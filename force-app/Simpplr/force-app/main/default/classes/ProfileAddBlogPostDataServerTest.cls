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
private class ProfileAddBlogPostDataServerTest {
    private static ContentVersion cvObj1;
    private static ContentVersion cvObj2;
    @testSetup static void setup() {
        App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        User testUser = TestHelper.createUser('ProfileAddBlogPostDataServer_StdUser', null, false); 
        User testAdminUser = TestHelper.createUser('ProfileAddBlogPostDataServer_AdminUser', null, true); 
        TestHelper.createPeopleRecordForUser(UserContext.id);
        cvObj1 = TestHelper.createContentVersion('bsnbmasbdmn', 'File_Blog1');
        cvObj2 = TestHelper.createContentVersion('bsnbmasbdmna', 'File_Blog2');
        CollaborationGroup collGrp = TestHelper.createCollaborationGroup('ProfileAddBlogPostDataServerTestSite', 'Public');
        Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test blog', 'BlogPost', 'Draft', testAdminUser, getSite());
    }
    
    private static User getStandardUser(){
        User userObj = TestHelper.getUser('Standard User', 'ProfileAddBlogPostDataServer_StdUser');
        return userObj;
    }
    
    private static User getAdminUser(){
        User userObj = TestHelper.getUser('System Administrator', 'ProfileAddBlogPostDataServer_AdminUser');
        return userObj;
    }
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
                                    Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
                                    From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }
    
    private static User getUser(String userId){
        User  userObj = TestHelper.getUserById(userId);
        return userObj;
    }
    
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [select Id, Name, Chatter_Group_Id__c, Landing_Page__c 
        								from Simpplr_Site__c where Name='ProfileAddBlogPostDataServerTestSite' LIMIT 1];
        return siteObj;
    }

    private static Simpplr_Content__c getContent(){
        Simpplr_Content__c  contentObj = [Select Id,Text_Intro__c,Display_Excerpt__c,Summary_1__c,Type__c,Version__c,
        Is_Published__c,Is_Unpublished__c,Is_Deleted__c,Activated_By_Feature__c,Publish_End_DateTime__c,Is_Must_Read__c,
        Status__c,Primary_Author__c,site__c,Title__c,CreatedDate,Publish_Start_DateTime__c,Event_End_DateTime__c,Event_Is_All_Day__c,
        Event_Start_DateTime__c,LastModifiedDate,Primary_Author__r.User__r.Id,Primary_Author__r.Full_Name__c,Site__r.Landing_Page__c,Event_RSVP_Allowed__c,
        Primary_Author__r.User__r.SmallPhotoUrl,Site__r.name,Site__r.Is_Active__c,Site__r.Is_Deleted__c,Site__r.Site_Type__c,
        (SELECT Id,Content_Version__c,Is_Title_Image__c,Title_Image_Type__c FROM File_Simpplr_Content__r where Is_Deleted__c = false)                                  
        From Simpplr_Content__c where Title__c =  'simpplr test blog' LIMIT 1];
        return contentObj;
    }

    private static Simpplr_Content__c getCreatedBlog(String status){
        Simpplr_Content__c pageObj = [SELECT Id, Title__c, Text_Intro__c FROM Simpplr_Content__c 
                                        where Status__c =:status AND Type__c =:ServiceConstants.TYPE_BLOGPOST LIMIT 1];
        return pageObj;
    }

    private static void init() {
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ProfileAddBlogPostDataServer');
        Test.setCurrentPage(pgRef);
    }
    
    @isTest static void testHandleRequestDraft() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        cvObj1 = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_Blog1'][0];
        cvObj2 = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_Blog2'][0];
        String dataString = '{"author":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                '"id":null,"department":"Department_01","canFollow":null,' + 
                                '"address":"Gurgaon,Haryana,India"},' + 
                            '"id":null,"title":"Test Blog DS0001","body":"<p>Test Blog DS0001 - content</p>","summary":null,' + 
                            '"publishAt":"2017-07-16T00:00:00","publishedToDate":null,' + 
            '"allowComments":true,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}';

        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ProfileAddBlogPostDataServer');
        pgRef.getParameters().put('action', 'saveDraft');
        pgRef.getParameters().put('data', dataString);
        Test.setCurrentPage(pgRef);
        ProfileAddBlogPostDataServer serverObj = new ProfileAddBlogPostDataServer();
        
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        Test.stopTest();
    }
    
    @isTest static void testHandleRequestUpdateDraft() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));

        cvObj1 = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_Blog1'][0];
        cvObj2 = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_Blog2'][0];
        
        String contentId = getContent().id;        
        String dataString = '{"author":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                '"id":null,"department":"Department_01","canFollow":null,' + 
                                '"address":"Gurgaon,Haryana,India"},' + 
                            '"id":"' + contentId + '","title":"Test Blog DS0001a","bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"textAlign":"left"},"content":[{"type":"text","marks":[{"type":"italic"}],"text":"Hello world"}]}]},"body":"<p>Test Blog DS0001a - content</p>","summary":null,' + 
                            '"publishAt":"2017-07-16T00:00:00","publishedToDate":null,' + 
                            '"allowComments":true,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[],' + 
                            '"topics":{"records":[]},"deletedTopics":[],"files":[],"deletedFiles":[],' +
                            '"listOfFiles":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj1.id + '","contentDocumentId":"' + cvObj1.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","type":"PNG","externalFileId":"testexternalId","isImage":true}]}';
        
        ProfileAddBlogPostDataServer serverObj = new ProfileAddBlogPostDataServer();   
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ProfileAddBlogPostDataServer');
        Test.setCurrentPage(pgRef);
                            
        pgRef.getParameters().put('action', 'get');
        pgRef.getParameters().put('contentId', contentId);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');

        pgRef.getParameters().put('action', 'updateDraft');
        pgRef.getParameters().put('data', dataString);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');
        
        Test.stopTest();
    }

    @isTest static void testHandleRequestUpdate() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));

        cvObj1 = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_Blog1'][0];
        cvObj2 = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_Blog2'][0];
        
        String contentId = getContent().Id;
        String dataString = '{"author":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                '"id":null,"department":"Department_01","canFollow":null,' + 
                                '"address":"Gurgaon,Haryana,India"},' + 
                            '"id":"' + contentId + '","title":"Test Blog DS0001a","body":"<p>Test Blog DS0001a - content</p>","summary":null,"bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"textAlign":"left"},"content":[{"type":"text","marks":[{"type":"italic"}],"text":"Hello world"}]}]},' + 
                            '"publishAt":"2017-07-16T00:00:00","publishedToDate":null,' + 
                            '"allowComments":true,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[],' + 
                            '"topics":{"records":[]},"deletedTopics":[],"files":[],"deletedFiles":[],' +
                            '"listOfFiles":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj2.id + '","contentDocumentId":"' + cvObj2.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"PNG","type":"PNG","externalFileId":"testexternalId","isImage":true}],' +
                            '"listOfInlineImages":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj1.id + '","contentDocumentId":"' + cvObj1.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"PNG","type":"PNG","externalFileId":"testexternalId","isImage":true}]}';
             
        ProfileAddBlogPostDataServer serverObj = new ProfileAddBlogPostDataServer();   
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ProfileAddBlogPostDataServer');
        pgRef.getParameters().put('contentId', contentId);
        pgRef.getParameters().put('action', 'update');
        pgRef.getParameters().put('data', dataString);   	
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected');

        Test.stopTest();
    }

    @isTest static void testHandleRequestMobile() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));

        ProfileAddBlogPostDataServer serverObj = new ProfileAddBlogPostDataServer();   
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ProfileAddBlogPostDataServer');
        Test.setCurrentPage(pgRef);
        
        cvObj1 = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_Blog1'][0];
        cvObj2 = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_Blog2'][0];
        
        String contentId = getContent().Id;        
        String dataString = '{"author":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?id=' + peopleObj.Id + '",' + 
                                '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                                '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,' + 
                                '"id":null,"department":"Department_01","canFollow":null,' + 
                                '"address":"Gurgaon,Haryana,India"},' + 
                            '"id":"' + contentId + '","title":"Test Blog DS0001a","body":"<p>Test Blog DS0001a - content</p>","bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"textAlign":"left"},"content":[{"type":"text","marks":[{"type":"italic"}],"text":"Hello world"}]}]},"summary":null,' + 
                            '"publishAt":"2017-07-16T00:00:00","publishedToDate":null,' + 
                            '"allowComments":true,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[],' + 
                            '"topics":{"records":[]},"deletedTopics":[],"files":[],"deletedFiles":[],' +
                            '"listOfFiles":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj1.id + '","contentDocumentId":"' + cvObj1.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","type":"PNG","externalFileId":"testexternalId","isImage":true}]}';
        
        
        pgRef.getParameters().put('origin','mobile');
        pgRef.getParameters().put('action', 'publish');
        pgRef.getParameters().put('data', dataString);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.status, 'Running as expected'); 

        
        Test.stopTest();
    }
    @isTest static void testUndefinedAction() {
        Test.startTest();
        init();
        ProfileAddBlogPostDataServer serverObj = new ProfileAddBlogPostDataServer();   
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ProfileAddBlogPostDataServer');
        Test.setCurrentPage(pgRef);
        pgRef.getParameters().put('action', 'undefinedAction');
        pgRef.getParameters().put('data', '{}');
        serverObj.handleRequest();
        // error - action is not correct
        System.assertEquals('error', serverObj.Response.status, 'Running as expected');
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false)); 
        pgRef.getParameters().put('action', 'publish');	
        pgRef.getParameters().put('data', '{}');
        serverObj.handleRequest();
        // error - data is missing
        System.assertEquals('error', serverObj.Response.status, 'Running as expected');
        Test.stopTest();
    }

}