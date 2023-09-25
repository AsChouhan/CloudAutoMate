public with sharing class BatchGoogleUserSync implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
	private Exception exceptionDetailsObj;
    private String GOOGLE_API_GET_GSUITE_USERS = SimpplrContext.simpplrAPIEndpoint + '/gsuite/user-manager?action=getgsuiteusers';
    private String clientId = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID;
    private String secretId = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_SECRET;
    private Boolean isFederationID;
    private Datetime lastSyncDateTime;
    private String queryFilter;
    private App_Config__c appConfig;
    private String nextPageToken;
    private String maxResults = '50';
    private Map<String, String> emailVsManagerPeopleIdMap;
    private String batchType;
    private Map<String, String> customFieldMap = null;
    private Boolean isCalledFromScheduler = false;	
    
    
    public BatchGoogleUserSync() {
    }

    public BatchGoogleUserSync(String batchType) {
        this.batchType = batchType;
    }

    /**
     * @description - constructor which is called from SchedulerSimpplrServices
     * @param - String batchType
     * @param - Boolean isCalledFromScheduler
     */
    public BatchGoogleUserSync(String batchType, Boolean isCalledFromScheduler) {
        this.batchType = batchType;
        this.isCalledFromScheduler = true;
    }    

    public BatchGoogleUserSync(String batchType, String nextPageToken, Datetime lastSyncDateTime) {
        this.batchType = batchType;
        this.nextPageToken = nextPageToken;
        this.lastSyncDateTime = lastSyncDateTime;
    }

    public database.querylocator start(Database.BatchableContext bc){
	 	String query = null;
	 	
        if('CleanSyncField'.equalsIgnoreCase(batchType)) {
            query = ' Select id, Sync_Field__c from People__c ' +
                    ' where user__r.isActive=true And Sync_Field__c != null ';
                    
        } else if('userSync'.equalsIgnoreCase(batchType)) {
            query = ' SELECT Id, PDS_Source_Application__c, '
                    + ' PDS_First_Name__c, PDS_Last_Name__c, PDS_Title__c, PDS_Email__c, PDS_Manager_Id__c, PDS_Department__c, '
                    + ' PDS_Company_Name__c, PDS_Fax__c, PDS_Street__c, PDS_Postal_Code__c, PDS_City__c, PDS_State__c, PDS_Country__c, '
                    + ' PDS_Phone__c, PDS_Mobile_Phone__c, PDS_Federation_Id__c, PDS_Birth_Date__c, PDS_Joining_Date__c, '
                    + ' PDS_Street_Key__c, PDS_City_Key__c, PDS_State_Key__c, PDS_Country_Key__c, PDS_Postal_Code_Key__c, '
                    + ' PDS_Joining_Date_Key__c, PDS_Birth_Date_Key__c, PDS_Company_Name_Key__c, PDS_Query_Filter__c '
                    + ' FROM App_Config__c LIMIT 1';

        }

    	return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
            if('CleanSyncField'.equalsIgnoreCase(batchType)) {
                cleanSyncFieldInPeople((List<People__c>)listOfsObject);


            } else if('userSync'.equalsIgnoreCase(batchType)) {
                this.appConfig = ((List<App_Config__c>) listOfsObject)[0];
                this.syncUsers();

            }
		} catch(Exception ex) {
			exceptionDetailsObj = ex;
    		throw ex;
    	}
    }

    private void cleanSyncFieldInPeople(List<People__c> peopleList) {
        for(People__c peopleObj:peopleList) {
            peopleObj.Sync_Field__c = null;
        }
        update peopleList;
    }

    public void finish(Database.BatchableContext bc){
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;

		} else {
			Utility.sendBatchFailedExceptionEmail('BatchGoogleUserSync.' + batchType, exceptionDetailsObj);
		}

        if(canStartNextBatch){
            if('userSync'.equalsIgnoreCase(batchType)) {        
                
                if(String.isNotBlank(this.nextPageToken)){

                    BatchGoogleUserSync job = new BatchGoogleUserSync(this.batchType, this.nextPageToken, this.lastSyncDateTime);
                    Database.executeBatch(job, 1);

                } else {
                    // Do Nothing
                    
                    // create logs for this batch job
                    ManageApplicationDao.logUserSyncProvStatus('successful', 'User Sync google');

                    if(isCalledFromScheduler) {
                        // Added to execute nigthly jobs sequentially
                        SchedulerSimpplrServices.executeNextJob('peopleSync'); 
                    }                    
                } 
                
            }
        } else {

            // create logs for this batch job
            ManageApplicationDao.logUserSyncProvStatus('failed', 'User Sync google');

            if(isCalledFromScheduler) {
                // Added to execute nigthly jobs sequentially
                SchedulerSimpplrServices.executeNextJob('peopleSync');  
            }           
        }
    }

    // Sync google users
    private void syncUsers(){
        // Initialize config attrs
        this.initConfig();
        // Get users from google API and finally sync
        this.getUsersFromGoogle();

    }

    private void getUsersFromGoogle(){
        Map<String, String> reqParamMap = new Map<String, String>();
        reqParamMap.put('orgId', SimpplrContext.simpplrOrgId);
        reqParamMap.put('maxResults', maxResults);

        if(String.isNotBlank(this.nextPageToken)){
            reqParamMap.put('pageToken', this.nextPageToken);

            this.nextPageToken = null;
        }    
        if(String.isNotBlank(this.queryFilter)){
            reqParamMap.put('queryFilter', this.queryFilter);
        }

        List<String> maskList = new List<String>();
        // Pull custom schema if needed
        if(this.appConfig.PDS_Birth_Date__c && String.isNotBlank(this.appConfig.PDS_Birth_Date_Key__c)){

            maskList.add(this.appConfig.PDS_Birth_Date_Key__c.split('\\.')[0]);
        }
        if(this.appConfig.PDS_Joining_Date__c && String.isNotBlank(this.appConfig.PDS_Joining_Date_Key__c)){

            maskList.add(this.appConfig.PDS_Joining_Date_Key__c.split('\\.')[0]);
        }
        if(this.appConfig.PDS_Company_Name__c && String.isNotBlank(this.appConfig.PDS_Company_Name_Key__c)){

            maskList.add(this.appConfig.PDS_Company_Name_Key__c.split('\\.')[0]);
        }
        if(this.appConfig.PDS_Street__c && String.isNotBlank(this.appConfig.PDS_Street_Key__c)){

            maskList.add(this.appConfig.PDS_Street_Key__c.split('\\.')[0]);
        }
        if(this.appConfig.PDS_City__c && String.isNotBlank(this.appConfig.PDS_City_Key__c)){

            maskList.add(this.appConfig.PDS_City_Key__c.split('\\.')[0]);
        }
        if(this.appConfig.PDS_State__c && String.isNotBlank(this.appConfig.PDS_State_Key__c)){

            maskList.add(this.appConfig.PDS_State_Key__c.split('\\.')[0]);
        }
        if(this.appConfig.PDS_Country__c && String.isNotBlank(this.appConfig.PDS_Country_Key__c)){

            maskList.add(this.appConfig.PDS_Country_Key__c.split('\\.')[0]);
        }
        if(this.appConfig.PDS_Postal_Code__c && String.isNotBlank(this.appConfig.PDS_Postal_Code_Key__c)){

            maskList.add(this.appConfig.PDS_Postal_Code_Key__c.split('\\.')[0]);
        }
        if(customFieldMap != null && customFieldMap.isEmpty() == false) {
            for(String fieldName : customFieldMap.values()){

                maskList.add(fieldName.split('\\.')[0]);
            }
        }
        reqParamMap.put('maskList', JSON.serialize(maskList));

        HttpResponse httpResponseObj = Utility.getResponseFromAWS(GOOGLE_API_GET_GSUITE_USERS, reqParamMap);

        if(httpresponseObj.getStatusCode() == 200){
            String bodyStr = httpresponseObj.getBody();

            if(String.isNotBlank(bodyStr)){
                Map<String, Object> resultBodyMap = ((Map<String, Object>) JSON.deserializeUntyped(bodyStr));
                Map<String, Object> resultMap = (Map<String, Object>) resultBodyMap.get('result');

                if(resultMap.get('nextPageToken') != null){
                    this.nextPageToken = (String) resultMap.get('nextPageToken');
                }

                // Process users records to create/update/delete
                this.processRecords((List<Object>) resultMap.get('users'));
            }
        }
    }

    private void processRecords(List<Object> userObjects){
        if(this.lastSyncDateTime == null){
            this.lastSyncDateTime = Datetime.now();    
        }

        Map<String, Object> usermap = null;

        // Email set from google API
        Set<String> userEmailSet = new Set<String>();
        Set<String> googleManagerEmailSet = new Set<String>();
        for(Object userObj : userObjects){
            usermap = (Map<String, Object>) userObj;
            if(userMap.get('primaryEmail') != null){
                userEmailSet.add(((String) usermap.get('primaryEmail')).toLowerCase());
            }
            // Prepare email set for managers
            if(this.appConfig.PDS_Manager_Id__c){
                 if(userMap.get('relations') != null){
                    List<Object> realtionList = (List<Object>) userMap.get('relations'); 
                    for(Object relationObj : realtionList){
                        Map<String, Object> relationMap = (Map<String, Object>) relationObj;
                        if(relationMap.get('type') != null && 'manager'.equalsIgnoreCase((String) relationMap.get('type'))){
                            if(relationMap.get('value') != null){
                                googleManagerEmailSet.add((String) relationMap.get('value'));
                            }

                            break;
                        }
                    }
                }
            }
        }
        List<People__c> managerList = [SELECT Id, Email__c
                                        FROM People__c
                                        WHERE Email__c IN :googleManagerEmailSet 
                                        AND User__r.UserType = 'Standard'];

        // email vs manager user id mapping
        this.emailVsManagerPeopleIdMap = new Map<String, String>();
        
        for(People__c peopleObj : managerList){
            this.emailVsManagerPeopleIdMap.put((peopleObj.Email__c).toLowerCase(), peopleObj.Id);
        }                                    

        String peopleQuery = 'SELECT Id, User__c, First_Name__c, Last_Name__c, Title__c,  '
                                        + ' Manager__c, Department__c, Company_Name__c, Street__c,'
                                        + ' Postal_Code__c, City__c, State__c, Country__c, Phone__c, Mobile_Phone__c, '
                                        + ' Employee_Number__c, Sync_Field__c, User__r.IsActive, '
                                        + ' Raw_City__c, Raw_Country__c, Raw_State__c, Location_Normalization_Status__c, '
                                        + ' Last_Sync_DateTime__c, Email__c, Fax__c, Birth_Date__c, Joining_Date__c, '
                                        + ' Custom_Field_1__c, Custom_Field_2__c, Custom_Field_3__c, Custom_Field_4__c, Custom_Field_5__c, '
                                        + ' Custom_Field_6__c, Custom_Field_7__c, Custom_Field_8__c, Custom_Field_9__c, Custom_Field_10__c, '
                                        + ' Custom_Field_11__c, Custom_Field_12__c, Custom_Field_13__c, Custom_Field_14__c, Custom_Field_15__c, '
                                        + ' Custom_Field_16__c, Custom_Field_17__c, Custom_Field_18__c, Custom_Field_19__c, Custom_Field_20__c, '
                                        + ' Custom_Field_21__c, Custom_Field_22__c, Custom_Field_23__c, Custom_Field_24__c, Custom_Field_25__c '
                                        + ' FROM People__c WHERE User__r.UserType = \'Standard\' AND User__r.Sync_Whitelisted__c = false ';

        peopleQuery += ' AND Email__c IN :userEmailSet ';

        List<People__c> peopleList = (List<People__c>) Database.query(peopleQuery);

        Map<String, People__c> syncIdentifierVsPeopleObjMap = new Map<String, People__c>();
        for(People__c peopleObj : peopleList){
            syncIdentifierVsPeopleObjMap.put(peopleObj.Email__c, peopleObj);
        }

        String primaryEmail = null;
        for(Object userObj : userObjects){
            usermap = (Map<String, Object>) userObj;
            if(userMap.get('primaryEmail') != null){
                primaryEmail = ((String) usermap.get('primaryEmail')).toLowerCase();
            }
            People__c peopleObj = null;
            if(syncIdentifierVsPeopleObjMap.get(primaryEmail) != null){
                peopleObj = syncIdentifierVsPeopleObjMap.get(primaryEmail);
                this.updatePeopleFields(peopleObj, usermap);

            }
        }   
        List<People__c> peopleListFinal = syncIdentifierVsPeopleObjMap.values();
        // Update people Object
        if(!peopleListFinal.isEmpty()){
            update peopleListFinal;
        }
    }

    private void updatePeopleFields(People__c peopleObj,  Map<String, Object> userMap){
		
        // update last sync date time
        peopleObj.Last_Sync_DateTime__c = Datetime.now();
        
        // Update sync identifier 
        if(usermap.get('primaryEmail') != null){

            peopleObj.Sync_Field__c = (String) usermap.get('primaryEmail');
        }
        
        if(this.appConfig.PDS_First_Name__c){
            
            peopleObj.First_Name__c = this.getFirstName(userMap);
		}
		if(this.appConfig.PDS_Last_Name__c){

            peopleObj.Last_Name__c = this.getLastName(userMap); 
		}
        // Update Organization
        if(this.appConfig.PDS_Title__c){

            peopleObj.Title__c = this.getTitle(userMap);
        }
        if(this.appConfig.PDS_Department__c){

            peopleObj.Department__c = this.getDepartment(userMap);
        }
        if(this.appConfig.PDS_Company_Name__c){

            if(String.isNotBlank(this.appConfig.PDS_Company_Name_Key__c)){

                peopleObj.Company_Name__c = this.getCompanyNameFromCustomField(userMap);
            } else {

                peopleObj.Company_Name__c = this.getCompanyName(userMap);
            }
        } 
		if(this.appConfig.PDS_Email__c){
            
            peopleObj.Email__c = this.getEmail(userMap);
		}
        // Update Address
        if(this.appConfig.PDS_Street__c){
            if(String.isNotBlank(this.appConfig.PDS_Street_Key__c)){

                peopleObj.Street__c = this.getStreetFromCustomField(userMap);
            } else {

                peopleObj.Street__c = this.getStreet(userMap);
            }
        }
        if(this.appConfig.PDS_Postal_Code__c){
            if(String.isNotBlank(this.appConfig.PDS_Postal_Code_Key__c)){

                peopleObj.Postal_Code__c = this.getPostalCodeFromCustomField(userMap);
            } else {

                peopleObj.Postal_Code__c = this.getPostalCode(userMap);
            }
        }
        if(this.appConfig.PDS_City__c){
            if(String.isNotBlank(this.appConfig.PDS_City_Key__c)){

                peopleObj.City__c = this.getCityFromCustomField(userMap);
            } else {

                peopleObj.City__c = this.getCity(userMap);
            }
        }
        if(this.appConfig.PDS_State__c){
            if(String.isNotBlank(this.appConfig.PDS_State_Key__c)){

                peopleObj.State__c = this.getStateFromCustomField(userMap);
            } else {

                peopleObj.State__c = this.getState(userMap);
            }
        }
        if(this.appConfig.PDS_Country__c){
            if(String.isNotBlank(this.appConfig.PDS_Country_Key__c)){

                peopleObj.Country__c = this.getCountryFromCustomField(userMap);
            } else {

                peopleObj.Country__c = this.getCountry(userMap);
            }
    }
		if(this.appConfig.PDS_Phone__c){

            peopleObj.Phone__c = this.getPhone(userMap);
		}
		if(this.appConfig.PDS_Mobile_Phone__c){

            peopleObj.Mobile_Phone__c = this.getMobilePhone(userMap);
		}
		if(this.appConfig.PDS_Fax__c){

            peopleObj.Fax__c = this.getFax(userMap);
		}
		if(this.appConfig.PDS_Manager_Id__c){

            peopleObj.Manager__c = this.getManager(userMap, emailVsManagerPeopleIdMap);
		}
		if(this.appConfig.PDS_Birth_Date__c){
            if(String.isNotBlank(this.appConfig.PDS_Birth_Date_Key__c)){

                String birthDateStr = this.getBirthDate(userMap);
                peopleObj.Birth_Date__c = String.isNotBlank(birthDateStr) ? convertStringToDate(birthDateStr, true) : null;
            } else {

                peopleObj.Birth_Date__c = null;
            }
            
		}
		if(this.appConfig.PDS_Joining_Date__c){
            if(String.isNotBlank(this.appConfig.PDS_Joining_Date_Key__c)){

                String joinDateStr = this.getJoiningDate(userMap);
                peopleObj.Joining_Date__c = String.isNotBlank(joinDateStr) ? convertStringToDate(joinDateStr, false) : null;
            } else {

                peopleObj.Joining_Date__c = null;
            }
            
		}
		if(this.appConfig.PDS_Fax__c){

            peopleObj.Fax__c = this.getFax(userMap);
		}

        // custom Fields
        String customFieldName = null;
        if(customFieldMap != null) {
            for(String peopleFieldApiName : customFieldMap.keySet()) { 
                if(customFieldMap.get(peopleFieldApiName) != null) {
                    customFieldName = (String) customFieldMap.get(peopleFieldApiName);
                    peopleObj.put(SimpplrContext.namespacePrefix + peopleFieldApiName, this.getCustomField(userMap, customFieldName));
                }
            }
        }
        
        
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

    private String getCustomField(Map<String, Object> userMap, String customField){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> customFieldList = customField.split('\\.');
                String key = customFieldList[0];
                String customKey = customFieldList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                if (customSchemaKeyMap != null && customSchemaKeyMap.containsKey(customKey)) {
                    if(customSchemaKeyMap.get(customKey) != null){

                        field = (String) customSchemaKeyMap.get(customKey);
                    }
                }
            }
        }
        return field;
    }

    private String getBirthDate(Map<String, Object> userMap){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> birthdayKeysList = this.appConfig.PDS_Birth_Date_Key__c.split('\\.');
                String key = birthdayKeysList[0];
                String birthdaykey = birthdayKeysList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                if (customSchemaKeyMap != null && customSchemaKeyMap.containsKey(birthdaykey)) {
                    if(customSchemaKeyMap.get(birthdaykey) != null){

                        field = (String) customSchemaKeyMap.get(birthdaykey);
                    }
                }
            }
        }
        return field;
    }

    private String getJoiningDate(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){
                List<String> joindateKeysList = this.appConfig.PDS_Joining_Date_Key__c.split('\\.');
                String key = joindateKeysList[0];
                String joiningDatekey = joindateKeysList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                if (customSchemaKeyMap != null && customSchemaKeyMap.containsKey(joiningDatekey)) {
                    if(customSchemaKeyMap.get(joiningDatekey) != null){
                        field = (String) customSchemaKeyMap.get(joiningDatekey);
                    }
                }
            }
        }
        return field;
    }

    private String getFirstName(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('name') != null){
            if(((Map<String, Object>) userMap.get('name')).get('givenName') != null){
                field = (String) ((Map<String, Object>) userMap.get('name')).get('givenName');

            }
        }
        return field;
    }

    private String getLastName(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('name') != null){
            if(((Map<String, Object>) userMap.get('name')).get('familyName') != null){
                field = (String) ((Map<String, Object>) userMap.get('name')).get('familyName');

            }
        }
        return field;
    }

    private String getTitle(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('organizations') != null){

                List<Object> orgObjList = (List<Object>) userMap.get('organizations');
                Map<String, Object> org = null;
                for(Object orgObj : orgObjList){

                    org = (Map<String, Object>) orgObj;
                    if(org.get('primary') != null && (Boolean) org.get('primary') == true){
                        
                        if(org.get('title') != null){
                            field = (String) org.get('title');
                        }

                        break;
                    }
                }
                
                if(field == null && !orgObjList.isEmpty() && orgObjList.size() > 0) {
                    org = (Map<String, Object>) orgObjList[0];
                    if(org.get('title') != null){
                        field = (String) org.get('title');
                    }
                }
            }
        return field;
    }

    private String getDepartment(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('organizations') != null){
                List<Object> orgObjList = (List<Object>) userMap.get('organizations');
                Map<String, Object> org = null;
                for(Object orgObj : orgObjList){

                    org = (Map<String, Object>) orgObj;
                    if(org.get('primary') != null && (Boolean) org.get('primary') == true){
                        
                        if(org.get('department') != null){
                            field = (String) org.get('department');
                        }

                        break;
                    }
                }

                if(field == null && !orgObjList.isEmpty() && orgObjList.size() > 0) {
                    org = (Map<String, Object>) orgObjList[0];
                    if(org.get('department') != null){
                        field = (String) org.get('department');
                    }
                }
            }
        return field;
    }

    private String getCompanyName(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('organizations') != null){
                List<Object> orgObjList = (List<Object>) userMap.get('organizations');
                Map<String, Object> org = null;
                for(Object orgObj : orgObjList){

                    org = (Map<String, Object>) orgObj;
                    if(org.get('primary') != null && (Boolean) org.get('primary') == true){
                        
                        if(org.get('name') != null){
                            field = (String) org.get('name');
                        }

                        break;
                    }
                }

                if(field == null && !orgObjList.isEmpty() && orgObjList.size() > 0) {
                    org = (Map<String, Object>) orgObjList[0];
                    if(org.get('name') != null){
                        field = (String) org.get('name');
                    }
                }
            }
        return field;
    }

    private String getCompanyNameFromCustomField(Map<String, Object> userMap){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> companyKeysList = this.appConfig.PDS_Company_Name_Key__c.split('\\.');
                String key = companyKeysList[0];
                String companykey = companyKeysList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                if (customSchemaKeyMap != null && customSchemaKeyMap.containsKey(companykey)) {
                    if(customSchemaKeyMap.get(companykey) != null){

                        field = (String) customSchemaKeyMap.get(companykey);
                    }
                }
            }
        }
        return field;
    }

    private String getEmail(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('primaryEmail') != null){
            field = ((String) userMap.get('primaryEmail')).toLowerCase();

        }
        return field;
    }

    private String getStreet(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('addresses') != null){
            List<Object> adressList = (List<Object>) userMap.get('addresses');
            Map<String, Object> adress = null;
            for(Object adressObj : adressList){

                adress = (Map<String, Object>) adressObj;
                if(adress.get('type') != null && 'work'.equalsIgnoreCase((String) adress.get('type'))){
                    
                    if(adress.get('streetAddress') != null){
                        field = (String) adress.get('streetAddress');
                    }
                    
                    break;
                }
            }
        }
        return field;
    }

    private String getPostalCode(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('addresses') != null){
            List<Object> adressList = (List<Object>) userMap.get('addresses');
            Map<String, Object> adress = null;
            for(Object adressObj : adressList){

                adress = (Map<String, Object>) adressObj;
                if(adress.get('type') != null && 'work'.equalsIgnoreCase((String) adress.get('type'))){
                    
                    if(adress.get('postalCode') != null){
                        field = (String) adress.get('postalCode');
                    }

                    break;
                }
            }
        }
        return field;
    }

    private String getCity(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('addresses') != null){
            List<Object> adressList = (List<Object>) userMap.get('addresses');
            Map<String, Object> adress = null;
            for(Object adressObj : adressList){

                adress = (Map<String, Object>) adressObj;
                if(adress.get('type') != null && 'work'.equalsIgnoreCase((String) adress.get('type'))){
                    
                    if(adress.get('locality') != null){
                        field = (String) adress.get('locality');
                    }
                    
                    break;
                }
            }
        }
        return field;
    }

    private String getState(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('addresses') != null){
            List<Object> adressList = (List<Object>) userMap.get('addresses');
            Map<String, Object> adress = null;
            for(Object adressObj : adressList){

                adress = (Map<String, Object>) adressObj;
                if(adress.get('type') != null && 'work'.equalsIgnoreCase((String) adress.get('type'))){
                    
                    if(adress.get('region') != null){
                        field = (String) adress.get('region');
                    }
                    
                    break;
                }
            }
        }
        return field;
    }

    private String getCountry(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('addresses') != null){
            List<Object> adressList = (List<Object>) userMap.get('addresses');
            Map<String, Object> adress = null;
            for(Object adressObj : adressList){

                adress = (Map<String, Object>) adressObj;
                if(adress.get('type') != null && 'work'.equalsIgnoreCase((String) adress.get('type'))){
                    
                    if(adress.get('country') != null){
                        field = (String) adress.get('country');
                    }
                    
                    break;
                }
            }
        }
        return field;
    }

    private String getPhone(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('phones') != null){
            List<Object> phoneList = (List<Object>) userMap.get('phones');
            Map<String, Object> phoneMap = null;
            for(Object phoneObj : phoneList){

                phoneMap = (Map<String, Object>) phoneObj;
                if(phoneMap.get('type') != null && 'work'.equalsIgnoreCase((String) phoneMap.get('type'))){
                    if(phoneMap.get('value') != null){
                        field = (String) phoneMap.get('value');
                    }

                    break;
                }
            }
        }
        return field;   
    }

    private String getMobilePhone(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('phones') != null){
            List<Object> phoneList = (List<Object>) userMap.get('phones');
            Map<String, Object> phoneMap = null;
            for(Object phoneObj : phoneList){

                phoneMap = (Map<String, Object>) phoneObj;
                if(phoneMap.get('type') != null && 'mobile'.equalsIgnoreCase((String) phoneMap.get('type'))){
                    if(phoneMap.get('value') != null){
                        field = (String) phoneMap.get('value');
                    }

                    break;
                }
            }
        }
        return field;   
    }

    private String getFax(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('phones') != null){
            List<Object> phoneList = (List<Object>) userMap.get('phones');
            Map<String, Object> phoneMap = null;
            for(Object phoneObj : phoneList){

                phoneMap = (Map<String, Object>) phoneObj;
                if(phoneMap.get('type') != null && 'work_fax'.equalsIgnoreCase((String) phoneMap.get('type'))){
                    if(phoneMap.get('value') != null){
                        field = (String) phoneMap.get('value');
                    }

                    break;
                }
            }
        }
        return field;   
    }

     private String getManager(Map<String, Object> userMap, Map<String, String> managerMap){
        String field = null;
        if(userMap.get('relations') != null){
            List<Object> realtionList = (List<Object>) userMap.get('relations');
            Map<String, Object> relationMap = null;
            for(Object relationObj : realtionList){

                relationMap = (Map<String, Object>) relationObj;
                if(relationMap.get('type') != null && 'manager'.equalsIgnoreCase((String) relationMap.get('type'))){
                    if(relationMap.get('value') != null){
                        field = managerMap.get(((String) relationMap.get('value')).toLowerCase()) != null ? managerMap.get(((String) relationMap.get('value')).toLowerCase()) : null;
                    }

                    break;
                }
            }
        }
        return field;   
    }

    private String getStreetFromCustomField(Map<String, Object> userMap){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> streetKeysList = this.appConfig.PDS_Street_Key__c.split('\\.');
                String key = streetKeysList[0];
                String streetkey = streetKeysList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                field = customSchemaKeyMap != null && customSchemaKeyMap.containsKey(streetkey) && customSchemaKeyMap.get(streetkey) != null ? (String) customSchemaKeyMap.get(streetkey) : null;
            }
        }
        return field;
    }

    private String getCityFromCustomField(Map<String, Object> userMap){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> cityKeysList = this.appConfig.PDS_City_Key__c.split('\\.');
                String key = cityKeysList[0];
                String citykey = cityKeysList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                field = customSchemaKeyMap != null && customSchemaKeyMap.containsKey(citykey) && customSchemaKeyMap.get(citykey) != null ? (String) customSchemaKeyMap.get(citykey) : null;
            }
        }
        return field;
    }

    private String getStateFromCustomField(Map<String, Object> userMap){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> stateKeysList = this.appConfig.PDS_State_Key__c.split('\\.');
                String key = stateKeysList[0];
                String statekey = stateKeysList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                field = customSchemaKeyMap != null && customSchemaKeyMap.containsKey(statekey) && customSchemaKeyMap.get(statekey) != null ? (String) customSchemaKeyMap.get(statekey) : null;
            }
        }
        return field;
    }

    private String getCountryFromCustomField(Map<String, Object> userMap){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> countryKeysList = this.appConfig.PDS_Country_Key__c.split('\\.');
                String key = countryKeysList[0];
                String countrykey = countryKeysList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                field = customSchemaKeyMap != null && customSchemaKeyMap.containsKey(countrykey) && customSchemaKeyMap.get(countrykey) != null ? (String) customSchemaKeyMap.get(countrykey) : null;
            }
        }
        return field;
    }

    private String getPostalCodeFromCustomField(Map<String, Object> userMap){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> postalCodeKeysList = this.appConfig.PDS_Postal_Code_Key__c.split('\\.');
                String key = postalCodeKeysList[0];
                String postalCodekey = postalCodeKeysList[1];
                Map<String, Object> customSchemaKeyMap = (Map<String, Object>) customSchemaMap.get(key);

                field = customSchemaKeyMap != null && customSchemaKeyMap.containsKey(postalCodekey) && customSchemaKeyMap.get(postalCodekey) != null ? String.valueOf(customSchemaKeyMap.get(postalCodekey)) : null;
            }
        }
        return field;
    }

    // Initialize Config variables
    private void initConfig(){

        this.queryFilter = this.appConfig.PDS_Query_Filter__c;

		if(String.isNotBlank(SimpplrContext.PPUserCustomFields)){
            customFieldMap = new Map<String, String>();

			List<CustomProfileField> customFieldList = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);			
			for(CustomProfileField customField : customFieldList){
				if(!'google'.equalsIgnoreCase(customField.syncSource)){
					continue;
				}
				customFieldMap.put(customField.columnName, customField.fieldName);
			}
		}
    }
}