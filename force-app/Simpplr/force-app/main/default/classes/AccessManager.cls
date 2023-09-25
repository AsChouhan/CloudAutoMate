/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AccessManager {
	
	
	
	public static final String USER_ROLE_MEMBER = 'MEMBER';
	public static final String USER_ROLE_SITEMANAGER = 'SITEMANAGER';
	public static final String USER_ROLE_APPMODERATOR = 'APPMODERATOR';
	
	public static final String DEFAULT_MEMBER_FEATURES = 'SIMPPLR,FEED,LAUNCHPAD,SITE,MY_SETTINGS,MANAGE_CONTENT,ADD_SITE';
	public static final String DEFAULT_SITEMANAGER_FEATURES = DEFAULT_MEMBER_FEATURES + ',MANAGE_SITE,ANALYTICS';
	public static final String DEFAULT_APPMODERATOR_FEATURES = DEFAULT_SITEMANAGER_FEATURES + ',SYSTEM_SETTINGS,NEWSLETTER';
	
	public static final String FEATURE_ALBUM = 'ALBUM';
	public static final String FEATURE_BLOG = 'BLOG';
	public static final String FEATURE_EVENT = 'EVENT';
	public static final String FEATURE_PAGE = 'PAGE';
	public static final String FEATURE_FEED = 'FEED';
	public static final String FEATURE_FILE = 'FILE';
	public static final String FEATURE_DASHBOARD = 'DASHBOARD';
	
	public static final String FEATURE_SIMPPLR = 'SIMPPLR';
	public static final String FEATURE_LAUNCHPAD = 'LAUNCHPAD';
	public static final String FEATURE_MANAGE_CONTENT = 'MANAGE_CONTENT';
	public static final String FEATURE_MANAGE_SITE = 'MANAGE_SITE';
	public static final String FEATURE_ADD_SITE = 'ADD_SITE';
	public static final String FEATURE_MY_SETTINGS = 'MY_SETTINGS';
	public static final String FEATURE_SYSTEM_SETTINGS = 'SYSTEM_SETTINGS';
	public static final String FEATURE_SITE = 'SITE';
	public static final String FEATURE_ANALYTICS = 'ANALYTICS';
	public static final String FEATURE_NEWSLETTER = 'NEWSLETTER';
	public static final String FEATURE_ALERT = 'ALERT';
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static Boolean isUserAppModerator(String userId){
		logger.logDebug('AccessManager.isUserAppModerator()====userId====' + userId );
		Boolean isUserAppModerator = false;
		
		People__c peopleRec = getUserProfileInfo(userId);
		if(peopleRec != null && !'No'.equalsIgnoreCase(peopleRec.App_Moderation_Permission__c)) {
			if(peopleRec.User__r.profile.PermissionsModerateChatter){
					isUserAppModerator = true;
			}else{
				List<PermissionSetAssignment> permissionSetList = getUserPermissionSetList(userId);
				for(PermissionSetAssignment assignmentObj: permissionSetList) {
					if(assignmentObj.PermissionSet.PermissionsModerateChatter) {
						isUserAppModerator = true;
						break;
					}
				}
			}
		}
		logger.logDebug('AccessManager.isUserAppModerator()====isUserAppModerator====' + isUserAppModerator );	
		return isUserAppModerator;
	}  
	
	public static Boolean hasContentCreateAccess(String siteId, String siteType, Boolean isPublicContributionAllowedAtSiteLevel) {
		Boolean hasContentCreateAccess = false;
		try{
			// Check isPublicContributionAllowed flag
			hasContentCreateAccess = (SimpplrContext.isPublicContributionAllowed && isPublicContributionAllowedAtSiteLevel);
			// if isPublicContributionAllowed == false then check current user is site manager
			if(!hasContentCreateAccess){
				if(UserContext.sitesIManageIdSet.contains(siteId)){
					hasContentCreateAccess = true;
				}
			}
			// if current user is not site manager then check if user is App manager  
			if(!hasContentCreateAccess){
				if(AccessManager.USER_ROLE_APPMODERATOR.equals(UserContext.primaryRole) && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)){
					hasContentCreateAccess = true;
				}
			}
			// if current user has modify All 
			if(!hasContentCreateAccess){
				if(UserContext.hasModifyAllDataPermission && UserContext.isUserAppModerator){
					hasContentCreateAccess = true;
				}
			}
			if(!hasContentCreateAccess){
				if(UserContext.hasManageUnlistedSitePermission && ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteType)) {
					hasContentCreateAccess = true;
				}
			}
		}catch(Exception e){
			logger.logError('AccessManager.hasContentCreateAccess(siteId,siteType,...)----Exception Occured----', e);
			throw new SImpplrException(ServiceConstants.ERROR_403, e);			
		}
		return hasContentCreateAccess;
	}
	
	public static Boolean hasContentCreateAccess() {
		Boolean hasContentCreateAccess = false;
		try{
			// Check isPublicContributionAllowed flag
			hasContentCreateAccess = (SimpplrContext.isPublicContributionAllowed && 
									  SiteContext.isPublicContributionAllowed &&
									  (UserContext.sitesIFollowIdSet.contains(SiteContext.siteId) || SiteContext.isPublicSite == true));
			// if isPublicContributionAllowed == false then check current user is site manager
			if(!hasContentCreateAccess){
				if(UserContext.sitesIManageIdSet.contains(SiteContext.siteId)){
					hasContentCreateAccess = true;
				}
			}			
			// if current user is not site manager then check if user is App manager  
			if(!hasContentCreateAccess){
				if(AccessManager.USER_ROLE_APPMODERATOR.equals(UserContext.primaryRole) && SiteContext.isPrivateSite==false){
					hasContentCreateAccess = true;
				}
			}
			// if current user has modify All 
			if(!hasContentCreateAccess){
				if(UserContext.hasModifyAllDataPermission && UserContext.isUserAppModerator){
					hasContentCreateAccess = true;
				}
			}
			if(!hasContentCreateAccess){
				if(SiteContext.isUnlistedSite==true && UserContext.hasManageUnlistedSitePermission) {
					hasContentCreateAccess = true;
				}
			}
		}catch(Exception e){
			logger.logError('AccessManager.hasContentCreateAccess()----Exception Occured----', e);
			throw new SImpplrException(ServiceConstants.ERROR_403, e);			
		}
		logger.logDebug('AccessManager.hasContentCreateAccess()====' + hasContentCreateAccess );
		return hasContentCreateAccess;
	}
	
	public static Boolean hasContentCreateAccess(String siteId, String siteType, Boolean isPublicContributionAllowedAtSiteLevel, Boolean isMember) {
		Boolean hasContentCreateAccess = false;
		try{
			// Check isPublicContributionAllowed flag
			hasContentCreateAccess = (SimpplrContext.isPublicContributionAllowed && 
									  isPublicContributionAllowedAtSiteLevel && 
									  (isMember || ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)));
			// if isPublicContributionAllowed == false then check current user is site manager
			if(!hasContentCreateAccess){
				if(UserContext.sitesIManageIdSet.contains(siteId)){
					hasContentCreateAccess = true;
				}
			}
			// if isPublicContributionAllowed == false then check current user is site content manager
			if(!hasContentCreateAccess){
				if(UserContext.sitesIManageContentsIdSet.contains(siteId)){
					hasContentCreateAccess = true;
				}
			}
			// if current user is not site manager then check if user is App manager  
			if(!hasContentCreateAccess){
				if(AccessManager.USER_ROLE_APPMODERATOR.equals(UserContext.primaryRole) && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)){
					hasContentCreateAccess = true;
				}
			}
			// if current user has modify All 
			if(!hasContentCreateAccess){
				if(UserContext.hasModifyAllDataPermission && UserContext.isUserAppModerator){
					hasContentCreateAccess = true;
				}
			}
			if(!hasContentCreateAccess){
				if(UserContext.hasManageUnlistedSitePermission && ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteType)) {
					hasContentCreateAccess = true;
				}
			}
		}catch(Exception e){
			logger.logError('AccessManager.hasContentCreateAccess(siteId,siteType,...)----Exception Occured----', e);
			throw new SImpplrException(ServiceConstants.ERROR_403, e);			
		}
		return hasContentCreateAccess;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static Boolean hasContentEditAccess(String contentStatus, Boolean isContentAuthor) {
		Boolean hasContentEditAccess = false;
		Boolean isAppModerator = UserContext.isUserAppModerator;
		Boolean isSiteManager =  UserContext.sitesIManageIdSet.contains(SiteContext.siteId);
		Boolean isSiteContentManager =  UserContext.sitesIManageContentsIdSet.contains(SiteContext.siteId);
		// Only content author can edit DRAFT and REJECTED 		
		if(('Draft'.equalsIgnoreCase(contentStatus) || 'Rejected'.equalsIgnoreCase(contentStatus) || 'PreDraft'.equalsIgnoreCase(contentStatus))){
			if(isContentAuthor) {
				// check isPublicContributionAllowed flag
				if (ServiceConstants.SITE_DASHBOARD_OWNER_APP_MANAGER.equalsIgnoreCase(SimpplrContext.SiteDashboardMode)) {
		    		hasContentEditAccess = SimpplrContext.isPublicContributionAllowed;
		    	} else if (ServiceConstants.DASHBOARD_OWNER_SITE_MANAGER.equalsIgnoreCase(SimpplrContext.SiteDashboardMode)) {
		    		hasContentEditAccess = (SimpplrContext.isPublicContributionAllowed && SiteContext.isPublicContributionAllowed);
		    	}
		    	if(!hasContentEditAccess && ((isAppModerator && SiteContext.isPublicSite) || isSiteManager || isSiteContentManager)) {
		    		hasContentEditAccess = true;
		    	}
			} else if('Rejected'.equalsIgnoreCase(contentStatus) && ((isAppModerator && SiteContext.isPublicSite) || isSiteManager || isSiteContentManager)){
				hasContentEditAccess = true;
			}
		} 
		if(!hasContentEditAccess){
			// if isPublicContributionAllowed == false then check current user is site manager
			if(UserContext.sitesIManageIdSet.contains(SiteContext.siteId) || UserContext.sitesIManageContentsIdSet.contains(SiteContext.siteId)){
				hasContentEditAccess = true;
			}
			
			// if current user is not site manager then check if user is App manager  
			if(!hasContentEditAccess){
				if(AccessManager.USER_ROLE_APPMODERATOR.equals(UserContext.primaryRole)){
					if(!SiteContext.isActive){
						logger.logDebug('AccessManager.hasContentEditAccess().Inactive_Site==== site is - ' + siteContext.siteId);
					    throw new SimpplrException(ServiceConstants.ERROR_404);
					}
					if(SiteContext.isPublicSite) {
						hasContentEditAccess = true;
					} else if(UserContext.hasModifyAllDataPermission) {
						hasContentEditAccess = true;
					}
				}
			}
		}
		logger.logDebug('AccessManager.hasContentEditAccess()====' + hasContentEditAccess );
		return hasContentEditAccess;
	}

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static Boolean hasContentApprovalAccess() {
		Boolean hasContentApprovalAccess = false;
		
		try {
			// if isPublicContributionAllowed == false then check current user is site manager
			if(UserContext.sitesIManageIdSet.contains(SiteContext.siteId) || UserContext.sitesIManageContentsIdSet.contains(SiteContext.siteId)){
				hasContentApprovalAccess = true;
			}
			
			// if current user is not site manager then check if user is App manager  
			if(!hasContentApprovalAccess){
				if(!SiteContext.isActive){
					logger.logDebug('AccessManager.hasContentApprovalAccess().Inactive_Site==== site is - ' + siteContext.siteId);
				    throw new SimpplrException(ServiceConstants.ERROR_404);
				}
				if(AccessManager.USER_ROLE_APPMODERATOR.equals(UserContext.primaryRole) && SiteContext.isPublicSite) {
					hasContentApprovalAccess = true;
				
				} else if(UserContext.hasModifyAllDataPermission && UserContext.isUserAppModerator){
					hasContentApprovalAccess = true;

				} else if(SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission) {
					hasContentApprovalAccess = true;
				
				} 
			}
		}
		catch(Exception e) {
			logger.logError('Exception occurred in site configuration while checking for content approval access!',e);
		}
		logger.logDebug('AccessManager.hasContentApprovalAccess()====' + hasContentApprovalAccess );
		return hasContentApprovalAccess;
	}
	
	public static Boolean hasContentApprovalAccess(String siteId, Boolean isPublicSite) {
		Boolean hasContentApprovalAccess = false;
		try {
			if(UserContext.sitesIManageIdSet.contains(siteId) || UserContext.sitesIManageContentsIdSet.contains(siteId)){
				hasContentApprovalAccess = true;
			} else if(isPublicSite && UserContext.isUserAppModerator){
				hasContentApprovalAccess = true;	

			} else if(UserContext.hasModifyAllDataPermission && UserContext.isUserAppModerator){
				hasContentApprovalAccess = true;
			}
		} catch(Exception e) {
			logger.logError('AccessManager.hasContentApprovalAccess(siteId)----Exception Occured----',e);
		}
		return hasContentApprovalAccess;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static Boolean hasUserManageSiteAccess(String currentSiteId) {
		Boolean hasUserManageSiteAccess = false;
		if(String.isNotBlank(currentSiteId)) {
			try {
				// if isPublicContributionAllowed == false then check current user is site manager
				if(UserContext.sitesIManageIdSet.contains(SiteContext.siteId)){
					hasUserManageSiteAccess = true;
				}
				
				// if current user is not site manager then check if user is App manager  
				if(!hasUserManageSiteAccess){
					if(AccessManager.USER_ROLE_APPMODERATOR.equals(UserContext.primaryRole)){
						if(!SiteContext.isActive){
							logger.logDebug('AccessManager.hasUserManageSiteAccess().Inactive_Site==== site is - ' + siteContext.siteId);
						    throw new SimpplrException(ServiceConstants.ERROR_404);
						}
						if(SiteContext.isPublicSite) {
							hasUserManageSiteAccess = true;
						} else if(UserContext.hasModifyAllDataPermission && !SiteContext.isUnlistedSite) {
							hasUserManageSiteAccess = true;
						} 
					}
				}
				if(SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission){
					hasUserManageSiteAccess = true;
				}
			}catch(Exception e) {
				logger.logError('Exception occurred in site configuration while checking for site management access!',e);
			}
			logger.logDebug('AccessManager.hasUserManageSiteAccess()====' + hasUserManageSiteAccess );
		}
		return hasUserManageSiteAccess;
	}

	public static Boolean hasUserSiteAccessForAnalytics(String currentSiteId) {
		Boolean hasUserSiteAccessForAnalytics = false;
		if(String.isNotBlank(currentSiteId)) {
			try {
				// if isPublicContributionAllowed == false then check current user is site manager
				if(UserContext.sitesIManageIdSet.contains(SiteContext.siteId)){
					hasUserSiteAccessForAnalytics = true;
				}
				
				// if current user is not site manager then check if user is App manager  
				if(!hasUserSiteAccessForAnalytics){
					if(AccessManager.USER_ROLE_APPMODERATOR.equals(UserContext.primaryRole) || UserContext.canAccessAnalytics || UserContext.hasModifyAllDataPermission){
							hasUserSiteAccessForAnalytics = true;
					}
				}
			}
			catch(Exception e) {
				logger.logError('Exception occurred in site configuration while checking for site management access!',e);
			}
			logger.logDebug('AccessManager.hasUserSiteAccessForAnalytics()====' + hasUserSiteAccessForAnalytics );
		}
		return hasUserSiteAccessForAnalytics;
	}
	
	public static Boolean hasUserManageDashboardAccess(String siteId) {
		Boolean hasUserManageDashboardAccess = false;
		siteId = (String.isBlank(siteId) ? '' : siteId);
		
		if('home'.equalsIgnoreCase(siteId) || String.isBlank(siteId)){
        	if(UserContext.isUserAppModerator){
				hasUserManageDashboardAccess = true;
			}
			else{
				return hasUserManageDashboardAccess = false;
			}
		} else {
			/**
				- Site is private AND logged in user is the owner OR
 				- System Admin User OR
 				- Site is public AND logged in user is App Manager
 				- Site is public AND Site Dashboard is Site Manager controlled AND Logged in user is Site Manager
			**/
			if((SiteContext.isPublicSite == false && SiteContext.isCurrentUserSiteManager) ||
				(SiteContext.isPublicSite && UserContext.isUserAppModerator) ||
				(SiteContext.isPublicSite && 'Site Manager'.equalsIgnoreCase(SimpplrContext.SiteDashboardMode) && SiteContext.isCurrentUserSiteManager) ||
				(SiteContext.isUnlistedSite == false && UserContext.hasModifyAllDataPermission) || 
				(SiteContext.isUnlistedSite == true && UserContext.hasManageUnlistedSitePermission)
				){
				hasUserManageDashboardAccess = true;
			}
		}
		
		return hasUserManageDashboardAccess;
	}
	
	public static Boolean hasSiteAccess() {
		Boolean hasSiteAccess = false;
		if(!SiteContext.isActive){
			logger.logDebug('AccessManager.hasSiteAccess().Inactive_Site==== site is - ' + siteContext.siteId);
		    throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		if(UserContext.hasModifyAllDataPermission && !SiteContext.isUnlistedSite) {
			hasSiteAccess = true;
		} else if(SiteContext.isPublicSite) {
			hasSiteAccess = true;
		} else if(UserContext.sitesIFollowIdSet.contains(SiteContext.siteId)) {
			hasSiteAccess = true;
		} else if(SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission){
			hasSiteAccess = true;
		} 
		logger.logDebug('AccessManager.hasSiteAccess()====' + hasSiteAccess );
		return hasSiteAccess;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static List<PermissionSetAssignment> getUserPermissionSetList(String userId){
		logger.logDebug('AccessManager.getUserPermissionSetList()====userId' + userId );
		List<PermissionSetAssignment> currentUserPermissionSetList = null;
		
		currentUserPermissionSetList = [Select PermissionSet.PermissionsCustomizeApplication,PermissionSet.PermissionsModifyAllData,
											PermissionSet.PermissionsChatterOwnGroups,PermissionSet.PermissionsManageUnlistedGroups,
							   				PermissionSet.PermissionsModerateChatter, PermissionSet.PermissionsCreateTopics 
							   				From PermissionSetAssignment WHERE AssigneeId =:userId];
		
		logger.logDebug('AccessManager.getUserPermissionSetList()====currentUserPermissionSetList' + currentUserPermissionSetList );										   
		return currentUserPermissionSetList;
	}
	
	private static People__c getUserProfileInfo(String userId){
		logger.logDebug('AccessManager.getUserProfileInfo()====userId' + userId );
		People__c peopleObj;
		List<People__c> peopleList = new List<People__c>();
		peopleList = [Select User__c,App_Moderation_Permission__c, User__r.profile.PermissionsCustomizeApplication, User__r.profile.PermissionsModifyAllData,
					User__r.Profile.PermissionsModerateChatter, User__r.Profile.PermissionsCreateTopics FROM People__c WHERE User__c=:userId];
		if(peopleList.size() > 0) {
			peopleObj = peopleList[0];
		}
		logger.logDebug('AccessManager.getUserProfileInfo()====peopleObj' + peopleObj );
		return peopleObj;
	}
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static Boolean hasPageAccess(String pageFeatureName) {
		Boolean returnValue = false;
		
        String allowedFeatures = SiteContext.siteAllowedFeatures + ',' + UserContext.DefaultAllowedFeatures;
        if(allowedFeatures.containsIgnoreCase(pageFeatureName)) {
        	returnValue = true;
        
		} else if(AccessManager.FEATURE_NEWSLETTER.equalsIgnoreCase(pageFeatureName) && (UserContext.canSendNewsletter || UserContext.isUserAppModerator  || UserContext.hasModifyAllDataPermission)){
        	returnValue = true;
        
		} else if(AccessManager.FEATURE_ALERT.equalsIgnoreCase(pageFeatureName) && (UserContext.canSendSiteAlert || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission)){
        	returnValue = true;
        
		} else if(AccessManager.FEATURE_ANALYTICS.equalsIgnoreCase(pageFeatureName) && (UserContext.canAccessAnalytics || UserContext.isUserAppModerator  || UserContext.hasModifyAllDataPermission || UserContext.sitesIManageIdSet.size()>0) || UserContext.sitesIManageContentsIdSet.size() > 0){
        	returnValue = true;
        
		} else if(AccessManager.FEATURE_DASHBOARD.equalsIgnoreCase(pageFeatureName) && Utility.isMobileMode) {
        	returnValue = true;
        
		} else if(String.isNotBlank(SiteContext.siteId) && SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission){
        	returnValue = true;
        
		}
		return returnValue;
	}
	
	// FOLLOWING METHODS COPIED FROM All content dataserver class.
	
	public static Boolean calculatePublishUnpublishAccess (Boolean isSiteManager, Boolean isSiteContentManager, String status, String userId, 
			String siteType){
    	Boolean isAppModerator = UserContext.isUserAppModerator;
    	Boolean canPublishUnpublishBool = false;
    	if (ServiceConstants.CONTENT_STATUS_PUBLISH.equalsIgnoreCase(status) 
          || ServiceConstants.CONTENT_STATUS_UNPUBLISH.equalsIgnoreCase(status)
          || ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(status)
          || ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(status)
          || ServiceConstants.CONTENT_STATUS_PENDING.equalsIgnoreCase(status)){// assuming that draft is only owned by the user who is publishing.
    		if ((isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager 
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))) {
    			canPublishUnpublishBool = true;
    		}
    	}
    	return canPublishUnpublishBool;
    }

	public static Boolean calculateCanMakeMustRead (String contentType, Boolean isPublished, String siteType,
													Boolean isSiteMustReadEnabled, Boolean isSiteManager, Boolean isSiteContentManager) {
		Boolean canMakeMustRead = false;
		if(isPublished) {
			if(UserContext.isUserAppModerator) {
				if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentType)) {
					canMakeMustRead = true;
				} else if (ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType) || isSiteManager || isSiteContentManager) {
					canMakeMustRead = true;
				}
			} else if((isSiteManager || isSiteContentManager) && isSiteMustReadEnabled) {
				canMakeMustRead = true;
			}
		} 
		return canMakeMustRead;
	}
	
	public static Boolean calculateCanManageOnboarding (Boolean isPublished, String siteId, Boolean isSiteOnboardingEnabled, Boolean isSiteFeatured) {
        Boolean isManager = UserContext.sitesIManageIdSet.contains(siteId);
        Boolean isContentManager = UserContext.sitesIManageContentsIdSet.contains(siteId);
        Boolean isOwner = UserContext.siteIOwnMap.containsKey(siteId);
        return  isPublished && (UserContext.isUserAppModerator || 
                UserContext.getCurrentUserInfo.Enable_Org_Level_Onboarding__c || 
                ((SimpplrContext.allSiteOnboardingEnabled || isSiteOnboardingEnabled || isSiteFeatured) && (isOwner || isContentManager || isManager))) ? true : false;
    }
    
    public static Boolean calculateManageBlogAccess(String contentOwnerId) {
    	Boolean canManageBlog = false;
    	if(UserContext.isUserAppModerator || UserContext.id.equalsIgnoreCase(contentOwnerId)) {
    		canManageBlog = true;
    	}
    	return canManageBlog;
    }
    
    public static Boolean calculateModerateAccess (Boolean isSiteManager, Boolean isSiteContentManager, String status, String contentOwnerId, 
    		String siteType){
    	Boolean isAppModerator = UserContext.isUserAppModerator;
    	Boolean canApproveReject = false;
    	if (ServiceConstants.CONTENT_STATUS_PENDING.equalsIgnoreCase(status) || ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(status) || ServiceConstants.CONTENT_STATUS_PUBLISH.equalsIgnoreCase(status)){
    		if ((isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			canApproveReject = true;
    		}
    	} 
    	return canApproveReject;
    }
    
    public static Boolean calculateDeleteAccess (Boolean isSiteManager, Boolean isSiteContentManager, String status, String contentOwnerId,
    		String siteType){
		
		Boolean canDeleteBool = false;

    	Boolean isAppModerator = UserContext.isUserAppModerator;
		Boolean isAuthor = UserContext.id.equalsIgnoreCase(contentOwnerId); 
		
    	if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(status)){
			
			if (isAuthor 
					|| (isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			canDeleteBool = true;
			}
			
    	} else if (ServiceConstants.CONTENT_STATUS_PENDING.equalsIgnoreCase(status) || ServiceConstants.CONTENT_STATUS_PUBLISH.equalsIgnoreCase(status) || ServiceConstants.CONTENT_STATUS_UNPUBLISH.equalsIgnoreCase(status)){
    		
    		if ((isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			canDeleteBool = true;
    		}
    	} else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(status)){
    		
    		if ((isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
    				|| isSiteManager 
    				|| UserContext.id.equalsIgnoreCase(contentOwnerId)
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			canDeleteBool = true;
    		}
    	}
    	return canDeleteBool;
    }
    
    public static Boolean calculateBlogEditAccess (String authorUserId, String status) {
    	Boolean canEditBool = false;
    	if(UserContext.id.equalsIgnoreCase(authorUserId)) {
	        canEditBool = SimpplrContext.isOnlyInfluencersAllowedToCreateBlog ? UserContext.getCurrentUserInfo.Is_Influencer__c : true;
	        
        } 
        if(!canEditBool && UserContext.isUserAppModerator) {
        	canEditBool = true;
        }
    	return canEditBool;
    }
    public static Boolean calculateEditAccess (Boolean isSiteManager, Boolean isSiteContentManager, String status, String contentOwnerId, String siteType){
    	Boolean canEditBool = false;
    	Boolean isAppModerator = UserContext.isUserAppModerator;
		Boolean isAuthor = UserContext.id.equalsIgnoreCase(contentOwnerId); 
		
		if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(status) || ServiceConstants.CONTENT_STATUS_PREDRAFT.equalsIgnoreCase(status)){
			
			if (isAuthor 
					|| (isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
					|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
				canEditBool = true;
			}
    	} else if (ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(status)){
    		
			if (isAuthor
					|| (isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			canEditBool = true;
    		}
    	} else if (ServiceConstants.CONTENT_STATUS_PENDING.equalsIgnoreCase(status) || ServiceConstants.CONTENT_STATUS_PUBLISH.equalsIgnoreCase(status) || ServiceConstants.CONTENT_STATUS_UNPUBLISH.equalsIgnoreCase(status)){
    		
    		if ((isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			canEditBool = true;
    		}
    	}
    	return canEditBool;
	}

	public static Boolean calculateDeleteQuestionAccess (Boolean isSiteManager, Boolean isSiteContentManager, String contentOwnerId, String siteType, Boolean hasApprovedAnswer){	
		Boolean isSuccess = false;
    	Boolean isAppModerator = UserContext.isUserAppModerator;
		Boolean isAuthor = UserContext.id.equalsIgnoreCase(contentOwnerId); 
        if ((isAuthor && !hasApprovedAnswer)
					|| (isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			isSuccess = true;
			}		   	
    	return isSuccess;
    }

    public static Boolean calculateEditQuestionAccess (Boolean isSiteManager, Boolean isSiteContentManager, String contentOwnerId, String siteType, Boolean hasApprovedAnswer){	
		Boolean isSuccess = false;
    	Boolean isAppModerator = UserContext.isUserAppModerator;
		Boolean isAuthor = UserContext.id.equalsIgnoreCase(contentOwnerId); 
        if ((isAuthor && !hasApprovedAnswer)
					|| (isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
					|| (isAppModerator && UserContext.hasModifyAllDataPermission)
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			isSuccess = true;
			}		   	
    	return isSuccess;
    }

    public static Boolean calculateDuplicateQuestionAccess (Boolean isSiteManager, Boolean isSiteContentManager, String contentOwnerId, String siteType){	
		Boolean isSuccess = false;
    	Boolean isAppModerator = UserContext.isUserAppModerator;
		Boolean isAuthor = UserContext.id.equalsIgnoreCase(contentOwnerId); 
        if ((isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
				|| isSiteManager 
				|| isSiteContentManager
			    || (isAppModerator && UserContext.hasModifyAllDataPermission)
    			|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			isSuccess = true;
			}		   	
    	return isSuccess;
    }

    public static Boolean calculateUnpublishQuestionAccess (Boolean isSiteManager, Boolean isSiteContentManager, String contentOwnerId, String siteType){	
		Boolean isSuccess = false;
    	Boolean isAppModerator = UserContext.isUserAppModerator;
		Boolean isAuthor = UserContext.id.equalsIgnoreCase(contentOwnerId); 
		if ((isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
				|| isAuthor
				|| isSiteManager 
				|| isSiteContentManager
			    || (isAppModerator && UserContext.hasModifyAllDataPermission)
    			|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))){
    			isSuccess = true;
			}		   	
    	return isSuccess;
    }
	
	public static Boolean calculateSiteViewAccess (String siteId, String siteType) {
		Boolean canView = false;
		if (ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteType)) {
			if(UserContext.sitesIFollowIdSet.contains(siteId)) {
				canView = true;
				
			}else if(UserContext.sitesIManageMap.keyset().contains(siteId) || UserContext.hasModifyAllDataPermission || UserContext.sitesIManageContentsIdSet.contains(siteId)) {
				canView = true;
				
			}
		} else if (ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteType)) {
			if(UserContext.sitesIFollowIdSet.contains(siteId)) {
				canView = true;
				
			}else if(UserContext.sitesIManageMap.keyset().contains(siteId) || UserContext.hasManageUnlistedSitePermission || UserContext.hasModifyAllDataPermission || UserContext.sitesIManageContentsIdSet.contains(siteId)) {
				canView = true;
				
			}

		} else {
			canView = UserContext.sitesIManageMap.keyset().contains(siteId) || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission || UserContext.sitesIManageContentsIdSet.contains(siteId);
			
		}
    		return canView;
    }

    public static Boolean calculateContentViewAccess (String contentType, Boolean isPublished, String siteId, String siteType, String contentStatus, String authorUserId) {
		Boolean canView = false;
		Boolean isAuthor = UserContext.id.equalsIgnoreCase(authorUserId); 
		
			
		if (isAuthor && (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentStatus) || 
						ServiceConstants.CONTENT_STATUS_PREDRAFT.equalsIgnoreCase(contentStatus) || 
						ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(contentStatus) || 
						ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(contentStatus))) {
			canView = true; 
		
		} else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(contentType)) {
	    		canView = isPublished || isAuthor || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission;
    		
		} else if (ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteType)) {
			if(isPublished && UserContext.sitesIFollowIdSet.contains(siteId)) {
				canView = true;
				
			}else if(UserContext.sitesIManageMap.keyset().contains(siteId) || UserContext.hasModifyAllDataPermission || UserContext.sitesIManageContentsIdSet.contains(siteId) || isAuthor ) {
				canView = true;
				
			}
		} else if (ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteType)) {
			if(isPublished && UserContext.sitesIFollowIdSet.contains(siteId)) {
				canView = true;
				
			}else if(UserContext.sitesIManageMap.keyset().contains(siteId) || UserContext.hasManageUnlistedSitePermission || UserContext.hasModifyAllDataPermission || UserContext.sitesIManageContentsIdSet.contains(siteId) || isAuthor ) {
				canView = true;
				
			}

		} else {
			canView = isPublished || isAuthor || UserContext.sitesIManageMap.keyset().contains(siteId) || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission || UserContext.sitesIManageContentsIdSet.contains(siteId);
			
		}
    		return canView;
    }    
    
    public static Boolean isMySettingExternalAppsAccessible {
    	get {
    		if(isMySettingExternalAppsAccessible == null) {
    			isMySettingExternalAppsAccessible = true;
    			if((SimpplrContext.isEmployeeAdvocacyEnabled == false  || SimpplrContext.appIntegrationEnabledSet.isEmpty()) &&
            	   (String.isBlank(SimpplrContext.BoxUserId) || SimpplrContext.appConfig.Box_Integration_Enabled__c == false) && 
            	   (SimpplrContext.connectedStorages.isEmpty()) &&
            	   	SimpplrContext.adIntegrationEnabled == false &&
            	   SimpplrContext.slackIntegrationEnabled == false &&
				   (SimpplrContext.serviceNowIntegrationEnabled == false || SimpplrContext.isServiceNowConnected ==false) ){
    				isMySettingExternalAppsAccessible = false;
    			} 
    		}
    		return isMySettingExternalAppsAccessible;
    	} private set;
    }
    
    public static Boolean hasBrandingUpdatePermissions() {
    	Boolean hasBrandingUpdatePermissions = false;
    	if(UserContext.isUserAppModerator) {
    		hasBrandingUpdatePermissions = true;

    	} else if(!SimpplrContext.isSegmentBrandingEnabled && !ServiceConstants.PACKAGE_VERSION.equalsIgnoreCase(SimpplrContext.packageVersion)){
			hasBrandingUpdatePermissions = true;
			
		} else if(SimpplrContext.isSegmentBrandingEnabled && !ServiceConstants.PACKAGE_VERSION.equalsIgnoreCase(UserContext.getCurrentUserInfo.Segment__r.Branding_Package_Version__c)) {
				hasBrandingUpdatePermissions = true;

		} 
    	return hasBrandingUpdatePermissions;
    }

	public Static Boolean hasAlertModerationAccess(String alertId){
		Boolean hasAccess = false;
		if(String.isNotBlank(alertId)){	
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', alertId);
			String query = 'Select Recipient_Site__c From Alert__c Where Id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Alert__c> alertObjList = (List<Alert__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			if(alertObjList.isEmpty()==false && String.isNotBlank(alertObjList[0].Recipient_Site__c)){				
				hasAccess = hasAlertCreateAccess(alertObjList[0].Recipient_Site__c);
			
			} else if(UserContext.isUserAppModerator || UserContext.canSendAlerts) {
				hasAccess = true;
			}
		} else if(UserContext.isUserAppModerator || UserContext.canSendAlerts){
			hasAccess = true; 
		} 
		return hasAccess; 
	}

	public Static Boolean hasAlertCreateAccess(String siteId){
		Boolean hasAccess = false;
		if(String.isNotBlank(siteId)) {			
			List<Simpplr_Site__c> siteList = [Select Is_Alert_Enabled__c, Site_Type__c, chatter_Group_id__c from Simpplr_Site__c Where id=:siteId WITH SECURITY_ENFORCED];
			if(siteList.isEmpty() == false){
				if(UserContext.canSendAlerts || UserContext.isUserAppModerator) {
					if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteList[0].Site_Type__c) ||
						UserContext.sitesIManageIdSet.contains(siteId) ||
						UserContext.hasModifyAllDataPermission ||
						(UserContext.hasManageUnlistedSitePermission && 
						ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteList[0].Site_Type__c))) {
							hasAccess = true; 
						}	
				} else if(siteList[0].Is_Alert_Enabled__c == true) {
					hasAccess = UserContext.sitesIManageIdSet.contains(siteId);						
				}
			}
		} else if(UserContext.isUserAppModerator || UserContext.canSendAlerts){
			hasAccess = true;
		}  
		return hasAccess; 
	}

	public Static Boolean hasNewsletterModerationAccess(String newsletterId){
		Boolean hasAccess = false;
		if(String.isNotBlank(newsletterId)){			
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', newsletterId);
			String query = 'Select Recipient__c, Site__c From Mailer__c Where Id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Mailer__c> mailerObjList = (List<Mailer__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			if(mailerObjList.isEmpty()==false && 'site'.equalsIgnoreCase(mailerObjList[0].Recipient__c)) {
				hasAccess = hasNewsletterCreateAccess(mailerObjList[0].Site__c);
										
			} else if(UserContext.isUserAppModerator || UserContext.canSendNewsletter) {
				hasAccess = true;
			}
		} else if(UserContext.isUserAppModerator || UserContext.canSendNewsletter) {
			hasAccess = true; 
		}  
		return hasAccess; 
	}
	
	public Static Boolean hasNewsletterCreateAccess(String siteId){
		Boolean hasAccess = false;
		if(String.isNotBlank(siteId)){
			if(UserContext.hasModifyAllDataPermission && (UserContext.isUserAppModerator || UserContext.canSendNewsletter)){
				hasAccess = true; 
			} else {
				List<Simpplr_Site__c> siteList = [Select Is_Newsletter_Allowed__c, Site_Type__c, chatter_Group_id__c from Simpplr_Site__c Where id=:siteId WITH SECURITY_ENFORCED];
				if(siteList.isEmpty() == false){				
					if((ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteList[0].Site_Type__c) || UserContext.sitesIManageIdSet.contains(siteId)) && 
						(UserContext.isUserAppModerator || UserContext.canSendNewsletter)){
						hasAccess = true; 
					} else if( ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteList[0].Site_Type__c) && UserContext.hasManageUnlistedSitePermission){
						hasAccess=true;
						
					}else if(siteList[0].Is_Newsletter_Allowed__c == true){
						hasAccess = UserContext.sitesIManageIdSet.contains(siteId);	
					}
				}
			}
		} else if(UserContext.isUserAppModerator || UserContext.canSendNewsletter){
				hasAccess = true; 
		}  
		return hasAccess; 
	}
	
	/**
	* @description get uniq csrf token for salesforce session
	* @return String csrf token
	**/
	public static String getCsrfToken(){
		return EncodingUtil.convertToHex(
			Crypto.generateDigest('MD5', Blob.valueOf(UserInfo.getSessionId()))
		);
	}

	/**
	* @description main method that validates csrf token and protects from CSRF attacks, default target null
	**/
	public static void protectFromRequestForgery(){
		protectFromRequestForgery(null);
	}

	/**
	* @description main method that validates csrf token and protects from CSRF attacks
	* @param target target class
	**/
	public static void protectFromRequestForgery(String target){
		try{
			if(ApexPages.currentPage() != null){
				String headerAuth = ApexPages.currentPage().getHeaders().get(ServiceConstants.HEADER_AUTH);
				// Filter out API invokes from mobile or other external systems.
				// Access token based APIs calls will have Authorization header, validate token only if header is missing
				if(String.isBlank(headerAuth)){
					String headerHttpVerb = ApexPages.currentPage().getHeaders().get(ServiceConstants.HEADER_HTTP_VERB);
					// Skip validation for GET requests.
					// Validate token, if headerHttpVerb missing, web api calls have this header, unless initiated from unauthorized system.
					if(String.isBlank(headerHttpVerb) || !headerHttpVerb.equalsIgnoreCase('GET')){
						String headerCsrfToken = ApexPages.currentPage().getHeaders().get(ServiceConstants.HEADER_CSRF_TOKEN);
						validateCsrfToken(headerCsrfToken, target);
					}
				}
			}
		}catch(Exception ex){
			logger.logError('CSRF Token Exception ', ex);
			if(ex.getMessage().contains('CSRF_TOKEN_VALIDATION_FAILED')){
				throw ex;
			}
		}
	}

	/**
	* @description validates server token against header or cookie token
	* @param csrfToken csrf token passed in request header or cookie
	* @param target target class from request
	**/
	public static void validateCsrfToken(String csrfToken, String target){
		String serverCsrfToken = getCsrfToken();
		// Throw 403 if csrfToken missing or does not match with server token
		if(!readCookieCsrf().contains(serverCsrfToken)) {
			throw new SimpplrException('CSRF_TOKEN_VALIDATION_FAILED');
		}
		if(String.isNotBlank(target)){
			if(String.isBlank(csrfToken) || !serverCsrfToken.equals(csrfToken)){
				throw new SimpplrException('CSRF_TOKEN_VALIDATION_FAILED');

			} else if (NotificationDataServer.class.getName().containsIgnoreCase(target)){
				extendCookieTimeCsrf(null);
			}
		}
	}

	/**
	* @description validates server CSRF token against cookie token
	**/
	public static void validateCsrfTokenCookie(){
		// Throw 403 if csrfToken does not match with server token
		if(!readCookieCsrf().contains(getCsrfToken())){
			throw new SimpplrException('CSRF_TOKEN_VALIDATION_FAILED');
		}
	}
	
	/**
	* @description read csrf cookie 
	* @return String cookie value
	**/
	public static String readCookieCsrf(){
		String cookieValue = '';
		Cookie tokenCookie = ApexPages.currentPage().getCookies().get(ServiceConstants.COOKIE_CSRF_TOKEN);
		if(tokenCookie != null ){
			cookieValue = String.isNotBlank(tokenCookie.getValue()) ? tokenCookie.getValue() : cookieValue;
		}
		return cookieValue;
	}

	/**
	* @description create cookie with csrf token
	* @param cookieValue csrf token new
	**/
	public static void createCookieCsrf(String cookieValue, Integer expireTimeInSec){
		if(expireTimeInSec == null && !Test.isRunningTest()){
			try {
				expireTimeInSec = Integer.valueOf(Auth.SessionManagement.getCurrentSession().get('NumSecondsValid'));
			} catch (Exception exp) {
				expireTimeInSec = ServiceConstants.COOKIE_EXPIRE_TIME;
			}
		}
		expireTimeInSec = expireTimeInSec != null ? expireTimeInSec : ServiceConstants.COOKIE_EXPIRE_TIME;

		ApexPages.currentPage().setCookies(new Cookie[]{
			new Cookie(ServiceConstants.COOKIE_CSRF_TOKEN, cookieValue, null, expireTimeInSec, true, ServiceConstants.COOKIE_CSRF_TOKEN_TYPE)
		});
	}

	/**
	* @description read and extend expiry time of cookie
	**/
	public static void extendCookieTimeCsrf(Integer expireTimeInSec){
		String cookieValue = readCookieCsrf();
		if(String.isNotBlank(cookieValue)){
			createCookieCsrf(cookieValue, expireTimeInSec);
		}
	}

	/**
	* @description read, update and extend expiration time of cookie
	* @param serverCsrfToken server csrf token
	**/
	public static void manageCookieCsrf(String serverCsrfToken){
		String cookieValue = readCookieCsrf();
		Set<String> csrfTokensSet = new Set<String>{serverCsrfToken};
		if(String.isNotBlank(cookieValue)){
			csrfTokensSet.addAll(cookieValue.split(','));
		}
		String newCookieValue = String.join(new List<String>(csrfTokensSet),',');
		createCookieCsrf(newCookieValue, null);
	}
	/**
	* @description - This method calculate manage access of user on content Template
	* @param   : isSiteManager - If user is site manager or owner, isSiteContentManager - if user is site content manager, siteType - type of site
	* @return : return true if user has manager content template access else false
	**/
	public static Boolean calculateContentTemplateManageAccess (Boolean isSiteManager, Boolean isSiteContentManager, String siteType){
    	Boolean isAppModerator = UserContext.isUserAppModerator;
    	Boolean canManageContentTemplate = false;
    	if ((isAppModerator && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteType)) 
					|| isSiteManager 
					|| isSiteContentManager
    				|| (UserContext.hasManageUnlistedSitePermission && 'unlisted'.equalsIgnoreCase(siteType))) {
					canManageContentTemplate = true;
    	} 
    	return canManageContentTemplate;
    }

	public static List<String> getAddOns() {
		List<String> addOns = new List<String>();				
		if(SimpplrContext.isQuestionAnswerFeatureEnabled){ 
			addOns.add('question_answer');
		}
		if(SimpplrContext.isFeatureEnabled('Employee_Advocacy')) {
			addOns.add('employee_advocacy');
		}
		if(SimpplrContext.isFeatureEnabled('Org_Chart')) {
			addOns.add('org_chart');
		}
		if(SimpplrContext.isFeatureEnabled('Segments')) {
			addOns.add('segments');
		}
		if(SimpplrContext.isFeatureEnabled('Alerts')) {
			addOns.add('alerts');
		}
		if(SimpplrContext.isFeatureEnabled('Newsletter')) {
			addOns.add('newsletter');
		}
		if(SimpplrContext.isFeatureContentOnboardingEnabled) {
			addOns.add('contentonboarding');
		}
		if(String.isNotBlank(SimpplrContext.knowledgeArticleType)) {
			addOns.add('knowledge');
		}		
		if(SimpplrContext.isExternalAnalyticsEnabled) {
			addOns.add('externalAnalytics');
		}
		if(SimpplrContext.isNativeVideo) {
			addOns.add('native_video');
		}
		if(SimpplrContext.newsletterPlusEnabled) {
			addOns.add('newsletter_v2');
		}			
		if(SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected && SimpplrContext.appConfig.External_Search_Active__c && Utility.isSmartSearchTokenValid()) {
			addOns.add('externalSearch');
		}
		if(SimpplrContext.listenerSuiteEnabled) {
			addOns.add('listener_suite');
		}

		if(SimpplrContext.isPageTemplateEnabled) {
			addOns.add('page_template');
		}

		if(SimpplrContext.isJwtAuthEnabled) {
			addOns.add('analytics_jwt_token');
		}

		if(SimpplrContext.isSiteAndLaunchpadAnalyticsEnabled) {
			addOns.add('launchpad_analytics');
		}

        if(SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
			addOns.add('microsoft_teams');
		}

		if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2) {
			addOns.add('microsoft_teams_phase_2');
		}
        
		if(SimpplrContext.recognitionEnabled) {
			addOns.add('recognition');
		}

		if(SimpplrContext.aiContentModerationEnabled) {
			addOns.add('content_moderation');
		}

		if(SimpplrContext.isSlackPhase2FeatureEnabled) {
			addOns.add('slack_phase_2');
		}
		if(SimpplrContext.locationNormalizationEnabled) {
			addOns.add('location_normalization');
		}
		return addOns;
	}
}