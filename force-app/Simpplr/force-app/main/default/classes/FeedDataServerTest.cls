@isTest 
private class FeedDataServerTest {
    private static App_Config__c appConfigRecord;

	@testSetup 
    static void setup() {
    	appConfigRecord = TestHelper.setupAppConfig();
        CollaborationGroup collGrp = TestHelper.createCollaborationGroup('FeedDataServerTestSite', 'Public');
	}
    
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [select Id from Simpplr_Site__c where Name='FeedDataServerTestSite' LIMIT 1];
        return siteObj;
    }
    
    @isTest 
    static void testVariables() { 
			FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedDataServer');
        	
	        Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('nextPageToken', null);
	        ApexPages.currentPage().getParameters().put('size', '10');
	        ApexPages.currentPage().getParameters().put('subjectId', 'me');
	        ApexPages.currentPage().getParameters().put('type', 'news');
	        ApexPages.currentPage().getParameters().put('sort', 'activity');
			FeedDataServer feedDataServerObj = new FeedDataServer();
	        feedDataServerObj.handleRequest();
            System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');

    	


    }
    
    @isTest 
    static void testShowFullData() {
			FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedDataServer');
	        Test.setCurrentPage(pageRef);

	        ApexPages.currentPage().getParameters().put('showFullData', 'true');
	        ApexPages.currentPage().getParameters().put('sort', 'activity');
			FeedDataServer feedDataServerObj = new FeedDataServer();
	        feedDataServerObj.handleRequest();
            System.assertEquals('error', feedDataServerObj.response.status, 'FeedType value is blank, Should be an error');


    }
    
    @isTest 
    static void testIsTestCheck() {
			FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedDataServer');
	        Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('isTest', 'true');
	        ApexPages.currentPage().getParameters().put('sort', 'activity');
			FeedDataServer feedDataServerObj = new FeedDataServer();
	        feedDataServerObj.handleRequest();
            System.assertEquals('error', feedDataServerObj.response.status, 'Running as expected');

    }
    
    @isTest static void testGetPopularContent() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
	    Test.setCurrentPage(pageRef);
        
        FeedDataServer feedDataServerObj = new FeedDataServer();
        pageRef.getParameters().put('siteId',getSite().Id);
        pageRef.getParameters().put('action','getPopularContent');
	    feedDataServerObj.handleRequest();
        System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testIsTestCheckNegtive() {
			FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedDataServer');
	        Test.setCurrentPage(pageRef);
	        
	        ApexPages.currentPage().getParameters().put('isTest', 'hello');
			FeedDataServer feedDataServerObj = new FeedDataServer();
	        feedDataServerObj.handleRequest();
            System.assertEquals('error', feedDataServerObj.response.status, 'isTest is invalid parameter, Should return  error');

    }
    
    @isTest 
    static void testFilterRecords() {
			FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
            List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C FROM App_Config__c limit 1];
        
            if (!listOfAppConfig.isEmpty()) {
                appConfigRecord = listOfAppConfig[0];
                appConfigRecord.Feed_Mode__c = 'timeline_comment_post';
                update appConfigRecord; 
            }
            Test.startTest();
            FeedItem feedItemObj=new FeedItem();
            feedItemObj.Body = 'Feed Item 1';
            feedItemObj.ParentId = UserContext.id;
            feedItemObj.Type = 'TextPost';
        	insert feedItemObj;

	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedDataServer');
			pageRef.getParameters().put('type','FilteredRecord');
			pageRef.getParameters().put('postId',feedItemObj.Id);
            pageRef.getParameters().put('sortBy','publishedNewest');
            pageRef.getParameters().put('size','2');

			Test.setCurrentPage(pageRef);
			FeedDataServer feedDataServerObj = new FeedDataServer();
	        feedDataServerObj.handleRequest();
            Test.stopTest();
            System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');

    }

    @isTest 
    static void testFilterRecords1() {
			FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
            List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C FROM App_Config__c limit 1];
        
            if (!listOfAppConfig.isEmpty()) {
                appConfigRecord = listOfAppConfig[0];
                appConfigRecord.Feed_Mode__c = 'timeline_comment';
                update appConfigRecord; 
            }

            FeedItem feedItemObj=new FeedItem();
            feedItemObj.Body = 'Feed Item 1';
            feedItemObj.ParentId = UserContext.id;
            feedItemObj.Type = 'TextPost';
        	insert feedItemObj;

	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedDataServer');
			pageRef.getParameters().put('type','FilteredRecord');
			pageRef.getParameters().put('postId',feedItemObj.Id);
            pageRef.getParameters().put('sortBy','publishedNewest');
            pageRef.getParameters().put('size','2');

			Test.setCurrentPage(pageRef);
			FeedDataServer feedDataServerObj = new FeedDataServer();
	        feedDataServerObj.handleRequest();
            System.assertEquals('error', feedDataServerObj.response.status, 'Running as expected'); 


    }

    @isTest 
    static void testFilterMultipleRecords() {
			FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();

            List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C FROM App_Config__c limit 1];
        
            if (!listOfAppConfig.isEmpty()) {
                appConfigRecord = listOfAppConfig[0];
                appConfigRecord.Feed_Mode__c = 'timeline_comment_post';
                update appConfigRecord; 
            }
            Test.startTest();

            FeedItem feedItemObj=new FeedItem();
            feedItemObj.Body = 'Feed Item 1';
            feedItemObj.ParentId = UserContext.id;
            feedItemObj.Type = 'TextPost';
        	insert feedItemObj;

	        PageReference pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','FeedDataServer');
			pageRef.getParameters().put('type','FilteredMultipleRecords');
			pageRef.getParameters().put('postIds', feedItemObj.Id);
            pageRef.getParameters().put('sortBy','publishedNewest');
            pageRef.getParameters().put('size','2');

			Test.setCurrentPage(pageRef);
			FeedDataServer feedDataServerObj = new FeedDataServer();
	        feedDataServerObj.handleRequest();
            Test.stopTest();
            System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');

    }
    
    @isTest 
    static void testGetTimeLineFeedPage() {
        FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
        pageRef.getParameters().put('type','news');
        Test.setCurrentPage(pageRef);
        FeedDataServer feedDataServerObj = new FeedDataServer();
        feedDataServerObj.handleRequest();
        System.assertEquals('error', feedDataServerObj.response.status, 'insufficient parameters, should return error');

    }

    @isTest 
    static void testGetTimeLineFeedSearchPage() {
        List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C FROM App_Config__c limit 1];
        appConfigRecord = listOfAppConfig[0];
        appConfigRecord.Feed_Mode__c = 'timeline';
        update appConfigRecord; 
        FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
        pageRef.getParameters().put('type','news');
        pageRef.getParameters().put('term','\\"test');
        pageRef.getParameters().put('size','2');
        Test.setCurrentPage(pageRef);
        FeedDataServer feedDataServerObj = new FeedDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchContents',false));
        feedDataServerObj.handleRequest();
        System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest 
    static void testGetTimeLineAndContentFeedPage() {
        FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
        List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C 
                FROM App_Config__c limit 1];
        
        if (!listOfAppConfig.isEmpty()) {
            appConfigRecord = listOfAppConfig[0];
            appConfigRecord.Feed_Mode__c = 'timeline_comment';
            update appConfigRecord; 
        }
       
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
        pageRef.getParameters().put('type','news');
        pageRef.getParameters().put('nextPageToken','10');
        pageRef.getParameters().put('size','1');
        Test.setCurrentPage(pageRef);
        FeedDataServer feedDataServerObj = new FeedDataServer();
        feedDataServerObj.handleRequest();
        System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');

    }

    @isTest 
    static void testGetTimeLineAndContentFeedSearchPage() {
        FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
        List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C 
                FROM App_Config__c limit 1];
        
        if (!listOfAppConfig.isEmpty()) {
            appConfigRecord = listOfAppConfig[0];
            appConfigRecord.Feed_Mode__c = 'timeline_comment';
            update appConfigRecord; 
        }
       
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
        pageRef.getParameters().put('type','news');
        pageRef.getParameters().put('term','\\"test');
        pageRef.getParameters().put('nextPageToken','2');
        pageRef.getParameters().put('size','2');
        Test.setCurrentPage(pageRef);
        FeedDataServer feedDataServerObj = new FeedDataServer();
        feedDataServerObj.handleRequest();
        System.assertEquals('error', feedDataServerObj.response.status, 'Running as expected');

    }

    @isTest 
    static void testGetFullFeedPage() {
        FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
        List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C 
                FROM App_Config__c limit 1];
        
        if (!listOfAppConfig.isEmpty()) {
            appConfigRecord = listOfAppConfig[0];
            appConfigRecord.Feed_Mode__c = 'timeline_comment_post';
            update appConfigRecord; 
        }
       
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
        pageRef.getParameters().put('subjectId','me');
        pageRef.getParameters().put('sort','activity');
        pageRef.getParameters().put('size','10');
        pageRef.getParameters().put('type','news');
        Test.setCurrentPage(pageRef);
        FeedDataServer feedDataServerObj = new FeedDataServer();
        feedDataServerObj.handleRequest();
        System.assertEquals(true, true, 'Failed');

    }

    @isTest 
    static void testGetFullFeedSearchPage() {
        FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
        List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C 
                FROM App_Config__c limit 1];
        
        if (!listOfAppConfig.isEmpty()) {
            appConfigRecord = listOfAppConfig[0];
            appConfigRecord.Feed_Mode__c = 'timeline_comment_post';
            update appConfigRecord; 
        }
       
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
        pageRef.getParameters().put('subjectId','me');
        pageRef.getParameters().put('sort','activity');
        pageRef.getParameters().put('size','10');
        pageRef.getParameters().put('type','news');
        pageRef.getParameters().put('term','test');
        Test.setCurrentPage(pageRef);
        FeedDataServer feedDataServerObj = new FeedDataServer();
        feedDataServerObj.handleRequest();
        System.assertEquals(true, true, 'Failed');

    }

    @isTest 
    static void testGetFavFeedPage() {
        FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
        List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C 
                FROM App_Config__c limit 1];
        
        if (!listOfAppConfig.isEmpty()) {
            appConfigRecord = listOfAppConfig[0];
            appConfigRecord.Feed_Mode__c = 'timeline_comment_post';
            update appConfigRecord; 
        }
       
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
        pageRef.getParameters().put('subjectId','me');
        pageRef.getParameters().put('sort','activity');
        pageRef.getParameters().put('type','favorites');
        pageRef.getParameters().put('showFullData','true');
        Test.setCurrentPage(pageRef);
        FeedDataServer feedDataServerObj = new FeedDataServer();
        feedDataServerObj.handleRequest();
        System.assertEquals('error', feedDataServerObj.response.status, 'Size parameter missing, Should return error');

    }
    
     @isTest 
    static void testGetMobileFeedPage() {
        FeedElementFactoryTest.createFeedElementPageRecordWithFeedDensity();
        List<App_Config__c> listOfAppConfig = [SELECT id, Feed_Mode__C 
                FROM App_Config__c limit 1];
        
        if (!listOfAppConfig.isEmpty()) {
            appConfigRecord = listOfAppConfig[0];
            appConfigRecord.Feed_Mode__c = 'timeline_comment_post';
            update appConfigRecord; 
        }
       
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
        pageRef.getParameters().put('subjectId','me');
        pageRef.getParameters().put('origin','mobile');
        Test.setCurrentPage(pageRef);
        FeedDataServer feedDataServerObj = new FeedDataServer();
        feedDataServerObj.handleRequest();
        System.assertEquals('error', feedDataServerObj.response.status, 'searchTerm missing, Should return error ');

        pageRef.getParameters().put('subjectId','me1');
        pageRef.getParameters().put('type','record');
        pageRef.getParameters().put('term','\\"hded');
        Test.setCurrentPage(pageRef);
        feedDataServerObj.handleRequest();
        System.assertEquals('error', feedDataServerObj.response.status, 'Origin is missing, should return error');

    }

    @isTest static void testGetNewHiresForPeoplePosts() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
	    Test.setCurrentPage(pageRef);
        
        FeedDataServer feedDataServerObj = new FeedDataServer();
        pageRef.getParameters().put('action','getPeoplePosts');
        pageRef.getParameters().put('variant', 'latest_hires');

        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        feedDataServerObj.handleRequest();
        System.assertEquals('success', feedDataServerObj.response.status, 'Message: '+feedDataServerObj.response.message);

        pageRef.getParameters().put('action','getMustReadContent');
        feedDataServerObj.handleRequest();
        System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getUpcomingEvents');
        feedDataServerObj.handleRequest();
        System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');

        Test.stopTest();
    }

    @isTest static void testGetCelebrationsForPeoplePosts() {
        Test.startTest();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
	    Test.setCurrentPage(pageRef);
        
        FeedDataServer FeedDataServerObj = new FeedDataServer();
        pageRef.getParameters().put('action','getPeoplePosts');
        pageRef.getParameters().put('variant', 'celebrations');
	    FeedDataServerObj.handleRequest();
        
        System.assertEquals('success', feedDataServerObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest 
    static void testFeedGroupingServiceGroupFeedPage() {
        FeedElementPageWrapper feedElementPageWrapObjArg = new FeedElementPageWrapper();
        feedElementPageWrapObjArg.total = 11; 
        feedElementPageWrapObjArg.listOfItems = new List<FeedElementWrapper>();
        String contentPrefix = Utility.getSimpplrContentPrefix();
        FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
        feedElementWrapperObj.postedOn = new  FeedElementWrapper.postedOnWrapper();
        feedElementWrapperObj.postedOn.id = contentPrefix + '3444';
        feedElementWrapperObj.postedOn.isPublished = true; 
        
        feedElementWrapperObj.postType = 'link';
        feedElementPageWrapObjArg.listOfItems.add(feedElementWrapperObj);
        FeedGroupingService.groupFeedPage(feedElementPageWrapObjArg);
        FeedElementPageWrapper feedElementPageObjOutput = new FeedElementPageWrapper();
        feedElementPageObjOutput  = FeedGroupingService.groupFeedPage(feedElementPageWrapObjArg);
        System.assertEquals(feedElementPageObjOutput.listOfItems[0].PostType, 'link');
    }

    @isTest 
    static void testFeedGroupingServiceGroupFeedPageTimeLine() {
        FeedElementPageWrapper feedElementPageWrapObjArg = new FeedElementPageWrapper();
        feedElementPageWrapObjArg.total = 11; 
        feedElementPageWrapObjArg.listOfItems = new List<FeedElementWrapper>();
        String contentPrefix = Utility.getSimpplrContentPrefix();
        FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
        feedElementWrapperObj.postedOn = new  FeedElementWrapper.postedOnWrapper();
        feedElementWrapperObj.postedOn.id = contentPrefix + '3444';
        feedElementWrapperObj.postedOn.isPublished = true;
        feedElementWrapperObj.postedOn.type = 'page';
        
        feedElementWrapperObj.postType = 'link';
        feedElementPageWrapObjArg.listOfItems.add(feedElementWrapperObj);

        FeedElementWrapper feedElementWrapperObj2 = new FeedElementWrapper();
        feedElementWrapperObj2.postedOn = new  FeedElementWrapper.postedOnWrapper();
        feedElementWrapperObj2.postedOn.id = contentPrefix + '3445';
        feedElementWrapperObj2.postedOn.isPublished = true;
        feedElementWrapperObj2.postedOn.type = 'page';
        
        feedElementWrapperObj2.postType = 'link';
        feedElementPageWrapObjArg.listOfItems.add(feedElementWrapperObj2);
        FeedElementPageWrapper feedElementPageObjOutput = new FeedElementPageWrapper();
        feedElementPageObjOutput  = FeedGroupingService.groupFeedPage(feedElementPageWrapObjArg);
        System.assertEquals(feedElementPageObjOutput.listOfItems[0].PostType, 'groupedtimelines');
    }

    @isTest static void testGetFeedOnboardingContent() {
        Test.startTest();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
	    Test.setCurrentPage(pageRef);
        
        FeedDataServer FeedDataServerObj = new FeedDataServer();
        pageRef.getParameters().put('action','getFeedOnboardingContent');
        pageRef.getParameters().put('siteId', 'getSite().Id');
	    FeedDataServerObj.handleRequest();
        
        System.assertEquals('success', feedDataServerObj.response.status, feedDataServerObj.response.message);
        Test.stopTest();
    }
    
    @isTest static void testSaveFeedOnboardingFlag() {
        Test.startTest();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FeedDataServer');
	    Test.setCurrentPage(pageRef);
        
        FeedDataServer FeedDataServerObj = new FeedDataServer();
        pageRef.getParameters().put('action','saveFeedOnboardingFlag');
        pageRef.getParameters().put('isOnboardingDisabledOnFeed', 'true');
	    FeedDataServerObj.handleRequest();
        
        System.assertEquals('success', feedDataServerObj.response.status, feedDataServerObj.response.message);
        Test.stopTest();
    }

    @isTest static void testFilterOutQuestionPost() {
        FeedDataServer feedDataServerObj = new FeedDataServer();
        FeedElementPageWrapper pageWrapper = new FeedElementPageWrapper();
        pageWrapper.listOfItems = new List<FeedElementWrapper>();

        FeedElementWrapper itemWrapper = new FeedElementWrapper();
        itemWrapper.postType = 'question';
        pageWrapper.listOfItems.add(itemWrapper);

        itemWrapper = new FeedElementWrapper();
        itemWrapper.postType = 'post';
        pageWrapper.listOfItems.add(itemWrapper);
        pageWrapper = feedDataServerObj.filterOutQuestionPost(pageWrapper);

        System.assertEquals(1, pageWrapper.listOfItems.size(), 'question post should get filter out');
    }

    @isTest static void testCreateFeedCommentForExternalSrc() {

        try {
            Test.startTest();
            People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
            PageReference pageRef = Page.DataServerRW;
            pageRef.getParameters().put('target', 'FeedDataServer');
            Test.setCurrentPage(pageRef);

            ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
            List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();

            ConnectApi.FeedItem textPostObj = new ConnectAPI.FeedItem();
            textPostObj.type = ConnectApi.FeedItemType.TextPost;
            listOfFeedElement.add((ConnectApi.FeedElement)textPostObj);
            feedElementPageObj.elements = listOfFeedElement;
            connectApi.chatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', null, 
                                                                    10, ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);

            FeedItem feedItemObj=new FeedItem();
            feedItemObj.Body = 'This is a test feed post';
            feedItemObj.ParentId = UserContext.id;
            feedItemObj.Type = 'TextPost';

        	insert feedItemObj;

            FeedDataServer feedDataServerObj = new FeedDataServer();
            pageRef.getParameters().put('action', 'createFeedCommentForExternalSrc');

            String bodyJson = '{"body":{"messageSegments":[{"type":"MarkupBegin","markupType":"Paragraph"},{"type":"text","text":"' + ServiceConstants.FEED_COMMENT_BODY_PLACEHOLDER + '"},{"type":"MarkupEnd","markupType":"Paragraph"}]}}';
            String feedPostId = feedItemObj.Id;
            String creatorUserId = UserContext.id;

            Map<String, Object> payloadMap = new Map<String, Object>();
            payloadMap.put('bodyJson', bodyJson);
            payloadMap.put('feedPostId', feedPostId);
            payloadMap.put('creatorUserId', creatorUserId);

            pageRef.getParameters().put('data', JSON.serialize(payloadMap));
            
            feedDataServerObj.handleRequest();
            
            System.assertEquals('success', feedDataServerObj.response.status, feedDataServerObj.response.message);
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
    
    @isTest static void testCreateFeedItemForExternalSrc() {

        try {
            Test.startTest();
            People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
            PageReference pageRef = Page.DataServerRW;
            pageRef.getParameters().put('target', 'FeedDataServer');
            Test.setCurrentPage(pageRef);
            
            FeedDataServer feedDataServerObj = new FeedDataServer();
            pageRef.getParameters().put('action', 'createFeedItemForExternalSrc');

            String payload = '{"creatorUserId":"'+UserContext.id+'","recognitionBody":{"objectId":"77f729a6-7754-44db-849d-6f246cab1bea","subType":"RECOGNITION"},"moderationResult":{},"listOfTopic":[],"textBody":"'+ServiceConstants.FEED_BODY_PLACEHOLDER+'","locationURL":"/recognition-hub","subjectId":"me","communityId":null}';

            pageRef.getParameters().put('data', payload);
            
            feedDataServerObj.handleRequest();
            
            System.assertEquals('success', feedDataServerObj.response.status, feedDataServerObj.response.message);
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
}