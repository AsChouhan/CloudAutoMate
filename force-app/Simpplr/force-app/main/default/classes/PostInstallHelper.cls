public with sharing class PostInstallHelper {
	
	private List<Map<String,Object>> schedulerClassSettingsList = new List<Map<String,Object>>{
		new Map<String,Object>{
			'name' => 'SchedulerBatchInsertPeopleRecords',
			'description' => 'Scheduler job to get new people records.',
			'cron_exp' => '0 45 0,3,6,9,12,15,18,21 * * ?',
			'size' => 200,
			'setOfApexClass'=> new Set<String>{'BatchInsertPeopleRecords'}
		},
		new Map<String,Object>{
			'name' => 'SchedulerSimpplrServices',
			'description' => 'Scheduler job for Simpplr Services.',
			'cron_exp' => '0 20 0 * * ?',
			'size' => 1000,
			'setOfApexClass'=> new Set<String>{'BatchSfdcUserDataSync','BatchADAPIUserSync','BatchInsertSiteRecords','BatchManageContentPermissions'}
		},
		new Map<String,Object>{
			'name' => 'SchedulerBatchTopStories',
			'description' => 'Scheduler job for daily top story digest',
			'cron_exp' => '0 30 0 * * ?',
			'size' => 50,
			'setOfApexClass'=> new Set<String>{'BatchTopStories'}
		},new Map<String,Object>{
			'name' => 'SchedulerBatchEmailDigest',
			'description' => 'Scheduler job for daily email digest',
			'cron_exp' => '0 40 0 * * ?',
			'size' => 25,
			'setOfApexClass'=> new Set<String>{'BatchEmailDigest'}
		},
		new Map<String,Object>{
			'name' => 'SchedulerBatchNotificationDigest',
			'description' => 'Scheduler job for daily Notification digest',
			'cron_exp' => '0 50 0 * * ?',
			'size' => 100,
			'setOfApexClass'=> new Set<String>{'BatchNotificationDigest'}
		},
		new Map<String,Object>{
			'name' => 'SchedulerAnalytics',
			'description' => 'Scheduler job for Analytics data',
			'cron_exp' => '0 15 0,3,6,9,12,15,18,21 * * ?',
			'size' => 20,
			'setOfApexClass'=> new Set<String>{'BatchAdoptionAnalytics','BatchLoginAnalytics','BatchSaleforceActiveUserAnalytics','BatchTopSitesAnalytics','BatchTopContentsAnalytics','BatchContentCountAnalytics',
												'BatchSearchAnalytics','BatchTopicAnalytics','BatchFeedAnalytics','BatchPeopleAnalytics','BatchPullNewsletterTrackerData','BatchPushAnalyticsData'}
		},
		new Map<String,Object>{
			'name' => 'SchedulerHourlySimpplrServices',
			'description' => 'Scheduler job for Hourly Simpplr Services',
			'cron_exp' => '0 0 * * * ?',
			'size' => 25,
			'setOfApexClass'=> new Set<String>{'BatchNewsletter', 'BatchNotificationsOnContentUpdate'}
		}
	};
	
    public void resetSchedulerConfig(){
		// delete existing configuration
		List<Simpplr_Metadata__c> listOfMetaData = [SELECT id FROM Simpplr_Metadata__c 
				WHERE type__c = :ServiceConstants.SIMPPLR_SCHEDULE_JOB WITH SECURITY_ENFORCED];

		if (!listOfMetaData.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfMetaData);
		}

		createSchedulerRecords();
	}
	
	public void createSchedulerRecords(){
		List<Simpplr_Metadata__c> currentJobs = [select id from Simpplr_Metadata__c where type__c = :ServiceConstants.SIMPPLR_SCHEDULE_JOB WITH SECURITY_ENFORCED];
		String jsonString = Json.serialize(schedulerClassSettingsList);
		Simpplr_Metadata__c metadataObj;
		if(currentJobs.isEmpty()){
			metadataObj = new Simpplr_Metadata__c(
												value__c = jsonString,
												type__c = ServiceConstants.SIMPPLR_SCHEDULE_JOB);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	        SIMPESAPI.accessController().insertAsUser(metadataObj,new List<Schema.SObjectField>{Simpplr_Metadata__c.value__c,
	        																					Simpplr_Metadata__c.type__c});
		} else {
			metadataObj = new Simpplr_Metadata__c(id = currentJobs[0].id,
												value__c = jsonString,
												type__c = ServiceConstants.SIMPPLR_SCHEDULE_JOB);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	        SIMPESAPI.accessController().updateAsUser(metadataObj,new List<Schema.SObjectField>{Simpplr_Metadata__c.value__c,
	        																					Simpplr_Metadata__c.type__c});
		}										
	}
	
	public String getBrandingDocIdJson(){
		String namespaceFilter = '';
    	String packageName = SimpplrContext.packageName;
    	if(String.isNotBlank(packageName)){
    		namespaceFilter = ' AND NamespacePrefix =: packageName ';
    	}
		String documentQuery = ' SELECT Id, Name, DeveloperName,  Folder.Name,FolderId FROM '+
		    							' Document WHERE Folder.DeveloperName=\'Simpplr\' AND (DeveloperName=\'Simpplr_Placeholder_Temp_Logo\' '+ 
		    							' OR DeveloperName=\'Simpplr_Placeholder_Background_Image\' OR '+
		    							' DeveloperName=\'Simpplr_Placeholder_Logo\' OR '+
		    							' DeveloperName=\'Simpplr_IE_Favicon_16x16\' OR '+
		    							' DeveloperName=\'Simpplr_Placeholder_Temp_Background_Image\' ) '+namespaceFilter+' limit 5 ';
		List<Document> listOfDocument =  Database.query(documentQuery); 
    	Map<String,String> brandingDocumentNameToIdMap = new Map<String,String>();
		for (Document docObj : listOfDocument) {		    			
			if ('Simpplr_Placeholder_Temp_Logo'.equalsIgnoreCase(docObj.DeveloperName)) {
				brandingDocumentNameToIdMap.put('LogoTemp',docObj.Id);		    				
			} else if ('Simpplr_Placeholder_Background_Image'.equalsIgnoreCase(docObj.DeveloperName)) {
				brandingDocumentNameToIdMap.put('BG',docObj.Id);		    				
			} else if ('Simpplr_Placeholder_Logo'.equalsIgnoreCase(docObj.DeveloperName)) {
				brandingDocumentNameToIdMap.put('Logo',docObj.Id);		    				
			} else if ('Simpplr_Placeholder_Temp_Background_Image'.equalsIgnoreCase(docObj.DeveloperName)) {
				brandingDocumentNameToIdMap.put('BGTemp',docObj.Id);
			} else if ('Simpplr_IE_Favicon_16x16'.equalsIgnoreCase(docObj.DeveloperName)) {
				brandingDocumentNameToIdMap.put('Favicon',docObj.Id);
			}
		}
		String brandingDocIdJSON;
		if(!brandingDocumentNameToIdMap.isEmpty()){
			brandingDocIdJSON = JSON.serialize(brandingDocumentNameToIdMap);
		}
		return brandingDocIdJSON;
	}

	public ManageApplicationWrapper.SMSNotificationWrapper getDefaultSMSNotificationSettings() {
		ManageApplicationWrapper.SMSNotificationWrapper smsNotiSettingsWrapper = new ManageApplicationWrapper.SMSNotificationWrapper();
		
		smsNotiSettingsWrapper.smsAlerts = true;	
		smsNotiSettingsWrapper.smsContentMarkedAsMustRead = true;
		smsNotiSettingsWrapper.smsContentPromotionMessage = true;

		return smsNotiSettingsWrapper;
	}

	public ManageApplicationWrapper.MobileAppNotificationWrapper getDefaultMobileAppNotificationSettings() {
		ManageApplicationWrapper.MobileAppNotificationWrapper mobileNotiSettingsWrapper = new ManageApplicationWrapper.MobileAppNotificationWrapper();

		mobileNotiSettingsWrapper.mobileAppContentMarkedAsMustRead = true;
		mobileNotiSettingsWrapper.mobileAppAlerts = true;
		mobileNotiSettingsWrapper.mobileAppUpdatesContentSitesFollow = true;
		mobileNotiSettingsWrapper.mobileAppFollowsMe = true;
		mobileNotiSettingsWrapper.mobileAppEndorseExpertise = true;
		mobileNotiSettingsWrapper.mobileAppCommentsPostMade = true;
		mobileNotiSettingsWrapper.mobileAppReplyAfterMe = true;
		mobileNotiSettingsWrapper.mobileAppReplyOnLikedPost = true;
		mobileNotiSettingsWrapper.mobileAppLikesPostOrCommentMade = true;
		mobileNotiSettingsWrapper.mobileAppSharesMyPost = true;
		mobileNotiSettingsWrapper.mobileAppPostsToMe = true;
		mobileNotiSettingsWrapper.mobileAppPrivateSiteMembershipResponse = true;
		mobileNotiSettingsWrapper.mobileAppCommentsContentPublished = true;
		mobileNotiSettingsWrapper.mobileAppLikesOrSharesContentPublished = true;
		mobileNotiSettingsWrapper.mobileAppContentApprovalRejection = true;
		mobileNotiSettingsWrapper.mobileAppEventInviteMore = true;
		mobileNotiSettingsWrapper.mobileAppPrivateSiteMembershipRequest = true;
		mobileNotiSettingsWrapper.mobileAppContentSubmittedForModeration = true;
		// Question Answer
		mobileNotiSettingsWrapper.mobileQnAQuestionMention = true;
		mobileNotiSettingsWrapper.mobileQnAAnswerMention = true;
		mobileNotiSettingsWrapper.mobileQnAVote = true;
		mobileNotiSettingsWrapper.mobileQnAAnswerApproval = true;
		mobileNotiSettingsWrapper.mobileQnANewAnswer = true;
		mobileNotiSettingsWrapper.mobileQnANewApprovedAnswer = true;
		mobileNotiSettingsWrapper.mobileQnADuplicateQuestion = true;
		mobileNotiSettingsWrapper.mobileQnANewQuestion = true;
		mobileNotiSettingsWrapper.mobileAppContentQuestion = true;
		mobileNotiSettingsWrapper.mobileAppContentAnswer = true;

		// Surveys
		mobileNotiSettingsWrapper.mobileSurveys = true;

		return mobileNotiSettingsWrapper;
	}
	
	public ManageApplicationWrapper.BrowserNotificationWrapper getDefaultBrowserNotificationSettings() {
		ManageApplicationWrapper.BrowserNotificationWrapper browserNotiSettingsWrapper = new ManageApplicationWrapper.BrowserNotificationWrapper();
		//Org
		browserNotiSettingsWrapper.browserMustRead = true;
		browserNotiSettingsWrapper.browserAlerts = true;
		browserNotiSettingsWrapper.browserUpdatesContentSitesFollow = true;
		//Profile
		browserNotiSettingsWrapper.browserFollowsMe = true;
		browserNotiSettingsWrapper.browserEndorseExpertise = true;
		//Feed
		browserNotiSettingsWrapper.browserReplyOnMyPost = true;
		browserNotiSettingsWrapper.browserReplyAfterMe = true;
		browserNotiSettingsWrapper.browserReplyOnLikedPost = true;
		browserNotiSettingsWrapper.browserLikesMyPostOrReply = true;
		browserNotiSettingsWrapper.browserSharesMyPost = true;
		browserNotiSettingsWrapper.browserPostsToMe = true;
		//Site
		browserNotiSettingsWrapper.browserPrivateSiteMembershipResponse = true;
		//Content
		browserNotiSettingsWrapper.browserContentValidationRequired = true;
		browserNotiSettingsWrapper.browserContentValidationExpired = true;
		browserNotiSettingsWrapper.browserContentCommentsOnPublished = true;
		browserNotiSettingsWrapper.browserContentLikesSharesOnPublished = true;
		browserNotiSettingsWrapper.browserContentApprovalRejection = true;
		browserNotiSettingsWrapper.browserContentFeedback = true;
		//Events
		browserNotiSettingsWrapper.browserEventInvite = true;
		browserNotiSettingsWrapper.browserEventUpdatesAttending = true;
		browserNotiSettingsWrapper.browserEventUpdatesAuthoredOrganized = true;
		//Site Management
		browserNotiSettingsWrapper.browserPrivateSiteMembershipRequest = true;
		browserNotiSettingsWrapper.browserContentSubmittedForModeration = true;
		browserNotiSettingsWrapper.browserSubscriptionRequest = true;
		// Question Answer
		browserNotiSettingsWrapper.browserQnANewQuestion = true;
		browserNotiSettingsWrapper.browserQnAQuestionMention = true;
		browserNotiSettingsWrapper.browserQnAAnswerMention = true;
		browserNotiSettingsWrapper.browserQnAVote = true;
		browserNotiSettingsWrapper.browserQnAAnswerApproval = true;
		browserNotiSettingsWrapper.browserQnANewAnswer = true;
		browserNotiSettingsWrapper.browserQnANewApprovedAnswer = true;
		browserNotiSettingsWrapper.browserQnADuplicateQuestion = true;
		browserNotiSettingsWrapper.browserContentQuestion = true;
		browserNotiSettingsWrapper.browserContentAnswer = true;
		// Campaign & Initiative
		browserNotiSettingsWrapper.browserCnIEndCampaign = true;
		browserNotiSettingsWrapper.browserCnINewCampaign = true;
		browserNotiSettingsWrapper.browserCnIInitiativeEnd = true;
		browserNotiSettingsWrapper.browserCnIInitiativeStart = true;


		return browserNotiSettingsWrapper;
	}
	
	public ManageApplicationWrapper.EmailNotificationWrapper getDefaultEmailNotificationsSettings(){
		String emailNotificationFrequencyDefault;
		String topStoriesFrequencyDefault;
		Schema.DescribeFieldResult emailNotification = People_Preference__c.Email_Notification_Digest_Frequency__c.getDescribe();
		List <Schema.PicklistEntry> pickValsEmailNotification = emailNotification.getPicklistValues();        
        
        for (Schema.PicklistEntry pv: pickValsEmailNotification) {
            
            if (pv.isDefaultValue()) {
		        emailNotificationFrequencyDefault = pv.getValue();
		        break;
            }
                
        }	
		
		Schema.DescribeFieldResult topStoriesNotification = People_Preference__c.Email_Content_Digest_Frequency__c.getDescribe();
		List <Schema.PicklistEntry> pickValsTopStoriesNotification = topStoriesNotification.getPicklistValues();        
		for (Schema.PicklistEntry pv: pickValsTopStoriesNotification) {
		    if (pv.isDefaultValue()) {
		        topStoriesFrequencyDefault = pv.getValue();
		        break;
		    }    
        }	
		
		ManageApplicationWrapper.EmailNotificationWrapper defaultEmailNotificationWrapper = new ManageApplicationWrapper.EmailNotificationWrapper();
		defaultEmailNotificationWrapper.emailNotificationFrequency = String.isNotBlank(emailNotificationFrequencyDefault) ? emailNotificationFrequencyDefault : 'Immediate';
		defaultEmailNotificationWrapper.allowSimpplrEmails = 'enable';
        defaultEmailNotificationWrapper.emailFollowsMe = true;
		defaultEmailNotificationWrapper.emailEndorseExpertise = true;
		defaultEmailNotificationWrapper.emailLikesPostOrCommentMade = true;
		defaultEmailNotificationWrapper.emailCommentsPostMade = true;
		defaultEmailNotificationWrapper.emailCommentsAfterMe = true;
		defaultEmailNotificationWrapper.emailCommentsPostLike = true;
		defaultEmailNotificationWrapper.emailPostsToMe = true;
		defaultEmailNotificationWrapper.emailSharesPostMade = true;
		defaultEmailNotificationWrapper.emailCommentsContentPublished = true;
		defaultEmailNotificationWrapper.emailLikesSharesContentPublished = true;
		defaultEmailNotificationWrapper.emailUpdatesContentSitesFollow = true;
		defaultEmailNotificationWrapper.emailEventInviteMore = true;
		defaultEmailNotificationWrapper.emailContentSubmissionResponse = true;
		defaultEmailNotificationWrapper.emailPrivateSiteMembershipResponse = true;
		defaultEmailNotificationWrapper.emailContentSubmittedForModeration = true;
		defaultEmailNotificationWrapper.emailForContentUseful = true;
		defaultEmailNotificationWrapper.emailPrivateSiteMembershipRequest = true;	
		
		defaultEmailNotificationWrapper.emailContentMarkedAsMustRead = true;
		defaultEmailNotificationWrapper.emailKnowledgeReview = true;
		defaultEmailNotificationWrapper.emailKnowledgeExpired = true;
		defaultEmailNotificationWrapper.emailSubscriptionModeration = true;
        defaultEmailNotificationWrapper.emailAlerts = true;
        defaultEmailNotificationWrapper.emailContentPromotionMessageForAppMgr = true; 
        defaultEmailNotificationWrapper.emailForContentUsefulAppMgr = true;
        defaultEmailNotificationWrapper.emailUpdatesEventIRsvpYes = true;
        defaultEmailNotificationWrapper.emailUpdatesEventIAuthorOrganize = true;
		defaultEmailNotificationWrapper.emailSiteActionableForAppMgr = true;
		defaultEmailNotificationWrapper.emailSubscriptionRequest = true;
		//Question Answer
		defaultEmailNotificationWrapper.emailQnANewQuestion = true;
		defaultEmailNotificationWrapper.emailQnAQuestionMention = true;
		defaultEmailNotificationWrapper.emailQnAAnswerMention = true;
		defaultEmailNotificationWrapper.emailQnAVote = true;
		defaultEmailNotificationWrapper.emailQnAAnswerApproval = true;
		defaultEmailNotificationWrapper.emailQnANewAnswer = true;
		defaultEmailNotificationWrapper.emailQnANewApprovedAnswer = true;
		defaultEmailNotificationWrapper.emailQnADuplicateQuestion = true;
		defaultEmailNotificationWrapper.emailForContentQuestion = true;
		defaultEmailNotificationWrapper.emailForContentAnswer = true;
		//Campaign & Initiative
		defaultEmailNotificationWrapper.emailCnIEndCampaign = true;
		defaultEmailNotificationWrapper.emailCnINewCampaign = true;
		defaultEmailNotificationWrapper.emailCnIInitiativeEnd = true;
		defaultEmailNotificationWrapper.emailCnIInitiativeStart = true;
		return defaultEmailNotificationWrapper; 
    }	

    public ManageApplicationWrapper.SummariesAndDigestWrapper getDefaultSummariesAndDigestSettings(){
		String digestFrequencyDefault; 
        String topStoriesFrequencyDefault;
		Schema.DescribeFieldResult digestNotification = People_Preference__c.Email_Digest_Frequency__c.getDescribe();
		List <Schema.PicklistEntry> pickValsDigestNotification = digestNotification.getPicklistValues();        
        
        for (Schema.PicklistEntry pv: pickValsDigestNotification) {
            
            if (pv.isDefaultValue()) {
		        digestFrequencyDefault = pv.getValue();
		        break;
            }
                
        }
        
		Schema.DescribeFieldResult topStoriesNotification = People_Preference__c.Email_Content_Digest_Frequency__c.getDescribe();
		List <Schema.PicklistEntry> pickValsTopStoriesNotification = topStoriesNotification.getPicklistValues();        
        
        for (Schema.PicklistEntry pv: pickValsTopStoriesNotification) {
         
            if (pv.isDefaultValue()) {
		        topStoriesFrequencyDefault = pv.getValue();
		        break;
            }
                
		}	
		
		ManageApplicationWrapper.SummariesAndDigestWrapper defaultSummariesAndDigestWrap = new ManageApplicationWrapper.SummariesAndDigestWrapper();
        defaultSummariesAndDigestWrap.digestFrequency = String.isNotBlank(digestFrequencyDefault) ? digestFrequencyDefault : 'Daily';
        defaultSummariesAndDigestWrap.topStoriesFrequency = String.isNotBlank(topStoriesFrequencyDefault) ? topStoriesFrequencyDefault : 'Daily';
        defaultSummariesAndDigestWrap.siteAnalyticsFrequency = 'monthly';
		return defaultSummariesAndDigestWrap; 
    }
    
	public ManageApplicationWrapper.DefaultFeedSettingsWrapper getDefaultFeedSettings(){
		String feedSetting;
		String feedFilter;
		
		ManageApplicationWrapper.DefaultFeedSettingsWrapper defaultFeedSeeting = new ManageApplicationWrapper.DefaultFeedSettingsWrapper();
		
		Schema.DescribeFieldResult feedSettingColumn = People_Preference__c.Feed_Type__c.getDescribe();
		
		List <Schema.PicklistEntry> pickValsFeedSetting = feedSettingColumn.getPicklistValues();        
		for (Schema.PicklistEntry pv: pickValsFeedSetting) {
		    if (pv.isDefaultValue()) {
		        feedSetting = pv.getValue();
		        break;
		    }    
		}	
		
		Schema.DescribeFieldResult feedFilterColumn = People_Preference__c.Feed_Sort_Order__c.getDescribe();
		
		List <Schema.PicklistEntry> pickValsFeedFilter = feedFilterColumn.getPicklistValues();        
		for (Schema.PicklistEntry pv: pickValsFeedSetting) {
		    if (pv.isDefaultValue()) {
		        feedFilter = pv.getValue();
		        break;
		    }    
		}
		
		defaultFeedSeeting.feedSetting = feedSetting;
		defaultFeedSeeting.feedFilter = feedFilter;
		return defaultFeedSeeting;
	}
}