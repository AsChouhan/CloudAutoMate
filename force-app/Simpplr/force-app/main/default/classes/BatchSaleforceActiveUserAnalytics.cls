public with sharing class BatchSaleforceActiveUserAnalytics implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
	
	private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
	Integer salesforceUserCount = 0 ;
	Date startDate ;
	Date endDate ;
	DateTime startDateTime ;
	DateTime endDateTime ;
	String recordType;
	List<Object> analyticWrapperList;
	
	public BatchSaleforceActiveUserAnalytics(String recordType, Date dateArg){
		startDate = dateArg;
		endDate = dateArg.addDays(1) ;
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);
		this.recordType = recordType;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query;
		
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			query = 'SELECT Id FROM User where isActive = true AND UserType=\'Standard\' AND createdDate <: endDateTime';
		
		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
			query = 'select Id, Average_logins_per_user__c, Data_Pushed__c, Date__c, Desktop__c, DesktopApp__c, Mobile__c, MobileApp__c,'
    				+' Page_Views__c, Total_Active_Salesforce_User__c, Total_Logins__c, Total_Simpplr_Users__c, Unique_logins__c, Users_logged_in__c,'
    				+' Hybrid_Android_App__c, Hybrid_IOS_App__c, Native_Android_App__c, Native_IOS_App__c, Likes__c, Posts__c,'
    				+' Replies__c, Shares__c, Content_Views__c, Sync_Status__c from Analytics_Login__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
		}
		
		return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> listOfsObject){
    	
    		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
    			salesforceUserCount = salesforceUserCount + listOfsObject.size();
    		
    		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
			PushAnalyticsDataHelper analyticsDataHelper = new PushAnalyticsDataHelper();
    			analyticsDataHelper.sendAnalticsLoginListToAWS(listOfsObject);
    		}
    }
    
    public void finish(Database.BatchableContext BC){
	    try {
		    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			    	List<Analytics_Login__c> loginAnalList = [select Id,Total_Active_Salesforce_User__c from Analytics_Login__c where Date__c=:startDate];
			    	if(!loginAnalList.isEmpty()){
			    		loginAnalList[0].Total_Active_Salesforce_User__c = salesforceUserCount;

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id, Analytics_Login__c>(loginAnalList), new List<Schema.SObjectField>{
							Analytics_Login__c.Total_Active_Salesforce_User__c
						});
			    	}
			    	
		    	}
	    	} catch(Exception ex) {
			Utility.sendBatchFailedExceptionEmail('BatchSaleforceActiveUserAnalytics', ex);
		}
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
		    	BatchSaleforceActiveUserAnalytics job = new BatchSaleforceActiveUserAnalytics('sendAnalyticsDataToAWS', startDate);
		    	Database.executeBatch(job, 100);
		} else {
    			BatchContentCountAnalytics job = new BatchContentCountAnalytics('initAnalyticsData', startDate);
			Database.executeBatch(job, 100);
    		}
    }
     
}