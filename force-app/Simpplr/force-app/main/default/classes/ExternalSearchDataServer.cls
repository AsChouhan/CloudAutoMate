public with sharing class ExternalSearchDataServer extends DataServer{
	private final String ACTION_VALUE_EXTERNAL_SEARCH = 'externalSearch';
	private final String ACTION_EXTERNAL_SEARCH_AUTOCOMPLETE = 'externalAutoComplete';
	private final String SEARCH_TYPE_ARG = 'searchForType';
	
	@TestVisible private final String SEARCH_TYPE_TOP = 'Top';	
	@TestVisible private final String SEARCH_TYPE_FEED = 'Feed';
	@TestVisible private final String SEARCH_TYPE_SITE = 'Site';
	@TestVisible private final String SEARCH_TYPE_USER = 'User';
	@TestVisible private final String SEARCH_TYPE_GOOGLEDRIVE_FILE = 'GoogleDriveFile';
	@TestVisible private final String SEARCH_TYPE_DROPBOXFILE = 'DropboxFile';
	@TestVisible private final String SEARCH_TYPE_SP_FILE = 'SharepointFile';
	@TestVisible private final String SEARCH_TYPE_OD_FILE = 'OneDriveFile';
	@TestVisible private final String SEARCH_TYPE_FILE = 'File';
	@TestVisible private final String SEARCH_TYPE_NATIVE_VIDEO = 'NativeVideo';
	@TestVisible private final String SEARCH_TYPE_CRMFILE = 'CrmFile';
	@TestVisible private final String SEARCH_TYPE_BOXFILE = 'BoxFile';
	@TestVisible private final String SEARCH_TYPE_LINK = 'Links';
	@TestVisible private final String SEARCH_TYPE_CONTENT = 'Content';
	@TestVisible private final String SEARCH_TYPE_TILE = 'Tiles';
	@TestVisible private final String SEARCH_TYPE_QUESTION = 'Question';
	@TestVisible private final String SEARCH_TYPE_CONTENT_ONBOARDING = 'ContentOnboarding';
	
	private final String REQUEST_PARAM_DATA = 'data';
	
	public ExternalSearchDataServer() { }
	public String getPageFeature() {
		return AccessManager.FEATURE_SIMPPLR;
	}
	
	public override void handleRequest() {
		
		try{
			logger.logDebug('ExternalSearchDataServer----entered handleRequest----');
			
			String action = readParam(REQUEST_PARAM_ACTION);
			
			if(String.isBlank(action)) {
				throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
			}
			
			if(ACTION_VALUE_EXTERNAL_SEARCH.equalsIgnoreCase(action)) {
				response = handleExternalSearch(readParam(REQUEST_PARAM_DATA), readParam(SEARCH_TYPE_ARG));
				
			}else if(ACTION_EXTERNAL_SEARCH_AUTOCOMPLETE.equalsIgnoreCase(action)) {
				response = externalSearchAutoComplete(readParam(REQUEST_PARAM_DATA));
				
			}else{
				throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
				
			}
			
		}catch(Exception ex) {
			logger.logError('Either no page access or action parameter returning wrong data',ex);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
		}
	}
	
	@TestVisible 
	/**
 * @api {get} /apex/DataServerRW?target=ExternalSearchDataServer&action=externalSearch externalSearch
 * @apiVersion 1.0.0
 * @apiGroup ExternalSearchDataServer
 * @apiName externalSearch
 *
 * @apiParam (Query Parameter) {String} action externalSearch
 * @apiParam (Post Parameter) {String} data <a href="../build/#global-global.externalSearch" target="_blank">global-global.externalSearch</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Global.ExternalSearchDataServer
 *
 * @apiSuccess {ResponseWrapper} contains list of objects to return
 * 
 */
	private ResponseWrapper handleExternalSearch(String requestData, String SearchForType){
		logger.logDebug('ExternalSearchDataServer.handleExternalSearch()-----SearchForType---' + SearchForType + '-----requestData---' + requestData);
		
		ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_FAIL, 'Exception occurred while searching ' + SearchForType, null);
		 
		ExternalSearchService externalSearchService = new ExternalSearchService();
		
		try{
			if (SEARCH_TYPE_TOP.equalsIgnoreCase(SearchForType)) {
				Criteria.ExternalSearchReq contentSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchTopResuls(contentSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);
			
			} else if (SEARCH_TYPE_CONTENT.equalsIgnoreCase(SearchForType)) {
				Criteria.ExternalSearchReq contentSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchContents(contentSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);
			
			} else if (SEARCH_TYPE_CONTENT_ONBOARDING.equalsIgnoreCase(SearchForType)) {
				Criteria.ExternalSearchReq contentSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchContents(contentSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);
			
			} else if (SEARCH_TYPE_SITE.equalsIgnoreCase(SearchForType)){
				Criteria.ExternalSearchReq siteSearchCriteria = (Criteria.ExternalSearchReq) Json.deserialize(requestData, Criteria.ExternalSearchReq.class);
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchSites(siteSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);
				
			} else if (SEARCH_TYPE_USER.equalsIgnoreCase(SearchForType)){
                Criteria.ExternalSearchReq peopleSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchPeople(peopleSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);
								
			} else if(SEARCH_TYPE_FILE.equalsIgnoreCase(SearchForType)){
				Criteria.ExternalSearchReq fileSearchCriteria = (Criteria.ExternalSearchReq) Json.deserialize(requestData, Criteria.ExternalSearchReq.class);
				
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchFiles(fileSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);

			} else if(SEARCH_TYPE_NATIVE_VIDEO.equalsIgnoreCase(SearchForType)){
				
				Criteria.ExternalSearchReq fileSearchCriteria = (Criteria.ExternalSearchReq) Json.deserialize(requestData, Criteria.ExternalSearchReq.class);
				
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchNativeVideos(fileSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);

			} else if(SEARCH_TYPE_GOOGLEDRIVE_FILE.equalsIgnoreCase(SearchForType) 
					|| SEARCH_TYPE_BOXFILE.equalsIgnoreCase(SearchForType) 
					|| SEARCH_TYPE_DROPBOXFILE.equalsIgnoreCase(SearchForType)
					|| SEARCH_TYPE_SP_FILE.equalsIgnoreCase(SearchForType)
					|| SEARCH_TYPE_OD_FILE.equalsIgnoreCase(SearchForType)
					|| SEARCH_TYPE_CRMFILE.equalsIgnoreCase(SearchForType)){

				Criteria.File fileSearchCriteria = (Criteria.File) Json.deserialize(requestData, Criteria.File.class);
				fileSearchCriteria.provider = EFSConstants.SearchTypetoProviderMap.get(SearchForType);
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchEFSFiles(fileSearchCriteria, SearchForType);
				if(SEARCH_TYPE_SP_FILE.equalsIgnoreCase(SearchForType) && EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID.equalsIgnoreCase(SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).Client_Id__c)){
					returnWrapper.totalRecords =  GlobalSearchService.totalMSResults;
				}
				if(SEARCH_TYPE_GOOGLEDRIVE_FILE.equalsIgnoreCase(SearchForType)) {
					returnWrapper.shareddriveName = GlobalSearchService.shareddriveName;
					returnWrapper.isMyDriveFolderLinked = GlobalSearchService.isMyDriveFolderLinked;
				} 
				
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);

			} else if(SEARCH_TYPE_LINK.equalsIgnoreCase(SearchForType)){

				Criteria.ExternalSearchReq linkSearchCriteria = (Criteria.ExternalSearchReq) Json.deserialize(requestData, Criteria.ExternalSearchReq.class);

				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchLinks(linkSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);
			} else if(SEARCH_TYPE_TILE.equalsIgnoreCase(SearchForType)){
				
				Criteria.ExternalSearchReq tileSearchCriteria = (Criteria.ExternalSearchReq) Json.deserialize(requestData, Criteria.ExternalSearchReq.class);
				
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchTiles(tileSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);

			} else if(SEARCH_TYPE_QUESTION.equalsIgnoreCase(SearchForType)){
				
				Criteria.ExternalSearchReq questionSearchCriteria = (Criteria.ExternalSearchReq) Json.deserialize(requestData, Criteria.ExternalSearchReq.class);
				
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchQuestions(questionSearchCriteria, SearchForType);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, returnWrapper);
			}
		} catch(Exception ex){
			logger.logError('ExternalSearchDataServer---Exception Occured----',ex);
		}
		return responseWrapperObj;
	}
	@future
	/**
	 * @api {get} /apex/DataServerRW?target=ExternalSearchDataServer&action=saveSearchStats saveSearchStats
	 * @apiVersion 1.0.0
	 * @apiGroup ExternalSearchDataServer
	 * @apiName saveSearchStats
	 *
	 * @apiParam (Query Parameter) {String} action saveSearchStats
	 * @apiParam (Post Parameter) {String} data <a href="../build/#global-global.saveSearchStats" target="_blank">global-global.saveSearchStats</a> 
	 *
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Global.ExternalSearchDataServer
	 * 
	 */
	public static void saveSearchStats(String requestData) {
		String loggedInUserId = UserInfo.getUserId();
		Criteria.SearchStats searchStatsData = (Criteria.SearchStats) Json.deserialize(requestData, Criteria.SearchStats.class);
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', loggedInUserId);
		soqlParamMap.put('soqlParam2', searchStatsData.term);
		String socialAnlytcsQuery = 'select id from Simpplr_social_analytics__c ' +
			' where createdbyId =:soqlParam1 ' +
			' and createddate = today ' +
			' and Interaction__c = \'View\' ' +
			' and Search_Text__c=:soqlParam2 ' +
			' order by createddate desc limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Simpplr_Social_Analytics__c> listOfSearchRecords = (List<Simpplr_Social_Analytics__c>)SIMPESAPI.accessController().queryAsUser(socialAnlytcsQuery, soqlParamMap);
		if(listOfSearchRecords.size() > 0) {
			listOfSearchRecords[0].Search_Results_Summary__c  = requestData;
			listOfSearchRecords[0].Search_Results_Count__c =  searchStatsData.totalResultCount;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(listOfSearchRecords[0], 
												  new List<Schema.SObjectField>{
														Simpplr_social_analytics__c.Search_Results_Summary__c,
														Simpplr_social_analytics__c.Search_Results_Count__c});
		}
			
	}
	
	@TestVisible 
 /**
 * @api {get} /apex/DataServerRW?target=ExternalSearchDataServer&action=externalSearchAutoComplete externalSearchAutoComplete
 * @apiVersion 1.0.0
 * @apiGroup ExternalSearchDataServer
 * @apiName externalSearchAutoComplete
 *
 * @apiParam (Query Parameter) {String} action externalSearchAutoComplete
 * @apiParam (Post Parameter) {String} data <a href="../build/#global-global.externalSearchAutoComplete" target="_blank">global-global.externalSearchAutoComplete</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Global.ExternalSearchDataServer
 *
 * @apiSuccess {ResponseWrapper} contains list of objects to return
 */
	private ResponseWrapper externalSearchAutoComplete(String requestData){
		logger.logDebug('ExternalSearchDataServer.externalSearchAutoComplete()-----requestData---' + requestData);
		ExternalSearchService externalSearchService = new ExternalSearchService();
		
		ResponseWrapper responseWrapperObj;

		try{
			Map<String,Object> searchCriteria = (Map<String,Object>)JSON.deserializeUntyped(requestData);
			String searchTerm = String.valueOf(searchCriteria.get('term'));
			List<AutoCompleteWrapper> listOfAutoCompleteWrapper = externalSearchService.searchAutoComplete(searchTerm);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfAutoCompleteWrapper);

		} catch(Exception ex) {
			logger.logError('ExternalSearchDataServer.searchAutoComplete()---Exception occured---',ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_FAIL, null, null);
		}
		return responseWrapperObj;
	}
}