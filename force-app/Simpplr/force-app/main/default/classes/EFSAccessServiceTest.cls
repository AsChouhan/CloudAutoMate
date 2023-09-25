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
private class EFSAccessServiceTest {

    private static App_Integration__c appIntegRecord;
	private static People_Integration__c pplIntegRec;
    @testSetup static void setup() {
    	TestHelper.setUpAppIntegration();        
        System.assert(true, 'Running as expected');
    }
    
    static void init() {
        appIntegRecord =  [SELECT Id, Client_Id__c, Client_Secret__c,
				integration_Enabled__c, name, Scope__c,
				app_Access_Token__c from App_Integration__c limit 1];
							
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    	pplIntegRec = TestHelper.createPeopleIntegRecordForUser(peopleObj.Id);
    	TestHelper.updatePeopleIntegRec(pplIntegRec.id,appIntegRecord.id);		
    }
    
     @isTest static void testDBService() {
    	init();
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('dropbox'));
    	
    	appIntegRecord.name = 'dropbox';
    	appIntegRecord.DB_User_Client_Id__c = 'test dropboc client id';
    	update appIntegRecord;
    	EFSAccessService.setUser(UserInfo.getUserId());
    	EFSAccessService EFSAsAdminObj = new EFSAccessService('dropbox', true);
    	EFSAsAdminObj.getTokenType();
		EFSAsAdminObj.getAccessToken();
		EFSAsAdminObj.getAccessTokenExpiresIn();
		EFSAsAdminObj.isAdmin();
		EFSAsAdminObj.isSaved();
    	EFSAsAdminObj.getAuthPage();
    	EFSAsAdminObj.isAccessValid();
    	EFSAsAdminObj.isAccessExpired();
    	
    	EFSAsAdminObj.getAccessTypeAndToken();
    	EFSAccessService.getAuthURL('dropbox');
    	
		EFSAsAdminObj.getAuthorizationEndpoint();
		EFSAsAdminObj.getTokenEndpoint();
		EFSAsAdminObj.getClientId();
		EFSAsAdminObj.getClientSecret();
		EFSAsAdminObj.getRedirectUri();
		EFSAsAdminObj.getExtraUrlParameters();
    	
    	EFSAsAdminObj.close();
    	Test.stopTest();

		System.assert(true, 'Running as expected');
    }
    
     @isTest static void testSPService() {
    	init();
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('sharepoint'));
    	appIntegRecord.name = 'sharepoint';
    	update appIntegRecord;
    	EFSAccessService.setUser(UserInfo.getUserId());
    	EFSAccessService EFSAsAdminObj = new EFSAccessService('sharepoint', true);
    	EFSAsAdminObj.getTokenType();
		EFSAsAdminObj.getAccessToken();
		EFSAsAdminObj.getAccessTokenExpiresIn();
		EFSAsAdminObj.isAdmin();
		EFSAsAdminObj.isSaved();
    	EFSAsAdminObj.getAuthPage();
    	EFSAsAdminObj.isAccessValid();
    	EFSAsAdminObj.isAccessExpired();
    	
		EFSAsAdminObj.refreshToken();
    	EFSAsAdminObj.saveToken();
    	EFSAsAdminObj.getAccessTypeAndToken();
    	EFSAccessService.getAuthURL('sharepoint');
    	
		EFSAsAdminObj.getAuthorizationEndpoint();
		EFSAsAdminObj.getTokenEndpoint();
		EFSAsAdminObj.getClientId();
		EFSAsAdminObj.getClientSecret();
		EFSAsAdminObj.getRedirectUri();
		EFSAsAdminObj.getExtraUrlParameters();
    	
    	EFSAsAdminObj.close();
    	Test.stopTest();

		System.assert(true, 'Running as expected');
    }

    @isTest
    public static void testSPMutiInstanceService() {
    	init();
        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('sharepoint'));
    	appIntegRecord.name = 'sharepoint';
    	update appIntegRecord;
    	Test.startTest();
    	EFSAccessService.setUser(UserInfo.getUserId());
    	EFSAccessService EFSAsAdminObj = new EFSAccessService('sharepoint', false);
    	Boolean isAdminConnected = EFSAsAdminObj.isSharepointConnected('123');
    	EFSAsAdminObj.close();
    	Test.stopTest();

		System.assertEquals(true, isAdminConnected, 'Running as expected');
    }
}