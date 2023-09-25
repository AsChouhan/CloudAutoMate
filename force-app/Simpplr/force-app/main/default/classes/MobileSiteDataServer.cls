public with sharing class MobileSiteDataServer extends DataServer{
	
	@TestVisible private final String ACTION_SEARCH = 'search';
	@TestVisible private final String ACTION_GET_SITE_DETAIL = 'getsiteDetailData';
	@TestVisible private final String ACTION_GET_PRIVATE_SITE_STATUS = 'getPrivateSiteStatus';
	@TestVisible private final String ACTION_GET_FEATURED_MANDATORY_SITE_LIST = 'getFeaturedMandatorySiteList';
	
	public MobileSiteDataServer() {
        
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try{
        	logger.logDebug('MobileSiteDataServer.handleRequest()----entered handleRequest----');
			String action = readParam(REQUEST_PARAM_ACTION);
            String data = readParam('data');	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            } else {
	            	if(ACTION_SEARCH.equalsIgnoreCase(action)){
	            		response = search(data);
	            	} else if (ACTION_GET_SITE_DETAIL.equalsIgnoreCase(action)) {
	            		String siteId = readParam('siteId');
	            		response = getsiteDetailData(siteId);
	            	} else if (ACTION_GET_PRIVATE_SITE_STATUS.equalsIgnoreCase(action)) {
	            		String privateSiteRequestId = readParam('privateSiteRequestId');
	            		response = getPrivateSiteStatus(privateSiteRequestId);
	            	} else if (ACTION_GET_FEATURED_MANDATORY_SITE_LIST.equalsIgnoreCase(action)) {
	            		response = getFeaturedMandatorySiteList();
	            	} else {
	                	throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
	            	}
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
	
	/**
	 * @api {post} /apex/DataServerRW?target=MobileSiteDataServer&action=search search
	 * @apiVersion 1.0.0
	 * @apiGroup MobileSiteDataServer
	 * @apiName search
	 *
	 * @apiParam (Query Parameter) {String} action search
	 * @apiParam (Post Parameter) {String} data {"filter":"all/featured/following/latest","category":"CategoryId","size":16,"nextPageToken":""}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting site list based on search criteria
	 * 
	 * @apiSuccess {Number} nextPageTokenFeatured It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenLatest It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenFollowing It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenAll It defines the offset of successive results
	 * @apiSuccess {Number} nextPageTokenCategoryItems It defines the offset of successive results
	 * @apiSuccess {List[String]} featured List of featured sites
	 * @apiSuccess {List[String]} latest List of latest sites
	 * @apiSuccess {List[String]} following List of sites followed
	 * @apiSuccess {List[String]} all List of all sites
	 * @apiSuccess {List[String]} category List of sites by category
	 * @apiError SimpplrException Simpplr Exception
	 */
    @TestVisible 
	private ResponseWrapper search(String requestData) {
		logger.logdebug('MobileSiteDataServer.search()----requestData----'+requestData);
		ResponseWrapper responseToReturn = null;
		try{
			Criteria.Site siteCriteriaObjArg = (Criteria.Site)JSON.deserialize(requestData, Criteria.Site.class);
			Map<String,String> requestDataMap = (Map<String,String>)JSON.deserialize(requestData, Type.forName('Map<String,String>'));
			if(siteCriteriaObjArg == null){
	            throw New SimpplrException(ServiceConstants.ERROR_INVALID_REQUEST_PARAMETERS);
	        }
	        
	        MobileSiteDataProvider mblSiteDataProviderObj = new MobileSiteDataProvider();
	        MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
	        Boolean isFullModel = readParam('isFullModel') == 'true'? true : false;
	        String term = requestDataMap.get('term');
        	Integer recordLimit = String.isNotBlank(requestDataMap.get('size'))?Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	recordLimit = recordLimit + 1;
        	Integer offset = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
			Integer nextPageToken = String.isNotBlank(requestDataMap.get('nextPageToken'))?Integer.valueOf(requestDataMap.get('nextPageToken')) : null;
			String categoryId = requestDataMap.get('category');
			
			List<Object> listOfFeaturedSite = new List<String>();
			List<Object> listOfLatestSite = new List<String>();
			List<Object> listOfFollowingSite = new List<String>();
			List<Object> listOfAllSite = new List<String>();
			
			List<ManageApplicationWrapper.ManageSitesCategoryWrapper> listOfCategoryItems = new List<ManageApplicationWrapper.ManageSitesCategoryWrapper>();
			String filter = siteCriteriaObjArg.filter != null ? siteCriteriaObjArg.filter:'';
    		
    		if(String.isNotBlank(categoryId)){
	    		listOfAllSite = mblSiteDataProviderObj.getAllSites(term, offset, recordLimit, categoryId, isFullModel);
	    		
    		} else {
    			
    			if(nextPageToken == null){
    				listOfFeaturedSite = mblSiteDataProviderObj.getAllFeaturedSites(term, offset, recordLimit, categoryId, isFullModel);
    				listOfLatestSite = mblSiteDataProviderObj.getAllLatestSites(term, offset, recordLimit, categoryId, isFullModel);
    				listOfFollowingSite = mblSiteDataProviderObj.getAllFollowingSites(term, offset, recordLimit, categoryId, isFullModel);
    				listOfCategoryItems = (new MobileSiteDataProvider()).convertToCategorySitesWrapper((new CategoryDao().getCategoriesWithSiteCount(term, 'natural', recordLimit, offset)));
    				
    			}else if('featured'.equalsIgnoreCase(filter)){
	    			listOfFeaturedSite = mblSiteDataProviderObj.getAllFeaturedSites(term, offset, recordLimit, categoryId, isFullModel);
	    		} else if('latest'.equalsIgnoreCase(filter)){
	    			listOfLatestSite = mblSiteDataProviderObj.getAllLatestSites(term, offset, recordLimit, categoryId, isFullModel);
	    		}else if('following'.equalsIgnoreCase(filter)){
				listOfFollowingSite = mblSiteDataProviderObj.getAllFollowingSites(term, offset, recordLimit, categoryId, isFullModel);
			} else if('all'.equalsIgnoreCase(filter)){
				listOfCategoryItems = (new MobileSiteDataProvider()).convertToCategorySitesWrapper((new CategoryDao().getCategoriesWithSiteCount(term, 'natural', recordLimit, offset)));
			}
    		}
			
			Integer nextPageTokenFeatured;
			Integer nextPageTokenLatest;
			Integer nextPageTokenFollowing;
			Integer nextPageTokenAll;
			Integer nextPageTokenCategoryItems;
			
			if(listOfFeaturedSite.size() == recordLimit){
				listOfFeaturedSite.remove(recordLimit - 1);
				nextPageTokenFeatured = offset + recordLimit-1;
			} else {
				nextPageTokenFeatured = null;
			}

			if(listOfLatestSite.size() == recordLimit){
				listOfLatestSite.remove(recordLimit - 1);
				nextPageTokenLatest = offset + recordLimit-1;
			} else {
				nextPageTokenLatest = null;
			}
			
			if(listOfFollowingSite.size() == recordLimit){
				listOfFollowingSite.remove(recordLimit - 1);
				nextPageTokenFollowing = offset + recordLimit-1;
			} else {
				nextPageTokenFollowing = null;
			}
			
			if(listOfAllSite.size() == recordLimit){
				listOfAllSite.remove(recordLimit - 1);
				nextPageTokenAll = offset + recordLimit-1;
			} else {
				nextPageTokenAll = null;
			}
			if(listOfCategoryItems.size() == recordLimit){
				listOfCategoryItems.remove(recordLimit - 1);
				nextPageTokenCategoryItems = offset + recordLimit-1;
			} else {
				nextPageTokenCategoryItems = null;
			}
				        
	        Map<String,Object> resultMap = new Map<String,Object>();
	        resultMap.put('featured',listOfFeaturedSite);
        	resultMap.put('latest',listOfLatestSite);
        	resultMap.put('following',listOfFollowingSite);
        	resultMap.put('all',listOfAllSite);
        	resultMap.put('category',listOfCategoryItems);
        	resultMap.put('nextPageTokenFeatured',nextPageTokenFeatured);
        	resultMap.put('nextPageTokenLatest',nextPageTokenLatest);
        	resultMap.put('nextPageTokenFollowing',nextPageTokenFollowing);
        	resultMap.put('nextPageTokenAll',nextPageTokenAll);
        	resultMap.put('nextPageTokenCategoryItems',nextPageTokenCategoryItems);
	        
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Site list for mobile app returned successfully!', resultMap);
	    	String pageName = '';
	    	if(String.isNotBlank(categoryId)){
	    		pageName = 'SitesByCategory';
	    	} else {
	    		pageName = filter+'Sites';
	    	}
	    	requestDataMap.put('userAgent', readHeader('User-Agent'));
	    	Utility.insertMobileAnalyticsRecord(pageName,requestDataMap);
		} catch(Exception e) {
        	logger.logError(e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
        }
    	
		return responseToReturn;
	}
	
	/**
	 * @api {post} /apex/DataServerRW?target=MobileSiteDataServer&action=getsiteDetailData getsiteDetailData
	 * @apiVersion 1.0.0
	 * @apiGroup MobileSiteDataServer
	 * @apiName getsiteDetailData
	 *
	 * @apiParam (Query Parameter) {String} action getsiteDetailData
	 * @apiParam (Query Parameter) {String} siteId site id
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting site detail
	 * @apiSuccess {SiteDetailWrapper} result site detail information
	 * @apiUse SiteDetailWrapper
	 * @apiError SimpplrException Simpplr Exception
	 */
	@testVisible private ResponseWrapper getsiteDetailData(String siteId) {
		ResponseWrapper responseToReturn = null;
		logger.logdebug('MobileSiteDataServer.getsiteDetailData()----siteId----'+siteId);
		try{  
        		Utility.insertMobileAnalyticsRecord('SiteAbout',new Map<String,String>{'siteId'=>siteId, 'userAgent'=>readHeader('User-Agent')});
			if(!SiteContext.isActive){
	    			throw new SimpplrException(ServiceConstants.ERROR_404);
		    	}
		    	if(!AccessManager.hasSiteAccess()) {
		    		SiteDetailWrapper sdWrapperObj = new MobileSiteDataProvider().getSiteMembership(siteId);
		    		
		    		if(SiteContext.isUnlistedSite){
		    			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.ERROR_404, sdWrapperObj);
		    		} else{
		    			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.ERROR_403, sdWrapperObj);
		    		}
		    	} else {
				SiteDetailWrapper sdWrapperObj = new MobileSiteDataProvider().getsiteDetailData(siteId);
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Site details returned successfully!', sdWrapperObj);
		    	}
	    	
		} catch(Exception e) {
        	logger.logError(e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
        }
    	
		return responseToReturn;
	}
	
	@testVisible private ResponseWrapper getPrivateSiteStatus(String privateSiteRequestId){
		ResponseWrapper responseToReturn = null;
		logger.logdebug('MobileSiteDataServer.getPrivateSiteStatus()----privateSiteRequestId----'+privateSiteRequestId);
		try{
        		Utility.insertMobileAnalyticsRecord('SiteAbout',new Map<String,String>{'privateSiteRequestId'=>privateSiteRequestId, 'userAgent'=>readHeader('User-Agent')});
			if(String.isNotBlank(privateSiteRequestId)){
				Map<String, Object> results;
				if('0I5'.equalsIgnoreCase(privateSiteRequestId.substring(0,3))){
					results = new MobileSiteDataProvider().getPrivateSiteStatus(privateSiteRequestId);
				} else {
					results = new MobileSiteDataProvider().getPublicSiteStatus(privateSiteRequestId);
				}
				
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Private Site Status returned successfully!', results);
		    	}else {
		    		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'No Data', null);
		    	}
		} catch(Exception e) {
        	logger.logError(e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
        }
    	
		return responseToReturn;
	}
	
	
	@testVisible private ResponseWrapper getFeaturedMandatorySiteList(){
		logger.logdebug('MobileSiteDataServer.getFeaturedMandatorySiteList()--------');
		
		ResponseWrapper responseToReturn = null;
		List<Segment_Site__c> segmentSiteList;
		Map<Id, SiteCacheWrapper> mapOfFeaturedMandatorySiteList = new Map<Id, SiteCacheWrapper>();
		SiteCacheWrapper siteCaheWrapObj;
		try{
        		Utility.insertMobileAnalyticsRecord('FeaturedMandatorySiteList',new Map<String,String>{'userAgent'=>readHeader('User-Agent')});
			
			
			if(SimpplrContext.isSegmentsEnabled){
				segmentSiteList = [Select Id, Site__c, Is_Featured__c from Segment_Site__c where Segment__c =: UserContext.segmentId AND Site__r.Is_Deleted__c = false AND Is_Featured__c = true WITH SECURITY_ENFORCED];
				for(Segment_Site__c segSiteRec : segmentSiteList){
					siteCaheWrapObj = new SiteCacheWrapper();
					siteCaheWrapObj.siteId = segSiteRec.Site__c;
					siteCaheWrapObj.isFeatured = true;
					mapOfFeaturedMandatorySiteList.put(segSiteRec.Site__c, siteCaheWrapObj);
				}
			}else {
				Map<Id, Simpplr_Site__c>featuredSiteMap = new Map<Id, Simpplr_Site__c>([Select Id, Is_Featured__c from Simpplr_Site__c where Is_Featured__c = true AND Is_Deleted__c = false]);
				for(Simpplr_Site__c siteRec : featuredSiteMap.values()){
					siteCaheWrapObj = new SiteCacheWrapper();
					siteCaheWrapObj.siteId = siteRec.Id;
					siteCaheWrapObj.isFeatured = true;
					mapOfFeaturedMandatorySiteList.put(siteRec.Id, siteCaheWrapObj);
				}
			}

			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', UserContext.segmentId);

			String queryString = 'Select Id, Site__c from Subscription_Entity__c where (Subscription__r.Audience__r.segment__c = null OR'
			+ ' Subscription__r.Audience__r.segment__c = :soqlParam1) and Status__c = \'approved\' and'
			+ ' Subscription__r.Action_Type__c = \'mandatory\' and Subscription__r.Status__c != \'Deleted\'';
					
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Subscription_Entity__c> subscriptionEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
			
			for(Subscription_Entity__c subEntityRec : subscriptionEntityList){
				if(mapOfFeaturedMandatorySiteList.containsKey(subEntityRec.Site__c)){
					siteCaheWrapObj = mapOfFeaturedMandatorySiteList.get(subEntityRec.Site__c);
				}else{
					siteCaheWrapObj = new SiteCacheWrapper();
					siteCaheWrapObj.siteId = subEntityRec.Site__c;
				}
				siteCaheWrapObj.isMandatory = true;
				mapOfFeaturedMandatorySiteList.put(subEntityRec.Site__c, siteCaheWrapObj);
			}
			
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Featured/Mandatory Site List per User Segment returned successfully!', mapOfFeaturedMandatorySiteList.values());
		    	

		} catch(Exception e) {
        	logger.logError(e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
    	
		return responseToReturn;
	}
}