/**
* Class BatchCheckUserLinkedinIntegration
* Purpose:  Batch to check if user's LinkedIn token is expired
* and if expired send mail
*
*/
public with sharing class BatchCheckUserLinkedinIntegration implements Database.Batchable<SObject>, Database.Stateful {
    public String query;
    public String integrationType;
    public Exception exceptionDetailsObj;
    public Boolean runNext;
    public Datetime currentTime;

    public BatchCheckUserLinkedinIntegration(Boolean runNext){
        String integrationType = IntegrationConstants.INTEGRATION_TYPE_LINKEDIN;
        this.integrationType = integrationType;
        Datetime currentTime = System.now();
        this.currentTime = currentTime;
        this.runNext = runNext;
        String query;
        if(SimpplrContext.isLinkedinConnected){
            query =  ' SELECT Id,Access_Token__c,Refresh_Token__c,People__c,People__r.User__c';
            query += ' FROM People_Integration__c WHERE Connected__c = TRUE AND';
            query += ' Is_Deleted__c = FALSE AND App_Integration__r.Name =:integrationType';
            query += ' AND Access_Token_Expiration_Datetime__c <=:currentTime';
        }
        else{
            query = 'SELECT Id from People_Integration__c where Id = null';
        }
        this.query=query;
    }

    public database.querylocator start(Database.BatchableContext bc){
    	return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<People_Integration__c> peopleIntList){
        try{
            List<People_Integration__c> disconnectList = new List<People_Integration__c>();
			Set<Id> peopleIds = new Set<Id>();
            for(People_Integration__c peopleInt : peopleIntList){
                disconnectList.add(peopleInt);
                peopleIds.add(peopleInt.People__c);
            }
            if(disconnectList.size()>0){
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(disconnectList);
            } 
            if(peopleIds.size()>0){
                NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(peopleIds,'LinkedIn');
            }
    	}catch(Exception ex){
    		exceptionDetailsObj =  ex;
    		throw ex;
    	}
    }

    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
        TotalJobItems, CreatedBy.Email, ExtendedStatus 
        FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        Boolean canStartNextBatch = false;
        if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
            canStartNextBatch = true;
        } else {
            Utility.sendExceptionEmail('BatchCheckUserLinkedinIntegration', exceptionDetailsObj);
        }
        if(runNext){
            BatchCheckUserDropboxIntegration dropboxBatch = new BatchCheckUserDropboxIntegration(runNext);
            Database.executeBatch(dropboxBatch,100);
        }
    }
}