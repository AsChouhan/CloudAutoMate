public without sharing class BatchManageContentPermissions implements Database.Batchable<SObject>, Database.Stateful {
	private String recordType;
	private Boolean makePrivateBool;
    private Boolean runNextBatchInSequence;
    private Set<String> setOfUserToSync;
    private List<String> listOfChatterGroupIds;
    private Exception exceptionDetailsObj;
     
    public BatchManageContentPermissions(String recordType, Boolean runNextBatchInSequence){
    	this.recordType = recordType;
    	this.runNextBatchInSequence = runNextBatchInSequence;
    }
    
    public BatchManageContentPermissions(String recordType, Set<String> setOfUserToSync) {
    	this.recordType = recordType;
    	this.runNextBatchInSequence = false;
    	this.setOfUserToSync = setOfUserToSync;
    }
    
    public BatchManageContentPermissions(String recordType, List<String> listOfChatterGroupIds, Boolean makePrivateBool){
    	this.recordType = recordType;
    	this.listOfChatterGroupIds = listOfChatterGroupIds;
    	this.makePrivateBool = makePrivateBool;
    	this.runNextBatchInSequence = false;
    }
    
    public database.querylocator start(Database.BatchableContext bc){
    	String query='';
		List<String> listOfIds = new List<String>();
		
    	if('UserGroups'.equalsIgnoreCase(recordType)) {
    		query = 'select id from CollaborationGroup ';
    		if(SimpplrContext.isCommunitiesEnabled){
    			query += ' Where NetworkId = null';
    		}
    	
    	} else if('GroupMembers'.equalsIgnoreCase(recordType)) {
    		if(setOfUserToSync != null) {
    			query = 'Select id from User where id in :setOfUserToSync ';

    		} else if(SimpplrContext.isCommunitiesEnabled){
				query = 'Select id from User where id in (select MemberId from CollaborationGroupMember where CollaborationGroup.NetworkId = null) ';

			} else {
				query = 'Select id from User where id in (select MemberId from CollaborationGroupMember) ';
    		}
		} else if('SiteRoles'.equalsIgnoreCase(recordType)) {
			query = 'select MemberId, collaborationgroupId, collaborationRole from CollaborationGroupMember ';
			if(listOfChatterGroupIds != null) {
				query += ' where collaborationgroupId =: listOfChatterGroupIds ';
			} else if(SimpplrContext.isCommunitiesEnabled){
				query += ' where CollaborationGroup.NetworkId = null ';
			} 

		} else if('RemoveUnsyncedSiteRoles'.equalsIgnoreCase(recordType)) {
			query = 'select Id, People__r.User__c, Site__r.Chatter_Group_Id__c from Site_Role__c where Is_Deleted__c = false';
			if(listOfChatterGroupIds != null) {
				query += ' and Site__r.Chatter_Group_Id__c IN :listOfChatterGroupIds ';
			}

    	} else if('ContentShare'.equalsIgnoreCase(recordType)) {
    		query = 'select id, OwnerId, Type__c, Site__c, site__r.chatter_group_id__c, site__r.Site_type__c from Simpplr_Content__c where Is_Deleted__c = false and owner.type=\'User\' ';
    	
    	} else if('OrphanCoverImagesCleanup'.equalsIgnoreCase(recordType)) {
            query = 'SELECT Id, Content_Document__c FROM File__c ' + 
                    ' WHERE Simpplr_Content__r.Is_Deleted__c = true ' + 
    				' AND Simpplr_Content__r.Type__c != \'Album\' ' + 
    				' AND Title_Image_Type__c IN (\'Thumbnail\', \'WIdescreen\')';
    		
    	} else if('ToggleContentPermissions'.equalsIgnoreCase(recordType)) {
    		query = 'select id, Site__r.chatter_Group_Id__c from Simpplr_Content__c where Is_Deleted__c=false And Site__r.chatter_Group_Id__c=:listOfChatterGroupIds';
    	}
    	
    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	
    	try{
	    	if('UserGroups'.equalsIgnoreCase(recordType)) {
	    		List<CollaborationGroup> listOfCollaborationGroups = (List<CollaborationGroup>)listOfsObject;
				createUserGroup(listOfCollaborationGroups);
				
	    	} else if('GroupMembers'.equalsIgnoreCase(recordType)) {
	    		List<User> listOfUsers = (List<User>)listOfsObject;
	    		UserDao daoObj = new UserDao();
	    		for(User userObj:listOfUsers) { 
	    			daoObj.syncGroupMembershipForUser(userObj.id);
	    		}
			
			} else if('SiteRoles'.equalsIgnoreCase(recordType)) {
				List<CollaborationGroupMember> collaborationGroupMemberlist = (List<CollaborationGroupMember>)listOfsObject;
				updateSiteRoles(collaborationGroupMemberlist);

			} else if('RemoveUnsyncedSiteRoles'.equalsIgnoreCase(recordType)) {
				List<Site_Role__c> siteRoleList = (List<Site_Role__c>)listOfsObject;
				removeUnsyncedSiteRoles(siteRoleList);

	    	} else if('ContentShare'.equalsIgnoreCase(recordType)) {
	    		List<Simpplr_Content__c> listOfContents = (List<Simpplr_Content__c>)listOfsObject;
	    		transferContentOwnership(listOfContents);
	    		Utility.createSimpplrContentShareRecords(listOfContents);
	    	
			} else if('OrphanCoverImagesCleanup'.equalsIgnoreCase(recordType)) {
	    		List<File__c> listOfFiles = (List<File__c>)listOfsObject;
	    		deleteFiles(listOfFiles); 
	    	
			} else if('ToggleContentPermissions'.equalsIgnoreCase(recordType)) {
				List<Simpplr_Content__c> listOfSimpplrContents = (List<Simpplr_Content__c>)listOfsObject;
				utility.toggleContentPermissions(listOfSimpplrContents, makePrivateBool);
			}
	    	}catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
	}
	
	private void updateSiteRoles(List<CollaborationGroupMember> collaborationGroupMemberlist) {
		Set<String> managerKeySet = new Set<String>();
		Set<String> memberKeySet = new Set<String>();
		for(CollaborationGroupMember cgm : collaborationGroupMemberlist) {
			String key = String.valueOf(cgm.MemberId) + String.valueOf(cgm.CollaborationgroupId);
			if('Admin'.equalsIgnoreCase(cgm.collaborationRole)) {
				managerKeySet.add(key);
			} else {
				memberKeySet.add(key);
			}
		}
		List<Site_Role__c> siteRoleList = [select Unique_Id__c, Site__r.Chatter_Group_Id__c, People__r.User__c, Is_Manager__c
											from Site_Role__c
											where (Unique_Id__c=:managerKeySet or Unique_Id__c=:memberKeySet)
											and is_Deleted__c=false];		
		List<Site_Role__c> updatedSiteRoleList = new List<Site_Role__c>();
		for(Site_Role__c siteRole:siteRoleList) {
			if(siteRole.Is_Manager__c && memberKeySet.contains(siteRole.Unique_Id__c)) {
				siteRole.Is_Manager__c = false;
				siteRole.Sync_status__c = null;
				updatedSiteRoleList.add(siteRole);
			
			} else if(siteRole.Is_Manager__c == false && managerKeySet.contains(siteRole.Unique_Id__c)) {
				siteRole.Is_Manager__c = true;
				siteRole.Is_Member__c = true;
				siteRole.Sync_status__c = null;
				updatedSiteRoleList.add(siteRole);
			}
			managerKeySet.remove(siteRole.Unique_Id__c);
			memberKeySet.remove(siteRole.Unique_Id__c);		
		}
		if(!updatedSiteRoleList.isEmpty()) {

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, Site_Role__c>(updatedSiteRoleList), new List<Schema.SObjectField>{
                                                                    Site_Role__c.Is_Member__c,
                                                                    Site_Role__c.Sync_Status__c,
																	Site_Role__c.Is_Manager__c
                                                                });

		}
		Set<String> userIdSet = new Set<String>();
		Set<String> chatterGroupIdSet = new Set<String>();
		for(String key : managerKeySet) {
			userIdSet.add(key.left(18));
			chatterGroupIdSet.add(key.right(18));
		}
		for(String key : memberKeySet) {
			userIdSet.add(key.left(18));
			chatterGroupIdSet.add(key.right(18));
		}
		if(!userIdSet.isEmpty()) {			
			Map<String, Simpplr_site__c> chatterGroupIdToSiteMap = new Map<String, Simpplr_site__c>();
			for(Simpplr_site__c siteObj : [select id, chatter_group_id__c, site_type__c from Simpplr_site__c where chatter_group_id__c=:chatterGroupIdSet]) {
				chatterGroupIdToSiteMap.put(siteObj.chatter_group_id__c, siteObj);
			}

			Map<String, String> userIdPeopleIdMap = new Map<String, String>();
			List<People__c> peopleList = [select id, User__c from People__c where User__c=:userIdSet];
			for(People__c peopleObj:peopleList) {
				userIdPeopleIdMap.put(peopleObj.User__c, peopleObj.id);
			}

			List<Site_Role__c> siteRoleInsertList = new List<Site_Role__c>();
			for(String key : managerKeySet) {
				if(userIdPeopleIdMap.containsKey(key.left(18)) && chatterGroupIdToSiteMap.get(key.right(18))?.id != null) {
					Site_Role__c siteRole = new Site_Role__c();
					siteRole.people__c = userIdPeopleIdMap.get(key.left(18));
					siteRole.User__c = key.left(18);
					siteRole.Site__c = chatterGroupIdToSiteMap.get(key.right(18)).id;
					siteRole.Is_Manager__c = true;
					siteRole.Is_Member__c = true;
					siteRoleInsertList.add(siteRole);
				}
			}
			for(String key : memberKeySet) {
				if(userIdPeopleIdMap.containsKey(key.left(18)) && chatterGroupIdToSiteMap.get(key.right(18))?.id != null) {
					Site_Role__c siteRole = new Site_Role__c();
					siteRole.people__c = userIdPeopleIdMap.get(key.left(18));
					siteRole.User__c = key.left(18);
					siteRole.Site__c = chatterGroupIdToSiteMap.get(key.right(18)).id;
					siteRole.Is_Manager__c = false;
					siteRole.Is_Member__c = 'public'.equalsIgnoreCase(chatterGroupIdToSiteMap.get(key.right(18)).site_type__c) ? false : true;
					siteRoleInsertList.add(siteRole);
				}
			}
			if(!siteRoleInsertList.isEmpty()) {
				SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(siteRoleInsertList,
					new List<Schema.SObjectField>{
						Site_Role__c.People__c,
						Site_Role__c.User__c,
						Site_Role__c.Site__c,
						Site_Role__c.Is_Manager__c,
						Site_Role__c.Is_Member__c
					});
			}
		}

	}

	private void removeUnsyncedSiteRoles(List<Site_Role__c> siteRoleList) {
		Set<String> userIdSet = new Set<String>();
		Set<String> chatterGroupIdSet = new Set<String>();
		for(Site_Role__c siteRole : siteRoleList) {
			userIdSet.add(siteRole.People__r.User__c);
			chatterGroupIdSet.add(siteRole.Site__r.Chatter_Group_Id__c);
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', chatterGroupIdSet);
		soqlParamMap.put('soqlParam2', userIdSet);
		String query = 'SELECT CollaborationGroupId, MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId IN :soqlParam1 AND MemberId IN :soqlParam2 ORDER BY CollaborationGroupId, MemberId';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<CollaborationGroupMember> cgmList  = (List<CollaborationGroupMember>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

		Set<String> chatterGroupIdUserIdSet = new Set<String>();
		for(CollaborationGroupMember cgm: cgmList) {
			chatterGroupIdUserIdSet.add(cgm.CollaborationGroupId +'_'+ cgm.MemberId);
		}

		List<Site_Role__c> siteRoleListToDelete = new List<Site_Role__c>();
		for(Site_Role__c siteRole : siteRoleList) {
			if(String.isNotBlank(siteRole.Site__r.Chatter_Group_Id__c)){
				String key = ((Id)siteRole.Site__r.Chatter_Group_Id__c) +'_'+ siteRole.People__r.User__c;
				if(!chatterGroupIdUserIdSet.contains(key)) {
					siteRole.Is_Deleted__c = true;
					siteRoleListToDelete.add(siteRole);
				}
			}
		}
		if(siteRoleListToDelete.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Site_Role__c>(siteRoleListToDelete),new List<Schema.SObjectField>{Site_Role__c.Is_Deleted__c});
		}
	}
    
    public void finish(Database.BatchableContext bc){
    	
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
	Boolean canStartNextBatch = false;
	if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
		canStartNextBatch = true;
	} else {
		Utility.sendExceptionEmail('BatchManageContentPermissions', exceptionDetailsObj);
	}
	
    	if('GroupMembers'.equalsIgnoreCase(recordType)) {
    		UserDao daoObj = new UserDao();
    		daoObj.syncAppManagersGroupMembership();
    		daoObj.syncUnlistedSiteManagersGroupMembership();
    	}
    	
    	if(runNextBatchInSequence) {
    		if('UserGroups'.equalsIgnoreCase(recordType)) {
    			BatchManageContentPermissions job = new BatchManageContentPermissions('GroupMembers', runNextBatchInSequence);
				Database.executeBatch(job,20);
				
    		} else if('GroupMembers'.equalsIgnoreCase(recordType)) {
    			BatchManageContentPermissions job = new BatchManageContentPermissions('SiteRoles', runNextBatchInSequence);
				Database.executeBatch(job,2000);
			
			} else if('SiteRoles'.equalsIgnoreCase(recordType)) {
				BatchManageContentPermissions job = new BatchManageContentPermissions('RemoveUnsyncedSiteRoles', runNextBatchInSequence);
				Database.executeBatch(job,500);
				
			} else if('RemoveUnsyncedSiteRoles'.equalsIgnoreCase(recordType)) {
				BatchManageContentPermissions job = new BatchManageContentPermissions('ContentShare', runNextBatchInSequence);
				Database.executeBatch(job,2000);

    		} else if('ContentShare'.equalsIgnoreCase(recordType)) {
    			BatchManageContentPermissions job = new BatchManageContentPermissions('OrphanCoverImagesCleanup', runNextBatchInSequence);
    			Database.executeBatch(job,200);
    		} else {
				if(!Test.isRunningTest()) {
					// Added to execute nigthly jobs sequentially
					SchedulerSimpplrServices.executeNextJob('manageContentPermission');
				}

			}
    	}
    }
    
    private void transferContentOwnership(List<Simpplr_Content__c> listOfSimpplrContents) {
    	List<String> listOfGroupDeveloperNames = new List<String>();
    	for(Simpplr_Content__c contentObj:listOfSimpplrContents) {
    		if(String.isNotBlank(contentObj.Site__c)) {
    			listOfGroupDeveloperNames.add('Simpplr_' + contentObj.site__r.Chatter_Group_Id__c + '_Admin');
    		}
    	}
    	List<Group> listOfGroups = [select id, developerName from group where developerName =:listOfGroupDeveloperNames];
    	Map<String, String> mapOfGroupNameAndGroupId = new Map<String, String>(); 
    	for(Group groupObj:listOfGroups) {
    		mapOfGroupNameAndGroupId.put(groupObj.DeveloperName, groupObj.Id);	
    	}
    	for(Simpplr_Content__c contentObj:listOfSimpplrContents) {
    		if(String.isNotBlank(contentObj.Site__c)) {
	    		String key = 'Simpplr_' + contentObj.site__r.Chatter_Group_Id__c + '_Admin';
				if(mapOfGroupNameAndGroupId.containsKey(key)) {
					contentObj.ownerId = mapOfGroupNameAndGroupId.get(key);
				}
    		}
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c>(listOfSimpplrContents), new List<Schema.SObjectField>{
																Simpplr_Content__c.ownerId
															});

    }
    
	private void createUserGroup(List<CollaborationGroup> listOfCollaborationGroups) {
		List<Group> listOfUserGroups = new List<Group>();
		List<String> listOfGroupNames = new List<String>();  
		for(CollaborationGroup cg:listOfCollaborationGroups) {
			listOfGroupNames.add('Simpplr_' + cg.Id + '_Standard');
			listOfGroupNames.add('Simpplr_' + cg.Id + '_Admin');
		}
		List<Group> listOfExistingGroups = [select id, DeveloperName from Group where DeveloperName=:listOfGroupNames];
		Set<String> setOfExistingGroupNames = new Set<String>();
		for(Group grp:listOfExistingGroups) {
			setOfExistingGroupNames.add(grp.DeveloperName);
		}
		Group groupObj; 
		for(CollaborationGroup cg:listOfCollaborationGroups) {
			
			String standardGrpName = 'Simpplr_' + cg.Id + '_Standard';
			if(!setOfExistingGroupNames.contains(standardGrpName)) {
				groupObj = new Group();
				groupObj.DeveloperName = standardGrpName;
				groupObj.DoesSendEmailToMembers = false;
				groupObj.type='Queue';
				groupObj.Name = standardGrpName; 
				listOfUserGroups.add(groupObj);
			}
			
			String adminGrpName = 'Simpplr_' + cg.Id + '_Admin';
			if(!setOfExistingGroupNames.contains(adminGrpName)) {
				groupObj = new Group();
				groupObj.DeveloperName = adminGrpName;
				groupObj.DoesSendEmailToMembers = false;
				groupObj.type='Queue';
				groupObj.Name = adminGrpName;
				listOfUserGroups.add(groupObj);
			}
		}
		if(listOfUserGroups.size() > 0) {

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPSFDCAccessControlResults.InsertResults insertResults = SIMPESAPI.accessController().insertAsUser(listOfUserGroups, new List<Schema.SObjectField> { 
				Group.DeveloperName,
				Group.DoesSendEmailToMembers,
				Group.type,
				Group.Name
			});
			listOfUserGroups = (List<Group>) insertResults.getInsertedObjects();

			createQueueSObjectRecords(listOfUserGroups);
		}
		if(listOfExistingGroups.size() > 0) {
			createMissingQueueSObjectRecords(listOfExistingGroups, 'Simpplr_Content__c');
			createMissingQueueSObjectRecords(listOfExistingGroups, 'Simpplr_Site__c');
		}
    }
    
    private void createQueueSObjectRecords(List<Group> listOfGroups) {
		List<QueueSObject> listOfQueueSObject = new List<QueueSObject>();
		String contentObjectName = PageContext.namespacePrefix + 'Simpplr_Content__c'; 
		String siteObjectName = PageContext.namespacePrefix + 'Simpplr_Site__c'; 
		for(Group groupObj : listOfGroups) {
			listOfQueueSObject.add(new QueueSObject(QueueId=groupObj.Id, SobjectType=contentObjectName));
			listOfQueueSObject.add(new QueueSObject(QueueId=groupObj.Id, SobjectType=siteObjectName));
		}

		if(listOfQueueSObject.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listOfQueueSObject, new List<Schema.SObjectField> { 
				QueueSObject.QueueId,
				QueueSObject.SobjectType
			});
		}
    }
    
    private void createMissingQueueSObjectRecords(List<Group> listOfGroups, String sobjectName) {
		String objectName = PageContext.namespacePrefix + sobjectName; 
    		List<Group> groupsWithMissingQueueSObjectRecords = [select id from Group where id=:listOfGroups and id not in (Select queueId from QueueSobject where SobjectType=:objectName)];
		if(groupsWithMissingQueueSObjectRecords.isEmpty() == false) {
			List<QueueSObject> listOfQueueSObject = new List<QueueSObject>();
			for(Group groupObj : groupsWithMissingQueueSObjectRecords) {
				listOfQueueSObject.add(new QueueSObject(QueueId=groupObj.Id, SobjectType=objectName));
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listOfQueueSObject, new List<Schema.SObjectField> { 
				QueueSObject.QueueId,
				QueueSObject.SobjectType
			});
		}
    }
    
    private void deleteFiles(List<File__c> filesList) {
        Set<Id> cdIdsSet = new Set<Id>();
        Set<Id> setOfCDIdUsedInMultipleContent = new Set<Id>();

    	for (File__c fileObj : filesList) {
            cdIdsSet.add(fileObj.Content_Document__c); // All ContentDocumentId for deleted content files's
        }

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', cdIdsSet);
        // Checking if same contentDocument is used in multiple contents
        String filesQuery = 'SELECT Id, Content_Document__c '+
            ' FROM File__c'+
            ' WHERE Simpplr_Content__r.Is_Deleted__c = false'+ 
            ' AND Content_Document__c IN :soqlParam1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFileWithSameCDId = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);

        for (File__c fileObj : listOfFileWithSameCDId) {
            cdIdsSet.remove(fileObj.Content_Document__c);
        }
    	
    	// deleting records from ContentDocument
        String queryStr = 'SELECT Id FROM ContentDocument WHERE Id = :cdIdsSet';
        
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND LatestPublishedVersion.networkid = null';
    	}
    	List<ContentDocument> cdList = Database.query(queryStr);
    	
    	if(cdList.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().deleteAsUser(cdList);
    	}
    	
    	// marking File__c records as deleted
    	if (!filesList.isEmpty()) {
			for(File__c fileObj : filesList) {
				fileObj.Is_Deleted__c = true;
				fileObj.Content_Document__c = null;
				fileObj.Content_Version__c = null;
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(filesList), new List<Schema.SObjectField>{
														File__c.Is_Deleted__c,
														File__c.Content_Document__c,
														File__c.Content_Version__c
													});
		}
    }
}