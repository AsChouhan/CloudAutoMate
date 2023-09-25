public with sharing class SchedulerBatchEmailDigest extends SimpplrScheduler {
	 
    public override void execute(SchedulableContext SC) {    	
    	try{
    		String appConfigQuery = 'select Simpplr_Emails_Allowed__c,Branding_Logo__c, Branding_JSON__c, App_Name__c from App_Config__c limit 1';
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
			if(appConfig != null){
    			logger.logDebug('Inside Execute : appConfig = ' + appConfig);
    			logger.logDebug('Inside Execute : Simpplr_Emails_Allowed__c = ' + appConfig.Simpplr_Emails_Allowed__c);
    			if(appConfig.Simpplr_Emails_Allowed__c){
    				
	    			Integer frequency = 1;
		    		String queryDailyEmailDigest = 'Select Id, People__r.Segment__c, People__r.User__c,People__r.User__r.UserName,User__r.languagelocalekey, People__r.User__r.timezonesidkey, '+
		    										' People__r.Full_Name__c, People__r.Email__c, People__c,People__r.First_Name__c, People__r.Last_Name__c From People_Preference__c '+
		    										' where people__r.User__r.isActive=true and people__r.User__r.UserType=\'Standard\' And '+
		    										' Allow_Simpplr_Emails__c = true and Email_Digest_Frequency__c = \'Daily\'';
		    		if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false){
		    			queryDailyEmailDigest = queryDailyEmailDigest + ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName)';
		    		}
		    		Map<String, NotificationHelper.BrandingInfo> brandingInfoMap = Utility.getSimpplrBrandingMap(appConfig);

		    		if (SimpplrContext.feedMode != 'timeline') {
                        BatchEmailDigest job = new BatchEmailDigest(appConfig, frequency, queryDailyEmailDigest, brandingInfoMap);
                        Database.executeBatch(job,size);
                    }

					if (frequency == 1) {
						Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
						String dayOfWeek = dt.format('EEEE');
						String startOfWeek;
						
						if (SimpplrContext.StartOfWeek != null) {
							startOfWeek = SimpplrContext.StartOfWeek;
						
						} else {
							startOfWeek = 'Monday';
						}
			
						if (dayOfWeek.startsWithIgnoreCase(startOfWeek)) {
							DateTime currentDateTime = DateTime.now();
							List<Simpplr_Content__c> contentList = [SELECT Id FROM Simpplr_Content__c WHERE id IN 
																	(SELECT Content__c FROM Must_Read_Audit__c WHERE 
																	Removed_DateTime__c = null  AND 
																	(Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime)) AND
																	 Is_Published__c = true AND Is_Deleted__c = false WITH SECURITY_ENFORCED limit 1];
							
							if (contentList.size() > 0) {
								BatchMustReadNotifications mustReadBatch = new BatchMustReadNotifications('', 'mustReadsReminderEmail');
								Database.executeBatch(mustReadBatch, 50);
							}
			
						}
						
						List<App_Notification__c> notifiList = sendNotiToAppManagerOn30Days();
						
						if (notifiList != null && notifiList.size() > 0) {
							List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

							fieldList.add(App_Notification__c.GUID__c);
							fieldList.add(App_Notification__c.Is_New__c);
							fieldList.add(App_Notification__c.Is_Read__c);
							fieldList.add(App_Notification__c.Category__c);
							fieldList.add(App_Notification__c.Snippet__c);
							fieldList.add(App_Notification__c.Type__c);
							fieldList.add(App_Notification__c.Sub_Type__c);
							fieldList.add(App_Notification__c.Status__c);
							fieldList.add(App_Notification__c.Sent_To__c);
							fieldList.add(App_Notification__c.Created_DateTime__c);
							
							SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
							SIMPESAPI.accessController().insertAsUser(notifiList, fieldList);
						}
			
					}

					BatchPendingApprovalDigest approvalDigestJob = new BatchPendingApprovalDigest('site_moderation', true);
					Database.executeBatch(approvalDigestJob,100);
    			}
    			if(SimpplrContext.isSegmentsEnabled) {
    				List<People__c> peopleList = [SELECT id, Segment_Attribute_Value__c, Segment__C  FROM People__c
    											WHERE Segment__C=null AND User__r.isActive=true AND 
    											User__r.userType='Standard' WITH SECURITY_ENFORCED];
    				if(peopleList.isEmpty() == false) {
					BatchProcessSegment segmentJob = new BatchProcessSegment('excludedUserSyncNotification', false, null);
					Database.executeBatch(segmentJob, size);
    				}
				}
                
                if(SimpplrContext.isFeatureContentOnboardingEnabled) {
                    Database.executeBatch(new BatchNewHireGraduatedNotification('newHireNotification'), 1000);
                }
    		}  		
    	} catch(Exception ex){
    		logger.logError('Error in Batch Email Digest Scheduler: ', ex);
    	}
    	
    	try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    }

	private list<App_Notification__c> sendNotiToAppManagerOn30Days() {
		String query = 'SELECT id, Type__c, lastModifiedDate FROM App_Default__c WHERE Type__c =\'home-default\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		list<App_Notification__c> notificationList = new list<App_Notification__c>();

		if (!appDefaultList.isEmpty()) {
			Integer daysBetween = system.today().daysBetween(date.valueOf(appDefaultList[0].lastModifiedDate));
			
            if( Test.isRunningTest() || (daysBetween >= 30 && math.mod(daysBetween, 30) == 0) ) {
				set<ID>userIdSet = new set<ID>();
				String currentUserId = UserContext.id;
				List<PermissionSetAssignment> pSetList = [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE 
															PermissionSet.PermissionsModerateChatter = true and Assignee.isActive = true and
															Assignee.userType ='Standard'];
															
				for (PermissionSetAssignment pSetObj: pSetList) {
					userIdSet.add(pSetObj.AssigneeId);
				}

				List<people__c> appPeopleList = [SELECT id FROM people__c WHERE 
												(user__r.profile.PermissionsModerateChatter = true OR user__c =:userIdSet) AND 
												App_Moderation_Permission__c != 'No' AND user__r.isActive = true AND 
												user__r.userType = 'Standard' WITH SECURITY_ENFORCED];
				String guid = currentUserId + '-' + System.currentTimeMillis(); // all user share same guid becuase later on we can process same guid's pending requests
				
                for (people__c pp: appPeopleList) {
					App_Notification__c notificationObj = new App_Notification__c();
					notificationObj.GUID__c = guid;
					notificationObj.Is_New__c = true;
					notificationObj.Is_Read__c = false;
					notificationObj.Category__c = 'Home_Default_Reminder';
					notificationObj.Snippet__c = String.valueOf(daysBetween);
					notificationObj.Type__c = 'Information';
					notificationObj.Sub_Type__c = 'Home Default';
					notificationObj.Status__c = 'Pending';
					notificationObj.Sent_To__c = pp.ID;
					notificationObj.Created_DateTime__c = DateTime.now();

					notificationList.add(notificationObj);
				}

			}

		}

		return notificationList;
	}
}