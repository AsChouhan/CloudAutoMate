public with sharing class BatchProcessSubscription implements Database.Batchable<SObject>, Database.Stateful  {
	private String batchType;
	private String query;
	private Boolean runNextBatchInSequence;
	private Exception exceptionDetailsObj;
	private String audienceId;
	Set<Id> sitesIds;

	private String subscriptionEntityId;
	private String subscriptionId;
	private Set<Id> siteIdSet;
	private List<Id> chatterGroupIdList;
	private Boolean isUserEmailToBeSwitchedOff;
	private Set<CollaborationGroupMember> deletedCGMemberSet = new Set<CollaborationGroupMember>();
	
    public BatchProcessSubscription (String batchType, String audienceId, Boolean runNextBatchInSequence, String subscriptionId) {
		this.isUserEmailToBeSwitchedOff = SimpplrContext.isFeatureEnabled('Salesforce_Chatter_Emails_Switched_On'); 
		this.batchType = batchType;
		this.audienceId = audienceId;
		this.runNextBatchInSequence = runNextBatchInSequence;
		this.subscriptionId = subscriptionId;
    } 
    
    public BatchProcessSubscription(String batchType, Set<Id> sitesIds, Boolean runNextBatchInSequence) {
		this.isUserEmailToBeSwitchedOff = SimpplrContext.isFeatureEnabled('Salesforce_Chatter_Emails_Switched_On'); 
    	this.batchType = batchType;
    	this.sitesIds = sitesIds;
    	this.runNextBatchInSequence = runNextBatchInSequence;
    }

	public BatchProcessSubscription (String batchType, Map<String, String> mapOfBatchParams) {
		this.isUserEmailToBeSwitchedOff = SimpplrContext.isFeatureEnabled('Salesforce_Chatter_Emails_Switched_On'); 
		this.batchType = batchType;
		
		if(mapOfBatchParams != null){
			if(mapOfBatchParams.containsKey('audienceId')){
				this.audienceId = mapOfBatchParams.get('audienceId');
			}
			
			if(mapOfBatchParams.containsKey('subscriptionEntityId')){
				this.subscriptionEntityId = mapOfBatchParams.get('subscriptionEntityId');
			}
			
			if(mapOfBatchParams.containsKey('subscriptionId')){
				this.subscriptionId = mapOfBatchParams.get('subscriptionId');
			}
		}
	}
	public BatchProcessSubscription (String batchType,Set<Id> siteIdSet) { 
		this.isUserEmailToBeSwitchedOff = SimpplrContext.isFeatureEnabled('Salesforce_Chatter_Emails_Switched_On'); 
		this.batchType = batchType;
		this.siteIdSet = siteIdSet;
	}
	
	public BatchProcessSubscription (Boolean isUserEmailToBeSwitchedOff, String batchTypeArg, String audienceId) {
		this.isUserEmailToBeSwitchedOff = isUserEmailToBeSwitchedOff;
		this.batchType = batchTypeArg;
		this.audienceId = audienceId;
		
	}

	/**
	 * @description - BatchProcessSubscription to create membership records
	 * @param - String Batch type
	 * @param - List of chatter group ids
	 */
	public BatchProcessSubscription (String batchTypeArg, List<String> chatterGroupIdList) {
		this.batchType = batchTypeArg;
		this.chatterGroupIdList = chatterGroupIdList;
		
	}
    
  	public database.querylocator start (Database.BatchableContext bc) {		
		List<Id> audienceIdList = new List<Id>();
		String packageName = SimpplrContext.packageName;  
		if('updateSubscriptionEntityWhenSitesMadePublic'.equalsIgnoreCase(batchType)) {
  			query = 'Select Id, Status__c, Subscription__c, Site__c, Site__r.Name, Site__r.Chatter_Group_Id__c FROM Subscription_Entity__c WHERE Site__c =: sitesIds AND Status__c =\'Pending\'';
  		
		} else if('updateSubscriptionEntityWhenSitesMadePrivate'.equalsIgnoreCase(batchType)) {
  			query = 'Select Id, Status__c, Subscription__c, Site__c, Site__r.Name, Site__r.Chatter_Group_Id__c FROM Subscription_Entity__c WHERE Site__c =: sitesIds AND Status__c =\'Approved\'';
  		
		} else if ('newSubscriptionEntities'.equalsIgnoreCase(batchType) || 'followMandatorySubscriptions'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT id, Audience__c, People__r.User__r.UserPreferencesDisableAllFeedsEmail, ' + 
  					' People__r.User__c, Is_All_Subscription_Required__c FROM Audience_Member__c ' +
  					' WHERE Is_All_Subscription_Required__c = false AND User__r.IsActive = true ';
  			
  			if(String.isNotBlank(this.audienceId)){
				query += ' AND Audience__c =: audienceId AND Audience__r.Is_Deleted__c = false ';
	  		}		
			  
			if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
				query +=' and User__c IN '+
						' (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
			}

		} else if ('newAudienceMembers'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT id, Audience__c, People__r.User__r.UserPreferencesDisableAllFeedsEmail,' +
  					' People__r.User__c, Is_All_Subscription_Required__c FROM Audience_Member__c ' +
  					' WHERE Is_All_Subscription_Required__c = true AND User__r.IsActive = true ';
  			
 			if(String.isNotBlank(this.audienceId)){
  				query += ' AND Audience__c =: audienceId';
	  		}
					  
			if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
				query +=' and User__c IN '+
						' (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
			}
			
  		} else if ('subscriptionApproved'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT id, Audience__c, People__r.User__r.UserPreferencesDisableAllFeedsEmail,' +
  					' People__r.User__c, Is_All_Subscription_Required__c FROM Audience_Member__c ';
  			
  			if(String.isNotBlank(this.audienceId)){
  				query += ' WHERE Audience__c =: audienceId';
	  		}
		
			if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
				query +=' and User__c IN '+
						' (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
			}

		} else if ('sitesMadePublic'.equalsIgnoreCase(batchType)) {
			List<Subscription_entity__c> seList = [select Subscription__r.Audience__c from Subscription_entity__c
			 										where Site__c=:siteIdSet];
			for(Subscription_entity__c seObj : seList){
				audienceIdList.add(seObj.Subscription__r.Audience__c);
			}
  			query = 'SELECT id, Audience__c, People__r.User__r.UserPreferencesDisableAllFeedsEmail,' +
  					' People__r.User__c, Is_All_Subscription_Required__c FROM Audience_Member__c ' +
  					' WHERE Audience__c =:audienceIdList ';

			if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
				query +=' and User__c IN '+
						' (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
			}

  		} else if ('unsubscribeAudienceMembers'.equalsIgnoreCase(batchType)) {
  			query = 'SELECT id, Audience__c, People__r.User__c, People__c ' +
  					' FROM Audience_Member__c WHERE People__r.App_Moderation_Permission__c = \'No\'';
  			
  			if(String.isNotBlank(this.audienceId)){
  				query += ' AND Audience__c =: audienceId';
	  		}
			  
			if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
				query +=' and User__c IN '+
						' (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
			}

  		} else if ('createGroupMembership'.equalsIgnoreCase(batchType)) {
			query = 'SELECT Id, CollaborationGroupId, CollaborationRole, MemberId FROM CollaborationGroupMember WHERE CollaborationGroupId IN:chatterGroupIdList';

		}
  		 
		return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext bc, sObject[] listOfsObject) {
    	try {
    		if('updateSubscriptionEntityWhenSitesMadePublic'.equalsIgnoreCase(batchType)) {
	    		List<Subscription_Entity__c> listOfSiteSubscriptions = (List<Subscription_Entity__c>)listOfsObject;
				for(Subscription_Entity__c subscriptionObj : listOfSiteSubscriptions) {
					subscriptionObj.Status__c = 'Approved';
				}
				
				update listOfSiteSubscriptions;
			} else if('updateSubscriptionEntityWhenSitesMadePrivate'.equalsIgnoreCase(batchType)) {
				List<Subscription_Entity__c> listOfSiteSubscriptions = (List<Subscription_Entity__c>)listOfsObject;
				Set<String> subscriptionIdSet = new Set<String>();
				for(Subscription_Entity__c subscriptionObj : listOfSiteSubscriptions) {
					subscriptionObj.Status__c = 'Pending';
					subscriptionIdSet.add(subscriptionObj.Subscription__c);
				}
				
				update listOfSiteSubscriptions;
				List<Subscription__c> subscriptionList = [SELECT Id,Membership_Type__c  FROM Subscription__c WHERE Id IN: subscriptionIdSet AND Membership_Type__c='siteFollowers'];
				for(Subscription__c subscription: subscriptionList ){
					subscription.Membership_Type__c = 'siteMembers';
				}
				update subscriptionList;
				NotificationDispatcher.sendPendingSubscriptionNotification(listOfSiteSubscriptions);
				NotificationDispatcher.sendPendingSubscriptionNotificationEmail(listOfSiteSubscriptions);
			
			} else if('unsubscribeAudienceMembers'.equalsIgnoreCase(batchType)){
				List<Audience_Member__c> listOfAudienceMember = (List<Audience_Member__c>) listOfsObject;
	  			unsubscribeAudienceMembers(listOfAudienceMember);
	  		
			} else if('newSubscriptionEntities'.equalsIgnoreCase(batchType)) {
				List<Audience_Member__c> listOfAudienceMember = (List<Audience_Member__c>) listOfsObject;
	  			processAudienceMembers(listOfAudienceMember);

	  		} else if('followMandatorySubscriptions'.equalsIgnoreCase(batchType)) {
				List<Audience_Member__c> listOfAudienceMember = (List<Audience_Member__c>) listOfsObject;
	  			processAudienceMembers(listOfAudienceMember);
				  
	  		} else if('newAudienceMembers'.equalsIgnoreCase(batchType)) {
				List<Audience_Member__c> listOfAudienceMember = (List<Audience_Member__c>) listOfsObject;
	  			processAudienceMembers(listOfAudienceMember);
				  
	  		} else if('subscriptionApproved'.equalsIgnoreCase(batchType)) {
				List<Audience_Member__c> listOfAudienceMember = (List<Audience_Member__c>) listOfsObject;
	  			processAudienceMembers(listOfAudienceMember);
				  
	  		} else if('sitesMadePublic'.equalsIgnoreCase(batchType)) {
				List<Audience_Member__c> listOfAudienceMember = (List<Audience_Member__c>) listOfsObject;
	  			processAudienceMembers(listOfAudienceMember);
				  
	  		} else if('createGroupMembership'.equalsIgnoreCase(batchType)){
				List<CollaborationGroupMember> listOfCollaborationGroupMembers = (List<CollaborationGroupMember>) listOfsObject;
				processMembership(listOfCollaborationGroupMembers);
			}
			
			
    	} catch (Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
    	}
    }

	private void unsubscribeAudienceMembers (List<Audience_Member__c> listOfAudienceMember) {
		List<Subscription_Entity__c> subscriptionEntityList = [SELECT id, People__r.user__c, site__r.chatter_group_id__c,
		  														People__c, Site__c FROM Subscription_Entity__c
		  														WHERE Subscription__c = :subscriptionId];
		
		Set<String> audienceUserIdSet = new Set<String>();
		for(Audience_Member__c audienceMemberObj : listOfAudienceMember){
			audienceUserIdSet.add(audienceMemberObj.People__r.User__c);
		}
		
		Set<String> chatterGroupIdToUnfollowSet = new Set<String>();
		Set<String> userIdToUnfollowSet = new Set<String>();
		for(Subscription_Entity__c subscriptionEntityObj : subscriptionEntityList){
			if(String.isNotBlank(subscriptionEntityObj.Site__c)){
				chatterGroupIdToUnfollowSet.add(subscriptionEntityObj.site__r.chatter_group_id__c);
			} else {
				userIdToUnfollowSet.add(subscriptionEntityObj.People__r.user__c);
			}	
		}
		
		if(!chatterGroupIdToUnfollowSet.isEmpty()){
			// Remove app managers and site owners from the list
			List<CollaborationGroupMember> listOfCollabGrpMember = [SELECT Id, MemberId, CollaborationRole,
																	CollaborationGroup.OwnerId
																	FROM CollaborationGroupMember 
																	WHERE CollaborationRole = 'Standard'
																	And MemberId =:audienceUserIdSet
																	And CollaborationGroupId IN :chatterGroupIdToUnfollowSet]; 
					
			if(!listOfCollabGrpMember.isEmpty()){
				deletedCGMemberSet.addAll(listOfCollabGrpMember);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(listOfCollabGrpMember);
			}
		}
		
		if(!userIdToUnfollowSet.isEmpty()){
			List<EntitySubscription> entitySubscriptionList = [SELECT id FROM EntitySubscription WHERE 
																ParentId IN :userIdToUnfollowSet
																AND SubscriberId IN :audienceUserIdSet LIMIT 1000];
			
			if(!entitySubscriptionList.isEmpty()){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(entitySubscriptionList);
			}													
		}
	}

	private void removeGroupMembers(Set<CollaborationGroupMember> cgMemberSet){
		
		BatchManageVideo batchJob = new BatchManageVideo('removeGroupMembers', cgMemberSet);
		Database.executeBatch(batchJob, 50);	
	}
	
	public void processAudienceMembers (List<Audience_Member__c> listOfAudienceMember) {
		Set<String> setOfAudienceId = new Set<String>(); 
		Map<String, List<Audience_Member__c>> audienceIdListOfAudienceMembersMap = new Map<String, List<Audience_Member__c>>();

		Set<Id> peopleIdSet = new Set<Id>();
		Set<Id> siteIdSet = new Set<Id>();
		for (Audience_Member__c audienceMemberObj: listOfAudienceMember) {
			setOfAudienceId.add(audienceMemberObj.Audience__c);
			peopleIdSet.add(audienceMemberObj.people__c);
			audienceMemberObj.Is_All_Subscription_Required__c = false;
			//Made map of Audience Id and List of its audience Members
			List<Audience_Member__c> audienceMemberList = new List<Audience_Member__c>();
			if (audienceIdListOfAudienceMembersMap.get(audienceMemberObj.Audience__c)!=null){
				audienceMemberList.addAll(audienceIdListOfAudienceMembersMap.get(audienceMemberObj.Audience__c));
			}
			audienceMemberList.add(audienceMemberObj);
			audienceIdListOfAudienceMembersMap.put(audienceMemberObj.Audience__c, audienceMemberList);
		}
		String query = 	'SELECT id, Subscription__r.audience__c, Subscription__r.Membership_Type__c, ' +
  						'Processing_Required__c, Subscription__c, People__r.user__c, site__r.chatter_group_id__c, ' +
  						'People__r.user__r.UserPreferencesDisableAllFeedsEmail, People__c, Site__c ' +
  						'FROM Subscription_Entity__c ' +
						'WHERE Subscription__r.audience__c IN :setOfAudienceId AND Status__c = \'approved\' ';
				
  		if ('newSubscriptionEntities'.equalsIgnoreCase(batchType)) {
  			query += ' AND Processing_Required__c = true' + (String.isNotBlank(subscriptionId) ? ' AND Subscription__c = :subscriptionId ' : '');
  		}
  		
  		if('subscriptionApproved'.equalsIgnoreCase(batchType)){
  			query += ' AND Id = :subscriptionEntityId';
  		}
  		
  		if('sitesMadePublic'.equalsIgnoreCase(batchType)){
  			query += ' AND site__c = :siteIdSet';
  		}
  		if('followMandatorySubscriptions'.equalsIgnoreCase(batchType)){
  			query += ' AND Subscription__r.Action_Type__c = \'mandatory\' AND Processing_Required__c = false';
  		}
  		
		List<Subscription_Entity__c> listOfSubscriptionEntity = Database.query(query);
				  
  		Map<String, List<String>> mapOfAudIdWithChatGrpsToFollow = new Map<String, List<String>>();
  		Map<String, List<String>> mapOfAudIdWithUsersToFollow = new Map<String, List<String>>();
  		Set<String> emailSettingsEnabledUserIdSet = new Set<String>();
  		Set<String> userPreferencesDisableFollowersEmailSet = new Set<String>();
		  
  		if (!listOfSubscriptionEntity.isEmpty()) {
  			for (Subscription_Entity__c subsEntityObj: listOfSubscriptionEntity) {
  				List<String> listOfIdToFollow = new List<String>();
  				
  				if (String.isNotBlank(subsEntityObj.Site__c)) { 
					siteIdSet.add(subsEntityObj.site__c);
  					if (mapOfAudIdWithChatGrpsToFollow.get(subsEntityObj.Subscription__r.audience__c) != null) {
  						listOfIdToFollow.addAll(mapOfAudIdWithChatGrpsToFollow.get(subsEntityObj.Subscription__r.audience__c));
  					}
  					 
  					listOfIdToFollow.add(subsEntityObj.site__r.chatter_group_id__c);
  					mapOfAudIdWithChatGrpsToFollow.put(subsEntityObj.Subscription__r.audience__c, listOfIdToFollow);
				  
  				} else if (String.isNotBlank(subsEntityObj.People__c)) {
  					
  					if (mapOfAudIdWithUsersToFollow.get(subsEntityObj.Subscription__r.audience__c) != null) {
						listOfIdToFollow.addAll(mapOfAudIdWithUsersToFollow.get(subsEntityObj.Subscription__r.audience__c));
  					}
  					
  					if(subsEntityObj.People__r.User__r.UserPreferencesDisableAllFeedsEmail == false){
  						emailSettingsEnabledUserIdSet.add(subsEntityObj.People__r.user__c);
  					}
  					
  					listOfIdToFollow.add(subsEntityObj.People__r.user__c);
  					mapOfAudIdWithUsersToFollow.put(subsEntityObj.Subscription__r.audience__c, listOfIdToFollow);
  					
  					userPreferencesDisableFollowersEmailSet.add(subsEntityObj.People__r.user__c);
  				}
  				
  			}
  			
  		}
		
  		List<CollaborationGroupMember> listOfCollbGrpMemForInsert = new List<CollaborationGroupMember>();
  		List<EntitySubscription> listOfEntitySubsForInsert = new List<EntitySubscription>();
		
  		for (Audience_Member__c audMemberObj: listOfAudienceMember) {
			List<String> listOfChatterGroupToFollow = mapOfAudIdWithChatGrpsToFollow.get(audMemberObj.Audience__c);
  			if (listOfChatterGroupToFollow != null && !listOfChatterGroupToFollow.isEmpty()) {
				
  				for (String chatterGrpId: listOfChatterGroupToFollow) {
  					CollaborationGroupMember collabGrpMemObj = new CollaborationGroupMember();
  					collabGrpMemObj.CollaborationGroupId = chatterGrpId;
  					collabGrpMemObj.MemberId = audMemberObj.People__r.user__c;
  					collabGrpMemObj.CollaborationRole = 'Standard';
  					
  					listOfCollbGrpMemForInsert.add(collabGrpMemObj);
  					
  					if(audMemberObj.People__r.User__r.UserPreferencesDisableAllFeedsEmail == false){
  						emailSettingsEnabledUserIdSet.add(audMemberObj.People__r.user__c);
  					}
  				}
				
  			}
  			
  			List<String> listOfUserToFollow = mapOfAudIdWithUsersToFollow.get(audMemberObj.Audience__c);
			  
  			if (listOfUserToFollow != null && !listOfUserToFollow.isEmpty()) {
  				
  				for (String userId: listOfUserToFollow) {
  					EntitySubscription entitySubsObj = new EntitySubscription();
  					entitySubsObj.ParentId = userId;
  					entitySubsObj.SubscriberId = audMemberObj.People__r.user__c;
  					listOfEntitySubsForInsert.add(entitySubsObj);
  				}
  			}
		}
		//Creating Site Roles
		createSiteRoles(audienceIdListOfAudienceMembersMap, listOfSubscriptionEntity, peopleIdSet, siteIdSet );
		
  		// Disable followers email
  		if(isUserEmailToBeSwitchedOff != null && isUserEmailToBeSwitchedOff) {
  			disableFollowersEmails(userPreferencesDisableFollowersEmailSet);
  		}
  		
  		List<String> emailOnOffUserIdlist = null;
  		if(isUserEmailToBeSwitchedOff != null && isUserEmailToBeSwitchedOff) {
	  		if(!emailSettingsEnabledUserIdSet.isEmpty()){
	  			emailOnOffUserIdlist = new List<String>(emailSettingsEnabledUserIdSet);
	  			Utility.setChatterEmailSettingsForUsers(true, emailOnOffUserIdlist);
	  		}
  		}
  		
  		if(!listOfEntitySubsForInsert.isEmpty()){
  			SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
  			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(listOfEntitySubsForInsert,
														new List<Schema.SObjectField>{
															EntitySubscription.ParentId,
															EntitySubscription.SubscriberId
														});
  		}

  		if(!listOfCollbGrpMemForInsert.isEmpty()){
  			SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
  			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(listOfCollbGrpMemForInsert,
														new List<Schema.SObjectField>{
															CollaborationGroupMember.CollaborationRole,
															CollaborationGroupMember.CollaborationGroupId,
															CollaborationGroupMember.MemberId
														});
  		}
		  
  		if (emailOnOffUserIdlist != null && !emailOnOffUserIdlist.isEmpty()) {
  			Utility.setChatterEmailSettingsForUsers(false, emailOnOffUserIdlist);
  		}
  		
  		// Mark audience members all subscription required as false after processing 
  		if('newAudienceMembers'.equalsIgnoreCase(batchType)){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,Audience_Member__c>(listOfAudienceMember),new List<Schema.SObjectField>
														{Audience_Member__c.Is_All_Subscription_Required__c
													});
		}  
	}

	/**
	 * @description - processMembership to create membership records
	 * @param - List of CollaborationGroupMembers
	 */
	public void processMembership (List<CollaborationGroupMember> listOfCollaborationGroupMembers) {
		List<GroupMember> listOfGroupMemberToInsert = Utility.getGroupMembershipToCreate(listOfCollaborationGroupMembers);
		if(listOfGroupMemberToInsert.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(listOfGroupMemberToInsert, new List<Schema.SObjectField>{GroupMember.groupId,GroupMember.UserOrGroupId});
		}

	}
	
	// Try to ON UserPreferencesDisableFollowersEmail setting for the subscription entity users
  	// (i.e. the user set whom audience going to follow)  
  	private void disableFollowersEmails(Set<String> userIdSet){
		if(!userIdSet.isEmpty()){
  			try{
	  			String queryStr = 'SELECT id FROM User WHERE id IN :userIdSet AND isactive = true AND UserPreferencesDisableFollowersEmail = false';
				String packageName = SimpplrContext.packageName;
				if (!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
					queryStr += ' AND id IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
				}

				List<User> userList = Database.query(queryStr);
	  			
	  			for(User userObj : userList){
	  				userObj.UserPreferencesDisableFollowersEmail = true;
	  			}
	  			
	  			if(!userList.isEmpty()){
	  				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, User>(userList),
																new List<Schema.SObjectField>{
																	User.UserPreferencesDisableFollowersEmail});
	  			} 						
	  		}catch(Exception ex){
	  			// Do nothing
	  		}
  		}
	}
    
    public void finish (Database.BatchableContext bc) {

		AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
				CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchProcessSubscription.' + batchType, exceptionDetailsObj);
		}

		if('updateSubscriptionEntityWhenSitesMadePublic'.equalsIgnoreCase(batchType)){
			BatchProcessSubscription job = new BatchProcessSubscription('sitesMadePublic', sitesIds);
			Database.executeBatch(job, 200);    		
    	
		} else if ('newSubscriptionEntities'.equalsIgnoreCase(batchType)) {
			Map<String, String> batchParamMap = new Map<String, String>();
			batchParamMap.put('audienceId', audienceId);
			batchParamMap.put('subscriptionId', subscriptionId);
			
			BatchProcessSubscription job = new BatchProcessSubscription('newAudienceMembers', batchParamMap);
			Database.executeBatch(job, 200);
			
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				BatchPushDataForExternalSearch failedTransactionJob = new BatchPushDataForExternalSearch('FailedTransactions', false);
				Database.executeBatch(failedTransactionJob, 50);
			}
		
		} else if ('newAudienceMembers'.equalsIgnoreCase(batchType)) {
			String query = 'select id, Site__r.Chatter_Group_id__c from Subscription_Entity__c where Subscription__r.Audience__c=:audienceId ';
			query += String.isNotBlank(subscriptionId) ? ' AND Subscription__c = :subscriptionId' : '';
			List<Subscription_Entity__c> listOfSubsEntityForProcessing = Database.query(query);
			List<String> chatterGroupIdList = new List<String>();
			for (Subscription_Entity__c subsEntityObj: listOfSubsEntityForProcessing) {
				subsEntityObj.Processing_Required__c = false;
				if(String.isNotBlank(subsEntityObj.Site__r.Chatter_Group_id__c)) {
					chatterGroupIdList.add(subsEntityObj.Site__r.Chatter_Group_id__c);
				}
			}
			if(!chatterGroupIdList.isEmpty()) {
				BatchManageContentPermissions siteRolesJob = new BatchManageContentPermissions('SiteRoles', chatterGroupIdList, false);
				Database.executeBatch(siteRolesJob, 2000);
			}
			
			update listOfSubsEntityForProcessing;
			
			if(canStartNextBatch) {
				processPendingAudienceMembership();
			} else {
				// newSubscriptionEntities calls => newAudienceMembers => canStartNextBatch is TRUE then self invoke, otherwise move to next
				syncSiteMembersToNativeVideoAWS();
			}
		
		} else if ('subscriptionApproved'.equalsIgnoreCase(batchType) && String.isNotBlank(subscriptionEntityId)) {
			List<Subscription_Entity__c> listOfSubsEntityApproved = [select id, Site__r.Chatter_Group_id__c from Subscription_Entity__c where id=:subscriptionEntityId];
			List<String> chatterGroupIdList = new List<String>();
			for (Subscription_Entity__c subsEntityObj: listOfSubsEntityApproved) {
				subsEntityObj.Processing_Required__c = false;
				if(String.isNotBlank(subsEntityObj.Site__r.Chatter_Group_id__c)) {
					chatterGroupIdList.add(subsEntityObj.Site__r.Chatter_Group_id__c);
				}
			}
			update listOfSubsEntityApproved;
			if(!chatterGroupIdList.isEmpty()) {
				BatchManageContentPermissions siteRolesJob = new BatchManageContentPermissions('SiteRoles', chatterGroupIdList, false);
				Database.executeBatch(siteRolesJob, 2000);

				BatchProcessSubscription membershipJob = new BatchProcessSubscription('createGroupMembership',chatterGroupIdList);
				Database.executeBatch(membershipJob, 2000);
			}
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				BatchPushDataForExternalSearch failedTransactionJob = new BatchPushDataForExternalSearch('FailedTransactions', false);
				Database.executeBatch(failedTransactionJob, 50);
			}
			syncSiteMembersToNativeVideoAWS();

		} else if('unsubscribeAudienceMembers'.equalsIgnoreCase(batchType)){
			
			// Call batch to remove group members
			if(SimpplrContext.isNativeVideo){
				removeGroupMembers(deletedCGMemberSet);
			}

			if(String.isNotBlank(subscriptionId)){
				// Delete the Subscription
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Subscription__c> subscriptionList = [SELECT Id FROM Subscription__c WHERE Id = :subscriptionId];
				SIMPESAPI.accessController().deleteAsUser(subscriptionList[0]);
			}
			if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				BatchPushDataForExternalSearch failedTransactionJob = new BatchPushDataForExternalSearch('FailedTransactions', false);
				Database.executeBatch(failedTransactionJob, 50);
			}
		} else if('followMandatorySubscriptions'.equalsIgnoreCase(batchType)){
			syncSiteMembersToNativeVideoAWS();

		} else if('sitesMadePublic'.equalsIgnoreCase(batchType)){
			syncSiteMembersToNativeVideoAWS();

		}
	}

	private void syncSiteMembersToNativeVideoAWS(){
		if(SimpplrContext.isNativeVideo){

			BatchManageVideo job = new BatchManageVideo('syncSiteMembersToNativeVideoAws');
			Database.executeBatch(job, 100);
		}
	}

	private void processPendingAudienceMembership() {
		String packageName = SimpplrContext.packageName;
		String query = 'SELECT Audience__c FROM Audience_Member__c WHERE Is_All_Subscription_Required__c = true AND User__r.IsActive = true ';
		if(String.isNotBlank(packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
			query +=' and User__c IN '+
					' (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
		}
		query += ' LIMIT 1';
		List<Audience_Member__c> audienceMemberList = Database.query(query);
		
		if(!audienceMemberList.isEmpty()) {
			BatchProcessSubscription job = new BatchProcessSubscription('newAudienceMembers', audienceMemberList[0].Audience__c, isUserEmailToBeSwitchedOff, subscriptionId);
			Database.executeBatch(job, 200);

		} else {
			syncSiteMembersToNativeVideoAWS();
		}
	}

	private void createSiteRoles(Map<String, List<Audience_Member__c>> audienceIdListOfAudienceMembersMap, List<Subscription_Entity__c> listOfSubscriptionEntity, Set<Id> peopleIdSet, Set<Id> siteIdSet ){
		List<Site_Role__c> srList = new List<Site_Role__c>();
		Set<String> peopleIdAnddSiteIdSet = new Set<String>();
		Map<String,Site_Role__c> siteIdAndPeopleIdToSiteRoleMap = new Map<String,Site_Role__c>();
		if (!listOfSubscriptionEntity.isEmpty()) {
			Map<String, List<Site_Role__c>> mapOfPeopleSiteRoles = new Map<String,List<Site_Role__c>>();
			for (Site_Role__c sr : [Select id, Subscription__c, Is_Content_Manager__c, is_Member__c, is_Manager__c, people__c, People__r.User__c, site__c from Site_Role__c where people__c IN: peopleIdSet and site__c IN: siteIdSet and Is_Deleted__c= false]){
				if (sr.People__c!=null && sr.Site__c!=null){
					if ( mapOfPeopleSiteRoles.get(sr.Site__c+''+sr.People__c) == null){
						mapOfPeopleSiteRoles.put(sr.Site__c+''+sr.People__c, new List<Site_Role__c>());
					}
					mapOfPeopleSiteRoles.get(sr.Site__c+''+sr.people__c).add(sr);
				}
			}
			for (Subscription_Entity__c subsEntityObj: listOfSubscriptionEntity) {
				if (String.isNotBlank(subsEntityObj.Site__c) && subsEntityObj.subscription__r.Audience__c !=null ){
					if (audienceIdListOfAudienceMembersMap.containskey(subsEntityObj.subscription__r.Audience__c) ){
						for (Audience_Member__c audMemberObj: audienceIdListOfAudienceMembersMap.get(subsEntityObj.subscription__r.Audience__c)) {
							Site_Role__c siteRole = new Site_Role__c();
							if (mapOfPeopleSiteRoles.get(subsEntityObj.site__c+''+audMemberObj.People__c)!=null){
								for(Site_Role__c sr: mapOfPeopleSiteRoles.get(subsEntityObj.site__c+''+audMemberObj.People__c)){
									if( sr.site__c == subsEntityObj.site__c){
										siteRole = sr;
										siteRole.User__c = sr.People__r.User__c;
										if(subsEntityObj.Subscription__r.Membership_Type__c == 'siteMembers'){
											if(sr.Is_Manager__c ==  false && sr.Is_Content_Manager__c ==  false && sr.Is_Member__c == false){ 
												siteRole.is_Member__c = true;
												siteIdAndPeopleIdToSiteRoleMap.put(siteRole.site__c+''+siteRole.people__c,siteRole);
											}
										} else {
											if(sr.Is_Manager__c ==  false && sr.Is_Content_Manager__c ==  false && sr.Is_Member__c == true){ 
												siteRole.is_Member__c = false;
												siteIdAndPeopleIdToSiteRoleMap.put(siteRole.site__c+''+siteRole.people__c,siteRole);
											}
										}
									}	
								}
							} else {
								siteRole.People__c = audMemberObj.People__c;
								siteRole.Site__c = subsEntityObj.site__c;
								siteRole.User__c = audMemberObj.People__r.User__c;
								if(subsEntityObj.Subscription__r.Membership_Type__c == 'siteMembers'){
									siteRole.is_Member__c = true;
								} else {
									siteRole.is_Member__c = false;
								}
								siteRole.Subscription__c = subsEntityObj.Subscription__c;
								siteIdAndPeopleIdToSiteRoleMap.put(siteRole.site__c+''+siteRole.people__c,siteRole);
								
							}
						}
					}
				}
			}
			if (siteIdAndPeopleIdToSiteRoleMap.isEmpty() ==  false){
				List<Site_Role__c> listOfSiteRoleToInsert = new List<Site_Role__c>();
				List<Site_Role__c> listOfSiteRoleToUpdate = new List<Site_Role__c>();
				for(Site_Role__c siteRole : siteIdAndPeopleIdToSiteRoleMap.values()) {
					if(siteRole.Id == null) {
						listOfSiteRoleToInsert.add(siteRole);
					} else {
						listOfSiteRoleToUpdate.add(siteRole);
					}
				}

				if(listOfSiteRoleToUpdate.size() > 0) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id,Site_Role__c>(listOfSiteRoleToUpdate),
						new List<Schema.SObjectField>{Site_Role__c.Is_Member__c, Site_Role__c.User__c});
				}
				if(listOfSiteRoleToInsert.size() > 0) {
					SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().insertAsUser(listOfSiteRoleToInsert,
						new List<Schema.SObjectField>{
							Site_Role__c.People__c,
							Site_Role__c.Site__c,
							Site_Role__c.User__c,
							Site_Role__c.Is_Member__c,
							Site_Role__c.Subscription__c
						});
				}
			}
		}	
	}
}