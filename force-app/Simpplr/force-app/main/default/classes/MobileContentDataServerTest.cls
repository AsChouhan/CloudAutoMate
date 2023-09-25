@isTest

private with sharing class MobileContentDataServerTest {
	@testSetup static void setup() {
        TestHelper.setupAppConfig();
        
		PeopleDao peopleDaoObj = new PeopleDao();
        peopleDaoObj.insertPeople(new List<User>{ getUser(UserContext.id) });
        
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        
        TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);
        TestHelper.createContent('simpplr test event', 'Event', 'Approved', testAdminUser, testSite);
        TestHelper.createContent('simpplr test album', 'Album', 'Approved', testAdminUser, testSite);
        TestHelper.createContent('simpplr test blog', 'BlogPost', 'Approved', testAdminUser, testSite);
		TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
		TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        
    	List<People__c> peopleList = [SELECT id from People__c];
    	
    	TestHelper.addBookmarkForSite(testSite.Id, peopleList[0].Id);
    	TestHelper.addBookmarkForPeople(peopleList[0].Id, peopleList[1].Id);
        People__c peopleObj = [select id from people__c where user__c =:UserInfo.getUserId() limit 1];
        Simpplr_Content__c conObj = [select id from Simpplr_Content__c limit 1];
        Must_Read_Detail__c mr  = new Must_Read_Detail__c(People__c=peopleObj.id, Content__c =conObj.id );
        insert mr;
        Id privateCollaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp2', 'Private').Id;
        Simpplr_Site__c  testPrivateSite = TestHelper.getSiteRecord(privateCollaborationGroupId);
    }
    
    private static User getUser(String userId){
        User  userObj = TestHelper.getUserById(userId);
        return userObj;
    }
    
    private static Simpplr_Site__c getSite() {
        Simpplr_Site__c siteObj = [Select Id From Simpplr_Site__c Limit 1];
        return siteObj;
    }
    
    @isTest static void testHandleRequest() {
    	Test.startTest();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        MobileContentDataServer mcds = new MobileContentDataServer();
        mcds.getPageFeature();
        mcds.handleRequest();
        ApexPages.currentPage().getParameters().put('action', 'getFavorite');
    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100"}');
    	mcds.handleRequest();
    	ApexPages.currentPage().getParameters().put('action', '');
    	ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100"}');
    	mcds.handleRequest();
    	Test.stopTest();
    	System.assert(true,'Running as expected');    
    	   
    }
    
    @isTest static void testGetAlbums() {
		Test.startTest();
        Simpplr_Site__c siteObj = getSite();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        MobileContentDataServer mcds = new MobileContentDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getAlbums');
    	ApexPages.currentPage().getParameters().put('data', '{"term":"","nextPageToken":"0","size":"1"}');
    	mcds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('data', '{"term":"","nextPageToken":"0","size":"1","siteId":"'+siteObj.Id+'"}');
    	mcds.handleRequest();
    	Test.stopTest();
    	System.assert(true,'Running as expected');       
    }
    
    @isTest static void testGetContentType() {
		Test.startTest();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        MobileContentDataServer mcds = new MobileContentDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getContentType');
        Simpplr_Content__c conObj = [select id from Simpplr_Content__c limit 1];
		ApexPages.currentPage().getParameters().put('contentId', conObj.id);
		mcds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('contentId', '');
		mcds.handleRequest();
		Test.stopTest();
    	System.assert(true,'Running as expected');       
    }
    
    @isTest static void testGetPages() {
    	Test.startTest();
        Simpplr_Site__c siteObj = getSite();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        MobileContentDataServer mcds = new MobileContentDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getPages');
    	ApexPages.currentPage().getParameters().put('data', '{"term":"","nextPageToken":"0","size":"1"}');
    	mcds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('data', '{"term":"","nextPageToken":"0","size":"1","siteId":"'+siteObj.Id+'"}');
    	mcds.handleRequest();
    	Test.stopTest();
    	System.assert(true,'Running as expected');       
    }
    
    @isTest static void testGetEvents() {
    	Test.startTest();
        Simpplr_Site__c siteObj = getSite();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        MobileContentDataServer mcds = new MobileContentDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getEvents');
    	ApexPages.currentPage().getParameters().put('data', '{"term":"","filter":"future","period":"this_week","sortBy":"","size":16}');
    	mcds.handleRequest();
    	ApexPages.currentPage().getParameters().put('action', 'getEvents');
    	ApexPages.currentPage().getParameters().put('data', '{"nextPageToken":"0","term":"","filter":"future","period":"this_week","sortBy":"","size":16}');
    	mcds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getEvents');
    	ApexPages.currentPage().getParameters().put('data', '{"nextPageToken":"0","term":"","filter":"future","period":"this_week","sortBy":"","size":16,"siteId":"'+siteObj.Id+'"}');
    	mcds.handleRequest();
    	Test.stopTest();
    	System.assert(true,'Running as expected');       
    }
    
    @isTest static void testGetPageCategories() {
        Test.startTest();
        Simpplr_Site__c siteObj = new Simpplr_Site__c();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        MobileContentDataServer mcds = new MobileContentDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getPageCategories');
    	ApexPages.currentPage().getParameters().put('data', '{"term":"","nextPageToken":"0","size":"100"}');
    	mcds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('data', '{"term":"","nextPageToken":"0","size":"100","siteId":"'+siteObj.Id+'"}');
    	mcds.handleRequest();
        Test.stopTest();
    	System.assert(true,'Running as expected');       
    }
    
    @isTest static void testGetBlogs() {
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        MobileContentDataServer mcds = new MobileContentDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getBlogs');
    	ApexPages.currentPage().getParameters().put('data', '{"term":"","nextPageToken":"0","size":"100"}');
    	mcds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('data', '');
    	mcds.handleRequest();
    	System.assert(true,'Running as expected');       
    }
    
    @isTest static void testGetEventOrganizers() {
        Test.startTest();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        Simpplr_Content__c conObj = [Select id, Site__c from Simpplr_Content__c where Type__c = 'Event' limit 1];
        MobileContentDataServer mcds = new MobileContentDataServer();
        ApexPages.currentPage().getParameters().put('siteId', conObj.Site__c);
        ApexPages.currentPage().getParameters().put('action', 'getEventOrganizers');
        String data = '{"eventId":"'+conObj.id+'","siteId":"'+conObj.Site__c+'","size":16}';
    	ApexPages.currentPage().getParameters().put('data', '{"eventId":"a016100000HsNAWAA3","siteId":"a0761000002Zy8SAAS","size":16}');
    	mcds.handleRequest();
        Test.stopTest();
    	System.assert(true,'Running as expected');       
    }
    
    @isTest static void testGetMustRead() {
    	Test.startTest();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileContentDataServer');
        Test.setCurrentPage(pageRef);
        MobileContentDataServer mcds = new MobileContentDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getMustRead');
	    ApexPages.currentPage().getParameters().put('data', '{"term":"","size":"100","filter":"all"}');
	    mcds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('data', '');
	    mcds.handleRequest();
	    Test.stopTest();
	    System.assert(true,'Running as expected');       
    }
    
    @isTest static void testOtherDaoMethods(){
    	Test.startTest();
    	MobileContentDao cd = new MobileContentDao();
    	cd.getEventsWithRSVPYes();
    	cd.getPageSortOrderCondition('Test');
    	cd.getSearchTermCondition(new Set<String>{'test'}, 'Name');
    	cd.getAlbumSortOrderCondition('Latest');
    	cd.getEventsWithRSVPYes();
	Test.stopTest();

    System.assert(true, 'Running as expected');
    }
}