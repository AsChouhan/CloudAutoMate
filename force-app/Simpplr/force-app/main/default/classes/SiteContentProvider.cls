public with sharing class SiteContentProvider {

	private ObjectToWrapperAdapter objectToWrapperAdapterObj = new ObjectToWrapperAdapter(); 

    public List<SiteListWrapper> getSitesAllSites(Criteria.Site siteCriteriaObjArg) {
    		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
    		Integer recordLimit = siteCriteriaObjArg.size + 1;
    		SiteDao siteDaoObj = new SiteDao();
    		Map<Id,CollaborationGroup> mapOfAllCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(UserContext.id);
            Set<Id> setOfCollGroupId = new Set<Id>();
            if(siteCriteriaObjArg.canSubmitQuestion){
                for(Id id: mapOfAllCollaborationGrp.keySet()){
                    CollaborationGroup cgObj = mapOfAllCollaborationGrp.get(id);
                    if ('Private'.equalsIgnoreCase(cgObj.CollaborationType) && cgObj.GroupMembers.size() > 0 && cgObj.GroupMembers.get(0).MemberId.equals(UserContext.id)){
                        setOfCollGroupId.add(cgObj.Id);
                    } else if (!'Private'.equalsIgnoreCase(cgObj.CollaborationType)){
                        setOfCollGroupId.add(cgObj.Id);
					}
				} 
			}else{
				setOfCollGroupId.addAll(mapOfAllCollaborationGrp.keySet());
			}
    		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSitesAllSites(setOfCollGroupId, siteCriteriaObjArg.term, 
					siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category,siteCriteriaObjArg.sortBy,siteCriteriaObjArg.isPrivate, siteCriteriaObjArg.canSubmitQuestion);
    		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfAllCollaborationGrp));
			
			if(listOfSiteWrapper!=null && listOfSiteWrapper.size()>0 && siteCriteriaObjArg.filter!=null && 'canCreatePage'.equalsIgnoreCase(siteCriteriaObjArg.filter)){
				for (Integer i = (listOfSiteWrapper.size()-1) ; i>= 0 ; i--){
					if(!listOfSiteWrapper[i].canCreatePage){
						listOfSiteWrapper.remove(i);
					}
				} 
			}

		return 	listOfSiteWrapper;
    		
    } 
     
    public  List<SiteListWrapper> getAvailableSitesForNewsLetter(String searchTerm) {
        List<SiteListWrapper> listOfNewsletterEnabledSitesIManage = new List<SiteListWrapper>();
		Map<Id, CollaborationGroup> listedCGIManageMap = getListedCollabGrpIManageMap(UserContext.canSendNewsletter);
		Set<Id> listedCGIManageSet = listedCGIManageMap.keySet();
		SiteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getAvailableSitesForNewsLetter(searchTerm, listedCGIManageSet);
		listOfNewsletterEnabledSitesIManage.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, listedCGIManageMap));
        return listOfNewsletterEnabledSitesIManage;
	}
    
    public  List<SiteListWrapper> getAvailableSitesForAlert(Criteria.Site siteCriteriaObjArg) {
		String searchTerm = siteCriteriaObjArg.term;
		Integer offset = 0;
		if (siteCriteriaObjArg.nextPageToken == null) {
				offset = 0;	
		} else {
				offset = Integer.valueOf(siteCriteriaObjArg.nextPageToken);
		}
		Integer recordLimit = siteCriteriaObjArg.size != null ? siteCriteriaObjArg.size + 1 : SimpplrContext.simpplrDefaultPageSize + 1;


        List<SiteListWrapper> listOfAlertEnabledSitesIManage = new List<SiteListWrapper>();
		Map<Id, CollaborationGroup> listedCGIManageMap = getListedCollabGrpIManageMap(UserContext.canSendAlerts);
		Set<Id> listedCGIManageSet = listedCGIManageMap.keySet();
		SiteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getAvailableSitesForAlert(searchTerm, listedCGIManageSet, recordLimit, offset);
        listOfAlertEnabledSitesIManage.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, listedCGIManageMap));
        return listOfAlertEnabledSitesIManage;
    }
    
    private static Map<Id,CollaborationGroup> getListedCollabGrpIManageMap(Boolean hasAccess){
    	String userId = UserContext.Id;
    	String CG_BASE_QUERY = 'SELECT Id, SmallPhotoUrl,CollaborationType,description,InformationTitle,IsBroadcast, InformationBody,MemberCount,OwnerId, '+
    	                    '(SELECT Id,CollaborationRole FROM GroupMembers WHERE memberId=:userId AND CollaborationRole = \'Admin\') '+
    	                    'FROM CollaborationGroup where IsArchived=false ';
    	List<CollaborationGroupMember> memberList;
    	Set<Id> cgGrpIdSet = new Set<Id>();
    	String unlistedCondition = '';
    	if(UserContext.hasManageUnlistedSitePermission) {
    		unlistedCondition += ' OR Collaborationtype = \'Unlisted\'';
    	}
    	if(UserContext.hasModifyAllDataPermission){
    		
    	} else if(UserContext.isUserAppModerator || hasAccess) {
    		memberList = [SELECT Id,CollaborationRole,CollaborationGroupId FROM CollaborationGroupMember 
    												WHERE memberId=:userId AND CollaborationRole = 'Admin' WITH SECURITY_ENFORCED];
    		for(CollaborationGroupMember cgMember :memberList){
				cgGrpIdSet.add(cgMember.CollaborationGroupId);
			}
    		CG_BASE_QUERY = CG_BASE_QUERY + ' AND (Id IN:cgGrpIdSet OR CollaborationType =\'Public\''+unlistedCondition+')';
    	} else {
    		memberList = [SELECT Id,CollaborationRole,CollaborationGroupId FROM CollaborationGroupMember 
    												WHERE memberId=:userId AND CollaborationRole = 'Admin' WITH SECURITY_ENFORCED];
    		for(CollaborationGroupMember cgMember :memberList){
				cgGrpIdSet.add(cgMember.CollaborationGroupId);
			}
    		CG_BASE_QUERY = CG_BASE_QUERY + ' AND (Id IN:cgGrpIdSet'+unlistedCondition+')';
    	}
    	
		if(SimpplrContext.isCommunitiesEnabled){
			CG_BASE_QUERY = CG_BASE_QUERY+' AND NetworkId = null';
		}
		Map<Id,CollaborationGroup> collabGrpMap = new Map<Id,CollaborationGroup>((List<CollaborationGroup>)Database.query(CG_BASE_QUERY));
		return collabGrpMap;
    }
    
    public  List<SiteListWrapper> searchSitesForAnalytics(String searchTerm) {
    	List<SiteListWrapper> siteListForAnalytics = new List<SiteListWrapper>();
		Map<Id,Simpplr_Site__c> sitesIManageMap =  UserContext.sitesIManageMap;
		
		if(UserContext.canAccessAnalytics || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission){
    		sitesIManageMap.putAll(Utility.getAllSimpplrSiteMap());
		}
		Set<Id> siteIManageIdSet = sitesIManageMap.keyset();
		SiteDao siteDaoObj = new SiteDao(); 
		List<Simpplr_Site__c> listOfSites = siteDaoObj.searchSitesForAnalytics(searchTerm, siteIManageIdSet);
		List<Id> chatterGroupIdList = new List<Id>();
        for (Simpplr_Site__c siteObj : listOfSites ) {
        	chatterGroupIdList.add(siteObj.Chatter_Group_Id__c);
        }
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = Utility.getAllCollaborationGroupMapForSiteIds(chatterGroupIdList);	
        siteListForAnalytics.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSites, mapOfIdWithCollaborationGrp));
    	return siteListForAnalytics;
    }
    
    public  List<SiteListWrapper> searchListedSites(String searchTerm) {
		List<SiteListWrapper> listedSiteList = new List<SiteListWrapper>();
			
		Map<Id, String> groupIdAndSmallPhotoUrlMap = new Map<Id, String>();
		String currentUserId = UserContext.id;
		List<CollaborationGroup> listOfcollaborationGroup = new List<CollaborationGroup>();
		
		String colGrpTypePrivate = ServiceConstants.PRIVATE_SITE;
		String colGrpTypePublic = ServiceConstants.PUBLIC_SITE;
		String colGrpTypeUnlisted = ServiceConstants.UNLISTED_SITE;
		
		String BASE_QUERY_CG = 'Select Id,smallPhotoUrl FROM CollaborationGroup WHERE isArchived=false AND CollaborationType!=:colGrpTypeUnlisted AND CollaborationGroup.Name Like: searchTerm ';
		
		if (SimpplrContext.isCommunitiesEnabled) {
    		BASE_QUERY_CG = BASE_QUERY_CG+' AND NetworkId = null';
    	} 
    	
		listOfcollaborationGroup = Database.query(BASE_QUERY_CG);
		// Creating smallphotoUrl Map
		for (CollaborationGroup colGrpObj : listOfcollaborationGroup) {
			groupIdAndSmallPhotoUrlMap.put(colGrpObj.Id, colGrpObj.SmallPhotoUrl);
		}
		SiteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSites = siteDaoObj.searchListedSites(searchTerm, groupIdAndSmallPhotoUrlMap.keySet());
    	List<Id> chatterGroupIdList = new List<Id>();
    	for (Simpplr_Site__c siteObj : listOfSites ) {
	    	chatterGroupIdList.add(siteObj.Chatter_Group_Id__c);
	    }
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = Utility.getAllCollaborationGroupMapForSiteIds(chatterGroupIdList);	
	    listedSiteList.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSites, mapOfIdWithCollaborationGrp));
    	return listedSiteList;
    }
    
    public List<SiteListWrapper> getSitesCanSubmitContent(String searchTerm, Boolean canSubmitQuestion) {
		List<SiteListWrapper> contentSubmissionSiteList = new List<SiteListWrapper>();
		List<Simpplr_Site__c> listOfAllTypeSite = new  List<Simpplr_Site__c>();
        SiteDao siteDaoObj = new SiteDao(); 
        Map<Id,CollaborationGroup> mapOfAllCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(UserContext.id);
        List<Id> listOfCollGroupId = new List<Id> ();
        List<Simpplr_Site__c> listOfSiteFinal = new List<Simpplr_Site__c>();  
        Integer siteToReturnCount = 0;
        Set<Id> setOfIdToExclude = new Set<Id>();
        Set<Id> setOfCollGroupId = new Set<Id>();
        for(Id id: mapOfAllCollaborationGrp.keySet()){
            CollaborationGroup cgObj = mapOfAllCollaborationGrp.get(id);
            if ('Private'.equalsIgnoreCase(cgObj.CollaborationType) && cgObj.GroupMembers.size() > 0 && cgObj.GroupMembers.get(0).MemberId.equals(UserContext.id)){
                setOfCollGroupId.add(cgObj.Id);
            } else if (!'Private'.equalsIgnoreCase(cgObj.CollaborationType)){
                setOfCollGroupId.add(cgObj.Id);
            }
        }

        //1. Recent sites
        listOfAllTypeSite.addAll(siteDaoObj.getRecentUsedSites(8, canSubmitQuestion));
        
        //2.Sites I can manage 
        if (!listOfAllTypeSite.isEmpty()) {

            for (Simpplr_Site__c siteObj: listOfAllTypeSite) {
                setOfIdToExclude.add(siteObj.id);
            }

        }

        Criteria.Site siteCriteriaObjImanage = new Criteria.Site();
        siteCriteriaObjImanage.filter = 'active';
        siteCriteriaObjImanage.size = 8;
        siteCriteriaObjImanage.term = searchTerm;
        siteCriteriaObjImanage.setOfIdToExclude = setOfIdToExclude; 
        siteCriteriaObjImanage.canSubmitQuestion = canSubmitQuestion;
        listOfAllTypeSite.addAll(siteDaoObj.getSitesSearchResults(siteCriteriaObjImanage));
	    siteToReturnCount = siteToReturnCount + listOfAllTypeSite.size();
        
        if (siteToReturnCount == 16) {

            for (Simpplr_Site__c simpplrSiteObj: listOfAllTypeSite) {
                listOfSiteFinal.add(simpplrSiteObj);
			}

		    contentSubmissionSiteList.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSiteFinal, mapOfAllCollaborationGrp));
            return contentSubmissionSiteList;
        }

         //3. Featured site 
        if (!listOfAllTypeSite.isEmpty()) {
            setOfIdToExclude = new Set<Id>();

            for (Simpplr_Site__c siteObj: listOfAllTypeSite) {
                setOfIdToExclude.add(siteObj.id);
            }

        } 

        Criteria.Site siteCriteriaObjFeatured = new Criteria.Site();
        siteCriteriaObjFeatured.filter = 'featured';
        siteCriteriaObjFeatured.sortBy = 'featured';
        siteCriteriaObjFeatured.size = 8;
        siteCriteriaObjFeatured.offset = 0;
        siteCriteriaObjFeatured.term = searchTerm;
        siteCriteriaObjFeatured.setOfIdToExclude = setOfIdToExclude; 
        siteCriteriaObjFeatured.canSubmitQuestion = canSubmitQuestion; 
        siteCriteriaObjFeatured.setOfCollGroupId = setOfCollGroupId; 

        if (SimpplrContext.isSegmentsEnabled) {
            siteCriteriaObjFeatured.segmentId = UserContext.segmentId; 
            List<Segment_Site__c> listOfSegmentSite = siteDaoObj.getSitesAllFeaturedSitesForSegments((canSubmitQuestion == true ? setOfCollGroupId : mapOfAllCollaborationGrp.keySet()), 
                    siteCriteriaObjFeatured.term, 
                    siteCriteriaObjFeatured.offset, siteCriteriaObjFeatured.size, 
                    siteCriteriaObjFeatured.category, 
                    siteCriteriaObjFeatured.sortBy, siteCriteriaObjFeatured.segmentId);
            Map<String, String> mapOfSiteIdAndChatterGroupId = new Map<String, String>();
            
            if (!listOfSegmentSite.isEmpty()) {
                
                for (Segment_Site__c segmentSiteObj : listOfSegmentSite) {
                    
                    if (!setOfIdToExclude.contains(segmentSiteObj.Site__c)) {
                        mapOfSiteIdAndChatterGroupId.put(segmentSiteObj.Site__c, 
                                segmentSiteObj.Site__r.Chatter_Group_Id__c);
                    }
                    
                }
                
                Map<Id, Simpplr_Site__c> mapOfIdWithSimpplrSite = siteDaoObj.getSites(siteCriteriaObjFeatured.segmentId, 
                        mapOfSiteIdAndChatterGroupId.keySet());
                List<Simpplr_Site__c> listOfSortedSites = new List<Simpplr_Site__c>();
                
                for (Segment_Site__c segmentSiteObj : listOfSegmentSite) {
                    
                    if (mapOfIdWithSimpplrSite.containsKey(segmentSiteObj.Site__c)) {
                        listOfSortedSites.add(mapOfIdWithSimpplrSite.get(segmentSiteObj.Site__c));
                    }

                }
                
                listOfAllTypeSite.addAll(listOfSortedSites);
            }

    					
        } else {
            listOfAllTypeSite.addAll(siteDaoObj.getSitesAllFeaturedSites(siteCriteriaObjFeatured));
        }

        siteToReturnCount = listOfAllTypeSite.size();

        if (siteToReturnCount >= 16) {

            for (Simpplr_Site__c simpplrSiteObj: listOfAllTypeSite) {
                
                if (16 == listOfSiteFinal.size()) {
                    break;
                }

                listOfSiteFinal.add(simpplrSiteObj);
			}

           
		    contentSubmissionSiteList.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSiteFinal, mapOfAllCollaborationGrp));
            return contentSubmissionSiteList;
        } 

        //4. All site list 
        if (!listOfAllTypeSite.isEmpty()) {
            setOfIdToExclude = new Set<Id>();

            for (Simpplr_Site__c siteObj: listOfAllTypeSite) {
                setOfIdToExclude.add(siteObj.id);
            }

        } 
        
        Criteria.Site siteCriteriaObjAllSite = new Criteria.Site();
        siteCriteriaObjAllSite.sortBy = 'createdNewest';
        siteCriteriaObjAllSite.size = 16;
        siteCriteriaObjAllSite.offset = 0;
        siteCriteriaObjAllSite.term = searchTerm;
        siteCriteriaObjAllSite.setOfIdToExclude = setOfIdToExclude; 
        siteCriteriaObjAllSite.canSubmitQuestion = canSubmitQuestion; 

        listOfAllTypeSite.addAll(siteDaoObj.getSitesAllSites(setOfCollGroupId, 
                siteCriteriaObjAllSite));
        
		if (!listOfAllTypeSite.isEmpty()) {

			for (Simpplr_Site__c simpplrSiteObj : listOfAllTypeSite) {

                if (16 == listOfSiteFinal.size()) {
                    break;
                }

                listOfSiteFinal.add(simpplrSiteObj);
			}
			
		}
		
		contentSubmissionSiteList.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSiteFinal, mapOfAllCollaborationGrp));
		return contentSubmissionSiteList;
    }
    
    public List<SiteListWrapper> getSitesCanBeMentionedInFeed(String searchTerm) {
		List<SiteListWrapper> mentionableSiteList = new List<SiteListWrapper>();
    	SiteDao siteDaoObj = new SiteDao();
    	List<Simpplr_Site__c> listOfSites = siteDaoObj.getSitesCanBeMentionedInFeed(searchTerm);
		List<Id> chatterGroupIdList = new List<Id>();
        for (Simpplr_Site__c siteObj : listOfSites ) {
        	chatterGroupIdList.add(siteObj.Chatter_Group_Id__c);
        }
        Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = Utility.getAllCollaborationGroupMapForSiteIds(chatterGroupIdList);
		mentionableSiteList.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSites, mapOfIdWithCollaborationGrp));
		return mentionableSiteList;
    }
    
    public List<SiteListWrapper> getSitesAllFeaturedSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		SiteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSitesAllFeaturedSites(siteCriteriaObjArg.term, 
				0, 2000, siteCriteriaObjArg.category,siteCriteriaObjArg.sortBy);
				
		List<Id> listOfCollGroupId = new List<Id> ();
		
		if (!listOfSimpplrSite.isEmpty()) {
			
			for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSite) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
			
		}
		
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp;
		mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollGroupId, UserContext.id);
		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrp));
		
		List<SiteListWrapper> finalListOfSites = new List<SiteListWrapper>();
		Integer total = listOfSiteWrapper.size();
		Integer offset = siteCriteriaObjArg.offset;
		Integer endIndex =   siteCriteriaObjArg.offset + siteCriteriaObjArg.size;
		endIndex = (endIndex >= total)? total - 1 :endIndex;
		for(Integer x = offset; x<= endIndex; x++){
			finalListOfSites.add(listOfSiteWrapper[x]);
		}
		return 	finalListOfSites;
    		
    }
    
    public List<SiteListWrapper> getSitesAllFeaturedSitesForSegments(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		SiteDao siteDaoObj = new SiteDao();
		Map<Id,CollaborationGroup> mapOfAllCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(UserContext.id);
		String segmentId = String.isBlank(siteCriteriaObjArg.segmentId) ? UserContext.segmentId : siteCriteriaObjArg.segmentId;
		
		List<Segment_Site__c> listOfSegmentSite = siteDaoObj.getSitesAllFeaturedSitesForSegments(mapOfAllCollaborationGrp.keySet(), siteCriteriaObjArg.term, 
				siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category,siteCriteriaObjArg.sortBy, segmentId);
		Map<String, String> mapOfSiteIdAndChatterGroupId = new Map<String, String>();
		
		if (!listOfSegmentSite.isEmpty()) {
			
			for (Segment_Site__c segmentSiteObj : listOfSegmentSite) {
				mapOfSiteIdAndChatterGroupId.put(segmentSiteObj.Site__c, segmentSiteObj.Site__r.Chatter_Group_Id__c);
			}
			
			Map<Id, Simpplr_Site__c> mapOfIdWithSimpplrSite = siteDaoObj.getSites(segmentId, mapOfSiteIdAndChatterGroupId.keySet());
			List<Simpplr_Site__c> listOfSortedSites = new List<Simpplr_Site__c>();
			for(Segment_Site__c segmentSiteObj : listOfSegmentSite) {
				if(mapOfIdWithSimpplrSite.containsKey(segmentSiteObj.Site__c)) {
					listOfSortedSites.add(mapOfIdWithSimpplrSite.get(segmentSiteObj.Site__c));
				}
			}
			listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSortedSites, mapOfAllCollaborationGrp));
		}
		return listOfSiteWrapper;
    		
    } 
    
    public List<SiteListWrapper> getSitesAllFavoriteSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		SiteDao siteDaoObj = new SiteDao();
		Map<Id,CollaborationGroup> mapOfAllCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(UserContext.id);
		List<Bookmark__c> listOfBookmarks = siteDaoObj.getSitesAllFavoriteSites(mapOfAllCollaborationGrp.keySet(), siteCriteriaObjArg.term, 
				siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category,siteCriteriaObjArg.sortBy);
				
		Map<String, String> mapOfSiteIdAndChatterGroupId = new Map<String, String>();
		
		if (!listOfBookmarks.isEmpty()) {
			
			for (Bookmark__c bookmarkObj : listOfBookmarks) {
				mapOfSiteIdAndChatterGroupId.put(bookmarkObj.Simpplr_Site__c, bookmarkObj.Simpplr_Site__r.Chatter_Group_Id__c);
			}
			
			Map<Id, Simpplr_Site__c> mapOfIdWithSimpplrSite = siteDaoObj.getSites(mapOfSiteIdAndChatterGroupId.keySet());
			List<Simpplr_Site__c> listOfSortedSites = new List<Simpplr_Site__c>();
			for(Bookmark__c bookmarkObj : listOfBookmarks) {
				if(mapOfIdWithSimpplrSite.containsKey(bookmarkObj.Simpplr_Site__c)) {
					listOfSortedSites.add(mapOfIdWithSimpplrSite.get(bookmarkObj.Simpplr_Site__c));
				}
			}
			listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSortedSites, mapOfAllCollaborationGrp));
		}
		return listOfSiteWrapper;
    		
    }
    
    public List<SiteListWrapper> getSitesAllPopularSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		SiteDao siteDaoObj = new SiteDao();
		Map<Id,CollaborationGroup> mapOfAllCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(UserContext.id);
		Map<String, String> mapOfSiteIdAndChatterGroupId = siteDaoObj.getSitesAllPopularSites(mapOfAllCollaborationGrp.keySet(), 
				siteCriteriaObjArg.offset, recordLimit);
		
		if (!mapOfSiteIdAndChatterGroupId.isEmpty()) {
			
			Map<Id, Simpplr_Site__c> mapOfIdWithSimpplrSite = siteDaoObj.getSites(mapOfSiteIdAndChatterGroupId.keySet());
			Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = objectToWrapperAdapterObj.getSiteStats(mapOfIdWithSimpplrSite.values());
			for(String siteId : mapOfSiteIdAndChatterGroupId.keySet()) {
				Simpplr_Site__c siteObj = mapOfIdWithSimpplrSite.get(siteId);
				if(siteObj != null) {
					listOfSiteWrapper.add(objectToWrapperAdapterObj.toSiteListWrapper(siteObj, mapOfAllCollaborationGrp.get(siteObj.chatter_group_id__c), siteStatsMap.get(siteObj.Id)));
				}
			}
		}
		return 	listOfSiteWrapper;
    		
    }
    
    public List<SiteListWrapper> getSitesAllFollowingSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		List<CollaborationGroupMember> listOfCollaborationGrpMem;
		SiteDao siteDaoObj = new SiteDao();
		// list of CollaborationGroupMember records where show in simpplr is true for current user
		listOfCollaborationGrpMem = siteDaoObj.getGrpMembrForSitesShowingInSimpplr(UserContext.id);
		List<Id> listOfCollabGrpId = new List<Id>();
		
		for (CollaborationGroupMember grpMemberObj : listOfCollaborationGrpMem) {
			listOfCollabGrpId.add(grpMemberObj.CollaborationGroupId);
		}
		
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp;
		mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollabGrpId,
				UserContext.id);
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSitesAllFollowingSites(siteCriteriaObjArg.term, 
				siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category, listOfCollabGrpId,siteCriteriaObjArg.sortBy);		
		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrp));	
		return listOfSiteWrapper;
    		
	}

	public List<SiteListWrapper> getAllSitesBelongsAsFollower(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		SiteDao siteDaoObj = new SiteDao();
		List<Site_Role__c> siteRoleList = new List<Site_Role__c>();
		if(siteCriteriaObjArg.peopleId != null) {
			siteRoleList = [Select id, site__c, is_Member__c, people__c, site__r.Chatter_Group_Id__c from Site_Role__c where is_Member__c = false And Is_Manager__c = false and Is_Content_Manager__c = false and people__c =: siteCriteriaObjArg.peopleId and is_Deleted__c = false WITH SECURITY_ENFORCED];
		} else {
			People__c peopleObj = [Select Id From People__c Where User__c =:UserContext.Id];
			siteRoleList = [Select id, site__c, is_Member__c, people__c, site__r.Chatter_Group_Id__c from Site_Role__c where is_Member__c = false And Is_Manager__c = false and Is_Content_Manager__c = false and people__c =: peopleObj.id and is_Deleted__c = false WITH SECURITY_ENFORCED];
		}
		
		Set<String> siteIds = new set<String>();
		Set<String> collaborationGroupIds = new Set<String>();
		for (Site_Role__c siteRole: siteRoleList){
			siteIds.add(siteRole.site__c);
			collaborationGroupIds.add(siteRole.site__r.chatter_Group_id__c);
		}
		List<String> listOfCollabGrpId = new List<String>();
		listOfCollabGrpId.addAll(collaborationGroupIds);
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp;
		mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollabGrpId, UserContext.id);

		Integer recordLimit = siteCriteriaObjArg.size + 1;
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSitesAllFollowingSites(siteCriteriaObjArg.term, 
						siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category, listOfCollabGrpId,siteCriteriaObjArg.sortBy);		
		
		Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = objectToWrapperAdapterObj.getSiteStats(listOfSimpplrSite);
		for(Simpplr_Site__c siteRecord : listOfSimpplrSite){
			if (mapOfIdWithCollaborationGrp.containskey(siteRecord.Chatter_Group_Id__c)){
				listOfSiteWrapper.add(objectToWrapperAdapterObj.toSiteListWrapper(siteRecord, mapOfIdWithCollaborationGrp.get(siteRecord.Chatter_Group_Id__c),siteStatsMap.get(siteRecord.id)));	
			}
		}
		return listOfSiteWrapper;
    		
	}
	
	public List<SiteListWrapper> getAllSitesBelongsAsMember(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		SiteDao siteDaoObj = new SiteDao();
		List<Site_Role__c> siteRoleList = new List<Site_Role__c>();
		String packageName = SimpplrContext.packageName;
		if(siteCriteriaObjArg.peopleId != null) {
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				siteRoleList = [Select id, site__c, is_Member__c, people__c, site__r.Chatter_Group_Id__c from Site_Role__c where (is_Member__c = true OR Is_Manager__c = true OR Is_Content_Manager__c = true) and people__c =: siteCriteriaObjArg.peopleId and is_Deleted__c = false
								AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) WITH SECURITY_ENFORCED];
			} else {
				siteRoleList = [Select id, site__c, is_Member__c, people__c, site__r.Chatter_Group_Id__c from Site_Role__c where (is_Member__c = true OR Is_Manager__c = true OR Is_Content_Manager__c = true) and people__c =: siteCriteriaObjArg.peopleId and is_Deleted__c = false WITH SECURITY_ENFORCED];
			}
		} else {
			People__c peopleObj = [Select Id From People__c Where User__c =:UserContext.Id];
			if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				siteRoleList = [Select id, site__c, is_Member__c, people__c, site__r.Chatter_Group_Id__c from Site_Role__c where (is_Member__c = true OR Is_Manager__c = true OR Is_Content_Manager__c = true) and people__c =: peopleObj.id and is_Deleted__c = false
								AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName) WITH SECURITY_ENFORCED];
			} else {
				siteRoleList = [Select id, site__c, is_Member__c, people__c, site__r.Chatter_Group_Id__c from Site_Role__c where (is_Member__c = true OR Is_Manager__c = true OR Is_Content_Manager__c = true) and people__c =: peopleObj.id and is_Deleted__c = false WITH SECURITY_ENFORCED];
			}
		}
		
		Set<String> siteIds = new set<String>();
		Set<String> collaborationGroupIds = new Set<String>();
		for (Site_Role__c siteRole: siteRoleList){
			siteIds.add(siteRole.site__c);
			collaborationGroupIds.add(siteRole.site__r.chatter_Group_id__c);
		}
		List<String> listOfCollabGrpId = new List<String>();
		listOfCollabGrpId.addAll(collaborationGroupIds);
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp;
		mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollabGrpId, UserContext.id);

		Integer recordLimit = siteCriteriaObjArg.size + 1;
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSitesAllFollowingSites(siteCriteriaObjArg.term, 
						siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category, listOfCollabGrpId,siteCriteriaObjArg.sortBy);	
		Map<String, ObjectToWrapperAdapter.SiteStats> siteStatsMap = objectToWrapperAdapterObj.getSiteStats(listOfSimpplrSite);
		for(Simpplr_Site__c siteRecord : listOfSimpplrSite){
			if (mapOfIdWithCollaborationGrp.containskey(siteRecord.Chatter_Group_Id__c)){
				listOfSiteWrapper.add(objectToWrapperAdapterObj.toSiteListWrapper(siteRecord, mapOfIdWithCollaborationGrp.get(siteRecord.Chatter_Group_Id__c),siteStatsMap.get(siteRecord.Id)));	
			}
		}
		return listOfSiteWrapper;
	}
    
    public List<SiteListWrapper> getSitesAllManagingSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		List<CollaborationGroupMember> listOfCollaborationGrpMem;
		SiteDao siteDaoObj = new SiteDao();
		// list of CollaborationGroupMember records where show in simpplr is true for current user
		List<CollaborationGroupMember> colGrpMembrList = siteDaoObj.getGrpMembrForSitesShowingInSimpplr(UserContext.id);
		listOfCollaborationGrpMem = getCollaborationGrpManagedBy(colGrpMembrList);
		List<Id> listOfCollabGrpId = new List<Id>();
		
		for (CollaborationGroupMember grpMemberObj : listOfCollaborationGrpMem) {
			listOfCollabGrpId.add(grpMemberObj.CollaborationGroupId);
		}
		
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp;
		mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollabGrpId,
				UserContext.id);
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSitesAllManagingSites(siteCriteriaObjArg.term, 
				siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category, listOfCollabGrpId,siteCriteriaObjArg.sortBy);
		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrp));	
		return listOfSiteWrapper;
    		
    }
    
    public List<SiteListWrapper> getProfileSitesAllSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		
		List<Id> listOfUsersCollGroupId = new List<Id>();
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrpForUserId;
		SiteDao siteDaoObj = new SiteDao();
		mapOfIdWithCollaborationGrpForUserId = Utility.getMapOfIdWithCollaborationGroup(siteCriteriaObjArg.sfUserId);
		
		for (Id collaGrpId : mapOfIdWithCollaborationGrpForUserId.keyset()) {
			if (!mapOfIdWithCollaborationGrpForUserId.get(collaGrpId).GroupMembers.isEmpty()) {
				listOfUsersCollGroupId.add(collaGrpId);
			}
		}		
		
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getProfileSitesAllSites(siteCriteriaObjArg.term, 
				siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category, listOfUsersCollGroupId);
				
		List<Id> listOfCollGroupId = new List<Id> ();
		
		if (!listOfSimpplrSite.isEmpty()) {
			
			for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSite) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
			
		}
		
		
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrpForLoggedInUser;
		mapOfIdWithCollaborationGrpForLoggedInUser = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollGroupId,
				UserContext.id);
			
		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrpForLoggedInUser));
		return 	listOfSiteWrapper;
    		
    }
    
    /*public List<SiteListWrapper> getProfileSitesAllFeaturedSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		List<Id> listOfUsersCollGroupId = new List<Id>();
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrpForUserId;
		SiteDao siteDaoObj = new SiteDao();
		mapOfIdWithCollaborationGrpForUserId = Utility.getMapOfIdWithCollaborationGroup(siteCriteriaObjArg.sfUserId);
		for (Id collaGrpId : mapOfIdWithCollaborationGrpForUserId.keyset()) {
			if (!mapOfIdWithCollaborationGrpForUserId.get(collaGrpId).GroupMembers.isEmpty()) {
				listOfUsersCollGroupId.add(collaGrpId);
			}
		}
		
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getProfileSitesAllFeaturedSites(siteCriteriaObjArg.term, 
				siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category, listOfUsersCollGroupId);
		
		List<Id> listOfCollGroupId = new List<Id> ();
		
		if (!listOfSimpplrSite.isEmpty()) {
			for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSite) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
			
		}
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrpForLoggedInUser;
		mapOfIdWithCollaborationGrpForLoggedInUser = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollGroupId,
				UserContext.id);
		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrpForLoggedInUser)); 
		return 	listOfSiteWrapper;
    		
    }*/
    
    /*public List<SiteListWrapper> getProfileSitesAllFavoriteSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		SiteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getProfileSitesAllFavoriteSites(siteCriteriaObjArg.term, 
				siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category, siteCriteriaObjArg.sfUserId);
				
		List<Id> listOfCollGroupId = new List<Id> ();
		
		if (!listOfSimpplrSite.isEmpty()) {
			
			for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSite) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
			
		}
				
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrpForLoggedInUser;
		mapOfIdWithCollaborationGrpForLoggedInUser = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollGroupId,
				UserContext.id);
			
		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrpForLoggedInUser));
		return listOfSiteWrapper;
    		
    }*/
   
    public List<SiteListWrapper> getProfileSitesAllManagingSites(Criteria.Site siteCriteriaObjArg) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		List<CollaborationGroupMember> listOfCollaborationGrpMem;
		SiteDao siteDaoObj = new SiteDao();
		// list of CollaborationGroupMember records where show in simpplr is true for current user
		List<CollaborationGroupMember> colGrpMembrList = siteDaoObj.getGrpMembrForSitesShowingInSimpplr(siteCriteriaObjArg.sfUserId);
		listOfCollaborationGrpMem = getCollaborationGrpManagedBy(colGrpMembrList);
		List<Id> listOfCollabGrpId = new List<Id>();
		
		for (CollaborationGroupMember grpMemberObj : listOfCollaborationGrpMem) {
			listOfCollabGrpId.add(grpMemberObj.CollaborationGroupId);
		}

		List<Site_Role__c> siteRoleList = new List<Site_Role__c>();
		if(siteCriteriaObjArg.peopleId != null) {
			siteRoleList = [Select id, site__c, is_Member__c, people__c, site__r.Chatter_Group_Id__c from Site_Role__c where (Is_Manager__c = true OR Is_Content_Manager__c = true) and people__c =: siteCriteriaObjArg.peopleId and is_Deleted__c = false WITH SECURITY_ENFORCED];
		} else {
			People__c peopleObj = [Select Id From People__c Where User__c =:UserContext.Id WITH SECURITY_ENFORCED];
			siteRoleList = [Select id, site__c, is_Member__c, people__c, site__r.Chatter_Group_Id__c from Site_Role__c where (Is_Manager__c = true OR Is_Content_Manager__c = true) and people__c =: peopleObj.id and is_Deleted__c = false WITH SECURITY_ENFORCED];
		}
		
		Set<String> siteIds = new set<String>();
		for (Site_Role__c siteRole: siteRoleList){
			siteIds.add(siteRole.site__c);
			if(!listOfCollabGrpId.contains(siteRole.site__r.chatter_Group_id__c)) {
				listOfCollabGrpId.add(siteRole.site__r.chatter_Group_id__c);
			}
		}
		
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollabGrpId, UserContext.id);
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getProfileSitesAllManagingSites(siteCriteriaObjArg.term, 
				siteCriteriaObjArg.offset, recordLimit, siteCriteriaObjArg.category, listOfCollabGrpId, siteCriteriaObjArg.sfUserId);
		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrp));	
		return listOfSiteWrapper;
    		
	}

	public List<SiteListWrapper> getSitesSearchResults(List<String> siteIdsToFilterFrom) {
		List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
		List<Id> listOfCollabGrpId = new List<Id>();
		SiteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSiteIdsToFilterFrom(siteIdsToFilterFrom);
		for (Simpplr_site__c site: listOfSimpplrSite){
			if(!listOfCollabGrpId.contains(site.chatter_Group_id__c)) {
				listOfCollabGrpId.add(site.chatter_Group_id__c);
			}
		}
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollabGrpId, UserContext.id);
		listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrp));
		return listOfSiteWrapper;
	}
	
    public List<SiteListWrapper> getSitesSearchResults(Criteria.Site siteCriteriaObjArg) {
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		
		SiteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSitesSearchResults(siteCriteriaObjArg);
				
		List<Id> listOfCollGroupId = new List<Id> ();
		
		if (!listOfSimpplrSite.isEmpty()) {
			
			for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSite) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
			
		}
		
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp;
		mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollGroupId,
				UserContext.id);
		
		List<SiteListWrapper> listOfSiteWrapper = objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrp);
		return 	listOfSiteWrapper;
    		
	}
	
	public List<SiteListWrapper> getSitesSearchResultsManagedByLoggedInUser(Criteria.Site siteCriteriaObjArg) {
		Integer recordLimit = siteCriteriaObjArg.size + 1;
		SiteDao siteDaoObj = new SiteDao();
		List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getSitesSearchResultsManagedByLoggedInUser(siteCriteriaObjArg);
				
		List<Id> listOfCollGroupId = new List<Id> ();
		
		if (!listOfSimpplrSite.isEmpty()) {
			
			for (Simpplr_Site__c simpplrSiteObj : listOfSimpplrSite) {
				listOfCollGroupId.add(simpplrSiteObj.Chatter_Group_Id__c);
			}
		}
		
		Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp;
		mapOfIdWithCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(listOfCollGroupId,
				UserContext.id);
		
		List<SiteListWrapper> listOfSiteWrapper = objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfIdWithCollaborationGrp);
		return 	listOfSiteWrapper;
    		
    }
    
    public ChatterGroupWrapper getChatterGroupDetails(String chatterGroupId) {
    	ChatterGroupWrapper cgWrapperObj = new ChatterGroupWrapper();
    	
    	SiteDao siteDaoObj = new SiteDao();
    	CollaborationGroup cgObj = siteDaoObj.getChatterGroupDetails(chatterGroupId);
    	
   		cgWrapperObj.chatterGroupId = cgObj.Id;
   		cgWrapperObj.name = cgObj.Name;
   		cgWrapperObj.url = SimpplrContext.salesforceBaseUrl + '/' + cgObj.Id;
  		cgWrapperObj.access = cgObj.CollaborationType;
   		cgWrapperObj.memberCount = cgObj.MemberCount;
    	
    	return cgWrapperObj;
    }
    
    public List<ChatterGroupWrapper> getChatterGroups (Criteria.ChatterGroup chatterGroupCriteriaObjArg) {
    	List<ChatterGroupWrapper> chatterGroupWrapperList = new List<ChatterGroupWrapper>();
		Integer recordLimit = chatterGroupCriteriaObjArg.size + 1;
		SiteDao siteDaoObj = new SiteDao();
		List<CollaborationGroup> chatterGroupList = siteDaoObj.getChatterGroups(chatterGroupCriteriaObjArg.term, 
				chatterGroupCriteriaObjArg.offset, recordLimit, chatterGroupCriteriaObjArg.sortBy);
		chatterGroupWrapperList.addAll(objectToWrapperAdapterObj.generateListOfChatterGroupWrapper(chatterGroupList));
		return 	chatterGroupWrapperList;
    }
    
    public SiteDetailWrapper getsiteDetailData(String siteId, String chatterGroupId) {
		ResponseWrapper responseToReturn = null;
		SiteDetailWrapper sdWrapperObj = new SiteDetailWrapper();
		String redirectUrl = '';
		List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
		Set<String>  allowedFeaturesInAppSet = new  Set<String>();
		for(String feature : allowedFeaturesInAppList) {
	    	allowedFeaturesInAppSet.add(feature.toLowerCase());
	    }
		List<Simpplr_Site__c> listOfSimpplrSite = null;
		List<Subscription_Entity__c> siteMandatorySubscriptionEntityList = new List<Subscription_Entity__c>();
		
		if(String.isBlank(siteId) && String.isNotBlank(chatterGroupId)){
			List<Simpplr_Site__c> siteList = [SELECT Id FROM Simpplr_Site__c WHERE Chatter_Group_Id__c = :chatterGroupId WITH SECURITY_ENFORCED];
			if(!siteList.isEmpty()){
				siteId = siteList[0].Id;
			}	
		} else  if (String.isBlank(siteId)) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		 
		} else {
			listOfSimpplrSite = [select id, name, chatter_group_id__c, Site_Type__c, Is_Active__c,File_Storage_Source__c,
					Has_Albums__c, Has_Events__c, Has_Pages__c, Landing_Page__c,Allow_Public_Contribution__c, Allow_File_Upload_App_Permission__c, 
					Is_Featured__c,Site_Category__c, Site_Category__r.Name__c, Question_Answer_Enabled__c, Is_Membership_Auto_Approved__c,
					Title_Content_Version__c,Title_Content_Document__c, Cover_Content_Document__c, Cover_Content_Version__c, Show_In_Simpplr__c, 
					Allow_Comments__c, Layout__c, Slack_Channel_Id__c,Slack_Channel_Name__c,Slack_Url__c, Microsoft_Teams_Integration_Enabled__c,
					External_Apps_Site_Config_Json__c,Slack_Integration_Enabled__c,Has_Campaigns__c, Follower_Count__c, Member_Count__c, Is_Content_Unfurl_Enabled__c,
					(select id from Bookmarked_Simpplr_Site__r where People__c =:UserContext.peopleId and Type__c='Site' And Is_Deleted__c=false),
					(Select Id, Is_Manager__c, Is_Content_Manager__c, Is_Member__c FROM Site_Roles__r WHERE People__c = :UserContext.peopleId AND Is_Deleted__c = false),
					(select id from Simpplr_Content_Site__r 
					where is_published__c=true and is_deleted__c=false 
					and Activated_By_Feature__c=true and 
					Type__c IN : allowedFeaturesInAppList limit 1),
					(Select Permissions__c From Simpplr_Folders__r WHERE Type__c = 'dropbox' 
					AND Is_Deleted__c = false AND Is_System_Folder__c = true 
					AND Parent_Folder__c = null LIMIT 1 ),
					(SELECT id FROM Site_Membership_Request__r WHERE Request_By__c=:UserContext.peopleId AND Status__c='Pending'), 
					(SELECT Id, Is_Featured__c FROM Site_Segments__r WHERE Segment__c =: UserContext.segmentId),
					(SELECT id, Subscription__r.Audience__c FROM Subscription_Entity_Site__r WHERE Subscription__r.Action_Type__c = 'mandatory'
				 	AND Status__c ='Approved' AND Subscription__r.Status__c != 'Deleted' And 
				 	(Subscription__r.Audience__r.Segment__c = :UserContext.segmentId OR
			  		Subscription__r.Audience__r.Segment__c = null) Limit 1) 
					FROM Simpplr_Site__c where id = :siteId WITH SECURITY_ENFORCED];

			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', UserContext.segmentId);
			soqlParamMap.put('soqlParam2', siteId);
			String query = 'SELECT Id, Subscription__r.Audience__c from Subscription_Entity__c ' + 
							'WHERE Subscription__r.Action_Type__c = \'mandatory\' ' + 
							'AND Status__c = \'Approved\' AND Subscription__r.Status__c != \'Deleted\' And ' +
							'(Subscription__r.Audience__r.Segment__c =: soqlParam1 OR ' +
							'Subscription__r.Audience__r.Segment__c = null) AND Site__c =: soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			siteMandatorySubscriptionEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);								
		}
		
		if(!listOfSimpplrSite.isEmpty()){ 
			if(listOfSimpplrSite[0].Is_Active__c == false){
				throw new SimpplrException('It\'s not possible to perform this action - Site is not active');
		    } else if (listOfSimpplrSite[0].Show_In_Simpplr__c == false) {
		    	//redirectUrl = SimpplrContext.salesforceBaseUrl + '/'+listOfSimpplrSite[0].chatter_group_id__c;
		    	throw new SimpplrException(ServiceConstants.ERROR_404);
			} else {
				Simpplr_Site__c siteObj = listOfSimpplrSite[0];
				
				Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = Utility.getAllCollaborationGroupMapForSiteIds(new List<Id>{siteObj.chatter_group_id__c});
				SiteDao siteDaoObj = new SiteDao();
				if(mapOfIdWithCollaborationGrp.get(siteObj.Chatter_Group_Id__c) == null){
					throw new SimpplrException(ServiceConstants.ERROR_404);	
				}
				CollaborationGroup collabGroup = mapOfIdWithCollaborationGrp.get(siteObj.Chatter_Group_Id__c);
				String packageName = SimpplrContext.packageName;
				String chatter_GroupId = siteObj.Chatter_Group_Id__c;

				Integer followerCount = 0;
				Integer memberCount = 0;
				Integer ownerAndManagerCount = 0;

				sdWrapperObj.managerCount = siteDaoObj.getSiteManagerCount(siteId, null);
				sdWrapperObj.memberCount = (Integer)siteObj.Member_Count__c;
				sdWrapperObj.members = memberCount;
				sdWrapperObj.followerCount = (Integer)siteObj.Follower_Count__c;
				
				// current-user role in site
				sdWrapperObj.isManager = false;
				sdWrapperObj.isContentManager = false;
				sdWrapperObj.isMember = false;
				sdWrapperObj.isFollower = false;
				
				if(!siteObj.Site_Roles__r.isEmpty()) {
					sdWrapperObj.isManager = siteObj.Site_Roles__r[0].Is_Manager__c;
					sdWrapperObj.isContentManager = siteObj.Site_Roles__r[0].Is_Content_Manager__c;
					if(siteObj.Site_Roles__r[0].Is_Member__c) {
						sdWrapperObj.isMember = siteObj.Site_Roles__r[0].Is_Member__c;					
					} else {
						sdWrapperObj.isFollower = true;
					}
				}

				sdWrapperObj.id = siteObj.id;
				sdWrapperObj.siteId = siteObj.id;
				sdWrapperObj.title = siteObj.name;
				sdWrapperObj.name = siteObj.name;
				sdWrapperObj.access = siteObj.Site_Type__c;
				sdWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.Id + '/' + siteObj.Landing_Page__c;
				sdWrapperObj.editUrl = PageContext.getPageURL(Pages.app) +'?u=/manage/sites/' + siteObj.id;
				sdWrapperObj.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(siteObj.Site_Type__c) ? true : false;
				sdWrapperObj.isListed = ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(siteObj.Site_Type__c) ? false : true;
				sdWrapperObj.isAccessRequested = new SiteDao().isAccessRequested(siteObj,collabGroup);
				sdWrapperObj.landingPage = siteObj.Landing_Page__c;
				if('dashboard'.equalsIgnoreCase(siteObj.Landing_Page__c)) {
					sdWrapperObj.hasDashboard = true;
				} else { 
					sdWrapperObj.hasDashboard = false;
				}
				
				sdWrapperObj.hasAlbums = allowedFeaturesInAppSet.contains('album') && siteObj.Has_Albums__c;
				sdWrapperObj.hasEvents = allowedFeaturesInAppSet.contains('event') && siteObj.Has_Events__c;
				sdWrapperObj.hasPages = allowedFeaturesInAppSet.contains('page') && siteObj.Has_Pages__c;
				sdWrapperObj.isMembershipAutoApproved = siteObj.Is_Membership_Auto_Approved__c;
				sdWrapperObj.isContentUnfurlEnabled = siteObj.Is_Content_Unfurl_Enabled__c;

				sdWrapperObj.hasContent =  siteObj.Simpplr_Content_Site__r.size() > 0;
				sdWrapperObj.information = collabGroup.InformationBody;
				sdWrapperObj.description = collabGroup.description;
				sdWrapperObj.chatterGroupId = siteObj.chatter_group_id__c;
				sdWrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(collabGroup.CreatedDate);
				sdWrapperObj.storageProvider = siteObj.File_Storage_Source__c.toLowerCase();
				if (SiteContext.isCurrentUserSiteManager || SiteContext.isCurrentUserSiteOwner || SiteContext.isCurrentUserSiteContentManager) {
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

				sdWrapperObj.canAccessLeadercast = false;
				if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_ALL_USER)) {
					sdWrapperObj.canAccessLeadercast = true;
				} else if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_APP_MANAGERS)
							&& UserContext.isUserAppModerator) {
					sdWrapperObj.canAccessLeadercast = true;
				} else if(SimpplrContext.leadercastEnabledFor.equalsIgnoreCase(ServiceConstants.ALLOW_LEADERCAST_SELECTED_SITES_USERS)) {
					if(UserContext.canAccessLeadercast) {
						sdWrapperObj.canAccessLeadercast = true;
					} else if(SiteContext.isLeadercastEnabled && (SiteContext.isCurrentUserSiteManager || 
								SiteContext.isCurrentUserSiteOwner || SiteContext.isCurrentUserSiteContentManager)) {
						sdWrapperObj.canAccessLeadercast = true;									
					}
				}

				Boolean hasContentCreationAccess = false;
				sdWrapperObj.isContentFeedEnabled = siteObj.Allow_Comments__c;
				sdWrapperObj.dashboardLayout = siteObj.Layout__c;
				
				if (ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(sdWrapperObj.storageProvider) 
						&& siteObj.Simpplr_Folders__r.size() > 0 
						&& String.isNotBlank(siteObj.Simpplr_Folders__r[0].Permissions__c)) {
					String permissions = siteObj.Simpplr_Folders__r[0].Permissions__c.toLowerCase();		
					sdWrapperObj.dropboxRootPermission = permissions;
				}
				
				hasContentCreationAccess = sdWrapperObj.isManager ? true : AccessManager.hasContentCreateAccess(sdWrapperObj.id, siteObj.Site_Type__c, siteObj.Allow_Public_Contribution__c, sdWrapperObj.isMember);
				
				if(String.isNotBlank(siteObj.Slack_Url__c) && SimpplrContext.slackIntegrationEnabled){
					SiteDetailWrapper.slack slackObj = new SiteDetailWrapper.Slack();
					slackObj.url = siteObj.Slack_Url__c+'messages/'+siteObj.Slack_Channel_Name__c;
					slackObj.name = siteObj.Slack_Channel_Name__c;
					sdWrapperObj.slack = slackObj;
				}
				if(String.isNotBlank(siteObj.External_Apps_Site_Config_Json__c) && SimpplrContext.slackIntegrationEnabled && siteObj.Slack_Integration_Enabled__c){
					ManageSiteWrapper.ExternalAppsSiteConfig wrapperObj =  new ManageSiteWrapper.ExternalAppsSiteConfig();
					wrapperObj = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
					if(wrapperObj.SlackSiteConfig != null){
						SiteDetailWrapper.slack slackObj = new SiteDetailWrapper.slack();
						slackObj.url = wrapperObj.SlackSiteConfig.slackWebUrl;
						slackObj.name = wrapperObj.SlackSiteConfig.slackChannelName;
						sdWrapperObj.slack = slackObj;
					}
				}
				if(String.isNotBlank(siteObj.External_Apps_Site_Config_Json__c) && SimpplrContext.microsoftTeamsIntegrationEnabled && siteObj.Microsoft_Teams_Integration_Enabled__c){
					ManageSiteWrapper.ExternalAppsSiteConfig wrapperObj =  new ManageSiteWrapper.ExternalAppsSiteConfig();
					wrapperObj = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
					if(wrapperObj.MsTeamsSiteConfig != null){
						SiteDetailWrapper.MsTeams microsoftTeamObj = new SiteDetailWrapper.MsTeams();
						microsoftTeamObj.webUrl = wrapperObj.MsTeamsSiteConfig.webUrl;
						microsoftTeamObj.name = wrapperObj.MsTeamsSiteConfig.msTeamsChannelName;
						sdWrapperObj.MsTeams = microsoftTeamObj;
					}
				}
				sdWrapperObj.teams = siteObj.Microsoft_Teams_Integration_Enabled__c;
				sdWrapperObj.canCreatePage = (sdWrapperObj.hasPages && hasContentCreationAccess);
				sdWrapperObj.canCreateEvent = (sdWrapperObj.hasEvents && hasContentCreationAccess);
				sdWrapperObj.canCreateAlbum = (sdWrapperObj.hasAlbums && hasContentCreationAccess);
				sdWrapperObj.isContentSubmissionsEnabled = siteObj.Allow_Public_Contribution__c;

				sdWrapperObj.isQuestionAnswerEnabled = SimpplrContext.isQuestionAnswerEnabled && siteObj.Question_Answer_Enabled__c;
				
				sdWrapperObj.canMention = collabGroup.CanHaveGuests ? false : true;
				sdWrapperObj.isActive = siteObj.Is_Active__c;
				sdWrapperObj.isFavorited = siteObj.Bookmarked_Simpplr_Site__r.isEmpty()?false:true;

				sdWrapperObj.isInMandatorySubscription = false;
				sdWrapperObj.hasCampaigns = siteObj.Has_Campaigns__c;
				if(!siteMandatorySubscriptionEntityList.isEmpty()){
					Set<String> audienceIdSet = new Set<String>();
					for(Subscription_Entity__c seObj : siteMandatorySubscriptionEntityList){
						audienceIdSet.add(seObj.Subscription__r.Audience__c);
					}
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', audienceIdSet);
					soqlParamMap.put('soqlParam2', UserContext.peopleId);
					String queryStr = 'SELECT id FROM Audience_Member__c WHERE Audience__c IN :soqlParam1'+
																	' And People__c = :soqlParam2';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<Audience_Member__c> audienceMemberList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
					sdWrapperObj.isInMandatorySubscription = (audienceMemberList != null && !audienceMemberList.isEmpty());
				}

				if(SimpplrContext.isSegmentsEnabled && String.isNotBlank(UserContext.segmentId)){
					sdWrapperObj.isFeatured = false;
					if(siteObj.Site_Segments__r.isEmpty() == false){
						sdWrapperObj.isFeatured = siteObj.Site_Segments__r[0].Is_Featured__c;
					}
				} else {
					sdWrapperObj.isFeatured = siteObj.Is_Featured__c;
				}
				
				sdWrapperObj.isOwner = UserContext.id.equalsIgnoreCase(collabGroup.OwnerId);
				sdWrapperObj.isBroadcast = collabGroup.IsBroadcast;
				
				if((UserContext.hasModifyAllDataPermission && !'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c)) 
			 		|| (UserContext.isUserAppModerator && 'Public'.equalsIgnoreCase(siteObj.Site_Type__c))
			 		|| (UserContext.hasManageUnlistedSitePermission && 'Unlisted'.equalsIgnoreCase(siteObj.Site_Type__c))){
				 		sdWrapperObj.canEdit  = true;
			 	} else {
			 		sdWrapperObj.canEdit  = sdWrapperObj.isManager;
			 	}
			 	
			 	if(( sdWrapperObj.canEdit) || ( (UserContext.hasModifyAllDataPermission || UserContext.isUserAppModerator))){
				 	sdWrapperObj.canActivateDeactivate = true;
			 	} else {
			 		sdWrapperObj.canActivateDeactivate = false;
			 	}
				
				if(String.isNotBlank(siteObj.Site_Category__c)) {
					sdWrapperObj.category = new SiteDetailWrapper.Category();
			 		sdWrapperObj.category.id = siteObj.Site_Category__c;
			 		sdWrapperObj.category.name = siteObj.Site_Category__r.Name__c;
			 		sdWrapperObj.category.url = PageContext.getPageURL(Pages.app)+'?u=/sites/category?category=' + siteObj.Site_Category__c;
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
				if(String.isNotBlank(siteObj.Cover_Content_Document__c)){
					sdWrapperObj.coverImage = Utility.getFileDownloadURL(siteObj.Cover_Content_Version__c);	
				}
				
				if(SimpplrContext.isSegmentsEnabled){
					sdWrapperObj.listOfFeaturedSegments = new List<SegmentWrapper>();
					Map<String, Object> soqlParamMap = new  Map<String, Object>();
					soqlParamMap.put('soqlParam1', siteId);
					String query1 = 'Select Id,Site__c, LastModifiedDate, CreatedDate, Is_Featured__c, Segment__c, Segment__r.Name__c from Segment_Site__c where Site__c =: soqlParam1';	
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
					List<Segment_Site__c> segmentList  = (List<Segment_Site__c>)SIMPESAPI.accessController().queryAsUSer(query1, soqlParamMap);
 					SegmentWrapper segmentObj;					
					List<String> segmentIds = new List<String>();
					for(Segment_Site__c segmentSiteObj : segmentList) {
						segmentIds.add(segmentSiteObj.Segment__c);	
					}
					Map<String, Object> soqlParamMap1 = new  Map<String, Object>();
					soqlParamMap1.put('soqlParam1', segmentIds);
					String queryStr = 'SELECT '+String.join(SegmentDataServer.getSegmentFieldList(),',') + ' FROM Segment__c where Id IN :soqlParam1';
					Map<Id, Segment__c> mapOfSegment = new Map<Id, Segment__c>((List<Segment__c>)SIMPESAPI.accessController().queryAsUSer(queryStr, soqlParamMap1));
	
					for(Segment_Site__c ss : segmentList){
						
						if(ss.Is_Featured__c){
							segmentObj = SegmentationWrapperAdapter.convertToLightSegmentWrap(mapOfSegment.get(ss.Segment__c));
							sdWrapperObj.listOfFeaturedSegments.add(segmentObj);
						}
					}
				}
				List<AggregateResult> aggrList = [select Type__c contentType, count(Id) recordCount 
												  from simpplr_content__c 
												  where site__c=:siteId
												  And First_Publish_DateTime__c != null
												  AND Is_Published__c=true And Is_Deleted__c = false 
												  AND Activated_By_Feature__c = true 
												  AND Type__c IN: allowedFeaturesInAppList
												  WITH SECURITY_ENFORCED
												  group by Type__c];
			    sdWrapperObj.analytics = new SiteDetailWrapper.AnalyticsWrapper();
			    sdWrapperObj.analytics.csvUrl = PageContext.getPageURL(Pages.Reports) + '?action=geSiteContentTypes&SiteId=' + siteId;
			    for(AggregateResult ar: aggrList) {
			    	String contentType = (String)ar.get('contentType');
		            if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(contentType)) {
		            	sdWrapperObj.analytics.totalPageCount = (Integer)ar.get('recordCount');
		            	
		            } else if(ServiceConstants.TYPE_Event.equalsIgnoreCase(contentType)) {
		            	sdWrapperObj.analytics.totalEventCount = (Integer)ar.get('recordCount');
		            	
		            } else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentType)) {
		            	sdWrapperObj.analytics.totalAlbumCount = (Integer)ar.get('recordCount'); 
		            	
		            }
		        }
			}
		}	
    	return sdWrapperObj;
	}
	    
	private List<CollaborationGroupMember> getCollaborationGrpManagedBy(List<CollaborationGroupMember> cgmList) {
		List<CollaborationGroupMember> listOfCollborationGrpMember = new List<CollaborationGroupMember>();
		
		for (CollaborationGroupMember cgm : cgmList) {
			
			if ('Admin'.equalsIgnoreCase(cgm.CollaborationRole)) {
				listOfCollborationGrpMember.add(cgm);
			}
		} 
				
		return listOfCollborationGrpMember;
	}

	public SlackDataServer.ResponseStructure getSlackUnfurlInfoForSite(String siteId) { 
		SlackDataServer.ResponseStructure response = new SlackDataServer.ResponseStructure();
		SiteDetailWrapper sdWrapperObj = new SiteDetailWrapper();
		String redirectUrl = '';
		List<String> allowedFeaturesInAppList = String.valueOf(SimpplrContext.AllowedFeatures).split(',');
		List<Simpplr_Site__c> listOfSimpplrSite = null;
		
		if (String.isBlank(siteId)) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		 
		} else {
			listOfSimpplrSite = [select id, name, chatter_group_id__c, Landing_Page__c, Site_Type__c, Is_Active__c,
										Title_Content_Version__c,Title_Content_Document__c,Show_In_Simpplr__c 
										FROM Simpplr_Site__c where id = :siteId WITH SECURITY_ENFORCED];
		}
		if(!listOfSimpplrSite.isEmpty()){ 
	    Simpplr_Site__c siteObj = listOfSimpplrSite[0];
			if(listOfSimpplrSite[0].Is_Active__c == false){
				throw new SimpplrException('It\'s not possible to perform this action - Site is not active');
		  } else if (listOfSimpplrSite[0].Show_In_Simpplr__c == false) {
		    	throw new SimpplrException(ServiceConstants.ERROR_404);
			} else {
				Map<Id, CollaborationGroup> mapOfIdWithCollaborationGrp = Utility.getAllCollaborationGroupMapForSiteIds(new List<Id>{siteObj.chatter_group_id__c});
				if(mapOfIdWithCollaborationGrp.get(siteObj.Chatter_Group_Id__c) == null){
					throw new SimpplrException(ServiceConstants.ERROR_403);	
				}
				CollaborationGroup collabGroup = mapOfIdWithCollaborationGrp.get(siteObj.Chatter_Group_Id__c);
				sdWrapperObj.siteId = siteObj.id;
				sdWrapperObj.title = siteObj.name;
				sdWrapperObj.name = siteObj.name;
				sdWrapperObj.access = siteObj.Site_Type__c;
				sdWrapperObj.information = collabGroup.InformationBody;
				sdWrapperObj.description = collabGroup.description;
				sdWrapperObj.chatterGroupId = siteObj.chatter_group_id__c;
				List<People__c> owner = [select Id, First_Name__c, Last_Name__c from People__c where user__c =:collabGroup.ownerId WITH SECURITY_ENFORCED];
				sdWrapperObj.owner = new SiteDetailWrapper.ManagerWrapper();
				if(owner.isEmpty() == false){
					sdWrapperObj.owner.peopleId = owner[0].id;
					sdWrapperObj.owner.firstName = owner[0].First_Name__c;
					sdWrapperObj.owner.lastName = owner[0].Last_Name__c;
				}
				sdWrapperObj.url  = SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + '?siteId=' + siteObj.id +'&pageToRedirect=siteLandingPage';
				sdWrapperObj.members = collabGroup.MemberCount;
				sdWrapperObj.isActive = siteObj.Is_Active__c;
				
				if(String.isNotBlank(siteObj.Title_Content_Document__c)) {
					String cvId = siteObj.Title_Content_Version__c;
					String cdId = siteObj.Title_Content_Document__c;
					Map<Id, String> cvIdNPublicUrlMap = generateEmbedPublicUrl(new List<Id>{siteObj.Title_Content_Version__c});
					sdWrapperObj.img = cvIdNPublicUrlMap.get(siteObj.Title_Content_Version__c);
				}
			}
			response.type = 'site';
			response.siteDetail = sdWrapperObj;
		}
		
		return response;
	}
	public Map<Id, String> generateEmbedPublicUrl(List<Id> cvIdsList) {
    	Map<Id, String> mapOfPublicURLs = FileContentProvider.generatePublicUrl(cvIdsList);
    	Map<Id, String> mapOfEmbedPublicURLs = new Map<Id, String>();
    	for(Id key:mapOfPublicURLs.keySet()) {
    		if(String.isNotBlank(mapOfPublicURLs.get(key))) {
    			mapOfEmbedPublicURLs.put(key, converDistributionPublicUrlToImageURL(key, mapOfPublicURLs.get(key)));
    		}
    	}
    	return mapOfEmbedPublicURLs;
    }

	public String converDistributionPublicUrlToImageURL(String contentVersionId, String distributionPublicUrl) {
    	String urlPart = distributionPublicUrl.substringAfter(UserInfo.getOrganizationId().mid(3,12));
    	String publicURL = SimpplrContext.salesforceHost + '/sfc/dist/version/renditionDownload?versionId=' + contentVersionId + '&d=' + urlPart + '&oid=' + UserInfo.getOrganizationId() + '&rendition=THUMB720BY480';
    	return publicURL;
    }

    public List<SiteListWrapper> getRecentUsedSites(Criteria.Site siteCriteriaObjArg) {
        List<SiteListWrapper> listOfSiteWrapper = new List<SiteListWrapper>();
        SiteDao siteDaoObj = new SiteDao();
        Map<Id,CollaborationGroup> mapOfAllCollaborationGrp = siteDaoObj.getMapOfIdWithCollaborationGroup(UserContext.id);
        List<Simpplr_Site__c> listOfSimpplrSite = siteDaoObj.getRecentUsedSites(siteCriteriaObjArg.size, false);
        listOfSiteWrapper.addAll(objectToWrapperAdapterObj.generateListOfSiteListWrapper(listOfSimpplrSite, mapOfAllCollaborationGrp));
		return 	listOfSiteWrapper;
	}
	
	public PeopleWrapper.peopleStatsWrapper getPeopleStats(Criteria.Site siteCriteriaObjArg){
		PeopleWrapper.peopleStatsWrapper peopleStatsObj = new PeopleWrapper.peopleStatsWrapper();
		if (siteCriteriaObjArg.siteId!=null){
			List<Simpplr_Site__c> simpplrSiteList = [Select id, Chatter_Group_Id__c, Is_Deleted__c, Site_Type__c, Follower_Count__c, Member_Count__c from Simpplr_Site__c where Is_Deleted__c=false and id =: siteCriteriaObjArg.siteId];

			Simpplr_Site__c simpSite = new Simpplr_Site__c();
			if (!simpplrSiteList.isEmpty()){
				simpSite = simpplrSiteList[0];
			}

			SiteDao siteDaoObj = new SiteDao();

			peopleStatsObj.ownerAndManagerCount = siteDaoObj.getSiteManagerCount(siteCriteriaObjArg.siteId, siteCriteriaObjArg.term);
			peopleStatsObj.memberCount = simpSite.Member_Count__c != null ? (Integer)simpSite.Member_Count__c : 0;
			peopleStatsObj.followerCount = simpSite.Follower_Count__c != null ? (Integer)simpSite.Follower_Count__c : 0;
			peopleStatsObj.requestCount = siteDaoObj.getSiteMembershipRequestsCount(siteCriteriaObjArg.siteId, siteCriteriaObjArg.term);
		}

		return peopleStatsObj;
	}

}