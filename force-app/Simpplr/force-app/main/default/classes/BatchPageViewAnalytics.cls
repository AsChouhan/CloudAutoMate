/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchPageViewAnalytics implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {	
    
    public Analytics_PageView__c pageViewObj;
    private static final List<Integer> SYNC_STATUS_SENT = new List<Integer> {1,3,5};
    DateTime startDateTime ;
	DateTime endDateTime ;
	Date startDate ;
	Date endDate ;
	String recordType;
	List<Object> analyticWrapperList;
	
    public BatchPageViewAnalytics(String recordType, Date dateArg){
		startDate = dateArg;
		endDate = dateArg.addDays(1) ;
		this.recordType = recordType;
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);
		
		init();	
	}
	
    public BatchPageViewAnalytics(){
    	
    	endDate = System.today();
		startDate = endDate.addDays(-1);
		
		startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);  
		endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day(), 0, 0, 0);
    	
    	init();
    }
    
    private void init() {
    	pageViewObj = new Analytics_PageView__c();
    	pageViewObj.Date__c = startDate;
    	pageViewObj.Desktop__c = 0;
    	pageViewObj.DesktopApp__c = 0;
    	pageViewObj.Mobile__c = 0;
    	pageViewObj.MobileApp__c = 0;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public Database.QueryLocator start(Database.BatchableContext BC){
		String query;
		
		if('initAnalyticsData'.equalsIgnoreCase(recordType)){
			query = 'Select id, Origin_Desktop_App__c, Origin_Mobile_App__c, Origin_Mobile_Browser__c from Simpplr_Social_Analytics__c  where  (createdDate >=: startDateTime AND createdDate <: endDateTime) And Interaction__c=\'View\'';
		
		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
			query = 'select Id, Date__c, Desktop__c, DesktopApp__c, Mobile__c, MobileApp__c, Sync_Status__c from Analytics_PageView__c where Sync_Status__c !=:SYNC_STATUS_SENT ';
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
    		for(Simpplr_Social_Analytics__c socialAnalObj : (List<Simpplr_Social_Analytics__c >)listOfsObject){
	    		if(socialAnalObj.Origin_Mobile_Browser__c){
	    			pageViewObj.Mobile__c += 1;
	    		} else if(socialAnalObj.Origin_Mobile_App__c){
	    			pageViewObj.MobileApp__c += 1;
	    		} else if(socialAnalObj.Origin_Desktop_App__c){
	    			pageViewObj.DesktopApp__c += 1;
	    		} else {
	    			pageViewObj.Desktop__c += 1;
	    		}
	    	}
    		} else if('sendAnalyticsDataToAWS'.equalsIgnoreCase(recordType)){
    			PushAnalyticsDataHelper analyticsHandler = new PushAnalyticsDataHelper();
    			analyticsHandler.sendAnalticsPageViewListToAWS(listOfsObject);
    		}
	    } catch(Exception ex) {
			Utility.sendBatchFailedExceptionEmail('BatchPageViewAnalytics', ex);
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
	    		saveBatchData();
	    	}
	    	if('initAnalyticsData'.equalsIgnoreCase(recordType)){
	    		BatchPageViewAnalytics job = new BatchPageViewAnalytics('sendAnalyticsDataToAWS', startDate);
	    		Database.executeBatch(job, 100);
	    		
	    	} else {
	    		BatchSearchAnalytics job = new BatchSearchAnalytics('initAnalyticsData', startDate);
		    Database.executeBatch(job, 100);
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
    private void saveBatchData() {
    	try {
	    	insert pageViewObj;
    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchPageViewAnalytics', ex);
    	}
    }
	 
}