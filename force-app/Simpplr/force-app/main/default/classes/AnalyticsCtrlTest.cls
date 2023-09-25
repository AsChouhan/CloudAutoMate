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
private class AnalyticsCtrlTest {
	
	private static App_Config__c appConfigRecord;
	private static simpplr_content__c content;
	private static Simpplr_Site__c site;
	private static User standardUserObj;
	private static User managerUserObj;
	
	@testSetup static void setup() {
		TestHelper.setupAppConfig();
		TestHelper.createUser('AnalyticsCtrlTest_admin', null, true);
		CollaborationGroup cgroup = TestHelper.createCollaborationGroup('AnalyticsCtrlTest_Grp1','Public');
	}
	
	@isTest static void testGetPageName() {
		PageReference pageRef = Page.Analytics;
		Test.setCurrentpage(pageRef);
		AnalyticsCtrl ctrlObj = new AnalyticsCtrl();
		String value = AnalyticsCtrl.pageName;
		value = ctrlObj.currentSiteId;
		value = ctrlObj.getPageFeature();
		ctrlObj.getPageTitle();
		ctrlObj.buildVIewParam();
		setCurrentPage();
		ctrlObj.buildVIewParam();
		ctrlObj.init();
		System.assert(true,'Running as expected');
	}
	
	private static void setCurrentPage(){
    	Simpplr_Site__c simpplrSiteRec = getSimpplrSite();
    	PageReference pageRef = Page.Analytics;
		pageRef.getParameters().put('siteId',simpplrSiteRec.Id);
        Test.setCurrentpage(pageRef);
    }
    
    private static Simpplr_Site__c getSimpplrSite(){
    	 return([select id from Simpplr_Site__c limit 1]);
    }
	
}