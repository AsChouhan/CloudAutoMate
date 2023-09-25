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
private class SlackDataServerTest {
	
	private static App_Config__c appConfigRecord;
	private static simpplr_content__c publishedContent;
    private static simpplr_content__c publishedEvent;
    private static simpplr_content__c publishedAlbum;
    private static simpplr_content__c publishedBlog;
    private static simpplr_content__c publishedEventAllDay;
	private static Simpplr_Site__c fullSiteRecord;
    private static File__c fileObj;
    private static People__c peopleObject ;
	private static User siteMember;
	 
    @testSetup static void setup() {
    	appConfigRecord = TestHelper.setupAppConfig();
        peopleObject = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
	    CollaborationGroup colabGroupObj= TestHelper.createCollaborationGroup('SlackDataServer_Grp1','Public');
        Simpplr_Site__c site = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
        fullSiteRecord = TestHelper.getSiteRecord(site.Chatter_Group_Id__c); 
        TestHelper.shareSitesToAllPeople(new List<String>{fullSiteRecord.Id});
        
        
        siteMember = TestHelper.createUser('AccessManagerTest_siteMmbr', null, false);
        
		publishedContent = TestHelper.createContent('simpplr test Page', 'Page', 'Approved', siteMember, fullSiteRecord);        
    	publishedEvent = TestHelper.createContent('simpplr test Event', 'Event', 'Approved', siteMember, fullSiteRecord); 
        publishedEvent.Event_Is_All_Day__c = false;
        update publishedEvent;       
        publishedEventAllDay = TestHelper.createContent('simpplr test EventAllDay', 'Event', 'Approved', siteMember, fullSiteRecord);         
        publishedAlbum = TestHelper.createContent('simpplr test Album', 'Album', 'Approved', siteMember, fullSiteRecord);
        publishedBlog = TestHelper.createContent('simpplr test Blog', 'BlogPost', 'Approved', siteMember, fullSiteRecord);
        publishedEventAllDay.Event_Is_All_Day__c = true;
        publishedEventAllDay.Event_Location__c = 'Delhi';
        update publishedEventAllDay;
        ContentVersion conVerObj = TestHelper.createContentVersion('conVer', 'File_01');
        fileObj  = TestHelper.createFileRecordForVideo(publishedContent.id,'https://www.youtube.com/watch?v=zWh3CShX_do');
        fileObj.Content_Version__c = conVerObj.id;
        update fileObj;
        TestHelper.createFileRecordForVideo(publishedAlbum.id,'https://www.youtube.com/watch?v=zWh3CShX_do');
        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE,appIntegList[0].id);
        System.assert(true,'Running as expected');
    }
    
    static void init() {
        publishedContent = [select id, site__c from simpplr_Content__c where title__c='simpplr test Page' limit 1];
        publishedEvent = [select id, site__c from simpplr_Content__c where title__c='simpplr test Event' limit 1];
        publishedAlbum = [select id, site__c from simpplr_Content__c where title__c='simpplr test Album' limit 1];
        publishedBlog = [select id from simpplr_Content__c where title__c='simpplr test Blog' limit 1];
        publishedEventAllDay = [select id, site__c from simpplr_Content__c where title__c='simpplr test EventAllDay' limit 1];
        fileObj = [Select id from File__c Where Simpplr_Content__c =:publishedContent.id limit 1];
        PageReference pgRef = Page.DataServerRW;
        pgRef.getParameters().put('target','SlackDataServer');
        Test.setCurrentPage(pgRef);
    }
    
    
    @isTest static void testHandleRequestWhenActionNull() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('error', slackDSObj.response.status, 'Running as expected');
    }
    
    @isTest static void testHandleRequestUnfurlContent() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        simpplr_content__c conObj = [select id, site__c from simpplr_content__c where type__c =: 'album'];
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','getSlackUnfurlInfo');
        pageRef.getParameters().put('setPeopleIntegSlackFlag','true');
        pageRef.getParameters().put('unfurlUrl',Url.getSalesforceBaseUrl().toExternalForm() + '/apex/app?u=/site/' + conObj.site__c + '/album/' + conObj.Id);
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

    }
        
    @isTest static void testHandleRequestUnfurlProfile() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','getSlackUnfurlInfo');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('unfurlUrl',Url.getSalesforceBaseUrl().toExternalForm() + '/apex/app?u=/people/' + getPeople(UserInfo.getUserId()).Id);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

    }

    @isTest static void testHandleRequestUnfurlGallery() {
    	init();    	
        Simpplr_Content__c conObj = [select id, site__c from simpplr_content__c where type__c =: 'album'];
        File__c albumFileObj = [Select id from File__c Where Simpplr_Content__c =:conObj.id limit 1];
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','getSlackUnfurlInfo');
        pageRef.getParameters().put('unfurlUrl', PageContext.getPageURL(Pages.app) + '?u=/site/' + conObj.site__c + '/album/' + conObj.Id + '/gallery/' + albumFileObj.Id);
        Test.setCurrentPage(pageRef);
        SlackDataServer slackDSObj= new SlackDataServer();
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status,'Running as expected');
        
    }

        
    @isTest static void testHandleRequestUnfurlSite() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','getSlackUnfurlInfo');
        pageRef.getParameters().put('unfurlUrl',Url.getSalesforceBaseUrl().toExternalForm() + '/apex/app?u=/site/' + getSite().Id);
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');
    }

    @isTest static void testHandleRequestSaveSlackInfoToPeopleInteg() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','saveSlackInfoToPeopleInteg');
        pageRef.getParameters().put('slackUserName','testuser');
        pageRef.getParameters().put('slackUserId','testuser@slack.test');
        pageRef.getParameters().put('teamId','slackdummyexternalid');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL,appIntegList[0].id);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');
        
    }

    @isTest static void testEnableSlackUnfurl() {
    	init();
        SimpplrContext.slackIntegrationEnabled = true;
        SimpplrContext.isSlackPhase2FeatureEnabled = true;
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','enableSlackUnfurl');
        pageRef.getParameters().put('appName','slackUnfurl');
        Test.setCurrentPage(pageRef);
        Test.StartTest();
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

        List<App_Integration__c>  appIntegList = TestHelper.createAppIntegrationRecords(true, new Set<String>{IntegrationConstants.INTEGRATION_TYPE_SLACK});
        People_integration__c unfurlInte = TestHelper.createPeopleIntegRecordForUser(UserCOntext.peopleId,IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL,appIntegList[0].id);
        unfurlInte.Connected__c = false;
        update unfurlInte;
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');
        Test.StopTest();
    }

    @isTest static void testHandleRequestUninstall() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','uninstall');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

    }

    @isTest static void testHandleRequestFollowUser() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','followUser');
        pageRef.getParameters().put('peopleId',getPeople(UserInfo.getUserId()).Id);
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('error', slackDSObj.response.status, 'Running as expected');
    }

    @isTest static void testHandleRequestFollowSite() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','followSite');
        pageRef.getParameters().put('peopleId',getSite().id+'');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('error', slackDSObj.response.status, 'Running as expected');

    }

    @isTest static void testHandleRequestRequestSiteAccess() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','requestSiteAccess');
        pageRef.getParameters().put('peopleId',getSite().id+'');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('error', slackDSObj.response.status, 'Running as expected');

    }

    @isTest static void testHandleRequestGetAvailableChannels() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','getAvailableChannels');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('error', slackDSObj.response.status, 'Running as expected');

    }

    @isTest static void testHandleRequestShareContentPage() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        slackDSObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/success', false));
        SimpplrContext.isSlackPhase2FeatureEnabled = true;
        SimpplrContext.isSlackUpgraded = true;
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','shareContent');
        String contentId = publishedContent.id;
        String message = 'hello';
        String channelId = 'testChannel';
        String contentUrl = '';
        pageRef.getParameters().put('data','{"contentId":"'+contentId+'","message":"'+message+'","channelId":"'+channelId+'","channelList":["test1","test2"]}');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');
    }

    @isTest static void testHandleRequestShareContentAlbum() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        slackDSObj.getPageFeature();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, '/slackDataServer/chat.postMessage', false));
        SimpplrContext.isSlackPhase2FeatureEnabled = false;
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','shareContent');
        String contentId = publishedAlbum.id;
        String message = 'hello';
        String channelId = 'testChannel';
        String contentUrl = '';
        pageRef.getParameters().put('data','{"contentId":"'+contentId+'","message":"'+message+'","channelId":"'+channelId+'","contentUrl":"'+contentUrl+'"}');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

    }

     @isTest static void testHandleRequestShareContentEvent() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        SimpplrContext.isSlackPhase2FeatureEnabled = false;
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','shareContent');
        String contentId = publishedEvent.id;
        String message = 'hello';
        String channelId = 'testChannel';
        String contentUrl = '';
        pageRef.getParameters().put('data','{"contentId":"'+contentId+'","message":"'+message+'","channelId":"'+channelId+'","contentUrl":"'+contentUrl+'"}');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

        contentId = publishedBlog.id;
        pageRef.getParameters().put('data','{"contentId":"'+contentId+'","message":"'+message+'","channelId":"'+channelId+'","contentUrl":"'+contentUrl+'"}');
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

    }

    @isTest static void testHandleRequestShareContentEventAllDay() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        SimpplrContext.isSlackPhase2FeatureEnabled = false;
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','shareContent');
        String contentId = publishedEventAllDay.id;
        String message = 'hello';
        String channelId = 'testChannel';
        String contentUrl = '';
        pageRef.getParameters().put('data','{"contentId":"'+contentId+'","message":"'+message+'","channelId":"'+channelId+'","contentUrl":"'+contentUrl+'"}');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status,'Running as expected');
    }

    @isTest static void testHandleRequestLikeContent() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        String contentId = publishedContent.id;
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','like');
        pageRef.getParameters().put('recordId',contentId);
        pageRef.getParameters().put('likeType','content');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

    }

    @isTest static void testHandleRequestLikeMedia() {
    	init();
    	SlackDataServer slackDSObj= new SlackDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','SlackDataServer');
        pageRef.getParameters().put('action','like');
        pageRef.getParameters().put('recordId',fileObj.Id);
        pageRef.getParameters().put('likeType','media');
        Test.setCurrentPage(pageRef);
        slackDSObj.handleRequest();
        System.assertEquals('success', slackDSObj.response.status, 'Running as expected');

    }
    
    private static People__c getPeople(String userId){
        People__c  peopleObj = [Select Id, Title__c, Street__c, State__c, Phone__c, Full_Name__c, User__c,user__r.name, Mobile_Phone__c, Manager__c, 
        							Last_Name__c, First_Name__c, Fax__c, Extension__c, Email__c, Department__c, Country__c, City__c 
									From People__c where User__c = :userId LIMIT 1];
        return peopleObj;
    }
    private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [Select Id From Simpplr_Site__c LIMIT 1];
        return siteObj;
    }        
}