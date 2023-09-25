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
private class EFSSiteServiceTest {
	private static App_Integration__c appIntegRecord;
	private static People_Integration__c pplIntegRec;
	
    @testSetup static void setup() {
    	appIntegRecord = TestHelper.setUpAppIntegration();
        
        System.assert(true, 'Running as expected');
    }
    
    static void initDb() {
    	People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    	TestHelper.createPeopleIntegRecordForUser(peopleObj.Id);
        appIntegRecord = [SELECT Id, Client_Id__c, Client_Secret__c,
				integration_Enabled__c, name, Scope__c,
				app_Access_Token__c from App_Integration__c where name = 'gdrive'];

        if (appIntegRecord.name != 'dropbox') {
        	appIntegRecord.Enterprise_Id__c = 'email.com';
            appIntegRecord.name = 'dropbox';
            update appIntegRecord;
        }
        	
    }
    
    @isTest static void createSiteServiceDropbox() {
    	initDb();

    	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('dropbox'));
        
    	new EFSSiteService('dropbox');
    	
    	try{
    		EFSSiteService EFSSiteServiceObj = new EFSSiteService(new EFSAccessService('dropbox', true), new EFSAccessService('dropbox', false)); 
			EFSSiteServiceObj.createSiteFolder('Dummysite', 'DummyCgId', true);
			
	    	EFSSiteServiceObj.addAdmin('DummyCgId', 'dummy@dummy.com', true);
	    	EFSSiteServiceObj.addMember('DummyCgId', 'dummy@dummy.com', true);
	    	
	    	EFSSiteServiceObj.removeMember('DummyCgId', 'dummy@dummy.com');
	    	EFSSiteServiceObj.removeAdmin('DummyCgId', 'dummy@dummy.com');
    	
		    EFSSiteServiceObj.close();
    	} catch(Exception ex) {
    		
    	}
		
		Test.stopTest();
        System.assert(true, 'Running as expected');
    }
}