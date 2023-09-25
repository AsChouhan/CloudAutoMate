@isTest
private class SchedulerSimpplrServicesTest {
	public static String CRON_EXP = '0 0 0 15 3 ? 2099';
	@testSetup static void setup() {
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    	appConfigRecord.PDS_Source_Application__c = 'None';
    	update appConfigRecord;
		System.assert(true,'Running as expected');
	}
	@isTest static void testSchedulerSimpplrServices() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
		SchedulerSimpplrServices scheduleJob = new SchedulerSimpplrServices();
		scheduleJob.size = 100;
		scheduleJob.execute(null);
		System.assert(true,'Running as expected');	
		SimpplrContext.PDSSourceApplication = 'UkgPro';
		scheduleJob.execute(null);
		Test.stopTest();
	}

	@isTest static void testCDCHistoricalMigration() {
		Test.startTest();
		String expectedStatus = 'Completed';
		Integer expectedError = 0;
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
		ID jobID = System.enqueueJob(new SchedulerSimpplrServices.CallFutureMethodQueuable('cdcHistoricalMigration'));
		Test.stopTest();
		AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
		System.assertEquals(expectedStatus,jobInfo.Status,'Migration status not completed');
		System.assertEquals(expectedError,jobInfo.NumberOfErrors,'Migration has error');
	}
}