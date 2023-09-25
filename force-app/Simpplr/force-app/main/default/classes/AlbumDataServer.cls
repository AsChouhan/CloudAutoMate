/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AlbumDataServer extends DataServer{
	
    @TestVisible private final String ACTION_VALUE_SEARCH = 'search'; 
    
    @TestVisible private final String REQUEST_PARAM_DATA = 'data';
    
    public AlbumDataServer() {

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
        
        try {
        	logger.logDebug('AlbumDataServer----entered handleRequest----');
	    	
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
	        	Criteria.Album criteriaAlbumObj = (Criteria.Album)JSON.deserialize(requestData, Criteria.Album.class);
	        	response = getAlbums(criteriaAlbumObj);
                
            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), new ResponseWrapper());
       		
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
    private ResponseWrapper getAlbums (Criteria.Album contentCriteriaObjArg) {
    	logger.logDebug('AlbumDataServer.getAlbums()----contentCriteriaObjArg----'+contentCriteriaObjArg);
    	ResponseWrapper responseToReturn = null;
    	
    	List<ContentWrapper> listOfContentWrapper = null;
    	try{
    		
    		contentCriteriaObjArg.offset = contentCriteriaObjArg.nextPageToken == null ? 0 : Integer.valueOf(contentCriteriaObjArg.nextPageToken);
			
			ContentDataProvider providerObj = new ContentDataProvider(); 
			listOfContentWrapper = providerObj.getAlbumsSearchResults(contentCriteriaObjArg);
	    	
	        Map<String, Object> resultMap = new Map<String, Object>(); 
	        Integer nextPageToken;
        	if (listOfContentWrapper.size() == (contentCriteriaObjArg.size + 1) && contentCriteriaObjArg.offset < 2000) {
        		listOfContentWrapper.remove((listOfContentWrapper.size()-1));
        		nextPageToken = contentCriteriaObjArg.offset + contentCriteriaObjArg.size;	
        	}
            AlbumDao daoObj = new AlbumDao();
            Integer totalRecords = daoObj.getTotalAlbumRecords(contentCriteriaObjArg);
            resultMap.put('totalRecords' , totalRecords);
	        resultMap.put('nextPageToken' , nextPageToken);
	        resultMap.put('listOfItems' , listOfContentWrapper);
	        
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
	     } catch(Exception e) {
        	logger.logError('Could not retrieve albums',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('AlbumDataServer.getAlbums()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
    }
    
}