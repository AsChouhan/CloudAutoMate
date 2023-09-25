/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class GlobalSearchDataServer extends DataServer{
	
	private final String ACTION_VALUE_SEARCH = 'search';
	private final String ACTION_VALUE_SAVE_SEARCH_STATS = 'saveSearchStats';  
	private final String ACTION_VALUE_SEARCH_RESULT_SELECT_STATS = 'saveSearchResultSelect'; 
	private final String SEARCH_TYPE_ARG = 'searchForType';
	private final String ACTION_AUTOCOMPLETE = 'searchAutoComplete';
	
	@TestVisible private final String SEARCH_TYPE_FEED = 'Feed';
	@TestVisible private final String SEARCH_TYPE_SITE = 'Site';
	@TestVisible private final String SEARCH_TYPE_USER = 'User';
	@TestVisible private final String SEARCH_TYPE_PAGE = 'Page';
	@TestVisible private final String SEARCH_TYPE_EVENT = 'Event';
	@TestVisible private final String SEARCH_TYPE_BLOG = 'BlogPost';
	@TestVisible private final String SEARCH_TYPE_FILE = 'File';
	@TestVisible private final String SEARCH_TYPE_GDFILE = 'GoogleDriveFile';
	@TestVisible private final String SEARCH_TYPE_DROPBOX_FILE = 'DropboxFile';
	@TestVisible private final String SEARCH_TYPE_SP_FILE = 'SharepointFile';
	@TestVisible private final String SEARCH_TYPE_OD_FILE = 'OneDriveFile';
	@TestVisible private final String SEARCH_TYPE_CRMFILE = 'CrmFile';
	@TestVisible private final String SEARCH_TYPE_BOXFILE = 'BoxFile';
	@TestVisible private final String SEARCH_TYPE_ALBUM = 'Album';
	@TestVisible private final String SEARCH_TYPE_TOPIC = 'Topic';
	
	@TestVisible private final String SEARCH_TYPE_CONTENT = 'Content';
	
    private final String REQUEST_PARAM_DATA = 'data';
    
    public GlobalSearchDataServer() {
		
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
        try{
        	logger.logDebug('GlobalSearchDataServer----entered handleRequest----');
        	
            String action = readParam(REQUEST_PARAM_ACTION);
        	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
                response = handleSearch(readParam(REQUEST_PARAM_DATA), readParam(SEARCH_TYPE_ARG));
                
            }else if(ACTION_VALUE_SAVE_SEARCH_STATS.equalsIgnoreCase(action)) {
            	response = saveSearchStats(readParam(REQUEST_PARAM_DATA));
            	
            } else if(ACTION_VALUE_SEARCH_RESULT_SELECT_STATS.equalsIgnoreCase(action)){
            	response = saveSearchResultSelect(readParam(REQUEST_PARAM_DATA));
            	
            } else if (ACTION_AUTOCOMPLETE.equalsIgnoreCase(action)) {
            	response = searchAutoComplete(readParam(REQUEST_PARAM_DATA));
            	
            }else{
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
                
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
    }
    
    @TestVisible 
    private ResponseWrapper searchAutoComplete(String requestData) {
    	logger.logDebug('GlobalSearchDataServer.searchAutoComplete()-----requestData---' + requestData);
    	GlobalSearchService searchService = new GlobalSearchService();
    	ResponseWrapper responseWrapperObj;

    	try{
    		Map<String,Object> searchCriteria = (Map<String,Object>)JSON.deserializeUntyped(requestData);
    		String searchTerm = String.valueOf(searchCriteria.get('term'));
    		List<AutoCompleteWrapper> listOfAutoCompleteWrapper;
			Boolean applyUserContext = 'false'.equalsIgnoreCase(readParam('applyUserContext')) ? false : true;
			Integer size = readParam('size') != null ? Integer.valueOf(readParam('size')) : null;
			listOfAutoCompleteWrapper = searchService.searchAutoComplete(searchTerm,applyUserContext,size);
    		
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfAutoCompleteWrapper);

    	} catch(Exception ex) {
			logger.logError('GlobalSearchDataServer.searchAutoComplete()---Exception occured---',ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_FAIL, null, null);
		}
		return responseWrapperObj;
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
    private ResponseWrapper handleSearch(String requestData, String SearchForType){
    	logger.logDebug('GlobalSearchDataServer.handleSearch()-----requestData---' + requestData);
    	logger.logDebug('GlobalSearchDataServer.handleSearch()-----SearchForType---' + SearchForType);
        ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_FAIL, null, null);
        
		GlobalSearchService searchService = new GlobalSearchService();
		
		try{
	        if (SEARCH_TYPE_CONTENT.equalsIgnoreCase(SearchForType)) {
	        	Map<String,Object> contentSearchCriteria = (Map<String,Object>)JSON.deserializeUntyped(requestData);
	        	Integer size = Integer.valueOf(contentSearchCriteria.get('size'));
    			Integer offset = Integer.valueOf(contentSearchCriteria.get('nextPageToken')) != null ?
    					Integer.valueOf(contentSearchCriteria.get('nextPageToken')) : 0;
        
	        	Map<String,Object> contentMap = searchService.searchContents(contentSearchCriteria);
	        	GlobalSearchWrapper globalSearchResultWrapObj = new GlobalSearchWrapper();
	        	List<Object> results = (List<Object>)contentMap.get('contents');
				
				if (results != null && results.size() > 0) {
					globalSearchResultWrapObj = new GlobalSearchWrapper();
	        		globalSearchResultWrapObj.totalRecords = GlobalSearchService.totalResults;
	        		globalSearchResultWrapObj.listOfItems = (List<GlobalSearchWrapper.ItemWrapper> )results;
	        		
	        		if (globalSearchResultWrapObj.listOfItems.size() == (size + 1) && offset < 2000) {
		    			globalSearchResultWrapObj.listOfItems.remove((globalSearchResultWrapObj.listOfItems.size()-1));
			    		globalSearchResultWrapObj.nextPageToken = String.valueOf(offset+size);
			    	} else {
			    		globalSearchResultWrapObj.nextPageToken = null;
			    	}
				}
	    		
	        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, globalSearchResultWrapObj);
	        	logger.logDebug('GlobalSearchDataServer.handleSearch()-----responseWrapperObj---for content listing' + responseWrapperObj);
	        	
	        }
		} catch(Exception ex){
			logger.logError('GlobalSearchDataServer---Could not retrieve contents',ex);
		}
		
		try{
	        if (SEARCH_TYPE_FEED.equalsIgnoreCase(SearchForType)) {
	        	Criteria.Feed feedSearchCriteria = (Criteria.Feed) Json.deserialize(requestData, Criteria.Feed.class);
	        			
	        	FeedElementPageWrapper feedElementPageWrapObj = new FeedElementPageWrapper();
		        feedElementPageWrapObj = searchService.searchFeed(feedSearchCriteria);
	        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, feedElementPageWrapObj);
	        	logger.logDebug('GlobalSearchDataServer.handleSearch()-----responseWrapperObj---for feed listing' + responseWrapperObj);
	        }
		} catch(Exception ex){
			logger.logError('GlobalSearchDataServer---Could not retrieve feed list',ex);
		}
        
        try{
	        if(SEARCH_TYPE_SITE.equalsIgnoreCase(SearchForType)){
	        	Criteria.Site siteSearchCriteria = (Criteria.Site) Json.deserialize(requestData, Criteria.Site.class);
	        	if (siteSearchCriteria.nextPageToken == null) {
	    			siteSearchCriteria.offset = 0;
	    		} else {
	    			siteSearchCriteria.offset = Integer.valueOf(siteSearchCriteria.nextPageToken);
	    		}
	    		
	    		//////////////--------
	        	List<Object> results = searchService.searchSites(siteSearchCriteria);
	        	//////////////--------
	        	
	        	GlobalSearchWrapper globalSearchResultWrapObj = new GlobalSearchWrapper();
	        	if(results != null && results.size() > 0){
	        		globalSearchResultWrapObj.totalRecords = GlobalSearchService.totalResults;
	        		globalSearchResultWrapObj.listOfItems = (List<GlobalSearchWrapper.ItemWrapper> )results;
	        		
	        		if (globalSearchResultWrapObj.listOfItems.size() == (siteSearchCriteria.size + 1) && siteSearchCriteria.offset < 2000) {
			        	globalSearchResultWrapObj.listOfItems.remove((globalSearchResultWrapObj.listOfItems.size()-1));
			        	globalSearchResultWrapObj.nextPageToken = String.valueOf(siteSearchCriteria.offset + siteSearchCriteria.size);
			        } else {
			        	globalSearchResultWrapObj.nextPageToken = null;
			        }
	        	}
	        	
	        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, globalSearchResultWrapObj);
	        	logger.logDebug('GlobalSearchDataServer.handleSearch()-----responseWrapperObj---for site listing' + responseWrapperObj);
	        }
        }  catch(Exception ex){
	        logger.logError('GlobalSearchDataServer---Could not retrieve site list',ex);
		}
        
        try{
	        if(SEARCH_TYPE_USER.equalsIgnoreCase(SearchForType)){
	        	Criteria.People peopleSearchCriteria = (Criteria.People) Json.deserialize(requestData, Criteria.People.class);
	        	if (peopleSearchCriteria.nextPageToken == null) {
	    			peopleSearchCriteria.offset = 0;
	    		} else {
	    			peopleSearchCriteria.offset = Integer.valueOf(peopleSearchCriteria.nextPageToken);
	    		}
	        	List<Object> results = searchService.searchPeople(peopleSearchCriteria);
	        	
	        	GlobalSearchWrapper globalSearchResultWrapObj; 
	        	
	        	if(results!=null){
	        		globalSearchResultWrapObj = new GlobalSearchWrapper();
	        		globalSearchResultWrapObj.totalRecords = GlobalSearchService.totalResults;
	        		globalSearchResultWrapObj.listOfItems = (List<GlobalSearchWrapper.ItemWrapper> )results;
	        		
	        		if (globalSearchResultWrapObj.listOfItems.size() == (peopleSearchCriteria.size + 1) && peopleSearchCriteria.offset < 2000) {
			        	globalSearchResultWrapObj.listOfItems.remove((globalSearchResultWrapObj.listOfItems.size()-1));
			        	globalSearchResultWrapObj.nextPageToken = String.valueOf(peopleSearchCriteria.offset + peopleSearchCriteria.size);
			        } else {
			        	globalSearchResultWrapObj.nextPageToken = null;
			        }
	        	}
	        	
	        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, globalSearchResultWrapObj);
	        	logger.logDebug('GlobalSearchDataServer.handleSearch()-----responseWrapperObj---for user listing' + responseWrapperObj);
	        }
        } catch(Exception ex){
        	logger.logError('GlobalSearchDataServer---Could not retrieve users list',ex);
		}        

        try{
	        if(SEARCH_TYPE_FILE.equalsIgnoreCase(SearchForType) || SEARCH_TYPE_CRMFILE.equalsIgnoreCase(SearchForType)){
	        	Criteria.File fileSearchCriteria = (Criteria.File) Json.deserialize(requestData, Criteria.File.class);
	        	List<FileListingWrapper> results = new List<FileListingWrapper> ();
	        	
	        	if (fileSearchCriteria.nextPageToken == null) {
	    			fileSearchCriteria.offset = 0;
	    		} else {
	    			fileSearchCriteria.offset = Integer.valueOf(fileSearchCriteria.nextPageToken);
	    		}
	    		
	    		if (SEARCH_TYPE_CRMFILE.equalsIgnoreCase(SearchForType)) {
	    			fileSearchCriteria.origin = 'CRM';
	    			results = searchService.searchCrmFiles(fileSearchCriteria);
					String origin = readParam('origin');
					if('mobile'.equalsIgnoreCase(origin)){
						Map<String,Object> result = new Map<String,Object>();
						if (results != NULL && results.size() == (fileSearchCriteria.size + 1) && fileSearchCriteria.offset < 2000) {
							results.remove((results.size()-1));
							result.put('nextPageToken',fileSearchCriteria.offset+ fileSearchCriteria.size);
						} else {
							result.put('nextPageToken',null);
						}
						result.put('listOfItems',results);
						responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
					} else {
						GlobalSearchWrapper gswObj = searchService.convertToGlobalSearchWrapper(results,fileSearchCriteria);	        	
						responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, gswObj);
						logger.logDebug('GlobalSearchDataServer.handleSearch()-----responseWrapperObj---for file listing' + responseWrapperObj);
					}
	    		} else {
	    			results = searchService.searchFiles(fileSearchCriteria);
					GlobalSearchWrapper gswObj = searchService.convertToGlobalSearchWrapper(results,fileSearchCriteria);	        	
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, gswObj);
					logger.logDebug('GlobalSearchDataServer.handleSearch()-----responseWrapperObj---for file listing' + responseWrapperObj);
	    		}
	    	}
        } catch(Exception ex){
        	logger.logError('GlobalSearchDataServer---Could not retrieve file list',ex);
		}
		
		try{
	        if(SEARCH_TYPE_GDFILE.equalsIgnoreCase(SearchForType) ||
	           SEARCH_TYPE_DROPBOX_FILE.equalsIgnoreCase(SearchForType) || 
	           SEARCH_TYPE_SP_FILE.equalsIgnoreCase(SearchForType) ||
	           SEARCH_TYPE_OD_FILE.equalsIgnoreCase(SearchForType)) {
	        	Criteria.File fileSearchCriteria = (Criteria.File) Json.deserialize(requestData, Criteria.File.class);
	        	if (fileSearchCriteria.nextPageToken == null) {
					fileSearchCriteria.offset = 0;
					
	    		} else if(fileSearchCriteria.nextPageToken.isNumeric()) {
	    			fileSearchCriteria.offset = Integer.valueOf(fileSearchCriteria.nextPageToken);
	    		}
	    		
	    		fileSearchCriteria.provider = EFSConstants.SearchTypetoProviderMap.get(SearchForType);
	    		try {
	        		List<FileListingWrapper> results = searchService.searchEFSFiles(fileSearchCriteria);
	        		
					
					String origin =  readParam('origin');
					if('mobile'.equalsIgnoreCase(origin)){ 
						Map<String,Object> result = new Map<String,Object>();
						if(GlobalSearchService.nextPageToken != null) {
							result.put('nextPageToken', GlobalSearchService.nextPageToken);

						} else if (results != NULL && results.size() == (fileSearchCriteria.size + 1) && fileSearchCriteria.offset < 2000) {
							results.remove((results.size()-1));
							result.put('nextPageToken',fileSearchCriteria.offset+ fileSearchCriteria.size);
						} else {
							result.put('nextPageToken',null);
						}
						result.put('listOfItems',results);
						responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
					} else {
						GlobalSearchWrapper gswObj = searchService.convertToGlobalSearchWrapper(results,fileSearchCriteria);
	        			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, gswObj);
					}


	    		} catch (EFSException efsEx) {
	    			logger.logDebug(efsEx);
	    			if(efsEx.getMessage() == EFSConstants.ACCESS_EXPIRED_MESSAGE) {
	    				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);	
	    			} else {
	    				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	    			}
	    		}
	        	logger.logDebug('GlobalSearchDataServer.handleSearch()-----responseWrapperObj---for EFS file listing' + responseWrapperObj);
	        }
        } catch(Exception ex){
        	logger.logError('GlobalSearchDataServer---Could not retrieve file storage file list',ex);
		}
		
		try{
	        if(SEARCH_TYPE_BOXFILE.equalsIgnoreCase(SearchForType)){
	        	Criteria.File fileSearchCriteria = (Criteria.File) Json.deserialize(requestData, Criteria.File.class);
	        	if (fileSearchCriteria.nextPageToken == null) {
	    			fileSearchCriteria.offset = 0;
	    		} else {
	    			fileSearchCriteria.offset = Integer.valueOf(fileSearchCriteria.nextPageToken);
	    		}
	    		
	        	List<FileListingWrapper> results = searchService.searchBoxFiles(fileSearchCriteria);
				String origin =  readParam('origin');
				if('mobile'.equalsIgnoreCase(origin)){
	        		Map<String,Object> result = new Map<String,Object>();
					if (results != NULL && results.size() == (fileSearchCriteria.size + 1) && fileSearchCriteria.offset < 2000) {
						results.remove((results.size()-1));
						result.put('nextPageToken',fileSearchCriteria.offset+ fileSearchCriteria.size);
					} else {
						result.put('nextPageToken',null);
					}
					result.put('listOfItems',results);
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
				} else {
					GlobalSearchWrapper gswObj = searchService.convertToGlobalSearchWrapper(results,fileSearchCriteria);
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, gswObj);
				}
	        	logger.logDebug('GlobalSearchDataServer.handleSearch()-----responseWrapperObj---for box file listing' + responseWrapperObj);
	        }
        } catch(Exception ex){
        	logger.logError('GlobalSearchDataServer---Could not retrieve box file list',ex);
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
    	logger.logDebug('GlobalSearchDataServer.saveSearchStats()-----requestData---' + requestData);
        ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        String loggedInUserId = UserInfo.getUserId();
		GlobalSearchService searchService = new GlobalSearchService();
		Criteria.SearchStats searchStatsData = (Criteria.SearchStats) Json.deserialize(requestData, Criteria.SearchStats.class);
		String userAgent = readHeader('USER-AGENT') != null ? readHeader('USER-AGENT') : readHeader('User-Agent');
		try{
			Simpplr_Social_Analytics__c ssa = new Simpplr_Social_Analytics__c();
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

			ssa.User__c = UserContext.id;
			ssa.People__c = UserContext.peopleId;
			ssa.Interaction__c = 'Search Stats';
			ssa.Search_Text__c=searchStatsData.term;
    		ssa.Simpplr_Site__c = searchStatsData.siteId;
			ssa.Search_Results_Summary__c  = requestData;
			ssa.Search_Results_Count__c =  searchStatsData.totalResultCount;

			fieldList.add(Simpplr_Social_Analytics__c.User__c);
			fieldList.add(Simpplr_Social_Analytics__c.People__c);
			fieldList.add(Simpplr_Social_Analytics__c.Interaction__c);
			fieldList.add(Simpplr_Social_Analytics__c.Search_Text__c);
			fieldList.add(Simpplr_Social_Analytics__c.Simpplr_Site__c);
			fieldList.add(Simpplr_Social_Analytics__c.Search_Results_Summary__c);
			fieldList.add(Simpplr_Social_Analytics__c.Search_Results_Count__c);

			fieldList.add(Simpplr_Social_Analytics__c.Origin_Desktop_App__c);
			fieldList.add(Simpplr_Social_Analytics__c.Origin_Mobile_App__c);
			fieldList.add(Simpplr_Social_Analytics__c.Origin_Mobile_Browser__c);
			
			if(String.isNotBlank(userAgent)) {
				ssa.User_Agent__c = userAgent.trim().left(255);
				if(userAgent.containsIgnoreCase('Desktop App')) {
					ssa.Origin_Desktop_App__c = true;	
					ssa.Origin_Mobile_App__c = false;
					ssa.Origin_Mobile_Browser__c  = false;
				
				} else if(userAgent.containsIgnoreCase('Mobile App')) {
					ssa.Origin_Desktop_App__c = false;
					ssa.Origin_Mobile_App__c = true;
					ssa.Origin_Mobile_Browser__c  = false;
				
				} else if(userAgent.containsIgnoreCase('Windows Phone') || userAgent.containsIgnoreCase('iPhone')  
								|| userAgent.containsIgnoreCase('iPad') || userAgent.containsIgnoreCase('Android') || userAgent.containsIgnoreCase('SymbianOS')
								||  userAgent.containsIgnoreCase('BlackBerry')){
					ssa.Origin_Desktop_App__c = false;
					ssa.Origin_Mobile_App__c = false;
					ssa.Origin_Mobile_Browser__c  = true;
				
				} else {
					ssa.Origin_Desktop_App__c = false;
					ssa.Origin_Mobile_App__c = false;
					ssa.Origin_Mobile_Browser__c  = false;
				}
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(ssa, fieldList);

    	} catch(Exception ex){
	        logger.logError('GlobalSearchDataServer.saveSearchStats()---Could not save search stats.',ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
        return responseWrapperObj;
    }
    
    private ResponseWrapper saveSearchResultSelect(String requestData){
    	ResponseWrapper responseWrapperObj;
        String loggedInPeopleId = UserContext.peopleId;
		Criteria.SearchResultsSelectStats searchResultsSelectStatsData = (Criteria.SearchResultsSelectStats) Json.deserialize(requestData, Criteria.SearchResultsSelectStats.class);
		
		try{
			Analytics_Search_Result_Select__c selectedSearchResultsObj = new Analytics_Search_Result_Select__c();
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

			selectedSearchResultsObj.Created_By_People__c = loggedInPeopleId;
			selectedSearchResultsObj.Context__c = searchResultsSelectStatsData.context;
			fieldList.add(Analytics_Search_Result_Select__c.Created_By_People__c);
			fieldList.add(Analytics_Search_Result_Select__c.Context__c);

			if('full'.equalsIgnorecase(searchResultsSelectStatsData.context)){
				selectedSearchResultsObj.Section__c = searchResultsSelectStatsData.section;
				fieldList.add(Analytics_Search_Result_Select__c.Section__c);
			}

			selectedSearchResultsObj.Item_Type__c = searchResultsSelectStatsData.itemtype;
			selectedSearchResultsObj.Position__c = searchResultsSelectStatsData.position;
			selectedSearchResultsObj.Page_Position__c = searchResultsSelectStatsData.pagePosition;
			selectedSearchResultsObj.Score__c = searchResultsSelectStatsData.score;
			selectedSearchResultsObj.Term__c = searchResultsSelectStatsData.term;
			selectedSearchResultsObj.Is_External__c = searchResultsSelectStatsData.isExternal;

			fieldList.add(Analytics_Search_Result_Select__c.Item_Type__c);
			fieldList.add(Analytics_Search_Result_Select__c.Position__c);
			fieldList.add(Analytics_Search_Result_Select__c.Page_Position__c);
			fieldList.add(Analytics_Search_Result_Select__c.Score__c);
			fieldList.add(Analytics_Search_Result_Select__c.Term__c);
			fieldList.add(Analytics_Search_Result_Select__c.Is_External__c);
			
			if(String.isNotBlank(searchResultsSelectStatsData.siteId)){
				selectedSearchResultsObj.Site_Context__c = searchResultsSelectStatsData.siteId;
				fieldList.add(Analytics_Search_Result_Select__c.Site_Context__c);
			}
			
			if('content'.equalsIgnorecase(searchResultsSelectStatsData.itemtype)){
				selectedSearchResultsObj.Content__c = searchResultsSelectStatsData.itemId;
				fieldList.add(Analytics_Search_Result_Select__c.Content__c);
			} else if('site'.equalsIgnorecase(searchResultsSelectStatsData.itemtype)){
				selectedSearchResultsObj.Site__c = searchResultsSelectStatsData.itemId;
				fieldList.add(Analytics_Search_Result_Select__c.Site__c);
			} else if('person'.equalsIgnorecase(searchResultsSelectStatsData.itemtype)){
				selectedSearchResultsObj.People__c = searchResultsSelectStatsData.itemId;
				fieldList.add(Analytics_Search_Result_Select__c.People__c);
			} else if('file'.equalsIgnorecase(searchResultsSelectStatsData.itemtype)){
				selectedSearchResultsObj.File_Id__c = searchResultsSelectStatsData.itemId;
				fieldList.add(Analytics_Search_Result_Select__c.File_Id__c);
			} else if('knowlegebase'.equalsIgnorecase(searchResultsSelectStatsData.itemtype)){
				selectedSearchResultsObj.Knowledgebase_Id__c = searchResultsSelectStatsData.itemId;
				fieldList.add(Analytics_Search_Result_Select__c.Knowledgebase_Id__c);
			}
			
			if(String.isNotBlank(searchResultsSelectStatsData.section) && 'top'.equalsIgnoreCase(searchResultsSelectStatsData.section)){
				selectedSearchResultsObj.Subsection__c = searchResultsSelectStatsData.subsection;
				fieldList.add(Analytics_Search_Result_Select__c.Subsection__c);
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(selectedSearchResultsObj, fieldList);
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		}catch(Exception ex){
	        logger.logError('GlobalSearchDataServer.saveSearchStats()---Could not save selected search results stats.',ex);
	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
    	return responseWrapperObj;
    }
}