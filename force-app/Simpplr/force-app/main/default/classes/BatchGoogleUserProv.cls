public with sharing class BatchGoogleUserProv implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
	private Exception exceptionDetailsObj;
    private String GOOGLE_API_GET_GSUITE_USERS = SimpplrContext.simpplrAPIEndpoint + '/gsuite/user-manager?action=getgsuiteusers';
    private String clientId = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID;
    private String secretId = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_SECRET;
    private Boolean canCreateUser = false;
    private Boolean canDeactivateUser = false;
    private Boolean isSyncingSourceGoogle = false;
    private Boolean isFederationID;
    private String userProfileId;
    private String timeZoneSidKey;
    private String suffix;
    private String queryFilter;
    private User_Provisioning_Config__c userProvisioningConfig;
    private String nextPageToken;
    private String maxResults = '50';
    private Set<Object> userTobeCreatedSet;
    @TestVisible private Set<String> activateUserIdSet;
    private String batchType;
    private Map<String, String> userEmailVsManagerEmailMap;
    @TestVisible private List<String> existingUserIdList;
    private Set<String> userFields;
    
    public BatchGoogleUserProv() {
    }

    public BatchGoogleUserProv(String batchType) {
        this.batchType = batchType;
    }

    public BatchGoogleUserProv(String batchType, String nextPageToken, List<String> existingUserIdList, Map<String, String> userEmailVsManagerEmailMap) {
        this.batchType = batchType;
        this.nextPageToken = nextPageToken;
        this.existingUserIdList = existingUserIdList;
        this.userEmailVsManagerEmailMap = userEmailVsManagerEmailMap;
        
    } 

    public database.querylocator start(Database.BatchableContext bc){
	 	String query = null;
        Set<String> userEmailIdSet = null;
        
        if('UserProv'.equalsIgnoreCase(batchType)) {
            query = ' SELECT Id, Provisioning_Source__c,'
                        + ' Firstname__c, Lastname__c, User_Title__c, User_Email__c, Manager__c,'
                        + ' Department__c, Company_Name__c, Fax__c, Street__c, PostalCode__c,'
                        + ' Country__c, City__c, State__c, Phone__c, MobilePhone__c,'
                        + ' Birthdate__c, Joining_Date__c, Joining_Date_Field__c,'
                        + ' Birthdate_Field__c, Company_Name_Field__c,'
                        + ' Street_Field__c, City_Field__c, State_Field__c, Country_Field__c, Postal_Code_Field__c, '
                        + ' Create_New_Users__c, Deactive_User__c, FedrationId__c,'
                        + ' Profile_Type__c, TimezoneSidKey__c, Username_Suffix__c, Query_Filter__c'
                        + ' FROM User_Provisioning_Config__c LIMIT 1 ';

        } else if('syncManagers'.equalsIgnoreCase(batchType)){
            userEmailIdSet = userEmailVsManagerEmailMap.keySet();

            query = ' SELECT Id, ManagerId, Email FROM User WHERE Email =:userEmailIdSet ';

        }

    	return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
            if('UserProv'.equalsIgnoreCase(batchType)) {
                this.userProvisioningConfig = ((List<User_Provisioning_Config__c>) listOfsObject)[0];
                this.provUsers();

            } else if('syncManagers'.equalsIgnoreCase(batchType)){
                List<User> userList = (List<User>) listOfsObject;
                this.syncUsersManagers(userList);

            }    
		} catch(Exception ex) {
            // create logs for this batch job
            ManageApplicationDao.logUserSyncProvStatus('failed', 'User Prov google');

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
            // create logs for this batch job
            ManageApplicationDao.logUserSyncProvStatus('failed', 'User Prov google');

			Utility.sendBatchFailedExceptionEmail('BatchGoogleUserProv.' + batchType, exceptionDetailsObj);
		}

        if('UserProv'.equalsIgnoreCase(batchType)) {    
            
            if(this.canCreateUser){
                // Create users
                if(userTobeCreatedSet.isEmpty() == false){
                    createUsers();

                }

                // Activate users and assign licence if, required
                if(this.activateUserIdSet.isEmpty() ==  false){
                    activateUsers(); 
                }
            }

            if(String.isNotBlank(this.nextPageToken)){

                BatchGoogleUserProv job = new BatchGoogleUserProv(this.batchType, this.nextPageToken, this.existingUserIdList, this.userEmailVsManagerEmailMap);
                Database.executeBatch(job, 1);

            } else {
                // Mark unsynced users as Delete
                if(this.canDeactivateUser){
                    deactivateUser();
                }

                // Call batch to sync managers
                if(this.userProvisioningConfig.Manager__c 
                        && this.userEmailVsManagerEmailMap != null 
                        && !this.userEmailVsManagerEmailMap.keySet().isEmpty()){
                    
                    BatchGoogleUserProv job = new BatchGoogleUserProv('syncManagers', null, null, this.userEmailVsManagerEmailMap);
                    Database.executeBatch(job, 200);
                } else {

                    // At last create people records
                    BatchInsertPeopleRecords job = new BatchInsertPeopleRecords(false, false, 'User Prov google');
                    Database.executeBatch(job, 200);
                }
            } 
            
        } else if('syncManagers'.equalsIgnoreCase(batchType)) { 
    
            // At last create people records
            BatchInsertPeopleRecords job = new BatchInsertPeopleRecords(false, false, 'User Prov google');
            Database.executeBatch(job, 200);
        }      
    }

    // Provision google users
    private void provUsers(){
        // Initialize config attrs
        this.initConfig();
        // Get users from google API and finally sync
        List<Object> gSuiteUsersList = this.getUsersFromGoogle();

        if(gSuiteUsersList != null){

            this.processRecords(gSuiteUsersList);
        }
    }

    private List<Object> getUsersFromGoogle(){
        Map<String, String> reqParamMap = new Map<String, String>();
        reqParamMap.put('orgId', SimpplrContext.simpplrOrgId);
        reqParamMap.put('maxResults', maxResults);

        if(String.isNotBlank(this.nextPageToken)){
            reqParamMap.put('pageToken', this.nextPageToken);
        }    
        if(String.isNotBlank(this.queryFilter)){
            reqParamMap.put('queryFilter', this.queryFilter);
        }
        
        List<String> maskList = new List<String>();
        // Pull custom schema if needed
        if(this.userProvisioningConfig.Company_Name__c 
                && String.isNotBlank(this.userProvisioningConfig.Company_Name_Field__c)){

            maskList.add(this.userProvisioningConfig.Company_Name_Field__c.split('\\.')[0]);
        }
        if(this.userProvisioningConfig.Birthdate__c 
                && String.isNotBlank(this.userProvisioningConfig.Birthdate_Field__c)){

            maskList.add(this.userProvisioningConfig.Birthdate_Field__c.split('\\.')[0]);
        }
        if(this.userProvisioningConfig.Joining_Date__c 
                && String.isNotBlank(this.userProvisioningConfig.Joining_Date_Field__c)){

            maskList.add(this.userProvisioningConfig.Joining_Date_Field__c.split('\\.')[0]);
        }
        if(this.userProvisioningConfig.Street__c && String.isNotBlank(this.userProvisioningConfig.Street_Field__c)){

            maskList.add(this.userProvisioningConfig.Street_Field__c.split('\\.')[0]);
        }
        if(this.userProvisioningConfig.City__c && String.isNotBlank(this.userProvisioningConfig.City_Field__c)){

            maskList.add(this.userProvisioningConfig.City_Field__c.split('\\.')[0]);
        }
        if(this.userProvisioningConfig.State__c && String.isNotBlank(this.userProvisioningConfig.State_Field__c)){

            maskList.add(this.userProvisioningConfig.State_Field__c.split('\\.')[0]);
        }
        if(this.userProvisioningConfig.Country__c && String.isNotBlank(this.userProvisioningConfig.Country_Field__c)){

            maskList.add(this.userProvisioningConfig.Country_Field__c.split('\\.')[0]);
        }
        if(this.userProvisioningConfig.PostalCode__c && String.isNotBlank(this.userProvisioningConfig.Postal_Code_Field__c)){

            maskList.add(this.userProvisioningConfig.Postal_Code_Field__c.split('\\.')[0]);
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
                } else {
                    this.nextPageToken = null;
                }

                // Process users records to create/update/delete
                return (List<Object>) resultMap.get('users');
            }
        }

        return null;
    }

    // Sync managers
    private void syncUsersManagers(List<User> userList){
        Set<String> managerEmailSet = new Set<String>();

        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

        for(User userObj : userList){
            String managerEmail = this.userEmailVsManagerEmailMap.get(userObj.Email.toLowerCase());
            if(String.isNotBlank(managerEmail)){
                managerEmailSet.add(managerEmail);
            }
        }

        List<User> managerList = [SELECT Id, Email FROM User WHERE Email =:managerEmailSet];

        Map<String, String> managerEmailVsIdMap = new Map<String, String>();
        for(User managerObj : managerList){
            managerEmailVsIdMap.put(managerObj.Email.toLowerCase(), managerObj.Id);
        }
        for(User userObj : userList){
            String managerEmail = this.userEmailVsManagerEmailMap.get(userObj.Email.toLowerCase());

            if(String.isNotBlank(managerEmail)){
                userObj.ManagerId = managerEmailVsIdMap.get(managerEmail);
            } else {
                userObj.ManagerId = null;
            }
            fieldList.add(User.ManagerId);
        }

        // Update manager 
        if(!userList.isEmpty()){
            SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPSFDCAccessControlResults.UpdateResults result = SIMPESAPI.accessController().updateAsUser(new Map<Id, User>(userList), fieldList);
            Database.SaveResult[] updateManagerList = result.getResults();

            Set<String> userNotUpdatedSet = new Set<String>();
            for(Integer index = 0; index < updateManagerList.size(); index++){
                if(!updateManagerList[index].isSuccess()){
                    userNotUpdatedSet.add(userList[index].email + ' - ' + updateManagerList[index].getErrors()[0].getMessage()); 
                }
            }

            // Send Email
            if(!userNotUpdatedSet.isEmpty()){
                EmailUtility emailUtilObj = new EmailUtility();
                String message = ' <br/><br/>Failed to update manager for the following users:  ';
                emailUtilObj.sendMailToCurrentUser('Google User data provisioning - Failed to update manager ', this.getEmailBody(userNotUpdatedSet, message));
            }
        }
    }

    private void processRecords(List<Object> userObjects){
        Map<String, Object> usermap = null;

        // Email set from google API
        Set<String> userEmailSet = new Set<String>();
        Set<String> googleManagerEmailSet = new Set<String>();
        for(Object userObj : userObjects){
            usermap = (Map<String, Object>) userObj;

            if(userMap.get('primaryEmail') != null){
                userEmailSet.add(((String) usermap.get('primaryEmail')).toLowerCase());
            }
        }

        if(existingUserIdList == null){
            existingUserIdList = new List<String>();
        }
        if(userEmailVsManagerEmailMap == null){
            userEmailVsManagerEmailMap = new Map<String, String>();
        }

        String peopleQuery = 'SELECT Id, User__c, Email__c, Manager__c, User__r.IsActive FROM People__c '
                            + ' WHERE User__r.UserType = \'Standard\' AND User__r.Sync_Whitelisted__c = false AND ' 
                            + ' Email__c IN :userEmailSet ';

        List<People__c> peopleList = (List<People__c>) Database.query(peopleQuery);

        Map<String, People__c> emailVsPeopleObjMap = new Map<String, People__c>();
        for(People__c peopleObj : peopleList){
            emailVsPeopleObjMap.put(peopleObj.Email__c.toLowerCase(), peopleObj);

            // Add existing user Id
            existingUserIdList.add(peopleObj.User__c);
        }

        String primaryEmail = null;
        for(Object userObj : userObjects){
            usermap = (Map<String, Object>) userObj;
            
            if(userMap.get('primaryEmail') != null){
                primaryEmail = ((String) usermap.get('primaryEmail')).toLowerCase();
            }
            People__c peopleObj = null;
            if(emailVsPeopleObjMap.get(primaryEmail) != null){
                peopleObj = emailVsPeopleObjMap.get(primaryEmail);
                if(!peopleObj.User__r.IsActive){
                   activateUserIdSet.add(peopleObj.User__c); 
                }

            } else {
                // Create list of Users to be created
                this.userTobeCreatedSet.add(userObj);
            }

            String managerEmail = this.getManager(usermap);
            // Add google user email vs manager email
            if(String.isNotBlank(managerEmail)){
                userEmailVsManagerEmailMap.put(primaryEmail, managerEmail.toLowerCase());
            }
        }
    }

    @TestVisible
    private void activateUsers(){        
        List<User> userList = [SELECT Id, email FROM USER WHERE IsActive = false And Id IN :this.activateUserIdSet];
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

        for(User userObj : userList){
            userObj.IsActive = true;     
            fieldList.add(User.IsActive);           
        }

        // Deactivate users
        SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPSFDCAccessControlResults.UpdateResults result = SIMPESAPI.accessController().updateAsUser(new Map<Id, User>(userList), fieldList);
        Database.SaveResult[] activatedUserList = result.getResults();
        
        Set<String> userNotActivatedSet = new Set<String>();
        for(Integer index = 0; index < activatedUserList.size(); index++){
            if(!activatedUserList[index].isSuccess()){
                userNotActivatedSet.add(userList[index].email + ' - ' + activatedUserList[index].getErrors()[0].getMessage()); 
            }else if((existingUserIdList!=null && existingUserIdList.isEmpty()) || (existingUserIdList !=null && !existingUserIdList.isEmpty() && !existingUserIdList.contains(activatedUserList[index].getId()))) {
                // Add ids of activated users
                existingUserIdList.add(activatedUserList[index].getId());
            }
        }
        
        // Send Email
        if(!userNotActivatedSet.isEmpty()){
            EmailUtility emailUtilObj = new EmailUtility();
            String message = ' <br/><br/>Failed to activate the following users:  ';
            emailUtilObj.sendMailToCurrentUser('Google User data provisioning - Failed to activate users ', this.getEmailBody(userNotActivatedSet, message));
        }

        // Check if the org is managed packaged.
        if(String.isNotBlank(SimpplrContext.packageName) && !Test.isRunningTest()){
            String packageName = SimpplrContext.packageName;
            
            userList = [SELECT Id FROM USER  
                        WHERE Id IN :this.activateUserIdSet
                        AND Id not in (select UserId from UserPackageLicense 
                                    where PackageLicense.NamespacePrefix =:packageName )];

            List<UserPackageLicense> userPackLicList = new List<UserPackageLicense>();
            PackageLicense packageLicObj = [SELECT Id FROM PackageLicense WHERE NamespacePrefix = :packageName];        

            for(User userObj : userList){
                UserPackageLicense licenseObj = new UserPackageLicense();
                licenseObj.packageLicenseId = packageLicObj.id;
                licenseObj.UserId = userObj.id;
                userPackLicList.add(licenseObj);
            }

            // Assign Licence
            if(userPackLicList.isEmpty() == false){

                SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().insertAsUser(userPackLicList, new List<Schema.SObjectField>{
                    UserPackageLicense.packageLicenseId,
                    UserPackageLicense.UserId
                });
            }
        }
    }

    private void createUsers(){      
        // Create users here 
        List<User> userList = new List<User>();
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
        Map<String, Object> usermap;
        Boolean fieldListInitialized = false;

        for(Object obj : this.userTobeCreatedSet){
            prepareUser((Map<String, Object>) obj, userList, fieldList, fieldListInitialized);
        }

        // Insert users, If any
        if(!userList.isEmpty()){

            SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPSFDCAccessControlResults.InsertResults insertResults = SIMPESAPI.accessController().insertAsUser(userList, fieldList);

            Database.SaveResult[] srList = insertResults.getResults();
            Set<String> userNotCreatedSet = new Set<String>();
            for(Integer srIndex = 0; srIndex < srList.size(); srIndex++){
                if(!srList[srIndex].isSuccess()){
                    userNotCreatedSet.add(userList[srIndex].email + ' - ' + srList[srIndex].getErrors()[0].getMessage());
                } else {
                    // Add ids of newly created users
                    existingUserIdList.add(srList[srIndex].getId());
                }
            }

            if(SimpplrContext.appConfig != null && SimpplrContext.appConfig.Auto_provisioning_Process_Enabled__c ){
                AutoProvisionUser.assignPermissionSets(existingUserIdList);
            }

            // Send Email
            if(!userNotCreatedSet.isEmpty()){
                EmailUtility emailUtilObj = new EmailUtility();
                String message = ' <br/><br/>Failed to create the following users:  ';
                emailUtilObj.sendMailToCurrentUser('Google User data provisioning - Failed to create new users ', this.getEmailBody(userNotCreatedSet, message));
            }
            
        }
    }

    public String getEmailBody(Set<String> userNotCreatedSet, String message) {
		String str = '';
        str += message; 
		str +='<br/> <ul>';

        for(String emailStr : userNotCreatedSet){
            str +=' <li> ' + emailStr + '</li>';
        }

        str +='</ul>';

		return str;
	}

    public void prepareUser(Map<String, Object> userMap, List<User> userList, List<Schema.SObjectField> fieldList, Boolean fieldListInitialized) {
		
        User userObj = new User();

        String lastName = this.getLastName(userMap);
        
        userObj.Alias = lastName;
        if(lastName.length() > 8){
            userObj.Alias = lastName.left(8);
        }
        if(fieldListInitialized == false) fieldList.add(User.Alias);

        String email = this.getEmail(userMap);

        if(this.isFederationID){
            userObj.FederationIdentifier = email;
            if(fieldListInitialized == false) fieldList.add(User.FederationIdentifier);
        }

        userObj.Username = email.SubStringBefore('@') + '@' + this.suffix;
        if(fieldListInitialized == false) fieldList.add(User.Username);
        
        userObj.TimeZoneSidKey = this.TimeZoneSidKey;
        userObj.LocaleSidKey = 'en_US';
        userObj.EmailEncodingKey = 'UTF-8';
        userObj.ProfileId = this.userProfileId;
        userObj.LanguageLocaleKey = 'en_US';

        if(fieldListInitialized == false) {
            fieldList.add(User.TimeZoneSidKey);
            fieldList.add(User.LocaleSidKey);
            fieldList.add(User.EmailEncodingKey);
            fieldList.add(User.ProfileId);
            fieldList.add(User.LanguageLocaleKey);
        }

        if(this.userProvisioningConfig.Firstname__c){
            userObj.FirstName = this.getFirstName(userMap);
            if(fieldListInitialized == false) fieldList.add(User.FirstName);
		}
        if(this.userProvisioningConfig.Firstname__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            userObj.FirstName__c = this.getFirstName(userMap);
            if(fieldListInitialized == false) fieldList.add(User.FirstName__c);
		}
		if(this.userProvisioningConfig.Lastname__c){
            userObj.LastName = lastName;
            if(fieldListInitialized == false) fieldList.add(User.LastName);
		}
        if(this.userProvisioningConfig.Lastname__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            userObj.Lastname__c = lastName;
            if(fieldListInitialized == false) fieldList.add(User.Lastname__c);
		}
        if(this.userProvisioningConfig.User_Title__c){
            userObj.Title = this.getTitle(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Title);
        }
        if(this.userProvisioningConfig.User_Title__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            userObj.Title__c = this.getTitle(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Title__c);
		}
        if(this.userProvisioningConfig.Department__c){
            userObj.Department = this.getDepartment(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Department);
        }
        if(this.userProvisioningConfig.Department__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            userObj.Department__c = this.getDepartment(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Department__c);
		}
        if(this.userProvisioningConfig.Company_Name__c){
            if(String.isNotBlank(this.userProvisioningConfig.Company_Name_Field__c)){
                userObj.CompanyName = this.getCompanyNameFromCustomField(userMap);
            } else {
                userObj.CompanyName = this.getCompanyName(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.CompanyName);
        }

        if(this.userProvisioningConfig.Company_Name__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            if(String.isNotBlank(this.userProvisioningConfig.Company_Name_Field__c)){
                userObj.CompanyName__c = this.getCompanyNameFromCustomField(userMap);
            } else {
                userObj.CompanyName__c = this.getCompanyName(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.CompanyName__c);
		}

        Map<String, Schema.SobjectField> nameVsObjectFieldApiUserObjMap = Utility.getFieldMapByObjectName('User');

        if(this.userProvisioningConfig.Birthdate__c && userFields.contains('Birth_Date__c')){
            if(String.isNotBlank(this.userProvisioningConfig.Birthdate_Field__c)){
                String birthDateStr = this.getBirthDate(userMap);
                userObj.put('Birth_Date__c', String.isNotBlank(birthDateStr) ? convertStringToDate(birthDateStr, true) : null);
            } else {
                userObj.put('Birth_Date__c', null);
            }
            if(fieldListInitialized == false) fieldList.add(nameVsObjectFieldApiUserObjMap.get('Birth_Date__c'));
        }
        if(this.userProvisioningConfig.Joining_Date__c && userFields.contains('Joining_Date__c')){
            if(String.isNotBlank(this.userProvisioningConfig.Joining_Date_Field__c)){
                String joinDateStr = this.getJoiningDate(userMap);
                userObj.put('Joining_Date__c', String.isNotBlank(joinDateStr) ? convertStringToDate(joinDateStr, false) : null);
            } else {
                userObj.put('Joining_Date__c', null);
            }
            if(fieldListInitialized == false) fieldList.add(nameVsObjectFieldApiUserObjMap.get('Joining_Date__c'));
        }
		if(this.userProvisioningConfig.User_Email__c){
            userObj.Email = this.getEmail(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Email);
		}
        if(this.userProvisioningConfig.User_Email__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            userObj.Email__c = this.getEmail(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Email__c);
		}
        if(this.userProvisioningConfig.Street__c){
            if(String.isNotBlank(this.userProvisioningConfig.Street_Field__c)){
                userObj.Street = this.getStreetFromCustomField(userMap);
            } else {
                userObj.Street = this.getStreet(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.Street);
        }
        if(this.userProvisioningConfig.Street__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            if(String.isNotBlank(this.userProvisioningConfig.Street_Field__c)){
                userObj.Street__c = this.getStreetFromCustomField(userMap);
            } else {
                userObj.Street__c = this.getStreet(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.Street__c);
		}
        if(this.userProvisioningConfig.PostalCode__c){
            if(String.isNotBlank(this.userProvisioningConfig.Postal_Code_Field__c)){
                userObj.PostalCode = this.getPostalCodeFromCustomField(userMap);
            } else {
                userObj.PostalCode = this.getPostalCode(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.PostalCode);
        }
        if(this.userProvisioningConfig.PostalCode__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            if(String.isNotBlank(this.userProvisioningConfig.Postal_Code_Field__c)){
                userObj.PostalCode__c = this.getPostalCodeFromCustomField(userMap);
            } else {
                userObj.PostalCode__c = this.getPostalCode(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.PostalCode__c);
		}
        if(this.userProvisioningConfig.City__c){
            if(String.isNotBlank(this.userProvisioningConfig.City_Field__c)){
                userObj.City = this.getCityFromCustomField(userMap);
            } else {
                userObj.City = this.getCity(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.City);
        }
        if(this.userProvisioningConfig.City__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            if(String.isNotBlank(this.userProvisioningConfig.City_Field__c)){
                userObj.City__c = this.getCityFromCustomField(userMap);
            } else {
                userObj.City__c = this.getCity(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.City__c);
		}
        if(this.userProvisioningConfig.State__c){
            if(String.isNotBlank(this.userProvisioningConfig.State_Field__c)){
                userObj.State = this.getStateFromCustomField(userMap);
            } else {
                userObj.State = this.getState(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.State);
        }
        if(this.userProvisioningConfig.State__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            if(String.isNotBlank(this.userProvisioningConfig.State_Field__c)){
                userObj.State__c = this.getStateFromCustomField(userMap);
            } else {
                userObj.State__c = this.getState(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.State__c);
		}
        if(this.userProvisioningConfig.Country__c){
            if(String.isNotBlank(this.userProvisioningConfig.Country_Field__c)){
                userObj.Country = this.getCountryFromCustomField(userMap);
            } else {
                userObj.Country = this.getCountry(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.Country);
        }
        if(this.userProvisioningConfig.Country__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            if(String.isNotBlank(this.userProvisioningConfig.Country_Field__c)){
                userObj.Country__c = this.getCountryFromCustomField(userMap);
            } else {
                userObj.Country__c = this.getCountry(userMap);
            }
            if(fieldListInitialized == false) fieldList.add(User.Country__c);
		}
		if(this.userProvisioningConfig.Phone__c){
            userObj.Phone = this.getPhone(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Phone);
		}
        if(this.userProvisioningConfig.Phone__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            userObj.Phone__c = this.getPhone(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Phone__c);
		}
		if(this.userProvisioningConfig.MobilePhone__c){
            userObj.MobilePhone = this.getMobilePhone(userMap);
            if(fieldListInitialized == false) fieldList.add(User.MobilePhone);
		}
        if(this.userProvisioningConfig.MobilePhone__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            userObj.MobilePhone__c = this.getMobilePhone(userMap);
            if(fieldListInitialized == false) fieldList.add(User.MobilePhone__c);
		}
		if(this.userProvisioningConfig.Fax__c){
            userObj.Fax = this.getFax(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Fax);
		}
        if(this.userProvisioningConfig.Fax__c && SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(SimpplrContext.packageName)){
            userObj.Fax__c = this.getFax(userMap);
            if(fieldListInitialized == false) fieldList.add(User.Fax__c);
        }

        fieldListInitialized = true;

        userList.add(userObj);
    }

    private Set<String> getUserFields () {
        Set<String> userFieldsSet = new Set<String>();
		List<Schema.SObjectField> userFieldsSchema = User.getSObjectType().getDescribe().fields.getMap().values();
		for(Schema.SObjectField field : userFieldsSchema){
            userFieldsSet.add(field + '');
        }

		return userFieldsSet;          
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

    private String getBirthDate(Map<String, Object> userMap){
        String field = null;

        if(userMap.get('customSchemas') != null){
            Map<String, Object> customSchemaMap = (Map<String, Object>) userMap.get('customSchemas');

            if(customSchemaMap != null && customSchemaMap.size() > 0){

                List<String> birthdayKeysList = this.userProvisioningConfig.Birthdate_Field__c.split('\\.');
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
                List<String> joindateKeysList = this.userProvisioningConfig.Joining_Date_Field__c.split('\\.');
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

    private void deactivateUser(){
        List<String> userIdNotToBeDeactivatedList = new List<String>(); 
        userIdNotToBeDeactivatedList.add(UserInfo.getUserId());
        if (this.existingUserIdList != null && !this.existingUserIdList.isEmpty()) {
            userIdNotToBeDeactivatedList.addAll(existingUserIdList);
        }
        
        List<User> userList = [SELECT Id, IsActive, Email FROM User WHERE
                                Id NOT IN :userIdNotToBeDeactivatedList
                                AND IsActive = true 
                                AND Sync_Whitelisted__c = false
                                AND UserType = 'Standard'];

        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

        if(userList != null && !userList.isEmpty()){
            
            for (User userObj : userList) {
                userObj.IsActive = false;
                fieldList.add(User.IsActive);
            }
            
            SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPSFDCAccessControlResults.UpdateResults result = SIMPESAPI.accessController().updateAsUser(new Map<Id, User>(userList), fieldList);
            Database.SaveResult[] deactivatedUserList = result.getResults();
            
            Set<String> userNotDeactivatedSet = new Set<String>();
            for(Integer index = 0; index < deactivatedUserList.size(); index++){
                if(!deactivatedUserList[index].isSuccess()){
                    userNotDeactivatedSet.add(userList[index].email + ' - ' + deactivatedUserList[index].getErrors()[0].getMessage()); 
                }
            }
    
            // Send Email
            if(!userNotDeactivatedSet.isEmpty()){
                EmailUtility emailUtilObj = new EmailUtility();
                String message = ' <br/><br/>Failed to deactivate the following users:  ';
                emailUtilObj.sendMailToCurrentUser('Google User data provisioning - Failed to deactivate users ', this.getEmailBody(userNotDeactivatedSet, message));
            }
        }
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

                List<String> companyKeysList = this.userProvisioningConfig.Company_Name_Field__c.split('\\.');
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

     private String getManager(Map<String, Object> userMap){
        String field = null;
        if(userMap.get('relations') != null){
            List<Object> realtionList = (List<Object>) userMap.get('relations');
            Map<String, Object> relationMap = null;
            for(Object relationObj : realtionList){

                relationMap = (Map<String, Object>) relationObj;
                if(relationMap.get('type') != null && 'manager'.equalsIgnoreCase((String) relationMap.get('type'))){
                    if(relationMap.get('value') != null){
                        field = (String) relationMap.get('value');
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

                List<String> streetKeysList = this.userProvisioningConfig.Street_Field__c.split('\\.');
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

                List<String> cityKeysList = this.userProvisioningConfig.City_Field__c.split('\\.');
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

                List<String> stateKeysList = this.userProvisioningConfig.State_Field__c.split('\\.');
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

                List<String> countryKeysList = this.userProvisioningConfig.Country_Field__c.split('\\.');
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

                List<String> postalCodeKeysList = this.userProvisioningConfig.Postal_Code_Field__c.split('\\.');
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
       
        userTobeCreatedSet = new Set<Object>();
        activateUserIdSet = new Set<String>();
        userFields = getUserFields();
        
        if(userProvisioningConfig != null){
        
            this.canCreateUser = userProvisioningConfig.Create_New_Users__c;
            this.canDeactivateUser = userProvisioningConfig.Deactive_User__c;
            this.isFederationID = userProvisioningConfig.FedrationId__c;
            this.userProfileId = userProvisioningConfig.Profile_Type__c;
            this.timeZoneSidKey = userProvisioningConfig.TimezoneSidKey__c;
            this.suffix = userProvisioningConfig.Username_Suffix__c;
            this.queryFilter = userProvisioningConfig.Query_Filter__c;

        }
    }
}