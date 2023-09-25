public with sharing class AIDataProvider {
    
	public static String loggedInUserId = UserContext.id;
    /**
	 * @description This method is used to call Content Moderation microservice and pass text to check for toxicity
	 * @param text
	 * @return `AIWrapper.CommentsToxicityWrapper`
	*/
	public AIWrapper.CommentsToxicityWrapper getToxicityDetails(String text) {
		logger.logDebug('AIDataProvider.getToxicityDetails() '+ text);
		AIWrapper.CommentsToxicityWrapper wrapperObj= new AIWrapper.CommentsToxicityWrapper();
		try{
			if(String.isNotBlank(text) && SimpplrContext.aiContentModerationEnabled && UserInfo.getLanguage()=='en_US'){
				Map<String, Object> requestBody = new Map<String, Object>();	
				requestBody.put('comment', text);
				
				HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/chatter/moderate', requestBody);
				
				String responseVal;
				if (res.getStatusCode() == 200) {
					responseVal = res.getBody();
				
				} else {
		
					logger.logError('AIDataProvider.getToxicityDetails()----status code----' + res.getStatusCode());
					throw new SimpplrException(String.valueOf(res.getStatusCode()));
				}
		
				Map<String, Object> resultBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
				
				wrapperObj.isToxic = Boolean.valueOf(resultBodyMap.get('isToxic'));
				wrapperObj.version = String.valueOf(resultBodyMap.get('version'));
                List<Object> cartegoriesList = (List<Object>)resultBodyMap.get('categories');
                List<string> cartegoriesStringList= new List<string> ();

                for(Object category: cartegoriesList){
                   cartegoriesStringList.add(String.valueOf(category));
                }
				wrapperObj.reasons = cartegoriesStringList;
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return wrapperObj;
    }

    /**
	 * @description This method is used to call Content Moderation microservice and send moderation info if content is toxic 
	 * @param reqBodyJson
	 * @param categories
	 * @param body
	*/
	@future(callout=true)
	public static void sendModerationInfo(String reqBodyJson, List<String> categories, String body) {
		
		logger.logDebug('AIDataProvider.sendModerationInfo()---requestBody-- '+ reqBodyJson + '---categories---' + categories);
		try{
			Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(reqBodyJson);
			requestBody.put('org_id', SimpplrContext.simpplrOrgId);
			ModerationMetaData moderationMetaDataObj = new ModerationMetaData();
			moderationMetaDataObj.reported_by = 'system';
			moderationMetaDataObj.report_reason = categories;
			DateTime currentDateTime = DateTime.now();
			moderationMetaDataObj.reported_on = String.valueOf(currentDateTime);
			moderationMetaDataObj.chatter_string = body;   
			moderationMetaDataObj.moderation_status = 'reported';
			requestBody.put('moderation_metadata', moderationMetaDataObj);
			HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/chatter/save', requestBody);
			if (res.getStatusCode() != 200) {
			    logger.logError('AIDataProvider.sendModerationInfo()----status code----' + res.getStatusCode());
				throw new SimpplrException(String.valueOf(res.getStatusCode()));
			}
		
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
    }

	@future(callout=true)
	public static void deleteNonToxicEditedContent(String id, String type){
		
		logger.logDebug('AIDataProvider.deleteNonToxicEditedContent()---id-- '+ id + '---type---' + type);
		try {
			Map<String, Object> requestMap = new Map<String, Object>();
			requestMap.put('org_id', SimpplrContext.simpplrOrgId);
			if(type.equalsIgnoreCase('feed')){
				requestMap.put('chatter_comment_id', id);
			}else if(type.equalsIgnoreCase('comment')){
				requestMap.put('chatter_reply_id', id);
			}
			HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/chatter/delete', requestMap);
			if (res.getStatusCode() != 200) {
			    logger.logError('AIDataProvider.deleteNonToxicEditedContent()----status code----' + res.getStatusCode());
				throw new SimpplrException(String.valueOf(res.getStatusCode()));
			}
		} catch (Exception e) {
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
	}
	public static void deleteNonToxicEditedContentList(List<String> chatterIdList){
		
		logger.logDebug('AIDataProvider.deleteNonToxicEditedContentList()---chatterIdList-- '+ chatterIdList);
		try {
			if(chatterIdList.isEmpty() && !SimpplrContext.aiContentModerationEnabled) {
				return;
			}
			Map<String, Object> requestMap = new Map<String, Object>();
			requestMap.put('org_id', SimpplrContext.simpplrOrgId);
			requestMap.put('chatter_comment_id_list', chatterIdList);
			HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/chatter/delete-list', requestMap);
			if (res.getStatusCode() != 200) {
			    logger.logError('AIDataProvider.deleteNonToxicEditedContentList()----status code----' + res.getStatusCode());
				throw new SimpplrException(String.valueOf(res.getStatusCode()));
			}
		} catch (Exception e) {
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
	}

	/**
	 * @description This method is used to MS to update moderation item status to dismissed
	 * @param moderationItemId
	 */
	public void markModerationItemDismissed(String moderationItemId, String type){
		logger.logDebug('AIDataProvider.markModerationItemDismissed()----moderationItemId'+moderationItemId);
		try {
			if(!SimpplrContext.aiContentModerationEnabled || !(UserContext.isContentModerator || UserContext.isUserAppModerator)){
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}
			
			if(!String.isBlank(moderationItemId)){
				Map<String, Object> requestMap = new Map<String, Object>();
				requestMap.put('moderation_item_id', moderationItemId);
				requestMap.put('moderator_id', UserContext.id);
				requestMap.put('moderation_item_type', type);
				requestMap.put('org_id', SimpplrContext.simpplrOrgId);
				HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/moderation/dismiss', requestMap);
				if (res.getStatusCode() != 200) {
					throw new SimpplrException(String.valueOf(res.getStatusCode()));
				}
			}else{
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}		
		} catch (Exception ex) {
			logger.logError(ex);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
	}
	public void sendReportedContentDetailsToMS(String reporterId, List<String> reportReason, String feedOrCommentId, String feedOrCommentText, String type){
		logger.logDebug('AIDataProvider.sendReportedContentDetailsToMS()-----'+'reporterId--'+reporterId+'--reportReason--'+reportReason+feedOrCommentId+'--feedOrCommentId--'+feedOrCommentText+'--feedOrCommentText--'+type+'--type--');
		try {
			if(!SimpplrContext.aiContentModerationEnabled){
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}
			Map<String, Object> requestDataMap = new Map<String, Object>();	
			ModerationMetaData moderationObj = new ModerationMetaData();
			moderationObj.reported_by = 'user';
			moderationObj.report_reason = reportReason.size()>0 ? reportReason : null;
			moderationObj.reporter_id = reporterId;
			moderationObj.moderation_status = 'reported';
			moderationObj.chatter_string = feedOrCommentText;
			Datetime currentDateTime = Datetime.now();
			moderationObj.reported_on = String.valueOf(currentDateTime);

			Map<String, Object> soqlParamMap = new Map<String, Object>();
			
			String parentType;
			String parentId;
			if (!String.isBlank(type) && type.equalsIgnoreCase('reply')) {
				requestDataMap.put('chatter_reply_id',feedOrCommentId);
				soqlParamMap.put('soqlParam1', feedOrCommentId);
				
				String feedCommentItemQuery = 'select createdById, CommentBody, FeedItemId from FeedComment where id=:soqlParam1 limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<FeedComment> feedCommentItemList = (List<FeedComment>)SIMPESAPI.accessController().queryAsUser(feedCommentItemQuery, soqlParamMap);
				String feedItemId;
				List<FeedItem> feedItemList = new List<FeedItem>();
				if(!feedCommentItemList.isEmpty()){
					requestDataMap.put('author_id',feedCommentItemList[0].createdById);
					feedItemId = feedCommentItemList[0].FeedItemId;
					soqlParamMap.put('soqlParam5', feedItemId);
					
					String feedItemQuery = 'Select id, createdById, parentId, parent.type from feeditem where id = :soqlParam5 limit 1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					feedItemList = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);
				}
				
				if(!feedItemList.isEmpty()){
					requestDataMap.put('parent_comment_id',feedItemList[0].id);
					parentType =  feedItemList[0].parentId!=null ? feedItemList[0].parent.type : '';
					parentId = feedItemList[0].parentId!=null ? feedItemList[0].parentId : '';
				}
			}else if(!String.isBlank(type) && type.equalsIgnoreCase('post')){
				requestDataMap.put('chatter_comment_id', feedOrCommentId);

				soqlParamMap.put('soqlParam3', feedOrCommentId); 
				String feedItemQuery = 'SELECT Id, ParentId, Parent.Type, CreatedById FROM FeedItem where Id =:soqlParam3 LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<FeedItem> feedItemList = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);
			
				if(!feedItemList.isEmpty()){
					requestDataMap.put('author_id',feedItemList[0].createdById);
					parentType =  feedItemList[0].parentId!=null ? feedItemList[0].parent.type : '';
					parentId = feedItemList[0].parentId;
				}
			}
			
			requestDataMap.put('org_id', SimpplrContext.simpplrOrgId);
			requestDataMap.put('moderation_metadata', moderationObj);
			
			if(!String.isBlank(parentId) && !String.isBlank(parentType) && parentType.equalsIgnoreCase(PageContext.namespacePrefix + 'Simpplr_Content__c')){
				requestDataMap.put('content_id',parentId);
				
				soqlParamMap.put('soqlParam2', parentId); 
				String query = 'SELECT Id, Site__c, Type__c FROM Simpplr_Content__c where Id =:soqlParam2 LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<simpplr_content__c> contentList = (List<simpplr_content__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

				if(!contentList.isEmpty()){
					requestDataMap.put('site_id',contentList[0].site__c);
					requestDataMap.put('content_type',contentList[0].Type__c);
				}
			}else if(!String.isBlank(parentId) && !String.isBlank(parentType) && parentType.equalsIgnoreCase('CollaborationGroup')){
                soqlParamMap.put('soqlParam4', parentId); 
				String query = 'SELECT Id from Simpplr_Site__c where Chatter_Group_Id__c = :soqlParam4 limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

                if(!siteList.isEmpty()) {
                   String siteId = siteList[0].Id;
				   requestDataMap.put('site_id',siteId);
                }
			}

			HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/chatter/save', requestDataMap);
			if (res.getStatusCode() != 200) {
				throw new SimpplrException(String.valueOf(res.getStatusCode()));
			}

		} catch (Exception ex) {
			logger.logError(ex);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
	}

	/**
	 * @description This method is used to MS to update moderation item status to removed
	 * @param moderationItemId
	 */
	public void markModerationItemRemoved(String moderationItemId, String type){
		logger.logDebug('AIDataProvider.markModerationItemRemoved()----moderationItemId'+moderationItemId);
		try {
			if(!SimpplrContext.aiContentModerationEnabled || !(UserContext.isContentModerator || UserContext.isUserAppModerator)){
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}
			
			if(!String.isBlank(moderationItemId)){
				Map<String, Object> requestMap = new Map<String, Object>();
				requestMap.put('moderation_item_id', moderationItemId);
				requestMap.put('moderator_id', UserContext.id);
				requestMap.put('moderation_item_type', type);
				requestMap.put('org_id', SimpplrContext.simpplrOrgId);
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', moderationItemId); 
				HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/moderation/remove', requestMap);
				if (res.getStatusCode() != 200) {
					throw new SimpplrException(String.valueOf(res.getStatusCode()));
				} else if('post'.equalsIgnoreCase(type)) {
					String feedItemQuery = 'SELECT Id, Body, LinkUrl FROM FeedItem where Id =:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<FeedItem> feedItemObj = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);
					ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo(feedItemObj[0].Body, moderationItemId, feedItemObj[0].LinkUrl, 'POST', true, false, false, true);    	
				} else if('reply'.equalsIgnoreCase(type)){
					String feedItemQuery = 'SELECT Id, CommentBody FROM FeedComment where Id =:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<FeedComment> feedItemObj = (List<FeedComment>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);
					ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo(feedItemObj[0].CommentBody, moderationItemId, null, 'REPLY', false, false, false, true);    	
				}
			}else{
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}		
		} catch (Exception ex) {
			logger.logError(ex);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
	}


	/**
	 * @description This method is used to get moderation details of feed post/comments/replies
	 * @param feedElementIdsList
	 * @return `AIWrapper.ModerationDataWrapper`
	*/
	public Map<String, AIWrapper.ModerationDataWrapper> getModerationDataFromMS(List<String> feedElementIdsList) {
		logger.logDebug('AIDataProvider.getModerationDataFromMS()---'+ feedElementIdsList);
		Map<String, AIWrapper.ModerationDataWrapper> feedToModerationDataMap = new Map<String, AIWrapper.ModerationDataWrapper>();
		try{
			if(feedElementIdsList != null && !feedElementIdsList.isEmpty()){ //SimpplrContext.aiContentModerationEnabled && 
				Map<String, Object> requestBody = new Map<String, Object>();	
				requestBody.put('chatterIdList', feedElementIdsList);
				requestBody.put('org_id', SimpplrContext.simpplrOrgId);
				
				HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/chatter/list', requestBody);
				
				String responseVal;
				if (res.getStatusCode() == 200) {
					responseVal = res.getBody();
				} else {
					logger.logError('AIDataProvider.getModerationDataFromMS()----status code----' + res.getStatusCode());
					throw new SimpplrException(String.valueOf(res.getStatusCode()));
				}
				if(String.isNotBlank(responseVal)){
					Map<String, Object> resultBodyMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
					feedToModerationDataMap = processResponseBody(resultBodyMap);
				}
			}
		}catch(Exception e){
			logger.logError(e);
			if(!Test.isRunningTest()) {
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}
		}
		logger.logDebug('AIDataProvider.feedToModerationDataMap()---'+ feedToModerationDataMap);
		return feedToModerationDataMap;
    }

	private Map<String, AIWrapper.ModerationDataWrapper> processResponseBody(Map<String, Object> resultBodyMap) {
		Map<String, AIWrapper.ModerationDataWrapper> feedToModerationDataMap = new Map<String, AIWrapper.ModerationDataWrapper>();
		List<Object> listOfModerationObjects = (List<Object>)resultBodyMap.get('moderationResults');
		for(Object result:listOfModerationObjects){

			AIWrapper.ModerationDataWrapper moderationDataObj = new AIWrapper.ModerationDataWrapper();
			Map<String,Object> mapOfParams = (Map<String,Object>)result;
			moderationDataObj.chatterCommentId = (String)mapOfParams.get('chatter_comment_id');
			Object moderationMetaObj = (Object)mapOfParams.get('moderation_metadata');
			Map<String,Object> moderationMetaValuesMap = (Map<String,Object>)moderationMetaObj;
			if(!moderationMetaValuesMap.isEmpty() && moderationMetaValuesMap.containsKey('moderation_status')){
				AIWrapper.ModerationMetaDataWrapper wrapperObj = new AIWrapper.ModerationMetaDataWrapper();
				wrapperObj.moderationStatus = (String)moderationMetaValuesMap.get('moderation_status');
				moderationDataObj.moderationMetadata = wrapperObj;
			}
			List<Object> listOfRepliesObjects = (List<Object>)mapOfParams.get('replies');
			List<AIWrapper.ModerationRepliesWrapper> moderationRepliesObjList = new List<AIWrapper.ModerationRepliesWrapper>();
			for(Object repliesObj : listOfRepliesObjects){
				AIWrapper.ModerationRepliesWrapper moderationRepliesObj = new AIWrapper.ModerationRepliesWrapper();
				Map<String,Object> moderationRepliesMap = (Map<String,Object>)repliesObj;
				moderationRepliesObj.chatterReplyId = (String)moderationRepliesMap.get('chatter_reply_id');
				Object moderationRepliesMetaObj = (Object)moderationRepliesMap.get('moderation_metadata');
				Map<String,Object> moderationMetaObjMap = (Map<String,Object>)moderationRepliesMetaObj;
				if(!moderationMetaObjMap.isEmpty() && moderationMetaObjMap.containsKey('moderation_status')){
					AIWrapper.ModerationMetaDataWrapper wrapperObj = new AIWrapper.ModerationMetaDataWrapper();
					wrapperObj.moderationStatus = (String)moderationMetaObjMap.get('moderation_status');
					moderationRepliesObj.moderationMetadata = wrapperObj;
				}
				moderationRepliesObjList.add(moderationRepliesObj);
			}
			moderationDataObj.replies = moderationRepliesObjList;
			feedToModerationDataMap.put(moderationDataObj.chatterCommentId, moderationDataObj);
		}
		return feedToModerationDataMap;
    }

	/**
	 * @description This method is used to get Moderation Queue Details
	 * @param requestDataMap
	 * @return `AIWrapper.ModerationQueueWrapper`
	*/
	public AIWrapper.ModerationQueueWrapper getModerationQueue(Map<String, Object> requestDataMap) {
		logger.logDebug('AIDataProvider.getModerationQueue() '+ requestDataMap);
		AIWrapper.ModerationQueueWrapper moderationQueueWrapObj = new AIWrapper.ModerationQueueWrapper();
		try{
			moderationQueueWrapObj.listOfItems = new List<AIWrapper.ModerationQueueItem>();
			Map<String,Object> moderationQueueDetailsMap = getModerationQueueDetailsFromMS(requestDataMap);
			Set<String> siteIdsList = new Set<String>();
			Set<String> contentIdsList = new Set<String>();
			Set<String> authorIdsList = new Set<String>();
			Set<String> reporterPeopleIdsList = new Set<String>();
			Map<String, AIWrapper.ModerationQueueItem> postIdVsModerationItemMap = new Map<String, AIWrapper.ModerationQueueItem>();
			Map<String, AIWrapper.ModerationQueueItem> replyIdVsModerationItemMap = new Map<String, AIWrapper.ModerationQueueItem>();
			List<Object> listOfChatterObjects = (List<Object>)moderationQueueDetailsMap.get('chatterList');
			for(Object result:listOfChatterObjects){
				Map<String,Object> mapOfParams = (Map<String,Object>)result;
				String chatterReplyId = mapOfParams.containsKey('chatter_reply_id') && mapOfParams.get('chatter_reply_id') != null ? (String)mapOfParams.get('chatter_reply_id') : null;	
				String chatterCommentId = mapOfParams.containsKey('chatter_comment_id') && mapOfParams.get('chatter_comment_id') != null ? (String)mapOfParams.get('chatter_comment_id') : null;
				Object moderationMetadata = mapOfParams.containsKey('moderation_metadata') && mapOfParams.get('moderation_metadata') != null ? mapOfParams.get('moderation_metadata') : null;
				String siteId = mapOfParams.containsKey('site_id') && mapOfParams.get('site_id') != null ? (String)mapOfParams.get('site_id') : null;
				String contentId = mapOfParams.containsKey('content_id') && mapOfParams.get('content_id') != null ? (String)mapOfParams.get('content_id') : null;	
				String authorId = mapOfParams.containsKey('author_id') && mapOfParams.get('author_id') != null ? (String)mapOfParams.get('author_id') : null;	
				if(String.isNotBlank(siteId)){
					siteIdsList.add(siteId);
				}
				if(String.isNotBlank(contentId)){
					contentIdsList.add(contentId);
				}
				if(String.isNotBlank(authorId)){
					authorIdsList.add(authorId);
				}
				Map<String,Object> mapOfModerationData = (Map<String,Object>)moderationMetadata;
				AIWrapper.ModerationQueueItem moderationQueueItemObj = new AIWrapper.ModerationQueueItem();
				List<Object> reasonsList = new List<Object>();
				if(mapOfModerationData.containsKey('report_reason')){
					reasonsList = (List<Object>)mapOfModerationData.get('report_reason');	
				}
				moderationQueueItemObj.reportReason = reasonsList;
				moderationQueueItemObj.reportedBy = mapOfModerationData.containsKey('reported_by') && mapOfModerationData.get('reported_by') != null ? (String)mapOfModerationData.get('reported_by') : '';	
				moderationQueueItemObj.reporterId = mapOfModerationData.containsKey('reporter_id') && mapOfModerationData.get('reporter_id') != null ? (String)mapOfModerationData.get('reporter_id') : '';	
				moderationQueueItemObj.reportedOn = mapOfModerationData.containsKey('reported_on') && mapOfModerationData.get('reported_on') != null ? (String)mapOfModerationData.get('reported_on') : '';	
				if(String.isNotBlank(chatterReplyId)){
					moderationQueueItemObj.type = 'reply';
					replyIdVsModerationItemMap.put(chatterReplyId, moderationQueueItemObj);
				}else if(String.isNotBlank(chatterCommentId)){
					moderationQueueItemObj.type = 'post';
					postIdVsModerationItemMap.put(chatterCommentId, moderationQueueItemObj);
				}
				if('user'.equalsIgnoreCase(moderationQueueItemObj.reportedBy) && String.isNotBlank(moderationQueueItemObj.reporterId)){
					reporterPeopleIdsList.add(moderationQueueItemObj.reporterId);
				}
			}
			Map<String, SiteListingWrapper> siteIdVsSiteWrapperMap = new Map<String, SiteListingWrapper>();
			Map<String, AIWrapper.ContentLiteWrapper> contentIdVsContentWrapperMap = new Map<String, AIWrapper.ContentLiteWrapper>();
			Map<String, PeopleLiteWrapper> authorIdVsPeopleWrapperMap = new Map<String, PeopleLiteWrapper>();
			Map<String, PeopleLiteWrapper> reporterPeopleIdVsPeopleWrapperMap = new Map<String, PeopleLiteWrapper>();
			if(!siteIdsList.isEmpty()){
				siteIdVsSiteWrapperMap = getSiteInformation(siteIdsList);
			}
			if(!contentIdsList.isEmpty()){
				contentIdVsContentWrapperMap = getContentInformation(contentIdsList);
			}
			if(!authorIdsList.isEmpty()){
				authorIdVsPeopleWrapperMap = getAuthorInformation(authorIdsList);
			}
			if(!reporterPeopleIdsList.isEmpty()){
				reporterPeopleIdVsPeopleWrapperMap = getReporterInformation(reporterPeopleIdsList);
			}
			Map<String,AIWrapper.ModerationQueueItem> feedIdVsModerationQueueItemMap = new Map<String,AIWrapper.ModerationQueueItem>();
			if(!postIdVsModerationItemMap.isEmpty()){
				feedIdVsModerationQueueItemMap = getFeedInformationForIds(postIdVsModerationItemMap);
			}
			Map<String,AIWrapper.ModerationQueueItem> replyIdVsModerationQueueItemMap = new Map<String,AIWrapper.ModerationQueueItem>();
			if(!replyIdVsModerationItemMap.isEmpty()){
				replyIdVsModerationQueueItemMap = getReplyInformationForIds(replyIdVsModerationItemMap);
			}
			
			for(Object result:listOfChatterObjects){ // Sorting data in same order received from MS
				Map<String,Object> mapOfParams = (Map<String,Object>)result;
				String chatterReplyId = mapOfParams.containsKey('chatter_reply_id') && mapOfParams.get('chatter_reply_id') != null ? (String)mapOfParams.get('chatter_reply_id') : null;	
				String chatterCommentId = mapOfParams.containsKey('chatter_comment_id') && mapOfParams.get('chatter_comment_id') != null ? (String)mapOfParams.get('chatter_comment_id') : null;	
				String siteId = mapOfParams.containsKey('site_id') && mapOfParams.get('site_id') != null ? (String)mapOfParams.get('site_id') : null;
				String contentId = mapOfParams.containsKey('content_id') && mapOfParams.get('content_id') != null ? (String)mapOfParams.get('content_id') : null;	
				String authorId = mapOfParams.containsKey('author_id') && mapOfParams.get('author_id') != null ? (String)mapOfParams.get('author_id') : null;	
				AIWrapper.ModerationQueueItem moderationQueueItemObj = new AIWrapper.ModerationQueueItem();
				if(String.isNotBlank(chatterReplyId) && replyIdVsModerationQueueItemMap.containsKey(chatterReplyId) && replyIdVsModerationQueueItemMap.get(chatterReplyId) != null){
					moderationQueueItemObj = replyIdVsModerationQueueItemMap.get(chatterReplyId);
				}else if(String.isNotBlank(chatterCommentId) && feedIdVsModerationQueueItemMap.containsKey(chatterCommentId) && feedIdVsModerationQueueItemMap.get(chatterCommentId) != null){
					moderationQueueItemObj = feedIdVsModerationQueueItemMap.get(chatterCommentId);
				}
				moderationQueueItemObj.site = String.isNotBlank(siteId) && siteIdVsSiteWrapperMap.containsKey(siteId) && siteIdVsSiteWrapperMap.get(siteId) != null ? siteIdVsSiteWrapperMap.get(siteId) : null;
				moderationQueueItemObj.content = String.isNotBlank(contentId) && contentIdVsContentWrapperMap.containsKey(contentId) && contentIdVsContentWrapperMap.get(contentId) != null ? contentIdVsContentWrapperMap.get(contentId) : null;
				if(moderationQueueItemObj.content != null){
					moderationQueueItemObj.contentId = moderationQueueItemObj.content.id;
					moderationQueueItemObj.contentTitle = moderationQueueItemObj.content.title;
					moderationQueueItemObj.publishAt = moderationQueueItemObj.content.publishAt;
				}
				moderationQueueItemObj.authoredBy = String.isNotBlank(authorId) && authorIdVsPeopleWrapperMap.containsKey(authorId) && authorIdVsPeopleWrapperMap.get(authorId) != null ? authorIdVsPeopleWrapperMap.get(authorId) : null;
				if('user'.equalsIgnoreCase(moderationQueueItemObj.reportedBy) && String.isNotBlank(moderationQueueItemObj.reporterId)){
					moderationQueueItemObj.reporterDetails = (!reporterPeopleIdVsPeopleWrapperMap.isEmpty() && reporterPeopleIdVsPeopleWrapperMap.containsKey(moderationQueueItemObj.reporterId)) ? reporterPeopleIdVsPeopleWrapperMap.get(moderationQueueItemObj.reporterId) : null;
				}
				moderationQueueWrapObj.nextPageToken = moderationQueueDetailsMap.containsKey('next_page_token') && moderationQueueDetailsMap.get('next_page_token') != null ? String.valueOf(moderationQueueDetailsMap.get('next_page_token')) : null;	
				moderationQueueWrapObj.listOfItems.add(moderationQueueItemObj);
			}
			
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return moderationQueueWrapObj;
    }

	/**
	 * @description This method is used to call Content Moderation microservice for moderation queue details
	 * @param requestDataMap
	 * @return `Map<String,Object>`
	*/
	public Map<String,Object> getModerationQueueDetailsFromMS(Map<String, Object> requestDataMap) {
		logger.logDebug('AIDataProvider.getModerationQueueDetailsFromMS() '+ requestDataMap);
		Map<String,Object> moderationQueueDataMap = new Map<String,Object>();
		try{
			Integer size = (requestDataMap!= null && requestDataMap.containsKey('size')) ? Integer.valueOf(requestDataMap.get('size')) : 16;
			String sortBy = (requestDataMap!= null && requestDataMap.containsKey('sortBy')) ? String.valueOf(requestDataMap.get('sortBy')) : 'OldestFirst';
			String origin = (requestDataMap!= null && requestDataMap.containsKey('origin')) ? String.valueOf(requestDataMap.get('origin')) : 'all';
			String reporter = (requestDataMap!= null && requestDataMap.containsKey('reporter')) ? String.valueOf(requestDataMap.get('reporter')) : 'all';
			String site = (requestDataMap!= null && requestDataMap.containsKey('site')) ? String.valueOf(requestDataMap.get('site')) : 'all';
			String type = (requestDataMap!= null && requestDataMap.containsKey('type')) ? String.valueOf(requestDataMap.get('type')) : 'all';
			Integer nextPageToken = (requestDataMap!= null && requestDataMap.containsKey('nextPageToken')) ? Integer.valueOf(requestDataMap.get('nextPageToken')) : null;
			Map<String, Object> requestBody = new Map<String, Object>();	
			requestBody.put('size', size);
			requestBody.put('sort_by', sortBy);
			requestBody.put('origin', origin);
			requestBody.put('reporter', reporter);
			requestBody.put('site', site);
			requestBody.put('type', type);
			requestBody.put('next_page_token', nextPageToken);
			requestBody.put('org_id', SimpplrContext.simpplrOrgId);
			if(UserContext.hasModifyAllDataPermission){
				requestBody.put('has_all_sites_access', true);
			}else{
				String query = 'select id from CollaborationGroup where id IN (select CollaborationGroupId from CollaborationGroupMember where memberId=:loggedInUserId) and CollaborationType!=\'Public\'';
				if(SimpplrContext.isCommunitiesEnabled){
					query = query+' AND NetworkId = null';
				}
				Map<String,CollaborationGroup> groupMap = new Map<String,CollaborationGroup>((List<CollaborationGroup>)Database.query(query));
				if(UserContext.hasManageUnlistedSitePermission){
					groupMap.putAll([select id from CollaborationGroup where CollaborationType = 'Unlisted']);
				}
				Map<String,Simpplr_Site__c> siteMap = new Map<String,Simpplr_Site__c>([select id from Simpplr_Site__c where Chatter_Group_Id__c IN:groupMap.keySet() OR Site_Type__c = 'Public']);
				requestBody.put('has_all_sites_access', false);
				requestBody.put('site_id_list', siteMap.keySet());
			}
			HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/moderation/queues', requestBody);
			
			String responseVal;
			if (res.getStatusCode() == 200) {
				responseVal = res.getBody();
			} else {
				logger.logError('AIDataProvider.getModerationDataFromMS()----status code----' + res.getStatusCode());
				throw new SimpplrException(String.valueOf(res.getStatusCode()));
			}
			if(String.isNotBlank(responseVal)){
				moderationQueueDataMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		logger.logDebug('AIDataProvider.getModerationQueueDetailsFromMS()---'+ moderationQueueDataMap);
		return moderationQueueDataMap;
    }

	/**
	 * @description This method is used to get information for feedIds 
	 * @param postIdVsModerationItemMap
	 * @return `Map<String,AIWrapper.ModerationQueueItem>`
	*/
	public Map<String,AIWrapper.ModerationQueueItem> getFeedInformationForIds(Map<String, AIWrapper.ModerationQueueItem> postIdVsModerationItemMap){
		logger.logDebug('AIDataProvider.getFeedInformationForIds() '+ postIdVsModerationItemMap);
		Map<String,AIWrapper.ModerationQueueItem> feedIdVsModerationQueueItemMap = new Map<String,AIWrapper.ModerationQueueItem>();
		try{
			if(!postIdVsModerationItemMap.isEmpty()){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', postIdVsModerationItemMap.keySet()); 
				String feedItemQuery = 'SELECT ParentId, Id, CreatedDate, Type, Body, InsertedById, Status FROM FeedItem WHERE Id IN : soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<FeedItem> feedItemList = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedItemQuery, soqlParamMap);
				if(!feedItemList.isEmpty()){
					for(FeedItem feedItemObj: feedItemList){
						AIWrapper.ModerationQueueItem moderationQueueItemObj = postIdVsModerationItemMap.get(feedItemObj.Id);
						moderationQueueItemObj.body = feedItemObj.Body;
						String dateStringValue = String.valueOf(feedItemObj.CreatedDate);
						if (String.isNotBlank(dateStringValue)) { 
							moderationQueueItemObj.createdAt = Utility.dateTimeToMomentJSDateTime(feedItemObj.CreatedDate);
						}
						moderationQueueItemObj.timeStamp = String.valueOf(system.now().getTime());
						moderationQueueItemObj.id = feedItemObj.id;
						moderationQueueItemObj.postType = 'post';
						moderationQueueItemObj.listOfMentions = new List<MentionWrapper>();
						moderationQueueItemObj.url = PageContext.getPageURL(Pages.app)+'?u=/feed/'+feedItemObj.Id;
						feedIdVsModerationQueueItemMap.put(feedItemObj.id, moderationQueueItemObj);
					}
				}	
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return feedIdVsModerationQueueItemMap;
    }
	
	/**
	 * @description This method is used to get information for replyIds 
	 * @param replyIdVsModerationItemMap
	 * @return `Map<String,AIWrapper.ModerationQueueItem>`
	*/
	public Map<String,AIWrapper.ModerationQueueItem> getReplyInformationForIds(Map<String, AIWrapper.ModerationQueueItem> replyIdVsModerationItemMap){
		logger.logDebug('AIDataProvider.getReplyInformationForIds() '+ replyIdVsModerationItemMap);
		Map<String,AIWrapper.ModerationQueueItem> replyIdVsModerationQueueItemMap = new Map<String,AIWrapper.ModerationQueueItem>();
		try{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', replyIdVsModerationItemMap.keySet()); 
			String feedCommentQuery = 'SELECT Id, FeedItemId, ParentId, CreatedById, CreatedDate, CommentBody, IsDeleted, InsertedById, CommentType FROM FeedComment WHERE Id IN : soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<FeedComment> feedCommentList = (List<FeedComment>)SIMPESAPI.accessController().queryAsUser(feedCommentQuery, soqlParamMap);
			if(!feedCommentList.isEmpty()){
				for(FeedComment feedCommentObj: feedCommentList){
					AIWrapper.ModerationQueueItem moderationQueueItemObj = replyIdVsModerationItemMap.get(feedCommentObj.Id);
					moderationQueueItemObj.body = feedCommentObj.CommentBody;
					String dateStringValue = String.valueOf(feedCommentObj.CreatedDate);
					if (String.isNotBlank(dateStringValue)) { 
						moderationQueueItemObj.createdAt = Utility.dateTimeToMomentJSDateTime(feedCommentObj.CreatedDate);
					}
					moderationQueueItemObj.timeStamp = String.valueOf(system.now().getTime());
					moderationQueueItemObj.id = feedCommentObj.id;
					moderationQueueItemObj.postType = 'reply';
					moderationQueueItemObj.listOfMentions = new List<MentionWrapper>();
					moderationQueueItemObj.url = PageContext.getPageURL(Pages.app)+'?u=/feed/'+feedCommentObj.ParentId;
					replyIdVsModerationQueueItemMap.put(feedCommentObj.id, moderationQueueItemObj);
				}
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return replyIdVsModerationQueueItemMap;
	}
		
	/**
	 * @description This method is used to get information for sites 
	 * @param siteIdsList
	 * @return `Map<String,SiteListingWrapper>`
	*/
	public Map<String,SiteListingWrapper> getSiteInformation(Set<String> siteIdsList){
		logger.logDebug('AIDataProvider.getSiteInformation()--'+ siteIdsList);
		Map<String, SiteListingWrapper> siteIdVsSiteWrapperMap = new Map<String, SiteListingWrapper>();
		try{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteIdsList); 
			String siteQuery = 'SELECT Id, Chatter_Group_Id__c, Name, Is_Active__c, Site_Type__c, Title_Content_Version__c, '
					+ 'Site_Category__r.Name__c, Site_Category__r.Id from simpplr_site__c where Id IN:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_site__c> siteObjectList = (List<simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);
			if(!siteObjectList.isEmpty()){
				for(Simpplr_Site__c siteObj: siteObjectList){
					SiteListingWrapper siteListingWrapperObj = new SiteListingWrapper();
					siteListingWrapperObj.chatterGroupId = siteObj.Chatter_Group_Id__c;
					siteListingWrapperObj.siteId = siteObj.Id;
					siteListingWrapperObj.isPrivate = siteObj.Site_Type__c.equalsIgnoreCase('Private');
					siteListingWrapperObj.isListed = siteObj.Site_Type__c.equalsIgnoreCase('Private') || siteObj.Site_Type__c.equalsIgnoreCase('Public');
					siteListingWrapperObj.isActivated = siteObj.Is_Active__c;
					siteListingWrapperObj.isMember = UserContext.chatterGroupsIFollowIdSet.contains(siteListingWrapperObj.chatterGroupId);
					Map<String, String> args = new Map<String, String>();
					args.put('pageToRedirect', ServiceConstants.SITE_LANDING_PAGE_STRING);
					args.put('chatterGroupId', siteListingWrapperObj.chatterGroupId);
					String linkUrl = PageContext.getPageURL(Pages.PageRedirector, args);
					siteListingWrapperObj.Url = linkUrl;
					siteListingWrapperObj.img = String.isBlank(siteObj.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(siteObj.Title_Content_Version__c);
	        		siteListingWrapperObj.imgThumbnail = String.isBlank(siteObj.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(siteObj.Title_Content_Version__c);
					siteListingWrapperObj.access = siteObj.site_type__c;
					siteListingWrapperObj.name = siteObj.Name;
					siteListingWrapperObj.category = new SiteListingWrapper.CategoryWrapper();
					siteListingWrapperObj.category.id = siteObj.Site_Category__r.Id;
					siteListingWrapperObj.category.name = siteObj.Site_Category__r.Name__c;
					siteListingWrapperObj.category.url = PageContext.getPageURL(Pages.app)+'?u=/sites/category&category='+siteObj.Site_Category__r.Id;
					siteIdVsSiteWrapperMap.put(siteListingWrapperObj.siteId, siteListingWrapperObj);
				}
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}			
		return siteIdVsSiteWrapperMap;
    }

	/**
	 * @description This method is used to get information for contents 
	 * @param contentIdsList
	 * @return `Map<String,AIWrapper.ContentLiteWrapper>`
	*/
	public Map<String,AIWrapper.ContentLiteWrapper> getContentInformation(Set<String> contentIdsList){
		logger.logDebug('AIDataProvider.getContentInformation()--'+ contentIdsList);
		Map<String, AIWrapper.ContentLiteWrapper> contentIdVsContentWrapperMap = new Map<String, AIWrapper.ContentLiteWrapper>();
		try{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', contentIdsList); 
			String contentQuery = 'SELECT Id, Site__c, Title__c, Type__c, First_Publish_DateTime__c, Primary_Author__c, '
							+ '(SELECT Id, Content_Version__c, Content_Document__c, Is_Title_Image__c, Mime_Type__c, Title_Image_Type__c, Thumbnail_URL__c '+
							+ 'FROM File_Simpplr_Content__r WHERE Is_Deleted__c = false AND Location__c in (\'cover\' , \'media\') ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, Order__c desc LIMIT 4) '+
							+ 'FROM Simpplr_Content__c where Id IN:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<simpplr_content__c> contentObjectList = (List<simpplr_content__c>)SIMPESAPI.accessController().queryAsUser(contentQuery, soqlParamMap);
			if(!contentObjectList.isEmpty()){
				for(Simpplr_Content__c contentObj: contentObjectList){
					AIWrapper.ContentLiteWrapper contentLiteWrapperObj = new AIWrapper.ContentLiteWrapper();
					contentLiteWrapperObj.type = contentObj.Type__c;
					contentLiteWrapperObj.id = contentObj.Id;
					contentLiteWrapperObj.title = contentObj.Title__c;
					String dateStringValue = String.valueOf(contentObj.First_Publish_DateTime__c);
					if (String.isNotBlank(dateStringValue)) { 
						contentLiteWrapperObj.publishAt = Utility.dateTimeToMomentJSDateTime(contentObj.First_Publish_DateTime__c);
					}
					if (ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentObj.Type__c)){
						contentLiteWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + contentObj.site__c + '/page/' + contentObj.Id+'&origin=moderation_queue';                                          
					} else if (ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentObj.Type__c)) {
						contentLiteWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentObj.Primary_Author__c + '/blog/' + contentObj.id+'&origin=moderation_queue';                                          
			
					} else if (ServiceConstants.TYPE_EVENT.equalsIgnoreCase(contentObj.Type__c)) {
						contentLiteWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + contentObj.site__c + '/event/' + contentObj.Id+'&origin=moderation_queue';
						
					} else if (ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)){
						contentLiteWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + contentObj.site__c + '/album/' + contentObj.Id+'&origin=moderation_queue';                                           
					}
					List<File__c> titleFilesList = contentObj.File_Simpplr_Content__r;
					if (titleFilesList.size() > 0) {
        				for (File__c fileObj : titleFilesList) {
							if (ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)) {
								if (fileObj.Is_Title_Image__c) {
									if (String.isNotBlank(fileObj.Content_Version__c)) {
										contentLiteWrapperObj.img = Utility.getFileDownloadURLFor240BY180(fileObj.Content_Version__c);
										contentLiteWrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
									} else {
										contentLiteWrapperObj.img = fileObj.Thumbnail_URL__c;
										contentLiteWrapperObj.imgLandscape = fileObj.Thumbnail_URL__c;
									}
									break;
								}
							} else {
								if (fileObj.Title_Image_Type__c == 'Thumbnail' && fileObj.Is_Title_Image__c) {
									contentLiteWrapperObj.img = Utility.getFileDownloadURLFor240BY180(fileObj.Content_Version__c);
								} else if (fileObj.Title_Image_Type__c == 'WideScreen' && fileObj.Is_Title_Image__c) {
											contentLiteWrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
								}
							}
						}
					}
					contentIdVsContentWrapperMap.put(contentLiteWrapperObj.id, contentLiteWrapperObj);
				}
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}		
		return contentIdVsContentWrapperMap;
    }

	/**
	 * @description This method is used to get information for authors 
	 * @param authorIdSet
	 * @return `Map<String,PeopleLiteWrapper>`
	*/
	public Map<String,PeopleLiteWrapper> getAuthorInformation(Set<String> authorIdSet){
		logger.logDebug('AIDataProvider.getAuthorInformation()--'+ authorIdSet);
		Map<String, PeopleLiteWrapper> authorIdVsPeopleWrapperMap = new Map<String, PeopleLiteWrapper>();
		try{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', authorIdSet); 
			String peopleQuery = 'SELECT Id, User_Id__c, Full_Name__c, User__r.SmallPhotoURL FROM People__c where User_Id__c IN:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People__c> peopleObjectList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
			
			if(!peopleObjectList.isEmpty()){
				for(People__c peopleObj:peopleObjectList){
					PeopleLiteWrapper wrapObj = new PeopleLiteWrapper();
					wrapObj.userId = peopleObj.User_Id__c;
					wrapObj.peopleId = peopleObj.Id;
					wrapObj.sfUserId = peopleObj.User_Id__c;
					wrapObj.name = peopleObj.Full_Name__c;
					wrapObj.Url = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + peopleObj.User_Id__c;
					wrapObj.isFollowing = UserContext.usersIFollowIdSet.contains(peopleObj.User_Id__c);
					wrapObj.img = peopleObj.User__r.SmallPhotoURL.endsWith('005/T') ? null : peopleObj.User__r.SmallPhotoURL;
					authorIdVsPeopleWrapperMap.put(wrapObj.userId, wrapObj);
				}
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}		
		return authorIdVsPeopleWrapperMap;
    }

	/**
	 * @description This method is used to get information for reporters 
	 * @param reporterIdSet
	 * @return `Map<String,PeopleLiteWrapper>`
	*/
	public Map<String,PeopleLiteWrapper> getReporterInformation(Set<String> reporterIdSet){
		logger.logDebug('AIDataProvider.getReporterInformation()--'+ reporterIdSet);
		Map<String, PeopleLiteWrapper> reporterIdVsPeopleWrapperMap = new Map<String, PeopleLiteWrapper>();
		try{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', reporterIdSet); 
			String peopleQuery = 'SELECT Id, User_Id__c, Full_Name__c, User__r.SmallPhotoURL FROM People__c where Id IN:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People__c> peopleObjectList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
			
			if(!peopleObjectList.isEmpty()){
				for(People__c peopleObj:peopleObjectList){
					PeopleLiteWrapper wrapObj = new PeopleLiteWrapper();
					wrapObj.userId = peopleObj.User_Id__c;
					wrapObj.peopleId = peopleObj.Id;
					wrapObj.sfUserId = peopleObj.User_Id__c;
					wrapObj.name = peopleObj.Full_Name__c;
					wrapObj.Url = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + peopleObj.User_Id__c;
					wrapObj.isFollowing = UserContext.usersIFollowIdSet.contains(peopleObj.User_Id__c);
					wrapObj.img = peopleObj.User__r.SmallPhotoURL.endsWith('005/T') ? null : peopleObj.User__r.SmallPhotoURL;
					reporterIdVsPeopleWrapperMap.put(wrapObj.peopleId, wrapObj);
				}
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}		
		return reporterIdVsPeopleWrapperMap;
    }

	/**
	 * @description This method is used to call Content Moderation microservice for filters data queue details
	 * @return `AIWrapper.FiltersDataWrapper`
	*/
	public AIWrapper.FiltersDataWrapper getFiltersData() {
		logger.logDebug('AIDataProvider.getFiltersData()---- ');
		AIWrapper.FiltersDataWrapper filtersDataWrapperObj = new AIWrapper.FiltersDataWrapper();
		try{
			Map<String, Object> requestBody = new Map<String, Object>();	
			requestBody.put('org_id', SimpplrContext.simpplrOrgId);
			HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/moderation/queues/filters', requestBody);
			if (res.getStatusCode() != 200) {
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}
			String responseVal = res.getBody();

			String query = 'select id from CollaborationGroup where id IN (select CollaborationGroupId from CollaborationGroupMember where memberId=:loggedInUserId) and CollaborationType!=\'Public\'';
			if(SimpplrContext.isCommunitiesEnabled){
				query = query+' AND NetworkId = null';
			}
			Map<String,CollaborationGroup> groupMap = new Map<String,CollaborationGroup>((List<CollaborationGroup>)Database.query(query));
			if(UserContext.hasManageUnlistedSitePermission){
				groupMap.putAll([select id from CollaborationGroup where CollaborationType = 'Unlisted']);
			}
			Map<String,Simpplr_Site__c> siteMap = new Map<String,Simpplr_Site__c>([select id, Name from Simpplr_Site__c where Chatter_Group_Id__c IN:groupMap.keySet() OR Site_Type__c = 'Public']);
			List<AIWrapper.SiteWrapper> siteWrapperList = new List<AIWrapper.SiteWrapper>();
			List<AIWrapper.ReporterWrapper> reporterWrapperList = new List<AIWrapper.ReporterWrapper>();
			Set<String> reporterIdSet = new Set<String>();
			if(String.isNotBlank(responseVal)){
				Map<String, Object> filtersDataMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
				List<Object> siteList = (List<Object>)filtersDataMap.get('site_list');
				List<Object> reporterList = (List<Object>)filtersDataMap.get('reporter_list');
				if(!siteList.isEmpty()){
					for(Object item : siteList){
						String siteId = (String)item;
						if(!siteMap.isEmpty() && siteMap.containsKey(siteId)){
							AIWrapper.SiteWrapper siteWrapObj = new AIWrapper.SiteWrapper();
							siteWrapObj.siteId = siteId;
							siteWrapObj.siteName = siteMap.get(siteId).Name;
							siteWrapperList.add(siteWrapObj);
						}
					}
				}
				for(Object item : reporterList){
					String reporterId = (String)item;
					reporterIdSet.add(reporterId);
				}
			}
			if(!reporterIdSet.isEmpty()){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', reporterIdSet); 
				String peopleQuery = 'SELECT Id, User_Id__c, Full_Name__c FROM People__c where Id IN:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<People__c> peopleObjectList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
				if(!peopleObjectList.isEmpty()){
					for(People__c peopleObj:peopleObjectList){
						AIWrapper.ReporterWrapper wrapObj = new AIWrapper.ReporterWrapper();
						wrapObj.reporterId = peopleObj.Id;
						wrapObj.reporterName = peopleObj.Full_Name__c;
						reporterWrapperList.add(wrapObj);
					}
				}
			}
			filtersDataWrapperObj.sitesList = siteWrapperList;
			filtersDataWrapperObj.reportersList = reporterWrapperList;
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		logger.logDebug('AIDataProvider.getFiltersData()---'+ filtersDataWrapperObj);
		return filtersDataWrapperObj;
    }

	/**
	 * @description This method is used to call Content Moderation microservice for filters data history details
	 * @return `AIWrapper.HistoryFiltersWrapper`
	*/
	public AIWrapper.HistoryFiltersWrapper getModerationFilters() {
		logger.logDebug('AIDataProvider.getModerationFilters()---- ');
		AIWrapper.HistoryFiltersWrapper filtersDataWrapperObj = new AIWrapper.HistoryFiltersWrapper();
		try{
			Map<String, Object> requestBody = new Map<String, Object>();	
			requestBody.put('org_id', SimpplrContext.simpplrOrgId);
			HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/moderation/history/filters', requestBody);
			if (res.getStatusCode() != 200) {
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}
			String responseVal = res.getBody();

			String query = 'select id from CollaborationGroup where id IN (select CollaborationGroupId from CollaborationGroupMember where memberId=:loggedInUserId) and CollaborationType!=\'Public\'';
			if(SimpplrContext.isCommunitiesEnabled){
				query = query+' AND NetworkId = null';
			}
			Map<String,CollaborationGroup> groupMap = new Map<String,CollaborationGroup>((List<CollaborationGroup>)Database.query(query));
			if(UserContext.hasManageUnlistedSitePermission){
				groupMap.putAll([select id from CollaborationGroup where CollaborationType = 'Unlisted']);
			}
			Map<String,Simpplr_Site__c> siteMap = new Map<String,Simpplr_Site__c>([select id, Name from Simpplr_Site__c where Chatter_Group_Id__c IN:groupMap.keySet() OR Site_Type__c = 'Public']);
			List<AIWrapper.SiteWrapper> siteWrapperList = new List<AIWrapper.SiteWrapper>();
			List<AIWrapper.UserWrapper> userWrapperList = new List<AIWrapper.UserWrapper>();
			List<AIWrapper.ModeratorWrapper> moderatorWrapperList = new List<AIWrapper.ModeratorWrapper>();
			Set<String> userIdSet = new Set<String>();
			Set<String> moderatorIdSet = new Set<String>();
			if(String.isNotBlank(responseVal)){
				Map<String, Object> filtersDataMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
				List<Object> siteList = (List<Object>)filtersDataMap.get('site_list');
				List<Object> usersList = (List<Object>)filtersDataMap.get('user_list');
				List<Object> moderatorsList = (List<Object>)filtersDataMap.get('moderator_list');
				if(!siteList.isEmpty()){
					for(Object item : siteList){
						String siteId = (String)item;
						if(!siteMap.isEmpty() && siteMap.containsKey(siteId)){
							AIWrapper.SiteWrapper siteWrapObj = new AIWrapper.SiteWrapper();
							siteWrapObj.siteId = siteId;
							siteWrapObj.siteName = siteMap.get(siteId).Name;
							siteWrapperList.add(siteWrapObj);
						}
					}
				}
				for(Object item : usersList){
					String userId = (String)item;
					userIdSet.add(userId);
				}
				for(Object item : moderatorsList){
					String moderatorId = (String)item;
					moderatorIdSet.add(moderatorId);
				}
			}
			if(!userIdSet.isEmpty()){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', userIdSet); 
				String peopleQuery = 'SELECT Id, User_Id__c, Full_Name__c FROM People__c where User_Id__c IN:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<People__c> peopleObjectList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
				if(!peopleObjectList.isEmpty()){
					for(People__c peopleObj:peopleObjectList){
						AIWrapper.UserWrapper wrapObj = new AIWrapper.UserWrapper();
						wrapObj.userId = peopleObj.User_Id__c;
						wrapObj.userName = peopleObj.Full_Name__c;
						userWrapperList.add(wrapObj);
					}
				}
			}
			if(!moderatorIdSet.isEmpty()){
				Map<String, Object> soqlParamMap1 = new Map<String, Object>();
				soqlParamMap1.put('soqlParam1', moderatorIdSet); 
				String peopleQuery1 = 'SELECT Id, User_Id__c, Full_Name__c FROM People__c where User_Id__c IN:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<People__c> peopleObjectList1 = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery1, soqlParamMap1);
				if(!peopleObjectList1.isEmpty()){
					for(People__c peopleObj:peopleObjectList1){
						AIWrapper.ModeratorWrapper wrapObj = new AIWrapper.ModeratorWrapper();
						wrapObj.moderatorId = peopleObj.User_Id__c;
						wrapObj.moderatorName = peopleObj.Full_Name__c;
						moderatorWrapperList.add(wrapObj);
					}
				}
			}
			filtersDataWrapperObj.sitesList = siteWrapperList;
			filtersDataWrapperObj.usersList = userWrapperList;
			filtersDataWrapperObj.moderatorsList = moderatorWrapperList;
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		logger.logDebug('AIDataProvider.getModerationFilters()---'+ filtersDataWrapperObj);
		return filtersDataWrapperObj;
    }


	/**
	 * @description This method is used to get Moderation History Details
	 * @param requestDataMap
	 * @return `AIWrapper.ModerationQueueWrapper`
	*/
	public AIWrapper.ModerationQueueWrapper getModerationHistory(Map<String, Object> requestDataMap) {
		logger.logDebug('AIDataProvider.getModerationHistory() '+ requestDataMap);
		AIWrapper.ModerationQueueWrapper moderationQueueWrapObj = new AIWrapper.ModerationQueueWrapper();
		try{
			moderationQueueWrapObj.listOfItems = new List<AIWrapper.ModerationQueueItem>();
			Map<String,Object> moderationQueueDetailsMap = getModerationHistoryDetailsFromMS(requestDataMap);
			String userId = (requestDataMap!= null && requestDataMap.containsKey('user')) ? String.valueOf(requestDataMap.get('user')) : 'all';
			Set<String> siteIdsList = new Set<String>();
			Set<String> contentIdsList = new Set<String>();
			Set<String> authorIdsList = new Set<String>();
			Set<String> moderatorIdsList = new Set<String>();
			Set<String> userIdsList = new Set<String>();
			Set<String> reporterPeopleIdsList = new Set<String>();
			Map<String, AIWrapper.ModerationQueueItem> postIdVsModerationItemMap = new Map<String, AIWrapper.ModerationQueueItem>();
			Map<String, AIWrapper.ModerationQueueItem> replyIdVsModerationItemMap = new Map<String, AIWrapper.ModerationQueueItem>();
			List<Object> listOfChatterObjects = (List<Object>)moderationQueueDetailsMap.get('history_data');
			for(Object result:listOfChatterObjects){
				Map<String,Object> mapOfParams = (Map<String,Object>)result;
				AIWrapper.ModerationQueueItem moderationQueueItemObj = new AIWrapper.ModerationQueueItem();
				String moderatorId = mapOfParams.containsKey('moderated_by') && mapOfParams.get('moderated_by') != null ? (String)mapOfParams.get('moderated_by') : null;

				Object chatterMetadata = mapOfParams.containsKey('chatter') && mapOfParams.get('chatter') != null ? mapOfParams.get('chatter') : null;
				Map<String,Object> mapOfchatterMetadata = (Map<String,Object>)chatterMetadata;
				String chatterReplyId = mapOfchatterMetadata.containsKey('chatter_reply_id') && mapOfchatterMetadata.get('chatter_reply_id') != null ? (String)mapOfchatterMetadata.get('chatter_reply_id') : null;	
				String chatterCommentId = mapOfchatterMetadata.containsKey('chatter_comment_id') && mapOfchatterMetadata.get('chatter_comment_id') != null ? (String)mapOfchatterMetadata.get('chatter_comment_id') : null;
				String siteId = mapOfchatterMetadata.containsKey('site_id') && mapOfchatterMetadata.get('site_id') != null ? (String)mapOfchatterMetadata.get('site_id') : null;
				String contentId = mapOfchatterMetadata.containsKey('content_id') && mapOfchatterMetadata.get('content_id') != null ? (String)mapOfchatterMetadata.get('content_id') : null;	
				String authorId = mapOfchatterMetadata.containsKey('author_id') && mapOfchatterMetadata.get('author_id') != null ? (String)mapOfchatterMetadata.get('author_id') : null;	
				if(String.isNotBlank(siteId)){
					siteIdsList.add(siteId);
				}
				if(String.isNotBlank(contentId)){
					contentIdsList.add(contentId);
				}
				if(String.isNotBlank(authorId)){
					authorIdsList.add(authorId);
				}
				if(String.isNotBlank(moderatorId)){
					moderatorIdsList.add(moderatorId);
				}
				if(String.isNotBlank(chatterReplyId)){
					moderationQueueItemObj.type = 'reply';
					replyIdVsModerationItemMap.put(chatterReplyId, moderationQueueItemObj);
				}else if(String.isNotBlank(chatterCommentId)){
					moderationQueueItemObj.type = 'post';
					postIdVsModerationItemMap.put(chatterCommentId, moderationQueueItemObj);
				}
                moderationQueueItemObj.reportedBy = mapOfParams.containsKey('reported_by') && mapOfParams.get('reported_by') != null ? (String)mapOfParams.get('reported_by') : null;
				moderationQueueItemObj.reporterId = mapOfParams.containsKey('reporter_id') && mapOfParams.get('reporter_id') != null ? (String)mapOfParams.get('reporter_id') : null;
				if('user'.equalsIgnoreCase(moderationQueueItemObj.reportedBy) && String.isNotBlank(moderationQueueItemObj.reporterId)){
					reporterPeopleIdsList.add(moderationQueueItemObj.reporterId);
				}
			}
			Map<String, SiteListingWrapper> siteIdVsSiteWrapperMap = new Map<String, SiteListingWrapper>();
			Map<String, AIWrapper.ContentLiteWrapper> contentIdVsContentWrapperMap = new Map<String, AIWrapper.ContentLiteWrapper>();
			Map<String, PeopleLiteWrapper> authorIdVsPeopleWrapperMap = new Map<String, PeopleLiteWrapper>();
			Map<String, PeopleLiteWrapper> moderatorIdVsPeopleWrapperMap = new Map<String, PeopleLiteWrapper>();
			Map<String, PeopleLiteWrapper> userIdVsPeopleWrapperMap = new Map<String, PeopleLiteWrapper>();
			Map<String, PeopleLiteWrapper> reporterPeopleIdVsPeopleWrapperMap = new Map<String, PeopleLiteWrapper>();
			if(!siteIdsList.isEmpty()){
				siteIdVsSiteWrapperMap = getSiteInformation(siteIdsList);
			}
			if(!contentIdsList.isEmpty()){
				contentIdVsContentWrapperMap = getContentInformation(contentIdsList);
			}
			if(!authorIdsList.isEmpty()){
				authorIdVsPeopleWrapperMap = getAuthorInformation(authorIdsList);
			}
			if(!moderatorIdsList.isEmpty()){
				moderatorIdVsPeopleWrapperMap = getAuthorInformation(moderatorIdsList);
			}
			if(!reporterPeopleIdsList.isEmpty()){
				reporterPeopleIdVsPeopleWrapperMap = getReporterInformation(reporterPeopleIdsList);
			}
			Map<String,AIWrapper.ModerationQueueItem> feedIdVsModerationQueueItemMap = new Map<String,AIWrapper.ModerationQueueItem>();
			if(!postIdVsModerationItemMap.isEmpty()){
				feedIdVsModerationQueueItemMap = getFeedInformationForIds(postIdVsModerationItemMap);
			}
			Map<String,AIWrapper.ModerationQueueItem> replyIdVsModerationQueueItemMap = new Map<String,AIWrapper.ModerationQueueItem>();
			if(!replyIdVsModerationItemMap.isEmpty()){
				replyIdVsModerationQueueItemMap = getReplyInformationForIds(replyIdVsModerationItemMap);
			}
			
			for(Object result:listOfChatterObjects){ // Sorting data in same order received from MS
				Map<String,Object> mapOfParams = (Map<String,Object>)result;
				Object chatterMetadata = mapOfParams.containsKey('chatter') && mapOfParams.get('chatter') != null ? mapOfParams.get('chatter') : null;
				Map<String,Object> mapOfchatterMetadata = (Map<String,Object>)chatterMetadata;
				String chatterReplyId = mapOfchatterMetadata.containsKey('chatter_reply_id') && mapOfchatterMetadata.get('chatter_reply_id') != null ? (String)mapOfchatterMetadata.get('chatter_reply_id') : null;	
				String chatterCommentId = mapOfchatterMetadata.containsKey('chatter_comment_id') && mapOfchatterMetadata.get('chatter_comment_id') != null ? (String)mapOfchatterMetadata.get('chatter_comment_id') : null;
				String siteId = mapOfchatterMetadata.containsKey('site_id') && mapOfchatterMetadata.get('site_id') != null ? (String)mapOfchatterMetadata.get('site_id') : null;
				String contentId = mapOfchatterMetadata.containsKey('content_id') && mapOfchatterMetadata.get('content_id') != null ? (String)mapOfchatterMetadata.get('content_id') : null;	
				String authorId = mapOfchatterMetadata.containsKey('author_id') && mapOfchatterMetadata.get('author_id') != null ? (String)mapOfchatterMetadata.get('author_id') : null;	
				String parentCommentId = mapOfchatterMetadata.containsKey('parent_comment_id') && mapOfchatterMetadata.get('parent_comment_id') != null ? (String)mapOfchatterMetadata.get('parent_comment_id') : null;	
				String moderatorId = mapOfParams.containsKey('moderated_by') && mapOfParams.get('moderated_by') != null ? (String)mapOfParams.get('moderated_by') : null;
				AIWrapper.ModerationQueueItem moderationQueueItemObj = new AIWrapper.ModerationQueueItem();
				if(String.isNotBlank(chatterReplyId) && replyIdVsModerationQueueItemMap.containsKey(chatterReplyId) && replyIdVsModerationQueueItemMap.get(chatterReplyId) != null){
					moderationQueueItemObj = replyIdVsModerationQueueItemMap.get(chatterReplyId).clone();
				}else if(String.isNotBlank(chatterCommentId) && feedIdVsModerationQueueItemMap.containsKey(chatterCommentId) && feedIdVsModerationQueueItemMap.get(chatterCommentId) != null){
					moderationQueueItemObj = feedIdVsModerationQueueItemMap.get(chatterCommentId).clone();
				}
				moderationQueueItemObj.moderationId = mapOfParams.containsKey('id') && mapOfParams.get('id') != null ? String.valueOf(mapOfParams.get('id')) : null;
                moderationQueueItemObj.reportedBy = mapOfParams.containsKey('reported_by') && mapOfParams.get('reported_by') != null ? (String)mapOfParams.get('reported_by') : null;
				List<Object> reasonsList = new List<Object>();
				if(mapOfParams.containsKey('report_reason')){
					reasonsList = (List<Object>)mapOfParams.get('report_reason');	
				}
				moderationQueueItemObj.reportReason = reasonsList;
				moderationQueueItemObj.reporterId = mapOfParams.containsKey('reporter_id') && mapOfParams.get('reporter_id') != null ? (String)mapOfParams.get('reporter_id') : null;
				moderationQueueItemObj.reportedOn = mapOfParams.containsKey('reported_on') && mapOfParams.get('reported_on') != null ? (String)mapOfParams.get('reported_on') : null;
				moderationQueueItemObj.moderationStatus = mapOfParams.containsKey('moderation_status') && mapOfParams.get('moderation_status') != null ? (String)mapOfParams.get('moderation_status') : null;
				moderationQueueItemObj.moderatedOn = mapOfParams.containsKey('moderated_on') && mapOfParams.get('moderated_on') != null ? (String)mapOfParams.get('moderated_on') : null;
                if(String.isBlank(moderationQueueItemObj.moderatedOn)){
                    moderationQueueItemObj.moderatedOn = moderationQueueItemObj.reportedOn;
                }
				moderationQueueItemObj.createdAt = mapOfParams.containsKey('created_at') && mapOfParams.get('created_at') != null ? (String)mapOfParams.get('created_at') : null;
				moderationQueueItemObj.parentCommentId = parentCommentId;
				moderationQueueItemObj.site = String.isNotBlank(siteId) && siteIdVsSiteWrapperMap.containsKey(siteId) && siteIdVsSiteWrapperMap.get(siteId) != null ? siteIdVsSiteWrapperMap.get(siteId) : null;
				moderationQueueItemObj.content = String.isNotBlank(contentId) && contentIdVsContentWrapperMap.containsKey(contentId) && contentIdVsContentWrapperMap.get(contentId) != null ? contentIdVsContentWrapperMap.get(contentId) : null;
				moderationQueueItemObj.lastUpdatedOn = mapOfParams.containsKey('updated_at') && mapOfParams.get('updated_at') != null ? (String)mapOfParams.get('updated_at') : null;
				if(moderationQueueItemObj.content != null){
					moderationQueueItemObj.contentId = moderationQueueItemObj.content.id;
					moderationQueueItemObj.contentTitle = moderationQueueItemObj.content.title;
					moderationQueueItemObj.publishAt = moderationQueueItemObj.content.publishAt;
				}
				moderationQueueItemObj.user = String.isNotBlank(authorId) && authorIdVsPeopleWrapperMap.containsKey(authorId) && authorIdVsPeopleWrapperMap.get(authorId) != null ? authorIdVsPeopleWrapperMap.get(authorId) : null;
				moderationQueueItemObj.moderator = String.isNotBlank(moderatorId) && moderatorIdVsPeopleWrapperMap.containsKey(moderatorId) && moderatorIdVsPeopleWrapperMap.get(moderatorId) != null ? moderatorIdVsPeopleWrapperMap.get(moderatorId) : null;
				if('user'.equalsIgnoreCase(moderationQueueItemObj.reportedBy) && String.isNotBlank(moderationQueueItemObj.reporterId) && String.isBlank(moderatorId)){
					moderationQueueItemObj.moderator = (!reporterPeopleIdVsPeopleWrapperMap.isEmpty() && reporterPeopleIdVsPeopleWrapperMap.containsKey(moderationQueueItemObj.reporterId)) ? reporterPeopleIdVsPeopleWrapperMap.get(moderationQueueItemObj.reporterId) : null;
				}
				if('user'.equalsIgnoreCase(moderationQueueItemObj.reportedBy) && String.isNotBlank(moderationQueueItemObj.reporterId)){
					moderationQueueItemObj.reporterDetails = (!reporterPeopleIdVsPeopleWrapperMap.isEmpty() && reporterPeopleIdVsPeopleWrapperMap.containsKey(moderationQueueItemObj.reporterId)) ? reporterPeopleIdVsPeopleWrapperMap.get(moderationQueueItemObj.reporterId) : null;
				}
				moderationQueueWrapObj.nextPageToken = moderationQueueDetailsMap.containsKey('next_page_token') && moderationQueueDetailsMap.get('next_page_token') != null ? String.valueOf(moderationQueueDetailsMap.get('next_page_token')) : null;	
                moderationQueueWrapObj.listOfItems.add(moderationQueueItemObj);
			}
			
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		return moderationQueueWrapObj;
    }

	/**
	 * @description This method is used to call Content Moderation microservice for moderation queue details
	 * @param requestDataMap
	 * @return `Map<String,Object>`
	*/
	public Map<String,Object> getModerationHistoryDetailsFromMS(Map<String, Object> requestDataMap) {
		logger.logDebug('AIDataProvider.getModerationHistoryDetailsFromMS() '+ requestDataMap);
		Map<String,Object> moderationHistoryDataMap = new Map<String,Object>();
		try{
			Integer size = (requestDataMap!= null && requestDataMap.containsKey('size')) ? Integer.valueOf(requestDataMap.get('size')) : 16;
			String start_date = (requestDataMap!= null && requestDataMap.containsKey('startDate')) ? String.valueOf(requestDataMap.get('startDate')) : null;
			String end_date = (requestDataMap!= null && requestDataMap.containsKey('endDate')) ? String.valueOf(requestDataMap.get('endDate')) : null;
			String action = (requestDataMap!= null && requestDataMap.containsKey('action')) ? String.valueOf(requestDataMap.get('action')) : 'all';
			String user = (requestDataMap!= null && requestDataMap.containsKey('user')) ? String.valueOf(requestDataMap.get('user')) : 'all';
			String moderator = (requestDataMap!= null && requestDataMap.containsKey('moderator')) ? String.valueOf(requestDataMap.get('moderator')) : 'all';
			String site = (requestDataMap!= null && requestDataMap.containsKey('site')) ? String.valueOf(requestDataMap.get('site')) : 'all';
			String type = (requestDataMap!= null && requestDataMap.containsKey('type')) ? String.valueOf(requestDataMap.get('type')) : 'all';
			Integer nextPageToken = (requestDataMap!= null && requestDataMap.containsKey('nextPageToken')) ? Integer.valueOf(requestDataMap.get('nextPageToken')) : null;
			Map<String, Object> requestBody = new Map<String, Object>();	
			requestBody.put('size', size);
			requestBody.put('action', action);
			requestBody.put('moderator', moderator);
			requestBody.put('user', user);
			requestBody.put('start_date', start_date);
			requestBody.put('end_date', end_date);
			requestBody.put('site', site);
			requestBody.put('type', type);
			requestBody.put('next_page_token', nextPageToken);
			requestBody.put('org_id', SimpplrContext.simpplrOrgId);
			if(UserContext.hasModifyAllDataPermission){
				requestBody.put('has_all_sites_access', true);
			}else{
				String query = 'select id from CollaborationGroup where id IN (select CollaborationGroupId from CollaborationGroupMember where memberId=:loggedInUserId) and CollaborationType!=\'Public\'';
				if(SimpplrContext.isCommunitiesEnabled){
					query = query+' AND NetworkId = null';
				}
				Map<String,CollaborationGroup> groupMap = new Map<String,CollaborationGroup>((List<CollaborationGroup>)Database.query(query));
				if(UserContext.hasManageUnlistedSitePermission){
					groupMap.putAll([select id from CollaborationGroup where CollaborationType = 'Unlisted']);
				}
				Map<String,Simpplr_Site__c> siteMap = new Map<String,Simpplr_Site__c>([select id from Simpplr_Site__c where Chatter_Group_Id__c IN:groupMap.keySet() OR Site_Type__c = 'Public']);
				requestBody.put('has_all_sites_access', false);
				requestBody.put('site_id_list', siteMap.keySet());
			}
			HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/content-moderation/moderation/history', requestBody);
			
			String responseVal;
			if (res.getStatusCode() == 200) {
				responseVal = res.getBody();
			} else {
				logger.logError('AIDataProvider.getModerationDataFromMS()----status code----' + res.getStatusCode());
				throw new SimpplrException(String.valueOf(res.getStatusCode()));
			}
			if(String.isNotBlank(responseVal)){
				moderationHistoryDataMap = (Map<String, Object>) JSON.deserializeUntyped(responseVal);
			}
		}catch(Exception e){
			logger.logError(e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
		logger.logDebug('AIDataProvider.getModerationHistoryDetailsFromMS()---'+ moderationHistoryDataMap);
		return moderationHistoryDataMap;
    }

	
	public class ModerationMetaData {
		public String reported_by;
		public List<String> report_reason;
		public String chatter_string;
		public String moderation_status;
		public String reporter_id;
		public String reported_on;
	}

}