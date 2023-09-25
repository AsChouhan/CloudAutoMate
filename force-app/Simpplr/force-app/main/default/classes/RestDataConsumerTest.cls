@isTest
public with sharing class RestDataConsumerTest {
    @testSetup 
    static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		PeopleDao peopleDaoObj = new PeopleDao();
        peopleDaoObj.insertPeople(new List<User>{ TestHelper.getUserById(UserContext.id) });
        
        TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        TestHelper.createUser('Simpplr_usr2', null, false);
        TestHelper.createUser('Simpplr_siteMngr', null, false);
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);
		TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
		TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        
        collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		testSite = TestHelper.getSiteRecord(collaborationGroupId);
		TestHelper.createContent('PageDataServerTest Page', 'Page', 'Approved', testAdminUser, testSite);
    }

    @isTest
    static void testDoGet() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/RestAPIDataConsumer';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        RestDataConsumer.doGet();
        System.assertEquals(200, res.statusCode, 'Running as expected');
    }

    @isTest
    static void testDoPost() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = Url.getSalesforceBaseUrl().toExternalForm()+'/services/apexrest/RestAPIDataConsumer';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        RestDataConsumer.doPost();
        System.assertEquals(200, res.statusCode, 'Running as expected');
    }
}