@isTest
private class AnalyticsLegacyDataServerTest {
	@testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        User grpMngr = TestHelper.createUser('Simpplr_grpMngr', null, false);
        
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('AccessManagerTest_Grp1','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, grpMngr.id,'Admin');
		
		Simpplr_Site__c siteObj = getSimpplrSite();
        TestHelper.shareSitesToAllPeople(new List<String>{siteObj.Id});
		Simpplr_content__c simpplrContent = TestHelper.createContent('album', 'Album', 'Approved', grpMngr, siteObj);
		
		TestDataHandler.createSocialAnalytics(simpplrContent.id,siteObj.id, grpMngr.id);
		TestHelper.createSocialAnalyticsForSearch('AccessManagerTest');
		
		TestHelper.createContentLike(simpplrContent.id, peopleObj.id);
		TestHelper.createContentShare(simpplrContent.id, peopleObj.id);
        
        Bookmark__c bookObj = TestHelper.createContentBookmark(simpplrContent.id, peopleObj.id);
        bookObj.Is_Deleted__c = false;
        bookObj.Simpplr_Site__c = siteObj.id;
        update bookObj;

        Analytics_Login__c anlyticObj = new Analytics_Login__c();
        anlyticObj.Date__c = system.today().addDays(1);
        anlyticObj.Total_Simpplr_Users__c = 2;
        insert anlyticObj;
        
        Analytics_Top_Site__c analyticTopSiteObj = new Analytics_Top_Site__c();
        analyticTopSiteObj.Date__c = system.today();
        analyticTopSiteObj.Site__c = siteObj.id;
        analyticTopSiteObj.Likes__c = 1;
        insert analyticTopSiteObj;

        Simpplr_Social_Analytics__c socialAnalyticsObj = TestHelper.createSocialAnalytics(peopleObj.id);
        socialAnalyticsObj.Interaction__c = 'View';
        socialAnalyticsObj.page_name__c = 'Site Dashboard';
        socialAnalyticsObj.Origin_Mobile_App__c = true;
        socialAnalyticsObj.Origin_Mobile_Browser__c = true;
        socialAnalyticsObj.Origin_Desktop_App__c=false; 
        socialAnalyticsObj.Origin_Native_Mobile_App__c=false;
        socialAnalyticsObj.Simpplr_Site__c = siteObj.id;
        update socialAnalyticsObj;
		
		BatchTopSitesAnalytics job1 = new BatchTopSitesAnalytics(Date.today());
		Database.executeBatch(job1,100);
		BatchAdoptionAnalytics job2 = new BatchAdoptionAnalytics(Date.today());
		Database.executeBatch(job2,2);

        FeedItem feedItemObj = TestDataHandler.createFeedItem(cgroup.id,'PollPost');
        FeedComment feedCommentObj = TestDataHandler.createFeedComment(feedItemObj.Id);
		Like__c likeObj = TestHelper.createFeedLike(feedItemObj.id, feedCommentObj.id, peopleObj.id);
        
        Segment__c segmentRec = TestHelper.createSegment(peopleObj.Id);
        Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
        TestHelper.shareSitesToAllPeople(new List<String>{siteObj.Id});
        TestHelper.createSiteRole(peopleObj.Id, siteObj.Id, true, true);
        TestHelper.createSiteRole(null, siteObj.Id, false, true);
		TestHelper.createRSVPResponse(simpplrContent.id, peopleObj.id, 'Yes');
		TestHelper.createSubscription(null,peopleObj.id,'autofollow');
		
		TestDataHandler.createSocialAnalytics(simpplrContent.id,null, grpMngr.id);
		TestHelper.createSocialAnalyticsForSearch('AccessManagerTest');		
		TestHelper.createContentLike(simpplrContent.id, peopleObj.id);
		TestHelper.createContentShare(simpplrContent.id, peopleObj.id);
		TestHelper.createContentBookmark(simpplrContent.id, peopleObj.id);
        Analytics_Adoption__c adoptionObj = new Analytics_Adoption__c();
        adoptionObj.People__c = peopleObj.id;
        adoptionObj.Desktop__c = 1;
        adoptionObj.DesktopApp__c = 1;
        adoptionObj.Mobile__c = 1;
        adoptionObj.MobileApp__c = 1;
        adoptionObj.Date__c = system.today().addDays(1);
        adoptionObj.Is_Contributor__c = true;
        adoptionObj.Is_Participant__c = true;
        adoptionObj.Is_Observer__c = true;
        insert adoptionObj;
        Analytics_Feed_Count__c feedCountObj = new Analytics_Feed_Count__c();
        feedCountObj.Date__c = system.today().addDays(1);
        insert feedCountObj;
        Analytics_Content_Count__c contentCountObj = new Analytics_Content_Count__c();
        contentCountObj.Date__c = system.today().addDays(1);
        insert contentCountObj;
        Analytics_Top_Site__c topsiteObj = new Analytics_Top_Site__c();
        topsiteObj.Date__c = system.today().addDays(1);
        insert topsiteObj;
        Analytics_Top_People__c topPeopleObj = new Analytics_Top_People__c();
        topPeopleObj.Date__c = system.today().addDays(1);
        topPeopleObj.People__c = peopleObj.id;
        topPeopleObj.Bookmarks_Received__c = 1;
        topPeopleObj.Bookmarks_Made__c = 1;
        topPeopleObj.Content_Published__c = 1;
        topPeopleObj.Feed_Mentions__c = 1;
        topPeopleObj.Posts__c = 1;
        topPeopleObj.Replies_Made__c = 1;
        topPeopleObj.Replies_Received__c = 1;
        topPeopleObj.Followers__c = 1;
        topPeopleObj.Likes_Made__c = 1;
        topPeopleObj.Likes_Received__c = 1;
        topPeopleObj.Shares_Made__c = 1;
        topPeopleObj.Shares_Received__c = 1;
        topPeopleObj.Views_Received__c = 1;
        insert topPeopleObj;
        Analytics_Top_Content__c topContentObj = new Analytics_Top_Content__c();
        topContentObj .content__c = simpplrContent.id;
        topContentObj.Date__c = system.today().addDays(1);
        insert topContentObj;
        Analytics_Top_Search__c topSearchObj = new Analytics_Top_Search__c();
        topSearchObj.Date__c = system.today().addDays(1);
        topSearchObj.Search_Results_Count__c = 0;
        insert topSearchObj;
        Analytics_Top_Topic__c topTopicObj = new Analytics_Top_Topic__c();
        topTopicObj.Date__c = system.today().addDays(1);
        insert topTopicObj;
        Expertise__c expertiseObj = TestHelper.createExpertise('test_Expertise');
        People_Expertise__c pEObj = TestHelper.createPeopleExpertise(expertiseObj, peopleObj);
        People_Expertise_Detail__c pEDObj = TestHelper.createPeopleExpertiseDetail(pEObj, peopleObj);

    }
    
    private static Simpplr_Site__c getSimpplrSite(){
    	 return([select id from Simpplr_Site__c limit 1]);
    }
    
    @isTest static void testhandleRequestAdoption() {
    	Simpplr_Site__c rec = getSimpplrSite();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','{"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36","pageURL":"/apex/app","pageName":"homemydashboard"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('data','###');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"from":"'+string.valueOf(system.today())+'","to":"'+string.valueOf(system.today().addDays(2))+'"}');
        pageRef.getParameters().put('action','getAdoption');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getAdoptionAverage');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();       
        
        pageRef.getParameters().put('action','getAdoptionCounts');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPageviews');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getLogins');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
  	  	System.assert(true,'Running as expected');  
    }
    
    @isTest static void testHandleRequestEngagement() {
    	Simpplr_Site__c rec = getSimpplrSite();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + 
                                    '","to":"' + string.valueOf(system.today().addDays(2)) + '"}');
        
        pageRef.getParameters().put('action','getEngagementFeedPosts');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementFeedLikes');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementFeedReplies');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementFeedShares');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentFavorites');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentLikes');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentPosts');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentPublished');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentReplies');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentShares');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentViews');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentTypes');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true,'Running as expected');  
    }
    
    @isTest static void testHandleRequestPerformance() {
    	Simpplr_Site__c rec = getSimpplrSite();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + 
                                    '","to":"' + string.valueOf(system.today().addDays(2)) + '"}');
        
        pageRef.getParameters().put('action','getPerformanceSitesmembers');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSitesviews');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSitesreplies');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSiteslikes');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSitesposts');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSitespublished');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFavorites');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFavorites_Received');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeoplePublished');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleMentions');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeoplePosts');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleReplies');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleReplies_Received');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFollowers');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFollowing');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleLikes');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleLikes_Received');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleShares');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleprofile_views');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFavorites');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"' + rec.Id + '"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFavorites_Received');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"' + rec.Id + '"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleShares_Received');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true,'Running as expected');  
    }
    
    @isTest static void testHandleRequestPerformanceContent() {
    	Simpplr_Site__c rec = getSimpplrSite();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02"}');
        
        pageRef.getParameters().put('action','getPerformanceContentBookmarks');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentLikes');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentPosts');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentReplies');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentShares');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentViews');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest(); 
        
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","contentType":"Page"}');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','getPerformanceContentLikes');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentPosts');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentReplies');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentShares');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentViews');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentFavorites');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"' + rec.Id + '"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        analyticsLegacyDSObject.getPageFeature();
        
        pageRef.getParameters().put('action','getPerformanceContentFavorites');
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + '","to":"' + string.valueOf(system.today().addDays(2)) + '","siteId":"' + rec.Id + '","contentType": "Page"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentFavorites');
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + '","to":"' + string.valueOf(system.today().addDays(2)) + '","siteId":"' + rec.Id + '"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();        
        
        pageRef.getParameters().put('action','getPerformanceContentUnuseful');
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + '","to":"' + string.valueOf(system.today().addDays(2)) + '","siteId":"' + rec.Id + '","contentType": "Page"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentUnuseful');
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + '","to":"' + string.valueOf(system.today().addDays(2)) + '","siteId":"' + rec.Id + '"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();        
        
        
        pageRef.getParameters().put('action','getPerformanceContentUseful');
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + '","to":"' + string.valueOf(system.today().addDays(2)) + '","siteId":"' + rec.Id + '","contentType": "Page"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentUseful');
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + '","to":"' + string.valueOf(system.today().addDays(2)) + '","siteId":"' + rec.Id + '"}');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();  
        
        System.assert(true,'Running as expected'); 
    }
    
    @isTest static void testHandleRequestPerformanceTopicAndSearch() {
    	Simpplr_Site__c rec = getSimpplrSite();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + 
                                    '","to":"' + string.valueOf(system.today().addDays(2)) + '"}');
        
        pageRef.getParameters().put('action','getPerformanceTopicsFollowers');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceTopicsEndorsements');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceTopicsExpertise');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceTopicsViews');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSearch');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceZeroSearchResults');
        Test.setCurrentPage(pageRef);
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true,'Running as expected'); 
        
    }
    
    @isTest static void testException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','###');
        pageRef.getParameters().put('action','getLogins');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPageviews');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getAdoption');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getAdoptionCounts');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getAdoptionAverage');
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testEngagementFeedException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','###');
        pageRef.getParameters().put('action','getEngagementFeedPosts');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementFeedLikes');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementFeedReplies');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementFeedShares');
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testEngagementContentException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','###');
        pageRef.getParameters().put('action','getEngagementContentFavorites');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentLikes');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentPosts');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentPublished');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentReplies');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentShares');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentViews');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementContentTypes');
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPerformanceSitesException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','###');
        pageRef.getParameters().put('action','getPerformanceSitesmembers');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSitesviews');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSitesreplies');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSiteslikes');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSitesposts');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceSitespublished');
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPerformanceTopicsException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','###');
        pageRef.getParameters().put('action','getPerformanceTopicsEndorsements');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceTopicsExpertise');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceTopicsViews');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceTopicsFollowers');
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPerformancePeopleException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','###');
        pageRef.getParameters().put('action','getPerformancePeopleFavorites');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFavorites_Received');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeoplePublished');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleMentions');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeoplePosts');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleReplies');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleReplies_Received');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFollowers');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleLikes');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleLikes_Received');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleShares');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleShares_Received');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleprofile_views');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformancePeopleFollowing');
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPerformanceContentException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','###');
        pageRef.getParameters().put('action','getPerformanceContentFavorites');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentLikes');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentPosts');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentReplies');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentShares');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentUnuseful');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentUseful');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceContentViews');
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPerformanceSearchException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsLegacyDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsLegacyDataServer analyticsLegacyDSObject= new AnalyticsLegacyDataServer();
        
        pageRef.getParameters().put('data','{"from":"' + string.valueOf(system.today()) + 
                                    '","to":"' + string.valueOf(system.today().addDays(2)) + '"}');
        pageRef.getParameters().put('action','getPerformanceSearch');
        analyticsLegacyDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPerformanceZeroSearchResults');
        analyticsLegacyDSObject.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
}