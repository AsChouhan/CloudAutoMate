@isTest
private class NewsletterV2DataServerTest {
    private static App_Config__c appConfigRecord;
	private static User systemAdmin;
	private static User siteOwnr;
	private static User siteMember;
	private static User managerOfsiteMember;
	private static CollaborationGroup cgroup;
	private static Simpplr_Content__c simpplrContent; 
    private static Simpplr_Site__c site;
    private static People__c peopleObj; 
    private static Pages_Category__c pageCategory;
    private static simpplr_content__c albumContent;
    private static simpplr_content__c content;
    private static simpplr_content__c publishedContent;
    private static Audience__c audienceRec;
    private static Segment__c segmentRec;
    
	@testSetup 
	private static void setup() {
		appConfigRecord = TestHelper.setupAppConfig();		
		systemAdmin = TestHelper.createUser('NewsletterV2DataServerTest_admin', null, true);
        siteOwnr = TestHelper.createUser('NewsletterV2DataServer_siteOwnr', null, false);
        peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        segmentRec = TestHelper.createSegment(peopleObj.Id);
        audienceRec = TestHelper.createAudience(segmentRec.Id);

        CollaborationGroup colabGroupObj= TestHelper.createCollaborationGroup('NewsletterV2DataServerTest_Grp1','Private');
        site = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
        if(pageCategory == null){
        	pageCategory = new Pages_Category__c(Name__c='Test Page Category',Site__c =site.id,Order__c =0,Is_Deleted__c = false);
        	insert pageCategory;
        }
        
        Simpplr_Site__c  fullSiteRecord = TestHelper.getSiteRecord(site.Chatter_Group_Id__c);        
        TestHelper.shareSitesToAllPeople(new List<String>{fullSiteRecord.Id});
        Topic topicObj = TestHelper.createTopic('NewsletterV2DataServerTestTopic');
        albumContent = TestHelper.createContent('NewsletterV2DataServerTest_testAlbumRecord', 'Album', 'Approved', systemAdmin, fullSiteRecord);
        TestHelper.createContentTitleImage(albumContent.Id);
        List<Simpplr_Content__c> pendingContentList = new List<Simpplr_Content__c>();		
		content = new Simpplr_Content__c(
							Title__c='NewsletterV2DataServerTest_testArticleRecord', 
								Text_Intro__c='NewsletterV2DataServerTest Example text', 
								Text_Main__c='NewsletterV2DataServerTest Example text',
								Text_Main_Continued__c='NewsletterV2DataServerTest example text ',
								Type__c='Page', 
								Pages_Category__c = pageCategory.id,
								Status__c='Draft',
								Site__c = site.id,
								Publish_Start_DateTime__c=DateTime.now(),
								Primary_Author__c = peopleObj.id
								);
        insert content;

        content = new Simpplr_Content__c(
                                        Title__c='NewsletterV2DataServerTest_testArticleRecord1', 
                                        Text_Intro__c='NewsletterV2DataServerTest Example text1', 
                                        Text_Main__c='NewsletterV2DataServerTest Example text1',
                                        Text_Main_Continued__c='NewsletterV2DataServerTest example text 1',
                                        Type__c='Page', 
                                        Pages_Category__c = pageCategory.id,
                                        Status__c='Approved',
                                        Site__c = site.id,
                                        Publish_Start_DateTime__c=DateTime.now(),
                                        Publish_End_DateTime__c = null,
                                        Primary_Author__c = peopleObj.id
                                        );
        insert content;
	}
	
	private static void init() {
    	if (appConfigRecord == null) {
    		appConfigRecord = SimpplrContext.appConfig;
        } 

        content  = [select id, site__c from simpplr_Content__c where title__c='NewsletterV2DataServerTest_testArticleRecord' limit 1];
        site = TestHelper.getSiteRecordWithName('NewsletterV2DataServerTest_Grp1');
        publishedContent = [select id, site__c ,Is_Published__c from simpplr_Content__c where title__c='NewsletterV2DataServerTest_testArticleRecord1'  limit 1];
        segmentRec = [Select id From Segment__c where Name__c = 'Untitled Segment' limit 1];
        audienceRec = [Select id From Audience__c where segment__c =: segmentRec.id];
       
    	PageReference pgRef = Page.DataServerRO;
    	pgRef.getParameters().put('target','NewsletterV2DataServer');
        Test.setCurrentPage(pgRef);
    }

    @isTest static void testValidateSiteContent() { 
        Test.startTest();
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        Test.setCurrentPage(pageRef);
       
        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+content.id+'"],"recipient": {"type": "site", "id": "'+site.id+'", "siteMembersType": "siteMembers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+content.id+'"],"recipient": {"type": "site", "id": "'+site.id+'", "siteMembersType": "siteMembersAndFollowers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+publishedContent.id+'"],"recipient": {"type": "site", "id": "'+site.id+'", "siteMembersType": "siteMembers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+publishedContent.id+'"],"recipient": {"type": "site", "id": "'+site.id+'", "siteMembersType": "siteMembersAndFollowers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+content.id+'"],"recipient": {"type": "org", "id": "'+site.id+'", "siteMembersType": "siteMembers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+content.id+'"],"recipient": {"type": "org", "id": "'+site.id+'", "siteMembersType": "siteMembersAndFollowers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+publishedContent.id+'"],"recipient": {"type": "org", "id": "'+site.id+'", "siteMembersType": "siteMembers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+publishedContent.id+'"],"recipient": {"type": "org", "id": "'+site.id+'", "siteMembersType": "siteMembersAndFollowers"}}');
        serverObj.handleRequest();

        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testValidateAudience() {
        Test.startTest();
        init();        
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');        
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+content.id+'"],"recipient": {"type": "audience", "id": "'+audienceRec.id+'", "siteMembersType": "siteMembers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+content.id+'"],"recipient": {"type": "audience", "id": "'+audienceRec.id+'", "siteMembersType": "siteMembersAndFollowers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+publishedContent.id+'"],"recipient": {"type": "audience", "id": "'+audienceRec.id+'", "siteMembersType": "siteMembers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');

        pageRef.getParameters().put('action','validate');
        pageRef.getParameters().put('data','{"contentIds": ["'+publishedContent.id+'"],"recipient": {"type": "audience", "id": "'+audienceRec.id+'", "siteMembersType": "siteMembersAndFollowers"}}');
        serverObj.handleRequest();
        
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testWhenNewsletterActionNull() {
        Test.startTest();
        init();        
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('error', serverObj.response.status, 'Running as Expected');
        
        pageRef.getParameters().put('action','randomAction');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('error', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testWhenTempateActionNull() {
        Test.startTest();
        init();        
        NewsletterTemplateDataServer serverObj = new NewsletterTemplateDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterTemplateDataServer');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('error', serverObj.response.status, 'Running as Expected');
        
        pageRef.getParameters().put('action','randomAction');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('error', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testGet() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','get');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('get', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testUpdateNewsLetter() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('save', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testCreateNewsletter() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();        
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('save', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testGetAuditLog() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','getAuditLog');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('getAuditLog', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testGetSnapshot() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','getSnapshot');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('getSnapshot', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testDelete() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','delete');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('delete', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testSendPreview() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','sendPreview');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('sendPreview', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testSearch() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','search');
        serverObj.handleRequest();
        
        System.assertEquals('search', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }


    @isTest 
    static void testGetAnalytics() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','getAnalytics');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('getAnalytics', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testGetAnalyticsOverview() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','getAnalyticsOverview');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('getAnalyticsOverview', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testGetAnalyticsClicksListing() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        pageRef.getParameters().put('order','ASC');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','getAnalyticsClicksListing');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('getAnalyticsClicksListing', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testGetAnalyticsHeatmap() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('newsletterId','12345');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','getAnalyticsHeatmap');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('getAnalyticsHeatmap', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testGetTemplate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterTemplateDataServer serverObj = new NewsletterTemplateDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterTemplateDataServer');
        pageRef.getParameters().put('templateId','123');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','get');
        serverObj.handleRequest();
        
        System.assertEquals('get', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdateTemplate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterTemplateDataServer serverObj = new NewsletterTemplateDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterTemplateDataServer');
        pageRef.getParameters().put('templateId','123');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('save', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testCreateTemplate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterTemplateDataServer serverObj = new NewsletterTemplateDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterTemplateDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','save');
        pageRef.getParameters().put('data','{}');
        serverObj.handleRequest();
        
        System.assertEquals('save', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testSearchTemplate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterTemplateDataServer serverObj = new NewsletterTemplateDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterTemplateDataServer');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','search');
        serverObj.handleRequest();
        pageRef.getParameters().put('data','searching');
        serverObj.handleRequest();
        
        System.assertEquals('search', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testDeleteTemplate() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterTemplateDataServer serverObj = new NewsletterTemplateDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterTemplateDataServer');
        pageRef.getParameters().put('templateId','123');
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('action','delete');
        serverObj.handleRequest();
        
        System.assertEquals('delete', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        Test.stopTest();
    }

    @isTest 
    static void testGetEmailIdentities() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getEmailIdentities');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getEmailIdentities', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetEmailIdentityDetails() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getEmailIdentityDetails');
        pageRef.getParameters().put('id','someId');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getEmailIdentityDetails', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testCreateEmailIdentity() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('data','{}');
        pageRef.getParameters().put('action','createEmailIdentity');
		Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('createEmailIdentity', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testUpdateEmailIdentity() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('data','{}');
        pageRef.getParameters().put('id','someId');
        pageRef.getParameters().put('action','updateEmailIdentity');
		Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('updateEmailIdentity', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testDeleteEmailIdentity() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','deleteEmailIdentity');
        pageRef.getParameters().put('id','someId');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('deleteEmailIdentity', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testSyncEmailIdentity() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','syncEmailIdentity');
        pageRef.getParameters().put('id','someId');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('syncEmailIdentity', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetFilterOptions() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getFilterOptions');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getFilterOptions', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetPhotos() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getPhotos');
        pageRef.getParameters().put('query','someQuery');
        pageRef.getParameters().put('page','1');
        pageRef.getParameters().put('perpage','10');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getPhotos', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetContentAnalytics() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getContentAnalytics');
        pageRef.getParameters().put('days','23');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getContentAnalytics', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testTrackDownload() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','trackDownload');
        pageRef.getParameters().put('data','{"downloadLocation": "https://foobar.com"}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('trackDownload', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testSessionHeartbeat() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','sessionHeartbeat');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('sessionHeartbeat', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetCategories() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getCategories');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getCategories', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testSaveCategory() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','saveCategory');
        pageRef.getParameters().put('data','{"name": "someName"}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('saveCategory', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetDetailedCategories() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getDetailedCategories');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getDetailedCategories', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetCategoryOverview() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getCategoryOverview');
        pageRef.getParameters().put('data','{"categoryId":"categoryId"}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getCategoryOverview', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetCategoryNewsletters() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getCategoryNewsletters');
        pageRef.getParameters().put('data','{"search":"term","sort":"asc","order":"order","skip":"1","limit":"50","categoryId":"categoryId"}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getCategoryNewsletters', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }

    @isTest 
    static void testGetCategoryUnsentNewsletters() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getCategoryUnsentNewsletters');
        pageRef.getParameters().put('data','{"search":"term","sort":"asc","order":"order","skip":"1","limit":"50","categoryId":"categoryId"}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getCategoryUnsentNewsletters', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    @isTest 
    static void testGetArchivedNewsletters() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getArchivedNewsletters');
        pageRef.getParameters().put('forIds','false');
        pageRef.getParameters().put('data','{"term":"term","sort":"asc","order":"order","rangeStart":"","rangeEnd":"","nextPageToken":"xyz","size":5}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getArchivedNewsletters', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    @isTest 
    static void testGetAllSenderAddresses() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getAllSenderAddresses');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getAllSenderAddresses', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    @isTest 
    static void testGetAllDomains() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','getAllDomains');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('getAllDomains', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    @isTest 
    static void testCreateDomain() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','createDomain');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('createDomain', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    @isTest 
    static void testCreateSenderAddress() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','createSenderAddress');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('createSenderAddress', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    @isTest 
    static void testUpdateSenderAddress() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','updateSenderAddress');
        pageRef.getParameters().put('id','id');
        pageRef.getParameters().put('data','{}');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('updateSenderAddress', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    @isTest 
    static void testDeleteSenderAddress() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','deleteSenderAddress');
        pageRef.getParameters().put('id','id');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('deleteSenderAddress', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
    
    static void testDeleteDomain() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'newsletters',false));
        init();
        NewsletterV2DataServer serverObj = new NewsletterV2DataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','NewsletterV2DataServer');
        pageRef.getParameters().put('action','deleteDomain');
        pageRef.getParameters().put('id','id');
        Test.setCurrentPage(pageRef);
        serverObj.handleRequest();
        
        System.assertEquals('deleteDomain', pageRef.getParameters().get('action'), 'Running as expected');
        System.assertEquals('success', serverObj.response.status, 'Running as Expected');
        
        Test.stopTest();
    }
}