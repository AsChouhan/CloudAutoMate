/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchSearchAnalytics implements Database.Batchable<SObject>, Database.AllowsCallouts {
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
    DateTime startDateTime ;
	DateTime endDateTime ;
	Date startDate ;
	Date endDate ;
	String recordType;
	List<Object> analyticWrapperList;
	
    public BatchSearchAnalytics (String recordType, Date dateArg){
		startDate = dateArg;
		endDate = dateArg.addDays(1);
		this.recordType = recordType;
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
	
	public BatchSearchAnalytics (){
		
		endDate = System.today();
		startDate = endDate.addDays(-1);
		this.recordType = 'initAnalyticsData';
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);	
	}
    
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query;
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			query = 'Select id, Search_Text__c, Search_Type__c, Simpplr_Site__c, Search_Results_Count__c  From Simpplr_Social_Analytics__c where (createdDate >=: startDateTime AND createdDate <: endDateTime) and Simpplr_Site__c=null And Interaction__c = \'Search Stats\' And Search_Text__c <> NULL';
		
		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
			query = 'select Id, Date__c, Search_Results_Count__c, Search_Text__c, Search_Type__c, Site__c, Sync_Status__c from Analytics_Top_Search__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
		
		} else if('sendAnalyticsSearchSelectDataToAWS'.equalsIgnoreCase(recordType)){
			query = ' select Id, Content__c, Context__c, Created_By_People__c, File_Id__c, Is_External__c, Item_Type__c, People__c, Position__c, Score__c, ' +
                    ' Page_Position__c, Section__c, Site__c, Site_Context__c, Subsection__c, Term__c, CreatedDate, Sync_Status__c ' + 
                    ' from Analytics_Search_Result_Select__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
		}
        return Database.getQueryLocator(query);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void execute(Database.BatchableContext BC, List<sObject> listOfsObject){
	    try {
	    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
				List<Analytics_Top_Search__c> topAnalyticsList = new List<Analytics_Top_Search__c>();
				for(Simpplr_Social_Analytics__c socialAnalObj : (List<Simpplr_Social_Analytics__c>)listOfsObject){
					Analytics_Top_Search__c topSearchAnalObj = new Analytics_Top_Search__c();
					topSearchAnalObj.Search_Text__c = socialAnalObj.Search_Text__c;
					topSearchAnalObj.Date__c = startDate;
					topSearchAnalObj.Site__c = socialAnalObj.Simpplr_Site__c;
					topSearchAnalObj.Search_Results_Count__c = socialAnalObj.Search_Results_Count__c;
					topSearchAnalObj.Search_Type__c = socialAnalObj.Search_Type__c;
					topAnalyticsList.add(topSearchAnalObj);
				}
				if(!topAnalyticsList.isEmpty()){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().insertAsUser(topAnalyticsList, new List<Schema.SObjectField>{
																Analytics_Top_Search__c.Search_Text__c,
																Analytics_Top_Search__c.Date__c,
																Analytics_Top_Search__c.Site__c,
																Analytics_Top_Search__c.Search_Results_Count__c,
																Analytics_Top_Search__c.Search_Type__c
															});
				}
	    	} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
	    		PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    		analyticsHandler.sendAnalticsTopSearchListToAWS(listOfsObject);
	    	
	    	} else if('sendAnalyticsSearchSelectDataToAWS'.equalsIgnoreCase(recordType)){
	    		PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
	    		analyticsHandler.sendAnalticsSearchResultSelectListToAWS(listOfsObject);
	    	}
	    	
    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchSearchAnalytics', ex);
    	}
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void finish(Database.BatchableContext BC){
    	
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			BatchSearchAnalytics job = new BatchSearchAnalytics('sendAnalyticsDataToAWS', startDate);
			Database.executeBatch(job, 1000);
		
		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)) {
			BatchSearchAnalytics job = new BatchSearchAnalytics('sendAnalyticsSearchSelectDataToAWS', startDate);
			Database.executeBatch(job, 1000);
			
		} else {
	    	BatchTopicAnalytics job = new BatchTopicAnalytics('initAnalyticsData', startDate);
		    Database.executeBatch(job, 100);
	    }
    }
}