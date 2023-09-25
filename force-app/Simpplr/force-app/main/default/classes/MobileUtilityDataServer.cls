public with sharing class MobileUtilityDataServer extends DataServer{
	@TestVisible private final String REQUEST_PARAM_DATA = 'data';
    @TestVisible private final String ACTION_GET_ORG_CHANGE_INFO = 'getOrgChangeInfo';

    @TestVisible private final String ACTION_GET_PEOPLE_CHANGE_INFO = 'getPeopleChangeInfo';
    
    @TestVisible private final String ACTION_GET_APP_CONFIG_CHANGE_INFO = 'getAppConfigChangeInfo';

    @TestVisible private final String ACTION_VALUE_GET_ALL_PEOPLE = 'getAllPeople';
    @TestVisible private final String ACTION_VALUE_GET_CACHE_SITE_BY_ID = 'getCacheSiteById';

    @TestVisible private final String ACTION_GET_BASIC_ORG_INFO = 'getBasicOrgInfo';
    @TestVisible private final String ACTION_GET_SALESFORCE_BASE_URL = 'getSalesforceBaseUrl';
    @TestVisible private final String ACTION_MARK_NOTIFICATION_READ = 'markNotificationRead';
    @TestVisible private final String ACTION_GET_POPULAR_SEARCH_LIST = 'getPopularSearchList';
    @TestVisible private final String ACTION_VALUE_GET_DASHBOARD_TILES = 'getDashboardTiles';
    @TestVisible private String loggedInPeopleId = UserContext.peopleId;
    
    public MobileUtilityDataServer() {
        
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
        try{
        	logger.logDebug('MobileUtilityDataServer.handleRequest()----entered handleRequest----');
			String action = readParam(REQUEST_PARAM_ACTION);
			String peoplePollTimeStamp = readParam('peoplePollTimeStamp');
			String sitePollTimeStamp = readParam('sitePollTimeStamp');
			String contentPollTimeStamp = readParam('contentPollTimeStamp');
			String appConfigPollTimeStamp = readParam('appConfigPollTimeStamp');
            String data = readParam(REQUEST_PARAM_DATA);	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            } else {
            	if(ACTION_GET_SALESFORCE_BASE_URL.equalsIgnoreCase(action)){
            		response = getSalesforceBaseUrl();
            	} else if(ACTION_GET_BASIC_ORG_INFO.equalsIgnoreCase(action)){
            		response = getBasicOrgInfo();
            	} else if(ACTION_GET_ORG_CHANGE_INFO.equalsIgnoreCase(action)){
            		response = getOrgChangeInfo(peoplePollTimeStamp, sitePollTimeStamp, contentPollTimeStamp, appConfigPollTimeStamp);
            	} else if(ACTION_GET_PEOPLE_CHANGE_INFO.equalsIgnoreCase(action)){
            		response = getPeopleChangeInfo(data);
            	} else if(ACTION_GET_APP_CONFIG_CHANGE_INFO.equalsIgnoreCase(action)){
            		response = getAppConfigChangeInfo();
            	} else if(ACTION_VALUE_GET_ALL_PEOPLE.equalsIgnoreCase(action)){
            		response = getAllPeopleForCaching(data);
            } else if(ACTION_VALUE_GET_CACHE_SITE_BY_ID.equalsIgnoreCase(action)){
                response = getCacheSiteById();
            } else if(ACTION_GET_POPULAR_SEARCH_LIST.equalsIgnoreCase(action)){
                response = getPopularSearchList();
            } else if(ACTION_MARK_NOTIFICATION_READ.equalsIgnoreCase(action)){
            	String notiId  = readParam('notificationId');
                response = markNotificationStatusAsRead(notiId);
            } else if(ACTION_VALUE_GET_DASHBOARD_TILES.equalsIgnoreCase(action)){
                response = getDashboardTiles();
            } else{
            	throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            	}
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    

	private ResponseWrapper getDashboardTiles() {
		logger.logDebug('MobileUtilityDataServer.getDashboardTiles()----');
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{
			Map<String,Object> responseMap = new Map<String,Object>();
			CarouselDataServer carouselDSObj = new CarouselDataServer();
			AllContentDataServer allContentDSObj = new AllContentDataServer();
			PeopleContentProvider providerObj = new PeopleContentProvider();
			List<PeopleListingWrapper> newHirePeopleList = new List<PeopleListingWrapper>();
			List<PeopleListingWrapper> celebrationPeopleList = new List<PeopleListingWrapper>();
            
			Map<String, String> requestMap = new Map<String, String>();
			String siteId = readParam('siteId');
			SiteContext.siteId = siteId;
			String segmentId;
			if(String.isBlank(siteId) && SimpplrContext.isSegmentsEnabled){
				segmentId = UserContext.segmentId;
			}
			ResponseWrapper responseWrap = carouselDSObj.carouselDataForDashboard(siteId, segmentId, true);	
			responseMap.put('carouselData',responseWrap.result);
		
			requestMap.put('siteId', siteId);
			requestMap.put('size', '12');
			responseWrap = allContentDSObj.getLatestContents(JSON.serialize(requestMap));
			Map<String,Object> responseWrapMap =  (Map<String, Object>) responseWrap.result;
			responseMap.put('latestContentList', responseWrapMap.get('listOfItems'));

			responseWrap = allContentDSObj.getPopularContents(JSON.serialize(requestMap));
			responseWrapMap = (Map<String, Object>) responseWrap.result;
			responseMap.put('popularContentList', responseWrapMap.get('listOfItems'));
			responseMap.put('recommendedContentList', responseWrapMap.get('aiRecommendedListOfItems'));
			
			requestMap.put('type', 'event');
			requestMap.put('maxAllowedEventEndDateTime', String.valueOf(System.now().addDays(7)));
			responseWrap = allContentDSObj.getLatestContents(JSON.serialize(requestMap));
			responseWrapMap =  (Map<String, Object>) responseWrap.result;
			responseMap.put('upcommingEventList', responseWrapMap.get('listOfItems'));
			
			requestMap.put('filter', 'unread');
			responseWrap = allContentDSObj.getContentMustReadForUser(JSON.serialize(requestMap));
			responseWrapMap = (Map<String, Object>) responseWrap.result;
			responseMap.put('mustReadContentList', responseWrapMap.get('listOfItems'));	
			
			if(UserContext.isNewHire) {
				responseWrap = allContentDSObj.getFeedOnboardingContents(JSON.serialize(requestMap));
				responseWrapMap = (Map<String, Object>) responseWrap.result;
				responseMap.put('OnboardingContentList', responseWrapMap.get('listOfItems'));
			} else {
				responseMap.put('OnboardingContentList',  new List<ContentWrapper>());
			}
			
			if(SimpplrContext.isSegmentsEnabled) {
				segmentId = UserContext.segmentId;
			}
			
			newHirePeopleList = providerObj.getNewHiresForPeoplePosts(segmentId, true);
			celebrationPeopleList = providerObj.getCelebrationsForPeoplePosts(segmentId, true);
			responseMap.put('newHirePeopleList', newHirePeopleList);
			responseMap.put('celebrationPeopleList', celebrationPeopleList);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseMap);
		} catch(Exception e){
			logger.logError('MobileUtilityDataServer.getDashboardTiles()----Could not retrieve data', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		logger.logDebug('MobileUtilityDataServer.getDashboardTiles()--------responseWrapperObj----'+responseWrapperObj);
		return responseWrapperObj;

	}
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileUtilityDataServer&action=getOrgChangeInfo getOrgChangeInfo
	 * @apiVersion 1.0.0
	 * @apiGroup MobileUtilityDataServer
	 * @apiName getOrgChangeInfo
	 *
	 * @apiParam (Query Parameter) {String} action getOrgChangeInfo
	 * @apiParam (Query Parameter) {Number} pollTimeStamp poll time in milliseconds
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for polling to record any changes in the org from pollTimeStamp to current time
	 * @apiSuccess {Number} pollTimeStamp Time in milliseconds
	 * @apiSuccess {Boolean} hasPeopleUpdated True, if any of the people record has been updated or added
	 * @apiSuccess {Boolean} hasContentUpdated True, if any of the content record has been updated or added
	 * @apiSuccess {Boolean} hasSiteUpdated True, if any of the site record has been updated or added
	 * @apiSuccess {Boolean} hasAppConfigUpdated True, if app config record has been updated or added
	 * @apiSuccess {Boolean} isSysAdmin True, if logged in user is System Administrator
	 * @apiSuccess {Boolean} isAppManager True, if logged in user is App Manager
	 * @apiSuccess {Boolean} isUnlistedManager True, if logged in user has manage Unlisted site permission
	 * @apiSuccess {String} packageVersion Installed app package version
	 * @apiSuccess {Number} notificationCount True, Total notification count
	 * @apiError SimpplrException Simpplr Exception
	 */
	 
    @testVisible 
    private ResponseWrapper getOrgChangeInfo(String peoplePollTimeStamp, String sitePollTimeStamp, String contentPollTimeStamp, String appConfigPollTimeStamp){
    	logger.logDebug('MobileUtilityDataServer.getOrgChangeInfo()----');
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        		DateTime peoplePollTimeGMT;
	        	DateTime sitePollTimeGMT;
	        	DateTime contentPollTimeGMT;
	        	DateTime appConfigPollTimeGMT;
	        	TimeZone tz = UserInfo.getTimeZone();
	        	List<Bookmark__c> favUpdateList;
	        Map<String,Object> basicOrgInfoMap = new Map<String,Object>();
	        basicOrgInfoMap.put('pollTimeStamp',(DateTime.now()).getTime()+'');
        	if(String.isNotBlank(peoplePollTimeStamp) && String.isNotBlank(sitePollTimeStamp) && String.isNotBlank(contentPollTimeStamp) && String.isNotBlank(appConfigPollTimeStamp)){
	        
            sitePollTimeGMT = DateTime.newInstance(long.valueOf(sitePollTimeStamp));
            contentPollTimeGMT = DateTime.newInstance(long.valueOf(contentPollTimeStamp));
                
	        	favUpdateList = getFavoritedList(peoplepollTimeGMT, sitePollTimeGMT, contentPollTimeGMT);
	        
	        
        	} else if(String.isNotBlank(peoplePollTimeStamp) && String.isNotBlank(appConfigPollTimeStamp)){
			
	        	favUpdateList = getFavoritedList(peoplepollTimeGMT, null, null);
        	
        	} else {
        		throw new SimpplrException('pollTimeStamp params missing');
        	}
        		
			peoplePollTimeGMT = DateTime.newInstance(long.valueOf(peoplePollTimeStamp));
            appConfigPollTimeGMT = DateTime.newInstance(long.valueOf(appConfigPollTimeStamp));
			basicOrgInfoMap.put('hasPeopleUpdated',(new MobilePeopleDao()).getPeopleChangeFlag(peoplePollTimeGMT, favUpdateList));
			basicOrgInfoMap.put('hasAppConfigUpdated',getAppConfigChangeFlag(appConfigPollTimeGMT));
			basicOrgInfoMap.put('isSegmentsEnabled',SimpplrContext.isSegmentsEnabled);
			basicOrgInfoMap.put('segmentID',UserContext.segmentId);
			basicOrgInfoMap.put('languageLocaleKey',UserContext.languageLocaleKey);
			basicOrgInfoMap.put('isMaintenanceModeOn',SimpplrContext.isMaintenanceInProgress);
			basicOrgInfoMap.put('isSysAdmin',UserContext.hasModifyAllDataPermission);
			basicOrgInfoMap.put('isAppManager',UserContext.isUserAppModerator);
			basicOrgInfoMap.put('isUnlistedManager',UserContext.hasManageUnlistedSitePermission);
			basicOrgInfoMap.put('userTimeZone',tz.getOffset(system.today()));
			basicOrgInfoMap.put('userTimeZoneName', UserContext.timeZoneLabel);
			basicOrgInfoMap.put('userTimezoneIso',UserInfo.getTimeZone().getId());
			basicOrgInfoMap.put('packageVersion',String.isBlank(SimpplrContext.packageName) ? 'Unmanaged' : Utility.getPackageVersion());
			basicOrgInfoMap.put('releaseVersion', ServiceConstants.RELEASE_VERSION);
			basicOrgInfoMap.put('notificationCount',NotificationDao.getNewNotificationCount());
			basicOrgInfoMap.put('currentGMTTime',Utility.dateTimeStringInGMT(DateTime.now(),'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			basicOrgInfoMap.put('siteMentionEnabled', !SimpplrContext.isMuteContentPostInSiteFeedEnabled);
			if(SimpplrContext.isMaintenanceInProgress &&
			  ('enableSegmentation'.equalsIgnoreCase(SimpplrContext.maintenanceReason) || 'disableSegmentation'.equalsIgnoreCase(SimpplrContext.maintenanceReason))){
	        		basicOrgInfoMap.put('segmentationInProgress',true);
	        	}else {
	        		basicOrgInfoMap.put('segmentationInProgress',false);
	        	}
	        	basicOrgInfoMap.put('hasConnectedBoxAccount', UserContext.isBoxConnected);
	        	basicOrgInfoMap.put('hasConnectedDropboxAccount', hasConnectedDropboxAccount);
				basicOrgInfoMap.put('hasConnectedGoogleDriveAccount', hasConnectedGoogleDriveAccount);
				if(hasConnectedSPAccount) {
					basicOrgInfoMap.put('hasConnectedSharePointAccount', true);
					basicOrgInfoMap.put('isSharePointFullSearchEnabled', EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID
																			.equalsIgnoreCase(SimpplrContext.Integrations.get('sharepoint').Client_id__c));
		
				} else {
					basicOrgInfoMap.put('hasConnectedSharePointAccount', false);
					basicOrgInfoMap.put('isSharePointFullSearchEnabled', false);
		
				}				
	        	basicOrgInfoMap.put('hasConnectedOneDriveAccount', hasConnectedODAccount);
				basicOrgInfoMap.put('hasConnectedAtlassianAccount', SimpplrContext.isAtlassianConnected);
				basicOrgInfoMap.put('confluenceCustomKBName', SimpplrContext.confluenceCustomKBName);
	        	basicOrgInfoMap.put('allowFileUpload', SimpplrContext.allowFileUpload);
				basicOrgInfoMap.put('isContentModerationEnabled', SimpplrContext.isContentModerationEnabled);
				basicOrgInfoMap.put('isCRMEnabled', new FolderDao().isCRMAvailable());
				basicOrgInfoMap.putAll(getSocialAccountsConnectedMap());
				basicOrgInfoMap.put('addOns', getAddOns());
				basicOrgInfoMap.put('isQuestionAnswerEnabled', SimpplrContext.isQuestionAnswerEnabled);
				basicOrgInfoMap.put('isQuestionEnabledForContent', SimpplrContext.isQuestionAnswerEnabled && SimpplrContext.questionChangesForKITA);
	        	basicOrgInfoMap.put('hireDate', UserContext.hireDate);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' Org change info returned successfully!', basicOrgInfoMap);
        }catch(Exception e){
        	logger.logError('MobileUtilityDataServer.getOrgChangeInfo()----Could not retrieve org change info',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileUtilityDataServer.getOrgChangeInfo()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
	}
	
	private Map<String, Object> getSocialAccountsConnectedMap() {
		Map<String, Object> socialAccountsConnectedMap = new Map<String, Object>();
		Boolean hasConnectedLinkedInAccount = false;
		Boolean hasConnectedTwitterAccount = false;  	
		if (SimpplrContext.isEmployeeAdvocacyEnabled) {
			Boolean isFacebookEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK);
			Boolean isLinkedinEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN);
			Boolean isTwitterEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_TWITTER);
			IntegrationService integrationServiceObj = new IntegrationService(UserContext.peopleId);
			
			if (isFacebookEnabled) {
				integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK);
				socialAccountsConnectedMap.put('socialCampaignsFacebookAppId', integrationServiceObj.getClientId());
			}
				
			if (isLinkedinEnabled) {
				integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN);
				if (integrationServiceObj.integrator != null && !integrationServiceObj.accessTokenExpired()) {
					hasConnectedLinkedInAccount = true;
				}
			}
			
			if (isTwitterEnabled) {
				integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_TWITTER);
				if (integrationServiceObj.integrator != null && !integrationServiceObj.accessTokenExpired()) {
					hasConnectedTwitterAccount = true;
				}
			}			
		}
		socialAccountsConnectedMap.put('hasConnectedLinkedInAccount', hasConnectedLinkedInAccount);
		socialAccountsConnectedMap.put('hasConnectedTwitterAccount', hasConnectedTwitterAccount);
		return socialAccountsConnectedMap;
	}
    
    @testVisible
    private List<Bookmark__c> getFavoritedList(DateTime peoplePollTimeStamp, DateTime sitePollTimeStamp, DateTime contentPollTimeStamp){
		List<DateTime> dateList = new List<DateTime>{peoplePollTimeStamp};
		
		if(sitePollTimeStamp != null && contentPollTimeStamp != null){
			dateList.add(sitePollTimeStamp);
			dateList.add(contentPollTimeStamp);
			dateList.sort();
		}
		
		DateTime pollTimeStamp = dateList[0];
		Set<String> typeSet = new Set<String>{'Site', 'People','Page','Album','Event','BlogPost'};
    	for(String feature: (SimpplrContext.AllowedFeatures).split(',')){
    		if(!'File'.equalsIgnoreCase(feature)){
    			typeSet.add(feature);
    		}
    	}
		    	
    	List<Bookmark__c> bookMarkList = [select Id, Type__c, LastModifiedDate from Bookmark__c where LastModifiedDate>: pollTimeStamp AND People__c =:UserContext.peopleId AND Type__c IN:typeSet WITH SECURITY_ENFORCED];
    	return bookMarkList;
    }
    /**
	 * @api {post} /apex/DataServerRW?target=MobileUtilityDataServer&action=getPeopleChangeInfo getPeopleChangeInfo
	 * @apiVersion 1.0.0
	 * @apiGroup MobileUtilityDataServer
	 * @apiName getPeopleChangeInfo
	 *
	 * @apiParam (Query Parameter) {String} action getPeopleChangeInfo
	 * @apiParam (Query Parameter) {String} pollTimeStamp Time in millisecond
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting new or updated people records from pollTimeStamp to current time
	 * @apiSuccess {Number} requestTimeStamp Time in milliseconds
	 * @apiSuccess {Object} result {"updateList":List[PeopleCacheWrapper],"deleteList":List[PeopleCacheWrapper]}
	 * @apiUse PeopleCacheWrapper
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getPeopleChangeInfo(String requestData){
    	logger.logDebug('MobileUtilityDataServer.getPeopleChangeInfo()----requestData---'+requestData);
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        if(String.isBlank(readParam('peoplePollTimeStamp')) ) {
    		throw new SimpplrException('pollTimeStamp param missing');
    	}
        try{
	        Map<String, Object> peopleChangeResultMap = new Map<String, Object>();
        	Map<String, Object> resultMap = new Map<String, Object>();
        	resultMap.put('requestTimeStamp',(DateTime.now()).getTime()+'');
        	String pollTimeStamp = readParam('peoplePollTimeStamp');
        	Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
   			Integer size = requestDataMap.get('size') != null ?Integer.valueOf(requestDataMap.get('size')) : 0;
   			Integer offset = requestDataMap.get('offset') != null ?Integer.valueOf(requestDataMap.get('offset')) : 0;
        	if('Now'.equalsIgnorecase(pollTimeStamp)){
        		DateTime pollTimeGMT = DateTime.now();
	        	peopleChangeResultMap = (new MobilePeopleDataProvider()).getUpdatedPeopleMap(pollTimeGMT, offset, size);
	        	resultMap.put('result',peopleChangeResultMap);
        	}else {
	        	DateTime pollTimeGMT = DateTime.newInstance(long.valueOf(pollTimeStamp));
	        	peopleChangeResultMap = (new MobilePeopleDataProvider()).getUpdatedPeopleMap(pollTimeGMT, offset, size);
	        	resultMap.put('result',peopleChangeResultMap);
        	}
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' People change info returned successfully!', resultMap);
        }catch(Exception e){
        	logger.logError('MobileUtilityDataServer.getPeopleChangeInfo()----Could not retrieve people change info',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
        }
        logger.logDebug('MobileUtilityDataServer.getPeopleChangeInfo()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileUtilityDataServer&action=getAppConfigChangeInfo getAppConfigChangeInfo
	 * @apiVersion 1.0.0
	 * @apiGroup MobileUtilityDataServer
	 * @apiName getAppConfigChangeInfo
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting app config record
	 * @apiSuccess {Number} requestTimeStamp Time in milliseconds
	 * @apiSuccess {Object} result {"isTitleDisplayOn":true,"isTimeZoneDisplayOn":true,"isStateDisplayOn":true,"isPhoneDisplayOn":true,"isMobileDisplayOn":true,"isManagerDisplayOn":true,"isLastNameDisplayOn":true,"isJoiningDateDisplayOn":false,"isFirstNameDisplayOn":true,"isExtensionDisplayOn":true,"isDepartmentDisplayOn":true,"isCountryDisplayOn":true,"isCityDisplayOn":true,"isCategoryDisplayOn":false,"isBirthDateDisplayOn":false,"isAboutMeDisplayOn":true,"isStreetDisplayOn":true,"defaultPageSize":16,"isAboutEditible":true,"appName":"Simpplr","isFeedOn":true,"isFileOn":false,"isBlogOn":false,"isEventOn":false,"isAlbumOn":false,"isPageOn":false}
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getAppConfigChangeInfo(){
    	logger.logDebug('MobileUtilityDataServer.getAppCOnfigChangeInfo()----');
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
            Map<String, Object> resultMap = new Map<String, Object>();
        	resultMap.put('requestTimeStamp',(DateTime.now()).getTime()+'');        	
        	resultMap.put('result',getAppConfigData());
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' App config change info returned successfully!', resultMap);
        }catch(Exception e){
        	logger.logError('MobileUtilityDataServer.getAppCOnfigChangeInfo()----Could not retrieve app config change info',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileUtilityDataServer.getAppCOnfigChangeInfo()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileUtilityDataServer&action=getAllPeopleForCaching getAllPeopleForCaching
	 * @apiVersion 1.0.0
	 * @apiGroup MobileUtilityDataServer
	 * @apiName getAllPeopleForCaching
	 *
	 * @apiParam (Query Parameter) {String} action getAllPeopleForCaching
	 * @apiParam (Post Parameter) {String} data {"offset":0,"size":2000}
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting people reocrds from offset and size provided in request data.
	 * @apiSuccess {Number} requestTimeStamp Time in milliseconds
	 * @apiSuccess {List[PeopleCacheWrapper]} result List of people records
	 * @apiUse PeopleCacheWrapper
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible
    private ResponseWrapper getAllPeopleForCaching(String requestData) {
   		logger.logDebug('MobileUtilityDataServer.getAllPeopleForCaching()--------'+requestData);
   		ResponseWrapper responseToReturn = null;
   		try{
   			Map<String, Object> resultMap = new Map<String, Object>();
        	resultMap.put('requestTimeStamp',(DateTime.now()).getTime()+'');
   			Map<String,Object> requestDataMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
   			Integer size = requestDataMap.get('size') != null ?Integer.valueOf(requestDataMap.get('size')) : 0;
   			Integer offset = requestDataMap.get('offset') != null ?Integer.valueOf(requestDataMap.get('offset')) : 0;
   			List<PeopleCacheWrapper> peopleWrapperList = (new MobilePeopleDataProvider()).getAllPeopleForCaching(size, offset);
   			resultMap.put('result',peopleWrapperList);
   			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'People list returned successfully!', resultMap);
   		
   		} catch(Exception e) {
        	logger.logError('MobileUtilityDataServer.getAllPeopleForCaching()----Could not fetch people list',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
   		logger.logDebug('MobileUtilityDataServer.getAllPeopleForCaching()----responseToReturn----'+responseToReturn);
   		return responseToReturn;
   	}
    
    @testVisible 
    private ResponseWrapper getCacheSiteById() {
	    	logger.logDebug('MobileUtilityDataServer.getCacheSiteById()----');
	    	ResponseWrapper resultWrapper = new ResponseWrapper();
	    	try {
				String siteId = readParam('siteId');
		    	String chatterGroupId = readParam('chatterGroupId');
		    	if(String.isNotBlank(chatterGroupId) ){
	    			Id  chatterGrpId  = chatterGroupId;
	    			List<Simpplr_Site__c> siteList = [Select Id from Simpplr_Site__c Where Chatter_Group_Id__c =:chatterGrpId WITH SECURITY_ENFORCED];
	    			if(siteList.isEmpty() == false){
	    				siteId = siteList[0].Id;
	    			}
		    	} else if(String.isBlank(siteId)){
		    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		    	}
	        	Map<String, Object> resultMap = new Map<String, Object>();
	        	MobileSiteDataProvider mblSiteDataProviderObj = new MobileSiteDataProvider();
		    	resultMap.put('site',mblSiteDataProviderObj.getSiteForCaching(siteId));
		    	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Site have been fetched succesfully!', resultMap);
		    	
			} catch(Exception e){
				logger.logError('MobileUtilityDataServer.getCacheSiteById()-----could not retrieve content----',e);
				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	    	}
	    	logger.logDebug('MobileUtilityDataServer.getCacheSiteById()--------resultWrapper----'+resultWrapper);
	    	return resultWrapper;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileUtilityDataServer&action=getBasicOrgInfo getBasicOrgInfo
	 * @apiVersion 1.0.0
	 * @apiGroup MobileUtilityDataServer
	 * @apiName getBasicOrgInfo
	 *
	 * @apiParam (Query Parameter) {String} action getBasicOrgInfo
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting basic org informations
	 * @apiSuccess {Boolean} isFeedEnabled True, if feed is enabled
	 * @apiSuccess {String} baseUrl Salesforce base url
	 * @apiSuccess {String} mediumPhotoUrl Logged in user medium sizes profile photo
	 * @apiSuccess {String} baseUrl Salesforce base url
	 * @apiSuccess {String} sfUserId Salesforce user id.
	 * @apiSuccess {String} size Size used for listing paginations
	 * @apiSuccess {String} peopleId Simpplr people id
	 * @apiSuccess {String} userName Logged in user full name
	 * @apiSuccess {Boolean} isSysAdmin True, if logged in user is System Administrator
	 * @apiSuccess {Boolean} isAppManager True, if logged in user is App Manager
	 * @apiSuccess {Boolean} isUnlistedManager True, if logged in user has manage Unlisted site permission
	 * @apiSuccess {Number} notificationCount Count of notifications
	 * @apiSuccess {Number} notificationRefreshInterval Duration for notifcation polling
	 * @apiSuccess {String} primaryColor Primary color used in branding
	 * @apiSuccess {String} backgroundColor Background color used in branding
	 * @apiSuccess {Number} peopleCount Total people count in app
	 * @apiSuccess {Number} siteCount Total site count in app
	 * @apiSuccess {Number} contentCount Total content count in app
	 * @apiError SimpplrException Simpplr Exception
	 */
    @testVisible 
    private ResponseWrapper getBasicOrgInfo(){
    	logger.logDebug('MobileUtilityDataServer.getBasicOrgInfo()----');
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	
			Map<String,Object> basicOrgInfoMap = getAppConfigData();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Salesforce basic org info returned successfully!',basicOrgInfoMap);
        }catch(Exception e){
        	logger.logError('MobileUtilityDataServer.getBasicOrgInfo()----Could not retrieve basic org info',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
        }
        logger.logDebug('MobileUtilityDataServer.getBasicOrgInfo()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	private Map<String,Object> getAppConfigData() {
		TimeZone tz = UserInfo.getTimeZone();
		Map<String,Object> basicOrgInfoMap = new Map<String,Object>();
		basicOrgInfoMap.put('isFeedEnabled',true);
		basicOrgInfoMap.put('feedMode',SimpplrContext.feedMode);
		basicOrgInfoMap.put('isSegmentsEnabled',SimpplrContext.isSegmentsEnabled);
		if(String.isNotBlank(SimpplrContext.segmentColumnName)) {
			basicOrgInfoMap.put('segmentName', UserContext.segmentName);
			basicOrgInfoMap.put('segmentColumnName', Utility.getLabelForSegmentFieldApi(SimpplrContext.segmentColumnName));
			basicOrgInfoMap.put('segmentAttributeValue',UserContext.segmentAttributeValue);
		}
		basicOrgInfoMap.put('isMaintenanceModeOn',SimpplrContext.isMaintenanceInProgress);
		
		if(SimpplrContext.isMaintenanceInProgress &&
			('enableSegmentation'.equalsIgnoreCase(SimpplrContext.maintenanceReason) || 'disableSegmentation'.equalsIgnoreCase(SimpplrContext.maintenanceReason))){
			basicOrgInfoMap.put('segmentationInProgress',true);
		}else {
			basicOrgInfoMap.put('segmentationInProgress',false);
		}
		
		basicOrgInfoMap.put('baseUrl',Url.getSalesforceBaseUrl().toExternalForm());
		basicOrgInfoMap.put('mediumPhotoUrl',Utility.getUserProfileImgUrl(UserContext.MediumPhotoUrl, UserContext.FullPhotoUrl));
		basicOrgInfoMap.put('sfUserId',UserContext.userId);
		basicOrgInfoMap.put('size',SimpplrContext.simpplrDefaultPageSize);
		basicOrgInfoMap.put('peopleId',UserContext.peopleId);
		basicOrgInfoMap.put('hireDate',UserContext.hireDate);
		basicOrgInfoMap.put('segmentID',UserContext.segmentId);
		basicOrgInfoMap.put('languageLocaleKey',UserContext.languageLocaleKey);
		basicOrgInfoMap.put('department',UserContext.getUsersDepartmentDetail);
		basicOrgInfoMap.put('userName',UserContext.peopleName);
		basicOrgInfoMap.put('userTimeZone',tz.getOffset(system.today()));
		basicOrgInfoMap.put('userTimeZoneName', UserContext.timeZoneLabel);
		basicOrgInfoMap.put('userTimezoneIso',UserInfo.getTimeZone().getId());
		basicOrgInfoMap.put('launchpadEnabled', Utility.isLaunchpadConfigured());
		basicOrgInfoMap.put('isSysAdmin',UserContext.hasModifyAllDataPermission);
		basicOrgInfoMap.put('isAppManager',UserContext.isUserAppModerator);
		basicOrgInfoMap.put('isUnlistedManager',UserContext.hasManageUnlistedSitePermission);
		basicOrgInfoMap.put('notificationCount',NotificationDao.getNewNotificationCount());
		basicOrgInfoMap.put('emailProductResearch',UserContext.emailProductResearch);
		basicOrgInfoMap.put('packageVersion',String.isBlank(SimpplrContext.packageName) ? 'Unmanaged' : Utility.getPackageVersion());
		basicOrgInfoMap.put('releaseVersion', ServiceConstants.RELEASE_VERSION);
		basicOrgInfoMap.put('isSiteMemberFollowersEnabled', true);
		Integer notirefreshInterval = (SimpplrContext.simpplrNotificationRefreshInterval == null || SimpplrContext.simpplrNotificationRefreshInterval == 0)?60000:(SimpplrContext.simpplrNotificationRefreshInterval)*1000;
		basicOrgInfoMap.put('notificationRefreshInterval',notirefreshInterval);
	
		String pepopleBranding = UserContext.getCurrentUserInfo.Segment__r.Branding_JSON__c;
		String brandingJson = SimpplrContext.isSegmentBrandingEnabled && String.isNotBlank(pepopleBranding) ? pepopleBranding : SimpplrContext.SABrandingJSON;
		
		if(String.isNotBlank(brandingJson)){
			Map<String,Object> brandingInfoMap = (Map<String,Object>)JSON.deserializeUntyped(brandingJson);
			basicOrgInfoMap.put('primaryColor',brandingInfoMap.get('general_primaryColor') != null ? brandingInfoMap.get('general_primaryColor')+'':null);
			basicOrgInfoMap.put('primaryDarkModeColor',brandingInfoMap.get('general_primaryDarkModeColor') != null ? brandingInfoMap.get('general_primaryDarkModeColor')+'':null);
			basicOrgInfoMap.put('linkColor',brandingInfoMap.get('general_lightModelinkColor') != null ? brandingInfoMap.get('general_LightModelinkColor')+'':null);				//CONT-10737
			basicOrgInfoMap.put('linkColor',brandingInfoMap.get('general_darkModelinkColor') != null ? brandingInfoMap.get('general_DarkModelinkColor')+'':null);				//CONT-10737
			basicOrgInfoMap.put('linkColor',brandingInfoMap.get('general_brandingAnchorPrimaryColor') != null ? brandingInfoMap.get('general_brandingAnchorPrimaryColor')+'':null);				//CONT-10737


			basicOrgInfoMap.put('backgroundColor',brandingInfoMap.get('general_backgroundColor') != null ? brandingInfoMap.get('general_backgroundColor')+'':null);
			basicOrgInfoMap.put('headerPreset',brandingInfoMap.get('header_preset') != null ? brandingInfoMap.get('header_preset')+'':null);
			basicOrgInfoMap.put('headerBackgroundColor',brandingInfoMap.get('header_backgroundColor') != null ? brandingInfoMap.get('header_backgroundColor')+'':null);
			basicOrgInfoMap.put('alertBackgroundColor',brandingInfoMap.get('alert_backgroundColor') != null ? brandingInfoMap.get('alert_backgroundColor')+'':null);
			basicOrgInfoMap.put('alertTextColor',brandingInfoMap.get('alert_textColor') != null ? brandingInfoMap.get('alert_textColor')+'':null);
		} else {
			basicOrgInfoMap.put('primaryColor',null);
			basicOrgInfoMap.put('backgroundColor',null);
			basicOrgInfoMap.put('lightModelinkColor',null);			//CONT-10737	
			basicOrgInfoMap.put('darkModelinkColor',null);			//CONT-10737	
			basicOrgInfoMap.put('brandingAnchorPrimaryColor',null);			//CONT-10737	


			basicOrgInfoMap.put('alertBackgroundColor',null);
			basicOrgInfoMap.put('alertTextColor',null);
		}
		String logoUrl = SimpplrContext.isSegmentBrandingEnabled ? UserContext.getCurrentUserInfo.Segment__r.Branding_Logo__c : SimpplrContext.SALogo; 		
		basicOrgInfoMap.put('logoUrl',String.isNotBlank(logoUrl) ? logoUrl : 'https://s3-us-west-1.amazonaws.com/static.simpplr.com/assets/img/simpplr-logo.svg');
		basicOrgInfoMap.put('peopleCount',(new MobilePeopleDao()).getPeopleCount());
		Map<String,Integer> mapOfSiteAndContentCount = (new MobileSiteDao()).getMapOfSiteAndContentCount();
		basicOrgInfoMap.put('siteCount',mapOfSiteAndContentCount.get('siteCount'));
		basicOrgInfoMap.put('contentCount',mapOfSiteAndContentCount.get('contentCount'));
		basicOrgInfoMap.put('hasConnectedBoxAccount', UserContext.isBoxConnected);
		basicOrgInfoMap.put('hasConnectedDropboxAccount', hasConnectedDropboxAccount);
		basicOrgInfoMap.put('hasConnectedGoogleDriveAccount', hasConnectedGoogleDriveAccount);
		if(hasConnectedSPAccount) {
			basicOrgInfoMap.put('hasConnectedSharePointAccount', true);
			basicOrgInfoMap.put('isSharePointFullSearchEnabled', EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID
																	.equalsIgnoreCase(SimpplrContext.Integrations.get('sharepoint').Client_id__c));

		} else {
			basicOrgInfoMap.put('hasConnectedSharePointAccount', false);
			basicOrgInfoMap.put('isSharePointFullSearchEnabled', false);

		}
		basicOrgInfoMap.put('hasConnectedOneDriveAccount', hasConnectedODAccount);
		basicOrgInfoMap.put('hasConnectedAtlassianAccount', SimpplrContext.isAtlassianConnected);
		basicOrgInfoMap.put('confluenceCustomKBName', SimpplrContext.confluenceCustomKBName);
		basicOrgInfoMap.put('allowFileUpload', SimpplrContext.allowFileUpload);
		basicOrgInfoMap.put('isCRMEnabled', new FolderDao().isCRMAvailable());
		basicOrgInfoMap.put('nativeVideoEnabled', SimpplrContext.isNativeVideo);
		basicOrgInfoMap.put('isEmployeeAdvocacyEnabled', SimpplrContext.isEmployeeAdvocacyEnabled && !SimpplrContext.appIntegrationEnabledSet.isEmpty());
		basicOrgInfoMap.putAll(getSocialAccountsConnectedMap());
		basicOrgInfoMap.put('isAutomatedTranslationEnabled', SimpplrContext.appConfig.Automated_Translation_Enabled__c);
		basicOrgInfoMap.put('contentUrl', Utility.getFileDownloadBaseURL());
		
		List<String> allowedfeatureList = SimpplrContext.AllowedFeatures.split(',');
		Set<String> allowedFeatureSet = new Set<String>();
		for(String feature : allowedFeatureList){
			allowedFeatureSet.add(feature.toLowerCase());
		}
		basicOrgInfoMap.put('isPageOn',allowedFeatureSet.contains('page')?true:false);
		basicOrgInfoMap.put('isAlbumOn',allowedFeatureSet.contains('album')?true:false);
		basicOrgInfoMap.put('isEventOn',allowedFeatureSet.contains('event')?true:false);
		basicOrgInfoMap.put('isBlogOn',allowedFeatureSet.contains('blog')?true:false);
		basicOrgInfoMap.put('isFileOn',allowedFeatureSet.contains('file')?true:false);
		
		basicOrgInfoMap.put('isFeedOn',SimpplrContext.isFeedEnabled);
		basicOrgInfoMap.put('appName',SimpplrContext.applicationName);
		
		if('None'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication)) {
			basicOrgInfoMap.put('isAboutEditible',SimpplrContext.isPPAboutMeEditable);
		} else {
			basicOrgInfoMap.put('isAboutEditible',!SimpplrContext.isPDSAboutMe && SimpplrContext.isPPAboutMeEditable);
		}
		basicOrgInfoMap.put('defaultPageSize',SimpplrContext.simpplrDefaultPageSize);
		basicOrgInfoMap.put('siteMentionEnabled', !SimpplrContext.isMuteContentPostInSiteFeedEnabled);
		basicOrgInfoMap.put('isStreetDisplayOn',SimpplrContext.isPPStreetDisplay);
		basicOrgInfoMap.put('isAboutMeDisplayOn',SimpplrContext.isPPAboutMeDisplay);
		basicOrgInfoMap.put('isBirthDateDisplayOn',SimpplrContext.isPPBirthDateDisplay);
		basicOrgInfoMap.put('isCategoryDisplayOn',SimpplrContext.isPeopleCategoryEnable);
		basicOrgInfoMap.put('isCityDisplayOn',SimpplrContext.isPPCityDisplay);
		basicOrgInfoMap.put('isCountryDisplayOn',SimpplrContext.isPPCountryDisplay);
		basicOrgInfoMap.put('isDepartmentDisplayOn',SimpplrContext.isPPDepartmentDisplay);
		basicOrgInfoMap.put('isExtensionDisplayOn',SimpplrContext.isPPExtensionDisplay);
		basicOrgInfoMap.put('isFirstNameDisplayOn',SimpplrContext.isPPFirstNameDisplay);
		basicOrgInfoMap.put('isJoiningDateDisplayOn',SimpplrContext.isPPJoiningDateDisplay);
		basicOrgInfoMap.put('isLastNameDisplayOn',SimpplrContext.isPPLastNameDisplay);
		basicOrgInfoMap.put('isManagerDisplayOn',SimpplrContext.isPPManagerDisplay);
		basicOrgInfoMap.put('isMobileDisplayOn',SimpplrContext.isPPMobilePhoneDisplay);
		basicOrgInfoMap.put('isPhoneDisplayOn',SimpplrContext.isPPPhoneDisplay);
		basicOrgInfoMap.put('isStateDisplayOn',SimpplrContext.isPPStateDisplay);
		basicOrgInfoMap.put('isTimeZoneDisplayOn',SimpplrContext.isPPTimezoneDisplay);
		basicOrgInfoMap.put('isTitleDisplayOn',SimpplrContext.isPPTitleDisplay);
		basicOrgInfoMap.put('peopleCategorySingular',SimpplrContext.peopleCategorySingular);
		basicOrgInfoMap.put('peopleCategoryPlural',SimpplrContext.peopleCategoryPlural);
		
		basicOrgInfoMap.put('homeCarouselEnabled',SimpplrContext.appConfig.Home_Carousel_Enabled__c);
		basicOrgInfoMap.put('siteCarouselEnabled',SimpplrContext.appConfig.Site_Carousel_Enabled__c);
		basicOrgInfoMap.put('mobileAppAdditionalSecurityEnabled',SimpplrContext.appConfig.Mobile_App_Additional_Security_Enabled__c);
		basicOrgInfoMap.put('isOrgChartEnabled',SimpplrContext.isOrgChartEnabled);
		basicOrgInfoMap.put('isFeedbackEnabled', String.isNotBlank(SimpplrContext.feedbackToEmails));
		basicOrgInfoMap.put('isExpertiseAppManagerControlled', SimpplrContext.isExpertiseAppManagerControlled);
		basicOrgInfoMap.put('isExpertiseCreateAppManagerControlled', SimpplrContext.isExpertiseCreateAppManagerControlled);
		basicOrgInfoMap.put('peopleCustomFieldList',getCustomProfileFieldList());
		if(String.isNotBlank(SimpplrContext.feedPlaceholder)) {
			basicOrgInfoMap.put('feedPlaceholder', SimpplrContext.feedPlaceholder.replaceAll('#userfirstname#', UserContext.firstName));
		} else {
			basicOrgInfoMap.put('feedPlaceholder', SimpplrContext.feedPlaceholder);
		}
		basicOrgInfoMap.put('addOns', getAddOns());
		basicOrgInfoMap.put('isQuestionAnswerEnabled', SimpplrContext.isQuestionAnswerEnabled);
		basicOrgInfoMap.put('isQuestionEnabledForContent', SimpplrContext.isQuestionAnswerEnabled && SimpplrContext.questionChangesForKITA);
		basicOrgInfoMap.put('listenerSuiteAPIURL', SimpplrContext.listenerSuiteURL);
		basicOrgInfoMap.put('microserviceUrl', SimpplrContext.simpplrAPIEndpoint);
		basicOrgInfoMap.put('zeusMicroserviceUrl',SimpplrContext.zeusMicroserviceUrl);
		basicOrgInfoMap.put('enterpriseSearch', getEnterpriseSearchSettings());	
		basicOrgInfoMap.put('enterpriseSearchList', getEnterpriseSearchListSettings());		
		basicOrgInfoMap.put('isContentModerationEnabled', SimpplrContext.isContentModerationEnabled);
		basicOrgInfoMap.put('isOnboardingEnabled', SimpplrContext.isOnboardingEnabled);
		basicOrgInfoMap.put('isOnboardingContentExist', SimpplrContext.isOnboardingContentExist);
		basicOrgInfoMap.put('isNewEditorEnabled', SimpplrContext.isNewEditorEnabled);
		basicOrgInfoMap.put('globalSearchProvider', SimpplrContext.globalSearchProvider);
		basicOrgInfoMap.put('globalSearchBaseUrl', SimpplrContext.simpplrAPIEndpointMFE+'/search');
		return basicOrgInfoMap;
	}
    

	public List<CustomProfileField> getCustomProfileFieldList(){
		List<CustomProfileField> customFieldList = new List<CustomProfileField>();
		List<CustomProfileField> peopleCustomFieldList = new List<CustomProfileField>();
		if(String.isNotBlank(SimpplrContext.PPUserCustomFields)) {
			Map<String,Schema.SObjectField> userFields = User.SObjectType.getDescribe().fields.getMap();
			customFieldList = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);
			for(CustomProfileField customFieldObj : customFieldList) {	
				if(String.isBlank(customFieldObj.syncSource)) {
					DescribeFieldResult resultObj = userFields.get(customFieldObj.fieldName).getDescribe();
					if (Schema.DisplayType.Picklist == resultObj.getType()) {
						customFieldObj.listOfOptions = getPickListOptions(resultObj.getPicklistValues());
						customFieldObj.fieldType = 'picklist';
							
					} else if (Schema.DisplayType.MultiPicklist == resultObj.getType()) {
						customFieldObj.listOfOptions = getPickListOptions(resultObj.getPicklistValues());
						customFieldObj.fieldType = 'multipicklist';

					} else {
						customFieldObj.fieldType = resultObj.getType().name();
					}
				}
				if(customFieldObj.displayPeopleFilter != null && customFieldObj.displayPeopleFilter == true){
					peopleCustomFieldList.add(customFieldObj);
				}
			}
		}
		return peopleCustomFieldList;
	}

	private List<CustomProfileField.Option> getPickListOptions(List<Schema.PicklistEntry> pickListEntries) {
		List<CustomProfileField.Option> optionList = new List<CustomProfileField.Option>();
		for(Schema.PicklistEntry pickList : pickListEntries) {
			CustomProfileField.Option optionWrapper = new CustomProfileField.Option();
			optionWrapper.label = pickList.getLabel();
			optionWrapper.value = pickList.getValue();
			optionList.add(optionWrapper);
		}
		return optionList;
	}
    /**
	 * @api {post} /apex/DataServerRW?target=MobileUtilityDataServer&action=getSalesforceBaseUrl getSalesforceBaseUrl
	 * @apiVersion 1.0.0
	 * @apiGroup MobileUtilityDataServer
	 * @apiName getSalesforceBaseUrl
	 *
	 * @apiParam (Query Parameter) {String} action getSalesforceBaseUrl
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting salesforce base url
	 * @apiSuccess {String} result Salesforce base url
	 * @apiError SimpplrException Simpplr Exception
	 */
	@testVisible 
    private ResponseWrapper getSalesforceBaseUrl(){
    	logger.logDebug('----getSalesforceBaseUrl---');
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Salesforce base url returned successfully!', Url.getSalesforceBaseUrl().toExternalForm());
        }catch(Exception e){
        	logger.logError('Could not retrieve salesforce base url',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
        }
        logger.logDebug('MobileUtilityDataServer.getSalesforceBaseUrl()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=MobileUtilityDataServer&action=getPopularSearchList getPopularSearchList
	 * @apiVersion 1.0.0
	 * @apiGroup MobileUtilityDataServer
	 * @apiName getPopularSearchList
	 *
	 * @apiParam (Query Parameter) {String} action getPopularSearchList
	 *
	 * @apiDescription 
	 * 1. Called from Mobile App
	 * 2. This is used for getting popular search terms
	 * @apiUse AnalyticsWrapperPerformanceSearchData
	 * @apiError SimpplrException Simpplr Exception
	 */
	@testVisible 
    private ResponseWrapper getPopularSearchList(){
    	logger.logDebug('MobileUtilityDataServer.getPopularSearchList()---');
        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try{
        	AnalyticsDao analyticsDaoObj = new AnalyticsDao();
        	DateTime todayDate = Date.today();
        	Date toDate = Date.today();
			Date fromDate = Date.today().addDays(-14);
			List<String> dateToPart =( ''+toDate ).split(' ');
			List<String> dateFromPart =( ''+fromDate ).split(' ');
        	
        	String fromDateStr = dateFromPart[0];
        	String toDateStr = dateToPart[0];
        	List<AnalyticsWrapper.PerformanceSearchData> listofPerformanceSearchWrapper = analyticsDaoObj.getPerformanceSearch(fromDateStr,toDateStr);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Popular search result returned successfully!', listofPerformanceSearchWrapper);
        }catch(Exception e){
        	logger.logError('Could not retrieve popular search result',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('MobileUtilityDataServer.getPopularSearchList()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    @testVisible
    private Boolean getAppConfigChangeFlag(DateTime pollTimeGMT){
    	
    	Boolean hasAppConfigUpdated = false;
    	logger.logDebug('MobileUtilityDataServer.getAppConfigChangeFlag()----');
    	
		String appConfigQuery = 'select id from App_Config__c where LastModifiedDate >: soqlParam1 limit 1';
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', pollTimeGMT);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, soqlParamMap);
		
    	if(appConfigList.isEmpty() == false){
    		hasAppConfigUpdated = true;
		}
		if(UserContext.getCurrentUserInfo.User__r.LastmodifiedDate >= pollTimeGMT) {
			hasAppConfigUpdated = true;
		}
    	
    	if(String.isNotBlank(UserContext.segmentId) && UserContext.getCurrentUserInfo.Segment__r.LastmodifiedDate >= pollTimeGMT){
    		hasAppConfigUpdated = true;
    	}
    	logger.logDebug('MobileUtilityDataServer.getAppConfigChangeFlag()----hasAppConfigUpdated----'+hasAppConfigUpdated);
    	return hasAppConfigUpdated;
    }
    
    
    public ResponseWrapper markNotificationStatusAsRead(String notificationId) {
    	ResponseWrapper responseWrapperObj;
    	try{
	    	logger.logDebug('MobileUtilityDataServer.markNotificationStatusAsRead()----');
    		if(!String.isBlank(notificationId)) {
		    	List<App_Notification__c> notificationList = [select id, Is_Read__c, Is_New__c from App_Notification__c 
		    															where id=:notificationId and Is_Read__c=false 
		    															and Is_Deleted__c=false and type__c='Information' WITH SECURITY_ENFORCED limit 1];
		    	if(!notificationList.isEmpty()){
		    		notificationList[0].Is_Read__c = true;
		    		notificationList[0].Is_New__c = false;
		    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notificationList),new List<Schema.SObjectField>{App_Notification__c.Is_Read__c, App_Notification__c.Is_New__c});
		    	}
    		}
    	 responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' Notification marked as read successfully!', true);
        }catch(Exception e){
        	logger.logError('MobileUtilityDataServer.markNotificationStatusAsRead()----Could not notification as resd',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, false);
        }
        logger.logDebug('MobileUtilityDataServer.markNotificationStatusAsRead()--------responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }


    public Boolean isGoogleDriveConnected{ get{
		return SimpplrContext.Integrations != null && SimpplrContext.Integrations.containsKey('googledrive') && 
				SimpplrContext.Integrations.get('googledrive').Integration_Enabled__c 
				&& SimpplrContext.Integrations.get('googledrive').Connected__c;
	}}
	
	public Boolean isDropboxConnected{ get{
		return SimpplrContext.appConfig != null  && SimpplrContext.Integrations.containsKey('dropbox') &&  
				SimpplrContext.Integrations.get('dropbox').Integration_Enabled__c 
				&& SimpplrContext.Integrations.get('dropbox').Connected__c;
	}}
	
	public Boolean isSPConnected{ get{
		return SimpplrContext.Integrations != null && SimpplrContext.Integrations.containsKey('sharepoint') && 
				SimpplrContext.Integrations.get('sharepoint').Integration_Enabled__c 
				&& SimpplrContext.Integrations.get('sharepoint').Connected__c;
	}}
	
	public Boolean isODConnected{ get{
		return SimpplrContext.Integrations != null && SimpplrContext.Integrations.containsKey('onedrive') &&
				SimpplrContext.Integrations.get('onedrive').Integration_Enabled__c 
				&& SimpplrContext.Integrations.get('onedrive').Connected__c;
	}}
	
	public Boolean hasConnectedGoogleDriveAccount { get{
		return isGoogleDriveConnected && UserContext.Integrations != null && UserContext.Integrations.containsKey('googledrive') 
				&& UserContext.Integrations.get('googledrive').Connected__c;
	}}
	
	public Boolean hasConnectedDropboxAccount { get{
		return isDropboxConnected && UserContext.Integrations != null && UserContext.Integrations.containsKey('dropbox')
				&& UserContext.Integrations.get('dropbox').Connected__c;
	}}
	
	public Boolean hasConnectedSPAccount { get{
		return isSPConnected && UserContext.Integrations != null && UserContext.Integrations.containsKey('sharepoint') 
				&& UserContext.Integrations.get('sharepoint').Connected__c;
	}}
	
	public Boolean hasConnectedODAccount { get{
		return isODConnected && UserContext.Integrations != null && UserContext.Integrations.containsKey('onedrive')
				&& UserContext.Integrations.get('onedrive').Connected__c;
	}}

	public List<String> getAddOns() {
		List<String> addOns = AccessManager.getAddons();
		addOns.add('mobile_tiles');		
		return addOns;
	}
	public AppInitWrapper.EnterpriseSearchSettings getEnterpriseSearchSettings() {
		logger.logDebug('MobileUtilityDataServer.getEnterpriseSearchSettings()');
		AppInitWrapper.EnterpriseSearchSettings enterpriseSearch = new AppInitWrapper.EnterpriseSearchSettings();
		enterpriseSearch.isEnabled = SimpplrContext.isEnterpriseSearchEnabled;
		if(SimpplrContext.isEnterpriseSearchEnabled) {
			enterpriseSearch.provider = SimpplrContext.enterpriseSearchProvider;
			enterpriseSearch.url = SimpplrContext.enterpriseSearchUrl;
		}
		return enterpriseSearch;
	}	
	public List<ManageApplicationWrapper.EnterpriseSearchIntegration> getEnterpriseSearchListSettings() {
		logger.logDebug('MobileUtilityDataServer.getEnterpriseSearchListSettings()');
		Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration> enterpriseSearchIntMap = new ManageApplicationDao().getSearchIntegrationsConfig();
		
		List<ManageApplicationWrapper.EnterpriseSearchIntegration> esSettingsList = new List<ManageApplicationWrapper.EnterpriseSearchIntegration>();
		List<String> enterpriseSearchIntegrationNameList = IntegrationConstants.ENTERPRISE_SEARCH_INTEGRATION_NAME_LIST;
		for(String searchIntgName : enterpriseSearchIntegrationNameList){
			ManageApplicationWrapper.EnterpriseSearchIntegration eSIWrapper = enterpriseSearchIntMap.get(searchIntgName);

			esSettingsList.add(eSIWrapper);
		}
		return esSettingsList;
	}
}