public with sharing class WorkdayService {
    private static Boolean isRerunRequired = false;
	private String username = '';
	private String password = '';
	private String baseURL = '';
	private Map<String, SObjectField> peopleFieldMap = People__c.getSObjectType().getDescribe().fields.getMap();	
	
    // workday filter parameter
	private String WD_EFFECTIVE_DATE = 'EffectiveAsOfDate'; 
	
	public WorkdayService() {
        username = SimpplrContext.PDSWorkdayUsername;
        
        Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		Blob cipherText = EncodingUtil.base64Decode(SimpplrContext.PDSWorkdayPassword);
		password = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();
        
        baseURL  = SimpplrContext.PDSWorkdayEndpoint;            
	}

	/*
	 * Returns new hires
	 *
	 * @param  Date from date and to date to fetch data between range.
	 *
	 * @return List<WorkdayUserWrapper> 	list of new hires from Workday
	 */
	public List<Map<String, Object>> pullWorkdayUsers(String effectiveDate) {
		logger.logDebug('WorkdayService.pullWorkdayUsers()----effectiveDate----'+effectiveDate);
		
        List<Map<String, Object>> workdayUserMapList = null;
	    String url = this.baseURL;
		Boolean hasRequestParams = false;
	    if(url.contains('?')) {
	    	hasRequestParams = true;
	    }
	    if(url.containsIgnoreCase('@today@')) {
	    	url = url.replace('@today@', effectiveDate);
	    }
		url += (hasRequestParams ? '&' : '?') + EncodingUtil.urlEncode('format', 'UTF-8') + '=' + EncodingUtil.urlEncode('json', 'UTF-8');
		Blob headerValue = Blob.valueOf(this.username + ':' + this.password);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

		HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET',url,authorizationHeader,null,new Map<String,String>());
		if(res.getStatusCode()==200){
			workdayUserMapList = parseResponseIntoWorkdayUserWrapper(res.getBody());
		} else {
			throw new SimpplrException('Unable to pull records from Workday, received Status Code: ' + res.getStatusCode() + ', Status: ' + res.getStatus() + ', Body: ' + res.getBody());
		}
        logger.logDebug('WorkdayService.pullWorkdayUsers()----workdayUserMapList----'+workdayUserMapList);
		return workdayUserMapList;
	}

	/*
	 * Parse JSON repsponse from Workday into list of WorkdayUserWrapper
	 *
	 * @param  String 				JSON response from Workday
	 *
	 * @return List<WorkdayUserWrapper> 	deserialized new hire objects
	 */
	
	public List<Map<String, Object>> parseResponseIntoWorkdayUserWrapper(String response) {
		logger.logDebug('WorkdayService.parseResponseIntoWorkdayUserWrapper()----response----'+response);
		List<Map<String, Object>> workDayUserMapList = new List<Map<String, Object>>();

		// Parse response
		if (response != null) { 
			Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(response);
			
			if(resultObj.get('Report_Entry') != null){
				List<Object> objList = (List<Object>) resultObj.get('Report_Entry');

				for(Object obj : objList){
					workDayUserMapList.add((Map<String, Object>) obj);
				}
			}
		}
		else {
			
		}
		logger.logDebug('WorkdayService.parseResponseIntoWorkdayUserWrapper()----workDayUserMapList ----'+ workDayUserMapList);
		return workDayUserMapList;
	}
	
    public void processWorkdaySync(){
        String effectiveDate = formatDate(Date.today());
		List<Map<String, Object>> workDayUsersMapList = pullWorkdayUsers(effectiveDate);

		if(workDayUsersMapList != null && workDayUsersMapList.size() > 0){
	        Integer count= 0; 
	        Decimal maxCount = (SimpplrContext.PDSMaxSyncAttempts==null)? ServiceConstants.WORKDAY_MIN_SYNC: (SimpplrContext.PDSMaxSyncAttempts <= ServiceConstants.WORKDAY_MAX_SYNC) ? SimpplrContext.PDSMaxSyncAttempts : ServiceConstants.WORKDAY_MAX_SYNC;
	        do{
	            if(count>=maxCount){
	                break;
	           	}
		        if(SimpplrContext.isPDSEmployeeNumber){
		        	updatePeopleEmployeeNumber(workDayUsersMapList);   
		        }
	            isRerunRequired = false;
				updatePeopleFromWorkdayData(workDayUsersMapList);
	            count++;
	        } while(isRerunRequired && SimpplrContext.isPDSEmployeeNumber);
        }
    }
    
        /**
     * updates user workdayID field if null in salesforce and workday have not null value. It do not compare values.
     * 
     * */
    public void updatePeopleEmployeeNumber(List<Map<String, Object>> listOfWorkdayUserWrapper){
    	logger.logDebug('WorkdayService.updatePeopleEmployeeNumber()----listOfWorkdayUserWrapper----'+listOfWorkdayUserWrapper);
       
        List<Logs__c> simpplrLogList = new List<Logs__c>();
        Map<String, String> mapOfEmailAndEmployeeNumber = new Map<String, String>();
        for(Map<String, Object> wdUserWrapperObj : listOfWorkdayUserWrapper){
			mapOfEmailAndEmployeeNumber.put((String) wdUserWrapperObj.get('PrimaryWorkEmail'), String.valueOf(wdUserWrapperObj.get('EmployeeID')));
        }

        List<People__c> listOfUpdatedPeople = new List<People__c>();
        People__c[]  listOfPeople = [select id, user__c, Employee_Number__c, email__c 
        													from People__c 
        													where user__c != null 
        													And user__r.isActive = true 
        													And (user__r.UserType='Standard' Or User__r.Show_Simpplr__c ='Yes')
        													And email__c in :mapOfEmailAndEmployeeNumber.keySet()
															WITH SECURITY_ENFORCED];
	    for(People__c peopleObj: listOfPeople){
            if(String.isBlank(peopleObj.Employee_Number__c)){
             	String emailToCompare = peopleObj.email__c;
                peopleObj.Employee_Number__c = mapOfEmailAndEmployeeNumber.get(emailToCompare);
                listOfUpdatedPeople.add(peopleObj);

	        	simpplrLogList.add(constructSimpplrLogMessage('Successfully updated EmployeeNumber for userId - ' + peopleObj.user__c, 'WorkdayService.updatePeopleEmployeeNumber()'));
            }
        }

        try {
        	if(listOfUpdatedPeople.size() > 0) {
	        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(listOfUpdatedPeople),new List<Schema.SObjectField>{
		    													People__c.Employee_Number__c});
        	} else {
        		simpplrLogList.add(constructSimpplrLogMessage('No Employee Number found to be updated in People__c.', 'WorkdayUserSyncScheduler.updatePeopleEmployeeNumber()'));
        	}
        } catch (Exception ex) {
        	simpplrLogList =  new List<Logs__c>{constructSimpplrLogMessage('Failed to update People__c for ' + listOfUpdatedPeople.size() + ' users due to error: ' + ex.getMessage() + ': ' + ex.getStackTraceString(), 'WorkdayService.updatePeopleEmployeeNumber()')};
        }
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        SIMPESAPI.accessController().insertAsUser(simpplrLogList, new List<Schema.SObjectField>{Logs__c.Log_Type__c,
        																						Logs__c.Source_Info__c,
        																						Logs__c.Log_Data__c});
    }
    
    /***
     * Method compare and update user fields 
     * 
     **/
    public Boolean updatePeopleFromWorkdayData(List<Map<String, Object>> workdayUserMapList){
    	logger.logDebug('WorkdayService.updatePeopleFromWorkdayData()----workdayUserMapList----'+workdayUserMapList);
        
        List<Logs__c> simpplrLogList = new List<Logs__c>();
        Set<String> listOfManagerWorkdayIdNotSynchedwithSF = new Set<String>();
        
        Map<String, Map<String, Object>> wdUserMap = new Map<String, Map<String, Object>>();
        for(Map<String, Object> wdUserWrapperObj : workdayUserMapList){
            wdUserMap.put(String.valueOf(wdUserWrapperObj.get('EmployeeID')), wdUserWrapperObj);
        }
        
        List<People__c> listOfPeople = new List<People__c>();
        listOfPeople.addAll([SELECT City__c, Last_Edited_DateTime__c, Company_Name__c, Country__c, Department__c, Email__c, 
        				 Employee_Number__c, First_Name__c, Last_Name__c, Manager__c, Mobile_Phone__c,Role__c,Joining_Date__c,
        				 Division__c, Phone__c, Postal_Code__c, State__c, Street__c, Title__c, User__c, Is_Data_Sync_Done__c,
						 About__c, Raw_City__c, Raw_Country__c, Raw_State__c, Location_Normalization_Status__c,
						 Birth_Date__c, Community_Nickname__c, Extension__c, Fax__c, Custom_Field_1__c, Custom_Field_2__c, Custom_Field_3__c,
						 Custom_Field_4__c, Custom_Field_5__c, Custom_Field_6__c, Custom_Field_7__c, Custom_Field_8__c,
						 Custom_Field_9__c, Custom_Field_10__c, Custom_Field_11__c, Custom_Field_12__c, Custom_Field_13__c,
						 Custom_Field_14__c, Custom_Field_15__c, Custom_Field_16__c, Custom_Field_17__c, Custom_Field_18__c,
						 Custom_Field_19__c, Custom_Field_20__c, Custom_Field_21__c, Custom_Field_22__c, Custom_Field_23__c,
						 Custom_Field_24__c, Custom_Field_25__c
        				 FROM People__c 
        				 WHERE user__r.isActive = true And (user__r.UserType='Standard' Or User__r.Show_Simpplr__c ='Yes')
        				 AND Employee_Number__c IN :wdUserMap.keySet() WITH SECURITY_ENFORCED]);
        
        Map<String,String> managerEmployeeIdPeopleIdMap = new Map<String,String>();
        for(People__c peopleObj : [SELECT Id, Employee_Number__c FROM People__c WHERE user__r.isActive = true And (user__r.UserType='Standard' Or User__r.Show_Simpplr__c ='Yes') and Employee_Number__c != null]){
            managerEmployeeIdPeopleIdMap.put(peopleObj.Employee_Number__c, peopleObj.Id);
        }
        
        List<People__c> listOfUpdatedPeople = new List<People__c>();
        List<Schema.SObjectField> listOfModifiedColumns = new List<Schema.SObjectField>();
        Datetime syncDateTime = DateTime.now();
        Boolean pullAllFieldsForFirstSync = false;
		if(SimpplrContext.appConfig != null) {
			pullAllFieldsForFirstSync = SimpplrContext.appConfig.PDS_First_Pull_Sync_All_Fields__c;
		}

		Map<String, String> customFieldMap = new Map<String, String>();
		
		if(String.isNotBlank(SimpplrContext.PPUserCustomFields)){
			List<CustomProfileField> customFieldList = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);			
			for(CustomProfileField customField : customFieldList){
				if(!'workday'.equalsIgnoreCase(customField.syncSource)){
					continue;
				}
				customFieldMap.put(customField.columnName, customField.fieldName);
			}
		}

        // normalizing, comparing, updating fields.
        for(People__c peopleObj : listOfPeople){
            Boolean isModified = false;
            listOfModifiedColumns = new List<Schema.SObjectField>();
            Map<String, Object> wdUserWrapperObj = wdUserMap.get(peopleObj.Employee_Number__c);	
            if(SimpplrContext.isPDSTitle || (pullAllFieldsForFirstSync && peopleObj.Is_Data_Sync_Done__c == false)){ 
            	listOfModifiedColumns.add(People__c.Title__c);

				String businessTitle = wdUserWrapperObj.get('BusinessTitle') != null ? (String) wdUserWrapperObj.get('BusinessTitle') : '';
            	isModified = WorkdayUtility.updateBusinessTitle(peopleObj, businessTitle) || isModified;
            }
            
			if(SimpplrContext.isPDSFirstName || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.First_Name__c);

				String firstName = wdUserWrapperObj.get('FirstName') != null ? (String) wdUserWrapperObj.get('FirstName') : '';
				isModified = WorkdayUtility.updateFirstName(peopleObj, firstName) || isModified;
			}
			
			if(SimpplrContext.isPDSLastName || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Last_Name__c);

				String lastName = wdUserWrapperObj.get('LastName') != null ? (String) wdUserWrapperObj.get('LastName') : '';
				isModified = WorkdayUtility.updateLastName(peopleObj, lastName) || isModified;
			}
			
			if(SimpplrContext.isPDSDepartment || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Department__c);

				String department = wdUserWrapperObj.get('Department') != null ? (String) wdUserWrapperObj.get('Department') : '';
				isModified = WorkdayUtility.updateDepartment(peopleObj, department, SimpplrContext.isPDSEnableFormatting) || isModified;
			}
			
			if(SimpplrContext.isPDSDivision || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Division__c);

				String division = wdUserWrapperObj.get('Division') != null ? (String) wdUserWrapperObj.get('Division') : '';
				isModified = WorkdayUtility.updateDivision(peopleObj, division) || isModified;
			}

            if(SimpplrContext.isPDSState || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
            	listOfModifiedColumns.add(People__c.State__c);

				String workAddressStateProvince = wdUserWrapperObj.get('WorkAddressStateProvince') != null ? (String) wdUserWrapperObj.get('WorkAddressStateProvince') : '';
            	isModified = WorkdayUtility.updateStateProvince(peopleObj, workAddressStateProvince) || isModified;
        	}
        	
        	if(SimpplrContext.isPDSCountry || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
        		listOfModifiedColumns.add(People__c.Country__c);

				String workAddressCountry = wdUserWrapperObj.get('WorkAddressCountry') != null ? (String) wdUserWrapperObj.get('WorkAddressCountry') : '';
				isModified = WorkdayUtility.updateCountry(peopleObj, workAddressCountry) || isModified;
			}
			
			if(SimpplrContext.isPDSCity || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.City__c);

				String workAddressCity = wdUserWrapperObj.get('WorkAddressCity') != null ? (String) wdUserWrapperObj.get('WorkAddressCity') : '';
				isModified = WorkdayUtility.updateCity(peopleObj, workAddressCity) || isModified;
			}
			
			if(SimpplrContext.isPDSEmail || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Email__c);

				String primaryWorkEmail = wdUserWrapperObj.get('PrimaryWorkEmail') != null ? (String) wdUserWrapperObj.get('PrimaryWorkEmail') : '';
				isModified = WorkdayUtility.updateEmail(peopleObj, primaryWorkEmail) || isModified;
			}
			if(SimpplrContext.isPDSPostalCode || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Postal_Code__c);

				String workAddressPostalCode = wdUserWrapperObj.get('WorkAddressPostalCode') != null ? (String) wdUserWrapperObj.get('WorkAddressPostalCode') : '';
				isModified = WorkdayUtility.updatePostalCode(peopleObj, workAddressPostalCode) || isModified;
			}
			
			if(SimpplrContext.isPDSPhone || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Phone__c);

				String publicWorkPhones = wdUserWrapperObj.get('PublicWorkPhones') != null ? (String) wdUserWrapperObj.get('PublicWorkPhones') : '';
				isModified = WorkdayUtility.updatePhones(peopleObj, publicWorkPhones) || isModified;
			}
			if(SimpplrContext.isPDSMobilePhone || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Mobile_Phone__c);

				String publicWorkMobilePhones = wdUserWrapperObj.get('PublicWorkMobilePhones') != null ? (String) wdUserWrapperObj.get('PublicWorkMobilePhones') : '';
				isModified = WorkdayUtility.updateMobilePhone(peopleObj, publicWorkMobilePhones) || isModified;
			}
			
			if(SimpplrContext.isPDSManagerId || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Manager__c);

				String managerID = wdUserWrapperObj.get('ManagerID') != null ? (String) wdUserWrapperObj.get('ManagerID') : '';
				isModified = WorkdayUtility.updateReportingManager(peopleObj, managerID, managerEmployeeIdPeopleIdMap, listOfManagerWorkdayIdNotSynchedwithSF) || isModified;
			}
			
			if(SimpplrContext.isPDSStreet || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Street__c);

				String location = wdUserWrapperObj.get('Location') != null ? (String) wdUserWrapperObj.get('Location') : '';
				String workAddressFormattedLine1 = wdUserWrapperObj.get('WorkAddressFormattedLine1') != null ? (String) wdUserWrapperObj.get('WorkAddressFormattedLine1') : '';
				String workAddressFormattedLine2 = wdUserWrapperObj.get('WorkAddressFormattedLine2') != null ? (String) wdUserWrapperObj.get('WorkAddressFormattedLine2') : '';
				isModified = WorkdayUtility.updateStreet(peopleObj, location, workAddressFormattedLine1, workAddressFormattedLine2) || isModified;
			}
			
			if(SimpplrContext.isPDSRole || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Role__c);

				String role = wdUserWrapperObj.get('Role') != null ? (String) wdUserWrapperObj.get('Role') : '';
				isModified = WorkdayUtility.updateRole(peopleObj, role) || isModified;
			}
			
			if(SimpplrContext.isPDSJoiningDate || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Joining_Date__c);

				String hireDate = wdUserWrapperObj.get('HireDate') != null ? (String) wdUserWrapperObj.get('HireDate') : '';
				isModified = WorkdayUtility.updateHireDate(peopleObj, hireDate) || isModified;
			}
			
			if(SimpplrContext.isPDSAboutMe || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.About__c);
				
				String aboutMe = wdUserWrapperObj.get('AboutMe') != null ? (String) wdUserWrapperObj.get('AboutMe') : '';
				isModified = WorkdayUtility.updateAboutMe(peopleObj, aboutMe) || isModified;
			}
			
			if(SimpplrContext.isPDSBirthDate || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Birth_Date__c);

				String birthDate = wdUserWrapperObj.get('BirthDate') != null ? (String) wdUserWrapperObj.get('BirthDate') : '';
				isModified = WorkdayUtility.updateBirthDate(peopleObj, birthDate) || isModified;
			}
			if(SimpplrContext.isPDSCommunityNickname || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Community_Nickname__c);

				String nickName = wdUserWrapperObj.get('NickName') != null ? (String) wdUserWrapperObj.get('NickName') : '';
				isModified = WorkdayUtility.updateCommunityNickName(peopleObj, nickName) || isModified;
			}
			
			if(SimpplrContext.isPDSCompanyName || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Company_Name__c);

				String companyName = wdUserWrapperObj.get('CompanyName') != null ? (String) wdUserWrapperObj.get('CompanyName') : '';
				isModified = WorkdayUtility.updateCompanyName(peopleObj, companyName) || isModified;
			}
			
			if(SimpplrContext.isPDSExtension || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Extension__c);

				String extension = wdUserWrapperObj.get('Extension') != null ? (String) wdUserWrapperObj.get('Extension') : '';
				isModified = WorkdayUtility.updateExtension(peopleObj, extension) || isModified;
			}
			
			if(SimpplrContext.isPDSFax || (pullAllFieldsForFirstSync  && peopleObj.Is_Data_Sync_Done__c == false)){
				listOfModifiedColumns.add(People__c.Fax__c);

				String fax = wdUserWrapperObj.get('Fax') != null ? (String) wdUserWrapperObj.get('Fax') : '';
				isModified = WorkdayUtility.updateFax(peopleObj, fax) || isModified;
			}
			if(customFieldMap.isEmpty() == false) {
				String customFieldName = null;
				String customFieldValue = null;
				// Custom fields
				for(String peopleFieldApiName : customFieldMap.keySet()) {
					if(customFieldMap.get(peopleFieldApiName) != null) {
						customFieldName = (String) customFieldMap.get(peopleFieldApiName);
						listOfModifiedColumns.add(peopleFieldMap.get(SimpplrContext.namespacePrefix + peopleFieldApiName));
						customFieldValue = wdUserWrapperObj.get(customFieldName) != null ? (String) wdUserWrapperObj.get(customFieldName) : '';
						isModified = WorkdayUtility.updateCustomField(peopleObj, customFieldValue, peopleFieldApiName) || isModified;
					}
				}
			}
			
            if(listOfManagerWorkdayIdNotSynchedwithSF.size()>0){
                isRerunRequired = true;
            }

            if(isModified){
            	peopleObj.Is_Data_Sync_Done__c = true;
            	peopleObj.Last_Sync_DateTime__c = syncDateTime;
            	peopleObj.Last_Edited_DateTime__c = syncDateTime;
            	listOfModifiedColumns.add(People__c.Is_Data_Sync_Done__c);
				listOfModifiedColumns.add(People__c.Last_Sync_DateTime__c);
				listOfModifiedColumns.add(People__c.Last_Edited_DateTime__c);
                listOfUpdatedPeople.add(peopleObj);
                simpplrLogList.add(constructSimpplrLogMessage('Successfully updated People__c for userId - ' + peopleObj.user__c, 'WorkdayUserSyncScheduler.updateWorkdayEmployees()'));
            }
         
        }

		String status = 'failed';
        try {
	        if(listOfUpdatedPeople.size() > 0) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(listOfUpdatedPeople),listOfModifiedColumns);
	        } else {
	        	simpplrLogList.add(constructSimpplrLogMessage('No records found to be updated in People__c.', 'WorkdayUserSyncScheduler.updateWorkdayEmployees()'));
	        }

			status = 'successful';
        } catch (Exception ex) {
        	simpplrLogList =  new List<Logs__c>{constructSimpplrLogMessage('Failed to update People__c for ' + listOfUpdatedPeople.size() + ' users due to error: ' + ex.getMessage() + ': ' + ex.getStackTraceString(), 'WorkdayService.updatePeopleFromWorkdayData()')};
        }
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        SIMPESAPI.accessController().insertAsUser(simpplrLogList, new List<Schema.SObjectField>{Logs__c.Log_Type__c,
        																						Logs__c.Source_Info__c,
        																						Logs__c.Log_Data__c});

		if(isRerunRequired == false){
			// create logs for this batch job
			ManageApplicationDao.logUserSyncProvStatus(status, 'User Sync workday');
		}

		return isRerunRequired;
    }
    
    
    /**
     *  format date for workday format.
     */
     
    public String formatDate(Date dateToFormat) {
        String month = String.valueOf(dateToFormat.month());
        // change to MM
        if (month.length() == 1) { 
            month = '0' + month;
        }
        String day = String.valueOf(dateToFormat.day());
        // change to DD
        if (day.length() == 1) { 
            day = '0' + day;
        }
        String formattedDate =  dateToFormat.year() + '-' + month + '-' + day; // YYYY-MM-DD
        return formattedDate;
    }
    
    /**
     * Log sync messages in simpplr log object
     * */
    @TestVisible 
    private Logs__c constructSimpplrLogMessage(String message, String source){
        Logs__c simpplrLogObj = new Logs__c(Log_Type__c = 'WORKDAY_SYNC',
        													Source_Info__c = source,
        													Log_Data__c = message);
        
        return simpplrLogObj;
    }

}