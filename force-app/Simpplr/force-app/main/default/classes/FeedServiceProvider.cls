public with sharing class FeedServiceProvider {
	/**	Method to fetch **/
	public static FeedElementPageWrapper getSpecifiedFeedElementsPage (String communityId, String feedType, 
			String subjectId, String pageToken, Integer pageSize, String sortParam) {
		try {
			FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
			ConnectApi.FeedElementPage feedElementPageObj = FeedConnectAPIService.getFeedElementsFromFeed(communityId, 
					feedType, subjectId, pageToken, pageSize, sortParam); 

	    	feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
	    	return feedElementPageWrapObj;
			
		} catch (exception e) { 
			
			if (e.getMessage()=='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
			throw e; 
		}
	}

	/**Method to post the TextPost**/
	public static FeedElementWrapper postTextPost (String communityIdArg, String subjectIdArg, 
			String feedElementTypeArg, String textArg, String bodyJsonArg, List<String> listOfTopicArg, Criteria.ModerationResult moderationResult, String locationUrl, List<Criteria.ExternalFileWrapper> externalFiles) {
		return postTextPost (communityIdArg, subjectIdArg, feedElementTypeArg, textArg, bodyJsonArg, listOfTopicArg, moderationResult, null, locationUrl, externalFiles);
	}
	
	/**Method to post the TextPost with recognition argument**/
	public static FeedElementWrapper postTextPost (String communityIdArg, String subjectIdArg, 
			String feedElementTypeArg, String textArg, String bodyJsonArg, List<String> listOfTopicArg, Criteria.ModerationResult moderationResult, FeedElementWrapper.RecognitionInfo recognitionArg, String locationUrl, List<Criteria.ExternalFileWrapper> externalFiles) {
		try {
			Boolean isRecognitionPost = recognitionArg != null ? true : false;
			ConnectApi.FeedElement feedElementObj = FeedConnectAPIService.postFeedElementWithOutCapability(
				communityIdArg, subjectIdArg, feedElementTypeArg, textArg, bodyJsonArg, isRecognitionPost, externalFiles);

			if (recognitionArg != null) {
				recognitionArg.feedElementId = feedElementObj.Id; //Attach feed element id
				//create recognition
				FeedDataAdapter.createRecognition(new List<FeedElementWrapper.RecognitionInfo>{recognitionArg});
				if(String.isBlank(recognitionArg.subType)){
					NotificationDispatcher.sendRecognitionNotificationsAndEmail(feedElementObj, 'recognition');	
				}
			}

			List<TopicWrapper> listOfTopicWrapper = new List<TopicWrapper>();
			
			if (!listOfTopicArg.isEmpty()) {
				listOfTopicWrapper.addAll(assignTopicToFeedElement(communityIdArg, feedElementObj.id,
						listOfTopicArg));
			}
			
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();

			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
				FeedDataAdapter.getPeopleFromUserIds();
			}

			if ( !Test.isRunningTest() && (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c) ||
				ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS.equalsIgnoreCase(SimpplrContext.leadercastEnabledFor))){
				List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(new List<ConnectApi.FeedElement>{feedElementObj});
				siteChatterIdList.add(subjectIdArg);
				Map<Id, Simpplr_Site__c> siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			} else {
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
			}

			if (!listOfTopicWrapper.isEmpty()) {
				
				if (!feedElementWrapperObj.listOfTopics.isEmpty()) {
					
					for (Integer i = 0; i < feedElementWrapperObj.listOfTopics.size(); i++) {
						
						for (Integer j = 0; j < listOfTopicWrapper.size(); j++) {
							
							if (feedElementWrapperObj.listOfTopics[i].id == listOfTopicWrapper[j].id) {
								listOfTopicWrapper.remove(j);
							}
						}
						
					}
				}
				
			}
			
			feedElementWrapperObj.listOfTopics.addAll(listOfTopicWrapper);
			if( SimpplrContext.aiContentModerationEnabled && moderationResult != null && moderationResult.isToxic != null && moderationResult.isToxic){ 
				List<String> categories = moderationResult.categories;
				//Send Info to AI micro-service
				sendPostDataToMS(feedElementWrapperObj, subjectIdArg, categories);
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.isToxic = true;
				moderationResultObj.categories = categories;
				moderationResultObj.moderationStatus = ServiceConstants.REPORTED;
                feedElementWrapperObj.moderationResult = moderationResultObj;
			}else if(SimpplrContext.aiContentModerationEnabled){
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.isToxic = false;
                feedElementWrapperObj.moderationResult = moderationResultObj;
			}
			ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo(feedElementWrapperObj.body, feedElementObj.Id, locationUrl, 'POST', true, false, false, false);    	
			return feedElementWrapperObj;
		} catch (exception e) {
			
			if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/ 
			}
			
			throw e; 
		}
	}

	private static void sendRecognitionNotifications (String recognitionAwardName, String recognitionAwardedById, String recognitionAwardedTo, String feedId) {
		List<NotificationDao.Notification> notificationObjList = new List<NotificationDao.Notification>();
		List<String> recognitionAwardedToList = recognitionAwardedTo.split(':');
		for(String peopleToId:recognitionAwardedToList){
			NotificationDao.Notification notificationObj= new NotificationDao.Notification();
			notificationObj.objectID = feedId;
			notificationObj.objectType = 'FeedItem';
			notificationObj.fromUser = recognitionAwardedById;
			notificationObj.toUser = peopleToId;
			notificationObj.categoryStr = 'Recognition';
			notificationObj.snippet = recognitionAwardName;
			notificationObj.type = 'Information';
			notificationObj.isNew = true;
			notificationObj.isRead = false;
			notificationObjList.add(notificationObj);
		}
		NotificationDispatcher.sendNotifications(notificationObjList);
	}

	/**
     * @description This method is used to process Response Body
     * @param feedElementWrapperObj 
     * @param subjectIdArg 
     * @param categories 
    */
    @TestVisible
	public static void sendPostDataToMS(FeedElementWrapper feedElementWrapperObj, String subjectIdArg, List<String> categories) {
		Map<String, Object> requestBody = new Map<String, Object>();	
		requestBody.put('chatter_comment_id', feedElementWrapperObj.id);
		requestBody.put('author_id', feedElementWrapperObj.authoredBy.userId);
		if(String.isNotBlank(subjectIdArg) && (subjectIdArg.startsWith('0F9') || subjectIdArg.startsWith('069'))){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', subjectIdArg); 
			String siteQuery = 'SELECT Id from simpplr_site__c where Chatter_Group_Id__c =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_site__c> siteObjectList = (List<simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);
			if(!siteObjectList.isEmpty()){
				requestBody.put('site_id', siteObjectList[0].Id);
			}
		}else if(String.isNotBlank(subjectIdArg) && !'me'.equalsIgnoreCase(subjectIdArg)){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', subjectIdArg); 
			String contentQuery = 'SELECT Id, Site__c, Type__c FROM Simpplr_Content__c where Id =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_content__c> contentObjectList = (List<simpplr_content__c>)SIMPESAPI.accessController().queryAsUser(contentQuery, soqlParamMap);
			if(!contentObjectList.isEmpty()){
				requestBody.put('content_id', contentObjectList[0].Id);
				requestBody.put('content_type', contentObjectList[0].Type__c); 
				requestBody.put('site_id', contentObjectList[0].Site__c); 
			}
		}
		AIDataProvider.sendModerationInfo(JSON.serialize(requestBody), categories, feedElementWrapperObj.body);
    }
	
	public static  List<TopicWrapper> assignTopicToFeedElement (String communityIdArg, String feedElementIdArg,
			List<String> listOfTopicsArg) {
			List<TopicWrapper> listOfTopicWrapper = new List<TopicWrapper>();
			
			for (String topicName : listOfTopicsArg) {
                topicName = topicName.trim();
                
                if (topicName.equals('')) {
                    continue;
                }
                
                ConnectApi.Topic newTopicObj = !Test.isRunningTest() ? ConnectApi.Topics.assignTopicByName(communityIdArg,
                		feedElementIdArg, topicName) : TestHelper.getConnectAPITopic();  
                listOfTopicWrapper.add(FeedDataAdapter.convertTopicToWrapper(newTopicObj));
            }
			
			return listOfTopicWrapper;
	}

	/**Method to post the link**/
	public static FeedElementWrapper postLink (String communityIdArg, String subjectIdArg, String feedElementTypeArg, 
			String urlArg, String urlNameArg, String textToPostArg, String bodyJsonArg, List<String> listOfTopicArg, Criteria.ModerationResult moderationResult, String locationUrl) {
		try {
			
			Boolean isSimpplrContentLink = false;
			Boolean isCampaignLink = false;
			String urlToProcess = urlArg;
			
			if(FeedUtility.isSimpplrContentLink(urlToProcess)) {
				isSimpplrContentLink = true;
			
			}  else if (urlToProcess.containsIgnoreCase('app') && urlToProcess.containsIgnoreCase('campaignId')){
					isCampaignLink = true;	
			}
			
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			ConnectApi.FeedElement feedElementObj;
			feedElementObj = FeedConnectAPIService.postFeedElementWithLinkCapability(communityIdArg, subjectIdArg, 
					feedElementTypeArg, urlArg, urlNameArg, textToPostArg, bodyJsonArg);
					
			List<TopicWrapper> listOfTopicWrapper = new List<TopicWrapper>();
			
			if (!listOfTopicArg.isEmpty()) {
				listOfTopicWrapper.addAll(assignTopicToFeedElement(communityIdArg, feedElementObj.id,
						listOfTopicArg));
			}

			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
				FeedDataAdapter.getPeopleFromUserIds();
			}

			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c) ||
				ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS.equalsIgnoreCase(SimpplrContext.leadercastEnabledFor)){
				List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(new List<ConnectApi.FeedElement>{feedElementObj});
				siteChatterIdList.add(subjectIdArg);
				Map<Id, Simpplr_Site__c> siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			} else {
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
			}
			//feedElementWrapperObj.listOfTopics = new List<TopicWrapper>();
			
			if (!listOfTopicWrapper.isEmpty()) {
				
				if (!feedElementWrapperObj.listOfTopics.isEmpty()) {
					
					for (Integer i = 0; i < feedElementWrapperObj.listOfTopics.size(); i++) {
						
						for (Integer j = 0; j < listOfTopicWrapper.size(); j++) {
							
							if (feedElementWrapperObj.listOfTopics[i].id == listOfTopicWrapper[j].id) {
								listOfTopicWrapper.remove(j);
							}
						}
						
					}
				}
				
			}
			
			feedElementWrapperObj.listOfTopics.addAll(listOfTopicWrapper);

			if( SimpplrContext.aiContentModerationEnabled && moderationResult != null && moderationResult.isToxic != null && moderationResult.isToxic){ 
				List<String> categories = moderationResult.categories;
				//Send Info to AI micro-service
				sendPostDataToMS(feedElementWrapperObj, subjectIdArg, categories);
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.isToxic = true;
				moderationResultObj.categories = categories;
				moderationResultObj.moderationStatus = ServiceConstants.REPORTED;
                feedElementWrapperObj.moderationResult = moderationResultObj;
			}else if(SimpplrContext.aiContentModerationEnabled){
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.isToxic = false;
                feedElementWrapperObj.moderationResult = moderationResultObj;
			}
			
			processFeedLink(isSimpplrContentLink, isCampaignLink, urlToProcess, feedElementObj, feedElementWrapperObj);
			ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo(feedElementWrapperObj.body, feedElementObj.Id, locationUrl, 'POST', true, false, false, false);    	
			return feedElementWrapperObj;
		} catch (exception e) {
			
			if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
			throw e; 
		} 
	}
	
	/**Method to post poll**/
	public static FeedElementWrapper postPoll (String communityIdArg, String subjectIdArg, String feedElementTypeArg, 
			List<String> listOfPollChoicesArg, String pollMsgArg, String bodyJsonArg, List<String> listOfTopicArg, String locationUrl) {
		try {
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			ConnectApi.FeedElement feedElementObj;
			feedElementObj = FeedConnectAPIService.postFeedElementWithPollCapability(communityIdArg, subjectIdArg, 
					feedElementTypeArg, listOfPollChoicesArg, pollMsgArg, bodyJsonArg);
					
			List<TopicWrapper> listOfTopicWrapper = new List<TopicWrapper>();
			
			if (!listOfTopicArg.isEmpty()) {
				listOfTopicWrapper.addAll(assignTopicToFeedElement(communityIdArg, feedElementObj.id,
						listOfTopicArg));
			}

			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
				FeedDataAdapter.getPeopleFromUserIds();
			}

			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c) ||
				ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS.equalsIgnoreCase(SimpplrContext.leadercastEnabledFor)){
				List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(new List<ConnectApi.FeedElement>{feedElementObj});
				siteChatterIdList.add(subjectIdArg);
				Map<Id, Simpplr_Site__c> siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			} else {
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
			}
			//feedElementWrapperObj.listOfTopics = new List<TopicWrapper>();
			
			if (!listOfTopicWrapper.isEmpty()) {
				
				if (!feedElementWrapperObj.listOfTopics.isEmpty()) {
					
					for (Integer i = 0; i < feedElementWrapperObj.listOfTopics.size(); i++) {
						
						for (Integer j = 0; j < listOfTopicWrapper.size(); j++) {
							
							if (feedElementWrapperObj.listOfTopics[i].id == listOfTopicWrapper[j].id) {
								listOfTopicWrapper.remove(j);
							}
						}
						
					}
				}
				
			}
			
			feedElementWrapperObj.listOfTopics.addAll(listOfTopicWrapper);
			ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo(feedElementWrapperObj.body, feedElementObj.Id, locationUrl, 'POST', true, false, false, false);    	
			return feedElementWrapperObj;
		} catch (exception e) {
			
			if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
			throw e;  
		}
	}

	/**Method to post the file**/ 
	public static FeedElementWrapper postFile (String communityIdArg, String subjectIdArg, 
			String feedElementTypeArg, List<String> listOfAttachedFileId, String contentCommentBodyArg, String bodyJsonArg,
			List<String> listOfTopicArg, Criteria.ModerationResult moderationResult, String locationUrl, List<Criteria.ExternalFileWrapper> externalFiles) {

			return postFile (communityIdArg, subjectIdArg, feedElementTypeArg, listOfAttachedFileId, contentCommentBodyArg, bodyJsonArg, listOfTopicArg,moderationResult, null, locationUrl, externalFiles);
	}

	/**Method to post the file with recognition argument**/ 
	public static FeedElementWrapper postFile (String communityIdArg, String subjectIdArg, 
			String feedElementTypeArg, List<String> listOfAttachedFileId, String contentCommentBodyArg, String bodyJsonArg,
			List<String> listOfTopicArg, Criteria.ModerationResult moderationResult, FeedElementWrapper.RecognitionInfo recognitionArg, String locationUrl, List<Criteria.ExternalFileWrapper> externalFiles) {
		try {
			Boolean isRecognitionPost = recognitionArg != null ? true : false;
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			ConnectApi.FeedElement feedElementObj = FeedConnectAPIService.postFeedElementWithFileCapabilty(communityIdArg, 
			subjectIdArg, feedElementTypeArg, listOfAttachedFileId, contentCommentBodyArg, bodyJsonArg, isRecognitionPost, externalFiles);

			if (recognitionArg != null) {
				recognitionArg.feedElementId = feedElementObj.Id; //Attach feed element id
				//create recognition
				FeedDataAdapter.createRecognition(new List<FeedElementWrapper.RecognitionInfo>{recognitionArg});
				NotificationDispatcher.sendRecognitionNotificationsAndEmail(feedElementObj, 'recognition');
			}
					
			List<TopicWrapper> listOfTopicWrapper = new List<TopicWrapper>();
			
			if (!listOfTopicArg.isEmpty()) {
				listOfTopicWrapper.addAll(assignTopicToFeedElement(communityIdArg, feedElementObj.id,
						listOfTopicArg));
			}
			
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
				FeedDataAdapter.getPeopleFromUserIds();
			}

			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c) ||
				ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS.equalsIgnoreCase(SimpplrContext.leadercastEnabledFor)){
				List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(new List<ConnectApi.FeedElement>{feedElementObj});
				siteChatterIdList.add(subjectIdArg);
				Map<Id, Simpplr_Site__c> siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			} else {
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
			}
			//feedElementWrapperObj.listOfTopics = new List<TopicWrapper>();
			
			if (!listOfTopicWrapper.isEmpty()) {
				
				if (!feedElementWrapperObj.listOfTopics.isEmpty()) {
					
					for (Integer i = 0; i < feedElementWrapperObj.listOfTopics.size(); i++) {
						
						for (Integer j = 0; j < listOfTopicWrapper.size(); j++) {
							
							if (feedElementWrapperObj.listOfTopics[i].id == listOfTopicWrapper[j].id) {
								listOfTopicWrapper.remove(j);
							}

						}
						
					}

				}
				
			}
			
			feedElementWrapperObj.listOfTopics.addAll(listOfTopicWrapper);

			if( SimpplrContext.aiContentModerationEnabled && moderationResult != null && moderationResult.isToxic != null && moderationResult.isToxic){ 
				List<String> categories = moderationResult.categories;
				//Send Info to AI micro-service
				sendPostDataToMS(feedElementWrapperObj, subjectIdArg, categories);
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.isToxic = true;
				moderationResultObj.categories = categories;
				moderationResultObj.moderationStatus = ServiceConstants.REPORTED;
                feedElementWrapperObj.moderationResult = moderationResultObj;
			}else if(SimpplrContext.aiContentModerationEnabled){
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.isToxic = false;
                feedElementWrapperObj.moderationResult = moderationResultObj;
			}
			ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo(feedElementWrapperObj.body, feedElementObj.Id, locationUrl, 'POST', true, false, false, false);    	
			return feedElementWrapperObj;

		} catch (exception e) {
			
			if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
			throw e; 
		}
	}
	
	/**Method to delete feed**/
	public static Boolean deleteFeed (String communityIdArg, String feedElementIdArg) {
		try {
			if(SimpplrContext.aiContentModerationEnabled){
				Map<String, Object> requestMap = new Map<String, Object>();
				requestMap.put('chatter_comment_id', feedElementIdArg);
				requestMap.put('org_id', SimpplrContext.simpplrOrgId);
				Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/chatter/delete', requestMap);
			}

			FeedConnectAPIService.deleteSpecifiedFeedElement(communityIdArg, feedElementIdArg);
            if(SimpplrContext.isInitiativesAndCampaignsEnabled ){
				deleteFeedVideosCIItems(feedElementIdArg);
			}
			return true;
            
		} catch (exception e) {
			
			if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
			throw e; 
		}
	}
    
    public static void deleteFeedVideosCIItems(String feedElementIdArg){
        String fileId = '';
        if(String.isNotBlank(feedElementIdArg)){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', feedElementIdArg); 
			String fileQuery = 'SELECT Id FROM File__c WHERE Repository__c = \'native_video\' AND Feed_Item__c =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap);
			if(!fileList.isEmpty()){
				fileId = fileList[0].Id;
				CIService.deleteCIItems('video', fileId);
			}
		}
	}
	
	/**Method to delete feed comment**/
	public static Boolean deleteComment (String communityIdArg, String commentIdArg) {
		try {
			if(SimpplrContext.aiContentModerationEnabled){
				Map<String, Object> requestMap = new Map<String, Object>();
				requestMap.put('chatter_reply_id', commentIdArg);
				requestMap.put('org_id', SimpplrContext.simpplrOrgId);
				Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/chatter/delete', requestMap);
			}

			FeedConnectAPIService.deleteComment(communityIdArg, commentIdArg);
			return true;
		} catch (exception e) {
			
			if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
			throw e; 
		}
	}
	
	/**Method to bookmark and unbookmark the feeds**/
	public static Boolean toggleBookMarks (String communityIdArg, String feedElementIdArg, 
			Boolean isBookmarkedByCurrentUserArg) {

		try {
			Boolean resultFlag = FeedConnectAPIService.toggleFeedElementBookMark(communityIdArg,
					feedElementIdArg, isBookmarkedByCurrentUserArg);
			
			List<FeedItem> feedItemList = [SELECT ID, CreatedById 
                    FROM FeedItem 
                    WHERE Id =: feedElementIdArg WITH SECURITY_ENFORCED LIMIT 1];

			if (feedItemList.size() > 0 ) {
				List<Bookmark__c> bookmarkList = [SELECT id, Is_Deleted__c, 
                        Feed_Item_Id__c,People__c 
                        FROM Bookmark__c 
						WHERE Feed_Item_Id__c =: feedItemList[0].Id
						AND People__c =: UserContext.getCurrentUserInfo.Id WITH SECURITY_ENFORCED];

				if (isBookmarkedByCurrentUserArg) {
					List<People__c> pplList = [SELECT Id, User__c 
                            FROM People__c 
                            WHERE User__c =: feedItemList[0].CreatedById  WITH SECURITY_ENFORCED LIMIT 1];
					
					if (bookmarkList.isEmpty()) {
						Bookmark__c  favouriteObj = new Bookmark__c(Bookmark_Receiver__c = pplList.size() > 0 ? pplList[0].Id : NULL,	
                                People__c = UserContext.getCurrentUserInfo.Id, 
                                Feed_Item_Id__c = feedItemList[0].id,
                                Type__c = 'Feed', 
                                name = 'Feed Post');
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					   	SIMPESAPI.accessController().insertAsUser(favouriteObj,
					   			new List<Schema.SObjectField>{ Bookmark__c.Bookmark_Receiver__c,
					   										   Bookmark__c.People__c, Bookmark__c.Type__c,
					   										   Bookmark__c.name,Bookmark__c.Feed_Item_Id__c});
					} else {

						for (Bookmark__c bookmarkObj : bookmarkList) {
		    				bookmarkObj.Is_Deleted__c = false;
						}

		    			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
   						SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(bookmarkList), new List<Schema.SObjectField>{Bookmark__c.Is_Deleted__c});
		    		}

				} else {
					
					for (Bookmark__c bookmarkObj : bookmarkList){
		    			bookmarkObj.Is_Deleted__c = true;
		    		}
	    	
	    			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
   					SIMPESAPI.accessController().updateAsUser(new Map<Id,Bookmark__c>(bookmarkList), new List<Schema.SObjectField>{Bookmark__c.Is_Deleted__c});
						
				}

			} 

			return resultFlag;

		} catch (exception e) {
			
			if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
			throw e; 
		}

	}

	/**Method to post comment on feed**/
	public static RecentCommentsWrapper postComment (String communityIdArg, String feedElementIdArg, 
			String contentDocumentIdArg, String commentText, String bodyJsonArg, Criteria.ModerationResult moderationResult,  List<Criteria.ExternalFileWrapper> externalFiles) {

		try {
			RecentCommentsWrapper commentWrapperObj =  new RecentCommentsWrapper();
			ConnectApi.Comment commentObj;
			
			if (contentDocumentIdArg != null && contentDocumentIdArg.trim().length() > 0) {
				commentObj = FeedConnectAPIService.postCommentToFeedElement(communityIdArg, 
						feedElementIdArg, contentDocumentIdArg, commentText, bodyJsonArg, externalFiles);
			} else {
				commentObj = FeedConnectAPIService.postCommentToFeedElement(communityIdArg, 
						feedElementIdArg, commentText, bodyJsonArg, externalFiles);
			}	

			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				FeedDataAdapter.getUserIdsToConvert(commentObj);
				FeedDataAdapter.getPeopleFromUserIds();
			}

			commentWrapperObj = FeedDataAdapter.convertFeedCommentToWrapper(commentObj);
			
			if( SimpplrContext.aiContentModerationEnabled && moderationResult != null && moderationResult.isToxic != null && moderationResult.isToxic){ 
				List<String> categories = moderationResult.categories;
				//Send Info to AI micro-service
				sendCommentDataToMS(commentWrapperObj, feedElementIdArg, categories);
				RecentCommentsWrapper.ModerationResult moderationResultObj = new RecentCommentsWrapper.ModerationResult();
				moderationResultObj.isToxic = true;
				moderationResultObj.categories = categories;
				moderationResultObj.moderationStatus = ServiceConstants.REPORTED;
                commentWrapperObj.moderationResult = moderationResultObj;
			} else if(SimpplrContext.aiContentModerationEnabled){
				RecentCommentsWrapper.ModerationResult moderationResultObj = new RecentCommentsWrapper.ModerationResult();
				moderationResultObj.isToxic = false;
                commentWrapperObj.moderationResult = moderationResultObj;
			}
			ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo(commentWrapperObj.body, commentObj.Id, null, 'REPLY', false, false, false, false);    	
			return commentWrapperObj;

		} catch (exception e) {
			
			if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
			throw e; 
		}

	}

	/**
     * @description This method is used to process Response Body
     * @param commentWrapperObj 
     * @param feedElementIdArg 
     * @param categories 
    */
    @TestVisible
	public static void sendCommentDataToMS(RecentCommentsWrapper commentWrapperObj, String feedElementIdArg, List<String> categories) {
		Map<String, Object> requestBody = new Map<String, Object>();	
		requestBody.put('chatter_reply_id', commentWrapperObj.id);
		requestBody.put('author_id', commentWrapperObj.authoredBy.userId);
		requestBody.put('parent_comment_id', feedElementIdArg); 
		
		requestBody.put('post_type', commentWrapperObj.postType); 
		String subjectIdArg = '';
		if(String.isNotBlank(feedElementIdArg)){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', feedElementIdArg); 
			String feedItemQuery = 'SELECT Id, ParentId FROM FeedItem where Id =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<FeedItem> feedItemObjectList = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);
			if(!feedItemObjectList.isEmpty()){
				subjectIdArg = feedItemObjectList[0].ParentId;
			}
		}
		if(String.isNotBlank(subjectIdArg) && (subjectIdArg.startsWith('0F9') || subjectIdArg.startsWith('069'))){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', subjectIdArg); 
			String siteQuery = 'SELECT Id from simpplr_site__c where Chatter_Group_Id__c =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_site__c> siteObjectList = (List<simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);
			if(!siteObjectList.isEmpty()){
				requestBody.put('site_id', siteObjectList[0].Id);
			}
		}else if(String.isNotBlank(subjectIdArg) && !'me'.equalsIgnoreCase(subjectIdArg)){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', subjectIdArg); 
			String contentQuery = 'SELECT Id, Site__c, Type__c FROM Simpplr_Content__c where Id =:soqlParam1 LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_content__c> contentObjectList = (List<simpplr_content__c>)SIMPESAPI.accessController().queryAsUser(contentQuery, soqlParamMap);
			if(!contentObjectList.isEmpty()){
				requestBody.put('content_id', contentObjectList[0].Id);
				requestBody.put('content_type', contentObjectList[0].Type__c); 
				requestBody.put('site_id', contentObjectList[0].Site__c); 
			}
		}
		AIDataProvider.sendModerationInfo(JSON.serialize(requestBody), categories, commentWrapperObj.body);
    }
	
	/**Method to search feed**/
	public static FeedElementPageWrapper searchFeeds(String communityIdArg, String feedTypeArg, 
            String subjectIdArg , String pageParamArg, Integer pageSizeArg, 
            String searchStrArg, String sortParamArg) {
        FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
        ConnectApi.FeedElementPage feedElementPageObj;
        feedElementPageObj = FeedConnectAPIService.searchFeeds(communityIdArg, feedTypeArg, 
                subjectIdArg, pageParamArg, pageSizeArg, searchStrArg, sortParamArg);
        feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
        return feedElementPageWrapObj;
    }
    
    /**Method to vote on feed Poll**/
     public static PollWrapper voteOnPoll (String communityIdArg, String feedElementIdArg, 
     		String myChoiceIdArg) {
    	try {
    		ConnectApi.PollCapability pollCapabilityObj;
    		pollCapabilityObj = FeedConnectAPIService.voteOnFeedElementPoll(communityIdArg, feedElementIdArg, 
					myChoiceIdArg);
					
			List<PollChoiceWrapper> listOfFeedPollChoiceWrapper = new List<PollChoiceWrapper>();
			
			for (ConnectApi.FeedPollChoice feedPollChObj : pollCapabilityObj.choices) {
				listOfFeedPollChoiceWrapper.add(FeedDataAdapter.convertFeedPollChoiceToWrapper(feedPollChObj));
			}
			
			PollWrapper pollObj = new PollWrapper();
			pollObj.title = '';
			pollObj.listOfAnswers = new List<PollChoiceWrapper>();
			pollObj.listOfAnswers.addAll(listOfFeedPollChoiceWrapper);
			pollObj.totalVotes = pollCapabilityObj.totalVoteCount;
			pollObj.myChoiceId = pollCapabilityObj.myChoiceId;
			
			if (pollObj.myChoiceId != null) {
				pollObj.hasVoted = true;
				
			} else {
				pollObj.hasVoted = false;
			}
			
			return pollObj;
    	} catch (exception e) {
    		
    		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
    	}

    }
    
    /**Method to like the feedElement **/
     public static String likeFeedElement (String communityIdArg, String feedElementIdArg) {
     	try {
     		FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
     		ConnectApi.ChatterLike chatterLikeObj = FeedConnectAPIService.likeFeedElement(communityIdArg, 
    				feedElementIdArg);
    		
    		return chatterLikeObj.Id;
     	} catch (exception e) {
     		
     		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
     	}
     }
     
     /**Method to unlike the feedElement **/
     public static Boolean unlikeFeedElement (String communityIdArg, String likeIdArg, String feedElementIdArg) {
     	try {
     		FeedConnectAPIService.unlikeFeedElement(communityIdArg, likeIdArg, feedElementIdArg);
    		
    		return true;
     	} catch (exception e) {
     		
     		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
     	}
     }
     
     /**Method to like the comment **/
     public static String likeComment (String communityIdArg, String commentIdArg, String feedElementIdArg) {
     	try {
     		RecentCommentsWrapper commentWrapperObj = new RecentCommentsWrapper();
     		ConnectApi.ChatterLike chatterLikeObj = FeedConnectAPIService.likeComment(communityIdArg, 
    				commentIdArg, feedElementIdArg); 
    		
    		return chatterLikeObj.Id;
     	} catch (exception e) {
     		
     		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
     	}
     }
     
     /**Method to unlike the comment **/
     public static Boolean unlikeComment (String communityIdArg, String commentIdArg, String likeIdArg) {
     	try {
     		FeedConnectAPIService.unlikeComment(communityIdArg, commentIdArg, likeIdArg);
     		
    		return true;
     	} catch (exception e) {
     		
     		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
     	}
     }

	 /**Method to update the TextPost**/
	 public static FeedElementWrapper updateFeedElement (String communityIdArg, String feedElementIdArg,
    		String bodyMsgArg, String bodyJsonArg, Criteria.ModerationResult moderationResult, List<Criteria.ExternalFileWrapper>  externalFiles){
			return updateFeedElement (communityIdArg, feedElementIdArg, bodyMsgArg, bodyJsonArg, moderationResult, null, externalFiles);
	}
    
	/**Method to update the TextPost with recognition argument**/
    public static FeedElementWrapper updateFeedElement (String communityIdArg, String feedElementIdArg,
    		String bodyMsgArg, String bodyJsonArg, Criteria.ModerationResult moderationResult, FeedElementWrapper.RecognitionInfo recognitionArg, List<Criteria.ExternalFileWrapper>  externalFiles) {
				System.debug('FSP>>updateFeedElement>>>>>803>>>>bodyMsgArg ' + bodyMsgArg);
				System.debug('FSP>>updateFeedElement>>>>>804>>>>bodyJsonArg ' + bodyJsonArg);
				System.debug('FSP>>updateFeedElement>>>>>805>>>>externalFiles ' + externalFiles);
    	try {
			Boolean isRecognitionPost = recognitionArg != null ? true : false;

    		ConnectApi.FeedElement feedElementObj = FeedConnectAPIService.updateFeedElement(communityIdArg,
    				feedElementIdArg, bodyMsgArg, bodyJsonArg, isRecognitionPost, externalFiles);
    		FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();

			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
				FeedDataAdapter.getPeopleFromUserIds();
			}

			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c) ||
				ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS.equalsIgnoreCase(SimpplrContext.leadercastEnabledFor)){
				List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(new List<ConnectApi.FeedElement>{feedElementObj});
				Map<Id, Simpplr_Site__c> siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			} else {
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
			}
			
			if(SimpplrContext.aiContentModerationEnabled && moderationResult != null && moderationResult.isToxic != null && moderationResult.isToxic){ 
				List<String> categories = moderationResult.categories;
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				String parentId;
				soqlParamMap.put('soqlParam1', feedElementIdArg); 
				String feedItemQuery = 'SELECT ParentId FROM FeedItem where Id =:soqlParam1 LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<FeedItem> feedItemList = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);
			
				if(!feedItemList.isEmpty()){
					parentId = feedItemList[0].ParentId;
				}

				//Send Info to AI micro-service
				sendPostDataToMS(feedElementWrapperObj, parentId, categories);
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.isToxic = true;
				moderationResultObj.categories = categories;
				moderationResultObj.moderationStatus = ServiceConstants.REPORTED;
                feedElementWrapperObj.moderationResult = moderationResultObj;
			}else if(SimpplrContext.aiContentModerationEnabled && System.isBatch() == false){
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.isToxic = false;
                feedElementWrapperObj.moderationResult = moderationResultObj;
				
				AIDataProvider.deleteNonToxicEditedContent(feedElementIdArg,'feed');
			}
			
			System.debug('FSP>>updateFeedElement>>>>>855>>>>feedElementWrapperObj ' + feedElementWrapperObj);
    		return feedElementWrapperObj;

    	} catch (Exception e) {
    		
    		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
    	}
    }
	
    public static RecentCommentsWrapper updateComment (String communityIdArg, String commentIdArg,
     		String commentBodyArg, String bodyJsonArg, Criteria.ModerationResult moderationResult, List<Criteria.ExternalFileWrapper>  externalFiles) {
    	try {
    		RecentCommentsWrapper recentCommentsWrapperObj = new RecentCommentsWrapper();

    		ConnectApi.Comment commentObj = FeedConnectAPIService.updateComment(communityIdArg, commentIdArg, 
     			commentBodyArg, bodyJsonArg, externalFiles);

			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				FeedDataAdapter.getUserIdsToConvert(commentObj);
				FeedDataAdapter.getPeopleFromUserIds();
			}

    		recentCommentsWrapperObj = FeedDataAdapter.convertFeedCommentToWrapper(commentObj);
			if( SimpplrContext.aiContentModerationEnabled && moderationResult != null && moderationResult.isToxic != null && moderationResult.isToxic){ 
				List<String> categories = moderationResult.categories;
				//Send Info to AI micro-service
				
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', commentIdArg);
				
				String feedCommentQuery = 'select FeedItemId from FeedComment where id=:soqlParam1 limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<FeedComment> feedCommentList = (List<FeedComment>)SIMPESAPI.accessController().queryAsUser(feedCommentQuery, soqlParamMap);
				String feedItemId;
				if(!feedCommentList.isEmpty()){
					feedItemId = feedCommentList[0].FeedItemId;
				}
				sendCommentDataToMS(recentCommentsWrapperObj, feedItemId, categories);
				RecentCommentsWrapper.ModerationResult moderationResultObj = new RecentCommentsWrapper.ModerationResult();
				moderationResultObj.isToxic = true;
				moderationResultObj.categories = categories;
				moderationResultObj.moderationStatus = ServiceConstants.REPORTED;
                recentCommentsWrapperObj.moderationResult = moderationResultObj;
			} else if(SimpplrContext.aiContentModerationEnabled && System.isBatch() == false){
				RecentCommentsWrapper.ModerationResult moderationResultObj = new RecentCommentsWrapper.ModerationResult();
				moderationResultObj.isToxic = false;
                recentCommentsWrapperObj.moderationResult = moderationResultObj;
				
				AIDataProvider.deleteNonToxicEditedContent(commentIdArg,'comment');
			}	
    		return recentCommentsWrapperObj;

    	} catch (Exception e) {
    		
    		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
    	}

    }
    
    public static ConnectApi.Photo setProfilePhoto (String communityIdArg, String peopleIdArg, String fileIdArg, Integer versionNumber) {
		try {
			List<People__c> peopleList = [SELECT User__c 
                    FROM People__c 
                    WHERE id=:peopleIdArg];
			
			ConnectApi.Photo photoObj = FeedConnectAPIService.setProfilePhoto(communityIdArg, 
                    peopleList[0].User__c, fileIdArg, versionNumber);
			
			new PeopleDao().saveExternalPhotoURL(peopleIdArg, photoObj.smallPhotoUrl, 
                    photoObj.standardEmailPhotoUrl, photoObj.fullEmailPhotoUrl);
			return photoObj;

		} catch (Exception e) {
    		
    		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
    	}	

	}
	
	public static void removeProfilePhoto (String communityIdArg, String peopleIdArg) {
		try {
			List<People__c> peopleList = [SELECT User__c FROM People__c WHERE id=:peopleIdArg WITH SECURITY_ENFORCED];
			FeedConnectAPIService.removeProfilePhoto(communityIdArg, peopleList[0].User__c);
			new PeopleDao().saveExternalPhotoURL(peopleIdArg, null, null, null);

		} catch (Exception e) {

    		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}

    		throw e;
    	}

	}

	 public static PollWrapper getFeedPoll (String communityIdArg, String feedElementIdArg) {
    	try {
    		ConnectApi.PollCapability pollCapabilityObj;
    		pollCapabilityObj = FeedConnectAPIService.getFeedPoll(communityIdArg, feedElementIdArg);
			List<PollChoiceWrapper> listOfFeedPollChoiceWrapper = new List<PollChoiceWrapper>();
			
			for (ConnectApi.FeedPollChoice feedPollChObj : pollCapabilityObj.choices) {
				listOfFeedPollChoiceWrapper.add(FeedDataAdapter.convertFeedPollChoiceToWrapper(feedPollChObj));
			}
			
			PollWrapper pollObj = new PollWrapper();
			pollObj.title = '';
			pollObj.listOfAnswers = new List<PollChoiceWrapper>();
			pollObj.listOfAnswers.addAll(listOfFeedPollChoiceWrapper);
			pollObj.totalVotes = pollCapabilityObj.totalVoteCount;
			pollObj.myChoiceId = pollCapabilityObj.myChoiceId;
			
			if (pollObj.myChoiceId != null) {
				pollObj.hasVoted = true;
				
			} else {
				pollObj.hasVoted = false;
			}
			
			return pollObj;
    	} catch (exception e) {
    		
    		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
    	}

    }
    
    public static void processFeedLink(Boolean isSimpplrContentLink, 
			Boolean isCampaignLink, String urlToProcess, ConnectApi.FeedElement feedElementObj, 
			FeedElementWrapper feedElementWrapperObj){
		
		if (isSimpplrContentLink) {
			String simpContentId = Utility.getParamValueFromUrl(urlToProcess, 'contentId');
			String simpFileId = Utility.getParamValueFromUrl(urlToProcess,'fileId');
			String simpAlbumFileId = '';
			
			if (String.isBlank(simpFileId) && String.isBlank(simpContentId)) {

				if (urlToProcess.containsIgnoreCase('/gallery/')) {
					simpAlbumFileId = urlToProcess.substringAfterLast('/');	
					simpContentId = urlToProcess.substringBeforeLast('/gallery/').substringAfterLast('/');
				
				} else {
					simpContentId = urlToProcess.substringAfterLast('/');
				}

			}					
			
			String simpSiteId = Utility.getParamValueFromUrl(urlToProcess,'siteId');
			
			if (String.isNotBlank(simpContentId)) {
				feedElementWrapperObj.postType = 'link';
				feedElementWrapperObj.link = new LinkWrapper();
				feedElementWrapperObj.link.url = feedElementObj.capabilities.link.Url;
				feedElementWrapperObj.link.title = feedElementObj.capabilities.link.UrlName;	
				
				if (!urlToProcess.containsIgnoreCase('/gallery/')) {						
					List<Simpplr_content__c> listOfSimpplrContent = [SELECT id, Site__r.Name, Site__r.Landing_Page__c, Site__r.Id,Site__r.Title_Content_Version__c,
							Site__r.Site_Type__c,Site__r.Is_Active__c,Site__c, Primary_Author__r.User__c, Primary_Author__r.Full_Name__c, Primary_Author__c,
							CreatedById, Title__c, Is_Published__c, Site__r.Chatter_Group_Id__c ,Is_Must_read__c,
							Primary_Author__r.User__r.SmallPhotoUrl, CreatedDate, Display_Excerpt__c, 
							Type__c, Album_Video_Count__c, Album_Allow_All_to_Upload__c, Album_Image_Count__c,
							Event_Is_All_Day__c, Event_Start_DateTime__c, Event_End_DateTime__c, Event_TimezoneSidKey__c, Pages_Category__c, Pages_Category__r.Name__c,
							(Select Id, Confirm_DateTime__c  from Must_Read_Confirm_History__r Where People__c =:UserContext.getCurrentUserInfo.Id and Must_Read_Audit__r.Removed_DateTime__c=null),
							(SELECT Id,Content_Version__c,Content_Document__c,Title_Image_Type__c,Is_Title_Image__c,Thumbnail_URL__c, MIME_Type__c FROM File_Simpplr_Content__r 
							WHERE Location__c IN ('cover' , 'media') And Is_Deleted__c = false ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, Order__c desc LIMIT 4) 
							FROM Simpplr_Content__c WHERE Id=:simpContentId WITH SECURITY_ENFORCED];	
					
					if (!listOfSimpplrContent.isEmpty()) { 
						feedElementWrapperObj.link.id = listOfSimpplrContent[0].id;
						feedElementWrapperObj.link.description = String.isBlank(listOfSimpplrContent[0].Display_Excerpt__c)?'':listOfSimpplrContent[0].Display_Excerpt__c.unescapeHtml4();
						feedElementWrapperObj.link.title = listOfSimpplrContent[0].Title__c;


						if (ServiceConstants.TYPE_PAGE.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
							feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.app)+'#/site/'+listOfSimpplrContent[0].site__c+'/page/'+listOfSimpplrContent[0].Id;
							feedElementWrapperObj.link.category = new LinkWrapper.CategoryWrapper();
							feedElementWrapperObj.link.category.id = listOfSimpplrContent[0].Pages_Category__c;
							feedElementWrapperObj.link.category.name = listOfSimpplrContent[0].Pages_Category__r.Name__c;
							feedElementWrapperObj.link.category.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrContent[0].site__c + '/content&pageCategoryId=' + listOfSimpplrContent[0].Pages_Category__c;
																	  
				
						} else if (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
							feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.ProfileBlogPost)+'#/profile/'+listOfSimpplrContent[0].Primary_Author__c+'/blog/'+listOfSimpplrContent[0].id;                                          
				
						} else if (ServiceConstants.TYPE_EVENT.equalsIgnoreCase(listOfSimpplrContent[0].Type__c)){
							feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.app)+'#/site/'+listOfSimpplrContent[0].site__c+'/event/'+listOfSimpplrContent[0].Id;
							
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
							feedElementWrapperObj.link.url = PageContext.getPageURL(Pages.app)+'#/site/'+listOfSimpplrContent[0].site__c+'/album/'+listOfSimpplrContent[0].Id;                                           
						}
						
						feedElementWrapperObj.link.isMustRead = listOfSimpplrContent[0].Is_Must_read__c;
						
						if (listOfSimpplrContent[0].Must_Read_Confirm_History__r.isEmpty()) {
							feedElementWrapperObj.link.hasRead = false;
						
						} else {
							feedElementWrapperObj.link.hasRead = true;
						} 
						 
						if (!listOfSimpplrContent[0].File_Simpplr_Content__r.isEmpty()) { 
							
							if (listOfSimpplrContent[0].Is_Published__c) {
							
								if (listOfSimpplrContent[0].Type__c == 'Album') {
									feedElementWrapperObj.link.listOfTopAlbumImages = new List<LinkWrapper.AlbumImagesWrapper>();
						        	for(File__c fileObj : listOfSimpplrContent[0].File_Simpplr_Content__r){
						        		feedElementWrapperObj.link.imageUrl = fileObj.Thumbnail_URL__c;
						        		
						        		LinkWrapper.AlbumImagesWrapper imagesWrapperObj = new LinkWrapper.AlbumImagesWrapper();
										imagesWrapperObj.albumMediaId = fileObj.id;

					    				if (String.isNotBlank(fileObj.Content_Version__c)) {
					    					imagesWrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
											imagesWrapperObj.thumbnailImg = Utility.getFileDownloadURLFor720BY480(fileObj.Content_Version__c);
					    				
					    				} else {
					    					imagesWrapperObj.thumbnailImg = fileObj.Thumbnail_URL__c;
											imagesWrapperObj.img = fileObj.Thumbnail_URL__c;	
					    				}

					    				feedElementWrapperObj.link.listOfTopAlbumImages.add(imagesWrapperObj);
							        		
						        	}

								} else {
									feedElementWrapperObj.link.imageUrl = Utility.getFileDownloadURL(listOfSimpplrContent[0].File_Simpplr_Content__r[0].Content_Version__c);
								}
								
							}
							
						}
						
						String siteImageUrl = '';
						String imgThumbnail = '';
						Boolean isSitePrivate = false;
						Boolean isSiteUnlisted = false;
						
						if (listOfSimpplrContent[0].Site__r.Chatter_Group_Id__c != null) {
							siteImageUrl =  String.isBlank(listOfSimpplrContent[0].Site__r.Title_Content_Version__c)?null:Utility.getFileDownloadURLFor720By480(listOfSimpplrContent[0].Site__r.Title_Content_Version__c);
							imgThumbnail =  String.isBlank(listOfSimpplrContent[0].Site__r.Title_Content_Version__c)?null:Utility.getFileDownloadURLFor120BY90(listOfSimpplrContent[0].Site__r.Title_Content_Version__c);
							
							if ('public'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)) {
								isSitePrivate = false;
								
							} else if ('private'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)){
								isSitePrivate = true;

							} else if ('unlisted'.equalsIgnoreCase(listOfSimpplrContent[0].Site__r.Site_Type__c)){
								isSiteUnlisted = true;
							}
							
						}
						
						feedElementWrapperObj.link.authoredBy =  new PeopleLiteWrapper();
						feedElementWrapperObj.link.authoredBy.id = listOfSimpplrContent[0].Primary_Author__c;
						feedElementWrapperObj.link.authoredBy.name = listOfSimpplrContent[0].Primary_Author__r.Full_Name__c;
						feedElementWrapperObj.link.authoredBy.img = listOfSimpplrContent[0].Primary_Author__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : listOfSimpplrContent[0].Primary_Author__r.User__r.SmallPhotoUrl;
						Map<String, String> args = new Map<String, String>();
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
							feedElementWrapperObj.link.site.isListed = !isSiteUnlisted;
							String sitelinkUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrContent[0].Site__c + '/' + listOfSimpplrContent[0].Site__r.Landing_Page__c;
							feedElementWrapperObj.link.site.url = sitelinkUrl;
						}
						
						//feedElementWrapperObj.link.category =  new LinkWrapper.CategoryWrapper();

						String dateStringValue = String.valueOf(listOfSimpplrContent[0].CreatedDate);
						
						if (String.isNotBlank(dateStringValue)) { 
							DateTime DateTimeValue = listOfSimpplrContent[0].CreatedDate;
							feedElementWrapperObj.link.createdAt = DateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
						}
						
						feedElementWrapperObj.link.type = listOfSimpplrContent[0].Type__c;
						feedElementWrapperObj.link.videoCount = Integer.valueof(listOfSimpplrContent[0].Album_Video_Count__c);
						feedElementWrapperObj.link.isOpenToSubmissions  = listOfSimpplrContent[0].Album_Allow_All_to_Upload__c;
						feedElementWrapperObj.link.imageCount = Integer.valueof(listOfSimpplrContent[0].Album_Image_Count__c);
						feedElementWrapperObj.link.isPublished = listOfSimpplrContent[0].Is_Published__c;	
					}
					
				} else {
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', simpAlbumFileId);
					String filesQuery = 'SELECT Id, Simpplr_Content__c, Simpplr_Content__r.Site__r.Name, Simpplr_Content__r.Site__r.Landing_Page__c, Simpplr_Content__r.Site__r.Id,Simpplr_Content__r.Site__r.Title_Content_Version__c,'+
							' Simpplr_Content__r.Site__r.Site_Type__c,Simpplr_Content__r.Site__r.Is_Active__c,Simpplr_Content__r.Site__c, Author__r.Full_Name__c, Author__c,'+
							' CreatedById, Simpplr_Content__r.Title__c, Simpplr_Content__r.Is_Published__c, Simpplr_Content__r.Site__r.Chatter_Group_Id__c ,Simpplr_Content__r.Is_Must_read__c,'+
							' Author__r.User__r.SmallPhotoUrl, CreatedDate, Simpplr_Content__r.Type__c, Simpplr_Content__r.Display_Excerpt__c,'+
							' Thumbnail_URL__c, Content_Version__c, MIME_Type__c, External_Id__c, Url__c,'+
							' Simpplr_Content__r.Album_Video_Count__c, Simpplr_Content__r.Album_Allow_All_to_Upload__c, Simpplr_Content__r.Album_Image_Count__c  '+
							' FROM File__c WHERE Id=:soqlParam1 And is_Deleted__c = false And Simpplr_Content__r.is_Deleted__c=false';	
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<File__c> listOfSimpplrAlbumFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
					if (!listOfSimpplrAlbumFile.isEmpty()) { 
						
						feedElementWrapperObj.link.id = listOfSimpplrAlbumFile[0].Simpplr_Content__c;
						feedElementWrapperObj.link.albumMediaId = listOfSimpplrAlbumFile[0].Id;
						
						if (listOfSimpplrAlbumFile[0].MIME_Type__c == 'image') {
							feedElementWrapperObj.link.downloadUrl = Utility.getFileDownloadURL(listOfSimpplrAlbumFile[0].Content_Version__c);
						
						} else if (listOfSimpplrAlbumFile[0].MIME_Type__c == 'video') {
							feedElementWrapperObj.link.video = new LinkWrapper.VideoWrapper();
							feedElementWrapperObj.link.video.Id = 	listOfSimpplrAlbumFile[0].External_Id__c;
							
							if (listOfSimpplrAlbumFile[0].Url__c.contains('://youtu.be/') || listOfSimpplrAlbumFile[0].Url__c.contains('.youtube.com/watch')) {
								feedElementWrapperObj.link.video.provider = 'youtube';
								
							} else if (listOfSimpplrAlbumFile[0].Url__c.contains('://embed.vidyard.com/share')) { 
								feedElementWrapperObj.link.video.provider = 'vidyard';
								
							} else if (listOfSimpplrAlbumFile[0].Url__c.contains('https://vimeo.com/')) {
								feedElementWrapperObj.link.video.provider = 'vimeo';
								
							} else if (listOfSimpplrAlbumFile[0].Url__c.contains('wistia.')) {
								feedElementWrapperObj.link.video.provider = 'wistia';
								
							} else if (listOfSimpplrAlbumFile[0].Url__c.containsIgnoreCase('vbrick.com')) {
								feedElementWrapperObj.link.video.provider = 'vbrick';
								
							}	
															
						}
						
						feedElementWrapperObj.link.description = String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Display_Excerpt__c)?'':listOfSimpplrAlbumFile[0].Simpplr_Content__r.Display_Excerpt__c.unescapeHtml4();									
						feedElementWrapperObj.link.title = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Title__c;
						
						feedElementWrapperObj.link.isMustRead = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Is_Must_read__c;
							
						if (listOfSimpplrAlbumFile[0].Simpplr_Content__r.Is_Published__c) {
						
							if (listOfSimpplrAlbumFile[0].Simpplr_Content__r.Type__c == 'Album') {
								feedElementWrapperObj.link.imageUrl = listOfSimpplrAlbumFile[0].Thumbnail_URL__c;
							
							} else {
								feedElementWrapperObj.link.imageUrl = Utility.getFileDownloadURL(listOfSimpplrAlbumFile[0].Content_Version__c);
							}
						}
						
						String siteImageUrl = '';
						String imgThumbnail = '';
						Boolean isSitePrivate = false;
						Boolean isSiteUnlisted = false;
						
						if (listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Chatter_Group_Id__c != null) {
							
							siteImageUrl =  String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c)?null:Utility.getFileDownloadURLFor720By480(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c);
							imgThumbnail =  String.isBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c)?null:Utility.getFileDownloadURLFor120BY90(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Title_Content_Version__c);
							
							if ('public'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)) {
								isSitePrivate = false;
								
							} else if ('private'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)){
								isSitePrivate = true;
							
							} else if ('unlisted'.equalsIgnoreCase(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Site_Type__c)){
								isSiteUnlisted = true;
							}
							
						}
						
						feedElementWrapperObj.link.authoredBy =  new PeopleLiteWrapper();
						feedElementWrapperObj.link.authoredBy.id = listOfSimpplrAlbumFile[0].Author__c;
						feedElementWrapperObj.link.authoredBy.name = listOfSimpplrAlbumFile[0].Author__r.Full_Name__c;
						feedElementWrapperObj.link.authoredBy.img = listOfSimpplrAlbumFile[0].Author__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : listOfSimpplrAlbumFile[0].Author__r.User__r.SmallPhotoUrl;
						Map<String, String> args = new Map<String, String>();
						String profileLinkUrl = PageContext.getPageURL(Pages.app) + '?u=/people/' + listOfSimpplrAlbumFile[0].Author__c;
						feedElementWrapperObj.link.authoredBy.url = profileLinkUrl;
						
						if (String.isNotBlank(listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c)) {
							feedElementWrapperObj.link.site =  new SiteLiteWrapper();
							feedElementWrapperObj.link.site.siteId =  listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c;
							feedElementWrapperObj.link.site.name = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Name;
							feedElementWrapperObj.link.site.isActivated = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Is_Active__c;
							feedElementWrapperObj.link.site.img = siteImageUrl;
							feedElementWrapperObj.link.site.imgThumbnail = imgThumbnail;
							feedElementWrapperObj.link.site.isPrivate = isSitePrivate;
							feedElementWrapperObj.link.site.isListed = !isSiteUnlisted;
							String sitelinkUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__c + '/' + listOfSimpplrAlbumFile[0].Simpplr_Content__r.Site__r.Landing_Page__c;
							feedElementWrapperObj.link.site.url = sitelinkUrl;
						}
						
						//feedElementWrapperObj.link.category =  new LinkWrapper.CategoryWrapper();

						String dateStringValue = String.valueOf(listOfSimpplrAlbumFile[0].CreatedDate);
						
						if (String.isNotBlank(dateStringValue)) { 
							DateTime DateTimeValue = listOfSimpplrAlbumFile[0].CreatedDate;
							feedElementWrapperObj.link.createdAt = DateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
						}
						
						feedElementWrapperObj.link.type = listOfSimpplrAlbumFile[0].Simpplr_Content__r.Type__c;
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
                    
                    if (listOfContentDoc[0].ContentSize != null){
                        fileWrapObj.size = Integer.valueOf(listOfContentDoc[0].ContentSize);
                    } 
                    
                    if ((listOfContentDoc[0].FileExtension == 'jpg') || (listOfContentDoc[0].FileExtension == 'png') || 
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
                    feedElementWrapperObj.link.url = feedElementObj.capabilities.link.Url;
                    feedElementWrapperObj.link.title = feedElementObj.capabilities.link.UrlName;	
                    
                }
				 
			}
		
		}  else if (isCampaignLink) {
			String campaignId = Utility.getParamValueFromUrl(urlToProcess,'campaignId');
			CampaignService campaignServiceObj = new CampaignService();
			feedElementWrapperObj.postType = 'campaign';
			feedElementWrapperObj.campaign = campaignServiceObj.getCampaignForFeed(campaignId);	
						
		}  
    }

	public static void createTimeLine(String communityId, String subjectId, 
			String urlArg, String titleArg, String textBody ) { 
			if(!Test.isRunningTest()){
				ConnectApi.FeedElement feedElemObj = FeedConnectAPIService.postFeedElementWithLinkCapability(communityId, 
				subjectId, 'record', urlArg, titleArg, textBody,'');
			}

	}  

    public static void createTimeLineAndClose(String communityId, String subjectId, 
			String urlArg, String titleArg, String textBody) { 
		ConnectApi.FeedElement feedElemObj = FeedConnectAPIService.postFeedElementWithLinkCapability(communityId, 
				subjectId, 'record', urlArg, titleArg, textBody,'');
        FeedConnectAPIService.closeFeedElement(null, feedElemObj.id);

	}  

   

	public static FeedElementPageWrapper getFeedElementsPage(String feedType, String subjectId, 
			String nextPageToken, String size, String sortBy, String origin) {
		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		Boolean isUnlistedSite = false;
		if ('record'.equalsIgnoreCase(feedType) && subjectId.startsWith('0F9')) {
			CollaborationGroup chatterGroupObj = new SiteDao().getChatterGroupDetails(subjectId);
			isUnlistedSite = 'Unlisted'.equalsIgnoreCase(chatterGroupObj.CollaborationType);
		}
		if (isUnlistedSite) {
			if (nextPageToken == null || String.isBlank(nextPageToken)) {
				nextPageToken = '0';
			}
			feedElementPageWrapObj = getUnlistedSiteFeedElementsPage(null, Integer.valueOf(size), Integer.valueOf(nextPageToken), sortBy, subjectId, origin);
		} else {
			ConnectApi.FeedElementPage feedElementPageObj = FeedConnectAPIService.getFeedElementsFromFeed(null,
					feedType, subjectId, nextPageToken, Integer.valueOf(size), sortBy);
			feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
		}
		
		if ((('record'.equalsIgnoreCase(feedType) && subjectId.startsWith('0F9') ) ||  
				'news'.equalsIgnoreCase(feedType) || 'company'.equalsIgnoreCase(feedType)) &&
				feedUtility.isContentGroupingRequired) {

                feedElementPageWrapObj = FeedGroupingService.groupFeedPage(feedElementPageWrapObj);			

		/*In case of content feed removing the timeline post from content feed*/
		} else if (('record'.equalsIgnoreCase(feedType) && 
				subjectId.startsWith(Utility.getSimpplrContentPrefix()))) {
			List<FeedElementWrapper> listOfFeedElemWrapTemp = new List<FeedElementWrapper>();

			for (FeedElementWrapper feedElemObj:feedElementPageWrapObj.listOfItems) {

				if (!'link'.equalsIgnoreCase(feedElemObj.postType)) {
					listOfFeedElemWrapTemp.add(feedElemObj);
				}
				
			}
			Simpplr_Content__c contentObj = ManageContentDao.getContentById(subjectId);
			if(contentObj != null && contentObj.Allow_comments__c == true) {
				feedElementPageWrapObj.postCount = Integer.valueOf(contentObj.Feed_Posts__c);
			}
			if(contentObj != null && contentObj.Question_Answer_Enabled__c == true) {
				feedElementPageWrapObj.questionCount = contentObj.Feed_Questions__c != null ? Integer.valueOf(contentObj.Feed_Questions__c) : 0;
			}

			feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
			feedElementPageWrapObj.listOfItems.addAll(listOfFeedElemWrapTemp);
			feedElementPageWrapObj.total = contentObj != null ? (Integer)contentObj.Feed_Posts__c : feedElementPageWrapObj.total;
		}

		feedElementPageWrapObj.sortBy = sortBy;
		feedElementPageWrapObj.type = feedType;
		return feedElementPageWrapObj;
	} 

	private static FeedElementPageWrapper getUnlistedSiteFeedElementsPage (String comumunityIdArg, 
		Integer recordLimit, Integer offset, String sortBy, 
		String subjectIdArg, String origin) {

		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
		List<String> listOfFeedId = new List<String>();
		FeedDao daoObj = new FeedDao(); 
		List<FeedItem> listOfFeedItems = daoObj.getUnlistedSiteTimelineContentAndFeedPosts(recordLimit + 1, offset,
			sortBy, subjectIdArg);

		for (FeedItem feedItemObj: listOfFeedItems) {
			listOfFeedId.add(feedItemObj.id);
		}

		List<ConnectAPI.FeedElement> listOfFeedElem = FeedConnectAPIService.getTimeLineFeed(null, listOfFeedId);

		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {	
			for (ConnectAPI.FeedElement feedElementObj: listOfFeedElem) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
			}
			FeedDataAdapter.getPeopleFromUserIds();
		}

		Map<Id, Simpplr_Site__c> siteIdDataMap = new Map<Id, Simpplr_Site__c>();
		List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(listOfFeedElem);
		siteChatterIdList.add(subjectIdArg);
		siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
		for (ConnectAPI.FeedElement feedElementObj: listOfFeedElem) {
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			
			if (feedElementWrapperObj.postType == 'link' && feedElementWrapperObj.postedOn != null && 
					(feedElementWrapperObj.postedOn.type == 'page' || 
					feedElementWrapperObj.postedOn.type == 'album' || 
					feedElementWrapperObj.postedOn.type == 'blogpost' || 
					feedElementWrapperObj.postedOn.type == 'event')) {
				feedElementWrapperObj.postType = 'timeline';
				feedElementWrapperObj.site = feedElementWrapperObj.postedOn.site;
				feedElementWrapperObj.body = null;
			}
			if(feedElementWrapperObj.postedOn == null || feedElementWrapperObj.postedOn.hidePost == null ||
				!feedElementWrapperObj.postedOn.hidePost) {

				feedElementPageWrapObj.listOfItems.add(feedElementWrapperObj);
			}
		}

		Integer nextPageToken;

		if (feedElementPageWrapObj.listOfItems.size() == (recordLimit + 1) && offset < 2000) {
			feedElementPageWrapObj.listOfItems.remove((feedElementPageWrapObj.listOfItems.size() - 1));
			nextPageToken = offset + recordLimit;	
		}
		
		feedElementPageWrapObj.nextPageToken = String.valueOf(nextPageToken);
		feedElementPageWrapObj.total = feedElementPageWrapObj.listOfItems.size(); 
		feedElementPageWrapObj.sortBy = sortBy; 
		feedElementPageWrapObj.timeStamp = String.valueOf(system.now().getTime());

		return 	feedElementPageWrapObj;
	}

	public static FeedElementPageWrapper getSingleFeedRecord(String postId, String feedType, 
			String sortBy, String size) {
		ConnectApi.FeedElement feedElementObj = FeedConnectAPIService.getFeedElement(null, postId, size);					
		FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
		List<String> feedElementIdsList = new List<String>();
		feedElementIdsList.add(feedElementObj.id);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			FeedDataAdapter.getUserIdsToConvert(feedElementObj);
			FeedDataAdapter.getPeopleFromUserIds();
		}
		Map<String, AIWrapper.ModerationDataWrapper> feedToModerationDataMap = new Map<String, AIWrapper.ModerationDataWrapper>();
		if(SimpplrContext.isContentModerationEnabled && SimpplrContext.aiContentModerationFeatureEnabled && feedElementIdsList != null && !feedElementIdsList.isEmpty()){
			AIDataProvider aIDataProviderObj = new AIDataProvider();
			feedToModerationDataMap = aIDataProviderObj.getModerationDataFromMS(feedElementIdsList);
		}

		if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c) ||
			ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS.equalsIgnoreCase(SimpplrContext.leadercastEnabledFor)){
			List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(new List<ConnectApi.FeedElement>{feedElementObj});
			Map<Id, Simpplr_Site__c> siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
			feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
		} else {
			feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
		}
		if (feedElementWrapperObj.site!=null) {
			List<Simpplr_Site__c> siteIdUdpateList = [select id from Simpplr_Site__c where Chatter_Group_Id__c = :feedElementWrapperObj.site.chatterGroupId and Is_Deleted__c = false WITH SECURITY_ENFORCED limit 1];
			if(siteIdUdpateList.size()>0){
				feedElementWrapperObj.site.siteId = siteIdUdpateList[0].id;
			}
		}
		Map<String, AIWrapper.ModerationMetaDataWrapper> commentsIdtoModerationStatusWrapperMap = new Map<String, AIWrapper.ModerationMetaDataWrapper>();
		if(SimpplrContext.aiContentModerationFeatureEnabled && !feedToModerationDataMap.isEmpty() && feedToModerationDataMap.containsKey(feedElementWrapperObj.id)){
			AIWrapper.ModerationDataWrapper moderationDataObj = (AIWrapper.ModerationDataWrapper)feedToModerationDataMap.get(feedElementWrapperObj.id);
			FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
			moderationResultObj.moderationStatus = moderationDataObj.moderationMetadata.moderationStatus;
			feedElementWrapperObj.moderationResult = moderationResultObj;
			if(feedElementWrapperObj.moderationResult.moderationStatus != null && 'removed'.equalsIgnoreCase(feedElementWrapperObj.moderationResult.moderationStatus)){
				feedElementWrapperObj.authoredBy = new PeopleLiteWrapper();
				feedElementWrapperObj.body = '';
				feedElementWrapperObj.listOfFiles = new List<FileWrapper>();
				feedElementWrapperObj.site = new SiteLiteWrapper();
			}
			List<AIWrapper.ModerationRepliesWrapper> moderationRepliesObjList = new List<AIWrapper.ModerationRepliesWrapper>();
			moderationRepliesObjList = moderationDataObj.replies.isEmpty() ? null : (List<AIWrapper.ModerationRepliesWrapper>)moderationDataObj.replies;
			if(moderationRepliesObjList != null){
				for(AIWrapper.ModerationRepliesWrapper wrapperObj: moderationRepliesObjList){
					commentsIdtoModerationStatusWrapperMap.put(wrapperObj.chatterReplyId, wrapperObj.moderationMetadata);
				}
			}
		}
		
		if (SimpplrContext.aiContentModerationFeatureEnabled && feedElementWrapperObj.recentComments != null && 
				feedElementWrapperObj.recentComments.listOfRecentComments != null &&
				!feedElementWrapperObj.recentComments.listOfRecentComments.isEmpty()) { // If external file is there in comment
			
			for (RecentCommentsWrapper commentWrapObj: feedElementWrapperObj.recentComments.listOfRecentComments) {
				
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

        if (feedElementWrapperObj.postType == 'link' && feedElementWrapperObj.postedOn != null && 
               (feedElementWrapperObj.postedOn.type == 'page' || 
               feedElementWrapperObj.postedOn.type == 'album' || 
               feedElementWrapperObj.postedOn.type == 'blogpost' || 
               feedElementWrapperObj.postedOn.type == 'event')) {
            feedElementWrapperObj.postType = 'timeline';
            feedElementWrapperObj.site = feedElementWrapperObj.postedOn.site;
        }

		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		feedElementPageWrapObj.nextPageToken = null;
		feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
		feedElementPageWrapObj.listOfItems.add(feedElementWrapperObj);
		feedElementPageWrapObj.total = 1; 
		feedElementPageWrapObj.sortBy = sortBy;
		feedElementPageWrapObj.type = feedType;	
        
		return 	feedElementPageWrapObj;
	}

	public static FeedElementPageWrapper getMultipleFeedRecords(List<String> postIdsList, String feedType, 
			String sortBy, String size) {

		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		feedElementPageWrapObj.nextPageToken = null;
		feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
		List<ConnectAPI.FeedElement> feedElementList = FeedConnectAPIService.getTimeLineFeed(null, postIdsList);
		for(ConnectAPI.FeedElement feedElementObj:feedElementList){		
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			List<String> feedElementIdsList = new List<String>();
			feedElementIdsList.add(feedElementObj.id);
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
				FeedDataAdapter.getPeopleFromUserIds();
			}
			Map<String, AIWrapper.ModerationDataWrapper> feedToModerationDataMap = new Map<String, AIWrapper.ModerationDataWrapper>();
			if(SimpplrContext.aiContentModerationFeatureEnabled && feedElementIdsList != null && !feedElementIdsList.isEmpty()){
				AIDataProvider aIDataProviderObj = new AIDataProvider();
				feedToModerationDataMap = aIDataProviderObj.getModerationDataFromMS(feedElementIdsList);
			}

			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c) ||
				ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS.equalsIgnoreCase(SimpplrContext.leadercastEnabledFor)){
				List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(new List<ConnectApi.FeedElement>{feedElementObj});
				Map<Id, Simpplr_Site__c> siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			} else {
				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
			}
			if (feedElementWrapperObj.site!=null) {
				List<Simpplr_Site__c> siteIdUdpateList = [select id from Simpplr_Site__c where Chatter_Group_Id__c = :feedElementWrapperObj.site.chatterGroupId and Is_Deleted__c = false WITH SECURITY_ENFORCED limit 1];
				if(siteIdUdpateList.size()>0){
					feedElementWrapperObj.site.siteId = siteIdUdpateList[0].id;
				}
			}
			Map<String, AIWrapper.ModerationMetaDataWrapper> commentsIdtoModerationStatusWrapperMap = new Map<String, AIWrapper.ModerationMetaDataWrapper>();
			if(SimpplrContext.aiContentModerationFeatureEnabled && !feedToModerationDataMap.isEmpty() && feedToModerationDataMap.containsKey(feedElementWrapperObj.id)){
				AIWrapper.ModerationDataWrapper moderationDataObj = (AIWrapper.ModerationDataWrapper)feedToModerationDataMap.get(feedElementWrapperObj.id);
				FeedElementWrapper.ModerationResult moderationResultObj = new FeedElementWrapper.ModerationResult();
				moderationResultObj.moderationStatus = moderationDataObj.moderationMetadata.moderationStatus;
				feedElementWrapperObj.moderationResult = moderationResultObj;
				if(feedElementWrapperObj.moderationResult.moderationStatus != null && 'removed'.equalsIgnoreCase(feedElementWrapperObj.moderationResult.moderationStatus)){
					feedElementWrapperObj.authoredBy = new PeopleLiteWrapper();
					feedElementWrapperObj.body = '';
					feedElementWrapperObj.listOfFiles = new List<FileWrapper>();
					feedElementWrapperObj.site = new SiteLiteWrapper();
				}
				List<AIWrapper.ModerationRepliesWrapper> moderationRepliesObjList = new List<AIWrapper.ModerationRepliesWrapper>();
				moderationRepliesObjList = moderationDataObj.replies.isEmpty() ? null : (List<AIWrapper.ModerationRepliesWrapper>)moderationDataObj.replies;
				if(moderationRepliesObjList != null){
					for(AIWrapper.ModerationRepliesWrapper wrapperObj: moderationRepliesObjList){
						commentsIdtoModerationStatusWrapperMap.put(wrapperObj.chatterReplyId, wrapperObj.moderationMetadata);
					}
				}
			}
			
			if (SimpplrContext.aiContentModerationFeatureEnabled && feedElementWrapperObj.recentComments != null && 
					feedElementWrapperObj.recentComments.listOfRecentComments != null &&
					!feedElementWrapperObj.recentComments.listOfRecentComments.isEmpty()) { // If external file is there in comment
				
				for (RecentCommentsWrapper commentWrapObj: feedElementWrapperObj.recentComments.listOfRecentComments) {
					
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

			if (feedElementWrapperObj.postType == 'link' && feedElementWrapperObj.postedOn != null && 
				(feedElementWrapperObj.postedOn.type == 'page' || 
				feedElementWrapperObj.postedOn.type == 'album' || 
				feedElementWrapperObj.postedOn.type == 'blogpost' || 
				feedElementWrapperObj.postedOn.type == 'event')) {
				feedElementWrapperObj.postType = 'timeline';
				feedElementWrapperObj.site = feedElementWrapperObj.postedOn.site;
			}
			feedElementPageWrapObj.listOfItems.add(feedElementWrapperObj);
		}
		
		feedElementPageWrapObj.total = feedElementPageWrapObj.listOfItems.size(); 
		feedElementPageWrapObj.sortBy = sortBy;
		feedElementPageWrapObj.type = feedType;	
        
		return 	feedElementPageWrapObj;
	}

	public static FeedElementPageWrapper getTimeLineFeedPage (String comumunityIdArg, 
				Integer recordLimit, Integer offset, String filterArg, String subjectIdArg) {
		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
		List<String> listOfFeedId = new List<String>();
        
		FeedDao daoObj = new FeedDao();
		List<Simpplr_Content__Feed> listOfTimeLineFeedItem = new List<Simpplr_Content__Feed>();
		listOfTimeLineFeedItem = daoObj.getTimeLineFeed(recordLimit, offset, filterArg, subjectIdArg);
		
		if (!listOfTimeLineFeedItem.isEmpty()) {
			
			for (Simpplr_Content__Feed feedItemObj: listOfTimeLineFeedItem) {
				listOfFeedId.add(feedItemObj.id);
			}

		}

		List<ConnectAPI.FeedElement> listOfFeedElem = FeedConnectAPIService.getTimeLineFeed(null, listOfFeedId);

		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			for (ConnectAPI.FeedElement feedElementObj : listOfFeedElem) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
			}
			FeedDataAdapter.getPeopleFromUserIds();	
		}

		Map<Id, Simpplr_Site__c> siteIdDataMap = new Map<Id, Simpplr_Site__c>();
		List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(listOfFeedElem);
		siteChatterIdList.add(subjectIdArg);
		siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
		for (ConnectAPI.FeedElement feedElementObj : listOfFeedElem) {
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			if(feedElementWrapperObj.postedOn == null || feedElementWrapperObj.postedOn.hidePost == null ||
				!feedElementWrapperObj.postedOn.hidePost) {
					
				feedElementWrapperObj.postType = 'timeline';
				feedElementWrapperObj.site = feedElementWrapperObj.postedOn.site;
				feedElementWrapperObj.body = null;
				feedElementPageWrapObj.listOfItems.add(feedElementWrapperObj);
			}
		}
        Integer nextPageToken;

        if (feedElementPageWrapObj.listOfItems.size() == (recordLimit + 1) && offset < 2000) {
            feedElementPageWrapObj.listOfItems.remove((feedElementPageWrapObj.listOfItems.size() - 1));
            nextPageToken = offset + recordLimit;	
        }

		feedElementPageWrapObj.nextPageToken = String.valueOf(nextPageToken);
		feedElementPageWrapObj.total = feedElementPageWrapObj.listOfItems.size(); 
		feedElementPageWrapObj.type = 'timeline';
        feedElementPageWrapObj.sortBy = 'date';
        feedElementPageWrapObj.timeStamp = String.valueOf(system.now().getTime());	 
		return 	feedElementPageWrapObj;
	}
 
	public static FeedElementPageWrapper getTimeLineAndContentFeedPage (String comumunityIdArg, 
				Integer recordLimit, Integer offset, String feedType, String sortBy, 
                String subjectIdArg, String origin) {
		FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
		List<String> listOfFeedId = new List<String>();
		FeedDao daoObj = new FeedDao(); 
		List<Object> listOfFeedInObjectContainer = new List<object>();
		listOfFeedInObjectContainer = daoObj.getTimeLineAndContentFeed(recordLimit + 1, offset, feedType, 
                sortBy, subjectIdArg);

		if (!listOfFeedInObjectContainer.isEmpty()) {
                
            for (Object genericFeedObj: listOfFeedInObjectContainer) {
                
                if (genericFeedObj instanceOf simpplr_content__feed) {
                    simpplr_content__feed contFeedItemObj = new simpplr_content__feed();
                    contFeedItemObj = (simpplr_content__feed)genericFeedObj;
                    listOfFeedId.add(contFeedItemObj.id);

                } else if (genericFeedObj instanceOf FeedItem) {
                    FeedItem feedItemObj = new FeedItem();
                    feedItemObj = (FeedItem)genericFeedObj;
                    listOfFeedId.add(feedItemObj.id);
                }
                
            }

        }

		List<ConnectAPI.FeedElement> listOfFeedElem = FeedConnectAPIService.getTimeLineFeed(null, listOfFeedId);

		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {	
			for (ConnectAPI.FeedElement feedElementObj: listOfFeedElem) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
			}
			FeedDataAdapter.getPeopleFromUserIds();
		}

		Map<Id, Simpplr_Site__c> siteIdDataMap = new Map<Id, Simpplr_Site__c>();
		List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(listOfFeedElem);
		siteChatterIdList.add(subjectIdArg);
		siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
		for (ConnectAPI.FeedElement feedElementObj: listOfFeedElem) {
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			
			if (feedElementWrapperObj.postType == 'link' && feedElementWrapperObj.postedOn != null && 
					(feedElementWrapperObj.postedOn.type == 'page' || 
					feedElementWrapperObj.postedOn.type == 'album' || 
					feedElementWrapperObj.postedOn.type == 'blogpost' || 
					feedElementWrapperObj.postedOn.type == 'event')) {
				feedElementWrapperObj.postType = 'timeline';
				feedElementWrapperObj.site = feedElementWrapperObj.postedOn.site;
				feedElementWrapperObj.body = null;
			}
			if(feedElementWrapperObj.postedOn == null || feedElementWrapperObj.postedOn.hidePost == null ||
				!feedElementWrapperObj.postedOn.hidePost) {

				feedElementPageWrapObj.listOfItems.add(feedElementWrapperObj);
			}
		}

		Integer nextPageToken;

		if (feedElementPageWrapObj.listOfItems.size() == (recordLimit + 1) && offset < 2000) {
			feedElementPageWrapObj.listOfItems.remove((feedElementPageWrapObj.listOfItems.size() - 1));
			nextPageToken = offset + recordLimit;	
		}
		
		feedElementPageWrapObj.nextPageToken = String.valueOf(nextPageToken);
		feedElementPageWrapObj.total = feedElementPageWrapObj.listOfItems.size(); 
		feedElementPageWrapObj.sortBy = sortBy;
		feedElementPageWrapObj.type = 'timeline_comment';	 
		feedElementPageWrapObj.timeStamp = String.valueOf(system.now().getTime());

		if ((('record'.equalsIgnoreCase(feedType) && subjectIdArg.startsWith('0F9') ) ||  
				'news'.equalsIgnoreCase(feedType) || 'company'.equalsIgnoreCase(feedType)) &&
				feedUtility.isContentGroupingRequired) {

				feedElementPageWrapObj = FeedGroupingService.groupFeedPage(feedElementPageWrapObj);
		} 

		if('mobile'.equalsIgnoreCase(origin) && 'record'.equalsIgnoreCase(feedType) && subjectIdArg.startsWith(Utility.getSimpplrContentPrefix())) {
			Simpplr_Content__c contentRecord = ManageContentDao.getContentById(subjectIdArg);
			if(contentRecord != null && contentRecord.Allow_comments__c == true) {
				feedElementPageWrapObj.postCount = Integer.valueOf(contentRecord.Feed_Posts__c);
			}
			if(contentRecord != null && contentRecord.Question_Answer_Enabled__c == true) {
				feedElementPageWrapObj.questionCount = contentRecord.Feed_Questions__c != null ? Integer.valueOf(contentRecord.Feed_Questions__c) : 0;
			}
		}


		return 	feedElementPageWrapObj;
	}

    public static FeedElementPageWrapper searchTimeLineAndContentFeed(String communityIdArg, 
            String feedTypeArg, String subjectIdArg , String pageParamArg, Integer pageSizeArg, 
            String searchStrArg, String sortParamArg) {
        FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
        ConnectApi.FeedElementPage feedElementPageObj;
        feedElementPageObj = FeedConnectAPIService.searchTimeLineAndContentFeed(communityIdArg, feedTypeArg, 
                subjectIdArg, pageParamArg, pageSizeArg, searchStrArg, sortParamArg);
        feedElementPageWrapObj = FeedDataAdapter.convertFeedElementPageToWrapper(feedElementPageObj);
        return feedElementPageWrapObj;
    }

    public static FeedElementPageWrapper searchTimeLineFeed(String feedTypeArg, 
            Integer offSet, Integer recordLimit, 
            String searchStrArg, String sortBy) {
        FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		feedElementPageWrapObj.listOfItems = new List<FeedElementWrapper>();
		List<String> listOfFeedId = new List<String>();
		FeedDao daoObj = new FeedDao();
		List<Simpplr_Content__Feed> listOfTimeLineFeedItem = new List<Simpplr_Content__Feed>();
		listOfTimeLineFeedItem = daoObj.searchTimeLineFeed(recordLimit, 
                offSet, feedTypeArg, sortBy, searchStrArg);
		
		if (!listOfTimeLineFeedItem.isEmpty()) {
			
			for (Simpplr_Content__Feed feedItemObj: listOfTimeLineFeedItem) {
				listOfFeedId.add(feedItemObj.id);
			}

		}

		List<ConnectAPI.FeedElement> listOfFeedElem = FeedConnectAPIService.getTimeLineFeed(null, listOfFeedId);	
		
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			for (ConnectAPI.FeedElement feedElementObj: listOfFeedElem) {
				FeedDataAdapter.getUserIdsToConvert(feedElementObj);
			}	
			FeedDataAdapter.getPeopleFromUserIds();	
		}

		Map<Id, Simpplr_Site__c> siteIdDataMap = new Map<Id, Simpplr_Site__c>();
		if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)){
			List<String> siteChatterIdList = FeedUtility.getChatterIdFromFeedElement(listOfFeedElem);
			siteIdDataMap = SiteService.getSiteDataMap(siteChatterIdList);
		}
		for (ConnectAPI.FeedElement feedElementObj: listOfFeedElem) {
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj, siteIdDataMap);
			
			if (feedElementWrapperObj.postType == 'link') {
				feedElementWrapperObj.postType = 'timeline';
				feedElementWrapperObj.site = feedElementWrapperObj.postedOn.site;
				feedElementWrapperObj.body = null;
			}
			
			feedElementPageWrapObj.listOfItems.add(feedElementWrapperObj);
		}

        Integer nextPageToken;

        if (feedElementPageWrapObj.listOfItems.size() == (recordLimit + 1) && offset < 2000) {
            feedElementPageWrapObj.listOfItems.remove((feedElementPageWrapObj.listOfItems.size() - 1));
            nextPageToken = offset + recordLimit;	
        }
		
		feedElementPageWrapObj.nextPageToken = String.valueOf(nextPageToken);
		feedElementPageWrapObj.total = feedElementPageWrapObj.listOfItems.size(); 
		feedElementPageWrapObj.sortBy = sortBy;
		feedElementPageWrapObj.type = 'timeline';	 
		
		return 	feedElementPageWrapObj;
	}
	
	public Map<String, Object> suggestTopics(String inputText) {
		List<TopicWrapper> topicList = new List<TopicWrapper>();
		Map<String, Object> responseBody = new Map<String, Object>();
		ConnectApi.TopicSuggestionPage  tspObj = ConnectApi.Topics.getTopicSuggestionsForText(null, inputText, 25);
		List<ConnectApi.TopicSuggestion> listOfTopicSuggestions = tspObj.TopicSuggestions;
		for(ConnectApi.TopicSuggestion tsObj : listOfTopicSuggestions){
			TopicWrapper topicObj = new TopicWrapper();
			if(tsObj.existingTopic != null){
				topicObj.topicId = tsObj.existingTopic.id;
				topicObj.topicName = tsObj.existingTopic.Name;
				
			} else if(UserContext.canCreateTopics){
				topicObj.topicId = '';
				topicObj.topicName = tsObj.Name;
			}
			topicList.add(topicObj);
		}
		responseBody.put('topicList', topicList);
		return responseBody;
	}

	public static void createTimeLineFeedForBroadcastSiteByAppModerators(String chatterGroupId, String subjectId, String urlArg, String titleArg, String textBody){
		Boolean isMember = true;
		SiteDao siteDaoObj = new siteDao();
		List<CollaborationGroupMember> groupMemberObjRecords = siteDaoObj.getCollaborationRoleUsingUserId(chatterGroupId, UserContext.id);
		if(groupMemberObjRecords==null || groupMemberObjRecords.size()==0){
			isMember = false;
		}
		if(isMember){
			//app moderator is a member of this site 
			if(groupMemberObjRecords[0].CollaborationRole == 'Admin'){
				createTimeLine(null, subjectId, urlArg, titleArg, textBody);
			}else{
				siteDaoObj.ToggleMemberManager(chatterGroupId, UserContext.id,'Admin');
				createTimeLine(null, subjectId, urlArg, titleArg, textBody);
				siteDaoObj.ToggleMemberManager(chatterGroupId, UserContext.id,groupMemberObjRecords[0].CollaborationRole);
			}
		}else{

			//app moderator is not a member of this site
			SiteDao.addMember(chatterGroupId, new List<String>{UserContext.id});
			siteDaoObj.ToggleMemberManager(chatterGroupId, UserContext.id,'Admin');
			createTimeLine(null, subjectId, urlArg, titleArg, textBody);
			siteDaoObj.removeMember(chatterGroupId, UserContext.id);
		}

	}

		
}