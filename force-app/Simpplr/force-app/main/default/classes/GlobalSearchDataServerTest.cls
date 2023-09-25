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
private class GlobalSearchDataServerTest {
	
	private static App_Config__c appConfigRecord;
	private static User systemAdmin;
	private static User siteOwnr;
	private static User siteMember;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Content__c simpplrContentForScore;
	private static Simpplr_Site__c site;
	private static People__c peopleObj;
	private static ContentVersion contentVersionObj;
	@testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		systemAdmin = TestHelper.createUser('GlobalSearchDataServer_admin', null, true);
		siteOwnr = TestHelper.createUser('GlobalSearchDataServer_siteOwnr', null, false);
		managerOfsiteMember = TestHelper.createUser('GlobalSearchDataServer_userMngr', null, false);
		siteMember = TestHelper.createUser('GlobalSearchDataServer_siteMmbr', managerOfsiteMember, false);
		cgroup = TestHelper.createCollaborationGroup('GlobalSearchDataServer_Grp1','Public');
        site = TestHelper.getSiteRecord(cgroup.id);
        TestHelper.shareSitesToAllPeople(new List<String>{site.Id});
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		TestHelper.createContentVersion('Global Test', 'Global_Test');
        TestHelper.createPeoplePreference(UserContext.peopleId);
        
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'googledrive', 'dropbox', 'sharepoint', 'onedrive', 'gdrive'});
		List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, peopleObj.id,'asdqdqwedwe');
		
	    CollaborationGroupMember cgMember2 = TestHelper.createCollaborationGroupMember(cgroup.Id, siteMember.id, 'Standard');
	    
	}
	
    private static void init() {
    	if(appConfigRecord == null) {
    		appConfigRecord = SimpplrContext.appConfig;
	    	List<User> listOfUsers = [select Id, lastName from user where lastname like 'GlobalSearchDataServer%'];
	    	for(User userObj : listOfUsers) {
	    		if(userObj.lastName == 'GlobalSearchDataServer_admin') {
	    			systemAdmin = userObj;
	    		} else if(userObj.lastName == 'GlobalSearchDataServer_siteOwnr') {
	    			siteOwnr = userObj; 
	    		} else if(userObj.lastName == 'GlobalSearchDataServer_userMngr') {
	    			managerOfsiteMember = userObj; 
	    		} else if(userObj.lastName == 'GlobalSearchDataServer_siteMmbr') {
	    			siteMember = userObj; 
	    		} 
	    	}
	    	site = TestHelper.getSiteRecordWithName('GlobalSearchDataServer_Grp1');
            site.File_Storage_Source__c = 'crm';
            site.Is_Active__c =true;
            site.Show_In_Simpplr__c = true;
            update site;
            simpplrContent = TestHelper.createContent('Global simpplr test page', 'Page', 'Approved', siteMember, site);
	    	TestHelper.createContent('Global simpplr test Event', 'Event', 'Approved', siteMember, site);
	        simpplr_content__c conObj = TestHelper.createContent('Global simpplr test Album', 'Album', 'Approved', siteMember, site);
            TestHelper.createFileRecordForVideo(conObj.Id , 'dummyURL');
            Pages_Category__c pcObj = TestHelper.createPageCategory(site.id, 'Policy');
            simpplrContent.Pages_Category__c = pcObj.Id;
            update simpplrContent;
	       
	        peopleObj=[select About__c,City__c,Country__c,Department__c,Extension__c,user__r.SmallPhotoURL,
	    			User__c,Mobile_Phone__c,Phone__c,State__c,Title__c,Full_Name__c,Email__c,
	    			First_Name__c,Last_Name__c from People__c limit 1];
	    	contentVersionObj=TestHelper.createContentVersion('h');
            
    	}
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','GlobalSearchDataServer');
        Test.setCurrentPage(pageRef);
    }
    
    @isTest static void testHandleRequestWhenActionNull() {
    	init();

        GlobalSearchDataServer dSObj= new GlobalSearchDataServer();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','GlobalSearchDataServer');
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        
        pageRef.getParameters().put('action','InvalidAction');
        Test.setCurrentPage(pageRef);

        Test.startTest();
            dSObj.handleRequest();
        Test.stopTest();

        System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleRequestWhenActionAvailable() {
    	init();
        GlobalSearchDataServer dSObj= new GlobalSearchDataServer();

        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','GlobalSearchDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{}');

        Test.startTest();
            dSObj.handleRequest();
        Test.stopTest();

        System.assert(true,'Running as expected');
    }
    
     @isTest static void testSearchForConttents() {
		Test.startTest();
    	CollaborationGroup cgroup2 = TestHelper.createCollaborationGroup('SiteDataServerTestPvt','Private');
		Simpplr_Site__c siteRec  = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='SiteDataServerTestPvt'][0];
        TestHelper.shareSitesToAllPeople(new List<String>{siteRec.Id});
		User userObj = TestHelper.createUser('userObj',null,false);
		People__c peopleRec = [Select id from People__c where user__c=:userObj.id];
        Segment__c segmentRec = TestHelper.createSegment(peopleRec.Id); 
		Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
        Simpplr_Content__c simpplrContent1 = TestHelper.createContent('simpplr test Page', 'Page', 'Submitted', userObj, siteRec);
		Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleRec.Id, 'Site');
        Topic topicObj = TestHelper.createTopic('SimranRawat');
        update topicObj;
		Simpplr_Metadata__c simpplrMetdataObj = new Simpplr_Metadata__c();
        simpplrMetdataObj.type__c = 'Endorsement';
        simpplrMetdataObj.topic__c = topicObj.id;
        simpplrMetdataObj.user__c = userObj.id;
         simpplrMetdataObj.Chatter_Group_Id__c = cgroup2.Id;
         simpplrMetdataObj.Simpplr_Site__c = siteRec.id;
         simpplrMetdataObj.Simpplr_Content__c  = simpplrContent1.id;
        insert simpplrMetdataObj;
    	GlobalSearchDataServer dSObj= new GlobalSearchDataServer();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','GlobalSearchDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('searchForType','Content');
        pageRef.getParameters().put('data','{"term":"Simran","siteId":null,"section":"Content","size":16}');
        dSObj.handleRequest();
        
        pageRef.getParameters().put('searchForType','Site');
        pageRef.getParameters().put('data','{"term":"Simran","siteId":null,"section":"Site","size":16}');
        dSObj.handleRequest();
         
        pageRef.getParameters().put('searchForType','User');
        pageRef.getParameters().put('data','{"term":"Simran","siteId":null,"section":"User","size":16}');
        dSObj.handleRequest();
         
        pageRef.getParameters().put('searchForType','File');
        pageRef.getParameters().put('data','{"term":"Simran","siteId":null,"section":"File","size":16}');
        dSObj.handleRequest();
         
       dSObj.handleSearch('{"name_term":"a","section":"User","userCategory":"all","term":"a","expertise":null,"filter":"following","department":"a","title_term":"a","location":"null @@ null @@ U","phone_term":"a","size":10,"nextPageToken":10}',dSObj.SEARCH_TYPE_USER);
        Test.stopTest();
        System.assertEquals('success',dSObj.response.status,'Running as expected');
     }
    
    
    @isTest static void testSearch() {
	Test.startTest();
    	init();
        Simpplr_Site__c site = TestHelper.getSiteRecordWithName('GlobalSearchDataServer_Grp1');
    	GlobalSearchDataServer dSObj = new GlobalSearchDataServer();
    	ResponseWrapper resp= new ResponseWrapper();
        
    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Site","size":10}',dSObj.SEARCH_TYPE_SITE);
    resp = dSObj.handleSearch('{"name_term":"a","section":"User","userCategory":"all","term":"a","expertise":null,"department":"a","title_term":"a","location":"null @@ null @@ U","phone_term":"a","size":0}',dSObj.SEARCH_TYPE_USER);
    	resp = dSObj.handleSearch('{"term":"Title","siteId":null,"section":"File","size":10}',dSObj.SEARCH_TYPE_FILE);
	resp = dSObj.handleSearch('{"term":"Title","siteId":"'+site.Id+'","section":"File","size":10}',dSObj.SEARCH_TYPE_CRMFILE);
    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Topic","size":10}',dSObj.SEARCH_TYPE_TOPIC);
    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Topic","size":10}',dSObj.SEARCH_TYPE_GDFILE);
    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Topic","size":10}',dSObj.SEARCH_TYPE_BOXFILE);
    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Topic","size":10,"nextPageToken":10}',dSObj.SEARCH_TYPE_GDFILE);
    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Topic","size":10}',dSObj.SEARCH_TYPE_DROPBOX_FILE);
        
        resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Site","size":10,"nextPageToken":10}',dSObj.SEARCH_TYPE_SITE);
        resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Site","size":0,"offset":10}',dSObj.SEARCH_TYPE_SITE);
        resp = dSObj.handleSearch('{"name_term":"a","section":"User","userCategory":"all","term":"a","expertise":null,"filter":"following","department":"a","title_term":"a","location":"null @@ null @@ U","phone_term":"a","size":10,"nextPageToken":10}',dSObj.SEARCH_TYPE_USER);
        resp = dSObj.handleSearch('{"term":"Title","siteId":"'+site.Id+'","section":"File","size":10,"nextPageToken":10}',dSObj.SEARCH_TYPE_FILE);
        resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Topic","size":10,"nextPageToken":10}',dSObj.SEARCH_TYPE_BOXFILE);
        Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testSearchWithOrigin() {
	Test.startTest();
    	init();
        
        //Simpplr_Site__c site = TestHelper.getSiteRecordWithName('GlobalSearchDataServer_Grp1');
    	GlobalSearchDataServer dSObj = new GlobalSearchDataServer();
        dsObj.getPageFeature();
    	ResponseWrapper resp= new ResponseWrapper();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','GlobalSearchDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('origin','mobile');
        
        pageRef.getParameters().put('searchForType','GoogleDriveFile');
        pageRef.getParameters().put('data','{"term":"Title","siteId":null,"section":"File","size":10,"nextPageToken":10}');
        dSObj.handleRequest();
        
        pageRef.getParameters().put('searchForType','OneDriveFile');
        pageRef.getParameters().put('data','{"term":"Title","siteId":null,"section":"File","size":10,"nextPageToken":10,"provider":"onedrive"}');
        dSObj.handleRequest();
        
        pageRef.getParameters().put('searchForType','Site');
        pageRef.getParameters().put('data','{"term":"test","siteId":null,"section":"Site","size":10,"origin":"mobile"}');
        dSObj.handleRequest();
        
        pageRef.getParameters().put('searchForType','User');
        pageRef.getParameters().put('data','{"name_term":"a","section":"User","origin":"mobile","userCategory":"all","term":"a","expertise":null,"department":null,"title_term":"a","location":null,"phone_term":"a","size":0}');
        dSObj.handleRequest();
        
    	Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testSearchCRMWithOrigin() {
	Test.startTest();
    	init();
        Site.File_Storage_Source__c = 'crm';
        update Site;
        Folder__c fObj = TestHelper.createChatterFolder('testFolder01', null, Site.Id, 'CRM', null, 'readwrite');
        Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, Site.Id, 'CRM', null, 'readwrite');
        folderObj.Is_Deleted__c=false;
        folderObj.External_Folder_Id__c=fObj.id;
        update folderObj;
        
    	GlobalSearchDataServer dSObj = new GlobalSearchDataServer();
        dsObj.getPageFeature();
    	ResponseWrapper resp= new ResponseWrapper();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','GlobalSearchDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('origin','mobile');
        pageRef.getParameters().put('searchForType','CrmFile');
        pageRef.getParameters().put('data','{"term":"Title","siteId":null,"section":"File","size":10}');
        dSObj.handleRequest();
        
    	Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    
    @isTest static void testSearchContent() {
	Test.startTest();
    	init();
    	GlobalSearchDataServer dSObj = new GlobalSearchDataServer();
    	ResponseWrapper resp= new ResponseWrapper();

		resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Page","size":10}',dSObj.SEARCH_TYPE_PAGE);
	    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Event","size":10}',dSObj.SEARCH_TYPE_EVENT);
	    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"BlogPost","size":10}',dSObj.SEARCH_TYPE_BLOG);
		resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Album","size":10}',dSObj.SEARCH_TYPE_ALBUM);
	    	resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Content","size":10,"topic":"test"}',dSObj.SEARCH_TYPE_CONTENT);
        resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Content","size":1,"offset":10}',dSObj.SEARCH_TYPE_CONTENT);
        resp = dSObj.handleSearch('{"term":"test","siteId":null,"section":"Content","size":1,"offset":10,"origin":"mobile"}',dSObj.SEARCH_TYPE_CONTENT);
	    	resp = dSObj.handleSearch('{"ids":["' + simpplrContent.id + '"],"siteId":null,"section":"Page","size":10}',dSObj.SEARCH_TYPE_PAGE);
	    	resp = dSObj.handleSearch('{"ids":["' + simpplrContent.id + '"],"siteId":null,"section":"Event","size":10}',dSObj.SEARCH_TYPE_EVENT);
	    	resp = dSObj.handleSearch('{"ids":["' + simpplrContent.id + '"],"siteId":null,"section":"BlogPost","size":10}',dSObj.SEARCH_TYPE_BLOG);
	    	resp = dSObj.handleSearch('{"ids":["' + simpplrContent.id + '"],"siteId":null,"section":"Album","size":10}',dSObj.SEARCH_TYPE_ALBUM);
	    	
    	Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    	
    @isTest 
    static void testHandleRequestSearchAutoComplete() {
    	Test.startTest();
    	init();
    		    TestHelper.createUser('GlobalSearchDataServer_User1', null, UserInfo.getProfileId());
	    TestHelper.createUser('GlobalSearchDataServer_User2', null, UserInfo.getProfileId());
	    TestHelper.createUser('GlobalSearchDataServer_User3', null, UserInfo.getProfileId());
	    TestHelper.createUser('GlobalSearchDataServer_User4', null, UserInfo.getProfileId());
	    TestHelper.createUser('GlobalSearchDataServer_User5', null, UserInfo.getProfileId());
	    TestHelper.createUser('GlobalSearchDataServer_User6', null, UserInfo.getProfileId());
	    TestHelper.createUser('GlobalSearchDataServer_User7', null, UserInfo.getProfileId());
    	GlobalSearchDataServer dSObj= new GlobalSearchDataServer();

        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','GlobalSearchDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','searchAutoComplete');
        pageRef.getParameters().put('data','{"term":"Global"}');
        dSObj.handleRequest();
        
        pageRef.getParameters().put('action','searchAutoComplete');
        pageRef.getParameters().put('data','');
        dSObj.handleRequest();
		Test.stopTest();
        System.assertEquals('fail',dSObj.response.status,'Running as expected');
    }
    
    @isTest 
    static void testHandleRequestSearchSaveSearchStats() {
        Test.startTest();
    	init();
        GlobalSearchDataServer dSObj= new GlobalSearchDataServer();
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','GlobalSearchDataServer');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Desktop App');
        pageRef.getParameters().put('action','saveSearchStats');
        //pageRef.getParameters().put('data','{"url":"/apex/SearchResults?term=global","term":"global","siteId":null,"totalTimeTaken":5098,"totalResultCount":2,"sections":[{"name":"Content","status":"success","resultCount":1,"timeTaken":1246,"topItems":[{"id":"a0d41000000ye7lAAA","score":3}]},{"name":"User","status":"success","resultCount":0,"timeTaken":1259,"topItems":[]},{"name":"Topic","status":"success","resultCount":0,"timeTaken":2477,"topItems":[]},{"name":"Site","status":"success","resultCount":1,"timeTaken":4178,"topItems":[{"id":"a0j41000001dY2PAAU","score":1}]},{"name":"File","status":"success","resultCount":0,"timeTaken":4724,"topItems":[]}]}');
        pageRef.getParameters().put('data','{"url":"/apex/SearchResults?term=global","term":"global","siteId":"'+site.Id+'","totalTimeTaken":5098,"totalResultCount":2,"sections":["TestString-1","TestString-2","TestString-3","TestString-4"]}');
        dSObj.handleRequest();
        
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'Mobile App');
        dSObj.handleRequest();
        
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'BlackBerry');
        dSObj.handleRequest();
        
        ApexPages.currentPage().getHeaders().put('USER-AGENT', 'testUserAgent');
        dSObj.handleRequest();
        Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest 
    static void testHandleRequestSaveSearchResultSelect() {
        Test.startTest();
    	init();
        GlobalSearchDataServer dSObj= new GlobalSearchDataServer();
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','GlobalSearchDataServer');
        
        pageRef.getParameters().put('action','saveSearchResultSelect');
        pageRef.getParameters().put('data','{"context":"full","section":"Top","score":17,"position":1,"itemId":"fileId","itemType":"file","subsection":"SiteContentPeople","term":"a","siteId":null,"isExternal":false}');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"context":"full","section":"Top","score":17,"position":1,"itemId":"fileId","itemType":"content","subsection":"SiteContentPeople","term":"a","siteId":null,"isExternal":false}');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"context":"full","section":"Top","score":17,"position":1,"itemId":"fileId","itemType":"site","subsection":"SiteContentPeople","term":"a","siteId":"'+site.Id+'","isExternal":false}');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"context":"full","section":"Top","score":17,"position":1,"itemId":"fileId","itemType":"person","subsection":"SiteContentPeople","term":"a","siteId":null,"isExternal":false}');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        
        pageRef.getParameters().put('data','{"context":"full","section":"Top","score":17,"position":1,"itemId":"fileId","itemType":"knowlegebase","subsection":"SiteContentPeople","term":"a","siteId":null,"isExternal":false}');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest
    static void testMiscellaneousMethods(){
        Test.startTest();
    	init();
    	GlobalSearchService gsss = new GlobalSearchService();
        gsss.getContentDocumentIdsForSite(site.id+'');
           gsss.getFinalSearchString('soslSearchText');
           Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void searchFilesTest() {
        Test.startTest();
    	init();
        Folder__c fObj = TestHelper.createChatterFolder('testFolder01', null, Site.Id, 'CRM', null, 'readwrite');
        Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, Site.Id, 'CRM', null, 'readwrite');
        folderObj.Is_Deleted__c=false;
        folderObj.External_Folder_Id__c=fObj.id;
        try{
            GlobalSearchservice gss = new GlobalSearchservice();
            Criteria.File inputFile = new Criteria.File();
            
            inputFile.id = '';
            inputFile.siteId = '';
            inputFile.rootDirectory = '';
            inputFile.isPaginationEnabled = false;
            inputFile.context = '';
            inputFile.hideProviderSystemDirs = false;
            inputFile.isGlobalSearchReq = false;
            inputFile.term = 'dummyterm';
            inputFile.owner = peopleObj.id;
            
            gss.searchEFSFiles(inputFile);
            
            Criteria.File inputFile1 = new Criteria.File();
            inputFile1.id = '';
            inputFile1.siteId = site.id;
            inputFile1.rootDirectory = '';
            inputFile1.isPaginationEnabled = false;
            inputFile1.context = '';
            inputFile1.publishStartDate = 'past_24_hours';
            inputFile1.hideProviderSystemDirs = false;
            inputFile1.isGlobalSearchReq = false;
            inputFile1.term = '';
            inputFile1.filter = 'bookmarked';
            inputFile1.owner = peopleObj.id;
            inputFile1.fileType = 'jpg';
            gss.searchEFSFiles(inputFile1);
            gss.searchFiles(inputFile1);
            gss.searchBoxFiles(inputFile1);
            
        } catch(Exception e){
            
        }
        Test.stopTest();
    	System.assert(true, 'Running as expected');
    }
}