@isTest 
private class AtlassianDataServerTest {
    static App_Config__c appConfig;
    static People__c currentUserPeopleObj; 
    
    @testSetup static void setup() {
        appConfig = TestHelper.setupAppConfig();
        People__c peopleRecord = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        
        List<App_Integration__c> appIntegList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'atlassian'});
        List<People_Integration__c> peopleIntegList = TestHelper.createPeopleIntegrationRecords(appIntegList, UserContext.peopleId, 'atlassian');
    }
    
    private static void init() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AtlassianDataServer');
        Test.setCurrentPage(pageRef);
    }
    
    @isTest 
    static void testGetSupportIntegrationsConfig() {
        AtlassianService atService = new AtlassianService();
        
        AtlassianWrapper atlassianIntegrationWrapperObj = new AtlassianWrapper();
        atlassianIntegrationWrapperObj = atService.getSupportIntegrationsConfig();
        System.assertEquals(true, atlassianIntegrationWrapperObj.atlassianEnabled, 'Running as expected');
    }
    
    @isTest static void testGetConfluenceSpaces() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/AtlassianService/getConfluenceSpaces',false));
        init();
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AtlassianDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('data','{"domain":"https://simpplr.atlassian.net","nextPageToken":null}');
        pageRef.getParameters().put('action','getConfluenceSpaces');
        
        AtlassianDataServer atlassianDSObject= new AtlassianDataServer();
        AtlassianDSObject.handleRequest();
        
        System.assertEquals('getConfluenceSpaces', pageRef.getParameters().get('action'), 'Running as expected');

        ResponseWrapper response = AtlassianDSObject.getConfluenceSpaces(pageRef.getParameters().get('data'));
        System.assertEquals('success', response.status, 'Running as expected');
        
        Test.stopTest();
    }
    
    @isTest static void testSearchConfluence() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/AtlassianService/searchConfluence',false));
        init();
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AtlassianDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('data','{"section":"Confluence","term":"user","searchSite":false,"isCorrectionEnabled":true,"space":{"id":"SWPRJ","name":"Demo Project Home"},"type":"page","lastModified":"past_year","size":16}');
        pageRef.getParameters().put('action','searchConfluence');
        
        AtlassianDataServer atlassianDSObject= new AtlassianDataServer();
        AtlassianDSObject.handleRequest();

        System.assertEquals('searchConfluence', pageRef.getParameters().get('action'), 'Running as expected');

        ResponseWrapper response = AtlassianDSObject.searchConfluence(pageRef.getParameters().get('data'));

        System.assertEquals('success', response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testSearchConfluenceFail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/AtlassianService/searchConfluenceFail',null , false));
        init();
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AtlassianDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('data','{"section":"Confluence","term":"user","searchSite":false,"isCorrectionEnabled":true,"space":{"id":"SWPRJ","name":"Demo Project Home"},"type":"page","lastModified":"past_year","size":16}');
        pageRef.getParameters().put('action','searchConfluence');
        
        AtlassianDataServer atlassianDSObject= new AtlassianDataServer();
        AtlassianDSObject.handleRequest();

        ResponseWrapper response = AtlassianDSObject.searchConfluence(pageRef.getParameters().get('data'));

        System.assertEquals('error', response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void tesGetConfluenceUsers() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/AtlassianService/getConfluenceUsers',false));
        init();
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AtlassianDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('data','{"term":"test","size":999}');
        pageRef.getParameters().put('action','getConfluenceUsers');
        
        AtlassianDataServer atlassianDSObject= new AtlassianDataServer();
        AtlassianDSObject.handleRequest();

        System.assertEquals('getConfluenceUsers', pageRef.getParameters().get('action'), 'Running as expected');
        
        ResponseWrapper response = AtlassianDSObject.getConfluenceUsers(pageRef.getParameters().get('data'));

        System.assertEquals('success', response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void tesUpdateConnectedAtlassianUsers() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/AtlassianService/updateConnectedAtlassianUsers',false));
        init();
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AtlassianDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','updateIntegrationInfo');
        
        List<App_Integration__c> appRecordsList = null;
        List<People_Integration__c> peopleRecordsList = null;
        
        AtlassianDataServer atlassianDSObject= new AtlassianDataServer();
        pageRef.getParameters().put('data','[{\"accountId\":\"atlassiandummyexternalid\",\"userName\":\"abc\",\"userEmail\":\"updatedEmail@gmail.com\",\"isUpdate\":true}]');
        AtlassianDSObject.handleRequest();
        
        appRecordsList = [SELECT Id,External_id__c, Integration_Enabled__c, Is_Deleted__c, User_email__c, User_name__c FROM App_Integration__c WHERE External_id__c = 'atlassiandummyexternalid' AND Is_Deleted__c = false LIMIT 1];
		System.assertEquals('updatedEmail@gmail.com', appRecordsList[0].User_email__c, 'Running as expected');
        
        pageRef.getParameters().put('data','[{\"accountId\":\"atlassiandummyexternalid\",\"userName\":\"abc\",\"userEmail\":\"abff@gmail.com\",\"isUpdate\":false}]');
        AtlassianDSObject.handleRequest();
        
        appRecordsList = [SELECT Id,External_id__c, Integration_Enabled__c, Is_Deleted__c, User_email__c, User_name__c FROM App_Integration__c WHERE External_id__c = 'atlassiandummyexternalid' AND Is_Deleted__c = false LIMIT 1];
		System.assertEquals(0, appRecordsList.size(), 'Running as expected');
        
        pageRef.getParameters().put('data','[{\"accountId\":\"'+UserInfo.getUserId()+'\",\"userName\":\"abc\",\"userEmail\":\"newPeopleEmail@gmail.com\",\"isUpdate\":true}]');
        AtlassianDSObject.handleRequest();
        
        peopleRecordsList = [SELECT id, name, External_id__c, Is_Deleted__c, User_email__c, User_name__c  FROM People_Integration__c WHERE External_id__c = :UserInfo.getUserId() AND Is_Deleted__c = false LIMIT 1];
        System.assertEquals('newPeopleEmail@gmail.com', peopleRecordsList[0].User_email__c, 'Running as expected');

        pageRef.getParameters().put('data','[{\"accountId\":\"'+UserInfo.getUserId()+'\",\"userName\":\"abc\",\"userEmail\":\"abff@gmail.com\",\"isUpdate\":false}]');
        AtlassianDSObject.handleRequest();
        
        peopleRecordsList = [SELECT id, name, External_id__c, Is_Deleted__c, User_email__c, User_name__c  FROM People_Integration__c WHERE External_id__c = :UserInfo.getUserId() AND Is_Deleted__c = false LIMIT 1];
        System.assertEquals(0, peopleRecordsList.size(), 'Running as expected');

        ResponseWrapper response = AtlassianDSObject.updateIntegrationInfo(pageRef.getParameters().get('data'));
        
        System.assertEquals('success', response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest


    static void refreshTokenExpiredTest() {
        Test.startTest();
        init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AtlassianDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','updateIntegrationInfo');
        List<App_Integration__c> appRecordsList = null;
        List<People_Integration__c> peopleRecordsList = null;

        AtlassianDataServer atlassianDSObject= new AtlassianDataServer();
        pageRef.getParameters().put('data','[{\"accountId\":\"'+UserInfo.getUserId()+'\",\"userName\":\"abc\",\"userEmail\":\"abff@gmail.com\",\"isNotValidConnection\":true, \"isUpdate\":false}]');
        AtlassianDSObject.handleRequest();
        peopleRecordsList = [SELECT id, name, External_id__c, Is_Deleted__c, User_email__c, User_name__c  FROM People_Integration__c WHERE External_id__c = :UserInfo.getUserId()];
        System.assertEquals(0, peopleRecordsList.size(), 'SUCCESS - Size should be zero');
        pageRef.getParameters().put('data','[{\"accountId\":\"atlassiandummyexternalid\",\"userName\":\"abc\",\"userEmail\":\"abff@gmail.com\",\"isNotValidConnection\":true, \"isUpdate\":false}]');
        AtlassianDSObject.handleRequest();
        Test.stopTest();
        appRecordsList = [SELECT Id,External_id__c, Integration_Enabled__c, Is_Deleted__c, User_email__c, User_name__c FROM App_Integration__c WHERE External_id__c = 'atlassiandummyexternalid'];
        System.assertEquals(0, appRecordsList.size(), 'SUCCESS - Size should be zero');
    }     
}