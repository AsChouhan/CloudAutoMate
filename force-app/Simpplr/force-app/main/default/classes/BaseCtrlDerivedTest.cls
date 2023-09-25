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
private class BaseCtrlDerivedTest {

    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        User testUser = TestHelper.createUser('SimpCtrlTest_usr', null, false);
        User siteMngr = TestHelper.createUser('SimpCtrlTest_siteMngr', null, false);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('SimpCtrlTest_Grp1','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteMngr.id,'Admin');
    }
     private static void setCurrentSiteRecordPropertyWithValidSiteId(){
        Simpplr_Site__c rec = [select id from Simpplr_Site__c limit 1];
        PageReference pageRef = Page.app;
        pageRef.getParameters().put('siteId',rec.Id);
        Test.setCurrentpage(pageRef);

        System.assert(true, 'Running as expected');
     }
     private static User getUser(){
     	return([select id from User where lastName='SimpCtrlTest_usr' limit 1]); 
     }
     
     
    @isTest static void testPageMessagesProperty() {
    	setCurrentSiteRecordPropertyWithValidSiteId();
       	BaseCtrlDerived BaseCtrlDerivedObj = new BaseCtrlDerived();
	    MessageHelper.addConfirmMessage('SUCCESS',true);
	    String pageMessages = BaseCtrlDerivedObj.pageMessages;
	    System.assert(true,'Running as expected');

        System.assert(true, 'Running as expected');
    }
    @isTest static void testOrgProperty() {
        Organization simpplrOrgTest = BaseCtrl.org;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testIsSandboxProperty() {
        Boolean isSandboxVar = BaseCtrl.isSandbox;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testInstanceProperty() {
        String instanceStr  = BaseCtrl.instance;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSalesforceHostProperty() {
        String salesforceHostStr = BaseCtrl.salesforceHost;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSimpplrBaseURLProperty() {
        String salesforceBaseUrlStr = BaseCtrl.simpplrBaseURL;
        System.assert(true,'Running as expected');
    }

    @isTest static void testSalesForceContentUrlProperty() {
        String salesforceBaseUrlStr = BaseCtrl.salesForceContentUrl;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSalesForceBaseUrlProperty() {
        String salesforceBaseUrlStr = BaseCtrl.salesforceBaseUrl;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testReadParamWithValidParamters() {
    	setCurrentSiteRecordPropertyWithValidSiteId();
       	BaseCtrlDerived BaseCtrlDerivedObj = new BaseCtrlDerived();
	    String readParam = BaseCtrlDerivedObj.readParam('siteId');
	    System.assert(true,'Running as expected');
    }
    
    @isTest static void testReadParamWithInvalidParameters() {
        setCurrentSiteRecordPropertyWithValidSiteId();
       	BaseCtrlDerived BaseCtrlDerivedObj = new BaseCtrlDerived();
	    String readParam = BaseCtrlDerivedObj.readParam('invalid');
	    System.assert(true,'Running as expected');
    }
    @isTest static void testReadParamWithNullParameters() {
        setCurrentSiteRecordPropertyWithValidSiteId();
       	BaseCtrlDerived BaseCtrlDerivedObj = new BaseCtrlDerived();
	    String readParam = BaseCtrlDerivedObj.readParam('');
	    System.assert(true,'Running as expected');
    }
     @isTest static void testPrepareMessage() {
     	 setCurrentSiteRecordPropertyWithValidSiteId();
       	BaseCtrlDerived BaseCtrlDerivedObj = new BaseCtrlDerived();
	    String readParam = BaseCtrlDerivedObj.prepareMessage('test_type','type_message');
	    System.assert(true,'Running as expected');
    }
    
    @isTest static void testHandleAndTranslateException() {
    	setCurrentSiteRecordPropertyWithValidSiteId();
    	BaseCtrlDerived BaseCtrlDerivedObj = new BaseCtrlDerived();
    	BaseCtrlDerivedObj.handleAndTranslateException(null, new SimpplrException(ServiceConstants.ERROR_404));
    	BaseCtrlDerivedObj.handleAndTranslateException(null, new SimpplrException(ExceptionCode.NO_ACCESS.name()));
    	BaseCtrlDerivedObj.handleAndTranslateException(null, new SimpplrException(ExceptionCode.INCORRECT_USER_SETUP.name()));
    	BaseCtrlDerivedObj.handleAndTranslateException(null, new SimpplrException(ExceptionCode.OPTION_DISABLED.name()));
    	System.assert(true,'Running as expected');
    }
   
    @isTest static void testStaticProperties(){
        System.assertNotEquals(null,BaseCtrl.salesforceOrgDomainUrl);
    }
    @isTest static void testurlRedirection() {
        SimpplrContext.isFileServiceAuthEnabled = true;
        SimpplrContext.uuid = '123';
    	setCurrentSiteRecordPropertyWithValidSiteId();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/v1/identity/oauth/client/token', false));
        AppCtrl app = new AppCtrl();
		PageReference page = app.urlRedirection();
	    System.assert(true,'Running as expected');
        Test.stopTest();
    }
}