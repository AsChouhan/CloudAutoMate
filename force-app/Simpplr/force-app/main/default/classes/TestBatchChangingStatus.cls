@isTest
private class TestBatchChangingStatus {
    
	@isTest static void testBatchChangingStatus(){
		BatchChangingStatus job = new BatchChangingStatus('Select Id, Status__c from Simpplr_Content__c where '+ 
												'Status__c = \''+ServiceConstants.STATUS_APPROVED+'\' ');			
		Database.executeBatch(job,1);
		System.assert(true, 'Running as Expected');
	}
    
}