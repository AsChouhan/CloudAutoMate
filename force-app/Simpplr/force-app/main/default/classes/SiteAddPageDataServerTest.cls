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
public class SiteAddPageDataServerTest {
    
    public static PageReference pageRef;   
    public static Pages_Category__c pageCategoryObj; 
    public static String data;
    public static String editData;
    public static String editData1;
    public static String siteId;   
    private static App_Config__c appConfigRecord;
    private static Simpplr_Content__c content;
    private static Simpplr_Content__c content1;
    private static ContentVersion cvObj;
    private static Folder__c folderObj;
    private static File__c fileObj;
    private static Simpplr_Site__c site;
    private static User standardUserObj;
    private static User managerUserObj;
    
    @testSetup 
    static void setup() {      
        TestHelper.setupAppConfig();
        if(managerUserObj==null){
            managerUserObj = TestHelper.createUser('Simpplr_mngr', null, false); 
        }
        if(standardUserObj==null){
            standardUserObj = TestHelper.createUser('Simpplr_usr', managerUserObj, false); 
        }
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id); 
        TestHelper.createPeoplePreference(peopleObj.id);
        
        if(site==null){
            CollaborationGroup collGrp = TestHelper.createCollaborationGroup('ContentDataServerTest_grp1', 'Public');
            site = [select id  from Simpplr_Site__c limit 1];
            TestHelper.shareSitesToAllPeople(new List<String>{site.Id});
        }
        
        content = TestHelper.createContent('simpplr test Page', 'Page', 'Approved', managerUserObj, site);
        TestHelper.createContentTitleImage(content.id);
        content1 = TestHelper.createContent('simpplr test Page1', 'Page', 'Approved', managerUserObj, site);
        TestHelper.createContentTitleImage(content1.id);
        Must_Read_Audit__c  mustReadAuditObj = TestHelper.createMustReadAudit(content1.id, 'everyone', UserContext.peopleId);
        mustReadAuditObj.Removed_DateTime__c = null;
        mustReadAuditObj.Expiry_DateTime__c = null;
        update mustReadAuditObj;
        cvObj = TestHelper.createContentVersion('bsnbmasbdmna', 'File_01');
        folderObj = TestHelper.createChatterFolder('testFolder01', null, site.Id, 'Intranet', null, 'readwrite');
        pageCategoryObj = TestHelper.createPageCategory(site.id, 'SiteAddPageDataServerTestPageCategroy');
    }
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
                                    Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
                                    From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }

    static void init() {
        pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SiteAddPageDataServer');
        Test.setCurrentPage(pageRef);      
        managerUserObj = [select Id, lastName from user where lastname like 'Simpplr_mngr%'][0];
        standardUserObj = [select Id, lastName from user where lastname like 'Simpplr_usr%'][0];
        site = [select id,chatter_group_id__c,External_Apps_Site_Config_Json__c,Microsoft_Teams_Integration_Enabled__c,Slack_Integration_Enabled__c  from Simpplr_Site__c where name ='ContentDataServerTest_grp1'][0];
        content = [select id, Title__c, Type__c, ownerId, Is_Published__c, Is_Deleted__c, Status__c, Site__c, Album_Image_Count__c, Last_Edited_DateTime__c, CreatedDate, Content_Sub_Type__c, Last_Validated_DateTime__c, Publish_End_DateTime__c, Text_Json__c
                    from simpplr_content__c where Title__c = 'simpplr test Page'][0];
        content1 = [select id, Title__c,version__c, Type__c, ownerId, Is_Published__c, Is_Deleted__c, Status__c, Site__c, Album_Image_Count__c, Last_Edited_DateTime__c, CreatedDate, Content_Sub_Type__c, Last_Validated_DateTime__c, Publish_End_DateTime__c, Text_Json__c
                    from simpplr_content__c where Title__c = 'simpplr test Page1'][0];
        cvObj = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_01'][0];
        folderObj = [SELECT Id, Name__c, Parent_Folder__c, External_Folder_Id__c, Path__c, Type__c, Site__c, Is_Deleted__c, Is_System_Folder__c, Is_Hidden__c, 
                            Permissions__c, People__c, CreatedDate FROM Folder__c where Name__c = 'testFolder01'][0];
        fileObj = [SELECT Id, MIME_Type__c, Repository__c, Content_Document__c, Simpplr_Content__c, Simpplr_Content__r.Site__c, Content_Version__c, External_Id__c, Title__c, size__c, 
                            Location__c, Folder__c,Title_Image_Type__c, Is_Title_Image__c,url__c, CreatedDate FROM File__c][0];
        pageCategoryObj = [Select id From Pages_Category__c where Name__c = 'SiteAddPageDataServerTestPageCategroy'];
        data = '{"siteId":"' + site.Id + '","id":null,"title":"Test Page","bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""},"content":[{"type":"text","text":"abcd"}]},{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""}}]},"body":"<p>Body</p>","summary":null,"contentSubType":"knowledge","category":{"id":"' + pageCategoryObj.Id + '","name":"SiteAddPageDataServerTestPageCategroy"},"publishAt":"2017-01-02T00:00:00","publishTo":null,"allowComments":true,"useMaximumWidth":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[],"categoryName":"New One","topics":{"records":[]},"deletedTopics":[],"files":[],"deletedFiles":[],"inlineImages":[],"deletedInlineImages":[],"imgFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"imgLandscapeFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.Id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"imgOriginalFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"listOfFiles":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId","isImage":true}],"listOfInlineImages":[{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"}],"listOfTopics":[{"id":null,"name":"ghgh"},{"id":null,"name":"vgcdvgc"},{"id":null,"name":"opop"}]}';
        editdata = '{"siteId":"' + site.Id + '","id":"' + content.id + '","contentSubType":"knowledge","title":"Test Page","bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""},"content":[{"type":"text","text":"abcd"}]},{"type":"paragraph","attrs":{"indentation":0,"textAlign":"left","className":""}}]},"body":"<p>Body</p>","summary":null,"category":{"id":null,"name":"newSiteAddPageDataServerTestPageCategroy"},"publishAt":"2017-01-02T00:00:00","publishTo":null,"allowComments":true,"useMaximumWidth":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[],"categoryName":"New One","topics":{"records":[]},"deletedTopics":[],"files":[],"deletedFiles":[],"inlineImages":[],"deletedInlineImages":[],"imgFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"imgLandscapeFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.Id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"imgOriginalFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"listOfFiles":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId","isImage":true}],"listOfInlineImages":[{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"}],"listOfTopics":[{"id":null,"name":"ghgh"},{"id":null,"name":"vgcdvgc"},{"id":null,"name":"opop"}]}';
        editdata1 = '{"siteId":"' + site.Id + '","id":"' + content.id + '","contentSubType":"knowledge","title":"Test Page","bodyJson":null,"body":"<p>Body<iframe></p>","summary":null,"category":{"id":null,"name":"newSiteAddPageDataServerTestPageCategroy"},"publishAt":"2017-01-02T00:00:00","publishTo":null,"allowComments":true,"useMaximumWidth":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[],"categoryName":"New One","topics":{"records":[]},"deletedTopics":[],"files":[],"deletedFiles":[],"inlineImages":[],"deletedInlineImages":[],"imgFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"imgLandscapeFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.Id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"imgOriginalFile":{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},"listOfFiles":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId","isImage":true}],"listOfInlineImages":[{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"},{"id":"' + fileObj.Id + '","fileId":"' + fileObj.Id + '","contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId + '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj.MIME_Type__c + '","type":"' + fileObj.MIME_Type__c + '","externalFileId":"testexternalId"}],"listOfTopics":[{"id":null,"name":"ghgh"},{"id":null,"name":"vgcdvgc"},{"id":null,"name":"opop"}]}';
    }
    
    @isTest public static void getCollaborationRoleUsingUserIdTest(){

        List<CollaborationGroupMember> collabGropMembers = new List<CollaborationGroupMember>();
        CollaborationGroup collabGrp = [SELECT id FROM CollaborationGroup LIMIT 1];
        Test.startTest();
        SiteDao siteDaoObj = new siteDao();
        collabGropMembers = siteDaoObj.getCollaborationRoleUsingUserId(collabGrp.id, UserContext.id);
        Test.stopTest();
        System.assertNotEquals(0, collabGropMembers.size(), 'unable to get CollaborationRoleUsing UserId');
        
    }

    @isTest public static void testMethodDraft() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer(); 
        pageRef.getParameters().put('action', 'saveDraft');
        pageRef.getParameters().put('siteId', site.Id);
        pageRef.getParameters().put('data', data);
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest public static void testMethodUpdateDraft() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer(); 
        pageRef.getParameters().put('siteId', site.Id);
        pageRef.getParameters().put('action', 'updateDraft');
        pageRef.getParameters().put('data', editData);
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest public static void testMethodPublish() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer(); 
        pageRef.getParameters().put('siteId', site.Id);
        pageRef.getParameters().put('action', 'publish');
        pageRef.getParameters().put('data', editData);
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest public static void testMethodPublish1() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));

        
        CollaborationGroup collGrp = [select id, isBroadcast FROM  CollaborationGroup where name = 'ContentDataServerTest_grp1' LIMIT 1];
        collGrp.isBroadcast = true;
        update collGrp;
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer(); 
        pageRef.getParameters().put('siteId', site.Id);
        pageRef.getParameters().put('action', 'publish');
        pageRef.getParameters().put('data', editData1);
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }
 

    @isTest public static void testMethodUpdate() {
        Test.startTest();
        init();
        
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer(); 

        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false)); 
        pageRef.getParameters().put('siteId', site.Id);
        pageRef.getParameters().put('action', 'update');
        pageRef.getParameters().put('data', editData);
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');

        pageRef.getParameters().put('action', 'update');
        pageRef.getParameters().put('data', '');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        // data is empty hence throwing error
        System.assertEquals('error', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest public static void startContentEdit() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer(); 
        pageRef.getParameters().put('action','startContentEdit');
        pageRef.getParameters().put('data','{"contentId":"'+content.id+'","versionNumber":1}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testApprove() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        PageReference pgRef = Page.DataServerRW;
        
        pgRef.getParameters().put('target', 'SiteAddPageDataServer');
        pgRef.getParameters().put('action', 'approve');
        pgRef.getParameters().put('siteId', site.id);
        pgRef.getParameters().put('data', editData);
        Test.setCurrentPage(pgRef); 
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    @isTest static void testApprove1() {
        Test.startTest();
        init();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        PageReference pgRef = Page.DataServerRW;
        
        pgRef.getParameters().put('target', 'SiteAddPageDataServer');
        pgRef.getParameters().put('action', 'approve');
        pgRef.getParameters().put('siteId', site.id);
        pgRef.getParameters().put('data','{"authoredBy":{"id":"' + getPeople(managerUserObj.id).Id + '","peopleId":"' + getPeople(managerUserObj.id).Id + '","sfUserId":"' + managerUserObj.Id + '","segmentId":null,"segmentName":"Div-1-Segment","subSegment":"Div-1","nickname":"User15728614299281898678","name":"Dummy","firstName":"Dummy","lastName":"Dummy","fullName":"Dummy Dummy","url":null,"img":null,"coverImageUrl":null,"title":null,"department":"enginnering","location":"Banglore, Australia","locationId":"Banglore @@ null @@ Australia","company":"samsung","division":"Div-1","street":null,"city":"Banglore","state":null,"country":"Australia","email":"utsav311612@gmail.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":true,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":"2020-04-09T02:11:11.000-0700","permissions":{"isAppManager":false,"isSiteManager":true,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":true,"canCreateTopics":true,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":true,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":"America/Los_Angeles","timezoneIso":"America/Los_Angeles","timezoneOffset":-25200000,"language":null,"lang":"en-US","userCategory":{"id":null,"name":null,"userCount":0},"hasLoggedInToMobileApp":false,"dismissedOnboardingFlags":["userMenu"]},"contentSubType":"knowledge","listOfFiles":[],"publishAt":"2020-04-09T00:00:00","body":"<p>ADDPAGE</p>","siteId":"' + site.id  + '","summary":"ADDPAGE","imgLayout":"small","listOfContentTopicIds":[],"title":"ADDPAGE","isFeedEnabled":true,"listOfTopics":[{"id":null,"name":"ADDPAGE"}],"category":{"id":null,"name":"Uncategorized"}}');
        Test.setCurrentPage(pgRef); 
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest public static void testMoveMethods() {
        Test.startTest();
        init();
        String pageOrderDataJson = '{"siteId":"' + site.Id + '", "categoryId": "' + pageCategoryObj.id+'","pageId":"' + content.id+ '", "pageIdsArray" : [" ' + content.id +'", " ' + content.id +'"]}';
        pageRef.getParameters().put('action', 'moveToBottom');
        pageRef.getParameters().put('data', pageOrderDataJson);
        Test.setCurrentPage(pageRef);
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        
        pageRef.getParameters().put('action', 'moveToTop');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');

        pageRef.getParameters().put('action', 'updatePagePosition');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest public static void testConvertFileWrapperToFileObject() {
        init();      
        List<FileContentWrapper> filesWrapperList = new List<FileContentWrapper>();
        
        FileContentWrapper fcwObj1 = new FileContentWrapper();
        fcwObj1.contentVersionId = cvObj.Id; 
        fcwObj1.contentDocumentId = cvObj.ContentDocumentId;
        fcwObj1.size = 111;
        
        FileContentWrapper fcwObj2 = new FileContentWrapper();
        fcwObj2.contentVersionId = cvObj.Id;
        fcwObj2.contentDocumentId = cvObj.ContentDocumentId;
        fcwObj2.size = 111;
        fcwObj2.context = 'Box';
        
        filesWrapperList.add(fcwObj1);
        filesWrapperList.add(fcwObj2);
        
        System.assertEquals(2, filesWrapperList.size(),'Running as expected');
    }

    @isTest public static void testGetContentStatus() {
        init();
        ContentDataServer cdsObj = new SiteAddPageDataServer();
        Simpplr_Content__c contentObj = TestHelper.createContent('simpplr Page', 'Page', 'Published', managerUserObj, site);
        cdsObj.getContentStatus(ServiceConstants.CONTENT_STATUS_SUBMITTED, true);
        cdsObj.getContentStatus(ServiceConstants.CONTENT_STATUS_DRAFT, true);
        cdsObj.getContentStatus(ServiceConstants.CONTENT_STATUS_REJECTED, true);
        cdsObj.getContentStatus(ServiceConstants.CONTENT_STATUS_PUBLISH, true);
        cdsObj.getContentStatus(ServiceConstants.CONTENT_STATUS_PUBLISH, false);
        
        Topic topicObj = TestHelper.createTopic('sitetesttopictest');
        TestHelper.addTopicToContent(topicObj.Id, contentObj.Id);
        
        Pages_Category__c pcObj = TestHelper.createPageCategory(site.Id, 'pagecategorystestattach');
        contentObj.Pages_Category__c = pcObj.Id;
        update contentObj;
        
        String siteId = site.Id;
        Folder__c foldObj = [select id from Folder__c where site__c = :siteId LIMIT 1];
        
        createFilesForContent(contentObj.Id, '', ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL, foldObj.Id);
        createFilesForContent(contentObj.Id, '', ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN, foldObj.Id);
        createFilesForContent(contentObj.Id, '', ServiceConstants.TITLE_IMAGE_TYPE_ORIGINAL, foldObj.Id);
        createFilesForContent(contentObj.Id, ServiceConstants.FILE_LOCATION_ATTACHMENT, '', foldObj.Id);
        createFilesForContent(contentObj.Id, ServiceConstants.FILE_LOCATION_INLINE, '', foldObj.Id);
        
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        ContentWrapper wrap = serverObj.convertToContentWrapper(contentObj);  
        System.assertEquals(contentObj.Id, wrap.id, 'Running as expected');
    }
    
    public static void createFilesForContent(Id ContentId, String location, String titleImageType, Id folderId){
        
        File__c fileObj 			= new File__c(); 
        fileObj.Title__c 			= 'test';
        fileObj.Size__c 			= Decimal.valueOf('333');
        fileObj.MIME_Type__c		= 'jpg';
        fileObj.Content_Version__c 	= 'testcontentversion';
        fileObj.Content_Document__c = 'testcontentdoc';
        fileObj.Simpplr_Content__c 	= contentId;
        fileObj.Folder__c = folderId;
        fileObj.Location__c = location;
        fileObj.MIME_Type__c = 'jpg';
        if(ServiceConstants.FILE_LOCATION_COVER.equalsIgnoreCase(location)) {
                fileObj.Title_Image_Type__c = titleImageType;
                fileObj.Is_Title_Image__c = true;
        }
        fileObj.Repository__c = '';
        if(ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(location)) {
            fileObj.url__c = 'testurl';
            fileObj.External_Id__c = 'externalid';	
        }       
        insert fileObj;
    }
    
    @isTest static void testPublish(){
        Test.startTest();
        init();
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        PageReference pgRef = Page.DataServerRW;
        
        pgRef.getParameters().put('target', 'SiteAddPageDataServer');
        pgRef.getParameters().put('action', 'publish'); 
        pgRef.getParameters().put('siteId', site.id);
        pgRef.getParameters().put('data','{"authoredBy":{"id":"' + getPeople(managerUserObj.id).id + '","peopleId":"' + getPeople(managerUserObj.id).id + '","sfUserId":"' + managerUserObj.Id + '","segmentId":null,"segmentName":"Div-1-Segment","subSegment":"Div-1","nickname":"User15728614299281898678","name":"Utsav Chaurasia","firstName":"Utsav","lastName":null,"fullName":null,"url":null,"img":null,"coverImageUrl":null,"title":null,"department":"enginnering","location":"Banglore, Australia","locationId":"Banglore @@ null @@ Australia","company":"samsung","division":"Div-1","street":null,"city":"Banglore","state":null,"country":"Australia","email":"dummy@gmail.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":true,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":"2020-04-09T02:11:11.000-0700","permissions":{"isAppManager":false,"isSiteManager":true,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":true,"canCreateTopics":true,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":true,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":"America/Los_Angeles","timezoneIso":"America/Los_Angeles","timezoneOffset":-25200000,"language":null,"lang":"en-US","userCategory":{"id":null,"name":null,"userCount":0},"hasLoggedInToMobileApp":false,"dismissedOnboardingFlags":["userMenu"]},"contentSubType":"knowledge","listOfFiles":[],"publishAt":"2020-04-09T00:00:00","body":"<p>ADDPAGE</p>","siteId":"' + site.id  + '","summary":"ADDPAGE","imgLayout":"small","listOfContentTopicIds":[],"title":"ADDPAGE","isFeedEnabled":true,"listOfTopics":[{"id":null,"name":"ADDPAGE"}],"category":{"id":null,"name":"Uncategorized"}}');
        Test.setCurrentPage(pgRef); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        serverObj.handleRequest();

        system.assertEquals('success', serverObj.response.status, serverObj.response.message);

        pgRef.getParameters().put('action', 'get');
        pgRef.getParameters().put('contentId', content1.id);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        pgRef.getParameters().put('versionHistoryId', String.ValueOf(content1.Version__c));
        serverObj.handleRequest();
        system.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }

    @isTest static void testPublishAndShareToMSTeams(){
        Test.startTest();
        init();
        SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 = true;
        site.External_Apps_Site_Config_Json__c ='{"msTeamsSiteConfig" : { "msTeamsSiteFeedOptions" : [ "msTeamsTimeline" ]}}';
        site.Microsoft_Teams_Integration_Enabled__c = true;
        update site;
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        PageReference pgRef = Page.DataServerRW;
        
        pgRef.getParameters().put('target', 'SiteAddPageDataServer');
        pgRef.getParameters().put('action', 'publish'); 
        pgRef.getParameters().put('siteId', site.id);
        pgRef.getParameters().put('data','{"authoredBy":{"id":"' + getPeople(managerUserObj.id).id + '","peopleId":"' + getPeople(managerUserObj.id).id + '","sfUserId":"' + managerUserObj.Id + '","segmentId":null,"segmentName":"Div-1-Segment","subSegment":"Div-1","nickname":"User15728614299281898678","name":"Utsav Chaurasia","firstName":"Utsav","lastName":null,"fullName":null,"url":null,"img":null,"coverImageUrl":null,"title":null,"department":"enginnering","location":"Banglore, Australia","locationId":"Banglore @@ null @@ Australia","company":"samsung","division":"Div-1","street":null,"city":"Banglore","state":null,"country":"Australia","email":"dummy@gmail.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":true,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":"2020-04-09T02:11:11.000-0700","permissions":{"isAppManager":false,"isSiteManager":true,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":true,"canCreateTopics":true,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":true,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":"America/Los_Angeles","timezoneIso":"America/Los_Angeles","timezoneOffset":-25200000,"language":null,"lang":"en-US","userCategory":{"id":null,"name":null,"userCount":0},"hasLoggedInToMobileApp":false,"dismissedOnboardingFlags":["userMenu"]},"contentSubType":"knowledge","listOfFiles":[],"publishAt":"2020-04-09T00:00:00","body":"<p>ADDPAGE</p>","siteId":"' + site.id  + '","summary":"ADDPAGE","imgLayout":"small","listOfContentTopicIds":[],"title":"ADDPAGE","isFeedEnabled":true,"listOfTopics":[{"id":null,"name":"ADDPAGE"}],"category":{"id":null,"name":"Uncategorized"}}');
        Test.setCurrentPage(pgRef); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        serverObj.handleRequest();

        system.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest static void testPublishAndShareToSlack(){
        Test.startTest();
        init();
        SimpplrContext.isSlackPhase2FeatureEnabled = true;
        SimpplrContext.isSlackUpgraded = true;
        site.External_Apps_Site_Config_Json__c ='{"slackSiteConfig" : { "slackSiteFeedOptions" : [ "slackTimeline" ]}}';
        site.Slack_Integration_Enabled__c = true;
        update site;
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        PageReference pgRef = Page.DataServerRW;
        
        pgRef.getParameters().put('target', 'SiteAddPageDataServer');
        pgRef.getParameters().put('action', 'publish'); 
        pgRef.getParameters().put('siteId', site.id);
        pgRef.getParameters().put('data','{"authoredBy":{"id":"' + getPeople(managerUserObj.id).id + '","peopleId":"' + getPeople(managerUserObj.id).id + '","sfUserId":"' + managerUserObj.Id + '","segmentId":null,"segmentName":"Div-1-Segment","subSegment":"Div-1","nickname":"User15728614299281898678","name":"Utsav Chaurasia","firstName":"Utsav","lastName":null,"fullName":null,"url":null,"img":null,"coverImageUrl":null,"title":null,"department":"enginnering","location":"Banglore, Australia","locationId":"Banglore @@ null @@ Australia","company":"samsung","division":"Div-1","street":null,"city":"Banglore","state":null,"country":"Australia","email":"dummy@gmail.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":true,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":"2020-04-09T02:11:11.000-0700","permissions":{"isAppManager":false,"isSiteManager":true,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":true,"canCreateTopics":true,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":true,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":"America/Los_Angeles","timezoneIso":"America/Los_Angeles","timezoneOffset":-25200000,"language":null,"lang":"en-US","userCategory":{"id":null,"name":null,"userCount":0},"hasLoggedInToMobileApp":false,"dismissedOnboardingFlags":["userMenu"]},"contentSubType":"knowledge","listOfFiles":[],"publishAt":"2020-04-09T00:00:00","body":"<p>ADDPAGE</p>","siteId":"' + site.id  + '","summary":"ADDPAGE","imgLayout":"small","listOfContentTopicIds":[],"title":"ADDPAGE","isFeedEnabled":true,"listOfTopics":[{"id":null,"name":"ADDPAGE"}],"category":{"id":null,"name":"Uncategorized"}}');
        Test.setCurrentPage(pgRef); 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        serverObj.handleRequest();

        system.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    @isTest static void testGet() {
        Test.startTest();
        init();
        people__c peopleObj = [select id from people__c where user__c =: managerUserObj.id];
        
        content.Version__c = 1;
        content.Text_Intro__c = 'abcd';
        content.Text_Main__c = 'def';
        content.Text_Main_Continued__c='ghi';
        content.Text_Json__c = '{}';
        content.Event_Location__c = 'test';
        content.Event_Directions_Enabled__c = true;
        content.Event_Map_URL__c='www.test.simpplr.orzg.1';
        content.Event_Is_All_Day__c = false;
        content.Event_TimezoneSidKey__c = 'America/Los_Angeles';
        content.Event_Start_DateTime__c = System.today().addDays(2);
        content.Pages_Category__c = pageCategoryObj.Id;
        update content;
        
        Content_History__c historyObj = new Content_History__c();
        historyObj.Content__c = content.id;
        historyObj.Version__c = content.Version__c;
        historyObj.Content_Json_Part1__c = JSON.serialize(content);
        insert historyObj;
                 
        pageRef.getParameters().put('action', 'get');
        pageRef.getParameters().put('contentId', content.id);
        pageRef.getParameters().put('versionHistoryId', String.valueOf(content.Version__c));
        Test.setCurrentPage(pageRef);
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        serverObj.handleRequest();   
        system.assertEquals('success', serverObj.response.status, serverObj.response.message);           
        Test.stopTest();
    }
    @isTest static void testGetOriginMobile() {
        Test.startTest();
        init();
        people__c peopleObj = [select id from people__c where user__c =: managerUserObj.id];
        
        content.Version__c = 1;
        content.Text_Intro__c = '<iframe';
        content.Text_Main__c = 'def';
        content.Text_Main_Continued__c='ghi';
        content.Pages_Category__c = pageCategoryObj.Id;
        update content;
        
        pageRef.getParameters().put('action', 'get');
        pageRef.getParameters().put('origin', 'mobile');
        pageRef.getParameters().put('contentId', content.id);
        Test.setCurrentPage(pageRef);
        SiteAddPageDataServer serverObj = new SiteAddPageDataServer();
        serverObj.handleRequest();   
        system.assertEquals('success', serverObj.response.status, serverObj.response.message);           
        Test.stopTest();
    }
}