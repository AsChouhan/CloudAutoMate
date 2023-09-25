@isTest 
private class LaunchpadDataServerTest {
	private static PageReference pageRef;
	private static App_Config__c appConfig;
	
	@testSetup  
	private static void setup() {
		appConfig = TestHelper.setupAppConfig();
	}
	private static void init() {
		pageRef = Page.DataServerRO;
		pageRef.getParameters().put('target', 'LaunchpadDataServer');
        Test.setCurrentPage(pageRef);
	}

	@isTest static void testGetPageFeature(){
		LaunchpadDataServer dsObject= new LaunchpadDataServer();
		String feature = dsObject.getPageFeature();
		System.assertEquals(AccessManager.FEATURE_SIMPPLR, feature, 'Should return SIMPPLR');
	}
    @istest static void testHandleRequestWhenActionNull() {
    	init();
    	LaunchpadDataServer dsObject= new LaunchpadDataServer();
    	pageRef = Page.DataServerRO;
		pageRef.getParameters().put('target', 'LaunchpadDataServer');
        pageRef.getParameters().put('action','');
        dsObject.handleRequest();
        System.assertEquals('error', dsObject.response.status, 'No action parameter, Should return error');
    }
	 @istest static void testHandleRequestWithWrongAction() {
    	init();
    	LaunchpadDataServer dsObject= new LaunchpadDataServer();
    	pageRef = Page.DataServerRO;
		pageRef.getParameters().put('target', 'LaunchpadDataServer');
        pageRef.getParameters().put('action','UnknownAction');
		pageRef.getParameters().put('data','{}');
		Test.setCurrentPage(pageRef);
        dsObject.handleRequest();
        System.assertEquals('error', dsObject.response.status, 'Unknown action param, Should return error');
    }
    
    @istest static void testHandleRequestWhenActionAvailable() {
    	init();

		appConfig = TestHelper.getAppConfig();
		appConfig.Custom_Links_JSON__c = '[{"url":"www.google.com","onOff":true,"name":"xyz","itemOrder":"0"},{"url":"www.googleqqq.com","onOff":true,"name":"abc","itemOrder":"1"},{"url":"","onOff":true,"name":"yahoo","itemOrder":"2"}]';
		TestHelper.updateAppConfigFields(appConfig);

		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		Segment__c segmentObj = TestHelper.createSegment(peopleObj.id);
		UserContext.getCurrentUserInfo.Segment__c = segmentObj.id;
		SimpplrContext.isSegmentsEnabled = true;
		SimpplrContext.isSegmentAppsNLinksEnabled = true;
		LaunchpadDataServer dsObject = new LaunchpadDataServer();
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data','{}');
		Test.setCurrentPage(pageRef);
        dsObject.handleRequest();
        
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
    }

    @istest static void testHandleRequestOKTA() {
		appConfig = TestHelper.getAppConfig();
		appConfig.SSO_Provider__c = 'okta';
		appConfig.Okta_Enabled__c = true;
		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		appConfig.Okta_API_Token__c = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, Blob.valueOf('dummy_token')));
		appConfig.Okta_Link__c = 'dummy_link_okta';
		TestHelper.updateAppConfigFields(appConfig);

        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success', 200, 'dummy_link_okta', false));
		Test.startTest(); 
        
		init();

		LaunchpadDataServer dsObject = new LaunchpadDataServer();
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data','{}');
		Test.setCurrentPage(pageRef);
        dsObject.handleRequest();

        Test.stopTest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
    }

	@istest static void testHandleRequestOKTA11() {
		init();

		appConfig = TestHelper.getAppConfig();
		appConfig.SSO_Provider__c = 'okta';
		appConfig.Okta_Enabled__c = true;
		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		appConfig.Okta_API_Token__c = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, Blob.valueOf('dummy_token')));
		appConfig.Okta_Link__c = 'dummy_link';
		appConfig.Okta_People_Name_Format__c = '11';
		TestHelper.updateAppConfigFields(appConfig);

		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success', 200, 'dummy_link_okta', false));

		Test.startTest();

		LaunchpadDataServer dsObject = new LaunchpadDataServer();
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data','{}');
		Test.setCurrentPage(pageRef);
        dsObject.handleRequest();
		Test.stopTest();
        
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
    }

	@istest static void testHandleRequestONELOGIN() {
		init();

		appConfig = TestHelper.getAppConfig();
		appConfig.SSO_Provider__c = 'onelogin';
		appConfig.OneLogin_Enabled__c = true;
		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		appConfig.OneLogin_API_Token__c = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, Blob.valueOf('dummy_token')));
		appConfig.OneLogin_Embedding_Token__c = 'dummy_embedd';
		appConfig.OneLogin_Link__c = 'dummy_link';

		TestHelper.updateAppConfigFields(appConfig);
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success', 200, 'dummy_link_okta', false));

		Test.startTest();
		LaunchpadDataServer dsObject = new LaunchpadDataServer();
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data','{}');
		Test.setCurrentPage(pageRef);
        dsObject.handleRequest();
		Test.stopTest();
        
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
    }

	@istest static void testHandleRequestCUSTOM() {
		init();

		appConfig = TestHelper.getAppConfig();
		appConfig.SSO_Provider__c = 'custom';

		TestHelper.updateAppConfigFields(appConfig);

		LaunchpadDataServer dsObject = new LaunchpadDataServer();
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data','{}');
		Test.setCurrentPage(pageRef);
        dsObject.handleRequest();
        
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
    }

	@istest static void testHandleRequestMICROSOFT() {
		appConfig = TestHelper.getAppConfig();
		appConfig.SSO_Provider__c = 'microsoft';
		appConfig.AD_Integration_Enabled__c = true;
		appConfig.OneLogin_API_Token__c = 'dummy_token';
		appConfig.OneLogin_Link__c = 'dummy_link';

		TestHelper.updateAppConfigFields(appConfig);
		TestHelper.setUpAppIntegrationADSI();

		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success', 200, 'dummy_link_okta', false));
		Test.startTest();
		init();

		LaunchpadDataServer dsObject = new LaunchpadDataServer();
        pageRef.getParameters().put('action', 'search');
        pageRef.getParameters().put('data','{}');
		Test.setCurrentPage(pageRef);
        dsObject.handleRequest();
		Test.stopTest();
        
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
    }

	@istest static void testToLaunchpadWrapper(){
    	init();

    	LaunchpadDataServer dsObject= new LaunchpadDataServer();

		Map<String, Object> dataObjMap = new Map<String, Object>();
		dataObjMap.put('displayName', 'dummy Name');
		dataObjMap.put('appId', 'dummy app id');
		dataObjMap.put('info', new Map<String, object>{
			'logoUrl' => 'dummyurl'
		});
		List<Object> listOfObj = new List<Object>();
		listOfObj.add(dataObjMap);
		Map<String, Object> appDetailsMap = new Map<String, Object>();
		appDetailsMap.put('value', listOfObj);	

    	List<LaunchpadDataServer.LaunchpadWrapper> result = dsObject.toLaunchpadWrapper(appDetailsMap);

    	System.assertNotEquals(0, result.size(), 'should return list');
    }

	@istest static void testCreateListOfLaunchpadApplications(){
    	init();

    	LaunchpadDataServer dsObject= new LaunchpadDataServer();

		List<Object> appDetails = new List<Object>();
		Map<String, Object> dataObjMap = new Map<String, Object>();
		dataObjMap.put('label', 'label');
		dataObjMap.put('logoUrl', 'logo url');
		dataObjMap.put('linkUrl', 'link url');

		appDetails.add(dataObjMap);

    	List<LaunchpadDataServer.LaunchpadWrapper> result = dsObject.createListOfLaunchpadApplications(appDetails);

    	System.assertNotEquals(0, result.size(), 'should return list');
    }

	@isTest static void testGetJsonResponseWithBasicAuth() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success', 200, 'launchpad/getRespBasicAuth', false));
        
		init();

    	LaunchpadDataServer dsObject= new LaunchpadDataServer();
		HTTPResponse result = dsObject.getJsonResponseWithBasicAuth('launchpad/getRespBasicAuth', 'dummyusername', 'dummypassword');

        Test.stopTest();
        System.assertNotEquals('', result.getBody(), 'Should contain response body');
     }
	
    @istest static void testConvertXmlToJsonString(){
    	init();
    	LaunchpadDataServer dsObject= new LaunchpadDataServer();
    	String xmlString= '<apps><app><id>494104</id><icon>https://s3.amazonaws.com/onelogin-assets/images/icons/square/ascendify/mobile_50.png?1434046407</icon><name>Ascendify</name><provisioned>0</provisioned><extension_required>false</extension_required><personal>false</personal><login_id>67033996</login_id></app><app><id>494105</id><icon>https://s3.amazonaws.com/onelogin-assets/images/icons/square/gartner/mobile_50.png?1427293613</icon><name>Gartner</name><provisioned>1</provisioned><extension_required>true</extension_required><personal>false</personal><login_id>67034020</login_id></app></apps>';
    	List<LaunchpadDataServer.LaunchpadWrapper> result = dsObject.convertXmlToListObject(xmlString);
    	System.assertNotEquals(0, result.size(), 'should return list');
    }

	@isTest static void testGetOktaLogin(){ 
		Test.startTest(); 
        
		init();

    	LaunchpadDataServer dsObject= new LaunchpadDataServer();
		String oktaUserName = dsObject.getOktaLogin();

        Test.stopTest();
        System.assertNotEquals('', oktaUserName, 'Should return okta user name');
	}

	@isTest static void testGetJsonResponse(){
		Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success', 200, 'launchpad/getRespBasicAuth', false));
        
		init();

    	LaunchpadDataServer dsObject= new LaunchpadDataServer();
		HTTPResponse result = dsObject.getJsonResponse('launchpad/getRespBasicAuth', 'dummyusername');

        Test.stopTest();
        System.assertNotEquals('', result.getBody(), 'Should contain response body');
	}

	@isTest static void testGetAllOneLoginApps(){
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success', 200, 'oneloginapps/get', false));
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		UserContext.getCurrentUserInfo.Email__c = peopleObj.Email__c;
		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		LaunchpadDataServer dsObject= new LaunchpadDataServer();
		Test.startTest();
		List<LaunchpadDataServer.LaunchpadWrapper> allAppsFromSSOProvider = dsObject.getAllOneLoginApps(EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, Blob.valueOf('dummy_token'))), 'dummy_embedd', 'dummy_link');
		Test.stopTest();
		System.assertNotEquals(true, allAppsFromSSOProvider.size()>0, 'Should return wrapper object list');
	}

	@isTest static void testGetAllOktaApps(){
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('success', 200, 'oktaapps/get', false));
		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		Test.startTest();
		LaunchpadDataServer dsObject= new LaunchpadDataServer();
		List<LaunchpadDataServer.LaunchpadWrapper> allAppsFromSSOProvider = dsObject.getAllOktaApps('oktaapps/get', EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, Blob.valueOf('dummy_token'))));
		Test.stopTest();
		System.assertNotEquals(true, allAppsFromSSOProvider.size()>0, 'Should return wrapper object list');
	}	
}