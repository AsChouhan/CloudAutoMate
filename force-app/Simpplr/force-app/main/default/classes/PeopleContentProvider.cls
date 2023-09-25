public with sharing class PeopleContentProvider {
	
	
	private static final String profilePlaceholderImage = 'https://static.simpplr.com/slack/profile.png';
	public static Integer totalRecords;
	
	public static List<PeopleListWrapper> getProfileConnectionsFollowing (Criteria.People peopleCriteriaObjArg) {
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;  
		List<Id> listOfUserId = new List<Id>();
		PeopleDao peopleDaoObj = new PeopleDao();
		listOfUserId = peopleDaoObj.getUsersFollowingList(peopleCriteriaObjArg.sfUserId);
		
		List<Id> listOfTopicExpertiseUserId;
		if(String.isNotBlank(peopleCriteriaObjArg.expertise_term)) {
			listOfTopicExpertiseUserId = new List<Id>();
			listOfTopicExpertiseUserId.addAll(getTopEndorseeUserForSearchedExpertise(peopleCriteriaObjArg.expertise_term));
		}
		List<People__c> listOfPeople = peopleDaoObj.getProfileConnectionsFollowing(peopleCriteriaObjArg.userCategory, 
				peopleCriteriaObjArg.department, peopleCriteriaObjArg.location, peopleCriteriaObjArg.offset, recordLimit, 
				listOfUserId,peopleCriteriaObjArg.sortBy,listOfTopicExpertiseUserId);
		List<PeopleListWrapper> listOfPeopleWrapper = PeopleListWrapper.peopleListToWrapper(listOfPeople);
		return listOfPeopleWrapper;
	}
	
	public static List<PeopleListWrapper> autoComplete(Criteria.People peopleCriteriaObjArg, List<String> peopleIds){
        
		String searchTerm = peopleCriteriaObjArg.term;
		String chatterGroupId = peopleCriteriaObjArg.chatterGroupId;
		String segmentId = peopleCriteriaObjArg.segmentId;

		Integer recordlimit = null;
		Integer offset = null;
		if (peopleCriteriaObjArg.nextPageToken == null) {
				offset = 0;	
		} else {
				offset = Integer.valueOf(peopleCriteriaObjArg.nextPageToken);
		}
		if(peopleIds == null || peopleIds.isEmpty()) {
			recordlimit = peopleCriteriaObjArg.size != null ? peopleCriteriaObjArg.size + 1 : SimpplrContext.simpplrDefaultPageSize + 1;
		}
		
		PeopleDao peopleDaoObj = new PeopleDao();
        List<People__c> peopleList = new List<People__c>();
        if(String.isNotBlank(chatterGroupId)) {
        	peopleList = peopleDaoObj.getPeopleListBySearchTermAndGroupId(searchTerm, chatterGroupId, peopleIds, recordlimit);
        } else if(String.isNotBlank(segmentId)) {
        	peopleList = peopleDaoObj.getPeopleListBySearchTermAndSegmentId(searchTerm, segmentId, peopleIds, recordlimit);
        } else {
        	peopleList = peopleDaoObj.getPeopleListBySearchTerm(searchTerm, peopleIds, recordlimit, offset);
        }
        List<PeopleListWrapper> peopleListWrapperObj = PeopleListWrapper.peopleListToWrapper(peopleList);
        return peopleListWrapperObj;
    }
	
	public static Map<Id,People__c> getSiteMembersBySearchTermWithExclusionMap(List<String> groupIdList,String searchTerm,Set<Id> invitedUsersIdSet){
        searchTerm = '%' + searchTerm + '%';
        return New Map<Id,People__c>([Select Id, User__c, Phone__c, Email__c, Title__c, About__c,Zoom_Id__c,Skype_Id__c, 
		        User__r.SmallPhotoUrl, User__r.FullPhotoUrl, Full_Name__c, Department__c,Birth_Date__c,Joining_Date__c,
		        City__c, Street__c, Country__c, State__c, User__r.IsActive,Mobile_Phone__c,Last_Name__c,Extension__c,
		        Manager__r.User__c,  Manager__r.Full_Name__c, Manager__r.User__r.IsActive,Community_Nickname__c,
		        First_Name__c, Segment__r.Name__c, Division__c, Company_Name__c,Is_Protected_Author__c,User__r.LanguageLocaleKey,User__r.TimeZoneSidKey, Microsoft_Teams_User_Id__c, Microsoft_Teams_User_Name__c, Microsoft_Tenant_Id__c, 
				Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c, 
		        (select connected__c, name from People_Integrations__r)
		        FROM People__c WHERE User__c IN (SELECT MemberId FROM CollaborationGroupMember 
                WHERE CollaborationGroupId IN :groupIdList AND Member.Name LIKE : searchTerm)
		        AND Id NOT IN:invitedUsersIdSet AND User__r.isActive = true
        ]);
    }
    
    
    public static List<People__c> getSiteMembersBySearchTermWithExclusionList(String groupId,String searchTerm,Set<Id> invitedUsersIdSet){
        List<People__c> result = New List<People__c>();
        if(!String.isBlank(groupId)){
           Map<Id,People__c> mapOfContent = getSiteMembersBySearchTermWithExclusionMap(New List<String>{groupId},searchTerm,invitedUsersIdSet);
            if(mapOfContent.size() > 0){
                result = mapOfContent.values();
            }
        }
        return result;
    }
	
	public static List<PeopleListWrapper> getProfileConnectionsFollowers (Criteria.People peopleCriteriaObjArg) {
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;  
		List<Id> listOfUserId = new List<Id>();
		PeopleDao peopleDaoObj = new PeopleDao();
		listOfUserId = peopleDaoObj.getUsersFollowerList(peopleCriteriaObjArg.sfUserId);
		
		List<Id> listOfTopicExpertiseUserId;
		if(String.isNotBlank(peopleCriteriaObjArg.expertise_term)) {
			listOfTopicExpertiseUserId = new List<Id>();
			listOfTopicExpertiseUserId.addAll(getTopEndorseeUserForSearchedExpertise(peopleCriteriaObjArg.expertise_term));
		}
		List<People__c> listOfPeople = peopleDaoObj.getProfileConnectionsFollowers(peopleCriteriaObjArg.userCategory, 
				peopleCriteriaObjArg.department, peopleCriteriaObjArg.location, peopleCriteriaObjArg.offset , recordLimit, 
				listOfUserId, peopleCriteriaObjArg.sortBy, listOfTopicExpertiseUserId);
		
		List<PeopleListWrapper> listOfPeopleWrapper = PeopleListWrapper.peopleListToWrapper(listOfPeople);
		return listOfPeopleWrapper;
	}
	
	public static List<PeopleListingWrapper> getPeopleByUserId (String userId) {
		List<PeopleListingWrapper> listOfPeopleWrapper = new List<PeopleListingWrapper>();
		PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> listOfPeople = peopleDaoObj.getPeopleByUserId(userId);
		for (People__c peopleObj : listOfPeople) {
			PeopleListingWrapper peopleWrapObj = new PeopleListingWrapper();
			peopleWrapObj = ObjectToWrapperAdapter.peopleToWrapper(peopleObj);
			listOfPeopleWrapper.add(peopleWrapObj);
		}
		return listOfPeopleWrapper;
	}
	
	public static List<PeopleListWrapper> getSitesMembersEveryone(Criteria.People peopleCriteriaObjArg, List<String> userIds) {
		logger.logDebug('PeopleContentProvider.getSitesMembersEveryone ----- peopleCriteriaObjArg '+peopleCriteriaObjArg);
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1; 
		SiteDao siteDaoObj = new SiteDao(); 
		PeopleDao peopleDaoObj = new PeopleDao();
		
		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.siteId);
		
		Set<Id> siteMembersPeopleIdSet = new Set<Id>();
		for(SiteDao.PeopleIdAndSiteRole peopleIdAndSiteRoleObj : mapOfMemberIdAndRoleOfSite.values()) {
			siteMembersPeopleIdSet.add(peopleIdAndSiteRoleObj.id);
		}
		/**
			Fetch all mandatory subscriptions for this site
			Check whether these users belongs to anyone of these subscriptions
			Make decision whether an user can be removed or not.
		**/
		String segmentId = UserContext.segmentId;
		String siteId = peopleCriteriaObjArg.siteId;

		List<Subscription_Entity__c> siteSubscriptionEntityList = peopleDaoObj.getSubscriptionEntity(siteId);

		Set<String> audienceIdSet = new Set<String>();
		for(Subscription_Entity__c susbcriptionEntity : siteSubscriptionEntityList){
			if(String.isNotBlank(susbcriptionEntity.Subscription__c)){
				audienceIdSet.add(susbcriptionEntity.Subscription__r.Audience__c);
			}
		}
		
		Set<String> mandatorySiteSubscriptionPeopleIdSet = null;
		if(!audienceIdSet.isEmpty()){
			mandatorySiteSubscriptionPeopleIdSet = new Set<String>();
			List<Audience_Member__c> audienceMemberList = peopleDaoObj.getAudienceMembers(siteMembersPeopleIdSet, audienceIdSet);											 
			for(Audience_Member__c audienceMember : audienceMemberList){
				mandatorySiteSubscriptionPeopleIdSet.add(audienceMember.People__c);
			}												 
		}
		
		List<People__c> listOfPeople = peopleDaoObj.getSitesMembersEveryone(peopleCriteriaObjArg.term, peopleCriteriaObjArg.offset ,
				recordLimit, peopleCriteriaObjArg.sortBy, mapOfMemberIdAndRoleOfSite.keySet());
		
		if (!listOfPeople.isEmpty()) {
			ConvertorArgumentsWrapper convertorArgumentsObj = new ConvertorArgumentsWrapper();
			convertorArgumentsObj.convertFor = 'getSitesMembersEveryone';
			convertorArgumentsObj.mapOfMemberIdAndRoleOfSite = mapOfMemberIdAndRoleOfSite;
			convertorArgumentsObj.mandatorySiteSubscriptionPeopleIdSet = mandatorySiteSubscriptionPeopleIdSet;
			convertorArgumentsObj.collabGroupObj = null;
			convertorArgumentsObj.siteObj = null;
			for (People__c peopleObj : listOfPeople) {
				convertorArgumentsObj.peopleObj = peopleObj;
				if(userIds == null || userIds.isEmpty()) {
					listOfPeopleWrapper.add(convertToPeopleListWrapper(convertorArgumentsObj));
				}
				else {
					Set<String> userIdSet = new Set<String>();
					userIdSet.addAll(userIds);
					if(userIdSet.contains(peopleObj.User__c)) {
						listOfPeopleWrapper.add(convertToPeopleListWrapper(convertorArgumentsObj));
					}
				}
			}
		}
		logger.logDebug('PeopleContentProvider.getSitesMembersEveryone ----- listOfPeopleWrapper '+listOfPeopleWrapper);
		return listOfPeopleWrapper;
	}

	/**
     * @description Use when all the records of People required by API as offset supports upto 2000 records only. this is implemented for Newsletter+ unless required for other features.
     * @return List<PeopleListWrapper> - fetched people list
	 * @param peopleCriteriaObjArg - wrapper containing all conditions and filters for people
	 * @param userIds - id's of users to restrict
     */
	public static List<PeopleListWrapper> getAllSitesMembersFollowers(Criteria.People peopleCriteriaObjArg, List<String> userIds) {
		logger.logDebug('PeopleContentProvider.getAllSitesMembersFollowers ----- peopleCriteriaObjArg '+peopleCriteriaObjArg);
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer recordLimit = peopleCriteriaObjArg.size != null ? peopleCriteriaObjArg.size + 1 : SimpplrContext.simpplrDefaultPageSize + 1; 
		SiteDao siteDaoObj = new SiteDao(); 
		PeopleDao peopleDaoObj = new PeopleDao();
		
		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.siteId);
		
		Set<Id> siteMembersPeopleIdSet = new Set<Id>();
		for(SiteDao.PeopleIdAndSiteRole peopleIdAndSiteRoleObj : mapOfMemberIdAndRoleOfSite.values()) {
			siteMembersPeopleIdSet.add(peopleIdAndSiteRoleObj.id);
		}
		/**
			Fetch all mandatory subscriptions for this site
			Check whether these users belongs to anyone of these subscriptions
			Make decision whether an user can be removed or not.
		**/
		String segmentId = UserContext.segmentId;
		String siteId = peopleCriteriaObjArg.siteId;

		Set<String> audienceIdSet = processSubscriptionEntities(siteId, peopleDaoObj);
		
		Set<String> mandatorySiteSubscriptionPeopleIdSet = null;
		mandatorySiteSubscriptionPeopleIdSet = processAudienceMembers(audienceIdSet, peopleDaoObj, siteMembersPeopleIdSet);
		String nextPageToken = null;
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)){
			nextPageToken = peopleCriteriaObjArg.nextPageToken;
		}
		List<People__c> listOfPeople = peopleDaoObj.getAllSitesMembersFollowers(nextPageToken ,recordLimit, mapOfMemberIdAndRoleOfSite.keySet());
		
		if (!listOfPeople.isEmpty()) {
			ConvertorArgumentsWrapper convertorArgumentsObj = new ConvertorArgumentsWrapper();
			convertorArgumentsObj.convertFor = 'getAllSitesMembersFollowers';
			convertorArgumentsObj.mapOfMemberIdAndRoleOfSite = mapOfMemberIdAndRoleOfSite;
			convertorArgumentsObj.mandatorySiteSubscriptionPeopleIdSet = mandatorySiteSubscriptionPeopleIdSet;
			convertorArgumentsObj.collabGroupObj = null;
			convertorArgumentsObj.siteObj = null;
			
			for (People__c peopleObj : listOfPeople) {
				convertorArgumentsObj.peopleObj = peopleObj;
				if(userIds == null || userIds.isEmpty()) {
					listOfPeopleWrapper.add(convertToPeopleListWrapper(convertorArgumentsObj));
				}
				else {
					Set<String> userIdSet = new Set<String>();
					userIdSet.addAll(userIds);
					if(userIdSet.contains(peopleObj.User__c)) {
						listOfPeopleWrapper.add(convertToPeopleListWrapper(convertorArgumentsObj));
					}
				}
			}
		}
		logger.logDebug('PeopleContentProvider.getAllSitesMembersFollowers ----- listOfPeopleWrapper '+listOfPeopleWrapper);
		return listOfPeopleWrapper;
	}

	public static List<PeopleListWrapper> removeInactiveUsersFromList(List<PeopleListWrapper> listOfPeopleWrapper) {
		List<PeopleListWrapper> wrapperListOfActivePeople = new List<PeopleListWrapper>();
		List<Id> allPeopleIds = new List<Id>();
		for(PeopleListWrapper pLWObj : listOfPeopleWrapper) {
			allPeopleIds.add(pLWObj.peopleId);
		}
		List<People__c> peopleList = [SELECT Id FROM People__c WHERE Id =:allPeopleIds AND User__r.IsActive = false WITH SECURITY_ENFORCED];
		List<Id> inactivePeopleIds = new List<Id>();
		for(People__c peopleObj : peopleList) {
			inactivePeopleIds.add(peopleObj.id);
		}
		for(PeopleListWrapper pLWObj : listOfPeopleWrapper) {
			if( !inactivePeopleIds.contains(pLWObj.peopleId) ){
				wrapperListOfActivePeople.add(pLWObj);
			}
		}
		return wrapperListOfActivePeople;
	}

	public static List<PeopleListWrapper> getSiteMembers(Criteria.People peopleCriteriaObjArg) {
		logger.logDebug('PeopleContentProvider.getSiteMembers ----- peopleCriteriaObjArg '+peopleCriteriaObjArg);

		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer nextpageToken = 0; 
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;  
		SiteDao siteDaoObj = new SiteDao(); 
		PeopleDao peopleDaoObj = new PeopleDao();

		Boolean isCurrentUserSiteOwner = false;

		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.siteId);

		Set<Id> siteMembersPeopleIdSet = new Set<Id>();
		for(SiteDao.PeopleIdAndSiteRole peopleIdAndSiteRoleObj : mapOfMemberIdAndRoleOfSite.values()) {
			siteMembersPeopleIdSet.add(peopleIdAndSiteRoleObj.id);
		}
		/**
			Fetch all mandatory subscriptions for this site
			Check whether these users belongs to anyone of these subscriptions
			Make decision whether an user can be removed or not.
		**/
		String segmentId = UserContext.segmentId;
		String siteId = peopleCriteriaObjArg.siteId;
		
		Set<String> audienceIdSet = processSubscriptionEntities(siteId, peopleDaoObj);
		
		Set<String> mandatorySiteSubscriptionPeopleIdSet = null;
		mandatorySiteSubscriptionPeopleIdSet = processAudienceMembers(audienceIdSet, peopleDaoObj, siteMembersPeopleIdSet);

		List<People__c> listOfPeople = peopleDaoObj.getSiteMembers(peopleCriteriaObjArg.siteId, peopleCriteriaObjArg.offset ,
				recordLimit);

		Simpplr_Site__c siteObj = peopleDaoObj.getSite(peopleCriteriaObjArg.siteId);

		CollaborationGroup collabGroupObj = peopleDaoObj.getCollaborationGroup(siteObj.chatter_Group_id__c);
		
		if (!listOfPeople.isEmpty()) {
            ConvertorArgumentsWrapper convertorArgumentsObj = new ConvertorArgumentsWrapper();
			convertorArgumentsObj.convertFor = 'getSiteMembers';
			convertorArgumentsObj.mapOfMemberIdAndRoleOfSite = mapOfMemberIdAndRoleOfSite;
			convertorArgumentsObj.mandatorySiteSubscriptionPeopleIdSet = mandatorySiteSubscriptionPeopleIdSet;
			convertorArgumentsObj.collabGroupObj = collabGroupObj;
			convertorArgumentsObj.siteObj = siteObj;
            Map<String, People_Integration__c> pplIntegrationMap = new Map<String, People_Integration__c>();
            if(SimpplrContext.isSharepointConnected && siteObj != null && ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(siteObj.File_Storage_Source__c)) {
                pplIntegrationMap = getSharepointPeopleIntegrations(listOfPeople);
            }
			
			for (People__c peopleObj : listOfPeople) {
				convertorArgumentsObj.peopleObj = peopleObj;
                convertorArgumentsObj.pplIntegration = pplIntegrationMap.get(peopleObj.Id);
				listOfPeopleWrapper.add(convertToPeopleListWrapper(convertorArgumentsObj));
			}
		}
		
		return listOfPeopleWrapper;
	}

	/**
     * @description Use when all the records of People required by API as offset supports upto 2000 records only. this is implemented for Newsletter+ unless required for other features.
     * @return List<PeopleListWrapper> - fetched people list
	 * @param peopleCriteriaObjArg - wrapper containing all conditions and filters for people
     */
	public static List<PeopleListWrapper> getAllSiteMembers(Criteria.People peopleCriteriaObjArg) {
		logger.logDebug('PeopleContentProvider.getAllSiteMembers ----- peopleCriteriaObjArg '+peopleCriteriaObjArg);

		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		String nextpageToken = null; 
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)){
			nextpageToken = peopleCriteriaObjArg.nextPageToken;
		}
		Integer recordLimit = peopleCriteriaObjArg.size != null ? peopleCriteriaObjArg.size + 1 : SimpplrContext.simpplrDefaultPageSize + 1;  
		SiteDao siteDaoObj = new SiteDao(); 
		PeopleDao peopleDaoObj = new PeopleDao();

		Boolean isCurrentUserSiteOwner = false;

		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.siteId);

		Set<Id> siteMembersPeopleIdSet = new Set<Id>();
		for(SiteDao.PeopleIdAndSiteRole peopleIdAndSiteRoleObj : mapOfMemberIdAndRoleOfSite.values()) {
			siteMembersPeopleIdSet.add(peopleIdAndSiteRoleObj.id);
		}
		/**
			Fetch all mandatory subscriptions for this site
			Check whether these users belongs to anyone of these subscriptions
			Make decision whether an user can be removed or not.
		**/
		String segmentId = UserContext.segmentId;
		String siteId = peopleCriteriaObjArg.siteId;
						
		Set<String> audienceIdSet = processSubscriptionEntities(siteId, peopleDaoObj);
		
		Set<String> mandatorySiteSubscriptionPeopleIdSet = null;
		mandatorySiteSubscriptionPeopleIdSet = processAudienceMembers(audienceIdSet, peopleDaoObj, siteMembersPeopleIdSet);

		List<People__c> listOfPeople = peopleDaoObj.getAllSiteMembers(peopleCriteriaObjArg.siteId, nextpageToken ,recordLimit);

		Simpplr_Site__c siteObj = peopleDaoObj.getSite(peopleCriteriaObjArg.siteId);

		CollaborationGroup collabGroupObj = peopleDaoObj.getCollaborationGroup(siteObj.chatter_Group_id__c);
		
		if (!listOfPeople.isEmpty()) {
			ConvertorArgumentsWrapper convertorArgumentsObj = new ConvertorArgumentsWrapper();
			convertorArgumentsObj.convertFor = 'getAllSiteMembers';
			convertorArgumentsObj.mapOfMemberIdAndRoleOfSite = mapOfMemberIdAndRoleOfSite;
			convertorArgumentsObj.mandatorySiteSubscriptionPeopleIdSet = mandatorySiteSubscriptionPeopleIdSet;
			convertorArgumentsObj.collabGroupObj = collabGroupObj;
			convertorArgumentsObj.siteObj = siteObj;
			
			for (People__c peopleObj : listOfPeople) {
				convertorArgumentsObj.peopleObj = peopleObj;
				listOfPeopleWrapper.add(convertToPeopleListWrapper(convertorArgumentsObj));
			}
		}
		
		return listOfPeopleWrapper;
	}

	/**
     * @description Use when all the records of People required by API as offset supports upto 2000 records only. this is implemented for Newsletter+ unless required for other features.
     * @return Set<String>
	 * @param siteId - site id
	 * @param peopleDaoObj - people dao object
     */
	private static Set<String> processSubscriptionEntities(String siteId, PeopleDao peopleDaoObj){
		List<Subscription_Entity__c> siteSubscriptionEntityList = peopleDaoObj.getSubscriptionEntity(siteId);
		Set<String> audienceIdSet = new Set<String>();
		for(Subscription_Entity__c susbcriptionEntity : siteSubscriptionEntityList){
			if(String.isNotBlank(susbcriptionEntity.Subscription__c)){
				audienceIdSet.add(susbcriptionEntity.Subscription__r.Audience__c);
			}
		}
		return audienceIdSet;
	}

	/**
     * @description Use when all the records of People required by API as offset supports upto 2000 records only. this is implemented for Newsletter+ unless required for other features.
     * @return Set<String>
	 * @param audienceIdSet - audience id set
	 * @param peopleDaoObj - people dao object
	 * @param siteMembersPeopleIdSet - site member people id set
     */
	private static Set<String> processAudienceMembers(Set<String> audienceIdSet, PeopleDao peopleDaoObj, Set<Id> siteMembersPeopleIdSet){
		Set<String> mandatorySiteSubscriptionPeopleIdSet = new Set<String>();
		if(!audienceIdSet.isEmpty()){
			List<Audience_Member__c> audienceMemberList = peopleDaoObj.getAudienceMembers(siteMembersPeopleIdSet, audienceIdSet);							 											 
			for(Audience_Member__c audienceMember : audienceMemberList){
				mandatorySiteSubscriptionPeopleIdSet.add(audienceMember.People__c);
			}												 
		}
		return mandatorySiteSubscriptionPeopleIdSet;
	}

	public static List<PeopleListWrapper> getSiteFollowers(Criteria.People peopleCriteriaObjArg) {
		logger.logDebug('PeopleContentProvider.getSiteFollowers ----- peopleCriteriaObjArg '+peopleCriteriaObjArg);

		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer nextpageToken = 0; 
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;  
		SiteDao siteDaoObj = new SiteDao(); 
		PeopleDao peopleDaoObj = new PeopleDao();

		Boolean isCurrentUserSiteOwner = false;

		Simpplr_Site__c siteObj = [Select Id, Site_Type__c, File_Storage_Source__c, chatter_Group_id__c From Simpplr_Site__c Where Id = :peopleCriteriaObjArg.siteId];
		CollaborationGroup collabGroupObj = [SELECT Id, CollaborationType, OwnerId, Owner.name FROM CollaborationGroup Where Id= : siteObj.chatter_Group_id__c];

		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.siteId);

		List<People__c> listOfPeople = peopleDaoObj.getSiteFollowers(peopleCriteriaObjArg.siteId, peopleCriteriaObjArg.offset ,
				recordLimit);
		
		if (!listOfPeople.isEmpty()) {
			Map<String, People_Integration__c> pplIntegrationMap = new Map<String, People_Integration__c>();
            if(SimpplrContext.isSharepointConnected && siteObj != null && ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(siteObj.File_Storage_Source__c)) {
                pplIntegrationMap = getSharepointPeopleIntegrations(listOfPeople);
            }

			for (People__c peopleObj : listOfPeople) {
				PeopleListWrapper peopleWrapObj = new PeopleListWrapper();
				peopleWrapObj = PeopleListWrapper.peopleToWrapper(peopleObj);
				String siteRole = mapOfMemberIdAndRoleOfSite.get(peopleObj.user__c)?.role;
				
				peopleWrapObj.canRemove = true;
				peopleWrapObj.canMakeOwner = true; 
				peopleWrapObj.canMakeManager = true;
				peopleWrapObj.canMakeNotManager = false;
				peopleWrapObj.isOwner = false;
				peopleWrapObj.isManager = false;
				peopleWrapObj.isContentManager = false;
				peopleWrapObj.canMakeContentManager = true;
				peopleWrapObj.canMakeNotContentManager = false;
				peopleWrapObj.isMember = false;
				peopleWrapObj.isFollower = true;
				peopleWrapObj.isAppManager = UserContext.isUserAppModerator;
				peopleWrapObj.canSPTransferOwnership = pplIntegrationMap.get(peopleObj.Id) == null ? null : pplIntegrationMap.get(peopleObj.Id)?.SP_Instance_Id__c == UserContext.spInstanceId ? true : false;

				if(SimpplrContext.isSharepointConnected && pplIntegrationMap.get(peopleObj.Id) != null) {
					peopleWrapObj.hasConnectedSharePointAccount = pplIntegrationMap.get(peopleObj.Id).connected__c;
				}

				if(UserInfo.getUserId().equalsIgnoreCase(collabGroupObj.OwnerId)){
					isCurrentUserSiteOwner = true;
				}

				if(((UserContext.hasModifyAllDataPermission && !'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c) 
						|| ('Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c) && UserContext.hasManageUnlistedSitePermission)
						|| isCurrentUserSiteOwner || (UserContext.isUserAppModerator && 'Public'.equalsIgnoreCase(siteObj.Site_Type__c))) && 'Owner'.equalsIgnoreCase(siteRole) == false)){
					peopleWrapObj.canMakeOwner = true;
				} else {
					peopleWrapObj.canMakeOwner = false;
				}
				
				listOfPeopleWrapper.add(peopleWrapObj);
			}
		}
		
		return listOfPeopleWrapper;
	}

    public static Map<String, People_Integration__c> getSharepointPeopleIntegrations(List<People__c> listOfPeople) {
        Map<String, People_Integration__c> pplIntegrationMap = new Map<String, People_Integration__c>();
        List<String> listOfPeopleIds = new List<String>();
        for(People__c ppl:listOfPeople) {
            listOfPeopleIds.add(ppl.Id);
        }
        Map<String, Object> paramMap = new Map<String, Object>{
            'soqlParam1' => listOfPeopleIds,
            'soqlParam2' => ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING
        };
        String pplQuery = 'SELECT Id, Name, People__c, SP_Instance_Id__c, Connected__c FROM People_Integration__c WHERE People__c IN :soqlParam1 AND Name = :soqlParam2 AND Is_Deleted__c=false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People_Integration__c> listOfPplIntegrations = ((List<People_Integration__c>) SIMPESAPI.accessController().queryAsUser(pplQuery, paramMap));
        for(People_Integration__c peoplInt:listOfPplIntegrations) {
            pplIntegrationMap.put(peoplInt.People__c, peoplInt);
        }
        return pplIntegrationMap;
    }

	public static List<PeopleListWrapper> getListOfRequest(Criteria.People peopleCriteriaObjArg) {
		logger.logDebug('PeopleContentProvider.getListOfRequest ----- peopleCriteriaObjArg '+peopleCriteriaObjArg);
 
		List<PeopleListWrapper> listOfPeopleRequestWrapper = new List<PeopleListWrapper>();
		Set<String> setOfSearchTerms = new Set<String>();

		Integer nextpageToken = 0;
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;
		PeopleDao peopleDaoObj = new PeopleDao();

		Datetime sinceTime;
		sinceTime = DateTime.now().addDays(-14);

		Simpplr_Site__c simpplrSiteObj = [Select id, Chatter_Group_Id__c, Is_Deleted__c, Site_Type__c from Simpplr_Site__c where Is_Deleted__c=false and id =: peopleCriteriaObjArg.siteId WITH SECURITY_ENFORCED];

		if (simpplrSiteObj.Site_Type__c == 'Private' ){

			List<CollaborationGroupMemberRequest> collabrationRequestList = [SELECT Id, CollaborationGroupId, RequesterId, Status, LastModifiedById, CreatedDate, LastModifiedDate 
																			FROM CollaborationGroupMemberRequest 
																			WHERE CollaborationGroupId =: simpplrSiteObj.Chatter_Group_Id__c 
																			AND ((Status = 'Pending') OR (Status != 'Pending' AND CreatedDate>:sinceTime))
																			WITH SECURITY_ENFORCED
																			ORDER BY Status, createddate desc];
			Set<Id> actionByUserIdSet = new Set<Id>();
			Set<Id> userIdSet = new Set<Id>();
			for(CollaborationGroupMemberRequest collabGroupMemReqObj : collabrationRequestList) {
				actionByUserIdSet.add(collabGroupMemReqObj.LastModifiedById);
				userIdSet.add(collabGroupMemReqObj.RequesterId);
			}

			Map<Id,People__c> mapOfUserIdAndPeople = new Map<Id,People__c>();
			String loggedInPeopleId = UserContext.peopleId;
			
			List<People__c>  actionByPeopleList = Database.query(peopleDaoObj.BASE_QUERY + ' WHERE User__c = :actionByUserIdSet');
			
			for(People__c peopleObj : actionByPeopleList) {
				mapOfUserIdAndPeople.put(peopleObj.User__c, peopleObj);
			}
			
			List<People__c> peopleList = peopleDaoObj.getSitesMembersEveryone(peopleCriteriaObjArg.term, peopleCriteriaObjArg.offset ,recordLimit, peopleCriteriaObjArg.sortBy, userIdSet);

			for(People__c peopleObj : peopleList) {
				mapOfUserIdAndPeople.put(peopleObj.User__c, peopleObj);
			}
			
			for(CollaborationGroupMemberRequest collabGroupMemReqObj : collabrationRequestList) {
				PeopleListWrapper peopleRequestObj = new PeopleListWrapper();
				People__c peopleObj = new People__c();
				peopleObj = mapOfUserIdAndPeople.get(collabGroupMemReqObj.RequesterId);

				if(peopleObj != null) {
					peopleRequestObj.user = PeopleListWrapper.peopleToWrapper(peopleObj);

					PeopleListWrapper.Request requestObj = new PeopleListWrapper.Request();
					requestObj.id = collabGroupMemReqObj.Id;
					requestObj.requestedBy = peopleObj.First_Name__c + peopleObj.Last_Name__c;
					requestObj.requestedByPeopleId = peopleObj.Id;
					requestObj.requestedOn = Utility.dateToDisplayString(collabGroupMemReqObj.CreatedDate,'yyyy-MM-dd');

					if(collabGroupMemReqObj.status == 'Accepted') {
						requestObj.status = 'approved';
					} else if(collabGroupMemReqObj.status == 'declined') {
						requestObj.status = 'rejected';
					} else {
						requestObj.status = collabGroupMemReqObj.status.toLowerCase();
					}

					if(collabGroupMemReqObj.status != 'Pending') {
						People__c actionByPeopleObj = new People__c();
						actionByPeopleObj = mapOfUserIdAndPeople.get(collabGroupMemReqObj.LastModifiedById);
						requestObj.actionOn = Utility.dateToDisplayString(collabGroupMemReqObj.LastModifiedDate,'yyyy-MM-dd');
						if(actionByPeopleObj != null) {
							requestObj.actionBy = actionByPeopleObj.Full_Name__c;
							requestObj.actionByPeopleId = actionByPeopleObj.Id;
						}
					}

					peopleRequestObj.request = requestObj;

					listOfPeopleRequestWrapper.add(peopleRequestObj);
				}

			}
		} else {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', peopleCriteriaObjArg.siteId);
			soqlParamMap.put('soqlParam2', sinceTime);
			String query = 'SELECT Id, Request_By__c, Request_By__r.Full_Name__c, User__c, Request_DateTime__c, Action_By__c, Action_By__r.Full_Name__c, Action_DateTime__c, Status__c ' +
				' FROM Site_Membership_Request__c ' +
				' WHERE Site__c = :soqlParam1 ' +
				' AND Is_Deleted__c = false AND ((Status__c = \'Pending\') OR (Status__c != \'Pending\' ' +
				' AND Request_DateTime__c>:soqlParam2))' +
				' ORDER BY Status__c, createddate desc';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Site_Membership_Request__c> membershipReqstList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

			Set<Id> userIdSet = new Set<Id>();
			for(Site_Membership_Request__c membershipReqstObj : membershipReqstList) {
				userIdSet.add(membershipReqstObj.User__c);
			}

			List<People__c> peopleList = peopleDaoObj.getSitesMembersEveryone(peopleCriteriaObjArg.term, peopleCriteriaObjArg.offset ,recordLimit, peopleCriteriaObjArg.sortBy, userIdSet);
			SiteDao siteDaoObj = new SiteDao(); 
			Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.siteId);

			Map<Id,People__c> mapOfUserIdAndPeople = new Map<Id,People__c>(); 
			
			for(People__c peopleObj : peopleList) {
				mapOfUserIdAndPeople.put(peopleObj.User__c, peopleObj);
			}

			for(Site_Membership_Request__c membershipReqstObj : membershipReqstList) {
				PeopleListWrapper peopleRequestObj = new PeopleListWrapper();

				People__c peopleObj = new People__c();
				peopleObj = mapOfUserIdAndPeople.get(membershipReqstObj.User__c);

				if(peopleObj != null) {
					peopleRequestObj.user = PeopleListWrapper.peopleToWrapper(peopleObj);
					String siteRole = mapOfMemberIdAndRoleOfSite.get(peopleObj.user__c) != null ?mapOfMemberIdAndRoleOfSite.get(peopleObj.user__c).role:'';
					if(String.isNotBlanK(siteRole) && 'Follower'.equalsIgnoreCase(siteRole)) {
						peopleRequestObj.user.isFollower = true;
					}else {
						peopleRequestObj.user.isFollower = false;
					}					
					PeopleListWrapper.Request requestObj = new PeopleListWrapper.Request();
					requestObj.id = membershipReqstObj.Id;
					requestObj.requestedBy = membershipReqstObj.Request_By__r.Full_Name__c;
					requestObj.requestedByPeopleId = membershipReqstObj.Request_By__c;
					requestObj.requestedOn = Utility.dateToDisplayString(membershipReqstObj.Request_DateTime__c,'yyyy-MM-dd');
					requestObj.status = String.isNotBlank(membershipReqstObj.Status__c) ? (membershipReqstObj.Status__c).toLowerCase():null;
					if(membershipReqstObj.Action_DateTime__c != null) {
						requestObj.actionOn = Utility.dateToDisplayString(membershipReqstObj.Action_DateTime__c,'yyyy-MM-dd');
					}
					requestObj.actionBy = membershipReqstObj.Action_By__r.Full_Name__c;
					requestObj.actionByPeopleId = membershipReqstObj.Action_By__c;

					peopleRequestObj.request = requestObj;

					listOfPeopleRequestWrapper.add(peopleRequestObj);
				}
			
			}
		}

		return listOfPeopleRequestWrapper;
	}


	public static List<PeopleListWrapper> getEveryone(Criteria.People peopleCriteriaObjArg, List<String> userIds) {
		logger.logDebug('PeopleContentProvider.getEveryone ----- peopleCriteriaObjArg '+peopleCriteriaObjArg);
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1; 
		SiteDao siteDaoObj = new SiteDao(); 
		PeopleDao peopleDaoObj = new PeopleDao();
		
		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.includeMemberTypeForSite);

		List<Id> listOfExpertisePeopleId;

		if (peopleCriteriaObjArg.expertiseId != null) {
			listOfExpertisePeopleId = new List<Id>();
			listOfExpertisePeopleId.addAll(getExperts(peopleCriteriaObjArg.expertiseId));
		}

		List<String> peopleIdsToFilterFrom = null;
		List<People__c> listOfPeople = peopleDaoObj.getAllPeople(peopleCriteriaObjArg.sortBy, 
		peopleCriteriaObjArg.size, 0, peopleCriteriaObjArg.term, peopleCriteriaObjArg.department, 
		peopleCriteriaObjArg.location, peopleCriteriaObjArg.userCategory, 
		listOfExpertisePeopleId, peopleIdsToFilterFrom, peopleCriteriaObjArg.limitToSubsegment, 
		peopleCriteriaObjArg);
		
		if (!listOfPeople.isEmpty()) {
			for (People__c peopleObj : listOfPeople) {
		
				PeopleListWrapper peopleWrapObj = new PeopleListWrapper();
				peopleWrapObj = PeopleListWrapper.peopleToWrapper(peopleObj);

				peopleWrapObj.canRemove = true;
				peopleWrapObj.canMakeOwner = true; 
				peopleWrapObj.canMakeManager = true;
				peopleWrapObj.canMakeContentManager = true;
				peopleWrapObj.canMakeNotManager = false;
				peopleWrapObj.canMakeNotContentManager = false;
				peopleWrapObj.isOwner = false;
				peopleWrapObj.isManager = false;
				peopleWrapObj.isContentManager = false;
				peopleWrapObj.isMember = false;
				peopleWrapObj.isFollower = false;

				if(mapOfMemberIdAndRoleOfSite.containsKey(peopleObj.user__c)) {
					String siteRole = mapOfMemberIdAndRoleOfSite.get(peopleObj.user__c).role;

					if('Owner'.equalsIgnoreCase(siteRole)) {
						peopleWrapObj.isOwner = true;
						peopleWrapObj.canRemove = false;
						peopleWrapObj.canMakeManager = false;
						peopleWrapObj.canMakeContentManager = false;
						peopleWrapObj.canMakeNotManager = false;
						peopleWrapObj.canMakeNotContentManager = false;
						peopleWrapObj.isMember = true;
					} else if('Manager'.equalsIgnoreCase(siteRole)) {
						peopleWrapObj.isManager = true;
						peopleWrapObj.canRemove = false;
						peopleWrapObj.canMakeManager = false;
						peopleWrapObj.canMakeContentManager = true;
						peopleWrapObj.canMakeNotManager = true;
						peopleWrapObj.canMakeNotContentManager = false;
						peopleWrapObj.isMember = true;
					} else if('ContentManager'.equalsIgnoreCase(siteRole)) {
						peopleWrapObj.isContentManager = true;
						peopleWrapObj.canRemove = false;
						peopleWrapObj.canMakeManager = true;
						peopleWrapObj.canMakeContentManager = false;
						peopleWrapObj.canMakeNotManager = false;
						peopleWrapObj.canMakeNotContentManager = true;
						peopleWrapObj.isMember = true;
					} else if('Member'.equalsIgnoreCase(siteRole)) {
						peopleWrapObj.isMember = true;
					} else if('Follower'.equalsIgnoreCase(siteRole)) {
						peopleWrapObj.isFollower = true;
					}

				} 
				
				if(( (UserContext.hasModifyAllDataPermission && !'Unlisted'.equalsIgnoreCase(SiteContext.currentSiteType) 
							|| ('Unlisted'.equalsIgnoreCase(SiteContext.currentSiteType) && UserContext.hasManageUnlistedSitePermission)
							|| (mapOfMemberIdAndRoleOfSite.get(UserContext.id) != null && 'Owner'.equalsIgnoreCase(mapOfMemberIdAndRoleOfSite.get(UserContext.id).role))) 
						&& peopleWrapObj.isOwner == false)){
					peopleWrapObj.canMakeOwner = true;
				} else {
					peopleWrapObj.canMakeOwner = false;
				}
				
				if(userIds == null || userIds.isEmpty()) {
					listOfPeopleWrapper.add(peopleWrapObj);
				}
				else {
					Set<String> userIdSet = new Set<String>();
					userIdSet.addAll(userIds);
					if(userIdSet.contains(peopleObj.User__c)) {
						listOfPeopleWrapper.add(peopleWrapObj);
					}
				}
			}
		}
		logger.logDebug('PeopleContentProvider.getEveryone ----- listOfPeopleWrapper '+listOfPeopleWrapper);
		return listOfPeopleWrapper;
	} 

	//TBD
	public static List<PeopleListWrapper> getSiteManagers (Criteria.People peopleCriteriaObjArg) {
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer nextpageToken = 0; 
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1;  
		SiteDao siteDaoObj = new SiteDao(); 
		PeopleDao peopleDaoObj = new PeopleDao();

		Boolean isCurrentUserSiteOwner = false;
		
		Map<Id, String> mapOfManagerIdAndRoleOfSite = new Map<Id, String>();
		Boolean canRemoveMembers = false;
		Simpplr_Site__c siteObj = siteDaoObj.getSites(new Set<String>{peopleCriteriaObjArg.siteId}).get(peopleCriteriaObjArg.siteId);
		CollaborationGroup collabGroupObj = [SELECT Id, CollaborationType, OwnerId, Owner.name FROM CollaborationGroup Where Id= : siteObj.chatter_Group_id__c WITH SECURITY_ENFORCED];
		if(siteObj != null) {
			mapOfManagerIdAndRoleOfSite = siteDaoObj.getMapOfManagerIdAndRoleOfSite(siteObj.Chatter_Group_id__c, siteObj.Id);
		}

		List<People__c> listOfPeople = peopleDaoObj.getSiteManagers(peopleCriteriaObjArg.term, peopleCriteriaObjArg.offset ,
				recordLimit, mapOfManagerIdAndRoleOfSite.keySet());
		
		if (!listOfPeople.isEmpty()) {
            Map<String, People_Integration__c> pplIntegrationMap = new Map<String, People_Integration__c>();
            if(SimpplrContext.isSharepointConnected && siteObj != null && ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(siteObj.File_Storage_Source__c)) {
                pplIntegrationMap = getSharepointPeopleIntegrations(listOfPeople);
            }

			for (People__c peopleObj : listOfPeople) {
				PeopleListWrapper peopleWrapObj = new PeopleListWrapper();
				peopleWrapObj = PeopleListWrapper.peopleToWrapper(peopleObj);
				String siteRole = mapOfManagerIdAndRoleOfSite.get(peopleObj.user__c);
				
				peopleWrapObj.canRemove = canRemoveMembers;
				peopleWrapObj.canMakeOwner = true; 
				peopleWrapObj.canMakeManager = true;
				peopleWrapObj.canMakeNotManager = false;
				peopleWrapObj.isOwner = false;
				peopleWrapObj.isManager = false;
				peopleWrapObj.isContentManager = false;
				peopleWrapObj.canMakeContentManager = true;
				peopleWrapObj.canMakeNotContentManager = false;
				peopleWrapObj.isMember = true;
				peopleWrapObj.isFollower = false;
				peopleWrapObj.isAppManager = UserContext.isUserAppModerator;
				if('Owner'.equalsIgnoreCase(siteRole)) {
					peopleWrapObj.isOwner = true;
					peopleWrapObj.isManager = false;
					peopleWrapObj.canRemove = false;
					peopleWrapObj.canMakeOwner = false; 
					peopleWrapObj.canMakeManager = false;
					peopleWrapObj.canMakeContentManager = false;
					peopleWrapObj.canMakeNotManager = false;
				} else if('Manager'.equalsIgnoreCase(siteRole)) {
					peopleWrapObj.isManager = true;
					peopleWrapObj.isOwner = false;
					peopleWrapObj.canRemove = true;
					peopleWrapObj.canMakeOwner = true;
					peopleWrapObj.canMakeManager = false;
					peopleWrapObj.canMakeContentManager = true;
					peopleWrapObj.canMakeNotManager = true;
				}  else if('ContentManager'.equalsIgnoreCase(siteRole)) {
					peopleWrapObj.isContentManager = true;
					peopleWrapObj.canRemove = true;
					peopleWrapObj.canMakeManager = true;
					peopleWrapObj.canMakeContentManager = false;
					peopleWrapObj.canMakeNotManager = false;
					peopleWrapObj.canMakeNotContentManager = true;
				}
                peopleWrapObj.canSPTransferOwnership = pplIntegrationMap.get(peopleObj.Id) == null ? null : pplIntegrationMap.get(peopleObj.Id)?.SP_Instance_Id__c == UserContext.spInstanceId ? true : false;
				if(SimpplrContext.isSharepointConnected && pplIntegrationMap.get(peopleObj.Id) != null) {
					peopleWrapObj.hasConnectedSharePointAccount = pplIntegrationMap.get(peopleObj.Id).connected__c;
				}

				if(UserInfo.getUserId().equalsIgnoreCase(collabGroupObj.OwnerId)){
					isCurrentUserSiteOwner = true;
				}

				if(((UserContext.hasModifyAllDataPermission && !'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c) 
						|| ('Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c) && UserContext.hasManageUnlistedSitePermission)
						|| isCurrentUserSiteOwner || (UserContext.isUserAppModerator && 'Public'.equalsIgnoreCase(siteObj.Site_Type__c))) && 'Owner'.equalsIgnoreCase(siteRole) == false)){
					peopleWrapObj.canMakeOwner = true;
				} else {
					peopleWrapObj.canMakeOwner = false;
				}
				
				listOfPeopleWrapper.add(peopleWrapObj);
			}
		}
		
		return listOfPeopleWrapper;
	}

	public static List<PeopleListWrapper> getMustReadRecordHistory (Criteria.People peopleCriteriaObjArg, String chatterGroupId, String auditId, String audienceType){
		
		String filter = peopleCriteriaObjArg.filter;
    	String contentId = peopleCriteriaObjArg.contentId;
    	Integer recordLimit = peopleCriteriaObjArg.size + 1;
    	Integer offset = peopleCriteriaObjArg.offset;
    	String searchText = peopleCriteriaObjArg.term;
    	
    	PeopleDao peopleDaoObj = new PeopleDao();

		List<People__c> peopleList = peopleDaoObj.getMustReadRecordHistory(contentId,searchText, filter, chatterGroupId, auditId, audienceType, recordLimit,offset);

		// Total records by criteria
		PeopleContentProvider.totalRecords = peopleDaoObj.getMustReadRecordHistoryCount(contentId,searchText, filter, chatterGroupId, auditId, audienceType);

    	List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>(); 
    	for(People__c pplObj : peopleList){
			PeopleListWrapper peopleListWrapObj = PeopleListWrapper.peopleToWrapper(pplObj); 
			peopleListWrapObj.hasRead = pplObj.Must_Read_Confirmed_By__r.isEmpty() ? false : true;
			listOfPeopleWrapper.add(peopleListWrapObj);
		}
		return listOfPeopleWrapper;
	}
	
	public static Set<Id> getExperts(String expertiseId) {
		Set<Id> setOfExpertIds = new Set<Id>();
		
		List<People_Expertise__c> peopleExperts = [SELECT Id, People__c FROM People_Expertise__c 
													WHERE Expertise__c = :expertiseId AND Is_Self_Hidden__c = false AND Endorser_Count__c > 0 WITH SECURITY_ENFORCED];

		for(People_Expertise__c pEObj : peopleExperts) {
			setOfExpertIds.add(pEObj.People__c);
		}
		
		return setOfExpertIds;
	}

	public static Map<Id, TopicExpertiseWrapper> getExpertsMap(String expertiseId) {
		// map of userId and TopicExpertiseWrapper Object 
		Map<Id, TopicExpertiseWrapper> mapOfExpertIdWithExpertObj = new Map<Id, TopicExpertiseWrapper>();

		List<People_Expertise__c> pEList = [SELECT Id, Endorser_Count__c,
													People__c, People__r.Full_Name__c, People__r.User__c, People__r.User__r.FullPhotoURL
											FROM People_Expertise__c 
											WHERE Expertise__c = :expertiseId WITH SECURITY_ENFORCED];

		for(People_Expertise__c pEObj : pElist) {
			TopicExpertiseWrapper wrapperObj = new TopicExpertiseWrapper();

			wrapperObj.numEndorsements = (Integer)pEObj.Endorser_Count__c;
			wrapperObj.isEndorsedByMe = null;

			wrapperObj.user.id = pEObj.People__r.User__c;
			wrapperObj.user.userId = pEObj.People__r.User__c;
			wrapperObj.user.peopleId = pEObj.People__c;
			wrapperObj.user.name = pEObj.People__r.Full_Name__c;

			wrapperObj.user.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + pEObj.People__c;
			if(String.isNotBlank(pEObj.People__r.User__r.FullPhotoURL)) {
				wrapperObj.user.img = pEObj.People__r.User__r.FullPhotoURL.endsWith('005/F') ? null : pEObj.People__r.User__r.FullPhotoURL;
			}
			
			mapOfExpertIdWithExpertObj.put(pEObj.People__r.User__c, wrapperObj);
		}

		return mapOfExpertIdWithExpertObj;
	}
	
	public static List<Id> getSelfEndorsementsForTopics(List<String> topicList) {
		List<Id> endorseeList = new List<Id>();		
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', topicList);
		String query = 'SELECT Id, Topic__c, User__c FROM Simpplr_Metadata__c '
				            + ' WHERE Type__c = \'Endorsement\' And Topic__c IN :soqlParam1';	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Simpplr_Metadata__c> simpplrMetaObjList = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		for(Simpplr_Metadata__c metaObj : simpplrMetaObjList) {
			endorseeList.add(metaObj.User__c);
		}
		
		return endorseeList;
	}
	
	public static Set<Id> getTopEndorseeUserForSearchedExpertise(String expertise_term){
		Set<Id> setOfEndorseeId = new Set<Id>();
		PeopleDao peopleDaoObj = new PeopleDao();
		List<String> listOfExpertiseIds = peopleDaoObj.getExpertises(expertise_term);
		
		for(String expertiseId : listOfExpertiseIds) {
			setOfEndorseeId.addAll(getExperts(expertiseId));
		}
		
		return setOfEndorseeId;
	}
	
	public class TopicExpertiseContinerWrapper {
		public String currentPageUrl {get;set;}
		public List<TopicExpertiseWrapper> knowledgeableUsers {get;set;}
	}
	
	public class TopicExpertiseWrapper {
		public UserWrapper user {get; set;}
		public Boolean isEndorsedByMe {get; set;}
		public Integer numEndorsements {get; set;}
		public Set<String> reasons {get; set;}
		public TopicExpertiseWrapper () {
			user = new UserWrapper();
		}
		
	}
	
	public class UserWrapper {
		public String id {get; set;}
		public String userId {get; set;}
		public String peopleId {get; set;}
		public String name {get; set;}
		public String url {get; set;}
		public String img {get; set;}
	}
	
	public static List<PeopleListWrapper> getAllFavoritesPeople (Criteria.People peopleCriteriaObjArg) {
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1; 
		PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> listOfPeople = peopleDaoObj.getFavoritesPeopleForLoggedInUser(peopleCriteriaObjArg.term, peopleCriteriaObjArg.offset ,recordLimit);
		List<PeopleListWrapper> listOfPeopleWrapper = PeopleListWrapper.peopleListToWrapper(listOfPeople);
		return listOfPeopleWrapper;
	}

	public static List<String> getAllFavoritePeopleIds (Criteria.People peopleCriteriaObjArg) {
		PeopleDao peopleDaoObj = new PeopleDao();
		List<String> favPeopleIds = peopleDaoObj.getAllFavoritePeopleIds();

		return favPeopleIds;
	}

	public static List<PeopleListWrapper> getFavPeopleFromPeopleIds (List<String> peopleIds) {
		PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> listOfPeople = peopleDaoObj.getFavPeopleFromPeopleIds(peopleIds);
		List<PeopleListWrapper> listOfPeopleWrapper = PeopleListWrapper.peopleListToWrapper(listOfPeople);
		return listOfPeopleWrapper;
	}
	
	public static List<PeopleListWrapper> getSegmentationMembers(Criteria.People peopleCriteriaObjArg){
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1; 
		PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> listOfPeople = null;
		Integer offset = null;
		Boolean limitToSubsegment = (String.isNotBlank(peopleCriteriaObjArg.limitToSubsegment) && 'true'.equalsIgnoreCase(peopleCriteriaObjArg.limitToSubsegment));
		
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)){
			offset = Integer.valueOf(peopleCriteriaObjArg.nextPageToken);
		}
		
		if(String.isNotBlank(peopleCriteriaObjArg.subscriptionId)){
			listOfPeople = peopleDaoObj.getPeopleBySubscriptionId(peopleCriteriaObjArg.subscriptionId, peopleCriteriaObjArg.term, recordLimit, offset, limitToSubsegment);
		} else if (String.isNotBlank(peopleCriteriaObjArg.segmentId)){
			listOfPeople = peopleDaoObj.getPeopleBySegmentId(peopleCriteriaObjArg.segmentId, peopleCriteriaObjArg.term, recordLimit, offset, limitToSubsegment);
		}
		
		return PeopleListWrapper.peopleListToWrapper(listOfPeople);
	}

	/**
     * @description Use when all the records of People required by API as offset supports upto 2000 records only. this is implemented for Newsletter+ unless required for other features.
     * @return List<PeopleListWrapper> - fetched people list
	 * @param peopleCriteriaObjArg - wrapper containing all conditions and filters for people
     */
	public static List<PeopleListWrapper> getAllSegmentationMembers(Criteria.People peopleCriteriaObjArg){
		Integer recordLimit = peopleCriteriaObjArg.size != null ? peopleCriteriaObjArg.size + 1: SimpplrContext.simpplrDefaultPageSize + 1; 
		PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> listOfPeople = null;
		String nextPageToken = null;
		Boolean limitToSubsegment = (String.isNotBlank(peopleCriteriaObjArg.limitToSubsegment) && 'true'.equalsIgnoreCase(peopleCriteriaObjArg.limitToSubsegment));
		
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)){
			nextPageToken = peopleCriteriaObjArg.nextPageToken;
		}
		
		if(String.isNotBlank(peopleCriteriaObjArg.subscriptionId)){
			listOfPeople = peopleDaoObj.getAllPeopleBySubscriptionId(peopleCriteriaObjArg.subscriptionId, recordLimit, nextPageToken, limitToSubsegment);
		} else if (String.isNotBlank(peopleCriteriaObjArg.segmentId)){
			listOfPeople = peopleDaoObj.getAllPeopleBySegmentId(peopleCriteriaObjArg.segmentId, recordLimit, nextPageToken, limitToSubsegment);
		}
		
		return PeopleListWrapper.peopleListToWrapper(listOfPeople);
	}

	public static List<PeopleListWrapper> getAudienceMembers(Criteria.People peopleCriteriaObjArg){
		Integer recordLimit = SimpplrContext.simpplrDefaultPageSize + 1; 
		PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> listOfPeople = null;
		Integer offset = null;
		
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)){
			offset = Integer.valueOf(peopleCriteriaObjArg.nextPageToken);
		}
		
		if(String.isNotBlank(peopleCriteriaObjArg.audienceId)){
			listOfPeople = peopleDaoObj.getPeopleByAudienceId(peopleCriteriaObjArg.audienceId, peopleCriteriaObjArg.term, recordLimit, offset);
		} 
		
		return PeopleListWrapper.peopleListToWrapper(listOfPeople);
	}

	/**
     * @description Use when all the records of People required by API as offset supports upto 2000 records only. this is implemented for Newsletter+ unless required for other features.
     * @return List<PeopleListWrapper> - fetched people list
	 * @param peopleCriteriaObjArg - wrapper containing all conditions and filters for people
     */
	public static List<PeopleListWrapper> getAllAudienceMembers(Criteria.People peopleCriteriaObjArg){
		Integer recordLimit = peopleCriteriaObjArg.size != null ? peopleCriteriaObjArg.size + 1 : SimpplrContext.simpplrDefaultPageSize + 1; 
		PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> listOfPeople = null;
		String nextPageToken = null;
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)){
			nextPageToken = peopleCriteriaObjArg.nextPageToken;
		}
		
		if(String.isNotBlank(peopleCriteriaObjArg.audienceId)){
			listOfPeople = peopleDaoObj.getAllAudienceMembers(peopleCriteriaObjArg.audienceId, recordLimit, nextPageToken);
		} 
		
		return PeopleListWrapper.peopleListToWrapper(listOfPeople);
	}
	
	public static Map<String, Object> getPeopleInMyDepartment(Criteria.People peopleCriteriaObjArg){
		Map<String, Object> resultMap = new Map<String, Object>();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;  
		PeopleDao daoObj = new PeopleDao();
		if('random'.equalsIgnoreCase(peopleCriteriaObjArg.sortBy)) {
			 List<People__c> listOfPeople = daoObj.getPeopleInMyDepartment(peopleCriteriaObjArg.sortBy, null, 0);
			 resultMap = getRandomRecordFromPeopleList(listOfPeople, recordLimit);
		} else {
			List<People__c> listOfPeople = daoObj.getPeopleInMyDepartment(peopleCriteriaObjArg.sortBy, recordLimit, peopleCriteriaObjArg.offset);
			List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
			for(People__c peopleObj : listOfPeople) {
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			resultMap.put('listOfItems',listOfPeopleWrapper);
		}
		return resultMap;
	}
	
	public static Map<String, Object> getAllPeople(Criteria.People peopleCriteriaObjArg) {
		List<String> peopleIdsToFilterFrom = null;
		return getAllPeople(peopleCriteriaObjArg, peopleIdsToFilterFrom);
	}
	
	public static Map<String, Object> getAllPeople(Criteria.People peopleCriteriaObjArg, List<String> peopleIdsToFilterFrom) {
		Map<String, Object> resultMap = new Map<String, Object>();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;  
		PeopleDao daoObj = new PeopleDao();
		SiteDao siteDaoObj = new SiteDao();
		Integer total;
		List<Id> listOfExpertisePeopleId;

		if (peopleCriteriaObjArg.expertiseId != null) {
			listOfExpertisePeopleId = new List<Id>();
			listOfExpertisePeopleId.addAll(getExperts(peopleCriteriaObjArg.expertiseId));
		}

		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.includeMemberTypeForSite);
		Integer offset = peopleCriteriaObjArg.offset;
		if (peopleCriteriaObjArg.includeTotal == true) {
			total = daoObj.getAllPeopleCount(peopleCriteriaObjArg.sortBy, peopleCriteriaObjArg.term, peopleCriteriaObjArg.department, 
				peopleCriteriaObjArg.location, peopleCriteriaObjArg.userCategory, 
				listOfExpertisePeopleId, null, peopleCriteriaObjArg.limitToSubsegment, 
				peopleCriteriaObjArg);
            offset = (peopleIdsToFilterFrom != null && peopleIdsToFilterFrom.size() > 0) ? 0 : offset;
		}
		
		List<People__c> listOfPeople = daoObj.getAllPeople(peopleCriteriaObjArg.sortBy, 
                recordLimit, offset, 
                peopleCriteriaObjArg.term, peopleCriteriaObjArg.department,
                peopleCriteriaObjArg.location, peopleCriteriaObjArg.userCategory, 
                listOfExpertisePeopleId, peopleIdsToFilterFrom, peopleCriteriaObjArg.limitToSubsegment, 
                peopleCriteriaObjArg);
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();

		ConvertorArgumentsWrapper convertorArgumentsObj = new ConvertorArgumentsWrapper();
		convertorArgumentsObj.convertFor = 'getAllPeople';
		convertorArgumentsObj.mapOfMemberIdAndRoleOfSite = mapOfMemberIdAndRoleOfSite;
		convertorArgumentsObj.mandatorySiteSubscriptionPeopleIdSet = null;
		convertorArgumentsObj.collabGroupObj = null;
		convertorArgumentsObj.siteObj = null;
			
		for (People__c peopleObj : listOfPeople) {
			convertorArgumentsObj.peopleObj = peopleObj;
			listOfPeopleWrapper.add(convertToPeopleListWrapper(convertorArgumentsObj));
		}

		resultMap.put('total',total);
		resultMap.put('listOfItems',listOfPeopleWrapper);
		return resultMap;
	}

	/**
     * @description Use when all the records of People required by API as offset supports upto 2000 records only. this is implemented for Newsletter+ unless required for other features.
     * @return Map<String, Object> - listOfItems To People list
	 * @param peopleCriteriaObjArg - wrapper containing all conditions and filters for people
	 * @param peopleIdsToFilterFrom - id's to filter
     */
	public static Map<String, Object> getAllPeopleData(Criteria.People peopleCriteriaObjArg, List<String> peopleIdsToFilterFrom) {
		Map<String, Object> resultMap = new Map<String, Object>();
		Integer recordLimit = peopleCriteriaObjArg.size != null ? peopleCriteriaObjArg.size + 1 : SimpplrContext.simpplrDefaultPageSize + 1;  
		PeopleDao daoObj = new PeopleDao();
		SiteDao siteDaoObj = new SiteDao();

		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = siteDaoObj.getMapOfMemberIdAndRoleOfSite(peopleCriteriaObjArg.includeMemberTypeForSite);
		
		List<People__c> listOfPeople = daoObj.getAllPeopleData(recordLimit, peopleIdsToFilterFrom, 
																peopleCriteriaObjArg.limitToSubsegment, peopleCriteriaObjArg);
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();

		ConvertorArgumentsWrapper convertorArgumentsObj = new ConvertorArgumentsWrapper();
		convertorArgumentsObj.convertFor = 'getAllPeopleData';
		convertorArgumentsObj.mapOfMemberIdAndRoleOfSite = mapOfMemberIdAndRoleOfSite;
		convertorArgumentsObj.mandatorySiteSubscriptionPeopleIdSet = null;
		convertorArgumentsObj.collabGroupObj = null;
		convertorArgumentsObj.siteObj = null;

		for (People__c peopleObj : listOfPeople) {
			convertorArgumentsObj.peopleObj = peopleObj;
			listOfPeopleWrapper.add(convertToPeopleListWrapper(convertorArgumentsObj));
		}

		resultMap.put('listOfItems',listOfPeopleWrapper);
		return resultMap;
	}
	
	public static Map<String, Object> getFollowingTileData(Criteria.People peopleCriteriaObjArg){
		Map<String, Object> resultMap = new Map<String, Object>();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;  
		PeopleDao daoObj = new PeopleDao();
		if('random'.equalsIgnoreCase(peopleCriteriaObjArg.sortBy)) {
			 List<People__c> listOfPeople = daoObj.getFollowingTileData(peopleCriteriaObjArg.sortBy, null, 0);
			 resultMap = getRandomRecordFromPeopleList(listOfPeople, recordLimit);
		} else {
			List<People__c> listOfPeople = daoObj.getFollowingTileData(peopleCriteriaObjArg.sortBy, recordLimit, peopleCriteriaObjArg.offset);
			List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
			for(People__c peopleObj : listOfPeople) {
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			resultMap.put('listOfItems',listOfPeopleWrapper);
		}
		return resultMap;
	}
	
	public static Map<String, Object> getFavoriteTileData(Criteria.People peopleCriteriaObjArg){
		Map<String, Object> resultMap = new Map<String, Object>();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;  
		PeopleDao daoObj = new PeopleDao();
		if('random'.equalsIgnoreCase(peopleCriteriaObjArg.sortBy)) {
			 List<People__c> listOfPeople = daoObj.getFavoriteTileData(peopleCriteriaObjArg.sortBy, null, 0);
			 resultMap = getRandomRecordFromPeopleList(listOfPeople, recordLimit);
		} else {
			List<People__c> listOfPeople = daoObj.getFavoriteTileData(peopleCriteriaObjArg.sortBy, recordLimit, peopleCriteriaObjArg.offset);
			List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
			for(People__c peopleObj : listOfPeople) {
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			resultMap.put('listOfItems',listOfPeopleWrapper);
		}
		return resultMap;
	}
	
	public static Map<String, Object> getCustomFieldTileData(Criteria.People peopleCriteriaObjArg){
		Map<String, Object> resultMap = new Map<String, Object>();
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;  
		PeopleDao daoObj = new PeopleDao();
		if('random'.equalsIgnoreCase(peopleCriteriaObjArg.sortBy)) {
			 List<People__c> listOfPeople = daoObj.getCustomFieldTileData(peopleCriteriaObjArg.sortBy, null, 0);
			 resultMap = getRandomRecordFromPeopleList(listOfPeople, recordLimit);
		} else {
			List<People__c> listOfPeople = daoObj.getCustomFieldTileData(peopleCriteriaObjArg.sortBy, recordLimit, peopleCriteriaObjArg.offset);
			for(People__c peopleObj : listOfPeople) {
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			resultMap.put('listOfItems',listOfPeopleWrapper);
		}
		return resultMap;
	}
	
	public static Map<String, Object> getMyLocationTileData(Criteria.People peopleCriteriaObjArg){
		Map<String, Object> resultMap = new Map<String, Object>();
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;  
		PeopleDao daoObj = new PeopleDao();
		if('random'.equalsIgnoreCase(peopleCriteriaObjArg.sortBy)) {
			 List<People__c> listOfPeople = daoObj.getMyLocationTileData(peopleCriteriaObjArg.sortBy, null, 0);
			 resultMap = getRandomRecordFromPeopleList(listOfPeople, recordLimit);
		} else {
			List<People__c> listOfPeople = daoObj.getMyLocationTileData(peopleCriteriaObjArg.sortBy, recordLimit, peopleCriteriaObjArg.offset);
			for(People__c peopleObj : listOfPeople) {
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			resultMap.put('listOfItems',listOfPeopleWrapper);
		}
		return resultMap;
	}
	
	public static Map<String, Object> getMyDirectReportTileData(Criteria.People peopleCriteriaObjArg){
		Map<String, Object> resultMap = new Map<String, Object>();
		PeopleDao daoObj = new PeopleDao();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;
		Integer total;
		List<PeopleListWrapper> listToBeReturned = new List<PeopleListWrapper>();
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)) {
			List<People__c> listOfPeople = daoObj.getMyDirectReportTileData(peopleCriteriaObjArg.sortBy, recordLimit, peopleCriteriaObjArg.offset);
			total = listOfPeople.size();
			for(People__c peopleObj : listOfPeople) {
				listToBeReturned.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
		} else {
			List<People__c> listOfPeople = daoObj.getMyDirectReportTileData(peopleCriteriaObjArg.sortBy, null, peopleCriteriaObjArg.offset);
			total = listOfPeople.size();
			List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
			for(People__c peopleObj : listOfPeople) {
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			
			Integer offset = peopleCriteriaObjArg.offset;
			Integer size = peopleCriteriaObjArg.size;
	    	Integer endIndex =   offset+size;
	    	endIndex = (endIndex >= total)? total - 1 :endIndex;
	    	
	    	for(Integer x = offset; x<= endIndex; x++){
	    		listToBeReturned.add(listOfPeopleWrapper.get(x));
	    	}
		}
		resultMap.put('listOfItems',listToBeReturned);
		resultMap.put('total',total);
		return resultMap;
	}
	
	public static Map<String, Object> getNewHireTileData(Criteria.People peopleCriteriaObjArg){
		Map<String, Object> resultMap = new Map<String, Object>();
		PeopleDao daoObj = new PeopleDao();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;
		Integer total;
		List<PeopleListWrapper> listToBeReturned = new List<PeopleListWrapper>();
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)) {
			List<People__c> listOfPeople = daoObj.getNewHireTileData(peopleCriteriaObjArg.sortBy, recordLimit, peopleCriteriaObjArg.offset);
			total = listOfPeople.size();
			for(People__c peopleObj : listOfPeople) {
				listToBeReturned.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
		} else {
			List<People__c> listOfPeople = daoObj.getNewHireTileData(peopleCriteriaObjArg.sortBy, null, peopleCriteriaObjArg.offset);
			total = listOfPeople.size();
			List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
			for(People__c peopleObj : listOfPeople) {
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			
			Integer offset = peopleCriteriaObjArg.offset;
			Integer size = peopleCriteriaObjArg.size;
	    	Integer endIndex =   offset+size;
	    	endIndex = (endIndex >= total)? total - 1 :endIndex;
	    	
	    	for(Integer x = offset; x<= endIndex; x++){
	    		listToBeReturned.add(listOfPeopleWrapper.get(x));
	    	}
		}
		resultMap.put('listOfItems',listToBeReturned);
		resultMap.put('total',total);
		return resultMap;
	}
	
	public static Map<String, Object> getLeadershipTileData(Criteria.People peopleCriteriaObjArg){
		Map<String, Object> resultMap = new Map<String, Object>();
		PeopleDao daoObj = new PeopleDao();
		Integer recordLimit = peopleCriteriaObjArg.size + 1;
		Integer total;
		List<PeopleListWrapper> listToBeReturned = new List<PeopleListWrapper>();
		if(String.isNotBlank(peopleCriteriaObjArg.nextPageToken)) {
			List<People__c> listOfPeople = daoObj.getLeadershipTileData(peopleCriteriaObjArg.sortBy, recordLimit, peopleCriteriaObjArg.offset);
			total = listOfPeople.size();
			for(People__c peopleObj : listOfPeople) {
				listToBeReturned.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			
		} else {
			List<People__c> listOfPeople = daoObj.getLeadershipTileData(peopleCriteriaObjArg.sortBy, null, peopleCriteriaObjArg.offset);
			total = listOfPeople.size();
			List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
			for(People__c peopleObj : listOfPeople) {
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(peopleObj));
			}
			Integer offset = peopleCriteriaObjArg.offset;
			Integer size = peopleCriteriaObjArg.size;
	    	Integer endIndex =   offset+size;
	    	endIndex = (endIndex >= total)? total - 1 :endIndex;
	    	
	    	for(Integer x = offset; x<= endIndex; x++){
	    		listToBeReturned.add(listOfPeopleWrapper.get(x));
	    	}
		}
		resultMap.put('listOfItems',listToBeReturned);
		resultMap.put('total',total);
		return resultMap;
	}
	//TBD
	public static String getDaysToCelebration(Integer celebrationDate, Integer todayDate){
		String remainingDays = null;
		if((celebrationDate-todayDate)>= -3 && (celebrationDate-todayDate)<0){
			remainingDays = String.valueOf(0);
		}
		if((celebrationDate>=todayDate) && (celebrationDate-todayDate)<31){
			remainingDays = String.valueOf(celebrationDate - todayDate);
			}
		return remainingDays;
	}
	public static Map<String, Object> getCelebrationTileData(Criteria.People peopleCriteriaObjArg){ 
		Map<String, Object> resultMap = new Map<String, Object>();
		date today = date.today();
		Integer thisyear = today.year();
		Integer todayDayofYear = today.dayofYear(); 
		if(Date.isLeapYear(thisyear) == false){
			todayDayofYear = today.dayofYear() + 1; 
		}
	
		PeopleDao daoObj = new PeopleDao();
		List<People__c> listOfPeople = daoObj.getCelebrations('all', 30, todayDayofYear);
		Integer total;
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();

		for(People__c peopleObj : listOfPeople) {
			String daysToBirthday;
			String daysToJoining;
			Boolean addObjectToWrapper = false; 

			if (peopleObj.Birth_Date__c != null) {
				daysToBirthday = getdaystocelebration(integer.valueOf(peopleobj.Day_Of_Year_B__c),todayDayofYear) + 'B';
				addObjectToWrapper = true;
			}

			if (peopleObj.Joining_Date__c != null && (peopleObj.Joining_Date__c < system.today().addDays(-31))) {
				daysToJoining = getdaystocelebration(integer.valueOf(peopleobj.Day_Of_Year_J__c),todayDayofYear) + 'A';
				addObjectToWrapper = true;
			}

			if (addObjectToWrapper) {
				PeopleListWrapper wrapperObj = PeopleListWrapper.peopleToWrapper(peopleObj);
				wrapperObj.relevancyScore = getCelbrationScore(daysToBirthday , daysToJoining);
				listOfPeopleWrapper.add(wrapperObj);
			}
			
		}

		listOfPeopleWrapper.sort();
		total= listOfPeopleWrapper.size();
		Integer size = peopleCriteriaObjArg.size;
		Integer offset = peopleCriteriaObjArg.offset;
    	Integer endIndex =   offset+size;
    	endIndex = (endIndex >= total)? total - 1 :endIndex;
    	
		List<PeopleListWrapper> listToBeReturned = new List<PeopleListWrapper>();
    	for(Integer x = offset; x<= endIndex; x++){
    		listToBeReturned.add(listOfPeopleWrapper.get(x));
    	}
		resultMap.put('listOfItems',listToBeReturned);
		resultMap.put('total',total);
		return resultMap;
	}
	
	public static Map<String, Object> getRandomRecordFromPeopleList(List<People__c> listOfPeople, Integer recordLimit){
		Map<String, Object> mapOfRandomRecords = new Map<String, Object>();
		List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>();
		Integer total = listOfPeople.size();
		
		if(total > 0){
			while(listOfPeopleWrapper.size() < recordLimit && listOfPeopleWrapper.size() < total){  
    			Integer randomNumber=math.round(math.random()*(listOfPeople.size() - 1));
				listOfPeopleWrapper.add(PeopleListWrapper.peopleToWrapper(listOfPeople[randomNumber]));
				listOfPeople.remove(randomNumber);
			}
		}
		mapOfRandomRecords.put('listOfItems',listOfPeopleWrapper);
		mapOfRandomRecords.put('total',total);
		
		return mapOfRandomRecords;
	}
	
	public static Map<String, Integer> scoreMap {
		get {
			if(scoreMap == null) {
				scoreMap = new Map<String, Integer>{
				'0B'   => 62,		'0A'   => 61,		'1B'  => 60,		'1A'   => 59,
				 '2B'  => 58,		'2A'   => 57,		'3B'  => 56,		'3A'   => 55,
				 '4B'  => 54,		'4A'   => 53,		'5B'   => 52,		'5A'   => 51,		
				 '6B'  => 50,		'6A'   => 49,		'7B'   => 48,		'7A'   => 47,		
				 '8B'  => 46,		'8A'   => 45,		'9B'   => 44,		'9A'   => 43,		
				'10B'  => 42,		'10A'  => 41,		'11B'  => 40,		'11A'  => 39,		
				'12B'  => 38,		'12A'  => 37,		'13B'  => 36,		'13A'  => 35,		
				'14B'  => 34,		'14A'  => 33,		'15B'  => 32,		'15A'  => 31,		
				'16B'  => 30,		'16A'  => 29,		'17B'  => 28,		'17A'  => 27,		
				'18B'  => 26,		'18A'  => 25,		'19B'  => 24,		'19A'  => 23,		
				'20B'  => 22,		'20A'  => 21,		'21B'  => 20,		'21A'  => 19,		
				'22B'  => 18,		'22A'  => 17,		'23B'  => 16,		'23A'  => 15,		
				'24B'  => 14,		'24A'  => 13,		'25B'  => 12,		'25A'  => 11,		
				'26B'  => 10,		'26A'  => 9,		'27B'  => 8, 		'27A'  => 7,		
				'28B'  => 6,		'28A'  => 5,		'29B'  => 4, 		'29A'  => 3,		
				'30B'  => 2,		'30A'  => 1};
			}
			return scoreMap;
		}private set;
	}
	public static Integer getCelbrationScore(String birthdayKey, String anniversaryKey) {

		Integer birthDayScore = 0;
		Integer anniversaryScore = 0;
	
		if(scoreMap.containsKey(birthdayKey)) {
			birthDayScore = scoreMap.get(birthdayKey);
		}
		if(scoreMap.containsKey(anniversaryKey)) {
			anniversaryScore = scoreMap.get(anniversaryKey);
		}
		 return anniversaryScore > birthDayScore ? anniversaryScore : birthDayScore;
	}
	
	public Static OrgChartWrapper getOrgChartDetail(String peopleId, Boolean includeChildren, Boolean includeParent, Boolean includeGrandparent, String size, String nextPageToken){
    	OrgChartWrapper orgChartObj = new OrgChartWrapper();
    	
    	PeopleDao poepleDaoOb = new peopleDao();
    	People__c peopleObj = poepleDaoOb.getManagerIdAndName(peopleId);
		String parentManagerId = peopleObj.Manager__c;
		Map<Id, Integer> childCountMap = poepleDaoOb.getChildCountMap(peopleId, parentManagerId);
		if(childCountMap.isEmpty()){
			orgChartObj.showSelfInVertical = true;
		}
		OrgChartWrapper.OrgChartNode orgChartUserNodeObj = getOrgChartNode( peopleId, parentManagerId, peopleObj.Full_Name__c, size, childCountMap);
    	orgChartObj.userNode = orgChartUserNodeObj;
    	
    	peopleObj = poepleDaoOb.getManagerIdAndName(parentManagerId);
    	String grandParentManagerId = peopleObj.Manager__c; 
    	if(includeParent && String.isNotBlank(parentManagerId)){
			childCountMap = poepleDaoOb.getChildCountMap(parentManagerId, grandParentManagerId);
	    	OrgChartWrapper.OrgChartNode orgChartParentNodeObj = getOrgChartNode( parentManagerId, grandParentManagerId, peopleObj.Full_Name__c, size, childCountMap);
	    	orgChartObj.parent = orgChartParentNodeObj;
    	}
    	
    	if(includeGrandparent && String.isNotBlank(grandParentManagerId)){
			peopleObj = poepleDaoOb.getManagerIdAndName(grandParentManagerId);
			String greatGrandParentManagerId = peopleObj.Manager__c; 
			childCountMap = poepleDaoOb.getChildCountMap(grandParentManagerId, greatGrandParentManagerId);
	    	OrgChartWrapper.OrgChartNode orgChartGrandParentNodeObj = getOrgChartNode( grandParentManagerId, greatGrandParentManagerId, peopleObj.Full_Name__c, size, childCountMap);
	    	orgChartObj.grandparent = orgChartGrandParentNodeObj;
    	}
    	
    	if(includeChildren){
			childCountMap = poepleDaoOb.geOrgChartChildrenNodeChildCountMap(peopleId);
	    	List<OrgChartWrapper.OrgChartNodeItem> orgChartChildrenNodeItemList = geOrgChartChildrenNodeItemList(peopleId, size, nextPageToken, childCountMap);
			if(childCountMap.isEmpty()){
				orgChartObj.showChildrenInVertical = true;
			}
			if(String.isBlank(nextPageToken) && orgChartChildrenNodeItemList.size() < orgChartObj.userNode.person.childCount){
				orgChartObj.nextPageToken = String.valueOf(orgChartChildrenNodeItemList.size());
			} else if(String.isNotBlank(nextPageToken) && (Integer.valueOf(nextPageToken)+orgChartChildrenNodeItemList.size()) < orgChartObj.userNode.person.childCount){
				orgChartObj.nextPageToken = String.valueOf(orgChartChildrenNodeItemList.size() + Integer.valueOf(nextPageToken));
			} else {
				orgChartObj.nextPageToken = null;
			}
	    	orgChartObj.children = orgChartChildrenNodeItemList;
    	}
    	
    	return orgChartObj;
    }
 
	public Static Map<String,Object> getOrgChartDetailForProfile(String peopleId, String size, String nextPageToken){    	
		Map<String,Object> result = New Map<String,Object>();
    	PeopleDao peopleDaoObj = new peopleDao();
    	String parentManagerId = peopleDaoObj.getManagerId(peopleId); 
		Integer totalRecords;   	
    	Map<Id, Integer> childCountMap = peopleDaoObj.getChildCountMap(peopleId, parentManagerId);
		totalRecords = childCountMap.get(peopleId) != null ? childCountMap.get(peopleId) : 0;
    	List<People__c> peopleList = peopleDaoObj.geOrgChartChildrenNodePeopleList(peopleId, size, nextPageToken);
		List<PeopleListWrapper> listOfPeopleWrapper = PeopleListWrapper.peopleListToWrapper(peopleList);	
		if(String.isBlank(nextPageToken) && listOfPeopleWrapper.size() < totalRecords){
			nextPageToken = String.valueOf(listOfPeopleWrapper.size());
		} else if(String.isNotBlank(nextPageToken) && (Integer.valueOf(nextPageToken)+listOfPeopleWrapper.size()) < totalRecords){
			nextPageToken = String.valueOf(listOfPeopleWrapper.size() + Integer.valueOf(nextPageToken));
		} else {
			nextPageToken = null;
		}
		result.put('listOfItems',listOfPeopleWrapper);
		result.put('nextPageToken',nextPageToken);
		result.put('totalRecords',totalRecords);
		return result;
    }

    
    private static OrgChartWrapper.OrgChartNode getOrgChartNode(String nodePeopleId, String managerId, String fullName, String size, Map<Id, Integer> childCountMap){
    	PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> peopleList;		
		if(String.isNotBlank(size) && (!SimpplrContext.isFeatureEnabled('Full_External_Search') || Test.isRunningTest())) {
    		peopleList = peopleDaoObj.getPeopleListIndexed(nodePeopleId, managerId, fullName);
		} else {
			peopleList = peopleDaoObj.getNodePeopleList(nodePeopleId, managerId);
		}
    	
    	OrgChartWrapper.OrgChartNode orgChartNodeObj =  new OrgChartWrapper.OrgChartNode();
    	orgChartNodeObj.person = new OrgChartWrapper.OrgChartNodeItem();
    	orgChartNodeObj.siblings = new List<OrgChartWrapper.OrgChartNodeItem>();
    	for(People__c peopleObj : peopleList){
    		if((peopleObj.id+'').equalsIgnoreCase(nodePeopleId)){
    			orgChartNodeObj.person.childCount = childCountMap.get(nodePeopleId) != null ? childCountMap.get(nodePeopleId) : 0;
    			orgChartNodeObj.person.user = getPeopleListWrapper(peopleObj);
    			
    		} else {
    			OrgChartWrapper.OrgChartNodeItem siblingItem = new OrgChartWrapper.OrgChartNodeItem();
    			siblingItem.childCount = childCountMap.get(peopleObj.id) != null ? childCountMap.get(peopleObj.id) : 0;
    			siblingItem.user = getPeopleListWrapper(peopleObj);
    			orgChartNodeObj.siblings.add(siblingItem);
    		}
    	}
		if(orgChartNodeObj.person.user == null) {
			peopleList = peopleDaoObj.getNodePeopleList(nodePeopleId, null); 
			for(People__c peopleObj : peopleList) {
				orgChartNodeObj.person.childCount = childCountMap.get(nodePeopleId) != null ? childCountMap.get(nodePeopleId) : 0;
    			orgChartNodeObj.person.user = getPeopleListWrapper(peopleObj);
			}
		}
    	return orgChartNodeObj;
    }

    private static List<OrgChartWrapper.OrgChartNodeItem> geOrgChartChildrenNodeItemList(String managerId, String size, String nextPageToken, Map<Id, Integer> childCountMap){
    	PeopleDao peopleDaoObj = new  PeopleDao();
    	List<People__c> peopleList = peopleDaoObj.geOrgChartChildrenNodePeopleList(managerId, size, nextPageToken);
    	List<OrgChartWrapper.OrgChartNodeItem> orgChartNodeObjList =  new List<OrgChartWrapper.OrgChartNodeItem>();
    	for(People__c peopleObj : peopleList){
	    	OrgChartWrapper.OrgChartNodeItem orgChartNodeItemObj = new OrgChartWrapper.OrgChartNodeItem();
			orgChartNodeItemObj.childCount = childCountMap.get(peopleObj.id) != null ? childCountMap.get(peopleObj.id) : 0;
			orgChartNodeItemObj.user = getPeopleListWrapper(peopleObj);
			orgChartNodeObjList.add(orgChartNodeItemObj);
    	}
    	return orgChartNodeObjList;
    }
    
	private static PeopleLiteWrapper getPeopleListWrapper(People__c peopleObj){
    	PeopleLiteWrapper peopleLiteWrapObj = new PeopleLiteWrapper();
    	peopleLiteWrapObj.id = peopleObj.id;
    	peopleLiteWrapObj.peopleId = peopleObj.id;
    	peopleLiteWrapObj.userId = peopleObj.User__c;
    	peopleLiteWrapObj.sfUserId = peopleObj.User__c;
    	
        String name = Utility.buildName(peopleObj.First_Name__c,peopleObj.Last_Name__c);
        
		if (String.isNotBlank(name)) {
			peopleLiteWrapObj.name = name;
		}
    	
    	peopleLiteWrapObj.nickname = peopleObj.Community_Nickname__c;
    	peopleLiteWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObj.id;
    	if(String.isNotBlank(peopleObj.user__r.FullPhotoURL)) {
			peopleLiteWrapObj.img = peopleObj.user__r.FullPhotoURL.endsWith('005/F') ? null : peopleObj.user__r.FullPhotoURL;
    	}
    	peopleLiteWrapObj.department = peopleObj.Department__c;
    	peopleLiteWrapObj.title = peopleObj.Title__c;
    	peopleLiteWrapObj.location = Utility.buildLocation(peopleObj.City__c, peopleObj.State__c, peopleObj.Country__c);
    	
    	peopleLiteWrapObj.email = peopleObj.Email__c;
    	peopleLiteWrapObj.phone = peopleObj.Phone__c;
    	peopleLiteWrapObj.mobile = peopleObj.Mobile_Phone__c;
    	peopleLiteWrapObj.phoneExtension = peopleObj.Extension__c;
    	//peopleLiteWrapObj.phoneRaw = null;//TBD
    	//peopleLiteWrapObj.videoCall = null;//TBD
    	peopleLiteWrapObj.about = null;//TBD
    	peopleLiteWrapObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(peopleObj.Birth_Date__c,'MM-dd') : null;
    	if(SimpplrContext.isPPJoiningDateDisplay && peopleObj.Joining_Date__c != null && peopleObj.Joining_Date__c < Date.today().addDays(-3)) {
			peopleLiteWrapObj.hireDate =  Utility.dateToDisplayString(peopleObj.Joining_Date__c,'yyyy-MM-dd');
		}
    	
    	peopleLiteWrapObj.workAnniversary = null;//tbd
    	//peopleLiteWrapObj.isFollowing = peopleObj.User__c;TBD
    	//peopleLiteWrapObj.isFavorited = peopleObj.User__c;TBD
    	peopleLiteWrapObj.isActive = peopleObj.User__r.isActive;
    	//peopleLiteWrapObj.canFollow = peopleObj.User__c;TBD
    	return peopleLiteWrapObj;
    }		
			
	public static PeopleWrapper.FollowStats getFollowStats(String peopleId) {
		PeopleWrapper.FollowStats followStatsWrapper = new PeopleWrapper.FollowStats();
		
		SiteDao siteDaoObj = new SiteDao();
		PeopleDao peopleDaoObj = new PeopleDao();
		String userId = peopleDaoObj.getUserIdByPeopleId(peopleId);
		
		followStatsWrapper.peopleId = peopleId;
		followStatsWrapper.userFollowersCount = peopleDaoObj.getUsersFollowerList(userId).size();
		followStatsWrapper.userFollowingCount = peopleDaoObj.getUsersFollowingList(userId).size();
		
		// list of CollaborationGroupMember records where show in simpplr is true for current user
		List<CollaborationGroupMember> colGrpMembrList = siteDaoObj.getGrpMembrForSitesShowingInSimpplr(userId);
		
		followStatsWrapper.siteManagingCount = getSitesManagedBy(colGrpMembrList,peopleId).size();
		followStatsWrapper.siteMemberCount = peopleDaoObj.getUserSiteMembersList(peopleId);
		followStatsWrapper.siteFollowingCount = peopleDaoObj.getUserSiteFollowersList(peopleId);
		return followStatsWrapper;
	}
	
	public PeopleWrapper getUser(String peopleOrUserId, Boolean includeCustomFields,Boolean includeHiddenProfileFields) {
		PeopleWrapper pwObj = new PeopleWrapper();
		
		SiteDao siteDaoObj = new SiteDao();
		PeopleDao peopleDaoObj = new PeopleDao();
		People__c peopleObj = null;
		
		if(peopleOrUserId.startsWith('005')) {
			List<People__c> peopleList = peopleDaoObj.getPeopleByUserId(peopleOrUserId);

			for(People__c peopleObjTemp : peopleList){
				peopleObj = peopleObjTemp;

				break;
			}
		} else {
			peopleObj = peopleDaoObj.getPeopleByPeopleId(peopleOrUserId);
		}
		
		pwObj = peopleToPeopleWrapper(peopleObj,includeHiddenProfileFields);

		if(String.isNotBlank(peopleObj.Manager__c)){
			pwObj.manager = getManagerDetails(peopleObj.Manager__c);
		}
		
		if(includeCustomFields) {
			pwObj.listOfCustomFields = getCustomFields4User(peopleObj);
		}
		
		return pwObj;
	}

	private static PeopleLiteWrapper getManagerDetails(String managerId){
		PeopleLiteWrapper peopleWrappper = null;
		List<People__c> peopleList = [SELECT Id, Name, User__c, First_Name__c,
		 								Last_Name__c, User__r.SmallPhotoURL FROM People__c 
										WHERE Id =:managerId AND User__r.IsActive = true WITH SECURITY_ENFORCED];

		if(!peopleList.isEmpty()){
			People__c peopleObj = peopleList[0];
			String managerName = Utility.buildName(peopleObj.First_Name__c, peopleObj.Last_Name__c);

			peopleWrappper = new PeopleLiteWrapper();

			peopleWrappper.id = peopleObj.id;
			peopleWrappper.peopleId = peopleObj.id;
			peopleWrappper.userId = peopleObj.User__c;
			peopleWrappper.sfUserId = peopleObj.User__c;
			peopleWrappper.name = managerName;
			peopleWrappper.img = peopleObj.User__r.SmallPhotoURL;

		}

		return peopleWrappper;
	}
	
	public static PeopleWrapper peopleToPeopleWrapper(People__c peopleObjArg,Boolean includeHiddenProfileFields) {
		PeopleWrapper  peopleWrapObj = new PeopleWrapper ();

		peopleWrapObj.segmentId = peopleObjArg.Segment__c;
		
		peopleWrapObj.hasConnectedGoogleDriveAccount = false;
		peopleWrapObj.hasConnectedDropboxAccount = false;
		peopleWrapObj.hasConnectedSharePointAccount = false;
		peopleWrapObj.hasConnectedOneDriveAccount = false;
		peopleWrapObj.hasConnectedSlackAccount = false;
		peopleWrapObj.hasConnectedGoogleCalendarAccount = false;
		peopleWrapObj.hasConnectedMicrosoftTeamsAccount = false;
		peopleWrapObj.hasConnectedOutlookCalendarAccount = false;
		
		if(peopleObjArg.Preferences_People__r != null && !peopleObjArg.Preferences_People__r.isEmpty()){
			People_Preference__c ppf = peopleObjArg.Preferences_People__r.get(0);
			
			if(SimpplrContext.IsBoxIntegrationEnabled) {
	    		peopleWrapObj.hasConnectedBoxAccount = String.isNotBlank(ppf.Box_Access_Token__c);
			}
			peopleWrapObj.feedSort = ppf.Feed_Sort_Order__c;
		}
		
		if(peopleObjArg.People_Integrations__r != null && !peopleObjArg.People_Integrations__r.isEmpty()) {
			for(People_Integration__c pplInteg: peopleObjArg.People_Integrations__r) {
				if(pplInteg.name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING)) {
					peopleWrapObj.hasConnectedGoogleDriveAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
					peopleWrapObj.hasConnectedDropboxAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING)) {
					peopleWrapObj.hasConnectedSharePointAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING)) {
					peopleWrapObj.hasConnectedOneDriveAccount = pplInteg.connected__c;		
				} else if(!(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded) && pplInteg.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE)) {
					peopleWrapObj.hasConnectedSlackAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_SLACK)) {
					peopleWrapObj.hasConnectedSlackAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR)) {
					peopleWrapObj.hasConnectedGoogleCalendarAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS)) {
					peopleWrapObj.hasConnectedMicrosoftTeamsAccount = pplInteg.connected__c;		
				} else if(pplInteg.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR)) {
					peopleWrapObj.hasConnectedOutlookCalendarAccount = pplInteg.connected__c;
				}
			}
		}
		
  		peopleWrapObj.hasConnectedFacebookAccount = false;
		peopleWrapObj.hasConnectedLinkedInAccount = false;
		peopleWrapObj.hasConnectedTwitterAccount = false;  	
    	if (SimpplrContext.isEmployeeAdvocacyEnabled) {
	    	Boolean isFacebookEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK);
	    	Boolean isLinkedinEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN);
	    	Boolean isTwitterEnabled = SimpplrContext.appIntegrationEnabledSet.contains(IntegrationConstants.INTEGRATION_TYPE_TWITTER);
	    	IntegrationService integrationServiceObj = new IntegrationService(UserContext.peopleId);
	    	
	    	if (isFacebookEnabled) {
	    		integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK);
	    		if (integrationServiceObj.integrator != null && !integrationServiceObj.accessTokenExpired()) {
	    			peopleWrapObj.hasConnectedFacebookAccount = true;
	    		}
	    	}
	    	 
	    	if (isLinkedinEnabled) {
	    		integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN);
	    		if (integrationServiceObj.integrator != null && !integrationServiceObj.accessTokenExpired()) {
	    			peopleWrapObj.hasConnectedLinkedInAccount = true;
	    		}
	    	}
	    	
	    	if (isTwitterEnabled) {
	    		integrationServiceObj.setIntegrationVariables(IntegrationConstants.INTEGRATION_TYPE_TWITTER);
	    		if (integrationServiceObj.integrator != null && !integrationServiceObj.accessTokenExpired()) {
	    			peopleWrapObj.hasConnectedTwitterAccount = true;
	    		}
	    	}
    	}
		
		peopleWrapObj.id = peopleObjArg.id;
		peopleWrapObj.firstName = peopleObjArg.First_Name__c;
		peopleWrapObj.lastName = peopleObjArg.Last_Name__c;
		peopleWrapObj.peopleId = peopleObjArg.id;
		peopleWrapObj.sfUserId = peopleObjArg.User__c;
		peopleWrapObj.nickname = peopleObjArg.Community_Nickname__c;
		peopleWrapObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleObjArg.id;
        peopleWrapObj.microsoftTeamsUserName = peopleObjArg.Microsoft_Teams_User_Name__c;
		peopleWrapObj.microsoftTeamsUserId = peopleObjArg.Microsoft_Teams_User_Id__c;
		peopleWrapObj.microsoftTenantId = peopleObjArg.Microsoft_Tenant_Id__c;
		peopleWrapObj.slackUserName = peopleObjArg.Slack_User_Name__c;
		peopleWrapObj.slackUserId = peopleObjArg.Slack_User_Id__c;
		peopleWrapObj.slackTenantId = peopleObjArg.Slack_Tenant_Id__c;
        
		String name = Utility.buildName(peopleObjArg.First_Name__c,peopleObjArg.Last_Name__c);
		if(String.isNotBlank(name)){
			peopleWrapObj.name = name;
		}

		if(String.isNotBlank(peopleObjArg.user__r.FullPhotoURL)) {
			peopleWrapObj.img = peopleObjArg.user__r.FullPhotoURL.endsWith('005/F') ? null : peopleObjArg.user__r.FullPhotoURL;
		}
		if(includeHiddenProfileFields == true)  {
			peopleWrapObj.department =  peopleObjArg.Department__c ;
			peopleWrapObj.title = peopleObjArg.Title__c ;
			peopleWrapObj.location = Utility.buildLocation(peopleObjArg.City__c, peopleObjArg.State__c, peopleObjArg.Country__c);
			peopleWrapObj.email = peopleObjArg.Email__c;
			peopleWrapObj.phone =  peopleObjArg.Phone__c ;
			peopleWrapObj.mobile =  peopleObjArg.mobile_phone__c ;
			peopleWrapObj.phoneExtension =  peopleObjArg.extension__c ;
			peopleWrapObj.about = peopleObjArg.About__c;
			peopleWrapObj.birthday =  Utility.dateToDisplayString(peopleObjArg.Birth_Date__c,'MM-dd');
			peopleWrapObj.hireDate =  Utility.dateToDisplayString(peopleObjArg.Joining_Date__c,'yyyy-MM-dd');
			peopleWrapObj.workAnniversary = Utility.dateToDisplayString(peopleObjArg.Joining_Date__c,'MM-dd');
			peopleWrapObj.videoCallProvider = SimpplrContext.PPVideoProvider;
			peopleWrapObj.company =  peopleObjArg.Company_Name__c ;
			peopleWrapObj.division = peopleObjArg.Division__c ;
			peopleWrapObj.city = 	peopleObjArg.City__c ;
			peopleWrapObj.state = 	peopleObjArg.State__c;
			peopleWrapObj.country =  peopleObjArg.Country__c ;
			peopleWrapObj.streetAddress = peopleObjArg.Street__c;
			peopleWrapObj.userCategory = toUserCategoryWrapper(peopleObjArg);
		}else {
			peopleWrapObj.department = SimpplrContext.isPPDepartmentDisplay ? peopleObjArg.Department__c : null;
			peopleWrapObj.title = SimpplrContext.isPPTitleDisplay ? peopleObjArg.Title__c : null;
			peopleWrapObj.location = Utility.buildLocation(peopleObjArg.City__c, peopleObjArg.State__c, peopleObjArg.Country__c);
			peopleWrapObj.email = peopleObjArg.Email__c;
			peopleWrapObj.phone = simpplrcontext.isPPPhoneDisplay ? peopleObjArg.Phone__c : null;
			peopleWrapObj.mobile = SimpplrContext.isPPMobilePhoneDisplay ? peopleObjArg.mobile_phone__c : null;
			peopleWrapObj.phoneExtension = SimpplrContext.isPPExtensionDisplay ? peopleObjArg.extension__c : null;
			peopleWrapObj.about = SimpplrContext.isPPAboutMeDisplay ? peopleObjArg.About__c : null;
			peopleWrapObj.birthday = SimpplrContext.isPPBirthDateDisplay ? Utility.dateToDisplayString(peopleObjArg.Birth_Date__c,'MM-dd') : null;
			peopleWrapObj.hireDate = SimpplrContext.isPPJoiningDateDisplay ? Utility.dateToDisplayString(peopleObjArg.Joining_Date__c,'yyyy-MM-dd') : null;
			peopleWrapObj.workAnniversary = SimpplrContext.isPPJoiningDateDisplay ? Utility.dateToDisplayString(peopleObjArg.Joining_Date__c,'MM-dd') : null;
			peopleWrapObj.videoCallProvider = SimpplrContext.isPPVideoDisplay ? SimpplrContext.PPVideoProvider : null;
			peopleWrapObj.company = SimpplrContext.isPPCompanyNameDisplay ? peopleObjArg.Company_Name__c : null;
			peopleWrapObj.division = SimpplrContext.isPPDivisionDisplay ? peopleObjArg.Division__c : null;
			peopleWrapObj.city = Simpplrcontext.isPPCityDisplay ? peopleObjArg.City__c : null;
			peopleWrapObj.state = Simpplrcontext.isPPStateDisplay ? peopleObjArg.State__c : null;
			peopleWrapObj.country = SimpplrContext.isPPCountryDisplay ? peopleObjArg.Country__c : null;
			peopleWrapObj.streetAddress = SimpplrContext.isPPStreetDisplay ? peopleObjArg.Street__c : null;
			if(SimpplrContext.isPeopleCategoryEnable && SimpplrContext.isPPCategoryDisplay) {
				peopleWrapObj.userCategory = toUserCategoryWrapper(peopleObjArg);
			}
		}
		if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(peopleWrapObj.videoCallProvider)) {
			peopleWrapObj.videoCallUsername = peopleObjArg.Zoom_Id__c;
		} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(peopleWrapObj.videoCallProvider)) {
			peopleWrapObj.videoCallUsername = peopleObjArg.Skype_Id__c;
		}
        
		if (UserContext.usersIFollowIdSet.contains(peopleObjArg.User__c)) {
    		peopleWrapObj.isFollowing = true;
    		
    	} else {
    		peopleWrapObj.isFollowing = false;
    	}
    	
		peopleWrapObj.isActive = peopleObjArg.User__r.isactive;

    	if (!peopleObjArg.Bookmark_Receiver_People__r.isEmpty()) {
    		peopleWrapObj.isFavorited = true;
    		
    	} else {
    		peopleWrapObj.isFavorited = false;
    	}
    	
		
		if (UserContext.getCurrentUserInfo.Id == peopleObjArg.Id) {
			peopleWrapObj.canFollow = false;
		} else {
			peopleWrapObj.canFollow = peopleObjArg.User__r.isactive;
		}
		
		// permissions
		PeopleWrapper.PermissionWrapper permissionsObj = new PeopleWrapper.PermissionWrapper();
		List<PermissionSetAssignment> permissionSetList = AccessManager.getUserPermissionSetList(peopleObjArg.User__c);
		
		List<Simpplr_Site__c> userManagedSites = userManagedSitesList(peopleObjArg.User__c);
		
		permissionsObj.isAppManager = isUserAppModerator(peopleObjArg, permissionSetList);
		permissionsObj.isSiteManager = permissionsObj.isAppManager || isUserAnySiteManager(peopleObjArg.User__c);
		permissionsObj.isUnlistedAdmin = hasManageUnlistedSitePermission(peopleObjArg, permissionSetList);
		permissionsObj.isSegmentManager = peopleObjArg.Is_Segment_Manager__c;
		permissionsObj.canCreateSite = canCreateOrOwnGroups(peopleObjArg, permissionSetList);
		permissionsObj.canCreateBlogPost = canCreateBlogPost(peopleObjArg);
		permissionsObj.canAccessAllPrivateSites = hasModifyAllDataPermission(peopleObjArg, permissionSetList);
		permissionsObj.canManageHomeDashboard = SimpplrContext.isSegmentsEnabled ? (permissionsObj.isSegmentManager || permissionsObj.isAppManager) 
																				 : (peopleObjArg.Can_Control_Dashboard__c || permissionsObj.isAppManager);
		
		
		permissionsObj.canAccessAnalytics = permissionsObj.isAppManager || peopleObjArg.Can_Access_Analytics__c;
		
		permissionsObj.canSendNewsletterToAll = permissionsObj.isAppManager ||
												hasModifyAllDataPermission(peopleObjArg, permissionSetList) || 
												canSendNewsletter(peopleObjArg);
												
		permissionsObj.canSendNewsletter = permissionsObj.canSendNewsletterToAll || canSendSiteNewsletter(userManagedSites);
		
		permissionsObj.canSendAlertsToAll = permissionsObj.isAppManager ||
												hasModifyAllDataPermission(peopleObjArg, permissionSetList) || 
												canSendAlerts(peopleObjArg);
		
		permissionsObj.canSendAlerts = permissionsObj.canSendNewsletterToAll || canSendSiteAlerts(userManagedSites);
		permissionsObj.canManageCampaigns = permissionsObj.isAppManager || peopleObjArg.Is_Campaign_Manager__c;
		
		peopleWrapObj.permissions = permissionsObj;		
		TimeZone tz = Timezone.getTimeZone(peopleObjArg.User__r.TimeZoneSidKey);
		peopleWrapObj.timezoneName = Utility.timezoneIdToDisplayLabel(peopleObjArg.User__r.TimeZoneSidKey);
		peopleWrapObj.timezoneIso = tz.getID();
		peopleWrapObj.timezoneOffset = tz.getOffset(system.today());
		
		FileDao fileDaoObj = new FileDao();
		peopleWrapObj.profileImageUrl = Utility.getUserProfileImgUrl(peopleObjArg.User__r.MediumPhotoURL, peopleObjArg.User__r.FullPhotoURL);
		
		if(String.isNotBlank(peopleObjArg.Cover_Content_Document_Id__c)) {
			ContentDocument documentObj = fileDaoObj.getFileDetails(peopleObjArg.Cover_Content_Document_Id__c);
			if(documentObj != null) {
				peopleWrapObj.coverImageFile = new FileDetailWrapper();
				peopleWrapObj.coverImageFile.id = documentObj.Id;
				peopleWrapObj.coverImageFile.contentVersionId = documentObj.LatestPublishedVersion.Id;
				peopleWrapObj.coverImageFile.fileUrl = Utility.getFileDownloadURL(documentObj.LatestPublishedVersion.Id);
				peopleWrapObj.coverImageUrl = peopleWrapObj.coverImageFile.fileUrl;
			}
		}
		peopleWrapObj.language = Utility.getSimpplrLanguageLocaleKey(peopleObjArg.User__r.languagelocalekey).replace('_', '-');
		
		return peopleWrapObj;
	}
	
	private static PeopleWrapper.UserCategory toUserCategoryWrapper(People__c peopleObjArg){
		PeopleWrapper.UserCategory userCategoryWrapper = null;
		
		if(String.isNotBlank(peopleObjArg.People_Category__c)){
			userCategoryWrapper = new PeopleWrapper.UserCategory();
			
			userCategoryWrapper.id = peopleObjArg.People_Category__c;
			userCategoryWrapper.name = peopleObjArg.People_Category__r.Name__c;
		} 
		
		return userCategoryWrapper;
	}
	
	private static Boolean isUserAppModerator(People__c peopleRec, List<PermissionSetAssignment> permissionSetList){
		logger.logDebug('PeopleWrapper.isUserAppModerator()====peopleRec====' + peopleRec + '====permissionSetList====' + permissionSetList);
		Boolean isUserAppModerator = false;
		
		if(peopleRec != null && !'No'.equalsIgnoreCase(peopleRec.App_Moderation_Permission__c)) {
			if(peopleRec.User__r.profile.PermissionsModerateChatter){
					isUserAppModerator = true;
			}else{
				for(PermissionSetAssignment assignmentObj: permissionSetList) {
					if(assignmentObj.PermissionSet.PermissionsModerateChatter) {
						isUserAppModerator = true;
						break;
					}
				}
			}
		}
		logger.logDebug('PeopleWrapper.isUserAppModerator()====isUserAppModerator====' + isUserAppModerator );	
		return isUserAppModerator;
	}
	
	private static Boolean isUserAnySiteManager(String userId){
		logger.logDebug('AccessManager.isUserAnySiteManager()====userId====' + userId );
		Boolean isAnySiteManager = false;
		
		try{
			List<CollaborationGroupMember> collaborationGroupmemberList =new List<CollaborationGroupMember>();
			String BASE_QUERY = 'Select Id From CollaborationGroupMember where CollaborationRole=\'Admin\' and Member.IsActive=true and MemberId =:userId';
			if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+' and CollaborationGroup.NetworkId = null';
	    	}
	    	collaborationGroupmemberList = Database.query(BASE_QUERY);
			isAnySiteManager = collaborationGroupmemberList.size()> 0 ?true:false;
		}catch(Exception e){
			logger.logError('Site id is null for for current page', e);
		}
		
		logger.logDebug('AccessManager.isUserAnySiteManager()====isAnySiteManager====' + isAnySiteManager );
		return isAnySiteManager;
	}
	
	private static Boolean hasManageUnlistedSitePermission(People__c peopleRec, List<PermissionSetAssignment> permissionSetList) {
		Boolean hasManageUnlistedSitePermission = false;
		//logger.logDebug('AccessManager.hasManageUnlistedSitePermission()====permissionSetList====' + permissionSetList );
		
		if(peopleRec != null && peopleRec.User__r.Profile.PermissionsManageUnlistedGroups) {
			hasManageUnlistedSitePermission = true;
		} else {
			hasManageUnlistedSitePermission = false;
			for(PermissionSetAssignment assignmentObj: permissionSetList) {
				if(assignmentObj.PermissionSet.PermissionsManageUnlistedGroups == true) {
					hasManageUnlistedSitePermission = true;
					break;
				}
			}
		}
		
		logger.logDebug('AccessManager.hasManageUnlistedSitePermission()====hasManageUnlistedSitePermission====' + hasManageUnlistedSitePermission );
    	return hasManageUnlistedSitePermission;
    }
    
    public static Boolean canCreateOrOwnGroups(People__c peopleRec, List<PermissionSetAssignment> permissionSetList) {
		Boolean canCreateOrOwnGroups = false;
		//logger.logDebug('AccessManager.canCreateOrOwnGroups()====permissionSetList====' + permissionSetList );
		
		if( SimpplrContext.isATCollaborationGroupEnabled && SimpplrContext.isATCollaborationGroupMemberEnabled ) {
			if(peopleRec.User__r.Profile.PermissionsChatterOwnGroups) {
				canCreateOrOwnGroups = true;
			} else {
				canCreateOrOwnGroups = false;
				for(PermissionSetAssignment assignmentObj: permissionSetList) {
					if(assignmentObj.PermissionSet.PermissionsChatterOwnGroups) {
						canCreateOrOwnGroups = true;
						break;
					}
				}
			}
		}
	    
	    logger.logDebug('AccessManager.canCreateOrOwnGroups()====canCreateOrOwnGroups====' + canCreateOrOwnGroups );
	    return canCreateOrOwnGroups;
    }
    
    public static Boolean canCreateBlogPost(People__c peopleRec){
		if(SimpplrContext.isOnlyInfluencersAllowedToCreateBlog && peopleRec.Is_Influencer__c == false){
			return false;
		} else{
			return true;
		}
	}
    
    public static Boolean hasModifyAllDataPermission(People__c peopleRec, List<PermissionSetAssignment> permissionSetList) {
		Boolean hasModifyAllDataPermission = false;
		if(peopleRec.User__r.Profile.PermissionsModifyAllData) {
			hasModifyAllDataPermission = true;
		} else {
			hasModifyAllDataPermission = false;
			for(PermissionSetAssignment assignmentObj: permissionSetList) {
				if(assignmentObj.PermissionSet.PermissionsModifyAllData) {
					hasModifyAllDataPermission = true;
					break;
				}
			}
		}
		
		logger.logDebug('AccessManager.hasModifyAllDataPermission()====hasModifyAllDataPermission====' + hasModifyAllDataPermission );
    	return hasModifyAllDataPermission;
    }
    
    public static Boolean canSendSiteNewsletter(List<Simpplr_Site__c> listOfManagedSitesByUser) {
    	Boolean canSendSiteNewsletter = false;
	    		
		for(Simpplr_Site__c ss : listOfManagedSitesByUser){
			if(ss.Is_Newsletter_Allowed__c){
				canSendSiteNewsletter = true;
				break;
			}
		}
		
	    return canSendSiteNewsletter;
    }
    
    public static Boolean canSendNewsletter(People__c peopleRec) {
    	Boolean canSendNewsletter = peopleRec.Can_Send_Newsletter__c;
    	
    	return canSendNewsletter;
    }
    
    public static Boolean canSendSiteAlerts(List<Simpplr_Site__c> listOfManagedSitesByUser) {
    	Boolean canSendSiteAlerts = false;
	    		
		for(Simpplr_Site__c ss : listOfManagedSitesByUser){
			if(ss.Is_Alert_Enabled__c){
				canSendSiteAlerts = true;
				break;
			}
		}
		
	    return canSendSiteAlerts;
    }
    
    public static Boolean canSendAlerts(People__c peopleRec) {
    	Boolean canSendAlerts = peopleRec.Can_Send_Alert__c;
    	
    	return canSendAlerts;
    }
    
    public static List<Simpplr_Site__c> userManagedSitesList(String userId) {
    	Set<Id> collGroupIds = new Set<Id>();
    	
    	SiteDao siteDaoObj = new SiteDao();
    	// list of CollaborationGroupMember records where show in simpplr is true for current user
		List<CollaborationGroupMember> colGrpMembrList = siteDaoObj.getGrpMembrForSitesShowingInSimpplr(userId);
		List<CollaborationGroupMember> listOfCGMembers = getCollaborationGrpManagedBy(colGrpMembrList);
		
		for(CollaborationGroupMember cGMObj : listOfCGMembers) {
			collGroupIds.add(cGMObj.CollaborationGroupId);
		}
		
		List<Simpplr_Site__c> listOfManagedSitesByUser = [Select Id, Is_Alert_Enabled__c, Is_Newsletter_Allowed__c from Simpplr_Site__c where Chatter_Group_Id__c = :collGroupIds WITH SECURITY_ENFORCED];
		
		return listOfManagedSitesByUser;
    }
	
	private List<PeopleWrapper.UserCustomFieldsWrapper> getCustomFields4User(People__c peopleObj) {
    	
    	List<PeopleWrapper.UserCustomFieldsWrapper> listOfCustomFields = new List<PeopleWrapper.UserCustomFieldsWrapper>();
    	String userFieldsJSON;
    	
    	if (String.isNotBlank(SimpplrContext.appConfig.PP_User_Custom_Fields__c)) {
    		userFieldsJSON = SimpplrContext.appConfig.PP_User_Custom_Fields__c;
    	}
    	
		if (String.isNotBlank(userFieldsJSON)) {	
			List<CustomProfileField> allCustomFields = (List<CustomProfileField>)
													Json.deserialize(userFieldsJSON, 
													Type.forName('List<CustomProfileField>'));
			listOfCustomFields.addAll(getCustomUserFieldsList(allCustomFields, peopleObj));
		}
		
    	return listOfCustomFields;
    }
    public static void setCoverImage(String peopleId, String contentDocumentId, String contentVersionId) {
    	PeopleDao peopleDaoObj = new PeopleDao();
    	peopleDaoObj.setCoverImage(peopleId, contentDocumentId, contentVersionId);
    }
   
	public SlackDataServer.ResponseStructure getSlackUnfurlInfoForProfile(String peopleId) { 
		SlackDataServer.ResponseStructure response = new SlackDataServer.ResponseStructure();
		PeopleLiteWrapper peopleInfoWrapper = new PeopleLiteWrapper();
		
		PeopleDao peopleDaoObj = new PeopleDao();
		People__c peopleInfo = peopleDaoObj.getPeopleByPeopleId(peopleId);

		peopleInfoWrapper.peopleId = peopleInfo.Id;
		peopleInfoWrapper.userId = peopleInfo.User__c;
		
		if(String.isNotBlank(peopleInfo.External_Full_Photo_URL__c)){
			peopleInfoWrapper.img = peopleInfo.External_Full_Photo_URL__c;	
		
		} else {
			peopleInfoWrapper.img = profilePlaceholderImage;
		}
		
		peopleInfoWrapper.name = peopleInfo.Full_Name__c;
		if(SimpplrContext.isPPTitleDisplay){
			peopleInfoWrapper.title = String.isNotBlank(peopleInfo.Title__c) ? peopleInfo.Title__c : '';
		} else {
			peopleInfoWrapper.title = 'N.A.';
		}
		if(SimpplrContext.isPPDepartmentDisplay){
			peopleInfoWrapper.department = String.isNotBlank(peopleInfo.Department__c) ? peopleInfo.Department__c : '';
		} else {
			peopleInfoWrapper.title = 'N.A.';
		}
		String city = '';
		String state = '';
		String country = '';
		if(SimpplrContext.isPPCityDisplay){
			city = peopleInfo.City__c;
		} 
		if(SimpplrContext.isPPStateDisplay){
			state = peopleInfo.State__c;
		} 
		if(SimpplrContext.isPPCountryDisplay){
			country = peopleInfo.Country__c;
		}
		peopleInfoWrapper.location = Utility.buildLocation(city, state, country); 
		
		peopleInfoWrapper.email = String.isNotBlank(peopleInfo.Email__c) ? peopleInfo.Email__c : '';
		if(SimpplrContext.isPPMobilePhoneDisplay){
			peopleInfoWrapper.mobile = String.isNotBlank(peopleInfo.Mobile_Phone__c) ? peopleInfo.Mobile_Phone__c : '';
		} else {
			peopleInfoWrapper.mobile = 'N.A.';
		}
		if(SimpplrContext.isPPPhoneDisplay){
			peopleInfoWrapper.phone = String.isNotBlank(peopleInfo.Phone__c) ? peopleInfo.Phone__c : '';
		} else {
			peopleInfoWrapper.phone = 'N.A.';
		} 
		if(SimpplrContext.isPPExtensionDisplay){
			peopleInfoWrapper.phoneExtension = String.isNotBlank(peopleInfo.Extension__c) ? peopleInfo.Extension__c : '';
		} else {
			peopleInfoWrapper.phoneExtension = 'N.A.';
		}
        peopleInfoWrapper.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+peopleInfo.Id;
        if(SimpplrContext.isPPVideoDisplay){
	        if(ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
				peopleInfoWrapper.videoCallUsername = String.isNotBlank(peopleInfo.Zoom_Id__c) ? peopleInfo.Zoom_Id__c : '';
			} else if(ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
				peopleInfoWrapper.videoCallUsername = String.isNotBlank(peopleInfo.Skype_Id__c) ? peopleInfo.Skype_Id__c : '';
			}
			peopleInfoWrapper.videoCallProvider = String.isNotBlank(SimpplrContext.PPVideoProvider) ? SimpplrContext.PPVideoProvider : '' ;
        } else {
        	peopleInfoWrapper.videoCallProvider = 'N.A.';
        }
		response.type = 'Profile';
		response.profileDetail = peopleInfoWrapper;
		return response;
	}
	   
	private static List<CollaborationGroupMember> getCollaborationGrpManagedBy(List<CollaborationGroupMember> cgmList) {
		List<CollaborationGroupMember> listOfCollborationGrpMember = new List<CollaborationGroupMember>();
		
		for (CollaborationGroupMember cgm : cgmList) {
			
			if ('Admin'.equalsIgnoreCase(cgm.CollaborationRole)) {
				listOfCollborationGrpMember.add(cgm);
			}
		}
				
		return listOfCollborationGrpMember;
	}

	private static List<Id> getSitesManagedBy(List<CollaborationGroupMember> cgmList, String peopleId) {
		List<Id> listOfManager = new List<Id>();
		
		for (CollaborationGroupMember cgm : cgmList) {
			
			if ('Admin'.equalsIgnoreCase(cgm.CollaborationRole)) {
				listOfManager.add(cgm.MemberId);
			}
		}
		
		List<Site_Role__c> listOfSiteRole = [Select Id, People__r.User__c From Site_Role__c Where People__c = :peopleId And Is_Content_Manager__c = true AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
		for (Site_Role__c siteRoleObj : listOfSiteRole) {
			listOfManager.add(siteRoleObj.People__r.User__c);
		}

		return listOfManager;
	}
	
	public List<FilterAttributeWrapper> searchDepartment(Criteria.People pplCriteriaObj) {
		List<FilterAttributeWrapper> wrapperList = new List<FilterAttributeWrapper>(); 

		Integer recordLimit = pplCriteriaObj.size + 1;
    	Integer offset = pplCriteriaObj.offset;

		PeopleDao daoObj = new PeopleDao();
		List<AggregateResult> aggrList =  daoObj.searchDepartment(pplCriteriaObj.term, offset, recordLimit);
		for(AggregateResult ar: aggrList) {
            String department = (String)ar.get('department');
			FilterAttributeWrapper wrapperObj = new FilterAttributeWrapper(department.toLowerCase(), department);
			wrapperList.add(wrapperObj);
        }
		return wrapperList;
		
	}

	public List<FilterAttributeWrapper> searchLocation(Criteria.People pplCriteriaObj) {
		List<FilterAttributeWrapper> wrapperList = new List<FilterAttributeWrapper>(); 

		Integer recordLimit = pplCriteriaObj.size + 1;
    	Integer offset = pplCriteriaObj.offset;

		PeopleDao daoObj = new PeopleDao();
		List<People__c> listOfPeople =  daoObj.searchLocation(pplCriteriaObj.term);
		Map<String, FilterAttributeWrapper> mapOfLocations = new Map<String, FilterAttributeWrapper>();
		Map<String, FilterAttributeWrapper> mapOfLocationsSorted = new Map<String, FilterAttributeWrapper>();
		Map<String, FilterAttributeWrapper> mapOfLocationsMid = new Map<String, FilterAttributeWrapper>();
		
		String city = ' ';
		String state = ' ';
		String country = ' ';
		Boolean isPPCityDisplay = SimpplrContext.isPPCityDisplay;
		Boolean isPPStateDisplay = SimpplrContext.isPPStateDisplay;
		Boolean isPPCountryDisplay = SimpplrContext.isPPCountryDisplay;

		for(People__c ppl : listOfPeople){
			if(!isPPCityDisplay){
				ppl.City__c = null;
			}
			if(!isPPStateDisplay){
				ppl.State__c = null;
			}
			if(!isPPCountryDisplay){
				ppl.Country__c = null;
			}
			city =  ppl.city__c;
			state =  ppl.state__c;
			country =  ppl.country__c;
			String location = '';
			String label = '';
			location = city + ' @@ ' + state + ' @@ ' + country;
			if(String.isNotBlank(city)) {
				label = city + ', ';
			}
			if(String.isNotBlank(state)) {
				label += state + ', ';
			}
			if(String.isNotBlank(country)) {
				label += country;
			}
			label.removeEnd(', ');
			if(!mapOfLocationsSorted.containsKey(location) && !mapOfLocations.containsKey(location) && !mapOfLocationsMid.containsKey(location)) {
				mapOfLocations.put(location,new FilterAttributeWrapper(location,label));
			}
			if(String.isNotBlank(country) && country.containsIgnoreCase(pplCriteriaObj.term)){
				location = null + ' @@ ' + null + ' @@ ' + country;
				if(!mapOfLocationsSorted.containsKey(location) && !mapOfLocations.containsKey(location) && !mapOfLocationsMid.containsKey(location)) {
					mapOfLocationsSorted.put(location,new FilterAttributeWrapper(location,country));
				}
			}
			if(String.isNotBlank(state) && String.isNotBlank(country) && (state+', '+country).containsIgnoreCase(pplCriteriaObj.term)) {
				location = null + ' @@ ' + state + ' @@ ' + country;
				label = state+', '+country;
				if(!mapOfLocationsSorted.containsKey(location) && !mapOfLocations.containsKey(location) && !mapOfLocationsMid.containsKey(location)) {
					mapOfLocationsMid.put(location,new FilterAttributeWrapper(location,label));
				}
			}
		}
		List<FilterAttributeWrapper> listOfFilterWrapper =  mapOfLocations.values();
		List<FilterAttributeWrapper> listOfFilterWrapperMid =  mapOfLocationsMid.values();
		List<FilterAttributeWrapper> listOfFilterWrapperSorted =  mapOfLocationsSorted.values();
		listOfFilterWrapper.sort();
		listOfFilterWrapperMid.sort();
		listOfFilterWrapperSorted.sort();
		listOfFilterWrapperSorted.addAll(listOfFilterWrapperMid);
		listOfFilterWrapperSorted.addAll(listOfFilterWrapper);
		return getSelectedPageRecords(listOfFilterWrapperSorted, offset, recordLimit);		
		
	}

	private static List<FilterAttributeWrapper> getSelectedPageRecords(List<FilterAttributeWrapper> listOfLocations, Integer offset, Integer recordLimit) {
		List<FilterAttributeWrapper> listOfSelectedPageRecords = new List<FilterAttributeWrapper>();
		Integer totalRecordCount = listOfLocations.size();
		if(totalRecordCount > offset) {
			if(offset ==0 && totalRecordCount <= recordLimit) {
				listOfSelectedPageRecords = listOfLocations;
			} else {
				for(Integer index = offset; index < totalRecordCount && index < offset + recordLimit; index++) {
					listOfSelectedPageRecords.add(listOfLocations[index]);
				}
			}
		}
		return listOfSelectedPageRecords;
	}

	private List<PeopleWrapper.UserCustomFieldsWrapper> getCustomUserFieldsList(List<CustomProfileField> fieldsList, People__c peopleObj) {
		List<PeopleWrapper.UserCustomFieldsWrapper> customUserFields = new List<PeopleWrapper.UserCustomFieldsWrapper> ();
		
		Set<String> userColumnSet = new Set<String>();
		for(CustomProfileField fieldObj : fieldsList) {
			if(fieldObj.onOff !=null && fieldObj.onOff && String.isBlank(fieldObj.syncSource)) {
				userColumnSet.add(fieldObj.fieldName);
			}
			
		}
		UserDao daoObj = new UserDao();
		User userObject = daoObj.getCustomFieldsForUser(userColumnSet, peopleObj.User__c);
		
		Map<String,Schema.SObjectField> userFields = User.SObjectType.getDescribe().fields.getMap();
		for(CustomProfileField customFieldObj : fieldsList) {	
			if(customFieldObj.onOff !=null && customFieldObj.onOff) {		
				PeopleWrapper.UserCustomFieldsWrapper fieldObj = new PeopleWrapper.UserCustomFieldsWrapper();
				if(String.isBlank(customFieldObj.syncSource)) {
					DescribeFieldResult resultObj = userFields.get(customFieldObj.fieldName).getDescribe();
					fieldObj.label = resultObj.getLabel();
					fieldObj.isHtml = customFieldObj.isHtml;
					fieldObj.isEditable = resultObj.isUpdateable() ? String.valueOf(customFieldObj.isEditable) : 'false';
					fieldObj.isRequired = !resultObj.isNillable();
					fieldObj.fieldName = customFieldObj.fieldName;
					fieldObj.columnName = customFieldObj.columnName;
					fieldObj.fieldType = resultObj.getType().name().toLowerCase();
					
					fieldObj.maxLength = (Integer)resultObj.getLength();
					
					if(Schema.DisplayType.Date == resultObj.getType()) {
						fieldObj.value = Utility.dateToDisplayString((Date)userObject.get(customFieldObj.fieldName), ServiceConstants.DATE_FORMAT);
					
					} else if (Schema.DisplayType.DateTime == resultObj.getType()) {
						fieldObj.value = Utility.dateToDisplayString((DateTime)userObject.get(customFieldObj.fieldName), 
														ServiceConstants.LISTING_DATETIME_FORMAT);
														
					} else if (Schema.DisplayType.Picklist == resultObj.getType()) {
						fieldObj.picklistEntryList = resultObj.getPicklistValues();
						//Map<String, String> mapOfPickListValues = getPickListMap(resultObj.getPicklistValues()); //commenting SV2-47180 this is not Required
						fieldObj.value = String.valueOf(userObject.get(customFieldObj.fieldName));
						//if(mapOfPickListValues.containsKey(fieldObj.value)) {
						//	fieldObj.value = mapOfPickListValues.get(fieldObj.value);
						//}
						
						
					} else if (Schema.DisplayType.MultiPicklist == resultObj.getType()) {
						fieldObj.picklistEntryList = resultObj.getPicklistValues();
						Map<String, String> mapOfPickListValues = getPickListMap(resultObj.getPicklistValues());
						fieldObj.listOfMultiPickListFieldValues = new List<String>();
						if(userObject.get(customFieldObj.fieldName) != null) {
							fieldObj.multiPickListFieldKeys = (String)userObject.get(customFieldObj.fieldName);
							List<String> selectedKeyList = (fieldObj.multiPickListFieldKeys).split(';');
							for(String key : selectedKeyList) {
								fieldObj.listOfMultiPickListFieldValues.add(mapOfPickListValues.get(key));
							}
							fieldObj.selectedValues = fieldObj.listOfMultiPickListFieldValues;
							fieldObj.value = Utility.convertToCommaSeparatedString(fieldObj.listOfMultiPickListFieldValues);
						}
						
						
					} else {
						fieldObj.value = String.valueOf(userObject.get(customFieldObj.fieldName));
						
					}
				} else {
					fieldObj.label = customFieldObj.singular;
					fieldObj.isHtml = false;
					fieldObj.isEditable = 'false';
					fieldObj.fieldName = customFieldObj.fieldName;
					fieldObj.fieldType = 'string';
					fieldObj.value = String.valueOf(peopleObj.get(SimpplrContext.namespacePrefix + customFieldObj.columnName));
				}		
				
				customUserFields.add(fieldObj);
			}
		}
		
		return customUserFields;
	} 

	private Map<String, String> getPickListMap(List<Schema.PicklistEntry> pickListEntries) {
		Map<String, String> mapOfPickListValues = new Map<String, String>();
		for(Schema.PicklistEntry pickList : pickListEntries) {
			mapOfPickListValues.put(pickList.getValue(), pickList.getLabel());
		}
		return mapOfPickListValues;
	}
	
	public List<FilterAttributeWrapper> getValues(String term, String columnName, Integer recordLimit) {
		PeopleDao peopleDaoObj = new PeopleDao();
		List<AggregateResult> aggrList =  peopleDaoObj.getValues(term, columnName, recordLimit);
		List<FilterAttributeWrapper> wrapperList = new List<FilterAttributeWrapper>();
		for(AggregateResult ar: aggrList) {
            String value = (String)ar.get('value');	
			FilterAttributeWrapper wrapperObj = new FilterAttributeWrapper(value, value);
			wrapperList.add(wrapperObj);
        }
		return wrapperList;
	}
	
	public List<FilterAttributeWrapper> getValues(String term, String columnName) {
		PeopleDao peopleDaoObj = new PeopleDao();
		List<People__c> peopleList =  peopleDaoObj.getValues(columnName);
		Set<String> columnValuesSet = new Set<String>();
		List<String> columnValuesList = new List<String>();
		String fieldName = SimpplrContext.namespacePrefix + columnName;
		for(People__c peopleObj : peopleList) {
			String fieldValue = (String)peopleObj.get(fieldName);
			if(String.isBlank(term) || fieldValue.containsIgnoreCase(term)){
				columnValuesSet.add(fieldValue);
			}
		}
		columnValuesList.addAll(columnValuesSet);
		columnValuesList.sort();
		List<FilterAttributeWrapper> wrapperList = new List<FilterAttributeWrapper>();
		for(String fieldValue: columnValuesList) {
			FilterAttributeWrapper wrapperObj = new FilterAttributeWrapper(fieldValue, fieldValue);
			wrapperList.add(wrapperObj);
        }
		return wrapperList;
	}
	   
	public List<PeopleListingWrapper> getCelebrationsForPeoplePosts(String segmentId, Boolean isMobileOrigin) {
    	logger.logDebug('PeopleContentProvider.getCelebrationsForPeoplePosts()----start----');
		
		Integer daysLimit = 3;
		String filter = 'all';
		date today = date.today();
		Integer thisyear = today.year();
		Integer todayDayofYear =today.dayofYear(); 
		if(Date.isLeapYear(thisyear) == false){
			todayDayofYear = today.dayofYear() + 1; 
		}
		
		List<PeopleListingWrapper> pLWList = new List<PeopleListingWrapper>();
    	
    	PeopleDao daoObj = new PeopleDao();
		List<People__c> listOfPeople = daoObj.getCelebrationsForPeoplePosts(filter, daysLimit,todayDayofYear, isMobileOrigin);
		
		for(People__c peopleObj : listOfPeople) {
			String daysToBirthday;
            String daysToJoining;
            if(peopleObj.Birth_Date__c != null){
                daysToBirthday = String.valueOf(getdaystocelebration(integer.valueOf(peopleobj.Day_Of_Year_B__c),todayDayofYear)) + 'B';
            }
            if(peopleObj.Joining_Date__c != null){
                daysToJoining = String.valueOf(getdaystocelebration(integer.valueOf(peopleobj.Day_Of_Year_J__c),todayDayofYear)) + 'A';
            }
			PeopleListingWrapper wrapperObj = ObjectToWrapperAdapter.peopleToWrapper(peopleObj);
			wrapperObj.relevancyScore = PeopleContentProvider.getCelbrationScore(daysToBirthday , daysToJoining);
			pLWList.add(wrapperObj);
		}

		pLWList.sort();
		
		return pLWList;
	}
	
	public List<PeopleListingWrapper> getNewHiresForPeoplePosts(String segmentId, Boolean isMobileOrigin) {
		logger.logDebug('PeopleContentProvider.getNewHiresForPeoplePosts()----segmentId----'+segmentId+'-----isMobileOrigin'+isMobileOrigin);
		
		Integer daysLimit = 3;

		PeopleDao peopleDaoObj = new PeopleDao();

		List<People__c> peopleList = new List<People__c>();
        if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
            ExternalSearchService searchServiceObj = new ExternalSearchService();
            List<String> peopleIds = searchServiceObj.getLatestHiresId(500, daysLimit);
            Map<Id, People__c> peopleMap = new Map<Id, People__c>(peopleDaoObj.getNewHiresForPeoplePosts('home', segmentId, null, peopleIds, isMobileOrigin));
            for(String peopleId : peopleIds) {
				if(SimpplrContext.isPPJoiningDateDisplay == true){
					if(peopleMap.containsKey(peopleId)) {
						peopleList.add(peopleMap.get(peopleId));
					}
				}
            }
        } else {
            peopleList = peopleDaoObj.getNewHiresForPeoplePosts('home', segmentId, daysLimit, null, isMobileOrigin);
        }
		
		List<PeopleListingWrapper> pLWList = new List<PeopleListingWrapper>();
        
        for(People__c peopleObj : peopleList){
            pLWList.add(ObjectToWrapperAdapter.peopleToWrapper(peopleObj));
        }
		
    	return pLWList;
	}

	public static List<PeopleListWrapper> getPeopleExpertiseList (Criteria.People peopleCriteriaObjArg){
		
    	String expertiseId = peopleCriteriaObjArg.expertiseId;
    	Integer recordLimit = peopleCriteriaObjArg.size + 1;
    	Integer offset = peopleCriteriaObjArg.offset;
    	String searchText = peopleCriteriaObjArg.term;
    	
    	PeopleDao peopleDaoObj = new PeopleDao();
	List<People__c> peopleList = peopleDaoObj.getPeopleExpertiseList(expertiseId ,searchText, recordLimit, offset);
    	List<PeopleListWrapper> listOfPeopleWrapper = new List<PeopleListWrapper>(); 
    	for(People__c pplObj : peopleList){
			PeopleListWrapper peopleListWrapObj = PeopleListWrapper.peopleToWrapper(pplObj); 
			listOfPeopleWrapper.add(peopleListWrapObj);
		}
		return listOfPeopleWrapper;
	}

	public List<String> getUserWebpushTokens(String peopleId, String orgId) {
		List<String> webpushTokensList = new List<String>();

		String WEB_PUSH_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/notifications/web-push-manager'; 
		String simpplrDri = Utility.externalRequestAuthToken() + 
				' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
				' ' + UserContext.userId.substring(0, 15);
				
		HttpRequest req = new HttpRequest();
		req.setEndpoint(WEB_PUSH_ENDPOINT);
		
		Map<String, Object> requestBody = new Map<String, Object>();
		
		requestBody.put('action', 'getuserwebpushtokens');

		requestBody.put('peopleId', peopleId.substring(0, 15)); 
		requestBody.put('orgId', orgId.substring(0, 15)); 
		
		req.setBody(Json.serialize(requestBody));
		req.setHeader('simpplr-dri', simpplrDri);
		
		req.setMethod('POST');

		Http httpObj = new Http();
		HttpResponse response = null;
			
		response = httpObj.send(req);

		if(response.getStatusCode() == 200){
			Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

			for(Object token : (List<Object>)responseMap.get('result')) {
				webpushTokensList.add((String)token);
			}
		}

		return webpushTokensList;
	}

    public List<PeopleWrapper.AppManagerWrapper> getAppManagerList() {		
		List<People__c> peopleList = new PeopleDao().getAppManagerList();
        List<PeopleWrapper.AppManagerWrapper> listOfAppManagerWrap = new List<PeopleWrapper.AppManagerWrapper>();
		
        for (People__c peopleObj: peopleList) {
            PeopleWrapper.AppManagerWrapper appMangerObj = new PeopleWrapper.AppManagerWrapper();
            appMangerObj.id = peopleObj.id;
            appMangerObj.name = peopleObj.Full_Name__c;
            appMangerObj.email = peopleObj.user__r.email; 
            listOfAppManagerWrap.add(appMangerObj);
        }
									
		return listOfAppManagerWrap;	
	}

	public List<PeopleWrapper.AppManagerWrapper> getAppAndSegmentManagerList() {		
		List<People__c> peopleList = new PeopleDao().getAppAndSegmentManagerList();
        List<PeopleWrapper.AppManagerWrapper> managerWrapperList = new List<PeopleWrapper.AppManagerWrapper>();
		
        for (People__c peopleObj: peopleList) {
            PeopleWrapper.AppManagerWrapper appMangerObj = new PeopleWrapper.AppManagerWrapper();
            appMangerObj.id = peopleObj.id;
            appMangerObj.name = peopleObj.Full_Name__c;
            appMangerObj.email = peopleObj.user__r.email; 
			
            managerWrapperList.add(appMangerObj);
        }
									
		return managerWrapperList;	
	}

	/**
     * @description convertToPeopleListWrapper converts the peopledate to listing wrapper
     * @return PeopleListWrapper - fetched people list
	 * @param convertorArgumentsObj - convertor object
     */
	private static PeopleListWrapper convertToPeopleListWrapper(ConvertorArgumentsWrapper convertorArgumentsObj) {		
		PeopleListWrapper peopleWrapObj = new PeopleListWrapper();
		
		People__c peopleObj = convertorArgumentsObj.peopleObj;
		String convertFor = convertorArgumentsObj.convertFor;
		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = convertorArgumentsObj.mapOfMemberIdAndRoleOfSite;
		Set<String> mandatorySiteSubscriptionPeopleIdSet = convertorArgumentsObj.mandatorySiteSubscriptionPeopleIdSet;

		peopleWrapObj = PeopleListWrapper.peopleToWrapper(convertorArgumentsObj.peopleObj);
		
		peopleWrapObj.canRemove = true;
		peopleWrapObj.canMakeOwner = true; 
		peopleWrapObj.canMakeManager = true;
		peopleWrapObj.canMakeContentManager = true;
		peopleWrapObj.canMakeNotManager = false;
		peopleWrapObj.canMakeNotContentManager = false;
		peopleWrapObj.isOwner = false;
		peopleWrapObj.isManager = false;
		peopleWrapObj.isContentManager = false;
		peopleWrapObj.isMember = false;
		peopleWrapObj.isFollower = false;
        peopleWrapObj.canSPTransferOwnership = convertorArgumentsObj.pplIntegration == null ? null : convertorArgumentsObj.pplIntegration.SP_Instance_Id__c == UserContext.spInstanceId ? true : false;

		if(SimpplrContext.isSharepointConnected && convertorArgumentsObj.pplIntegration != null) {
			peopleWrapObj.hasConnectedSharePointAccount = convertorArgumentsObj.pplIntegration.connected__c;
		}

		Boolean isSiteMembers = (convertFor == 'getSiteMembers' || convertFor == 'getAllSiteMembers');
		Boolean isSiteMembersFl = (convertFor == 'getSiteMembers' || convertFor == 'getAllSiteMembers' || convertFor == 'getSitesMembersEveryone' || convertFor == 'getAllSitesMembersFollowers');

		peopleWrapObj.isMember = isSiteMembers;
		peopleWrapObj.isAppManager = UserContext.isUserAppModerator && isSiteMembers;

		String siteRole = mapOfMemberIdAndRoleOfSite.containsKey(peopleObj.user__c) ? mapOfMemberIdAndRoleOfSite.get(peopleObj.user__c).role : '';

		peopleWrapObj = setPermissionLevel(peopleWrapObj, convertFor, siteRole);

		if(mandatorySiteSubscriptionPeopleIdSet != null && !mandatorySiteSubscriptionPeopleIdSet.isEmpty() && mandatorySiteSubscriptionPeopleIdSet.contains(peopleObj.Id) && isSiteMembersFl){
			// Check if users other than managers/owner not in the subscriptions then provide an option to remove them.
			peopleWrapObj.canRemove = false;
		}

		peopleWrapObj = setSpecialCases(peopleWrapObj, convertorArgumentsObj, siteRole);
		peopleWrapObj.language = Utility.getSimpplrLanguageLocaleKey(peopleObj.User__r.languagelocalekey).replace('_', '-');
		peopleWrapObj.segmentId = SimpplrContext.isSegmentsEnabled ? peopleObj.Segment__c : null;

		TimeZone tz = Timezone.getTimeZone(peopleObj.User__r.TimeZoneSidKey);
		peopleWrapObj.timezoneName = Utility.timezoneIdToDisplayLabel(peopleObj.User__r.TimeZoneSidKey);
		peopleWrapObj.timezoneIso = tz.getID();
		peopleWrapObj.timezoneOffset = tz.getOffset(system.today());

		return peopleWrapObj;
	}

	/**
     * @description setPermissionLevel converts the peopledate to listing wrapper
     * @return PeopleListWrapper - fetched people list
	 * @param peopleWrapObj - people wrapper object
	 * @param convertFor - requested Method for conversion
	 * @param siteRole - value of siteRole
     */
	private Static PeopleListWrapper setPermissionLevel(PeopleListWrapper peopleWrapObj, String convertFor, String siteRole){

		Boolean isSiteMembers = (convertFor == 'getSiteMembers' || convertFor == 'getAllSiteMembers');
		Boolean isSiteMembersFl = (convertFor == 'getSiteMembers' || convertFor == 'getAllSiteMembers' || convertFor == 'getSitesMembersEveryone' || convertFor == 'getAllSitesMembersFollowers');


		if('Owner'.equalsIgnoreCase(siteRole)) {
			peopleWrapObj.isOwner = true;
			peopleWrapObj.canRemove = false;
			peopleWrapObj.canMakeManager = false;
			peopleWrapObj.canMakeContentManager = false;
			peopleWrapObj.canMakeNotManager = false;
			peopleWrapObj.canMakeNotContentManager = false;
			peopleWrapObj.isMember = true;
			peopleWrapObj.isManager = !isSiteMembers;
			peopleWrapObj.canMakeOwner = !isSiteMembers;
			
		} else if('Manager'.equalsIgnoreCase(siteRole)) {
			peopleWrapObj.isManager = true;
			peopleWrapObj.canRemove = false;
			peopleWrapObj.canMakeManager = false;
			peopleWrapObj.canMakeContentManager = true;
			peopleWrapObj.canMakeNotManager = true;
			peopleWrapObj.canMakeNotContentManager = false;
			peopleWrapObj.isMember = true;
			peopleWrapObj.isOwner = false;
			peopleWrapObj.canMakeOwner = isSiteMembers;
			peopleWrapObj.canRemove = isSiteMembersFl;

		} else if('ContentManager'.equalsIgnoreCase(siteRole)) {
			peopleWrapObj.isContentManager = true;
			peopleWrapObj.canRemove = false;
			peopleWrapObj.canMakeManager = true;
			peopleWrapObj.canMakeContentManager = false;
			peopleWrapObj.canMakeNotManager = false;
			peopleWrapObj.canMakeNotContentManager = true;
			peopleWrapObj.isMember = true;
			peopleWrapObj.canRemove = isSiteMembersFl;
			
		} else if('Member'.equalsIgnoreCase(siteRole)) {
			peopleWrapObj.isMember = true;
		} else if('Follower'.equalsIgnoreCase(siteRole)) {
			peopleWrapObj.isFollower = true;
		}
		return peopleWrapObj;
	}

	/**
     * @description setSpecialCases converts the peopledate to listing wrapper
     * @return PeopleListWrapper - fetched people list 
	 * @param peopleWrapObj - people wrapper object
	 * @param convertorArgumentsObj - convertor object
	 * @param siteRole - value of siteRole
     */
	private Static PeopleListWrapper setSpecialCases(PeopleListWrapper peopleWrapObj, ConvertorArgumentsWrapper convertorArgumentsObj, String siteRole){

		String convertFor = convertorArgumentsObj.convertFor;
		Boolean isSiteMembers = (convertFor == 'getSiteMembers' || convertFor == 'getAllSiteMembers');

		peopleWrapObj.canMakeOwner = false;
		peopleWrapObj = isSiteMembers ? setCanMakeOwnerMembers(peopleWrapObj, convertorArgumentsObj, siteRole) : setCanMakeOwner(peopleWrapObj, convertorArgumentsObj);
		return peopleWrapObj;
	}

	/**
     * @description setCanMakeOwnerMembers converts the peopledate to listing wrapper
     * @return PeopleListWrapper - fetched people list 
	 * @param peopleWrapObj - people wrapper object
	 * @param convertorArgumentsObj - convertor object
	 * @param siteRole - value of siteRole
     */
	private Static PeopleListWrapper setCanMakeOwnerMembers(PeopleListWrapper peopleWrapObj, ConvertorArgumentsWrapper convertorArgumentsObj, String siteRole){

		CollaborationGroup collabGroupObj = convertorArgumentsObj.collabGroupObj;
		Simpplr_Site__c siteObj = convertorArgumentsObj.siteObj;

		Boolean isCurrentUserSiteOwner = false;
		if(UserInfo.getUserId().equalsIgnoreCase(collabGroupObj.OwnerId)){
			isCurrentUserSiteOwner = true;
		}
		if(((UserContext.hasModifyAllDataPermission && !'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c) || ('Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c) && UserContext.hasManageUnlistedSitePermission) || isCurrentUserSiteOwner || (UserContext.isUserAppModerator && 'Public'.equalsIgnoreCase(siteObj.Site_Type__c))) && 'Owner'.equalsIgnoreCase(siteRole) == false)){
			peopleWrapObj.canMakeOwner = true;
		}
		return peopleWrapObj;
	}

	/**
     * @description setCanMakeOwner converts the peopledate to listing wrapper
     * @return PeopleListWrapper - fetched people list 
	 * @param peopleWrapObj - people wrapper object
	 * @param convertorArgumentsObj - convertor object
     */
	private Static PeopleListWrapper setCanMakeOwner(PeopleListWrapper peopleWrapObj, ConvertorArgumentsWrapper convertorArgumentsObj){
		Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite = convertorArgumentsObj.mapOfMemberIdAndRoleOfSite;

		if(( (UserContext.hasModifyAllDataPermission && !'Unlisted'.equalsIgnoreCase(SiteContext.currentSiteType) || ('Unlisted'.equalsIgnoreCase(SiteContext.currentSiteType) && UserContext.hasManageUnlistedSitePermission) || (mapOfMemberIdAndRoleOfSite.get(UserContext.id) != null && 'Owner'.equalsIgnoreCase(mapOfMemberIdAndRoleOfSite.get(UserContext.id).role))) && peopleWrapObj.isOwner == false)){
			peopleWrapObj.canMakeOwner = true;
		}
		return peopleWrapObj;
	}

	/**
     * @description ConvertorArgumentsWrapper to support convertToPeopleListWrapper param's
     */
	public class ConvertorArgumentsWrapper {
		public People__c peopleObj;
		public String convertFor;
		public Map<Id, SiteDao.PeopleIdAndSiteRole> mapOfMemberIdAndRoleOfSite;
		public Set<String> mandatorySiteSubscriptionPeopleIdSet;
		public CollaborationGroup collabGroupObj;
		public Simpplr_Site__c siteObj;
        public People_Integration__c pplIntegration;
	}
}