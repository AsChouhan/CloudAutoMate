public with sharing class MySettingDataServer extends DataServer { 
    public transient final String STR_ERROR_PROFILE_BIRTHDAY_PARTIAL { get { return labelMap.get('my_settings.profile.birthday_partial_error_flash');}}
    public transient final String STR_ERROR_PROFILE_INACTIVE_MANAGER { get { return labelMap.get('my_settings.profile.inactive_manager_error_flash');}}
	public transient final String STR_ERROR_PROFILE_MANAGER_RECURSION { get { return labelMap.get('my_settings.profile.manager_recursion_error_flash');}}
	public transient final String STR_ERROR_PROFILE_SEGMENT_BLANK { get { return labelMap.get('my_settings.profile.segment_field_blank_error_flash');}}
	public transient final String STR_ERROR_LANGUAGE_NOT_ENABLED { get { return labelMap.get('my_settings.profile.language_disabled_error_flash');}}
	private final String ACTION_VALUE_GET_EMAIL_NOTIFICATIONS_SETTING = 'getEmailNotificationsSettings';
	private final String ACTION_VALUE_GET_MOBILE_APP_NOTIFICATION_SETTING = 'getMobileAppNotificationsSettings';
	private final String ACTION_VALUE_GET_NATIVE_MOBILE_APP_NOTIFICATION_SETTING = 'getNativeMobileAppNotificationsSettings';
    private final String ACTION_VALUE_GET_APP_MANAGER_NOTIFICATION_SETTING = 'getAppManagerNotificationsSettings';
    private final String ACTION_VALUE_GET_EXTERNAL_APP_SETTING = 'getExternalAppsSettings';
    private final String ACTION_VALUE_GET_SMS_NOTIFICATIONS_SETTING = 'getSMSNotificationsSettings';
	private final String ACTION_VALUE_SAVE_PROFILE_SETTING = 'saveProfileSettings';
	private final String ACTION_VALUE_SAVE_EMAIL_NOTIFICATIONS_SETTING = 'saveEmailNotificationsSettings';
    private final String ACTION_VALUE_SAVE_APP_MANAGER_NOTIFICATION_SETTING = 'saveAppManagerNotificationsSettings';
    private final String ACTION_VALUE_SAVE_MOBILE_APP_NOTIFICATION_SETTING = 'saveMobileAppNotificationsSettings';
    private final String ACTION_VALUE_SAVE_NATIVE_MOBILE_APP_NOTIFICATION_SETTING = 'saveNativeMobileAppNotificationsSettings';
    private final String ACTION_VALUE_SAVE_SMS_NOTIFICATIONS_SETTING = 'saveSMSNotificationsSettings';
    private final String ERROR_NOT_PERFORMING_ACTION = 'Unable to perform action.';
    private final String BIRTH_MONTH_DAY_EXCEPTION_MESSAGE = 'You must select both birthday month and date'; 
    private final String REQUEST_PARAM_DATA = 'data';
    private final String SETTINGS_UPDATED = 'Settings are being updated';
    
    private final String ACTION_VALUE_GET_BROWSER_NOTIFICATIONS_SETTING = 'getBrowserNotificationsSettings';
    private final String ACTION_VALUE_SAVE_BROWSER_NOTIFICATIONS_SETTING = 'saveBrowserNotificationsSettings';
    private final String ACTION_VALUE_SAVE_MOBILENO_SETTING = 'saveMobileNoOnProfileSettings';
    
    private final String ACTION_VALUE_GET_SUMMARIES_AND_DIGEST_SETTING = 'getSummariesAndDigestSettings';
    private final String ACTION_VALUE_SAVE_SUMMARIES_AND_DIGEST_SETTING = 'saveSummariesAndDigestSettings';
    private final String ACTION_VALUE_SAVE_USER_WEB_PUSH_CONFIG = 'saveUserWebPushConfig';
    private final String MICROSOFT_OUTLOOK_CALENDAR = 'microsoftoutlookcalendar';


    public MySettingDataServer() {
        
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {

        try {
        	logger.logDebug('MySettingDataServer----entered handleRequest----');
	    	
			String action = readParam(REQUEST_PARAM_ACTION);
        	String dataParam = readParam(REQUEST_PARAM_DATA);	

            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());

            } else {
				if (ACTION_VALUE_SAVE_MOBILENO_SETTING.equalsIgnoreCase(action)){
                    response = saveMobileNoOnProfileSettings(dataParam);

                } else if (ACTION_VALUE_GET_EMAIL_NOTIFICATIONS_SETTING.equalsIgnoreCase(action)) {
                	response = getEmailNotificationsSettings(readParam('peopleId'));
			    
                } else if (ACTION_VALUE_GET_SUMMARIES_AND_DIGEST_SETTING.equalsIgnoreCase(action)) {
                	response = getSummariesAndDigestSettings(readParam('peopleId'));
			    
                } else if (ACTION_VALUE_GET_MOBILE_APP_NOTIFICATION_SETTING.equalsIgnoreCase(action)) {
                	response = getMobileAppNotificationsSettings(readParam('peopleId'));
				
                } else if (ACTION_VALUE_GET_NATIVE_MOBILE_APP_NOTIFICATION_SETTING.equalsIgnoreCase(action)) {
                	response = getNativeMobileAppNotificationsSettings(readParam('peopleId'));
				
                } else if (ACTION_VALUE_GET_BROWSER_NOTIFICATIONS_SETTING.equalsIgnoreCase(action)){
                    response = getBrowserNotificationsSettings(readParam('peopleId'));
                    
                } else if (ACTION_VALUE_GET_APP_MANAGER_NOTIFICATION_SETTING.equalsIgnoreCase(action)) {
                	response = getAppManagerNotificationsSetting(readParam('peopleId'));
				
                } else if (ACTION_VALUE_GET_EXTERNAL_APP_SETTING.equalsIgnoreCase(action)) {
                	response = getExternalAppsSettings(readParam('peopleId'));
            	
                } else if (ACTION_VALUE_GET_SMS_NOTIFICATIONS_SETTING.equalsIgnoreCase(action)) {
                	response = getSMSNotificationsSettings(readParam('peopleId'));
            	
                } else if (ACTION_VALUE_SAVE_SMS_NOTIFICATIONS_SETTING.equalsIgnoreCase(action)) {
                	response = saveSMSNotificationsSettings(dataParam);
            	
                } else if (ACTION_VALUE_SAVE_PROFILE_SETTING.equalsIgnoreCase(action)) {
               		response = saveProfileSetting(dataParam);
            	
                } else if (ACTION_VALUE_SAVE_EMAIL_NOTIFICATIONS_SETTING.equalsIgnoreCase(action)) {
                	response = saveEmailNotificationsSetting(dataParam);
            	
                } else if (ACTION_VALUE_SAVE_APP_MANAGER_NOTIFICATION_SETTING.equalsIgnoreCase(action)) {
                	response = saveAppManagerNotificationsSetting(dataParam);
            	
                } else if (ACTION_VALUE_SAVE_MOBILE_APP_NOTIFICATION_SETTING.equalsIgnoreCase(action)) {
                	response = saveMobileAppNotificationsSetting(dataParam);
            	
                } else if (ACTION_VALUE_SAVE_NATIVE_MOBILE_APP_NOTIFICATION_SETTING.equalsIgnoreCase(action)) {
                	response = saveNativeMobileAppNotificationsSettings(dataParam);
            	
                } else if (ACTION_VALUE_SAVE_BROWSER_NOTIFICATIONS_SETTING.equalsIgnoreCase(action)){
                    response = saveBrowserNotificationsSettings(dataParam);

                }  else if (ACTION_VALUE_SAVE_SUMMARIES_AND_DIGEST_SETTING.equalsIgnoreCase(action)){
                    response = saveSummariesAndDigestSettings(dataParam);

                }  else if (ACTION_VALUE_SAVE_USER_WEB_PUSH_CONFIG.equalsIgnoreCase(action)){
                    response = saveUserWebPushConfig(dataParam);
                    
                } else {
                	throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            	}

            }
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
	}
    
	private MySettingsWrapper.EmailNotificationWrapper loadEmailNotificationSettings(String peopleId){
        MySettingsWrapper.EmailNotificationWrapper notificationSettings = new MySettingsWrapper.EmailNotificationWrapper();
        List<People_Preference__c> notificationPreferenceList = [SELECT id, 
                Allow_Simpplr_Emails__c, Receive_Content_Moderation_Notifications__c, 
                Email_Follows_Me__c, Email_Endorses_Me__c, Email_Updates_Content_Sites_I_Follow__c, 
                Email_Event_Invite_More__c, 
                Email_Like_My_Post_Or_Comment__c,Email_Content_Marked_As_Must_Read__c,
                Email_Comments_On_My_Post__c, Email_Content_Useful__c, Email_Comments_After_Me__c, 
                Email_Comments_On_Post_I_Like__c,Email_Posts_To_Me__c, Email_Shares_My_Post__c, 
                Email_My_Content_Post__c, Email_My_Content_Like_Or_Share__c, 
                Email_Private_Site_Membership_Requests__c, Email_Content_Submitted_For_Moderation__c, 
                Email_My_Content_Approved__c, Email_My_Content_Rejected__c, 
                Email_Notification_Digest_Frequency__c,
                Email_Content_Digest_Frequency__c, 
                Email_Digest_Frequency__c,Email_PrivateSiteMembership_Response__c, 
                Email_Subscription_Moderation__c, Email_My_Content_Validation_Expired__c, 
                Email_My_Content_Validation_Required__c, 
                Email_Content_Submission_Response__c, Email_Site_Analytics_Frequency__c, Email_Product_Research__c,
                Email_Updates_Event_I_RSVP_Yes__c,Email_Updates_Event_I_Author_Organize__c, 
                Email_Alerts__c, Receive_Content_Update_Notifications__c,
                Receive_Content_Useful_Notifications__c, Email_Subscription_Request__c,
                Email_QnA_New_Question__c, Email_QnA_New_Content_Question__c, Email_QnA_New_Content_Answer__c , Email_QnA_New_Answer__c, Email_QnA_Question_Mention__c,
                Email_QnA_Answer_Mention__c, Email_QnA_Answer_Vote__c, Email_QnA_Answer_Approval__c,
                Email_QnA_New_Answer_Approval__c, Email_QnA_Duplicate_Question__c,
                Email_CnI_Campaign_End__c, Email_CnI_Campaign_New__c, Email_CnI_Initiative_End__c, Email_CnI_Initiative_Start__c
                FROM People_Preference__c 
                WHERE People__r.Id =: peopleId WITH SECURITY_ENFORCED];


		if (notificationPreferenceList.isEmpty()) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		}
		
      	notificationSettings = toEmailNotiWrapper(notificationPreferenceList);
        return notificationSettings;
    }

	private MySettingsWrapper.EmailNotificationWrapper toEmailNotiWrapper(List<People_Preference__c> notificationPrefList) {
    	MySettingsWrapper.EmailNotificationWrapper notificationPref = new MySettingsWrapper.EmailNotificationWrapper();
        notificationPref.allowSimpplrEmails = notificationPrefList[0].Allow_Simpplr_Emails__c == true ? 'enable' : 'disable';
        notificationPref.emailFollowsMe = notificationPrefList[0].Email_Follows_Me__c;
        notificationPref.emailEndorseExpertise = notificationPrefList[0].Email_Endorses_Me__c;
        notificationPref.emailLikesPostOrCommentMade = notificationPrefList[0].Email_Like_My_Post_Or_Comment__c;
        notificationPref.emailCommentsPostMade = notificationPrefList[0].Email_Comments_On_My_Post__c;
        notificationPref.emailCommentsAfterMe = notificationPrefList[0].Email_Comments_After_Me__c;
        notificationPref.emailCommentsPostLike = notificationPrefList[0].Email_Comments_On_Post_I_Like__c;
        notificationPref.emailPostsToMe = notificationPrefList[0].Email_Posts_To_Me__c;
        notificationPref.emailSharesPostMade = notificationPrefList[0].Email_Shares_My_Post__c;
        notificationPref.emailSubscriptionModeration = notificationPrefList[0].Email_Subscription_Moderation__c;
        notificationPref.emailKnowledgeExpired = notificationPrefList[0].Email_My_Content_Validation_Expired__c;
        notificationPref.emailKnowledgeReview = notificationPrefList[0].Email_My_Content_Validation_Required__c;
        notificationPref.emailCommentsContentPublished = notificationPrefList[0].Email_My_Content_Post__c;
        notificationPref.emailLikesSharesContentPublished = notificationPrefList[0].Email_My_Content_Like_Or_Share__c;
        notificationPref.emailUpdatesContentSitesFollow = notificationPrefList[0].Email_Updates_Content_Sites_I_Follow__c;
        notificationPref.emailEventInviteMore = notificationPrefList[0].Email_Event_Invite_More__c;
        notificationPref.emailContentSubmittedApproved = notificationPrefList[0].Email_My_Content_Approved__c;
        notificationPref.emailContentSubmittedRejected = notificationPrefList[0].Email_My_Content_Rejected__c;
        notificationPref.emailContentSubmittedForModeration = notificationPrefList[0].Email_Content_Submitted_For_Moderation__c;
        notificationPref.emailForContentUseful = notificationPrefList[0].Email_Content_Useful__c;
        notificationPref.emailPrivateSiteMembershipRequest = notificationPrefList[0].Email_Private_Site_Membership_Requests__c;
        notificationPref.emailPrivateSiteMembershipResponse = notificationPrefList[0].Email_PrivateSiteMembership_Response__c;
        notificationPref.emailContentSubmissionResponse = notificationPrefList[0].Email_Content_Submission_Response__c;
        notificationPref.emailContentMarkedAsMustRead = notificationPrefList[0].Email_Content_Marked_As_Must_Read__c;
        notificationPref.emailUpdatesEventIRsvpYes = notificationPrefList[0].Email_Updates_Event_I_RSVP_Yes__c;
        notificationPref.emailUpdatesEventIAuthorOrganize = notificationPrefList[0].Email_Updates_Event_I_Author_Organize__c;
        notificationPref.emailNotificationFrequency = 'Immediate';
        notificationPref.emailAlerts = notificationPrefList[0].Email_Alerts__c;
        notificationPref.emailSubscriptionRequest =  notificationPrefList[0].Email_Subscription_Request__c;

        if (String.isNotBlank(notificationPrefList[0].Email_Notification_Digest_Frequency__c)) {
            notificationPref.emailNotificationFrequency = notificationPrefList[0].Email_Notification_Digest_Frequency__c;
        } 
        
        notificationPref.emailSiteActionableForAppMgr =  notificationPrefList[0].Receive_Content_Moderation_Notifications__c;
        notificationPref.emailForContentUsefulAppMgr = notificationPrefList[0].Receive_Content_Useful_Notifications__c;
        notificationPref.emailContentPromotionMessageForAppMgr = notificationPrefList[0].Receive_Content_Update_Notifications__c;
        notificationPref.emailContentUseful = notificationPrefList[0].Email_Content_Useful__c;

        notificationPref.emailQnANewQuestion = notificationPrefList[0].Email_QnA_New_Question__c;
        notificationPref.emailQnAQuestionMention = notificationPrefList[0].Email_QnA_Question_Mention__c;
        notificationPref.emailQnAAnswerMention = notificationPrefList[0].Email_QnA_Answer_Mention__c;
        notificationPref.emailQnAVote = notificationPrefList[0].Email_QnA_Answer_Vote__c;
        notificationPref.emailQnAAnswerApproval = notificationPrefList[0].Email_QnA_Answer_Approval__c;
        notificationPref.emailQnANewAnswer = notificationPrefList[0].Email_QnA_New_Answer__c;
        notificationPref.emailQnANewApprovedAnswer = notificationPrefList[0].Email_QnA_New_Answer_Approval__c;
        notificationPref.emailQnADuplicateQuestion = notificationPrefList[0].Email_QnA_Duplicate_Question__c;
        notificationPref.emailForContentQuestion = notificationPrefList[0].Email_QnA_New_Content_Question__c;
        notificationPref.emailForContentAnswer = notificationPrefList[0].Email_QnA_New_Content_Answer__c;

        notificationPref.emailCnIEndCampaign = notificationPrefList[0].Email_CnI_Campaign_End__c;
        notificationPref.emailCnINewCampaign = notificationPrefList[0].Email_CnI_Campaign_New__c;
        notificationPref.emailCnIInitiativeEnd = notificationPrefList[0].Email_CnI_Initiative_End__c;
        notificationPref.emailCnIInitiativeStart = notificationPrefList[0].Email_CnI_Initiative_Start__c;

        return notificationPref;
    }

    private ResponseWrapper getEmailNotificationsSettings(string peopleId) {
	    logger.logDebug('MySettingDataServer.getEmailNotificationsSetting()----peopleId----' + peopleId);	
	    ResponseWrapper responseWrapperObj = null;

	    try {
            MySettingsWrapper.EmailNotificationWrapper emailNotificationWrapObj = new MySettingsWrapper.EmailNotificationWrapper();		
		    emailNotificationWrapObj = loadEmailNotificationSettings(peopleId);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, emailNotificationWrapObj);
 
		} catch (Exception e) {        	
			logger.logError('MySettingDataServer.getEmailNotificationsSetting()----could not get email notification configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 	
		}

		return responseWrapperObj;
    }

    private ResponseWrapper getSummariesAndDigestSettings(string peopleId) {
	    logger.logDebug('MySettingDataServer.getSummariesAndDigestSettings()----peopleId----' + peopleId);	
	    ResponseWrapper responseWrapperObj = null;

	    try {
            MySettingsWrapper.SummariesAndDigestWrapper summariesAndDigestWrapObj = new MySettingsWrapper.SummariesAndDigestWrapper();		
		    summariesAndDigestWrapObj = loadSummariesAndDigestSettings(peopleId);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, summariesAndDigestWrapObj);
 
		} catch (Exception e) {        	
			logger.logError('MySettingDataServer.getSummariesAndDigestSettings()----could not get SummariesAndDigest configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 	
		}

		return responseWrapperObj;
    }

    private MySettingsWrapper.SummariesAndDigestWrapper loadSummariesAndDigestSettings(String peopleId){
        MySettingsWrapper.SummariesAndDigestWrapper summariesAndDigestSettingsObj = new MySettingsWrapper.SummariesAndDigestWrapper();
        List<People_Preference__c> notificationPreferenceList = [SELECT id, 
                Email_Product_Research__c,Email_Digest_Frequency__c, 
                Email_Content_Digest_Frequency__c, Email_Site_Analytics_Frequency__c, Email_Onboarding_Frequency__c
                FROM People_Preference__c 
                WHERE People__r.Id =: peopleId WITH SECURITY_ENFORCED];

		if (notificationPreferenceList.isEmpty()) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		}
		
        summariesAndDigestSettingsObj = toSummariesAndDigestWrapper(notificationPreferenceList);
        return summariesAndDigestSettingsObj;
    }

	private MySettingsWrapper.SummariesAndDigestWrapper toSummariesAndDigestWrapper(List<People_Preference__c> notificationPrefList) {
    	MySettingsWrapper.SummariesAndDigestWrapper summariesAndDigestWrapObj = new MySettingsWrapper.SummariesAndDigestWrapper();
        summariesAndDigestWrapObj.emailProductResearch = notificationPrefList[0].Email_Product_Research__c;
        summariesAndDigestWrapObj.digestFrequency = String.isNotBlank(notificationPrefList[0].Email_Digest_Frequency__c) ? notificationPrefList[0].Email_Digest_Frequency__c : 'Daily';
        summariesAndDigestWrapObj.topStoriesFrequency = String.isNotBlank(notificationPrefList[0].Email_Content_Digest_Frequency__c) ? notificationPrefList[0].Email_Content_Digest_Frequency__c : 'Daily';
        summariesAndDigestWrapObj.siteAnalyticsFrequency = String.isNotBlank(notificationPrefList[0].Email_Site_Analytics_Frequency__c) ? notificationPrefList[0].Email_Site_Analytics_Frequency__c : 'monthly';
        if(SimpplrContext.isFeatureContentOnboardingEnabled) {
            summariesAndDigestWrapObj.emailOnboardingFrequency = String.isNotBlank(notificationPrefList[0].Email_Onboarding_Frequency__c) ? notificationPrefList[0].Email_Onboarding_Frequency__c : 'Never';
        } else {
            summariesAndDigestWrapObj.emailOnboardingFrequency = 'Never';
        }
        return summariesAndDigestWrapObj;
    }

    private ResponseWrapper getSMSNotificationsSettings(string peopleId) {
	    logger.logDebug('MySettingDataServer.getSMSNotificationsSettings()----peopleId----' + peopleId);	
	    ResponseWrapper responseWrapperObj = null;

	    try {
                MySettingsWrapper.SMSNotificationsWrapper sMSNotificationWrapObj = new MySettingsWrapper.SMSNotificationsWrapper();		
		    sMSNotificationWrapObj = loadSMSNotificationSettings(peopleId);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, sMSNotificationWrapObj);

		} catch (Exception e) {        	
		logger.logError('MySettingDataServer.getSMSNotificationsSettings()----could not get sms notification configuration',e);
                    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 	
		}

		return responseWrapperObj;
    }

    private MySettingsWrapper.SMSNotificationsWrapper loadSMSNotificationSettings(String peopleId){
        MySettingsWrapper.SMSNotificationsWrapper notificationSettings = new MySettingsWrapper.SMSNotificationsWrapper();
        List<People_Preference__c> notificationPreferenceList = [select id, SMS_Alerts__c, SMS_Must_Reads__c, SMS_Content_Promotion_Message__c
            from People_Preference__c where People__r.Id =: peopleId WITH SECURITY_ENFORCED];

		if (notificationPreferenceList.isEmpty()) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		}
		
      	 notificationSettings = toSMSNotiWrapper(notificationPreferenceList);
        return notificationSettings;
    }

    private MySettingsWrapper.SMSNotificationsWrapper toSMSNotiWrapper(List<People_Preference__c> notificationPrefList) {
    	 MySettingsWrapper.SMSNotificationsWrapper notificationPref = new MySettingsWrapper.SMSNotificationsWrapper();
        notificationPref.smsAlerts = notificationPrefList[0].SMS_Alerts__c;
        notificationPref.smsContentMarkedAsMustRead = notificationPrefList[0].SMS_Must_Reads__c;
        notificationPref.smsContentPromotionMessage = notificationPrefList[0].SMS_Content_Promotion_Message__c;
        return notificationPref;
    }

    private MySettingsWrapper.MobileNotificationWrapper loadMobileNotificationSettings(String peopleId) {
        MySettingsWrapper.MobileNotificationWrapper notificationSettings = new MySettingsWrapper.MobileNotificationWrapper();
       
        try {
          	List<People_Preference__c> notificationPreferenceList = [select id, 
                    Mobile_Allow_Notifications__c, Mobile_Comments_After_Me__c, 
                    Mobile_Comments_On_My_Post__c, Mobile_Comments_On_Post_I_Like__c, 
                    Mobile_Content_Submitted_For_Moderation__c, Mobile_Endorses_Me__c, 
                    Mobile_Follows_Me__c, Mobile_Like_My_Post_Or_Comment__c, 
                    Mobile_Posts_To_Me__c, Mobile_Updates_Content_Sites_I_Follow__c, 
                    Mobile_Event_Invite_More__c, Mobile_My_Content_Approved__c, 
                    Mobile_My_Content_Post__c, Mobile_My_Content_Rejected__c, 
                    Mobile_Content_Marked_As_Must_Read__c,
                    Mobile_My_Content_Like_Or_Share__c, Mobile_Content_Useful__c, 
                    Mobile_Private_Site_Membership_Requests__c, Mobile_Shares_My_Post__c,   
                    Mobile_Content_Submission_Response__c,Mobile_PrivateSiteMembership_Response__c
                    FROM People_Preference__c 
                    WHERE People__r.Id =: peopleId WITH SECURITY_ENFORCED];
			
			if (notificationPreferenceList.isEmpty()) {
				throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
			}
			
      		notificationSettings = toMobileWrapper(notificationPreferenceList);
        
        } catch (Exception e) {
            logger.logError(e.getStackTraceString());
        }

		return notificationSettings;
    }
    
    private MySettingsWrapper.MobileNotificationWrapper toMobileWrapper(List<People_Preference__c> notificationPrefList) {
    	MySettingsWrapper.MobileNotificationWrapper notificationPref = new MySettingsWrapper.MobileNotificationWrapper();
        notificationPref.mobileAppNotifications = notificationPrefList[0].Mobile_Allow_Notifications__c;
        notificationPref.mobileAppFollowsMe = notificationPrefList[0].Mobile_Follows_Me__c;
        notificationPref.mobileAppEndorseExpertise = notificationPrefList[0].Mobile_Endorses_Me__c;
        notificationPref.mobileAppLikesPostOrCommentMade = notificationPrefList[0].Mobile_Like_My_Post_Or_Comment__c;
        notificationPref.mobileAppCommentsPostMade = notificationPrefList[0].Mobile_Comments_On_My_Post__c;
        notificationPref.mobileAppCommentsAfterMe = notificationPrefList[0].Mobile_Comments_After_Me__c;
        notificationPref.mobileAppUpdatesContentSitesFollow = notificationPrefList[0].Mobile_Updates_Content_Sites_I_Follow__c;
        notificationPref.mobileAppEventInviteMore = notificationPrefList[0].Mobile_Event_Invite_More__c;
        notificationPref.mobileAppCommentsPostLike = notificationPrefList[0].Mobile_Comments_On_Post_I_Like__c;
        notificationPref.mobileAppPostsToMe = notificationPrefList[0].Mobile_Posts_To_Me__c;
        notificationPref.mobileAppSharesPostMade = notificationPrefList[0].Mobile_Shares_My_Post__c;
        notificationPref.mobileAppCommentsContentPublished = notificationPrefList[0].Mobile_My_Content_Post__c;
        notificationPref.mobileAppLikesOrSharesContentPublished = notificationPrefList[0].Mobile_My_Content_Like_Or_Share__c;
        notificationPref.mobileAppContentSubmittedApproved = notificationPrefList[0].Mobile_My_Content_Approved__c;
        notificationPref.mobileAppContentSubmittedRejected = notificationPrefList[0].Mobile_My_Content_Rejected__c;
        notificationPref.mobileAppContentSubmittedForModeration = notificationPrefList[0].Mobile_Content_Submitted_For_Moderation__c;
        notificationPref.mobileAppContentUseful = notificationPrefList[0].Mobile_Content_Useful__c;
        notificationPref.mobileAppPrivateSiteMembershipRequest = notificationPrefList[0].Mobile_Private_Site_Membership_Requests__c;
        notificationPref.mobileAppContentSubmissionResponse =  notificationPrefList[0].Mobile_Content_Submission_Response__c;
        notificationPref.mobileAppPrivateSiteMembershipResponse =  notificationPrefList[0].Mobile_PrivateSiteMembership_Response__c;
        notificationPref.mobileAppContentMarkedAsMustRead =  notificationPrefList[0].Mobile_Content_Marked_As_Must_Read__c;
    	return notificationPref;
    }

	private ResponseWrapper getMobileAppNotificationsSettings(string peopleId) {
	    logger.logDebug('MySettingDataServer.getMobileAppNotificationsSettings()----');	
	    ResponseWrapper responseWrapperObj = null;

	    try {
            MySettingsWrapper.MobileNotificationWrapper mobileNotificationWrapObj = new MySettingsWrapper.MobileNotificationWrapper();		
			mobileNotificationWrapObj = loadMobileNotificationSettings(peopleId);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, mobileNotificationWrapObj);

		} catch (Exception e) {        	
			logger.logError('SettingDataServer.getMobileAppNotificationsSettings()----could not get mobile app notification configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 	
        }

		return responseWrapperObj;
    }

	private MySettingsWrapper.NativeMobileNotificationWrapper loadNativeMobileNotificationSettings(String peopleId) {
        MySettingsWrapper.NativeMobileNotificationWrapper notificationSettings = new MySettingsWrapper.NativeMobileNotificationWrapper();
          List<People_Preference__c> notificationPreferenceList = [SELECT id, 
                    Native_Mob_Content_Marked_As_Must_Read__c, Native_Mobile_Alerts__c, Native_Mob_Update_Content_Site_I_Follow__c, 
                    Native_Mobile_Follows_Me__c, Native_Mob_Endorse_Expertise__c, 
                    Native_Mob_Comments_On_My_Post__c, Native_Mob_Reply_After_Me__c, Native_Mob_Replied_On_liked_Post__c, Native_Mob_Like_My_Post_Or_Comment__c, Native_Mob_Shares_My_Post__c, Native_Mob_Posts_To_Me__c,
                    Native_MobPrivateSiteMembership_Resp__c,
                    Native_Mob_My_Content_Post__c, Native_Mobile_My_Content_Like_Or_Share__c, Native_Mob_Content_ApproveReject__c, 
                    Native_Mobile_Event_Invite_More__c, 
                    Native_Mob_Private_Site_Membership_Req__c, Native_Mob_Content_Submit_Moderation__c,
                    Native_Mobile_QnA_Question_Mention__c, Native_Mobile_QnA_Answer_Mention__c, Native_Mobile_QnA_Answer_Vote__c,
                    Native_Mobile_QnA_Answer_Approval__c, Native_Mobile_QnA_New_Answer__c, Native_Mobile_QnA_New_Answer_Approval__c,
                    Native_Mobile_QnA_Duplicate_Question__c, Native_Mobile_QnA_New_Question__c, Native_Mobile_QnA_New_Content_Question__c, Native_Mobile_QnA_New_Content_Answer__c, Native_Mobile_Surveys__c
      			FROM People_Preference__c 
                WHERE People__r.Id =: peopleId WITH SECURITY_ENFORCED];
		
		if (notificationPreferenceList.isEmpty()) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		}
		
  		notificationSettings = toMobileNotiWrapper(notificationPreferenceList);
		return notificationSettings;
    }

    private MySettingsWrapper.BrowserNotificationWrapper loadBrowserNotificationSettings(String peopleId) {
        MySettingsWrapper.BrowserNotificationWrapper notificationSettings = new MySettingsWrapper.BrowserNotificationWrapper();
          List<People_Preference__c> notificationPreferenceList = [SELECT id, 
                    Browser_Must_Read__c,Browser_Alerts__c,Browser_Update_Content_Site_I_Follow__c,Browser_Follows_Me__c,
                    Browser_Endorse_Expertise__c,Browser_Comments_On_My_Post__c,Browser_Comments_After_Me__c,
                    Browser_Comments_On_Liked_Post__c,Browser_Like_My_Post_Or_Comment__c,Browser_Shares_My_Post__c,
                    Browser_Posts_To_Me__c,Browser_Content_Validation_Required__c,Browser_Content_Validation_Expired__c,
                    Browser_Content_Comments_On_Published__c,Browser_Content_LikesShares_On_Published__c,
                    Browser_Content_Approval_Rejection__c,Browser_Content_Feedback__c,Browser_Event_Invite__c,
                    Browser_Event_Updates_Attending__c,Browser_Event_Updates_Authored_Organized__c,Browser_Site_Membership_Request__c,
                    Browser_Subscription_Submission__c,Browser_Content_Submission__c, Browser_PrivateSiteMembership_Resp__c,
                    Browser_QnA_Answer_Approval__c, Browser_QnA_Answer_Mention__c, Browser_QnA_Answer_Vote__c, Browser_QnA_Duplicate_Question__c,
                    Browser_QnA_New_Answer__c, Browser_QnA_New_Answer_Approval__c, Browser_QnA_New_Question__c, Browser_QnA_Question_Mention__c,
                    Browser_QnA_New_Content_Question__c, Browser_QnA_New_Content_Answer__c,
                    Browser_CnI_Campaign_End__c, Browser_CnI_Campaign_New__c, Browser_CnI_Initiative_End__c, Browser_CnI_Initiative_Start__c
      			FROM People_Preference__c 
                WHERE People__r.Id =: peopleId WITH SECURITY_ENFORCED];
		
		if (notificationPreferenceList.isEmpty()) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		}
		
  		notificationSettings = toBrowserNotiWrapper(notificationPreferenceList);
		return notificationSettings;
    }
  
    private MySettingsWrapper.NativeMobileNotificationWrapper toMobileNotiWrapper(List<People_Preference__c> notificationPrefList) {
    	MySettingsWrapper.NativeMobileNotificationWrapper notificationPref = new MySettingsWrapper.NativeMobileNotificationWrapper();
        //Org
        notificationPref.mobileAppContentMarkedAsMustRead = notificationPrefList[0].Native_Mob_Content_Marked_As_Must_Read__c;
        notificationPref.mobileAppAlerts = notificationPrefList[0].Native_Mobile_Alerts__c;
        notificationPref.mobileAppUpdatesContentSitesFollow = notificationPrefList[0].Native_Mob_Update_Content_Site_I_Follow__c;
        //Profile
        notificationPref.mobileAppFollowsMe = notificationPrefList[0].Native_Mobile_Follows_Me__c;
        notificationPref.mobileAppEndorseExpertise = notificationPrefList[0].Native_Mob_Endorse_Expertise__c;
        //Feed
        notificationPref.mobileAppCommentsPostMade = notificationPrefList[0].Native_Mob_Comments_On_My_Post__c;
        notificationPref.mobileAppReplyAfterMe = notificationPrefList[0].Native_Mob_Reply_After_Me__c;
        notificationPref.mobileAppReplyOnLikedPost = notificationPrefList[0].Native_Mob_Replied_On_liked_Post__c;
        notificationPref.mobileAppLikesPostOrCommentMade = notificationPrefList[0].Native_Mob_Like_My_Post_Or_Comment__c;
        notificationPref.mobileAppSharesMyPost = notificationPrefList[0].Native_Mob_Shares_My_Post__c;
        notificationPref.mobileAppPostsToMe = notificationPrefList[0].Native_Mob_Posts_To_Me__c;
        //Sites
        notificationPref.mobileAppPrivateSiteMembershipResponse = notificationPrefList[0].Native_MobPrivateSiteMembership_Resp__c;
        //Content
        notificationPref.mobileAppCommentsContentPublished = notificationPrefList[0].Native_Mob_My_Content_Post__c;
        notificationPref.mobileAppLikesOrSharesContentPublished = notificationPrefList[0].Native_Mobile_My_Content_Like_Or_Share__c;
        notificationPref.mobileAppContentApprovalRejection = notificationPrefList[0].Native_Mob_Content_ApproveReject__c;
        //Events
        notificationPref.mobileAppEventInviteMore = notificationPrefList[0].Native_Mobile_Event_Invite_More__c;
        //Site Management
        notificationPref.mobileAppPrivateSiteMembershipRequest = notificationPrefList[0].Native_Mob_Private_Site_Membership_Req__c;
        notificationPref.mobileAppContentSubmittedForModeration = notificationPrefList[0].Native_Mob_Content_Submit_Moderation__c;
        //Question Answer
        notificationPref.mobileQnAQuestionMention = notificationPrefList[0].Native_Mobile_QnA_Question_Mention__c;
        notificationPref.mobileQnAAnswerMention = notificationPrefList[0].Native_Mobile_QnA_Answer_Mention__c;
        notificationPref.mobileQnAVote = notificationPrefList[0].Native_Mobile_QnA_Answer_Vote__c;
        notificationPref.mobileQnAAnswerApproval = notificationPrefList[0].Native_Mobile_QnA_Answer_Approval__c;
        notificationPref.mobileQnANewAnswer = notificationPrefList[0].Native_Mobile_QnA_New_Answer__c;
        notificationPref.mobileQnANewApprovedAnswer = notificationPrefList[0].Native_Mobile_QnA_New_Answer_Approval__c;
        notificationPref.mobileQnADuplicateQuestion = notificationPrefList[0].Native_Mobile_QnA_Duplicate_Question__c;
        notificationPref.mobileQnANewQuestion = notificationPrefList[0].Native_Mobile_QnA_New_Question__c;
        notificationPref.mobileAppContentQuestion = notificationPrefList[0].Native_Mobile_QnA_New_Content_Question__c;
        notificationPref.mobileAppContentAnswer = notificationPrefList[0].Native_Mobile_QnA_New_Content_Answer__c;

        //Surveys
        notificationPref.mobileSurveys = notificationPrefList[0].Native_Mobile_Surveys__c;

        return notificationPref;
    }

    private MySettingsWrapper.BrowserNotificationWrapper toBrowserNotiWrapper(List<People_Preference__c> notificationPrefList) {
        MySettingsWrapper.BrowserNotificationWrapper notificationPrefWrapper = new MySettingsWrapper.BrowserNotificationWrapper();
        //Org
        notificationPrefWrapper.browserMustRead = notificationPrefList[0].Browser_Must_Read__c;
        notificationPrefWrapper.browserAlerts = notificationPrefList[0].Browser_Alerts__c;
        notificationPrefWrapper.browserUpdatesContentSitesFollow = notificationPrefList[0].Browser_Update_Content_Site_I_Follow__c;
        //Profile 
        notificationPrefWrapper.browserFollowsMe = notificationPrefList[0].Browser_Follows_Me__c;
        notificationPrefWrapper.browserEndorseExpertise = notificationPrefList[0].Browser_Endorse_Expertise__c;
        //Feed
        notificationPrefWrapper.browserReplyOnMyPost = notificationPrefList[0].Browser_Comments_On_My_Post__c;
        notificationPrefWrapper.browserReplyAfterMe = notificationPrefList[0].Browser_Comments_After_Me__c;
        notificationPrefWrapper.browserReplyOnLikedPost = notificationPrefList[0].Browser_Comments_On_Liked_Post__c;
        notificationPrefWrapper.browserLikesMyPostOrReply = notificationPrefList[0].Browser_Like_My_Post_Or_Comment__c;
        notificationPrefWrapper.browserSharesMyPost = notificationPrefList[0].Browser_Shares_My_Post__c;
        notificationPrefWrapper.browserPostsToMe = notificationPrefList[0].Browser_Posts_To_Me__c;
        //Site
        notificationPrefWrapper.browserPrivateSiteMembershipResponse = notificationPrefList[0].Browser_PrivateSiteMembership_Resp__c;
        //Content
        notificationPrefWrapper.browserContentValidationRequired = notificationPrefList[0].Browser_Content_Validation_Required__c;
        notificationPrefWrapper.browserContentValidationExpired = notificationPrefList[0].Browser_Content_Validation_Expired__c;
        notificationPrefWrapper.browserContentCommentsOnPublished =  notificationPrefList[0].Browser_Content_Comments_On_Published__c;
        notificationPrefWrapper.browserContentLikesSharesOnPublished = notificationPrefList[0].Browser_Content_LikesShares_On_Published__c;
        notificationPrefWrapper.browserContentApprovalRejection = notificationPrefList[0].Browser_Content_Approval_Rejection__c;
        notificationPrefWrapper.browserContentFeedback = notificationPrefList[0].Browser_Content_Feedback__c;
        //Event
        notificationPrefWrapper.browserEventInvite = notificationPrefList[0].Browser_Event_Invite__c;
        notificationPrefWrapper.browserEventUpdatesAttending = notificationPrefList[0].Browser_Event_Updates_Attending__c;
        notificationPrefWrapper.browserEventUpdatesAuthoredOrganized = notificationPrefList[0].Browser_Event_Updates_Authored_Organized__c;
        //Site Management
        notificationPrefWrapper.browserPrivateSiteMembershipRequest = notificationPrefList[0].Browser_Site_Membership_Request__c;
        notificationPrefWrapper.browserContentSubmittedForModeration = notificationPrefList[0].Browser_Content_Submission__c;
        notificationPrefWrapper.browserSubscriptionRequest = notificationPrefList[0].Browser_Subscription_Submission__c;

        //Question Answer
        notificationPrefWrapper.browserQnAAnswerApproval = notificationPrefList[0].Browser_QnA_Answer_Approval__c;
        notificationPrefWrapper.browserQnAAnswerMention = notificationPrefList[0].Browser_QnA_Answer_Mention__c;
        notificationPrefWrapper.browserQnAVote = notificationPrefList[0].Browser_QnA_Answer_Vote__c;
        notificationPrefWrapper.browserQnADuplicateQuestion = notificationPrefList[0].Browser_QnA_Duplicate_Question__c;
        notificationPrefWrapper.browserQnANewAnswer = notificationPrefList[0].Browser_QnA_New_Answer__c;
        notificationPrefWrapper.browserQnANewApprovedAnswer = notificationPrefList[0].Browser_QnA_New_Answer_Approval__c;
        notificationPrefWrapper.browserQnANewQuestion = notificationPrefList[0].Browser_QnA_New_Question__c;
        notificationPrefWrapper.browserQnAQuestionMention = notificationPrefList[0].Browser_QnA_Question_Mention__c;
        notificationPrefWrapper.browserContentQuestion = notificationPrefList[0].Browser_QnA_New_Content_Question__c;
        notificationPrefWrapper.browserContentAnswer = notificationPrefList[0].Browser_QnA_New_Content_Answer__c;

        //Campaign & Initiative
        notificationPrefWrapper.browserCnIEndCampaign = notificationPrefList[0].Browser_CnI_Campaign_End__c;
        notificationPrefWrapper.browserCnINewCampaign = notificationPrefList[0].Browser_CnI_Campaign_New__c;
        notificationPrefWrapper.browserCnIInitiativeEnd = notificationPrefList[0].Browser_CnI_Initiative_End__c;
        notificationPrefWrapper.browserCnIInitiativeStart = notificationPrefList[0].Browser_CnI_Initiative_Start__c;
        return notificationPrefWrapper;
    }
	
	private ResponseWrapper getNativeMobileAppNotificationsSettings(string peopleId) {
	    logger.logDebug('MySettingDataServer.getNativeMobileAppNotificationsSettings()----');	
	    ResponseWrapper responseWrapperObj = null;

	    try {
            MySettingsWrapper.NativeMobileNotificationWrapper notificationWrapper = new MySettingsWrapper.NativeMobileNotificationWrapper();		
		    notificationWrapper = loadNativeMobileNotificationSettings(peopleId);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, 
                    notificationWrapper);

		} catch (Exception e) {        	
			logger.logError('MySettingDataServer.getNativeMobileAppNotificationsSettings()----could not get native mobile app notification configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 	
        }

		return responseWrapperObj;
    }

    private ResponseWrapper getBrowserNotificationsSettings(string peopleId) {
	    logger.logDebug('MySettingDataServer.getBrowserNotificationsSettings()----');	
	    ResponseWrapper responseWrapperObj = null;

	    try {
            MySettingsWrapper.BrowserNotificationWrapper notificationWrapper = new MySettingsWrapper.BrowserNotificationWrapper();		
		    notificationWrapper = loadBrowserNotificationSettings(peopleId);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, 
                    notificationWrapper);

		} catch (Exception e) {        	
			logger.logError('MySettingDataServer.getBrowserNotificationsSettings()----could not get browser notification configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 	
        }

		return responseWrapperObj;
    }

	private ResponseWrapper getAppManagerNotificationsSetting(string peopleId) {
	    logger.logDebug('MySettingDataServer.getAppManagerNotificationsSetting()----');	
	    ResponseWrapper responseWrapperObj = null;

	    try {
            MySettingsWrapper.AppManagerNotificationWrapper appManagerNotificationWrapObj = new MySettingsWrapper.AppManagerNotificationWrapper();		
			appManagerNotificationWrapObj = loadAppManagerNotificationSetting(peopleId);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, 
                    appManagerNotificationWrapObj);

		} catch (Exception e) {        	
			logger.logError('SettingDataServer.getAppManagerNotificationsSetting()----could not get app manager notification configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 	
        }

		return responseWrapperObj;
    }

	private MySettingsWrapper.AppManagerNotificationWrapper loadAppManagerNotificationSetting(String peopleId) {
        MySettingsWrapper.AppManagerNotificationWrapper notificationSettings = new MySettingsWrapper.AppManagerNotificationWrapper();
        List<People_Preference__c> peoplePrefList = [SELECT Receive_Content_Update_Notifications__c,
                Receive_Content_Moderation_Notifications__c, 
                Receive_Content_Useful_Notifications__c 
                FROM People_Preference__c 
                WHERE people__r.Id =:peopleId WITH SECURITY_ENFORCED];
		
		if (peoplePrefList.isEmpty()) {
			throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
		}
		
  		notificationSettings = toAppManagerNotiWrapper(peoplePrefList);
		return notificationSettings;
    }
    
	private MySettingsWrapper.AppManagerNotificationWrapper toAppManagerNotiWrapper(List<People_Preference__c> peoplePrefList) {
    	MySettingsWrapper.AppManagerNotificationWrapper notificationPref = new MySettingsWrapper.AppManagerNotificationWrapper();
        notificationPref.appManagerNotifications = peoplePrefList[0].Receive_Content_Moderation_Notifications__c;
        notificationPref.appManagerUsefulContentNotifications = peoplePrefList[0].Receive_Content_Useful_Notifications__c;
        notificationPref.appManagerUpdateContentNotifications = peoplePrefList[0].Receive_Content_Update_Notifications__c;
    	return notificationPref;
    }	

    private ResponseWrapper saveMobileNoOnProfileSettings(String requestData) {
        logger.logDebug('MySettingDataServer.saveMobileNoOnProfileSettings()----requestData----'+requestData);
        
    	if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
        }

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        try {
            String message = 'Saved changes successfully';
            MySettingsWrapper.MobileNumberWrapper userMobileNumberWrapper = (MySettingsWrapper.MobileNumberWrapper)Json.deserialize(requestData, MySettingsWrapper.MobileNumberWrapper.class);
            logger.logDebug('MySettingDataServer.saveMobileNoOnProfileSettings()----MobileNumberWrapper----'+ userMobileNumberWrapper);
            if (userMobileNumberWrapper.peopleId != UserContext.peopleId && !UserContext.isUserAppModerator) {
            	throw new SimpplrException(ExceptionCode.NO_ACCESS.name());
            }
            List<People__c> peopleList = [SELECT id, User__c, Mobile_Phone__c FROM People__c WHERE Id =:userMobileNumberWrapper.peopleId WITH SECURITY_ENFORCED];
            if (!peopleList.isEmpty()){
                People__c people = peopleList[0];
                people.Mobile_Phone__c = userMobileNumberWrapper.mobile;
                
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().updateAsUser(people,new List<Schema.SObjectField>{
                    People__c.Mobile_Phone__c
                    });
            }
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, message, null);
        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save mobile info', e);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);
        }
        return responseWrapperObj;
    }


    private ResponseWrapper saveProfileSetting(String requestData) {
    	logger.logDebug('MySettingDataServer.saveProfileSetting()----requestData----'+requestData);
    	
    	if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}
    	
        ResponseWrapper responseWrapperObj = new ResponseWrapper();

        try {
        	MySettingsWrapper.ProfileWrapper profileWrapper = (MySettingsWrapper.ProfileWrapper)Json.deserialize(requestData, MySettingsWrapper.ProfileWrapper.class);
            logger.logDebug('MySettingDataServer.saveProfileSetting()----profileWrapper----'+ profileWrapper);
            // Redirect URL Args
        	Map<String, String> args = new Map<String, String>();
        	String message = 'Saved changes successfully';
            
            if (profileWrapper.peopleId != UserContext.peopleId && !UserContext.isUserAppModerator) {
            	throw new SimpplrException(ExceptionCode.NO_ACCESS.name());
            }

            if ((String.isBlank(profileWrapper.birthdayMonth) && 
                    String.isNotBlank(profileWrapper.birthdayDay)) || 
                    (String.isNotBlank(profileWrapper.birthdayMonth) && 
                    String.isBlank(profileWrapper.birthdayDay))) {
				throw new SimpplrException(STR_ERROR_PROFILE_BIRTHDAY_PARTIAL);
			}

            List<Schema.SObjectField> userObjectFieldList = new List<Schema.SObjectField>();

            Boolean isManagerActive = true;
            String managerOfManager = '';
            List<People__c> peopleList = [SELECT id, First_Name__c, User__c, 
                    Last_Name__c, Street__c, Title__c, Department__c, Manager__c, 
                    Manager__r.Full_Name__c, Manager__r.manager__c,About__c, Phone__c, 
                    People_Category__c, Extension__c, Mobile_Phone__c, City__c, 
                    State__c, Country__c, User__r.TimeZoneSidKey, User__r.LanguageLocaleKey,
        			Zoom_Id__c, Skype_Id__c, 
                    Raw_City__c, Raw_Country__c, Raw_State__c, Location_Normalization_Status__c,
                    People__c.Joining_Date__c, People__c.Birth_Date__c, People__c.Division__c, 
                    People__c.Company_Name__c, Custom_Field_1__c, Custom_Field_2__c,
                    Custom_Field_3__c, Custom_Field_4__c, Custom_Field_5__c,
                    Custom_Field_6__c, Custom_Field_7__c, Custom_Field_8__c,
                    Custom_Field_9__c, Custom_Field_10__c, Custom_Field_11__c,
                    Custom_Field_12__c, Custom_Field_13__c, Custom_Field_14__c,
                    Custom_Field_15__c, Custom_Field_16__c, Custom_Field_17__c,
                    Custom_Field_18__c, Custom_Field_19__c, Custom_Field_20__c,
                    Custom_Field_21__c, Custom_Field_22__c, Custom_Field_23__c,
                    Custom_Field_24__c, Custom_Field_25__c,
                    User_Custom_Field_1__c, User_Custom_Field_2__c, User_Custom_Field_3__c,
                    User_Custom_Field_4__c, User_Custom_Field_5__c, User_Custom_Field_6__c,
                    User_Custom_Field_7__c, User_Custom_Field_8__c, User_Custom_Field_9__c,
                    User_Custom_Field_10__c, User_Custom_Field_11__c, User_Custom_Field_12__c,
                    User_Custom_Field_13__c, User_Custom_Field_14__c, User_Custom_Field_15__c,
                    User_Custom_Field_16__c, User_Custom_Field_17__c, User_Custom_Field_18__c,
                    User_Custom_Field_19__c, User_Custom_Field_20__c, User_Custom_Field_21__c,
                    User_Custom_Field_22__c, User_Custom_Field_23__c, User_Custom_Field_24__c, 
                    User_Custom_Field_25__c
        			FROM People__c 
                    WHERE Id =:profileWrapper.peopleId WITH SECURITY_ENFORCED];
        	
        	if (!peopleList.isEmpty()) {
        		List<People__c> managerList = [SELECT User__r.isActive,manager__c 
                        FROM people__c 
                        WHERE id = :profileWrapper.manager WITH SECURITY_ENFORCED];

        		if (!managerList.isEmpty()) {
        			isManagerActive = managerList[0].User__r.isActive;
        			managerOfManager = managerList[0].manager__c;
        		}

        	}
        	
            if (!peopleList.isEmpty() && profileWrapper != null) {
            	
                if (UserContext.isUserAppModerator || 
                        (!UserContext.isUserAppModerator && SimpplrContext.isPPManagerEditable)) {

            		if (!isManagerActive) {
            			throw new SimpplrException(STR_ERROR_PROFILE_INACTIVE_MANAGER);
	            	
                    } else if (String.isNotBlank(managerOfManager) && 
                            profileWrapper.peopleId == managerOfManager) {
	            		throw new SimpplrException(STR_ERROR_PROFILE_MANAGER_RECURSION);
	            	}

            	}
            	
	            People__c people = toPeople(peopleList[0], profileWrapper);
                List<Schema.SObjectField> peopleObjectFieldList = new List<Schema.SObjectField>();

	            if (people != null) {
	            	// Check if segmentation is enabled and app manager is trying to update the segmentation field.
	            	
                    if (SimpplrContext.isSegmentsEnabled && UserContext.isUserAppModerator){
	            		String segmentFieldName = SimpplrContext.namespacePrefix + SimpplrContext.segmentColumnName;
	            		String segmentFieldNameValue = people.get(segmentFieldName) != null && String.isNotBlank((String) people.get(segmentFieldName)) ? (String) people.get(segmentFieldName) : '';
	            		
	            		// Check for Segments
                        Map<String, Object> soqlParamMap = new  Map<String, Object>();
                        soqlParamMap.put('soqlParam1', segmentFieldNameValue);
                        String query = 'SELECT Id FROM Segment_Rule__c WHERE Attribute_Value__c = :soqlParam1';
                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
                        List<Segment_Rule__c> segmentRuleList = (List<Segment_Rule__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
	            		
                        if (segmentRuleList.isEmpty()) {
	            			
                            if (profileWrapper.peopleId != UserContext.peopleId) {
	            				// warning message if editing some other profile
	            				message = STR_ERROR_PROFILE_SEGMENT_BLANK.replace('{{fieldName}}', 
                                        Utility.getLabelForSegmentFieldApi(SimpplrContext.segmentColumnName))
										.replace('{{fieldValue}}', segmentFieldNameValue);
	            				args.put('flash', prepareMessage('warning', message));
	            			
                            } else {
	            				// Dont let the App Manager to lock himself
	            				throw new SimpplrException(STR_ERROR_PROFILE_SEGMENT_BLANK);
	            			}

	            		}

		            }
                    Map<String,String> customFieldToProfileFieldValueMap = new Map<String,String>();
                    if (profileWrapper.customUserFieldList != null && profileWrapper.customUserFieldList.size() > 0) {
						
                        if (UserContext.Id.equalsIgnoreCase(people.User__c) || (UserContext.isUserAppModerator && UserContext.canManageInternalUsers)) {
							
                            for (MySettingsWrapper.CustomUserFields customFieldDetails : profileWrapper.customUserFieldList) {
								
                                if ('true'.equalsIgnoreCase(customFieldDetails.isEditable)) {

                                    if ('string'.equalsIgnoreCase(customFieldDetails.fieldType) || 
                                            'url'.equalsIgnoreCase(customFieldDetails.fieldType)) {
										        String profileFieldValue = String.isNotBlank(customFieldDetails.stringFieldValue) ? Utility.getSanitizedHTMLfromLambda(customFieldDetails.stringFieldValue) : '';
                                                customFieldToProfileFieldValueMap.put(customFieldDetails.fieldName, profileFieldValue);
                                    }
                                }
                            }
                        }
                    }
		            
	            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	            	logger.logDebug('MySettingDataServer.saveProfileSetting()----updating profile info----');
					SIMPESAPI.accessController().updateAsUser(people,new List<Schema.SObjectField>{
							People__c.First_Name__c, People__c.Last_Name__c, People__c.Title__c,
							People__c.Department__c, People__c.Manager__c, People__c.People_Category__c,
							People__c.Phone__c, People__c.About__c,
                            People__c.Raw_City__c, People__c.Raw_Country__c, People__c.Raw_State__c, People__c.Location_Normalization_Status__c,
							People__c.extension__c, People__c.mobile_phone__c, People__c.city__c,People__c.Street__c,
							People__c.state__c, People__c.country__c, People__c.Joining_Date__c, People__c.Birth_Date__c,
							People__c.Company_Name__c, People__c.Division__c, People__c.Zoom_Id__c, People__c.Skype_Id__c
							});
					User thisUser = new User(Id = people.User__c);
					Boolean updateUserRequired = false;

					if ((SimpplrContext.isPPTimezoneDisplay && 
                            SimpplrContext.isPPTimezoneEditable && 
                            UserContext.Id.equalsIgnoreCase(people.User__c)) || 
						    (UserContext.isUserAppModerator && 
                            (UserContext.Id.equalsIgnoreCase(people.User__c) || 
                            UserContext.canManageInternalUsers))) {
						thisUser.TimezoneSidKey = profileWrapper.timeZone; 
                        userObjectFieldList.add(User.TimezoneSidKey);

						updateUserRequired = true;
                        
                        if(String.isNotBlank(profileWrapper.timeZone)) {
                            TimeZone tz = Timezone.getTimeZone(profileWrapper.timeZone);
                            profileWrapper.timezoneName = Utility.timezoneIdToDisplayLabel(profileWrapper.timeZone);
                            profileWrapper.timezoneIso = tz.getID();
                            profileWrapper.timezoneOffset = tz.getOffset(system.today());
                        }
					}                    
                    String salesforceLanguageLocaleKey = Utility.getSimpplrLanguageLocaleKey(peopleList[0].User__r.languagelocalekey).replace('_', '-');

					if (String.isNotBlank(profileWrapper.simpplrLanguageLocaleKey) && 
						    (profileWrapper.simpplrLanguageLocaleKey.equalsIgnoreCase(salesforceLanguageLocaleKey)) == false) {
						
                        if ((SimpplrContext.isPPLanguageDisplay && 
                                SimpplrContext.isPPLanguageEditable && 
                                UserContext.Id.equalsIgnoreCase(people.User__c)) || 
							    (UserContext.isUserAppModerator && 
                                (UserContext.Id.equalsIgnoreCase(people.User__c) || UserContext.canManageInternalUsers))) {
							
							Map<String, String> mapOfLanguage = new Map<String, String> {
                                'en-US' => 'en_US', 'en-GB' => 'en_GB', 'es-ES'	=> 'es', 'fr-FR' => 'fr', 'fr-CA' => 'fr_CA',
                                'it-IT' => 'it',    'de-DE' => 'de',    'ja-JP' => 'ja', 'pt-BR' => 'pt_BR',
                                'da-DA' => 'da',    'hy-AM' => 'hy',    'bg-BG' => 'bg', 'el-GR' => 'el',
                                'nl-NL' => 'nl_NL', 'ms-MY' => 'ms',    'th-TH' => 'th', 'ro-RO' => 'ro', 'zh-CN' => 'zh_CN'
							};
							thisUser.languageLocaleKey = mapOfLanguage.get(profileWrapper.simpplrLanguageLocaleKey); 
                            userObjectFieldList.add(User.languageLocaleKey);

							updateUserRequired = true;
						}

					}

					if (profileWrapper.customUserFieldList != null && profileWrapper.customUserFieldList.size() > 0) {
						
                        if (UserContext.Id.equalsIgnoreCase(people.User__c) || (UserContext.isUserAppModerator && UserContext.canManageInternalUsers)) {
							
                            Map<String, Schema.SobjectField> nameVsObjectFieldApiPeopleObjMap = Utility.getFieldMapByObjectName(SimpplrContext.namespacePrefix + 'People__c');
                            Map<String, Schema.SobjectField> nameVsObjectFieldApiUserObjMap = Utility.getFieldMapByObjectName('User');

                            for (MySettingsWrapper.CustomUserFields customFieldDetails : profileWrapper.customUserFieldList) {
								
                                if ('true'.equalsIgnoreCase(customFieldDetails.isEditable)) {
									
                                    if ('multipicklist'.equalsIgnoreCase(customFieldDetails.fieldType)) {
                                        String multipicklistValue;
                                        String stringFieldValue;
										
                                        if (customFieldDetails.listOfMultiPickListFieldKeys != null) {
											String separator = ''; 
											multipicklistValue = '';
											
                                            for (String key : customFieldDetails.listOfMultiPickListFieldKeys) {
												multipicklistValue += (separator + key);
                                                separator = ';';
                                                stringFieldValue = key + ' ';
											}

										}

                                        thisUser.put(customFieldDetails.fieldName, multipicklistValue);
                                        people.put(SimpplrContext.namespacePrefix + customFieldDetails.columnName, stringFieldValue == null ?  null : stringFieldValue.left(255));
										
									} else if ('date'.equalsIgnoreCase(customFieldDetails.fieldType)) {
										Date customDateValue = String.isNotBlank(customFieldDetails.stringFieldValue) ? Utility.stringToDate(customFieldDetails.stringFieldValue) : null;
										thisUser.put(customFieldDetails.fieldName, customDateValue);
										
									} else if ('string'.equalsIgnoreCase(customFieldDetails.fieldType) || 
                                            'url'.equalsIgnoreCase(customFieldDetails.fieldType)) {
										String profileFieldValue = customFieldToProfileFieldValueMap.containsKey(customFieldDetails.fieldName) && !String.isEmpty(customFieldToProfileFieldValueMap.get(customFieldDetails.fieldName)) ? customFieldToProfileFieldValueMap.get(customFieldDetails.fieldName) : null;
                                        thisUser.put(customFieldDetails.fieldName, profileFieldValue);
                                        people.put(SimpplrContext.namespacePrefix + customFieldDetails.columnName, profileFieldValue);
										
									} else {
										thisUser.put(customFieldDetails.fieldName, customFieldDetails.stringFieldValue);
                                        people.put(SimpplrContext.namespacePrefix + customFieldDetails.columnName, customFieldDetails.stringFieldValue);
                                        logger.logDebug('MySettingDataServer.saveProfileSetting()----profile info has been updated----' + customFieldDetails.fieldName);
										logger.logDebug('MySettingDataServer.saveProfileSetting()----profile info has been updated----' + customFieldDetails.stringFieldValue);
									}
                                    
                                    peopleObjectFieldList.add(nameVsObjectFieldApiPeopleObjMap.get(SimpplrContext.namespacePrefix + customFieldDetails.columnName));
                                    userObjectFieldList.add(nameVsObjectFieldApiUserObjMap.get(customFieldDetails.fieldName));
									updateUserRequired = true;
								}

							}

						}

					}

					if (updateUserRequired && !Test.isRunningTest()) {

                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                        SIMPESAPI.accessController().updateAsUser(thisUser, userObjectFieldList);
					}
                    people.Last_Edited_DateTime__c = DateTime.now();
                    peopleObjectFieldList.add(People__c.Last_Edited_DateTime__c);

                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().updateAsUser(people, peopleObjectFieldList);

                    profileWrapper.location = Utility.buildLocation(people.City__c, people.State__c, people.Country__c);
																				
	            	logger.logDebug('MySettingDataServer.saveProfileSetting()----profile info has been updated----');
	            }

            }
            
            args.put('peopleId', profileWrapper.peopleId);
            args.put('ts', String.valueOf(dateTime.now().getTime()));
            
            String linkUrl = PageContext.getPageURL(Pages.MySettingsProfile, args);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, message, profileWrapper);
            responseWrapperObj.redirectUrl = linkUrl;

        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save profile info', e);
        	
            if (e.getMessage().containsIgnoreCase('INVALID_EMAIL_ADDRESS')) {
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ERROR_NOT_PERFORMING_ACTION, null);
           
            } else if (e.getMessage().containsIgnoreCase('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST')){
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_LANGUAGE_NOT_ENABLED, null);
            
            } else {
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);
            }

        }
        
        return responseWrapperObj;
    }
    
	private String prepareMessage(String type, String message) {
		Map<String, String> messageMap = new Map<String, String>();
		messageMap.put('type', type);
		messageMap.put('message', message);
		return JSON.serialize(messageMap);
    }
    
    private MySettingsWrapper.ProfileWrapper getProfileSettingsWrapper(){
    	MySettingsWrapper.ProfileWrapper profilePrefObj = new MySettingsWrapper.ProfileWrapper();    	
    	Boolean syncDisabled = ('None'.equalsIgnoreCase(SimpplrContext.PDSSourceApplication));    	
    	
        if (UserContext.isUserAppModerator) {
    		
            if (syncDisabled) {
	    		profilePrefObj.firstNameEditable = true;
				profilePrefObj.lastNameEditable = true;
				profilePrefObj.titleEditable = true;
				profilePrefObj.departmentEditable = true;
				profilePrefObj.managerEditable = true;
				profilePrefObj.aboutMeEditable = true;
				profilePrefObj.phoneEditable = true;
				profilePrefObj.extensionEditable = true;
				profilePrefObj.mobileEditable = true;
				profilePrefObj.cityEditable = true;
				profilePrefObj.stateEditable = true;
				profilePrefObj.streetEditable = true;
				profilePrefObj.countryEditable = true;
				profilePrefObj.birthDateEditable = true;
				profilePrefObj.joiningDateEditable = true;
				profilePrefObj.companyNameEditable = true;
				profilePrefObj.divisionEditable = true;

    		} else {
    			profilePrefObj.firstNameEditable = !SimpplrContext.isPDSFirstName;
				profilePrefObj.lastNameEditable = !SimpplrContext.isPDSLastName;
				profilePrefObj.titleEditable = !SimpplrContext.isPDSTitle;
				profilePrefObj.departmentEditable = !SimpplrContext.isPDSDepartment;
				profilePrefObj.managerEditable = !SimpplrContext.isPDSManagerId;
				profilePrefObj.aboutMeEditable = !SimpplrContext.isPDSAboutMe;
				profilePrefObj.phoneEditable = !SimpplrContext.isPDSPhone;
				profilePrefObj.extensionEditable = !SimpplrContext.isPDSExtension;
				profilePrefObj.mobileEditable = !SimpplrContext.isPDSMobilePhone;
				profilePrefObj.cityEditable = !SimpplrContext.isPDSCity;
				profilePrefObj.stateEditable = !SimpplrContext.isPDSState;
				profilePrefObj.streetEditable = !SimpplrContext.isPDSStreet;
				profilePrefObj.countryEditable = !SimpplrContext.isPDSCountry;
				profilePrefObj.birthDateEditable = !SimpplrContext.isPDSBirthDate;
				profilePrefObj.joiningDateEditable = !SimpplrContext.isPDSJoiningDate;
				profilePrefObj.companyNameEditable = !SimpplrContext.isPDSCompanyName;
				profilePrefObj.divisionEditable = !SimpplrContext.isPDSDivision;
    		}

    		profilePrefObj.timeZoneEditable = true;// TZ is not sysnced
			profilePrefObj.peopleCategoryEditable = SimpplrContext.isPeopleCategoryEnable;// people catgeory is never synced// if it is enabled add check
			profilePrefObj.zoomEditable = true;  // zoom /video ID is not sysnced
			profilePrefObj.skypeEditable = true; // skype/video ID is not sysnced
			
    	} else {
	    	
            if (syncDisabled) {
				profilePrefObj.firstNameEditable = SimpplrContext.isPPFirstNameEditable && SimpplrContext.isPPFirstNameDisplay;
				profilePrefObj.lastNameEditable = SimpplrContext.isPPLastNameEditable && SimpplrContext.isPPLastNameDisplay;
				profilePrefObj.titleEditable = SimpplrContext.isPPTitleEditable && SimpplrContext.isPPTitleDisplay;
				profilePrefObj.departmentEditable = SimpplrContext.isPPDepartmentEditable && SimpplrContext.isPPDepartmentDisplay;
				profilePrefObj.managerEditable = SimpplrContext.isPPManagerEditable && SimpplrContext.isPPManagerDisplay;
				profilePrefObj.aboutMeEditable = SimpplrContext.isPPAboutMeEditable && SimpplrContext.isPPAboutMeDisplay;
				profilePrefObj.phoneEditable = SimpplrContext.isPPPhoneEditable && SimpplrContext.isPPPhoneDisplay;
				profilePrefObj.extensionEditable = SimpplrContext.isPPExtensionEditable && SimpplrContext.isPPExtensionDisplay;
				profilePrefObj.mobileEditable = SimpplrContext.isPPMobilePhoneEditable && SimpplrContext.isPPMobilePhoneDisplay;
				profilePrefObj.cityEditable = SimpplrContext.isPPCityEditable && SimpplrContext.isPPCityDisplay;
				profilePrefObj.streetEditable = SimpplrContext.isPPStreetEditable && SimpplrContext.isPPStreetDisplay;
				profilePrefObj.stateEditable = SimpplrContext.isPPStateEditable && SimpplrContext.isPPStateDisplay;
				profilePrefObj.countryEditable = SimpplrContext.isPPCountryEditable && SimpplrContext.isPPCountryDisplay;
				profilePrefObj.birthDateEditable = SimpplrContext.isPPBirthDateEditable && SimpplrContext.isPPBirthDateDisplay;
				profilePrefObj.joiningDateEditable = SimpplrContext.isPPJoiningDateEditable && SimpplrContext.isPPJoiningDateDisplay;
				profilePrefObj.companyNameEditable = SimpplrContext.isPPCompanyNameEditable && SimpplrContext.isPPCompanyNameDisplay;
				profilePrefObj.divisionEditable = SimpplrContext.isPPDivisionEditable && SimpplrContext.isPPDivisionDisplay;
		
        	} else {
				profilePrefObj.firstNameEditable = !SimpplrContext.isPDSFirstName && SimpplrContext.isPPFirstNameEditable && SimpplrContext.isPPFirstNameDisplay;
				profilePrefObj.lastNameEditable = !SimpplrContext.isPDSLastName && SimpplrContext.isPPLastNameEditable && SimpplrContext.isPPLastNameDisplay;
				profilePrefObj.titleEditable = !SimpplrContext.isPDSTitle && SimpplrContext.isPPTitleEditable && SimpplrContext.isPPTitleDisplay;
				profilePrefObj.departmentEditable = !SimpplrContext.isPDSDepartment && SimpplrContext.isPPDepartmentEditable && SimpplrContext.isPPDepartmentDisplay;
				profilePrefObj.managerEditable = !SimpplrContext.isPDSManagerId && SimpplrContext.isPPManagerEditable && SimpplrContext.isPPManagerDisplay;
				profilePrefObj.aboutMeEditable = !SimpplrContext.isPDSAboutMe && SimpplrContext.isPPAboutMeEditable && SimpplrContext.isPPAboutMeDisplay;
				profilePrefObj.phoneEditable = !SimpplrContext.isPDSPhone && SimpplrContext.isPPPhoneEditable && SimpplrContext.isPPPhoneDisplay;
				profilePrefObj.extensionEditable = !SimpplrContext.isPDSExtension && SimpplrContext.isPPExtensionEditable && SimpplrContext.isPPExtensionDisplay;
				profilePrefObj.mobileEditable = !SimpplrContext.isPDSMobilePhone && SimpplrContext.isPPMobilePhoneEditable && SimpplrContext.isPPMobilePhoneDisplay;
				profilePrefObj.cityEditable = !SimpplrContext.isPDSCity && SimpplrContext.isPPCityEditable && SimpplrContext.isPPCityDisplay;
				profilePrefObj.streetEditable = !SimpplrContext.isPDSStreet && SimpplrContext.isPPStreetEditable && SimpplrContext.isPPStreetDisplay;
				profilePrefObj.stateEditable = !SimpplrContext.isPDSState && SimpplrContext.isPPStateEditable && SimpplrContext.isPPStateDisplay;
				profilePrefObj.countryEditable = !SimpplrContext.isPDSCountry && SimpplrContext.isPPCountryEditable && SimpplrContext.isPPCountryDisplay;
				profilePrefObj.birthDateEditable = !SimpplrContext.isPDSBirthDate && SimpplrContext.isPPBirthDateEditable && SimpplrContext.isPPBirthDateDisplay;
				profilePrefObj.joiningDateEditable = !SimpplrContext.isPDSJoiningDate && SimpplrContext.isPPJoiningDateEditable && SimpplrContext.isPPJoiningDateDisplay;
				profilePrefObj.companyNameEditable = !SimpplrContext.isPDSCompanyName && SimpplrContext.isPPCompanyNameEditable && SimpplrContext.isPPCompanyNameDisplay;
				profilePrefObj.divisionEditable = !SimpplrContext.isPDSDivision && SimpplrContext.isPPDivisionEditable && SimpplrContext.isPPDivisionDisplay;
			}

			profilePrefObj.peopleCategoryEditable =  SimpplrContext.isPeopleCategoryEnable && SimpplrContext.isPPCategoryDisplay && SimpplrContext.isPPCategoryEditable;// people catgeory is never synced 
			profilePrefObj.timeZoneEditable = SimpplrContext.isPPTimezoneDisplay && SimpplrContext.isPPTimezoneEditable;// TZ is not sysnced
			profilePrefObj.zoomEditable = SimpplrContext.isPPVideoDisplay && SimpplrContext.isPPVideoEditable;// zoom/video ID is not sysnced
			profilePrefObj.skypeEditable = SimpplrContext.isPPVideoDisplay && SimpplrContext.isPPVideoEditable;// zoom/video ID is not sysnced
    	}
    	
    	return profilePrefObj;
    }

    private People__c toPeople (People__c people, MySettingsWrapper.ProfileWrapper profileWrapper) {
    	MySettingsWrapper.ProfileWrapper profileSettingWrap = getProfileSettingsWrapper();     	
		
        if (String.isNotBlank(profileWrapper.manager) && String.isNotBlank(String.valueOf(people.user__c))) {
		
        	if ((String.valueOf(people.Id)).equalsIgnoreCase(profileWrapper.manager)) {
				throw new SimpplrException(ExceptionCode.CAN_NOT_ADD_YOURSELF_AS_MANAGER.name());
			}

	    }

		people.First_Name__c = profileSettingWrap.firstNameEditable ? profileWrapper.firstName : people.First_Name__c;
    	people.Last_Name__c = profileSettingWrap.lastNameEditable ? profileWrapper.lastName : people.Last_Name__c;
    	people.Title__c = profileSettingWrap.titleEditable ? profileWrapper.title : people.Title__c;
    	people.Department__c = profileSettingWrap.departmentEditable ? profileWrapper.department : people.Department__c;
        people.Manager__c = profileSettingWrap.managerEditable ? profileWrapper.manager : people.Manager__c;
    	
        if (profileSettingWrap.aboutMeEditable) {
    		people.About__c =  profileWrapper.aboutMe;
        }

    	people.Phone__c = profileSettingWrap.phoneEditable ? profileWrapper.phone : people.Phone__c;
    	people.extension__c = profileSettingWrap.extensionEditable ? profileWrapper.extension : people.extension__c;
    	people.mobile_phone__c = profileSettingWrap.mobileEditable ? profileWrapper.mobile : people.mobile_phone__c;
    	people.city__c = profileSettingWrap.cityEditable ? profileWrapper.city : people.city__c;
    	people.Street__c = profileSettingWrap.streetEditable? profileWrapper.street: people.Street__c;
    	people.state__c = profileSettingWrap.stateEditable ? profileWrapper.state : people.state__c;
    	people.country__c = profileSettingWrap.countryEditable ? profileWrapper.country : people.country__c;
    	people.People_Category__c = profileSettingWrap.peopleCategoryEditable ? profileWrapper.peopleCategoryId : people.People_Category__c;
    	people.User__r.TimeZoneSidKey = profileSettingWrap.timeZoneEditable ? profileWrapper.timeZone : people.User__r.TimeZoneSidKey;
			
		if (profileSettingWrap.joiningDateEditable){
			people.Joining_Date__c = String.isNotBlank(profileWrapper.joiningDate) ? Utility.stringToDate(profileWrapper.joiningDate) : null;
		
        } else {
			people.Joining_Date__c = people.Joining_Date__c;
		}
		
		Date birthDayDate = null;
		
        if (profileSettingWrap.birthDateEditable) {
			
            if (String.isNotBlank(profileWrapper.birthdayMonth) && String.isNotBlank(profileWrapper.birthdayDay)) {
				birthDayDate = Date.newInstance(1904, 
                        Integer.valueOf(profileWrapper.birthdayMonth), 
                        Integer.valueOf(profileWrapper.birthdayDay));

			}

		} else {
			birthDayDate = people.Birth_Date__c;
		}
		
		people.Last_Edited_DateTime__c = DateTime.now();
		people.Birth_Date__c = birthDayDate;
		people.Company_Name__c = profileSettingWrap.companyNameEditable ? profileWrapper.companyName : people.Company_Name__c;
		people.Division__c = profileSettingWrap.divisionEditable ? profileWrapper.division : people.Division__c;
		people.Zoom_Id__c = (profileSettingWrap.zoomEditable && ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) ? profileWrapper.zoomId : people.Zoom_Id__c;
		people.Skype_Id__c = (profileSettingWrap.skypeEditable && ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) ? profileWrapper.skypeId : people.Skype_Id__c;
        return people;
    }
    
    private ResponseWrapper saveEmailNotificationsSetting(String requestData) {
    	logger.logDebug('MySettingDataServer.saveEmailNotificationsSetting()----requestData----'+requestData);
        
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        
        try {
            String query = 'select Data__c, OverwriteBatchInProgress__c from App_Default__c where Type__c = \'email_notifications\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
	   		
            if (!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c) && 
                    listOfAppDefault[0].OverwriteBatchInProgress__c) {
	   			throw new SimpplrException(SETTINGS_UPDATED);
	   		} 
	   		        	
        	MySettingsWrapper.EmailNotificationWrapper notificationWrapper =  (MySettingsWrapper.EmailNotificationWrapper)Json.deserialize(requestData, MySettingsWrapper.EmailNotificationWrapper.class);
            List<People_Preference__c> notificationPrefList = [SELECT id, 
                    Allow_Simpplr_Emails__c, Receive_Content_Moderation_Notifications__c, 
            		Email_Shares_My_Post__c, Email_Private_Site_Membership_Requests__c, 
                    Email_PrivateSiteMembership_Response__c, 
            		Email_Notification_Digest_Frequency__c, Email_My_Content_Like_Or_Share__c, 
            		Email_My_Content_Rejected__c, Email_My_Content_Post__c, 
                    Email_My_Content_Approved__c, 
            		Email_Posts_To_Me__c, Email_Like_My_Post_Or_Comment__c, 
                    Email_Follows_Me__c, Email_Endorses_Me__c, 
            		Email_Digest_Frequency__c, Email_Content_Submitted_for_Moderation__c, 
                    Email_Content_Useful__c, Email_Content_Submission_Response__c, 
            		Email_Content_Digest_Frequency__c, Email_Comments_On_Post_I_Like__c, 
                    Email_Comments_On_My_Post__c, 
            		Email_Comments_After_Me__c, Email_Updates_Content_Sites_I_Follow__c, 
                    Email_Event_Invite_More__c,Email_Content_Marked_As_Must_Read__c,
            		Email_Site_Analytics_Frequency__c, 
                    Email_Subscription_Moderation__c, Email_My_Content_Validation_Expired__c, 
                    Email_My_Content_Validation_Required__c, Email_Product_Research__c,Email_Updates_Event_I_RSVP_Yes__c,
                    Email_Updates_Event_I_Author_Organize__c,Email_Alerts__c, Receive_Content_Update_Notifications__c,
                    Receive_Content_Useful_Notifications__c, Email_Subscription_Request__c, Email_QnA_New_Question__c,
                    Email_QnA_New_Answer__c, Email_QnA_Question_Mention__c, Email_QnA_Answer_Mention__c,
                    Email_QnA_Answer_Vote__c, Email_QnA_Answer_Approval__c, Email_QnA_New_Answer_Approval__c,
                    Email_QnA_Duplicate_Question__c, Email_QnA_New_Content_Question__c, Email_QnA_New_Content_Answer__c,
                    Email_CnI_Campaign_End__c, Email_CnI_Campaign_New__c, Email_CnI_Initiative_End__c, Email_CnI_Initiative_Start__c
        			FROM People_Preference__c 
                    WHERE People__r.Id =: notificationWrapper.peopleId WITH SECURITY_ENFORCED];

            if (!notificationPrefList.isEmpty() && notificationWrapper != null) {
	            People_Preference__c notiPreference = toEmailNotificationPreference(notificationPrefList[0], notificationWrapper);
	            
                if (notiPreference != null) {
	            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().updateAsUser(notiPreference, 
                            new List<Schema.SObjectField> {
                        People_Preference__c.Allow_Simpplr_Emails__c, 
                        People_Preference__c.Receive_Content_Moderation_Notifications__c, 
                        People_Preference__c.Email_Shares_My_Post__c, 
                        People_Preference__c.Email_Private_Site_Membership_Requests__c, 
                        People_Preference__c.Email_PrivateSiteMembership_Response__c, 
                        People_Preference__c.Email_Notification_Digest_Frequency__c, 
                        People_Preference__c.Email_My_Content_Like_Or_Share__c, 
                        People_Preference__c.Email_My_Content_Rejected__c, 
                        People_Preference__c.Email_My_Content_Post__c,  
                        People_Preference__c.Email_My_Content_Approved__c, 
                        People_Preference__c.Email_My_Content_Validation_Expired__c,
                        People_Preference__c.Email_My_Content_Validation_Required__c,
                        People_Preference__c.Email_Posts_To_Me__c, 
                        People_Preference__c.Email_Like_My_Post_Or_Comment__c, 
                        People_Preference__c.Email_Follows_Me__c, 
                        People_Preference__c.Email_Endorses_Me__c, 
                        People_Preference__c.Email_Digest_Frequency__c, 
                        People_Preference__c.Email_Content_Submitted_for_Moderation__c, 
                        People_Preference__c.Email_Content_Useful__c,
                        People_Preference__c.Email_Content_Submission_Response__c, 
                        People_Preference__c.Email_Content_Digest_Frequency__c, 
                        People_Preference__c.Email_Comments_On_Post_I_Like__c, 
                        People_Preference__c.Email_Comments_On_My_Post__c, 
                        People_Preference__c.Email_Comments_After_Me__c, 
                        People_Preference__c.Email_Updates_Content_Sites_I_Follow__c,
                        People_Preference__c.Email_Event_Invite_More__c,
                        People_Preference__c.Email_Content_Marked_As_Must_Read__c,
                        People_Preference__c.Email_Subscription_Moderation__c,
                        People_Preference__c.Email_Site_Analytics_Frequency__c,
                        People_Preference__c.Email_Product_Research__c,
                        People_Preference__c.Email_Updates_Event_I_RSVP_Yes__c,
                        People_Preference__c.Email_Updates_Event_I_Author_Organize__c,
                        People_Preference__c.Email_Alerts__c,
                        People_Preference__c.Email_Subscription_Request__c,
                        People_Preference__c.Email_QnA_New_Question__c,
                        People_Preference__c.Email_QnA_New_Answer__c,
                        People_Preference__c.Email_QnA_Question_Mention__c,
                        People_Preference__c.Email_QnA_Answer_Mention__c,
                        People_Preference__c.Email_QnA_Answer_Vote__c,
                        People_Preference__c.Email_QnA_Answer_Approval__c,
                        People_Preference__c.Email_QnA_New_Answer_Approval__c,
                        People_Preference__c.Email_QnA_Duplicate_Question__c,
                        People_Preference__c.Receive_Content_Update_Notifications__c,
                        People_Preference__c.Receive_Content_Useful_Notifications__c,
                        People_Preference__c.Email_QnA_New_Content_Question__c,
                        People_Preference__c.Email_QnA_New_Content_Answer__c,
                        People_Preference__c.Email_CnI_Campaign_End__c,
                        People_Preference__c.Email_CnI_Campaign_New__c,
                        People_Preference__c.Email_CnI_Initiative_End__c,
                        People_Preference__c.Email_CnI_Initiative_Start__c
                    });
                    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Email Notification Setting saved successfully!', notificationWrapper);
	            }

            } else {
                throw new SimpplrException('ERROR');
            }
        
        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save email notification settings',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        logger.logDebug('MySettingDataServer.saveEmailNotificationsSetting()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    private ResponseWrapper saveSummariesAndDigestSettings(String requestData) {
    	logger.logDebug('MySettingDataServer.saveSummariesAndDigestSettings()----requestData----'+requestData);
        
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        
        try {
            String query = 'select Data__c, OverwriteBatchInProgress__c from App_Default__c where Type__c = \'summaries_and_digest\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
	   		
            if (!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c) && 
                    listOfAppDefault[0].OverwriteBatchInProgress__c) {
	   			throw new SimpplrException(SETTINGS_UPDATED);
	   		} 
	   		        	
            MySettingsWrapper.SummariesAndDigestWrapper notificationWrapper =  (MySettingsWrapper.SummariesAndDigestWrapper)Json.deserialize(requestData, 
                    MySettingsWrapper.SummariesAndDigestWrapper.class);
            
            if (UserContext.emailProductResearch != notificationWrapper.emailProductResearch) {
                NotificationDispatcher notifObj = new NotificationDispatcher();
                
                // If user choose for product research 
                if (notificationWrapper.emailProductResearch) {
                    notifObj.addContactToSendInBlue();

                // If user don't want to participate in product research
                } else {
                    notifObj.removeContactFromSendInBlue();
                }
                
            }
            
            List<People_Preference__c> notificationPrefList = [SELECT id, 
                    Email_Product_Research__c, Email_Digest_Frequency__c, 
                    Email_Content_Digest_Frequency__c, Email_Site_Analytics_Frequency__c, Email_Onboarding_Frequency__c
        			FROM People_Preference__c 
                    WHERE People__r.Id =: notificationWrapper.peopleId WITH SECURITY_ENFORCED];

            if (!notificationPrefList.isEmpty() && notificationWrapper != null) {
	            People_Preference__c notiPreference = toSummariesAndDigestPreference(notificationPrefList[0], notificationWrapper);
	            
                if (notiPreference != null) {
	            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().updateAsUser(notiPreference, 
                            new List<Schema.SObjectField> {
                        People_Preference__c.Email_Site_Analytics_Frequency__c, 
                        People_Preference__c.Email_Digest_Frequency__c, 
                        People_Preference__c.Email_Content_Digest_Frequency__c, 
                        People_Preference__c.Email_Product_Research__c,
                        People_Preference__c.Email_Onboarding_Frequency__c
                    });

	            }

            }

	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'SummariesAndDigest Setting saved successfully!', notificationWrapper);
        
        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save SummariesAndDigest settings',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        logger.logDebug('MySettingDataServer.SummariesAndDigest()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    private People_Preference__c toSummariesAndDigestPreference(People_Preference__c notificationPref , 
            MySettingsWrapper.SummariesAndDigestWrapper notificationPrefWrapper) { 
		notificationPref.Email_Content_Digest_Frequency__c  = notificationPrefWrapper.topStoriesFrequency;
		notificationPref.Email_Digest_Frequency__c  =notificationPrefWrapper.digestFrequency; 
        notificationPref.Email_Site_Analytics_Frequency__c = notificationPrefWrapper.siteAnalyticsFrequency;
        notificationPref.Email_Product_Research__c = notificationPrefWrapper.emailProductResearch;
        notificationPref.Email_Onboarding_Frequency__c = notificationPrefWrapper.emailOnboardingFrequency;
        return notificationPref;
    }

    private ResponseWrapper saveSMSNotificationsSettings(String requestData) {
    	logger.logDebug('MySettingDataServer.saveSMSNotificationsSettings()----requestData----'+requestData);
        
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        
        try {
            String query = 'select Data__c, OverwriteBatchInProgress__c from App_Default__c where Type__c = \'sms_notifications\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
	   		
            if (!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c) && 
                    listOfAppDefault[0].OverwriteBatchInProgress__c) {
	   			throw new SimpplrException(SETTINGS_UPDATED);
	   		} 
	   		        	
        	MySettingsWrapper.SMSNotificationsWrapper notificationWrapper =  (MySettingsWrapper.SMSNotificationsWrapper)Json.deserialize(requestData, MySettingsWrapper.SMSNotificationsWrapper.class);
                List<People_Preference__c> notificationPrefList = [SELECT id, SMS_Alerts__c, SMS_Must_Reads__c, SMS_Content_Promotion_Message__c
                    FROM People_Preference__c 
                    WHERE People__r.Id =: notificationWrapper.peopleId WITH SECURITY_ENFORCED];

            if (!notificationPrefList.isEmpty() && notificationWrapper != null) {
	            People_Preference__c notiPreference = toSMSNotificationPreference(notificationPrefList[0],notificationWrapper);
	            
                if (notiPreference != null) {
	            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().updateAsUser(notiPreference, 
                            new List<Schema.SObjectField> {
                            People_Preference__c.SMS_Alerts__c,
                            People_Preference__c.SMS_Must_Reads__c,
                            People_Preference__c.SMS_Content_Promotion_Message__c
                    });

	            }

            }

	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'SMS Notification Setting saved successfully!', notificationWrapper);
        
        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save sms notification settings',e);
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        logger.logDebug('MySettingDataServer.saveSMSNotificationsSettings()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    private People_Preference__c toSMSNotificationPreference(People_Preference__c notificationPref , 
        MySettingsWrapper.SMSNotificationsWrapper notificationPrefWrapper) {
        notificationPref.SMS_Alerts__c  = notificationPrefWrapper.smsAlerts == null ? false : notificationPrefWrapper.smsAlerts;
        notificationPref.SMS_Must_Reads__c  = notificationPrefWrapper.smsContentMarkedAsMustRead == null ? false : notificationPrefWrapper.smsContentMarkedAsMustRead;
        notificationPref.SMS_Content_Promotion_Message__c  = notificationPrefWrapper.smsContentPromotionMessage == null ? false : notificationPrefWrapper.smsContentPromotionMessage;
        
        return notificationPref;
    }
    
    private ResponseWrapper saveAppManagerNotificationsSetting(String requestData){
    	logger.logDebug('MySettingDataServer.saveAppManagerNotificationsSetting()----requestData----'+requestData);
    	String peopleId = null;
        
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        
        try {
            Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
            
            if (!requestDataMap.isEmpty() && requestDataMap.get('peopleId') != null) {
            	peopleId = String.valueOf(requestDataMap.get('peopleId'));
            }
            
            List<People_Preference__c> notificationPrefList = [SELECT id, 
                    Receive_Content_Moderation_Notifications__c, 
                    Receive_Content_Useful_Notifications__c, Receive_Content_Update_Notifications__c  
        			FROM People_Preference__c 
                    WHERE People__r.Id =:peopleId WITH SECURITY_ENFORCED];
            
            if (!notificationPrefList.isEmpty() && requestDataMap != null) {
            	List<Schema.SObjectField> fieldsToBeUpdated = new List<Schema.SObjectField>();
	            
                if (!requestDataMap.isEmpty()){
	          
                	if (requestDataMap.get('appManagerNotifications') != null) {
		            	notificationPrefList[0].Receive_Content_Moderation_Notifications__c = Boolean.valueOf(requestDataMap.get('appManagerNotifications'));
	            		fieldsToBeUpdated.add(People_Preference__c.Receive_Content_Moderation_Notifications__c);
	            	}

	            	if (requestDataMap.get('appManagerUsefulContentNotifications') != null) {
		            	notificationPrefList[0].Receive_Content_Useful_Notifications__c = Boolean.valueOf(requestDataMap.get('appManagerUsefulContentNotifications'));
	            		fieldsToBeUpdated.add(People_Preference__c.Receive_Content_Useful_Notifications__c);
	            	}

	            	if (requestDataMap.get('appManagerUpdateContentNotifications') != null) {
		            	notificationPrefList[0].Receive_Content_Update_Notifications__c = Boolean.valueOf(requestDataMap.get('appManagerUpdateContentNotifications'));
	            		fieldsToBeUpdated.add(People_Preference__c.Receive_Content_Update_Notifications__c);
	            	}	

	           	}

	           	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(notificationPrefList), fieldsToBeUpdated);
	           	
            }

	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'App Manager Notification Setting saved successfully!', null);
        
        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save app manager notification settings',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        logger.logDebug('MySettingDataServer.saveAppManagerNotificationsSetting()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    private ResponseWrapper saveMobileAppNotificationsSetting(String requestData) {
    	logger.logDebug('MySettingDataServer.saveMobileAppNotificationsSetting()----requestData----'+requestData);
        
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        
        try {
        	MySettingsWrapper.MobileNotificationWrapper notificationWrapper =  (MySettingsWrapper.MobileNotificationWrapper)Json.deserialize(requestData, MySettingsWrapper.MobileNotificationWrapper.class);
            List<People_Preference__c> notificationPrefList = [SELECT id, 
                    Mobile_Allow_Notifications__c, Mobile_Comments_After_Me__c, 
                    Mobile_Comments_On_My_Post__c, Mobile_Comments_On_Post_I_Like__c, 
                    Mobile_Content_Submitted_For_Moderation__c, 
                    Mobile_Updates_Content_Sites_I_Follow__c, Mobile_Event_Invite_More__c, 
                    Mobile_Content_Useful__c, Mobile_Endorses_Me__c, Mobile_Follows_Me__c, 
                    Mobile_Like_My_Post_Or_Comment__c, 
                    Mobile_Posts_To_Me__c, Mobile_My_Content_Approved__c, Mobile_My_Content_Post__c, 
                    Mobile_My_Content_Rejected__c,
                    Mobile_My_Content_Like_Or_Share__c, Mobile_Private_Site_Membership_Requests__c, 
                    Mobile_Shares_My_Post__c,
                    Mobile_Content_Submission_Response__c,Mobile_PrivateSiteMembership_Response__c, 
                    Mobile_Content_Marked_As_Must_Read__c
                    FROM People_Preference__c 
                    WHERE People__r.Id =: notificationWrapper.peopleId WITH SECURITY_ENFORCED];
                                            								
            if (!notificationPrefList.isEmpty() && notificationWrapper != null) {
	            People_Preference__c notiPreference = toMobileNotificationPreference(notificationPrefList[0],notificationWrapper);
	            
                if (notiPreference != null) {
	            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	            	logger.logDebug('MySettingDataServer.saveMobileAppNotificationsSetting()----saving mobile app notifications settings----');
					SIMPESAPI.accessController().updateAsUser(notiPreference, 
                            new List<Schema.SObjectField> {
                            People_Preference__c.Mobile_Allow_Notifications__c ,             
                            People_Preference__c.Mobile_Follows_Me__c ,                      
                            People_Preference__c.Mobile_Endorses_Me__c ,                              
                            People_Preference__c.Mobile_Like_My_Post_Or_Comment__c ,         
                            People_Preference__c.Mobile_Comments_On_My_Post__c ,             
                            People_Preference__c.Mobile_Comments_After_Me__c ,               
                            People_Preference__c.Mobile_Comments_On_Post_I_Like__c ,         
                            People_Preference__c.Mobile_Posts_To_Me__c ,                     
                            People_Preference__c.Mobile_Shares_My_Post__c ,                  
                            People_Preference__c.Mobile_Updates_Content_Sites_I_Follow__c,
                            People_Preference__c.Mobile_Event_Invite_More__c ,                 
                            People_Preference__c.Mobile_My_Content_Post__c ,                 
                            People_Preference__c.Mobile_My_Content_Like_Or_Share__c ,                
                            People_Preference__c.Mobile_Content_Submitted_For_Moderation__c ,
                            People_Preference__c.Mobile_Content_Useful__c,
                            People_Preference__c.Mobile_My_Content_Approved__c ,             
                            People_Preference__c.Mobile_My_Content_Rejected__c ,             
                            People_Preference__c.Mobile_Private_Site_Membership_Requests__c ,
                            People_Preference__c.Mobile_Content_Submission_Response__c,
                            People_Preference__c.Mobile_PrivateSiteMembership_Response__c,
                            People_Preference__c.Mobile_Content_Marked_As_Must_Read__c
                            });
				logger.logDebug('MySettingDataServer.saveMobileAppNotificationsSetting()----mobile app notifications settings has been saved----');
	            	
	            }

            }

	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Mobile Notification Setting saved successfully!', notificationWrapper);
        
        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save mobile app  notification settings',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        logger.logDebug('MySettingDataServer.saveMobileAppNotificationsSetting()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    
    private ResponseWrapper saveNativeMobileAppNotificationsSettings(String requestData) {
    	logger.logDebug('MySettingDataServer.saveNativeMobileAppNotificationsSetting()----requestData----'+requestData);
        
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        
        try {
        	MySettingsWrapper.NativeMobileNotificationWrapper notificationWrapper =  (MySettingsWrapper.NativeMobileNotificationWrapper)Json.deserialize(requestData, MySettingsWrapper.NativeMobileNotificationWrapper.class);
            List<People_Preference__c> notificationPrefList = [SELECT id, 
                    Native_Mob_Content_Marked_As_Must_Read__c, Native_Mobile_Alerts__c, Native_Mob_Update_Content_Site_I_Follow__c, 
                    Native_Mobile_Follows_Me__c, Native_Mob_Endorse_Expertise__c, 
                    Native_Mob_Comments_On_My_Post__c, Native_Mob_Reply_After_Me__c, Native_Mob_Replied_On_liked_Post__c, Native_Mob_Like_My_Post_Or_Comment__c, Native_Mob_Shares_My_Post__c, Native_Mob_Posts_To_Me__c,
                    Native_MobPrivateSiteMembership_Resp__c,
                    Native_Mob_My_Content_Post__c, Native_Mobile_My_Content_Like_Or_Share__c, Native_Mob_Content_ApproveReject__c, 
                    Native_Mobile_Event_Invite_More__c,
                    Native_Mob_Private_Site_Membership_Req__c, Native_Mob_Content_Submit_Moderation__c, Native_Mobile_Surveys__c

                FROM People_Preference__c 
                WHERE People__r.Id =: notificationWrapper.peopleId WITH SECURITY_ENFORCED];
                                            								
            if (!notificationPrefList.isEmpty() && notificationWrapper != null) {
	            People_Preference__c notiPreference = toNativeMobileNotificationPreference(notificationPrefList[0],notificationWrapper);
	            
                if (notiPreference != null) {
	            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	            	logger.logDebug('MySettingDataServer.saveNativeMobileAppNotificationsSetting()----saving mobile app notifications settings----');
					SIMPESAPI.accessController().updateAsUser(notiPreference, 
                            new List<Schema.SObjectField>{
                            People_Preference__c.Native_Mob_Content_Marked_As_Must_Read__c,
                            People_Preference__c.Native_Mobile_Alerts__c,              
                            People_Preference__c.Native_Mob_Update_Content_Site_I_Follow__c,          
                            People_Preference__c.Native_Mobile_Follows_Me__c,
                            People_Preference__c.Native_Mob_Endorse_Expertise__c,
                            People_Preference__c.Native_Mob_Comments_On_My_Post__c,
                            People_Preference__c.Native_Mob_Reply_After_Me__c,
                            People_Preference__c.Native_Mob_Replied_On_liked_Post__c,
                            People_Preference__c.Native_Mob_Like_My_Post_Or_Comment__c,
                            People_Preference__c.Native_Mob_Shares_My_Post__c,
                            People_Preference__c.Native_Mob_Posts_To_Me__c,
                            People_Preference__c.Native_MobPrivateSiteMembership_Resp__c,
                            People_Preference__c.Native_Mob_My_Content_Post__c,
                            People_Preference__c.Native_Mobile_My_Content_Like_Or_Share__c,
                            People_Preference__c.Native_Mob_Content_ApproveReject__c,
                            People_Preference__c.Native_Mobile_Event_Invite_More__c,
                            People_Preference__c.Native_Mob_Private_Site_Membership_Req__c,
                            People_Preference__c.Native_Mob_Content_Submit_Moderation__c,
                            People_Preference__c.Native_Mobile_QnA_Question_Mention__c,
                            People_Preference__c.Native_Mobile_QnA_Answer_Mention__c,
                            People_Preference__c.Native_Mobile_QnA_Answer_Vote__c,
                            People_Preference__c.Native_Mobile_QnA_Answer_Approval__c,
                            People_Preference__c.Native_Mobile_QnA_New_Answer__c,
                            People_Preference__c.Native_Mobile_QnA_New_Answer_Approval__c,
                            People_Preference__c.Native_Mobile_QnA_Duplicate_Question__c,
                            People_Preference__c.Native_Mobile_QnA_New_Question__c,
                            People_Preference__c.Native_Mobile_QnA_New_Content_Question__c,
                            People_Preference__c.Native_Mobile_QnA_New_Content_Answer__c,
                            People_Preference__c.Native_Mobile_Surveys__c
                        });

				logger.logDebug('MySettingDataServer.saveNativeMobileAppNotificationsSetting()----mobile app notifications settings has been saved----');
	            }
            }

	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Native Mobile Notification Setting saved successfully!', notificationWrapper);
        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save native mobile app  notification settings',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        logger.logDebug('MySettingDataServer.saveNativeMobileAppNotificationsSetting()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    private ResponseWrapper saveUserWebPushConfig(String requestData) {
        logger.logDebug('MySettingDataServer.saveUserWebPushConfig()----requestData----'+requestData);
        
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();

        try {
            Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(requestData);
            
            String peopleId = UserContext.peopleId;
            String notificationOpted;
            String webPushToken;
            String userAgent;
            if (!requestDataMap.isEmpty()) {
                if(requestDataMap.get('notificationOpted') != null) {
                    notificationOpted = String.valueOf(requestDataMap.get('notificationOpted'));
                }
                if (requestDataMap.get('webPushToken') != null) {
                    webPushToken = String.valueOf(requestDataMap.get('webPushToken'));
                }
                if (requestDataMap.get('userAgent') != null) {
                    userAgent = String.valueOf(requestDataMap.get('userAgent'));
                }
            }

            if (String.isBlank(notificationOpted) || String.isBlank(webPushToken) || String.isBlank(userAgent)) {
                throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
            }

            List<People_Preference__c> notificationPrefList = [SELECT id, Allow_Browser_Notifications__c FROM People_Preference__c WHERE People__r.Id =: peopleId WITH SECURITY_ENFORCED];

            if(!notificationPrefList.isEmpty()) {
                People_Preference__c ppObj = notificationPrefList[0];
                ppObj.Allow_Browser_Notifications__c = notificationOpted;

                // Save user preference - Web push notifications
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().updateAsUser(ppObj, new List<Schema.SObjectField>{
                                People_Preference__c.Allow_Browser_Notifications__c
                });
            }

            // send info/details to Lambda
            if('Yes'.equalsIgnoreCase(notificationOpted)) {
                Utility.sendWebPushConfigInfoToLambda(peopleId, webPushToken, userAgent);
            }

        } catch (Exception e) {
            logger.logError('MySettingDataServer------could not save Browser notification settings',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        logger.logDebug('MySettingDataServer.saveUserWebPushConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    private ResponseWrapper saveBrowserNotificationsSettings(String requestData) {
    	logger.logDebug('MySettingDataServer.saveBrowserNotificationsSettings()----requestData----'+requestData);
        
        if (String.isBlank(requestData)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

        ResponseWrapper responseWrapperObj = new ResponseWrapper();
        
        try {
        	MySettingsWrapper.BrowserNotificationWrapper notificationWrapper =  (MySettingsWrapper.BrowserNotificationWrapper)Json.deserialize(requestData, MySettingsWrapper.BrowserNotificationWrapper.class);
            List<People_Preference__c> notificationPrefList = [SELECT id, 
                    Browser_Must_Read__c,Browser_Alerts__c,Browser_Update_Content_Site_I_Follow__c,Browser_Follows_Me__c,
                    Browser_Endorse_Expertise__c,Browser_Comments_On_My_Post__c,Browser_Comments_After_Me__c,
                    Browser_Comments_On_Liked_Post__c,Browser_Like_My_Post_Or_Comment__c,Browser_Shares_My_Post__c,
                    Browser_Posts_To_Me__c,Browser_Content_Validation_Required__c,Browser_Content_Validation_Expired__c,
                    Browser_Content_Comments_On_Published__c,Browser_Content_LikesShares_On_Published__c,
                    Browser_Content_Approval_Rejection__c,Browser_Content_Feedback__c,Browser_Event_Invite__c,
                    Browser_Event_Updates_Attending__c,Browser_Event_Updates_Authored_Organized__c,Browser_Site_Membership_Request__c,
                    Browser_Subscription_Submission__c,Browser_Content_Submission__c, Browser_PrivateSiteMembership_Resp__c,
                    Browser_QnA_Answer_Approval__c, Browser_QnA_Answer_Mention__c, Browser_QnA_Answer_Vote__c, Browser_QnA_Duplicate_Question__c,
                    Browser_QnA_New_Answer__c, Browser_QnA_New_Answer_Approval__c, Browser_QnA_New_Question__c, Browser_QnA_Question_Mention__c,
                    Browser_QnA_New_Content_Question__c, Browser_QnA_New_Content_Answer__c,
                    Browser_CnI_Campaign_End__c, Browser_CnI_Campaign_New__c, Browser_CnI_Initiative_End__c, Browser_CnI_Initiative_Start__c
                FROM People_Preference__c 
                WHERE People__r.Id =: notificationWrapper.peopleId WITH SECURITY_ENFORCED];
                                            								
            if (!notificationPrefList.isEmpty() && notificationWrapper != null) {
	            People_Preference__c notiPreference = toBrowserNotificationPreference(notificationPrefList[0],notificationWrapper);
	            
                if (notiPreference != null) {
	            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	            	logger.logDebug('MySettingDataServer.saveBrowserNotificationsSettings()----saving browser notifications settings----');
					SIMPESAPI.accessController().updateAsUser(notiPreference, 
                            new List<Schema.SObjectField>{
                            People_Preference__c.Browser_Must_Read__c,
                            People_Preference__c.Browser_Alerts__c,
                            People_Preference__c.Browser_Update_Content_Site_I_Follow__c,
                            People_Preference__c.Browser_Follows_Me__c,
                            People_Preference__c.Browser_Endorse_Expertise__c,
                            People_Preference__c.Browser_Comments_On_My_Post__c,
                            People_Preference__c.Browser_Comments_After_Me__c,
                            People_Preference__c.Browser_Comments_On_Liked_Post__c,
                            People_Preference__c.Browser_Like_My_Post_Or_Comment__c,
                            People_Preference__c.Browser_Shares_My_Post__c,
                            People_Preference__c.Browser_Posts_To_Me__c,
                            People_Preference__c.Browser_PrivateSiteMembership_Resp__c,
                            People_Preference__c.Browser_Content_Validation_Required__c,
                            People_Preference__c.Browser_Content_Validation_Expired__c,
                            People_Preference__c.Browser_Content_Comments_On_Published__c,
                            People_Preference__c.Browser_Content_LikesShares_On_Published__c,
                            People_Preference__c.Browser_Content_Approval_Rejection__c,
                            People_Preference__c.Browser_Content_Feedback__c,
                            People_Preference__c.Browser_Event_Invite__c,
                            People_Preference__c.Browser_Event_Updates_Attending__c,
                            People_Preference__c.Browser_Event_Updates_Authored_Organized__c,
                            People_Preference__c.Browser_Site_Membership_Request__c,
                            People_Preference__c.Browser_Subscription_Submission__c,
                            People_Preference__c.Browser_Content_Submission__c,
                            People_Preference__c.Browser_QnA_Answer_Approval__c,
                            People_Preference__c.Browser_QnA_Answer_Mention__c,
                            People_Preference__c.Browser_QnA_Answer_Vote__c,
                            People_Preference__c.Browser_QnA_Duplicate_Question__c,
                            People_Preference__c.Browser_QnA_New_Answer__c,
                            People_Preference__c.Browser_QnA_New_Answer_Approval__c,
                            People_Preference__c.Browser_QnA_New_Question__c,
                            People_Preference__c.Browser_QnA_Question_Mention__c,
                            People_Preference__c.Browser_QnA_New_Content_Question__c,
                            People_Preference__c.Browser_QnA_New_Content_Answer__c,
                            People_Preference__c.Browser_CnI_Campaign_End__c,
                            People_Preference__c.Browser_CnI_Campaign_New__c,
                            People_Preference__c.Browser_CnI_Initiative_End__c,
                            People_Preference__c.Browser_CnI_Initiative_Start__c

                        });

				logger.logDebug('MySettingDataServer.saveBrowserNotificationsSettings()----Browser notifications settings has been saved----');
	            }
            }

	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Browser Notification Setting saved successfully!', notificationWrapper);
        } catch (Exception e) {
        	logger.logError('MySettingDataServer------could not save Browser notification settings',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

        logger.logDebug('MySettingDataServer.saveBrowserNotificationsSettings()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    private People_Preference__c toEmailNotificationPreference(People_Preference__c notificationPref , 
            MySettingsWrapper.EmailNotificationWrapper notificationPrefWrapper) { 
        notificationPref.Allow_Simpplr_Emails__c  = 'disable'.equalsIgnoreCase(notificationPrefWrapper.allowSimpplrEmails) ? false : true;
		notificationPref.Email_Follows_Me__c  = notificationPrefWrapper.emailFollowsMe == null ? true : notificationPrefWrapper.emailFollowsMe;
		notificationPref.Email_Endorses_Me__c  = notificationPrefWrapper.emailEndorseExpertise == null ? true : notificationPrefWrapper.emailEndorseExpertise;
		notificationPref.Email_Like_My_Post_Or_Comment__c  = notificationPrefWrapper.emailLikesPostOrCommentMade == null ? true : notificationPrefWrapper.emailLikesPostOrCommentMade;
		notificationPref.Email_Comments_On_My_Post__c  = notificationPrefWrapper.emailCommentsPostMade == null ? true : notificationPrefWrapper.emailCommentsPostMade; 
		notificationPref.Email_Comments_After_Me__c  = notificationPrefWrapper.emailCommentsAfterMe == null ? true : notificationPrefWrapper.emailCommentsAfterMe;
		notificationPref.Email_Comments_On_Post_I_Like__c  = notificationPrefWrapper.emailCommentsPostLike == null ? true : notificationPrefWrapper.emailCommentsPostLike; 
		notificationPref.Email_Posts_To_Me__c  = notificationPrefWrapper.emailPostsToMe == null ? true : notificationPrefWrapper.emailPostsToMe;
		notificationPref.Email_Shares_My_Post__c  = notificationPrefWrapper.emailSharesPostMade == null ? true : notificationPrefWrapper.emailSharesPostMade; 
		notificationPref.Email_My_Content_Validation_Expired__c = notificationPrefWrapper.emailKnowledgeExpired == null ? true : notificationPrefWrapper.emailKnowledgeExpired;
		notificationPref.Email_My_Content_Validation_Required__c = notificationPrefWrapper.emailKnowledgeReview == null ? true : notificationPrefWrapper.emailKnowledgeReview;
		notificationPref.Email_My_Content_Post__c  = notificationPrefWrapper.emailCommentsContentPublished == null ? true : notificationPrefWrapper.emailCommentsContentPublished; 
		notificationPref.Email_My_Content_Like_Or_Share__c  = notificationPrefWrapper.emailLikesSharesContentPublished == null ? false : notificationPrefWrapper.emailLikesSharesContentPublished;
		notificationPref.Email_Event_Invite_More__c  = notificationPrefWrapper.emailEventInviteMore == null ? true : notificationPrefWrapper.emailEventInviteMore;
        notificationPref.Email_Updates_Event_I_RSVP_Yes__c = notificationPrefWrapper.emailUpdatesEventIRsvpYes == null ? true : notificationPrefWrapper.emailUpdatesEventIRsvpYes;
        notificationPref.Email_Updates_Event_I_Author_Organize__c = notificationPrefWrapper.emailUpdatesEventIAuthorOrganize == null ? true : notificationPrefWrapper.emailUpdatesEventIAuthorOrganize;
		notificationPref.Email_Updates_Content_Sites_I_Follow__c = notificationPrefWrapper.emailUpdatesContentSitesFollow == null ? false : notificationPrefWrapper.emailUpdatesContentSitesFollow;
        notificationPref.Email_Notification_Digest_Frequency__c = notificationPrefWrapper.emailNotificationFrequency;		
        
        notificationPref.Email_Private_Site_Membership_Requests__c = notificationPrefWrapper.emailPrivateSiteMembershipRequest == null ? false : notificationPrefWrapper.emailPrivateSiteMembershipRequest;
        notificationPref.Email_Content_Submitted_For_Moderation__c = notificationPrefWrapper.emailContentSubmittedForModeration == null ? false : notificationPrefWrapper.emailContentSubmittedForModeration;
        notificationPref.Email_Subscription_Request__c = notificationPrefWrapper.emailSubscriptionRequest == null ? false : notificationPrefWrapper.emailSubscriptionRequest;

		notificationPref.Email_Content_Useful__c  = notificationPrefWrapper.emailForContentUseful == null ? true : notificationPrefWrapper.emailForContentUseful;
		notificationPref.Email_My_Content_Approved__c = notificationPrefWrapper.emailContentSubmittedApproved == null ? true : notificationPrefWrapper.emailContentSubmittedApproved;
		notificationPref.Email_My_Content_Rejected__c = notificationPrefWrapper.emailContentSubmittedRejected == null ? true : notificationPrefWrapper.emailContentSubmittedRejected;	
		notificationPref.Email_Content_Submission_Response__c = notificationPrefWrapper.emailContentSubmissionResponse == null ? true : notificationPrefWrapper.emailContentSubmissionResponse;
		notificationPref.Email_PrivateSiteMembership_Response__c = notificationPrefWrapper.emailPrivateSiteMembershipResponse == null ? true : notificationPrefWrapper.emailPrivateSiteMembershipResponse;
		notificationPref.Email_Subscription_Moderation__c = notificationPrefWrapper.emailSubscriptionModeration == null ? true : notificationPrefWrapper.emailSubscriptionModeration;
		notificationPref.Email_Content_Marked_As_Must_Read__c = notificationPrefWrapper.emailContentMarkedAsMustRead == null ? true : notificationPrefWrapper.emailContentMarkedAsMustRead;
        notificationPref.Email_Alerts__c = notificationPrefWrapper.emailAlerts == null ? true : notificationPrefWrapper.emailAlerts;
        
        notificationPref.Email_QnA_New_Question__c = notificationPrefWrapper.emailQnANewQuestion == null ? true : notificationPrefWrapper.emailQnANewQuestion;
        notificationPref.Email_QnA_Question_Mention__c = notificationPrefWrapper.emailQnAQuestionMention == null ? true : notificationPrefWrapper.emailQnAQuestionMention;
        notificationPref.Email_QnA_Answer_Mention__c = notificationPrefWrapper.emailQnAAnswerMention == null ? true : notificationPrefWrapper.emailQnAAnswerMention;
        notificationPref.Email_QnA_Answer_Vote__c = notificationPrefWrapper.emailQnAVote == null ? true : notificationPrefWrapper.emailQnAVote;
        notificationPref.Email_QnA_Answer_Approval__c = notificationPrefWrapper.emailQnAAnswerApproval == null ? true : notificationPrefWrapper.emailQnAAnswerApproval;
        notificationPref.Email_QnA_New_Answer__c = notificationPrefWrapper.emailQnANewAnswer == null ? true : notificationPrefWrapper.emailQnANewAnswer;
        notificationPref.Email_QnA_New_Answer_Approval__c = notificationPrefWrapper.emailQnANewApprovedAnswer == null ? true : notificationPrefWrapper.emailQnANewApprovedAnswer;
        notificationPref.Email_QnA_Duplicate_Question__c = notificationPrefWrapper.emailQnADuplicateQuestion == null ? true : notificationPrefWrapper.emailQnADuplicateQuestion;
        notificationPref.Email_QnA_New_Content_Question__c = notificationPrefWrapper.emailForContentQuestion == null ? true : notificationPrefWrapper.emailForContentQuestion;
        notificationPref.Email_QnA_New_Content_Answer__c = notificationPrefWrapper.emailForContentAnswer == null ? true : notificationPrefWrapper.emailForContentAnswer;
        
        notificationPref.Email_CnI_Campaign_End__c = notificationPrefWrapper.emailCnIEndCampaign == null ? true : notificationPrefWrapper.emailCnIEndCampaign;
        notificationPref.Email_CnI_Campaign_New__c = notificationPrefWrapper.emailCnINewCampaign == null ? true : notificationPrefWrapper.emailCnINewCampaign;
        notificationPref.Email_CnI_Initiative_End__c = notificationPrefWrapper.emailCnIInitiativeEnd == null ? true : notificationPrefWrapper.emailCnIInitiativeEnd;
        notificationPref.Email_CnI_Initiative_Start__c = notificationPrefWrapper.emailCnIInitiativeStart == null ? true : notificationPrefWrapper.emailCnIInitiativeStart;

        notificationPref.Receive_Content_Update_Notifications__c = notificationPrefWrapper.emailContentPromotionMessageForAppMgr == null ? true : notificationPrefWrapper.emailContentPromotionMessageForAppMgr;
        notificationPref.Receive_Content_Moderation_Notifications__c = notificationPrefWrapper.emailSiteActionableForAppMgr;
        notificationPref.Receive_Content_Useful_Notifications__c = notificationPrefWrapper.emailForContentUsefulAppMgr == null ? true : notificationPrefWrapper.emailForContentUsefulAppMgr;
        return notificationPref;
    }
    
    private People_Preference__c toMobileNotificationPreference(People_Preference__c notificationPref ,MySettingsWrapper.MobileNotificationWrapper notificationPrefWrapper) {        
        notificationPref.Mobile_Allow_Notifications__c  = notificationPrefWrapper.mobileAppNotifications == null ? true : notificationPrefWrapper.mobileAppNotifications;
		notificationPref.Mobile_Follows_Me__c  = notificationPrefWrapper.mobileAppFollowsMe == null ? true : notificationPrefWrapper.mobileAppFollowsMe;
		notificationPref.Mobile_Endorses_Me__c  = notificationPrefWrapper.mobileAppEndorseExpertise == null ? true : notificationPrefWrapper.mobileAppEndorseExpertise;
		notificationPref.Mobile_Like_My_Post_Or_Comment__c  = notificationPrefWrapper.mobileAppLikesPostOrCommentMade == null ? true : notificationPrefWrapper.mobileAppLikesPostOrCommentMade;
		notificationPref.Mobile_Comments_On_My_Post__c  = notificationPrefWrapper.mobileAppCommentsPostMade == null ? true : notificationPrefWrapper.mobileAppCommentsPostMade;
		notificationPref.Mobile_Comments_After_Me__c  = notificationPrefWrapper.mobileAppCommentsAfterMe == null ? true : notificationPrefWrapper.mobileAppCommentsAfterMe;
		notificationPref.Mobile_Comments_On_Post_I_Like__c  = notificationPrefWrapper.mobileAppCommentsPostLike == null ? true : notificationPrefWrapper.mobileAppCommentsPostLike; 
		notificationPref.Mobile_Posts_To_Me__c  = notificationPrefWrapper.mobileAppPostsToMe == null ? true : notificationPrefWrapper.mobileAppPostsToMe;
		notificationPref.Mobile_Shares_My_Post__c  = notificationPrefWrapper.mobileAppSharesPostMade == null ? true : notificationPrefWrapper.mobileAppSharesPostMade;
		notificationPref.Mobile_My_Content_Post__c  = notificationPrefWrapper.mobileAppCommentsContentPublished == null ? true : notificationPrefWrapper.mobileAppCommentsContentPublished; 
		notificationPref.Mobile_My_Content_Like_Or_Share__c  = notificationPrefWrapper.mobileAppLikesOrSharesContentPublished == null ? true : notificationPrefWrapper.mobileAppLikesOrSharesContentPublished;
		notificationPref.Mobile_Event_Invite_More__c  = notificationPrefWrapper.mobileAppEventInviteMore == null ? true : notificationPrefWrapper.mobileAppEventInviteMore;
		notificationPref.Mobile_Updates_Content_Sites_I_Follow__c = notificationPrefWrapper.mobileAppUpdatesContentSitesFollow == null ? true : notificationPrefWrapper.mobileAppUpdatesContentSitesFollow;
		notificationPref.Mobile_Content_Submitted_For_Moderation__c  = notificationPrefWrapper.mobileAppContentSubmittedForModeration == null ? true : notificationPrefWrapper.mobileAppContentSubmittedForModeration;
		notificationPref.Mobile_Content_Useful__c  = notificationPrefWrapper.mobileAppContentUseful == null ? true : notificationPrefWrapper.mobileAppContentUseful;
		notificationPref.Mobile_My_Content_Approved__c  = notificationPrefWrapper.mobileAppContentSubmittedApproved == null ? true : notificationPrefWrapper.mobileAppContentSubmittedApproved;
		notificationPref.Mobile_My_Content_Rejected__c  = notificationPrefWrapper.mobileAppContentSubmittedRejected == null ? true : notificationPrefWrapper.mobileAppContentSubmittedRejected;
		notificationPref.Mobile_Private_Site_Membership_Requests__c  = notificationPrefWrapper.mobileAppPrivateSiteMembershipRequest == null ? true : notificationPrefWrapper.mobileAppPrivateSiteMembershipRequest;
		notificationPref.Mobile_Content_Submission_Response__c  = notificationPrefWrapper.mobileAppContentSubmissionResponse == null ? true : notificationPrefWrapper.mobileAppContentSubmissionResponse;
		notificationPref.Mobile_PrivateSiteMembership_Response__c  = notificationPrefWrapper.mobileAppPrivateSiteMembershipResponse == null ? true : notificationPrefWrapper.mobileAppPrivateSiteMembershipResponse;
		notificationPref.Mobile_Content_Marked_As_Must_Read__c  = notificationPrefWrapper.mobileAppContentMarkedAsMustRead == null ? true : notificationPrefWrapper.mobileAppContentMarkedAsMustRead;
		return notificationPref;
    }
    
    private People_Preference__c toNativeMobileNotificationPreference(People_Preference__c notificationPref ,MySettingsWrapper.NativeMobileNotificationWrapper notificationPrefWrapper) {
        //Org
        notificationPref.Native_Mob_Content_Marked_As_Must_Read__c = notificationPrefWrapper.mobileAppContentMarkedAsMustRead == null ? true : notificationPrefWrapper.mobileAppContentMarkedAsMustRead;
        notificationPref.Native_Mobile_Alerts__c = notificationPrefWrapper.mobileAppAlerts == null ? true : notificationPrefWrapper.mobileAppAlerts;
		notificationPref.Native_Mob_Update_Content_Site_I_Follow__c = notificationPrefWrapper.mobileAppUpdatesContentSitesFollow == null ? true : notificationPrefWrapper.mobileAppUpdatesContentSitesFollow;
        //Profile
        notificationPref.Native_Mobile_Follows_Me__c = notificationPrefWrapper.mobileAppFollowsMe == null ? true : notificationPrefWrapper.mobileAppFollowsMe;
        notificationPref.Native_Mob_Endorse_Expertise__c = notificationPrefWrapper.mobileAppEndorseExpertise == null ? true : notificationPrefWrapper.mobileAppEndorseExpertise;
        //Feed
        notificationPref.Native_Mob_Comments_On_My_Post__c = notificationPrefWrapper.mobileAppCommentsPostMade == null ? true : notificationPrefWrapper.mobileAppCommentsPostMade;
        notificationPref.Native_Mob_Reply_After_Me__c = notificationPrefWrapper.mobileAppReplyAfterMe == null ? true : notificationPrefWrapper.mobileAppReplyAfterMe;
        notificationPref.Native_Mob_Replied_On_liked_Post__c = notificationPrefWrapper.mobileAppReplyOnLikedPost == null ? true : notificationPrefWrapper.mobileAppReplyOnLikedPost;
		notificationPref.Native_Mob_Like_My_Post_Or_Comment__c = notificationPrefWrapper.mobileAppLikesPostOrCommentMade == null ? true : notificationPrefWrapper.mobileAppLikesPostOrCommentMade;
        notificationPref.Native_Mob_Shares_My_Post__c = notificationPrefWrapper.mobileAppSharesMyPost == null ? true : notificationPrefWrapper.mobileAppSharesMyPost;
        notificationPref.Native_Mob_Posts_To_Me__c  = notificationPrefWrapper.mobileAppPostsToMe == null ? true : notificationPrefWrapper.mobileAppPostsToMe;
        //Sites
        notificationPref.Native_MobPrivateSiteMembership_Resp__c = notificationPrefWrapper.mobileAppPrivateSiteMembershipResponse == null ? true : notificationPrefWrapper.mobileAppPrivateSiteMembershipResponse;
        //Content
		notificationPref.Native_Mob_My_Content_Post__c = notificationPrefWrapper.mobileAppCommentsContentPublished == null ? true : notificationPrefWrapper.mobileAppCommentsContentPublished;
        notificationPref.Native_Mobile_My_Content_Like_Or_Share__c = notificationPrefWrapper.mobileAppLikesOrSharesContentPublished == null ? true : notificationPrefWrapper.mobileAppLikesOrSharesContentPublished;
        notificationPref.Native_Mob_Content_ApproveReject__c = notificationPrefWrapper.mobileAppContentApprovalRejection == null ? true : notificationPrefWrapper.mobileAppContentApprovalRejection;
        //Events
        notificationPref.Native_Mobile_Event_Invite_More__c = notificationPrefWrapper.mobileAppEventInviteMore == null ? true : notificationPrefWrapper.mobileAppEventInviteMore;
        //Site Management
        notificationPref.Native_Mob_Private_Site_Membership_Req__c = notificationPrefWrapper.mobileAppPrivateSiteMembershipRequest == null ? true : notificationPrefWrapper.mobileAppPrivateSiteMembershipRequest;
		notificationPref.Native_Mob_Content_Submit_Moderation__c = notificationPrefWrapper.mobileAppContentSubmittedForModeration == null ? true : notificationPrefWrapper.mobileAppContentSubmittedForModeration;
        //Question Answer
        notificationPref.Native_Mobile_QnA_Question_Mention__c = notificationPrefWrapper.mobileQnAQuestionMention == null ? true : notificationPrefWrapper.mobileQnAQuestionMention;
        notificationPref.Native_Mobile_QnA_Answer_Mention__c = notificationPrefWrapper.mobileQnAAnswerMention == null ? true : notificationPrefWrapper.mobileQnAAnswerMention;
        notificationPref.Native_Mobile_QnA_Answer_Vote__c = notificationPrefWrapper.mobileQnAVote == null ? true : notificationPrefWrapper.mobileQnAVote;
        notificationPref.Native_Mobile_QnA_Answer_Approval__c = notificationPrefWrapper.mobileQnAAnswerApproval == null ? true : notificationPrefWrapper.mobileQnAAnswerApproval;
        notificationPref.Native_Mobile_QnA_New_Answer__c = notificationPrefWrapper.mobileQnANewAnswer == null ? true : notificationPrefWrapper.mobileQnANewAnswer;
        notificationPref.Native_Mobile_QnA_New_Answer_Approval__c = notificationPrefWrapper.mobileQnANewApprovedAnswer == null ? true : notificationPrefWrapper.mobileQnANewApprovedAnswer;
        notificationPref.Native_Mobile_QnA_Duplicate_Question__c = notificationPrefWrapper.mobileQnADuplicateQuestion == null ? true : notificationPrefWrapper.mobileQnADuplicateQuestion;
        notificationPref.Native_Mobile_QnA_New_Question__c = notificationPrefWrapper.mobileQnANewQuestion == null ? true : notificationPrefWrapper.mobileQnANewQuestion;
        notificationPref.Native_Mobile_QnA_New_Content_Question__c = notificationPrefWrapper.mobileAppContentQuestion == null ? true : notificationPrefWrapper.mobileAppContentQuestion;
        notificationPref.Native_Mobile_QnA_New_Content_Answer__c = notificationPrefWrapper.mobileAppContentAnswer == null ? true : notificationPrefWrapper.mobileAppContentAnswer;

        //survey
        notificationPref.Native_Mobile_Surveys__c = notificationPrefWrapper.mobileSurveys == null ? true : notificationPrefWrapper.mobileSurveys;
        return notificationPref;
    }

    private People_Preference__c toBrowserNotificationPreference(People_Preference__c notificationPref ,MySettingsWrapper.BrowserNotificationWrapper notificationPrefWrapper) {
        //Org
        notificationPref.Browser_Must_Read__c = notificationPrefWrapper.browserMustRead;
        notificationPref.Browser_Alerts__c = notificationPrefWrapper.browserAlerts;
        notificationPref.Browser_Update_Content_Site_I_Follow__c = notificationPrefWrapper.browserUpdatesContentSitesFollow;
        //Profile
        notificationPref.Browser_Follows_Me__c = notificationPrefWrapper.browserFollowsMe;
        notificationPref.Browser_Endorse_Expertise__c = notificationPrefWrapper.browserEndorseExpertise;
        //Feed
        notificationPref.Browser_Comments_On_My_Post__c = notificationPrefWrapper.browserReplyOnMyPost;
        notificationPref.Browser_Comments_After_Me__c = notificationPrefWrapper.browserReplyAfterMe;
        notificationPref.Browser_Comments_On_Liked_Post__c = notificationPrefWrapper.browserReplyOnLikedPost;
        notificationPref.Browser_Like_My_Post_Or_Comment__c = notificationPrefWrapper.browserLikesMyPostOrReply;
        notificationPref.Browser_Shares_My_Post__c = notificationPrefWrapper.browserSharesMyPost;
        notificationPref.Browser_Posts_To_Me__c = notificationPrefWrapper.browserPostsToMe;
        //Site
        notificationPref.Browser_PrivateSiteMembership_Resp__c  = notificationPrefWrapper.browserPrivateSiteMembershipResponse;
        //Content
        notificationPref.Browser_Content_Validation_Required__c = notificationPrefWrapper.browserContentValidationRequired;
        notificationPref.Browser_Content_Validation_Expired__c = notificationPrefWrapper.browserContentValidationExpired;
        notificationPref.Browser_Content_Comments_On_Published__c = notificationPrefWrapper.browserContentCommentsOnPublished;
        notificationPref.Browser_Content_LikesShares_On_Published__c = notificationPrefWrapper.browserContentLikesSharesOnPublished;
        notificationPref.Browser_Content_Approval_Rejection__c = notificationPrefWrapper.browserContentApprovalRejection;
        notificationPref.Browser_Content_Feedback__c = notificationPrefWrapper.browserContentFeedback;
        //Event
        notificationPref.Browser_Event_Invite__c = notificationPrefWrapper.browserEventInvite;
        notificationPref.Browser_Event_Updates_Attending__c = notificationPrefWrapper.browserEventUpdatesAttending;
        notificationPref.Browser_Event_Updates_Authored_Organized__c = notificationPrefWrapper.browserEventUpdatesAuthoredOrganized;
        //Site Management
        notificationPref.Browser_Site_Membership_Request__c = notificationPrefWrapper.browserPrivateSiteMembershipRequest;
        notificationPref.Browser_Subscription_Submission__c = notificationPrefWrapper.browserSubscriptionRequest;
        notificationPref.Browser_Content_Submission__c = notificationPrefWrapper.browserContentSubmittedForModeration;

        //Question Answer
        notificationPref.Browser_QnA_Answer_Approval__c = notificationPrefWrapper.browserQnAAnswerApproval;
        notificationPref.Browser_QnA_Answer_Mention__c = notificationPrefWrapper.browserQnAAnswerMention;
        notificationPref.Browser_QnA_Answer_Vote__c = notificationPrefWrapper.browserQnAVote;
        notificationPref.Browser_QnA_Duplicate_Question__c = notificationPrefWrapper.browserQnADuplicateQuestion;
        notificationPref.Browser_QnA_New_Answer__c = notificationPrefWrapper.browserQnANewAnswer;
        notificationPref.Browser_QnA_New_Answer_Approval__c = notificationPrefWrapper.browserQnANewApprovedAnswer;
        notificationPref.Browser_QnA_New_Question__c = notificationPrefWrapper.browserQnANewQuestion;
        notificationPref.Browser_QnA_Question_Mention__c = notificationPrefWrapper.browserQnAQuestionMention;
        notificationPref.Browser_QnA_New_Content_Question__c = notificationPrefWrapper.browserContentQuestion;
        notificationPref.Browser_QnA_New_Content_Answer__c = notificationPrefWrapper.browserContentAnswer;
        //Campaign & Initiative
        notificationPref.Browser_CnI_Campaign_End__c = notificationPrefWrapper.browserCnIEndCampaign;
        notificationPref.Browser_CnI_Campaign_New__c = notificationPrefWrapper.browserCnINewCampaign;
        notificationPref.Browser_CnI_Initiative_End__c = notificationPrefWrapper.browserCnIInitiativeEnd;
        notificationPref.Browser_CnI_Initiative_Start__c = notificationPrefWrapper.browserCnIInitiativeStart;

        return notificationPref;
    }

	private ResponseWrapper getExternalAppsSettings(string peopleId) {
		logger.logDebug('MySettingDataServer.getExternalAppsSettings()----peopleId----' + peopleId);	
	    ResponseWrapper responseWrapperObj = null;

	    try {
            Map<String, Object> responseMap = new Map<String, Object>();
            List<ExternalAppsSettingsWrapper> settingsWrapperList = new List<ExternalAppsSettingsWrapper>();
            ExternalAppsSettingsWrapper wrapperObj;
            IntegrationService integrationServiceObj = new IntegrationService(peopleId);
            Map<String, People_Integration__c> peopleIntegrationsMap = getPeopleIntegrations(peopleId);
            Boolean isSlackAppInstalled;
            if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded) {
                isSlackAppInstalled = new SlackHelper().getSlackAppInstalledInfo();
            } else {
                isSlackAppInstalled = new ManageApplicationDao().getSlackAppInstalledInfo(SimpplrContext.simpplrOrgId);
            }
            for (App_Integration__c obj: SimpplrContext.Integrations.values()) {
                // Skip, if integration is not enabled OR is amongst enterprise search integration
                if(obj.Integration_Enabled__c == false || 
                        IntegrationConstants.ENTERPRISE_SEARCH_INTEGRATION_NAME_LIST.contains(obj.Name)){
                    continue;
                }
                wrapperObj = new ExternalAppsSettingsWrapper();
                if(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN.equalsIgnoreCase(obj.Name) ||
                    IntegrationConstants.INTEGRATION_TYPE_TWITTER.equalsIgnoreCase(obj.Name)) {
                    
                    if(SimpplrContext.isFeatureEnabled('Employee_Advocacy')) {
                        integrationServiceObj.setIntegrationVariables(obj.Name);
                        wrapperObj.name = obj.Name;
                        if(integrationServiceObj.integrator != null && !integrationServiceObj.accessTokenExpired()){
                            wrapperObj.isConnected = true;
                            wrapperObj.connectedAs = integrationServiceObj.integrator.User_Name__c;
                        }
                    } else {
                        continue;
                    }

                } else if(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(obj.Name)) {                        
                    if(String.isNotBlank(SimpplrContext.serviceNowUserName)) {
                        integrationServiceObj.setIntegrationVariables(obj.Name);
                        wrapperObj.name = obj.Name;
                        ServiceNowIntegrationService snisObj = new ServiceNowIntegrationService();
                        if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) != null){
                            if(snisObj.isAccessTokenExpired(false) == false){
                                wrapperObj.isConnected = true;
                                wrapperObj.connectedAs = integrationServiceObj.integrator.User_Name__c;
                            } else {
                                Boolean isSuccess = snisObj.refreshServiceNowToken(false);
                                if(isSuccess == true){
                                    wrapperObj.isConnected = true;
                                    wrapperObj.connectedAs = integrationServiceObj.integrator.User_Name__c;
                                } else {
                                    wrapperObj.isConnected = false;
                                }
                            }
                        } else {
                            wrapperObj.isConnected = false;
                        }
                        
                    } else {
                        continue;
                    }

                } else if(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(obj.Name)) {   
                    if(obj.Connected__c && SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_EVENT)) {
                        People_Integration__c peopleIntegrationObj = peopleIntegrationsMap.get(obj.Name);
                        if(peopleIntegrationObj !=null) {                                                
                            wrapperObj.name = peopleIntegrationObj.Name;
                            wrapperObj.connectedAs = peopleIntegrationObj.User_Email__c;	    
                            wrapperObj.isConnected =peopleIntegrationObj.Connected__c;  
                            
                        } else{
                            wrapperObj.name = obj.Name;
                            wrapperObj.isConnected = false;
                        }

                    } else {
                        continue;
                    }                      

                } else if(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(obj.Name)) {   
                    if(obj.Connected__c && SimpplrContext.AllowedFeatures.containsIgnoreCase(AccessManager.FEATURE_EVENT)) {
                        People_Integration__c peopleIntegrationObj = peopleIntegrationsMap.get(obj.Name);
                        if(peopleIntegrationObj !=null) {                                                
                            wrapperObj.name = MICROSOFT_OUTLOOK_CALENDAR;
                            wrapperObj.connectedAs = peopleIntegrationObj.User_Email__c;	    
                            wrapperObj.isConnected =peopleIntegrationObj.Connected__c;  
                            
                        } else{
                            wrapperObj.name = MICROSOFT_OUTLOOK_CALENDAR;
                            wrapperObj.isConnected = false;
                        }

                    } else {
                        continue;
                    }                      

                } else if (IntegrationConstants.INTEGRATION_TYPE_SLACK.equalsIgnoreCase(obj.Name)) {
                    People_Integration__c peopleIntegrationObj;
                    if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded) {
                        peopleIntegrationObj = peopleIntegrationsMap.get(IntegrationConstants.INTEGRATION_TYPE_SLACK);
                        wrapperObj.name = IntegrationConstants.INTEGRATION_TYPE_SLACK;
                    } else {
                        peopleIntegrationObj = peopleIntegrationsMap.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE);
                        wrapperObj.name = IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE;
                    }
                    wrapperObj.isConnected = peopleIntegrationObj != null && peopleIntegrationObj.Connected__c; 
                    wrapperObj.connectedAs = wrapperObj.isConnected ? peopleIntegrationObj.User_Name__c:'';                     

                    if(!(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded) && isSlackAppInstalled == true) {
                        settingsWrapperList.add(wrapperObj);  
                        peopleIntegrationObj = peopleIntegrationsMap.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL);
                        wrapperObj = new ExternalAppsSettingsWrapper();
                        wrapperObj.name = IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL;
                        wrapperObj.isConnected = peopleIntegrationObj != null && peopleIntegrationObj.Connected__c; 
                        wrapperObj.connectedAs = wrapperObj.isConnected ? peopleIntegrationObj.User_Name__c:'';  
                    }
                    
                } else if('facebook'.equalsIgnoreCase(obj.Name)) {
                        continue;

                } else if('adsi'.equalsIgnoreCase(obj.Name)) {
                    continue;
                    
                } else if('activedirectory'.equalsIgnoreCase(obj.Name)) {
                    continue;
                    
                } else if('salesforce'.equalsIgnoreCase(obj.Name)) {
                    continue;

                } else if('googleusersync'.equalsIgnoreCase(obj.Name)) {
                    continue;

                } else {
                    People_Integration__c peopleIntegrationObj = peopleIntegrationsMap.get(obj.Name);
                    if(peopleIntegrationObj !=null) {   
                        if (IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS.equalsIgnoreCase(obj.Name) && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
                        
                            wrapperObj.name = peopleIntegrationObj.Name;
                            wrapperObj.connectedAs = peopleIntegrationObj.User_Name__c +' - '+peopleIntegrationObj.User_Email__c;	    
                            wrapperObj.isConnected = peopleIntegrationObj.Connected__c;
    
                        }  else {
                            wrapperObj.name = peopleIntegrationObj.Name;
                            wrapperObj.connectedAs = peopleIntegrationObj.User_Name__c;   
                            wrapperObj.isConnected = peopleIntegrationObj.Connected__c;
                        }                                                                   
                    

                    } else if (IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT.equalsIgnoreCase(obj.Name)) {
                        if(EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID.equalsIgnoreCase(obj.Client_Id__c) && 
                            String.isBlank(obj.User_Email__c) && String.isBlank(obj.User_Name__c)) {
                            continue;

                        } else {
                            wrapperObj.name = obj.Name;
                            wrapperObj.isConnected = false;
                        }

                    } else if (IntegrationConstants.INTEGRATION_TYPE_ONEDRIVE.equalsIgnoreCase(obj.Name)) {
                        wrapperObj.name = obj.Name;
                        wrapperObj.isConnected = false;

                    } else if (IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS.equalsIgnoreCase(obj.Name) && SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
                        wrapperObj.name = obj.Name;
                        wrapperObj.isConnected = false;

                    } else if(obj.Connected__c) {
                        wrapperObj.name = obj.Name;
                        wrapperObj.isConnected = false;
                    } else {
                        continue;
                    }
                }
                settingsWrapperList.add(wrapperObj);
            }

            if(SimpplrContext.IsBoxIntegrationEnabled && String.isNotBlank(SimpplrContext.BoxUsername) && String.isNotBlank(SimpplrContext.boxManagedPermission)) {
                wrapperObj = new ExternalAppsSettingsWrapper();
                People_Preference__c peoplePrefObj = getPeoplePreference(peopleId);
                wrapperObj.name = 'box';
                wrapperObj.isConnected = peoplePrefObj == null ? false : true;
                wrapperObj.connectedAs = wrapperObj.isConnected ? peoplePrefObj.Box_Username__c : null;
                settingsWrapperList.add(wrapperObj);
            }

            settingsWrapperList.sort();             

            responseMap.put('listOfApps', settingsWrapperList);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseMap);

        } catch (Exception e) {        	
            logger.logError('MySettingDataServer.getExternalAppsSettings()----could not get external app settings',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

		return responseWrapperObj;
    }
    // Fetch all people integration records based on peopleId received
    private Map<String, People_Integration__c> getPeopleIntegrations(String peopleId){
        Map<String, People_Integration__c> peopleIntegrationsMap = new Map<String, People_Integration__c>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1',peopleId );
        soqlParamMap.put('soqlParam2', UserInfo.getOrganizationId());
        String query = 'Select Name, Connected__c,User_Name__c, User_Email__c FROM People_Integration__c '+
                                            ' WHERE People__c =: soqlParam1 AND Is_Deleted__c = false AND App_Integration__r.Org_Id__c =: soqlParam2';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People_Integration__c> peopleIntList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
        for(People_Integration__c integObj : peopleIntList){
            peopleIntegrationsMap.put(integObj.Name, integObj);
        }

        return peopleIntegrationsMap;
    }

    // Fetch people preference record based on peopleId received for Box integration
    private People_Preference__c getPeoplePreference(String peopleId){
        
        List<People_Preference__c> peoplePrefObj = [SELECT Id, Box_Username__c, Box_Refresh_Token__c, Box_Refresh_Token_Expires_At__c
                                        FROM People_Preference__c WHERE People__c = :peopleId AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
        if(peoplePrefObj != null && peoplePrefObj.size() > 0) {
            if(String.isNotBlank(peoplePrefObj[0].Box_Refresh_Token__c) &&
            peoplePrefObj[0].Box_Refresh_Token_Expires_At__c > Datetime.now()) {
                return peoplePrefObj[0];
            }
        }

        return null;
    }

    public class ExternalAppsSettingsWrapper implements Comparable{
        public String name;
        public Boolean isConnected;
        public String connectedAs;

        public Integer compareTo(Object compareToObj) {
            ExternalAppsSettingsWrapper mfObj = (ExternalAppsSettingsWrapper)compareToObj;
	        return name.toLowerCase().compareTo(mfObj.name.toLowerCase()); 
        }
    }
    public List<People__c> getNormalizedLocation(List<People__c> peopleList) {
        logger.logDebug('MySettingDataServer.getNormalizedLocation()');
        try{
            Map<Id, People__c> peopleMap =  new Map<Id, People__c>();
            List <Map<String,Object>> requestList = new List <Map<String,Object>> ();
            for(People__c peopleObj : peopleList) {
                Map<String,Object> requestBody = new Map<String,Object>();
                String peopleId = String.isNotBlank(peopleObj.Id) ? peopleObj.Id : peopleObj.User__c;
                requestBody.put('city',peopleObj.city__c);
                requestBody.put('state',peopleObj.state__c);
                requestBody.put('country',peopleObj.country__c);
                requestBody.put('street',peopleObj.street__c);
                requestBody.put('userId',peopleId);
                requestList.add(requestBody);
                peopleMap.put(peopleId, peopleObj);
            }
            HttpResponse res = Utility.getResponseFromAWS(SimpplrContext.simpplrAPIEndpoint + '/normalization/locations/validate-address', requestList);
            if (res.getStatusCode() != 200) {
            	logger.logError('MySettingDataServer.getNormalizedLocation()----status code----' + res.getStatusCode());
                logger.logError('MySettingDataServer.getNormalizedLocation()----response body----' + res.getBody());
                throw new SimpplrException(String.valueOf(res.getStatusCode()));
            }
            if(String.isNotBlank(Res.getBody())) {
                List<Object> respList = (List<Object>)JSON.deserializeUntyped(Res.getBody());
                for(Object Obj : respList) {
                    Map<String,Object> respDataMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(Obj));
                    People__c pObj = Test.isRunningTest() ? peopleList[0] : peopleMap.get((String)respDataMap.get('userId'));
                    if(Integer.valueOf(respDataMap.get('normalizationStatus')) == 1 || Integer.valueOf(respDataMap.get('normalizationStatus')) == 3) {
                        pObj.city__c = (String)respDataMap.get('city');
                        pObj.state__c = (String)respDataMap.get('state');
                        pObj.country__c = (String)respDataMap.get('country');
                    }
                    pObj.raw_city__c = (String)respDataMap.get('oldCity');
                    pObj.raw_state__c = (String)respDataMap.get('oldState');
                    pObj.raw_country__c = (String)respDataMap.get('oldCountry');
                    //Add 10 to Location_Normalization_Status__c and subtract in PeopleTriggerHandler.updateLocationFields() to avoid overwrite
                    pObj.Location_Normalization_Status__c = respDataMap.get('normalizationStatus') != null ? Integer.valueOf(respDataMap.get('normalizationStatus')) + 10 : null;
                }
            }
            return peopleMap.values();
            
		} catch(Exception e){
			logger.logError('MySettingDataServer.getNormalizedLocation()----Exception Occured----', e);
			throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
		}
    }

     
}