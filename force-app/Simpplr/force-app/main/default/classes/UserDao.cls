/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class UserDao {	

    
	public People__c getUserInfo (String userId) {
		People__c selectedUserInfo;
		List<People__c> UpdatedlistOfPeople = new List<People__c>();
		
		if (String.isNotBlank(userId) && UserContext.id.equalsIgnoreCase(userId)) {
			selectedUserInfo = UserContext.getCurrentUserInfo;
			
		} else if (String.isNotBlank(userId) && userId.startsWith('005')) {
			List<People__c> listOfPeople = [SELECT id, User__c, Phone__c, Email__c, Title__c, 
					About__c, People_Category__c, Mobile_Phone__c, Extension__c, People_Category__r.Name__c, 
					User__r.SmallPhotoUrl, User__r.FullPhotoUrl, Full_Name__c, First_Name__c,Last_Name__c, 
					Department__c, Manager__c, City__c, Company_Name__c, Division__c,  
					Street__c, Country__c, State__c, Birth_Date__c, Joining_Date__c, User__r.IsActive, User__r.TimezoneSIDKey,
					 (select id from Bookmark_Receiver_People__r where People__c=:UserContext.peopleId AND Type__c='People' And Is_Deleted__c=false) 
					FROM People__c 
					WHERE User__c =: userId WITH SECURITY_ENFORCED order by CreatedDate asc limit 1];
			UpdatedlistOfPeople = updatePeopleListAccToProfileFields(listOfPeople);
			
			if (UpdatedlistOfPeople.isEmpty()) {
				throw new SimpplrException(ExceptionCode.INVALID_USER_ID.name());
				
			} else {
				selectedUserInfo = UpdatedlistOfPeople[0];
			}
			
		} else if (String.isNotBlank(userId) && userId.startsWith(Utility.getPeoplePrefix())) {
			List<People__c> listOfPeople = [SELECT id, User__c, Phone__c, Email__c, Title__c, About__c,
					People_Category__c, Mobile_Phone__c, Extension__c, People_Category__r.Name__c, 
					User__r.SmallPhotoUrl, User__r.FullPhotoUrl, Full_Name__c, First_Name__c, Last_Name__c, 
					Department__c, Manager__c, City__c, Street__c, Company_Name__c, Division__c,
					Country__c, State__c, Birth_Date__c, Joining_Date__c, User__r.IsActive, User__r.TimezoneSIDKey,
					(SELECT People__c, Bookmark_Receiver__c 
					FROM Bookmark_Receiver_People__r 
					WHERE People__c=:UserContext.peopleId AND Bookmark_Receiver__c =:userId 
					AND Type__c='People' And Is_Deleted__c=false )
					FROM People__c 
					WHERE id =:userId WITH SECURITY_ENFORCED order by CreatedDate asc limit 1];
			UpdatedlistOfPeople = updatePeopleListAccToProfileFields(listOfPeople);
			
			if (UpdatedlistOfPeople.isEmpty()) {
				throw new SimpplrException(ExceptionCode.INVALID_USER_ID.name());
				
			} else {
				selectedUserInfo = UpdatedlistOfPeople[0];
			}
			
		} else {
			throw new SimpplrException(ExceptionCode.INVALID_USER_ID.name());
		}
		
		return selectedUserInfo;
    }
    
    private list<People__c> updatePeopleListAccToProfileFields (List<People__c> pplList) {
			List<People__c> listOfPeopleToUpdate = new List<People__c>();
			
			for (People__c peopleObj : pplList) {
				
				if (SimpplrContext.isPPTitleDisplay == false) {
					peopleObj.Title__c = null;
				}
				
				if (SimpplrContext.isPPDepartmentDisplay == false) {
					peopleObj.Department__c = null;
				}
				
				if (SimpplrContext.isPPCityDisplay == false) {
					peopleObj.City__c = null;
				}
				
				if (SimpplrContext.isPPStateDisplay == false) {
					peopleObj.State__c = null;
				}
				
				if (SimpplrContext.isPPCountryDisplay == false) {
					peopleObj.Country__c = null;
				}
				
				if (SimpplrContext.isPPFirstNameDisplay == false) {
					peopleObj.First_Name__c = null;
				}
				
				if (SimpplrContext.isPPLastNameDisplay == false) {
					peopleObj.Last_Name__c = null;
				}
				
				if (SimpplrContext.isPPPhoneDisplay == false) {
					peopleObj.Phone__c = null;
				}
				
				if (SimpplrContext.isPPExtensionDisplay == false) {
					peopleObj.extension__c = null;
				}
				
				if (SimpplrContext.isPPBirthDateDisplay == false) {
					peopleObj.Birth_Date__c = null;
				}
				
				if (SimpplrContext.isPPJoiningDateDisplay == false) {
					peopleObj.Joining_Date__c = null;
				}
				
				if (SimpplrContext.isPPCompanyNameDisplay == false) {
					peopleObj.Company_Name__c = null;
				}
				
				if (SimpplrContext.isPPDivisionDisplay == false) {
					peopleObj.Division__c = null;
				}
				
				listOfPeopleToUpdate.add(peopleObj);
			}
			
		return listOfPeopleToUpdate;
	}
	
	public List<PeopleWrapper.EndorsementsWrapper> getEndorsementsForUser (String profileId) {
		profileId= profileId.replace('"','');

		List<People_Expertise_Detail__c> pEDList = [SELECT  Id, People_Expertise__c, People_Expertise__r.Expertise__c, 
															People_Expertise__r.Expertise__r.Display_Name__c, People_Expertise__r.Expertise__r.Name__c,  
															Endorser__c, CreatedDate 
														FROM People_Expertise_Detail__c 
														WHERE People_Expertise__r.People__r.User__c = :profileId 
															AND People_Expertise__r.Is_Self_Hidden__c = false WITH SECURITY_ENFORCED];

		Map<String,PeopleWrapper.EndorsementsWrapper> mapOfUserEndorsement = getMapOfUserEndorsement(pEDList);

		return mapOfUserEndorsement.values();
	}

	private Map<String,PeopleWrapper.EndorsementsWrapper> getMapOfUserEndorsement(List<People_Expertise_Detail__c> pEDList) {
		Map<String,PeopleWrapper.EndorsementsWrapper> mapOfUserEndorsement = new Map<String,PeopleWrapper.EndorsementsWrapper>(); 

		PeopleWrapper.EndorsementsWrapper endoWrapper;

		for(People_Expertise_Detail__c pEDObj : pEDList) {
			
			String expertiseId = pEDObj.People_Expertise__r.Expertise__c;
			if(mapOfUserEndorsement.containsKey(expertiseId)) {
				endoWrapper = mapOfUserEndorsement.get(expertiseId);
				if(endoWrapper.isEndorsed == false && UserContext.peopleId.equalsIgnoreCase(pEDObj.Endorser__c)) {
					endoWrapper.isEndorsed = true;
				}
				endoWrapper.count++;

			} else {
				endoWrapper = new PeopleWrapper.EndorsementsWrapper();
				if(UserContext.peopleId.equalsIgnoreCase(pEDObj.Endorser__c)) {
					endoWrapper.isEndorsed = true;
				}
				endoWrapper.count = 1;
				endoWrapper.expertise.id = expertiseId;
				endoWrapper.expertise.url = PageContext.getPageURL(Pages.PeopleExpertise) + '?expertiseId=' + expertiseId;
				endoWrapper.expertise.name = pEDObj.People_Expertise__r.Expertise__r.Display_Name__c;
				endoWrapper.expertise.alphanumericName = pEDObj.People_Expertise__r.Expertise__r.Name__c;
			}

			mapOfUserEndorsement.put(expertiseId, endoWrapper);
		}

		return mapOfUserEndorsement;
	}
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    private Map<Id,People__c> getUsersMapBySearchTermWithExclusion (String query, Set<Id> invitedUsers) {
    	query = '%' + query + '%';
		String queryStr = 'SELECT Id, User__c, Phone__c, Email__c, Title__c, About__c,Zoom_Id__c,Skype_Id__c, ' +
				'User__r.SmallPhotoUrl, User__r.FullPhotoUrl, Full_Name__c, Department__c,Birth_Date__c,Joining_Date__c, ' +
				'City__c, Street__c, Country__c, State__c, User__r.IsActive,Mobile_Phone__c,Last_Name__c,Extension__c, ' +
				'Manager__r.User__c,  Manager__r.Full_Name__c, Manager__r.User__r.IsActive, Community_Nickname__c, First_Name__c, ' +
				'Segment__r.Name__c, Division__c, Company_Name__c,Is_Protected_Author__c, User__r.languagelocalekey, User__r.TimeZoneSidKey, ' +
				'Microsoft_Teams_User_Id__c, Microsoft_Teams_User_Name__c, Microsoft_Tenant_Id__c, Slack_User_Id__c, Slack_User_Name__c, Slack_Tenant_Id__c, ' +
				'(select connected__c,name from People_Integrations__r) ' +
			'FROM People__c ' +
			'WHERE Full_Name__c Like: query AND Id NOT IN :invitedUsers AND User__r.isActive = true ';
		return New Map<Id,People__c>((List<People__c>)Database.query(queryStr));
	}

	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public List<People__c> getUsersBySearchTermWithExclusion (String query, Set<Id> invitedUsers) {
    	List<People__c> result = new List<People__c>();
    	Map<Id,People__c> peopleMap = getUsersMapBySearchTermWithExclusion(query,invitedUsers);
    	
    	if (peopleMap.size() > 0) {
    		result = peopleMap.values();
    	}
    	
    	return result;
	}
	
	public User getCustomFieldsForUser(Set<String> fieldsSet, String profileOrUserId) {
		User userObj = null;
		
		if(fieldsSet==null || fieldsSet.size()==0){ // adding null guard. 
			return userObj;
		}
		String userId = '';
		
		if (String.isNotBlank(profileOrUserId) && profileOrUserId.startsWith('005')) {
			userId = profileOrUserId;
			
		} else {
			List<People__c> peopleList = [SELECT User__c FROM People__c WHERE Id = :profileOrUserId WITH SECURITY_ENFORCED];
			userId = peopleList.size()>0 ? peopleList[0].User__c : profileOrUserId; // not expecting else part ever.
		}
		 
		String query = 'select ' + Utility.convertToCommaSeparatedString(new List<String>(fieldsSet)) + ' from User where Id =:userId ';
		
		List<User> userList = Database.query(query);
		
		if (userList.isEmpty()) { // throw exception if record not found in query
			throw new SimpplrException(ExceptionCode.INVALID_USER_ID.name());
		}
		
		userObj = userList[0];	
		return userObj;
	}
		
	
	private class TopicWrapper implements Comparable {
		public String topicId{set;get;}
		public String topicDisplayName{set;get;}
	    public String topicName{set;get;}
	    public Integer topicCount{set;get;}
	    public Boolean isEndorsedByCurrentUser{set;get;}
	    public Boolean isSelfEndorsed{set;get;}
	    
	    
	    /**
	     * 
	     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	     * Parameters:
	     * parameter_name -- [Explanation of the purpose of this parameter to the method.
	     *      
	     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	    */
	    public TopicWrapper (String id, String name, Integer topicCount) {
	    	this.topicId=id;
	    	this.topicName=name;
	    	this.topicCount=topicCount;
	    	this.topicDisplayName = Utility.chompString(name, 40);
	    }
	    
	    /**
	     * 
	     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	     * Parameters:
	     * parameter_name -- [Explanation of the purpose of this parameter to the method.
	     *      
	     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	    */
	    public Integer compareTo (Object compareTo) {
	        TopicWrapper compareToTopicWrapper = (TopicWrapper)compareTo;
	        Integer compareToTopicCount = compareToTopicWrapper.topicCount;
	        
	        if (topicCount == null || compareToTopicCount == null){
	        	return 0;
	        }
	        
	        if (compareToTopicCount > topicCount) {
	            return 1;
	            
	        } else if (compareToTopicCount < topicCount) {
	            return -1;
	            
	        } else {
	        	Integer comparisionResult = topicName.compareTo(compareToTopicWrapper.topicName);
	        	
	        	if (comparisionResult > 0) {
	        		return 1;
	        		
	        	} else if (comparisionResult == 0) {
	        		return 0;
	        		
	        	} else {
	        		return -1;
	        	}
	        	
	     	}    
	    } 
	}
	
	@future
    public static void setChatterEmailSettingsForUsers (String chatterEmailsSettings, 
    		List<String> listOfProfiles) {
    	Boolean disableChatterEmails = true;
    	String packageName = SimpplrContext.packageName;
    	String query = 'Select id from user where isactive = true And usertype = \'Standard\' ';
    	
    	if ('Off For All'.equalsIgnoreCase(chatterEmailsSettings)) {
    		disableChatterEmails = true;
    		query += 'And UserPreferencesDisableAllFeedsEmail = false ';
    		
    	} else if ('On For All'.equalsIgnoreCase(chatterEmailsSettings)) {
    		disableChatterEmails = false;
    		query += 'And UserPreferencesDisableAllFeedsEmail = true ';
    		
    	} else if ('Off For Selected Profiles'.equalsIgnoreCase(chatterEmailsSettings)) {
    		disableChatterEmails = true;
    		query += 'And UserPreferencesDisableAllFeedsEmail = false And profileId=:listOfProfiles ';
    		
    	}
    	
    	List<User> listOfUsers = Database.query(query);
    	
    	for (User userObj:listOfUsers) {
    		userObj.UserPreferencesDisableAllFeedsEmail = disableChatterEmails;
    	}
    	
    	if (!listOfUsers.isEmpty()) {
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, User>(listOfUsers), new List<Schema.SObjectField>{User.UserPreferencesDisableAllFeedsEmail});
    	}
    	
    }
    
    public void syncUnlistedSiteManagersGroupMembership(){
    	List<Group> userGroup = [SELECT id FROM Group WHERE DeveloperName = 'Simpplr_Unlisted_Site_Managers' WITH SECURITY_ENFORCED];
    	String unlistedSiteManagerGroupId;
    	
    	if (userGroup.isEmpty()) {
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
			Group groupObj = new Group();
    		
			groupObj.DeveloperName = 'Simpplr_Unlisted_Site_Managers';
    		groupObj.DoesSendEmailToMembers = false;
    		groupObj.Type = 'Regular';
    		groupObj.Name = groupObj.DeveloperName; 
			
			fieldList.add(Group.DeveloperName);
			fieldList.add(Group.DoesSendEmailToMembers);
			fieldList.add(Group.Type);
			fieldList.add(Group.Name);
				
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(new List<Group>{groupObj}, fieldList);
    		
			groupObj = (Group)(result.getInsertedObjects()[0]);
    		unlistedSiteManagerGroupId = groupObj.id;
    		
    	} else {
    		unlistedSiteManagerGroupId = userGroup[0].id;
    	}
    	
    	Set<Id> userIdSet = new Set<Id>();
    	List<People__c> peopleList = [SELECT Id, User__c FROM People__c WHERE Unlisted_Site_Moderation_Permission__c = 'Yes' WITH SECURITY_ENFORCED];
		for (People__c peopleObj : peopleList){
			userIdSet.add(peopleObj.User__c);
		}
						
		List<GroupMember> listOfOldGroupMember = [SELECT UserOrGroupId FROM GroupMember 
				WHERE groupId = :unlistedSiteManagerGroupId And UserOrGroupId =:userIdSet WITH SECURITY_ENFORCED];
		Set<String> setOfOldMembers = new Set<String>();
		
		for (GroupMember groupMemberObj : listOfOldGroupMember) {
			setOfOldMembers.add(groupMemberObj.UserOrGroupId);
		}
		
		Set<String> setOfNewMembers = new Set<String>();
		for (String userId : userIdSet) {
			if (setOfOldMembers.contains(userId)) {
				setOfOldMembers.remove(userId);
			} else {
				setOfNewMembers.add(userId);
			}
		}
		
		if (setOfOldMembers.size() > 0) {
			List<GroupMember> listOfGroupMemberToDelete = [SELECT Id, groupId, UserOrGroupId 
					FROM GroupMember WHERE groupId = :unlistedSiteManagerGroupId AND UserOrGroupId =:setOfOldMembers WITH SECURITY_ENFORCED];
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfGroupMemberToDelete);
		}
		
		if (setOfNewMembers.size() > 0) {
			List<GroupMember> listOfGroupMemberToInsert = new List<GroupMember>();
			
			for (String userId:setOfNewMembers) {
    			listOfGroupMemberToInsert.add(new GroupMember(groupId = unlistedSiteManagerGroupId, UserOrGroupId = userId));
    		}
    		
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().insertAsUser(listOfGroupMemberToInsert, 
    				new List<Schema.SObjectField>{GroupMember.groupId, GroupMember.UserOrGroupId});
		}
    }
    
    public void syncAppManagersGroupMembership() {
    	List<Group> userGroup = [SELECT id FROM Group WHERE DeveloperName='Simpplr_App_Managers' WITH SECURITY_ENFORCED];
    	String appManagerGroupId;
    	
    	if (userGroup.isEmpty()) {
			Group groupObj = new Group();
    		groupObj.DeveloperName = 'Simpplr_App_Managers';
    		groupObj.DoesSendEmailToMembers = false;
    		groupObj.type='Regular';
    		groupObj.Name = groupObj.DeveloperName; 
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SObject resultObj = SIMPESAPI.accessController().insertAsUser(groupObj, new List<Schema.SObjectField>{
					Group.DeveloperName,
					Group.DoesSendEmailToMembers,
					Group.type,
					Group.Name
					});
    		groupObj = (Group)resultObj;
			appManagerGroupId = groupObj.id;
    		
    	} else {
    		appManagerGroupId = userGroup[0].id;
    	}
    	
    	Set<Id> userIdSet = new Set<Id>();
    	List<People__c> peopleList = [SELECT Id, User__c FROM People__c WHERE App_Moderation_Permission__c = 'Yes' WITH SECURITY_ENFORCED];
		for (People__c peopleObj : peopleList){
			userIdSet.add(peopleObj.User__c);
		}			
						
		List<GroupMember> listOfOldGroupMember = [SELECT UserOrGroupId FROM GroupMember 
				WHERE groupId=:appManagerGroupId And UserOrGroupId =:userIdSet WITH SECURITY_ENFORCED];
		Set<String> setOfOldMembers = new Set<String>();
		
		for (GroupMember groupMemberObj:listOfOldGroupMember) {
			setOfOldMembers.add(groupMemberObj.UserOrGroupId);
		}
		
		Set<String> setOfNewMembers = new Set<String>();
		for (String userId : userIdSet) {
			if (setOfOldMembers.contains(userId)) {
				setOfOldMembers.remove(userId);
			} else {
				setOfNewMembers.add(userId);
			}
		}
		
		if (setOfOldMembers.size() > 0) {
			List<GroupMember> listOfGroupMemberToDelete = [SELECT Id, groupId, UserOrGroupId 
					FROM GroupMember WHERE groupId=:appManagerGroupId AND UserOrGroupId =:setOfOldMembers WITH SECURITY_ENFORCED];
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfGroupMemberToDelete);
		}
		
		if (setOfNewMembers.size() > 0) {
			List<GroupMember> listOfGroupMemberToInsert = new List<GroupMember>();
			
			for (String userId:setOfNewMembers) {
    			listOfGroupMemberToInsert.add(new GroupMember(groupId=appManagerGroupId, UserOrGroupId=userId));
    		}
    		
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().insertAsUser(listOfGroupMemberToInsert, 
    				new List<Schema.SObjectField>{GroupMember.groupId, GroupMember.UserOrGroupId});
		}
		
    }
    
    public void syncGroupMembershipForUser(String userId) {
    	logger.logDebug('UserDao.syncGroupMembershipForUser() ---userId---' + userId);
    	Set<String> setOfOldMembership = new Set<String>(); 
    	List<GroupMember> listOfOldGroupMember = [SELECT Group.DeveloperName 
    			FROM GroupMember WHERE Group.DeveloperName like 'Simpplr_%' AND UserOrGroupId =:userId WITH SECURITY_ENFORCED];
    			
    	for (GroupMember cm:listOfOldGroupMember) {
    		setOfOldMembership.add(cm.Group.DeveloperName);
    	}
    	
    	Set<String> setOfNewMembership = new Set<String>(); 
    	List<CollaborationGroupMember> listOfCollaborationGroupMembership = [SELECT CollaborationGroupId, 
    			CollaborationRole FROM CollaborationGroupMember 
    			WHERE Member.UserType = 'Standard' AND MemberId=:userId WITH SECURITY_ENFORCED]; 
    			
    	for (CollaborationGroupMember cgm:listOfCollaborationGroupMembership) {
    		String devloperName = 'Simpplr_' + cgm.CollaborationGroupId + '_' + cgm.CollaborationRole;
    		
    		if (setOfOldMembership.contains(devloperName)) {
    			setOfOldMembership.remove(devloperName);
    			
    		} else {
    			setOfNewMembership.add(devloperName);
    		}
    		
    	}
    	
    	if (setOfOldMembership.size() > 0) {
    		List<GroupMember> listOfGroupMemberToDelete = [SELECT Id FROM GroupMember 
    				WHERE Group.DeveloperName=:setOfOldMembership AND UserOrGroupId =:userId WITH SECURITY_ENFORCED];
    				
    		if (listOfGroupMemberToDelete.size() > 0) {
	    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(listOfGroupMemberToDelete);
    		}
    		
    	}
    	
    	if (setOfNewMembership.size() > 0) {
    		List<GroupMember> listOfGroupMemberToInsert = new List<GroupMember>();
    		List<Group> listOfGroups = [SELECT id, DeveloperName FROM Group 
    				WHERE Group.DeveloperName=:setOfNewMembership WITH SECURITY_ENFORCED];
    		
    		for (Group groupObj:listOfGroups) {
    			listOfGroupMemberToInsert.add(new GroupMember(groupId = groupObj.id, UserOrGroupId = userId));
    		}
    		
    		if (listOfGroupMemberToInsert.size() > 0) {
	    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    		SIMPESAPI.accessController().insertAsUser(listOfGroupMemberToInsert, 
	    				new List<Schema.SObjectField>{GroupMember.groupId, GroupMember.UserOrGroupId});
    		}
    		
    	}
    		 
    }
    
    // Function to set/unset the EFS_Batch_Flag__c in People_Preference__c object.
    public static void setMountBatchFlag(Boolean flag, Id usrId) {
   		try {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', usrId);
			soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
   			String queryStr = 'Select Id, My_Drive_Id__c, Batch_Flag__c, Connected__c from People_Integration__c WHERE User__c = :soqlParam1 and name=:soqlParam2 and is_deleted__c=false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			People_Integration__c ppl = ((List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap))[0];
   			if(ppl == null || !ppl.Connected__c || ppl.Batch_Flag__c == flag) {
   				return;
   			}
   			
   			ppl.Batch_Flag__c = flag;

			if(flag == false) {
				String appConfigQuery = 'Select Id, App_Name__c from App_Config__c limit 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				App_Config__c app = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
				
				
				// Check the Application Root Folder
				String appName = app.App_Name__c;
				String ppAppName = ppl.My_Drive_Id__c+'';
				
				if(String.isNotBlank(ppAppName) && !appName.equalsIgnoreCase(ppAppName)) {
					// Move the Folder
					EFSFileService fs = new EFSFileService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
					fs.updateFileName('/' + ppAppName, '/' + appName);
					ppl.My_Drive_Id__c = appName;
					fs.close();	
				}
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(ppl, new List<Schema.SObjectField>{People_Integration__c.Batch_Flag__c,
																							People_Integration__c.My_Drive_Id__c});   			
   		} catch(Exception e) {
			return;   			
   		}
    }
}