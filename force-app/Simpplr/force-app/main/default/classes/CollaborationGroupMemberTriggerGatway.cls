public class CollaborationGroupMemberTriggerGatway {
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public void OnBeforeInsert(List<CollaborationGroupMember> newObjects){
        // EXECUTE BEFORE INSERT LOGIC
    }

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	 public void OnAfterInsert(List<CollaborationGroupMember> newList){
	 	if (!Test.isRunningTest()) {
             /** Site Role Part Start */
            CollaborationGroupMemberTriggerHandler.siteRolesOperations(newList, 'insert');
            /** Site Role Part End */
			CollaborationGroupMemberTriggerHandler.createGroupMembership(newList);
	 	}
	 	// when user is added to site via simpplr , because only one member can be added to a site at one go
	 	if(UserContext.Integrations.size()>0 && newList.size() == 1) {
	 		if(newList[0].CollaborationGroup.OwnerId != newList[0].MemberId){
	 			String cgStorage = UserContext.siteStorageMap.get(newList[0].CollaborationGroupId);	 			
	 			Database.executeBatch(new BatchEFSUserSync('SYNC', '["'+newList[0].CollaborationGroupId+'"]', cgStorage));
	 			
		    	// Added mount flag set for dropbox
		    	if(UserContext.isDropboxConnected && cgStorage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
					UserDao.setMountBatchFlag(true, newList[0].MemberId);
		    	}
	 		}
		 }

	 	updatingSiteEditRecord(newList); 	
		addMustReadNotifications(newList);
	 }
 
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void OnBeforeUpdate(List<CollaborationGroupMember> oldList, List<CollaborationGroupMember> newList, Map<Id,CollaborationGroupMember> newMap){
        // BEFORE UPDATE LOGIC
        
    }

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void OnAfterUpdate(List<CollaborationGroupMember> oldList, List<CollaborationGroupMember> newList, Map<Id,CollaborationGroupMember> newMap,Map<Id,CollaborationGroupMember> oldMap){
        if (!Test.isRunningTest()) {
            CollaborationGroupMemberTriggerHandler.deleteGroupMembership(oldList);
            /** Site Role Part Start */
            CollaborationGroupMemberTriggerHandler.siteRolesOperations(newList, 'update');
            /** Site Role Part End */
	        CollaborationGroupMemberTriggerHandler.createGroupMembership(newList);
        }
        if(SimpplrContext.IsBoxIntegrationEnabled && String.isNotBlank(SimpplrContext.boxManagedPermission) && 'simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)){
	        for(CollaborationGroupMember collabGroupMember : oldList){
	        	CollaborationGroupMemberTriggerHandler.usersIdGroupMapOfNewMembers.put(collabGroupMember.CollaborationGroupId,collabGroupMember.memberId);
			}
			Set<String> groupTypeSet = new Set<String>{BoxConstants.BOX_ADMIN_GROUP_TYPE,BoxConstants.BOX_MEMBER_GROUP_TYPE};
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', CollaborationGroupMemberTriggerHandler.usersIdGroupMapOfNewMembers.values());
			String query = 'SELECT Id,Box_User_Id__c,User__c '
								+ ' FROM People_Preference__c ' 
								+ ' WHERE User__c IN: soqlParam1'
								+ ' AND Box_User_Id__c!= NULL ' 
								+ ' AND Box_User_Id__c!= \'\' ';
																			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			CollaborationGroupMemberTriggerHandler.userPreferenceList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

			soqlParamMap.put('soqlParam2', groupTypeSet);
			soqlParamMap.put('soqlParam3', CollaborationGroupMemberTriggerHandler.usersIdGroupMapOfNewMembers.keyset());
			String query1 = 'SELECT Value__c,Chatter_Group_Id__c,Type__c '
								+ ' FROM Simpplr_Metadata__c '
								+ ' WHERE Chatter_Group_Id__c IN: soqlParam3'
								+ ' AND Type__c IN :soqlParam2 '
								+ ' order by LastModifiedDate';	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			CollaborationGroupMemberTriggerHandler.listOfGroupsMetadata = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query1, soqlParamMap);

			soqlParamMap.put('soqlParam4', BoxConstants.BOX_MEMBERSHIP_INFO);
			String query2 = 'SELECT Value__c,User__c ' 
								+ ' FROM Simpplr_Metadata__c ' 
								+ ' WHERE Type__c = : soqlParam4 '
								+ ' AND User__c IN: soqlParam1 '
								+ ' order by LastModifiedDate';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			CollaborationGroupMemberTriggerHandler.listOfChatterUserMapiingWithBoxMetadata = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query2, soqlParamMap);	

			CollaborationGroupMemberTriggerHandler.updateMemberToBoxGroupASYNC(JSON.serialize(CollaborationGroupMemberTriggerHandler.listOfChatterUserMapiingWithBoxMetadata),
																				JSON.serialize(CollaborationGroupMemberTriggerHandler.listOfGroupsMetadata),
																				JSON.serialize(oldMap),
																				JSON.serialize(newMap),
																				JSON.serialize(CollaborationGroupMemberTriggerHandler.userPreferenceList)
																				);    
        }    
    	
    	if(newMap.size() == 1 && oldMap.size() == 1 &&
    	  (UserContext.connectedStorages.contains(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING))){
    		CollaborationGroupMemberTriggerHandler.updateEFSGroups(JSON.serialize(newMap), JSON.serialize(oldMap));
    	}
    	updatingSiteEditRecord(newList);
    }

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void OnBeforeDelete(List<CollaborationGroupMember> oldList, Map<Id,CollaborationGroupMember> oldMap){
    	String storageStr = '';
    	if(UserContext.siteStorageMap.containsKey(oldList.get(0).CollaborationGroupId)) {
    		storageStr = UserContext.siteStorageMap.get(oldList.get(0).CollaborationGroupId);
    	}
        if(!Test.isRunningTest() && oldList.size() == 1 && String.isNotBlank(storageStr) && SimpplrContext.integrations.get(storageStr).Integration_Enabled__c) {

        	//Need to discuss: Whould not this be in after delete and why true for isReadGrp
        	// Move it to after delete and isReadGrp must be conditional  based on role to decide removal  r or rw group
			SiteDao.updateEFSGroup(oldList.get(0).MemberId, oldList.get(0).CollaborationGroupId, true, 'Admin'.equalsIgnoreCase(oldList.get(0).CollaborationRole)?false:true, false, storageStr);
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
    public void OnAfterDelete(List<CollaborationGroupMember> oldList, Map<Id,CollaborationGroupMember> oldMap){
    	if (!Test.isRunningTest()) {
            /** Delete Site Role */
            CollaborationGroupMemberTriggerHandler.siteRolesOperations(oldList, 'delete');
        	CollaborationGroupMemberTriggerHandler.deleteGroupMembership(oldList);
    	}
    	if(SimpplrContext.IsBoxIntegrationEnabled && String.isNotBlank(SimpplrContext.boxManagedPermission) && 'simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)){
        for(CollaborationGroupMember collabGroupMember : oldList){
        	CollaborationGroupMemberTriggerHandler.usersIdGroupMapOfNewMembers.put(collabGroupMember.CollaborationGroupId,collabGroupMember.memberId);
		}
		Set<String> groupTypeSet = new Set<String>{BoxConstants.BOX_ADMIN_GROUP_TYPE,BoxConstants.BOX_MEMBER_GROUP_TYPE};
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', CollaborationGroupMemberTriggerHandler.usersIdGroupMapOfNewMembers.keyset());
		soqlParamMap.put('soqlParam2', groupTypeSet);
		String query = 'SELECT Value__c,Chatter_Group_Id__c '  
						+ ' FROM Simpplr_Metadata__c ' 
						+ ' WHERE Chatter_Group_Id__c IN: soqlParam1 ' 
						+ ' AND Type__c IN :soqlParam2 '
						+ ' order by LastModifiedDate';	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		CollaborationGroupMemberTriggerHandler.listOfGroupsMetadata = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

		soqlParamMap.put('soqlParam3', CollaborationGroupMemberTriggerHandler.usersIdGroupMapOfNewMembers.values());
		soqlParamMap.put('soqlParam4', BoxConstants.BOX_MEMBERSHIP_INFO);
		String query1 = 'SELECT Value__c,User__c '
							+ ' FROM Simpplr_Metadata__c '
							+ ' WHERE Type__c = :soqlParam4 '
							+ ' AND User__c IN: soqlParam3 '
							+ ' order by LastModifiedDate';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		CollaborationGroupMemberTriggerHandler.listOfChatterUserMapiingWithBoxMetadata = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query1, soqlParamMap);																			
		CollaborationGroupMemberTriggerHandler.removeMemberFromBoxGroup_ASYNC(JSON.serialize(CollaborationGroupMemberTriggerHandler.listOfChatterUserMapiingWithBoxMetadata),
																			JSON.serialize(CollaborationGroupMemberTriggerHandler.listOfGroupsMetadata)
																			);
    	}
		updatingSiteEditRecord(oldList);
		removeMustReadNotifications(oldList);
    }

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public void OnUndelete(List<CollaborationGroupMember> newList){
        // AFTER UNDELETE LOGIC
    }
    
    public void updatingSiteEditRecord(List<CollaborationGroupMember> colGrpList){
		List<Simpplr_Site__c> listOfSimpplrSite = [Select Id from Simpplr_Site__c Where Chatter_Group_Id__c = :colGrpList[0].CollaborationGroupId];
		listOfSimpplrSite[0].Last_Edited_DateTime__c = DateTime.now();

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(listOfSimpplrSite), new List<Schema.SObjectField>{
				Simpplr_Site__c.Last_Edited_DateTime__c
		});
	}

	public void addMustReadNotifications(List<CollaborationGroupMember> colGrpList){
		Map<String, Set<String>> memberIdToSetOfFollowedCGIdSet = new Map<String, Set<String>>();
		for(CollaborationGroupMember cgm : colGrpList){
			if(memberIdToSetOfFollowedCGIdSet.get(cgm.MemberId) == null){
				memberIdToSetOfFollowedCGIdSet.put(cgm.MemberId, new Set<String>());
			}
			memberIdToSetOfFollowedCGIdSet.get(cgm.MemberId).add(cgm.CollaborationGroupId);
		}
		BatchMustReadNotifications job = new BatchMustReadNotifications(memberIdToSetOfFollowedCGIdSet, 'mustReadsNotificationOnSiteFollow');
		Database.executeBatch(job,100);
		
	}

	public void removeMustReadNotifications(List<CollaborationGroupMember> colGrpList){
		Map<String, Set<String>> memberIdToSetOfFollowedCGIdSet = new Map<String, Set<String>>();
		for(CollaborationGroupMember cgm : colGrpList){
			if(memberIdToSetOfFollowedCGIdSet.get(cgm.MemberId) == null){
				memberIdToSetOfFollowedCGIdSet.put(cgm.MemberId, new Set<String>());
			}
			memberIdToSetOfFollowedCGIdSet.get(cgm.MemberId).add(cgm.CollaborationGroupId);
		}
		BatchMustReadNotifications job = new BatchMustReadNotifications(memberIdToSetOfFollowedCGIdSet, 'removeMustReadsNotificationOnSitenUnFollow');
		Database.executeBatch(job,100);
		
	}
}