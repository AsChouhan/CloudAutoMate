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
private class NotificationDispatcherTest { 
	
	private static App_Config__c appconfigRecord;
	private static People__c peopleObj;
	private static People_Preference__c peoplePreferenceObj;
	private static People_Preference__c peoplePreferenceObj1;
	private static Simpplr_Content__c simpContentPage;
	private static Simpplr_Content__c simpContentEvent;
	private static Simpplr_Content__c simpContentAlbum;
	private static Simpplr_Content__c privateAlbum;
	private static File__c simpMedia;
	private static User standardUsersPeopleObj;
	private static List<FeedItem> feedItemList;
	private static List<App_Notification__c> notificationList;
	private static List<NotificationDao.Notification> notificationObjList;
	private static NotificationHelper.NotificationMetadata metaData;
	private static NotificationHelper.EmailWrapper emailWrapObj;
	private static List<People_Preference__c> listOfPeoplePreferences;
	private static Simpplr_Site__c publicSiteObj;
	private static Simpplr_Site__c sitePrivateObj;
	
	@testSetup static void setup() {
		
		appconfigRecord = TestHelper.setupAppConfig();
		TestHelper.setupAppDefault();
        peopleObj =  TestHelper.createPeopleRecordForUser(UserContext.id);
        peoplePreferenceObj = TestHelper.createPeoplePreference(peopleObj.Id);
        User userObj = TestHelper.createUser('TestUser_TileServiceTest',null,false);
		peopleObj  = [select id, user__c from People__c where Last_Name__c='TestUser_TileServiceTest' limit 1];
		peoplePreferenceObj1 = TestHelper.createPeoplePreference(peopleObj.Id, peopleObj.User__c);
		
        User userObj2 = TestHelper.createUser('TestUser_TileServiceTest1',userObj,false);
        CollaborationGroup cg = TestHelper.createCollaborationGroup('Test_Group1_TileServiceTest','Public');
        
		TestHelper.createCollaborationGroupMember(cg.id, userObj2.id, 'Admin');
        publicSiteObj = TestHelper.getSiteRecordWithName('Test_Group1_TileServiceTest');
        
		CollaborationGroup cgPrivate = TestHelper.createCollaborationGroup('Test_Group_Private','Private');
		sitePrivateObj = TestHelper.getSiteRecordWithName('Test_Group_Private');
        simpContentPage = TestHelper.createContent('Test_Page', 'Page', 'Approved', peopleObj, publicSiteObj);
		simpContentEvent = TestHelper.createContent('Test_Event', 'Event', 'Approved', peopleObj, publicSiteObj);
        simpContentAlbum = TestHelper.createContent('Test_Album', 'album', 'Approved', peopleObj, publicSiteObj);
		privateAlbum = TestHelper.createContent('Private_Album', 'private album', 'Approved', peopleObj, sitePrivateObj);
        File__c simpMediaFile = TestHelper.createContentTitleImage(simpContentAlbum.Id);
        TestHelper.createSimpplrNotification('Dummy', peopleObj.id,null,'Like',simpContentPage.id,null);
       
        FeedItem feedItemObj;
    	FeedComment feedCommentObj;
        FeedComment feedCommentObj2;
        System.runAs(userObj) {
    		feedItemObj = TestDataHandler.createFeedItem(userObj.id);
			TestHelper.createFeedLike(feedItemObj.id, feedItemObj.id);
    		feedCommentObj = TestDataHandler.createFeedComment(feedItemObj.id);
			feedCommentObj2 = TestDataHandler.createFeedCommentForSlackPlaceholderReply(feedItemObj.id);
			TestHelper.createFeedLike(feedItemObj.id, feedCommentObj.id);
    	}  	
    	FeedItem testfeed = new FeedItem(Body = 'HelloThere', ParentId = userObj.id, Title = 'FileName');
    	insert testfeed;
		TestHelper.createFeedLike(testfeed.id, testfeed.id);

		Csv_Download_Request__c csvReqObj = new Csv_Download_Request__c();
		csvReqObj.csv_url__c = 'url';
		csvReqObj.People__c = peopleObj.Id;
		insert csvReqObj;
    	    	
    }
    
     @isTest static void init() {         	
     	notificationObjList = new List<NotificationDao.Notification>(); 
        peopleObj  = [select id, User__c, First_Name__c, Last_Name__c, Full_Name__c, User__r.timezonesidkey, User__r.UserName, User__r.languagelocalekey from People__c where Last_Name__c='TestUser_TileServiceTest' limit 1];
		standardUsersPeopleObj = [select id,lastname,firstname from User where lastName='TestUser_TileServiceTest' limit 1];
        simpContentPage = [select id,Title__c,Type__c,site__c,site__r.Chatter_Group_Id__c, createdById, Primary_Author__c,  Primary_Author__r.User__c from Simpplr_Content__c where Title__c='Test_Page' limit 1];   
		simpContentEvent = [select id,Title__c,Type__c,site__c,site__r.Chatter_Group_Id__c, createdById, Primary_Author__c,  Primary_Author__r.User__c from Simpplr_Content__c where Title__c='Test_Event' limit 1];   
        simpContentAlbum = [select id,Title__c,Last_Edited_DateTime__c,Publish_Start_DateTime__c,Event_Location__c,Event_Is_All_Day__c,Event_Start_Datetime__c,Event_End_DateTime__c,Event_TimezoneSidKey__c,Type__c,site__c, site__r.Name, createdById, Primary_Author__c,  Primary_Author__r.User__c, Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c from Simpplr_Content__c where Title__c='Test_Album' limit 1];
        privateAlbum = [select id,Title__c,Type__c,site__c, site__r.Name, createdById, Primary_Author__c,  Primary_Author__r.User__c, Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c from Simpplr_Content__c where Title__c='Private_Album' limit 1];
		simpMedia = [Select Id, Is_Deleted__c, Is_Title_Image__c, Simpplr_Content__c, Title_Image_Type__c, 
					MIME_Type__c, Likes__c, Author__c, Author__r.User__c 
					From File__c LIMIT 1];
        
        feedItemList = [Select f.Type, f.Title, f.SystemModstamp,  f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, 
                       f.CommentCount, f.Body From FeedItem f limit 1];    
        listOfPeoplePreferences = [SELECT Id,people__r.user__c,people__r.user__r.userName, people__r.User_Hash__c,People__r.First_Name__c, People__r.Full_Name__c,People__r.About__c, Allow_Simpplr_Emails__c,  Email_Comments_After_Me__c, Email_Comments_On_My_Post__c, Email_Comments_On_Post_I_Like__c, 
																Email_Endorses_Me__c, Email_Follows_Me__c, Email_Like_My_Post_Or_Comment__c, Email_Posts_To_Me__c, 
																Email_My_Content_Post__c, Email_My_Content_Like_Or_Share__c,
																Email_Shares_My_Post__c, People__c,people__r.External_Photo_URL__c,User__r.languagelocalekey,
																people__r.user__r.timeZonesidkey, user__r.timeZonesidkey, People__r.External_Photo_URL_Expiry_Date__c,
																people__r.User__r.languagelocalekey, People__r.Last_Name__c
																FROM People_Preference__c limit 1];	
        publicSiteObj = TestHelper.getSiteRecordWithName('Test_Group1_TileServiceTest');
		sitePrivateObj = TestHelper.getSiteRecordWithName('Test_Group_Private');
		PageReference pgRef = Page.app;
        Test.setCurrentPage(pgRef);
        System.assert(true,'Running as expected');
    }
    
      @isTest static void testSendMemberAddedNotification() {
        init();
        List<People__c> peopleList = null;
        NotificationDispatcher.sendMemberAddedNotification(sitePrivateObj.Id, sitePrivateObj.Name,peopleList);
        peopleList=[select id, User__c, First_Name__c, Last_Name__c, Full_Name__c, User__r.timezonesidkey, User__r.UserName, User__r.languagelocalekey from People__c where Last_Name__c='TestUser_TileServiceTest' limit 1];
        NotificationDispatcher.sendMemberAddedNotification(sitePrivateObj.Id, sitePrivateObj.Name,peopleList);
        List<App_Notification__c> notificationList = [Select Object_Id__c from App_Notification__c WHERE Snippet__c =:sitePrivateObj.Name and Simpplr_Site__c=:sitePrivateObj.Id limit 1];
        System.assertEquals(notificationList[0].Object_Id__c, peopleList[0].Id, 'successful');
    }
    
     @isTest static void testSendPublicSiteRequestNotification() {
		Test.startTest();
    	init();
     	notificationList = [select Object_Id__c from App_Notification__c WHERE Is_Deleted__c = false LIMIT 1];
		NotificationDispatcher.sendPublicSiteRequestNotification(notificationList[0].Object_Id__c,publicSiteObj.Id,publicSiteObj.Name,new List<People__c>{peopleObj});
		List<Ungrouped_Notification__c> obj = [Select Object_Id__c from Ungrouped_Notification__c WHERE Snippet__c =:publicSiteObj.Name and Simpplr_Site__c=:publicSiteObj.Id limit 1];
        System.assertEquals(obj[0].Object_Id__c, notificationList[0].Object_Id__c, 'successful');
        Test.stopTest();
     }

    @isTest static void testSendPublicSiteAutomaticRequestApprovedNotification() {
		Test.startTest();
    	init();
     	notificationList = [select Object_Id__c from App_Notification__c WHERE Is_Deleted__c = false LIMIT 1];
		NotificationDispatcher.sendPublicSiteAutomaticRequestApprovedNotification(notificationList[0].Object_Id__c,publicSiteObj.Id,publicSiteObj.Name,new List<People__c>{peopleObj});
     	List<App_Notification__c> obj = [Select Object_Id__c from App_Notification__c WHERE Snippet__c =:publicSiteObj.Name and Simpplr_Site__c=:publicSiteObj.Id limit 1];
        System.assertEquals(obj[0].Object_Id__c, notificationList[0].Object_Id__c, 'successful');
        Test.stopTest();
     }
    
   
    @isTest static void testGetRSVPConfirmedNotificationEmailBody(){
        init();
        String userLanguage = Utility.getSimpplrLanguageLocaleKey(listOfPeoplePreferences[0].User__r.languagelocalekey);
        Set<String> localeSet = new Set<String>();
        localeSet.add('en_US');
        localeSet.add(userLanguage);
        simpContentAlbum.Event_TimezoneSidKey__c='America/Los_Angeles';
        simpContentAlbum.Event_Start_DateTime__c= DateTime.now();
        Date nextWeekDate = Date.today().addDays(7);
        simpContentAlbum.Event_Is_All_Day__c=true;
        simpContentAlbum.Event_End_DateTime__c=DateTime.newInstance(nextWeekDate.year(), nextWeekDate.month(), nextWeekDate.day(), 0 ,0,0);
        simpContentAlbum.Event_Location__c='America';
        update simpContentAlbum;
        LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
		String result=new NotificationDispatcher().getRSVPConfirmedNotificationEmailBody(simpContentAlbum,userLanguage,listOfPeoplePreferences[0]);        
        System.assertEquals(true, result.contains('RESPONSIVE AND MOBILE FRIENDLY STYLES'), 'successful');
    }
    
    @isTest static void testGetRSVPRemovedNotificationEmailBody(){
        init();
        String userLanguage = Utility.getSimpplrLanguageLocaleKey(listOfPeoplePreferences[0].User__r.languagelocalekey);
        Set<String> localeSet = new Set<String>();
        localeSet.add('en_US');
        localeSet.add(userLanguage);
        simpContentAlbum.Event_TimezoneSidKey__c='America/Los_Angeles';
        simpContentAlbum.Event_Start_DateTime__c= DateTime.now();
        Date nextWeekDate = Date.today().addDays(7);
        simpContentAlbum.Event_Is_All_Day__c=true;
        simpContentAlbum.Event_End_DateTime__c=DateTime.newInstance(nextWeekDate.year(), nextWeekDate.month(), nextWeekDate.day(), 0 ,0,0);
        simpContentAlbum.Event_Location__c='America';
        simpContentAlbum.Publish_Start_DateTime__c=DateTime.now();
        simpContentAlbum.Last_Edited_DateTime__c=DateTime.now();
        update simpContentAlbum;
        LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
		String result=new NotificationDispatcher().getRSVPRemovedNotificationEmailBody(simpContentAlbum,listOfPeoplePreferences[0],userLanguage,'test');        
        System.assertEquals(true, result.contains('RESPONSIVE AND MOBILE FRIENDLY STYLES'), 'successful');
    }
    
    @isTest static void testGetRespondentsEmailBody(){
        init();
        String userLanguage = Utility.getSimpplrLanguageLocaleKey(listOfPeoplePreferences[0].User__r.languagelocalekey);
        Set<String> localeSet = new Set<String>();
        localeSet.add('en_US');
        localeSet.add(userLanguage);
        LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
        simpContentAlbum.Event_TimezoneSidKey__c='America/Los_Angeles';
        simpContentAlbum.Event_Start_DateTime__c= DateTime.now();
        Date nextWeekDate = Date.today().addDays(7);
        simpContentAlbum.Event_Is_All_Day__c=true;
        simpContentAlbum.Event_End_DateTime__c=DateTime.newInstance(nextWeekDate.year(), nextWeekDate.month(), nextWeekDate.day(), 0 ,0,0);
        simpContentAlbum.Event_Location__c='America';
        update simpContentAlbum;
        List<String> respondentNameList= new List<String>();
        respondentNameList.add(listOfPeoplePreferences[0].People__r.Full_Name__c);
        String result=new NotificationDispatcher().getRespondentsEmailBody(simpContentAlbum,userLanguage,listOfPeoplePreferences[0],respondentNameList,respondentNameList.size());    
    	System.assertEquals(true, result.contains('RESPONSIVE AND MOBILE FRIENDLY STYLES'), 'successful');
    }
	
    @isTest static void testGetEventActionNotificationEmailBody(){
        Test.startTest();
    	init();
        String userLanguage = Utility.getSimpplrLanguageLocaleKey(listOfPeoplePreferences[0].User__r.languagelocalekey);
        Set<String> localeSet = new Set<String>();
        localeSet.add('en_US');
        localeSet.add(userLanguage);
        simpContentAlbum.Event_TimezoneSidKey__c='America/Los_Angeles';
        simpContentAlbum.Event_Start_DateTime__c= DateTime.now();
        Date nextWeekDate = Date.today().addDays(7);
        simpContentAlbum.Event_Is_All_Day__c=true;
        simpContentAlbum.Event_End_DateTime__c=DateTime.newInstance(nextWeekDate.year(), nextWeekDate.month(), nextWeekDate.day(), 0 ,0,0);
        simpContentAlbum.Event_Location__c='America';
        simpContentAlbum.Publish_Start_DateTime__c=DateTime.now();
        simpContentAlbum.Last_Edited_DateTime__c=DateTime.now();
        update simpContentAlbum;
        LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
        String result=new NotificationDispatcher().getEventActionNotificationEmailBody(simpContentAlbum,listOfPeoplePreferences[0],userLanguage,'eventUnpublished',false);
		System.assertEquals(true, result.contains('RESPONSIVE AND MOBILE FRIENDLY STYLES'), 'successful');
		result=new NotificationDispatcher().getEventActionNotificationEmailBody(simpContentAlbum,listOfPeoplePreferences[0],userLanguage,'eventDeleted',false);
		System.assertEquals(true, result.contains('RESPONSIVE AND MOBILE FRIENDLY STYLES'), 'successful');
        result=new NotificationDispatcher().getEventActionNotificationEmailBody(simpContentAlbum,listOfPeoplePreferences[0],userLanguage,'eventUpdated',false);
		System.assertEquals(true, result.contains('RESPONSIVE AND MOBILE FRIENDLY STYLES'), 'successful');
        Test.stopTest();    
    }
    
    @isTest static void testGetSharepointUpgradeInProgressEmailBody(){
        Test.startTest();
    	init();
        String result=NotificationDispatcher.getSharepointUpgradeInProgressEmailBody();
        System.assertEquals(true, result.contains('html'), 'successful');
        Test.stopTest(); 
    }
    
    @isTest static void testSendNotificationForPublishedOnYourBehalf(){
        Test.startTest();
    	init();
        NotificationDispatcher.sendNotificationForPublishedOnYourBehalf(simpContentAlbum);
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
     @isTest static void testSendPublicSiteRequestApprovalEmail() {
        Test.startTest();
		init();	
     	NotificationDispatcher.sendPublicSiteRequestApprovalEmail(publicSiteObj.Name,publicSiteObj.Id,peopleObj.id);
     	Test.stopTest();
        System.assert(true,'Running as expected');
		
     }
    
    @isTest static void testSendPrivateSiteRequestApprovalEmail() {
        Test.startTest();
		init();	
     	NotificationDispatcher.sendPrivateSiteRequestApprovalEmail(sitePrivateObj.Name,sitePrivateObj.Id,standardUsersPeopleObj.id);
     	Test.stopTest();
        System.assert(true,'Running as expected');
		
     } 
    
    @isTest static void testSendSPUpgradeDoneEmailNotification(){
        Test.startTest();
    	init();
        NotificationDispatcher.sendSPUpgradeDoneEmailNotification();
        Test.stopTest(); 
        System.assert(true,'Running as expected');
    }
   

	@isTest static void testFeedTriggers() {
		Test.startTest();
		FeedComment feedCommentObj = [select id from FeedComment Limit 1];
		update feedCommentObj;
        
        //Update to update FeedCache again
		update feedCommentObj;
        
		delete feedCommentObj;

		FeedItem feedItemObj = [select id from FeedItem Limit 1];
		update feedItemObj;

		//Update to update FeedCache again
		update feedItemObj;
		delete feedItemObj;
		Test.stopTest();
        System.assert(true,'Running as expected');
	}
    
    @isTest static void testSubscriptionNotifications(){
		Test.startTest();
        init();
        App_Config__c appConfigRec = [Select Id, Segment_Enabled__c, Segment_Column_Name__c from App_Config__c Limit 1][0];
		appConfigRec.Segment_Enabled__c = true;
		appConfigRec.Segment_Column_Name__c = 'Country__c';
		update appConfigRec; 
		People__c peopleRec = [Select id from People__c Limit 1]; 
        Segment__c segmentRecord = TestHelper.createSegment(peopleRec.Id);
		peopleRec.Country__c='India';
		peopleRec.Segment_Attribute_Value__c='India';
		peopleRec.Segment__c=segmentRecord.id;
		update peopleRec;
        Audience__c audienceRecord = TestHelper.createAudience(segmentRecord.Id); 
        Subscription__c subscriptionRecord =  TestHelper.createSubscription(audienceRecord.Id, peopleRec.Id, 'Site');   
        List<Subscription_Entity__c> listOfSubscriptionEntity =  TestHelper.createPrivateSiteSubscriptionEntity(subscriptionRecord.Id, sitePrivateObj.Id);        
        listOfSubscriptionEntity = [Select Id, Status__c, Subscription__c, Site__c, Site__r.Name, Site__r.Chatter_Group_Id__c, People__r.User__c FROM Subscription_Entity__c
                                    where id=:listOfSubscriptionEntity];
        //segments 
        NotificationDispatcher.sendNotificationToNewSegmentManagers(segmentRecord.Id, new Set<String>{PeopleRec.Id});
		NotificationDispatcher.sendEmailNotificationToNewSegmentManagers(segmentRecord.Id, new Set<String>{PeopleRec.Id});
        //subscriptions
        NotificationDispatcher.sendPendingSubscriptionNotification(listOfSubscriptionEntity);
        NotificationDispatcher.sendPendingSubscriptionNotificationEmail(listOfSubscriptionEntity);
		NotificationDispatcher.sendSubscriptionApprovalRejectNotification(sitePrivateObj.Id, sitePrivateObj.Name, subscriptionRecord.Id, 'rejected');
		
		App_Notification__c notificationObj = [select id, status__c from App_Notification__c where Is_Deleted__c = false AND Object_Id__c=:subscriptionRecord.Id limit 1];
		notificationObj.Status__c = 'Pending';
		update notificationObj;
        NotificationDispatcher.sendSubscriptionApprovalRejectNotification(sitePrivateObj.Id, sitePrivateObj.Name, subscriptionRecord.Id, 'approved');        
        
		Test.stopTest();
        System.assert(true,'Running as expected'); 	
    } 
    
        
      @isTest static void testGetEmailNotificationDetails(){
		Test.startTest();
        init();        
        
        metaData = createNotiMeta(feedItemList[0].id, null, null, null,null);
        emailWrapObj = createEmailWrapper(feedItemList[0].id, String.valueOf(UserContext.id), null, null, null,null);
                
        NotificationHelper.EmailWrapper emailWrapperObj = new NotificationHelper.EmailWrapper();         
        emailWrapperObj.createdByName = 'test';  
        Map<String, Simpplr_Content__c> simpplrContentMap = new Map<String, Simpplr_Content__c>();  
        String targetUserId = UserInfo.getUserId();
        FeedItem feedItemObj = feedItemList[0];    
          
        Recognition__c recognitionRecord = new Recognition__c();
        recognitionRecord.Feed_Element_Id__c = feedItemObj.Id;
        recognitionRecord.Award_Name__c = 'shout-out';
        recognitionRecord.Award_Id__c = 'hsggj-ahhsg-whwh';
        recognitionRecord.Award_receviers__c = peopleObj.Id;
        recognitionRecord.Award_Giver__c = peopleObj.Id;
        insert recognitionRecord;
        
																
	    User userObject1 = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];        
        simpplrContentMap.put(userObject1.id, simpContentPage);      									
        Map<String,People_Preference__c> peoplePreferMap = new Map<String,People_Preference__c>();
        peoplePreferMap.put(listOfPeoplePreferences[0].people__r.user__c,listOfPeoplePreferences[0]);
		NotificationDispatcher.initLangKeyValueMap(listOfPeoplePreferences);
        String feedCommentId = null;
        String feedParentId = null;
  				
        
        List<NotificationHelper.EmailCommentWrapper> commentList = getCommentList();
        
    	Map<String, String> commentOwnerIdToExtPhotoUrlMap = new Map<String, String>{commentList[0].createdById=>null};
        NotificationDispatcher.getEmailNotificationDetails(metaData,simpplrContentMap,targetUserId,feedItemObj,peoplePreferMap);
        metaData.isRecognition = true;
        NotificationDispatcher.getEmailNotificationDetails(metaData,simpplrContentMap,targetUserId,feedItemObj,peoplePreferMap);
		NotificationHelper.BrandingInfo brandingInfo =  EmailUtility.getBrandingInfo4People(null);       
        NotificationDispatcher.getPostLikeEmailWithTemplate(emailWrapObj,feedItemList[0].id,listOfPeoplePreferences,brandingInfo);
        NotificationDispatcher.sendFeedItemNotificationsAndEmail(feedItemList,'origin');
        NotificationDispatcher.sendNotifications(notificationObjList);        
        NotificationDispatcher.getParentSiteObj(simpContentPage.site__r.Chatter_Group_id__c);
        NotificationDispatcher.viewLink(feedItemList[0].id);
        NotificationDispatcher.getPrimaryCommentTemplate(commentList[0],feedItemList[0].id, commentOwnerIdToExtPhotoUrlMap, brandingInfo);
        NotificationDispatcher.getPrimaryCommentBody(commentList,feedItemList[0].id, commentOwnerIdToExtPhotoUrlMap, brandingInfo);
		Test.stopTest();
        System.assert(true,'Running as expected');
    } 
  	
    @isTest static void testContent() {  
		Test.startTest();
    	init();
		ConnectApi.FeedElement feedObj = TestHelper.getFeedElement(null);
    	NotificationDispatcher.sendEmailForContentModeration(simpContentAlbum);
    	NotificationDispatcher.sendEmailForContentRejection(simpContentAlbum.Id, 'reject');
    	NotificationDispatcher.sendEmailForContentApproval(simpContentAlbum.Id);
    	NotificationDispatcher.sendEmailForContentShare(simpContentPage, 'url', feedObj);
		NotificationDispatcher.sendEmailForContentShare(simpContentEvent, 'url', feedObj);
		NotificationDispatcher.sendEmailForContentShare(simpContentAlbum, 'url', feedObj);
    	NotificationDispatcher.sendNotificationForContentShare(simpContentAlbum, feedObj);
		NotificationDispatcher.sendNotificationForContentLike(simpContentAlbum);
		NotificationDispatcher.sendEmailForContentLike(simpContentPage);
		NotificationDispatcher.sendEmailForContentLike(simpContentEvent);
		NotificationDispatcher.sendEmailForContentLike(simpContentAlbum);
		Social_Campaign__c campaignObj = new Social_Campaign__c(People__c = UserContext.peopleId);
        campaignObj.URL_Preview_Json__c = '{"title" : "Simpplr 3 Minute Demo"}';
		NotificationDispatcher.sendNotificationForCampaignFeedShare(campaignObj, feedObj, publicSiteObj.Chatter_Group_Id__c);
		NotificationDispatcher.sendNotificationForContentAuthorChange(simpContentAlbum);
		Test.stopTest();
        System.assert(true,'Running as expected');
    } 
    
    @isTest static void testMediaNotifications() {  
		Test.startTest();
    	init();
    	NotificationDispatcher.sendEmailForMediaShare(simpMedia, simpContentAlbum,'abc');
		NotificationDispatcher.sendEmailForMediaShare(simpMedia, privateAlbum,'abc');
    	NotificationDispatcher.sendNotificationForMediaShare(simpMedia, simpContentAlbum,'abc');
		NotificationDispatcher.sendNotificationForMediaLike(simpMedia,simpContentAlbum);
		NotificationDispatcher.sendEmailForMediaLike(simpMedia,simpContentAlbum);
		NotificationDispatcher.sendEmailForContentPromote(listOfPeoplePreferences, simpContentAlbum, 'Content', null);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }     	
    
    @isTest static void testSendOnBoardMustReadsEmail() {  
		Test.startTest();
    	init();
		TestHelper.createMustReadAudit(simpContentPage.id, 'everyone', UserContext.peopleId);
		TestHelper.createMustReadAudit(simpContentEvent.id, 'everyone', UserContext.peopleId);
		TestHelper.createMustReadAudit(simpContentAlbum.id, 'everyone', UserContext.peopleId);
    	NotificationDispatcher nd = new NotificationDispatcher();
    	nd.sendOnBoardMustReadsEmail(peopleObj);
		Test.stopTest();
        System.assert(true,'Running as expected');
    } 
    
    @isTest static void testSendNotificationForMakeOwner() {  
		Test.startTest();
    	init();
    	NotificationDispatcher.sendNotificationForMakeOwner(UserContext.Id, sitePrivateObj.Id);
		Test.stopTest();
        System.assert(true,'Running as expected');
    } 
    
    @isTest static void testSendNotificationForMakeManager() { 
		Test.startTest(); 
    	init();
    	NotificationDispatcher.sendNotificationForMakeManager(UserContext.Id, sitePrivateObj.Id, 'Made_Site_Manager');
		Test.stopTest();
        System.assert(true,'Running as expected');
    }    
    
    @isTest static void testSendNotificationForMakeContentManager() { 
		Test.startTest(); 
    	init();
    	NotificationDispatcher.sendNotificationForMakeManager(UserContext.Id, sitePrivateObj.Id, 'Made_Site_Content_Manager');
		Test.stopTest();
        System.assert(true,'Running as expected');
    }    
    
	@isTest static void testSendNotificationForFollow() { 
		Test.startTest(); 
    	init();
		NotificationDispatcher.sendNotificationForFollow(UserContext.Id);
		Test.stopTest();
        System.assert(true,'Running as expected');
    } 
    
    @isTest static void testSendFeedItemNotificationsAndEmail() {    	
		Test.startTest();
    	feedItemList = [Select f.Type, f.Title, f.SystemModstamp,  f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	NotificationDispatcher.sendFeedItemNotificationsAndEmail(feedItemList, null);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testNotifyForEmployeeAdvocacyAccess() {    
		Test.startTest();	
		NotificationDispatcher.notifyForEmployeeAdvocacyAccess(new Set<String>{UserContext.peopleId});
		Test.stopTest();
        System.assert(true,'Running as expected');
    }   

	@isTest static void testSendNotificationForGrantingNewsletterAccess() {   
		Test.startTest();
		init();
		Set<String> userIdSet = new Set<String>{UserInfo.getuserId(), peopleobj.User__c};
    	NotificationDispatcher.sendNotificationForGrantingNewsletterAccess(userIdSet, 
								new Map<String, List<CollaborationGroupMember>>(), new Map<String, String>());

		CollaborationGroupMember cgm = new CollaborationGroupMember(MemberId=UserInfo.getuserId());
		Map<String, List<CollaborationGroupMember>> userIdWithCollabGrpMemberMap = new Map<String, List<CollaborationGroupMember>>();
        userIdWithCollabGrpMemberMap.put(UserInfo.getuserId(), new List<CollaborationGroupMember>{cgm});
		NotificationDispatcher.sendNotificationForGrantingNewsletterAccess(new Set<String>(), 
								userIdWithCollabGrpMemberMap, new Map<String, String>());
		Test.stopTest();
        System.assert(true,'Running as expected');
    }   
    
    @isTest static void testSendNotificationForAddInAlbum() {    	
		Test.startTest();
		init();
    	NotificationDispatcher.sendNotificationForAddInAlbum(privateAlbum, 10, 10);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }      
    
    @isTest static void testSendFeedItemNotificationsAndEmailOnUpdate() {    	
		Test.startTest();
    	feedItemList = [Select f.Type, f.Title, f.SystemModstamp,  f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	Set<String>targertUserId = new Set<String>();
		targertUserId.add(UserInfo.getUserId());
	
    	NotificationDispatcher.sendFeedItemNotificationsAndEmailOnUpdate(feedItemList[0].Id, targertUserId);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }

	@isTest static void testContentFeedback() { 
		Test.startTest();
		init();
		NotificationDispatcher.sendNotificationForContentFeedback(privateAlbum.id, 'Album', false, simpContentAlbum.site__c,'Test Comment', simpContentAlbum.title__c);
		Test.stopTest();
        System.assert(true,'Running as expected'); 
	}
   
    @isTest static void testSendPrivateSiteRequestNotification() {
		Test.startTest();
    	init();
     	notificationList = [select Object_Id__c from App_Notification__c WHERE Is_Deleted__c = false LIMIT 1];
		NotificationDispatcher.sendPrivateSiteRequestNotification(notificationList[0].Object_Id__c,publicSiteObj.Id,publicSiteObj.Name,new List<People__c>{peopleObj});
     	NotificationDispatcher.sendPrivateSiteRequestNotificationEmail(notificationList[0].Object_Id__c,sitePrivateObj.Id,sitePrivateObj.Name,new Set<Id>{peopleObj.User__c});
     	Test.stopTest();
        List<Ungrouped_Notification__c> obj = [Select Object_Id__c from Ungrouped_Notification__c WHERE Snippet__c =:publicSiteObj.Name and Simpplr_Site__c=:publicSiteObj.Id limit 1];
        System.assertEquals(obj[0].Object_Id__c, notificationList[0].Object_Id__c, 'successful');
		
     }          
  
      @isTest static void testSendNotificationEmailForEventInviteMore() {
      	Test.startTest();
		init();
     	notificationList = [select Object_Id__c from App_Notification__c WHERE Is_Deleted__c = false limit 1];  
     	new NotificationDispatcher().sendNotificationEmailForEventInviteMore(simpContentPage.Title__c,new Set<String>{peopleobj.id},notificationList);
     	Test.stopTest();
		System.assert(true,'Running as expected');
     }
     
    @isTest static void testSendPrivateSiteRequestApprovalEmail1() {
        Test.startTest();
		init();	
     	NotificationDispatcher.sendPrivateSiteRequestApprovalEmail(publicSiteObj.Name,publicSiteObj.Id,peopleObj.id);
     	Test.stopTest();
		System.assert(true,'Running as expected');
     } 
     
    @isTest static void testInsertLikeOfComment() {
		Test.startTest();
    	standardUsersPeopleObj = [select id,lastname,firstname from User where lastName='TestUser_TileServiceTest' limit 1];
    	feedItemList = [Select (select id from feedcomments),f.Type, f.Title, f.SystemModstamp, f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	NotificationDispatcher.insertLikeOfComment(String.valueOf(feedItemList[0].feedcomments[0].id),String.valueOf(feedItemList[0].id),standardUsersPeopleObj.id);
        NotificationDispatcher.insertLikeOfFeedpost(String.valueOf(feedItemList[0].id),standardUsersPeopleObj.id);
        Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSendFeedCommentNotificationsAndEmail() {    	
		Test.startTest();
    	feedItemList = [Select (Select  RelatedRecordId, ParentId,  IsDeleted, InsertedById, Id, FeedItemId, CreatedDate, CreatedById, CommentType, CommentBody From FeedComments ),f.Type, f.Title, f.SystemModstamp, f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	NotificationDispatcher.sendFeedCommentNotificationsAndEmail(feedItemList[0].feedcomments, null, false);
		NotificationDispatcher.sendFeedCommentNotificationsAndEmail(feedItemList[0].feedcomments, UserContext.Id, false);
		Test.stopTest();
        System.assert(true,'Running as expected'); 
    }
    
    @isTest static void testSendFeedCommentNotificationsAndEmailOnUpdate() {    
		Test.startTest();
		feedItemList = [Select (Select  RelatedRecordId, ParentId,  IsDeleted, InsertedById, Id, FeedItemId, CreatedDate, CreatedById, CommentType, CommentBody From FeedComments ),f.Type, f.Title, f.SystemModstamp, f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
		Set<String>targertUserId = new Set<String>();
		targertUserId.add(UserInfo.getUserId());
		NotificationDispatcher.sendFeedCommentNotificationsAndEmailOnUpdate(feedItemList[0].feedcomments[0].Id, targertUserId);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSendCommentLikeNotificationAndEmail() {
    	Test.startTest();
    	feedItemList = [Select (select id from feedcomments),f.Type, f.Title, f.SystemModstamp, f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
		update feedItemList[0].feedcomments;
    	NotificationDispatcher.sendCommentLikeNotificationAndEmail(String.valueOf(feedItemList[0].feedcomments[0].id),String.valueOf(feedItemList[0].id));
        Test.stopTest();
		System.assert(true,'Running as expected');
    }
    
    @isTest static void testSendPollPostNotificationAndEmail() {
    	Test.startTest();
    	feedItemList = [Select (select id from feedcomments),f.Type, f.Title, f.SystemModstamp,  f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	NotificationDispatcher.sendPollPostNotificationAndEmail(String.valueOf(feedItemList[0].id));
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testSendPostLikeNotificationAndEmail() {
    	Test.startTest();
		init();
    	feedItemList = [Select f.Type, f.Title, f.SystemModstamp,  f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	NotificationDispatcher.sendPostLikeNotificationAndEmail(feedItemList[0].id);
		FeedItem contentFeedObj = TestDataHandler.createFeedItem(simpContentAlbum.id);
		NotificationDispatcher.sendPostLikeNotificationAndEmail(contentFeedObj.id);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
     @isTest static void testSendEmailForFollow() {   
		Test.startTest(); 	
    	User userObject = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];
    	NotificationDispatcher.sendEmailForFollow(userObject.id);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testNewsletter() {
		Test.startTest();   
    	init();
    	NotificationDispatcher.sendEmailForOnholdNewsletter(peopleObj.id, 'title', 'newsLetterId', 'Unpublished Data'); 	
        NotificationDispatcher.sendNotificationForOnholdNewsletter(peopleObj.id,'newsletterId','Unpublished Data');
		Test.stopTest();
        System.assert(true,'Running as expected');
    }
    
    @isTest static void testEndorsement() {   
		Test.startTest();
    	init();
		List<People__c> peopleList = [select id, user__c, name, Full_Name__c, Last_Name__c, External_Photo_URL__c, External_Photo_URL_Expiry_Date__c, About__c from People__c where Last_Name__c IN ('TestUser_TileServiceTest', 'TestUser_TileServiceTest1') LIMIT 2];
		NotificationDispatcher.sendNotificationForEndorsement(peopleList[0].id, peopleList[1].id, 'topicId', 'topicName');
    	NotificationDispatcher.sendEmailForEndorsement(peopleList[0], peopleList[1], new Map<String, String>{'key' => 'value'});  	
		Test.stopTest();
        System.assert(true,'Running as expected');
    }    
    
    @isTest static void testGetEmailHtmlBodyWithTemplate() {
		Test.startTest();
    	init();
    	feedItemList = [Select f.Type, f.Title, f.SystemModstamp,  f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	emailWrapObj = createEmailWrapper(feedItemList[0].id, String.valueOf(UserContext.id), null, null, null,null);
    	User userObject = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];
    	
    	String segmentId = UserContext.segmentId;
    	
    	Map<String, NotificationHelper.BrandingInfo> brandingInfoMap = new Map<String, NotificationHelper.BrandingInfo>();
    	brandingInfoMap.put(segmentId, EmailUtility.getBrandingInfo4People(null));
    	
    	Map<String, NotificationHelper.EmailWrapper> mapOfSegmentIdAndEmailWrapper = new Map<String, NotificationHelper.EmailWrapper>(); 
    	mapOfSegmentIdAndEmailWrapper.put(segmentId, emailWrapObj);
    	
    	NotificationDispatcher.getEmailHtmlBodyWithTemplate(mapOfSegmentIdAndEmailWrapper, brandingInfoMap, feedItemList[0].id, UserContext.languageLocaleKey);
        Test.stopTest();
		System.assert(true,'Running as expected');
    }
    
    @isTest static void testGetOriginalPostHtmlBodyWithTemplate() {
		Test.startTest();
    	init();
    	feedItemList = [Select f.Type, f.Title, f.SystemModstamp,  f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	emailWrapObj = createEmailWrapper(feedItemList[0].id, String.valueOf(UserContext.id), null, null, null,null);
    	List<Simpplr_Content__c> simpplrContentList = new List<Simpplr_Content__c>{simpContentPage};
    	List<NotificationHelper.EmailCommentWrapper> commentList = getCommentList();
    	Map<String, String> commentOwnerIdToExtPhotoUrlMap = new Map<String, String>{commentList[0].createdById=>null};
    	User userObject = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];
    	String result=NotificationDispatcher.getOriginalPostHtmlBodyWithTemplate(emailWrapObj,10,feedItemList[0].id,simpplrContentList,commentOwnerIdToExtPhotoUrlMap);
        Test.stopTest();
        System.assertEquals(true, result.contains('simpplr.com'), 'successful');
    }
    
     @isTest static void testGetPrimaryCommentBody() {
		Test.startTest();
    	feedItemList = [Select f.Type, f.Title, f.SystemModstamp,  f.RelatedRecordId, f.ParentId, f.LinkUrl, f.LikeCount, f.LastModifiedDate,  f.IsDeleted, f.InsertedById, f.Id, f.HasLink, f.HasContent, f.CreatedDate, f.CreatedById, f.CommentCount, f.Body From FeedItem f limit 1];
    	emailWrapObj = createEmailWrapper(feedItemList[0].id, String.valueOf(UserContext.id), null, null, null,null);
    	User userObject = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];
    	String result=NotificationDispatcher.getPrimaryCommentBody(emailWrapObj.commentList, feedItemList[0].id, null, EmailUtility.getBrandingInfo4People(null));
        Test.stopTest();
        System.assertEquals(true, result.contains('simpplr.com'), 'successful');
    }
    
    static NotificationHelper.EmailWrapper createEmailWrapper(String feedItmId, String userId, String feedCommentId, String type, String subType,String objectType){

    	emailWrapObj = new NotificationHelper.EmailWrapper();
    	emailWrapObj.notificationMetadata = createNotiMeta(feedItmId, feedCommentId, type, subType,objectType);
    	emailWrapObj.feedItemId = feedItmId;
    	emailWrapObj.title = 'Test';
    	emailWrapObj.body = 'test body';
    	emailWrapObj.pollBody = 'poll body';
    	emailWrapObj.createdDate = Date.today();    
    	emailWrapObj.createdByName = 'Test';    	 	
    	emailWrapObj.contentBody = 'content body';
    	emailWrapObj.createdById = userId;
    	emailWrapObj.linkBody = 'Link body';
    	emailWrapObj.totalComments = 5;
    	emailWrapObj.postDate = null;
    	emailWrapObj.commentList = getCommentList();
    	return emailWrapObj;

    }
	
	static NotificationHelper.NotificationMetadata createNotiMeta(String feedItmId, String feedCommentId, String type, String subType,String objectType){
		NotificationHelper.NotificationMetadata  metaObj = new NotificationHelper.NotificationMetadata();
		metaObj.type = String.isBlank(type)?'Post':'trackedChange';
		metaObj.subType = 'Like';
		metaObj.objectType = 'FeedItem';
		metaObj.subject = 'commented on your post';
		metaObj.isTrackChange = false;	
		User userObject1 = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];
		User userObject2 = [select id from user where lastname = 'TestUser_TileServiceTest1' limit 1];

		Map<String,String> userMap = new Map<String,String>();
		userMap.put(userObject1.id, 'TestUser_TileServiceTest');
		userMap.put(userObject2.id, 'TestUser_TileServiceTest1');
		userMap.put(UserInfo.getUserId(), 'Test');

		metaObj.postLikeduserMap = userMap;
		metaObj.profileIdMap = userMap;
		metaObj.postOwnerMap = userMap;
		metaObj.mentionedUserMap = userMap;
        metaObj.isRecognition = false;
		return metaObj;
	}
	
	static List<NotificationHelper.EmailCommentWrapper> getCommentList(){
		User userObject = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];
		List<NotificationHelper.EmailCommentWrapper> commentList = new List<NotificationHelper.EmailCommentWrapper>();
		for(integer i=0;i<5;i++){
			NotificationHelper.EmailCommentWrapper emailComWrap= new NotificationHelper.EmailCommentWrapper();
			emailComWrap.title = 'Test comment'+string.valueOf(i);
			emailComWrap.feedCommentId='11111';
			emailComWrap.createdDate = Date.today();
			emailComWrap.createdById = userObject.id;
			emailComWrap.createdByName = 'Test';		
			
			commentList.add(emailComWrap);
		}
		return commentList;
	}

	@isTest static void testSendInBlue() {
		Test.startTest();
		try{
			NotificationDispatcher obj = new NotificationDispatcher();
			Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGenerator('',200,'success',true));  
			obj.addContactToSendInBlue();
			System.assert(true,'Running as expected');  //No return value or DML in called method
		} catch(Exception ex) {
			//Ignore exception
		}
		Test.stopTest();
	}
	
    /**
     * @description test case Send Email For Csv Download
     */
	@isTest static void testSendEmailForCsvDownload() {   
		Test.startTest(); 	
    	User userObject = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];
		Map<String, Object> valuesMap = new Map<String, Object>();
		valuesMap.put('widgetTab', 'Must Read History');
		valuesMap.put('widgetTitle', 'example');
		valuesMap.put('userId', userObject.id);
		valuesMap.put('localizedDateTime', 'localizedDateTimeStr');
    	NotificationDispatcher.sendEmailForCsvDownload('url string',valuesMap);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }

	/**
     * @description test case Send In App Notification For Csv Download
     */
	@isTest static void testSendInAppNotificationForCsvDownload() {   
		Test.startTest(); 
		init();	
    	User userObject = [select id from user where lastname = 'TestUser_TileServiceTest' limit 1];
		People__c peopleObj  = [select id from People__c where Last_Name__c='TestUser_TileServiceTest' limit 1];
		Csv_Download_Request__c csvReqObj = [select id from Csv_Download_Request__c where People__c =:peopleObj.Id limit 1];
		Map<String, Object> valuesMap = new Map<String, Object>();
		valuesMap.put('widgetTab', 'Must Read History');
		valuesMap.put('peopleId', peopleObj.Id);
		valuesMap.put('userId', userObject.id);
		valuesMap.put('contentId', simpContentAlbum.Id);
    	NotificationDispatcher.sendInAppNotificationForCsvDownload(csvReqObj.Id,valuesMap);
		Test.stopTest();
        System.assert(true,'Running as expected');
    }

	@isTest static void testSendMailToReconnectIntegration() {
		People__c ppl = TestHelper.getPeopleRecordForUser(UserInfo.getUserId());
		Test.startTest();
		List<Email_Log__c> emails = NotificationDispatcher.sendMailToReconnectIntegration(IntegrationConstants.INTEGRATION_TYPE_BOX,new List<People__c>{ppl}, 7);
		Test.stopTest();

		System.assertEquals(1, emails.size(), 'Running as Expected');
		System.assertEquals('Reconnect', emails[0].Type__c, 'Running as Expected');
	}

	@isTest static void testSendInterationDisconnectedEmail() {
		People__c ppl = TestHelper.getPeopleRecordForUser(UserInfo.getUserId());
		Test.startTest();
		List<Email_Log__c> emails = NotificationDispatcher.sendInterationDisconnectedEmail(IntegrationConstants.INTEGRATION_TYPE_BOX, new List<People__c>{ppl});
		Test.stopTest();

		System.assertEquals(1, emails.size(), 'Running as Expected');
		System.assertEquals('Disconnect', emails[0].Type__c, 'Running as Expected');
	}

	@isTest static void testSendNewSiteOnboardingNotification() {
		Test.startTest();
    	init();
		NotificationDispatcher.sendNewSiteOnboardingNotification(publicSiteObj.Id,publicSiteObj.Name,new List<People__c>{peopleObj});
     	Test.stopTest();
        List<App_Notification__c> obj = [Select Category__c from App_Notification__c WHERE Snippet__c =:publicSiteObj.Name and Simpplr_Site__c=:publicSiteObj.Id limit 1];
        System.assertEquals(obj[0].Category__c, 'New_Site_Onboarding_Content', 'Notification not sent');
     }   

	 @isTest static void testSendNotificationForOnboardingPrivilege() {
		Test.startTest();
    	init();
        list<People__c> peopleList = [SELECT Id, User__c FROM People__c WHERE Last_Name__c='TestUser_TileServiceTest' limit 1];
        Set<String> grantedUserForOrgOnboardingSet = new Set<String>();
        grantedUserForOrgOnboardingSet.add(peopleList[0].User__c);
		NotificationDispatcher.sendNotificationForOnboardingPrivilege(grantedUserForOrgOnboardingSet);
     	Test.stopTest();
        List<App_Notification__c> obj = [SELECT Category__c, Sent_To__c FROM App_Notification__c WHERE Category__c = 'Granted_Org_Level_Privilege' LIMIT 1];
        System.assertEquals(obj[0].Sent_To__c, peopleList[0].Id, 'Notification not sent');
     }
    
    @isTest static void testGetEmailRecognitionBody() {
		Test.startTest();
    	init();
        Recognition__c recognitionRecord = new Recognition__c();
        recognitionRecord.Feed_Element_Id__c = 'aHsdgyejjuh0';
        recognitionRecord.Award_Name__c = 'shout-out';
        recognitionRecord.Award_Id__c = 'hsggj-ahhsg-whwh';
        recognitionRecord.Award_receviers__c = peopleObj.Id;
        recognitionRecord.Award_Giver__c = peopleObj.Id;
        insert recognitionRecord;
        String emailBody = NotificationHelper.getEmailRecognitionBody('aHsdgyejjuh0');
        system.assert(emailBody != null, 'email body is null');
        Test.stopTest();
     }
}