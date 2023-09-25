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
private class RestAPIDataConsumerTest { 

    @testSetup static void setup() {
        TestHelper.setupAppConfig();
        TestHelper.createUser('TestUser_TileServiceTest',null,false);
        String currentUserId = UserContext.id;
        TestHelper.createPeopleRecordForUser(currentUserId);
        People__c peopleObj = [select id, Mobile_Token_iOS__c,Mobile_Token_Android__c from people__c where user__c=:currentUserId limit 1];
        if(peopleObj != null){
			peopleObj.Mobile_Token_iOS__c = 'ios'; 
			peopleObj.Mobile_Token_Android__c = 'android';
			update peopleObj;       	
        }
        TestHelper.createCollaborationGroup('Test_Group1_TileServiceTest','Public');
         
    }
    
    
    @isTest static void testHandleRequest() {
        setMobileToken();
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('object','tokenupdate');
        ApexPages.currentPage().getParameters().put('type', 'ios');
        ApexPages.currentPage().getParameters().put('token', 'tkI_VL79XkEN8PoIVbcPydT7rMZECKh2s2oolAx');
    	RestAPIDataConsumer restDataServerObj = new RestAPIDataConsumer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleRequest1() {
        setMobileToken();
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('object','tokenupdate');
        ApexPages.currentPage().getParameters().put('type', 'android');
        ApexPages.currentPage().getParameters().put('token', 'tk_VL79XkEN8Pp7IVbcPydT7rMZECKh2s2oolAx');
    	RestAPIDataConsumer restDataServerObj = new RestAPIDataConsumer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleRequest2() {
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('object','Invalid');
        ApexPages.currentPage().getParameters().put('type', 'type');
        ApexPages.currentPage().getParameters().put('token', 'ios');
    	RestAPIDataConsumer restDataServerObj = new RestAPIDataConsumer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleRequest3() {
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('objectInvalid','Invalid');
        ApexPages.currentPage().getParameters().put('type', 'type');
        ApexPages.currentPage().getParameters().put('token', 'ios');
    	RestAPIDataConsumer restDataServerObj = new RestAPIDataConsumer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }

     @isTest static void testHandleRequest4() {
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','RestAPIDataServer');
        pageRef.getParameters().put('object','clearToken');
        pageRef.getParameters().put('type', 'android');
        Test.setCurrentPage(pageRef);
    	RestAPIDataConsumer restDataServerObj = new RestAPIDataConsumer();
    	restDataServerObj.handleRequest();
        pageRef.getParameters().put('type', 'ios');         
        Test.setCurrentPage(pageRef);
        restDataServerObj = new RestAPIDataConsumer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }

    private static void setMobileToken() {
        People__c peopleObj = [select id from People__c where last_name__c='TestUser_TileServiceTest'];
        peopleObj.Mobile_Token_Android__c = 'tk_VL79XkEN8Pp7IVbcPydT7rMZECKh2s2oolAx';
    	peopleObj.Mobile_Token_IOS__c = 'tkI_VL79XkEN8PoIVbcPydT7rMZECKh2s2oolAx';
        update peopleObj;
    }
    
}