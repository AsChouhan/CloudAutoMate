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
private class ManageSiteDataServerTest {

    @testSetup
    static void setup() {
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        
        People__c peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        TestHelper.createPeoplePreference(peopleObj.Id);

        User testUser = TestHelper.createUser('ManageSiteDSTest_std', null, false);
        User testAdminUser = TestHelper.createUser('ManageSiteDSTest_admin', null, true); 
        User testUser2 = TestHelper.createUser('ManageSiteDSTest_usr2', testAdminUser, false);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('ManageSiteDSTest_Grp1', 'Public');
        CollaborationGroup cgroupPrivate = TestHelper.createCollaborationGroup('ManageSiteDSTestPrivateGrp', 'Private');
        TestHelper.createCollaborationGroupMember(cgroup.Id, testUser2.id,'Admin');
        Simpplr_Site__c  siteObj = [SELECT Id FROM Simpplr_Site__c WHERE Name='ManageSiteDSTest_Grp1' LIMIT 1];
        siteObj.File_Storage_Source__c = 'googledrive';
        update siteObj;
        Folder__c folderObj = TestHelper.createChatterFolder('Albums', null, siteObj.id, 'googledrive', null, 'readwrite');
        People__c peopleObj2 = [SELECT Id FROM People__c WHERE User__c = :testUser.Id];  
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE, IntegrationConstants.INTEGRATION_TYPE_DROPBOX, IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT, IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE});
        for (App_Integration__c appIntegObj : appIntegList){
          TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId, appIntegObj.Name, appIntegObj.id); 
        }
        
    }
    private static void init() {
    	PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        Test.setCurrentPage(pgRef);
	}
    private static User getStandardUser(){
        User userObj = [SELECT id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
        					FROM User WHERE lastName = 'ManageSiteDSTest_std' LIMIT 1];
        return userObj;
    }

    private static People__c getStandardPeople() {
        People__c peopleObj = [SELECT Id FROM People__c WHERE last_name__c = 'ManageSiteDSTest_std' LIMIT 1];
        return peopleObj;
    }
    
    private static User getAdminUser(){
        User userObj = [SELECT id,name,alias,profile.PermissionsCustomizeApplication,profile.PermissionsModifyAllData,profile.permissionsModerateChatter 
        					FROM User WHERE lastname='ManageSiteDSTest_admin' LIMIT 1];
        return userObj;
    }
    
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [SELECT Id, Name, Chatter_Group_Id__c, Landing_Page__c,Site_Category__c,External_Apps_Site_Config_Json__c
        								FROM Simpplr_Site__c WHERE Name='ManageSiteDSTest_Grp1' LIMIT 1];
        return siteObj;
    }
    
    
    @isTest 
    static void testHandleRequestWhenActionNull() {
        Test.startTest();
    	init();
     	ManageSiteDataServer serverObj = new ManageSiteDataServer();
        PageReference pageRef = Page.DataServerRW;
        
        serverObj.getPageFeature();
        
        pageRef.getParameters().put('target','ManageSiteDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','makeManager');
        serverObj.handleRequest();

        pageRef.getParameters().put('action','makeContentManager');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','makeOwner');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','makeMember');
        serverObj.handleRequest();

        pageRef.getParameters().put('action','makeFollower');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','removeMember');
        serverObj.handleRequest();

        pageRef.getParameters().put('action','removePeople');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','addMember');
        serverObj.handleRequest();

        pageRef.getParameters().put('action','addPeople');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','saveSiteDetail');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','createFileRecord');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','saveSiteDashboardConfig');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','saveSiteExternalAppsConfig');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','disconnectApp');
        serverObj.handleRequest();

        pageRef.getParameters().put('action','getExternalAppsSettings');
        serverObj.handleRequest();
        
        
        system.assertEquals('error', serverObj.response.status, 'HandleRequest executed successfully');
        Test.stopTest();
    } 
    
    @isTest 
    static void testHandleRequestWhenActionNotNull() {
        Test.startTest();
        init();
        Simpplr_Site__c  siteObj = getSite();
     	ManageSiteDataServer serverObj = new ManageSiteDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','ManageSiteDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','addMemberToManagerGroup');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','makeOwner');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','removeMemberFromManagerGroup');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','removeMember');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','addMember');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','addPeople');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','saveSiteDetail');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','createFileRecord');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','saveSiteDashboardConfig');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','saveSiteExternalAppsConfig');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        pageRef.getParameters().put('action','disconnectApp');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
		System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    } 

    @isTest 
    static void testSaveSiteExternalAppsConfig() {
    	init();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getStandardUser();
        Simpplr_Site__c  siteObj = getSite();
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE,appIntegList[0].id);

        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'saveSiteExternalAppsConfig');
		pgRef.getParameters().put('data', '{"siteId":"'+siteObj.Id+'","channelUrl":"https://slack.com/api/conversations.info","teamsWebhookUrl":"https://outlook.office.com/sss","slackAccessToken":"xoxp-2398475486","slackSendFeed":"only-posts","channelId":"GTLQRSEJ0","channelName":"team"}');
    	Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/slackDataServer/channels.list',false));
		serverObj.handleRequest();
        
        SimpplrContext.microsoftTeamsIntegrationEnabled = true;
       	SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 = true;
        SimpplrContext.isSlackPhase2FeatureEnabled = true;
        SimpplrContext.isSlackUpgraded = true;
        pgRef.getParameters().put('data', '{"siteId":"'+siteObj.Id+'","slackSendFeed":"only-posts","teamsWebhookUrl":"https://outlook.office.com/sss","teamsSendFeed":"only-posts","externalAppsSiteConfig": {  "slackSiteConfig" : {    "slackWebUrl" : "https://slack.com/archives/C03U55K5UFQ",    "slackSiteFeedOptions" : [ "slackPostAndReplies", "slackTimeline" ],    "slackConnectedUserId" : "U046FGQSJMT",    "slackConnectedAs" : "tanviladkani2",    "slackChannelName" : "general",    "slackChannelId" : "C03U55K5UFQ"  },  "msTeamsSiteConfig" : {    "webUrl" : "https://teams.microsoft.com/l/channel/19%3A18774be2d0b6452cacaa9b679b3e49cc%40thread.tacv2/People%20of%20Simpplr?groupId=4841a72f-9ab7-4e9d-b65f-124cf5e51d1a&tenantId=3c0a0034-da1f-479d-a860-082149bd9a54&allowXTenantAccess=False",    "msTeamsTeamName" : "Simpplr Inc",    "msTeamsTeamId" : "4841a72f-9ab7-4e9d-b65f-124cf5e51d1a",    "msTeamsSiteFeedOptions" : [ "msTeamsPosts", "msTeamsReplies", "msTeamsTimeline" ],    "msTeamsConnectedUserId" : "f94e5a8b-a77d-4ac0-b998-9d13133582be",    "msTeamsChannelName" : "People of Simpplr",    "msTeamsChannelId" : "19:18774be2d0b6452cacaa9b679b3e49cc@thread.tacv2",    "microsoftTeamsConnectedAs" : "Frank Hobert - frank.hobert@simpplr.net"  }}}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }

    @isTest 
    static void testTeamsTransferAccount() {
    	init();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getStandardUser();
        Simpplr_Site__c  siteObj = getSite();
        siteObj.External_Apps_Site_Config_Json__c = '{  "slackSiteConfig" : {    "slackWebUrl" : "https://slack.com/archives/C03U55K5UFQ",    "slackSiteFeedOptions" : [ "slackPostAndReplies", "slackTimeline" ],    "slackConnectedUserId" : "U046FGQSJMT",    "slackConnectedAs" : "tanviladkani2",    "slackChannelName" : "general",    "slackChannelId" : "C03U55K5UFQ"  },  "msTeamsSiteConfig" : {    "webUrl" : "https://teams.microsoft.com/l/channel/19%3A18774be2d0b6452cacaa9b679b3e49cc%40thread.tacv2/People%20of%20Simpplr?groupId=4841a72f-9ab7-4e9d-b65f-124cf5e51d1a&tenantId=3c0a0034-da1f-479d-a860-082149bd9a54&allowXTenantAccess=False",    "msTeamsTeamName" : "Simpplr Inc",    "msTeamsTeamId" : "4841a72f-9ab7-4e9d-b65f-124cf5e51d1a",    "msTeamsSiteFeedOptions" : [ "msTeamsPosts", "msTeamsReplies", "msTeamsTimeline" ],    "msTeamsConnectedUserId" : "f94e5a8b-a77d-4ac0-b998-9d13133582be",    "msTeamsChannelName" : "People of Simpplr",    "msTeamsChannelId" : "19:18774be2d0b6452cacaa9b679b3e49cc@thread.tacv2",    "microsoftTeamsConnectedAs" : "Frank Hobert - frank.hobert@simpplr.net"  }}';
        update siteObj;
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS});
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS,appIntegList[0].id);
		PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'transferAccount');
        pgRef.getParameters().put('data', '{"siteId":"'+siteObj.Id+'","name":"microsoftteams"}');
    	Test.setCurrentPage(pgRef);
        Test.startTest();
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest 
    static void testSlackTransferAccount() {
    	init();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getStandardUser();
        Simpplr_Site__c  siteObj = getSite();
        siteObj.External_Apps_Site_Config_Json__c = '{  "slackSiteConfig" : {    "slackWebUrl" : "https://slack.com/archives/C03U55K5UFQ",    "slackSiteFeedOptions" : [ "slackPostAndReplies", "slackTimeline" ],    "slackConnectedUserId" : "U046FGQSJMT",    "slackConnectedAs" : "tanviladkani2",    "slackChannelName" : "general",    "slackChannelId" : "C03U55K5UFQ"  },  "msTeamsSiteConfig" : {    "webUrl" : "https://teams.microsoft.com/l/channel/19%3A18774be2d0b6452cacaa9b679b3e49cc%40thread.tacv2/People%20of%20Simpplr?groupId=4841a72f-9ab7-4e9d-b65f-124cf5e51d1a&tenantId=3c0a0034-da1f-479d-a860-082149bd9a54&allowXTenantAccess=False",    "msTeamsTeamName" : "Simpplr Inc",    "msTeamsTeamId" : "4841a72f-9ab7-4e9d-b65f-124cf5e51d1a",    "msTeamsSiteFeedOptions" : [ "msTeamsPosts", "msTeamsReplies", "msTeamsTimeline" ],    "msTeamsConnectedUserId" : "f94e5a8b-a77d-4ac0-b998-9d13133582be",    "msTeamsChannelName" : "People of Simpplr",    "msTeamsChannelId" : "19:18774be2d0b6452cacaa9b679b3e49cc@thread.tacv2",    "microsoftTeamsConnectedAs" : "Frank Hobert - frank.hobert@simpplr.net"  }}';
        update siteObj;
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        TestHelper.createPeopleIntegRecordForUser(UserContext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK,appIntegList[0].id);
		PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'transferAccount');
        pgRef.getParameters().put('data', '{"siteId":"'+siteObj.Id+'","name":"slack"}');
    	Test.setCurrentPage(pgRef);
        Test.startTest();
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest 
    static void testAddMember() {
        init();
        system.runAs(getAdminUser()){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));
            ManageSiteDataServer serverObj = new ManageSiteDataServer();
            List<User> userList = [SELECT Id FROM User WHERE LastName = 'ManageSiteDSTest_std' LIMIT 1];
            Simpplr_Site__c  siteObj = getSite();
            siteObj.File_Storage_Source__c ='googledrive';
            update siteObj;
            SimpplrContext.googleManagedPermission = false;
                
            PageReference pgRef = Page.DataServerRW;
            pgRef.getParameters().put('target','ManageSiteDataServer');
            pgRef.getParameters().put('action', 'addMember');
            pgRef.getParameters().put('siteId', siteObj.Id);
            pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserIds":["' + userList[0].Id + '"]}');
            Test.setCurrentPage(pgRef);
            
            serverObj.handleRequest();
            System.assertEquals('success',serverObj.response.status,serverObj.response.message);
            
            Test.stopTest();
        }
    }
    
    @isTest 
    static void testAddPeople() {
        init();
        
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = TestHelper.createUser('New_Simpplr_usr', null, false); 
        People__c pObj = [SELECT id FROM people__c WHERE  user__c = : userObj.id];
        Simpplr_Site__c  siteObj = getSite();
        siteObj.File_Storage_Source__c ='intranet';
        update siteObj;
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'addPeople');
    	pgRef.getParameters().put('siteId', siteObj.Id);
    	pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","userDetail":[{"sfUserId":"'+ userObj.id +'","membershipType":"member"}]}');
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
    }

    @istest
    static void testMakeOwner(){
        init();
        
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = TestHelper.createUser('New_Simpplr_usr', null, false); 
        People__c pObj = [SELECT id FROM people__c WHERE  user__c = : userObj.id];
        Simpplr_Site__c  siteObj = getSite();
        TestHelper.createCollaborationGroupMember(siteObj.Chatter_Group_Id__c, userObj.id, 'Admin');
        Site_Role__c siteRoleObj = TestHelper.createSiteRole(pObj.Id, siteObj.Id, true, true); 
        List<Site_Role__c> siteRoleList = [SELECT id, Site__r.Chatter_Group_Id__C
                        				   FROM Site_Role__c 
                        				   WHERE People__r.User__c =: userObj.id AND Site__c = :siteObj.Id AND Is_Deleted__c = false ];
        
        List<collaborationGroup> listOfCollbGrp = [SELECT id, ownerId, name FROM collaborationGroup WHERE id =:siteRoleList[0].Site__r.Chatter_Group_Id__C];
        collaborationGroup CollbGrpObj = listOfCollbGrp[0];
        CollbGrpObj.ownerId = userObj.id;
        update CollbGrpObj;
        siteObj.File_Storage_Source__c ='googledrive';
        update siteObj;
        SiteContext.fileStorageSource = 'googledrive';
        SimpplrContext.googleManagedPermission = false;

        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'makeOwner');
    	pgRef.getParameters().put('siteId', siteObj.Id);
    	pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"'+ userObj.id +'","permission":"owner","provider":""}');
    	Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new EFSHTTPMock('googledrive'));
        serverObj.handleRequest(); 
        
        SimpplrContext.googleManagedPermission = true;
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        System.assertEquals('success',serverObj.response.status,serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest 
    static void testRemovePeople() {
        init();
        Test.startTest();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getStandardUser();
        Simpplr_Site__c  siteObj = getSite();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'removePeople');
    	pgRef.getParameters().put('siteId', siteObj.Id);
    	pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '"}');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        
        System.assertEquals('success',serverObj.response.status,serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest 
    static void removeMandatorySubscriptionPeople() {
        init();
        User userObj = getStandardUser();
        Simpplr_Site__c  siteObj = getSite();
        People__c peopleObj = getStandardPeople();
        TestHelper.createSiteRole(peopleObj.Id, siteObj.Id, false, true);
        Audience__c audienceObj = TestHelper.createAudience(null);
        TestHelper.createAudienceMember(audienceObj.Id, peopleObj.Id);
        Subscription__c subscriptionObj = TestHelper.createSiteSubscriptionByActionType(audienceObj.Id, siteObj.Id, 'Site', 'mandatory');
        TestHelper.createSiteSubscriptionEntityByStatus(subscriptionObj.Id, siteObj.Id, 'approved');        
        
        Test.startTest();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'removePeople');
    	pgRef.getParameters().put('siteId', siteObj.Id);
    	pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","userIds":["' + userObj.Id + '"]}');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        Test.stopTest();
        System.assertEquals('error', serverObj.response.status, 'Result should have been error');
    }

    @isTest 
    static void test_setPeoplePermission() {
        init();
        Test.startTest();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getStandardUser();
        Simpplr_Site__c  siteObj = getSite();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'setPeoplePermission');
    	pgRef.getParameters().put('siteId', siteObj.Id);
        Test.setCurrentPage(pgRef);
        
    	pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '","permission":"member","provider":""}');
        serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '","permission":"follower","provider":""}');
        serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '","permission":"owner","provider":""}');
        serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '","permission":"manager","provider":""}');
        serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '","permission":"contentManager","provider":""}');
        serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '","permission":"removePeople","provider":""}');
        serverObj.handleRequest();
        
        Test.stopTest();
        System.assertEquals('success',serverObj.response.status,serverObj.response.message);
    }
    
    @isTest static void testMakeContentManager() {
        Test.startTest();
        
        User userObj = getStandardUser();
        Simpplr_Site__c  siteObj = getSite();
        People__c peopleObj = getStandardPeople();
        Testhelper.createSiteRole(peopleObj.Id,siteObj.Id, false, true);
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'makeContentManager');
        pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '"}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status,serverObj.response.message);
        
        pgRef.getParameters().put('data', '###');
        serverObj.handleRequest();
        System.assertEquals('error', serverObj.response.status,'Data not correct');
        Test.stopTest();
    }
    
    @isTest
    static void testMakeManager() {
        Test.startTest();
    	init();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = [SELECT id FROM User WHERE lastName =:'ManageSiteDSTest_usr2'];
        Simpplr_Site__c  siteObj = getSite();
        SiteContext.fileStorageSource = 'googledrive';
        SimpplrContext.googleManagedPermission = false;
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'makeManager');
    	pgRef.getParameters().put('siteId', siteObj.Id);
    	pgRef.getParameters().put('data', '{"siteId":"'+siteObj.Id+'", "sfUserId":"' + userObj.id + '"}');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest 
    static void testMakeMember() {
        Test.startTest();
    	init();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = [SELECT Id FROM User WHERE LastName = 'ManageSiteDSTest_usr2' LIMIT 1];
        Simpplr_Site__c  siteObj = getSite();
        siteObj.File_Storage_Source__c = 'intranet';
        update siteObj;
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'makeMember');
    	pgRef.getParameters().put('siteId', siteObj.Id);
    	pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '", "permission":"Member"}');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status,serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest 
    static void testRemoveMember() {
        Test.startTest();
    	init();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getStandardUser();
        Simpplr_Site__c  siteObj = getSite();
        siteObj.File_Storage_Source__c = 'googledrive';
        update siteObj;
        SimpplrContext.googleManagedPermission = false;
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'removeMember');
    	pgRef.getParameters().put('siteId', siteObj.Id);
    	pgRef.getParameters().put('data', '{"siteId":"' + siteObj.Id + '","sfUserId":"' + userObj.Id + '"}');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('success',serverObj.response.status,serverObj.response.message);
    	Test.stopTest();
    }
    
    @isTest 
    static void testSaveSiteDetailGoogleDrive() {
    	init();
      	ManageSiteDataServer serverObj = new ManageSiteDataServer();
        Simpplr_Site__c  siteObj = getSite();
        Simpplr_Site__c  privatesite = [SELECT Id FROM Simpplr_Site__c WHERE Name='ManageSiteDSTestPrivateGrp' LIMIT 1];
        people__c pObj = [SELECT id FROM people__c WHERE user__c =:UserInfo.getUserId()];
        TestHelper.createSiteRole(pObj.id, privatesite.Id, true, true);

        Test.startTest();

        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('action', 'saveSiteDetail');
        pgRef.getParameters().put('siteId', siteObj.Id);
        siteObj.File_Storage_Source__c = 'googledrive';
        update siteObj;
        SimpplrContext.googleManagedPermission = true;
        pgRef.getParameters().put('data', '{"siteImageThumbnail":null,"name":"' + siteObj.Name + '","siteId":"' + siteObj.Id + '","description":"Test Description.","category":{"id":null,"name":"dummycategory"},"siteCategory":"","access":"Public","titleImage":[{"url":null,"titleImageType":"thumbnail","title":null,"source":null,"size":null,"id":null,"fileType":null,"downloadUrl":"https://c.na34.content.force.com/profilephoto/72961000000F6cb/T","contentVersionId":null,"contentDocumentId":null}],"titleImageCaption":null,"deletedTitleImage":[],"storageProvider":"dropbox","dropboxRootPermission":"readwrite","landingPage":"NoDashboard","isBroadcast":false,"isContentSubmissionsEnabled":true,"isContentFeedEnabled":true,"hasAlbums":true,"hasEvents":true,"hasPages":true,"isQuestionAnswerEnabled":true,"isContentUnfurlEnabled":false}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        Simpplr_Site__c  privatesiteObj = [SELECT Id, Name, Chatter_Group_Id__c, Landing_Page__c,Site_Category__c
        								FROM Simpplr_Site__c WHERE Name='ManageSiteDSTestPrivateGrp' LIMIT 1];
        privatesiteObj.File_Storage_Source__c = 'googledrive';
        update privatesiteObj;
        
        pgRef.getParameters().put('data', '{"siteImageThumbnail":null,"name":"' + privatesiteObj.Name + '","siteId":"' + privatesiteObj.Id + '","description":"Test Description.","category":{"id":null,"name":"dummycategory"},"siteCategory":"","access":"Public","titleImage":[{"url":null,"titleImageType":"thumbnail","title":null,"source":null,"size":null,"id":null,"fileType":null,"downloadUrl":"https://c.na34.content.force.com/profilephoto/72961000000F6cb/T","contentVersionId":null,"contentDocumentId":null}],"titleImageCaption":null,"deletedTitleImage":[],"storageProvider":"dropbox","dropboxRootPermission":"readwrite","landingPage":"NoDashboard","isBroadcast":false,"isContentSubmissionsEnabled":true,"isContentFeedEnabled":true,"hasAlbums":true,"hasEvents":true,"hasPages":true,"isQuestionAnswerEnabled":true,"isContentUnfurlEnabled":false}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        Test.stopTest();

        System.assertEquals('success',serverObj.response.status,serverObj.response.message);
    }
    
    @isTest
    static void testUndefinedAction() {
        Test.startTest();
    	init();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'undefinedAction');
    	pgRef.getParameters().put('data', '{}');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('error',serverObj.response.status,serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest
    static void testAddMemberToManagerGroup() {
        Test.startTest();
    	init();
    	ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getStandardUser();
        Simpplr_Site__c siteObj = getSite();
        String siteId = siteObj.id;
        String catId = siteObj.Site_Category__c;
        
        Test.setCurrentPageReference(new PageReference('Page.ManageSiteDataServer')); 
        System.currentPageReference().getParameters().put('siteId', siteId);
                
        String contentDocumentId ='';
        String pathOnClient = 'A0F29C47EA374DF79BDB3A280F1B7D5C#' + siteObj.Id + '#' + 'dummyFolderId' + '#' + 'dummyfile.png';
		ContentVersion cvObj = TestHelper.createContentVersion('nvcjdnvjfnvjnfdkjvnfHVGVGDXnkjckjdnvjndn6347hcbchdbc', pathOnClient);
		List<ContentDocument> ContentDocumentList = [SELECT Id, Title, ContentSize, FileType FROM ContentDocument WHERE latestpublishedversionId=:cvObj.id];
        
        serverObj.createFileRecord(cvObj.id, ContentDocumentList[0]);  
        List<File__c> fileList = [SELECT Content_Document__c FROM File__c WHERE Content_Version__c =:cvObj.id];
        System.assertEquals(fileList[0].Content_Document__c, ContentDocumentList[0].id, 'File record not created');
        Test.stopTest();
    } 
    
    @isTest
    static void removeMemberFromSiteRoleTest() {
        //Arrange
        init();
        User userObj = [SELECT id FROM User WHERE lastName =:'ManageSiteDSTest_usr2'];
        people__c pObj = [SELECT id FROM people__c WHERE user__c =:userObj.id];
        Simpplr_Site__c siteObj = getSite();
        String siteId = siteObj.id;
        String userId = userObj.id;
        Site_Role__c roleObj = new Site_Role__c();
        roleObj.People__c = pObj.id;
        roleObj.Site__c = siteId;
        roleObj.Is_Deleted__c = false;
        roleObj.Is_Member__c = true;
        insert roleObj;
        Boolean expected = false;
        ManageSiteDataServer manageSiteDataServerObj = new ManageSiteDataServer();
        //Act
        Test.startTest();
        manageSiteDataServerObj.removeMemberFromSiteRole(siteId, userId);    
        Test.stopTest();  
        //Assert
        Site_Role__c [] siteRoles = [SELECT id,
                                            Is_Member__c,
                                            Is_Deleted__c
                                    FROM Site_Role__c 
                                    WHERE Site__c =: siteId AND
                                        People__r.User__c =: userId];
                                        
        for(Site_Role__c siteRole  :siteRoles){
            System.assertEquals(expected , siteRole.Is_Member__c, 'removeMemberFromSiteRole failed expected false for is member flag');
        }
        expected = true;
        for(Site_Role__c siteRole  :siteRoles){
            System.assertEquals(expected , siteRole.Is_Deleted__c, 'removeMemberFromSiteRole failed expected true for is deleted flag');
        }
    }
    
    @isTest
    static void getSiteRoleBySiteIdUserIdTest(){
        //Arrange
        init();
        User userObj = [SELECT id FROM User WHERE lastName =:'ManageSiteDSTest_usr2'];
        people__c pObj = [SELECT id FROM people__c WHERE user__c =:userObj.id];
        Simpplr_Site__c siteObj = getSite();
        String siteId = siteObj.id;
        String userId = userObj.id;
        Site_Role__c roleObj = new Site_Role__c();
        roleObj.People__c = pObj.id;
        roleObj.Site__c = siteId;
        roleObj.Is_Deleted__c = false;
        roleObj.Is_Member__c = true;
        insert roleObj;
        ManageSiteDataServer manageSiteDataServerObj = new ManageSiteDataServer();
        Site_Role__c [] siteRoles;
        integer expected = 1;
        //Act
        Test.startTest();
        siteRoles = manageSiteDataServerObj.getSiteRoleBySiteIdUserId(siteId, userId);    
        Test.stopTest();  
        //Assert
        System.assertEquals(expected, siteRoles.size(), 'getSiteRoleBySiteIdUserId for correct input failed');

    }

    @isTest
    static void getSiteRoleBySiteIdUserIdBlank() {
        //Arrange
        String siteId ='';
        String userId ='';
        Site_Role__c[] siteRoles ;
        ManageSiteDataServer manageSiteDataServerObj = new ManageSiteDataServer();
        //Act
        Test.startTest();
        siteRoles = manageSiteDataServerObj.getSiteRoleBySiteIdUserId(siteId, userId);
        Test.stopTest();
        //Assert
        System.assertEquals(null, siteRoles, 'getSiteRoleBySiteIdUserId for blank input failed');
    }
    @isTest
    static void getSiteRoleBySiteIdUserIdNull() {
        //Arrange
        String siteId =null;
        String userId =null;
        Site_Role__c[] siteRoles ; 
        ManageSiteDataServer manageSiteDataServerObj = new ManageSiteDataServer();
        //Act
        Test.startTest();
        siteRoles = manageSiteDataServerObj.getSiteRoleBySiteIdUserId(siteId, userId);
        Test.stopTest();
        //Assert
        System.assertEquals(null, siteRoles, 'getSiteRoleBySiteIdUserId for null input failed.');
    }

    @isTest
    static void testMakeFollower() {
        Test.startTest();
        init();
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = [SELECT Id FROM User WHERE LastName = 'ManageSiteDSTest_usr2' LIMIT 1];
        Simpplr_Site__c  siteObj = getSite();
        siteObj.File_Storage_Source__c = 'intranet';
        update siteObj;
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'makeFollower');
    	pgRef.getParameters().put('siteId', siteObj.Id);
    	pgRef.getParameters().put('data', '{"siteId":"'+siteObj.Id+'", "sfUserId":"' + userObj.id + '"}');
    	Test.setCurrentPage(pgRef);
    	
        serverObj.handleRequest();
        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
        Test.stopTest();
    }
   
	@isTest
    static void testGetExternalAppsSettings() {
        Test.startTest();
        init();
        SimpplrContext.microsoftTeamsIntegrationEnabled = true;
        SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 = true;
        ManageSiteDataServer serverObj = new ManageSiteDataServer();
        Simpplr_Site__c  siteObj = getSite();
        PageReference pgRef = Page.DataServerRW;
        SimpplrContext.slackIntegrationEnabled = true;
        SimpplrContext.isSlackUpgraded = true;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action','getExternalAppsSettings');
        pgRef.getParameters().put('siteId',siteObj.Id);
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status,serverObj.response.message);
        Test.stopTest();
    }
    
    @isTest 
    static void testSaveSiteDetailSharepoint() {
        
    	init();
       	ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getAdminUser();
        Simpplr_Site__c  siteObj = getSite();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'saveSiteDetail');
    	pgRef.getParameters().put('siteId', siteObj.Id);
		siteObj.File_Storage_Source__c = 'sharepoint';
        update siteObj;
        pgRef.getParameters().put('data', '{"siteImageThumbnail":null,"name":"' + siteObj.Name + '","siteId":"' + siteObj.Id + '","description":"Test Description.","category":{"id":null,"name":"dummycategory"},"siteCategory":"","access":"Public","titleImage":[{"url":null,"titleImageType":"thumbnail","title":null,"source":null,"size":null,"id":null,"fileType":null,"downloadUrl":"https://c.na34.content.force.com/profilephoto/72961000000F6cb/T","contentVersionId":null,"contentDocumentId":null}],"titleImageCaption":null,"deletedTitleImage":[],"storageProvider":"dropbox","dropboxRootPermission":"readwrite","landingPage":"NoDashboard","isBroadcast":false,"isContentSubmissionsEnabled":true,"isContentFeedEnabled":true,"hasAlbums":true,"hasEvents":true,"hasPages":true,"isQuestionAnswerEnabled":true, "isContentUnfurlEnabled":false}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'sp/removelinkeditem',false));
        serverObj.handleRequest();
        Test.stopTest();

        System.assertEquals('success',serverObj.response.status,serverObj.response.message);
    }

    @isTest
    static void testSaveSiteDetailOneDrive() {
        
    	init();
       	ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getAdminUser();
        Simpplr_Site__c  siteObj = getSite();
        PageReference pgRef = Page.DataServerRW;
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'saveSiteDetail');
    	pgRef.getParameters().put('siteId', siteObj.Id);
		siteObj.File_Storage_Source__c = 'onedrive';
        update siteObj;
        pgRef.getParameters().put('data', '{"siteImageThumbnail":null,"name":"' + siteObj.Name + '","siteId":"' + siteObj.Id + '","description":"Test Description.","category":{"id":null,"name":"dummycategory"},"siteCategory":"","access":"Public","titleImage":[{"url":null,"titleImageType":"thumbnail","title":null,"source":null,"size":null,"id":null,"fileType":null,"downloadUrl":"https://c.na34.content.force.com/profilephoto/72961000000F6cb/T","contentVersionId":null,"contentDocumentId":null}],"titleImageCaption":null,"deletedTitleImage":[],"storageProvider":"dropbox","dropboxRootPermission":"readwrite","landingPage":"NoDashboard","isBroadcast":false,"isContentSubmissionsEnabled":true,"isContentFeedEnabled":true,"hasAlbums":true,"hasEvents":true,"hasPages":true,"isQuestionAnswerEnabled":true,"isContentUnfurlEnabled":false}');
        Test.setCurrentPage(pgRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'sp/removelinkeditem',false));
        serverObj.handleRequest();
        Test.stopTest();

        System.assertEquals('success', serverObj.response.status, serverObj.response.message);
    }
    
    @isTest 
    static void testSaveSiteDetailDropBox() {
        Test.startTest();
    	init();
      	ManageSiteDataServer serverObj = new ManageSiteDataServer();
        User userObj = getAdminUser();
        Simpplr_Site__c  siteObj = getSite();
        siteObj.File_Storage_Source__c = 'dropbox';
        update siteObj;
        PageReference pgRef = Page.DataServerRW;
        SimpplrContext.IsBoxIntegrationEnabled = true;
        SimpplrContext.BoxUsername = 'dummy';
    	pgRef.getParameters().put('target','ManageSiteDataServer');
        pgRef.getParameters().put('action', 'saveSiteDetail');
    	pgRef.getParameters().put('siteId', siteObj.Id);
        pgRef.getParameters().put('data', '{"access":"Public","siteImageThumbnail":null,"name":"' + siteObj.Name + '","siteId":"' + siteObj.Id + '","description":"Test Description.","category":{"id":null,"name":"dummycategory"},"siteCategory":"","siteAccess":"Public","titleImage":[{"url":null,"titleImageType":"thumbnail","title":null,"source":null,"size":null,"id":null,"fileType":null,"downloadUrl":"https://c.na34.content.force.com/profilephoto/72961000000F6cb/T","contentVersionId":null,"contentDocumentId":null}],"titleImageCaption":null,"deletedTitleImage":[],"storageProvider":"box","dropboxRootPermission":null,"landingPage":"NoDashboard","isBroadcast":false,"isContentSubmissionsEnabled":true,"isContentFeedEnabled":true,"hasAlbums":true,"hasEvents":true,"hasPages":true,"isQuestionAnswerEnabled":true,"isContentUnfurlEnabled":false}');
    	Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        
        pgRef.getParameters().put('data', '{"access":"Public","siteImageThumbnail":null,"name":"' + siteObj.Name + '","siteId":"' + siteObj.Id + '","description":"Test Description.","category":{"id":null,"name":"dummycategory"},"siteCategory":"","siteAccess":"Public","titleImage":[{"url":null,"titleImageType":"thumbnail","title":null,"source":null,"size":null,"id":null,"fileType":null,"downloadUrl":"https://c.na34.content.force.com/profilephoto/72961000000F6cb/T","contentVersionId":null,"contentDocumentId":null}],"titleImageCaption":null,"deletedTitleImage":[],"storageProvider":"dropbox","dropboxRootPermission":"readwrite","landingPage":"NoDashboard","isBroadcast":false,"isContentSubmissionsEnabled":true,"isContentFeedEnabled":true,"hasAlbums":true,"hasEvents":true,"hasPages":true,"isQuestionAnswerEnabled":true,"isContentUnfurlEnabled":false}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        SimpplrContext.googleManagedPermission = true;
        pgRef.getParameters().put('data', '{"siteImageThumbnail":null,"name":"' + siteObj.Name + '","siteId":"' + siteObj.Id + '","description":"Test Description.","category":{"id":null,"name":"dummycategory"},"siteCategory":"","access":"Private","titleImage":[{"url":null,"titleImageType":"thumbnail","title":null,"source":null,"size":null,"id":null,"fileType":null,"downloadUrl":"https://c.na34.content.force.com/profilephoto/72961000000F6cb/T","contentVersionId":null,"contentDocumentId":null}],"titleImageCaption":null,"deletedTitleImage":[],"storageProvider":"googledrive","dropboxRootPermission":"readwrite","landingPage":"NoDashboard","isBroadcast":false,"isContentSubmissionsEnabled":true,"isContentFeedEnabled":true,"hasAlbums":true,"hasEvents":true,"hasPages":true,"isQuestionAnswerEnabled":true,"isContentUnfurlEnabled":false}');
        Test.setCurrentPage(pgRef);
        serverObj.handleRequest();
        Test.stopTest();

        System.assertEquals('success',serverObj.response.status,serverObj.response.message);
    }
    
        
}