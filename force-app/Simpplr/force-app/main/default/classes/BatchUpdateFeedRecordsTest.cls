@isTest
private class BatchUpdateFeedRecordsTest {
    @testSetup
    private static void setup() {
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
		TestHelper.createPeopleRecordForUser(UserContext.id); 
		User siteMember = TestHelper.createUser('Test_siteMmbr', null, false);
		CollaborationGroup cgroup = TestHelper.createCollaborationGroup('BatchUpdateFeedRecordsTest_Grp1','Public');
	    Simpplr_Site__c	site = TestHelper.getSiteRecordWithName('BatchUpdateFeedRecordsTest_Grp1');
		TestHelper.shareSitesToAllPeople(new List<String>{site.Id});
	    Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test Page', 'Page', 'Submitted', siteMember, site);
        TestDataHandler.insertFeedItem4Content(simpplrContent);
	}
	
	@isTest static void testBatchUpdateFeedRecordsTest() {
		String userId = UserContext.id;
        List<Simpplr_Content__c> listContentId1=[ SELECT id  FROM Simpplr_Content__c where title__c ='simpplr test Page'];
        List<String> listContentId=new List<String>();
        for(Simpplr_Content__c contentObj:listContentId1){
            listContentId.add(contentObj.id);
        }
        List<CollaborationGroup> chatterGroupIdList= [ SELECT id  FROM CollaborationGroup where name ='BatchUpdateFeedRecordsTest_Grp1'];
        BatchUpdateFeedRecords batchJob = new BatchUpdateFeedRecords('moveContent', listContentId, chatterGroupIdList[0].id, 'AccessManagerTest_Grp1', 'public');
		Database.executeBatch(batchJob,100);
		System.assert(true,'Running as expected');
	}
	
}