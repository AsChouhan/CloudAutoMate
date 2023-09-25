public with sharing class FavoriteDataServer extends DataServer {
    private final String REQUEST_PARAM_DATA = 'data';
	private final string ACTION_GET_FAVORITE = 'getFavorite';
    
	
	public FavoriteDataServer() {
        
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try{
        	logger.logDebug('FavoriteDataServer----entered handleRequest----');
			String action = readParam(REQUEST_PARAM_ACTION);
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            } else {
            	if(ACTION_GET_FAVORITE.equalsIgnoreCase(action)){
            		response = getFavorite(readParam(REQUEST_PARAM_DATA));
            	}else{
                	throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            	}
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FavoriteDataServer&action=getFavorite getFavorite
	 * @apiVersion 1.0.0
	 * @apiGroup FavoriteDataServer
	 * @apiName getFavorite
	 *
	 * @apiParam (Query Parameter) {String} action getFavorite
	 * @apiParam (Post Parameter) {String} data {"term":"","filter":"people/site/content","size":16,"nextPageToken":""}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for favourite people, site or content listing
	 * @apiSuccess {Number} nextPageTokenSite It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenContent It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenPeople It defines the offset of successive results
	 * @apiSuccess {List[Id]} sites List of favourite sites
	 * @apiSuccess {List[Id]} people List of favourite people
	 * @apiSuccess {List[Id]} contents List of favourite contents
	 * @apiError SimpplrException Simpplr Exception
	 */
    private ResponseWrapper getFavorite(String requestData){
    	logger.logDebug('FavoriteDataServer.getFavorite()----requestData----'+requestData);
    	if(String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
        	String filter = requestDataMap.get('filter');
        	String term = requestDataMap.get('term');
        	String categoryId = requestDataMap.get('categoryId');
        	String sortBy = requestDataMap.get('sortBy');
        	Integer size = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	Integer recordLimit = size + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
        	Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;
        	List<Object> siteList = new List<Object>();
        	List<Object> contentList = new List<Object>();
        	List<Object> peopleList = new List<Object>();
        	
        	Map<Id,CollaborationGroup> mapOfAllCollaborationGrp = new Map<Id,CollaborationGroup>();
        	if(String.isBlank(requestDataMap.get('nextPageToken')) || 'site'.equalsIgnoreCase(filter)){
        		siteList = new MobileSiteDataProvider().getAllFavoriteSites(term, offset, recordLimit, categoryId, isFullModel);
        	}
        	
        	if(String.isBlank(requestDataMap.get('nextPageToken')) || 'content'.equalsIgnoreCase(filter)){
        		contentList = new MobileContentDataProvider().getFavoriteContentList(null, term, recordLimit, offset, isFullModel);
        	}
        	
        	if(String.isBlank(requestDataMap.get('nextPageToken')) || 'people'.equalsIgnoreCase(filter)){
        		peopleList = new MobilePeopleDataProvider().getAllFavoritePeople(term, offset, recordLimit, isFullModel);
        	}
        	
	    	Integer nextPageTokenSite;
			Integer nextPageTokenContent;
			Integer nextPageTokenPeople;
			
			if(siteList.size() == recordLimit){
				siteList.remove(recordLimit - 1);
				nextPageTokenSite = offset + size;
			} else {
				nextPageTokenSite = null;
			}
			if(contentList.size() == recordLimit){
				contentList.remove(recordLimit - 1);
				nextPageTokenContent = offset + size;
			} else {
				nextPageTokenContent = null;
			}
			if(peopleList.size() == recordLimit){
				peopleList.remove(recordLimit - 1);
				nextPageTokenPeople = offset + size;
			} else {
				nextPageTokenPeople = null;
			}
        	
        	Map<String,Object> resultMap = new map<String,Object>();
        	resultMap.put('sites',siteList);
        	resultMap.put('people',peopleList);
        	resultMap.put('contents',contentList);
        	resultMap.put('nextPageTokenSite',nextPageTokenSite);
        	resultMap.put('nextPageTokenContent',nextPageTokenContent);
        	resultMap.put('nextPageTokenPeople',nextPageTokenPeople);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord( 'Favorite'+requestDataMap.get('filter'),requestDataMap);
        } catch(Exception e){
        	logger.logError('Could not retrieve favorite list',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('FavoriteDataServer.getFavorite()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
}