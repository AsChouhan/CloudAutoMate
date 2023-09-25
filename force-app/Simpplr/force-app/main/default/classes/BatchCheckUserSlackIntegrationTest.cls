@isTest
private class BatchCheckUserSlackIntegrationTest {
    @TestSetup static void setup(){
        TestHelper.setupAppConfig();
        People__c people = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        List<App_Integration__c> appList = TestHelper.createAppIntegrationRecords(true,new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        List<People_Integration__c> peopleInt = TestHelper.createPeopleIntegrationRecords(appList,people.Id,'');
        peopleInt[0].Name = IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE;
        update peopleInt;

        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('SimpplrSiteTest','Public');
        TestHelper.changeCollaborationGroupOwner(cgroup.id, UserInfo.getUserId());

        List<Simpplr_Site__c> sites = new List<Simpplr_Site__c>();
        sites = [select Id,Name from Simpplr_Site__c];
        sites[0].Slack_Site_Manager__c = people.Id;
        update sites;
    }

    @isTest static void testBatchSlackInt() {
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'slackAuthTest',false));
        Test.startTest();
        BatchCheckUserSlackIntegration job1 = new BatchCheckUserSlackIntegration(false);
            Database.executeBatch(job1,25);
        Test.stopTest();
        List<People__c> people = new List<People__c>();
        people = [select Id from People__c where User__c =: UserInfo.getUserId()];
        List<People_Integration__c> peopleInt = new List<People_Integration__c>();
        peopleInt = [select id  from People_Integration__c where People__c in:people];
        System.assertEquals(0, peopleInt.size() , 'Running as Expected');
    }
}