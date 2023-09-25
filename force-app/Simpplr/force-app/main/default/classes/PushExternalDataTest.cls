/**
 * @description       : Test class for PushExternalDataV2, PushExternalDataHelper related classes
 * @author            : simpplr.com
 * @last modified on  : 05-04-2022
**/
@isTest
private class PushExternalDataTest {
  
    @TestSetup
    static void testSetup(){
        ObjectHandler.skipExternalDataPush = false;
        SimpplrContext.isExternalDataSyncEnabled = true;
        
        App_Config__c appConfig = TestHelper.setupAppConfig();
        appConfig.Flow_External_Sync_Enabled__c = true;
        update appConfig;

        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('CollaborationGroup123', 'Public');   
        FeedItem feedItemObj = TestDataHandler.createFeedItem(cgroup.id,'PollPost');
        FeedComment feedCommentObj = TestDataHandler.createFeedComment(feedItemObj.Id);

        User siteOwnr = TestHelper.createUser('Test_siteOwnr', null, false);
        EntitySubscription entitySubcrptionObj = new EntitySubscription(ParentId = siteOwnr.Id, SubscriberId = UserInfo.getUserId());
        insert entitySubcrptionObj;
    }

    @isTest
    static void testPushExternalData(){
        ObjectHandler.skipExternalDataPush = false;
        Test.startTest();
        SimpplrContext.isExternalDataSyncEnabled = true;
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'salesforce_cdc',true));

        Map<Id, External_Data_Trail__c> mapTrailRecords = new Map<Id, External_Data_Trail__c>([SELECT Id FROM External_Data_Trail__c]);
        System.assertEquals(false, mapTrailRecords.isEmpty(), 'External data trail records created successfully!');

        PushExternalDataV2.pushData(new List<Id>(mapTrailRecords.keySet()));
        PushExternalDataHelper.deleteTrails(new List<String>{(String)mapTrailRecords.values()[0].Id});
        
        Test.stopTest();
    }

    @isTest
    static void testBatchPushExternalData(){
        ObjectHandler.skipExternalDataPush = false;
        
        Test.startTest();
        
        SimpplrContext.isExternalDataSyncEnabled = true;

        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'salesforce_cdc',true));
        
        BatchPushExternalData batchObj = new BatchPushExternalData(true);
        Database.executeBatch(batchObj, 100);
        
        Map<Id, External_Data_Trail__c> mapTrailRecords = new Map<Id, External_Data_Trail__c>([SELECT Id FROM External_Data_Trail__c]);
        System.assertEquals(false, mapTrailRecords.isEmpty(), 'External data trail map is empty!');

        Test.stopTest();
    }

    @isTest
    static void testDeleteBatchSync(){
        ObjectHandler.skipExternalDataPush = false;
        List<EntitySubscription> listSubs = [SELECT Id FROM EntitySubscription];
        delete listSubs;
        
        Test.startTest();
        
        SimpplrContext.isExternalDataSyncEnabled = true;

        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'salesforce_cdc',true));
        
        BatchPushExternalData batchObj = new BatchPushExternalData('CDC_HEAVY_CATEGORY_SYNC', true);
        Database.executeBatch(batchObj, 10);
        batchObj.insertExternalDataTrail(new Set<String>{listSubs[0].Id});
        
        Map<Id, External_Data_Trail__c> mapTrailRecords = new Map<Id, External_Data_Trail__c>([SELECT Id FROM External_Data_Trail__c]);
        System.assertEquals(false, mapTrailRecords.isEmpty(), 'External data trail map is empty!');

        Test.stopTest();
    }
}