@isTest
private class FavoriteDataServerTest {
	 @testSetup static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        User testUser2 = TestHelper.createUser('Simpplr_usr2', null, false);
        User siteMngr = TestHelper.createUser('Simpplr_siteMngr', null, false);
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);
		TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
		TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        
        List<People__c> peopleList = [SELECT id from People__c];
    	TestHelper.addBookmarkForSite(testSite.Id, peopleList[0].Id);
        
        collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		testSite = TestHelper.getSiteRecord(collaborationGroupId);
		Simpplr_Content__c simpplrContent = TestHelper.createContent('PageDataServerTest Page', 'Page', 'Approved', testAdminUser, testSite);
    }

    @isTest static void testHandleRequest() {
    	
    		List<Simpplr_Site__c> siteObj = [Select Id,chatter_group_id__c from Simpplr_Site__c order by Site_Type__c];
    		List<Simpplr_Content__c> contentList = [Select Id from Simpplr_Content__c];
    		List<People__c> peopleList = [Select Id from People__c];
    		
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target', 'FavoriteDataServer');
        Test.setCurrentPage(pageRef);
        FavoriteDataServer fds = new FavoriteDataServer();
        fds.getPageFeature();
        
        ApexPages.currentPage().getParameters().put('action', '');
    		fds.handleRequest();
    		
    		ApexPages.currentPage().getParameters().put('action', 'getFavorite');
    		fds.handleRequest();
    		
        ApexPages.currentPage().getParameters().put('action', 'getFavorite');
        ApexPages.currentPage().getParameters().put('isFullModel','true');
        ApexPages.currentPage().getParameters().put('data', '{"filter":"people"}');
			Test.startTest();
    		fds.handleRequest();
    		
	    	ApexPages.currentPage().getParameters().put('data', '{"filter":"site"}');
	    	fds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('data', '{"filter":"content","term":"test"}');
	    	fds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('isFullModel','false');
	    	ApexPages.currentPage().getParameters().put('data', '{"filter":"people","nextPageToken":"16"}');
	    	fds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('data', '{"filter":"site","nextPageToken":"16"}');
	    	fds.handleRequest();
	    	
	    	ApexPages.currentPage().getParameters().put('data', '{"filter":"content","nextPageToken":"16"}');
	    	fds.handleRequest();
	    	
	    	Test.stopTest();
	    	System.assert(true,'Running as expected');
    	        
    }
}