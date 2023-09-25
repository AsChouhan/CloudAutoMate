public with sharing class SchedulerHourlySimpplrServices extends SimpplrScheduler {

	public override void execute(SchedulableContext SC) {		
		Datetime currentTime = DateTime.now();
    	Datetime currentHourTime = DateTime.newInstance(currentTime.year(),currentTime.month(),currentTime.day(),currentTime.hour(),0,0);
		DateTime lastOneHour = currentTime.addMinutes(-60);
		String queryNewsletter = ' SELECT ' + String.join(NewsletterDataServer.getNewsletterFieldList(),',') + 
				' FROM Mailer__c where Is_Deleted__c=false AND Status__c = \'Scheduled\' AND Scheduled_Date__c=:currentHourTime LIMIT 1';	
		
		String queryAlert  = ' SELECT id ,Is_Deleted__c, Notification_Sent__c,Display_From_DateTime__c, '+
							 'Display_To_DateTime__c FROM alert__c WHERE Display_From_DateTime__c=:currentHourTime AND Notification_Sent__c = false AND Is_Deleted__c= false LIMIT 1 '; 		
								 
							 
		List<Mailer__c> newsletterList = Database.query(queryNewsletter);
		List<Alert__c> alertList = Database.query(queryAlert);
		
		if (!newsletterList.isEmpty()) {	
			BatchNewsletter job = new BatchNewsletter(newsletterList[0], currentHourTime, false, true);
			Database.executeBatch(job,25);
		}
		if(!alertList.isEmpty()){
			BatchAlertNotifications job = new BatchAlertNotifications(alertList[0].id,currentHourTime,true);
			Database.executeBatch(job,500);
		}
		if(SimpplrContext.isNativeVideo == true){
			BatchManageVideo job = new BatchManageVideo('syncFailedSite');
			Database.executeBatch(job,2);
		}
		
		if(SimpplrContext.aiRelatedContentEnabled) {
			String appFeatureQuery = ' SELECT Id, AI_Related_Content_Enabled__c, AI_Related_Content_Active__c From App_Feature__c LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Feature__c> appFeatureList = (List<App_Feature__c>)SIMPESAPI.accessController().queryAsUser(appFeatureQuery, null);
			
			if(!appFeatureList.isEmpty() && appFeatureList[0].AI_Related_Content_Enabled__c == true){
				if(appFeatureList[0].AI_Related_Content_Active__c){
					//Remove expired content from AI server
					removeExpiredContentFromAI();
				} else {
					checkStatusForAIRelatedContent();
				}
			}
		}

		//Update People records with deactivated date from user
		List<People__c> peopleList = [SELECT Id, User_Last_Deactivated__c, User__c, User__r.LastModifiedDate, User__r.isActive FROM People__c WHERE (User__r.isActive = false AND User_Last_Deactivated__c = null) OR (User__r.isActive = true AND User_Last_Deactivated__c != null) WITH SECURITY_ENFORCED];
		if (peopleList.size() > 0) {	
			deactivatedPeopleUpdate(JSON.serialize(peopleList));
		}
        
        if (SimpplrContext.isExternalSearchAppConnected) {
            
            if (Utility.isSmartSearchTokenValid()) {
                if (SimpplrContext.isFlowExternalSearchEnabled) {
                    Database.executebatch(new BatchPushDataForExternalSearch('CollaborationGroupMemberRequest', true),50);
                }
            } else {
                Utility.resetSmartSearch();
            }
        }
		
		BatchUpdatePeopleLicence updatePeopleLicenseJob = new BatchUpdatePeopleLicence('syncLicenseFlagToTrue');
		Database.executeBatch(updatePeopleLicenseJob, 5);

		BatchSyncAudienceMembership audienceSyncJob = new BatchSyncAudienceMembership('editUserAudienceMembership', null);
		Database.executeBatch(audienceSyncJob, 20);
		
		BatchProcessSubscription followMandatorySubscriptionsJob = new BatchProcessSubscription('followMandatorySubscriptions', new Map<String, String>());
		Database.executeBatch(followMandatorySubscriptionsJob, 200);
		List<Must_Read_Audit__c> mrAuditList = [SELECT Id, Content__c FROM Must_Read_Audit__c WHERE Content__r.Is_Published__c=false AND Removed_DateTime__c = null WITH SECURITY_ENFORCED];
		List<String> listOfContentIds = new List<String>();

		if (mrAuditList.isEmpty() == false) {
			removeMustReadForUnpublishedContent();
			
            for (Must_Read_Audit__c mraObj : mrAuditList) {
				listOfContentIds.add(mraObj.Content__c);
			}

			Map<String, Object> mapOfActivityParams = new Map<String, Object>();
			mapOfActivityParams.put('listOfContentIds',listOfContentIds);
			BatchResetMustRead job = new BatchResetMustRead('DeletePendingActionableNotifications',false,mapOfActivityParams);
			Database.executeBatch(job,2000);
		}

		// Send notifications to event author and organizers, whenever there is change in RSVP or new RSVP is created
		if(currentTime.hour() == 17) {
			BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate('sendNotificationOnRSVPActionToAuthorAndOrganizer', null, null);
			Database.executeBatch(job, 10); 

		}

		// Update member and follower count on sites.
		BatchUpdateSiteRecords updateSiteRecords = new BatchUpdateSiteRecords();
		Database.executeBatch(updateSiteRecords, 100);
		

		// Run User Provisioning every 3 hours or run now
		if(Math.mod(currentTime.hour(), 3) == 0 || sc == null){
			
			// Check if Google Integration is enabled 
			if(SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC) != null && 
                SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC).Connected__c){
				// Provisioning is also ON
				String query = 'SELECT Id, Provisioning_Source__c FROM User_Provisioning_Config__c LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<User_Provisioning_Config__c> userProvConfigObj = ((List<User_Provisioning_Config__c>)SIMPESAPI.accessController().queryAsUser(query, null));
				if(userProvConfigObj.isEmpty() == false  
						&& 'Google'.equalsIgnoreCase(userProvConfigObj[0].Provisioning_Source__c)){

					// Call Batch
					BatchGoogleUserProv job = new BatchGoogleUserProv('UserProv');
					Database.executeBatch(job, 1);
				}	
			}
		}
		
		updateSimpplrLicenses();
        generateTimeLine();

		//Process failed cdc records and ensure external sync enabled and initial load completed
		if(SimpplrContext.isExternalDataSyncEnabled && SimpplrContext.isFlowExternalSyncEnabled){
			Database.executeBatch(new BatchPushExternalData(true), 100);
		}
	}

    private void generateTimeLine(){
        DateTime CurrentDateTime = System.now();
        DateTime lastHour = CurrentDateTime.addHours(-1);
       
        List<Simpplr_content__c> listOfSimpplrContent= [SELECT id, Is_Published__c, 
                Publish_Start_DateTime__c, title__c, Is_deleted__c, Site__c, 
                Site__r.Chatter_group_Id__c, Primary_Author__c,  
                (SELECT id, parentId, type FROM feeds WHERE type='link') 
                FROM Simpplr_content__c WHERE (Publish_Start_DateTime__c > :lastHour 
                or createddate >: lastHour) 
                AND Publish_Start_DateTime__c <=:CurrentDateTime AND Is_deleted__c=false WITH SECURITY_ENFORCED limit 1];
        
        if (!listOfSimpplrContent.isEmpty()) {
            BatchGenerateTimeline timeLineBatchObj = new BatchGenerateTimeline();
		    Database.executeBatch(timeLineBatchObj, 20);
        }
    }

	@future 
	private static void updateSimpplrLicenses() {
		if(SimpplrContext.appConfig.Auto_Free_Simpplr_License_Enabled__c) {
			String packageName = SimpplrContext.packageName;
			List<User> inActiveUserList = [select id, name from user where isactive = false and usertype='Standard' 
										and id IN (select userid from UserPackageLicense 
										Where PackageLicense.NamespacePrefix =:packageName) WITH SECURITY_ENFORCED Limit 3000];
			if (inActiveUserList.size () > 0) {		    
				List<UserPackageLicense> uplList = new List<UserPackageLicense> ([select id, PackageLicenseid, Userid 
																				 from UserPackageLicense 
																				 where PackageLicense.NamespacePrefix =:packageName
																				 AND userId IN : inActiveUserList WITH SECURITY_ENFORCED]);
				if (uplList.size () > 0) {
					SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(uplList);
				}
			}
		}
		
		if(SimpplrContext.appConfig.Auto_provisioning_Process_Enabled__c && String.isNotBlank(SimpplrContext.packageName)) {
			String packageName = SimpplrContext.packageName;
			List<PermissionSetAssignment> permissionsetList = [select AssigneeId from PermissionSetAssignment 
																where PermissionSet.name='Simpplr_User' and assignee.isactive=true 
																and PermissionSet.NamespacePrefix=:packageName 
																and assignee.usertype='standard'
																and AssigneeId not in  (select userid from UserPackageLicense 
																where PackageLicense.NamespacePrefix =: packageName) Limit 3000];
			if(permissionsetList.isEmpty() == false) {
				assignSimpplrPackageLicense(permissionsetList);
			}
		}
	}

	private static void assignSimpplrPackageLicense(List<PermissionSetAssignment>  permissionsetList) {
		String packageName = SimpplrContext.packageName;
		List<PackageLicense> listOfPackageLicense = [SELECT Id, AllowedLicenses, UsedLicenses 
													 FROM PackageLicense 
													 WHERE NamespacePrefix = :SimpplrContext.appConfig.Package_Name__c WITH SECURITY_ENFORCED Limit 1];
		List<UserPackageLicense> listOfUserPackageLicense = new List<UserPackageLicense>();
		if(!listOfPackageLicense.isEmpty() && listOfPackageLicense[0].AllowedLicenses > 0){
			if(listOfPackageLicense[0].AllowedLicenses > listOfPackageLicense[0].UsedLicenses){ 
				Integer size = permissionsetList.size();
				if(listOfPackageLicense[0].AllowedLicenses >= listOfPackageLicense[0].UsedLicenses + size){
					for(PermissionSetAssignment psa : permissionsetList){
						UserPackageLicense userpackageLicenseRec = new UserPackageLicense(PackageLicenseId = listOfPackageLicense[0].Id, Userid = psa.AssigneeId);
						listOfUserPackageLicense.add(userpackageLicenseRec);
					}
				} else {
					List<Id> listOfUseridNotAllowed = new List<Id>();
					Integer allowedLicenseCount = listOfPackageLicense[0].AllowedLicenses - listOfPackageLicense[0].UsedLicenses;
					for(Integer i = 0; i < allowedLicenseCount; i++){
						UserPackageLicense userpackageLicenseRec = new UserPackageLicense(PackageLicenseId = listOfPackageLicense[0].Id, Userid = permissionsetList[i].AssigneeId);
						listOfUserPackageLicense.add(userpackageLicenseRec);		
					}														
				}		
				if(!listOfUserPackageLicense.isEmpty()){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().insertAsUser(listOfUserPackageLicense, new List<Schema.SObjectField>{
						UserPackageLicense.PackageLicenseId,
						UserPackageLicense.Userid
					});
				}
			} else{
				List<Id> listOfUserIds = new List<Id>();
				for(PermissionSetAssignment psa : permissionsetList){
					listOfUserIds.add(psa.AssigneeId);
				}
				EmailUtility.sendEmailForUnavailableLicense(listOfPackageLicense[0].AllowedLicenses, listOfUserIds, SimpplrContext.simpplrOrg);		
			}	
		}
	}

	@future 
	@TestVisible
	private static void removeMustReadForUnpublishedContent(){
		List<Must_Read_Audit__c> mrAuditList = [SELECT Id, Removed_By_People__c, Removed_DateTime__c,  Removed_Reason__c FROM Must_Read_Audit__c WHERE Content__r.Is_Published__c=false AND Removed_DateTime__c = null WITH SECURITY_ENFORCED limit 9000];
		for(Must_Read_Audit__c mraObj : mrAuditList){
			mraObj.Removed_By_People__c = UserContext.peopleId;
			mraObj.Removed_DateTime__c = Datetime.now();
			mraObj.Removed_Reason__c = 'Content Unpublished';
		}

		if(!mrAuditList.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Must_Read_Audit__c>(mrAuditList), new List<Schema.SObjectField>{
				Must_Read_Audit__c.Removed_By_People__c,
				Must_Read_Audit__c.Removed_DateTime__c,
				Must_Read_Audit__c.Removed_Reason__c
			});
		}
	}
			
	@future (callout=true)
	@TestVisible
	private static void checkStatusForAIRelatedContent() {
		String CHECK_STATUS_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/content/related-content';
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('org_id', SimpplrContext.simpplrOrgId);
		requestBody.put('action', 'checkStatus');

		List<Logs__c> logList = [SELECT Id, Log_Data__c, Source_Info__c FROM Logs__c Where Source_Info__c = 'AIContentIndexing' WITH SECURITY_ENFORCED Limit 1];
		if(!logList.isEmpty()) {
			requestBody.put('job_id', logList[0].Log_Data__c);
		}

		HttpResponse res = Utility.getResponseFromAWS(CHECK_STATUS_ENDPOINT, requestBody);

		if(res.getStatusCode() != 200) {
			throw new SimpplrException(res.getStatusCode() + ' received, Response Body is ' + res.getBody());
		} else {
			String statusResponse= res.getBody();
			Map<String, Object> statusResponseMap = (Map<String, Object>)JSON.deserializeUntyped(statusResponse);

			if (statusResponseMap != null && statusResponseMap.containsKey('status')) {
				if((String) statusResponseMap.get('status') == 'finished' || (String) statusResponseMap.get('status') == 'gone') {
					String appFeatureQuery = 'SELECT Id, AI_Related_Content_Enabled__c, AI_Related_Content_Active__c From App_Feature__c LIMIT 1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					App_Feature__c appFeatureObj = ((List<App_Feature__c>)SIMPESAPI.accessController().queryAsUser(appFeatureQuery, null))[0];
					
					appFeatureObj.AI_Related_Content_Active__c = true;

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(appFeatureObj, new List<Schema.SObjectField>{
						App_Feature__c.AI_Related_Content_Active__c
					});
				}
			}
		}
	}

	@future (callout=true)
	@TestVisible
	private static void removeExpiredContentFromAI(){   
		String RELATED_CONTENT_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/content/related-content';
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('action', 'removeExpiredContent');
		requestBody.put('version', ServiceConstants.RELATED_CONTENT_API_VERSION);
		HttpResponse httpresponseObj = Utility.getResponseFromAWS(RELATED_CONTENT_ENDPOINT, requestBody);
    }

	@future 
	@TestVisible
	private static void deactivatedPeopleUpdate(String peopleListStr) {
		List<People__c> peopleList = (List<People__c>) JSON.deserialize(peopleListStr, 
				List<People__c>.class);

		List<Schema.SObjectField> fieldToBeAdded = new List<Schema.SObjectField>();
		for(People__c people :peopleList){
			if(people.user__r.isActive){
				people.User_Last_Deactivated__c = null;
				fieldToBeAdded.add(People__c.User_Last_Deactivated__c);
			}else if(people.User_Last_Deactivated__c == null){
				Datetime lastModifiedDT = people.user__r.LastModifiedDate;
				Date lastModifiedDate = date.newinstance(lastModifiedDT.year(), lastModifiedDT.month(), lastModifiedDT.day());
				people.User_Last_Deactivated__c = lastModifiedDate;			
				fieldToBeAdded.add(People__c.User_Last_Deactivated__c);
			}
			people.Last_Edited_DateTime__c =  DateTime.now();
			fieldToBeAdded.add(People__c.Last_Edited_DateTime__c);
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id,People__c>(peopleList), fieldToBeAdded);
	}
}