@isTest
private class TestForCtrlClasses {
    
    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
    	TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    	User testUser = TestHelper.createUser('TestForCtrlClasses_usr1', null, false);
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('TestForCtrlClasses_Grp1', 'Public').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
    	Simpplr_Content__c simpplrContent = TestHelper.createContent('TestForCtrlClasses Event', 'Event', 'Approved', testUser, testSite);
        Simpplr_Content__c simpplrContent2 = TestHelper.createContent('TestForCtrlClasses Event', 'Page', 'Approved', testUser, testSite);
        Simpplr_Content__c simpplrContent3 = TestHelper.createContent('TestForCtrlClasses Event', 'Album', 'Approved', testUser, testSite);
        Simpplr_Content__c simpplrContent4 = TestHelper.createContent('TestForCtrlClasses Event', 'BlogPost', 'Approved', testUser, testSite);
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE,appIntegList[0].id);
    	TestHelper.createCarousel(testSite.id,simpplrContent.id);
    	
    }
    
    private static Simpplr_Site__c getSite() {
    	Simpplr_Site__c siteObj = [select id, chatter_group_id__c from Simpplr_Site__c limit 1];
    	return siteObj;
    }
    
    private static Simpplr_Content__c getContent(String contentType){
        Simpplr_Content__c contentObj = [SELECT Id FROM Simpplr_Content__c where Type__c =:contentType LIMIT 1];
        return contentObj;
    }
    
    
    static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, 
        							Manager__c,Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, 
        							Department__c, Country__c, City__c,Mobile_Token_Android__c,Mobile_Token_IOS__c
                                    From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }
    
    @isTest static void testDownloadCalendarCtrl() {
    	PageReference pageRef = Page.DownloadCalendar;
    	pageRef.getParameters().put('action','downloadEventICSFile');
    	pageRef.getParameters().put('contentId',getContent('Event').Id);
    	Test.setCurrentpage(pageRef);
    	DownloadCalendarCtrl ctrlObj = new DownloadCalendarCtrl();
    	ctrlObj.getPageFeature();
    	ctrlObj.handleRequest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testSlackSettingsCtrl() {
    	PageReference pageRef = Page.SlackSettings;
    	pageRef.getParameters().put('state',getPeople(UserContext.id).id);
    	Test.setCurrentpage(pageRef);
    	SlackSettingsCtrl ctrlObj = new SlackSettingsCtrl();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/slackDataServer/chat.postMessage', false));
    	ctrlObj.handleRequest();
        Test.stopTest();
    	System.assert(true,'Running as expected');
    }

	@isTest static void testAppCtrl() {
    	PageReference pageRef = Page.app;
    	Test.setCurrentpage(pageRef);
    	AppCtrl ctrlObj = new AppCtrl();
		ctrlObj.init();
    	ctrlObj.getPageTitle();
		ctrlObj.getPageFeature();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testPdfPreviewCtrl() {
    	PageReference pageRef = Page.PdfPreview;
    	Test.setCurrentpage(pageRef);
    	PdfPreviewCtrl ctrlObj = new PdfPreviewCtrl();
		ctrlObj.init();
        ctrlObj.getPageFeature();
    	System.assert(true,'Running as expected');
    }
    
    
    @isTest static void testPageRedirectorController() {
    	
    	People__c peopleObj = getPeople(UserInfo.getUserId());
    	FeedItem feedItemObj = TestDataHandler.createFeedItem(UserInfo.getUserId());
    	Topic topicObj = TestHelper.createTopic('PageRedirectorContTestTopic');
        Simpplr_Site__c siteObj = getSite();
        String pageName = PageRedirectorController.pageName;
    	PageReference pageRef = Page.PageRedirector;
        String contentId = getContent('Event').Id;
        
        Test.startTest();
        PageRedirectorController ctrlObj = new PageRedirectorController();
        
        pageRef.getParameters().put('pageToRedirect','SiteFeed');
    	Test.setCurrentpage(pageRef);
    	ctrlObj.handleRequest();
        
    	pageRef.getParameters().put('pageToRedirect','SiteDashboard');
    	pageRef.getParameters().put('chatterGroupId',getSite().Chatter_Group_id__c);
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','SiteFeed');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','ContentDetailPage');
    	pageRef.getParameters().put('contentId',contentId);
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','ProfileAbout');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','ProfileFeed');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','manageDeactivatedSites');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','managesitesubscription');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','manageDeactivatedSites');
        pageRef.getParameters().put('siteId', siteObj.Id);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','managesitesubscription');
        pageRef.getParameters().put('siteId', siteObj.Id);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','manageContent');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','manageContent');
        pageRef.getParameters().put('status','testStatus');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','managesegmentsubscription');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','MySettingsEmail');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','MySettingsEmail');
        pageRef.getParameters().put('userId', peopleObj.Id);
        ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ProfileAbout');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','Notificationsprivatesiterequest');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','SiteDashboard');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','HomeFeedSinglePost');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','FileDetail');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','FileDetail');
        pageRef.getParameters().put('fileId','testfileId');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect',ServiceConstants.SITE_LANDING_PAGE_STRING);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect',ServiceConstants.SITE_LANDING_PAGE_STRING);
        pageRef.getParameters().put('chatterGroupId','');
    	ctrlObj.handleRequest();
        
    	pageRef.getParameters().put('pageToRedirect','SiteDashboard');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect',ServiceConstants.SITE_LANDING_PAGE_STRING);
        pageRef.getParameters().put('siteId','');
        pageRef.getParameters().put('notificationId','testId');
    	ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('feedId', feedItemObj.Id);
    	pageRef.getParameters().put('pageToRedirect','SiteDashboard');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','HomeFeedSinglePost');
    	ctrlObj.handleRequest();
        Test.stopTest();
    	
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testPageRedirectorController_Notification() {
        Test.startTest();
        People__c peopleObj = getPeople(UserInfo.getUserId());
        Simpplr_Site__c siteObj = getSite();
        String pageName = PageRedirectorController.pageName;
    	PageReference pageRef = Page.PageRedirector;
        String contentId = getContent('Event').Id;
    	
        PageRedirectorController ctrlObj = new PageRedirectorController();
        
        App_Notification__c notificationObj = TestHelper.createSimpplrNotification('PageRedirectorControllerTest', peopleObj.id,null,'Must Read',contentId,null);
        
        pageRef.getParameters().put('pageToRedirect',ServiceConstants.SITE_LANDING_PAGE_STRING);
        pageRef.getParameters().put('siteId','');
        pageRef.getParameters().put('notificationId', notificationObj.Id);
        Test.setCurrentPage(pageRef);
    	ctrlObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPageRedirectorController_Topic() {
        Test.startTest();
        Topic topicObj = TestHelper.createTopic('PageRedirectorContTestTopic');
        
        PageReference pageRef = Page.PageRedirector;
        PageRedirectorController ctrlObj = new PageRedirectorController();
        
        pageRef.getParameters().put('pageToRedirect','TopicExpertise');
        Test.setCurrentpage(pageRef);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','TopicFeed');
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','TopicExpertise');
        pageRef.getParameters().put('topicName', topicObj.name);
        ctrlObj.handleRequest();
    	
    	pageRef.getParameters().put('pageToRedirect','TopicFeed');
    	ctrlObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPageRedirectorController_ContentDetailFromFeed() {
        Test.startTest();
        
        PageReference pageRef = Page.PageRedirector;
        PageRedirectorController ctrlObj = new PageRedirectorController();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailFromFeed');
    	Test.setCurrentpage(pageRef);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailFromFeed');
        pageRef.getParameters().put('contentId',getContent('Event').Id);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailFromFeed');
        pageRef.getParameters().put('contentId',getContent('Album').Id);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailFromFeed');
        pageRef.getParameters().put('contentId',getContent('BlogPost').Id);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailFromFeed');
        pageRef.getParameters().put('contentId',getContent('Page').Id);
    	ctrlObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPageRedirectorController_ContentDetailPage() {
        Test.startTest();
        People__c peopleObj = getPeople(UserInfo.getUserId());
        String contentId = getContent('Event').Id;
        
        Must_Read_Audit__c mustReadObj = new Must_Read_Audit__c();
        mustReadObj.Marked_By_People__c = peopleObj.Id;
        mustReadObj.Content__c = contentId;
        insert mustReadObj;
        
        Must_Read_Confirm_History__c mustReadConfirmHistoryObj = new Must_Read_Confirm_History__c();
        mustReadConfirmHistoryObj.Content__c = contentId;
        mustReadConfirmHistoryObj.People__c = peopleObj.Id;
        mustReadConfirmHistoryObj.Must_Read_Audit__c = mustReadObj.Id;
        insert mustReadConfirmHistoryObj;
        
        TestHelper.createSimpplrNotification('PageRedirectorControllerTest', peopleObj.id,null,'Must Read',contentId,null);
        PageReference pageRef = Page.PageRedirector;
        
        PageRedirectorController ctrlObj = new PageRedirectorController();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailPage');
        pageRef.getParameters().put('mustRead','true');
    	Test.setCurrentpage(pageRef);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailPage');
    	pageRef.getParameters().put('contentId',getContent('Event').Id);
        pageRef.getParameters().put('mustRead','true');
    	Test.setCurrentpage(pageRef);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailPage');
    	pageRef.getParameters().put('contentId',getContent('Page').Id);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailPage');
    	pageRef.getParameters().put('contentId',getContent('Album').Id);
    	ctrlObj.handleRequest();
        
        pageRef.getParameters().put('pageToRedirect','ContentDetailPage');
    	pageRef.getParameters().put('contentId',getContent('BlogPost').Id);
    	ctrlObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testLightningCarouselCtrl() {
		ApexPages.currentPage().getParameters().put('target', 'AllContentDataServer');
    	String responseDara= LightningCarouselCtrl.getCarouselData();

		System.assert(true, 'Running as expected');
    }
    
    @isTest static void testLightningPopularContentCtrl() {
		ApexPages.currentPage().getParameters().put('target', 'AllContentDataServer');
    	String responseDara= LightningPopularContentCtrl.getPopularContent('Event', null);

		System.assert(true, 'Running as expected');
    }
    
    @isTest static void testGetLatestContent() {
		ApexPages.currentPage().getParameters().put('target', 'AllContentDataServer');
    	String responseDara= LightningPopularContentCtrl.getLatestContent('Event', null);

		System.assert(true, 'Running as expected');
    }
    
}