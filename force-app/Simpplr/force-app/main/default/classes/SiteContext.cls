/*
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SiteContext {
	
	// July5 code refactoring - Do we really need default site id?? - Ajay 
	public static final String SIMPPLR_DEFAULT_SITE_ID = 'S06I000000MPPLR';
	
	public static String siteId{
		get{ 
			if(ApexPages.currentPage()==null && SimpplrContext.isRESTServiceContext != true){
				throw new SimpplrException(ExceptionCode.SITE_CONTEXT_NOT_AVAILABLE.name());
			}
			if(String.isBlank(siteId) && SimpplrContext.isRESTServiceContext != true) {
				siteId = ApexPages.currentPage().getParameters().get('siteId'); 
			}
			if(String.isBlank(siteId)){
				siteId = ''; // TODO - should we throw 404 Exception?? - Ajay
			}
			return siteId;
		}set;
	}
	
	public static String chatterGroupId{
		get{
			if(chatterGroupId == null){
				if(currentSiteRecord != null && !String.isBlank(currentSiteRecord.chatter_Group_id__c)){
					chatterGroupId = currentSiteRecord.chatter_Group_id__c;
				}
			}
			return chatterGroupId;
		}private set;
	}
	
	public static String siteName{
		get{
			try{
			if(siteName == null){
				siteName = '';
				if(currentSiteRecord!=null){
					siteName = currentSiteRecord.Name;
				}
			}
			}catch(Exception e){
				siteName = '';
			}
			return siteName;
		}private set;
	}
	
	public static Boolean isPrivateSite{
		get{
			if(isPrivateSite == null){
				isPrivateSite = false;
				if(currentChatterGroup != null){
					if(currentChatterGroup.CollaborationType.equalsIgnoreCase('Private')){
						isPrivateSite = true;
					}
				}
			}
			return isPrivateSite;
		}private set;
	}
	
	public static Boolean isBroadcastSite{
		get{
			if(isBroadcastSite == null){
				isBroadcastSite = false;
				if(currentChatterGroup != null){
					if(currentChatterGroup.IsBroadcast){
						isBroadcastSite = true;
					}
				}
			}
			return isBroadcastSite;
		}private set;
	}
	@TestVisible
	public static Boolean isUnlistedSite{
		get{
			if(isUnlistedSite == null){
				isUnlistedSite = false;
				if(currentSiteRecord != null){
					if(currentSiteRecord.Site_Type__c.equalsIgnoreCase('Unlisted')){
						isUnlistedSite = true;
					}
				}
			}
			return isUnlistedSite;
		}private set;
	}
	@TestVisible
	public static Boolean isPublicSite{
		get{
			if(isPublicSite == null){
				isPublicSite = false;
				if(currentChatterGroup != null){
					if(currentChatterGroup.CollaborationType.equalsIgnoreCase('Public')){
						isPublicSite = true;
					}
				}
			}
			return isPublicSite;
		}private set;
	}

	public static String currentSiteOwnerUserId{
		get{
			if(currentSiteOwnerUserId == null){
				if(currentChatterGroup != null){
					currentSiteOwnerUserId = currentChatterGroup.OwnerId;
				}
			}
			return currentSiteOwnerUserId;
		}private set;
	}
	
	public static Boolean isCurrentUserSiteOwner{
		get{
			if(isCurrentUserSiteOwner == null){
				isCurrentUserSiteOwner = false;
				if(currentChatterGroup != null){
					if(UserInfo.getUserId().equalsIgnoreCase(currentChatterGroup.OwnerId)){
						isCurrentUserSiteOwner = true;
					}
				}
			}
			return isCurrentUserSiteOwner;
		}private set;
	}
	
	public static Site_Role__c currentSiteRoleRecordWRTLoggedUser{
		get{
			
			if(currentSiteRoleRecordWRTLoggedUser == null){
				List<Site_Role__c> listOfSiteRoles = new List<Site_Role__c>();
				
				if(String.isNotBlank(SiteContext.siteId) && !'home'.equalsIgnoreCase(SiteContext.siteId)){
					listOfSiteRoles.addAll([Select Id,Is_Manager__c, Is_Content_Manager__c
					               FROM Site_Role__c 
								   WHERE Site__c = :SiteContext.siteId AND People__c = :UserContext.peopleId AND Is_Deleted__c = false]);
				}
				
				if(listOfSiteRoles!=null && listOfSiteRoles.size() > 0){
					currentSiteRoleRecordWRTLoggedUser = listOfSiteRoles[0];
				}
			}
			return currentSiteRoleRecordWRTLoggedUser;
		}private set;
	}

	//TODO (used in SiteDashboardctrl used to validate if logged in user in site manager)
	public static Boolean isCurrentUserSiteManager{
		get{
			if(isCurrentUserSiteManager == null){
				isCurrentUserSiteManager = false;
					
				if(currentSiteRoleRecordWRTLoggedUser != null && currentSiteRoleRecordWRTLoggedUser.Is_Manager__c != null) {
					isCurrentUserSiteManager = currentSiteRoleRecordWRTLoggedUser.Is_Manager__c;
				}
			}
			return isCurrentUserSiteManager;
		}private set;
	}

	public static Boolean isCurrentUserSiteContentManager{
		get{
			if(isCurrentUserSiteContentManager == null){
				isCurrentUserSiteContentManager = false;
					
				if(currentSiteRoleRecordWRTLoggedUser != null && currentSiteRoleRecordWRTLoggedUser.Is_Content_Manager__c != null) {
					isCurrentUserSiteContentManager = currentSiteRoleRecordWRTLoggedUser.Is_Content_Manager__c;
				}
			}
			return isCurrentUserSiteContentManager;
		}private set;
	}
	
	public static Boolean hasPages{
		get{
			hasPages = false;
			if(currentSiteRecord!=null) {
				hasPages = currentSiteRecord.Has_Pages__c;
			}
			return hasPages;
		}private set;
	}
	
	public static Boolean hasEvents{
		get{
			hasEvents = false;
			if(currentSiteRecord!=null) {
				hasEvents = currentSiteRecord.Has_Events__c;
			}
			return hasEvents;
		}private set;
	}
	
	public static Boolean hasAlbums{
		get{
			hasAlbums = false;
			if(currentSiteRecord!=null) {
				hasAlbums = currentSiteRecord.Has_Albums__c;
			}
			return hasAlbums;
		}private set;
	}
	public static String siteAllowedFeatures{
		get{
			if(siteAllowedFeatures == null){
				if(currentSiteRecord!=null){
					
					String allowedFeaturesString = '';
					
					
					if(String.isNotBlank(currentSiteRecord.Landing_Page__c)) {
						allowedFeaturesString += currentSiteRecord.Landing_Page__c + ',';
					}
					
					if(SimpplrContext.isFeedEnabled && !'Feed'.equalsIgnoreCase(currentSiteRecord.Landing_Page__c)) {
						allowedFeaturesString += 'Feed,';
					}
					
					if(currentSiteRecord.Has_Pages__c && !'Page'.equalsIgnoreCase(currentSiteRecord.Landing_Page__c)) {
						allowedFeaturesString += 'Page,';
					}
					if(currentSiteRecord.Has_Events__c && !'Event'.equalsIgnoreCase(currentSiteRecord.Landing_Page__c)) {
						allowedFeaturesString += 'Event,';
					}
					if(currentSiteRecord.Has_Albums__c && !'Album'.equalsIgnoreCase(currentSiteRecord.Landing_Page__c)) {
						allowedFeaturesString += 'Album,';
					}
					
					if(!'File'.equalsIgnoreCase(currentSiteRecord.Landing_Page__c)) {
						allowedFeaturesString += 'File,';
					}
					if(!'About'.equalsIgnoreCase(currentSiteRecord.Landing_Page__c)) {
						allowedFeaturesString += 'About';
					}
					
    				siteAllowedFeatures = '';
    				if(String.isNotBlank(allowedFeaturesString) && String.isNotBlank(SimpplrContext.AllowedFeatures)) {
						Set<String> setOfAppAllowedFeatures = new Set<String>(SimpplrContext.AllowedFeatures.tolowerCase().split(','));
						List<String> listOfSiteAllowedFeatures = allowedFeaturesString.split(',');
	    				for(String featureName : listOfSiteAllowedFeatures) {
	    					// Exempt dashboard, feeds and about as they are always allowed on application level
	    					if(setOfAppAllowedFeatures.contains(featureName.toLowerCase()) ||
		    					 ('dashboard'.equalsIgnoreCase(featureName.toLowerCase())) ||
		    					 (SimpplrContext.isFeedEnabled && 'feed'.equalsIgnoreCase(featureName.toLowerCase())) ||
		    					 ('about'.equalsIgnoreCase(featureName.toLowerCase()))
	    					 	) {
	    						siteAllowedFeatures +=  featureName + ',';
	    					}
	    				}
	    				siteAllowedFeatures.removeEnd(',');
    				} 
				}else{
					// if sitecontext is null then return features enabled by App Manager. 
					siteAllowedFeatures = 'dashboard,feed,' + SimpplrContext.AllowedFeatures + ',about';
				}
    		}
			return siteAllowedFeatures;    		
    	}private set;
	}
	
	@TestVisible
	public static String fileStorageSource {
		get{
			if(fileStorageSource == null){ 
				if(currentSiteRecord != null){
					fileStorageSource = currentSiteRecord.File_Storage_Source__c;
				}
			}
			return fileStorageSource;
		}private set;
	}
	
     public static Boolean isCurrentGroupArchived{
    	get{
	    	if(isCurrentGroupArchived == null){
	    		if(currentChatterGroup != null){
	    			isCurrentGroupArchived = currentChatterGroup.IsArchived;
	    		}
	    	}
	    	return isCurrentGroupArchived;
    	}private set;
    }
  
     public static Boolean isFeedActive{
    	get{
	    	if(isFeedActive == null){
	    		if(currentSiteRecord != null){
	    			isFeedActive = currentSiteRecord.Feed_Enabled__c;
	    		}
	    	}
	    	return isFeedActive;
    	}private set;
    }
    
    public static String tileLayout{
    	get{
	    	if(tileLayout == null){
	    		if(currentSiteRecord != null){
	    			tileLayout = currentSiteRecord.Layout__c;
	    		}
	    	}
	    	return tileLayout;
    	}private set;
    }
    
    public static String carouselLayout{
    	get{
	    	if(carouselLayout == null){
	    		if(currentSiteRecord != null){
	    			carouselLayout = currentSiteRecord.Carousel_Layout__c;
	    		}
	    	}
	    	return carouselLayout;
    	}private set;
    }
    
    public static Boolean isTilesInitialized{
    	get{
	    	if(isTilesInitialized == null){
	    		if(currentSiteRecord != null){
	    			isTilesInitialized = currentSiteRecord.Tiles_Initialized__c;
	    		}
	    	}
	    	return isTilesInitialized;
    	}private set;
    }

	@TestVisible
     public static Boolean isActive{
    	get{
	    	if(isActive == null){
	    		
				if(currentSiteRecord!=null) {
					isActive = currentSiteRecord.Is_Active__c;
				} else {
					throw new SimpplrException(ServiceConstants.ERROR_404);
				}
	    	}	
	    	return isActive;
    	}private set;
    }

     public static Boolean isFeatured{
    	get{
	    	if(isFeatured == null){
	    		if(currentSiteRecord != null){
	    			isFeatured = currentSiteRecord.Is_Featured__c;
	    		}
	    	}
	    	return isFeatured;
    	}private set;
    }
     public static Boolean isFollowMandatory{
    	get{
	    	if(isFollowMandatory == null){
	    		if(currentSiteRecord != null){
	    			isFollowMandatory = !currentSiteRecord.Subscription_Entity_Site__r.isEmpty();
	    		}
	    	}
	    	return isFollowMandatory;
    	}private set;
    }
    
    public static String currentSiteCategoryId{
    	get{
    		if(currentSiteCategoryId == null){
    			if(currentSiteRecord != null){
    				currentSiteCategoryId = currentSiteRecord.Site_Category__c;
    			}
    		}
    		return currentSiteCategoryId;
    	}private set;
    }
    public static String currentSiteCategoryName {
    	get{
    		if(currentSiteCategoryName == null){
    			if(currentSiteRecord != null){
    				currentSiteCategoryName = currentSiteRecord.Site_Category__r.Name__c;
    			}
    		}
    		return currentSiteCategoryName;
    	}private set;
    }
    
     public static String currentSiteType{
    	get{
    		if(currentSiteType == null){
    			if(currentSiteRecord != null){
    				currentSiteType = currentSiteRecord.Site_Type__c;
    			}
    		}
    		return currentSiteType;
    	}private set;
    }
    
    public static String siteOrigin{
    	get{
	    	if(siteOrigin == null){
	    		if(currentSiteRecord != null){
	    			tileLayout = currentSiteRecord.Origin__c;
	    		}
	    	}
	    	return siteOrigin;
    	}private set;
    }
    
    public static Boolean showInSimpplr{
    	get{
	    	if(showInSimpplr == null){
	    		if(currentSiteRecord != null){
	    			showInSimpplr = currentSiteRecord.Show_In_Simpplr__c;
	    		}
	    	}
	    	return showInSimpplr;
    	}private set;
    }
    
    public static String landingPage {
    	get{
	    	if(landingPage == null){
	    		if(currentSiteRecord != null){
	    			landingPage = currentSiteRecord.Landing_Page__c;
	    		}
	    	}
	    	return landingPage;
    	}private set;
    }
      
    public static Simpplr_Site__c currentSiteRecord{
		get{
			
			if(currentSiteRecord == null){
				List<Simpplr_Site__c> listOfSites = new List<Simpplr_Site__c>();
				
				if(String.isNotBlank(SiteContext.siteId) && !'home'.equalsIgnoreCase(SiteContext.siteId)){
					listOfSites.addAll([Select Name, Id,File_Storage_Source__c,
					               Allow_Public_Contribution__c, Origin__c, Show_In_Simpplr__c,
					               Is_Active__c,Is_Featured__c, Question_Answer_Enabled__c,
					               Site_Category__c,Site_Category__r.Name__c, Site_Type__c, Title_Content_Version__c,
								   Has_Albums__c, Has_Events__c, Has_Pages__c, Landing_Page__c, Chatter_Group_Id__c,
								   Layout__c, Carousel_Layout__c, Tiles_Initialized__c, 
									Feed_Enabled__c, Allow_Follow__c, Allow_Comments__c, Microsoft_Teams_Webhook_URL__c, Microsoft_Teams_Integration_Enabled__c,
									Slack_Access_Token__c, Slack_Channel_Id__c, Slack_Comment_Enabled__c, Slack_Integration_Enabled__c, Slack_Post_Enabled__c, 
									Slack_Channel_Name__c, Slack_Url__c, Is_Leadercast_Enabled__c, 
								   (SELECT Id FROM Subscription_Entity_Site__r WHERE Status__c = 'Approved' AND Subscription__r.Action_Type__c = 'mandatory' 
								   	AND Subscription__r.Status__c != 'Deleted'
								   	AND (Subscription__r.Audience__r.Segment__c = :UserContext.segmentId OR Subscription__r.Audience__r.Segment__c = null) LIMIT 1) 
								   FROM Simpplr_Site__c 
								   WHERE is_Active__c=true and is_Deleted__c = false and Id=:SiteContext.siteId]);
				}
				
				if(listOfSites!=null && listOfSites.size() > 0){
					currentSiteRecord = listOfSites[0];
				}
			}
			return currentSiteRecord;
		}private set;
	}

	public static Boolean isQuestionAnswerEnabled{
		get{
			if(isQuestionAnswerEnabled == null) {
				isQuestionAnswerEnabled = false;
				if(currentSiteRecord != null) {
					isQuestionAnswerEnabled = SimpplrContext.isQuestionAnswerEnabled && currentSiteRecord.Question_Answer_Enabled__c == true;
				}
			}
			return isQuestionAnswerEnabled;
		}private set;
	}
	
	public static String CurrentSiteSmallPhotoUrl{
		get{
			
			if(CurrentSiteSmallPhotoUrl == null){
				CurrentSiteSmallPhotoUrl = '';
				try{
					if(currentSiteRecord != null){
						CurrentSiteSmallPhotoUrl = String.isBlank(currentSiteRecord.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(currentSiteRecord.Title_Content_Version__c);
					}
				}catch(Exception e){
				}
			}
			return CurrentSiteSmallPhotoUrl;
		}private set;
	}
	
	public static String CurrentsiteFullPhotoUrl {
		get{
			if(CurrentsiteFullPhotoUrl == null){
				CurrentsiteFullPhotoUrl = '';
				try{
					if(currentSiteRecord != null){
						CurrentsiteFullPhotoUrl = String.isBlank(currentSiteRecord.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(currentSiteRecord.Title_Content_Version__c);
					}
				}catch(Exception e){
				}
			}
			return CurrentsiteFullPhotoUrl;
		}private set;
    }
    
    public static String currentSitePhotoDownloadUrl {
		get{
			if(currentSitePhotoDownloadUrl == null){
				currentSitePhotoDownloadUrl = '';
				try{
					if(currentSiteRecord != null){
						currentSitePhotoDownloadUrl = String.isBlank(currentSiteRecord.Title_Content_Version__c)? null :Utility.getFileDownloadURL(currentSiteRecord.Title_Content_Version__c);
					}
				}catch(Exception e){
				}
			}
			return currentSitePhotoDownloadUrl;
		}private set;
    }
    
	public static CollaborationGroup currentChatterGroup{
		get{
			if(currentChatterGroup == null){
				if(currentSiteRecord != null && !String.isBlank(currentSiteRecord.chatter_Group_id__c)){
					String groupId = currentSiteRecord.chatter_Group_id__c;
					List<CollaborationGroup> CollaborationGroupList = new List<CollaborationGroup>();
					String BASE_QUERY= 'SELECT Id, CollaborationType, IsBroadcast, Name, Description,FullPhotoUrl, HasPrivateFieldsAccess, InformationBody,InformationTitle, IsArchived, MemberCount, OwnerId, Owner.name, SmallPhotoUrl FROM CollaborationGroup Where Id= : groupId ';
					if(SimpplrContext.isCommunitiesEnabled){
			    		BASE_QUERY = BASE_QUERY+'AND NetworkId = null';
			    	}
					CollaborationGroupList = Database.query(BASE_QUERY);
					if(CollaborationGroupList.size() > 0){
						currentChatterGroup = CollaborationGroupList[0];
					}
				}
			}
			return currentChatterGroup;
		}private set;
	}
	
	public static Boolean isCommentsAllowed{
	    	get{
		    	if(isCommentsAllowed == null){
		    		if(currentSiteRecord != null){
		    			isCommentsAllowed = currentSiteRecord.Allow_Comments__c;
		    		}
		    	}
		    	if(SimpplrContext.isCommentsAllowed == false) {
		    		isCommentsAllowed = false;
		    	}
		    	return isCommentsAllowed;
	    	}private set;
    }
    
	public static Boolean isPublicContributionAllowed{
	    	get{
		    	if(isPublicContributionAllowed == null){
						isPublicContributionAllowed = false;
		    		if(currentSiteRecord != null){
		    			isPublicContributionAllowed = currentSiteRecord.Allow_Public_Contribution__c;
		    		}
		    	}
		    	return isPublicContributionAllowed;
	    	}private set;
    }
    
	public static Boolean MicrosoftTeamsIntegrationEnabled{
    	get{
	    	if(MicrosoftTeamsIntegrationEnabled == null){
	    		if(currentSiteRecord != null){
	    			MicrosoftTeamsIntegrationEnabled = currentSiteRecord.Microsoft_Teams_Integration_Enabled__c;
	    		}
	    	}
	    	return MicrosoftTeamsIntegrationEnabled;
    	}private set;
	}
	
	public static String MicrosoftTeamsWebhookUrl{
    	get{
	    	if(MicrosoftTeamsWebhookUrl == null){
	    		if(currentSiteRecord != null){
	    			MicrosoftTeamsWebhookUrl = currentSiteRecord.Microsoft_Teams_Webhook_URL__c;
	    		}
	    	}
	    	return MicrosoftTeamsWebhookUrl;
    	}private set;
	}	
	    
    /* This property will not be in use
     public static String currentSiteConfigDashboardMode{
    	get{
    		if(currentSiteConfigDashboardMode == null){
    			if(currentSiteRecord != null){
    				currentSiteConfigDashboardMode = currentSiteRecord.Dashboard_Mode__c;
    			}
    		}
    		return currentSiteConfigDashboardMode;
    	}
    }
    */
	
	public static Boolean SlackPostEnabled{
    	get{
	    	if(SlackPostEnabled == null){
	    		if(currentSiteRecord != null){
	    			SlackPostEnabled = currentSiteRecord.Slack_Post_Enabled__c;
	    		}
	    	}
	    	return SlackPostEnabled;
    	}private set;
	}

	/**
	 * @description is leadercast featured enabled for this site
	 * @return Boolean
	 */
	public static Boolean isLeadercastEnabled{
    	get{
	    	if(isLeadercastEnabled == null){
				isLeadercastEnabled = false;
	    		if(currentSiteRecord != null){
	    			isLeadercastEnabled = currentSiteRecord.Is_Leadercast_Enabled__c;
	    		}
	    	}
	    	return isLeadercastEnabled;
    	}private set;
	}	
	
	public static Boolean SlackIntegrationEnabled{
    	get{
	    	if(SlackIntegrationEnabled == null){
	    		if(currentSiteRecord != null){
	    			SlackIntegrationEnabled = currentSiteRecord.Slack_Integration_Enabled__c;
	    		}
	    	}
	    	return SlackIntegrationEnabled;
    	}private set;
	}
	
	public static Boolean SlackCommentEnabled{
    	get{
	    	if(SlackCommentEnabled == null){
	    		if(currentSiteRecord != null){
	    			SlackCommentEnabled = currentSiteRecord.Slack_Comment_Enabled__c;
	    		}
	    	}
	    	return SlackCommentEnabled;
    	}private set;
	}
	
	public static String SlackChannelId{
    	get{
	    	if(SlackChannelId == null){
	    		if(currentSiteRecord != null){
	    			SlackChannelId = currentSiteRecord.Slack_Channel_Id__c;
	    		}
	    	}
	    	return SlackChannelId;
    	}private set;
	}
	public static String SlackChannelName{
    	get{
	    	if(SlackChannelName == null){
	    		if(currentSiteRecord != null){
	    			SlackChannelName = currentSiteRecord.Slack_Channel_Name__c;
	    		}
	    	}
	    	return SlackChannelName;
    	}private set;
	}
	public static String SlackUrl{
    	get{
	    	if(SlackUrl == null){
	    		if(currentSiteRecord != null){
	    			SlackUrl = currentSiteRecord.Slack_Url__c;
	    		}
	    	}
	    	return SlackUrl;
    	}private set;
	}
	
	public static String SlackAccesToken{
    	get{
	    	if(SlackAccesToken == null){
	    		if(currentSiteRecord != null){
	    			SlackAccesToken = currentSiteRecord.Slack_Access_Token__c;
	    		}
	    	}
	    	return SlackAccesToken;
    	}private set;
	}

	public static Boolean canManage() {
		Boolean canManage = false;
		if(UserContext.sitesIManageIdSet.contains(siteId)) {
			canManage = true;

		} else if(isPublicSite && UserContext.isUserAppModerator) {
			canManage = true;

		} else if(isUnlistedSite) {
			canManage = UserContext.hasManageUnlistedSitePermission;

		} else if(UserContext.hasModifyAllDataPermission && UserContext.isUserAppModerator) {
			canManage = true;

		}
		return canManage;
	}

	/**
	 * @description returns list of mandatory Subscription_Entity__c for a site
	 * @return List<Subscription_Entity__c>
	 */	
	public static List<Subscription_Entity__c> siteMandatorySubscriptionEntityList {
		get {
			if(siteMandatorySubscriptionEntityList == null) {
				siteMandatorySubscriptionEntityList = new List<Subscription_Entity__c>();
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', UserContext.segmentId);
				soqlParamMap.put('soqlParam2', SiteContext.siteId);				
				String query = 'SELECT Id, Subscription__r.Audience__c from Subscription_Entity__c ' + 
				'WHERE Subscription__r.Action_Type__c = \'mandatory\' ' + 
				'AND Status__c = \'Approved\' AND Subscription__r.Status__c != \'Deleted\' And ' +
				'(Subscription__r.Audience__r.Segment__c =: soqlParam1 OR ' +
				'Subscription__r.Audience__r.Segment__c = null) AND Site__c =: soqlParam2 AND ' + 
				'Subscription__r.Audience__r.Is_Deleted__c = false';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				siteMandatorySubscriptionEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	
			}
			return siteMandatorySubscriptionEntityList;
		} private set;
	}

	/**
	 * @description returns whether a site has mandatory subscription
	 * @return Boolean
	 */		
	public static Boolean siteHasMandatorySubscription {
    	get{
	    	if(siteHasMandatorySubscription == null){
	    		if(siteMandatorySubscriptionEntityList != null){
	    			siteHasMandatorySubscription = !siteMandatorySubscriptionEntityList.isEmpty();
	    		}
	    	}
	    	return siteHasMandatorySubscription;
    	}private set;
    }
	

	/**
	 * @description returns set of audiences that has mandatory subscription the the site
	 * @return Set<Id>
	 */	
	public static Set<Id> mandatorySubscriptionAudienceIdSet {
		get {
			if(mandatorySubscriptionAudienceIdSet == null) {
				mandatorySubscriptionAudienceIdSet = new Set<Id>();
				if(siteHasMandatorySubscription) {
					for(Subscription_Entity__c subscriptionEntityObj : siteMandatorySubscriptionEntityList) {
						mandatorySubscriptionAudienceIdSet.add(subscriptionEntityObj.Subscription__r.Audience__c);
					}
				}
			}
			return mandatorySubscriptionAudienceIdSet;
		} private set;
	}	

}