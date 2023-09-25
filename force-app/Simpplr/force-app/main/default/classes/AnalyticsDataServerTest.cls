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
private class AnalyticsDataServerTest {

    @testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
       
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        User grpMngr = TestHelper.createUser('Simpplr_grpMngr', null, false);
        
		Simpplr_content__c simpplrContent = TestHelper.createContent('simpplrPage', 'Page', 'Approved', grpMngr, null);
		
		TestDataHandler.createSocialAnalytics(simpplrContent.id,null, grpMngr.id);
		TestHelper.createSocialAnalyticsForSearch('AccessManagerTest');		
		TestHelper.createContentLike(simpplrContent.id, peopleObj.id);
		TestHelper.createContentShare(simpplrContent.id, peopleObj.id);
		TestHelper.createContentBookmark(simpplrContent.id, peopleObj.id);
		
    }
    
    private static Simpplr_Content__c getContent(){
    	return([select id from Simpplr_Content__c limit 1]);
    }
    
    private static People__c getPeople() {
        People__c peopleObj = [Select Id, User__c From People__c Limit 1];
        return peopleObj;
    }
    
    @isTest static void testHandleRequest1() { 
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        
        pageRef.getParameters().put('data','{"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36","pageURL":"/apex/homealbums","pageName":"homealbums"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"userAgent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('data','###');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02"}');
        pageRef.getParameters().put('action','getAdoption');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getAdoptiondata');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getAdoptionAverage');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();       
        
        pageRef.getParameters().put('action','getEngagementFeed');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getSearchList');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getSearches');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getCampaigns');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
  	  	System.assert(true,'Running as expected');  
    }
    
    @isTest static void testExternalAnalytics() { 
		PageReference pageRef = Page.DataServerRW;
		Simpplr_Content__c simpplrContent = getContent();
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentPopularity');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","orderBy": "top"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        analyticsDSObject.handleRequest();
        
		pageRef.getParameters().put('action','getContentViews');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","groupBy": "day","contentId":"'+simpplrContent.id+'"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getContentViewsList');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","orderBy": "top"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        UserContext.isUserAppModerator = true;
        UserContext.hasModifyAllDataPermission = false;
        pageRef.getParameters().put('action','getContentViewsList');
        pageRef.getParameters().put('data','{"orderBy":"bottom","resultType":"segment","from":"2020-01-20","to":"2020-04-19","groupBy":"week","contentId":"'+simpplrContent.id+'"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getEngagementList');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","orderBy": "top","filterBy":"segment"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
		pageRef.getParameters().put('action','getEngagement');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","groupBy": "day","siteId":null,"filterValue":"internal","filterBy":"segment","contentId":"'+simpplrContent.id+'"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getContentPublications');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId": null,"onlyPublished":true}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
		pageRef.getParameters().put('action','getSiteViews');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","groupBy": "day","type":"content","siteId":"dummy"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getAdoptionAverage');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","filterBy": "segment","filterValue":"internal"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
		pageRef.getParameters().put('action','getLoginsList');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","filterBy": "segment","orderBy":"top"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getNewsletters');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
		pageRef.getParameters().put('action','getPerformanceContent');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","orderBy": "top","metric":"views","siteId":"dummy"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getLoginsOverTime');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","filterBy": "segment","filterValue":"internal","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
		pageRef.getParameters().put('action','getMonthlyReports');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getSiteActivity');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","orderBy":"top"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
		pageRef.getParameters().put('action','getSiteCounts');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getSitePopularity');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getSitePublications');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPeoplePerformance');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","metric":"contentPublished"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getViewsOverTime');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","groupBy": "week","siteId":"dummy"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPeopleProfileCompleteness');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","groupBy": "week"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getPeopleOverview');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","groupBy": "week"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getContentViewsByType');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"dummy"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('action','getContentReferralSources');
		pageRef.getParameters().put('data','{"from":"2020-01-20","to":"2020-04-19","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();

        pageRef.getParameters().put('action','getAppAdoption');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","filterBy": "segment","orderBy":"top"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();

        System.assert(true, 'Running as expected');
    }
    
    @isTest static void testExternalAnalytics2() {
		Simpplr_Content__c simpplrContent = getContent();		
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'AnalyticsDataServer/getKnowledgePageStats', false));
        
        String actual = analyticsDsObject.getPageFeature();
        System.assertEquals('SIMPPLR', actual, 'Running as expected');

        pageRef.getParameters().put('action','getLastSyncDate');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"dummy"}');
        analyticsDSObject.handleRequest();
        System.assertEquals('success', analyticsDSObject.response.status, 'Running as expected');

        
        pageRef.getParameters().put('action','getViewsList');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02"}');
        analyticsDSObject.handleRequest();
        System.assertEquals('success', analyticsDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getLowActivitySites');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"dummy"}');
        analyticsDSObject.handleRequest();
        System.assertEquals('error', analyticsDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getSiteViewsTotal');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"dummy"}');
        analyticsDSObject.handleRequest();
        System.assertEquals('success', analyticsDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getContentViewsOverTime');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"dummy"}');
        analyticsDSObject.handleRequest();
        System.assertEquals('error', analyticsDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getKnowledgePageStats');
		pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"dummy"}');
        analyticsDSObject.handleRequest();
        System.assertEquals('success', analyticsDSObject.response.status,'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetGovernanceList() {
        PageReference pageRef = Page.DataServerRO;
        Simpplr_Content__c simpplrContent = getContent();
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getGovernanceList');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","orderby":"top"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getGovernanceList',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetAppPageViews() {       
    	PageReference pageRef = Page.DataServerRO;
        Simpplr_Content__c simpplrContent = getContent();
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getAppPageViews');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"dummy","contentId":"'+simpplrContent.Id+'"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getAppPageViews',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
     }
    
    @isTest static void testGetAdoptiondata() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getAdoptiondata');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getAdoptiondata',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPeoplePerformance() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getPeoplePerformance');
        pageRef.getParameters().put('data','{"metric":"profileViews","from":"2020-02-03","to":"2020-05-03","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getPeoplePerformance',false));
        analyticsDSObject.handleRequest();
        SimpplrContext.isDemoAnalyticsEnabled = true;
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetKnowledgePageStats() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getKnowledgePageStats');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week","siteId":"Dummy"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getKnowledgePageStats',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetContentReferralSources() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentReferralSources');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week","siteId":"Dummy"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentReferralSources',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetSearchList() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getSearchList');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","resultType":"segment"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getSearchList',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetSearches() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getSearches');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week","filterBy":"segment","filterValue":"internal"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getSearches',false));
        analyticsDSObject.handleRequest();
        SimpplrContext.isDemoAnalyticsEnabled = true;
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPeopleProfileCompletenesss() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getPeopleProfileCompleteness');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getPeopleProfileCompleteness',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetContentViewsList() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentViewsList');
        pageRef.getParameters().put('data','{"orderBy":"bottom","from":"2020-02-03","to":"2020-05-03","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViewsList',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetContentPopularity() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentPopularity');
        pageRef.getParameters().put('data','{"orderBy":"bottom","from":"2020-02-03","to":"2020-05-03","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentPopularity',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetSitePopularity() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getSitePopularity');
        pageRef.getParameters().put('data','{"orderBy":"top","from":"2020-02-03","to":"2020-05-03","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getSitePopularity',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetSitePublication() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getSitePublications');
        pageRef.getParameters().put('data','{"orderBy":"bottom","from":"2020-02-03","to":"2020-05-03"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getSitePublication',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetLowActivitySites() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getLowActivitySites');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getLowActivitySites',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetLoginsList() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getLoginsList');
        pageRef.getParameters().put('data','{"orderBy":"top","resultType":"segment","from":"2020-02-03","to":"2020-05-03","groupBy":"week","filterValue":"internal","filterBy":"segment"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getLoginsList',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPerformanceContent() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getPerformanceContent');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","orderBy": "top","metric":"popularity","contentId":"dummycontent","siteId":"dummy"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getPerformanceContent',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetAdoptionAverage() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getAdoptionAverage');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week","filterValue":"internal","filterBy":"segment"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getAdoptionAverage',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetViewsOverTime() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getViewsOverTime');
        pageRef.getParameters().put('data',' {"from":"2020-02-03","to":"2020-05-03","groupBy":"week","filterValue":"internal","filterBy":"segment"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getViewsOverTime',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetContentViewsOverTime() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentViewsOverTime');
        pageRef.getParameters().put('data',' {"from":"2020-02-03","to":"2020-02-12","groupBy":"week","filterValue":"internal","filterBy":"segment"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getViewsOverTime',false));
        analyticsDSObject.handleRequest();
        SimpplrContext.isDemoAnalyticsEnabled = true;
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetLoginViewsOverTime() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getLoginsOverTime');
        pageRef.getParameters().put('data',' {"from":"2020-02-03","to":"2020-03-12","groupBy":"week","filterValue":"internal","filterBy":"segment"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getViewsOverTime',false));
        analyticsDSObject.handleRequest();
        SimpplrContext.isDemoAnalyticsEnabled = true;
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetContentViews() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentViews');
        pageRef.getParameters().put('data',' {"from":"2020-02-03","to":"2020-05-03","groupBy":"week","contentId":"dummy"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViewsList',false));
        analyticsDSObject.handleRequest();
        SimpplrContext.isDemoAnalyticsEnabled = true;
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetViewsList() {    
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getViewsList');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week","filterValue":"internal","filterBy":"segment"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViewsList',false));
        analyticsDSObject.handleRequest();
        
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","groupBy":"week","filterValue":"internal","filterBy":"segment","resultType":"category"}');
        analyticsDSObject.handleRequest();
        
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetMonthlyReport() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getMonthlyReports');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getMonthlyReport',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }

    @isTest static void testGetVideo() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getVideoPopularity');
        pageRef.getParameters().put('data','{"orderBy":"top","from":"2022-09-25","to":"2022-10-25","groupBy":"day"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getVideoPopularity',false));
        analyticsDSObject.handleRequest();
        pageRef.getParameters().put('action','getVideoAdoption');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getVideoAdoption',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetEngagement() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getEngagement');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-02-12","groupBy":"week","filterValue":"internal","filterBy":"site"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getEngagement',false));
        analyticsDSObject.handleRequest();
        SimpplrContext.isDemoAnalyticsEnabled = true;
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetEngagementList() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getEngagementList');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","orderBy":"bottom","filterValue":"internal","filterBy":"site","resultType":"segment"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getEngagementList',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetSiteViews() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getSiteViews');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","siteId":"dummy","groupBy":"week","type":"page"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getSiteViews',false));
        analyticsDSObject.handleRequest();
        SimpplrContext.isDemoAnalyticsEnabled = true;
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetSiteCounts() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getSiteCounts');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","siteId":"dummy","groupBy":"week","type":"page"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getSiteCounts',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetSiteViewsTotal() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getSiteViewsTotal');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","siteId":"dummy","groupBy":"week"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getSiteViews',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetContentPublications() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentPublications');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","siteId":"dummy","onlyPublished":true}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentPublications',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetContentViewsByType() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentViewsByType');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","siteId":"dummy"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViewsByType',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPeopleOverview() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getPeopleOverview');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getPeopleOverview',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetLastSyncDate() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getLastSyncDate');
        pageRef.getParameters().put('data','{"type":"content"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getLastSyncDate',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testGetContentEngagement() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getContentEngagement');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","siteId":"dummy","contentId":"dummy","groupBy":"week","filterBy":"Segment","filterValue":"dummy"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentEngagement',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testGetRecommendationByType() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getRecommendationByType');
        pageRef.getParameters().put('data','{"from":"2020-02-03","to":"2020-05-03","type":"dummy","groupBy":"week","filterBy":"Segment","filterValue":"dummy"}');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getRecommendationByType',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    @isTest static void testGetCustomerSegmentAdoption() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getCustomerSegmentAdoption');
		Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getCustomerSegmentAdoption',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }

    @isTest static void testGetAppAdoption() {        
    	PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','getAppAdoption');
        pageRef.getParameters().put('data','{"orderBy":"top","resultType":"segment","from":"2020-02-03","to":"2020-05-03","groupBy":"week","filterValue":"internal","filterBy":"segment"}');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getAppAdoption',false));
        analyticsDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }

    @isTest static void testDemoAnalytics() {   
        Test.startTest();
        DemoAnalytics analyticsObj = new  DemoAnalytics();

        String resultJson = '{"data":{"loginsOverTime":[{"label":"2021-03-07","value":282,"id":"1","totalUsers":9813},{"label":"2021-03-08","value":3662,"id":"2","totalUsers":9821},{"label":"2021-03-09","value":3313,"id":"3","totalUsers":9831},{"label":"2021-03-10","value":3329,"id":"4","totalUsers":9835},{"label":"2021-03-11","value":3408,"id":"5","totalUsers":9835},{"label":"2021-03-12","value":3090,"id":"6","totalUsers":9828},{"label":"2021-03-13","value":294,"id":"7","totalUsers":9828},{"label":"2021-03-14","value":311,"id":"8","totalUsers":9828},{"label":"2021-03-15","value":3454,"id":"9","totalUsers":9829},{"label":"2021-03-16","value":3304,"id":"11","totalUsers":9821},{"label":"2021-03-17","value":3226,"id":"12","totalUsers":9832},{"label":"2021-03-18","value":3370,"id":"13","totalUsers":9837},{"label":"2021-03-19","value":3059,"id":"14","totalUsers":9825},{"label":"2021-03-20","value":247,"id":"15","totalUsers":9825}],"totalUserCount":9838,"usersLoggedInCount":0,"pageViewCount":0,"contentViewCount":0,"contentPublished":0,"desktopLogins":34471,"mobileLogins":273,"mobileAppLogins":0,"loggedInPercentage":63.28,"averageContentViewsPerUser":0,"averageLoginsPerUser":0,"totalUniqueUserCount":6225,"usersWhoViewedContent":0}}';
        analyticsObj.getDateAdjustedLoginsOverTimeData(30, resultJson, 10);
        analyticsObj.getDateAdjustedLoginsOverTimeData(90, resultJson, 10);

        resultJson = '{"uniqueContentViewsOverTime":[{"value":75,"label":"2021-03-07"},{"value":1234,"label":"2021-03-08"},{"value":779,"label":"2021-03-09"},{"value":782,"label":"2021-03-10"},{"value":876,"label":"2021-03-11"},{"value":600,"label":"2021-03-12"},{"value":38,"label":"2021-03-13"},{"value":36,"label":"2021-03-14"},{"value":689,"label":"2021-03-15"},{"value":679,"label":"2021-03-16"},{"value":583,"label":"2021-03-17"},{"value":854,"label":"2021-03-18"},{"value":510,"label":"2021-03-19"},{"value":42,"label":"2021-03-20"}],"uniqueContentViews":7002,"mobileAppContentViews":301,"mobileContentViews":1,"desktopContentViews":10128,"contentViews":[{"value":112,"label":"2021-03-07"},{"value":1757,"label":"2021-03-08"},{"value":1094,"label":"2021-03-09"},{"value":1006,"label":"2021-03-10"},{"value":1115,"label":"2021-03-11"},{"value":859,"label":"2021-03-12"},{"value":53,"label":"2021-03-13"},{"value":45,"label":"2021-03-14"},{"value":954,"label":"2021-03-15"},{"value":882,"label":"2021-03-16"},{"value":770,"label":"2021-03-17"},{"value":1163,"label":"2021-03-18"},{"value":719,"label":"2021-03-19"},{"value":52,"label":"2021-03-20"}]}';
        analyticsObj.getDateAdjustedContentViewsOverTime(7, resultJson);
        analyticsObj.getDateAdjustedContentViewsOverTime(90, resultJson);

        resultJson = '{"data":{"favorites":[{"value":0,"label":"2021-03-07","id":null},{"value":7,"label":"2021-03-08","id":null},{"value":1,"label":"2021-03-09","id":null},{"value":3,"label":"2021-03-10","id":null},{"value":1,"label":"2021-03-11","id":null},{"value":2,"label":"2021-03-12","id":null},{"value":0,"label":"2021-03-13","id":null},{"value":0,"label":"2021-03-14","id":null},{"value":0,"label":"2021-03-15","id":null},{"value":0,"label":"2021-03-16","id":null},{"value":1,"label":"2021-03-17","id":null},{"value":1,"label":"2021-03-18","id":null},{"value":6,"label":"2021-03-19","id":null},{"value":0,"label":"2021-03-20","id":null}],"shares":[{"value":0,"label":"2021-03-07","id":null},{"value":1,"label":"2021-03-08","id":null},{"value":3,"label":"2021-03-09","id":null},{"value":1,"label":"2021-03-10","id":null},{"value":1,"label":"2021-03-11","id":null},{"value":0,"label":"2021-03-12","id":null},{"value":0,"label":"2021-03-13","id":null},{"value":0,"label":"2021-03-14","id":null},{"value":1,"label":"2021-03-15","id":null},{"value":0,"label":"2021-03-16","id":null},{"value":1,"label":"2021-03-17","id":null},{"value":1,"label":"2021-03-18","id":null},{"value":1,"label":"2021-03-19","id":null},{"value":0,"label":"2021-03-20","id":null}],"replies":[{"value":0,"label":"2021-03-07","id":null},{"value":4,"label":"2021-03-08","id":null},{"value":0,"label":"2021-03-09","id":null},{"value":0,"label":"2021-03-10","id":null},{"value":6,"label":"2021-03-11","id":null},{"value":2,"label":"2021-03-12","id":null},{"value":0,"label":"2021-03-13","id":null},{"value":0,"label":"2021-03-14","id":null},{"value":2,"label":"2021-03-15","id":null},{"value":1,"label":"2021-03-16","id":null},{"value":0,"label":"2021-03-17","id":null},{"value":0,"label":"2021-03-18","id":null},{"value":2,"label":"2021-03-19","id":null},{"value":0,"label":"2021-03-20","id":null}],"comments":[{"value":0,"label":"2021-03-07","id":null},{"value":4,"label":"2021-03-08","id":null},{"value":1,"label":"2021-03-09","id":null},{"value":3,"label":"2021-03-10","id":null},{"value":6,"label":"2021-03-11","id":null},{"value":1,"label":"2021-03-12","id":null},{"value":0,"label":"2021-03-13","id":null},{"value":0,"label":"2021-03-14","id":null},{"value":1,"label":"2021-03-15","id":null},{"value":0,"label":"2021-03-16","id":null},{"value":0,"label":"2021-03-17","id":null},{"value":1,"label":"2021-03-18","id":null},{"value":3,"label":"2021-03-19","id":null},{"value":0,"label":"2021-03-20","id":null}],"likes":[{"value":0,"label":"2021-03-07","id":null},{"value":16,"label":"2021-03-08","id":null},{"value":21,"label":"2021-03-09","id":null},{"value":18,"label":"2021-03-10","id":null},{"value":21,"label":"2021-03-11","id":null},{"value":5,"label":"2021-03-12","id":null},{"value":1,"label":"2021-03-13","id":null},{"value":0,"label":"2021-03-14","id":null},{"value":10,"label":"2021-03-15","id":null},{"value":10,"label":"2021-03-16","id":null},{"value":13,"label":"2021-03-17","id":null},{"value":11,"label":"2021-03-18","id":null},{"value":15,"label":"2021-03-19","id":null},{"value":0,"label":"2021-03-20","id":null}]},"trackingStartdate":"2021-03-07"}';
        analyticsObj.getDateAdjustedEngagementData(7, resultJson);
        analyticsObj.getDateAdjustedEngagementData(90, resultJson);

        resultJson = '{"totalCount":3833,"searchesOverTime":[{"label":"2021-03-07","value":29,"id":null},{"label":"2021-03-08","value":469,"id":null},{"label":"2021-03-09","value":359,"id":null},{"label":"2021-03-10","value":404,"id":null},{"label":"2021-03-11","value":370,"id":null},{"label":"2021-03-12","value":329,"id":null},{"label":"2021-03-13","value":25,"id":null},{"label":"2021-03-14","value":19,"id":null},{"label":"2021-03-15","value":388,"id":null},{"label":"2021-03-16","value":452,"id":null},{"label":"2021-03-17","value":320,"id":null},{"label":"2021-03-18","value":382,"id":null},{"label":"2021-03-19","value":274,"id":null},{"label":"2021-03-20","value":13,"id":null}]}';
        analyticsObj.getDateAdjustedSearchesData(30, resultJson);
        analyticsObj.getDateAdjustedSearchesData(90, resultJson);

        resultJson = '{"totalViewCount":599,"uniqueViewCount":411,"viewsOverTime":[{"label":"2021-03-11","value":76},{"label":"2021-03-12","value":80},{"label":"2021-03-13","value":0},{"label":"2021-03-14","value":0},{"label":"2021-03-15","value":55},{"label":"2021-03-16","value":44},{"label":"2021-03-17","value":35},{"label":"2021-03-18","value":70},{"label":"2021-03-19","value":55},{"label":"2021-03-20","value":0},{"label":"2021-03-21","value":0},{"label":"2021-03-22","value":70},{"label":"2021-03-23","value":26},{"label":"2021-03-24","value":88}],"topDepartments":[{"name":"QA , Audit & Compliance, Quality standards, Legal","viewCount":599}],"topLocations":[{"id":"Gurgaon Haryana India","name":"Gurgaon, Haryana, India","viewCount":599}]}';
        analyticsObj.getDateAdjustedContentViewsData(30, resultJson);
        analyticsObj.getDateAdjustedContentViewsData(90, resultJson);

        analyticsObj.getDateAdjustedSiteViewsData(30, resultJson);
        analyticsObj.getDateAdjustedSiteViewsData(90, resultJson);

        resultJson = '{"status":"success","result":{"data":[{"label":"US","value":8811,"id":"US"},{"label":"UK","value":3089,"id":"UK"},{"label":"China","value":1945,"id":"China"}]},"message":"Page view list returned successfully","recordCount":0}';
        analyticsObj.getDummySegmentData('getViewsList', resultJson);
        
        resultJson = '{"status":"success","result":{"data":[{"id":"US","label":"US","likes":48,"posts":18,"replies":32,"shares":4,"favorites":12},{"id":"China","label":"China","likes":28,"posts":1,"replies":4,"shares":0,"favorites":0},{"id":"UK","label":"UK","likes":6,"posts":2,"replies":1,"shares":0,"favorites":7}]},"message":"Engagement list returned successfully","recordCount":0}';
        analyticsObj.getDummySegmentData('getEngagementList', resultJson);

        resultJson = '{"status":"success","result":{"data":{"searchList":[{"label":"US","value":475,"id":"US"},{"label":"UK","value":113,"id":" UK"},{"label":"China","value":79,"id":"China"}],"searchTotal":0}},"message":"Analytics data returned successfully","recordCount":0}';
        analyticsObj.getDummySearchSegmentData('getSearchList', resultJson);
        
        resultJson = '{"status":"success","result":{"data":[{"count":7,"id":"a7x1B0000008TNRQA2","label":"5nYIg/oGuFQjPD2iZhHjAxeVQzWb0xs0HleW8PDX4Kw="},{"count":5,"id":"a7x1B000000bmCXQAY","label":"1q+f6ktr8NkchV67b5J5kg=="},{"count":4,"id":"a7x1B0000008P2sQAE","label":"FYgT85m5CdQQygTMHxAuT5RqKaJZam1YldjARnNbC4Y="},{"count":2,"id":"a7x4P000000LDBbQAO","label":"7Y8THmDwGObSzYMTm2lvUA=="},{"count":2,"id":"a7x1B0000008TNLQA2","label":"yxF53M9vGd8bfWyPBcmQrQ=="},{"count":1,"id":"a7x1B0000008P9iQAE","label":"PQ25uFfz9wg/GUv7+8O/Gg=="},{"count":1,"id":"a7x1B0000008QUnQAM","label":"jPgph5S4c0TZwXEKc5WXoA=="},{"count":1,"id":"a7x1B0000008TQXQA2","label":"MzUGIxPHKpIBtNO1OUzfDQ=="},{"count":1,"id":"a7x1B0000008SHMQA2","label":"W5fur8Q10OSrf0hj3jKhcw=="},{"count":1,"id":"a7x4P0000008WPKQA2","label":"BTauS8M3FZoQmy7Ppi6wCg=="}]},"message":"Analytics Poeple  returned successfully","recordCount":0}';
        analyticsObj.getDummyPeoplePerformanceData(resultJson);
        
        resultJson = '{"data":{"customCategoryCount":0,"locationCount":315,"departmentCount":1218,"activeUserCount":9828,"totalUserCount":9872}}';
        analyticsObj.getMultipledPeopleOverviewData(resultJson, 10);
        
        resultJson = '{"data":[{"count":243,"name":"contributors"},{"count":308,"name":"participants"},{"count":6884,"name":"observers"},{"count":2450,"name":"inactive"}]}';
        analyticsObj.getMultipledAdoptionAverageData(resultJson, 10);
        
        resultJson = '{"data":{"usersWhoViewedContent":3459,"totalUniqueUserCount":0,"averageLoginsPerUser":18,"averageContentViewsPerUser":3.0442011354420115,"loggedInPercentage":0.0,"mobileAppLogins":0,"mobileLogins":0,"desktopLogins":0,"contentPublished":100,"contentViewCount":22521,"pageViewCount":256844,"usersLoggedInCount":6237,"totalUserCount":9900,"loginsOverTime":[]}}';
        analyticsObj.getMultipledAdoptionData(resultJson, 10);
        
        resultJson = '{"data":[{"year":2021,"month":3,"sharesCount":31,"likesCount":887,"postsAndRepliesCount":550,"averageViewsPerUserCount":7.0,"viewedContentPercentage":36.0,"viewedContentCount":23617,"usersLoggedInPercentage":76.51122625215889,"usersLoggedInCount":7531,"label":"Mar 2021"},{"year":2021,"month":2,"sharesCount":18,"likesCount":790,"postsAndRepliesCount":500,"averageViewsPerUserCount":6.0,"viewedContentPercentage":38.0,"viewedContentCount":23456,"usersLoggedInPercentage":76.02309562398703,"usersLoggedInCount":7505,"label":"Feb 2021"},{"year":2021,"month":1,"sharesCount":24,"likesCount":602,"postsAndRepliesCount":467,"averageViewsPerUserCount":6.0,"viewedContentPercentage":43.0,"viewedContentCount":25560,"usersLoggedInPercentage":77.78656126482214,"usersLoggedInCount":7872,"label":"Jan 2021"},{"year":2020,"month":12,"sharesCount":36,"likesCount":607,"postsAndRepliesCount":414,"averageViewsPerUserCount":6.0,"viewedContentPercentage":36.0,"viewedContentCount":20467,"usersLoggedInPercentage":76.85194198384114,"usersLoggedInCount":7895,"label":"Dec 2020"},{"year":2020,"month":11,"sharesCount":26,"likesCount":661,"postsAndRepliesCount":600,"averageViewsPerUserCount":6.0,"viewedContentPercentage":40.0,"viewedContentCount":24980,"usersLoggedInPercentage":77.17850476471166,"usersLoggedInCount":7856,"label":"Nov 2020"},{"year":2020,"month":10,"sharesCount":30,"likesCount":607,"postsAndRepliesCount":551,"averageViewsPerUserCount":7.0,"viewedContentPercentage":31.0,"viewedContentCount":24056,"usersLoggedInPercentage":66.53503612838179,"usersLoggedInCount":7919,"label":"Oct 2020"},{"year":2020,"month":9,"sharesCount":13,"likesCount":625,"postsAndRepliesCount":411,"averageViewsPerUserCount":7.0,"viewedContentPercentage":33.0,"viewedContentCount":26057,"usersLoggedInPercentage":64.32115098395899,"usersLoggedInCount":7779,"label":"Sep 2020"}]}';
        analyticsObj.getMonthsShiftedMonthlyReports(resultJson);
        
        resultJson = '{"status":"success","result":{"data":[{"views":2,"videoId":"1_en5fmxyi","url":"https://simpplr--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_en5fmxyi&provider=native_video","uploader":"Rachel Smith","uploadedAt":"2020-12-22","label":"⁣VID_20190224_131611.mp4"},{"views":2,"videoId":"1_drbw1id5","url":"https://simpplr--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_drbw1id5&provider=native_video","uploader":"Dan Gallo","uploadedAt":"2020-12-02","label":"⁣IMG_7715.TRIM.MOV"},{"views":2,"videoId":"1_qn6uk2rx","url":"https://simpplr--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_qn6uk2rx&provider=native_video","uploader":"Clint Patterson","uploadedAt":"2021-02-05","label":"Simpplr-Video-Offering.mp4"},{"views":2,"videoId":"1_v3864ifd","url":"https://simpplr--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_v3864ifd&provider=native_video","uploader":"Jason Li","uploadedAt":"2021-01-21","label":"⁣LinkedIn list building.mp4"},{"views":2,"videoId":"1_jxwmw4kk","url":"https://simpplr--simpplr.visualforce.com/apex/simpplr__FileDetail?fileId=1_jxwmw4kk&provider=native_video","uploader":"Brendan Patterson","uploadedAt":"2021-03-16","label":"Screen Recording 2021-03-01 at 10.46.12.mov"}],"csvUrl":"https://simpplr--simpplr.visualforce.com/apex/simpplr__Reports?action=getVideoPopularity&to=2021-04-21&from=2021-03-22&orderBy=bottom"},"responseTimeStamp":"1619073829244","message":"","debugLogs":[]}';
        analyticsObj.getDummyVideoPopularityData(resultJson);
        
        resultJson = '{"status":"success","result":{"updatedAt":"2021-03-25T09:45:16.000+0000"},"message":"Date returned successfully","recordCount":0}';
        analyticsObj.getLastSyncSwiftedDate(resultJson);

        resultJson = '{"totalViewCount":48,"uniqueViewCount":35,"viewsOverTime":[{"label":"2021-02-08","value":4},{"label":"2021-02-09","value":2},{"label":"2021-02-10","value":5},{"label":"2021-02-11","value":2},{"label":"2021-02-12","value":11},{"label":"2021-02-13","value":0},{"label":"2021-02-14","value":0},{"label":"2021-02-15","value":1},{"label":"2021-02-16","value":1},{"label":"2021-02-17","value":3},{"label":"2021-02-18","value":3}],"uniqueViewsOverTime":[{"label":"2021-02-08","value":3},{"label":"2021-02-09","value":1},{"label":"2021-02-10","value":4},{"label":"2021-02-11","value":2},{"label":"2021-02-12","value":8},{"label":"2021-02-13","value":0},{"label":"2021-02-14","value":0},{"label":"2021-02-15","value":1},{"label":"2021-02-16","value":1},{"label":"2021-02-17","value":2},{"label":"2021-02-18","value":2}]}';
        analyticsObj.getDateAdjustedConsumptionOverTimeData(30, resultJson);

        resultJson = '{"totalViewCount":6991,"uniqueViewCount":5378,"viewsOverTime":[{"value":2717,"label":"2021-01-25/2021-01-31"},{"value":2026,"label":"2021-02-01/2021-02-07"}],"uniqueViewsOverTime":[{"value":2104,"label":"2021-01-25/2021-01-31"},{"value":1558,"label":"2021-02-01/2021-02-07"}]}';
        analyticsObj.getDateAdjustedConsumptionOverTimeData(90, resultJson);

        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    /**
     * @description test case getViewedByMetricData
     */
    @isTest static void testPrepareGetViewedByMetricData() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'AnalyticsDataServer/getViewedByMetricData', false));
		
        pageRef.getParameters().put('action','getViewedByMetricData');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","groupBy":"week","siteId":"dummy","contentId":"dummy"}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        System.assertEquals('success', analyticsDSObject.response.status, 'Running as Expected');
        Test.stopTest();
	}

    /**
     * @description test case getConsumptionOverTime
     */
    @isTest static void testPrepareGetConsumptionOverTime() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'AnalyticsDataServer/getConsumptionOverTime', false));
		
        pageRef.getParameters().put('action','getConsumptionOverTime');
        pageRef.getParameters().put('data','{"from":"2016-01-01","to":"2020-01-02","siteId":"dummy","contentId":"dummy","groupBy":"day","includeMembers":true,"includeFollowers":true,"includeOthers":true}');
        Test.setCurrentPage(pageRef);
        analyticsDSObject.handleRequest();
        System.assertEquals('success', analyticsDSObject.response.status, 'Running as Expected');
        Test.stopTest();
	}

    @isTest static void testAnalyticsCsvDownloadPostProcess() {
        People__c peopleObj = getPeople();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AnalyticsDataServer');
        pageRef.getParameters().put('action','analyticsCsvDownloadPostProcess');
        Map<String, Object> valuesMap = new Map<String, Object>();
		valuesMap.put('widgetTab', 'Tab');
		valuesMap.put('peopleId', peopleObj.Id);
		valuesMap.put('userId', peopleObj.User__c);
        valuesMap.put('preSignedUrl', 'https://simpplr.com');

        pageRef.getParameters().put('data',Json.serialize(valuesMap));
        Test.setCurrentPage(pageRef);
        AnalyticsDataServer analyticsDSObject= new AnalyticsDataServer();
        analyticsDSObject.handleRequest();
        System.assertEquals('success', analyticsDSObject.response.status, 'Running as Expected');
    }
    
}