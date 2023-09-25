public with sharing class BatchMigrateRecords implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {
    
    private final String BATCH_TOPICS_CLEANUP = 'topicsCleanUp';
    private final String BATCH_RESET_CDC_RETRY_COUNT = 'resetCDCRetryCount';
    private String batchContext;
	private String query;
	private Boolean runNextBatchInSequence;
    private Exception exceptionDetailsObj;


    public BatchMigrateRecords(String batchContext, Boolean runNextBatchInSequence){
        this.batchContext = batchContext;
        this.runNextBatchInSequence = runNextBatchInSequence;
    }

  	public database.querylocator start(Database.BatchableContext bc) { 
        String orgId = UserInfo.getOrganizationId();
        String packageName = SimpplrContext.packageName;

        if(BATCH_TOPICS_CLEANUP.equalsIgnoreCase(batchContext)) {
            query = 'SELECT Id, Name from Topic WHERE Id NOT IN (SELECT TopicId FROM TopicAssignment)';
        
            if(SimpplrContext.isCommunitiesEnabled) {
                query += ' AND NetworkId = null';
            }
        } else if(BATCH_RESET_CDC_RETRY_COUNT.equalsIgnoreCase(batchContext)) {
            query = 'SELECT Id FROM External_Data_Trail__c WHERE Retry_Count__c >= 5';
        }  

		return Database.getQueryLocator(query);
	}
    
	public void execute(Database.BatchableContext bc, sObject[] listOfsObject) {
    	try {
            if(BATCH_TOPICS_CLEANUP.equalsIgnoreCase(batchContext)) {
                List<Topic> topicList = (List<Topic>)listOfsObject;
                delete topicList;
            } else if(BATCH_RESET_CDC_RETRY_COUNT.equalsIgnoreCase(batchContext)) {
                List<External_Data_Trail__c> listOfDataTrialObj = (List<External_Data_Trail__c>) listOfsObject;

                for(External_Data_Trail__c trailObj: listOfDataTrialObj){
                    trailObj.Retry_Count__c  = 3;
                }

                if(listOfDataTrialObj != null && !listOfDataTrialObj.isEmpty()){
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().updateAsUser(new Map<Id, External_Data_Trail__c>(listOfDataTrialObj), new List<Schema.SObjectField>{
                        External_Data_Trail__c.Retry_Count__c
                    });
                }

            }

		} catch (Exception ex) {
            exceptionDetailsObj =  ex;
    		throw ex;
    	}
    }

    public void finish (Database.BatchableContext bc) {
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
                                            TotalJobItems, CreatedBy.Email, ExtendedStatus 
                                    FROM AsyncApexJob 
                                    WHERE Id = :bc.getJobId()];
                                    
		Boolean canStartNextBatch = false;

		if (currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendBatchFailedExceptionEmail('BatchMigrateRecords.' + batchContext, exceptionDetailsObj);
        }

        if (canStartNextBatch && runNextBatchInSequence) {
            sendCompletionEmail();            
            
        }
    }

    private void sendCompletionEmail() {
        String mailSubject = 'Migration process has been successfully completed';
        String mailBodyHtml = 'Hi ' + UserInfo.getName() + ',<br/><br/> Migration has been successfully completed.';
        mailBodyHtml+=' <br/><br/>Org Details:<br/>';
        mailBodyHtml+=' <br/>OrgId - '+ UserInfo.getOrganizationId();
        mailBodyHtml+=' <br/>Org Name - '+ UserInfo.getOrganizationName();
        mailBodyHtml+=' <br/> <br/> Thanks.!';
        EmailUtility emailUtilObj = new EmailUtility();
        emailUtilObj.sendMailToCurrentUser(mailSubject,mailBodyHtml);
    }
    
}