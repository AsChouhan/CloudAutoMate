@isTest
private class V1ToV2PageRedirectorControllerTest {
	
	static PageReference pageRef;
		
    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
    }	
    @isTest public static void redirectToV2() {
    	setPageParameters();
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Home() {
    	pageRef = new PageReference('/apex/home');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Dashboard() {
    	pageRef = new PageReference('/apex/Dashboard');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2HomeMyDashboard() {
    	pageRef = new PageReference('/apex/HomeMyDashboard');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SiteDetails() {
    	pageRef = new PageReference('/apex/SiteDetails');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SiteNews() {
    	pageRef = new PageReference('/apex/SiteNews');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2News() {
    	pageRef = new PageReference('/apex/News');
        pageRef.getParameters().put('siteId','siteId');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Events() {
    	pageRef = new PageReference('/apex/Events');
        pageRef.getParameters().put('siteId','siteId');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Articleindex() {
    	pageRef = new PageReference('/apex/articleindex');
        pageRef.getParameters().put('siteId','siteId');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Albums() {
    	pageRef = new PageReference('/apex/albums');
        pageRef.getParameters().put('siteId','siteId');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Videos() {
    	pageRef = new PageReference('/apex/videos');
        pageRef.getParameters().put('siteId','siteId');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2TopicExpertise() {
        Topic topicObj = TestHelper.createTopic('TestTopic');
    	pageRef = new PageReference('/apex/TopicExpertise');
        pageRef.getParameters().put('topicId',topicObj.Id);
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2TopicBlogPosts() {
        Topic topicObj = TestHelper.createTopic('TestTopic');
    	pageRef = new PageReference('/apex/TopicBlogPosts');
        pageRef.getParameters().put('topicId',topicObj.Id);
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2TopicFeed() {
        Topic topicObj = TestHelper.createTopic('TestTopic');
    	pageRef = new PageReference('/apex/TopicFeed');
        pageRef.getParameters().put('topicId',topicObj.Id);
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2TopicFiles() {
        Topic topicObj = TestHelper.createTopic('TestTopic');
    	pageRef = new PageReference('/apex/TopicFiles');
        pageRef.getParameters().put('topicId',topicObj.Id);
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Boxlibrary() {
    	pageRef = new PageReference('/apex/boxlibrary');
        pageRef.getParameters().put('siteId','siteId');
        pageRef.getParameters().put('boxFolderId','boxFolderId');
        pageRef.getParameters().put('rootFolderId','rootFolderId');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2BoxFileDetail() {
    	pageRef = new PageReference('/apex/BoxFileDetail');
        pageRef.getParameters().put('boxFolderId','boxFolderId');
        pageRef.getParameters().put('rootFolderId','rootFolderId');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Filedetail() {
        ContentVersion contentVersionObj = TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
        Id collaborationGroupId = TestHelper.createCollaborationGroup('V1ToV2PageRedirectorControllerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        folderObj.External_Folder_Id__c = folderObj.Id;
        update folderObj;
    	pageRef = new PageReference('/apex/filedetail');
        pageRef.getParameters().put('cvId',contentVersionObj.Id);
        pageRef.getParameters().put('folderId',folderObj.Id);
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Library() {
    	pageRef = new PageReference('/apex/library');
        pageRef.getParameters().put('siteId','siteId');
        pageRef.getParameters().put('libraryId','libraryId');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2InternalLibrary() {
        Id collaborationGroupId = TestHelper.createCollaborationGroup('V1ToV2PageRedirectorControllerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        folderObj.External_Folder_Id__c = folderObj.Id;
        update folderObj;
    	pageRef = new PageReference('/apex/internalLibrary');
        pageRef.getParameters().put('siteId',testSite.Id);
        pageRef.getParameters().put('libraryId',folderObj.Id);
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ManageContent() {
    	pageRef = new PageReference('/apex/ManageContent');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2HomeLatest() {
    	pageRef = new PageReference('/apex/HomeLatest');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2HomeFeed() {
    	pageRef = new PageReference('/apex/HomeFeed');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2MyFiles() {
    	pageRef = new PageReference('/apex/MyFiles');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ProfileSites() {
    	pageRef = new PageReference('/apex/ProfileSites');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ProfileFeed() {
    	pageRef = new PageReference('/apex/ProfileFeed');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ProfileAbout() {
    	pageRef = new PageReference('/apex/ProfileAbout');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2Favorites() {
    	pageRef = new PageReference('/apex/Favorites');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ProfileCalendar() {
    	pageRef = new PageReference('/apex/ProfileCalendar');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ProfileBlog() {
    	pageRef = new PageReference('/apex/ProfileBlog');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ProfileConnections() {
    	pageRef = new PageReference('/apex/ProfileConnections');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ProfileMustReads() {
    	pageRef = new PageReference('/apex/ProfileMustReads');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ProfileOrgChart() {
    	pageRef = new PageReference('/apex/ProfileOrgChart');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2ReportingStructure() {
    	pageRef = new PageReference('/apex/ReportingStructure');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SiteDashboard() {
    	pageRef = new PageReference('/apex/SiteDashboard');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SiteEvents() {
    	pageRef = new PageReference('/apex/SiteEvents');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SiteFeed() {
    	pageRef = new PageReference('/apex/SiteFeed');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SitePages() {
    	pageRef = new PageReference('/apex/SitePages');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SiteAlbums() {
    	pageRef = new PageReference('/apex/SiteAlbums');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SiteFiles() {
    	pageRef = new PageReference('/apex/SiteFiles');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2SiteAbout() {
    	pageRef = new PageReference('/apex/SiteAbout');
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest public static void redirectToV2LibraryDetail() {
        ContentVersion contentVersionObj = TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
    	pageRef = new PageReference('/apex/libraryDetail');
        pageRef.getParameters().put('libraryId',contentVersionObj.Id);
    	Test.setCurrentpage(pageRef);
    	new V1ToV2PageRedirectorController().redirectToV2();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testRedirectToNewFilePage() {
        Test.startTest();
        V1ToV2PageRedirectorController obj = new V1ToV2PageRedirectorController();
        obj.redirectToNewFilePage();
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    static void setPageParameters(){
        pageRef = Page.app;
		pageRef.getParameters().put('contentId','contentId');
		pageRef.getParameters().put('siteId','siteId');
		pageRef.getParameters().put('userId','userId');
		pageRef.getParameters().put('topicId','topicId');
		pageRef.getParameters().put('libraryId','libraryId');
		pageRef.getParameters().put('boxFolderId','boxFolderId');
		pageRef.getParameters().put('rootFolderId','rootFolderId');
		pageRef.getParameters().put('fileId','fileId');    	
		pageRef.getParameters().put('folderId','folderId');
		pageRef.getParameters().put('cvId','cvId');
		pageRef.getParameters().put('FId','FId');
		Test.setCurrentpage(pageRef);
    }
}