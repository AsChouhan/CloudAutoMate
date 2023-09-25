public with sharing class CollaborationGroupTriggerHandler {

	/*
	private final String STR_KEY_SITE_DUPLICATE_NAME_NOT_ALLOWED = 'manage_sites.duplicate_site_name_error_message';
	*/

	public void initLangKeyValueMap() {
        Set<String> localeSet = new Set<String>{Utility.getSimpplrLanguageLocaleKey(UserContext.languagelocalekey)};		
		LocaleContext.getAllLabelMap('CollaborationGroupTriggerHandler', new List<String>(localeSet));
    }

    public void onBeforeInsert (List<CollaborationGroup> listOfNewCollaborationGroups) {
		checkForExistingDuplicateSite(listOfNewCollaborationGroups, null, false);
    }
    
    public void onAfterInsert (Map<Id, CollaborationGroup> mapOfNewCollaborationGroups) {
    	if(SimpplrContext.isATSimpplrSiteEnabled) {
	    	SiteDao siteDaoObj = new SiteDao();
	    	// Restricted not to make simpplr site from collaboration group of community
	    	Map<Id,CollaborationGroup> mapOfCollabGrpWithoutCommunity = new Map<Id,CollaborationGroup>();
	    	for(CollaborationGroup grp : mapOfNewCollaborationGroups.values()){
    			if(SimpplrContext.isCommunitiesEnabled == false || grp.get('NetworkId') == null) {
    				mapOfCollabGrpWithoutCommunity.put(grp.Id,grp);
	    		}
	    	}
	    	if(Utility.IsSiteCreationFromSimpplrUI == false) {
	    		siteDaoObj.createSimpplrSites(mapOfCollabGrpWithoutCommunity.values());
	    	}
    	}
    }
    
    public void onBeforeUpdate (Map<Id, CollaborationGroup> mapOfOldCollaborationGroups, Map<Id, CollaborationGroup> mapOfNewCollaborationGroups) {
    	checkForExistingDuplicateSite(mapOfNewCollaborationGroups.values(), mapOfOldCollaborationGroups, true);
		CollaborationGroupTriggerGatway.updatePrivateSiteNotification(mapOfOldCollaborationGroups, mapOfNewCollaborationGroups);
    	if(mapOfOldCollaborationGroups.size() == 1 && mapOfNewCollaborationGroups.size() == 1 && (mapOfOldCollaborationGroups.values().get(0).ownerId != mapOfNewCollaborationGroups.values().get(0).ownerId)){
			SiteDao siteDaoObj = new SiteDao();
	    	siteDaoObj.transferOwnershipInEFS(mapOfNewCollaborationGroups.values().get(0).Id,mapOfNewCollaborationGroups.values().get(0).OwnerId,mapOfOldCollaborationGroups.values().get(0).OwnerId);
		}
    }
    
    public void onAfterUpdate (Map<Id, CollaborationGroup> mapOfOldCollaborationGroups, Map<Id, CollaborationGroup> mapOfNewCollaborationGroups) {
    	CollaborationGroupTriggerGatway.updateSimpplrRecords(mapOfOldCollaborationGroups, mapOfNewCollaborationGroups);
    }
    
    public void onBeforeDelete (Map<Id, CollaborationGroup> mapOfOldCollaborationGroups) {
    	set<Id> chatterGroupIdWithContentSet = new set<Id>();
    	for(simpplr_content__c contentObj : [select id,site__r.Chatter_Group_Id__c from simpplr_content__c where is_deleted__c = false AND site__r.Chatter_Group_Id__c IN :mapOfOldCollaborationGroups.keySet() WITH SECURITY_ENFORCED]){
    		chatterGroupIdWithContentSet.add(contentObj.site__r.Chatter_Group_Id__c);
    	}
    	List<Simpplr_Site__c> lstSimpplrSite = new List<Simpplr_Site__c>();
    	if(!mapOfOldCollaborationGroups.isEmpty()){
    		lstSimpplrSite = [select chatter_Group_Id__c from Simpplr_Site__c where chatter_Group_Id__c IN :mapOfOldCollaborationGroups.keySet() WITH SECURITY_ENFORCED];
    	}
    	Set<Id> mandatorySiteCGIdSet = new Set<Id>();
    	for(Simpplr_Site__c siteObj : lstSimpplrSite){
    		mandatorySiteCGIdSet.add(siteObj.chatter_Group_Id__c);
    	} 
    	for(CollaborationGroup groupObj : mapOfOldCollaborationGroups.values()){
    		if(chatterGroupIdWithContentSet.contains(groupObj.id)){
    			groupObj.addError(ServiceConstants.COLLABORATION_GROUP_DELETE_ERROR_MESSAGE);
    		}
			if(mandatorySiteCGIdSet.contains(groupObj.id) && !(UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission)){
				groupObj.addError('"You do not have permission to delete Mandatory Sites"');
			}
    	}
    }
    
    public void OnAfterDelete (Map<Id, CollaborationGroup> mapOfOldCollaborationGroups) {
    	List<Simpplr_Site__c> listToUpdate = new List<Simpplr_Site__c>();
    	for(Simpplr_Site__c siteObj : [select id,Is_Deleted__c from Simpplr_Site__c where Chatter_Group_Id__c IN : mapOfOldCollaborationGroups.keySet() WITH SECURITY_ENFORCED]){
    		siteObj.Is_Deleted__c = true;
			siteObj.Is_Active__c = false;
			siteObj.Last_Edited_DateTime__c = Datetime.now();
    		listToUpdate.add(siteObj);
    	}
    	if(listToUpdate.size()>0){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(listToUpdate),
														new List<Schema.SObjectField>{Simpplr_Site__c.Is_Deleted__c,
																					  Simpplr_Site__c.Is_Active__c,
																					  Simpplr_Site__c.Last_Edited_DateTime__c});
    	}
    }

	private void checkForExistingDuplicateSite(List<CollaborationGroup> listOfNewCollaborationGroups, Map<Id, CollaborationGroup> mapOfOldCollaborationGroups, Boolean isCollaborationGroupUpdated) {
		if (!Test.isRunningTest()) {
			Map<String, CollaborationGroup> groupNameDataMap = new Map<String, CollaborationGroup>();
			for (CollaborationGroup collGroup : listOfNewCollaborationGroups) {
				if (isCollaborationGroupUpdated) {
					if (!collGroup.Name.equalsIgnoreCase(mapOfOldCollaborationGroups.get(collGroup.Id).Name)) {
						groupNameDataMap.put(collGroup.Name, collGroup);
					}
				} else {
					groupNameDataMap.put(collGroup.Name, collGroup);
				}
			}

			SiteDao siteDaoObj = new siteDao();
			Map<String,CollaborationGroup> mapOfCollaborationGroup = siteDaoObj.getNameVsCollaborationGroupMap(groupNameDataMap.keySet());
			initLangKeyValueMap();
			for (CollaborationGroup grpObj : groupNameDataMap.values()) {
				if (mapOfCollaborationGroup.keySet().contains(grpObj.Name.toLowerCase())) {
					(groupNameDataMap.get(grpObj.Name)).Name.addError(
						LocaleContext.getLabel( UserContext.languageLocaleKey, 'manage_sites.duplicate_site_name_error_message')
					);
				}
			}
		}
	}
}