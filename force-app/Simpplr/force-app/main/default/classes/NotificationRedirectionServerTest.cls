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
private class NotificationRedirectionServerTest {
	
	private static App_Config__c appConfigRecord;
	private static User siteOwnr;
	private static User siteMember;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent;
	private static Simpplr_Content__c simpplrContentForScore;
	private static Simpplr_Site__c site;
	private static ContentVersion contentVersionObj;
	private static PageReference pageRef;
	
    @testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();
		People__c peopleObj = TestHelper.createPeopleRecordForUser(UserContext.id);
		siteOwnr = TestHelper.createUser('RedirectionServer_siteOwnr', null, false);
		managerOfsiteMember = TestHelper.createUser('RedirectionServer_userMngr', null, false);
		siteMember = TestHelper.createUser('RedirectionServer_siteMmbr', managerOfsiteMember, false);
		cgroup = TestHelper.createCollaborationGroup('RedirectionServer_Grp1','Public');
		TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
		TestHelper.changeCollaborationGroupOwner(cgroup.id, siteOwnr.Id);
		TestHelper.createSimpplrNotification('NotificationRedirectionServerTest', peopleObj.id,null,'Like',peopleObj.id,null);
	}
    
    @isTest static void testInit() {
    	App_Notification__c notiObj = [select id from App_Notification__c WHERE Is_Deleted__c = false AND Guid__c='NotificationRedirectionServerTest' limit 1];

		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','NotificationRedirectionServer');
		pageRef.getParameters().put('mustRead','true');
		pageRef.getParameters().put('openUsefulHistory','true');
		pageRef.getParameters().put('feedCommenId','dummyId');
		pageRef.getParameters().put('notificationId',notiObj.id);
		pageRef.getParameters().put('type', 'page');
		pageRef.getParameters().put('campaignId', 'campaignId');

		Test.setCurrentPage(pageRef);
        NotificationRedirectionServer serverObj = new NotificationRedirectionServer();
		serverObj.init();
    
    	pageRef.getParameters().put('redirectPageName', 'siteLandingPage');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'newsletter');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'managesitesubscription');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'managesegmentsubscription');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'campaigns');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'SiteContent');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'ProfileBlogPost');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'HomeFeedSinglePost');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'homeDefault');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'ProfileAbout');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'AppManagerAnalytics');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'SiteAnalytics');
    	serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'ContentAnalytics');
    	serverObj.init();
		
		pageRef.getParameters().put('redirectPageName', 'manageContent');
		serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'onboarding');
		serverObj.init();

        System.assert(true,'Running as expected');
    }
    
	@isTest static void testInitForNotificationsPublicSiteRequest() {
		Simpplr_Site__c siteObj = [SELECT Id FROM Simpplr_Site__c WHERE Name = 'RedirectionServer_Grp1'];
    	App_Notification__c notiObj = [select id from App_Notification__c WHERE Is_Deleted__c = false AND Guid__c='NotificationRedirectionServerTest' limit 1];
		notiObj.Simpplr_Site__c = siteObj.Id;
		update notiObj;

		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','NotificationRedirectionServer');
		pageRef.getParameters().put('notificationId',notiObj.id);
		pageRef.getParameters().put('redirectPageName', 'NotificationsSiteMemberRequest');
		Test.setCurrentPage(pageRef);

        NotificationRedirectionServer serverObj = new NotificationRedirectionServer();

		Pagereference p = serverObj.init();
		System.assertEquals(true, p.getUrl() != null, 'Should return URL');
    }

	@isTest static void testInitForNotificationsPrivateSiteRequest() {
		TestHelper.createCollaborationGroup('RedirectionServer_GrpPrivate','Private');
		Simpplr_Site__c sitePrivateObj = [SELECT Id FROM Simpplr_Site__c WHERE Name = 'RedirectionServer_GrpPrivate'];
    	App_Notification__c notiObj = [select id from App_Notification__c WHERE Is_Deleted__c = false AND Guid__c='NotificationRedirectionServerTest' limit 1];
		notiObj.Simpplr_Site__c = sitePrivateObj.Id;
		update notiObj;

		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','NotificationRedirectionServer');
		pageRef.getParameters().put('notificationId',notiObj.id);
		pageRef.getParameters().put('redirectPageName', 'NotificationsPrivateSiteRequest');
		Test.setCurrentPage(pageRef);

        NotificationRedirectionServer serverObj = new NotificationRedirectionServer();

		Pagereference p = serverObj.init();
		System.assertEquals(true, p.getUrl() != null, 'Should return URL');
    }
	
	@isTest static void testInitForQuestionAnswerDetail() {
    	App_Notification__c notiObj = [select id from App_Notification__c WHERE Is_Deleted__c = false AND Guid__c='NotificationRedirectionServerTest' limit 1];

		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','NotificationRedirectionServer');
		pageRef.getParameters().put('mustRead','true');
		pageRef.getParameters().put('openUsefulHistory','true');
		pageRef.getParameters().put('feedCommenId','dummyId');
		pageRef.getParameters().put('notificationId',notiObj.id);
		pageRef.getParameters().put('type', 'page');
		pageRef.getParameters().put('campaignId', 'campaignId');

		Test.setCurrentPage(pageRef);
        NotificationRedirectionServer serverObj = new NotificationRedirectionServer();

		pageRef.getParameters().put('redirectPageName', 'QuestionDetail');
		serverObj.init();

		pageRef.getParameters().put('redirectPageName', 'AnswerDetail');
		serverObj.init();

        System.assert(true,'Running as expected');
    }

	@isTest static void testInitForSurveys() {
    	App_Notification__c notiObj = [select id from App_Notification__c WHERE Is_Deleted__c = false AND Guid__c='NotificationRedirectionServerTest' limit 1];

		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','NotificationRedirectionServer');
		pageRef.getParameters().put('notificationId',notiObj.id);
		pageRef.getParameters().put('objectId', 'objectId');

		Test.setCurrentPage(pageRef);
        NotificationRedirectionServer serverObj = new NotificationRedirectionServer();

		pageRef.getParameters().put('redirectPageName', 'survey');
		serverObj.init();
        
        pageRef.getParameters().put('subType', 'action_instance');
        
        pageRef.getParameters().put('redirectPageName', 'survey');
		serverObj.init();

        System.assert(true,'Running as expected');
    }

	@isTest static void testInitForRecognition() {
    	App_Notification__c notiObj = [select id from App_Notification__c WHERE Is_Deleted__c = false AND Guid__c='NotificationRedirectionServerTest' limit 1];

		pageRef = Page.DataServerRW;
		pageRef.getParameters().put('target','NotificationRedirectionServer');
		pageRef.getParameters().put('notificationId',notiObj.id);
		pageRef.getParameters().put('objectId', 'objectId');
		pageRef.getParameters().put('objectType', 'recognition');

		Test.setCurrentPage(pageRef);
        NotificationRedirectionServer serverObj = new NotificationRedirectionServer();

		pageRef.getParameters().put('redirectPageName', 'recognition_hub');
		serverObj.init();

        System.assert(true,'Running as expected');
    }
    
}