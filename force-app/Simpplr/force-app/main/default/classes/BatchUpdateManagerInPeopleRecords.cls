public with sharing class BatchUpdateManagerInPeopleRecords implements Database.Batchable<SObject> {
	
    private List<String> listOfUserIds;
    private Boolean runNextBatchInSequence;
    private Boolean generateEmailOnCompletion;
	private String recordType;
	private Boolean isCalledFromScheduler = false;

    public BatchUpdateManagerInPeopleRecords(List<String> listOfUserIds) {
    	this.listOfUserIds = listOfUserIds;
    	this.runNextBatchInSequence = false;
    	this.generateEmailOnCompletion = false;
		// This constructor is called from BatchSfdcUserDataSync which is called from scheduler
		this.isCalledFromScheduler = true;
    }
    
    public BatchUpdateManagerInPeopleRecords(List<String> listOfUserIds, Boolean runNextBatchInSequence) {
    	this.listOfUserIds = listOfUserIds;
    	this.runNextBatchInSequence = runNextBatchInSequence;
    	this.generateEmailOnCompletion = false;
    }
    
    public BatchUpdateManagerInPeopleRecords(List<String> listOfUserIds, Boolean runNextBatchInSequence, Boolean generateEmailOnCompletion, String recordType) {
    	this.listOfUserIds = listOfUserIds;
    	this.runNextBatchInSequence = runNextBatchInSequence;
    	this.generateEmailOnCompletion = generateEmailOnCompletion;
		this.recordType = recordType;
    }
    
    public database.querylocator start(Database.BatchableContext bc){
    	String query = 'select User__c, User__r.ManagerId from People__c where user__c =:listOfUserIds';
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
	    	List<People__c> listOfFetchedPeople = (List<People__c>)listOfsObject;
	    	map<String, String> mapOfUserIdAndManagersId = new map<String, String>();
	    	for(People__c peopleObj : listOfFetchedPeople) {
	    		mapOfUserIdAndManagersId.put(peopleObj.user__c, peopleObj.User__r.ManagerId);
	    	}
	    	PeopleDao peopleDaoObj = new PeopleDao();
	    	peopleDaoObj.updateManagerInfo(listOfFetchedPeople, mapOfUserIdAndManagersId);
    	} catch(Exception ex) {
    		String mailSubject='BatchUpdateManagerInPeopleRecords batch failed';
    		
			String mailBodyHtml='Dear User'+ ', <br/><br/> BatchUpdateManagerInPeopleRecords batch has failed due to following reasons:';
			mailBodyHtml+=' <br/>Error Message - ' + ex.getMessage(); 
			mailBodyHtml+=' <br/>Line Number - ' + ex.getLineNumber();
			mailBodyHtml+=' <br/>Error cause - ' + ex.getCause(); 
			mailBodyHtml+=' <br/>Error stack trace - ' + ex.getStackTraceString();
			mailBodyHtml+=' <br/>Exception Type Name - ' + ex.getTypeName();
			mailBodyHtml+=' <br/>Org Info - ' + UserContext.id + '/' + UserInfo.getOrganizationId();
			mailBodyHtml+=' <br/> <br/> Thanks.!';
			
			EmailUtility emailUtilObj=new EmailUtility();
			emailUtilObj.sendMailToCurrentUser(mailSubject,mailBodyHtml);

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
		
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			
			logUserSyncProvStatus('successful', recordType);
		} else {

			logUserSyncProvStatus('failed', recordType);
		}

    	if(generateEmailOnCompletion) {
	    	String mailSubject='Setup batch for People creation completed.';
			String mailBodyHtml='Dear User'+ ', <br/><br/> Setup batch for People creation started by you has been completed.';
			mailBodyHtml+=' <br/> <br/> Thanks.!';
			EmailUtility emailUtilObj=new EmailUtility();
			emailUtilObj.sendMailToCurrentUser(mailSubject, mailBodyHtml);
    	}
		if(runNextBatchInSequence) {
			startSiteBatch();
		} else if(isCalledFromScheduler) {
			// Added to execute nigthly jobs sequentially
			SchedulerSimpplrServices.executeNextJob('peopleSync');
		}
		if(!Test.isRunningTest()) {
			BatchUpdatePeopleLicence updatePeopleLicenseJob = new BatchUpdatePeopleLicence('syncLicenseFlagToTrue');
			Database.executeBatch(updatePeopleLicenseJob, 5);
		}
    }
    
    private void startSiteBatch(){
		BatchInsertSiteRecords job = new BatchInsertSiteRecords(true);
		Database.executeBatch(job,200);
    }
}