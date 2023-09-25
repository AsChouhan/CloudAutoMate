public with sharing class BatchContentAutoGovNotifications implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	private String recordType;
    private Boolean runNextBatchInSequence;
	private String packageName;
	private Exception exceptionDetailsObj;
	private Datetime expiryStartDateTime;
	private Datetime expiry14DaysStartDateTime;
	private Datetime expiry28DaysStartDateTime;
	private Datetime validationExpiring14Days;
	private Datetime validationExpiring28Days;
	private Set<String> newlyExpiredContentSet;
	private Set<String> toBeExpiringContentSet;

	private List<People__c> appManagerList;
	private Map<String, List<Simpplr_Content__c>> mapOfContentsOwnedByPeople;
	private Map<String, Set<String>> mapOfContentIdsOwnedByPeople;

	public Map<Id, String> contentIdWithPublicUrlMap = new Map<Id, String>();
	
	Map<Id, App_Notification__c> mapOfPeopleIdNotifications = new Map<ID, App_Notification__c>();
	Map<Id, Integer>mapPeopleIdTotalCampCount = new Map<Id, Integer>();
	Map<Id, Integer>mapPeopleIdTotalPeopleCount = new Map<Id, Integer>();

	public static final String CONTENT_EXPIRED = 'Content_Expired';
	public static final String CONTENT_FOR_REVIEW = 'Content_For_Review';

	public static final String KEY_REVIEW_REQD_SINGULAR = 'in_app.notification.knowledge.review.required';
	public static final String KEY_PAGE_EXPIRED_SINGULAR = 'in_app.notification.knowledge.expired';
	public static final String KEY_PAGE_EXPIRED_PLURAL = 'in_app.notification.knowledge.expired_plural';

	public BatchContentAutoGovNotifications(String recordType, Boolean runNextBatchInSequence) {
		this.packageName = SimpplrContext.packageName;
		this.recordType = recordType;
        this.runNextBatchInSequence = runNextBatchInSequence;
		String validationPeriodMonth = SimpplrContext.contentValidationPeriod.replace('P', '').replace('M', '');
		this.expiryStartDateTime = DateTime.now().addMonths(- (Integer.valueOf(validationPeriodMonth)));
	}

	public BatchContentAutoGovNotifications(String recordType) {
		this.recordType = recordType;
        this.runNextBatchInSequence = false;
	}
	
	public BatchContentAutoGovNotifications(String recordType, Boolean runNextBatchInSequence, Set<String> newlyExpiredContentSet){
		this.packageName = SimpplrContext.packageName;
		this.recordType = recordType;
        this.runNextBatchInSequence = runNextBatchInSequence;
		this.newlyExpiredContentSet = newlyExpiredContentSet;
		Integer validationPeriodMonth = SimpplrContext.validationPeriodMonth;
		this.expiryStartDateTime = DateTime.now().addMonths(- (validationPeriodMonth));
		this.validationExpiring14Days = DateTime.now().addDays(14);
		this.validationExpiring28Days = DateTime.now().addDays(28);
		this.expiry14DaysStartDateTime = expiryStartDateTime.addDays(14);
		this.expiry28DaysStartDateTime = expiryStartDateTime.addDays(28);
	}
	
    public database.querylocator start(Database.BatchableContext bc){
    	String query = '';
		List<String> peopleIdList;

		if('markContentsAsExpired'.equalsIgnoreCase(recordType)) {
			query =  'SELECT id, Publish_Start_DateTime__c, Publish_End_DateTime__c, Last_Validated_DateTime__c ' +
						' FROM Simpplr_Content__c ' +
						' WHERE Type__c = \'Page\' AND Content_Sub_Type__c = \'knowledge\' ' + 
						' AND Is_Published__c = true AND Is_Deleted__c = false ' +
						' AND ( (Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c < :expiryStartDateTime) OR ' +
						'		(Last_Validated_DateTime__c !=null AND Last_Validated_DateTime__c < :expiryStartDateTime) ' + 
						'     ) ';
    	} else if('sendNotifications'.equalsIgnoreCase(recordType)) {
			toBeExpiringContentSet = new Set<String>();
			mapOfContentsOwnedByPeople = new Map<String, List<Simpplr_Content__c>>();
			mapOfContentIdsOwnedByPeople = new Map<String, Set<String>>();
			appManagerList = new List<People__c>();
			peopleIdList = getAppManagerOrSiteManagers();
			query = ' Select Id, People__c, People__r.Full_Name__c, People__r.First_Name__c, User__c, Email_My_Content_Validation_Required__c, Email_My_Content_Validation_Expired__c, Browser_Content_Validation_Required__c, ' +
					' Allow_Simpplr_Emails__c, Email_Notification_Digest_Frequency__c, People__r.App_Moderation_Permission__c, Allow_Browser_Notifications__c, Browser_Content_Validation_Expired__c, Receive_Content_Moderation_Notifications__c,   ' +
					' People__r.Segment__c, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey, User__r.TimezoneSIDKey ' +
					' From People_Preference__c where User__r.isActive = true And User__r.UserType=\'Standard\' And people__c=:peopleIdList ';

			if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
				query += ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
			}
    	} else if('deleteContentGovActionableNotifications'.equalsIgnoreCase(recordType)) {
    		query = 'SELECT Id, Is_Deleted__c FROM App_Notification__c WHERE Category__c = \'CONTENT_FOR_REVIEW\' AND Is_Deleted__c = false';
    	}

    	return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, sObject[] listOfsObject){
    	try {
            if('markContentsAsExpired'.equalsIgnoreCase(recordType)){
				List<Simpplr_Content__c> listOfContent = (List<Simpplr_Content__c>) listOfsObject;
				markContentsAsExpired(listOfContent);
	    		
			} else if('sendNotifications'.equalsIgnoreCase(recordType)){
				List<People_Preference__c> listOfPeoplePreference = (List<People_Preference__c>) listOfsObject;
				sendNotifications(listOfPeoplePreference);
	    	} else if('deleteContentGovActionableNotifications'.equalsIgnoreCase(recordType)){
	    		List<App_Notification__c> listAppNotifications = (List<App_Notification__c>) listOfsObject;
	    		ManageApplicationDao.deleteContentGovernanceActionableNotifications(listAppNotifications);
			} 
	    }catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }

	private void sendNotifications(List<People_Preference__c> peoplePrefList) {
		Map<Id, List<Simpplr_Content__c>> peopleIdAndContentsMap = new Map<Id, List<Simpplr_Content__c>>();
		Map<Id, Boolean> peopleIdAndWarningMap = new Map<Id, Boolean>();

		Map<String, List<String>> userIdAndManagedGroupMap = getUserIdAndManagedGroupMap(peoplePrefList);
		Map<String, List<Simpplr_Content__c>> mapOfContentsManagedByPeople = getPeopleIdAndManagedContentsMap(peoplePrefList, userIdAndManagedGroupMap);
		
		Map<String, List<Simpplr_Content__c>> authoredExpiredMap = new Map<String, List<Simpplr_Content__c>>();
		Map<String, List<Simpplr_Content__c>> authoredExpiringMap = new Map<String, List<Simpplr_Content__c>>();
		Map<String, List<Simpplr_Content__c>> managedExpiredMap = new Map<String, List<Simpplr_Content__c>>();
		Map<String, List<Simpplr_Content__c>> managedExpiringMap = new Map<String, List<Simpplr_Content__c>>();
		
		List<String> localeList = new List<String>();
		Map<String,String> peopleToUserIdMap = new Map<String,String>();
		// Initialize Locale Context
		
    	//Target User IdSet
    	Set<String> userIdSet = new Set<String>();
    	//List<Messaging.SingleEmailMessage> digestEmailList = new List<Messaging.SingleEmailMessage>();
    	for(People_Preference__c peoplePref: peoplePrefList){
    		userIdSet.add(peoplePref.User__c);
			peopleToUserIdMap.put(peoplePref.people__c, peoplePref.User__c);
			localeList.add(Utility.getSimpplrLanguageLocaleKey(peoplePref.User__r.languagelocalekey));
    	}
    	LocaleContext.getAllLabelMap('EmailNotifications', localeList);
		LocaleContext.getAllLabelMap('InAppNotifications', localeList);
		
		for(People_Preference__c peoplePrefObj : peoplePrefList) {
			List<Simpplr_Content__c> ownedContentsList = mapOfContentsOwnedByPeople.get(peoplePrefObj.People__c);
			
			if(ownedContentsList != null) {
				for(Simpplr_Content__c contentObj : ownedContentsList) {
					List<String> managedGroupList = userIdAndManagedGroupMap.get(peoplePrefObj.User__c);

					List<String> appManagerIdList = new List<String>();
					for(People__c peopleObj : appManagerList) {
						appManagerIdList.add(peopleObj.id);
					}

					if( (appManagerIdList.contains(peoplePrefObj.People__c) && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(contentObj.Site__r.Site_Type__c)) 
							|| managedGroupList.contains(contentObj.Site__r.Chatter_Group_Id__c)) {

						if(newlyExpiredContentSet!= null && newlyExpiredContentSet.contains(contentObj.Id)) {  // authored Expired
							if(!authoredExpiredMap.containsKey(peoplePrefObj.People__c)) {	
								authoredExpiredMap.put(peoplePrefObj.People__c, new List<Simpplr_Content__c>());
							}
							authoredExpiredMap.get(peoplePrefObj.People__c).add(contentObj);
						} else if(toBeExpiringContentSet!= null && toBeExpiringContentSet.contains(contentObj.Id)) {  // authored Expiring
							if(!authoredExpiringMap.containsKey(peoplePrefObj.People__c)) {	
								authoredExpiringMap.put(peoplePrefObj.People__c, new List<Simpplr_Content__c>());
							}
							authoredExpiringMap.get(peoplePrefObj.People__c).add(contentObj);
						}
					}
				}
			}

			List<Simpplr_Content__c> managedContentsList = mapOfContentsManagedByPeople.get(peoplePrefObj.People__c);

			if(managedContentsList != null) {
				for(Simpplr_Content__c contentObj : managedContentsList) {
					if(newlyExpiredContentSet != null && newlyExpiredContentSet.contains(contentObj.Id)) {  // managed Expired
						if(!managedExpiredMap.containsKey(peoplePrefObj.People__c)) {	
							managedExpiredMap.put(peoplePrefObj.People__c, new List<Simpplr_Content__c>());
						}
						managedExpiredMap.get(peoplePrefObj.People__c).add(contentObj);
					} else if(toBeExpiringContentSet != null && toBeExpiringContentSet.contains(contentObj.Id)) {  // managed Expiring
						if(!managedExpiringMap.containsKey(peoplePrefObj.People__c)) {	
							managedExpiringMap.put(peoplePrefObj.People__c, new List<Simpplr_Content__c>());
						}
						managedExpiringMap.get(peoplePrefObj.People__c).add(contentObj);
					}
				}
			}
		}

		if(authoredExpiredMap.size() > 0 || authoredExpiringMap.size() > 0 || managedExpiredMap.size() > 0 || managedExpiringMap.size() > 0) {
			sendInAppNotificationToUsers(peoplePrefList, authoredExpiredMap, authoredExpiringMap, managedExpiredMap, managedExpiringMap);
			if(SimpplrContext.enableEmail && isWeeklyJobRunRequired()) {
				sendEmailToUsers(peoplePrefList, authoredExpiredMap, authoredExpiringMap, managedExpiredMap, managedExpiringMap);
			}
		}

	}

	private Boolean isWeeklyJobRunRequired() {
		Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
		String dayOfWeek = dt.format('EEEE');
		String startOfWeek;
		if (SimpplrContext.StartOfWeek != null) {
			startOfWeek = SimpplrContext.StartOfWeek;
		} else {
			startOfWeek = 'Monday';
		}
		return dayOfWeek.startsWithIgnoreCase(startOfWeek);
	}

	private Map<String, List<Simpplr_Content__c>> getPeopleIdAndManagedContentsMap(List<People_Preference__c> prefList, Map<String, List<String>> userIdAndManagedGroupMap) {
		Map<String, List<Simpplr_Content__c>> mapOfContentsManagedByPeople = new Map<String, List<Simpplr_Content__c>>();

		List<Simpplr_Content__c> contentList = [SELECT Id, Title__c, Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c, Is_Published__c, Type__c, Is_Must_Read__c, 
													Primary_Author__c, Primary_Author__r.Full_Name__c, Display_Excerpt__c, Publish_Start_DateTime__c, Last_Validated_DateTime__c, 
													Last_Edited_DateTime__c, Site__r.Name, Site__r.Landing_Page__c, 
													Site__r.Title_Content_Version__c,
													(SELECT Id,Content_Version__c,Is_Title_Image__c,Title_Image_Type__c, Thumbnail_URL__c 
														FROM File_Simpplr_Content__r 
														WHERE Is_Deleted__c = false AND Is_Title_Image__c=true ORDER BY Title_Image_Type__c)
												FROM Simpplr_Content__c 
												WHERE Type__c='Page' And Content_Sub_Type__c='knowledge'
												AND Is_Deleted__c=false and Site__r.is_Active__c=true And Site__r.Show_In_Simpplr__c=true
												AND (Id = :newlyExpiredContentSet OR Id = :toBeExpiringContentSet)
												AND (
													  (Is_Published__c= true And (Publish_End_DateTime__c = null OR Publish_End_DateTime__c >: validationExpiring14Days)
													  AND (	(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <: expiry14DaysStartDateTime) OR 
															(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <: expiry14DaysStartDateTime)
														  )
													  )
													  OR
													  id=:newlyExpiredContentSet
													)
												AND Id NOT IN (SELECT content__c from Content_Audit_Trail__c 
																WHERE Action__c='Validation Require Dismissed' AND Dismiss_By__c != null AND Action_DateTime__c = LAST_N_DAYS: 14)
											   ];

		for(People_Preference__c prefObj : prefList) {
			List<String> managedGroups = userIdAndManagedGroupMap.get(prefObj.User__c);
			Set<String> ownedContentIds = mapOfContentIdsOwnedByPeople.get(prefObj.People__c);
			for(Simpplr_Content__c contentObj : contentList) {
				if((ownedContentIds == null || ownedContentIds.contains(contentObj.Id) == false) 
						&& (managedGroups!= null && managedGroups.contains(contentObj.Site__r.Chatter_Group_Id__c)
							|| ('Yes'.equalsIgnoreCase(prefObj.People__r.App_Moderation_Permission__c) && (prefObj.Receive_Content_Moderation_Notifications__c == true) && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(contentObj.Site__r.Site_Type__c)))
				) {
					if(!mapOfContentsManagedByPeople.containsKey(prefObj.People__c)) {
						mapOfContentsManagedByPeople.put(prefObj.People__c, new List<Simpplr_Content__c>());
					}
					mapOfContentsManagedByPeople.get(prefObj.People__c).add(contentObj);
				}
			}
		}

		return mapOfContentsManagedByPeople;
	}
	
	private Map<String, List<String>> getUserIdAndManagedGroupMap(List<People_Preference__c> prefList) {
		Map<String, List<String>> userIdAndCollGroupMap= new Map<String, List<String>>();

		List<String> userIdList = new List<String>();
		for(People_Preference__c prefObj : prefList) {
			userIdList.add(prefObj.User__c);
		}

		List<CollaborationGroupMember> cGMList = [SELECT Id, MemberId, CollaborationGroupId FROM CollaborationGroupMember 
													WHERE MemberId = :userIdList
													AND CollaborationRole = 'Admin'];

		List<Site_Role__c> siteRoleList = [SELECT Id, Site__c, Site__r.Chatter_Group_Id__c, People__c, People__r.User__c FROM Site_Role__c 
													WHERE People__r.User__c = :userIdList
													AND Is_Content_Manager__c = true AND Is_Deleted__c = false];

		for(CollaborationGroupMember cGMObj : cGMList) {
			if(!userIdAndCollGroupMap.containsKey(cGMObj.MemberId)) {
				userIdAndCollGroupMap.put(cGMObj.MemberId, new List<String>());
			}
			userIdAndCollGroupMap.get(cGMObj.MemberId).add(cGMObj.CollaborationGroupId);
		}

		for(Site_Role__c siteRoleObj : siteRoleList) {
			if(!userIdAndCollGroupMap.containsKey(siteRoleObj.People__r.User__c)) {
				userIdAndCollGroupMap.put(siteRoleObj.People__r.User__c, new List<String>());
			}
			userIdAndCollGroupMap.get(siteRoleObj.People__r.User__c).add(siteRoleObj.Site__r.Chatter_Group_Id__c);
		}

		return userIdAndCollGroupMap;
	}
    
	public void finish(Database.BatchableContext BC){
    	
    	AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus, ApexClassId from AsyncApexJob where Id = :bc.getJobId()];
		Boolean canStartNextBatch = false;
		Boolean canRerunFailedBatch = false;
		if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
			canStartNextBatch = true;
		} else {
			Utility.sendExceptionEmail('BatchContentAutoGovNotifications.' + recordType, exceptionDetailsObj);
		}
		
    	if('markContentsAsExpired'.equalsIgnoreCase(recordType) && runNextBatchInSequence) {
			BatchContentAutoGovNotifications job = new BatchContentAutoGovNotifications('sendNotifications', runNextBatchInSequence, newlyExpiredContentSet);
			Database.executeBatch(job,100);					
		} else if('sendNotifications'.equalsIgnoreCase(recordType) && runNextBatchInSequence && !Test.isRunningTest()) {
			// Added to execute nigthly jobs sequentially
			SchedulerSimpplrServices.executeNextJob('contentGovernance');
		}
		
    }

	private void markContentsAsExpired(List<Simpplr_Content__c> contentList) {
		List<Content_Audit_trail__c> auditTrailList = new list<Content_Audit_trail__c>();
		newlyExpiredContentSet = new Set<String>();
		for(Simpplr_Content__c contentObj : contentList) {			
			contentObj.Publish_End_DateTime__c = Datetime.now();
			contentObj.Last_Edited_DateTime__c = Datetime.now();

			Content_Audit_trail__c auditObj = new Content_Audit_trail__c();
			auditObj.Content__c = contentObj.Id;
			auditObj.Action__c = 'Validation Expired';
			auditObj.Action_By__c = UserContext.peopleId;
			auditObj.Action_DateTime__c = DateTime.now();
			auditTrailList.add(auditObj);
			newlyExpiredContentSet.add(contentObj.Id);				
		}
		if(contentList.isEmpty() == false){
			update contentList;
		}
		if(auditTrailList.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(auditTrailList, new List<Schema.SObjectField>{
					Content_Audit_trail__c.Content__c,
					Content_Audit_trail__c.Action__c,
					Content_Audit_trail__c.Action_By__c,
					Content_Audit_trail__c.Action_DateTime__c});
		}

		deleteActionableNotifications(contentList);
	}

	private void deleteActionableNotifications(List<Simpplr_Content__c> contentList) {
		List<Id> contentIds = new List<Id>();

		for(Simpplr_Content__c contentObj : contentList) {
			contentIds.add(contentObj.Id);
		}

		List<App_Notification__c> notiList = [SELECT Id, Is_Deleted__c FROM App_Notification__c 
												WHERE Content__c = :contentIds 
													AND Category__c = :CONTENT_FOR_REVIEW 
													AND Type__c = 'Actionable'
													AND Is_Deleted__c = false
													LIMIT 9000];

		if(notiList.isEmpty() == false) {
			for(App_Notification__c notiObj : notiList) {
				notiObj.Is_Deleted__c = true;
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notiList),new List<Schema.SObjectField>{App_Notification__c.Is_Deleted__c});
		}
	}

	private void sendInAppNotificationToUsers(List<People_Preference__c> prefList, 
												Map<String, List<Simpplr_Content__c>> authoredExpiredMap,
												Map<String, List<Simpplr_Content__c>> authoredExpiringMap,
												Map<String, List<Simpplr_Content__c>> managedExpiredMap,
												Map<String, List<Simpplr_Content__c>> managedExpiringMap
											 ) {
		List<App_Notification__c> listOfNewNotifications = new List<App_Notification__c>();
		List<PushNotifcationWrapper> pushNotiListBrowser = new List<PushNotifcationWrapper>();
		Map<String, List<Simpplr_Content__c>> authoredManagedExpiringMap = new Map<String, List<Simpplr_Content__c>>();
		authoredManagedExpiringMap.putAll(authoredExpiringMap);
		authoredManagedExpiringMap.putAll(managedExpiringMap);
		Set<String> contentIdForExpiring = new Set<String>();
		for (String peopleObj: authoredManagedExpiringMap.keyset()){
			List<Simpplr_Content__c> SimpplrList = authoredManagedExpiringMap.get(peopleObj);
			if (!SimpplrList.isEmpty()){
				for (Simpplr_Content__c simpplrContent: SimpplrList){
					contentIdForExpiring.add(simpplrContent.id);
				}
			}
		}

		Datetime last15DaysRecords = DateTime.now().addDays(-15);
		Set<String> contentPeopleIdSetAlreadySentNotification = new Set<String>();
		List<App_Notification__c> appnotificationList = [Select id, Content__c, Sent_to__c, CreatedDate from App_Notification__c where content__c in:contentIdForExpiring and type__c ='Actionable' and Category__c = :CONTENT_FOR_REVIEW and CreatedDate >=: last15DaysRecords ];
		if (!appnotificationList.isEmpty()){
			for (App_Notification__c appNotifications : appnotificationList){
				contentPeopleIdSetAlreadySentNotification.add('' + appNotifications.Content__c + appNotifications.Sent_to__c);
			}
		}
		
		for(People_Preference__c prefObj : prefList) {
			Integer expiredCount = 0;
			Integer expiringCount = 0;
			Boolean expiredContentWebNotiEnabled = 'Yes'.equalsIgnoreCase(prefObj.Allow_Browser_Notifications__c) && prefObj.Browser_Content_Validation_Expired__c ? true : false;
			Boolean expiringContentWebNotiEnabled = 'Yes'.equalsIgnoreCase(prefObj.Allow_Browser_Notifications__c) && prefObj.Browser_Content_Validation_Required__c ? true : false;
			String localeKey = Utility.getSimpplrLanguageLocaleKey(prefObj.User__r.languagelocalekey);

			if(authoredExpiredMap.get(prefObj.People__c) != null && authoredExpiredMap.get(prefObj.People__c).size() > 0) {
				expiredCount += authoredExpiredMap.get(prefObj.People__c).size();
			}
			if(managedExpiredMap.get(prefObj.People__c) != null && managedExpiredMap.get(prefObj.People__c).size() > 0) {
				expiredCount += managedExpiredMap.get(prefObj.People__c).size();
			}
			if(authoredExpiringMap.get(prefObj.People__c) != null && authoredExpiringMap.get(prefObj.People__c).size() > 0) {
				expiringCount += authoredExpiringMap.get(prefObj.People__c).size();
			}
			if(managedExpiringMap.get(prefObj.People__c) != null && managedExpiringMap.get(prefObj.People__c).size() > 0) {
				expiringCount += managedExpiringMap.get(prefObj.People__c).size();
			}
			
			if(expiredCount > 0) {
				App_Notification__c notificationObj1 = new App_Notification__c();

				notificationObj1.Category__c = CONTENT_EXPIRED;
				notificationObj1.Type__c = 'Information';
				notificationObj1.Sub_Type__c = 'Update';
				notificationObj1.Snippet__c = String.valueOf(expiredCount);
				notificationObj1.Sent_to__c = prefObj.People__c;
				notificationObj1.Created_DateTime__c = DateTime.now();
				listOfNewNotifications.add(notificationObj1);

				if(expiredContentWebNotiEnabled) {
					pushNotiListBrowser.add(getBrowserNotificationObj(prefObj, notificationObj1, null, localeKey));					
				}
				
			}

			if(expiringCount > 0) {			

				for (Simpplr_Content__c simpplrContent : authoredManagedExpiringMap.get(prefObj.People__c)){
					if (!contentPeopleIdSetAlreadySentNotification.contains('' + simpplrContent.id + prefObj.People__c)){
						App_Notification__c notificationObj2 = new App_Notification__c();
						notificationObj2.Category__c = CONTENT_FOR_REVIEW;
						notificationObj2.Type__c = 'Actionable';
						notificationObj2.Sub_Type__c = 'Update';
						notificationObj2.Snippet__c = '1';
						notificationObj2.Content__c = simpplrContent.id;
						notificationObj2.Object_Type__c = ServiceConstants.TYPE_PAGE;
						notificationObj2.object_id__c = simpplrContent.id;
						notificationObj2.Simpplr_Site__c = simpplrContent.site__c;
						notificationObj2.Sent_to__c = prefObj.People__c;
						notificationObj2.Created_DateTime__c = DateTime.now();
						listOfNewNotifications.add(notificationObj2);

						if(expiringContentWebNotiEnabled) {
							pushNotiListBrowser.add(getBrowserNotificationObj(prefObj, notificationObj2, simpplrContent, localeKey));
						}

					}
				}
			}
		}

		if(pushNotiListBrowser.size() > 0) {
			try {
				Utility.sendPushNotifications(null, JSON.serialize(pushNotiListBrowser));				
			} catch (Exception ex) {
				
			}
		}

		if(listOfNewNotifications.isEmpty() == false){

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(listOfNewNotifications, new List<Schema.SObjectField>{
					App_Notification__c.Category__c,
					App_Notification__c.Type__c,
					App_Notification__c.Sub_Type__c,
					App_Notification__c.Snippet__c,
					App_Notification__c.Content__c,
					App_Notification__c.Object_Type__c,
					App_Notification__c.object_id__c,
					App_Notification__c.Simpplr_Site__c,
					App_Notification__c.Sent_to__c,
					App_Notification__c.Created_DateTime__c});
		}
    }

	private PushNotifcationWrapper getBrowserNotificationObj(People_Preference__c peoplePrefObj, App_Notification__c appNotiObj,
		Simpplr_Content__c contentObj, String localeKey) {

		PushNotifcationWrapper pushNotiBrowserObj = new PushNotifcationWrapper();

		if(CONTENT_EXPIRED.equalsIgnoreCase(appNotiObj.Category__c)) {
			String key = Integer.valueOf(appNotiObj.Snippet__c) == 1 ? KEY_PAGE_EXPIRED_SINGULAR : KEY_PAGE_EXPIRED_PLURAL;
			pushNotiBrowserObj.notificationtext = LocaleContext.getLabel(localeKey, key)
													.replace('{{count}}', String.valueOf(appNotiObj.Snippet__c));														
			pushNotiBrowserObj.isActionable = false;	
			pushNotiBrowserObj.Url = PageContext.getPageURL(Pages.NotificationRedirectionServer) + '?redirectPageName=ManageContent&status=validationExpired&filter=managing&origin=ian';										
		} else {
			String contentTitle = contentObj.Title__c.length() > 15 ? '"'+contentObj.Title__c.substring(0,15) +'…"' : '"'+contentObj.Title__c+'"';
			pushNotiBrowserObj.notificationText = LocaleContext.getLabel(localeKey, KEY_REVIEW_REQD_SINGULAR)
													.replace('{{contentTitle}}', contentTitle);												
			pushNotiBrowserObj.isActionable = true;	
			pushNotiBrowserObj.siteId = contentObj.site__c;	
			pushNotiBrowserObj.contentId = contentObj.id;
			pushNotiBrowserObj.contentType = contentObj.Type__c;
			pushNotiBrowserObj.Url = PageContext.getPageURL(Pages.NotificationRedirectionServer) + '?redirectPageName=SiteContent&contentId=' + contentObj.id + '&siteId=' + contentObj.site__c + '&type=page&origin=ian';		
		}
		pushNotiBrowserObj.notificationType = 'content';
		pushNotiBrowserObj.title = SimpplrContext.applicationName;
		pushNotiBrowserObj.deviceType = 'browser';
		pushNotiBrowserObj.sentById = UserContext.peopleId;
		pushNotiBrowserObj.isClickable = true;
		pushNotiBrowserObj.sentToId = ((String)peoplePrefObj.people__c).substring(0, 15);

		return pushNotiBrowserObj;
	}

	private List<String> getAppManagerOrSiteManagers() {
		List<String> peopleIdList = new List<String>();
		String query = 'SELECT Id, People__c FROM People_Preference__c WHERE People__r.App_Moderation_Permission__c = \'Yes\' AND ' +
			'Receive_Content_Moderation_Notifications__c = true';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People_Preference__c> peoplePreList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
		for(People_Preference__c peoplePreferenceObj : peoplePreList) {
			People__c peopleObj = new People__c(Id = peoplePreferenceObj.People__c);
			appManagerList.add(peopleObj);
		}					
		for(People__c peopleObj : appManagerList) {
			peopleIdList.add(peopleObj.id);
		}

		List<Simpplr_Content__c> contentList = [select Id, Title__c, Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c, Is_Published__c, Type__c, Is_Must_Read__c, 
													Primary_Author__c, Primary_Author__r.Full_Name__c, Display_Excerpt__c, Publish_Start_DateTime__c, Last_Validated_DateTime__c, 
													Last_Edited_DateTime__c, Site__r.Name, Site__r.Landing_Page__c,
													Site__r.Title_Content_Version__c
												FROM Simpplr_Content__c 
												WHERE Type__c='Page' And Content_Sub_Type__c='knowledge'
												AND Is_Deleted__c=false and Site__r.is_Active__c=true And Site__r.Show_In_Simpplr__c=true
												AND (
														(Is_Published__c= true And (Publish_End_DateTime__c = null OR Publish_End_DateTime__c >: validationExpiring28Days)
														And (	(Last_Validated_DateTime__c = null AND Publish_Start_DateTime__c <: expiry28DaysStartDateTime) OR 
																(Last_Validated_DateTime__c != null AND Last_Validated_DateTime__c <: expiry28DaysStartDateTime)
															)
														)
														OR
														id=:newlyExpiredContentSet
													)
												AND Id NOT IN (SELECT content__c from Content_Audit_Trail__c 
																WHERE Action__c='Validation Require Dismissed' AND Dismiss_By__c != null AND Action_DateTime__c = LAST_N_DAYS: 14)
												];

		List<String> chatterGroupIdList = new List<String>();
		for(Simpplr_Content__c contentObj : contentList) {
			chatterGroupIdList.add(contentObj.site__r.Chatter_Group_Id__c);
			if(!mapOfContentsOwnedByPeople.containsKey(contentObj.Primary_Author__c)) {
				mapOfContentsOwnedByPeople.put(contentObj.Primary_Author__c, new List<Simpplr_Content__c>());
			}
			mapOfContentsOwnedByPeople.get(contentObj.Primary_Author__c).add(contentObj);

			if(!mapOfContentIdsOwnedByPeople.containsKey(contentObj.Primary_Author__c)) {
				mapOfContentIdsOwnedByPeople.put(contentObj.Primary_Author__c, new Set<String>());
			}
			mapOfContentIdsOwnedByPeople.get(contentObj.Primary_Author__c).add(contentObj.Id);
			
			if(contentObj.Is_Published__c) {
				toBeExpiringContentSet.add(contentObj.id);
			}

		}

		List<People__c> siteManagerList = [select Id from People__c where User__r.isActive = true And User__r.UserType='Standard' 
											AND User__c in (select MemberId from CollaborationGroupMember where CollaborationRole='Admin' And CollaborationGroupId=:chatterGroupIdList)];
		for(People__c peopleObj : siteManagerList) {
			peopleIdList.add(peopleObj.id);
		}

		List<Site_Role__c> siteRoleContentManagerList = [select People__c from Site_Role__c where People__r.User__r.isActive = true And People__r.User__r.UserType='Standard' 
											AND Site__r.Chatter_Group_Id__c = :chatterGroupIdList AND Is_Content_Manager__c = true AND Is_Deleted__c = false ];
		for(Site_Role__c siteRoleObj : siteRoleContentManagerList) {
			peopleIdList.add(siteRoleObj.People__c);
		}
		
		return peopleIdList;
	}

	private void sendEmailToUsers(List<People_Preference__c> prefList, 
												Map<String, List<Simpplr_Content__c>> authoredExpiredMap,
												Map<String, List<Simpplr_Content__c>> authoredExpiringMap,
												Map<String, List<Simpplr_Content__c>> managedExpiredMap,
												Map<String, List<Simpplr_Content__c>> managedExpiringMap
											 ) {
		
		String KEY_EMAIL_AUTO_GOV_EXPIRED_SINGLE_INTRO = 'email.notification.knowledge.expired.single.intro';
		String KEY_EMAIL_AUTO_GOV_EXPIRING_SINGLE_INTRO = 'email.notification.knowledge.expiring.single.intro';
		String KEY_EMAIL_AUTO_GOV_EXPIRED_MULTIPLE_INTRO = 'email.notification.knowledge.expired.multiple.intro';
		String KEY_EMAIL_AUTO_GOV_EXPIRING_MULTIPLE_INTRO = 'email.notification.knowledge.expiring.multiple.intro';
		String KEY_EMAIL_AUTO_GOV_EXPIRED_WITH_EXPIRING_INTRO = 'email.notification.knowledge.expired_with_expiring.intro';
		
		List<Messaging.SingleEmailMessage> autoGovEmailList = new List<Messaging.SingleEmailMessage>();

		for(People_Preference__c prefObj : prefList) {
			if(prefObj.Allow_Simpplr_Emails__c && !'none'.equalsIgnoreCase(prefObj.Email_Notification_Digest_Frequency__c)) {
				String localeKey = Utility.getSimpplrLanguageLocaleKey(prefObj.User__r.languagelocalekey);
				
				List<Simpplr_Content__c> authoredExpiredList = new List<Simpplr_Content__c>();
				List<Simpplr_Content__c> authoredExpiringList = new List<Simpplr_Content__c>();
				List<Simpplr_Content__c> managedExpiredList = new List<Simpplr_Content__c>();
				List<Simpplr_Content__c> managedExpiringList = new List<Simpplr_Content__c>();

				if(prefObj.Email_My_Content_Validation_Expired__c && authoredExpiredMap.get(prefObj.People__c) != null) {
					authoredExpiredList = authoredExpiredMap.get(prefObj.People__c);
				}
				if(prefObj.Email_My_Content_Validation_Required__c && authoredExpiringMap.get(prefObj.People__c) != null) {
					authoredExpiringList = authoredExpiringMap.get(prefObj.People__c);
				}
				if(prefObj.Email_My_Content_Validation_Expired__c && managedExpiredMap.get(prefObj.People__c) != null) {
					managedExpiredList = managedExpiredMap.get(prefObj.People__c);
				}
				if(prefObj.Email_My_Content_Validation_Required__c && managedExpiringMap.get(prefObj.People__c) != null) {
					managedExpiringList = managedExpiringMap.get(prefObj.People__c);
				}

				Integer authoredExpiredContentsCount = authoredExpiredList.size();
				Integer managedExpiredContentsCount = managedExpiredList.size();
				Integer authoredExpiringContentsCount = authoredExpiringList.size();
				Integer managedExpiringContentsCount = managedExpiringList.size();

				String emailSubject;
				if((authoredExpiredContentsCount + managedExpiredContentsCount) == 1 && (authoredExpiringContentsCount + managedExpiringContentsCount) == 0) {
					emailSubject = LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRED_SINGLE_INTRO);
				} else if((authoredExpiredContentsCount + managedExpiredContentsCount) > 1 && (authoredExpiringContentsCount + managedExpiringContentsCount) == 0) {
					emailSubject = LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRED_MULTIPLE_INTRO);
				} else if((authoredExpiredContentsCount + managedExpiredContentsCount) == 0 && (authoredExpiringContentsCount + managedExpiringContentsCount) == 1) {
					emailSubject = LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRING_SINGLE_INTRO);
				} else if((authoredExpiredContentsCount + managedExpiredContentsCount) == 0 && (authoredExpiringContentsCount + managedExpiringContentsCount) > 1) {
					emailSubject = LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRING_MULTIPLE_INTRO);
				} else if((authoredExpiredContentsCount + managedExpiredContentsCount) >= 1 && (authoredExpiringContentsCount + managedExpiringContentsCount) >= 1) {
					emailSubject = LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRED_WITH_EXPIRING_INTRO);
				}

				if(String.isNotBlank(emailSubject)) {
					String contentCount = String.valueOf(authoredExpiredContentsCount + managedExpiredContentsCount + authoredExpiringContentsCount + managedExpiringContentsCount);
					emailSubject = emailSubject.replace('{{count}}', contentCount);

					String emailBody = getAutoGovEmailBody(prefObj,
															localeKey,
															emailSubject,
															authoredExpiredList, 
															authoredExpiringList, 
															managedExpiredList, 
															managedExpiringList
														);
					
					if(String.isNotBlank(emailBody)) {
						Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
						singleMail.setTargetObjectId(prefObj.User__c);
						singleMail.setSubject(emailSubject);

						if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
							singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
						}
						if(SimpplrContext.DeeplinkingEnabled) {
							emailBody = EmailUtility.deeplinkedMailBody(emailBody);
						}
						
						singleMail.setHtmlBody(emailBody);
						singleMail.setCharset('UTF-8');
						singleMail.setUseSignature(false);
						singleMail.setSaveAsActivity(false);
						autoGovEmailList.add(singleMail);
					}
				}
			}
		}

		if(autoGovEmailList.size() > 0) {
			List<Messaging.SendEmailResult> results = Messaging.sendEmail(autoGovEmailList);
		}
    }

	private String getAutoGovEmailBody(People_Preference__c peoplePref,
										String localeKey,
										String emailSubject,
										List<Simpplr_Content__c> authoredExpiredContents, 
										List<Simpplr_Content__c> authoredExpiringContents, 
										List<Simpplr_Content__c> managedExpiredContents, 
										List<Simpplr_Content__c> managedExpiringContents
									  ) {
    	String autoGovEmailHtmlBody = '';

		String KEY_EMAIL_HI = 'email.common.salutation';
		String KEY_EMAIL_VIEW_POST_BTN = 'email.common.view_all';

		String KEY_FOOTER_PROMOTION_HEADING = 'email.common.footer.promotion_heading';
		String KEY_FOOTER_PROMOTION_TEXT = 'email.common.footer.promotion_text';
		
		String KEY_EMAIL_AUTO_GOV_AUTHORED_SUB_HEADING = 'email.notification.knowledge.authored.sub_heading';
		String KEY_EMAIL_AUTO_GOV_MANAGED_SUB_HEADING = 'email.notification.knowledge.managed.sub_heading';

		String KEY_EMAIL_AUTO_GOV_VALIDATION_EXPIRED = 'email.notification.knowledge.validation.expired';
		String KEY_EMAIL_AUTO_GOV_VALIDATION_PENDING = 'email.notification.knowledge.validation.pending';

		String KEY_EMAIL_AUTO_GOV_EXPIRED_BLOCK_HEADING = 'email.notification.knowledge.expired.block.heading';
		String KEY_EMAIL_AUTO_GOV_EXPIRED_BLOCK_TEXT = 'email.notification.knowledge.expired.block.text';
		String KEY_EMAIL_AUTO_GOV_EXPIRED_BLOCK_TEXT_PLURAL = 'email.notification.knowledge.expired.block.text_plural';
		String KEY_EMAIL_AUTO_GOV_EXPIRING_BLOCK_HEADING = 'email.notification.knowledge.expiring.block.heading';
		String KEY_EMAIL_AUTO_GOV_EXPIRING_BLOCK_TEXT = 'email.notification.knowledge.expiring.block.text';
		String KEY_EMAIL_AUTO_GOV_EXPIRING_BLOCK_TEXT_PLURAL = 'email.notification.knowledge.expiring.block.text_plural';

		Integer authoredExpiredContentsCount = authoredExpiredContents.size();
		Integer managedExpiredContentsCount = managedExpiredContents.size();
		Integer authoredExpiringContentsCount = authoredExpiringContents.size();
		Integer managedExpiringContentsCount = managedExpiringContents.size();

    	if((authoredExpiredContentsCount + managedExpiredContentsCount + authoredExpiringContentsCount + managedExpiringContentsCount) > 0) {
			NotificationHelper.BrandingInfo brandingInfo = EmailUtility.getBrandingInfo4People(peoplePref.People__r);
	    	Map<String,String> partMap = contentAutoGovPartMap;
	    	
	    	List<String> baseEmailBodyList = new List<String>();
	    	
	    	baseEmailBodyList.add(SimpplrContext.salesforceBaseUrl  + Page.app.getUrl()+'?origin=ge'); // 0
	    	
	    	baseEmailBodyList.add(brandingInfo.logo_url); // 1
							
	    	baseEmailBodyList.add(LocaleContext.getLocalisedDateAsMMMDDYYYY(DateTime.now(), localeKey, peoplePref.User__r.timezonesidkey));
	    	
	    	//{3} userName 
            if(String.isNotBlank(peoplePref.People__r.First_Name__c)) {
				baseEmailBodyList.add(LocaleContext.getLabel(localeKey, 
						KEY_EMAIL_HI).replace('{{firstName}}', peoplePref.People__r.First_Name__c));
            } else {
            	baseEmailBodyList.add(LocaleContext.getLabel(localeKey, 
						KEY_EMAIL_HI).replace('{{firstName}}', peoplePref.People__r.Full_Name__c));
            }
			
			String introText = emailSubject;
			
			baseEmailBodyList.add(introText); 
	    	
			baseEmailBodyList.add(''); // 5
	    	baseEmailBodyList.add(''); // 6
			
			baseEmailBodyList.add(LocaleContext.getLabel(localeKey,EmailConstants.KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
			
			baseEmailBodyList.add('https://www.simpplr.com'); //8
			baseEmailBodyList.add('Simpplr'); //9

			// *************************** Content ROWS START ************************************
			String ownerShipLabelPart = partMap.get('ownerShipLabelRow');
			List<String> ownerShipLabelPartList;

			String authoredExpiredContentRows= '';
			if(authoredExpiredContentsCount > 0) {
				ownerShipLabelPartList = new List<String>();
				ownerShipLabelPartList.add( LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_AUTHORED_SUB_HEADING));
				String authoredExpiredLabelRow = EmailUtility.format(ownerShipLabelPart, ownerShipLabelPartList);
				authoredExpiredContentRows = authoredExpiredLabelRow + getContentRows(peoplePref, authoredExpiredContents, KEY_EMAIL_AUTO_GOV_VALIDATION_EXPIRED, localeKey, brandingInfo);
			}

			String managedExpiredContentRows= '';
			if(managedExpiredContentsCount > 0) {
				ownerShipLabelPartList = new List<String>();
				ownerShipLabelPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_MANAGED_SUB_HEADING));
				String managedExpiredLabelRow = EmailUtility.format(ownerShipLabelPart, ownerShipLabelPartList);
				managedExpiredContentRows = managedExpiredLabelRow + getContentRows(peoplePref, managedExpiredContents, KEY_EMAIL_AUTO_GOV_VALIDATION_EXPIRED, localeKey, brandingInfo);
			}

			String authoredExpiringContentRows= '';
			if(authoredExpiringContentsCount > 0) {
				ownerShipLabelPartList = new List<String>();
				ownerShipLabelPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_AUTHORED_SUB_HEADING));
				String authoredExpiringLabelRow = EmailUtility.format(ownerShipLabelPart, ownerShipLabelPartList);
				authoredExpiringContentRows = authoredExpiringLabelRow + getContentRows(peoplePref, authoredExpiringContents, KEY_EMAIL_AUTO_GOV_VALIDATION_PENDING, localeKey, brandingInfo);
			}

			String managedExpiringContentRows= '';
			if(managedExpiringContentsCount > 0) {
				ownerShipLabelPartList = new List<String>();
				ownerShipLabelPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_MANAGED_SUB_HEADING));
				String managedExpiringLabelRow = EmailUtility.format(ownerShipLabelPart, ownerShipLabelPartList);
				managedExpiringContentRows = managedExpiringLabelRow + getContentRows(peoplePref, managedExpiringContents, KEY_EMAIL_AUTO_GOV_VALIDATION_PENDING, localeKey, brandingInfo);
			}

			// KEY_EMAIL_VIEW_POST_BTN - Expired
			String expiredContentsViewButtonRow = '';
			if(authoredExpiredContentsCount > 0 || managedExpiredContentsCount > 0) {
				String viewPostButtonPart = partMap.get('viewPostButtonRow');
				List<String> viewPostButtonPartList = new List<String>();
				viewPostButtonPartList.add(SimpplrContext.salesforceBaseUrl + Page.PageRedirector.getUrl() + '?userId=' + peoplePref.User__c + '&pageToRedirect=manageContent&status=validationExpired&origin=ge');
				viewPostButtonPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_VIEW_POST_BTN));
				viewPostButtonPartList.add(brandingInfo.general_primaryColor);
				expiredContentsViewButtonRow = EmailUtility.format(viewPostButtonPart, viewPostButtonPartList);
			}


			// KEY_EMAIL_VIEW_POST_BTN - Expiring
			String expiringContentsViewButtonRow = '';
			if(authoredExpiringContentsCount > 0 || managedExpiringContentsCount > 0) {
				// expired button code copied coz 'View Post; button will point to same page(manage content index)
				String viewPostButtonPart = partMap.get('viewPostButtonRow');
				List<String> viewPostButtonPartList = new List<String>();
				viewPostButtonPartList.add(SimpplrContext.salesforceBaseUrl + Page.PageRedirector.getUrl() + '?userId=' + peoplePref.User__c + '&pageToRedirect=manageContent&status=validationRequired&filter=managing&origin=ge');
				viewPostButtonPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_VIEW_POST_BTN));
				viewPostButtonPartList.add(brandingInfo.general_primaryColor);
				expiringContentsViewButtonRow = EmailUtility.format(viewPostButtonPart, viewPostButtonPartList);
			}

			String contentBlockStyle = '';
			String expiredBlockHeading = '';
			String expiringBlockHeading = '';

			if((authoredExpiredContentsCount + managedExpiredContentsCount >= 1) && (authoredExpiringContentsCount + managedExpiringContentsCount == 0)) {
				expiredBlockHeading = partMap.get('horizontalLineRow');
			}
			else if((authoredExpiredContentsCount + managedExpiredContentsCount == 0) && (authoredExpiringContentsCount + managedExpiringContentsCount >= 1)) {
				expiringBlockHeading = partMap.get('horizontalLineRow');
			}
			else if((authoredExpiredContentsCount + managedExpiredContentsCount >= 1) && (authoredExpiringContentsCount + managedExpiringContentsCount >= 1)) {
				contentBlockStyle = '"-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: 1px solid #eeeeee; border-collapse: collapse; border-radius: 5px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 10px 0; text-align: left; vertical-align: top;"';

				// block heading and text - expired
				List<String> expiredContentBlockHeadingRowPartList = new List<String>();
				expiredContentBlockHeadingRowPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRED_BLOCK_HEADING));
				if(authoredExpiredContentsCount + managedExpiredContentsCount == 1) {
					expiredContentBlockHeadingRowPartList.add((LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRED_BLOCK_TEXT)).replace('{{count}}', String.valueOf(authoredExpiredContentsCount + managedExpiredContentsCount)));
				} else {
					expiredContentBlockHeadingRowPartList.add((LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRED_BLOCK_TEXT_PLURAL)).replace('{{count}}', String.valueOf(authoredExpiredContentsCount + managedExpiredContentsCount)));
				}
				expiredBlockHeading = EmailUtility.format(partMap.get('contentBlockHeadingRow'), expiredContentBlockHeadingRowPartList) + partMap.get('horizontalLineRow');

				// block heading and text - expiring
				List<String> expiringContentBlockHeadingRowPartList = new List<String>();
				expiringContentBlockHeadingRowPartList.add(LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRING_BLOCK_HEADING));
				if(authoredExpiringContentsCount + managedExpiringContentsCount == 1) {
					expiringContentBlockHeadingRowPartList.add((LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRING_BLOCK_TEXT)).replace('{{count}}', String.valueOf(authoredExpiringContentsCount + managedExpiringContentsCount)));
				} else {
					expiringContentBlockHeadingRowPartList.add((LocaleContext.getLabel(localeKey, KEY_EMAIL_AUTO_GOV_EXPIRING_BLOCK_TEXT_PLURAL)).replace('{{count}}', String.valueOf(authoredExpiringContentsCount + managedExpiringContentsCount)));
				}
				expiringBlockHeading = EmailUtility.format(partMap.get('contentBlockHeadingRow'), expiringContentBlockHeadingRowPartList) + partMap.get('horizontalLineRow');
			}

			// 10 for content rows.
			String expiredContentBlockRow = '';
			if(authoredExpiredContentsCount + managedExpiredContentsCount >= 1) {
				String expiredContentInnerBlock = expiredBlockHeading + authoredExpiredContentRows + managedExpiredContentRows + expiredContentsViewButtonRow;
				List<String> contentBlockWrapperPartList1 = new List<String>();
				contentBlockWrapperPartList1.add(contentBlockStyle);
				contentBlockWrapperPartList1.add(expiredContentInnerBlock);
				expiredContentBlockRow = EmailUtility.format(partmap.get('contentBlockWrapper'), contentBlockWrapperPartList1);
			}
			baseEmailBodyList.add(expiredContentBlockRow);
			
			// 11
			String expiringContentBlockRow = '';
			if(authoredExpiringContentsCount + managedExpiringContentsCount >= 1) {
				String expiringContentInnerBlock = expiringBlockHeading + authoredExpiringContentRows + managedExpiringContentRows + expiringContentsViewButtonRow;
				List<String> contentBlockWrapperPartList2 = new List<String>();
				contentBlockWrapperPartList2.add(contentBlockStyle);
				contentBlockWrapperPartList2.add(expiringContentInnerBlock);
				expiringContentBlockRow = EmailUtility.format(partmap.get('contentBlockWrapper'), contentBlockWrapperPartList2);
			}
			baseEmailBodyList.add(expiringContentBlockRow);
			// *************************** Content ROWS END ************************************
			
			// 12 - footer mobile promotion			
			baseEmailBodyList.add(EmailUtility.getMobilePromotionFooterDiv(localekey, peoplePref.People__c));

			// 13
			baseEmailBodyList.add('');
			// 14
			baseEmailBodyList.add('');
			// 15
			baseEmailBodyList.add('');
			
			// 16 - Email Setting
	    	baseEmailBodyList.add('' + SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + '?userId=' + peoplePref.User__c +'&pageToRedirect='+Pages.MySettingsEmail+'&origin=ge');
	    	
	    	// header background // 17
			if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
				baseEmailBodyList.add('000000');
			} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
				baseEmailBodyList.add(brandingInfo.general_primaryColor);
			} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
				baseEmailBodyList.add('ffffff');
			} else {
				baseEmailBodyList.add(brandingInfo.header_backgroundColor);
			}

			//18
			baseEmailBodyList.add('');
			
			//19 app name
			baseEmailBodyList.add(LocaleContext.getLabel(localekey, EmailConstants.KEY_FOOTER_SETTINGS).replace('{{appName}}',SimpplrContext.applicationName));
			//20 copyright 
			baseEmailBodyList.add(LocaleContext.getLabel(localekey, EmailConstants.KEY_COPYRIGHT).replace('{{year}}',''+DateTime.now().year()));
			//21 powered by 
			baseEmailBodyList.add(LocaleContext.getLabel(localekey, EmailConstants.KEY_POWERED_BY));

			//22 APPName 
			baseEmailBodyList.add(SimpplrContext.applicationName);
			// 23 mediaCSS
			baseEmailBodyList.add('<style>@media all {    .ExternalClass {      width: 100%;    }    .ExternalClass,    .ExternalClass p,    .ExternalClass span,    .ExternalClass font,    .ExternalClass td,    .ExternalClass div {      line-height: 100%;    }    .apple-link a {      color: inherit !important;      font-family: inherit !important;      font-size: inherit !important;      font-weight: inherit !important;      line-height: inherit !important;      text-decoration: none !important;    }  }@media only screen and (max-width:620px) {    table[class=body] .wrapper,    table[class=body] .header,    table[class=body] .article {      padding: 10px !important;    }    table[class=body] .content {      padding: 0 !important;    }    table[class=body] .container {      padding: 0 !important;      width: 100% !important;    }    table[class=body] .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    table[class=body] .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    table[class=body] .btn a {      width: 100% !important;    }    table[class=body] .img-responsive {      height: auto !important;      max-width: 100% !important;      width: auto !important;    }    td[class="mobile-hide"] {      display: none;    }    .mobile-hide {      display: none;    }    .newsletter-item .media {      width: 100px !important;    }    .newsletter-item .media .Calendar .CalendarMonth {      font-size: 14px !important;    }    .newsletter-item .media .Calendar .CalendarDay {      font-size: 33px !important;    }    .newsletter-item--showCase .media {      width: 100% !important;    }    .newsletter-item--showCase .media .Calendar .CalendarMonth {      font-size: 20px !important;    }    .newsletter-item--showCase .media .Calendar .CalendarDay {      font-size: 40px !important;    }    .wrapper,    .header,    .article {      padding: 10px !important;    }    .content {      padding: 0 !important;    }    .container {      padding: 0 !important;      width: 100% !important;    }    .main {      border-left-width: 0 !important;      border-radius: 0 !important;      border-right-width: 0 !important;    }    .btn table {      width: 100% !important;    }    .btn a {      width: 100% !important;    }    .img-responsive {      height: auto !important;      max-width: 100% !important;      width: auto !important;    }  }    a[x-apple-data-detectors] {        color: inherit !important;        text-decoration: none !important;        font-size: inherit !important;        font-family: inherit !important;        font-weight: inherit !important;        line-height: inherit !important;    }</style>');
			autoGovEmailHtmlBody = EmailUtility.format(partMap.get('BaseEmailBody'), baseEmailBodyList);
    	}
    	return autoGovEmailHtmlBody;
    }

	private String getContentRows(People_Preference__c peoplePref, List<Simpplr_Content__c> contentList, String contentValidationStatusKey, String localeKey, NotificationHelper.BrandingInfo brandingInfo) {
		String contentsHTML = '';
		Map<String,String> partMap = contentAutoGovPartMap;
		
		String viewURL = '';
		String thumbnailTitleImageHTML = '';
		String widescreenTitleImageHTML = ''; 
		
		getcontentIdNPublicUrlMap(contentList);

		String KEY_EMAIL_AUTO_GOV_DATE_PUBLISHED_EDITED = 'email.notification.knowledge.date.published.edited';
		String KEY_EMAIL_AUTO_GOV_DATE_VALIDATION_REQD = 'email.notification.knowledge.date.validation_required';
		
		// *******************Content ROW************************************
	    	Integer index = 0;	
	    	for (Simpplr_Content__c content :contentList) {
				String contentPart = '';
				Boolean isMustReadPage = false;
				if ('Page'.equalsIgnoreCase(content.Type__c)) {
					if (content.Is_Must_Read__c) {
						isMustReadPage  = true;
					}

					if (String.isNotBlank(contentIdWithPublicUrlMap.get(content.id))) {
						contentPart = partMap.get('pageRow');
					} else {
						contentPart = partMap.get('pageWithoutImageRow');
					}
				}

	    		List<String> contentPartList = new List<String>();
				viewURL = ''+SimpplrContext.salesforceBaseUrl   + Page.PageRedirector.getUrl() + '?siteId=' + content.Site__c +'&contentId='+content.id+'&pageToRedirect=ContentDetailPage'+'&origin=ge&contentType='+content.Type__c.tolowercase();

				// 10.0
				contentPartList.add(viewURL);
				
				// 10.1 - Adding title Image 
    			if(String.isNotBlank(contentIdWithPublicUrlMap.get(content.id))) {
		    		contentPartList.add(contentIdWithPublicUrlMap.get(content.id));
				} else {
					contentPartList.add(' ');
				}

				String validationLabelColor = 'FF6A23';
				if(contentValidationStatusKey.containsIgnoreCase('EXPIRED')) {
					validationLabelColor = 'D0021B';
				}

				// 10.2
	    		String localizedContentStatus = LocaleContext.getLabel(localeKey, contentValidationStatusKey).capitalize();
				List<String> contentStatusPartList = new List<String>();
				contentStatusPartList.add(validationLabelColor);
				contentStatusPartList.add(localizedContentStatus);
				String contentStatusRow = EmailUtility.format(partmap.get('ContentStatus'), contentStatusPartList);
				contentPartList.add(contentStatusRow);

				// 10.3  // ============== Content Title row ==============
				String contentTitlePart = partMap.get('contentTitleRow');
				List<String> contentTitlePartList = new List<String>();
				contentTitlePartList.add(viewURL);
	    		contentTitlePartList.add(content.Title__c.length()>100 ? content.Title__c.substring(0,97)+'...' : content.Title__c);
				String contentTitleRow = EmailUtility.format(contentTitlePart, contentTitlePartList);
				contentPartList.add(contentTitleRow);

				// 10.4
				String contentAuthorAndSitePart = partMap.get('contentAuthorAndSiteRow');
				List<String> contentAuthorAndSitePartList = new List<String>();
				contentAuthorAndSitePartList.add(LocaleContext.getLabel(localekey, EmailConstants.KEY_LABEL_BY)+' ');
	    		contentAuthorAndSitePartList.add(content.Primary_Author__r.Full_Name__c + ' ');
				contentAuthorAndSitePartList.add(LocaleContext.getLabel(localekey, EmailConstants.KEY_LABEL_IN)+' ');
	    		contentAuthorAndSitePartList.add(content.Site__r.Name);
				String contentAuthorAndSiteRow = EmailUtility.format(contentAuthorAndSitePart, contentAuthorAndSitePartList);
				contentPartList.add(contentAuthorAndSiteRow);

				// 10.5
				String contentPublishedAndEditedDatePart = partMap.get('contentPublishedAndEditedDateRow');
				String publishedDate = LocaleContext.getLocalisedDateAsDDMMYYYY(content.Publish_Start_DateTime__c, localeKey);
				String editedDate = LocaleContext.getLocalisedDateAsDDMMYYYY(content.Last_Edited_DateTime__c, localeKey);
				String publishedEditedDateText = LocaleContext.getLabel(localekey, KEY_EMAIL_AUTO_GOV_DATE_PUBLISHED_EDITED);
				publishedEditedDateText = publishedEditedDateText.replace('{{publish_date}}', publishedDate).replace('{{edit_date}}', editedDate);
				List<String> contentPublishedAndEditedDatePartList = new List<String>();
	    		contentPublishedAndEditedDatePartList.add(publishedEditedDateText);
				String contentPublishedAndEditedDateRow = EmailUtility.format(contentPublishedAndEditedDatePart, contentPublishedAndEditedDatePartList);
				contentPartList.add(contentPublishedAndEditedDateRow);

				// 10.6
				String contentValidationReqdDatePart = partMap.get('contentValidationReqdDateRow');
				String validationPeriodMonth = SimpplrContext.contentValidationPeriod.replace('P', '').replace('M', '');
				DateTime validationReqdDateTime = (content.Last_Validated_DateTime__c == null) ? content.Publish_Start_DateTime__c : content.Last_Validated_DateTime__c;
				validationReqdDateTime = validationReqdDateTime.addMonths(Integer.valueOf(validationPeriodMonth));
				String validationDate = LocaleContext.getLocalisedDateAsDDMMYYYY(validationReqdDateTime, localeKey);
				String validationReqdDateText = LocaleContext.getLabel(localekey, KEY_EMAIL_AUTO_GOV_DATE_VALIDATION_REQD);
				validationReqdDateText = validationReqdDateText.replace('{{validation_date}}', validationDate);
				List<String> contentValidationReqdDatePartList = new List<String>();
				contentValidationReqdDatePartList.add(validationLabelColor);
				contentValidationReqdDatePartList.add(validationReqdDateText);
				String contentValidationReqdDateRow = EmailUtility.format(contentValidationReqdDatePart, contentValidationReqdDatePartList);
				contentPartList.add(contentValidationReqdDateRow);

	    		contentsHTML += EmailUtility.format(contentPart, contentPartList);
	    		index++;
	    	}

	    // *******************Content Row ends************************************
		return contentsHTML;
	}

	private void getcontentIdNPublicUrlMap(List<Simpplr_Content__c> contentList) {
    	Map<Id, Id> contentIdAndCVIdMap = new Map<Id, Id>();
    	
    	// Widescreen image is required for First content, Thumbnail image for the rest..
    	String desiredImageType = 'Thumbnail';
    	for(Simpplr_Content__c contentObj : contentList) {
    		if(!contentIdWithPublicUrlMap.containsKey(contentObj.Id)){
	    		List<File__c> fileList = contentObj.File_Simpplr_Content__r;
				if(!fileList.isEmpty()) {
					// below 'for' loop will execute max 2 times per iteration
					for(File__c fileObj : fileList) {
						if(fileObj.Is_Title_Image__c){
							if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(contentObj.Type__c)){
								if(String.isNotBlank(fileObj.Content_Version__c)) {
									contentIdAndCVIdMap.put(contentObj.Id, fileObj.Content_Version__c);
								} else {
									contentIdWithPublicUrlMap.put(contentObj.id, fileObj.Thumbnail_URL__c);
								}
								break;
							} else if(desiredImageType.equalsIgnoreCase(fileObj.Title_Image_Type__c)) {
								contentIdAndCVIdMap.put(contentObj.Id, fileObj.Content_Version__c);
								break;
							}
						}
					}
				} else {
					Simpplr_Site__c siteObj = contentObj.Site__r;
					if(siteObj != null && String.isNotBlank(siteObj.Title_Content_Version__c) && contentObj.Type__c != 'Event') {
						contentIdAndCVIdMap.put(contentObj.Id, siteObj.Title_Content_Version__c);
					}
				}
    		
    			desiredImageType = 'Thumbnail';
    		}
    	}
    	Map<Id, String> cvIdNPublicUrlMap;
    	if(contentIdAndCVIdMap.size()>0){
    		cvIdNPublicUrlMap = FileContentProvider.generateEmbedPublicUrl(contentIdAndCVIdMap.values());
    	
	    	for(Id contentId : contentIdAndCVIdMap.keySet()){
	    		contentIdWithPublicUrlMap.put(contentId,cvIdNPublicUrlMap.get( contentIdAndCVIdMap.get(contentId)));
	    	}
    	}
    }

	public static Map<String,String> contentAutoGovPartMap = new Map<String,String>{
		'BaseEmailBody' =>'<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">{23}<title>Simpplr Email Digest</title></head><body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"><div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"><table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{17}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"></td><td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"><span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span></td></tr></tbody></table></td></tr><tr><td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><h2 style="color: #000000; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-weight: 400; line-height: 1.4; margin: 0; margin-bottom: 15px;">{3},<br>{4}</h2></td></tr>{5}{10}{11}</tbody></table></td></tr></tbody></table>{12}<div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"><a href="{16}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{19}.</a><br>{20}</td></tr><tr><td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {21} <a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">{9}</a>. </td></tr></tbody></table></div></div></td></tr></tbody></table></body></html>',
		//'BaseEmailBody' => '<html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">{23}<title>Simpplr Email Digest</title></head><body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"><div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"><table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{17}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"></td><td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"><span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span></td></tr></tbody></table></td></tr><tr><td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><h2 style="color: #000000; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-weight: 400; line-height: 1.4; margin: 0; margin-bottom: 15px;">{3},<br>{4}</h2></td></tr><tr><td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: left; vertical-align: top;"><table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="Post" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: 1px solid #eeeeee; border-collapse: collapse; border-radius: 5px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px 10px 0; text-align: left; vertical-align: top;"><table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody>{5}{10} </tbody></table></td></tr></tbody></table></td></tr></tbody></table></td></tr></tbody></table><div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"><a href="{16}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{19}.</a><br>{20}</td></tr><tr><td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {21} <a href="{8}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">{9}</a>. </td></tr></tbody></table></div></div></td></tr></tbody></table></body></html>',
		/*{0} LogoLink*/
		/*{1} LogoImage*/  
		/*{2} EmailDate*/
		/*{3} UserName*/
		/*{4} AppName*/
		/*{5} UserName link to HomeMyDashboard page*/
		/*{6} EMAIL User Name*/
		/*{7} Copywrite*/
		/*{8} App Link*/
		/*{9} App Name*/
		/*{10} ContentRow*/
			/*{0} CONTENT LINK*/
			/*{1} Widescreen Title Image */  'WidescreenTitleImage' => '<tr><td valign="top" style="padding-bottom: 12px"><div style="max-height: 320px; max-width: 570px; overflow: hidden; width: 100%; text-align: center;"><a href="{0}"><img width="570" src="{1}" alt="" style="border: none; height: auto; max-width: 100%; width: auto"></a></div></td></tr>',
			/*{2} Validation Status*/ 'ContentStatus' =>'<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><span class="type--stamp" style="color: #adadad; display: block; font-family: \'Helvetica Neue\', Helvetica, Arial, sans-serif; font-size: 9px; font-weight: 500; letter-spacing: 0.075em; line-height: 20px; text-transform: uppercase;"><span class="type--danger" style="color: #{0};">{1}</span></span></td></tr>',
			/*{3} Title*/ 'contentTitleRow' => '<tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 8px; text-align: left; vertical-align: top;"> <a href="{0}" class="newsletter-item-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #333; font-size: 16px; font-weight: 500; text-decoration: none; word-break: break-word;"> {1}</a> </td> </tr>',
			/*{4} By {{author}} in {{Site}} */ 'contentAuthorAndSiteRow' => '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 12px; line-height: 21px; margin: 0;">{0}{1}{2}{3}</p></td></tr>',
			/*{5} Published {{date}} (edited {{date}}) */ 'contentPublishedAndEditedDateRow' => '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999; font-size: 12px; line-height: 21px; margin: 0;">{0}</p></td></tr>',
			/*{6} Validation required {{date}} */ 'contentValidationReqdDateRow' => '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-item-meta color-danger" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #{0}; font-size: 12px; line-height: 21px; margin: 0;">{1}</p></td></tr>',
			
		/*{11} Email Setting page link	
		/*{12} header backgroundcolor*/
		/*{13} footer backgroundcolor*/
		/*{14} header text color Applicable for date only.*/
		/*{15} footer text color Applicable for footer text only*/
		/*{16} footer color Applicable for all links/buttons in header and footer.*/
		/*{17} CSS media rule*/
		/*{18} Frequency */
		/*{19} app name*/
		/*{20} copyright*/
		/*{21} powered by */
		/*{22} appname*/
		/*{23} media css */
		'contentBlockWrapper' => '<tr><td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: left; vertical-align: top;"><table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td class="Post" style={0}><table style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody>{1}</tbody></table></td></tr></tbody></table></td></tr>',
		'contentBlockHeadingRow' => '<tr><td class="newsletter-item-box" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><h3 class="alert-heading" style="color: #444; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 16px; font-weight: bold; line-height: 1.4; margin: 0 0 10px; margin-bottom: 15px;">{0}</h3><p class="alert-text" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #444; font-size: 16px; margin: 0 0 17px;">{1}</p></td></tr></tbody></table></td></tr>',
		'pageWithoutImageRow' => '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{0}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img alt="alt" height="125" src="'+ EmailConstants.knowledgePageDefaultIconSquareIcon + '" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125"> </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody> {2} {3} {4} {5} {6} </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td></tr>',
		'pageRow' =>             '<tr> <td class="newsletter-item" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 30px; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td bgcolor="#FFFFFF" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; text-align: left; vertical-align: top;" valign="top"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" width="100%" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tbody> <tr> <td align="left" class="mobile-hide" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0 16px 0 0; text-align: left; vertical-align: top;" valign="top" width="125"> <a href="{0}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border: none; display: block; max-height: 125px; max-width: 125px; overflow: hidden; text-decoration: none;"> <table align="center" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #ffffff; border-collapse: separate; margin: 0; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 0; width: 100%;" width="125"> <tbody> <tr> <td align="center" height="125" valign="middle" width="125" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="125" src="{1}" style="-ms-interpolation-mode: bicubic; border: none; display: block; height: auto; max-width: 100%; outline: none; text-decoration: none;" width="125">                                                     </td> </tr> </tbody> </table> </a> </td> <td valign="top" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <table border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; color: #333333; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;" width="100%"> <tbody> {2} {3} {4} {5} {6} </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td> </tr> </tbody> </table> </td></tr>',
		'ownerShipLabelRow' => '<tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><p class="newsletter-list-heading" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #000000; font-size: 13px; font-weight: 500; line-height: 16px; margin: 0 0 15px; opacity: 0.3; padding: 0;"> {0}</p></td></tr>',
		'viewPostButtonRow' => '<tr><td class="btn-container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"><center><table role="presentation" border="0" cellpadding="0" cellspacing="0" class="btn btn-primary" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; box-sizing: border-box; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px !important;"><tbody><tr><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td><td align="center" class="btn-spacer" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 15px; padding-top: 15px; text-align: left; vertical-align: top; width: 120px;"><table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 120px;"><tbody><tr><td class="btn-inner" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{2}; border-collapse: collapse; border-radius: 4px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top; width: 120px;"><a href="{0}" target="_blank" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{2}; border: solid 1px #{2}; border-color: #{2}; border-radius: 5px; box-sizing: border-box; color: #ffffff; cursor: pointer; display: inline-block; font-size: 14px; font-weight: normal; margin: 0; padding: 5px 15px; text-decoration: none; text-transform: capitalize; width: 120px;">{1}</a></td></tr></tbody></table></td><td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;">&nbsp;</td></tr></tbody></table></center></td></tr>',
		'horizontalLineRow' => '<tr><td height="15" class="newsletter-divider-line" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; border-top: 1px solid #e5e5e5; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"></td></tr>'
	};
}