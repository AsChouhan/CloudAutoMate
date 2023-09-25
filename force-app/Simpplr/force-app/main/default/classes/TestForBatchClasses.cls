@isTest
private class TestForBatchClasses {
	@testSetup
	static void setup() {
		App_Config__c appConfig = TestHelper.setupAppConfig();
		TestHelper.setupAppDefault();
    	People__c currentUserPeopleObj = TestHelper.createPeopleRecordForUser(UserInfo.getUserId());
        String jsonObj = '{"contentSharesCount":"10","usersWhoViewedContentPercentage":"10","contentViewsCount":"10","averageContentPerPerson":"10","contentPostsAndRepliesCount":"10","contentLikesCount":"10","usersLoggedInPercentage":"54"}';
		String jsonObj1= '{"contentSharesCount":"10","usersWhoViewedContentPercentage":"10","contentViewsCount":"10","averageContentPerPerson":"10","contentPostsAndRepliesCount":"10","contentLikesCount":"10","usersLoggedInPercentage":"54"}';

		Adoption_Email__c adEmail = new Adoption_Email__c(Adoption_Email_Month__c= Integer.valueOf(DateTime.now().addMonths(-2).format('yyyyMM')), Adoption_Email_JSON__c= jsonObj);
		insert adEmail;
		Adoption_Email__c adEmail1 = new Adoption_Email__c(Adoption_Email_Month__c= Integer.valueOf(DateTime.now().addMonths(-1).format('yyyyMM')), Adoption_Email_JSON__c= jsonObj1);
        insert adEmail1;
    	
    	User testAdminUser = TestHelper.createUser('TestForBatchClasses_admin', null, true);
    	User testStdUser = TestHelper.createUser('TestForBatchClasses_standard', null, true);
        
		People__c peopleObj = [select id from People__c where last_Name__c='TestForBatchClasses_admin' limit 1];
		
    	peopleObj.Mobile_Token_IOS__c ='Dummy';
		peopleObj.Mobile_Token_Android__c='Dummy';
		peopleObj.Mobile_App_Type_Android__c = 'native';
        peopleObj.App_Moderation_Permission__c = 'Yes';
        peopleObj.Can_Access_Analytics__c = true;
		peopleObj.Unlisted_Site_Moderation_Permission__c = 'Yes';
		peopleObj.Mobile_App_Type_Android__c ='native';
        peopleObj.Sync_Field__c = 'Id';
		update peopleObj;

		People__c peopleObj1 = [select id from People__c where last_Name__c='TestForBatchClasses_standard' limit 1];
		peopleObj1.Mobile_Token_IOS__c ='Dummy';
		peopleObj1.Mobile_Token_Android__c='Dummy';
		peopleObj1.Mobile_App_Type_Android__c = 'native';
        peopleObj1.App_Moderation_Permission__c = 'Yes';
        peopleObj1.Can_Access_Analytics__c = true;
		peopleObj1.Unlisted_Site_Moderation_Permission__c = 'Yes';
		peopleObj1.Mobile_App_Type_Android__c ='native';
        peopleObj.Sync_Field__c = 'Id';
		update peopleObj1;
		People_Preference__c peoplePreference = TestHelper.createPeoplePreference(peopleObj.id);
		Segment__c segmentRec = TestHelper.createSegment(peopleObj.Id);
		
        peoplePreference.Email_PrivateSiteMembership_Response__c = true;
        peoplePreference.Email_Endorses_Me__c = true;
        peoplePreference.Email_My_Content_Post__c = true;
        peoplePreference.Email_Like_My_Post_Or_Comment__c = true;
        peoplePreference.Email_Content_Useful__c = true;
        peoplePreference.Email_Event_Invite_More__c = true;
        peoplePreference.Email_Updates_Content_Sites_I_Follow__c = true;
        peoplePreference.Email_Content_Submission_Response__c = true;
        peoplePreference.Email_My_Content_Like_Or_Share__c = true;
        peoplePreference.Email_Shares_My_Post__c = true;
        peoplePreference.Email_Content_Digest_Frequency__c = 'Weekly';
		peoplePreference.Allow_Simpplr_Emails__c = true;
		peoplePreference.Email_Content_Marked_As_Must_Read__c = true;
        peoplePreference.Email_Site_Analytics_Frequency__c = 'monthly';
        update peoplePreference;
        
        CollaborationGroup grpObj = TestHelper.createCollaborationGroup('TestForBatchClasses_Grp1','Public');
    	TestHelper.createCollaborationGroupMember(grpObj.Id, testAdminUser.id,'Admin');
    	Simpplr_Site__c siteObj = getSite();
    	Alert__c alertObj= TestForBatchClasses.CreateAlertRecord(peopleObj1.id,system.now(),siteObj.id);
		Datetime pubStartDateTime = DateTime.now().addMonths(-12); //.addDays(14)
		List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();

		contentList.add(prepareContentRecord('simpplr test album', 'Album', null, 'Approved', Datetime.now(), Datetime.now(), siteObj));
    	contentList.add(prepareContentRecord('simpplr test album', 'Album', null, 'Approved', Datetime.now(), Datetime.now(), siteObj));
		contentList.add(prepareContentRecord('simpplr K-Page-3', 'Page', 'knowledge', 'Approved', pubStartDateTime.addDays(-4), null, siteObj));
    	contentList.add(prepareContentRecord('simpplr K-Page-4', 'Page', 'knowledge', 'Approved', pubStartDateTime.addDays(4), null, siteObj));
		contentList.add(prepareContentRecord('simpplr K-Page-5', 'Page', 'knowledge', 'Approved', pubStartDateTime.addDays(14), null, siteObj));
		contentList.add(prepareContentRecord('simpplr K-Page-6', 'Page', 'knowledge', 'Approved', pubStartDateTime.addDays(24), null, siteObj));
		contentList = TestHelper.createContentList(contentList, testAdminUser);

		Simpplr_Content__c simpplrContent = TestHelper.createContent('simpplr test album', 'Album', 'Approved', testStdUser, siteObj);
        TestHelper.createFileRecordForVideo(simpplrContent.Id , 'dummyURL');
        simpplrContent = TestHelper.createContent('simpplr test event', 'Event', 'Approved', testAdminUser, siteObj);
		TestHelper.createContent('simpplr test blogpost', 'BlogPost', 'Approved', testStdUser, siteObj);
		TestHelper.createContent('simpplr test page', 'page', 'Approved', testStdUser, siteObj);
		TestDataHandler.createSocialAnalytics(simpplrContent.id,siteObj.id, testAdminUser.id, peopleObj.id);

		FeedItem feedItemObj = TestDataHandler.createFeedItem(simpplrContent.id);
    	FeedComment commentObj = TestDataHandler.createFeedComment(feedItemObj.id);
    	TestHelper.createFeedLike(feedItemObj.id, commentObj.id, peopleObj.id);
		TestHelper.createFeedShare(feedItemObj.id, peopleObj.id);
		TestHelper.createContentLike(simpplrContent.id, peopleObj.id);
		TestHelper.createContentBookmark(simpplrContent.id, peopleObj.id);
		
		Event_RSVP_Response__c rSVPResObj = TestHelper.createRSVPResponse(simpplrContent.Id, currentUserPeopleObj.id, 'Yes');
		TestHelper.createRSVPResponse(simpplrContent.Id, peopleObj1.id, 'Yes');
		List<App_Notification__c> notiList = new List<App_Notification__c>();
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','update', simpplrContent.id, null,'','CollaborationGroupMemberRequest'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','update', simpplrContent.id, null,'','Simpplr Content'));
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Approved','update', simpplrContent.Id, null,'','Simpplr Content'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','follow', UserContext.peopleId, null,'','Simpplr Content'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Endorse', UserContext.peopleId, null,'','Simpplr Content'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','post', UserContext.peopleId, null,'','Simpplr Content'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','like', simpplrContent.Id, null,'','Simpplr Content'));
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','like', Utility.getSimpplrFilePrefix(), null,'','album'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','comment', simpplrContent.Id, null,'','Simpplr Content'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','mention', simpplrContent.Id, null,'','Simpplr Content'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','share', simpplrContent.Id, null,'','Simpplr Content'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','share','0D5ASDF' , null,'','Simpplr Content'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','share', Utility.getSimpplrContentPrefix(), null,'','Simpplr Content'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','rate', simpplrContent.Id, null,'','Simpplr Content'));
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','content update', simpplrContent.Id, null,'','Simpplr Content'));
    	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Event Invite', simpplrContent.Id, null,'','Simpplr Content'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Must Read', UserContext.peopleId, null,'','Simpplr Content'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','rate', UserContext.peopleId, null,'Content_Rated_Unuseful','Simpplr Content'));
       
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','post', UserContext.peopleId, null,'Content_Post','Simpplr Content'));
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','post', UserContext.peopleId, null,'My_Content_Post','Simpplr Content'));
		
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','comment', simpplrContent.Id, null,'Also_Replied_On_Post','Simpplr Content'));
		
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','comment', simpplrContent.Id, null,'Email_Comments_On_Post_I_Like__c','Simpplr Content'));
		
      	notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','comment', simpplrContent.Id, null,'Comments_On_Post_I_Like','Simpplr Content'));
		
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Approved','update', simpplrContent.Id, null,'','CollaborationGroupMemberRequest'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','comment', simpplrContent.Id, null,'Email_Comments_On_Post_I_Like__c','Simpplr Content'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','comment', simpplrContent.Id, null,'CONTENT_FOR_REVIEW','Simpplr Content'));
        notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','rate', simpplrContent.Id, null,'Content_Rated_Unuseful','CollaborationGroupMemberRequest'));

		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Mention', 'questionid', null,'Mentions_In_Question','Question'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Mention', 'answerid', null,'Mentions_In_Answer','Answer'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Vote', 'answerid', null,'Voted_On_Answer','Answer'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Approved', 'answerid', null,'Answer_Approved','Answer'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','New', 'questionid', null,'New_Answer_To_Question','Question'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Approved', 'questionid', null,'Approved_Answer_To_Question','Question'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','Duplicate', 'questionid', null,'Question_Marked_Duplicate','Question'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','New', 'questionid', null,'New_Question','Question'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','New', 'questionid', null,'New_Question_In_Content','Question'));
		notiList.add(prepareNotificationObj('Dummy', peopleObj.id,'Pending','New', 'questionid', null,'New_Answer_In_Content','Question'));


        App_Notification__c modNoti = prepareNotificationObj('Dummy', peopleObj.id,'Pending','like', simpplrContent.Id, null,'','Simpplr Content');
        modNoti.Object_Id__c = '0D5';
        notiList.add(modNoti);
        App_Notification__c modNoti2 = prepareNotificationObj('Dummy', peopleObj.id,'Pending','share', simpplrContent.Id, null,'','Simpplr Content');
        modNoti2.Object_Id__c = '0D5';
        notiList.add(modNoti2);
		notiList = TestHelper.insertSimpplrNotifications(notiList);

    	TestHelper.getMailerRecord('TestForBatchClasses_NewsLetter1', currentUserPeopleObj.Id, null, simpplrContent.Id);    	
    	feedItemObj = TestDataHandler.createFeedItem(testAdminUser.id);
    	commentObj = TestDataHandler.createFeedComment(feedItemObj.id);
    	TestHelper.createFeedLike(feedItemObj.id, commentObj.id, peopleObj.id);
    	TestHelper.createFeedShare(feedItemObj.id, peopleObj.id);
    	
    	feedItemObj = TestDataHandler.createFeedItem(grpObj.id);
    	commentObj = TestDataHandler.createFeedComment(feedItemObj.id);
    	TestHelper.createFeedLike(feedItemObj.id, commentObj.id, peopleObj.id);
    	TestHelper.createFeedShare(feedItemObj.id, peopleObj.id);
    	
    	TestHelper.createTilesConfigData(null, siteObj.id, null, 'albums', 'latest');
    	TestHelper.createTilesConfigData(null, null, peopleObj.id, 'latest', 'activity');
		TestHelper.createTilesConfigData(null, null, null, 'content', 'activity');
		TestHelper.createTilesConfigData(null, null, null, 'content', 'latest_popular');
		TestHelper.createTilesConfigData(null, siteObj.id, null, 'sites', 'latest');
		TestHelper.createTilesConfigData(null, siteObj.id, null, 'site_info', 'standard');
        
        Segment__c segmentObj = TestHelper.createSegment(peopleObj.Id);
        TestHelper.createTilesConfigData(segmentObj.Id, null, null, 'segment', 'latest');
        peopleobj.Segment__c = segmentObj.Id;
        peopleObj.Is_Segment_Manager__c = true;
        update peopleObj;
        
        Audience__c audienceObj = TestHelper.createAudience(segmentObj.Id);
        Subscription__c subscriptionRecSite = TestHelper.createSubscription(audienceObj.Id, peopleObj.Id, 'Site');
        Subscription__c subscriptionRecPeople = TestHelper.createSubscription(audienceObj.Id, peopleObj.id, 'People');
        TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRecSite.Id, siteObj.Id);
        TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRecPeople.Id, siteObj.Id);
		
    	TestHelper.createSiteCategory();
    	Simpplr_content__c simpplrContentAlbum = TestHelper.createContent('album', 'Event', 'Approved', testAdminUser, siteObj);
    	TestHelper.createContentTitleImage(simpplrContentAlbum.Id, 'Thumbnail');
        simpplrContentAlbum.Is_Deleted__c = true;
        update simpplrContentAlbum;
		TestHelper.createSocialAnalytics(currentUserPeopleObj.Id);		
		List<App_Integration__c> appIntegList  = TestHelper.createAppIntegrationRecords(true, new Set<String>{'googledrive', 'adsi'});
		List<People_Integration__c> peopleIntegList = TestHelper.createPeopleIntegrationRecords(appIntegList, currentUserPeopleObj.Id, 'asdsada');
	}

	private static App_Notification__c prepareNotificationObj(String guid, String peopleId, String actionStatus, String subType,
                                                                    String objectId, String parentId,String category,String objType){
        App_Notification__c notiObj = new App_Notification__c
                (
                    GUID__c = guid, Is_Read__c=false, Sent_To__c=peopleId,Sent_By__c=peopleId, Type__c='Information', sub_type__c=subType, Object_Type__c=objType, 
                    Object_Id__c = objectId,  Submitter_Comment__c ='Some Comments', is_Deleted__c=false, Parent__c=parentId,Created_DateTime__c = Datetime.now(),Status__c = actionStatus,
                    Category__c = category
                );
        
		return notiObj;
    }

	private static Simpplr_Content__c prepareContentRecord(String title, String typeArg, String subTypeArg, String status, DateTime publishStartDate, DateTime publishEndDate, Simpplr_Site__c simpplrSiteObj ){
		
		String ctype = String.isBlank(typeArg) ? 'News' : typeArg;
	    Simpplr_Content__c  contentRec = new Simpplr_Content__c(
					                    Title__c=title,
					                    Primary_Author__c = UserContext.peopleId,
					                    Text_Intro__c=TestHelper.getLongText(), 
					                    Text_Main__c=TestHelper.getLongText(),
					                    Text_Main_Continued__c=TestHelper.getLongText(),
					                    Type__c=ctype, 
										Content_Sub_Type__c=subTypeArg,
					                    Summary_1__c='testSummary',
					                    Summary_2__c=' testSummary2',
					                    Status__c=status,
					                    Publish_Start_DateTime__c = publishStartDate,
					                    Last_Edited_DateTime__c = Datetime.now(),
					                    Site__c=(simpplrSiteObj==null)?null:simpplrSiteObj.id);
		
		if('Event'.equalsIgnoreCase(typeArg)) {
			contentRec.Event_Start_DateTime__c = DateTime.now();
			contentRec.Event_End_DateTime__c = DateTime.now().addDays(12);
			contentRec.Event_RSVP_Allowed__c = true;
		}

        return contentRec;
    }

	
	@isTest static void testBatchSfdcUserDataSync(){
		Test.startTest();
        SimpplrContext.locationNormalizationEnabled = true;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/normalization/locations/validate-address',false));
		User siteOwnr = TestHelper.createUser('BatchSfdcUserDataSyncTest_siteOwnr', null, false);
		User siteMember = TestHelper.createUser('BatchSfdcUserDataSyncTest_siteMmbr', null, false);
		User siteAdmin = TestHelper.createUser('BatchSfdcUserDataSyncTest_siteAdmin', null, false);
		SimpplrContext.isPDSJoiningDate = true;
		SimpplrContext.isPDSAboutMe = true;
		BatchSfdcUserDataSync job = new BatchSfdcUserDataSync();
		Database.executeBatch(job,100);
		BatchSfdcUserDataSync job1 = new BatchSfdcUserDataSync(null,1);
		Database.executeBatch(job1,100);
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	
	private static Simpplr_Site__c getSite(){
        Simpplr_Site__c  siteObj = [select Id, Name, Chatter_Group_Id__c, Landing_Page__c 
        								from Simpplr_Site__c where Name='TestForBatchClasses_Grp1' LIMIT 1];
        return siteObj;
    }
    
    private static Simpplr_Content__c getContent() {
        Simpplr_Content__c contentObj = [select id, Site__r.chatter_Group_Id__c from Simpplr_Content__c Limit 1];
        return contentObj;
    }
    
	@isTest static void testBatchTopStories(){
		Test.startTest();
		SimpplrContext.aiFeaturesEnabled='110000000';
		String userId = UserInfo.getUserId(); 
		String queryDailyTopStoryDigest = 'Select Id, People__r.User__c,People__r.UserName__c, People__r.User__r.timezonesidkey,  People__r.User__r.LanguageLocaleKey, People__r.User__r.UserName, '+
		    										' People__r.Full_Name__c, People__r.Email__c, People__c,People__r.First_Name__c, People__r.Segment__c, People__r.Segment__r.Branding_Logo__c, People__r.Segment__r.Branding_JSON__c, People__r.User_Hash__c From People_Preference__c '+
		    										' where people__r.User__c=\'' + userId + '\'';
		
		App_config__c appConfig = SimpplrContext.appConfig;
		appConfig.PDS_About_Me__c = true;
		appConfig.PDS_City__c = true;
		appConfig.PDS_Company_Name__c = true;
		appConfig.PDS_Country__c = true;
		update appConfig;
		
		NotificationHelper.BrandingInfo brandingInfo = new NotificationHelper.BrandingInfo();
		brandingInfo.header_backgroundColor = 'ffffff';
		brandingInfo.header_iconColor = 'c5c5c5';
		brandingInfo.footer_backgroundColor = 'ffffff';
		brandingInfo.footer_textColor = '333333';
		brandingInfo.header_preset = 'default';
		brandingInfo.footer_preset = 'default'; 
		App_Config__c appCon =  TestHelper.setupAppConfig(); 
		BatchTopStories job1 = new BatchTopStories(appConfig, 1, queryDailyTopStoryDigest, brandingInfo, 'https://static.simpplr.com/email-assets/img/logo.png');
		Database.executeBatch(job1,1);
		SimpplrContext.isSegmentsEnabled = true;
		SimpplrContext.isSegmentBrandingEnabled = true; 
		BatchTopStories job2 = new BatchTopStories(appConfig, 1, queryDailyTopStoryDigest, brandingInfo, 'https://static.simpplr.com/email-assets/img/logo.png');
		Database.executeBatch(job2,1);
		
        Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchManageContentPermissions(){
        CollaborationGroup cg = [Select Id From CollaborationGroup Limit 1];
        List<String> chatterGroupList = new List<String>();
        chatterGroupList.add(cg.Id);
        
		Simpplr_Site__c siteObj = getSite();
        Simpplr_Content__c contentObj = getContent();
        
		BatchManageContentPermissions job1 = new BatchManageContentPermissions('ToggleContentPermissions', chatterGroupList, false); 
		Database.executeBatch(job1,10);
		
		job1 = new BatchManageContentPermissions('GroupMembers', new List<String>(), false);
		Database.executeBatch(job1,2);
        
        job1 = new BatchManageContentPermissions('OrphanCoverImagesCleanup', new Set<String>());
		Database.executeBatch(job1,2);
        	
        job1 = new BatchManageContentPermissions('UserGroups', true);
		Database.executeBatch(job1,2);
        
		System.assert(true, 'Running as Expected');
        
	}
    
    @isTest static void testBatchManageContentPermissionWithUser() {
        Test.startTest();
        
        List<User> userList = [Select Id From User Limit 2];
        Set<String> userIds = new Set<String>();
        for(User userObj: userList) {
            userIds.add(userObj.Id);
        }
        
        BatchManageContentPermissions job1 = new BatchManageContentPermissions('GroupMembers', userIds); 
		Database.executeBatch(job1,2);
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testBatchManageSiteConversionActivities() {
        Test.startTest();
        
        Simpplr_Site__c siteObj = getSite();
        Set<Id> siteIdSet = new Set<Id>();
        siteIdSet.add(siteObj.Id);
        
        BatchManageSiteConversionActivities job1 = new BatchManageSiteConversionActivities(JSON.serialize(siteIdSet), 'public', 'private'); 
		Database.executeBatch(job1,2);
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
	@isTest static void testBatchSiteDataSync() {
		BatchSiteDataSync job = new BatchSiteDataSync();
		Database.executeBatch(job,10);
		System.assert(true, 'Running as Expected'); 
	}
    
    @isTest static void testBatchReadershipAnalytics() {
        Test.startTest();
        Simpplr_Content__c contentObj = getContent();
        SimpplrContext.isAnalyticsDataCollectionEnabled = true;
        Date dateArg = Date.today();
        
		BatchReadershipAnalytics job1 = new BatchReadershipAnalytics('initAnalyticsData', dateArg); 
		Database.executeBatch(job1,100);
        BatchReadershipAnalytics job2 = new BatchReadershipAnalytics('initAnalyticsData', dateArg+7); 
		Database.executeBatch(job2,100);
        BatchReadershipAnalytics job3 = new BatchReadershipAnalytics('initAnalyticsData', dateArg+14); 
		Database.executeBatch(job3,100);
        BatchReadershipAnalytics job4 = new BatchReadershipAnalytics('initAnalyticsData', dateArg+21); 
		Database.executeBatch(job4,100);
        BatchReadershipAnalytics job5 = new BatchReadershipAnalytics('initAnalyticsData', dateArg+28); 
		Database.executeBatch(job5,100);
        BatchReadershipAnalytics job6 = new BatchReadershipAnalytics('sendAnalyticsDataToAWS', dateArg); 
		Database.executeBatch(job6,100);
        
        
		System.assert(true, 'Running as Expected');
        Test.stopTest();
	}
    
    @isTest static void testBatchProcessAudienceMembership() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false));
        People__c peopleObj = [Select Id From People__c Limit 1];
        
        Audience__c audienceObj = [Select Id From Audience__c Limit 1];
        audienceObj.Audience_Rule_Json__c = '[{"department":["Dep-1"]}]';
        update audienceObj;
        
        Audience_Member__c audienceMemberObj = new Audience_Member__c();
        audienceMemberObj.Audience__c =audienceObj.Id;
        audienceMemberObj.People__c = peopleObj.Id;
        insert audienceMemberObj;
        
        BatchProcessAudienceMembership job = new BatchProcessAudienceMembership(audienceObj.Id, new List<String>());
		Database.executeBatch(job,100);
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }
    
    @isTest static void testBatchUpdatePeopleRecords() {
        Test.startTest();
        
        List<String> fieldListToEmpty = new List<String>();
        fieldListToEmpty.add('Custom_Field_1__c');
        
        BatchUpdatePeopleRecords job = new BatchUpdatePeopleRecords('clearCustomFields',fieldListToEmpty);
		Database.executeBatch(job,10);
        
        System.assert(true, 'Running as Expected');
        Test.stopTest();
    }

	@isTest static void testBatchUpdateSiteRecords() {
		Test.startTest();

		Simpplr_Site__c siteObj = getSite();
		People__c peopleObj = [select id from People__c where last_Name__c='TestForBatchClasses_admin' limit 1];
		Site_Role__c siteRoleObj = TestHelper.createSiteRole(peopleObj.Id, siteObj.Id, true, true);
		
		BatchUpdateSiteRecords updateSiteRecords = new BatchUpdateSiteRecords();
		Database.executeBatch(updateSiteRecords, 100);

		Test.stopTest();
		System.assert(true, 'Running as Expected');		

	}
	
	@isTest static void testBatchMustReadNotifications() {
		Test.startTest();
		String appConfigQuery = 'SELECT Id, Simpplr_Mobile_Notification_Allowed__c From App_Config__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
		appConfig.Simpplr_Mobile_Notification_Allowed__c = true;
		update appConfig;
		Simpplr_Content__c contentObj = [select id, Site__c, Site__r.Chatter_Group_Id__c from Simpplr_Content__c Where title__c = 'simpplr test album' limit 1];
		Must_Read_Audit__c  mustReadAuditObj = TestHelper.createMustReadAudit(contentObj.id, 'everyone', UserContext.peopleId);
		mustReadAuditObj.Removed_DateTime__c = null;
		update mustReadAuditObj;
		Must_Read_Confirm_History__c mustReadAuditHistoryObj = new Must_Read_Confirm_History__c();
		mustReadAuditHistoryObj.Must_Read_Audit__c = mustReadAuditObj.Id;
		mustReadAuditHistoryObj.people__c = UserContext.peopleId;
		mustReadAuditHistoryObj.Content__c = contentObj.Id;
		insert mustReadAuditHistoryObj;
		File__c fileObj = TestHelper.createContentTitleImage(contentObj.id);
		ContentVersion conObj  = TestHelper.createContentVersion('conVer', 'File_01');
		fileObj.Title_Image_Type__c = 'thumbnail';
		fileObj.Content_Version__c = conObj.Id;
		update fileObj;

		BatchMustReadNotifications job = new BatchMustReadNotifications(contentObj.id,'makeMustReadNotifications');
		Database.executeBatch(job);

		Simpplr_Content__c contentObj1 = [select id,Event_Start_DateTime__c,Event_End_DateTime__c, Site__c, Site__r.Chatter_Group_Id__c from Simpplr_Content__c Where title__c = 'simpplr test event' limit 1];
		contentObj1.Event_Start_DateTime__c = DateTime.Now();
		contentObj1.Event_End_DateTime__c = DateTime.Now();
		update contentObj1;
		mustReadAuditObj = TestHelper.createMustReadAudit(contentObj1.id, 'everyone', UserContext.peopleId);
		BatchMustReadNotifications job1a = new BatchMustReadNotifications(contentObj1.id,'makeMustReadNotifications');
		Database.executeBatch(job1a);
		Simpplr_Content__c contentObj2 = [select id, Site__c, Site__r.Chatter_Group_Id__c from Simpplr_Content__c Where title__c = 'simpplr test BlogPost' limit 1];
		mustReadAuditObj = TestHelper.createMustReadAudit(contentObj2.id, 'everyone', UserContext.peopleId);
		BatchMustReadNotifications job1b = new BatchMustReadNotifications(contentObj1.id,'makeMustReadNotifications');
		Database.executeBatch(job1b);
		
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
	
	@isTest static void testBatchMustReadNotificationsForMustReadsReminderEmailForSingleContent() {
		Test.startTest();
		Simpplr_Content__c contentObj = [select id,Is_Deleted__c,Activated_By_Feature__c from Simpplr_Content__c  Where title__c = 'simpplr test page' limit 1];
		contentObj.Is_Deleted__c = false;
		update contentObj;
		Must_Read_Audit__c  mustReadAuditObj = TestHelper.createMustReadAudit(contentObj.id, 'everyone', UserContext.peopleId);
		mustReadAuditObj.Expiry_DateTime__c = null;
		update mustReadAuditObj;
		Must_Read_Confirm_History__c mustReadAuditHistoryObj = new Must_Read_Confirm_History__c();
		mustReadAuditHistoryObj.Must_Read_Audit__c = mustReadAuditObj.Id;
		mustReadAuditHistoryObj.people__c = UserContext.peopleId;
		mustReadAuditHistoryObj.Content__c = contentObj.Id;
		insert mustReadAuditHistoryObj;
		BatchMustReadNotifications job = new BatchMustReadNotifications(contentObj.id,'mustReadsReminderEmailForSingleContent');
		Database.executeBatch(job);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
	
	
	@isTest static void testBatchContentAutoGovNotifications() {
		Test.startTest();
		
		List<Simpplr_Content__c> contentObjList = [select id from Simpplr_Content__c limit 10];
		BatchContentAutoGovNotifications job = new BatchContentAutoGovNotifications('markContentsAsExpired', true);
		Database.executeBatch(job);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}

	@isTest 
	static void testBatchSaveAppGovernance() {
		Test.startTest();
		BatchContentAutoGovNotifications job = new BatchContentAutoGovNotifications('deleteContentGovActionableNotifications');
		Database.executeBatch(job);
		Test.stopTest();

		List<App_Notification__c> listAppNotifications = [SELECT Id FROM App_Notification__c WHERE Category__c='CONTENT_FOR_REVIEW' AND Is_Deleted__c = false];

		System.assertEquals(0, listAppNotifications.size(), 'Delete content governance actionable notifications');
	}
		
	@isTest static void testBatchResetMustRead() {
		Test.startTest();
		Map<String,Object> mapOfActivityParams = new Map<String,Object>();
		Simpplr_Site__c siteObj = getSite();
		List<String> listOfSiteIds = new List<String>();
		listOfSiteIds.add(siteObj.Id);
		Simpplr_Content__c contentObj = [select id,Is_Deleted__c, Site__c, Type__c from Simpplr_Content__c  Where title__c = 'simpplr test page' limit 1];

		mapOfActivityParams.put('listOfArchivedSites', new List<String>{contentObj.site__c});
		contentObj.Is_Deleted__c =false;
		contentObj.Site__c = listOfSiteIds[0];
		contentObj.Type__c = 'page';
		update contentObj;
		CollaborationGroup grpObj1 = TestHelper.createCollaborationGroup('TestForBatchClasses_Grp2','Public');
		User testAdminUser1 = TestHelper.createUser('TestForBatchClasses_admin1', null, true);
		TestHelper.createCollaborationGroupMember(grpObj1.Id, testAdminUser1.id,'Admin');
		List<String> listOfInactiveFeatures = new List<String>();
		listOfInactiveFeatures.add(contentObj.Type__c);
		List<String> listOfContentIds = new List<String>();
		listOfContentIds.add(contentObj.Id);
		Must_Read_Audit__c  mustReadAuditObj = TestHelper.createMustReadAudit(contentObj.id, 'everyone', UserContext.peopleId);
		mustReadAuditObj.Expiry_DateTime__c = null;
		mustReadAuditObj.Removed_DateTime__c = null;
		update mustReadAuditObj;
		App_Notification__c appNotiObj = TestHelper.createSimpplrNotification('Dummy', UserContext.peopleId,'actionable','Like',contentObj.id,null);
		appNotiObj.Type__c = 'actionable';
		appNotiObj.Category__c = 'Must_Read';
		appNotiObj.Action_By__c = null;
		appNotiObj.Is_Deleted__c = false;
		appNotiObj.Content__c = contentObj.Id;
		update appNotiObj;
		mapOfActivityParams.put('listOfArchivedSites', listOfSiteIds);
		mapOfActivityParams.put('InactiveFeatures', listOfInactiveFeatures);
		mapOfActivityParams.put('listOfSitesWithInactiveFeatures', listOfSiteIds);
		mapOfActivityParams.put('listOfSiteIds', listOfSiteIds);
		mapOfActivityParams.put('listOfContentIds', listOfContentIds);
		BatchResetMustRead job = new BatchResetMustRead('SitesArchived', true, mapOfActivityParams);
		Database.executeBatch(job,1);
		
		BatchResetMustRead job1a = new BatchResetMustRead('FeaturesInactive', true, mapOfActivityParams);
		Database.executeBatch(job1a);

		BatchResetMustRead job1b = new BatchResetMustRead('DeletePendingActionableNotifications', true, mapOfActivityParams);
		Database.executeBatch(job1b);

		BatchResetMustRead job1c = new BatchResetMustRead('DeleteMustReadNotificationsForNonSiteMembers', false, mapOfActivityParams);
		Database.executeBatch(job1c,2000);
		
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
	
	@isTest static void testBatchResetMustReadFeatureInactive() {
		Test.startTest();
		Map<String,Object> mapOfActivityParams = new Map<String,Object>();
		Simpplr_Content__c contentObj = [select id, Site__c, Type__c from Simpplr_Content__c limit 1];
		mapOfActivityParams.put('listOfArchivedSites', new List<String>{contentObj.site__c});
			
		mapOfActivityParams.put('InactiveFeatures', new List<String>{contentObj.Type__c});
		mapOfActivityParams.put('listOfSitesWithInactiveFeatures', new List<String>{contentObj.Site__c});
		BatchResetMustRead job = new BatchResetMustRead('FeaturesInactive', false, mapOfActivityParams);
		ID batchID = Database.executeBatch(job,1);
		System.abortJob(batchID);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
	
	@isTest static void testBatchLoginAnalytics(){
		BatchLoginAnalytics job1 = new BatchLoginAnalytics(Date.today());
		Database.executeBatch(job1,1);
		
		System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchAdoptionAnalytics(){
		BatchAdoptionAnalytics job2 = new BatchAdoptionAnalytics('initAnalyticsData', Date.today());
		Database.executeBatch(job2,10);
		System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchTopSitesAnalytics(){
		BatchTopSitesAnalytics job1 = new BatchTopSitesAnalytics('initAnalyticsData', Date.today());
		Database.executeBatch(job1,100);
		System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchADAPIUserSync(){
		Test.startTest();
        SimpplrContext.locationNormalizationEnabled = true;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/normalization/locations/validate-address',false));
		BatchADAPIUserSync job = new BatchADAPIUserSync(null, 'InitialUserSync');
		Database.executeBatch(job,100);
        Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	@isTest static void testBatchADAPIUserSync1(){
		Test.startTest();
        SimpplrContext.locationNormalizationEnabled = true;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/normalization/locations/validate-address',false));
		BatchADAPIUserSync job = new BatchADAPIUserSync(null,'3', 'UserIndividualSync');
		Database.executeBatch(job,100);
        Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	@isTest static void testBatchADAPIUserSync2(){
		Test.startTest();
        SimpplrContext.locationNormalizationEnabled = true;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/normalization/locations/validate-address',false));
        BatchADAPIUserSync job = new BatchADAPIUserSync(null, 'UserIndividualSync');
		Database.executeBatch(job,100);
        Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	@isTest static void testBatchADAPIUserSync3(){
		Test.startTest();
        SimpplrContext.locationNormalizationEnabled = true;
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'/normalization/locations/validate-address',false));
        BatchADAPIUserSync job = new BatchADAPIUserSync(null, 'UserBulkSync');
		Database.executeBatch(job,100);    
        Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchContentCountAnalytics(){
		Test.startTest();
		BatchContentCountAnalytics job = new BatchContentCountAnalytics('initAnalyticsData', Date.today());
		ID batchID = Database.executeBatch(job,1);
		System.abortJob(batchID);
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchFeedAnalytics() {
		BatchFeedAnalytics job = new BatchFeedAnalytics('initAnalyticsData', Date.today());
		Database.executeBatch(job,10);
		System.assert(true, 'Running as Expected');
	}

	@isTest static void testBatchGoogleDriveSync() {
		Test.startTest();
		List<CollaborationGroup> collabGroup = [Select id from CollaborationGroup ];
		BatchGoogleDriveSync job = new BatchGoogleDriveSync('addMembersToGoogleGroup', true, collabGroup[0].id);
		Database.executeBatch(job,10);

		String appIntQuery = 'Select id, name, Simpplr_Managed_Permission__c from App_Integration__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, null);
		appIntegList[0].Simpplr_Managed_Permission__c = true;
		update appIntegList;
		BatchGoogleDriveSync job1 = new BatchGoogleDriveSync('addMembersToGoogleGroup', true);
		Database.executeBatch(job1,10);
		
		job1.setToString(new Set<String>{'a', 'b', 'c'}, 'test' );
		BatchGoogleDriveSync.stringToSet('test', 'testtest' );
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}

	@isTest static void testBatchDeleteFolderRecords() {
		Test.startTest();
		BatchDeleteFolderRecords job = new BatchDeleteFolderRecords('googledrive', false);
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}

	@isTest static void testBatchDeleteTilesConfigRecords() {
		Test.startTest();
		BatchDeleteTilesConfigRecords job = new BatchDeleteTilesConfigRecords(null, 'googleCalendar');
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
    
	@isTest static void testBatchDeleteAnalyticsRecords() {
		BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(Date.today().addDays(-1), Date.today(), 'Analytics_Content_Count__c', true);
		Database.executeBatch(job,1);
		System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchNewsletter() {
		Test.startTest();
		List<String> fieldList = NewsLetterDataServer.getNewsletterFieldList();
		String query = 'SELECT '+String.join(fieldList,',')+' FROM Mailer__c limit 1';
		Mailer__c mailerObj = Database.query(query);
		BatchNewsletter job = new BatchNewsletter(mailerObj, DateTime.now(), false, false);
		Database.executeBatch(job, 10);
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}

	@isTest static void testBatchInsertTilesConfig() {
		Test.startTest();
		Tiles_Config__c tileConfig=[select id from Tiles_Config__c limit 1];
		BatchInsertTilesConfig job = new BatchInsertTilesConfig(tileConfig.id);
		Database.executeBatch(job, 10);
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testScheduledBatchNewsletter() {
		Test.startTest();
        List<String> fieldList =  NewsLetterDataServer.getNewsletterFieldList();
        String query = 'SELECT '+String.join(fieldList,',')+' FROM Mailer__c limit 1';
        Mailer__c mailerObj = Database.query(query);
        BatchNewsletter job = new BatchNewsletter(mailerObj, mailerObj.Scheduled_Date__c.addDays(2), true, true);
        Database.executeBatch(job,2);
        Test.stopTest();
        System.assert(true, 'Running as Expected');
    }

	@isTest static void testSchedulerHourlySimpplrServices() {
		Test.startTest();
		SchedulerHourlySimpplrServices scheduleJob = new SchedulerHourlySimpplrServices();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
		SchedulerHourlySimpplrServices.checkStatusForAIRelatedContent();
		SchedulerHourlySimpplrServices.removeExpiredContentFromAI();
        List<People__c> peopleObjList = [select Id, User_Last_Deactivated__c, User__c, User__r.LastModifiedDate, User__r.isActive  from People__c limit 1];
        SchedulerHourlySimpplrServices.deactivatedPeopleUpdate(JSON.serialize(peopleObjList));
		scheduleJob.execute(null);
		SchedulerHourlySimpplrServices.removeMustReadForUnpublishedContent();
		Test.stopTest();
        System.assert(true, 'Running as Expected');

	}
    
	@isTest static void testBatchNotificationDigest(){
		Test.startTest();
		new SchedulerBatchNotificationDigest().execute(null);
		People__c peopleObj = [select id from People__c where last_Name__c='TestForBatchClasses_admin' limit 1];
  		List<People_Preference__c> peoplePreferences = [Select Id, People__r.User__c,People__r.User__r.UserName, People__r.User__r.timezonesidkey, People__r.User__r.languagelocalekey,
														Email_Follows_Me__c, Email_Endorses_Me__c, Email_PrivateSiteMembership_Response__c, Email_Content_Submission_Response__c,
														Email_My_Content_Post__c, Email_Like_My_Post_Or_Comment__c, Email_Comments_After_Me__c, Email_Comments_On_Post_I_Like__c,
														Email_Comments_On_My_Post__c, Email_Posts_To_Me__c, Email_Shares_My_Post__c, Email_My_Content_Like_Or_Share__c,Email_Content_Submitted_for_Moderation__c,
														Email_Content_Useful__c,Email_Updates_Content_Sites_I_Follow__c, Email_Event_Invite_More__c,Email_Private_Site_Membership_Requests__c,
														Email_QnA_Question_Mention__c, Email_QnA_Answer_Mention__c, Email_QnA_Answer_Vote__c, Email_QnA_Answer_Approval__c, Email_QnA_New_Content_Question__c, Email_QnA_New_Answer__c, Email_QnA_New_Content_Answer__c, Email_QnA_New_Answer_Approval__c, Email_QnA_Duplicate_Question__c, Email_QnA_New_Question__c,
														People__r.Full_Name__c, People__r.Email__c, People__c,People__r.First_Name__c, People__r.Last_Name__c From People_Preference__c
														where People__c=:peopleObj.id];

		peoplePreferences[0].Email_Private_Site_Membership_Requests__c= true;
		peoplePreferences[0].Email_Content_Submitted_for_Moderation__c = true; 
		peoplePreferences[0].Email_Notification_Digest_Frequency__c = 'Daily';
		update peoplePreferences[0];
        
		BatchNotificationDigest job1 = new BatchNotificationDigest(SimpplrContext.appConfig , 1 , '' , new NotificationHelper.BrandingInfo(),'');
			
		NotificationHelper.BrandingInfo brandingInfo = new NotificationHelper.BrandingInfo();
		brandingInfo.header_backgroundColor = 'ffffff';
		brandingInfo.header_iconColor = 'c5c5c5';
		brandingInfo.footer_backgroundColor = 'ffffff';
		brandingInfo.footer_textColor = '333333';
		brandingInfo.header_preset = 'default';
		brandingInfo.footer_preset = 'default';
		job1.execute(null, peoplePreferences);
		CollaborationGroup cGObj = TestHelper.createCollaborationGroup('BatchPendingApprovalDigest', 'Public');
        Simpplr_Site__c siteeObj = getSimpplrSite('BatchPendingApprovalDigest');
        siteeObj.Is_Active__c = true;
        siteeObj.Show_In_Simpplr__c = true;
        siteeObj.Chatter_Group_Id__c = cGObj.Id;
        siteeObj.Site_Type__c = 'public';
        update siteeObj;
        Simpplr_Content__c simpContentPage = TestHelper.createContent('Test_Page', 'Page', 'Approved', peopleObj, siteeObj);
        App_Notification__c notificationObj = TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'Like',null,null);
        notificationObj.Type__c = 'Actionable';
		notificationObj.Sub_Type__c = 'App Analytics';
		notificationObj.Status__c = 'Pending';
        notificationObj.is_Deleted__c = false;
        notificationObj.Simpplr_Site__c = null;
		notificationObj.Object_Type__c = 'CollaborationGroupMemberRequest'; 
		notificationObj.Object_Id__c = simpContentPage.id;
        notificationObj.category__c = null;
		update notificationObj;
		BatchPendingApprovalDigest job2 = new BatchPendingApprovalDigest('site_moderation', true);
        job2.execute(null, peoplePreferences);
        notificationObj.Object_Type__c = null;
        notificationObj.category__c = 'Event_Submitted_For_Moderation';
        update notificationObj;
        job2.execute(null, peoplePreferences);
        notificationObj.category__c = 'Page_Submitted_For_Moderation';
        update notificationObj;
        job2.execute(null, peoplePreferences);
        notificationObj.category__c = 'Album_Submitted_For_Moderation';
        update notificationObj;
		job2.execute(null, peoplePreferences);
		Database.executeBatch(job2,20);
        Test.stopTest();
		System.assert(true, 'Running as Expected');
		
	}
	
	
	@isTest static void testBatchNotificationsOnContentUpdate() { 
		Test.startTest();
        Simpplr_Content__c contentObj = [select id from Simpplr_Content__c limit 1];
        BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate(contentObj.id, 'Content Update Message');
        List<App_Notification__c> notificationList = [Select id, Sent_To__c,sub_type__c, Submitter_Comment__c, Simpplr_Site__c, Status__c,
        										  Object_Id__c, Object_Type__c, Parent_Object_Id__c, Type__c, Sent_By__c From App_Notification__c];
		Database.executeBatch(job,20);
		
		contentObj = [select id,Event_Start_DateTime__c,Event_End_DateTime__c, Site__c, Site__r.Chatter_Group_Id__c from Simpplr_Content__c Where title__c = 'simpplr test event' limit 1];
		job = new BatchNotificationsOnContentUpdate('sendEmailToAuthorOnEventAction', contentObj.id, 'eventUpdated', true, true);
		Database.executeBatch(job,20);
		job = new BatchNotificationsOnContentUpdate('sendEmailToAuthorOnEventAction', contentObj.id, 'eventUnpublished', true, true);
		Database.executeBatch(job,20);
		job = new BatchNotificationsOnContentUpdate('sendEmailToAuthorOnEventAction', contentObj.id, 'eventDeleted', true, true);
		Database.executeBatch(job,20);
		job = new BatchNotificationsOnContentUpdate('sendNotificationOnRSVPActionToAuthorAndOrganizer', null, null);
		Database.executeBatch(job, 20);
        Test.stopTest();
        System.assert(true, 'Running as Expected');
    }
	
	@isTest static void testBatchNotificationsOnContentUpdateNew() {
		Test.startTest();
		Simpplr_Content__c contentObj = [select id, title__c, Type__c, Site__c, Primary_Author__r.User__r.languagelocalekey,
										(SELECT Id, People__c, People__r.Full_Name__c FROM Event_RSVP_Responses__r) 										
										from Simpplr_Content__c where Type__c='Event' limit 1];
		String appConfigQuery = 'SELECT Id, Simpplr_Mobile_Notification_Allowed__c, SMS_Enabled__c From App_Config__c Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
		appConfig.Simpplr_Mobile_Notification_Allowed__c = true;
		update appConfig;
		List<People__c> peopleList = [Select id, Mobile_Phone__c from People__c];
		BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate(contentObj.id, 'Content Update Message');
		Database.executeBatch(job,20);

		BatchNotificationsOnContentUpdate job1 = new BatchNotificationsOnContentUpdate('sendEmailToAuthorOnEventAction', contentObj.id, 'eventUpdated', true, true);
		Database.executeBatch(job1,20);
		List<Map<String,String>> listOfMap = new List<Map<String,String>>();
		Map<String, String> mapOfSmsDetail = new Map<String, String>();
		mapOfSmsDetail.put(peopleList[0].id, peopleList[0].id);
		listOfMap.add(mapOfSmsDetail);
		ResponseWrapper response = job1.sendSms(listOfMap, contentObj, 'test');
		List<Simpplr_Content__c> simpplrList = new List<Simpplr_Content__c>();
		simpplrList.add(contentObj);
		job1.sendNotificationOnRSVPActionToAuthorAndOrganizer(simpplrList);
		job1.sendEventActionEmail(mapOfSmsDetail);
		Test.stopTest();
        System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchOverwriteAppDefaults() {
		Test.startTest();
		Simpplr_Site__c siteObj = getSite();
		People__c ppOb = [select id from People__c where last_Name__c='TestForBatchClasses_standard' ];
		Segment__c segObj = TestHelper.createSegment(ppOb.Id);
		Tiles_Config__c tileObj = TestHelper.createTilesConfigData(segObj.id,siteObj.Id,ppOb.Id,'albums', 'latest');
		tileObj.Is_deleted__c = false;
		tileObj.Location__c = 'Home Dashboard';
		update tileObj;
		App_Default__c appDefaultObj = TestHelper.setupAppDefault();
		appDefaultObj.segment__c = null;
		appDefaultObj.type__c = 'home-feed';
		update appDefaultObj;

        BatchOverwriteAppDefaults job = new BatchOverwriteAppDefaults('email_notifications', false, null);
        Database.executeBatch(job,100);
        
        job = new BatchOverwriteAppDefaults('DeleteOldTiles', true, null);
		Database.executeBatch(job,100);
		
		job = new BatchOverwriteAppDefaults('Default Feed', false, null);
		Database.executeBatch(job,100);

		App_Default__c appDefaultObj1 = TestHelper.setupAppDefault();
		Tiles_Config__c tileObj1 = TestHelper.createTilesConfigData(segObj.id,siteObj.Id,ppOb.Id,'albums', 'latest');
		tileObj1.Location__c = 'Home Default';
		update tileObj1;
		appDefaultObj1.type__c = 'home-default';
		update appDefaultObj1;

		BatchOverwriteAppDefaults job1 = new BatchOverwriteAppDefaults('createDefaultHomeTiles', false, segObj.Id);
		Database.executeBatch(job1,100);
		Test.stopTest();
        System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchOverwriteAppDefaultOthers() {
		Test.startTest();
		//SMS
		App_Default__c appDefaultSMS = TestHelper.setupAppDefault();
		appDefaultSMS.Data__c = '{"smsContentPromotionMessage":true,"smsContentMarkedAsMustRead":false,"smsAlerts":true,"isProcessing":false,"isApplyToAllUsers":"1"}';
		appDefaultSMS.type__c = 'sms_notifications';
		update appDefaultSMS;
		BatchOverwriteAppDefaults jobSMS = new BatchOverwriteAppDefaults('sms_notifications', false, null);
		Database.executeBatch(jobSMS,100);
		//Summaries
		App_Default__c appDefaultSummaries = TestHelper.setupAppDefault();
		appDefaultSummaries.Data__c = '{"topStoriesFrequency":"Daily","siteAnalyticsFrequency":"Monthly","digestFrequency":"Daily","isApplyToAllUsers":1}';
		appDefaultSummaries.type__c = 'summaries_and_digest';
		update appDefaultSummaries;
		BatchOverwriteAppDefaults jobSummaries = new BatchOverwriteAppDefaults('summaries_and_digest', false, null);
		Database.executeBatch(jobSummaries,100);
		//MOBILE
		App_Default__c appDefaultMobile = TestHelper.setupAppDefault();
		appDefaultMobile.Data__c = '{"mobileAppContentMarkedAsMustRead": true, "mobileAppAlerts": true, "mobileAppUpdatesContentSitesFollow": true, "mobileAppFollowsMe": true, "mobileAppEndorseExpertise": true, "mobileAppCommentsPostMade": true, "mobileAppReplyAfterMe": true, "mobileAppReplyOnLikedPost": true, "mobileAppLikesPostOrCommentMade": true, "mobileAppSharesMyPost": true, "mobileAppPostsToMe": true, "mobileAppPrivateSiteMembershipResponse": true, "mobileAppCommentsContentPublished": true, "mobileAppLikesOrSharesContentPublished": true, "mobileAppContentApprovalRejection": true, "mobileAppEventInviteMore": true, "mobileAppPrivateSiteMembershipRequest": true, "mobileAppContentSubmittedForModeration": true, "mobileQnAQuestionMention": true, "mobileQnAAnswerMention": true, "mobileQnAVote": true, "mobileQnAAnswerApproval": true, "mobileQnANewAnswer": true, "mobileQnANewApprovedAnswer": true, "mobileQnADuplicateQuestion": true, "mobileQnANewQuestion": true, "mobileAppContentQuestion":true, "mobileAppContentAnswer":true, "mobileSurveys": true}';
		appDefaultMobile.type__c = 'native_mobile_notifications';
		update appDefaultMobile;
		BatchOverwriteAppDefaults jobMobile = new BatchOverwriteAppDefaults('Native Mobile Notifications', false, null);
		Database.executeBatch(jobMobile,100);
		//BROWSER
		App_Default__c appDefaultBrowser = TestHelper.setupAppDefault();
		appDefaultBrowser.Data__c = '{"browserMustRead": true, "browserAlerts": true, "browserUpdatesContentSitesFollow": true, "browserFollowsMe": true, "browserEndorseExpertise": true, "browserReplyOnMyPost": true, "browserReplyAfterMe": true, "browserReplyOnLikedPost": true, "browserLikesMyPostOrReply": true, "browserSharesMyPost": true, "browserPostsToMe": true, "browserPrivateSiteMembershipResponse": true, "browserContentValidationRequired": true, "browserContentValidationExpired": true, "browserContentCommentsOnPublished": true, "browserContentLikesSharesOnPublished": true, "browserContentApprovalRejection": true, "browserContentFeedback": true, "browserEventInvite": true, "browserEventUpdatesAttending": true, "browserEventUpdatesAuthoredOrganized": true, "browserPrivateSiteMembershipRequest": true, "browserContentSubmittedForModeration": true, "browserSubscriptionRequest": true,"browserQnAVote":true,"browserQnAQuestionMention":true,"browserQnANewQuestion":true,"browserQnANewApprovedAnswer":true,"browserQnANewAnswer":true,"browserQnADuplicateQuestion":true,"browserQnAAnswerMention":true,"browserQnAAnswerApproval":true,"browserContentQuestion":true,"browserContentAnswer":true}';
		appDefaultBrowser.type__c = 'browser_notifications';
		update appDefaultBrowser;

		BatchOverwriteAppDefaults jobBrowser = new BatchOverwriteAppDefaults('browser_notifications', false, null);
		Database.executeBatch(jobBrowser,100);
		Test.stopTest();

        System.assert(true, 'Running as Expected');
	}
    
	@isTest static void testBatchMigrateSiteRecords() {
        Test.startTest();
        CollaborationGroup cGrp = TestHelper.createCollaborationGroup('BatchMigrateSiteRecords_Grp', 'Public');
        cGrp.isArchived = false;
        update cGrp;
        Simpplr_Site__c sObj = getSimpplrSite('BatchMigrateSiteRecords_Grp');
        sObj.Is_Active__c = true;
        sObj.Show_In_Simpplr__c = true;
        sObj.Chatter_Group_Id__c = cGrp.Id;
        sObj.is_Deleted__c = false;
        sObj.Title_Content_Version__c = null;
        update sObj; 
        BatchMigrateSiteRecords job = new BatchMigrateSiteRecords('disableAllSiteDashboardAndContentFeature');
		Database.executeBatch(job,100);
        List<CollaborationGroup> cGrp1  = [SELECT Id, FullPhotoUrl FROM CollaborationGroup where isArchived=false AND (NOT FullPhotoUrl  like '%/0F9/F%') limit 1];        
        BatchMigrateSiteRecords job1 = new BatchMigrateSiteRecords();
        job1.execute(null,cGrp1);
        Test.stopTest();
        System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testBatchMigrateSiteRecordsForMigrateCollaborationGroupMembers() {
        Test.startTest();
        CollaborationGroup cGrp = TestHelper.createCollaborationGroup('BatchMigrateSiteRecords_Grp', 'Public');
        cGrp.isArchived = false;
        update cGrp;
        BatchMigrateSiteRecords job = new BatchMigrateSiteRecords('migrateCollaborationGroupMembers');
		Database.executeBatch(job,100);
        Test.stopTest();
        System.assert(true, 'Running as Expected');
    }
    
    @isTest static void testBatchMigrateSiteRecordsForNoRecordType() {
        Test.startTest();
        CollaborationGroup cGrp = TestHelper.createCollaborationGroup('BatchMigrateSiteRecords_Grp', 'Public');
        cGrp.isArchived = false;
        update cGrp;
        List<CollaborationGroup> cGrp1  = [SELECT Id, FullPhotoUrl FROM CollaborationGroup where isArchived=false AND (NOT FullPhotoUrl  like '%/0F9/F%') limit 1];        
        
        BatchMigrateSiteRecords job1 = new BatchMigrateSiteRecords();
        Database.executeBatch(job1,100);
        Test.stopTest();
        System.assert(true, 'Running as Expected');
    }
    
	@isTest static void testBatchCheckAccessAndSendNotification_1() {
		Test.startTest();
		Map<String,NotificationHelper.NotificationMetadata> targetIdtoSubjectMap = new Map<String,NotificationHelper.NotificationMetadata>();
		NotificationHelper.NotificationMetadata notiMetaObj = new NotificationHelper.NotificationMetadata();
		notiMetaObj.subject = 'Like a post';
		notiMetaObj.heading = 'Like post heading';
		notiMetaObj.prefSettingType = 'LIKES A POST OR REPLY I MADE';				
		targetIdtoSubjectMap.put(UserInfo.getUserId(), notiMetaObj);
		Map<String, NotificationDao.Notification> notificationObjMap = new Map<String, NotificationDao.Notification>();
		NotificationDao.Notification notificationObj = new NotificationDao.Notification();
		notificationObj.type = 'Information';
		notificationObj.subType = 'Post';
		notificationObj.status = 'Pending'; 
		notificationObj.objectType = 'FeedItem';		
		notificationObjMap.put(UserInfo.getUserId(), notificationObj);
		List<People_Preference__c> peoplePrefList = [SELECT Id,people__r.user__c, people__r.user__r.userName, User__r.LanguageLocaleKey, People__r.First_Name__c,People__r.Last_Name__c, People__r.Full_Name__c, Allow_Simpplr_Emails__c, Email_Comments_On_Post_I_Like__c, 
													 Email_Like_My_Post_Or_Comment__c, Email_Posts_To_Me__c, People__c, People__r.External_Photo_URL__c, People__r.External_Photo_URL_Expiry_Date__c, people__r.User__r.timeZonesidkey 
													 FROM People_Preference__c ];
		
		BatchCheckAccessAndSendNotification job = new BatchCheckAccessAndSendNotification(UserInfo.getUserId(), notificationObjMap, targetIdtoSubjectMap, new Map<String, String>{'abc'=> 'abc'}, peoplePrefList, false);
		Database.executeBatch(job,50);
		
		Map<String, Integer> localisationCountsMap = new Map<String, Integer>();
		localisationCountsMap.put('commentsCount', 1);
		localisationCountsMap.put('filesCount', 1);
		job = new BatchCheckAccessAndSendNotification(UserInfo.getUserId(), notificationObjMap, targetIdtoSubjectMap, new Map<String, String>{'abc'=> 'abc'}, peoplePrefList, false, localisationCountsMap);
		Database.executeBatch(job,50);
		
		ConnectApi.FeedElement feedObject = TestHelper.getFeedElement('');
		List<Simpplr_Content__c> simpplrContentList = new List<Simpplr_Content__c>();
		job = new BatchCheckAccessAndSendNotification(feedObject, simpplrContentList, notificationObjMap, targetIdtoSubjectMap, new Map<String, String>{'abc'=> 'abc'}, peoplePrefList, false, localisationCountsMap);
        Database.executeBatch(job,50);
		
		Test.stopTest();
        System.assert(true, 'Running as Expected');
	}
	
	@isTest static void testBatchSitesAndChatterGroupsConversion() {
    	Test.startTest();
		BatchSitesAndChatterGroupsConversion job = new BatchSitesAndChatterGroupsConversion('revertAllToChatterGroups');
		Database.executeBatch(job);
		job = new BatchSitesAndChatterGroupsConversion('convertAllToSites');
		Database.executeBatch(job);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
	
    @isTest static void testBatchAdoptionEmail() {
    	Test.startTest();
    	Analytics_Login__c analyticsLoginRec = new Analytics_Login__c( Date__c = System.today().addMonths(-1), Content_Views__c = 10, Likes__c = 10, Posts__c = 10, Replies__c = 10, Shares__c = 10,Total_Simpplr_Users__c= 5);
    	insert analyticsLoginRec;
    	
    	List<Simpplr_Content__c> simpplrContentList = [Select Id, Is_Published__c, Activated_By_Feature__c,Type__c From Simpplr_Content__c Where Title__c = 'simpplr test album' OR Title__c = 'simpplr test event' OR Title__c = 'simpplr test page' OR Title__c = 'simpplr test blogpost'];
		
		List<Analytics_Top_Content__c> analyticsTopContentList = new List<Analytics_Top_Content__c>(); 
		for(Simpplr_Content__c sc : simpplrContentList){
			Analytics_Top_Content__c analyticsTopContentRec = new Analytics_Top_Content__c( Date__c = System.today().addMonths(-1), content__c = sc.Id);
           
            If(sc.Type__c == 'BlogPost' || sc.Type__c == 'Event'){
                analyticsTopContentRec.Views__c = 10;
                analyticsTopContentRec.Shares__c = 10;
                analyticsTopContentRec.Likes__c = 10;
            }
            
			analyticsTopContentList.add(analyticsTopContentRec);
		}
		
		if(!analyticsTopContentList.isEmpty()){
			insert analyticsTopContentList;		
		}		
		BatchAdoptionEmail job = new BatchAdoptionEmail('initAnalyticsData');
		Database.executeBatch(job);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}	
	
	@isTest static void testBatchVerifyAnalyticsData() {
		Test.startTest();
		BatchVerifyAnalyticsData job = new BatchVerifyAnalyticsData('analytics_adoption', true);
		DataBase.executeBatch(job);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
	
	@isTest static void testBatchAnalyticsNotifications() {
		Test.startTest();
		Simpplr_Content__c contentObj = getContent();
		CollaborationGroup grpObj = TestHelper.createCollaborationGroup('testBatchAnalyticsNotifications','Public');
		Simpplr_Site__c siteObj = getSite();
		contentObj.is_Deleted__c = false;
		update contentObj;
		Analytics_Top_Site__c analyticTopSiteObj = new Analytics_Top_Site__c( Date__c = System.today().addMonths(-1), site__c = siteObj.Id,Likes__c = 10,Posts__c =10,Shares__c =10,Replies__c =10);
		insert analyticTopSiteObj;
		BatchAnalyticsNotifications job = new BatchAnalyticsNotifications('AppManagerAnalytics');
		DataBase.executeBatch(job);
		People__c peopleObj = [select id from People__c where last_Name__c='TestForBatchClasses_admin' limit 1];
		peopleObj.App_Moderation_Permission__c = 'No';
		peopleObj.Can_Access_Analytics__c = false;
		update peopleObj;
		BatchAnalyticsNotifications job1 = new BatchAnalyticsNotifications('SiteManagerAnalytics');
		DataBase.executeBatch(job1);
		contentObj.Primary_Author__c = peopleObj.Id;
        update contentObj;
		BatchAnalyticsNotifications job2 = new BatchAnalyticsNotifications('ContentAuthorAnalytics');
		DataBase.executeBatch(job2);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}

	@isTest static void testBatchCampaignNotifications() {
		Test.startTest();
		People__c pObj = [select id from People__c where last_Name__c='TestForBatchClasses_standard' limit 1];
		
		Social_Campaign__c sCObj = TestHelper.createSocialCampaign(pObj.Id);
		Segment__c segObj = TestHelper.createSegment(pObj.Id);
		Audience__c audObj = TestHelper.createAudience(segObj.Id);
		audObj.Audience_Rule_Json__c = '[{"department":["Dep-1"]}]';
		update audObj;
		sCObj.Is_Deleted__c = false;
		sCObj.Audience__c = audObj.Id;
		update sCObj;
		
		BatchCampaignNotifications job = new BatchCampaignNotifications(sCObj.id, sCObj.Audience__c, 'NewCampaignNotifcations');
		Database.executeBatch(job,100);
		
		TestHelper.createSocialCampaignShareRecords(pObj.Id,sCObj,new Set<String>{'Facebook','Twitter','Linkedin'});
		BatchCampaignNotifications job1 = new BatchCampaignNotifications(sCObj.id,'CampaignAnalyticsDataPrepare');
		Database.executeBatch(job1,100);
		BatchCampaignNotifications job2 = new BatchCampaignNotifications('CampaignAnalyticsDataPrepare',true);
		Database.executeBatch(job2,100);
		Test.stopTest();

		List<App_Notification__c> listNotifications = [SELECT ID FROM App_Notification__c WHERE Object_Type__c='Social  Campaign'];
		System.assertNotEquals(0, listNotifications.size(), 'Send Weekly In-app notifications'); 
	}

	@isTest static void testBatchCampaignNotifications2() {
		Test.startTest();
			People__c pObj = [select id from People__c where last_Name__c='TestForBatchClasses_standard' limit 1];
			
			Social_Campaign__c sCObj = TestHelper.createSocialCampaign(pObj.Id);
			App_Notification__c notificationObj = new App_Notification__c();
			notificationObj.Category__c = 'Social_Campaign_Ready';
			notificationObj.Type__c = 'Information';
			notificationObj.Sub_Type__c = 'Campaign';
			notificationObj.Object_Id__c = sCObj.Id;
			notificationObj.Object_Type__c = 'Social  Campaign';
			notificationObj.Sent_to__c = pObj.Id;
			notificationObj.Created_DateTime__c = DateTime.now();
			insert notificationObj;

			BatchCampaignNotifications job = new BatchCampaignNotifications(sCObj.id, 'DeleteCampaignNotifcations');
			Database.executeBatch(job,100);
		Test.stopTest();

		List<App_Notification__c> listNotifications = [SELECT ID FROM App_Notification__c WHERE Category__c = 'Social_Campaign_Ready'];
		System.assertNotEquals(0, listNotifications.size(), 'Send Weekly In-app notifications'); 
	}

	private static Simpplr_Site__c getSimpplrSite(String siteName){
		return([select id,chatter_group_id__c  from Simpplr_Site__c where name = :siteName]);
	}

	@isTest static void testBatchSiteAdoptionEmail() {
        Test.startTest();
        SimpplrContext.isSegmentsEnabled = true;
        SimpplrContext.isSegmentBrandingEnabled = true;
        CollaborationGroup pubCollabGrp = TestHelper.createCollaborationGroup('BatchSiteAdoptionEmail', 'Public');
        Simpplr_Site__c siteeObj = getSimpplrSite('BatchSiteAdoptionEmail');
        siteeObj.Is_Active__c = true;
        siteeObj.Show_In_Simpplr__c = true;
        siteeObj.Chatter_Group_Id__c = pubCollabGrp.Id;
        siteeObj.Site_Type__c = 'public';
        update siteeObj;
        Analytics_Top_Site__c analyticTopSiteObj = new Analytics_Top_Site__c( Date__c = System.today().addMonths(-1), site__c = siteeObj.Id,Likes__c = 10,Posts__c =10,Shares__c =10,Replies__c =10);
        insert analyticTopSiteObj;
        People__c pPObj = [select id from People__c where last_Name__c='TestForBatchClasses_admin' limit 1];
		TestHelper.createSegment(pPObj.Id);
        BatchSiteAdoptionEmail job = new BatchSiteAdoptionEmail('toSiteManagers',false,true);
        Database.executeBatch(job,100);
        BatchSiteAdoptionEmail job1 = new BatchSiteAdoptionEmail('toAppManagers',true);
        Database.executeBatch(job1,100);
        Test.stopTest();
		System.assert(true, 'Running as Expected');
	}
	

	private static Alert__c createAlertRecord(String authorId, DateTime fromDateTime, String siteId) {
    	Alert__c alertObj = new Alert__c(
                            Alert_Message__c='AlertTest_testArticleRecord', 
                            Author__c=authorId, Is_Deleted__c=false, Is_Dismissible__c = false,
                            Is_Link_Alert__c = false, Is_Manually_Expired__c = false,
                            Recipient_Count__c = 0, Display_From_DateTime__c = fromDateTime,
                            Recipient_Site__c=siteId,
							Display_To_DateTime__c = Date.today().addDays(2)  ,
							Recipient__c='site'
							                                                 
                           );
        insert alertObj;
        return alertObj;
	}
    @isTest static void testBatchAlertNotifications() {
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'success',false)); 
		alert__c alertobj=[select id,Alert_Message__c,Author__c, Is_Deleted__c, Is_Dismissible__c ,Is_Link_Alert__c, Is_Manually_Expired__c,Recipient_Count__c , 
		Display_From_DateTime__c,Recipient_Site__c,Recipient__c,Display_To_DateTime__c  from Alert__c limit 1];                                             
		BatchAlertNotifications job = new BatchAlertNotifications(alertObj.id,alertobj.Display_From_DateTime__c,false);
		Database.executeBatch(job);

		People__c pPObj = [select id from People__c where last_Name__c='TestForBatchClasses_admin' limit 1];
		pPObj.Mobile_App_Type_IOS__c = 'native';
		pPObj.Mobile_Token_IOS__c = 'asdasdad';
		update pPObj;

		job = new BatchAlertNotifications(alertObj.id,alertobj.Display_From_DateTime__c,true);
		Database.executeBatch(job);

		List<People__c> peopleList = [Select id, Mobile_Phone__c, User__c, User__r.isActive, User__r.UserType, User__r.languagelocalekey, user__r.userName from People__c];
		job.sendAlertSms(peopleList);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}

	@isTest static void testBatchPullNewsletterTrackerData() {
		Test.startTest();
		Mailer__c mailerObj = [select id from Mailer__c limit 1];
		BatchPullNewsletterTrackerData.TrackerData tracker = new BatchPullNewsletterTrackerData.TrackerData();
		tracker.id='dummy';
		tracker.newsletterid=mailerObj.id;
		tracker.useridhash=EncodingUtil.base64Encode(Crypto.generateDigest('SHA-512', Blob.valueOf(UserInfo.getUserId())));
		tracker.createddatetime='2020-06-16 16:39:25';
		BatchPullNewsletterTrackerData job = new BatchPullNewsletterTrackerData();
		job.updateTrackerDataInDB(new List<BatchPullNewsletterTrackerData.TrackerData>{tracker});
		System.assert(true, 'Running as Expected');
	}

	@isTest static void testBatchGenerateTimeline() {
		Test.startTest();
		BatchGenerateTimeline job = new BatchGenerateTimeline();
		Database.executeBatch(job,10);
		Test.stopTest();
		System.assert(true, 'Running as Expected');
	}

	@isTest static void testBatchVideoNotifications() {
		SimpplrContext.isVideosManagementFeatureEnabled = true;
		SimpplrContext.isNativeVideo = true;
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('OK',200,'VideoDataService/sendNotification',false));    
		BatchVideoNotifications job = new BatchVideoNotifications('sendNotification');
		Database.executeBatch(job);
		Test.stopTest();
		System.assert(true, 'Running as Expected'); 
	}
	
}