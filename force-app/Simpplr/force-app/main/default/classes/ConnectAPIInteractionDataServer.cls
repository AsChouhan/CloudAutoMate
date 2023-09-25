/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ConnectAPIInteractionDataServer extends DataServer {

    private final String REQUEST_PARAM_DATA = 'data';
    private final String INSUFFICIENT_PERMISSION_TO_POST_MSG = 'It’s not possible to Post to this Feed';
    private final String INACTIVE_SITE_FEED_NOT_ALLOWED_MSG = 'It’s not possible to post on an inactive Site’s Feed';
    private final String BORADCAST_SITE_FEED_NOT_ALLOWED_MSG = 'Only Site Managers can Post to a Broadcast only Site';
	private final String POST_CHARACTER_LIMIT_ERROR_MSG = 'You have exceeded the maximum character limit for the post'; //EDT-419

    /**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public override void handleRequest () {
    	Criteria.Feed criteriaFeedObj = new Criteria.Feed();

    	logger.logDebug('ConnectApiInteractionDataServer.handleRequest()22 '+criteriaFeedObj);
    	try {
    		String requestData = readParam(REQUEST_PARAM_DATA); 
			logger.logDebug('REQUEST DATA '+ requestData);
	        criteriaFeedObj = (Criteria.Feed)JSON.deserialize(requestData, Criteria.Feed.class);
    		logger.logDebug('ConnectApiInteractionDataServer.handleRequest()26 '+criteriaFeedObj);
    		if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('toggleFavorite')) {
    			response = toggleFavorite(criteriaFeedObj.communityId, criteriaFeedObj.feedElementId, 
    				criteriaFeedObj.setBookmark);
    		
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('likefeed')) {
    			response = likeFeed(criteriaFeedObj.communityId, criteriaFeedObj.feedElementId);
    		
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('unlikefeed')) {
    			response = unLikeFeed(criteriaFeedObj.communityId, criteriaFeedObj.likeId, criteriaFeedObj.feedElementId);
    		
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('deletefeed')) {
    			response = deleteFeedElement(criteriaFeedObj.communityId, criteriaFeedObj.feedElementId, criteriaFeedObj.locationURL);
				
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('deletecomment')) {
    			response = deleteComment(criteriaFeedObj.communityId, criteriaFeedObj.commentId);
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('updatefeed')) {
    			response = updateFeedElement(criteriaFeedObj);
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('posttextpost')) {
				logger.logDebug('ConnectApiInteractionDataServer.handleRequest()48 '+criteriaFeedObj.action);
    			response = postTextPost(criteriaFeedObj);
    					
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('postlink')) {
    			response = postLink(criteriaFeedObj.communityId, criteriaFeedObj.subjectId,
    					criteriaFeedObj.feedElementType,criteriaFeedObj.urlArg, criteriaFeedObj.urlName, 
    					criteriaFeedObj.textBody, criteriaFeedObj.bodyJson, criteriaFeedObj.listOfTopic, criteriaFeedObj.moderationResult, criteriaFeedObj.locationURL);
    					
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('postpoll')) {
    			response = postPoll(criteriaFeedObj.communityId, criteriaFeedObj.subjectId, 
    					criteriaFeedObj.feedElementType, criteriaFeedObj.listOfPollChoice, 
    					criteriaFeedObj.textBody, criteriaFeedObj.bodyJson, criteriaFeedObj.listOfTopic, criteriaFeedObj.locationURL);
						
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('postcomment')) {
    			response = postComment(criteriaFeedObj.communityId, criteriaFeedObj.feedElementId, 
    					criteriaFeedObj.contentDocumentId, criteriaFeedObj.textBody, criteriaFeedObj.bodyJson, criteriaFeedObj.moderationResult,  criteriaFeedObj.externalFiles);
						
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('setprofilephoto')) {
    			response = setProfilePhoto(criteriaFeedObj.communityId, criteriaFeedObj.peopleId ,
    					criteriaFeedObj.fileId, null);
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('removeprofilephoto')) {
    			response = removeProfilePhoto(criteriaFeedObj.communityId, criteriaFeedObj.peopleId);
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('voteonpoll')) {
    			response = voteOnPoll(criteriaFeedObj.communityId, criteriaFeedObj.feedElementId,
    					criteriaFeedObj.myChoiceId);
    					
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('updatecomment')) {
    			response = updateComment(criteriaFeedObj.communityId, criteriaFeedObj.commentId, 
    					criteriaFeedObj.commentText, criteriaFeedObj.bodyJson, criteriaFeedObj.moderationResult, criteriaFeedObj.externalFiles); 
    					
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('upserttopic')) {
    			response = upsertTopic(criteriaFeedObj.communityId, criteriaFeedObj.feedElementId, 
    					criteriaFeedObj.listOfTopic); 
    					
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('getpollresults')) {
    			response = getPollResults(criteriaFeedObj.communityId, criteriaFeedObj.feedElementId); 
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('postFile')) {
				logger.logDebug('ConnectApiInteractionDataServer.handleRequest() PostFile ---'+criteriaFeedObj);
    			response = postFile(criteriaFeedObj); 
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('likecomment')) {
    			response = likecomment(criteriaFeedObj.communityId, criteriaFeedObj.commentId, 
    					criteriaFeedObj.feedElementId); 
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('unlikecomment')) {
    			response = unlikecomment(criteriaFeedObj.communityId, criteriaFeedObj.commentId, criteriaFeedObj.likeId); 
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('savesortby')) {
    			response = saveSortBy(criteriaFeedObj.filterValue); 
    			
    		} else if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('savefilterby')) {
    			response = saveFilterBy(criteriaFeedObj.filterValue); 
    			
    		}
    		
    	} catch (Exception e) { 
    		logger.logError('Exception Details', e);
    		
    		Boolean isInsufficientPermissionError = e.getMessage().containsIgnoreCase('Insufficient Privileges');
    		Boolean isScriptThrownError = e.getMessage().containsIgnoreCase('Script-thrown exception');
    		Boolean isBroadcastGroupsError = e.getMessage().containsIgnoreCase('mention broadcast groups');
    		if ((isScriptThrownError || isInsufficientPermissionError || isBroadcastGroupsError) && (
    				criteriaFeedObj.action.equalsIgnoreCase('posttextpost') || 
    				criteriaFeedObj.action.equalsIgnoreCase('postlink') ||
    				criteriaFeedObj.action.equalsIgnoreCase('postpoll') || 
    				criteriaFeedObj.action.equalsIgnoreCase('postFile'))) {
    			
    			if(String.isNotBlank(criteriaFeedObj.subjectId) && criteriaFeedObj.subjectId.startsWith('0F9')) {
    				List<CollaborationGroup> cgmList = [select id, isArchived, CollaborationType, isBroadCast, (select id from  GroupMembers 
    																						 where CollaborationRole = 'Admin'
    																						 and memberId=:UserInfo.getUserId())
    													from CollaborationGroup where id=:criteriaFeedObj.subjectId WITH SECURITY_ENFORCED];
    				if(cgmList.isEmpty()) {
    					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, INSUFFICIENT_PERMISSION_TO_POST_MSG, null);
    				
    				} else if(cgmList[0].isArchived){
    					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, INACTIVE_SITE_FEED_NOT_ALLOWED_MSG, null);
    				
    				} else if(cgmList[0].isBroadCast && cgmList[0].GroupMembers.isEmpty()) {
    					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, BORADCAST_SITE_FEED_NOT_ALLOWED_MSG, null);
    				
    				} else if(!'Public'.equalsIgnoreCase(cgmList[0].CollaborationType) && cgmList[0].GroupMembers.isEmpty()) {
    					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, INSUFFICIENT_PERMISSION_TO_POST_MSG, null);
    					
    				} else if (isBroadcastGroupsError) {
    					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, BORADCAST_SITE_FEED_NOT_ALLOWED_MSG, null);
    				
    				} else {
    					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
    				}
    				
    			} else if(isBroadcastGroupsError) {
    				response = buildResponseWrapper(RESPONSE_STATUS_ERROR, BORADCAST_SITE_FEED_NOT_ALLOWED_MSG, null);
    				
    			} else {
    				response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
    			
    			}
    			
    		} else {
    			
    			if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('postFile')
    					&& e.getMessage().containsIgnoreCase('Invalid content ids specified')) {
					response = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
    						'Unable to perform action - file is either deleted or you do not have correct permissions.', null);
    						
    			} else if (isInsufficientPermissionError) {
    				response = buildResponseWrapper(RESPONSE_STATUS_ERROR, 'Unable to perform action', null);
	    					
    			} else {
        			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
    			}
    			
    		}
    		
    	}
    	
    }
    
    /**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    @testVisible 
    private ResponseWrapper toggleFavorite (String communityIdArg, String feedElementIdArg, 
    		Boolean setBookmarkArg) {
    	ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			Boolean isSuccess = FeedServiceProvider.toggleBookMarks(communityIdArg, feedElementIdArg,
				setBookmarkArg);
				
			if (setBookmarkArg) {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, isSuccess);
					
			} else {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, isSuccess);
			}
		} catch(exception e){
      		logger.logError('ConnectAPIInteractionDataServer.toggleFavorite()-----could not retrieve data----',e);
  			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
    	return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper likeFeed (String communityIdArg, String feedElementIdArg) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			String likeId = FeedServiceProvider.likeFeedElement(communityIdArg, feedElementIdArg);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, likeId);
			responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
		} catch(exception e){
      		logger.logError('ConnectAPIInteractionDataServer.likeFeed()-----could not retrieve data----',e);
  			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private  ResponseWrapper unLikeFeed (String communityIdArg, String likeIdArg, String feedElementIdArg) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
		Boolean isSuccess = FeedServiceProvider.unlikeFeedElement(communityIdArg, likeIdArg, feedElementIdArg);
		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, isSuccess);
		} catch(exception e){
			logger.logError('ConnectAPIInteractionDataServer.unLikeFeed()-----could not retrieve data----',e);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper deleteFeedElement(String communityIdArg, String feedElementIdArg, String locationUrl) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			Boolean isSuccess = FeedServiceProvider.deleteFeed(communityIdArg, feedElementIdArg);
           	sendEmotionAndSentimentInfo(' ', feedElementIdArg, locationUrl, 'POST', true, true, false, false);    	
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, isSuccess);
		}catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.deleteFeedElement()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}
		
		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
    private ResponseWrapper deleteComment (String communityIdArg, String commentIdArg) {
    	ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			Boolean isSuccess = FeedServiceProvider.deleteComment(communityIdArg, commentIdArg);
           	sendEmotionAndSentimentInfo(' ', commentIdArg, null, 'REPLY', false, true, false, false);    	
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, isSuccess);
		} catch(exception e){
			logger.logError('ConnectAPIInteractionDataServer.deleteComment()-----could not retrieve data----',e);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseToReturn;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
    private ResponseWrapper updateFeedElement (Criteria.Feed criteriaFeedObj) {
		System.debug('CADs>>updateFeedElement>>>>301>>>>>criteriaFeedObj ' + criteriaFeedObj);
    	ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			feedElementWrapperObj = FeedServiceProvider.updateFeedElement(criteriaFeedObj.communityId, criteriaFeedObj.feedElementId,
			criteriaFeedObj.textBody, criteriaFeedObj.bodyJson, criteriaFeedObj.moderationResult, criteriaFeedObj.recognitionBody, criteriaFeedObj.externalFiles);

			System.debug('CADs>>updateFeedElement>>>>>308>>>>feedElementWrapperObj ' + feedElementWrapperObj);
			System.debug('CADs>>updateFeedElement>>>>>>310>>>criteriaFeedObj.bodyJson ' + criteriaFeedObj.bodyJson);
			System.debug('CADs>>updateFeedElement>>>>>>311>>>criteriaFeedObj.textBody ' + criteriaFeedObj.textBody);
			System.debug('CADs>>updateFeedElement>>>>>>312>>>criteriaFeedObj.externalFiles ' + criteriaFeedObj.externalFiles);
           	sendEmotionAndSentimentInfo(feedElementWrapperObj.body, criteriaFeedObj.feedElementId, criteriaFeedObj.locationURL, 'POST', true, false, true, false);    	
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, feedElementWrapperObj);
			System.debug('CADs>>updateFeedElement>>>>>315>>>>responseToReturn ' + responseToReturn);
			responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
    	} catch(exception e){
			System.debug('CADs>>updateFeedElement>>>>>318>>>>Exception:::::::: ');
         	logger.logError('ConnectAPIInteractionDataServer.updateFeedElement()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
    }
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper postTextPost (Criteria.Feed criteriaFeedObj) {
		logger.logdebug('ConnectAPIInteractionDataServer.postTextPost()-----criteriaFeedObj----'+ criteriaFeedObj);
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			// PS -816 Check for rate limit
			Utility.checkForRateLimit('feeditem');
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			feedElementWrapperObj = FeedServiceProvider.postTextPost(criteriaFeedObj.communityId, criteriaFeedObj.subjectId,
																		criteriaFeedObj.feedElementType, criteriaFeedObj.textBody, criteriaFeedObj.bodyJson, criteriaFeedObj.listOfTopic,
																			criteriaFeedObj.moderationResult, criteriaFeedObj.recognitionBody, criteriaFeedObj.locationURL, criteriaFeedObj.externalFiles);
			logger.logdebug('ConnectAPIInteractionDataServer.postTextPost()-----feedElementWrapperObj----'+feedElementWrapperObj);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, feedElementWrapperObj);
			responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
		
		} catch(exception e){
			logger.logError('ConnectAPIInteractionDataServer.postTextPost()-----could not retrieve data----',e);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, POST_CHARACTER_LIMIT_ERROR_MSG, null); //EDT-419
			// responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper postLink (String communityIdArg, String subjectIdArg, String feedElementTypeArg,
			String urlArg, String urlNameArg, String textToPostArg, String bodyJsonArg, List<String> listOfTopicArg, Criteria.ModerationResult moderationResult, String locationUrl) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			feedElementWrapperObj = FeedServiceProvider.postLink(communityIdArg, subjectIdArg,
					feedElementTypeArg, urlArg, urlNameArg, textToPostArg, bodyJsonArg,listOfTopicArg, moderationResult, locationUrl);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, feedElementWrapperObj);
			responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.likeFeed()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;	
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper postPoll (String communityIdArg, String subjectIdArg, String feedElementTypeArg,
			List<String> listOfPollChoicesArg, String pollMsgArg, String bodyJsonArg, List<String> listOfTopicArg, String locationUrl) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
			feedElementWrapperObj = FeedServiceProvider.postPoll(communityIdArg, subjectIdArg, feedElementTypeArg,
					listOfPollChoicesArg, pollMsgArg, bodyJsonArg, listOfTopicArg, locationUrl);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, feedElementWrapperObj);
			responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.postPoll()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}
		return responseToReturn;		
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper postComment (String communityIdArg, String feedElementIdArg, String contentDocumentIdArg,
			String textArg, String bodyJsonArg, Criteria.ModerationResult moderationResult,  List<Criteria.ExternalFileWrapper> externalFiles) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			// PS -816 Check for rate limit
			Utility.checkForRateLimit('feedcomment');
			RecentCommentsWrapper recentCommentsWrapperObj = new RecentCommentsWrapper();
			recentCommentsWrapperObj = FeedServiceProvider.postComment(communityIdArg, feedElementIdArg,
					contentDocumentIdArg, textArg, bodyJsonArg, moderationResult, externalFiles);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, recentCommentsWrapperObj);
			responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.likeFeed()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
    private ResponseWrapper  postFile (Criteria.Feed criteriaFeedObj) {
		logger.logDebug('ConnectApiInteractionDataServer.PostFile()-criteriaFeedObj--'+criteriaFeedObj);
		
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
		FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
		feedElementWrapperObj = FeedServiceProvider.postFile(criteriaFeedObj.communityId, criteriaFeedObj.subjectId,
																criteriaFeedObj.feedElementType, criteriaFeedObj.listOfAttachedFileId, 
																	criteriaFeedObj.textBody, criteriaFeedObj.bodyJson, criteriaFeedObj.listOfTopic, criteriaFeedObj.moderationResult, criteriaFeedObj.recognitionBody, criteriaFeedObj.locationURL, criteriaFeedObj.externalFiles);
		logger.logDebug('ConnectApiInteractionDataServer.PostFile()-feedElementWrapperObj--'+feedElementWrapperObj);
		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, feedElementWrapperObj);
		logger.logDebug('ConnectApiInteractionDataServer.PostFile()-responseToReturn--'+responseToReturn);
		responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.postFile()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}
    	return responseToReturn;
    }
     
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
    private ResponseWrapper updateComment (String communityIdArg, String commentIdArg, String commentBodyArg, String bodyJsonArg, Criteria.ModerationResult moderationResult, List<Criteria.ExternalFileWrapper>  externalFiles) {
    	ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			RecentCommentsWrapper recentCommentsWrapperObj = new RecentCommentsWrapper();
			recentCommentsWrapperObj = FeedServiceProvider.updateComment(communityIdArg, commentIdArg, 
					commentBodyArg, bodyJsonArg, moderationResult, externalFiles);
           	sendEmotionAndSentimentInfo(recentCommentsWrapperObj.body, commentIdArg, null, 'REPLY', false, false, true, false);    	
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, recentCommentsWrapperObj);	
			responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.updateComment()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

    	return responseToReturn;
    } 
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
    private ResponseWrapper upsertTopic (String communityIdArg, String feedElementIdArg, List<String> listOfTopicsArg) {
        ResponseWrapper responseToReturn = new  ResponseWrapper();
        try {
           	ConnectApi.TopicPage topicPageObj = FeedConnectAPIService.getTopics(communityIdArg, feedElementIdArg);
            
          	for (ConnectApi.Topic topicObj : topicPageObj.topics) {
                Boolean isTopicFound = false;
                
                for (String topicName : listOfTopicsArg) {
                    
                    if (topicObj.Name.equals(topicName.trim())) {
                        isTopicFound = true;
                        
                        break;
                    }
                    
                }
                
                if (!isTopicFound) {
                    FeedConnectAPIService.unassignTopic(communityIdArg, feedElementIdArg, topicObj.id);
                }
            }
            
            for (String topicName : listOfTopicsArg) {
                topicName = topicName.trim();
                
                if (topicName.equals('')) {
                    continue;
                }
                
                ConnectApi.Topic newTopicObj = ConnectApi.Topics.assignTopicByName(communityIdArg,
                		feedElementIdArg, topicName);  
            }
            
            topicPageObj = FeedConnectAPIService.getTopics(communityIdArg, feedElementIdArg);
            List<TopicWrapper> listOfTopicWrapper = new List<TopicWrapper>();
            
            for (ConnectApi.Topic topicObj : topicPageObj.topics) {
            	listOfTopicWrapper.add(FeedDataAdapter.convertTopicToWrapper(topicObj));
            }
            
            responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfTopicWrapper);
					 
        } catch (exception e) {
           	logger.logError('ConnectAPIInteractionDataServer.upsertTopic()-----could not retrieve data----',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return responseToReturn;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper voteOnPoll (String communityIdArg, String feedElementIdArg, String myChoiceIdArg) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			PollWrapper pollWrapperObj = new PollWrapper();
			pollWrapperObj = FeedServiceProvider.voteOnPoll(communityIdArg, feedElementIdArg, myChoiceIdArg);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, pollWrapperObj);
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.voteOnPoll()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper setProfilePhoto (String communityIdArg, String peopleIdArg, String fileIdArg,
    		Integer versionNumber) {
    	ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
		ConnectApi.Photo photoObj = FeedServiceProvider.setProfilePhoto(null, peopleIdArg, fileIdArg, null);
		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, photoObj);
    	} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.setProfilePhoto()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper removeProfilePhoto (String communityIdArg, String peopleIdArg) {
    	ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			FeedServiceProvider.removeProfilePhoto(null, peopleIdArg);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.removeProfilePhoto()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	
	@testVisible 
	private ResponseWrapper getPollResults (String communityIdArg, String feedElementIdArg) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			PollWrapper pollWrapperObj = new PollWrapper();
			pollWrapperObj = FeedServiceProvider.getFeedPoll(communityIdArg, feedElementIdArg);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, pollWrapperObj);
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.getPollResults()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private ResponseWrapper likecomment (String communityIdArg, String commentIdArg, String feedElementId) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			String likeId = FeedServiceProvider.likeComment(communityIdArg, commentIdArg, feedElementId);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, likeId);
			responseToReturn.responseTimeStamp = String.valueOf(system.now().getTime());
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.likeFeed()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private  ResponseWrapper unlikecomment (String communityIdArg, String commentIdArg, String likeIdArg) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			Boolean isSuccess = FeedServiceProvider.unlikeComment(communityIdArg, commentIdArg, likeIdArg);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, isSuccess);
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.unlikecomment()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private  ResponseWrapper saveSortBy (String filterValue) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			List<People_Preference__c> listOfPeoplePrefrence = [SELECT Feed_Sort_Order__c
					FROM People_Preference__c WHERE People__c=:userContext.peopleId WITH SECURITY_ENFORCED limit 1];
			Boolean isSuccess = false;
			
			if (!listOfPeoplePrefrence.isEmpty()) {
				listOfPeoplePrefrence[0].Feed_Sort_Order__c = filterValue;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(listOfPeoplePrefrence[0], 
						new List<Schema.SObjectField>{People_Preference__c.Feed_Sort_Order__c});
				isSuccess = true;
			} 
				
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, isSuccess);
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.saveSortBy()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	
	/**
	* 
	* Purpose:  This method is to create a new group on box.com for new inserted chatter collaboration group
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@testVisible 
	private  ResponseWrapper saveFilterBy (String filterValue) {
		ResponseWrapper responseToReturn = new  ResponseWrapper();
		try{
			List<People_Preference__c> listOfPeoplePrefrence = [SELECT Feed_Type__c FROM People_Preference__c
					WHERE People__c=:userContext.peopleId WITH SECURITY_ENFORCED limit 1];
			Boolean isSuccess = false;
			
			if (!listOfPeoplePrefrence.isEmpty()) {
				listOfPeoplePrefrence[0].Feed_Type__c = filterValue;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(listOfPeoplePrefrence[0], 
						new List<Schema.SObjectField>{People_Preference__c.Feed_Type__c});
				isSuccess = true;
			} 
			
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, isSuccess);
		} catch(exception e){
         	logger.logError('ConnectAPIInteractionDataServer.saveFilterBy()-----could not retrieve data----',e);
       		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
   		}

		return responseToReturn;
	}
	@future(callout=true)
	public static void sendEmotionAndSentimentInfo(String comment, String commentId, String locationUrl, String postType, Boolean isFeedPost, Boolean isDeleted, Boolean isUpdated, Boolean isRemoved) {
        logger.logDebug('ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo()');
		try{
			if(SimpplrContext.listenerSuiteEnabled && String.isNotEmpty(comment)) {
				Map<String,Object> requestBody = new Map<String,Object>();
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', UserInfo.getUserId()); 
				String peopleQuery = 'SELECT Id, Department__c, city__c, state__c, country__c, User_Id__c, Full_Name__c, User__r.SmallPhotoURL FROM People__c where User__c =:soqlParam1';
                if(SimpplrContext.isSegmentsEnabled){
					peopleQuery = 'SELECT Id, Department__c, city__c, state__c, country__c, User_Id__c, Segment__c, Segment__r.Name__c, Full_Name__c, User__r.SmallPhotoURL FROM People__c where User__c =:soqlParam1';
                }
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<People__c> peopleObject = (List<People__c>)SIMPESAPI.accessController().queryAsUser(peopleQuery, soqlParamMap);
				String siteId;
				String siteUrl;
				String siteName;
				String contentName;
				String contentId;
				String contentIdentifier;
				String contentUrl;
				String feedId;
				if(String.isNotBlank(locationUrl)) {
					siteId = locationUrl.substringBetween('/site/','/');
				}
				if(String.isNotBlank(siteId)) {
					siteUrl = locationUrl.substringBefore('/site/')+'/site/'+siteId;
					soqlParamMap.put('soqlParam1', siteId); 
					String siteQuery = 'SELECT Id, Name from simpplr_site__c where Id =:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<simpplr_site__c> siteObjectList = (List<simpplr_site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);
					if(!siteObjectList.isEmpty()){
						siteName = siteObjectList[0].Name;
					}
				}
				if(String.isNotBlank(locationUrl) && locationUrl.contains('/page/')) {
					contentIdentifier = '/page/';
				} else if(String.isNotBlank(locationUrl) && locationUrl.contains('/event/')) {
					contentIdentifier = '/event/';
				} else if(String.isNotBlank(locationUrl) && locationUrl.contains('/album/')) {
					contentIdentifier = '/album/';
				} else if(String.isNotBlank(locationUrl) && locationUrl.contains('/blog/')) {
					contentIdentifier = '/blog/';
				}
				if(String.isNotBlank(contentIdentifier)) {
					contentId = locationUrl.substringAfter(contentIdentifier).substring(0, 18);
					contentUrl = locationUrl.substringBefore(contentId)+contentId;
					if(String.isNotBlank(contentId)) {
						soqlParamMap.put('soqlParam1', contentId); 
						String contentQuery = 'SELECT Id, Title__c from Simpplr_Content__c where Id =:soqlParam1';
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						List<simpplr_content__c> contentObjectList = (List<simpplr_content__c>)SIMPESAPI.accessController().queryAsUser(contentQuery, soqlParamMap);
						if(!contentObjectList.isEmpty()){
							contentName = contentObjectList[0].Title__c;
						}
					}
				}

				requestBody.put('account_id',SimpplrContext.simpplrOrgId);
				requestBody.put('department_name',peopleObject[0].Department__c);
				requestBody.put('city',peopleObject[0].city__c);
				requestBody.put('state',peopleObject[0].state__c);
				requestBody.put('country',peopleObject[0].country__c);
				requestBody.put('user_id',peopleObject[0].Id);
				requestBody.put('user_name',peopleObject[0].Full_Name__c);
				requestBody.put('comment_datetime',datetime.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
				requestBody.put('comment',comment);
				requestBody.put('type',postType);
				requestBody.put('content_id',contentId);
				requestBody.put('site_id',siteId);
				requestBody.put('content_name',contentName);
				requestBody.put('site_name',siteName);
				requestBody.put('is_feedpost',isFeedPost);
				requestBody.put('comment_id',commentId);
				requestBody.put('is_comment_deleted',isDeleted);
				requestBody.put('is_comment_updated',isUpdated);
				requestBody.put('is_comment_removed',isRemoved);
				requestBody.put('site_url',siteUrl);
				requestBody.put('content_url',contentUrl);
				requestBody.put('user_image_url',peopleObject[0].User__r.SmallPhotoURL.endsWith('005/T') ? null : peopleObject[0].User__r.SmallPhotoURL);
				requestBody.put('user_url',PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + peopleObject[0].User_Id__c);
                if(SimpplrContext.isSegmentsEnabled){
                	requestBody.put('segment_id',peopleObject[0].Segment__c);
					requestBody.put('segment_name',peopleObject[0].Segment__r.Name__c);
                }

				if(postType.equalsIgnoreCase('REPLY')) {
					soqlParamMap.put('soqlParam1', commentId);
					String feedIdQuery = 'SELECT FeedItemId FROM FeedComment WHERE Id =:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<FeedComment> feedCommentList = (List<FeedComment>)SIMPESAPI.accessController().queryAsUser(feedIdQuery, soqlParamMap);
					if(!feedCommentList.isEmpty()){
						feedId = feedCommentList[0].FeedItemId;
                        requestBody.put('feed_id',feedId);
					}
				}

				requestBody.put('source','CORE');
				HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/ai-es-analysis/emotion', requestBody);
				if (res.getStatusCode() != 200) {
					logger.logError('ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo()----status code----' + res.getStatusCode());
					logger.logError('ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo()----response body----' + res.getBody());
					throw new SimpplrException(String.valueOf(res.getStatusCode()));
				}
			}
		
		} catch(Exception e){
			logger.logError('ConnectAPIInteractionDataServer.sendEmotionAndSentimentInfo()----Exception Occured----', e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
    }
	
}