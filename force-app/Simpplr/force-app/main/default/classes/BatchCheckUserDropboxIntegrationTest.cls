@isTest
private class BatchCheckUserDropboxIntegrationTest {
    
    @TestSetup static void setup(){
        App_Config__c appConfig = TestHelper.setupAppConfig();
        People__c people = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        List<App_Integration__c> appList = TestHelper.createAppIntegrationRecords(true,new Set<String>{IntegrationConstants.INTEGRATION_TYPE_DROPBOX});
        List<People_Integration__c> peopleInt = TestHelper.createPeopleIntegrationRecords(appList,people.Id,'');
        peopleInt[0].Refresh_Token__c = 'refreshToken';
        update peopleInt;
    }

    @isTest static void testBatchDropboxIntSucess() {
        String bodyPass = '{"access_token": "sl", "token_type": "bearer", "expires_in": 14400}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'dropboxOK',bodyPass,false));
        Test.startTest();
            BatchCheckUserDropboxIntegration job1 = new BatchCheckUserDropboxIntegration(false);
            Database.executeBatch(job1,25);
        Test.stopTest();
        List<People__c> people = new List<People__c>();
        people = [select Id from People__c where User__c =: UserInfo.getUserId()];
        List<People_Integration__c> peopleInt = new List<People_Integration__c>();
        peopleInt = [select id  from People_Integration__c where People__c in:people];
        System.assertEquals(1, peopleInt.size() , 'Running as Expected');
    }

    @isTest static void testBatchDropboxIntFail() {
        String bodyFail = '{"error": "invalid_grant", "error_description": "refresh token is invalid or revoked"}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'dropboxError',bodyFail,false));
        Test.startTest();
            BatchCheckUserDropboxIntegration job1 = new BatchCheckUserDropboxIntegration(false);
            Database.executeBatch(job1,25);
        Test.stopTest();
        List<User> users = new List<User>();
        List<People__c> people = new List<People__c>();
        people = [select Id from People__c where User__c =: UserInfo.getUserId()];
        List<People_Integration__c> peopleInt = new List<People_Integration__c>();
        peopleInt = [select id  from People_Integration__c where People__c in:people];
        System.assertEquals(0, peopleInt.size() , 'Running as Expected');
    }
}