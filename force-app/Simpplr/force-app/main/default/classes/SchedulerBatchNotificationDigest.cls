public with sharing class SchedulerBatchNotificationDigest extends SimpplrScheduler {
    
    public override void execute(SchedulableContext SC) {    	
    	try{
    		String appConfigQuery = 'select Simpplr_Emails_Allowed__c,Branding_Logo__c, Branding_JSON__c, App_Name__c from App_Config__c limit 1';
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
			
			logger.logDebug('Inside Execute : appConfig = ' + appConfig);
    		if(appConfig != null){

				Datetime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
				String dayOfWeek = dt.format('EEEE');
				String startOfWeek;

				if (SimpplrContext.StartOfWeek != null) {
					startOfWeek = SimpplrContext.StartOfWeek;
				
				} else {
					startOfWeek = 'Monday';
				}

				if (dayOfWeek.startsWithIgnoreCase(startOfWeek) && SimpplrContext.isNativeVideo == true && SimpplrContext.isVideosManagementFeatureEnabled == true) {
					VideoDataService videoService = new VideoDataService();
					if(videoService.getVideoStorage() == true) {
						BatchVideoNotifications videoNotificationBatch = new BatchVideoNotifications('sendNotification');
						Database.executeBatch(videoNotificationBatch, 100);
					}
				}
				
    			logger.logDebug('Inside Execute : appConfig.Simpplr_Emails_Allowed__c = ' + appConfig.Simpplr_Emails_Allowed__c);
    			if(appConfig.Simpplr_Emails_Allowed__c){
	    			Integer frequency = 1;
		    		String queryNotificationDigest = 'Select Id, People__r.User__c,People__r.User__r.UserName, People__r.User__r.timezonesidkey, People__r.User__r.languagelocalekey, '+
		    										' Email_Follows_Me__c, Email_Endorses_Me__c, Email_PrivateSiteMembership_Response__c, Email_Content_Submission_Response__c, '+
		    										' Email_My_Content_Post__c, Email_Like_My_Post_Or_Comment__c, Email_Comments_After_Me__c, Email_Comments_On_Post_I_Like__c, '+
													' Email_Comments_On_My_Post__c, Email_Posts_To_Me__c, Email_Shares_My_Post__c, Email_My_Content_Like_Or_Share__c,Email_Content_Useful__c, Email_Updates_Content_Sites_I_Follow__c, Email_Event_Invite_More__c,'+
													' Email_QnA_Question_Mention__c, Email_QnA_Answer_Mention__c, Email_QnA_Answer_Vote__c, Email_QnA_Answer_Approval__c, Email_QnA_New_Answer__c, Email_QnA_New_Answer_Approval__c, Email_QnA_New_Content_Answer__c, Email_QnA_New_Content_Question__c, Email_QnA_Duplicate_Question__c, Email_QnA_New_Question__c, ' +
													' People__r.Segment__c, People__r.Segment__r.Branding_Logo__c, People__r.Segment__r.Branding_JSON__c, ' +
		    										' People__r.Full_Name__c, People__r.Email__c, People__c,People__r.First_Name__c, People__r.Last_Name__c From People_Preference__c '+
		    										' where people__r.User__r.isActive=true and people__r.User__r.UserType=\'Standard\' And '+
		    										' Allow_Simpplr_Emails__c = true and Email_Notification_Digest_Frequency__c = \'Daily\'';
		    		if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false){
		    			queryNotificationDigest = queryNotificationDigest + ' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName)';
		    		}
		    		String brandingJsonString = appConfig.Branding_JSON__c;
					NotificationHelper.BrandingInfo brandingInfo = Utility.getBrandingInfoJson(brandingJsonString, appConfig.Branding_Logo__c);
		    		
		    		String simpplrDefaultLogoUrl = '';
		    		if(String.isBlank(appConfig.Branding_Logo__c)){
		    			simpplrDefaultLogoUrl = EmailTemplateService.simpplrDefaultLogoUrl;
		    		}
		    		
		    		BatchNotificationDigest job = new BatchNotificationDigest(appConfig, frequency, queryNotificationDigest, brandingInfo, simpplrDefaultLogoUrl);
					Database.executeBatch(job,size);
    			}
    		}  		
    	}catch(Exception ex){
    		logger.logError('Error in Batch Notification Digest Scheduler: ', ex);
    	}

    	try {
            logger.flushLogsToDB();    
        } catch (Exception e) {
            System.debug('Exception - ' + e.getMessage());
            // Do not want to log this exception 
        }
    }
}