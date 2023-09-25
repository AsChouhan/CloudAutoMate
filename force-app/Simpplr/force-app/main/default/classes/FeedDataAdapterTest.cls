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
private class FeedDataAdapterTest {
	private static CollaborationGroup colabGroupObj;
	private static Simpplr_Content__c contentObj;
	@testSetup 
	private static void setup() {
		App_Config__c appConfigRecord = TestHelper.setupAppConfig();
		appConfigRecord.Allow_Leadercast__c = 'selectedSitesAndUsers';
		update appConfigRecord;
		TestHelper.createPeopleRecordForUser(UserContext.id); 

		colabGroupObj= TestHelper.createCollaborationGroup('FeedDataAdapterTest_Grp1','Public');
        Simpplr_Site__c site = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
		List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();
		contentList.add(TestHelper.getContentRecordForCreation('FeedDataAdapterTest Test Page' , 'Page', 'Approved', site));
		contentList.add(TestHelper.getContentRecordForCreation('FeedDataAdapterTest Test Event' , 'Event', 'Approved', site));
		contentList.add(TestHelper.getContentRecordForCreation('FeedDataAdapterTest Test Album' , 'Album', 'Approved', site));
		contentList.add(TestHelper.getContentRecordForCreation('FeedDataAdapterTest Test BlogPost' , 'BlogPost', 'Approved', null));
		insert contentList;		
		TestHelper.createContentVersion('Test', 'Test');
	}	

	@isTest static void testConvertFeedElementPageToWrapperContentDocument() {
		Test.startTest();
		testConvertFeedElementPageToWrapper('ContentDocument'); 
        Test.stopTest();
		System.assert(true,'Running as expected'); 
	}

	@isTest static void testConvertFeedElementPageToWrapperCampaign() {
		Test.startTest();
		testConvertFeedElementPageToWrapper('campaign'); 
        Test.stopTest();
		System.assert(true,'Running as expected'); 
	}

	@isTest static void testConvertFeedElementPageToWrapperPage() {
		Test.startTest();
		testConvertFeedElementPageToWrapper('Page'); 
        Test.stopTest();
		System.assert(true,'Running as expected'); 
	}
    
    @isTest static void testConvertFeedElementPageToWrapperRecognition() {
		Test.startTest();
		testConvertFeedElementPageToWrapper('recognition'); 
        Test.stopTest();
		System.assert(true,'Running as expected'); 
	}
	
    @isTest static void testConvertFeedElementPageToWrapper() {
        Test.startTest();
		testConvertFeedElementPageToWrapper('Event');
		testConvertFeedElementPageToWrapper('Album');
        Test.stopTest();
		System.assert(true,'Running as expected');       
    }
	@isTest static void testConvertFeedElementPageToWrapper2() {
        Test.startTest();
		testConvertFeedElementPageToWrapper('AlbumMedia');
		testConvertFeedElementPageToWrapper('BlogPost');
        Test.stopTest();
		System.assert(true,'Running as expected');       
    }
    @isTest static void testConvertFeedElementPageToWrapperWhenComment() {
    	Test.startTest();
    	testConvertFeedElementPageToWrapperWhenComment('ContentDocument'); 
		testConvertFeedElementPageToWrapperWhenComment('campaign'); 
		testConvertFeedElementPageToWrapperWhenComment('Page');
		
        Test.stopTest();
		System.assert(true,'Running as expected');       
    }
	@isTest static void testConvertFeedElementPageToWrapperWhenComment2() {
    	Test.startTest();
		testConvertFeedElementPageToWrapperWhenComment('Event');
		testConvertFeedElementPageToWrapperWhenComment('Album');
		testConvertFeedElementPageToWrapperWhenComment('AlbumMedia');
		testConvertFeedElementPageToWrapperWhenComment('BlogPost');
        Test.stopTest();
		System.assert(true,'Running as expected');       
    }
   
	private static void testConvertFeedElementPageToWrapper(String type) {
		FeedDataAdapter obj = new FeedDataAdapter();
		colabGroupObj = [select id from CollaborationGroup Limit 1];
        Simpplr_Site__c site = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
		String contentType = 'AlbumMedia'.equalsIgnoreCase(type) ? 'Album' : type;		
		ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
		List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
        List<ConnectApi.MessageSegment> messageSegments = new List<ConnectApi.MessageSegment>();
		String link = '';
        if ('recognition'.equalsIgnoreCase(type)){
            link = 'https://apex/app';

        } else if(type == 'ContentDocument') {			
			ContentDocument cd = [select id from ContentDocument limit 1];
			link = 'https://apex/FileDetail?fileId=' + cd.id;
           
		} else if(type == 'campaign') {	
			link = 'https://apex/app?campaignId=1234';
            
        } else {
			contentObj = [select id, Type__c from Simpplr_Content__c where Type__c=:contentType Limit 1];						
			if(type == 'AlbumMedia') {
				File__c fileObj = TestHelper.createContentTitleImage(contentObj.id);
				contentObj = [select id, Type__c from Simpplr_Content__c where Type__c=:contentType Limit 1];
				link = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id + '/gallery/' + fileObj.id + '&fromPromoteModal=true';				
				
			} else if(type == 'Album') {
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://youtu.be/');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://embed.vidyard.com/share');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://vimeo.com/');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://wistia.');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://vbrick.com');
				link = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id;
              
			} else {
				TestHelper.createContentTitleImage(contentObj.id);
                link = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id;
                
			}
        }	
		
        if('recognition'.equalsIgnoreCase(type)){
            listOfFeedElement.add(getFeedElement(link, type));
            People__c peopleObj = [SELECT Id FROM People__c WHERE User__c =: UserContext.Id];
            Recognition__c recognitionRecord = new Recognition__c();
            recognitionRecord.Feed_Element_Id__c = listOfFeedElement[0].Id;
            recognitionRecord.Award_Name__c = 'shout-out';
            recognitionRecord.Award_Id__c = 'hsggj-ahhsg-whwh';
            recognitionRecord.Award_receviers__c = peopleObj.Id;
            recognitionRecord.Award_Giver__c = peopleObj.Id;
            insert recognitionRecord;

        } else {
            listOfFeedElement.add(TestHelper.getFeedElement(link));
        }        
		feedElementPageObj.elements = listOfFeedElement;
				
		ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', 3, 
				ConnectApi.FeedDensity.AllUpdates	, null, 10,  ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);		
		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		ConnectApi.FeedElementPage feedPageObj = FeedConnectAPIService.getFeedElementsFromFeed(null, 
				'news', 'me', null, 10, 'activity'); 
		FeedElementPageWrapper feedElementPageWrapperObj = new FeedElementPageWrapper();
		feedElementPageWrapperObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedPageObj); 		
		FeedDataAdapter.isFeedPageContext=null;
		FeedDataAdapter.isCommentPageContext = true;

		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			FeedDataAdapter.getUserIdsToConvert(listOfFeedElement[0].capabilities.comments.page);
			FeedDataAdapter.getPeopleFromUserIds();
		}

		FeedDataAdapter.convertCommentPageToWrapper(listOfFeedElement[0].capabilities.comments.page);
	}
    
    private static void testConvertFeedElementPageToWrapperWhenComment(String type) {
		FeedDataAdapter obj = new FeedDataAdapter();
		colabGroupObj = [select id from CollaborationGroup Limit 1];
        Simpplr_Site__c site = [select id, Chatter_Group_Id__c from Simpplr_Site__c limit 1];
		String contentType = 'AlbumMedia'.equalsIgnoreCase(type) ? 'Album' : type;		
		ConnectApi.FeedElementPage feedElementPageObj = new ConnectApi.FeedElementPage();
		List<ConnectApi.FeedElement> listOfFeedElement = new List<ConnectApi.FeedElement>();
        List<ConnectApi.MessageSegment> messageSegments = new List<ConnectApi.MessageSegment>();
		String link = '';		
		if(type == 'ContentDocument') {			
			ContentDocument cd = [select id from ContentDocument limit 1];
			link = 'https://apex/FileDetail?fileId=' + cd.id;
           
		} else if(type == 'campaign') {	
			link = 'https://apex/app?campaignId=1234';
            
            
		} else {
			contentObj = [select id, Type__c from Simpplr_Content__c where Type__c=:contentType Limit 1];						
			if(type == 'AlbumMedia') {
				File__c fileObj = TestHelper.createContentTitleImage(contentObj.id);
				contentObj = [select id, Type__c from Simpplr_Content__c where Type__c=:contentType Limit 1];				
				link = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id + '/gallery/' + fileObj.id + '&fromPromoteModal=true';	
			} else if(type == 'Album') {
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://youtu.be/');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://embed.vidyard.com/share');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://vimeo.com/');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://wistia.');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://vbrick.com');
				link = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id;
              
			} else {
				TestHelper.createContentTitleImage(contentObj.id);
                link = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id;
                
			}
        }	

        listOfFeedElement.add(getFeedElement(link, type));
		feedElementPageObj.elements = listOfFeedElement;
				
		ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null, ConnectApi.FeedType.news, 'me', 3, 
				ConnectApi.FeedDensity.AllUpdates	, null, 10,  ConnectApi.FeedSortOrder.LastModifiedDateDesc, feedElementPageObj);		
		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		ConnectApi.FeedElementPage feedPageObj = FeedConnectAPIService.getFeedElementsFromFeed(null, 
				'news', 'me', null, 10, 'activity'); 
		FeedElementPageWrapper feedElementPageWrapperObj = new FeedElementPageWrapper();
		feedElementPageWrapperObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedPageObj); 		
		FeedDataAdapter.isFeedPageContext=null;
		FeedDataAdapter.isCommentPageContext = true;

		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			FeedDataAdapter.getUserIdsToConvert(listOfFeedElement[0].capabilities.comments.page);
			FeedDataAdapter.getPeopleFromUserIds();
		}
		
		FeedDataAdapter.convertCommentPageToWrapper(listOfFeedElement[0].capabilities.comments.page);
	}
    
    public static ConnectApi.FeedElement getFeedElement(String url, string type) { 
		ConnectApi.FeedItem connectAPIFeedItemObj = new ConnectAPI.FeedItem(); 
		connectAPIFeedItemObj.OriginalFeedItem = new ConnectApi.Reference();
		connectAPIFeedItemObj.type = ConnectApi.FeedItemType.TextPost;
		connectAPIFeedItemObj.feedElementType = ConnectApi.FeedElementType.FeedItem;
		connectAPIFeedItemObj.photoUrl = 'https://photourl/005';
		connectAPIFeedItemObj.header = getConnectApiMessageBody(type);
		connectAPIFeedItemObj.body = new ConnectApi.FeedBody();
		connectAPIFeedItemObj.body.messageSegments = connectAPIFeedItemObj.header.messageSegments;		
		connectAPIFeedItemObj.capabilities =  getConnectApiFeedCapabilities(url, type);
		connectAPIFeedItemObj.parent = TestHelper.getConnectApiUserDetail();
		connectAPIFeedItemObj.actor = TestHelper.getConnectApiUserDetail();
		connectAPIFeedItemObj.isSharable = true;
		connectAPIFeedItemObj.isDeleteRestricted = false;
		connectAPIFeedItemObj.originalFeedItemActor = TestHelper.getConnectApiUserDetail();
		connectAPIFeedItemObj.createdDate = DateTime.now();
		return (connectAPIFeedItemObj);
	}
    public static ConnectApi.FeedElementCapabilities getConnectApiFeedCapabilities(String url, string type) {
		ConnectApi.FeedElementCapabilities capabilities = new ConnectApi.FeedElementCapabilities();
		capabilities.link = new ConnectApi.LinkCapability();
		capabilities.link.url = url == null ? '/apex/' : url;
		capabilities.link.urlName = 'DummyURL';

		capabilities.poll = new ConnectApi.PollCapability();
		capabilities.Poll.choices = new List<ConnectApi.FeedPollChoice>();
		capabilities.Poll.totalVoteCount = 0;
		capabilities.Poll.myChoiceId = '123';
		ConnectApi.FeedPollChoice choice = new ConnectApi.FeedPollChoice();
		choice.voteCountRatio = 10;
		capabilities.Poll.choices.add(choice);

		capabilities.Files = new ConnectApi.FilesCapability();
		ConnectApi.Content contObj = new ConnectApi.Content();
		contObj.id = '069';
		contObj.fileSize = '100';
		contObj.fileExtension = 'pdf';
		capabilities.Files.items = new List<ConnectApi.Content>();
		capabilities.Files.items.add(contObj);

		capabilities.comments = getConnectApiCommentsCapability(type);

		capabilities.Topics = new ConnectApi.TopicsCapability();
		ConnectApi.Topic connectApiTopic = new ConnectApi.Topic();
		connectApiTopic.id = '0TO61000000PkgvGAC'; 
		connectApiTopic.name = 'Topic'; 
		capabilities.Topics.items = new List<ConnectApi.Topic>();
		capabilities.Topics.items.add(connectApiTopic); 

		capabilities.chatterLikes = new ConnectApi.ChatterLikesCapability();
		capabilities.chatterLikes.page = new ConnectApi.ChatterLikePage();
		capabilities.chatterLikes.page.items = new List<ConnectApi.ChatterLike>();

		capabilities.trackedChanges = new  ConnectApi.TrackedChangesCapability();

		return capabilities;
	}
    
    public static ConnectApi.CommentsCapability getConnectApiCommentsCapability(String type) {
		ConnectApi.CommentsCapability commentsCapabilityObj = new ConnectApi.CommentsCapability();
		commentsCapabilityObj.page = new ConnectApi.CommentPage();
		commentsCapabilityObj.page.items = new List<ConnectApi.Comment>();
		commentsCapabilityObj.page.total = 1;
		
		ConnectApi.Comment connectAPICommentObj = new ConnectApi.Comment();
		connectAPICommentObj.capabilities = new ConnectApi.CommentCapabilities();
		connectAPICommentObj.capabilities.content = new ConnectApi.ContentCapability();
		connectAPICommentObj.capabilities.content.id = '069';
		connectAPICommentObj.capabilities.content.fileExtension = 'pptx';
		connectAPICommentObj.capabilities.content.fileSize = '100';
		connectAPICommentObj.body = new ConnectApi.FeedBody();
		connectAPICommentObj.isDeleteRestricted = false;
		connectAPICommentObj.body.messageSegments = getMessageSegments(type);
		connectAPICommentObj.body.text = 'Test';

		connectAPICommentObj.user = new ConnectApi.UserSummary();
		connectAPICommentObj.user.photo = new ConnectApi.Photo();
		connectAPICommentObj.user.id = UserInfo.getUserId();
		connectAPICommentObj.user.name = 'Simpplr';

		connectAPICommentObj.likes = new ConnectApi.ChatterLikePage();
		connectAPICommentObj.likes.total = 100;
		commentsCapabilityObj.page.items.add(connectAPICommentObj);


		return commentsCapabilityObj;
	}

    
    public static ConnectApi.MessageBody getConnectApiMessageBody(String type) {						
		ConnectApi.MessageBody message = new ConnectApi.MessageBody();			
		message.messageSegments = getMessageSegments(type);
		return message;
	}
    
    public static List<ConnectApi.MessageSegment> getMessageSegments(String type) {
		ConnectApi.TextSegment textSegment;
		ConnectApi.HashtagSegment hashSegment;
		ConnectApi.LinkSegment linkSegment;
		ConnectApi.EntityLinkSegment entityLinkSegment;
		ConnectApi.MentionSegment mentionSegment;
		ConnectApi.MarkupBeginSegment markupBeginSegment;
		ConnectApi.MarkupEndSegment markupEndSegment;
		ConnectApi.InlineImageSegment inlineSegment;
        String contentType = 'AlbumMedia'.equalsIgnoreCase(type) ? 'Album' : type;	
        List<ConnectApi.MessageSegment> messageSegments = new List<ConnectApi.MessageSegment>();
        linkSegment = new ConnectApi.LinkSegment();	
        
        if('recognition'.equalsIgnoreCase(type)) {
            textSegment = new ConnectApi.TextSegment();
            textSegment.text = '\u2063\uFEFF\uFEFF\u200b\uFEFF\uFEFF\u2063 great Work';
            messageSegments.add(textSegment);
			
        } else if(type == 'ContentDocument') {			
			ContentDocument cd = [select id from ContentDocument limit 1];
			 linkSegment.url = 'https://apex/FileDetail?fileId=' + cd.id;
           messageSegments.add(linkSegment);
           
		} else if(type == 'campaign') {	
			linkSegment.url  = 'https://apex/app?campaignId=1234';
            messageSegments.add(linkSegment);
            
		} else if(type == 'externalLink') {	
			linkSegment.url = 'https://www.youtube.com/watch?v=_n365oEeMwg';
             messageSegments.add(linkSegment);
            
            
		} else {
			Simpplr_Content__c contentObj = [select id, Type__c from Simpplr_Content__c where Type__c=:contentType Limit 1];					
			if(type == 'AlbumMedia') {
				File__c fileObj = TestHelper.createContentTitleImage(contentObj.id);
				contentObj = [select id, Type__c from Simpplr_Content__c where Type__c=:contentType Limit 1];
                linkSegment.url  = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id + '/gallery/' + fileObj.id + '&fromPromoteModal=true';
                messageSegments.add(linkSegment);
				
			} else if(type == 'Album') {
                 contentObj = [select id, Type__c from Simpplr_Content__c where Type__c=:type Limit 1];	
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://youtu.be/');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://embed.vidyard.com/share');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://vimeo.com/');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://wistia.');
				TestHelper.createFileRecordForVideo(contentObj.id, 'https://vbrick.com');
				linkSegment.url  = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id;
                messageSegments.add(linkSegment);
              
			} else {
                 contentObj = [select id, Type__c from Simpplr_Content__c where Type__c=:type Limit 1];	
				TestHelper.createContentTitleImage(contentObj.id);
                linkSegment.url  = 'https://apex/app?u=/' + contentObj.type__c + '/' + contentObj.id;
                messageSegments.add(linkSegment);
			
            }
        }
        return messageSegments;
    }
    
	@isTest 
	static void testGenerateLikeUserWrapObj1() {
    	ConnectApi.ChatterLike connectApilikeObj = new ConnectApi.ChatterLike();
		connectApilikeObj.user = new ConnectApi.UserSummary();
		connectApilikeObj.user.photo = new ConnectApi.Photo();
		
		Test.startTest();
		LikersWrapper likersWrapperObj = FeedDataAdapter.generateLikeUserWrapObj(connectApilikeObj, 2);
		Test.stopTest();

		System.assertEquals(null, likersWrapperObj.userId, 'user id should be as per test value');
    }
    
	@isTest 
	static void testConvertToPostedOnWrapperForEventPost() {
		List<Simpplr_Content__c> contentList = [Select id, Type__c, Title__c from Simpplr_Content__c Where Type__c='Event' limit 1];
		File__c fileObj = TestHelper.createContentTitleImage(contentList[0].id);

		Test.startTest();
		FeedElementWrapper.PostedOnWrapper postedOnWrapperObj = FeedDataAdapter.convertToPostedOnWrapper(contentList[0].id, 'Test');
		Test.stopTest();

		System.assertEquals('event', postedOnWrapperObj.type, 'type should be as per test value');
		System.assertEquals(contentList[0].Title__c, postedOnWrapperObj.title, 'title should be as per test value');
		System.assertEquals(true, postedOnWrapperObj.site != null, 'site detail should be here');
		System.assertEquals('FeedDataAdapterTest_Grp1', postedOnWrapperObj.site.name, 'site name should be as per test value');
	}

	@isTest 
	static void testConvertToPostedOnWrapperForAlbumPost() {
		List<Simpplr_Content__c> contentList = [Select id, Type__c, Title__c from Simpplr_Content__c Where Type__c='album' limit 1];
		File__c fileObj = TestHelper.createContentTitleImage(contentList[0].id);
		fileObj.Content_Version__c ='2';
		fileObj.Is_Title_Image__c = true;
		update fileObj;
		
		Test.startTest();
		FeedElementWrapper.PostedOnWrapper postedOnWrapperObj = FeedDataAdapter.convertToPostedOnWrapper(contentList[0].id, 'Test');
		Test.stopTest();

		System.assertEquals('album', postedOnWrapperObj.type, 'type should be as per test value');
		System.assertEquals(contentList[0].Title__c, postedOnWrapperObj.title, 'title should be as per test value');
		System.assertEquals(true, postedOnWrapperObj.listOfTopAlbumImages != null, 'images should be here');
		System.assertEquals(fileObj.id, postedOnWrapperObj.listOfTopAlbumImages[0].albumMediaId, 'images should be here');
		System.assertEquals(true, postedOnWrapperObj.site != null, 'site detail should be here');
		System.assertEquals('FeedDataAdapterTest_Grp1', postedOnWrapperObj.site.name, 'site name should be as per test value');
	}


	@isTest 
	static void testConvertToPostedOnWrapperForAlbumPostForVideoType() {
		List<Simpplr_Content__c> contentList = [Select id, Type__c, Title__c from Simpplr_Content__c Where Type__c='album' limit 1];
		File__c fileObj = TestHelper.createContentTitleImage(contentList[0].id);
		
		Test.startTest();
		FeedElementWrapper.PostedOnWrapper postedOnWrapperObj = FeedDataAdapter.convertToPostedOnWrapper(contentList[0].id, 'Test');
		Test.stopTest();

		System.assertEquals('album', postedOnWrapperObj.type, 'type should be as per test value');
		System.assertEquals(contentList[0].Title__c, postedOnWrapperObj.title, 'title should be as per test value');
		System.assertEquals(true, postedOnWrapperObj.listOfTopAlbumImages != null, 'images should be here');
		System.assertEquals(true, postedOnWrapperObj.listOfTopAlbumImages[0].isVideo, 'video should be here');
	}

	@isTest 
	static void testConvertToPostedOnWrapperForAlbumPostWhenNoImagesFound() {
		List<Simpplr_Content__c> contentList = [Select id, Type__c, Title__c from Simpplr_Content__c Where Type__c='album' limit 1];
		
		Test.startTest();
		FeedElementWrapper.PostedOnWrapper postedOnWrapperObj = FeedDataAdapter.convertToPostedOnWrapper(contentList[0].id, 'Test');
		Test.stopTest();

		System.assertEquals('album', postedOnWrapperObj.type, 'type should be as per test value');
		System.assertEquals(contentList[0].Title__c, postedOnWrapperObj.title, 'title should be as per test value');
		System.assertEquals(true, postedOnWrapperObj.listOfTopAlbumImages == null, 'images should not be here');
	}

	@isTest 
	static void testConvertToPostedOnWrapperForBlogPostPostDoesNotContainsSiteDetails() {
		List<Simpplr_Content__c> contentList = [Select id, Type__c, Title__c from Simpplr_Content__c Where Type__c='blogpost' limit 1];

		Test.startTest();
		FeedElementWrapper.PostedOnWrapper postedOnWrapperObj = FeedDataAdapter.convertToPostedOnWrapper(contentList[0].id, 'Test');
		Test.stopTest();

		System.assertEquals('blogpost', postedOnWrapperObj.type, 'type should be as per test value');
		System.assertEquals(true, postedOnWrapperObj.site == null, 'site detail should not be here');
	}
    


	@isTest
	static void AddMarksTest() {
        // Arrange
		FeedDataAdapter.marks.add('bold');
		FeedDataAdapter.marks.add('italic');

        Map<String, Object> segmentJSON = new Map<String, Object>();

        // Act
        Map<String, Object> result = FeedDataAdapter.addMarks(segmentJSON);

        // Assert
        List<Map<String, Object>> marksJSONList = (List<Map<String, Object>>) result.get('marks');
        System.assertNotEquals(null, marksJSONList,'add marks failed.');
        System.assertEquals(2, marksJSONList.size(),'in correct no of marks added');

     
    }

	@isTest
    static void populateTopicIdsByNameTest() {
        // Arrange
        List<String> listOfTag = new List<String> { 'tag1', 'tag2', 'tag3' };
        Map<String, Id> expectedTopicIds = new Map<String, Id>();

		List<Topic> topicToInsert = new List<Topic>();
        for (String tag : listOfTag) {
            Topic t = new Topic(Name = tag);
			topicToInsert.add(t);
        }
		insert topicToInsert;
		for(Topic t : topicToInsert){
			expectedTopicIds.put(t.Name.toLowerCase(), t.Id);
		}
        // Act
        Test.startTest();
        FeedDataAdapter.populateTopicIdsByName(listOfTag);
        Test.stopTest();

        // Assert
        Map<String, Id> actualTopicIds = FeedDataAdapter.TopicIdsByName;
        System.assertEquals(expectedTopicIds, actualTopicIds, 'populateTopicIdsByName failed');
    }


	@isTest
    static void processFromSegmentsV1Test() {
		//Arrange
		List<ConnectApi.MessageSegment> segments = new List<ConnectApi.MessageSegment>();
		ConnectApi.MarkupBeginSegment pbegin = new ConnectApi.MarkupBeginSegment();
		pbegin.htmlTag ='p';
		segments.add(pbegin);

		ConnectApi.MarkupBeginSegment italic = new ConnectApi.MarkupBeginSegment();
		italic.htmlTag ='i';
		segments.add(italic);

		ConnectApi.MarkupBeginSegment strikethrough = new ConnectApi.MarkupBeginSegment();
		strikethrough.htmlTag ='s';
		segments.add(strikethrough);

		ConnectApi.MarkupBeginSegment bold = new ConnectApi.MarkupBeginSegment();
		bold.htmlTag ='b';
		segments.add(bold);

		ConnectApi.MarkupBeginSegment underline = new ConnectApi.MarkupBeginSegment();
		underline.htmlTag ='u';
		segments.add(underline);

		ConnectApi.TextSegment text1 = new ConnectApi.TextSegment();
		text1.text = 'Hi';
		segments.add(text1);

		ConnectApi.MarkupEndSegment underlineEnd = new ConnectApi.MarkupEndSegment();
		underlineEnd.htmlTag ='u';
		segments.add(underlineEnd);

		ConnectApi.MarkupEndSegment boldEnd = new ConnectApi.MarkupEndSegment();
		boldEnd.htmlTag ='b';
		segments.add(boldEnd);

		ConnectApi.MarkupEndSegment strikethroughEnd = new ConnectApi.MarkupEndSegment();
		strikethroughEnd.htmlTag ='s';
		segments.add(strikethroughEnd);

		ConnectApi.MarkupEndSegment italicEnd = new ConnectApi.MarkupEndSegment();
		italicEnd.htmlTag ='i';
		segments.add(italicEnd);

		ConnectApi.MarkupEndSegment pend = new ConnectApi.MarkupEndSegment();
		pend.htmlTag ='p';
		segments.add(pend);

		ConnectApi.MarkupBeginSegment pbegin1 = new ConnectApi.MarkupBeginSegment();
		pbegin1.htmlTag ='p';
		segments.add(pbegin1);

		ConnectApi.HashtagSegment tag = new ConnectApi.HashtagSegment();
		tag.tag = 'abcd';
		segments.add(tag);
		ConnectApi.MarkupEndSegment pend1 = new ConnectApi.MarkupEndSegment();
		pend1.htmlTag ='p';
		segments.add(pend1);

		ConnectApi.MarkupBeginSegment olBegin = new ConnectApi.MarkupBeginSegment();
		olBegin.htmlTag ='ol';
		segments.add(olBegin);

		ConnectApi.MarkupBeginSegment liBegin = new ConnectApi.MarkupBeginSegment();
		liBegin.htmlTag ='li';
		segments.add(liBegin);

		ConnectApi.MarkupBeginSegment p1Begin = new ConnectApi.MarkupBeginSegment();
		p1Begin.htmlTag ='p';
		segments.add(p1Begin);

		ConnectApi.TextSegment text2 = new ConnectApi.TextSegment();
		text2.text = 'one';
		segments.add(text2);

		ConnectApi.MarkupEndSegment p1End = new ConnectApi.MarkupEndSegment();
		p1End.htmlTag ='p';
		segments.add(p1End);

		ConnectApi.MarkupEndSegment liEnd = new ConnectApi.MarkupEndSegment();
		liEnd.htmlTag ='li';
		segments.add(liEnd);

		ConnectApi.MarkupBeginSegment li2Begin = new ConnectApi.MarkupBeginSegment();
		li2Begin.htmlTag ='li';
		segments.add(li2Begin);


		ConnectApi.MarkupBeginSegment nestedList = new ConnectApi.MarkupBeginSegment();
		nestedList.htmlTag ='ul';
		segments.add(nestedList);

		ConnectApi.MarkupBeginSegment nestedLi = new ConnectApi.MarkupBeginSegment();
		nestedLi.htmlTag ='li';
		segments.add(nestedLi);

		ConnectApi.MarkupBeginSegment np2Begin = new ConnectApi.MarkupBeginSegment();
		np2Begin.htmlTag ='p';
		segments.add(np2Begin);

		ConnectApi.TextSegment ntext3 = new ConnectApi.TextSegment();
		ntext3.text = 'two';
		segments.add(ntext3);

		ConnectApi.MarkupEndSegment np2End = new ConnectApi.MarkupEndSegment();
		np2End.htmlTag ='p';
		segments.add(np2End);
		ConnectApi.MarkupEndSegment nestedLiEnd = new ConnectApi.MarkupEndSegment();
		nestedLiEnd.htmlTag ='li';
		segments.add(nestedLiEnd);

		ConnectApi.MarkupEndSegment nestedListEnd = new ConnectApi.MarkupEndSegment();
		nestedListEnd.htmlTag ='ul';
		segments.add(nestedListEnd);

		ConnectApi.MarkupEndSegment li2End = new ConnectApi.MarkupEndSegment();
		li2End.htmlTag ='li';
		segments.add(li2End);

		ConnectApi.MarkupEndSegment olEnd = new ConnectApi.MarkupEndSegment();
		olEnd.htmlTag ='ol';
		segments.add(olEnd);


		ConnectApi.MarkupBeginSegment ulBegin = new ConnectApi.MarkupBeginSegment();
		ulBegin.htmlTag ='ul';
		segments.add(ulBegin);

		ConnectApi.MarkupBeginSegment li3Begin1 = new ConnectApi.MarkupBeginSegment();
		li3Begin1.htmlTag ='li';
		segments.add(li3Begin1);

		ConnectApi.MarkupBeginSegment nestedList1 = new ConnectApi.MarkupBeginSegment();
		nestedList1.htmlTag ='ol';
		segments.add(nestedList1);

		ConnectApi.MarkupBeginSegment nestedLi1 = new ConnectApi.MarkupBeginSegment();
		nestedLi1.htmlTag ='li';
		segments.add(nestedLi1);

		ConnectApi.MarkupBeginSegment np2Begin1 = new ConnectApi.MarkupBeginSegment();
		np2Begin1.htmlTag ='p';
		segments.add(np2Begin1);

		ConnectApi.TextSegment ntext31 = new ConnectApi.TextSegment();
		ntext31.text = 'two';
		segments.add(ntext31);

		ConnectApi.MarkupEndSegment np2End1 = new ConnectApi.MarkupEndSegment();
		np2End1.htmlTag ='p';
		segments.add(np2End1);
		ConnectApi.MarkupEndSegment nestedLiEnd1 = new ConnectApi.MarkupEndSegment();
		nestedLiEnd1.htmlTag ='li';
		segments.add(nestedLiEnd1);

		ConnectApi.MarkupEndSegment nestedListEnd1 = new ConnectApi.MarkupEndSegment();
		nestedListEnd1.htmlTag ='ul';
		segments.add(nestedListEnd1);


		ConnectApi.MarkupEndSegment nli3Begin = new ConnectApi.MarkupEndSegment();
		nli3Begin.htmlTag ='li';
		segments.add(nli3Begin);


		ConnectApi.MarkupBeginSegment li3Begin = new ConnectApi.MarkupBeginSegment();
		li3Begin.htmlTag ='li';
		segments.add(li3Begin);

		ConnectApi.MarkupBeginSegment p3Begin = new ConnectApi.MarkupBeginSegment();
		p3Begin.htmlTag ='p';
		segments.add(p3Begin);

		ConnectApi.TextSegment text4 = new ConnectApi.TextSegment();
		text4.text = 'two';
		segments.add(text4);

		ConnectApi.MarkupBeginSegment boldStart = new ConnectApi.MarkupBeginSegment();
		boldStart.htmlTag ='b';
		segments.add(boldStart);

		ConnectApi.LinkSegment link = new ConnectApi.LinkSegment();
		link.url = 'google.com.abcd';
		segments.add(link);

		ConnectApi.MarkupEndSegment boldEnd1 = new ConnectApi.MarkupEndSegment();
		boldEnd1.htmlTag ='b';
		segments.add(boldEnd1);

		ConnectApi.MarkupEndSegment p3End = new ConnectApi.MarkupEndSegment();
		p3End.htmlTag ='p';
		segments.add(p3End);

		ConnectApi.MarkupEndSegment li3End = new ConnectApi.MarkupEndSegment();
		li3End.htmlTag ='li';
		segments.add(li3End);

		ConnectApi.MarkupEndSegment ulEnd = new ConnectApi.MarkupEndSegment();
		ulEnd.htmlTag ='ul';
		segments.add(ulEnd);


		for(ConnectApi.MessageSegment segment : segments){
			System.debug(segment);
		}

		//Act
		Test.startTest();
        String actualParagraphJSON = FeedDataAdapter.processFromSegmentsV1(segments);
		Test.stopTest();

		System.assertNotEquals(0, actualParagraphJSON.length(), 'processFromSegmentsV1 failing');

	}


    @isTest
    static void testProcessTextSegmentWithValidInput() {
		ConnectApi.TextSegment textSegment = new ConnectApi.TextSegment();
		textSegment.text = 'Test message';

        
        Map<String, Object> expectedResult = new Map<String, Object>();
        expectedResult.put('type', 'text');
        expectedResult.put('text', 'Test message');
        Test.startTest();
        Map<String, Object> actualResult = FeedDataAdapter.processTextSegment(textSegment);
		Test.stopTest();
        
        System.assertEquals(expectedResult, actualResult,'processTextSegment failed for valid input');
    }
    

  


}