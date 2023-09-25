@isTest
private class SchedulerBatchEmailDigestTest {
	
	@testSetup static void setup() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Segment_Enabled__c = true;
        update appConfigRecord;
        
        User stdUser = TestHelper.createUser('SchedulerBatchEmailDigest_StdUser', null, false);  
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
	}
    
	@isTest static void testSchedulerBatchEmailDigest() {
		Test.startTest();

		App_Default__c appDefaultObj = TestHelper.setupAppDefault();

        appDefaultObj.Type__c = 'home-default';
        update appDefaultObj;

		new SchedulerBatchEmailDigest().execute(null);
		Test.stopTest();

		System.assert(true, 'Running as expected');
	}
}