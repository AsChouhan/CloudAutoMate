public with sharing class SchedulerBatchInsertPeopleRecords extends SimpplrScheduler {

	
    public override void execute(SchedulableContext SC) {    	
    	try{
    		logger.logDebug('Inside Execute : ');
    		BatchInsertPeopleRecords job = new BatchInsertPeopleRecords();
			Database.executeBatch(job,size);  		
    	}catch(Exception ex){
    		logger.logError('Error in Batch Insert People Records Scheduler: ', ex);
    	}
    	
		try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    }
}