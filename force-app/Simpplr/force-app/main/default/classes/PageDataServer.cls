/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PageDataServer extends DataServer {
	
	private final String ACTION_VALUE_SEARCH = 'search';
    private final String REQUEST_PARAM_DATA = 'data';
    
	public PageDataServer() {
		
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
        	logger.logDebug('PageDataServer----entered handleRequest----');

        	String action = readParam(REQUEST_PARAM_ACTION);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
    		if (String.isNotBlank(SiteContext.chatterGroupId) && !SiteContext.showInSimpplr) {
    			redirectUrl = SimpplrContext.salesforceBaseUrl + '/'+SiteContext.chatterGroupId;
			    throw new SimpplrException(ServiceConstants.ERROR_404);
    		}
    		
            
            if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
            	
               	String requestData = readParam(REQUEST_PARAM_DATA);
        		Criteria.Pages criteriaPagesObj = (Criteria.pages)JSON.deserialize(requestData, Criteria.Pages.class);
        		
        		if(criteriaPagesObj.groupCategories != null && criteriaPagesObj.groupCategories) {
        			 response = getSitePagesGroupByCategories(criteriaPagesObj);
        		} else {
        			response = getPages(criteriaPagesObj);
        		}
            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }

        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	
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
    private ResponseWrapper getPages(Criteria.Pages contentCriteriaObjArg){
		logger.logDebug('PageDataServer.getPages()----contentCriteriaObjArg----'+contentCriteriaObjArg);
		ResponseWrapper responseToReturn = null;
	    	List<ContentWrapper> listOfContentWrapper = null;
	    	try{
			contentCriteriaObjArg.offset = contentCriteriaObjArg.nextPageToken == null ? 0 : Integer.valueOf(contentCriteriaObjArg.nextPageToken);
    		
	    		ContentDataProvider providerObj = new ContentDataProvider(); 
		    	listOfContentWrapper = providerObj.getPagesSearchResults(contentCriteriaObjArg);
		    	
		        Map<String, Object> resultMap = new Map<String, Object>(); 
		        Integer nextPageToken;
	        	if (listOfContentWrapper.size() == (contentCriteriaObjArg.size + 1) && contentCriteriaObjArg.offset < 2000) {
	        		listOfContentWrapper.remove((listOfContentWrapper.size()-1));
	        		nextPageToken = contentCriteriaObjArg.offset + contentCriteriaObjArg.size;	
	        	}
			Integer contentCountsPerCategory = providerObj.getContentCounts(contentCriteriaObjArg);
	        resultMap.put('nextPageToken' , nextPageToken);
	        resultMap.put('listOfItems' , listOfContentWrapper);
			resultMap.put('totalRecords' , contentCountsPerCategory);
	        resultMap.put('popularTopics',providerObj.getPopularTopics(contentCriteriaObjArg));
		    responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
		    logger.logDebug('PageDataServer.getPages()----responseToReturn----'+responseToReturn);
	     } catch(Exception e) {
	        	logger.logError('PageDataServer.getPages()----Could not fetch pages',e);
	        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(e.getMessage()), null);
        }
    	return responseToReturn;
    }
    
    private ResponseWrapper getSitePagesGroupByCategories (Criteria.Pages pagesCriteriaObjArg) {
    	logger.logDebug('PageDataServer.getSitePagesGroupByCategories()----pagesCriteriaObjArg----'+pagesCriteriaObjArg);
    	ResponseWrapper responseToReturn = null;
    	
    	List<PageListingWrapper.CategoryWrapper> listOfCategoryWrapper = new List<PageListingWrapper.CategoryWrapper>();
    	try{
    		
    		if (pagesCriteriaObjArg.nextPageToken == null) {
    			pagesCriteriaObjArg.offset = 0;
    			
    		} else {
    			pagesCriteriaObjArg.offset = Integer.valueOf(pagesCriteriaObjArg.nextPageToken);
    		}
			listOfCategoryWrapper = ContentDataProvider.getSitePagesGroupByCategories(pagesCriteriaObjArg);
			
	        PageListingWrapper.IndexPaginationWrapper categoryPagination = new PageListingWrapper.IndexPaginationWrapper();
	        categoryPagination.canSort = false;
	        //ToDo - True Only if user has content publish access in site
	        if(UserContext.sitesIManageIdSet.contains(SiteContext.siteId) || (UserContext.isUserAppModerator && SiteContext.isPrivateSite==false) || UserContext.hasModifyAllDataPermission){
	        	categoryPagination.canSort = true;
	        }
	        categoryPagination.listOfItems.addAll(listOfCategoryWrapper);
	        
	        if (categoryPagination.listOfItems.size() == (pagesCriteriaObjArg.size + 1) &&
	        		pagesCriteriaObjArg.offset < 2000) {
	        	categoryPagination.listOfItems.remove((categoryPagination.listOfItems.size()-1));
	        	categoryPagination.nextPageToken = String.valueOf(pagesCriteriaObjArg.offset + pagesCriteriaObjArg.size);
	        } else {
	        	categoryPagination.nextPageToken = null;
	        }
	        
	        responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, categoryPagination); 
			logger.logDebug('PageDataServer.getSitePagesGroupByCategories()----responseToReturn----'+responseToReturn);
		} catch(Exception e) {
	    	logger.logError('PageDataServer----Could not fetch site pages grouped by categories',e);
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
    	return responseToReturn;
	}
}