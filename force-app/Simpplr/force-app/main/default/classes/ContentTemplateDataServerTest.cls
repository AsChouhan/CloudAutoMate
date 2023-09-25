/**
 * @description       : Test class for ContentTemplate related classes
 * @author            : simpplr.com
 * @group             : content
 * @last modified on  : 03-21-2022
 * @last modified by  : simpplr.com
**/
@isTest
private class ContentTemplateDataServerTest {

    private static Simpplr_Site__c site;
    private static User standardUserObj;
    private static User adminUserObj;
    private static People__c standardUsersPeopleObj;
    private static People__c adminUsersPeopleObj;
    private static User managerUserObj;
    private static Pages_Category__c pageCategory;
    private static PageReference pgRef;

    @testSetup 
    static void setup() {
        TestHelper.setupAppConfig();
        TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        standardUserObj = TestHelper.createUser('ContentTemplate_Simpplr_usr', null, false); 
        adminUserObj = TestHelper.createUser('ContentTemplate_Simpplr_admin', null, true);
        standardUsersPeopleObj = getPeople(standardUserObj.id); 
        adminUsersPeopleObj = getPeople(adminUserObj.id);

        CollaborationGroup collabGroupObj= TestHelper.createCollaborationGroup('ContentTemplate_Grp1','Public');
        site = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
        if(pageCategory == null){
            pageCategory = new Pages_Category__c(Name__c='Test Page Category',Site__c =site.id,Order__c =0,Is_Deleted__c = false);
            insert pageCategory;
        }
        Simpplr_Site__c  siteRecord = TestHelper.getSiteRecord(site.Chatter_Group_Id__c);
        TestHelper.shareSitesToAllPeople(new List<String>{siteRecord.Id});
        Site_Role__c memberSiteRole = TestHelper.createSiteRole(standardUsersPeopleObj.Id, site.id, false, true);
        Site_Role__c managerSiteRole = TestHelper.createSiteRole(adminUsersPeopleObj.Id, site.id, true, true);

        Content_Template__c conTemp1 = TestHelper.createContentTemplate('PageTemplate1', 'page', 'Page1', site.id, pageCategory.id, adminUsersPeopleObj.id,false);
        Content_Template__c sysTemp1 = TestHelper.createContentTemplate('SystemPageTemplate', 'page', 'SystemPage', site.id, pageCategory.id, adminUsersPeopleObj.id, true);

    }

    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c,user__r.name, Mobile_Phone__c, Manager__c, 
                                    Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
                                    From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }

    private static Content_Template__c getContentTemplateByName() {
        Content_Template__c contentTemplateObj = [select id, Name__c from Content_Template__c where Name__c = 'PageTemplate1'];
        return contentTemplateObj;
    }

    private static void createfilesAndTopic(String contentTemplateId) {
        Topic topic = TestHelper.createTopic('ContentTemplate1');
        TestHelper.addTopicToContentTemplate(topic.id, contentTemplateId);
        TestHelper.createContentTemplateTitleImage(contentTemplateId, 'Widescreen');
        TestHelper.createContentTemplateTitleImage(contentTemplateId, 'thumbnail');
        TestHelper.createContentTemplateTitleImage(contentTemplateId, 'original');
        TestHelper.createContentTemplateInlineImage(contentTemplateId, 'intranet');
        TestHelper.createContentTemplateInlineImage(contentTemplateId, 'native_video');
    }

    static void init() {
        SimpplrContext.isPageTemplateEnabled = true;
        site = TestHelper.getSiteRecordWithName('ContentTemplate_Grp1');
        standardUserObj = [select id from User where lastName='ContentTemplate_Simpplr_usr' limit 1];
        adminUserObj = [select id from User where lastName='ContentTemplate_Simpplr_admin' limit 1];
        pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','ContentTemplateDataServer');
        Test.setCurrentPage(pgRef);
    }

    @isTest 
    static void testSearchContentTemplates() {
        init();

        pgRef.getParameters().put('action','search');
        pgRef.getParameters().put('data','{"size":16,"siteId":"'+site.Id+'","type":"page"}');
        ContentTemplateDataServer conTemplateObj = new ContentTemplateDataServer();

        Test.startTest();
        
        conTemplateObj.handleRequest();
        System.assertEquals('success', conTemplateObj.response.status, 'Running as expected');

        pgRef.getParameters().put('data','{"size":16,"siteId":"'+site.Id+'","type":"page","sortBy":"modifiedNewest"}');
        conTemplateObj.handleRequest();

        System.assertEquals('success', conTemplateObj.response.status, 'Running as expected');

        pgRef.getParameters().put('data','{"size":16,"siteId":"'+site.Id+'","type":"page","sortBy":"createdNewest"}');
        conTemplateObj.handleRequest();

        System.assertEquals('success', conTemplateObj.response.status, 'Running as expected');

        pgRef.getParameters().put('data','{"size":16,"siteId":"'+site.Id+'","type":"page","nextPageToken":"16"}');
        conTemplateObj.handleRequest();

        System.assertEquals('success', conTemplateObj.response.status, 'Running as expected');

        Test.stopTest();
    }

    @isTest 
    static void testContentTemplateElasticSearch() {
        init();
        Test.startTest();

        pgRef.getParameters().put('action','search');
        pgRef.getParameters().put('data','{"size":16,"siteId":"'+site.Id+'","type":"page","term":"Page"}');
        ContentTemplateDataServer conTemplateObj = new ContentTemplateDataServer();

        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('OK', 200, 'searchContentTemplate', false));
        conTemplateObj.handleRequest();
        
        System.assertEquals('success', conTemplateObj.response.status, 'Running as expected');

        Test.stopTest();
    }
    
    @isTest static void testSaveContentTemplate(){
        Test.startTest();
        init();
        ContentTemplateDataServer serverObj = new ContentTemplateDataServer();
        PageReference pgRef = Page.DataServerRW;
        site.Show_In_Simpplr__c = true;
        update site;
        pgRef.getParameters().put('target', 'ContentTemplateDataServer');
        pgRef.getParameters().put('action', 'savePageTemplate'); 
        People__c p1 = new People__c();
        p1.User__c=adminUserObj.id;
        insert p1;
        System.debug('logLevel------'+p1+adminUserObj+site.id);
        pgRef.getParameters().put('data','{"authoredBy":{"id":"' + p1.Id + '","peopleId":"' + p1.Id + '","sfUserId":"' + adminUserObj.Id + '","segmentId":null,"segmentName":"Div-1-Segment","subSegment":"Div-1","nickname":"User15728614299281898678","name":"Utsav Chaurasia","firstName":"Utsav","lastName":null,"fullName":null,"url":null,"img":null,"coverImageUrl":null,"title":null,"department":"enginnering","location":"Banglore, Australia","locationId":"Banglore @@ null @@ Australia","company":"samsung","division":"Div-1","street":null,"city":"Banglore","state":null,"country":"Australia","email":"dummy@gmail.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":true,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":"2020-04-09T02:11:11.000-0700","permissions":{"isAppManager":false,"isSiteManager":true,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":true,"canCreateTopics":true,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":true,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":"America/Los_Angeles","timezoneIso":"America/Los_Angeles","timezoneOffset":-25200000,"language":null,"lang":"en-US","userCategory":{"id":null,"name":null,"userCount":0},"hasLoggedInToMobileApp":false,"dismissedOnboardingFlags":["userMenu"]},"contentSubType":"knowledge","listOfFiles":[],"publishAt":"2020-04-09T00:00:00","body":"<p>ADDPAGE</p>","siteId":"' + site.id  + '","summary":"ADDPAGE","imgLayout":"small","listOfContentTopicIds":[],"title":"ADDPAGE","isFeedEnabled":true,"listOfTopics":[{"id":null,"name":"ADDPAGE"}],"category":{"id":null,"name":"Uncategorized"}}');
        Test.setCurrentPage(pgRef); 
        serverObj.handleRequest();

        system.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }

    @isTest static void testgetContentTemplateById() {
        init();
        Content_Template__c contentTemplateObj = getContentTemplateByName();
        createfilesAndTopic(contentTemplateObj.id);
        pgRef.getParameters().put('action','get');
        pgRef.getParameters().put('contentTemplateId',contentTemplateObj.id);
        ContentTemplateDataServer conTemplateObj = new ContentTemplateDataServer();

        Test.startTest();
        conTemplateObj.handleRequest();
        System.assertEquals('success', conTemplateObj.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest static void testEditContentTemplate(){
        Test.startTest();
        init();
        ContentTemplateDataServer serverObj = new ContentTemplateDataServer();
        PageReference pgRef = Page.DataServerRW;
        site.Show_In_Simpplr__c = true;
        update site;
        pgRef.getParameters().put('target', 'ContentTemplateDataServer');
        pgRef.getParameters().put('action', 'updatePageTemplate'); 
        People__c p1 = new People__c();
        p1.User__c=adminUserObj.id;
        insert p1;
        Content_Template__c ct = new Content_Template__c();
        insert ct;
        pgRef.getParameters().put('siteId', site.id);
        pgRef.getParameters().put('templateId', ct.id); 
        pgRef.getParameters().put('data','{"authoredBy":{"id":"' + p1.Id + '","peopleId":"' + p1.Id + '","sfUserId":"' + adminUserObj.Id + '","segmentId":null,"segmentName":"Div-1-Segment","subSegment":"Div-1","nickname":"User15728614299281898678","name":"Utsav Chaurasia","firstName":"Utsav","lastName":null,"fullName":null,"url":null,"img":null,"coverImageUrl":null,"title":null,"department":"enginnering","location":"Banglore, Australia","locationId":"Banglore @@ null @@ Australia","company":"samsung","division":"Div-1","street":null,"city":"Banglore","state":null,"country":"Australia","email":"dummy@gmail.com","phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":true,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":"2020-04-09T02:11:11.000-0700","permissions":{"isAppManager":false,"isSiteManager":true,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":true,"canCreateTopics":true,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":true,"canSendAlertsToAll":false,"canManageCampaigns":false,"canManageInternalUsers":false,"isSystemAdmin":false},"listOfCustomFields":[],"timezoneName":"America/Los_Angeles","timezoneIso":"America/Los_Angeles","timezoneOffset":-25200000,"language":null,"lang":"en-US","userCategory":{"id":null,"name":null,"userCount":0},"hasLoggedInToMobileApp":false,"dismissedOnboardingFlags":["userMenu"]},"contentSubType":"knowledge","listOfFiles":[],"publishAt":"2020-04-09T00:00:00","body":"<p>ADDPAGE</p>","siteId":"' + site.id  + '","summary":"ADDPAGE","imgLayout":"small","listOfContentTopicIds":[],"title":"ADDPAGE","isFeedEnabled":true,"listOfTopics":[{"id":null,"name":"ADDPAGE"}],"category":{"id":null,"name":"Uncategorized"}}');
        Test.setCurrentPage(pgRef); 
        serverObj.handleRequest();

        system.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }
}