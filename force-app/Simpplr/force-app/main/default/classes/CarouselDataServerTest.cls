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
private class CarouselDataServerTest {
	
	private static App_Config__c appConfigRecord;
	private static User siteOwnr;
	private static User siteMember;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Content__c simpplrContent2;
	private static Simpplr_Site__c site;
	private static People__c peopleObj;
    private static Segment__c segment;
	@testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		TestHelper.createPeopleRecordForUser(UserContext.id);
		siteOwnr = TestHelper.createUser('CarouselDataServerTest_siteOwnr', null, true);
		managerOfsiteMember = TestHelper.createUser('CarouselDataServerTest_userMngr', null, false);
		siteMember = TestHelper.createUser('CarouselDataServerTest_siteMmbr', managerOfsiteMember, false);
		addPermSet(siteMember.Id);
		cgroup = TestHelper.createCollaborationGroup('CarouselDataServerTest_Grp1','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		
		site = TestHelper.getSiteRecordWithName('CarouselDataServerTest_Grp1');
		TestHelper.shareSitesToAllPeople(new List<String>{site.Id});
		simpplrContent = TestHelper.createContent('simpplr test page', 'Page', 'Published', siteMember, site);
		simpplrContent2 = TestHelper.createContent('simpplr test page 2', 'Page', 'Published', siteMember, site);
		TestHelper.shareContentsToAllPeople(new List<String>{simpplrContent.Id, simpplrContent2.Id});
	    
	}

	@future
    private static void addPermSet(String userId) {
        List<PermissionSet> perAssignments = [SELECT Id, Name FROM PermissionSet where Name = 'Simpplr_User' limit 1];
        if(!perAssignments.isEmpty()) {
        	PermissionSetAssignment perSetAssignObj = new PermissionSetAssignment();
            perSetAssignObj.PermissionSetId = perAssignments[0].id;
            perSetAssignObj.AssigneeId = userId;
            insert perSetAssignObj;
    	}
    }
	
    private static void init() {
    	if(appConfigRecord == null) {
    		appConfigRecord = SimpplrContext.appConfig;
	    	List<User> listOfUsers = [select Id, lastName from user where lastname like 'CarouselDataServerTest%'];
	    	for(User userObj : listOfUsers) {
	    		if(userObj.lastName == 'CarouselDataServerTest_siteOwnr') {
	    			siteOwnr = userObj; 
	    		} else if(userObj.lastName == 'CarouselDataServerTest_userMngr') {
	    			managerOfsiteMember = userObj; 
	    		} else if(userObj.lastName == 'CarouselDataServerTest_siteMmbr') {
	    			siteMember = userObj; 
	    		} 
	    	}
	    	peopleObj = getPeople(siteOwnr.id); 
	    	
	    	site = TestHelper.getSiteRecordWithName('CarouselDataServerTest_Grp1');
	        simpplrContent = TestHelper.createContent('simpplr test page', 'Page', 'Approved', siteOwnr, site, peopleObj.id);
	    	simpplrContent2 = TestHelper.createContent('simpplr test page', 'BlogPost', 'Approved', siteOwnr, site, peopleObj.id);
			TestHelper.shareContentsToAllPeople(new List<String>{simpplrContent.Id, simpplrContent2.Id});
            segment = TestHelper.createSegment(peopleObj.id);
            Social_Campaign__c socialCamp = TestHelper.createSocialCampaign(peopleObj.id);
            TestHelper.createSocialCampaignShareRecords(UserContext.peopleId, socialCamp, new Set<String>{'Facebook','Twitter','Linkedin'});
	    	TestHelper.createCarousel(site.id,simpplrContent.id,'content',socialCamp.id);
            TestHelper.createCarousel(site.id,simpplrContent.id,'campaign',socialCamp.id);
            TestHelper.createCarousel(site.id, simpplrContent.id,'external',socialCamp.id);
	    	TestHelper.createContentTitleImage(simpplrContent.Id);
            TestHelper.createContentTitleImage(simpplrContent.Id,'Thumbnail');
            TestHelper.createCarousel(site.Id,simpplrContent2.Id,'content',socialCamp.id);
	    	
    	}
    	PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','CarouselDataServer');
        Test.setCurrentPage(pgRef);
    }

	static List<String> getCarouselIds() {
		List<String> ids = new List<String>();
		for(Carousel_Content__c cobj : [select id from Carousel_Content__c]) {
			ids.add(cobj.id);
		}
		return ids;
	}
    
    //Add JSON: {id: "home", contentId: "a0161000005UsXwAAK"}
    @isTest
	static void testHandleRequestWhenActionNull() {
    	init();
    	CarouselDataServer allContentDSObj= new CarouselDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','CarouselDataServer');
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        allContentDSObj.handleRequest();
		System.assertEquals('error', allContentDSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','None');
        pageRef.getParameters().put('data','{"peopleId":"'+siteOwnr.Id+'"}');
        Test.setCurrentPage(pageRef);
        allContentDSObj.handleRequest();
        System.assertEquals('error', allContentDSObj.response.status, 'Running as expected');
    }
    
    @isTest
	static void testHandleRequestWhenActionAvailable() {
        init();
    	Test.startTest();
		List<String> carouselIds = getCarouselIds();
    	CarouselDataServer allContentDSObj= new CarouselDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/content/topic-suggest',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','CarouselDataServer');
        Test.setCurrentPage(pageRef);

        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_GET);
        pageRef.getParameters().put('data','{"siteId":"'+ site.id +'"}');
        Test.setCurrentPage(pageRef);
        allContentDSObj.handleRequest();
		System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_GET);
        pageRef.getParameters().put('data','{"siteId":"'+ site.id +'","segmentId":"'+ segment.id +'"}');
        Test.setCurrentPage(pageRef);
        allContentDSObj.handleRequest();
		System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
        
        SimpplrContext.isSegmentsEnabled = true;
        SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_GET);
        pageRef.getParameters().put('data','{"siteId":"'+ site.id +'","segmentId":"'+ segment.id +'"}');
        Test.setCurrentPage(pageRef);
        allContentDSObj.handleRequest();
		System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
        pageRef.getParameters().put('pageName','CarouselDataServer');
        Test.setCurrentPage(pageRef);
        allContentDSObj.handleRequest();
		System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_SAVEORDER);
		String itemIds = '[' + String.join(carouselIds, ',') + ']';
        pageRef.getParameters().put('data','{"orderOfItemIds":"' + itemIds + '"}');
        allContentDSObj.handleRequest();
		System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
        
        String dataStrRemoveContentItem = '{"siteId":"' + site.id + '", "contentId":"' + simpplrContent.id + '"}';
        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_REMOVE_CONTENT_ITEM);
        pageRef.getParameters().put('data',dataStrRemoveContentItem);
        allContentDSObj.handleRequest();
		System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_REMOVE_CONTENT_ITEM);
        pageRef.getParameters().put('data','{}');
        allContentDSObj.handleRequest();
		System.assertEquals('error', allContentDSObj.response.status, 'No data passed. Should return error');
        
        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_REMOVEITEM);
        pageRef.getParameters().put('data','{"carouselItemId":"' + carouselIds[0] + '"}');
        allContentDSObj.handleRequest();
		System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
        
        System.runAs(siteMember) {
        	pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_SAVEORDER);
        	pageRef.getParameters().put('data','{"orderOfItemIds":"' + itemIds + '"}');
	        allContentDSObj.handleRequest();
			System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
	        
	        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_REMOVE_CONTENT_ITEM);
	        pageRef.getParameters().put('data',dataStrRemoveContentItem);
	        allContentDSObj.handleRequest();
			System.assertEquals('error', allContentDSObj.response.status, 'Already removed. Should be an error');
	        
	        pageRef.getParameters().put('action',allContentDSObj.ACTION_VALUE_REMOVEITEM);
	        pageRef.getParameters().put('data','{"carouselItemId":"' + carouselIds[1] + '"}');
	        allContentDSObj.handleRequest();
			System.assertEquals('success', allContentDSObj.response.status, 'Running as expected');
        }
        
        Test.stopTest();
    }
    
	@isTest
	static void testSetLayout() {
		Test.startTest();
		init();
		
		CarouselDataServer carouselContentDSObj = new CarouselDataServer();
		PageReference pageRef = Page.DataServerRW;
		
		pageRef.getParameters().put('target','CarouselDataServer');
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_SETLAYOUT);
		pageRef.getParameters().put('data','{"siteId":"' + site.id + '","segmentId":null,"layout":"standard","governance":"enable"}');
		Test.setCurrentPage(pageRef);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');
	
		pageRef.getParameters().put('data','{"siteId":"' + site.id + '","segmentId":null,"layout":"","governance":"enable"}');
		carouselContentDSObj.handleRequest();
		System.assertEquals('error', carouselContentDSObj.response.status, 'Layout value is blank. Should be an error');
	
		pageRef.getParameters().put('data','{"siteId":"' + site.id + '","segmentId":"'+segment.Id+'","layout":"standard","governance":"enable"}');
		Test.setCurrentPage(pageRef);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');
	
		pageRef.getParameters().put('data','{"siteId":null,"segmentId":null,"layout":"standard","governance":"enable"}');
		Test.setCurrentPage(pageRef);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');

		System.assert(true,'Running as expected');	    	
    	Test.stopTest();
    }

    @isTest
	static void testRemoveContentItem() {
		Test.startTest();
		init();
		System.runAs(siteMember) {
			CarouselDataServer carouselContentDSObj = new CarouselDataServer();
			String estr = '"type":"WebPage","title":"Test Title Name","provider_url":"www.amazon.com","url":"https://www.amazon.in/Cadbury-Miniatures-Collection-Dairy-Milk/dp/B071X6KZFC"';
			ResponseWrapper resp2 = carouselContentDSObj.addEmbedly(null, null, '{' + estr + '}');
			System.assertEquals('success', resp2.status, 'Running as expected');
		} 
    	Test.stopTest();
    }
    
    @isTest
	static void testAdd1() {
		init();
		List<String> carouselIds = getCarouselIds();
		CarouselDataServer carouselContentDSObj = new CarouselDataServer();
		List<String> listofValues=new List<String>{site.id,simpplrContent.id, carouselIds[0]};
		String str = '"id":"{0}","contentId":"{1}","carouselItemId":"{2}"';
		String jsonString = '{' + EmailUtility.format(str,listofValues) + '}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViews',false));
		ResponseWrapper resp = carouselContentDSObj.addContent(null, null, jsonString, true);
		System.assertEquals('success', resp.status, 'Running as expected');
		
		String jsonStringSaveOrder = '{"siteId":null,"orderOfItemIds":["' + carouselIds[0] + '"]}';
		resp = carouselContentDSObj.saveOrder(null, jsonStringSaveOrder, null);
		System.assertEquals('success', resp.status, 'Running as expected');
		
		
		//removeItem --
		resp = carouselContentDSObj.removeItem(null, carouselIds[0]);
		System.assertEquals('success', resp.status, 'Running as expected');
		
		Test.stopTest();
    }
    
	
    @isTest
	static void testHandleRequestAddItemAddContent() {
		init();
		Test.startTest();

		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','CarouselDataServer');
		Test.setCurrentPage(pageRef);

		CarouselDataServer carouselContentDSObj= new CarouselDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViews',false));
		String dataStr = '{"siteId":null,"segmentId":null,"type":"content","model":"{\\"editedBy\\":{},\\"authoredBy\\":{\\"canFollow\\":false,\\"mobile\\":\\"4444\\",\\"img\\":\\"https://c.na130.content.force.com/profilephoto/7294N000000FSND/F\\",\\"isFollowing\\":false,\\"peopleId\\":\\"' + UserContext.peopleId + '\\",\\"name\\":\\"Deepak Sirohi\\",\\"nickname\\":\\"deepak.sirohi1.4459378254093433E12\\",\\"phone\\":\\"9\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/people/a0B61000005ilvzEAA\\",\\"isActive\\":true,\\"phoneExtension\\":\\"1\\",\\"department\\":\\"Dev\\",\\"location\\":\\"Gurgaon, State 2, India\\",\\"title\\":\\"DS title\\",\\"sfUserId\\":\\"' + UserContext.id + '\\",\\"id\\":\\"a0B61000005ilvzEAA\\",\\"email\\":\\"deepak@simpplr.com\\"},\\"excerpt\\":\\"asdasd\\",\\"listOfFiles\\":[],\\"publishAt\\":\\"2018-11-29T00:00:00.000+0530\\",\\"isLiked\\":false,\\"usefulContent\\":{\\"hasUserRated\\":false,\\"canViewHistory\\":true},\\"isPublished\\":true,\\"editUrl\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/page/' + simpplrContent.id + '/edit\\",\\"listOfInlineImages\\":[],\\"site\\":{\\"siteId\\":\\"' + site.id + '\\",\\"isManager\\":true,\\"img\\":\\"https://c.na130.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=06861000005DNYMAA4\\",\\"isMember\\":true,\\"access\\":\\"Public\\",\\"isListed\\":true,\\"imgThumbnail\\":\\"https://c.na130.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=06861000005DNYMAA4\\",\\"name\\":\\"CRM Site - 22-Oct\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/dashboard\\",\\"isActive\\":true,\\"chatterGroupId\\":\\"0F961000000EfSTCA0\\",\\"isPublic\\":true,\\"title\\":\\"CRM Site - 22-Oct\\",\\"isPrivate\\":false},\\"listOfTopAlbumImages\\":[],\\"isMustRead\\":false,\\"$order\\":9,\\"isTypeActive\\":true,\\"publishTo\\":\\"\\",\\"canSendUpdateNotification\\":true,\\"isInHomeCarousel\\":false,\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/page/' + simpplrContent.id + '\\",\\"isDeleted\\":false,\\"hasRead\\":false,\\"status\\":\\"published\\",\\"favoriteContext\\":\\"Page\\",\\"canModerate\\":true,\\"contentId\\":\\"' + simpplrContent.id + '\\",\\"isInSiteCarousel\\":false,\\"canPublishUnpublish\\":true,\\"title\\":\\"test 1\\",\\"likeCount\\":0,\\"readCount\\":0,\\"canEdit\\":true,\\"type\\":\\"Page\\",\\"id\\":\\"' + simpplrContent.id + '\\",\\"createdAt\\":\\"2018-11-29T14:25:36.000+0530\\",\\"canDelete\\":true,\\"modifiedAt\\":\\"2018-11-29T14:25:36.000+0530\\",\\"isFavorited\\":false,\\"category\\":{\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/content&pageCategoryId=a1P610000030zPPEAY\\",\\"site\\":{},\\"name\\":\\"Uncategorized\\",\\"id\\":\\"a1P610000030zPPEAY\\",\\"categoryId\\":\\"a1P610000030zPPEAY\\",\\"authoredBy\\":{}}}"}';
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');
		Test.stopTest();
    }
    @isTest
	static void testHandleRequestAddItemAddContent2() {
		init();
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','CarouselDataServer');
		Test.setCurrentPage(pageRef);
		CarouselDataServer carouselContentDSObj= new CarouselDataServer();
		String dataStr = '{"siteId":null,"segmentId":null,"type":"content","model":"{\\"editedBy\\":{},\\"authoredBy\\":{\\"canFollow\\":false,\\"mobile\\":\\"4444\\",\\"img\\":\\"https://c.na130.content.force.com/profilephoto/7294N000000FSND/F\\",\\"isFollowing\\":false,\\"peopleId\\":\\"' + UserContext.peopleId + '\\",\\"name\\":\\"Deepak Sirohi\\",\\"nickname\\":\\"deepak.sirohi1.4459378254093433E12\\",\\"phone\\":\\"9\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/people/a0B61000005ilvzEAA\\",\\"isActive\\":true,\\"phoneExtension\\":\\"1\\",\\"department\\":\\"Dev\\",\\"location\\":\\"Gurgaon, State 2, India\\",\\"title\\":\\"DS title\\",\\"sfUserId\\":\\"' + UserContext.id + '\\",\\"id\\":\\"a0B61000005ilvzEAA\\",\\"email\\":\\"deepak@simpplr.com\\"},\\"excerpt\\":\\"asdasd\\",\\"listOfFiles\\":[],\\"publishAt\\":\\"2018-11-29T00:00:00.000+0530\\",\\"isLiked\\":false,\\"usefulContent\\":{\\"hasUserRated\\":false,\\"canViewHistory\\":true},\\"isPublished\\":true,\\"editUrl\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/page/' + simpplrContent.id + '/edit\\",\\"listOfInlineImages\\":[],\\"site\\":{\\"siteId\\":\\"' + site.id + '\\",\\"isManager\\":true,\\"img\\":\\"https://c.na130.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=06861000005DNYMAA4\\",\\"isMember\\":true,\\"access\\":\\"Public\\",\\"isListed\\":true,\\"imgThumbnail\\":\\"https://c.na130.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=06861000005DNYMAA4\\",\\"name\\":\\"CRM Site - 22-Oct\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/dashboard\\",\\"isActive\\":true,\\"chatterGroupId\\":\\"0F961000000EfSTCA0\\",\\"isPublic\\":true,\\"title\\":\\"CRM Site - 22-Oct\\",\\"isPrivate\\":false},\\"listOfTopAlbumImages\\":[],\\"isMustRead\\":false,\\"$order\\":9,\\"isTypeActive\\":true,\\"publishTo\\":\\"\\",\\"canSendUpdateNotification\\":true,\\"isInHomeCarousel\\":false,\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/page/' + simpplrContent.id + '\\",\\"isDeleted\\":false,\\"hasRead\\":false,\\"status\\":\\"published\\",\\"favoriteContext\\":\\"Page\\",\\"canModerate\\":true,\\"contentId\\":\\"' + simpplrContent.id + '\\",\\"isInSiteCarousel\\":false,\\"canPublishUnpublish\\":true,\\"title\\":\\"test 1\\",\\"likeCount\\":0,\\"readCount\\":0,\\"canEdit\\":true,\\"type\\":\\"Page\\",\\"id\\":\\"' + simpplrContent.id + '\\",\\"createdAt\\":\\"2018-11-29T14:25:36.000+0530\\",\\"canDelete\\":true,\\"modifiedAt\\":\\"2018-11-29T14:25:36.000+0530\\",\\"isFavorited\\":false,\\"category\\":{\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/content&pageCategoryId=a1P610000030zPPEAY\\",\\"site\\":{},\\"name\\":\\"Uncategorized\\",\\"id\\":\\"a1P610000030zPPEAY\\",\\"categoryId\\":\\"a1P610000030zPPEAY\\",\\"authoredBy\\":{}}}"}';
		dataStr = '{"siteId":"' + site.id + '","segmentId":null,"type":"content","isInAllSegments":"true","model":"{\\"editedBy\\":{},\\"authoredBy\\":{\\"canFollow\\":false,\\"mobile\\":\\"4444\\",\\"img\\":\\"https://c.na130.content.force.com/profilephoto/7294N000000FSND/F\\",\\"isFollowing\\":false,\\"peopleId\\":\\"' + UserContext.peopleId + '\\",\\"name\\":\\"Deepak Sirohi\\",\\"nickname\\":\\"deepak.sirohi1.4459378254093433E12\\",\\"phone\\":\\"9\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/people/a0B61000005ilvzEAA\\",\\"isActive\\":true,\\"phoneExtension\\":\\"1\\",\\"department\\":\\"Dev\\",\\"location\\":\\"Gurgaon, State 2, India\\",\\"title\\":\\"DS title\\",\\"sfUserId\\":\\"' + UserContext.id + '\\",\\"id\\":\\"a0B61000005ilvzEAA\\",\\"email\\":\\"deepak@simpplr.com\\"},\\"excerpt\\":\\"asdasd\\",\\"listOfFiles\\":[],\\"publishAt\\":\\"2018-11-29T00:00:00.000+0530\\",\\"isLiked\\":false,\\"usefulContent\\":{\\"hasUserRated\\":false,\\"canViewHistory\\":true},\\"isPublished\\":true,\\"editUrl\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/page/' + simpplrContent2.id + '/edit\\",\\"listOfInlineImages\\":[],\\"site\\":{\\"siteId\\":\\"' + site.id + '\\",\\"isManager\\":true,\\"img\\":\\"https://c.na130.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=06861000005DNYMAA4\\",\\"isMember\\":true,\\"access\\":\\"Public\\",\\"isListed\\":true,\\"imgThumbnail\\":\\"https://c.na130.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=06861000005DNYMAA4\\",\\"name\\":\\"CRM Site - 22-Oct\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/dashboard\\",\\"isActive\\":true,\\"chatterGroupId\\":\\"0F961000000EfSTCA0\\",\\"isPublic\\":true,\\"title\\":\\"CRM Site - 22-Oct\\",\\"isPrivate\\":false},\\"listOfTopAlbumImages\\":[],\\"isMustRead\\":false,\\"$order\\":9,\\"isTypeActive\\":true,\\"publishTo\\":\\"\\",\\"canSendUpdateNotification\\":true,\\"isInHomeCarousel\\":false,\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/page/' + simpplrContent2.id + '\\",\\"isDeleted\\":false,\\"hasRead\\":false,\\"status\\":\\"published\\",\\"favoriteContext\\":\\"Page\\",\\"canModerate\\":true,\\"contentId\\":\\"' + simpplrContent2.id + '\\",\\"isInSiteCarousel\\":false,\\"canPublishUnpublish\\":true,\\"title\\":\\"test 1\\",\\"likeCount\\":0,\\"readCount\\":0,\\"canEdit\\":true,\\"type\\":\\"Page\\",\\"id\\":\\"' + simpplrContent2.id + '\\",\\"createdAt\\":\\"2018-11-29T14:25:36.000+0530\\",\\"canDelete\\":true,\\"modifiedAt\\":\\"2018-11-29T14:25:36.000+0530\\",\\"isFavorited\\":false,\\"category\\":{\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/content&pageCategoryId=a1P610000030zPPEAY\\",\\"site\\":{},\\"name\\":\\"Uncategorized\\",\\"id\\":\\"a1P610000030zPPEAY\\",\\"categoryId\\":\\"a1P610000030zPPEAY\\",\\"authoredBy\\":{}}}"}';
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViews',false));
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');
		Test.stopTest();
	}

	@isTest
	static void testHandleRequestAddItemAddEmbedly() {
		Test.startTest();
		init();

		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','CarouselDataServer');
		Test.setCurrentPage(pageRef);

		CarouselWrapper.OembedModel wrapperObj = new CarouselWrapper.OembedModel();         
		wrapperObj.provider_url = 'https://www.youtube.com/';
		wrapperObj.width = 854;
		wrapperObj.height = 480;
		wrapperObj.html = '<iframe class="embedly-embed" src="//cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fwww.youtube.com%2Fembed%2FjvIGFhqbe0c%3Fautoplay%3D1%26feature%3Doembed&url=http%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DjvIGFhqbe0c&image=https%3A%2F%2Fi.ytimg.com%2Fvi%2FjvIGFhqbe0c%2Fhqdefault.jpg&key=232a45f8a2a448de94ac10274adf58f8&autoplay=1&type=text%2Fhtml&schema=youtube" width="854" height="480" scrolling="no" frameborder="0" allow="autoplay; fullscreen" allowfullscreen="true"></iframe>';
		wrapperObj.url = 'https://www.youtube.com/watch?v=jvIGFhqbe0c';
		wrapperObj.thumbnail_width = '480';
		wrapperObj.version = '1.0';
		wrapperObj.title = 'San Andreas (2015) - Tsunami Scene - Pure Action [4K]';
		wrapperObj.provider_name = 'YouTube';
		wrapperObj.type = 'video';
		wrapperObj.thumbnail_height = '360';
		wrapperObj.author_url = 'https://www.youtube.com/channel/UCyiKdqreDmEBJEN0cDG5OxA';
		wrapperObj.thumbnail_url = 'https://i.ytimg.com/vi/jvIGFhqbe0c/hqdefault.jpg';
		wrapperObj.description = 'I like this movie much more, than 2012. 1) No annoying yelling kids. 2) No surviving at last possible second, without any injuries. 3) ( ͡° ͜ʖ ͡°) 4) Actual practical use of many tools and vehicles. Movie info: http://www.imdb.com/title/tt2126355/ Credits goes to: Village Roadshow Pictures, New Line Cinema, RatPac-Dune Entertainment.';
		wrapperObj.author_name = 'Kimer Lorens';
		Map<String, String> requestData = new Map<String, String>();
		requestData.put('siteId', null);
		requestData.put('segmentId', null);
		requestData.put('type', 'external');
		requestData.put('model', JSON.serialize(wrapperObj));

		CarouselDataServer carouselContentDSObj = new CarouselDataServer();
		String dataStr = JSON.serialize(requestData);
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');
		
		requestData.put('segmentId', segment.Id);
		requestData.put('isInAllSegments', 'true');
		dataStr = JSON.serialize(requestData);
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');

    	Test.stopTest();
    }
	
	@isTest
	static void testHandleRequestAddItemAddCampaign() {
		Test.startTest();
		init();
		Social_Campaign__c campaignObj = TestHelper.createSocialCampaign(peopleObj.id);

		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','CarouselDataServer');
		Test.setCurrentPage(pageRef);
		CarouselDataServer carouselContentDSObj = new CarouselDataServer();
		String dataStr = '{"siteId":null,"segmentId":null,"type":"campaign","model":"{\\"img\\":\\"http://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png\\",\\"networks\\":{\\"facebook\\":{\\"shareCount\\":0,\\"isEnabled\\":true}},\\"$order\\":1,\\"oembed\\":{\\"provider_url\\":\\"http://www.google.com\\",\\"url\\":\\"http://www.google.com/\\",\\"thumbnail_width\\":\\"272\\",\\"version\\":\\"1.0\\",\\"title\\":\\"Google\\",\\"provider_name\\":\\"Google\\",\\"type\\":\\"link\\",\\"thumbnail_height\\":\\"92\\",\\"thumbnail_url\\":\\"http://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png\\",\\"description\\":\\"Search the world\'s information, including webpages, images, videos and more. Google has many special features to help you find exactly what you\'re looking for.\\"},\\"campaignId\\":\\"'+campaignObj.Id+'\\",\\"isInHomeCarousel\\":false,\\"url\\":\\"www.google.com\\",\\"isActive\\":true,\\"title\\":\\"Google\\",\\"id\\":\\"a0P4N000009KhZjUAK\\",\\"createdAt\\":\\"2019-05-10T15:46:55.000+0530\\",\\"defaultDescription\\":\\"test msg for campaign\\",\\"createdBy\\":{\\"img\\":\\"https://c.na130.content.force.com/profilephoto/7294N000000FSND/T\\",\\"userId\\":\\"' + UserContext.id + '\\",\\"isFollowing\\":false,\\"peopleId\\":\\"' + UserContext.peopleId + '\\",\\"videoCallProvider\\":\\"zoom\\",\\"name\\":\\"Deepak Sirohi\\",\\"videoCallUsername\\":\\"DS-zoom-Id\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/people/' + UserContext.peopleId + '\\",\\"department\\":\\"Dev\\",\\"location\\":\\"Gurgaon, State 2, India\\",\\"title\\":\\"DS title\\",\\"id\\":\\"' + UserContext.peopleId + '\\"}}"}';
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');

		dataStr = '{"siteId":"' + site.id + '","segmentId":null,"type":"campaign","model":"{\\"img\\":\\"http://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png\\",\\"networks\\":{\\"facebook\\":{\\"shareCount\\":0,\\"isEnabled\\":true}},\\"$order\\":1,\\"oembed\\":{\\"provider_url\\":\\"http://www.google.com\\",\\"url\\":\\"http://www.google.com/\\",\\"thumbnail_width\\":\\"272\\",\\"version\\":\\"1.0\\",\\"title\\":\\"Google\\",\\"provider_name\\":\\"Google\\",\\"type\\":\\"link\\",\\"thumbnail_height\\":\\"92\\",\\"thumbnail_url\\":\\"http://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png\\",\\"description\\":\\"Search the world\'s information, including webpages, images, videos and more. Google has many special features to help you find exactly what you\'re looking for.\\"},\\"campaignId\\":\\"'+campaignObj.Id+'\\",\\"isInHomeCarousel\\":false,\\"url\\":\\"www.google.com\\",\\"isActive\\":true,\\"title\\":\\"Google\\",\\"id\\":\\"a0P4N000009KhZjUAK\\",\\"createdAt\\":\\"2019-05-10T15:46:55.000+0530\\",\\"defaultDescription\\":\\"test msg for campaign\\",\\"createdBy\\":{\\"img\\":\\"https://c.na130.content.force.com/profilephoto/7294N000000FSND/T\\",\\"userId\\":\\"' + UserContext.id + '\\",\\"isFollowing\\":false,\\"peopleId\\":\\"' + UserContext.peopleId + '\\",\\"videoCallProvider\\":\\"zoom\\",\\"name\\":\\"Deepak Sirohi\\",\\"videoCallUsername\\":\\"DS-zoom-Id\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/people/' + UserContext.peopleId + '\\",\\"department\\":\\"Dev\\",\\"location\\":\\"Gurgaon, State 2, India\\",\\"title\\":\\"DS title\\",\\"id\\":\\"' + UserContext.peopleId + '\\"}}"}';
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');

		dataStr = '{"siteId":"' + site.id + '","segmentId":null,"campaignId":"'+campaignObj.Id+'"}';
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_REMOVE_CAMPAIGN_ITEM);
		pageRef.getParameters().put('data', dataStr);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');

    	Test.stopTest();
    }

	@isTest
	static void testHandleRequestAddItemInvalidType() {
		Test.startTest();
		init();

		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','CarouselDataServer');
		Test.setCurrentPage(pageRef);

		CarouselDataServer carouselContentDSObj = new CarouselDataServer();
		String dataStr = '{"siteId":null,"segmentId":null,"type":"invalid","model":"dummyModel"}';
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		carouselContentDSObj.handleRequest();
		System.assertEquals('error', carouselContentDSObj.response.status, 'Invalid type. Should be an error.');

		dataStr = '{"siteId":null,"segmentId":null,"type":"invalid","model":""}';
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		carouselContentDSObj.handleRequest();
		System.assertEquals('error', carouselContentDSObj.response.status, 'Invalid type. Should be an error.');

    	Test.stopTest();
    }


    @isTest
	static void testAdd2() {
		init();
		Test.startTest();
		List<String> carouselIds = getCarouselIds();
		CarouselDataServer carouselContentDSObj = new CarouselDataServer();
		List<String> listofValues=new List<String>{'home',simpplrContent.id};
		String str = '"id":"{0}","contentId":"{1}"';
		String jsonString = '{' + EmailUtility.format(str,listofValues) + '}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViews',false));
		ResponseWrapper resp = carouselContentDSObj.addContent(null, null, jsonString, true);
		System.assertEquals('success', resp.status, 'Running as expected');
		
		//removeItem --
		resp = carouselContentDSObj.removeItem(null, carouselIds[0]);
		System.assertEquals('success', resp.status, 'Running as expected');
		Test.stopTest();
    }

	
    @isTest
	static void testAdd3() {
		init();
		Test.startTest();
		PageReference pageRef = Page.DataServerRW;
		CarouselDataServer carouselContentDSObj = new CarouselDataServer();
		String dataStr = '{"siteId":null,"segmentId":null,"isInAllSegments":true,"type":"content","model":"{\\"editedBy\\":{},\\"authoredBy\\":{\\"canFollow\\":false,\\"mobile\\":\\"4444\\",\\"img\\":\\"https://c.na130.content.force.com/profilephoto/7294N000000FSND/F\\",\\"isFollowing\\":false,\\"peopleId\\":\\"' + UserContext.peopleId + '\\",\\"name\\":\\"Deepak Sirohi\\",\\"nickname\\":\\"deepak.sirohi1.4459378254093433E12\\",\\"phone\\":\\"9\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/people/a0B61000005ilvzEAA\\",\\"isActive\\":true,\\"phoneExtension\\":\\"1\\",\\"department\\":\\"Dev\\",\\"location\\":\\"Gurgaon, State 2, India\\",\\"title\\":\\"DS title\\",\\"sfUserId\\":\\"' + UserContext.id + '\\",\\"id\\":\\"a0B61000005ilvzEAA\\",\\"email\\":\\"deepak@simpplr.com\\"},\\"excerpt\\":\\"asdasd\\",\\"listOfFiles\\":[],\\"publishAt\\":\\"2018-11-29T00:00:00.000+0530\\",\\"isLiked\\":false,\\"usefulContent\\":{\\"hasUserRated\\":false,\\"canViewHistory\\":true},\\"isPublished\\":true,\\"editUrl\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/page/' + simpplrContent.id + '/edit\\",\\"listOfInlineImages\\":[],\\"site\\":{\\"siteId\\":\\"' + site.id + '\\",\\"isManager\\":true,\\"img\\":\\"https://c.na130.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=06861000005DNYMAA4\\",\\"isMember\\":true,\\"access\\":\\"Public\\",\\"isListed\\":true,\\"imgThumbnail\\":\\"https://c.na130.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=06861000005DNYMAA4\\",\\"name\\":\\"CRM Site - 22-Oct\\",\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/dashboard\\",\\"isActive\\":true,\\"chatterGroupId\\":\\"0F961000000EfSTCA0\\",\\"isPublic\\":true,\\"title\\":\\"CRM Site - 22-Oct\\",\\"isPrivate\\":false},\\"listOfTopAlbumImages\\":[],\\"isMustRead\\":false,\\"$order\\":9,\\"isTypeActive\\":true,\\"publishTo\\":\\"\\",\\"canSendUpdateNotification\\":true,\\"isInHomeCarousel\\":false,\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/page/' + simpplrContent.id + '\\",\\"isDeleted\\":false,\\"hasRead\\":false,\\"status\\":\\"published\\",\\"favoriteContext\\":\\"Page\\",\\"canModerate\\":true,\\"contentId\\":\\"' + simpplrContent.id + '\\",\\"isInSiteCarousel\\":false,\\"canPublishUnpublish\\":true,\\"title\\":\\"test 1\\",\\"likeCount\\":0,\\"readCount\\":0,\\"canEdit\\":true,\\"type\\":\\"Page\\",\\"id\\":\\"' + simpplrContent.id + '\\",\\"createdAt\\":\\"2018-11-29T14:25:36.000+0530\\",\\"canDelete\\":true,\\"modifiedAt\\":\\"2018-11-29T14:25:36.000+0530\\",\\"isFavorited\\":false,\\"category\\":{\\"url\\":\\"https://c.na130.visual.force.com/apex/app?u=/site/' + site.id + '/content&pageCategoryId=a1P610000030zPPEAY\\",\\"site\\":{},\\"name\\":\\"Uncategorized\\",\\"id\\":\\"a1P610000030zPPEAY\\",\\"categoryId\\":\\"a1P610000030zPPEAY\\",\\"authoredBy\\":{}}}"}';
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_ADDITEM);
		pageRef.getParameters().put('data', dataStr);
		Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentViews',false));
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');
		Test.stopTest();
    }
    
    @isTest
	static void testAlreadyAddedToCarousel() {
        Test.startTest();
    	init();
    	System.runAs(siteMember) {
	    	CarouselDataServer carouselContentDSObj = new CarouselDataServer();
	    	Boolean resp = carouselContentDSObj.alreadyAddedToCarousel(simpplrContent.id, null, 'home');
			System.assertEquals(false, resp, 'Not added to carousel');
			
	    	Boolean resp2 = carouselContentDSObj.alreadyAddedToCarousel(simpplrContent.id, null, site.id);
			System.assertEquals(true, resp2, 'Added to carousel');
			
	    	Boolean resp3 = carouselContentDSObj.alreadyAddedToCarousel('home', null, null, null);
			System.assertEquals(false, resp3, 'Not added to carousel');
			
	    	Boolean resp4 = carouselContentDSObj.alreadyAddedToCarousel(site.id, null, null, null);
			System.assertEquals(true, resp4, 'Added to carousel');
    	} 
        Test.stopTest();
    }
    
    @isTest
	static void testConvertContentsListTowrapperList(){
    	init();
    	System.runAs(siteMember) {
			CarouselDataServer carouselContentDSObj = new CarouselDataServer();
			List<String> fieldList = carouselContentDSObj.fieldList;
			fieldList.add('(SELECT Id,Order__c,Is_Deleted__c,Site__c FROM Simpplr_Carousel_Contents__r WHERE '+
					' Is_Deleted__c = false LIMIT 1)');
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', UserContext.sitesIFollowIdSet);
			soqlParamMap.put('soqlParam2', DateTime.now());
			soqlParamMap.put('soqlParam3',  '');
			soqlParamMap.put('soqlParam4',  '');
			soqlParamMap.put('soqlParam5',  '');
			soqlParamMap.put('soqlParam6', new List<String>{'Page', 'Event', 'Album', 'Blog'});
			String query = 'SELECT '+String.join(fieldList,',')+' FROM Simpplr_Content__c';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Simpplr_Content__c> listOfContents = (List<Simpplr_Content__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
    		Map<Id, ContentWrapper> result = carouselContentDSObj.convertContentsListTowrapperList(listOfContents);
			System.assertNotEquals(0, result.size(), 'Map should not be empty');
    	}
    }
    
    @isTest
	static void testConvertContentToWrapper(){
    	init();
    	System.runAs(siteMember) {
			Set<Id> sitesIFollowIdSet = UserContext.sitesIFollowIdSet;
			DateTime currentDateTime = DateTime.now();
			Object soqlParam1 = sitesIFollowIdSet;
			Object soqlParam2 = currentDateTime;
			Object soqlParam3 =  '';
			Object soqlParam4 =  '';
			Object soqlParam5 =  '';
			Object soqlParam6 = new List<String>{'Page', 'Event', 'Album', 'Blog'};
			CarouselDataServer carouselContentDSObj = new CarouselDataServer();
			List<String> fieldList=carouselContentDSObj.fieldList;
            String loggedInPeopleId='';
            String siteId='';
			list<Simpplr_Content__c> listOfCarouselContentsInOrder = new list<Simpplr_Content__c>();
			fieldList.add('(SELECT Id,Order__c,Is_Deleted__c,Site__c FROM Simpplr_Carousel_Contents__r WHERE '+
					' Is_Deleted__c = false LIMIT 1)');
			String query = 'SELECT '+String.join(fieldList,',')+' FROM Simpplr_Content__c Limit 1';
    		simpplrContent = Database.query(query);
    		
    		simpplrContent.type__c=ServiceConstants.TYPE_PAGE;
    		ContentWrapper resp = carouselContentDSObj.convertContentToWrapper(1,simpplrContent);
			System.assertEquals('Page', resp.type, 'Running as expected');

    		simpplrContent.type__c=ServiceConstants.TYPE_BLOGPOST;
    		resp = carouselContentDSObj.convertContentToWrapper(1,simpplrContent);
			System.assertEquals('BlogPost', resp.type, 'Running as expected');

            simpplrContent.type__c=ServiceConstants.TYPE_EVENT;
            simpplrContent.Event_Start_DateTime__c=date.today();
			simpplrContent.Event_End_DateTime__c=date.today();
			simpplrContent.Event_TimezoneSidKey__c = 'America/Los_Angeles';
    		resp = carouselContentDSObj.convertContentToWrapper(1,simpplrContent);
			System.assertEquals('Event', resp.type, 'Running as expected');

            simpplrContent.Type__c=ServiceConstants.TYPE_ALBUM;
            resp = carouselContentDSObj.convertContentToWrapper(1, simpplrContent);
			System.assertEquals('Album', resp.type, 'Running as expected');
            
    		simpplrContent.Status__c='Rejected';
    		resp = carouselContentDSObj.convertContentToWrapper(1,simpplrContent);
			System.assertEquals('rejected', resp.status, 'Running as expected');

    		simpplrContent.Status__c='Draft';
    		resp = carouselContentDSObj.convertContentToWrapper(1,simpplrContent);
			System.assertEquals('draft', resp.status, 'Running as expected');

    		simpplrContent.Status__c='Submitted';
    		resp = carouselContentDSObj.convertContentToWrapper(1,simpplrContent);
			System.assertEquals('pending', resp.status, 'Running as expected');
    	}
    	System.assert(true,'Running as expected');
    }
    
    private static People__c getPeople(String userId){
        People__c  peopleRecord = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
        							Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
									From People__c where User__c = :userId LIMIT 1];
        return peopleRecord;
    }
    
    @isTest static void testGetPageFeature() {
		init();
    	CarouselDataServer dSObj= new CarouselDataServer();
    	String res = dSObj.getPageFeature();
    	System.assertEquals('SIMPPLR', res, 'Running as expected');
    }
    @isTest
	static void testHandleRequestGetAnalytics() {
		init();
		Test.startTest();

		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','CarouselDataServer');
		Test.setCurrentPage(pageRef);

		CarouselDataServer carouselContentDSObj= new CarouselDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AnalyticsDataServer/getContentListViews',false));
		pageRef.getParameters().put('action',carouselContentDSObj.ACTION_VALUE_GETANALYTICS);
		carouselContentDSObj.handleRequest();
		System.assertEquals('success', carouselContentDSObj.response.status, 'Running as expected');
		Test.stopTest();
    }
}