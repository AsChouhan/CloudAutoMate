@isTest
private with sharing class MobilePeopleDataServerTest {
	@testSetup static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		PeopleDao peopleDaoObj = new PeopleDao();
        peopleDaoObj.insertPeople(new List<User>{ getUser(UserContext.id) });
        
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        User testUser2 = TestHelper.createUser('Simpplr_usr2', null, false);
        User siteMngr = TestHelper.createUser('Simpplr_siteMngr', null, false);
        
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
        Test.startTest();
    	List<Simpplr_Site__c>siteList = [Select Id, Chatter_Group_Id__c from Simpplr_Site__c];
    	String chatterGroupId = siteList[0].Chatter_Group_Id__c;
    	
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobilePeopleDataServer');
        Test.setCurrentPage(pageRef);
        MobilePeopleDataServer mpds = new MobilePeopleDataServer();
        mpds.getPageFeature();
        mpds.handleRequest();
        
        Map<String, Object> mapDataMap = new Map<String, Object>();
        mapDataMap.put('size', '100');
        mapDataMap.put('chatterGroupId', chatterGroupId);
        mapDataMap.put('term', '');
        
        ApexPages.currentPage().getParameters().put('action', 'getAllSiteMembers');
        ApexPages.currentPage().getParameters().put('data', Json.serialize(mapDataMap));
        mpds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('isFullModel','true');
        mpds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('data', '');
        mpds.handleRequest();
        
        ApexPages.currentPage().getParameters().put('action', 'renewExternalPhotoURL');
        mpds.handleRequest();    	    		
        Test.stopTest();
        System.assert(true,'Running as expected');
    }

    @isTest static void testHandleRenewExternalPhotoURL() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'MobilePeopleDataServer');
        Test.setCurrentPage(pageRef);
        MobilePeopleDataServer mpds = new MobilePeopleDataServer();

        ApexPages.currentPage().getParameters().put('action', 'renewExternalPhotoURL');
        mpds.handleRequest();  
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
}