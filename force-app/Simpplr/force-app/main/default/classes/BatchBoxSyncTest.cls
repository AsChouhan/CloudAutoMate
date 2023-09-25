@isTest
private class BatchBoxSyncTest {
    @TestSetup static void setup(){
        App_Config__c appConfig = TestHelper.setupAppConfig();
        appConfig.Box_User_Id__c = 'abc';
        update appconfig;
        People__c people = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        People_Preference__c peoplePreference = TestHelper.createPeoplePreference(people.Id);
        peoplePreference.Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(4);
        update peoplePreference;
    }

    @isTest static void testBatchBoxSync() {
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'Box/UserDetails',false));
        Test.startTest();
            BatchBoxSync job1 = new BatchBoxSync('refreshUserToken',false);
            Database.executeBatch(job1,25);
        Test.stopTest();
        People_Preference__c peoplePreference = [select id, Box_Refresh_Token_Expires_At__c from People_Preference__c limit 1];
        System.assertEquals(Datetime.now().addDays(59).date(), peoplePreference.Box_Refresh_Token_Expires_At__c.date(), 'Running as Expected');
    }

    @isTest static void testBatchBoxSyncFail() {
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',403,'Box/UserDetailsFail','Error',false));
        Test.startTest();
            BatchBoxSync job1 = new BatchBoxSync('refreshUserToken',false);
            Database.executeBatch(job1,25);
        Test.stopTest();
        People_Preference__c peoplePreference = [select id,Box_Refresh_Token__c from People_Preference__c limit 1];
        System.assertEquals(null, peoplePreference.Box_Refresh_Token__c, 'Running as Expected');
    }
}