/**
* Class [AIDataServer] 
* Purpose:  [This class is a controller class for all the actions related to AI features]
*
*/
public with sharing class AIDataServer extends DataServer{ 
	
	private final String REQUEST_PARAM_DATA = 'data';
    private final String ACTION_GET_MODERATION_QUEUE = 'getModerationQueue';
  	private final String ACTION_CHECK_CONTENT_TOXICITY = 'checkCommentToxicity';
	private final String ACTION_MARK_MODERATION_ITEM_DISMISSED = 'markModerationItemDismissed';
	private final String ACTION_MARK_MODERATION_ITEM_REMOVED = 'markModerationItemRemoved';
	private final String ACTION_REPORT_CONTENT = 'reportContent';
	private final String ACTION_GET_FILTERS_DATA = 'getFiltersData';
	private final String ACTION_GET_MODERATION_HISTORY= 'getModerationHistory';
    private final String ACTION_GET_MODERATION_FILTERS = 'getHistoryFiltersData';


    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try {
        	
        	logger.logDebug('AIDataServer----entered handleRequest----');
        	String action = readParam(REQUEST_PARAM_ACTION);
	    	String requestData = readParam(REQUEST_PARAM_DATA);
        	if(ACTION_CHECK_CONTENT_TOXICITY.equalsIgnoreCase(action)){
            response = checkCommentToxicity(requestData);
			}else if(ACTION_MARK_MODERATION_ITEM_DISMISSED.equalsIgnoreCase(action)){
				response = markModerationItemDismissed(requestData);
			}else if(ACTION_MARK_MODERATION_ITEM_REMOVED.equalsIgnoreCase(action)){
				response = markModerationItemRemoved(requestData);
			}else if(ACTION_REPORT_CONTENT.equalsIgnoreCase(action)){
				response = reportContent(requestData);
			}else if(ACTION_GET_MODERATION_QUEUE.equalsIgnoreCase(action)){
				response = getModerationQueue(requestData);
			}else if(ACTION_GET_FILTERS_DATA.equalsIgnoreCase(action)){
				response = getFiltersData();
			}else if(ACTION_GET_MODERATION_HISTORY.equalsIgnoreCase(action)){
				response = getModerationHistory(requestData);
			}else if(ACTION_GET_MODERATION_FILTERS.equalsIgnoreCase(action)){
				response = getModerationHistoryFilters();
			}else{
				throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
			}
            
        } catch (Exception ex) {
			logger.logError('AIDataServer.handleRequest()---Exception occured----', ex);
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
	}
	
	/**
     * @description This method is used to check Comment Toxicity
     * @param requestData 
     * @return  `ResponseWrapper`
    */
    @TestVisible
	private ResponseWrapper checkCommentToxicity(String requestData) {
		logger.logDebug('checkCommentToxicity()--'+requestData);
		ResponseWrapper localResult = null;
		try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			String text = (requestDataMap!= null && requestDataMap.containsKey('text')) ? String.valueOf(requestDataMap.get('text')) : null;
			AIDataProvider aiDataProviderObj = new AIDataProvider();
			AIWrapper.CommentsToxicityWrapper commentToxicityWrapperObj = aiDataProviderObj.getToxicityDetails(text);
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, commentToxicityWrapperObj);
		} catch(Exception ex) {
			logger.logError('AIDataServer.checkCommentToxicity()---Exception occured----', ex);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}
	
	/**
     * @description This method is used to get Moderation Queue Details
     * @param requestData 
     * @return  `ResponseWrapper`
    */
    @TestVisible
	private ResponseWrapper getModerationQueue(String requestData) {
		logger.logDebug('getModerationQueue()--'+requestData);
		ResponseWrapper localResult = null;
		try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			AIDataProvider aiDataProviderObj = new AIDataProvider();
			AIWrapper.ModerationQueueWrapper moderationQueueWrapObj = new AIWrapper.ModerationQueueWrapper();
			moderationQueueWrapObj = aiDataProviderObj.getModerationQueue(requestDataMap);
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, moderationQueueWrapObj);
		} catch(Exception ex) {
			logger.logError('AIDataServer.getModerationQueue()---Exception occured----', ex);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}

	/**
	 * @description This method is used to mark the moderation item as dismissed
	 * @param requestData
	 * @return ResponseWrapper
	 */
	 @TestVisible
	 private ResponseWrapper markModerationItemDismissed(String requestData){
		logger.logDebug('markModerationItemDismissed()-----'+requestData);
		ResponseWrapper responseWrapperObj = null;
		try{
			if(String.isBlank(requestData)){
				throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
			}

			Map<String,Object> requestDataMap = (Map<String,Object>) JSON.deserializeUntyped(requestData);
			String moderationItemId = (requestDataMap!= null && requestDataMap.containsKey('moderationItemId')) ? String.valueOf(requestDataMap.get('moderationItemId')) : null;
			String type = (requestDataMap!= null && requestDataMap.containsKey('type')) ? String.valueOf(requestDataMap.get('type')) : null;
			if((UserContext.isContentModerator || UserContext.isUserAppModerator) && SimpplrContext.aiContentModerationEnabled){
				AIDataProvider aiDataProviderObj = new AIDataProvider();
				aiDataProviderObj.markModerationItemDismissed(moderationItemId,type);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			}else{
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			}

		} catch(Exception ex) {
			logger.logError('AIDataServer.markModerationItemDismissed()----Exception occured----',ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	 }

	 /**
	 * @description This method is used to mark the moderation item as removed
	 * @param requestData
	 * @return ResponseWrapper
	 */
	@TestVisible
	private ResponseWrapper markModerationItemRemoved(String requestData){
	   logger.logDebug('markModerationItemRemoved()-----'+requestData);
	   ResponseWrapper responseWrapperObj = null;
	   try{
		   if(String.isBlank(requestData)){
			   throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		   }

		   Map<String,Object> requestDataMap = (Map<String,Object>) JSON.deserializeUntyped(requestData);
		   String moderationItemId = (requestDataMap!= null && requestDataMap.containsKey('moderationItemId')) ? String.valueOf(requestDataMap.get('moderationItemId')) : null;
		   String type = (requestDataMap!= null && requestDataMap.containsKey('type')) ? String.valueOf(requestDataMap.get('type')) : null;
		   if((UserContext.isContentModerator || UserContext.isUserAppModerator) && SimpplrContext.aiContentModerationEnabled){
				AIDataProvider aiDataProviderObj = new AIDataProvider();
				aiDataProviderObj.markModerationItemRemoved(moderationItemId,type);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		   }else{
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		   }
	   } catch(Exception ex) {
		   logger.logError('AIDataServer.markModerationItemRemoved()----Exception occured----',ex);
		   responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	   }
	   return responseWrapperObj;
	}

	 /** @description This method is used to report a comment/feed/reply
	 * @param requestData
	 * @return ResponseWrapper
	 */
	@TestVisible
	private ResponseWrapper reportContent(String requestData){
		logger.logDebug('reportContent()-----'+requestData);
		ResponseWrapper responseWrapperObj = null;
		try {
			if(String.isBlank(requestData)){
				throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
			}
			
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			AIDataProvider aiDataProviderObj = new AIDataProvider();
			
			String reportAction = (requestDataMap!= null && requestDataMap.containsKey('action')) ? String.valueOf(requestDataMap.get('action')) : null;
			String reporterId = (requestDataMap!= null && requestDataMap.containsKey('reporterId')) ? String.valueOf(requestDataMap.get('reporterId')) : null;
			List<String> reportReason = new List<String>();
			if(requestDataMap!= null && requestDataMap.containsKey('reportReason')) {
				reportReason.add(String.valueOf(requestDataMap.get('reportReason')));
			}
			String feedOrCommentId;
			String feedOrCommentText;
			String type;
			if(!String.isBlank(reportAction) && reportAction.equalsIgnoreCase('reportComment')){
				feedOrCommentId = (requestDataMap!= null && requestDataMap.containsKey('itemId')) ? String.valueOf(requestDataMap.get('itemId')) : null;
				feedOrCommentText = (requestDataMap!= null && requestDataMap.containsKey('itemText')) ? String.valueOf(requestDataMap.get('itemText')) : null;
				type = 'reply';
			}else if(!String.isBlank(reportAction) && reportAction.equalsIgnoreCase('reportFeed')){
				feedOrCommentId = (requestDataMap!= null && requestDataMap.containsKey('itemId')) ? String.valueOf(requestDataMap.get('itemId')) : null;
				feedOrCommentText = (requestDataMap!= null && requestDataMap.containsKey('itemText')) ? String.valueOf(requestDataMap.get('itemText')) : null;
				type = 'post';
			}else{
				throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
			}

			aiDataProviderObj.sendReportedContentDetailsToMS(reporterId,reportReason,feedOrCommentId,feedOrCommentText,type);

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			
		} catch (Exception ex) {
			logger.logError('AIDataServer.reportContent()----Exception occured----',ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}

	/**
     * @description This method is used to get Moderation History Details
     * @param requestData 
     * @return  `ResponseWrapper`
    */
    @TestVisible
	private ResponseWrapper getModerationHistory(String requestData) {
		logger.logDebug('getModerationHistory()--'+requestData);
		ResponseWrapper localResult = null;
		try {
			Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
			AIDataProvider aiDataProviderObj = new AIDataProvider();
			AIWrapper.ModerationQueueWrapper moderationHistoryWrapObj = new AIWrapper.ModerationQueueWrapper();
			moderationHistoryWrapObj = aiDataProviderObj.getModerationHistory(requestDataMap);
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, moderationHistoryWrapObj);
		} catch(Exception ex) {
			logger.logError('AIDataServer.getModerationHistory()---Exception occured----', ex);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}

	/**
     * @description This method is used to get Moderation History Filter Details
     * @param requestData 
     * @return  `ResponseWrapper`
    */
    @TestVisible
	private ResponseWrapper getModerationHistoryFilters() {
		logger.logDebug('getModerationHistoryFilters()--');
		ResponseWrapper localResult = null;
		try {
			AIDataProvider aiDataProviderObj = new AIDataProvider();
			AIWrapper.HistoryFiltersWrapper historyFiltersWrapObj = aiDataProviderObj.getModerationFilters();
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, historyFiltersWrapObj);
		} catch(Exception ex) {
			logger.logError('AIDataServer.getModerationFilters()---Exception occured----', ex);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}


	/**
     * @description This method is used to find all filters data
     * @return  `ResponseWrapper`
    */
    @TestVisible
	private ResponseWrapper getFiltersData() {
		logger.logDebug('getFiltersData()--');
		ResponseWrapper localResult = null;
		try {
			AIDataProvider aiDataProviderObj = new AIDataProvider();
			AIWrapper.FiltersDataWrapper filtersDataWrapperObj = aiDataProviderObj.getFiltersData();
			
        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filtersDataWrapperObj);
		} catch(Exception ex) {
			logger.logError('AIDataServer.getFiltersData()---Exception occured----', ex);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return localResult;
	}
}