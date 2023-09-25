/**
 * This class contains unit tests for validating the behavior of Apex class FlagDataServerTest 
 */
@isTest
private class FlagDataServerTest {
	private static User adminUser;
	public static PageReference pageRef;
   
   	@testSetup
   	static void setup() {
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
		People__c peopleRecord = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
		People_Preference__c ppfRecord = TestHelper.createPeoplePreference(peopleRecord.Id);
		ppfRecord.Dismissed_Onboarding_Flags__c = 'item1,item2';
		update ppfRecord;
    }
    
    @isTest
    static void testGetPageFeature() {
        Test.startTest();
        init();
        FlagDataServer dsObject= new FlagDataServer();
        String resp = dsObject.getPageFeature();
        System.assertEquals('SIMPPLR', resp, 'Running as expected');
        Test.stopTest();
    }
    
    private static void init() {
        pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FlagDataServer');
       	Test.setCurrentpage(pageRef);
    }
    
    @isTest 
    static void testHandleRequestWhenActionNull() {
        Test.startTest();
        init();
        FlagDataServer dsObject= new FlagDataServer();  
        pageRef.getParameters().put('action','');
        dsObject.handleRequest();
        System.assertEquals('error', dsObject.response.status, 'Missing action parameter');
        Test.stopTest(); 
    } 
    
    @isTest
    static void testHandleRequestDismiss() {
        Test.startTest();
        init();
        FlagDataServer dsObject= new FlagDataServer();  
        pageRef.getParameters().put('action','dismiss');
        pageRef.getParameters().put('data','taskId');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        pageRef.getParameters().put('data','connect-account-prompt');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        Test.stopTest();  
    }        
    
    @isTest
    static void testHandleRequestDismissOnboarding() {
        Test.startTest();
        init();        
        FlagDataServer dsObject= new FlagDataServer();    
        pageRef.getParameters().put('action','dismissOnboarding');
        pageRef.getParameters().put('data','itemToBeDismissed');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest
    static void testHandleRequestResetOnboarding() {
        Test.startTest();
        init();        
        FlagDataServer dsObject= new FlagDataServer();
        pageRef.getParameters().put('action','resetOnboarding');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'Running as expected');
        Test.stopTest();     
    }
    
}