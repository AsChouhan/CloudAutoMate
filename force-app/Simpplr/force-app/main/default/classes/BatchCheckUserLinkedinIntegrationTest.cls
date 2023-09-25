@isTest
private class BatchCheckUserLinkedinIntegrationTest {
    @TestSetup static void setup(){
        App_Config__c appConfig = TestHelper.setupAppConfig();
        People__c people = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        List<App_Integration__c> appList = TestHelper.createAppIntegrationRecords(true,new Set<String>{IntegrationConstants.INTEGRATION_TYPE_LINKEDIN});
        List<People_Integration__c> peopleInt = TestHelper.createPeopleIntegrationRecords(appList,people.Id,'');
        peopleInt[0].Access_Token_Expiration_Datetime__c = System.now().addDays(-1);
        update peopleInt;
    }

    @isTest static void testBatchLinkedInIntegration() {
        Test.startTest();
        BatchCheckUserLinkedinIntegration job1 = new BatchCheckUserLinkedinIntegration(false);
        Database.executeBatch(job1,100);
        Test.stopTest();
        List<People__c> people = new List<People__c>();
        people = [select Id from People__c where User__c =: UserInfo.getUserId()];
        List<People_Integration__c> peopleInt = new List<People_Integration__c>();
        peopleInt = [select id  from People_Integration__c where People__c in:people];
        System.assertEquals(0, peopleInt.size() , 'Running as Expected');
    }
}