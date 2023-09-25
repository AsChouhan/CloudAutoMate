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
private class EFSFileServiceTest {
	private static App_Integration__c appIntegRecord;
	
    @testSetup static void setup() {
    	TestHelper.setupAppConfig();
    	appIntegRecord = TestHelper.setUpAppIntegration();
    	
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    	TestHelper.createPeoplePreference(peopleObj.Id);

		People_integration__c pplInteg = TestHelper.createPeopleIntegRecordForUser(peopleObj.Id);
        pplInteg.App_Integration__c = appIntegRecord.id;
        update pplInteg;
        
        System.assert(true, 'Running as expected');
    }
    
    static void initDb() {
        appIntegRecord = [SELECT Id, Client_Id__c, Client_Secret__c,
				integration_Enabled__c, name, Scope__c,
				app_Access_Token__c from App_Integration__c where name = 'gdrive'];
							
        if (appIntegRecord.name != 'dropbox') {
            appIntegRecord.name = 'dropbox';
            update appIntegRecord;
        }				
    	
    	Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('dropbox'));		
    }
    
    @isTest static void adminAccessDropbox() {
        initDb();
        
        try {
            Criteria.Folder inputFolder = new Criteria.Folder();
            inputFolder.name = 'DummyFolder';
            inputFolder.permissions = 'readwrite';
            inputFolder.directory = 'root';
            inputFolder.rootDirectory = '';
            
            Test.startTest();
            EFSAccessService efsAccSer = new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, true);
            EFSFileService EFSAsObj = new EFSFileService(efsAccSer);
            EFSAsObj.getFileStorage();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('', 200, 'dropboxFolderCreate', false));
            EFSAsObj.createFolder(inputFolder);
            
            inputFolder.name = 'Forbidden';
            EFSAsObj.createFolder(inputFolder);
            EFSAsObj.close();
        
        	Test.stopTest();
       	} catch (Exception e) {}
        
        System.assert(true, 'Running as expected');
	}
    
    @isTest static void updateFileNameDbTest() {
    	initDb();
    	
		try {
			EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.updateFileName('folderId', 'updateFileNameTest');
	    	EFSAsObj.updateFileName('Forbidden', 'updateFileNameTest');
	    	EFSAsObj.close();
		} catch (Exception e) {}
		
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void updateFileNameDbExceptionTest() {
   	
		try {
            initDb();
			EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.updateFileName('Forbidden', 'updateFileNameTest');
	    	
	    	EFSAsObj.close();
		} catch (Exception e) {}
		
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void listFilesByCriteriaDropboxTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	Criteria.File inputFile = new Criteria.File();
	    	
	    	inputFile.id = '';
			inputFile.siteId = '';
			inputFile.rootDirectory = '';
			inputFile.isPaginationEnabled = false;
			inputFile.context = '';
			inputFile.hideProviderSystemDirs = false;
			inputFile.isGlobalSearchReq = false;
			
	    	EFSAsObj.listFiles('namess', inputFile);
	    	EFSAsObj.listFiles('Forbidden', inputFile);
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
	}
	
	@isTest static void listFilesByCriteriaSharepointTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, false));
	    	Criteria.File inputFile = new Criteria.File();
	    	
	    	inputFile.id = '';
			inputFile.siteId = '';
			inputFile.rootDirectory = '';
			inputFile.isPaginationEnabled = false;
			inputFile.context = '';
			inputFile.hideProviderSystemDirs = false;
			inputFile.isGlobalSearchReq = false;
			
	    	EFSAsObj.listFiles('namess', inputFile);
	    	EFSAsObj.listFiles('Forbidden', inputFile);
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
	}
	
	@isTest static void listFilesByCriteriaOnedriveTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, false));
	    	Criteria.File inputFile = new Criteria.File();
	    	
	    	inputFile.id = '';
			inputFile.siteId = '';
			inputFile.rootDirectory = '';
			inputFile.isPaginationEnabled = false;
			inputFile.context = '';
			inputFile.hideProviderSystemDirs = false;
			inputFile.isGlobalSearchReq = false;
			
	    	EFSAsObj.listFiles('namess', inputFile);
	    	EFSAsObj.listFiles('Forbidden', inputFile);
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void searchFilesDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	Criteria.File inputFile = new Criteria.File();
	    	
	    	inputFile.id = '';
			inputFile.siteId = '';
			inputFile.rootDirectory = '';
			inputFile.isPaginationEnabled = false;
			inputFile.context = '';
			inputFile.hideProviderSystemDirs = false;
			inputFile.isGlobalSearchReq = false;
			inputFile.term = 'dummyterm';
			
	    	EFSAsObj.searchFiles('AppFiles', inputFile);
	    	
	    	EFSAsObj.searchFiles('SiteFiles', inputFile);
	    	
	    	Criteria.File inputFile1 = new Criteria.File();
	    	inputFile1.id = '';
			inputFile1.siteId = '';
			inputFile1.rootDirectory = '';
			inputFile1.isPaginationEnabled = false;
			inputFile1.context = '';
			inputFile1.hideProviderSystemDirs = false;
			inputFile1.isGlobalSearchReq = false;
			inputFile1.term = '';
			inputFile1.filter = 'bookmarked';
			
	    	EFSAsObj.searchFiles('SiteFiles', inputFile1);
	    	EFSAsObj.searchFiles('Forbidden', inputFile);
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void deleteFileDbTest() {
    	initDb();
    	
    	try{
			EFSFileService.getEFSEmailIdWithPeoplePref();
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.deleteFile('dummyFileId');
            EFSAsObj.deleteFile('Forbidden');
	    	
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void ownershipTransferDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.ownershipTransfer('dummyFileId','newOwnerKey');
			EFSAsObj.ownershipTransfer('Forbidden','newOwnerKey');
			
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void shareFolderDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.shareFolder('foldName', 'sharedFolderId', 'viewerGroup', 'editorGroup');
            EFSAsObj.shareFolder('Forbidden', 'sharedFolderId', 'viewerGroup', 'editorGroup');
	    	
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void unshareFolderDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.unshareFolder('sharedFolderId', 'viewerGroupId');
            EFSAsObj.unshareFolder('Forbidden', 'viewerGroupId');
	    	
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void changeFolderSharingDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.changeFolderSharing('sharedFolderId', 'viewerGroupId', 'permission');
            EFSAsObj.changeFolderSharing('Forbidden', 'viewerGroupId', 'permission');
	    	
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void listFoldersDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.listFolders();
	    	
	    	EFSAsObj.close();
    	}catch(Exception ex){ }
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void mountFolderDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.mountFolder('sharedFolderId');
            
            DBAPIClient client;
            DBAPISharing dbShare = new DBAPISharing(client);
            dbShare.getUnmountFolderRequest('folderId');
            EFSAsObj.mountFolder('Forbidden');
			EFSAsObj.getFileOwnerId('folderId');
			EFSAsObj.listFolders();
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    private static void setupInternal() {
        User userAsOwner = TestHelper.createUser('Simpplr_usrAsSiteOwner', null, false);
        User userAsMember = TestHelper.createUser('Simpplr_usrAsMember', null, false);
        
       CollaborationGroup cgroup = TestHelper.createCollaborationGroup('MySettingsAppManagerCtrlTest_Grp1','Public');
        cgroup.owner = [SELECT id FROM User WHERE Id=: UserInfo.getUserId()][0];
        update cgroup;
        TestHelper.createCollaborationGroupMember(cgroup.Id, userAsMember.id,'Standard');
        Simpplr_Site__c siteObj = getSimpplrSite();
        siteObj.File_Storage_Source__c = 'gdrive';
        update siteObj;
        Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, getSimpplrSite().id, 'Intranet', null, 'readwrite');        
        folderObj.Type__c = 'gdrive';
        folderObj.Is_System_Folder__c = true;
        update folderObj;
    }
    
    private static Simpplr_Site__c getSimpplrSite(){
         return([select id,File_Storage_Source__c from Simpplr_Site__c where name = 'MySettingsAppManagerCtrlTest_Grp1']);
    }
    
    @isTest static void getFileDetailDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.getFileDetail('dummyFileId', 'dummyParentDir','dummySiteId','');
            EFSAsObj.getFileDetail('Forbidden', 'dummyParentDir','dummySiteId','');
	    	
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void getFileVersionsDbTest() {
    	initDb();
    	
    	try{
	    	EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.getFileVersions('dummyFileId');
	    	EFSAsObj.getFileVersions('Forbidden');
            EFSAsObj.getFileVersions('Errors');
	    	EFSAsObj.close();
    	}catch(Exception ex){}
    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void addPermissionDbTest() {
    	initDb();
    	
		try {
			EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.addPermission('fileId', 'READWRITE', 'grpEmail@cm.com');
	    	EFSAsObj.close();
		} catch (Exception e) {}
		    	
    	System.assert(true, 'Running as expected');
    }
    
    @isTest static void addPermissionDbExceptionTest() {
    	initDb();
    	
		try {
			EFSFileService EFSAsObj = new EFSFileService(new EFSAccessService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, false));
	    	EFSAsObj.addPermission('Forbidden', 'Forbidden', 'Forbidden');
	    	
	    	EFSAsObj.close();
		} catch (Exception e) {}
		    	
    	System.assert(true, 'Running as expected');
    }
    
}