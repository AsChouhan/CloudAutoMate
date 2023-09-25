public with sharing class MobileSearchDataServer extends DataServer{
	
	private final String REQUEST_PARAM_DATA = 'data';
	private final String SEARCH_TYPE_ARG = 'searchForType';
	private final String ACTION_VALUE_SAVE_SEARCH_STATS = 'saveSearchStats';
    private String loggedInPeopleId = UserContext.peopleId;
	
	public MobileSearchDataServer() {
    }
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileSearchDataServer&action=search search
	 * @apiVersion 1.0.0
	 * @apiGroup MobileSearchDataServer
	 * @apiName search
	 *
	 * @apiParam (Query Parameter) {String} action search
	 * @apiParam (Query Parameter) {String} searchForType Content/People/File
	 * @apiParam (Post Parameter) {String} data {"term":"SEARCH_TEXT","siteId":optional,"section":"Content/People/File","size":16}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for searching content, people or file based on serach term
	 * @apiSuccess {List[String]} listOfItems list of content
	 * @apiSuccess {List[String]} listOfItems list of people
	 * @apiSuccess {FileListingWrapper[]} result list of files
	 * @apiUse FileListingWrapper
	 * @apiError SimpplrException Simpplr Exception
	 */	   
    public override void handleRequest() {
        try{
        	logger.logDebug('MobileSearchDataServer----entered handleRequest----');
			String action = readParam(REQUEST_PARAM_ACTION);
            String data = readParam(REQUEST_PARAM_DATA);	
            String searchForType = readParam(SEARCH_TYPE_ARG);
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            } else {
				if('Content'.equalsIgnoreCase(searchForType)){
					response = searchContents(data);
				} else if('People'.equalsIgnoreCase(searchForType)){
					response = searchPeople(data);
				} else if('File'.equalsIgnoreCase(searchForType)){
					response = searchFiles(data);
				} else if('Site'.equalsIgnoreCase(searchForType)){
					response = searchSite(data);
				} else if(ACTION_VALUE_SAVE_SEARCH_STATS.equalsIgnoreCase(action)) {
	            		response = saveSearchStats(data);
	            } else{
				    	throw new SimpplrException('Search type not supported');
				}
	            	Map<String,Object> searchCriteria = (Map<String,Object>)JSON.deserializeUntyped(data);
	            	String term = String.valueOf(searchCriteria.get('term') != null?searchCriteria.get('term'):'');
	    			String siteId = String.valueOf(searchCriteria.get('siteId')!=null ?searchCriteria.get('siteId'):'');
	            	Utility.insertMobileAnalyticsRecord('Search',new Map<String,String>{'term'=>term, 'siteId'=>siteId, 'userAgent'=>readHeader('User-Agent')});
            }
            
        }catch(Exception ex) {
        	logger.logError('Exception occured',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
    public ResponseWrapper searchContents(String requestData){
		ResponseWrapper responseWrapperObj;
	    	logger.logDebug('MobileSearchDataServer.searchContents()-----');
	    	Map<String,Object> result = new Map<String,Object>();
	    	List<Object>contentList = new List<Object>();
	    	
		try{
		
			Map<String,Object> contentSearchCriteria = (Map<String,Object>)JSON.deserializeUntyped(requestData);
        	Integer size = Integer.valueOf(contentSearchCriteria.get('size'));
        	contentSearchCriteria.put('origin', 'mobile');
        	Integer offset = Integer.valueOf(contentSearchCriteria.get('nextPageToken')) > 0?
    		Integer.valueOf(contentSearchCriteria.get('nextPageToken')) : 0;
        	
        	if(SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected){
				ExternalSearchService searchExternalService = new ExternalSearchService();
				Criteria.ExternalSearchReq contentSearchCriteriaArg = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				ExternalSearchWrapper.TopContentsWrapper searchResultWrapper = searchExternalService.searchContents(contentSearchCriteriaArg, 'content');
				contentList = convertToObjectList(searchResultWrapper.listOfItems);
				result.put('nextPageToken', searchResultWrapper.nextPageToken);
			}else{
        		GlobalSearchService searchService = new GlobalSearchService();
        		contentList = (List<Object>)searchService.searchContents(contentSearchCriteria).get('contents');
				if (contentList != NULL && contentList.size() == (size + 1) && offset < 2000) {
					contentList.remove((contentList.size()-1));
					result.put('nextPageToken',offset+size);
				} else {
					result.put('nextPageToken',null);
				}
			}				
			result.put('listOfItems', contentList);
		  	
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        	logger.logDebug('MobileSearchDataServer.searchContents()-----responseWrapperObj----' + responseWrapperObj);
        	String term = String.valueOf(contentSearchCriteria.get('term') != null?contentSearchCriteria.get('term'):'');
    		String siteId = String.valueOf(contentSearchCriteria.get('siteId')!=null ?contentSearchCriteria.get('siteId'):'');
	        	
		} catch(Exception ex){
			logger.logError('MobileSearchDataServer.searchContents()---Could not retrieve contents',ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
    }
    
    public ResponseWrapper searchPeople(String requestData){
		ResponseWrapper responseWrapperObj;
	    	List<Object> peopleSearchList = new List<Object>();
	    	Map<String,Object> result = new Map<String,Object>();
    		logger.logDebug('MobileSearchDataServer.searchPeople()-----');
		try{
        	Criteria.People peopleSearchCriteria = (Criteria.People) Json.deserialize(requestData, Criteria.People.class);
        	
        	Integer size = Integer.valueOf(peopleSearchCriteria.size);
        	peopleSearchCriteria.origin = 'mobile';
        	peopleSearchCriteria.offset = String.isNotBlank(peopleSearchCriteria.nextPageToken) && Integer.valueOf(peopleSearchCriteria.nextPageToken) > 0?
    		Integer.valueOf(peopleSearchCriteria.nextPageToken) : 0;
        	
        	
        if(SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected){
			ExternalSearchService searchExternalService = new ExternalSearchService();
			Criteria.ExternalSearchReq peopleSearchCriteriaArg = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
			ExternalSearchWrapper.TopContentsWrapper searchResultWrapper = searchExternalService.searchPeople(peopleSearchCriteriaArg, 'user');
			peopleSearchList = convertToObjectList(searchResultWrapper.listOfItems);
			result.put('nextPageToken', searchResultWrapper.nextPageToken);
			
		}else {
			GlobalSearchService searchService = new GlobalSearchService();
			peopleSearchList = searchService.searchPeople(peopleSearchCriteria);
			if (peopleSearchList != NULL && peopleSearchList.size() == (size + 1) && peopleSearchCriteria.offset < 2000) {
    			peopleSearchList.remove((peopleSearchList.size()-1));
	    		result.put('nextPageToken',peopleSearchCriteria.offset+size);
	    	} else {
	    		result.put('nextPageToken',null);
	    	}
		}
		result.put('listOfItems',peopleSearchList);
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		logger.logDebug('MobileSearchDataServer.searchPeople()-----responseWrapperObj----' + responseWrapperObj);
	        
        } catch(Exception ex){
        	logger.logError('MobileSearchDataServer.searchPeople()---Could not retrieve people list',ex);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
    }
    
    public ResponseWrapper searchSite(String requestData){
		ResponseWrapper responseWrapperObj;
	    	List<Object> siteList = new List<Object>();
	    	Map<String,Object> result = new Map<String,Object>();
    		logger.logDebug('MobileSearchDataServer.searchSite()-----');
		try{
        	Criteria.Site siteSearchCriteria = (Criteria.Site) Json.deserialize(requestData, Criteria.Site.class);
    		Integer size = Integer.valueOf(siteSearchCriteria.size);
        	siteSearchCriteria.origin = 'mobile';
        	siteSearchCriteria.offset = String.isNotBlank(siteSearchCriteria.nextPageToken) && Integer.valueOf(siteSearchCriteria.nextPageToken) > 0?
    		Integer.valueOf(siteSearchCriteria.nextPageToken) : 0;
        	
		if(SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected){
			ExternalSearchService searchExternalService = new ExternalSearchService();
			Criteria.ExternalSearchReq siteSearchCriteriaArg = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
			ExternalSearchWrapper.TopContentsWrapper searchResultWrapper = searchExternalService.searchSites(siteSearchCriteriaArg, 'site');
			siteList = convertToObjectList(searchResultWrapper.listOfItems);
			result.put('nextPageToken', searchResultWrapper.nextPageToken);
		}else{
			GlobalSearchService searchService = new GlobalSearchService();
			siteList = searchService.searchSites(siteSearchCriteria);
			if (siteList != NULL && siteList.size() == (size + 1) && siteSearchCriteria.offset < 2000) {
				siteList.remove((siteList.size()-1));
				result.put('nextPageToken',siteSearchCriteria.offset+size);
			} else {
				result.put('nextPageToken',null);
			}
		}
                
        result.put('listOfItems',siteList);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        	logger.logDebug('MobileSearchDataServer.searchSite()-----responseWrapperObj----' + responseWrapperObj);
	        
        } catch(Exception ex){
        	logger.logError('MobileSearchDataServer.searchSite()---Could not retrieve site list',ex);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
    }
    
    public ResponseWrapper searchFiles(String requestData){
		ResponseWrapper responseWrapperObj;
		Map<String,Object> result = new Map<String,Object>();
    		logger.logDebug('MobileSearchDataServer.searchFiles()-----');
		try{
        	Criteria.File fileSearchCriteria = (Criteria.File) Json.deserialize(requestData, Criteria.File.class);
        	fileSearchCriteria.offset = String.isNotBlank(fileSearchCriteria.nextPageToken) && Integer.valueOf(fileSearchCriteria.nextPageToken) > 0?
    					Integer.valueOf(fileSearchCriteria.nextPageToken) : 0;
        	List<Object> fileList;
        	
        
        if(SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected){
			ExternalSearchService searchExternalService = new ExternalSearchService();	
			Criteria.ExternalSearchReq fileSearchCriteriaArg = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);		
			ExternalSearchWrapper.TopContentsWrapper searchResultWrapper = searchExternalService.searchFiles(fileSearchCriteriaArg, 'file');
			fileList = convertToObjectList(searchResultWrapper.listOfItems);
			result.put('nextPageToken', searchResultWrapper.nextPageToken);
			
		}else{
			GlobalSearchService searchService = new GlobalSearchService();
			fileList = searchService.searchFiles(fileSearchCriteria);
			if (fileList != NULL && fileList.size() == (fileSearchCriteria.size + 1) && fileSearchCriteria.offset < 2000) {
    			fileList.remove((fileList.size()-1));
	    		result.put('nextPageToken',fileSearchCriteria.offset+ fileSearchCriteria.size);
	    	} else {
	    		result.put('nextPageToken',null);
	    	}
		}
		result.put('listOfItems',fileList);
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		
	    	
        	logger.logDebug('MobileSearchDataServer.searchFiles()-----responseWrapperObj---' + responseWrapperObj);
	        
        } catch(Exception ex){
        	logger.logError('MobileSearchDataServer.searchFiles()---Could not retrieve file list',ex);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    private ResponseWrapper saveSearchStats(String requestData) {
    		logger.logDebug('MobileSearchDataServer.saveSearchStats()-----requestData---' + requestData);
		Map<String, String> requestMap = (Map<String, String>)Json.deserialize(requestData, Map<String, String>.class);
		ResponseWrapper responseWrapperObj;
		try{
			Integer siteCount = requestMap.containsKey('siteCount') ? Integer.valueOf(requestMap.get('siteCount')) : 0;
			Integer peopleCount = requestMap.containsKey('peopleCount') ? Integer.valueOf(requestMap.get('peopleCount')) : 0;
			Integer contentCount = requestMap.containsKey('contentCount') ? Integer.valueOf(requestMap.get('contentCount')) : 0;
			Integer fileCount = requestMap.containsKey('fileCount') ? Integer.valueOf(requestMap.get('fileCount')) : 0;
			Integer totalResultCount = siteCount + peopleCount + contentCount + fileCount;
			
			Map<String, Integer> sectionCount = new Map<String, Integer>();
			sectionCount.put('Site', siteCount);
			sectionCount.put('People', peopleCount);
			sectionCount.put('Content', contentCount);
			sectionCount.put('File', fileCount);
			
			Map<String, Object> summaryMap = new Map<String, Object>();
			summaryMap.put('term', requestMap.get('term'));
			summaryMap.put('totalResultCount', totalResultCount);
			summaryMap.put('sectionCount', sectionCount);
			
			String userAgent = readHeader('USER-AGENT') != null ? readHeader('USER-AGENT') : readHeader('User-Agent');
			Simpplr_social_analytics__c ssa = new Simpplr_social_analytics__c();
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

			ssa.User__c = UserContext.id;
			ssa.People__c = UserContext.peopleId;
			ssa.Interaction__c = 'Search Stats';
			ssa.Search_Text__c= requestMap.get('term');
			ssa.User_Agent__c = String.isNotBlank(userAgent) ? userAgent.trim().left(255) : null;
			ssa.Search_Results_Summary__c  = JSON.serialize(summaryMap);
			ssa.Search_Results_Count__c =  totalResultCount;
			ssa.Origin_Mobile_App__c = true;

			fieldList.add(Simpplr_social_analytics__c.User__c);
			fieldList.add(Simpplr_social_analytics__c.People__c);
			fieldList.add(Simpplr_social_analytics__c.Interaction__c);
			fieldList.add(Simpplr_social_analytics__c.Search_Text__c);
			fieldList.add(Simpplr_social_analytics__c.User_Agent__c);
			fieldList.add(Simpplr_social_analytics__c.Search_Results_Summary__c);
			fieldList.add(Simpplr_social_analytics__c.Search_Results_Count__c);
			fieldList.add(Simpplr_social_analytics__c.Origin_Mobile_App__c);
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(ssa, fieldList);
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			
    	} catch(Exception ex){
	        logger.logError('MobileSearchDataServer.saveSearchStats()---Could not save search stats.',ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
        return responseWrapperObj;
    }

	private List<Object> convertToObjectList(List<ExternalSearchWrapper.ItemWrapper> itemWrapperList) {
		List<Object> resultList = new List<Object>();
		for(ExternalSearchWrapper.ItemWrapper itemObj : itemWrapperList){
			resultList.add(itemObj.item);
		}
		return resultList;
	}
    
}