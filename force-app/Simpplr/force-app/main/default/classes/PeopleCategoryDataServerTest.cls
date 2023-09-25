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
private class PeopleCategoryDataServerTest {

	private static App_Config__c appConfigRecord;
	private static User siteOwnr;
	private static User siteMember;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Content__c simpplrContentForScore;
	private static Simpplr_Site__c site;
	private static People__c peopleObj;
	private static People_Category__c peopleCategory;
	private static ContentVersion contentVersionObj;
	private static PageReference pageRef;
	
	@testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		peopleCategory = TestHelper.createPeopleCategory('Test Category');
		peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		peopleObj.People_Category__c = peopleCategory.Id;
		update peopleObj;
		siteOwnr = TestHelper.createUser('PeopleCategoryDataServer_siteOwnr', null, false);
		managerOfsiteMember = TestHelper.createUser('PeopleCategoryDataServer_userMngr', null, false);
		siteMember = TestHelper.createUser('PeopleCategoryDataServer_siteMmbr', managerOfsiteMember, false);
		cgroup = TestHelper.createCollaborationGroup('PeopleCategoryDataServer_Grp1','Public');
		site = TestHelper.getSiteRecord(cgroup.id);
		TestHelper.shareSitesToAllPeople(new List<String>{site.Id});
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		
		
	    CollaborationGroupMember cgMember2 = TestHelper.createCollaborationGroupMember(cgroup.Id, siteMember.id, 'Standard');
	}
	
    private static void init() {
    	if(appConfigRecord == null) {
    		appConfigRecord = SimpplrContext.appConfig;
	    	List<User> listOfUsers = [select Id, lastName from user where lastname like 'PeopleCategoryDataServer%'];
	    	for(User userObj : listOfUsers) {
	    		if(userObj.lastName == 'PeopleCategoryDataServer_siteOwnr') {
	    			siteOwnr = userObj; 
	    		} else if(userObj.lastName == 'PeopleCategoryDataServer_userMngr') {
	    			managerOfsiteMember = userObj; 
	    		} else if(userObj.lastName == 'PeopleCategoryDataServer_siteMmbr') {
	    			siteMember = userObj; 
	    		} 
	    	}
	    	site = TestHelper.getSiteRecordWithName('PeopleCategoryDataServer_Grp1');
	        simpplrContent = TestHelper.createContent('simpplr test news', 'News', 'Submitted', siteMember, site);
	        simpplrContentForScore=[SELECT Title__c from Simpplr_Content__c limit 1];
	        peopleObj=[select About__c,City__c,Country__c,Department__c,Extension__c,user__r.SmallPhotoURL,
	    			User__c,Mobile_Phone__c,Phone__c,State__c,Title__c,Full_Name__c,Email__c,
	    			First_Name__c,Last_Name__c from People__c limit 1];
	    	contentVersionObj=TestHelper.createContentVersion('h');
	    	TestHelper.createCarousel(site.id,simpplrContent.id);
	    	peopleCategory = [SELECT Id, Name__c FROM People_Category__c LIMIT 1];
	    	pageRef = Page.DataServerRW;
        	pageRef.getParameters().put('target','PeopleCategoryDataServer');
        
        	Test.setCurrentPage(pageRef);
	    	System.assert(true,'Running as expected');
    	}
    }
    
    @isTest static void testSearch() {
        init();
        Test.startTest();
        ExternalSearchHttpMock httpMockObj = new ExternalSearchHttpMock('OK',200,'CustomBodyResponse',false);
        httpMockObj.resbody = '{"hits": {"start": 0,"found": 1,"total": {"value": 1,"relation": "eq"},"hit": [{"_index": "idx_search_00d4x000006tsuteaa_v5","_type": "add","_id": "' + peopleCategory.Id + '","_score": null,"sort": ["cat 1"],"id": "' + peopleCategory.Id + '","name": "cat 1","is_deleted": false,"object_type": "People_Category"}]},"status": "SUCCESS"}';
        Test.setMock(HttpCalloutMock.class, httpMockObj);
        PeopleCategoryDataServer serverObj = new PeopleCategoryDataServer();
        
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data', '{"sortBy":"latest","size":10}');
        Test.setCurrentPage(pageRef);
        
        serverObj.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSearch1() {
        init();
        Test.startTest();
        PeopleCategoryDataServer.checkFullExternalSearch = false;
        PeopleCategoryDataServer serverObj = new PeopleCategoryDataServer();
        
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data', '{"sortBy":"latest","size":10}');
        Test.setCurrentPage(pageRef);
        
        serverObj.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testDelete() {
    	init();
        PeopleCategoryDataServer serverObj = new PeopleCategoryDataServer();
        
        pageRef.getParameters().put('action', 'delete');
    	pageRef.getParameters().put('data', '["a0F61000001deSTEAY"]'); // intentional hardcoding - for exception - non-existing ID
    	Test.setCurrentPage(pageRef);
    	
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testRename() {
    	init();
        PeopleCategoryDataServer serverObj = new PeopleCategoryDataServer();
        
        pageRef.getParameters().put('action', 'rename');
    	pageRef.getParameters().put('data', '{"id":"a0F61000001dc6WEAQ","name":"PCat001a"}'); // intentional hardcoding - for exception - non-existing ID
    	
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCreate() {
    	init();
        PeopleCategoryDataServer serverObj = new PeopleCategoryDataServer();
        
        pageRef.getParameters().put('action', 'create');
    	pageRef.getParameters().put('data', '"PCat002"');
    	
        serverObj.handleRequest();
        
        String peopleCategoryId = [select id from People_Category__c where Name__c = 'PCat002' LIMIT 1].Id;
        
        pageRef.getParameters().put('action', 'rename');
    	pageRef.getParameters().put('data', '{"id":"' + peopleCategoryId + '","name":"PCat002a"}');
    	serverObj.handleRequest();
    	
        pageRef.getParameters().put('action', 'delete');
    	pageRef.getParameters().put('data', '["' + peopleCategoryId + '"]');
    	serverObj.handleRequest();
    	
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUndefinedAction() {
    	init();
        PeopleCategoryDataServer serverObj = new PeopleCategoryDataServer();
        
        pageRef.getParameters().put('action', 'undefinedAction');
    	pageRef.getParameters().put('data', '{}');
    	
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testMissingAction() {
    	init();
        PeopleCategoryDataServer serverObj = new PeopleCategoryDataServer();
        
        pageRef.getParameters().put('action', '');
        serverObj.handleRequest();
        System.assert(true,'Running as expected');
    }
    
}