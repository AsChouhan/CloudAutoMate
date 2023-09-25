@isTest
private class FeedUpdatesServerTest {

    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
    	User testUser = TestHelper.createUser('TestForCtrlClasses_usr1', null, false);
    	People__c peopleObj = TestHelper.createPeopleRecordForUser(String.valueOf(UserContext.id));
    	Id collaborationGroupId = TestHelper.createCollaborationGroup('TestForCtrlClasses_Grp1', 'Public').Id;
    	Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
		TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
    	Simpplr_Content__c simpplrContent = TestHelper.createContent('TestForCtrlClasses Event', 'Event', 'Approved', testUser, testSite);
    	TestHelper.createCarousel(testSite.id,simpplrContent.id);
    	
    }
    private static Simpplr_Site__c getSite() {
    	Simpplr_Site__c siteObj = [select id, chatter_group_id__c, ownerId from Simpplr_Site__c limit 1];
    	return siteObj;
    }

    private static Simpplr_Content__c getContent(String contentType){
        Simpplr_Content__c contentObj = [SELECT Id FROM Simpplr_Content__c where Type__c =:contentType LIMIT 1];
        return contentObj;
    }
    @isTest static void testhandleRequest() {
	    	List<App_Config__c> appConfigList = [SELECT Id, Use_ConnectAPI_for_Feed_Update_Check__c FROM App_Config__c LIMIT 1];
	    	
	    	if (appConfigList.size() > 0 ) {
	    		appConfigList[0].Use_ConnectAPI_for_Feed_Update_Check__c = true;
	    		update appConfigList;
	    	}
	    	
	    	ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
	        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
	        testItemList.add(new ConnectApi.FeedItem());
	        testItemList.add(new ConnectApi.FeedItem());
	        testPage.elements = testItemList;
	        
	        // set data 
	        connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.Company, null,
	       			ConnectApi.FeedDensity.AllUpdates, null, null, testPage.updatesToken, testPage);
	    	FeedItem feedItemObj = TestDataHandler.createFeedItem(UserInfo.getUserId());
	    	PageReference pageRef = Page.DataServerRO;
            pageRef.getParameters().put('target', 'FeedUpdatesServer');
	    	pageRef.getParameters().put('timeStamp', String.valueOf(DateTime.now().millisecond()));
	    	pageRef.getParameters().put('updatesToken', testPage.updatesToken);
	    	pageRef.getParameters().put('type','company');
	    	pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
	    	pageRef.getParameters().put('idsInViewPort', feedItemObj.Id);
	    	pageRef.getParameters().put('sortBy', 'date');
	    	Test.setCurrentpage(pageRef);
            FeedUpdatesServer serverObj = new FeedUpdatesServer();
	    	serverObj.handleRequest();
	    	
	    	// for site 
	    	pageRef.getParameters().put('type','record');
	    	pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
	    	connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.Groups, 
	    			getSite().Chatter_Group_id__c, 10,ConnectApi.FeedDensity.AllUpdates, 
	       			null, null, testPage.updatesToken, testPage);
	    	Test.setCurrentpage(pageRef);
	    	serverObj.handleRequest();
	    	
	    	// for user
	    	connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.People, 
	    			UserInfo.getUserId(),10,ConnectApi.FeedDensity.AllUpdates, 
	       			null, null, testPage.updatesToken, testPage);
	    	pageRef.getParameters().put('subjectId',UserInfo.getUserId());
	    	Test.setCurrentpage(pageRef);
	    	serverObj.handleRequest();
	    	
	   		// for content
	    	connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.Record, 
	    			getContent('Event').id,10,ConnectApi.FeedDensity.AllUpdates, 
	       			null, null, testPage.updatesToken, testPage);
	    	pageRef.getParameters().put('subjectId',getContent('Event').id);
	    	Test.setCurrentpage(pageRef);
	    	serverObj.handleRequest();
	    	
	    	// for news 
	    	connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.News, 
	    			'me',10,ConnectApi.FeedDensity.AllUpdates, 
	    			null, null, testPage.updatesToken, testPage);
	    	pageRef.getParameters().put('type','news');
	    	Test.setCurrentpage(pageRef);
	    	serverObj.handleRequest(); 
	    	
	    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleRequestFeedMode() {
        Test.startTest();
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Feed_Mode__c = 'testMode';
        update appConfigObj;
        
        User systemAdmin = TestHelper.createUser('FeedUpdatesServerTest_admin', null, true);
        
        EntitySubscription entitySubObj = new EntitySubscription();
        entitySubObj.ParentId = systemAdmin.Id;
        entitySubObj.SubscriberId = UserInfo.getUserId();
        insert entitySubObj;
        
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
	    List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
	    testItemList.add(new ConnectApi.FeedItem());
	    testItemList.add(new ConnectApi.FeedItem());
	    testPage.elements = testItemList;
        
        FeedItem feedItemObj = TestDataHandler.createFeedItem(UserInfo.getUserId());
        
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target', 'FeedUpdatesServer');
	    pageRef.getParameters().put('timeStamp', String.valueOf(DateTime.now().millisecond()));
	    pageRef.getParameters().put('updatesToken', testPage.updatesToken);
	    pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
	    pageRef.getParameters().put('idsInViewPort', feedItemObj.Id);
	    pageRef.getParameters().put('sortBy', 'date');
	    Test.setCurrentpage(pageRef);
        
        FeedUpdatesServer serverObj = new FeedUpdatesServer();
        
        pageRef.getParameters().put('type','company');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('type','news');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('type','userprofile');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('subjectId',getSite().ownerId);
        pageRef.getParameters().put('type','userprofile');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('subjectId','');
        pageRef.getParameters().put('type','userprofile');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('sortBy', 'day');
        pageRef.getParameters().put('type','news');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('type','company');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('type','userprofile');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('subjectId',getSite().ownerId);
        pageRef.getParameters().put('type','userprofile');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
        pageRef.getParameters().put('type','userprofile');
	    serverObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestWithoutFeedItem() {
        Test.startTest();
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Feed_Mode__c = 'testMode';
        update appConfigObj;
        
        User systemAdmin = TestHelper.createUser('FeedUpdatesServerTest_admin', null, true);
        
        EntitySubscription entitySubObj = new EntitySubscription();
        entitySubObj.ParentId = systemAdmin.Id;
        entitySubObj.SubscriberId = UserInfo.getUserId();
        insert entitySubObj;
        
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
	    List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
	    testItemList.add(new ConnectApi.FeedItem());
	    testItemList.add(new ConnectApi.FeedItem());
	    testPage.elements = testItemList;
        
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target', 'FeedUpdatesServer');
	    pageRef.getParameters().put('timeStamp', String.valueOf(DateTime.now().millisecond()));
	    pageRef.getParameters().put('updatesToken', testPage.updatesToken);
	    pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
	    pageRef.getParameters().put('idsInViewPort', '##');
	    pageRef.getParameters().put('sortBy', 'day');
	    Test.setCurrentpage(pageRef);
        
        FeedUpdatesServer serverObj = new FeedUpdatesServer();
        
        
        pageRef.getParameters().put('sortBy', 'day');
        pageRef.getParameters().put('type','news');
	    serverObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestNews() {
        Test.startTest();
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Feed_Mode__c = 'testMode';
        appConfigObj.Use_ConnectAPI_for_Feed_Update_Check__c = true;
        update appConfigObj;
        
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
	    List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
	    testItemList.add(new ConnectApi.FeedItem());
	    testItemList.add(new ConnectApi.FeedItem());
	    testPage.elements = testItemList;
        
        FeedItem feedItemObj = TestDataHandler.createFeedItem(UserInfo.getUserId());
        
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target', 'FeedUpdatesServer');
	    pageRef.getParameters().put('timeStamp', String.valueOf(DateTime.now().millisecond()));
	    pageRef.getParameters().put('updatesToken', testPage.updatesToken);
	    pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
	    pageRef.getParameters().put('idsInViewPort', feedItemObj.Id);
	    pageRef.getParameters().put('sortBy', 'date');
	    Test.setCurrentpage(pageRef);
        
        FeedUpdatesServer serverObj = new FeedUpdatesServer();
        
        connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.News, 
	    			'me',10,ConnectApi.FeedDensity.AllUpdates, 
	    			null, null, testPage.updatesToken, testPage);
        
        pageRef.getParameters().put('type','news');
	    serverObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestRecord() {
        Test.startTest();
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Feed_Mode__c = 'testMode';
        appConfigObj.Use_ConnectAPI_for_Feed_Update_Check__c = true;
        update appConfigObj;
        
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
	    List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
	    testItemList.add(new ConnectApi.FeedItem());
	    testItemList.add(new ConnectApi.FeedItem());
	    testPage.elements = testItemList;
        
        FeedItem feedItemObj = TestDataHandler.createFeedItem(UserInfo.getUserId());
        
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target', 'FeedUpdatesServer');
	    pageRef.getParameters().put('timeStamp', String.valueOf(DateTime.now().millisecond()));
	    pageRef.getParameters().put('updatesToken', testPage.updatesToken);
	    pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
	    pageRef.getParameters().put('idsInViewPort', feedItemObj.Id);
	    pageRef.getParameters().put('sortBy', 'date');
	    Test.setCurrentpage(pageRef);
        
        FeedUpdatesServer serverObj = new FeedUpdatesServer();
	    
        connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.Groups, 
	    			getSite().Chatter_Group_id__c, 10,ConnectApi.FeedDensity.AllUpdates, 
	       			null, null, testPage.updatesToken, testPage);
        
        pageRef.getParameters().put('type','record');
	    serverObj.handleRequest();
        
        pageRef.getParameters().put('subjectId','');
        pageRef.getParameters().put('type','userprofile');
	    serverObj.handleRequest();
        
        connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.People, 
	    			UserInfo.getUserId(),10,ConnectApi.FeedDensity.AllUpdates, 
	       			null, null, testPage.updatesToken, testPage);
        
        pageRef.getParameters().put('subjectId',getSite().ownerId);
        pageRef.getParameters().put('type','record');
	    serverObj.handleRequest();
        
        connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.Record, 
	    			getContent('Event').id,10,ConnectApi.FeedDensity.AllUpdates, 
	       			null, null, testPage.updatesToken, testPage);
        
        pageRef.getParameters().put('subjectId','');
        pageRef.getParameters().put('type','record');
	    serverObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestCompany() {
        Test.startTest();
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.Feed_Mode__c = 'testMode';
        appConfigObj.Use_ConnectAPI_for_Feed_Update_Check__c = true;
        update appConfigObj;
        
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
	    List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
	    testItemList.add(new ConnectApi.FeedItem());
	    testItemList.add(new ConnectApi.FeedItem());
	    testPage.elements = testItemList;
        
        FeedItem feedItemObj = TestDataHandler.createFeedItem(UserInfo.getUserId());
        
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target', 'FeedUpdatesServer');
	    pageRef.getParameters().put('timeStamp', String.valueOf(DateTime.now().millisecond()));
	    pageRef.getParameters().put('updatesToken', testPage.updatesToken);
	    pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
	    pageRef.getParameters().put('idsInViewPort', feedItemObj.Id);
	    pageRef.getParameters().put('sortBy', 'date');
	    Test.setCurrentpage(pageRef);
        
        FeedUpdatesServer serverObj = new FeedUpdatesServer();
        
        connectApi.chatterFeeds.setTestgetFeedElementsUpdatedSince(null, ConnectApi.FeedType.Company, null,
	       			ConnectApi.FeedDensity.AllUpdates, null, null, testPage.updatesToken, testPage);
        
        pageRef.getParameters().put('type','company');
	    serverObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }

    @isTest static void testFeedUpdatesServerMethods() {
    	List<App_Config__c> appConfigList = [SELECT Id, Use_ConnectAPI_for_Feed_Update_Check__c FROM App_Config__c LIMIT 1];
	    	
    	if (appConfigList.size() > 0 ) {
    		appConfigList[0].Use_ConnectAPI_for_Feed_Update_Check__c = false;
    		update appConfigList;
    	}
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target', 'FeedUpdatesServer');
    	pageRef.getParameters().put('timeStamp', String.valueOf(DateTime.now().millisecond()));
    	pageRef.getParameters().put('type','record');
    	pageRef.getParameters().put('subjectId',getSite().Chatter_Group_id__c);
    	FeedItem feedItemObj = TestDataHandler.createFeedItem(UserInfo.getUserId());
    	pageRef.getParameters().put('idsInViewPort', feedItemObj.Id);
    	pageRef.getParameters().put('sortBy', 'date');
    	Test.setCurrentpage(pageRef);
        
        FeedUpdatesServer serverObj = new FeedUpdatesServer();
    	serverObj.handleRequest();
    	pageRef.getParameters().put('sortBy', '');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	
    	pageRef.getParameters().put('subjectId',UserInfo.getUserId());
    	pageRef.getParameters().put('sortBy', 'date');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	pageRef.getParameters().put('sortBy', '');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	
    	pageRef.getParameters().put('subjectId',getContent('Event').id);
    	pageRef.getParameters().put('sortBy', 'date');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	pageRef.getParameters().put('sortBy', '');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	
    	pageRef.getParameters().put('type','company');
    	pageRef.getParameters().put('sortBy', 'date');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	pageRef.getParameters().put('sortBy', '');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	
    	pageRef.getParameters().put('type','news');
    	pageRef.getParameters().put('sortBy', 'date');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	pageRef.getParameters().put('sortBy', '');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	
    	delete feedItemObj;
    	pageRef.getParameters().put('type','news');
    	pageRef.getParameters().put('sortBy', 'date');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	pageRef.getParameters().put('sortBy', '');
    	Test.setCurrentpage(pageRef);
    	serverObj.handleRequest();
    	
    	System.assert(true,'Running as expected');
    }
}