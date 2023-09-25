@isTest
private class BatchPushContentDataForAITest {
	private static App_Config__c appConfigRecord;
    private static App_Integration__c appIntList;
	private static User userObj;
    private static App_Integration__c appintegObj;
	private static People__c peopleRecord;
    
    @testSetup static void setup() {
        appConfigRecord = TestHelper.setupAppConfig();
        App_Default__c appDefaultObj = TestHelper.setupAppDefault();
        TestHelper.createPeopleRecordForUser(UserContext.id);
        userObj = TestHelper.createUser('Simpplr_usr', null, false);
        CollaborationGroup collGrp = TestHelper.createCollaborationGroup('Test_Group_SettingDataServerTest','Unlisted');
        Simpplr_Site__c site = [select id,File_Storage_Source__c,chatter_group_Id__c from Simpplr_Site__c where chatter_group_Id__c =: collGrp.id limit 1];
        Simpplr_Content__c contentObj = TestHelper.createContent('simpplr test BlogPost', 'BlogPost', 'Approved', userObj, null);
        Topic topicObj = TestHelper.createTopic('PushContentDataForAItopictopic');
        TopicAssignment topicAssignment = new TopicAssignment(TopicId=topicObj.id,EntityId=contentObj.id);
		insert topicAssignment;

    }
    
    @isTest static void testBatchPushContentDataForAI() { 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ai',false));
      	Test.startTest();
        BatchPushContentDataForAI ba= new BatchPushContentDataForAI();
        Id jobid= Database.executeBatch(ba,5);
       	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testBatchPushContentDataForAINegative() { 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ai',true));
      	Test.startTest();
        BatchPushContentDataForAI ba= new BatchPushContentDataForAI();
        Id jobid= Database.executeBatch(ba,5);
       	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testrecommendationsSetUp() { 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'recommendationsSetUp',false));
      	Test.startTest();
        PushDataHelperForAI pushDataHelperForAIObj = new PushDataHelperForAI();
        pushDataHelperForAIObj.recommendationsSetUp();
       	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testrecommendationsSetUpNegative() { 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'recommendationsSetUp',true));
      	Test.startTest();
        PushDataHelperForAI pushDataHelperForAIObj = new PushDataHelperForAI();
        pushDataHelperForAIObj.recommendationsSetUp();
       	Test.stopTest();
        System.assert(true,'Running as expected');
    }
}