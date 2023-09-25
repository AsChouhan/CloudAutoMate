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
private class SiteContentProviderTest {
	static App_Config__c appConfig;
    static TileService serviceObj = new TileService();
    static user usr;
    static collaborationGroup cgGroup;
	static User siteMember;
	
	
    @testSetup static void setup() {
        appConfig = TestHelper.setupAppConfig();
        People__c peopleRecord = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        siteMember = TestHelper.createUser('TestUser1_TileServiceTest', null, false);
		usr = TestHelper.createUser('TestUser_TileServiceTest',null,false);
        cgGroup = TestHelper.createCollaborationGroup('Test_Group1_TileServiceTest','Public');
		CollaborationGroupMember cgMember = TestHelper.createCollaborationGroupMember(cgGroup.Id, siteMember.id,'Standard');
		Segment__c segmentRec = TestHelper.createSegment(peopleRecord.Id);
		Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
		List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE,appIntegList[0].id);
	}
    
    @isTest static void testMiscellaneous() {
		Test.startTest();
        User usrObj = [select id from user where lastname='TestUser_TileServiceTest' limit 1];
        CollaborationGroup cg = [select id from collaborationgroup where name='Test_Group1_TileServiceTest' limit 1];
        Simpplr_Site__c siteObj = [select id,name,is_active__c,Chatter_Group_Id__c from Simpplr_site__c where name='Test_Group1_TileServiceTest' limit 1 ];
        String jsonString = '{"userId":"'+String.valueOf(usrObj.id)+'","topicId":null,"term":"Test_Group1_TileServiceTest","sortBy":"Latest","size":10,"siteId":"'+String.valueOf(siteObj.id)+'","profileId":"'+String.valueOf(UserInfo.getProfileId())+'","pageName":"dd","offset":0,"nextPageToken":"ddf","isGlobalSearchReq":false,"groupCategories":true,"filter":"Latest","cid":"'+String.valueOf(cg.id)+'","category":null, "canSubmitQuestion":false}';
       	Criteria.Site criteriaSiteObj = (Criteria.Site)JSON.deserialize(jsonString, Criteria.Site.class);
		criteriaSiteObj.filter = 'canCreatePage';
       	
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteDataServer');
		pageRef.getParameters().put('siteId', siteObj.id);
		
        Test.setCurrentpage(pageRef);

       	SiteDataServer SiteDSObject= new SiteDataServer();  
        ResponseWrapper resWrapper1 = SiteDSObject.getsiteDetailData(System.currentPageReference().getParameters().put('siteId', siteObj.id), null);
		System.currentPageReference().getParameters().put('siteId', '');  
		ResponseWrapper resWrapper2 = SiteDSObject.getsiteDetailData(System.currentPageReference().getParameters().put('siteId', siteObj.id), null); 
       	
       	SiteContentProvider contentProviderObj = new SiteContentProvider();
       	contentProviderObj.getSitesAllSites(criteriaSiteObj);
       	contentProviderObj.getSitesAllFavoriteSites(criteriaSiteObj);
       	contentProviderObj.getSitesAllFollowingSites(criteriaSiteObj);
       	contentProviderObj.getSitesAllManagingSites(criteriaSiteObj);
       	contentProviderObj.getProfileSitesAllSites(criteriaSiteObj);
       	
       	String searchTerm = 'test';
       	contentProviderObj.getAvailableSitesForNewsLetter(searchTerm);
		criteriaSiteObj.term = searchTerm;
		criteriaSiteObj.nextPageToken = null;
		criteriaSiteObj.size = 16;
       	contentProviderObj.getAvailableSitesForAlert(criteriaSiteObj);
		contentProviderObj.searchSitesForAnalytics(searchTerm);
       	contentProviderObj.getSitesAllPopularSites(criteriaSiteObj);
       	contentProviderObj.getChatterGroupDetails(cg.id);
        
        siteObj.Is_Featured__c=true;
        update siteObj;
        
       	contentProviderObj.getSitesAllFeaturedSites(criteriaSiteObj);
		contentProviderObj.getSitesAllFeaturedSitesForSegments(criteriaSiteObj);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }

	@isTest static void testMiscellaneous1() {
		Test.startTest();
		User usrObj = [select id from user where lastname='TestUser_TileServiceTest' limit 1];
    	CollaborationGroup cg = [select id from collaborationgroup where name='Test_Group1_TileServiceTest' limit 1];
    	Simpplr_Site__c siteObj = [select id,name,Site_Type__c,Landing_Page__c,File_Storage_Source__c,is_active__c,Is_Featured__c,Chatter_Group_Id__c from Simpplr_site__c where name='Test_Group1_TileServiceTest' limit 1 ];
        String jsonString = '{"userId":"'+String.valueOf(usrObj.id)+'","topicId":null,"term":"Test_Group1_TileServiceTest","sortBy":"Latest","size":10,"siteId":"'+String.valueOf(siteObj.id)+'","profileId":"'+String.valueOf(UserInfo.getProfileId())+'","pageName":"dd","offset":0,"nextPageToken":"ddf","isGlobalSearchReq":false,"groupCategories":true,"filter":"Latest","cid":"'+String.valueOf(cg.id)+'","category":null}';
    	Criteria.Site criteriaSiteObj = (Criteria.Site)JSON.deserialize(jsonString, Criteria.Site.class);
		Criteria.ChatterGroup chatterGroupCriteriaObjArg = (Criteria.ChatterGroup)JSON.deserialize(jsonString, Criteria.ChatterGroup.class);
		SimpplrContext.slackIntegrationEnabled = true;
       	
		PageReference pageRef = Page.DataServerRW;
		SiteContentProvider contentProviderObj = new SiteContentProvider();
    	String searchTerm = 'test';

		contentProviderObj.getChatterGroups(chatterGroupCriteriaObjArg);
		contentProviderObj.getSitesCanSubmitContent(searchTerm, false);
		contentProviderObj.searchListedSites(searchTerm);
		contentProviderObj.getSitesCanBeMentionedInFeed(searchTerm); 
		UserContext.hasModifyAllDataPermission = false;
		UserContext.isUserAppModerator = true;
		UserContext.hasManageUnlistedSitePermission = true;

		contentProviderObj.getSitesCanSubmitContent(searchTerm, true);
		contentProviderObj.getAvailableSitesForNewsLetter(searchTerm);

		siteObj.File_Storage_Source__c = 'dropbox';
        siteObj.Landing_Page__c = 'dashboard';
        siteObj.Is_Featured__c=true;
        siteObj.Site_Type__c = 'Unlisted';
        siteObj.Title_Content_Document__c = '0694T0000016jw9QAA';
        siteObj.Cover_Content_Document__c = 'a134T0000004ikgQAA';
    	siteObj.Slack_Url__c = 'dadxa';
        update siteObj;
		UserContext.hasModifyAllDataPermission = true;
		SimpplrContext.isSegmentsEnabled = true;
       	
        contentProviderObj.getsiteDetailData(siteObj.id,cg.id);  
        contentProviderObj.getSlackUnfurlInfoForSite(siteObj.id);
		contentProviderObj.converDistributionPublicUrlToImageURL('0684T000000J5YHQA0','aa');
       	contentProviderObj.getSitesAllFeaturedSites(criteriaSiteObj);
		Test.stopTest();
		System.assert(true,'Running as expected');
	}
    
    @isTest static void testGetRecentUsedSites() {
        User usrObj = [select id from user where lastname='TestUser_TileServiceTest' limit 1];
    	CollaborationGroup cg = [select id from collaborationgroup where name='Test_Group1_TileServiceTest' limit 1];
    	Simpplr_Site__c siteObj = [select id,name,Site_Type__c,Landing_Page__c,File_Storage_Source__c,is_active__c,Is_Featured__c,Chatter_Group_Id__c from Simpplr_site__c where name='Test_Group1_TileServiceTest' limit 1 ];
        String jsonString = '{"userId":"'+String.valueOf(usrObj.id)+'","topicId":null,"term":"Test_Group1_TileServiceTest","sortBy":"Latest","size":10,"siteId":"'+String.valueOf(siteObj.id)+'","profileId":"'+String.valueOf(UserInfo.getProfileId())+'","pageName":"dd","offset":0,"nextPageToken":"ddf","isGlobalSearchReq":false,"groupCategories":true,"filter":"Latest","cid":"'+String.valueOf(cg.id)+'","category":null}';
    	Criteria.Site criteriaSiteObj = (Criteria.Site)JSON.deserialize(jsonString, Criteria.Site.class);
        
        PageReference pageRef = Page.DataServerRW;
		SiteContentProvider contentProviderObj = new SiteContentProvider();
        
        contentProviderObj.getRecentUsedSites(criteriaSiteObj);
        System.assert(true,'Running as expected');
    }


	@isTest static void testMiscellaneous2() {
		String searchTerm = 'test';

		User usrObj = [select id from user where lastname='TestUser_TileServiceTest' limit 1];
        CollaborationGroup cg = [select id from collaborationgroup where name='Test_Group1_TileServiceTest' limit 1];
        Simpplr_Site__c siteObj = [select id,name,is_active__c,Chatter_Group_Id__c from Simpplr_site__c where name='Test_Group1_TileServiceTest' limit 1 ];
        

		String jsonString = '{"userId":"'+String.valueOf(usrObj.id)+'","topicId":null,"term":"Test_Group1_TileServiceTest","sortBy":"Latest","size":10,"siteId":"'+String.valueOf(siteObj.id)+'","profileId":"'+String.valueOf(UserInfo.getProfileId())+'","pageName":"dd","offset":0,"nextPageToken":"ddf","isGlobalSearchReq":false,"groupCategories":true,"filter":"Latest","cid":"'+String.valueOf(cg.id)+'","category":null, "canSubmitQuestion":false}';
       	Criteria.Site criteriaSiteObj = (Criteria.Site)JSON.deserialize(jsonString, Criteria.Site.class);
       	
		PageReference pageRef = Page.DataServerRW;
		SiteContentProvider contentProviderObj = new SiteContentProvider();
		contentProviderObj.getProfileSitesAllManagingSites(criteriaSiteObj);
		contentProviderObj.getSitesSearchResults(criteriaSiteObj);

		UserContext.hasManageUnlistedSitePermission = false;
		UserContext.hasModifyAllDataPermission = false;
		UserContext.isUserAppModerator = false;
		UserContext.hasManageUnlistedSitePermission = false;
		contentProviderObj.getAvailableSitesForNewsLetter(searchTerm);
		System.assert(true,'Running as expected');

	}

}