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
private class PageDataServerTest {

    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        User testUser2 = TestHelper.createUser('Simpplr_usr2', null, false);
        User siteMngr = TestHelper.createUser('Simpplr_siteMngr', null, false);
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        Simpplr_Content__c contentObj = TestHelper.createContent('simpplr test Page', 'Page', 'Approved', testAdminUser, testSite);
        TestHelper.getPageCategory('uncategorized', testSite.Id);
		TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
		TestHelper.createChatterFolder('testFolder01', null, testSite.Id, 'Intranet', null, 'readwrite');
        
        collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', 'Public').Id;
		testSite = TestHelper.getSiteRecord(collaborationGroupId);
		Simpplr_Content__c simpplrContent = TestHelper.createContent('PageDataServerTest Page', 'Page', 'Approved', testAdminUser, testSite);
		Pages_Category__c pageCategoryObj = TestHelper.getPageCategory('uncategorized', testSite.Id);
        simpplrContent.Pages_Category__c = pageCategoryObj.Id;
        update simpplrContent;
        
        Topic topicObj = TestHelper.createTopic('PageDataServerTestTopic');
        TestHelper.addTopicToContent(topicObj.id, simpplrContent.id);
        
    }
    
    private static User getAdminUser(){
    	User userObj = TestHelper.getUser('System Administrator', 'Simpplr_admin');
        return userObj;
    }
    
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [select Id, Name, Chatter_Group_Id__c, Landing_Page__c 
        								from Simpplr_Site__c where Name='Simpplr_Grp1' LIMIT 1];
        return siteObj;
    }
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
        							Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
									From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }
    
    private static Pages_Category__c getPageCategory4Site_Policy(String siteId){
        Pages_Category__c  pageCatObj = [SELECT Id, Name__c,Order__c,Site__c,Site__r.name 
                                                FROM Pages_Category__c where Site__c = :siteId and Name__c = 'Policy' LIMIT 1];
        return pageCatObj;
    }
    
    private static Pages_Category__c getPageCategory4Site_Process(String siteId){
        Pages_Category__c  pageCatObj = [SELECT Id, Name__c,Order__c,Site__c,Site__r.name 
                                                FROM Pages_Category__c where Site__c = :siteId and Name__c = 'Process' LIMIT 1];
        return pageCatObj;
    }
    
    private static List<Pages_Category__c> createPageCategory4Site(String siteId){
    	List<Pages_Category__c> lstPC = new List<Pages_Category__c>();
        Pages_Category__c  pageCatObj = new Pages_Category__c(Site__c = siteId, Name__c = 'Policy');
        lstPC.add(pageCatObj);
        pageCatObj = new Pages_Category__c(Site__c = siteId, Name__c = 'Process');
        lstPC.add(pageCatObj);
        pageCatObj = new Pages_Category__c(Site__c = siteId, Name__c = 'Insight');
        lstPC.add(pageCatObj);
        Database.insert(lstPC);
        return lstPC;
    }
    
    private static Simpplr_Content__c getPage4Category(String categoryId){
        Simpplr_Content__c pageObj = [SELECT Id, Title__c, Display_Excerpt__c, Text_Intro__c FROM Simpplr_Content__c where Status__c ='Approved' AND Type__c =:ServiceConstants.TYPE_PAGE AND Pages_Category__c = :categoryId LIMIT 1];
        return pageObj;
    }
    
    private static void updateShowSimpplrFalse(Id siteId)
    {
        Simpplr_Site__c  siteObj = [select Id, Name, Show_In_Simpplr__c  
                        from Simpplr_Site__c where id=:siteId ];
        siteObj.Show_In_Simpplr__c = false;
        Database.update(siteObj);
    }
    
    private static void init() {
    	PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PageDataServer');
    	
        pgRef.getParameters().put('action', 'search');
        Test.setCurrentPage(pgRef);
    }
    @isTest static void testSearch() {
        Test.startTest();
    	init();
        PageDataServer serverObj = new PageDataServer();
        Simpplr_Site__c  siteObj = getSite();
		createPageCategory4Site(siteObj.Id);
        
        Pages_Category__c catObjPolicy = getPageCategory4Site_Policy(siteObj.Id);
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PageDataServer');
    	pgRef.getParameters().put('action', 'search');
    	pgRef.getParameters().put('siteId',siteObj.id);
        Test.setCurrentPage(pgRef);
    	
        pgRef.getParameters().put('data', '{"PageName":"SitePages","siteId":"' + siteObj.Id + '","sortBy":"promoted","category":"all","groupCategories":true,"size":1}');
    	serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');
  
        pgRef.getParameters().put('data', '{"PageName":"SitePages","siteId":"' + siteObj.Id + '","sortBy":"viewed","category":"all","groupCategories":false,"size":1,"filter":"following"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');

        pgRef.getParameters().put('data', '{"PageName":"SitePages","siteId":"' + siteObj.Id + '","sortBy":"latest","category":"uncategorized","groupCategories":false,"size":1,"filter":"following"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');

        pgRef.getParameters().put('data', '{"PageName":"SitePages","siteId":"' + siteObj.Id + '","sortBy":"popular","category":"all","groupCategories":false,"size":1,"filter":"ImportantPages"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');

        pgRef.getParameters().put('data', '{"PageName":"SitePages","siteId":"' + siteObj.Id + '","sortBy":null, "categoryId":"test", "category":null, "groupCategories":false, "size":1, "filter":"bookmarked", "topicId":"test"}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, 'Running as expected');

        pgRef.getParameters().put('data', '{"PageName":"SitePages","siteId":"' + siteObj.Id + '","nextPageToken":"abc", "categoryId":"test", "category":null, "groupCategories":false, "size":1, "filter":"bookmarked", "topicId":"test"}');
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message);

        pgRef.getParameters().put('data', '{"PageName":"SitePages","siteId":"' + siteObj.Id + '","nextPageToken":"abc", "categoryId":"test", "category":null, "groupCategories":true, "size":1, "filter":"bookmarked", "topicId":"test"}');
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, serverObj.response.message);

        pgRef.getParameters().put('action', 'searchImportantPages');
        Test.setCurrentPage(pgRef);
        
        serverObj = new PageDataServer();
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, 'Action is undefinedAction, Should return error');
        Test.stopTest();
    }
    
    @isTest static void testUndefinedAction() {
        Test.startTest();
    	init();
        PageDataServer serverObj = new PageDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PageDataServer');
    	pgRef.getParameters().put('action', 'undefinedAction');
    	pgRef.getParameters().put('data', '{}');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, 'Action is undefinedAction, Should return error');
        Test.stopTest();
    }
    
    @isTest static void testMissingAction() {
    	init();
        PageDataServer serverObj = new PageDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','PageDataServer');
    	pgRef.getParameters().put('action', '');
        Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, 'Action is blank, Should return error');

        String pageFeature = serverObj.getPageFeature();
        System.assertEquals('SIMPPLR', pageFeature, 'Running as expected');
    }

    @isTest static void testSiteShowSimpplrFalse(){
        Test.startTest();
        init();
        PageDataServer serverObj = new PageDataServer();
        Simpplr_Site__c  siteObj = getSite();
        updateShowSimpplrFalse(siteObj.id);
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','PageDataServer');
        pgRef.getParameters().put('action', 'search');
        pgRef.getParameters().put('siteId',siteObj.id);
        Test.setCurrentPage(pgRef);
      
        pgRef.getParameters().put('data', '{"PageName":"SitePages","siteId":"' + siteObj.Id + '","sortBy":"promoted","category":"all","groupCategories":true,"size":1}');
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status, 'Site is showSimmplr false, should return error');
        Test.stopTest();
    }
}