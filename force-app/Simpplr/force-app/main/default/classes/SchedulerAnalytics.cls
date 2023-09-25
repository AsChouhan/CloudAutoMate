/**
* This schedular will run following batches:
*	 1. BatchSaleforceActiveUserAnalytics
*	 2.	BatchTopSitesAnalytics
*	 3. BatchTopContentsAnalytics
*	 4. BatchContentCountAnalytics
*	 5. BatchContentCountAnalytics
*	 6. BatchSearchAnalytics
*	 7. BatchTopicAnalytics
*	 8. BatchFeedAnalytics
*	 9. BatchPeopleAnalytics 
*	10. BatchAdoptionAnalytics
*	11. BatchLoginAnalytics
*/

public with sharing class SchedulerAnalytics extends SimpplrScheduler {
	
    public override void execute(SchedulableContext SC) {
    	try {
    		DateTime currentTime = DateTime.now();
    		Date startDate = currentTime.date();
    		if(currentTime.hour() < 3) {
    			startDate = startDate.addDays(-1);
			}else if (currentTime.date().day()==1){
				startAdoptionEmailInitBatch(currentTime);
			}
			
    		
    		BatchTopSitesAnalytics siteJob = new BatchTopSitesAnalytics('initAnalyticsData', startDate);
			Database.executeBatch(siteJob, size);

			// Trigger notification between 10:15 AM and 12:15 PM
    		if(currentTime.hour() > 9 && currentTime.hour() < 13 && startDate == SimpplrContext.adoptionEmailNextRunDate && SimpplrContext.enableEmail){
    			BatchAnalyticsNotifications notificationJob = new BatchAnalyticsNotifications('AppManagerAnalytics');
	  			Database.executeBatch(notificationJob, 10);
			
			} else if(startDate > SimpplrContext.adoptionEmailNextRunDate) {
				String appConfigQuery = 'SELECT Id, Adoption_Email_Next_Run_Date__c FROM App_Config__c LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				App_Config__c appConfigRec = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
				Date adoptionEmailNextRunDate = Utility.adoptionEmailNextRunDate();	
				appConfigRec.Adoption_Email_Next_Run_Date__c = adoptionEmailNextRunDate;

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(appConfigRec, new List<Schema.SObjectField>{
					App_Config__c.Adoption_Email_Next_Run_Date__c
				});
			}


    	} catch(Exception ex) {
    		logger.logError('Error in Analytics batch Scheduler: ', ex);
    	}
    	
    	try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
	}
	public void startAdoptionEmailInitBatch(datetime currentTime){
		Integer previousMonthInt = Integer.valueOf(currentTime.addMonths(-1).format('yyyyMM'));
		List<Adoption_Email__c> adoptionEmailObj = [SELECT Id FROM Adoption_Email__c WHERE Adoption_Email_Month__c = :previousMonthInt WITH SECURITY_ENFORCED];
		if(adoptionEmailObj.isEmpty()){
			BatchAdoptionEmail adoptionEmailJob = new BatchAdoptionEmail('initAnalyticsData');
			Database.executeBatch(adoptionEmailJob, 1);
		}
	}
}