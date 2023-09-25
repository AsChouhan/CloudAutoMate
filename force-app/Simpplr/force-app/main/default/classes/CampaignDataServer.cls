public with sharing class CampaignDataServer extends DataServer{
    
    private final String ACTION_VALUE_GET = 'get';
    private final String ACTION_VALUE_SEARCH = 'search';
    private final String ACTION_VALUE_DELETE = 'delete';
    private final String ACTION_VALUE_SAVE = 'save';
    private final String ACTION_VALUE_SET_ACTIVE = 'setActive';
    private final String ACTION_VALUE_SHARE = 'share';
    private final String ACTION_VALUE_GET_SHARE_HISTORY = 'getShareHistory';
    
    private final String intTypeFacebook = IntegrationConstants.INTEGRATION_TYPE_FACEBOOK;
    private final String intTypeTwitter = IntegrationConstants.INTEGRATION_TYPE_TWITTER;
    private final String intTypeLinkedIn = IntegrationConstants.INTEGRATION_TYPE_LINKEDIN;
    
	private final String REQUEST_PARAM_DATA = 'data';
	private final String REQUEST_PARAM_CAMPAIGN_ID = 'campaignId';
	
	private final String ERROR_ACCESS_TOKEN_EXPIRED = 'Your access token has expired, Please reconnect your account';
	private final String ERROR_NOT_PERFORMING_CAMPAIGN = 'Unable to perform action';
	
	public CampaignService campaignServiceObj = new CampaignService();
	
	public override void handleRequest() {
		logger.logDebug('CampaignDataServer.handleRequest()----entered handleRequest----');
		try {
			if(SimpplrContext.isEmployeeAdvocacyEnabled == false  || SimpplrContext.appIntegrationEnabledSet.isEmpty()) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			String action = readParam(REQUEST_PARAM_ACTION);
			String requestData = readParam(REQUEST_PARAM_DATA);
			String campaignId = readParam(REQUEST_PARAM_CAMPAIGN_ID);
			
			if(ACTION_VALUE_SEARCH.equalsIgnoreCase(action)){
	            	response = search(requestData);
		        
			} else if(ACTION_VALUE_SHARE.equalsIgnoreCase(action)){
				response = share(requestData);
			
			} else if(ACTION_VALUE_get.equalsIgnoreCase(action)){
				response = getCampaign(campaignId);
			
			}  else {
				//Remaining endPoints can be used only by Users having Campaign Manage Access
				if(UserContext.hasManageCampaignAccess == false) {
					throw new SimpplrException(ServiceConstants.ERROR_403);
				}
				
				if(ACTION_VALUE_SAVE.equalsIgnoreCase(action)) {
					response = save(requestData);
				
				} else if(ACTION_VALUE_SET_ACTIVE.equalsIgnoreCase(action)) {
					Boolean isActive = Boolean.valueOf(readParam('isActive'));
					response = setActive(campaignId, isActive);
				
				} else if(ACTION_VALUE_DELETE.equalsIgnoreCase(action)) {
					response = deleteCampaign(campaignId);
					
				} else if(ACTION_VALUE_GET_SHARE_HISTORY.equalsIgnoreCase(action)) {
					response = getShareHistory(requestData);
					
				}
				
			}
		} catch(Exception ex) {
            logger.logError('CampaignDataServer.handleRequest()---Exception occured----', ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
	}


/**
 * @api {post} /apex/DataServerRW?target=CampaignDataServer&action=search search
 * @apiVersion 1.229.1
 * @apiGroup CampaignDataServer
 * @apiName search
 *
 * @apiParam (Query Parameter) {String} action search
 * @apiParam (Post Parameter) {Object} data  {size, nextPageToken, excludeAudienceCampaigns, filter}
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Campaign.search
 * 2. This is used for different campaign listings
 * 
 * @apiSuccess {List[CampaignWrapper]} Response.listOfItems Item list will contain CampaignWrapper
 * @apiSuccess {String} Response.nextPageToken Next page token
 * @apiUse CampaignWrapper
 * @apiUse CampaignWrapperNetworksWrapper
 * @apiUse CampaignWrapperNetworkWrapper 
 * @apiUse CampaignWrapperOembedWrapper
 */	
	private ResponseWrapper search(String requestData) {
		ResponseWrapper responseWrapperObj;
		 
		try {
			
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			logger.logDebug('CampaignDataServer.search()----requestMap----' + requestMap);
			
			Integer size = requestMap.get('size') != null ? Integer.valueOf(requestMap.get('size')) : 0; 
			Integer offset = requestMap.get('nextPageToken') != null ?Integer.valueOf(requestMap.get('nextPageToken')):0;
			Integer recordLimit = size + 1;
			Boolean excludeAudienceCampaigns = 'true'.equalsIgnoreCase(requestMap.get('excludeAudienceCampaigns'));
			List<CampaignWrapper> campaignWrapperList = campaignServiceObj.searchCampaign(recordLimit, offset, requestMap.get('filter'), requestMap.get('sortBy'), excludeAudienceCampaigns);			
			Integer nextPageToken;
	        if (campaignWrapperList.size() == (size + 1) && offset < 2000) {
		        	campaignWrapperList.remove((campaignWrapperList.size()-1));
		        	nextPageToken = offset + size;
	        }
	        Map<String,Object> result = New Map<String,Object>();
	        result.put('listOfItems',campaignWrapperList);
	        result.put('nextPageToken',nextPageToken);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
			
		} catch(Exception ex) {
			logger.logError('CampaignDataServer.search()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}

/**
 * @api {post} /apex/DataServerRW?target=CampaignDataServer&action=delete delete
 * @apiVersion 1.229.1
 * @apiGroup CampaignDataServer
 * @apiName delete
 *
 * @apiParam (Query Parameter) {String} action delete
 * @apiParam (Post Parameter) {String} data <a href="../build/#campaign-campaign.delete" target="_blank">campaign-campaign.delete</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Campaign.delete
 * 2. This is used for deleting a campaign record for the campaign id provided
 * 
 * @apiSuccess {Null} Response.result Null
 */	
	private ResponseWrapper deleteCampaign(String campaignId){
		ResponseWrapper responseWrapperObj;
		try {
			Social_Campaign__c scObj = new Social_Campaign__c(Id = campaignId);
			scObj.Is_Deleted__c = true;
			scObj.Is_Active__c = false;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(scObj,new List<Schema.SObjectField>{
														Social_Campaign__c.Is_Deleted__c,
														Social_Campaign__c.Is_Active__c
													});
			BatchCampaignNotifications job = new BatchCampaignNotifications(scObj.id, 'DeleteCampaignNotifcations');
			Database.executeBatch(job, 2000);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} catch(Exception ex) {
			logger.logError('CampaignDataServer.deleteCampaign()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}

/**
 * @api {post} /apex/DataServerRW?target=CampaignDataServer&action=setActive setActive
 * @apiVersion 1.229.1
 * @apiGroup CampaignDataServer
 * @apiName setActive
 *
 * @apiParam (Query Parameter) {String} action setActive
 * @apiParam (Post Parameter) {String} data <a href="../build/#campaign-campaign.setactive" target="_blank">campaign-campaign.setActive</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Campaign.setActive
 * 2. This is used for setting a campaign as active or inactive
 * 
 * @apiSuccess {Null} Response.result Null
  
 * @apiError (Error) 404 If a campaign is not found with the given campaign id in undeleted status
 */ 	
	private ResponseWrapper setActive(String campaignId, Boolean isActive){
		ResponseWrapper responseWrapperObj;
		try {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', campaignId);
			String queryStr = 'Select Id, People__c from Social_Campaign__c where Is_Deleted__c = false and Id =: soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Social_Campaign__c> scList = (List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);			
			if(!scList.isEmpty()){
				scList[0].Is_Active__c = isActive;				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<id,Social_Campaign__c>(scList),new List<Schema.SObjectField>{Social_Campaign__c.Is_Active__c});

				// Currently there is no functionality to re-activate the expired social campaigns
				BatchCampaignNotifications job = new BatchCampaignNotifications(scList[0].Id, 'DeleteCampaignNotifcations');
				Database.executeBatch(job, 2000);
			}else{
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} catch(Exception ex) {
			logger.logError('CampaignDataServer.setActive()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}

/**
 * @api {get} /apex/DataServerRW?target=CampaignDataServer&action=getShareHistory getShareHistory
 * @apiVersion 1.229.1
 * @apiGroup CampaignDataServer
 * @apiName getShareHistory
 *
 * @apiParam (Query Parameter) {String} action getShareHistory
 * @apiParam (Post Parameter) {String} data <a href="../build/#campaign-campaign.getsharehistory" target="_blank">campaign-campaign.getShareHistory</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Campaign.getShareHistory
 * 2. This is used for getting details of which users have shared the Campaign to which social networks
 * 
 * @apiSuccess {CampaignWrapper.CampaignShareHistoryWrapper} Response.listOfItems Campaign share data for the requested campaign sorted first by number of networks shared to, then by most recent share timestamp
 * @apiSuccess {String} Response.nextPageToken Next page token
 * @apiSuccess {String} Response.csvUrl Csv file url
 * @apiUse CampaignWrapperCampaignShareHistoryWrapper
 * @apiUse PeopleLiteWrapper
 * @apiUse CampaignWrapperNetworksWrapper
 * @apiUse CampaignWrapperNetworkWrapper 
 */	
	private ResponseWrapper getShareHistory(String requestData){
		ResponseWrapper responseWrapperObj;
		Map<Id, CampaignWrapper.CampaignShareHistoryWrapper>campaignShareMap = new Map<Id, CampaignWrapper.CampaignShareHistoryWrapper>();
		CampaignWrapper.CampaignShareHistoryWrapper shareWrapperObj;
				
		try {
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			logger.logDebug('CampaignDataServer.getShareHistory()----requestMap----'+ requestMap);
			
			String campaignId = requestMap.get('campaignId');
			Integer size = requestMap.get('size') != null ? Integer.valueOf(requestMap.get('size')) : 0; 
			Integer offset = requestMap.get('nextPageToken') != null ?Integer.valueOf(requestMap.get('nextPageToken')):0;
			Integer recordLimit = size + 1;
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', campaignId);
			soqlParamMap.put('soqlParam2', recordLimit);
			soqlParamMap.put('soqlParam3', offset);
			String queryStr = 'Select Id from People__c where Id in (Select People__c from Social_Campaign_Share__c'
							+ ' where Social_Campaign__c =: soqlParam1)';
			queryStr += 		getLimitOffsetCondition(recordLimit, offset);
			queryStr = (queryStr.replace('recordLimit', 'soqlParam2')).replace(':offset', ':soqlParam3');
			logger.logDebug('CampaignDataServer.getShareHistory()----queryStr----' + queryStr);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);	
			Map<String, Object> soqlParamMap1 = new Map<String, Object>();
			soqlParamMap1.put('soqlParam1', peopleList);
			soqlParamMap1.put('soqlParam2', requestMap.get('campaignId'));
			String queryString = 'Select Id, Network_Shared__c, People__c, People__r.User__c, People__r.Full_Name__c, People__r.Country__c, '+
														' People__r.Title__c, People__r.Role__c, People__r.Department__c, People__r.City__c, People__r.State__c,'+
														' People__r.Phone__c, People__r.Email__c, People__r.User__r.SmallPhotoUrl, '+
														' People__r.User__r.isActive, People__r.Skype_Id__c, People__r.Zoom_Id__c, '+
														' Social_Campaign__c ,Total_Likes__c,Total_Shares__c'+
														' from Social_Campaign_Share__c '+
														' where People__c =: soqlParam1 and Social_Campaign__c =: soqlParam2';
														
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Social_Campaign_Share__c> shareList = (List<Social_Campaign_Share__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap1);
			for(Social_Campaign_Share__c ssObj : shareList){
				if(campaignShareMap.containsKey(ssObj.People__c)){
	 				
					shareWrapperObj = campaignShareMap.get(ssObj.People__c);
					
					}else {
					shareWrapperObj = new CampaignWrapper.CampaignShareHistoryWrapper();
					shareWrapperObj.user.id = ssObj.People__c;
					shareWrapperObj.user.sfUserId = ssObj.People__r.User__c;
					shareWrapperObj.user.peopleId = ssObj.People__c;
					shareWrapperObj.user.name = ssObj.People__r.Full_Name__c;
					shareWrapperObj.user.title = ssObj.People__r.Title__c;
					shareWrapperObj.user.img = ssObj.People__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null : ssObj.People__r.User__r.SmallPhotoUrl;
					shareWrapperObj.user.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + ssObj.People__c;
					shareWrapperObj.user.role = ssObj.People__r.Role__c;
					shareWrapperObj.user.department = ssObj.People__r.Department__c;
					shareWrapperObj.user.location = Utility.buildLocation(ssObj.People__r.City__c, ssObj.People__r.State__c, ssObj.People__r.Country__c);
					shareWrapperObj.user.phone = ssObj.People__r.Phone__c;
					shareWrapperObj.user.email = ssObj.People__r.Email__c;
					shareWrapperObj.user.isActive = ssObj.People__r.User__r.isActive;
					
					if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
						shareWrapperObj.user.videoCallUsername = ssObj.People__r.Zoom_Id__c;
					} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
						shareWrapperObj.user.videoCallUsername = ssObj.People__r.Skype_Id__c;
					}
					shareWrapperObj.user.videoCallProvider = SimpplrContext.PPVideoProvider;
				}
				if('facebook'.equalsIgnoreCase(ssObj.Network_Shared__c)) {
					if(shareWrapperObj.networksSharedTo.facebook == null) {
						shareWrapperObj.networksSharedTo.facebook = new CampaignWrapper.NetworkWrapper();
						shareWrapperObj.networksSharedTo.facebook.likeCount = 0;
						shareWrapperObj.networksSharedTo.facebook.reshareCount = 0;
						shareWrapperObj.networksSharedTo.facebook.shareCount = 0;
					}
					shareWrapperObj.networksSharedTo.facebook.likeCount += (Integer)ssObj.Total_Likes__c;
					shareWrapperObj.networksSharedTo.facebook.reshareCount += (Integer)ssObj.Total_Shares__c;
					shareWrapperObj.networksSharedTo.facebook.shareCount++;
					
				} else if('linkedIn'.equalsIgnoreCase(ssObj.Network_Shared__c)) {
					if(shareWrapperObj.networksSharedTo.linkedIn == null) {
						shareWrapperObj.networksSharedTo.linkedIn = new CampaignWrapper.NetworkWrapper();
						shareWrapperObj.networksSharedTo.linkedIn.likeCount = 0;
						shareWrapperObj.networksSharedTo.linkedIn.reshareCount = 0;
						shareWrapperObj.networksSharedTo.linkedIn.shareCount = 0;
					}
					shareWrapperObj.networksSharedTo.linkedIn.likeCount += (Integer)ssObj.Total_Likes__c;
					shareWrapperObj.networksSharedTo.linkedIn.reshareCount += (Integer)ssObj.Total_Shares__c;
					shareWrapperObj.networksSharedTo.linkedIn.shareCount++;
				}
				else{
					if(shareWrapperObj.networksSharedTo.twitter == null) {
						shareWrapperObj.networksSharedTo.twitter = new CampaignWrapper.NetworkWrapper();
						shareWrapperObj.networksSharedTo.twitter.likeCount = 0;
						shareWrapperObj.networksSharedTo.twitter.reshareCount = 0;
						shareWrapperObj.networksSharedTo.twitter.shareCount = 0;
					}
					shareWrapperObj.networksSharedTo.twitter.likeCount += (Integer)ssObj.Total_Likes__c;
					shareWrapperObj.networksSharedTo.twitter.reshareCount += (Integer)ssObj.Total_Shares__c;
					shareWrapperObj.networksSharedTo.twitter.shareCount++;
				}
				
				campaignShareMap.put(ssObj.People__c, shareWrapperObj);
			}
			 
			Integer nextPageToken;
	        if (campaignShareMap.values().size() == (size + 1) && offset < 2000) {
		        	campaignShareMap.values().remove((campaignShareMap.values().size()-1));
		        	nextPageToken = offset + size;
	        }
	        
			Map<String, Object>result = new Map<String, Object>();
			result.put('listOfItems',campaignShareMap.values());
	        result.put('nextPageToken',nextPageToken);
			result.put('csvUrl', PageContext.getPageURL(Pages.Reports) + '?action=getCampaignShareData&campaignId='+campaignId);
			
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		} catch(Exception ex) {
			logger.logError('CampaignDataServer.getShareHistory()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	
	}       
    
    public list<CampaignWrapper.CampaignReportWrapper> getCampaignShareHistoryReport(String campaignId){
    		
    		List<CampaignWrapper.CampaignReportWrapper> campaignReportList = new List<CampaignWrapper.CampaignReportWrapper>();
    		Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', campaignId);
    		String queryString = 'Select Id, CreatedDate, Network_Shared__c, People__c, People__r.User__c, People__r.Name, People__r.Country__c, '+
														' People__r.Title__c, People__r.Role__c, People__r.Department__c, People__r.City__c, People__r.State__c,'+
														' People__r.Phone__c, People__r.Email__c, People__r.User__r.SmallPhotoUrl,'+
														' People__r.User__r.isActive, Social_Campaign__c ,Total_Likes__c,Total_Shares__c'+
														' from Social_Campaign_Share__c '+
														' where Social_Campaign__c =: soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Social_Campaign_Share__c> shareList = (List<Social_Campaign_Share__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
    		for(Social_Campaign_Share__c ssObj : shareList){
    			campaignReportList.add(new CampaignWrapper.CampaignReportWrapper(ssObj.People__r.Name, ssObj.People__r.Email__c, ssObj.People__r.Department__c, ssObj.People__r.City__c, ssObj.People__r.State__c, ssObj.People__r.Country__c, Utility.dateToDisplayString(ssObj.CreatedDate, ServiceConstants.LISTING_DATETIME_FORMAT), ssObj.Network_Shared__c, (Integer)ssObj.Total_Shares__c, (Integer)ssObj.Total_Likes__c, ssObj.CreatedDate));
    			
    		}
    		return campaignReportList;
    
    }
    
    private String getLimitOffsetCondition(Integer recordLimit, Integer offset){
		String	queryStr = '';
		if(recordLimit!=null && offset!=null) {
			queryStr += ' limit :recordLimit  offset :offset';
		}
		return queryStr;
	}
    
/**
 * @api {post} /apex/DataServerRW?target=CampaignDataServer&action=get get
 * @apiVersion 1.229.1
 * @apiGroup CampaignDataServer
 * @apiName get
 *
 * @apiParam (Query Parameter) {String} action get
 * @apiParam (Post Parameter) {String} data <a href="../build/#campaign-campaign.get" target="_blank">campaign-campaign.get</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Campaign.get
 * 2. This is used for retrieving the campaign record from the campaign id provided
 * 
 * @apiSuccess {CampaignWrapper} Response.result Result contains the campaign information of the requested campaign id
 * @apiUse CampaignWrapper
 * @apiUse CampaignWrapperNetworksWrapper
 * @apiUse CampaignWrapperNetworkWrapper 
 * @apiUse CampaignWrapperOembedWrapper
  
 * @apiError (Error) CampaignIsNoLongerActive If a campaign is deleted or inactive
 */
     
	private ResponseWrapper getCampaign(String campaignId) {
		ResponseWrapper responseWrapperObj;
		try {
			CampaignWrapper wrapperObj = campaignServiceObj.getCampaign(campaignId);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
			
		} catch(Exception ex) {
			logger.logError('CampaignDataServer.getCampaign()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);
		}
		return responseWrapperObj;
	}

/**
 * @api {post} /apex/DataServerRW?target=CampaignDataServer&action=save save
 * @apiVersion 1.229.1
 * @apiGroup CampaignDataServer
 * @apiName save
 *
 * @apiParam (Query Parameter) {String} action save
 * @apiParam (Post Parameter) {String} data <a href="../build/#campaign-campaign.save" target="_blank">campaign-campaign.save</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Campaign.save
 * 2. This is used for creating a new Social Campaign 
 * 
 * @apiSuccess {CampaignWrapper} Response.result Result contains the campaign information of the newly created campaign
 * @apiUse CampaignWrapper
 * @apiUse CampaignWrapperNetworksWrapper
 * @apiUse CampaignWrapperNetworkWrapper 
 * @apiUse CampaignWrapperOembedWrapper
 */ 	
	private ResponseWrapper save (String requestData) {
		ResponseWrapper responseWrapperObj;
		try {
			CampaignWrapper wrapperObj = (CampaignWrapper)JSON.deserialize(requestData, CampaignWrapper.class);
			if(wrapperObj.networks.facebook.isEnabled == true && String.isBlank(wrapperObj.url)){
				throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN);
			}
			Social_Campaign__c campaignObj = saveCampaignToDB(wrapperObj);
			BatchCampaignNotifications job = new BatchCampaignNotifications(campaignObj.id, campaignObj.Audience__c, 'NewCampaignNotifcations');
			Database.executeBatch(job,200);
			responseWrapperObj = getCampaign(campaignObj.id);	
   
		} catch(Exception ex) {
			logger.logError('CampaignDataServer.save()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}
	
	private Social_Campaign__c saveCampaignToDB(CampaignWrapper wrapperObj) {
																							
		Social_Campaign__c campaignObj;
		Boolean isEdit = false;
		if(String.isNotBlank(wrapperObj.campaignId)) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', wrapperObj.campaignId);
			STring queryStr = 'select id from Social_Campaign__c where id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			campaignObj = (Social_Campaign__c)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap)[0];
			
		} else {
			campaignObj = new Social_Campaign__c();
			campaignObj.People__c = UserContext.peopleId;
		}

		String audienceId;
		List<Audience__c> audienceList;
		if('audience'.equalsIgnoreCase(wrapperObj.recipient)) {
			audienceId = wrapperObj.audience.audienceId;

		} else if('segment'.equalsIgnoreCase(wrapperObj.recipient)) {
			String segmentId = wrapperObj.segmentId;
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', segmentId);
			String query = 'SELECT Id FROM Audience__c WHERE Segment__c = : soqlParam1 ' +  
							'AND Is_Deleted__c = false ' +
							'AND Is_Hidden__c = true ' +
							'AND Has_City_Condition__c = false ' +
							'AND Has_Company_Name_Condition__c = false ' +
							'AND Has_Country_Condition__c = false ' +
							'AND Has_Custom_Field_1_Condition__c = false ' +
							'AND Has_Custom_Field_2_Condition__c = false ' +
							'AND Has_Custom_Field_3_Condition__c = false ' +
							'AND Has_Custom_Field_4_Condition__c = false ' +
							'AND Has_Custom_Field_5_Condition__c = false ' +
							'AND Has_Custom_Field_6_Condition__c = false ' +
							'AND Has_Custom_Field_7_Condition__c = false ' +
							'AND Has_Custom_Field_8_Condition__c = false ' +
							'AND Has_Custom_Field_9_Condition__c = false ' +
							'AND Has_Custom_Field_10_Condition__c = false ' +
							'AND Has_Custom_Field_11_Condition__c = false ' +
							'AND Has_Custom_Field_12_Condition__c = false ' +
							'AND Has_Custom_Field_13_Condition__c = false ' +
							'AND Has_Custom_Field_14_Condition__c = false ' +
							'AND Has_Custom_Field_15_Condition__c = false ' +							
							'AND Has_Custom_Field_16_Condition__c = false ' +
							'AND Has_Custom_Field_17_Condition__c = false ' +
							'AND Has_Custom_Field_18_Condition__c = false ' +
							'AND Has_Custom_Field_19_Condition__c = false ' +
							'AND Has_Custom_Field_20_Condition__c = false ' +
							'AND Has_Custom_Field_21_Condition__c = false ' +
							'AND Has_Custom_Field_22_Condition__c = false ' +
							'AND Has_Custom_Field_23_Condition__c = false ' +
							'AND Has_Custom_Field_24_Condition__c = false ' +
							'AND Has_Custom_Field_25_Condition__c = false ' +														
							'AND Has_Department_Condition__c = false ' +
							'AND Has_Division_Condition__c = false ' +
							'AND Has_Joining_Date_Condition__c = false ' +
							'AND Has_People_Category_Condition__c = false ' +
							'AND Has_State_Condition__c = false ' +
							'AND Has_Title_Condition__c = false';							
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
										
			if(!audienceList.isEmpty()) {
				audienceId = audienceList[0].Id;
			}
		} else if('everyone'.equalsIgnoreCase(wrapperObj.recipient)) {
			String query = 'select id from Audience__c where name__c=\'Everyone\' AND Is_Deleted__c = false AND Is_Hidden__c = true';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(query, null);
			if(!audienceList.isEmpty()) {
				audienceId = audienceList[0].Id;
			}
		}

		campaignObj.audience__c = audienceId; 
		campaignObj.recipient__c = wrapperObj.recipient;
		campaignObj.Description__c = wrapperObj.defaultDescription;
		campaignObj.Facebook_Share_Enabled__c = wrapperObj.networks.facebook != null ? wrapperObj.networks.facebook.isEnabled : false;
		campaignObj.Twitter_Share_Enabled__c = wrapperObj.networks.twitter != null ? wrapperObj.networks.twitter.isEnabled : false;
		campaignObj.LinkedIn_Share_Enabled__c = wrapperObj.networks.linkedIn != null ? wrapperObj.networks.linkedIn.isEnabled : false;
		campaignObj.URL__c = wrapperObj.url;
		if ((campaignObj.Facebook_Share_Enabled__c && SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK) == false) ||
			(campaignObj.Twitter_Share_Enabled__c && SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_TWITTER) == false) ||
			(campaignObj.LinkedIn_Share_Enabled__c && SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN) == false)) {
			throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN);	
		}
		if(wrapperObj.oembed != null) {
			campaignObj.URL_Preview_Json__c = JSON.serialize(wrapperObj.oembed);
		}
		if(String.isNotBlank(wrapperObj.campaignId)) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(campaignObj,new List<Schema.SObjectField>{
														Social_Campaign__c.People__c,
														Social_Campaign__c.audience__c,
														Social_Campaign__c.recipient__c,
														Social_Campaign__c.Description__c,
														Social_Campaign__c.Facebook_Share_Enabled__c,
														Social_Campaign__c.Twitter_Share_Enabled__c,
														Social_Campaign__c.LinkedIn_Share_Enabled__c,
														Social_Campaign__c.URL__c,
														Social_Campaign__c.URL_Preview_Json__c
													});
		} else {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			campaignObj = (Social_Campaign__c)SIMPESAPI.accessController().insertAsUser(campaignObj,new List<Schema.SObjectField>{
														Social_Campaign__c.People__c,
														Social_Campaign__c.audience__c,
														Social_Campaign__c.recipient__c,
														Social_Campaign__c.Description__c,
														Social_Campaign__c.Facebook_Share_Enabled__c,
														Social_Campaign__c.Twitter_Share_Enabled__c,
														Social_Campaign__c.LinkedIn_Share_Enabled__c,
														Social_Campaign__c.URL__c,
														Social_Campaign__c.URL_Preview_Json__c
													});
		}
		return campaignObj;
	}

/**
 * @api {post} /apex/DataServerRW?target=CampaignDataServer&action=share share
 * @apiVersion 1.229.1
 * @apiGroup CampaignDataServer
 * @apiName share
 *
 * @apiParam (Query Parameter) {String} action share
 * @apiParam (Post Parameter) {String} data <a href="../build/#campaign-campaign.share" target="_blank">campaign-campaign.share</a> 
 *
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.Campaign.share
 * 2. This is used for sharing a Campaign to the current user's social networks
 * 
 * @apiSuccess {Null} Response.result Null
  
 * @apiError (Error) InvalidParameter If campaign is not found with the requested campaign id
 * @apiError (Error) UnableToPerformAction If user tries to 
 1) Share a campaign which is deleted or inactive 
 2) Share a campaign on facebook which is not enabled for facebook 
 3) Share a campaign on twitter which is not enabled for twitter 
 4) Share a campaign on linkedin which is not enabled for linkedin
 
 */ 	
	private ResponseWrapper share(String requestData) {
		ResponseWrapper responseWrapperObj;
		try {
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			logger.logDebug('CampaignDataServer.share()----requestMap----' + requestMap);
			String networkArg = requestMap.get('network');
			String campaignId = requestMap.get('campaignId');
			if(String.isBlank(networkArg) || SimpplrContext.appIntegrationEnabledSet.contains(networkArg) == false) {
				throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN);
			}
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', campaignId);
			String queryStr = 'Select Id, URL__c, URL_Preview_Json__c, Is_Active__c, Is_Deleted__c,Facebook_Share_Enabled__c, LinkedIn_Share_Enabled__c,'+
														' Twitter_Share_Enabled__c from Social_Campaign__c where id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Social_Campaign__c> socialCampaignList = (List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
			if(socialCampaignList.isEmpty()) {
				throw new SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
				
			} else if(socialCampaignList[0].is_Deleted__c) {
				throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN);
				
			} else if(socialCampaignList[0].is_Active__c == false) {
				throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN);
				
			} else if(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK.equalsIgnoreCase(networkArg)) {
				if(socialCampaignList[0].Facebook_Share_Enabled__c){
					FacebookService facebookServiceObj = new FacebookService();
					facebookServiceObj.postToFacebook(socialCampaignList[0], requestMap.get('message'));
				}else{
					throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN);
				}
			} else if(IntegrationConstants.INTEGRATION_TYPE_TWITTER.equalsIgnoreCase(networkArg)) {
				if(socialCampaignList[0].Twitter_Share_Enabled__c){
					TwitterService twitterServiceObj = new TwitterService();
					twitterServiceObj.postOnTwitter(socialCampaignList[0], requestMap.get('message'));
				}else{
					throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN);
				}
				
			} else if(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN.equalsIgnoreCase(networkArg)) {
				if(socialCampaignList[0].LinkedIn_Share_Enabled__c){
					LinkedInService linkedInServiceObj = new LinkedInService();
					linkedInServiceObj.linkedInShareProcess(socialCampaignList[0], requestMap.get('message'));
				}else{
					throw new SimpplrException(ERROR_NOT_PERFORMING_CAMPAIGN);
				}
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} catch(Exception ex) {
			logger.logError('CampaignDataServer.share()---Exception occured----', ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
	}	

}