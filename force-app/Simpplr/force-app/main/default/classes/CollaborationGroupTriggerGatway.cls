public with sharing class CollaborationGroupTriggerGatway {
	public static void updateSimpplrRecords(Map<Id, CollaborationGroup> mapOfOldCollaborationGroups, Map<Id, CollaborationGroup> mapOfNewCollaborationGroups) {
		
		List<Simpplr_Site__c> updateableSimpplrSites = new List<Simpplr_Site__c>();
		List<String> listOfChatterIdPublicToNotPublic=new List<String>();
		List<String> listOfChatterIdNotPublicToPublic=new List<String>();
		
		List<String> listOfSiteIdPublicToNotPublic=new List<String>();
		List<String> listOfSiteIdPublicToPrivate=new List<String>();
		List<String> listOfSiteIdNotPublicToPublic=new List<String>();
		Set<Id> updatedCollaborationGroupIds = new Set<Id>();
		Map<String,List<String>> storageToSitesMap = new Map<String,List<String>>();
		Set<String> storageSet = new Set<String>();
		Set<String> archivedSiteIdSet = new Set<String>();
		for(Simpplr_Site__c simpplrSite : [select id, Chatter_Group_Id__c, is_Active__c,Site_Type__c,
				Site_Category__c,File_Storage_Source__c from Simpplr_Site__c 
	    		where Chatter_Group_Id__c in : mapOfNewCollaborationGroups.keySet() WITH SECURITY_ENFORCED]) {
	    			
			Simpplr_Site__c objSite = new Simpplr_Site__c(
							Id = simpplrSite.Id, 
							Is_Active__c = simpplrSite.Is_Active__c,
							Name = mapOfNewCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).Name,
							Site_Category__c = simpplrSite.Site_Category__c,
							Site_type__c = mapOfNewCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).CollaborationType);					
			if(mapOfNewCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).isArchived == true && simpplrSite.is_Active__c == true) {
			   objSite.Is_Active__c = false;	
			   objSite.Site_Category__c = null;
			   objSite.Last_Edited_DateTime__c = DateTime.now();			
			   updateableSimpplrSites.add(objSite);
				 archivedSiteIdSet.add(simpplrSite.id);
			   
			} else if(mapOfNewCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).isArchived == false && simpplrSite.is_Active__c == false) {
			   objSite.Is_Active__c = true;		
			   objSite.Last_Edited_DateTime__c = DateTime.now();			
			   updateableSimpplrSites.add(objSite);		
			} else {
				objSite.Last_Edited_DateTime__c = DateTime.now();
				updateableSimpplrSites.add(objSite);
			}
			
			if(mapOfNewCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).CollaborationType == ServiceConstants.PUBLIC_SITE && mapOfOldCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).CollaborationType!=ServiceConstants.PUBLIC_SITE){
				//non public to public migration
				listOfChatterIdNotPublicToPublic.add(simpplrSite.Chatter_Group_Id__c);
				listOfSiteIdNotPublicToPublic.add(simpplrSite.id);
			}
			if(mapOfNewCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).CollaborationType != ServiceConstants.PUBLIC_SITE && mapOfOldCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).CollaborationType==ServiceConstants.PUBLIC_SITE){
				//public to non public migration
				listOfChatterIdPublicToNotPublic.add(simpplrSite.Chatter_Group_Id__c);
				listOfSiteIdPublicToNotPublic.add(simpplrSite.id);
			}
			if(mapOfNewCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).CollaborationType == ServiceConstants.PRIVATE_SITE && mapOfOldCollaborationGroups.get(simpplrSite.Chatter_Group_Id__c).CollaborationType==ServiceConstants.PUBLIC_SITE){
				//public to private migration
				listOfSiteIdPublicToPrivate.add(simpplrSite.id);
			}
			if(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(simpplrSite.File_Storage_Source__c) || 
				ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(simpplrSite.File_Storage_Source__c)) {
					
				storageSet.add(simpplrSite.File_Storage_Source__c);
				// populate storageToSitesMap
				if (storageToSitesMap != NULL && !storageToSitesMap.containsKey(simpplrSite.File_Storage_Source__c)) {
					storageToSitesMap.put(simpplrSite.File_Storage_Source__c, new List<String>());
				}
				List<String> tempList = storageToSitesMap.get(simpplrSite.File_Storage_Source__c);
				tempList.add(simpplrSite.id);
				storageToSitesMap.put(simpplrSite.File_Storage_Source__c,tempList);
			}
		}

		if(UserContext.Integrations.size()>0 && listOfSiteIdPublicToNotPublic.size()>0){
			
			for (String storage : storageSet) {
				List<String> siteList = storageToSitesMap.get(storage);
				Database.executeBatch(new BatchEFSFolderSync('SITEMADEPRIVATE', 
						JSON.serialize(siteList), storage),1);
			}
			
		}
		if(UserContext.Integrations.size()>0 && listOfSiteIdNotPublicToPublic.size()>0){
			
			for (String storage : storageSet) {
				List<String> siteList = storageToSitesMap.get(storage);
				Database.executeBatch(new BatchEFSFolderSync('SITEMADEPUBLIC', 
					JSON.serialize(listOfSiteIdNotPublicToPublic), storage), 1);
			}
			
		}
		if(listOfChatterIdNotPublicToPublic.size()!=0){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', BoxConstants.BOX_FOLDER_TYPE_LABEL);
			soqlParamMap.put('soqlParam2', listOfChatterIdNotPublicToPublic);
			String folderQuery = 'SELECT ID,Site__c,Box_Collaboration_Id__c,site__r.Chatter_Group_Id__c,External_Folder_Id__c,permissions__c from Folder__c where Is_System_Folder__c = false And type__c= :soqlParam1 AND Is_Deleted__c = false AND (Site__r.Chatter_group_id__c in :soqlParam2)';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfBoxFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
			if(listOfBoxFolders.size()>100){
				//throw new Exception('Cannot complete the action');
			} else if(!listOfBoxFolders.isEmpty() && SimpplrContext.IsBoxIntegrationEnabled == true && (String.isNotBlank(SimpplrContext.boxManagedPermission) && 'simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission))){
				String serializedListOfBoxFolders = Utility.getJsonFormat(listOfBoxFolders);
				createCollaborationFromBox(serializedListOfBoxFolders);
			}
			toggleContentPermissions(listOfChatterIdNotPublicToPublic, false);
		}
		if(listOfChatterIdPublicToNotPublic.size()!=0){
			updateMustReadContentToSiteTypeAudience(mapOfNewCollaborationGroups, listOfSiteIdPublicToNotPublic);
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', BoxConstants.BOX_FOLDER_TYPE_LABEL);
			soqlParamMap.put('soqlParam2', listOfChatterIdPublicToNotPublic);
			String folderQuery = 'SELECT ID,Site__c,Box_Collaboration_Id__c,site__r.Chatter_Group_Id__c,External_Folder_Id__c,permissions__c from Folder__c where Is_System_Folder__c = false And type__c= :soqlParam1 AND Is_Deleted__c = false AND (Site__r.Chatter_group_id__c in :soqlParam2)';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfBoxFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
			if(listOfBoxFolders.size()>100){
				//throw new Exception('Cannot complete the action');
			} else if(!listOfBoxFolders.isEmpty() && (String.isNotBlank(SimpplrContext.boxManagedPermission) && 'simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission))){
				String serializedListOfBoxFolders=Utility.getJsonFormat(listOfBoxFolders);
				deleteCollaborationFromBox(serializedListOfBoxFolders);
			}
			toggleContentPermissions(listOfChatterIdPublicToNotPublic, true);
		}
		if(listOfSiteIdPublicToPrivate.isEmpty() == false){
			Database.executeBatch(new BatchManageSiteConversionActivities(JSON.serialize(listOfSiteIdPublicToPrivate),ServiceConstants.PUBLIC_SITE,ServiceConstants.PRIVATE_SITE),200);
		}
		if(listOfSiteIdNotPublicToPublic.isEmpty() == false){
			Database.executeBatch(new BatchManageSiteConversionActivities(JSON.serialize(listOfSiteIdNotPublicToPublic),'Non Public',ServiceConstants.PUBLIC_SITE),200);
		}
		if(!updateableSimpplrSites.isEmpty()) {

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(updateableSimpplrSites),
														new List<Schema.SObjectField>{Simpplr_Site__c.Last_Edited_DateTime__c,
																					  Simpplr_Site__c.Is_Active__c,
																					  Simpplr_Site__c.Site_Category__c});
		}
    
	}
	
	public static void updateMustReadContentToSiteTypeAudience(Map<Id, CollaborationGroup> mapOfCollaborationGroups, List<String> listOfSiteIdPublicToNotPublic) {
		List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>();
		Map<String, Object> soqlParamMustReadMap = new Map<String, Object>();
		soqlParamMustReadMap.put('soqlParam1', listOfSiteIdPublicToNotPublic);
		String mustReadQuery = 'SELECT Id, Audience_Type__c FROM Must_Read_Audit__c WHERE Removed_DateTime__c = null AND (Audience_Type__c=\'everyone\' OR Audience_Type__c = \'site_members_and_followers\') AND Content__r.Site__c IN: soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Must_Read_Audit__c> mrAudList = (List<Must_Read_Audit__c>)SIMPESAPI.accessController().queryAsUser(mustReadQuery, soqlParamMustReadMap);
		for(Must_Read_Audit__c mrAudObj : mrAudList){
			mrAudObj.Audience_Type__c = 'site_members';
			listOfColumnsToBeUpdated.add(Must_Read_Audit__c.Audience_Type__c);
		}
		if(mrAudList.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Must_Read_Audit__c>(mrAudList), listOfColumnsToBeUpdated);
		}
		Map<String, Object> mapOfActivityParams = new Map<String, Object>();
		mapOfActivityParams.put('listOfSiteIds',listOfSiteIdPublicToNotPublic);
		BatchResetMustRead job = new BatchResetMustRead('DeleteMustReadNotificationsForNonSiteMembers',false,mapOfActivityParams);
		Database.executeBatch(job,1000);
	}
	
		/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@future (callout=true)
	public static void deleteCollaborationFromBox(String serializedListOfBoxFolders){

		BoxService boxServiceObj=new BoxService();
		String allCompanyBoxGroupId = SimpplrContext.BoxAllCompanyGroupId;
		List<Folder__c> listOfBoxFolders = (List<Folder__c>)Json.deserialize(serializedListOfBoxFolders, List<Folder__c>.class);
		BoxWrapper.UserTokens adminUserTokens = boxServiceObj.getBoxAdminUserTokens(false);
		
		if(adminUserTokens!=null && String.isNotBlank(adminUserTokens.accessToken)) {
			try {
				for(Folder__c simpplrContent: listOfBoxFolders){
					Map<String,String> mapOfcollaborationIds = (Map<String,String>) Json.deserialize(simpplrContent.Box_Collaboration_Id__c, Map<String,String>.class);
					String allCompanyCollaborationId = mapOfcollaborationIds.get(allCompanyBoxGroupId);
					if(String.isNotBlank(allCompanyCollaborationId)) {
						Boolean isDeleted=BoxService.deleteCollaborationOnBox(allCompanyCollaborationId,adminUserTokens.accessToken);
						if(isDeleted){
							mapOfcollaborationIds.remove(allCompanyCollaborationId);
						}
					}
					simpplrContent.Box_Collaboration_Id__c = Utility.getJsonFormat(mapOfcollaborationIds);
				}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		   		SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(listOfBoxFolders),new List<Schema.SObjectField>{
		    													Folder__c.Site__c,
		    													Folder__c.Box_Collaboration_Id__c,
		    													Folder__c.External_Folder_Id__c,Folder__c.permissions__c});		
				
				boxServiceObj.updateAdminUserTokensInDB(adminUserTokens);
			} catch(Exception ex) {
				boxServiceObj.updateAdminUserTokensInDB(adminUserTokens);
				//throw ex;
			}
		}
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@future (callout=true)
	public static void createCollaborationFromBox(String serializedListOfBoxFolders){
		BoxService boxServiceObj=new BoxService();
		String allCompanyBoxGroupId = SimpplrContext.BoxAllCompanyGroupId;
		List<Folder__c> listOfBoxFolders=(List<Folder__c>)Json.deserialize(serializedListOfBoxFolders, List<Folder__c>.class);
		BoxWrapper.UserTokens adminUserTokens = boxServiceObj.getBoxAdminUserTokens(false);
		if(adminUserTokens!=null && String.isNotBlank(adminUserTokens.accessToken)) {
			try {
				for(Folder__c simpplrContent: listOfBoxFolders){
					String role= 'Read'.equalsIgnoreCase(simpplrContent.permissions__c)?'previewer':'editor';
					Map<String,String> mapOfcollaborationIds = (Map<String,String>) Json.deserialize(simpplrContent.Box_Collaboration_Id__c, Map<String,String>.class);
					Object collaborationObj= boxServiceObj.addFolderIntoGroup(simpplrContent.External_Folder_Id__c, allCompanyBoxGroupId,role,adminUserTokens.accessToken);
					if(collaborationObj instanceof BoxWrapper.BoxCollaboration){
						BoxWrapper.BoxCollaboration boxCollaborationObj = (BoxWrapper.BoxCollaboration)collaborationObj;
						if(boxCollaborationObj!=null){
							mapOfcollaborationIds.put(allCompanyBoxGroupId, boxCollaborationObj.id);
						}
					}
					simpplrContent.Box_Collaboration_Id__c = Utility.getJsonFormat(mapOfcollaborationIds);
				}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		   		SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(listOfBoxFolders),new List<Schema.SObjectField>{
		    													Folder__c.Site__c,
		    													Folder__c.Box_Collaboration_Id__c,
		    													Folder__c.External_Folder_Id__c,Folder__c.permissions__c});
				
				boxServiceObj.updateUserTokensInDB(adminUserTokens);
				boxServiceObj.updateAdminUserTokensInDB(adminUserTokens);
			} catch(Exception ex) {
				boxServiceObj.updateAdminUserTokensInDB(adminUserTokens);
				//throw ex;
			}
		}
	}
	
	public static void updatePrivateSiteNotification(Map<Id, CollaborationGroup> mapOfOldCollaborationGroups, Map<Id, CollaborationGroup> mapOfNewCollaborationGroups) {
    	List<App_Notification__c> listOfNotifications = new List<App_Notification__c>();
		try {
			
			for(String cId : mapOfNewCollaborationGroups.keySet()) {
				CollaborationGroup cgObjOld = mapOfOldCollaborationGroups.get(cId);
				CollaborationGroup cgObjNew = mapOfNewCollaborationGroups.get(cId);
				
				if('Private'.equalsIgnoreCase(cgObjOld.CollaborationType) && 'Public'.equalsIgnoreCase(cgObjNew.CollaborationType)) {
					List<App_Notification__c> notificationsList = [Select Id, Status__c, Action_By__c, Action_Comment__c 
							FROM App_Notification__c where Simpplr_Site__r.Chatter_Group_Id__c =: cId and Type__c='Actionable'
							AND (Object_Type__c = 'CollaborationGroupMemberRequest' or Object_Type__c='Subscription') AND Status__c = 'Pending' AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
							
					listOfNotifications.addAll(notificationsList);
				}
			}
			
			UserDao userDaoObj = new UserDao();
			People__c peopleObj = userDaoObj.getUserInfo(UserContext.id);
			for(App_Notification__c notyObj : listOfNotifications) {
				notyObj.Is_New__c = false;
				notyObj.Action_By__c = peopleObj.Id;
				notyObj.Action_Comment__c = 'The Site is no longer Private';
				notyObj.Status__c = 'Approved';
			}
			
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_New__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_Comment__c,
				App_Notification__c.Status__c
			};

			if(!listOfNotifications.isEmpty()) {
	    		NotificationDao.updateNotification(listOfNotifications, listOfColumnsToBeUpdated);
			}
		}catch(Exception ex) {
			throw ex;
		}
    }
    
    @future 
    public static void toggleContentPermissions(List<String> listOfChatterGroupIds, Boolean makePrivateBool) {
    	List<Simpplr_Content__c> listOfSimpplrContents = [select id, Site__r.chatter_Group_Id__c from Simpplr_Content__c
    													   where Is_Deleted__c=false And Site__r.chatter_Group_Id__c=:listOfChatterGroupIds WITH SECURITY_ENFORCED];
		
		if(listOfSimpplrContents.size() > 2000) {
			BatchManageContentPermissions job = new BatchManageContentPermissions('ToggleContentPermissions', listOfChatterGroupIds, makePrivateBool);
			Database.executeBatch(job,2000);  
		} else if(listOfSimpplrContents.size() > 0) {
			utility.toggleContentPermissions(listOfSimpplrContents, makePrivateBool);
		}
    }
}