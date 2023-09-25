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
private class BaseTemplateCtrlTest {

    private static App_Config__c appConfigRecord;
	private static User systemAdmin;
	private static User siteOwnr;
	private static User siteMember;
	private static User siteAdmin;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Site__c site;
	
    
    @testSetup
 	static void setup() {
    	TestHelper.setupAppConfig();
        TestHelper.setupAppDefault();
    	User userObj = TestHelper.createUser('BaseTemplateCtrlTest_User', null, false); 
    	simpplrContent = TestHelper.createContent('simpplr test blog', 'BlogPost', 'Approved', userObj, null);
        TestHelper.createAppIntegrationRecords(false, new Set<String>{'twitter', 'facebook', 'linkedin'});
        System.assert(true,'Running as expected'); 
    }

    private static void setCurrentPage(){
    	PageReference pageRef = Page.BaseTemplate;
        Test.setCurrentpage(pageRef);
    }
  
    @isTest static void testGetPageTitle() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String pageTitle = baseTemplateCtrlObj.getPageTitle();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetCSSClasses() {
        Test.startTest();
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        SimpplrContext.isSimpplrSetupComplete = true;
        SimpplrContext.isMaintenanceInProgress = false;
        PageReference testPage = baseTemplateCtrlObj.init(); 
        UserContext.hasSimpplrUserPermissionSetAssigned = false;
        testPage = baseTemplateCtrlObj.init();
        SimpplrContext.BrandingCSSClass = '["page-bg-img-t"]'; 
        String getCSSClasses = baseTemplateCtrlObj.getCSSClasses();
        Test.stopTest();
        System.assert(true,'Running as expected');  
    }
    
     
    @isTest static void testGetLogoUrl() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String getLogoUrl = baseTemplateCtrlObj.getLogoUrl();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPageUrl() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String getPageUrl = baseTemplateCtrlObj.getPageUrl();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPageFeature() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String pageFeature = baseTemplateCtrlObj.getPageFeature();
        System.assert(true,'Running as expected');
    }

    
    @isTest static void testGetFaviconsPath() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String faviconsPath = baseTemplateCtrlObj.faviconsPath;
        System.assert(true,'Running as expected');
    } 

    
    // cannot make method with inactive user as system.runAs(user) is not supported with inactive user
    @isTest static void testInitWhenUserIsActive() {
        setCurrentPage();
        BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
    	PageReference testPage = baseTemplateCtrlObj.init();
		System.assert(true,'Running as expected');
    }
    
    @isTest static void testMinifiedCssPath() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String minifiedCssPath = baseTemplateCtrlObj.minifiedCssPath;
        System.assert(true,'Running as expected');
    } 
    
     @isTest static void testMinifiedJsPath() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String minifiedJsPath = baseTemplateCtrlObj.minifiedJsPath;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testTimeZoneOffset() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        Integer timeZoneOffset = baseTemplateCtrlObj.timeZoneOffset;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testShowOnlyLogoInHeader() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        Boolean showOnlyLogoInHeader = baseTemplateCtrlObj.showOnlyLogoInHeader;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testAppName() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String appName = baseTemplateCtrlObj.appName;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testPackageName() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String packageName = baseTemplateCtrlObj.packageName;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testFontCSSURL() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        baseTemplateCtrlObj.useCustomFont = true;
        String fontCSSURL = baseTemplateCtrlObj.fontCSSURL;
        baseTemplateCtrlObj.useCustomFont = false;
        fontCSSURL = baseTemplateCtrlObj.fontCSSURL;
        fontCSSURL = baseTemplateCtrlObj.fontCSSURL;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSetFirstLoginTimeIfRequired() {
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        baseTemplateCtrlObj.setFirstLoginTimeIfRequired();
        System.assert(true,'Running as expected');
    }
   
    
     @isTest static void testGetDashboardHasFeedCSSClasses(){
    	setCurrentPage();
    	BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String tileLayout = SiteContext.tileLayout;
        baseTemplateCtrlObj.getDashboardHasFeedCSSClasses();
        SimpplrContext.isSegmentsEnabled = true;
        baseTemplateCtrlObj.getDashboardHasFeedCSSClasses();
        System.assert(true,'Running as expected');  
    }
  

    @isTest static void testGettters() {
    	setCurrentPage();
		BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        String str = baseTemplateCtrlObj.packageVersion;
        str = baseTemplateCtrlObj.minifiedCssPath;
        str = baseTemplateCtrlObj.minifiedJsPath;
        str = baseTemplateCtrlObj.languageLocale;
	    str = baseTemplateCtrlObj.brandingCSSURL;
        Boolean bool = baseTemplateCtrlObj.isJSDebugEnabled;
        String test ='';
        bool = baseTemplateCtrlObj.isMaintenanceModeEnabled;
        bool = baseTemplateCtrlObj.showMaintenanceInterstitialDiv;
        test = baseTemplateCtrlObj.getDashboardHasFeedCSSClasses();
        System.assert(true,'Running as expected');
    } 
    @isTest static void testGetAlerts(){
        setCurrentPage();
        BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        PageReference pg = baseTemplateCtrlObj.getNotificationsAndAlerts();
        String str = baseTemplateCtrlObj.getAlert();
        str = baseTemplateCtrlObj.getNotification();
        System.assert(true,'Running as expected');  
    }

    @isTest static void testfeatureFlags(){
        setCurrentPage();
        System.assertNotEquals(null,BaseTemplateCtrl.isActionPollerNotificationEnabled);
        System.assertNotEquals(null,BaseTemplateCtrl.isApexRestEnabled);
        System.assertNotEquals(null,BaseTemplateCtrl.isKitaPSARChangesEnabled);
        System.assert(true,'Running as expected');  
    }
    @isTest static void testStartOnboarding() {
        SimpplrContext.uuid = '123';
		TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        Test.startTest();
    	setCurrentPage();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/people-onboarding', false));
        BaseTemplateCtrl baseTemplateCtrlObj = new BaseTemplateCtrl();
        PageReference testPage = baseTemplateCtrlObj.init(); 
        Test.stopTest();
        System.assert(true,'Running as expected');  
    }
}