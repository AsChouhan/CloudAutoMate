/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class EventDataServer extends DataServer {
	
	@TestVisible private final String ACTION_VALUE_SEARCH = 'search'; 
    private final String REQUEST_PARAM_DATA = 'data';
    
	public EventDataServer() {

    }
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest() {
    		String redirectUrl = '';
        try{
        	
        	logger.logDebug('EventDataServer----entered handleRequest----');
	    	
        	String action = readParam(REQUEST_PARAM_ACTION);
        	
            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if (String.isNotBlank(SiteContext.chatterGroupId) && !SiteContext.showInSimpplr) {
	    			redirectUrl = SimpplrContext.salesforceBaseUrl + '/'+SiteContext.chatterGroupId;
				    throw new SimpplrException(ServiceConstants.ERROR_404);
	    		}
            
            if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
               	String requestData = readParam(REQUEST_PARAM_DATA);
				Criteria.Event criteriaEventObj = (Criteria.Event)JSON.deserialize(requestData, Criteria.Event.class);
				if('google'.equalsIgnoreCase(criteriaEventObj.source)) {
					response = getGoogleCalendarEvents(criteriaEventObj);
				} else {
					response = getEvents(criteriaEventObj);
				}
	        	
            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        }catch(Exception ex) {
			logger.logError('Either no page access or action parameter returning wrong data',ex);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
			if(String.isNotBlank(redirectUrl)) {
	        		response.redirectUrl = redirectUrl;
	        	}
        }
        
    } 
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible 
    private ResponseWrapper getEvents (Criteria.Event contentCriteriaObjArg) {
    	logger.logDebug('EventDataServer.getEvents()----contentCriteriaObjArg----'+contentCriteriaObjArg);
    	ResponseWrapper responseToReturn = null;
    	List<ContentWrapper> listOfContentWrapper = null;
    	try{
			contentCriteriaObjArg.offset = contentCriteriaObjArg.nextPageToken == null ? 0 : Integer.valueOf(contentCriteriaObjArg.nextPageToken);
    		
    		ContentDataProvider providerObj = new ContentDataProvider(); 
    		if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(contentCriteriaObjArg.term)) {
				Criteria.ExternalSearchReq eventCriteria = new Criteria.ExternalSearchReq();
		        eventCriteria.term = contentCriteriaObjArg.term;
				eventCriteria.nextPageToken = contentCriteriaObjArg.nextPageToken;
				eventCriteria.authoredBy=contentCriteriaObjArg.authoredBy;
				eventCriteria.size=contentCriteriaObjArg.size;
				eventCriteria.filter=contentCriteriaObjArg.filter;
				eventCriteria.source=contentCriteriaObjArg.source;
				eventCriteria.type='Event';
				String searchForType='Content';
				ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
				ExternalSearchWrapper.TopContentsWrapper externalSearchResponse = new ExternalSearchWrapper.TopContentsWrapper();
				externalSearchResponse =externalSearchServiceObj.searchContents(eventCriteria,searchForType);
				List<String> contentIds = new List<String>();
				if(externalSearchResponse.listOfItems != null && externalSearchResponse.listOfItems.size() > 0) {
					contentIds = getContentIdsFromAWSResponse(externalSearchResponse.listOfItems);
				}
				listOfContentWrapper = providerObj.getEventDataFromSF(contentIds);
		    }else{
				listOfContentWrapper = providerObj.getEventsSearchResults(contentCriteriaObjArg);
			}
			Map<String, Object> resultMap = new Map<String, Object>(); 
			Integer nextPageToken;
			if (listOfContentWrapper.size() == (contentCriteriaObjArg.size + 1) && contentCriteriaObjArg.offset < 2000) {
				listOfContentWrapper.remove((listOfContentWrapper.size()-1));
				nextPageToken = contentCriteriaObjArg.offset + contentCriteriaObjArg.size;	
			}
			resultMap.put('nextPageToken' , nextPageToken);
	        resultMap.put('listOfItems' , listOfContentWrapper);
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
	     } catch(Exception e) {
        	logger.logError('Could not retrieve events',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('EventDataServer.getEvents()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
	}
	
	private ResponseWrapper getGoogleCalendarEvents (Criteria.Event contentCriteriaObjArg) {
    	logger.logDebug('EventDataServer.getGoogleCalendarEvents()----contentCriteriaObjArg----'+contentCriteriaObjArg);
    	ResponseWrapper responseToReturn = null;
    	List<ContentWrapper> listOfContentWrapper = null;
    	try{   		
			contentCriteriaObjArg.calendarId = 'primary';
			GoogleCalendarHelper helperObj = new GoogleCalendarHelper(); 
    		Map<String, Object> resultMap = helperObj.getEventsSearchResults(contentCriteriaObjArg);	        
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
	     } catch(Exception e) {
        	logger.logError('Could not retrieve events',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('EventDataServer.getGoogleCalendarEvents()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
    }
	private List<String> getContentIdsFromAWSResponse(List<ExternalSearchWrapper.ItemWrapper> listOfItems) {
		List<String> contentIds = new List<String>();

		for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : listOfItems) {
			Object item = itemWrapperObj.item;
			ContentWrapper clWrapper = (ContentWrapper)item;

			contentIds.add(clWrapper.id);
		}
		return contentIds;
	}
}