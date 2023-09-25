public with sharing class SimpplrSiteTriggerGatway {
    
    public static void disableAutoArchiveForCollaborationGroups(Map<Id, Simpplr_Site__c> mapOfOfSimpplrSites) {
    	List <Id> listOfCollaborationGroupIds = new List<Id>();
        for(Simpplr_Site__c site : mapOfOfSimpplrSites.values()){
        	if(String.isNotBlank(site.Chatter_Group_Id__c)){
        	    listOfCollaborationGroupIds.add(site.Chatter_Group_Id__c);
        	}
        } 
	        
    	List <CollaborationGroup> listOfCollaborationGroups = new List <CollaborationGroup>();
    	String BASE_QUERY= 'Select Id, IsAutoArchiveDisabled from CollaborationGroup where id in : listOfCollaborationGroupIds ';
		if(SimpplrContext.isCommunitiesEnabled){
    		BASE_QUERY = BASE_QUERY+'AND NetworkId = null';
    	}
		listOfCollaborationGroups = Database.query(BASE_QUERY);
        List <CollaborationGroup> listOfUpdatableCollaborationGroups = new List<CollaborationGroup>();
        for(CollaborationGroup chatterGroup :listOfCollaborationGroups){    
            if(!chatterGroup.IsAutoArchiveDisabled){
                chatterGroup.IsAutoArchiveDisabled = true;
                listOfUpdatableCollaborationGroups.add(chatterGroup);
            }
        }
        if(! listOfUpdatableCollaborationGroups.isEmpty()){
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,CollaborationGroup>(listOfUpdatableCollaborationGroups),new List<Schema.SObjectField>{CollaborationGroup.IsAutoArchiveDisabled});
        	
        }           
    }
    
    public static void createPagesCategories(Map<Id, Simpplr_Site__c> mapOfOfSimpplrSites) {
    	List<String> listOfPagesCategoryValues = ServiceConstants.GLOBAL_DEFAULT_PAGES_CATEGORIES.split(',');
    	List<Pages_Category__c> listOfPageCategoriesToCreate = new List<Pages_Category__c>();
    	for(Simpplr_Site__c simpplrSiteObj : mapOfOfSimpplrSites.values()){
    		Integer index = 0;         
    		for(String pageCategoryName : listOfPagesCategoryValues){
    			Pages_Category__c pageCategoryObj = new Pages_Category__c();
    			pageCategoryObj.Site__c = simpplrSiteObj.Id;
    			pageCategoryObj.Name__c = pageCategoryName;
    			pageCategoryObj.order__c = index;
    			listOfPageCategoriesToCreate.add(pageCategoryObj);
    		}
    	}
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(listOfPageCategoriesToCreate,new List<Schema.SObjectField>{Pages_Category__c.Site__c,
																											Pages_Category__c.Name__c,
																											Pages_Category__c.order__c
																											});
    }
    
    public static void resetMustReadRecordForSites(Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites, Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites){
    	List<String> listOfSitesArchived = new List<String>();
    	Map<String, Object> mapOfActivityParams = new Map<String, Object>();
		    
	    for(Simpplr_Site__c site : mapOfNewSimpplrSites.values()){
		   	if(site.is_Active__c == false && mapOfOldSimpplrSites.get(site.Id).is_Active__c == true){
	    		listOfSitesArchived.add(site.id);
	    	}
	    }
	    
	    if(listOfSitesArchived.size()>0){
			mapOfActivityParams.put('listOfArchivedSites',listOfSitesArchived);
			BatchResetMustRead job = new BatchResetMustRead('SitesArchived',true,mapOfActivityParams);
			Database.executeBatch(job,2000);
		}
    }
    
    public static void expireOrDeleteAlerts(Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites, Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites){
    	List<String> listOfSitesArchived = new List<String>();
	    for(Simpplr_Site__c site : mapOfNewSimpplrSites.values() ){
		   	if(site.is_Active__c == false && mapOfOldSimpplrSites.get(site.Id).is_Active__c == true){
	    		listOfSitesArchived.add(site.id);
	    		
	    	}
	    }
	    
	    if(listOfSitesArchived.size()>0){
			BatchUpdateAlertAnalytics job = new BatchUpdateAlertAnalytics('ExpireOrDeleteAlerts', null, listOfSitesArchived);
			Database.executeBatch(job,2000);
		}
    }
    
    public static void updateSubscriptions(Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites, Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites) {
    	Set<Id> sitesMadePublic = new Set<Id>();
    	Set<Id> sitesMadePrivate = new Set<Id>();
    	
    	for(Simpplr_Site__c site : mapOfNewSimpplrSites.values()){
		   	if('Public'.equalsIgnoreCase(site.Site_Type__c) == true && 'Public'.equalsIgnoreCase(mapOfOldSimpplrSites.get(site.Id).Site_Type__c) == false){
	    		sitesMadePublic.add(site.id);
	    	} else if('Public'.equalsIgnoreCase(site.Site_Type__c) == false && 'Public'.equalsIgnoreCase(mapOfOldSimpplrSites.get(site.Id).Site_Type__c) == true){
	    		sitesMadePrivate.add(site.id);
	    	}
	    }
	    
	    if(sitesMadePublic.size() > 0){
			BatchProcessSubscription job = new BatchProcessSubscription('updateSubscriptionEntityWhenSitesMadePublic', sitesMadePublic, false);
			Database.executeBatch(job,200);
		}
		if(sitesMadePrivate.size() > 0){
			BatchProcessSubscription job = new BatchProcessSubscription('updateSubscriptionEntityWhenSitesMadePrivate', sitesMadePrivate, false);
			Database.executeBatch(job,200);
		}
    }
    
    public static void assignUncategorizedCategory(List<Simpplr_Site__c> listOfNewSimpplrSites) {
    	String uncategorizedString = ServiceConstants.UNCATEGORIZED_CATEGORY_STR;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', uncategorizedString);
		String query = 'SELECT Id FROM Site_Category__c WHERE Name__c =:soqlParam1 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Category__c> defaultSiteCategoryList = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	
    		for(Simpplr_Site__c site : listOfNewSimpplrSites){
			if(defaultSiteCategoryList.size() > 0 && site.is_Active__c == true && site.Site_Category__c == null) {
	    			site.Site_Category__c = defaultSiteCategoryList[0].Id;
	    		}
    		}
    }
    
    // Handle only the name changes
    public static void updateIntegrationFolders(Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites, Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites) {
    	if(!SimpplrContext.connectedStorages.isEmpty()) {			
			Map<String, Set<Id>> storageSitesMap = new Map<String, Set<Id>>();
			String siteStorage = '';
			Set<Id> storageSiteIds = new Set<Id>();
			
			for(Simpplr_Site__c newSite: mapOfNewSimpplrSites.values()) {
				siteStorage = newsite.File_Storage_Source__c;
				if(!newSite.Name.equalsIgnoreCase(mapOfOldSimpplrSites.get(newSite.Id).Name) &&
				   SimpplrContext.connectedStorages.contains(siteStorage)) {			
					if(storageSitesMap.containsKey(siteStorage)) {
						storageSiteIds = storageSitesMap.get(siteStorage);
					} else {
						storageSiteIds = new Set<Id>();
					}
					storageSiteIds.add(newSite.Id);
					storageSitesMap.put(siteStorage, storageSiteIds);
				}
			}
			
			//Group fileStorage and Sites
			for(String connStorage: SimpplrContext.connectedStorages) {
				if(storageSitesMap.containsKey(connStorage)) {					
					Database.executeBatch(new BatchEFSFolderSync('SITENAME', JSON.serialize(storageSitesMap.get(connStorage)), connStorage), 20);	
				}
			}
    	}
    }
    
    public static void shareTitleImageWithAllCompany(Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites, Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites) {
    	List<ContentDocumentLink> cdlinks = new List<ContentDocumentLink>();
    	
    	for(Simpplr_Site__c newSite: mapOfNewSimpplrSites.values()) {
			if(!'unlisted'.equalsIgnoreCase(newSite.Site_Type__c) && 
					'unlisted'.equalsIgnoreCase(mapOfOldSimpplrSites.get(newSite.Id).Site_Type__c) &&
					String.isNotBlank(newSite.Title_Content_Document__c)) {
						
				ContentDocumentLink cdLink2 = new ContentDocumentLink();
				cdLink2.ContentDocumentId = newSite.Title_Content_Document__c; 
				cdLink2.ShareType = 'V';
				cdLink2.LinkedEntityId = UserInfo.getOrganizationId();  
				             
				cdlinks.add(cdLink2);
			}
		}
		
		if(!cdlinks.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(cdlinks, new List<Schema.SObjectField>{
				ContentDocumentLink.ContentDocumentId,
				ContentDocumentLink.ShareType,
				ContentDocumentLink.LinkedEntityId
			});
		}
    }
    
    public static void insertSiteRecord (Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites) {

    	if (SimpplrContext.isExternalSearchAppConnected) {
			List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();

			for (Id siteId : mapOfNewSimpplrSites.keySet()) {
				External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
				obj.Site__c = siteId;
				obj.Type__c = 'Site';
				listToInsert.add(obj);
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
					External_Search_Data_Trail__c.Site__c,
					External_Search_Data_Trail__c.Type__c
					});
		}

    }

	public static void updateSimpplrSiteShareRecords(Map<Id, Simpplr_Site__c> mapOfOldSimpplrSites,
		Map<Id, Simpplr_Site__c> mapOfNewSimpplrSites) {

		List<Simpplr_Site__c> siteList = new List<Simpplr_Site__c>();
		List<String> siteIds = new List<String>();
		Boolean isAllInternalUserGroupIdToDelete = false;
		Boolean isUnlistedSiteManagerGroupIdToDelete = false;
		for(Simpplr_Site__c siteRecord : mapOfNewSimpplrSites.values()) {
			if(siteRecord.Site_Type__c != mapOfOldSimpplrSites.get(siteRecord.Id).Site_Type__c) {
				siteList.add(siteRecord);
				siteIds.add(siteRecord.Id);
				if(!isAllInternalUserGroupIdToDelete && ('Public'.equalsIgnoreCase(mapOfOldSimpplrSites.get(siteRecord.Id).Site_Type__c) || 'Private'.equalsIgnoreCase(mapOfOldSimpplrSites.get(siteRecord.Id).Site_Type__c))) {
					isAllInternalUserGroupIdToDelete = true;
				} else if(!isUnlistedSiteManagerGroupIdToDelete && 'Unlisted'.equalsIgnoreCase(mapOfOldSimpplrSites.get(siteRecord.Id).Site_Type__c)) {
					isUnlistedSiteManagerGroupIdToDelete = true;
				}
			}
		}
		if(siteList.size() != 0) {
			List<String> listOfUserOrGroupIdForDelete = new List<String>();
			if(isAllInternalUserGroupIdToDelete) {
				listOfUserOrGroupIdForDelete.add(Utility.getUserGroupId('AllInternalUsers'));
				listOfUserOrGroupIdForDelete.add(Utility.getUserGroupId('Simpplr_App_Managers'));
			}
			if(isUnlistedSiteManagerGroupIdToDelete) {
				listOfUserOrGroupIdForDelete.add(Utility.getUserGroupId('Simpplr_Unlisted_Site_Managers'));
			}
			if(listOfUserOrGroupIdForDelete.size() > 0) {
				List<Simpplr_Site__Share> listOfSimpplrSiteShareForDelete = [
					SELECT Id FROM Simpplr_Site__Share WHERE ParentID IN :siteIds AND UserOrGroupId IN :listOfUserOrGroupIdForDelete WITH SECURITY_ENFORCED
				];
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().deleteAsUser(listOfSimpplrSiteShareForDelete);	
			}
			Utility.createSimpplrSiteShareRecords(siteList, false);
		}
	}

}