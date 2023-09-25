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
private class TileDataServerTest {
	
	static App_Config__c appConfig;
    static user usr;
    static collaborationGroup cgGroup;
    static People__c peopleObj1,peopleObj2;
    static Simpplr_Site__c siteObj;
    static PageReference pageRef;
    static List<App_Integration__c> appIntegrationObjList;
    static List<People_integration__c> peopleIntegrationObjList;
    static Social_Campaign__c campaignObj;
    
    @testSetup static void setup() { 
        
        List<Id> tileIdList = new List<Id>();
	    appConfig = TestHelper.setupAppConfig();
	    Tiles_Config__c tileRecord = TestHelper.createTilesConfigData(null, null, null, 'page','latest');
        tileIdList.add(tileRecord.id);
       
        Tiles_Config__c tileRecord1 = TestHelper.createTilesConfigData(null, null, null, 'content','latest_popular');
        tileIdList.add(tileRecord1.Id);
        appConfig.App_Home_Dashboard_Tile_Ids__c =  String.join(tileIdList, ',');
        update appConfig;
        
        peopleObj1 = TestHelper.createPeopleRecordForUser(UserInfo.getUSerId());
        usr = TestHelper.createUser('TestUser_TileServiceTest',null,false);
        cgGroup = TestHelper.createCollaborationGroup('Test_Group1_TileServiceTest','Public');
        TestHelper.insertMemberToGroup(cgGroup.id,usr.id,'Admin');
        TestHelper.addBookmarkForSite(getSimpplrSite().id,peopleObj1.id);
        TestHelper.createPeoplePreference(peopleObj1.Id);
        TestHelper.createTilesConfigData(null, null, peopleObj1.Id, 'page','latest');
        TestHelper.createTilesConfigData(null, null, peopleObj1.Id, 'content','latest_popular');
        
        TestHelper.createTilesConfigData(null, null, peopleObj1.Id, 'campaigns','latest');
        TestHelper.createTilesConfigData(null, null, null, 'campaigns','latest');
        Simpplr_Site__c siteObj = getSimpplrSite();
        TestHelper.shareSitesToAllPeople(new List<String>{siteObj.Id});
        TestHelper.createContent('TileDataServerTest', 'Page', 'Approved', usr, siteObj);
        TestHelper.createContent('TileDataServerTest', 'Event', 'Approved', usr, siteObj);
        TestHelper.createContent('TileDataServerTest', 'Album', 'Approved', usr, siteObj);
        TestHelper.createContent('TileDataServerTest', 'BlogPost', 'Approved', usr, siteObj);
        TestHelper.createPageCategory(siteObj.id, 'Policy');
        TestHelper.createTilesConfigData(null, siteObj.id, null, 'page','latest');
        TestHelper.addBookmarkForSite(siteObj.id, peopleObj1.id);
        TestHelper.addBookmarkForPeople(peopleObj1.id, peopleObj1.id);
        Segment__c segmentObj = TestHelper.createSegment(peopleObj1.id);
        
        appIntegrationObjList = TestHelper.createAppIntegrationRecords(false, new Set<String>{'twitter', 'facebook', 'linkedin', 'native_video'});
    	peopleIntegrationObjList = TestHelper.createPeopleIntegrationRecords(appIntegrationObjList, peopleObj1.id, 'asdasadasd');
    	campaignObj = TestHelper.createSocialCampaign(peopleObj1.Id);
    	peopleObj1.segment__c=segmentObj.id;
    	update peopleObj1;
    	TestHelper.createTilesConfigData(segmentObj.id, null, null, 'page','latest');
    }
    
    static void init() {
        pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','TileDataServer');
        Test.setCurrentPage(pageRef);
    }
    
     private static Segment__c getSegment(){
     	return [select id from Segment__c limit 1];
     	
     }
     private static Simpplr_Site__c getSimpplrSite(){
         if(siteObj == null) {
             siteObj = [select id,chatter_Group_id__c,name,Landing_Page__c from Simpplr_Site__c where Name='Test_Group1_TileServiceTest' limit 1];
         }
    	return(siteObj) ; 
    }
    
    private static list<Tiles_Config__c> getSiteOrHomeTiles(String siteOrHomeId){
    	List<Tiles_Config__c> tilesList = new List<Tiles_Config__c>();
    	if(String.isNotBlank(siteOrHomeId)){
    		tilesList = [select id,variant__c,type__c from Tiles_Config__c where site__c=:siteOrHomeId and Location__c='Site Dashboard'];
    	}else{
    		tilesList = [select id,variant__c,type__c from Tiles_Config__c where site__c=null and Location__c='Home Dashboard'];
    	}
    	return tilesList;
    }
    
    @isTest static void testHandleRequest() {
    	init();
    	getSimpplrSite();
        pageRef.getParameters().put('siteId',siteObj.id);
         pageRef.getParameters().put('dashboardId',siteObj.id);
        pageRef.getParameters().put('action', 'getTileList');
        Test.setCurrentPage(pageRef);
        
    	TileDataServer tileDataServerObj = new TileDataServer();
    	tileDataServerObj.handleRequest();
    		
    		pageRef.getParameters().put('siteId',null);
    		pageRef.getParameters().put('dashboardId','home');
        Test.setCurrentPage(pageRef);
        tileDataServerObj.handleRequest();
        
        People_Preference__c peoplePreference = [Select Id, Tiles_Initialized__c From People_Preference__c where People__c=:UserContext.peopleId][0];
	    	peoplePreference.Tiles_Initialized__c = true;
	    	update peoplePreference;
        tileDataServerObj.handleRequest();
        
        SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
        tileDataServerObj.handleRequest();

        pageRef.getParameters().put('origin','mobile');
        List<String> listOfTiles = new  List<String>();
        listOfTiles.add('latest_popular_content');
        pageRef.getParameters().put('mobileTileList', Utility.getJsonFormat(listOfTiles));
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
    }
    
    @isTest static void testGetUserHomeTilesOrder() {
    	Test.startTest();
    	init();
    	
    	People_Preference__c peoplePreference = [Select Id, Tiles_Initialized__c From People_Preference__c where People__c=:UserContext.peopleId][0];
    	peoplePreference.Tiles_Initialized__c = true;
    	update peoplePreference;
    	
    	App_Config__c appConfigRecord = [select Id, App_Dashboard_Mode__c from App_Config__c][0];
        appConfigRecord.App_Dashboard_Mode__c = 'User';
        update appConfigRecord;
        
        SimpplrContext.isEmployeeAdvocacyEnabled = false;
        
        ApexPages.currentPage().getParameters().put('siteId',null);
        pageRef.getParameters().put('dashboardId','home');
        ApexPages.currentPage().getParameters().put('action', 'getTileList');
        TileDataServer tileDataServerObj = new TileDataServer();
    	tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');

        pageRef.getParameters().put('origin','mobile');
        List<String> listOfTiles = new  List<String>();
        listOfTiles.add('latest_popular_content');
        pageRef.getParameters().put('mobileTileList', Utility.getJsonFormat(listOfTiles));
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('origin','');
        App_Default__c newAppDefault = TestHelper.setupAppDefault();
        newAppDefault.Type__c = 'home-default';
        newAppDefault.Segment__c = getSegment().Id;
        
        update newAppDefault;
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');

        pageRef.getParameters().put('origin','mobile');
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
    	
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testNoAction() {
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('action', '');
        TileDataServer tileDataServerObj = new TileDataServer();
    	tileDataServerObj.handleRequest();
        
        tileDataServerObj.getPageFeature();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    @isTest static void testGetTileList() {
        Test.startTest();
        init();
        
        Tiles_Config__c tileRecord = TestHelper.createTilesConfigData(getSegment().id, null, null, 'content','latest_popular');
        tileRecord.Variant__c = 'latest_popular';
        update tileRecord;
        TestHelper.createTilesConfigData(getSegment().id, null, null, 'campaigns','latest_popular');
        App_Default__c newAppDefault = TestHelper.setupAppDefault();
        newAppDefault.Type__c = 'home-default';
        newAppDefault.Segment__c = getSegment().Id;
        newAppDefault.Data__c = tileRecord.id;
        update newAppDefault;
        TileDataServer tileDataServerObj = new TileDataServer();
        ApexPages.currentPage().getParameters().put('dashboardId','home');
        ApexPages.currentPage().getParameters().put('action', 'getTileList');
        ApexPages.currentPage().getParameters().put('origin','mobile');
        List<String> listOfTiles = new  List<String>();
        listOfTiles.add('latest_popular_content');
        ApexPages.currentPage().getParameters().put('mobileTileList', Utility.getJsonFormat(listOfTiles));
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
        ApexPages.currentPage().getParameters().put('origin','');
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');

	    SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
    	tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
        ApexPages.currentPage().getParameters().put('origin','mobile');
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');

        SimpplrContext.isSegmentsEnabled = true;
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');   
        ApexPages.currentPage().getParameters().put('origin','');
        tileDataServerObj.handleRequest();
        System.assertEquals('error', tileDataServerObj.response.status, 'Segment is enabled but segment id is not define (for web)');

        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
        ApexPages.currentPage().getParameters().put('origin','mobile');
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');

        SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_USER;
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
        ApexPages.currentPage().getParameters().put('origin','');
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
    	      
        tileRecord.Type__c = 'campaigns';
        update tileRecord;
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
        ApexPages.currentPage().getParameters().put('origin','mobile');
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');

        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    
    
    @isTest static void testGetAppManagerHomeTilesOrder() {
    	Test.startTest();
    	init();
        App_Config__c appConfig = TestHelper.getAppConfig();
        
        Tiles_Config__c tilesConfigObj = [Select Id From Tiles_Config__c Where Type__c = 'content' Limit 1];
        Tiles_Config__c tilesConfigCampaignsObj = [Select Id From Tiles_Config__c Where Type__c = 'campaigns' Limit 1];
        appConfig.App_Home_Dashboard_Tile_Ids__c = tilesConfigObj.Id + ',' + tilesConfigCampaignsObj.Id;
        update appConfig;
        tilesConfigObj.People__c = null;
        tilesConfigObj.Variant__c = 'latest_popular';
        tilesConfigObj.Variant_Type__c = 'latest_popular_content';
        update tilesConfigObj;
        
        tilesConfigCampaignsObj.People__c = null;
        update tilesConfigCampaignsObj;

    	SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
        SimpplrContext.isEmployeeAdvocacyEnabled = false;
        ApexPages.currentPage().getParameters().put('siteId', null);
        pageRef.getParameters().put('dashboardId','home');
        ApexPages.currentPage().getParameters().put('action', 'getTileList');
        TileDataServer tileDataServerObj = new TileDataServer();
    	tileDataServerObj.handleRequest();
    	System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
       
        List<String> listOfTiles = new  List<String>();
        listOfTiles.add('latest_popular_content');
        ApexPages.currentPage().getParameters().put('mobileTileList', Utility.getJsonFormat(listOfTiles));
        ApexPages.currentPage().getParameters().put('origin','mobile');
        tileDataServerObj.handleRequest();
        System.assertEquals('success', tileDataServerObj.response.status, 'Running as expected');
    	Test.stopTest();
    }
   
    @isTest static void testAddHomeTiles() {
		Test.startTest();
    	init();
		Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
		People__c peopleObj = [select id from People__c limit 1];
        
        Segment__c segmentObj = [Select Id From Segment__c Limit 1];
        peopleObj.Joining_Date__c = date.today() - 2;
        peopleObj.Segment__c = segmentObj.Id;
        update peopleObj;
        
    	SimpplrContext.isEmployeeAdvocacyEnabled = false;
    	TileDataServer tileDataServerObj = new TileDataServer();
        ApexPages.currentPage().getParameters().put('dashboardId','home');
        ApexPages.currentPage().getParameters().put('action', 'addTile');

        //Latest & Popular tile        
		String tileJson = '{"title":"Latest & Popular","options":{"type":"all","siteFilter":"following","siteId":null,"layout":"standard"},"pushToAllHomeDashboards":false,"items":[],"type":"content","variant":"latest_popular"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//Celebrations tile
    	tileJson = '{"title":"Celebrations","options":{},"pushToAllHomeDashboards":false,"items":[],"type":"people","variant":"celebrations"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//Rich Text tile
    	tileJson = '{"title":"Text","options":{"text":"<p>Some Text</p>"},"pushToAllHomeDashboards":false,"items":[],"type":"html","variant":"text"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//Links tile
        tileJson = '{"title":"Links","options":{"layout":"standard","links":[{"imageFile":{},"text":"Google","url":"Google.com","oembed":{"provider_url":"http://www.google.com","url":"http://www.google.com/","thumbnail_width":272,"version":"1.0","title":"Google","provider_name":"Google","type":"link","thumbnail_height":92,"thumbnail_url":"http://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png","description":"Search the worlds information, including webpages, images, videos and more. Google has many special features to help you find exactly what you are looking for."}}]},"pushToAllHomeDashboards":false,"items":[],"type":"links","variant":"custom"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//html tile
    	tileJson = '{"title":"HTML","options":{"code":"<h1>","height":"500"},"pushToAllHomeDashboards":false,"items":[],"type":"html","variant":"iframe"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//image tile
    	tileJson = '{"title":"Image","options":{"imageFile":null,"title":null,"url":null,"showInfo":true},"pushToAllHomeDashboards":false,"items":[],"type":"media","variant":"image"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//video tile
    	tileJson = '{"title":"Video","options":{"url":"https://www.youtube.com/watch?v=0qW0xe9kvQQ","title":"","description":"TIle","oembed":{"provider_url":"https://www.youtube.com/","width":854,"height":480,"html":"<h1>","url":"http://www.youtube.com/watch?v=0qW0xe9kvQQ","thumbnail_width":480,"version":"1.0","title":"Simpplr Product Demo","provider_name":"YouTube","type":"video","thumbnail_height":360,"author_url":"https://www.youtube.com/channel/UCBSkpP2rV2Ql3t5mKPF3zmw","thumbnail_url":"https://i.ytimg.com/vi/0qW0xe9kvQQ/hqdefault.jpg","description":"Description","author_name":"Simpplr"},"showInfo":true,"initialUrl":"https://www.youtube.com/watch?v=0qW0xe9kvQQ"},"pushToAllHomeDashboards":false,"items":[],"type":"media","variant":"video"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//Site Categories tile
        tileJson = '{"title":"Site Categories","options":{"size":"3","links":{"imageFile:{}}},"pushToAllHomeDashboards":false,"items":[],"type":"site_categories","variant":"default"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//Custom Content tile
    	tileJson = '{"title":"Custom Content","options":{"siteFilter":null,"siteId":null,"layout":"standard"},"pushToAllHomeDashboards":false,"items":["a0n1I000003Ien7QAC"],"type":"content","variant":"custom"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//facebook tile
        tileJson = '{"title":"Facebook","options":{"url":"https://facebook.com/simpplr","height":500,"showPosts":true,"showFaces":true,"showCover":true},"pushToAllHomeDashboards":false,"items":[],"type":"facebook","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//Twitter tile
    	tileJson = '{"title":"Twitter","options":{"code":"some code"},"pushToAllHomeDashboards":false,"items":[],"type":"twitter","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//latest & popular campaign tile
    	tileJson = '{"title":"Latest & Popular","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"items":[],"type":"campaigns","variant":"latest_popular"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
        
    	// custom campaign tile
    	tileJson = '{"title":"Custom Social Campaigns","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"items":["a0z1I0000023LbzQAE"],"type":"campaigns","variant":"custom"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();

		// new hire tile
    	tileJson = '{"title":"Custom Social Campaigns","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"type":"people","variant":"new_hires"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('siteId',siteObj.Id);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().Id);
    	tileDataServerObj.handleRequest();

		// sites tile
    	tileJson = '{"title":"Custom Social Campaigns","options":{"layout":"standard"},"pushToAllHomeDashboards":true,"items":["' + siteObj.id+ '"],"type":"sites","variant":"custom"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();

		// custom people
    	tileJson = '{"title":"Custom Social Campaigns","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"items":["' + peopleObj.id+ '"],"type":"people","variant":"custom"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
        
        //site_members people 
       	tileJson = '{"title":"Custom Social Campaigns","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"items":["' + peopleObj.id+ '"],"type":"people","variant":"site_members"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('siteId' , siteObj.Id);
    	tileDataServerObj.handleRequest();
        
        //site_managers people
		tileJson = '{"title":"Custom Social Campaigns","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"items":["' + peopleObj.id+ '"],"type":"people","variant":"site_managers"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('siteId' , siteObj.Id);
    	tileDataServerObj.handleRequest();
				
        // salesforce_apps tile
    	tileJson = '{"title":"Custom Social Campaigns","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"type":"salesforce_apps","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();

        // recognition tile
    	tileJson = '{"title":"Recognition","pushToAllHomeDashboards":false,"type":"recognition_nominations","variant":"default"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testAddSiteTiles() {
		Test.startTest();
    	init();
    	Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
    	TileDataServer tileDataServerObj = new TileDataServer();
        ApexPages.currentPage().getParameters().put('siteId',siteObj.Id);
        ApexPages.currentPage().getParameters().put('dashboardId','site');
        ApexPages.currentPage().getParameters().put('action', 'addTile');

        String tileJson = '{"title":"Latest & Popular","options":{"type":"all","siteFilter":"googleCalendar","calendar":{"name":"Birthdays","id":"addressbook#contacts@group.v.calendar.google.com"},"siteId":null,"layout":"standard"},"pushToAllHomeDashboards":false,"items":[],"type":"content","variant":"latest_popular"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        tileDataServerObj.handleRequest();
        
		//Pages from Category
		tileJson = '{"title":"Pages from Category","options":{"siteFilter":null,"siteId":null,"layout":"standard","pageCategoryId":"a0f1I000001WrHPQA0"},"pushToAllHomeDashboards":false,"items":[],"type":"content","variant":"from_category"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//Pages Categories
    	Pages_Category__c newPageCategory = TestHelper.createPageCategory(siteObj.id, 'Policy');
        Simpplr_Content__c newContent = new Simpplr_Content__c(Pages_Category__c = newPageCategory.id,Site__c = siteObj.id,is_deleted__c = false);
        insert newContent;
		tileJson = '{"title":"Page Categories","options":{"size":5},"pushToAllHomeDashboards":false,"items":[],"type":"page_categories","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('siteId' , siteObj.id);
    	tileDataServerObj.handleRequest();
    		
    	//Site Information
		tileJson = '{"title":"Site Information","options":{"text":"<p>Something</p>"},"pushToAllHomeDashboards":false,"items":[],"type":"site_info","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    		
    	//Site About
		tileJson = '{"title":"Site Information","options":{"text":"<p>Something</p>"},"pushToAllHomeDashboards":false,"items":[],"type":"site_about","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();
    	
		//RSS
		tileJson = '{"options":{"size":5},"pushToAllHomeDashboards":false,"items":[],"type":"rss","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
    	tileDataServerObj.handleRequest();

		//files
        tileJson = '{"options":{"size":5,"value":"dummy1"},"pushToAllHomeDashboards":false,"items":["+testFile.Id+","+dummy[0].Id+"],"type":"files","variant":"intranet"}'; 
		ApexPages.currentPage().getParameters().put('tile', tileJson);
		tileDataServerObj.handleRequest();
        
        //files with variant
        tileJson = '{"options":{"size":5,"value":"test","files":[{"url":"dummy"}]},"pushToAllHomeDashboards":false,"items":[],"type":"files","variant":"box","listOfItems":[{"title":".dummy"}]}'; 
		ApexPages.currentPage().getParameters().put('tile', tileJson);
		tileDataServerObj.handleRequest();

        tileJson = '{"options":{"size":5,"value":"test","type":"recent_and_starred"},"pushToAllHomeDashboards":false,"items":[],"type":"files","variant":"googledrive","listOfItems":[{"title":".dummy"}]}'; 
		ApexPages.currentPage().getParameters().put('tile', tileJson);
		tileDataServerObj.handleRequest();
        
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCreateUserDefaultTiles() {
    	Test.startTest();
    	init();
    	
	    People_Preference__c peoplePreference = [Select Id, Tiles_Initialized__c From People_Preference__c where People__c=:UserContext.peopleId][0];
	    peoplePreference.Tiles_Initialized__c = false;
	    update peoplePreference;
	    	
	    SimpplrContext.AppDashboardMode = 'User';
        TileDataServer tileDataServerObj = new TileDataServer();
        String tileJson1 = '{"title":"Latest Albums","options":{"size":"2","siteFilter":"following","siteId":null},"description":null,"pushToAllHomeDashboards":false,"items":[],"type":"content","variant":"latest_popular"}';
        
        ApexPages.currentPage().getParameters().put('siteId', null);
        ApexPages.currentPage().getParameters().put('dashboardId','home-default');
        ApexPages.currentPage().getParameters().put('tile', tileJson1);
        ApexPages.currentPage().getParameters().put('action', 'addTile');
		tileDataServerObj.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getTileList');
	    tileDataServerObj.handleRequest();
	    	
	    ApexPages.currentPage().getParameters().put('dashboardId', 'home');
	    ApexPages.currentPage().getParameters().put('action', 'addTile');
	    tileDataServerObj.handleRequest();
        
	    SimpplrContext.AppDashboardMode = 'Manager';
		tileDataServerObj.handleRequest();
	    	
        ApexPages.currentPage().getParameters().put('action', 'getTileList');
        tileDataServerObj.handleRequest();
	    	
    	Tiles_config__c tileObj = [select id from tiles_config__c  limit 1];
        ApexPages.currentPage().getParameters().put('action', 'removeTile');
        
	    tileDataServerObj.handleRequest();
        ApexPages.currentPage().getParameters().put('dashboardId', 'home-default');
        tileDataServerObj.handleRequest();
        
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetTileOnSiteDashboard() {
    	Test.startTest();
        init();
        
        Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
        String siteId = siteObj.id;
        
        List<Tiles_Config__c> siteTiles = getSiteOrHomeTiles(siteId);
        
        TileDataServer tileDataServerObj = new TileDataServer();
        for(Tiles_Config__c tileObj : siteTiles){
        	ApexPages.currentPage().getParameters().put('siteId',siteId);
        	ApexPages.currentPage().getParameters().put('dashboardId','site');
	        ApexPages.currentPage().getParameters().put('tileId',tileObj.Id);
	        ApexPages.currentPage().getParameters().put('action', 'getTile');
	        tileDataServerObj.handleRequest();
        }
    	
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetTile() {
    	Test.startTest();
        init();
        Site_Category__c siteCategoryObj = TestHelper.createSiteCategory();
        CollaborationGroup cg = [Select Id From CollaborationGroup Limit 1];
        
        Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
        siteObj.Site_Category__c = siteCategoryObj.Id;
        update siteObj;
        String siteId = siteObj.id;
        
        Tiles_Config__c tileObj = [Select Id From Tiles_Config__c Limit 1];
        tileObj.Variant__c = 'custom';
        tileObj.Type__c = 'sites';
        tileObj.Data__c = '{"value" : "'+cg.Id+'",  "layout" : "list"}';
        update tileObj;
        
        TileDataServer tileDataServerObj = new TileDataServer();
        ApexPages.currentPage().getParameters().put('siteId',siteId);
        ApexPages.currentPage().getParameters().put('dashboardId','site');
	    ApexPages.currentPage().getParameters().put('tileId',tileObj.Id);
	    ApexPages.currentPage().getParameters().put('action', 'getTile');
	    tileDataServerObj.handleRequest();
        
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetTileForFile() {
    	Test.startTest();
        init();
        ContentVersion obj = TestHelper.createContentVersion('bsnbmasbdm', 'File_01');
		ContentVersion cv = [select id, ContentDocumentId from ContentVersion where id=:obj.id];
        
        Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
        String siteId = siteObj.id;
        
        Tiles_Config__c tileObj = [Select Id From Tiles_Config__c Limit 1];
        tileObj.Variant__c = 'intranet';
        tileObj.Type__c = 'files';
        tileObj.Data__c = '{"value" : "'+cv.ContentDocumentId+'"}';
        update tileObj;
        
        TileDataServer tileDataServerObj = new TileDataServer();
        ApexPages.currentPage().getParameters().put('siteId',siteId);
        ApexPages.currentPage().getParameters().put('dashboardId','site');
	    ApexPages.currentPage().getParameters().put('tileId',tileObj.Id);
	    ApexPages.currentPage().getParameters().put('action', 'getTile');
	    tileDataServerObj.handleRequest();
        
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testAddTileSiteDashboard1() {
    	Test.startTest();
    	init();
    	TileDataServer tileDataServerObj = new TileDataServer();
		
        
    	Simpplr_Site__c siteObj = [Select id,chatter_Group_id__c from Simpplr_Site__c where Name='Test_Group1_TileServiceTest' limit 1] ;
        
        // Add a non lib tile on site dashboard
        String tileJson1 = '{"items":[],"isSaving":false,"variant":"standard","tileId":null,"title":"Countdown Clock DS","type":"countdown","description":null,"options":{"stopAt":"2016-10-13T23:00:00","endMessage":"asasd"}}';
        ApexPages.currentPage().getParameters().put('siteId', siteObj.Id);
        Tiles_Config__c tempTile = TestHelper.createTilesConfigData(null , siteObj.Id , null,'content', 'latest_popular');
        tempTile.Variant__c = 'latest_Popular';
        update tempTile;
        TestHelper.createTilesConfigData(null , siteObj.Id , null,'campaigns', 'latest_popular');
        TestHelper.createTilesConfigData(null , siteObj.Id , null,'site_info', 'latest_popular');
        	ApexPages.currentPage().getParameters().put('dashboardId', 'site');
        ApexPages.currentPage().getParameters().put('tile', tileJson1);
        ApexPages.currentPage().getParameters().put('action', 'addTile');
    	tileDataServerObj.handleRequest();
    	
        ApexPages.currentPage().getParameters().put('action', 'getTileList');
        	tileDataServerObj.handleRequest();
        
         tileJson1 = '{"title":"Latest Albums","options":{"size":"2","siteFilter":"following","siteId":null},"description":null,"pushToAllHomeDashboards":false,"items":[],"type":"campaigns","variant":"latest_popular"}';
	    ApexPages.currentPage().getParameters().put('tile', tileJson1);
        //ApexPages.currentPage().getParameters().put('dashboardId', 'home');
        //ApexPages.currentPage().getParameters().put('action', 'getTileList');
        tileDataServerObj.handleRequest();
    	
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }

    @isTest static void testSetLayout() {
    	Test.startTest();
    	Simpplr_Site__c siteObj = [select Id, Layout__c from Simpplr_Site__c  where Name='Test_Group1_TileServiceTest' limit 1];
        init();
        
        ApexPages.currentPage().getParameters().put('siteId', siteObj.Id);
        ApexPages.currentPage().getParameters().put('dashboardId', 'site');
        ApexPages.currentPage().getParameters().put('layout', 'd');
        ApexPages.currentPage().getParameters().put('action', 'setLayout');
        TileDataServer tileDataServerObj = new TileDataServer();
		tileDataServerObj.handleRequest();
		
		ApexPages.currentPage().getParameters().put('dashboardId','home-default');
		ApexPages.currentPage().getParameters().put('siteId',null);
		tileDataServerObj.handleRequest();
		ApexPages.currentPage().getParameters().put('dashboardId','home');
		tileDataServerObj.handleRequest();
		
		ApexPages.currentPage().getParameters().put('layout', 'd');
		tileDataServerObj.handleRequest();
		
		ApexPages.currentPage().getParameters().put('layout', 'd');
		tileDataServerObj.handleRequest();
		SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
		tileDataServerObj.handleRequest();
		
		SimpplrContext.isSegmentsEnabled = true;
		ApexPages.currentPage().getParameters().put('dashboardId','home');
		ApexPages.currentPage().getParameters().put('layout', 'd');
		ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
		tileDataServerObj.handleRequest();
		
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest 
    static void testSetUserHomeDashboardPosition() {
	    Test.startTest();
        App_Default__c appDefault = TestHelper.setupAppDefault();
        appDefault.Type__c = 'home-default';
        appDefault.Segment__c = getSegment().Id;
        update appDefault;
        
	    Tiles_Config__c TileObj =  [select id from Tiles_Config__c limit 1];
	    String position = '{"1":["' + TileObj.id + '"]}';
        init();
		       
        ApexPages.currentPage().getParameters().put('position', position);
        ApexPages.currentPage().getParameters().put('action', 'setPositions');
        ApexPages.currentPage().getParameters().put('dashboardId','home');
        TileDataServer tileDataServerObj = new TileDataServer();
		tileDataServerObj.handleRequest();
    		
		SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
	     
	    tileDataServerObj.handleRequest();
	    SimpplrContext.isSegmentsEnabled = true;
	    ApexPages.currentPage().getParameters().put('segmentId',getSegment().id); 
	    tileDataServerObj.handleRequest();
	     
	    ApexPages.currentPage().getParameters().put('dashboardId','home-default');
    	tileDataServerObj.handleRequest();
	     
	    Simpplr_Site__c siteObj = [Select id,chatter_Group_id__c from Simpplr_Site__c where Name='Test_Group1_TileServiceTest' limit 1] ;
        ApexPages.currentPage().getParameters().put('siteId',siteObj.id);
        ApexPages.currentPage().getParameters().put('dashboardId', 'site');
        tileDataServerObj.handleRequest();
         
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    
     @isTest static void testEditTileOnSiteDashboard() {
     	Test.startTest();
    	init();
    	TileDataServer tileDataServerObj = new TileDataServer();
         
    	Simpplr_Site__c siteObj = [Select id,chatter_Group_id__c from Simpplr_Site__c where Name='Test_Group1_TileServiceTest' limit 1] ;
    	
    	String tileJson1 = '{"items":[],"isSaving":false,"variant":"standard","tileId":null,"title":"Countdown Clock DS","type":"countdown","description":null,"options":{"stopAt":"2016-10-13T23:00:00","endMessage":"asasd"}}';
    	ApexPages.currentPage().getParameters().put('siteId', siteObj.Id);
		ApexPages.currentPage().getParameters().put('dashboardId', 'site');
        ApexPages.currentPage().getParameters().put('tile', tileJson1);
        ApexPages.currentPage().getParameters().put('action', 'addTile');
    	tileDataServerObj.handleRequest();
    	
    	Tiles_config__c tileObj = [select id from tiles_config__c where Name__c='Countdown Clock DS' limit 1];
         
    	
         
         ContentVersion obj = TestHelper.createContentVersion('bsnbmasbdm', 'File_01');
		ContentVersion cv=[select id, ContentDocumentId from ContentVersion where id=:obj.id];
         
         ContentVersion obj1 = TestHelper.createContentVersion('bsnbmasbdm', 'File_02');
         		ContentVersion cv1=[select id, ContentDocumentId from ContentVersion where id=:obj1.id];

         
         String changedTileJson1 = '{"items":[],"isSaving":false,"variant":"standard","tileId":null,"title":"Countdown Clock DS","type":"countdown","description":null,"options":{"stopAt":"2016-10-13T23:00:00","endMessage":"asasd","imageFile":{"contentDocumentId":"'+cv.ContentDocumentId+'"},"links":[{"imageFile":{"contentDocumentId":"'+cv1.ContentDocumentId+'"}}]}}';
        ApexPages.currentPage().getParameters().put('tile', changedTileJson1);
        ApexPages.currentPage().getParameters().put('tileId', tileObj.id);
        ApexPages.currentPage().getParameters().put('action', 'editTile');
        ApexPages.currentPage().getParameters().put('siteId' , siteObj.Id);
    	tileDataServerObj.handleRequest();
    	
         
    	ApexPages.currentPage().getParameters().put('siteId',  null);
    	ApexPages.currentPage().getParameters().put('dashboardId', 'home');
    	tileDataServerObj.handleRequest();
    	
        App_Default__c temp = TestHelper.setupAppDefault();
         temp.Type__c = 'home-default';
         temp.Segment__c = getSegment().Id;
         update temp;
    	ApexPages.currentPage().getParameters().put('siteId',  siteObj.Id);
    	ApexPages.currentPage().getParameters().put('dashboardId', 'home-default');
         ApexPages.currentPage().getParameters().put('segmentId' , getSegment().Id);
    	tileDataServerObj.handleRequest();
    	
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testResetToDefaultHomeDashboard() {
    		init();
        //Added Part
        Id segId = getSegment().Id;
       	Tiles_Config__c tileRecord = TestHelper.createTilesConfigData(segId, null, null, 'home-default','latest');
        
        App_Default__c newAppDefault = TestHelper.setupAppDefault();
        newAppDefault.Type__c = 'home-default';
        newAppDefault.Segment__c = segId;
        newAppDefault.Data__c = tileRecord.id;
        update newAppDefault;
        //Ends
		TileDataServer tileDataServerObj = new TileDataServer();
		pageRef.getParameters().put('dashboardId',  'home-default');
        pageRef.getParameters().put('action', 'resetToDefault');
        pageRef.getParameters().put('segmentId' , segId);
        Test.setCurrentPage(pageRef);
		tileDataServerObj.handleRequest();
	
		SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
        
		pageRef.getParameters().put('dashboardId',  'home');
        pageRef.getParameters().put('action', 'resetToDefault');
        Test.setCurrentPage(pageRef);
		tileDataServerObj.handleRequest();
	
		pageRef.getParameters().put('dashboardId',  'home');
        pageRef.getParameters().put('action', 'applyDefaultHomeToAllUsers');
        Test.setCurrentPage(pageRef);
		tileDataServerObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetAppManagerHomeTilesOrder1() {
		Test.startTest();
		init();
    	
                appConfig = TestHelper.setupAppConfig();
    	Tiles_Config__c newTiles = TestHelper.createTilesConfigData(null, null, null, 'content','latest_popular');
        appConfig.App_Home_Dashboard_Tile_Ids__c = newTiles.id;
        update appConfig;
        
    		SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
        
        ApexPages.currentPage().getParameters().put('siteId', 'home');
        ApexPages.currentPage().getParameters().put('dashboardId', 'home');
        ApexPages.currentPage().getParameters().put('action', 'getTileList');
        TileDataServer tileDataServerObj = new TileDataServer();
    	tileDataServerObj.handleRequest();
    	
    	Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetsetSegmentDashboardPosition() {
		Test.startTest();
	    	Tiles_Config__c TileObj =  [select id from Tiles_Config__c limit 1];
	    	String position = '{"1":["' + TileObj.id + '"]}';
        init();
		       
        ApexPages.currentPage().getParameters().put('position', position);
        ApexPages.currentPage().getParameters().put('action', 'setPositions');
        ApexPages.currentPage().getParameters().put('dashboardId','home');
        TileDataServer tileDataServerObj = new TileDataServer();
		tileDataServerObj.handleRequest();
    		
	    SimpplrContext.isSegmentsEnabled = true;
	    tileDataServerObj.handleRequest();
	     
	    ApexPages.currentPage().getParameters().put('segmentId',getSegment().id); 
	    tileDataServerObj.handleRequest();
	     
    	ApexPages.currentPage().getParameters().put('positionJson',position);
    	tileDataServerObj.handleRequest();
        tileDataServerObj.handleRequest();
         
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testAddTileOnSegmentDashboard() {
		Test.startTest();
		init();
		TileDataServer tileDataServerObj = new TileDataServer();
		SimpplrContext.isSegmentsEnabled = true;
		SimpplrContext.AppDashboardMode = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER;
        ApexPages.currentPage().getParameters().put('dashboardId','home');
        ApexPages.currentPage().getParameters().put('action', 'addTile');
		ApexPages.currentPage().getParameters().put('segmentId',getSegment().id); 
		//Latest & Popular tile
		
		String tileJson = '{"title":"Latest & Popular","options":{"type":"all","siteFilter":"following","siteId":null,"layout":"standard"},"pushToAllHomeDashboards":false,"items":[],"type":"content","variant":"latest_popular"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
		tileDataServerObj.handleRequest();
    		
    		//Celebrations tile
    	tileJson = '{"title":"Celebrations","options":{},"pushToAllHomeDashboards":false,"items":[],"type":"people","variant":"celebrations"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    	tileDataServerObj.handleRequest();
    		
    		//Rich Text tile
		tileJson = '{"title":"Text","options":{"text":"<p>Some Text</p>"},"pushToAllHomeDashboards":false,"items":[],"type":"html","variant":"text"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    	tileDataServerObj.handleRequest();
    		
    		//Links tile
		tileJson = '{"title":"Links","options":{"layout":"standard","links":[{"text":"Google","url":"Google.com","oembed":{"provider_url":"http://www.google.com","url":"http://www.google.com/","thumbnail_width":272,"version":"1.0","title":"Google","provider_name":"Google","type":"link","thumbnail_height":92,"thumbnail_url":"http://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png","description":"Search the worlds information, including webpages, images, videos and more. Google has many special features to help you find exactly what you are looking for."}}]},"pushToAllHomeDashboards":false,"items":[],"type":"links","variant":"custom"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
		tileDataServerObj.handleRequest();
    		
    		//html tile
		tileJson = '{"title":"HTML","options":{"code":"<h1>","height":"500"},"pushToAllHomeDashboards":false,"items":[],"type":"html","variant":"iframe"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
		tileDataServerObj.handleRequest();
    		
    		//image tile
    	tileJson = '{"title":"Image","options":{"imageFile":null,"title":null,"url":null,"showInfo":true},"pushToAllHomeDashboards":false,"items":[],"type":"media","variant":"image"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    	tileDataServerObj.handleRequest();
    		
        //youtube video tile
        tileJson = '{"title":"Video","options":{"videoFile": {}, "url":"https://www.youtube.com/watch?v=0qW0xe9kvQQ","title":"","description":"TIle","oembed":{"provider_url":"https://www.youtube.com/","width":854,"height":480,"html":"<h1>","url":"http://www.youtube.com/watch?v=0qW0xe9kvQQ","thumbnail_width":480,"version":"1.0","title":"Simpplr Product Demo","provider_name":"YouTube","type":"video","thumbnail_height":360,"author_url":"https://www.youtube.com/channel/UCBSkpP2rV2Ql3t5mKPF3zmw","thumbnail_url":"https://i.ytimg.com/vi/0qW0xe9kvQQ/hqdefault.jpg","description":"Description","author_name":"Simpplr"},"showInfo":true,"initialUrl":"https://www.youtube.com/watch?v=0qW0xe9kvQQ"},"pushToAllHomeDashboards":false,"items":[],"type":"media","variant":"video"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    		tileDataServerObj.handleRequest();

        //native_video tile
        tileJson = '{"title":"Video","options":{"url":"https://www.youtube.com/watch?v=0qW0xe9kvQQ","title":"","description":"TIle","oembed":{"provider_url":"https://www.youtube.com/","width":854,"height":480,"html":"<h1>","url":"http://www.youtube.com/watch?v=0qW0xe9kvQQ","thumbnail_width":480,"version":"1.0","title":"Simpplr Product Demo","provider_name":"YouTube","type":"video","thumbnail_height":360,"author_url":"https://www.youtube.com/channel/UCBSkpP2rV2Ql3t5mKPF3zmw","thumbnail_url":"https://i.ytimg.com/vi/0qW0xe9kvQQ/hqdefault.jpg","description":"Description","author_name":"Simpplr"},"showInfo":true,"initialUrl":"https://www.youtube.com/watch?v=0qW0xe9kvQQ"},"pushToAllHomeDashboards":false,"items":[],"type":"media","variant":"video"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
        tileDataServerObj.handleRequest();
        
        	//campaign tile
        tileJson = '{"title":"Video","options":{"url":"https://www.youtube.com/watch?v=0qW0xe9kvQQ","title":"","description":"TIle","oembed":{"provider_url":"https://www.youtube.com/","width":854,"height":480,"html":"<h1>","url":"http://www.youtube.com/watch?v=0qW0xe9kvQQ","thumbnail_width":480,"version":"1.0","title":"Simpplr Product Demo","provider_name":"YouTube","type":"campaign","thumbnail_height":360,"author_url":"https://www.youtube.com/channel/UCBSkpP2rV2Ql3t5mKPF3zmw","thumbnail_url":"https://i.ytimg.com/vi/0qW0xe9kvQQ/hqdefault.jpg","description":"Description","author_name":"Simpplr"},"showInfo":true,"initialUrl":"https://www.youtube.com/watch?v=0qW0xe9kvQQ"},"pushToAllHomeDashboards":false,"items":["dummy1","dummy2"],"type":"campaign","variant":"video"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    		tileDataServerObj.handleRequest();
    		
    		//Site Categories tile
    		tileJson = '{"title":"Site Categories","options":{"size":"3"},"pushToAllHomeDashboards":false,"items":[],"type":"site_categories","variant":"default"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    		tileDataServerObj.handleRequest();
    		
    		//Custom Content tile
    		tileJson = '{"title":"Custom Content","options":{"siteFilter":null,"siteId":null,"layout":"standard"},"pushToAllHomeDashboards":false,"items":["a0n1I000003Ien7QAC"],"type":"content","variant":"custom"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    		tileDataServerObj.handleRequest();
    		
    		//facebook tile
    		tileJson = '{"title":"Facebook","options":{"url":"https://facebook.com/simpplr","height":500,"showPosts":true,"showFaces":true,"showCover":true},"pushToAllHomeDashboards":false,"items":[],"type":"facebook","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    		tileDataServerObj.handleRequest();
    		
    		//Twitter tile
    		tileJson = '{"title":"Twitter","options":{"code":"some code"},"pushToAllHomeDashboards":false,"items":[],"type":"twitter","variant":"standard"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    		tileDataServerObj.handleRequest();
    		
    		//latest & popular campaign tile
    		tileJson = '{"title":"Latest & Popular","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"items":[],"type":"campaigns","variant":"latest_popular"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    		tileDataServerObj.handleRequest();
    		
    		// custom campaign tile
    		tileJson = '{"title":"Custom Social Campaigns","options":{"layout":"standard"},"pushToAllHomeDashboards":false,"items":["a0z1I0000023LbzQAE"],"type":"campaigns","variant":"custom"}'; 
        ApexPages.currentPage().getParameters().put('tile', tileJson);
        ApexPages.currentPage().getParameters().put('segmentId',getSegment().id);
    		tileDataServerObj.handleRequest();
    		
    		Test.stopTest();
        System.assert(true,'Running as expected');
    }
   
    @isTest static void testGetGmtDateTimeFromStringDate(){
        TileService tileServiceObj = new TileService();
        String stopDate = 'Feb 2 2000';
        String stopTime = '23:00:00';
        Test.startTest();
        Datetime datetimeActual = tileServiceObj.getGmtDateTimeFromStringDate(stopDate , stopTime);
        Test.stopTest();
        Datetime datetimeExpected =  Datetime.newInstanceGmt(2000, 2, 2, 23, 00, 00);
        System.assertEquals(datetimeExpected,datetimeActual,'Running as expected');
    }
    
    /**
     * @description test case when aiContentRecommendation is enabled
     */
    @isTest static void testGetTileWithAIContentRecommended() {
        
        init();
        TileDataServer tileDSObj = new TileDataServer();
        PageReference pageRef = Page.DataServerRW;
        
        ContentVersion obj = TestHelper.createContentVersion('bsnbmasbdm', 'File_01');
		ContentVersion cv = [select id, ContentDocumentId from ContentVersion where id=:obj.id];
        
        Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
        String siteId = siteObj.id;
        
        Simpplr_Content__c contentObj = [select id from Simpplr_Content__c where Title__c='TileDataServerTest' limit 1];

        Tiles_Config__c tileObj = [Select Id, Variant__c, Type__c, Data__c From Tiles_Config__c Limit 1];
        tileObj.Variant__c = 'latest_popular';
        tileObj.Type__c = 'content';
        tileObj.Data__c = '{"value" : "'+cv.ContentDocumentId+'", "type": "all"}';
        update tileObj;
        SimpplrContext.aiFeaturesEnabled = '100100000';
        
        pageRef.getParameters().put('siteId',siteId);
        pageRef.getParameters().put('dashboardId','home');
        pageRef.getParameters().put('tileId',tileObj.Id);
        pageRef.getParameters().put('action', 'getTile');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        String resBody = '{"content_recommendations":{"'+UserContext.peopleId+'":[{"Simpplr__Content__Id":"'+contentObj.Id+'","score":0.9033308060290319,"message":"Recommendations from AI Model"}]},"version":"1.0","code_version":"1.0.1","status":"success"}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'recommendation', resBody, false)); 
        tileDSObj.handleRequest();
        System.assertEquals('success', tileDSObj.response.status, 'Running as Expected');
        Test.stopTest();
	}
    
    @isTest static void testOnboardingTile() {
        Test.startTest();
        init();
        SimpplrContext.isFeatureContentOnboardingEnabled = true;
        UserContext.isNewHire = true;
        TileDataServer tileDataServerObj = new TileDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'TileDataServer');
        pageRef.getParameters().put('action', 'addTile');
        pageRef.getParameters().put('dashboardId','home');
        
        // onboarding homedashboard tile
    	String tileJson = '{"title":"Onboarding", "options":{"layout":"standard"}, "pushToAllHomeDashboards":false, "type":"content", "variant":"content_onboarding"}'; 
        pageRef.getParameters().put('tile', tileJson);
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchContents',true));
    	tileDataServerObj.handleRequest();
        // onboarding sitedashboard tile
        Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
        pageRef.getParameters().put('dashboardId','site');
        pageRef.getParameters().put('siteId',siteObj.id);
        Test.setCurrentPage(pageRef);
    	tileDataServerObj.handleRequest();
        system.assertEquals('success', tileDataServerObj.response.status, tileDataServerObj.response.message);
        Test.stopTest();
    }
    
   
    
    @isTest static void testRemoveOnboardingTile() {
        Test.startTest();
        init();
        UserContext.isNewHire = false;
        UserContext.isUserAppModerator = false;
        App_Config__c appConfigRecord = [select Id, App_Dashboard_Mode__c from App_Config__c][0];
        appConfigRecord.App_Dashboard_Mode__c = 'Manager';
        update appConfigRecord;
        
        Tiles_Config__c tileObj = [Select Id, Variant__c, Type__c, Data__c From Tiles_Config__c Limit 1];
        tileObj.Variant__c = 'content_onboarding';
        update tileObj;
        
        TileDataServer tileDataServerObj = new TileDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'TileDataServer');
        pageRef.getParameters().put('action', 'removeTile');
        pageRef.getParameters().put('dashboardId','home');
		pageRef.getParameters().put('tileId',tileObj.Id);
        Test.setCurrentPage(pageRef);
        
        
    	tileDataServerObj.handleRequest();
        system.assertEquals('success', tileDataServerObj.response.status, 'null');
        Test.stopTest();
    }

    @isTest static void testRemoveOnboardingTile1() {
        Test.startTest();
        init();
        UserContext.isUserAppModerator = true;
        App_Config__c appConfigRecord = [select Id, App_Dashboard_Mode__c from App_Config__c][0];
        appConfigRecord.App_Dashboard_Mode__c = 'Manager';
        update appConfigRecord;
        
        Tiles_Config__c tileObj = [Select Id, Variant__c, Type__c, Data__c From Tiles_Config__c Limit 1];
        tileObj.Variant__c = 'content_onboarding';
        update tileObj;
        
        TileDataServer tileDataServerObj = new TileDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'TileDataServer');
        pageRef.getParameters().put('action', 'removeTile');
        pageRef.getParameters().put('dashboardId','home');
		pageRef.getParameters().put('tileId',tileObj.Id);
        Test.setCurrentPage(pageRef);
        
        
    	tileDataServerObj.handleRequest();
        system.assertEquals('success', tileDataServerObj.response.status, 'null');
        Test.stopTest();
    }
    
    @isTest static void testEditOnboardingTile() {
        Test.startTest();
        init();
        UserContext.isNewHire = true;
        Tiles_Config__c tileObj = [Select Id From Tiles_Config__c Limit 1];
        TileDataServer tileDataServerObj = new TileDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'TileDataServer');
        pageRef.getParameters().put('action', 'editTile');
        pageRef.getParameters().put('dashboardId','home');
        pageRef.getParameters().put('tileId',tileObj.Id);
        // onboarding homedashboard tile
    	String tileJson = '{"title":"Onboarding", "options":{"layout":"standard"}, "pushToAllHomeDashboards":false, "type":"content", "variant":"content_onboarding"}'; 
        pageRef.getParameters().put('tile', tileJson);
        Test.setCurrentPage(pageRef);
    	tileDataServerObj.handleRequest();
        // not a new hire on home dashboard
        UserContext.isNewHire = false;
		Test.setCurrentPage(pageRef);
    	tileDataServerObj.handleRequest();        
        // onboarding sitedashboard tile
        Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
        pageRef.getParameters().put('dashboardId','site');
        pageRef.getParameters().put('siteId',siteObj.id);
        Test.setCurrentPage(pageRef);
    	tileDataServerObj.handleRequest();
        system.assertEquals('success', tileDataServerObj.response.status, tileDataServerObj.response.message);
        Test.stopTest();
    }

    @isTest
    static void testAddOutlookCalendarTile() {
        init();
        pageRef.getParameters().put('target', 'TileDataServer');
        pageRef.getParameters().put('action', 'addTile');
        pageRef.getParameters().put('dashboardId','home');
        String tileJson = '{"title":"Events from Google Calendar - India Engineering Team Leave Calendar","options":{"type":"event","siteFilter":"outlookCalendar","siteId":null,"layout":"standard","outlookCalendar":{"name":"India Engineering Team Leave Calendar","id":"c_d4tvq8pr2n1vmhe008tfhkdics@group.calendar.google.com","ownerAddress":"test@simpplr.com"}},"pushToAllHomeDashboards":false,"items":[],"type":"content","variant":"latest_popular"}';   
        pageRef.getParameters().put('tile', tileJson);
        Test.setCurrentPage(pageRef);
        TileDataServer tileDataServerObj = new TileDataServer();
        Test.startTest();  
        tileDataServerObj.handleRequest(); 
        Test.stopTest();
        system.assertEquals('success', tileDataServerObj.response.status, tileDataServerObj.response.message);
    }

    @isTest
    static void testEditOutlookCalendarTile() {
        init();
        Tiles_Config__c tileObj = [Select Id From Tiles_Config__c Limit 1];        
        pageRef.getParameters().put('target', 'TileDataServer');
        pageRef.getParameters().put('action', 'editTile');
        pageRef.getParameters().put('dashboardId','home');
        pageRef.getParameters().put('tileId', tileObj.id);
        String tileJson = '{"title":"Events from Google Calendar - Holidays in India","options":{"type":"event","siteFilter":"outlookCalendar","siteId":null,"layout":"standard","outlookCalendar":{"name":"Holidays in India","id":"en-gb.indian#holiday@group.v.calendar.google.com","ownerAddress":"test@simpplr.com"}},"pushToAllHomeDashboards":false,"items":[null,null],"type":"content","variant":"latest_popular"}';   
        pageRef.getParameters().put('tile', tileJson);
        Test.setCurrentPage(pageRef);
        TileDataServer tileDataServerObj = new TileDataServer();
        Test.startTest();  
        tileDataServerObj.handleRequest(); 
        Test.stopTest();
        system.assertEquals('success', tileDataServerObj.response.status, tileDataServerObj.response.message);
    }    

    @isTest
    static void testEditGoogleCalendarTile() {
        init();
        Tiles_Config__c tileObj = [Select Id From Tiles_Config__c Limit 1];        
        pageRef.getParameters().put('target', 'TileDataServer');
        pageRef.getParameters().put('action', 'editTile');
        pageRef.getParameters().put('dashboardId','home');
        pageRef.getParameters().put('tileId', tileObj.id);
        String tileJson = '{"title":"Events from Google Calendar - Holidays in India","options":{"type":"event","siteFilter":"googleCalendar","siteId":null,"layout":"standard","calendar":{"name":"Holidays in India","id":"en-gb.indian#holiday@group.v.calendar.google.com","ownerAddress":"test@simpplr.com"}},"pushToAllHomeDashboards":false,"items":[null,null],"type":"content","variant":"latest_popular"}';   
        pageRef.getParameters().put('tile', tileJson);
        Test.setCurrentPage(pageRef);
        TileDataServer tileDataServerObj = new TileDataServer();
        Test.startTest();  
        tileDataServerObj.handleRequest(); 
        Test.stopTest();
        system.assertEquals('success', tileDataServerObj.response.status, tileDataServerObj.response.message);
    } 

    @isTest static void testGetTileForCalendar() {
    	Test.startTest();
        init();
        Site_Category__c siteCategoryObj = TestHelper.createSiteCategory();
        CollaborationGroup cg = [Select Id From CollaborationGroup Limit 1];
        
        Simpplr_Site__c siteObj = [select id from simpplr_site__c where Name='Test_Group1_TileServiceTest' limit 1];
        siteObj.Site_Category__c = siteCategoryObj.Id;
        update siteObj;
        String siteId = siteObj.id;
        
        Tiles_Config__c tileObj = [Select Id From Tiles_Config__c Limit 1];
        tileObj.Variant__c = 'latest_popular';
        tileObj.Type__c = 'content';
        tileObj.Data__c = '{  "type" : "event",  "siteFilter" : "googleCalendar",  "layout" : "standard",  "calendar" : {    "id" : "en.indian#holiday@group.v.calendar.google.com",    "name" : "Holidays in India"  }}';
        update tileObj;
        
        TileDataServer tileDataServerObj = new TileDataServer();
        ApexPages.currentPage().getParameters().put('siteId',siteId);
        ApexPages.currentPage().getParameters().put('dashboardId','site');
	    ApexPages.currentPage().getParameters().put('tileId',tileObj.Id);
	    ApexPages.currentPage().getParameters().put('action', 'getTile');
	    tileDataServerObj.handleRequest();
        system.assertEquals('success', tileDataServerObj.response.status, tileDataServerObj.response.message);

        tileObj.Data__c = '{  "type" : "event",  "siteFilter" : "outlookCalendar",  "outlookCalendar" : {    "ownerName" : "Frank test Hobert",    "ownerAddress" : "frank.hoberttest@simpplr.net",    "name" : "United States holidays",    "id" : "fdasf-OR5F0ZOri411aAAAAAAEGAAB1xpeTm5-OR5F0ZOri411aAABWjKaaAAA="  },  "layout" : "standard"}';
        update tileObj;
        tileDataServerObj.handleRequest();
        
    	Test.stopTest();
        system.assertEquals('success', tileDataServerObj.response.status, tileDataServerObj.response.message);
    }

}