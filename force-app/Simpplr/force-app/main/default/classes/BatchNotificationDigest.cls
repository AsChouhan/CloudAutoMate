public class BatchNotificationDigest implements Database.Batchable<sObject>{
    
	private static final String KEY_NEW_FOLLOWER_SINGULAR = 'email.notification.batch.digest.new_followers_singular';
	private static final String KEY_NEW_FOLLOWER_PLURAL = 'email.notification.batch.digest.new_followers_plural';
	private static final String KEY_ENDORSEMENT_SINGULAR = 'email.notification.batch.digest.endorsement_singular';
	private static final String KEY_ENDORSEMENT_PLURAL = 'email.notification.batch.digest.endorsement_plural';
	private static final String KEY_APPROVED_PRIVATE_SITE_JOIN_PLURAL = 'email.notification.batch.digest.private_site_approval_plural';
	private static final String KEY_APPROVED_PRIVATE_SITE_JOIN_SINGULAR = 'email.notification.batch.digest.private_site_approval_singular';
	private static final String KEY_REJECTED_PRIVATE_SITE_JOIN_PLURAL = 'email.notification.batch.digest.private_site_rejection_plural';
	private static final String KEY_REJECTED_PRIVATE_SITE_JOIN_SINGULAR = 'email.notification.batch.digest.private_site_rejection_singular';
	private static final String KEY_POST_ON_CONTENT_PLURAL = 'email.notification.batch.digest.posts_on_content_plural';
	private static final String KEY_POST_ON_CONTENT_SINGULAR = 'email.notification.batch.digest.posts_on_content_singular';
	private static final String KEY_LIKE_PLURAL = 'email.notification.batch.digest.likes_plural';
	private static final String KEY_LIKE_SINGULAR = 'email.notification.batch.digest.likes_singular';
	private static final String KEY_LIKE_OR_SHARE_ON_CONTENT_PLURAL = 'email.notification.batch.digest.likes_shares_content_plural';
	private static final String KEY_LIKE_OR_SHARE_ON_CONTENT_SINGULAR = 'email.notification.batch.digest.likes_shares_content_singular';
	private static final String KEY_SHARE_PLURAL = 'email.notification.batch.digest.shares_plural';
	private static final String KEY_SHARE_SINGULAR = 'email.notification.batch.digest.shares_singular';
	private static final String KEY_CONTENT_APPROVED_PLURAL = 'email.notification.batch.digest.content_approved_plural';
	private static final String KEY_CONTENT_APPROVED_SINGULAR = 'email.notification.batch.digest.content_approved_singular';
	private static final String KEY_CONTENT_REJECTED_PLURAL = 'email.notification.batch.digest.content_rejected_plural';
	private static final String KEY_CONTENT_REJECTED_SINGULAR = 'email.notification.batch.digest.content_rejected_singular';
	private static final String KEY_FEED_POST_PLURAL = 'email.notification.batch.digest.feed_posts_plural';
	private static final String KEY_FEED_POST_SINGULAR = 'email.notification.batch.digest.feed_posts_singular';
	private static final String KEY_REPLIED_AFTER_YOU_PLURAL = 'email.notification.batch.digest.replies_after_you_plural';
	private static final String KEY_REPLIED_AFTER_YOU_SINGULAR = 'email.notification.batch.digest.replies_after_you_singular';
	private static final String KEY_REPLY_ON_POST_I_LIKED_PLURAL = 'email.notification.batch.digest.post_reply_liked_plural';
	private static final String KEY_REPLY_ON_POST_I_LIKED_SINGULAR = 'email.notification.batch.digest.post_reply_liked_singular';
	private static final String KEY_REPLY_PLURAL = 'email.notification.batch.digest.replies_after_you_plural';
	private static final String KEY_REPLY_SINGULAR = 'email.notification.batch.digest.replies_after_you_singular';
	private static final String KEY_CONTENT_RATED_USEFUL_PLURAL = 'email.notification.batch.digest.content_rated_useful_plural';
	private static final String KEY_CONTENT_RATED_USEFUL_SINGULAR = 'email.notification.batch.digest.content_rated_useful_singular';
	private static final String KEY_CONTENT_RATED_UNUSEFUL_PLURAL = 'email.notification.batch.digest.content_rated_unuseful_plural';
	private static final String KEY_CONTENT_RATED_UNUSEFUL_SINGULAR = 'email.notification.batch.digest.content_rated_unuseful_singular';
	private static final String KEY_CONTENT_UPDATED_PLURAL = 'email.notification.batch.digest.content_updated_plural';
	private static final String KEY_CONTENT_UPDATED_SINGULAR = 'email.notification.batch.digest.content_updated_singular';
	private static final String KEY_EVENT_INVITE_PLURAL = 'email.notification.batch.digest.event_invites_plural';
	private static final String KEY_EVENT_INVITE_SINGULAR = 'email.notification.batch.digest.event_invites_singular';
	private static final String KEY_MUST_READ_PLURAL = 'email.notification.batch.digest.must_reads_plural';
	private static final String KEY_MUST_READ_SINGULAR = 'email.notification.batch.digest.must_reads_singular';
	private static final String KEY_HI = 'email.common.salutation';
	private static final String KEY_VIEW_ALL = 'email.common.view_all';
	private static final String KEY_DIGEST_PLURAL_HEADING = 'email.notification.batch.digest.intro_plural';
	private static final String KEY_DIGEST_SINGULAR_HEADING = 'email.notification.batch.digest.intro_singular';
	private static final String KEY_DIGEST_HTML_TITLE = 'email.notification.batch.digest.html_title';
	private static final String KEY_POWERED_BY = 'email.common.footer.powered_by';
	private static final String KEY_FOOTER_SETTINGS = 'email.common.footer.settings';
	private static final String KEY_SUBJECT_SINGULAR = 'email.notification.batch.digest.subject_singular';
	private static final String KEY_SUBJECT_PLURAL = 'email.notification.batch.digest.subject_plural';
	private static final String KEY_COPYRIGHT_TEXT = 'email.common.footer.copyright';
	private static final String KEY_ALERT_SINGULAR = 'email.notification.batch.digest.alert_count_singular';
	private static final String KEY_ALERT_PLURAL = 'email.notification.batch.digest.alert_count_plural';
	private static final String KEY_MENTION_IN_QUESTION_SINGULAR = 'email.notification.batch.digest.mention_question_count_singular';
	private static final String KEY_MENTION_IN_QUESTION_PLURAL = 'email.notification.batch.digest.mention_question_count_plural';
	private static final String KEY_MENTION_IN_ANSWER_SINGULAR = 'email.notification.batch.digest.mention_answer_count_singular';
	private static final String KEY_MENTION_IN_ANSWER_PLURAL = 'email.notification.batch.digest.mention_answer_count_plural';
	private static final String KEY_VOTE_ON_ANSWER_SINGULAR = 'email.notification.batch.digest.vote_on_answer_count_singular';
	private static final String KEY_VOTE_ON_ANSWER_PLURAL = 'email.notification.batch.digest.vote_on_answer_count_plural';
	private static final String KEY_APPROVAL_ON_ANSWER_SINGULAR = 'email.notification.batch.digest.approval_on_answer_count_singular';
	private static final String KEY_APPROVAL_ON_ANSWER_PLURAL = 'email.notification.batch.digest.approval_on_answer_count_plural';
	private static final String KEY_NEW_ANSWER_SINGULAR = 'email.notification.batch.digest.new_answer_count_singular';
	private static final String KEY_NEW_ANSWER_PLURAL = 'email.notification.batch.digest.new_answer_count_plural';
	private static final String KEY_APPROVED_ANSWER_TO_QUESTION_SINGULAR = 'email.notification.batch.digest.approved_answer_to_question_count_singular';
	private static final String KEY_APPROVED_ANSWER_TO_QUESTION_PLURAL = 'email.notification.batch.digest.approved_answer_to_question_count_plural';
	private static final String KEY_DUPLICATE_QUESTION_SINGULAR = 'email.notification.batch.digest.duplicate_question_count_singular';
	private static final String KEY_DUPLICATE_QUESTION_PLURAL = 'email.notification.batch.digest.duplicate_question_count_plural';
	private static final String KEY_NEW_QUESTION_SINGULAR = 'email.notification.batch.digest.new_question_count_singular';
	private static final String KEY_NEW_QUESTION_PLURAL = 'email.notification.batch.digest.new_question_count_plural';
	
    public Integer frequency;
    public string logoUrl;
    public string query;	
    public String applicationName;
    public App_Config__c appConfig;
    public NotificationHelper.BrandingInfo brandingInfo;
    public String simpplrDefaultLogoUrl;
    public string packageName = SimpplrContext.packageName;

	public static Map<String,String> notificationDigestPartMap = new Map<String,String>{
		
		//0=style-text 1=LogUrl 2=Date 3= notificationRowsWithGreeting 4= MyEmailSetting page link 5=MyEmailSetting page link 6=HomemyDashboard link 7= target UserName
		//8=copyright 9=www.simpplr.com 10=Primary color 11=footer BG 12= Footer Text Color 13= Header  BG Color  14= Header Icon Color 15=Link to homemydashboard
		'notificationDigestWithHeaderFooter'=> '<!doctype html> <html> <head> <meta charset="utf-8"> <meta content="width=device-width, initial-scale=1.0" name="viewport"> <meta content="text/html" http-equiv="Content-Type"> <meta content="telephone=no" name="format-detection"> {0} <title>{8}</title> </head> <body class="" style="-ms-text-size-adjust: 100%; -webkit-font-smoothing: antialiased; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; height: 100% !important; line-height: 1.4; margin: 0; padding: 0; width: 100% !important;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="body" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #f6f6f6; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> <td class="container" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; display: block; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; margin: 0 auto !important; max-width: 580px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 10px; text-align: left; vertical-align: top; width: 580px;"> <div class="content" style="-moz-box-sizing: border-box; box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;"> <!-- START CENTERED WHITE CONTAINER --> <table role="presentation" class="main" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background: #ffffff; border-collapse: collapse !important; border-radius: 4px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="header" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%;background: #{11}; border-bottom: 1px solid #eeeeee; border-collapse: collapse; border-radius: 4px 4px 0 0; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <img height="31" class="logo" src="{1}" style="-ms-interpolation-mode: bicubic; border: 0; display: block; height: auto; max-height: 31px; max-width: 100%; outline: 0; text-decoration: none; width: auto;"> </td> <td class="align-right align-middle" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: right; vertical-align: middle;"> <span class="date" style="color: #c5c5c5; font-size: 12px; font-weight: normal;">{2}</span> </td> </tr> </table> </td> </tr> {3} </table> <div class="footer" style="clear: both; margin-top: 10px; text-align: center; width: 100%;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"><a href="{4}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: underline;">{10}.</a><br>{6} </td> </tr> <tr> <td class="content-block powered-by" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #999999; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 12px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: center; vertical-align: top;"> {9} <a href="{7}" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; color: #999999; font-size: 12px; text-align: center; text-decoration: none;">Simpplr</a>. </td> </tr> </table> </div> </div> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> </tr> </table> </body> </html>',

		//0=targetUserFirstName 1= header text
		'notificationDigestGreeting' =>'<tr> <td align="left" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <h2 style="color: #000000; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-weight: 400; line-height: 1.4; margin: 0; margin-bottom: 15px;"> {0},<br> {1} </h2> </td> </tr>',
		
		//0=notificationRow 1=showAllNotifications
		'notificationInfoRows' =>'{0}{1}',
		
		//0=count 1=text
		'notificationRow' => '<tr> <td class="content-block" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 10px; padding-top: 10px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> <tr> <td class="List-number" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-bottom: 1px solid #e5e5e5; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 21px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 8px; text-align: center; vertical-align: middle; width: 40px;"> {0} </td> <td class="List-text" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-bottom: 1px solid #e5e5e5; border-collapse: collapse; color: #666666; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; line-height: 18px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 8px; text-align: left; vertical-align: middle;"> {1} </td> </tr> </table> </td> </tr>',
		
		//0=link to notifications page
		'showAllNotifications' => '<tr> <td class="" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> <center> <table role="presentation" border="0" cellpadding="0" cellspacing="0" class="btn btn-primary" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; box-sizing: border-box; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100px !important;"> <tr> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> <td align="center" class="btn-spacer" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding-bottom: 15px; padding-top: 15px; text-align: left; vertical-align: top; width: 100px;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100px;"> <tbody> <tr> <td class="btn-inner" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{1}; border-collapse: collapse; border-radius: 4px; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: center; vertical-align: top; width: 100px;"> <a href="{0}" target="_blank" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; background-color: #{1}; border: solid 1px #{1}; border-color: #{1}; border-radius: 5px; box-sizing: border-box; color: #ffffff; cursor: pointer; display: inline-block; font-size: 14px; font-weight: normal; margin: 0; padding: 5px 15px; text-decoration: none; text-transform: capitalize; width: 100px;">{2}</a> </td> </tr> </tbody> </table> </td> <td style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; text-align: left; vertical-align: top;"> </td> </tr> </table> </center> </td> </tr>',
		
		//0=notificationDigestGreeting 1=notificationInfoRows
		'notificationInfoWithGreetingHeader' => '<tr> <td class="wrapper" style="-moz-box-sizing: border-box; -ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: collapse; box-sizing: border-box; color: #333; font-family: \'Helvetica Neue\',Helvetica,Arial,sans-serif; font-size: 14px; mso-table-lspace: 0pt; mso-table-rspace: 0pt; padding: 20px; text-align: left; vertical-align: top;"> <table role="presentation" border="0" cellpadding="0" cellspacing="0" style="-ms-text-size-adjust: 100%; -webkit-text-size-adjust: 100%; border-collapse: separate; mso-table-lspace: 0pt; mso-table-rspace: 0pt; width: 100%;"> {0} {1} </table> </td> </tr>'
	};

    public BatchNotificationDigest() {
    }
    
	public BatchNotificationDigest(App_Config__c appConfig, Integer frequency, String query, NotificationHelper.BrandingInfo brandingInfo, String simpplrDefaultLogoUrl){
        this.appConfig = appConfig;
        this.query = query;
        this.frequency = frequency;
        if(String.isNotBlank(appConfig.Branding_Logo__c)){
        	this.logoUrl = appConfig.Branding_Logo__c;
        } else {
        	this.logoUrl = simpplrDefaultLogoUrl;
        }
        this.applicationName = appConfig.App_Name__c;
        this.brandingInfo = brandingInfo;
        this.simpplrDefaultLogoUrl = simpplrDefaultLogoUrl;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<People_Preference__c> peoplePrefList){
    		try {
				List<String> localeList = new List<String>();
		    	Map<String,String> peopleToUserIdMap = new Map<String,String>();
		    	List<Messaging.SingleEmailMessage> digestEmailList = new List<Messaging.SingleEmailMessage>();
		    	for(People_Preference__c peoplePref: peoplePrefList){
		    		peopleToUserIdMap.put(peoplePref.people__c,peoplePref.people__r.user__c);
					localeList.add(Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey));
		    	}


				// Initialize Locale Context
				LocaleContext.getAllLabelMap('EmailNotifications', localeList);
		    	
		    	Set<String> peopleIdSet = peopleToUserIdMap.keySet();

				Map<String, Integer> audienceAlertCountMap = getAlertCountMap('audience', null, frequency);
				Map<String, Integer> siteAlertOnlyMembersCountMap = getAlertCountMap('site', 'site_members', frequency);
				Map<String, Integer> siteAlertBothMemberFollowerCountMap = getAlertCountMap('site', 'site_members_and_followers', frequency);

				AlertCountWrapperClass alertCountWrapperClassObj = new AlertCountWrapperClass();
				alertCountWrapperClassObj.audienceAlertCountMap = audienceAlertCountMap;
				alertCountWrapperClassObj.siteAlertOnlyMembersCountMap = siteAlertOnlyMembersCountMap;
				alertCountWrapperClassObj.siteAlertBothMemberFollowerCountMap = siteAlertBothMemberFollowerCountMap;

				Map<String, Set<String>> mapOfPeopleIdToAudienceSet = getMapOfPeopleIdToAudienceSet(audienceAlertCountMap.keySet(), peopleIdSet);
				Map<String, Set<String>> mapOfPeopleIdToOnlyMemberSiteSet = getMapOfPeopleIdToSiteSet(siteAlertOnlyMembersCountMap.keySet(), peopleIdSet, 'site_members');
				Map<String, Set<String>> mapOfPeopleIdToBothMemeberFollowerSiteSet = getMapOfPeopleIdToSiteSet(siteAlertBothMemberFollowerCountMap.keySet(), peopleIdSet, 'site_members_and_followers');

		    	String notificationQuery ='';
		    	notificationQuery = 'Select id, Type__c, Sub_Type__c, Sent_To__c,Created_DateTime__c, Category__c, status__c, Object_Type__c, Simpplr_Site__c, Object_Id__c, Is_Read__c, Is_New__c, CreatedDate, '+
		    							' Action_By__c From App_Notification__c  where is_Deleted__c = false and (Simpplr_Site__c = null OR (Simpplr_Site__r.is_active__c = true AND Simpplr_Site__r.Show_In_Simpplr__c = true)) and type__c=\'Information\' and Sent_to__r.Id IN: peopleIdSet and '+
		    							' Created_DateTime__c = LAST_N_DAYS:'+frequency+' order by Created_DateTime__c desc ';
		    	Integer notificationCount = 0;
		    	List<App_Notification__c> notificationList = Database.query(notificationQuery);
			    Map<String, List<App_Notification__c>> notificationMap = new Map<String, List<App_Notification__c>>();
		    	if(notificationList != null) {
			    	notificationCount = notificationList.size();
			    	for(App_Notification__c notification :  notificationList) {
			    		if(peopleToUserIdMap.get(notification.sent_to__c) != null){
			    			if(notificationMap.get(notification.sent_to__c) == null) {
			    				notificationMap.put(notification.sent_to__c, new List<App_Notification__c>());
			    			}
			    			notificationMap.get(notification.sent_to__c).add(notification);
			    		}
			    	}
		    	}
		    	for(People_Preference__c peoplePref : peoplePrefList) {
		    		String localeKey = Utility.getSimpplrLanguageLocaleKey(peoplePref.people__r.User__r.languagelocalekey);
		    		String digestBody = '';
				    String subject = '';

					String peopleId = peoplePref.people__c;
					Set<String> audienceIdSet = mapOfPeopleIdToAudienceSet.containsKey(peopleId) ? 
												mapOfPeopleIdToAudienceSet.get(peopleId) : new Set<String>();
					Set<String> onlyMemberSiteIdSet = mapOfPeopleIdToOnlyMemberSiteSet.containsKey(peopleId) ?
														mapOfPeopleIdToOnlyMemberSiteSet.get(peopleId) : new Set<String>();
					Set<String> bothMemberFollowerSiteIdSet = mapOfPeopleIdToBothMemeberFollowerSiteSet.containsKey(peopleId) ?
																mapOfPeopleIdToBothMemeberFollowerSiteSet.get(peopleId) : new Set<String>();
					Map<String, Set<String>> mapOfaudienceIdsSiteIdsSet = new Map<String, Set<String>>();
					mapOfaudienceIdsSiteIdsSet.put('audienceIdSet', audienceIdSet);
					mapOfaudienceIdsSiteIdsSet.put('onlyMemberSiteIdSet', onlyMemberSiteIdSet);
					mapOfaudienceIdsSiteIdsSet.put('bothMemberFollowerSiteIdSet', bothMemberFollowerSiteIdSet);
					Integer alertNotificationCount = getAlertNotificationCount(alertCountWrapperClassObj, mapOfaudienceIdsSiteIdsSet);																			

		    		if(notificationMap.get(peoplePref.people__c) != null || alertNotificationCount > 0){

						Map<String,Integer> notificationInfoMap = getNotiInfoMap(notificationMap.get(peoplePref.people__c), peoplePref);
						notificationInfoMap.put('countOfAlert', alertNotificationCount);
						Integer subjectCount = 0;
			        	for(Integer notiCount : notificationInfoMap.values()){
			        		subjectCount = subjectCount + notiCount; 
			        	}
						
						if(subjectCount == 0){
							continue;
						}
						if(subjectCount == 1) {
				        	subject = (LocaleContext.getLabel(localekey, KEY_SUBJECT_SINGULAR))
												.replace('{{appName}}', applicationName)
												.replace('{{count}}', '1'); 
				        } else {
				        	subject = (LocaleContext.getLabel(localekey, KEY_SUBJECT_PLURAL))
												.replace('{{appName}}', applicationName)
												.replace('{{count}}', String.valueOf(subjectCount));
				        }

						digestBody = getDigestBody(frequency, logoUrl, applicationName, peoplePref, notificationMap.get(peoplePref.people__c), subjectCount, localekey, alertNotificationCount);
			        	
						if(String.isNotBlank(digestBody) && String.isNotBlank(subject)) {
				    		Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
							singleMail.setTargetObjectId(peoplePref.people__r.User__c);
							singleMail.setSubject(subject);
							if(String.isNotBlank(SimpplrContext.SEDFromEmail)) {
								singleMail.setOrgWideEmailAddressId(SimpplrContext.SEDFromEmail);
							}
							if(SimpplrContext.DeeplinkingEnabled) {
								digestBody = EmailUtility.deeplinkedMailBody(digestBody);
							}
							singleMail.setHtmlBody(digestBody);
							singleMail.setCharset('UTF-8');
							singleMail.setUseSignature(false);
							singleMail.setSaveAsActivity(false);			
							digestEmailList.add(singleMail);
			        	}
		    		}
		    	}
		    	
		    	if(digestEmailList.size() > 0) {
		        	List<Messaging.SendEmailResult> results = Messaging.sendEmail(digestEmailList);
		        }
    		} catch (Exception ex) {
    			Utility.sendBatchFailedExceptionEmail('BatchNotificationDigest', ex);
                throw ex;
    		}
    }
    
    private String getDigestBody(Integer frequency, String logoUrl, String applicationName, People_Preference__c peoplePref,
    							List<App_Notification__c> notificationList, Integer subjectCount, String localekey, 
								Integer alertNotificationCount) {
		
		brandingInfo = EmailUtility.getBrandingInfo4People(peoplePref.People__r);
    	List<String> formatterList = new List<String>();
    	Map<String,Integer> notificationInfoMap = getNotiInfoMap(notificationList, peoplePref);
		if(alertNotificationCount > 0) {
			notificationInfoMap.put('countOfAlert', alertNotificationCount);
		}
    	String notificatioDigestHtmlBody = '';
    	Integer notiCount = 0;
    	for(Integer notificationCount : notificationInfoMap.values()){
    		notiCount = notiCount + notificationCount; 
    	}

    	if(String.isNotBlank(peoplePref.people__r.First_Name__c)){
    		formatterList.add(LocaleContext.getLabel(localekey, KEY_HI).replace('{{firstName}}', peoplePref.people__r.First_Name__c)); //{0}
    	} else {
    		formatterList.add(LocaleContext.getLabel(localekey, KEY_HI).replace('{{firstName}}', peoplePref.people__r.Last_Name__c)); //{0}
    	}

		String digestHeadingStr = KEY_DIGEST_SINGULAR_HEADING;
		if(subjectCount > 1){
			digestHeadingStr = KEY_DIGEST_PLURAL_HEADING;
		}

    	String bodyHeading = (LocaleContext.getLabel(localekey, digestHeadingStr)).replace('{{count}}', String.valueOf(subjectCount));
    	formatterList.add(bodyHeading); //{1}
    	
    	String notificationDigestGreeting = EmailUtility.format(notificationDigestPartMap.get('notificationDigestGreeting'), formatterList);
    	formatterList.clear();
    	
		String finalDigestEmailBody = getMapOfBoxTypeToHTMLBoxBody(notificationInfoMap, localekey, brandingInfo);
		
		formatterList.add(notificationDigestGreeting);
		formatterList.add(finalDigestEmailBody);
    	String digestBodyWithGreeting = EmailUtility.format(notificationDigestPartMap.get('notificationInfoWithGreetingHeader'),formatterList);
    	formatterList.clear();

		formatterList.add('<style>  @media all { .ExternalClass { width: 100%; } .ExternalClass, .ExternalClass p, .ExternalClass span, .ExternalClass font, .ExternalClass td, .ExternalClass div { line-height: 100%; } .apple-link a { color: inherit !important; font-family: inherit !important; font-size: inherit !important; font-weight: inherit !important; line-height: inherit !important; text-decoration: none !important; } } @media only screen and (max-width: 620px) { table[class=body] .wrapper, table[class=body] .header, table[class=body] .article { padding: 10px !important; } table[class=body] .content { padding: 0 !important; } table[class=body] .container { padding: 0 !important; width: 100% !important; } table[class=body] .main { border-left-width: 0 !important; border-radius: 0 !important; border-right-width: 0 !important; } table[class=body] .btn table { width: 100% !important; } table[class=body] .btn a { width: 100% !important; } table[class=body] .img-responsive { height: auto !important; max-width: 100% !important; width: auto !important; } td[class="mobile-hide"] { display: none; } .mobile-hide { display: none; } .wrapper, .header, .article { padding: 10px !important; } .content { padding: 0 !important; } .container { padding: 0 !important; width: 100% !important; } .main { border-left-width: 0 !important; border-radius: 0 !important; border-right-width: 0 !important; } .btn table { width: 100% !important; } .btn a { width: 100% !important; } .img-responsive { height: auto !important; max-width: 100% !important; width: auto !important; } } a[x-apple-data-detectors] { color: inherit !important; text-decoration: none !important; font-size: inherit !important; font-family: inherit !important; font-weight: inherit !important; line-height: inherit !important; } </style> <!--[if (gte mso 9)|(IE)]> <style type="text/css"> table {border-collapse: collapse;} </style> <![endif]-->'); //{0}
    	formatterList.add(logoUrl); //{1}
    	formatterList.add(LocaleContext.getLocalisedDateAsMMMMDDYYYY(DateTime.now(), localekey));//{2}
    	formatterList.add(digestBodyWithGreeting);//{3}
    	formatterList.add('' + SimpplrContext.salesforceBaseUrl  + Page.PageRedirector.getUrl() + '?userId=' + peoplePref.people__r.user__c +'&pageToRedirect='+Pages.MySettingsEmail+'&origin=nde');//{4}
    	formatterList.add(SimpplrContext.applicationName);//{5}
    	formatterList.add((LocaleContext.getLabel(localekey, KEY_COPYRIGHT_TEXT)).replace('{{year}}', String.valueOf(Date.today().year())));//{6} 
    	formatterList.add('http://www.simpplr.com');//{7}
		formatterList.add(LocaleContext.getLabel(localekey, KEY_DIGEST_HTML_TITLE));//{8}
		formatterList.add(LocaleContext.getLabel(localekey, KEY_POWERED_BY));//{9}
		formatterList.add(LocaleContext.getLabel(localekey, KEY_FOOTER_SETTINGS).replace('{{appName}}', SimpplrContext.applicationName));//{10}
		
		if('dark'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('000000');
		} else if('primary'.equalsIgnoreCase(brandingInfo.header_preset)) {
			formatterList.add(brandingInfo.general_primaryColor);
		} else if('default'.equalsIgnoreCase(brandingInfo.header_preset)){
			formatterList.add('ffffff');
		} else {
			formatterList.add(brandingInfo.header_backgroundColor);
		}

		notificatioDigestHtmlBody = EmailUtility.format(notificationDigestPartMap.get('notificationDigestWithHeaderFooter'), formatterList);
    	
		return notificatioDigestHtmlBody;
    }
    
    
    @testVisible 
    private static String getMapOfBoxTypeToHTMLBoxBody(Map<String,Integer> notificationInfoMap, String localekey, NotificationHelper.BrandingInfo brandingInfo){
    	List<String> formatterList = new List<String>();
		String notificationRows = '';
		/************************ ACTIVITY *********************************************/
		if(notificationInfoMap.get('follow') != null){
			formatterList.add(''+notificationInfoMap.get('follow'));
			if(notificationInfoMap.get('follow') != 1) {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_NEW_FOLLOWER_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_NEW_FOLLOWER_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('Endorse') != null){
			formatterList.add(''+notificationInfoMap.get('Endorse'));
			if(notificationInfoMap.get('Endorse') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_ENDORSEMENT_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_ENDORSEMENT_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		
		if(notificationInfoMap.get('privateSiteJoinReqApprovalCount') != null){
			formatterList.add(''+notificationInfoMap.get('privateSiteJoinReqApprovalCount'));
			if(notificationInfoMap.get('privateSiteJoinReqApprovalCount') != 1) {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_APPROVED_PRIVATE_SITE_JOIN_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_APPROVED_PRIVATE_SITE_JOIN_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		
		if(notificationInfoMap.get('privateSiteJoinReqRejectionCount') != null){
			formatterList.add(''+notificationInfoMap.get('privateSiteJoinReqRejectionCount'));
			if(notificationInfoMap.get('privateSiteJoinReqRejectionCount') !=1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_REJECTED_PRIVATE_SITE_JOIN_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_REJECTED_PRIVATE_SITE_JOIN_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		/************************ CONTENT *********************************************/
		if(notificationInfoMap.get('postOnContentCount') != null){
			formatterList.add(''+notificationInfoMap.get('postOnContentCount'));
			if(notificationInfoMap.get('postOnContentCount') != 1){
					formatterList.add(LocaleContext.getLabel(localekey, KEY_POST_ON_CONTENT_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_POST_ON_CONTENT_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('likesCount') != null){
			formatterList.add(''+notificationInfoMap.get('likesCount'));
			if(notificationInfoMap.get('likesCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_LIKE_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_LIKE_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('likesOrSharesCountOfContent') != null){
			formatterList.add(''+notificationInfoMap.get('likesOrSharesCountOfContent'));
			if(notificationInfoMap.get('likesOrSharesCountOfContent') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_LIKE_OR_SHARE_ON_CONTENT_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_LIKE_OR_SHARE_ON_CONTENT_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('sharesCount') != null){
			formatterList.add(''+notificationInfoMap.get('sharesCount'));
			if(notificationInfoMap.get('sharesCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_SHARE_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_SHARE_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('contentApprovedCount') != null){
			formatterList.add(''+notificationInfoMap.get('contentApprovedCount'));
			if(notificationInfoMap.get('contentApprovedCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_APPROVED_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_APPROVED_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		
		if(notificationInfoMap.get('contentRejectedCount') != null){
			formatterList.add(''+notificationInfoMap.get('contentRejectedCount'));
			if(notificationInfoMap.get('contentRejectedCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_REJECTED_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_REJECTED_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		
		/************************ FEED *********************************************/
		if(notificationInfoMap.get('postOnFeedCount') != null){
			formatterList.add(''+notificationInfoMap.get('postOnFeedCount'));
			if(notificationInfoMap.get('postOnFeedCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_FEED_POST_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_FEED_POST_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		
		if(notificationInfoMap.get('replysAfterMyReplyCount') != null){
			formatterList.add(''+notificationInfoMap.get('replysAfterMyReplyCount'));
			if(notificationInfoMap.get('replysAfterMyReplyCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_REPLIED_AFTER_YOU_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_REPLIED_AFTER_YOU_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		
		if(notificationInfoMap.get('replysToMyLikedPosCount') != null){
			formatterList.add(''+notificationInfoMap.get('replysToMyLikedPosCount'));
			if(notificationInfoMap.get('replysToMyLikedPosCount') != 1) {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_REPLY_ON_POST_I_LIKED_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_REPLY_ON_POST_I_LIKED_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		
		if(notificationInfoMap.get('replysToMyPostCount') != null){
			formatterList.add(''+notificationInfoMap.get('replysToMyPostCount'));
			if(notificationInfoMap.get('replysToMyPostCount') != 1) {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_REPLY_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_REPLY_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
	
		if(notificationInfoMap.get('contentRatedAsUnuseful') != null){
			formatterList.add(''+notificationInfoMap.get('contentRatedAsUnuseful'));
			if(notificationInfoMap.get('contentRatedAsUnuseful') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_RATED_UNUSEFUL_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_RATED_UNUSEFUL_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('contentRatedAsUseful') != null){
			formatterList.add(''+notificationInfoMap.get('contentRatedAsUseful'));
			if(notificationInfoMap.get('contentRatedAsUseful') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_RATED_USEFUL_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_RATED_USEFUL_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}if(notificationInfoMap.get('countOfUpdatedContent') != null){
			formatterList.add(''+notificationInfoMap.get('countOfUpdatedContent'));
			if(notificationInfoMap.get('countOfUpdatedContent') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_UPDATED_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_CONTENT_UPDATED_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}if(notificationInfoMap.get('countOfEventInvitation') != null){
			formatterList.add(''+notificationInfoMap.get('countOfEventInvitation'));
			if(notificationInfoMap.get('countOfEventInvitation') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_EVENT_INVITE_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_EVENT_INVITE_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}if(notificationInfoMap.get('countOfMustRead') != null){
			formatterList.add(''+notificationInfoMap.get('countOfMustRead'));
			if(notificationInfoMap.get('countOfMustRead') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_MUST_READ_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_MUST_READ_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}if(notificationInfoMap.get('countOfAlert') != null){
			formatterList.add(''+notificationInfoMap.get('countOfAlert'));
			if(notificationInfoMap.get('countOfAlert') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_ALERT_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_ALERT_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		/************************ QnA *********************************************/

		if(notificationInfoMap.get('mentionInQuestionCount') != null){
			formatterList.add(''+notificationInfoMap.get('mentionInQuestionCount'));
			if(notificationInfoMap.get('mentionInQuestionCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_MENTION_IN_QUESTION_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_MENTION_IN_QUESTION_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('mentionInAnswerCount') != null){
			formatterList.add(''+notificationInfoMap.get('mentionInAnswerCount'));
			if(notificationInfoMap.get('mentionInAnswerCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_MENTION_IN_ANSWER_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_MENTION_IN_ANSWER_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('voteOnAnswerCount') != null){
			formatterList.add(''+notificationInfoMap.get('voteOnAnswerCount'));
			if(notificationInfoMap.get('voteOnAnswerCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_VOTE_ON_ANSWER_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_VOTE_ON_ANSWER_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('answerApprovedCount') != null){
			formatterList.add(''+notificationInfoMap.get('answerApprovedCount'));
			if(notificationInfoMap.get('answerApprovedCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_APPROVAL_ON_ANSWER_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_APPROVAL_ON_ANSWER_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('newAnswerCount') != null){
			formatterList.add(''+notificationInfoMap.get('newAnswerCount'));
			if(notificationInfoMap.get('newAnswerCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_NEW_ANSWER_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_NEW_ANSWER_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('approvedAnswerToQuestionCount') != null){
			formatterList.add(''+notificationInfoMap.get('approvedAnswerToQuestionCount'));
			if(notificationInfoMap.get('approvedAnswerToQuestionCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_APPROVED_ANSWER_TO_QUESTION_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_APPROVED_ANSWER_TO_QUESTION_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('markedQuestionDuplicateCount') != null){
			formatterList.add(''+notificationInfoMap.get('markedQuestionDuplicateCount'));
			if(notificationInfoMap.get('markedQuestionDuplicateCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_DUPLICATE_QUESTION_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_DUPLICATE_QUESTION_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		if(notificationInfoMap.get('newQuestionCount') != null){
			formatterList.add(''+notificationInfoMap.get('newQuestionCount'));
			if(notificationInfoMap.get('newQuestionCount') != 1){
				formatterList.add(LocaleContext.getLabel(localekey, KEY_NEW_QUESTION_PLURAL));
			} else {
				formatterList.add(LocaleContext.getLabel(localekey, KEY_NEW_QUESTION_SINGULAR));
			}
			notificationRows = notificationRows + EmailUtility.format(notificationDigestPartMap.get('notificationRow'),formatterList);
			formatterList.clear();
		}
		
		String notificationInfoRows = '';
		String showAllNotifications = '';
		if(String.isNotBlank(notificationRows)){
			formatterList.add(PageContext.getPageURL(Pages.app)+'?u=/notifications'); 
			formatterList.add(brandingInfo.general_primaryColor);
			formatterList.add(LocaleContext.getLabel(localekey, KEY_VIEW_ALL));
			showAllNotifications = showAllNotifications + EmailUtility.format(notificationDigestPartMap.get('showAllNotifications'),formatterList);
			formatterList.clear();
			formatterList.add(notificationRows);
			formatterList.add(showAllNotifications);
			notificationInfoRows = notificationInfoRows + EmailUtility.format(notificationDigestPartMap.get('notificationInfoRows'),formatterList);
			formatterList.clear();
		}
		return notificationInfoRows;
    }
    
    @testVisible 
    private static Map<String,Integer> getNotiInfoMap(List<App_Notification__c> notificationList, People_Preference__c peoplePre){
    	Map<String,Integer> notificationInfoMap = new Map<String,Integer>();
		if(notificationList == null) {
			return notificationInfoMap;
		}
    	for(App_Notification__c noti : notificationList) {
    		if('follow'.equalsIgnoreCase(noti.sub_type__c)){
    			if(peoplePre.Email_Follows_Me__c) {
	    			if(notificationInfoMap.get('follow') == null){
		    			notificationInfoMap.put('follow',0);
	    			}
	    			notificationInfoMap.put('follow',notificationInfoMap.get('follow') + 1);
    			}
    		} else if('Endorse'.equalsIgnoreCase(noti.sub_type__c)){
            	if(peoplePre.Email_Endorses_Me__c){
	    			if(notificationInfoMap.get('Endorse') == null){
		    			notificationInfoMap.put('Endorse',0);
	    			}
	    			notificationInfoMap.put('Endorse',notificationInfoMap.get('Endorse') + 1);
    			}
    		} else if('update'.equalsIgnoreCase(noti.sub_type__c)){
    			if('Approved'.equalsIgnoreCase(noti.status__c)) {
    				if(noti.Object_Type__c.equalsIgnorecase('CollaborationGroupMemberRequest')){
    					if(peoplePre.Email_PrivateSiteMembership_Response__c) {
	    					if(notificationInfoMap.get('privateSiteJoinReqApprovalCount') == null){
			    			notificationInfoMap.put('privateSiteJoinReqApprovalCount',0);
			    			}
			    			notificationInfoMap.put('privateSiteJoinReqApprovalCount', notificationInfoMap.get('privateSiteJoinReqApprovalCount') + 1);
    					}
    				} else {
    					if(peoplePre.Email_Content_Submission_Response__c) {
	    					if(notificationInfoMap.get('contentApprovedCount') == null){
			    			notificationInfoMap.put('contentApprovedCount',0);
			    			}
			    			notificationInfoMap.put('contentApprovedCount', notificationInfoMap.get('contentApprovedCount') + 1);
    					}
    				}
    			} else {
    				if('CollaborationGroupMemberRequest'.equalsIgnorecase(noti.Object_Type__c)){
    					if(peoplePre.Email_PrivateSiteMembership_Response__c){
	    					if(notificationInfoMap.get('privateSiteJoinReqRejectionCount') == null){
			    				notificationInfoMap.put('privateSiteJoinReqRejectionCount',0);
			    			}
			    			notificationInfoMap.put('privateSiteJoinReqRejectionCount',notificationInfoMap.get('privateSiteJoinReqRejectionCount') + 1);
    					}
    				} else if('My_Content_Rejected'.equalsIgnoreCase(noti.Category__c)) {
    					if(peoplePre.Email_Content_Submission_Response__c){
	    					if(notificationInfoMap.get('contentRejectedCount') == null){
				    			notificationInfoMap.put('contentRejectedCount',0);
			    			}
			    			notificationInfoMap.put('contentRejectedCount',notificationInfoMap.get('contentRejectedCount') + 1);
    					}
    				}
    			}
    		} else if('post'.equalsIgnoreCase(noti.sub_type__c)){
    			if(String.isBlank(noti.Simpplr_Site__c) && !'Content_Post'.equalsIgnoreCase(noti.Category__c) && !'My_Content_Post'.equalsIgnoreCase(noti.Category__c) && !'My_Content_File_Post'.equalsIgnoreCase(noti.Category__c) && !'Posts_On_My_Profile'.equalsIgnoreCase(noti.Category__c)){
    				if(peoplePre.Email_Posts_To_Me__c) {
	    				if(notificationInfoMap.get('postOnFeedCount') == null){
			    			notificationInfoMap.put('postOnFeedCount',0);
		    			}
		    			notificationInfoMap.put('postOnFeedCount',notificationInfoMap.get('postOnFeedCount') + 1);
    				}
    			} else {
    				if(peoplePre.Email_My_Content_Post__c) {
	    				if(notificationInfoMap.get('postOnContentCount') == null){
			    			notificationInfoMap.put('postOnContentCount',0);
		    			}
		    			notificationInfoMap.put('postOnContentCount',notificationInfoMap.get('postOnContentCount') + 1);
    				}
    			}
    		} else if('like'.equalsIgnoreCase(noti.sub_type__c)){
				if(peoplePre.Email_Like_My_Post_Or_Comment__c && noti.Object_Id__c.subString(0,3).equalsIgnoreCase('0D5')){	
					if(notificationInfoMap.get('likesCount') == null){
		    			notificationInfoMap.put('likesCount',0);
	    			}
	    			notificationInfoMap.put('likesCount',notificationInfoMap.get('likesCount') + 1);
				}
				if(peoplePre.Email_My_Content_Like_Or_Share__c && noti.Object_Id__c.subString(0,3).equalsIgnoreCase(Utility.getSimpplrContentPrefix())){
					if(notificationInfoMap.get('likesOrSharesCountOfContent') == null){
		    			notificationInfoMap.put('likesOrSharesCountOfContent',0);
		    			}
		    			notificationInfoMap.put('likesOrSharesCountOfContent',notificationInfoMap.get('likesOrSharesCountOfContent') + 1);
				}
				if(peoplePre.Email_My_Content_Like_Or_Share__c && noti.Object_Id__c.subString(0,3).equalsIgnoreCase(Utility.getSimpplrFilePrefix()) && noti.Object_Type__c.equalsIgnoreCase('album')){
					if(notificationInfoMap.get('likesOrSharesCountOfContent') == null){
		    			notificationInfoMap.put('likesOrSharesCountOfContent',0);
		    			}
		    			notificationInfoMap.put('likesOrSharesCountOfContent',notificationInfoMap.get('likesOrSharesCountOfContent') + 1);
				}
				
    		} else if('comment'.equalsIgnoreCase(noti.sub_type__c)){
    			if('Also_Replied_On_Post'.equalsIgnoreCase(noti.Category__c) || 'Also_Replied_On_My_Post'.equalsIgnoreCase(noti.Category__c) || 
						'Also_Replied_On_Comment'.equalsIgnoreCase(noti.Category__c) || 'Also_Replied_On_My_Comment'.equalsIgnoreCase(noti.Category__c)){
    				if(peoplePre.Email_Comments_After_Me__c){
	    				if(notificationInfoMap.get('replysAfterMyReplyCount') == null){
			    			notificationInfoMap.put('replysAfterMyReplyCount',0);
		    			}
		    			notificationInfoMap.put('replysAfterMyReplyCount',notificationInfoMap.get('replysAfterMyReplyCount') + 1);
    				}
    			} else if('Comments_On_Post_I_Like'.equalsIgnoreCase(noti.Category__c)) {
    				if(peoplePre.Email_Comments_On_Post_I_Like__c){
	    				if(notificationInfoMap.get('replysToMyLikedPosCount') == null){
			    			notificationInfoMap.put('replysToMyLikedPosCount',0);
		    			}
		    			notificationInfoMap.put('replysToMyLikedPosCount',notificationInfoMap.get('replysToMyLikedPosCount') + 1);
    				}
    			} else {
    				if(peoplePre.Email_Comments_On_My_Post__c){
	    				if(notificationInfoMap.get('replysToMyPostCount') == null){
			    			notificationInfoMap.put('replysToMyPostCount',0);
		    			}
		    			notificationInfoMap.put('replysToMyPostCount',notificationInfoMap.get('replysToMyPostCount') + 1);
    				}
    			}
    		} else if('mention'.equalsIgnoreCase(noti.sub_type__c)){
				if('Mentions_In_Question'.equalsIgnoreCase(noti.Category__c)) {
					if(peoplePre.Email_QnA_Question_Mention__c){
						if(notificationInfoMap.get('mentionInQuestionCount') == null){
							notificationInfoMap.put('mentionInQuestionCount',0);
						}
						notificationInfoMap.put('mentionInQuestionCount',notificationInfoMap.get('mentionInQuestionCount') + 1);
					}
				} else if('Mentions_In_Answer'.equalsIgnoreCase(noti.Category__c)) {
					if(peoplePre.Email_QnA_Answer_Mention__c){
						if(notificationInfoMap.get('mentionInAnswerCount') == null){
							notificationInfoMap.put('mentionInAnswerCount',0);
						}
						notificationInfoMap.put('mentionInAnswerCount',notificationInfoMap.get('mentionInAnswerCount') + 1);
					}
				} else {
					if(peoplePre.Email_Posts_To_Me__c){
						if(notificationInfoMap.get('postOnFeedCount') == null){
							notificationInfoMap.put('postOnFeedCount',0);
						}
						notificationInfoMap.put('postOnFeedCount',notificationInfoMap.get('postOnFeedCount') + 1);
					}
				}
    		} else if('share'.equalsIgnoreCase(noti.sub_type__c)){
    			if(peoplePre.Email_Shares_My_Post__c && noti.Object_Id__c.subString(0,3).equalsIgnoreCase('0D5')){
					if(notificationInfoMap.get('sharesCount') == null){
		    			notificationInfoMap.put('sharesCount',0);
	    			}
					notificationInfoMap.put('sharesCount',notificationInfoMap.get('sharesCount') + 1);
    			}
    			if(peoplePre.Email_My_Content_Like_Or_Share__c && noti.Object_Id__c.subString(0,3).equalsIgnoreCase(Utility.getSimpplrContentPrefix())){
    				if(notificationInfoMap.get('likesOrSharesCountOfContent') == null){
		    			notificationInfoMap.put('likesOrSharesCountOfContent',0);
	    			}
					notificationInfoMap.put('likesOrSharesCountOfContent',notificationInfoMap.get('likesOrSharesCountOfContent') + 1);
    			}
    		}else if('rate'.equalsIgnoreCase(noti.sub_type__c)){
    			if(peoplePre.Email_Content_Useful__c) {
    				if(!'Content_Rated_Unuseful'.equalsIgnoreCase(noti.Category__c)){
		    			if(notificationInfoMap.get('contentRatedAsUseful') == null){
			    			notificationInfoMap.put('contentRatedAsUseful',0);
		    			}
		    			notificationInfoMap.put('contentRatedAsUseful',notificationInfoMap.get('contentRatedAsUseful') + 1);
    				}else{
    					if(notificationInfoMap.get('contentRatedAsUnuseful') == null){
			    			notificationInfoMap.put('contentRatedAsUnuseful',0);
		    			}
		    			notificationInfoMap.put('contentRatedAsUnuseful',notificationInfoMap.get('contentRatedAsUnuseful') + 1);
    				}
    			}
    		}else if('Content Update'.equalsIgnoreCase(noti.sub_type__c)){
    			if(peoplePre.Email_Updates_Content_Sites_I_Follow__c){
    				if(notificationInfoMap.get('countOfUpdatedContent') == null){
		    			notificationInfoMap.put('countOfUpdatedContent',0);
	    			}
	    			notificationInfoMap.put('countOfUpdatedContent',notificationInfoMap.get('countOfUpdatedContent') + 1);
    			}
    		}else if('Event Invite'.equalsIgnoreCase(noti.sub_type__c)){
    			if(peoplePre.Email_Event_Invite_More__c){
    				if(notificationInfoMap.get('countOfEventInvitation') == null){
		    			notificationInfoMap.put('countOfEventInvitation',0);
	    			}
	    			notificationInfoMap.put('countOfEventInvitation',notificationInfoMap.get('countOfEventInvitation') + 1);
    			}
    		}else if('Must Read'.equalsIgnoreCase(noti.sub_type__c)){
    			if(notificationInfoMap.get('countOfMustRead') == null){
	    			notificationInfoMap.put('countOfMustRead',0);
    			}
    			notificationInfoMap.put('countOfMustRead',notificationInfoMap.get('countOfMustRead') + 1);
    		} else if('new'.equalsIgnoreCase(noti.sub_type__c)) {
				if('New_Question'.equalsIgnoreCase(noti.Category__c)) {
					if(peoplePre.Email_QnA_New_Question__c){
						if(notificationInfoMap.get('newQuestionCount') == null){
							notificationInfoMap.put('newQuestionCount',0);
						}
						notificationInfoMap.put('newQuestionCount',notificationInfoMap.get('newQuestionCount') + 1);
					}
				} else if('New_Answer_To_Question'.equalsIgnoreCase(noti.Category__c)) {
					if(peoplePre.Email_QnA_New_Answer__c){
						if(notificationInfoMap.get('newAnswerCount') == null){
							notificationInfoMap.put('newAnswerCount',0);
						}
						notificationInfoMap.put('newAnswerCount',notificationInfoMap.get('newAnswerCount') + 1);
					}
				}
    		} else if('approved'.equalsIgnoreCase(noti.sub_type__c)) {
				if('Answer_Approved'.equalsIgnoreCase(noti.Category__c)) {
					if(peoplePre.Email_QnA_Answer_Approval__c){
						if(notificationInfoMap.get('answerApprovedCount') == null){
							notificationInfoMap.put('answerApprovedCount',0);
						}
						notificationInfoMap.put('answerApprovedCount',notificationInfoMap.get('answerApprovedCount') + 1);
					}
				} else if('Approved_Answer_To_Question'.equalsIgnoreCase(noti.Category__c)) {
					if(peoplePre.Email_QnA_New_Answer_Approval__c){
						if(notificationInfoMap.get('approvedAnswerToQuestionCount') == null){
							notificationInfoMap.put('approvedAnswerToQuestionCount',0);
						}
						notificationInfoMap.put('approvedAnswerToQuestionCount',notificationInfoMap.get('approvedAnswerToQuestionCount') + 1);
					}
				}
    		} else if('duplicate'.equalsIgnoreCase(noti.sub_type__c)) {
				if(peoplePre.Email_QnA_Duplicate_Question__c){
					if(notificationInfoMap.get('markedQuestionDuplicateCount') == null){
						notificationInfoMap.put('markedQuestionDuplicateCount',0);
					}
					notificationInfoMap.put('markedQuestionDuplicateCount',notificationInfoMap.get('markedQuestionDuplicateCount') + 1);
				}
    		} else if('vote'.equalsIgnoreCase(noti.sub_type__c)) {
				if(peoplePre.Email_QnA_Answer_Vote__c){
					if(notificationInfoMap.get('voteOnAnswerCount') == null){
						notificationInfoMap.put('voteOnAnswerCount',0);
					}
					notificationInfoMap.put('voteOnAnswerCount',notificationInfoMap.get('voteOnAnswerCount') + 1);
				}
			}
    	}
    	return notificationInfoMap;
    }

	/**
	 * @description returns alert notification count for a people record in execute method of batch
	 * @param alertCountWrapperClassObj  maps of alert counts for audienceIds/SiteIds
	 * @param mapOfaudienceIdsSiteIdsSet audienceIds, siteIds people records member or follower of
	 * @return Integer count of notification
	 */
	@TestVisible
	private static Integer getAlertNotificationCount(AlertCountWrapperClass alertCountWrapperClassObj, Map<String, Set<String>> mapOfaudienceIdsSiteIdsSet) {

		Set<String>	audienceIdSet = mapOfaudienceIdsSiteIdsSet.get('audienceIdSet');
		Set<String>	onlyMemberSiteIdSet = mapOfaudienceIdsSiteIdsSet.get('onlyMemberSiteIdSet');
		Set<String>	bothMemberFollowerSiteIdSet = mapOfaudienceIdsSiteIdsSet.get('bothMemberFollowerSiteIdSet');

		Integer count = 0;	
		
		
		for(String audienceId : alertCountWrapperClassObj.audienceAlertCountMap.keySet()) {
			if(audienceIdSet.contains(audienceId)) {
				count += alertCountWrapperClassObj.audienceAlertCountMap.get(audienceId);
			}
		}
		for(String siteId : alertCountWrapperClassObj.siteAlertOnlyMembersCountMap.keySet()) {
			if(onlyMemberSiteIdSet.contains(siteId)) {
				count += alertCountWrapperClassObj.siteAlertOnlyMembersCountMap.get(siteId);
			}
		}
		for(String siteId : alertCountWrapperClassObj.siteAlertBothMemberFollowerCountMap.keySet()) {
			if(bothMemberFollowerSiteIdSet.contains(siteId)) {
				count += alertCountWrapperClassObj.siteAlertBothMemberFollowerCountMap.get(siteId);
			}
		}

		return count;

	}

	/**
	 * @description wrapper class for alertCounts
	 */
	@TestVisible
	private Class AlertCountWrapperClass {
		Map<String, Integer> audienceAlertCountMap;
		Map<String, Integer> siteAlertOnlyMembersCountMap;
		Map<String, Integer> siteAlertBothMemberFollowerCountMap;
	}

	/**
	 * @description getAlertCountMap either AudienceId -> count or SiteId -> count
	 * @param audienceType whether its audience or site
	 * @param membershipType only incase of site whether it's for 'members' only or 'both members and followers'
	 * @param frequency period from last how many days
	 * @return Map<String, Integer> AudienceId/SiteId -> count
	 */	
	@TestVisible
	private Map<String, Integer> getAlertCountMap(String audienceType, String membershipType, Integer frequency) {

		Map<String, Integer> alertCountMap = new Map<String, Integer>();
		String alertQuery = '';
		Map<String, Object> soqlParamMap = new  Map<String, Object>();

		if('audience'.equalsIgnoreCase(audienceType)) {
		
			alertQuery = 'SELECT Audience__c audience, COUNT_DISTINCT(Id) alertCount from Alert__c WHERE Display_From_DateTime__c = LAST_N_DAYS:' + frequency + ' ' + 
							'AND Audience__c != null AND Is_Deleted__c = false GROUP BY Audience__c';

		} else if('site'.equalsIgnoreCase(audienceType)) {
			
			soqlParamMap.put('soqlParam1', membershipType);
			alertQuery = 'SELECT Recipient_Site__c audience, COUNT_DISTINCT(Id) alertCount FROM Alert__c  WHERE Display_From_DateTime__c = LAST_N_DAYS:' + frequency + ' ' + 
							' AND Recipient_Site__c != null AND Members_Type__c =: soqlParam1  AND Is_Deleted__c = false GROUP BY Recipient_Site__c';
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<AggregateResult> arList = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUSer(alertQuery, soqlParamMap);
		for(AggregateResult ar : arList) {
			alertCountMap.put((String)ar.get('audience'), (Integer)ar.get('alertCount'));
		}

		return alertCountMap;
	}
    
	/**
	 * @description getMapOfPeopleIdToAudienceSet by quering audienceMember based on ,audienceIdSet peopleIds
	 * @param audienceIdSet
	 * @param peopleIdSet
	 * @return Map<String, Set<String>> peopleId to Set of AudienceIds Map
	 */	
	@TestVisible
	private Map<String, Set<String>> getMapOfPeopleIdToAudienceSet(Set<String> audienceIdSet, Set<String> peopleIdSet) {
		
		Map<String, Set<String>> mapOfPeopleIdToAudienceSet = new Map<String, Set<String>>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', audienceIdSet);
		soqlParamMap.put('soqlParam2', peopleIdSet);
		String audienceMemberQuery = 'SELECT Id, Audience__c, People__c FROM Audience_Member__c ' + 
										'WHERE Audience__c =: soqlParam1 AND People__c =: soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);												
		List<Audience_Member__c> audienceMemberList = (List<Audience_Member__c>)SIMPESAPI.accessController().queryAsUSer(audienceMemberQuery, soqlParamMap);	


		for(Audience_Member__c audienceMemberObj : audienceMemberList) {
			String peopleId = audienceMemberObj.people__c;
			String audienceId = audienceMemberObj.Audience__c;
			if(!mapOfPeopleIdToAudienceSet.containsKey(peopleId)) {
				mapOfPeopleIdToAudienceSet.put(peopleId, new Set<String>()); 
			}
			Set<String> audienceSet = mapOfPeopleIdToAudienceSet.get(peopleId);
			audienceSet.add(audienceId);
			mapOfPeopleIdToAudienceSet.put(peopleId, audienceSet);
		}

		return mapOfPeopleIdToAudienceSet;
	}

	/**
	 * @description getMapOfPeopleIdToSiteSet by quering siteRole based on siteIds, peopleIds and membershipType
	 * @param siteIdSet
	 * @param peopleIdSet
	 * @param membershipType whether only members or both members and followers
	 * @return Map<String, Set<String>> peopleId to Set of siteIds Map
	 */
	@TestVisible
	private Map<String, Set<String>> getMapOfPeopleIdToSiteSet(Set<String> siteIdSet, Set<String> peopleIdSet, String membershipType) {

		Map<String, Set<String>> mapOfPeopleIdToSiteSet = new Map<String, Set<String>>();
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteIdSet);
		soqlParamMap.put('soqlParam2', peopleIdSet);
		
		String siteRoleQuery = 'SELECT Id, People__c, Site__c FROM Site_Role__c ' + 
								'WHERE Is_Deleted__c = false AND ' + 
								' Site__c =: soqlParam1 AND People__c =: soqlParam2';

		if('site_members'.equalsIgnoreCase(membershipType)) {
			siteRoleQuery += ' AND Is_Member__c = true';
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);												
		List<Site_Role__c> siteRoleList = (List<Site_Role__c>)SIMPESAPI.accessController().queryAsUSer(siteRoleQuery, soqlParamMap);	

		for(Site_Role__c siteRoleObj : siteRoleList) {

			String peopleId = siteRoleObj.people__c;
			String siteId = siteRoleObj.Site__c;
			if(!mapOfPeopleIdToSiteSet.containsKey(peopleId)) {
				mapOfPeopleIdToSiteSet.put(peopleId, new Set<String>()); 
			}
			Set<String> siteSet = mapOfPeopleIdToSiteSet.get(peopleId);
			siteSet.add(siteId);
			mapOfPeopleIdToSiteSet.put(peopleId, siteSet);

		}

		return mapOfPeopleIdToSiteSet;
	}

    public void finish(Database.BatchableContext BC){
    
    }
}