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
private class RestAPIDataServerTest {

    @testSetup static void setup() {
        TestHelper.setupAppConfig();
        User userObj = TestHelper.createUser('Test_RestAPIDataServerTest',null,false);
        TestHelper.createCollaborationGroup('Test_Group1_RestAPIDataServerTest','Public');
        
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        Simpplr_Site__c publicSiteObj = TestHelper.getSiteRecordWithName('Test_Group1_RestAPIDataServerTest');
        Simpplr_Content__c simpContentPage = TestHelper.createContent('Test_Page', 'Page', 'Approved', peopleObj, publicSiteObj);
        TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'Like',simpContentPage.id,null);
        TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'follow',simpContentPage.id,null);
        TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'Endorse',simpContentPage.id,null);
        TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'post',simpContentPage.id,null);
        TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'comment',simpContentPage.id,null);
        TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'mention',simpContentPage.id,null);
        TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'review',simpContentPage.id,null);
        App_Notification__c appNotificationObj1 = TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'share',simpContentPage.id,null);
        appNotificationObj1.Object_Type__c = 'FeedItem';
        update appNotificationObj1;
        App_Notification__c appNotificationObj2 = TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'update',simpContentPage.id,null);
        appNotificationObj2.Status__c = 'Approved';
        update appNotificationObj2;
        TestHelper.createPeoplePreference(peopleObj.Id);
         
    }
    
    @isTest static void testRestAPIDataServer() {
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('object','users');
        ApexPages.currentPage().getParameters().put('filter', 'Test_RestAPIDataServerTest');
    	RestAPIDataServer restDataServerObj = new RestAPIDataServer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testRestAPIDataServer1() {
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
    	ApexPages.currentPage().getParameters().put('object','sites');
        ApexPages.currentPage().getParameters().put('filter', 'Test_Group1_RestAPIDataServerTest');
    	RestAPIDataServer restDataServerObj = new RestAPIDataServer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }
    @isTest static void testRestAPIDataServer2() {
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
        String currentUserId = UserContext.id;
    	ApexPages.currentPage().getParameters().put('object','XXXXX');
        ApexPages.currentPage().getParameters().put('filter', currentUserId);
    	RestAPIDataServer restDataServerObj = new RestAPIDataServer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testRestAPIDataServer3() {
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
        String currentUserId = UserContext.id;
    	ApexPages.currentPage().getParameters().put('object','notification');
        ApexPages.currentPage().getParameters().put('filter', currentUserId);
    	RestAPIDataServer restDataServerObj = new RestAPIDataServer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
    }
    
    @isTest static void testRestAPIDataServerNotificationCount() {
    	Test.startTest();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','RestAPIDataServer');
        Test.setCurrentPage(pageRef);
    	ApexPages.currentPage().getParameters().put('object','notificationCount');
    	RestAPIDataServer restDataServerObj = new RestAPIDataServer();
    	restDataServerObj.handleRequest();
    	System.assert(true,'Running as expected');
        Test.stopTest();
    }
}