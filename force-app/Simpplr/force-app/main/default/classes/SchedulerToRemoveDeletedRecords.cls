public with sharing class SchedulerToRemoveDeletedRecords extends SimpplrScheduler {
	 //public String CRON_EXP = '0 0 0 ? * 1';	
	/*public static String scheduleMe() {   
        return System.schedule('Simpplr - Batch Remove Job', CRON_EXP, new SchedulerToRemoveDeletedRecords());
    }*/
    
    public SchedulerToRemoveDeletedRecords(){
    	CRON_EXP = '0 0 0 ? * 1';
    }
	
	public override void execute(SchedulableContext SC) {     	
    	try{
    		//Remove Simpplr_Metadata Records with deleted status
    		String simpplrMetadataQuery='Select id from Simpplr_Metadata__c where isDeleted__c=true and lastModifiedDate = N_DAYS_AGO:7';
	        BatchRemoveDeletedRecords simpplrMetadataJob = new BatchRemoveDeletedRecords(simpplrMetadataQuery);
	        Database.executeBatch(simpplrMetadataJob,size); 	        
	        //Remove Simpplr_File Records with deleted status
	        String simpplrFileQuery='Select id from Simpplr_File__c where isDeleted__c=true and lastModifiedDate = N_DAYS_AGO:7';
	        BatchRemoveDeletedRecords simpplrFileJob = new BatchRemoveDeletedRecords(simpplrFileQuery);
	        Database.executeBatch(simpplrFileJob,size);	        
    	}catch(Exception ex){
    	}
    }
}