public with sharing class CollaborationGroupMemberTriggerHandler {
	public static Map<String,String> usersIdGroupMapOfNewMembers = New Map<String,String>(); 
	public static List<Id> collabGroupsToFetch = new List<Id>();
	public static List<Simpplr_Metadata__c> listOfGroupsMetadata = new List<Simpplr_Metadata__c>();
	public static List<People_Preference__c> userPreferenceList= new List<People_Preference__c>();
	public static List<Simpplr_Metadata__c> listOfChatterUserMapiingWithBoxMetadata = new List<Simpplr_Metadata__c>();
	public static String boxAdminSfUserId = null;

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	@future (callout =true)
	public static void updateMemberToBoxGroupASYNC(String metadataForUserJson,String metadataForGroupJson,String oldMapJson,String newMapJson,String listOfPreferenceJson){
		BoxService service = new BoxService();
		List<Simpplr_Metadata__c>recordToUpsert = new List<Simpplr_Metadata__c>();
		List<People_Preference__c> listOfPreference = (List<People_Preference__c>) JSON.deserialize(listOfPreferenceJson, Type.forName('List<People_Preference__c>'));
		Map<Id,CollaborationGroupMember> oldMap = (Map<Id,CollaborationGroupMember>)JSON.deserialize(oldMapJson,Type.forName('Map<Id,CollaborationGroupMember>'));
		Map<Id,CollaborationGroupMember> newMap = (Map<Id,CollaborationGroupMember>)JSON.deserialize(newMapJson,Type.forName('Map<Id,CollaborationGroupMember>'));
		List<Simpplr_Metadata__c> metadataForUser = (List<Simpplr_Metadata__c>) JSON.deserialize(metadataForUserJson, Type.forName('List<Simpplr_Metadata__c>'));
		List<Simpplr_Metadata__c> metadataForGroup = (List<Simpplr_Metadata__c>) JSON.deserialize(metadataForGroupJson, Type.forName('List<Simpplr_Metadata__c>'));
		CollaborationGroupMember oldMember;
		Map<String,String> sfUserAndBoxIdMap = new Map<String,String>();
		Map<String,String> sfBoxIxAndUserMap = new Map<String,String>();
		Map<String,List<String>> groupAndMemberListMap = new Map<String,List<String>>();
		Map <String,List<Simpplr_Metadata__c>> ChatterGroupAndMetaDataListMap = new Map<String,List<Simpplr_Metadata__c>>();	
		List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
		Set<Schema.SObjectField> setOfModifiedFields = new Set<Schema.SObjectField>();
		for(People_Preference__c preference : listOfPreference){
			sfUserAndBoxIdMap.put(preference.User__c,preference.Box_User_Id__c);
			sfBoxIxAndUserMap.put(preference.Box_User_Id__c,preference.User__c);
		}
		Map<String,Simpplr_Metadata__c> userAndMetaInfoMap = new Map<String,Simpplr_Metadata__c>();
		for(Simpplr_Metadata__c userMeta : metadataForUser){
			userAndMetaInfoMap.put(userMeta.user__c,userMeta);
		}
		if(metadataForUser.size() > 0 ){
			setOfModifiedFields.add(Simpplr_Metadata__c.value__c);	
			setOfModifiedFields.add(Simpplr_Metadata__c.User__c);	
		}

		for(Simpplr_Metadata__c groupMetaInfo : metadataForGroup){
			if(ChatterGroupAndMetaDataListMap.containsKey(groupMetaInfo.Chatter_Group_Id__c)){
				ChatterGroupAndMetaDataListMap.get(groupMetaInfo.Chatter_Group_Id__c).add(groupMetaInfo);
			}else{
				ChatterGroupAndMetaDataListMap.put(groupMetaInfo.Chatter_Group_Id__c,new List<Simpplr_Metadata__c>{groupMetaInfo});
			}
		}
		
		BoxWrapper.UserTokens userTokensObj = service.getUserTokens(false,boxAdminSfUserId);
		String accessToken = userTokensObj != null && !String.isBlank(userTokensObj.accessToken) ? userTokensObj.accessToken : null;
		Object result;
		//logger.logDebug('~~~~~~~~~~~~~~ChatterGroupAndMetaDataListMap'+ChatterGroupAndMetaDataListMap);
		for(CollaborationGroupMember newMember : newMap.values()){
			oldMember = oldMap.get(newMember.Id);
			if(!oldMember.CollaborationRole.equalsIgnoreCase(newMember.CollaborationRole)){
				List<Simpplr_Metadata__c> currentGroupMetaList = ChatterGroupAndMetaDataListMap.get(newMember.CollaborationGroupId)== null ? new List<Simpplr_Metadata__c>():ChatterGroupAndMetaDataListMap.get(newMember.CollaborationGroupId);
				String adminBoxGroupId = '';
				String memberBoxGroupId = '';
				for(Simpplr_Metadata__c  groupMeta : currentGroupMetaList){
					if(groupMeta.Type__c.equalsIgnoreCase(BoxConstants.BOX_MEMBER_GROUP_TYPE)){
						memberBoxGroupId = groupMeta.Value__c;
					}
					else if(groupMeta.Type__c.equalsIgnoreCase(BoxConstants.BOX_ADMIN_GROUP_TYPE)){
						adminBoxGroupId = groupMeta.Value__c;
					}
				}
				if(newMember.CollaborationRole.equalsIgnoreCase('Admin')){
					//logger.logDebug('this is in admin role');
					String boxUserId = sfUserAndBoxIdMap.get(newMember.memberId);
					//logger.logDebug('~~~~~~~~~~~~~~~~~adminBoxGroupId'+adminBoxGroupId);
					if(!String.isBlank(adminBoxGroupId) && !String.isBlank(boxUserId)){
						
						result = service.addMemberIntoGroup(boxUserId, adminBoxGroupId, accessToken);
						Simpplr_Metadata__c userBoxGroupAndMembershipInfo;
						if(!userAndMetaInfoMap.containsKey(newMember.memberId)){
							userBoxGroupAndMembershipInfo = New Simpplr_Metadata__c(
																						value__c = '{}',
																						User__c = newMember.memberId,
																						type__C = BoxConstants.BOX_MEMBERSHIP_INFO
																					);
							userAndMetaInfoMap.put(newMember.memberId,userBoxGroupAndMembershipInfo);
							setOfModifiedFields.add(Simpplr_Metadata__c.value__c);	
							setOfModifiedFields.add(Simpplr_Metadata__c.User__c);	
							setOfModifiedFields.add(Simpplr_Metadata__c.type__C);																				
						}
						Simpplr_Metadata__c userMemberInfoMeta = addMemberResultParse(result,adminBoxGroupId,userAndMetaInfoMap.get(newMember.memberId));
						if(userMemberInfoMeta != null && String.isNotBlank(userMemberInfoMeta.Value__c)) {			
							setOfModifiedFields.add(Simpplr_Metadata__c.value__c);	
						}
						userAndMetaInfoMap.put(newMember.memberId,userMemberInfoMeta);
						//logger.logDebug(result);
					}
					
				}else{
					Simpplr_Metadata__c curentUserMembershipInfoMeta = userAndMetaInfoMap.get(newMember.memberId);
					if(curentUserMembershipInfoMeta != null && String.isNotBlank(curentUserMembershipInfoMeta.value__c)) {
						Map<String,String> membershipInfomap = 	(Map<String,String>)JSON.deserialize(curentUserMembershipInfoMeta.value__c, Type.forName('Map<String,String>'));										 								
						String groupMemberShipId = membershipInfomap.get(adminBoxGroupId);
						//logger.logDebug('groupMemberShipId~~~~~~~~~~~~~'+groupMemberShipId);
						if(!String.isBlank(groupMemberShipId)){
							result = service.removeMemberFromGroup(groupMemberShipId, accessToken);
							//logger.logDebug(result);
							if(result instanceof string){
								if(((String)result).equalsIgnoreCase(BoxConstants.BOX_EMPTY_SUCCESS_RESPONSE)){
									membershipInfomap.remove(adminBoxGroupId);
									curentUserMembershipInfoMeta.Value__c = JSON.serialize(membershipInfomap);
									userAndMetaInfoMap.put(newMember.memberId,curentUserMembershipInfoMeta);
									setOfModifiedFields.add(Simpplr_Metadata__c.value__c);
								}
							
							}else if(result instanceof BoxWrapper.BoxErrorWrapper){
								BoxWrapper.BoxErrorWrapper errorClass = (BoxWrapper.BoxErrorWrapper )result;
								//logger.logDebug(errorClass.message+'Error in Box remove');
							}
						}												 		
					}
				}
			}
		}
		listOfModifiedFields.addAll(setOfModifiedFields);
		recordToUpsert.addAll(userAndMetaInfoMap.values());
		service.updateUserTokensInDB(userTokensObj);
		if(recordToUpsert.size() > 0){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().upsertAsUser(recordToUpsert,listOfModifiedFields);
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
	public static void AddMemberToBoxGroupASYNC(String listOfPreferenceJson,String groupMetaDataListJson,String newListJson){
		
		
			List<Simpplr_Metadata__c> recordToUpsert = New List<Simpplr_Metadata__c>();
			List<CollaborationGroupMember> newList = (List<CollaborationGroupMember>)JSON.deserialize(newListJson,Type.forName('List<CollaborationGroupMember>'));
			List<Simpplr_Metadata__c> groupMetaDataList = (List<Simpplr_Metadata__c>) JSON.deserialize(groupMetaDataListJson, Type.forName('List<Simpplr_Metadata__c>'));
			List<People_Preference__c> listOfPreference = (List<People_Preference__c>) JSON.deserialize(listOfPreferenceJson, Type.forName('List<People_Preference__c>'));
			Map<String,String> sfUserAndBoxIdMap = new Map<String,String>();
			Map<String,String> sfBoxIxAndUserMap = new Map<String,String>();
			Map<String,List<String>> groupAndMemberListMap = new Map<String,List<String>>();
			List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
			for(People_Preference__c preference : listOfPreference){
				sfUserAndBoxIdMap.put(preference.User__c,preference.Box_User_Id__c);
				sfBoxIxAndUserMap.put(preference.Box_User_Id__c,preference.User__c);
			}
			
			Map<String,List<CollaborationGroupMember>> groupAndMembersListMap = new Map<String,List<CollaborationGroupMember>>();
			for(CollaborationGroupMember  collabGroupMember : newList){
				if(groupAndMembersListMap.containsKey(collabGroupMember.CollaborationGroupId)){
					groupAndMembersListMap.get(collabGroupMember.CollaborationGroupId).add(collabGroupMember);
				}else{
					groupAndMembersListMap.put(collabGroupMember.CollaborationGroupId,new List<CollaborationGroupMember>{collabGroupMember});
				}
			}
			Map <String,List<Simpplr_Metadata__c>> ChatterGroupAndMetaDataListMap = new Map<String,List<Simpplr_Metadata__c>>();
			for(Simpplr_Metadata__c groupMetaInfo : groupMetaDataList){
				if(ChatterGroupAndMetaDataListMap.containsKey(groupMetaInfo.Chatter_Group_Id__c)){
					ChatterGroupAndMetaDataListMap.get(groupMetaInfo.Chatter_Group_Id__c).add(groupMetaInfo);
				}else{
					ChatterGroupAndMetaDataListMap.put(groupMetaInfo.Chatter_Group_Id__c,new List<Simpplr_Metadata__c>{groupMetaInfo});
				}
			}
			
			if(groupMetaDataList.size() >0){
				
				for(List<CollaborationGroupMember> memberChatterList : groupAndMembersListMap.values()){
					for(CollaborationGroupMember memberChatter : memberChatterList){
						if(!String.isBlank(sfUserAndBoxIdMap.get(memberChatter.memberId))){
							List<Simpplr_Metadata__c> MemberGroupMetaData = ChatterGroupAndMetaDataListMap.get(memberChatter.CollaborationGroupId)==null? new List<Simpplr_Metadata__c>():ChatterGroupAndMetaDataListMap.get(memberChatter.CollaborationGroupId);
							if(memberChatter.CollaborationRole.equalsIgnoreCase('Admin')){
								for(Simpplr_Metadata__c metadata : MemberGroupMetaData){
									if(groupAndMemberListMap.containsKey(metadata.Value__c)){
										groupAndMemberListMap.get(metadata.Value__c).add(sfUserAndBoxIdMap.get(memberChatter.memberId));
									}else{
										groupAndMemberListMap.put(metadata.Value__c,new List<String>{sfUserAndBoxIdMap.get(memberChatter.memberId)});
									}
								}
					
							}else if(memberChatter.CollaborationRole.equalsIgnoreCase('Standard')){
								for(Simpplr_Metadata__c metadata : MemberGroupMetaData){
									if(metadata.Type__c.equalsIgnoreCase(BoxConstants.BOX_MEMBER_GROUP_TYPE)){
										if(groupAndMemberListMap.containsKey(metadata.Value__c)){
											groupAndMemberListMap.get(metadata.Value__c).add(sfUserAndBoxIdMap.get(memberChatter.memberId));
										}else{
											groupAndMemberListMap.put(metadata.Value__c,new List<String>{sfUserAndBoxIdMap.get(memberChatter.memberId)});
										}
									}
								}
							
							}
						}
					}
				}
			}
			BoxService service = new BoxService();
			//logger.logDebug('~~~~~~~~~~~~~~~~~~~~boxAdminSfUserId~~~'+boxAdminSfUserId);
			BoxWrapper.UserTokens userTokensObj = service.getUserTokens(false,boxAdminSfUserId);
			if(userTokensObj!=null && !String.isBlank(userTokensObj.accessToken)){
				Map<String,Simpplr_Metadata__c> userAndMetaInfoMap = new Map<String,Simpplr_Metadata__c>();				
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', BoxConstants.BOX_MEMBERSHIP_INFO);
				soqlParamMap.put('soqlParam2', sfUserAndBoxIdMap.keyset());
				String query = 'SELECT value__c,User__c '
									+ ' FROM Simpplr_Metadata__c '
									+ ' WHERE type__C =: soqlParam1 '
									+ ' AND User__c IN:soqlParam2';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				for(Simpplr_Metadata__c userMeta : (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap)){
					userAndMetaInfoMap.put(userMeta.user__c,userMeta);													
												
				}
				for(String groupId : groupAndMemberListMap.keyset()){
					for(String boxUserId :  groupAndMemberListMap.get(groupId)){
						//logger.logDebug(boxUserId+'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~boxUserId');
						Object result = service.addMemberIntoGroup(boxUserId,groupId,userTokensObj.accessToken);
						Simpplr_Metadata__c userBoxGroupAndMembershipInfo;
						if(!userAndMetaInfoMap.containsKey(sfBoxIxAndUserMap.get(boxUserId))){
							userBoxGroupAndMembershipInfo = New Simpplr_Metadata__c(
																						value__c = '{}',
																						User__c = sfBoxIxAndUserMap.get(boxUserId),
																						type__C = BoxConstants.BOX_MEMBERSHIP_INFO
																					);
							listOfModifiedFields.add(Simpplr_Metadata__c.value__c);
							listOfModifiedFields.add(Simpplr_Metadata__c.User__c);
							listOfModifiedFields.add(Simpplr_Metadata__c.type__C);
							userAndMetaInfoMap.put(sfBoxIxAndUserMap.get(boxUserId),userBoxGroupAndMembershipInfo);																					
						}	
						Simpplr_Metadata__c userMemberInfoMeta = addMemberResultParse(result,groupId,userAndMetaInfoMap.get(sfBoxIxAndUserMap.get(boxUserId)));
						userAndMetaInfoMap.put(sfBoxIxAndUserMap.get(boxUserId),userMemberInfoMeta);	
					}
				}
				recordToUpsert.addAll(userAndMetaInfoMap.values());
				service.updateUserTokensInDB(userTokensObj);
			}else{
	    		//logger.logDebug(BoxConstants.BOX_CURRENT_USER_IS_NOT_CONNECTED);
	    	}
			if(recordToUpsert.size() > 0 ){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().upsertAsUser(recordToUpsert,listOfModifiedFields);
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
	public static Simpplr_Metadata__c addMemberResultParse(Object result,String groupId,Simpplr_Metadata__c userBoxGroupAndMembershipInfo){
	
		if(result instanceof BoxWrapper.BoxErrorWrapper){
			//logger.logDebug(result);
		}else if(result instanceof BoxWrapper.BoxAddMemberWrapper){
			BoxWrapper.BoxAddMemberWrapper resultWrapper = (BoxWrapper.BoxAddMemberWrapper)result;
				Map<String,String> groupAndMemberShipMap = new Map<String,String>();																	
				if(!String.isBlank(userBoxGroupAndMembershipInfo.value__c)){
					groupAndMemberShipMap = (Map<String,String>)JSON.deserialize(userBoxGroupAndMembershipInfo.value__c , Type.forName('Map<String,String>'));
					groupAndMemberShipMap.put(groupId,resultWrapper.id);
					
					
				}else{
					groupAndMemberShipMap.put(groupId,resultWrapper.id);
				}
				userBoxGroupAndMembershipInfo.value__c = JSON.serialize(groupAndMemberShipMap);
		}
		else{
			//logger.logDebug(result);
		}
		return userBoxGroupAndMembershipInfo;
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
	public static void removeMemberFromBoxGroup_ASYNC(String metadataForUserJson,String metadataForGroupJson){
		
			BoxService service = new BoxService();
			List<Simpplr_Metadata__c> metadataForUser = (List<Simpplr_Metadata__c>) JSON.deserialize(metadataForUserJson, Type.forName('List<Simpplr_Metadata__c>'));
			List<Simpplr_Metadata__c> metadataForGroup = (List<Simpplr_Metadata__c>) JSON.deserialize(metadataForGroupJson, Type.forName('List<Simpplr_Metadata__c>'));
			//logger.logDebug(metadataForUser+'~~~~~~~~~~~~~~~~~~~~~~``metadataForUser');
			//logger.logDebug(metadataForGroup+'~~~~~~~~~~~~~~~~~~~~``metadataForGroupJson');
			List<String> groupsList = new List<String>();
			for(Simpplr_Metadata__c groupInfoData : metadataForGroup){
				groupsList.add(groupInfoData.Value__c);
			}
			List<String> memberShipList = new List<String>();
			BoxWrapper.UserTokens userTokensObj = service.getUserTokens(false,boxAdminSfUserId);
			if(!String.isBlank(userTokensObj.accessToken)){
				for(String groupId : groupsList){
					for(Simpplr_Metadata__c userInfoData : metadataForUser){
						Map<String,String> userBoxGroupMemberInfoJson = new Map<String,String>();
						userBoxGroupMemberInfoJson = (Map<String,String>)JSON.deserialize(userInfoData.value__c , Type.forName('Map<String,String>'));
						if(userBoxGroupMemberInfoJson.containsKey(groupId)){
							String memberShipId = userBoxGroupMemberInfoJson.get(groupId);
							Object result = service.removeMemberFromGroup(memberShipId,userTokensObj.accessToken);
							if(result instanceof string){
								if(((String)result).equalsIgnoreCase(BoxConstants.BOX_EMPTY_SUCCESS_RESPONSE)){
									userBoxGroupMemberInfoJson.remove(groupId);
									userInfoData.Value__c = JSON.serialize(userBoxGroupMemberInfoJson);
								}
							}else if(result instanceof BoxWrapper.BoxErrorWrapper){
								BoxWrapper.BoxErrorWrapper errorClass = (BoxWrapper.BoxErrorWrapper )result;
								//logger.logDebug(errorClass.message+'Error in Box remove');
							}
							
						}
					}
				}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Metadata__c>(metadataForUser),new List<Schema.SObjectField>{Simpplr_Metadata__c.Value__c});
				service.updateUserTokensInDB(userTokensObj);
			}else{
	    		//logger.logDebug(BoxConstants.BOX_CURRENT_USER_IS_NOT_CONNECTED);
	    	}
	}
	
	public static void deleteGroupMembership(List<CollaborationGroupMember> listOfCollaborationGroupMembers) {
		if(listOfCollaborationGroupMembers.size() == 1) {
			String groupName = 'Simpplr_' +listOfCollaborationGroupMembers[0].CollaborationGroupId + '_' + listOfCollaborationGroupMembers[0].CollaborationRole;
			List<GroupMember> listOfGroupMemberToDelete = [select id from GroupMember where Group.DeveloperName =:groupName And UserOrGroupId=:listOfCollaborationGroupMembers[0].memberId WITH SECURITY_ENFORCED];
			if(listOfGroupMemberToDelete.size() > 0) {
				if('Public'.equalsIgnoreCase(listOfCollaborationGroupMembers[0].CollaborationRole) == false) {
					transferContentOwnershipForAllContents(listOfCollaborationGroupMembers[0].CollaborationGroupId, listOfCollaborationGroupMembers[0].MemberId);
				}
				deleteGroupMemberRecords(JSON.serialize(listOfGroupMemberToDelete));
			}
		} else {
			Set<String> setOfUserToSync = new Set<String>();
			for(CollaborationGroupMember cgm:listOfCollaborationGroupMembers) {
				setOfUserToSync.add(cgm.MemberId);
			}
			BatchManageContentPermissions job = new BatchManageContentPermissions('GroupMembers', setOfUserToSync);
			Database.executeBatch(job,20); 	
		}
		
	}
	
	public static void siteRolesOperations(List<CollaborationGroupMember> listOfCollaborationGroupMembers, String typeOfOperations){
        if( listOfCollaborationGroupMembers!=null && listOfCollaborationGroupMembers.size()>0 ){
            Set<String> collabGroupId = new Set<String>();
            Map<String, String> collabGroupMemberIdMap = new Map<String, String>();
            for(CollaborationGroupMember cgm:listOfCollaborationGroupMembers) {
                collabGroupId.add(cgm.CollaborationGroupId);
                collabGroupMemberIdMap.put(cgm.id, cgm.MemberID);
            }
            
            List<Site_Role__c> srList = new List<Site_Role__c>();
            if(  typeOfOperations == 'delete' ||  typeOfOperations == 'update' ){
                Map<String, Site_Role__c> srMap = new Map<String, Site_Role__c>();
                for( Site_Role__c sr: [SELECT Id, Name, is_Manager__c, Is_Member__c, Site__c, Site__r.Chatter_Group_Id__c,  Is_Content_Manager__c,
                                        People__r.User__c, People__c, Is_Deleted__c FROM Site_Role__c where 
                                        Site__r.Chatter_Group_Id__c in: collabGroupId and People__r.User__c in: collabGroupMemberIdMap.values() AND Is_Deleted__c = false WITH SECURITY_ENFORCED ] ){
                    srMap.put(sr.Site__r.Chatter_Group_Id__c+'_'+sr.People__r.User__c, sr);
                }
                
                for(CollaborationGroupMember cgm : listOfCollaborationGroupMembers) {
                    if( srMap.containskey(cgm.CollaborationGroupId+'_'+cgm.MemberID) ){
                        Site_Role__c sr = srMap.get(cgm.CollaborationGroupId+'_'+cgm.MemberID);
                        if( typeOfOperations == 'update'){
                            if('admin'.equalsIgnoreCase(cgm.CollaborationRole)){
                                sr.Is_Manager__c = true;
								sr.Is_Member__c = true;
                            }else{
                                sr.Is_Manager__c = false;
								
                            }
                            srList.add(sr);
                        }else if( typeOfOperations == 'delete'){
							sr.Is_Deleted__c = true;
                            srList.add(sr);
                        }
                    }
                }
            }
            
            if( typeOfOperations == 'insert' ){
				List<String> cGMIdsList = new List<String>();
				for(CollaborationGroupMember cGMObj : listOfCollaborationGroupMembers) {
					cGMIdsList.add(cGMObj.Id);
				}
				if (System.IsBatch() == false && System.isFuture() == false ){
					if(Utility.IsSiteCreationFromSimpplrUI  == true) {
						//Do nothing
					} else {
						siteRoleInsert(cGMIdsList, collabGroupId, collabGroupMemberIdMap);
					}
				}
            }
            try{
                if( (typeOfOperations == 'update' || typeOfOperations == 'delete') && (srList.isEmpty() == false) ){

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, Site_Role__c>(srList), new List<Schema.SObjectField>{
							Site_Role__c.Is_Manager__c,
							Site_Role__c.Is_Member__c,
							Site_Role__c.Is_Deleted__c
					});
				}
            }catch( exception ex){
				logger.logError('Exception occurred in deletion or updation of site roles',ex);
            }
        }
	}
	
	@future
	public static void siteRoleInsert(List<String> cGMIdsList, Set<String> collabGroupIdSet, Map<String, String> collabGroupMemberIdMap){
		List<CollaborationGroupMember> listOfCollaborationGroupMembers = [SELECT Id, CollaborationGroupId, CollaborationRole, MemberID FROM CollaborationGroupMember WHERE Id = :cGMIdsList WITH SECURITY_ENFORCED] ;

		List<Site_Role__c> srList = new List<Site_Role__c>();
		Map<String, Simpplr_Site__c> collabGMIDSiteMap = new Map<String, Simpplr_Site__c>();
		for( Simpplr_Site__c ss : [Select id, Site_Type__c, Chatter_Group_Id__c from Simpplr_Site__c where Chatter_Group_Id__c IN :collabGroupIdSet WITH SECURITY_ENFORCED]){
			collabGMIDSiteMap.put(ss.Chatter_Group_Id__c, ss);
		}

		Map<String, String> peopleIDMemberIdMap = new Map<String, String>();
		for( People__c peo : [SELECT Id, User__c from People__c where User__c in: collabGroupMemberIdMap.values() WITH SECURITY_ENFORCED]){
			peopleIDMemberIdMap.put(peo.User__c, peo.id);
		}

		for( CollaborationGroupMember cgm: listOfCollaborationGroupMembers){
			if( collabGMIDSiteMap.containskey(cgm.CollaborationGroupId) && peopleIDMemberIdMap.containskey(cgm.MemberID) ){
				Site_Role__c sr = new Site_Role__c();
				sr.People__c = peopleIDMemberIdMap.get(cgm.MemberID);
				sr.User__c = cgm.MemberId;
				sr.Site__c = collabGMIDSiteMap.get(cgm.CollaborationGroupId).Id;
				sr.is_Manager__c = false;
				sr.Is_Member__c = false;
				if( 'admin'.equalsIgnoreCase(cgm.CollaborationRole)){
					sr.Is_Manager__c = true;
					sr.Is_Member__c = true;
				}
				if(collabGMIDSiteMap.get(cgm.CollaborationGroupId).Site_Type__c != 'Public') {
					sr.Is_Member__c = true;
				}
				srList.add(sr);
			}
		}
		if(srList.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(srList,new List<Schema.SObjectField>{
				Site_Role__c.People__c,
				Site_Role__c.User__c,
				Site_Role__c.Site__c,
				Site_Role__c.Is_Manager__c,
				Site_Role__c.Is_Member__c
			});
		}
	}

	public static void createGroupMembership(List<CollaborationGroupMember> listOfCollaborationGroupMembers) {
		List<GroupMember> listOfGroupMemberToInsert = Utility.getGroupMembershipToCreate(listOfCollaborationGroupMembers);
		if(listOfGroupMemberToInsert.size() > 0) {
			insertGroupMemberRecords(JSON.serialize(listOfGroupMemberToInsert));
		}
	}
	
	public static void transferContentOwnershipForAllContents(String collaborationGroupId, String userId) {
		List<CollaborationGroupMember> listOfCollaborationGroupMembers = [select CollaborationGroup.OwnerId, CollaborationGroup.Owner.isActive, MemberId from CollaborationGroupMember 
											  where CollaborationGroupId=:collaborationGroupId and Member.isActive=true And CollaborationRole='Admin' WITH SECURITY_ENFORCED order by Member.createdDate asc limit 1];
											  
		if(listOfCollaborationGroupMembers.isEmpty() == false) {
			String newOwnerId;
			if(listOfCollaborationGroupMembers[0].CollaborationGroup.Owner.isActive) {
				newOwnerId = listOfCollaborationGroupMembers[0].CollaborationGroup.OwnerId;
			} else {
				newOwnerId = listOfCollaborationGroupMembers[0].MemberId;
			}
			List<Simpplr_Content__c> listOfSimpplrContents = [select Id, OwnerId from Simpplr_Content__c where OwnerId=:userId And Site__r.chatter_group_id__c=:collaborationGroupId and Is_Deleted__c=false WITH SECURITY_ENFORCED];
			for(Simpplr_Content__c contentObj: listOfSimpplrContents) {
				contentObj.OwnerId = newOwnerId;
			}
			if(listOfSimpplrContents.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(listOfSimpplrContents), 
															new List<Schema.SObjectField>{Simpplr_Content__c.OwnerId});
			}
		}
	}
	
	@future 
	public static void insertGroupMemberRecords(String memberShipRecords) {
		List<GroupMember> listOfGroupMemberToInsert = (List<GroupMember>)JSON.deserialize(memberShipRecords, List<GroupMember>.class); 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().insertAsUser(listOfGroupMemberToInsert, new List<Schema.SObjectField>{GroupMember.groupId,GroupMember.UserOrGroupId});
	}
	
	@future 
	public static void deleteGroupMemberRecords(String memberShipRecords) {
		List<GroupMember> listOfGroupMemberToDelete = (List<GroupMember>)JSON.deserialize(memberShipRecords, List<GroupMember>.class); 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().deleteAsUser(listOfGroupMemberToDelete);
	}
	
	@future (callout =true)
	public static void updateEFSGroups(String newMapJson, String oldMapJson){
		Map<Id,CollaborationGroupMember> oldMap = (Map<Id,CollaborationGroupMember>)JSON.deserialize(oldMapJson,Type.forName('Map<Id,CollaborationGroupMember>'));
		Map<Id,CollaborationGroupMember> newMap = (Map<Id,CollaborationGroupMember>)JSON.deserialize(newMapJson,Type.forName('Map<Id,CollaborationGroupMember>'));
		
		String grpId = newMap.values().get(0).CollaborationGroupId;
		List<Simpplr_Site__c> siteList = [select File_Storage_Source__c from Simpplr_Site__c where 
				chatter_group_id__c=:grpId WITH SECURITY_ENFORCED];
		String storageStr = siteList.get(0).File_Storage_Source__c;
		
		String userId = newMap.values().get(0).MemberId;
		CollaborationGroupMember cgm = [select CollaborationGroup.OwnerId from CollaborationGroupMember where MemberId=:userId WITH SECURITY_ENFORCED limit 1];
		
		String ownerId = cgm.CollaborationGroup.OwnerId;
		Map<String, Object> soqlParamMap1 = new Map<String, Object>();
		soqlParamMap1.put('soqlParam1', userId);
		soqlParamMap1.put('soqlParam2', ownerId);
		soqlParamMap1.put('soqlParam3', storageStr);
		String queryStr = 'select Id, User__c, User_Email__c, Group_Id_Set__c from People_Integration__c where (User__c =:soqlParam1 or User__c=:soqlParam2) and name=:soqlParam3 and is_deleted__c=false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap1);
		String ownerEmail = '';
		String memberEmail = '';
		String newOwnerKey = '';
		for(People_Integration__c pplIntegObj : peopleIntegList){
			if(((String)pplIntegObj.User__c).equalsIgnorecase(userId)){
				memberEmail = pplIntegObj.User_Email__c;
			}else{
				ownerEmail = pplIntegObj.User_Email__c;
				newOwnerKey = pplIntegObj.User__c;
			}
		}
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', grpId);
		soqlParamMap.put('soqlParam2', storageStr);
		String folderQuery = 'select External_Folder_Id__c,EFS_Shared_Folder_Id__c from folder__c where site__r.chatter_group_id__c=:soqlParam1  AND Type__c =:soqlParam2 AND is_deleted__c = false AND Is_System_folder__c=true limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		Folder__c rootFolder = ((List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap))[0];
		if(SimpplrContext.connectedStorages.contains(storageStr) && UserContext.connectedStorages.contains(storageStr)){
			if((ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).equalsIgnoreCase(storageStr) && String.isNotBlank(memberEmail)){
		    	EFSSiteService ss = new  EFSSiteService(storageStr);
		    	if('Standard'.equalsIgnoreCase(newMap.values().get(0).CollaborationRole) && 'Admin'.equalsIgnoreCase(oldMap.values().get(0).CollaborationRole)){
			    	// Add member to read Group
			    	ss.addMember(newMap.values().get(0).CollaborationGroupId,peopleIntegList.get(0).User_Email__c,false);
			    	// Remove member from readWrite Grooup 
			    	ss.removeAdmin(newMap.values().get(0).CollaborationGroupId,peopleIntegList.get(0).User_Email__c);
			    	// transfer ownership to site owner
			    	
		    	} else if('Admin'.equalsIgnoreCase(newMap.values().get(0).CollaborationRole) && 'Standard'.equalsIgnoreCase(oldMap.values().get(0).CollaborationRole)){
		    		// Add member to readWrite Group
			    	ss.addAdmin(newMap.values().get(0).CollaborationGroupId,peopleIntegList.get(0).User_Email__c,false);
			    	// Remove member from read Grooup 
			    	ss.removeMember(newMap.values().get(0).CollaborationGroupId,peopleIntegList.get(0).User_Email__c);
		    	}
		    	ss.close();
	    	}	
		}
	}
}