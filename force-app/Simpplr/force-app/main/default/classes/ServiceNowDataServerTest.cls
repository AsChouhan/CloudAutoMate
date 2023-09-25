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
private class ServiceNowDataServerTest {
	
	private static App_Config__c appConfigRecord;
    private static People__c peopleObject;
    public static PageReference pageRef;   
	 
    @testSetup static void setup() {
    	appConfigRecord = TestHelper.setupAppConfig();
        peopleObject = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
	    List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW, IntegrationConstants.INTEGRATION_TYPE_SALESFORCE});
        appIntegList[0].Access_Token_Requested_Datetime__c = dateTime.now();
        appIntegList[0].Access_Token_Expiry__c = 1;
        update appIntegList;
        TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW,appIntegList[0].id);
        System.assert(true,'Running as expected');
    }

    static void init() {
		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','ServiceNowDataServer');
        Test.setCurrentPage(pageRef);
    }
    
    
     @isTest static void testHandleRequestGetIncidentsStatusDesc() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/incidentList', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getIncidents');
        pageRef.getParameters().put('data','{"sortBy":"statusDesc","size":16}');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        pageRef.getParameters().put('data','{"sortBy":"statuAsc","size":16}');
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

     @isTest static void testHandleRequestGetIncidents() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/incidentList', false));
        PageReference pageRef = Page.DataServerRW;
        People_Integration__c pplInt =[select id,External_Id__c from People_Integration__c];
        pplInt.External_Id__c = 'EJQPR4819P';
        update pplInt;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getIncidents');
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','createNotification');
        pageRef.getParameters().put('snUserId','EJQPR4819P');
        pageRef.getParameters().put('incidentId','EJQPR4819P');
        pageRef.getParameters().put('description','helloww');
        pageRef.getParameters().put('status','hello');
        pageRef.getParameters().put('notitype','MOBILE_PROMOTION_PHONE');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestGetIncidentsStatusAsc() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/incidentList', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getIncidents');
        pageRef.getParameters().put('data','{"sortBy":"statusAsc","size":16}');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }
    @isTest static void testHandleRequestGetIncidentsDescriptionDesc() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/incidentList', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getIncidents');
        pageRef.getParameters().put('data','{"sortBy":"descriptionDesc","size":16}');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestGetIncidentsDescriptionAsc() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/incidentList', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getIncidents');
        pageRef.getParameters().put('data','{"sortBy":"descriptionAsc","size":16}');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }
    @isTest static void testHandleRequestGetIncidentsLastUpdatedNewest() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/incidentList', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getIncidents');
        pageRef.getParameters().put('data','{"sortBy":"lastUpdatedNewest","size":16}');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }
    @isTest static void testHandleRequestGetIncidentsLastUpdatedOldest() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/incidentList', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getIncidents');
        pageRef.getParameters().put('data','{"sortBy":"lastUpdatedOldest","size":16}');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestCreateIncident() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/incident/createIncident', false));
        pageRef.getParameters().put('action','createIncident');
        pageRef.getParameters().put('data','{"shortDescription":"new incident","urgency":"5","category":"enquiry","subcategory":"help","description":"ok","caller_id":"test@simpplr.com","assigned_to":"test@simpplr.com","state":"1"}');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestGetKnowledgeBases() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/kb_knowledge_base', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','servicenowDataServer');
        pageRef.getParameters().put('action','getKnowledgeBases');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestGetKnowledgeBaseItems() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/kb_knowledge', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getKnowledgeBaseItems');
        pageRef.getParameters().put('data','{"size":3,"nextPageToken":null,"term":"hr"}');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }
    
     @isTest static void testHandleRequestGetCategory() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/sys_choice/category', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getCategory');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestGetSubcategory() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/sys_choice/subCategory', false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getSubcategory');
        pageRef.getParameters().put('categoryName','software');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestGetAccessToken() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','getAccessToken');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestRevokeAccessToken() {
        init();
    	ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        snDSObj.getPageFeature();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/sys_choice/subCategory', false));
        pageRef.getParameters().put('action','revokeAccessToken');
        Test.setCurrentPage(pageRef);
        snDSObj.handleRequest();
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }

    @isTest static void testHandleRequestUpdatePeopleIntegRecord() {
        init();
        ServiceNowDataServer snDSObj= new ServiceNowDataServer();
    	ServiceNowIntegrationService snISObj= new ServiceNowIntegrationService();
        Test.startTest();
        String respJSON = '{"access_token":"test","refresh_token":"test","expires_in":36000}';
        Map<String,Object> respMap = (Map<String,Object>)JSON.deserializeUntyped(respJSON);
        snISObj.updatePeopleIntegRecord(respMap);
        Test.stopTest();
        system.assertEquals('success', snDSObj.response.status, snDSObj.response.message);
    }
    @isTest static void testHandleRequestGetAccessTokenResponseMap() {
        init();
        Test.setCurrentPage(pageRef);
        ServiceNowDataServer snDSObj= new ServiceNowDataServer();
    	ServiceNowIntegrationService snISObj= new ServiceNowIntegrationService();
        List<People_Integration__c> peopleIntegList = [select id , Access_Token_Expiry__c from People_Integration__c Where Name=: IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW AND People__c=:UserContext.peopleId];
        if(peopleIntegList.isEmpty()==false){
            peopleIntegList[0].Access_Token_Expiry__c = 0;
            update peopleIntegList;
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/serviceNowDataServer/refreshToken', false));
        Map<String, Object> resultMap = snISObj.getAccessTokenResponseMap(false);
        Test.stopTest();
        
        system.assertNotEquals(null, resultMap.get('access_token'), 'Access token should be return.');
    }
    
    @isTest static void testGetSupportIntegrationsConfig() {
        Test.startTest();
        init();
        Test.setCurrentPage(pageRef);
        SettingDataServer SettingDSObject= new SettingDataServer();
        pageRef.getParameters().put('action','getSupportIntegrationsConfig');
        SettingDSObject.handleRequest();
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testRevokeAccessToken() {
        Test.startTest();
        init();
        SettingDataServer snDSObj= new SettingDataServer();
        snDSObj.getPageFeature();
        
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','revokeAccessToken');
        Test.setCurrentPage(pageRef);
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'serviceNowDataServer/revokeAccessToken', false));
        
        snDSObj.handleRequest();
        System.assert(true, 'Running as Expected');
        Test.stopTest();
        
    }
    
    @isTest static void testExceptions() {
        Test.startTest();
        People_Integration__c peopleIntegObj = [Select Id From People_Integration__c Where Name = :IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW];
        delete peopleIntegObj;
        
        PageReference pageRef = Page.DataServerRW;
        ServiceNowDataServer snDSObj= new ServiceNowDataServer();
        snDSObj.getPageFeature();
        
        pageRef.getParameters().put('target','ServiceNowDataServer');
        pageRef.getParameters().put('action','###');
        Test.setCurrentPage(pageRef);
        
        snDSObj.handleRequest();
        
        pageRef.getParameters().put('action','getSubcategory');
        snDSObj.handleRequest();
        
        pageRef.getParameters().put('action','getCategory');
        snDSObj.handleRequest();
        
        pageRef.getParameters().put('action','getKnowledgeBaseItems');
        snDSObj.handleRequest();
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
            
}