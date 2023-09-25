/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchInsertPeopleRecords implements Database.Batchable<SObject>, Database.Stateful,Database.AllowsCallouts {
	
	private List<String> consolidatedListOfUserIds;
	private Boolean generateEmailOnCompletion;
	private String query;
	private Boolean runNextBatchInSequence;
	private Boolean isInitialSetup;
	private string recordType ;
	
	public BatchInsertPeopleRecords(){
		consolidatedListOfUserIds = new List<String>();
		this.runNextBatchInSequence = false;
		this.generateEmailOnCompletion = false;
	}

	public BatchInsertPeopleRecords(Boolean generateEmailOnCompletion, Boolean runNextBatchInSequence, String recordType){
		consolidatedListOfUserIds = new List<String>();
		this.runNextBatchInSequence = runNextBatchInSequence;
		this.generateEmailOnCompletion = generateEmailOnCompletion;
		this.isInitialSetup = false;
		this.recordType = recordType;
	}
	
	public BatchInsertPeopleRecords(Boolean runNextBatchInSequence, Boolean isInitialSetup) {
		consolidatedListOfUserIds = new List<String>();
		this.runNextBatchInSequence = runNextBatchInSequence;
		this.generateEmailOnCompletion = true;
		this.isInitialSetup = isInitialSetup;
	}
	
	public BatchInsertPeopleRecords(String query){
		this.query = query; 		
		consolidatedListOfUserIds = new List<String>();
		this.runNextBatchInSequence = false;
		this.generateEmailOnCompletion = false;
		this.isInitialSetup = false;
	}
	
    public database.querylocator start(Database.BatchableContext bc){
    	
    	if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(recordType) ) {
			query = 'SELECT Id, First_Name__c, Last_Name__c, Email__c, Full_Name__c, App_Moderation_Permission__c, '
					+ ' Postal_Code__c, City__c, State__c, Country__c '
					+ ' FROM People__c WHERE Id not in(SELECT people__c from people_integration__c where name=\'native_video\')';
	
		} else {
    		query = 'SELECT Id from User where ((isActive=true And UserType=\'Standard\') Or Show_Simpplr__c=\'Yes\') And id not in (select user__c from People__c)';
		}
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
		 List<People__c> listOfPeopleInserted ;
		 
		 if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(recordType) && SimpplrContext.isNativeVideo){
			List<NativeVideoWrapper.peopleWrapper> listofPeopleToBeSynced = new List<NativeVideoWrapper.peopleWrapper>();
			listOfPeopleInserted = (List<People__C>)listOfsObject;
			For(people__c peopleObj :listOfPeopleInserted){
				NativeVideoWrapper.peopleWrapper wrapperObj = new NativeVideoWrapper.peopleWrapper();
				wrapperObj.peopleId = peopleObj.id;
				wrapperObj.firstName =  peopleObj.First_Name__c;
				wrapperObj.lastName =   peopleObj.Last_Name__c;
				wrapperObj.email = peopleObj.Email__c;
				wrapperObj.name = peopleObj.Full_Name__c;
				wrapperObj.country = peopleObj.Country__c;
				wrapperObj.state = peopleObj.State__c;
				wrapperObj.city = peopleObj.City__c;
				wrapperObj.zip = peopleObj.Postal_Code__c;
				wrapperObj.isAppManager = 'Yes'.equalsIgnoreCase(peopleObj.App_Moderation_Permission__c);

				listofPeopleToBeSynced.add(wrapperObj);				
			}
			sendDataToAws(JSON.serialize(listofPeopleToBeSynced)); 

		 } else {

			List<User> listOfUsers = (List<User>)listOfsObject;
			String fetchedUsersQueryStr = 'SELECT AboutMe,City,CommunityNickname,CompanyName,Country,Department,Division,'
											+ ' Email,EmployeeNumber,Extension,Fax,FirstName,LastName,ManagerId,MobilePhone,'
											+ ' Phone,PostalCode,State,Street,Title, isActive, UserType, Show_Simpplr__c,'
											+ ' AboutMe__c,City__c,CommunityNickname__c,CompanyName__c,'
											+ ' Country__c,Department__c,Division__c, ' 
											+ ' Email__c,EmployeeNumber__c,Extension__c,Fax__c,FirstName__c,LastName__c,MobilePhone__c, '
											+ ' Phone__c,PostalCode__c,State__c,Street__c,Title__c,'
											+ ' CreatedDate';									
			
			Set<String> userFieldSet = getUserFields();
			if(userFieldSet.contains('Birth_Date__c')){
				fetchedUsersQueryStr += ',Birth_Date__c ';
			}
			if(userFieldSet.contains('Joining_Date__c')){
				fetchedUsersQueryStr += ',Joining_Date__c ';
			}
			fetchedUsersQueryStr += ' FROM User WHERE id IN: listOfUsers ';

			List<User> listOfFetchedUsers = Database.query(fetchedUsersQueryStr);

			for(User userObj : listOfFetchedUsers) {
				consolidatedListOfUserIds.add(userObj.id);
			}
			PeopleDao peopleDaoObj = new PeopleDao();
			listOfPeopleInserted = peopleDaoObj.insertPeople(listOfFetchedUsers);
			peopleDaoObj.insertPeoplePreference(listOfPeopleInserted);
	
		 }
		} catch(Exception ex) {
    		String mailSubject='BatchInsertPeopleRecords batch failed';
    		
			String mailBodyHtml='Dear User'+ ', <br/><br/> BatchInsertPeopleRecords batch has failed due to following reasons:';
			mailBodyHtml+=' <br/>Error Message - ' + ex.getMessage(); 
			mailBodyHtml+=' <br/>Line Number - ' + ex.getLineNumber();
			mailBodyHtml+=' <br/>Error cause - ' + ex.getCause(); 
			mailBodyHtml+=' <br/>Error stack trace - ' + ex.getStackTraceString();
			mailBodyHtml+=' <br/>Exception Type Name - ' + ex.getTypeName();
			mailBodyHtml+=' <br/>Org Info - ' + UserContext.id + '/' + UserInfo.getOrganizationId();
			mailBodyHtml+=' <br/> <br/> Thanks.!';
			
			EmailUtility emailUtilObj=new EmailUtility();
			emailUtilObj.sendMailToCurrentUser(mailSubject,mailBodyHtml);

			// create logs for this batch job
			logUserSyncProvStatus('failed', recordType);
    	}
    }

	private void logUserSyncProvStatus(String status, String recordType){
		if('User Prov google'.equalsIgnoreCase(recordType)){
				
			// create logs for this batch job
			ManageApplicationDao.logUserSyncProvStatus(status, recordType);
		}
	}
    
    public void finish(Database.BatchableContext bc){
		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email,
                                     ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean isBatchSuccessful = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			isBatchSuccessful = true;
			
		}

		if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(recordType)){
			
		} else {
			if(isInitialSetup == true) {
				String currentUserId = UserInfo.getUserId();
				List<People__c> peopleList = [select id, App_Moderation_Permission__c from People__c where User__c =:currentUserId];
				if(!peopleList.isEmpty()) {
					peopleList[0].App_Moderation_Permission__c = 'Yes';

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(peopleList), new List<Schema.SObjectField>{
																			People__c.App_Moderation_Permission__c
																		});

				}
				
			}
			DateTime currentTime = DateTime.now().addHours(-1); 			
			List<People__c> peopleList = [SELECT id, user__c, Segment__c 
											FROM people__c 
											WHERE id NOT IN (SELECT people__c FROM people_preference__c)
											AND CreatedDate <=:currentTime
											AND User__r.IsActive = true
											Limit 9000];
			if(!peopleList.isEmpty()) {
				PeopleDao peopleDaoObj = new PeopleDao();
				peopleDaoObj.insertPeoplePreference(peopleList);
			}
			if(!consolidatedListOfUserIds.isEmpty()) {
				List<String> listOfUserIds = consolidatedListOfUserIds;
				BatchUpdateManagerInPeopleRecords job = new BatchUpdateManagerInPeopleRecords(listOfUserIds, runNextBatchInSequence, generateEmailOnCompletion, recordType);
				Database.executeBatch(job, 1000); 
			} else {

				if(isBatchSuccessful){
					logUserSyncProvStatus('successful', recordType);
					BatchUpdatePeopleLicence updatePeopleLicenseJob = new BatchUpdatePeopleLicence('syncLicenseFlagToTrue');
					Database.executeBatch(updatePeopleLicenseJob, 5);
				} else {
					logUserSyncProvStatus('failed', recordType);
				}
			} 
			if(SimpplrContext.isNativeVideo){	
				BatchInsertPeopleRecords job = new BatchInsertPeopleRecords(false, runNextBatchInSequence, ServiceConstants.VIDEO_PROVIDER_NATIVE);
				database.executeBatch(job, 50);
			}
		}
        if(SimpplrContext.locationNormalizationEnabled) {
            BatchPeopleLocationNormalization batchOb = new BatchPeopleLocationNormalization();
            Database.executeBatch(batchOb, 2000);
        } 

	}
	private Set<String> getUserFields () {
        Set<String> userFieldsSet = new Set<String>();
		List<Schema.SObjectField> userFieldsSchema = User.getSObjectType().getDescribe().fields.getMap().values();
		for(Schema.SObjectField field : userFieldsSchema){
            userFieldsSet.add(field + '');
        }

		return userFieldsSet;          
	}
	public static void sendDataToAws (String peopleList) {
		String USER_CREATION_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/user-manager';                
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('org_id', SimpplrContext.simpplrOrgId);
		requestBody.put('peopleList', peopleList);
		requestBody.put('action', 'syncDeltaUsers');
		HttpResponse res = Utility.getResponseFromAWS(USER_CREATION_ENDPOINT, requestBody);
	}
}