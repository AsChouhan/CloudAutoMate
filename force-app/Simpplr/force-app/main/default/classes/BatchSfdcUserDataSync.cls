public with sharing class BatchSfdcUserDataSync implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    private List<String> consolidatedListOfUserIds;
    public Boolean joiningDateExistBool ;
    public Boolean birthDateExistBool ;
	public Set<String> fieldsToQuerySet;
    
    Integer pageNumber = 0;
    Boolean hasMore = false;
    Integer maxRepetetionAllowed = 0;
    Boolean isRerunRequired = false;
    String batchType; 
	String packageName ;
	Map<String, String> userToPeopleFieldMap = new Map<String, String>(); 
	Set<String> customFieldsToSyncSet = new Set<String>{
		'Custom_Field_1__c',
		'Custom_Field_2__c',
		'Custom_Field_3__c',
		'Custom_Field_4__c',
		'Custom_Field_5__c'
		};
	Map<String, String> customFieldsNameLabelMap = new Map<String, String>();	

	public BatchSfdcUserDataSync(String batchType,Map<String, String> userToPeopleFieldMap){
		this.batchType = batchType ;
		this.userToPeopleFieldMap = userToPeopleFieldMap ; 
	}

	/**
	 * @description constructor with param batchType
	 * @param batchType
	 */
	public BatchSfdcUserDataSync(String batchType){
		this.batchType = batchType;
	}	

    public database.querylocator start(Database.BatchableContext bc){
    	String query;
    	if('WorkdaySync'.equalsIgnoreCase(batchType)) {
    		query = 'SELECT id from App_Config__c ';
    		
    	} else if('WorkdaySyncFromServiceClass'.equalsIgnoreCase(batchType)) {
			query = 'SELECT id from App_Config__c ';

		} else if('UserCustomFieldSync'.equalsIgnoreCase(batchType)) {
			query = getPeopleDescribeQuery(userToPeopleFieldMap) ;
		} 
		else {
			String userFieldString = String.join(new List<String>(fieldsToQuerySet), ',');
			query = 'SELECT ' + userFieldString + ', (select Id, User__c from Parent_User__r) ' + ' from User where id in (select user__c from People__c) ';
    	}
    	return Database.getQueryLocator(query);
    }
    
	public String getPeopleDescribeQuery(Map<String,String> userToPeopleFieldMap) {

		String query = 'SELECT ' ; 
		String objectType ;
		SObjectType sObjType ;
		Set<String> fields = new Set<String>();
		packageName = SimpplrContext.packageName;
		String whereClause = '';
			objectType = 'people__c' ;
			sObjType = ((SObject) Type.forName(objectType).newInstance()).getSObjectType();
			fields = sObjType.getDescribe().fields.getMap().keySet() ;	
			whereClause = ' WHERE User__r.isActive=true AND User__r.UserType=\'Standard\' ' ;		
			
		for (String userObj : userToPeopleFieldMap.keyset()){             
                     query += userObj + ',';
            }
		for(String peopleObj : fields){
					query +=  peopleObj + ',' ;
		}
		query = query.removeEnd(',');
		query  += ' FROM ' + objectType  +  whereClause;
		
		if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
    		query += ' AND User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
    	}
		return query ;
	}

    public BatchSfdcUserDataSync(){
		fieldsToQuerySet = new Set<String>();
		fieldsToQuerySet = populateFieldsToQuerySet();
		consolidatedListOfUserIds = new List<String>();
        Map<String,Schema.DescribeFieldResult> userFieldDescribeMap;
        joiningDateExistBool = false;
        birthDateExistBool = false;
        
        if (SimpplrContext.isPDSJoiningDate || SimpplrContext.isPDSBirthDate) {
            userFieldDescribeMap = getUserFieldDescribeMap();
            
            if (userFieldDescribeMap != NULL){
					
				if (userFieldDescribeMap.containsKey('Joining_Date__c') ) {
					joiningDateExistBool = true;
					fieldsToQuerySet.add('Joining_Date__c');
				}	
				
				if (userFieldDescribeMap.containsKey('Birth_Date__c') ) {
					birthDateExistBool = true;
					fieldsToQuerySet.add('Birth_Date__c');
				}
			}	
				
        }

		// Add custom fields to query
		List<App_Config__c> appConfig = [SELECT Id, PP_User_Custom_Fields__c FROM App_Config__c LIMIT 1];
		if(appConfig != null && !appConfig.isEmpty()){

			String customFieldsStr = appConfig[0].PP_User_Custom_Fields__c;
			if(String.isNotBlank(customFieldsStr)){
				if(userFieldDescribeMap == null) {
					userFieldDescribeMap = getUserFieldDescribeMap();					
				}
				List<CustomProfileField> customFieldList = (List<CustomProfileField>)Json.deserialize(customFieldsStr, List<CustomProfileField>.class);
				
				for(CustomProfileField customField : customFieldList){
					if(!'salesforce'.equalsIgnoreCase(customField.syncSource)){
						continue;
					}
					
					if(userFieldDescribeMap.containsKey(customField.fieldName)) {
						fieldsToQuerySet.add(customField.fieldName);
						customFieldsNameLabelMap.put(customField.columnName, customField.fieldName);
					}
				}
			}
		}
	}

	/**
	 * @description populate set with fields to query from user object
	 * @return Set<String> 
	 */
	public Set<String> populateFieldsToQuerySet() {

		Set<String> fieldsToQuerySet = new Set<String>();
		fieldsToQuerySet.add('AboutMe');
		fieldsToQuerySet.add('City');
		fieldsToQuerySet.add('CommunityNickname');
		fieldsToQuerySet.add('CompanyName');
		fieldsToQuerySet.add('Country');
		fieldsToQuerySet.add('Department');
		fieldsToQuerySet.add('Division');
		fieldsToQuerySet.add('Email');
		fieldsToQuerySet.add('EmployeeNumber');
		fieldsToQuerySet.add('Extension');
		fieldsToQuerySet.add('Fax');
		fieldsToQuerySet.add('FirstName');
		fieldsToQuerySet.add('LastName');
		fieldsToQuerySet.add('ManagerId');
		fieldsToQuerySet.add('MobilePhone');
		fieldsToQuerySet.add('Name');
		fieldsToQuerySet.add('Phone');
		fieldsToQuerySet.add('PostalCode');
		fieldsToQuerySet.add('State');
		fieldsToQuerySet.add('Street');
		fieldsToQuerySet.add('Title');
		fieldsToQuerySet.add('AboutMe__c');
		fieldsToQuerySet.add('City__c');
		fieldsToQuerySet.add('CommunityNickname__c');
		fieldsToQuerySet.add('CompanyName__c');
		fieldsToQuerySet.add('Country__c');
		fieldsToQuerySet.add('Department__c');
		fieldsToQuerySet.add('Division__c');
		fieldsToQuerySet.add('Email__c');
		fieldsToQuerySet.add('EmployeeNumber__c');
		fieldsToQuerySet.add('Extension__c');
		fieldsToQuerySet.add('Fax__c');
		fieldsToQuerySet.add('FirstName__c');
		fieldsToQuerySet.add('LastName__c');
		fieldsToQuerySet.add('MobilePhone__c');
		fieldsToQuerySet.add('Phone__c');
		fieldsToQuerySet.add('PostalCode__c');
		fieldsToQuerySet.add('State__c');
		fieldsToQuerySet.add('Street__c');
		fieldsToQuerySet.add('Title__c');

		return fieldsToQuerySet;
	} 

	public BatchSfdcUserDataSync(Integer pageNumb, Integer maxRepetetionAllowed) {
		this.batchType = 'WorkdaySync';
		pageNumber = pageNumb;
        this.maxRepetetionAllowed = maxRepetetionAllowed;
	}
	
	public Map<String,Schema.DescribeFieldResult> getUserFieldDescribeMap () {
		Map<String,Schema.DescribeFieldResult> userFieldDescribeMap = new Map<String, Schema.DescribeFieldResult>();
		Schema.SObjectType userDescribeResult = Schema.getGlobalDescribe().get('User');
			
		if (String.isNotBlank(String.valueOf(userDescribeResult))) {
            Schema.DescribeSObjectResult dsr = userDescribeResult.getDescribe();
            Map<String, Schema.SObjectField> objectFieldsMap = dsr.fields.getMap();
			
			for (String field : objectFieldsMap.keySet()) {
                Schema.DescribeFieldResult dfr = objectFieldsMap.get(field).getDescribe();
				userFieldDescribeMap.put(String.valueOf(dfr.getName()),dfr);
            }
			
			
        } 
		
		return userFieldDescribeMap;          
	} 
	
	public void execute(Database.BatchableContext bc, sObject[] objects){
	
		if('WorkdaySync'.equalsIgnoreCase(batchType)) {
			if(String.isNotBlank(SimpplrContext.PDSWorkdayEndpoint)){
				syncFromWorkday(SimpplrContext.PDSWorkdayEndpoint);
			}
			
		} else if('WorkdaySyncFromServiceClass'.equalsIgnoreCase(batchType)) {

			try {
				WorkdayService serviceObj = new WorkdayService();
				serviceObj.processWorkdaySync();				
			} catch (Exception ex) {
				Utility.sendExceptionEmail('WorkdayService', ex);				
			}

		} else if('UserCustomFieldSync'.equalsIgnoreCase(batchType)){
				UserCustomFieldSync((List<People__c>)objects);
		}
		
		 else {
			syncFromSfdc((List<User>)objects);
		}
	}
	
	private Void UserCustomFieldSync(List<People__c> objects){
		List<People__c> listOfPeopleToBeUpdated = new List<People__c>(); 
		consolidatedListOfUserIds = new List<String>();
		Schema.SobjectField theField ;
		Schema.SobjectField lastModifiedDateField ;
		Boolean updatePeopleRecord  ;
		String namespacePrefix = SimpplrContext.NamespacePrefix ; 
		List<Schema.SObjectField> listOfFieldsToBeModified=new List<Schema.SObjectField>();
		lastModifiedDateField = Schema.getGlobalDescribe().get(namespacePrefix + 'people__c').getDescribe().fields.getMap().get(namespacePrefix + 'Last_Edited_DateTime__c');
		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(namespacePrefix + 'people__c').getDescribe().fields.getMap();
		for(People__c peopleObj : objects){
			updatePeopleRecord = false ;

			for(String fieldName :userToPeopleFieldMap.keyset()){			
				String [] fieldArray = fieldName.split('\\.');
				String userFieldValue = String.valueOf(peopleObj.getSObject(fieldArray[0]).get(fieldArray[1]));
				if(String.isNotBlank(userFieldValue)) {
					if(!userFieldValue.equalsIgnoreCase(String.valueof(peopleObj.get(userToPeopleFieldMap.get(fieldName))))){
						updatePeopleRecord = true ;
						peopleObj.put(namespacePrefix + userToPeopleFieldMap.get(fieldName),userFieldValue);
						peopleObj.Last_Edited_DateTime__c = DateTime.now();
						theField = fieldMap.get(namespacePrefix + userToPeopleFieldMap.get(fieldName));
						listOfFieldsToBeModified.add(theField);
					}
				} else if(String.isNotBlank(String.valueof(peopleObj.get(userToPeopleFieldMap.get(fieldName))))) {
					updatePeopleRecord = true ;
					peopleObj.put(namespacePrefix + userToPeopleFieldMap.get(fieldName), null);
					peopleObj.Last_Edited_DateTime__c = DateTime.now();
					theField = fieldMap.get(namespacePrefix + userToPeopleFieldMap.get(fieldName));
					listOfFieldsToBeModified.add(theField);
				}
			}
			if(updatePeopleRecord == true){			
			  listOfPeopleToBeUpdated.add(peopleObj) ;
			  listOfFieldsToBeModified.add(lastModifiedDateField) ;
			}
		}
		if(listOfPeopleToBeUpdated.size()>0){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(listOfPeopleToBeUpdated),listOfFieldsToBeModified);
		}	
	}
	private void syncFromWorkday(String workdayUrl) {
		hasMore = false;
		workdayUrl = workdayUrl.removeEndIgnoreCase('?usePassthrough=1');
		workdayUrl = workdayUrl.removeEndIgnoreCase('&usePassthrough=1');    
		Boolean hasRequestParams = false;
		if(workdayUrl.contains('?')) {
			hasRequestParams = true;
		}
		WorkdayService ws = new WorkdayService();
		String effectiveDate = ws.formatDate(Date.today());
		if(workdayUrl.containsIgnoreCase('@today@')) {
			workdayUrl = workdayUrl.replace('@today@', effectiveDate);
		}
		workdayUrl += (hasRequestParams ? '&' : '?') + EncodingUtil.urlEncode('format', 'UTF-8') + '=' + EncodingUtil.urlEncode('json', 'UTF-8');
		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		Blob cipherText = EncodingUtil.base64Decode(SimpplrContext.PDSWorkdayPassword);
		String password = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();
		String userName = SimpplrContext.PDSWorkdayUsername;
		Blob headerValue = Blob.valueOf(userName + ':' + password);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		String orgId = SimpplrContext.simpplrOrgId;
		String dri = Utility.requestAdoptionDataAuthToken();
		String url  = 'https://services.simpplr.com/workday/get-user-data.php';
		String jsonBody = '{"page_number":'+pageNumber+',"url":"'+workdayUrl+'","org_id":"'+orgId+'","auth_header":"'+authorizationHeader+'","dri":"'+dri+'"}';
		HttpResponse res = Utility.getJsonResponseFromExternalSystem('POST',url,authorizationHeader,jsonBody,new Map<String,String>());
		if(res.getStatusCode()==200){
			Map<String, Object> resultObj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
			if(resultObj.get('status') != null && 'success'.equalsIgnoreCase((String) resultObj.get('status'))){
				hasMore = resultObj.get('hasMore') != null ? ((Boolean) resultObj.get('hasMore')) : false;
				List<Map<String, Object>> workDayUserMapList = new List<Map<String, Object>>();
				List<Object> objList = null;
				if(resultObj.get('Report_Entry') != null){
					objList = (List<Object>) resultObj.get('Report_Entry');
					for(Object obj : objList){
						workDayUserMapList.add((Map<String, Object>) obj);
					}
				}
				if(workDayUserMapList != null && workDayUserMapList.size() > 0){
					if(SimpplrContext.isPDSEmployeeNumber){
						ws.updatePeopleEmployeeNumber(workDayUserMapList);   
					}
					isRerunRequired = ws.updatePeopleFromWorkdayData(workDayUserMapList) || isRerunRequired;
				}
			}
		} else {
			throw new SimpplrException('BatchSfdcUserDataSync.syncFromWorkday()----Unable to pull records from Workday, received Status Code: ' + res.getStatusCode() + ', Status: ' + res.getStatus() + ', Body: ' + res.getBody());
		}
	}
	private void syncFromSfdc(List<User> listOfFetchedUsers) {
		
		Map<String,String> mapOfUserAndPrefId= new Map<String,String>();
		List<People__c> listOfPeopleToBeUpdated = new List<People__c> ();
		List<Schema.SObjectField> listOfFieldsToBeModified=new List<Schema.SObjectField>();
		try{
			Map<String, SObjectField> peopleFieldMap = People__c.getSObjectType().getDescribe().fields.getMap();
			Boolean useCustomFields = SimpplrContext.isFeatureEnabled('Full_External_Search');
			for(User userObj : listOfFetchedUsers){
				// Skip records which are not present in People Object
				if(userObj.Parent_User__r.isEmpty()) {
					continue;
				}
				listOfFieldsToBeModified=new List<Schema.SObjectField>();
				People__c peopleObj=new People__c();
				peopleObj.id = userObj.Parent_User__r[0].id;
					if(SimpplrContext.isPDSAboutMe){
					
					peopleObj.About__c = useCustomFields ? userObj.AboutMe__c : userObj.AboutMe;
					
					listOfFieldsToBeModified.add(People__c.About__c);
				}
				if(SimpplrContext.isPDSCity){
					peopleObj.City__c = useCustomFields ? userObj.City__c : userObj.City;
					listOfFieldsToBeModified.add(People__c.City__c);
				}
				try {
					if(SimpplrContext.isPDSJoiningDate && joiningDateExistBool){
                        peopleObj.Joining_Date__c = Date.valueOf(userObj.get('Joining_Date__c'));
                        listOfFieldsToBeModified.add(People__c.Joining_Date__c);
					}
					
					if(SimpplrContext.isPDSBirthDate && birthDateExistBool){
						peopleObj.Birth_Date__c=Date.valueOf(userObj.get('Birth_Date__c'));
						listOfFieldsToBeModified.add(People__c.Birth_Date__c);
					}
				} catch (Exception e) {
					// ignoring Exception here
				}
				
				if(SimpplrContext.isPDSCommunityNickname){
					peopleObj.Community_Nickname__c = useCustomFields ? userObj.CommunityNickname__c : userObj.CommunityNickname;
					listOfFieldsToBeModified.add(People__c.Community_Nickname__c);
				}
				if(SimpplrContext.isPDSCompanyName){
					peopleObj.Company_Name__c = useCustomFields ? userObj.CompanyName__c : userObj.CompanyName;
					listOfFieldsToBeModified.add(People__c.Company_Name__c);
				}
				if(SimpplrContext.isPDSCountry){
					peopleObj.Country__c = useCustomFields ? userObj.Country__c : userObj.Country;
					listOfFieldsToBeModified.add(People__c.Country__c);
				}
				if(SimpplrContext.isPDSDepartment){
					peopleObj.Department__c = useCustomFields ?  userObj.Department__c : userObj.Department;
					listOfFieldsToBeModified.add(People__c.Department__c);
				}
				if(SimpplrContext.isPDSDivision){
					peopleObj.Division__c = useCustomFields ? userObj.Division__c : userObj.Division;
					listOfFieldsToBeModified.add(People__c.Division__c);
				}
				if(SimpplrContext.isPDSEmployeeNumber){
					peopleObj.Employee_Number__c = useCustomFields ? userObj.EmployeeNumber__c : userObj.EmployeeNumber;
					listOfFieldsToBeModified.add(People__c.Employee_Number__c);
				}
				if(SimpplrContext.isPDSExtension){
					peopleObj.Extension__c = useCustomFields ? userObj.Extension__c : userObj.Extension;
					listOfFieldsToBeModified.add(People__c.Extension__c);
				}
				if(SimpplrContext.isPDSFax){
					peopleObj.Fax__c = useCustomFields ? userObj.Fax__c : userObj.Fax;
					listOfFieldsToBeModified.add(People__c.Fax__c);
				}
				if(SimpplrContext.isPDSFirstName){
					peopleObj.First_Name__c =  useCustomFields ? userObj.FirstName__c : userObj.FirstName;
					listOfFieldsToBeModified.add(People__c.First_Name__c);
				}
				if(SimpplrContext.isPDSLastName){
					peopleObj.Last_Name__c = useCustomFields ? userObj.LastName__c : userObj.LastName;
					listOfFieldsToBeModified.add(People__c.Last_Name__c);
				}
				if(SimpplrContext.isPDSManagerId) {
					consolidatedListOfUserIds.add(userObj.Id);
				}
				if(SimpplrContext.isPDSMobilePhone){
					peopleObj.Mobile_Phone__c = useCustomFields ? userObj.MobilePhone__c : userObj.MobilePhone;
					listOfFieldsToBeModified.add(People__c.Mobile_Phone__c);
				}
				if(SimpplrContext.isPDSPhone){
					peopleObj.Phone__c = useCustomFields ? userObj.Phone__c : userObj.Phone;
					listOfFieldsToBeModified.add(People__c.Phone__c);
				}
				if(SimpplrContext.isPDSPostalCode){
					peopleObj.Postal_Code__c = useCustomFields ? userObj.PostalCode__c : userObj.PostalCode;
					listOfFieldsToBeModified.add(People__c.Postal_Code__c);
				}
				if(SimpplrContext.isPDSState){
					peopleObj.State__c = useCustomFields ? userObj.State__c : userObj.State;
					listOfFieldsToBeModified.add(People__c.State__c);
				}
				if(SimpplrContext.isPDSStreet){
					peopleObj.Street__c = useCustomFields ? userObj.Street__c : userObj.Street;
					listOfFieldsToBeModified.add(People__c.Street__c);
				}
				if(SimpplrContext.isPDSTitle){
					peopleObj.Title__c = useCustomFields ? userObj.Title__c : userObj.Title;
					listOfFieldsToBeModified.add(People__c.Title__c);
				}
				if(SimpplrContext.isPDSEmail){
					peopleObj.Email__c = useCustomFields ? userObj.Email__c : userObj.Email;
					listOfFieldsToBeModified.add(People__c.Email__c);
				}
				
				// Sync custom fields
				for(String columnName : customFieldsNameLabelMap.keySet()){
					peopleObj.put((SimpplrContext.namespacePrefix + columnName), String.valueOf(userObj.get(customFieldsNameLabelMap.get(columnName))));

					listOfFieldsToBeModified.add(peopleFieldMap.get((SimpplrContext.namespacePrefix + columnName)));
				}

				peopleObj.User__c=userObj.id;
				peopleObj.Last_Edited_DateTime__c = DateTime.now();
				listOfFieldsToBeModified.add(People__c.User__c);
				listOfFieldsToBeModified.add(People__c.Last_Edited_DateTime__c);
				listOfPeopleToBeUpdated.add(peopleObj);
			}
			if(listOfPeopleToBeUpdated.size() > 0){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		   		SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(listOfPeopleToBeUpdated),listOfFieldsToBeModified);
		    
		    	
			}
			
		} catch(Exception ex) {
    		String mailSubject='BatchSfdcUserDataSync batch failed';
    		
			String mailBodyHtml='Dear User'+ ', <br/><br/> BatchSfdcUserDataSync batch has failed due to following reasons:';
			mailBodyHtml+=' <br/>Error Message - ' + ex.getMessage(); 
			mailBodyHtml+=' <br/>Line Number - ' + ex.getLineNumber();
			mailBodyHtml+=' <br/>Error cause - ' + ex.getCause(); 
			mailBodyHtml+=' <br/>Error stack trace - ' + ex.getStackTraceString();
			mailBodyHtml+=' <br/>Exception Type Name - ' + ex.getTypeName();
			mailBodyHtml+=' <br/>Org Info - ' + UserContext.id + '/' + UserInfo.getOrganizationId();
			mailBodyHtml+=' <br/> <br/> Thanks.!';
			
			EmailUtility emailUtilObj=new EmailUtility();
			emailUtilObj.sendMailToCurrentUser(mailSubject,mailBodyHtml);
			throw ex;
    	}
	}
	
	public void finish(Database.BatchableContext bc){

		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email,
                                     ExtendedStatus, ApexClassId from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		Boolean canRerunFailedBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		}

		if('Salesforce'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication) && String.isBlank(batchType)){
			
			// create logs for this batch job
			ManageApplicationDao.logUserSyncProvStatus(canStartNextBatch ? 'successful' : 'failed', 'User Sync salesforce');

		}

		if('WorkdaySync'.equalsIgnoreCase(batchType)) {
			if(hasMore ==  true){
	            DataBase.executeBatch(new BatchSfdcUserDataSync(++pageNumber, maxRepetetionAllowed));
	        } else if(SimpplrContext.isPDSEmployeeNumber && isRerunRequired == true && maxRepetetionAllowed > 0){
	            DataBase.executeBatch(new BatchSfdcUserDataSync(0, --maxRepetetionAllowed));
	        } else {
				if(!Test.isRunningTest()) {
					// Added to execute nigthly jobs sequentially
					SchedulerSimpplrServices.executeNextJob('peopleSync');	
				}
			}
			
		} else if('WorkdaySyncFromServiceClass'.equalsIgnoreCase(batchType)) {
			
			if(!Test.isRunningTest()) {
				// Added to execute nigthly jobs sequentially
				SchedulerSimpplrServices.executeNextJob('peopleSync');
			}			

		} else if('UserCustomFieldSync'.equalsIgnoreCase(batchType)) {
			
			if(!Test.isRunningTest()) {
				// Added to execute nigthly jobs sequentially
				SchedulerSimpplrServices.executeNextJob('UserCustomFieldSync');
			}

		} else if(!consolidatedListOfUserIds.isEmpty()) {
    		List<String> listOfUserIds = consolidatedListOfUserIds;
	        BatchUpdateManagerInPeopleRecords job = new BatchUpdateManagerInPeopleRecords(listOfUserIds);
	        Database.executeBatch(job, 1000); 
    	} else {
			if(!Test.isRunningTest()) {
				// Added to execute nigthly jobs sequentially
				SchedulerSimpplrServices.executeNextJob('peopleSync');
			}
		}
	}
}