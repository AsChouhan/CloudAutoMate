/**
* @Class UserContext 
* @Purpose:  Class provide Current user contextual information like User/People details and preferences.
*
*/
public with sharing class UserContext {
	
    /**
    **
    */
    private UserContext() {
    } 
    
    /**
    **
    */
    public static String id{
    	get {
	    	if(id == null) {
	    		id = userInfo.getUserId();
	    	}
	    	return id;
         }private set;
    }
    
    public static String userId{
    	get {
	    	if(userId == null) {
	    		userId = userInfo.getUserId();
	    	}
	    	return userId;
         }private set;
    }

 	/**
    **
    */
	@TestVisible
    public static String peopleId{
    	get {
	    	if(peopleId == null) {
	    		if(getCurrentUserInfo!=null){
	    			peopleId = getCurrentUserInfo.Id;
	    		}
	    	}
	    	return peopleId;
         }private set;
    }
    
    public static String profileId{
    	get {
	    	if(profileId == null) {
    			profileId = UserInfo.getProfileId();
	    	}
	    	return profileId;
         }private set;
    }
    
    public static String smallPhotoURL{
    	get {
	    	if(smallPhotoURL == null) {
	    		if(getCurrentUserInfo!=null){
	    			smallPhotoURL = getCurrentUserInfo.User__r.SmallPhotoUrl;
	    		}
	    	}
	    	return smallPhotoURL;
         }private set;
    }
    
    public static String mediumPhotoURL{
    	get {
	    	if(mediumPhotoURL == null) {
	    		if(getCurrentUserInfo!=null){
	    			mediumPhotoURL = getCurrentUserInfo.User__r.MediumPhotoUrl;
	    		}
	    	}
	    	return mediumPhotoURL;
         }private set;
    }
    
    public static String fullPhotoURL{
    	get {
	    	if(fullPhotoURL == null) {
	    		if(getCurrentUserInfo!=null){
	    			fullPhotoURL = getCurrentUserInfo.User__r.FullPhotoURL;
	    		}
	    	}
	    	return fullPhotoURL;
         }private set;
    }
    
    public static String externalPhotoUrl{
    	get {
	    	if(externalPhotoUrl == null) {
	    		if(getCurrentUserInfo!=null){
	    			externalPhotoUrl = getCurrentUserInfo.External_Photo_URL__c;
	    		}
	    	}
	    	return externalPhotoUrl;
         }private set;
    }
    
    public static Datetime externalPhotoUrlExpiryDate{
    	get {
	    	if(externalPhotoUrlExpiryDate == null) {
	    		if(getCurrentUserInfo!=null){
	    			externalPhotoUrlExpiryDate = getCurrentUserInfo.External_Photo_URL_Expiry_Date__c;
	    		}
	    	}
	    	return externalPhotoUrlExpiryDate;
         }private set;
    }
    
    public static String firstName{
    	get {
	    	if(firstName == null) {
	    		if(getCurrentUserInfo!=null){
	    			firstName = getCurrentUserInfo.First_Name__c;
	    		}
	    	}
	    	return firstName;
         }private set;
    }

	/**
	 * @description get user's last name
	 */
	public static String lastName{
		get {
			if(lastName == null) {
				if(getCurrentUserInfo!=null){
					lastName = getCurrentUserInfo.Last_Name__c;
				}
			}
			return lastName;
		}private set;
	}
    
    public static String country{
    	get {
	    	if(country == null) {
	    		if(getCurrentUserInfo!=null){
	    			country = getCurrentUserInfo.Country__c;
	    		}
	    	}
	    	return country;
         }private set;
    }
    
    public static String division{
    	get {
	    	if(division == null) {
	    		if(getCurrentUserInfo!=null){
	    			division = getCurrentUserInfo.Division__c;
	    		}
	    	}
	    	return division;
         }private set;
	}
	
	public static String city{
    	get {
	    	if(city == null) {
	    		if(getCurrentUserInfo!=null){
	    			city = getCurrentUserInfo.City__c;
	    		}
	    	}
	    	return city;
         }private set;
	}

	public static String state{
    	get {
	    	if(state == null) {
	    		if(getCurrentUserInfo!=null){
	    			state = getCurrentUserInfo.State__c;
	    		}
	    	}
	    	return state;
         }private set;
	}
    
    public static String companyName{
    	get {
	    	if(companyName == null) {
	    		if(getCurrentUserInfo!=null){
	    			companyName = getCurrentUserInfo.Company_Name__c;
	    		}
	    	}
	    	return companyName;
         }private set;
    }

    /**
    **
    */
    public static String name{
    	get {
	    	if(name == null) {
	    		name = userInfo.getName();
	    	}
	    	return name;
         }private set;
    }
    
    public static String peopleName{
    	get {
	    	if(peopleName == null) {
	    		if(getCurrentUserInfo!=null){
	    			peopleName = getCurrentUserInfo.Full_Name__c;
	    		}
	    	}
	    	return peopleName;
         }private set;
    }
    
    public static String phone{
    	get {
	    	if(phone == null) {
	    		if(getCurrentUserInfo!=null){
	    			phone = getCurrentUserInfo.Phone__c;
	    		}
	    	}
	    	return phone;
         }private set;
    }
    
    public static String mobile{
    	get {
	    	if(mobile == null) {
	    		if(getCurrentUserInfo!=null){
	    			mobile = getCurrentUserInfo.Mobile_Phone__c;
	    		}
	    	}
	    	return mobile;
         }private set;
    }

	 /**
     * @description getter for email
     * @return string
     */
	public static String email{
    	get {
	    	if(email == null) {
	    		if(getCurrentUserInfo!=null){
	    			email = getCurrentUserInfo.Email__c;
	    		}
	    	}
	    	return email;
         }private set;
    }
    
    public static String aboutMe{
    	get {
	    	if(aboutMe == null) {
	    		if(getCurrentUserInfo!=null){
	    			aboutMe = getCurrentUserInfo.About__c;
	    		}
	    	}
	    	return aboutMe;
         }private set;
    }
    
    public static String coverImageId{
    	get {
	    	if(coverImageId == null) {
	    		if(getCurrentUserInfo!=null){
	    			coverImageId = getCurrentUserInfo.Cover_Content_Version_Id__c;
	    		}
	    	}
	    	return coverImageId;
         }private set;
    }
	@TestVisible
	public static Boolean canAccessAnalytics{
    	get {
	    	if(canAccessAnalytics == null) {
	    		canAccessAnalytics =  false;
	    		if(getCurrentUserInfo!=null){
	    			canAccessAnalytics = getCurrentUserInfo.Can_Access_Analytics__c;
	    		}
	    	}
	    	return canAccessAnalytics;
         }private set;
    }

	/**
     * @description check if the current user Listener Suite Enabled
     * @return true if it is enbaled
     */
	@TestVisible
	public static Boolean userSentimentCheckEnabled{
		get {
			if(userSentimentCheckEnabled == null) {
				userSentimentCheckEnabled =  false;
				if(getCurrentUserInfo!=null){
					userSentimentCheckEnabled = getCurrentUserInfo.Can_Manage_Sentiment_Check__c;
				}
			}
			return userSentimentCheckEnabled;
		}private set;
	}
    
    public static Boolean canControlHomeDashboard{
    	get {
	    	if(canControlHomeDashboard == null) {
	    		canControlHomeDashboard =  false;
	    		if(getCurrentUserInfo!=null){
	    			canControlHomeDashboard = getCurrentUserInfo.Can_Control_Dashboard__c;
	    		}
	    	}
	    	return canControlHomeDashboard;
         }private set;
    }
    @TestVisible
    public static Boolean canSendNewsletter{
    	get {
	    	if(canSendNewsletter == null) {
	    		canSendNewsletter = false;
	    		if(getCurrentUserInfo!=null){
	    			canSendNewsletter = getCurrentUserInfo.Can_Send_Newsletter__c;
	    		}
	    	}
	    	return canSendNewsletter;
         }private set;
    }
    @TestVisible
    public static Boolean canSendAlerts{
    	get {
	    	if(canSendAlerts == null) {
	    		canSendAlerts = false;
	    		if(getCurrentUserInfo!=null){
	    			canSendAlerts = getCurrentUserInfo.Can_Send_Alert__c;
	    		}
	    	}
	    	return canSendAlerts;
    	}private set;
    }
    
    public static Boolean canSendSiteNewsletter {
    	get {
	    	if(canSendSiteNewsletter == null) {
	    		canSendSiteNewsletter = canSendNewsletter || isUserAppModerator;
	    		
	    		if(canSendSiteNewsletter == false && !sitesIManageMap.isEmpty()) {
	    			
	    			for(Simpplr_Site__c ss : sitesIManageMap.values()){
	    				if(ss.Is_Newsletter_Allowed__c){
	    					canSendSiteNewsletter = true;
	    					break;
	    				}
	    			}
	    		}
	    	}
	    	return canSendSiteNewsletter;
         }private set;
    }
    
    public static Boolean canSendSiteAlert {
    	get {
	    	if(canSendSiteAlert == null) {
	    		canSendSiteAlert = canSendAlerts || isUserAppModerator;
	    		
	    		if(canSendSiteAlert == false && !sitesIManageMap.isEmpty()) {
	    			
	    			for(Simpplr_Site__c ss : sitesIManageMap.values()){
	    				if(ss.Is_Alert_Enabled__c){
	    					canSendSiteAlert = true;
	    					break;
	    				}
	    			}
	    		}
	    	}
	    	return canSendSiteAlert;
         }private set;
    }

	
	public static String DefaultAllowedFeatures{
	  get {
	    if(DefaultAllowedFeatures == null){
	    	DefaultAllowedFeatures = '';
	    	if(AccessManager.USER_ROLE_MEMBER.equalsIgnoreCase(primaryRole)){
	    		DefaultAllowedFeatures  = AccessManager.DEFAULT_MEMBER_FEATURES;
	    	}
	    	if(AccessManager.USER_ROLE_SITEMANAGER.equalsIgnoreCase(primaryRole)){
	    		DefaultAllowedFeatures  = AccessManager.DEFAULT_SITEMANAGER_FEATURES;
	    	}
	    	if(AccessManager.USER_ROLE_APPMODERATOR.equalsIgnoreCase(primaryRole)){
	    		DefaultAllowedFeatures  = AccessManager.DEFAULT_APPMODERATOR_FEATURES;
	    	}
	    	if(hasManageUnlistedSitePermission && String.isNotBlank(SiteContext.siteId)){
	    		DefaultAllowedFeatures  = AccessManager.DEFAULT_SITEMANAGER_FEATURES;	
	    	}
	    }
	    return DefaultAllowedFeatures;
	   }private set;
	  }
	  
	public static String getUsersDepartmentDetail{
    	get {
	    	if(getUsersDepartmentDetail == null) {
	    		if(getCurrentUserInfo!=null){
	    			getUsersDepartmentDetail = getCurrentUserInfo.Department__c;
	    		}
	    	}
	    	return getUsersDepartmentDetail;
         }private set;
    }
	
	public static Boolean isProtectedAuthorAllowlisted{
		get{
			if( isProtectedAuthorAllowlisted == null ){
				if(getCurrentUserInfo!=null){
					isProtectedAuthorAllowlisted = getCurrentUserInfo.Is_Protected_Author_Allowlisted__c;
				}
			}
			return isProtectedAuthorAllowlisted;
		}private set;
	}
	

    public static String getUserCategory{
    	get {
	    	if(getUserCategory == null) {
	    		if(getCurrentUserInfo!=null){
	    			getUserCategory = getCurrentUserInfo.People_Category__c;
	    		}
	    	}
	    	return getUserCategory;
         }private set;
    }
    
    public static String languageLocaleKey{
    	get {
	    	if(languageLocaleKey == null) {
	    		if(getCurrentUserInfo!=null){
					languageLocaleKey = ServiceConstants.SUPPORTED_LOCALE_MAP.get(getCurrentUserInfo.User__r.LanguageLocaleKey);
					if(SimpplrContext.appLanguageEnabledSet.contains(languageLocaleKey) == false) {
						if('en_UK'.equalsIgnoreCase(languageLocaleKey) && SimpplrContext.appLanguageEnabledSet.contains('en_US')) {
							languageLocaleKey = 'en_US';

						} else if('en_US'.equalsIgnoreCase(languageLocaleKey) && SimpplrContext.appLanguageEnabledSet.contains('en_UK')) {
							languageLocaleKey = 'en_UK';

						} else {
							languageLocaleKey = SimpplrContext.appDefaultLanguage;
						}
					}
				} else {
					languageLocaleKey = SimpplrContext.appDefaultLanguage;
				}
	    	}
	    	return languageLocaleKey;
         }private set;
    }
    
    public static String timeZoneName{get{
        return UserInfo.getTimeZone().getID();
    }private set;}

    public static Integer timezoneOffset{get{
        return UserInfo.getTimeZone().getOffset(system.today());
    }private set;}
    
    public static String timeZoneLabel {
       get {
           if(String.isBlank(timeZoneLabel)) {
               return Utility.timezoneIdToDisplayLabel(UserInfo.getTimeZone().getId());
           } else {
               return timeZoneLabel;
           }
       }  private set;  
   }
    
    /**
    **
    */
    public static String primaryRole{
    	get {
	    	if(primaryRole == null) {
	    		primaryRole = getCurrentUserSimpplrRole();
	    	}
	    	return primaryRole;
         }private set;
    }

    @TestVisible public static Boolean isUserAppModerator{get{
        if(isUserAppModerator == null) {
        		isUserAppModerator = false;
        		if(getCurrentUserInfo!= null && 'Yes'.equalsIgnoreCase(getCurrentUserInfo.App_Moderation_Permission__c)) {
            		if(getCurrentUserInfo.User__r.profile.PermissionsModerateChatter){
						isUserAppModerator = true;
					}else{
						List<PermissionSetAssignment> permissionSetList = getCurrentUserPermissionSetList;
						for(PermissionSetAssignment assignmentObj: permissionSetList) {
							if(assignmentObj.PermissionSet.PermissionsModerateChatter) {
								isUserAppModerator = true;
								break;
							}
						}
					}
        		}
        }
        return isUserAppModerator;
    }private set;
	}

	@TestVisible public static Boolean isUserCampaignModerator{get{
        if(isUserCampaignModerator == null) {
			isUserCampaignModerator = false;
        	if(getCurrentUserInfo!= null && 'Yes'.equalsIgnoreCase(getCurrentUserInfo.Campaign_Moderation_Permission__c)) {
				isUserCampaignModerator = true;
			}
		}
    	return isUserCampaignModerator;
    }private set;
	}

	@TestVisible public static Boolean isUserOnboardingManager{get{
        if(isUserOnboardingManager == null) {
			isUserOnboardingManager = false;
			if(getCurrentUserInfo!= null && getCurrentUserInfo.Enable_Org_Level_Onboarding__c == true) {
				isUserOnboardingManager = true;
			}
        }
        return isUserOnboardingManager;
    }private set;
	}

	public static Boolean isUserSiteManager{get{
        if(isUserSiteManager == null){
            isUserSiteManager = groupsIManageMap.size() > 0;
        }
        return isUserSiteManager;
    }private set;}

    public static Boolean isUserSiteOnboardingManager{get{
        if(isUserSiteOnboardingManager == null){
            List<Site_Role__c> siteRoleList = [SELECT Id FROM Site_Role__c WHERE People__c = :peopleId AND Is_Deleted__c = false AND Site__r.Is_Deleted__c = false AND Site__r.Is_Active__c=true AND Site__r.Is_Onboarding_Enabled__c=true LIMIT 1];
            isUserSiteOnboardingManager = siteRoleList.size() > 0;
        }
        return isUserSiteOnboardingManager;
    }private set;}

	public static Map<Id,Audience__c> audiencesIAmMemberOfMap{
		get{
            if(audiencesIAmMemberOfMap == null){
                audiencesIAmMemberOfMap = new Map<Id,Audience__c>();
            	String currentUserId = Userinfo.getUserId();
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', currentUserId);
				String BASE_QUERY = 'SELECT Id, Name__c, Segment__c, Audience_Rule_Json__c, Audience_Member_Count__c, Is_Hidden__c';
				String BASE_FROM_WHERE = ' FROM Audience__c ' +
										 ' WHERE Id IN (Select Audience__c from Audience_Member__c WHERE User__c = :soqlParam1) ' +
										 ' AND Is_Deleted__c = false';
            	
				List<Audience__c> audienceList = new List<Audience__c>();
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(BASE_QUERY+BASE_FROM_WHERE, soqlParamMap);
	    		
	    		for(Audience__c audienceObj : audienceList){
	    			audiencesIAmMemberOfMap.put(audienceObj.Id,audienceObj);
	    		}
            }
            return audiencesIAmMemberOfMap;
        }private set;
	}
    
    /**
    **
    */
    public static Map<Id,CollaborationGroup> chatterGroupsIFollowMap{
        get{
            if(chatterGroupsIFollowMap == null){
                chatterGroupsIFollowMap = new Map<Id,CollaborationGroup>();
            	String currentUserId = Userinfo.getUserId();
            	String BASE_QUERY = 'select Id, Name, MemberCount, OwnerId, CollaborationType,SmallPhotoUrl, FullPhotoUrl, Description, HasPrivateFieldsAccess,'+
            						'(select CollaborationRole from GroupMembers where MemberId=:currentUserId)';
            	String BASE_FROM_WHERE = ' From CollaborationGroup where id in (select CollaborationGroupId from CollaborationGroupMember where MemberId=:currentUserId)';
            	if(SimpplrContext.isCommunitiesEnabled){
	    			BASE_FROM_WHERE = BASE_FROM_WHERE+' AND NetworkId = null';
	    		}
	    		List<CollaborationGroup> collaborationGrpList = new List<CollaborationGroup>();
	    		collaborationGrpList = Database.query(BASE_QUERY+BASE_FROM_WHERE);
	    		for(CollaborationGroup grp : collaborationGrpList){
	    			chatterGroupsIFollowMap.put(grp.Id,grp);
	    		}
            }
            return chatterGroupsIFollowMap;
        }private set;
    }

	public static Map<Id,People__c> peopleIManageMap{
        get{
            if(peopleIManageMap == null){
                peopleIManageMap = new Map<Id,People__c>();
				if(getCurrentUserInfo!=null){
	    			Map<String, Object> peopleSoqlParamMap = new  Map<String, Object>();
					peopleSoqlParamMap.put('soqlParam1', getCurrentUserInfo.Id);
					String peopleQuery = 'SELECT id, User__c, Manager__c FROM People__c '+
							' WHERE Manager__c=: soqlParam1 AND User__r.isActive = true AND Has_Simpplr_License__c = true ' +
							' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.UserType=\'Standard\'))  ';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
					List<People__c> peopleListList = (List<People__c>)SIMPESAPI.accessController().queryAsUSer(peopleQuery, peopleSoqlParamMap);
					for(People__c peopleObj : peopleListList){
						peopleIManageMap.put(peopleObj.Id,peopleObj);
					}
				}
            }
            return peopleIManageMap;
        }private set;
    }

	/**
    **
    */
    
    public static List<CollaborationGroup> chatterGroupsIFollowList{get{
        if(chatterGroupsIFollowList == null){
            chatterGroupsIFollowList = New List<CollaborationGroup>();
            chatterGroupsIFollowList = chatterGroupsIFollowMap.values();
        }
        return chatterGroupsIFollowList;
    }private set;}

	/**
    **
    */
    public static set<Id> chatterGroupsIFollowIdSet{
    	get{
			return chatterGroupsIFollowMap.keySet();
    	}private set;
	}
    
    
    /**
    * TODO: 
    */
    public static Map<Id,CollaborationGroup> groupsIManageMap{get{
        if(groupsIManageMap == null){
            groupsIManageMap = New Map<Id,CollaborationGroup>();
            for(CollaborationGroup groupIFollow : chatterGroupsIFollowMap.values()){
                if('Admin'.equalsIgnoreCase(groupIFollow.GroupMembers[0].CollaborationRole)) {
                    groupsIManageMap.put(groupIFollow.Id,groupIFollow);
                }
            }
        }
        return groupsIManageMap;
    }private set;}

	/**
    **
    */
    public static set<Id> groupsIManageIdSet{get{
        if(groupsIManageIdSet == null){
            groupsIManageIdSet = New Set<Id>();
            groupsIManageIdSet = groupsIManageMap.keyset();
        }
        return groupsIManageIdSet;
	}private set;}
	
    /**
    **
    */
    public static Map<Id,Simpplr_Site__c> sitesIFollowMap{get{
        if(sitesIFollowMap == null){
				sitesIFollowMap = New Map<Id,Simpplr_Site__c>([Select Id,Is_Newsletter_Allowed__c,Is_Alert_Enabled__c, Is_Sentiment_Check_Enabled__c, Chatter_Group_Id__c, File_Storage_Source__c,
																Site_Type__c, OwnerId from Simpplr_Site__c where Is_Active__c=true and Is_Deleted__c = false 
																and chatter_Group_Id__c in :chatterGroupsIFollowIdSet]);
        }
        return sitesIFollowMap;
    }private set;}   

	/**
	*
	*/
	public static Map<Id, String> siteStorageMap {
		get {
			if(siteStorageMap == null){
				siteStorageMap = new Map<Id, String>();
				for(Simpplr_Site__c siteObj: sitesIFollowMap.values()) {
					siteStorageMap.put(siteObj.id, siteObj.File_Storage_Source__c);
					siteStorageMap.put(siteObj.Chatter_Group_Id__c, siteObj.File_Storage_Source__c);
				}
			}
			return siteStorageMap;
		}private set;
	}
	/**
    **
    */
    public static List<Simpplr_Site__c> sitesIFollowList{get{
        if(sitesIFollowList == null){
            sitesIFollowList = New List<Simpplr_Site__c>();
            sitesIFollowList = sitesIFollowMap.values();
        }
        return sitesIFollowList;
    }private set;}

	/**
    **
    */
    public static set<Id> sitesIFollowIdSet{get{
        if(sitesIFollowIdSet == null){
            sitesIFollowIdSet = New Set<Id>();
            sitesIFollowIdSet = sitesIFollowMap.keyset();
        }
        return sitesIFollowIdSet;
    }private set;}

	

	public static List<Site_Role__c> mySitesRolesList{get{
        if(mySitesRolesList == null){
			mySitesRolesList =[Select Id, Is_Manager__c, Is_Content_Manager__c , Is_Member__c, Is_Onboarding_Content_Manager__c,
								Site__c, Site__r.Name, Site__r.Is_Newsletter_Allowed__c, Site__r.Is_Onboarding_Enabled__c, Site__r.Is_Alert_Enabled__c, Site__r.Chatter_Group_Id__c, Site__r.File_Storage_Source__c
								FROM Site_Role__c 
								WHERE People__c = :peopleId 
								AND Is_Deleted__c = false
								AND Site__r.Is_Deleted__c = false
								AND Site__r.Is_Active__c=true];
        }
        return mySitesRolesList;
	}private set;}

    public static Map<Id, Simpplr_Site__c> siteIOwnMap{get{
        if(siteIOwnMap == null){
            siteIOwnMap = new Map<Id, Simpplr_Site__c>();
            List<Id> collabGrpIds = new List<Id>();
            for(Site_Role__c role:UserContext.mySiteRolesMap.values()) {
                collabGrpIds.add(role.Site__r.Chatter_Group_Id__c);
            }
            Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = Utility.getAllCollaborationGroupMapForSiteIds(collabGrpIds);

            for(Site_Role__c role:UserContext.mySiteRolesMap.values()) {
                CollaborationGroup collabGroup = mapOfIdWithCollaborationGrp.get(role.Site__r.Chatter_Group_Id__c);
                Boolean isOwner = collabGroup != null ? UserContext.Id.equals(collabGroup.OwnerId) : false;
                if(isOwner) {
                    siteIOwnMap.put(role.Site__c, role.Site__r);
                }
            }
        }
        return siteIOwnMap;
    }private set;}
    
	public static Map<Id, Site_Role__c> mySiteRolesMap{get{
		if(mySiteRolesMap == null) {
			mySiteRolesMap = new Map<Id, Site_Role__c>();
			for(Site_Role__c siteRole : mySitesRolesList) {
				mySiteRolesMap.put(siteRole.Site__c, siteRole);
			}
		}
		return mySiteRolesMap;
	}private set;}
	
	
	/**
	**
	*/
	public static Map<Id,Simpplr_Site__c> sitesIManageMap{get{
        if(sitesIManageMap == null) {
        		sitesIManageMap = new Map<Id,Simpplr_Site__c>();
        		for(Simpplr_Site__c siteObj : sitesIFollowMap.values()) {
        			if(groupsIManageIdSet.contains(siteObj.Chatter_Group_Id__c)) {
        				sitesIManageMap.put(siteObj.Id, siteObj);
        			}
        		}
        }
        return sitesIManageMap;
    }private set;}
	
	/**
    **
    */
	public static set<Id> sitesIManageIdSet{get{
        if(sitesIManageIdSet == null){
            sitesIManageIdSet = New Set<Id>();
            sitesIManageIdSet = sitesIManageMap.keyset();
        }
        return sitesIManageIdSet;
	}private set;}
	
	
	/*public static Map<Id,Simpplr_Site__c> sitesIManageMap{get{
		if(sitesIManageMap == null) {
			sitesIManageMap = new Map<Id,Simpplr_Site__c>();
			for(Site_Role__c siteRoleObj : mySitesRolesList) {
				
				if(siteRoleObj.Is_Manager__c) {
					Simpplr_Site__c siteObj = siteRoleObj.Site__r;
       				sitesIManageMap.put(siteRoleObj.Site__c, siteObj);
       			}
			}
        }
        return sitesIManageMap;
    }private set;}
    
	public static set<Id> sitesIManageIdSet{get{
        if(sitesIManageIdSet == null){
            sitesIManageIdSet = New Set<Id>();
            sitesIManageIdSet = sitesIManageMap.keyset();
        }
        return sitesIManageIdSet;
	}private set;}
	*/
	/**
	**
	*/
	public static Map<Id,Simpplr_Site__c> sitesIManageContentsMap{get{
		if(sitesIManageContentsMap == null) {
			sitesIManageContentsMap = new Map<Id,Simpplr_Site__c>();
			if(!mySitesRolesList.isEmpty()) {
				for(Site_Role__c siteRoleObj : mySitesRolesList) {
					
					if(siteRoleObj.Is_Content_Manager__c) {
						Simpplr_Site__c siteObj = siteRoleObj.Site__r;
        				sitesIManageContentsMap.put(siteRoleObj.Site__c, siteObj);
        			}
				}
			}
        }
        return sitesIManageContentsMap;
    }private set;}

	public static Map<Id,Simpplr_Site__c> sitesIManageOnboardingContentsMap{get{
		if(sitesIManageOnboardingContentsMap == null) {
			sitesIManageOnboardingContentsMap = new Map<Id,Simpplr_Site__c>();
			if(!mySitesRolesList.isEmpty()) {
				for(Site_Role__c siteRoleObj : mySitesRolesList) {
					
					if(siteRoleObj.Is_Onboarding_Content_Manager__c) {
						Simpplr_Site__c siteObj = siteRoleObj.Site__r;
        				sitesIManageOnboardingContentsMap.put(siteRoleObj.Site__c, siteObj);
        			}
				}
			}
        }
        return sitesIManageOnboardingContentsMap;
    }private set;}
    
	public static set<Id> sitesIManageContentsIdSet{get{
        if(sitesIManageContentsIdSet == null){
            sitesIManageContentsIdSet = New Set<Id>();
            sitesIManageContentsIdSet = sitesIManageContentsMap.keyset();
        }
        return sitesIManageContentsIdSet;
    }private set;}

	public static set<Id> sitesIManageOnboardingContentsIdSet{get{
        if(sitesIManageOnboardingContentsIdSet == null){
            sitesIManageOnboardingContentsIdSet = new Set<Id>();
            sitesIManageOnboardingContentsIdSet = sitesIManageOnboardingContentsMap.keyset();
        }
        return sitesIManageOnboardingContentsIdSet;
    }private set;}
    
   
	/**
    **
    */    
    private static String getCurrentUserSimpplrRole(){
    	return UserContext.isUserAppModerator ? AccessManager.USER_ROLE_APPMODERATOR:
    				UserContext.sitesIManageIdSet.size()>0 ? AccessManager.USER_ROLE_SITEMANAGER:AccessManager.USER_ROLE_MEMBER;
    }

    @testVisible public static Boolean emailProductResearch {
        get{
			if(emailProductResearch == null){
				emailProductResearch = false;
	    		if(getCurrentUserSettings != null){
	    			emailProductResearch = getCurrentUserSettings.Email_Product_Research__c;
	    		}
			}
			return emailProductResearch;
        } set;
	}

	@testVisible public static String browserNotificationAllowed {
        get{
			if(browserNotificationAllowed == null){
				browserNotificationAllowed = 'Undecided';
	    		if(getCurrentUserSettings != null){
	    			browserNotificationAllowed = getCurrentUserSettings.Allow_Browser_Notifications__c;
	    		}
			}
			return browserNotificationAllowed;
        } set;
	}

	@testVisible public static Boolean hasDismissedWebPushPromptFromNotiPanel {
        get{
			if(hasDismissedWebPushPromptFromNotiPanel == null){
				hasDismissedWebPushPromptFromNotiPanel = false;
	    		if(getCurrentUserSettings != null){
	    			hasDismissedWebPushPromptFromNotiPanel = getCurrentUserSettings.Dismissed_Prompt_Web_Notifications__c;
	    		}
			}
			return hasDismissedWebPushPromptFromNotiPanel;
        } set;
	}

	@testVisible public static Boolean isOnboardingDisabledOnFeed {
        get{
			if(isOnboardingDisabledOnFeed == null){
				isOnboardingDisabledOnFeed = false;
	    		if(getCurrentUserSettings != null){
	    			isOnboardingDisabledOnFeed = getCurrentUserSettings.Disable_Onboarding_Feed__c;
	    		}
			}
			return isOnboardingDisabledOnFeed;
        } set;
	}
@TestVisible
	public static Boolean isNewHire{
    	get {
	    	if(isNewHire == null) {
	    		isNewHire = false;
	    		if(getCurrentUserInfo!=null && getCurrentUserInfo.Joining_Date__c!=null){
	    			isNewHire = getCurrentUserInfo.Joining_Date__c.daysBetween(Date.today())<=29 ? true : false;
	    		}
	    	}
	    	return isNewHire;
    	}private set;
    }

	public static Date hireDate{
		get {
			if(hireDate == null) {
				hireDate = null;
				if(getCurrentUserInfo!=null && getCurrentUserInfo.Joining_Date__c!=null){
					hireDate = getCurrentUserInfo.Joining_Date__c;
				}
			}
			return hireDate;
		}private set;
	}
	
	/**
    **
    */
    public static People__c getCurrentUserInfo{get{
		if(getCurrentUserInfo == null){
			Map<String, Object> peopleSoqlParamMap = new  Map<String, Object>();
			peopleSoqlParamMap.put('soqlParam1', UserInfo.getUserId());
			String peopleQuery = 'SELECT id, OwnerId, User__c,Mobile_Token_iOS__c, Mobile_Token_Android__c, User__r.LastmodifiedDate, '+
					' Mobile_Promotion_Sent_Datetime__c, User__r.LastLoginDate, Can_Add_Sites__c, User__r.FirstName, CI_Moderation_Permission__c,'+
            		' Segment_Attribute_Value__c, Segment__c, Segment__r.Name__c, Segment__r.Branding_CSS_Class__c, Segment__r.Branding_CSS__c, Segment__r.SSO_Provider__c, Segment__r.Custom_Links_JSON__c,'+
            		' Segment__r.Branding_JSON__c, Segment__r.Layout__c, Segment__r.Branding_Logo__c,Segment__r.Branding_Package_Version__c,Segment__r.LastmodifiedDate,Segment__r.Favicons_Folder__c, '+
            		' Phone__c, Email__c, Title__c, About__c, Mobile_Phone__c, People_Category__c, Extension__c, '+
					' User__r.SmallPhotoUrl, User__r.MediumPhotoUrl, User__r.FullPhotoUrl, Full_Name__c, Department__c,First_Name__c,Last_Name__c,Can_Control_Dashboard__c, '+
					' Manager__c, City__c, Street__c, Country__c, Division__c, Company_Name__c, State__c, User__r.IsActive, App_Moderation_Permission__c,Campaign_Moderation_Permission__c,Unlisted_Site_Moderation_Permission__c, '+
					' People_Category__r.Name__c,User__r.TimezoneSIDKey, User__r.profileId, Birth_Date__c, Joining_Date__c,Is_Campaign_Manager__c, Is_Segment_Manager__c, '+
					' External_Photo_URL__c, External_Photo_URL_Expiry_Date__c, Can_Access_Analytics__c, First_Login_DateTime__c, UUID__c, User__r.Email, '+ 
					' User__r.Profile.PermissionsChatterOwnGroups, User__r.Profile.PermissionsModifyAllData, User__r.Profile.PermissionsModerateChatter, '+
					' User__r.Profile.PermissionsCreateTopics, User__r.Profile.PermissionsManageInternalUsers, User__r.Profile.PermissionsManageUnlistedGroups, '+
					' Can_Send_Newsletter__c, Can_Send_Alert__c, User__r.CommunityNickname, Is_Influencer__c, User_Hash__c, NPS_Survey_Last_Display_DateTime__c, NPS_Survey_Last_Action__c, Is_Content_Moderator__c, '+
					' Cover_Content_Version_Id__c, User__r.LanguageLocaleKey, Is_Protected_Author_Allowlisted__c, Is_Protected_Author__c, Can_Access_Leadercast__c, Can_Manage_Sentiment_Check__c, Can_Manage_Surveys__c, Enable_Org_Level_Onboarding__c, '+
					' Is_Recognition_Manager__c, Microsoft_Teams_User_Id__c, Microsoft_Teams_User_Name__c, Microsoft_Tenant_Id__c, User__r.Username, Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c FROM People__c '+
					' WHERE User__c=: soqlParam1 limit 1 ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<People__c> peopleListList = (List<People__c>)SIMPESAPI.accessController().queryAsUSer(peopleQuery, peopleSoqlParamMap);
	        if(peopleListList.size()>0){
	        	getCurrentUserInfo = peopleListList[0];
	        	getCurrentUserInfo = updatePeopleObjAccToProfileFields(getCurrentUserInfo);
	        }
        }
	
        return getCurrentUserInfo;
    }private set;}

	public static String timeZoneSIDKey{
    	get{
	    	if(timeZoneSIDKey == null){
	    		if(getCurrentUserInfo != null){
	    			timeZoneSIDKey = getCurrentUserInfo.User__r.TimezoneSIDKey;
	    		}
	    	}
	    	return timeZoneSIDKey;
    	}private set;
    }

	public static String username{
    	get {
	    	if(username == null) {
	    		if(getCurrentUserInfo!=null){
	    			username = getCurrentUserInfo.User__r.Username;
	    		}
	    	}
	    	return username;
         }private set;
    }
    
    public static String segmentAttributeValue{
    	get{
	    	if(segmentAttributeValue == null){
	    		if(getCurrentUserInfo != null){
	    			segmentAttributeValue = getCurrentUserInfo.Segment_Attribute_Value__c;
	    		}
	    	}
	    	return segmentAttributeValue;
    	}private set;
	}

	public static String manager{
    	get{
	    	if(manager == null){
	    		if(getCurrentUserInfo != null){
	    			manager = getCurrentUserInfo.Manager__c;
	    		}
	    	}
	    	return manager;
    	}private set;
    }
    
    @testVisible public static Boolean isSegmentManager{
    	get{
	    	if(isSegmentManager == null){
	    		isSegmentManager = false;
	    		if(getCurrentUserInfo != null){
	    			isSegmentManager = getCurrentUserInfo.Is_Segment_Manager__c;
	    		}
	    	}
	    	return isSegmentManager;
    	}private set;
    }

	@testVisible public static Boolean isInitiativesAndCampaignsManager{
    	get{
	    	if(isInitiativesAndCampaignsManager == null){
	    		isInitiativesAndCampaignsManager = false;
	    		if(getCurrentUserInfo != null){
	    			isInitiativesAndCampaignsManager = getCurrentUserInfo.CI_Moderation_Permission__c;
	    		}
	    	}
	    	return isInitiativesAndCampaignsManager;
    	}private set;
    }
    
   @TestVisible public static DateTime firstLoginDateTime{
    	get{
    		if(firstLoginDateTime == null) {
    			if(getCurrentUserInfo != null && getCurrentUserInfo.First_Login_DateTime__c != null){
	    			firstLoginDateTime = getCurrentUserInfo.First_Login_DateTime__c;
	    		} else {
	    			firstLoginDateTime = DateTime.now();
	    		}
    		}
    		return firstLoginDateTime;
    	}private set;
    }
    public static String userHash{
    	get{
	    	if(userHash == null){
	    		if(getCurrentUserInfo != null){
	    			userHash = getCurrentUserInfo.User_Hash__c;
	    		}
	    	}
	    	return userHash;
    	}private set;
    }
    @TestVisible
    public static String segmentId{
    	get{
	    	if(segmentId == null){
	    		if(getCurrentUserInfo != null){
	    			segmentId = getCurrentUserInfo.Segment__c;
	    		}
	    	}
	    	return segmentId;
    	}private set;
    }

	public static String segmentName{
    	get{
	    	if(segmentName == null){
	    		if(getCurrentUserInfo != null){
	    			segmentName = getCurrentUserInfo.Segment__r.Name__c;
	    		}
	    	}
	    	return segmentName;
    	}private set;
    }
    
	public static String getSegmentCSSClasses {
		get{
			if(getSegmentCSSClasses == null){
				if(getCurrentUserInfo != null && String.isNotBlank(segmentId)){
					getSegmentCSSClasses = getCurrentUserInfo.Segment__r.Branding_CSS_Class__c;
				}
			} 
			return getSegmentCSSClasses;
		}private set;
	}
    
    public static String segmentTileLayout{
    	get{
	    	if(segmentTileLayout == null){
	    		if(getCurrentUserInfo != null && String.isNotBlank(segmentId)){
	    			segmentTileLayout = getCurrentUserInfo.Segment__r.Layout__c;
	    		}
	    	}
	    	return segmentTileLayout;
    	}private set;
    }
    
    public static Boolean isLaunchpadConfigured{
    	get{
			isLaunchpadConfigured = false;
			Boolean useSegmentAppsNLinks = SimpplrContext.isSegmentsEnabled && SimpplrContext.isSegmentAppsNLinksEnabled;
	    	if(!useSegmentAppsNLinks){
				isLaunchpadConfigured = SimpplrContext.isLaunchpadConfigured;
	    	} else if(getCurrentUserInfo != null && String.isNotBlank(segmentId)){
	    		isLaunchpadConfigured = String.isNotBlank(getCurrentUserInfo.Segment__r.SSO_Provider__c) && !'None'.equalsIgnoreCase(getCurrentUserInfo.Segment__r.SSO_Provider__c);
			}
	    	return isLaunchpadConfigured;
    	}private set;
    }
    
	/**
	 * @description This property tells if user have content moderation priveledges
   	 * @return `Boolean'
    */
	@TestVisible
	public static Boolean isContentModerator{
    	get{
	    	if(isContentModerator == null){
				isContentModerator = false;
	    		if(getCurrentUserInfo != null){
	    			isContentModerator = SimpplrContext.aiContentModerationEnabled ? getCurrentUserInfo.Is_Content_Moderator__c : false;
	    		}
	    	}
	    	return isContentModerator;
    	}private set;
    }

    public static String tileLayout{
    	get{
	    	if(tileLayout == null){
	    		if(getCurrentUserSettings != null){
	    			tileLayout = getCurrentUserSettings.Layout__c;
	    		}
	    	}
	    	return tileLayout;
    	}private set;
    }
    
    public static String communityNickname {
    	get{
    		if(communityNickname == null) {
	    		if(getCurrentUserInfo!=null){
	    			communityNickname = getCurrentUserInfo.User__r.CommunityNickname;
	    		}
	    	}
	    	return communityNickname;
    	}private set;
    }
    
    public static String mobileLandingPage{
    	get{
	    	if(mobileLandingPage == null){
	    		if(getCurrentUserSettings != null){
	    			mobileLandingPage = getCurrentUserSettings.Mobile_Landing_Page__c;
	    		}
	    	}
	    	return mobileLandingPage;
    	}private set;
    }
    
    public static Boolean isTilesInitialized{
    	get{
	    	if(isTilesInitialized == null){
				isTilesInitialized = false;
	    		if(getCurrentUserSettings != null){
	    			isTilesInitialized = getCurrentUserSettings.Tiles_Initialized__c;
	    		}
	    	}
	    	return isTilesInitialized;
    	}private set;
    }
    
    public static People__c updatePeopleObjAccToProfileFields(People__c pplObj){ 
		if(SimpplrContext.isPPTitleDisplay == false){
			pplObj.Title__c = null;
		}
		if(SimpplrContext.isPPDepartmentDisplay == false){
			pplObj.Department__c = null;
		}
		if(SimpplrContext.isPPStreetDisplay == false){
			pplObj.Street__c = null;
		}
		if(SimpplrContext.isPPCityDisplay == false){
			pplObj.City__c = null;
		}
		if(SimpplrContext.isPPStateDisplay == false){
			pplObj.State__c = null;
		}
		if(SimpplrContext.isPPFirstNameDisplay == false){
			pplObj.First_Name__c = null;
		}
		if(SimpplrContext.isPPLastNameDisplay == false){
			pplObj.Last_Name__c = null;
		}
		if(SimpplrContext.isPPPhoneDisplay == false){
			pplObj.Phone__c = null;
		}
		if(SimpplrContext.isPPAboutMeDisplay == false){
			pplObj.About__c = null;
		}
		return pplObj;
	}
    
    public static List<PermissionSetAssignment> getCurrentUserPermissionSetList{get{
    	if(getCurrentUserPermissionSetList == null){
			getCurrentUserPermissionSetList = [Select PermissionSet.Name,PermissionSet.NameSpacePrefix,PermissionSet.PermissionsModifyAllData,PermissionSet.PermissionsChatterOwnGroups,
							   PermissionSet.PermissionsModerateChatter, PermissionSet.PermissionsCreateTopics,PermissionSet.PermissionsManageInternalUsers, PermissionSet.PermissionsManageUnlistedGroups
							   From PermissionSetAssignment WHERE AssigneeId =:Id];
    	}
		return getCurrentUserPermissionSetList;
    }private set;}
    
    public static Boolean hasManageCampaignAccess {get {
    		hasManageCampaignAccess = false;
    		if(getCurrentUserInfo!=null){
    			hasManageCampaignAccess = getCurrentUserInfo.Is_Campaign_Manager__c;
    		}
    		if(hasManageCampaignAccess == false) {
    			hasManageCampaignAccess = isUserAppModerator;
    		}
    		return hasManageCampaignAccess;
    }private set;}
    
    public static Boolean hasManageSegmentAccess {get {
    		hasManageSegmentAccess = false;
    		if(getCurrentUserInfo!=null){
    			hasManageSegmentAccess = getCurrentUserInfo.Is_Segment_Manager__c;
    		}
    		if(hasManageSegmentAccess == false) {
    			hasManageSegmentAccess = isUserAppModerator;
    		}
    		return hasManageSegmentAccess;
    }private set;}    
    
    @TestVisible public static Boolean hasSimpplrUserPermissionSetAssigned{ get{
    	if(hasSimpplrUserPermissionSetAssigned == null){
    		hasSimpplrUserPermissionSetAssigned = false;
			for(PermissionSetAssignment permissionSetAssignObj : getCurrentUserPermissionSetList){
				if(permissionSetAssignObj.PermissionSet.Name.equalsIgnoreCase('Simpplr_User')){
					hasSimpplrUserPermissionSetAssigned = true;
					break;
				}
			}
    	}
    	return hasSimpplrUserPermissionSetAssigned;
    }private set;}
    
    /**
    ** TODO - Ajay
    */
    public static People_Preference__c getCurrentUserSettings{
    	get{
	    	list<People_Preference__c> peoplePreference = new List<People_Preference__c>();
	        if(getCurrentUserSettings == null){
	            peoplePreference.addAll([Select Id, Mobile_Landing_Page__c, Layout__c, Tiles_Initialized__c, 
	            						 Box_Username__c, Box_Favorite_Collection_Id__c, Feed_Type__c, 
	            						 Feed_Sort_Order__c, Box_User_Id__c, Email_Product_Research__c,
	            						 Box_Access_Token__c, Box_Refresh_Token__c, Box_Refresh_Token_Expires_At__c,
										 people__c, People__r.Full_Name__c, Disable_Onboarding_Feed__c,
										 Dismissed_Onboarding_Flags__c, Slack_User_Name__c, 
										 Allow_Browser_Notifications__c, Dismissed_Prompt_Web_Notifications__c
										 FROM People_Preference__c 
	            						 WHERE People__r.User__c=:UserInfo.getUserId()]);
	            						 
		        if(peoplePreference.size()>0){
		        	getCurrentUserSettings = peoplePreference[0];
		        }
	        }
	        return getCurrentUserSettings;
    	}private set;
    }
    
    public static String feedSortOrder{get{
    	if(feedSortOrder == null){
    		feedSortOrder = 'activity';
    		if(getCurrentUserSettings!=null){
				feedSortOrder = getCurrentUserSettings.Feed_Sort_Order__c;
    		}
    	}
    	return feedSortOrder;
    }private set;}
    
    public static String feedFilter{get{
    	if(feedFilter == null){
    		feedFilter = 'news';
    		if(getCurrentUserSettings!=null){
				feedFilter = getCurrentUserSettings.Feed_Type__c;
    		}
    	}
    	return feedFilter;
    }private set;}
    
    /**
    *
    */
    public static String boxUserId {
    	get {
			if(boxUserId == null) {   		
    			if(getCurrentUserSettings!=null){
    				boxUserId = getCurrentUserSettings.Box_User_Id__c;
    			}
			}
			return boxUserId;
    	}private set;
    }
	@TestVisible
    public static Boolean isBoxConnected {
    	get {
	    	if(isBoxConnected == null) {
	    		isBoxConnected = false;
	    		if(SimpplrContext.IsBoxIntegrationEnabled) {
		    		if(getCurrentUserSettings != null) {
						if(String.isNotBlank(getCurrentUserSettings.Box_Refresh_Token__c) &&
							getCurrentUserSettings.Box_Refresh_Token_Expires_At__c > Datetime.now()) {

							isBoxConnected = String.isNotBlank(getCurrentUserSettings.Box_Access_Token__c);
						}
		    		}
	    		}
	        }
			return isBoxConnected;
    	}private set;
	}


	@TestVisible
    public static Boolean isSlackUnfurlConnected {
    	get{
    		if(isSlackUnfurlConnected == null){
				isSlackUnfurlConnected = false;
				if(Integrations != null && Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL)) {
    				isSlackUnfurlConnected = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL).Connected__c;
				}
    		}
    		return isSlackUnfurlConnected;
    	}private set;
	}
	
    public static Boolean isSlackContentShareConnected {
    	get{
    		if(isSlackContentShareConnected == null){
				isSlackContentShareConnected = false;
				if(Integrations != null && Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE)) {
    				isSlackContentShareConnected = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE).Connected__c;
				}
    		}
    		return isSlackContentShareConnected;
    	}private set;
	}	
	
	/**
    **
    */
	public static Set<Id> usersIFollowIdSet{get{
        if(usersIFollowIdSet == null){
            usersIFollowIdSet = usersIFollowAndEntitySubscriptionIdMap.keySet();
        }
        return usersIFollowIdSet;
    }private set;}
    
    /**
    **
    */
    public static Map<Id, Id> usersIFollowAndEntitySubscriptionIdMap{get{
    	if(usersIFollowAndEntitySubscriptionIdMap == null) {
    		usersIFollowAndEntitySubscriptionIdMap = new Map<Id, Id>();
    		//Limit 1000 is imposed by Salesforce for non-admin users
    		String currentUserId = UserInfo.getUserId();
    		String BASE_QUERY = 'Select Id, ParentId From EntitySubscription '+
    					   'where parent.type=\'User\' and  isDeleted=false '+
    					   'AND ParentID IN (SELECT User__c from People__c '+
    					   'WHERE ((User__r.isActive=true And User__r.UserType=\'Standard\' '+
    					   'And User__r.Show_Simpplr__c != \'No\') Or User__r.Show_Simpplr__c = \'Yes\')) '+
    					   'And SubscriberId=:currentUserId';
    		if(SimpplrContext.isCommunitiesEnabled){
    			BASE_QUERY+=' And NetworkId = null';
    		}
    		String SUB_CONDITION = ' Limit 1000';
    		String query = BASE_QUERY+SUB_CONDITION;
    		
    		List<EntitySubscription> listOfES= new List<EntitySubscription>();
            listOfES = Database.query(query);
            for(EntitySubscription es:listOfES) {
            	usersIFollowAndEntitySubscriptionIdMap.put(es.parentId, es.Id);
            }
    	}
    	return usersIFollowAndEntitySubscriptionIdMap; 
    }private set;}
    
    /**
    **
    */
    public static List<Id> listOfMyFavoriteSiteID { 
    	get{
	    	if (listOfMyFavoriteSiteID == null) {
	    		listOfMyFavoriteSiteID = new List<Id>();
	    		Map<Id,Bookmark__c> mapOfGrpIdWithFavoriteSite = new Map<Id,Bookmark__c>();
		    	List<Bookmark__c> listOfSiteBookmark = [SELECT Id, Simpplr_Site__c,Simpplr_Site__r.Chatter_Group_Id__c FROM Bookmark__c WHERE People__c=:peopleId  AND Is_Deleted__c = false AND Type__c='Site' AND Simpplr_Site__r.Chatter_Group_Id__c IN:Utility.getAllCollaborationGroupMap().keySet() AND Simpplr_Site__r.Is_Active__c=true];
				for(Bookmark__c bookmarkObj : listOfSiteBookmark){
					mapOfGrpIdWithFavoriteSite.put(bookmarkObj.Simpplr_Site__r.Chatter_Group_Id__c,bookmarkObj);
				}
				Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrpForUser = Utility.getMapOfIdWithCollaborationGroup(userId);
				if(!hasModifyAllDataPermission){
					for (Id grpId : mapOfGrpIdWithFavoriteSite.keyset()) {
						if(mapOfIdWithCollaborationGrpForUser.get(grpId).GroupMembers.isEmpty() && mapOfIdWithCollaborationGrpForUser.get(grpId).CollaborationType == 'private' ){
							mapOfGrpIdWithFavoriteSite.remove(grpId);
						}
					}
				}
				List<Bookmark__c> listOfBookmarkedSite = new List<Bookmark__c>();
				listOfBookmarkedSite = mapOfGrpIdWithFavoriteSite.values();
				if (!listOfBookmarkedSite.isEmpty()) {
					for (Bookmark__c bookmarkObj: listOfBookmarkedSite) {
						listOfMyFavoriteSiteID.add(bookmarkObj.Simpplr_Site__c);
					}
				}
				
	    	}
	    	return listOfMyFavoriteSiteID;
    	}private set;
    }
    
    public static Set<Id> setOfMyFavouriteSiteId {
    	get {
    		if(setOfMyFavouriteSiteId == null){
	    		setOfMyFavouriteSiteId = new Set<id>();
	    		if(listOfMyFavoriteSiteID != null){
		    		setOfMyFavouriteSiteId.addAll(listOfMyFavoriteSiteID);
	    		}
    		}
    		return setOfMyFavouriteSiteId;
    	}private set;
    }
    
    public static Set<Id> setOfMyFavouritePeopleId {
		get {
			if(setOfMyFavouritePeopleId == null){
				setOfMyFavouritePeopleId = new Set<id>();
				List<Bookmark__c> listOfPeopleBookmark = [SELECT Bookmark_Receiver__c FROM Bookmark__c WHERE People__c=:peopleId AND Type__c='People'  AND Is_Deleted__c = false order by CreatedDate desc]; 
				for(Bookmark__c bookmarkObj : listOfPeopleBookmark) {
					setOfMyFavouritePeopleId.add(bookmarkObj.Bookmark_Receiver__c);
				}
			}
			return setOfMyFavouritePeopleId;
		}private set;
    }
    
    public static Boolean canCreateTopics {
    	get {
			if(canCreateTopics == null) {
				canCreateTopics = false;
				if(getCurrentUserInfo != null){
					if(getCurrentUserInfo.User__r.Profile.PermissionsCreateTopics) {
						canCreateTopics = true;
					} else {
						canCreateTopics = false;
						for(PermissionSetAssignment assignmentObj: getCurrentUserPermissionSetList) {
							if(assignmentObj.PermissionSet.PermissionsCreateTopics) {
								canCreateTopics = true;
								break;
							}
						}
					}
				} else {
					canCreateTopics = false;
				}
			}
			return canCreateTopics;
    	}private set;
    }
    
    public static Boolean canManageInternalUsers {
    	get {
			if(canManageInternalUsers == null) {
				canManageInternalUsers = false;
				if(getCurrentUserInfo != null){
					if(getCurrentUserInfo.User__r.Profile.PermissionsManageInternalUsers) {
						canManageInternalUsers = true;
					} else {
						canManageInternalUsers = false;
						for(PermissionSetAssignment assignmentObj: getCurrentUserPermissionSetList) {
							if(assignmentObj.PermissionSet.PermissionsManageInternalUsers) {
								canManageInternalUsers = true;
								break;
							}
						}
					}
				} else {
					canManageInternalUsers = false;
				}
			}
			return canManageInternalUsers;
    	}private set;
    }
    
    public static Boolean canCreateOrOwnGroups {
    	get {
			if(canCreateOrOwnGroups == null) {
				canCreateOrOwnGroups = false;
				Boolean hasPermissionInSF = false;
				if( SimpplrContext.isATCollaborationGroupEnabled && SimpplrContext.isATCollaborationGroupMemberEnabled ) {
					if(getCurrentUserInfo != null){
						
						if(getCurrentUserInfo.User__r.Profile.PermissionsChatterOwnGroups) {
							hasPermissionInSF = true;
						} else {
							hasPermissionInSF = false;
							for(PermissionSetAssignment assignmentObj: getCurrentUserPermissionSetList) {
								if(assignmentObj.PermissionSet.PermissionsChatterOwnGroups) {
									hasPermissionInSF = true;
									break;
								}
							}
						}
						
						if (SimpplrContext.appConfig != NULL){
							if ('app managers'.equalsIgnoreCase(SimpplrContext.appConfig.Allow_Site_Add__c)){
								canCreateOrOwnGroups = hasPermissionInSF && isUserAppModerator ;
							} else if ('all'.equalsIgnoreCase(SimpplrContext.appConfig.Allow_Site_Add__c)) {
								canCreateOrOwnGroups = hasPermissionInSF ;
							} else if(isUserAppModerator) {
								canCreateOrOwnGroups = hasPermissionInSF;
							} else if ('selected users'.equalsIgnoreCase(SimpplrContext.appConfig.Allow_Site_Add__c)) {
								canCreateOrOwnGroups = hasPermissionInSF && getCurrentUserInfo.Can_Add_Sites__c ;
							}	
						}
					}
				}
				else {
		    		canCreateOrOwnGroups = false;
				}
			}
	    	return canCreateOrOwnGroups;
         }private set;
    }
    
	@TestVisible
   	public static Boolean hasModifyAllDataPermission {
    	get {
    		if(hasModifyAllDataPermission == null) {
    			hasModifyAllDataPermission = false;
    			if(getCurrentUserInfo != null){
					if(getCurrentUserInfo.User__r.Profile.PermissionsModifyAllData) {
						hasModifyAllDataPermission = true;
					} else {
						hasModifyAllDataPermission = false;
						for(PermissionSetAssignment assignmentObj: getCurrentUserPermissionSetList) {
							if(assignmentObj.PermissionSet.PermissionsModifyAllData) {
								hasModifyAllDataPermission = true;
								break;
							}
						}
					}
	    		}
    		}
    		return hasModifyAllDataPermission;
    	}private set;
    }
    
    /**
    **
    */
	public static Set<Id> topicsIFollowIdSet{get{
        if(topicsIFollowIdSet == null){
            topicsIFollowIdSet = topicsIFollowAndEntitySubscriptionIdMap.keySet();
        }
        return topicsIFollowIdSet;
    }private set;}
    
    /**
    **
    */
    public static Map<Id, Id> topicsIFollowAndEntitySubscriptionIdMap{get{
    	if(topicsIFollowAndEntitySubscriptionIdMap == null) {
    		topicsIFollowAndEntitySubscriptionIdMap = new Map<Id, Id>();
    		//Limit 1000 is imposed by Salesforce for non-admin users
    		String currentUserId = UserInfo.getUserId();
    		String BASE_QUERY = 'Select Id, ParentId From EntitySubscription '+
    					   'where parent.type=\'Topic\' and  isDeleted=false '+
    					   'And SubscriberId=:currentUserId';
    		
    		if(SimpplrContext.isCommunitiesEnabled){
    			BASE_QUERY+=' And NetworkId = null';
    		}
    		String SUB_CONDITION = ' Limit 1000';
    		String query = BASE_QUERY+SUB_CONDITION;
    		
    		List<EntitySubscription> listOfES= new List<EntitySubscription>();
            listOfES = Database.query(query);
            for(EntitySubscription es:listOfES) {
            	topicsIFollowAndEntitySubscriptionIdMap.put(es.parentId, es.Id);
            }
    	}
    	return topicsIFollowAndEntitySubscriptionIdMap; 
    }private set;}
    
	@TestVisible
   	public static Boolean hasManageUnlistedSitePermission {
    	get {
    		if(hasManageUnlistedSitePermission == null) {
    			hasManageUnlistedSitePermission = false;
    			if(getCurrentUserInfo != null && 'Yes'.equalsIgnoreCase(getCurrentUserInfo.Unlisted_Site_Moderation_Permission__c)){
					if(getCurrentUserInfo.User__r.Profile.PermissionsManageUnlistedGroups ) {
						hasManageUnlistedSitePermission = true;
					} else {
						hasManageUnlistedSitePermission = false;
						for(PermissionSetAssignment assignmentObj: getCurrentUserPermissionSetList) {
							if(assignmentObj.PermissionSet.PermissionsManageUnlistedGroups ) {
								hasManageUnlistedSitePermission = true;
								break;
							}
						}
					}
	    		}
    		}
    		return hasManageUnlistedSitePermission;
    	}private set;
    }

    public static Map<String, People_Integration__c> Integrations {
    	get {
    		if(Integrations == null) {
    			Integrations = new Map<String, People_Integration__c>();
				List<People_Integration__c> peopleIntList = new List<People_Integration__c>();
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', UserInfo.getUserId());
				soqlParamMap.put('soqlParam2', UserInfo.getOrganizationId());
				String query = 'Select Id, Name, Token_Type__c,My_Drive_Id__c,'+
								' Refresh_Token__c, Refresh_Token_Requested_Datetime__c, Unsuccessful_Group_Id_Set__c,'+
								' Access_Token__c, Access_Token_Requested_Datetime__c, Access_Token_Expiry__c,Group_Id_Set__c, '+
								' External_Id__c,People__c, User__c,  User_Email__c, User_Name__c,Batch_Flag__c ,'+
								' Connected__c, App_Integration__c, App_Integration__r.Org_Id__c, Is_SP_Admin__c, '+
								' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,People__r.Full_Name__c,'+
								' People__r.Id , SP_Instance_Id__c '+
								' FROM People_Integration__c '+
								' WHERE People__r.User__c=:soqlParam1 '+
								' AND App_Integration__r.Org_Id__c=:soqlParam2 '+
								' AND Is_Deleted__c = false';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				peopleIntList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

				for (People_Integration__c integObj : peopleIntList) {
					Integrations.put(integObj.Name, integObj);					   			
				}

    		}

			return Integrations;
    	}private set;
    }
    
    public static Boolean isGdriveConnected{
    	get{
    		if(isGdriveConnected == null){
				isGdriveConnected = false;
				if(Integrations != null && Integrations.containsKey(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING)) {
    				isGdriveConnected = Integrations.get(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING).Connected__c;
				}
    		}
    		return isGdriveConnected;
    	}private set;
    }

    public static Boolean isGoogledriveConnected{
    	get{
    		if(isGoogledriveConnected == null){
				isGoogledriveConnected = false;
				if(Integrations != null && Integrations.containsKey(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING)) {
    				isGoogledriveConnected = Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Connected__c;
				}
    		}
    		return isGoogledriveConnected;
    	}private set;
    }
    public static Boolean isDropboxConnected{
    	get{
    		if(isDropboxConnected == null){
				isDropboxConnected = false;
				if(Integrations != null && Integrations.containsKey(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
    				isDropboxConnected = Integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Connected__c;
				}
    		}
    		return isDropboxConnected;
    	}private set;
    }

    public static set<String> connectedStorages {
    	get {
    		if(connectedStorages == null) {
    			connectedStorages = new Set<String>();
    			if(SimpplrContext.integrations != null && integrations != null) {
					for(String name : integrations.keySet()){
						if(SimpplrContext.integrations.get(name) != null &&
							SimpplrContext.integrations.get(name).Integration_Enabled__c && 
						   	SimpplrContext.integrations.get(name).Connected__c && 
						   	integrations.get(name).Connected__c){
							connectedStorages.add(name); 
						}
					}
    			}
    		}
    		return connectedStorages;
    	}private set;
    }

	/**
     * @description isSharepointConnected
     * @return true if sharepoint is connected
     */
	public static Boolean isSharepointConnected{
    	get{
    		if(isSharepointConnected == null){
				isSharepointConnected = false;
				if(Integrations != null && Integrations.containsKey(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING)) {
    				isSharepointConnected = Integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).Connected__c;
				}
    		}
    		return isSharepointConnected;
    	}private set;
    }
	
	/**
     * @description sharepoint Instance Id of sharepoint user is connected
     * @return String Instance Id
     */
	public static String spInstanceId {
    	get{
    		if(isSharepointConnected == true){
				spInstanceId = '';
				if(Integrations != null && Integrations.containsKey(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING)) {
    				spInstanceId = Integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).SP_Instance_Id__c;
				}
    		}
    		return spInstanceId;
    	}private set;
    }

	/**
	 * @description used to check is user is owner of any site
	 * @return if user is owner of any site then return true otherwise false
	 */
	public static Boolean isUserSiteOwner{
		get{
			if (isUserSiteOwner == null) {
				isUserSiteOwner = false;
				for(CollaborationGroup chatterGroup : chatterGroupsIFollowMap.values()) {
					if(chatterGroup.OwnerId == Id) {
						isUserSiteOwner = true;
						break;
					}
				}
			}
			return isUserSiteOwner;
		} private set;
	}

	/**
	 * @description used to check is user is manager of any other user
	 * @return if user is manager of any other user then return true otherwise false
	 */
	public static Boolean isUserPeopleManager{
		get{
			if (isUserPeopleManager == null) {
				isUserPeopleManager = false;
				if(peopleIManageMap.size()>0) {
					isUserPeopleManager = true;
				}
			}
			return isUserPeopleManager;
		} private set;
	}

	/**
	 * @description can this user access leadercast feature or not
	 * @return Boolean
	 */
	public static Boolean canAccessLeadercast {
		get {
			if(canAccessLeadercast == null) {
				canAccessLeadercast = false;
				if(getCurrentUserInfo != null) {
					canAccessLeadercast = getCurrentUserInfo.Can_Access_Leadercast__c;
				}
			}
			return canAccessLeadercast;
		} private set;
	}

	
	/**
	 * @description check whether current user manage sentiment check
	 * @return Boolean
	 */
	public static Boolean canManageSentimentCheck {
		get {
			if(canManageSentimentCheck == null) {
			canManageSentimentCheck = userSentimentCheckEnabled || isUserAppModerator;				
				if(canManageSentimentCheck == false && !sitesIManageMap.isEmpty()) {	
					for(Simpplr_Site__c ss : sitesIManageMap.values()){
						if(ss.Is_Sentiment_Check_Enabled__c){
							canManageSentimentCheck = true;
							break;
						}
					}
				}
			}
			return canManageSentimentCheck;
		 }private set;
	}

	/**
	 * @description check whether current user manage surveys or not
	 * @return Boolean
	 */
	public static Boolean canManageSurveys {
		get {
			canManageSurveys = false;
        		if(getCurrentUserInfo!= null && getCurrentUserInfo.Can_Manage_Surveys__c) {
					canManageSurveys = true;
				}	
			return canManageSurveys;
		 }private set;
	}

	/**
	 * @description check whether current user manage recognition
	 * @return Boolean
	 */
	public static Boolean canManageRecognition {
		get {
			canManageRecognition = false;
        		if(getCurrentUserInfo!= null && getCurrentUserInfo.Is_Recognition_Manager__c) {
					canManageRecognition = true;
				}	
			return canManageRecognition;
		 }private set;
	}
    
	public static String microsoftTeamsUserId{
    	get{
	    	if(microsoftTeamsUserId == null){
	    		if(getCurrentUserInfo != null){
	    			microsoftTeamsUserId = getCurrentUserInfo.Microsoft_Teams_User_Id__c;
	    		}
	    	}
	    	return microsoftTeamsUserId;
    	}private set;
    }

	public static String microsoftTeamsUserName{
    	get{
	    	if(microsoftTeamsUserName == null){
	    		if(getCurrentUserInfo != null){
	    			microsoftTeamsUserName = getCurrentUserInfo.Microsoft_Teams_User_Name__c;
	    		}
	    	}
	    	return microsoftTeamsUserName;
    	}private set;
    }

	public static String microsoftTeamsConnectedAs{
    	get{
	    	if(microsoftTeamsConnectedAs == null){
	    		if(Integrations != null && Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS)) {
					People_Integration__c obj = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS);
    				microsoftTeamsConnectedAs = obj.User_Name__c + ' - ' + obj.User_Email__c;
				}
	    	}
	    	return microsoftTeamsConnectedAs;
    	}private set;
    }

	public static String microsoftTenantId{
    	get{
	    	if(microsoftTenantId == null){
	    		if(getCurrentUserInfo != null){
	    			microsoftTenantId = getCurrentUserInfo.Microsoft_Tenant_Id__c;
	    		}
	    	}
	    	return microsoftTenantId;
    	}private set;
    }
	@TestVisible
	public static String uuid{
    	get{
	    	if(uuid == null){
	    		if(getCurrentUserInfo != null){
	    			uuid = getCurrentUserInfo.UUID__c;
	    		}
	    	}
	    	return uuid;
    	}private set;
    }

	public static String slackConnectedAs{
    	get{
	    	if(slackConnectedAs == null){
				if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded){
					if(Integrations != null && Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SLACK)) {
						slackConnectedAs = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).User_Name__c;	
					}
				} else {
					if(Integrations != null && Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE)) {
						slackConnectedAs = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE).User_Name__c;	
					}
				}
			}
	    	return slackConnectedAs;
    	}private set;
    }

	public static String slackUserId{
    	get{
	    	if(slackUserId == null){
	    		if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && getCurrentUserInfo != null){
					slackUserId = getCurrentUserInfo.Slack_User_Id__c;
				
				} else {
					if(Integrations != null && Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE)) {
						slackUserId = Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE).User_Email__c;	
					}
				}
	    	}
	    	return slackUserId;
    	}private set;
    }
	/**
	 * @description slack username of loggedIn user
	 * @return String
	 */
	public static String slackUserName{
    	get{
	    	if(slackUserName == null){
	    		if(getCurrentUserInfo != null){
	    			slackUserName = getCurrentUserInfo.Slack_User_Name__c;
	    		}
	    	}
	    	return slackUserName;
    	}private set;
    }
	/**
	 * @description slack tenantId of loggedIn user
	 * @return String
	 */
	public static String slackTenantId{
    	get{
	    	if(slackTenantId == null){
	    		if(getCurrentUserInfo != null){
	    			slackTenantId = getCurrentUserInfo.Slack_Tenant_Id__c;
	    		}
	    	}
	    	return slackTenantId;
    	}private set;
    }

}