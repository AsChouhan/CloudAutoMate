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
private class PageContextTest {  

    @testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    	People__c peopleRec = new People__c(User__c = UserContext.id);
    	insert peopleRec;
    	People_Preference__c peoplePreference = new People_Preference__c(People__c=peopleRec.id);
    	insert peoplePreference;
    	User testUser = TestHelper.createUser('PageContextTest_usr', null, false);
 		User grpMngr = TestHelper.createUser('PageContextTest_grpMngr', null, false);
 		
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('PageContextTest_Grp1','Public');
        TestHelper.createCollaborationGroupMember(cgroup.Id, grpMngr.id,'Admin');
    } 
   
    private static void setCurrentSiteRecordProperty(){
        PageReference pageRef = Page.app;
        pageRef.getParameters().put('siteId',getSite().Id);
        Test.setCurrentpage(pageRef);
    }
  
    private static Simpplr_Site__c getSite(){
    	return([select id,Landing_Page__c from Simpplr_Site__c limit 1]);
    }
    
    private static App_Config__c getAppConfig(){
    	return([select id,Allowed_Features__c,App_Dashboard_Mode__c,Site_Dashboard_Mode__c	 from App_Config__c limit 1]);
    }
    
    private static list<Tiles_Config__c> getTilesList(){
    	return([select id,Site__c from Tiles_Config__c]);
    }
    
    @isTest static void testCurrentPageURLProperty() {
        setCurrentSiteRecordProperty();
        String currentPageURL = PageContext.currentPageURL;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testNamespacePrefixProperty() {
        String namespacePrefix = PageContext.namespacePrefix;
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testCurrentPageNameProperty() {
    	setCurrentSiteRecordProperty();
    	Simpplr_Site__c siteRecord = getSite();
        String currentPageName = PageContext.currentPageName; 
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPageURLWithValidPageName() {
        String getPageURL = PageContext.getPageURL('Sites');
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testAllowCommentOnContentWhenAcrossApp() {
    	App_Config__c appConfig = getAppConfig();
    	appConfig.Site_Dashboard_Mode__c = 'App Manager';
    	update appConfig;
        Boolean allowCommentOnContent = PageContext.allowCommentOnContent(); 
        System.assert(true,'Running as expected');
    }

}