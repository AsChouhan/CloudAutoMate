/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ReportsCtrlTest {
    private static App_Config__c appConfigRecord;

    @testSetup static void setup() {
    	appConfigRecord = TestHelper.setupAppConfig();
        
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        User grpMngr = TestHelper.createUser('Simpplr_grpMngr', null, false);
        
        Segment__c segmentRec = TestHelper.createSegment(peopleObj.Id);
        Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
        TestHelper.createCollaborationGroup('Simpplr_Grp_SiteDataServerTest','Public');
        Simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_SiteDataServerTest');
        TestHelper.shareSitesToAllPeople(new List<String>{siteObj.Id});
        TestHelper.createSiteRole(peopleObj.Id, siteObj.Id, true, true);
        TestHelper.createSiteRole(null, siteObj.Id, false, true);
		Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test Page', 'Page', 'Published', grpMngr, siteObj);
		TestHelper.createRSVPResponse(simpplrContent.id, peopleObj.id, 'Yes');
		TestHelper.createSubscription(null,peopleObj.id,'autofollow');
		
		TestDataHandler.createSocialAnalytics(simpplrContent.id,null, grpMngr.id);
		TestHelper.createSocialAnalyticsForSearch('AccessManagerTest');		
		TestHelper.createContentLike(simpplrContent.id, peopleObj.id);
		TestHelper.createContentShare(simpplrContent.id, peopleObj.id);
		TestHelper.createContentBookmark(simpplrContent.id, peopleObj.id);
        Analytics_Login__c anlyticObj = new Analytics_Login__c();
        anlyticObj.Date__c = system.today().addDays(1);
        anlyticObj.Total_Simpplr_Users__c = 2;
        insert anlyticObj;
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

    private static Simpplr_Site__c getSimpplrSite(String siteName){
        return([select id,chatter_group_id__c  from Simpplr_Site__c where name = :siteName]);
    }
    
    private static Simpplr_Content__c getContent(){
    	return([select id from Simpplr_Content__c limit 1]);
    }
    
    private static People__c getPeople() {
        People__c peopleObj = [Select Id, NPS_Survey_Last_Display_DateTime__c From People__c Limit 1];
        return peopleObj;
    }
    
    @isTest static void testInit1() { 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
        
        pageRef.getParameters().put('data','{"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36","pageURL":"/apex/homealbums","pageName":"homealbums"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('data','{"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('data','###');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        //pageRef.getParameters().put('data','{"from":"2017-01-01","to":"2020-01-02"}');
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        pageRef.getParameters().put('action','getLogins');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPageviews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getAdoption');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getAdoptionCounts');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getAdoptionAverage');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();        
        
        pageRef.getParameters().put('action','getEngagementFeedPosts');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementFeedLikes');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementFeedReplies');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementFeedShares');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentBookmarks');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentLikes');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentPosts');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentPublished');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentReplies');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentShares');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentViews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentTypes');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
  	  	System.assert(true,'Running as expected');  
    }
    
    @isTest static void testInit2() { 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
        
        pageRef.getParameters().put('data','{"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36","pageURL":"/apex/homealbums","pageName":"homealbums"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('data','{"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('data','###');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        //pageRef.getParameters().put('data','{"from":"2017-01-01","to":"2020-01-02"}');
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        pageRef.getParameters().put('action','getLogins');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesmembers');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesviews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesreplies');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSiteslikes');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesposts');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitespublished');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleBookmarks');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleBookmarks_Received');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeoplePublished');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleMentions');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeoplePosts');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleReplies');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleReplies_Received');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleFollowers');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleFollowing');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleLikes');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleLikes_Received');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleShares');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleShares_Received');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceTopicsEndorsements');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceTopicsExpertise');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceTopicsViews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSearch');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();

        pageRef.getParameters().put('action','getContentEngagementCsv');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
  	  	System.assert(true,'Running as expected');  
    }
        
     static String getContentId() {
    		String contentId;
    		List<Simpplr_Content__c> contentList = [select id from Simpplr_Content__c limit 1];
    		if(!contentList.isEmpty()) {
    			contentId = contentList[0].id;
    		}
    		return contentId;
    }
    
    @isTest static void testInit3() {
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
    	
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
    	pageRef.getParameters().put('action','getPerformanceContentBookmarks');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentLikes');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentPosts');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentReplies');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentShares');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentViews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        //pageRef.getParameters().put('data','{"from":"2017-01-01","to":"2020-01-02","contentType":"Page"}');
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        
        pageRef.getParameters().put('action','getPerformanceContentFavorites');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getSiteCounts');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentUseful');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentUnuseful');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('contentType','pages');        
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','getPerformanceContentBookmarks');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentLikes');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentPosts');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentReplies');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentShares');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentViews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getRsvpList');
        pageRef.getParameters().put('contentId',getContentId());
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleFavorites');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleFavorites_Received');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformancePeopleprofile_views');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentFavorites');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentUnuseful');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceContentUseful');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceTopicsFollowers');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPerformanceZeroSearchResults');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getEngagementContentFavorites');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getMustReadHistory');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('siteId', getSimpplrSite('Simpplr_Grp_SiteDataServerTest').Id);
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        String count = analyticsDSObject.siteManagersCount;
    	System.assertEquals('Managers: 1', count, 'Manager count should be 1');

        count = analyticsDSObject.siteMembersCount;
    	System.assertEquals('Members: 2', count, 'Members count should be 2');

        count = analyticsDSObject.siteMembersNFollowersCount;
    	System.assertEquals('Members: 2', count, 'Members count should be 2 as there is no follower');
    }
    
    @isTest static void testInit4() {
    	Subscription__c subscriptionObj = [select id from Subscription__c limit 1];
    	Segment__c segmentObj = [select id from Segment__c limit 1];
        Expertise__c expertiseObj = [Select id From Expertise__c where Display_Name__c='test_Expertise'];
    	PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
    	
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
    	pageRef.getParameters().put('action','getUnassignedUsers');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('segmentId',segmentObj.id);
        pageRef.getParameters().put('action','getSegmentationMembers');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('subscriptionId',subscriptionObj.id);
        pageRef.getParameters().put('action','getSegmentationMembers');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('expertiseId',expertiseObj.id);
        pageRef.getParameters().put('action','getPeopleExpertise');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('subscriptionId',subscriptionObj.id);
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();   
        
        pageRef.getParameters().put('action','getUnassignedSegmentUsers');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();        
        
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testInit5() {
    	
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
    	
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        pageRef.getParameters().put('action','getContentViews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();   
        
        pageRef.getParameters().put('action','getViewsOverTimeCsv');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getAppPageViews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getGovernanceList');
        pageRef.getParameters().put('orderBy','top');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getCampaignShareData');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();  
        
        pageRef.getParameters().put('action','getContentViewsCsv');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('type','test');
        pageRef.getParameters().put('action','getSiteViews');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getContentViewsList');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('orderBy','top');
        pageRef.getParameters().put('action','getContentViewsList');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getContentPopularity');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getSitePopularity');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getSitePublication');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('onlyPublished','true');
        pageRef.getParameters().put('action','getContentPublications');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('onlyPublished','false');
        pageRef.getParameters().put('action','getContentPublications');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getContentViewsTopDepartmentsCsv');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getContentViewsTopLocationsCsv');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getMonthlyReports');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();  
        
        pageRef.getParameters().put('action','getEngagement');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getAdoptionData');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getSearches');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getSearchList');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 

        pageRef.getParameters().put('type','terms');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 

        pageRef.getParameters().put('type','searchesZeroResults');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 

        pageRef.getParameters().put('type','clickThroughTerms');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 

        pageRef.getParameters().put('type','clickThroughTypes');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('type','searches');
        pageRef.getParameters().put('orderBy','top');
        pageRef.getParameters().put('resultType','category');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('orderBy','bottom');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getLoginsList');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 

        pageRef.getParameters().put('action','getAppAdoption');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getEngagementList');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init(); 
        
        pageRef.getParameters().put('action','getViewsList');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('siteId', getSimpplrSite('Simpplr_Grp_SiteDataServerTest').Id);
        pageRef.getParameters().put('action','getSiteViewsTotal');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        pageRef.getParameters().remove('siteId');
        
        pageRef.getParameters().put('action','getContentReferralSources');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getPeopleProfileCompleteness');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getContentViewsByTypeCsv');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getContentViewsOverTimeCsv');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('action','getKnowledgePageCsv');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('filterBy','Department');
        pageRef.getParameters().put('groupBy','week');
        pageRef.getParameters().put('filterValue','Dep');
        pageRef.getParameters().put('resultType','category');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetAudienceMembers() {
        Audience__c audienceObj = [Select Id From Audience__c Limit 1];
        
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
    	
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        pageRef.getParameters().put('audienceId',audienceObj.Id);
        pageRef.getParameters().put('action','getAudienceMembers');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.init();
        
        System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testGetLoginsOverTimeCsv() {
        Segment__c segmentObj = [Select Id From Segment__c Limit 1];
        People_Category__c peopleCategoryObj = new People_Category__c();
        insert peopleCategoryObj;
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();

        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        pageRef.getParameters().put('filterBy','segment');
        pageRef.getParameters().put('filterValue',segmentObj.Id);
        pageRef.getParameters().put('action','getLoginsOverTimeCsv');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('filterBy','category');
        pageRef.getParameters().put('filterValue',peopleCategoryObj.id);
        pageRef.getParameters().put('action','getLoginsOverTimeCsv');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('filterValue','India@@Gurugram');
        pageRef.getParameters().put('filterBy','location');
        pageRef.getParameters().put('action','getLoginsOverTimeCsv');
        analyticsDSObject.init();
        
        System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testGetPeoplePerformance() {
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
    	
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        
        pageRef.getParameters().put('metric','contentPublished');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','favoritesReceived');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','feedPosts');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','likesMade');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','likesReceived');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','profileViews');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','replies');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','repliesFrom');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();

        pageRef.getParameters().put('metric','repliesFrom');
        pageRef.getParameters().put('siteId','dummyId');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','sharesReceived');
        pageRef.getParameters().put('action','getPeoplePerformance');
        analyticsDSObject.init();
        
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void testGetPerformanceContent() {
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
    	
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        
        pageRef.getParameters().put('action','getPerformanceContent');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('orderBy','bottom');
        pageRef.getParameters().put('action','getPerformanceContent');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','popularity');
        pageRef.getParameters().put('action','getPerformanceContent');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('metric','views');
        pageRef.getParameters().put('action','getPerformanceContent');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('orderBy','top');
        pageRef.getParameters().put('action','getPerformanceContent');
        analyticsDSObject.init();
        
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testWhenResultTypeAvailable() {
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl analyticsDSObject= new ReportsCtrl();
    	
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        pageRef.getParameters().put('resultType','department');
        pageRef.getParameters().put('action','getContentViewsList');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('resultType','location');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('resultType','segment');
        analyticsDSObject.init();
        
        pageRef.getParameters().put('resultType','category');
        analyticsDSObject.init();
        
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void testWhenExternalAnalyticsEnabled() {
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.External_Analytics_Enabled__c = true;
        update appConfig;
        
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
    	
        pageRef.getParameters().put('from',string.valueOf(system.today()));
        pageRef.getParameters().put('to',string.valueOf(system.today().addDays(2)));
        pageRef.getParameters().put('action','getAdoptionAverage');
        reportCtrlObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesMembers');
        reportCtrlObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesPosts');
        reportCtrlObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesLikes');
        reportCtrlObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesReplies');
        reportCtrlObject.init();
        
        pageRef.getParameters().put('action','getPerformanceSitesViews');
        reportCtrlObject.init();
        
        System.assert(true, 'Running as expected');
    }
    
    @isTest static void testGetContentPublications() {        
        appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord;
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getContentPublications');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        pageRef.getParameters().put('onlyPublished','true');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getContentPublications',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPeopleProfileCompletenessCsv() {        
        appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getPeopleProfileCompleteness');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getPeopleProfileCompletenessCsv',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPerformanceSitesMembers() {        
        appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getPerformanceSitesMembers');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getPerformanceSitesMembers',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPerformanceTopicsEndorsements() {        
        appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getPerformanceTopicsEndorsements');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getPerformanceSitesMembers',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
     @isTest static void testGetPerformanceSearch() {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getPerformanceSearch');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getPerformanceSearch',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGgetAdoptionAverage() {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getAdoptionAverage');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getAdoptionOverview',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetEngagementFeedPosts () {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getEngagementFeedPosts');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getEngagementFeed',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetEngagementContentTypes() {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getEngagementContentTypes');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getEngagementContentTypes',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetEngagementContent() {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getEngagementContentShares');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getEngagementFeed',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetLoginsOverTimeCsv1() {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getLoginsOverTimeCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getEngagementContentTypes',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetViewsOverTimeCsv() {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getViewsOverTimeCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getViewsOverTime',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetContentViewsCsv() {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getContentViewsCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getEngagementContentTypes',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetContentViewsByTypeCsv() {        
    	appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getContentViewsByTypeCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getEngagementContentTypes',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetContentViewsOverTimeCsv() {
		appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord;         
    	PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getContentViewsOverTimeCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getEngagementContentTypes',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetKnowledgePageCsv() {
        appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord;        
    	PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getKnowledgePageCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getEngagementContentTypes',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetMonthlyReport() {
        appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord;        
    	PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getMonthlyReports');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getMonthlyReport',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetContentViewsList() {
        appConfigRecord = [Select id From App_Config__c where App_Name__c =:'TestAppName'];
		appConfigRecord.External_Analytics_Enabled__c = true;
        update appConfigRecord;        
    	PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getContentViewsList');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViewsList',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testGetContentEngagementCsv () {        
    	 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getContentEngagementCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        pageRef.getParameters().put('groupBy','week');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getContentEngagementCsv',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
     @isTest static void testGetVideoPopularity () {        
    	App_Config__c configObj = [Select id, External_Analytics_Enabled__c From App_Config__c where App_Name__c = 'TestAppName' LIMIT 1];
        configObj.External_Analytics_Enabled__c = true;
        update configObj; 
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getVideoPopularity');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        pageRef.getParameters().put('groupBy','week');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getVideoPopularity',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }
    
    @isTest static void testGetContentEngagement() {        
    	App_Config__c configObj = [Select id, External_Analytics_Enabled__c From App_Config__c where App_Name__c = 'TestAppName' LIMIT 1];
        configObj.External_Analytics_Enabled__c = true;
        update configObj;
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getContentEngagementCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        pageRef.getParameters().put('groupBy','week');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getEngagement',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   } 
    @isTest static void testGetVideoAdoption() {        
    	App_Config__c configObj = [Select id, External_Analytics_Enabled__c From App_Config__c where App_Name__c = 'TestAppName' LIMIT 1];
        configObj.External_Analytics_Enabled__c = true;
        update configObj;
        PageReference pageRef = Page.Reports;
        Test.setCurrentPage(pageRef);
        ReportsCtrl reportCtrlObject= new ReportsCtrl();
        pageRef.getParameters().put('action','getVideoAdoptionCsv');
        pageRef.getParameters().put('from','2017-01-01');
        pageRef.getParameters().put('to','2020-01-02');
        pageRef.getParameters().put('groupBy','week');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'ReportCtrl/getVideoAdoption',false));
        reportCtrlObject.init();
        Test.stopTest();
        System.assert(true,'Running as expected');
   }         
}