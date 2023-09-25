@isTest
private class SchedulerToRemoveDeletedRecordsTest {
	// CRON expression: midnight on March 15.
	// Because this is a test, job executes immediately after Test.stopTest().
	public static String CRON_EXP = '0 0 0 15 3 ? 2099';
	
	@isTest static void testSchedulerToRemoveDeletedRecords() {
		Test.startTest();
		// Schedule the test job
		String jobId = System.schedule('ScheduleToRemoveDeletedRecords', CRON_EXP, new SchedulerToRemoveDeletedRecords());
		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		// Verify the expressions are the same
		System.assertEquals(CRON_EXP, ct.CronExpression);	
		Test.stopTest();
	}
}