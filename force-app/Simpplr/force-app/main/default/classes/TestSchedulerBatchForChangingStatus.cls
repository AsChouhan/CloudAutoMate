@isTest
private class TestSchedulerBatchForChangingStatus {
	public static String CRON_EXP = '0 0 0 15 3 ? 2030';
	@isTest static void test() {
		Test.startTest();
		String jobId = System.schedule('Scheduling ApexClass SchedulerBatchForChangingStatus',
						CRON_EXP, 
                        new SchedulerBatchForChangingStatus());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
								NextFireTime
								FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2030-03-15 00:00:00', String.valueOf(ct.NextFireTime));
      Test.stopTest();

   }
}