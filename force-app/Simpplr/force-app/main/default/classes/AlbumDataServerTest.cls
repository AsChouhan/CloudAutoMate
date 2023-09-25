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
private class AlbumDataServerTest {

    private static App_Config__c appConfigRecord;
	private static User systemAdmin;
	private static User siteOwnr;
	private static User siteMember;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Site__c site;
	@testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
		systemAdmin = TestHelper.createUser('AlbumDataServerTest_admin', null, true);
		siteOwnr = TestHelper.createUser('AlbumDataServerTest_siteOwnr', null, false);
		managerOfsiteMember = TestHelper.createUser('AlbumDataServerTest_userMngr', null, false);
		siteMember = TestHelper.createUser('AlbumDataServerTest_siteMmbr', managerOfsiteMember, false);
		cgroup = TestHelper.createCollaborationGroup('AlbumDataServerTest_Grp1','Public');
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(cgroup.Id);
		TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		
	    CollaborationGroupMember cgMember2 = TestHelper.createCollaborationGroupMember(cgroup.Id, siteMember.id, 'Standard');
        simpplrContent = TestHelper.createContent('AlbumDataServerTest Album', 'Album', 'Approved', systemAdmin, testSite);
        TestHelper.createContentTitleImage(simpplrContent.Id);
	}
	
	private static void init() {
    	if(appConfigRecord == null) {
    		appConfigRecord = SimpplrContext.appConfig;
	    	List<User> listOfUsers = [select Id, lastName from user where lastname like 'AlbumDataServerTest%'];
	    	for(User userObj : listOfUsers) {
	    		if(userObj.lastName == 'AlbumDataServerTest_admin') {
	    			systemAdmin = userObj;
	    		} else if(userObj.lastName == 'AlbumDataServerTest_siteOwnr') {
	    			siteOwnr = userObj; 
	    		} else if(userObj.lastName == 'AlbumDataServerTest_userMngr') {
	    			managerOfsiteMember = userObj; 
	    		} else if(userObj.lastName == 'AlbumDataServerTest_siteMmbr') {
	    			siteMember = userObj; 
	    		} 
	    	}
	    	site = TestHelper.getSiteRecordWithName('AlbumDataServerTest_Grp1');
	        simpplrContent = TestHelper.createContent('simpplr test news', 'News', 'Submitted', siteMember, site);
    	}
    	PageReference pgRef = Page.DataServerRO;
    	pgRef.getParameters().put('target','AlbumDataServer');
        Test.setCurrentPage(pgRef);
    }
	
    @isTest static void testHandleRequest() { 
  	  	init();
        AlbumDataServer albumDSObject= new AlbumDataServer();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('siteId',site.id);
    	pageRef.getParameters().put('target','AlbumDataServer');
        
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        albumDSObject.handleRequest();
        System.assertEquals('error', albumDSObject.response.status, 'Missing action parameter');
        
        pageRef.getParameters().put('action',albumDSObject.ACTION_VALUE_SEARCH);
        pageRef.getParameters().put('data','{"PageName":"SiteAlbums","filter":"all","siteId":"a0761000004rXMsAAM","sortBy":"promoted","size":10}');
        Test.setCurrentPage(pageRef);
        albumDSObject.handleRequest();
        System.assertEquals('success', albumDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',albumDSObject.ACTION_VALUE_SEARCH);
        pageRef.getParameters().put('data','{"PageName":"","filter":"","siteId":"","sortBy":"","size":10}');
        Test.setCurrentPage(pageRef);
        albumDSObject.handleRequest();
        System.assertEquals('success', albumDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action', 'search');
    	pageRef.getParameters().put('data', '{"PageName":"SiteAlbums","siteId":"' + site.Id + '","sortBy":"promoted","size":1}');
    	albumDSObject.handleRequest();
        System.assertEquals('success', albumDSObject.response.status, 'Running as expected');
        albumDSObject.getPageFeature();
    }
    
}