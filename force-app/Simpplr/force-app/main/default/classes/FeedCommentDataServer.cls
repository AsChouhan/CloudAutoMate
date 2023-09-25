/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FeedCommentDataServer extends DataServer {
	private final String REQUEST_PARAM_DATA = 'data';
	
	public FeedCommentDataServer() {
		
	}
	
	public override void handleRequest() {
		logger.logDebug('FeedCommentDataServer----entered handleRequest----');
		
		String requestData = readParam(REQUEST_PARAM_DATA);
	  	Criteria.Feed criteriaFeedObj = (Criteria.Feed)JSON.deserialize(requestData, Criteria.Feed.class);
	   	response = getFeedComments(criteriaFeedObj);
	}
	
	private  ResponseWrapper getFeedComments (Criteria.Feed feedCriteriaObj) {
		logger.logDebug('FeedCommentDataServer.getFeedComments()----feedCriteriaObj----'+feedCriteriaObj);
		ResponseWrapper responseToReturn = null;
		RecentCommentsContainerWrapper commentContainerObj = null;
		try {
			
			if (feedCriteriaObj.postId != null && feedCriteriaObj.size != null ) {
				ConnectApi.CommentPage commentPageObj = FeedConnectAPIService.getCommentsForFeedElement(null, 
						feedCriteriaObj.postId, feedCriteriaObj.nextPageToken, Integer.valueOf(feedCriteriaObj.size));

				if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					FeedDataAdapter.getUserIdsToConvert(commentPageObj);
					FeedDataAdapter.getPeopleFromUserIds();
				}
				
				commentContainerObj = FeedDataAdapter.convertCommentPageToWrapper(commentPageObj);
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, commentContainerObj);
		 			
			} else {
			
		 		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			}
			 
	    } catch (Exception e) {
        	logger.logError('Could not retrieve feed comments',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('FeedCommentDataServer.getFeedComments()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
	}
}