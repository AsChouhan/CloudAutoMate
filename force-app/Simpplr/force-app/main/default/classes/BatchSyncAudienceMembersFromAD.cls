/**
 * @description This batch is used sync audience and audience members with AD Groups 
 */
public without sharing class BatchSyncAudienceMembersFromAD implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {
	
    private final String BATCH_SYNC_AUDIENCE_MEM_WITH_AD = 'syncAudienceMemWithAD';
    private final String BATCH_UPDATE_REMOVED_AD_GROUP_AUDIENCE = 'updateRemovedADGroupAudience';
    private final String BATCH_DELETE_ALL_AD_GROUP_AUDIENCE = 'deleteAllADGroupAudience';
    private final String BATCH_DELETE_AUTO_CREATED_AUDIENCE = 'deleteAutoCreatedAudiences';
    private final String BATCH_CREATE_AUTOMATIC_AUDIENCE_AD = 'createAutomaticAudienceAD';
    private final String BATCH_INITIATE_AD_GROUP_SYNC = 'initiateADGroupSync';
    private String batchType; 
	private String query;
    private List<String> audienceList;
	private Exception exceptionDetailsObj;  
    private Set<String> adObjectIdList;  
    private String currentAudienceId;
    private Set<String> adGroupIds; 
    private Boolean runComleteSync;
    private Boolean isCalledFromCompleteGroupSync = false;

    /**
     * @description Constructor for specifying batchType, audienceList to work upon and whether called after Group Sync AWS
     * @param batchType String
     * @param audienceList List<String>
     * @param isCalledFromCompleteGroupSync Boolean
     */
	public BatchSyncAudienceMembersFromAD(String batchType, List<String> audienceList, Boolean isCalledFromCompleteGroupSync) {
		this.batchType = batchType;
		this.audienceList = audienceList;
        this.isCalledFromCompleteGroupSync = isCalledFromCompleteGroupSync;
	}    
    
    /**
     * @description Constructor for batchType - `updateRemovedADGroupAudience` and adGroupIds which are removed from selected groups
     * @param batchType String
     * @param adGroupIds Set<String>
     */    
    public BatchSyncAudienceMembersFromAD(String batchType, Set<String> adGroupIds, Boolean isCalledFromCompleteGroupSync) {
        this.batchType = batchType;
        this.adGroupIds = adGroupIds;
        this.isCalledFromCompleteGroupSync = isCalledFromCompleteGroupSync;
    }

    /**
     * @description Constructor for specifying batchType
     * @param batchType String
     */      
    public BatchSyncAudienceMembersFromAD(String batchType) {
        this.batchType = batchType;
    }  
    
    /**
     * @description Constructor for specifying batchType and whether to execute complete AD GroupSync
     * @param batchType String
     * @param runComleteSync Boolean
     */       
    public BatchSyncAudienceMembersFromAD(String batchType, Boolean runComleteSync) {
        this.batchType = batchType;
        this.runComleteSync = runComleteSync;
    }      
    
    /**
     * @description This is the batch class entry method which returns dynamic record set based on batch type
     * @param bc 
     * @return  `Database.QueryLocator`
     */    
    public database.querylocator start (Database.BatchableContext bc) {

        if(batchType.equalsIgnoreCase(BATCH_SYNC_AUDIENCE_MEM_WITH_AD)) {
            currentAudienceId = audienceList[0];
            Map<String, Object> soqlParamMap = new  Map<String, Object>();
            soqlParamMap.put('soqlParam1', currentAudienceId);              
            String audienceQuery = 'SELECT Id, Audience_Rule_Json__c FROM Audience__c WHERE Id =: soqlParam1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<Audience__c> audiences = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(audienceQuery, soqlParamMap);
            Audience__c audienceObj = audiences[0];
            List<Map<String, Set<String>>> audienceRuleMapList = (List<Map<String, Set<String>>>) JSON.deserialize(
                                                                                    audienceObj.Audience_Rule_Json__c, 
                                                                                    Type.forName('List<Map<String, Set<String>>>')); 
            adObjectIdList = audienceRuleMapList[0].get('aDGroupSet'); 
            String packageName = SimpplrContext.packageName;                                                                               
            query = 'SELECT Id, User__c FROM People__c WHERE User__r.IsActive = true';
            if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
                query += ' AND user__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
            }
        } else if(batchType.equalsIgnoreCase(BATCH_UPDATE_REMOVED_AD_GROUP_AUDIENCE)) {
            // dummy query
            query = 'SELECT Id from App_Config__c LIMIT 1';
            audienceList = new List<String>();
        } else if(batchType.equalsIgnoreCase(BATCH_DELETE_ALL_AD_GROUP_AUDIENCE)) {
            query = 'SELECT Id FROM Audience__c WHERE Is_Created_From_AD_Groups__c = true AND Is_Deleted__c = false';
        } else if(batchType.equalsIgnoreCase(BATCH_DELETE_AUTO_CREATED_AUDIENCE)) {
            query = 'SELECT Id FROM Audience__c WHERE Is_Audience_Created_Automatically__c = true AND Is_Deleted__c = false';
        } else if(batchType.equalsIgnoreCase(BATCH_CREATE_AUTOMATIC_AUDIENCE_AD)) {
            audienceList = new List<String>();
            query = 'SELECT Id, AD_Object_Id__c, Name__c FROM Active_Directory_Group__c WHERE Is_Deleted__c = false';
        } else if(batchType.equalsIgnoreCase(BATCH_INITIATE_AD_GROUP_SYNC)) {
            // dummy query
            query = 'SELECT Id from App_Config__c LIMIT 1';            
        }
        System.debug('query ----' + query);
        return Database.getQueryLocator(query);                
        
    }

    /**
     * @description Actual batch execution based on type
     * @param `Database.BatchableContext` bc 
     * @param `List<sObject>` listOfSObjects 
     */    
    public void execute (Database.BatchableContext bc, sObject[] listOfsObject) {
		try {
            if(batchType.equalsIgnoreCase(BATCH_SYNC_AUDIENCE_MEM_WITH_AD)) {
                List<People__c> peopleList = (List<People__c>) listOfsObject;	    		
                updateAudienceMembers(peopleList);
            } else if(batchType.equalsIgnoreCase(BATCH_UPDATE_REMOVED_AD_GROUP_AUDIENCE)) {
                updateRemovedADGroupsInAudience();
            } else if(batchType.equalsIgnoreCase(BATCH_DELETE_ALL_AD_GROUP_AUDIENCE)) {
                List<Audience__c> audienceListToDelete = (List<Audience__c>)listOfsObject;
                deleteAudiences(audienceListToDelete);
            } else if(batchType.equalsIgnoreCase(BATCH_DELETE_AUTO_CREATED_AUDIENCE)) {
                List<Audience__c> audienceListToDelete = (List<Audience__c>)listOfsObject;
                deleteAudiences(audienceListToDelete);
            } else if(batchType.equalsIgnoreCase(BATCH_CREATE_AUTOMATIC_AUDIENCE_AD)) {
                List<Active_Directory_Group__c> adGroupList = (List<Active_Directory_Group__c>) listOfsObject;
                List<String> newAudienceList = createAutomaticAudienceForAD(adGroupList);
                if(!newAudienceList.isEmpty()) {
                    audienceList.addAll(newAudienceList);
                }
            } else if(batchType.equalsIgnoreCase(BATCH_INITIATE_AD_GROUP_SYNC)) {
                ActiveDirectoryService.intiateADGroupSyncJob();
            }
  		} catch(Exception ex) {
			exceptionDetailsObj =  ex;
			throw ex;
		}        
    }

    /**
     * @description method to create automatic audience for AD groups selected if not already exists
     * @return `List<String>`
     */        
    private List<String> createAutomaticAudienceForAD(List<Active_Directory_Group__c> adGroupList) {

        List<String> newAudienceList = new List<String>();
		Map<String, String> mapOfADObjectIdToAudienceId = getMapOfADObjectIdToAudienceId();
        List<Audience__c> audienceListToInsert = new List<Audience__c>();

        for(Active_Directory_Group__c adGroupObj : adGroupList) {
            String adGroupId = adGroupObj.AD_Object_Id__c;
            if(!mapOfADObjectIdToAudienceId.containsKey(adGroupId)) {
                // automatic audience does not exist

                Audience__c audienceObj = new Audience__c();
                audienceObj.Name__c = adGroupObj.Name__c;

                List<Map<String, Set<String>>> audienceRuleMapList = new List<Map<String, Set<String>>>();
                Set<String> aDGroupIdSet = new Set<String>();
                aDGroupIdSet.add(adGroupId);
                Map<String, Set<String>> audienceRuleMap = new Map<String, Set<String>>();
                audienceRuleMap.put('aDGroupSet', aDGroupIdSet);
                audienceRuleMapList.add(audienceRuleMap);   
                
                audienceObj.Is_Created_From_AD_Groups__c = true;
                audienceObj.Audience_Rule_Json__c = JSON.serialize(audienceRuleMapList);
                audienceObj.Modified_By_People__c = UserContext.peopleId;
                audienceObj.Created_By_People__c = UserContext.peopleId;
                audienceObj.Is_Audience_Created_Automatically__c = true; 
                audienceListToInsert.add(audienceObj);               
            }         
        }	

        if(!audienceListToInsert.isEmpty()) {

            List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
            listOfModifiedFields.add(Audience__c.Is_Created_From_AD_Groups__c);
            listOfModifiedFields.add(Audience__c.Name__c);
            listOfModifiedFields.add(Audience__c.Audience_Rule_Json__c);
            listOfModifiedFields.add(Audience__c.Modified_By_People__c);
            listOfModifiedFields.add(Audience__c.Created_By_People__c);
            listOfModifiedFields.add(Audience__c.Is_Audience_Created_Automatically__c);

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(audienceListToInsert,listOfModifiedFields);
            List<Audience__c> audienceListInserted = (List<Audience__c>)result.getInsertedObjects();
            for(Audience__c audience : audienceListInserted) {
                newAudienceList.add(audience.Id);
            }
        }           

        return newAudienceList;

    }

    /**
     * @description method to return map of AD Id to Audience Id for automatically created audience
     * @return `Map<String, String>`
     */      
	private static Map<String, String> getMapOfADObjectIdToAudienceId() {

		Map<String, String> mapOfADObjectIdToAudienceId = new Map<String, String>();
		String query = 'SELECT Id, Audience_Rule_Json__c FROM Audience__c ' +
            'WHERE Is_Audience_Created_Automatically__c = true AND Is_Deleted__c = False';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience__c> adAutomaticAudienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		for(Audience__c audienceObj : adAutomaticAudienceList) {
			List<Map<String, Set<String>>> audienceRuleMapList = (List<Map<String, Set<String>>>) Json.deserialize(audienceObj.Audience_Rule_Json__c, Type.forName('List<Map<String, Set<String>>>'));	
			Set<String> activeDirectoryIdsSet = audienceRuleMapList[0].get('aDGroupSet');
			String activeDirectoryId = new List<String>(activeDirectoryIdsSet)[0];
			mapOfADObjectIdToAudienceId.put(activeDirectoryId, audienceObj.Id);
		}
		return mapOfADObjectIdToAudienceId;
	}    

    /**
     * @description method to update Audiences created from AD Group that have been removed from selection
     */      
    private void updateRemovedADGroupsInAudience() {

        List<Audience__c> audienceListToDelete = new List<Audience__c>();
        List<Audience__c> audienceListToUpdate = new List<Audience__c>();
        String query = 'SELECT Id, Audience_Rule_Json__c, Is_Audience_Created_Automatically__c FROM Audience__c ' + 
            'WHERE Is_Created_From_AD_Groups__c = true AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Audience__c> adAudienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(query, null);        
        for(Audience__c adAudienceObj : adAudienceList) {
            Boolean updateRecord = false;
            Boolean deleteRecord = false;
            Boolean isADAudienceCreatedAutomatically = adAudienceObj.Is_Audience_Created_Automatically__c;
            Audience__c audienceObj = new Audience__c(Id = adAudienceObj.Id);
            List<Map<String, Set<String>>> audienceRuleMapList = (List<Map<String, Set<String>>>) Json.deserialize(adAudienceObj.Audience_Rule_Json__c, Type.forName('List<Map<String, Set<String>>>'));
            Set<String> activeDirectoryIdsSet = audienceRuleMapList[0].get('aDGroupSet');
            Set<String> aDGroupSetIds = new Set<String>();
            for(String activeDirectoryId : activeDirectoryIdsSet) {
                if(adGroupIds.contains(activeDirectoryId)) {
                    if(isADAudienceCreatedAutomatically || activeDirectoryIdsSet.size() == 1) {
                        deleteRecord = true;
                        break;
                    } 
                    updateRecord = true;
                    continue;
                }
                aDGroupSetIds.add(activeDirectoryId);
            }
            if(aDGroupSetIds.isEmpty()) {
                deleteRecord = true;
            }
            audienceRuleMapList = new List<Map<String, Set<String>>>();
            Map<String, Set<String>> audienceRuleMap = new Map<String, Set<String>>();
            audienceRuleMap.put('aDGroupSet', aDGroupSetIds);
            audienceRuleMapList.add(audienceRuleMap);
            audienceObj.Audience_Rule_Json__c = JSON.serialize(audienceRuleMapList);
            if(deleteRecord) {
                audienceListToDelete.add(audienceObj);
            } else if(updateRecord) {
                audienceList.add(audienceObj.Id);
                audienceListToUpdate.add(audienceObj);
            }
        }

        if(!audienceListToUpdate.isEmpty()) {
			List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
            listOfModifiedFields.add(Audience__c.Audience_Rule_Json__c);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Audience__c>(audienceListToUpdate),listOfModifiedFields);	            
        }

        if(!audienceListToDelete.isEmpty()) {
            deleteAudiences(audienceListToDelete);
        }
    }

    /**
     * @description method to delete AD Audience and do cleanup task on other objects
     * @param audienceListToDelete `List<Audience__c>`
     */    
    private void deleteAudiences(List<Audience__c> audienceListToDelete) {
        List<String> audienceIdsListToDelete = new List<String>();
        List<Audience__c> audienceListToUpdate = new List<Audience__c>();
        for(Audience__c audienceObj : audienceListToDelete) {
            audienceIdsListToDelete.add(audienceObj.Id);
            Audience__c newAudienceObj = new Audience__c(Id = audienceObj.Id);
            newAudienceObj.Is_Deleted__c = true;
            audienceListToUpdate.add(newAudienceObj);
        }
        if(!audienceListToUpdate.isEmpty()) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, Audience__c>(audienceListToUpdate), new List<Schema.SObjectField>{
                Audience__c.Is_Deleted__c
                });             
        }
        AudienceService service = new AudienceService();
        service.markCampaignAsInactive(audienceIdsListToDelete);
        service.markAlertsAsExpired(audienceIdsListToDelete);
        service.deletePendingSubscriptions(audienceIdsListToDelete);
        service.deleteDraftOrScheduledNewsletter(audienceIdsListToDelete);        
    }

    /**
     * @description method to update Audience Member for a particular audience created from AD and peopleList provided
     * @param peopleList `List<People__c>`
     */
    private void updateAudienceMembers(List<People__c> peopleList) {

        // query ADGM peopleIds
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', adObjectIdList);  
        soqlParamMap.put('soqlParam2', peopleList);        
        String query = 'SELECT People__c FROM Active_Directory_Group_Member__c ' + 
            'WHERE Active_Directory_Group__r.AD_Object_Id__c =: soqlParam1 ' + 
            'AND People__c =: soqlParam2 AND Active_Directory_Group__r.Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Active_Directory_Group_Member__c> adGrpMemberList = (List<Active_Directory_Group_Member__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);        
        Set<String> adGroupMemberPeopleIds = new Set<String>();
        for(Active_Directory_Group_Member__c adGrpMember : adGrpMemberList) {
            adGroupMemberPeopleIds.add(adGrpMember.People__c);
        }

        // query AM peopleIds
        soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', currentAudienceId); 
        soqlParamMap.put('soqlParam2', peopleList);           
        query = 'SELECT People__c FROM Audience_Member__c WHERE Audience__c =: soqlParam1 AND People__c =: soqlParam2';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Audience_Member__c> audienceMemberList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);        
        Set<String> audienceMemberPeopleIds = new Set<String>();
        for(Audience_Member__c audienceMember : audienceMemberList) {
            audienceMemberPeopleIds.add(audienceMember.People__c);
        }

        // find new Ids to insert
        // find common Ids
        Set<String> peopleIdsToInsert = new Set<String>();
        List<Audience_Member__c> audienceMemberToInsert = new List<Audience_Member__c>();
        Set<String> commonPeopleIds = new Set<String>();
        for(String adGroupMemberPeopleId : adGroupMemberPeopleIds) {
            if(audienceMemberPeopleIds.contains(adGroupMemberPeopleId)) {
                // already present
                commonPeopleIds.add(adGroupMemberPeopleId);
            } else{
                // not present              
                peopleIdsToInsert.add(adGroupMemberPeopleId);
            }
        }

        // find ids to delete
        Set<String> peopleIdsToDelete = new Set<String>();
        for(String audienceMemberPeopleId : audienceMemberPeopleIds) {
            if(!commonPeopleIds.contains(audienceMemberPeopleId)) {
                // not present
                peopleIdsToDelete.add(audienceMemberPeopleId);
            }
        }

        List<Audience_Member__c> newAudienceMemberList = new List<Audience_Member__c>();
        for(People__c peopleObj : peopleList) {
            if(peopleIdsToInsert.contains(peopleObj.Id)) {
                // insert new Audience Member record
    			Audience_Member__c audienceMember = new Audience_Member__c(
														Audience__c = this.currentAudienceId,
														Is_All_Subscription_Required__c = true,
														People__c = peopleObj.Id,
														User__c = peopleObj.User__c);
				newAudienceMemberList.add(audienceMember);                
            }
        }

        soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', currentAudienceId);  
        soqlParamMap.put('soqlParam2', peopleIdsToDelete);           
        query = 'SELECT Id FROM Audience_Member__c WHERE Audience__c =: soqlParam1 AND People__c =: soqlParam2';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        audienceMemberList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        if(!audienceMemberList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(audienceMemberList);            
        }

    	// Add new members acc to the new rule, If any
		if(!newAudienceMemberList.isEmpty()){
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(newAudienceMemberList, new List<Schema.SObjectField>{
																			Audience_Member__c.Audience__c,
																			Audience_Member__c.Is_All_Subscription_Required__c,
																			Audience_Member__c.People__c,
																			Audience_Member__c.User__c});
    	}       

    }    

    /**
     * @description Batch finish method for running batch in sequence base on batch type
     * @param bc 
     */    
    public void finish (Database.BatchableContext bc) {

		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
				CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		}       

        if(batchType.equalsIgnoreCase(BATCH_SYNC_AUDIENCE_MEM_WITH_AD)) {
            if(canStartNextBatch) {
                String removedAudienceId  = audienceList.remove(0);
                if(!audienceList.isEmpty()) {
                    Database.executeBatch(new BatchSyncAudienceMembersFromAD(BATCH_SYNC_AUDIENCE_MEM_WITH_AD, audienceList, isCalledFromCompleteGroupSync), 2000);
                } else {
                    if(isCalledFromCompleteGroupSync) {
                        // Update Batch_Processing__c flag
                        ActiveDirectoryService.updateBatchProcessingFlag(false);
                        ActiveDirectoryService.logADGroupSyncStatus('successful', 'Group Sync activedirectory');        
                    }
                    String query = 'SELECT Id, Status__c FROM Subscription__c WHERE Audience__r.Is_Created_From_AD_Groups__c = true AND Audience__r.Is_Deleted__c = false';
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUSer(query, null);                                         
                    if(!subscriptionList.isEmpty()) {
                        // Called to update subscriptions
                        Map<String, String> batchParamMap = new Map<String, String>();
                        batchParamMap.put('audienceId', removedAudienceId);                        
                        BatchProcessSubscription job = new BatchProcessSubscription('newAudienceMembers', batchParamMap);
                        Database.executeBatch(job, 200);
                    }
                }                
            } else {
                if(isCalledFromCompleteGroupSync) {
                    ActiveDirectoryService.updateBatchProcessingFlag(false);
                    ActiveDirectoryService.logADGroupSyncStatus('failed', 'Group Sync activedirectory');    
                }    
            }
        } else if(batchType.equalsIgnoreCase(BATCH_UPDATE_REMOVED_AD_GROUP_AUDIENCE)) {
            if(isCalledFromCompleteGroupSync) {
                ActiveDirectoryService.initiateAudienceMemSync();
            } else {
                if(!audienceList.isEmpty()) {
                    Database.executeBatch(new BatchSyncAudienceMembersFromAD(BATCH_SYNC_AUDIENCE_MEM_WITH_AD, audienceList, false), 2000);
                }
            }
        } else if(batchType.equalsIgnoreCase(BATCH_CREATE_AUTOMATIC_AUDIENCE_AD)) {
            if(runComleteSync) {
                ActiveDirectoryService.intiateADGroupSyncJob();
            } else {
                if(!audienceList.isEmpty()) {
                    Database.executeBatch(new BatchSyncAudienceMembersFromAD(BATCH_SYNC_AUDIENCE_MEM_WITH_AD, audienceList, false), 2000);
                }                    
            }
        }
    }
}