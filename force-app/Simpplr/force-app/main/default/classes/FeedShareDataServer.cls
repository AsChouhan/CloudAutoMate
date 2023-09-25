public with sharing class FeedShareDataServer extends DataServer {
    private final String REQUEST_PARAM_DATA = 'data';
    
    public override void handleRequest () {
    	Criteria.Feed criteriaFeedObj = new Criteria.Feed();
    	
    	try {
    		String requestData = readParam(REQUEST_PARAM_DATA); 
	        criteriaFeedObj = (Criteria.Feed)JSON.deserialize(requestData, Criteria.Feed.class);
	        
	        if (criteriaFeedObj.action != null && criteriaFeedObj.action.equalsIgnoreCase('sharefeed')) {
    			response = shareFeedElement(criteriaFeedObj.communityId, criteriaFeedObj.subjectId,
    					criteriaFeedObj.feedElementType, criteriaFeedObj.originalFeedElementId, 
    					criteriaFeedObj.commentText, criteriaFeedObj.bodyJson);
    		}
    		
		} catch (exception e) {
			logger.logError('ConnectAPIInteractionDataServer.handleRequest()-----could not retrieve data----',e);
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
    }
    
    public ResponseWrapper shareFeedElement (String communityIdArg, String subjectIdArg,
    		String feedElementTypeArg, String originalFeedElementIdArg, String commentTextArg, String commentBodyJson) {
    	ResponseWrapper responseToReturn = new  ResponseWrapper();
		FeedElementWrapper feedElementWrappObj = new FeedElementWrapper();
		
		if (subjectIdArg != null && subjectIdArg.startsWith('005')){
			subjectIdArg = 'me'; 
		}
		
		feedElementWrappObj =  feedElementShare(communityIdArg, subjectIdArg,
				feedElementTypeArg, originalFeedElementIdArg, commentTextArg, commentBodyJson);
		feedElementWrappObj.includeInFeedOnPage = true;
		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Successfully shared the feed.', feedElementWrappObj);
    	return responseToReturn; 
    }
    
    
    public static FeedElementWrapper feedElementShare(String communityIdArg, String subjectIdArg,
    		String feedElementTypeArg, String originalFeedElementIdArg, String commentTextArg, String commentBodyJson) {
    	try {
    		List<FeedItem> listOfFeedItem = [SELECT Type, LinkUrl, Id 
    				FROM FeedItem WHERE id=:originalFeedElementIdArg WITH SECURITY_ENFORCED];
    		Boolean isLinkPost = false;
    		
    		if (!listOfFeedItem.isEmpty()) {
    			
    			if (listOfFeedItem[0].Type == 'LinkPost') {
    				isLinkPost = true;
    				
    			} else {
    				isLinkPost = false;
    			}
    			
    		}
    		
    		if (isLinkPost) {
				Boolean isSimpplrContentLink = false;
				Boolean isCampaignLink = false;
				String urlToProcess = listOfFeedItem[0].LinkUrl;
				
				if(FeedUtility.isSimpplrContentLink(urlToProcess)) {
					isSimpplrContentLink = true;
				
				}  else if (urlToProcess.containsIgnoreCase('app') && urlToProcess.containsIgnoreCase('campaignId')){
					isCampaignLink = true;	
				}
				 
				ConnectApi.FeedElement feedElementObj = ConnectApi.chatterFeeds.shareFeedElement(communityIdArg,
    				subjectIdArg, ConnectApi.FeedElementType.FeedItem, originalFeedElementIdArg);
	    				
	    		if ((commentTextArg != null && commentTextArg.trim().length() > 0)||(commentBodyJson !=null && commentBodyJson.length()>5)) {
					ConnectApi.Comment commentObj = FeedConnectAPIService.postCommentToFeedElement(communityIdArg, 
							feedElementObj.Id, commentTextArg, commentBodyJson,null);
				}
				
				feedElementObj = FeedConnectAPIService.getFeedElement(communityIdArg, feedElementObj.Id);
				FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();

				if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					FeedDataAdapter.getUserIdsToConvert(feedElementObj);
					FeedDataAdapter.getPeopleFromUserIds();
				}

				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
				FeedServiceProvider.processFeedLink(isSimpplrContentLink, isCampaignLink, urlToProcess, feedElementObj, feedElementWrapperObj);
				
	    		return feedElementWrapperObj; 
				
    		} else {
    		
	    		ConnectApi.FeedElement feedElementObj = ConnectApi.chatterFeeds.shareFeedElement(communityIdArg,
    				subjectIdArg, ConnectApi.FeedElementType.FeedItem, originalFeedElementIdArg);
	    		
	    		if ((commentTextArg != null && commentTextArg.trim().length() > 0) ||(commentBodyJson !=null && commentBodyJson.length()>5)) {
					ConnectApi.Comment commentObj = FeedConnectAPIService.postCommentToFeedElement(communityIdArg, 
							feedElementObj.Id, commentTextArg,commentBodyJson,null);
				}
				
				feedElementObj = FeedConnectAPIService.getFeedElement(communityIdArg, feedElementObj.Id);
	    		FeedElementWrapper feedElementWrapperObj = new FeedElementWrapper();
				
				if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					FeedDataAdapter.getUserIdsToConvert(feedElementObj);
					FeedDataAdapter.getPeopleFromUserIds();
				}

				feedElementWrapperObj = FeedDataAdapter.convertFeedElementToWrapper(feedElementObj); 
	    		return feedElementWrapperObj; 
    		}
    		
    	} catch (Exception e) {
    		
    		if (e.getMessage() =='ConnectAPI hourly Limit') {
				/**	RestAPI implementations **/
			}
			
    		throw e;
    	}
    }
    
}