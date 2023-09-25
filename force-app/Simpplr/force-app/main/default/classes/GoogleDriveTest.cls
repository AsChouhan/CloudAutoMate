@isTest 
private with sharing class GoogleDriveTest {
    static App_Config__c appConfig;
    static People__c currentUserPeopleObj; 
    private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
    private static Simpplr_Site__c site;
    private static Folder__c folderRecord; 

    @testSetup static void setup() {
		appConfig = TestHelper.setupAppConfig();
        currentUserPeopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        cgroup = TestHelper.createCollaborationGroup('AlbumDataServerTest_Grp1','Public');
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(cgroup.Id);
        testSite.File_Storage_Source__c = 'googledrive';
        testSite.Title_Content_Version__c = 'google';
        update testSite;

        folderRecord = new Folder__c();
        folderRecord.site__c = testSite.id;
        folderRecord.External_folder_id__c = '1234';
        folderRecord.Is_System_Folder__c = true; 
        folderRecord.Is_Deleted__c = false; 
        folderRecord.Type__c = 'googledrive';
        insert folderRecord; 

    }
    
    @isTest 
    static void GDAdapterConvertToFileDetailWrapperTest() {
        PageReference pageRef = Page.FileDetail;
		Test.setCurrentpage(pageRef);
        FileDetailCtrl FileDetailCtrlObj = new FileDetailCtrl();
        GoogleDriveModel.File fileObj = new GoogleDriveModel.File();
        fileObj.id = '123';
        fileObj.name = 'test.jpeg';
        fileObj.size = 400;
        fileObj.modifiedTime = System.now();
        fileObj.fileType = 'jpeg';
        fileObj.version = 4;
        fileObj.capabilities = new GoogleDriveModel.Capability();
        fileObj.capabilities.canAddChildren = true;
        fileObj.capabilities.canDownload = true;
        fileObj.capabilities.canRename = true;
        fileObj.capabilities.canShare = true;
        fileObj.capabilities.canEdit = true;
        fileObj.parents = new List<String>();
        fileObj.parents.add('1234');
        FileDetailWrapper fileDetailWrapObj = new GoogleDriveDataAdapter().convertToFileDetailWrapper(fileObj);
        System.assertEquals('JPEG',fileDetailWrapObj.type , 'Running as expected');
    }

    @isTest 
    static void GDAdapterConvertToFileDetailWrapper1Test() {
        PageReference pageRef = Page.FileDetail;
		Test.setCurrentpage(pageRef);
        FileDetailCtrl FileDetailCtrlObj = new FileDetailCtrl();
        GoogleDriveModel.File fileObj = new GoogleDriveModel.File();
        fileObj.id = '123';
        fileObj.name = 'test';
        fileObj.size = 400;
        fileObj.mimeType = 'mimeType/jpeg';
        fileObj.modifiedTime = System.now();
        fileObj.fileType = 'jpeg';
        fileObj.version = 4;
        fileObj.capabilities = new GoogleDriveModel.Capability();
        fileObj.capabilities.canAddChildren = false;
        fileObj.capabilities.canDownload = true;
        fileObj.capabilities.canRename = true;
        fileObj.capabilities.canShare = true;
        fileObj.capabilities.canEdit = true;
        fileObj.parents = new List<String>();
        fileObj.parents.add('1234');
        fileObj.owners = new List<GoogleDriveModel.Owner>();
        GoogleDriveModel.Owner ownerObj = new GoogleDriveModel.Owner();
        ownerObj.emailAddress = 'test@test.com';
        ownerObj.displayName = 'test test';
        fileObj.owners.add(ownerObj);
        FileDetailWrapper result = new GoogleDriveDataAdapter().convertToFileDetailWrapper(fileObj);
        system.assertEquals('123', result.id, 'Running as expected');
    }

    @isTest 
    static void GDAdapterConvertToDirectoryWrapperTest() {
        GoogleDriveModel.File fileObj = new GoogleDriveModel.File();
        fileObj.id = '123';
        fileObj.name = 'test.jpeg';
        fileObj.size = 400;
        fileObj.modifiedTime = System.now();
        fileObj.fileType = 'jpeg';
        fileObj.version = 4;
        fileObj.capabilities = new GoogleDriveModel.Capability();
        fileObj.capabilities.canAddChildren = true;
        fileObj.capabilities.canDownload = true;
        FileListingWrapper.DirectoryWrapper directoryWrapperObj = new GoogleDriveDataAdapter().convertToDirectoryWrapper(fileObj);

        System.assertNotEquals(directoryWrapperObj, null, 'DirectoryWrapper object is null!');
    }

    @isTest 
    static void GDAdapterConvertGoogleDriveFileToFileListingWrapperTest() {
        GoogleDriveModel.File fileObj = new GoogleDriveModel.File();
        fileObj.id = '123';
        fileObj.name = 'test.jpeg';
        fileObj.size = 400;
        fileObj.mimeType = 'mimeType/jpeg';
        fileObj.modifiedTime = System.now();
        fileObj.fileType = 'jpeg';
        fileObj.version = 4;
        fileObj.capabilities = new GoogleDriveModel.Capability();
        fileObj.capabilities.canAddChildren = true;
        fileObj.capabilities.canDownload = true;
        fileObj.capabilities.canRename = true;
        fileObj.capabilities.canShare = true;
        fileObj.capabilities.canEdit = true;
        fileObj.parents = new List<String>();
        fileObj.parents.add('1234');
        fileObj.owners = new List<GoogleDriveModel.Owner>();
        GoogleDriveModel.Owner ownerObj = new GoogleDriveModel.Owner();
        ownerObj.emailAddress = 'test@test.com';
        ownerObj.displayName = 'test test';
        fileObj.owners.add(ownerObj);
        FileListingWrapper fileListingObj = new GoogleDriveDataAdapter().convertGoogleDriveFileToFileListingWrapper(fileObj);

        System.assertNotEquals(fileListingObj, null, 'FileListing object is null!');
    }

    @isTest 
    static void GDAdapterConvertGoogleDriveFileToFileListingWrapper1Test() {
        GoogleDriveModel.File fileObj = new GoogleDriveModel.File();
        fileObj.id = '123';
        fileObj.name = 'test.jpeg';
        fileObj.size = 400;
        fileObj.mimeType = 'application/vnd.google-apps.folder';
        fileObj.modifiedTime = System.now();
        fileObj.fileType = 'jpeg';
        fileObj.version = 4;
        fileObj.capabilities = new GoogleDriveModel.Capability();
        fileObj.capabilities.canAddChildren = true;
        fileObj.capabilities.canDownload = true;
        fileObj.capabilities.canRename = true;
        fileObj.capabilities.canShare = true;
        fileObj.capabilities.canEdit = true;
        fileObj.parents = new List<String>();
        fileObj.parents.add('1234');
        fileObj.owners = new List<GoogleDriveModel.Owner>();
        GoogleDriveModel.Owner ownerObj = new GoogleDriveModel.Owner();
        ownerObj.emailAddress = 'test@test.com';
        ownerObj.displayName = 'test test';
        fileObj.owners.add(ownerObj);
        new GoogleDriveDataAdapter().convertGoogleDriveFileToFileListingWrapper(fileObj);
        fileObj.mimeType = 'application/pdf';
        fileObj.name = 'test';
        FileListingWrapper result = new GoogleDriveDataAdapter().convertGoogleDriveFileToFileListingWrapper(fileObj);
        system.assertEquals('123', result.id, 'Running as expected');
    }

    @isTest 
    static void GDAdapterConvertListOfFilesToWrapperTest() {
        GoogleDriveModel.File fileObj = new GoogleDriveModel.File();
        fileObj.id = '123';
        fileObj.name = 'test.jpeg';
        fileObj.size = 400;
        fileObj.modifiedTime = System.now();
        fileObj.fileType = 'jpeg';
        fileObj.version = 4;
        fileObj.capabilities = new GoogleDriveModel.Capability();
        fileObj.capabilities.canAddChildren = true;
        fileObj.capabilities.canDownload = true;
        fileObj.capabilities.canRename = true;
        fileObj.capabilities.canShare = true;
        fileObj.capabilities.canEdit = true;
        fileObj.parents = new List<String>();
        fileObj.parents.add('1234');
        List<GoogleDriveModel.File> listOfFiles = new List<GoogleDriveModel.File>();
        fileObj.permissions = new List<GoogleDriveModel.Permission>();
        GoogleDriveModel.Permission permObj = new GoogleDriveModel.Permission();
        permObj.displayName  = 'reader';
        permObj.id = '1234';
        permObj.role = 'member';
        permObj.emailAddress = '0f912345689_r@test.com';
        fileObj.permissions.add(permObj);
        listOfFiles.add(fileObj);
        List<FileListingWrapper> result = new GoogleDriveDataAdapter().convertListOfFilesToWrapper(listOfFiles);
        system.assertEquals('123', result[0].id, 'Running as expected');
    }

    @isTest 
    static void GDAdapterConvertToTileDataListTest() {
        List<TileDataWrapper.TileData> tileDataList = new List<TileDataWrapper.TileData>();
        try{
            GDAPIModelFileList listRes = new GDAPIModelFileList();
            tileDataList = new GoogleDriveDataAdapter().convertToTileDataList(listRes);
        } catch(Exception e){

        }

        System.assertEquals(true, tileDataList.isEmpty(), 'Invalid TileData list!');
    }
    

    @isTest 
    static void GDAdapterFetchSiteInfoTest() {
        List<GoogleDriveModel.Permission> listOfPermissions = new List<GoogleDriveModel.Permission>();
        GoogleDriveModel.Permission permObj = new GoogleDriveModel.Permission();
        permObj.displayName  = 'reader';
        permObj.id = '1234';
        permObj.role = 'member';
        listOfPermissions.add(permObj);
        List<SiteLiteWrapper> siteWrapperList = new GoogleDriveDataAdapter().fetchSiteInfo(listOfPermissions);

        System.assertEquals(true, siteWrapperList.isEmpty(), 'Invalid SiteWrapper list!');
    }
    
    
}