public without sharing class BatchUpdateAlertAnalytics implements Database.Batchable<SObject>, Database.stateful {
	public String actionName;
	public Id alertId;
	public List<String> archivedSiteList;
	private Exception exceptionDetailsObj;
	
	public BatchUpdateAlertAnalytics(String actionName, Id alertId, List<String> archivedSiteList){
		this.actionName = actionName;
		this.archivedSiteList = archivedSiteList;
		this.alertId = alertId;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query = '';
		if('ResetMarkAsDismiss'.equalsIgnoreCase(actionName)){
			query = 'SELECT id,Is_Marked_Dismissed__c FROM Analytics_Alert__c WHERE Alert__c =:alertId AND Is_Marked_Dismissed__c=true AND Is_Deleted__C = false';	
		} else if('ExpireOrDeleteAlerts'.equalsIgnoreCase(actionName)) {
			query = 'SELECT id,Is_Manually_Expired__c,Display_From_DateTime__c, Is_Deleted__c FROM Alert__c WHERE Recipient_Site__c IN:archivedSiteList AND Is_Deleted__C = false';
		}
		return Database.getQueryLocator(query);
	}
    public void execute(Database.BatchableContext BC, List<SObject> sObjectList){
    	try{
    	if('ResetMarkAsDismiss'.equalsIgnoreCase(actionName)){
    		markAlertNonDismissed((List<Analytics_Alert__c>)sObjectList);
    	} else if('ExpireOrDeleteAlerts'.equalsIgnoreCase(actionName)){
    		markAlertExpiredOrDeleted((List<Alert__c>)sObjectList);
    	}
    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    public void finish(Database.BatchableContext BC){
    		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchUpdateAlertAnalytics', exceptionDetailsObj);
		}
    }
    
    private void markAlertNonDismissed(List<Analytics_Alert__c> alertAnalList){
    	for(Analytics_Alert__c alertAnalObj : alertAnalList){
    		alertAnalObj.Is_Marked_Dismissed__c = false;
    	}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,Analytics_Alert__c>(alertAnalList), new List<Schema.SObjectField>{
			Analytics_Alert__c.Is_Marked_Dismissed__c
		});
    }
    
    private void markAlertExpiredOrDeleted(List<Alert__c> alertList){
    	for(Alert__c alertObj : alertList){
    		if(alertObj.Display_From_DateTime__c != null && alertObj.Display_From_DateTime__c > DateTime.now()){
    			alertObj.Is_Deleted__c = true;
    		} else {
    			alertObj.Is_Manually_Expired__c = true;
    		}
    	}
    	update alertList;
    }
}