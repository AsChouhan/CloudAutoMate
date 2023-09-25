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
private class MobileUtilityDataServerTest {

	 @testSetup static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		PeopleDao peopleDaoObj = new PeopleDao();
        peopleDaoObj.insertPeople(new List<User>{ getUser(UserContext.id) });
        
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);
        TestHelper.createContent('simpplr test event', 'Event', 'Approved', testAdminUser, testSite);
        TestHelper.createContent('simpplr test album', 'Album', 'Approved', testAdminUser, testSite);
        TestHelper.createContent('simpplr test blog', 'BlogPost', 'Approved', testAdminUser, testSite);
		TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
		TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite'); 
        
        collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		testSite = TestHelper.getSiteRecord(collaborationGroupId);
        Simpplr_Content__c simpplrContent = TestHelper.createContent('PageDataServerTest Page', 'Page', 'Approved', testAdminUser, testSite);
        
        Simpplr_Site__c siteObj = [SELECT id from Simpplr_Site__c LIMIT 1];
    	List<People__c> peopleList = [SELECT id from People__c];
         
        TestHelper.createSimpplrNotification('Dummy', peopleList[0].id,null,'Like',simpplrContent.id,null); 
    	
    	TestHelper.addBookmarkForSite(siteObj.Id, peopleList[0].Id);
        TestHelper.addBookmarkForPeople(peopleList[0].Id, peopleList[1].Id);
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'gdrive', 'dropbox', 'sharepoint', 'onedrive'});
        List<People_Integration__c> peopleIntegObjList = TestHelper.createPeopleIntegrationRecords(appIntList, peopleList[0].id, 'asdasd');
        List<App_Integration__c> appIntegrationObjList = TestHelper.createAppIntegrationRecords(true, new Set<String>{'twitter', 'facebook', 'linkedin'});
    	List<People_Integration__c> peopleIntegrationObjList = TestHelper.createPeopleIntegrationRecords(appIntegrationObjList, peopleList[0].id, 'asdasd');
        TestHelper.createTilesConfigData(null, siteObj.id, null, 'site_about', 'standard');
        TestHelper.createTilesConfigData(null, null, null, 'content', 'latest_popular');
    }
    
    private static User getUser(String userId){
        User  userObj = TestHelper.getUserById(userId);
        return userObj;
    }

    @isTest static void testHandleRequest() {
        Test.startTest();
        App_Notification__c notificationObj = [Select Id From App_Notification__c WHERE Is_Deleted__c = false Limit 1];
    	
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileUtilityDataServer');
        Test.setCurrentPage(pageRef);
        MobileUtilityDataServer ads = new MobileUtilityDataServer();
        ads.getPageFeature();
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getSalesforceBaseUrl');
	    ads.handleRequest();
        
	    ApexPages.currentPage().getParameters().put('action', 'getBasicOrgInfo');
	    ads.handleRequest();
        
	    ApexPages.currentPage().getParameters().put('action', 'getAppConfig');
	    ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getPopularSearchList');
	    ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'markNotificationRead');
	    ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'markNotificationRead');
        ApexPages.currentPage().getParameters().put('notificationId',notificationObj.Id);
	    ads.handleRequest();
    	
    	ApexPages.currentPage().getParameters().put('action', 'exception');
    	ads.handleRequest();
        
        Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetOrgChangeInfo() {
        Test.startTest();
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileUtilityDataServer');
        Test.setCurrentPage(pageRef);
        MobileUtilityDataServer ads = new MobileUtilityDataServer();
        ads.getPageFeature();
        ads.handleRequest();
        String pollTimeStamp = (DateTime.now()).addDays(-1)+'';
    	String pollTimeStampNow = (DateTime.now())+'';
        ApexPages.currentPage().getParameters().put('action', 'getOrgChangeInfo');
        ads.handleRequest();    
        
        ApexPages.currentPage().getParameters().put('action', 'getOrgChangeInfo');
        ApexPages.currentPage().getParameters().put('peoplePollTimeStamp', 'now');
	    ApexPages.currentPage().getParameters().put('appConfigPollTimeStamp', 'now');
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getOrgChangeInfo');
	    ApexPages.currentPage().getParameters().put('peoplePollTimeStamp', 'now');
	    ApexPages.currentPage().getParameters().put('sitePollTimeStamp', 'now');
	    ApexPages.currentPage().getParameters().put('contentPollTimeStamp', 'now');
	    ApexPages.currentPage().getParameters().put('appConfigPollTimeStamp', 'now');
    	ads.handleRequest();
        
	    ApexPages.currentPage().getParameters().put('peoplePollTimeStamp', '1517403720213');
	    ApexPages.currentPage().getParameters().put('sitePollTimeStamp', '1517403720213');
	    ApexPages.currentPage().getParameters().put('contentPollTimeStamp', '1517403720213');
	    ApexPages.currentPage().getParameters().put('appConfigPollTimeStamp', '1517403720213');
    	ads.handleRequest();
        
    	Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetAllPeople() {
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileUtilityDataServer');
        Test.setCurrentPage(pageRef);
        MobileUtilityDataServer ads = new MobileUtilityDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getAllPeople');
    	ApexPages.currentPage().getParameters().put('data', '{"size":5,"offset":0}');
    	ads.handleRequest();
    	
    	System.assert(true,'Running as expected');       
    }
    
    @isTest static void testGetAppConfigChangeInfo() {
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileUtilityDataServer');
        Test.setCurrentPage(pageRef);
        MobileUtilityDataServer ads = new MobileUtilityDataServer();
        ApexPages.currentPage().getParameters().put('action', 'getAppConfigChangeInfo');
    	ads.handleRequest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetCacheSiteById() {
        Test.startTest();
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ActivityDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
    	
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileUtilityDataServer');
        Test.setCurrentPage(pageRef);
        MobileUtilityDataServer ads = new MobileUtilityDataServer();
        ads.getPageFeature();
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getCacheSiteById');
        ApexPages.currentPage().getParameters().put('siteId', testSite.Id);
    	ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getCacheSiteById');
        ApexPages.currentPage().getParameters().put('siteId', '');
    	ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getCacheSiteById');
        ApexPages.currentPage().getParameters().put('chatterGroupId',collaborationGroupId);
    	ads.handleRequest();
    	Test.stopTest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPeopleChangeInfo() {
    	String pollTimeStamp = (DateTime.now()).addDays(-1)+'';
    	String pollTimeStampNow = (DateTime.now())+'';
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileUtilityDataServer');
        Test.setCurrentPage(pageRef);
        MobileUtilityDataServer ads = new MobileUtilityDataServer();
        ads.getPageFeature();
        ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getPeopleChangeInfo');
    	ApexPages.currentPage().getParameters().put('peoplePollTimeStamp', '1517403720213');
    	ApexPages.currentPage().getParameters().put('data', '{"filter":"all","peopleId":"","size":16,"nextPageToken":""}');
	    ads.handleRequest();
	    	
	    ApexPages.currentPage().getParameters().put('action', 'getPeopleChangeInfo');
	    ApexPages.currentPage().getParameters().put('peoplePollTimeStamp', 'now');
	    ApexPages.currentPage().getParameters().put('data', '{"filter":"all","peopleId":"","size":16,"nextPageToken":""}');
	    ads.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'getPeopleChangeInfo');
        ApexPages.currentPage().getParameters().put('peoplePollTimeStamp', '');
	    ads.handleRequest();
	    	
	    System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetDashboardTiles() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobileUtilityDataServer');
        Test.setCurrentPage(pageRef);
        MobileUtilityDataServer mobileutilityDSObj = new MobileUtilityDataServer();    
        ApexPages.currentPage().getParameters().put('action', 'getDashboardTiles');
        ApexPages.currentPage().getParameters().put('siteId', '');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchPeople',false));
        mobileutilityDSObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success', mobileutilityDSObj.response.status, 'Running as expected');
    }
    
}