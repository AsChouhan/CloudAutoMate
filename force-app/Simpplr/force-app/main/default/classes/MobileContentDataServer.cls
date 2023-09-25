public with sharing class MobileContentDataServer extends DataServer{
	@TestVisible private final String ACTION_GET_ALBUMS = 'getAlbums';
	@TestVisible private final String ACTION_GET_CONTENT_TYPE = 'getContentType';
	@TestVisible private final String ACTION_GET_EVENTS = 'getEvents';
	@TestVisible private final String ACTION_GET_PAGES = 'getPages';
	@TestVisible private final String ACTION_GET_PAGE_CATEGORIES = 'getPageCategories';
	@TestVisible private final String ACTION_GET_BLOGS = 'getBlogs';
	@TestVisible private final String ACTION_GET_MUST_READ = 'getMustRead';
	@TestVisible private final String ACTION_GET_EVENT_ORGANIZERS = 'getEventOrganizers';
	
	public List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).replace('Blog', 'BlogPost').split(',');
	public Set<String> allowedFeaturesInAppSet = new Set<String>(allowedFeaturesInAppList);
	
	public MobileContentDataServer() {
        
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try{
        	logger.logDebug('MobileContentDataServer.handleRequest()----entered handleRequest----');
			String action = readParam(REQUEST_PARAM_ACTION);
            String data = readParam('data');	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            } else {
            	if(ACTION_GET_ALBUMS.equalsIgnoreCase(action)){
            		response = getAlbums(data);
            	} else if(ACTION_GET_EVENTS.equalsIgnoreCase(action)){
	           		response = getEvents(data);
            	} else if(ACTION_GET_PAGES.equalsIgnoreCase(action)){
            		response = getPages(data);
            	} else if(ACTION_GET_PAGE_CATEGORIES.equalsIgnoreCase(action)){
            		response = getPageCategories(data);
            	} else if(ACTION_GET_BLOGS.equalsIgnoreCase(action)){
            		response = getBlogs(data);
            	} else if(ACTION_GET_MUST_READ.equalsIgnoreCase(action)){
            		response = getMustReadContentList(data);
            	} else if(ACTION_GET_CONTENT_TYPE.equalsIgnoreCase(action)){
            		String contentId = readParam('contentId');
            		response = getContentType(contentId);
            	} else if(ACTION_GET_EVENT_ORGANIZERS.equalsIgnoreCase(action)){
            		response = getEventOrganizers(data);
            	} else{
                	throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            	}
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileContentDataServer&action=getAlbums getAlbums
	 * @apiVersion 1.0.0
	 * @apiGroup MobileContentDataServer
	 * @apiName getAlbums
	 *
	 * @apiParam (Query Parameter) {String} action getAlbums
	 * @apiParam (Post Parameter) {String} data {"term":"","siteId":"","sortBy":"Promoted","size":16} 
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting album list for a site
	 * 
	 * @apiSuccess {Number} nextPageToken It defines the offset of successive results
	 * @apiSuccess {List[String]} listOfItems List of album ids
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getAlbums(String requestData){
    	logger.logDebug('MobileContentDataServer.getAlbums()----requestData---'+requestData);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
	        
        	String term = requestDataMap.get('term');
        	String sortBy = requestDataMap.get('sortBy');
        	String siteId = requestDataMap.get('siteId');
        	if(String.isNotBlank(siteId)){
	        	if(!SiteContext.isActive){
		    		throw new SimpplrException(ServiceConstants.ERROR_404);
		    	}
		    	if(!AccessManager.hasSiteAccess()) {
			        throw new SimpplrException(ServiceConstants.ERROR_403);
		    	}
        	}
        	Integer recordLimit = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	recordLimit = recordLimit + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
	    Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;
	      
	        Map<String,Object> resultMap = new Map<String,Object>();
	        List<Object> albumList = (new MobileContentDataProvider()).getAlbums(term, siteId, offset, recordLimit, sortBy, isFullModel);
	        if(albumList.size() == recordLimit){
	        		albumList.remove(recordLimit - 1);
	        		resultMap.put('nextPageToken',offset+recordLimit-1);
	        } else {
	        		resultMap.put('nextPageToken',null);
	        }
	        resultMap.put('listOfItems',albumList);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Album list returned successfully!', resultMap);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord('AlbumListing',requestDataMap);
        }catch(Exception e){
        	logger.logError('MobileContentDataServer.getAlbums()----Could not retrieve album list',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileContentDataServer.getAlbums()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileContentDataServer&action=getEvents getEvents
	 * @apiVersion 1.0.0
	 * @apiGroup MobileContentDataServer
	 * @apiName getEvents
	 *
	 * @apiParam (Query Parameter) {String} action getEvents
	 * @apiParam (Post Parameter) {String} data {"term":"","siteId":"","peopleId":"","filter":"future","period":"this_week/next_week/after_next_week","sortBy":"","size":16} 
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting event list for a site
	 * 
	 * @apiSuccess {Number} nextPageToken It defines the offset of successive results
	 * @apiSuccess {List[String]} listOfItems List of event ids
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getEvents(String requestData){
    	logger.logDebug('MobileContentDataServer.getEvents()----requestData---'+requestData);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
	        
        	String term = requestDataMap.get('term');
        	String sortBy = requestDataMap.get('sortBy');
        	String period = requestDataMap.get('period');
        	String filter = requestDataMap.get('filter');
        	String siteId = requestDataMap.get('siteId');
        	
        	if(!SimpplrContext.AllowedFeatures.containsIgnoreCase('event')){
        		throw new SimpplrException(ServiceConstants.ERROR_404);
        	}
        	
        	if(String.isNotBlank(siteId)){
	        	if(!SiteContext.isActive){
		    		throw new SimpplrException(ServiceConstants.ERROR_404);
		    	}
		    	if(!AccessManager.hasSiteAccess()) {
			        throw new SimpplrException(ServiceConstants.ERROR_403);
		    	}
        	}
        	
        	String peopleId = requestDataMap.get('peopleId');
        	
        	if(String.isBlank(peopleId)){
        		peopleId = UserContext.peopleId;
        	}
        	Integer size = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	Integer recordLimit = size + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
	    Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;
    		
    		Map<String,List<Object>> eventMap = (new MobileContentDataProvider()).getEventsMap(term, siteId, peopleId, filter, period, offset, recordLimit, sortBy, requestDataMap.get('nextPageToken'), isFullModel);
    		List<Object> listOfThisWeekEventWrapper = eventMap.get('thisWeekEvents')!=null ? eventMap.get('thisWeekEvents'): new List<Object>();
    		List<Object> listOfThisMonthEventWrapper = eventMap.get('thisMonthEvents') != null ? eventMap.get('thisMonthEvents') : new List<Object>();
    		List<Object> listOfLaterEventWrapper = eventMap.get('laterEvents') != null ? eventMap.get('laterEvents') : new List<Object>();
			
			Integer nextPageTokenThisWeek;
			Integer nextPageTokenThisMonth;
			Integer nextPageTokenLater;
			if(listOfThisWeekEventWrapper.size() == recordLimit){
				listOfThisWeekEventWrapper.remove(recordLimit - 1);
				nextPageTokenThisWeek = offset + size;
			} else {
				nextPageTokenThisWeek = null;
			}

			if(listOfThisMonthEventWrapper.size() == recordLimit){
				listOfThisMonthEventWrapper.remove(recordLimit - 1);
				nextPageTokenThisMonth = offset + size;
			} else {
				nextPageTokenThisMonth = null;
			}

			if(listOfLaterEventWrapper.size() == recordLimit){
				listOfLaterEventWrapper.remove(recordLimit - 1);
				nextPageTokenLater = offset + size;
			} else {
				nextPageTokenLater = null;
			}

	    	Map<String,Object> result = New Map<String,Object>();
            result.put('listOfThisWeekEvents',listOfThisWeekEventWrapper);
            result.put('nextPageTokenThisWeek',nextPageTokenThisWeek);
            
            result.put('listOfThisMonthEvents',listOfThisMonthEventWrapper);
            result.put('nextPageTokenThisMonth',nextPageTokenThisMonth);
            
            result.put('listOfLaterEvents',listOfLaterEventWrapper);
            result.put('nextPageTokenLater',nextPageTokenLater);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Event list returned successfully!', result);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord('EventListing',requestDataMap);
        }catch(Exception e){
        	logger.logError('MobileContentDataServer.getEvents()----Could not retrieve event list',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileContentDataServer.getEvents()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileContentDataServer&action=getPages getPages
	 * @apiVersion 1.0.0
	 * @apiGroup MobileContentDataServer
	 * @apiName getPages
	 *
	 * @apiParam (Query Parameter) {String} action getPages
	 * @apiParam (Post Parameter) {String} data {"term":"","siteId":"","categoryId":"","sortBy":"displayOrder","size":16}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting page list for a site
	 * 
	 * @apiSuccess {Number} nextPageToken It defines the offset of successive results
	 * @apiSuccess {List[String]} listOfItems List of page ids
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getPages(String requestData){
    	logger.logDebug('MobileContentDataServer.getPages()----requestData---'+requestData);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
	        
        	String term = requestDataMap.get('term');
        	String sortBy = requestDataMap.get('sortBy');
        	String siteId = requestDataMap.get('siteId');
        	if(String.isNotBlank(siteId)){
	        	if(!SiteContext.isActive){
		    		throw new SimpplrException(ServiceConstants.ERROR_404);
		    	}
		    	if(!AccessManager.hasSiteAccess()) {
			        throw new SimpplrException(ServiceConstants.ERROR_403);
		    	}
        	}
        	String categoryId = requestDataMap.get('categoryId');
        	Integer recordLimit = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	recordLimit = recordLimit + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
	    Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;
	      
	        Map<String,Object> resultMap = new Map<String,Object>();
	        List<Object> pageList = (new MobileContentDataProvider()).getPages(term ,siteId, offset, recordLimit, sortBy, categoryId, isFullModel);
	        if(pageList.size() == recordLimit){
	        	pageList.remove(recordLimit - 1);
	        	resultMap.put('nextPageToken',offset+recordLimit-1);
	        } else {
	        	resultMap.put('nextPageToken',null);
	        }
	        resultMap.put('listOfItems',pageList);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Page list returned successfully!', resultMap);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord('PageListing',requestDataMap);
        }catch(Exception e){
        	logger.logError('MobileContentDataServer.getPages()----Could not retrieve pages list',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileContentDataServer.getPages()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileContentDataServer&action=getPageCategories getPageCategories
	 * @apiVersion 1.0.0
	 * @apiGroup MobileContentDataServer
	 * @apiName getPageCategories
	 *
	 * @apiParam (Query Parameter) {String} action getPageCategories
	 * @apiParam (Post Parameter) {String} data {"term":"","siteId":"","size":16}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting page category list for a site
	 * @apiSuccess {Number} nextPageToken It defines the offset of successive results
	 * @apiSuccess {MobileContentDataProvider.CategoryWrapper[]} listOfItems list of page category items
	 * @apiUse MobileContentDataProviderCategoryWrapper
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getPageCategories(String requestData){
    	logger.logDebug('MobileContentDataServer.getPageCategories()----requestData---'+requestData);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
	        
        	String term = requestDataMap.get('term');
        	String sortBy = requestDataMap.get('sortBy');
        	String siteId = requestDataMap.get('siteId');
        	if(String.isNotBlank(siteId)){
	        	if(!SiteContext.isActive){
		    		throw new SimpplrException(ServiceConstants.ERROR_404);
		    	}
		    	if(!AccessManager.hasSiteAccess()) {
			        throw new SimpplrException(ServiceConstants.ERROR_403);
		    	}
        	}
        	Integer recordLimit = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	recordLimit = recordLimit + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
	        
	        Map<String,Object> resultMap = new Map<String,Object>();
	        List<MobileContentDataProvider.CategoryWrapper> categoryList = (new MobileContentDataProvider()).getPageCategories(term, siteId, offset, recordLimit, sortBy);
	        if(categoryList.size() == recordLimit){
	        	categoryList.remove(recordLimit - 1);
	        	resultMap.put('nextPageToken',offset+recordLimit-1);
	        } else {
	        	resultMap.put('nextPageToken',null);
	        }
	        resultMap.put('listOfItems',categoryList);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Page category list returned successfully!', resultMap);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord('PageCategoryListing',requestDataMap);
        }catch(Exception e){
        	logger.logError('MobileContentDataServer.getPageCategories()----Could not retrieve page category list',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileContentDataServer.getPageCategory()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileContentDataServer&action=getBlogs getBlogs
	 * @apiVersion 1.0.0
	 * @apiGroup MobileContentDataServer
	 * @apiName getBlogs
	 *
	 * @apiParam (Query Parameter) {String} action getBlogs
	 * @apiParam (Post Parameter) {String} data {"term":"","peopleId":"","sortBy":"latest","size":16}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting blog list for a profile
	 * 
	 * @apiSuccess {Number} nextPageToken It defines the offset of successive results
	 * @apiSuccess {List[String]} listOfItems List of blog ids
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getBlogs(String requestData){
    	logger.logDebug('MobileContentDataServer.getBlogs()----requestData---'+requestData);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	if(allowedFeaturesInAppSet.contains(ServiceConstants.TYPE_BLOGPOST)){
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
	        
        	String term = requestDataMap.get('term');
        	String sortBy = requestDataMap.get('sortBy');
        	String peopleId = requestDataMap.get('peopleId');
        	Integer recordLimit = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	recordLimit = recordLimit + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
	    	Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;
	    
	        Map<String,Object> resultMap = new Map<String,Object>();
	        List<Object> blogList = (new MobileContentDataProvider()).getBlogs(term, peopleId, offset, recordLimit, sortBy, isFullModel);
	        if(blogList.size() == recordLimit){
	        	blogList.remove(recordLimit - 1);
	        	resultMap.put('nextPageToken',offset+recordLimit-1); 
	        } else {
	        	resultMap.put('nextPageToken',null);
	        }
	        resultMap.put('listOfItems',blogList);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Blog list returned successfully!', resultMap);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord('BlogListing',requestDataMap);
        	}else{
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Blog list is disabled at App Level!', null);
        	}
        	
        }catch(Exception e){
        	logger.logError('MobileContentDataServer.getBlogs()----Could not retrieve blog list',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileContentDataServer.getBlogs()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileContentDataServer&action=getBlogs getBlogs
	 * @apiVersion 1.0.0
	 * @apiGroup MobileContentDataServer
	 * @apiName getBlogs
	 *
	 * @apiParam (Query Parameter) {String} action getBlogs
	 * @apiParam (Post Parameter) {String} data {"term":"","peopleId":"","sortBy":"latest","size":16}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting blog list for a profile
	 * 
	 * @apiSuccess {Number} nextPageTokenAll It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenRead It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenUnread It defines the offset of successive results
	 * @apiSuccess {List[String]} listOfAllItems List of all must read contents
	 * @apiSuccess {List[String]} listOfReadItems List of read must read content ids
	 * @apiSuccess {List[String]} listOfUnreadItems List of unread must read content ids
	 * @apiError SimpplrException Simpplr Exception
	 */
    @TestVisible private ResponseWrapper getMustReadContentList(String data) {
        
        logger.logDebug('MobileContentDataServer.getMustReadContentList----data---' + data);
        ResponseWrapper resultWrapper = New ResponseWrapper();
        
        try{
        
            Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(data, Type.forName('Map<String,String>'));
            String filter = requestDataMap.get('filter');
            Integer recordLimit = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')):0;
            recordLimit = recordLimit +1;
            Integer offSet = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;

            
			List<ContentCacheWrapper> allMustReadContentWrapperList = (new MobileContentDataProvider()).getMustReadContentListForMobile(offSet, recordLimit, requestDataMap.get('nextPageToken'));               
            Integer nextPageTokenAll;
            
            if(allMustReadContentWrapperList.size() == recordLimit){
				allMustReadContentWrapperList.remove(recordLimit - 1);
				nextPageTokenAll = offset + recordLimit - 1;
			} else {
				nextPageTokenAll = null;
			}
            
            Map<String,Object> result = New Map<String,Object>();
            result.put('listOfAllItems',allMustReadContentWrapperList);
            result.put('nextPageTokenAll',nextPageTokenAll);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Must read for mobile have been retreived successfully!', result);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord('MustReadContentListing',requestDataMap);       
        } catch(Exception e){
            logger.logError('MobileContentDataServer.getMustReadContentList-----Could not retreive must read for mobile----',e);
            resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return resultWrapper;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileContentDataServer&action=getContentType getContentType
	 * @apiVersion 1.0.0
	 * @apiGroup MobileContentDataServer
	 * @apiName getContentType
	 *
	 * @apiParam (Query Parameter) {String} action getContentType
	 * @apiParam (Query Parameter) {String} contentId contentId
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting content type wrt content id passed in request
	 * 
	 * @apiSuccess {String} contentType Type of content : Event, Album, Page or BlogPost
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getContentType(String contentId){
    	logger.logDebug('MobileContentDataServer.getContentType()----contentId---'+contentId);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
	        Map<String,Object> resultMap = new Map<String,Object>();
	        String contentType = (new MobileContentDao()).getContentType(contentId);
	        resultMap.put('contentType',contentType);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content type returned successfully!', resultMap);
        }catch(Exception e){
        	logger.logError('MobileContentDataServer.getContentType()----Could not retrieve content type',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileContentDataServer.getContentType()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileContentDataServer&action=getEventOrganizers getEventOrganizers
	 * @apiVersion 1.0.0
	 * @apiGroup MobileContentDataServer
	 * @apiName getEventOrganizers
	 *
	 * @apiParam (Query Parameter) {String} action getEventOrganizers
	 * @apiParam (Post Parameter) {String} data {"eventId":"","siteId":"","nextPageToken":"","size":16}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting event organizers list
	 * 
	 * @apiSuccess {List[String]} listOfItems List of event organizers id
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getEventOrganizers(String requestData){
    	logger.logDebug('MobileContentDataServer.getEventOrganizers()----requestData---'+requestData);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	if(String.valueOf(SimpplrContext.allowedFeatures).containsIgnoreCase(ServiceConstants.TYPE_EVENT) == false) {
    			throw new SimpplrException(ServiceConstants.ERROR_404);
    		}
        	Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
		String eventId = requestDataMap.get('eventId');	        
        	String siteId = requestDataMap.get('siteId');
        	if(String.isNotBlank(siteId)){
	        	if(!SiteContext.isActive){
		    		throw new SimpplrException(ServiceConstants.ERROR_404);
		    	}
		    	if(!AccessManager.hasSiteAccess()) {
			        throw new SimpplrException(ServiceConstants.ERROR_403);
		    	}
        	}
        	Integer recordLimit = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	recordLimit = recordLimit + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
	    Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;
	       
	        Map<String,Object> resultMap = new Map<String,Object>();
	        String sortBy;
	        if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
		        sortBy = 'CreatedDate';
	        } else {
		        sortBy = 'CollaboratorName';
	        }
	        List<Object> organizerIdList = (new MobileContentDataProvider()).getEventOrganizers(eventId, siteId, offset, recordLimit, isFullModel, sortBy);
	        if(organizerIdList.size() == recordLimit){
	        	organizerIdList.remove(recordLimit - 1);
	        	resultMap.put('nextPageToken',offset+recordLimit-1);
	        } else {
	        	resultMap.put('nextPageToken',null);
	        }
	        resultMap.put('listOfItems',organizerIdList);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Event organizers list returned successfully!', resultMap);
            
            requestDataMap.put('userAgent', readHeader('User-Agent'));
            Utility.insertMobileAnalyticsRecord('EventDetail',requestDataMap);
        }catch(Exception e){
        	logger.logError('MobileContentDataServer.getEventOrganizers()----Could not retrieve event organizers',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileContentDataServer.getEventOrganizers()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
}