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
private class UtilityDataServerTest {

    private static App_Config__c appConfigRecord;
    private static PageReference pageRef;
	 @testSetup static void setup() {
        appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Enterprise_Search_Enabled__c = true;
        appConfigRecord.Box_User_Id__c = '001';
        appConfigRecord.Custom_Links_JSON__c = '[{"url":"www.google.com","onOff":true,"name":"xyz","itemOrder":"0"}]';
      	update appConfigRecord;
         
        People__c pObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        pObj.City__c = 'Delhi';
        pObj.State__c = 'Delhi';
        pObj.Country__c = 'India';
        update pObj;

        People_Preference__c prefObj = TestHelper.createPeoplePreference(UserContext.peopleId);
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW, IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS});
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'gdrive', 'dropbox', 'sharepoint', 'onedrive'});
        List<App_Integration__c> appIntegrationObjList = TestHelper.createAppIntegrationRecords(true, new Set<String>{'twitter', 'facebook', 'linkedin','microsoftteams'});
        List<People_Integration__c> peopleIntegrationObjList = TestHelper.createPeopleIntegrationRecords(appIntList, UserContext.peopleId, 'asdadasd');
        TestHelper.createPeopleIntegrationRecords(appIntegrationObjList, UserContext.peopleId, 'asdadasd');
        ContentVersion conVersionObj =  TestHelper.createContentVersion('C');
        Audit_Trail__c auditTrailObj = new Audit_Trail__c();
        auditTrailObj.Object_Name__c = 'App_Config__c';
        auditTrailObj.Column_Name__c = 'Branding__c';
		insert auditTrailObj;
        Help_Text__c textObj = new Help_Text__c();
        textObj.Type__c = 'Task';
        insert textObj;
        Help_Text_View__c textViewObj = new Help_Text_View__c();
        textViewObj.Help_Text__c = textObj.id;
     	textViewObj.Is_Deleted__c = false;
		textViewObj.People__c= UserContext.peopleId;
        insert textViewObj;  

        textObj = new Help_Text__c();
        textObj.Type__c = 'error';
        textObj.Task_Id__c = 'test-help-text';
        insert textObj;
        textViewObj = new Help_Text_View__c();
        textViewObj.Help_Text__c = textObj.id;
     	textViewObj.Is_Deleted__c = false;
		textViewObj.People__c= UserContext.peopleId;
        insert textViewObj;          
        
        App_Feature__c appFeatureObj=new App_Feature__c();
        appFeatureObj.AI_Topic_Suggestion_Enabled__c=true;
        insert appFeatureObj;
    }

    private static void init() {
        pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'UtilityDataServer');
        Test.setCurrentPage(pageRef);
    }

    @isTest static void testMiscellaneous() {
    	PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('target', 'UtilityDataServer');
        ApexPages.currentPage().getParameters().put('values', '{"general_primaryColor":"6a31c5","general_primaryDarkModeColor":"1EA0E6","general_backgroundColor":"62af89","general_backgroundImagePosition":"left top","logo_faviconPath":"https://c.na34.visual.force.com/resource/1449828000000/Logo1","font_font":"/dist/font.min.css","header_preset":"custom","header_backgroundColor":"cc2d2d","header_iconColor":"c5c5c5","navigation_preset":"custom","navigation_backgroundColor":"ffffff","navigation_linkColor":"23221f","navigation_linkSelectedColor":"2343b2","navigation_linkBackgroundHover":"821fb2","footer_preset":"dark","footer_backgroundColor":"ffffff","footer_textColor":"858585","general_backgroundImage":null,"logo_logo":{"id":"01561000000G8RUAA0","thumbnailImg":"/servlet/servlet.ImageServer?id=01561000000G8RUAA0&oid=00D61000000CKLyEAO&lastMod=1453270588376","provider":"simpplr"}}');
        ApexPages.currentPage().getParameters().put('css', 'url(/servlet');
        ApexPages.currentPage().getParameters().put('text', 'UtilityDataServerTest');
        ApexPages.currentPage().getParameters().put('className', 'pppppppppp');
    	UtilityDataServer uds = new UtilityDataServer();
    	uds.getBrandingCss();
    	uds.saveCustomizationValues();
    	uds.sendFeedBackEmail('{"feedbackMsg" : "test msg", "pageUrl" : "www.google.com", "pageTitle" : "test title", "helpTopic":"ask_question"}');
    	uds.getPageFeature();
       
    	ApexPages.currentPage().getParameters().put('action', 'getBrandingCSS');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        

        
    	ApexPages.currentPage().getParameters().put('action', 'getValues');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
    	ApexPages.currentPage().getParameters().put('action', 'saveCustomizations');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
    	
    	ApexPages.currentPage().getParameters().put('action', 'refreshCustomizations');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
    	
    	ApexPages.currentPage().getParameters().put('action', 'getSalesforceBaseUrl');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        ApexPages.currentPage().getParameters().put('action', 'getCustomFontCSS');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        SimpplrContext.enableGoogleAnalytics4 = true;
        SimpplrContext.isGAEnabled = true;
        ApexPages.currentPage().getParameters().put('action', 'getAppConfig');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);

        ApexPages.currentPage().getParameters().put('action', 'getCurrentUserSettings');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
    	
        ApexPages.currentPage().getParameters().put('action', 'getProfileFields');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        ApexPages.currentPage().getParameters().put('action', 'getDRI');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        ApexPages.currentPage().getParameters().put('action', 'getSecurityToken');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        ApexPages.currentPage().getParameters().put('action', 'getFromAddresses');
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        setTestGetTopicSuggestionsForText();
        ApexPages.currentPage().getParameters().put('action', 'suggestTopics');
        ApexPages.currentPage().getParameters().put('data', '{"text":"UtilityDataServerTest"}');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);

    	ApexPages.currentPage().getParameters().put('action', '');
    	uds.handleRequest();
        System.assertEquals('error', uds.response.status, uds.response.message);
        
    }

  	@isTest	static void testSendFeedBackEmail(){
        PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('target', 'UtilityDataServer');
		UtilityDataServer uds = new UtilityDataServer();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/NPS',false));
    	ApexPages.currentPage().getParameters().put('action', 'sendFeedBackEmail');
        ApexPages.currentPage().getParameters().put('data','{"feedbackMsg":"feedback","pageTitle":"ABCD","pageUrl":"https://ABCD.com","toEmail":"abc@abc.com","helpTopics":"XYZ"}');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        Test.stopTest();
    }
    
    private static void setTestGetTopicSuggestionsForText() {
        ConnectApi.TopicSuggestionPage tsp = new ConnectApi.TopicSuggestionPage();
        List<ConnectApi.TopicSuggestion> tsList = new List<ConnectApi.TopicSuggestion>();
        ConnectApi.TopicSuggestion ts = new ConnectApi.TopicSuggestion();
        ts.name = 'UtilityDataServerTest';
        tsList.add(ts);
        tsp.topicSuggestions = tsList;
		ConnectApi.Topics.setTestGetTopicSuggestionsForText(null, 'UtilityDataServerTest', 25, tsp);
    }

    @isTest static void testGetAppHomeDefaultLayout() {
        App_Default__c appDefaultObj = new App_Default__c(Type__c = 'home-default');
        appDefaultObj.Layout__c = 'd';
        insert appDefaultObj;
    	UtilityDataServer uds = new UtilityDataServer();

        Test.startTest();
    	    uds.getAppHomeDefaultLayout();
        Test.stopTest();
        System.assertEquals('success', uds.response.status, uds.response.message);

    }
    
    @isTest static void testGetProfileFields() {
        App_Config__c appConfigObj = TestHelper.getAppConfig();
        appConfigObj.PDS_Source_Application__c = 'None';
        appConfigObj.PP_Video_Provider__c = 'Skype';
        update appConfigObj;
    	PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('target', 'UtilityDataServer');
    	UtilityDataServer uds = new UtilityDataServer();
        
        ApexPages.currentPage().getParameters().put('action', 'getProfileFields');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
    }
    
    @isTest static void testActions() {
        Test.startTest();
        SimpplrContext.isSegmentsEnabled = true;
        SimpplrContext.isSegmentBrandingEnabled = true;
        People__c peopleObj = [SELECT Id From People__c LIMIT 1];
        Segment__c segmentRec = TestHelper.createSegment(peopleObj.Id);
        UserContext.segmentId = segmentRec.Id;
    	PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('target', 'UtilityDataServer');
        ApexPages.currentPage().getParameters().put('values', '{"general_primaryColor":"6a31c5","general_primaryDarkModeColor":"1EA0E6","general_backgroundColor":"62af89","general_backgroundImagePosition":"left top","logo_faviconPath":"https://c.na34.visual.force.com/resource/1449828000000/Logo1","font_font":"/dist/font.min.css","header_preset":"custom","header_backgroundColor":"cc2d2d","header_iconColor":"c5c5c5","navigation_preset":"custom","navigation_backgroundColor":"ffffff","navigation_linkColor":"23221f","navigation_linkSelectedColor":"2343b2","navigation_linkBackgroundHover":"821fb2","footer_preset":"dark","footer_backgroundColor":"ffffff","footer_textColor":"858585","general_backgroundImage":null,"logo_logo":{"id":"01561000000G8RUAA0","thumbnailImg":"/servlet/servlet.ImageServer?id=01561000000G8RUAA0&oid=00D61000000CKLyEAO&lastMod=1453270588376","provider":"simpplr"}}');
        ApexPages.currentPage().getParameters().put('css', 'url(/servlet');
        ApexPages.currentPage().getParameters().put('className', 'pppppppppp');
    	UtilityDataServer uds = new UtilityDataServer();
    	uds.getBrandingCss();
    	uds.saveCustomizationValues();
    	uds.sendFeedBackEmail('{"feedbackMsg" : "test msg", "pageUrl" : "www.google.com", "pageTitle" : "test title","emailProductResearch":false}');
    	uds.getPageFeature();
        	
    	ApexPages.currentPage().getParameters().put('action', 'getValues');
        ApexPages.currentPage().getParameters().put('segmentId',segmentRec.Id);
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        ApexPages.currentPage().getParameters().put('action', 'saveCustomizations');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        ApexPages.currentPage().getParameters().put('action', 'getBrandingCSS');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        ApexPages.currentPage().getParameters().put('action', 'getCustomFontCSS');
    	uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);

        Test.stopTest();
    }

    @isTest static void testActions2() {   

        Analytics_Top_Content__c topContentObj = new Analytics_Top_Content__c();
        User adminUserObj = TestHelper.createUser('AllContentDataServerTest_Simpplr_admin', null, true);
        CollaborationGroup priCollabGrp = new CollaborationGroup ();
		priCollabGrp = TestHelper.createCollaborationGroup('AllContent_Grp', 'Public');
		List<Simpplr_Site__c> listOfSitePublic = [select id, Name, Chatter_Group_Id__c FROM 
		      Simpplr_Site__c  WHERE Chatter_Group_Id__c=:priCollabGrp.id limit 1];
        Simpplr_Content__c conObj =  TestHelper.createContent( 'title',  'Page',  'knowledge',  'Approved',  adminUserObj,  DateTime.Now(), DateTime.Now().addDays(2),  listOfSitePublic[0]);
        conObj.Is_Deleted__c = false;
        update conObj;
        topContentObj.Content__c = conObj.id;
        topContentObj.Date__c = date.today();
        insert topContentObj;
        
        PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('target', 'UtilityDataServer');
        ApexPages.currentPage().getParameters().put('values', '{"general_primaryColor":"6a31c5","general_primaryDarkModeColor":"1EA0E6","general_backgroundColor":"62af89","general_backgroundImagePosition":"left top","logo_faviconPath":"https://c.na34.visual.force.com/resource/1449828000000/Logo1","font_font":"/dist/font.min.css","header_preset":"custom","header_backgroundColor":"cc2d2d","header_iconColor":"c5c5c5","navigation_preset":"custom","navigation_backgroundColor":"ffffff","navigation_linkColor":"23221f","navigation_linkSelectedColor":"2343b2","navigation_linkBackgroundHover":"821fb2","footer_preset":"dark","footer_backgroundColor":"ffffff","footer_textColor":"858585","general_backgroundImage":null,"logo_logo":{"id":"01561000000G8RUAA0","thumbnailImg":"/servlet/servlet.ImageServer?id=01561000000G8RUAA0&oid=00D61000000CKLyEAO&lastMod=1453270588376","provider":"simpplr"}}');
        ApexPages.currentPage().getParameters().put('css', 'url(/servlet');
        ApexPages.currentPage().getParameters().put('className', 'pppppppppp');
    	UtilityDataServer uds = new UtilityDataServer();

        Test.startTest();
        ApexPages.currentPage().getParameters().put('action', 'getAppConfig');
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);

        ApexPages.currentPage().getParameters().put('action', 'getDeferredAppConfig');
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        conObj = TestHelper.createContent('Developer','Event', 'Approved', adminUserObj, listOfSitePublic[0]);
        topContentObj.Content__c = conObj.id;
        update topContentObj;
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        conObj = TestHelper.createContent('Developer','Album', 'Approved', adminUserObj, listOfSitePublic[0]);
        topContentObj.Content__c = conObj.id;
        update topContentObj;
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        conObj = TestHelper.createContent('Developer','BlogPost', 'Approved', adminUserObj, listOfSitePublic[0]);
        topContentObj.Content__c = conObj.id;
        update topContentObj;
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);

        ApexPages.currentPage().getParameters().put('action', 'getSchedulingSlots');    
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        
        Test.stopTest();
        
    }

    @isTest static void testOembed() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'oembed',false));
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        init();
        pageRef.getParameters().put('action', 'oembed');
        pageRef.getParameters().put('data', '{"key1":"value1","key2":"value2"}');
        UtilityDataServer uds = new UtilityDataServer();
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        Test.stopTest();
    }

    @isTest
    static void deleteDismissibleFlashesTest() {
        Test.startTest();
        init();
        pageRef.getParameters().put('action', 'deleteDismissibleFlashes');
        pageRef.getParameters().put('data', '{"dismissibleFlashes":[{"type":"error","name":"test-help-text"}]}');
        UtilityDataServer uds = new UtilityDataServer();
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        Test.stopTest();     
        List<Help_Text_View__c> helptextViewList = [SELECT Id from Help_Text_View__c
                                                    WHERE is_deleted__c = FALSE
                                                    AND Help_Text__r.Task_Id__c = 'test-help-text'
                                                    AND Help_Text__r.Type__c IN: ServiceConstants.DISMISSIBLE_FLASHES_TASK_TYPE_MAP.values()];
        System.assertEquals(0, helptextViewList.size(), 'FAILED - size should be zero');                                                     
    }

    @isTest
    static void getJWTTokenTest() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'getJWTToken',false));
        pageRef.getParameters().put('action', 'getJWTToken');
        UtilityDataServer uds = new UtilityDataServer();
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, 'error occured');
        Test.stopTest();                                              
    }
    
    @isTest
    static void getSSJWTTokenTest() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'getSSJWTToken',false));
        pageRef.getParameters().put('action', 'getSSJWTToken');
        UtilityDataServer uds = new UtilityDataServer();
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, 'error occured');
        Test.stopTest();                                              
    }

    @isTest
    static void getListenerSuiteJwtTest() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'getJWTToken',false));
        pageRef.getParameters().put('action', 'getListenerSuiteJwt');
        UtilityDataServer uds = new UtilityDataServer();
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, 'error occured');
        Test.stopTest();                                              
    }

    @isTest
    static void platformCacheUpdateRecordTest() {
        Test.startTest();
        init();
        List<App_Integration__c> appIntegrationObjList = TestHelper.createAppIntegrationRecords(true, new Set<String>{'twitterTest'});
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'gdrive', 'dropbox', 'sharepoint', 'onedrive'});
        appIntegrationObjList[0].User_Name__c = 'newAppIntegUser';
        update appIntegrationObjList[0];
        List<App_Integration__c> listOfAppInteg = [SELECT id, name, User_Name__c 
                FROM App_Integration__c 
                WHERE name ='twitterTest' limit 1];
        System.assertEquals('newAppIntegUser', listOfAppInteg[0].User_Name__c, 'Username values not matched');
        Test.stopTest();                                              
    }
    @isTest
    static void getAvailableTimezonesTest() {
        Test.startTest();
        init();
        pageRef.getParameters().put('action', 'getAvailableTimezones');
        UtilityDataServer uds = new UtilityDataServer();
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        Test.stopTest();                                              
    }

    @isTest
    static void validateClearCacheTest() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'getJWTToken',false));
        String partitionName = 'Local.Cache';
        if(!String.isBlank(SimpplrContext.namespacePrefix)){
            partitionName = 'Simpplr.Cache';
        }
        String platformCacheTestkey = partitionName+'.testingkey';
        Cache.Org.put(platformCacheTestkey, 'testing value');

        System.assertEquals('testing value', Cache.Org.get(platformCacheTestkey), 'failed');
        pageRef.getParameters().put('action', 'resetCache');
        UtilityDataServer uds = new UtilityDataServer();
        uds.handleRequest();
        System.assertEquals(null, Cache.Org.get(platformCacheTestkey), 'failed');
        Test.stopTest();                                              
    }

    @isTest
    static void resetCDCRetryCountTest() {
        Test.startTest();
        init();
        pageRef.getParameters().put('action', 'resetCDCRetryCount');
        UtilityDataServer uds = new UtilityDataServer();
        uds.handleRequest();
        System.assertEquals('success', uds.response.status, uds.response.message);
        Test.stopTest();                                              
    }
}