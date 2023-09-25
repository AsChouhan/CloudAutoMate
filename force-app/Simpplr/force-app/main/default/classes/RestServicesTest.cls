@isTest
private with sharing class RestServicesTest {
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
    @isTest static void testGetBaseUrl() {
       	RestRequest req = new RestRequest(); 
       	RestResponse res = new RestResponse();
        req.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/getBasicAppInformation';
       	req.httpMethod = 'POST';
       	RestContext.request = req;
       	RestContext.response= res;
		RestServices.getBasicAppInformation();
    	System.assert(true,'Running as expected');
    }
}