@isTest
private class AIDataServerTest {

    private static User contentModerator;
    static People__c peopleObj;

    @testSetup static void setup() {
    	App_Config__c appConfigRecord = TestHelper.setupAppConfig();
        appConfigRecord.Content_Moderation_Enabled__c = true;
        update appConfigRecord;
        contentModerator = TestHelper.createUser('AIDataServerTest_ContentModerator', null, false);
        User siteOwnr = TestHelper.createUser('AIDataServerTest_siteOwnr', null, false);
        User adminUser = TestHelper.createUser('AIDataServerTest_adminUser', null, true);
        CollaborationGroup cgroup = TestHelper.createCollaborationGroup('Simpplr_Grp_AIDataServerTest','Public');
		CollaborationGroupMember cGrpMem = TestHelper.createCollaborationGroupMember(cgroup.Id, siteOwnr.id,'Admin');
        Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test Page', 'Page', 'Submitted', adminUser, getSimpplrSite('Simpplr_Grp_AIDataServerTest'));
        peopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
    }

    private static void init() {
       List<User> listOfUsers = [select id,lastName from User where lastName='AIDataServerTest_ContentModerator'];
        for(User userObj : listOfUsers) {
            if(userObj.lastName == 'AIDataServerTest_ContentModerator') {
                contentModerator = userObj;
            }
        }
    }
    
    private static Simpplr_Site__c getSimpplrSite(String siteName){
        return([select id,chatter_group_id__c  from Simpplr_Site__c where name = :siteName]);
    }

    private static Simpplr_Content__c getContent(){
    	return([select id from Simpplr_Content__c limit 1]);
    }

    private static CollaborationGroup getCollaborationGroup(){
        // returning the first col group
    	return([select id from CollaborationGroup limit 1]);
    }

    /**
     * @description test case checkCommentToxicity
     */
    @isTest static void testCheckCommentToxicity() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AIDataServer');
        Test.setCurrentPage(pageRef);
        AIDataServer aiDSObject= new AIDataServer();
        SimpplrContext.aiContentModerationEnabled = true;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'AIDataServer/checkCommentToxicity', false));
		    SimpplrContext.aiFeaturesEnabled = '100010000';
        pageRef.getParameters().put('action','checkCommentToxicity');
        pageRef.getParameters().put('data','{"text":"abc"}');
        Test.setCurrentPage(pageRef);
        aiDSObject.handleRequest();
        System.assertEquals('success', aiDSObject.response.status, 'Running as Expected');
        Test.stopTest();
	}

    /**
     * @description test case getFiltersData
     */
    @isTest static void testGetFiltersData() {
        init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AIDataServer');
        Test.setCurrentPage(pageRef);
        AIDataServer aiDSObject= new AIDataServer();
        SimpplrContext.aiContentModerationEnabled = true;
        Test.startTest();
        Simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_AIDataServerTest');
        String resBody = '{"site_list":["'+siteObj.Id+'"],"reporter_list":["'+contentModerator.Id+'"]}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AIDataServer/getFiltersData', resBody, false)); 
		SimpplrContext.aiFeaturesEnabled = '100010000';
        pageRef.getParameters().put('action','getFiltersData');
        pageRef.getParameters().put('data','');
        Test.setCurrentPage(pageRef);
        aiDSObject.handleRequest();
        System.assertEquals('success', aiDSObject.response.status, 'Running as Expected');
        Test.stopTest();
	}

    /**
     * @description test case getModerationQueue
     */
    @isTest static void testGetModerationQueue() {
        init();
        FeedItem feedItem=new FeedItem();
        feedItem.Body = 'Feed Item 1';
        feedItem.ParentId = UserContext.id;
        feedItem.Type = 'TextPost';
        insert feedItem;

        FeedComment feedComm=new FeedComment();
        feedComm.FeedItemId = feedItem.id;
        feedComm.CommentBody = 'Comment 1';
        feedComm.CommentType = 'TextComment';
        insert feedComm; 

        SimpplrContext.aiContentModerationEnabled = true;
        UserContext.hasModifyAllDataPermission = false;
        Simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_AIDataServerTest');

        People__c peopleObj = [select id,user__c  from People__c where user__c = :UserInfo.getUserId()];
        Simpplr_Content__c simpplrContent = getContent();
        String resBody = '{"chatterList":[{"chatter_comment_id":null,"author_id":"'+contentModerator.Id+'","site_id":"'+siteObj.Id+'","content_id":"'+simpplrContent.Id+'","chatter_reply_id":"'+feedComm.Id+'","moderation_metadata":{"reported_by":"user","report_reason":["reported because its not a good reply"],"reporter_id":"'+peopleObj.Id+'","reported_on":"date"}},{"chatter_comment_id":"'+feedItem.Id+'","chatter_reply_id":null,"author_id":"'+contentModerator.Id+'","moderation_metadata":{"reported_by":"system","report_reason":["reported reason","reported reason2"],"reporter_id":"'+contentModerator.Id+'","reported_on":"date"}}],"next_page_token":4}';
        
        AIDataServer aiDSObject= new AIDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AIDataServer');
        pageRef.getParameters().put('action','getModerationQueue');
        pageRef.getParameters().put('data','{"size":16,"sortBy":"Newest","origin":"all","reporter":"all","site":"all","type":"all"}');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        SimpplrContext.aiFeaturesEnabled = '100010000';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AIDataServer/getModerationQueue', resBody, false)); 
        aiDSObject.handleRequest();
        System.assertEquals('success', aiDSObject.response.status, 'Running as Expected');
        Test.stopTest();
	}
    
    /**
     * @description test case reportContent
     */
    @isTest static void testReportContent() {
        FeedItem feedItem=new FeedItem();
        feedItem.Body = 'Feed Item 1';
        feedItem.ParentId = getContent().Id;
        feedItem.Type = 'TextPost';
        insert feedItem;

        FeedItem feedItem2 = new FeedItem();
        feedItem2.Body = 'Feed Item 2';
        feedItem2.ParentId = getCollaborationGroup().id;
        feedItem2.Type = 'TextPost';
        insert feedItem2;

        FeedComment feedComm=new FeedComment();
        feedComm.FeedItemId = feedItem.id;
        feedComm.CommentBody = 'Comment 1';
        feedComm.CommentType = 'TextComment';
        insert feedComm; 

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AIDataServer');
        pageRef.getParameters().put('action','reportContent');
        pageRef.getParameters().put('data','{"reporterId":"'+UserContext.Id+'","itemText":"hi","report_reason":"hiiiii","itemId":"'+feedComm.id+'","action":"reportComment"}');
        Test.setCurrentPage(pageRef);

        AIDataServer aiDSObject= new AIDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'AIDataServer/reportContent', false));
        SimpplrContext.aiFeaturesEnabled = '100010000';
        SimpplrContext.aiContentModerationEnabled = true;
        aiDSObject.handleRequest();

        pageRef.getParameters().put('action','reportContent');
        pageRef.getParameters().put('data','{"reporterId":"'+UserContext.Id+'","itemText":"hi","report_reason":"hiiiii","itemId":"'+feedItem.id+'","action":"reportFeed"}');
        aiDSObject.handleRequest();

        pageRef.getParameters().put('action','reportContent');
        pageRef.getParameters().put('data','{"reporterId":"'+UserContext.Id+'","itemText":"hi","report_reason":"hiiiii","itemId":"'+feedItem2.id+'","action":"reportFeed"}');
        aiDSObject.handleRequest();

        System.assertEquals('success', aiDSObject.response.status, 'Running as Expected');
        Test.stopTest();
	}
  
    /**
     * @description test case to invoke dismiss api
     */
    @isTest static void testDismissAPICall() {
        init();
        FeedItem feedItem=new FeedItem();
        feedItem.Body = 'Feed Item 1';
        feedItem.ParentId = UserContext.id;
        feedItem.Type = 'TextPost';
        insert feedItem;

        FeedComment feedComm=new FeedComment();
        feedComm.FeedItemId = feedItem.id;
        feedComm.CommentBody = 'Comment 1';
        feedComm.CommentType = 'TextComment';
        insert feedComm;   

        SimpplrContext.aiContentModerationEnabled = true;
        System.runAs(contentModerator){
        UserContext.isContentModerator = true;

        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AIDataServer');
        pageRef.getParameters().put('action','markModerationItemDismissed');
        pageRef.getParameters().put('data','{"moderationItemId":"'+feedComm.id+'","type":"post"}');
        Test.setCurrentPage(pageRef);

        AIDataServer aiDSObject= new AIDataServer();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'AIDataServer/markModerationItemDismissed', false));
        SimpplrContext.aiFeaturesEnabled = '100010000';
        aiDSObject.handleRequest();

        System.assertEquals('success', aiDSObject.response.status, 'Running as Expected');
        }
        Test.stopTest();
	}

     /**
     * @description test case to invoke remove api
     */
    @isTest static void testRemoveAPICall() {
        init();
        FeedItem feedItem=new FeedItem();
        feedItem.Body = 'Feed Item 1';
        feedItem.ParentId = UserContext.id;
        feedItem.Type = 'TextPost';
        insert feedItem; 
        
        FeedComment feedComm=new FeedComment();
        feedComm.FeedItemId = feedItem.id;
        feedComm.CommentBody = 'Comment 1';
        feedComm.CommentType = 'TextComment';
        insert feedComm;
        
        SimpplrContext.aiContentModerationEnabled = true;
        System.runAs(contentModerator){
            UserContext.isContentModerator = true;

            PageReference pageRef = Page.DataServerRW;
            pageRef.getParameters().put('target','AIDataServer');
            pageRef.getParameters().put('action','markModerationItemRemoved');
            pageRef.getParameters().put('data','{"moderationItemId":"'+feedItem.id+'","type":"post"}');
            Test.setCurrentPage(pageRef);

            AIDataServer aiDSObject= new AIDataServer();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'AIDataServer/markModerationItemRemoved', false));
            SimpplrContext.aiFeaturesEnabled = '100010000';
            aiDSObject.handleRequest();

            pageRef.getParameters().put('action','markModerationItemRemoved');
            pageRef.getParameters().put('data','{"moderationItemId":"'+feedComm.id+'","type":"reply"}');
            aiDSObject.handleRequest();

            System.assertEquals('success', aiDSObject.response.status, 'Running as Expected');
        }
        Test.stopTest();
	}

    /**
     * @description test case getModerationDataFromMS
     */
    @isTest static void testGetModerationDataFromMS() {
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AIDataProvider');
        Test.setCurrentPage(pageRef);
        AIDataProvider aiDPObj = new AIDataProvider();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('Ok', 200, 'AIDataServer/getModerationDataFromMS', false));
		    SimpplrContext.aiFeaturesEnabled = '100010000';
        List<String> feedElementIdsList = new List<String>();
        feedElementIdsList.add('0D54x00001IwlejCAB');
        Map<String, AIWrapper.ModerationDataWrapper> feedToModerationDataMap = aiDPObj.getModerationDataFromMS(feedElementIdsList);
        Test.setCurrentPage(pageRef);
        String resultMapStr = '{"0D54x00001Iwld7CAB":{"replies":[],"moderationMetadata":{"moderationStatus":"reported"},"chatterCommentId":"0D54x00001Iwld7CAB"},"0D54x00001IwlejCAB":{"replies":[{"moderationMetadata":{"moderationStatus":"reported reply"},"chatterReplyId":"0D74x0000005YlxCAE"}],"moderationMetadata":{"moderationStatus":"reported post"},"chatterCommentId":"0D54x00001IwlejCAB"}}';
        System.assertEquals(resultMapStr, JSON.serialize(feedToModerationDataMap).replaceAll('\'', ''), 'Running as Expected');
        Test.stopTest();
	}
    @isTest static void testGetModerationHistory() {
        init();
        FeedItem feedItem=new FeedItem();
        feedItem.Body = 'Feed Item 1';
        feedItem.ParentId = UserContext.id;
        feedItem.Type = 'TextPost';
        insert feedItem;

        FeedComment feedComm=new FeedComment();
        feedComm.FeedItemId = feedItem.id;
        feedComm.CommentBody = 'Comment 1';
        feedComm.CommentType = 'TextComment';
        insert feedComm; 

        SimpplrContext.aiContentModerationEnabled = true;
        UserContext.hasModifyAllDataPermission = false;
        Simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_AIDataServerTest');

        People__c peopleObj = [select id,user__c  from People__c where user__c = :UserInfo.getUserId()];
        Simpplr_Content__c simpplrContent = getContent();
        String resBody = '{"history_data":[{"reported_by":"system","author_id":"'+contentModerator.Id+'","chatter":{"chatter_comment_id":"'+feedItem.Id+'","chatter_reply_id":null,"reporter_id":"'+contentModerator.Id+'","reported_on":"date"}}],"next_page_token":4}';
        
        AIDataServer aiDSObject= new AIDataServer();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AIDataServer');
        pageRef.getParameters().put('action','getModerationHistory');
        pageRef.getParameters().put('data','{"size":16,"sortBy":"Newest","origin":"all","reporter":"all","site":"all","type":"all"}');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        SimpplrContext.aiFeaturesEnabled = '100010000';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AIDataServer/getModerationHistory', resBody, false)); 
        aiDSObject.handleRequest();
        System.assertEquals('success', aiDSObject.response.status, 'Running as Expected');
        Test.stopTest();
	}
    /**
     * @description test case getFiltersData
     */
    @isTest static void testGetHistoryFilters() {
        init();
        PageReference pageRef = Page.DataServerRW;
        pageRef.getParameters().put('target','AIDataServer');
        Test.setCurrentPage(pageRef);
        AIDataServer aiDSObject= new AIDataServer();
        SimpplrContext.aiContentModerationEnabled = true;
        Test.startTest();
        Simpplr_Site__c siteObj = getSimpplrSite('Simpplr_Grp_AIDataServerTest');
        String resBody = '{"site_list":["'+siteObj.Id+'"],"user_list":["'+contentModerator.Id+'"],"moderator_list":["'+contentModerator.Id+'"]}';
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'AIDataServer/getHistoryFiltersData', resBody, false)); 
		SimpplrContext.aiFeaturesEnabled = '100010000';
        pageRef.getParameters().put('action','getHistoryFiltersData');
        pageRef.getParameters().put('data','');
        Test.setCurrentPage(pageRef);
        aiDSObject.handleRequest();
        System.assertEquals('success', aiDSObject.response.status, 'Running as Expected');
        Test.stopTest();
	}

    
}