public with sharing class BatchOktaUserSync implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
	private Exception exceptionDetailsObj;
    private String syncIdentifier;
    private String nextPageLink;
    private String maxResults = '200';
    private Map<String, Object> emailVsManagerUserIdMap;
    private String batchType;
    private Map<String, SObjectField> peopleFieldMap = People__c.getSObjectType().getDescribe().fields.getMap();
    
    public BatchOktaUserSync() {
    }

    public BatchOktaUserSync(String batchType) {
        this.batchType = batchType;
    }

    public BatchOktaUserSync(String batchType, String nextPageLink) {
        this.batchType = batchType;
        this.nextPageLink = nextPageLink;
    }

    public database.querylocator start(Database.BatchableContext bc){
	 	String query = ' SELECT Id FROM App_Config__c LIMIT 1';
        
    	return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
            if('syncIdentifier'.equalsIgnoreCase(batchType)){
                // Get users from OKTA API
                List<Object> oktaDataList = getUsersFromOkta();

                // Update Sync identifier first
                updatePeopleSyncIdentifier(oktaDataList);
                
            } else if('userSync'.equalsIgnoreCase(batchType)) {
                // Get users from OKTA API
                List<Object> oktaDataList = getUsersFromOkta();

                // Sync Users
                syncUsers(oktaDataList);
                
            }
		} catch(Exception ex) {
			exceptionDetailsObj = ex;
    		throw ex;
    	}
    }

    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email,
                                     ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;

		} else {
			// Exception
		}

        if(canStartNextBatch){
            if('syncIdentifier'.equalsIgnoreCase(batchType)){
                String batchToExecute = 'userSync';
                if(String.isNotBlank(nextPageLink)){
                    batchToExecute = 'syncIdentifier';
                }
    
                BatchOktaUserSync job = new BatchOktaUserSync(batchToExecute, nextPageLink);
                Database.executeBatch(job, 1);
                
            } else if('userSync'.equalsIgnoreCase(batchType)) {        
                if(String.isNotBlank(nextPageLink)){
    
                    BatchOktaUserSync job = new BatchOktaUserSync(batchType, nextPageLink);
                    Database.executeBatch(job, 1);
    
                } else {
                    // Sync completed
    
                    // create logs for this batch job
                    ManageApplicationDao.logUserSyncProvStatus('successful', 'User Sync okta');

                    // Added to execute nigthly jobs sequentially
                    SchedulerSimpplrServices.executeNextJob('peopleSync');                    
                }
            }
        } else {
            // create logs for this batch job
            ManageApplicationDao.logUserSyncProvStatus('failed', 'User Sync okta');

            // Added to execute nigthly jobs sequentially
            SchedulerSimpplrServices.executeNextJob('peopleSync');            
        }
          
    }

    // Sync google users
    private void syncUsers(List<Object> oktaDataList){
        Map<String, Map<String, Object>> oktaIdVsUserMap = new Map<String, Map<String, Object>>();

        Map<String, Object> oktaUserMap = null;
        for(Object oktaObj : oktadataList){
            oktaUserMap = (Map<String, Object>) oktaObj;

            oktaIdVsUserMap.put((String) oktaUserMap.get('id'), oktaUserMap);
        }
        
        List<People__c> peopleList = [SELECT Id, City__c, Last_Edited_DateTime__c, Company_Name__c, Country__c, Department__c, Email__c, 
                                        Sync_Field__c, First_Name__c, Last_Name__c, Manager__c, Mobile_Phone__c, Role__c, Joining_Date__c,
                                        Division__c, Phone__c, Postal_Code__c, State__c, Street__c, Title__c, User__c, Is_Data_Sync_Done__c,
                                        About__c, Raw_City__c, Raw_Country__c, Raw_State__c, Location_Normalization_Status__c,
                                        Birth_Date__c, Community_Nickname__c, Extension__c, Fax__c, Employee_Number__c,
                                        Custom_Field_1__c, Custom_Field_2__c, Custom_Field_3__c, Custom_Field_4__c, Custom_Field_5__c,
                                        Custom_Field_6__c, Custom_Field_7__c, Custom_Field_8__c, Custom_Field_9__c, Custom_Field_10__c,
                                        Custom_Field_11__c, Custom_Field_12__c, Custom_Field_13__c, Custom_Field_14__c, Custom_Field_15__c,
                                        Custom_Field_16__c, Custom_Field_17__c, Custom_Field_18__c, Custom_Field_19__c, Custom_Field_20__c,
                                        Custom_Field_21__c, Custom_Field_22__c, Custom_Field_23__c, Custom_Field_24__c, Custom_Field_25__c
                                        FROM People__c 
                                        WHERE user__r.IsActive = true AND (User__r.UserType='Standard' OR User__r.Show_Simpplr__c ='Yes')
                                        AND Sync_Field__c IN :oktaIdVsUserMap.keySet()];
        
        Map<String, String> managerEmailIdPeopleIdMap = new Map<String, String>();
        for(People__c peopleObj : [SELECT Id, Sync_Field__c, Email__c FROM People__c WHERE User__r.IsActive = true AND (User__r.UserType='Standard' OR User__r.Show_Simpplr__c ='Yes')]){
            managerEmailIdPeopleIdMap.put((peopleObj.Email__c).toLowerCase(), peopleObj.Id);
        }
        
        // Create custom fields map
        Map<String, String> customFieldMap = new Map<String, String>();
		if(String.isNotBlank(SimpplrContext.PPUserCustomFields)){
			List<CustomProfileField> customFieldList = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);			
			for(CustomProfileField customField : customFieldList){
				if(!'okta'.equalsIgnoreCase(customField.syncSource)){
					continue;
				}
				customFieldMap.put(customField.columnName, customField.fieldName);
			}
		}

        List<People__c> listOfUpdatedPeople = new List<People__c>();
        List<Schema.SObjectField> listOfModifiedColumns = new List<Schema.SObjectField>();
        Datetime syncDateTime = DateTime.now();
        Map<String, Object> oktaUserProfileMap = null;
        for(People__c peopleObj : peopleList){
            Boolean isModified = false;
            listOfModifiedColumns = new List<Schema.SObjectField>();

            oktaUserMap = (Map<String, Object>)  oktaIdVsUserMap.get(peopleObj.Sync_Field__c);
            oktaUserProfileMap = (Map<String, Object>) oktaUserMap.get('profile');

            if(SimpplrContext.isPDSEmployeeNumber){ 
            	listOfModifiedColumns.add(People__c.Employee_Number__c);

                String empNumber = oktaUserProfileMap.get('employeeNumber') != null ? (String) oktaUserProfileMap.get('employeeNumber') : '';
				isModified = OktaUtility.updateEmployeeNumber(peopleObj, empNumber) || isModified;
            }

            if(SimpplrContext.isPDSTitle){ 
            	listOfModifiedColumns.add(People__c.Title__c);

                String title = oktaUserProfileMap.get('title') != null ? (String) oktaUserProfileMap.get('title') : '';
				isModified = OktaUtility.updateBusinessTitle(peopleObj, title) || isModified;
            }
            
			if(SimpplrContext.isPDSFirstName){
				listOfModifiedColumns.add(People__c.First_Name__c);

				String firstName = oktaUserProfileMap.get('firstName') != null ? (String) oktaUserProfileMap.get('firstName') : '';
				isModified = OktaUtility.updateFirstName(peopleObj, firstName) || isModified;
			}
			
			if(SimpplrContext.isPDSLastName){
				listOfModifiedColumns.add(People__c.Last_Name__c);

				String lastName = oktaUserProfileMap.get('lastName') != null ? (String) oktaUserProfileMap.get('lastName') : '';
				isModified = OktaUtility.updateLastName(peopleObj, lastName) || isModified;
			}
			
			if(SimpplrContext.isPDSDepartment){
				listOfModifiedColumns.add(People__c.Department__c);

				String department = oktaUserProfileMap.get('department') != null ? (String) oktaUserProfileMap.get('department') : '';
				isModified = OktaUtility.updateDepartment(peopleObj, department, SimpplrContext.isPDSEnableFormatting) || isModified;
			}
			
			if(SimpplrContext.isPDSDivision){
				listOfModifiedColumns.add(People__c.Division__c);

				String division = oktaUserProfileMap.get('division') != null ? (String) oktaUserProfileMap.get('division') : '';
				isModified = OktaUtility.updateDivision(peopleObj, division) || isModified;
			}

            if(SimpplrContext.isPDSState){
            	listOfModifiedColumns.add(People__c.State__c);

				String state = oktaUserProfileMap.get('state') != null ? (String) oktaUserProfileMap.get('state') : '';
            	isModified = OktaUtility.updateStateProvince(peopleObj, state) || isModified;
        	}
        	
        	if(SimpplrContext.isPDSCountry){
        		listOfModifiedColumns.add(People__c.Country__c);
                
				String workAddressCountry = oktaUserProfileMap.get('countryCode') != null ? (String) oktaUserProfileMap.get('countryCode') : '';
				isModified = OktaUtility.updateCountry(peopleObj, workAddressCountry) || isModified;
			}
			
			if(SimpplrContext.isPDSCity){
				listOfModifiedColumns.add(People__c.City__c);

				String workAddressCity = oktaUserProfileMap.get('city') != null ? (String) oktaUserProfileMap.get('city') : '';
				isModified = OktaUtility.updateCity(peopleObj, workAddressCity) || isModified;
			}
			
			if(SimpplrContext.isPDSEmail){
				listOfModifiedColumns.add(People__c.Email__c);

				String primaryWorkEmail = oktaUserProfileMap.get('email') != null ? (String) oktaUserProfileMap.get('email') : '';
				isModified = OktaUtility.updateEmail(peopleObj, primaryWorkEmail) || isModified;
			}
			if(SimpplrContext.isPDSPostalCode){
				listOfModifiedColumns.add(People__c.Postal_Code__c);

				String workAddressPostalCode = oktaUserProfileMap.get('zipCode') != null ? (String) oktaUserProfileMap.get('zipCode') : '';
				isModified = OktaUtility.updatePostalCode(peopleObj, workAddressPostalCode) || isModified;
			}
			
			if(SimpplrContext.isPDSPhone){
				listOfModifiedColumns.add(People__c.Phone__c);

				String publicWorkPhones = oktaUserProfileMap.get('primaryPhone') != null ? (String) oktaUserProfileMap.get('primaryPhone') : '';
				isModified = OktaUtility.updatePhones(peopleObj, publicWorkPhones) || isModified;
			}
			if(SimpplrContext.isPDSMobilePhone){
				listOfModifiedColumns.add(People__c.Mobile_Phone__c);

				String publicWorkMobilePhones = oktaUserProfileMap.get('mobilePhone') != null ? (String) oktaUserProfileMap.get('mobilePhone') : '';
				isModified = OktaUtility.updateMobilePhone(peopleObj, publicWorkMobilePhones) || isModified;
			}
			
			if(SimpplrContext.isPDSManagerId){
				listOfModifiedColumns.add(People__c.Manager__c);
                String managerID = '';
                if(oktaUserProfileMap.get('managerEmail') != null) {
                    managerID = ((String) oktaUserProfileMap.get('managerEmail')).toLowerCase();   
                                 
                } else if(oktaUserProfileMap.get('manager') != null) {
                    managerID = ((String) oktaUserProfileMap.get('manager')).toLowerCase();
                }
                isModified = OktaUtility.updateReportingManager(peopleObj, managerID, managerEmailIdPeopleIdMap) || isModified;
			}
			
			if(SimpplrContext.isPDSStreet){
				listOfModifiedColumns.add(People__c.Street__c);

				String street = oktaUserProfileMap.get('streetAddress') != null ? (String) oktaUserProfileMap.get('streetAddress') : '';
				isModified = OktaUtility.updateStreet(peopleObj, street) || isModified;
			}
			
			if(SimpplrContext.isPDSJoiningDate && String.isNotBlank(SimpplrContext.pdsJoiningDateKey)){
				listOfModifiedColumns.add(People__c.Joining_Date__c);

				String hireDate = oktaUserProfileMap.get(SimpplrContext.pdsJoiningDateKey) != null ? (String) oktaUserProfileMap.get(SimpplrContext.pdsJoiningDateKey) : '';
				isModified = OktaUtility.updateHireDate(peopleObj, hireDate) || isModified;
			}
			
			if(SimpplrContext.isPDSBirthDate && String.isNotBlank(SimpplrContext.pdsBirthDateKey)){
				listOfModifiedColumns.add(People__c.Birth_Date__c);

				String birthDate = oktaUserProfileMap.get(SimpplrContext.pdsBirthDateKey) != null ? (String) oktaUserProfileMap.get(SimpplrContext.pdsBirthDateKey) : '';
				isModified = OktaUtility.updateBirthDate(peopleObj, birthDate) || isModified;
            }
            
			if(SimpplrContext.isPDSCommunityNickname){
				listOfModifiedColumns.add(People__c.Community_Nickname__c);

				String nickName = oktaUserProfileMap.get('nickName') != null ? (String) oktaUserProfileMap.get('nickName') : '';
				isModified = OktaUtility.updateCommunityNickName(peopleObj, nickName) || isModified;
			}
			
			if(SimpplrContext.isPDSCompanyName){
				listOfModifiedColumns.add(People__c.Company_Name__c);

				String companyName = oktaUserProfileMap.get('organization') != null ? (String) oktaUserProfileMap.get('organization') : '';
				isModified = OktaUtility.updateCompanyName(peopleObj, companyName) || isModified;
            }
            
			if(customFieldMap.isEmpty() == false) {
				String customFieldName = null;
				String customFieldValue = null;
				// Sync custom fields
                for(String peopleFieldApiName : customFieldMap.keySet()) { 
                    if(customFieldMap.get(peopleFieldApiName) != null) {
                        customFieldName = (String) customFieldMap.get(peopleFieldApiName);
                        listOfModifiedColumns.add(peopleFieldMap.get(SimpplrContext.namespacePrefix + peopleFieldApiName));
                        customFieldValue = oktaUserProfileMap.get(customFieldName) != null ? (String) oktaUserProfileMap.get(customFieldName) : '';
    
                        isModified = OktaUtility.updateCustomField(peopleObj, customFieldValue, peopleFieldApiName) || isModified;
                    }
                }
			}

            if(isModified){
            	peopleObj.Is_Data_Sync_Done__c = true;
            	peopleObj.Last_Sync_DateTime__c = syncDateTime;
            	peopleObj.Last_Edited_DateTime__c = syncDateTime;
            	listOfModifiedColumns.add(People__c.Is_Data_Sync_Done__c);
                listOfModifiedColumns.add(People__c.Last_Sync_DateTime__c);
                listOfModifiedColumns.add(People__c.Last_Edited_DateTime__c);
                listOfUpdatedPeople.add(peopleObj);
            }
         
        }
        try {
	        if(listOfUpdatedPeople.size() > 0) {
	        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(listOfUpdatedPeople), listOfModifiedColumns);
	        }
        } catch (Exception ex) {
            exceptionDetailsObj = ex;
            throw ex;
        	
        }

    }

    private void updatePeopleSyncIdentifier(List<Object> oktadataList){
        Map<String, String> emailVsOktaIdMap = new Map<String, String>();
        
        Map<String, Object> oktaUserMap = null;
        Map<String, Object> oktaUserProfileMap = null;
        for(Object oktaObj : oktadataList){
            oktaUserMap = (Map<String, Object>) oktaObj;

            oktaUserProfileMap = (Map<String, Object>) oktaUserMap.get('profile');

			emailVsOktaIdMap.put(((String) oktaUserProfileMap.get('email')).toLowerCase(), (String) oktaUserMap.get('id'));
        }

        List<People__c> updatedPeopleList = new List<People__c>();
        People__c[]  listOfPeople = [SELECT id, user__c, Sync_Field__c, email__c 
                                        FROM People__c 
                                        WHERE user__c != null 
                                        AND user__r.isActive = true 
                                        AND (user__r.UserType = 'Standard' OR User__r.Show_Simpplr__c = 'Yes')
                                        AND email__c IN :emailVsOktaIdMap.keySet()];

	    for(People__c peopleObj: listOfPeople){
            if(String.isBlank(peopleObj.Sync_Field__c)){
                peopleObj.Sync_Field__c = emailVsOktaIdMap.get((peopleObj.email__c).toLowerCase());

                updatedPeopleList.add(peopleObj);
            }
        }

        try {
        	if(updatedPeopleList.size() > 0) {
	        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(updatedPeopleList), new List<Schema.SObjectField>{
		    													People__c.Sync_Field__c});
        	} else {
        		// Nothing to update
        	}
        } catch (Exception ex) {
        	// Exception occured
            exceptionDetailsObj = ex;
            throw ex;
        }
    }

    private List<Object> getUsersFromOkta(){
        List<Object> oktaDataList = null;
        String endpoint = '';

        if(String.isNotBlank(nextPageLink)){

            endpoint = nextPageLink;
        } else {
    
            endpoint += SimpplrContext.OktaLink + '/api/v1/users?';
            endpoint += 'limit=' + maxResults;
            
        }

        HttpResponse httpResponseObj = getJsonResponse(endpoint);
        Boolean isNextLinkFound = false;
        if(httpresponseObj.getStatusCode() == 200){
            String bodyStr = httpresponseObj.getBody();

            if(String.isNotBlank(bodyStr)){
                oktaDataList = (List<Object>) JSON.deserializeUntyped(bodyStr);
                
                // Extract next page token from response header
                String headerLink = httpresponseObj.getHeader('link');
                if(String.isNotBlank(headerLink) && headerLink.contains('rel="next"')){
                    for(String str : headerLink.split(';')){
                    
                        if(str.contains('after=')){
                            isNextLinkFound = true;
                            nextPageLink = str.remove('<').remove('>');
                            
                            break;
                        }
                    }
                }
            }
        }

        if(!isNextLinkFound){
            nextPageLink = '';
        }

        return oktaDataList;
    }

    @Testvisible 
	private HTTPResponse getJsonResponse(String url) {

        Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
        Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
        Blob cipherText = EncodingUtil.base64Decode(SimpplrContext.OktaAPIToken);
        String oktaApiToken = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();

		HttpRequest req = new HttpRequest();
         
        req.setEndpoint(url);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'SSWS ' + oktaApiToken);
        req.setMethod('GET');

        Http http = new Http();

		return (http.send(req));
    }

    private static Date convertStringToDate(String dateObj, Boolean isBirthday){
    	// DateObj is assumed to be in yyyy-MM-dd format
    	List<String> dateObjSplitArray = dateObj.split('-');
    	Date convertedDate = null;
    	if(dateObjSplitArray.size() == 3){
			
			Integer month 	= Integer.valueOf(dateObjSplitArray[1]);
            Integer day		= Integer.valueOf(dateObjSplitArray[2]);
            
            if(isBirthday){
                convertedDate 	= Date.newInstance(1904, month, day);
            } else {
                Integer year 	= Integer.valueOf(dateObjSplitArray[0]);

                convertedDate 	= Date.newInstance(year, month, day);
            }
    	}
    	
    	return convertedDate;
    }

}