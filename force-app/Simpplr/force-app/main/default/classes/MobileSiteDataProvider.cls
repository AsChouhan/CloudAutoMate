public with sharing class MobileSiteDataProvider {


    
    public static Map<Id, CollaborationGroup> mapOfAllCollaborationGrp{
		get{
			if(mapOfAllCollaborationGrp == null){
				mapOfAllCollaborationGrp = (new MobileSiteDao()).getMapOfAllCollaborationGrp();
			}
	    return mapOfAllCollaborationGrp;
	    
		}
		private set;
	}
    
    public SiteCacheWrapper getSiteForCaching(String siteId) {
		List<SiteCacheWrapper> listOfSiteWrapper = new List<SiteCacheWrapper>();
		String userIdArg = UserContext.id;
		
	    MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
	    Set<Id>siteIdSet = new Set<ID>();
	    siteIdSet.add(siteId);
		Map<Id, Simpplr_Site__c> mapOfSimpplrSite = mblSiteDaoObj.getSitesForCaching(siteIdSet);
		listOfSiteWrapper.addAll(generateListOfSiteCacheWrapper(new List<Simpplr_Site__c>{mapOfSimpplrSite.get(siteId)}, mapOfAllCollaborationGrp));
		
		if(listOfSiteWrapper.isEmpty()){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		return listOfSiteWrapper[0];
    }
    
    public List<Object> getAllFavoriteSites(String textSearch, Integer offset, Integer recordLimit, String categoryId, Boolean isFullModel){
    		MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
    		List<Bookmark__c> bookmarkObjList = mblSiteDaoObj.getAllFavoriteSites(textSearch, offset, recordLimit, categoryId);
    		List<Id>siteIdList = new List<Id>();
    		
		for(Bookmark__c bookMarkRecord : bookmarkObjList){
    			siteIdList.add(bookMarkRecord.Simpplr_Site__c);
		}
		
    		if(isFullModel){
    			List<SiteCacheWrapper> listOfSiteWrapper = new List<SiteCacheWrapper>();
    			Map<Id, Simpplr_Site__c> mapOfSimpplrSite = mblSiteDaoObj.getSitesForCaching(new set<ID>(siteIdList));
				Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = new ObjectToWrapperAdapter().getSiteStats(mapOfSimpplrSite.values());
				for(Bookmark__c bookMarkRecord : bookmarkObjList){
		    		if(mapOfAllCollaborationGrp.containsKey(bookMarkRecord.Simpplr_Site__r.Chatter_Group_Id__c)){
		    			listOfSiteWrapper.add(toSiteCacheWrapper(mapOfSimpplrSite.get(bookMarkRecord.Simpplr_Site__c), mapOfAllCollaborationGrp.get(bookMarkRecord.Simpplr_Site__r.Chatter_Group_Id__c), siteStatsMap.get(bookMarkRecord.Simpplr_Site__c)));
		    		}
		    	}
    	    		return listOfSiteWrapper;
    		}else{
    			return siteIdList;
    		}
    }
    
    public List<Object> getAllFeaturedSites(String textSearch, Integer offset, Integer recordLimit, String categoryId, Boolean isFullModel){
    		MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
    		SiteDao siteDaoObj = new SiteDao();
    		
    		List<SiteCacheWrapper> siteWrapperList = new List<SiteCacheWrapper>();
    		List<Id>siteIdList = new List<Id>();
    		Simpplr_Site__c siteRecord;
    		
    		if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(UserContext.segmentId)){
    			String segmentId = UserContext.segmentId;
    			List<Segment_Site__c> listOfSegmentSite = siteDaoObj.getSitesAllFeaturedSitesForSegments(mapOfAllCollaborationGrp.keySet(), textSearch, 
				offset, recordLimit, categoryId, 'featured', segmentId);
					
			if (!listOfSegmentSite.isEmpty()) {
				if(isFullModel){
					Set<Id>setIdSet = new Set<Id>();
					
					for (Segment_Site__c segmentSiteObj : listOfSegmentSite) {
						setIdSet.add(segmentSiteObj.Site__c);
					}
					Map<Id, Simpplr_Site__c> siteSegmentObjMap = mblSiteDaoObj.getSitesForCaching(setIdSet);
					Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = new ObjectToWrapperAdapter().getSiteStats(siteSegmentObjMap.values());
					for (Segment_Site__c segmentSiteObj : listOfSegmentSite) {
						if(siteSegmentObjMap.containsKey(segmentSiteObj.Site__c)) {
							siteRecord = siteSegmentObjMap.get(segmentSiteObj.Site__c);
							siteWrapperList.add(toSiteCacheWrapper(siteRecord, mapOfAllCollaborationGrp.get(siteRecord.Chatter_Group_Id__c), siteStatsMap.get(siteRecord.Id)));					
						}
					}
					return siteWrapperList;
				}else{
					for (Segment_Site__c segmentSiteObj : listOfSegmentSite) {
						siteIdList.add(segmentSiteObj.Site__c);
					}
					return siteIdList;
				}
			}
			return siteWrapperList;
    		}else{
    			Map<Id, Simpplr_Site__c> siteObjMap = mblSiteDaoObj.getAllFeaturedSites(textSearch, offset, recordLimit, categoryId);
	    		if(isFullModel){
		    		return generateListOfSiteCacheWrapper(siteObjMap.values(), mapOfAllCollaborationGrp);
	    		}else{
	    			return getSiteIDList(siteObjMap.values());
	    		}	
	    	}
    }
    
    public List<Object> getAllLatestSites(String textSearch, Integer offset, Integer recordLimit, String categoryId, Boolean isFullModel){
    		MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
    		List<Simpplr_Site__c> sitObjList = mblSiteDaoObj.getAllLatestSites(textSearch, offset, recordLimit, categoryId);
    		
    		if(isFullModel){
	    		return generateListOfSiteCacheWrapper(sitObjList, mapOfAllCollaborationGrp);
    		}else{
    			return getSiteIDList(sitObjList);
    		}
    }
    
    public List<Object> getAllFollowingSites(String textSearch, Integer offset, Integer recordLimit, String categoryId, Boolean isFullModel){
    		MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
    		List<Simpplr_Site__c> sitObjList = mblSiteDaoObj.getAllFollowingSites(textSearch, offset, recordLimit, categoryId);
    		
    		if(isFullModel){
	    		return generateListOfSiteCacheWrapper(sitObjList, mapOfAllCollaborationGrp);
    		}else{
    			return getSiteIDList(sitObjList);
    		}
    }
    
    public List<Object> getAllSites(String textSearch, Integer offset, Integer recordLimit, String categoryId, Boolean isFullModel){
    		MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
    		List<Simpplr_Site__c> sitObjList = mblSiteDaoObj.getAllSites(textSearch, offset, recordLimit, categoryId);
    		
    		if(isFullModel){
	    		return generateListOfSiteCacheWrapper(sitObjList, mapOfAllCollaborationGrp);
    		}else{
    			return getSiteIDList(sitObjList);
    		}
    }
    
    public List<String> getSiteIDList(List<Simpplr_Site__c> sitObjList){
    		List<String> siteIdList = new List<String>();
		for(Simpplr_Site__c siteObj : sitObjList){
			siteIdList.add(siteObj.id);
		}
		return siteIdList;
    }
    
    public List<SiteCacheWrapper> generateListOfSiteCacheWrapper(List<Simpplr_Site__c> sitObjList, Map<Id, CollaborationGroup> collGrpMap){
		List<SiteCacheWrapper> siteWrapperList = new List<SiteCacheWrapper>();
		Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = new ObjectToWrapperAdapter().getSiteStats(sitObjList);
    	for(Simpplr_Site__c siteRecord : sitObjList){
    		if(collGrpMap != null && collGrpMap.containsKey(siteRecord.Chatter_Group_Id__c)){
    			siteWrapperList.add(toSiteCacheWrapper(siteRecord, collGrpMap.get(siteRecord.Chatter_Group_Id__c), siteStatsMap.get(siteRecord.Id)));
    		}	
    	}
    	return siteWrapperList;
    }
    
    public SiteCacheWrapper toSiteCacheWrapper(Simpplr_Site__c siteObj, CollaborationGroup collGrp,  ObjectToWrapperAdapter.SiteStats siteStatRecord){
    
  		SiteCacheWrapper siteCacheWrapperObj = new SiteCacheWrapper();
    	siteCacheWrapperObj.siteId = siteObj.Id;
    	siteCacheWrapperObj.isActivated = siteObj.Is_Active__c;
    	siteCacheWrapperObj.isDeleted = (siteObj.Is_Deleted__c == null)?false:siteObj.Is_Deleted__c;
    	siteCacheWrapperObj.isShowInSimpplrEnabled = siteObj.Show_In_Simpplr__c;
    	siteCacheWrapperObj.chatterGroupId = siteObj.Chatter_Group_Id__c;
    	siteCacheWrapperObj.name = siteObj.Name;
    	if(SimpplrContext.slackIntegrationEnabled && siteObj.Slack_Url__c != null){
			siteCacheWrapperObj.SlackChannelUrl = siteObj.Slack_Url__c+'messages/'+siteObj.Slack_Channel_Name__c;
			siteCacheWrapperObj.SlackChannelName = siteObj.Slack_Channel_Name__c;
		}
		
    	siteCacheWrapperObj.isPageEnabled = siteObj.Has_Pages__c;
    	siteCacheWrapperObj.isAlbumEnabled = siteObj.Has_Albums__c;
    	siteCacheWrapperObj.isEventEnabled = siteObj.Has_Events__c;
    	siteCacheWrapperObj.isFileEnabled = true;
    	siteCacheWrapperObj.isFeedEnabled = SimpplrContext.isFeedEnabled;
    	siteCacheWrapperObj.isAboutEnabled = true;
	siteCacheWrapperObj.isMandatory = (siteObj.Subscription_Entity_Site__r.isEmpty() == false);
	
    	if(siteObj.Site_Category__c != null){
    		siteCacheWrapperObj.categoryId = siteObj.Site_Category__c;
    		siteCacheWrapperObj.categoryName = siteObj.Site_Category__r.Name__c;
    	}
		siteCacheWrapperObj.name = siteObj.Name;
		siteCacheWrapperObj.memberCount = siteStatRecord.memberCount;
    	siteCacheWrapperObj.IsBroadcast = collGrp.IsBroadcast;
    	siteCacheWrapperObj.about = collGrp.description;
    	if(String.isNotBlank(siteObj.Title_Content_Document__c)){
			siteCacheWrapperObj.contentDocumentId =  siteObj.Title_Content_Document__c;
			siteCacheWrapperObj.imgUrl =  SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +siteObj.Title_Content_Document__c+'/rendition?type=THUMB240BY180';
			siteCacheWrapperObj.imgFile = new FileListingWrapper();
			siteCacheWrapperObj.imgFile.url = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => siteObj.Title_Content_Document__c, 'siteId' => siteObj.id});
			siteCacheWrapperObj.imgFile.downloadUrl = Utility.getFileDownloadURL(siteObj.Title_Content_Version__c);
			siteCacheWrapperObj.imgFile.fileUrl = Utility.getFileDownloadURL(siteObj.Title_Content_Version__c);
			siteCacheWrapperObj.imgFile.id = siteObj.Title_Content_Document__c;
			siteCacheWrapperObj.imgFile.thumbnailImg = Utility.getFileDownloadURLFor240BY180(siteObj.Title_Content_Version__c);
		}
    	if (!collGrp.GroupMembers.isEmpty()) {
			if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteObj.Site_Type__c)){
				siteCacheWrapperObj.isMember = false;
				if(UserContext.mySiteRolesMap.get(siteObj.Id) != null){
					if(UserContext.mySiteRolesMap.get(siteObj.Id) != null && UserContext.mySiteRolesMap.get(siteObj.Id).Is_Member__c == true){
						siteCacheWrapperObj.isMember = true;
					}
				}
			} else {
				siteCacheWrapperObj.isMember = true;	 		
			}
			if ('Admin'.equalsIgnoreCase(collGrp.GroupMembers[0].CollaborationRole)) {
	 			siteCacheWrapperObj.isManager = true;	
	 		} else {
	 			siteCacheWrapperObj.isManager = false;
	 		}	 		
	 	} else {
	 		siteCacheWrapperObj.isMember = false;
	 		siteCacheWrapperObj.isManager = false;
	 	}
    	siteCacheWrapperObj.isAccessRequested = new SiteDao().isAccessRequested(siteObj,collGrp);			
    	siteCacheWrapperObj.isOwner = UserContext.id.equalsIgnoreCase(collGrp.OwnerId);
    	if(siteObj.Bookmarked_Simpplr_Site__r.isEmpty()){
	    	siteCacheWrapperObj.isFavorited = false;
    	} else {
    		siteCacheWrapperObj.isFavorited = true;
    	}
    	if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(UserContext.segmentId)){
		if(siteObj.Site_Segments__r.isEmpty() == false){
			siteCacheWrapperObj.isFeatured = siteObj.Site_Segments__r[0].Is_Featured__c;
		} else {
			siteCacheWrapperObj.isFeatured = false;
		}
	} else {
		siteCacheWrapperObj.isFeatured = siteObj.Is_Featured__c;
	}
    	siteCacheWrapperObj.access = siteObj.Site_Type__c;
    	return siteCacheWrapperObj;
    }
    
    public List<ManageApplicationWrapper.ManageSitesCategoryWrapper> convertToCategorySitesWrapper (List<Site_category__c> listCatObj){
    	List<ManageApplicationWrapper.ManageSitesCategoryWrapper> listResult = new List<ManageApplicationWrapper.ManageSitesCategoryWrapper>();
    	if(listCatObj!=null && listCatObj.size()>0){
    		ManageApplicationWrapper.ManageSitesCategoryWrapper uncategorizedCategory;
    		for(Site_category__c siteCatObj: listCatObj){
    			if(siteCatObj.Simpplr_Sites_Site_Category__r.size() > 0){
	    			ManageApplicationWrapper.ManageSitesCategoryWrapper temp = new ManageApplicationWrapper.ManageSitesCategoryWrapper();
	    			temp.categoryId = siteCatObj.Id;
	    			temp.name = siteCatObj.name__c;
	    			temp.siteCount = siteCatObj.Simpplr_Sites_Site_Category__r.size();
	    			temp.access = siteCatObj.access__c;
	    			
	    			if(ServiceConstants.UNCATEGORIZED_CATEGORY_STR.equalsIgnoreCase(temp.name)) {
	    				temp.isUncategorized = true;
	    			} else {
	    				temp.isUncategorized = false;
	    			}
	    			
	    			listResult.add(temp);
    			}
    		}
    	}
    	return listResult;
    }
    
    public SiteDetailWrapper getsiteDetailData(String siteId) {
		SiteDetailWrapper sdWrapperObj = new SiteDetailWrapper();
		List<Subscription_Entity__c> siteMandatorySubscriptionEntityList = new List<Subscription_Entity__c>();
		siteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSimpplrSite;
		String loggedInPeopleId = UserContext.peopleId;
		if (String.isBlank(siteId)) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		} else {
			listOfSimpplrSite = [select id, name, Landing_Page__c, Chatter_group_id__c, Site_Type__c, Is_Active__c,
					Is_Featured__c,Site_Category__c, Site_Category__r.Name__c, Allow_File_Upload_App_Permission__c,
					Title_Content_Version__c,Title_Content_Document__c,Allow_Public_Contribution__c, Question_Answer_Enabled__c,
					Has_Pages__c,Has_Albums__c,Has_Events__c, Slack_Channel_Name__c, Slack_Url__c, Allow_Comments__c,
					(SELECT Id, Is_Featured__c FROM Site_Segments__r WHERE Segment__c =: UserContext.segmentId),
					(SELECT id FROM Site_Membership_Request__r WHERE Request_By__c=:UserContext.peopleId AND Status__c='Pending'), 
					(SELECT id FROM Subscription_Entity_Site__r WHERE Subscription__r.Action_Type__c = 'mandatory'
						AND Status__c ='Approved' AND Subscription__r.Status__c != 'Deleted' AND 
						(Subscription__r.Audience__r.Segment__c = :UserContext.segmentId OR Subscription__r.Audience__r.Segment__c = null) Limit 1),
					(SELECT id FROM Bookmarked_Simpplr_Site__r WHERE People__c =:loggedInPeopleId AND Simpplr_Site__c=:siteId AND Type__c = 'Site' AND Is_Deleted__c = false),
					(Select Id, People__c, Is_Manager__c, Is_Content_Manager__c, Is_Member__c FROM Site_Roles__r WHERE People__c = :UserContext.peopleId AND Is_Deleted__c = false)
					FROM Simpplr_Site__c WHERE id = :siteId AND Is_Deleted__c = false WITH SECURITY_ENFORCED];

			siteMandatorySubscriptionEntityList = siteDaoObj.getSiteMandatorySubscription(siteId);
						
		}
		if(!listOfSimpplrSite.isEmpty()){ 
			if(listOfSimpplrSite[0].Is_Active__c == false){
				throw new SimpplrException(ServiceConstants.ERROR_404);
		    } else{
		    	CollaborationGroup collabGroup = Utility.getColGroupFromSiteId(listOfSimpplrSite[0].chatter_group_id__c, UserContext.id);
				sdWrapperObj = convertToSiteDetailWrapper(listOfSimpplrSite[0], collabGroup);

				if(!siteMandatorySubscriptionEntityList.isEmpty()){
					sdWrapperObj.isInMandatorySubscription = true;
					sdWrapperObj.isMandatory = true;
				}
			}
		} else {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}	
		return sdWrapperObj;
	}
	
	public SiteDetailWrapper getSiteMembership(String siteId){
		SiteDetailWrapper sdWrapperObj = new SiteDetailWrapper();
		siteDao siteDaoObj = new SiteDao();
		List<Subscription_Entity__c> siteMandatorySubscriptionEntityList = new List<Subscription_Entity__c>();

		List<Simpplr_Site__c> listOfSimpplrSite = [select id, name, chatter_group_id__c,Site_Category__c, Site_Category__r.Name__c, Is_Featured__c, Site_Type__c, Is_Active__c,
													Has_Pages__c,Has_Albums__c,Has_Events__c, Landing_Page__c,
													(SELECT id FROM Site_Membership_Request__r WHERE Request_By__c=:UserContext.peopleId AND Status__c='Pending'), 
													(SELECT Id, Is_Featured__c FROM Site_Segments__r WHERE Segment__c =: UserContext.segmentId),
													(SELECT id FROM Subscription_Entity_Site__r WHERE
													 Subscription__r.Action_Type__c = 'mandatory' AND Status__c ='Approved' AND
													  Subscription__r.Status__c != 'Deleted' AND 
													  (Subscription__r.Audience__r.Segment__c = :UserContext.segmentId OR
													   Subscription__r.Audience__r.Segment__c = null) Limit 1)
													FROM Simpplr_Site__c WHERE id = :siteId AND Is_Deleted__c = false WITH SECURITY_ENFORCED];

		siteMandatorySubscriptionEntityList = siteDaoObj.getSiteMandatorySubscription(siteId);
			
    	String userId = UserContext.id;
    	String collaborationGrpId = listOfSimpplrSite[0].chatter_group_id__c;
		String BASE_QUERY = 'SELECT Id, SmallPhotoUrl, MediumPhotoUrl, FullPhotoUrl, CollaborationType,description,InformationBody, InformationTitle, MemberCount,OwnerId,IsBroadcast, '+
		' (select Id, MemberId,Member.Name, CollaborationRole from GroupMembers where MemberId =: userId  order by CollaborationRole DESC,CreatedDate DESC) '+
		' ,(SELECT RequesterId, status FROM GroupMemberRequests WHERE status =\'Pending\' And RequesterId =:userId order by CreatedDate DESC)  FROM CollaborationGroup where IsArchived=false and Id =:collaborationGrpId';
		if(SimpplrContext.isCommunitiesEnabled){
			BASE_QUERY = BASE_QUERY+' AND NetworkId = null';
		}
		List<CollaborationGroup> collabGrpList = Database.query(BASE_QUERY);
		
		if(collabGrpList.isEmpty()){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		
		sdWrapperObj.siteId = listOfSimpplrSite[0].id;
		if(!siteMandatorySubscriptionEntityList.isEmpty()){
			sdWrapperObj.isInMandatorySubscription = true;
			sdWrapperObj.isMandatory = true;
		}		
	    	
    	if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(UserContext.segmentId)){
			sdWrapperObj.isFeatured = false;
			if(listOfSimpplrSite[0].Site_Segments__r.isEmpty() == false){
				sdWrapperObj.isFeatured = listOfSimpplrSite[0].Site_Segments__r[0].Is_Featured__c;	
			}
			
		} else {
			sdWrapperObj.isFeatured = listOfSimpplrSite[0].Is_Featured__c;
		}
		
		sdWrapperObj.name = listOfSimpplrSite[0].name;
		if(String.isNotBlank(listOfSimpplrSite[0].Site_Category__c)) {
			sdWrapperObj.category = new SiteDetailWrapper.Category();
	 		sdWrapperObj.category.id = listOfSimpplrSite[0].Site_Category__c;
	 		sdWrapperObj.category.name = listOfSimpplrSite[0].Site_Category__r.Name__c;
		}
		sdWrapperObj.isAccessRequested = new SiteDao().isAccessRequested(listOfSimpplrSite[0],collabGrpList[0]);			
		return sdWrapperObj;
	}

	public Map<String, Object> getPrivateSiteStatus(String privateSiteRequestId){
		
		List<CollaborationGroupMemberRequest> groupRequestList = [select id, CollaborationGroupId, status, lastmodifiedDate, requesterId, requester.name from CollaborationGroupMemberRequest where Id =: privateSiteRequestId WITH SECURITY_ENFORCED];
	    
	    Map<String, Object> results = new Map<String, Object>();
		if(!groupRequestList.isEmpty()){
			Set<Id> CollaborationGroupIdSet = new Set<ID>();
			Set<Id>userIdSet = new Set<ID>();
			MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
			MobilePeopleDao mblPeopleDaoObj = new MobilePeopleDao();
			MobilePeopleDataProvider mblPeopleDataProviderObj = new MobilePeopleDataProvider();
			CollaborationGroupIdSet.add(groupRequestList[0].CollaborationGroupId);
			Map<Id, Simpplr_Site__c> siteObjMap = mblSiteDaoObj.getOffsetSiteIdSet(CollaborationGroupIdSet);
			List<Simpplr_Site__c> siteRecordList = siteObjMap.values();
			Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = new ObjectToWrapperAdapter().getSiteStats(siteRecordList);
			userIdSet.add(groupRequestList[0].requesterId);
			Map<Id, People__c> peopleMap = mblPeopleDaoObj.getAllPeopleCaching(userIdSet);
			results.put('site', toSiteCacheWrapper(siteRecordList[0], mapOfAllCollaborationGrp.get(siteRecordList[0].Chatter_Group_Id__c),siteStatsMap.get(siteRecordList[0].Id)));
			results.put('people', mblPeopleDataProviderObj.convertToPeopleCacheWrapper(peopleMap.values().get(0)));
			results.put('status', groupRequestList[0].status.toLowerCase());
			results.put('modifiedAt', groupRequestList[0].lastModifiedDate);
		}		
		return results;
	}
	
	public Map<String, Object> getPublicSiteStatus(String privateSiteRequestId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', privateSiteRequestId);
		String query = 'SELECT Id, lastmodifiedDate, User__c, Request_By__r.Name,  Site__r.Chatter_Group_Id__c, Status__c FROM Site_Membership_Request__c where Id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Membership_Request__c> publicSiteMemRequest = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		Map<String, Object> results = new Map<String, Object>();
		if(!publicSiteMemRequest.isEmpty()){
			Set<Id> CollaborationGroupIdSet = new Set<ID>();
			Set<Id>userIdSet = new Set<ID>();
			MobileSiteDao mblSiteDaoObj = new MobileSiteDao();
			MobilePeopleDao mblPeopleDaoObj = new MobilePeopleDao();
			MobilePeopleDataProvider mblPeopleDataProviderObj = new MobilePeopleDataProvider();
			CollaborationGroupIdSet.add(publicSiteMemRequest[0].Site__r.Chatter_Group_Id__c);
			Map<Id, Simpplr_Site__c> siteObjMap = mblSiteDaoObj.getOffsetSiteIdSet(CollaborationGroupIdSet);
			List<Simpplr_Site__c> siteRecordList = siteObjMap.values();
			Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = new ObjectToWrapperAdapter().getSiteStats(siteRecordList);
			userIdSet.add(publicSiteMemRequest[0].User__c);
			Map<Id, People__c> peopleMap = mblPeopleDaoObj.getAllPeopleCaching(userIdSet);
			results.put('site', toSiteCacheWrapper(siteRecordList[0], mapOfAllCollaborationGrp.get(siteRecordList[0].Chatter_Group_Id__c), siteStatsMap.get(siteRecordList[0].Id)));
			results.put('people', mblPeopleDataProviderObj.convertToPeopleCacheWrapper(peopleMap.values().get(0)));
			results.put('status', publicSiteMemRequest[0].status__c.toLowerCase());
			results.put('modifiedAt', publicSiteMemRequest[0].lastModifiedDate);
		}		
		return results;
	}
	
	@testVisible
	private SiteDetailWrapper convertToSiteDetailWrapper(Simpplr_Site__c siteObj, CollaborationGroup collabGroup) {
		SiteDetailWrapper sdWrapperObj = new SiteDetailWrapper();
		sdWrapperObj.id = siteObj.id;//TBR
		sdWrapperObj.siteId = siteObj.id;
		sdWrapperObj.chatterGroupId = siteObj.chatter_group_id__c;
		sdWrapperObj.title = siteObj.name;//TBR
		sdWrapperObj.name = siteObj.name;
		sdWrapperObj.access = siteObj.Site_Type__c;
		sdWrapperObj.about = collabGroup.description;
		sdWrapperObj.description = collabGroup.description;//TBR
		sdWrapperObj.information = collabGroup.InformationBody;
		sdWrapperObj.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteObj.Site_Type__c) ? true : false;//TBR
		sdWrapperObj.isListed = ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteObj.Site_Type__c) ? false : true;//TBR
		sdWrapperObj.hasEvents = siteObj.Has_Events__c;//TBR
		sdWrapperObj.hasPages = siteObj.Has_Pages__c;//TBR
		sdWrapperObj.hasAlbums = siteObj.Has_Albums__c;//TBR
		sdWrapperObj.isContentFeedEnabled = siteObj.Allow_Comments__c;//TBR
			
		sdWrapperObj.isQuestionAnswerEnabled = siteObj.Question_Answer_Enabled__c;
		sdWrapperObj.landingPage = siteObj.Landing_Page__c;
		sdWrapperObj.IsBroadcast = collabGroup.IsBroadcast;
		sdWrapperObj.isActive = siteObj.Is_Active__c;
		sdWrapperObj.isFavorited = siteObj.Bookmarked_Simpplr_Site__r.isEmpty()?false:true;
		sdWrapperObj.isInMandatorySubscription = (siteObj.Subscription_Entity_Site__r.isEmpty() == false);
		sdWrapperObj.isMandatory = (siteObj.Subscription_Entity_Site__r.isEmpty() == false);
				
		if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(UserContext.segmentId)){
			sdWrapperObj.isFeatured = false;
			if(siteObj.Site_Segments__r.isEmpty() == false){
				sdWrapperObj.isFeatured = siteObj.Site_Segments__r[0].Is_Featured__c;
			}
		} else {
			sdWrapperObj.isFeatured = siteObj.Is_Featured__c;
		}
			
		sdWrapperObj.isOwner = UserContext.id.equalsIgnoreCase(collabGroup.OwnerId);
			
		if(String.isNotBlank(siteObj.Site_Category__c)) {
			sdWrapperObj.category = new SiteDetailWrapper.Category();
			sdWrapperObj.category.id = siteObj.Site_Category__c;
			sdWrapperObj.category.name = siteObj.Site_Category__r.Name__c;
		}
		if(String.isNotBlank(siteObj.Title_Content_Document__c)) {
			sdWrapperObj.imgTHUMB240BY180URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +siteObj.Title_Content_Document__c+'/rendition?type=THUMB240BY180';
			sdWrapperObj.imgTHUMB720BY480URL = SimpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +siteObj.Title_Content_Document__c+'/rendition?type=THUMB720BY480';
			sdWrapperObj.imgFullURL = SImpplrContext.salesforceHost + ServiceConstants.FILE_CONNECT_API_SUB_URL +siteObj.Title_Content_Document__c+'/content';
		}
		sdWrapperObj.isAccessRequested = new SiteDao().isAccessRequested(siteObj,collabGroup);			
	
		if(siteObj.Slack_Url__c != null && SimpplrContext.slackIntegrationEnabled){
			sdWrapperObj.slack = new SiteDetailWrapper.slack();
			sdWrapperObj.slack.url = siteObj.Slack_Url__c+'messages/'+siteObj.Slack_Channel_Name__c;
			sdWrapperObj.slack.name = siteObj.Slack_Channel_Name__c;
		}
		sdWrapperObj.isManager = false;
		sdWrapperObj.isMember = false;
		sdWrapperObj.isFollower = false;
		if (String.isNotBlank(siteObj.id) && (UserContext.sitesIManageIdSet.contains(siteObj.id) || UserContext.groupsIManageMap.keySet().contains(siteObj.id) || UserContext.sitesIManageContentsMap.keySet().contains(siteObj.id))){
			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_ALL_SITES.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
				sdWrapperObj.canUploadAllFileTypes =  true;
			} else if (ServiceConstants.ALLOW_FILE_UPLOAD_AS_All_USER.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
				sdWrapperObj.canUploadAllFileTypes =  false;
			} else if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)){
				sdWrapperObj.canUploadAllFileTypes = siteObj.Allow_File_Upload_App_Permission__c;
			}
		}else{
			sdWrapperObj.canUploadAllFileTypes = false;
		}

		// current-user role in site
		sdWrapperObj.isManager = false;
		sdWrapperObj.isContentManager = false;
		sdWrapperObj.isMember = false;
		sdWrapperObj.isFollower = false;

		if(!siteObj.Site_Roles__r.isEmpty()) {
			if(siteObj.Site_Roles__r[0].Is_Manager__c) {
				sdWrapperObj.isManager = true;
			} else if(siteObj.Site_Roles__r[0].Is_Content_Manager__c) {
				sdWrapperObj.isContentManager = true;
			} else if(siteObj.Site_Roles__r[0].Is_Member__c) {
				sdWrapperObj.isMember = true;
			} else {
				sdWrapperObj.isFollower = true;
			}
		}
		
		SiteDao siteDaoObj = new SiteDao();
		sdWrapperObj.managerCount = siteDaoObj.getSiteManagerCount(siteObj.id, null); // do not pass search-term(2nd param), As will break in EAR
		sdWrapperObj.memberCount = siteDaoObj.getSiteMemberCount(siteObj.id, null); // do not pass search-term(2nd param), As will break in EAR
		sdWrapperObj.memberCount -= sdWrapperObj.managerCount;
		sdWrapperObj.members = sdWrapperObj.memberCount;
		sdWrapperObj.followerCount = siteDaoObj.getSiteFollowerCount(siteObj.id, null); // do not pass search-term(2nd param), As will break in EAR

		sdWrapperObj.managerList = siteDaoObj.getSiteManagerList(siteObj.id);
		sdWrapperObj.memberList = siteDaoObj.getSiteMemberList(siteObj.id);
		sdWrapperObj.followerList = siteDaoObj.getSiteFollowerList(siteObj.id);
		
		sdWrapperObj.owner = siteDaoObj.getSiteOwner(collabGroup.OwnerId);

		Map<String, People__c> userIdToPeopleMap = new Map<String, People__c>();

		return sdWrapperObj;
	}
    
}