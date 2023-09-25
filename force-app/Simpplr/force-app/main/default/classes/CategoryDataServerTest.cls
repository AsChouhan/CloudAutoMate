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
private class CategoryDataServerTest {
    
    
    private static App_Config__c appConfigRecord;
	private static Simpplr_Content__c content;
	private static Pages_Category__c categoryObj;
	private static Pages_Category__c unCategorizedCategoryObj;
	
	private static Simpplr_Site__c siteObj1;
	private static Simpplr_Site__c siteObj2;
	private static Site_Category__c siteCategoryObj;
	private static Site_Category__c siteCategoryObj2;
	
	private static User standardUserObj;
	private static User managerUserObj;
	private static User systemAdminUserObj;
	@testSetup 
	static void setup() {
    	
    	if(appConfigRecord==null){
	    	appConfigRecord = TestHelper.setupAppConfig();
    	}
        
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
        
        if(standardUserObj==null){
	    	standardUserObj = TestDataHandler.createUser();
        }
    	
        
        if(managerUserObj==null){
        	managerUserObj = TestDataHandler.createManagerUser(standardUserObj);
        }
        
        if(systemAdminUserObj==null){
        	systemAdminUserObj = TestDataHandler.createSystemAdmin();
        }
        
        if(siteObj1==null){
	        TestDataHandler.createCollaborationGroup('Test_Site_01');
        	siteObj1 = [select id from Simpplr_Site__c where Name = 'Test_Site_01' limit 1];
        	
        }
        if(siteObj2==null){
	        TestDataHandler.createCollaborationGroup('Test_Site_02');
        	siteObj2 = [select id from Simpplr_Site__c where Name = 'Test_Site_02' limit 1];
        	
        }
    	
    	List<Pages_Category__c> lstPC = new List<Pages_Category__c>();
        Pages_Category__c  pageCatObj = new Pages_Category__c(Site__c = siteObj1.Id, Name__c = 'Policy');
        lstPC.add(pageCatObj);
        pageCatObj = new Pages_Category__c(Site__c = siteObj1.Id, Name__c = 'Process');
        lstPC.add(pageCatObj);
        pageCatObj = new Pages_Category__c(Site__c = siteObj1.Id, Name__c = 'Insight');
        lstPC.add(pageCatObj);
        pageCatObj = new Pages_Category__c(Site__c = siteObj1.Id, Name__c = ServiceConstants.CATEGORY_UNCATEGORIZED);
        lstPC.add(pageCatObj);
        Database.insert(lstPC);
    	//categoryObj = [select id,name__c, order__c from Pages_Category__c where (Not name__c like 'uncategorized%') limit 1];
    	//categoryObj.order__c=1;
        	
    	if(siteCategoryObj==null){
    		siteCategoryObj= new Site_Category__c (Name__c='CategoryDataServerTest',Is_Deleted__c=false);
    		insert siteCategoryObj;
    	}
    	if(siteCategoryObj2==null){
    		siteCategoryObj2= new Site_Category__c (Name__c='CategoryDataServerTest2',Is_Deleted__c=false);
    		insert siteCategoryObj2;
    	}
        
        if(content == null){
	        	content = new Simpplr_Content__c(
	                            Title__c='CategoryDataServerTest_testArticleRecord', 
	                                Text_Intro__c='Example text', 
	                                Text_Main__c='Example text',
	                                Text_Main_Continued__c=' example text ',
	                                Type__c='News', 
	                                Status__c='submitted',
	                                Site__c = siteObj1.id
	                                );
	        	insert content;
	        }
    }
    
    static void init() {
		PageReference pgRef = Page.DataServerRW;
		pgRef.getParameters().put('target','CategoryDataServer');
        Test.setCurrentPage(pgRef);
        content = [select id, site__c from Simpplr_Content__c where title__c='CategoryDataServerTest_testArticleRecord' limit 1];
        siteObj1 = [select id from Simpplr_Site__c where Name = 'Test_Site_01' limit 1];
        siteObj2 = [select id from Simpplr_Site__c where Name = 'Test_Site_02' limit 1];
        categoryObj = [select id,name__c, order__c from Pages_Category__c where name__c != 'Uncategorized' limit 1];
    	unCategorizedCategoryObj = [select id,name__c, order__c from Pages_Category__c where name__c = 'Uncategorized' limit 1];
    	siteCategoryObj = [select id,name__c from Site_Category__c where name__c = 'CategoryDataServerTest'];
    	siteCategoryObj2 = [select id,name__c from Site_Category__c where name__c = 'CategoryDataServerTest2'];
    	
    	systemAdminUserObj = [select Id, Name from User where CommunityNickname = 'testsys1'];
    }
    @isTest static void testHandleRequestWhenActionNull() {
    	init();
    	CategoryDataServer dSObj= new CategoryDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','');
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'status should be error for null action');
    }
    
    @isTest static void testHandleRequestWhenActionAvailable() {
    	init();
    	CategoryDataServer dsObject= new CategoryDataServer();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','CategoryDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action',dsObject.ACTION_VALUE_SEARCH);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'status should have been success');

        pageRef.getParameters().put('action',dsObject.ACTION_VALUE_EDIT);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error');

        pageRef.getParameters().put('action',dsObject.ACTION_VALUE_DELETE);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error');
        
        pageRef.getParameters().put('action',dsObject.ACTION_VALUE_CREATE);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error');
        
        pageRef.getParameters().put('action',dsObject.ACTION_SEARCH_CATEGORY_WITH_SITE_COUNT);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('success', dsObject.response.status, 'status should have been success');
        
        pageRef.getParameters().put('action',dsObject.ACTION_DELETE_SITE_CATEGORY);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error');
        
        pageRef.getParameters().put('action',dsObject.ACTION_VALUE_UPDATE_CATEGORY_POSITION);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error');
        
        pageRef.getParameters().put('action',dsObject.ACTION_CREATE_SITE_CATEGORY);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error');
        
        pageRef.getParameters().put('action',dsObject.ACTION_VALUE_UPDATE_SITE_CATEGORY_POSITION);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error');
        
        pageRef.getParameters().put('action',dsObject.ACTION_GET_SITE_CATEGORY);
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error');
        
        pageRef.getParameters().put('action','####'); //wrong action value
        pageRef.getParameters().put('data','{}');
        dsObject.handleRequest();
		System.assertEquals('error', dsObject.response.status, 'status should have been error for wrong action value');
        
    }
    
	@isTest
    static void searchPageCategoryTest() {
		init();
		CategoryDataServer dsObject = new CategoryDataServer();
		String data = '{"size":999999,"siteId":"' + siteObj1.id + '"}';
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','CategoryDataServer');
        Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('action',dsObject.ACTION_VALUE_SEARCH);
		pageRef.getParameters().put('data', data);
        dsObject.handleRequest();
        System.assertEquals('success', dsObject.response.status, 'status should have been success');
	}

    @isTest static void testDeletePageCategoryRecord1() {
    		init();
	    	CategoryDataServer dsObject = new CategoryDataServer();
	    	String data='["' + categoryObj.id + '"]';
	    	ResponseWrapper resp = dsObject.deletePageCategoryRecord(data);
			System.assertEquals('success', resp.status, 'Result should have been success');
	    	data='["' + unCategorizedCategoryObj.id + '"]';
	    	resp = dsObject.deletePageCategoryRecord(data);
	    	System.assertEquals('error', resp.status, 'Result should have been error. Cannot delete uncategorised category');
    }
    
    @isTest static void testDeletePageCategoryRecord2() {
    		init();
	    	CategoryDataServer dsObject = new CategoryDataServer();
			String data='';
			ResponseWrapper resp = dsObject.deletePageCategoryRecord(data);
			System.assertEquals('error', resp.status, 'Result should have been error. Data is blank');
	    	data='{""}';
			resp = dsObject.deletePageCategoryRecord(data);	    	
	    	System.assertEquals('error', resp.status, 'Result should have been error. Data is blank');
    }
    
    @isTest static void testEditPageCategoryRecord() {
    		init();
	    	CategoryDataServer dsObject = new CategoryDataServer();
	    	String data='{"name":"SomeRandomName","id":"'+categoryObj.id+'"}';
	    	ResponseWrapper resp = dsObject.editPageCategoryRecord(data); 
	    	System.assertEquals('success', resp.status, 'Result should have been success');
    }

    @isTest static void testCreatePageCategoryRecord() {
    	init();
    	CategoryDataServer dsObject = new CategoryDataServer();
    	String data='{"name":"SimpplrTest","siteId":"'+siteObj1.id+'"}';
    	ResponseWrapper resp = dsObject.createPageCategoryRecord(data); 
    	System.assertEquals('success', resp.status, 'Result should have been success');
    }
    
    @isTest static void testUpdateCategoryPosition() {
    		init();
	    	CategoryDataServer dsObject = new CategoryDataServer();

	    	//System.runAs(systemAdminUserObj) {
		    	String data = '{"siteId":"' + siteObj1.Id + '","categoryIds":["' + categoryObj.Id + '","' + categoryObj.Id + '"]}';
				SiteContext.siteId = siteObj1.Id;
		    	ResponseWrapper resp = dsObject.updateCategoryPosition(data);
				System.assertEquals('success', resp.status, 'Result should have been success');
	    	//}
	    	
	    	
    }
    
    //{"sortBy":"createdNewest","size":10,"term":"SomeName"}
    @isTest static void testSearchSiteCategory() {
    	init();
	    CategoryDataServer dsObject = new CategoryDataServer();
	    	
	    String data = '{"sortBy":"createdNewest","size":10,"term":"SomeSimpleName","includeSites":true,"showOnlyContainingSites":true}';
	    Test.startTest();
		Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchSiteCategory',false));		
		ResponseWrapper resp = dsObject.searchSiteCategory(data);
		System.assertEquals('success', resp.status, 'Result should be success');
	    	
	    String data2 = '######';
	    ResponseWrapper resp2 = dsObject.searchSiteCategory(data2);
		System.assertEquals('error', resp2.status, 'Result should be error');
	    	
	    String data3 = null;
	    ResponseWrapper resp3 = dsObject.searchSiteCategory(data3);
	    System.assertEquals('success', resp3.status, 'Result should be success');
		Test.stopTest();
    }
    
    @isTest static void testGetSiteCategory() {
    		init();
	    	CategoryDataServer dsObject = new CategoryDataServer();
	    	
	    	String data = '{"categoryId":"' + siteCategoryObj.id + '"}';
	    	ResponseWrapper resp = dsObject.getSiteCategory(data);
	    	
	    	System.assertEquals('success', resp.status, 'Result should be success');
    }
    
    @isTest static void testSaveSiteCategory() {
    	init();
	    CategoryDataServer dsObject = new CategoryDataServer();
	    	String data = '{"access":"all","name":"site category1","categoryId":null}';
	    	ResponseWrapper resp = dsObject.saveSiteCategory(data);
	    	System.assertEquals('success', resp.status, 'Result should be success');
	    	// adding duplicate category
	    	resp = dsObject.saveSiteCategory(data);
			System.assertEquals('error', resp.status, 'duplicate site should throw error');
    }
    
    @isTest static void testUpdateSiteCategoryPosition() {
    		init();
	    	CategoryDataServer dsObject = new CategoryDataServer();
	    	
	    	//System.runAs(systemAdminUserObj) {
		    	String data = '{"siteId":"' + siteObj1.Id + '","categoryIds":["' + siteCategoryObj.Id + '"]}';
		    	ResponseWrapper resp = dsObject.updateSiteCategoryPosition(data);
				System.assertEquals('success', resp.status, 'Result should be success');
			//}
	    	
	    	
    }
    
    @isTest static void testDeleteSiteCategory() {
    		init();
	    	CategoryDataServer dsObject = new CategoryDataServer();
	    	
	    	
	    	// case 1
	    	String data='["'+siteCategoryObj.id+'"]';
	    	ResponseWrapper resp = dsObject.deleteSiteCategory(data);
			List<Site_category__c> siteCategoryList = [SELECT Id from Site_category__c WHERE Id =: siteCategoryObj.id
														AND is_deleted__c = false];
			System.assertEquals('success', resp.status, 'Result should be success');
			System.assertEquals(0, siteCategoryList.size(), 'size should be 0');
	    	
	    	// case 2
	    	siteCategoryObj= new Site_Category__c (Name__c='CategoryDataServerTest',Is_Deleted__c=false);
    		insert siteCategoryObj;
	    	siteObj1.Site_Category__c = siteCategoryObj2.Id;
	    	upsert siteObj1;
	    	
	    	data='["'+siteCategoryObj.id+'","' + siteCategoryObj2.Id + '"]';
	    	resp = dsObject.deleteSiteCategory(data);
	    	System.assertEquals('error', resp.status, 'Result should be error as deleted site category is linked with active site');
	    	
	    	// case 3
	    	siteCategoryObj= new Site_Category__c (Name__c='CategoryDataServerTest',Is_Deleted__c=false);
    		insert siteCategoryObj;
	    	siteObj1.Site_Category__c = siteCategoryObj.Id;
	    	upsert siteObj1;
	    	siteObj2.Site_Category__c = siteCategoryObj2.Id;
	    	upsert siteObj2;
	    	
	    	Site_Category__c siteCategoryObj3= new Site_Category__c (Name__c='CategoryDataServerTest',Is_Deleted__c=false);
    		insert siteCategoryObj3;
 	    	
	    	data='["'+siteCategoryObj.id+'","' + siteCategoryObj2.Id + '","' + siteCategoryObj3.Id + '"]';
	    	resp = dsObject.deleteSiteCategory(data);
	    	System.assertEquals('error', resp.status, 'Result should be error as deleted site category is linked with active site');
	    	
    }
   
     @isTest static void testUpdateCategoryOrder() {
    	init();
	    //System.runAs(managerUserObj) {
	    	CategoryDataServer dsObject = new CategoryDataServer();
	    	Map<Id, Pages_Category__c> categoryMap = new Map<Id, Pages_Category__c>();
	    	categoryMap.put(categoryObj.id,categoryObj);
	    	List<String> categoryidList= new List<String>{categoryObj.id};
	    	List<Pages_Category__c> resp = dsObject.updateCategoryOrder(categoryMap,categoryidList); 
			Pages_Category__c pagesCategoryObj = resp[0];
	    	System.assertEquals(pagesCategoryObj.Order__c, 0, 'Order should be 0');
    	//}
    	
    }
    
    @isTest static void testGetPageFeature() {
		init();
    	CategoryDataServer dSObj= new CategoryDataServer();
    	String pageFeature = dSObj.getPageFeature();
    	System.assertEquals(AccessManager.FEATURE_SIMPPLR, pageFeature, 'Value should be AccessManager.FEATURE_SIMPPLR');
    }
}