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
private class EventDataServerTest {
    
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
	private static PageReference pageRef;
	
    @testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		systemAdmin = TestHelper.createUser('RedirectionServer_admin', null, true);
		siteOwnr = TestHelper.createUser('RedirectionServer_siteOwnr', null, false);
		managerOfsiteMember = TestHelper.createUser('RedirectionServer_userMngr', null, false);
		siteMember = TestHelper.createUser('RedirectionServer_siteMmbr', managerOfsiteMember, false);
		cgroup = TestHelper.createCollaborationGroup('RedirectionServer_Grp1','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		Simpplr_Site__c  testSite = TestHelper.getSiteRecord(cgroup.Id);
		simpplrContent = TestHelper.createContent('EventDataServerTest Event', 'Event', 'Approved', systemAdmin, testSite);
        TestHelper.createContentTitleImage(simpplrContent.Id);
        TestHelper.createRSVPResponse(simpplrContent.Id, peopleObj.Id, 'Yes');
		CollaborationGroupMember cgMember2 = TestHelper.createCollaborationGroupMember(cgroup.Id, siteMember.id, 'Standard');
		contentVersionObj=TestHelper.createContentVersion('h');
		TestHelper.createCarousel(testSite.id,simpplrContent.id);
	    
	}
	
    private static void init() {
    	if(appConfigRecord == null) {
    		appConfigRecord = SimpplrContext.appConfig;
	    	List<User> listOfUsers = [select Id, lastName from user where lastname like 'RedirectionServer%'];
	    	for(User userObj : listOfUsers) {
	    		if(userObj.lastName == 'RedirectionServer_admin') {
	    			systemAdmin = userObj;
	    		} else if(userObj.lastName == 'RedirectionServer_siteOwnr') {
	    			siteOwnr = userObj; 
	    		} else if(userObj.lastName == 'RedirectionServer_userMngr') {
	    			managerOfsiteMember = userObj; 
	    		} else if(userObj.lastName == 'RedirectionServer_siteMmbr') {
	    			siteMember = userObj; 
	    		} 
	    	}
	    	site = TestHelper.getSiteRecordWithName('RedirectionServer_Grp1');
	        simpplrContentForScore=[SELECT Title__c, Display_Excerpt__c from Simpplr_Content__c limit 1];
	        peopleObj=[select About__c,City__c,Country__c,Department__c,Extension__c,user__r.SmallPhotoURL,
	    			User__c,Mobile_Phone__c,Phone__c,State__c,Title__c,Full_Name__c,Email__c,
	    			First_Name__c,Last_Name__c from People__c limit 1];
	    	
	    	
	    	//pageRef=Page.EventDataServer;
	    	pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','EventDataServer');
        
	    	Test.setCurrentPage(pageRef);
    	}
    }
    
    
    @isTest static void testHandleRequestWhenActionNull() {
        Test.startTest();
    	init();
    	EventDataServer dSObj= new EventDataServer();
        pageRef.getParameters().put('action','');
        dSObj.handleRequest();
        Test.stopTest();
        System.assertEquals('error', dSObj.response.status, 'Action is blank, Should return error');
    }
	@isTest static void testHandleRequestWhenNotShowInSimpplr() {
		Test.startTest();
		init();
		CollaborationGroup cgroup1 = [SELECT Id, Name FROM CollaborationGroup WHERE  name = 'RedirectionServer_Grp1'][0];
		site = TestHelper.getSiteRecord(cgroup1.Id);
		site.Show_In_Simpplr__c = false;
		update site;
		SiteContext.siteId = site.Id;
		EventDataServer dSObj= new EventDataServer();
		pageRef.getParameters().put('action','showinsimpplr');
		dSObj.handleRequest();
		Test.stopTest();
		System.assertEquals('error', dSObj.response.status, 'Should be an error , Site is not belongs to Simpplr');
    }
    
    @isTest static void testHandleRequestWhenActionAvailable() {
        Test.startTest();
    	init();
    	EventDataServer dsObject= new EventDataServer();

        pageRef.getParameters().put('action',dsObject.ACTION_VALUE_SEARCH);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
        dsObject.getPageFeature();
        
        pageRef.getParameters().put('action','####');
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
        System.assertEquals('error', dsObject.response.status, 'Action parameter is missing');
        
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","filter":"bookmarked","sortBy":"promoted","size":1,"source":"all"}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');

		pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","filter":"past","sortBy":"eventNewest","size":1,"source":"all"}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
		pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","filter":"future","sortBy":"eventNewest","size":1,"source":"all"}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
		pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","filter":"past","sortBy":"eventOldest","size":1,"source":"all"}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
		pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","filter":"future","sortBy":"eventOldest","size":1,"source":"all"}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');

    	pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","filter":"future","sortBy":"promoted","size":1,"source":"following"}');
    	dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","period":"this_week","filter":"future","size":1,"source":"rsvp"}');
    	dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","period":"next_week","filter":"future","size":1,"source":"all"}');
    	dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","period":"this_month","filter":"future","size":1,"source":"all"}');
    	dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","period":"after_this_month","filter":"future","size":1,"source":"all"}');
    	dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"PageName":"SiteEvents","siteId":"' + site.Id + '","period":"after_this_month","filter":"past","size":1,"source":"all"}');
    	dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
    	
        pageRef.getParameters().put('data', '{"PageName":"HomeEvents","filter":"following","sortBy":"promoted","size":10}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"PageName":"HomeEvents","sortBy":"Latest","size":10,"eventDate":"'+string.valueOf(system.today())+'"}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
       
        pageRef.getParameters().put('data', '{"PageName":"HomeEvents","sortBy":"Liked","size":10}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"PageName":"HomeEvents","sortBy":"Viewed","size":10}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"PageName":"HomeEvents","sortBy":"Popular","size":10}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetEvents() {
    	Test.startTest();
    	init();
    	Criteria.Event eventCriteriaObjArg = new Criteria.Event();
    	eventCriteriaObjArg.PageName='HomeEvents';
    	eventCriteriaObjArg.filter='following';
    	eventCriteriaObjArg.sortBy='promoted';
    	eventCriteriaObjArg.size=10;
    	System.runAs(siteMember) {
	    	EventDataServer dsObject = new EventDataServer();
	    	ResponseWrapper resp = dsObject.getEvents(eventCriteriaObjArg);
	    	eventCriteriaObjArg.nextPageToken='10';
	    	ResponseWrapper resp2 = dsObject.getEvents(eventCriteriaObjArg);
	    	System.assertEquals('success', dsObject.response.status, 'Running as expected');
    	} 
    	Test.stopTest();
	}
	@isTest static void testGetEventsFromExternalSearch(){

		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('success',200,'searchContents',true));
		Criteria.Event eventCriteriaObjArg = new Criteria.Event();
		eventCriteriaObjArg.term='Random';
		eventCriteriaObjArg.nextPageToken='10';
		eventCriteriaObjArg.PageName='HomeEvents';
		eventCriteriaObjArg.filter='following';
		eventCriteriaObjArg.sortBy='promoted';
		eventCriteriaObjArg.size=10;
		EventDataServer dsObject = new EventDataServer();
		ResponseWrapper response = dsObject.getEvents(eventCriteriaObjArg);
		Test.stopTest();
		System.assertEquals('success', response.status, response.result);
    }
	@isTest static void testSearchGoogleCalendarEvents() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'googleCalendarEvents',false));
		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('target','EventDataServer');
        Test.setCurrentPage(pageRef);
			
		pageRef.getParameters().put('data', '{"source":"google","period":"this_week","size":1}');
		EventDataServer dsObject = new EventDataServer();
		dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
		
        pageRef.getParameters().put('data', '{"source":"google","period":"next_week","size":1}');
		dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
		
        pageRef.getParameters().put('data', '{"source":"google","period":"after_this_month","size":1}');
		dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
		
        pageRef.getParameters().put('data', '{"source":"google","period":"this_month","size":1}');
		dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
		Test.stopTest();
	}
    
    
}