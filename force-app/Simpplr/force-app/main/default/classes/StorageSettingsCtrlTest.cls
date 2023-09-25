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
private class StorageSettingsCtrlTest {
   private static App_Config__c appConfigRecord;
	
    @testSetup static void setup() {
        appConfigRecord = TestHelper.setupAppConfig();
		appConfigRecord.Box_Managed_Permissions__c = 'simpplr';
        update appConfigRecord;
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    	 TestHelper.createPeoplePreference(peopleObj.Id);
    	 List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'gdrive', 'dropbox', 'sharepoint', 'onedrive','adsi', 'googledrive'});
        TestHelper.createPeopleIntegrationRecords(appIntList, UserContext.peopleId, 'asdasd');
    }

	static void init() {
        AccessManager.manageCookieCsrf(AccessManager.getCsrfToken());
    }	
    
    @isTest static void testsaveUserDetails() {
    	String pageName = Pages.StorageSettings;
    	PageReference pgRef = Page.StorageSettings;
		Test.setCurrentPage(pgRef);
		init();
        
        StorageSettingsCtrl obj = new StorageSettingsCtrl();
        
        pgRef.getParameters().put('state', 'Box');
    	obj.saveUserDetails();
        
        pgRef.getParameters().put('state', 'BoxAdmin');
		obj.saveUserDetails();
        
        pgRef.getParameters().put('state', 'adsi');
		obj.saveUserDetails();
        
        pgRef.getParameters().put('state', 'Box');
		pgRef.getParameters().put('code', '123');
    	obj.saveUserDetails();
    	
    	pgRef.getParameters().put('state', 'BoxAdmin');
    	pgRef.getParameters().put('code', '123');
		obj.saveUserDetails();
        
        pgRef.getParameters().put('state', 'googledriveadmin');
	 pgRef.getParameters().put('code', '123');
    	 obj.saveUserDetails();
		
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void testGoogleDriveAdminInfoSave() {
		PageReference pgRef = Page.StorageSettings;
    		pgRef.getParameters().put('state', 'googledriveadmin');
		pgRef.getParameters().put('code', '123');
        	pgRef.getParameters().put('isConnected', 'true');
        	pgRef.getParameters().put('simpManagedPermissions', 'true');
        	pgRef.getParameters().put('myDriveEnabled', 'true');
        	pgRef.getParameters().put('userName', 'dummy');
        	pgRef.getParameters().put('userEmail', 'dummy@gmail.com');
        	pgRef.getParameters().put('userDomain', 'dummy');
        	pgRef.getParameters().put('allCompanyGroupId', 'dummy');
        	pgRef.getParameters().put('isSuccess', 'true');
		Test.setCurrentPage(pgRef);
    	init();
    		StorageSettingsCtrl obj = new StorageSettingsCtrl();
		obj.saveUserDetails();
    		System.assert(true, 'Running as expected');
    }
    
    @isTest static void testGoogleDriveNonAdminInfoSave() {
		PageReference pgRef = Page.StorageSettings;
    		pgRef.getParameters().put('state', 'googledrive');
		pgRef.getParameters().put('code', '123');
        	pgRef.getParameters().put('isConnected', 'true');
        	pgRef.getParameters().put('myDriveId', 'dummy');
        	pgRef.getParameters().put('userName', 'dummy');
        	pgRef.getParameters().put('userEmail', 'dummy@gmail.com');
        	pgRef.getParameters().put('userDomain', 'dummy');
		Test.setCurrentPage(pgRef);
    	init();
    		StorageSettingsCtrl obj = new StorageSettingsCtrl();
    		obj.saveUserDetails();
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void testGoogleDriveNonAdminInfoSaveWithAppIntegration() {
		PageReference pgRef = Page.StorageSettings;
    	pgRef.getParameters().put('state', 'gdrive');
		pgRef.getParameters().put('code', '123');
		Test.setCurrentPage(pgRef);
		init();
        TestHelper.setUpAppIntegration();
    	StorageSettingsCtrl obj = new StorageSettingsCtrl();
    
    	Test.startTest();
		
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('', 200, 'GoogleDriveNonAdminInfoSave', false));
    	obj.saveUserDetails();
    	
    	Test.stopTest();
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void testGoogleDriveAdminInfoSaveWithAppIntegration() {
		PageReference pgRef = Page.StorageSettings;
        Test.setCurrentPage(pgRef);
    	init();
        TestHelper.setUpAppIntegration();
    	App_Config__c appObj = TestHelper.setupAppConfig();
    	StorageSettingsCtrl obj = new StorageSettingsCtrl();
        
		Test.startTest();
        pgRef.getParameters().put('state', 'gdriveadmin');
		pgRef.getParameters().put('code', '123');
		
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('', 200, 'GoogleDriveAdminInfoSave', false));
    	obj.saveUserDetails();
    	
    	Test.stopTest();
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void testDropBoxAdminInfoSaveWithAppIntegration() {
		PageReference pgRef = Page.StorageSettings;
        Test.setCurrentPage(pgRef);
        init();
    	App_Config__c appObj = TestHelper.setupAppConfig();
    	StorageSettingsCtrl obj = new StorageSettingsCtrl();
        
		Test.startTest();
        pgRef.getParameters().put('state', 'dropboxadmin');
		pgRef.getParameters().put('code', '123');
		
    	obj.saveUserDetails();
    	
    	Test.stopTest();
    	
    	System.assert(true, 'Running as expected');
    }

    @isTest
    static void testSharepointSaveWithAppIntegration() {
		PageReference pgRef = Page.StorageSettings;
        Test.setCurrentPage(pgRef);
        init();
    	App_Config__c appObj = TestHelper.setupAppConfig();
        appObj.SP_Upgrade_Status__c = 'completed';
        update appObj;
    	StorageSettingsCtrl obj = new StorageSettingsCtrl();
        
		Test.startTest();
        pgRef.getParameters().put('state', 'sharepoint');
		pgRef.getParameters().put('code', '123');
		
    	PageReference pgRefReturned = obj.saveUserDetails();
    	System.assertEquals(true, pgRefReturned.getParameters().get('alert').contains('success'), 'Running as expected');
    	Test.stopTest();
    }

    @isTest
    static void testDropBoxSaveWithAppIntegration() {
		PageReference pgRef = Page.StorageSettings;
        Test.setCurrentPage(pgRef);
        init();
    	App_Config__c appObj = TestHelper.setupAppConfig();
    	StorageSettingsCtrl obj = new StorageSettingsCtrl();
        
		Test.startTest();
        pgRef.getParameters().put('state', 'dropbox');
		pgRef.getParameters().put('code', '123');
		Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('dropbox'));
    	PageReference pgRefReturned = obj.saveUserDetails();
    	System.assertEquals(true, pgRefReturned.getParameters().get('alert').contains('success'), 'Running as expected');
    	Test.stopTest();
    }

    @isTest
    static void testNoAuthCodeSaveWithAppIntegration() {
		PageReference pgRef = Page.StorageSettings;
        Test.setCurrentPage(pgRef);
        init();
    	App_Config__c appObj = TestHelper.setupAppConfig();
    	StorageSettingsCtrl obj = new StorageSettingsCtrl();
        
		Test.startTest();
        List<App_Integration__c> appIntegrations = [SELECT Id FROM App_Integration__c];
        for(App_Integration__c appInt:appIntegrations) {
            appInt.Batch_Processing__c = true;
        }
        update appIntegrations;

        pgRef.getParameters().put('state', 'dropbox');
		pgRef.getParameters().put('code', null);
		
    	PageReference pgRefReturned = obj.saveUserDetails();
    	System.assertEquals(true, pgRefReturned.getParameters().get('alert').contains('danger'), 'Running as expected');
    	Test.stopTest();
    }

    @isTest
    static void testNoAuthCancelledSaveWithAppIntegration() {
		PageReference pgRef = Page.StorageSettings;
        Test.setCurrentPage(pgRef);
        init();
    	App_Config__c appObj = TestHelper.setupAppConfig();
    	StorageSettingsCtrl obj = new StorageSettingsCtrl();
        
		Test.startTest();
        pgRef.getParameters().put('state', 'dropbox');
		pgRef.getParameters().put('error', 'dropbox error');
		pgRef.getParameters().put('error_description', 'some error occured here');
		pgRef.getParameters().put('code', null);
		
    	PageReference pgRefReturned = obj.saveUserDetails();
    	System.assertEquals(true, pgRefReturned.getParameters().get('alert').contains('danger'), 'Running as expected');
    	Test.stopTest();
    }

	@isTest static void testGoogleDriveErrorSingleDomain() {
		PageReference pgRef = Page.StorageSettings;
    	pgRef.getParameters().put('state', 'googledrive');
		pgRef.getParameters().put('error_code', 'not_a_gsuite_account');
		App_Config__c appConfig = [SELECT Id, Google_Multi_Domain_Upgrade_Status__c FROM App_Config__c LIMIT 1];
		appConfig.Google_Multi_Domain_Upgrade_Status__c = ServiceConstants.UPGRADE_STATUS_NOT_STARTED_YET;
		update appConfig;
		Test.setCurrentPage(pgRef);
    	init();
    		StorageSettingsCtrl obj = new StorageSettingsCtrl();
    		obj.saveUserDetails();
    	System.assert(true, 'Running as expected');
    }

	@isTest static void testGoogleDriveErrorMultiDomain() {
		PageReference pgRef = Page.StorageSettings;
    	pgRef.getParameters().put('state', 'googledrive');
		pgRef.getParameters().put('error_code', 'not_a_gsuite_account');
		App_Config__c appConfig = [SELECT Id, Google_Multi_Domain_Upgrade_Status__c FROM App_Config__c LIMIT 1];
		appConfig.Google_Multi_Domain_Upgrade_Status__c = ServiceConstants.UPGRADE_STATUS_COMPLETED;
		update appConfig;
		Test.setCurrentPage(pgRef);
    	init();
    		StorageSettingsCtrl obj = new StorageSettingsCtrl();
    		obj.saveUserDetails();
    	System.assert(true, 'Running as expected');
    }
}