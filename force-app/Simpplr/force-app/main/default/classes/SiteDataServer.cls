/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SiteDataServer extends DataServer{
	public transient final String STR_ERROR_STORAGE_FULL { get { return labelMap.get('common.storage_full_error_flash');}}
	public transient final String STR_ERROR_MANAGE_SITE_DUPLICATE { get { return labelMap.get('manage_sites.duplicate_error_flash');}}
	public transient final String STR_ERROR_SITE_PER_USER_LIMIT_EXCEEDED { get { return labelMap.get('manage_sites.site_limit_reached_error_flash');}}
	public transient final String STR_KEY_SITE_DUPLICATE_NAME_NOT_ALLOWED {get {return labelMap.get('manage_sites.duplicate_site_name_error_message');}}
	public transient final String STR_UNABLE_TO_LOCK_ROW_ERROR {get { return labelMap.get('manage_sites.unable_to_lock_row_error_message') ;}}

	public static final String STATUS_APPROVED='Approved';
	public static final String STATUS_REJECTED='Rejected';

	private final String ACTION_VALUE_SEARCH = 'search';
	private final String ACTION_GET_PEOPLESTATS = 'getPeopleStats';
    private final String CREATE_SITE = 'createSite';
	private final String ACTION_CREATE_DUPLICATE = 'createDuplicate';
    private final String ACTION_GET_SITE_DETAIL = 'getsiteDetailData';
    private final String ACTION_VALUE_SET_FEATURED = 'setFeatured';
    private final String ACTION_VALUE_SET_PRIVATE = 'setPrivate';
    private final String ACTION_VALUE_SET_ACTIVATE = 'setActivated';
    private final String ACTION_VALUE_SET_CATEGORY = 'setCategory';
    private final String ACTION_VALUE_SET_IMAGE = 'setImage';
    private final String ACTION_VALUE_SET_COVER_IMAGE = 'setCoverImage';
    private final String ACTION_VALUE_REQUEST='request';
    private final String ACTION_VALUE_REQUEST_SET_SEQUENCE='arrangeFeaturedSites';
	private final String ACTION_VALUE_REQUEST_REVERT_TO_CHATTER_GROUP='revertToChatterGroup';
	private final String ACTION_VALUE_APPROVE_REQUEST_MEMBERSHIP='approveMembershipRequest';
	private final String ACTION_VALUE_REJECT_REQUEST_MEMBERSHIP='rejectMembershipRequest';
    
    private final String DUPLICATE_SITE_NAME_ERRMSG = 'A site already exists with this name - please change the name and try again';
    private final String SITE_PER_USER_LIMIT_EXCEEDED_ERRMSG = 'You\'ve reached your Site limit. It\'s not possible to manage or follow more Sites';
    private final String ERROR_SITE_FOLLOW_ALREADY_REQUESTED = 'You cannot create duplicate requests for the same group.';
    private final String STORAGE_LIMIT_EXCEEDED_ERRMSG = 'Unable to perform action - storage full';
    private final String PRIVATE_SITE_NOT_MANDATORY = 'Mandatory Sites cannot be made Private';
    private final String STANDARD_USER_BROADCAST_ONLY = 'You cannot make site Mandatory or Featured';
    private final String DUPLICATE_CATEGORY_STR = 'A category with this name already exists';
    
    private final String REQUEST_PARAM_DATA = 'data';
    private final String REQUEST_PARAM_INCLUDE_MEMBER_FOLLOWER_COUNT = 'includeMemberFollowerCount';
    private final String REQUEST_PARAM_LIST_OF_SITE_ID = 'listOfSiteId';
    private final String REQUEST_PARAM_SITE_ID = 'siteId';
    private final String REQUEST_PARAM_CHATTERGROUP_ID = 'chatterGroupId';
    private final String REQUEST_PARAM_SUBSCRIPTION_ID = 'subscriptionId';
    
    private final String ACTION_VALUE_APPROVE_SUBSCRIPTION = 'approveSubscription';
    private final String ACTION_VALUE_REJECT_SUBSCRIPTION = 'rejectSubscription';
    @TestVisible private final String ACTION_VALUE_GET_BY_IDS = 'getByIds';
    public SiteDataServer() {

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
        try {
        	
        	logger.logDebug('SiteDataServer----entered handleRequest---- ');
        	
        	String action = readParam(REQUEST_PARAM_ACTION);
            
            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
        		response = getSites(readParam(REQUEST_PARAM_DATA));	
	        	
            } else if(ACTION_GET_PEOPLESTATS.equalsIgnoreCase(action)){
				response = getPeopleStats(readParam(REQUEST_PARAM_DATA));
                 
			} else if (CREATE_SITE.equalsIgnoreCase(action)) {
				response = createSite(readParam(REQUEST_PARAM_DATA));
			} else if (ACTION_CREATE_DUPLICATE.equalsIgnoreCase(action)) {
				response = createDuplicate(readParam(REQUEST_PARAM_DATA));	        	 	        	
            } else if (ACTION_VALUE_SET_FEATURED.equalsIgnoreCase(action)) {
				response = setFeatured(readParam(REQUEST_PARAM_DATA));	        	
            } else if (ACTION_VALUE_SET_PRIVATE.equalsIgnoreCase(action)) {
				response = setPrivate(readParam(REQUEST_PARAM_DATA));	        	
            } else if (ACTION_VALUE_SET_ACTIVATE.equalsIgnoreCase(action)) {
				response = setActivate(readParam(REQUEST_PARAM_DATA));	        	
            } else if (ACTION_VALUE_SET_CATEGORY.equalsIgnoreCase(action)) {
				response = setCategory(readParam(REQUEST_PARAM_DATA));	
            } else if(ACTION_VALUE_SET_IMAGE.equalsIgnoreCase(action)) {
				response = setImage(readParam('siteId'), readParam('imageFile'));	
			} else if(ACTION_VALUE_SET_COVER_IMAGE.equalsIgnoreCase(action)) {
				response = setCoverImage(readParam('siteId'), readParam('imageFile'));	
			} else if (ACTION_GET_SITE_DETAIL.equalsIgnoreCase(action)) {
            		String siteId = String.isNotBlank(readParam('siteId'))?readParam('siteId'):null;
            		String chatterGroupId = String.isNotBlank(readParam('chatterGroupId'))?readParam('chatterGroupId'):null;
            		response = getsiteDetailData(siteId, chatterGroupId);
            } else if (ACTION_VALUE_REQUEST.equalsIgnoreCase(action)){
            	response = requestSiteMembership(readParam(REQUEST_PARAM_DATA));	
            } else if (ACTION_VALUE_REQUEST_SET_SEQUENCE.equalsIgnoreCase(action)){
            	response = setSiteSequence(readParam(REQUEST_PARAM_DATA));
            } else if (ACTION_VALUE_REQUEST_REVERT_TO_CHATTER_GROUP.equalsIgnoreCase(action)){
            	response = revertToChatterGroup(readParam(REQUEST_PARAM_SITE_ID));
            } else if (ACTION_VALUE_APPROVE_SUBSCRIPTION.equalsIgnoreCase(action)){
            	response = approveSubscription(readParam(REQUEST_PARAM_SITE_ID), readParam(REQUEST_PARAM_SUBSCRIPTION_ID));
            } else if (ACTION_VALUE_REJECT_SUBSCRIPTION.equalsIgnoreCase(action)){
            	response = rejectSubscription(readParam(REQUEST_PARAM_SITE_ID), readParam(REQUEST_PARAM_SUBSCRIPTION_ID));
			} else if (ACTION_VALUE_APPROVE_REQUEST_MEMBERSHIP.equalsIgnoreCase(action)){
            	response = approveMembershipRequest(readParam(REQUEST_PARAM_DATA));
			} else if (ACTION_VALUE_REJECT_REQUEST_MEMBERSHIP.equalsIgnoreCase(action)){
            	response = rejectMembershipRequest(readParam(REQUEST_PARAM_DATA));

			}  else if (ACTION_VALUE_GET_BY_IDS.equalsIgnoreCase(action)){				
				Boolean includeMemberFollowerCount = readParam(REQUEST_PARAM_INCLUDE_MEMBER_FOLLOWER_COUNT) != null ? Boolean.valueOf(readParam(REQUEST_PARAM_INCLUDE_MEMBER_FOLLOWER_COUNT)) : false;
                String[] listOfSiteId = (String[])JSON.deserialize(readParam(REQUEST_PARAM_LIST_OF_SITE_ID), 
                        String[].class);

                logger.logDebug(listOfSiteId);
                List<Simpplr_Site__c> listOfSite = new SiteDao().getSitesByIds(listOfSiteId);
                List<SiteLiteWrapper> listOfSiteWrap = new NewsletterV2DataAdapter().convertToListOfSiteLiteWrapper(listOfSite, includeMemberFollowerCount);
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfSiteWrap);
            
            } else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
    
        } catch (Exception ex) {
        	logger.logError(ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    } 
    
   @TestVisible 
   private ResponseWrapper setFeatured(String requestData){
        	ResponseWrapper responseWrapperObj = null;
        try{
        	SiteDao siteDaoObj = new SiteDao(); 
        	SiteWrapper.FeaturedWrapper featuredObj =(SiteWrapper.FeaturedWrapper)Json.deserialize(requestData, SiteWrapper.FeaturedWrapper.class);
        	if(SimpplrContext.isSegmentsEnabled){
        		if(String.isNotBlank(featuredObj.segmentId)) {
	        		siteDaoObj.setFeaturedWithSegment(featuredObj);
        		} else {
        			throw new SimpplrException('Unable to perform action, please try again after some time');
        		}
        	} else {
	        	siteDaoObj.setFeatured(featuredObj);
        	}
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }catch(Exception e){
        		logger.logError(e);
			if('Unable to perform action, please try again after some time'.equalsIgnoreCase(e.getMessage())){
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_UNABLE_TO_LOCK_ROW_ERROR, null);
            
			} else {
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
			}
		}
        
        return responseWrapperObj;
    }
    
    @TestVisible 
    private ResponseWrapper setPrivate(String requestData){
        ResponseWrapper responseWrapperObj = null;
        
        try{
			SiteWrapper.PrivateWrapper privatedObj =(SiteWrapper.PrivateWrapper)Json.deserialize(requestData, SiteWrapper.PrivateWrapper.class);
			
			SiteDao siteDaoObj = new SiteDao(); 
        	siteDaoObj.setPrivate(privatedObj);        	
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }catch(Exception e){
        	logger.logError(e);
        	
        	if(e.getmessage().containsIgnoreCase('DUPLICATE_VALUE, An active or archived group with this name already exists or is being deleted')){
				responseWrapperObj = buildResponseWrapper('error', STR_ERROR_MANAGE_SITE_DUPLICATE, null);
			} else {
            	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        	}
        }
        
        return responseWrapperObj;
    }
    @TestVisible 
    private ResponseWrapper setActivate(String requestData){
        ResponseWrapper responseWrapperObj = null;
        try{
			SiteWrapper.ActivateWrapper activatedObj =(SiteWrapper.ActivateWrapper)Json.deserialize(requestData, SiteWrapper.ActivateWrapper.class);
			SiteDao siteDaoObj = new SiteDao(); 
        	siteDaoObj.setActivate(activatedObj);
        	CategoryDao categoryDaoObj = new CategoryDao();
        	SiteListingWrapper siteObj = categoryDaoObj.getUncategorizedSiteCategory();
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, siteObj);
        }catch(Exception e){
        	logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper setCategory(String requestData){
        	ResponseWrapper responseWrapperObj = null;
        	SiteListingWrapper siteObjWrapper = new SiteListingWrapper();
        	
	        try{
	        	SiteWrapper.EditSiteCategoryWrapper editSiteCategoryObj =(SiteWrapper.EditSiteCategoryWrapper)Json.deserialize(requestData, SiteWrapper.EditSiteCategoryWrapper.class);
	        	SiteDao siteDaoObj = new SiteDao();
	        	if (String.isBlank(editSiteCategoryObj.categoryObj.category)){// new category being added
					siteObjWrapper = siteDaoObj.setCategory(editSiteCategoryObj);
					responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, siteObjWrapper);
						
	        	} else {
	        		siteObjWrapper = siteDaoObj.setCategory(editSiteCategoryObj);
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, siteObjWrapper);
	        	}
	        }catch(Exception e){ 
	        	logger.logError(e);
	            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
	        }
	        
	        return responseWrapperObj;
    }
    
    @TestVisible 
	private ResponseWrapper setImage(String siteId, String imageFileJSON) {
    	ResponseWrapper responseWrapperObj = null;
        try{
        	FileContentWrapper imageFile = String.isNotBlank(imageFileJSON) ? (FileContentWrapper) Json.deserialize(imageFileJSON, FileContentWrapper.class) : null;
	    	
    		if(String.isNotBlank(siteId)) {
    			String chatterGroupId = SiteContext.chatterGroupId;
    			String siteType = SiteContext.currentSiteType;
    			if(imageFile!=null) {
    				try{
						ConnectApi.ChatterGroups.setPhoto(null, chatterGroupId, imageFile.contentDocumentId, null);
    				} catch(Exception e){
    					logger.logError('SiteDataServer.setImage()----ConnectApi.ChatterGroups.setPhoto API exception: ',e);
    				}
    			}
    			
    			Simpplr_Site__c siteObj = new Simpplr_Site__c();
	        	siteObj.Id = siteId;
	        	siteObj.Chatter_Group_Id__c = chatterGroupId;
				siteObj.Site_Type__c = siteType;
				siteObj.Last_Edited_DateTime__c = DateTime.now();
				siteObj.Title_Content_Version__c = imageFile != null ? imageFile.contentVersionId : null;
				siteObj.Title_Content_Document__c = imageFile != null ? imageFile.contentDocumentId : null;
				
				if(imageFile != null){
					SiteDao siteDao = new SiteDao(); 
					siteDao.createContentDocumentLink(new List<Simpplr_Site__c>{siteObj});
				}
				// Update site record
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(siteObj, new List<Schema.SObjectField>{
					Simpplr_Site__c.Chatter_Group_Id__c,
					Simpplr_Site__c.Site_Type__c,
					Simpplr_Site__c.Last_Edited_DateTime__c,
					Simpplr_Site__c.Title_Content_Version__c,
					Simpplr_Site__c.Title_Content_Document__c
				});
				
        	} else{
        		throw new SimpplrException('Site Id cannot be null');
        	}
	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }catch(Exception e){
        	logger.logError('SiteDataServer.setImage()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        return responseWrapperObj;
    }
    
    @TestVisible 
	private ResponseWrapper setCoverImage(String siteId, String imageFileJSON) {
    	ResponseWrapper responseWrapperObj = null;
        try{
        	FileContentWrapper imageFile = String.isNotBlank(imageFileJSON) ? (FileContentWrapper) Json.deserialize(imageFileJSON, FileContentWrapper.class) : null;
	    	
    		if(String.isNotBlank(siteId)) {
    			String chatterGroupId = SiteContext.chatterGroupId;
    			String siteType = SiteContext.currentSiteType;
    			
    			Simpplr_Site__c siteObj = new Simpplr_Site__c();
	        	siteObj.Id = siteId;
	        	siteObj.Chatter_Group_Id__c = chatterGroupId;
				siteObj.Site_Type__c = siteType;
				siteObj.Last_Edited_DateTime__c = DateTime.now();
				siteObj.Cover_Content_Version__c = imageFile != null ? imageFile.contentVersionId : null;
				siteObj.Cover_Content_Document__c = imageFile != null ? imageFile.contentDocumentId : null;
				
				// Update site record
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(siteObj, new List<Schema.SObjectField>{
					Simpplr_Site__c.Chatter_Group_Id__c,
					Simpplr_Site__c.Site_Type__c,
					Simpplr_Site__c.Last_Edited_DateTime__c,
					Simpplr_Site__c.Cover_Content_Version__c,
					Simpplr_Site__c.Cover_Content_Document__c
				});
				
				if(imageFile != null){
			    	if('Unlisted'.equalsIgnoreCase(siteType)) {
						ContentDocumentLink cdLink = new ContentDocumentLink();
						cdLink.ContentDocumentId = imageFile.contentDocumentId; 
						cdLink.ShareType = 'C';
						cdLink.LinkedEntityId = chatterGroupId;

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPESAPI.accessController().insertAsUser(cdLink, new List<Schema.SObjectField>{
							ContentDocumentLink.ContentDocumentId,
							ContentDocumentLink.ShareType,
							ContentDocumentLink.LinkedEntityId
						});
					}else {
						ContentDocumentLink cdLink2 = new ContentDocumentLink();
						cdLink2.ContentDocumentId = imageFile.contentDocumentId; 
						cdLink2.ShareType = 'V';
						cdLink2.LinkedEntityId = UserInfo.getOrganizationId();

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPESAPI.accessController().insertAsUser(cdLink2, new List<Schema.SObjectField>{
							ContentDocumentLink.ContentDocumentId,
							ContentDocumentLink.ShareType,
							ContentDocumentLink.LinkedEntityId
						});
					}	
				}				  
        	} else{
        		throw new SimpplrException('Site Id cannot be null');
        	}
	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        }catch(Exception e){
        	logger.logError('SiteDataServer.setCoverImage()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        return responseWrapperObj;
	}    
	
    public ResponseWrapper getPeopleStats(String requestData) {
		logger.logdebug('PeopleListWrapper.getPeopleStats() '+requestData);
		SiteContentProvider siteContentProviderObj = new SiteContentProvider(); 
		Criteria.Site siteCriteriaObjArg = (Criteria.Site)JSON.deserialize(requestData, Criteria.Site.class);
        ResponseWrapper responseToReturn = null;
        PeopleWrapper.peopleStatsWrapper peopleStatsObj = new PeopleWrapper.peopleStatsWrapper();

        if (!String.isBlank(siteCriteriaObjArg.term) && 
                SimpplrContext.isFeatureEnabled('Full_External_Search')) {
            Criteria.ExternalSearchReq extSiteCriteriaObj = new Criteria.ExternalSearchReq();
            extSiteCriteriaObj.siteId = siteCriteriaObjArg.siteId;
            extSiteCriteriaObj.term = siteCriteriaObjArg.term;
            extSiteCriteriaObj.requestType = 'count';
            String  peopleStatJson = new ExternalSearchService().getPeopleStats(extSiteCriteriaObj); 
            peopleStatsObj = new ExternalSearchResultToWrapper().extPeopleStatToWrapper(peopleStatJson);
            responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleStatsObj);

        } else { 
            try {
                peopleStatsObj = siteContentProviderObj.getPeopleStats(siteCriteriaObjArg);
                responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleStatsObj);
            } catch(Exception e) {
                logger.logError(e);
                responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
            }
        }

		return responseToReturn;
	}
    
    @TestVisible 
	public ResponseWrapper getSites(String requestData) {
		logger.logdebug('------------getSites()---'+requestData);
		SiteContentProvider siteContentProviderObj = new SiteContentProvider(); 
		Criteria.Site siteCriteriaObjArg = (Criteria.Site)JSON.deserialize(requestData, Criteria.Site.class);
		SiteListWrapper.PaginationWrapper paginationObj = new SiteListWrapper.PaginationWrapper();
        if (siteCriteriaObjArg == null) {
            throw New SimpplrException(ServiceConstants.ERROR_INVALID_REQUEST_PARAMETERS);
        }

		//handling null value for canSubmitQuestion flag
		if(siteCriteriaObjArg.canSubmitQuestion == null){
			siteCriteriaObjArg.canSubmitQuestion = false;
		}

    	logger.logDebug('------------siteCriteriaObjArg---'+siteCriteriaObjArg);
		ResponseWrapper responseToReturn = null;
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		Integer pageSize = 0;
		
		try{
			pageSize = siteCriteriaObjArg.size != null ? siteCriteriaObjArg.size : SimpplrContext.simpplrDefaultPageSize;
			siteCriteriaObjArg.size = pageSize;
			
            if (siteCriteriaObjArg.nextPageToken == null) {
    			siteCriteriaObjArg.offset = 0;
    		
            } else {
    			siteCriteriaObjArg.offset = Integer.valueOf(siteCriteriaObjArg.nextPageToken);
    		}
			
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotEmpty(siteCriteriaObjArg.term)) {
				logger.logDebug('--------enter in external search');
				Criteria.ExternalSearchReq siteSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				String SearchForType = 'Site';
				List<String> siteIds = new List<String>();
				ExternalSearchService externalSearchService = new ExternalSearchService();
				if(siteCriteriaObjArg.filter != null && siteCriteriaObjArg.filter.containsIgnoreCase('favorite')) {
					List<String> bookmarkSiteIds = new List<String>();
					List<Bookmark__c> bookmarkList = [Select id, Simpplr_Site__c From Bookmark__c where Type__c = 'Site' 
													And Simpplr_Site__r.Is_Active__c=true And Simpplr_Site__r.Is_Deleted__c = false
													AND Is_Deleted__c = false AND Simpplr_Site__r.Show_In_Simpplr__c = true
													AND people__c =: UserContext.peopleId WITH SECURITY_ENFORCED Order by LastModifiedDate Desc];
					for(Bookmark__c bookmarkObj : bookmarkList) {
						bookmarkSiteIds.add(bookmarkObj.Simpplr_Site__c);
					}
					siteSearchCriteria.favouriteIds = bookmarkSiteIds;
				}
				if(siteSearchCriteria.size != null && siteSearchCriteria.size > 9999) {
					siteSearchCriteria.size = 9999;
				}
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchSites(siteSearchCriteria, SearchForType);
				if(returnWrapper.listOfItems != null && returnWrapper.listOfItems.size() > 0) {
					for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : returnWrapper.listOfItems) {
						Object item = itemWrapperObj.item;
						SiteListingWrapper slWrapper = (SiteListingWrapper)item;
						siteIds.add(slWrapper.id);	
					}					
					listOfSiteWrapper = sitecontentProviderObj.getSitesSearchResults(siteIds);
					paginationObj.listOfItems.addAll(listOfSiteWrapper);
					paginationObj.nextPageToken = returnWrapper.nextPageToken;
				}
			}
			
	        else {
				String searchTerm = '';
				
				if (String.isNotBlank(siteCriteriaObjArg.term)) {
					searchterm =  '%' + siteCriteriaObjArg.term + '%';
				
				} else {
					searchterm = '%%';
				}

				if (String.isNotBlank(siteCriteriaObjArg.sfUserId) && 
						(siteCriteriaObjArg.canAccess == null || siteCriteriaObjArg.canAccess == false) 
						&& (siteCriteriaObjArg.canManage == null || siteCriteriaObjArg.canManage == false) 
						&& (siteCriteriaObjArg.includeDeactivated == null || 
						siteCriteriaObjArg.includeDeactivated == false) &&
						!siteCriteriaObjArg.filter.containsIgnoreCase('popular') &&
						!siteCriteriaObjArg.filter.containsIgnoreCase('featured') &&
						!siteCriteriaObjArg.filter.containsIgnoreCase('favorite') &&
						!siteCriteriaObjArg.filter.containsIgnoreCase('following') &&
						!siteCriteriaObjArg.filter.containsIgnoreCase('members') 
						) {
					if (siteCriteriaObjArg.filter != null && 
							siteCriteriaObjArg.filter.containsIgnoreCase('managing')) {
						logger.logdebug('SiteDataServer.getProfileSitesAllManagingSites()----');
						listOfSiteWrapper = siteContentProviderObj.getProfileSitesAllManagingSites(siteCriteriaObjArg);
					
					} else {
						logger.logdebug('SiteDataServer.getProfileSitesAllSites()----');
						listOfSiteWrapper = siteContentProviderObj.getProfileSitesAllSites(siteCriteriaObjArg);
					} 

				} else if (siteCriteriaObjArg.canManage != null && siteCriteriaObjArg.canManage){
						logger.logdebug('SiteDataServer.getSitesSearchResults()----');
						listOfSiteWrapper = siteContentProviderObj.getSitesSearchResults(siteCriteriaObjArg);
					
				} else if (siteCriteriaObjArg.isManager != null && siteCriteriaObjArg.isManager){
					logger.logdebug('SiteDataServer.getSitesSearchResultsManagedByLoggedInUser()----');
					listOfSiteWrapper = siteContentProviderObj.getSitesSearchResultsManagedByLoggedInUser(siteCriteriaObjArg);
				
				} else if (String.isNotBlank(siteCriteriaObjArg.term) && 
						siteCriteriaObjArg.canAccess != null && siteCriteriaObjArg.canAccess) {
						logger.logdebug('SiteDataServer.getSitesCanBeMentionedInFeed()----');
						listOfSiteWrapper = siteContentProviderObj.getSitesCanBeMentionedInFeed(searchterm);
					
				} else if (siteCriteriaObjArg.filter != null && 
						siteCriteriaObjArg.filter.containsIgnoreCase('canCreateAlert')) {
					siteCriteriaObjArg.term = searchterm;
					logger.logdebug('SiteDataServer.getAvailableSitesForAlert()----');
					listOfSiteWrapper = siteContentProviderObj.getAvailableSitesForAlert(siteCriteriaObjArg);
					
				} else if (siteCriteriaObjArg.filter != null && 
						siteCriteriaObjArg.filter.containsIgnoreCase('canCreateNewsletter')) {
					logger.logdebug('SiteDataServer.getAvailableSitesForNewsLetter()----');
					listOfSiteWrapper = siteContentProviderObj.getAvailableSitesForNewsLetter(searchterm);
					
				} else if (siteCriteriaObjArg.filter != null && 
						siteCriteriaObjArg.filter.containsIgnoreCase('canAccessAnalytics')){
					logger.logdebug('SiteDataServer.searchSitesForAnalytics()----');
					listOfSiteWrapper = siteContentProviderObj.searchSitesForAnalytics(searchterm);
					
				} else if (siteCriteriaObjArg.filter != null && 
						siteCriteriaObjArg.filter.containsIgnoreCase('listed')){
					logger.logdebug('SiteDataServer.searchListedSites()----');
					listOfSiteWrapper = siteContentProviderObj.searchListedSites(searchterm);
					
				} else if (siteCriteriaObjArg.filter != null && 
						siteCriteriaObjArg.filter.containsIgnoreCase('canSubmitContent')){
					logger.logdebug('SiteDataServer.getSitesCanSubmitContent()----');
					if (String.isNotBlank(siteCriteriaObjArg.term)) {
						listOfSiteWrapper = siteContentProviderObj.getSitesAllSites(siteCriteriaObjArg);
					} else {
						listOfSiteWrapper = siteContentProviderObj.getSitesCanSubmitContent(searchterm, siteCriteriaObjArg.canSubmitQuestion);
					}
				
				} else if (siteCriteriaObjArg.filter != null && 
						siteCriteriaObjArg.filter.equalsIgnoreCase('recentUsedSites')) {
					logger.logdebug('SiteDataServer.recentUsedSites()----');
					listOfSiteWrapper = siteContentProviderObj.getRecentUsedSites(siteCriteriaObjArg);

				} else if (siteCriteriaObjArg.filter != null && 
						(siteCriteriaObjArg.includeDeactivated ==  null || 
						siteCriteriaObjArg.includeDeactivated == false) && 
						siteCriteriaObjArg.filter.containsIgnoreCase('active') == false) {
					
					if (siteCriteriaObjArg.filter.containsIgnoreCase('popular')) {
						logger.logdebug('SiteDataServer.getSitesAllPopularSites()----');
						listOfSiteWrapper = siteContentProviderObj.getSitesAllPopularSites(siteCriteriaObjArg);
					
					} else if (siteCriteriaObjArg.filter.containsIgnoreCase('featured')) {
						
						if (SimpplrContext.isSegmentsEnabled) {
							logger.logdebug('SiteDataServer.getSitesAllFeaturedSitesForSegments()----');
							listOfSiteWrapper = siteContentProviderObj.getSitesAllFeaturedSitesForSegments(siteCriteriaObjArg);
							
						} else {
							logger.logdebug('SiteDataServer.getSitesAllFeaturedSites()----');
							listOfSiteWrapper = siteContentProviderObj.getSitesAllFeaturedSites(siteCriteriaObjArg);
						}	
					
					} else if (siteCriteriaObjArg.filter.containsIgnoreCase('favorite')) {
						logger.logdebug('SiteDataServer.getSitesAllFavoriteSites()----');
						listOfSiteWrapper = siteContentProviderObj.getSitesAllFavoriteSites(siteCriteriaObjArg);
					
					} else if (siteCriteriaObjArg.filter.containsIgnoreCase('managing')){
						logger.logdebug('SiteDataServer.getSitesAllManagingSites()----');
						listOfSiteWrapper = siteContentProviderObj.getSitesAllManagingSites(siteCriteriaObjArg);
				
					} else if (siteCriteriaObjArg.filter.containsIgnoreCase('following')) {
						logger.logdebug('SiteDataServer.getAllSitesBelongsAsFollower()----');
						listOfSiteWrapper = siteContentProviderObj.getAllSitesBelongsAsFollower(siteCriteriaObjArg);
					
					} else if (siteCriteriaObjArg.filter.containsIgnoreCase('members') || siteCriteriaObjArg.filter.containsIgnoreCase('member')) {
						logger.logdebug('SiteDataServer.getAllSitesBelongsAsMember()----');
						listOfSiteWrapper = siteContentProviderObj.getAllSitesBelongsAsMember(siteCriteriaObjArg);
					
					} else if(siteCriteriaObjArg.filter.containsIgnoreCase('contributed')) {
						logger.logdebug('SiteDataServer.getSitesSearchResultsManagedByLoggedInUser()----');
						listOfSiteWrapper = siteContentProviderObj.getSitesSearchResultsManagedByLoggedInUser(siteCriteriaObjArg);
					} else {
							listOfSiteWrapper = siteContentProviderObj.getSitesAllSites(siteCriteriaObjArg);
					
					}
					
				} else {
					logger.logdebug('SiteDataServer.getSitesAllSites()----');
					listOfSiteWrapper = siteContentProviderObj.getSitesAllSites(siteCriteriaObjArg);
				
				}
				paginationObj.listOfItems.addAll(listOfSiteWrapper);
				if (paginationObj.listOfItems.size() == (pageSize + 1) &&
						siteCriteriaObjArg.offset < 2000) {
					paginationObj.listOfItems.remove((paginationObj.listOfItems.size()-1));
					paginationObj.nextPageToken = String.valueOf(siteCriteriaObjArg.offset + pageSize);
					
				} else {
					paginationObj.nextPageToken = null;
				}
			}				
				

        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, paginationObj);
	    	
		} catch(Exception e) {
        	logger.logError(e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
    	
		return responseToReturn;
	}
	
	
	@TestVisible private ResponseWrapper getsiteDetailData(String siteId, String chatterGroupId){
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{	
			SiteContentProvider scpObj = new SiteContentProvider();
			SiteDetailWrapper wrapperObj= scpObj.getsiteDetailData(siteId, chatterGroupId);	
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
			
		} catch(Exception e) {
			logger.logError('SiteDataServer.getsiteDetailData() --- Exception occured ---', e);
        	
        	if(SiteContext.showInSimpplr == false) {
	        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        		responseWrapperObj.redirectUrl = SimpplrContext.salesforceBaseUrl + '/'+SiteContext.chatterGroupId;
        	} else {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        	}
        }
        return responseWrapperObj;
	}
	
    @TestVisible 
    private ResponseWrapper createSite(String requestData) {
    	Savepoint sp = Database.setSavepoint();
    	ResponseWrapper responseWrapperObj = new ResponseWrapper();
		ConnectApi.Photo image;
		String contentVersionId;
		List<ContentDocument> contentDocument = new List<ContentDocument>();
		try{
			if (!userContext.canCreateOrOwnGroups) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			SiteDetailWrapper siteCreateWrapper = (SiteDetailWrapper)JSON.deserialize(requestData, SiteDetailWrapper.class);
	    	if(siteCreateWrapper != null) {
		    	String categoryId = null;
		    	SiteDetailWrapper.Category categoryObj = siteCreateWrapper.category;
		    	if(categoryObj != null) {
			    	Site_Category__c siteCategoryObj;
			    	
			    	String categoryNameToBeInserted = categoryObj.name.trim();
			    	categoryId = categoryObj.id;
			    	
			    	// if new category being added before assigning it to site.
					if (String.isBlank(categoryId) && String.isNotBlank(categoryNameToBeInserted)) {
						if(categoryNameToBeInserted.length() > 40){
							throw new SimpplrException('Category name can not be more than 40 characters');
						}
						Map<String, Object> soqlParamMap = new Map<String, Object>();
						soqlParamMap.put('soqlParam1', categoryNameToBeInserted);
						String query = 'SELECT Id, Name__c, access__c FROM Site_Category__c WHERE Name__c =:soqlParam1 AND Is_Deleted__c = false';
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						List<Site_Category__c> listOfCategories = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
				    	if(!listOfCategories.isEmpty()){
				    		if(!UserContext.isUserAppModerator && 'app_manager'.equalsIgnoreCase(listOfCategories[0].access__c)){
				    			throw new SimpplrException('Insufficient permissions to access this category.');
				    		}
				    		categoryId = listOfCategories[0].Id;
				    	} else{
				    		CategoryDao catDaoObj = new CategoryDao();
							siteCategoryObj = catDaoObj.addSiteCategory(categoryNameToBeInserted);
							categoryId = siteCategoryObj.Id;
				    	}
					}
		    	}
		    	
		    	Utility.IsSiteCreationFromSimpplrUI = true;
		    	CollaborationGroup colGroup = new CollaborationGroup();
		    	SiteDao siteDao =  new SiteDao();
	    		colGroup.Name = siteCreateWrapper.name;
	    		colGroup.Description = siteCreateWrapper.description;
	    		colGroup.CollaborationType  = siteCreateWrapper.access;
	    		colGroup.IsBroadcast  = siteCreateWrapper.isBroadcast == true ? true : false;
	    		
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				sObject colGroupSobj = SIMPESAPI.accessController().insertAsUser(colGroup, new List<Schema.SObjectField>{
					CollaborationGroup.Name,
					CollaborationGroup.Description,
					CollaborationGroup.CollaborationType,
					CollaborationGroup.IsBroadcast
				});
				colGroup = (CollaborationGroup) colGroupSobj;
	    		
    			Utility.IsSiteCreationFromSimpplrUI = false;
    			
    			Simpplr_Site__c siteObj = new Simpplr_Site__c();
    			siteObj.Allow_Public_Contribution__c = siteCreateWrapper.isContentSubmissionsEnabled;
    			siteObj.Name = siteCreateWrapper.name;
	        	siteObj.Chatter_Group_Id__c = colGroup.id;
				siteObj.Site_Category__c = categoryId;
				siteObj.Site_Type__c = siteCreateWrapper.access;
				siteObj.Has_Albums__c = siteCreateWrapper.hasAlbums == true ? true : false;
				siteObj.Has_Events__c = siteCreateWrapper.hasEvents == true ? true : false;
				siteObj.Has_Pages__c = siteCreateWrapper.hasPages == true ? true : false;
				siteObj.Is_Content_Unfurl_Enabled__c = siteCreateWrapper.isContentUnfurlEnabled;

				List<Schema.SObjectField> siteSchemaFieldList = new List<Schema.SObjectField>{
					Simpplr_Site__c.Allow_Public_Contribution__c,
					Simpplr_Site__c.Name,
					Simpplr_Site__c.Chatter_Group_Id__c,
					Simpplr_Site__c.Site_Category__c,
					Simpplr_Site__c.Site_Type__c,
					Simpplr_Site__c.Has_Albums__c,
					Simpplr_Site__c.Has_Events__c,
					Simpplr_Site__c.Has_Pages__c,
					Simpplr_Site__c.Is_Membership_Auto_Approved__c,
					Simpplr_Site__c.Origin__c,
					Simpplr_Site__c.Is_Active__c,
					Simpplr_Site__c.Landing_Page__c,
					Simpplr_Site__c.Show_In_Simpplr__c,
					Simpplr_Site__c.Last_Edited_DateTime__c,
					Simpplr_Site__c.Is_Content_Unfurl_Enabled__c
				};

				if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteCreateWrapper.access)) {
					siteObj.Is_Membership_Auto_Approved__c =  siteCreateWrapper.isMembershipAutoApproved == true ? true : false;
				} else {
					siteObj.Is_Membership_Auto_Approved__c = false;
				}
				siteObj.Landing_Page__c = siteCreateWrapper.landingPage;
				if(SimpplrContext.isQuestionAnswerEnabled) {
					siteObj.Question_Answer_Enabled__c = siteCreateWrapper.isQuestionAnswerEnabled;
					siteSchemaFieldList.add(Simpplr_Site__c.Question_Answer_Enabled__c);
				}
				siteObj.Origin__c = 'Simpplr';
				siteObj.Is_Active__c = true;
				siteObj.Show_In_Simpplr__c = true;
				siteObj.Last_Edited_DateTime__c = DateTime.now();
				if(SimpplrContext.isNativeVideo) {
					siteObj.Video_Provider_Sync_Status__c = 1;
					siteSchemaFieldList.add(Simpplr_Site__c.Video_Provider_Sync_Status__c);
				}
 			
				// Insert site record
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				sObject obj = SIMPESAPI.accessController().insertAsUser(siteObj, siteSchemaFieldList);
				siteObj = (Simpplr_Site__c) obj;

				// Insert site-role record
				List<Site_Role__c> siteRoleList = [SELECT Id from Site_Role__c WHERE Site__c = :siteObj.Id AND People__c = :UserContext.peopleId];
				if(siteRoleList.isEmpty()) {
					Site_Role__c siteRoleObj = new Site_Role__c();
					siteRoleObj.Site__c = siteObj.Id;
					siteRoleObj.People__c = UserContext.peopleId;
					siteRoleObj.User__c = UserContext.userId;
					siteRoleObj.Is_Manager__c = true;
					siteRoleObj.Is_Member__c = true;
					// As, this will get sync to NV provider in createCategoryForSite call
					if(SimpplrContext.isNativeVideo || Test.isRunningTest()) {
						siteRoleObj.Video_Provider_Sync_Status__c = 1;
					} else {
						siteRoleObj.Video_Provider_Sync_Status__c = 0;
					}
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().insertAsUser(siteRoleObj, new List<Schema.SObjectField>{
						Site_Role__c.Site__c,
						Site_Role__c.People__c,
						Site_Role__c.User__c,
						Site_Role__c.Is_Manager__c,
						Site_Role__c.Is_Member__c,
						Site_Role__c.Video_Provider_Sync_Status__c
					});
				}
				
				//create System Folders (excluding gdrive/dropbox/crm/box)
				siteDao.createSystemFolders(new List<Simpplr_Site__c>{siteObj});
				
				// set default storage provider for site if its blank
				if(String.isBlank(siteCreateWrapper.storageProvider)) {
					siteCreateWrapper.storageProvider = 'intranet';
				}
				
				SiteService service = new SiteService();
				service.saveSiteStorageConfig(siteObj.Id, siteCreateWrapper.dropboxRootPermission, null, siteCreateWrapper.storageProvider);
				
				SiteContentProvider scpObj = new SiteContentProvider();
				SiteDetailWrapper wrapperObj = scpObj.getsiteDetailData(siteObj.Id, null);
				if(SimpplrContext.isNativeVideo) {
					VideoDao.createCategoryForSite(siteObj.Id, siteCreateWrapper.name, siteCreateWrapper.access);
				}
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
				responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.Id + '/dashboard';
	    	}	    	
        }catch(Exception e){
        	logger.logError('SiteDataServer.createSite() --- Exception occured ---', e);
        	Database.rollback(sp);        	
        	if(String.isNotBlank(e.getMessage())) {
	        	if(e.getMessage().containsIgnoreCase('STORAGE_LIMIT_EXCEEDED')) {
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_STORAGE_FULL, null);
	        	}
	        	else if(e.getMessage().containsIgnoreCase('DUPLICATE_VALUE') || e.getMessage().containsIgnoreCase(STR_KEY_SITE_DUPLICATE_NAME_NOT_ALLOWED)) {
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_MANAGE_SITE_DUPLICATE, null);
	        	}
	        	else if(e.getMessage().containsIgnoreCase('Maximum per user active group limit reached')) {
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_SITE_PER_USER_LIMIT_EXCEEDED, null);
	        	}
	        	else {
	            	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
	        	}
        	}
        	else {
            	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.UNEXPECTED_ERROR, null);
        	}
        }
        return responseWrapperObj;
    }

	private ResponseWrapper createDuplicate(String requestData) {
		Savepoint sp = Database.setSavepoint();
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{
			if (!UserContext.canCreateOrOwnGroups) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			SiteDao siteDao = new siteDao();
			CategoryDao categoryDao = new CategoryDao();
			TileService tileService = new TileService();

			SiteWrapper.DuplicateSite duplicateSiteWrap = (SiteWrapper.DuplicateSite)JSON.deserialize(requestData, SiteWrapper.DuplicateSite.class);

            String originalSiteId = duplicateSiteWrap.siteId;

			List<Simpplr_Site__c> originalSiteList = [SELECT Id,
													       Name,
													       Chatter_Group_Id__c,
													       Site_Category__c,
													       Site_Type__c,
													       Has_Albums__c,
													       Has_Events__c,
													       Has_Pages__c,
													       Is_Membership_Auto_Approved__c,
													       Landing_Page__c,
													       Origin__c,
													       Is_Active__c,
													       Show_In_Simpplr__c,
													       Last_Edited_Datetime__c,
													       File_Storage_Source__c,
													       Allow_Comments__c,
													       Layout__c,
														   Carousel_Layout__c,
													       Allow_Public_Contribution__c,
													       Title_Content_Version__c,
													       Title_Content_Document__c,
													       Cover_Content_Version__c,
													       Cover_Content_Document__c
													FROM   Simpplr_Site__c
													WHERE  Id =: originalSiteId
													       AND Is_Active__c = TRUE
													       AND Is_Deleted__c = FALSE
													       AND Show_In_Simpplr__c = TRUE 
														   WITH SECURITY_ENFORCED];

            if (originalSiteList.size() == 0) {
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }

            Simpplr_Site__c originalSiteObj = originalSiteList[0];  
            Simpplr_Site__c duplicateSiteObj = saveDuplicateSite(originalSiteObj, duplicateSiteWrap.shouldCopyDashboard);

			String duplicateSiteId = duplicateSiteObj.id;
            siteDao.assignSiteRoles(duplicateSiteObj.id, userContext.Id, 'manager', false, true);
            siteDao.createSystemFolders(new List<Simpplr_Site__c>{duplicateSiteObj});

			if(duplicateSiteWrap.shouldCopyPageCategories) {
				categoryDao.duplicatePageCategory(originalSiteId, duplicateSiteId);
			}

			if(duplicateSiteWrap.shouldCopyDashboard) {
				tileService.duplicateSiteDashboardTiles(originalSiteId, duplicateSiteId);
			}

			SiteContentProvider scpObj = new SiteContentProvider();
			SiteDetailWrapper wrapperObj = scpObj.getsiteDetailData(duplicateSiteId, null);
			wrapperObj.isNew = true;
			wrapperObj.peopleCount = 1;

			if(SimpplrContext.isNativeVideo) {
				VideoDao.createCategoryForSite(duplicateSiteObj.Id, duplicateSiteObj.Name, duplicateSiteObj.Site_Type__c);
			}
	
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
			responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + duplicateSiteObj.Id + '/dashboard';	    	
        }catch(Exception e){
        	logger.logError('SiteDataServer.createSite() --- Exception occured ---', e);
        	Database.rollback(sp);        	
        	if(String.isNotBlank(e.getMessage())) {
	        	if(e.getMessage().containsIgnoreCase('STORAGE_LIMIT_EXCEEDED')) {
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_STORAGE_FULL, null);
	        	}
	        	else if(e.getMessage().containsIgnoreCase('DUPLICATE_VALUE')) {
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_MANAGE_SITE_DUPLICATE, null);
	        	}
	        	else if(e.getMessage().containsIgnoreCase('Maximum per user active group limit reached')) {
	        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_SITE_PER_USER_LIMIT_EXCEEDED, null);
	        	}
	        	else {
	            	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
	        	}
        	}
        	else {
            	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ServiceConstants.UNEXPECTED_ERROR, null);
        	}
        }
        return responseWrapperObj;
    }
    
    /**
     * @description site clone
     * @param originalSiteObj - original site record
     * @param shouldCopyDashboard - flag to copy dashboard from UI
     * @return cloned site record
     */
    public Simpplr_Site__c saveDuplicateSite(Simpplr_site__c originalSiteObj, Boolean shouldCopyDashboard) {
		String originalCollabId = originalSiteObj.Chatter_Group_Id__c;
        String originalSiteCategory = originalSiteObj.Site_Category__c;
		String originalSiteName = originalSiteObj.Name;
		String originalSiteId = originalSiteObj.Id;

        Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', originalSiteCategory);
		String query = 'SELECT Id, Name__c, Access__c FROM Site_Category__c WHERE Id =:soqlParam1 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Category__c> listOfCategories = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        String newSiteCategoryId;  
        if(!listOfCategories.isEmpty()){
            if(!UserContext.isUserAppModerator && 'app_manager'.equalsIgnoreCase(listOfCategories[0].access__c)){
                Map<String, Object> soqlParamMap1 = new Map<String, Object>();
                soqlParamMap1.put('soqlParam1', 'Uncategorized');
                query = 'SELECT Id, Name__c, Access__c FROM Site_Category__c WHERE Name__c LIKE :soqlParam1 AND Is_Deleted__c = false';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<Site_Category__c> listOfUncategorizedCategory = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap1);                  
                newSiteCategoryId = listOfUncategorizedCategory[0].id;
            }else{
                newSiteCategoryId = listOfCategories[0].Id;
            }
        }
		
        List<CollaborationGroup> originalCollabGrpList = [SELECT Id, Description, isBroadcast, InformationBody, InformationTitle FROM CollaborationGroup WHERE Id =: originalCollabId WITH SECURITY_ENFORCED];                       
        SiteDao siteDao =  new SiteDao();
        String duplicateSiteName = siteDao.getDuplicateSiteName(originalSiteName);

        Utility.IsSiteCreationFromSimpplrUI = true;

        CollaborationGroup colGroup = new CollaborationGroup();
        colGroup.Name = duplicateSiteName;
        //COPY ONLY IF SITE ABOUT TILE IS DUPLICATED
		if(shouldCopyDashboard == true) {
			Map<String, Object> soqlParamMap1 = new Map<String, Object>();
			soqlParamMap1.put('soqlParam1', originalSiteId);
			String tileConfigQuery = 'SELECT Id, Type__c FROM Tiles_Config__c '+
									' WHERE Type__c IN (\'site_about\', \'site_info\') AND Is_Active__c = true '+
									' AND Site__c =: soqlParam1 AND Is_deleted__c = false ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Tiles_Config__c> tileConfigList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(tileConfigQuery, soqlParamMap1);

			if(tileConfigList != null && !tileConfigList.isEmpty()) {
				for(Tiles_Config__c tileConfig: tileConfigList){
					if(tileConfig.Type__c == 'site_about'){
						colGroup.Description = originalCollabGrpList[0].description;
					}
					if(tileConfig.Type__c == 'site_info'){
						colGroup.InformationBody = originalCollabGrpList[0].InformationBody;
						colGroup.InformationTitle = originalCollabGrpList[0].InformationTitle;
					}
				}
			}
		}
        colGroup.CollaborationType  = originalSiteObj.Site_Type__c;
        colGroup.IsBroadcast  = originalCollabGrpList[0].isBroadcast;

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		colGroup = (CollaborationGroup) SIMPESAPI.accessController().insertAsUser(colGroup, new List<Schema.SObjectField>{
			CollaborationGroup.Name,
			CollaborationGroup.Description,
			CollaborationGroup.InformationBody,
			CollaborationGroup.InformationTitle,
			CollaborationGroup.CollaborationType,
			CollaborationGroup.IsBroadcast
		});
	    		
        Utility.IsSiteCreationFromSimpplrUI = false;

		List<Schema.SObjectField> siteSchemaFieldList = new List<Schema.SObjectField>{
			Simpplr_Site__c.Allow_Public_Contribution__c,
			Simpplr_Site__c.Name,
			Simpplr_Site__c.Chatter_Group_Id__c,
			Simpplr_Site__c.Site_Category__c,
			Simpplr_Site__c.Site_Type__c,
			Simpplr_Site__c.Has_Albums__c,
			Simpplr_Site__c.Has_Events__c,
			Simpplr_Site__c.Has_Pages__c,
			Simpplr_Site__c.Is_Membership_Auto_Approved__c,
			Simpplr_Site__c.Origin__c,
			Simpplr_Site__c.Is_Active__c,
			Simpplr_Site__c.Landing_Page__c,
			Simpplr_Site__c.Show_In_Simpplr__c,
			Simpplr_Site__c.Last_Edited_DateTime__c,
			Simpplr_Site__c.Carousel_Layout__c,
			Simpplr_Site__c.Layout__c,
			Simpplr_Site__c.Allow_Comments__c,
			Simpplr_Site__c.File_Storage_Source__c
		};
        // create simpplr site		
        Simpplr_Site__c siteObj = new Simpplr_Site__c();
        siteObj.Allow_Public_Contribution__c = originalSiteObj.Allow_Public_Contribution__c;
        siteObj.Name = duplicateSiteName;
        siteObj.Chatter_Group_Id__c = colGroup.Id;
        siteObj.Site_Category__c = newSiteCategoryId;
        siteObj.Site_Type__c = originalSiteObj.Site_Type__c;
        siteObj.Has_Albums__c = originalSiteObj.Has_Albums__c;
        siteObj.Has_Events__c = originalSiteObj.Has_Events__c;
        siteObj.Has_Pages__c = originalSiteObj.Has_Pages__c;
        siteObj.Is_Membership_Auto_Approved__c = originalSiteObj.Is_Membership_Auto_Approved__c;
        siteObj.Landing_Page__c = originalSiteObj.Landing_Page__c;
        siteObj.Origin__c = 'Simpplr';
        siteObj.Is_Active__c = true;
        siteObj.Show_In_Simpplr__c = true;
        siteObj.File_Storage_Source__c = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
        siteObj.Last_Edited_DateTime__c = DateTime.now();
        siteObj.Allow_Comments__c = originalSiteObj.Allow_Comments__c;

        if(shouldCopyDashboard == true){
        	siteObj.Layout__c = originalSiteObj.Layout__c;
    	}else{
    		siteObj.Layout__c = SimpplrContext.isFeedEnabled ? 'e' : 'd';
    	}

		siteObj.Carousel_Layout__c = originalSiteObj.Carousel_Layout__c;
		if(SimpplrContext.isNativeVideo) {
			siteObj.Video_Provider_Sync_Status__c = 1;
			siteSchemaFieldList.add(Simpplr_Site__c.Video_Provider_Sync_Status__c);
		}
        // create content version and content document for site cover image
		if(originalSiteObj.Cover_Content_Version__c != null 
			&& originalSiteObj.Cover_Content_Document__c != null) {
				siteDao.duplicateSiteCover(originalSiteObj, siteObj);
		}
		// Insert site record
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		siteObj = (Simpplr_Site__c) SIMPESAPI.accessController().insertAsUser(siteObj, siteSchemaFieldList);

        // content document link
        if(siteObj.Cover_Content_Version__c != null && siteObj.Cover_Content_Document__c != null) {
			siteDao.createCDLSiteCover(new List<Simpplr_Site__c>{siteObj}, false);
		}

        return siteObj;
	}
    
    public ResponseWrapper requestSiteMembership (String siteId){
		ResponseWrapper responseToReturn = null;
		try{
			List<Simpplr_Site__c> listOfRelatedSite= [select Name, Site_Type__c, Chatter_Group_Id__c, Is_Membership_Auto_Approved__c from Simpplr_Site__c where Id=:siteId limit 1];
            
            if (!listOfRelatedSite.isEmpty()) {
				
                if (ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(listOfRelatedSite[0].Site_Type__c)){
					Boolean createRequest = true;
					List<CollaborationGroupMember> collGrpMem = [Select MemberId, CollaborationRole, CollaborationGroupId From CollaborationGroupMember Where MemberId =:UserContext.UserId AND CollaborationGroupId=:listOfRelatedSite[0].Chatter_Group_Id__c];
                    
                    if (collGrpMem.isEmpty() == false) {
						responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 'DUPLICATE_VALUE', null);	
						createRequest = false;
                    } 
                    
					if (createRequest) {
						CollaborationGroupMemberRequest cGMRObj= new CollaborationGroupMemberRequest();
						cGMRObj.CollaborationGroupId=listOfRelatedSite[0].Chatter_Group_Id__c;
						cGMRObj.RequesterId=UserContext.id;
						CollaborationGroupMemberRequest requestObj = (CollaborationGroupMemberRequest)SIMPESAPI.accessController().insertAsUser(cGMRObj,
							new List<Schema.SObjectField>{CollaborationGroupMemberRequest.CollaborationGroupId,
															CollaborationGroupMemberRequest.RequesterId});
						SiteDao siteDaoObj = new SiteDao();
						Set<Id> listOfAdminUsers = siteDaoObj.getSiteManagerIdsSet(siteId);
						List<People__c> listOfSiteAdmins  = [select id from People__c where User__r.isActive = true and user__c =:listOfAdminUsers];
						NotificationDispatcher.sendPrivateSiteRequestNotification(requestObj.id, siteId, listOfRelatedSite[0].Name, listOfSiteAdmins);
                        
                        Site_Membership_Request__c msRquestRecord = new Site_Membership_Request__c();
                        msRquestRecord.Status__c = 'Pending';
                        msRquestRecord.Request_By__c = Usercontext.peopleId;
						msRquestRecord.User__c = UserContext.userId;
                        msRquestRecord.Site__c = siteId;
                        msRquestRecord.Request_DateTime__c = DateTime.Now();
                        msRquestRecord.CollaborationGroupMemberRequest_Id__c = requestObj.id; 
                        Database.SaveResult sr = Database.insert(msRquestRecord, false);
                        String requestId;

                        if (sr.isSuccess()){
                            requestId = sr.getId();

                        }
                        
                        logger.logDebug('Private membership request:>'+ requestId);

                        if (SimpplrContext.enableEmail) { 
							NotificationDispatcher.sendPrivateSiteRequestNotificationEmail(requestObj.id, siteId, listOfRelatedSite[0].Name, listOfAdminUsers);
                        }
                        
						responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
                    }
                    
				} else if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(listOfRelatedSite[0].Site_Type__c)){
					SiteDao siteDaoObj = new SiteDao();					
					if(listOfRelatedSite[0].Is_Membership_Auto_Approved__c){
						Boolean isSiteMember = siteDaoObj.makeSiteMember(listOfRelatedSite[0]);
						if(isSiteMember){
							SiteDetailWrapper.MembershipRequestsWrapper membershipReqWrapper = new SiteDetailWrapper.MembershipRequestsWrapper();
							membershipReqWrapper.isMembershipAutoApproved = true;
							responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, membershipReqWrapper);
						} else {
							responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
						}
					} else {
						String requestId = siteDaoObj.requestMembership(siteId);
						if(String.isNotBlank(requestId)){ 
							Set<Id> listOfAdminUsers = siteDaoObj.getSiteManagerIdsSet(siteId);
							List<People__c> listOfSiteAdmins  = [select id from People__c where User__r.isActive = true and user__c =:listOfAdminUsers];
							NotificationDispatcher.sendPublicSiteRequestNotification(requestId, siteId, listOfRelatedSite[0].Name, listOfSiteAdmins);
							if(SimpplrContext.enableEmail){
								NotificationDispatcher.sendPrivateSiteRequestNotificationEmail(requestId, siteId, listOfRelatedSite[0].Name, listOfAdminUsers);
							}
							responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
						} else {
							responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
						}
					}
				}	
			} else {
				responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			}
		} catch(Exception e) {
        	logger.logError('SiteDataServer.requestSiteMembership()-----could not retrieve data----',e);
        	if(e.getMessage().containsIgnoreCase('Maximum per user active group limit reached')) {
	        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_SITE_PER_USER_LIMIT_EXCEEDED, null);
	        } else if(e.getMessage().containsIgnoreCase(ERROR_SITE_FOLLOW_ALREADY_REQUESTED)){
	        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);
	        }
	        
	        else {
        		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);
	        }
        }
    	
		return responseToReturn;
	}
	
	@TestVisible 
	private ResponseWrapper setSiteSequence(String requestData){
		ResponseWrapper responseWrapperObj = null;
		try{
        	SiteWrapper.SequenceWrapper sequenceObj =(SiteWrapper.SequenceWrapper)Json.deserialize(requestData, SiteWrapper.SequenceWrapper.class);
        	String segmentId = sequenceObj.segmentId;
        	List<String> listOfSiteIds=sequenceObj.idsArray;
        	if((UserContext.isUserAppModerator) || (UserContext.isSegmentManager && UserContext.segmentId == segmentId))  {
        		SiteDao siteDaoObj = new SiteDao(); 
        		siteDaoObj.setSiteSequence(segmentId, listOfSiteIds);
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        	}
        	else {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Insufficient privileges for drag/drop!', null);
        	}
        }catch(Exception e){
        	logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(e.getMessage()), null);
        }
        
        return responseWrapperObj;
	}
		
	@TestVisible 
	private ResponseWrapper revertToChatterGroup(String siteId){
		ResponseWrapper responseWrapperObj = null;
		try{
        	if(UserContext.isUserAppModerator) {
        		SiteDao siteDaoObj = new SiteDao();
        		String chatterGroupId = siteDaoObj.revertToChatterGroup(siteId);
        		SiteContentProvider providerObj = new SiteContentProvider();
        		ChatterGroupWrapper cgWrapperObj = providerObj.getChatterGroupDetails(chatterGroupId);
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, cgWrapperObj);
        	}
        	else {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 'Insufficient privileges!', null);
        	}
        }catch(Exception e){
        	logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(e.getMessage()), null);
        }
        
        return responseWrapperObj;
	}
	
	@TestVisible 
	private ResponseWrapper approveSubscription(String siteId, String subscriptionId){
		ResponseWrapper responseWrapperObj = null;
		try{
			if(siteId == null || subscriptionId == null){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			if(SiteContext.isCurrentUserSiteManager || (UserContext.isUserAppModerator && SiteContext.isPublicSite)) {
				// Do nothing
			} else if(SiteContext.isUnlistedSite == false && UserContext.hasModifyAllDataPermission) {
				// Do nothing
			} else if(SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission) {
				// Do nothing
			} else {
				throw new SimpplrException('Insufficient privileges !');
			}
			
        	SiteDao siteDaoObj = new SiteDao();
    		Subscription_Entity__c susbcriptionEntity = siteDaoObj.approveSubscription(siteId, subscriptionId);
    		
    		Map<String, String> batchParamMap = new Map<String, String>();
			batchParamMap.put('audienceId', susbcriptionEntity.Subscription__r.Audience__c);
			batchParamMap.put('subscriptionEntityId', susbcriptionEntity.id);
			
    		BatchProcessSubscription job = new BatchProcessSubscription('subscriptionApproved', batchParamMap);
    		Database.executeBatch(job, 200);
    		
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
        }catch(Exception e){
        	logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(e.getMessage()), null);
        }
        
        return responseWrapperObj;
	}
	
	@TestVisible 
	private ResponseWrapper rejectSubscription(String siteId, String subscriptionId){
		ResponseWrapper responseWrapperObj = null;
		try{
			if(siteId == null || subscriptionId == null){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			if(SiteContext.isCurrentUserSiteManager || (UserContext.isUserAppModerator && SiteContext.isPublicSite)) {
				// Do nothing
			} else if(SiteContext.isUnlistedSite == false && UserContext.hasModifyAllDataPermission) {
				// Do nothing
			} else if(SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission) {
				// Do nothing
			} else {
				throw new SimpplrException('Insufficient privileges !');
			}
			
    		SiteDao siteDaoObj = new SiteDao();
    		siteDaoObj.rejectSubscription(siteId, subscriptionId);
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
        }catch(Exception e){
        	logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(e.getMessage()), null);
        }
        
        return responseWrapperObj;
	}		
	
	
	@TestVisible 
	private ResponseWrapper approveMembershipRequest(String data){
		ResponseWrapper responseWrapperObj = null;
		try{
			String requestId;
			String 	siteType;
			String siteId;
			String siteName;
			Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(data);
			if(dataMap != null && dataMap.get('requestId') != null){
				requestId = (String)dataMap.get('requestId');
				siteType = (String)dataMap.get('siteType');
			}
			if(requestId == null ){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			SiteDao siteDaoObj = new SiteDao();
			Boolean status = false;
			if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)){
				status = siteDaoObj.approveMembershipRequest(requestId);
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', requestId);
				String query = 'SELECT Id, Request_By__c, User__c, Site__c, Site__r.Id, Site__r.Name, Status__c ' +
					' FROM Site_Membership_Request__c WHERE Id=:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Site_Membership_Request__c> membershipReqList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
				siteId = membershipReqList[0].Site__r.Id;
				siteName = membershipReqList[0].Site__r.Name;
				 
				status = true;
				Boolean sendApproveEmail = false;
				List<Ungrouped_Notification__c> ungroupedNotiList = [SELECT GUID__c from Ungrouped_Notification__c WHERE Object_Id__c = :requestId AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
				if(ungroupedNotiList.isEmpty() == false){
					SiteService.updateSiteRequestNotifications(ungroupedNotiList[0].GUID__c, siteId, siteName, 'public', STATUS_APPROVED, 'Request approved by ' + UserContext.id);
					sendApproveEmail = true;
				} else {
					List<App_Notification__c> appNotiList = [SELECT GUID__c 
                        FROM App_Notification__c 
                        WHERE Object_Id__c = :requestId WITH SECURITY_ENFORCED];

					if (appNotiList.isEmpty() == false && String.isNotBlank(appNotiList[0].GUID__c)) {
						generatePublicSiteRequestApproveNotifications(appNotiList[0].GUID__c, siteId, siteName, siteType, 'Request approved by ' + UserContext.id,STATUS_APPROVED);
						sendApproveEmail = true;
					}
				}
				if(sendApproveEmail == true) {
					NotificationDispatcher.sendPublicSiteRequestApprovalEmail(siteName, siteId, membershipReqList[0].Request_By__c);
					list<Simpplr_Content__c> onboardingObjList = [SELECT Id FROM Simpplr_Content__c WHERE Content_Onboarding_Status__c != 'none' AND Site__c = :siteId AND Is_Deleted__c = false AND Is_Published__c = true WITH SECURITY_ENFORCED];
					list<People__c> peopleList = [SELECT Id, Full_Name__c, Joining_Date__c FROM People__c WHERE Id = :membershipReqList[0].Request_By__c WITH SECURITY_ENFORCED];   
					if(SimpplrContext.isFeatureContentOnboardingEnabled && !onboardingObjList.isEmpty() && peopleList[0].Joining_Date__c != null && peopleList[0].Joining_Date__c.daysBetween(Date.today())<=30) {
						NotificationDispatcher.sendNewSiteOnboardingNotification(String.valueOf(siteId), siteName, peopleList);
					}
				}
			} else if(ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteType)){
				RequestApprovalDataServer radsObj = new RequestApprovalDataServer();
				List<CollaborationGroupMemberRequest> collabrationRequestList = [SELECT Id, CollaborationGroupId, RequesterId, Status, CreatedDate FROM CollaborationGroupMemberRequest where Id =: requestId WITH SECURITY_ENFORCED];
                Simpplr_Site__c siteObj = [SELECT Id, Name 
                        FROM Simpplr_Site__c 
                        WHERE chatter_group_id__c = :collabrationRequestList[0].CollaborationGroupId];
				siteId = siteObj.Id;
				siteName = siteObj.Name; 
				
				responseWrapperObj = radsObj.approvePrivateSiteMembershipRequest (requestId, siteId, siteName);
                status = true;
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', collabrationRequestList[0].RequesterId);
				soqlParamMap.put('soqlParam2', collabrationRequestList[0].CollaborationGroupId);
				String query = 'SELECT Id, Action_By__c, Site__c, Site__r.Chatter_Group_Id__c, User__c, Action_DateTime__c, Status__c, Request_By__c ' +
					' FROM Site_Membership_Request__c ' +
					' WHERE User__c =:soqlParam1 ' +
					' AND Site__r.Chatter_Group_Id__c =:soqlParam2 ' +
					' AND Is_Deleted__c = false AND Status__c =\'Pending\'';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Site_Membership_Request__c> msRequestList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
                
                if (!msRequestList.isEmpty() && status){
                    msRequestList[0].Status__c = 'Approved';
                    msRequestList[0].Action_By__c = Usercontext.peopleId;
                    msRequestList[0].Action_DateTime__c = DateTime.Now();
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().updateAsUser(msRequestList[0], new List<Schema.SObjectField>{
                        Site_Membership_Request__c.Status__c,
                        Site_Membership_Request__c.Action_By__c,
                        Site_Membership_Request__c.Action_DateTime__c
                    });

					List<App_Notification__c> appNotiList = [SELECT GUID__c FROM App_Notification__c WHERE Object_Id__c = :requestId WITH SECURITY_ENFORCED];
					if(appNotiList.isEmpty() == false){
						list<Simpplr_Content__c> onboardingObjList = [SELECT Id FROM Simpplr_Content__c WHERE Content_Onboarding_Status__c != 'none' AND Site__c = :siteId AND Is_Deleted__c = false AND Is_Published__c = true WITH SECURITY_ENFORCED];
						list<People__c> peopleList = [SELECT Id, Full_Name__c, Joining_Date__c FROM People__c WHERE Id = :msRequestList[0].Request_By__c WITH SECURITY_ENFORCED];   
						if(SimpplrContext.isFeatureContentOnboardingEnabled && !onboardingObjList.isEmpty() && peopleList[0].Joining_Date__c != null && peopleList[0].Joining_Date__c.daysBetween(Date.today())<=30 && SimpplrContext.isFeatureContentOnboardingEnabled) {
							NotificationDispatcher.sendNewSiteOnboardingNotification(String.valueOf(siteId), siteName, peopleList);
						}
                	}
				}
				 
			}

			if(status == true){
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
				
			} else {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
        }catch(Exception e){
        	logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(e.getMessage()), null);
        }
        
        return responseWrapperObj;
	}

	
	@TestVisible 
	private ResponseWrapper rejectMembershipRequest(String data){
		ResponseWrapper responseWrapperObj = null;
		try{
			String requestId;
			String siteType;
			String siteId;
			String siteName;
			Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(data);
			if(dataMap != null && dataMap.get('requestId') != null){
				requestId = (String)dataMap.get('requestId');
				siteType = (String)dataMap.get('siteType');
			}

			if(requestId == null){
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			SiteDao siteDaoObj = new SiteDao();
			Boolean status = true;
			if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', requestId);
				String query = 'SELECT Id, User__c, Site__c, Site__r.Id, Site__r.Name, Status__c FROM Site_Membership_Request__c WHERE Id=:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Site_Membership_Request__c> membershipReqList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
				siteId = membershipReqList[0].Site__r.Id;
				siteName = membershipReqList[0].Site__r.Name;
				
				status = siteDaoObj.rejectMembershipRequest(requestId);
				List<Ungrouped_Notification__c> ungroupedNotiList = [SELECT GUID__c from Ungrouped_Notification__c WHERE Object_Id__c = :requestId AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
				if(ungroupedNotiList.isEmpty() == false){
					SiteService.updateSiteRequestNotifications(ungroupedNotiList[0].GUID__c, siteId, siteName, 'public', STATUS_REJECTED, 'Request rejected by ' + UserContext.id);
				} else {
					List<App_Notification__c> appNotiList = [SELECT GUID__c 
                        FROM App_Notification__c 
                        WHERE Object_Id__c = :requestId WITH SECURITY_ENFORCED];

					if (appNotiList.isEmpty() == false && String.isNotBlank(appNotiList[0].GUID__c)) {
						updatePublicSiteRequestRejectNotifications(appNotiList[0].GUID__c, siteId, siteName, siteType, 'Request rejected by ' + UserContext.id, STATUS_REJECTED);
					}
				}
                
			} else if(ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteType)){
				RequestApprovalDataServer radsObj = new RequestApprovalDataServer();
                List<CollaborationGroupMemberRequest> collabrationRequestList = [SELECT Id, 
                        CollaborationGroupId, RequesterId, Status, CreatedDate 
                        FROM CollaborationGroupMemberRequest where Id =: requestId WITH SECURITY_ENFORCED];
                Simpplr_Site__c siteObj = [SELECT Id, Name 
                        FROM Simpplr_Site__c 
                        WHERE chatter_group_id__c = :collabrationRequestList[0].CollaborationGroupId WITH SECURITY_ENFORCED];
				siteId = siteObj.Id;
				siteName = siteObj.Name; 
                responseWrapperObj = radsObj.rejectPrivateSiteMembershipRequest(requestId, 
                        siteId, siteName);

				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', collabrationRequestList[0].RequesterId);
				soqlParamMap.put('soqlParam2', collabrationRequestList[0].CollaborationGroupId);
				String query = 'SELECT Id, Action_By__c, Site__c, Site__r.Chatter_Group_Id__c, User__c, Action_DateTime__c, Status__c ' +
					' FROM Site_Membership_Request__c ' +
					' WHERE User__c =:soqlParam1 ' +
					' AND Site__r.Chatter_Group_Id__c =:soqlParam2 ' +
					' AND Is_Deleted__c = false AND Status__c =\'Pending\'';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Site_Membership_Request__c> msRequestList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
                
                if (!msRequestList.isEmpty()){
                    msRequestList[0].Status__c = 'Rejected';
                    msRequestList[0].Action_By__c = Usercontext.peopleId;
                    msRequestList[0].Action_DateTime__c = DateTime.Now();
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().updateAsUser(msRequestList[0], new List<Schema.SObjectField>{
                        Site_Membership_Request__c.Status__c,
                        Site_Membership_Request__c.Action_By__c,
                        Site_Membership_Request__c.Action_DateTime__c
                    });
                }

			}
			
			if (status == true) {
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, true);
                
			} else {
				throw new SimpplrException(ServiceConstants.ERROR_403);
            }
            
    	} catch (Exception e) {
        	logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(e.getMessage()), null);
        }
        
        return responseWrapperObj;
	}

	private void updatePublicSiteRequestRejectNotifications(String guId, String siteId, String siteName, String siteType, String actionComment, String status) {
		try {
			List<App_Notification__c> listOfSN = NotificationDao.prepareActionNotifications(guId, actionComment, status);
			String parentId = ''; 
			String submitterId = '';
			String objType = '';
			String objId = '';
			for(App_Notification__c sn : listOfSN){
				if(UserContext.peopleId.equals(sn.Sent_to__c) || (siteType == 'Public' && (UserContext.hasModifyAllDataPermission || UserContext.isUserAppModerator)) || (siteType == 'Private' && UserContext.hasModifyAllDataPermission)){
					parentId = sn.id;
					submitterId = sn.Sent_By__c;
					objType = sn.Object_Type__c;
					objId = sn.Object_Id__c;
				}
			}
			
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_Read__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_On__c,
				App_Notification__c.Action_Comment__c,
				App_Notification__c.Status__c
			};
			
			NotificationDao.updateNotification(listOfSN, listOfColumnsToBeUpdated);
		}
		catch(Exception ex) {
			throw ex;
		}
	}

	private Map<String,App_Notification__c> generatePublicSiteRequestApproveNotifications(String guId, String siteId, String siteName, String siteType, String actionComment, String status) {
		try {
			List<App_Notification__c> listOfSN = NotificationDao.prepareActionNotifications(guId, actionComment, status);
			String parentId = ''; 
			String submitterId = '';
			String objType = '';
			String objId = '';
			for(App_Notification__c sn : listOfSN){
				if(UserContext.peopleId.equals(sn.Sent_to__c) || (siteType == 'Public' && (UserContext.hasModifyAllDataPermission || UserContext.isUserAppModerator)) || (siteType == 'Private' && UserContext.hasModifyAllDataPermission)){
					parentId = sn.id;
					submitterId = sn.Sent_By__c;
					objType = sn.Object_Type__c;
					objId = sn.Object_Id__c;
				}
			}

			App_Notification__c notificationObj = new App_Notification__c(Category__c='Public_Site_Membership_Response',Is_Read__c=false,type__c=NotificationDao.TYPE_INFORMATION, Sub_Type__c = 'Update',
			    Status__c=status,Object_Type__c=objType,Object_Id__c=objId,Sent_By__c=UserContext.peopleId, Simpplr_site__c = siteId,
				Sent_to__c=submitterId,Action_Comment__c=actionComment,	Action_By__c=UserContext.peopleId, Parent__c=parentId, Created_DateTime__c = DateTime.now(),
				Snippet__c = siteName);
			
			Map<String,App_Notification__c> userToNotificationMap = NotificationDao.createNotifications(new List<App_Notification__c>{notificationObj});
			
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_Read__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_On__c,
				App_Notification__c.Action_Comment__c,
				App_Notification__c.Status__c
			};

			NotificationDao.updateNotification(listOfSN, listOfColumnsToBeUpdated);
			return userToNotificationMap;
		}
		catch(Exception ex) {
			throw ex;
		}
	}
    
}