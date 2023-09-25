@isTest
private class BatchCheckUserServiceNowIntegrationTest {

    @TestSetup static void setup(){
        App_Config__c appConfig = TestHelper.setupAppConfig();
        People__c people = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        List<App_Integration__c> appList = TestHelper.createAppIntegrationRecords(true,new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW});
        List<People_Integration__c> peopleInt = TestHelper.createPeopleIntegrationRecords(appList,people.Id,'');
    }

    @isTest static void testBatchServiceNowIntSucess() {
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/serviceNowDataServer/refreshToken',false));
        Test.startTest();
        BatchCheckUserServiceNowIntegration job1 = new BatchCheckUserServiceNowIntegration(false);
            Database.executeBatch(job1,25);
        Test.stopTest();
        List<People__c> people = new List<People__c>();
        people = [select Id from People__c where User__c =: UserInfo.getUserId()];
        List<People_Integration__c> peopleInt = new List<People_Integration__c>();
        peopleInt = [select id  from People_Integration__c where People__c in:people];
        System.assertEquals(1, peopleInt.size() , 'Running as Expected');
    }

    @isTest static void testBatchServiceNowIntFail() {
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'serviceNowError',false));
        Test.startTest();
        BatchCheckUserServiceNowIntegration job1 = new BatchCheckUserServiceNowIntegration(false);
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