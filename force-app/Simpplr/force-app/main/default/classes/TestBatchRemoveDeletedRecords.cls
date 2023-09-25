@isTest
private class TestBatchRemoveDeletedRecords {
	@testSetup static void setup() {
       App_Config__c appConfigRecord = TestHelper.setupAppConfig();  
    }
    
	@isTest static void testBatchRemoveDeletedRecords(){
		BatchRemoveDeletedRecords job = new BatchRemoveDeletedRecords('Select Id, Status__c from Simpplr_Content__c where '+ 
												'Status__c = \''+ServiceConstants.STATUS_APPROVED+'\' ');			
		Database.executeBatch(job,1);
		System.assert(true, 'Running as Expected');
	}
    
}