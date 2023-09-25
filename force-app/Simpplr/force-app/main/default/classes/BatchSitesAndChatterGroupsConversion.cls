/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class BatchSitesAndChatterGroupsConversion implements Database.Batchable<SObject> {
	
	private String operationType;
	
    public BatchSitesAndChatterGroupsConversion(String operationType) {
        this.operationType = operationType;
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
		String query = 'SELECT Id,Show_In_Simpplr__c from Simpplr_Site__c WHERE Is_Deleted__c = false ';
		
		String whereClause = '';
		if('convertAllToSites'.equalsIgnoreCase(operationType)) {
			whereClause = ' AND Show_In_Simpplr__c = false';
		}
		else if('revertAllToChatterGroups'.equalsIgnoreCase(operationType)) {
			whereClause = 'AND Show_In_Simpplr__c = true';
		}
		
        return Database.getQueryLocator(query + whereClause);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void execute(Database.BatchableContext BC, List<Simpplr_Site__c> siteList){
		try {
			
			for(Simpplr_Site__c siteObj : siteList){
				if('convertAllToSites'.equalsIgnoreCase(operationType)) {
					siteObj.Show_In_Simpplr__c = true ;
					siteObj.Landing_Page__c = 'feed';
					siteObj.Has_Albums__c = false;
					siteObj.Has_Events__c = false;
					siteObj.Has_Pages__c = false;
				}
				else {
					siteObj.Show_In_Simpplr__c = false ;
				}

                siteObj.Last_Edited_DateTime__c = DateTime.now();
			}
			
			update siteList;
			
    	} catch(Exception ex) {
    		Utility.sendBatchFailedExceptionEmail('BatchSitesAndChatterGroupsConversion', ex);
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
    public void finish(Database.BatchableContext BC) {
	    
    }
    
}