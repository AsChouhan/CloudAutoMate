/**
 * This class contains unit tests for validating the behavior of Apex class ChatterGroupDataServerTest 
 */
@isTest
private class ChatterGroupDataServerTest {

    private static User adminUser;
   
   @testSetup
   static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        User siteOwnr = TestHelper.createUser('ChatterGroupDataServerTest_siteOwnr', null, false);
        User adminUser = TestHelper.createUser('ChatterGroupDataServerTest_adminUser', null, true);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('Simpplr_Grp_ChatterGroupDataServerTest','Public');
        
        system.runAs(adminUser){
       		CollaborationGroup cgroup2 = TestHelper.createCollaborationGroup('ChatterGroupDataServerTestPvt_Test','Private');
        }
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
        List<App_Integration__c> appIntegList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'native_video'});
        appIntegList[0].Org_Id__c = SimpplrContext.simpplrOrgId;
        update appIntegList[0];
    }
    
    private static void init() {
    	PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ChatterGroupDataServer');
       	Test.setCurrentpage(pageRef);
    }
    
    private static Simpplr_Site__c getSimpplrSite(String siteName){
    	 return([select id,chatter_group_id__c  from Simpplr_Site__c where name = :siteName]);
    }
    
    private static String getChatterGroupId(String chatterGroupName){
    	 return([select id from CollaborationGroup where name = :chatterGroupName]).id;
    }
    
    @isTest 
    static void testHandleRequestWhenActionNull() {
    	init();
     	ChatterGroupDataServer ChatterDSObject= new ChatterGroupDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ChatterGroupDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','');
        ChatterDSObject.handleRequest();
        
        pageRef.getParameters().put('action','search');
        ChatterDSObject.handleRequest();
        
        pageRef.getParameters().put('action','createSite');
        ChatterDSObject.handleRequest();
        
        pageRef.getParameters().put('action','convertToSite');
        ChatterDSObject.handleRequest();
               
        system.assert(true,'Running as expected');
    } 
    
    
    @isTest
    static void testHandleRequestWhenActionAvailable() {
        init();        
        ChatterGroupDataServer ChatterDSObject= new ChatterGroupDataServer();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ChatterGroupDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"term":"mpplr_Gr","size":16}');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
    ChatterDSObject.handleRequest();
        
        pageRef.getParameters().put('action','createSite');
        pageRef.getParameters().put('data','{}');
        ChatterDSObject.handleRequest();
        
        String chatterGroupId = getChatterGroupId('Simpplr_Grp_ChatterGroupDataServerTest');
        pageRef.getParameters().put('action','convertToSite');
        pageRef.getParameters().put('data','{}');
        pageRef.getParameters().put('chatterGroupId',chatterGroupId);
        ChatterDSObject.handleRequest();

        System.assert(true,'Running as expected');
        
    }
    
    
    @isTest 
    static void testGetChatterGroups() {
    	init(); 	 
        ChatterGroupDataServer ChatterDSObject= new ChatterGroupDataServer();        
        
        ChatterDSObject.getPageFeature();
        ResponseWrapper resWrapper5 = ChatterDSObject.getChatterGroups('{"term":null,"size":1,"nextPageToken":0}');
        ResponseWrapper resWrapper2 = ChatterDSObject.getChatterGroups('{"term":"mpplr_Gr","size":16}');  
              
  	  	System.assert(true,'Running as expected');  
    }
    
    @isTest 
    static void testGetsiteDetailData() {
    	init();
    	Site_Category__c sc = TestHelper.createSiteCategory(); 	 
        ChatterGroupDataServer ChatterDSObject= new ChatterGroupDataServer();        
        Simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_ChatterGroupDataServerTest');
        siteObj.Site_Category__c = sc.Id;
        siteObj.Title_Content_Document__c='dummy';
        siteObj.Title_Content_Version__c='dummy';
        update siteObj;
        ResponseWrapper resWrapper = ChatterDSObject.getsiteDetailData(siteObj.id);
        resWrapper = ChatterDSObject.getsiteDetailData(null);
                
  	  	System.assert(true,'Running as expected.');  
    }

    @isTest
    static void convertToSiteWithNVTest() {
        init();
        PageReference pageRef = Page.DataServerRW;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('target','ChatterGroupDataServer');
        pageRef.getParameters().put('action','convertToSite');
        String chatterGroupId = getChatterGroupId('Simpplr_Grp_ChatterGroupDataServerTest');
        pageRef.getParameters().put('chatterGroupId',chatterGroupId);
        ChatterGroupDataServer chatterDSObject= new ChatterGroupDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
        Test.startTest();
        chatterDSObject.handleRequest();
        Test.stopTest();
        System.assertEquals('success', chatterDSObject.response.status, 'Result should be sucess');
    }
    
}