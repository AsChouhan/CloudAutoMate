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
private class ConnectExternalAppCtrlTest {
	
	static App_Config__c appConfigRecord;
	static PageReference pageRef;
	static People__c peopleObject;
	
	@testSetup static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		CollaborationGroup cgroup = TestHelper.createCollaborationGroup('Simpplr_Grp_SiteDataServerTest','Public');
        peopleObject = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
	    List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW});
        TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW,appIntegList[0].id);
		List<App_Integration__c>  appIntegList1 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT,appIntegList1[0].id);
		List<App_Integration__c>  appIntegList2 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE,appIntegList2[0].id);
		List<App_Integration__c>  appIntegList3 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_DROPBOX});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_DROPBOX,appIntegList3[0].id);
		List<App_Integration__c>  appIntegList4 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE,appIntegList4[0].id);
		List<App_Integration__c>  appIntegList5 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL,appIntegList5[0].id);
		List<App_Integration__c>  appIntegList6 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT,appIntegList6[0].id);
        List<App_Integration__c>  appIntegList7 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR,appIntegList7[0].id);
        List<App_Integration__c>  appIntegList8 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS});
		TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR});
		Simpplr_Metadata__c simpplrMetadataObj = new Simpplr_Metadata__c();
		simpplrMetadataObj.Type__c = ServiceConstants.SIMPPLR_SCHEDULE_JOB;
		simpplrMetadataObj.Value__c = '[{"setOfApexClass":["BatchPendingApprovalDigest"],"size":100,"cron_exp":"0 1 0,4,8,12,16,20 * * ?","description":"Scheduler job for sending pending approval digest","name":"SchedulerBatchPendingApprovalDigest"}]';
		insert simpplrMetadataObj;
		System.assert(true,'Running as expected');
	}
	
    static void init() {
        pageRef = Page.ConnectExternalApp;
        Test.setCurrentPage(pageRef);

        AccessManager.manageCookieCsrf(AccessManager.getCsrfToken());
    }	

	public static void deleteMSTeamsAppIntegrationRecords() {
		List<App_Integration__c> appInteList = [select id, Name from App_Integration__c where Name =:IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS];
		delete appInteList;
	}
	
	@isTest static void testTwitter() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		
		pageRef.getParameters().put('state','twitter');
		pageRef.getParameters().put('oauth_verifier','twitter_oauth_verifier');
		pageRef.getParameters().put('oauth_token','twitter_oauth_token');
		pageRef.getParameters().put('denied','no');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/campaigndataserver/twitterSaveToken', false));
		connectExternalAppCtrlObj.saveAppDetails();
		
		System.assert(true,'Running as expected');
	}
    
    @isTest static void testBn() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		
		pageRef.getParameters().put('state','bn');
		pageRef.getParameters().put('code','some_code');
        pageRef.getParameters().put('userAgent','agent');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectexternalapp', false));
		connectExternalAppCtrlObj.saveAppDetails();
	
		System.assert(true,'Running as expected');
	}
	
	@isTest static void testFacebook() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		
		pageRef.getParameters().put('state','facebook');
		pageRef.getParameters().put('code','facebook_code');
		pageRef.getParameters().put('error','no');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectexternalapp/processcodefromfacebook', false));
		connectExternalAppCtrlObj.saveAppDetails();
		
		System.assert(true,'Running as expected');
	}
	
	@isTest static void testLinkedin() {
		Test.startTest();
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		pageRef.getParameters().put('state','linkedin');
		pageRef.getParameters().put('code','linkedin_code');
		pageRef.getParameters().put('error','no');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectexternalapp/processcodefromlinkedin', false));
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		System.assert(true,'Running as expected');
	}	
	
	@isTest static void testAdsi() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		
		pageRef.getParameters().put('state','adsi');
		pageRef.getParameters().put('code','adsi_code');
		pageRef.getParameters().put('error','no');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectexternalapp/processcodefromadsi', false));
		connectExternalAppCtrlObj.saveAppDetails();
		pageRef.getParameters().put('code',null);
		pageRef.getParameters().put('retURL',null);
		connectExternalAppCtrlObj.saveAppDetails();
		System.assert(true,'Running as expected');
	}
	
	@isTest static void testExternalSearch() {
		Test.startTest();
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		App_Config__c appCon = [Select id ,AWS_Access_Token__c From App_Config__c];
		appCon.AWS_Access_Token__c = '';
		update appCon;
		pageRef.getParameters().put('state','ServiceAccount');
		pageRef.getParameters().put('code','externalsearch_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		pageRef.getParameters().put('retURL',null);
		connectExternalAppCtrlObj.saveAppDetails();
		pageRef.getParameters().put('error','danger');
		connectExternalAppCtrlObj.saveAppDetails();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/externalSearch', false));
		Test.stopTest();
		App_Config__c configObj = [select id,External_search_app_connected__c  from App_Config__c limit 1];
		System.assertEquals(true, configObj.External_search_app_connected__c, 'Running as expected');
	}
    
    @isTest static void testGoogleCalendar() {
		Test.startTest();
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		App_Config__c appCon = [Select id ,AWS_Access_Token__c From App_Config__c];
		appCon.AWS_Access_Token__c = '';
		update appCon;
		pageRef.getParameters().put('state','googlecalendar');
		pageRef.getParameters().put('userName','testUserName');
		pageRef.getParameters().put('isConnected','true');
        pageRef.getParameters().put('userEmail','test@gmail.com');
        pageRef.getParameters().put('userDomain','test');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		People_Integration__c peopleIntegrationRec = [select id, Connected__c from People_Integration__c where name = 'googlecalendar' and is_deleted__c = false limit 1];
		
		System.assertEquals(true, peopleIntegrationRec.Connected__c,'Running as expected');
	}
    
    @isTest static void testGoogleCalendarErrorCodeArg() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','googlecalendar');
		pageRef.getParameters().put('error_code','error_code');
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}
    @isTest static void testGoogleCalendarError() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','googlecalendar');
		pageRef.getParameters().put('error','error');
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}

	@isTest static void testServiceNow() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','ServiceNowAdmin');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		pageRef.getParameters().put('state','ServiceNow');
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		App_Integration__c appIntegrationRec = [select id, App_Access_Token__c from App_Integration__c where name = 'ServiceNow' and is_deleted__c = false limit 1];
		
		System.assertEquals('test', appIntegrationRec.App_Access_Token__c,'Running as expected');
	}

	@isTest static void testSharepointAdmin() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','sharepointadmin');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		App_Integration__c appIntegrationRec = [select id, App_Access_Token__c from App_Integration__c where name = 'sharepoint' and is_deleted__c = false limit 1];
		
		System.assertEquals('sharepointdummyaccestoken', appIntegrationRec.App_Access_Token__c,'Running as expected');
	}
    
    @isTest static void testGoogleUserSyncAdmin() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/googleusersyncadmin/', false));
		pageRef.getParameters().put('state','googleusersyncadmin');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		System.assert(true,'Running as expected');
	}
    
    @isTest static void testGoogleUserSyncAdminErrorCodeArg() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','googleusersyncadmin');
		pageRef.getParameters().put('error_code','error_code');
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}
    @isTest static void testGoogleUserSyncAdminError() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','googleusersyncadmin');
		pageRef.getParameters().put('error','error');
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}
    
    @isTest static void testGoogleCalendarAdmin() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/GDriveDataServer/', false));
		pageRef.getParameters().put('state','googlecalendaradmin');
        pageRef.getParameters().put('gUserName','atlassianadmin');
        pageRef.getParameters().put('gUserEmail','atlassianadmin@test.com');
        pageRef.getParameters().put('gUserId','atlassianadmin');
        pageRef.getParameters().put('gUserDomain','atlassianadmin');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		System.assert(true,'Running as expected');
	}
    
    @isTest static void testGoogleCalendarAdminErrorCodeArg() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','googlecalendaradmin');
		pageRef.getParameters().put('error_code','error_code');
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}
    @isTest static void testGoogleCalendarAdminError() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','googlecalendaradmin');
		pageRef.getParameters().put('error','error');
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}
    
    @isTest static void testAtlassianAdmin() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/AtlassianDataServer/', false));
		pageRef.getParameters().put('state','atlassianadmin');
        pageRef.getParameters().put('aUserName','atlassianadmin');
        pageRef.getParameters().put('aUserEmail','atlassianadmin@test.com');
        pageRef.getParameters().put('aUserId','atlassianadmin');
        pageRef.getParameters().put('isSuccess','true');
        pageRef.getParameters().put('isConnected','true');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		System.assert(true,'Running as expected');
	}
    
    @isTest static void testAtlassianAdminErrorCodeArg() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','atlassianadmin');
		pageRef.getParameters().put('error_code','error_code');
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}
    @isTest static void testAtlassianAdminError() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','atlassianadmin');
		pageRef.getParameters().put('error','error');
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}

	@isTest static void testOnedriveAdmin() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE,appIntegList[0].id);
		appIntegList[0].Token_Type__c = 'dummy';
		update appIntegList;
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','onedriveadmin');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		App_Integration__c appIntegrationRec = [select id, App_Access_Token__c from App_Integration__c where name = 'onedrive' and is_deleted__c = false limit 1];
		
		System.assertEquals('onedrivedummyaccestoken', appIntegrationRec.App_Access_Token__c,'Running as expected');
	}
	@isTest static void testDropboxAdmin() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','dropboxadmin');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		App_Integration__c appIntegrationRec = [select id, App_Access_Token__c from App_Integration__c where name = 'dropbox' and is_deleted__c = false limit 1];

		System.assertEquals('dropboxdummyaccestoken', appIntegrationRec.App_Access_Token__c,'Running as expected');
	}
	@isTest static void testGdriveAdmin() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','gdriveadmin');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		PageReference res = connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();

		System.assertNotEquals(null, res.getUrl(),'Running as expected');
	}
	@isTest static void testSharepoint() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','sharepoint');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		People_Integration__c peopleIntegrationRec = [select id, Access_Token__c from People_Integration__c where name = 'sharepoint' and is_deleted__c = false limit 1];
		
		System.assertNotEquals('', peopleIntegrationRec.Access_Token__c,'Running as expected');
	}
	@isTest static void testDropbox() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','dropbox');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		People_Integration__c peopleIntegrationRec = [select id, Access_Token__c from People_Integration__c where name = 'dropbox' and is_deleted__c = false limit 1];
		
		System.assertNotEquals('', peopleIntegrationRec.Access_Token__c,'Running as expected');
	}

	@isTest static void testGdrive() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','gdrive');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		Pagereference res = connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assertNotEquals('', res.getUrl(),'Running as expected');
	}

	@isTest static void testSlackAppInstall() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','slackAppInstall');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		pageRef.getParameters().put('status','success');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
		appIntegList[0].Is_Deleted__c = false;
		appIntegList[0].App_installed__c = false;
		update appIntegList;
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK,appIntegList[0].id);
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		App_Integration__c appIntegrationRec = [select id, Integration_Enabled__c from App_Integration__c where name =:IntegrationConstants.INTEGRATION_TYPE_SLACK and is_deleted__c = false limit 1];
		
		System.assertEquals(true, appIntegrationRec.Integration_Enabled__c,'Running as expected');
	}

	@isTest static void testSlackAppInstallRedirect() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','slackAppInstallRedirect');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		pageRef.getParameters().put('status','success');
		Test.setCurrentPage(pageRef);	
		
		Pagereference res = connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assertNotEquals(null, res.getUrl(),'Running as expected');
	}

	@isTest static void testSlackAppUninstall() {
		init();
		SimpplrContext.isSlackPhase2FeatureEnabled = false;
		List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
		appIntegList[0].Is_Deleted__c = false;
		appIntegList[0].App_installed__c = true;
		update appIntegList;
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK,appIntegList[0].id);
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('source','salesforce');
		pageRef.getParameters().put('state','slackAppUninstall');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		App_Integration__c appIntegrationRec = [select id, App_Installed__c from App_Integration__c where name = :IntegrationConstants.INTEGRATION_TYPE_SLACK AND Is_Deleted__c = false];
		
		System.assertEquals(false, appIntegrationRec.App_Installed__c,'Running as expected');
	}

	@isTest static void testSlackUnfurlAppUninstallPhase2() {
		init();
		SimpplrContext.isSlackPhase2FeatureEnabled = true;
		SimpplrContext.isSlackUpgraded = true;
		UserContext.uuid = 'testuser1';
		SimpplrContext.uuid = 'testorguuid';
		List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
		appIntegList[0].Is_Deleted__c = false;
		appIntegList[0].App_installed__c = true;
		update appIntegList;
		//TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK,appIntegList[0].id);
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('source','salesforce');
		pageRef.getParameters().put('state','slackAppUninstall');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		App_Integration__c appIntegrationRec = [select id, App_Installed__c from App_Integration__c where name = :IntegrationConstants.INTEGRATION_TYPE_SLACK AND Is_Deleted__c = false];
		
		System.assertEquals(false, appIntegrationRec.App_Installed__c,'Running as expected');
	}

	@isTest static void testEnableSlackForSite() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','enableSlackForSite');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		Test.setCurrentPage(pageRef);	
		
		PageReference res = connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assertNotEquals('', res.getUrl(),'Running as expected');
	}

	@isTest static void testRemoveSlackFromSite() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Simpplr_Site__c siteObj = [select id from Simpplr_Site__c limit 1];
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','removeSlackFromSite');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		pageRef.getParameters().put('siteId', siteObj.id);
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		siteObj = [SELECT Id, Slack_Access_Token__c FROM Simpplr_Site__c where Id =: siteObj.Id];
		
		System.assertEquals(null, siteObj.Slack_Access_Token__c,'Running as expected');
	}

	@isTest static void testIntegrationTypeSalesforce() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','salesforce');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
        pageRef.getParameters().put('status','success');
		Test.setCurrentPage(pageRef);
        connectExternalAppCtrlObj.saveAppDetails();
		List<App_Integration__c>  appIntegList7 = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SALESFORCE});
        appIntegList7[0].Is_Deleted__c = false;
        update appIntegList7;
        TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SALESFORCE,appIntegList7[0].id);
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		System.assert(true,'Running as expected');
	}

	@isTest static void testResetSiteSlackSetting() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Simpplr_Site__c siteObj = [select id from Simpplr_Site__c limit 1];
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		pageRef.getParameters().put('state','resetSiteSlackSetting');
		pageRef.getParameters().put('code','sn_code');
		pageRef.getParameters().put('retURL','http://a.b.com');
		pageRef.getParameters().put('siteId', siteObj.id);
		Test.setCurrentPage(pageRef);	
		
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		siteObj = [SELECT Id, Slack_Access_Token__c FROM Simpplr_Site__c where Id =: siteObj.Id];
		
		System.assertEquals(null, siteObj.Slack_Access_Token__c,'Running as expected');
	}
	
	@isTest static void testGetServiceNowUser() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectExternalApp/getServicenowUser', false));
		ServiceNowWrapper result = connectExternalAppCtrlObj.getServiceNowUser('test');
		Test.stopTest();

		System.assertNotEquals(null, result,'Running as expected');
	}

	@isTest static void testCreatePeopleIntegRecord() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		String respJSON = '{"access_token":"test","refresh_token":"test","expires_in":36000}';
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(respJSON);
		connectExternalAppCtrlObj.createPeopleIntegRecord(new ServiceNowWrapper(), respMap);
		Test.stopTest();
		People_Integration__c peopleIntegrationRec = [select id, Access_Token__c from People_Integration__c where name =:IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW and is_deleted__c = false limit 1];
		
		System.assertEquals('test', peopleIntegrationRec.Access_Token__c,'Running as expected');
	}

	@isTest static void testUpdateAppIntegRecord() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		Test.startTest();
		String respJSON = '{"access_token":"test","refresh_token":"test","expires_in":36000}';
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(respJSON);
		connectExternalAppCtrlObj.updateAppIntegRecord(new ServiceNowWrapper(), respMap);
		Test.stopTest();
		App_integration__c appIntegrationRec = [select id, App_Access_Token__c from App_integration__c where name =:IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW and is_deleted__c = false limit 1];
		
		System.assertEquals('test', appIntegrationRec.App_Access_Token__c,'Running as expected');
	}

	@isTest static void testClearInstallationDetailFromAWS() {
		init();
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
		ConnectExternalAppCtrl.clearInstallationDetailFromAWS();
		Test.stopTest();

		System.assert(true,'Running as expected');
	}

	@isTest static void testMicrosoftTeams() {
		init();
		SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 = true;
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
        pageRef.getParameters().put('state','microsoftteams');
        pageRef.getParameters().put('alert', '{"message":"Connected to Microsoft Teams successfully","type":"success","translationCode":"my_settings.apps.connection.success","serviceName":"Microsoft Teams"}');
        Test.startTest();
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectExternalApp/microsoftteams', false));
        connectExternalAppCtrlObj.saveAppDetails();	
        Test.stopTest();
        List<People_Integration__c> peopleIntegrationList = [SELECT Id FROM People_Integration__c WHERE name = 'microsoftteams' and Connected__c = true];
        System.assertEquals(1, peopleIntegrationList.size(), 'Microsoft teams not connected');	
	}

	@isTest static void testMicrosoftTeamsAdminConnect() {
		init();
		deleteMSTeamsAppIntegrationRecords();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		SimpplrContext.uuid = 'abcd-slgis-slgj-envs';
        pageRef.getParameters().put('state','microsoftTeamsAdmin');
        pageRef.getParameters().put('alert', '{"message":"Connected to Microsoft Teams successfully","type":"success","translationCode":"my_settings.apps.connection.success","serviceName":"Microsoft Teams"}');
        Test.startTest();
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectExternalApp/microsoftteams', false));
        connectExternalAppCtrlObj.saveAppDetails();	
        Test.stopTest();
        List<App_Integration__c> appIntegrationList = [SELECT Id FROM App_Integration__c WHERE name = 'microsoftteams' and Connected__c = true];
        System.assertEquals(1, appIntegrationList.size(), 'Microsoft teams not connected');	
	}

	@isTest static void testMicrosoftTeamsAdminConnectUpdate() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
        pageRef.getParameters().put('state','microsoftTeamsAdmin');
        pageRef.getParameters().put('alert', '{"message":"Connected to Microsoft Teams successfully","type":"success","translationCode":"my_settings.apps.connection.success","serviceName":"Microsoft Teams"}');
        Test.startTest();
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectExternalApp/microsoftteams', false));
        connectExternalAppCtrlObj.saveAppDetails();	
        Test.stopTest();
        List<App_Integration__c> appIntegrationList = [SELECT Id FROM App_Integration__c WHERE name = 'microsoftteams' and Connected__c = true];
        System.assertEquals(1, appIntegrationList.size(), 'Microsoft teams not connected');	
	}

	@isTest static void testMicrosoftTeams1() {
		init();
        SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 = false;
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
        pageRef.getParameters().put('state','microsoftteams');
        pageRef.getParameters().put('displayName','testUserName');
        pageRef.getParameters().put('externalId','12345678');
        pageRef.getParameters().put('email','test@gmail.com');
		pageRef.getParameters().put('tenantId','dfh728-fgjie8-buavb4');
        pageRef.getParameters().put('isSuccess','true');
		pageRef.getParameters().put('alert', '{"message":"Connected to Microsoft Teams successfully","type":"success","translationCode":"my_settings.apps.connection.success","serviceName":"Microsoft Teams"}');
        Test.startTest();
        Test.setCurrentPage(pageRef);	
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/get-jwt-token', false));
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectExternalApp/microsoftteams', false));
        connectExternalAppCtrlObj.saveAppDetails();
        Test.stopTest();
        People_Integration__c peopleIntegrationRec = [select id, Connected__c from People_Integration__c where name = 'microsoftteams' and is_deleted__c = false limit 1];
        System.assertEquals(true, peopleIntegrationRec.Connected__c,'Microsoft Teams not connected');
	}

	@isTest static void testSlackPhaseTwo() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		SimpplrContext.uuid = 'account_id';
		UserContext.uuid = 'user_id';
		List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        pageRef.getParameters().put('state','slack');
        pageRef.getParameters().put('alert', '{"message":"Connected to Slack succesfully","type":"success","translationCode":"my_settings.apps.connection.success","serviceName":"Slack"}');
        Test.startTest();
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectExternalApp/slack', false));
        connectExternalAppCtrlObj.saveAppDetails();	
        Test.stopTest();
        List<People_Integration__c> peopleIntegrationList = [SELECT Id FROM People_Integration__c WHERE name = 'slack' and Connected__c = true];
        System.assertEquals(1, peopleIntegrationList.size(), 'Slack connected');	
	}
    
    @isTest static void testSlackUnfurlPhaseTwo() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
		TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK,appIntegList[0].id);
        pageRef.getParameters().put('state','slackUnfurl');
        pageRef.getParameters().put('alert', '{"message":"Connected to Slack succesfully","type":"success","translationCode":"my_settings.apps.connection.success","serviceName":"Slack"}');
        Test.startTest();
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectExternalApp/slack', false));
        connectExternalAppCtrlObj.saveAppDetails();	
        Test.stopTest();
        List<People_Integration__c> peopleIntegrationList = [SELECT Id FROM People_Integration__c WHERE name = 'slack' and Connected__c = true];
        System.assertEquals(1, peopleIntegrationList.size(), 'Slack connected');	
	}


	@isTest
	static void testADDomainMismatch() {

		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		pageRef.getParameters().put('state','activedirectoryadmin');
		pageRef.getParameters().put('displayName','testUserName');
		pageRef.getParameters().put('externalId','12345678');
		pageRef.getParameters().put('email','test@gmail.com');
		pageRef.getParameters().put('error_code','domain_or_account_mismatch');
		pageRef.getParameters().put('isSuccess','true');
		Test.startTest();	
		Test.setCurrentPage(pageRef);
		connectExternalAppCtrlObj.saveAppDetails();	
		Test.stopTest();	
		List<App_Integration__c> appIntegrationList = [SELECT Id FROM App_Integration__c WHERE name = 'activedirectory' and Connected__c = true];
		System.assertEquals(0, appIntegrationList.size(), 'Size should have been 0');		
	}

	@isTest
	static void testConnectOutlookCalendarSuccess() {

		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		pageRef.getParameters().put('state', 'outlookcalendar');
		pageRef.getParameters().put('alert', '{"message":"Connected to Outlook successfully","type":"success","translationCode":"my_settings.apps.connection.success","serviceName":"Outlook"}');
		Test.startTest();
		Test.setCurrentPage(pageRef);
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/connectExternalApp/outlookCalendar', false));
		connectExternalAppCtrlObj.saveAppDetails();	
		Test.stopTest();
		List<People_Integration__c> peopleIntegrationList = [SELECT Id FROM People_Integration__c WHERE name = 'outlookcalendar' and Connected__c = true];
		System.assertEquals(1, peopleIntegrationList.size(), 'Size should have been 1');		
	}

	@isTest
	static void testConnectOutlookCalendarDomainMismatch() {
		init();
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		pageRef.getParameters().put('state', 'outlookcalendar');
		pageRef.getParameters().put('alert', '{"message":"Domain Mismatch","type":"danger","translationCode":"apps.connection.outlook.setup_domain_mismatch"}');
		Test.startTest();
		Test.setCurrentPage(pageRef);
		connectExternalAppCtrlObj.saveAppDetails();	
		Test.stopTest();
		List<People_Integration__c> peopleIntegrationList = [SELECT Id FROM People_Integration__c WHERE name = 'outlookcalendar' and Connected__c = true];
		System.assertEquals(0, peopleIntegrationList.size(), 'Size should have been 0');			
	}

	@isTest static void testGoogleCalendarErrorSingleDomain() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','googlecalendar');
		pageRef.getParameters().put('error_code','not_a_gsuite_account');
		App_Config__c appConfig = [SELECT Id, Google_Multi_Domain_Upgrade_Status__c FROM App_Config__c LIMIT 1];
		appConfig.Google_Multi_Domain_Upgrade_Status__c = ServiceConstants.UPGRADE_STATUS_NOT_STARTED_YET;
		update appConfig;
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}

	@isTest static void testGoogleCalendarErrorMultiDomain() {
		Test.startTest();
		init();
		pageRef.getParameters().put('state','googlecalendar');
		pageRef.getParameters().put('error_code','not_a_gsuite_account');
		App_Config__c appConfig = [SELECT Id, Google_Multi_Domain_Upgrade_Status__c FROM App_Config__c LIMIT 1];
		appConfig.Google_Multi_Domain_Upgrade_Status__c = ServiceConstants.UPGRADE_STATUS_COMPLETED;
		update appConfig;
		Test.setCurrentPage(pageRef);	
		ConnectExternalAppCtrl connectExternalAppCtrlObj = new ConnectExternalAppCtrl();
		connectExternalAppCtrlObj.saveAppDetails();
		Test.stopTest();
		
		System.assert(true,'Running as expected');
	}
	
}