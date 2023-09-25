public with sharing class ActiveDirectoryHelper {

    

	/**
	 * @description- method to update selected and removed AD groups to SF DB
	 * @param - listOfActiveDirectoryGroupsSelected groups to be added
	 * @param - listOfActiveDirectoryGroupsRemoved groups to be removed
	 */
	public void updateADGroupsInDB(List<ActiveDirectoryModel.ADGroup> listOfActiveDirectoryGroupsSelected,
		List<ActiveDirectoryModel.ADGroup> listOfActiveDirectoryGroupsRemoved, Boolean isADGroupsV2Enabled) {

        List<Active_Directory_Group__c> listOfADGroups = getSelectedActiveDirectoryGroups(); 
		Map<String, String> adGroupIdToSFIdMap = new Map<String, String>();
		for(Active_Directory_Group__c adGroupObj : listOfADGroups) {
			adGroupIdToSFIdMap.put(adGroupObj.AD_Object_Id__c, adGroupObj.Id);
		}

		List<Active_Directory_Group__c> upsertADGroupsList = new List<Active_Directory_Group__c>();
		List<Active_Directory_Group__c> deleteADGroupsList = new List<Active_Directory_Group__c>();

		for(ActiveDirectoryModel.ADGroup selectedGroup : listOfActiveDirectoryGroupsSelected) {
			String adGroupId = selectedGroup.id;
			Active_Directory_Group__c adGroupObj;
			if(adGroupIdToSFIdMap.containsKey(adGroupId)) {
				 adGroupObj = new Active_Directory_Group__c(id = adGroupIdToSFIdMap.get(adGroupId));
			} else {
				adGroupObj = new Active_Directory_Group__c();
			}
			adGroupObj.AD_Object_Id__c = adGroupId;
			adGroupObj.Name__c = selectedGroup.name;
			adGroupObj.Email__c = selectedGroup.email;
			adGroupObj.Mail_Enabled__c = false;
			adGroupObj.Security_Enabled__c = false;
			if (isADGroupsV2Enabled) {
				adGroupObj.AD_Group_Type__c = selectedGroup.groupType;
				if(selectedGroup.groupType.equalsIgnoreCase('microsoft365')) {
					adGroupObj.Mail_Enabled__c = true;
				} else if (selectedGroup.groupType.equalsIgnoreCase('security')) {
					adGroupObj.Security_Enabled__c = true;
				}
			} else {
				List<String> groupTypesList = selectedGroup.groupTypes;
				if(groupTypesList.isEmpty()) {
					adGroupObj.Security_Enabled__c = true;
					adGroupObj.AD_Group_Type__c = 'security';
				} else if(groupTypesList[0].equalsIgnoreCase('Unified')) {
					adGroupObj.Mail_Enabled__c = true;	
					adGroupObj.AD_Group_Type__c = 'microsoft365';
				}
			}

			upsertADGroupsList.add(adGroupObj);
		}

		for(ActiveDirectoryModel.ADGroup removedGroup : listOfActiveDirectoryGroupsRemoved) {
			String adGroupId = removedGroup.id;
			if(adGroupIdToSFIdMap.containsKey(adGroupId)) {
				Active_Directory_Group__c adGroupObj = new Active_Directory_Group__c(id = adGroupIdToSFIdMap.get(adGroupId));
				deleteADGroupsList.add(adGroupObj);
			}
		}

		if(!upsertADGroupsList.isEmpty()) {

			List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
			listOfModifiedFields.add(Active_Directory_Group__c.AD_Object_Id__c);
			listOfModifiedFields.add(Active_Directory_Group__c.Name__c);
			listOfModifiedFields.add(Active_Directory_Group__c.Email__c);
			listOfModifiedFields.add(Active_Directory_Group__c.AD_Group_Type__c);
			listOfModifiedFields.add(Active_Directory_Group__c.Mail_Enabled__c);
			listOfModifiedFields.add(Active_Directory_Group__c.Security_Enabled__c);
			

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().upsertAsUser(upsertADGroupsList,listOfModifiedFields);			
		}

		List<Active_Directory_Group__c> adGroupsToUpdateList = new List<Active_Directory_Group__c>();
		for(Active_Directory_Group__C adGroupObj : deleteADGroupsList) {
			Active_Directory_Group__c adGroupObjToUpdate = new Active_Directory_Group__c(Id = adGroupObj.Id);
			adGroupObjToUpdate.Is_Deleted__c = true;
			adGroupsToUpdateList.add(adGroupObjToUpdate);
		} 		

		if(!adGroupsToUpdateList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Active_Directory_Group__c>(adGroupsToUpdateList), new List<Schema.SObjectField>{
                Active_Directory_Group__c.Is_Deleted__c
                });
		}

	}    

    public List<Active_Directory_Group__c>  getSelectedActiveDirectoryGroups() {
		String query = 'SELECT Id, AD_Object_Id__c FROM Active_Directory_Group__c WHERE Is_Deleted__c = false LIMIT 40000';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Active_Directory_Group__c> listOfADGroups = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUser(query, null);    
        return listOfADGroups;
    }  
	
	/**
	 * @description For getting activeGroupIds from audienceRuleJson Str
	 * @param String audienceRuleStr
	 * @return Set<String>
	 */
	public static Set<String> getActiveDirectoryGroupIds(String audienceRuleStr) {
		Set<String> activeDirectoryGroupIds = new Set<String>();
		List<Map<String, Set<String>>> audienceRuleMapList = null;
		if (String.isNotBlank(audienceRuleStr)){
			audienceRuleMapList = (List<Map<String, Set<String>>>) Json.deserialize(audienceRuleStr, Type.forName('List<Map<String, Set<String>>>'));
			if(!audienceRuleMapList.isEmpty() && audienceRuleMapList[0].containsKey('aDGroupSet')) {
				activeDirectoryGroupIds.addAll(audienceRuleMapList[0].get('aDGroupSet'));
			}
		}
		return activeDirectoryGroupIds;
	}

	/**
	 * @description For getting activeDirectory groups for set of setOfActiveDirectoryGroups
	 * @param Set<String> setOfActiveDirectoryGroups
	 * @return Map<String, Active_Directory_Group__c>
	 */	
	public static Map<String, Active_Directory_Group__c> getSelectedActiveDirectoryGroups(Set<String> setOfActiveDirectoryGroups) {
		Map<String, Active_Directory_Group__c> adIdToADObjectMap = new Map<String, Active_Directory_Group__c>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		String query = 'SELECT id, name, name__c, Email__c, AD_Object_Id__c, Mail_Enabled__c,' +
				' Security_Enabled__c FROM Active_Directory_Group__c ' +
				' WHERE AD_Object_Id__c IN :soqlParam1 AND Is_Deleted__c = false';
		soqlParamMap.put('soqlParam1', setOfActiveDirectoryGroups);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Active_Directory_Group__c> listOfADGroup = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		for (Active_Directory_Group__c aDGrpObj : listOfADGroup) {
			adIdToADObjectMap.put(aDGrpObj.AD_Object_Id__c, aDGrpObj);
		}
		return adIdToADObjectMap;
	}

	/**
	 * @description method to return which AD Group Types are selected
	 * @return `ActiveDirectoryModel.SelectedGroupTypes`
	 */
	public ActiveDirectoryModel.SelectedGroupTypes getSelectedGroupTypesWrapper(Boolean isADGroupsV2Enabled) {
		ActiveDirectoryModel.SelectedGroupTypes selectedGroupTypesWrapperObj = new ActiveDirectoryModel.SelectedGroupTypes();
		selectedGroupTypesWrapperObj.isMailGroupsSelected = false;
		selectedGroupTypesWrapperObj.isSecurityGroupsSelected = false;
		
		if(isADGroupsV2Enabled) {
			selectedGroupTypesWrapperObj.isMailSecurityGroupsSelected = false;
			selectedGroupTypesWrapperObj.isDistributionGroupsSelected = false;

			String query = 'SELECT Count(Id), AD_Group_Type__c FROM Active_Directory_Group__c GROUP BY AD_Group_Type__c';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<AggregateResult> listOfADGroupType = SIMPESAPI.accessController().queryAsUSer(query, null);
			for(AggregateResult ar: listOfADGroupType) {
				if(ar.get('AD_Group_Type__c') == 'microsoft365') {
					selectedGroupTypesWrapperObj.isMailGroupsSelected = true;
				} else if(ar.get('AD_Group_Type__c') == 'security') {
					selectedGroupTypesWrapperObj.isSecurityGroupsSelected = true;
				} else if(ar.get('AD_Group_Type__c') == 'mail-security') {
					selectedGroupTypesWrapperObj.isMailSecurityGroupsSelected = true;
				} else if(ar.get('AD_Group_Type__c') == 'distribution') {
					selectedGroupTypesWrapperObj.isDistributionGroupsSelected = true;
				}
			}
			
		} else {
			String query = 'SELECT Id FROM Active_Directory_Group__c WHERE Mail_Enabled__c = TRUE AND Is_Deleted__c = false LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Active_Directory_Group__c> listOfADGroup = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
			if(!listOfADGroup.isEmpty()) {
				selectedGroupTypesWrapperObj.isMailGroupsSelected = true;
			} 
			query = 'SELECT Id FROM Active_Directory_Group__c WHERE Security_Enabled__c = TRUE AND Is_Deleted__c = false LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			listOfADGroup = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUSer(query, null);	
			if(!listOfADGroup.isEmpty()) {
				selectedGroupTypesWrapperObj.isSecurityGroupsSelected = true;
			}
		}
		
		return selectedGroupTypesWrapperObj;	
	}

    public void syncGroupsDeletedFromADPortal(List<Object> adGroupIdsDeletedFromPortal) {
        
		List<String> adGroupIdsDeletedFromPortalList = objectListToStringList(adGroupIdsDeletedFromPortal);
        // delete AD Groups from List
        deleteActiveDirectoryGroups(adGroupIdsDeletedFromPortalList);
		// check if AD Group is selected
		Boolean isADGroupSelected = isADGroupSelected();
		if(!isADGroupSelected) {
			// Update AD Groups Config
			updateADGroupsEnabledConfig();
		}
		// call Batch to Sync Audience
		Database.executeBatch(new BatchSyncAudienceMembersFromAD('updateRemovedADGroupAudience', new Set<String>(adGroupIdsDeletedFromPortalList), true), 1);
    }

	public void updateADGroupsEnabledConfig() {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY);
		String query = 'SELECT Id, Active_Directory_Groups_Enabled__c FROM App_Integration__c WHERE Name =: soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_Integration__c> appIntegrationList = (List<App_Integration__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		if(!appIntegrationList.isEmpty()) {
			App_Integration__c appIntegrationObj = appIntegrationList[0];
			appIntegrationObj.Active_Directory_Groups_Enabled__c = false;
            SIMPESAPI.accessController().updateAsUser(appIntegrationObj, new List<Schema.SObjectField>{
                App_Integration__c.Active_Directory_Groups_Enabled__c});  			
		} 
	}

	public Boolean isADGroupSelected() {
		Boolean isADGroupSelected = true;
		String query = 'SELECT Id FROM Active_Directory_Group__c WHERE Is_Deleted__c = false LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Active_Directory_Group__c> listOfADGroup = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUSer(query, null);		
		if(listOfADGroup.isEmpty()) {
			isADGroupSelected = false;
		}
		return isADGroupSelected;
	}

    private List<String> objectListToStringList(List<Object> objectList) {
        List<String> stringList = new List<String>();
        for(Object obj : objectList) {
            String element = (String)obj;
            stringList.add(element);
        }
        return stringList;
    }

    private static void deleteActiveDirectoryGroups(List<String> adGroupIdsDeletedFromPortalList) {
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', adGroupIdsDeletedFromPortalList);
        String query = 'SELECT Id FROM Active_Directory_Group__c WHERE AD_Object_Id__c =: soqlParam1 AND Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Active_Directory_Group__c> adGroupsToDeleteList = (List<Active_Directory_Group__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap); 
		List<Active_Directory_Group__c> adGroupsToUpdateList = new List<Active_Directory_Group__c>();
		for(Active_Directory_Group__C adGroupObj : adGroupsToDeleteList) {
			adGroupObj.Is_Deleted__c = true;
			adGroupsToUpdateList.add(adGroupObj);
		} 
		if(!adGroupsToUpdateList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Active_Directory_Group__c>(adGroupsToUpdateList), new List<Schema.SObjectField>{
                Active_Directory_Group__c.Is_Deleted__c
                });
		}		       
    }	
	
}