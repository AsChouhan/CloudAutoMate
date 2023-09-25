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
private class FileDataServerTest {
	private static App_Config__c appConfigRecord;
	private static simpplr_content__c content;
	private static Simpplr_Site__c site;
	private static Simpplr_Site__c eSite;
	private static Simpplr_Site__c googleDriveSite;
	private static User standardUserObj;
	private static User managerUserObj;
    private static Folder__c intranetSourceFolderObj;
    private static Folder__c intranetDestinationFolderObj;
    private static File__c intranetFileObj;
	
    @testSetup static void setup() {
    	
    	App_Config__c appConfig = TestHelper.setupAppConfig();
        appConfig.Box_Managed_Permissions__c = 'simpplr';
        update appConfig;
		managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false); 
		standardUserObj = TestHelper.createUser('Simpplr_usr', managerUserObj, false); 
        
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
        People_Preference__c prefObj = TestHelper.createPeoplePreference(peopleObj.id);
		        		
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'googledrive', 'dropbox', 'sharepoint', 'onedrive'});
		List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, peopleObj.id,'asdqdqwedwe');
        for(People_Integration__c pInt :peopleIntList) {
			if('sharepoint'.equalsIgnoreCase(pInt.name)) {
                pInt.SP_Instance_Id__c = 'testInstance';
            }  
        }

        update peopleIntList;
		  
		CollaborationGroup collGrp = TestHelper.createCollaborationGroup('FileDataServerTest_googleDriveSite', 'Public');         
		googleDriveSite = [select id,File_Storage_Source__c,chatter_group_Id__c from Simpplr_Site__c where chatter_group_Id__c =: collGrp.id limit 1];

		googleDriveSite.File_Storage_Source__c = 'googledrive';
    	update googleDriveSite;
		
		// googledrive System Folder must exist with 'googledrivetestid'
		Folder__c folderObj = TestHelper.createChatterFolder('Google Drive Files', null, googleDriveSite.Id, 'googledrive', null, null);
		folderObj.Is_System_Folder__c = true;
		folderObj.External_Folder_Id__c = 'googledrivetestid';
		update folderObj;
  
		collGrp = TestHelper.createCollaborationGroup('FileDataServerTest_grp1', 'Public');
		site = [select id,File_Storage_Source__c,chatter_group_Id__c from Simpplr_Site__c where chatter_group_Id__c =: collGrp.id limit 1];
        intranetSourceFolderObj = TestHelper.createChatterFolder('Source intranet folder', null, site.id, 'Intranet', null, 'readwrite');
        intranetDestinationFolderObj = TestHelper.createChatterFolder('Destination intranet folder', null, site.id, 'Intranet', null, 'readwrite');
        String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' +site.id+ '#' + intranetSourceFolderObj.Id + '#' + 'intranetDummyfile.png';
    	ContentVersion contVerObj = TestHelper.createContentVersion('dummy', pathOnClient);
		List<ContentDocument> ContentDocumentList = [select Id from ContentDocument where latestpublishedversionId=:contVerObj.id];
        intranetFileObj = TestHelper.createFile('intranet Dummy file', site.id, intranetSourceFolderObj.id);
        intranetFileObj.Content_Version__c = contVerObj.id;
        intranetFileObj.Content_Document__c = ContentDocumentList[0].id;
        update intranetFileObj;
		// Set up for testing external file storages
		CollaborationGroup extCG = TestHelper.createCollaborationGroup('FileDataServerTestExternal', 'Public');    	
		Simpplr_Site__c siteObj = getSimpplrSite('FileDataServerTestExternal');
		TestHelper.shareSitesToAllPeople(new List<String>{site.Id, googleDriveSite.Id, siteObj.Id});
        Simpplr_Content__c contentObj = TestHelper.createContent('simpplr test BlogPost', 'BlogPost', 'Approved',standardUserObj, null); 
        if(content == null){
	        System.runAs(standardUserObj) {
	        	content = new Simpplr_Content__c(
	                            Title__c='testArticleRecord', 
	                                Text_Intro__c='Example text', 
	                                Text_Main__c='Example text',
	                                Text_Main_Continued__c=' example text ',
	                                Type__c='Page', 
	                                Status__c='submitted', 
	                                Site__c = site.id
	                                );
	        	insert content;
	        }    
        }
        
        ContentVersion cvObj = TestHelper.createContentVersion('C');
        ContentVersion contentVersionObj = TestDataHandler.createContentVersion('H');
        Simpplr_Metadata__c metdataObj = new Simpplr_Metadata__c();
        metdataObj.User__c = UserContext.Id;
        metdataObj.Type__c = 'BOX_ADMIN_GROUP_ID';
        metdataObj.Simpplr_Site__c = site.id;
        insert metdataObj;
        site.Is_Deleted__c = false;
        update site;
        folderObj = TestHelper.createChatterFolder('Box Files', null, site.Id, 'Box', null, 'read');
        folderObj.Is_System_Folder__c = true;
        folderObj.is_deleted__c=false;
        update folderObj;
		Bookmark__c bookmarkObj =  TestHelper.createContentBookmark(content.id, UserContext.peopleId);
		File__c fileObj = TestHelper.createContentTitleImage(content.Id);
		fileObj.Content_Version__c = contentVersionObj.id;
		update fileObj;
        bookmarkObj.Type__c='Box';  
        bookmarkObj.Is_Deleted__c = false;
        bookmarkObj.External_File_Id__c = folderObj.id;
        update bookmarkObj;

        Folder__c folder = TestHelper.createChatterFolder('Test Folder 12345', null, siteObj.id, 'googledrive', 'googledrive', null);
        folder.Drive_Type__c = 'shareddrive';
        folder.Is_System_Folder__c = false;
        folder.External_Folder_Id__c = '12345';
        update folder; 

    	System.assertEquals('shareddrive', folder.Drive_Type__c, 'Running as expected');
    }
    
    
    static void init() {
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        
        managerUserObj = [select Id, lastName from user where lastname like 'Simpplr_mngr%'][0];
        site = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='FileDataServerTest_grp1'][0];
    }
    
    static void initExternal() {		
        managerUserObj = [select Id, lastName from user where lastname like 'Simpplr_mngr%'][0];
        
        eSite = getSimpplrSite('FileDataServerTestExternal');

		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('siteId', eSite.id);
    }
 
    private static Simpplr_Site__c getSimpplrSite(string siteName){
    	 return([select id, chatter_group_id__c,File_Storage_Source__c from Simpplr_Site__c where name = :siteName]);
    }
 
 	private static void setIntegrationsConnected(String storage, Boolean connectFlag) {
 		App_Integration__c eAppInteg = SimpplrContext.Integrations.get(storage);
 		eAppInteg.Integration_Enabled__c = true;
 		eAppInteg.Connected__c = connectFlag;
 		update eAppInteg;
 		
 		List<People_Integration__c> pplList = new List<People_Integration__c>();
 		for(People_Integration__c pplObj : [Select Id, Name, Connected__c FROM People_Integration__c WHERE name=:storage]) {
 			pplObj.Connected__c = connectFlag;
 			pplList.add(pplObj);
 		}
 		
 		update pplList;
 	}   
 	
    @isTest static void testHandleRequestWhenActionNull() {
    	init();
    	FileDataServer dSObj= new FileDataServer();
        //PageReference pageRef = Page.FileDataServer;
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
    }
    
    @isTest static void testHandleRequestWhenActiongoogledrive() {
    	Simpplr_Site__c site = getSimpplrSite('FileDataServerTest_grp1');
       	site.File_Storage_Source__c = 'googledrive';
        update site;
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));
    		
    	Folder__c siteFold = TestHelper.createChatterFolder('Test Folder', null, site.id, 'googledrive', 'googledrive', null);
    	siteFold.Is_System_Folder__c = true;
    	siteFold.External_Folder_Id__c = '12345';
    	update siteFold; 
    		
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
        
        // site files -- googledrive
    	pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + site.id + '","term":"gdrive","directory":null,"provider":"googledrive","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'FileDataServer/googledrive',false));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');   
        
        pageRef.getParameters().put('data','{"provider":"googledrive","pageName":"myfiles","filter":"favorites"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + site.id + '","term":"","directory":null,"provider":"googledrive","owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        // my files -- grive
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"'+ site.id + '" ,"term":"abc","directory":null,"provider":"googledrive","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"my_files"}');
        dSObj.handleRequest();

        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"googledrive","owner":"all","filter":null,"type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        pageRef.getParameters().put('data','{"size":16,"siteId":"'+ site.id + '" ,"term":"","directory":null,"provider":"googledrive","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"googledrive","owner":"all","filter":null,"type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        pageRef.getParameters().put('data','{"size":16,"driveType":"mydrive","siteId":"' + site.id + '","provider":"googledrive","directory":"dummy","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
         
    @isTest static void testHandleRequestWhenActionAvailable1() {
		Test.startTest();
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');        
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"Intranet","pageName":"siteFiles"}');
		FileDataServer dSObj= new FileDataServer();
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"CRM","pageName":"siteFiles"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"dropbox","pageName":"siteFiles"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"CRM","pageName":"sitealbumdetail"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"Intranet","pageName":"myfiles"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"dropbox","pageName":"myfiles"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"Intranet","pageName":"myfiles","filter":"favorites"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('origin','mobile');
        pageRef.getParameters().put('data','{"provider":"Intranet","pageName":"myfiles","filter":"favorites"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"BOX","pageName":"myfiles","filter":"favorites"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"CRM","pageName":"myfiles","filter":"favorites"}');
		dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"provider":"CRM","pageName":"myfiles","filter":"native_video"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testCreateFolder() {
     	App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
        Simpplr_Site__c site = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='FileDataServerTest_grp1'][0];
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        SiteContext.isPublicSite = true;
		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_CREATE_BOX_FOLDER);
        pageRef.getParameters().put('data','{"name":"box","siteId":"'+site.id+'","permissions":"read"}');
        ApexPages.currentPage().getParameters().put('siteId',siteId);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testGetBookmarkedFiles() {
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.External_Folder_Id__c = folderObj.id;
        folderObj.Is_System_Folder__c = false;
        update folderObj;
        Simpplr_Site__c site = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='FileDataServerTest_grp1'][0];
        PageReference pageRef = Page.DataServerRO;
		FileDataServer dSObj= new FileDataServer();
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
		Criteria.File fileCriteriaObj = new Criteria.File();
    	fileCriteriaObj.siteId = site.id;
    	fileCriteriaObj.term = 'newTerm';
		fileCriteriaObj.provider = 'box';
        fileCriteriaObj.filter = 'bookmarked';
        fileCriteriaObj.offset = 0;
        fileCriteriaObj.size = 0;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContent',false));
		dSObj.getMyBoxFiles(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
    }
    
    @isTest static void testSearchFiles() {
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
        Simpplr_Site__c site = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='FileDataServerTest_grp1'][0];
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.External_Folder_Id__c = folderObj.id;
        folderObj.Is_System_Folder__c = false;
        update folderObj;
        PageReference pageRef = Page.DataServerRO;
		FileDataServer dSObj= new FileDataServer();
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
		Criteria.File fileCriteriaObj = new Criteria.File();
    	fileCriteriaObj.siteId = site.id;
    	fileCriteriaObj.term = 'newTerm';
		fileCriteriaObj.provider = 'box';
        fileCriteriaObj.filter = '';
        fileCriteriaObj.offset = 0;
        fileCriteriaObj.size = 0;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',false));
		dSObj.getMyBoxFiles(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
	 }	 
    
    
    @isTest static void testDeleteFile() {
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.External_Folder_Id__c = folderObj.id;
        update folderObj;
        Simpplr_Site__c site = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='FileDataServerTest_grp1'][0];
        PageReference pageRef = Page.DataServerRO;
		FileDataServer dSObj= new FileDataServer();
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        Criteria.FileDeleteParams deleteFolderCriteriaObjArg=new Criteria.FileDeleteParams();
		deleteFolderCriteriaObjArg.fileId=(new List<String>{folderObj.id});
    	deleteFolderCriteriaObjArg.provider='box';
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',204,'Box/FileDetails',false));
		dSObj.deleteFile(deleteFolderCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
     }
    
    @isTest static void testPullBoxUserToken() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
		update appConfig;
		BoxDao bObj = new BoxDao();
		PageReference pageRef = Page.DataServerRW;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',true));
        bObj.pullBoxUserToken('access_token');
        List <People_Preference__c> listOfUserPreference = [select id,Box_Access_Token__c from People_Preference__c where People__c =:UserContext.peopleId];
        system.assertNotEquals(null, listOfUserPreference[0].Box_Access_Token__c, 'access token should not be null');
        Test.stopTest();
     }
    
    @isTest static void testGetBoxAdminUserTokens() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        appConfig.Box_Access_Token_Expires_At__c = DateTime.now().addHours(-1);
		update appConfig;
        BoxWrapper.UserTokens userTokensObj = new BoxWrapper.UserTokens();
		BoxDao bObj = new BoxDao();
		PageReference pageRef = Page.DataServerRW;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',true));
        userTokensObj = bObj.getBoxAdminUserTokens(true);   
        system.assertEquals(appConfig.Box_User_Id__c, userTokensObj.boxUserId, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testAutoComplete() {
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
        Simpplr_Site__c site = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='FileDataServerTest_grp1'][0];
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.External_Folder_Id__c = folderObj.id;
        folderObj.Is_System_Folder__c = false;
        update folderObj;
        PageReference pageRef = Page.DataServerRO;
		FileDataServer dSObj= new FileDataServer();
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        Criteria.File fileCriteriaObj = new Criteria.File();
    	fileCriteriaObj.siteId = site.id;
    	fileCriteriaObj.term = 'newTerm';
		fileCriteriaObj.provider = 'box';
        fileCriteriaObj.filter = '';
        fileCriteriaObj.fullText = true;
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',false));
        dSObj.autoComplete(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testDeleteFolder() {
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.External_Folder_Id__c = folderObj.id;
        update folderObj;
        Simpplr_Site__c site = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='FileDataServerTest_grp1'][0];
        PageReference pageRef = Page.DataServerRO;
		FileDataServer dSObj= new FileDataServer();
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        Criteria.FolderDeleteParams deleteFolderCriteriaObjArg=new Criteria.FolderDeleteParams();
		deleteFolderCriteriaObjArg.folderId=(new List<String>{folderObj.id});
    	deleteFolderCriteriaObjArg.provider='box';
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',204,'Box/FileDetails',false));
		dSObj.deleteFolder(deleteFolderCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
     }
    

    
    @isTest static void testResetCurrentUserBoxAccessToken() {
     	App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
		update appConfig;
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.Permissions__c = 'readwrite';
        update folderObj;
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		pageRef.getParameters().put('action','resetCurrentUserBoxAccessToken');
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testGetSiteBoxFiles() {
     	App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
		update appConfig;
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.Permissions__c = 'readwrite';
        folderObj.is_System_Folder__c = false;
        folderObj.People__c = UserContext.PeopleId;
        update folderObj;
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		pageRef.getParameters().put('siteId',siteId);
        Criteria.File fileCriteriaObjArg= new Criteria.File();
    	fileCriteriaObjArg.siteId=siteId;
    	fileCriteriaObjArg.filter='write_folders';
    	fileCriteriaObjArg.provider='box';
        fileCriteriaObjArg.offset=0;
        fileCriteriaObjArg.sortBy='createdNewest';
        fileCriteriaObjArg.size=1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/UserDetails',true));
        dSObj.getSiteBoxFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testGetContentsAssociatedToFolder() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
		update appConfig;
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":null,"directory":"random","provider":"box","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files","rootDirectory":"1"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testGetContentsAssociatedToFolderwhenTerm() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
		PageReference pageRef = Page.DataServerRO;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		Simpplr_Site__c site = getSimpplrSite('FileDataServerTest_grp1');
        site.File_Storage_Source__c = 'box';
        update site;
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + site.id + '","fullText":false,"term":"newTerm","directory":"random","provider":"box","isMediaManager":true,"owner":"all","filter":"write_folders","type":null,"encodedSearchText":"site_files"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
	}
	 
	@isTest static void testGetContentsAssociatedToFolderwhenTermGD() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
        Folder__c folderId = [Select id From Folder__c where Name__c =: 'Google Drive Files'];
        folderId.Is_System_Folder__c = false;
		update folderId;
		PageReference pageRef = Page.DataServerRO;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","fullText":false,"term":"newTerm","directory":"random","provider":"box","isMediaManager":true,"owner":"all","filter":"write_folders","type":null,"encodedSearchText":"site_files"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGet() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
		update appConfig;
        Folder__c folderId = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderId.External_Folder_Id__c = '1';
		update folderId;
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('siteId',siteId);
        pageRef.getParameters().put('data','{"size":16,"fileId":"' + folderId.id + '","provider":"box","rootDirectory":"1"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/FileDetails',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testGetwhensiteisBlank() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
		update appConfig;
        Folder__c folderId = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderId.External_Folder_Id__c = folderId.id;
		update folderId;
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('data','{"size":16,"fileId":"' + folderId.id + '","provider":"box","rootDirectory":"' + folderId.id + '"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/FileDetails',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    
    @isTest static void getVersionHistoryGoogleDrive() {
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();	  	
		pageRef.getParameters().put('action','getVersionHistory');
        pageRef.getParameters().put('data','{"provider":"googledrive","fileId":"dummy"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'googledrive/FileVersion',true));
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        dSObj.handleRequest();
        Test.stopTest();
	 } 
    
     @isTest static void getVersionHistoryBox() {
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();	  	
		pageRef.getParameters().put('action','getVersionHistory');
        pageRef.getParameters().put('data','{"provider":"box","fileId":"dummy"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'/FileVersion',true));
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        dSObj.handleRequest();
        Test.stopTest();
	 }

    @isTest static void testGetDownloadUrl() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;
		Folder__c folderId = [Select id From Folder__c where Name__c =: 'Box Files'];
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		pageRef.getParameters().put('action','getDownloadUrl');
        pageRef.getParameters().put('data','{"versionId":"testversionId","fileId":"'+folderId.id+'"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',302,'BoxFolderFile/FolderContents',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testSetDescription() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
		update appConfig;
		Folder__c folderId = [Select id From Folder__c where Name__c =: 'Box Files'];
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		pageRef.getParameters().put('action','setDescription');
        pageRef.getParameters().put('data','{"provider":"box","description":"ANewFile","fileId":"'+folderId.id+'"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
	 }
	 
	 @isTest static void testSetFolderNameOfGoogleDrive() {
		Simpplr_Site__c siteObj = new Simpplr_Site__c(
			name = 'testSite',
			Is_Active__c = true
		);
		insert siteObj;

		Folder__c folder = new folder__c(
			name = 'test',
			External_Folder_Id__c = 'asdfghjkl123',
			Drive_Type__c = 'shareddrive',
            Type__c = 'googledrive',
			site__c = siteObj.id
		);
		insert folder;
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
		pageRef.getParameters().put('action','setFolderName');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		pageRef.getParameters().put('data','{"provider":"googledrive","siteId":"'+siteObj.id+'","name":"FolderNewName","folderId":"'+folder.External_Folder_Id__c+'"}');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'rename',false));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Failed: Rename google drive folder');

        Folder__c folderRenamed = [SELECT Id, Name__c FROM Folder__c WHERE External_Folder_Id__c=:folder.External_Folder_Id__c LIMIT 1];
        System.assertEquals('FolderNewName', folderRenamed.Name__c, 'Failed: Rename google drive folder');
        Test.stopTest();
     }

	 @isTest static void testSetFolderName() {
		App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
		update appConfig;
		Folder__c folderId = [Select id From Folder__c where Name__c =: 'Box Files'];
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		pageRef.getParameters().put('action','setFolderName');
        pageRef.getParameters().put('data','{"provider":"box","name":"ANewFile","folderId":"'+folderId.id+'"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',true));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
     }
    
    @isTest static void testHandleRequestWhenActionAvailable2() {
		Test.startTest();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Folder__c folderId = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderId.External_Folder_Id__c = folderId.id;
        folderId.type__c = 'Intranet';
        update folderId;
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' +siteId+ '#' + folderId.Id + '#' + 'dummyfile.png';
    	ContentVersion cvObj = TestHelper.createContentVersion('nvcjdnvjfnvjnfdkjvnfHVGVGDXnkjckjdnvjndn6347hcbchdbc', pathOnClient);
		List<ContentDocument> ContentDocumentList = [select Id from ContentDocument where latestpublishedversionId=:cvObj.id];
        pageRef.getParameters().put('siteId',siteId);
        Test.setCurrentPage(pageRef);
    
		FileDataServer dSObj= new FileDataServer();
    	pageRef.getParameters().put('action',dSObj.ACTION_VALUE_CREATE_CHATTER_FOLDER);
        pageRef.getParameters().put('data','{"directory":"'+folderId.id+'"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_BOX_LINKABLE_FOLDERS);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_LINK_BOX_FOLDER);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_UNLINK_BOX_FOLDER);
        pageRef.getParameters().put('data','{"folderId":"'+folderId.id+'"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_CREATE_BOX_FOLDER);
        pageRef.getParameters().put('data','{"name":"box"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_SET_DESCRIPTION);
        pageRef.getParameters().put('data','{"provider":"box"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_SET_FOLDER_NAME);
        pageRef.getParameters().put('data','{"provider":"box"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_SET_FOLDER_NAME);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_DELETE_FILE);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_DELETE_FOLDER);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_VERSION_HISTORY);
        pageRef.getParameters().put('data','{"fileId":"'+ContentDocumentList[0].id+'"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_BOX_DOWNLOAD_URL);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_BOX_ACCESS_TOKEN);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_RESET_BOX_ACCESS_TOKEN);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_LINK_SHAREPOINT_FOLDER);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_LINK_ONEDRIVE_FOLDER);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_UNLINK_ONEDRIVE_FOLDER);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_UNLINK_SHAREPOINT_FOLDER);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_UNLINK_SHAREPOINT_FOLDER); 
        pageRef.getParameters().put('data','{}');
		dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
		
		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_LINK_GOOGLE_DRIVE_FOLDER); 
        pageRef.getParameters().put('data','{}');
		dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_UNLINK_GOOGLE_DRIVE_FOLDER); 
        pageRef.getParameters().put('data','{}');
		dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
		
		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_CREATE_GOOGLE_FOLDER); 
        pageRef.getParameters().put('data','{}');
		dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
		
		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_GOOGLE_DRIVE_ACCESS_TOKEN); 
        pageRef.getParameters().put('data','{}');
		dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
		
		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_RESET_GOOGLE_DRIVE_ACCESS_TOKEN); 
        pageRef.getParameters().put('data','{}');
		dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
		
		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_GOOGLE_DRIVE_FOLDERS); 
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_EFS_FOLDERS);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_CREATE_EFS_FOLDER);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_UNLINK_CRM_FOLDER);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_SHAREPOINT_SITE_ITEM_LIST);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

		pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_ONEDRIVE_SITE_ITEM_LIST);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        // invalid action 
        pageRef.getParameters().put('action','invalid_action');
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
		Test.stopTest();
    }
    
    @isTest static void testRemoveFile() {
        Test.startTest();
        Simpplr_Content__c contentObj = [Select Id From Simpplr_Content__c Limit 1];
        Simpplr_Site__c siteObj = [Select Id From Simpplr_Site__c Limit 1];
        File__c  fileObj = TestHelper.createContentTitleImage(contentObj.Id);
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        
        Test.setCurrentPage(pageRef);
        FileDataServer dSObj= new FileDataServer();
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_REMOVE_FILE);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_REMOVE_FILE);
        pageRef.getParameters().put('data','{"fileId":["'+fileObj.Id+'"],"provider":"intranet","fileSiteId":"'+siteObj.Id+'"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        SimpplrContext.isNativeVideo = true;
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_REMOVE_FILE);
        pageRef.getParameters().put('data','{"fileId":["'+fileObj.Id+'"],"provider":"native_video","fileSiteId":"'+siteObj.Id+'"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestSetFolderPermissions() {
		Test.startTest();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_SET_FOLDER_PERMISSIONS);
        pageRef.getParameters().put('data','{}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data','{"provider":"box"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        pageRef.getParameters().put('data','{"provider":"googledrive","permissions":"read"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data','{"provider":"dropbox"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
		Test.stopTest();
    }
    
    @isTest static void testGetMySFDCFiles(){
		Test.startTest();
    	init(); 
        Simpplr_Site__c site = getSimpplrSite('FileDataServerTest_grp1');
        ContentVersion contentVersionObj = TestHelper.createContentVersion('developer', 'File_01');
        Simpplr_Content__c albumContent = TestHelper.createContent('FileDataServerTest_testAlbumRecord', 'Album', 'Approved', managerUserObj, site);     
        File__c fileObj = TestHelper.createContentTitleImage(albumContent.Id);
        fileObj.Content_Version__c = contentVersionObj.id;
        update fileObj;
    	FileDataServer dSObj= new FileDataServer();
    	Criteria.File fileCriteriaObjArg= new Criteria.File();
    	fileCriteriaObjArg.nextPageToken='10';
    	fileCriteriaObjArg.filter='owned';
    	fileCriteriaObjArg.provider='Intranet';
    	fileCriteriaObjArg.context='feed';
    	fileCriteriaObjArg.pageName='myfiles';
        fileCriteriaObjArg.fileId=fileObj.id;
        fileCriteriaObjArg.owner = managerUserObj.id;
        fileCriteriaObjArg.siteId = site.id;
    	
    	dSObj.getMyFilesIntranetFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.filter='shared';
    	dSObj.getMyFilesIntranetFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.filter='bookmarked';
    	dSObj.getMyFilesIntranetFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.nextPageToken='Errorvalue';
    	dSObj.getMyFilesIntranetFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.filter='Random';
    	dSObj.getMyFilesIntranetFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
    	
    }
    
    @isTest static void testGetSiteCRMFiles (){
		Test.startTest();
    	init();
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'testArticleRecord'];
        update content;
        File__c fileObj =  TestHelper.createContentTitleImage(content.id);
        update fileObj;
        String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' +siteId+ '#' + fileObj.Id + '#' + 'dummyfile.png';
	 	ContentVersion cvObj = TestHelper.createContentVersion('nvcjdnvjfnvjnfdkjvnfHVGVGDXnkjckjdnvjndn6347hcbchdbc', pathOnClient);
	 	List<ContentDocument> ContentDocumentList = [select Id,title from ContentDocument where latestpublishedversionId=:cvObj.id];
        ContentDocumentList[0].title = 'Random';
        update ContentDocumentList[0];
        Bookmark__c bookmarkObj =  TestHelper.createContentBookmark(content.id, UserContext.peopleId);
        bookmarkObj.Type__c='Intranet';  
        bookmarkObj.Is_Deleted__c = false;
        bookmarkObj.External_File_Id__c = ContentDocumentList[0].id;
        update bookmarkObj;
	 	ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace limit 1];
	 	ContentWorkspaceDoc newWorkspaceDoc =new ContentWorkspaceDoc();
	 	newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
	 	newWorkspaceDoc.ContentDocumentId = ContentDocumentList[0].id;
        insert newWorkspaceDoc;

        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.External_Folder_Id__c=testWorkspace.id;
        folderObj.type__c='CRM';
        update folderObj;

    	FileDataServer dSObj= new FileDataServer();
    	Criteria.File fileCriteriaObjArg= new Criteria.File();
        fileCriteriaObjArg.fullText = true;
        fileCriteriaObjArg.sortBy='createdNewest';
    	fileCriteriaObjArg.nextPageToken='10';
    	fileCriteriaObjArg.filter='owned';
        fileCriteriaObjArg.directory=ContentDocumentList[0].id;
        fileCriteriaObjArg.siteID=siteId;
    	fileCriteriaObjArg.provider='box';
    	fileCriteriaObjArg.context='feed';
    	fileCriteriaObjArg.pageName='myfiles';
    	fileCriteriaObjArg.term='Random';
        fileCriteriaObjArg.offset=0;
        fileCriteriaObjArg.size= 0;
    	dSObj.getSiteCRMFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.filter='shared';
    	dSObj.getSiteCRMFiles(fileCriteriaObjArg);    	
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.nextPageToken='Errorvalue';
    	dSObj.getSiteCRMFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.filter='Random';
        dSObj.getSiteCRMFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();    	
    }
    
    
    
    
    
    @isTest static void testGetMedia (){
    	init();
    	FileDataServer dSObj= new FileDataServer();
    	Criteria.File fileCriteriaObjArg= new Criteria.File();
    	fileCriteriaObjArg.nextPageToken='10';
    	fileCriteriaObjArg.filter='owned';
    	fileCriteriaObjArg.provider='box';
    	fileCriteriaObjArg.context='feed';
    	fileCriteriaObjArg.pageName='myfiles';
    	
    	dSObj.getMedia(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.filter='shared';
    	dSObj.getMedia(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.filter='bookmarked';
    	dSObj.getMedia(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.filter='photo';
    	dSObj.getMedia(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.filter='video';
    	dSObj.getMedia(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.nextPageToken='Errorvalue';
    	dSObj.getMedia(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.filter='Random';
    	dSObj.getMedia(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');    	
    }
    
    //new
    
    @isTest static void testGetSiteChatterFoldersAndFiles (){
        Test.startTest();
    	init();
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        Folder__c folderObj = [Select id From Folder__c where Name__c =: 'Box Files'];
        folderObj.Name__c = 'Feed Files';
        folderObj.External_Folder_Id__c = folderObj.id;
        folderObj.Is_System_Folder__c = false;
        folderObj.Site__c = siteId;
        folderObj.Type__c = 'Intranet';
        folderObj.path__c = folderObj.id;
        folderObj.Is_Hidden__c = false;
        folderObj.Permissions__c='readwrite';
        update folderObj;
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'testArticleRecord'];
        String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' + site.Id + '#' + '#' + 'dummyfile.png';
    	ContentVersion cvObj = TestHelper.createContentVersion('nvcjdnvjfnvjnfdkjvnfHVGVGDXnkjckjdnvjndn6347hcbchdbc', pathOnClient);
		List<ContentDocument> ContentDocumentList = [select Id from ContentDocument where latestpublishedversionId=:cvObj.id];
        File__c fileObj =  TestHelper.createContentTitleImage(content.id);
        fileObj.Is_Deleted__c = false;
        fileObj.Content_Document__c = ContentDocumentList[0].id;
        fileObj.Folder__c = folderObj.id;
        update fileObj;
    	FileDataServer dSObj= new FileDataServer();
    	Criteria.File fileCriteriaObjArg= new Criteria.File();
        fileCriteriaObjArg.term=null;
        fileCriteriaObjArg.directory=null;
    	fileCriteriaObjArg.filter='owned';
    	fileCriteriaObjArg.provider='box';
    	fileCriteriaObjArg.context='feed';
    	fileCriteriaObjArg.pageName='myfiles';
      
    	dSObj.getSiteChatterFoldersAndFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.filter='shared';
    	dSObj.getSiteChatterFoldersAndFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	folderObj.Is_System_Folder__c = true;
		update folderObj;
		fileCriteriaObjArg.directory=folderObj.id;
		fileCriteriaObjArg.filter='write_folders';
    	dSObj.getSiteChatterFoldersAndFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    
    	fileCriteriaObjArg.filter='bookmarked';
    	dSObj.getSiteChatterFoldersAndFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.filter='photo';
    	dSObj.getSiteChatterFoldersAndFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.filter='video';
    	dSObj.getSiteChatterFoldersAndFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	fileCriteriaObjArg.nextPageToken='Errorvalue';
    	dSObj.getSiteChatterFoldersAndFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	fileCriteriaObjArg.filter='Random';
		dSObj.getSiteChatterFoldersAndFiles(fileCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    	
    }
    
    @isTest static void testFileFolderOperationsIntranet(){
        Test.startTest();
    	init();
    	FileDataServer dSObj= new FileDataServer();
    	Criteria.Folder folderCriteriaObjArg= new Criteria.Folder();
    	folderCriteriaObjArg.directory=null;
    	folderCriteriaObjArg.rootDirectory=null;
    	folderCriteriaObjArg.name='dummyfolder';
    	folderCriteriaObjArg.permissions='readwrite';
    	folderCriteriaObjArg.siteId=site.id;
    	
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('siteId', site.id);
        Test.setCurrentPage(pageRef);
    	ResponseWrapper resp = dSObj.createChatterFolder(folderCriteriaObjArg);		
    	List<Folder__c> folderList = [SELECT id FROM Folder__c WHERE is_system_folder__c = false AND Site__c=:site.id LIMIT 1];
    	
    	if(!folderList.isEmpty()){
            Map<String, String> folderRenameRequestDataMap = new Map<String, String>();
    		folderRenameRequestDataMap.put('folderId', folderList[0].Id);
    		folderRenameRequestDataMap.put('provider', 'Intranet');
    		folderRenameRequestDataMap.put('name', 'NewName');
    		
    		dSObj.setFolderName(folderRenameRequestDataMap);
            System.assertEquals('success', dSObj.response.status, 'Running as expected');
    		
            String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' + site.Id + '#' + folderList[0].Id + '#' + 'dummyfile.png';
    		ContentVersion cvObj = TestHelper.createContentVersion('nvcjdnvjfnvjnfdkjvnfHVGVGDXnkjckjdnvjndn6347hcbchdbc', pathOnClient);
            List<ContentDocument> ContentDocumentList = [select Id from ContentDocument where latestpublishedversionId=:cvObj.id];
            File__c fileObj = TestHelper.createFile('new file', site.id, folderList[0].Id);
            fileObj.Content_Document__c = ContentDocumentList[0].id;
        	update fileObj;
    		Map<String, String> fileDescriptionRequestDataMap = new Map<String, String>();
    		fileDescriptionRequestDataMap.put('fileId', ContentDocumentList[0].Id);
    		fileDescriptionRequestDataMap.put('provider', 'Intranet');
    		fileDescriptionRequestDataMap.put('description', 'This is a new description');
    		
    		dSObj.setFileDescription(fileDescriptionRequestDataMap);
            System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        	Map<String, String> filePublicUrlRequestDataMap = new Map<String, String>();
    		filePublicUrlRequestDataMap.put('fileId', fileObj.Id);   		
    		dSObj.getPublicUrl(filePublicUrlRequestDataMap);
            System.assertEquals('success', dSObj.response.status, 'Running as expected');

            Criteria.FileDeleteParams deleteFileCriteriaObj = new Criteria.FileDeleteParams();
    		deleteFileCriteriaObj.fileId  = new List<String>{ContentDocumentList[0].id};
    		deleteFileCriteriaObj.provider  = 'intranet';		
    		dSObj.deleteFile(deleteFileCriteriaObj);
            System.assertEquals('success', dSObj.response.status, 'Running as expected');
    		
            String req = JSON.serialize(resp.result);
            FileListingWrapper requestMap = (FileListingWrapper)JSON.deserialize(req, FileListingWrapper.class);
    		Criteria.FolderDeleteParams deleteFolderCriteriaObjArg=new Criteria.FolderDeleteParams();
    		deleteFolderCriteriaObjArg.folderId=(new List<String>{requestMap.Id});
	    	deleteFolderCriteriaObjArg.provider='intranet';	
    		dSObj.deleteFolder(deleteFolderCriteriaObjArg);
            System.assertEquals('success', dSObj.response.status, 'Running as expected');       
        }
        Test.stopTest();
    }

    @isTest static void testFileFolderOperationsgoogledrive(){
    	initExternal();
        // soft delete existing shared drive folder to validate link 
        Folder__c sharedFolder = [SELECT Id, Is_Deleted__c FROM Folder__c WHERE Drive_Type__c='shareddrive' AND Site__c=:eSite.id LIMIT 1];
        sharedFolder.Is_Deleted__c = true;
        update sharedFolder;

    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive')); 	
        
    	// File Instance
    	FileDataServer dSObj= new FileDataServer();
    	
    	// Input Folder
    	Criteria.Folder folderCriteriaObjArg= new Criteria.Folder();
    	folderCriteriaObjArg.directory='googledrivetestid';
    	folderCriteriaObjArg.rootDirectory=null;
    	folderCriteriaObjArg.name='TestCreateFolder';
    	folderCriteriaObjArg.permissions = 'readwrite';
    	folderCriteriaObjArg.siteId = eSite.id;
    	
    	// Create New Folder
    	ResponseWrapper resp = dSObj.createGoogleFolder(folderCriteriaObjArg);
		System.assertEquals('success', resp.status, 'Failed: create google drive folder');

		// Folder Rename
   		Map<String, String> folderRenameRequestDataMap = new Map<String, String>();
    	folderRenameRequestDataMap.put('folderId', 'googledrivefolderexternalid');
    	folderRenameRequestDataMap.put('provider', 'googledrive');
    	folderRenameRequestDataMap.put('name', 'TestRenameFolder');
    		
		//dSObj.setFolderName(folderRenameRequestDataMap);

		// Folder Deletion
		Criteria.FolderDeleteParams deleteFolderCriteriaObjArg=new Criteria.FolderDeleteParams();
		deleteFolderCriteriaObjArg.folderId=(new List<String>{'googledrivefolderexternalid'});
    	deleteFolderCriteriaObjArg.provider='googledrive';
    	
		resp = dSObj.deleteFolder(deleteFolderCriteriaObjArg);
		System.assertEquals('success', resp.status, 'Failed: delete google drive folder');

		// File Operations
		Criteria.File fileObj = new Criteria.File();
		fileObj.provider = 'googledrive';
		fileObj.rootDirectory = 'googledriverootdirectory';
		fileObj.directory = 'googledrivedirectory';
		fileObj.fileId = 'googledrivefileexternalid';
		
    	// File Description
    	Map<String, String> fileDescriptionRequestDataMap = new Map<String, String>();
    	fileDescriptionRequestDataMap.put('fileId', 'googledrivefileexternalid');
    	fileDescriptionRequestDataMap.put('provider', 'googledrive');
    	fileDescriptionRequestDataMap.put('description', 'This is a new description');
    		
    	resp = dSObj.setFileDescription(fileDescriptionRequestDataMap);
        System.assertEquals('success', resp.status, 'Failed: set google drive file description');

        // Move
    	Criteria.FileMove moveFileRequestDataObj = new Criteria.FileMove();
		Criteria.File fileObje = new Criteria.File();
		fileObje.name = 'fileName';
		fileObje.fileId = 'googledrivefileexternalid';
		moveFileRequestDataObj.fileArray = new List<Criteria.File>();
		moveFileRequestDataObj.fileArray.add(fileObje);
		moveFileRequestDataObj.source = 'googledriveFROMFOLDER';
		moveFileRequestDataObj.destination = 'googledriveTOFOLDER';
		moveFileRequestDataObj.provider = 'googledrive';
		moveFileRequestDataObj.siteId = eSite.Id;
		
		//dSObj.moveFiles(moveFileRequestDataObj);
		
		// Deletion
		Criteria.FileDeleteParams deleteFileCriteriaObj = new Criteria.FileDeleteParams();
		deleteFileCriteriaObj.fileId  = new List<String>{'googledrivefileexternalid'};
		deleteFileCriteriaObj.provider  = 'googledrive';
		deleteFileCriteriaObj.fileSiteId  = eSite.Id;
		
		resp = dSObj.deleteFile(deleteFileCriteriaObj);
        System.assertEquals('success', resp.status, 'Failed: delete google drive file');
		
		// Link Folder my drive
        folderCriteriaObjArg.type = 'mydrive';
		resp = dSObj.linkGoogleDriveFolder(folderCriteriaObjArg);
        System.assertEquals('success', resp.status, 'Failed: Link google my drive folder to site');

        // Link Folder shared drive
        folderCriteriaObjArg.type = 'shareddrive';
        resp = dSObj.linkGoogleDriveFolder(folderCriteriaObjArg);
        System.assertEquals('success', resp.status, 'Failed: Link google shared drive to site');

        // reLink Folder shared drive
        resp = dSObj.linkGoogleDriveFolder(folderCriteriaObjArg);
        System.assertEquals(true, resp.message.contains('Linked folder limit reached'), 'Only a shared drive can be linked to a site');
		
		setIntegrationsConnected('googledrive', false);
		
    	Test.stopTest();
    }
	
    @isTest static void testFileFolderOperationsDropbox(){
    	initExternal();   	
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('dropbox'));
    	setIntegrationsConnected('dropbox', true);
    	// Set site storage to googledrive
    	eSite.File_Storage_Source__c = 'dropbox';
    	update eSite;
		
		// googledrive System Folder must exist with 'googledrivetestid'
		Folder__c eFolderObj = TestHelper.createChatterFolder('Dropbox Files', null, eSite.Id, 'dropbox', null, null);
		eFolderObj.Is_System_Folder__c = true;
		eFolderObj.External_Folder_Id__c = 'dropboxtestid';
		update eFolderObj;
        
    	// File Instance
    	FileDataServer dSObj= new FileDataServer();
    	
    	// Input Folder
    	Criteria.Folder folderCriteriaObjArg= new Criteria.Folder();
    	folderCriteriaObjArg.directory='';
    	folderCriteriaObjArg.rootDirectory=null;
    	folderCriteriaObjArg.name='TestCreateFolder';
    	folderCriteriaObjArg.permissions = 'readwrite';
    	folderCriteriaObjArg.siteId = eSite.id;
    	
    	// Create New Folder
    	ResponseWrapper resp = dSObj.createEFSFolder(folderCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
		// Folder Rename
   		Map<String, String> folderRenameRequestDataMap = new Map<String, String>();
    	folderRenameRequestDataMap.put('folderId', 'dropboxfolderexternalid');
    	folderRenameRequestDataMap.put('provider', 'dropbox');
    	folderRenameRequestDataMap.put('name', 'TestRenameFolder');	
    	dSObj.setFolderName(folderRenameRequestDataMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

		// Folder Deletion
		Criteria.FolderDeleteParams deleteFolderCriteriaObjArg=new Criteria.FolderDeleteParams();
		deleteFolderCriteriaObjArg.folderId=(new List<String>{'dropboxfolderexternalid'});
    	deleteFolderCriteriaObjArg.provider='dropbox';    	
		dSObj.deleteFolder(deleteFolderCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		// File Operations
		Criteria.File fileObj = new Criteria.File();
		fileObj.provider = 'dropbox';
		fileObj.rootDirectory = 'dropboxrootdirectory';
        fileObj.directory = 'dropboxdirectory';
		fileObj.fileId = 'dropboxfileexternalid';
		    		        	
		// Site Files Listing
		dsObj.getSiteDropboxFiles(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		fileObj.directory = 'dropboxtestid';
		dsObj.getSiteDropboxFiles(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		// MY Files Listing
		fileObj.directory = null;
		dsObj.getMyDropboxFiles(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		fileObj.directory = 'root';
		dsObj.getMyDropboxFiles(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
    	// File Description
    	Map<String, String> fileDescriptionRequestDataMap = new Map<String, String>();
    	fileDescriptionRequestDataMap.put('fileId', 'dropboxfileexternalid');
    	fileDescriptionRequestDataMap.put('provider', 'dropbox');
    	fileDescriptionRequestDataMap.put('description', 'This is a new description');	
    	dSObj.setFileDescription(fileDescriptionRequestDataMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        // Move
    	Criteria.FileMove moveFileRequestDataObj = new Criteria.FileMove();
		Criteria.File fileObje = new Criteria.File();
		fileObje.name = 'fileName';
		fileObje.fileId = 'dropboxfileexternalid';
		moveFileRequestDataObj.fileArray = new List<Criteria.File>();
		moveFileRequestDataObj.fileArray.add(fileObje);
		moveFileRequestDataObj.source = 'DROPBOXFROMFOLDER';
		moveFileRequestDataObj.destination = 'DROPBOXTOFOLDER';
		moveFileRequestDataObj.provider = 'dropbox';
		moveFileRequestDataObj.siteId = eSite.Id;	
		dSObj.moveFiles(moveFileRequestDataObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		// Deletion
		Criteria.FileDeleteParams deleteFileCriteriaObj = new Criteria.FileDeleteParams();
		deleteFileCriteriaObj.fileId  = new List<String>{'dropboxfileexternalid'};
		deleteFileCriteriaObj.provider  = 'dropbox';
		deleteFileCriteriaObj.fileSiteId  = eSite.Id;	
		dSObj.deleteFile(deleteFileCriteriaObj);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
    	setIntegrationsConnected('dropbox', false);
    }


    @isTest static void testFileFolderOperationsSharepoint(){
    	initExternal();   	
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('sharepoint')); 	
    	setIntegrationsConnected('sharepoint', true);
    	// Set site storage to googledrive
    	eSite.File_Storage_Source__c = 'sharepoint';
    	update eSite;
		
		// googledrive System Folder must exist with 'googledrivetestid'
		Folder__c eFolderObj = TestHelper.createChatterFolder('Sharepoint Files', null, eSite.Id, 'sharepoint', null, null);
		eFolderObj.Is_System_Folder__c = true;
		eFolderObj.External_Folder_Id__c = 'sharepointtestid';
        eFolderObj.SP_Instance_Id__c = 'testInstance';
		update eFolderObj;
        
    	// File Instance
    	FileDataServer dSObj= new FileDataServer();    	
    	ResponseWrapper resp = new ResponseWrapper();
    	
    	Map<String,String> inpMap = new Map<String,String>();
    	dsObj.getSharePointLinkableItems(inpMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	inpMap.put('id', 'siteid1');
    	dsObj.getSharePointLinkableItems(inpMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        inpMap.put('sharepointSiteId', 'sharepointtestid');
        dsObj.getSharePointLinkableItems(inpMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	// Link Folder
    	inpMap.clear();
    	inpMap.put('name', 'TestLinkingFolder');
    	inpMap.put('directory', 'sharepointdocumentlibraryid');

    	
    	// Create New Folder
    	// Input Folder
    	Criteria.Folder folderCriteriaObjArg= new Criteria.Folder();
    	folderCriteriaObjArg.directory='sharepointtestid';
    	folderCriteriaObjArg.rootDirectory='sharepointdocumentlibraryid';
    	folderCriteriaObjArg.name='TestCreateFolder';
    	folderCriteriaObjArg.permissions = 'readwrite';
    	folderCriteriaObjArg.siteId = eSite.id;
    	resp = dSObj.createEFSFolder(folderCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		// Folder Rename
   		Map<String, String> folderRenameRequestDataMap = new Map<String, String>();
    	folderRenameRequestDataMap.put('folderId', 'sharepointtestid');
    	folderRenameRequestDataMap.put('provider', 'sharepoint');
    	folderRenameRequestDataMap.put('name', 'TestRenameFolder');
    	folderRenameRequestDataMap.put('siteId', eSite.id); 		
    	dSObj.setFolderName(folderRenameRequestDataMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

		// Folder Deletion
		Criteria.FolderDeleteParams deleteFolderCriteriaObjArg=new Criteria.FolderDeleteParams();
		deleteFolderCriteriaObjArg.folderId=(new List<String>{'sharepointfolderexternalid'});
    	deleteFolderCriteriaObjArg.provider='sharepoint';
    	
		//dSObj.deleteFolder(deleteFolderCriteriaObjArg);
		
		// File Operations
		Criteria.File fileObj = new Criteria.File();
		fileObj.provider = 'sharepoint';
		fileObj.rootDirectory = 'sharepointrootdirectory';
		fileObj.directory = eFolderObj.id;
		fileObj.fileId = 'sharepointfileexternalid';
		    		        	
		// Site Files Listing
		dsObj.getSiteMSDriveFiles(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		fileObj.directory = 'sharepointtestid';
		dsObj.getSiteMSDriveFiles(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
    	// File Description
    	Map<String, String> fileDescriptionRequestDataMap = new Map<String, String>();
    	fileDescriptionRequestDataMap.put('fileId', 'sharepointfileexternalid');
    	fileDescriptionRequestDataMap.put('provider', 'sharepoint');
    	fileDescriptionRequestDataMap.put('description', 'This is a new description');	
    	dSObj.setFileDescription(fileDescriptionRequestDataMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        // Move
    	Criteria.FileMove moveFileRequestDataObj = new Criteria.FileMove();
		Criteria.File fileObje = new Criteria.File();
		fileObje.name = 'fileName';
		fileObje.fileId = 'googledrivefileexternalid';
		moveFileRequestDataObj.fileArray = new List<Criteria.File>();
		moveFileRequestDataObj.fileArray.add(fileObje);
		moveFileRequestDataObj.source = 'SHAREPOINTFROMFOLDER';
		moveFileRequestDataObj.destination = 'SHAREPOINTTOFOLDER';
		moveFileRequestDataObj.provider = 'sharepoint';
		moveFileRequestDataObj.siteId = eSite.Id;
		dSObj.moveFiles(moveFileRequestDataObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		// Deletion
		Criteria.FileDeleteParams deleteFileCriteriaObj = new Criteria.FileDeleteParams();
		deleteFileCriteriaObj.fileId  = new List<String>{'sharepointfileexternalid'};
		deleteFileCriteriaObj.provider  = 'sharepoint';
		deleteFileCriteriaObj.fileSiteId  = eSite.Id;
		
		//dSObj.deleteFile(deleteFileCriteriaObj);
    	
    	setIntegrationsConnected('sharepoint', false);
        Test.stopTest();
    }
    
     
    
    @isTest static void testFileFolderOperationsOnedrive(){
    	initExternal();   	
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('onedrive'));
    	
    	setIntegrationsConnected('onedrive', true);
    	// Set site storage to googledrive
    	eSite.File_Storage_Source__c = 'onedrive';
    	update eSite;
		
		// googledrive System Folder must exist with 'googledrivetestid'
		Folder__c eFolderObj = TestHelper.createChatterFolder('onedrive Files', null, eSite.Id, 'onedrive', null, null);
		eFolderObj.Is_System_Folder__c = true;
		eFolderObj.External_Folder_Id__c = 'onedrivetestid';
        eFolderObj.People__c = UserContext.PeopleId;
		update eFolderObj;

            	// File Instance
    	FileDataServer dSObj= new FileDataServer();	    	
    	ResponseWrapper resp = new ResponseWrapper();
    	
    	Map<String,String> inpMap = new Map<String,String>();
    	dsObj.getOnedriveLinkableItems(inpMap);
    	
    	inpMap.put('id', 'siteid1');
    	dsObj.getOnedriveLinkableItems(inpMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    	
    	// Link Folder
    	inpMap.clear();
    	inpMap.put('name', 'TestLinkingFolder');
    	inpMap.put('directory', 'onedrivedocumentlibraryid');
    	
    	// Create New Folder
    	// Input Folder
    	Criteria.Folder folderCriteriaObjArg= new Criteria.Folder();
    	folderCriteriaObjArg.directory='onedrivetestid';
    	folderCriteriaObjArg.rootDirectory='onedrivedocumentlibraryid';
    	folderCriteriaObjArg.name='TestCreateFolder';
    	folderCriteriaObjArg.permissions = 'readwrite';
    	folderCriteriaObjArg.siteId = eSite.id;
    	resp = dSObj.createEFSFolder(folderCriteriaObjArg);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        // Folder Rename
   		Map<String, String> folderRenameRequestDataMap = new Map<String, String>();
    	folderRenameRequestDataMap.put('folderId', 'onedrivefolderexternalid');
    	folderRenameRequestDataMap.put('provider', 'onedrive');
    	folderRenameRequestDataMap.put('name', 'TestRenameFolder');
    		
    	dSObj.setFolderName(folderRenameRequestDataMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

		// Folder Deletion
		Criteria.FolderDeleteParams deleteFolderCriteriaObjArg=new Criteria.FolderDeleteParams();
		deleteFolderCriteriaObjArg.folderId=(new List<String>{'onedrivefolderexternalid'});
    	deleteFolderCriteriaObjArg.provider='onedrive';
    	
		//dSObj.deleteFolder(deleteFolderCriteriaObjArg);
		
		// File Operations
		Criteria.File fileObj = new Criteria.File();
		fileObj.provider = 'onedrive';
		fileObj.rootDirectory = 'onedriverootdirectory';
		fileObj.directory = eFolderObj.id;
		fileObj.fileId = 'onedrivefileexternalid';
		    		        	
		// Site Files Listing 
		dsObj.getSiteMSDriveFiles(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		fileObj.directory = 'onedrivetestid';
		dsObj.getSiteMSDriveFiles(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
    	// File Description
    	Map<String, String> fileDescriptionRequestDataMap = new Map<String, String>();
    	fileDescriptionRequestDataMap.put('fileId', 'onedrivefileexternalid');
    	fileDescriptionRequestDataMap.put('provider', 'onedrive');
    	fileDescriptionRequestDataMap.put('description', 'This is a new description');
    		
    	dSObj.setFileDescription(fileDescriptionRequestDataMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        // Move
    	Criteria.FileMove moveFileRequestDataObj = new Criteria.FileMove();
		Criteria.File fileObje = new Criteria.File();
		fileObje.name = 'fileName';
		fileObje.fileId = 'onedrivefileexternalid';
		moveFileRequestDataObj.fileArray = new List<Criteria.File>();
		moveFileRequestDataObj.fileArray.add(fileObje);
		moveFileRequestDataObj.source = 'ONEDRIVEFROMFOLDER';
		moveFileRequestDataObj.destination = 'ONEDRIVETOFOLDER';
		moveFileRequestDataObj.provider = 'onedrive';
		moveFileRequestDataObj.siteId = eSite.Id;
		
		dSObj.moveFiles(moveFileRequestDataObj);
		System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
		// Deletion
		Criteria.FileDeleteParams deleteFileCriteriaObj = new Criteria.FileDeleteParams();
		deleteFileCriteriaObj.fileId  = new List<String>{'onedrivefileexternalid'};
		deleteFileCriteriaObj.provider  = 'onedrive';
		deleteFileCriteriaObj.fileSiteId  = eSite.Id;
		
		//dSObj.deleteFile(deleteFileCriteriaObj);
    	
    	setIntegrationsConnected('onedrive', false);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }
        
    @isTest static void testBoxConnections(){
    	init();
    	FileDataServer dSObj= new FileDataServer();
    	dSObj.getAccessToken();
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }
    
    @isTest static void testGetPageFeature() {
		init();
    	FileDataServer dSObj= new FileDataServer();
    	dSObj.getPageFeature();
    	System.assertEquals('SIMPPLR', AccessManager.FEATURE_SIMPPLR, 'Running as expected');
    }
    
    
    @isTest static void testSearchSiteFiles() {
		Test.startTest();
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);  
		FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('siteId',siteId);    
    	
    	// site files -- intranet
    	pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":null,"provider":"intranet","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":null,"provider":"intranet","owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        // site files -- crm
    	pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":null,"provider":"crm","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":null,"provider":"crm","owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');

		// site files -- native_video
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":null,"provider":"native_video","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
		System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testSearchSiteFilesWithDirectory() {
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        Folder__c folderObj = new Folder__c();
        folderObj.Is_System_Folder__c = true;
        folderObj.Site__c = siteId;
        insert folderObj;      
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);        
		FileDataServer dSObj= new FileDataServer(); 	
    	pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":"'+folderObj.Id+'","provider":"crm","owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }
    
    @isTest static void testSearchSiteFilesBoxandBlank() {
		Test.startTest();
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');     
        Test.setCurrentPage(pageRef); 
       	FileDataServer dSObj= new FileDataServer();               
        // site files -- blank
    	pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":"random","provider":"","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":"random","provider":"","owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testSearchMyFiles() {  
        Test.startTest();	
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
        
        // my files -- intranet
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"intranet","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"intranet","owner":"all","filter":null,"type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        // my files -- crm
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"crm","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"crm","owner":"all","filter":null,"type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testSearchMyFilesFavorites() {
        Test.startTest(); 
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');        
        Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
		// Favorites -- sfdc
		pageRef.getParameters().put('action','search');
		pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"intranet","isMediaManager":true,"owner":"all","filter":"favorites","type":null,"pageName":"favorites"}');
		dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
	}

    @isTest static void searchBox() {
        Simpplr_Site__c site = getSimpplrSite('FileDataServerTest_grp1');
        site.File_Storage_Source__c = 'box';
        update site;
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FileDataServer'); 
        pageRef.getParameters().put('siteId',site.id);        
        Test.setCurrentPage(pageRef);
        // Favorites -- box
        UserContext.isBoxConnected = true;
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',false)); 
        FileDataServer dSObj= new FileDataServer();
        
        // site files -- box
    	pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + site.id + '","term":null,"directory":"random","provider":"box","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' +  site.id + '","term":"abc","directory":"random","provider":"box","owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected'); 

        pageRef.getParameters().put('data','{"size":16,"siteId":"' +  site.id + '","term":null,"directory":null,"rootDirectory":null,"provider":"box","isMediaManager":true,"owner":"all","filter":null,"type":null}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

        Test.stopTest();

    }
    
    @isTest static void searchBoxFromMediaManager() {    
        Simpplr_Site__c site = getSimpplrSite('FileDataServerTest_grp1');
        site.File_Storage_Source__c = 'box';
        update site;
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FileDataServer'); 
        pageRef.getParameters().put('siteId',site.id);        
        Test.setCurrentPage(pageRef);
        UserContext.isBoxConnected = true;
        FileDataServer dSObj= new FileDataServer();
        // my files -- box
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"box","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"my_files"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',false));    
        dSObj.handleRequest();
        Test.stopTest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

    }
    
    @isTest static void searchSharepointWithoutTerm() {
        Test.startTest();     
        App_Integration__c appIntegObj = [Select Id From App_Integration__c Where Name = 'sharepoint' Limit 1];
        appIntegObj.Client_Id__c = '72e22fb7-3ef7-4233-9171-54caef8a5e19';
        appIntegObj.Connected__c = true;
        update appIntegObj;
        People_Integration__c peopleIntegObj = [Select Id From People_Integration__c Where Name = 'sharepoint' Limit 1];
        peopleIntegObj.Connected__c = true;
        update peopleIntegObj;    	
    	PageReference pageRef = Page.DataServerRW;  
        pageRef.getParameters().put('target','FileDataServer');    
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'search/sharepoint',false));
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"sharepoint","owner":"all","filter":"sharepoint","type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"onedrive","owner":"all","filter":"sharepoint","type":null,"view":"my_files"}');
        dSObj.handleRequest();
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest static void searchSharepointWithTerm() {
        App_Integration__c appIntegObj = [Select Id From App_Integration__c Where Name = 'sharepoint' Limit 1];
        appIntegObj.Client_Id__c = '72e22fb7-3ef7-4233-9171-54caef8a5e19';
        appIntegObj.Connected__c = true;
        update appIntegObj;
        People_Integration__c peopleIntegObj = [Select Id From People_Integration__c Where Name = 'sharepoint' Limit 1];
        peopleIntegObj.Connected__c = true;
        update peopleIntegObj;    	
        PageReference pageRef = Page.DataServerRW;  
        pageRef.getParameters().put('target','FileDataServer');    
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'search/sharepoint',false));
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"test","directory":null,"provider":"sharepoint","owner":"all","filter":"sharepoint","type":null,"view":"my_files"}');   
        Test.startTest();
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetSharePointVersionDownloadUrl() {
        Test.startTest();
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');       
        Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',false));
        pageRef.getParameters().put('action','getSharePointVersionDownloadUrl');
        pageRef.getParameters().put('data','{"driveId":"testDriveId","fileId":"testFileId","versionId":"testversionId"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetCrmFolders() {
        Test.startTest();
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id; 	
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');      
        Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getCrmFolders');
        pageRef.getParameters().put('siteId',siteId);
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetFileTypes() {
        Test.startTest();
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id;   	
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');     
        Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getFileTypes');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testGetMedia1() {
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);    
		FileDataServer dSObj= new FileDataServer();
        String albumId = getSimpplrSite('FileDataServerTest_grp1').id; /// TODO - albumId
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'testArticleRecord'];
        File__c fileObj =  TestHelper.createContentTitleImage(content.id);
        fileObj.Is_Deleted__c=false;
        fileObj.Location__c = 'media';
        update fileObj;
    	pageRef.getParameters().put('action','getMedia');
        pageRef.getParameters().put('data','{"size":16,"id":"' + content.id + '","term":"","directory":null,"provider":"intranet","isMediaManager":true,"owner":"all","filter":null,"type":null}');
        dSObj.handleRequest();
		System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }

    @isTest static void testGetAlbumMediaByVersionId() {
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'testArticleRecord'];
        File__c fileObj =  TestHelper.createContentTitleImage(content.id);
        List<File__c> fileList = new List<File__c>();
        fileList.add(fileObj);
        string fileJson = JSON.serialize(fileList);
        Content_History__c historyObj = new Content_History__c();
        historyObj.Content__c = content.id;
        historyObj.Version__c = 1;
        historyObj.Content_Json_Part1__c = '"{"attributes":{"type":"Simpplr_Content__c"},"Total_View_Count__c":2,"Popularity_Score__c":20,"Version__c":1,"Last_Edited_DateTime__c":"2022-05-25T09:46:42.000+0000","First_Publish_DateTime__c":"2022-05-25T09:46:42.000+0000","Is_Published__c":true,"Publish_Start_DateTime__c":"2022-05-24T18:30:00.000+0000","Title__c":"TestAlbum","Type__c":"Album","Id":"'+content.Id+'","Status__c":"Approved","Unique_View_Count__c":1,"Display_Order__c":1,"Allow_Comments__c":true,"Site__c":"'+siteId+'","Activated_By_Feature__c":true}"';
        historyObj.File_Json__c = fileJson;
        insert historyObj;

        FileDataServer dSObj= new FileDataServer();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        pageRef.getParameters().put('action','getMedia');
        pageRef.getParameters().put('data','{"id":"' + content.id + '","versionHistoryId":"1"}');
        Test.setCurrentPage(pageRef); 
        Test.startTest();
        dSObj.handleRequest();
		System.assertEquals('success', dSObj.response.status, 'failed to return album media files for version id');
        Test.stopTest();
    }
    
    @isTest static void testGetPublicUrl() {
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        String albumId = getSimpplrSite('FileDataServerTest_grp1').id; /// TODO - albumId
    	String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' + albumId + '#'  + 'dummyfile.png';
    	ContentVersion cvObj = TestHelper.createContentVersion('H', pathOnClient);
		FileDataServer dSObj= new FileDataServer();
    	pageRef.getParameters().put('action','getPublicUrl');
        pageRef.getParameters().put('data','{"fileId":"' + cvObj.ContentDocumentId + '"}');
        dSObj.handleRequest();
		System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }
    
    @isTest static void testMoveFiles() {
        Test.startTest();
        intranetFileObj = [Select id, content_Document__c From File__c where title__c = 'intranet Dummy file' LIMIT 1];
        intranetSourceFolderObj = [Select id From Folder__c where Name__c = 'Source intranet folder' LIMIT 1];
        intranetDestinationFolderObj = [Select id From Folder__c where Name__c = 'Destination intranet folder' LIMIT 1];
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer'); 
        Test.setCurrentPage(pageRef);
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id; /// TODO - albumId
		FileDataServer dSObj= new FileDataServer();
    	pageRef.getParameters().put('action','moveFiles');
        pageRef.getParameters().put('data','{"siteId":"' + siteId + '","fileArray":[{"fileId":"'+intranetFileObj.content_Document__c+'"}],"source":"'+intranetSourceFolderObj.id+'","destination":"'+intranetDestinationFolderObj.id+'","provider":"intranet"}');
        dSObj.handleRequest();

        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('data','{"fileId":"' + intranetFileObj.content_Document__c + '","provider":"intranet","rootDirectory":null, "directory":null}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testMoveBoxFile() {
    	PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id; /// TODO - albumId
		FileDataServer dSObj= new FileDataServer();
    	pageRef.getParameters().put('action','moveFiles');
        Criteria.File fileCriteriaObjArg= new Criteria.File();
    	fileCriteriaObjArg.siteId=siteId;
    	fileCriteriaObjArg.filter='write_folders';
    	fileCriteriaObjArg.provider='box';
        fileCriteriaObjArg.offset=0;
        fileCriteriaObjArg.sortBy='createdNewest';
        fileCriteriaObjArg.size=1;
        Criteria.FileMove fileCriteriaMoveObj= new Criteria.FileMove();
        fileCriteriaMoveObj.siteId=siteId;
    	fileCriteriaMoveObj.Provider='box';
        fileCriteriaMoveObj.source='FolderToBox';
        fileCriteriaMoveObj.destination='BoxToFolder';
        fileCriteriaMoveObj.fileArray = new List <Criteria.File>{fileCriteriaObjArg};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'BoxFolderFile/FolderContents',false));
        dSObj.moveFiles(fileCriteriaMoveObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    
     @isTest static void testAutoComplete2(){
        Test.startTest();
    	init();
    	String siteId = getSimpplrSite('FileDataServerTest_grp1').id;	
    	FileDataServer dSObj= new FileDataServer();
    	String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' +siteId+ '#' + '#' + 'dummyfile.png';
	    ContentVersion cvObj = TestHelper.createContentVersion('nvcjdnvjfnvjnfdkjvnfHVGVGDXnkjckjdnvjndn6347hcbchdbc', pathOnClient);
	    List<ContentDocument> ContentDocumentList = [select Id from ContentDocument where latestpublishedversionId=:cvObj.id];
    	
        Criteria.File fileCriteriaObj = new Criteria.File();
        fileCriteriaObj.provider = dSObj.PROVIDER_INTRANET;
    	dSObj.autoComplete(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
         
    	fileCriteriaObj.siteId = siteId;
    	fileCriteriaObj.term = '';
    	dSObj.autoComplete(fileCriteriaObj); 
        System.assertEquals('success', dSObj.response.status, 'Running as expected');

    	fileCriteriaObj.provider = dSObj.PROVIDER_BOX;
    	dSObj.autoComplete(fileCriteriaObj);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
     
        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));
    	fileCriteriaObj.provider = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
    	dSObj.autoComplete(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testMethods2(){
        Test.startTest();
    	init();
    	String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
    	FileDataServer dSObj= new FileDataServer();
    	
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_DROPBOX_ACCESS_TOKEN);
        dSObj.handleRequest();
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_CRM_FOLDER);
        pageRef.getParameters().put('action',siteId);
        pageRef.getParameters().put('data','{"directory":null,"rootDirectory":{"permissions":"read","name":"CRM Files","isSystemDir":true,"id":"a0x61000001gKhSAAU","canLinkFolder":true}}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_LINK_CRM_FOLDER);
        pageRef.getParameters().put('data','{"directory":"05861000000IeZmAAK","name":"Acc_lib1","permissions":"read","siteId":"' + siteId + '"}');
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        // favourite - CRM - myFiles
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":null,"term":"","directory":null,"provider":"crm","isMediaManager":false,"owner":"all","filter":"favorites","type":null,"view":"my_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        // getSiteCRMFiles
        Folder__c externalFolder = TestHelper.createChatterFolder('testFolder02', null, siteId, 'crm', null, 'write');
        Folder__c folderObj = TestHelper.createChatterFolder('CRM Files', null, siteId, 'crm', null, 'readwrite'); 
        folderObj.External_Folder_Id__c = externalFolder.id;
        folderObj.Is_Deleted__c = false;
        folderObj.Is_System_Folder__c=true;
        update folderObj;
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","directory":"' + externalFolder.id + '","term":"","provider":"crm","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":"058xxxxxxxxxxxx","provider":"intranet","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        // getSiteDropboxFiles
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"siteId":"' + siteId + '","term":"","directory":null,"provider":"dropbox","isMediaManager":true,"owner":"all","filter":null,"type":null,"view":"site_files"}');
        dSObj.handleRequest();
        Test.stopTest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
    }
    
    @isTest static void testEFSToken(){
    	init();
    	FileDataServer dSObj= new FileDataServer();
    	
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_GET_EFS_ACCESS_TOKEN);

        pageRef.getParameters().put('provider',ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('provider',ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('provider',ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action',dSObj.ACTION_VALUE_RESET_EFS_ACCESS_TOKEN);
        pageRef.getParameters().put('provider',ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('provider',ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
        
        pageRef.getParameters().put('provider',ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);
        dSObj.handleRequest();
        System.assertEquals('error', dSObj.response.status, 'Running as expected');
    }

	 @isTest static void testGetMyFilesCRMLibFilesNegtive(){
    	init();
        Criteria.File fileCriteriaObjArg = new Criteria.File();
        fileCriteriaObjArg.owner = 'owned_by_me';
    	FileDataServer dSObj= new FileDataServer();
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        dSObj.getMyFilesCRMLibFiles(fileCriteriaObjArg);
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }

	@isTest static void testGetFavoriteFilesNegtive(){
		Test.startTest();
    	init();
    	FileDataServer dSObj= new FileDataServer();
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'testArticleRecord'];
        update content;
        File__c fileObj =  TestHelper.createContentTitleImage(content.id);
        update fileObj;
        String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' +siteId+ '#' + fileObj.Id + '#' + 'dummyfile.png';
	    ContentVersion cvObj = TestHelper.createContentVersion('nvcjdnvjfnvjnfdkjvnfHVGVGDXnkjckjdnvjndn6347hcbchdbc', pathOnClient);
	    List<ContentDocument> ContentDocumentList = [select Id from ContentDocument where latestpublishedversionId=:cvObj.id];
        Bookmark__c bookmarkObj =  TestHelper.createContentBookmark(content.id, UserContext.peopleId);
        bookmarkObj.Type__c='Intranet';  
        bookmarkObj.Is_Deleted__c = false;
        bookmarkObj.External_File_Id__c = ContentDocumentList[0].id;
        update bookmarkObj;
	    ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace limit 1];
	    ContentWorkspaceDoc newWorkspaceDoc =new ContentWorkspaceDoc();
	    newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id;
	    newWorkspaceDoc.ContentDocumentId = ContentDocumentList[0].id;
        insert newWorkspaceDoc;
        Criteria.File fileCriteriaObj = new Criteria.File();
	    fileCriteriaObj.provider = 'intranet';
        fileCriteriaObj.directory = testWorkspace.id;
        fileCriteriaObj.offset = 0;
        fileCriteriaObj.size = 0;
        dSObj.getFavoriteFiles(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        bookmarkObj.Type__c='CRM';
        update bookmarkObj;
        dSObj.getFavoriteCRMFiles(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        dSObj.getSiteCRMFiles(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        fileCriteriaObj.filter='bookmarked';
		dSObj.getSiteCRMFiles(fileCriteriaObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
    }
	
	@isTest static void testCreateEFSFolderNegtive(){
    	initExternal();   	
    	Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));
    	      
    	setIntegrationsConnected('googledrive', true);
    	// Set site storage to googledrive
    	eSite.File_Storage_Source__c = 'googledrive';
    	update eSite;
    	FileDataServer dSObj= new FileDataServer();
    	Criteria.Folder folderCriteriaObjArg= new Criteria.Folder();
    	folderCriteriaObjArg.directory='googledrivetestid';
    	folderCriteriaObjArg.rootDirectory=null;
    	folderCriteriaObjArg.name='TestCreateFolder';
    	folderCriteriaObjArg.permissions = 'readwrite';
        dSObj.createGoogleFolder(folderCriteriaObjArg); 
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }

	@isTest static void testMoveBoxFileNegtive(){
    	init();
    	FileDataServer dSObj= new FileDataServer();
    	PageReference pageRef = Page.DataServerRW;
    	pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        dSObj.moveBoxFile('test', 'teset', 'test');
    	System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }
	
	
	@isTest static void testUnlinkCRMFolderNegtive(){
    	init();
    	FileDataServer dSObj= new FileDataServer();
    	PageReference pageRef = Page.DataServerRW;
        string siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        Map<String, String> requestDataMap = new Map<String, String>();
        requestDataMap.put('folderId','updateFileNameTest');
    	pageRef.getParameters().put('target','FileDataServer');
        Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, siteId, 'crm', null, 'readwrite'); 
        folderObj.External_Folder_Id__c = 'updateFileNameTest';
        folderObj.Is_Deleted__c = false;
        update folderObj;
        List<Folder__c> folderList = new List<Folder__c>();
        folderList.add(folderObj);
        pageRef.getParameters().put('siteId', siteId);
        Test.setCurrentPage(pageRef);
        dSObj.unlinkCRMFolder(requestDataMap);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        dSObj.getCrmFolders(requestDataMap,siteId);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
    }

	@isTest static void testLinkOnedriveFolder() {
		FileDataServer dSObj= new FileDataServer();
        initExternal();   	
    	setIntegrationsConnected('onedrive', true);
    	eSite.File_Storage_Source__c = 'onedrive';
    	update eSite;
		Criteria.OwnerWrapper OwnerWrap = new Criteria.OwnerWrapper();
		OwnerWrap.id = managerUserObj.id;
		OwnerWrap.name = managerUserObj.lastName;
		OwnerWrap.url = null;
    	Criteria.Folder foldObj = new Criteria.Folder();
    	foldObj.name = 'TestLinkingFolder';
    	foldObj.directory = 'onedrivedocumentlibraryid';
		foldObj.siteId = eSite.id;
		Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('onedrive'));
		dSObj.linkOnedriveFolder(foldObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }
    
	
	@isTest static void testUnLinkOnedriveFolder(){
        FileDataServer dSObj= new FileDataServer();
        initExternal();   	
		Criteria.OwnerWrapper OwnerWrap = new Criteria.OwnerWrapper();
		OwnerWrap.id = managerUserObj.id;
		OwnerWrap.name = managerUserObj.lastName;
		OwnerWrap.url = null;
    	Criteria.Folder foldObj = new Criteria.Folder();
    	foldObj.name = 'TestLinkingFolder';
    	foldObj.directory = 'onedrivedocumentlibraryid';
		foldObj.siteId = eSite.id;
		PageReference pageRef = Page.DataServerRO;
		Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('onedrive'));
		pageRef.getParameters().put('target','FileDataServer');
        pageRef.getParameters().put('action','unLinkOnedriveFolder');
		Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('data','{"folderId":"folderid","siteId":"'+eSite.id+'"}');
		dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
		setIntegrationsConnected('onedrive', false);
    }

	@isTest static void testLinkSharepointFolder() {
		FileDataServer dSObj= new FileDataServer();
        initExternal();   	
    	setIntegrationsConnected('sharepoint', true);
    	eSite.File_Storage_Source__c = 'sharepoint';
    	update eSite;
		Criteria.OwnerWrapper OwnerWrap = new Criteria.OwnerWrapper();
		OwnerWrap.id = managerUserObj.id;
		OwnerWrap.name = managerUserObj.lastName;
		OwnerWrap.url = null;
		Criteria.Folder foldObj = new Criteria.Folder();
    	foldObj.name = 'TestLinkingFolder';
    	foldObj.directory = 'sharepointdocumentlibraryid';
		foldObj.sharepointSiteId = eSite.id;
		foldObj.siteId = eSite.id;
		Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('sharepoint'));
		dSObj.linkSharepointFolder(foldObj);
        Test.stopTest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		setIntegrationsConnected('sharepoint', false);
    }

	@isTest static void testUnLinkSharepointFolder(){
        FileDataServer dSObj= new FileDataServer();
        initExternal();   	
		Folder__c eFolderObj = TestHelper.createChatterFolder('Sharepoint Files', null, eSite.Id, 'sharepoint', null, null);
        eFolderObj.Is_System_Folder__c = true;
        eFolderObj.External_Folder_Id__c = 'sharepointtestid';
        eFolderObj.SP_Instance_Id__c = 'testInstance';
        update eFolderObj; 
        PageReference pageRef = Page.DataServerRO;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('sharepoint'));
        pageRef.getParameters().put('target','FileDataServer');
        pageRef.getParameters().put('action','unLinkSharepointFolder');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('data','{"folderId":"sharepointtestid","siteId":"'+eSite.id+'"}');
        dSObj.handleRequest();
		System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
		setIntegrationsConnected('sharepoint', false);
    }

	@isTest static void testUnLinkGoogleDriveFolder(){
        FileDataServer dSObj= new FileDataServer();
        initExternal();   	  	
    	Folder__c folderObj = [Select id from Folder__c where Name__c = 'Google Drive Files'];     
		Simpplr_Site__c site = [select id,File_Storage_Source__c,chatter_group_Id__c from Simpplr_Site__c where Name = 'FileDataServerTest_googleDriveSite' limit 1];
		Test.startTest();
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','FileDataServer');
        pageRef.getParameters().put('action','unlinkGoogleDriveFolder');
        Test.setCurrentPage(pageRef);
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));
        pageRef.getParameters().put('data','{"folderId":"googledrivetestid","siteId":"'+site.id+'"}');
		dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Failed: Unlink google drive folder from site');
        Test.stopTest();
    }
    
    @isTest static void testGetFileDetailBox(){
        Test.startTest(); 
		init();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/FileDetails',false));
    	FileDataServer dSObj= new FileDataServer();
		Criteria.File fileObj = new Criteria.File();
		fileObj.name = 'fileName';
		fileObj.fileId = 'dummyid';
		fileObj.provider = 'Box';
		dSObj.getFileDetail(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
	}
    
    @isTest static void testGetFileDetailBoxBoxConnected(){
        Test.startTest(); 
		init();
        App_Config__c appConfig = TestHelper.getAppConfig();
        appConfig.Box_Integration_Enabled__c = true;
        appConfig.Box_User_Id__c = 'testBoxUserId';
        update appConfig;       
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/FileDetails',false));
    	FileDataServer dSObj= new FileDataServer();        
		Criteria.File fileObj = new Criteria.File();
		fileObj.name = 'fileName';
		fileObj.fileId = 'dummyid';
		fileObj.provider = 'Box';
		System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
	}
    
    @isTest static void testGetFileDetailgoogledrive(){
        Test.startTest(); 
		init();
        SimpplrContext.isPlatformCachingFeatureEnabled = false;
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'googledrive/FileDetails',false));
    	FileDataServer dSObj= new FileDataServer();
		Criteria.File fileObje = new Criteria.File();
		fileObje.name = 'fileName';
		fileObje.fileId = 'dummyid';
		fileObje.provider = 'googledrive';
		ResponseWrapper response = dSObj.getFileDetail(fileObje);
        System.assertEquals('success', response.status, 'Failed: Fetch google drive file details');
        Test.stopTest();
	}
    
    @isTest static void testGetFileDetailDropbox(){
        Test.startTest(); 
		init();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'dropbox/FileDetails',false));
    	FileDataServer dSObj= new FileDataServer();
		Criteria.File fileObj = new Criteria.File();
		fileObj.name = 'fileName';
		fileObj.fileId = 'dummyid';
		fileObj.provider = 'dropbox';
		dSObj.getFileDetail(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
	}
      @isTest static void testGetFileDetailSharepoint(){
        Test.startTest(); 
		init();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'sharepoint/FileDetails',false));
    	FileDataServer dSObj= new FileDataServer();
		Criteria.File fileObj = new Criteria.File();
		fileObj.name = 'fileName';
		fileObj.fileId = 'dummyid';
		fileObj.provider = 'sharepoint';
		dSObj.getFileDetail(fileObj);
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
	}
    @isTest static void testGetFileDetailOnedrive(){
        Test.startTest(); 
		init();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'onedrive/FileDetails',false));
    	FileDataServer dSObj= new FileDataServer();
		Criteria.File fileObj = new Criteria.File();
		fileObj.name = 'fileName';
		fileObj.fileId = 'dummyid';
		fileObj.provider = 'onedrive';
		dSObj.getFileDetail(fileObj);
		System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
	}
    
    @isTest static void testCreateGoogleDriveFolder(){
    	initExternal();   
        setIntegrationsConnected('googledrive', true);
    	// Set site storage to googledrive
    	eSite.File_Storage_Source__c = 'googledrive';
    	update eSite;

    	Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));

        FileDataServer dSObj= new FileDataServer();
    	Criteria.Folder folderCriteriaObjArg= new Criteria.Folder();
    	folderCriteriaObjArg.directory='googledrivetestid';
    	folderCriteriaObjArg.rootDirectory=null;
    	folderCriteriaObjArg.name='TestCreateFolder';
    	folderCriteriaObjArg.permissions = 'readwrite';

        ResponseWrapper result = new ResponseWrapper(); 
		result = dSObj.createGoogleFolder(folderCriteriaObjArg);

        System.assertEquals('success', result.status, 'Failed: Create google drive folder');
        Test.stopTest();
	}
	
	@isTest static void testUploadImageToAWS(){
		Test.startTest(); 
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'Success',false));
		PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');       
		pageRef.getParameters().put('action','uploadImageToAWS');
		pageRef.getParameters().put('contentVersionId','AWS_Upload');
		Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
        dSObj.handleRequest();
		System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
	}
	
	@isTest static void testNativeVideo() {
        Test.startTest();  
        init();
		PageReference pageRef = Page.DataServerRO;	
        UserContext.hasModifyAllDataPermission = true;
        UserContext.isUserAppModerator = true;
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
		Site_Role__c siteRoleObj = TestHelper.createSiteRole(UserContext.peopleId, siteId);
		siteRoleObj.is_Member__c = true;
		siteRoleObj.Is_Manager__c = true;
		update siteRoleObj;
        pageRef.getParameters().put('siteId', site.id);
        Test.setCurrentPage(pageRef);
		Folder__c folderObj = TestHelper.createChatterFolder('Site Videos', null, siteId, 'native_video', null, null);
        folderObj.Is_System_Folder__c = true;
        folderObj.Permissions__c = 'readwrite';
        update folderObj;
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'testArticleRecord'];
        File__c fileObj =  TestHelper.createFileRecordForVideo(content.id, 'DummyUrl');
        fileObj.External_Id__c = '1_ionhbfw7';
        update fileObj;
        Bookmark__c bookmarkObj =  TestHelper.createContentBookmark(content.id, UserContext.peopleId);
        bookmarkObj.External_File_Id__c = '1_ionhbfw7';
        update bookmarkObj;
        Criteria.FileDeleteParams deleteFolderCriteriaObjArg=new Criteria.FileDeleteParams();
		deleteFolderCriteriaObjArg.fileId=(new List<String>{'1_ionhbfw7'});
    	deleteFolderCriteriaObjArg.provider='native_video';
        deleteFolderCriteriaObjArg.fileSiteId = siteId;
        String str = JSON.serialize(deleteFolderCriteriaObjArg);
			
		SimpplrContext.isNativeVideo = true;
		pageRef.getParameters().put('target','FileDataServer');
		pageRef.getParameters().put('data','{"provider":"native_video", "siteId":"' + siteId + '", "directory":"'  + folderObj.id + '"}');
		pageRef.getParameters().put('action','search');
		Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
		dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		
		pageRef.getParameters().put('data','{"filter": "favorites", "provider":"native_video", "siteId":"' + siteId + '"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        
		pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('data','{"fileId": "1_ionhbfw7", "provider":"native_video"}');
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
	}

    @isTest static void testSearchVideosWhenExternalSearchEnable() {
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'testArticleRecord'];
        File__c fileObj =  TestHelper.createFileRecordForVideo(content.id, 'DummyUrl');
        fileObj.External_Id__c = '1_ionhbfw7';
        update fileObj;
        Bookmark__c bookmarkObj =  TestHelper.createContentBookmark(content.id, UserContext.peopleId);
        bookmarkObj.External_File_Id__c = '1_ionhbfw7';
        bookmarkObj.Is_Deleted__c = false;
        bookmarkObj.Type__c = 'native_video';
        update bookmarkObj;
		PageReference pageRef = Page.DataServerRO;		
		SimpplrContext.isNativeVideo = true;
		pageRef.getParameters().put('target','FileDataServer');
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter": "favorites", "provider":"native_video", "term" : "Title", "size": 16}');
        Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchFiles',false));
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
	}
    
    @isTest static void testSearchIntranetfilesWhenExternalSearchEnable() {
		String siteId = getSimpplrSite('FileDataServerTest_grp1').id;
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'testArticleRecord'];
        File__c fileObjForImage = TestHelper.createContentTitleImage(content.Id);
		ContentVersion contentVersionObj = TestHelper.createContentVersion('developer', 'File_01');
		fileObjForImage.Content_Version__c = contentVersionObj.id;
		update fileObjForImage;
        Bookmark__c bookmarkObjForImage =  TestHelper.createContentBookmark(null, UserContext.peopleId);
        bookmarkObjForImage.External_File_Id__c = fileObjForImage.Content_Version__c;
        bookmarkObjForImage.Is_Deleted__c = false;
        bookmarkObjForImage.Type__c = 'Intranet';
        update bookmarkObjForImage;
		PageReference pageRef = Page.DataServerRO;		
		SimpplrContext.isNativeVideo = true;
		pageRef.getParameters().put('target','FileDataServer');
		pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"filter": "favorites", "provider":"Intranet", "term" : "Title", "size": 16}');
        Test.setCurrentPage(pageRef);
		FileDataServer dSObj= new FileDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK',200,'searchFiles',false));
        dSObj.handleRequest();
		pageRef.getParameters().put('data','{"filter": "favorites", "provider":"Intranet", "size": 16}');
		dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
	 }
    
    @isTest static void deleteVideo() {
        Simpplr_Content__c content = [Select id From Simpplr_Content__c where title__c =: 'simpplr test BlogPost'];
        File__c fileObj =  TestHelper.createContentTitleImage(content.id);
        fileObj.External_Id__c = '1_ionhbfw6';
        update fileObj;
        Criteria.FileDeleteParams deleteFolderCriteriaObjArg=new Criteria.FileDeleteParams();
		deleteFolderCriteriaObjArg.fileId=(new List<String>{'1_ionhbfw6'});
    	deleteFolderCriteriaObjArg.provider='native_video';
        String str = JSON.serialize(deleteFolderCriteriaObjArg);
		PageReference pageRef = Page.DataServerRO;		
		SimpplrContext.isNativeVideo = true;
		FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('target','FileDataServer');
		pageRef.getParameters().put('action','deleteFile');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('data',str);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/Videos',false));
		dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
		Test.stopTest();
     }
     
     @isTest static void testSyncAllCompanyGoogleDriveGroup() {
        User stdUserObj = [SELECT id from User limit 1];

        if (stdUserObj == null) {
            stdUserObj = TestHelper.createUser('Simpplr_usr12', null, false); 
        }

        People__c peopleObject = [SELECT id from People__c limit 1];

        if (peopleObject == null) {
            peopleObject = TestHelper.createPeopleRecordForUser(stdUserObj.id); 
        }

        People_Integration__c peopleIntObj = new People_Integration__c();
        peopleIntObj.User_Email__c = 'xyz@abc.com';
        peopleIntObj.name = 'googledrive';
        peopleIntObj.people__c = peopleObject.id;
        insert peopleIntObj;

    	FileDataServer dSObj= new FileDataServer();
        PageReference pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','FileDataServer');
        pageRef.getParameters().put('data', '{}');
        pageRef.getParameters().put('action','syncAllCompanyGoogleDriveGroup');
        Test.setCurrentPage(pageRef);
        dSObj.handleRequest();

        System.assertEquals('success', dSObj.response.status, 'Failed: Add members to the group in bulk');
    }    

    @isTest 
    static void testGetGoogleDriveLinkFolders(){
        Simpplr_Site__c siteObj = new Simpplr_Site__c(
            name = 'testSite',
            Is_Active__c = true
        );
        insert siteObj;

        Folder__c folder = TestHelper.createChatterFolder('Test Folder', null, siteObj.id, 'googledrive', 'googledrive', null);
        folder.Drive_Type__c = 'shareddrive';
        folder.Is_System_Folder__c = false;
        folder.External_Folder_Id__c = '12345';
        update folder; 

		Test.startTest();

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);

        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));

        // File Instance
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getGoogleDriveLinkFolders');

        pageRef.getParameters().put('data','{"storage":"googledrive", "type":"mydrive"}');
        dSObj.handleRequest();

        System.assertEquals('success', dSObj.response.status, 'Error: retrieve my drive folders');
        System.assertNotEquals(null, dSObj.response.result, 'Failed: retrieve my drive folders');

        pageRef.getParameters().put('data','{"storage":"googledrive", "type":"shareddrive"}');
        dSObj.handleRequest();

        System.assertEquals('success', dSObj.response.status, 'Error: retrieve shared drives');
        System.assertNotEquals(null, dSObj.response.result, 'Failed: retrieve shared drives');

        Test.stopTest();
    }
    
    @isTest 
    static void testGetSiteSharedDriveDetails(){
        eSite = getSimpplrSite('FileDataServerTestExternal');

        Test.startTest();

		PageReference pageRef = Page.DataServerRO;
		pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);

        // File Instance
        FileDataServer dSObj= new FileDataServer();
		pageRef.getParameters().put('action','getSiteSharedDriveDetails');
		pageRef.getParameters().put('data','{"storage":"googledrive", "siteId":"'+eSite.id+'"}');

		Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));
		
		dSObj.handleRequest();

		Criteria.Folder folderObjArg= new Criteria.Folder();
        folderObjArg.storage = 'googledrive';
        folderObjArg.siteId = eSite.id;

        ResponseWrapper response = dSObj.getSiteSharedDriveDetails(folderObjArg);
        Map<String, Object> result = (Map<String, Object>) response.result;

        System.assertEquals('success', response.status, 'Error in shared drive link limit validation for site');
        System.assertEquals(true, result.get('isSharedDriveLinkedWithSite'), 'Failed to validate whether shared drive already linked to the site');
    }
    
    @isTest 
    static void getFileFolderPermissionGoogle(){
        eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'googledrive';
        update eSite;
        Folder__c folderObj = TestHelper.createChatterFolder('Google', null, eSite.Id, 'googledrive', null, null);
		folderObj.External_Folder_Id__c = 'googledrivetfolder';
		update folderObj;		
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        // File Instance
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getFileFolderPermission');
        pageRef.getParameters().put('data','{"itemId" : "'+folderObj.External_Folder_Id__c+'", "siteId" : "'+eSite.id+'", "provider" : "googledrive", "isDir": "true"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'googledrive/FileDetails',false));		
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest 
    static void getFileFolderPermissionSharepoint(){
        eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'sharepoint';
        update eSite;
        Folder__c folderObj = TestHelper.createChatterFolder('Sharepoint', null, eSite.Id, 'sharepoint', null, null);
		folderObj.External_Folder_Id__c = 'sharepointfolder';
		update folderObj;		
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        // File Instance
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getFileFolderPermission');
        pageRef.getParameters().put('data','{"itemId" : "'+folderObj.External_Folder_Id__c+'", "siteId" : "'+eSite.id+'", "provider" : "sharepoint", "isDir": "true"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'sharepoint/FileDetails',false));		
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest 
    static void getFileFolderPermissionBoxFolder(){
        eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'box';
        update eSite;		
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        // File Instance
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getFileFolderPermission');
        pageRef.getParameters().put('data','{"itemId" : "5000948880", "siteId" : "'+eSite.id+'", "provider" : "box", "isDir": "true"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/FileDetails',false));		
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest 
    static void getFileFolderPermissionBoxFile(){
        eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'box';
        update eSite;		
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        // File Instance
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getFileFolderPermission');
        pageRef.getParameters().put('data','{"itemId" : "5000948880", "siteId" : "'+eSite.id+'", "provider" : "box", "isDir": "false"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/FileDetails',false));		
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest 
    static void getFileFolderPermissionBoxFail(){
        eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'box';
        update eSite;		
        PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);
        // File Instance
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getFileFolderPermission');
        pageRef.getParameters().put('data','{"itemId" : "5000948880", "siteId" : "'+eSite.id+'", "provider" : "box", "isDir": "false"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'Box/FileDetails',true));		
        dSObj.handleRequest();
        System.assertEquals('success', dSObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest
    static void searchGoogleDriveFilesSharedDriveTest() {
        eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'googledrive';
        update eSite;
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);  
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"term" : "simpplr", "siteId" : "'+eSite.id+'", "provider" : "googledrive", "driveType" : "shareddrive"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'FileDataServer/searchGoogleDrive',false));		
        dSObj.handleRequest();
        ResponseWrapper response  = dSObj.response;   
        FileListingWrapper.PaginationWrapper result = (FileListingWrapper.PaginationWrapper) response.result;                 
        System.assertEquals('success', response.status, 'Failed - Status should have been success');
        System.assertEquals('Test Folder 12345', result.shareddriveName, 'Failed - folder name is incorrect');
    }

    @isTest
    static void searchGoogleDriveFilesMyDriveTest() {
        eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'googledrive';
        update eSite;        
        Folder__c folder = TestHelper.createChatterFolder('Test Folder 12346', null, eSite.id, 'googledrive', 'googledrive', null);
        folder.Drive_Type__c = 'mydrive';
        folder.Is_System_Folder__c = false;
        folder.External_Folder_Id__c = '12346';
        update folder;   
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);  
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"term" : "simpplr", "siteId" : "'+eSite.id+'", "provider" : "googledrive", "driveType" : "mydrive"}');	
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'FileDataServer/searchGoogleDrive',false));		
        dSObj.handleRequest();
        ResponseWrapper response  = dSObj.response;   
        FileListingWrapper.PaginationWrapper result = (FileListingWrapper.PaginationWrapper) response.result;                 
        System.assertEquals('success', response.status, 'Failed - Status should have been success');
        System.assertEquals(true, result.isMyDriveFolderLinked, 'Failed - isMyDriveFolderLinked should have been true');
        Test.stopTest();    
    }
    
      @isTest
   static void testCreateBoxFolder() {
        eSite = getSimpplrSite('FileDataServerTestExternal');
        eSite.File_Storage_Source__c = 'box';
        update eSite;         
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);  
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','createBoxFolder');
       	pageRef.getParameters().put('siteId',eSite.id);
        pageRef.getParameters().put('data','{"directory":"new Directory","rootDirectory":null,"name":"Box Fldr 11","permissions":"read","siteId":"'+eSite.id+'"}');	
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'/Box/CreateFolder',true));		
        dSObj.handleRequest();               
        System.assertEquals('success', dSObj.response.status, 'Running As Expected');
		Test.stopTest();    
    }   
    
   @isTest
   static void getAudienceCSVDownloadURL() {       
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','FileDataServer');
        Test.setCurrentPage(pageRef);  
        FileDataServer dSObj= new FileDataServer();
        pageRef.getParameters().put('action','getAudienceCSVDownloadURL');
        pageRef.getParameters().put('data','{"fileId":"dummy"}');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'getCSVDownloadUrl',true));		
        dSObj.handleRequest();               
        System.assertEquals('success', dSObj.response.status, 'Running As Expected');
        Test.stopTest();    
    }  

}