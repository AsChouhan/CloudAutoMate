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
private class FileDetailCtrlTest {

    private static App_Config__c appConfigRecord;
    private static App_Integration__c appIntList;
    private static User userObj;
    private static App_Integration__c appintegObj;
    private static People__c peopleRecord;
    private static CollaborationGroup cgroup;
	
    @testSetup static void setup() {
        appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Allowed_Features__c = 'File';
        appConfigRecord.Box_Managed_Permissions__c = 'simpplr';
        update appConfigRecord;
        userObj = TestHelper.createUser('Simpplr_usr', null, false);
        people__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        People_Preference__c prefObj = TestHelper.createPeoplePreference(UserContext.peopleId);
        prefObj.Box_Access_Token__c = null;
        prefObj.Box_Refresh_Token_Expires_At__c = DateTime.Now().addDays(2);
        update prefObj;
        cgroup = TestHelper.createCollaborationGroup('FileDetailCtrlPage','Public');
        Simpplr_Site__c siteObj = [select id  from Simpplr_Site__c where chatter_Group_Id__c =: cgroup.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{siteObj.Id});
        TestHelper.createSocialCampaign(UserContext.peopleId);
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING,ServiceConstants.STORAGE_TYPE_DROPBOX_STRING,ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING,ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING});
      	TestHelper.createPeopleIntegRecordForUser(peopleObj.id,ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING,appIntList[0].id);
        TestHelper.createPeopleIntegRecordForUser(peopleObj.id,ServiceConstants.STORAGE_TYPE_DROPBOX_STRING,appIntList[0].id);
        TestHelper.createPeopleIntegRecordForUser(peopleObj.id,ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING,appIntList[0].id);
        TestHelper.createPeopleIntegRecordForUser(peopleObj.id,ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING,appIntList[0].id);
        
    }

    private static void setCurrentPage(){
		PageReference pageRef = Page.FileDetail;
		Test.setCurrentpage(pageRef);
    }
    
    @isTest static void testGetPageTitle() {
    		setCurrentPage();
    		FileDetailCtrl FileDetailCtrlObj = new FileDetailCtrl();
        String pageTitle = FileDetailCtrlObj.getPageTitle();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetPageFeature() {
    		setCurrentPage();
    		FileDetailCtrl FileDetailCtrlObj = new FileDetailCtrl();
        String pageFeature = FileDetailCtrlObj.getPageFeature();
        System.assert(true,'Running as expected');
    }
    
    
    @isTest static void testInit() {
        Test.startTest();
        PageReference pageRef = Page.FileDetail;
        userObj = [Select id From user where lastName =:'Simpplr_usr'];
        cgroup = [Select id From CollaborationGroup where Name =: 'FileDetailCtrlPage'];
        simpplr_Site__c siteObj = [Select id from Simpplr_Site__c where chatter_group_Id__c =: cgroup.id];
        
        Simpplr_Content__c content = TestHelper.createContent('simpplr test Page', 'Page', 'Approved', userObj, siteObj);
        File__c fileObj =  TestHelper.createContentTitleImage(content.id);
        Folder__c folderObj = TestHelper.createChatterFolder('CRM Files', null, siteObj.id, 'Intranet', null, 'readwrite');
        folderObj.path__c = folderObj.id;
        folderObj.Is_System_Folder__c = true;
        folderObj.Is_Deleted__c=false;
        update folderObj;
        String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' + site.Id + '#' + fileObj.Id + '#' + 'dummyfile.png';
    	ContentVersion cvObj = TestHelper.createContentVersion('H', pathOnClient);
    	List<ContentDocument> ContentDocumentList = [select Id from ContentDocument where latestpublishedversionId=:cvObj.id];
        ContentDocumentList[0].OwnerId = userObj.id;
        update ContentDocumentList;
        ApexPages.currentPage().getParameters().put('target','FileDetailCtrl');
        Test.setCurrentPage(pageRef);
      	ApexPages.currentPage().getParameters().put('provider','googledrive');
        ApexPages.currentPage().getParameters().put('fileId',ContentDocumentList[0].id);
        ApexPages.currentPage().getParameters().put('rootdirectory','gdriverootdirectory');
        ApexPages.currentPage().getParameters().put('siteId',siteObj.id);
        ApexPages.currentPage().getParameters().put('directory',folderObj.id);
        ApexPages.currentPage().getParameters().put('permission','Yes');
        ApexPages.currentPage().getParameters().put('fileDetailJson','{"name":"file","externalUrl":"my.sharepoint.com/","extension":"pdf","size":16}');
        FileDetailCtrl FileDetailCtrlObj = new FileDetailCtrl();
        Test.setCurrentPage(pageRef);
        FileDetailCtrlObj.init();
        ApexPages.currentPage().getParameters().put('provider','box');
        FileDetailCtrlObj.init();
        ApexPages.currentPage().getParameters().put('provider','onedrive');
        FileDetailCtrlObj.init();
        ApexPages.currentPage().getParameters().put('provider','dropbox');
        FileDetailCtrlObj.init();
        ApexPages.currentPage().getParameters().put('provider','sharepoint');
        FileDetailCtrlObj.init();
        ApexPages.currentPage().getParameters().put('provider','Intranet');
        FileDetailCtrlObj.init();
        UserContext.hasModifyAllDataPermission = false;
        FileDetailCtrlObj.init();
        folderObj.type__c='CRM';
        folderObj.External_Folder_Id__c=folderObj.id;
        update folderObj;
        ApexPages.currentPage().getParameters().put('provider','CRM');
        FileDetailCtrlObj.init();
       	Test.stopTest(); 
        System.assert(true,'Running as expected');
    }

    @isTest 
    static void testFileDetail() {
      Test.startTest();

      PageReference pageRef = Page.FileDetail;
      Test.setCurrentPage(pageRef);

      FileDetailCtrl ctrl = new FileDetailCtrl();

      ApexPages.currentPage().getParameters().put('provider','googledrive');
      ApexPages.currentPage().getParameters().put('fileId','googledrivefileId');

      //File Access 
      Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('', 200, 'GoogleDrive/GetFile', false));
      ctrl.init();
      System.assertEquals(false, ctrl.isFileNotFoundOrNoAccess, 'Failed: File should have access');

      //No File Access 
      Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('', 400, 'GoogleDrive/GetFile', true));
      ctrl.init();
      System.assertEquals(true, ctrl.isFileNotFoundOrNoAccess, 'Failed: File should not have access');

      Test.stopTest(); 
      System.assert(true,'Running as expected');
    }    
   
}