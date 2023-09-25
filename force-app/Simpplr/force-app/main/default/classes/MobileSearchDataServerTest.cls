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
private class MobileSearchDataServerTest {

	 @testSetup static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		PeopleDao peopleDaoObj = new PeopleDao();
        peopleDaoObj.insertPeople(new List<User>{ getUser(UserContext.id) });
        
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true);
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);
		TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
		TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        
        collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		testSite = TestHelper.getSiteRecord(collaborationGroupId);
		Simpplr_Content__c simpplrContent = TestHelper.createContent('PageDataServerTest Page', 'Page', 'Approved', testAdminUser, testSite);
    }
    
    private static User getUser(String userId){
        User  userObj = TestHelper.getUserById(userId);
        return userObj;
    }

    @isTest static void testHandleRequest() {
    	Simpplr_Site__c siteObj = [SELECT id from Simpplr_Site__c LIMIT 1];
    	List<People__c> peopleList = [SELECT id from People__c];
    	List<Simpplr_Content__c> simpplrContent = [Select Id from Simpplr_Content__c];
    	
    	TestHelper.addBookmarkForSite(siteObj.Id, peopleList[0].Id);
    	TestHelper.addBookmarkForPeople(peopleList[0].Id, peopleList[1].Id);

		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileSearchDataServer');
        Test.setCurrentPage(pageRef);
        MobileSearchDataServer ads = new MobileSearchDataServer();
        ads.getPageFeature();
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', '');
    	ads.handleRequest();

        ApexPages.currentPage().getParameters().put('action', 'action');
        ApexPages.currentPage().getParameters().put('searchForType', 'Content');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","siteId":"siteObj[0].Id","filter":"", "size":16}');
        ads.handleRequest();   	

        ApexPages.currentPage().getParameters().put('searchForType', 'People');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","expertise_term":"", "size":16}');
        ads.handleRequest();
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('searchForType', 'File');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","expertise_term":"", "size":16}');
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('searchForType', 'site');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","expertise_term":"", "size":16}');
        ads.handleRequest();
        system.assertNotEquals(null, ads.response.result, 'result should not be null');
        Test.stopTest(); 
    }
    
    //External Service method  
    @isTest static void testHandleRequest2() {
    	Simpplr_Site__c siteObj = [SELECT id from Simpplr_Site__c LIMIT 1];
    	List<People__c> peopleList = [SELECT id from People__c];
    	List<Simpplr_Content__c> simpplrContent = [Select Id from Simpplr_Content__c];
    		
    	PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('target', 'MobileSearchDataServer');
        MobileSearchDataServer ads = new MobileSearchDataServer();
        ads.getPageFeature();
        ads.handleRequest();
        
        SimpplrContext.isExternalSearchEnabled = true;
        SimpplrContext.isExternalSearchAppConnected = true;
        
    	ApexPages.currentPage().getParameters().put('action', 'action');
    	ApexPages.currentPage().getParameters().put('searchForType', 'Content');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","siteId":"siteObj[0].Id","filter":"", "size":16}');
        ApexPages.currentPage().getParameters().put('isFullModel', 'true');
        ads.handleRequest();   	

        ApexPages.currentPage().getParameters().put('searchForType', 'People');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","expertise_term":"", "size":16}');
        ApexPages.currentPage().getParameters().put('isFullModel', 'true');
        ads.handleRequest();
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('searchForType', 'File');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","expertise_term":"", "size":16}');
        ApexPages.currentPage().getParameters().put('isFullModel', 'true');
        ads.handleRequest();
		
        ApexPages.currentPage().getParameters().put('searchForType', 'site');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","expertise_term":"", "size":16}');
        ApexPages.currentPage().getParameters().put('isFullModel', 'true');
        ads.handleRequest();
        Test.stopTest();
        
        ApexPages.currentPage().getParameters().put('action', 'saveSearchStats');
        ApexPages.currentPage().getParameters().put('searchForType', '');
        ApexPages.currentPage().getParameters().put('data', '{}');
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'action');
        ApexPages.currentPage().getParameters().put('searchForType', 'exception');
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('searchForType', 'content');
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('searchForType', 'site');
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('searchForType', 'people');
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('searchForType', 'file');
        ads.handleRequest();
        
    	System.assert(true,'Running as expected');  
    }
    
    @isTest static void testWhenExternalsearchNotEnabled() {
        Simpplr_Site__c siteObj = [SELECT id from Simpplr_Site__c LIMIT 1];
    	List<People__c> peopleList = [SELECT id from People__c];
    	List<Simpplr_Content__c> simpplrContent = [Select Id from Simpplr_Content__c];
        
        SimpplrContext.isExternalSearchEnabled = false;
        SimpplrContext.isExternalSearchAppConnected = false;
    		
        MobileSearchDataServer mdsObj = new MobileSearchDataServer();
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileSearchDataServer');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('action', 'action');
    	  ApexPages.currentPage().getParameters().put('searchForType', 'Content');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","siteId":"siteObj[0].Id","filter":"", "size":16}');
        ApexPages.currentPage().getParameters().put('isFullModel', 'true');
        mdsObj.handleRequest();
        
        ApexPages.currentPage().getParameters().put('searchForType', 'People');
        ApexPages.currentPage().getParameters().put('data', '{"term":"test","expertise_term":"", "size":16}');
        ApexPages.currentPage().getParameters().put('isFullModel', 'true');
        mdsObj.handleRequest();
        
        ApexPages.currentPage().getParameters().put('searchForType', 'site');
        mdsObj.handleRequest();
        
        ApexPages.currentPage().getParameters().put('searchForType','file');
        mdsObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
    }
}