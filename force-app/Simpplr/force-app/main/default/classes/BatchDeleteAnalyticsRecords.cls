public with sharing class BatchDeleteAnalyticsRecords implements Database.Batchable<SObject> {
	
	private Date startDate;
	private Date endDate;
	private String objectName;
	private Boolean isAllAnalyticsObjectsRecords;
	
    public BatchDeleteAnalyticsRecords(Date startDate, Date endDate, String objectName, Boolean isAllAnalyticsObjectsRecords){
    	this.startDate = startDate;
    	this.endDate = endDate;
		this.objectName = objectName;
		this.isAllAnalyticsObjectsRecords = isAllAnalyticsObjectsRecords;
    }
    
    public database.querylocator start(Database.BatchableContext bc){
    	String query='';
		query = 'Select id from ' + objectName + ' where Date__c >= :startDate And Date__c <= :endDate ';
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
			
			if (!listOfsObject.isEmpty()) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(listOfsObject);
			}
	    	
    	} catch(Exception ex) {
			Utility.sendBatchFailedExceptionEmail('BatchDeleteAnalyticsRecords', ex);
			throw ex;
    	}
    }
    
    public void finish(Database.BatchableContext bc){
    	if(isAllAnalyticsObjectsRecords) {
    		if('Analytics_Content_Count__c'.equalsIgnoreCase(objectName)) {
    			BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Adoption__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
			
	    	} else if('Analytics_Adoption__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Top_Site__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
	    		
	    	} else if('Analytics_Top_Site__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Top_Search__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
				
	    	} else if('Analytics_Top_Search__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Top_People__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
	    		
	    	} else if('Analytics_Top_People__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Top_Content__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
	    		
	    	} else if('Analytics_Top_Content__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_PageView__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
	    		
	    	} else if('Analytics_PageView__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Login__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
	    		
	    	} else if('Analytics_Login__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Feed_Count__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
	    		
			}
			else if('Analytics_Weekly_Content_Readership__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Weekly_Content_Readership__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
	    		
	    	}
			 else if('Analytics_Feed_Count__c'.equalsIgnoreCase(objectName)) {
	    		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, 'Analytics_Top_Topic__c', isAllAnalyticsObjectsRecords);
				Database.executeBatch(job,2000);
	    		
	    	} else if('Analytics_Top_Topic__c'.equalsIgnoreCase(objectName)) {
	    		
	    	}
    	}
    }
}