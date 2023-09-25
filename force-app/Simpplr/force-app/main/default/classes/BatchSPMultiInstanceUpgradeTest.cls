@isTest
public class BatchSPMultiInstanceUpgradeTest {
    
    @testSetup static void setup() {
        TestHelper.setupAppConfig();
        TestHelper.setupAppConfig();
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        
        List<App_Integration__c> appIntegList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'sharepoint'});
        List<People_Integration__c> piObj = TestHelper.createPeopleIntegrationRecords(appIntegList, UserContext.peopleId, 'sharepoint');
        piObj[0].Access_Token_Expiry__c = 3600;
        piObj[0].Refresh_Token__c = 'dummypeopleaccesstoken';
        piObj[0].Access_Token_Requested_Datetime__c = DateTime.now().addDays(-20);
        update piObj;

        Test.startTest();
            Folder__c folderRecord = new Folder__c();
            folderRecord.Name__c = 'sharepoint';
            folderRecord.Type__c = 'sharepoint';
            folderRecord.Permissions__c = 'readwrite';
            folderRecord.External_folder_id__c = '1234';
            folderRecord.Is_System_Folder__c = false; 
            folderRecord.Is_Deleted__c = false; 
            insert folderRecord; 
        Test.stopTest();
    }

    @isTest
    public static void testUnlinkFolder() {
        Test.startTest();
            DataBase.executeBatch(new BatchSPMultiInstanceUpgrade('unlinkFolders', false));
        Test.stopTest();

        List<Folder__c> folderList = [SELECT Is_Deleted__c FROM Folder__c];
        System.assertEquals(1, folderList.size(), 'Failed retrieving the folder after unlinking');
        System.assertEquals(true, folderList[0].Is_Deleted__c, 'Failed deleting folder records');
    }
    
    @isTest
    public static void testPopulateInstanceId() {
        List<People_Integration__c> peopleIntegList = [SELECT Id FROM People_Integration__c];
        for(People_Integration__c pplInt:peopleIntegList) {
            pplInt.SP_Instance_Id__c = null;
        }
        update peopleIntegList;

        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('sharepoint'));
        Test.startTest();
            DataBase.executeBatch(new BatchSPMultiInstanceUpgrade('populateInstanceId', false));
        Test.stopTest();

        List<People_Integration__c> intList = [SELECT SP_Instance_Id__c FROM People_Integration__c];
        System.assertEquals(1, intList.size(), 'Failed retrieving the people integration list after populating sharepoint instance ids');
        System.assertEquals(false, String.isEmpty(intList[0].SP_Instance_Id__c), 'Failed populating sharepoint instance id on people integrations');
    }
    
    @isTest
    public static void testPopulateInstanceIdForInvalidRefreshToken(){
        List<People_Integration__c> peopleIntegList = [SELECT Id FROM People_Integration__c];
        for(People_Integration__c pplInt:peopleIntegList) {
            pplInt.SP_Instance_Id__c = null;
            pplInt.Access_Token_Requested_Datetime__c = DateTime.now();
        }
        update peopleIntegList;

        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('sharepoint'));
        Test.startTest();
            DataBase.executeBatch(new BatchSPMultiInstanceUpgrade('populateInstanceId', false));
        Test.stopTest();

        List<People_Integration__c> intList = [SELECT SP_Instance_Id__c FROM People_Integration__c];
        System.assertEquals(1, intList.size(), 'Failed retrieving the people integration list after populating sharepoint instance ids');
        System.assertEquals(true, String.isEmpty(intList[0].SP_Instance_Id__c), 'Failed populating sharepoint instance id on people integrations');
    }

    @isTest
    public static void testFolderPopulateInstanceId() {
        List<People_Integration__c> pplIntList = [SELECT Id FROM People_Integration__c];
        for(People_Integration__c pplInt:pplIntList) {
            pplInt.SP_Instance_Id__c = 'test-instance-id';
        }
        update pplIntList;
        
        Test.startTest();
            DataBase.executeBatch(new BatchSPMultiInstanceUpgrade('folderPopulateInstanceId', false));
        Test.stopTest();

        List<Folder__c> folderList = [SELECT SP_Instance_Id__c FROM Folder__c];
        System.assertEquals(1, folderList.size(), 'Failed retrieving the folder list after populating sharepoint instance ids');
        System.assertEquals(false, String.isEmpty(folderList[0].SP_Instance_Id__c), 'Failed populating sharepoint instance id on the folder records');
    }

    @isTest
    public static void testFilePopulateInstanceId() {
        List<People_Integration__c> pplIntList = [SELECT Id FROM People_Integration__c];
        for(People_Integration__c pplInt:pplIntList) {
            pplInt.SP_Instance_Id__c = 'test-instance-id';
        }
        update pplIntList;

        Simpplr_Content__c content = new Simpplr_Content__c();
        content.Title__c = 'testArticleRecord';
        content.Text_Intro__c = 'Example text';
        content.Text_Main__c = 'Example text';
        content.Text_Main_Continued__c = 'example text';
        content.Type__c = 'Page';
        content.Status__c = 'submitted';
        insert content;
        
        File__c file = new File__c();
        file.Is_Deleted__c = false;
        file.Title__c = 'Test';
        file.Simpplr_Content__c = content.Id;
        file.MIME_Type__c = 'txt';
        file.Likes__c = 2;
        file.Repository__c = 'sharepoint';
        file.External_Id__c = 'test-sp-id';
        insert file;

        Test.startTest();
            DataBase.executeBatch(new BatchSPMultiInstanceUpgrade('filePopulateInstanceId', false));
        Test.stopTest();

        List<File__c> fileList = [SELECT SP_Instance_Id__c FROM File__c];
        System.assertEquals(1, fileList.size(), 'Failed retrieving the file list after populating sharepoint instance ids');
        System.assertEquals(false, String.isEmpty(fileList[0].SP_Instance_Id__c), 'Failed populating sharepoint instance id on file records');
    }

}