/**
* @Class [SubscriptionService] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SubscriptionService {

    
    public void deleteSubscription(String subscriptionId) {
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', subscriptionId);

        String queryString = 'SELECT Id, Recipient__c, Audience__c, Status__c, Type__c FROM Subscription__c WHERE Id = :soqlParam1';
        List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

    	if(!subscriptionList.isEmpty()){
    		if('Site'.equalsIgnoreCase(subscriptionList[0].Type__c)) {
    			deleteSubscriptionNotification(subscriptionId);
    		}
			// Delete the Subscription
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(subscriptionList[0]);
    	} else {
    		throw new SimpplrException(ServiceConstants.ERROR_404);
    	}
    }
    
    public void deleteSubscriptionAndUnfollow(String subscriptionId) {
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', subscriptionId);

        String queryString = 'SELECT Id, Recipient__c, Audience__c, Audience__r.Segment__c, Status__c, Type__c FROM Subscription__c WHERE Id = :soqlParam1';
        List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

    	if(!subscriptionList.isEmpty()){
    		if('Site'.equalsIgnoreCase(subscriptionList[0].Type__c)) {
    			deleteSubscriptionNotification(subscriptionId);
    		}

    		String audienceId;
			List<Audience__c> audienceList = null;

			if('everyone'.equalsIgnoreCase(subscriptionList[0].Recipient__c)) {
				audienceList = [select id from Audience__c where name__c='Everyone' AND Is_Deleted__c = false AND Is_Hidden__c = true WITH SECURITY_ENFORCED];
				audienceId = audienceList[0].Id;

			} else if('audience'.equalsIgnoreCase(subscriptionList[0].Recipient__c)) {
				audienceId = subscriptionList[0].Audience__c;
				
			} else if('segment'.equalsIgnoreCase(subscriptionList[0].Recipient__c)) {
				String segmentId = subscriptionList[0].Audience__r.Segment__c;
				audienceList = [SELECT Id FROM Audience__c WHERE Segment__c = :segmentId AND Is_Deleted__c = false 
											AND Has_City_Condition__c = false
											AND Has_Company_Name_Condition__c = false
											AND Has_Country_Condition__c = false
											AND Has_Custom_Field_1_Condition__c = false
											AND Has_Custom_Field_2_Condition__c = false
											AND Has_Custom_Field_3_Condition__c = false
											AND Has_Custom_Field_4_Condition__c = false
											AND Has_Custom_Field_5_Condition__c = false
											AND Has_Custom_Field_6_Condition__c = false
											AND Has_Custom_Field_8_Condition__c = false
											AND Has_Custom_Field_9_Condition__c = false
											AND Has_Custom_Field_10_Condition__c = false
											AND Has_Custom_Field_11_Condition__c = false
											AND Has_Custom_Field_12_Condition__c = false
											AND Has_Custom_Field_13_Condition__c = false
											AND Has_Custom_Field_14_Condition__c = false
											AND Has_Custom_Field_15_Condition__c = false
											AND Has_Custom_Field_16_Condition__c = false
											AND Has_Custom_Field_17_Condition__c = false
											AND Has_Custom_Field_18_Condition__c = false
											AND Has_Custom_Field_19_Condition__c = false
											AND Has_Custom_Field_20_Condition__c = false
											AND Has_Custom_Field_21_Condition__c = false
											AND Has_Custom_Field_22_Condition__c = false
											AND Has_Custom_Field_23_Condition__c = false
											AND Has_Custom_Field_24_Condition__c = false
											AND Has_Custom_Field_25_Condition__c = false
											AND Has_Department_Condition__c = false
											AND Has_Division_Condition__c = false
											AND Has_Joining_Date_Condition__c = false
											AND Has_People_Category_Condition__c = false
											AND Has_State_Condition__c = false
											AND Has_Title_Condition__c = false
											AND Is_Hidden__c = true
											WITH SECURITY_ENFORCED
								];
				
				if(!audienceList.isEmpty()) {
					audienceId = audienceList[0].Id;
				}
			}

			subscriptionList[0].Status__c = 'Deleted';
			SIMPESAPI.accessController().updateAsUser(subscriptionList[0], new List<Schema.SObjectField>{
																	Subscription__c.Status__c
																	});
			
			if(String.isNotBlank(audienceId)) {
				Map<String, String> batchParamMap = new Map<String, String>();
				batchParamMap.put('subscriptionId', subscriptionId);
				batchParamMap.put('audienceId', audienceId);
				
				BatchProcessSubscription batchJob = new BatchProcessSubscription('unsubscribeAudienceMembers', batchParamMap);
				Database.executeBatch(batchJob, 200);
			}
    	} else {
    		throw new SimpplrException(ServiceConstants.ERROR_404);
    	}
    }
    
    /**
    	Method: createSubscription
    	Param Type: SubscriptionWrapper
    	
    	- Insert Audience__c records.
    	- Insert Subscription__c records.
    	- Insert Subscription_Entity__c records.
    **/
    public SubscriptionWrapper createSubscription(SubscriptionWrapper subscriptionWrapper) {
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	

		List<SubscriptionWrapper.SubscriptionSiteItem> subscriptionActionSiteList = subscriptionWrapper.action.listOfSites;
		List<SubscriptionWrapper.SubscriptionPeopleItem> subscriptionActionPeopleList = subscriptionWrapper.action.listOfPeople;
		String membershipType = subscriptionWrapper.membershipType;
		String itemType;
		if(subscriptionActionSiteList !=null && subscriptionActionSiteList.size() > 0) {
			itemType = 'site';
			
		} else if(subscriptionActionPeopleList !=null && subscriptionActionPeopleList.size() > 0) {
			itemType = 'people';
			
		} else {
			throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
		}

		String audienceId = null;
		String segmentId = null;
		String subscriptionRecipient = subscriptionWrapper.recipient;

		List<Audience__c> audienceList;
		if('audience'.equalsIgnoreCase(subscriptionRecipient)) {
			audienceId = subscriptionWrapper.audience.audienceId;

		} else if('segment'.equalsIgnoreCase(subscriptionRecipient)) {
			segmentId = subscriptionWrapper.segment.segmentId;

			audienceList = [SELECT Id FROM Audience__c WHERE Segment__c = :segmentId 
							AND Is_Deleted__c = false 
							AND Is_Hidden__c = true
							AND Has_City_Condition__c = false
							AND Has_Company_Name_Condition__c = false
							AND Has_Country_Condition__c = false
							AND Has_Custom_Field_1_Condition__c = false
							AND Has_Custom_Field_2_Condition__c = false
							AND Has_Custom_Field_3_Condition__c = false
							AND Has_Custom_Field_4_Condition__c = false
							AND Has_Custom_Field_5_Condition__c = false
							AND Has_Custom_Field_6_Condition__c = false
							AND Has_Custom_Field_8_Condition__c = false
							AND Has_Custom_Field_9_Condition__c = false
							AND Has_Custom_Field_10_Condition__c = false
							AND Has_Custom_Field_11_Condition__c = false
							AND Has_Custom_Field_12_Condition__c = false
							AND Has_Custom_Field_13_Condition__c = false
							AND Has_Custom_Field_14_Condition__c = false
							AND Has_Custom_Field_15_Condition__c = false
							AND Has_Custom_Field_16_Condition__c = false
							AND Has_Custom_Field_17_Condition__c = false
							AND Has_Custom_Field_18_Condition__c = false
							AND Has_Custom_Field_19_Condition__c = false
							AND Has_Custom_Field_20_Condition__c = false
							AND Has_Custom_Field_21_Condition__c = false
							AND Has_Custom_Field_22_Condition__c = false
							AND Has_Custom_Field_23_Condition__c = false
							AND Has_Custom_Field_24_Condition__c = false
							AND Has_Custom_Field_25_Condition__c = false							
							AND Has_Department_Condition__c = false
							AND Has_Division_Condition__c = false
							AND Has_Joining_Date_Condition__c = false
							AND Has_People_Category_Condition__c = false
							AND Has_State_Condition__c = false
							AND Has_Title_Condition__c = false
							WITH SECURITY_ENFORCED
						];
			
			if(!audienceList.isEmpty()) {
				audienceId = audienceList[0].Id;
			}
		} else if('everyone'.equalsIgnoreCase(subscriptionRecipient)) {
			audienceList = [select id from Audience__c where name__c='Everyone' AND Is_Deleted__c = false AND Is_Hidden__c = true WITH SECURITY_ENFORCED];
			if(!audienceList.isEmpty()) {
				audienceId = audienceList[0].Id;
			}
		} else {
			throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
		}


		Subscription__c subscriptionObj = new Subscription__c(Audience__c = audienceId,
																Recipient__c = subscriptionRecipient, 
																Type__c = itemType,
																Membership_Type__c = membershipType,
																Modified_By_People__c = UserContext.peopleId,
																Action_Type__c = subscriptionWrapper.action.actionType,
																Created_By_People__c = UserContext.peopleId);
		
		subscriptionObj = (Subscription__c) SIMPESAPI.accessController().insertAsUser(subscriptionObj, new List<Schema.SObjectField>{
																							Subscription__c.Recipient__c,
																							Subscription__c.Audience__c,
																							Subscription__c.Type__c,
																							Subscription__c.Membership_Type__c,
																							Subscription__c.Action_Type__c,
																							Subscription__c.Modified_By_People__c,
																							Subscription__c.Created_By_People__c
																						});
		
		List<Subscription_Entity__c> subscriptionEntityList = new List<Subscription_Entity__c>();
		Subscription_Entity__c subsEntity = null;
		Set<Id> pendingSubscriptionsSiteIdSet = new Set<Id>();
		if('site'.equalsIgnoreCase(itemType)) {
			for(SubscriptionWrapper.SubscriptionSiteItem subscriptionActionSiteObject : subscriptionActionSiteList){
				subsEntity = new Subscription_Entity__c();
				
				subsEntity.Subscription__c = subscriptionObj.id;
				subsEntity.People__c = null;
				subsEntity.Site__c = subscriptionActionSiteObject.item.siteId;
				subsEntity.Status__c = 'approved';
				
				if(!'public'.equalsIgnoreCase(subscriptionActionSiteObject.item.access)){
					subsEntity.Status__c = 'pending';
					pendingSubscriptionsSiteIdSet.add(subsEntity.Site__c);
				}
				
				subscriptionEntityList.add(subsEntity);
			}
		} else if('people'.equalsIgnoreCase(itemType)) {
			for(SubscriptionWrapper.SubscriptionPeopleItem subscriptionActionPeopleObject : subscriptionActionPeopleList){
				subsEntity = new Subscription_Entity__c();
				
				subsEntity.Subscription__c = subscriptionObj.id;
				subsEntity.Site__c = null;
				subsEntity.People__c = subscriptionActionPeopleObject.item.peopleId;
				subsEntity.Status__c = 'approved';
				subscriptionEntityList.add(subsEntity);
			}
		}
		
		if(!subscriptionEntityList.isEmpty()){
			SIMPESAPI.accessController().insertAsUser(subscriptionEntityList, new List<Schema.SObjectField>{
																								Subscription_Entity__c.Subscription__c,
																								Subscription_Entity__c.People__c,
																								Subscription_Entity__c.Site__c,
																								Subscription_Entity__c.Status__c
																								});
		}
		
		// Generate notifications for pending subscriptions of sites
		if(!pendingSubscriptionsSiteIdSet.isEmpty()){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', pendingSubscriptionsSiteIdSet);
			soqlParamMap.put('soqlParam2', subscriptionObj.id);
			
			String queryString = 'SELECT Id, Status__c, Subscription__c, Site__c,'
									+ ' Site__r.Name, Site__r.Chatter_Group_Id__c,'
									+ ' People__c, People__r.User__c, People__r.User__r.languagelocalekey'
									+ ' FROM Subscription_Entity__c'
									+ ' WHERE Site__c = :soqlParam1'
									+ ' AND Subscription__c = :soqlParam2';
		
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Subscription_Entity__c> subscriptionEntityListPending = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

			if(!subscriptionEntityListPending.isEmpty()){
				// Intialize In App Notification labels, if not done yet.
				Set<String> localeSet = new Set<String>();
				for(Subscription_Entity__c seObj : subscriptionEntityListPending){
					localeSet.add(Utility.getSimpplrLanguageLocaleKey(seObj.People__r.User__r.languagelocalekey));
				}
				LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));

				NotificationDispatcher.sendPendingSubscriptionNotification(subscriptionEntityListPending);
				NotificationDispatcher.sendPendingSubscriptionNotificationEmail(subscriptionEntityListPending);
			}
		}		
    	
    	return getSubscriptionById(subscriptionObj.Id);
    }
    
    /**
    	Method: updateSubscription
    	Param Type: SubscriptionWrapper
    	
    	- Update Audience__c records, If any.
    	- Update Subscription__c records, If any.
    	- Update Subscription_Entity__c records, If any.
    **/
    public SubscriptionWrapper updateSubscription(SubscriptionWrapper subscriptionWrapper) {
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);

    	String subscriptionId = subscriptionWrapper.subscriptionId;

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', subscriptionId);

        String queryString = 'SELECT id, Type__c, Modified_By_People__c, Audience__c, Audience__r.Segment__c, Recipient__c FROM Subscription__c WHERE Id = :soqlParam1 LIMIT 1';
        List<Subscription__c> subscriptionObjList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

		if(subscriptionObjList.isEmpty()){
    		throw new SimpplrException(ServiceConstants.ERROR_404);
    	}
		
		Subscription__c subscriptionObj = subscriptionObjList[0];
		
		List<SubscriptionWrapper.SubscriptionSiteItem> subscriptionActionSiteList = subscriptionWrapper.action.listOfSites;
		List<SubscriptionWrapper.SubscriptionPeopleItem> subscriptionActionPeopleList = subscriptionWrapper.action.listOfPeople;
		String membershipType = subscriptionWrapper.membershipType;
		String itemType;
		if(subscriptionActionSiteList !=null && subscriptionActionSiteList.size() > 0) {
			itemType = 'site' ;
			
		} else if(subscriptionActionPeopleList !=null && subscriptionActionPeopleList.size() > 0) {
			itemType = 'people';
			
		} else {
			throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
		}
		
		String audienceId = null;
		String segmentId = null;
		String subscriptionRecipient = subscriptionWrapper.recipient;

		if('audience'.equalsIgnoreCase(subscriptionRecipient)) {
			audienceId = subscriptionWrapper.audience.audienceId;
		} else if('segment'.equalsIgnoreCase(subscriptionRecipient)) {
			segmentId = subscriptionWrapper.segment.segmentId;

			List<Audience__c> audienceList = [SELECT Id FROM Audience__c WHERE Segment__c = :segmentId AND Is_Deleted__c = false 
											AND Has_City_Condition__c = false
											AND Has_Company_Name_Condition__c = false
											AND Has_Country_Condition__c = false
											AND Has_Custom_Field_1_Condition__c = false
											AND Has_Custom_Field_2_Condition__c = false
											AND Has_Custom_Field_3_Condition__c = false
											AND Has_Custom_Field_4_Condition__c = false
											AND Has_Custom_Field_5_Condition__c = false
											AND Has_Custom_Field_6_Condition__c = false
											AND Has_Custom_Field_8_Condition__c = false
											AND Has_Custom_Field_9_Condition__c = false
											AND Has_Custom_Field_10_Condition__c = false
											AND Has_Custom_Field_11_Condition__c = false
											AND Has_Custom_Field_12_Condition__c = false
											AND Has_Custom_Field_13_Condition__c = false
											AND Has_Custom_Field_14_Condition__c = false
											AND Has_Custom_Field_15_Condition__c = false
											AND Has_Custom_Field_16_Condition__c = false
											AND Has_Custom_Field_17_Condition__c = false
											AND Has_Custom_Field_18_Condition__c = false
											AND Has_Custom_Field_19_Condition__c = false
											AND Has_Custom_Field_20_Condition__c = false
											AND Has_Custom_Field_21_Condition__c = false
											AND Has_Custom_Field_22_Condition__c = false
											AND Has_Custom_Field_23_Condition__c = false
											AND Has_Custom_Field_24_Condition__c = false
											AND Has_Custom_Field_25_Condition__c = false											
											AND Has_Department_Condition__c = false
											AND Has_Division_Condition__c = false
											AND Has_Joining_Date_Condition__c = false
											AND Has_People_Category_Condition__c = false
											AND Has_State_Condition__c = false
											AND Has_Title_Condition__c = false
											WITH SECURITY_ENFORCED
								];
			
			if(!audienceList.isEmpty()) {
				audienceId = audienceList[0].Id;
			}
		} else if('everyone'.equalsIgnoreCase(subscriptionRecipient)) {
			List<Audience__c> audienceList = [select id from Audience__c where name__c='Everyone' AND Is_Deleted__c = false AND Is_Hidden__c = true WITH SECURITY_ENFORCED];
			if(!audienceList.isEmpty()) {
				audienceId = audienceList[0].Id;
			}
		}
		 
		// Update Subscription records, If any.
		subscriptionObj.Recipient__c = subscriptionRecipient;
		subscriptionObj.Audience__c = audienceId;
		subscriptionObj.Type__c = itemType;
		subscriptionObj.Modified_By_People__c = UserContext.peopleId;
		subscriptionObj.Action_Type__c = subscriptionWrapper.action.actionType;
		subscriptionObj.Membership_Type__c = membershipType;
		subscriptionObj = (Subscription__c) SIMPESAPI.accessController().updateAsUser(subscriptionObj, new List<Schema.SObjectField>{
																							Subscription__c.Recipient__c,
																							Subscription__c.Audience__c,
																							Subscription__c.Type__c,
																							Subscription__c.Membership_Type__c,
																							Subscription__c.Modified_By_People__c,
																							Subscription__c.Action_Type__c
																							});
		// Update Subscription Entity records, If any.
		List<Subscription_Entity__c> newSubscriptionEntityList = new List<Subscription_Entity__c>();
		List<Subscription_Entity__c> existingSubscriptionEntityList = new List<Subscription_Entity__c>();
		Set<String> existingEntityIdSet = new Set<String>();
		Subscription_Entity__c subsEntity = null;
		/**
			Set containing private/unlisted site ids of the subscriptions those
			are converted to pending or are newly added private/unlisted sites.
		**/ 
		Set<Id> pendingSubscriptionsSiteIdSet = new Set<Id>();
		Set<Id> newlyAddedPrivateUnlistedSiteIdSet = new Set<Id>();
		
		
		if('site'.equalsIgnoreCase(itemType)){
			List<String> siteTypeList = new List<String>{'Private', 'Unlisted'};
			
			Map<String, Object> soqlParamMap2 = new Map<String, Object>();
			soqlParamMap2.put('soqlParam1', subscriptionId);
			soqlParamMap2.put('soqlParam2', siteTypeList);
			
			String queryString2 = 'SELECT Id, Status__c'
						+ ' FROM Subscription_Entity__c'
						+ ' WHERE Subscription__c = :soqlParam1'
						+ ' AND Site__r.Site_Type__c IN :soqlParam2'
						+ ' AND Subscription__r.type__c = \'Site\'';
			
			List<Subscription_Entity__c> subscriptionEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString2, soqlParamMap2);
			
			Map<String, Subscription_Entity__c> subscriptionEntityMap = new Map<String, Subscription_Entity__c>();
			for(Subscription_Entity__c entityObj : subscriptionEntityList) {
				subscriptionEntityMap.put(entityObj.Id, entityObj);
			}

			String subscriptionEntityId = null;													
			for(SubscriptionWrapper.SubscriptionSiteItem subscriptionActionSiteObject : subscriptionActionSiteList){
				subscriptionEntityId = subscriptionActionSiteObject.subscriptionEntityId;
				subsEntity = new Subscription_Entity__c();
				
				subsEntity.Subscription__c = subscriptionObj.id;
				subsEntity.People__c = null;
				subsEntity.Site__c = subscriptionActionSiteObject.item.siteId;
				subsEntity.Status__c = 'approved';
				
				String access = subscriptionActionSiteObject.item.access;
				// Check if the site is private/unlisted, move the status back to 'pending' status
				// For unlisted sites NEW/EXISTING there won't be any access sent from UI so we need to handle it here.  
				if((String.isNotBlank(access) && !'public'.equalsIgnoreCase(access)) ||
						 (String.isBlank(access) && subscriptionEntityMap.containsKey(subscriptionEntityId))){
					subsEntity.Status__c = 'pending';
					
					if(String.isNotBlank(subscriptionEntityId)){
		 				if(!'pending'.equalsIgnoreCase(subscriptionEntityMap.get(subscriptionEntityId).Status__c)){
		 					pendingSubscriptionsSiteIdSet.add(subsEntity.Site__c);
		 				}
					} else {
						newlyAddedPrivateUnlistedSiteIdSet.add(subsEntity.Site__c);
					}
				}
				
				if(String.isBlank(subscriptionEntityId)){
					newSubscriptionEntityList.add(subsEntity);
				} else {
					subsEntity.id = subscriptionEntityId;
					
					existingSubscriptionEntityList.add(subsEntity);
					
					existingEntityIdSet.add(subsEntity.id);
				}
			}
		} else if('people'.equalsIgnoreCase(itemType)){
			for(SubscriptionWrapper.SubscriptionPeopleItem subscriptionActionPeopleObject : subscriptionActionPeopleList){
				subsEntity = new Subscription_Entity__c();
				
				subsEntity.Subscription__c = subscriptionObj.id;
				subsEntity.Site__c = null;
				subsEntity.People__c = subscriptionActionPeopleObject.item.id;
				subsEntity.Status__c = 'approved';
				
				if(String.isBlank(subscriptionActionPeopleObject.subscriptionEntityId)){
					newSubscriptionEntityList.add(subsEntity);
				} else {
					subsEntity.id = subscriptionActionPeopleObject.subscriptionEntityId;
					
					existingSubscriptionEntityList.add(subsEntity);
					
					existingEntityIdSet.add(subsEntity.id);
				}
			}
		}
		
		// WARNING: First remove then do other processing 
		// Remove Subscription Entities, If any
		Map<String, Object> soqlParamMap3 = new Map<String, Object>();
		soqlParamMap3.put('soqlParam1', existingEntityIdSet);
		soqlParamMap3.put('soqlParam2', subscriptionId);
		
		String queryString3 = 'SELECT Id FROM Subscription_Entity__c WHERE Id NOT IN :soqlParam1 AND Subscription__c = :soqlParam2';
		List<Subscription_Entity__c> subscriptionEntityRemoveList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString3, soqlParamMap3);
		
		if(!subscriptionEntityRemoveList.isEmpty()){
			SIMPESAPI.accessController().deleteAsUser(subscriptionEntityRemoveList);
		}								
		
		// Insert new records, If any.
		SIMPSFDCAccessControlResults.InsertResults result = null;
		if(!newSubscriptionEntityList.isEmpty()){
			result = SIMPESAPI.accessController().insertAsUser(newSubscriptionEntityList, new List<Schema.SObjectField>{
																					Subscription_Entity__c.Subscription__c,
																					Subscription_Entity__c.People__c,
																					Subscription_Entity__c.Site__c,
																					Subscription_Entity__c.Status__c});
		}
		// Update existing records, If any.
		if(!existingSubscriptionEntityList.isEmpty()){
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Subscription_Entity__c>(existingSubscriptionEntityList), 
														new List<Schema.SObjectField>{
														Subscription_Entity__c.People__c,
														Subscription_Entity__c.Site__c,
														Subscription_Entity__c.Status__c});
		}
		
		// Add newly added Private/Unlisted sites for notification
		if(result != null){
			List<Subscription_Entity__c> insertedSubscriptionEntityList = (List<Subscription_Entity__c>) result.getInsertedObjects();
			for (Subscription_Entity__c subEntityObj : insertedSubscriptionEntityList){
				if(newlyAddedPrivateUnlistedSiteIdSet.contains(subEntityObj.Site__c)){
					pendingSubscriptionsSiteIdSet.add(subEntityObj.Site__c);
				}
			}
		}							 
		
		// Generate notifications for pending subscriptions of sites
		if(!pendingSubscriptionsSiteIdSet.isEmpty()){
			Map<String, Object> soqlParamMap4 = new Map<String, Object>();
			soqlParamMap4.put('soqlParam1', pendingSubscriptionsSiteIdSet);
			soqlParamMap4.put('soqlParam2', subscriptionObj.id);
			
			String queryString4 = 'Select Id, Status__c, Subscription__c, Site__c,'
									+ ' Site__r.Name, Site__r.Chatter_Group_Id__c,'
									+ ' People__c, People__r.User__c, People__r.User__r.languagelocalekey'
									+ ' FROM Subscription_Entity__c'
									+ ' WHERE Site__c = :soqlParam1'
									+ ' AND Subscription__c = :soqlParam2';
			
			List<Subscription_Entity__c> subscriptionEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString4, soqlParamMap4);
			
			if(!subscriptionEntityList.isEmpty()){
				// Intialize In App Notification labels, if not done yet.
				Set<String> localeSet = new Set<String>();
				for(Subscription_Entity__c seObj : subscriptionEntityList){
					localeSet.add(Utility.getSimpplrLanguageLocaleKey(seObj.People__r.User__r.languagelocalekey));
				}
				LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));

				NotificationDispatcher.sendPendingSubscriptionNotification(subscriptionEntityList);
				NotificationDispatcher.sendPendingSubscriptionNotificationEmail(subscriptionEntityList);
			}
		}
		
		return getSubscriptionById(subscriptionId);    	
    }
 
    public Boolean isSubscriptionLocked(String subscriptionId){
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);

    	Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', subscriptionId);

        String queryString = 'SELECT id, Status__c FROM Subscription__c WHERE id = :soqlParam1';
        List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

    	if(subscriptionList.isEmpty()){
    		throw new SimpplrException(ServiceConstants.ERROR_404);
    	}
    	
    	return ((ServiceConstants.SUBSCRIPTION_STATUS_MAP.get('pending')).equalsIgnoreCase(subscriptionList[0].Status__c));
	}
    
    public SubscriptionWrapper getSubscriptionById(String subscriptionId){
    	List<String> fieldList = new List<String>();
		fieldList.addAll(getSubscriptionFieldList(null));
		fieldList.addAll(getSegmentFieldListBulk());
		fieldList.addAll(getAudienceFieldListBulk());
		
		String fieldsStr = String.join(fieldList, ',');
		
    	Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', subscriptionId);
		
        String queryString = 'SELECT ' + fieldsStr + ' FROM Subscription__c WHERE id = :soqlParam1 AND Status__c != \'Deleted\' ';
		logger.logDebug('SubscriptionService.getSubscriptionById()----queryStr----' + queryString);
        
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);


		if(subscriptionList.isEmpty()) {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		List<SubscriptionWrapper> subscriptionWrapperList = SegmentationWrapperAdapter.convertToSubscriptionWrapper(subscriptionList);
		
		return subscriptionWrapperList[0];
    }
    
    public void deleteSubscriptionNotification(String subscriptionId) {
    	List<App_Notification__c> notificationsList = [Select Id, is_deleted__c 
							FROM App_Notification__c where Object_id__c=:subscriptionId and Type__c='Actionable'
							AND Object_Type__c='Subscription' AND Status__c = 'Pending' and is_deleted__c=false WITH SECURITY_ENFORCED];
		if(!notificationsList.isEmpty()) {
			for(App_Notification__c noti:notificationsList) {
				noti.is_deleted__c = true;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Notification__c>(notificationsList), new List<Schema.SObjectField>{
																				App_Notification__c.is_deleted__c}); 
		}			
					
    }
    
	public List<SubscriptionWrapper> search(Criteria.Subscription subscriptionCriteriaObj){
		List<SubscriptionWrapper> subscriptionWrapperList = new List<SubscriptionWrapper>();
	 	
		String segmentId = subscriptionCriteriaObj.segmentId;
		Boolean excludeSegments = subscriptionCriteriaObj.excludeSegments;
		String siteId = subscriptionCriteriaObj.siteId;
		Integer recordLimit = subscriptionCriteriaObj.size + 1;
		Integer offset = subscriptionCriteriaObj.offset;
		
		List<String> fieldList = new List<String>();
		fieldList.addAll(getSubscriptionFieldList(siteId));
		fieldList.addAll(getSegmentFieldListBulk());
		fieldList.addAll(getAudienceFieldListBulk());
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		
		String fieldsStr = String.join(fieldList, ',');
		String queryString = 'SELECT ' + fieldsStr + ' FROM Subscription__c WHERE Status__c != \'Deleted\' ';

		if(String.isNotBlank(siteId)){
			soqlParamMap.put('soqlParam1', siteId);
			queryString += ' AND Type__c = \'site\' ';
			queryString += ' AND id in (SELECT Subscription__c FROM Subscription_Entity__c WHERE site__c = :soqlParam1 AND isDeleted__c = false) ';
		
		} else if(excludeSegments){
			queryString += ' AND Audience__r.Segment__c = null';
		
		} else if(String.isNotBlank(segmentId)){
			soqlParamMap.put('soqlParam1', segmentId);
			queryString += ' AND Audience__r.Segment__c = :soqlParam1';
		
		} else if(UserContext.isUserAppModerator) {
			//Return All Subscriptions
		
		} else if(UserContext.isSegmentManager) {
			segmentId = UserContext.segmentId;
			soqlParamMap.put('soqlParam1', segmentId);
			queryString += ' AND Audience__r.Segment__c = :soqlParam1';
		
		} else {
			throw new SimpplrException(ServiceConstants.ERROR_403);
		
		}
		
		soqlParamMap.put('soqlParam2', recordLimit);
		soqlParamMap.put('soqlParam3', offset);
		queryString += ' ORDER BY CreatedDate DESC LIMIT :soqlParam2 OFFSET :soqlParam3';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
		
		if(!subscriptionList.isEmpty()){
			subscriptionWrapperList = SegmentationWrapperAdapter.convertToSubscriptionWrapper(subscriptionList);
		}
		
		return subscriptionWrapperList;
	}

	public static List<String> getSegmentFieldListBulk() {
    		return New List<String>{
			'Audience__r.Segment__c',
			'Audience__r.Segment__r.CreatedDate',
			'Audience__r.Segment__r.LastModifiedDate',
			'Audience__r.Segment__r.Id',
			'Audience__r.Segment__r.Name__c',
            'Audience__r.Segment__r.Branding_CSS__c',
            'Audience__r.Segment__r.Branding_CSS_Class__c',
            'Audience__r.Segment__r.Branding_Custom_Font_CSS__c',
            'Audience__r.Segment__r.Branding_JSON__c',
            'Audience__r.Segment__r.Branding_Logo__c',
            'Audience__r.Segment__r.Created_By_People__c',
            'Audience__r.Segment__r.Modified_By_People__c',
			'Audience__r.Segment__r.Created_By_People__r.user__r.Id',
			'Audience__r.Segment__r.Created_By_People__r.First_Name__c', 
			'Audience__r.Segment__r.Created_By_People__r.Community_Nickname__c',
            'Audience__r.Segment__r.Created_By_People__r.Last_Name__c',
            'Audience__r.Segment__r.Created_By_People__r.Full_Name__c',
            'Audience__r.Segment__r.Created_By_People__r.user__r.SmallPhotoURL',
			'Audience__r.Segment__r.Created_By_People__r.Department__c',
			'Audience__r.Segment__r.Created_By_People__r.About__c',
			'Audience__r.Segment__r.Created_By_People__r.Title__c',
			'Audience__r.Segment__r.Created_By_People__r.City__c',
			'Audience__r.Segment__r.Created_By_People__r.State__c',
			'Audience__r.Segment__r.Created_By_People__r.Country__c',
			'Audience__r.Segment__r.Created_By_People__r.Email__c',
			'Audience__r.Segment__r.Created_By_People__r.Phone__c',
			'Audience__r.Segment__r.Created_By_People__r.mobile_phone__c',
			'Audience__r.Segment__r.Created_By_People__r.extension__c',
			'Audience__r.Segment__r.Created_By_People__r.Birth_Date__c',
			'Audience__r.Segment__r.Created_By_People__r.Joining_Date__c',
			'Audience__r.Segment__r.Created_By_People__r.Skype_Id__c',
			'Audience__r.Segment__r.Created_By_People__r.Zoom_Id__c',
			'Audience__r.Segment__r.Created_By_People__r.User__c',
			'Audience__r.Segment__r.Created_By_People__r.User__r.isactive',	
			'Audience__r.Segment__r.Modified_By_People__r.user__r.Id',
			'Audience__r.Segment__r.Modified_By_People__r.First_Name__c', 
			'Audience__r.Segment__r.Modified_By_People__r.Community_Nickname__c',
            'Audience__r.Segment__r.Modified_By_People__r.Last_Name__c',
            'Audience__r.Segment__r.Modified_By_People__r.Full_Name__c',
            'Audience__r.Segment__r.Modified_By_People__r.user__r.SmallPhotoURL',
			'Audience__r.Segment__r.Modified_By_People__r.Department__c',
			'Audience__r.Segment__r.Modified_By_People__r.About__c',
			'Audience__r.Segment__r.Modified_By_People__r.Title__c',
			'Audience__r.Segment__r.Modified_By_People__r.City__c',
			'Audience__r.Segment__r.Modified_By_People__r.State__c',
			'Audience__r.Segment__r.Modified_By_People__r.Country__c',
			'Audience__r.Segment__r.Modified_By_People__r.Email__c',
			'Audience__r.Segment__r.Modified_By_People__r.Phone__c',
			'Audience__r.Segment__r.Modified_By_People__r.mobile_phone__c',
			'Audience__r.Segment__r.Modified_By_People__r.extension__c',
			'Audience__r.Segment__r.Modified_By_People__r.Birth_Date__c',
			'Audience__r.Segment__r.Modified_By_People__r.Joining_Date__c',
			'Audience__r.Segment__r.Modified_By_People__r.Skype_Id__c',
			'Audience__r.Segment__r.Modified_By_People__r.Zoom_Id__c',
			'Audience__r.Segment__r.Modified_By_People__r.User__c',
			'Audience__r.Segment__r.Modified_By_People__r.User__r.isactive'					
        };
    }
    
    public static List<String> getAudienceFieldListBulk() {
    	return New List<String>{
			'Audience__c',
			'Audience__r.Id',
			'Audience__r.Name__c',
			'Audience__r.CreatedDate',
			'Audience__r.LastModifiedDate',
			'Audience__r.Audience_Rule_Json__c',
			'Audience__r.Is_Hidden__c',
			'Audience__r.Is_Deleted__c'
		};
    }

	public static List<String> getSegmentFieldList() {
    		return New List<String>{
			'Id',
			'CreatedDate',
			'LastModifiedDate',
			'Name__c',
            'Branding_CSS__c',
            'Branding_CSS_Class__c',
            'Branding_Custom_Font_CSS__c',
            'Branding_JSON__c',
            'Branding_Logo__c',
            'Created_By_People__c',
            'Modified_By_People__c',
			'Created_By_People__r.user__r.Id',
			'Created_By_People__r.First_Name__c', 
			'Created_By_People__r.Community_Nickname__c',
            'Created_By_People__r.Last_Name__c',
            'Created_By_People__r.Full_Name__c',
            'Created_By_People__r.user__r.SmallPhotoURL',
			'Created_By_People__r.Department__c',
			'Created_By_People__r.About__c',
			'Created_By_People__r.Title__c',
			'Created_By_People__r.City__c',
			'Created_By_People__r.State__c',
			'Created_By_People__r.Country__c',
			'Created_By_People__r.Email__c',
			'Created_By_People__r.Phone__c',
			'Created_By_People__r.mobile_phone__c',
			'Created_By_People__r.extension__c',
			'Created_By_People__r.Birth_Date__c',
			'Created_By_People__r.Joining_Date__c',
			'Created_By_People__r.Skype_Id__c',
			'Created_By_People__r.Zoom_Id__c',
			'Created_By_People__r.User__c',
			'Created_By_People__r.User__r.isactive',	
			'Modified_By_People__r.user__r.Id',
			'Modified_By_People__r.First_Name__c', 
			'Modified_By_People__r.Community_Nickname__c',
            'Modified_By_People__r.Last_Name__c',
            'Modified_By_People__r.Full_Name__c',
            'Modified_By_People__r.user__r.SmallPhotoURL',
			'Modified_By_People__r.Department__c',
			'Modified_By_People__r.About__c',
			'Modified_By_People__r.Title__c',
			'Modified_By_People__r.City__c',
			'Modified_By_People__r.State__c',
			'Modified_By_People__r.Country__c',
			'Modified_By_People__r.Email__c',
			'Modified_By_People__r.Phone__c',
			'Modified_By_People__r.mobile_phone__c',
			'Modified_By_People__r.extension__c',
			'Modified_By_People__r.Birth_Date__c',
			'Modified_By_People__r.Joining_Date__c',
			'Modified_By_People__r.Skype_Id__c',
			'Modified_By_People__r.Zoom_Id__c',
			'Modified_By_People__r.User__c',
			'Modified_By_People__r.User__r.isactive'					
        };
    }
    
	public List<String> getSubscriptionFieldList(String siteId) {
		List<String> fieldList = new List<String>{
			'Id',
			'Status__c',
			'CreatedDate',
			'LastModifiedDate',
			'Recipient__c',
			'Type__c',
			'Action_Type__c',
			'Membership_Type__c',
			'Created_By_People__r.user__r.Id',
			'Created_By_People__r.First_Name__c',
			'Created_By_People__r.Community_Nickname__c',
            'Created_By_People__r.Last_Name__c',
            'Created_By_People__r.Full_Name__c',
            'Created_By_People__r.user__r.SmallPhotoURL',
			'Created_By_People__r.Department__c',
			'Created_By_People__r.About__c',
			'Created_By_People__r.Title__c',
			'Created_By_People__r.City__c',
			'Created_By_People__r.State__c',
			'Created_By_People__r.Country__c',
			'Created_By_People__r.Email__c',
			'Created_By_People__r.Phone__c',
			'Created_By_People__r.mobile_phone__c',
			'Created_By_People__r.extension__c',
			'Created_By_People__r.Birth_Date__c',
			'Created_By_People__r.Joining_Date__c',
			'Created_By_People__r.Skype_Id__c',
			'Created_By_People__r.Zoom_Id__c',
			'Created_By_People__r.User__c',
			'Created_By_People__r.User__r.isactive',	
			'Modified_By_People__r.user__r.Id',
			'Modified_By_People__r.First_Name__c', 
			'Modified_By_People__r.Community_Nickname__c',
            'Modified_By_People__r.Last_Name__c',
            'Modified_By_People__r.Full_Name__c',
            'Modified_By_People__r.user__r.SmallPhotoURL',
			'Modified_By_People__r.Department__c',
			'Modified_By_People__r.About__c',
			'Modified_By_People__r.Title__c',
			'Modified_By_People__r.City__c',
			'Modified_By_People__r.State__c',
			'Modified_By_People__r.Country__c',
			'Modified_By_People__r.Email__c',
			'Modified_By_People__r.Phone__c',
			'Modified_By_People__r.mobile_phone__c',
			'Modified_By_People__r.extension__c',
			'Modified_By_People__r.Birth_Date__c',
			'Modified_By_People__r.Joining_Date__c',
			'Modified_By_People__r.Skype_Id__c',
			'Modified_By_People__r.Zoom_Id__c',
			'Modified_By_People__r.User__c',
			'Modified_By_People__r.User__r.isactive'
    	};
    	
    	List<String> subEntityFieldList = new List<String>{
    		'Id',
    		'People__c',
    		'Site__c',
    		'Processing_Required__c',
    		'Subscription__c',
    		'Action_By__c',
    		'Action_On__c',
    		'Action_Comment__c',
			'Status__c',
			'isDeleted__c'
    	};
    	
    	subEntityFieldList.addAll(getSiteRelationalLiteFieldList());
    	subEntityFieldList.addAll(getPeopleRelationalLiteFieldList());
    	subEntityFieldList.addAll(getActionByRelationalLiteFieldList());
    	
    	String subscriptionEntityQuery = 'SELECT ' + String.join(subEntityFieldList, ',') + ' FROM Subscription_Entities__r';
    	
    	subscriptionEntityQuery += ' ORDER BY Status__c DESC ';
		
    	fieldList.add('(' + subscriptionEntityQuery + ')');
    	
    	return fieldList;
    }
    
    public static List<String> getSiteRelationalLiteFieldList() {
    	return New List<String>{
			'Site__r.Id',
			'Site__r.CreatedDate',
			'Site__r.LastModifiedDate',
			'Site__r.Name',
			'Site__r.Site_Type__c',
			'Site__r.is_Active__c',
			'Site__r.Show_In_Simpplr__c',
			'Site__r.Chatter_Group_Id__c',
			'Site__r.Title_Content_Version__c',
			'Site__r.Landing_Page__c'
		};
    }
    
    public static List<String> getPeopleRelationalLiteFieldList() {
    	return New List<String>{
			'People__r.Id',
			'People__r.CreatedDate',
			'People__r.LastModifiedDate',
			'People__r.User__r.Id',
			'People__r.First_Name__c',
			'People__r.Community_Nickname__c',
            'People__r.Last_Name__c',
            'People__r.Full_Name__c',
            'People__r.User__r.SmallPhotoURL',
			'People__r.Department__c',
			'People__r.About__c',
			'People__r.Title__c',
			'People__r.City__c',
			'People__r.State__c',
			'People__r.Country__c',
			'People__r.Email__c',
			'People__r.Phone__c',
			'People__r.mobile_phone__c',
			'People__r.extension__c',
			'People__r.Birth_Date__c',
			'People__r.Joining_Date__c',
			'People__r.Skype_Id__c',
			'People__r.Zoom_Id__c',
			'People__r.User__c',
			'People__r.User__r.isactive'	
		};
    }
    
    public static List<String> getActionByRelationalLiteFieldList() {
    	return New List<String>{
			'Action_By__r.Id',
			'Action_By__r.CreatedDate',
			'Action_By__r.LastModifiedDate',
			'Action_By__r.User__r.Id',
			'Action_By__r.First_Name__c',
			'Action_By__r.Community_Nickname__c',
            'Action_By__r.Last_Name__c',
            'Action_By__r.Full_Name__c',
            'Action_By__r.User__r.SmallPhotoURL',
			'Action_By__r.Department__c',
			'Action_By__r.About__c',
			'Action_By__r.Title__c',
			'Action_By__r.City__c',
			'Action_By__r.State__c',
			'Action_By__r.Country__c',
			'Action_By__r.Email__c',
			'Action_By__r.Phone__c',
			'Action_By__r.mobile_phone__c',
			'Action_By__r.extension__c',
			'Action_By__r.Birth_Date__c',
			'Action_By__r.Joining_Date__c',
			'Action_By__r.Skype_Id__c',
			'Action_By__r.Zoom_Id__c',
			'Action_By__r.User__c',
			'Action_By__r.User__r.isactive'	
		};
    }
}