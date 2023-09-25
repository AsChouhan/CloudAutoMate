public with sharing class NotificationHelper {
    
    public static final string POST_ON_PROFILE = 'PostOnProfile';
    public static final string POST_MENTION = 'PostMention';
    public static final string COMMENT_MENTION = 'CommentMention';
    public static final string POST_SHARE = 'PostShare';
    public static final string STATUS_CHANGE = 'StatusChange';
    public static final string COMMENT_ON_POST = 'CommentOnPost';
    public static final string COMMENT_AFTER_ME = 'CommentAfterMe';
    public static final string COMMENT_ON_POST_I_LIKE = 'CommentOnPostILike';
    public static final String INACTIVE = 'Inactive';

	public static final String EMAIL_TITLE_PLACEHOLDER = 'EMAIL_TITLE_PLACEHOLDER';
	
	private static final String FILES_ATTACHED_LABEL_PLACEHOLDER = '{4}';
	
    public static boolean insertShareRecordFlag = true;
    public static String baseUrl = BaseCtrl.salesForceBaseUrl;

	public Static String feedId;
    
    public class BrandingInfo{
    	public String header_backgroundColor;
    	public String header_iconColor;
    	public String footer_backgroundColor;
    	public String footer_textColor;
    	public String general_primaryColor;
    	public String header_preset;
    	public String footer_preset;
    	public String logo_url;
    }
    
    public class NotificationMetadata {
        public String type;
        public String parentType;
        public String siteId;
        public String subType;
        public String status;
        public String objectType;
        public String subject;
        public String snippet;
		public String category;
        public String heading;
        public String appNotificationSubject;
        public String prefSettingType;
        public Boolean isTrackChange;
		public Boolean isRecognition;
        public Map<String,String> postLikeduserMap;
        public Map<String,String> sharedPostOwnerMap;
        public Map<String,String> profileIdMap;
        public Map<String,String> postOwnerMap;
        public Map<String,String> mentionedUserMap;
    }
    
    public class EmailWrapper{
        public NotificationMetadata notificationMetadata;
        public String feedItemId;
        public String title;
        public String body;
        public String pollBody;
        public String contentBody;
        public String createdById;
        public Datetime createdDate;
        public String createdByName;
        public String linkBody;
        public String postDate;
        public Integer totalComments;
        public List<EmailCommentWrapper> commentList;
    }
    
    public class EmailCommentWrapper{
        public NotificationMetadata notificationMetadata;
        public String feedCommentId;
        public String title;
        public String body;
        public String createdById;
        public Datetime createdDate;
        public String createdByName;
        public String contentBody;
    }
    
    public class SharePostMetaData{
    	public boolean isSharePost;
    	public String originalPostOwnerName;
    	public String originalPostOwnerId;
    }
    
    public class JSONConvertor {
    	FilterAttributeWrapper actor;
    	FilterAttributeWrapper originalFeedItemActor;
    	public JSONConvertorToFeedItem originalFeedItem;
    	String type;
    	JSONConvertorToFeedItemParent parent;
    }
    
    public class JSONConvertorToFeedItemParent{
    	public String type;
    }
    
    public class JSONConvertorToFeedItem{
    	public String id;
    	public String url;
    }
    
    
    @testVisible 
    private static List<EmailCommentWrapper> createEmailCommentWrapperObjectList(ConnectApi.FeedElement feedObject, String replysnippet, BrandingInfo brandingInfo, List<Simpplr_Content__c> simpplrContentList) {
        List<EmailCommentWrapper> emailCommentWrapperObjList = new List<EmailCommentWrapper>();  
        String feedItemJSON;
		feedId = feedObject.Id;
		List<ConnectApi.Comment> commentList = feedObject.capabilities.comments.page.items;
		for(ConnectApi.Comment comments : commentList) {
			ConnectApi.ContentCapability commentContent = comments.capabilities.content;
			EmailCommentWrapper emailCommentWrappperObj = new EmailCommentWrapper(); 
			emailCommentWrappperObj.notificationMetadata = getCommentNotificationInfo(feedObject);
			emailCommentWrappperObj.feedCommentId = comments.id;
			JSONConvertor feedElementActor = (JSONConvertor)JSON.deserialize(JSON.serialize(feedObject),JSONConvertor.class);
			emailCommentWrappperObj.createdById = comments.user.id;
			emailCommentWrappperObj.createdDate = comments.createdDate;
			emailCommentWrappperObj.createdByName = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(comments.user.id) ? FeedDataAdapter.mapUserIdToPeople.get(comments.user.id).Full_Name__c : comments.user.name;
			String contentTitle = emailCommentWrappperObj.createdByName.escapeHtml4();
			emailCommentWrappperObj.title = contentTitle;
			emailCommentWrappperObj.body = getEmailBody(comments.body.messageSegments, replysnippet, brandingInfo, 'reply');

			if(commentContent!= null && commentContent.id != null && commentContent.fileSize != null ) {
				emailCommentWrappperObj.contentBody = getEmailContentBodyForAttachedFile();
			} else {
				emailCommentWrappperObj.contentBody = '';
			}

			emailCommentWrapperObjList.add(emailCommentWrappperObj);
		}
        
        return emailCommentWrapperObjList;
    }
    
    @testVisible 
    private static NotificationMetadata getCommentNotificationInfo(ConnectApi.FeedElement feedElementObj){
        List<ConnectApi.Comment> commentList =  feedElementObj.capabilities.comments.page.items;
        NotificationMetadata notificationInfo = new NotificationMetadata();
        
        JSONConvertor feedElementActor = (JSONConvertor)JSON.deserialize(JSON.serialize(feedElementObj),JSONConvertor.class);
        notificationInfo.profileIdMap =  new Map<String,String>{feedElementObj.parent.id=>(SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(feedElementObj.parent.id) ? FeedDataAdapter.mapUserIdToPeople.get(feedElementObj.parent.id).Full_Name__c : feedElementObj.parent.name)};
        notificationInfo.postOwnerMap = new Map<String,String>{feedElementActor.actor.id=>(SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(feedElementActor.actor.id) ? FeedDataAdapter.mapUserIdToPeople.get(feedElementActor.actor.id).Full_Name__c : feedElementActor.actor.name)};
		notificationInfo.type = feedElementActor.type;
		notificationInfo.parentType = feedElementActor.parent.type;        
        Integer indexOfLastComment = 1;

    	List<ConnectApi.ChatterLike> likeList = feedElementObj.capabilities.chatterLikes.page.items;
        notificationInfo.postLikeduserMap = getPostLikedUserMap(likeList);

        for(ConnectApi.Comment comments : commentList) {
            if(indexOfLastComment == commentList.size()) {
				List<ConnectApi.MessageSegment> messageSegments = comments.body.messageSegments;
		        notificationInfo.mentionedUserMap = getMentionedUserIdMap(messageSegments);
            }
            indexOfLastComment = indexOfLastComment +1;
        }
        return notificationInfo;

    }
    
    @testVisible 
    private static Map<String,String> getPostLikeduserMap(List<ConnectApi.ChatterLike> likeList){
    	
        Map<String,String> postLikedUsers = new Map<String,String>();
        for(ConnectApi.ChatterLike likes : likeList) {
    		postLikedUsers.put(likes.user.id, (SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(likes.user.id) ? FeedDataAdapter.mapUserIdToPeople.get(likes.user.id).Full_Name__c : likes.user.name));
    	}
        return postLikedUsers;

    }
    
    public static Boolean isUnlisted = false;
    
    /* *****************************************************************************************************************************/
    public static ConnectApi.FeedElement getFeedElementObject(List<FeedItem> feedItemList, String source) {
    	ConnectApi.FeedElement feedObject;
    	
        if(!feedItemList.isEmpty()) {
        	String feedItemId = feedItemList[0].id;
        	
            if(!feedItemList[0].Type.equalsIgnoreCase('PollPost') || String.isNotBlank(source))  { 
				feedObject = getFeedElementObject(feedItemId);
            }
        }
        
        return feedObject;
    }

	public static ConnectApi.FeedElement getFeedElementObject(Id feedItemId) {
		ConnectApi.FeedElement feedObject;
		if(!Test.isRunningTest()){
			feedObject = ConnectApi.ChatterFeeds.getFeedElement(null, feedItemId);
		} else {
			feedObject = TestHelper.getFeedElement(null);
		}
		return feedObject;
	}

	public static ConnectApi.FeedElement getFeedElementObjectWithSortedComments(FeedItem feedItemObj) {
    	ConnectApi.FeedElement feedObject;
    	ConnectApi.FeedCommentSortOrder commentSort = ConnectApi.FeedCommentSortOrder.CreatedDateLatestAsc;
        
		if(!Test.isRunningTest()){
			feedObject = ConnectApi.ChatterFeeds.getFeedElement(null, feedItemObj.id, commentSort);
		} else {
			feedObject = TestHelper.getFeedElement(null);
		}
        
        return feedObject;
    }

	public static Map<String, EmailWrapper> createSegmentIdAndEmailWrapperMap(Map<String, BrandingInfo> brandingInfoMap, List<FeedItem> feedItemList, ConnectApi.FeedElement feedObject, String replysnippet, NotificationMetadata notiMetaObj, String source, List<Simpplr_Content__c> simpplrContentList, String actionName, ConnectApi.Comment currentComment, Boolean isUpdatingPlaceholderFeed) {
    	Map<String, EmailWrapper> segmentIdAndEmailWrapperMap = new Map<String, EmailWrapper>();
    	Boolean isComment = false;
	    String feedCommentId = '';
    	String feedItemId = feedItemList[0].id;
        String parentId = feedItemList[0].parentId;
		ConnectAPI.FeedItem feedItemCastedObj = (ConnectApi.FeedItem)feedObject;
		feedId = feedItemCastedObj.originalFeedItem != null ? feedItemCastedObj.originalFeedItem.Id : feedObject.Id;
        String feedItemJSON;
		String feedCommentJSON = '{}';
        Set<String> mentionedUserIdSet = new Set<String>();
        Set<String> mentionedGrpIdSet = new Set<String>();
	    List<Id> contentVersionId = new List<Id>();
	    String slackThumbUrl = '';
	    
        if(!feedItemList.isEmpty()) {
            if(!feedItemList[0].Type.equalsIgnoreCase('PollPost') || String.isNotBlank(source))  { 
				feedItemJSON = JSON.serialize(feedObject);
				if(currentComment != null){
					feedCommentJSON = JSON.serialize(currentComment);
				}
				for(String segmentId : brandingInfoMap.keySet()) {
					BrandingInfo brandingInfoObj = brandingInfoMap.get(segmentId);
					EmailWrapper emailWrappperObj = new EmailWrapper();
		
		
					Map<String,Object> feedParent= (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(feedObject.parent));
					if(feedParent.get('additionalLabel') != null && 'Unlisted'.equalsIgnoreCase(''+feedParent.get('additionalLabel'))){
						isUnlisted = true;
					}
					List<ConnectApi.MessageSegment> messageSegments = feedObject.body.messageSegments;
					List<ConnectApi.MessageSegment> headerMessage = feedObject.header.messageSegments;
					
					ConnectApi.FilesCapability files = feedObject.capabilities.files;  
					ConnectApi.LinkCapability link = feedObject.capabilities.link;
					ConnectApi.PollCapability poll = feedObject.capabilities.poll;
					emailWrappperObj.notificationMetadata = notiMetaObj;
					emailWrappperObj.feedItemId = feedObject.id;
					JSONConvertor feedElementActor = (JSONConvertor)JSON.deserialize(JSON.serialize(feedObject),JSONConvertor.class);
					emailWrappperObj.createdById = feedElementActor.actor.id;
					emailWrappperObj.createdDate = feedObject.createdDate;
					emailWrappperObj.createdByName = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(feedElementActor.actor.id) ? FeedDataAdapter.mapUserIdToPeople.get(feedElementActor.actor.id).Full_Name__c : feedElementActor.actor.name;
					emailWrappperObj.title = EMAIL_TITLE_PLACEHOLDER;
					emailWrappperObj.body = getEmailBody(messageSegments, null, brandingInfoObj, 'post');
					
					emailWrappperObj.contentBody = '';
					if(files != null && files.items != null) {
						ConnectApi.Content contentFile = files.items[0];
						if(contentFile.id != null && contentFile.fileSize != null) {
							emailWrappperObj.contentBody = getEmailContentBodyForAttachedFile();
						}
					}

					if(link != null) {
						emailWrappperObj.linkBody = getEmailLinkBody(link, brandingInfoObj);
					} else {
						emailWrappperObj.linkBody = '';
					}
					if(poll != null) {
						List<String> formatterList = new List<String>();
						formatterList.add(emailWrappperObj.body);
						formatterList.add(baseUrl + Page.PageRedirector.getUrl() + '?feedId=' + feedObject.id +'&pageToRedirect='+Pages.HomeFeedSinglePost+'&origin=ne');
						emailWrappperObj.pollBody = EmailUtility.format(getEmailPollBody(poll, brandingInfoObj), formatterList);
					} else {
						emailWrappperObj.pollBody = '';
					}
					emailWrappperObj.postDate = String.valueOf(feedObject.createdDate);
					integer totalComments = feedObject.capabilities.comments.page.total;
					emailWrappperObj.totalComments = totalComments;
					List<ConnectApi.Comment> commentList = feedObject.capabilities.comments.page.items;
					List<EmailCommentWrapper> commentWrapperObjList =  new List<EmailCommentWrapper>();
						
					if(!commentList.isEmpty()) {
						commentWrapperObjList = createEmailCommentWrapperObjectList(feedObject, replysnippet, brandingInfoObj, simpplrContentList);
						emailWrappperObj.commentList = commentWrapperObjList;
						mentionedUserIdSet.addAll(getMentionedUserIdMap(commentList[commentList.size()-1].body.messageSegments).keySet());
						mentionedGrpIdSet.addAll(getMentionedGroupIdMap(commentList[commentList.size()-1].body.messageSegments).keySet());
						//Added for Slack
						if(commentList[commentList.size()-1].capabilities.content != null){
							if(commentList[commentList.size()-1].capabilities.content.fileExtension.equalsIgnoreCase('jpeg')
								|| commentList[commentList.size()-1].capabilities.content.fileExtension.equalsIgnoreCase('jpg')
								|| commentList[commentList.size()-1].capabilities.content.fileExtension.equalsIgnoreCase('png')
								|| commentList[commentList.size()-1].capabilities.content.fileExtension.equalsIgnoreCase('gif')
							){
								contentVersionId.add(commentList[commentList.size()-1].capabilities.content.versionId);
							}
						}
						//End
						isComment = true;
						feedCommentId = commentList[commentList.size()-1].id;
					} else {
						mentionedUserIdSet.addAll(getMentionedUserIdMap(feedObject.body.messageSegments).keySet());
						mentionedGrpIdSet.addAll(getMentionedGroupIdMap(feedObject.body.messageSegments).keySet());
						//Added for Slack
						if(files != null){
							for(ConnectApi.Content content : files.items){   
								if(content.fileExtension.equalsIgnoreCase('jpeg')
									|| content.fileExtension.equalsIgnoreCase('jpg')
									|| content.fileExtension.equalsIgnoreCase('png')
									|| content.fileExtension.equalsIgnoreCase('gif')
								){
									contentVersionId.add(content.versionId);
								} 
							}
						}else if(link != null){
							Simpplr_Content__c contentObj = getSharedContent(link);
							if (contentObj != null) {
								List<File__c> fileList = contentObj.File_Simpplr_Content__r;
								if(!fileList.isEmpty()){ 
									contentVersionId.add(fileList[0].Content_Version__c);
								}
							}
						}
						//End
					}
					segmentIdAndEmailWrapperMap.put(segmentId, emailWrappperObj);
				}
	        }
    	}    	
    	if(!('CommentLike'.equalsIgnoreCase(actionName) || 'Comment'.equalsIgnoreCase(actionName))){
	        cacheFeedElement(feedItemJSON, mentionedUserIdSet, mentionedGrpIdSet, feedItemId, isComment, feedCommentId, parentId);
	        //Added For Slack
	        if('PostLike'.equalsIgnoreCase(actionName) == false){
	        	if(!contentVersionId.isEmpty()){
	        		Map<Id, String> CVToThumUrlMap = FileContentProvider.generateEmbedPublicUrl(contentVersionId);
	        		
	        		if(!CVToThumUrlMap.isEmpty()){
	        			slackThumbUrl = CVToThumUrlMap.values()[0];
	        		}
	        	}
	        	if((!isUpdatingPlaceholderFeed && SimpplrContext.slackIntegrationEnabled) || SimpplrContext.microsoftTeamsIntegrationEnabled){
	        		try{
	        			System.enqueueJob(new PushSiteFeed.QueueablePushSiteFeed(feedItemJSON, slackThumbUrl, feedCommentJSON));
	        		} catch(Exception e) {
	        		}
	        	}
         	
	        }
	        //End
			if(feedItemJSON !=null) {
	        	shareFeedElement(feedItemJSON,source);
			}
    	}
    	return segmentIdAndEmailWrapperMap;
    }
	
    public static List<EmailWrapper> createEmailWrapperObjectList(List<FeedItem> feedItemList, ConnectApi.FeedElement feedObject, NotificationMetadata notiMetaObj, String source, List<Simpplr_Content__c> simpplrContentList, BrandingInfo brandingInfo, String actionName, ConnectApi.Comment currentComment, Boolean isUpdatingPlaceholderFeed) {
        List<EmailWrapper> emailWrapperObjList = new List<EmailWrapper>();  
        String feedItemId = feedItemList[0].id;
		ConnectAPI.FeedItem feedItemCastedObj = (ConnectApi.FeedItem)feedObject;
		feedId = feedItemCastedObj.originalFeedItem != null ? feedItemCastedObj.originalFeedItem.Id : feedObject.Id;
        String parentId = feedItemList[0].parentId;
        String feedItemJSON;
		String feedCommentJSON = '{}';
        Set<String> mentionedUserIdSet = new Set<String>();
        Set<String> mentionedGrpIdSet = new Set<String>();
        List<Id> contentVersionId = new List<Id>();
        String slackThumbUrl = '';
        Boolean isComment = false;
        String feedCommentId = '';
        if(!feedItemList.isEmpty()) {
            if(!feedItemList[0].Type.equalsIgnoreCase('PollPost') || String.isNotBlank(source))  { 
                EmailWrapper emailWrappperObj = new EmailWrapper(); 
                
                    //feedObject = ConnectApi.ChatterFeeds.getFeedElement(null, feedItemId);
                    feedItemJSON = JSON.serialize(feedObject);
					if(currentComment != null){
						feedCommentJSON = JSON.serialize(currentComment);
					}
                if(feedObject != null) {
                	Map<String,Object> feedParent= (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(feedObject.parent));
                	if(feedParent.get('additionalLabel') != null && 'Unlisted'.equalsIgnoreCase(''+feedParent.get('additionalLabel'))){
                		isUnlisted = true;
                	}
	                List<ConnectApi.MessageSegment> messageSegments = feedObject.body.messageSegments;
	                List<ConnectApi.MessageSegment> headerMessage = feedObject.header.messageSegments;
	                
	                ConnectApi.FilesCapability files = feedObject.capabilities.files;
	                ConnectApi.LinkCapability link = feedObject.capabilities.link;
	            	ConnectApi.PollCapability poll = feedObject.capabilities.poll;
	                emailWrappperObj.notificationMetadata = notiMetaObj;
	                emailWrappperObj.feedItemId = feedObject.id;
	                JSONConvertor feedElementActor = (JSONConvertor)JSON.deserialize(JSON.serialize(feedObject),JSONConvertor.class);
	                emailWrappperObj.createdById = feedElementActor.actor.id;
	                emailWrappperObj.createdDate = feedObject.createdDate;
	                emailWrappperObj.createdByName = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(feedElementActor.actor.id) ? FeedDataAdapter.mapUserIdToPeople.get(feedElementActor.actor.id).Full_Name__c : feedElementActor.actor.name;
	                emailWrappperObj.title = EMAIL_TITLE_PLACEHOLDER;
	                emailWrappperObj.body = getEmailBody(messageSegments, null, brandingInfo, 'post');
	                
					emailWrappperObj.contentBody = '';
					if(files != null && files.items != null) {
						ConnectApi.Content contentFile = files.items[0];
						if(contentFile.id != null && contentFile.fileSize != null) {
							emailWrappperObj.contentBody = getEmailContentBodyForAttachedFile();
						}
					}
					
	                if(link != null) {
	                    emailWrappperObj.linkBody = getEmailLinkBody(link, brandingInfo);
	                } else {
	                    emailWrappperObj.linkBody = '';
	                }
	                if(poll != null) {
						List<String> formatterList = new List<String>();
						formatterList.add(emailWrappperObj.body);
						formatterList.add(baseUrl + Page.PageRedirector.getUrl() + '?feedId=' + feedObject.id +'&pageToRedirect='+Pages.HomeFeedSinglePost+'&origin=ne');
	                    emailWrappperObj.pollBody = EmailUtility.format(getEmailPollBody(poll, brandingInfo), formatterList);
	                } else {
	                    emailWrappperObj.pollBody = '';
	                }
	                emailWrappperObj.postDate = String.valueOf(feedObject.createdDate);
	                integer totalComments = feedObject.capabilities.comments.page.total;
	                emailWrappperObj.totalComments = totalComments;
	                List<ConnectApi.Comment> commentList = feedObject.capabilities.comments.page.items;
	                List<EmailCommentWrapper> commentWrapperObjList =  new List<EmailCommentWrapper>();
	                 
	                if(!commentList.isEmpty()) {
						commentWrapperObjList = createEmailCommentWrapperObjectList(feedObject, null, brandingInfo, simpplrContentList);
	                	emailWrappperObj.commentList = commentWrapperObjList;
	                	mentionedUserIdSet.addAll(getMentionedUserIdMap(commentList[commentList.size()-1].body.messageSegments).keySet());
	                	mentionedGrpIdSet.addAll(getMentionedGroupIdMap(commentList[commentList.size()-1].body.messageSegments).keySet());
	                	//Added for Slack
	                	if(commentList[commentList.size()-1].capabilities.content != null){
		                	if(commentList[commentList.size()-1].capabilities.content.fileExtension.equalsIgnoreCase('jpeg')
		            			|| commentList[commentList.size()-1].capabilities.content.fileExtension.equalsIgnoreCase('jpg')
		            			|| commentList[commentList.size()-1].capabilities.content.fileExtension.equalsIgnoreCase('png')
		            			|| commentList[commentList.size()-1].capabilities.content.fileExtension.equalsIgnoreCase('gif')
		            		){
		            			contentVersionId.add(commentList[commentList.size()-1].capabilities.content.versionId);
		            		}
	                	}
	                	//End
	                	isComment = true;
	                	feedCommentId = commentList[commentList.size()-1].id;
	                } else {
	                	mentionedUserIdSet.addAll(getMentionedUserIdMap(feedObject.body.messageSegments).keySet());
	                	mentionedGrpIdSet.addAll(getMentionedGroupIdMap(feedObject.body.messageSegments).keySet());
	                	//Added for Slack
	                	if(files != null){
	                		for(ConnectApi.Content content : files.items){
			                	if(content.fileExtension.equalsIgnoreCase('jpeg')
			            			|| content.fileExtension.equalsIgnoreCase('jpg')
			            			|| content.fileExtension.equalsIgnoreCase('png')
			            			|| content.fileExtension.equalsIgnoreCase('gif')
			            		){
			            		
			            			contentVersionId.add(content.versionId);
			            		
			            		}
	                		} 
	                	}else if(link != null){
	            			Simpplr_Content__c contentObj = getSharedContent(link);
            				if (contentObj != null) {
            					List<File__c> fileList = contentObj.File_Simpplr_Content__r;
            					if(!fileList.isEmpty()){ 
									contentVersionId.add(fileList[0].Content_Version__c);
            					}
				        	}
	            		}
	                	//End
	                }
	                emailWrapperObjList.add(emailWrappperObj);
            	}
            }
        }
        cacheFeedElement(feedItemJSON, mentionedUserIdSet, mentionedGrpIdSet, feedItemId, isComment, feedCommentId, parentId);
        //Added For Slack
        if('PostLike'.equalsIgnoreCase(actionName) == false && 'CommentLike'.equalsIgnoreCase(actionName) ==  false){
        	if(!contentVersionId.isEmpty()){
        		Map<Id, String> CVToThumUrlMap = FileContentProvider.generateEmbedPublicUrl(contentVersionId);
        		
        		if(!CVToThumUrlMap.isEmpty()){
        			slackThumbUrl = CVToThumUrlMap.values()[0];
        		}
        	}
        	if((!isUpdatingPlaceholderFeed && SimpplrContext.slackIntegrationEnabled) || SimpplrContext.microsoftTeamsIntegrationEnabled){
        		try{
        			System.enqueueJob(new PushSiteFeed.QueueablePushSiteFeed(feedItemJSON, slackThumbUrl, feedCommentJSON));
        		} catch(Exception e) {
        		}
        	}
        }
        //End
        if(feedItemJSON !=null) {
        	shareFeedElement(feedItemJSON,source);
		}
        return emailWrapperObjList;
    }
    
    @testVisible @future
    public static void deleteFeedItemCache(Id postId){
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', postId);
    	String query = 'SELECT Id FROM Feed_Cache__c WHERE Feed_Id__c =:soqlParam1 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Feed_Cache__c> myFeedCacheRecord = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	for(Feed_Cache__c feedCacheObj : myFeedCacheRecord) {
    		feedCacheObj.Is_Deleted__c =  true;
    	}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Feed_Cache__c>(myFeedCacheRecord), new List<Schema.SObjectField>{
													Feed_Cache__c.Is_Deleted__c
												});    	
    }
    
    @testVisible @future
    public static void deleteFeedCommentCache(Id commentId){
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', commentId);
    	String query = 'SELECT Id FROM Feed_Cache__c WHERE Feed_Comment_Id__c =:soqlParam1 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Feed_Cache__c> myFeedCacheRecord = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	for(Feed_Cache__c feedCacheObj : myFeedCacheRecord) {
    		feedCacheObj.Is_Deleted__c =  true;
    	}
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Feed_Cache__c>(myFeedCacheRecord), new List<Schema.SObjectField>{
													Feed_Cache__c.Is_Deleted__c
												});
    }
    
    @testVisible
    public static void updateFeedItemCache(Id postId){

    	ConnectApi.FeedElement feedObject = getFeedElementObject(postId);
    	String feedElementJson = JSON.serialize(feedObject);
    	Set<String> mentionUserIds = new Set<String>();
    	Set<String> mentionGrpIds = new Set<String>();
    	Set<String>targetUserIdSet = new Set<String>();
    	mentionUserIds.addAll(getMentionedUserIdMap(feedObject.body.messageSegments).keySet());
	    mentionGrpIds.addAll(getMentionedGroupIdMap(feedObject.body.messageSegments).keySet());
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', postId);
    	String query = 'SELECT Id, Feed_Id__c,Feed_Comment_Id__c, Feed_Item_Type__c, Mention_1__c, Mention_2__c, Mention_3__c, Mention_4__c, Mention_5__c, Mentions__c, '+
    	 								' Group_Mention_1__c, Group_Mention_2__c, Group_Mention_3__c, Group_Mention_4__c, Group_Mention_5__c, Group_Mentions__c '+
    	 								' FROM Feed_Cache__c WHERE Feed_Id__c =:soqlParam1 AND Feed_Comment_Id__c = null AND Is_Deleted__c = false order by CreatedDate Desc limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Feed_Cache__c> myFeedCacheList = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	if(myFeedCacheList.isEmpty()){
    		cacheFeedElement(feedElementJson, mentionUserIds, mentionGrpIds, feedObject.id+'', false, '', feedObject.parent.id);
    		targetUserIdSet.addAll(mentionUserIds);
    	} else {
	        Integer count = 0;
    		Feed_Cache__c myFeedCacheRecord = new Feed_Cache__c();
    		myFeedCacheRecord.id = myFeedCacheList[0].id;
    			if(!String.isBlank(myFeedCacheList[0].Mentions__c)){
	    			for(String targetUserId : mentionUserIds){
	    				if(!myFeedCacheList[0].Mentions__c.containsIgnoreCase(targetUserId)){
	    					targetUserIdSet.add(targetUserId);
	    				}
	    			}
    			}else{
    				targetUserIdSet.addAll(mentionUserIds);
    			}
	        myFeedCacheRecord.Mention_1__c = '';
	        myFeedCacheRecord.Mention_2__c = '';
	        myFeedCacheRecord.Mention_3__c = '';
	        myFeedCacheRecord.Mention_4__c = '';
	        myFeedCacheRecord.Mention_5__c = '';
	        for(String mentionUserId : mentionUserIds) {
	            if(count>=0 && count<252) {
	                myFeedCacheRecord.Mention_1__c = myFeedCacheRecord.Mention_1__c + mentionUserId;
	            }
	            if(count>252 && count<252*2) {
	                myFeedCacheRecord.Mention_2__c = myFeedCacheRecord.Mention_2__c + mentionUserId;
	            }
	            if(count>252*2 && count<252*3) {
	                myFeedCacheRecord.Mention_3__c = myFeedCacheRecord.Mention_3__c + mentionUserId;
	            }
	            if(count>252*3 && count<252*4) {
	                myFeedCacheRecord.Mention_4__c = myFeedCacheRecord.Mention_4__c + mentionUserId;
	            }
	            if(count>252*4 && count<252*5) {
	                myFeedCacheRecord.Mention_5__c = myFeedCacheRecord.Mention_5__c + mentionUserId;
	            }
	            count +=18;
	        }
	        count = 0;
	        myFeedCacheRecord.Group_Mention_1__c = '';
	        myFeedCacheRecord.Group_Mention_2__c = '';
	        myFeedCacheRecord.Group_Mention_3__c = '';
	        myFeedCacheRecord.Group_Mention_4__c = '';
	        myFeedCacheRecord.Group_Mention_5__c = '';
	        
	        for(String mentionGrpId : mentionGrpIds) {
	            if(count>=0 && count<252) {
	                myFeedCacheRecord.Group_Mention_1__c = myFeedCacheRecord.Group_Mention_1__c + mentionGrpId;
	            }
	            if(count>252 && count<252*2) {
	                myFeedCacheRecord.Group_Mention_2__c = myFeedCacheRecord.Group_Mention_2__c + mentionGrpId;
	            }
	            if(count>252*2 && count<252*3) {
	                myFeedCacheRecord.Group_Mention_3__c = myFeedCacheRecord.Group_Mention_3__c + mentionGrpId;
	            }
	            if(count>252*3 && count<252*4) {
	                myFeedCacheRecord.Group_Mention_4__c = myFeedCacheRecord.Group_Mention_4__c + mentionGrpId;
	            }
	            if(count>252*4 && count<252*5) {
	                myFeedCacheRecord.Group_Mention_5__c = myFeedCacheRecord.Group_Mention_5__c + mentionGrpId;
	            }
	            count +=18;
	        }
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(myFeedCacheRecord, new List<Schema.SObjectField>{
															Feed_Cache__c.Mention_1__c,
															Feed_Cache__c.Mention_2__c,
															Feed_Cache__c.Mention_3__c,
															Feed_Cache__c.Mention_4__c,
															Feed_Cache__c.Mention_5__c,
															Feed_Cache__c.Group_Mention_1__c,
															Feed_Cache__c.Group_Mention_2__c,
															Feed_Cache__c.Group_Mention_3__c,
															Feed_Cache__c.Group_Mention_4__c,
															Feed_Cache__c.Group_Mention_5__c															
														});	        	
	        	
    		}
    		if(!targetUserIdSet.isEmpty()){
    			NotificationDispatcher.sendFeedItemNotificationsAndEmailOnUpdate(postId, targetUserIdSet);
    		}
    }
    
    @testVisible 
    public static void updateFeedCommentCache(Id commentId, Id FeedItemId){
		ConnectApi.FeedElement feedObject = getFeedElementObject(FeedItemId);
    	String feedElementJson = JSON.serialize(feedObject);
    	List<ConnectApi.MessageSegment> messSegments = new List<ConnectApi.MessageSegment>();
    	if(feedObject.capabilities.comments.page.total>0){
    		List<ConnectApi.Comment> commentList = feedObject.capabilities.comments.page.items;
	    	for(ConnectApi.Comment feedCommentObj : commentList){
	    		if(feedCommentObj.id == commentId){
	    			messSegments = feedCommentObj.body.messageSegments;
	    		}
	    	}
    	}
    	Set<String> mentionUserIds = new Set<String>();
    	Set<String> mentionGrpIds = new Set<String>();
    	Set<String>targetUserIdSet = new Set<String>();
        mentionUserIds.addAll(getMentionedUserIdMap(messSegments).keySet());
        mentionGrpIds.addAll(getMentionedGroupIdMap(messSegments).keySet());
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', commentId);
    	String query = 'SELECT Id, Feed_Id__c,Feed_Comment_Id__c, Feed_Item_Type__c, Mention_1__c, Mention_2__c, Mention_3__c, Mention_4__c, Mention_5__c, Mentions__c, '+
    											' Group_Mention_1__c, Group_Mention_2__c, Group_Mention_3__c, Group_Mention_4__c, Group_Mention_5__c, Group_Mentions__c'+
    											' FROM Feed_Cache__c WHERE Feed_Comment_Id__c =:soqlParam1 AND Is_Deleted__c = false order by CreatedDate Desc limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Feed_Cache__c> myFeedCacheList = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	if(myFeedCacheList.isEmpty()){
    		cacheFeedElement(feedElementJson, mentionUserIds, mentionGrpIds, feedObject.id+'', true, commentId+'', feedObject.parent.id);
    		targetUserIdSet.addAll(mentionUserIds);
    	} else {
	        Integer count = 0;
	        Feed_Cache__c myFeedCacheRecord = new Feed_Cache__c();
	        myFeedCacheRecord.id = myFeedCacheList[0].id;
	        
	        if(!String.isBlank(myFeedCacheList[0].Mentions__c)){
	    			for(String targetUserId : mentionUserIds){
	    				if(!myFeedCacheList[0].Mentions__c.containsIgnoreCase(targetUserId)){
	    					targetUserIdSet.add(targetUserId);
	    				}
	    			}
    			}else{
    				targetUserIdSet.addAll(mentionUserIds);
    			}
    			
	        myFeedCacheRecord.Mention_1__c = '';
	        myFeedCacheRecord.Mention_2__c = '';
	        myFeedCacheRecord.Mention_3__c = '';
	        myFeedCacheRecord.Mention_4__c = '';
	        myFeedCacheRecord.Mention_5__c = '';
	        for(String mentionUserId : mentionUserIds) {
	            if(count>=0 && count<252) {
	                myFeedCacheRecord.Mention_1__c = myFeedCacheRecord.Mention_1__c + mentionUserId;
	            }
	            if(count>252 && count<252*2) {
	                myFeedCacheRecord.Mention_2__c = myFeedCacheRecord.Mention_2__c + mentionUserId;
	            }
	            if(count>252*2 && count<252*3) {
	                myFeedCacheRecord.Mention_3__c = myFeedCacheRecord.Mention_3__c + mentionUserId;
	            }
	            if(count>252*3 && count<252*4) {
	                myFeedCacheRecord.Mention_4__c = myFeedCacheRecord.Mention_4__c + mentionUserId;
	            }
	            if(count>252*4 && count<252*5) {
	                myFeedCacheRecord.Mention_5__c = myFeedCacheRecord.Mention_5__c + mentionUserId;
	            }
	            count +=18;
	        }
	        count = 0;
	        myFeedCacheRecord.Group_Mention_1__c = '';
	        myFeedCacheRecord.Group_Mention_2__c = '';
	        myFeedCacheRecord.Group_Mention_3__c = '';
	        myFeedCacheRecord.Group_Mention_4__c = '';
	        myFeedCacheRecord.Group_Mention_5__c = '';
	        
	        for(String mentionGrpId : mentionGrpIds) {
	            if(count>=0 && count<252) {
	                myFeedCacheRecord.Group_Mention_1__c = myFeedCacheRecord.Group_Mention_1__c + mentionGrpId;
	            }
	            if(count>252 && count<252*2) {
	                myFeedCacheRecord.Group_Mention_2__c = myFeedCacheRecord.Group_Mention_2__c + mentionGrpId;
	            }
	            if(count>252*2 && count<252*3) {
	                myFeedCacheRecord.Group_Mention_3__c = myFeedCacheRecord.Group_Mention_3__c + mentionGrpId;
	            }
	            if(count>252*3 && count<252*4) {
	                myFeedCacheRecord.Group_Mention_4__c = myFeedCacheRecord.Group_Mention_4__c + mentionGrpId;
	            }
	            if(count>252*4 && count<252*5) {
	                myFeedCacheRecord.Group_Mention_5__c = myFeedCacheRecord.Group_Mention_5__c + mentionGrpId;
	            }
	            count +=18;
	        }
	        if(feedObject != null) {
	        	myFeedCacheRecord.Feed_Data__c = JSON.serialize(feedObject);
	        	myFeedCacheRecord.Parent_Id__c = feedObject.parent.Id;
	        }
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(myFeedCacheRecord, new List<Schema.SObjectField>{
														Feed_Cache__c.Mention_1__c,
														Feed_Cache__c.Mention_2__c,
														Feed_Cache__c.Mention_3__c,
														Feed_Cache__c.Mention_4__c,
														Feed_Cache__c.Mention_5__c,
														Feed_Cache__c.Group_Mention_1__c,
														Feed_Cache__c.Group_Mention_2__c,
														Feed_Cache__c.Group_Mention_3__c,
														Feed_Cache__c.Group_Mention_4__c,
														Feed_Cache__c.Group_Mention_5__c,
														Feed_Cache__c.Feed_Data__c,
														Feed_Cache__c.Parent_Id__c
													});

   	 	}
    		if(!targetUserIdSet.isEmpty()){
    			NotificationDispatcher.sendFeedCommentNotificationsAndEmailOnUpdate(commentId, targetUserIdSet);
    		}
    }
    
    @testVisible
    private static Simpplr_Content__c getSharedContent(ConnectApi.LinkCapability link){
    	Simpplr_Content__c contentObj;
    	PageReference pfObj =  new PageReference(link.url);
    	if(pfObj.getParameters().get('contentId') != null 
    		&& pfObj.getParameters().get('siteId') != null 
    		|| pfObj.getParameters().get('profileId') != null) 
    	{
    		String contentId = pfObj.getParameters().get('contentId');
    		if (String.isNotBlank(contentId)) {
				contentObj = [SELECT id,
								(SELECT id, Content_Version__c 
									FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c ) 
								FROM Simpplr_Content__c where id=:contentId WITH SECURITY_ENFORCED limit 1];
		
        	}
    	}
    	return contentObj; 
    }
    
    @testVisible 
    private static void cacheFeedElement(String feedElementJson, Set<String> mentionUserIds,Set<String> mentionGrpIds, String feedItemId, boolean isComment, String feedCommentId, String parentId){ 
        try{
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

	        Feed_Cache__c myFeedCacheRecord = new Feed_Cache__c();
	        
			myFeedCacheRecord.Feed_Id__c = feedItemId;
	        myFeedCacheRecord.Parent_Id__c = parentId;
	        myFeedCacheRecord.Feed_Data__c = feedElementJson;
			if (parentId.startsWith('0F9')) {
				Map<String,Simpplr_Site__c> mapOfChatterToSite = new SiteDao().getColGrpIdToShowInSimpplrSitesMap(new Set<String>{parentId});
				myFeedCacheRecord.Site__c = mapOfChatterToSite.get(parentId).Id;
			} else if (parentId.startsWith(Utility.getSimpplrContentPrefix())) {
				myFeedCacheRecord.Site__c = ManageContentDao.getContentById(parentId).Site__c;
			}

			fieldList.add(Feed_Cache__c.Feed_Id__c);
			fieldList.add(Feed_Cache__c.Parent_Id__c);
			fieldList.add(Feed_Cache__c.Feed_Data__c);
			fieldList.add(Feed_Cache__c.Site__c);
			

	        Integer count = 0;
	        myFeedCacheRecord.Mention_1__c = '';
	        myFeedCacheRecord.Mention_2__c = '';
	        myFeedCacheRecord.Mention_3__c = '';
	        myFeedCacheRecord.Mention_4__c = '';
	        myFeedCacheRecord.Mention_5__c = '';

			fieldList.add(Feed_Cache__c.Mention_1__c);
			fieldList.add(Feed_Cache__c.Mention_2__c);
			fieldList.add(Feed_Cache__c.Mention_3__c);
			fieldList.add(Feed_Cache__c.Mention_4__c);
			fieldList.add(Feed_Cache__c.Mention_5__c);
			

	        for(String mentionUserId : mentionUserIds) {
	            if(count>=0 && count<252) {
	                myFeedCacheRecord.Mention_1__c = myFeedCacheRecord.Mention_1__c + mentionUserId;
	            }
	            if(count>=252 && count<252*2) {
	                myFeedCacheRecord.Mention_2__c = myFeedCacheRecord.Mention_2__c + mentionUserId;
	            }
	            if(count>=252*2 && count<252*3) {
	                myFeedCacheRecord.Mention_3__c = myFeedCacheRecord.Mention_3__c + mentionUserId;
	            }
	            if(count>=252*3 && count<252*4) {
	                myFeedCacheRecord.Mention_4__c = myFeedCacheRecord.Mention_4__c + mentionUserId;
	            }
	            if(count>=252*4 && count<252*5) {
	                myFeedCacheRecord.Mention_5__c = myFeedCacheRecord.Mention_5__c + mentionUserId;
	            }
	            count +=18;
	        }
	        count = 0;
	        myFeedCacheRecord.Group_Mention_1__c = '';
	        myFeedCacheRecord.Group_Mention_2__c = '';
	        myFeedCacheRecord.Group_Mention_3__c = '';
	        myFeedCacheRecord.Group_Mention_4__c = '';
	        myFeedCacheRecord.Group_Mention_5__c = '';

			fieldList.add(Feed_Cache__c.Group_Mention_1__c);
			fieldList.add(Feed_Cache__c.Group_Mention_2__c);
			fieldList.add(Feed_Cache__c.Group_Mention_3__c);
			fieldList.add(Feed_Cache__c.Group_Mention_4__c);
			fieldList.add(Feed_Cache__c.Group_Mention_5__c);
			
	        
	        for(String mentionGrpId : mentionGrpIds) {
	            if(count>=0 && count<252) {
	                myFeedCacheRecord.Group_Mention_1__c = myFeedCacheRecord.Group_Mention_1__c + mentionGrpId;
	            }
	            if(count>252 && count<252*2) {
	                myFeedCacheRecord.Group_Mention_2__c = myFeedCacheRecord.Group_Mention_2__c + mentionGrpId;
	            }
	            if(count>252*2 && count<252*3) {
	                myFeedCacheRecord.Group_Mention_3__c = myFeedCacheRecord.Group_Mention_3__c + mentionGrpId;
	            }
	            if(count>252*3 && count<252*4) {
	                myFeedCacheRecord.Group_Mention_4__c = myFeedCacheRecord.Group_Mention_4__c + mentionGrpId;
	            }
	            if(count>252*4 && count<252*5) {
	                myFeedCacheRecord.Group_Mention_5__c = myFeedCacheRecord.Group_Mention_5__c + mentionGrpId;
	            }
	            count +=18;
	        }
	        if(isComment){
	        	myFeedCacheRecord.Feed_Item_Type__c = 'Comment';
	        	myFeedCacheRecord.Feed_Comment_Id__c = feedCommentId;

				fieldList.add(Feed_Cache__c.Feed_Item_Type__c);
				fieldList.add(Feed_Cache__c.Feed_Comment_Id__c);
	        }

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(myFeedCacheRecord, fieldList);
        }catch(Exception e){
        	
        }
    }
    
    @testvisible
    private static void shareFeedElement(String feedElementJson,string source){
    	
    	try{
    		Share__c feedShareRecord = new Share__c();
    		JSONConvertor feedElementActor = (JSONConvertor)JSON.deserialize(feedElementJson,JSONConvertor.class);
    		if(feedElementActor.originalFeedItem!=null){
    			if (String.isBlank(source) && insertShareRecordFlag){
					List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

    				feedShareRecord.Feed_Item_Id__c = feedElementActor.originalFeedItem.id;
	    			fieldList.add(Share__c.Feed_Item_Id__c);
					
					List<String> userIdList = new List<String>();
	    			Map<String,People__c> uIdToPeopleMap = new Map<String,People__c>();
	    			if(feedElementActor.originalFeedItemActor!=null){
	    				userIdList.add(feedElementActor.originalFeedItemActor.id); 
	    			}
	    			if(userIdList.size()>0 && userIdList!=null){
	    				uIdToPeopleMap = Utility.userIdToPeopleMap(userIdList);
	    			}
	    			if(uIdToPeopleMap.containsKey(feedElementActor.originalFeedItemActor.id)){
	    				feedShareRecord.Share_Receiver__c = uIdToPeopleMap.get(feedElementActor.originalFeedItemActor.id).id;
						fieldList.add(Share__c.Share_Receiver__c);
	    			}

	    			feedShareRecord.People__c = UserContext.getCurrentUserInfo.id; 
					fieldList.add(Share__c.People__c);

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().insertAsUser(feedShareRecord, fieldList);

	    			insertShareRecordFlag = false;
    			}
    		}
	    	
    	}catch(DmlException e) {
        	
		}
    }
    
	@testVisible
    public static String getEmailContentBodyForAttachedFile() {
		String contentBody = EmailTemplateService.templatePartMap.get('contentBodyForFiles');
		List<String> formatterList = new List<String>();
		formatterList.add(FILES_ATTACHED_LABEL_PLACEHOLDER);
		contentBody = EmailUtility.format(contentBody, formatterList);
        
		return contentBody;
    }
    
    @testVisible
    private static String getEmailLinkBody(ConnectApi.LinkCapability link, BrandingInfo brandingInfo) {
        String linkBody = EmailTemplateService.templatePartMap.get('linkPostBody');
        List<String> formatterList = new List<String>();
        formatterList.add(getLinkWithFromEmail(link.url));
        formatterList.add(link.urlName);
        formatterList.add(getLinkWithFromEmail(link.url));
        formatterList.add(link.url);
        formatterList.add(brandingInfo.general_primaryColor);
        linkBody = EmailUtility.format(linkBody, formatterList);
        return linkBody;
    }
    
    @testVisible
    private static String getLinkWithFromEmail(String url){
		if(url.containsIgnoreCase('/apex/')){
			List<String> lstURLParts = url.split('#');
			if(lstURLParts.size() > 1) {
				url = lstURLParts[0] + ((lstURLParts[0].indexOf('?') > -1) ? '&' : '?') + 'origin=ne'+ '#' + lstURLParts[1];
			} else {
				url = lstURLParts[0] + ((lstURLParts[0].indexOf('?') > -1) ? '&' : '?') + 'origin=ne';
			}
		}
		return url;
    }
    
	@testVisible
    private static String getEmailPollBody(ConnectApi.PollCapability poll, BrandingInfo brandingInfo) {
    	String pollBody = '';
		List<ConnectApi.FeedPollChoice> pollChoiceList = poll.choices;
		
		List<String> formatterList = new List<String>();
		for(ConnectApi.FeedPollChoice feedChoice : pollChoiceList){
			pollBody = pollBody + '<li style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; list-style-position: inside; margin-left: 5px;">'+ feedChoice.text+'</li>';
		}
		formatterList.add(pollBody);
		String pollPostChoices = EmailTemplateService.templatePartMap.get('pollPostChoicesRow');
		pollPostChoices = EmailUtility.format(pollPostChoices,formatterList);
		formatterList.clear();
		
		String pollTextWithChoices = EmailTemplateService.templatePartMap.get('pollTextWithChoices');
		formatterList.add('{0}');
		formatterList.add(pollPostChoices);
		pollTextWithChoices = EmailUtility.format(pollTextWithChoices,formatterList);
		formatterList.clear();

		return pollTextWithChoices;
    }

	@testVisible
    public static String createEmailTitle(ConnectApi.FeedElement feedObj, List<Simpplr_Content__c> simpplrContentList, String userLanguage) {

		JSONConvertor feedElementObj = (JSONConvertor)JSON.deserialize(JSON.serialize(feedObj),JSONConvertor.class);
        List<ConnectApi.MessageSegment> headerMessage = feedObj.header.messageSegments;
        Integer headerMesaageSegmentsSize = headerMessage.size();

        String feedType = feedElementObj.type;
        String parentId = feedObj.parent.id;
        String createdById = feedElementObj.actor.id;
        String parentType = feedElementObj.parent.type;
        
        String emailTitle ='';
        String firstSegment = '';
        String secondSegment = '';
        String thirdSegment = '';
        String extraLabel = '';
		
		String COMMON_IN = 'common.in';
		String COMMON_ON = 'email.common.on.digest';
		String COMMON_TO = 'common.to';
		
		String COMMON_ARCHIVED_SITE = 'common.inactive';
		String COMMON_PRIVATE_SITE = 'common.private';
		String COMMON_UNLISTED_SITE = 'common.unlisted';

		String COMMON_SHARED_CONTENT = 'email.common.shared.content';
		String COMMON_SHARED_POST = 'email.common.shared.post';

		if(feedElementObj.originalFeedItemActor == null) {
        	for( Integer index=0 ;index<headerMesaageSegmentsSize;index++){
        		ConnectApi.MessageSegment messageSegment = headerMessage.get(index);

        		if(messageSegment instanceof ConnectApi.EntityLinkSegment){
        			if(parentId.startsWithIgnoreCase('005')){
        				if(feedType.equalsIgnoreCase('CollaborationGroupCreated')){
        					if(index == 0){
	    						firstSegment = EmailUtility.htmlBold(messageSegment.text.escapeHtml4());
	    					}
	    					if(index == 2){
	    						thirdSegment = EmailUtility.htmlBold(messageSegment.text.escapeHtml4());
	    					}
        				}else{
							String referenceId = ((ConnectApi.EntityLinkSegment)messageSegment).reference.id;
							String messageSegmentText = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(referenceId) ? FeedDataAdapter.mapUserIdToPeople.get(referenceId).Full_Name__c : null;
        					emailTitle = emailTitle + (EmailUtility.htmlBold((String.isNotBlank(messageSegmentText) ? messageSegmentText : messageSegment.text).escapeHtml4()));
        				}
        			}else if(parentId.startsWith('0F9') || parentId.startsWithIgnoreCase(Utility.getSimpplrContentPrefix())){
						String referenceId = ((ConnectApi.EntityLinkSegment)messageSegment).reference.id;
						String messageSegmentText = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(referenceId) ? FeedDataAdapter.mapUserIdToPeople.get(referenceId).Full_Name__c : null;
        				if(index == 0){
	        				if(!simpplrContentList.isEmpty()){
			               		if(simpplrContentList[0].Name.equalsIgnoreCase(messageSegment.text)) {
			               			String contentTitle = simpplrContentList[0].Title__c.length()>73 ? simpplrContentList[0].Title__c.substring(0,70)+'...' : simpplrContentList[0].Title__c;
			                		firstSegment = EmailUtility.htmlBold(contentTitle.escapeHtml4());
			               		} else {
			               			firstSegment = EmailUtility.htmlBold(messageSegment.text.escapeHtml4());
			               		}
			                }else{
	    						firstSegment = EmailUtility.htmlBold((String.isNotBlank(messageSegmentText) ? messageSegmentText : messageSegment.text).escapeHtml4());
	        				}
    					}else if(index == 2){
    						thirdSegment = EmailUtility.htmlBold((String.isNotBlank(messageSegmentText) ? messageSegmentText : messageSegment.text).escapeHtml4());
    					}else{
    						emailTitle = emailTitle + EmailUtility.htmlBold((String.isNotBlank(messageSegmentText) ? messageSegmentText : messageSegment.text).escapeHtml4());
    					}
    				}else{
    					if(index == 0){
    						firstSegment = EmailUtility.htmlBold(messageSegment.text.escapeHtml4());
    					}
    					if(index == 2){
    						thirdSegment = EmailUtility.htmlBold(messageSegment.text.escapeHtml4());
    					}
    				}
        		} else {
        			if(index == 1) {
						if(parentType.equalsIgnoreCase('CollaborationGroup')){
							ConnectApi.ChatterGroupSummary parentRecord = (ConnectApi.ChatterGroupSummary)feedObj.parent;
							if(parentRecord.isArchived == true) {
								extraLabel = '(' + LocaleContext.getLabel(userLanguage, COMMON_ARCHIVED_SITE) + ')';
							} else if(parentRecord.visibility == ConnectApi.GroupVisibilityType.PRIVATEACCESS) {
								extraLabel = '(' + LocaleContext.getLabel(userLanguage, COMMON_PRIVATE_SITE) + ')';
							} else if(parentRecord.visibility == ConnectApi.GroupVisibilityType.UNLISTEDACCESS) {
								extraLabel = '(' + LocaleContext.getLabel(userLanguage, COMMON_UNLISTED_SITE) + ')';
							}
						
							secondSegment = ' ' + LocaleContext.getLabel(userLanguage, COMMON_IN) + ' ';
	        			} else if(parentType.equalsIgnoreCase('User')){
	        				if(headerMesaageSegmentsSize > 2) {
								emailTitle = emailTitle + ' ' + LocaleContext.getLabel(userLanguage, COMMON_TO) + ' ';
							} 
	        			} else {
	        				secondSegment = ' ' + LocaleContext.getLabel(userLanguage, COMMON_ON) + ' ';
	        			}	
        			} else {
						// 4th messageSegment is to be skipped(its about "posted a file"/"posted a link"/etc msgs) - refer SV2-22243 and linked tickets
        				if(index == 3 && headerMesaageSegmentsSize == 4) {
        					continue;
        				}
        				
						if((!messageSegment.text.containsIgnoreCase(':'))){
        					emailTitle = emailTitle + messageSegment.text.escapeHtml4();
        				}
        			}
	        			
        		}
        	}

        	if(feedType.equalsIgnoreCase('CollaborationGroupCreated')){
        		emailTitle = firstSegment + ' added Site ' + thirdSegment;
        	}else if(!feedType.equalsIgnoreCase('TrackedChange')){
        		emailTitle = thirdSegment+secondSegment + firstSegment + emailTitle + extraLabel;
        	}else{
        		emailTitle = thirdSegment+secondSegment + firstSegment + extraLabel + '<br>' + emailTitle;
        	}
        } else {
        	String siteName = '';
        	String newPostOwner = '';
        	String originalPostOwner = '';
        	String originalPost = '';
        	for( Integer index=0 ;index<headerMesaageSegmentsSize;index++){
        		ConnectApi.MessageSegment messageSegment = headerMessage.get(index);
        		
        		if(messageSegment instanceof ConnectApi.EntityLinkSegment){
	        		 String referenceId = ((ConnectApi.EntityLinkSegment)messageSegment).reference.id;
	        		 if(referenceId.startsWith('0F9')){
	        		 	siteName = ' ' + LocaleContext.getLabel(userLanguage, COMMON_IN) + ' ' + EmailUtility.htmlBold(messageSegment.text.escapeHtml4());
	        		 }else if(referenceId.startsWithIgnoreCase('005')){
						String messageSegmentText = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(referenceId) ? FeedDataAdapter.mapUserIdToPeople.get(referenceId).Full_Name__c : null;
	        		 	if(String.isBlank(originalPost)){
	        		 		newPostOwner = EmailUtility.htmlBold((String.isNotBlank(messageSegmentText) ? messageSegmentText : messageSegment.text).escapeHtml4());
	        		 	}else{
	        		 		originalPostOwner = EmailUtility.htmlBold((String.isNotBlank(messageSegmentText) ? messageSegmentText : messageSegment.text).escapeHtml4());
	        		 	}
	        		 }else if(referenceId.startsWithIgnoreCase('0D5')){
	        		 	originalPost = ' post';
	        		 }
        		}else{
        			 if(index == 1 && parentType.equalsIgnoreCase('CollaborationGroup')){
                        ConnectApi.ChatterGroupSummary parentRecord = (ConnectApi.ChatterGroupSummary)feedObj.parent;
						if(parentRecord.isArchived == true) {
							extraLabel = '(' + LocaleContext.getLabel(userLanguage, COMMON_ARCHIVED_SITE) + ')';
						} else if(parentRecord.visibility == ConnectApi.GroupVisibilityType.PRIVATEACCESS) {
							extraLabel = '(' + LocaleContext.getLabel(userLanguage, COMMON_PRIVATE_SITE) + ')';
						} else if(parentRecord.visibility == ConnectApi.GroupVisibilityType.UNLISTEDACCESS) {
							extraLabel = '(' + LocaleContext.getLabel(userLanguage, COMMON_UNLISTED_SITE) + ')';
						}
                    }
        		}
        	}

			emailTitle = newPostOwner  + ' '
							+ LocaleContext.getLabel(userLanguage, COMMON_SHARED_POST).replace('{{fullName}}', originalPostOwner )
							+ siteName + extraLabel;
        }

		logger.logDebug('NotificationHelper.createEmailTitle() -------------- :: returning emailTitle :: ' + emailTitle);
        return emailTitle;
    }
    
    @testVisible
    public static NotificationMetadata getNotificationInfo(FeedItem feedObj, ConnectApi.FeedElement feedItem){
        
        NotificationMetadata notiMetaData = new NotificationMetadata();

		JSONConvertor feedElementActor = (JSONConvertor)JSON.deserialize(JSON.serialize(feedItem),JSONConvertor.class);
		String actorId = feedElementActor.actor.id;
		String actorName = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(feedElementActor.actor.id) ? FeedDataAdapter.mapUserIdToPeople.get(feedElementActor.actor.id).Full_Name__c : feedElementActor.actor.name;
		String profileOwnerId = feedObj.parentId;
		String profileOwnerName = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(feedObj.parentId) ? FeedDataAdapter.mapUserIdToPeople.get(feedObj.parentId).Full_Name__c : feedObj.parent.name;
		
		notiMetaData.postOwnerMap = new Map<String,String>{actorId=>actorName};
		notiMetaData.profileIdMap = new Map<String,String>{profileOwnerId=>profileOwnerName};
		
		List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
		String notificationText = getNotificationText(messageSegments);
		notiMetaData.snippet = notificationText;
		
		SharePostMetaData shareMetaDataObj = validateSharedPostType(feedItem);
		Boolean isSharePost = shareMetaDataObj.isSharePost!=null?shareMetaDataObj.isSharePost:false;
		notiMetaData.isTrackchange = false;

		if(isSharePost) {
			notiMetaData.sharedPostOwnerMap = new Map<String,String>{shareMetaDataObj.originalPostOwnerId=>shareMetaDataObj.originalPostOwnerName}; 
			
		} else if(feedObj.type == 'TrackedChange') {
			notiMetaData.isTrackchange = true;
		}
	
		if(!(feedObj.type).equalsIgnoreCase('TrackedChange') && !isSharePost) {

			Map<String,String> targetIdMap = getMentionedUserIdMap(feedItem.body.messageSegments);

			if(!targetIdMap.isEmpty()) {

				if(targetIdMap.keySet().contains(profileOwnerId)) {
					//targetIdMap.remove(profileOwnerId);
				}

				if(!targetIdMap.isEmpty() && targetIdMap.keySet().contains(actorId)){
					targetIdMap.remove(actorId);
				}

				if(!targetIdMap.isEmpty()) {
					notiMetaData.mentionedUserMap = targetIdMap;
				} 
			}
		}
        return notiMetaData;

    }
    
    @testVisible
    private static SharePostMetaData validateSharedPostType(ConnectApi.FeedElement feedObject){
        SharePostMetaData shareMetaData = new SharePostMetaData();
        
        JSONConvertor feedElementObj = (JSONConvertor)JSON.deserialize(JSON.serialize(feedObject),JSONConvertor.class);
        if(feedElementObj != null && feedElementObj.originalFeedItemActor != null) {
            shareMetaData.isSharePost = true;
            shareMetaData.originalPostOwnerName = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(feedElementObj.originalFeedItemActor.id) ? FeedDataAdapter.mapUserIdToPeople.get(feedElementObj.originalFeedItemActor.id).Full_Name__c : feedElementObj.originalFeedItemActor.name;
            shareMetaData.originalPostOwnerId = feedElementObj.originalFeedItemActor.id;
        }
        return shareMetaData;
    }
    
    @testVisible
    private static String getEmailBody(List<ConnectApi.MessageSegment> messageSegments, String replysnippet, BrandingInfo brandingInfo, String isReplyOrPost) {
        String body = '';
        List<String> feedBodyTokenList = new List<String>();
        Boolean externalAppLinks = false;

		String recognitionBody = '';
		Boolean isRecognitionBodySet = false;
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            //If the segment is a Text 
            if(messageSegment instanceof ConnectApi.TextSegment){
                ConnectApi.TextSegment textSegments = (ConnectApi.TextSegment) messageSegment;                          
                String tempFeedBody = textSegments.text;
                if(('\n'.equalsIgnoreCase(tempFeedBody)) || ('reply'.equalsIgnoreCase(isReplyOrPost) && String.isBlank(replysnippet))) {
                	tempFeedBody = '';
                }
                tempFeedBody = String.isNotBlank(tempFeedBody)?tempFeedBody:'';
                if(String.isNotBlank(tempFeedBody) && tempFeedBody.containsIgnoreCase(ServiceConstants.FEED_EXT_FILE_SEPRATOR)){
	            	externalAppLinks = true;
	            	tempFeedBody = tempFeedBody.remove(ServiceConstants.FEED_EXT_FILE_SEPRATOR);	            	
                }
				//process recognition body
				if(String.isNotBlank(tempFeedBody) && tempFeedBody.containsIgnoreCase(ServiceConstants.RECOGNITION_FILE_SEPRATOR)){
					recognitionBody = getEmailRecognitionBody(feedId);
					isRecognitionBodySet = true;
                }

                if(String.isNotBlank(tempFeedBody)) {
                    feedBodyTokenList.add(tempFeedBody.unEscapeHTML4());
                }                               
            } else if(messageSegment instanceof ConnectApi.LinkSegment){
                //link segment
                ConnectApi.LinkSegment linkSegments = (ConnectApi.LinkSegment) messageSegment; 
                if(externalAppLinks && linkSegments.url.containsIgnoreCase('provider=')){
					PageReference externalAppPageRefLink = new PageReference(linkSegments.url);
                	String externalAppLinkBody = '';
                	List<String> formatterList = new List<String>();
                	
					externalAppLinkBody = EmailTemplateService.templatePartMap.get('contentBody');
        			
					formatterList.add(linkSegments.url.trim());
					formatterList.add(externalAppPageRefLink.getParameters().get('fileName'));
					if(externalAppPageRefLink.getParameters().get('size') != null){
						formatterList.add(Utility.byteToHumanReadableFormate(Decimal.valueOf(externalAppPageRefLink.getParameters().get('size'))));
					} else{
						formatterList.add('');	
					}
					
					formatterList.add(linkSegments.url.trim());
					formatterList.add(brandingInfo.general_primaryColor);
					formatterList.add(FILES_ATTACHED_LABEL_PLACEHOLDER);
					externalAppLinkBody = EmailUtility.format(externalAppLinkBody, formatterList);							                			                			
					if(String.isNotBlank(externalAppLinkBody)){
						feedBodyTokenList.add(externalAppLinkBody);	
					}		
                } else {                       
	                String tempFeedBody = applyLinksFormatting(linkSegments.url, linkSegments.text, brandingInfo);
	                feedBodyTokenList.add(tempFeedBody);   
                }       
            } else if(messageSegment instanceof ConnectApi.MentionSegment) {
                 //If the segment is a mention
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                //mention segment for user
                if(mentionSegment.record instanceof ConnectApi.UserSummary) {
                    ConnectApi.UserSummary userRecord = (ConnectApi.UserSummary) mentionSegment.record;
					String userRecordName = SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(userRecord.Id) ? FeedDataAdapter.mapUserIdToPeople.get(userRecord.Id).Full_Name__c : userRecord.Name;
                    feedBodyTokenList.add(getMentionLinkForFeedBody(userRecord.Id, userRecordName, 'User', brandingInfo));
                } else if(mentionSegment.record instanceof ConnectApi.ChatterGroupSummary) {
                    //mention segment for groups
                    ConnectApi.ChatterGroupSummary groupRecord = (ConnectApi.ChatterGroupSummary) mentionSegment.record;
                    feedBodyTokenList.add(getMentionLinkForFeedBody(groupRecord.Id, groupRecord.Name, 'Group', brandingInfo));
                    if(groupRecord.additionalLabel != null){
                    	if('Archived'.equalsIgnoreCase(groupRecord.additionalLabel)){
                    		feedBodyTokenList.add('<span style="color:#999999;"> ('+INACTIVE+')</span>');
                    	}else if('Private'.equalsIgnoreCase(groupRecord.additionalLabel)){
                    		feedBodyTokenList.add('<span style="color:#999999;"> ('+groupRecord.additionalLabel+')</span>');
                    	}else if('Unlisted'.equalsIgnoreCase(groupRecord.additionalLabel)){
                    		feedBodyTokenList.add('<span style="color:#999999;"> ('+groupRecord.additionalLabel+')</span>');
                    	}
                    } 
                }
           } else if(messageSegment instanceof ConnectApi.HashtagSegment) {
                //mention segment for topics
                String tempFeedBody='';
                ConnectApi.HashtagSegment topicRecord = (ConnectApi.HashtagSegment) messageSegment;
                if(isUnlisted){
                	tempFeedBody = '#' + topicRecord.tag;
                } else {
	                tempFeedBody = getMentionLinkForFeedBody(topicRecord.tag, topicRecord.tag, 'Topic', brandingInfo);
                }
                feedBodyTokenList.add(tempFeedBody);
            } else if(messageSegment instanceof ConnectApi.MarkupBeginSegment){
		        //html mark up begin
		        ConnectApi.MarkupBeginSegment paraSegments = (ConnectApi.MarkupBeginSegment) messageSegment;                          
		        feedBodyTokenList.add('<'+paraSegments.htmlTag+'>');
		        
		    } else if(messageSegment instanceof ConnectApi.MarkupEndSegment){
		        //html mark up end
		        ConnectApi.MarkupEndSegment paraSegments = (ConnectApi.MarkupEndSegment) messageSegment;
		        feedBodyTokenList.add('</'+paraSegments.htmlTag+'>');
		    }
        }
        
        for(String bodyTokens: feedBodyTokenList) {
            body = body + bodyTokens;
        }

		if(isRecognitionBodySet){
			body += recognitionBody;
		}
        
        return body;
    }
    
    @testVisible
    public static String getNotificationText(List<ConnectApi.MessageSegment> messageSegments) {
        String notificationText = '';
        List<String> feedTokenList = new List<String>();
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            //If the segment is a Text
            if(messageSegment instanceof ConnectApi.TextSegment){
                ConnectApi.TextSegment textSegments = (ConnectApi.TextSegment) messageSegment;                          
                String tempFeedBody = textSegments.text;
                tempFeedBody = String.isNotBlank(tempFeedBody)?tempFeedBody:null;
                if(String.isNotBlank(tempFeedBody)) {
                    feedTokenList.add(tempFeedBody.unescapeHtml4());
                }                 
            } else if(messageSegment instanceof ConnectApi.MentionSegment) {
                //If the segment is a mention
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
				if(SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(mentionSegment.record.id)) {
					feedTokenList.add('@'+FeedDataAdapter.mapUserIdToPeople.get(mentionSegment.record.id).Full_Name__c);
				} else {
                	feedTokenList.add(mentionSegment.text);
				}
           } else if(messageSegment instanceof ConnectApi.LinkSegment){
                //link segment
                ConnectApi.LinkSegment linkSegments = (ConnectApi.LinkSegment) messageSegment;
                feedTokenList.add(linkSegments.text);          
            } else if(messageSegment instanceof ConnectApi.HashtagSegment) {
                //mention segment for topics
                ConnectApi.HashtagSegment topicRecord = (ConnectApi.HashtagSegment) messageSegment;
                feedTokenList.add(topicRecord.text);
            }
        }
        
        for(String token : feedTokenList) {
            notificationText = notificationText + ' ' + token;
        }
        
        return notificationText;
    }
    
	/**
	 * @description getNotificationText
	 * @param messageSegment
	 */
	public static String getNotificationText(JSONFeedElementWrapper.MessageSegments messageSegment) {
        String notificationText = '';
            //If the segment is a Text
		if(messageSegment.type == 'Mention'){
			if(FeedDataAdapter.mapUserIdToPeople.get(messageSegment.record.id) != null) {
				notificationText = '@'+FeedDataAdapter.mapUserIdToPeople.get(messageSegment.record.id).Full_Name__c;
			} else {
				notificationText = messageSegment.text;
			}                
		} else {
			notificationText = messageSegment.text;
		}
        
        return notificationText;
    }
    
    @testVisible
    private static Map<String,String> getMentionedUserIdMap(List<ConnectApi.MessageSegment> messageSegments){
        Map<String,String> mentionedUserIdMap = new Map<String,String>();
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if(messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                if(mentionSegment.record instanceof ConnectApi.UserSummary) {
                    ConnectApi.UserSummary userRecord = (ConnectApi.UserSummary) mentionSegment.record;
                    mentionedUserIdMap.put(userRecord.Id, (SimpplrContext.isFeatureEnabled('Full_External_Search') && FeedDataAdapter.mapUserIdToPeople.containsKey(userRecord.Id) ? FeedDataAdapter.mapUserIdToPeople.get(userRecord.Id).Full_Name__c : userRecord.name));
                }
            }
        }
        return mentionedUserIdMap;
    }
    
    @testVisible
    private static Map<String,String> getMentionedGroupIdMap(List<ConnectApi.MessageSegment> messageSegments){
        Map<String,String> mentionedGroupIdMap = new Map<String,String>();
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if(messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                if(mentionSegment.record instanceof ConnectApi.ChatterGroupSummary) {
                    ConnectApi.ChatterGroupSummary grpRecord = (ConnectApi.ChatterGroupSummary) mentionSegment.record;
                    mentionedGroupIdMap.put(grpRecord.Id,grpRecord.name);
                }
            }
        }
        return mentionedGroupIdMap;
    }

    @testVisible 
    public static String applyLinksFormatting(String linkUrl, String linkName, BrandingInfo brandingInfo) {
    	return '<a style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" href="' + linkUrl + '">' + linkName + ' </a>';
    }
    
    @testVisible 
    public static String getMentionLinkForFeedBody(String id, String name, String mentionType, BrandingInfo brandingInfo) {
    	String mentionLink;
    	if('User'.equalsIgnoreCase(mentionType)) {
    		mentionLink = '<a style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" href=\"' + baseUrl + Page.PageRedirector.getUrl() + '?userId=' + id +'&pageToRedirect='+Pages.ProfileAbout+ '&origin=ne\">@' + name.escapeHtml4() + ' </a>';
    	} else if('Group'.equalsIgnoreCase(mentionType)) {
    		mentionLink = '<a  style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" href=\"' + baseUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + id + '&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=ne\">@' + name.escapeHtml4() + ' </a>';
    	} else if('Topic'.equalsIgnoreCase(mentionType)) {
			mentionLink = '<a style="color: #'+brandingInfo.general_primaryColor+'; text-decoration: none; word-break: break-word;" href=\"' + baseUrl+Page.PageRedirector.getUrl() + '?topicName=' + EncodingUtil.urlEncode(name, 'utf-8')+ '&pageToRedirect='+Pages.TopicFeed+'&origin=ne\">#' + name.escapeHtml4() + ' </a>';
    	}
    	return mentionLink;
    }
	
    public class NotificationDigestWrapper{
    	public Integer count;
    	public Set<String> objectId;
    }

	public static String getEmailRecognitionBody(String feedElementId) {
		FeedElementWrapper.RecognitionResponseInfo recognitionResponseObj = getRecognition(feedElementId);
		List<PeopleLiteWrapper.PeopleMinWrapper> receiversPeopleList = recognitionResponseObj.recognitionAwardedTo;

		String recognitionBody = '<table style="border-collapse:separate;width:100%"><tbody>';
		//Add AwardName
		recognitionBody += '<tr><td style="font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 16px;font-weight: bold;margin:0;margin-bottom:15px;text-align: center;"><p style="font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 16px;font-weight: bold;margin:0;">'+recognitionResponseObj.recognitionAwardName+'</p></td></tr><hr style=";width: 100px;border: none;border-top: 1px solid #cccccc;">';
		
		//Add Receivers deatils
		Integer totalReceivers = receiversPeopleList.size();
		recognitionBody += '<tr><td style="font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 14px;margin:0;margin-bottom:15px;text-align: center;"><p style="font-family:\'Helvetica Neue\',Helvetica,Arial,sans-serif;font-size: 14px;margin: 0;margin-bottom:15px">';
		if(totalReceivers == 1){
			recognitionBody += '<b>'+receiversPeopleList[0].name+'</b>';

		} else if(totalReceivers == 2){
			recognitionBody += '<b>'+receiversPeopleList[0].name+'</b> and <b>'+receiversPeopleList[1].name+'</b>';

		} else if(totalReceivers == 3){
			recognitionBody += '<b>'+receiversPeopleList[0].name+'</b>, <b>'+receiversPeopleList[1].name+'</b> and <b>'+receiversPeopleList[2].name+'</b>';

		} else {
			String remainingTotalReceivers = String.valueOf(totalReceivers-3);
			remainingTotalReceivers += remainingTotalReceivers == '1' ? ' other' : ' others';
			recognitionBody += '<b>'+receiversPeopleList[0].name+'</b>, <b>'+receiversPeopleList[1].name+'</b>, <b>'+receiversPeopleList[2].name+'</b> and <b> '+remainingTotalReceivers+'</b>';
		}
		recognitionBody += '</p></td></tr>';

		recognitionBody += '</tbody></table>';

		return recognitionBody;
    }  

	/**
	 * @description method to get recognition record
	 * @param feedElementId - String
	 * @return FeedElementWrapper.RecognitionInfo
	 */
	public static FeedElementWrapper.RecognitionResponseInfo getRecognition(String feedElementId) {
		FeedElementWrapper.RecognitionResponseInfo recognitionInfoObj = new FeedElementWrapper.RecognitionResponseInfo();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', feedElementId);
		String query = 'SELECT Id, Feed_Element_Id__c, Award_Name__c, Award_Id__c, Award_receviers__c, Award_Giver__c FROM Recognition__c WHERE Feed_Element_Id__c =:soqlParam1 ORDER BY CreatedDate DESC';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Recognition__c> listOfRecognition = (List<Recognition__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(listOfRecognition.size() > 0){
			List<PeopleLiteWrapper.PeopleMinWrapper> recognitionPeopleResponse = getPeopleFromIds(listOfRecognition[0].Award_receviers__c);
			recognitionInfoObj.recognitionAwardedTo = recognitionPeopleResponse;
			recognitionInfoObj.recognitionAwardId = listOfRecognition[0].Award_Id__c;
			recognitionInfoObj.recognitionAwardName = listOfRecognition[0].Award_Name__c;
			recognitionInfoObj.feedElementId = listOfRecognition[0].Feed_Element_Id__c;
		}
		
		return recognitionInfoObj;
	}

	private static List<PeopleLiteWrapper.PeopleMinWrapper> getPeopleFromIds (String recognitionAwardedTo) {
		List<PeopleLiteWrapper.PeopleMinWrapper> recognitionPeopleResponse = new List<PeopleLiteWrapper.PeopleMinWrapper>();
		List<String> peopleIds = new List<String>();
		peopleIds.addAll(recognitionAwardedTo.split(':'));
		List<PeopleLiteWrapper.PeopleMinWrapper> peopleWrapperList = new List<PeopleLiteWrapper.PeopleMinWrapper>(); 
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleIds);
    	String query = 'SELECT Id, full_Name__c, User__c, user__r.SmallPhotoURL FROM People__c WHERE Id IN :soqlParam1 ORDER BY full_Name__c ASC';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(People__c people:peopleList){
			PeopleLiteWrapper.PeopleMinWrapper peopleLite = new PeopleLiteWrapper.PeopleMinWrapper();
			peopleLite.peopleId = people.Id;
			peopleLite.sfUserId = people.User__c;
			peopleLite.name = people.full_Name__c;
			peopleLite.img = people.user__r.SmallPhotoURL.endsWith('005/T') ? null : people.user__r.SmallPhotoURL;
			peopleWrapperList.add(peopleLite);
		}

		return peopleWrapperList;
	}
}