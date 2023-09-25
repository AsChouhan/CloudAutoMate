public with sharing class CampaignService {
  	  
  	
    private final String intTypeFacebook = IntegrationConstants.INTEGRATION_TYPE_FACEBOOK;
    private final String intTypeTwitter = IntegrationConstants.INTEGRATION_TYPE_TWITTER;
    private final String intTypeLinkedIn = IntegrationConstants.INTEGRATION_TYPE_LINKEDIN;
    private final Integer CAMPAIGN_TILE_ITEM_LIMIT = 4;
	private final String ERROR_GET_INACTIVE_OR_EXPIRED_CAMPAIGN = 'Social Campaign is no longer active'; 
    
    public String addCampaignToCarousel(String siteId, String segmentId, String campaignId){
    	Carousel_Content__c ccObj = new Carousel_Content__c();  
        ccObj.Site__c = siteId;
        ccObj.Segment__c = segmentId;
        ccObj.Social_Campaign__c = campaignId;
        ccObj.Item_Type__c = 'campaign';
		ccObj.Created_by_People__c = UserContext.peopleId;
        
        List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField> { 	Carousel_Content__c.Segment__c, 
        																					Carousel_Content__c.Site__c,
																							Carousel_Content__c.Created_by_People__c,
        																					Carousel_Content__c.Social_Campaign__c, 
        																					Carousel_Content__c.Item_Type__c};
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		ccObj = (Carousel_Content__c) SIMPESAPI.accessController().insertAsUser(ccObj, listOfColumnsToBeSet);
		return ccObj.id;
    }
      
	public List<CampaignWrapper> searchCampaign(Integer recordLimit, Integer offset, String filter, String sortBy, Boolean excludeAudienceCampaigns) {
		Set<Id> audienceIdSet = UserContext.audiencesIAmMemberOfMap.keySet();
		
		String queryStr = 'SELECT '+String.join(getCampaignFieldList(),',')+ ' FROM Social_Campaign__c ';
		queryStr += getFilterCondition(filter, excludeAudienceCampaigns);
		queryStr += getSortOrderCondition(sortBy);
		queryStr += getLimitOffsetCondition(recordLimit, offset); 
		queryStr = ((queryStr.replace('audienceIdSet', 'soqlParam1')).replace('recordLimit', 'soqlParam2')).replace(':offset', ':soqlParam3');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIdSet);
		soqlParamMap.put('soqlParam2', recordLimit);
		soqlParamMap.put('soqlParam3', offset);
		logger.logDebug('CampaignService.searchCampaign()----queryStr----' + queryStr);	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Social_Campaign__c> queryResult = (List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		Map<Id, set<String>> mapCampaignIdIntegrationShared = getCampSharedMap(queryResult);
		List<CampaignWrapper> campaignWrapperList = new List<CampaignWrapper>();
		Set<String> setOfActiveDirectoryGroups = new Set<String>();
		Map<String, Active_Directory_Group__c> adIdToADObjectMap = new Map<String, Active_Directory_Group__c>();		
		// For AD audience
		for(Social_Campaign__c campaignObj : queryResult) {
			if('audience'.equalsIgnoreCase(campaignObj.Recipient__c)) {
				Set<String> activeDirectoryGroupIds = ActiveDirectoryHelper.getActiveDirectoryGroupIds(campaignObj.Audience__r.Audience_Rule_Json__c);
				if(!activeDirectoryGroupIds.isEmpty()) {
					setOfActiveDirectoryGroups.addAll(activeDirectoryGroupIds);
				}	
			}	
		}
		// For AD audience
		if(!setOfActiveDirectoryGroups.isEmpty()) {
			adIdToADObjectMap = ActiveDirectoryHelper.getSelectedActiveDirectoryGroups(setOfActiveDirectoryGroups);
		}		
		for(Social_Campaign__c campaignObj : queryResult) {
			campaignWrapperList.add(convertToWrapper(campaignObj, mapCampaignIdIntegrationShared, adIdToADObjectMap));
		}
		system.debug('>convertToWrapper>>>>>63>>>campaignWrapperList' +campaignWrapperList);
		return campaignWrapperList;
	}	
	
	@TestVisible 
	private Map<Id, set<String>> getCampSharedMap(List<Social_Campaign__c> campList){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.peopleId);
		soqlParamMap.put('soqlParam2', campList);
		String queryStr = 'Select Id, Network_Shared__c, People__c, Social_Campaign__c '+
													' from Social_Campaign_Share__c '+
													' where People__c =: soqlParam1 and Social_Campaign__c =: soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Social_Campaign_Share__c> camSharelist = (List<Social_Campaign_Share__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		Map<Id, set<String>> mapCampaignIdIntegrationShared = new Map<Id, set<String>>();
		for(Social_Campaign_Share__c shareObj : camSharelist){
			if(mapCampaignIdIntegrationShared.containsKey(shareObj.Social_Campaign__c)){
				mapCampaignIdIntegrationShared.get(shareObj.Social_Campaign__c).add(shareObj.Network_Shared__c);
			}else{
				mapCampaignIdIntegrationShared.put(shareObj.Social_Campaign__c, new set<String> {shareObj.Network_Shared__c});
			}
		
		}
		return mapCampaignIdIntegrationShared;
	}
	
	public CampaignWrapper getCampaign(String campaignId){
		Map<Id, set<String>> mapCampaignIdIntegrationShared = new Map<Id, set<String>>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', campaignId);
		String queryStr = 'SELECT '+String.join(getCampaignFieldList(),',')+' FROM Social_Campaign__c where id=:soqlParam1 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Social_Campaign__c> campaignList = (List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(campaignList[0].is_Deleted__c) {
			throw new SimpplrException(ServiceConstants.ERROR_404);
			
		} else if(campaignList[0].is_Active__c == false) {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		Set<String> setOfActiveDirectoryGroups = new Set<String>();
		Map<String, Active_Directory_Group__c> adIdToADObjectMap = new Map<String, Active_Directory_Group__c>();		
		if(!campaignList.isEmpty() && 'audience'.equalsIgnoreCase(campaignList[0].Recipient__c)) {
			Set<String> activeDirectoryGroupIds = ActiveDirectoryHelper.getActiveDirectoryGroupIds(campaignList[0].Audience__r.Audience_Rule_Json__c);
			if(!activeDirectoryGroupIds.isEmpty()) {
				setOfActiveDirectoryGroups.addAll(activeDirectoryGroupIds);
			}			
		}
		if(!setOfActiveDirectoryGroups.isEmpty()) {
			adIdToADObjectMap = ActiveDirectoryHelper.getSelectedActiveDirectoryGroups(setOfActiveDirectoryGroups);
		}			
		CampaignWrapper  wrapperObj = convertToWrapper(campaignList[0], mapCampaignIdIntegrationShared, adIdToADObjectMap);
		return wrapperObj;
		
	}
	
	public CampaignWrapper getCampaignForFeed(String campaignId){ 
		CampaignWrapper  wrapperObj;
		Map<Id, set<String>> mapCampaignIdIntegrationShared = new Map<Id, set<String>>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', campaignId);
		String queryStr = 'SELECT '+String.join(getCampaignFieldList(),',')+' FROM Social_Campaign__c where id=:soqlParam1 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Social_Campaign__c> campaignList = (List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		Set<String> setOfActiveDirectoryGroups = new Set<String>();
		Map<String, Active_Directory_Group__c> adIdToADObjectMap = new Map<String, Active_Directory_Group__c>();		
		if(!campaignList.isEmpty() && 'audience'.equalsIgnoreCase(campaignList[0].Recipient__c)) {
			Set<String> activeDirectoryGroupIds = ActiveDirectoryHelper.getActiveDirectoryGroupIds(campaignList[0].Audience__r.Audience_Rule_Json__c);
			if(!activeDirectoryGroupIds.isEmpty()) {
				setOfActiveDirectoryGroups.addAll(activeDirectoryGroupIds);
			}			
		}
		if(!setOfActiveDirectoryGroups.isEmpty()) {
			adIdToADObjectMap = ActiveDirectoryHelper.getSelectedActiveDirectoryGroups(setOfActiveDirectoryGroups);
		}			
		if(!campaignList.isEmpty()) {			
	 		wrapperObj = convertToWrapper(campaignList[0], mapCampaignIdIntegrationShared, adIdToADObjectMap);
		}
		
		return wrapperObj;
		
	}	
	
	public List<TileDataWrapper.TileData> getCampaignTilesData(TileDataWrapper.TileDataSettings tiledataSettings){
    	List<String> listOfCampaignIds = tiledataSettings.value.split(',');
    	List<TileDataWrapper.TileData> listOfCampaignTileData = new List<TileDataWrapper.TileData>();
    	
    	Map<Id,Social_Campaign__c> campaignMap = getCampaignByIds(null, listOfCampaignIds);
    	
		Map<Id, set<String>> mapCampaignIdIntegrationShared =  getCampSharedMap(campaignMap.values());												
    	
    	for(String campaignId : listOfCampaignIds){
    		if(campaignMap.get(campaignId) != null){
	    		listOfCampaignTileData.add(convertCampaignToTileDataWrapper(campaignMap.get(campaignId), mapCampaignIdIntegrationShared));
    		}
    	}
    	
		return listOfCampaignTileData;
    }
    
    public Map<Id,Social_Campaign__c> getCampaignByIds(String filter, List<String> listOfCampaignIds){
		Set<Id> audienceIdSet = UserContext.audiencesIAmMemberOfMap.keySet();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfCampaignIds);
		soqlParamMap.put('soqlParam2', audienceIdSet);
		
		String queryStr = 'SELECT '+String.join(getCampaignFieldList(),',')+' FROM Social_Campaign__c ';
    	queryStr += getFilterCondition(filter, false);
    	queryStr += ' And ID = :soqlParam1 ';
    	queryStr = queryStr.replace('audienceIdSet', 'soqlParam2');
		logger.logDebug('CampaignService.getCampaignByIds()----queryStr----' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		Map<Id,Social_Campaign__c> campaignMap = new Map<Id,Social_Campaign__c>((List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap));
		
		return campaignMap;
	}
    
    public List<TileDataWrapper.TileData> getLatestCampaignTilesData(){
    	List<TileDataWrapper.TileData> listOfCampaignTileData = new List<TileDataWrapper.TileData>();
    	Set<Id> audienceIdSet = UserContext.audiencesIAmMemberOfMap.keySet();

    	String queryStr = 'SELECT '+String.join(getCampaignFieldList(),',')+' FROM Social_Campaign__c ';
    	queryStr += getFilterCondition(null, false);
    	queryStr += getSortOrderCondition('latest');
    	Integer recordLimit = CAMPAIGN_TILE_ITEM_LIMIT;
    	Integer offset = 0;
		queryStr += getLimitOffsetCondition(recordLimit, offset); 
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		queryStr = ((queryStr.replace('audienceIdSet', 'soqlParam1')).replace('recordLimit', 'soqlParam2')).replace(':offset', ':soqlParam3');
		soqlParamMap.put('soqlParam1', audienceIdSet);
		soqlParamMap.put('soqlParam2', recordLimit);
		soqlParamMap.put('soqlParam3', offset);
		logger.logDebug('CampaignService.getLatestCampaignTilesData()----queryStr----' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		Map<Id,Social_Campaign__c> campaignMap = new Map<Id,Social_Campaign__c>((List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap));
		Map<Id, set<String>> mapCampaignIdIntegrationShared = getCampSharedMap(campaignMap.values());												
    	for(String campaignId : campaignMap.keySet()){
	    	listOfCampaignTileData.add(convertCampaignToTileDataWrapper(campaignMap.get(campaignId), mapCampaignIdIntegrationShared));
    	}
    	
		return listOfCampaignTileData;
    }
    
    
    public List<TileDataWrapper.TileData> getPopularCampaignTilesData(){
    	List<TileDataWrapper.TileData> listOfCampaignTileData = new List<TileDataWrapper.TileData>();
    	Set<Id> audienceIdSet = UserContext.audiencesIAmMemberOfMap.keySet();

    	String queryStr = 'SELECT '+String.join(getCampaignFieldList(),',')+' FROM Social_Campaign__c ';
    	queryStr += getFilterCondition(null, false);
    	queryStr += getSortOrderCondition('popular');
    	Integer recordLimit = CAMPAIGN_TILE_ITEM_LIMIT;
    	Integer offset = 0;
		queryStr += getLimitOffsetCondition(recordLimit, offset); 
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		queryStr = ((queryStr.replace('audienceIdSet', 'soqlParam1')).replace('recordLimit', 'soqlParam2')).replace(':offset', ':soqlParam3');
		soqlParamMap.put('soqlParam1', audienceIdSet);
		soqlParamMap.put('soqlParam2', recordLimit);
		soqlParamMap.put('soqlParam3', offset);
		logger.logDebug('CampaignService.getPopularCampaignTilesData()----queryStr----' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		Map<Id,Social_Campaign__c> campaignMap = new Map<Id,Social_Campaign__c>((List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap));
		Map<Id, set<String>> mapCampaignIdIntegrationShared = getCampSharedMap(campaignMap.values());												
    	
    	for(String campaignId : campaignMap.keySet()){
	    	listOfCampaignTileData.add(convertCampaignToTileDataWrapper(campaignMap.get(campaignId), mapCampaignIdIntegrationShared));
    	}
    	
		return listOfCampaignTileData;
    }
    
    private TileDataWrapper.TileData convertCampaignToTileDataWrapper(Social_Campaign__c campaignObj, Map<Id, set<String>> mapCampaignIdIntegrationShared) {
		TileDataWrapper.TileData wrapperObj = new TileDataWrapper.TileData();
		wrapperObj.campaignId				= campaignObj.Id;
		wrapperObj.id						= campaignObj.Id;
		wrapperObj.defaultDescription 		= campaignObj.Description__c;
		wrapperObj.url				 		= campaignObj.URL__c;
		wrapperObj.isActive				 	= campaignObj.Is_Active__c;
		if(String.isNotBlank(campaignObj.URL_Preview_Json__c)) {
			wrapperObj.oembed = (OembedModel)JSON.deserialize(campaignObj.URL_Preview_Json__c, OembedModel.class);
		}
		wrapperObj.defaultDescription 		= campaignObj.Description__c;
		wrapperObj.createdBy = new PeopleListWrapper();
		wrapperObj.createdBy.Id 			= campaignObj.People__c;
        wrapperObj.createdBy.userId			= campaignObj.People__r.User__r.Id;
        wrapperObj.createdBy.peopleId 		= campaignObj.People__c;
        wrapperObj.createdBy.name 			= campaignObj.People__r.Full_Name__c;
        wrapperObj.createdBy.img 			= Utility.getProfilePhotoURL(campaignObj.People__r.User__r.SmallPhotoUrl);
        wrapperObj.createdBy.url 			= PageContext.getPageURL(Pages.app) + '?u=/people/' + campaignObj.People__c;
    	wrapperObj.createdBy.title 			= SimpplrContext.isPPTitleDisplay ? campaignObj.People__r.title__c : null;
	    wrapperObj.createdBy.location 		= Utility.buildLocation(campaignObj.People__r.city__c,campaignObj.People__r.state__c,campaignObj.People__r.country__c);
        wrapperObj.createdBy.isFollowing 	= UserContext.usersIFollowIdSet.contains(wrapperObj.createdBy.userId);
		wrapperObj.createdBy.department		= SimpplrContext.isPPDepartmentDisplay ? campaignObj.People__r.Department__c : null;
    	
    	if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			wrapperObj.createdBy.videoCallUsername = campaignObj.People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			wrapperObj.createdBy.videoCallUsername = campaignObj.People__r.Skype_Id__c;
		}
		wrapperObj.createdBy.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		wrapperObj.networks = new CampaignWrapper.NetworksWrapper();
		if(campaignObj.Facebook_Share_Enabled__c) {
			wrapperObj.networks.facebook = new CampaignWrapper.NetworkWrapper();
			wrapperObj.networks.facebook.isEnabled = campaignObj.Facebook_Share_Enabled__c;
			wrapperObj.networks.facebook.hasShared = mapCampaignIdIntegrationShared.containsKey(campaignObj.Id) ? mapCampaignIdIntegrationShared.get(campaignObj.Id).contains(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK) : null;
			wrapperObj.networks.facebook.shareCount = (Integer)campaignObj.Total_Facebook_Share_Count__c;
		}
		if(campaignObj.Twitter_Share_Enabled__c) {
			wrapperObj.networks.twitter = new CampaignWrapper.NetworkWrapper();
			wrapperObj.networks.twitter.isEnabled = campaignObj.Twitter_Share_Enabled__c;
			wrapperObj.networks.twitter.hasShared = mapCampaignIdIntegrationShared.containsKey(campaignObj.Id) ? mapCampaignIdIntegrationShared.get(campaignObj.Id).contains(IntegrationConstants.INTEGRATION_TYPE_TWITTER) : null;
			wrapperObj.networks.twitter.shareCount = (Integer)campaignObj.Total_Twitter_Share_Count__c;
		}
		if(campaignObj.LinkedIn_Share_Enabled__c) {
			wrapperObj.networks.linkedIn = new CampaignWrapper.NetworkWrapper();
			wrapperObj.networks.linkedIn.isEnabled = campaignObj.LinkedIn_Share_Enabled__c;
			wrapperObj.networks.linkedIn.hasShared = mapCampaignIdIntegrationShared.containsKey(campaignObj.Id) ? mapCampaignIdIntegrationShared.get(campaignObj.Id).contains(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN) : null;
			wrapperObj.networks.linkedIn.shareCount = (Integer)campaignObj.Total_LinkedIn_Share_Count__c;
		}
		return wrapperObj;
		
	}
	
	public CampaignWrapper convertToWrapper(Social_Campaign__c campaignObj, 
			Map<Id, set<String>> mapCampaignIdIntegrationShared, Map<String, Active_Directory_Group__c> adIdToADObjectMap) {
		CampaignWrapper wrapperObj = new CampaignWrapper();
		wrapperObj.campaignId				= campaignObj.Id;
		wrapperObj.defaultDescription 		= campaignObj.Description__c;
		wrapperObj.url				 		= campaignObj.URL__c;
		wrapperObj.isActive				 		= campaignObj.Is_Active__c;
		wrapperObj.socialCampIdSet.add(campaignObj.Id);
		system.debug('>convertToWrapper>>>>>293>>>wrapperObj.socialCampIdSet' + wrapperObj.socialCampIdSet);

		if(String.isNotBlank(campaignObj.URL_Preview_Json__c)) {
			wrapperObj.oembed = (CampaignWrapper.OembedWrapper)JSON.deserialize(campaignObj.URL_Preview_Json__c, CampaignWrapper.OembedWrapper.class);
		}
		wrapperObj.defaultDescription 		= campaignObj.Description__c;
		
		wrapperObj.createdAt				= Utility.dateToDisplayString(campaignObj.createdDate,
													'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		wrapperObj.createdBy.Id 			= campaignObj.People__c;
        wrapperObj.createdBy.userId			= campaignObj.People__r.User__r.Id;
        wrapperObj.createdBy.peopleId 		= campaignObj.People__c;
        wrapperObj.createdBy.name 			= campaignObj.People__r.Full_Name__c;
        wrapperObj.createdBy.img 			= Utility.getProfilePhotoURL(campaignObj.People__r.User__r.SmallPhotoUrl);
        wrapperObj.createdBy.url 			= PageContext.getPageURL(Pages.app) + '?u=/people/' + campaignObj.People__c;
		wrapperObj.createdBy.title 			= SimpplrContext.isPPTitleDisplay ? campaignObj.People__r.title__c : null;
	    wrapperObj.createdBy.location 		= Utility.buildLocation(campaignObj.People__r.city__c,campaignObj.People__r.state__c,campaignObj.People__r.country__c);
        wrapperObj.createdBy.isFollowing 	= UserContext.usersIFollowIdSet.contains(wrapperObj.createdBy.userId);
		wrapperObj.createdBy.department		= SimpplrContext.isPPDepartmentDisplay ? campaignObj.People__r.Department__c : null;
    	
    	if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			wrapperObj.createdBy.videoCallUsername = campaignObj.People__r.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
			wrapperObj.createdBy.videoCallUsername = campaignObj.People__r.Skype_Id__c;
		}
		wrapperObj.createdBy.videoCallProvider = SimpplrContext.PPVideoProvider;
		
		if(campaignObj.Facebook_Share_Enabled__c) {
			wrapperObj.networks.facebook = new CampaignWrapper.NetworkWrapper();
			wrapperObj.networks.facebook.isEnabled = campaignObj.Facebook_Share_Enabled__c;
			wrapperObj.networks.facebook.hasShared = mapCampaignIdIntegrationShared.containsKey(campaignObj.Id) ? mapCampaignIdIntegrationShared.get(campaignObj.Id).contains(intTypeFacebook) : null;
			wrapperObj.networks.facebook.shareCount = (Integer)campaignObj.Total_Facebook_Share_Count__c;
		}
		if(campaignObj.Twitter_Share_Enabled__c) {
			wrapperObj.networks.twitter = new CampaignWrapper.NetworkWrapper();
		wrapperObj.networks.twitter.isEnabled = campaignObj.Twitter_Share_Enabled__c;
		wrapperObj.networks.twitter.hasShared = mapCampaignIdIntegrationShared.containsKey(campaignObj.Id) ? mapCampaignIdIntegrationShared.get(campaignObj.Id).contains(intTypeTwitter) : null;
		wrapperObj.networks.twitter.shareCount = (Integer)campaignObj.Total_Twitter_Share_Count__c;
		}
		if(campaignObj.LinkedIn_Share_Enabled__c) {
			wrapperObj.networks.linkedIn = new CampaignWrapper.NetworkWrapper();
		wrapperObj.networks.linkedIn.isEnabled = campaignObj.LinkedIn_Share_Enabled__c;
		wrapperObj.networks.linkedIn.hasShared = mapCampaignIdIntegrationShared.containsKey(campaignObj.Id) ? mapCampaignIdIntegrationShared.get(campaignObj.Id).contains(intTypeLinkedIn) : null;
		wrapperObj.networks.linkedIn.shareCount = (Integer)campaignObj.Total_LinkedIn_Share_Count__c;
		}
		
		wrapperObj.isInHomeCarousel = false;
		if(campaignObj.Simpplr_Carousel_Campaigns__r.isEmpty() == false) {
			wrapperObj.isInHomeCarousel = true;
		}
		wrapperObj.recipient = campaignObj.Recipient__c;
		if('segment'.equalsIgnoreCase(campaignObj.Recipient__c)) {
			wrapperObj.segment = new SegmentWrapper();
			if(String.isBlank(campaignObj.Audience__c) || String.isBlank(campaignObj.Audience__r.Segment__c)) {
				wrapperObj.segment.isDeleted = true;
			} else {
				wrapperObj.segment.id = campaignObj.Audience__r.Segment__c;
				wrapperObj.segment.name = campaignObj.Audience__r.Segment__r.name__c;
			}
		} else if('audience'.equalsIgnoreCase(campaignObj.Recipient__c)) {
			AudienceService audServiceObj = new AudienceService();
			wrapperObj.audience = audServiceObj.getAudienceByIdAndRuleJSON(campaignObj.Audience__r, adIdToADObjectMap);
			
			if(String.isNotBlank(campaignObj.Audience__r.Segment__c)) {
				wrapperObj.segment = new SegmentWrapper();
				wrapperObj.segment.id = campaignObj.Audience__r.Segment__c;
				wrapperObj.segment.name = campaignObj.Audience__r.Segment__r.name__c;
			}
		} else if('everyone'.equalsIgnoreCase(campaignObj.Recipient__c)) {
			wrapperObj.audience = null;
			wrapperObj.segment = null;
		}

		return wrapperObj;
	}
	
 	public String getFilterCondition(String filter, Boolean excludeAudienceCampaigns) {
		String queryStr = ' Where Is_Deleted__c = false ';
		
		if('all'.equalsIgnoreCase(filter)) {
			//Return all
 		} else if('expired'.equalsIgnoreCase(filter)) {
			queryStr += ' And Is_Active__c = false ';
		} else {
			queryStr += ' And Is_Active__c = true ';
		}
		
		if(excludeAudienceCampaigns) {
			queryStr += ' And Audience__c = null ';
		} else {
			if(!UserContext.hasManageCampaignAccess) { 
				queryStr += ' And (Audience__c = null OR Audience__c = :audienceIdSet) ';
			}
		}
		return queryStr;
	}
	
	private String getSortOrderCondition(String sortby){
		String queryStr = '';
		if ('latest'.equalsIgnoreCase(sortby)) {
        		queryStr += ' Order by CreatedDate desc '; 
        	
		} else if ('popular'.equalsIgnoreCase(sortby)) {
        		queryStr += ' Order by Total_Active_Network_Share_Count__c desc, CreatedDate desc '; 	
        		
		} else{
			//Add default sort order
			queryStr += ' Order by CreatedDate desc '; 
		}
        return queryStr;
	}
	
	private String getLimitOffsetCondition(Integer recordLimit, Integer offset){
		String	queryStr = '';
		if(recordLimit!=null && offset!=null) {
			queryStr += ' limit :recordLimit  offset :offset';
		}
		return queryStr;
	}	
	
	public List<String> getCampaignFieldList() {
    		return New List<String>{
			'Id',
			'createdDate',
            'Description__c',
            'Is_Deleted__c',
			'Recipient__c',
			'Audience__c',
            'Audience__r.Is_Deleted__c',
            'Url__c',
            'Is_Active__c',
            'URL_Preview_Json__c',
			'Audience__r.Name__c',
            'Audience__r.Segment__c',
            'Audience__r.segment__r.name__c',
            'Audience__r.Audience_Rule_Json__c',
            'People__c',
            'People__r.Full_Name__c', 
            'People__r.Email__c',
            'People__r.Department__c',
            'People__r.title__c',
			'People__r.city__c',
			'People__r.state__c',
			'People__r.country__c',
            'People__r.User__r.Id',
            'People__r.User__r.SmallPhotoUrl',
            'People__r.User__r.IsActive',
            'People__r.Skype_Id__c',
            'People__r.Zoom_Id__c',
            'Facebook_Share_Enabled__c',
            'LinkedIn_Share_Enabled__c',
            'Twitter_Share_Enabled__c',
            'Total_Facebook_Share_Count__c',
            'Total_LinkedIn_Share_Count__c',
            'Total_Twitter_Share_Count__c',
            '(Select id, Site__c from  Simpplr_Carousel_Campaigns__r where Is_Deleted__c = false and Site__c=null)'
        };
    }	   
}