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
public class SiteAddAlbumDataServerTest {
    private static ContentVersion cvObj;
    private static Simpplr_Content__c contentObj;
    private static Social_Campaign__c socialCamp;
    private static File__c fileObj2;
    
    @testSetup static void setup() {
        TestHelper.setupAppConfig();
        User systemAdmin = TestHelper.createUser('SiteAddAlbumDataServerTest_admin', null, true);
        User testUser = TestHelper.createUser('Simpplr_usr1', null, false);
        User testAdminUser = TestHelper.createUser('Simpplr_admin', null, true); 
        Id collaborationGroupId = TestHelper.createCollaborationGroup('Simpplr_Grp1', getUser(UserInfo.getUserId()), false, false);
        Simpplr_Site__c  testSite = TestHelper.getSiteRecord(collaborationGroupId);
        TestHelper.shareSitesToAllPeople(new List<String>{testSite.Id});
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        TestHelper.createPeoplePreference(peopleObj.Id);
        Simpplr_content__c albumObj = TestHelper.createContent('AlbumDataServerTest Album', 'Album', 'Approved', systemAdmin, testSite);
        cvObj = TestHelper.createContentVersion('bsnbmasbdmna', 'File_SiteAddAlbum');
        socialCamp = TestHelper.createSocialCampaign(peopleObj.id);
        TestHelper.createCarousel(testSite.id,albumObj.id,'album',socialCamp.id);
        File__c fileObj2 = TestHelper.createContentTitleImage(albumObj.id);
        fileObj2.Location__c = 'media';
        update fileObj2;
        Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, testSite.id, 'Intranet', null, 'readwrite');
        folderObj.External_Folder_Id__c = albumObj.Id;
        update folderObj;
    }

    static void init(){
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        contentObj = [Select id From Simpplr_Content__c where title__c = 'AlbumDataServerTest Album' LIMIT 1];
        fileObj2 = [Select id,MIME_Type__c From File__c where title__c='TitleImage' And Location__c='media' LIMIT 1];
    }
    
    private static User getStandardUser(){
        User userObj = [select id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
                            from User where profile.name ='Standard User' and lastname='Simpplr_usr1' LIMIT 1];
        return userObj;
    }
    
    private static User getAdminUser(){
        User userObj = [select id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
                            from User where profile.name ='System Administrator' and lastname='Simpplr_admin' LIMIT 1];
        return userObj;
    }
    
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [select Id, Name, Chatter_Group_Id__c, Landing_Page__c 
                                        from Simpplr_Site__c where Name='Simpplr_Grp1' LIMIT 1];
        return siteObj;
    }
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c, Mobile_Phone__c, Manager__c, 
                                    Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
                                    From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }
    
    private static User getUser(String userId){
        User  userObj = [SELECT Id, AboutMe, City, CommunityNickname, CompanyName, Country, Department, Division, Email, EmployeeNumber, 
                                Extension, Fax, FirstName, LastName, MobilePhone, Phone, PostalCode, State, Street, Title 
                                                FROM User where Id = :userId];
        return userObj;
    }
    
    private static Simpplr_Content__c getCreatedAlbum(List<String> fieldList, String status){
        DateTime currentDateTime = DateTime.now();
            String loggedInPeopleId = UserContext.peopleId;
            String query = 'SELECT '+String.join(fieldList,',') + 
                        ' FROM Simpplr_Content__c where Status__c =:status AND Type__c =\'Album\' LIMIT 1';
        return (Simpplr_Content__c) Database.query(query);
    }

    @isTest public static void testAllNegative() {
        Test.startTest();
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        pageRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentpage(pageRef);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();   
        Simpplr_Content__c albumObj = getCreatedAlbum(serverObj.getAlbumFieldList(), 'Approved');  

        String dataStringForPublish = '{"siteId":"' + siteObj.Id + '","id":"' + albumObj.id + '",' + 
                        '"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?profileId=' + peopleObj.Id + '",' + 
                            '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                            '"peopleId":"' + peopleObj.Id + '","name":"hi","location":null,"id":null,' + 
                            '"department":"Department_01","canFollow":null,"address":"Gurgaon,Haryana,India"},' + 
                        '"id":"' + albumObj.id + '","title":"Test Album DS0001","description":"Test Album DS0001 - content",' + 
                        '"topics":{"records":[{"id":null,"name":"albumTopic","url":null}]},' + 
                        '"publishedToDate":null,"isPromoted":true,"promotedFromDate":"Feb 5 2016 (India Standard Time)",' + 
                        '"promotedToDate":null,"allowComments":true,"deletedTopics":[]}';				
        
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentPage(pgRef);
        
        pgRef.getParameters().put('action', 'saveDraft');
        pgRef.getParameters().put('contentId', 'null');
        pgRef.getParameters().put('data', '');
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.Response.Status, 'Running as Expected');
        
        pgRef.getParameters().put('action', '');
        pgRef.getParameters().put('data', dataStringForPublish);
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.Response.Status, 'Running as Expected');          
        Test.stopTest();
    }
    @isTest static void testUpdate() {
        Test.startTest();
        init();
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        pageRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentpage(pageRef);
        
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        String dataUpdateString = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":"'+ contentObj.Id +'"}';
        String dataUpdateString2 = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":""}';
        
        pageRef.getParameters().put('action', 'update');
        pageRef.getParameters().put('data', dataUpdateString);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        
        //error because - dataUpdateString2 id is null 
        pageRef.getParameters().put('data', dataUpdateString2);
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testUpdate1() {
        Test.startTest();
        init();
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        pageRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentpage(pageRef);
        
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        String dataUpdateString = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":"'+ contentObj.Id +'"}';
        String dataUpdateString2 = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":""}';
        
        pageRef.getParameters().put('action', 'update');
        
        pageRef.getParameters().put('includeMedia', 'true');
        pageRef.getParameters().put('data', dataUpdateString);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');

        Test.stopTest();
    }

    @isTest static void testUpdate2() {
        Test.startTest();
        init();
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        pageRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentpage(pageRef);
        
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        String dataUpdateString = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":"'+ contentObj.Id +'"}';
        String dataUpdateString2 = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":""}';
        
        cvObj = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_SiteAddAlbum'][0];
        String dataUpdateStr = '{"authoredBy":{"id":"'+peopleObj.id+'","peopleId":"'+peopleObj.id+'","sfUserId":"'+adminUserObj.id+'","spInstanceId":null,"segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Simran Rawat","firstName":"Simran","lastName":"Rawat","fullName":null,"isProtectedAuthor":false},"contentSubType":"","listOfFiles":[{"id":null,"fileId":null,"contentVersionId":"' + cvObj.id + '","contentDocumentId":"' + cvObj.contentDocumentId+ '","url":"testurl","fileUrl":"testurl","downloadUrl":"testurl","title":"testimage","size":"3332","fileType":"' + fileObj2.MIME_Type__c + '","type":"' + fileObj2.MIME_Type__c + '","externalFileId":"testexternalId","isImage":true}],"publishAt":"2021-11-29T00:00:00","body":"<p>Album </p>","siteId":"'+siteObj.id+'","imgCaption":null,"img":"/sfc/servlet.shepherd/version/Download/'+contentObj.id+'?asPdf=false&operationContext=CHATTER","publishingStatus":"immediate","listOfInlineImages":[],"listOfInlineVideos":[],"summary":"Album","listOfAlbumMedia":[{"id":"'+fileObj2.id+'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"listOfSuggestedTopics":[],"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":"/sfc/servlet.shepherd/version/Download/'+fileObj2.id+'?asPdf=false&operationContext=CHATTER","title":"Album","isOpenToSubmissions":true,"language":"en","isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+fileObj2.id+'","imgFile":null,"id":"'+contentObj.id+'"}';
        pageRef.getParameters().put('action', 'update');
        pageRef.getParameters().put('data', dataUpdateStr);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest static void testEdit() {
        Test.startTest();
        init();
        User standardUserObj = getStandardUser();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        pageRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentpage(pageRef);
        
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        String dataUpdateString = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":"'+ contentObj.Id +'"}';
        String dataUpdateString2 = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":""}';
        
        pageRef.getParameters().put('action','startContentEdit');
        pageRef.getParameters().put('data','{"contentId":"'+contentObj.id+'","versionNumber":1}');
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected'); 
        Test.stopTest();
    }

    @isTest public static void testsaveDraft() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId', siteObj.Id);
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentPage(pageRef);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();       
        
        String draftDataUpdateString = '{"authoredBy":{"id":"'+peopleObj.id+'","peopleId":"'+peopleObj.id+'","sfUserId":"'+adminUserObj.id+'","spInstanceId":null,"segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Simran Rawat","firstName":"Simran","lastName":"Rawat","fullName":null,"isProtectedAuthor":false},"contentSubType":"","listOfFiles":[],"publishAt":"2021-11-29T00:00:00","body":"<p>Album </p>","siteId":"'+siteObj.id+'","imgCaption":null,"img":"/sfc/servlet.shepherd/version/Download/'+contentObj.id+'?asPdf=false&operationContext=CHATTER","publishingStatus":"immediate","listOfInlineImages":[],"listOfInlineVideos":[],"summary":"Album","listOfAlbumMedia":[{"id":"'+fileObj2.id+'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"listOfSuggestedTopics":[],"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":"/sfc/servlet.shepherd/version/Download/'+fileObj2.id+'?asPdf=false&operationContext=CHATTER","title":"Album","isOpenToSubmissions":true,"language":"en","isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+fileObj2.id+'","imgFile":null,"id":"'+contentObj.id+'"}';

        String draftDataString = '{"siteId":"' + siteObj.Id + '","id":null,' + 
                        '"authoredBy":{"userId":"' + adminUserObj.Id + '","url":"https://c.na34.visual.force.com/apex/profileabout?profileId=' + peopleObj.Id + '",' + 
                            '"title":"Mr","role":null,"img":"https://c.na34.content.force.com/profilephoto/72961000000F6qr/T",' + 
                            '"peopleId":"' + peopleObj.Id + '","name":"Deepak Sirohi","location":null,"id":null,' + 
                            '"department":"Department_01","canFollow":null,"address":"Gurgaon,Haryana,India"},' + 
                        '"id":"' + contentObj.id + '","title":"Test Album DS0001","description":"Test Album DS0001 - content",' + 
                        '"topics":{"records":[{"id":null,"name":"albumTopic","url":null}]},' + 
                        '"publishAt":"2017-07-16T00:00:00","publishedToDate":null,"isPromoted":true,"promotedFromDate":"Feb 5 2016 (India Standard Time)",' + 
                        '"promoteAt":"2017-07-16T00:00:00","promotedToDate":null,"allowComments":true,"deletedTopics":[]}';
        
        
        pageRef.getParameters().put('action', 'saveDraft');
        pageRef.getParameters().put('contentId', 'null');
        pageRef.getParameters().put('data', draftDataString);
        serverObj.handleRequest();   
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');   	

        pageRef.getParameters().put('action', 'get');
        pageRef.getParameters().put('data', '{"contentType":"album"}');
        pageRef.getParameters().put('action', 'get');
        pageRef.getParameters().put('contentId', contentObj.id);
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');  	
        
        Test.stopTest();
    }

    @isTest public static void testupdateDraft() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId', siteObj.Id);
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentPage(pageRef);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();       
        
        String draftDataUpdateString = '{"authoredBy":{"id":"'+peopleObj.id+'","peopleId":"'+peopleObj.id+'","sfUserId":"'+adminUserObj.id+'","spInstanceId":null,"segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Simran Rawat","firstName":"Simran","lastName":"Rawat","fullName":null,"isProtectedAuthor":false},"contentSubType":"","listOfFiles":[],"publishAt":"2021-11-29T00:00:00","body":"<p>Album </p>","siteId":"'+siteObj.id+'","imgCaption":null,"img":"/sfc/servlet.shepherd/version/Download/'+contentObj.id+'?asPdf=false&operationContext=CHATTER","publishingStatus":"immediate","listOfInlineImages":[],"listOfInlineVideos":[],"summary":"Album","listOfAlbumMedia":[{"id":"'+fileObj2.id+'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"listOfSuggestedTopics":[],"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":"/sfc/servlet.shepherd/version/Download/'+fileObj2.id+'?asPdf=false&operationContext=CHATTER","title":"Album","isOpenToSubmissions":true,"language":"en","isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+fileObj2.id+'","imgFile":null,"id":"'+contentObj.id+'"}';
        
        pageRef.getParameters().put('contentId', 'null');
        pageRef.getParameters().put('action', 'updateDraft');
        pageRef.getParameters().put('data', draftDataUpdateString);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');

        Test.stopTest();
    }
    
    @isTest public static void testPublish2() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId', siteObj.Id);
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentPage(pageRef);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();       
        
        String draftDataUpdateString = '{"authoredBy":{"id":"'+peopleObj.id+'","peopleId":"'+peopleObj.id+'","sfUserId":"'+adminUserObj.id+'","spInstanceId":null,"segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Simran Rawat","firstName":"Simran","lastName":"Rawat","fullName":null,"isProtectedAuthor":false},"contentSubType":"","listOfFiles":[],"publishAt":"2021-11-29T00:00:00","body":"<p>Album </p>","siteId":"'+siteObj.id+'","imgCaption":null,"img":"/sfc/servlet.shepherd/version/Download/'+contentObj.id+'?asPdf=false&operationContext=CHATTER","publishingStatus":"immediate","listOfInlineImages":[],"listOfInlineVideos":[],"summary":"Album","listOfAlbumMedia":[{"id":"'+fileObj2.id+'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"listOfSuggestedTopics":[],"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":"/sfc/servlet.shepherd/version/Download/'+fileObj2.id+'?asPdf=false&operationContext=CHATTER","title":"Album","isOpenToSubmissions":true,"language":"en","isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+fileObj2.id+'","imgFile":null,"id":"'+contentObj.id+'"}';
        
        pageRef.getParameters().put('action', 'publish');
        pageRef.getParameters().put('data', draftDataUpdateString);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        
        Test.stopTest();
    } 

    @isTest public static void testPublish1() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();

        CollaborationGroup collGrp = [select id, isBroadcast FROM  CollaborationGroup where name = 'Simpplr_Grp1'];
        collGrp.isBroadcast = true;
        update collGrp;

        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('siteId', siteObj.Id);
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentPage(pageRef);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();       
        
        String draftDataUpdateString = '{"authoredBy":{"id":"'+peopleObj.id+'","peopleId":"'+peopleObj.id+'","sfUserId":"'+adminUserObj.id+'","spInstanceId":null,"segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Simran Rawat","firstName":"Simran","lastName":"Rawat","fullName":null,"isProtectedAuthor":false},"contentSubType":"","listOfFiles":[],"publishAt":"2021-11-29T00:00:00","body":"<p>Album </p>","siteId":"'+siteObj.id+'","imgCaption":null,"img":"/sfc/servlet.shepherd/version/Download/'+contentObj.id+'?asPdf=false&operationContext=CHATTER","publishingStatus":"immediate","listOfInlineImages":[],"listOfInlineVideos":[],"summary":"Album","listOfAlbumMedia":[{"id":"'+fileObj2.id+'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"listOfSuggestedTopics":[],"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":"/sfc/servlet.shepherd/version/Download/'+fileObj2.id+'?asPdf=false&operationContext=CHATTER","title":"Album","isOpenToSubmissions":true,"language":"en","isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+fileObj2.id+'","imgFile":null,"id":"'+contentObj.id+'"}';
        
        pageRef.getParameters().put('action', 'publish');
        pageRef.getParameters().put('data', draftDataUpdateString);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        
        Test.stopTest();
    } 


    @isTest public static void testHandleRequest() {
        Test.startTest();
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        Simpplr_Site__c  siteObj = getSite();
        Simpplr_Content__c albumObj = getCreatedAlbum(serverObj.getAlbumFieldList(), 'Approved');
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        pgRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentpage(pgRef);
        
        cvObj = [select Id, Title, ContentDocumentId, PathOnClient, IsDeleted, Origin, CreatedDate FROM ContentVersion where Title ='Title_File_SiteAddAlbum'][0];
        String fileIdStr = TestHelper.createContentTitleImage(String.valueOf(albumObj.Id)).Id;
        String submitMediaDataString = '{"albumMediaList":[{"id":"'+fileIdStr+'","description":""}],"albumId":"'+albumObj.Id+'"}';
        pgRef.getParameters().put('action', 'submitMedia');
        pgRef.getParameters().put('data', submitMediaDataString);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');						    
        
        pgRef.getParameters().put('action', 'addPhoto'); 
        String addPhotoRequest = '{"id":"' + albumObj.Id +'","fileContentVersionId":"'+cvObj.id+'","fileContentDocId":"'+cvObj.contentDocumentId+'","fileDescription":"google-signin-2x.png"}';
        pgRef.getParameters().put('data', addPhotoRequest);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');

        pgRef.getParameters().put('action', 'addPhoto'); 
        String addPhotoRequestWithOutCV = '{"id":"' + albumObj.Id +'","fileContentVersionId":"","fileContentDocId":"'+cvObj.contentDocumentId+'","fileDescription":"google-signin-2x.png"}';
        pgRef.getParameters().put('data', addPhotoRequestWithOutCV);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');

        pgRef.getParameters().put('action', 'addVideo');
        String addVideoRequest = '{"videoUrl":"https://www.youtube.com/watch?v=vqcHjS1O8kM","id":"' + albumObj.Id +'","videoProvider":"youtube","videoId":"vqcHjS1O8kM","videoThumbsnailImg":"https://i.ytimg.com/vi/vqcHjS1O8kM/hqdefault.jpg","videoTitle":"Simpplr 3 Minute Demo"}';
        pgRef.getParameters().put('data', addVideoRequest);
        serverObj.handleRequest();    
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        serverobj.getPageFeature();  
        Test.stopTest();
    }
    
    @isTest static void testApprove() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        pageRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentpage(pageRef);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();    
        
        String dataStringForPublish = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","bodyJson":{"type":"doc","content":[{"type":"paragraph","attrs":{"textAlign":"left"},"content":[{"type":"text","marks":[{"type":"italic"}],"text":"Hello world"}]}]},"body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":"'+ contentObj.Id +'"}';
        
        pageRef.getParameters().put('action', 'approve');
        pageRef.getParameters().put('data', dataStringForPublish);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testPublish() {
        Test.startTest();
        init();
        User adminUserObj = getAdminUser();
        People__c peopleObj = getPeople(adminUserObj.Id);
        Simpplr_Site__c  siteObj = getSite();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/utility/sanitize-html',false));
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        pageRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentpage(pageRef);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();    
        
        String dataStringForPublish = '{"authoredBy":{"id":"' + peopleObj.Id + '","peopleId":"' + peopleObj.Id + '","sfUserId":"'+ adminUserObj.Id +'","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Priya Singh","firstName":"Priya","lastName":"Singh","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/a0t4T000000kE5lQAE","img":null,"coverImageUrl":null,"title":null,"department":"Dep-1","location":"India","locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":"India","email":"priya.singh@simpplr.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-03-24T00:00:00","body":"<p>Test Album</p>","siteId":"' + siteObj.Id + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":null,"listOfAlbumMedia":[{"id":"'+ fileObj2.id +'","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"TestAlbum","isOpenToSubmissions":false,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":"'+ contentObj.Id +'","imgFile":null,"id":"'+ contentObj.Id +'"}';
        
        pageRef.getParameters().put('action', 'publish');
        pageRef.getParameters().put('data', dataStringForPublish);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest static void testUndefinedAction() {
    PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentpage(pageRef);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer(); 
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentPage(pgRef);  	
        pgRef.getParameters().put('action', 'invalid_action');
        pgRef.getParameters().put('data', '{}');	
        serverObj.handleRequest();
        //data is missing
        System.assertEquals('error', serverObj.Response.Status, 'Running as Expected');
    }
    
    @isTest static void testConvertToWrapperMethod() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentpage(pageRef);
        List<App_Config__c> appConfigList = [SELECT id,Calendar_Google_Enabled__c, Calendar_Outlook_Web_Enabled__c,
                    Calendar_App_Enabled__c,Calendar_Office365_Enabled__c FROM App_Config__c LIMIT 1];
        App_Config__c appConfig = (appConfigList.size() > 0 ? appConfigList[0] : new App_Config__c());
        appConfig.Calendar_Google_Enabled__c = false;
        appConfig.Calendar_Outlook_Web_Enabled__c = false;
        appConfig.Calendar_App_Enabled__c = false;
        appConfig.Calendar_Office365_Enabled__c = false;
        update appConfig;
        People__c peopleObj = getPeople(UserContext.id);
        TestHelper.createPeoplePreference(peopleObj.Id);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        Simpplr_content__c albumObj = getCreatedAlbum(serverObj.getAlbumFieldList(), 'Approved');
        ContentWrapper wrap = serverObj.convertToContentWrapper(albumObj);
        System.assertEquals(albumObj.id, wrap.id, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testSaveAlbumMediaToDB () {
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentpage(pageRef);
        List<App_Config__c> appConfigList = [SELECT id,Calendar_Google_Enabled__c, Calendar_Outlook_Web_Enabled__c,
                    Calendar_App_Enabled__c,Calendar_Office365_Enabled__c FROM App_Config__c LIMIT 1];
        App_Config__c appConfig = (appConfigList.size() > 0 ? appConfigList[0] : new App_Config__c());
        appConfig.Calendar_Google_Enabled__c = false;
        appConfig.Calendar_Outlook_Web_Enabled__c = false;
        appConfig.Calendar_App_Enabled__c = false;
        appConfig.Calendar_Office365_Enabled__c = false;
        update appConfig;
        People__c peopleObj = getPeople(UserContext.id);
        TestHelper.createPeoplePreference(peopleObj.Id);
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        Simpplr_content__c albumObj = getCreatedAlbum(serverObj.getAlbumFieldList(), 'Approved');
        File__c fileObj = TestHelper.createContentTitleImage(albumObj.id);
        fileObj.Location__c = 'media';
        update fileObj;
        String str = '{"id":"' +fileObj.id + '","description":"description"}';
        ContentWrapper.MediaWrapper fileWrapperObj = (ContentWrapper.MediaWrapper) JSON.deserialize(str,ContentWrapper.MediaWrapper.class);
        serverObj.saveAlbumMediaToDB(albumObj.Id, fileObj.id, new List<ContentWrapper.MediaWrapper>{fileWrapperObj});
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testException() {
        Test.startTest();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target', 'SiteAddAlbumDataServer');
        Test.setCurrentpage(pageRef);      
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        serverObj.handleRequest(); 
        //action is missing
        System.assertEquals('error', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testUpdateForSubmission(){
        Test.startTest();
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        PageReference pgRef = Page.DataServerRW;
        CollaborationGroup priCollabGrp = new CollaborationGroup();
        priCollabGrp = TestHelper.createCollaborationGroup('SiteAddAlbumDataServer_Grp', 'Public');
        List<Simpplr_Site__c> listOfSitePublic = [select id, Name, Chatter_Group_Id__c FROM 
              Simpplr_Site__c  WHERE Chatter_Group_Id__c=:priCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{listOfSitePublic[0].Id});
        User UserObj = TestHelper.createUser('SiteAddAlbumDataServer_User', null, false);
        people__c pObj = [select id from people__c where user__c =:UserObj.id];
        Simpplr_Content__c content = TestHelper.createContent('simpplr test Album', 'Album', 'Submitted', UserObj, listOfSitePublic[0]);
        
        pgRef.getParameters().put('action', 'update'); 
        pgRef.getParameters().put('data','{"authoredBy":{"id":"' + pObj.Id + '","peopleId":"' + pObj.Id + '","sfUserId":"' + UserObj.Id + '","segmentId":null,"segmentName":null,"subSegment":null,"nickname":null,"name":"Utsav Chaurasia","firstName":"Utsav","lastName":"Chaurasia","fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/people/' + pObj.Id + '","img":null,"coverImageUrl":null,"title":null,"department":"enginnering","location":"Banglore, Australia","locationId":null,"company":null,"division":null,"street":null,"city":"Banglore","state":null,"country":"Australia","email":"utsav@gmail.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"lang":null,"userCategory":{"id":null,"name":null,"userCount":0}},"contentSubType":"","listOfFiles":[],"publishAt":"2020-04-09T00:00:00","bodyJson":null,"body":"<p><iframe></iframe></p> ","siteId":"' + listOfSitePublic[0].id  + '","imgCaption":null,"img":null,"listOfInlineImages":[],"summary":"ADDALBUM","listOfAlbumMedia":[{"id":"a0a4T0000007c77QAA","description":""}],"publishTo":null,"imgLayout":"small","listOfContentTopicIds":[],"isMaximumWidth":false,"imgOriginalFile":null,"imgOriginal":null,"imgLandscapeFile":null,"imgLandscape":null,"title":"ADDALBUM","isOpenToSubmissions":true,"isFeedEnabled":true,"listOfTopics":[],"coverImageMediaId":null,"imgFile":null,"id":null} ');
        Test.setCurrentPage(pgRef); 
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');

        Must_Read_Audit__c  mustReadAuditObj = TestHelper.createMustReadAudit(content.id, 'everyone', UserContext.peopleId);
        mustReadAuditObj.Removed_DateTime__c = null;
        mustReadAuditObj.Expiry_DateTime__c = null;
        update mustReadAuditObj;
        
        File__c fileObj2 = [Select id From File__c where title__c='TitleImage' And Location__c='media' LIMIT 1];   
        List<File__c> fileList = new List<File__c>();
        fileList.add(fileObj2);
        string fileJson = JSON.serialize(fileList);
        Content_History__c historyObj = new Content_History__c();
        historyObj.Content__c = content.id;
        historyObj.Version__c = 1;
        historyObj.Content_Json_Part1__c = '"{"attributes":{"type":"Simpplr_Content__c"},"Total_View_Count__c":2,"Popularity_Score__c":20,"Version__c":1,"Last_Edited_DateTime__c":"2020-04-15T09:46:42.000+0000","First_Publish_DateTime__c":"2020-04-15T09:46:42.000+0000","Is_Published__c":true,"Primary_Author__c":"'+pObj.Id+'","Publish_Start_DateTime__c":"2020-04-14T18:30:00.000+0000","Title__c":"TestAlbum","Type__c":"Album","Id":"'+content.Id+'","Status__c":"Approved","Unique_View_Count__c":1,"Display_Order__c":1,"Allow_Comments__c":true,"Site__c":"'+listOfSitePublic[0].Id+'","Activated_By_Feature__c":true}"';
        historyObj.File_Json__c = fileJson;
        insert historyObj;
        
        File__c fileObj = TestHelper.createContentTitleImage(content.id);
        fileObj.MIME_Type__c = 'Image';
        fileObj.Location__c = 'attachment';
        update fileObj;
        
        Like__c likeObj = TestHelper.createContentLike(content.id, UserContext.peopleId);
        likeObj.File__c = fileObj.id;
        update likeObj;

        pgRef.getParameters().put('action', 'get');       
        pgRef.getParameters().put('origin', 'mobile');
        pgRef.getParameters().put('data', '{"contentId" : "'+content.id+'"}');
        pgRef.getParameters().put('contentId', content.id);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest static void testUpdateForSubmission2(){
        SiteAddAlbumDataServer serverObj = new SiteAddAlbumDataServer();
        PageReference pgRef = Page.DataServerRW;
        CollaborationGroup priCollabGrp = new CollaborationGroup();
        priCollabGrp = TestHelper.createCollaborationGroup('SiteAddAlbumDataServer_Grp', 'Public');
        List<Simpplr_Site__c> listOfSitePublic = [select id, Name, Chatter_Group_Id__c FROM 
        Simpplr_Site__c  WHERE Chatter_Group_Id__c=:priCollabGrp.id limit 1];
        TestHelper.shareSitesToAllPeople(new List<String>{listOfSitePublic[0].Id});
        User UserObj = TestHelper.createUser('SiteAddAlbumDataServer_User', null, false);
        people__c pObj = [select id from people__c where user__c =:UserObj.id];
        Simpplr_Content__c content = TestHelper.createContent('simpplr test Album', 'Album', 'Submitted', UserObj, listOfSitePublic[0]);
        File__c fileObj = TestHelper.createContentTitleImage(content.id);
        fileObj.MIME_Type__c = 'Image';
        
        Test.startTest();
        pgRef.getParameters().put('action', 'get');       
        pgRef.getParameters().put('origin', 'mobile');
        pgRef.getParameters().put('data', '{"contentId" : "'+content.id+'"}');
        pgRef.getParameters().put('contentId', content.id);
        Test.setCurrentPage(pgRef);

        fileObj.Location__c = 'inline';
        update fileObj;
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Status should be success');

        fileObj.Location__c = 'media';
        fileObj.MIME_Type__c = 'video';
        fileObj.Url__c = 'dummy';
        update fileObj;
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.Response.Status, 'Status should be success');
    }
}