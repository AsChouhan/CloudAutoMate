/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class TileDataServer extends DataServer {		
	
	private TileService tileServiceObj = new TileService(); 
	private String NO_PERMISSION = 'You do not have permission to perform this action';
	
	private final Integer CONTENT_TILE_ITEM_LIMIT = 18;
	private List<TileDataWrapper.TileData> listOfAIRecommendedItems = new List<TileDataWrapper.TileData>();
	private Boolean canCache = true;
	private Boolean isHomeAppManagerControlled = ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode);
	public TileDataServer() {
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
    public override void handleRequest(){
    	
        try{
	        	logger.logDebug('TileDataServer.handleRequest()----entered handleRequest----');
	        	String siteId = readParam('siteId');
	        	String dashboardId = readParam('dashboardId');
	        	String segmentId = readParam('segmentId');
				system.debug('tileId--37--'+ readParam('tileId'));
	        	Boolean isMobileOrigin = 'mobile'.equalsIgnoreCase(readParam('origin')) ? true : false;
	        	List<String> mobileTileList = new List<String>();
	        	logger.logDebug('TileDataServer.handleRequest()----siteId----' + siteId + '----dashboardId----' + dashboardId + '----segmentId----' + segmentId);
		    	String action = readParam('action');

				
				Boolean foundCache = false;
				
		    	if ('getTileList'.equalsIgnoreCase(action)) {
					String orgCacheTileListDataStr = '';
					if(SimpplrContext.isKitaPSARChangesEnabled && isHomeAppManagerControlled){
						String cacheName = 'cacheTileList';
						if(String.isBlank(siteId)){
							cacheName = cacheName+'Home';
						}else{
							cacheName = cacheName + 'Site'+siteId;
						}
						if(isMobileOrigin){
							cacheName += 'Mobile';
						}
						orgCacheTileListDataStr = 'Local.Cache.'+cacheName;
						if(!String.isBlank(SimpplrContext.namespacePrefix)){
							orgCacheTileListDataStr = 'Simpplr.Cache.'+cacheName;
						}
						
						ResponseWrapper result = (ResponseWrapper)Cache.Org.get(orgCacheTileListDataStr);
						if(result != null){
							logger.logDebug('Returned from Cache '+orgCacheTileListDataStr);
							foundCache = true;
							response = result;

						}

					}
					if(!foundCache){
						if(isMobileOrigin == true) {
							mobileTileList = (List<String>)JSON.deserialize(readParam('mobileTileList'), List<String>.class);
							logger.logDebug('TileDataServer.handleRequest()----mobileTileList----' + mobileTileList);		    	
						}
						if('home'.equalsIgnoreCase(dashboardId)) {
							if (ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
								if (!UserContext.isTilesInitialized) {
									response = createUserDefaultTiles();
									if(isMobileOrigin == true) {
										response = getUserHomeTilesOrder(isMobileOrigin, mobileTileList);
									}
								} else {
									response = getUserHomeTilesOrder(isMobileOrigin, mobileTileList);
								}
							} else if (SimpplrContext.isSegmentsEnabled) {
								segmentId = isMobileOrigin == true ? UserContext.segmentId : segmentId;
								response = getSegmentTilesOrder(segmentId, isMobileOrigin, mobileTileList);
							
							} else {
								response = getAppManagerHomeTilesOrder(isMobileOrigin, mobileTileList);
							}
								
						} else if ('home-default'.equalsIgnoreCase(dashboardId)) {
								segmentId = isMobileOrigin == true ? UserContext.segmentId : segmentId;
								response = getHomeDefaultTilesOrder(segmentId, isMobileOrigin, mobileTileList);
								
						} else if('site'.equalsIgnoreCase(dashboardId)) {
							response = getSiteTilesOrder(siteId, isMobileOrigin, mobileTileList);
							
						}
						if( isHomeAppManagerControlled && SimpplrContext.isKitaPSARChangesEnabled){
							logger.logDebug('Added To CACHE '+orgCacheTileListDataStr);
							System.debug('<<<<<Cache memory key >>'+orgCacheTileListDataStr);
							System.debug('<<<<<Cache memory response value >>'+response);
							Cache.Org.put(orgCacheTileListDataStr, response);
						}
					}
					if(isMobileOrigin){
						Utility.insertMobileAnalyticsRecord('homedashboard',new Map<String,String>{'peopleId'=>UserContext.peopleId, 'userAgent'=>readHeader('User-Agent')});
					}	
					
		    	} else if ('getTile'.equalsIgnoreCase(action)) {
					String orgCacheTileDataStr = '';
					if(SimpplrContext.isKitaPSARChangesEnabled && isHomeAppManagerControlled){
						String cacheName = 'cacheTileData';
						String tileId = readParam('tileId');
						if(isMobileOrigin){
							cacheName += 'Mobile';
						}
						cacheName += tileId;
						orgCacheTileDataStr = 'Local.Cache.'+cacheName;
						if(!String.isBlank(SimpplrContext.namespacePrefix)){
							orgCacheTileDataStr = 'Simpplr.Cache.'+cacheName;
						}
						ResponseWrapper result = (ResponseWrapper)Cache.Org.get(orgCacheTileDataStr);
						if(result != null){
							logger.logDebug('Returned from Cache '+orgCacheTileDataStr);
							foundCache = true;
							response = result;

						}
					}
					if(!foundCache){
						response = getTileData(dashboardId, siteId, segmentId, readParam('tileId')); 
						if(canCache && isHomeAppManagerControlled && SimpplrContext.isKitaPSARChangesEnabled){
							logger.logDebug('Added To CACHE '+orgCacheTileDataStr);
							Cache.Org.put(orgCacheTileDataStr, response);
						}
					}
					
					
				
				} else {//clear cache
					system.debug('tileId--146--'+ readParam('tileId'));
		        	if(checkTileModerationAccess(dashboardId, segmentId, siteId, readParam('tileId')) == false) {
		    			throw new SimpplrException(ServiceConstants.ERROR_403);
		    		}
		    		if ('setPositions'.equalsIgnoreCase(action)) {
			        	String positionJson = readParam('position');
			        	if('home'.equalsIgnoreCase(dashboardId)) {
			    			if (ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
		    					tileServiceObj.setUserHomeDashboardPosition(positionJson);
		    					
		    				} else if (SimpplrContext.isSegmentsEnabled) {
							tileServiceObj.setSegmentDashboardPosition(segmentId, positionJson);
							
			    			} else {
		    					tileServiceObj.setHomeDashboardPosition(positionJson);
		    				}
			    				
			    		} else if ('home-default'.equalsIgnoreCase(dashboardId)) {
		    					tileServiceObj.setHomeDefaultPosition(segmentId, positionJson);
			    				
			    		} else if('site'.equalsIgnoreCase(dashboardId)) {
			    			tileServiceObj.setSiteDashboardPosition(siteId, positionJson);
			    			
			    		}

			    	} else if ('setLayout'.equalsIgnoreCase(action)) {
			        	String layout = readParam('layout');
			        	if('home'.equalsIgnoreCase(dashboardId)) {
			    			if (ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
		    					tileServiceObj.setUserDashboardLayout(layout);
		    					
		    				} else if (SimpplrContext.isSegmentsEnabled) {
							tileServiceObj.setSegmentDashboardLayout(segmentId, layout);
							
			    			} else {
		    					tileServiceObj.setHomeDashboardLayout(layout);
		    				}
			    				
			    		} else if ('home-default'.equalsIgnoreCase(dashboardId)) {
		    					tileServiceObj.setHomeDefaultLayout(segmentId, layout);
			    				
			    		} else if('site'.equalsIgnoreCase(dashboardId)) {
			    			tileServiceObj.setSiteDashboardLayout(siteId,layout);
			    			
			    		}

			    	} else if('addTile'.equalsIgnoreCase(action)) {
						response = addTile(segmentId, dashboardId, siteId, readParam('tile'));

			    	} else if('editTile'.equalsIgnoreCase(action)) {
			    		String tileId = readParam('tileId');
			    		String tile = readParam('tile');
						response = editTile(segmentId, dashboardId, siteId, tileId, tile);

			    	} else if('removeTile'.equalsIgnoreCase(action)) {
		        		response = removeTile(readParam('tileId'), segmentId, dashboardId);

		        	} else if('resetToDefault'.equalsIgnoreCase(action)) {
		    			response = resetToDefaultHomeDashboard(segmentId, dashboardId);

		        	} else if('applyDefaultHomeToAllUsers'.equalsIgnoreCase(action)){
			    		response = applyDefaultHomeToAllUsers(segmentId, dashboardId);	
		        		
		        	}else {
						throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
					}

					CacheManagerUtil.clearCacheContainsKey(ServiceConstants.CACHE_TILE);
		    	}
        }catch(Exception ex){
			logger.logError('TileDataServer.handleRequest()----Exception Occured----',ex);
           response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
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
	/**
	 * @description fetch site tile record
	 * @param siteId
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	 */
    @TestVisible
    private ResponseWrapper getSiteTilesOrder(String siteId, Boolean isMobileOrigin, List<String> mobileTileList){
    		logger.logDebug('TileDataServer.getSiteTilesOrder()----siteId----'+siteId);
        TileDataWrapper.TileOrderData tileOrderDataObj = new TileDataWrapper.TileOrderData();
		tileOrderDataObj = tileServiceObj.getSiteTilesOrderConfig(siteId, isMobileOrigin, mobileTileList);
		ResponseWrapper localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Tiles order response successful', tileOrderDataObj);        
        logger.logDebug('TileDataServer.getSiteTilesOrder()----localResult----'+localResult);
        return localResult;
    }

	/**
	 * @description fetch segment tile order
	 * @param segmentId
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	 */
    @TestVisible
    private ResponseWrapper getSegmentTilesOrder(String segmentId, Boolean isMobileOrigin, List<String> mobileTileList){
    		logger.logDebug('TileDataServer.getSegmentTilesOrder()----segmentId----'+segmentId);
    		if(String.isBlank(segmentId) || (UserContext.isUserAppModerator == false && segmentId.equalsIgnoreCase(UserContext.SegmentId) == false)) {
    			throw new SimpplrException(ServiceConstants.ERROR_403);
    		}
        TileDataWrapper.TileOrderData tileOrderDataObj = new TileDataWrapper.TileOrderData();
    		tileOrderDataObj = tileServiceObj.getSegmentTilesOrderConfig(segmentId, isMobileOrigin, mobileTileList);
        ResponseWrapper localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Tiles order response successful', tileOrderDataObj);        
        logger.logDebug('TileDataServer.getSegmentTilesOrder()----localResult----'+localResult);
        return localResult;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	/**
	 * @description fetch user home tile order
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	 */
    @TestVisible 
    private ResponseWrapper getUserHomeTilesOrder(Boolean isMobileOrigin, List<String> mobileTileList){
        ResponseWrapper localResult = null;
        TileDataWrapper.TileOrderData tileOrderDataObj = new TileDataWrapper.TileOrderData();
       
        try { 
        	tileOrderDataObj = tileServiceObj.getUserHomeTilesOrderConfig(isMobileOrigin, mobileTileList); 
			System.debug('(((((TDS((286((((tileOrderDataObj' + tileOrderDataObj);
    	
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'User Controlled Tiles order response successful', tileOrderDataObj);        
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve user home tiles order',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getUserHomeTilesOrder()----localResult----'+localResult);
        return localResult;
    }

	/**
	 * @description fetch home default tile order
	 * @param segmentId
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	*/
    private ResponseWrapper getHomeDefaultTilesOrder(String segmentId, Boolean isMobileOrigin, List<String> mobileTileList){
        ResponseWrapper localResult = null;
        TileDataWrapper.TileOrderData tileOrderDataObj = new TileDataWrapper.TileOrderData();
       
        try { 
        		tileOrderDataObj = tileServiceObj.getHomeDefaultTilesOrder(segmentId, isMobileOrigin, mobileTileList); 	
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Home defaults tiles response successful', tileOrderDataObj);        
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve default home tiles',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        logger.logDebug('TileDataServer.getHomeDefaultTilesOrder()----localResult----'+localResult);
        return localResult;
    }
/**
 * @api {post} /apex/DataServerRO?target=TileDataServer&action=getTileList getTileList
 * @apiVersion 1.0.0
 * @apiGroup TileDataServer
 * @apiName getTileList
 *
 * @apiParam (Query Parameter) {String} action getTileList 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.dashboard.getTileList
 * 
 * @apiSuccess {TileDataWrapper.TileOrderData} TileDataWrapper.TileOrderData based on the itemType
 * @apiUse TileDataWrapperTileOrderData
 * @apiUse TileDataWrapperTilesOrder
 *
 * @apiError SimpplrException Simpplr Exception
 */
	/**
	 * @description fetch App Manager home tile recorrd
	 * @param isMobileOrigin - flag to decide request come from mobile
	 * @param mobileTileList - list of variant to ignore 
	 * @return ResponseWrapper
	*/
    @TestVisible
    private ResponseWrapper getAppManagerHomeTilesOrder(Boolean isMobileOrigin, List<String> mobileTileList){
        ResponseWrapper localResult = null;
        TileDataWrapper.TileOrderData tileOrderDataObj = new TileDataWrapper.TileOrderData();
        
        try { 
        	tileOrderDataObj = tileServiceObj.getAppManagerHomeTilesOrderConfig(isMobileOrigin, mobileTileList); 
			System.debug('********tileOrderDataObj  349'+tileOrderDataObj);
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'App manager controlled order response successful', tileOrderDataObj);        
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve App Manager home tiles order',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getAppManagerHomeTilesOrder()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getLatestHires(String siteId, String segmentId, String tileId, TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getLatestHires()----tiledataSettings----' + tiledataSettings);
        ResponseWrapper localResult = null;
        
        try {
        	TileDataWrapper.LatestHiresData latestHiresDataObj = tileServiceObj.getLatestHires(siteId, segmentId, tileId, tiledataSettings);
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Latest Hires response successful', latestHiresDataObj);	        
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve Latest Hires',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getLatestHires()----localResult----'+localResult);
        return localResult;
    }
	
	private ResponseWrapper getGoogleCalendarTileData(Map<String, String> calendarDetails, String siteFilter, String type) {
		logger.logDebug('TileDataServer.getGoogleCalendarTileData()----calendarDetails----' + calendarDetails+ '--siteFilter--'+ siteFilter + '--type--' +type);
		ResponseWrapper localResult = null;
        try {
			Criteria.Event contentCriteriaObjArg = new Criteria.Event();
			contentCriteriaObjArg.calendarId = EncodingUtil.urlEncode(calendarDetails.get('id'), 'UTF-8');
			contentCriteriaObjArg.size = CONTENT_TILE_ITEM_LIMIT;
			TileDataWrapper.GoogleCalendarData tileDataObj = new TileDataWrapper.GoogleCalendarData();
			tileDataObj.options.calendar = calendarDetails;
			if(UserContext.Integrations != null && UserContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR) 
				&& UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR).Connected__c) {
				GoogleCalendarHelper helperObj = new GoogleCalendarHelper(); 			
				Map<String, Object> resultMap = helperObj.getEventsSearchResults(contentCriteriaObjArg);
				tileDataObj.listOfItems = (List<Object>) resultMap.get('listOfItems');
				tileDataObj.nextPageToken = (String) resultMap.get('nextPageToken');
			} else {
				tileDataObj.listOfItems = new List<Object>();
				tileDataObj.nextPageToken = null;
			}
			if(siteFilter != null){
				tileDataObj.options.siteFilter =  siteFilter;
			}
			if(type != null){
				tileDataObj.options.type = type;
			}
			localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, tileDataObj);	
		} catch(Exception e) {
			logger.logError('Could not retrieve Google Calendar Tile Data',e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return localResult;

	}
    @TestVisible
    private ResponseWrapper getLatestPopularContentTileData(String dashboardId, String siteId, String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
        logger.logDebug('TileDataServer.getLatestPopularContentTileData()----dashboardId----'+dashboardId+'----tileId----'+tileId+'----tiledataSettings----'+tiledataSettings);
        ResponseWrapper localResult = null;
        try {
			TileDataWrapper.LatestPopularContentTileData tileDataObj = new TileDataWrapper.LatestPopularContentTileData();
			tileDataObj.id = tileId;
			tileDataObj.options.type = tiledataSettings.type;
			tileDataObj.options.layout = tiledataSettings.layout;
			tileDataObj.options.pageCategoryID = tiledataSettings.pageCategoryID;
			
			String siteIdArg = siteId;
			if('home'.equalsIgnoreCase(dashboardId) || 'home-default'.equalsIgnoreCase(dashboardId)){
				tileDataObj.options.siteId = tiledataSettings.siteId;
				tileDataObj.options.siteFilter = tiledataSettings.siteFilter;
				siteIdArg = tiledataSettings.siteId;
				if(String.isNotBlank(tileDataObj.options.siteId)) {
					tileDataObj.options.siteName = new SiteDao().getSiteName(tileDataObj.options.siteId);
				}
			} 
        		TileDataWrapper.ContentTabData latestContentTabDataObj = new TileDataWrapper.ContentTabData();
        		latestContentTabDataObj.section = 'Event'.equalsIgnoreCase(tiledataSettings.type) ? 'upcoming' : 'latest';
        		latestContentTabDataObj.listOfItems = ContentDataProvider.getLatestTileData(siteIdArg, tiledataSettings.type, CONTENT_TILE_ITEM_LIMIT);
        		
        		TileDataWrapper.ContentTabData popularContentTabDataObj = new TileDataWrapper.ContentTabData();
        		popularContentTabDataObj.section = 'popular';
        		popularContentTabDataObj.listOfItems = ContentDataProvider.getPopularTileData(siteIdArg, tiledataSettings.type, CONTENT_TILE_ITEM_LIMIT);

				if(('home'.equalsIgnoreCase(dashboardId) || 'home-default'.equalsIgnoreCase(dashboardId)) && SimpplrContext.aiContentRecommendationEnabled && !listOfAIRecommendedItems.isEmpty()){	
					//Show Recommended contents only if AI Content Recommendation Enabled
					TileDataWrapper.ContentTabData recommendedContentTabDataObj = new TileDataWrapper.ContentTabData();
					recommendedContentTabDataObj.section = 'recommended';
					recommendedContentTabDataObj.listOfItems = listOfAIRecommendedItems;
					tileDataObj.listOfItems.add(recommendedContentTabDataObj);
				}
				tileDataObj.listOfItems.add(latestContentTabDataObj);
				tileDataObj.listOfItems.add(popularContentTabDataObj);

	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, tileDataObj);
			
			if(isHomeAppManagerControlled && SimpplrContext.isKitaPSARChangesEnabled){
				if(tileDataObj.listOfItems!=null){
					for(TileDataWrapper.ContentTabData contentTabDataRecord : tileDataObj.listOfItems){
						for(TileDataWrapper.TileData tileDataRecord : contentTabDataRecord.listOfItems){
							if(tileDataRecord.site!=null){
								if(tileDataRecord.site.isPublic==false){
									canCache = false;
									break;
								}
							}
						}
					}
				}
			}


        } catch(Exception e) {
			logger.logError('Could not retrieve Latest Tile Data',e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        logger.logDebug('TileDataServer.getLatestPopularContentTileData()----localResult----'+localResult);
        return localResult;
    }
    
    
    
    @TestVisible
    private ResponseWrapper getLatestPopularCampaignTileData(String dashboardId, String siteId, String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
        logger.logDebug('TileDataServer.getLatestPopularCampaignTileData()----dashboardId----'+dashboardId+'----tileId----'+tileId+'----tiledataSettings----'+tiledataSettings);
        ResponseWrapper localResult = null;
        try {
			TileDataWrapper.LatestPopularCampaignTileData tileDataObj = new TileDataWrapper.LatestPopularCampaignTileData();
			tileDataObj.id = tileId;
			tileDataObj.options.type = tiledataSettings.type;
			tileDataObj.options.layout = tiledataSettings.layout;
			CampaignService csObj = new CampaignService();
    		TileDataWrapper.CampaignTabData latestCampaignTabDataObj = new TileDataWrapper.CampaignTabData();
    		latestCampaignTabDataObj.section = 'latest';
    		latestCampaignTabDataObj.listOfItems = csObj.getLatestCampaignTilesData();
    		
    		TileDataWrapper.CampaignTabData popularCampaignTabDataObj = new TileDataWrapper.CampaignTabData();
    		popularCampaignTabDataObj.section = 'popular';
    		popularCampaignTabDataObj.listOfItems = csObj.getPopularCampaignTilesData();
    		
    		tileDataObj.listOfItems.add(latestCampaignTabDataObj);
    		tileDataObj.listOfItems.add(popularCampaignTabDataObj);
        		
        	
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, tileDataObj);
			
        } catch(Exception e) {
			logger.logError('Could not retrieve latest/popular campaign tile data',e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        logger.logDebug('TileDataServer.getLatestPopularCampaignTileData()----localResult----'+localResult);
        return localResult;
    }
    
    
    @TestVisible
    private  ResponseWrapper getPagesWidgetData(String dashboardId, String siteId, String tileId, String variant,TileDataWrapper.TileDataSettings tiledataSettings){
        logger.logDebug('TileDataServer.getPagesWidgetData()----siteId----'+siteId+'----tileId----'+tileId+'----variant----'+variant);
        ResponseWrapper localResult = null;
        
        try {
        	TileDataWrapper.ContentData contentDataObj = new TileDataWrapper.ContentData();
       		if('home'.equalsIgnoreCase(dashboardId) || 'home-default'.equalsIgnoreCase(dashboardId)){
        		contentDataObj.listOfItems = ContentDataProvider.getPagesWidgetData(tiledataSettings.siteId, CONTENT_TILE_ITEM_LIMIT,variant,tiledataSettings.value, tiledataSettings.pageCategoryID);
        	}else {
    			contentDataObj.listOfItems = ContentDataProvider.getPagesWidgetData(siteId, CONTENT_TILE_ITEM_LIMIT,variant,tiledataSettings.value, tiledataSettings.pageCategoryID);
        	}

        	if(String.isNotBlank(tiledataSettings.siteId)){
        		contentDataObj.options.siteId = tiledataSettings.siteId;
        		contentDataObj.options.siteName = new SiteDao().getSiteName(contentDataObj.options.siteId);
        	}

    		if(String.isNotBlank(tiledataSettings.pageCategoryID)){
    			contentDataObj.options.pageCategoryID = tiledataSettings.pageCategoryID;
    			Pages_Category__c pageCategoryObj = new CategoryDao().getCategoryWithId(contentDataObj.options.pageCategoryID);
    			contentDataObj.options.pageCategoryName = pageCategoryObj != null ? pageCategoryObj.Name__c : null;
    		}
    		
    		contentDataObj.options.siteFilter = tiledataSettings.siteFilter;
    		contentDataObj.options.layout = tiledataSettings.layout;
    		contentDataObj.id = tileId;

	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentDataObj);	        
        
        } catch(Exception e) {
			logger.logError('Could not retrieve Pages Widget Data',e);
			localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        logger.logDebug('TileDataServer.getPagesWidgetData()----localResult----'+localResult);
        return localResult;
    }
    
    private ResponseWrapper getCustomTilesData(String dashboardId, String siteId, String tileId, String variant,TileDataWrapper.TileDataSettings tiledataSettings){
        logger.logDebug('TileDataServer.getCustomTilesData()----siteId----'+siteId+'----tileId----'+tileId+'----variant----'+variant);

        ResponseWrapper localResult = null;
        
        try {
        	TileDataWrapper.ContentData contentDataObj = new TileDataWrapper.ContentData();
        	if('home'.equalsIgnoreCase(dashboardId) || 'home-default'.equalsIgnoreCase(dashboardId)){
        		contentDataObj.listOfItems = ContentDataProvider.getCustomTilesData(tiledataSettings.siteId, tiledataSettings);
			}else {
    			contentDataObj.listOfItems = ContentDataProvider.getCustomTilesData(siteId, tiledataSettings);
        	}
			if(isHomeAppManagerControlled && SimpplrContext.isKitaPSARChangesEnabled){
				for(TileDataWrapper.TileData tileData : contentDataObj.listOfItems)	{
					if(tileData.site!=null){
						if(tileData.site.isPublic==false){
							canCache = false;
							break;
						}
					}
				}
			}
	
        	
    		contentDataObj.options.siteId = tiledataSettings.siteId;
    		contentDataObj.options.siteFilter = tiledataSettings.siteFilter;
    		contentDataObj.options.layout = tiledataSettings.layout;
    		contentDataObj.id = tileId;
        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentDataObj);	        
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve custom tiles data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('TileDataServer.getCustomTilesData()----localResult----'+localResult);
        return localResult;
    }
    
    private ResponseWrapper getCampaignTilesData(String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
        logger.logDebug('TileDataServer.getCampaignTilesData()----tiledataSettings----'+tiledataSettings);

        ResponseWrapper localResult = null;
        
        try {
        	TileDataWrapper.CampaignData campaignDataObj = new TileDataWrapper.CampaignData();
    		CampaignService campaignServiceObj = new CampaignService();
    		campaignDataObj.listOfItems = campaignServiceObj.getCampaignTilesData(tiledataSettings);
    		campaignDataObj.options.layout = tiledataSettings.layout;
    		campaignDataObj.id = tileId;
        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, campaignDataObj);	        
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve campaign tiles data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('TileDataServer.getCampaignTilesData()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getAboutDetail(String siteId,String tileId){
    	logger.logDebug('TileDataServer.getAboutDetail()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions aboutDetail = new TileDataWrapper.WidgetOptions();
        
        try {
        	aboutDetail = tileServiceObj.getGroupDescription(siteId, tileId);	        
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'About Detail response successful', aboutDetail);	        
        	aboutDetail.id = tileId;
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve Site About details',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getAboutDetail()----localResult----'+localResult);
        return localResult;
    }
    
    private ResponseWrapper getPageCategoriesTileData(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings) {
    	logger.logDebug('TileDataServer.getPageCategoriesTileData()----siteId----'+siteId+'----tileId----'+tileId);
    	ResponseWrapper localResult = null;
    	try {
    		TileDataWrapper.CategoriesData pageCategoriesTile = tileServiceObj.getPageCategoriesTileData(siteId, tileId, tiledataSettings);
			if(isHomeAppManagerControlled && SimpplrContext.isKitaPSARChangesEnabled){
				if(pageCategoriesTile.listOfItems!=null){
					for(TileDataWrapper.TileData tileDataRecord :  pageCategoriesTile.listOfItems){
						if(tileDataRecord.site!=null){
							if(tileDataRecord.site.isPublic==false){
								canCache = false;
							}
						}
					}
				}
			}
			

	    	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, pageCategoriesTile);
    	
    	} catch(Exception e) {
        	logger.logError('Could not retrieve Site Site Information Tile Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
    	
    	logger.logDebug('TileDataServer.getPageCategoriesTileData()----localResult----'+localResult);
        return localResult;
    }
    
    private ResponseWrapper getSiteCategoriesTileData(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings) {
    	logger.logDebug('TileDataServer.getSiteCategoriesTileData()----siteId----'+siteId+'----tileId----'+tileId);
    	ResponseWrapper localResult = null;
    	try {
    		TileDataWrapper.CategoriesData pageCategoriesTile = tileServiceObj.getSiteCategoriesTileData(siteId, tileId,tiledataSettings);
	    	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, pageCategoriesTile);
		
			if(isHomeAppManagerControlled && SimpplrContext.isKitaPSARChangesEnabled){
				if(pageCategoriesTile.listOfItems!=null){
					for(TileDataWrapper.TileData tileDataRecord :  pageCategoriesTile.listOfItems){
						if(tileDataRecord.site!=null){
							if(tileDataRecord.site.isPublic==false){
								canCache = false;
							}
						}
					}
				}
			}
			
    	} catch(Exception e) {
        	logger.logError('Could not retrieve Site Site Information Tile Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
    	
    	logger.logDebug('TileDataServer.getSiteCategoriesTileData()----localResult----'+localResult);
        return localResult;
    }
    
    @TestVisible
    private ResponseWrapper getSiteInformationTileData(String siteId,String tileId){
    	logger.logDebug('TileDataServer.getSiteInformationTileData()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions informationTile = new TileDataWrapper.WidgetOptions();
        
        try {
        	informationTile = tileServiceObj.getSiteInformationTileData(siteId, tileId);	        
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, informationTile);	        
        	informationTile.id = tileId;
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve Site Site Information Tile Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        return localResult;
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
    private ResponseWrapper getMySites(String siteId,String tileId,String variant,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getMySites()----siteId----'+siteId+'----tileId----'+tileId+'----variant----'+variant);
        ResponseWrapper localResult = null;
        
        try {
        		TileDataWrapper.MySitesData MySitesDataObj = tileServiceObj.getSiteList(siteId,tileId,variant, tiledataSettings); 
        		MySitesDataObj.options.layout = tiledataSettings.layout;     	
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'My Sites response successful', MySitesDataObj);	        
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve Sites',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getMySites()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getTwitterDetail(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getTwitterDetail()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions twitterDetailObj = new TileDataWrapper.WidgetOptions();
        
        try {
        	twitterDetailObj = tileServiceObj.getTwitterWidgetData(siteId, tileId, tiledataSettings);
    		twitterDetailObj.id = tileId;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Twitter response successful', twitterDetailObj);	        
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve Twitter details',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getTwitterDetail()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getFacebookDetail(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getFacebookDetail()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions facebookDetailObj;
        
        try {
        	facebookDetailObj = tileServiceObj.getFacebookWidgetData(siteId,tileId, tiledataSettings); 
        	facebookDetailObj.id = tileId;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'facebook response successful', facebookDetailObj);	        
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve Facebook details',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getFacebookDetail()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getHTMLWidgetOne(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getHTMLWidgetOne()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions HTMLWidgetOneDataObj;
       
        try {
	        	HTMLWidgetOneDataObj = tileServiceObj.getHTMLWidgetOneData(siteId, tileId, tiledataSettings);
	        	HTMLWidgetOneDataObj.id = tileId;
	        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,'HTMLWidgetOneData response successful', HTMLWidgetOneDataObj);	        
        
        } catch(Exception e) {
	        	logger.logError('Could not retrieve HTML Widget details',e);
	        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getHTMLWidgetOne()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getImageData(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getImageData()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions imageObj;
       
        try {
	        	imageObj = tileServiceObj.getImageData(siteId, tileId, tiledataSettings);
	        	imageObj.id = tileId;
	        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,'Image Tile response successful', imageObj);	        
        
        } catch(Exception e) {
	        	logger.logError('Could not retrieve Image Tile details',e);
	        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getImageData()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getVideoData(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getVideoData()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions videoObj;
       
        try {
	        	videoObj = tileServiceObj.getVideoData(siteId, tileId, tiledataSettings);
	        	videoObj.id = tileId;
	        	localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Video Tile response successful', videoObj);	        
        
        } catch(Exception e) {
	        	logger.logError('Could not retrieve Video Tile details',e);
	        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getVideoData()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getAppData(String siteId,String tileId, TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getAppData()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.AppData AppDataObj;
       
        try {
        	AppDataObj = tileServiceObj.getAppData(siteId,tileId,tiledataSettings);
        	AppDataObj.id = tileId;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'AppData response successful', AppDataObj);	        
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve App data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getAppData()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getPeopleListData(String siteId,String tileId,String variant,TileDataWrapper.TileDataSettings tiledataSettings) {
    	logger.logDebug('TileDataServer.getPeopleListData()----siteId----'+siteId+'----tileId----'+tileId+'----variant----'+variant);
        ResponseWrapper localResult = null;
        TileDataWrapper.PeopleData peopleDataObj = new TileDataWrapper.PeopleData();
       
        try {
        	peopleDataObj = tileServiceObj.getPeopleListData(siteId, tileId,variant, tiledataSettings);
        	peopleDataObj.id = tileId;
        	peopleDataObj.options.layout = tiledataSettings.layout;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'PeopleListData response successful', peopleDataObj);	        
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve Followers Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getPeopleListData()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getRSSData(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getRSSData()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions rssObj = new TileDataWrapper.WidgetOptions();
        
        try {
        	rssObj = tileServiceObj.getRSSData(siteId, tileId, tiledataSettings);
        	rssObj.id = tileId;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'RSS detail response successful', rssObj);	        
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve RSS Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        logger.logDebug('TileDataServer.getRSSData()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getFileData(String siteId,String tileId,String variant,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getFileData()----siteId----'+siteId+'----tileId----'+tileId+'----variant----'+variant);
        ResponseWrapper localResult = null;
		TileDataWrapper.FileData fileDataObj = new TileDataWrapper.FileData();
		TileDataWrapper.FileDataGoogleDrive fileDataGoogleDriveObj = new TileDataWrapper.FileDataGoogleDrive();
       
        try {        	
			
			if('googleDrive'.equalsIgnoreCase(variant) && 'recent_and_starred'.equalsIgnoreCase(tiledataSettings.type)) {
				fileDataGoogleDriveObj = tileServiceObj.getStarredAndRecentGoogleDriveFiles(siteId);
				localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileDataGoogleDriveObj);
				canCache = false;
			} else {
				fileDataObj = tileServiceObj.getFileList(siteId,tileId,variant, tiledataSettings);
				fileDataObj.id = tileId;
				localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileDataObj);	        
			}
			
        } catch(Exception e) {
        	logger.logError('Could not retrieve File Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getFileData()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getHelpLinkData(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getHelpLinkData()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        try {
	        TileDataWrapper.MyHelpLinkData helpLinkDataObj = new TileDataWrapper.MyHelpLinkData();
	        TileService tsObj = new TileService();
	        if(tiledataSettings.listOfItems != null){
		        for(TileDataWrapper.TileData linkData : tiledataSettings.listOfItems){
		        	if(linkData.imageFile != null){
		        		linkData.imageFile = tsObj.getImageFile(linkData.imageFile);
		        	} 
		        }
	        }
	        helpLinkDataObj.listOfItems = tiledataSettings.listOfItems;
        	helpLinkDataObj.id = tileId;
        	helpLinkDataObj.options.layout = tiledataSettings.layout;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS ,' Help Link detail response successful', helpLinkDataObj);	        
        
        } catch(Exception e) {
        	logger.logError('Could not retrieve HelpLink Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getHelpLinkData()----localResult----'+localResult);
        return localResult;
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
    private ResponseWrapper getCountdownData(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
    	logger.logDebug('TileDataServer.getCountdownData()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions countDownWidget = new TileDataWrapper.WidgetOptions();
        
        try {
        	countDownWidget = tileServiceObj.getCountDownData(siteId,tileId, tiledataSettings);
        	countDownWidget.id = tileId;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' CountDown detail response successful', countDownWidget);	        
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve CountDown Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getCountdownData()----localResult----'+localResult);
        return localResult;
    }
    
     @TestVisible
    private ResponseWrapper getTextWidgetData(String siteId,String tileId,TileDataWrapper.TileDataSettings tiledataSettings){
        logger.logDebug('TileDataServer.getTextWidgetData()----siteId----'+siteId+'----tileId----'+tileId);
        ResponseWrapper localResult = null;
        TileDataWrapper.WidgetOptions textWidgetDetail = new TileDataWrapper.WidgetOptions();
       
        try {
        	textWidgetDetail = tileServiceObj.getTextWidgetData(siteId,tileId, tiledataSettings);
        	textWidgetDetail.id = tileId;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, textWidgetDetail);	        
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve Pages Widget Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(e.getMessage()), null);
        }
        
        logger.logDebug('TileDataServer.getTextWidgetData()----localResult----'+localResult);
        return localResult;
    }
	
/**
 * @api {post} /apex/DataServerRW?target=TileDataServer&action=removeTile removeTile
 * @apiVersion 1.0.0
 * @apiGroup TileDataServer
 * @apiName removeTile
 *
 * @apiParam (Query Parameter) {String} action removeTile
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.dashboard.removeTile
 * 
 * @apiError SimpplrException Simpplr Exception
 */
   	private ResponseWrapper removeTile(String tileId, String segmentId, String dashboadId) {
		ResponseWrapper result = null;
		try {
			logger.logDebug('TileDataServer.removeTile()----tileId----' + tileId + '----segmentId----' + segmentId + '----dashboadId----' + dashboadId);
    		tileServiceObj.removeTile(tileId, segmentId, dashboadId);
	    	result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		}catch(Exception e){
			logger.logError('TileDataServer.removeTile()----Exception Occured--' + e.getTypeName(),e);
            result = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
		return result;
    }

	private ResponseWrapper resetToDefaultHomeDashboard(String segmentId, String dashboardId) {
		logger.logDebug('TileDataServer.removeTile()----segmentId----' + segmentId);
		logger.logDebug('TileDataServer.removeTile()----dashboardId----' + dashboardId);
    		if(ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode) == false) {
    			throw new SimpplrException(ServiceConstants.ERROR_403);
    		}
		tileServiceObj.resetToDefaultHomeDashboard(segmentId);
		ResponseWrapper result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    		return result;
    }
    
/**
 * @api {post} /apex/DataServerRW?target=TileDataServer&action=applyDefaultHomeToAllUsers applyDefaultHomeToAllUsers
 * @apiVersion 1.0.0
 * @apiGroup TileDataServer
 * @apiName applyDefaultHomeToAllUsers
 *
 * @apiParam (Query Parameter) {String} action applyDefaultHomeToAllUsers
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.dashboard.applyDefaultHomeToAllUsers
 * 
 * @apiError SimpplrException Simpplr Exception
 */
    private ResponseWrapper applyDefaultHomeToAllUsers(String segmentId, String dashboardId){
   		ResponseWrapper result = null;
   		try {
   			tileServiceObj.applyDefaultHomeToAllUsers(segmentId, dashboardId);
   			result = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Applying Home Default to all users Home - this process may take some time', 'null');
		} catch(exception e){
      		logger.logError('TileDataServer.applyDefaultHomeToAllUsers()-----could not retrieve data----',e);
  			result = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return result;
    }
    
	private ResponseWrapper addTile(String segmentId, String dashboardId, String siteId, String tile) {
		ResponseWrapper response = null;
		try {
			TileDataWrapper.AddTile tileWrapperObj = (TileDataWrapper.AddTile)JSON.deserialize(tile, TileDataWrapper.AddTile.class);
			List<Tiles_Config__c> addedTileList;
			Boolean googleCalendarTile = false;
			Boolean outlookCalendarTile = false;
			Boolean googleDriveTile = false;
			Boolean newHireTile = false;
			Boolean recommendedTabInLatestPopularTile = false;
			Boolean onboardingTile = false;
			if('latest_popular'.equalsIgnoreCase(tileWrapperObj.variant) && 
				'googleCalendar'.equalsIgnoreCase(tileWrapperObj.options.siteFilter)) {
				googleCalendarTile = true;
				response = getGoogleCalendarTileData(tileWrapperObj.options.calendar,tileWrapperObj.options.siteFilter,tileWrapperObj.options.type);

			} else if('latest_popular'.equalsIgnoreCase(tileWrapperObj.variant) && 
				IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(tileWrapperObj.options.siteFilter)) {
				outlookCalendarTile = true;

			} else if('googleDrive'.equalsIgnoreCase(tileWrapperObj.variant) && 
					'recent_and_starred'.equalsIgnoreCase(tileWrapperObj.options.type)) {
				googleDriveTile = true;
				TileDataWrapper.FileDataGoogleDrive fileDataGoogleDriveObj = tileServiceObj.getStarredAndRecentGoogleDriveFiles(siteId);
				response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileDataGoogleDriveObj);	 
			
			} else if('new_hires'.equalsIgnoreCase(tileWrapperObj.variant) && 
					'people'.equalsIgnoreCase(tileWrapperObj.type)) {
				newHireTile = true;
				TileDataWrapper.TileDataSettings tiledataSettings = new TileDataWrapper.TileDataSettings();
				tiledataSettings.hireDaysThreshold = tileWrapperObj.options.hireDaysThreshold;
				TileDataWrapper.LatestHiresData latestHiresDataObj = tileServiceObj.getLatestHires(siteId, segmentId, null, tiledataSettings);
				response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, latestHiresDataObj);	 

			} else if(!'site'.equalsIgnoreCase(dashboardId) &&
				'video'.equalsIgnoreCase(tileWrapperObj.variant) && 
				'media'.equalsIgnoreCase(tileWrapperObj.type) && 
				tileWrapperObj.options.videoFile !=null) {
				tileServiceObj.createVideoFileRecord(tileWrapperObj.options.videoFile); 
			} else if(('home'.equalsIgnoreCase(dashboardId) || 'home-default'.equalsIgnoreCase(dashboardId)) &&
				'latest_popular'.equalsIgnoreCase(tileWrapperObj.variant) && 'all'.equalsIgnoreCase(tileWrapperObj.options.type)
				&& String.isBlank(tileWrapperObj.options.siteId) && SimpplrContext.aiContentRecommendationEnabled ){	
				//Show Recommended contents only if AI Content Recommendation Enabled
				recommendedTabInLatestPopularTile = true;
				listOfAIRecommendedItems = ContentDataProvider.getAIRecommendedContentTileData(UserContext.peopleId, CONTENT_TILE_ITEM_LIMIT);
			} else if('content_onboarding'.equalsIgnoreCase(tileWrapperObj.variant) && 
					'content'.equalsIgnoreCase(tileWrapperObj.type)) {
				if (SimpplrContext.isFeatureContentOnboardingEnabled) {
					onboardingTile = true;
					TileDataWrapper.TileDataSettings tiledataSettings = new TileDataWrapper.TileDataSettings();
					tiledataSettings.layout = tileWrapperObj.options.layout;
					TileDataWrapper.onboardingTileData onboardingTileDataObj = getOnboardingContentsTileData(siteId, dashboardId, null, tiledataSettings);
					if('home'.equalsIgnoreCase(dashboardId)){
						if(!SimpplrContext.isFeatureEnabled('Full_External_Search')){
							String query = 'SELECT Id, Disable_Onboarding_Home_Tile__c FROM People_Preference__c WHERE Disable_Onboarding_Home_Tile__c = true AND Is_Deleted__c = false AND People__r.Joining_Date__c = LAST_N_DAYS:60 AND People__r.Is_Deleted__c = false';
							List<People_Preference__c> peoplePrefList = Database.query(query);
							if(peoplePrefList.size()>0){
								for(People_Preference__c obj : peoplePrefList){
									obj.Disable_Onboarding_Home_Tile__c= false;
								}
								SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
								SIMPESAPI.accessController().updateAsUser(new Map<id,People_Preference__c>(peoplePrefList),new List<Schema.SObjectField>{People_Preference__c.Disable_Onboarding_Home_Tile__c});
							}
						} else { 
							List<People_Preference__c> peoplePrefList = [SELECT Id, People__r.Joining_Date__c, Disable_Onboarding_Home_Tile__c FROM People_Preference__c WHERE Disable_Onboarding_Home_Tile__c = true AND Is_Deleted__c = false AND People__r.Is_Deleted__c = false WITH SECURITY_ENFORCED];
							List<People_Preference__c> newpeoplePrefList = new List<People_Preference__c>();
							if(peoplePrefList.size()>0){
								for(People_Preference__c obj : peoplePrefList){
									if(obj.People__r.Joining_Date__c!= null && obj.People__r.Joining_Date__c.daysBetween(Date.today())<=59) {
										obj.Disable_Onboarding_Home_Tile__c= false;
										newpeoplePrefList.add(obj);
									}
								}
								if(newpeoplePrefList.size()>0){
									SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
									SIMPESAPI.accessController().updateAsUser(new Map<id,People_Preference__c>(newpeoplePrefList),new List<Schema.SObjectField>{People_Preference__c.Disable_Onboarding_Home_Tile__c});
								}
							}
						}
					}
					response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, onboardingTileDataObj);	
				}
			}

			if('home'.equalsIgnoreCase(dashboardId)) {	
				if (ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
					addedTileList = tileServiceObj.addTileOnUserDashboard(tileWrapperObj);
					if(tileWrapperObj.pushToAllHomeDashboards == true){
						BatchInsertTilesConfig job = new BatchInsertTilesConfig(addedTileList[0].id);
						Database.executeBatch(job,2000);
					}
					
				} else if (SimpplrContext.isSegmentsEnabled) {
					addedTileList = tileServiceObj.addTileOnSegmentDashboard(segmentId, tileWrapperObj);
					
				} else {
					addedTileList = tileServiceObj.addTileOnAppHomeDashboard(tileWrapperObj);
					
				}
			} else if('home-default'.equalsIgnoreCase(dashboardId)){
				addedTileList = tileServiceObj.addTileOnHomeDefaultDashboard(segmentId, tileWrapperObj);

			} else if('site'.equalsIgnoreCase(dashboardId)){
				addedTileList = tileServiceObj.addTileOnSiteDashboard(siteId, tileWrapperObj);
				
			}

			//Add Tile Id in file__c for native videos
			if('video'.equalsIgnoreCase(tileWrapperObj.variant) && 
				'media'.equalsIgnoreCase(tileWrapperObj.type) && 
				tileWrapperObj.options.videoFile !=null && 'native_video'.equalsIgnoreCase(tileWrapperObj.options.videoFile.provider)) {
				tileServiceObj.updateVideoFileRecord(tileWrapperObj.options.videoFile.externalFileId, addedTileList[0].id); 
			}

			if(googleCalendarTile) {
				TileDataWrapper.GoogleCalendarData calendarData = (TileDataWrapper.GoogleCalendarData) response.result;
				calendarData.id = addedTileList[0].Id;
				response.result = calendarData;

			} else if(outlookCalendarTile) {
				TileDataWrapper.OutlookCalendarData outlookCalendarData = new TileDataWrapper.OutlookCalendarData();
				outlookCalendarData.options.outlookCalendar = tileWrapperObj.options.outlookCalendar;
				outlookCalendarData.id = addedTileList[0].id;
				outlookCalendarData.options.siteFilter = tileWrapperObj.options.siteFilter;
				outlookCalendarData.options.type = tileWrapperObj.options.type;
				response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, outlookCalendarData);	 

			} else if(googleDriveTile) {
				TileDataWrapper.FileDataGoogleDrive fileDataGoogleDriveObj = (TileDataWrapper.FileDataGoogleDrive) response.result;
				fileDataGoogleDriveObj.id = addedTileList[0].Id;
				response.result = fileDataGoogleDriveObj;
			
			} else if(newHireTile) {
				TileDataWrapper.LatestHiresData latestHiresData = (TileDataWrapper.LatestHiresData) response.result;
				latestHiresData.id = addedTileList[0].Id;
				latestHiresData.options = tileWrapperObj.options;
				response.result = latestHiresData;

			} else if(recommendedTabInLatestPopularTile){
				TileDataWrapper.TileDataSettings tiledataSettings;
				tiledataSettings = (TileDataWrapper.TileDataSettings)JSON.deserialize(addedTileList[0].data__c,TileDataWrapper.TileDataSettings.class);
				response = getLatestPopularContentTileData(dashboardId, siteId, addedTileList[0].Id, tiledataSettings);

			} else if(onboardingTile) {
				TileDataWrapper.onboardingTileData onboardingTileDataObj = (TileDataWrapper.onboardingTileData) response.result;
				onboardingTileDataObj.id = addedTileList[0].Id;
				onboardingTileDataObj.options = tileWrapperObj.options;
				response.result = onboardingTileDataObj;

			} else {
				response = getTileData(dashboardId, siteId, segmentId, addedTileList[0].Id); 
			}
		} catch(exception e){
			logger.logError('TileDataServer.addTile()-----Exception occured----',e);
			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	  }
	  return response;
	}

	private ResponseWrapper editTile(String segmentId, String dashboardId, String siteId, String tileId, String tile){
			TileDataWrapper.AddTile tileWrapperObj = (TileDataWrapper.AddTile)JSON.deserialize(tile, TileDataWrapper.AddTile.class);
			Boolean googleCalendarTile = false;
			Boolean outlookCalendarTile = false;
			Boolean googleDriveTile = false;
			if('latest_popular'.equalsIgnoreCase(tileWrapperObj.variant) && 
				'googleCalendar'.equalsIgnoreCase(tileWrapperObj.options.siteFilter)) {
				googleCalendarTile = true;
				response = getGoogleCalendarTileData(tileWrapperObj.options.calendar,tileWrapperObj.options.siteFilter,tileWrapperObj.options.type);
				tileServiceObj.editTile(segmentId, dashboardId, siteId, tileId, tileWrapperObj);
				
			} else if('latest_popular'.equalsIgnoreCase(tileWrapperObj.variant) &&
				IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(tileWrapperObj.options.siteFilter)) {
				outlookCalendarTile = true;
				tileServiceObj.editTile(segmentId, dashboardId, siteId, tileId, tileWrapperObj);
				TileDataWrapper.OutlookCalendarData outlookCalendarData = new TileDataWrapper.OutlookCalendarData();
				outlookCalendarData.options.outlookCalendar = tileWrapperObj.options.outlookCalendar;
				outlookCalendarData.options.siteFilter = tileWrapperObj.options.siteFilter;
				outlookCalendarData.options.type = tileWrapperObj.options.type;
				response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, outlookCalendarData);	 				
				
			} else if('googleDrive'.equalsIgnoreCase(tileWrapperObj.variant) && 
					'recent_and_starred'.equalsIgnoreCase(tileWrapperObj.options.type)) {
				googleDriveTile = true;
				TileDataWrapper.FileDataGoogleDrive fileDataGoogleDriveObj = tileServiceObj.getStarredAndRecentGoogleDriveFiles(siteId);
				response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileDataGoogleDriveObj);	 
				tileServiceObj.editTile(segmentId, dashboardId, siteId, tileId, tileWrapperObj);

			} else if('people'.equalsIgnoreCase(tileWrapperObj.type) && 'new_hires'.equalsIgnoreCase(tileWrapperObj.variant)) {
				TileDataWrapper.TileDataSettings tiledataSettings = new TileDataWrapper.TileDataSettings();
				tiledataSettings.hireDaysThreshold = tileWrapperObj.options.hireDaysThreshold;
				response = getLatestHires(siteId, segmentId, tileId, tiledataSettings);
				tileServiceObj.editTile(segmentId, dashboardId, siteId, tileId, tileWrapperObj);
			} else if('video'.equalsIgnoreCase(tileWrapperObj.variant) && 
				'media'.equalsIgnoreCase(tileWrapperObj.type) && 
				tileWrapperObj.options.videoFile !=null && 'native_video'.equalsIgnoreCase(tileWrapperObj.options.videoFile.provider)) {

				tileServiceObj.editTile(segmentId, dashboardId, siteId, tileId, tileWrapperObj);
				tileServiceObj.updateVideoFileRecord(tileWrapperObj.options.videoFile.externalFileId, tileId); 
				response = getTileData(dashboardId, siteId, segmentId, tileId);

			} else if(('home'.equalsIgnoreCase(dashboardId) || 'home-default'.equalsIgnoreCase(dashboardId)) &&
				'latest_popular'.equalsIgnoreCase(tileWrapperObj.variant) && 'all'.equalsIgnoreCase(tileWrapperObj.options.type)
				&& String.isBlank(tileWrapperObj.options.siteId) && SimpplrContext.aiContentRecommendationEnabled ){	
					
				//Show Recommended contents only if AI Content Recommendation Enabled
				listOfAIRecommendedItems = ContentDataProvider.getAIRecommendedContentTileData(UserContext.peopleId, CONTENT_TILE_ITEM_LIMIT);
				tileServiceObj.editTile(segmentId, dashboardId, siteId, tileId, tileWrapperObj);
				TileDataWrapper.TileDataSettings tiledataSettings;
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', tileId);
				String query = 'SELECT Type__c, Variant__c, data__c FROM tiles_config__c WHERE id =:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Tiles_Config__c> tilesConfigList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
				tiledataSettings = (TileDataWrapper.TileDataSettings)JSON.deserialize(tilesConfigList[0].data__c,TileDataWrapper.TileDataSettings.class);
				response = getLatestPopularContentTileData(dashboardId, siteId, tileId, tiledataSettings);
			} else if('content'.equalsIgnoreCase(tileWrapperObj.type) && 'content_onboarding'.equalsIgnoreCase(tileWrapperObj.variant)) {
				TileDataWrapper.TileDataSettings tiledataSettings = new TileDataWrapper.TileDataSettings();
				tileServiceObj.editTile(segmentId, dashboardId, siteId, tileId, tileWrapperObj);
				response = getTileData(dashboardId, siteId, segmentId, tileId);
			} else {
				tileServiceObj.editTile(segmentId, dashboardId, siteId, tileId, tileWrapperObj);
				response = getTileData(dashboardId, siteId, segmentId, tileId);
			}	
    		return response;
    }
    
    private ResponseWrapper getTileData(String dashboardId, String siteId, String segmentId, String tileId) {


		String tileType = '';
		String variant = '';
		TileDataWrapper.TileDataSettings tiledataSettings;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', tileId);
		String query = 'SELECT Type__c, Variant__c, data__c, CreatedDate FROM tiles_config__c WHERE id =:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Tiles_Config__c> tilesConfigList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	
		if (!tilesConfigList.isEmpty()) {
    			tileType = tilesConfigList[0].Type__c;
 			variant = tilesConfigList[0].Variant__c;
		}

  		if (String.isBlank(tileType)) {
  			response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
  		}
		tiledataSettings = (TileDataWrapper.TileDataSettings)JSON.deserialize(tilesConfigList[0].data__c,TileDataWrapper.TileDataSettings.class);
		tiledataSettings.addedAt = tilesConfigList[0].CreatedDate == null ? '':Utility.dateToDisplayString(tilesConfigList[0].CreatedDate,'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		
		if (tileType.equalsIgnoreCase('people')) {
			if (variant.equalsIgnoreCase('new_hires')) {
        	    response = getLatestHires(siteId, segmentId, tileId, tiledataSettings);                    	
			}else if (variant.equalsIgnoreCase('custom') || variant.equalsIgnoreCase('site_members') || variant.equalsIgnoreCase('site_managers') ) {
				response = getPeopleListData(siteId, tileId, variant, tiledataSettings);		
			} else if (variant.equalsIgnoreCase('celebrations')) {
				response = getCelebrationPeopleData(siteId, tileId, variant, tiledataSettings);
			}
			canCache = false;
		} else if(tileType.equalsIgnoreCase('content')) {	
			if('latest_popular'.equalsIgnoreCase(variant)) {

				if('googleCalendar'.equalsIgnoreCase(tiledataSettings.siteFilter)) {
					response = getGoogleCalendarTileData(tiledataSettings.calendar,tiledataSettings.siteFilter,tiledataSettings.type);
					canCache = false;
				} else if(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(tiledataSettings.siteFilter)) {
					TileDataWrapper.OutlookCalendarData outlookCalendarData = new TileDataWrapper.OutlookCalendarData();
					outlookCalendarData.options.outlookCalendar = tiledataSettings.outlookCalendar;
					outlookCalendarData.options.siteFilter = tiledataSettings.siteFilter;
					outlookCalendarData.options.type =  tiledataSettings.type;
					outlookCalendarData.id = tileId;
					response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, outlookCalendarData);					
					canCache = false;
				} else if(('home'.equalsIgnoreCase(dashboardId) || 'home-default'.equalsIgnoreCase(dashboardId)) && 'all'.equalsIgnoreCase(tiledataSettings.type)
						&& String.isBlank(tiledataSettings.siteId) && SimpplrContext.aiContentRecommendationEnabled ){	
					//Show Recommended contents only if AI Content Recommendation Enabled 
					listOfAIRecommendedItems = ContentDataProvider.getAIRecommendedContentTileData(UserContext.peopleId, CONTENT_TILE_ITEM_LIMIT);
					response = getLatestPopularContentTileData(dashboardId, siteId,tileId, tiledataSettings);
				} else {
					response = getLatestPopularContentTileData(dashboardId, siteId,tileId, tiledataSettings);
				}
			} else if('from_category'.equalsIgnoreCase(variant)){
	                response = getPagesWidgetData(dashboardId, siteId, tileId,variant, tiledataSettings);
					canCache = false;
			} else if('custom'.equalsIgnoreCase(variant)){
	                response = getCustomTilesData(dashboardId, siteId, tileId, variant, tiledataSettings);         
			} else if ('content_onboarding'.equalsIgnoreCase(variant)) {
				if (UserContext.isNewHire && dashboardId.equalsIgnoreCase('home')) {
					TileDataWrapper.onboardingTileData onboardingTileDataObj = getOnboardingContentsTileData(siteId, dashboardId, tileId, tiledataSettings);
					response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, onboardingTileDataObj);	 
				} else if (dashboardId.equalsIgnoreCase('site')) {
					TileDataWrapper.onboardingTileData onboardingTileDataObj = getOnboardingContentsTileData(siteId, dashboardId, tileId, tiledataSettings);
					response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, onboardingTileDataObj);
				} else if(!UserContext.isNewHire && dashboardId.equalsIgnoreCase('home')) {
					TileDataWrapper.onboardingTileData onboardingTileDataObj = new TileDataWrapper.onboardingTileData();
					onboardingTileDataObj.options.addedAt = tiledataSettings.addedAt;
					response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, onboardingTileDataObj);
				}       
				canCache = false;        
			}	
    	} else if(tileType.equalsIgnoreCase('site_about')){
            response = getAboutDetail(siteId,tileId);
        } else if(tileType.equalsIgnoreCase('site_info')){
            response = getSiteInformationTileData(siteId,tileId);
    	} else if(tileType.equalsIgnoreCase('sites')){
            response = getMySites(siteId, tileId,variant, tiledataSettings);
			canCache = false;
    	} else if(tileType.equalsIgnoreCase('twitter')){
            response = getTwitterDetail(siteId,tileId, tiledataSettings);

    	}  else if(tileType.equalsIgnoreCase('facebook')){
            response = getFacebookDetail(siteId,tileId, tiledataSettings);

    	} else if(tileType.equalsIgnoreCase('html')){
    		if('iframe'.equalsIgnoreCase(variant)) {
            response = getHTMLWidgetOne(siteId,tileId, tiledataSettings);
    		} else if('text'.equalsIgnoreCase(variant)) {  
            response = getTextWidgetData(siteId,tileId, tiledataSettings);
    		}
    	} else if(tileType.equalsIgnoreCase('salesforce_apps')){
            response = getAppData(siteId,tileId, tiledataSettings);
			canCache = false;
    	} else if(tileType.equalsIgnoreCase('rss')){
            response = getRSSData(siteId,tileId, tiledataSettings);
    	} else if(tileType.equalsIgnoreCase('files')){
            response = getFileData(siteId,tileId,variant, tiledataSettings);
			canCache = false;    
    	} else if(tileType.equalsIgnoreCase('links')){
            response = getHelpLinkData(siteId,tileId, tiledataSettings);
    	} else if(tileType.equalsIgnoreCase('countdown')){
            response = getCountdownData(siteId,tileId, tiledataSettings);
			canCache = false;
    	} else if(tileType.equalsIgnoreCase('page_categories')){
				response = getPageCategoriesTileData(siteId,tileId, tiledataSettings);

    	} else if(tileType.equalsIgnoreCase('site_categories')){
				response = getSiteCategoriesTileData(siteId,tileId, tiledataSettings);
    	} else if(tileType.equalsIgnoreCase('media')){
    		if('image'.equalsIgnoreCase(variant)) {
            response = getImageData(siteId,tileId, tiledataSettings);
    		} else if('video'.equalsIgnoreCase(variant)) {  
            response = getVideoData(siteId,tileId, tiledataSettings);
    		}
    	} else if(tileType.equalsIgnoreCase('campaigns')){
    		if('latest_popular'.equalsIgnoreCase(variant)) {
				response = getLatestPopularCampaignTileData(dashboardId, siteId,tileId, tiledataSettings);
			} else if('custom'.equalsIgnoreCase(variant)){
				response = getCampaignTilesData(tileId,tiledataSettings);
    		}
    		
    	} else if(tileType.contains('recognition')){
			TileDataWrapper.TilesOrder tile = new TileDataWrapper.TilesOrder();
			tile.type = tileType;
			tile.variant = variant;
			tile.id = tileId;
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, tile);
		} else {
    		response = buildResponseWrapper(RESPONSE_STATUS_ERROR, 'Invalid tile type', null);
    	}
	    return response;
    }	
    
    private ResponseWrapper getCelebrationPeopleData (String siteId, String tileId, String variant, TileDataWrapper.TileDataSettings tiledataSettings) {
    	logger.logDebug('TileDataServer.getCelebrationPeopleData()----siteId----' + 
    			siteId + '----tileId----' + tileId + '----variant----' + variant);
        ResponseWrapper localResult = null;
        TileDataWrapper.PeopleData peopleDataObj = new TileDataWrapper.PeopleData();
       
        try {
        	peopleDataObj = tileServiceObj.getCelebrationPeopleData(siteId, tileId, variant, tiledataSettings);
        	peopleDataObj.id = tileId;
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 
	        		'Celebrations detail response successful', peopleDataObj);	        
        
        } catch (Exception e) {
        	logger.logError('Could not retrieve Celebrations Data',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        logger.logDebug('TileDataServer.getCelebrationPeopleData()----localResult----' + localResult);
        return localResult;
    }
    
    private ResponseWrapper createUserDefaultTiles(){
    	logger.logDebug('TileDataServer.createUserDefaultTiles()' );
        ResponseWrapper localResult = null;
        TileDataWrapper.TileOrderData tileOrderDataObj = new TileDataWrapper.TileOrderData();
       
        try { 
        	tileOrderDataObj = tileServiceObj.createUserDefaultTiles();     	
	        localResult = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Response successful', tileOrderDataObj);        
       
        } catch(Exception e) {
        	logger.logError('Could not retrieve tiles order',e);
        	localResult = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        logger.logDebug('TileDataServer.createUserDefaultTiles()----localResult----'+localResult);
        return localResult;
    }
    
	private Boolean checkTileModerationAccess (String dashboardId, String segmentId, String siteId, String tileId) { 
		system.debug('tileId-checkTileModerationAccess-1566--'+ readParam('tileId'));
		Boolean hasTileModerationAccess = false;
		if(String.isNotBlank(siteId)) {
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1569 ' );
			if(SiteContext.isCurrentUserSiteManager || (UserContext.isUserAppModerator && SiteContext.isPublicSite)) {
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1571 ' );

				hasTileModerationAccess = true;
			} else if(SiteContext.isUnlistedSite == false && UserContext.hasModifyAllDataPermission) {
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1575 ' );
				hasTileModerationAccess = true;
			} else if(SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission) {
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1578 ' );
				hasTileModerationAccess = true;
			}
		} else if ('home'.equalsIgnoreCase(dashboardId) && ServiceConstants.DASHBOARD_OWNER_USER.equalsIgnoreCase(SimpplrContext.AppDashboardMode)) {
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1582 ' );
    			hasTileModerationAccess = true;
    			
    		} else if (UserContext.isUserAppModerator || (UserContext.canControlHomeDashboard && (SimpplrContext.isSegmentsEnabled == false))) {
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1587 ' );

    			hasTileModerationAccess = true;
    			
    		} else if (String.isNotBlank(segmentId) && segmentId.equalsIgnoreCase(UserContext.segmentId) && UserContext.isSegmentManager) {
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1592 ' );

    			hasTileModerationAccess = true;
    			
    		} else if ('home'.equalsIgnoreCase(dashboardId) && ServiceConstants.DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.AppDashboardMode) &&
				!UserContext.isUserAppModerator && !UserContext.isNewHire) {
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1597 ' );

				Map<String, Object> tileSoqlParamMap = new Map<String, Object>();
				tileSoqlParamMap.put('soqlParam1', tileId);
				String queryStr = 'select Id, Is_Deleted__c, Variant__c from Tiles_Config__c where id = :soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Tiles_Config__c> listOfTileObj = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(queryStr, tileSoqlParamMap);
				if ('content_onboarding'.equalsIgnoreCase(listOfTileObj[0].Variant__c)) {
				system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1605 ' );

					hasTileModerationAccess = true;
				}
			}
			system.debug('??????>>>> TDS >>>>checkTileModerationAccess>> 1610 '+ hasTileModerationAccess);

		return hasTileModerationAccess;
	}

	private TileDataWrapper.onboardingTileData getOnboardingContentsTileData(String siteId, String dashboardId, String tileId, TileDataWrapper.TileDataSettings tiledataSettings) {
		TileDataWrapper.onboardingTileData onboardingTileDataObj = new TileDataWrapper.onboardingTileData();
		onboardingTileDataObj.options.layout = tiledataSettings.layout;
		onboardingTileDataObj.options.addedAt = tiledataSettings.addedAt;
		onboardingTileDataObj.id = tileId;
		AllContentDataServer AllContentDataServerObj = new AllContentDataServer();
		if ('home'.equalsIgnoreCase(dashboardId)) {
			String dataString = '{"sortBy":"site"}';
			response = AllContentDataServerObj.getMyOnboardingContents(dataString);
			map<String,Object> resultMap = (map<String,Object>) response.result;
			List<Object> listOfItems = (List<Object>) resultMap.get('listOfItems');
			for (Integer i=0; i<listOfItems.size(); i++){
				map<String,Object> listMap = (map<String,Object>) listOfItems[i];
				Object data = (Object) listMap.get('data');
				onboardingTileDataObj.listOfItems.add(data);
			}
				
		} else if ('site'.equalsIgnoreCase(dashboardId)) {
			String dataString = '{"siteId":"'+ siteId +'"}';
			response = AllContentDataServerObj.getOnboardingContents(dataString);
			map<String,Object> resultMap = (map<String,Object>) response.result;
			List<Object> listOfItems = (List<Object>) resultMap.get('listOfItems');
			for (Integer i=0; i<listOfItems.size(); i++){
				onboardingTileDataObj.listOfItems.add(listOfItems[i]);
			}
		}
		return onboardingTileDataObj;
	}
}