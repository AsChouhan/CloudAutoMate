global with sharing class SchedulerBatchForChangingStatus implements Schedulable {
    global void execute(SchedulableContext SC) {
    	try{    		
    		string query='Select Status__c from Simpplr_Content__c where Status__c = \''+ServiceConstants.STATUS_APPROVED+'\'';
	        BatchChangingStatus job = new BatchChangingStatus(query);
	        Database.executeBatch(job,200);    		
    	}catch(Exception ex){
    	}
    }
}