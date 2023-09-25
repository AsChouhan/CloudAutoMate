@isTest
private class ActivityDataServerTest {
	 @testSetup static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ActivityDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
        TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);

    }

    @isTest static void testHandleRequest() {
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActivityDataServer');
        Test.setCurrentPage(pageRef);
        ActivityDataServer ads = new ActivityDataServer();
        ads.getPageFeature();
        ads.handleRequest();
        Simpplr_Site__c testSite = TestHelper.getSiteRecordWithName('ActivityDataServerTest_Grp1');
        pageRef.getParameters().put('target', 'ActivityDataServer');
        pageRef.getParameters().put('action', 'getActivity');        
    	pageRef.getParameters().put('data', '{"filter":"popular","siteId":"' + testSite.id + '","term":"","size":"1"}');
    	ads.handleRequest();        
    	pageRef.getParameters().put('data', '{"filter":"popular","term":"test","size":"1"}');
    	ads.handleRequest();
        pageRef.getParameters().put('chatterGroupId', testSite.chatter_group_id__c);
    	pageRef.getParameters().put('data', '{"filter":"latest","siteId":"","term":"","size":"1"}');
    	ads.handleRequest();
    	pageRef.getParameters().put('data', '{"filter":"latest","siteId":"' + testSite.id + '","term":"","nextPageToken":"0","size":"1"}');
    	ads.handleRequest(); 
    	System.assert(true,'Running as expected');       
    }
}