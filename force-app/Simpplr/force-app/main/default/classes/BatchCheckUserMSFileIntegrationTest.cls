@isTest
private class BatchCheckUserMSFileIntegrationTest {
    
    @TestSetup static void setup(){
        App_Config__c appConfig = TestHelper.setupAppConfig();
        People__c people = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        List<App_Integration__c> appList = TestHelper.createAppIntegrationRecords(true,new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT,IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE});
        List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appList,people.Id,'');
        for(People_Integration__c peopleInt : peopleIntList){
            peopleInt.Refresh_Token__c = 'refreshToken';
        }
        update peopleIntList;
    }

    @isTest static void testBatchMSFileIntSucess() {
        String bodyPass = '{"access_token": "at", "token_type": "bearer", "expires_in": "14400", "refresh_token": "rt"}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'MSIntegrationOK',bodyPass,false));
        Test.startTest();
           BatchCheckUserMSFileIntegration job1 = new BatchCheckUserMSFileIntegration(false);
           Database.executeBatch(job1,25);
        Test.stopTest();
        List<People__c> people = new List<People__c>();
        people = [select Id from People__c where User__c =: UserInfo.getUserId()];
        List<People_Integration__c> peopleInt = new List<People_Integration__c>();
        peopleInt = [select id  from People_Integration__c where People__c in:people];
        System.assertEquals(2, peopleInt.size() , 'Running as Expected');
    }

    @isTest static void testBatchMSFileIntFail() {
        String bodyFail = '{"error": "invalid_grant", "error_description": "refresh token is invalid or revoked"}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'MSIntegrationError',bodyFail,false));
        Test.startTest();
            BatchCheckUserMSFileIntegration job1 = new BatchCheckUserMSFileIntegration(false);
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