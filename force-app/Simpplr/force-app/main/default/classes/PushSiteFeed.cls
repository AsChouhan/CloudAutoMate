public with sharing class PushSiteFeed {
	public static final String KEY_EMAIL_NOTIFICATION_ERROR_SLACK_SUBJECT = 'email.notification.error.slack.subject';
	public static final String KEY_EMAIL_NOTIFICATION_ERROR_SLACK_BODY = 'email.notification.error.slack.body';
	public static final String KEY_EMAIL_NOTIFICATION_ERROR_SLACK_SUBJECT_PLURAL = 'email.notification.error.slack.subject_plural';
	public static final String KEY_EMAIL_NOTIFICATION_ERROR_SLACK_BODY_ONE_PLURAL = 'email.notification.error.slack.body_one_plural';
	public static final String KEY_EMAIL_NOTIFICATION_ERROR_SLACK_BODY_TWO_PLURAL = 'email.notification.error.slack.body_two_plural';

	public static final String INACTIVE = 'Inactive';
	public static String deepLinkUrl = BaseCtrl.salesForceBaseUrl;
		
	public class QueueablePushSiteFeed implements System.Queueable, Database.AllowsCallouts {
		
		public String feedItemJSON;
		public String slackThumbUrl; 
		public String feedCommentJSON;  
	       
		public QueueablePushSiteFeed(String feedItemJSON, String slackThumbUrl, String feedCommentJSON) {
			this.feedItemJSON = feedItemJSON;
			this.slackThumbUrl = slackThumbUrl;
			this.feedCommentJSON = feedCommentJSON;
	    } 
	       
	    public void execute(System.QueueableContext ctx) {
			List<Simpplr_Site__c> SiteList = [select id, Name, Chatter_Group_Id__c, Site_Type__c,Slack_Access_Token__c, Slack_Channel_Id__c, 
													Slack_Comment_Enabled__c, Slack_Post_Enabled__c , Slack_Channel_Name__c, Slack_Url__c,Microsoft_Teams_Comment_Enabled__c, Microsoft_Teams_Integration_Enabled__c, 
													Slack_Site_Manager__c, Slack_Site_Manager__r.User__c, Slack_Site_Manager__r.User__r.Name, Slack_Site_Manager__r.User__r.UserName, Slack_Integration_Enabled__c, Is_Content_Unfurl_Enabled__c, 
													Microsoft_Teams_Site_Manager__c, Microsoft_Teams_Site_Manager__r.User__c, Microsoft_Teams_Site_Manager__r.User__r.Name, Microsoft_Teams_Site_Manager__r.User__r.UserName,
													Microsoft_Teams_Webhook_URL__c, Is_Deleted__c, External_Apps_Site_Config_Json__c From Simpplr_Site__c where ((Slack_Channel_Id__c != null AND Is_Deleted__c=false) OR 
													Slack_Integration_Enabled__c = true OR (Microsoft_Teams_Integration_Enabled__c = true  AND Is_Deleted__c=false)) WITH SECURITY_ENFORCED];	    	
			Set<String> userIds = new Set<String>();
			for (Simpplr_Site__c siteObj : SiteList) {
				userIds.add(siteObj.Slack_Site_Manager__r.User__c);
				userIds.add(siteObj.Microsoft_Teams_Site_Manager__r.User__c);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
	    	if(feedItemJSON != null) {
				if(SimpplrContext.slackIntegrationEnabled){
					pushSlackNotification(feedItemJSON, slackThumbUrl, SiteList, feedCommentJSON);	
				}   
				if(SimpplrContext.microsoftTeamsIntegrationEnabled){
					pushMicrosoftTeamsNotification(feedItemJSON, SiteList);	
				}
			}
		}
	}
	
	public with sharing class QueueablePushSiteFeedWithImages implements System.Queueable, Database.AllowsCallouts {
		public Simpplr_Site__c siteObj;
		public MicrosoftTeamsService.MicrosoftTeamsWrapper microsoftTeamsObj;
		
		public QueueablePushSiteFeedWithImages(Simpplr_Site__c siteObj, MicrosoftTeamsService.MicrosoftTeamsWrapper microsoftTeamsObj) {
			this.siteObj = siteObj;
	    	this.microsoftTeamsObj = microsoftTeamsObj;
	    }
	    
	    public void execute(System.QueueableContext ctx) {
	        postToteams(siteObj, microsoftTeamsObj);
	
		}  	    
	}		 
		
		
    public class BrandingInfo{
    	public String header_backgroundColor;
    	public String header_iconColor;
    	public String footer_backgroundColor;
    	public String footer_textColor;
    	public String general_primaryColor;
		public String general_lightModelinkColor;				//CONT-10737
		public String general_darkModelinkColor;				//CONT-10737
		public String general_brandingAnchorPrimaryColor;				//CONT-10737


    	public String header_preset;
    	public String footer_preset;
    	public String logo_url;
    }
    	
	public static void pushSlackNotification(String jsonFeedItem, String thumbUrl, List<Simpplr_Site__c> SiteObjListInParam, String feedCommentJSON){
		String brandingJson = SimpplrContext.SABrandingJSON;
		BrandingInfo brandingInfo  = (BrandingInfo)JSON.deserialize(brandingJson,BrandingInfo.class);
		String primaryColor = brandingInfo.general_primaryColor;
		JSONFeedElementWrapper feedElementWrapperObj = JSONFeedElementWrapper.parse(jsonFeedItem);
		FeedDataAdapter.getUserIdsToConvert(feedElementWrapperObj);
		FeedDataAdapter.getPeopleFromUserIds();
		Map<String,Simpplr_Content__c> simpContentMap = new Map<String,Simpplr_Content__c>();
		String parentGroupId = '';
		if(feedElementWrapperObj.parent.id.subString(0,3).equalsIgnoreCase(Utility.getSimpplrContentPrefix())){
			simpContentMap = new Map<String,Simpplr_Content__c>([select id,Name, Title__c, Site__r.Chatter_Group_Id__c, Site__c, Primary_Author__r.Full_Name__c, Primary_Author__r.Email__c, Primary_Author__c, Type__c  from Simpplr_content__c where id =:feedElementWrapperObj.parent.id ]);
			parentGroupId = simpContentMap.get(feedElementWrapperObj.parent.id).Site__r.Chatter_Group_Id__c;
		} else if(feedElementWrapperObj.parent.id.subString(0,3).equalsIgnoreCase('0F9')){
			simpContentMap = new Map<String,Simpplr_Content__c>();
			parentGroupId = feedElementWrapperObj.parent.id;
		}
		Set<String> groupIdSet = new Set<String>();
		groupIdSet.add(parentGroupId);
		List<JSONFeedElementWrapper.MessageSegments> postBodyMessSegment = feedElementWrapperObj.body.messagesegments;
        String commentFallBacktext = '';
		if(feedElementWrapperObj.capabilities.comments.page.items != null && !feedElementWrapperObj.capabilities.comments.page.items.isEmpty()){
			List<JSONFeedElementWrapper.Items_Z> commentItemsList = feedElementWrapperObj.capabilities.comments.page.items;
        	Integer commentItemsListSize = commentItemsList.size();
        	List<JSONFeedElementWrapper.MessageSegments_Y> commntBodySegments = new List<JSONFeedElementWrapper.MessageSegments_Y>();
        	for(JSONFeedElementWrapper.Items_Z  items : commentItemsList) {
        		if(commentItemsListSize == 1){
	            	commntBodySegments = items.body.messageSegments;
	            	commentFallBacktext = items.body.text.unescapeHtml4();
        		}
        		commentItemsListSize--;
        	}
			groupIdSet.addAll(getCommentMentionedGroupMap(commntBodySegments).keySet());
			groupIdSet.addAll(getMentionedGroupIdSet(feedElementWrapperObj.id));
			
		} else {
			groupIdSet.addAll(getPostMentionedGroupMap(postBodyMessSegment).keySet());
		} 
		List<Simpplr_Site__c> SiteObjList = new List<Simpplr_Site__c>();

		for(Simpplr_Site__c siteObj : SiteObjListInParam){
			if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && siteObj.Slack_Integration_Enabled__c){
				SiteObjList.add(siteObj);
			} else if(siteObj.Slack_Channel_Id__c != null && (siteObj.Is_Deleted__c==false)){
				SiteObjList.add(siteObj);	
			}
		}
		List<Simpplr_Site__c> simpplrSiteObjList = new List<Simpplr_Site__c>();
		String parentChannelId = '';
		boolean isParentSitePrivate = false;
		Set<String> targetCGIdSet = new Set<String>();
		ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
		for(Simpplr_Site__c siteObj : SiteObjList){
			if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && siteObj.External_Apps_Site_Config_Json__c!=null){
				externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
				if(externalAppsSiteConfig != null && externalAppsSiteConfig.SlackSiteConfig != null && externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions != null && (externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions.contains('slackPosts') || externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions.contains('slackPostAndReplies')) && siteObj.Chatter_Group_Id__c.equalsIgnoreCase(parentGroupId) && groupIdSet.contains(siteObj.Chatter_Group_Id__c)){
					simpplrSiteObjList.add(siteObj);
					parentChannelId = externalAppsSiteConfig.SlackSiteConfig.slackChannelId;
					isParentSitePrivate = 'Public'.equalsIgnoreCase(siteObj.Site_Type__c) == false ? true : false;
				}
			} else if(siteObj.Chatter_Group_Id__c.equalsIgnoreCase(parentGroupId) && groupIdSet.contains(siteObj.Chatter_Group_Id__c)
				&& (siteObj.Slack_Post_Enabled__c == true || siteObj.Slack_Comment_Enabled__c == true)){
				parentChannelId = siteObj.Slack_Channel_Id__c;
				simpplrSiteObjList.add(siteObj);
				isParentSitePrivate = 'Public'.equalsIgnoreCase(siteObj.Site_Type__c) == false ? true : false;
			}
			targetCGIdSet.add(siteObj.Chatter_Group_Id__c);
		}
		
		for(Simpplr_Site__c siteObj : SiteObjList){
			if(!(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded) && !siteObj.Slack_Channel_Id__c.equalsIgnoreCase(parentChannelId) && isParentSitePrivate == false && groupIdSet.contains(siteObj.Chatter_Group_Id__c)
				&& (siteObj.Slack_Post_Enabled__c == true || siteObj.Slack_Comment_Enabled__c == true)){
				simpplrSiteObjList.add(siteObj);
			}
		}
		
		Set<String> channelIdSet = new Set<String>();
		Map<String,Set<String>> channelToCGIdsMap= new Map<String,Set<String>>();
		Map<String,String> siteIdToSlackSiteManagerAccessTokenMap = new Map<String,String>();
		Set<String> siteManagerIdSet = new Set<String>();
		for(Simpplr_Site__c siteObj : simpplrSiteObjList){
			siteManagerIdSet.add(siteObj.Slack_Site_Manager__c);
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteManagerIdSet);
		soqlParamMap.put('soqlParam2', IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE);
		String queryStr = 'SELECT People__c, Access_Token__c from People_Integration__c WHERE People__c IN: soqlParam1 AND Name=:soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		Map<String,String> peopleIdToAccessTokenMap = new Map<String,String>();
		for(People_Integration__c peopleInteg : peopleIntegList){
			peopleIdToAccessTokenMap.put(peopleInteg.People__c, peopleInteg.Access_Token__c);
		}
			
		for(Simpplr_Site__c siteObj : simpplrSiteObjList){
			if((SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && siteObj.Slack_Integration_Enabled__c) || String.isNotBlank(peopleIdToAccessTokenMap.get(siteObj.Slack_Site_Manager__c))){
				Boolean postAndcommentEnabled = false;
				Boolean postEnabled = false;
				if(siteObj.External_Apps_Site_Config_Json__c!=null){
					externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
					if(externalAppsSiteConfig!=null && externalAppsSiteConfig.SlackSiteConfig != null && externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions.size()>0){
						if(externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions.contains('slackPostAndReplies')){
							postAndcommentEnabled = true;
						}
						if(externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions.contains('slackPosts')){
							postEnabled = true;
						}
					}		
				}
				
				if(siteObj.Slack_Post_Enabled__c || siteObj.Slack_Comment_Enabled__c || postEnabled || postAndcommentEnabled){
					String fallbackText = '\n' + UserContext.peopleName + ': ';
					String viewLink = '';
					String actor = '';
					String postBody = '';
					String commentBody = '';
					String originalPostBody = '';
					String dateFooter;
					String replyId = '';
					String slackTitle = SimpplrContext.applicationName+' - '+siteObj.Name;
					if(siteObj.Site_Type__c.equalsIgnoreCase('Private')){
						slackTitle = slackTitle + ' (Private) ';
					} else if(siteObj.Site_Type__c.equalsIgnoreCase('Unlisted')){
						slackTitle = slackTitle + ' (Unlisted) ';
					}
					Boolean isComment = false;
					if(feedElementWrapperObj.capabilities.comments.page.items != null && !feedElementWrapperObj.capabilities.comments.page.items.isEmpty()){
						actor = getSlackLink(UserContext.peopleName, deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + UserInfo.getUserId() +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack')+' replied';
						viewLink = getSlackLink('View Reply', deepLinkUrl + Page.app.getUrl()+'?u=/feed/'+feedElementWrapperObj.id+'&origin=slack');
						actor = actor +' - '+viewLink;
						commentBody = getCommentBody(feedElementWrapperObj, 'slack');
						originalPostBody = getOriginalPostSnippet(feedElementWrapperObj, simpContentMap);
						dateFooter = getDateFooter(feedElementWrapperObj);
						isComment = true;
					} else {
						actor = createSlackTitle(feedElementWrapperObj,simpContentMap.values());
						viewLink = getSlackLink('View Post', deepLinkUrl + Page.app.getUrl()+'?u=/feed/'+feedElementWrapperObj.id+'&origin=slack');
						actor = actor +' - '+viewLink;
						postBody = getPostBody(feedElementWrapperObj, 'slack');
					}
					if(isComment == false || (SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && isComment == true && postAndcommentEnabled) || (isComment == true && siteObj.Slack_Comment_Enabled__c)){
						SlackAttachmentWrapper slackAttachWrapObj = new SlackAttachmentWrapper();
						String category = '';
						if(isComment){
							category = 'Promote_Comment';
							fallbackText += commentFallBacktext;
							slackAttachWrapObj = getSlackChatPostJson(primaryColor,actor+'\n'+commentBody+'\n\n\n'+originalPostBody, dateFooter, fallbackText, thumbUrl);
						} else {
							category = 'Promote_Feed';
							fallbackText += String.isNotBlank(feedElementWrapperObj.body.text) ? feedElementWrapperObj.body.text.unescapeHtml4() : '';
							if(feedElementWrapperObj.capabilities.content != null){
								if(String.isBlank(feedElementWrapperObj.body.text)){
									fallbackText += 'posted a file.';
								}
							} 
							if(feedElementWrapperObj.capabilities.link != null) {
								if(String.isBlank(feedElementWrapperObj.body.text)){
									fallbackText += 'posted a link.';
								}
							}
							slackAttachWrapObj = getSlackChatPostJson(primaryColor,actor+'\n'+postBody,dateFooter, fallbackText, thumbUrl);
						}
						SlackFeedWrapper slackFeedWrapperObj = new SlackFeedWrapper();
						slackFeedWrapperObj.slackAttachment = new List<SlackAttachmentWrapper>{slackAttachWrapObj};
						String attachmentsJson = Json.serialize(slackFeedWrapperObj.slackAttachment);
						if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && siteObj.Slack_Integration_Enabled__c){
							Map<String, String> siteFeedDetail = new Map<String, String>();
							siteFeedDetail.put('postId', feedElementWrapperObj.id);
							siteFeedDetail.put('siteId', siteObj.Id);
							siteFeedDetail.put('siteName', siteObj.Name);
							siteFeedDetail.put('imgURL', slackAttachWrapObj.imgURL);
							siteFeedDetail.put('siteType',siteObj.Site_Type__c);
							siteFeedDetail.put('isUnfurlEnabled', String.valueOf(siteObj.Is_Content_Unfurl_Enabled__c));

							Map<String, Object> feedCommentMap = (Map<String, Object>) JSON.deserializeUntyped(feedCommentJSON);
							if(feedCommentMap != null && feedCommentMap.get('body') != null){
								Map<String, Object> comentBodyMap = (Map<String, Object>) feedCommentMap.get('body');
								List<Object> messageSegmentsList = (List<Object>) comentBodyMap.get('messageSegments');

								siteFeedDetail.put('feedMessageSegments', JSON.serialize(messageSegmentsList));
							} else {

								siteFeedDetail.put('feedMessageSegments', JSON.serialize(postBodyMessSegment));
							}

							externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
							String channelId = '';
							if(externalAppsSiteConfig!=null && externalAppsSiteConfig.SlackSiteConfig!=null && externalAppsSiteConfig.SlackSiteConfig.slackChannelId!=null){
								channelId = externalAppsSiteConfig.SlackSiteConfig.slackChannelId;
							}
							siteFeedDetail.put('channelId', channelId);
							siteFeedDetail.put('slackUserId', externalAppsSiteConfig.SlackSiteConfig.slackConnectedUserId);
							String parentType = PageContext.namespacePrefix + 'Simpplr_Content__c';
							if((postEnabled || postAndcommentEnabled)&& 'Promote_Feed'.equalsIgnoreCase(category) && !(feedElementWrapperObj.type.equalsIgnoreCase('LinkPost') && feedElementWrapperObj.parent.type.equalsIgnoreCase(parentType))){
								siteFeedDetail.put('body', postBody);
								siteFeedDetail.put('category', category);
								siteFeedDetail.put('replyId', '');
								new SlackHelper().createSiteFeed(siteFeedDetail);
							} else if(postAndcommentEnabled && 'Promote_Comment'.equalsIgnoreCase(category)){
								List<JSONFeedElementWrapper.Items_Z> commentItemsList = feedElementWrapperObj.capabilities.comments.page.items;
								replyId = commentItemsList[commentItemsList.size()-1].id ;
								siteFeedDetail.put('body', commentBody);
								siteFeedDetail.put('category', category);
								siteFeedDetail.put('replyId', replyId);
								new SlackHelper().createSiteFeed(siteFeedDetail);
							}
							
						} else {
							Http h = new Http();
							HttpRequest req = new HttpRequest();
							String endPoint = 'https://slack.com/api/chat.postMessage?token='+peopleIdToAccessTokenMap.get(siteObj.Slack_Site_Manager__c)+
							'&channel='+EncodingUtil.urlEncode(siteObj.Slack_Channel_Id__c,'UTF-8')+
							'&username='+EncodingUtil.urlEncode(slackTitle,'UTF-8');
							req.setEndpoint(endPoint);
							req.setHeader('Content-Type','application/x-www-form-urlencoded');
							req.setBody('attachments='+EncodingUtil.urlEncode(attachmentsJson,'UTF-8'));
							req.setMethod('POST');
							req.setTimeout(60000);
							HttpResponse res = h.send(req);
							Map<String,Object> resBodyObj = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
							if(resBodyObj.get('ok') == false){
								channelIdSet.add(siteObj.Slack_Channel_Id__c);
								if(channelToCGIdsMap.get(siteObj.Slack_Channel_Id__c) == null){
									channelToCGIdsMap.put(siteObj.Slack_Channel_Id__c, new Set<String>());
								}
								channelToCGIdsMap.get(siteObj.Slack_Channel_Id__c).add(siteObj.Chatter_Group_Id__c);
							}
						}
					}
				}
			}
		}
		if(!(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded)){
			for(Simpplr_Site__c siteObj : SiteObjList){
				if(channelIdSet.contains(siteObj.Slack_Channel_Id__c)){
					targetCGIdSet.add(siteObj.Chatter_Group_Id__c);
				}
				if(channelToCGIdsMap.get(siteObj.Slack_Channel_Id__c) == null){
					channelToCGIdsMap.put(siteObj.Slack_Channel_Id__c, new Set<String>());
				}
				channelToCGIdsMap.get(siteObj.Slack_Channel_Id__c).add(siteObj.Chatter_Group_Id__c);
				
			}
			
			if(channelIdSet.isEmpty() == false){
				handleSlackException(channelToCGIdsMap, targetCGIdSet, SiteObjList);
			}
		}
		
	}
	
    @testvisible
    private static SlackAttachmentWrapper getSlackChatPostJson(String color, String text, String footer, String fallbackText, String thumbUrl){
    	SlackAttachmentWrapper slackWrapObj = new SlackAttachmentWrapper();
    	slackWrapObj.color = color;
    	slackWrapObj.text = text;
    	slackWrapObj.footer = footer;
    	slackWrapObj.fallback = fallbackText;
    	slackWrapObj.imgURL = thumbUrl;
    	slackWrapObj.mrkdwn_in = new List<String>{'text'};
    	return slackWrapObj;
    }
    
    public class SlackAttachmentWrapper{
    	public String color;
    	public String text;
    	public String footer;
    	public String fallback;
    	public String imgURL;
    	public List<String> mrkdwn_in;
    }
    public class SlackFeedWrapper{
    	public List<SlackAttachmentWrapper> slackAttachment;
    }
    
    
    @testvisible
    private static String getSlackLink(String name, String url){
    	String pipe = '|';
		url = (String.isNotBlank(SimpplrContext.DeeplinkingRedirectURL)?SimpplrContext.DeeplinkingRedirectURL: ServiceConstants.SIMPPLR_DEEPLINKING_REDIRECTOR_URL) + EncodingUtil.urlEncode(url, 'UTF-8');
    	return '<'+url+pipe+name+'>';
    }
    @testvisible
    private static String getPostBody(JSONFeedElementWrapper feedElementWrapperObj, String appName){
    	String postBody='';
		List<JSONFeedElementWrapper.MessageSegments> bodyMessSegment = feedElementWrapperObj.body.messagesegments;
		Integer orderListIndex = 1;
        Integer listTypeMarker = 0;// 1 = ordered -1= unordered
		for(JSONFeedElementWrapper.MessageSegments bodySegments : bodyMessSegment) {
            if(bodySegments.type =='Mention') {
                if(bodySegments.record.type == 'User') {
                	if('slack'.equalsIgnoreCase(appName)){
                    	postBody = postBody + getSlackLink('@'+(FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.displayName).unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + bodySegments.record.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
                	
                	} else if('teams'.equalsIgnoreCase(appName)){
                		postBody = postBody + getMicrosoftTeamsLink('@'+(FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.displayName).unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + bodySegments.record.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=microsoftteams');
                	} 
                } else if(bodySegments.record.type == 'CollaborationGroup') {
                	String additionalInfo = '';
                	if(String.isNotBlank(bodySegments.record.additionalLabel)){
                		if(bodySegments.record.additionalLabel.containsIgnoreCase('Archived')){
                	 		additionalInfo = ' ('+INACTIVE+')';
                	 	}else{
                			additionalInfo = ' ('+bodySegments.record.additionalLabel+')';	
                	 	}
                	}
                	if('slack'.equalsIgnoreCase(appName)){
                    	postBody = postBody + getSlackLink('@'+bodySegments.record.name.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + bodySegments.record.id + '&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=slack')+additionalInfo;
                	
                	} else if('teams'.equalsIgnoreCase(appName)){
                		postBody = postBody + getMicrosoftTeamsLink('@'+bodySegments.record.name.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + bodySegments.record.id + '&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=microsoftteams')+additionalInfo;	
                	}	
                }
            }            
            if(bodySegments.type =='Text') {
                postBody = postBody + bodySegments.text.unEscapeHtml4();
            }
            if(bodySegments.type =='Link') {
            	if('slack'.equalsIgnoreCase(appName)){
                	postBody = postBody + getSlackLink(bodySegments.text.unEscapeHtml4(),bodySegments.url);
                
            	} else if('teams'.equalsIgnoreCase(appName)){
            		postBody = postBody + getMicrosoftTeamsLink(bodySegments.text.unEscapeHtml4(),bodySegments.url);
            	}
            }
            if(bodySegments.type =='HashTag') {
            	if('slack'.equalsIgnoreCase(appName)){
                	postBody = postBody + getSlackLink('#' + bodySegments.tag.unEscapeHtml4() , deepLinkUrl+Page.PageRedirector.getUrl() + '?topicName=' + EncodingUtil.urlEncode(bodySegments.tag, 'utf-8')+ '&pageToRedirect='+Pages.TopicFeed+'&origin=slack');
            	
            	} else if('teams'.equalsIgnoreCase(appName)){
            		postBody = postBody + getMicrosoftTeamsLink('#' + bodySegments.tag.unEscapeHtml4() , deepLinkUrl+Page.PageRedirector.getUrl() + '?topicName=' + EncodingUtil.urlEncode(bodySegments.tag, 'utf-8')+ '&pageToRedirect='+Pages.TopicFeed+'&origin=microsoftteams');
            	}	
            }
            
            if(bodySegments.type =='MarkupBegin'){
            	if(bodySegments.htmlTag.equalsIgnoreCase('ul')){
        			listTypeMarker = -1;
        			if('slack'.equalsIgnoreCase(appName)){
        				postBody = postBody +'\n';
        			} else if('teams'.equalsIgnoreCase(appName)){
        				postBody = postBody +'<ul>';	
        			}	
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('ol')){
            		listTypeMarker = 1;
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody +'\n';
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody +'<ol>';		
            		}	
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('b')){
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody + '*';
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '<strong>';	
            		}	
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('i')){
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody + '_';
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '<i>';	
            		}
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('s')){
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody + '~';
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '<s>';	
            		}	
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('u')){
            		// No alternative found in slack
            		if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '<u>';	
            		}
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('p')){
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody + '\n';
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '<p>';	
            		}	
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('li')){
            		if(listTypeMarker == -1){
            			if('slack'.equalsIgnoreCase(appName)){
	            			postBody = postBody +'• ';
            			} else if('teams'.equalsIgnoreCase(appName)){
            				postBody = postBody +'<li>';	
            			}
            		} else if(listTypeMarker == 1){
            			if('slack'.equalsIgnoreCase(appName)){
	            			postBody = postBody + orderListIndex+'. ';
	            			orderListIndex++;
            			} else if('teams'.equalsIgnoreCase(appName)){
            				postBody = postBody +'<li>';	
            			}
            		}
            	}
            }
            if(bodySegments.type =='MarkupEnd'){
            	if(bodySegments.htmlTag.equalsIgnoreCase('ul')){
            		listTypeMarker = 0;
            		if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '</ul>';	 
            		}
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('ol')){
            		listTypeMarker = 0;
            		if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '</ol>';	 
            		}
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('b')){
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody + '*';
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '</strong>';	 
            		}
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('i')){
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody + '_';
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '</i>';	
            		}
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('s')){
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody + '~';
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '</s>';	
            		}	
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('u')){
            		// No alternative found in slack
            		if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + '</u>';	
            		}            		
            	} else if(bodySegments.htmlTag.equalsIgnoreCase('li')){
            		if('slack'.equalsIgnoreCase(appName)){
            			postBody = postBody + bodySegments.text;
            		} else if('teams'.equalsIgnoreCase(appName)){
            			postBody = postBody + bodySegments.text + '</li>';	
            		}	
            	}
            }
        }
    	String pollBody = '';
        if(feedElementWrapperObj.capabilities.poll != null) {
        	List<JSONFeedElementWrapper.Choices> pollChoiceList = feedElementWrapperObj.capabilities.poll.choices;
			Integer index = 1;
			for(JSONFeedElementWrapper.Choices feedChoice : pollChoiceList){
				if('slack'.equalsIgnoreCase(appName)){
					pollBody = pollBody + index+'. '+feedChoice.text.unEscapeHtml4()+'\n';
				} else if('teams'.equalsIgnoreCase(appName)){
					pollBody = pollBody + '\n' +index+'. '+feedChoice.text.unEscapeHtml4()+'\n';	
				} 	
				index++;
			}
			Boolean isCommentOnPoll = (feedElementWrapperObj.capabilities.comments.page.items != null) && (!feedElementWrapperObj.capabilities.comments.page.items.isEmpty());
			String voteCountLabel = '';
			if(isCommentOnPoll){
				if(feedElementWrapperObj.capabilities.poll.totalVoteCount != null){
					if(feedElementWrapperObj.capabilities.poll.totalVoteCount == 1){
						voteCountLabel = '1 Vote';
					} else {
						voteCountLabel = feedElementWrapperObj.capabilities.poll.totalVoteCount+' Votes';
					}
				}
			}
			if('slack'.equalsIgnoreCase(appName)){
				pollBody = '```'+pollBody+voteCountLabel+'```';
			} else if('teams'.equalsIgnoreCase(appName)){
				if(isCommentOnPoll){
					pollBody = pollBody + '\n' +voteCountLabel;
				} 		
			} 	
        }
        
        String attchmentBody = '';
       
		if('slack'.equalsIgnoreCase(appName)){      
	        if(feedElementWrapperObj.capabilities.content != null) {
	        	if(feedElementWrapperObj.capabilities.content.id != null && feedElementWrapperObj.capabilities.content.fileSize != null){
	        		String contentUrl = PageContext.getPageURL(Pages.FileDetail,new Map<String,String>{'fileId'=>feedElementWrapperObj.capabilities.content.id,'origin'=>appName});
	        		String contentSize = ' ('+Utility.byteToHumanReadableFormate(Decimal.valueOf(feedElementWrapperObj.capabilities.content.fileSize))+') ';
	        		String contentLink = '';
	        		if('slack'.equalsIgnoreCase(appName)){
	        			contentLink = getSlackLink(Utility.chompString(feedElementWrapperObj.capabilities.content.title.unEscapeHtml4(),50)+contentSize, contentUrl);	
	        		
	        		} else if('teams'.equalsIgnoreCase(appName)){
						contentLink = getMicrosoftTeamsLink(Utility.chompString(feedElementWrapperObj.capabilities.content.title.unEscapeHtml4(),50)+contentSize, contentUrl);        			
	        		}	
	        		String downloadUrl = '';
	        		if('slack'.equalsIgnoreCase(appName)){
	        			downloadUrl = getSlackLink('Download',feedElementWrapperObj.capabilities.content.downloadUrl);	
	        		} else if('teams'.equalsIgnoreCase(appName)){
	        			downloadUrl = getMicrosoftTeamsLink('Download',feedElementWrapperObj.capabilities.content.downloadUrl);	
	        		}
	    			attchmentBody = '```'+contentLink+' '+downloadUrl+'```\n';
	        	}
	       	}
		}
       	String linkBody = '';
       	if(feedElementWrapperObj.capabilities.Link != null) {
       		if('slack'.equalsIgnoreCase(appName)){
       			linkBody = '```'+getSlackLink(Utility.chompString(feedElementWrapperObj.capabilities.Link.urlName,50),feedElementWrapperObj.capabilities.Link.url) +'\n'+ getSlackLink(Utility.chompString(feedElementWrapperObj.capabilities.Link.url,50),feedElementWrapperObj.capabilities.Link.url)+'``` \n';	
       		
       		} else if('teams'.equalsIgnoreCase(appName)){
       			linkBody = '<blockquote>'+getMicrosoftTeamsLink(Utility.chompString(feedElementWrapperObj.capabilities.Link.urlName,50),feedElementWrapperObj.capabilities.Link.url) + '</blockquote>';	
       		}
       	}
        
    	postBody = postBody+'\n' + pollBody + attchmentBody + linkBody;
		return postBody;
    }
    
    @testvisible
    private static String getCommentBody(JSONFeedElementWrapper feedElementWrapperObj, String appName){ 
    	String commentBody ='';
        List<JSONFeedElementWrapper.Items_Z> commentItemsList = feedElementWrapperObj.capabilities.comments.page.items;
        Integer commentItemsListSize = commentItemsList.size();
		Integer orderListIndex = 1;
        Integer listTypeMarker = 0;// 1 = ordered -1= unordered        
        for(JSONFeedElementWrapper.Items_Z  items : commentItemsList) {
        	if(commentItemsListSize == 1){
	        	String title = FeedDataAdapter.mapUserIdToPeople.containsKey(items.user.id) ? FeedDataAdapter.mapUserIdToPeople.get(items.user.id).Full_Name__c : items.user.name;
	            for( JSONFeedElementWrapper.MessageSegments_Y bodySegments: items.body.messageSegments) {
	            	if(bodySegments.type =='Mention') {
	                	if(bodySegments.record.type == 'User') {
	                		if('slack'.equalsIgnoreCase(appName)){
	                    		commentBody = commentBody+ getSlackLink('@'+(FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.displayName).unEscapeHtml4(),deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + bodySegments.record.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
	                		} else if('teams'.equalsIgnoreCase(appName)){
	                			commentBody = commentBody+ getMicrosoftTeamsLink('@'+(FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.displayName).unEscapeHtml4(),deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + bodySegments.record.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=microsoftteams');
	                		}	
	                    																																															
	                    } else if(bodySegments.record.type == 'CollaborationGroup') {
	                         String additionalInfo = '';
		                	 if(String.isNotBlank(bodySegments.record.additionalLabel)){
		                	 	if(bodySegments.record.additionalLabel.containsIgnoreCase('Archived')){
	                	 		additionalInfo = ' ('+INACTIVE+')';
		                	 	}else{
		                			additionalInfo = ' ('+bodySegments.record.additionalLabel+')';	
	                	 		}
		                	 }
		                	 if('slack'.equalsIgnoreCase(appName)){
	                         	commentBody = commentBody + getSlackLink('@'+bodySegments.record.name.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + bodySegments.record.id + '&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=slack')+additionalInfo;
		                	 } else if('teams'.equalsIgnoreCase(appName)){
		                	 	commentBody = commentBody + getMicrosoftTeamsLink('@'+bodySegments.record.name.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + bodySegments.record.id + '&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=microsoftteams')+additionalInfo;
		                	 }
	                    }
	                }            
	                if(bodySegments.type =='Text') {
	                	if(!bodySegments.text.equalsIgnoreCase('posted a file.')){
	                		commentBody = commentBody + bodySegments.text.unEscapeHtml4();
	                	}
	                }
	                if(bodySegments.type =='Link') {
	                	if('slack'.equalsIgnoreCase(appName)){
	                		commentBody = commentBody + getSlackLink(bodySegments.text.unEscapeHtml4(), bodySegments.url);
	                	} else if('teams'.equalsIgnoreCase(appName)){
	                	 	commentBody = commentBody + getMicrosoftTeamsLink(bodySegments.text.unEscapeHtml4(), bodySegments.url);
	                	}
	                }
	                if(bodySegments.type =='HashTag') {
	                	if('slack'.equalsIgnoreCase(appName)){
	                    	commentBody = commentBody + getSlackLink('#'+bodySegments.tag.unEscapeHtml4() , deepLinkUrl+Page.PageRedirector.getUrl() + '?topicName=' + EncodingUtil.urlEncode(bodySegments.tag, 'utf-8')+ '&pageToRedirect='+Pages.TopicFeed+'&origin=slack');
	                	} else if('teams'.equalsIgnoreCase(appName)){
	                		commentBody = commentBody + getMicrosoftTeamsLink('#'+bodySegments.tag.unEscapeHtml4() , deepLinkUrl+Page.PageRedirector.getUrl() + '?topicName=' + EncodingUtil.urlEncode(bodySegments.tag, 'utf-8')+ '&pageToRedirect='+Pages.TopicFeed+'&origin=microsoftteams');
	                	}
	                }
	                
		            if(bodySegments.type =='MarkupBegin'){
		            	if(bodySegments.htmlTag.equalsIgnoreCase('ul')){
		        			listTypeMarker = -1;
		        			if('slack'.equalsIgnoreCase(appName)){
		        				commentBody = commentBody +'\n';
		        			} else if('teams'.equalsIgnoreCase(appName)){
		        				commentBody = commentBody +'<ul>';	
		        			}	
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('ol')){
		            		listTypeMarker = 1;
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody +'\n';
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody +'<ol>';		
		            		}	
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('b')){
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '*';
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '<strong>';	
		            		}	
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('i')){
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '_';
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '<i>';	
		            		}
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('s')){
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '~';
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '<s>';	
		            		}	
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('u')){
		            		// No alternative found in slack
		            		if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '<u>';	
		            		}
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('p')){
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '\n';
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '<p>';	
		            		}	
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('li')){
		            		if(listTypeMarker == -1){
		            			if('slack'.equalsIgnoreCase(appName)){
			            			commentBody = commentBody +'• ';
		            			} else if('teams'.equalsIgnoreCase(appName)){
		            				commentBody = commentBody +'<li>';	
		            			}
		            		} else if(listTypeMarker == 1){
		            			if('slack'.equalsIgnoreCase(appName)){
			            			commentBody = commentBody + orderListIndex+'. ';
			            			orderListIndex++;
		            			} else if('teams'.equalsIgnoreCase(appName)){
		            				commentBody = commentBody +'<li>';	
		            			}
		            		}
		            	}
		            }
		            if(bodySegments.type =='MarkupEnd'){
		            	if(bodySegments.htmlTag.equalsIgnoreCase('ul')){
		            		listTypeMarker = 0;
		            		if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '</ul>';	 
		            		}
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('ol')){
		            		listTypeMarker = 0;
		            		if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '</ol>';	 
		            		}
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('b')){
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '*';
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '</strong>';	 
		            		}
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('i')){
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '_';
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '</i>';	
		            		}
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('s')){
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '~';
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '</s>';	
		            		}	
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('u')){
		            		// No alternative found in slack
		            		if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + '</u>';	
		            		}            		
		            	} else if(bodySegments.htmlTag.equalsIgnoreCase('li')){
		            		if('slack'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + bodySegments.text;
		            		} else if('teams'.equalsIgnoreCase(appName)){
		            			commentBody = commentBody + bodySegments.text + '</li>';	
		            		}	
		            	}
		            }	                
	            
	            }

		    	commentBody =  Utility.chompString(commentBody,1000);
	            String commentAttachBody = '';
	       		if(items.Capabilities.Content != null && items.Capabilities.Content.id != null){
					String contentUrl = PageContext.getPageURL(Pages.FileDetail,new Map<String,String>{'fileId'=>items.Capabilities.Content.id,'origin'=>appName});       			
	       			String contentSize = ' ('+Utility.byteToHumanReadableFormate(Decimal.valueOf(items.capabilities.content.fileSize))+') ';
	       			String contentLink = '';
	       			String downloadUrl = '';
	       			if('slack'.equalsIgnoreCase(appName)){
	       				contentLink = getSlackLink(Utility.chompString(items.capabilities.content.title.unEscapeHtml4(),50)+contentSize,contentUrl);	
	       				downloadUrl = getSlackLink('Download',items.capabilities.content.downloadUrl);
	       				commentAttachBody = ' ```'+contentLink+' '+downloadUrl+'```\n';
	       			} else if('teams'.equalsIgnoreCase(appName)){
	       				contentLink = getMicrosoftTeamsLink(Utility.chompString(items.capabilities.content.title.unEscapeHtml4(),50)+contentSize,contentUrl);
	       				downloadUrl = getMicrosoftTeamsLink('Download',items.capabilities.content.downloadUrl);
	       				commentAttachBody = '\n\n'+contentLink+' '+downloadUrl+'\n';
	       			}
	       			
	       		}
	       		
	            commentBody = commentBody + commentAttachBody;
        	}
        	commentItemsListSize--;
        }
		return commentBody;	
    }

    @testvisible
    private Static String getOriginalPostSnippet(JSONFeedElementWrapper feedElementWrapperObj, Map<String,Simpplr_Content__c> simpContentMap) {
    	String postBody='';
		List<JSONFeedElementWrapper.MessageSegments> bodyMessSegment = feedElementWrapperObj.body.messagesegments;
		for(JSONFeedElementWrapper.MessageSegments bodySegments : bodyMessSegment) {
            if(bodySegments.type !='MarkupBegin' || bodySegments.type !='MarkupEnd'){
            	postBody = postBody + NotificationHelper.getNotificationText(bodySegments).unEscapeHtml4();
            	if(bodySegments.type =='Mention') {
	            	if(bodySegments.record.type == 'CollaborationGroup') {
	                     String additionalInfo = '';
	                	 if(String.isNotBlank(bodySegments.record.additionalLabel)){
	                	 	if(bodySegments.record.additionalLabel.containsIgnoreCase('Archived')){
	                	 		additionalInfo = ' ('+INACTIVE+')';
	                	 	}else{
	                			additionalInfo = ' ('+bodySegments.record.additionalLabel+')';	
	                	 	}
	                	 }
	                     postBody = postBody + additionalInfo;
	                }
	            } 
            }
    	}
    	postBody =  Utility.chompString(postBody,ServiceConstants.SNIPPET_IN_NOTIFICATION_MAX_LENGTH);
    	String pollBody = '';
        if(feedElementWrapperObj.capabilities.poll != null) {
        	List<JSONFeedElementWrapper.Choices> pollChoiceList = feedElementWrapperObj.capabilities.poll.choices;
			Integer index = 1;
			for(JSONFeedElementWrapper.Choices feedChoice : pollChoiceList){
				pollBody = pollBody + index+'. '+feedChoice.text.unEscapeHtml4()+'\n';
				index++;
			}
			String voteCountLabel = '';
			if(feedElementWrapperObj.capabilities.poll.totalVoteCount != null){
				if(feedElementWrapperObj.capabilities.poll.totalVoteCount == 1){
					voteCountLabel = '1 Vote';
				} else {
					voteCountLabel = feedElementWrapperObj.capabilities.poll.totalVoteCount+' Votes';
				}
			}
			pollBody = '```'+pollBody+voteCountLabel+'```';
        }
        
        String attchmentBody = '';
        if(feedElementWrapperObj.capabilities.content != null) {
        	if(feedElementWrapperObj.capabilities.content.id != null && feedElementWrapperObj.capabilities.content.fileSize != null){
        		String contentUrl = PageContext.getPageURL(Pages.FileDetail,new Map<String,String>{'fileId'=>feedElementWrapperObj.capabilities.content.id,'origin'=>'slack'});
        		String contentSize = ' ('+Utility.byteToHumanReadableFormate(Decimal.valueOf(feedElementWrapperObj.capabilities.content.fileSize))+') ';
        		String contentLink = getSlackLink(Utility.chompString(feedElementWrapperObj.capabilities.content.title.unEscapeHtml4(),50)+contentSize, contentUrl);	
        		String downloadUrl = getSlackLink('Download',feedElementWrapperObj.capabilities.content.downloadUrl);
	        	attchmentBody = '```'+contentLink+' '+downloadUrl+'```\n';
        	}
       	}
       	String linkBody = '';
       	if(feedElementWrapperObj.capabilities.Link != null) {
       		linkBody = '```'+Utility.chompString(feedElementWrapperObj.capabilities.Link.urlName.unEscapeHtml4(),50) +'\n'+ Utility.chompString(feedElementWrapperObj.capabilities.Link.url,50)+'``` \n';
       	}
        
    	postBody = postBody+'\n' + pollBody + attchmentBody + linkBody;
    	String originalPostSnippet = '*Original Post* - ';
    	originalPostSnippet = originalPostSnippet + createSlackTitle(feedElementWrapperObj, simpContentMap.values());
    	if(!feedElementWrapperObj.type.equalsIgnorecase('TrackedChange')){
    		originalPostSnippet = originalPostSnippet+'\n'+postBody;
    	}
		return originalPostSnippet;
    }
    @testvisible
    private static string getDateFooter(JSONFeedElementWrapper feedElementWrapperObj){
    	DateTime originalPostDate = Utility.convertStringTodateTime(feedElementWrapperObj.createdDate);
    	String dateFooter = Utility.getDuration(originalPostDate);
    	return dateFooter;
    }
    
    @testVisible
    private static Map<String,String> getPostMentionedGroupMap(List<JSONFeedElementWrapper.MessageSegments> messageSegments){
        Map<String,String> mentionedGrpIdMap = new Map<String,String>();
        for(JSONFeedElementWrapper.MessageSegments bodySegments : messageSegments) {
            if(bodySegments.type =='Mention') {
                if(bodySegments.record.type == 'CollaborationGroup') {
                	mentionedGrpIdMap.put(bodySegments.record.id, (FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.name));
                }
            }
        }
        return mentionedGrpIdMap;
    }
    
    @testVisible
    private static Map<String,String> getCommentMentionedGroupMap(List<JSONFeedElementWrapper.MessageSegments_Y> messageSegments){
        Map<String,String> mentionedGrpIdMap = new Map<String,String>();
        for(JSONFeedElementWrapper.MessageSegments_Y bodySegments : messageSegments) {
            if(bodySegments.type =='Mention') {
                if(bodySegments.record != null && bodySegments.record.type == 'CollaborationGroup') {
                	mentionedGrpIdMap.put(bodySegments.record.id, (FeedDataAdapter.mapUserIdToPeople.containsKey(bodySegments.record.id) ? FeedDataAdapter.mapUserIdToPeople.get(bodySegments.record.id).Full_Name__c : bodySegments.record.name));
                }
            }
        }
        return mentionedGrpIdMap;
    }	
	
	@testvisible
	private static void handleSlackException(Map<String,Set<String>> channelToCGIdsMap, Set<String> targetCGIdSet, List<Simpplr_Site__c> SiteObjList){
		//targetCGIdSet is set of CG to be disconnected
		//channelToCGIdsMap is Map of channel to Set of cgids(which has to be disconnected as the channel in key is archived)
		Map<String,Set<String>> cgIdToManagersMap = new Map<String,Set<String>>();// contains Map of a collgrp(to be disconnected i.e. targetCGIdSet) TO set of all it managers
		Map<String,Set<Simpplr_Site__c>> siteManagerToSiteObjMap = new Map<String,Set<Simpplr_Site__c>>();// contains Map of a site Manager TO all the SiteConfigs(connected to archived channel only) he manages 
		Map<String,Set<String>> channelToSiteManagersMap = new Map<String, Set<String>>();
		List<CollaborationGroupMember> listOfCollabGrpMember = [SELECT MemberId, CollaborationGroupId, CollaborationRole,
																CollaborationGroup.OwnerId
																FROM CollaborationGroupMember 
																WHERE CollaborationGroupId IN :targetCGIdSet AND (CollaborationRole = 'Manager' OR CollaborationRole = 'Owner' OR CollaborationRole = 'Admin') WITH SECURITY_ENFORCED];
		
		for(CollaborationGroupMember cgMember: listOfCollabGrpMember){
			if(cgIdToManagersMap.get(cgMember.CollaborationGroupId) == null){
				cgIdToManagersMap.put(cgMember.CollaborationGroupId, new Set<String>{cgMember.MemberId});
			}
	    	cgIdToManagersMap.get(cgMember.CollaborationGroupId).add(cgMember.MemberId);
		}
		Map<String,String> channelIdToNameMap = new Map<String,String>();
		for(Simpplr_Site__c siteObj :SiteObjList ){
			for(String siteManagerId : cgIdToManagersMap.get(siteObj.Chatter_Group_Id__c)){
				if(siteManagerToSiteObjMap.get(siteManagerId) == null){
					siteManagerToSiteObjMap.put(siteManagerId, new Set<Simpplr_Site__c>());
				}
				siteManagerToSiteObjMap.get(siteManagerId).add(siteObj);
			}
			channelIdToNameMap.put(siteObj.Slack_Channel_Id__c, siteObj.Slack_Channel_Name__c);
		}
		
		for(String channelId : channelToCGIdsMap.keySet()){
			for(String cgId : channelToCGIdsMap.get(channelId)){
				channelToSiteManagersMap.put(channelId,cgIdToManagersMap.get(cgId));
			}
		}
		List<Messaging.SingleEmailMessage> slackErrorEmailList = new List<Messaging.SingleEmailMessage>();
		
		for(String channelId : channelToCGIdsMap.keySet()){
			slackErrorEmailList.addAll(getSlackExceptionEmail(channelIdToNameMap.get(channelId), channelId, channelToSiteManagersMap.get(channelId), siteManagerToSiteObjMap));
		}
		
		if(slackErrorEmailList.size() > 0) {
			Messaging.sendEmail(slackErrorEmailList);
		} 
		updateSlackInfoFromSiteConfig(SiteObjList, channelToCGIdsMap.keySet());
	}
	
	@testVisible
	private static List<Messaging.SingleEmailMessage> getSlackExceptionEmail(String channelName,String channelId, Set<String> siteManagersSetPerChannel, Map<String,Set<Simpplr_Site__c>> siteManagerToSiteObjMap){
		List<Messaging.SingleEmailMessage> slackErrorEmailListPerChannel = new List<Messaging.SingleEmailMessage>();

		
			Map<String,Set<Simpplr_Site__c>> siteManagerToSiteObjMapTemp = new Map<String,Set<Simpplr_Site__c>>();
			
			for(String siteManagerId: siteManagerToSiteObjMap.keySet()){
				for(Simpplr_Site__c sitCofg : siteManagerToSiteObjMap.get(siteManagerId)){
					if(sitCofg.Slack_Channel_Id__c.equalsIgnoreCase(channelId)){
						if(siteManagerToSiteObjMapTemp.get(siteManagerId) == null){
							siteManagerToSiteObjMapTemp.put(siteManagerId, new Set<Simpplr_Site__c>());
						}
						siteManagerToSiteObjMapTemp.get(siteManagerId).add(sitCofg);
					}
				}
				
			}
			List<User> listOfSiteManagerPerChannel = [SELECT id,isActive, languagelocalekey  
					FROM User 
					WHERE isActive=true AND id=:siteManagersSetPerChannel WITH SECURITY_ENFORCED];
			List<String> localeList = new List<String>();
		
			for (User userObj: listOfSiteManagerPerChannel) {
				localeList.add(Utility.getSimpplrLanguageLocaleKey(userObj.languagelocalekey));
			}

			LocaleContext.getAllLabelMap('EmailNotifications', localeList);

			for (User siteManagerObj: listOfSiteManagerPerChannel) {
				String siteManagerId = siteManagerObj.id;
				Messaging.SingleEmailMessage slackErrorEmail = new Messaging.SingleEmailMessage();
				String mailBodyHtml = '';	
				String siteDetails = '';	
				String siteLink = '';
				String subject = '';
				String userLanguage = Utility.getSimpplrLanguageLocaleKey(siteManagerObj.languagelocalekey);

				if (siteManagerToSiteObjMapTemp.get(siteManagerId) != null && 
						siteManagerToSiteObjMapTemp.get(siteManagerId).isEmpty() == false) {
					List<Simpplr_Site__c> siteObjList = new List<Simpplr_Site__c>();
					siteObjList.addAll(siteManagerToSiteObjMapTemp.get(siteManagerId));
					
					if (siteManagerToSiteObjMapTemp.get(siteManagerId).size() == 1) {
						subject = LocaleContext.getLabel(userLanguage, KEY_EMAIL_NOTIFICATION_ERROR_SLACK_SUBJECT).replace(
								'{{siteName}}', siteObjList[0].Name);
						
						siteLink += '<a href="'+deepLinkUrl + Page.app.getUrl()+'?u=/manage/sites/'+ siteObjList[0].Id + '/external-apps" >'+siteObjList[0].Name+'</a>';
						mailBodyHtml = LocaleContext.getLabel(userLanguage, KEY_EMAIL_NOTIFICATION_ERROR_SLACK_BODY).replace(
								'{{siteName}}', siteLink);
						mailBodyHtml = Utility.replace(mailBodyHtml, '{{siteManagerId}}', siteObjList[0].Slack_Site_Manager__r.User__c);
						mailBodyHtml = Utility.replace(mailBodyHtml, '{{siteManagerName}}', (PeopleDao.mapUserIdToPeopleName.containsKey(siteObjList[0].Slack_Site_Manager__r.User__c) ? PeopleDao.mapUserIdToPeopleName.get(siteObjList[0].Slack_Site_Manager__r.User__c) : siteObjList[0].Slack_Site_Manager__r.User__r.Name));
						mailBodyHtml = Utility.replace(mailBodyHtml, '{{siteManagerLogin}}', siteObjList[0].Slack_Site_Manager__r.User__r.Username);
						mailBodyHtml = Utility.replace(mailBodyHtml, '{{orgId}}', UserInfo.getOrganizationId());
						mailBodyHtml = Utility.replace(mailBodyHtml, '{{appName}}', UserInfo.getOrganizationName());

					} else if(siteManagerToSiteObjMapTemp.get(siteManagerId).size() > 1){
						mailBodyHtml= LocaleContext.getLabel(userLanguage, 
									KEY_EMAIL_NOTIFICATION_ERROR_SLACK_BODY_ONE_PLURAL);
						Integer siteObjListSize = siteObjList.size();
						subject = LocaleContext.getLabel(userLanguage, 
									KEY_EMAIL_NOTIFICATION_ERROR_SLACK_SUBJECT_PLURAL);
						String siteDetailText = LocaleContext.getLabel(userLanguage, 
									KEY_EMAIL_NOTIFICATION_ERROR_SLACK_BODY_TWO_PLURAL);
						for(Simpplr_Site__c siteObject : siteObjList){
							siteLink= '<a href="'+deepLinkUrl + Page.app.getUrl()+'?u=/manage/sites/'+ siteObject.Id + '/external-apps" >'+siteObject.Name+'</a>';
							siteDetails += '<br/><br/>' + siteDetailText;
							siteDetails = Utility.replace(siteDetails, '{{siteName}}', siteLink);
							siteDetails = Utility.replace(siteDetails, '{{siteManagerId}}', siteObject.Slack_Site_Manager__r.User__c);
							siteDetails = Utility.replace(siteDetails, '{{siteManagerName}}', (PeopleDao.mapUserIdToPeopleName.containsKey(siteObject.Slack_Site_Manager__r.User__c) ? PeopleDao.mapUserIdToPeopleName.get(siteObject.Slack_Site_Manager__r.User__c) : siteObject.Slack_Site_Manager__r.User__r.Name));
							siteDetails = Utility.replace(siteDetails, '{{siteManagerLogin}}', siteObject.Slack_Site_Manager__r.User__r.Username);
							siteObjListSize--;	
						}
						mailBodyHtml = Utility.replace(mailBodyHtml, '{{siteDetails}}', siteDetails);
						mailBodyHtml = Utility.replace(mailBodyHtml, '{{orgId}}', UserInfo.getOrganizationId());
						mailBodyHtml = Utility.replace(mailBodyHtml, '{{appName}}', UserInfo.getOrganizationName());
					
					} else{
						
					}					
				}
				
				slackErrorEmail = EmailUtility.getSingleEmailElement(subject,mailBodyHtml, siteManagerId,SimpplrContext.SEDFromEmail);
				slackErrorEmailListPerChannel.add(slackErrorEmail);
				mailBodyHtml = '';
			}
        
		return slackErrorEmailListPerChannel;
	}
	
	@testVisible
	private static void updateSlackInfoFromSiteConfig(List<Simpplr_Site__c> SiteObjList, Set<String> channelIdSet){
		List<Simpplr_Site__c> simpplrSiteList = new List<Simpplr_Site__c>();
		for(Simpplr_Site__c siteObj : SiteObjList){
			if(channelIdSet.contains(siteObj.Slack_Channel_Id__c)){
				siteObj.Slack_Channel_Name__c = null;
				siteObj.Slack_Url__c = null;
				siteObj.Slack_Channel_Id__c = null;
				siteObj.Slack_Comment_Enabled__c = false;
				siteObj.Slack_Post_Enabled__c = true;
				siteObj.Slack_Access_Token__c = null;
				simpplrSiteList.add(siteObj);
			}
		}
		if(!simpplrSiteList.isEmpty()){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(simpplrSiteList), new List<Schema.SObjectField>{
				Simpplr_Site__c.Slack_Channel_Name__c,
				Simpplr_Site__c.Slack_Url__c, 
				Simpplr_Site__c.Slack_Channel_Id__c,
				Simpplr_Site__c.Slack_Comment_Enabled__c,
				Simpplr_Site__c.Slack_Post_Enabled__c,
				Simpplr_Site__c.Slack_Access_Token__c
			});
		}
		
	}
	
	@testVisible 
	private static Set<String> getMentionedGroupIdSet(String feedId){
		Set<String> mentionedGroupIdSet = new Set<String>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', feedId);
		String query = 'Select Group_Mentions__c from Feed_Cache__c where Feed_Id__c = : soqlParam1 and Is_Deleted__c = false'; 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Feed_Cache__c> feedCacheList = (List<Feed_Cache__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		for(Feed_Cache__c feedCache : feedCacheList){
			if(String.isNotBlank(feedCache.Group_Mentions__c)){
				for(Integer i = 0; i<feedCache.Group_Mentions__c.length(); i=i+18){
					mentionedGroupIdSet.add(feedCache.Group_Mentions__c.substring(i,i+18));
				}
			}
		}
		return mentionedGroupIdSet;
	}
	    
    private static String createSlackTitle(JSONFeedElementWrapper feedElementWrapperObj, List<Simpplr_Content__c> simpplrContentList) {
        
        List<JSONFeedElementWrapper.MessageSegments_Z> headerMessSegment = feedElementWrapperObj.header.messagesegments;
        Integer headerMesaageSegmentsSize = headerMessSegment.size();
        
        
        String emailTitle ='';
        String firstSegment = '';
        String secondSegment = '';
        String thirdSegment = '';
        String extraLabel = '';
        
        if(feedElementWrapperObj.originalFeedItemActor == null) {
            
            for( Integer index=0 ;index<headerMesaageSegmentsSize;index++){
                JSONFeedElementWrapper.MessageSegments_Z header = headerMessSegment.get(index);
                
                if('EntityLink'.equalsIgnoreCase(header.type)){
                    
					String headerText = header.reference?.id != null && header.reference.id.startsWith('005') && FeedDataAdapter.mapUserIdToPeople.containsKey(header.reference.id) ? FeedDataAdapter.mapUserIdToPeople.get(header.reference.id).Full_name__c : header.text;
                    if(feedElementWrapperObj.parent.id.subString(0,3).equalsIgnoreCase('005')){
                        if(feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                            if(feedElementWrapperObj.parent.id != feedElementWrapperObj.actor.id){
                                if(index == 0){
                                    firstSegment = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
                                }
                                if(index == 2){
                                    thirdSegment = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
                                }
                            }else{
                                thirdSegment = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
                                firstSegment = '';
                            }
                            
                        }else if(feedElementWrapperObj.type.equalsIgnoreCase('CollaborationGroupCreated')){
        					if(index == 0){
	    						firstSegment = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
	    					}
	    					if(index == 2){
	    						thirdSegment = getSlackLink(headerText, PageContext.getPageURL(Pages.app) +'?u=/site/chatter/' + header.reference.id + '&origin=slack');
	    					
	    					}
         				}else{
                            emailTitle = emailTitle+getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
                        }
                    }else if(feedElementWrapperObj.parent.id.startsWith('0F9') || feedElementWrapperObj.parent.id.startsWithIgnoreCase(Utility.getSimpplrContentPrefix())){
                        if(index == 0){
                            if(!simpplrContentList.isEmpty()){
                                if(simpplrContentList[0].Name.equalsIgnoreCase(header.text)) {
                                    String contentTitle = simpplrContentList[0].Title__c.length()>73 ? simpplrContentList[0].Title__c.substring(0,70)+'...' : simpplrContentList[0].Title__c;
                                    firstSegment = getSlackLink(contentTitle, deepLinkUrl + Page.PageRedirector.getUrl() + '?siteId=' + simpplrContentList[0].Id +'&contentId='+header.reference.id+'&pageToRedirect=ContentDetailPage&origin=slack&contentType='+simpplrContentList[0].type__c.tolowercase());
                                } else {
                                    firstSegment = getSlackLink(header.text,deepLinkUrl + Page.PageRedirector.getUrl() + '?siteId=' + simpplrContentList[0].Id +'&contentId='+header.reference.id+'&pageToRedirect=ContentDetailPage&origin=slack&contentType='+simpplrContentList[0].type__c.tolowercase());
                                }
                            }else{
                                firstSegment = getSlackLink(header.text.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + header.reference.id +'&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=slack');
                            }
                        }else if(index == 2){
                            thirdSegment = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
                        }else{
                            emailTitle = emailTitle+getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl+'/'+header.reference.id+'?origin=slack');
                        }
                    }else{
                    	if(index == 0){
    						firstSegment = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl+'/'+header.reference.id+'?origin=slack');
    					}
    					if(index == 2){
    						thirdSegment = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
    					}
                        //emailTitle = emailTitle+getSlackLink(header.text.unEscapeHtml4(), deepLinkUrl+'/'+header.reference.id+'?origin=slack');
                    }
                    
                }else { 
					String headerText = header.reference?.id != null && header.reference.id.startsWith('005') && FeedDataAdapter.mapUserIdToPeople.containsKey(header.reference.id) ? FeedDataAdapter.mapUserIdToPeople.get(header.reference.id).Full_name__c : header.text;
                    if(index == 1 && feedElementWrapperObj.parent.type.equalsIgnoreCase('CollaborationGroup')){
                        extraLabel = header.text;
                        if(extraLabel.containsIgnoreCase('Archived')){
                        	extraLabel = ' ('+INACTIVE+')';
                        }else{
                        	extraLabel = extraLabel.remove(' — ');
                        }
                    }
                    String str = '';
                    
                    if(index == 1 && !header.text.containsIgnoreCase(' posted a ')){
                        if(feedElementWrapperObj.parent.id.startsWith('0F9')){
                            if(!feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                                str = ' in ';
                            }else{
                                str = ' made changes in ';
                            }
                            
                        }else if(feedElementWrapperObj.parent.id.startsWithIgnoreCase(Utility.getSimpplrContentPrefix())){
                            if(!feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                                str = ' on ';
                            }else{
                                str = ' made changes on ';
                            }
                        }else if(feedElementWrapperObj.parent.id.startsWithIgnoreCase('005')){
                            if(feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                                if(feedElementWrapperObj.parent.id != feedElementWrapperObj.actor.id){
                                    str = ' made changes to ';
                                }else{
                                    str = ' made changes ';
                                }
                            }else{
                                emailTitle = emailTitle+headerText;
                            }
                            
                        }else{
                            str = ' made changes on ';
                        }
                        secondSegment = str;
                    }else{
                    	if(index == 3 && !feedElementWrapperObj.parent.id.startsWithIgnoreCase('005') && !feedElementWrapperObj.parent.id.startsWith('0F9')){
        					continue;
	       				}
                    	
                        if((!feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange') && !header.text.containsIgnoreCase(' posted a ') && !header.text.containsIgnoreCase(':')) || (!header.text.equalsIgnoreCase(' changed ') && feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange'))){
                            emailTitle = emailTitle+headerText;
                        }
                    }
                        
                }
            }
            if(feedElementWrapperObj.type.equalsIgnoreCase('CollaborationGroupCreated')){
        		emailTitle = firstSegment+' added Site '+thirdSegment;
        	}else if(!feedElementWrapperObj.type.equalsIgnoreCase('TrackedChange')){
                emailTitle = thirdSegment+secondSegment+firstSegment+emailTitle+extraLabel;
            }else{
                emailTitle = thirdSegment+secondSegment+firstSegment+extraLabel+'\n'+emailTitle;
            }
        }
        
        if(feedElementWrapperObj.originalFeedItemActor != null){
            String siteName = '';
            String newPostOwner = '';
            String originalPostOwner = '';
            String originalPost = '';
            for( Integer index=0 ;index<headerMesaageSegmentsSize;index++){
                JSONFeedElementWrapper.MessageSegments_Z header = headerMessSegment.get(index);
                
                if('EntityLink'.equalsIgnoreCase(header.type)){
                     
                     if(header.reference.id.subString(0,3).equalsIgnoreCase('0F9')){
                        siteName = ' in ' + getSlackLink(header.text.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + header.reference.id +'&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=slack');
                     }else if(header.reference.id.startsWithIgnoreCase('005')){
						String headerText = FeedDataAdapter.mapUserIdToPeople.containsKey(header.reference.id) ? FeedDataAdapter.mapUserIdToPeople.get(header.reference.id).Full_name__c : header.text;
                        if(String.isBlank(originalPost)){
                            newPostOwner = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
                        }else{
                            originalPostOwner = getSlackLink(headerText.unEscapeHtml4(), deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + header.reference.id +'&pageToRedirect='+Pages.ProfileAbout+'&origin=slack');
                        }
                     }else if(header.reference.id.startsWithIgnoreCase('0D5')){
                        originalPost = 'post';
                     }
                } else {
                    if(index == 1 && feedElementWrapperObj.parent.type.equalsIgnoreCase('CollaborationGroup')){
                        extraLabel = header.text;
                        if(extraLabel.containsIgnoreCase('Archived')){
                        	extraLabel = ' ('+INACTIVE+')';
                        }else{
                        	extraLabel = extraLabel.removeEndIgnoreCase(' — ');
                        }
                    }
                   
                }
            }
            emailTitle = emailTitle + newPostOwner+' shared '+originalPostOwner+'\'s '+originalPost+siteName+extraLabel;
        }
         
        return emailTitle ;
    }	
	   
	public static void pushMicrosoftTeamsNotification(String jsonFeedItem, List<Simpplr_Site__c> SiteObjList){
		String brandingJson = SimpplrContext.SABrandingJSON;
		BrandingInfo brandingInfo  = (BrandingInfo)JSON.deserialize(brandingJson,BrandingInfo.class);
		String primaryColor = brandingInfo.general_primaryColor;
		JSONFeedElementWrapper feedElementWrapperObj = JSONFeedElementWrapper.parse(jsonFeedItem);
		FeedDataAdapter.getUserIdsToConvert(feedElementWrapperObj);
		FeedDataAdapter.getPeopleFromUserIds();
		
		List<ContentVersion> contentVersionAttachedList = [select Id, ContentDocumentId, ContentDocument.FileExtension, ContentDocument.Title, ContentDocument.LastModifiedDate FROM ContentVersion where Id in (select RecordId from FeedAttachment where FeedEntityId = :feedElementWrapperObj.Id) WITH SECURITY_ENFORCED ORDER BY ContentDocument.LastModifiedDate];
		List<ContentVersion> imagesAttachedList = new List<ContentVersion>();
		List<ContentVersion> filesAttachedList = new List<ContentVersion>();
		
		for(ContentVersion contentVersionObj : contentVersionAttachedList){
			if((contentVersionObj.ContentDocument.FileExtension == 'jpg') || (contentVersionObj.ContentDocument.FileExtension == 'jpeg') ||
				(contentVersionObj.ContentDocument.FileExtension == 'gif') || (contentVersionObj.ContentDocument.FileExtension == 'png')){
					imagesAttachedList.add(contentVersionObj);		
			} else {
					filesAttachedList.add(contentVersionObj);		
			}	
		}  
		Map<String,Simpplr_Content__c> simpContentMap = new Map<String,Simpplr_Content__c>();
		String parentGroupId = '';
		String contentName = '';
		if(feedElementWrapperObj.parent.id.subString(0,3).equalsIgnoreCase(Utility.getSimpplrContentPrefix())){
			simpContentMap = new Map<String,Simpplr_Content__c>([select id,Name, Title__c, Site__r.Chatter_Group_Id__c, Site__c, Primary_Author__r.Full_Name__c, Primary_Author__r.Email__c, Primary_Author__c, Type__c  from Simpplr_content__c where id =:feedElementWrapperObj.parent.id ]);
			parentGroupId = simpContentMap.get(feedElementWrapperObj.parent.id).Site__r.Chatter_Group_Id__c;
			contentName = simpContentMap.get(feedElementWrapperObj.parent.id).Title__c;
		} else if(feedElementWrapperObj.parent.id.subString(0,3).equalsIgnoreCase('0F9')){
			simpContentMap = new Map<String,Simpplr_Content__c>();
			parentGroupId = feedElementWrapperObj.parent.id;
		}
		Set<String> groupIdSet = new Set<String>();
		groupIdSet.add(parentGroupId);
		List<JSONFeedElementWrapper.MessageSegments> postBodyMessSegment = feedElementWrapperObj.body.messagesegments;
        String commentFallBacktext = '';
		if(feedElementWrapperObj.capabilities.comments.page.items != null && !feedElementWrapperObj.capabilities.comments.page.items.isEmpty()){
			List<JSONFeedElementWrapper.Items_Z> commentItemsList = feedElementWrapperObj.capabilities.comments.page.items;
        	Integer commentItemsListSize = commentItemsList.size();
        	List<JSONFeedElementWrapper.MessageSegments_Y> commntBodySegments = new List<JSONFeedElementWrapper.MessageSegments_Y>();
        	for(JSONFeedElementWrapper.Items_Z  items : commentItemsList) {
        		if(commentItemsListSize == 1){
	            	commntBodySegments = items.body.messageSegments;
	            	commentFallBacktext = items.body.text.unescapeHtml4();
        		}
        		commentItemsListSize--;
        	}
			groupIdSet.addAll(getCommentMentionedGroupMap(commntBodySegments).keySet());
			groupIdSet.addAll(getMentionedGroupIdSet(feedElementWrapperObj.id));
			
		} else { 
			groupIdSet.addAll(getPostMentionedGroupMap(postBodyMessSegment).keySet());
		}
		
		List<Simpplr_Site__c> simpplrSiteObjList = new List<Simpplr_Site__c>();
		Set<String> targetCGIdSet = new Set<String>();
		for(Simpplr_Site__c siteObj : SiteObjList){
			if((siteObj.Microsoft_Teams_Integration_Enabled__c) && ((siteObj.Microsoft_Teams_Webhook_URL__c != null) || (SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 && siteObj.External_Apps_Site_Config_Json__c != null)) && (!siteObj.Is_Deleted__c)){
				if(groupIdSet.contains(siteObj.Chatter_Group_Id__c) && (siteObj.Microsoft_Teams_Integration_Enabled__c == true || siteObj.Microsoft_Teams_Comment_Enabled__c == true || ((SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 && siteObj.External_Apps_Site_Config_Json__c != null)))){
					simpplrSiteObjList.add(siteObj);
				}
				targetCGIdSet.add(siteObj.Chatter_Group_Id__c);
			}	
		}
		
		
		Set<String> channelIdSet = new Set<String>();
		Map<String,Set<String>> channelToCGIdsMap= new Map<String,Set<String>>();
		String parentType = PageContext.namespacePrefix + 'Simpplr_Content__c';
		
		for(Simpplr_Site__c siteObj : simpplrSiteObjList){
			Boolean commentEnabled = false;
			Boolean onlyPosts = false;
			if(siteObj.External_Apps_Site_Config_Json__c != null){
				ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
				externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
				if((externalAppsSiteConfig.MsTeamsSiteConfig != null) && externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsSiteFeedOptions.size()>0){
					if(externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsSiteFeedOptions.contains('msTeamsReplies')){
						commentEnabled = true;
					}
					if(externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsSiteFeedOptions.contains('msTeamsPosts') && !(feedElementWrapperObj.type.equalsIgnoreCase('LinkPost') && feedElementWrapperObj.parent.type.equalsIgnoreCase(parentType))){
						onlyPosts = true;
					}
				}
			}
			String fallbackText = '\n' + UserContext.peopleName + ': ';
			String viewLink = '';
			String actor = '';
			String postBody = '';
			String commentBody = '';
			String originalPostBody = '';
			
			String teamsTitle = SimpplrContext.applicationName+' - '+(String.isBlank(contentName)? siteObj.Name : contentName);
			if(String.isBlank(contentName)){
				if(siteObj.Site_Type__c.equalsIgnoreCase('Private')){
					teamsTitle = teamsTitle + ' (Private) ';
				} else if(siteObj.Site_Type__c.equalsIgnoreCase('Unlisted')){
					teamsTitle = teamsTitle + ' (Unlisted) ';	
				}
			}  
			String siteOrContentURL = '';
			if(String.isBlank(contentName)){
				siteOrContentURL = deepLinkUrl + Page.PageRedirector.getUrl() + '?chatterGroupId=' + parentGroupId + '&pageToRedirect='+ServiceConstants.SITE_LANDING_PAGE_STRING+'&origin=microsoftteams';
			} else {
				siteOrContentURL = deepLinkUrl + Page.PageRedirector.getUrl() + '?siteId=' + siteObj.Id +'&contentId='+feedElementWrapperObj.parent.id+'&pageToRedirect=ContentDetailPage&origin=microsoftteams&contentType='+simpContentMap.get(feedElementWrapperObj.parent.id).type__c.tolowercase();
			}
			Boolean isComment = false;
			MicrosoftTeamsService.MicrosoftTeamsWrapper microsoftTeamsObj = new MicrosoftTeamsService.MicrosoftTeamsWrapper();
			 
			if(feedElementWrapperObj.capabilities.comments.page.items != null && !feedElementWrapperObj.capabilities.comments.page.items.isEmpty()){
				actor = getMicrosoftTeamsLink(UserContext.peopleName, deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + UserInfo.getUserId() +'&pageToRedirect='+Pages.ProfileAbout+'&origin=microsoftteams')+' replied';
				viewLink = getMicrosoftTeamsLink('View Reply', deepLinkUrl+Page.app.getUrl()+'?u=/feed/'+feedElementWrapperObj.id+'&origin=microsoftteams');
				actor = actor +' - '+viewLink;	
				microsoftTeamsObj.summary = actor;
				
				microsoftTeamsObj.sections = new List<Object>();
				MicrosoftTeamsService.Activity activity = new MicrosoftTeamsService.Activity();			
				activity.activityTitle = actor;
				
				commentBody = getCommentBody(feedElementWrapperObj, 'teams');
				originalPostBody = '<strong>Original Post</strong>  ' + getMicrosoftTeamsLink(UserContext.peopleName, deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + UserInfo.getUserId() +'&pageToRedirect='+Pages.ProfileAbout+'&origin=microsoftteams');
				originalPostBody += ' in ' + getMicrosoftTeamsLink(teamsTitle, siteOrContentURL);
				String viewPostLink = getMicrosoftTeamsLink('View Post', deepLinkUrl+Page.app.getUrl()+'?u=/feed/'+feedElementWrapperObj.id+'&origin=microsoftteams');
				originalPostBody = originalPostBody +' - '+viewPostLink;
				originalPostBody = originalPostBody + getPostBody(feedElementWrapperObj, 'teams');
				activity.activityText = commentBody + '<br><br>' + originalPostBody;
				microsoftTeamsObj.siteFeedUrl = actor + '<br>' + commentBody + '<br><br>' + originalPostBody;
				
				microsoftTeamsObj.sections.add(activity);
				
				if(!imagesAttachedList.isEmpty()){
					microsoftTeamsObj.sections.add(getMicrosoftTeamsImages(imagesAttachedList));	
				}
				
				if(!filesAttachedList.isEmpty()){
					microsoftTeamsObj.sections.add(getMicrosoftTeamsFacts(filesAttachedList));
				}			
				
				isComment = true;
				
			} else {				
				actor = getMicrosoftTeamsLink(UserContext.peopleName, deepLinkUrl + Page.PageRedirector.getUrl() + '?userId=' + UserInfo.getUserId() +'&pageToRedirect='+Pages.ProfileAbout+'&origin=microsoftteams');
				actor += ' in ' + getMicrosoftTeamsLink(teamsTitle, siteOrContentURL);
				viewLink = getMicrosoftTeamsLink('View Post', deepLinkUrl+Page.app.getUrl()+'?u=/feed/'+feedElementWrapperObj.id+'&origin=microsoftteams');
				actor = actor +' - '+viewLink;
				microsoftTeamsObj.summary = actor;
				 
				microsoftTeamsObj.sections = new List<Object>();
				MicrosoftTeamsService.Activity activity = new MicrosoftTeamsService.Activity();			
				activity.activityTitle = actor;
								
				postBody = getPostBody(feedElementWrapperObj, 'teams');
				activity.activityText = postBody;
				microsoftTeamsObj.sections.add(activity);
				microsoftTeamsObj.siteFeedUrl = actor + postBody;
				
				if(!imagesAttachedList.isEmpty()){
					microsoftTeamsObj.sections.add(getMicrosoftTeamsImages(imagesAttachedList));	
				}
				
				if(!filesAttachedList.isEmpty()){
					microsoftTeamsObj.sections.add(getMicrosoftTeamsFacts(filesAttachedList));		
				}
				
			}
			if(((!SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2) && (isComment == false || (isComment == true && siteObj.Microsoft_Teams_Comment_Enabled__c))) || (SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 && (commentEnabled == true && isComment == true) || (isComment == false && onlyPosts == true))){
				if(!imagesAttachedList.isEmpty()){
					System.enqueueJob(new QueueablePushSiteFeedWithImages(siteObj, microsoftTeamsObj));
				} else{
					postToteams(siteObj, microsoftTeamsObj);
				}
			}
		} 
	}
			         
	public static String getMicrosoftTeamsLink(String name, String url){
		String linkToReturn = '';
		url = (String.isNotBlank(SimpplrContext.DeeplinkingRedirectURL)?SimpplrContext.DeeplinkingRedirectURL: ServiceConstants.SIMPPLR_DEEPLINKING_REDIRECTOR_URL) + EncodingUtil.urlEncode(url, 'UTF-8');
		linkToReturn = '<a href = "' + url + '">' + name + '</a>';
		return linkToReturn;
	} 
	
	public static MicrosoftTeamsService.ImageListWrapper getMicrosoftTeamsImages(List<ContentVersion> imagesAttachedList){
		Integer i = 5;
		List<Id> contentVersionIdList = new List<Id>();
		for(ContentVersion images : imagesAttachedList){
			if(i==0){
				break;
			}
			contentVersionIdList.add(images.Id);
			i--;
		}
		Map<Id, String> CVToThumUrlMap = FileContentProvider.generateEmbedPublicUrl(contentVersionIdList);
		
		MicrosoftTeamsService.ImageListWrapper wrapperObj = new MicrosoftTeamsService.ImageListWrapper();
		List<MicrosoftTeamsService.ImageWrapper> imageList = new List<MicrosoftTeamsService.ImageWrapper>();
		for(String imageURL : CVToThumUrlMap.values()){
			MicrosoftTeamsService.ImageWrapper imageObj = new MicrosoftTeamsService.ImageWrapper(); 
			imageObj.image = imageURL;
			imageList.add(imageObj);	
		}
		wrapperObj.images = imageList;
		return 	wrapperObj;	
	}  
	
	public static MicrosoftTeamsService.FactListWrapper getMicrosoftTeamsFacts(List<ContentVersion> filesAttachedList){
		MicrosoftTeamsService.FactListWrapper wrapperObj = new MicrosoftTeamsService.FactListWrapper();	
		List<MicrosoftTeamsService.FactWrapper> factsList = new List<MicrosoftTeamsService.FactWrapper>();
		MicrosoftTeamsService.FactWrapper factsObj = new MicrosoftTeamsService.FactWrapper();
		factsObj.name = 'Files';
		String factsValue = '';
		for(ContentVersion files : filesAttachedList){
			factsValue +=  getMicrosoftTeamsLink(files.ContentDocument.Title, deepLinkUrl + Page.PageRedirector.getUrl() + '?fileId=' + files.ContentDocumentId +'&pageToRedirect='+Pages.FileDetail+'&origin=microsoftteams');	
			factsValue = factsValue + '<br>';
		}	
		factsValue = factsValue.removeEnd('</br>');
		factsObj.value = factsValue;
		factsList.add(factsObj);
		
		wrapperObj.facts = factsList;
		return wrapperObj;
	}
	
	public static void sendMicrosoftTeamsExceptionMail(Simpplr_Site__c siteObj){
		List<Messaging.SingleEmailMessage> microsoftTeamsErrorEmailList = new List<Messaging.SingleEmailMessage>();
		 
		List<CollaborationGroupMember> groupManagerList = [Select Id, Member.Id From CollaborationGroupMember where CollaborationRole='Admin' and Member.IsActive=true and CollaborationGroupId =:siteObj.Chatter_Group_Id__c WITH SECURITY_ENFORCED];
		for(CollaborationGroupMember groupManagers : groupManagerList){
			Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
			
			String subject = 'Problem with Microsoft Teams and ' + siteObj.Name;
			String body = 'Unfortunately there is a problem with Microsoft Teams and ' + siteObj.Name + '. The webhook is incorrect and the integration has been disabled.';
			body += '<br/><br/>Org Details:<br/><br/>';
			body += 'Site Manager ID - ' + siteObj.Microsoft_Teams_Site_Manager__r.User__c + '<br/>';
			body += 'Site Manager Name - ' + (PeopleDao.mapUserIdToPeopleName.containsKey(siteObj.Microsoft_Teams_Site_Manager__r.User__c) ? PeopleDao.mapUserIdToPeopleName.get(siteObj.Microsoft_Teams_Site_Manager__r.User__c) : siteObj.Microsoft_Teams_Site_Manager__r.User__r.Name) + '<br/>';
			body += 'Site Manager Login - ' + siteObj.Microsoft_Teams_Site_Manager__r.User__r.Username + '<br/>';
			body += 'OrgId - ' + UserInfo.getOrganizationId() + '<br/>';
			body += 'Org Name - ' + UserInfo.getOrganizationName() + '<br/>'; 
			body += 'Webhook URL - ' + siteObj.Microsoft_Teams_Webhook_URL__c + '<br/>'; 	
			
			emailMessage = EmailUtility.getSingleEmailElement(subject, body, groupManagers.Member.Id, SimpplrContext.SEDFromEmail);
			microsoftTeamsErrorEmailList.add(emailMessage);
		}
		
        if(microsoftTeamsErrorEmailList.size() > 0) {
        	Messaging.sendEmail(microsoftTeamsErrorEmailList);
        }		
		
	}
	
	public static void removeMicrosoftTeamsWebhookURL(Simpplr_Site__c siteObj){	
		Simpplr_Site__c siteObjToUpdate = siteObj;
		siteObjToUpdate.Microsoft_Teams_Webhook_Url__c = '';
		siteObjToUpdate.Microsoft_Teams_Integration_Enabled__c = false;
		siteObjToUpdate.Microsoft_Teams_Comment_Enabled__c = false;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(siteObjToUpdate, new List<Schema.SObjectField>{
			Simpplr_Site__c.Microsoft_Teams_Webhook_Url__c,
			Simpplr_Site__c.Microsoft_Teams_Integration_Enabled__c, 
			Simpplr_Site__c.Microsoft_Teams_Comment_Enabled__c
		});
	}
	
	public static void postToTeams(Simpplr_Site__c siteObj , MicrosoftTeamsService.MicrosoftTeamsWrapper microsoftTeamsObj){
		if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2){
			ManageSiteWrapper.ExternalAppsSiteConfig obj = new ManageSiteWrapper.ExternalAppsSiteConfig();
			obj = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
			if(obj.MsTeamsSiteConfig != null){
				ContentWrapper.ContentSiteFeedWrapper contentWrapper = new ContentWrapper.ContentSiteFeedWrapper();
				new MicrosoftTeamsHelper().promoteContentToChannel(obj.MsTeamsSiteConfig.msTeamsTeamId,obj.MsTeamsSiteConfig.msTeamsChannelId,'', microsoftTeamsObj.siteFeedUrl,IntegrationConstants.POST_SITE_FEED_CONTENT, '', obj.MsTeamsSiteConfig.msTeamsConnectedUserId,contentWrapper);
			}
		} else {
			Http h = new Http();
			HttpRequest req = new HttpRequest();
			String endPoint = siteObj.Microsoft_Teams_Webhook_URL__c;
			req.setEndpoint(endPoint);
			req.setHeader('Content-Type','application/json');
			req.setBody(JSON.serialize(microsoftTeamsObj));
			req.setMethod('POST');
			req.setTimeout(60000);
			HttpResponse res = h.send(req);		
			if(res.getStatusCode() == 200){
				
			} else {
				sendMicrosoftTeamsExceptionMail(siteObj);
				removeMicrosoftTeamsWebhookURL(siteObj);
			} 	
		}	       
	}
	    
}