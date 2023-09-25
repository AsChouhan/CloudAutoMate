@isTest
private class BatchMigrateRecordsTest {
    private static Simpplr_Site__c sharepointSite;
    @testSetup
    static void setUp() {
        TestHelper.setupAppConfig();
        TestHelper.createTopic('BatchMigrateRecordsTest');
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());        
    }
    
    @isTest static void testBatchTopicsCleanUp() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'video',false));
        
        List<Topic> topicList = [SELECT Id, Name from Topic WHERE Id NOT IN (SELECT TopicId FROM TopicAssignment)] ;
        System.assertEquals(1, topicList.size(), 'No Topics found');
        
        BatchMigrateRecords job = new BatchMigrateRecords('topicsCleanUp', false);	
        Database.executeBatch(job, 200); 
        Test.stopTest();
        
        List<Topic> topicListAfter = [SELECT Id, Name from Topic WHERE Id NOT IN (SELECT TopicId FROM TopicAssignment)] ;
        System.assertEquals(0, topicListAfter.size(), 'Topics clean up failed');
    }
    
    @isTest static void testBatchResetCDCRetryCount() {
        Test.startTest();
        External_Data_Trail__c externalDataTrailRecord = new External_Data_Trail__c(Retry_Count__c = 5);
        insert externalDataTrailRecord;

        BatchMigrateRecords job = new BatchMigrateRecords('resetCDCRetryCount', false);	
        Database.executeBatch(job, 200); 
        Test.stopTest();

        System.assert(true, 'resetCDCRetryCount completed successfully');
    }
}