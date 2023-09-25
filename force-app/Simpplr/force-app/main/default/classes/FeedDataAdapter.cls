public with sharing class FeedDataAdapter {
	public static List<MentionWrapper> listOfMentionUserGlobal;
	public static List<String> listOfLinksGlobal;
	public static List<TopicWrapper> listOfTopicGlobal;
	public static Map<String, String> mapOfTopicNameToIdGlobal;
	public static set<String> setOfCreatedSitesId;
	@TestVisible private static Boolean hasCreatedSiteData;
	@TestVisible private static Boolean isExtFilePresent; // Context Boolean to check if the gd/box files are there on feed page
	@TestVisible private static Boolean isFeedPageContext; // Context Boolean to check if the data will be returned as feed page or single feed.Used for external file sharing. 
	@TestVisible private static Boolean isCommentPageContext; //Context Boolean to check if we are returning comment page or single comment. Used for external file sharing 
	@TestVisible private static Map<String, List<String>> mapOfFeedIdWithListOfIdOfExtFile = new Map<String, List<String>>(); //Gdrive box feed post
	@TestVisible private static Map<String, List<String>> mapOfCommentIdWithListOfIdOfExtFile = new Map<String, List<String>>(); //Gdrive box comment 
	@TestVisible private static Set<String> setUserIds = new Set<String>();
	public static Map<String, People__c> mapUserIdToPeople = new Map<String, People__c>();
	public static Map<string,String> mapUserVSsiteId = new map<string,String>();

	public static Map<Id, Simpplr_Site__c> siteIdDataMap = new Map<Id, Simpplr_Site__c>();
	public static Map<Id, CollaborationGroup> chatterGroupDataMap = new Map<Id, CollaborationGroup>();
	@TestVisible private static Integer currIdx=0;
	@TestVisible private static Map<Id, Id> peopleIdByUserIdMap = new Map<Id, Id>();
	@TestVisible private static Map<string, Id> siteIdByCollaborationGrpIdMap = new Map<string, Id>();
	@TestVisible private static Map<string, Id> topicIdsByName = new Map<string, Id> ();
	@TestVisible private static Set<String> marks = new Set<String>();

	/*constructor */
	public FeedDataAdapter () {
		isExtFilePresent = false;
		isFeedPageContext = false;
		isCommentPageContext = false;
	}

	public static FeedElementPageWrapper convertFeedElementPageToWrapper(ConnectApi.FeedElementPage feedElementPageObjArg) {
		hasCreatedSiteData = false;
		isFeedPageContext = true; // If data will be returned in form of feed page. 
		setOfCreatedSitesId = new set<String>();
		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		feedElementPageWrapObj.nextPageToken = feedElementPageObjArg.nextPageToken;
		feedElementPageWrapObj.updatesToken = feedElementPageObjArg.updatesToken;
		feedElementPageWrapObj.timeStamp = String.valueOf(system.now().getTime());
		List<FeedElementWrapper> listOfFeedElementWrapperTemp = new List<FeedElementWrapper>();
		List<String> feedElementIdsList = new List<String>();
		if(SimpplrContext.isFeatureEnabled('Full_External_Search') || SimpplrContext.aiContentModerationFeatureEnabled) {
			//Pre-processing loop
			for (ConnectApi.FeedElement feedElementObj : feedElementPageObjArg.elements) {
				if (feedElementObj.feedElementType == ConnectApi.FeedElementType.FeedItem) {
					getUserIdsToConvert(feedElementObj);
				}
				feedElementIdsList.add(feedElementObj.id);
			}

			getPeopleFromUserIds();
		}
		Map<String, AIWrapper.ModerationDataWrapper> feedToModerationDataMap = new Map<String, AIWrapper.ModerationDataWrapper>();
		if(SimpplrContext.aiContentModerationFeatureEnabled && feedElementIdsList != null && !feedElementIdsList.isEmpty()){
			AIDataProvider aIDataProviderObj = new AIDataProvider();
			feedToModerationDataMap = aIDataProviderObj.getModerationDataFromMS(feedElementIdsList);
		}

		List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(feedElementPageObjArg.elements);
		siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
		List<String> chatterGroupIds = new List<String>();
		for(Simpplr_Site__c siteObj : siteIdDataMap.values()) {
			chatterGroupIds.add(siteObj.Chatter_Group_Id__c);
		}
		chatterGroupDataMap = SiteService.getChatterGroupDataMap(chatterGroupIds);
		
		for (ConnectApi.FeedElement feedElementObj : feedElementPageObjArg.elements) {

			if (feedElementObj.feedElementType == ConnectApi.FeedElementType.FeedItem) {
				FeedElementWrapper feedElementItrObj = convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
				if(feedElementItrObj.postedOn == null || feedElementItrObj.postedOn.hidePost == null ||
					!feedElementItrObj.postedOn.hidePost) {
					listOfFeedElementWrapperTemp.add(feedElementItrObj);
				}
			}
			
		}
		system.debug('feedElementPageObjArg.elements'+ feedElementPageObjArg.elements);

		system.debug('feedElementPageObjArg.elements'+ feedElementPageObjArg.elements.size());
			
		if (hasCreatedSiteData && setOfCreatedSitesId != null) {
			Map<ID, CollaborationGroup> mapOfSiteIdWithGroupObj = new Map<ID, CollaborationGroup>(
					[SELECT Id, IsArchived, CollaborationType 
					FROM CollaborationGroup 
					WHERE Id IN:setOfCreatedSitesId]);
					
			if (!mapOfSiteIdWithGroupObj.isEmpty()) {
				
				for (FeedElementWrapper feedElemObj: listOfFeedElementWrapperTemp) {
					
					if (feedElemObj.createdSite != null) {
						String siteAccessType = String.valueOf(mapOfSiteIdWithGroupObj.get(feedElemObj.createdSite.id).CollaborationType);
						feedElemObj.createdSite.isActivated = !(mapOfSiteIdWithGroupObj.get(feedElemObj.createdSite.id)).IsArchived;
						feedElemObj.createdSite.isListed = 'Public'.equalsIgnoreCase(siteAccessType) || 'Private'.equalsIgnoreCase(siteAccessType);
					}
					
				}
				
			}
			
		}
		
		if (mapOfFeedIdWithListOfIdOfExtFile.keySet().size() > 0 || 
				mapOfCommentIdWithListOfIdOfExtFile.keySet().size() > 0 ) { // If gdrive box files are attached to post or comment 
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', mapOfFeedIdWithListOfIdOfExtFile.keySet());
			soqlParamMap.put('soqlParam2', mapOfCommentIdWithListOfIdOfExtFile.keySet());
			String filesQuery =  'SELECT id, title__C, Size__c, url__c, '+
                    ' Feed_Item__c, External_Id__c, MIME_Type__c, Repository__c, Feed_Comment__c,'+
                    ' Video_Status__c, Is_deleted__c, Sp_Instance_Id__c'+
					' FROM file__c '+
					' WHERE (Feed_Item__c IN :soqlParam1 OR'+
					' Feed_Comment__c IN :soqlParam2)';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> listOfExtFilesAttached = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
			Map<String, File__c> mapOfFeedIdWithExtFile = new Map<String, File__c>();
			Map<String, File__c> mapOfCommentIdWithExtFile = new Map<String, File__C>();
			
			if (!listOfExtFilesAttached.isEmpty()) {
				
				for (File__c fileObj: listOfExtFilesAttached) {
					
					if (String.isNotBlank(fileObj.Feed_Comment__c) && 
							String.isNotBlank(fileObj.Feed_Item__c)) { // For comment type file__C
						mapOfCommentIdWithExtFile.put(fileObj.Feed_Comment__c + fileObj.External_Id__c, fileObj);
						
					} else if (String.isNotBlank(fileObj.Feed_Item__c)) { // For feed type file__C 
						mapOfFeedIdWithExtFile.put(fileObj.Feed_Item__c + fileObj.External_Id__c, fileObj);
					}  
					
				}
				
			}
			
			for (FeedElementWrapper feedElemWrapObj: listOfFeedElementWrapperTemp) { 
				
				if (feedElemWrapObj.listOfFiles != null && !feedElemWrapObj.listOfFiles.isEmpty() && 
						mapOfFeedIdWithExtFile.keyset().size() > 0) { // check if external file is there for feed Id
					
					for (FileWrapper fileWrapObj: feedElemWrapObj.listOfFiles) {
						File__c fileObj = new File__c();
						
						if (feedElemWrapObj.originalPost != null && 
								feedElemWrapObj.originalPost.id != null) {
							fileObj = mapOfFeedIdWithExtFile.get(feedElemWrapObj.originalPost.id + fileWrapObj.id);
						
						} else {
							fileObj = mapOfFeedIdWithExtFile.get(feedElemWrapObj.id + fileWrapObj.id);
						} 
						
						if (fileObj != null) {
							fileWrapObj.title = fileObj.title__C;
							fileWrapObj.id = fileObj.External_Id__c;
							fileWrapObj.fileId = fileObj.id;
							fileWrapObj.size = Integer.valueOf(fileObj.Size__c);
							if (fileObj.Repository__c == 'native_video' && !SimpplrContext.isNativeVideo) {
								fileWrapObj.isAccessible = false;
							} else {
								fileWrapObj.isAccessible = !fileObj.is_Deleted__c;
							}
                            fileWrapObj.videoStatus = 1; 
                            if (fileObj.Video_Status__c != null) {
                                fileWrapObj.videoStatus = Integer.valueOf(fileObj.Video_Status__c);
                            }

							String tempFileName = fileWrapObj.title;
									
							if (String.isNotBlank(tempFileName) && tempFileName.indexOf('.') > 0 
									&& (tempFileName.indexOf('.') + 1 <= tempFileName.length())) {
								fileWrapObj.fileExtension = tempFileName.substring(tempFileName.lastIndexOf('.') + 1,
										tempFileName.length());
							} else {
								fileWrapObj.fileExtension = fileObj.MIME_Type__c;
							}
							
							fileWrapObj.type = fileObj.MIME_Type__c;
							fileWrapObj.context = fileObj.Repository__c;
							fileWrapObj.provider = fileObj.Repository__c;
							
							if(SimpplrContext.isNativeVideo && fileWrapObj.provider == 'native_video') {
								fileWrapObj.thumbnail = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileWrapObj.id +'/width/550/height/480';
								fileWrapObj.isVideo = true;
							}
							if ((fileWrapObj.provider == 'onedrive' || fileWrapObj.provider == 'sharepoint') && 
									String.isNotBlank(fileWrapObj.url)) {
								fileWrapObj.rootDirectory = Utility.getParamValueFromUrl(fileWrapObj.url, 
										'rootDirectory');
							}
							if(fileWrapObj.provider == 'sharepoint'){
								fileWrapObj.spInstanceId = fileObj.Sp_Instance_Id__c;
							}
							
						}
						
					}
					
				}
				if (feedElemWrapObj.recentComments != null && 
						feedElemWrapObj.recentComments.listOfRecentComments != null &&
						!feedElemWrapObj.recentComments.listOfRecentComments.isEmpty()) { // If external file is there in comment
					
					for (RecentCommentsWrapper commentWrapObj: feedElemWrapObj.recentComments.listOfRecentComments) {
						
						if (!commentWrapObj.listOfFiles.isEmpty() && 
								mapOfCommentIdWithExtFile.keySet().size() > 0) {
							
							for (RecentCommentsWrapper.FileWrapper  fileWrapObj: commentWrapObj.listOfFiles) { 
								File__c fileObj = new File__C();
								fileObj = mapOfCommentIdWithExtFile.get(commentWrapObj.id + fileWrapObj.id);// There is only one file attached to comment
								
								if (fileObj != null) {
									fileWrapObj.title = fileObj.title__C;
									fileWrapObj.id = fileObj.External_Id__c;
									fileWrapObj.fileId = fileObj.id;
									fileWrapObj.size = String.valueOf(fileObj.Size__c);
									if (fileObj.Repository__c == 'native_video' && !SimpplrContext.isNativeVideo) {
										fileWrapObj.isAccessible = false;
									} else {
										fileWrapObj.isAccessible = !fileObj.is_Deleted__c;
									}
                                    fileWrapObj.videoStatus = 1; 
                                
                                    if (fileObj.Video_Status__c != null) {
                                        fileWrapObj.videoStatus = Integer.valueOf(fileObj.Video_Status__c);
                                    }

									String tempFileName = fileWrapObj.title;
									
									if (String.isNotBlank(tempFileName) && 
											tempFileName.indexOf('.') > 0 && 
											(tempFileName.indexOf('.') + 1 <= tempFileName.length())) {
										fileWrapObj.fileExtension = tempFileName.substring(tempFileName.lastIndexOf('.') + 1,
												tempFileName.length());
									} else {
										fileWrapObj.fileExtension = fileObj.MIME_Type__c;
									}
									
									fileWrapObj.type = fileObj.MIME_Type__c;
									fileWrapObj.context = fileObj.Repository__c;
									fileWrapObj.provider = fileObj.Repository__c;

									if(SimpplrContext.isNativeVideo && fileWrapObj.provider == 'native_video') {
										fileWrapObj.thumbnail = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileWrapObj.id +'/width/550/height/480';
										fileWrapObj.isVideo = true;
									}
									if ((fileWrapObj.provider == 'onedrive' || fileWrapObj.provider == 'sharepoint') && 
										String.isNotBlank(fileWrapObj.url)) {
											fileWrapObj.rootDirectory = Utility.getParamValueFromUrl(fileWrapObj.url, 
											'rootDirectory');
									}
									if(fileWrapObj.provider == 'sharepoint'){
										fileWrapObj.spInstanceId = fileObj.Sp_Instance_Id__c;
									}
								}
								
							}
							
						}
					}
					
				}
				
			}
			
		}
		if(SimpplrContext.aiContentModerationFeatureEnabled){
			for (FeedElementWrapper feedElemWrapObj: listOfFeedElementWrapperTemp) { 
				Map<String, AIWrapper.ModerationMetaDataWrapper> commentsIdtoModerationStatusWrapperMap = new Map<String, AIWrapper.ModerationMetaDataWrapper>();
				if(SimpplrContext.aiContentModerationFeatureEnabled && !feedToModerationDataMap.isEmpty() && feedToModerationDataMap.containsKey(feedElemWrapObj.id)){
					AIWrapper.ModerationDataWrapper moderationDataObj = (AIWrapper.ModerationDataWrapper)feedToModerationDataMap.get(feedElemWrapObj.id);
					FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
					moderationResultObj.moderationStatus = moderationDataObj.moderationMetadata!=null && moderationDataObj.moderationMetadata.moderationStatus !=null  ? moderationDataObj.moderationMetadata.moderationStatus : null;
					feedElemWrapObj.moderationResult = moderationResultObj;
					if(feedElemWrapObj.moderationResult.moderationStatus != null && 'removed'.equalsIgnoreCase(feedElemWrapObj.moderationResult.moderationStatus)){
						feedElemWrapObj.authoredBy = new PeopleLiteWrapper();
						feedElemWrapObj.body = '';
						feedElemWrapObj.listOfFiles = new List<FileWrapper>();
						feedElemWrapObj.site = new SiteLiteWrapper();
					}
					List<AIWrapper.ModerationRepliesWrapper> moderationRepliesObjList = new List<AIWrapper.ModerationRepliesWrapper>();
					moderationRepliesObjList = moderationDataObj.replies.isEmpty() ? null : (List<AIWrapper.ModerationRepliesWrapper>)moderationDataObj.replies;
					if(moderationRepliesObjList != null){
						for(AIWrapper.ModerationRepliesWrapper wrapperObj: moderationRepliesObjList){
							commentsIdtoModerationStatusWrapperMap.put(wrapperObj.chatterReplyId, wrapperObj.moderationMetadata);
						}
					}
				}
				
				if (SimpplrContext.aiContentModerationFeatureEnabled && feedElemWrapObj.recentComments != null && 
						feedElemWrapObj.recentComments.listOfRecentComments != null &&
						!feedElemWrapObj.recentComments.listOfRecentComments.isEmpty()) { 
					
					for (RecentCommentsWrapper commentWrapObj: feedElemWrapObj.recentComments.listOfRecentComments) {
						
						if(SimpplrContext.aiContentModerationFeatureEnabled && commentsIdtoModerationStatusWrapperMap != null && !commentsIdtoModerationStatusWrapperMap.isEmpty() && commentsIdtoModerationStatusWrapperMap.containsKey(commentWrapObj.id)){
							AIWrapper.ModerationMetaDataWrapper moderationMetaDataWrapperObj = (AIWrapper.ModerationMetaDataWrapper)commentsIdtoModerationStatusWrapperMap.get(commentWrapObj.id);
							RecentCommentsWrapper.ModerationResult moderationResultObj = new RecentCommentsWrapper.ModerationResult();
							moderationResultObj.moderationStatus = moderationMetaDataWrapperObj.moderationStatus;
							if(moderationResultObj.moderationStatus != null && 'removed'.equalsIgnoreCase(moderationResultObj.moderationStatus)){
								commentWrapObj.authoredBy = new PeopleLiteWrapper();
								commentWrapObj.body = '';
								commentWrapObj.listOfFiles = new List<RecentCommentsWrapper.FileWrapper>();
							}
							commentWrapObj.moderationResult = moderationResultObj;
						}
					}
					
				}
				
			}
		}
		feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
		feedElementPageWrapObj.listOfItems.addAll(listOfFeedElementWrapperTemp);
		feedElementPageWrapObj.total = listOfFeedElementWrapperTemp.size(); 
		return feedElementPageWrapObj;
	}

	/*Method to get all user ids**/
	public static void getUserIdsToConvert(ConnectApi.FeedElement feedElementObjArg) {
		logger.logDebug('FeedDataAdapter.getUserIdsToConvert()----FeedItemId----' + feedElementObjArg.id);
		if (feedElementObjArg instanceOf ConnectAPI.FeedItem) {
			ConnectAPI.FeedItem feedItemCastedObj = (ConnectApi.FeedItem)feedElementObjArg;
				if(feedItemCastedObj.actor instanceOf ConnectApi.ActorWithId) {
					setUserIds.add(((ConnectApi.ActorWithId)(feedItemCastedObj.actor)).id);
			}
		}

		for (ConnectApi.MessageSegment segmentObj : feedElementObjArg.header.messageSegments) {
			if (segmentObj instanceOf ConnectApi.EntityLinkSegment) {
				if (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith('005')) {
					setUserIds.add(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id);
				}
			}
		}	
		if (feedElementObjArg.body != null ) {
			List<ConnectApi.MessageSegment> listOfMessageSegment = feedElementObjArg.body.messageSegments;
			for (ConnectApi.MessageSegment segment : listOfMessageSegment) {
				if (segment instanceof ConnectApi.MentionSegment) {
					ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;
					String mentionId = mentionSegment.record.id;
					if (mentionId.startsWith('005')) {
						setUserIds.add(mentionId);			
					} 
				} 
			}
		}
		if (feedElementObjArg.capabilities.comments != null) {
			ConnectApi.CommentPage commentPageObjArg = feedElementObjArg.capabilities.comments.page;
			for (ConnectApi.Comment commentObj:commentPageObjArg.items) {
				setUserIds.add(String.valueOf(commentObj.user.Id));
				List<ConnectApi.MessageSegment> messageSegments = commentObj.body.messageSegments;
				for (ConnectApi.MessageSegment segment : messageSegments) {
					if (segment instanceof ConnectApi.MentionSegment) {
						ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;
						String mentionId = mentionSegment.record.id;
						if (mentionId.startsWith('005')) {
							setUserIds.add(mentionId);			
						} 
					} 
				}
			}
		}
	}

	public static void getUserIdsToConvert(ConnectApi.CommentPage commentPageObjArg) {
		for (ConnectApi.Comment commentObj:commentPageObjArg.items) {
			setUserIds.add(String.valueOf(commentObj.user.Id));
			List<ConnectApi.MessageSegment> messageSegments = commentObj.body.messageSegments;
			for (ConnectApi.MessageSegment segment : messageSegments) {
				if (segment instanceof ConnectApi.MentionSegment) {
					ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;
					String mentionId = mentionSegment.record.id;
					if (mentionId.startsWith('005')) {
						setUserIds.add(mentionId);			
					} 
				} 
			}
		}
	}

	public static void getUserIdsToConvert(ConnectApi.Comment commentObj) {
			setUserIds.add(String.valueOf(commentObj.user.Id));
			List<ConnectApi.MessageSegment> messageSegments = commentObj.body.messageSegments;
			for (ConnectApi.MessageSegment segment : messageSegments) {
				if (segment instanceof ConnectApi.MentionSegment) {
					ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;
					String mentionId = mentionSegment.record.id;
					if (mentionId.startsWith('005')) {
						setUserIds.add(mentionId);			
					} 
				} 
			}
	}

	public static void getUserIdsToConvert(ConnectApi.ChatterLike lk) {
		setUserIds.add(String.valueOf(((ConnectApi.UserSummary)lk.User).Id));
	}

	/**
	 * @description getUserIdsToConvert
	 * @param feedElementWrapperObj
	 */
	public static void getUserIdsToConvert(JSONFeedElementWrapper feedElementWrapperObj) {
		logger.logDebug('FeedDataAdapter.getUserIdsToConvert()----JSONFeedElementWrapper----' + feedElementWrapperObj.id);
		if (feedElementWrapperObj.actor?.id != null) {
			setUserIds.add(feedElementWrapperObj.actor.id);
		}
		if (feedElementWrapperObj.header?.messageSegments != null) {
			for (JSONFeedElementWrapper.MessageSegments_Z segmentObj : feedElementWrapperObj.header.messageSegments) {
				if (segmentObj.reference != null && segmentObj.reference.id.startsWith('005')) {
					setUserIds.add(segmentObj.reference.id);
				}
			}
		}
		if (feedElementWrapperObj.body?.messageSegments != null) {
			for (JSONFeedElementWrapper.MessageSegments segment : feedElementWrapperObj.body.messageSegments) {
				if (segment.record != null && segment.record.id != null && segment.record.id.startsWith('005')) {
					setUserIds.add(segment.record.id);
				} 
			}
		}
		if (feedElementWrapperObj.capabilities?.comments?.page?.items != null) {
			for (JSONFeedElementWrapper.Items_Z commentObj : feedElementWrapperObj.capabilities.comments.page.items) {
				if(commentObj.user?.id != null) {
					setUserIds.add(commentObj.user.id);
				}
				if(commentObj.body?.messageSegments != null) {
					for (JSONFeedElementWrapper.MessageSegments_Y segment : commentObj.body.messageSegments) {
						if (segment.record?.id != null && segment.record.id.startsWith('005')) {
							setUserIds.add(segment.record.id);
						} 
					}
				}
			}
		}
		system.debug('*********setUserIds*****436' +setUserIds );

	}

	/**
	 * @description addUserIdsToConvert
	 * @param userId
	 */
	public static void addUserIdsToConvert(String userId) {
		setUserIds.add(userId);
		system.debug('setUserIds*****446' +setUserIds );

	}

	//get People record from user ids
	public static void getPeopleFromUserIds(){
		setUserIds.removeAll(mapUserIdToPeople.keySet());
		if(!setUserIds.isEmpty()) {
			for(People__c People:[SELECT Id, User__c, Full_Name__c FROM People__c WHERE User__c IN :setUserIds WITH SECURITY_ENFORCED]){
				mapUserIdToPeople.put(People.User__c, People);
			}

		}
	}

	/**
	 * @description prepare feed data wrapper object
	 * @param ConnectApi.FeedElement feedElementObjArg 
	 * @param Map<Id, Simpplr_Site__c> siteIdDataMap
	 */
	public static FeedElementWrapper convertFeedElementToWrapper(ConnectApi.FeedElement feedElementObjArg) {
		system.debug('***feedElementObjArg****   466'+feedElementObjArg);
		return convertFeedElementToWrapper(feedElementObjArg, new Map<Id, Simpplr_Site__c>());
	}
	
	/*Method to convert ConnectApi.FeedElement into Wrapper**/
	public static FeedElementWrapper convertFeedElementToWrapper(ConnectApi.FeedElement feedElementObjArg, Map<Id, Simpplr_Site__c> siteIdDataMap) {
		system.debug('***siteIdDataMap****   472 '+siteIdDataMap);

		Map<String, String> chatterGroupIdToSiteIdMap = new Map<String, String>();

		Boolean isParentPostTypeContent = false;
		Set<String> sitesWithLeadercastAccessSet = new Set<String>();
		Set<String> chatterGroupWithLeadercastAccessSet = new Set<String>();

		for(Simpplr_Site__c siteObj : siteIdDataMap.values()) {
			chatterGroupIdToSiteIdMap.put(siteObj.chatter_group_id__c, siteObj.Id);
			if(siteObj.Is_Leadercast_Enabled__c) {
				sitesWithLeadercastAccessSet.add(siteObj.Id);
				chatterGroupWithLeadercastAccessSet.add(siteObj.chatter_group_id__c);
			}			
		}
		logger.logDebug('FeedDataAdapter.convertFeedElementToWrapper()----FeedItemId----' + feedElementObjArg.id);
		FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
		feedElementWrapperObj.listOfLinks = new List<String>();

		if (feedElementObjArg.feedElementType == ConnectApi.FeedElementType.Bundle) {
			feedElementWrapperObj.feedElementType = 'Bundle';
			
		} else if (feedElementObjArg.feedElementType == ConnectApi.FeedElementType.Recommendation) {
			feedElementWrapperObj.feedElementType = 'Recommendation';
			
		} else {
			feedElementWrapperObj.feedElementType = 'FeedItem';
		}

		feedElementWrapperObj.id = feedElementObjArg.id;
		
		if (feedElementObjArg instanceOf ConnectAPI.FeedItem) {
			ConnectAPI.FeedItem feedItemCastedObj = (ConnectApi.FeedItem)feedElementObjArg;
			feedElementWrapperObj.authoredBy = new PeopleLiteWrapper();
			feedElementWrapperObj.authoredBy.img = feedItemCastedObj.photoUrl.endsWith('005/T') ? null : feedItemCastedObj.photoUrl;
			feedElementWrapperObj.authoredBy.department = '';
						
			feedElementWrapperObj.authoredBy.name = !mapUserIdToPeople.isEmpty() && mapUserIdToPeople.containsKey(((ConnectApi.ActorWithId)(feedItemCastedObj.actor)).id) ? mapUserIdToPeople.get(((ConnectApi.ActorWithId)(feedItemCastedObj.actor)).id).Full_Name__c :feedItemCastedObj.Actor.name;

			if ('User'.equalsIgnoreCase(feedItemCastedObj.actor.type) && 
					feedItemCastedObj.actor instanceOf ConnectApi.ActorWithId) {
				feedElementWrapperObj.authoredBy.UserId = ((ConnectApi.ActorWithId)(feedItemCastedObj.actor)).id;
				feedElementWrapperObj.authoredBy.sfUserId = ((ConnectApi.ActorWithId)(feedItemCastedObj.actor)).id;
				feedElementWrapperObj.authoredBy.Url = PageContext.getPageURL(Pages.app) + 
						'?u=/redirect-to-profile/' + feedElementWrapperObj.authoredBy.userId;
				feedElementWrapperObj.authoredBy.isFollowing = UserContext.usersIFollowIdSet.contains(
						feedElementWrapperObj.authoredBy.userId);
			}

			feedElementWrapperObj.canShare = isFeedTypeSharable(String.valueOf(feedItemCastedObj.type)) && feedItemCastedObj.isSharable && (feedElementObjArg.capabilities.poll == null); 			
			feedElementWrapperObj.canDelete = !feedItemCastedObj.isDeleteRestricted; 
			
		} else {
			ConnectApi.GenericFeedElement genericFeedElementCastedObj = (ConnectApi.GenericFeedElement)feedElementObjArg;
		}
		
		if (feedElementObjArg.capabilities != null && feedElementObjArg.capabilities.edit != null) {
			
			if (feedElementObjArg.capabilities.edit.isEditRestricted) {
				feedElementWrapperObj.canEdit = false;
				
			} else {
				feedElementWrapperObj.canEdit = true;
			}
			
		} else {
			feedElementWrapperObj.canEdit = false;
		} 
		
		Boolean isCreatedSite = false;
		Boolean isSharedPost = false;
		String originalPostId = '';
		
		for (ConnectApi.MessageSegment segmentObj : feedElementObjArg.header.messageSegments) {
			
			if (segmentObj instanceOf ConnectApi.EntityLinkSegment) {
				
				if (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith('0F9')) {
					Boolean isGroupPrivate = false;
					Boolean isGroupActivated = true;
					Boolean isGroupPublic = false;
					
					if (feedElementObjArg.Parent instanceOf ConnectApi.ChatterGroup) {
						ConnectApi.ChatterGroup parentGroup = (ConnectApi.ChatterGroup) feedElementObjArg.Parent;
						isGroupPrivate = (parentGroup.visibility == ConnectApi.GroupVisibilityType.PrivateAccess) ? 
								true : false;
						isGroupPublic = (parentGroup.visibility == ConnectApi.GroupVisibilityType.PublicAccess) ? 
								true : false;
						isGroupActivated = !parentGroup.isArchived;
					} 
											
					if (!isCreatedSite) {
						feedElementWrapperObj.site = new SiteLiteWrapper();
						feedElementWrapperObj.site.name = segmentObj.Text;
						feedElementWrapperObj.site.siteId = chatterGroupIdToSiteIdMap.containsKey(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id) ? chatterGroupIdToSiteIdMap.get(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id) : ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
						feedElementWrapperObj.site.chatterGroupId = ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
						feedElementWrapperObj.site.isPrivate = isGroupPrivate;
						feedElementWrapperObj.site.isListed = isGroupPrivate || isGroupPublic;
						feedElementWrapperObj.site.isActivated = isGroupActivated;
						feedElementWrapperObj.site.isMember = UserContext.chatterGroupsIFollowIdSet.contains(
								feedElementWrapperObj.site.chatterGroupId);
						feedElementWrapperObj.site.isManager = UserContext.groupsIManageIdSet.contains(feedElementWrapperObj.site.chatterGroupId);
						feedElementWrapperObj.site.isOwner = UserContext.siteIOwnMap.keySet().contains(feedElementWrapperObj.site.siteId);
						feedElementWrapperObj.site.isBroadcast = chatterGroupDataMap.get(feedElementWrapperObj.site.chatterGroupId)?.IsBroadcast;
						Map<String, String> args = new Map<String, String>();
						args.put('pageToRedirect', ServiceConstants.SITE_LANDING_PAGE_STRING);
						args.put('chatterGroupId', feedElementWrapperObj.site.chatterGroupId);
						String linkUrl = PageContext.getPageURL(Pages.PageRedirector, args);
						feedElementWrapperObj.site.Url = linkUrl;
						
					} else {
						feedElementWrapperObj.createdSite = new FeedSiteWrapper();
						feedElementWrapperObj.createdSite.id = ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
						feedElementWrapperObj.createdSite.chatterGroupId= ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
						feedElementWrapperObj.createdSite.name = segmentObj.Text;
						feedElementWrapperObj.createdSite.isPrivate = isGroupPrivate;
						feedElementWrapperObj.createdSite.isListed = isGroupPrivate || isGroupPublic;
						feedElementWrapperObj.createdSite.isActivated = isGroupActivated;
						
						//Fix for MAR-4961 
						if (setOfCreatedSitesId != null) {
							setOfCreatedSitesId.add(feedElementWrapperObj.createdSite.chatterGroupId);
						}
						
						Map<String, String> args = new Map<String, String>();
						args.put('pageToRedirect', ServiceConstants.SITE_LANDING_PAGE_STRING);
						args.put('chatterGroupId', feedElementWrapperObj.createdSite.chatterGroupId);
						String linkUrl = PageContext.getPageURL(Pages.PageRedirector, args);
						feedElementWrapperObj.createdSite.Url = linkUrl;
					}
					
				} else if (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith('005')) {
					
					if (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id != feedElementWrapperObj.authoredBy.userId) {
						feedElementWrapperObj.addressedTo = new PeopleLiteWrapper();
						feedElementWrapperObj.addressedTo.id = ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
						feedElementWrapperObj.addressedTo.sfUserId = ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
						feedElementWrapperObj.addressedTo.name = !mapUserIdToPeople.isEmpty() && mapUserIdToPeople.containsKey(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id) ? mapUserIdToPeople.get(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id).Full_Name__c : segmentObj.Text;
						feedElementWrapperObj.addressedTo.department = '';
						feedElementWrapperObj.addressedTo.img = '';
						String linkUrl = PageContext.getPageURL(Pages.app) + 
								'?u=/redirect-to-profile/' + feedElementWrapperObj.addressedTo.id;
						feedElementWrapperObj.addressedTo.Url = linkUrl;
					}
					
					if (isSharedPost) {
						feedElementWrapperObj.originalPost = new FeedElementWrapper.OriginalPostWrapper();
						ConnectAPI.FeedItem feedItemCastedObj = (ConnectApi.FeedItem)feedElementObjArg;
						feedElementWrapperObj.originalPost.id = feedItemCastedObj.originalFeedItem.id;//((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
						Map<String, String> feedArgs = new Map<String, String>();
						feedArgs.put('feedId', originalPostId);
						String feedlinkUrl = PageContext.getPageURL(Pages.app)+'?u=/feed/'+originalPostId;
						feedElementWrapperObj.originalPost.url = feedlinkUrl;
						feedElementWrapperObj.originalPost.authoredBy = new PeopleLiteWrapper();
						feedElementWrapperObj.originalPost.authoredBy.name = !mapUserIdToPeople.isEmpty() && mapUserIdToPeople.containsKey(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id) ? mapUserIdToPeople.get(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id).Full_Name__c : segmentObj.Text;
						feedElementWrapperObj.originalPost.authoredBy.sfUserId = feedElementWrapperObj.originalPost.authoredBy.userId;
						feedElementWrapperObj.originalPost.authoredBy.department = '';
						feedElementWrapperObj.originalPost.authoredBy.userId = ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
						String linkUrl = PageContext.getPageURL(Pages.app) + 
								'?u=/redirect-to-profile/' + feedElementWrapperObj.originalPost.authoredBy.userId;
						feedElementWrapperObj.originalPost.authoredBy.Url = linkUrl;
					}
					
				} else if (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith('0D5')) {
					isSharedPost = true;
					originalPostId = ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
					
				} else if (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith('069')) {
					feedElementWrapperObj.postedOn = new FeedElementWrapper.postedOnWrapper();
					feedElementWrapperObj.postedOn.Id =  ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
					feedElementWrapperObj.postedOn.name = segmentObj.Text;
					feedElementWrapperObj.postedOn.title = segmentObj.Text;
					Map<String, String> args = new Map<String, String>();
					args.put('fileId', ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id);
					String linkUrl = PageContext.getPageURL(Pages.FileDetail, args);
					feedElementWrapperObj.postedOn.url = linkUrl;
					feedElementWrapperObj.isFileNewVersion = true;
					
				} else if (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith(Utility.getSimpplrContentPrefix())) {
					feedElementWrapperObj.postedOn = convertToPostedOnWrapper(((ConnectApi.EntityLinkSegment)segmentObj).reference.Id, segmentObj.Text);
					isParentPostTypeContent = true;
					
				} else if (((ConnectApi.EntityLinkSegment)segmentObj).reference.Id.startsWith(Utility.getPeoplePrefix())) {
					feedElementWrapperObj.postedOn = new FeedElementWrapper.postedOnWrapper();
					feedElementWrapperObj.postedOn.Id =  ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
					feedElementWrapperObj.postedOn.name = segmentObj.Text;
					feedElementWrapperObj.postedOn.title = segmentObj.Text;
					String linkUrl = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + 
							feedElementWrapperObj.postedOn.Id;
					feedElementWrapperObj.postedOn.url = linkUrl;
				
				} else {
					feedElementWrapperObj.postedOn = new FeedElementWrapper.postedOnWrapper();
					feedElementWrapperObj.postedOn.Id =  ((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
					feedElementWrapperObj.postedOn.name = segmentObj.Text;
					feedElementWrapperObj.postedOn.title = segmentObj.Text;
					feedElementWrapperObj.postedOn.url =  SimpplrContext.salesforceBaseUrl +'/' + 
							((ConnectApi.EntityLinkSegment)segmentObj).reference.Id;
				}
				
			} else if (segmentObj instanceOf ConnectApi.TextSegment) {
				
				if (((ConnectApi.TextSegment)segmentObj).text.containsIgnoreCase('created the public group')) {
					isCreatedSite = true;
					hasCreatedSiteData = true;
					feedElementWrapperObj.canEdit = false;
				} 
					
			}

		}
 
		feedElementWrapperObj.postType = 'post';
		feedElementWrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(feedElementObjArg.createdDate);

		/**Different feed Types handling**/
		if (feedElementObjArg.capabilities.link != null) {			
			Boolean isSimpplrContentLink = false;
			Boolean isCampaignLink = false;
			String urlToProcess = feedElementObjArg.capabilities.link.Url;
			
			if(FeedUtility.isSimpplrContentLink(urlToProcess)) {
				isSimpplrContentLink = true;
				
			} else if (urlToProcess.containsIgnoreCase('app') && urlToProcess.containsIgnoreCase('campaignId')) {
				isCampaignLink = SimpplrContext.isFeatureEnabled('Employee_Advocacy');	
			}
			
			if (isSimpplrContentLink) {
				PageReference internalSFLink = new PageReference(urlToProcess);
				String simpContentId = internalSFLink.getParameters().get('contentId');
				String simpFileId = internalSFLink.getParameters().get('fileId');
				String simpAlbumFileId = '';
				
				if (String.isBlank(simpFileId) && String.isBlank(simpContentId)) {
					
					if (urlToProcess.containsIgnoreCase('/gallery/')) {
						simpAlbumFileId = urlToProcess.substringAfterLast('/').substringBefore('&');	
						simpContentId = urlToProcess.substringBeforeLast('/gallery/').substringAfterLast('/').substringBefore('&');
					
					} else {
						simpContentId = urlToProcess.substringAfterLast('/').substringBefore('&');
					}
					
				}					
				
				String simpSiteId = internalSFLink.getParameters().get('siteId');
				
				if (String.isNotBlank(simpContentId)) {
					feedElementWrapperObj.postType = 'link';
					feedElementWrapperObj.link = new LinkWrapper();
					feedElementWrapperObj.link.url = feedElementObjArg.capabilities.link.Url+'&origin=feed';
					feedElementWrapperObj.link.title = feedElementObjArg.capabilities.link.UrlName;	

					if (urlToProcess.containsIgnoreCase('fromPromoteModal')) {
						feedElementWrapperObj.link.isFromPromoteModal = true;

					} else {
						feedElementWrapperObj.link.isFromPromoteModal = false;
					}
					
					if (!urlToProcess.containsIgnoreCase('/gallery/')) {						
						List<Simpplr_content__c> listOfSimpplrContent = [SELECT id, Site__r.Name, 
								Site__r.Landing_Page__c, Site__r.Id,Site__r.Title_Content_Version__c,Site__r.Title_Content_Document__c,
								Site__r.Site_Type__c,Site__r.Is_Active__c,Site__c, Primary_Author__r.Full_Name__c, 
								Primary_Author__c, CreatedById, Title__c, Is_Published__c, Is_Deleted__c, Primary_Author__r.User__c,
								Site__r.Chatter_Group_Id__c ,Is_Must_read__c, Primary_Author__r.User__r.SmallPhotoUrl, 
								CreatedDate, Display_Excerpt__c, Type__c, Album_Video_Count__c, 
								Publish_Start_DateTime__c, Last_Edited_DateTime__c, 
								Album_Allow_All_to_Upload__c, Album_Image_Count__c, Event_Is_All_Day__c, 
								Event_Start_DateTime__c, Event_End_DateTime__c, Event_TimezoneSidKey__c, Pages_Category__c, 
								Pages_Category__r.Name__c, (Select Id, createdDate from 
								Must_Read_Confirm_History__r Where People__c =:UserContext.getCurrentUserInfo.Id), 
								(SELECT Id, Content_Version__c, Content_Document__c, Video_provider__c, Repository__c, External_id__c, Video_Status__c,
								Title_Image_Type__c, Is_Title_Image__c, Thumbnail_URL__c, MIME_Type__c 
								FROM File_Simpplr_Content__r WHERE Location__c IN ('cover' , 'media') And 
								Is_Deleted__c = false ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, 
								Order__c desc LIMIT 4) 
								FROM Simpplr_Content__c WHERE Id=:simpContentId and 
								(Type__c='BlogPost' or Site__r.Show_In_Simpplr__c = true) WITH SECURITY_ENFORCED];	
						
						if (!listOfSimpplrContent.isEmpty()) { 
							feedElementWrapperObj.link.id = listOfSimpplrContent[0].id;
							if(listOfSimpplrContent[0].Is_Deleted__c != true && listOfSimpplrContent[0].Is_Published__c == true) {
								feedElementWrapperObj.link.description = String.isBlank(listOfSimpplrContent[0].Display_Excerpt__c)?'':listOfSimpplrContent[0].Display_Excerpt__c.unescapeHtml4();
								feedElementWrapperObj.link.title = listOfSimpplrContent[0].Title__c;
							}

							if (ServiceConstants.TYPE_PAGE.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
								feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.app) + 
										'?u=/site/' + listOfSimpplrContent[0].site__c + '/page/' + 
										listOfSimpplrContent[0].Id+'&origin=feed';                                          
								feedElementWrapperObj.link.category = new LinkWrapper.CategoryWrapper();
								feedElementWrapperObj.link.category.id = listOfSimpplrContent[0].Pages_Category__c;
								feedElementWrapperObj.link.category.name = listOfSimpplrContent[0].Pages_Category__r.Name__c;
								feedElementWrapperObj.link.category.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + listOfSimpplrContent[0].site__c + '/content&pageCategoryId=' + listOfSimpplrContent[0].Pages_Category__c; 

							} else if (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)) {
								feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.app) + 
										'?u=/people/' + listOfSimpplrContent[0].Primary_Author__c + '/blog/' + 
										listOfSimpplrContent[0].id+'&origin=feed';                                          
					 
							} else if (ServiceConstants.TYPE_EVENT.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)) {
								feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.app) + 
										'?u=/site/' + listOfSimpplrContent[0].site__c + '/event/' + 
										listOfSimpplrContent[0].Id+'&origin=feed';
								// Additional event related info
								TimeZone tz = Timezone.getTimeZone(listOfSimpplrContent[0].Event_TimezoneSidKey__c);
								feedElementWrapperObj.link.timezoneName = Utility.timezoneIdToDisplayLabel(listOfSimpplrContent[0].Event_TimezoneSidKey__c);
								feedElementWrapperObj.link.timezoneIso = tz.getID();
								feedElementWrapperObj.link.timezoneOffset = tz.getOffset(system.today());

								feedElementWrapperObj.link.startsAt = Utility.dateTimeToMomentJSDateTime(listOfSimpplrContent[0].Event_Start_DateTime__c);
								DateTime endDateTimeValue = listOfSimpplrContent[0].Event_End_DateTime__c;
								
								if ('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
									endDateTimeValue = listOfSimpplrContent[0].Event_End_DateTime__c.addMinutes(-1);
								}
								
								feedElementWrapperObj.link.endsAt = Utility.dateTimeToMomentJSDateTime(endDateTimeValue);
								feedElementWrapperObj.link.isAllDay = listOfSimpplrContent[0].Event_Is_All_Day__c;
								
								if (listOfSimpplrContent[0].Event_Start_DateTime__c.isSameDay(endDateTimeValue)) {
									feedElementWrapperObj.link.isMultiDay = false;
								
								} else {
									feedElementWrapperObj.link.isMultiDay = true;
								}
								
							} else if (ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
								feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.app) + 
										'?u=/site/' + listOfSimpplrContent[0].site__c + '/album/' + 
										listOfSimpplrContent[0].Id+'&origin=feed';                                           
							}
							
							feedElementWrapperObj.link.isMustRead = listOfSimpplrContent[0].Is_Must_read__c;
							
							if (listOfSimpplrContent[0].Must_Read_Confirm_History__r.isEmpty()) {
								feedElementWrapperObj.link.hasRead = false;
							
							} else {
								feedElementWrapperObj.link.hasRead = true;
							}
							
							if (!listOfSimpplrContent[0].File_Simpplr_Content__r.isEmpty() ) {
								
								if (listOfSimpplrContent[0].Is_Published__c) {
								
									if (listOfSimpplrContent[0].Type__c == 'Album') {
										feedElementWrapperObj.link.listOfTopAlbumImages = new List<LinkWrapper.AlbumImagesWrapper>();
										
										for (File__c fileObj: listOfSimpplrContent[0].File_Simpplr_Content__r) {
											feedElementWrapperObj.link.imageUrl = fileObj.Thumbnail_URL__c;
											LinkWrapper.AlbumImagesWrapper imagesWrapperObj = new LinkWrapper.AlbumImagesWrapper();
											imagesWrapperObj.albumMediaId = fileObj.id;
											
											if (String.isNotBlank(fileObj.Content_Version__c)) {
												imagesWrapperObj.isVideo = false;
												imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
												imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
												
												if (fileObj.Is_Title_Image__c == true) {
													feedElementWrapperObj.link.imgTHUMB720BY480URL =  SimpplrContext.salesforceHost +
														ServiceConstants.FILE_CONNECT_API_SUB_URL +
														fileObj.Content_Document__c + '/rendition?type=THUMB720BY480';
												}

											} else {
												imagesWrapperObj.isVideo = true;
												imagesWrapperObj.thumbnailImg = fileObj.Thumbnail_URL__c;
												imagesWrapperObj.img = fileObj.Thumbnail_URL__c;
												imagesWrapperObj.provider = String.isNotBlank(fileObj.Video_provider__c) ? fileObj.Video_provider__c : String.isNotBlank(fileObj.Repository__c) ? fileObj.Repository__c : '';
												imagesWrapperObj.status = fileObj.Video_Status__c;
												imagesWrapperObj.videoId = fileObj.External_id__c;
												
												if (fileObj.Is_Title_Image__c == true) {
													feedElementWrapperObj.link.imgTHUMB720BY480URL =  fileObj.Thumbnail_URL__c;
												}

											}

											feedElementWrapperObj.link.listOfTopAlbumImages.add(imagesWrapperObj);
												
										}											
									
									} else {
										feedElementWrapperObj.link.imageUrl = Utility.getFileDownloadURL(listOfSimpplrContent[0].File_Simpplr_Content__r[0].Content_Version__c);
										feedElementWrapperObj.link.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + 
												ServiceConstants.FILE_CONNECT_API_SUB_URL +
												listOfSimpplrContent[0].File_Simpplr_Content__r[0].Content_Document__c + 
												'/rendition?type=THUMB720BY480';
									}
									
								}
								
							}
							
							String siteImageUrl = '';
							String imgThumbnail = '';
							Boolean isSitePrivate = false;
							Boolean isSiteUnlisted = false;
							
							if (listOfSimpplrContent[0].Site__r.Chatter_Group_Id__c != null) {
								siteImageUrl =  String.isBlank(listOfSimpplrContent[0].Site__r.Title_Content_Version__c) ? 
										null: Utility.getFileDownloadURLFor720By480(listOfSimpplrContent[0].Site__r.Title_Content_Version__c);
								imgThumbnail =  String.isBlank(listOfSimpplrContent[0].Site__r.Title_Content_Version__c) ? 
										null: Utility.getFileDownloadURLFor120BY90(listOfSimpplrContent[0].Site__r.Title_Content_Version__c);
								
								if ('public'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)) {
									isSitePrivate = false;
									
								} else if ('private'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)) {
									isSitePrivate = true;

								} else if ('unlisted'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)) {
									isSiteUnlisted = true;
								}
								
							}
							
							feedElementWrapperObj.link.authoredBy =  new PeopleLiteWrapper();
							feedElementWrapperObj.link.authoredBy.id = listOfSimpplrContent[0].Primary_Author__c;
							feedElementWrapperObj.link.authoredBy.name = listOfSimpplrContent[0].Primary_Author__r.Full_Name__c;
							feedElementWrapperObj.link.authoredBy.img = listOfSimpplrContent[0].Primary_Author__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : listOfSimpplrContent[0].Primary_Author__r.User__r.SmallPhotoUrl;
							String profileLinkUrl = PageContext.getPageURL(Pages.app) + '?u=/people/' + listOfSimpplrContent[0].Primary_Author__c;
							feedElementWrapperObj.link.authoredBy.url = profileLinkUrl;
							
							if (String.isNotBlank(listOfSimpplrContent[0].Site__c)) {
								feedElementWrapperObj.link.site =  new SiteLiteWrapper();
								feedElementWrapperObj.link.site.siteId =  listOfSimpplrContent[0].Site__c;
								feedElementWrapperObj.link.site.name = listOfSimpplrContent[0].Site__r.Name;
								feedElementWrapperObj.link.site.isActivated = listOfSimpplrContent[0].Site__r.Is_Active__c;
								feedElementWrapperObj.link.site.img = siteImageUrl; 
								feedElementWrapperObj.link.site.imgThumbnail = imgThumbnail;
								feedElementWrapperObj.link.site.isPrivate = isSitePrivate;
								feedElementWrapperObj.link.site.isMember = UserContext.chatterGroupsIFollowIdSet.contains(
										listOfSimpplrContent[0].Site__r.Chatter_Group_Id__c);
								feedElementWrapperObj.link.site.access = listOfSimpplrContent[0].Site__r.Site_Type__c.toLowerCase(); 
								feedElementWrapperObj.link.site.isListed = !isSiteUnlisted;
								String sitelinkUrl = PageContext.getPageURL(Pages.app) + '?u=/site/' + 
										listOfSimpplrContent[0].Site__c + '/' + listOfSimpplrContent[0].Site__r.Landing_Page__c;
								feedElementWrapperObj.link.site.url = sitelinkUrl;
							}
							
							//feedElementWrapperObj.link.category =  new LinkWrapper.CategoryWrapper();
							String dateStringValue = String.valueOf(listOfSimpplrContent[0].CreatedDate);
							
							if (String.isNotBlank(dateStringValue)) { 
								DateTime DateTimeValue = listOfSimpplrContent[0].CreatedDate;
								feedElementWrapperObj.link.createdAt = DateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
							}
							
							feedElementWrapperObj.link.type = listOfSimpplrContent[0].Type__c.toLowerCase();
							feedElementWrapperObj.link.videoCount = Integer.valueof(listOfSimpplrContent[0].Album_Video_Count__c);
							feedElementWrapperObj.link.isOpenToSubmissions  = listOfSimpplrContent[0].Album_Allow_All_to_Upload__c;
							feedElementWrapperObj.link.imageCount = Integer.valueof(listOfSimpplrContent[0].Album_Image_Count__c);
							feedElementWrapperObj.link.isPublished = listOfSimpplrContent[0].Is_Published__c;

							if (listOfSimpplrContent[0].Is_Deleted__c ==  true || (String.isNotBlank(listOfSimpplrContent[0].Site__c) 
									&& feedElementWrapperObj.link.site.isPrivate && !feedElementWrapperObj.link.site.isMember)) {
								feedElementWrapperObj.link.isPublished = false;
							}	

							feedElementWrapperObj.link.isDeleted = listOfSimpplrContent[0].Is_Deleted__c;
						}
						
					} else {
						Map<String, Object> soqlParamMap = new Map<String, Object>();
						soqlParamMap.put('soqlParam1', simpAlbumFileId);
						String filesQuery = 'SELECT Id, Simpplr_Content__c, Is_Title_Image__c,'+
								' Simpplr_Content__r.Site__r.Name, Simpplr_Content__r.Site__r.Landing_Page__c, '+
								' Simpplr_Content__r.Site__r.Id, Simpplr_Content__r.Site__r.Title_Content_Version__c,'+
								' Simpplr_Content__r.Site__r.Title_Content_Document__c,'+
								' Simpplr_Content__r.Site__r.Site_Type__c, Simpplr_Content__r.Site__r.Is_Active__c,'+ 
								' Simpplr_Content__r.Site__c, Author__r.Full_Name__c, Author__c, CreatedById,'+ 
								' Simpplr_Content__r.Title__c, Simpplr_Content__r.Is_Published__c, '+
								' Simpplr_Content__r.Site__r.Chatter_Group_Id__c, Simpplr_Content__r.Is_Must_read__c,'+
								' Author__r.User__r.SmallPhotoUrl, CreatedDate, Simpplr_Content__r.Type__c, '+
								' Simpplr_Content__r.Display_Excerpt__c, Thumbnail_URL__c, Content_Version__c, '+
								' Content_Document__c, MIME_Type__c, External_Id__c, Video_Status__c,  Url__c, '+
								' Simpplr_Content__r.Album_Video_Count__c, Simpplr_Content__r.Album_Allow_All_to_Upload__c, '+
								' Simpplr_Content__r.Album_Image_Count__c, Is_Deleted__c  '+
								' FROM File__c'+ 
								' WHERE Id=:soqlParam1 And Simpplr_Content__r.is_Deleted__c=false';	
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						List<File__c> listOfSimpplrAlbumFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
						if (!listOfSimpplrAlbumFile.isEmpty()) { 
							
							feedElementWrapperObj.link.id = listOfSimpplrAlbumFile[0].Simpplr_Content__c;
							feedElementWrapperObj.link.albumMediaId = listOfSimpplrAlbumFile[0].Id;
							feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + 
									listOfSimpplrAlbumFile[0].Simpplr_Content__r.site__c + '/album/' + 
									listOfSimpplrAlbumFile[0].Simpplr_Content__c+'&origin=feed';   
							feedElementWrapperObj.link.isAvailable = listOfSimpplrAlbumFile[0].Is_Deleted__c ? false : true;
									
							if (listOfSimpplrAlbumFile[0].MIME_Type__c == 'image') {
								feedElementWrapperObj.link.downloadUrl = Utility.getFileDownloadURL(listOfSimpplrAlbumFile[0].Content_Version__c);
							
							} else if (listOfSimpplrAlbumFile[0].MIME_Type__c == 'video') {
								feedElementWrapperObj.link.video = new LinkWrapper.VideoWrapper();
								feedElementWrapperObj.link.video.Id = 	listOfSimpplrAlbumFile[0].External_Id__c;
								
								if (listOfSimpplrAlbumFile[0].Url__c.contains('://youtu.be/') || 
										listOfSimpplrAlbumFile[0].Url__c.contains('.youtube.com/watch')) {
									feedElementWrapperObj.link.video.provider = 'youtube';
									
								} else if (listOfSimpplrAlbumFile[0].Url__c.contains('://embed.vidyard.com/share')) { 
									feedElementWrapperObj.link.video.provider = 'vidyard';
									
								} else if (listOfSimpplrAlbumFile[0].Url__c.contains('https://vimeo.com/')) {
									feedElementWrapperObj.link.video.provider = 'vimeo';
									
								} else if (listOfSimpplrAlbumFile[0].Url__c.contains('wistia.')) {
									feedElementWrapperObj.link.video.provider = 'wistia';
								
								} else if (listOfSimpplrAlbumFile[0].Url__c.containsIgnoreCase('vbrick.com')) {
									feedElementWrapperObj.link.video.provider = 'vbrick';
									
								} else if (listOfSimpplrAlbumFile[0].Url__c.containsIgnoreCase('entryId')) {
									feedElementWrapperObj.link.video.provider = 'native_video';
									feedElementWrapperObj.link.video.videoStatus = listOfSimpplrAlbumFile[0].Video_Status__c;
									feedElementWrapperObj.link.video.thumbnailImg = listOfSimpplrAlbumFile[0].Thumbnail_URL__c;
								}
																
							}

							feedElementWrapperObj.link.description = String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Display_Excerpt__c)?
									'': listOfSimpplrAlbumFile[0].Simpplr_Content__r.Display_Excerpt__c.unescapeHtml4();
							feedElementWrapperObj.link.title = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Title__c;
							
							feedElementWrapperObj.link.isMustRead = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Is_Must_read__c;
								
							if (listOfSimpplrAlbumFile[0].Simpplr_Content__r.Is_Published__c) {						
								feedElementWrapperObj.link.imageUrl = listOfSimpplrAlbumFile[0].Thumbnail_URL__c;

								if (String.isNotBlank(listOfSimpplrAlbumFile[0].Content_Document__c)) {
									
									if (listOfSimpplrAlbumFile[0].Is_Title_Image__c == true) {
										feedElementWrapperObj.link.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + 
											ServiceConstants.FILE_CONNECT_API_SUB_URL + 
											listOfSimpplrAlbumFile[0].Content_Document__c + 
											'/rendition?type=THUMB720BY480';
									}

								} else if (listOfSimpplrAlbumFile[0].Is_Title_Image__c == true) {
									feedElementWrapperObj.link.imgTHUMB720BY480URL = listOfSimpplrAlbumFile[0].Thumbnail_URL__c;
								}

							}
							
							String siteImageUrl = '';
							String imgContentDocumentId = '';
							String imgThumbnail = '';
							Boolean isSitePrivate = false;
							Boolean isSiteUnlisted = false;
							
							if (listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c != null) {
								imgContentDocumentId = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Document__c;
								siteImageUrl =  String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c)? 
										null : Utility.getFileDownloadURLFor720By480(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c);
								imgThumbnail =  String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c) ? 
										null : Utility.getFileDownloadURLFor120BY90(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c);
								
								if ('public'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)) {
									isSitePrivate = false;
									
								} else if ('private'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)) {
									isSitePrivate = true;
								
								} else if ('unlisted'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)) {
									isSiteUnlisted = true;
								}
								
							}
							
							feedElementWrapperObj.link.authoredBy =  new PeopleLiteWrapper();
							feedElementWrapperObj.link.authoredBy.id = listOfSimpplrAlbumFile[0].Author__c;
							feedElementWrapperObj.link.authoredBy.sfUserId = listOfSimpplrAlbumFile[0].Author__c;
							feedElementWrapperObj.link.authoredBy.name = listOfSimpplrAlbumFile[0].Author__r.Full_Name__c; 
							feedElementWrapperObj.link.authoredBy.img = Utility.getProfilePhotoURL(listOfSimpplrAlbumFile[0].Author__r.User__r.SmallPhotoUrl);
							String profileLinkUrl = PageContext.getPageURL(Pages.app) + '?u=/people/' + 
									listOfSimpplrAlbumFile[0].Author__c;
							feedElementWrapperObj.link.authoredBy.url = profileLinkUrl;
							
							if (String.isNotBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c)) {
								feedElementWrapperObj.link.site =  new SiteLiteWrapper();
								feedElementWrapperObj.link.site.siteId =  listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c;
								feedElementWrapperObj.link.site.name = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Name;
								feedElementWrapperObj.link.site.isActivated = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Is_Active__c;
								feedElementWrapperObj.link.site.img = siteImageUrl;
								feedElementWrapperObj.link.site.imgContentDocumentId = imgContentDocumentId;
								feedElementWrapperObj.link.site.imgThumbnail = imgThumbnail;
								feedElementWrapperObj.link.site.isPrivate = isSitePrivate;
								feedElementWrapperObj.link.site.access = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c.toLowerCase(); 
								feedElementWrapperObj.link.site.isListed = !isSiteUnlisted;
								feedElementWrapperObj.link.site.isMember = UserContext.chatterGroupsIFollowIdSet.contains(
											listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c);
								String sitelinkUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c + '/' + listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Landing_Page__c;
								feedElementWrapperObj.link.site.url = sitelinkUrl;
							}
							
							String dateStringValue = String.valueOf(listOfSimpplrAlbumFile[0].CreatedDate);
							
							if (String.isNotBlank(dateStringValue)) { 
								feedElementWrapperObj.link.createdAt = Utility.dateTimeToMomentJSDateTime(listOfSimpplrAlbumFile[0].CreatedDate);
							}
							
							feedElementWrapperObj.link.type = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Type__c.toLowerCase();
							feedElementWrapperObj.link.videoCount = Integer.valueof(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Album_Video_Count__c);
							feedElementWrapperObj.link.isOpenToSubmissions  = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Album_Allow_All_to_Upload__c;
							feedElementWrapperObj.link.imageCount = Integer.valueof(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Album_Image_Count__c);
							feedElementWrapperObj.link.isPublished = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Is_Published__c;						        	
									
						}														

					}
						
				} else if (String.isNotBlank(simpFileId)) {
					String queryStr = 'SELECT Title, Id, Description, CreatedBy.SmallPhotoUrl, CreatedBy.Name, CreatedBy.Id,'
							+ ' CreatedById, CreatedDate, ContentSize,'
							+ ' LatestPublishedVersionId, FileExtension, FileType,'
							+ ' (Select Id, IsLatest,FileExtension From ContentVersions WHERE IsLatest= true)' 
							+ ' FROM ContentDocument WHERE Id=:simpFileId';
	
					if (SimpplrContext.isCommunitiesEnabled) {
						queryStr += ' AND LatestPublishedVersion.NetworkId = null';
					}
					
					List<ContentDocument> listOfContentDoc = Database.query(queryStr);

					if (!listOfContentDoc.isEmpty()) {
						feedElementWrapperObj.postType = 'file';						
						String dateStringValue = String.valueOf(listOfContentDoc[0].CreatedDate);					        
						feedElementWrapperObj.listOfFiles = new List<FileWrapper>();							
						FileWrapper fileWrapObj = new FileWrapper();
						fileWrapObj.isAccessible = true;
						
						if (listOfContentDoc[0].Id == null) {
							fileWrapObj.isAccessible = false;
							feedElementWrapperObj.canShare = false;
						}
						
						fileWrapObj.id = listOfContentDoc[0].id;
						fileWrapObj.name = listOfContentDoc[0].title;
						Map<String, String> arg = new Map<String, String>();
						arg.put('fileId', listOfContentDoc[0].id);			                
						String linkUrl = PageContext.getPageURL(Pages.FileDetail, arg);
						fileWrapObj.url = linkUrl;				
						
						if (listOfContentDoc[0].ContentSize != null) {
							fileWrapObj.size = Integer.valueOf(listOfContentDoc[0].ContentSize);
						} 
						
						if ((listOfContentDoc[0].FileExtension == 'jpg') || 
								(listOfContentDoc[0].FileExtension == 'png') || 
								(listOfContentDoc[0].FileExtension == 'jpeg')){		
							fileWrapObj.thumbnail  = Utility.getFileDownloadURLFor720By480(listOfContentDoc[0].LatestPublishedVersionId);
							fileWrapObj.isImage = true;
						
						} else if (listOfContentDoc[0].FileExtension == 'gif') {
							fileWrapObj.thumbnail  = Utility.getFileDownloadURL(listOfContentDoc[0].LatestPublishedVersionId);
							fileWrapObj.isImage = true;		    				
						
						} else if((listOfContentDoc[0].FileExtension == 'doc')|| (listOfContentDoc[0].FileExtension == 'docx') ||
								(listOfContentDoc[0].FileExtension == 'txt')|| (listOfContentDoc[0].FileExtension == 'pdf') ||
								(listOfContentDoc[0].FileExtension == 'ppt')|| (listOfContentDoc[0].FileExtension == 'pptx')){
							fileWrapObj.thumbnail  = Utility.getFileDownloadURLFor240BY180(listOfContentDoc[0].LatestPublishedVersionId);
							fileWrapObj.isImage = false;				    					
						}
						
						fileWrapObj.downloadURL = Utility.getFileDownloadURL(listOfContentDoc[0].LatestPublishedVersionId);				
						String fileExtension = listOfContentDoc[0].FileExtension;				
						fileWrapObj.isDownloadableOniOS = Utility.isDownloadableOniOS(fileExtension, null);		
						fileWrapObj.type = Utility.getFileType(listOfContentDoc[0].fileType);		
						feedElementWrapperObj.listOfFiles.add(fileWrapObj);	        
						
					} else {
						feedElementWrapperObj.postType = 'link';
						feedElementWrapperObj.link = new LinkWrapper();
						feedElementWrapperObj.link.url = feedElementObjArg.capabilities.link.Url+'&origin=feed';
						feedElementWrapperObj.link.title = feedElementObjArg.capabilities.link.UrlName;	
						
					}
				
				}
					
			} else if (isCampaignLink) {
				PageReference campaignURL = new PageReference(urlToprocess);
				String campaignId = campaignURL.getParameters().get('campaignId');
				CampaignService campaignServiceObj = new CampaignService();
				
				feedElementWrapperObj.postType = 'campaign';
				feedElementWrapperObj.campaign = campaignServiceObj.getCampaignForFeed(campaignId);	
					
			} else {
				feedElementWrapperObj.postType = 'link';
				feedElementWrapperObj.link = new LinkWrapper();
				feedElementWrapperObj.link.url = feedElementObjArg.capabilities.link.Url;
				feedElementWrapperObj.link.title = feedElementObjArg.capabilities.link.UrlName;		
				feedElementWrapperObj.listOfLinks.add(feedElementObjArg.capabilities.link.Url);				
				
			}
			
		}

		if (feedElementObjArg.capabilities.poll != null) {
			feedElementWrapperObj.postType = 'poll';
			feedElementWrapperObj.poll = new PollWrapper();
			feedElementWrapperObj.poll.title = feedElementWrapperObj.body;
			feedElementWrapperObj.poll.totalVotes = feedElementObjArg.capabilities.poll.totalVoteCount;
			feedElementWrapperObj.poll.myChoiceId = feedElementObjArg.capabilities.poll.myChoiceId;
			feedElementWrapperObj.canEdit = false; 
			
			if (feedElementWrapperObj.poll.myChoiceId != null && 
					feedElementWrapperObj.poll.myChoiceId.length() > 0) {
				feedElementWrapperObj.poll.hasVoted = true;
				
			} else {
				feedElementWrapperObj.poll.hasVoted = false;
			}
			
			if (!feedElementObjArg.capabilities.poll.choices.isEmpty()) {
				List<PollChoiceWrapper> listOfFeedPollChoiceWrapper = new List<PollChoiceWrapper>();
				
				for (ConnectApi.FeedPollChoice feedPollChObj : feedElementObjArg.capabilities.poll.choices) {
					listOfFeedPollChoiceWrapper.add(convertFeedPollChoiceToWrapper(feedPollChObj));
				}
				
				feedElementWrapperObj.poll.listOfAnswers = new List<PollChoiceWrapper>();
				feedElementWrapperObj.poll.listOfAnswers.addAll(listOfFeedPollChoiceWrapper);
			}
								
		} 

		if (feedElementObjArg.capabilities.files != null) {
			feedElementWrapperObj.postType = 'file';
			feedElementWrapperObj.listOfFiles = new List<FileWrapper>();
			
			for (ConnectApi.Content contentObj : feedElementObjArg.capabilities.files.items) {
				FileWrapper fileWrapObj = new FileWrapper();
				fileWrapObj.isAccessible = true;
				fileWrapObj.fileExtension = contentObj.fileExtension;
				
				if (contentObj.Id == null) {
					fileWrapObj.isAccessible = false;
					feedElementWrapperObj.canShare = false;
				}
				
				fileWrapObj.id = contentObj.id;
				fileWrapObj.name = contentObj.title;				
				Map<String, String> args = new Map<String, String>();
				args.put('fileId', contentObj.id);
				
				String linkUrl = PageContext.getPageURL(Pages.FileDetail, args);
				fileWrapObj.url = linkUrl;				
				
				if (contentObj.fileSize != null) {
					fileWrapObj.size = Integer.valueOf(contentObj.fileSize);
				} 

				fileWrapObj.isImage = false;
				
				if ((contentObj.fileExtension == 'jpg') || (contentObj.fileExtension == 'png') || 
						(contentObj.fileExtension == 'jpeg')) {		
					fileWrapObj.thumbnail  = Utility.getFileDownloadURLFor720By480(contentObj.versionId);
					fileWrapObj.isImage = true;
					
				} else if (contentObj.FileExtension == 'gif') {
					fileWrapObj.thumbnail  = Utility.getFileDownloadURL(contentObj.versionId);
					fileWrapObj.isImage = true;	
											
				} else if ((contentObj.fileExtension == 'doc')|| (contentObj.fileExtension == 'docx') ||
						(contentObj.fileExtension == 'txt')|| (contentObj.fileExtension == 'pdf') ||
						(contentObj.fileExtension == 'ppt')|| (contentObj.fileExtension == 'pptx')) {
					fileWrapObj.thumbnail  = Utility.getFileDownloadURLFor240BY180(contentObj.versionId);
					fileWrapObj.isImage = false;				    					
				}					
				
				fileWrapObj.downloadURL = Utility.getFileDownloadURL(contentObj.versionId);				
				String fileExtension = contentObj.fileExtension;				
				fileWrapObj.isDownloadableOniOS = Utility.isDownloadableOniOS(fileExtension, null);			
				fileWrapObj.type = Utility.getFileType(contentObj.fileType);
				feedElementWrapperObj.listOfFiles.add(fileWrapObj);
			}
			
		} 

		if (feedElementObjArg.capabilities.trackedChanges != null) {
			feedElementWrapperObj.postType = 'changes';
			feedElementWrapperObj.canEdit = false;
			feedElementWrapperObj.changes = new ChangeContainerWrapper();
			List<ConnectApi.MessageSegment> msgSgmtList = feedElementObjArg.header.messageSegments;			
			List<String> listOfTrackedChange = new List<String>();
			
			for (ConnectApi.MessageSegment oneMsgSegment : msgSgmtList) {			
				
				if (oneMsgSegment instanceof ConnectApi.FieldChangeSegment) {	
					ConnectApi.FieldChangeSegment typeCastToFieldChngeSgmt = (ConnectApi.FieldChangeSegment) oneMsgSegment;
					listOfTrackedChange.add(typeCastToFieldChngeSgmt.text);
					
				} else if (oneMsgSegment instanceof ConnectApi.MoreChangesSegment) {
					ConnectApi.MoreChangesSegment typeCastToMoreChngSgmt = (ConnectApi.MoreChangesSegment) oneMsgSegment;
					List<ConnectApi.FieldChangeSegment> fieldChngSgmtList = typeCastToMoreChngSgmt.moreChanges;
					
					for (ConnectApi.FieldChangeSegment oneFieldChangeSegment : fieldChngSgmtList) {
						listOfTrackedChange.add(oneFieldChangeSegment.text);
					}
											
				} else if (oneMsgSegment instanceof ConnectApi.TextSegment) {
					ConnectApi.TextSegment textSegmentObj = (ConnectApi.TextSegment)oneMsgSegment;
					listOfTrackedChange.add(textSegmentObj.text);
					
				}
														
			}
			
			if (!listOfTrackedChange.isEmpty()) {
				
				if (listOfTrackedChange.size() > 2) {
					String changeText = '';
					feedElementWrapperObj.changes.amountNotInSummary = listOfTrackedChange.size() - 2;
					
					for (Integer i = 0; i < 2; i++) {
						changeText = changeText + listOfTrackedChange[i]+',';
					}
					
					feedElementWrapperObj.changes.summary = changeText;
					
				} else {
					String changeText = '';
					feedElementWrapperObj.changes.amountNotInSummary = 0;
					
					for (Integer i = 0; i < listOfTrackedChange.size(); i++) {
						changeText = changeText + listOfTrackedChange[i]+',';
					}
					
					changeText =changeText.substring(0, changeText.lastIndexOf(','));
					feedElementWrapperObj.changes.summary = changeText;
				}
				
				feedElementWrapperObj.changes.listOfChanges = new List<String>();
				feedElementWrapperObj.changes.listOfChanges.addAll(listOfTrackedChange);
			}
			
		} 
		
		/**Handling bookmarks**/
		if (feedElementObjArg.capabilities.bookmarks != null) {
			feedElementWrapperObj.canFavorite = true;
			feedElementWrapperObj.isFavorited = feedElementObjArg.capabilities.bookmarks.isBookmarkedByCurrentUser;
		
		} else {
			feedElementWrapperObj.canFavorite = false;
		}
		
		/**Handling Topic**/
		feedElementWrapperObj.listOfTopics = new List<TopicWrapper>();
		
		if (feedElementObjArg.capabilities.Topics != null) {
			mapOfTopicNameToIdGlobal = new Map <String, String>();
			feedElementWrapperObj.canChangeTopics = feedElementObjArg.capabilities.Topics.canAssignTopics;
			
				for (ConnectApi.Topic topicObj : feedElementObjArg.capabilities.Topics.items) {
				feedElementWrapperObj.listOfTopics.add(convertTopicToWrapper(topicObj));
				String topicNameForProcessing = topicObj.name.replaceAll('\\s+', '');
				topicNameForProcessing = topicNameForProcessing.toLowerCase();
				mapOfTopicNameToIdGlobal.put(topicNameForProcessing, topicObj.id); 
				}
			
		} else {
			feedElementWrapperObj.canChangeTopics = false;
		}
		
		/** Feed comments handling**/
		if (feedElementObjArg.capabilities.comments != null) {
			feedElementWrapperObj.recentComments = convertCommentPageToWrapper(feedElementObjArg.capabilities.comments.page);
			feedElementWrapperObj.commentCount = feedElementWrapperObj.recentComments.total;
			
		} else { 
			feedElementWrapperObj.recentComments = new RecentCommentsContainerWrapper();
			feedElementWrapperObj.recentComments.total = 0;
			feedElementWrapperObj.commentCount = 0;
		}
		
		/**Feed like handling**/
		
		if (feedElementObjArg.capabilities.chatterLikes != null) {
			feedElementWrapperObj.isliked = feedElementObjArg.capabilities.chatterLikes.isLikedByCurrentUser;
			feedElementWrapperObj.likeCount = feedElementObjArg.capabilities.chatterLikes.page.total;
			
			if (feedElementObjArg.capabilities.chatterLikes.myLike != null) {
				feedElementWrapperObj.likeId = feedElementObjArg.capabilities.chatterLikes.myLike.Id;
				
			} else {
				feedElementWrapperObj.likeId = null;
			}
			
		} else {
			feedElementWrapperObj.likeCount = 0;
			feedElementWrapperObj.likeId = null;
		}

		if (feedElementObjArg.capabilities.close != null) {

			if (feedElementObjArg.capabilities.close.isClosed) {
				feedElementWrapperObj.isClosed = true;
			
			} else {
				feedElementWrapperObj.isClosed = false;
			}
			
		}
		
		Map<String, String> args = new Map<String, String>();
		args.put('feedId', feedElementWrapperObj.id);
		String linkUrl = PageContext.getPageURL(Pages.app)+'?u=/feed/'+feedElementWrapperObj.id;            
		feedElementWrapperObj.url = linkUrl;
		
		// Feed Text body processing  
		if (feedElementObjArg.body != null ) {
			List<ConnectApi.MessageSegment> listOfMessageSegment = feedElementObjArg.body.messageSegments;
			String feedItemMsgTempStr = processFromSegments(listOfMessageSegment);
			
				
			if (feedItemMsgTempStr.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0) { // User posted text is seprated from google file info added by us using \u2063\uFEFF\u200b\uFEFF\u2063
				isExtFilePresent =  true; // External file is there setting context variable  
				String gdInfoStr =  feedItemMsgTempStr.substring(feedItemMsgTempStr.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
						ServiceConstants.FEED_EXT_FILE_SEPRATOR.length() + 1, feedItemMsgTempStr.length());
				feedItemMsgTempStr = feedItemMsgTempStr.substring(0, 
						feedItemMsgTempStr.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR));
				
				List<String> listOfGoogleFilesInfo = new List<String>();
				listOfGoogleFilesInfo = gdInfoStr.split('\n'); // Files are seprated by newline 				
				if (feedElementWrapperObj.listOfFiles == null) {
					feedElementWrapperObj.postType = 'file';
					feedElementWrapperObj.listOfFiles = new List<FileWrapper>();
				}
				
				if (!listOfGoogleFilesInfo.isEmpty()) {
					List<String> listOfExtFileForMap = new List<String>(); // for query optimization
					
					for (String singleFileStr: listOfGoogleFilesInfo) {
						FileWrapper fileWrapObj = new FileWrapper();
						String urlTempStr = singleFileStr.trim();
							
						if (urlTempStr.indexOf('>') > 0) {
							urlTempStr = urlTempStr.subString((urlTempStr.indexOf('>') + 1), 
									urlTempStr.indexOf('</a>'));
						}
						
						PageReference extFileSFLink = new PageReference(urlTempStr);
						String extFileId = extFileSFLink.getParameters().get('fileId'); 
						String videoEntityId = extFileSFLink.getParameters().get('entry_id');
						String provider = extFileSFLink.getParameters().get('provider');
						fileWrapObj.url = urlTempStr; 
						if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)){
							videoEntityId = extFileId ;
						}	
						fileWrapObj.id = String.isNotBlank(videoEntityId) ? videoEntityId : extFileId;
						if(SimpplrContext.isNativeVideo && String.isNotBlank(videoEntityId)) {
							fileWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/video/' + videoEntityId;
							fileWrapObj.thumbnail = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileWrapObj.id +'/width/550/height/480';
							fileWrapObj.isVideo = true;
						}
						listOfExtFileForMap.add(fileWrapObj.url); // added to temp list for map processing
						feedElementWrapperObj.listOfFiles.add(fileWrapObj); // added to feedItem
					}
					
					if (isFeedPageContext != null && isFeedPageContext) { // If fetching feedElement page 
						
						if (isSharedPost && feedElementWrapperObj.originalPost !=null) {
							mapOfFeedIdWithListOfIdOfExtFile.put(feedElementWrapperObj.originalPost.id, listOfExtFileForMap);							
						}
						mapOfFeedIdWithListOfIdOfExtFile.put(feedElementWrapperObj.id, listOfExtFileForMap);
					
					} else { // if returning data in case of new feed posted
						String originalFeedId = feedElementWrapperObj.id;
						
						if (isSharedPost){
							originalFeedId = feedElementWrapperObj.originalPost.id;
						} 
						Map<String, Object> soqlParamMap = new Map<String, Object>();
						soqlParamMap.put('soqlParam1', originalFeedId);
						String filesQuery =  'SELECT id, title__C, Size__c, url__c,'+ 
                                ' Feed_Item__c, External_Id__c, MIME_Type__c, Repository__c,'+ 
                                ' Video_Status__c, Is_Deleted__c, Sp_Instance_Id__c '+
								' FROM file__c '+
								' WHERE Feed_Item__c =:soqlParam1';
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						List<File__c> listOfExtFilesAttached = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
						if (!listOfExtFilesAttached.isEmpty() && 
								!feedElementWrapperObj.listOfFiles.isEmpty()) {
							
							for (FileWrapper fileWrapObj: feedElementWrapperObj.listOfFiles) {
								
								for (File__c fileObj: listOfExtFilesAttached) {
									
									if (fileObj.External_Id__c == fileWrapObj.id) {
										fileWrapObj.title = fileObj.title__C;
										fileWrapObj.id = fileObj.External_Id__c;
										fileWrapObj.fileId = fileObj.id;
										fileWrapObj.size = Integer.valueOf(fileObj.Size__c);
										if (fileObj.Repository__c == 'native_video' && !SimpplrContext.isNativeVideo) {
											fileWrapObj.isAccessible = false;
										} else {
											fileWrapObj.isAccessible = !fileObj.is_Deleted__c;
										}
                                        fileWrapObj.videoStatus = 1; 
                                
                                        if (fileObj.Video_Status__c != null) {
                                            fileWrapObj.videoStatus = Integer.valueOf(fileObj.Video_Status__c);
                                        }

										String tempFileName = fileWrapObj.title;
									
										if (String.isNotBlank(tempFileName) && 
												tempFileName.indexOf('.') > 0 && 
												(tempFileName.indexOf('.') + 1 <= tempFileName.length())) {
											fileWrapObj.fileExtension = tempFileName.substring(tempFileName.lastIndexOf('.') +1 ,
													tempFileName.length());
										} else {
											fileWrapObj.fileExtension = fileObj.MIME_Type__c;
										}
										
										fileWrapObj.type = fileObj.MIME_Type__c;
										fileWrapObj.context = fileObj.Repository__c;
										fileWrapObj.provider = fileObj.Repository__c;
										
										if(SimpplrContext.isNativeVideo && fileWrapObj.provider == 'native_video') {
											fileWrapObj.thumbnail = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileWrapObj.id +'/width/550/height/480';
											fileWrapObj.isVideo = true;
										}
										if ((fileWrapObj.provider == 'onedrive' || 
												fileWrapObj.provider == 'sharepoint') && 
												String.isNotBlank(fileWrapObj.url)) {
											fileWrapObj.rootDirectory = Utility.getParamValueFromUrl(fileWrapObj.url, 
													'rootDirectory');
										}
										if(fileWrapObj.provider == 'sharepoint'){
											fileWrapObj.spInstanceId = fileObj.Sp_Instance_Id__c;
										}
										
										break;
									}
									
								}
								
							}
							
						}
						
					}
					
				}
			
			} 

			if (feedItemMsgTempStr.contains(ServiceConstants.RECOGNITION_FILE_SEPRATOR)) { // Recognition Post identify elements by us using \u2063\uFEFF\uFEFF\u200b\uFEFF\uFEFF\u2063 
				String feedId = feedElementWrapperObj.originalPost != null ? feedElementWrapperObj.originalPost.Id : feedElementWrapperObj.id;
				FeedElementWrapper.RecognitionResponseInfo recognitionResponseObj = getRecognition(feedId);
				feedElementWrapperObj.recognitionAwardedTo = recognitionResponseObj.recognitionAwardedTo;
				feedElementWrapperObj.recognitionAwardedBy = recognitionResponseObj.recognitionAwardedBy ;
				feedElementWrapperObj.recognitionAwardId = recognitionResponseObj.recognitionAwardId;
				feedElementWrapperObj.subType = recognitionResponseObj.subType;
				feedElementWrapperObj.objectId = recognitionResponseObj.objectId;	

				feedElementWrapperObj.postType = 'recognition';
				feedItemMsgTempStr = feedItemMsgTempStr.remove(ServiceConstants.RECOGNITION_FILE_SEPRATOR); //Remove recognition special character
			}

			if (feedItemMsgTempStr.contains(ServiceConstants.QNA_QUESTION_SEPERATOR)) {
				String regex = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}';
				Matcher matcher = Pattern.compile(regex).matcher(feedItemMsgTempStr);
				if(matcher.find()){
					feedElementWrapperObj.questionId = matcher.group(0);
					feedElementWrapperObj.postType = 'question';
				}
			}

			feedItemMsgTempStr = feedItemMsgTempStr.replaceAll('<li><p>', '<li>');
			feedItemMsgTempStr = feedItemMsgTempStr.replaceAll('</p></li>', '</li>');
			feedElementWrapperObj.body = feedItemMsgTempStr;
			try{
				currIdx = 0;
				feedElementWrapperObj.bodyJson = processFromSegmentsV1(listOfMessageSegment);	
			}catch(Exception ex){
				logger.logDebug(ex);
			}
			
		}
		
		if (feedElementObjArg.capabilities.poll != null) {
			feedElementWrapperObj.poll.title = feedElementWrapperObj.body;
		}
		
		feedElementWrapperObj.listOfMentions =  new List<MentionWrapper>();
		
		if (listOfMentionUserGlobal != null) {
			feedElementWrapperObj.listOfMentions.addAll(listOfMentionUserGlobal);
		}

		if (listOfLinksGlobal != null) {
			feedElementWrapperObj.listOfLinks.addAll(listOfLinksGlobal);
		}
		
		if (feedElementWrapperObj.originalPost != null && feedElementWrapperObj.addressedTo != null) {
			feedElementWrapperObj.addressedTo = null;
        }

		String chatterGrpOrSiteId = feedElementObjArg.parent.id;
		if (feedElementWrapperObj.site != null) {
			chatterGrpOrSiteId = feedElementWrapperObj.site.siteId;
		} else if(isParentPostTypeContent) {
			if(feedElementWrapperObj.postedOn != null) {
				chatterGrpOrSiteId = feedElementWrapperObj.postedOn.siteId;
			}
		}
		List<String> chatterGrpIdsList = new List<String>();
		for (Simpplr_Site__c  siteObj: UserContext.sitesIManageContentsMap.values()) {
			chatterGrpIdsList.add(siteObj.Chatter_Group_Id__c);
		}

		if (String.isNotBlank(chatterGrpOrSiteId) && (UserContext.sitesIManageIdSet.contains(chatterGrpOrSiteId) || UserContext.groupsIManageMap.keySet().contains(chatterGrpOrSiteId) || UserContext.sitesIManageContentsMap.keySet().contains(chatterGrpOrSiteId) || chatterGrpIdsList.contains(chatterGrpOrSiteId))) {
			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_ALL_SITES.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
				feedElementWrapperObj.canUploadAllFileTypes =  true;
			} else if (ServiceConstants.ALLOW_FILE_UPLOAD_AS_All_USER.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
				feedElementWrapperObj.canUploadAllFileTypes =  false;
			} else if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)){
				for (Simpplr_Site__c siteObj : siteIdDataMap.values()) {
					if (String.isNotBlank(chatterGrpOrSiteId) && siteObj != null && (chatterGrpOrSiteId.equals(siteObj.id) || chatterGrpOrSiteId.equals(siteObj.Chatter_Group_Id__c))) {
						feedElementWrapperObj.canUploadAllFileTypes =  siteObj.Allow_File_Upload_App_Permission__c;
						
						break;
					}
				}
			}
		} else {
			feedElementWrapperObj.canUploadAllFileTypes =  false;
		}

		feedElementWrapperObj.canAccessLeadercast = false;
		if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_ALL_USER)) {
			feedElementWrapperObj.canAccessLeadercast = true;
		} else if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_APP_MANAGERS)
					&& UserContext.isUserAppModerator) {
			feedElementWrapperObj.canAccessLeadercast = true;
		} else if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS)) {
			if(UserContext.canAccessLeadercast) {
				feedElementWrapperObj.canAccessLeadercast = true;
			} else if(String.isNotBlank(chatterGrpOrSiteId) && 
					(UserContext.sitesIManageIdSet.contains(chatterGrpOrSiteId) || 
					UserContext.groupsIManageMap.keySet().contains(chatterGrpOrSiteId) || 
					UserContext.sitesIManageContentsMap.keySet().contains(chatterGrpOrSiteId) || 
					chatterGrpIdsList.contains(chatterGrpOrSiteId)) && 
					(sitesWithLeadercastAccessSet.contains(chatterGrpOrSiteId) || 
					chatterGroupWithLeadercastAccessSet.contains(chatterGrpOrSiteId))) {					
				feedElementWrapperObj.canAccessLeadercast = true;									
			}
		}		
        
		return feedElementWrapperObj;
			  
	}

	public static TopicWrapper convertTopicToWrapper (ConnectApi.Topic topicObjArg) {
		TopicWrapper topicWrapObj = new TopicWrapper();
		topicWrapObj.id = topicObjArg.id;
		topicWrapObj.name = topicObjArg.name;
		topicWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/topic/' + topicWrapObj.id + '/feed';
		topicWrapObj.isFollowing = UserContext.topicsIFollowIdSet.contains(topicObjArg.id);
		return topicWrapObj;
	}
    
    public static LikersWrapper generateLikeUserWrapObj (ConnectApi.ChatterLike lk, Integer wrapperType) {
		LikersWrapper likeUser = new LikersWrapper();
		likeUser.Id = lk.Id;
		likeUser.Name = !mapUserIdToPeople.isEmpty() && mapUserIdToPeople.containsKey(((ConnectApi.UserSummary)lk.User).id) ? mapUserIdToPeople.get(((ConnectApi.UserSummary)lk.User).id).Full_Name__c : ((ConnectApi.UserSummary)lk.User).name;
		likeUser.userId = ((ConnectApi.UserSummary)lk.User).Id;
		ConnectApi.Photo likeUserPhotoObj = lk.User.photo;
		likeUser.img = Utility.getProfilePhotoURL(likeUserPhotoObj.smallPhotoUrl);
		String linkUrl = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + 
				((ConnectApi.UserSummary)lk.User).id;
		likeUser.userUrl = linkUrl;
		likeUser.url = linkUrl;
		return likeUser;
    }
    
	/*Method to convert ConnectApi.FeedPollChoice into FeedPollChoiceWrapper	**/
	public static PollChoiceWrapper convertFeedPollChoiceToWrapper (ConnectApi.FeedPollChoice feedPollChObjArg) {
		PollChoiceWrapper feedPollChWrapObj =  new PollChoiceWrapper();
		feedPollChWrapObj.id = feedPollChObjArg.id;
		feedPollChWrapObj.position = feedPollChObjArg.position;
		feedPollChWrapObj.title = feedPollChObjArg.text;
		feedPollChWrapObj.voteCount = feedPollChObjArg.voteCount;
		feedPollChWrapObj.percentage = (Decimal.valueOf((feedPollChObjArg.voteCountRatio * 100))).setScale(2);
		return feedPollChWrapObj;
	}
	
	/**Method to convert ConnectApi.CommentPage to Wrapper for recent. Used while first load**/
	public static RecentCommentsContainerWrapper convertCommentPageToWrapper (ConnectApi.CommentPage commentPageObjArg) {
		isCommentPageContext = true; // Converting feed comment page instead of single comment 
		RecentCommentsContainerWrapper commentPageWrapObj = new RecentCommentsContainerWrapper();
		commentPageWrapObj.nextPageToken = commentPageObjArg.nextPageToken;
		commentPageWrapObj.total = commentPageObjArg.total;
		List<RecentCommentsWrapper> listOfRecentCommentWrapTemp = new List<RecentCommentsWrapper>(); 
		system.debug('***commentPageObjArg.items**** 1675 '+ commentPageObjArg.items);
		system.debug('***commentPageObjArg.items**** 1675 '+ commentPageObjArg.items.size());

		for (ConnectApi.Comment commentObj:commentPageObjArg.items) {
			listOfRecentCommentWrapTemp.add(convertFeedCommentToWrapper(commentObj));
		}

		
		if (isFeedPageContext == null || (isFeedPageContext != null && !isFeedPageContext)) {
			
			if (mapOfCommentIdWithListOfIdOfExtFile.keySet().size() >0 ) { // If gdrive box files are attached to post or comment 
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', mapOfCommentIdWithListOfIdOfExtFile.keySet());
				String filesQuery =  'SELECT id, title__C, Size__c, url__c,'+ 
                        ' Feed_Item__c, External_Id__c, MIME_Type__c, Repository__c, Feed_Comment__c,'+
                        ' Video_Status__c, Is_Deleted__c, Sp_Instance_Id__c'+
						' FROM file__c '+
						' WHERE Feed_Comment__c IN :soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<File__c> listOfExtFilesAttached = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
				Map<String, File__c> mapOfCommentIdWithExtFile = new Map<String, File__C>();
			
				if (!listOfExtFilesAttached.isEmpty()) {
					
					for (File__c fileObj: listOfExtFilesAttached) {
						mapOfCommentIdWithExtFile.put(fileObj.Feed_Comment__c, fileObj);
					}
					
				}
						
				for (RecentCommentsWrapper commentWrapObj: listOfRecentCommentWrapTemp) {
					
					if (!commentWrapObj.listOfFiles.isEmpty() && 
							mapOfCommentIdWithExtFile.keySet().size() > 0) {
						
						for (RecentCommentsWrapper.FileWrapper  fileWrapObj: commentWrapObj.listOfFiles) { 
							File__c fileObj = new File__C();
							fileObj = mapOfCommentIdWithExtFile.get(commentWrapObj.id);// There is only one file attached to comment
							
							if (fileObj != null){
								fileWrapObj.title = fileObj.title__C;
								fileWrapObj.id = fileObj.External_Id__c;
								fileWrapObj.fileId = fileObj.id;
								fileWrapObj.size = String.valueOf(fileObj.Size__c);
								if (fileObj.Repository__c == 'native_video' && !SimpplrContext.isNativeVideo) {
									fileWrapObj.isAccessible = false;
								} else {
									fileWrapObj.isAccessible = !fileObj.is_Deleted__c;
								}
                                fileWrapObj.videoStatus = 1; 

                                if (fileObj.Video_Status__c != null) {
                                    fileWrapObj.videoStatus = Integer.valueOf(fileObj.Video_Status__c);
                                }
                                
								String tempFileName = fileWrapObj.title;
									
								if (String.isNotBlank(tempFileName) && 
										tempFileName.indexOf('.') > 0 && 
										(tempFileName.indexOf('.') + 1 <= tempFileName.length())) {
									fileWrapObj.fileExtension = tempFileName.substring(tempFileName.lastIndexOf('.') + 1,
											tempFileName.length());
								} else {
									fileWrapObj.fileExtension = fileObj.MIME_Type__c;
								}
								
								fileWrapObj.type = fileObj.MIME_Type__c;
								fileWrapObj.context = fileObj.Repository__c;
								fileWrapObj.provider = fileObj.Repository__c;

								if(SimpplrContext.isNativeVideo && fileWrapObj.provider == 'native_video') {
									fileWrapObj.thumbnail = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileWrapObj.id +'/width/550/height/480';
									fileWrapObj.isVideo = true;
								}
								if ((fileWrapObj.provider == 'onedrive' || fileWrapObj.provider == 'sharepoint') 
										&& String.isNotBlank(fileWrapObj.url)) {
									fileWrapObj.rootDirectory = Utility.getParamValueFromUrl(fileWrapObj.url, 
											'rootDirectory');
								}
								if(fileWrapObj.provider == 'sharepoint'){
									fileWrapObj.spInstanceId = fileObj.Sp_Instance_Id__c;
								}
							}
							
						}
						
					}
							
				}
			
			}
		}
		
		commentPageWrapObj.listOfRecentComments = new List<RecentCommentsWrapper>();
		commentPageWrapObj.listOfRecentComments.addAll(listOfRecentCommentWrapTemp);
		commentPageWrapObj.listOfItems = new List<RecentCommentsWrapper>();
		commentPageWrapObj.listOfItems.addAll(listOfRecentCommentWrapTemp);
		return commentPageWrapObj;

	}
	
	/*	Method to convert ConnectApi.Comment to wrapper	**/
	public static RecentCommentsWrapper convertFeedCommentToWrapper (ConnectApi.Comment commentObjArg) {
		RecentCommentsWrapper commentWrapObj = new RecentCommentsWrapper();
		commentWrapObj.id = commentObjArg.id;
		String urlToProcess;
		for (ConnectApi.MessageSegment segmentObj : commentObjArg.body.messageSegments) {
			if(segmentObj instanceof ConnectApi.LinkSegment){
				ConnectApi.LinkSegment linkSegment = (ConnectApi.LinkSegment) segmentObj;
				urlToProcess = linkSegment.url;
			}
		}
		if (String.isNotBlank(urlToProcess)) {			
			Boolean isSimpplrContentLink = false;
			Boolean isCampaignLink = false;
			logger.logDebug('urlToProcess----'+urlToProcess);
			
			if(FeedUtility.isSimpplrContentLink(urlToProcess)) {			
				isSimpplrContentLink = true;
			
			} else if (urlToProcess.containsIgnoreCase('app') && urlToProcess.containsIgnoreCase('campaignId')) {
				isCampaignLink = SimpplrContext.isFeatureEnabled('Employee_Advocacy');	
			}
			
			if (isSimpplrContentLink) {
				logger.logDebug('isSimpplrContentLink');
				PageReference internalSFLink = new PageReference(urlToProcess);
				String simpContentId = internalSFLink.getParameters().get('contentId');
				String simpFileId = internalSFLink.getParameters().get('fileId');
				String simpAlbumFileId = '';
				logger.logDebug('contentId '+simpContentId+'simpFileId '+simpFileId);
				
				if (String.isBlank(simpFileId) && String.isBlank(simpContentId)) {
					
					if (urlToProcess.containsIgnoreCase('/gallery/')) {
						simpAlbumFileId = urlToProcess.substringAfterLast('/').substringBefore('&');	
						simpContentId = urlToProcess.substringBeforeLast('/gallery/').substringAfterLast('/').substringBefore('&');
					
					} else {
						simpContentId = urlToProcess.substringAfterLast('/').substringBefore('&');
					}
					
				}					
				
				String simpSiteId = internalSFLink.getParameters().get('siteId');
				
				if (String.isNotBlank(simpContentId)) {
					commentWrapObj.postType = 'link';
					commentWrapObj.link = new LinkWrapper();
					commentWrapObj.link.url = urlToProcess;

					if (urlToProcess.containsIgnoreCase('fromPromoteModal')) {
						commentWrapObj.link.isFromPromoteModal = true;
		
					} else {
						commentWrapObj.link.isFromPromoteModal = false;
					}
					
					if (!urlToProcess.containsIgnoreCase('/gallery/')) {					
						List<Simpplr_content__c> listOfSimpplrContent = [SELECT id, Site__r.Name, 
								Site__r.Landing_Page__c, Site__r.Id,Site__r.Title_Content_Version__c,Site__r.Title_Content_Document__c,
								Site__r.Site_Type__c,Site__r.Is_Active__c,Site__c, Primary_Author__r.Full_Name__c, 
								Primary_Author__c, CreatedById, Title__c, Is_Published__c, Primary_Author__r.User__c,
								Site__r.Chatter_Group_Id__c ,Is_Must_read__c, Primary_Author__r.User__r.SmallPhotoUrl, 
								CreatedDate, Display_Excerpt__c, Type__c, Album_Video_Count__c, 
								Publish_Start_DateTime__c, Last_Edited_DateTime__c, 
								Album_Allow_All_to_Upload__c, Album_Image_Count__c, Event_Is_All_Day__c, 
								Event_Start_DateTime__c, Event_End_DateTime__c, Event_TimezoneSidKey__c, Pages_Category__c, 
								Pages_Category__r.Name__c, (Select Id, createdDate from 
								Must_Read_Confirm_History__r Where People__c =:UserContext.getCurrentUserInfo.Id), 
								(SELECT Id, Content_Version__c, Content_Document__c, 
								Title_Image_Type__c, Is_Title_Image__c, Thumbnail_URL__c, MIME_Type__c 
								FROM File_Simpplr_Content__r WHERE Location__c IN ('cover' , 'media') And 
								Is_Deleted__c = false ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, 
								Order__c desc LIMIT 4) 
								FROM Simpplr_Content__c WHERE Id=:simpContentId and 
								(Type__c='BlogPost' or Site__r.Show_In_Simpplr__c = true) WITH SECURITY_ENFORCED];	
						
						if (!listOfSimpplrContent.isEmpty()) { 
							commentWrapObj.link.id = listOfSimpplrContent[0].id;
							commentWrapObj.link.description = String.isBlank(listOfSimpplrContent[0].Display_Excerpt__c)?'':listOfSimpplrContent[0].Display_Excerpt__c.unescapeHtml4();
							commentWrapObj.link.title = listOfSimpplrContent[0].Title__c;
		
							if (ServiceConstants.TYPE_PAGE.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
								commentWrapObj.link.url = PageContext.getPageURL(Pages.app) + 
										'?u=/site/' + listOfSimpplrContent[0].site__c + '/page/' + 
										listOfSimpplrContent[0].Id+'&origin=feed';                                          
										commentWrapObj.link.category = new LinkWrapper.CategoryWrapper();
										commentWrapObj.link.category.id = listOfSimpplrContent[0].Pages_Category__c;
										commentWrapObj.link.category.name = listOfSimpplrContent[0].Pages_Category__r.Name__c;
										commentWrapObj.link.category.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + listOfSimpplrContent[0].site__c + '/content&pageCategoryId=' + listOfSimpplrContent[0].Pages_Category__c; 
														
							} else if (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)) {
								commentWrapObj.link.url = PageContext.getPageURL(Pages.app) + 
										'?u=/people/' + listOfSimpplrContent[0].Primary_Author__c + '/blog/' + 
										listOfSimpplrContent[0].id+'&origin=feed';                                          
					 
							} else if (ServiceConstants.TYPE_EVENT.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)) {
								commentWrapObj.link.url = PageContext.getPageURL(Pages.app) + 
										'?u=/site/' + listOfSimpplrContent[0].site__c + '/event/' + 
										listOfSimpplrContent[0].Id+'&origin=feed';
								// Additional event related info
								TimeZone tz = Timezone.getTimeZone(listOfSimpplrContent[0].Event_TimezoneSidKey__c);
								commentWrapObj.link.timezoneName = Utility.timezoneIdToDisplayLabel(listOfSimpplrContent[0].Event_TimezoneSidKey__c);
								commentWrapObj.link.timezoneIso = tz.getID();
								commentWrapObj.link.timezoneOffset = tz.getOffset(system.today());
		
								commentWrapObj.link.startsAt = Utility.dateTimeToMomentJSDateTime(listOfSimpplrContent[0].Event_Start_DateTime__c);
								DateTime endDateTimeValue = listOfSimpplrContent[0].Event_End_DateTime__c;
								
								if ('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
									endDateTimeValue = listOfSimpplrContent[0].Event_End_DateTime__c.addMinutes(-1);
								}
								
								commentWrapObj.link.endsAt = Utility.dateTimeToMomentJSDateTime(endDateTimeValue);
								commentWrapObj.link.isAllDay = listOfSimpplrContent[0].Event_Is_All_Day__c;
								
								if (listOfSimpplrContent[0].Event_Start_DateTime__c.isSameDay(endDateTimeValue)) {
									commentWrapObj.link.isMultiDay = false;
								
								} else {
									commentWrapObj.link.isMultiDay = true;
								}
								
							} else if (ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
								commentWrapObj.link.url = PageContext.getPageURL(Pages.app) + 
										'?u=/site/' + listOfSimpplrContent[0].site__c + '/album/' + 
										listOfSimpplrContent[0].Id+'&origin=feed';                                           
							}
							
							commentWrapObj.link.isMustRead = listOfSimpplrContent[0].Is_Must_read__c;
							
							if (listOfSimpplrContent[0].Must_Read_Confirm_History__r.isEmpty()) {
								commentWrapObj.link.hasRead = false;
							
							} else {
								commentWrapObj.link.hasRead = true;
							}
							
							if (!listOfSimpplrContent[0].File_Simpplr_Content__r.isEmpty() ) {
								
								if (listOfSimpplrContent[0].Is_Published__c) {
								
									if (listOfSimpplrContent[0].Type__c == 'Album') {
										commentWrapObj.link.listOfTopAlbumImages = new List<LinkWrapper.AlbumImagesWrapper>();
										
										for (File__c fileObj: listOfSimpplrContent[0].File_Simpplr_Content__r) {
											commentWrapObj.link.imageUrl = fileObj.Thumbnail_URL__c;
											LinkWrapper.AlbumImagesWrapper imagesWrapperObj = new LinkWrapper.AlbumImagesWrapper();
											imagesWrapperObj.albumMediaId = fileObj.id;
											
											if (String.isNotBlank(fileObj.Content_Version__c)) {
												imagesWrapperObj.isVideo = false;
												imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
												imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
												
												if (fileObj.Is_Title_Image__c == true) {
													commentWrapObj.link.imgTHUMB720BY480URL =  SimpplrContext.salesforceHost +
														ServiceConstants.FILE_CONNECT_API_SUB_URL +
														fileObj.Content_Document__c + '/rendition?type=THUMB720BY480';
												}
		
											} else {
												imagesWrapperObj.isVideo = true;
												imagesWrapperObj.thumbnailImg = fileObj.Thumbnail_URL__c;
												imagesWrapperObj.img = fileObj.Thumbnail_URL__c;
												
												if (fileObj.Is_Title_Image__c == true) {
													commentWrapObj.link.imgTHUMB720BY480URL =  fileObj.Thumbnail_URL__c;
												}
		
											}
		
											commentWrapObj.link.listOfTopAlbumImages.add(imagesWrapperObj);
												
										}											
									
									} else {
										commentWrapObj.link.imageUrl = Utility.getFileDownloadURL(listOfSimpplrContent[0].File_Simpplr_Content__r[0].Content_Version__c);
										commentWrapObj.link.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + 
												ServiceConstants.FILE_CONNECT_API_SUB_URL +
												listOfSimpplrContent[0].File_Simpplr_Content__r[0].Content_Document__c + 
												'/rendition?type=THUMB720BY480';
									}
									
								}
								
							}
							
							String siteImageUrl = '';
							String imgThumbnail = '';
							Boolean isSitePrivate = false;
							Boolean isSiteUnlisted = false;
							
							if (listOfSimpplrContent[0].Site__r.Chatter_Group_Id__c != null) {
								siteImageUrl =  String.isBlank(listOfSimpplrContent[0].Site__r.Title_Content_Version__c) ? 
										null: Utility.getFileDownloadURLFor720By480(listOfSimpplrContent[0].Site__r.Title_Content_Version__c);
								imgThumbnail =  String.isBlank(listOfSimpplrContent[0].Site__r.Title_Content_Version__c) ? 
										null: Utility.getFileDownloadURLFor120BY90(listOfSimpplrContent[0].Site__r.Title_Content_Version__c);
								
								if ('public'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)) {
									isSitePrivate = false;
									
								} else if ('private'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)) {
									isSitePrivate = true;
		
								} else if ('unlisted'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)) {
									isSiteUnlisted = true;
								}
								
							}
							
							commentWrapObj.link.authoredBy =  new PeopleLiteWrapper();
							commentWrapObj.link.authoredBy.id = listOfSimpplrContent[0].Primary_Author__c;
							commentWrapObj.link.authoredBy.name = listOfSimpplrContent[0].Primary_Author__r.Full_Name__c;
							commentWrapObj.link.authoredBy.img = listOfSimpplrContent[0].Primary_Author__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : listOfSimpplrContent[0].Primary_Author__r.User__r.SmallPhotoUrl;
							String profileLinkUrl = PageContext.getPageURL(Pages.app) + '?u=/people/' + listOfSimpplrContent[0].Primary_Author__c;
							commentWrapObj.link.authoredBy.url = profileLinkUrl;
							
							if (String.isNotBlank(listOfSimpplrContent[0].Site__c)) {
								commentWrapObj.link.site =  new SiteLiteWrapper();
								commentWrapObj.link.site.siteId =  listOfSimpplrContent[0].Site__c;
								commentWrapObj.link.site.name = listOfSimpplrContent[0].Site__r.Name;
								commentWrapObj.link.site.isActivated = listOfSimpplrContent[0].Site__r.Is_Active__c;
								commentWrapObj.link.site.img = siteImageUrl; 
								commentWrapObj.link.site.imgThumbnail = imgThumbnail;
								commentWrapObj.link.site.isPrivate = isSitePrivate;
								commentWrapObj.link.site.isMember = UserContext.chatterGroupsIFollowIdSet.contains(
									listOfSimpplrContent[0].Site__r.Chatter_Group_Id__c);
								commentWrapObj.link.site.access = listOfSimpplrContent[0].Site__r.Site_Type__c.toLowerCase(); 
								commentWrapObj.link.site.isListed = !isSiteUnlisted;
								String sitelinkUrl = PageContext.getPageURL(Pages.app) + '?u=/site/' + 
										listOfSimpplrContent[0].Site__c + '/' + listOfSimpplrContent[0].Site__r.Landing_Page__c;
										commentWrapObj.link.site.url = sitelinkUrl;
							}
							
							String dateStringValue = String.valueOf(listOfSimpplrContent[0].CreatedDate);
							
							if (String.isNotBlank(dateStringValue)) { 
								DateTime DateTimeValue = listOfSimpplrContent[0].CreatedDate;
								commentWrapObj.link.createdAt = DateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
							}
							
							commentWrapObj.link.type = listOfSimpplrContent[0].Type__c.toLowerCase();
							commentWrapObj.link.videoCount = Integer.valueof(listOfSimpplrContent[0].Album_Video_Count__c);
							commentWrapObj.link.isOpenToSubmissions  = listOfSimpplrContent[0].Album_Allow_All_to_Upload__c;
							commentWrapObj.link.imageCount = Integer.valueof(listOfSimpplrContent[0].Album_Image_Count__c);
							commentWrapObj.link.isPublished = listOfSimpplrContent[0].Is_Published__c;	
						}
						
					} else {
						Map<String, Object> soqlParamMap = new Map<String, Object>();
						soqlParamMap.put('soqlParam1', simpAlbumFileId);
						String filesQuery = 'SELECT Id, Simpplr_Content__c, Is_Title_Image__c,'+
								' Simpplr_Content__r.Site__r.Name, Simpplr_Content__r.Site__r.Landing_Page__c, '+
								' Simpplr_Content__r.Site__r.Id, Simpplr_Content__r.Site__r.Title_Content_Version__c,'+
								' Simpplr_Content__r.Site__r.Title_Content_Document__c,'+
								' Simpplr_Content__r.Site__r.Site_Type__c, Simpplr_Content__r.Site__r.Is_Active__c, '+
								' Simpplr_Content__r.Site__c, Author__r.Full_Name__c, Author__c, CreatedById, '+
								' Simpplr_Content__r.Title__c, Simpplr_Content__r.Is_Published__c, '+
								' Simpplr_Content__r.Site__r.Chatter_Group_Id__c, Simpplr_Content__r.Is_Must_read__c,'+
								' Author__r.User__r.SmallPhotoUrl, CreatedDate, Simpplr_Content__r.Type__c, '+
								' Simpplr_Content__r.Display_Excerpt__c, Thumbnail_URL__c, Content_Version__c, '+
								' Content_Document__c, MIME_Type__c, External_Id__c, Url__c, '+
								' Simpplr_Content__r.Album_Video_Count__c, Simpplr_Content__r.Album_Allow_All_to_Upload__c, '+
								' Simpplr_Content__r.Album_Image_Count__c, Is_Deleted__c  '+
								' FROM File__c '+
								' WHERE Id=:soqlParam1 And Simpplr_Content__r.is_Deleted__c=false';	
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						List<File__c> listOfSimpplrAlbumFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
						if (!listOfSimpplrAlbumFile.isEmpty()) { 
							
							commentWrapObj.link.id = listOfSimpplrAlbumFile[0].Simpplr_Content__c;
							commentWrapObj.link.albumMediaId = listOfSimpplrAlbumFile[0].Id;
							commentWrapObj.link.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + 
									listOfSimpplrAlbumFile[0].Simpplr_Content__r.site__c + '/album/' + 
									listOfSimpplrAlbumFile[0].Simpplr_Content__c+'&origin=feed';   
							commentWrapObj.link.isAvailable = listOfSimpplrAlbumFile[0].Is_Deleted__c ? false : true;
									
							if (listOfSimpplrAlbumFile[0].MIME_Type__c == 'image') {
								commentWrapObj.link.downloadUrl = Utility.getFileDownloadURL(listOfSimpplrAlbumFile[0].Content_Version__c);
							
							} else if (listOfSimpplrAlbumFile[0].MIME_Type__c == 'video') {
								commentWrapObj.link.video = new LinkWrapper.VideoWrapper();
								commentWrapObj.link.video.Id = 	listOfSimpplrAlbumFile[0].External_Id__c;
								
								if (listOfSimpplrAlbumFile[0].Url__c.contains('://youtu.be/') || 
										listOfSimpplrAlbumFile[0].Url__c.contains('.youtube.com/watch')) {
											commentWrapObj.link.video.provider = 'youtube';
									
								} else if (listOfSimpplrAlbumFile[0].Url__c.contains('://embed.vidyard.com/share')) { 
									commentWrapObj.link.video.provider = 'vidyard';
									
								} else if (listOfSimpplrAlbumFile[0].Url__c.contains('https://vimeo.com/')) {
									commentWrapObj.link.video.provider = 'vimeo';
									
								} else if (listOfSimpplrAlbumFile[0].Url__c.contains('wistia.')) {
									commentWrapObj.link.video.provider = 'wistia';
								
								} else if (listOfSimpplrAlbumFile[0].Url__c.containsIgnoreCase('vbrick.com')) {
									commentWrapObj.link.video.provider = 'vbrick';
									
								}
																
							}
		
							commentWrapObj.link.description = String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Display_Excerpt__c)?
									'': listOfSimpplrAlbumFile[0].Simpplr_Content__r.Display_Excerpt__c.unescapeHtml4();
									commentWrapObj.link.title = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Title__c;
							
									commentWrapObj.link.isMustRead = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Is_Must_read__c;
								
							if (listOfSimpplrAlbumFile[0].Simpplr_Content__r.Is_Published__c) {						
								commentWrapObj.link.imageUrl = listOfSimpplrAlbumFile[0].Thumbnail_URL__c;
		
								if (String.isNotBlank(listOfSimpplrAlbumFile[0].Content_Document__c)) {
									
									if (listOfSimpplrAlbumFile[0].Is_Title_Image__c == true) {
										commentWrapObj.link.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + 
											ServiceConstants.FILE_CONNECT_API_SUB_URL + 
											listOfSimpplrAlbumFile[0].Content_Document__c + 
											'/rendition?type=THUMB720BY480';
									}
		
								} else if (listOfSimpplrAlbumFile[0].Is_Title_Image__c == true) {
									commentWrapObj.link.imgTHUMB720BY480URL = listOfSimpplrAlbumFile[0].Thumbnail_URL__c;
								}
		
							}
							
							String siteImageUrl = '';
							String imgContentDocumentId = '';
							String imgThumbnail = '';
							Boolean isSitePrivate = false;
							Boolean isSiteUnlisted = false;
							
							if (listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c != null) {
								imgContentDocumentId = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Document__c;
								siteImageUrl =  String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c)? 
										null : Utility.getFileDownloadURLFor720By480(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c);
								imgThumbnail =  String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c) ? 
										null : Utility.getFileDownloadURLFor120BY90(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c);
								
								if ('public'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)) {
									isSitePrivate = false;
									
								} else if ('private'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)) {
									isSitePrivate = true;
								
								} else if ('unlisted'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)) {
									isSiteUnlisted = true;
								}
								
							}
							
							commentWrapObj.link.authoredBy =  new PeopleLiteWrapper();
							commentWrapObj.link.authoredBy.id = listOfSimpplrAlbumFile[0].Author__c;
							commentWrapObj.link.authoredBy.sfUserId = listOfSimpplrAlbumFile[0].Author__c;
							commentWrapObj.link.authoredBy.name = listOfSimpplrAlbumFile[0].Author__r.Full_Name__c; 
							commentWrapObj.link.authoredBy.img = Utility.getProfilePhotoURL(listOfSimpplrAlbumFile[0].Author__r.User__r.SmallPhotoUrl);
							String profileLinkUrl = PageContext.getPageURL(Pages.app) + '?u=/people/' + 
									listOfSimpplrAlbumFile[0].Author__c;
							commentWrapObj.link.authoredBy.url = profileLinkUrl;
							
							if (String.isNotBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c)) {
								commentWrapObj.link.site =  new SiteLiteWrapper();
								commentWrapObj.link.site.siteId =  listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c;
								commentWrapObj.link.site.name = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Name;
								commentWrapObj.link.site.isActivated = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Is_Active__c;
								commentWrapObj.link.site.img = siteImageUrl;
								commentWrapObj.link.site.imgContentDocumentId = imgContentDocumentId;
								commentWrapObj.link.site.imgThumbnail = imgThumbnail;
								commentWrapObj.link.site.isPrivate = isSitePrivate;
								commentWrapObj.link.site.isMember = UserContext.chatterGroupsIFollowIdSet.contains(
									listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c);
								commentWrapObj.link.site.access = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c.toLowerCase(); 
								commentWrapObj.link.site.isListed = !isSiteUnlisted;
								String sitelinkUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c + '/' + listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Landing_Page__c;
								commentWrapObj.link.site.url = sitelinkUrl;
							}
							
							String dateStringValue = String.valueOf(listOfSimpplrAlbumFile[0].CreatedDate);
							
							if (String.isNotBlank(dateStringValue)) { 
								commentWrapObj.link.createdAt = Utility.dateTimeToMomentJSDateTime(listOfSimpplrAlbumFile[0].CreatedDate);
							}
							
							commentWrapObj.link.type = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Type__c.toLowerCase();
							commentWrapObj.link.videoCount = Integer.valueof(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Album_Video_Count__c);
							commentWrapObj.link.isOpenToSubmissions  = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Album_Allow_All_to_Upload__c;
							commentWrapObj.link.imageCount = Integer.valueof(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Album_Image_Count__c);
							commentWrapObj.link.isPublished = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Is_Published__c;						        	
									
						}														
							
					}
						
				} else if (String.isNotBlank(simpFileId)) {
					String queryStr = 'SELECT Title, Id, Description, CreatedBy.SmallPhotoUrl, CreatedBy.Name, CreatedBy.Id,'
							+ ' CreatedById, CreatedDate, ContentSize,'
							+ ' LatestPublishedVersionId, FileExtension, FileType,'
							+ ' (Select Id, IsLatest,FileExtension From ContentVersions WHERE IsLatest= true)' 
							+ ' FROM ContentDocument WHERE Id=:simpFileId';
		
					if (SimpplrContext.isCommunitiesEnabled) {
						queryStr += ' AND LatestPublishedVersion.NetworkId = null';
					}
					
					List<ContentDocument> listOfContentDoc = Database.query(queryStr);
		
					if (!listOfContentDoc.isEmpty()) {
						commentWrapObj.postType = 'file';						
						String dateStringValue = String.valueOf(listOfContentDoc[0].CreatedDate);					        
						commentWrapObj.listOfFiles = new List<RecentCommentsWrapper.FileWrapper>();							
						RecentCommentsWrapper.FileWrapper fileWrapObj = new RecentCommentsWrapper.FileWrapper();
						fileWrapObj.isAccessible = true;
						
						if (listOfContentDoc[0].Id == null) {
							fileWrapObj.isAccessible = false;
							commentWrapObj.canShare = false;
						}
						
						fileWrapObj.id = listOfContentDoc[0].id;
						fileWrapObj.name = listOfContentDoc[0].title;
						Map<String, String> arg = new Map<String, String>();
						arg.put('fileId', listOfContentDoc[0].id);			                
						String linkUrl = PageContext.getPageURL(Pages.FileDetail, arg);
						fileWrapObj.url = linkUrl;				
						
						if (listOfContentDoc[0].ContentSize != null) {
							fileWrapObj.size = String.valueOf(listOfContentDoc[0].ContentSize);
						} 
						
						if ((listOfContentDoc[0].FileExtension == 'jpg') || 
								(listOfContentDoc[0].FileExtension == 'png') || 
								(listOfContentDoc[0].FileExtension == 'jpeg')){		
							fileWrapObj.thumbnail  = Utility.getFileDownloadURLFor720By480(listOfContentDoc[0].LatestPublishedVersionId);
							fileWrapObj.isImage = true;
						
						} else if (listOfContentDoc[0].FileExtension == 'gif') {
							fileWrapObj.thumbnail  = Utility.getFileDownloadURL(listOfContentDoc[0].LatestPublishedVersionId);
							fileWrapObj.isImage = true;		    				
						
						} else if((listOfContentDoc[0].FileExtension == 'doc')|| (listOfContentDoc[0].FileExtension == 'docx') ||
								(listOfContentDoc[0].FileExtension == 'txt')|| (listOfContentDoc[0].FileExtension == 'pdf') ||
								(listOfContentDoc[0].FileExtension == 'ppt')|| (listOfContentDoc[0].FileExtension == 'pptx')){
							fileWrapObj.thumbnail  = Utility.getFileDownloadURLFor240BY180(listOfContentDoc[0].LatestPublishedVersionId);
							fileWrapObj.isImage = false;				    					
						}
						
						fileWrapObj.downloadURL = Utility.getFileDownloadURL(listOfContentDoc[0].LatestPublishedVersionId);				
						String fileExtension = listOfContentDoc[0].FileExtension;				
						fileWrapObj.isDownloadableOniOS = Utility.isDownloadableOniOS(fileExtension, null);		
						fileWrapObj.type = Utility.getFileType(listOfContentDoc[0].fileType);		
						commentWrapObj.listOfFiles.add(fileWrapObj);	        
						
					} else {
						commentWrapObj.postType = 'link';
						commentWrapObj.link = new LinkWrapper();
						commentWrapObj.link.url = urlToProcess;
						
					}
				
				}
					
			} else if (isCampaignLink) {
				logger.logDebug('isCampaignLink');
				PageReference campaignURL = new PageReference(urlToprocess);
				String campaignId = campaignURL.getParameters().get('campaignId');
				CampaignService campaignServiceObj = new CampaignService();
				
				commentWrapObj.postType = 'campaign';
				commentWrapObj.campaign = campaignServiceObj.getCampaignForFeed(campaignId);	
					
			} 
			
		}
		
		
		if (commentObjArg.capabilities.content != null) { 
			commentWrapObj.listOfFiles = new List<RecentCommentsWrapper.FileWrapper> ();
			RecentCommentsWrapper.FileWrapper fileWrapObj = new RecentCommentsWrapper.FileWrapper();
			fileWrapObj.id = commentObjArg.capabilities.content.id;				
			fileWrapObj.name = commentObjArg.capabilities.content.title;
			fileWrapObj.size = commentObjArg.capabilities.content.fileSize;
			fileWrapObj.fileExtension = commentObjArg.capabilities.content.fileExtension;				
			fileWrapObj.isImage = false;

			if ((commentObjArg.capabilities.content.fileExtension == 'jpg') || 
					(commentObjArg.capabilities.content.fileExtension == 'png') || 
					(commentObjArg.capabilities.content.fileExtension == 'jpeg')) {		
				fileWrapObj.thumbnail  = Utility.getFileDownloadURLFor720By480(commentObjArg.capabilities.content.versionId);
				fileWrapObj.isImage = true;
			
			} else if (commentObjArg.capabilities.content.fileExtension == 'gif') {
				fileWrapObj.thumbnail  = Utility.getFileDownloadURL(commentObjArg.capabilities.content.versionId);
				fileWrapObj.isImage = true;	
										
			} else if ((commentObjArg.capabilities.content.fileExtension == 'doc')|| 
					(commentObjArg.capabilities.content.fileExtension == 'docx') ||
					(commentObjArg.capabilities.content.fileExtension == 'txt')|| 
					(commentObjArg.capabilities.content.fileExtension == 'pdf') ||
					(commentObjArg.capabilities.content.fileExtension == 'ppt')|| 
					(commentObjArg.capabilities.content.fileExtension == 'pptx')) {
				fileWrapObj.thumbnail  = Utility.getFileDownloadURLFor240BY180(commentObjArg.capabilities.content.versionId);
				fileWrapObj.isImage = false;				    					
			}					
			
			fileWrapObj.downloadURL = Utility.getFileDownloadURL(commentObjArg.capabilities.content.versionId);//commentObjArg.capabilities.content.downloadUrl;
			fileWrapObj.isAccessible = true;					
			
			if (commentObjArg.capabilities.content.id == null) {
				fileWrapObj.isAccessible = false;
			}
						
			Map<String, String> args = new Map<String, String>();
			args.put('fileId', commentObjArg.capabilities.content.id);
			String linkUrl = PageContext.getPageURL(Pages.FileDetail, args);
			fileWrapObj.url = linkUrl;				
			String fileExtension = commentObjArg.capabilities.content.fileExtension;
			fileWrapObj.isDownloadableOniOS = Utility.isDownloadableOniOS(fileExtension, null);		
			fileWrapObj.type = Utility.getFileType(commentObjArg.capabilities.content.fileType);
			commentWrapObj.listOfFiles.add(fileWrapObj);
		} 
		
		List<ConnectApi.MessageSegment> messageSegments = commentObjArg.body.messageSegments;
		String tempProcessedStr = processFromSegments(messageSegments);
		
		/*External attached file processing starts*/
		if (tempProcessedStr.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) >= 0) { // User posted text is seprated from google file info added by us using \u2063\uFEFF\u200b\uFEFF\u2063
			String externalFileStr =  tempProcessedStr.substring(tempProcessedStr.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR) +
					8, tempProcessedStr.length());
			tempProcessedStr = tempProcessedStr.substring(0, tempProcessedStr.indexOf(ServiceConstants.FEED_EXT_FILE_SEPRATOR));
			List<String> listOfExtFile = new List<String>();
			listOfExtFile = externalFileStr.split('\n'); // Files are seprated by newline 
			
			if (commentObjArg.capabilities.content == null) { 
				commentWrapObj.listOfFiles = new List<RecentCommentsWrapper.FileWrapper> ();
			}
			
			if (!listOfExtFile.isEmpty()) {
				List<String> listOfExtFileForCommentMap = new List<String>();
		
				for (String singleFileStr: listOfExtFile) {
					String urlTempStr = singleFileStr.trim();
							
					if (urlTempStr.indexOf('>') > 0) {
						urlTempStr = urlTempStr.subString((urlTempStr.indexOf('>') + 1), 
								urlTempStr.indexOf('</a>'));
					}
					
					RecentCommentsWrapper.FileWrapper  fileWrapObj = new RecentCommentsWrapper.FileWrapper();
					fileWrapObj.url = urlTempStr;
					PageReference extFileSFLink = new PageReference(urlTempStr);
					String extFileId = extFileSFLink.getParameters().get('fileId'); 
					String videoEntityId = extFileSFLink.getParameters().get('entry_id');
					String provider = extFileSFLink.getParameters().get('provider');										
					fileWrapObj.id = String.isNotBlank(videoEntityId) ? videoEntityId : extFileId;
					if(SimpplrContext.isNativeVideo && String.isNotBlank(fileWrapObj.id) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)) {
						fileWrapObj.url =  PageContext.getPageURL(Pages.app) + '?u=/video/' + fileWrapObj.id;
						fileWrapObj.thumbnail = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileWrapObj.id +'/width/550/height/480';
						fileWrapObj.isVideo = true;
						fileWrapObj.videoStatus = 1;
						fileWrapObj.provider = 'native_video';
					}
					commentWrapObj.listOfFiles.add(fileWrapObj);
					listOfExtFileForCommentMap.add(fileWrapObj.url);
				}
				
				if (isCommentPageContext != null && isCommentPageContext) { // If fetching feedComment page 
					mapOfCommentIdWithListOfIdOfExtFile.put(commentWrapObj.id, listOfExtFileForCommentMap); 
				
				} else { // if new comment is added with gd box file 
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', commentWrapObj.id);
					String filesQuery =  'SELECT id, title__C, Size__c, url__c, '+
							' Feed_Comment__c, External_Id__c, MIME_Type__c, Repository__c,Video_Status__c,'+
							' Is_Deleted__c, Sp_Instance_Id__c '+
							' FROM file__c '+
							' WHERE Feed_Comment__c =:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<File__c> listOfExtFilesAttached = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
					if (!listOfExtFilesAttached.isEmpty() && 
							!commentWrapObj.listOfFiles.isEmpty()) {
								
						for (RecentCommentsWrapper.FileWrapper fileWrapObj: commentWrapObj.listOfFiles) {
							
							for (File__c fileObj: listOfExtFilesAttached) {
								
								if (fileObj.External_Id__c == fileWrapObj.id) {
									fileWrapObj.title = fileObj.title__C;
									fileWrapObj.id = fileObj.External_Id__c;
									fileWrapObj.fileId = fileObj.id;
									fileWrapObj.size = String.valueOf(fileObj.Size__c);
									if (fileObj.Repository__c == 'native_video' && !SimpplrContext.isNativeVideo) {
										fileWrapObj.isAccessible = false;
									} else {
										fileWrapObj.isAccessible = !fileObj.is_Deleted__c;
									}
                                    fileWrapObj.videoStatus = 1; 
                                
                                    if (fileObj.Video_Status__c != null) {
                                        fileWrapObj.videoStatus = Integer.valueOf(fileObj.Video_Status__c);
                                    }

									String tempFileName = fileWrapObj.title;
									
									if (String.isNotBlank(tempFileName) && 
											tempFileName.indexOf('.') > 0 && 
											(tempFileName.indexOf('.') + 1 <= tempFileName.length())) {
										fileWrapObj.fileExtension = tempFileName.substring(tempFileName.lastIndexOf('.') + 1,
											tempFileName.length());

									} else {
										fileWrapObj.fileExtension = fileObj.MIME_Type__c;
									}
									
									fileWrapObj.type = fileObj.MIME_Type__c;
									fileWrapObj.context = fileObj.Repository__c;
									fileWrapObj.provider = fileObj.Repository__c;

									if(SimpplrContext.isNativeVideo && fileWrapObj.provider == 'native_video') {
										fileWrapObj.thumbnail = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileWrapObj.id +'/width/550/height/480';
										fileWrapObj.isVideo = true;
									}
									if ((fileWrapObj.provider == 'onedrive' || fileWrapObj.provider == 'sharepoint') && 
										String.isNotBlank(fileWrapObj.url)) {
											fileWrapObj.rootDirectory = Utility.getParamValueFromUrl(fileWrapObj.url, 
											'rootDirectory');
									}
									if(fileWrapObj.provider == 'sharepoint'){
										fileWrapObj.spInstanceId = fileObj.Sp_Instance_Id__c;
									}
									break;
								}
								
							}
							
						}
						
					}
						
				}
				
			}
			
		}
		
		commentWrapObj.listOfMentions = new List<MentionWrapper>();
		commentWrapObj.listOfMentions.addAll(listOfMentionUserGlobal);
		commentWrapObj.listOfLinks = new List<String>();
		commentWrapObj.listOfLinks.addAll(listOfLinksGlobal);
		commentWrapObj.listOfTopics = new List<TopicWrapper>();
		commentWrapObj.listOfTopics.addAll(listOfTopicGlobal);
		commentWrapObj.body = tempProcessedStr;
		try{
			currIdx = 0;
			commentWrapObj.bodyJson = FeedDataAdapter.processFromSegmentsV1(commentObjArg.body.messageSegments);
		}catch(Exception ex){
			logger.logDebug(ex);
		}
		
		commentWrapObj.authoredBy = new PeopleLiteWrapper();
		commentWrapObj.authoredBy.name = !mapUserIdToPeople.isEmpty() && mapUserIdToPeople.containsKey(commentObjArg.user.Id) ? mapUserIdToPeople.get(String.Valueof(commentObjArg.user.Id)).Full_Name__c : commentObjArg.user.Name;
		commentWrapObj.authoredBy.userId = commentObjArg.user.Id;
		commentWrapObj.authoredBy.sfUserId = commentObjArg.user.Id;
		commentWrapObj.authoredBy.department = '';
		commentWrapObj.authoredBy.img = Utility.getProfilePhotoURL(commentObjArg.user.photo.smallPhotoUrl);
		commentWrapObj.createdAt = Utility.dateTimeToMomentJSDateTime(commentObjArg.createdDate);
		commentWrapObj.canDelete = !commentObjArg.isDeleteRestricted;
		
		if (commentObjArg.likes != null) {
			commentWrapObj.likeCount = commentObjArg.likes.total;
			
			if (commentObjArg.myLike != null) {
				commentWrapObj.likeId = commentObjArg.myLike.Id;
				commentWrapObj.isliked = true;
				
			} else {
				commentWrapObj.likeId = null;
				commentWrapObj.isliked = false;
			}
			
		} else {
			commentWrapObj.likeCount = 0;
			commentWrapObj.likeId = null;
			commentWrapObj.isliked = false;
		}
		
		if (commentObjArg.capabilities.edit != null) {
			
			if (commentObjArg.capabilities.edit.isEditRestricted) {
				commentWrapObj.canEdit = false;
			
			} else {
				commentWrapObj.canEdit = true;
			}
			
		} else {
			commentWrapObj.canEdit = false;
		}  
		
		String linkUrl = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + commentObjArg.user.Id;
		commentWrapObj.authoredBy.Url = linkUrl;
		return commentWrapObj;
	}

	private static Boolean isFeedTypeSharable (String type) {
		Boolean isSharable = false;
		if('TextPost'.equalsIgnoreCase(type) || 'ContentPost'.equalsIgnoreCase(type) || 'LinkPost'.equalsIgnoreCase(type)){
			isSharable = true;
		}
		return isSharable;
	}
	

	@TestVisible private static Map<String, Object>  addMarks(Map<String, Object>  segmentJSON ){
		if(marks.size()>0){
			List<Map<String, Object>> marksJSONList = new List<Map<String, Object>>();
			for(String mark: marks){
				Map<String, Object> marksJSON = new Map<String, Object> ();
				marksJSON.put('type',mark);
				marksJSONList.add(marksJSON);
			}
			segmentJSON.put('marks', marksJSONList);
		}
		return segmentJSON;
	}

	
	@TestVisible private static Map<String, Object> processTextSegment(ConnectApi.MessageSegment segment){
		Map<String, Object>  segmentJSON = new Map<String, Object> ();
		segmentJSON.put('type', 'text');
		segmentJSON.put('text', segment.text);
		segmentJSON = addMarks(segmentJSON);
		return segmentJSON;
	}

	@TestVisible private static Map<String, Object> processLinkSegment(ConnectApi.MessageSegment segment){
		ConnectApi.LinkSegment linkSegment = (ConnectApi.LinkSegment) segment;
		Map<String, Object>  segmentJSON = new Map<String, Object> ();
		segmentJSON.put('type', 'text');
		segmentJSON.put('text', linkSegment.text);
		List<Map<String, Object>> marksJSONList = new List<Map<String, Object>>();
		if(marks.size()>0){
			for(String mark: marks){
				Map<String, Object> marksJSON = new Map<String, Object> ();
				marksJSON.put('type',mark);
				marksJSONList.add(marksJSON);
			}
		}
		Map<String, Object> marksJSON = new Map<String, Object> ();
		marksJSON.put('type', 'link');
		Map<String, Object> attrJSON = new Map<String, Object> ();
		attrJSON.put('href',linkSegment.url);
		marksJSON.put('attrs',attrJSON);
		marksJSONList.add(marksJSON);
		segmentJSON.put('marks', marksJSONList);
		return segmentJSON;
	}

	@TestVisible private static Map<String, Object> processMentionSegment(ConnectApi.MessageSegment segment){
		ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;
		Map<String, Object>  segmentJSON = new Map<String, Object> ();
		segmentJSON.put('type', 'UserAndSiteMention');
		Map<String, Object> attrJSON = new Map<String, Object>();
		Map<String, Object> type = new Map<String, Object>();
		String mentionType = mentionSegment.record.type.toLowerCase() == 'user' ? 'user' : 'site';
		attrJSON.put('type', mentionType);
		attrJSON.put('label', mentionSegment.name);
		if(mentionType == 'user') {
			attrJSON.put('id', peopleIdByUserIdMap.get(mentionSegment.record.id));
		}else{
			attrJSON.put('id', siteIdByCollaborationGrpIdMap.get(mentionSegment.record.id));
		}

		segmentJSON.put('attrs', attrJSON);
		segmentJSON = addMarks(segmentJSON);
		return segmentJSON;
	}

	@TestVisible private static Map<String, Object>  processHashTagSegment(ConnectApi.MessageSegment segment){
		ConnectApi.HashtagSegment hashtagSegment = (ConnectApi.HashtagSegment) segment;
		Map<String, Object>  segmentJSON = new Map<String, Object> ();
		segmentJSON.put('type', 'TopicMention');
		Map<String, Object> attrJSON = new Map<String, Object>();
		attrJSON.put('id', topicIdsByName.get(hashtagSegment.tag) );
		attrJSON.put('label', hashtagSegment.tag );
		attrJSON.put('type', 'topic' );
		segmentJSON.put('attrs', attrJSON);
		segmentJSON = addMarks(segmentJSON);
		return segmentJSON;
	}

	@TestVisible private static void processMarkupBeginSegment(ConnectApi.MessageSegment segment){
		String segmentHtmlTag = ((ConnectApi.MarkupBeginSegment)segment).htmlTag;
		if(segmentHtmlTag == 'b'){
			marks.add('bold');
		}else if(segmentHtmlTag == 'i'){
			marks.add('italic');
		}else if(segmentHtmlTag == 'u'){
			marks.add('underline');
		}else if(segmentHtmlTag == 's'){
			marks.add('strike');
		}
	}

	@TestVisible private static void processMarkupEndSegment(ConnectApi.MessageSegment segment){
		String segmentHtmlTag = ((ConnectApi.MarkupEndSegment)segment).htmlTag;
		if(segmentHtmlTag == 'b'){
			marks.remove('bold');
		}else if(segmentHtmlTag == 'i'){
			marks.remove('italic');
		}else if(segmentHtmlTag == 'u'){
			marks.remove('underline');
		}else if(segmentHtmlTag == 's'){
			marks.remove('strike');
		}
	}

	@TestVisible private static List<Map<String, Object>> paragraphJSONHelper(ConnectApi.MessageSegment[] messageSegments) {
		List<Map<String, Object>>  segmentJSONList = new List<Map<String, Object>> ();
		for (Integer i=0;i<messageSegments.size();i++) {
			ConnectApi.MessageSegment segment = messageSegments[i];
			if(segment instanceof ConnectApi.TextSegment){
				segmentJSONList.add(processTextSegment(segment));
			}else if(segment instanceof ConnectApi.LinkSegment){
				segmentJSONList.add(processLinkSegment(segment));
			}else if(segment instanceof ConnectApi.MentionSegment){
				segmentJSONList.add(processMentionSegment(segment));
			}else if(segment instanceof ConnectApi.HashtagSegment){
				segmentJSONList.add(processHashTagSegment(segment));
			}else if(segment instanceof ConnectApi.MarkupBeginSegment){
				processMarkupBeginSegment(segment);
			}else if(segment instanceof ConnectApi.MarkupEndSegment){
				processMarkupEndSegment(segment);
			}
		}
		return segmentJSONList;
	}

	@TestVisible private static void populateTopicIdsByName(List<String> listOfTag){
		List<Topic> listOfTopic = new List<Topic>();
		String baseQuery= 'select id, name from Topic where name =:listOfTag';
		if (SimpplrContext.isCommunitiesEnabled) {
			baseQuery = baseQuery+' AND NetworkId = null';
		}
		listOfTopic = Database.query(baseQuery);
		for (Topic t:listOfTopic) {
			topicIdsByName.put(t.name.toLowerCase(), t.id);
		}
	}

	@TestVisible private static Map<String, Object> getParagraphJSON(List<ConnectApi.MessageSegment> messageSegments){
		Map<String, Object> paragraphJSON = new Map<String, Object>();
		paragraphJSON.put('type', 'paragraph');
		List<ConnectApi.MessageSegment>  nestedSegments = new List<ConnectApi.MessageSegment> ();
		Boolean keep = true;
		while(currIdx<messageSegments.size()  && keep){
			currIdx++;
			ConnectApi.MessageSegment segment = messageSegments[currIdx];
			nestedSegments.add(segment);
			if(segment instanceof ConnectApi.MarkupEndSegment && (((ConnectApi.MarkupEndSegment)segment).htmlTag == 'p' )){
					keep = false;
			} 
		}
		if(nestedSegments.size()>0){
			nestedSegments.remove(nestedSegments.size()-1);
		}
		paragraphJSON.put('content', paragraphJSONHelper(nestedSegments));
		return paragraphJSON;
	}

	@TestVisible private static Map<String, Object> getListJSON(List<ConnectApi.MessageSegment> messageSegments, String listType){
		Map<String, Object> bulletListJSON = new Map<String, Object>();
		String type = listType=='ol' ? 'orderedList' : 'bulletList';
		List<Map<String, Object>> allListItems = new  List<Map<String, Object>> ();
		Boolean keep = true;

		bulletListJSON.put('type', type);
		while(currIdx<messageSegments.size()  && keep){
			currIdx++;
			ConnectApi.MessageSegment segment = messageSegments[currIdx];
			if(segment instanceof ConnectApi.MarkupEndSegment && 
				(((ConnectApi.MarkupEndSegment)segment).htmlTag == 'ul' || ((ConnectApi.MarkupEndSegment)segment).htmlTag == 'ol' )){
					keep = false;
				
			} else if(segment instanceof ConnectApi.MarkupBeginSegment &&  
				(((ConnectApi.MarkupBeginSegment)segment).htmlTag == 'li' )){
					allListItems.add(getListItemJSON(messageSegments));
			}
		}
		bulletListJSON.put('content', allListItems);
		return bulletListJSON;
	}

	@TestVisible private static Map<String, Object> getListItemJSON(List<ConnectApi.MessageSegment> messageSegments){
		Map<String, Object> listItemJSON = new Map<String, Object>();
		listItemJSON.put('type', 'listItem');
		List<Map<String, Object>> allListItems = new List<Map<String, Object>>();
		Boolean keep = true;
		while(currIdx<messageSegments.size()  && keep){
			currIdx++;
			ConnectApi.MessageSegment segment = messageSegments[currIdx];
			if(segment instanceof ConnectApi.MarkupEndSegment && 
				(((ConnectApi.MarkupEndSegment)segment).htmlTag == 'li' )){
					keep = false;
			} else if(segment instanceof ConnectApi.MarkupBeginSegment &&
					(((ConnectApi.MarkupBeginSegment)segment).htmlTag == 'p' )){
					allListItems.add(getParagraphJSON(messageSegments));
			}else if(segment instanceof ConnectApi.MarkupBeginSegment &&  
			(((ConnectApi.MarkupBeginSegment)segment).htmlTag == 'ul' || 
				((ConnectApi.MarkupBeginSegment)segment).htmlTag == 'ol')){
				allListItems.add(getListJSON(messageSegments, ((ConnectApi.MarkupBeginSegment)segment).htmlTag ));
			}
		}
		listItemJSON.put('content', allListItems);
		return listItemJSON;
	}

	@TestVisible private static void populateMentionsData(List<ConnectApi.MessageSegment> messageSegments){
		List<String> listOfTag = new List<String>();
		Set<Id> mentionedUserIds = new Set<Id>();
		Set<String> collaborationGrpIds = new Set<String>();

		for (ConnectApi.MessageSegment segment : messageSegments) {
			if(segment instanceof  ConnectApi.MentionSegment){
				ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;
				if(mentionSegment.record.type == 'user'){
					mentionedUserIds.add(mentionSegment.record.Id);
				}else{
					collaborationGrpIds.add(mentionSegment.record.Id);
				}
			}else if(segment instanceof ConnectApi.HashTagSegment){
				ConnectApi.HashTagSegment hashSegment = (ConnectApi.HashTagSegment) segment;
				listOfTag.add(hashSegment.tag);
			}
		}

		if(listOfTag.size()>0){
			populateTopicIdsByName(listOfTag);
		}
		if(mentionedUserIds.size()>0){
			PeopleDao peopleDaoObj = new PeopleDao();
			peopleIdByUserIdMap = peopleDaoObj.getPeopleIdByUserIdMap(mentionedUserIds);
		}
		if(collaborationGrpIds.size()>0){
			SiteDao siteDaoObj = new SiteDao();

			for (Simpplr_Site__c site : siteDaoObj.getColGrpIdToShowInSimpplrSitesMap(collaborationGrpIds).Values()) {
				siteIdByCollaborationGrpIdMap.put(site.chatter_Group_id__c , site.Id );
			}
		}
	}

	@TestVisible private static String processFromSegmentsV1(List<ConnectApi.MessageSegment> messageSegments) {
		Map<String, Object> tiptapJSON = new Map<String, Object>();
		List<Map<String, Object>> content = new List<Map<String, Object>>();

		populateMentionsData(messageSegments);
		
		for (;currIdx<messageSegments.size();currIdx++) {
			ConnectApi.MessageSegment segment = messageSegments[currIdx]; 
			if(segment instanceof ConnectApi.MarkupBeginSegment){
				String segmentHtmlTag = ((ConnectApi.MarkupBeginSegment)segment).htmlTag;
				if(segmentHtmlTag == 'p'){
					content.add(getParagraphJSON(messageSegments));
				}else if(segmentHtmlTag == 'ul' || segmentHtmlTag =='ol'){
					content.add(getListJSON(messageSegments, segmentHtmlTag));
				}
			}
		}
		tiptapJSON.put('type', 'doc');
		tiptapJSON.put('content', content);
		return JSON.serialize(tiptapJSON);
	}
	

    /**Process from segments**/
    private static String processFromSegments (List<ConnectApi.MessageSegment> messageSegments) {
    	listOfMentionUserGlobal = new List<MentionWrapper>();
		listOfLinksGlobal = new List<String>();
    	listOfTopicGlobal = new List<TopicWrapper>();
        String feedItemText = '';
		List<String> listOfTag = new List<String>();
		Map<String,id> mapOfTopicNameAndId = new Map<String,id>(); 
		Map<String, People__c> mapOfIdVsPeople = new Map<String, People__c>();
		Map<String, Simpplr_Content__c> mapOfIdVsSite = new Map<String, Simpplr_Content__c>();
		for (ConnectApi.MessageSegment segment : messageSegments) {
			
			if (segment instanceof ConnectApi.HashTagSegment) {
		    	ConnectApi.HashTagSegment hashSegment = (ConnectApi.HashTagSegment) segment;
		    	listOfTag.add(hashSegment.tag);
		 	}

		}
		
		if (!listOfTag.isEmpty()) {
			List<Topic> listOfTopic = new List<Topic>();
	        String BASE_QUERY= 'select id, name from Topic where name =:listOfTag';

	        if (SimpplrContext.isCommunitiesEnabled) {
	    		BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
	    	}

	    	listOfTopic = Database.query(BASE_QUERY);
        	
        	for (Topic t:listOfTopic) {
        		mapOfTopicNameAndId.put(t.name.toLowerCase(), t.id);
		        String topicUrl = PageContext.getPageURL(Pages.app) + '?u=/topic/' + t.id + '/feed';
        		listOfTopicGlobal.add(new TopicWrapper(t.id, t.name, topicUrl));
        	}
        	
		}

		//EDT-431
		for (ConnectApi.MessageSegment segment : messageSegments) {
        	MentionWrapper mentionObj = new MentionWrapper();

            if (segment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;
				
                String mentionId = mentionSegment.record.id;
                
                if (mentionId.startsWith('0F9')) {
	                mapOfIdVsSite.put(mentionId , null);
				}
				else if(mentionId.startsWith('005')) {
					mapOfIdVsPeople.put(mentionId , null);
				}
			}
		}
		//EDT-431

		for(Simpplr_Content__c siteObj : [select Site__r.Chatter_Group_Id__c, Site__c from Simpplr_Content__c where Site__r.Chatter_Group_Id__c IN: mapOfIdVsSite.keySet()]){
			mapOfIdVsSite.put(siteObj.Site__r.Chatter_Group_Id__c , siteObj);
		}
		for(People__c peopleObj : [select Id, User__c, Full_Name__c FROM People__c WHERE User__c IN: mapOfIdVsPeople.keySet()]){
			mapOfIdVsPeople.put(peopleObj.User__c , peopleObj);
		}
        
        for (ConnectApi.MessageSegment segment : messageSegments) {
        	MentionWrapper mentionObj = new MentionWrapper();

            if (segment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segment;

                String mentionId = mentionSegment.record.id;
                
                if (mentionId.startsWith('0F9')) {
	                Map<String, String> args = new Map<String, String>();
	                args.put('pageToRedirect', ServiceConstants.SITE_LANDING_PAGE_STRING);
	                args.put('chatterGroupId', mentionId);
	                String linkUrl = PageContext.getPageURL(Pages.PageRedirector, args);
	                String mentionSiteName = !mapUserIdToPeople.isEmpty() && mapUserIdToPeople.containsKey(mentionId) ? mapUserIdToPeople.get(mentionId).Full_Name__c : mentionSegment.name;
					mentionSiteName = FeedUtility.processNameToPreventXSS(mentionSiteName);
					//EDT-431
					string siteId = '';
					if(mapOfIdVsSite.get(mentionId) != null) siteId = mapOfIdVsSite.get(mentionId).Site__c;
					feedItemText += '<a data-type="site" data-id="'+siteId+'" data-label="'+mentionSiteName+'" data-mention="'+mentionId+'" href="' + linkUrl +'">@' + mentionSiteName + '</a>';		
	                mentionObj.Id = mentionId;
	                mentionObj.name = mentionSiteName;
	                mentionObj.type = 'Site';
	                mentionObj.url = linkUrl;
	                                	
                } else {
		            String linkUrl = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + mentionId;
		            String mentionUserName = !mapUserIdToPeople.isEmpty() && mapUserIdToPeople.containsKey(mentionId) ? mapUserIdToPeople.get(mentionId).Full_Name__c : mentionSegment.name;
		            mentionUserName = FeedUtility.processNameToPreventXSS(mentionUserName);
					//EDT-431
					string peopleIds = '';
					if(mapOfIdVsPeople.get(mentionId) != null) peopleIds = mapOfIdVsPeople.get(mentionId).Id;

	                //feedItemText += '<a data-mention="'+mentionId+'" href="' + linkUrl +'">@' + mentionUserName + '</a>';
					feedItemText += '<a data-type="user" data-id="'+peopleIds+'" data-label="'+mentionUserName+'" data-mention="'+mentionId+'" href="' + linkUrl +'">@' + mentionUserName + '</a>';     
					
	                mentionObj.Id = mentionId;
	                mentionObj.name = mentionUserName;
	                mentionObj.type = 'People';
	                mentionObj.url = linkUrl;
                }
                
                listOfMentionUserGlobal.add(mentionObj);
                                
            } else if (segment instanceof ConnectApi.HashTagSegment) {
            	ConnectApi.HashTagSegment hashSegment = (ConnectApi.HashTagSegment) segment;
                Map<String, String> args = new Map<String, String>();
                String topicIdFromMap = mapOfTopicNameAndId.get(hashSegment.tag.toLowerCase());
                
                if (topicIdFromMap == null && mapOfTopicNameToIdGlobal != null 
                		&& !mapOfTopicNameToIdGlobal.isEmpty()) {
                	String topicNameForProcessing = hashSegment.tag.replaceAll('\\s+', '');
                	topicNameForProcessing = topicNameForProcessing.toLowerCase();
                	topicIdFromMap = mapOfTopicNameToIdGlobal.get(topicNameForProcessing);
                }
                
                if (topicIdFromMap == null && !Test.isRunningTest()) {
                	ConnectApi.TopicPage topicPage = connectAPI.topics.getTopics(null, 
							hashSegment.tag.toLowerCase() , true);
                	
                	if (topicPage != null && topicPage.topics != null 
                			&& !topicPage.topics.isEmpty()) {
                		topicIdFromMap = topicPage.topics[0].id;
                	}
                	
                }
                
                if (topicIdFromMap != null && topicIdFromMap.trim().length() > 0) {
		            String linkUrl = PageContext.getPageURL(Pages.app) + '?u=/topic/' + topicIdFromMap + '/feed';
			        String mentionHashTag = hashSegment.tag;
		            mentionHashTag = FeedUtility.processNameToPreventXSS(mentionHashTag);

	                //feedItemText += '<a data-topic="" href="' + linkUrl +'">#' + mentionHashTag + '</a>';
					//EDT-431
					feedItemText += '<a data-type="topic" data-id="'+topicIdFromMap+'" data-label="'+mentionHashTag+'" data-topic="" href="' + linkUrl +'">#' + mentionHashTag + '</a>';   

                
                }   else {
                	String mentionHashTag = hashSegment.tag;
		            mentionHashTag = FeedUtility.processNameToPreventXSS(mentionHashTag);
                	feedItemText += '#' + mentionHashTag +'';
                }
                      	
			} else if (segment instanceof ConnectApi.LinkSegment) {
	            ConnectApi.LinkSegment linkSegment = (ConnectApi.LinkSegment) segment;
	            String url = linkSegment.url;

				if (!url.startsWith(SimpplrContext.salesforceBaseUrl) && !url.startsWith('https://cdnapisec.kaltura.com')) {
	            	listOfLinksGlobal.add(url);
				}

	            if (url.startsWith('mailto:')) {
	            	url = url.substring('mailto:'.length());
	            }
	            
                feedItemText += '<a href="' + linkSegment.url +'">' + linkSegment.text + '</a>';
	            
            } else if (segment instanceof ConnectApi.MarkupBeginSegment) {
				String segmentHtmlTag = ((ConnectApi.MarkupBeginSegment)segment).htmlTag;
				
				if (segmentHtmlTag == 'a' && ((ConnectApi.MarkupBeginSegment)segment).url != null) {
					feedItemText += '<'+segmentHtmlTag + ' href="' + ((ConnectApi.MarkupBeginSegment)segment).url +'">';

				} else {
					feedItemText += '<'+((ConnectApi.MarkupBeginSegment)segment).htmlTag+'>';
				}
            	
            } else if (segment instanceof ConnectApi.MarkupEndSegment) {
            	feedItemText += '</'+((ConnectApi.MarkupEndSegment)segment).htmlTag+'>';
            	
            } else  if (segment instanceof ConnectApi.TextSegment) {
                ConnectApi.TextSegment textSegment = (ConnectApi.TextSegment) segment;
                String textFromSegment = textSegment.text;
                textFromSegment = textFromSegment.replaceAll('<','&lt;');
                textFromSegment = textFromSegment.replaceAll('>','&gt;');
                feedItemText += textFromSegment;
            
            } else if (segment instanceof ConnectApi.InlineImageSegment) {
            	ConnectApi.InlineImageSegment inlineImgSegment =  (ConnectApi.InlineImageSegment)segment;
            	String imgSegmentHtmlStr = '<img src="';
            	imgSegmentHtmlStr = imgSegmentHtmlStr + inlineImgSegment.url +'"/>' ;
            	feedItemText += imgSegmentHtmlStr;
            }
            
        }
        
        return feedItemText;
    }

	@TestVisible
	private static FeedElementWrapper.PostedOnWrapper convertToPostedOnWrapper(String contentId, String name) {
		FeedElementWrapper.PostedOnWrapper wrapperObj = new FeedElementWrapper.PostedOnWrapper();
		wrapperObj.Id =  contentId;
		wrapperObj.name = name;

		List<Simpplr_content__c> listOfSimpplrContent = feedUtility.loadPostedOnDetails(contentId);

		if (!listOfSimpplrContent.isEmpty()) { 
			Simpplr_content__c contentObj = listOfSimpplrContent[0];
            wrapperObj.title = contentObj.Title__c;
            wrapperObj.isPublished = contentObj.Is_Published__c;
			wrapperObj.postCount = contentObj.Feed_Posts__c == null ? 0 : Integer.valueOf(contentObj.Feed_Posts__c);
			wrapperObj.questionCount = contentObj.Feed_Questions__c == null ? 0 : Integer.valueOf(contentObj.Feed_Questions__c);
			wrapperObj.isQuestionAnswerEnabled = contentObj.Question_Answer_Enabled__c == true;
			wrapperObj.type = contentObj.Type__c.toLowerCase();
			wrapperObj.siteId = contentObj.site__c;
			wrapperObj.description = String.isBlank(contentObj.Display_Excerpt__c) ?'': contentObj.Display_Excerpt__c.unescapeHtml4();
                    
			if (!'blogpost'.equalsIgnoreCase(wrapperObj.type)) {
				wrapperObj.Site = new SiteLiteWrapper();
				wrapperObj.Site.siteId = wrapperObj.siteId;
				wrapperObj.Site.chatterGroupId = contentObj.Site__r.Chatter_Group_Id__c;
				wrapperObj.Site.name = contentObj.Site__r.name;
				wrapperObj.site.isActivated = contentObj.Site__r.Is_Active__c;
				wrapperObj.site.img = String.isBlank(contentObj.Site__r.Title_Content_Version__c) ? 
														null: Utility.getFileDownloadURLFor720By480(contentObj.Site__r.Title_Content_Version__c);
				wrapperObj.site.imgContentDocumentId = contentObj.Site__r.Title_Content_Document__c;
				wrapperObj.site.imgThumbnail = String.isBlank(contentObj.Site__r.Title_Content_Version__c) ? 
														null: Utility.getFileDownloadURLFor120BY90(contentObj.Site__r.Title_Content_Version__c);
				wrapperObj.site.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + wrapperObj.siteId + '/' + contentObj.Site__r.Landing_Page__c;
				wrapperObj.site.access = contentObj.Site__r.Site_Type__c.toLowerCase();
				wrapperObj.site.isManager = UserContext.groupsIManageIdSet.contains(wrapperObj.site.chatterGroupId);
				wrapperObj.site.isOwner = UserContext.siteIOwnMap.keySet().contains(wrapperObj.site.siteId);
				wrapperObj.site.isBroadcast = chatterGroupDataMap.get(wrapperObj.site.chatterGroupId)?.IsBroadcast;

				String chatterGrpOrSiteId = wrapperObj.siteId;

				if (String.isNotBlank(chatterGrpOrSiteId) && (UserContext.sitesIManageIdSet.contains(chatterGrpOrSiteId) || 
						UserContext.sitesIManageContentsMap.keySet().contains(chatterGrpOrSiteId) )) {
					
					if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_ALL_SITES.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
						wrapperObj.site.canUploadAllFileTypes =  true;
					
					} else if (ServiceConstants.ALLOW_FILE_UPLOAD_AS_All_USER.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
						wrapperObj.site.canUploadAllFileTypes =  false;
					
					} else if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)){
						wrapperObj.site.canUploadAllFileTypes =  contentObj.Site__r.Allow_File_Upload_App_Permission__c;
					}

				}
			}

			if ('event'.equalsIgnoreCase(wrapperObj.type)) {
				TimeZone tz = Timezone.getTimeZone(contentObj.Event_TimezoneSidKey__c);
				wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentObj.Event_TimezoneSidKey__c);
				wrapperObj.timezoneIso = tz.getID();
				wrapperObj.timezoneOffset = tz.getOffset(system.today());

				wrapperObj.startsAt = Utility.dateTimeToMomentJSDateTime(contentObj.Event_Start_DateTime__c);
				DateTime endDateTimeValue = contentObj.Event_End_DateTime__c;
												
				if ('12:00 AM'.equalsIgnoreCase(endDateTimeValue.format('h:mm a'))) {
						endDateTimeValue = contentObj.Event_End_DateTime__c.addMinutes(-1);
				}				
				wrapperObj.endsAt = Utility.dateTimeToMomentJSDateTime(endDateTimeValue);
				wrapperObj.isAllDay = contentObj.Event_Is_All_Day__c;				
				if (contentObj.Event_Start_DateTime__c.isSameDay(endDateTimeValue)) {
						wrapperObj.isMultiDay = false;
				} else {
						wrapperObj.isMultiDay = true;
				}
			} else if ('album'.equalsIgnoreCase(wrapperObj.type)) {
				wrapperObj.videoCount = Integer.valueof(contentObj.Album_Video_Count__c);
				wrapperObj.imageCount = Integer.valueof(contentObj.Album_Image_Count__c);
			}

			wrapperObj.authoredBy =  new PeopleLiteWrapper();
			wrapperObj.authoredBy.id = contentObj.Primary_Author__c;
			wrapperObj.authoredBy.peopleId =  contentObj.Primary_Author__c;
			wrapperObj.authoredBy.sfUserId = contentObj.Primary_Author__r.User__c;
			wrapperObj.authoredBy.name = contentObj.Primary_Author__r.Full_Name__c;
			wrapperObj.authoredBy.img = contentObj.Primary_Author__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : contentObj.Primary_Author__r.User__r.SmallPhotoUrl;
			wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentObj.Primary_Author__c;
			
			Map<String, String> args = new Map<String, String>();
			args.put('pageToRedirect', 'ContentDetailFromFeed');
			args.put('contentId', wrapperObj.Id);
			wrapperObj.url = PageContext.getPageURL(Pages.PageRedirector, args);
			wrapperObj.createdAt = contentObj.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			wrapperObj.publishAt = contentObj.Publish_Start_DateTime__c == null ? '' : contentObj.Publish_Start_DateTime__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			wrapperObj.modifiedAt = contentObj.Last_Edited_DateTime__c == null ? '' : contentObj.Last_Edited_DateTime__c.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			
			if (contentObj.File_Simpplr_Content__r.isEmpty() == false) {
				
				if (contentObj.Type__c == 'Album') {
					wrapperObj.listOfTopAlbumImages = new List<FeedElementWrapper.AlbumImagesWrapper>();

					for (File__c fileObj: contentObj.File_Simpplr_Content__r) {
						FeedElementWrapper.AlbumImagesWrapper imagesWrapperObj = new FeedElementWrapper.AlbumImagesWrapper();
						imagesWrapperObj.albumMediaId = fileObj.id;
								
						if (String.isNotBlank(fileObj.Content_Version__c)) {
							imagesWrapperObj.isVideo = false;
							imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
							imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
							
							if (fileObj.Is_Title_Image__c == true) {
								wrapperObj.imageUrl = fileObj.Thumbnail_URL__c;
								wrapperObj.imgTHUMB720BY480URL =  SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL + fileObj.Content_Document__c + '/rendition?type=THUMB720BY480';
							}

						} else {
							imagesWrapperObj.isVideo = true;
							imagesWrapperObj.thumbnailImg = fileObj.Thumbnail_URL__c;
							imagesWrapperObj.img = fileObj.Thumbnail_URL__c;
							imagesWrapperObj.provider = String.isNotBlank(fileObj.Video_provider__c) ? fileObj.Video_provider__c : String.isNotBlank(fileObj.Repository__c) ? fileObj.Repository__c : '';
							imagesWrapperObj.status = fileObj.Video_Status__c;
							imagesWrapperObj.videoId = fileObj.External_id__c;	

							if (fileObj.Is_Title_Image__c == true) {
								wrapperObj.imageUrl = fileObj.Thumbnail_URL__c;
								wrapperObj.imgTHUMB720BY480URL =  fileObj.Thumbnail_URL__c;
							}

						}   

						wrapperObj.listOfTopAlbumImages.add(imagesWrapperObj);
					}

				} else {
					
					for (File__c fileObj: contentObj.File_Simpplr_Content__r) {
						
						if (ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
							wrapperObj.imageUrl = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						
						} else if(ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c)){
							wrapperObj.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +
											fileObj.Content_Document__c + '/rendition?type=THUMB720BY480';
						} 

					}

				}	

			} 

		} else {
			wrapperObj.title = name;
			wrapperObj.hidePost = true;
		}	

		Map<String, String> args = new Map<String, String>();
		args.put('pageToRedirect', 'ContentDetailFromFeed');
		args.put('contentId', wrapperObj.Id);
		String linkUrl = PageContext.getPageURL(Pages.PageRedirector, args);
		wrapperObj.url = linkUrl;
		return wrapperObj;
	}

	/**
	 * @description method to create recognition record
	 * @param recognitionWrapperObject - FeedElementWrapper.RecognitionInfo
	 */
	public static void createRecognition(List<FeedElementWrapper.RecognitionInfo> recognitionWrapperList) {
		List<Recognition__c> recognitionListToInsert = new List<Recognition__c>();
		for(FeedElementWrapper.RecognitionInfo recognitionWrapperObject: recognitionWrapperList){
			Recognition__c recognitionObj = new Recognition__c(
				Feed_Element_Id__c = recognitionWrapperObject.feedElementId,
				Award_Name__c = recognitionWrapperObject.awardName,
				Award_Id__c = recognitionWrapperObject.awardId,
				Award_receviers__c = recognitionWrapperObject.awardedTo,
				Award_Giver__c = recognitionWrapperObject.awardedBy,
				Sub_Type__c = recognitionWrapperObject.subType,
				Object_Id__c = recognitionWrapperObject.objectId
			);
			recognitionListToInsert.add(recognitionObj);
		}
		if(recognitionListToInsert.size() > 0){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(recognitionListToInsert, new List<Schema.SObjectField>{
																			Recognition__c.Award_Name__c,
																			Recognition__c.Award_Id__c,
																			Recognition__c.Award_receviers__c,
																			Recognition__c.Award_Giver__c,
																			Recognition__c.Feed_Element_Id__c,
																			Recognition__c.Sub_Type__c,
																			Recognition__c.Object_Id__c});
		}
	}

	/**
	 * @description method to delete recognition record
	 * @param feedElementId - String
	 */
	public static void deleteRecognition(String feedElementId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', feedElementId);
		String query = 'SELECT Id FROM Recognition__c WHERE Feed_Element_Id__c =:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Recognition__c> listOfRecognition = (List<Recognition__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if (!listOfRecognition.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfRecognition);
		}
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
		String query = 'SELECT Id, Feed_Element_Id__c, Award_Name__c, Award_Id__c, Award_receviers__c, Award_Giver__c, Sub_Type__c, Object_Id__c  FROM Recognition__c WHERE Feed_Element_Id__c =:soqlParam1 ORDER BY CreatedDate DESC';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Recognition__c> listOfRecognition = (List<Recognition__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(listOfRecognition.size() > 0){
			recognitionInfoObj.feedElementId = listOfRecognition[0].Feed_Element_Id__c;
			if(String.isBlank(listOfRecognition[0].Sub_Type__c)){
				Map<String, List<PeopleLiteWrapper.PeopleMinWrapper>> recognitionPeopleResponse = getPeopleMapFromIds(listOfRecognition[0].Award_receviers__c, listOfRecognition[0].Award_Giver__c);
				recognitionInfoObj.recognitionAwardedTo = recognitionPeopleResponse.get('recognitionAwardedTo');
				recognitionInfoObj.recognitionAwardedBy = recognitionPeopleResponse.get('recognitionAwardedBy')[0];
				recognitionInfoObj.recognitionAwardId = listOfRecognition[0].Award_Id__c;
				recognitionInfoObj.recognitionAwardName = listOfRecognition[0].Award_Name__c;
			} else {
				recognitionInfoObj.subType = listOfRecognition[0].Sub_Type__c;
				recognitionInfoObj.objectId = listOfRecognition[0].Object_Id__c;
			}
			
		}
		
		return recognitionInfoObj;
	}

	private static Map<String, List<PeopleLiteWrapper.PeopleMinWrapper>> getPeopleMapFromIds (String recognitionAwardedTo, String recognitionAwardedBy) {
		Map<String, List<PeopleLiteWrapper.PeopleMinWrapper>> recognitionPeopleResponse = new Map<String, List<PeopleLiteWrapper.PeopleMinWrapper>>();
		List<String> peopleIds = new List<String>();
		peopleIds.addAll(recognitionAwardedBy.split(':'));
		peopleIds.addAll(recognitionAwardedTo.split(':'));

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

			List<PeopleLiteWrapper.PeopleMinWrapper> peopleWrapperList;

			if(recognitionAwardedBy.containsIgnoreCase(peopleLite.peopleId)){ //AwardedBy
				peopleWrapperList = recognitionPeopleResponse.containsKey('recognitionAwardedBy') ? recognitionPeopleResponse.get('recognitionAwardedBy') : new List<PeopleLiteWrapper.PeopleMinWrapper>();
				peopleWrapperList.add(peopleLite);
				recognitionPeopleResponse.put('recognitionAwardedBy', peopleWrapperList);

			} else {	
				peopleWrapperList = recognitionPeopleResponse.containsKey('recognitionAwardedTo') ? recognitionPeopleResponse.get('recognitionAwardedTo') : new List<PeopleLiteWrapper.PeopleMinWrapper>();
				peopleWrapperList.add(peopleLite);
				recognitionPeopleResponse.put('recognitionAwardedTo', peopleWrapperList);
			}
		}

		return recognitionPeopleResponse;
	}
}