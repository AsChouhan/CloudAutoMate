@isTest
private class BoxServiceTest {
	
	private static CollaborationGroup collGroup;
	private static Simpplr_Site__c site;
	
	@testSetup
	static void setUp() {
		App_Config__c appConfigRecord = TestHelper.setupAppconfig();
      appConfigRecord.Box_Managed_Permissions__c = 'simpplr';
      update appConfigRecord;
      People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		TestHelper.createPeoplePreference(peopleObj.Id);
		
        collGroup = new CollaborationGroup(name='BoxServiceTest', CollaborationType='Public');
        insert collGroup;
        Simpplr_Site__c site = [select id from Simpplr_Site__c where chatter_group_Id__c =: collGroup.id];
        Simpplr_Metadata__c metdataObj = new Simpplr_Metadata__c();
        metdataObj.User__c = UserContext.Id;
        metdataObj.Type__c = 'BOX_MEMBERSHIP_INFO';
        insert metdataObj;
        Folder__c folderObj = TestHelper.createChatterFolder('Box Files', null, site.Id, 'Box', null, 'read');
        folderObj.Is_System_Folder__c = false;
        folderObj.is_deleted__c=false;
        folderObj.External_Folder_Id__c = folderObj.id;
        update folderObj;
		System.assert(true,'Running as expected');
	}
    
     @isTest static void testgetBoxFileDetails() {
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        BoxService obj = new BoxService();
        BoxWrapper.FolderFile result = obj.getBoxFileDetails('TestFileId','TestAccessToken');
        Test.stopTest();
        System.assertNotEquals(0, result.path_collection.total_count,'Running as expected');
     }
     
     @isTest static void testAddUserToBoxGroup() {
        site = TestHelper.getSiteRecordWithName('BoxServiceTest');
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        BoxService obj = new BoxService();
        obj.addUserToBoxGroup('11446498',site.id,site.Chatter_group_Id__c,'Admin'); 
        Test.stopTest();
        App_Config__c configObj = [select id, Box_Access_Token__c from App_Config__c LIMIT 1];
        System.assertEquals('DummyValue', configObj.Box_Access_Token__c, 'Running as expected');
     }
     
     @isTest static void testClearBoxTokens() {   
     	String peopleId = UserContext.peopleId;
     	Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        BoxService obj = new BoxService(); 
        String response = '{"type":"folder","id":"11446498","permissions": {"can_download": true,"can_preview": true},"sequence_id":"1","etag":"1","name":"Pictures","created_at":"2012-12-12T10:53:43-08:00","modified_at":"2012-12-12T11:15:04-08:00","description":"Some pictures I took","size":629644,"path_collection":{"total_count":1,"entries":[{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"}}]},"created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"modified_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"owned_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"shared_link":{"url":"https://www.box.com/s/vspke7y05sb214wjokpk","download_url":null,"vanity_url":null,"preview_count":0,"access":"open","permissions":{"can_download":true,"can_preview":true}},"parent":{"type":"folder","id":"0","sequence_id":null,"etag":null,"name":"All Files"},"item_status":"active","item_collection":{"total_count":1,"entries":[{"type":"file","id":"5000948880","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","modified_at":"2012-12-12T11:15:04-08:00"},{"type":"folder","id":"5000948880","created_by":{"type":"user","id":"17738362","name":"sean rose","login":"sean@box.com"},"sequence_id":"3","etag":"3","sha1":"134b65991ed521fcfe4724b7d814ab8ded5185dc","name":"tigers.jpeg","modified_at":"2012-12-12T11:15:04-08:00"}],"offset":0,"limit":100}}';
        
        obj.toFileListingWrapperList(BoxWrapper.parseFolderFile(response).item_collection.entries,null,null); 
        obj.clearBoxTokens(peopleId);
        Test.stopTest();
        People_Preference__c preferenceObj = [select id, Box_User_Id__c from People_Preference__c where people__c=: peopleId limit 1];
        System.assertEquals(null, preferenceObj.Box_User_Id__c, 'Running as expected');
     }

    @isTest static void testGetFolderDetails() {            
        string[] str= new List<String>();
        str.add('Test1');
        str.add('Test2');
        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('fields',str);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',false));
        BoxService obj = new BoxService();
        obj.getFolderDetails('TestFolder','T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl',paramMap);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        Object result = obj.getFolderDetails('TestFolder','T9cE5asGnuyYCCqIZFoWjFHvNbvVqHjl',paramMap);
        Test.stopTest();
        System.assertNotEquals(ServiceConstants.UNEXPECTED_ERROR, String.valueOf(result), 'Running as expected');
     }

     @isTest static void testAddMemberIntoAllCompanyGroup() {  
        site = TestHelper.getSiteRecordWithName('BoxServiceTest');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',false));    
        BoxService obj = new BoxService();
        obj.addMemberIntoAllCompanyGroup(UserContext.id,site.Chatter_group_Id__c,true); 
        Test.stopTest();
        List<Simpplr_Metadata__c> metadataList = [select id from Simpplr_Metadata__c];
        System.assertNotEquals(0, metadataList.size(), 'Running as expected');
     }
     
    @isTest static void testLinkFolder() {  
		BoxService obj = new BoxService();
        Criteria.OwnerWrapper owner = new Criteria.OwnerWrapper();
        owner.id = '001';
        owner.name = 'newOwner';
        owner.URL = 'DummyUrl';
		Simpplr_Site__c simpplrSiteObj = TestHelper.getSiteRecordWithName('BoxServiceTest');
      Folder__c result = obj.linkFolder('Box001','Box001',owner,'',simpplrSiteObj.id ,simpplrSiteObj.chatter_group_id__c);
        System.assertEquals('Box001', result.External_Folder_Id__c,'Running as expected');
     }
     @isTest static void testUnlinkAllFolders4User() {
     	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/UserDetails',true));  
        BoxService obj = new BoxService();
        obj.unlinkAllFolders4User(UserContext.peopleId);
        obj.getBoxAdminUserTokens(false);     
        Test.stopTest();  
        List<Folder__c> folderObj = [Select Id, is_Deleted__c from Folder__c where Type__c = 'Box' and Is_System_Folder__c = false and Is_Deleted__c = false And people__c =: UserContext.peopleId];
        System.assertEquals(0, folderObj.size(), 'Running as expected');
     }

      @isTest static void testDeleteBoxFile() {  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',204,'BoxFolderFile/FolderContents',true));
        BoxService obj = new BoxService();
        Boolean result = obj.deleteBoxFile('','','Testaccess');
        Test.stopTest();
        System.assertEquals(true, result, 'Running as expected');
     }
@isTest static void testCreateGroup() {  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));

        BoxService obj = new BoxService();
        Object result = obj.createGroup('Test','','','','');
        Test.stopTest();
        System.assertNotEquals(ServiceConstants.UNEXPECTED_ERROR, String.valueOf(result),'Running as expected');
     }
    @isTest static void testAddMemberIntoGroup() {  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        BoxService obj = new BoxService();
        obj.addMemberIntoGroup('','','');
        Object result = obj.addMemberIntoGroup('123','123','test');
        Test.stopTest();
        System.assertNotEquals(ServiceConstants.UNEXPECTED_ERROR, String.valueOf(result),'Running as expected');
     }
    @isTest static void testPullCollaborationsOnFolder() {  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        BoxService obj = new BoxService();
        Object result = obj.pullCollaborationsOnFolder('','');
        obj.updateCollaboration('123','123','test');
        Test.stopTest();
        System.assertNotEquals(ServiceConstants.UNEXPECTED_ERROR, String.valueOf(result),'Running as expected');
     }
     @isTest static void testPullCollaborationsOnFolder2() {  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        BoxService obj = new BoxService();
        Object result = obj.pullCollaborationsOnFolder('123','123');
        obj.updateCollaboration('123','123','test');
        Test.stopTest();
        System.assertEquals('BoxCollaborationCollection:[entries=(BoxCollaboration:[accessible_by=null, acknowledged_at=null, created_at=null, created_by=MiniBoxUser:[enterprise=null, id=17738362, login=sean@box.com, name=sean rose, role=null, type=user], expires_at=null, id=5000948880, item=null, modified_at=2012-12-12 19:15:04, role=null, status=null, type=folder], BoxCollaboration:[accessible_by=null, acknowledged_at=null, created_at=null, created_by=MiniBoxUser:[enterprise=null, id=17738362, login=sean@box.com, name=sean rose, role=null, type=user], expires_at=null, id=5000948880, item=null, modified_at=2012-12-12 19:15:04, role=null, status=null, type=file], BoxCollaboration:[accessible_by=null, acknowledged_at=null, created_at=null, created_by=MiniBoxUser:[enterprise=null, id=17738362, login=sean@box.com, name=sean rose, role=null, type=user], expires_at=null, id=5000948880, item=null, modified_at=2012-12-12 19:15:04, role=null, status=null, type=folder]), total_count=1]', String.valueOf(result),'Running as expected');
     }
 @isTest static void testHttpFolderCallout() {  
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        BoxService obj = new BoxService();
        obj.addFolderIntoGroup('','','','');
        Object result = obj.createBoxFolder('123','123','test');
        obj.UpdateFolderName('Test','Test','Testing');
        Test.stopTest();
        System.assertNotEquals(ServiceConstants.UNEXPECTED_ERROR, String.valueOf(result),'Running as expected');
     }

    
     @isTest static void testRemoveBoxGroupMembershipIdsfromDB() {
     	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',false));
        BoxService obj = new BoxService();   
        obj.removeBoxGroupMembershipIdsfromDB();
        Test.stopTest();
        List<Simpplr_Metadata__c> metadataObjList = [select id from Simpplr_Metadata__c where User__c =: UserContext.id And type__C =: BoxConstants.BOX_MEMBERSHIP_INFO];
        System.assertEquals(0, metadataObjList.size(), 'Running as expected');
     } 
     @isTest static void testDeleteCollaborationOnBox() {  
      
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',204,'BoxFolderFile/FolderContents',true));
       
        Boolean result = BoxService.deleteCollaborationOnBox('','');
        Test.stopTest();
        System.assertEquals(true, result, 'Running as expected');
     }
     
     @isTest static void testRefreshBoxAdminUserToken() {
     	App_Config__c appConfig = SimpplrContext.appConfig;
     	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',false));
       	BoxService obj = new BoxService(); 
       	BoxWrapper.UserTokens result = obj.refreshBoxAdminUserToken(appConfig,true);
        Test.stopTest();
     	System.assertNotEquals(null, result.refreshToken,'Running as expected');
     }
     
     @isTest static void testUpdateUserTokensInDB() { 
     	BoxService obj = new BoxService(); 
     	BoxWrapper.UserTokens userTokenObj = new BoxWrapper.UserTokens();
     	userTokenObj.accessToken = 'Dummy Value';
     	userTokenObj.preferenceObjUpdated = false;
     	userTokenObj.userId = UserContext.PeopleId;
     	obj.updateUserTokensInDB(userTokenObj);
        People_Preference__c listOfUserPreference = [SELECT Id, Box_Access_Token__c from People_Preference__c where People__c=:UserContext.PeopleId limit 1];
     	System.assertEquals('Dummy Value', listOfUserPreference.Box_Access_Token__c, 'Running as expected'); 
     }
     
     @isTest static void testStoreBoxUserDetails() {
     	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',false));
     	BoxService obj = new BoxService(); 
     	People__c peopleObj = [select id from People__c limit 1];
     	obj.storeBoxUserDetails(peopleObj.id);
     	Test.stopTest();
        People_Preference__c preferenceObj = [select id, Box_Enterprise_Id__c from People_Preference__c where People__c =:peopleObj.Id limit 1];
     	System.assertEquals('17077211', preferenceObj.Box_Enterprise_Id__c, 'Running as expected'); 
     } 
     
     @isTest static void testStoreBoxAdminDetails() {
     	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',false));
     	BoxService obj = new BoxService(); 
     	obj.storeBoxAdminDetails();
     	Test.stopTest();
        App_Config__c configObj = [select id, Box_Enterprise_Id__c from App_Config__c limit 1];
     	System.assertEquals('17077211', configObj.Box_Enterprise_Id__c, 'Running as expected'); 
     } 
     
      @isTest static void testRemoveMemberFromGroup() {  
      
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',false));
        BoxService obj = new BoxService();     
       
        obj.removeMemberFromGroup('','');
        Object result = obj.removeMemberFromGroup('','');
        obj.getMembershipsIdForGroup('','','');
        Test.stopTest();
        System.assertEquals('SUCCESS WITH NO RESPONSE', String.valueOf(result),'Running as expected');
     }
    
    @isTest static void deLinkBoxFolder() {  
		Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        Simpplr_Site__c site = [select id from Simpplr_Site__c where Name =: 'BoxServiceTest'];
        BoxService obj = new BoxService();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',false));
        String result = obj.deLinkBoxFolder(folderObj.id,site.id);
        Test.stopTest();
        System.assertEquals('SUCCESS', result, 'Running as expected');
     }
}