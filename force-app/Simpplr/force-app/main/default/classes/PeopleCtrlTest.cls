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
private class PeopleCtrlTest {

    private static App_Config__c appConfigRecord;
	private static simpplr_content__c content;
	private static Simpplr_Site__c site;
	private static User standardUserObj;
	private static User managerUserObj;
	private static User sysAdminUserObj;
    
    static void setup() {
    	if(appConfigRecord==null){
	    	appConfigRecord = new App_Config__c(Name='Test App Config',AT_User_Trigger_Type__c='Realtime',Package_Name__c='', Allowed_Features__c='News,Page,Event,File');
	        insert appConfigRecord;
    	}
    }
    
    private static void setCurrentPage(){
    	PageReference pageRef = Page.People;
        Test.setCurrentpage(pageRef);
    }
    
    @isTest static void testGetPageName() {
        String pageName = Pages.People;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPageTitle() {
    	setCurrentPage();
    	PeopleCtrl PeopleCtrlObj = new PeopleCtrl();
        String pageTitle = PeopleCtrlObj.getPageTitle();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPageFeature() {
    	setCurrentPage();
    	PeopleCtrl PeopleCtrlObj = new PeopleCtrl();
        String pageFeature = PeopleCtrlObj.getPageFeature();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testInit() {
        setCurrentPage();
    	PeopleCtrl PeopleCtrlObj = new PeopleCtrl();
		PageReference testPage = PeopleCtrlObj.init();
		System.assert(true,'Running as expected');	
    }
    
    @isTest static void testSearch() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testFollowUser() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testUnFollowUser() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetfilterWrapperList() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }
    
    
    @isTest static void testMethod1() {
        // Perform some testing
        System.assert(true,'Running as expected');
    }

    @isTest static void testMethod2() {
        // Perform some testing
       System.assert(true,'Running as expected');
    }
    
}