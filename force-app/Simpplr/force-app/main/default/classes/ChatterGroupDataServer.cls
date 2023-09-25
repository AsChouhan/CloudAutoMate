/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
	
public with sharing class ChatterGroupDataServer extends DataServer{
	
	private final String ACTION_VALUE_SEARCH = 'search';
    private final String CREATE_SITE = 'createSite';
    private Final String ACTION_VALUE_REQUEST_CONVERT_TO_SITE = 'convertToSite';
    
    private final String REQUEST_PARAM_DATA = 'data';
    private final String REQUEST_PARAM_CHATTERGROUP_ID = 'chatterGroupId';
    
    public ChatterGroupDataServer() {

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
        	
        	logger.logDebug('ChatterGroupDataServer----entered handleRequest----');
        	
        	String action = readParam(REQUEST_PARAM_ACTION);
            
            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
        		response = getChatterGroups(readParam(REQUEST_PARAM_DATA));	
	        	
            } else if (ACTION_VALUE_REQUEST_CONVERT_TO_SITE.equalsIgnoreCase(action)){
            	response = convertToSite(readParam(REQUEST_PARAM_CHATTERGROUP_ID));
            }else {
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
    
        } catch (Exception ex) {
        	logger.logError(ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
    } 
    
    /**
	 * @api {post} /apex/DataServerRW?target=ChatterGroupDataServer&action=getChatterGroups getChatterGroups
	 * @apiVersion 1.0.0
	 * @apiGroup ChatterGroupDataServer
	 * @apiName getChatterGroups
	 *
	 * @apiParam (Query Parameter) {String} action getChatterGroups
	 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#chatterGroup-chatterGroup.getChatterGroups" target="_blank">chatterGroup-chatterGroup.search</a> 
	 *
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.ChatterGroup.search
	 * 2. This is used to get ChatterGroup List
	 * 
	 * @apiSuccess {ChatterGroupWrapper.PaginationWrapper} result contains ChatterGroupWrapper.PaginationWrapper
	 * @apiUse ChatterGroupWrapperWITHIC
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */
    @TestVisible 
	public ResponseWrapper getChatterGroups(String requestData) {
		logger.logdebug('ChatterGroupDataServer.getChatterGroups()---'+requestData);
		SiteContentProvider siteContentProviderObj = new SiteContentProvider(); 
		Criteria.ChatterGroup chatterGroupCriteriaObj = (Criteria.ChatterGroup)JSON.deserialize(requestData, Criteria.ChatterGroup.class);
		ResponseWrapper responseToReturn = null;
		List<ChatterGroupWrapper> listOfChatterGroupWrapper = new List<ChatterGroupWrapper>();
		Integer pageSize = 0;
		
		try{
			pageSize = chatterGroupCriteriaObj.size != null ? chatterGroupCriteriaObj.size : SimpplrContext.simpplrDefaultPageSize;
			chatterGroupCriteriaObj.size = pageSize;
			
			if (chatterGroupCriteriaObj.nextPageToken == null) {
    			chatterGroupCriteriaObj.offset = 0;
    		} else {
    			chatterGroupCriteriaObj.offset = Integer.valueOf(chatterGroupCriteriaObj.nextPageToken);
    		}
	        
    		String searchTerm = '';
			
			if(String.isNotBlank(chatterGroupCriteriaObj.term)){
				searchterm =  '%' + chatterGroupCriteriaObj.term + '%';
			} else {
				searchterm = '%%';
			}
    		
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotBlank(chatterGroupCriteriaObj.term)) {
				Criteria.ExternalSearchReq chatterSearchCriteria = new Criteria.ExternalSearchReq();
					
				chatterSearchCriteria.size = chatterGroupCriteriaObj.size;
				chatterSearchCriteria.term = chatterGroupCriteriaObj.term;

				String searchForType = 'Chatter_Group';

				ExternalSearchService externalSearchServiceObj = new ExternalSearchService();
				ExternalSearchWrapper.TopContentsWrapper externalSearchResponse = new ExternalSearchWrapper.TopContentsWrapper();
				externalSearchResponse = externalSearchServiceObj.searchChatterGroups(chatterSearchCriteria, searchForType);

				listOfChatterGroupWrapper = convertToChatterGrpWrapper(externalSearchResponse.listOfItems);
			} else {
				listOfChatterGroupWrapper = siteContentProviderObj.getChatterGroups(chatterGroupCriteriaObj);
			}
			
	    	ChatterGroupWrapper.PaginationWrapper paginationObj = new ChatterGroupWrapper.PaginationWrapper();
        	paginationObj.listOfItems.addAll(listOfChatterGroupWrapper);
        	
        	if (paginationObj.listOfItems.size() == (pageSize + 1) &&
	        		chatterGroupCriteriaObj.offset < 2000) {
	        	paginationObj.listOfItems.remove((paginationObj.listOfItems.size()-1));
	        	paginationObj.nextPageToken = String.valueOf(chatterGroupCriteriaObj.offset + pageSize);
	        } else {
	        	paginationObj.nextPageToken = null;
	        }
	        
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Chatter Group list returned successfully!', paginationObj);
	    	
		} catch(Exception e) {
        	logger.logError(e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null);
        }
    	
		return responseToReturn;
	}
	
	private List<ChatterGroupWrapper> convertToChatterGrpWrapper(List<ExternalSearchWrapper.ItemWrapper> listOfItems) {
		List<ChatterGroupWrapper> chatterGrpWrapList = new List<ChatterGroupWrapper>();
		for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : listOfItems) {
			Object item = itemWrapperObj.item;

			SiteListingWrapper chatterSearchObj = (SiteListingWrapper)item;

			ChatterGroupWrapper chatterGrpWrapObj = new ChatterGroupWrapper();

			chatterGrpWrapObj.chatterGroupId = chatterSearchObj.chatterGroupId;
			chatterGrpWrapObj.name = chatterSearchObj.name;
			chatterGrpWrapObj.url = SimpplrContext.salesforceBaseUrl + '/' + chatterSearchObj.chatterGroupId;
			chatterGrpWrapObj.access = chatterSearchObj.access;
			chatterGrpWrapObj.memberCount = chatterSearchObj.memberCount;

			chatterGrpWrapList.add(chatterGrpWrapObj);
		}
		
	 	return chatterGrpWrapList;
	}

	/**
	 * @api {post} /apex/DataServerRW?target=ChatterGroupDataServer&action=convertToSite convertToSite
	 * @apiVersion 1.0.0
	 * @apiGroup ChatterGroupDataServer
	 * @apiName convertToSite
	 *
	 * @apiParam (Query Parameter) {String} action convertToSite
	 * @apiParam (Post Parameter) {String} data <a href="http://winter18d.simpplr.com/docs/build/#chatterGroup-chatterGroup.convertToSite" target="_blank">chatterGroup-chatterGroup.convertToSite</a> 
	 *
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.ChatterGroup.convertToSite
	 * 2. This is used to convert a chatter group to a site
	 * 
	 * @apiSuccess {SiteDetailWrapper} result Contain SiteDetailWrapper
	 * @apiUse SiteDetailWrapperWITHIC
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */	
	@TestVisible 
	private ResponseWrapper convertToSite(String chatterGroupId){
		ResponseWrapper responseWrapperObj = null;
		try{
        	if(UserContext.isUserAppModerator) {
        		SiteDao siteDaoObj = new SiteDao(); 
        		String siteId = siteDaoObj.convertToSite(chatterGroupId);
        		responseWrapperObj = getsiteDetailData(siteId);
				if(SimpplrContext.isNativeVideo) {
					SiteDetailWrapper sdWrapperObj = (SiteDetailWrapper)responseWrapperObj.result;
					PeopleDao peopleDaoObj = new PeopleDao();
					People__c siteOwnerPeopleRecord = peopleDaoObj.getPeopleByUserId(sdWrapperObj.ownerId)[0];
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', sdWrapperObj.ownerId);
					soqlParamMap.put('soqlParam2', sdWrapperObj.Id);
					String query = 'SELECT Id FROM Site_Role__c WHERE ' + 
									' User__c =: soqlParam1 AND Site__c =:  soqlParam2 LIMIT 1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<Site_Role__c> siteRoleList = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);	
					for(Site_Role__c siteRoleObj : siteRoleList){
						siteRoleObj.Video_Provider_Sync_Status__c = 1;
					}
					if(!siteRoleList.isEmpty()){
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id,Site_Role__c>(siteRoleList), new List<Schema.SObjectField>{
							Site_Role__c.Video_Provider_Sync_Status__c
						});
					}								
					VideoDao.createCategoryForCgToSite(sdWrapperObj.siteId, sdWrapperObj.name, sdWrapperObj.access, siteOwnerPeopleRecord.Id);
				}				
        	}
        	else {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        	}
        }catch(Exception e){
        	logger.logError(e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        
        return responseWrapperObj;
	}
	
	@testVisible private ResponseWrapper getsiteDetailData(String siteId) {
		ResponseWrapper responseToReturn = null;
		SiteDetailWrapper sdWrapperObj = new SiteDetailWrapper();
		String redirectUrl = '';
		List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
		try{  
			List<Simpplr_Site__c> listOfSimpplrSite = null;
			
			if (String.isBlank(siteId)) {
				throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
			
			} else {
				listOfSimpplrSite = [select id, name, Allow_Public_Contribution__c,Landing_Page__c, Has_Albums__c, Has_Events__c, Has_Pages__c, chatter_group_id__c, Site_Type__c, Is_Active__c,
						Is_Featured__c,Site_Category__c, Site_Category__r.Name__c, Allow_Comments__c,
						Title_Content_Version__c,Title_Content_Document__c,Show_In_Simpplr__c, 
						(select id from Bookmarked_Simpplr_Site__r where Simpplr_Site__c=:siteId and Type__c='Site' And Is_Deleted__c=false ),
						(select id from Simpplr_Content_Site__r 
						where is_published__c=true and is_deleted__c=false 
						and Activated_By_Feature__c=true and Type__c IN : allowedFeaturesInAppList limit 1) 
						from Simpplr_Site__c where id = :siteId WITH SECURITY_ENFORCED];
			}
			logger.logdebug('====listOfSimpplrSite===='+listOfSimpplrSite);
			if(!listOfSimpplrSite.isEmpty()){ 
				if(listOfSimpplrSite[0].Is_Active__c == false){
					throw new SimpplrException('It\'s not possible to perform this action - Site is not active');
			    } else if (listOfSimpplrSite[0].Show_In_Simpplr__c == false) {
			    	redirectUrl = SimpplrContext.salesforceBaseUrl + '/'+listOfSimpplrSite[0].chatter_group_id__c;
			    	throw new SimpplrException(ServiceConstants.ERROR_404);
				} else {	
			    		Simpplr_Site__c siteObj = listOfSimpplrSite[0];
					Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = Utility.getAllCollaborationGroupMapForSiteIds(new List<Id>{siteObj.chatter_group_id__c});
					CollaborationGroup collabGroup = mapOfIdWithCollaborationGrp.get(siteObj.Chatter_Group_Id__c);
					
					sdWrapperObj.id = siteObj.id;
					sdWrapperObj.siteId = siteObj.id;
					sdWrapperObj.title = siteObj.name;
					sdWrapperObj.name = siteObj.name;
					sdWrapperObj.access = siteObj.Site_Type__c;
					sdWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.Id + '/' + siteObj.Landing_Page__c;
					sdWrapperObj.editUrl = PageContext.getPageURL(Pages.app) +'?u=/manage/sites/' + siteObj.id;
					sdWrapperObj.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteObj.Site_Type__c) ? true : false;
					sdWrapperObj.isListed = ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteObj.Site_Type__c) ? false : true;
					sdWrapperObj.hasEvents = siteObj.Has_Events__c;
					sdWrapperObj.hasPages = siteObj.Has_Pages__c;
					sdWrapperObj.hasAlbums = siteObj.Has_Albums__c;
					
					sdWrapperObj.hasContent =  siteObj.Simpplr_Content_Site__r.size() > 0;
					sdWrapperObj.information = collabGroup.InformationBody;
					sdWrapperObj.description = collabGroup.description;
					sdWrapperObj.chatterGroupId = siteObj.chatter_group_id__c;
					sdWrapperObj.isMember = collabGroup.GroupMembers.isEmpty()?false:true;
					sdWrapperObj.isManager = (!collabGroup.GroupMembers.isEmpty() && 'Admin'.equalsIgnoreCase(collabGroup.GroupMembers[0].CollaborationRole)) ? true:false;
					
					Boolean hasContentCreationAccess = false;
					sdWrapperObj.isContentFeedEnabled = siteObj.Allow_Comments__c;
					hasContentCreationAccess = AccessManager.hasContentCreateAccess(sdWrapperObj.id, siteObj.Site_Type__c, siteObj.Allow_Public_Contribution__c, sdWrapperObj.isMember);
					sdWrapperObj.canCreatePage = (sdWrapperObj.hasPages && hasContentCreationAccess);
					sdWrapperObj.canCreateEvent = (sdWrapperObj.hasEvents && hasContentCreationAccess);
					sdWrapperObj.canCreateAlbum = (sdWrapperObj.hasAlbums && hasContentCreationAccess);
					
					sdWrapperObj.members = collabGroup.MemberCount;
					sdWrapperObj.isActive = siteObj.Is_Active__c;
					sdWrapperObj.isFavorited = siteObj.Bookmarked_Simpplr_Site__r.isEmpty()?false:true;
					sdWrapperObj.isFeatured = siteObj.Is_Featured__c;
					sdWrapperObj.isOwner = UserContext.id.equalsIgnoreCase(collabGroup.OwnerId);
					sdWrapperObj.isBroadcast = collabGroup.IsBroadcast;
					sdWrapperObj.ownerId = collabGroup.OwnerId;
					
					
					if((UserContext.hasModifyAllDataPermission && !'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c)) 
				 		|| (UserContext.isUserAppModerator && 'Public'.equalsIgnoreCase(siteObj.Site_Type__c))
				 		|| (UserContext.hasManageUnlistedSitePermission && 'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c))){
					 		sdWrapperObj.canEdit  = true;
				 	} else {
				 		sdWrapperObj.canEdit  = sdWrapperObj.isManager;
				 	}
				 	
				 	if((sdWrapperObj.canEdit) || ((UserContext.hasModifyAllDataPermission || UserContext.isUserAppModerator))){
					 	sdWrapperObj.canActivateDeactivate = true;
				 	} else {
				 		sdWrapperObj.canActivateDeactivate = false;
				 	}
					
					if(String.isNotBlank(siteObj.Site_Category__c)) {
						sdWrapperObj.category = new SiteDetailWrapper.Category();
				 		sdWrapperObj.category.id = siteObj.Site_Category__c;
				 		sdWrapperObj.category.name = siteObj.Site_Category__r.Name__c;
				 		sdWrapperObj.category.url = PageContext.getPageURL(Pages.app)+'?u=/sites/category&category=' + siteObj.Site_Category__c;
					}
					
					if(String.isNotBlank(siteObj.Title_Content_Document__c)) {
						String cvId = siteObj.Title_Content_Version__c;
						String cdId = siteObj.Title_Content_Document__c;
						
						sdWrapperObj.imgFile = new SiteDetailWrapper.FileWrapper();
						sdWrapperObj.imgFile.id = cdId;
						sdWrapperObj.imgFile.thumbnailImg = Utility.getFileDownloadURLFor240BY180(cvId);
						sdWrapperObj.imgFile.url = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => cdId, 'siteId' => siteId});
						sdWrapperObj.imgFile.fileUrl = Utility.getFileDownloadURL(cvId);
						sdWrapperObj.imgFile.downloadUrl = Utility.getFileDowloadRelativeURL(cvId);
                        sdWrapperObj.img = sdWrapperObj.imgFile.thumbnailImg;
					}
				}
			}	
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Site details returned successfully!', sdWrapperObj);
	    	
		} catch(Exception e) {
        	logger.logError(e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        	
        	if(String.isNotBlank(redirectUrl)) {
        		responseToReturn.redirectUrl = redirectUrl;
        	}
        }
    	
		return responseToReturn;
	}
    
}