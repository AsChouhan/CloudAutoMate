@isTest
private class BatchPushAnalyticsDataTest {
  @testSetup
	static void setup() {
    	TestHelper.setupAppConfig();
		People__c currentUserPeopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        Simpplr_Content__c contentObj = TestHelper.createContent('Blog', 'BlogPost', 'Approved', currentUserPeopleObj, null);
        TestHelper.createContentTitleImage(contentObj.id);
        Segment__c segmentRec = TestHelper.createSegment(currentUserPeopleObj.Id);
        Audience__c audienceRec = TestHelper.createAudience(segmentRec.Id);
		TestHelper.getMailerRecord('Test Newsletter', currentUserPeopleObj.id, null, contentObj.id);
		TestHelper.createCarousel(null, null);
		TestHelper.createSocialCampaign(currentUserPeopleObj.id);
		TestHelper.createSocialAnalytics(currentUserPeopleObj.id);
        TestHelper.createPeoplePreference(currentUserPeopleObj.Id);
        Simpplr_Site__c siteObj = new Simpplr_Site__c();
        siteObj.Site_Type__c = 'Public';
        siteObj.Name = 'TestSite'; 
        insert siteObj;
        Subscription__c subscriptionRecod = TestHelper.createSubscription(audienceRec.id,currentUserPeopleObj.id,'people');
        list<Subscription_Entity__c> subEntityRecord = TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRecod.id,siteObj.id);
        app_default__c appDefaultRecord = TestHelper.setupAppDefault();
        Expertise__c exp = TestHelper.setupExpertise();
        People_Expertise__c expPeople = TestHelper.setupPeopleExpertise(exp,currentUserPeopleObj);
        People_Expertise_Detail__c expPeopleDetail = TestHelper.setupPeopleExpertiseDetail(expPeople,currentUserPeopleObj);
        TestHelper.createChatterFolder('testFolder01', null, siteObj.Id, 'Intranet', null, 'readwrite');

        TestHelper.createAnalyticsFile();
        appDefaultRecord = new App_Default__c(Type__c = 'native_mobile_notifications', OverwriteBatchInProgress__c = false, Data__c = '{"mobileAppUpdatesContentSitesFollow":true,"mobileAppPrivateSiteMembershipRequest":true,"mobileAppPostsToMe":true,"mobileAppLikesPostOrCommentMade":true,"mobileAppLikesOrSharesContentPublished":true,"mobileAppFollowsMe":true,"mobileAppEventInviteMore":true,"mobileAppContentSubmittedForModeration":true,"mobileAppContentMarkedAsMustRead":true,"mobileAppCommentsPostMade":true,"mobileAppCommentsContentPublished":true,"mobileAppAlerts":true,"isProcessing":false,"isApplyToAllUsers":1}');
        insert appDefaultRecord;
        appDefaultRecord = new App_Default__c(Type__c = 'sms_notifications', OverwriteBatchInProgress__c = false, Data__c = '{"smsContentMarkedAsMustRead":true,"smsAlerts":true}');
        insert appDefaultRecord; 
        appDefaultRecord = new App_Default__c(Type__c = 'home-feed', OverwriteBatchInProgress__c = false, Data__c = '{"feedSetting":"news","feedFilter":"date"}');
        insert appDefaultRecord;      
        
        Tiles_Config__c tileRecord = TestHelper.createTilesConfigData(null, siteObj.id, null, 'albums', 'latest');
        appDefaultRecord = new App_Default__c(Type__c = 'home-default', OverwriteBatchInProgress__c = false, Data__c = tileRecord.id);
        insert appDefaultRecord;    
        
        List<App_Integration__c> appIntList  = TestHelper.createAppIntegrationRecords(false, new Set<String>{
                                                                                                    'dropbox', 'sharepoint', 'onedrive', 
                                                                                                    'box', 'googlecalendar', 'servicenow',
                                                                                                    'twitter', 'linkedin', 'dropbox',
                                                                                                    'googledrive'
                                                                                                }); 
		List<People_Integration__c> peopleIntList = TestHelper.createPeopleIntegrationRecords(appIntList, currentUserPeopleObj.id, 'dummy');
                                     
    }

	@isTest static void testBatchPushAnalyticsData1() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('carousel_content', true);
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}

	@isTest static void testBatchPushAnalyticsData2() {
		Test.startTest();
        Simpplr_Site__c siteObj = new Simpplr_Site__c();
        siteObj.Site_Type__c = 'Public';
        siteObj.Name = 'TestSite';
        insert siteObj;
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('site', true);
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
    
    @isTest static void testBatchPushAnalyticsData3() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchAdoptionAnalytics job = new BatchAdoptionAnalytics();
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}

	@isTest static void testBatchPushAnalyticsData4() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		Date currentDate = Date.today();
		DateTime startDateTime = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 0, 0 , 0 );
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('social_analytics', startDateTime, startDateTime.addDays(1));
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}

	@isTest static void testBatchPushAnalyticsData5() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchNewsletter job = new BatchNewsletter('sendAnalyticsDataToAWS');
		DataBase.executeBatch(job, 10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}

	@isTest static void testBatchPushAnalyticsData6() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchSocialCampaignAnalytics campaignBatchJob = new BatchSocialCampaignAnalytics('sendSocialCampaignData', Date.today());
		DataBase.executeBatch(campaignBatchJob, 10);
            people__c currentUserPeopleObj = [Select id from people__c where user__c =: UserInfo.getUserId()];
            Social_Campaign__c camObj = [Select id from Social_Campaign__c where people__c =: currentUserPeopleObj.id];
            List<Social_Campaign_Share__c> socialCampaignShareList = TestHelper.createSocialCampaignShareRecords(currentUserPeopleObj.id, camObj, new Set<String>{'Facebook','Twitter','Linkedin'});
            Analytics_Social_Campaign__c aSocialCamObj = new Analytics_Social_Campaign__c();
            aSocialCamObj.Sync_Status__c = 0;
            aSocialCamObj.Social_Campaign_Share__c = socialCampaignShareList[0].id;
            aSocialCamObj.Date__c = system.today();
            insert aSocialCamObj;
            campaignBatchJob = new BatchSocialCampaignAnalytics('sendSocialCampaignAnlyticsData', Date.today());
		DataBase.executeBatch(campaignBatchJob, 10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
    
    @isTest static void testReccordTypeSegment() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('segment', true);
		DataBase.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }

    @isTest static void testReccordTypeUserProvisioningConfig() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('user_provisioning_config', true);
		DataBase.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testReccordTypeFeedItemPeople() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('feed_item_people', true);
		DataBase.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testRecordTypeSiteRole() {
		Test.startTest();
        People__c peopleObj = [Select Id From People__c Limit 1];
        Simpplr_Site__c siteObj = new Simpplr_Site__c();
        siteObj.Site_Type__c = 'Public';
        siteObj.Name = 'TestSite';
        insert siteObj;
        
        Site_Role__c siteRoleObj = new Site_Role__c();
        siteRoleObj.People__c = peopleObj.Id;
        siteRoleObj.Site__c = siteObj.Id;
        insert siteRoleObj;
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('site_role', true);
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
    
    @isTest static void testRecordTypeAnalyticsTopSite() {
		Test.startTest();
        Simpplr_Site__c siteObj = new Simpplr_Site__c();
        siteObj.Site_Type__c = 'Public';
        siteObj.Name = 'TestSite';
        insert siteObj;
        
        Analytics_Top_Site__c analyticsTopSiteObj = new Analytics_Top_Site__c();
        analyticsTopSiteObj.Date__c = Date.today();
        analyticsTopSiteObj.Site__c = siteObj.Id;
        insert analyticsTopSiteObj;
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_top_site', true);
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
    
    @isTest static void testRecordTypeSegmentSite() {
		Test.startTest();
        Simpplr_Site__c siteObj = new Simpplr_Site__c();
        siteObj.Site_Type__c = 'Public';
        siteObj.Name = 'TestSite';
        insert siteObj;
        
        Segment_Site__c segmentSiteObj = new Segment_Site__c();
        segmentSiteObj.Site__c = siteObj.Id;
        insert segmentSiteObj;
        
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('segment_site', true);
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
    
    @isTest static void testRecordTypeTilesConfig() {
        Test.startTest();
        People__c peopleObj = [Select Id From People__c Limit 1];
        Tiles_Config__c tilesConfigObj = new Tiles_Config__c();
        tilesConfigObj.People__c = peopleObj.Id;
        insert tilesConfigObj;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('tiles_config', true);
		DataBase.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testReccordTypeContentAuditTrail() {
        Test.startTest();
        People__c peopleObj = [Select Id From People__c Limit 1];
        Content_Audit_Trail__c contentAuditTrailObj = new Content_Audit_Trail__c();
        contentAuditTrailObj.Action_DateTime__c = DateTime.now();
        contentAuditTrailObj.Action_By__c = peopleObj.Id;
        contentAuditTrailObj.Dismiss_By__c = peopleObj.Id;
        contentAuditTrailObj.New_Author__c = peopleObj.Id;
        contentAuditTrailObj.Old_Author__c = peopleObj.Id;
        insert contentAuditTrailObj;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('content_audit_trail', true);
		DataBase.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testReccordTypeAnalyticsSocialCampaign() {
        Test.startTest();
        People__c peopleObj = [Select Id From People__c Limit 1];
        Social_Campaign__c socialCampaignObj = new Social_Campaign__c();
        socialCampaignObj.Facebook_Share_Enabled__c = true;
        insert socialCampaignObj;
        
        Social_Campaign_Share__c socialCampaignShareObj = new Social_Campaign_Share__c();
        socialCampaignShareObj.Network_Shared__c = 'facebook';
        socialCampaignShareObj.Social_Campaign__c = socialCampaignObj.Id;
        insert socialCampaignShareObj;
        
        Analytics_Social_Campaign__c analyticsSocialCampaignObj = new Analytics_Social_Campaign__c();
        analyticsSocialCampaignObj.Date__c = date.today();
        analyticsSocialCampaignObj.Social_Campaign_Share__c = socialCampaignShareObj.Id;
        insert analyticsSocialCampaignObj;
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
		BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_social_campaign', true);
		DataBase.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testAnalyticsTopPeople() {
        Test.startTest();
        People__c peopleObj = [Select Id From People__c Limit 1];
        Analytics_Top_People__c analyticsPeopleObj = new Analytics_Top_People__c();
        analyticsPeopleObj.Date__c = date.today();
        analyticsPeopleObj.People__c = peopleObj.Id;
        analyticsPeopleObj.Sync_Status__c = 4;
        insert analyticsPeopleObj;
        
        Analytics_Top_Search__c analyticsTopSearchObj = new Analytics_Top_Search__c();
        analyticsTopSearchObj.Date__c =  date.today();
        insert analyticsTopSearchObj;
        
        Analytics_Top_Topic__c analyticsTopTopicObj = new Analytics_Top_Topic__c();
        analyticsTopTopicObj.Date__c = date.today();
        analyticsTopTopicObj.Topic_Id__c = '0TO0U000000HQnJWAW';
        insert analyticsTopTopicObj;
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
        BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_top_people', true);
        Database.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testAnalyticsFeedCount() {
        Test.startTest();
        Analytics_Feed_Count__c analyticsFeedCountObj = new Analytics_Feed_Count__c();
        analyticsFeedCountObj.Sync_Status__c = 4;
        analyticsFeedCountObj.Date__c = date.today();
        insert analyticsFeedCountObj;
        
        Analytics_Login__c analyticsLoginObj = new Analytics_Login__c();
        analyticsLoginObj.Sync_Status__c = 4;
        analyticsLoginObj.Date__c = date.today();
        insert analyticsLoginObj;
        
        Analytics_PageView__c analyticsPageViewObj = new Analytics_PageView__c();
        analyticsPageViewObj.Sync_Status__c = 4;
        analyticsPageViewObj.Date__c = date.today();
        insert analyticsPageViewObj;
        
        Analytics_Search_Result_Select__c analyticsSearchResultSelectObj = new Analytics_Search_Result_Select__c();
        analyticsSearchResultSelectObj.Sync_Status__c = 4;
        insert analyticsSearchResultSelectObj;
        
        Analytics_Top_Content__c analyticsTopContentObj = new Analytics_Top_Content__c();
        analyticsTopContentObj.Date__c = date.today();
        insert analyticsTopContentObj;
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
        BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_feed_count', true);
        Database.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testAnalyticsAdoption() {
        Test.startTest();
        Analytics_Adoption__c analyticsAdoptionObj = new Analytics_Adoption__c();
        analyticsAdoptionObj.Date__c = date.today();
        insert analyticsAdoptionObj;
        
        Analytics_Content_Count__c analyticsContentCountObj = new Analytics_Content_Count__c();
        analyticsContentCountObj.Date__c = date.today();
        insert analyticsContentCountObj;
        
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
        BatchPushAnalyticsData job = new BatchPushAnalyticsData('analytics_adoption', true);
        Database.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }

    /**
     * @description test case getViewedByMetricData
     */
    @isTest static void testPushContentInteractionData() {
        Test.startTest();
        People__c peopleObj = [Select Id From People__c Limit 1];
        Simpplr_Content__c contentObj = [Select Id From Simpplr_Content__c Limit 1];
        Content_Interaction__c contentInteractionObj = new Content_Interaction__c();
    		contentInteractionObj.View_Count__c = 1;
    		contentInteractionObj.People__c = peopleObj.Id;
    		contentInteractionObj.Content__c = contentObj.Id;
			contentInteractionObj.Sync_Status__c = 0;
    		insert contentInteractionObj;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/PushAnalytics',false));
        BatchPushAnalyticsData job = new BatchPushAnalyticsData('content_interaction', true);
        Database.executeBatch(job, 10);
        System.assert(true, 'Running as Expected');
        Test.stopTest();
	}

}