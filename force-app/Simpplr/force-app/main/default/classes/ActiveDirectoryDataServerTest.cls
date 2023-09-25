@isTest
private class ActiveDirectoryDataServerTest {
	 @testSetup static void setup() {
        TestHelper.setupAppConfig();
        
        TestHelper.createUser('Simpplr_mngr', null, false); 
		TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        
        Id collaborationGroupId = TestHelper.createCollaborationGroup('ActiveDirectoryDataServerTest_Grp1', 'Public').Id;
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
        TestHelper.createAppIntegrationRecords(True, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY});
    }

   @isTest static void testHandleRequest() {
        Active_Directory_Group__C aDGrpObj=new Active_Directory_Group__C();
        aDGrpObj.Name='ActiveDirectoryDataServerTest_Grp1';
		insert aDGrpObj;        
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        Test.setCurrentPage(pageRef);
        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();
        activeDirectoryDSObject.handleRequest();
        Simpplr_Site__c testSite = TestHelper.getSiteRecordWithName('ActiveDirectoryDataServerTest_Grp1');
        pageRef.getParameters().put('target', 'ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'groupSearch');        
    	pageRef.getParameters().put('data', '{"term":"ActiveDirectoryDataServerTest_Grp1","selected":true}');
    	activeDirectoryDSObject.handleRequest(); 
    	
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);       
    }
    
    @isTest static void testgetActiveDirectoryGroupsAll() {
        Active_Directory_Group__C aDGrpObj=new Active_Directory_Group__C();
        aDGrpObj.name = 'Test Group';
		aDGrpObj.AD_Object_Id__c = '004d2075-1e1b-4f15-b94c-778b0e48cc9c';
		insert aDGrpObj;   
        
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'getActiveDirectoryGroups');        
    	pageRef.getParameters().put('data', '{"tab":"All","size":16,"nextPageToken":"1","term":"test","groupType":"nil"}');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/ActiveDirectory',false));
        activeDirectoryDSObject.handleRequest(); 
    	
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);  
        Test.stopTest();
    }
    
    @isTest static void testgetActiveDirectoryGroupsV2All() {
        Active_Directory_Group__C aDGrpObj=new Active_Directory_Group__C();
        aDGrpObj.name = 'Test Group';
		aDGrpObj.AD_Object_Id__c = '004d2075-1e1b-4f15-b94c-778b0e48cc9c';
		insert aDGrpObj;   

		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'getActiveDirectoryGroups');        
    	pageRef.getParameters().put('data', '{"tab":"All","size":16,"nextPageToken":"1","term":"test","groupType":"nil"}');
        Test.setCurrentPage(pageRef);
		
        Test.startTest();
        FeatureFlagManager.featureFlagValueMap.put('ad_groups_v2', true);
        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/ActiveDirectory',false));
        activeDirectoryDSObject.handleRequest(); 
    	
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);  
        Test.stopTest();
    }
    
    
    @isTest static void testgetActiveDirectoryGrpSelcted() {
        Active_Directory_Group__C aDGrpObj=new Active_Directory_Group__C();
        aDGrpObj.name = 'Test Group';
		aDGrpObj.AD_Object_Id__c = '004d2075-1e1b-4f15-b94c-778b0e48cc9c';
		insert aDGrpObj;   
        
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'getActiveDirectoryGroups');        
    	pageRef.getParameters().put('data', '{"tab":"Selected","size":16,"nextPageToken":"1","term":"test","groupType":"nil"}');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/ActiveDirectory',false));
        activeDirectoryDSObject.handleRequest(); 
    	
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);  
        Test.stopTest();
    }
    
    @isTest static void testgetADGroupMembers() {
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'getActiveDirectoryGroupMembers');        
    	pageRef.getParameters().put('data', '{"size":16,"nextPageToken":"1","term":"test","groupId":"group Id"}');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/ActiveDirectory',false));
        activeDirectoryDSObject.handleRequest(); 
    	
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);  
        Test.stopTest();
    }

    @isTest
    static void testInitiateADGroupMemSync() {
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'initiateADGroupMemSync');        
    	pageRef.getParameters().put('data', '{"jobType":"intiateADGroupSyncJob"}');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        SimpplrContext.isActiveDirectoryGroupsEnabled = true;
        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        activeDirectoryDSObject.handleRequest(); 
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message); 
        
        pageRef.getParameters().put('data', '{"jobType":"initiateAudienceMemSync","adGroupIdsDeletedFromPortal":[]}');
        Test.setCurrentPage(pageRef);
        activeDirectoryDSObject.handleRequest(); 
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);         

        Test.stopTest();        
    }

    @isTest
    static void testInitiateADGroupMemSync2() {
        Active_Directory_Group__c adGroupObj = TestHelper.createActiveDirectoryGroup();
        String adId = adGroupObj.AD_Object_Id__c;
		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'initiateADGroupMemSync');        
    	pageRef.getParameters().put('data', '{"jobType":"initiateAudienceMemSync", "adGroupIdsDeletedFromPortal" : ["' + adId + '"]}');
        Test.setCurrentPage(pageRef); 
        
        Test.startTest();
        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();
        SimpplrContext.isActiveDirectoryGroupsEnabled = true;  
        activeDirectoryDSObject.handleRequest(); 
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);         
        Test.stopTest();                      
    }

    @isTest
    static void testGetSelectedGroupTypes() {
        Active_Directory_Group__c adGroupObj = TestHelper.createActiveDirectoryGroup();
        adGroupObj.Mail_Enabled__c = TRUE;
        update adGroupObj;

        adGroupObj = TestHelper.createActiveDirectoryGroup();
        adGroupObj.Security_Enabled__c = TRUE;
        update adGroupObj;        

		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'getSelectedGroupTypes');        
        Test.setCurrentPage(pageRef);        

        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();    
        activeDirectoryDSObject.handleRequest(); 
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);             
    }
    
    @isTest
    static void testGetSelectedGroupTypesV2Enabled() {
        Active_Directory_Group__c adGroupObj = TestHelper.createActiveDirectoryGroup();
        adGroupObj.Mail_Enabled__c = TRUE;
        update adGroupObj;

        adGroupObj = TestHelper.createActiveDirectoryGroup();
        adGroupObj.Security_Enabled__c = TRUE;
        update adGroupObj;        

		PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ActiveDirectoryDataServer');
        pageRef.getParameters().put('action', 'getSelectedGroupTypes');        
        Test.setCurrentPage(pageRef);        
        FeatureFlagManager.featureFlagValueMap.put('ad_groups_v2', true);
        ActiveDirectoryDataServer activeDirectoryDSObject = new ActiveDirectoryDataServer();    
        activeDirectoryDSObject.handleRequest(); 
        System.assertEquals('success', activeDirectoryDSObject.response.status , activeDirectoryDSObject.response.message);             
    }
}