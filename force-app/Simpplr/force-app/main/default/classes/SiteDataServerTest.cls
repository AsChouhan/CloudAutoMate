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
private class SiteDataServerTest {
	
   private static User adminUser;
   private static PageReference pageRef;
   
   @testSetup
   static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
    	appConfigRecord.Default_Page_Size__c = 0;
    	appConfigRecord.Segment_Enabled__c = true;
    	appConfigRecord.Segment_Column_Name__c = 'country__c';
    	update appConfigRecord;
        TestHelper.createContentVersion('H');
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
        User siteOwnr = TestHelper.createUser('SiteDataServerTest_siteOwnr', null, false);
        User adminUser = TestHelper.createUser('SiteDataServerTest_adminUser', null, true);
        addPermissionSet(adminUser.id);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('Simpplr_Grp_SiteDataServerTest','Public');
		CollaborationGroup cgroup2 = TestHelper.createCollaborationGroup('SiteDataServerTestPvt_Test','Private');
		CollaborationGroupMember cGrpMem = TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
        Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test Page', 'Page', 'Submitted', adminUser, getSimpplrSite('Simpplr_Grp_SiteDataServerTest'));
   		Segment__c segObj = TestHelper.createSegment(peopleObj.id);
       	TestHelper.addBookmarkForSite(getSimpplrSite('SiteDataServerTestPvt_Test').Id, peopleObj.Id);
       
        
   }
    
   @future
    private static void addPermissionSet(String userId) {
        List<PermissionSet> perAssignments = [SELECT Id, Name FROM PermissionSet where Name = 'Simpplr_User' limit 1];
        if(!perAssignments.isEmpty()) {
            PermissionSetAssignment perSetAssignObj = new PermissionSetAssignment();
            perSetAssignObj.PermissionSetId = perAssignments[0].id;
            perSetAssignObj.AssigneeId = userId;
            insert perSetAssignObj;
        }
    }

    private static void init() {
    	pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SiteDataServer');
       	Test.setCurrentpage(pageRef);
    }
    
    private static Simpplr_Site__c getSimpplrSite(String siteName){
    	 return([select id,chatter_group_id__c  from Simpplr_Site__c where name = :siteName]);
    }
    
    private static User getUserAsSiteManager(){
        User userObj = [select id,name from User where lastname='SiteDataServerTest_siteOwnr'];
        return userObj;
    }
    
    private static User getUserByName(String lastName){
        User userObj = [select id,name from User where lastname = :lastName];
        return userObj;
    }
  
    @isTest 
    static void testHandleRequestWhenActionNull() {
    	init();
     	SiteDataServer siteDSObject= new SiteDataServer();
        pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SiteDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','search');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','setFeatured');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','setPrivate');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','createSite');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getsiteDetailData');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');

        pageRef.getParameters().put('action','getsiteDetailData');
        pageRef.getParameters().put('siteId','dummy');
        pageRef.getParameters().put('chatterGroupId','dummy');
        SiteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','setActivated');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','setCategory');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','setImage');
        pageRef.getParameters().put('siteId','dummy');
        pageRef.getParameters().put('imageFile','{"isAccessible":true,"size":"33832","isDownloadableOniOS":false,"isLiked":false,"canUnlink":false,"isDir":false,"permissions":null,"canCreateNewVersion":true,"canCreatePublicShareLink":true,"externalUrl":null,"publicUrl":null,"downloadUrl":"/sfc/servlet.shepherd/version/Download/0684T0000016ecQQAQ?asPdf=false&operationContext=CHATTER","canChangeName":false,"rootDirectory":null,"sites":[],"contentDocumentId":"0694T0000016jw9QAA","url":"/apex/FileDetail?siteId=undefined&fileId=0694T0000016jw9QAA","context":"intranet","pathOnClient":"Mahi.jpg","provider":"intranet","isImage":true,"canSetPermissions":false,"fileUrl":"https://c.na136.content.force.com/sfc/servlet.shepherd/version/Download/0684T0000016ecQQAQ?asPdf=false&operationContext=CHATTER","owner":{"id":"0054T000000Jj7dQAC","peopleId":"0054T000000Jj7dQAC","sfUserId":null,"segmentId":null,"segmentName":null,"nickname":null,"name":"Simran Rawat","firstName":null,"lastName":null,"fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/redirect-to-profile/0054T000000Jj7dQAC","img":null,"coverImageUrl":null,"title":null,"department":null,"location":null,"locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":null,"email":null,"phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"isSystemDir":false,"thumbnailImgLocal":"blob:https://c.na136.visual.force.com/8efc5de5-0723-44cb-aeee-62240b440482","isExternal":false,"location":null,"thumbnailImg":"/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=0684T0000016ecQQAQ","fileId":null,"canDownload":true,"title":"Mahi.jpg","directoryName":null,"type":"JPG","contentVersionId":"0684T0000016ecQQAQ","id":"0694T0000016jw9QAA","createdAt":null,"canDelete":true,"basename":"Mahi","modifiedAt":"2020-01-15T19:54:02-08:00","isFavorited":false,"extension":"JPG"}');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','setCoverImage');
        pageRef.getParameters().put('siteId','dummy');
        pageRef.getParameters().put('imageFile','{"isAccessible":true,"size":"33832","isDownloadableOniOS":false,"isLiked":false,"canUnlink":false,"isDir":false,"permissions":null,"canCreateNewVersion":true,"canCreatePublicShareLink":true,"externalUrl":null,"publicUrl":null,"downloadUrl":"/sfc/servlet.shepherd/version/Download/0684T0000016ecQQAQ?asPdf=false&operationContext=CHATTER","canChangeName":false,"rootDirectory":null,"sites":[],"contentDocumentId":"0694T0000016jw9QAA","url":"/apex/FileDetail?siteId=undefined&fileId=0694T0000016jw9QAA","context":"intranet","pathOnClient":"Mahi.jpg","provider":"intranet","isImage":true,"canSetPermissions":false,"fileUrl":"https://c.na136.content.force.com/sfc/servlet.shepherd/version/Download/0684T0000016ecQQAQ?asPdf=false&operationContext=CHATTER","owner":{"id":"0054T000000Jj7dQAC","peopleId":"0054T000000Jj7dQAC","sfUserId":null,"segmentId":null,"segmentName":null,"nickname":null,"name":"Simran Rawat","firstName":null,"lastName":null,"fullName":null,"url":"https://c.na136.visual.force.com/apex/app?u=/redirect-to-profile/0054T000000Jj7dQAC","img":null,"coverImageUrl":null,"title":null,"department":null,"location":null,"locationId":null,"company":null,"division":null,"street":null,"city":null,"state":null,"country":null,"email":null,"phone":null,"mobile":null,"videoCallProvider":null,"videoCallUsername":null,"phoneExtension":null,"about":null,"birthday":null,"workAnniversary":null,"hireDate":null,"manager":null,"isFollowing":false,"isFavorited":false,"isActive":true,"isNewUser":false,"canFollow":false,"hasConnectedBoxAccount":false,"hasConnectedGoogleDriveAccount":false,"hasConnectedDropboxAccount":false,"hasConnectedTwitterAccount":false,"hasConnectedLinkedInAccount":false,"hasConnectedServiceNowAccount":false,"hasConnectedSharePointAccount":false,"hasConnectedOneDriveAccount":false,"hasConnectedSlackAccount":false,"hasRead":false,"lastLoginAt":null,"permissions":{"isAppManager":false,"isSiteManager":false,"isUnlistedAdmin":false,"isSegmentManager":false,"canCreateSite":false,"canCreateBlogPost":false,"canCreateTopics":false,"canAccessAllPrivateSites":false,"canManageHomeDashboard":false,"canAccessAnalytics":false,"canSendNewsletter":false,"canSendNewsletterToAll":false,"canSendAlerts":false,"canSendAlertsToAll":false,"canManageCampaigns":false},"listOfCustomFields":[],"timezoneName":null,"timezoneIso":null,"timezoneOffset":0,"language":null,"userCategory":{"id":null,"name":null,"userCount":0}},"isSystemDir":false,"thumbnailImgLocal":"blob:https://c.na136.visual.force.com/8efc5de5-0723-44cb-aeee-62240b440482","isExternal":false,"location":null,"thumbnailImg":"/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB240BY180&versionId=0684T0000016ecQQAQ","fileId":null,"canDownload":true,"title":"Mahi.jpg","directoryName":null,"type":"JPG","contentVersionId":"0684T0000016ecQQAQ","id":"0694T0000016jw9QAA","createdAt":null,"canDelete":true,"basename":"Mahi","modifiedAt":"2020-01-15T19:54:02-08:00","isFavorited":false,"extension":"JPG"}');
        SiteDSObject.handleRequest();                
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','revertToChatterGroup');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','approveSubscription');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','rejectSubscription');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','request');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','arrangeFeaturedSites');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
    } 
    
    
    @isTest
    static void testHandleRequestWhenActionAvailable() {
        init();        
        SiteDataServer siteDSObject= new SiteDataServer();
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{}');
        SiteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','setFeatured');
        pageRef.getParameters().put('data','{}');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','setPrivate');
        pageRef.getParameters().put('data','{}');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','createSite');
        pageRef.getParameters().put('data','{}');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('action','getsitedetail');
        pageRef.getParameters().put('data','{}');
        SiteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
    }
    
    @isTest
    static void testHandleRequestWhenSiteAvailable() {
        init();
    	String siteId = getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id;
    	pageRef.getParameters().put('siteId',siteId);
    	
    	pageRef.getParameters().put('action','revertToChatterGroup');
    	Test.setCurrentPage(pageRef);
        SiteDataServer siteDSObject= new SiteDataServer();
        SiteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
    }
    
    @isTest
    static void testGetPeopleStats() {
        init();
    	String siteId = getSimpplrSite('Simpplr_Grp_SiteDataServerTest').Id;
        
        People__c peopleObj = [Select Id From People__c Where User__r.lastName = 'SiteDataServerTest_siteOwnr'];
        Site_Role__c siterole = new Site_Role__c(is_Member__c = true,people__c = peopleObj.Id,site__c = siteId);
		insert siterole;
        
    	pageRef.getParameters().put('action','getPeopleStats');
        Test.setCurrentPage(pageRef);
    	
        SiteDataServer siteDSObject= new SiteDataServer();
        
        pageRef.getParameters().put('data','{"siteId":"' + siteId + '","term":""}');
        SiteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
    }
    
    @isTest 
    static void testApproveMembershipRequest() {
        init();
        Test.startTest();
        SiteDataServer siteDSObject= new SiteDataServer();
        User userObj = TestHelper.createUser('New_Simpplr_usr', null, false);
        User adminUserObj = getUserByName('SiteDataServerTest_adminUser');
        String publicSiteId = getSimpplrSite('Simpplr_Grp_SiteDataServerTest').Id;
        Simpplr_Site__c privateSite = getSimpplrSite('SiteDataServerTestPvt_Test');
        TestHelper.shareSitesToAllPeople(new List<String>{publicSiteId, privateSite.Id});
        system.runAs(userObj){
			pageRef.getParameters().put('action', 'request');
            pageRef.getParameters().put('data', publicSiteId);
            Test.setCurrentPage(pageRef);
            SiteDSObject.handleRequest();
            System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
            pageRef.getParameters().put('action', 'request');
            pageRef.getParameters().put('data', privateSite.Id);
            Test.setCurrentPage(pageRef);
            SiteDSObject.handleRequest();
            System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        }
        
        system.runAs(adminUserObj){
            Site_Membership_Request__c publicSiteRequest = [SELECT Id, user__c, Site__c, 
                                                Site__r.Id, Site__r.Name, Status__c 
                                                FROM Site_Membership_Request__c where Site__c =:publicSiteId LIMIT 1];
            pageRef.getParameters().put('action', 'approveMembershipRequest');
            pageRef.getParameters().put('data', '{"requestId":"' + publicSiteRequest.id + '","siteType":"public"}');
            Test.setCurrentPage(pageRef);
            SiteDSObject.handleRequest();
            System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
            
            CollaborationGroupMemberRequest privateSiteRequest = [SELECT Id, CollaborationGroupId
                                                FROM CollaborationGroupMemberRequest LIMIT 1];
            
            pageRef.getParameters().put('data', '{"requestId":"' + privateSiteRequest.id + '","siteType":"private"}');
            Test.setCurrentPage(pageRef);
            SiteDSObject.handleRequest();
            System.assertEquals('success', siteDSObject.response.status, siteDSObject.response.message);
        }
        
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest 
    static void testRejectMembershipRequest() {
         init();
        Test.startTest();
        SiteDataServer siteDSObject= new SiteDataServer();
        User userObj = TestHelper.createUser('New_Simpplr_usr2', null, false);
        User adminUserObj = getUserByName('SiteDataServerTest_adminUser');
        String publicSiteId = getSimpplrSite('Simpplr_Grp_SiteDataServerTest').Id;
        Simpplr_Site__c privateSite = getSimpplrSite('SiteDataServerTestPvt_Test');
        TestHelper.shareSitesToAllPeople(new List<String>{publicSiteId, privateSite.Id});
        system.runAs(userObj){
			pageRef.getParameters().put('action', 'request');
            pageRef.getParameters().put('data', publicSiteId);
            Test.setCurrentPage(pageRef);
            SiteDSObject.handleRequest();
            System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
            pageRef.getParameters().put('action', 'request');
            pageRef.getParameters().put('data', privateSite.Id);
            Test.setCurrentPage(pageRef);
            SiteDSObject.handleRequest();
            System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        }
        
        system.runAs(adminUserObj){
            Site_Membership_Request__c publicSiteRequest = [SELECT Id, User__c, Site__c, 
                                                Site__r.Id, Site__r.Name, Status__c 
                                                FROM Site_Membership_Request__c where Site__c =:publicSiteId LIMIT 1];
            pageRef.getParameters().put('action', 'rejectMembershipRequest');
            pageRef.getParameters().put('data', '{"requestId":"' + publicSiteRequest.id + '","siteType":"public"}');
            Test.setCurrentPage(pageRef);
            SiteDSObject.handleRequest();
            System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
            
            CollaborationGroupMemberRequest privateSiteRequest = [SELECT Id, CollaborationGroupId
                                                FROM CollaborationGroupMemberRequest LIMIT 1];
                                                
            pageRef.getParameters().put('data', '{"requestId":"' + privateSiteRequest.id + '","siteType":"private"}');
            Test.setCurrentPage(pageRef);
            SiteDSObject.handleRequest();
            System.assertEquals('success', siteDSObject.response.status, 'Running as expected');

        }
        
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest
    static void testSetFeatured() { 
    	init();
        Segment__c segObj = [Select id From Segment__c where  Name__c =: 'Untitled Segment'];
        Segment_Site__c segSiteObj = new Segment_Site__c();
       	segSiteObj.site__c = getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id;
       	segSiteObj.Segment__c = segObj.id;
       	segSiteObj.is_featured__c = true;
       	insert segSiteObj;
        SiteDataServer siteDSObject= new SiteDataServer();        
        List<String> values = new List<String>{getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id};
        String str = '"idsArray":["{0}"]';
        String jsonString = '{"listOfSiteIds":["'+getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id+'"],"makeFeaturedBool":true,"segmentId":"'+segObj.id+'"}';
		ResponseWrapper resWrapper1 = SiteDSObject.setFeatured(jsonString); 
        System.assertEquals('success', resWrapper1.status, 'Running as expected');
		ResponseWrapper resWrapper2 = SiteDSObject.setFeatured('{"listOfSiteIds":["'+getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id+'"],"makeFeaturedBool":false,"segmentId":"'+segObj.id+'"}'); 		
        System.assertEquals('success', resWrapper2.status, 'Running as expected');
		SimpplrContext.isSegmentsEnabled = false;
        ResponseWrapper resWrapper3 = SiteDSObject.setFeatured(jsonString); 
        System.assertEquals('success', resWrapper3.status, 'Running as expected');
		//SiteDSObject.setFeatured('{"listOfSiteIds":["'+getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id+'"],"makeFeaturedBool":false,"segmentId":"'+segObj.id+'"}'); 
        system.assert(true,'Running as expected');
    }
    
    @isTest
    static void testSetFeatured2() { 
    	init();
        Segment__c segObj = [Select id From Segment__c where  Name__c =: 'Untitled Segment'];
        Segment_Site__c segSiteObj = new Segment_Site__c();
       	segSiteObj.site__c = getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id;
       	segSiteObj.Segment__c = segObj.id;
       	segSiteObj.is_featured__c = true;
       	insert segSiteObj;
        SiteDataServer siteDSObject= new SiteDataServer();        
         
		ResponseWrapper resWrapper1 = SiteDSObject.setFeatured('{"listOfSiteIds":["'+getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id+'"],"makeFeaturedBool":false,"segmentId":"'+segObj.id+'"}'); 
        System.assertEquals('success', resWrapper1.status, 'Running as expected');
    }
    
    @isTest
    static void testSetPrivate() { 
    	init();
        
        simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_SiteDataServerTest');
        siteObj.Site_Type__c = 'Public';
        update siteObj;
        Folder__c folderObj = TestHelper.createChatterFolder('testFolder01', null, siteObj.id, 'gdrive', null, 'readwrite');
        folderObj.is_deleted__c = false;
        update folderObj;
        SiteDataServer siteDSObject= new SiteDataServer();        
        List<String> values = new List<String>{siteObj.id};
        String str = '"idsArray":["{0}"]';
        SimpplrContext.isGdriveConnected = true;
        String jsonString = '{' + EmailUtility.format(str,values) + ',"makePrivateBool":true'  +'}';
        ResponseWrapper resWrapper1 = SiteDSObject.setPrivate(jsonString);
        System.assertEquals('success', resWrapper1.status, 'Running as expected');
        ResponseWrapper resWrapper2 = SiteDSObject.setPrivate(''); 	
        System.assertEquals('error', resWrapper2.status, 'Running as expected');
    }
    
    @isTest
    static void testSetActivate() { 
    	init();
        SiteDataServer siteDSObject= new SiteDataServer();        
        List<String> values = new List<String>{getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id};
        String str = '"idsArray":["{0}"]';
        String jsonString = '{' + EmailUtility.format(str,values) + ',"makeActivatedBool":true'  +'}';
		ResponseWrapper resWrapper1 = SiteDSObject.setActivate(jsonString);
		System.assertEquals('success', resWrapper1.status, 'Running as expected');
		ResponseWrapper resWrapper2 = SiteDSObject.setActivate(''); 		
		System.assertEquals('error', resWrapper2.status, 'Running as expected');
    }
    
   @isTest
   static void testCreateSite() {
        init();
        SiteDataServer siteDSObject= new SiteDataServer();  
        Test.startTest();
        ResponseWrapper resp1 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestTesting1","siteImageThumbnail":null,"description":"Testing Testing Testing Testing","siteAccess":"public","isFeatured":true,"isBroadcast":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');
        System.assertEquals('error', resp1.status, 'Running as expected');
        ResponseWrapper resp2 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestTesting2","siteImageThumbnail":null,"description":"Testing Testing Testing Testing","siteAccess":"private","isFeatured":false,"isBroadcast":true,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');
        System.assertEquals('error', resp2.status, 'Running as expected');
        ResponseWrapper resp3 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestTesting3","siteImageThumbnail":null,"description":"Testing Testing Testing Testing","siteAccess":"unlisted","isFeatured":false,"isBroadcast":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');
        System.assertEquals('error', resp3.status, 'Running as expected');
        ResponseWrapper resp5 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestTesting4","siteImageThumbnail":null,"description":"Testing Testing Testing Testing","siteAccess":"unlisted","isFeatured":true,"isBroadcast":true,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');       
        System.assertEquals('error', resp5.status, 'Running as expected');
        ResponseWrapper resp6 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestTesting5","siteImageThumbnail":null,"description":"Testing Testing Testing Testing","siteAccess":"private","isFeatured":false,"isBroadcast":true,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');
        System.assertEquals('error', resp6.status, 'Running as expected');
        ResponseWrapper resp7 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestMyCate6","siteImageThumbnail":null,"description":"MyCate","category":null,"siteAccess":"public","isBroadcast":true,"isFeatured":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');
        System.assertEquals('error', resp7.status, 'Running as expected');
        ResponseWrapper resp8 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestMyCate7","siteImageThumbnail":null,"description":"MyCate","category":null,"siteAccess":"public","isBroadcast":true,"isFeatured":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');
        System.assertEquals('error', resp8.status, 'Running as expected');
        ResponseWrapper resp9 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestMyCate8","siteImageThumbnail":null,"description":"MyCate","category":SiteDataServerTestMyCate7,"siteAccess":"public","isBroadcast":true,"isFeatured":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');       
        System.assertEquals('error', resp9.status, 'Running as expected');
        ResponseWrapper resp10 = SiteDSObject.createSite('{"siteName":"SiteDataServerTestMyCate9","siteImageThumbnail":null,"description":"MyCate","category":SiteDataServerTestMyCate7,"siteAccess":"public","isBroadcast":true,"isFeatured":false,"titleImage":[],"titleImageCaption":null,"deletedTitleImage":[]}');
        System.assertEquals('error', resp10.status, 'Running as expected');
        Test.stopTest();
        
        ResponseWrapper resp11 = SiteDSObject.createSite('{"access":"public","name":"test temp 02","description":"qwqw","category":{"name":"Category 19","id":null,"categoryId":null,"url":null}}');
        System.assertEquals('error', resp11.status, 'Running as expected');
    }
    
   @isTest
   static void testCreateSiteEmpty() {
        init();
        SiteDataServer siteDSObject= new SiteDataServer();  
        ResponseWrapper resp = SiteDSObject.createSite('{}');
        System.assertEquals('error', resp.status, 'Running as expected');
    }    
    
   @isTest
   static void testSetCategory() {
       init();
       SiteDataServer siteDSObject= new SiteDataServer();  
       ResponseWrapper resp1 = SiteDSObject.setCategory('{"idsArray":[],"categoryObj":{"category":"","categoryName":"Test"}}');
       System.assertEquals('success', resp1.status, 'Running as expected');
       ResponseWrapper resp2 = SiteDSObject.setCategory('{"idsArray":[],"categoryObj":{"category":"","categoryName":""}}');
       System.assertEquals('success', resp2.status, 'Running as expected');
    }   
        
    static void unfollowSite(String cgId, String userId) {
    	delete [select id from CollaborationGroupMember where CollaborationGroupId = :cgId and MemberId = :userId];
    }
    
    @isTest 
    static void testSetImage() {
    	init();
        SiteDataServer siteDSObject= new SiteDataServer();        
	    ResponseWrapper resWrapper4 = SiteDSObject.setImage(getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id, null);        
        System.assertEquals('success', resWrapper4.status, 'Running as expected');
    } 
    
    @isTest 
    static void testSetCoverImage() {
    	init();
        SiteDataServer siteDSObject= new SiteDataServer();        
	    ResponseWrapper resWrapper4 = SiteDSObject.setCoverImage(getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id, null);        
        System.assertEquals('success', resWrapper4.status, 'Running as expected');
    }          
    
    @isTest
    static void testSetSiteSequence() {
       init();
       SiteDataServer siteDSObject= new SiteDataServer();
       Segment__c segObj = [Select id From Segment__c where  Name__c =: 'Untitled Segment']; 
       Segment_Site__c segSiteObj = new Segment_Site__c();
       segSiteObj.site__c = getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id;
       segSiteObj.Segment__c = segObj.id;
       segSiteObj.is_featured__c = true;
       insert segSiteObj;
       SiteWrapper.SequenceWrapper sequenceObj = new SiteWrapper.SequenceWrapper();
       sequenceObj.idsArray = new List<String>{getSimpplrSite('Simpplr_Grp_SiteDataServerTest').id};
       sequenceObj.segmentId = segObj.id;
       String listOfSiteIds=JSON.serialize(sequenceObj);
       
       User userObj = getUserByName('SiteDataServerTest_adminUser');
       system.runAs(userObj){
            ResponseWrapper resWrapper1 = SiteDSObject.setSiteSequence(listOfSiteIds);
            System.assertEquals('success', resWrapper1.status, 'Running as expected');
       }
       ResponseWrapper resWrapper2 = SiteDSObject.setSiteSequence(listOfSiteIds);
       System.assertEquals('success', resWrapper2.status, 'Running as expected');
    }
    
    @isTest
    static void testPublicSiteMembership() {
        Test.startTest();
        init();
        pageRef.getParameters().put('target','SiteDataServer');
        pageRef.getParameters().put('action','request');
        simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_SiteDataServerTest');
        pageRef.getParameters().put('data',siteObj.id);
        SiteDataServer siteDSObject= new SiteDataServer();
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        Site_Membership_Request__c request = [SELECT Id, User__c, Site__c, 
                                                Site__r.Id, Site__r.Name, Status__c 
                                                FROM Site_Membership_Request__c Limit 1];
        pageRef.getParameters().put('action', 'approveMembershipRequest');
        pageRef.getParameters().put('data', '{"requestId":"' +  request.id + '","siteType":"public"}');
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        siteObj = getSimpplrSite('SiteDataServerTestPvt_Test');
        pageRef.getParameters().put('action','request');
        pageRef.getParameters().put('data',siteObj.id);
        siteDSObject.handleRequest();
        System.assertEquals('error', siteDSObject.response.status, 'Running as expected');
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    
    @isTest 
    static void testSearch1() {
    	init();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchSites',true));
        Test.startTest();
    	User userObj = getUserAsSiteManager();
    	People__c peopleRecord = [select id from People__c where User__c=:userObj.id];    	 
        SiteDataServer siteDSObject= new SiteDataServer();        
        List<String> values = new List<String>{peopleRecord.id,userObj.id};
        String str = '"profileId":"{0}","sfUserId":"{1}"';
        
        String jsonString = '{' + '"filter":"managing",' +EmailUtility.format(str,values) + ',"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper1 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper1.status, 'Running as expected');

        jsonString = '{' + '"filter":null,' +EmailUtility.format(str,values) + ',"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper2 = SiteDSObject.getSites(jsonString);
        System.assertEquals('error', resWrapper2.status, 'Running as expected as filter is null');

        jsonString = '{' + '"canManage":true,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper3 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper3.status, 'Running as expected');

        jsonString = '{' + '"term":"aa","canAccess":true,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper4 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper4.status, 'Running as expected');
        Test.stopTest();
    }     
    @isTest 
    static void testSearch2() {
        Test.startTest();
    	init();
    	User userObj = getUserAsSiteManager();    	 
        SiteDataServer siteDSObject= new SiteDataServer();        
    	
        String jsonString = '{' + '"filter":"canSubmitContent","category":"all","size":10'  +'}';
        ResponseWrapper resWrapper1 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper1.status, 'Running as expected');
    	
        jsonString = '{' + '"filter":"canCreateAlert","category":"all","size":10'  +'}';
        ResponseWrapper resWrapper2 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper2.status, 'Running as expected');

        jsonString = '{' + '"filter":"canCreateNewsletter","category":"all","size":10'  +'}';
        ResponseWrapper resWrapper3 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper3.status, 'Running as expected');

        jsonString = '{' + '"filter":"canAccessAnalytics","category":"all","size":10'  +'}';
        ResponseWrapper resWrapper4 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper4.status, 'Running as expected');

        jsonString = '{' + '"filter":"listed","category":"all","size":10'  +'}';
        ResponseWrapper resWrapper5 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper5.status, 'Running as expected');

        jsonString = '{' + '"filter":"popular","includeDeactivated":false,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper6 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper6.status, 'Running as expected');

        SimpplrContext.isSegmentsEnabled = true;
        jsonString = '{' + '"filter":"featured","includeDeactivated":false,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper7 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper7.status, 'Running as expected');
        SimpplrContext.isSegmentsEnabled = false;
        jsonString = '{' + '"filter":"featured","includeDeactivated":false,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper8 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper8.status, 'Running as expected');

        jsonString = '{' + '"filter":"favorite","includeDeactivated":false,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper9 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper9.status, 'Running as expected');

        jsonString = '{' + '"filter":"managing","includeDeactivated":false,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper10 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper10.status, 'Running as expected');

        jsonString = '{' + '"filter":null,"includeDeactivated":false,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper11 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper11.status, 'Running as expected');

        jsonString = '{' + '"filter":"following","includeDeactivated":false,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper12 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper12.status, 'Running as expected');

        jsonString = '{' + '"filter":"recentUsedSites","includeDeactivated":true,"category":"all","size":10'  +'}';
        ResponseWrapper resWrapper13 = SiteDSObject.getSites(jsonString);
        System.assertEquals('success', resWrapper13.status, 'Running as expected');
		Test.stopTest();
    }

	@isTest
    static void testGetSitesSearchResultsManagedByLoggedInUser() {
        Test.startTest();
        
        init();
        SiteDataServer siteDSObject= new SiteDataServer();
        
        pageRef.getParameters().put('target','SiteDataServer');
        pageRef.getParameters().put('action','search');
        
        pageRef.getParameters().put('data','{"isManager":true,"category":"all","size":10}');
        Test.setCurrentPage(pageRef);
        
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');

        Test.stopTest();
    }
    
    @isTest 
    static void testSearchSiteWhereMember() {
        Test.startTest();
    	init();
    	User userObj = getUserAsSiteManager();    	 
        SiteDataServer siteDSObject= new SiteDataServer();   
        
        pageRef.getParameters().put('action', 'search');
        Test.setCurrentPage(pageRef);
        
    	pageRef.getParameters().put('data', '{"size":16,"filter":"member","sortBy":"alphabetical"}');
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"size":16,"filter":"all","sortBy":"alphabetical"}');
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"sfUserId":"'+UserInfo.getUserId()+'","size":16,"filter":"profileSites","sortBy":"alphabetical"}');
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        
		Test.stopTest();
    }
    
    @isTest 
    static void testGetSiteDetailData() {
        Test.startTest();
    	init();
    	User userObj = getUserAsSiteManager();  
        Simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_SiteDataServerTest');
        
        People__c peopleObj = [Select Id From People__c Where User__c = :UserInfo.getUserId()];
        Site_Role__c siteRoleObj = TestHelper.createSiteRole(peopleObj.Id, siteObj.Id);
        siteRoleObj.Is_Member__c = true;
        siteRoleObj.Is_Content_Manager__c = true;
        update siteRoleObj;
        
        SiteDataServer siteDSObject= new SiteDataServer();
        
        pageRef.getParameters().put('action', 'getsiteDetailData');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('siteId', siteObj.Id);
        pageRef.getParameters().put('chatterGroupId', siteObj.Chatter_Group_Id__c);
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"size":16,"filter":"all","sortBy":"alphabetical"}');
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        
        pageRef.getParameters().put('data', '{"sfUserId":"'+UserInfo.getUserId()+'","size":16,"filter":"profileSites","sortBy":"alphabetical"}');
        siteDSObject.handleRequest();
        System.assertEquals('success', siteDSObject.response.status, 'Running as expected');
        
		Test.stopTest();
        System.assert(true,'Running as expected');  
    }
    
    @isTest 
    static void testSubscription() {
        init();
 		
 		CollaborationGroup cgroup2 = TestHelper.createCollaborationGroup('SiteDataServerTestPvt','Private');
		Simpplr_Site__c siteRec  = [select id,chatter_group_id__c  from Simpplr_Site__c where name ='SiteDataServerTestPvt'][0];
		
		People__c peopleRec = [Select id from People__c where user__c=:UserInfo.getUserId()];
        Segment__c segmentRec = TestHelper.createSegment(peopleRec.Id); 
		Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
		Subscription__c subscriptionRec = TestHelper.createSubscription(audienceRec.Id, peopleRec.Id, 'Site');
        subscriptionRec.Status__c = 'approved';
        update subscriptionRec;
        Audience_Member__c audMemObj = new Audience_Member__c();
        audMemObj.Audience__c = audienceRec.id;
        audMemObj.user__c = UserInfo.getUserId();
        audMemObj.people__c = peopleRec.id;
        insert audMemObj;
        
		List<Subscription_Entity__c> listOfSubscriptionEntity = TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRec.Id, siteRec.Id);
        Subscription_Entity__c subEntityOb = new Subscription_Entity__c();
        subEntityOb.Status__c = 'approved';
        listOfSubscriptionEntity.add(subEntityOb);
		
        Test.startTest();        
        pageRef.getParameters().put('target', 'SiteDataServer');
        pageRef.getParameters().put('action','approveSubscription');
        pageRef.getParameters().put('siteId',siteRec.Id);
        pageRef.getParameters().put('subscriptionId',subscriptionRec.Id);
        Test.setCurrentPage(pageRef);
        SiteDataServer siteDSObject= new SiteDataServer();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'approveSubscription',true));
        SiteDSObject.handleRequest();
        pageRef.getParameters().put('action','rejectSubscription');
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'rejectSubscription',true));
		SiteDSObject.handleRequest();
        Test.stopTest();
        System.assert(true,'Running as expected');
    } 
    
    @isTest 
    static void testSearchWhenExternalSearchEnable() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExternalSearchHttpMock('',200,'searchSites',true));
        init();
 		PageReference pageRef = Page.DataServerRO;
        pageRef.getParameters().put('target','SiteDataServer');
        pageRef.getParameters().put('action','search');
        pageRef.getParameters().put('data','{"size":16,"filter":"favorites","term":"SiteData"}');
        Test.setCurrentPage(pageRef);
        SiteDataServer dSObject= new SiteDataServer();  
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status, 'Running as expected');
        pageRef.getParameters().put('data','{"size":16,"term":"SiteData"}');
        Test.setCurrentPage(pageRef);
        dSObject.handleRequest();
        System.assertEquals('success', dSObject.response.status, 'Running as expected');
        Test.stopTest();
    }

    @isTest 
    static void testDuplicateSite() {
        List<CollaborationGroup> listCGs = new List<CollaborationGroup>();
        listCGs.add(TestHelper.createCollaborationGroup('SiteDataServerTestPvt','Private', false));
        listCGs.add(TestHelper.createCollaborationGroup('SiteDataServerTestPvt Copy','Private', false));
        listCGs.add(TestHelper.createCollaborationGroup('SiteDataServerTestPvt Copy 2','Private', false));
        insert listCGs;

        Simpplr_Site__c orginalSite  = [SELECT Id, Chatter_Group_Id__c From Simpplr_Site__c WHERE Name ='SiteDataServerTestPvt' LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        orginalSite.Title_Content_Version__c = cv.Id;
        orginalSite.Title_Content_Document__c = cv.ContentDocumentId;
        orginalSite.Cover_Content_Version__c = cv.Id;
        orginalSite.Cover_Content_Document__c = cv.ContentDocumentId;
        update orginalSite;
        
        Test.startTest();
        pageRef = Page.DataServerRW;
        Test.setCurrentpage(pageRef);
        pageRef.getParameters().put('target','SiteDataServer');
        
        SiteDataServer dSObject= new SiteDataServer();
        pageRef.getParameters().put('action','createDuplicate');
        pageRef.getParameters().put('data','{"siteId":"' + orginalSite.Id + '","shouldCopyPageCategories":true,"shouldCopyDashboard":true}');
        dSObject.handleRequest();

        List<Simpplr_Site__c> listDuplicateSite  = [SELECT Id, Name From Simpplr_Site__c WHERE Name ='SiteDataServerTestPvt Copy 3'];
        System.assertEquals(1, listDuplicateSite.size(), 'Failed to duplicate site');

        Test.stopTest();
    }
   
}