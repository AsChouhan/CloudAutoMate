/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class NotificationDao{ 
	
	public static final String KEY_LIKED_YOUR_COMMENT = 'push.notification.comment.like';
	public static final String KEY_COMMENT_MENTIONED_YOU = 'push.notification.comment.mention';
	public static final String KEY_COMMENT_REPLY = 'push.notification.comment.reply';
	
	public static final String KEY_ALBUM_PENDING_APPROVAL = 'push.notification.content.album.pending_approval';
	public static final String KEY_COMMENTED_ON_YOUR_CONTENT = 'push.notification.content.comment';
	public static final String KEY_COMMENTED_ON_MANAGE_CONTENT = 'push.notification.content.manage.comment';
	public static final String KEY_CONTENT_FILE_POST = 'push.notification.content.file_post';
	public static final String KEY_EVENT_PENDING_APPROVAL = 'push.notification.content.event.pending_approval';
	public static final String KEY_LIKED_CONTENT = 'push.notification.content.like';
	public static final String KEY_LIKED_MANAGE_CONTENT = 'push.notification.content.manage.like';
	public static final String KEY_SUBMITTED_PAGE_FOR_APPROVAL = 'push.notification.content.page.pending_approval';
	public static final String KEY_SHARED_CONTENT = 'push.notification.content.share';
	public static final String KEY_UPDATED_CONTENT = 'push.notification.content.update';
	public static final String KEY_LIKED_YOUR_REPLY_ON_CONTENT = 'push.notification.content_reply.like';
	public static final String KEY_LIKED_YOUR_REPLY_ON_CONTENT_NO_TEXT = 'push.notification.content_reply.like_no_text';
	public static final String KEY_INVITED_YOU_TO_EVENT = 'push.notification.event.invite';
	
	public static final String KEY_MEDIA_TYPE_PHOTO = 'common.media_type.photo';
	public static final String KEY_MEDIA_TYPE_VIDEO = 'common.media_type.video';
	public static final String KEY_CONTENT_ALBUM_MEDIA_LIKED = 'push.notification.content.album.media.liked';
	public static final String KEY_CONTENT_ALBUM_MEDIA_SHARED = 'push.notification.content.album.media.shared';
	public static final String KEY_CONTENT_ALBUM_MEDIA_CONTRIBUTED_LIKED = 'push.notification.content.album.media.liked.your';
	public static final String KEY_CONTENT_ALBUM_MEDIA_CONTRIBUTED_SHARED = 'push.notification.content.album.media.shared.your';

	public static final String KEY_CONTENT_ALBUM_SHARE = 'push.notification.content.album.share';
	public static final String KEY_CONTENT_BLOG_POST_SHARE = 'push.notification.content.blog_post.share';
	public static final String KEY_CONTENT_EVENT_SHARE = 'push.notification.content.event.share';
	public static final String KEY_CONTENT_PAGE_SHARE = 'push.notification.content.page.share';
	
	public static final String KEY_CONTENT_MANAGE_ALBUM_SHARE = 'push.notification.content.manage.album.share';
	public static final String KEY_CONTENT_MANAGE_BLOG_POST_SHARE = 'push.notification.content.manage.blog_post.share';
	public static final String KEY_CONTENT_MANAGE_EVENT_SHARE = 'push.notification.content.manage.event.share';
	public static final String KEY_CONTENT_MANAGE_PAGE_SHARE = 'push.notification.content.manage.page.share';
	
	public static final String KEY_POST_LIKE = 'push.notification.post.like';
	public static final String KEY_RECOGNITION_LIKE = 'push.notification.recognition.like';
	public static final String KEY_POST_NO_TEXT_LIKE = 'push.notification.post.no_text.like';
	public static final String KEY_POST_MENTIONED_YOU = 'push.notification.post.mention';
	public static final String KEY_RECOGNITION_MENTIONED_YOU = 'push.notification.recognition.mention';
	public static final String KEY_POST_REPLY = 'push.notification.post.reply';
	public static final String KEY_RECOGNITION_REPLY = 'push.notification.recognition.reply';
	public static final String KEY_REPLY_WITH_FILE = 'push.notification.reply.with_file';
	public static final String KEY_FEED_POLL_LIKE = 'push.notification.feed.poll.like';
	public static final String KEY_FEED_POLL_REPLY = 'push.notification.feed.poll.reply';
	public static final String KEY_POST_NO_TEXT_REPLY = 'push.notification.post.no_text.reply';
	public static final String KEY_POST_SHARED_WITH_YOU_REPLY = 'push.notification.post_shared_with_you.reply';
	public static final String KEY_POST_SHARED_WITH_YOU_NO_TEXT_REPLY = 'push.notification.post_shared_with_you.no_text.reply.';
	public static final String KEY_IS_FOLLOWING_YOU = 'push.notification.profile.follows_me';
	public static final String KEY_POST_REPLY_LIKE = 'push.notification.reply.like';
	public static final String KEY_POST_REPLY_NO_TEXT_LIKE = 'push.notification.reply.no_text.like';
	public static final String KEY_REPLY_MENTIONED_YOU = 'push.notification.reply.mention'; 
	public static final String KEY_REQUESTED_TO_JOIN_SITE = 'push.notification.site.request';
	public static final String KEY_SITE_MADE_YOU_MEMBER = 'push.notification.site.made_you_member';
	public static final String KEY_FEED_REPLIED_AFTER = 'push.notification.feed.replied_after';
	public static final String KEY_FEED_REPLIED_AFTER_OWN = 'push.notification.feed.replied_after_own';
	public static final String KEY_COMMENT_REPLIED_AFTER = 'push.notification.content.comment_replied_after';
	public static final String KEY_COMMENT_REPLIED_AFTER_OWN = 'push.notification.content.comment_replied_after_own';
	public static final String KEY_POST_YOU_LIKED_REPLY = 'push.notification.post.you_liked.reply';
	public static final String KEY_ALBUM_SUBMISSION_APPROVAL = 'push.notification.content.album.submission.approval';
	public static final String KEY_BLOG_SUBMISSION_APPROVAL = 'push.notification.content.blog post.submission.approval'; 
	public static final String KEY_EVENT_SUBMISSION_APPROVAL = 'push.notification.content.event.submission.approval'; 
	public static final String KEY_PAGE_SUBMISSION_APPROVAL = 'push.notification.content.page.submission.approval';
	public static final String KEY_PROFILE_EXPERTISE_ENDORSE = 'push.notification.profile.expertise.endorce';
	public static final String KEY_CONTENT_APPROVED = 'push.notification.content.approved'; 
	public static final String KEY_CONTENT_REJECTED = 'push.notification.content.rejected'; 
	public static final String KEY_CONTENT_MANAGE_APPROVED = 'push.notification.content.manage.approved'; 
	public static final String KEY_CONTENT_MANAGE_REJECTED = 'push.notification.content.manage.rejected'; 
	public static final String KEY_POSTED_TO_YOU_FILE_WITH_TEXT = 'push.notification.posted_to_you.file_with_text';
	public static final String KEY_POSTED_TO_YOU_FILE = 'push.notification.posted_to_you.file';
	public static final String KEY_POSTED_TO_YOU_POLL = 'push.notificaction.feed.poll.posted_to_you';
	public static final String KEY_FEED_POSTED_TO_YOU = 'push.notification.feed.posted_to_you';
	public static final String KEY_FEED_NO_TEXT_POSTED_TO_YOU = 'push.notification.feed.no_text.posted_to_you';
	public static final String KEY_PRIVATE_SITE_APPROVAL = 'push.notification.private_site.approval';
	public static final String KEY_FEED_POST_SHARE = 'push.notification.feed.post.share';
	public static final String KEY_FEED_RECOGNITION_SHARE = 'push.notification.feed.recognition.share';
	public static final String KEY_CONTENT_NOT_USEFUL = 'push.notification.content.not_useful';

	public static final String KEY_SUBSCRIPTION_REQUIRES_ATTENTION = 'push.notification.subscription.requires_attention';
	public static final String KEY_NEWSLETTER = 'push.notification.newsletter_shared';

	public static final String ACTION_APPROVE='Approved';
	public static final String ACTION_PENDING='Pending';
	public static final String ACTION_IGNORE='Ignored';
	public static final String ACTION_REJECTED='Rejected';

	// recognition
	public static final String KEY_RECOGNITION = 'push.notification.recognition';
	public static final String KEY_NEW_AWARD_10_DAYS_BEFORE = '.nomination.delegate.new_award.10_days_before';
	public static final String KEY_EXISTING_AWARD_7_DAYS_BEFORE = '.nomination.delegate.existing_award.7_days_before_no_rpt_msg';
	public static final String KEY_NEW_AWARD_3_DAYS_BEFORE = '.nomination.delegate.new_award.3_days_before';
	public static final String KEY_DELEGATE_OPEN = '.nomination.delegate.open';
	public static final String KEY_LOW_PARTICIPATION = '.nomination.delegate.low_participation';
	public static final String KEY_DELEGATE_CLOSE = '.nomination.delegate.close';
	public static final String KEY_OVERDUE_NEXT_OPEN = '.delegate.overdue.next_open';
	public static final String KEY_OVERDUE_NEXT_CLOSE = '.delegate.overdue.next_close';
	public static final String KEY_OVERDUE_WARNING = '.manager.overdue.warning';
	public static final String KEY_OVERDUE_AWARDED = '.manager.overdue.awarded';
	public static final String KEY_AWARD_SKIPPED = '.manager.skipped';
	public static final String KEY_AWARD_MISSED = '.manager.missed';
	public static final String KEY_USER_OPEN = '.nomination.user.open';
	public static final String KEY_USER_OPEN_N_AWARDS = '.nomination.user.open_n_awards';
	public static final String KEY_AWARD_GRANTED = '.user.award_granted';
	public static final String KEY_AWARD_WINNER = '.user.award_winner';
	public static final String KEY_DIRECT_NEW_AWARD = '.direct.delegate.new_award';
	public static final String KEY_DIRECT_EXISTING_AWARD = '.direct.delegate.existing_award';
	public static final String KEY_AWARD_DUE = '.direct.delegate.award_due';
	public static final String KEY_AWARD_CHEER = '.award.cheer';
	public static final String KEY_RECOGNITION_CHEER = '.recognition.cheer';
	public static final String KEY_AWARD_COMMENT = '.award.comment';
	public static final String KEY_RECOGNITION_COMMENT = '.recognition.comment';
	public static final String KEY_RECOGNITION_COMMENT_LIKE = '.comment.like';
	public static final String KEY_RECOGNITION_MANAGER_NOTIFY_AWARD = '.manager_notify_award';
	public static final String KEY_RECOGNITION_MANAGER_NOTIFY_RECOGNITION = '.manager_notify_recognition';
	public static final String KEY_COMMENT_MENTION_RECOGNITION = 'push.notification.comment.recognition.mention';

	public static final String CATEGORY_MY_CONTENT_APPROVED = 'My_Content_Approved';
	public static final String CATEGORY_MY_CONTENT_REJECTED = 'My_Content_Rejected';
	public static final String CATEGORY_MANAGE_CONTENT_APPROVED = 'Content_Approved';
	public static final String CATEGORY_MANAGE_CONTENT_REJECTED = 'Content_Rejected';

	public static final String OBJECT_TYPE_CHATTER_POST='Chatter Post';
	public static final String OBJECT_TYPE_Simpplr_Content='Simpplr Content';
	public static final String TYPE_REVIEW='Review';
	public static final String TYPE_REPORT='Report';
	public static final String TYPE_UPDATE='Update';
	public static final String TYPE_INFORMATION='Information';
	public static final String TYPE_ACTIONABLE='Actionable';
	/******content useful/not useful*********/
	public static final String CONTENT_RATE_SUBTYPE_USEFUL = 'Rate Useful';
	public static final String CONTENT_RATE_SUBTYPE_UNUSEFUL = 'Rate Unuseful';
	public static final String CONTENT_USEFUL_SUBJECT = ' rated Content ';
	
	private static  final String BASE_QUERY = 
	' Select Type__c, Submitter_Comment__c, Category__c, Snippet__c, Simpplr_Site__c, Simpplr_Site__r.name, Simpplr_Site__r.Landing_Page__c, Simpplr_Site__r.Title_Content_Version__c, Status__c,Sub_Type__c, Sent_By__r.New_Notification_Count__c, ' +
	' Sent_By__r.User__r.smallPhotoUrl, Sent_By__r.User__r.mediumPhotoUrl, Sent_By__r.user__r.FullPhotoURL, Sent_By__r.Full_Name__c, Sent_By__c,Sent_to__c, Object_Type__c,Parent_Object_Id__c, ' +
	' Object_Id__c, Is_Read__c, Is_New__c, Id, GUID__c, CreatedDate, Created_DateTime__c, Action_On__c, Content__r.Type__c, Content__r.Title__c, External_URL__c, ' +
	' Action_By__r.User__r.smallPhotoUrl, Action_By__r.User__r.mediumPhotoUrl, Action_By__r.user__r.FullPhotoURL, Action_By__r.Full_Name__c, Action_By__c, External_Id__c, ' + 
    ' Action_Count__c, RAB_1__c, RAB_2__c, RAB_3__c, RAB_1__r.Full_Name__c, RAB_2__r.Full_Name__c, RAB_3__r.Full_Name__c, Csv_Download_Request__c, Csv_Download_Request__r.Widget_Title__c, Csv_Download_Request__r.Widget_Tab__c, ' +
    ' RAB_1__r.User__r.smallPhotoUrl, RAB_1__r.User__r.mediumPhotoUrl, RAB_1__r.User__r.FullPhotoURL, ' + 
    ' RAB_2__r.User__r.smallPhotoUrl, RAB_2__r.User__r.mediumPhotoUrl, RAB_2__r.User__r.FullPhotoURL,' +
    ' RAB_3__r.User__r.smallPhotoUrl, RAB_3__r.User__r.mediumPhotoUrl, RAB_3__r.user__r.FullPhotoURL ' +
    ' FROM App_Notification__c ' + 
	' WHERE Sent_to__c=:peopleId AND Is_Deleted__c=false ' + 
	' And (Simpplr_Site__c = null OR (Simpplr_Site__r.is_active__c = true And Simpplr_Site__r.Show_In_Simpplr__c = true)) ';

	private static final Set<String> prohibitedObjectTypeSet = new Set<String>{'Mailer', 'Subscription'};
	private static final Set<String> prohibitedSubTypeSet = new Set<String>{'NL OnHold','Grant NL Access','Home Default','Email Notifications Default', 'Content Analytics', 'Site Analytics', 'App Analytics'};
	private static final Set<String> prohibitedCategorySet = new Set<String>{'Mobile_Promotion', 'Content_For_Review', 'Content_Expired', 'ServiceNow', 'Content_Rated_Unuseful', 'Content_Expired', 'Content_For_Review', 'Public_Site_Membership_Request_Auto_Approve', 'Csv_Download_Request'};

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public void markNotificationsAsRead(String peopleId) {
		List<App_Notification__c> notificationList = [SELECT id, Is_Read__c FROM App_Notification__c 
				WHERE Is_Read__c = false AND type__c = 'Information' AND Sent_to__c=:peopleId AND Is_Deleted__c=false WITH SECURITY_ENFORCED];
		
		if (!notificationList.isEmpty()) {
			for(App_Notification__c notification: notificationList) {
				notification.Is_Read__c = true;
			}
			
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{App_Notification__c.Is_Read__c};
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notificationList), listOfColumnsToBeUpdated);
		}
	}
	/**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
   @TestVisible 
   public void markNotificationAsSeen (String type) {
    	Set<String> notiIdSet = new Set<String>();
    	
	List<App_Notification__c> notificationList = [SELECT Is_New__c, Id, Type__c
            FROM App_Notification__c  
            WHERE Sent_to__c=:UserContext.peopleId AND Is_Deleted__c=false
            AND Is_New__c = true AND Type__c =: type WITH SECURITY_ENFORCED order by CreatedDate Desc Limit 9000];	

    	if (!notificationList.isEmpty()) {
            Set<String> setOfAppNotificationId = new Set<String>();
            
			for (App_Notification__c notification: notificationList) {
                notification.Is_New__c = false;
                setOfAppNotificationId.add(notification.id);
            }
            
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{App_Notification__c.Is_New__c};
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Notification__c>( 
                    notificationList), 
                    listOfColumnsToBeUpdated);

			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', setOfAppNotificationId);
			
            String queryString = 'SELECT id, App_Notification__c, Is_New__c'
                + ' FROM Ungrouped_Notification__c'
                + ' WHERE App_Notification__c IN :soqlParam1 AND Is_New__c = true'
                + ' Limit 9000';

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        	List<Ungrouped_Notification__c> listOfUngroupedNotifcation = (List<Ungrouped_Notification__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);


            if (!listOfUngroupedNotifcation.isEmpty()) {

                for(Ungrouped_Notification__c ungroupedNotiObj: listOfUngroupedNotifcation) {
                    ungroupedNotiObj.Is_New__c = false;
                }
                
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(new Map<Id, Ungrouped_Notification__c>( 
                    listOfUngroupedNotifcation), new List<Schema.SObjectField>{
                    Ungrouped_Notification__c.Is_New__c
                });
            }

		}
    	
    }
    
    	/**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
   @TestVisible 
   public void markNotificationAsSeenForMobile (String type, Boolean includeFeedNotification) {
    	Set<String> notiIdSet = new Set<String>();    	

		//Do not change to "== false" as Null value is expected in "includeFeedNotification" 
		if (includeFeedNotification != true) { 
			prohibitedObjectTypeSet.addAll(new Set<String>{'ContentFeedItem','ContentFeedComment', 'FeedItem','FeedComment'});
		}
		List<App_Notification__c> notificationList = [SELECT Is_New__c, Id, Type__c
												FROM App_Notification__c  WHERE Sent_to__c=:UserContext.peopleId AND Is_Deleted__c=false
												AND Is_New__c = true AND Type__c =: type AND Object_Type__c NOT IN: prohibitedObjectTypeSet
												AND Category__c NOT IN: prohibitedCategorySet
												AND Sub_Type__c NOT IN: prohibitedSubTypeSet WITH SECURITY_ENFORCED];										
    	if (!notificationList.isEmpty()) {
			for (App_Notification__c notification: notificationList) {
				notification.Is_New__c = false;
			}
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{App_Notification__c.Is_New__c};
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notificationList), listOfColumnsToBeUpdated);
		}
    	
    }
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public void setStateAsSeen(Set<String> notificationIdSet, string state) {
		
		List<App_Notification__c> notificationList = [SELECT id, Type__c,Is_New__c FROM App_Notification__c 
				WHERE Is_Deleted__c = false AND Is_New__c = true AND Id IN:notificationIdSet WITH SECURITY_ENFORCED];
				
		if (!notificationList.isEmpty()) {
			for (App_Notification__c notification: notificationList) {
				if (!'Actionable'.equalsIgnoreCase(notification.Type__c) ){
					notification.Is_New__c = false;
				}
			}
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{App_Notification__c.Is_New__c};
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notificationList), listOfColumnsToBeUpdated);
		}
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public List<App_Notification__c> getPopUpNotifications(String filter,Integer offset,Integer size, String timeStamp,
    		String peopleId, String origin, Boolean includeFeedNotification) {
    	Datetime sinceTimeStamp;
    	
    	String queryStr = String.escapeSingleQuotes(BASE_QUERY); 
		queryStr += ' AND (Not((Content__c != null) AND (Content__r.Type__c = null))) ';
		
		if ('actionable'.equalsIgnorecase(filter)) {
			queryStr += ' And type__c = \'Actionable\' AND (Sent_By__c = null Or Sent_By__r.user__r.isActive = true)';
			queryStr += ' AND Action_By__c=null';
			
		} else if('activity'.equalsIgnorecase(filter)) {
			queryStr += ' And type__c = \'Information\' ';	
		
		} else if(String.isBlank(filter)) {

            if (!String.isBlank(timeStamp)) {
                Long timeInMilliSeconds = Long.valueOf(timeStamp);
                sinceTimeStamp = DateTime.newInstance(timeInMilliSeconds);
                queryStr += ' And ((type__c = \'Actionable\' AND (Sent_By__c = null Or Sent_By__r.user__r.isActive = true) AND (Action_By__c=null OR lastmodifieddate >=:sinceTimeStamp)) OR type__c = \'Information\') ';
            } else {
                queryStr += ' And ((type__c = \'Actionable\' AND (Sent_By__c = null Or Sent_By__r.user__r.isActive = true) AND Action_By__c=null) OR type__c = \'Information\') ';
            }
        }

		if('mobile'.equalsIgnoreCase(origin)){
			queryStr += ' And Object_Type__c NOT IN: prohibitedObjectTypeSet ';
			queryStr += ' And Sub_Type__c NOT IN: prohibitedSubTypeSet ';
			queryStr += ' AND Category__c NOT IN: prohibitedCategorySet ';
		}
		if (!String.isBlank(timeStamp)) {
			Long timeInMilliSeconds = Long.valueOf(timeStamp);
			sinceTimeStamp = DateTime.newInstance(timeInMilliSeconds);
            queryStr += ' And (Created_DateTime__c >=:sinceTimeStamp or (type__c = \'Actionable\' and lastmodifieddate >=:sinceTimeStamp))';
    	}
		if(String.isBlank(filter)) {
			queryStr += ' Order By Type__c Asc, Created_DateTime__c desc limit:size OFFSET :offset';
		} else {
			queryStr += ' Order By Created_DateTime__c desc limit:size OFFSET :offset';
		}
		return Database.query(queryStr);
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public List<App_Notification__c> getAllNotifications(String peopleId, Integer offset, Integer recordLimit, String sortBy, String siteId, String filter, String origin) {
		String queryStr = String.escapeSingleQuotes(BASE_QUERY);  
		if ('actionable'.equalsIgnorecase(filter)) {
			queryStr += ' And type__c = \'Actionable\' And (Sent_By__c = null Or Sent_By__r.User__r.isActive = true)';
			
		} else if('activity'.equalsIgnorecase(filter)) {
			queryStr += ' And type__c = \'Information\' ';	
		
		} else if(String.isBlank(filter)) {
			queryStr += ' And ((type__c = \'Actionable\' AND Action_By__c=null And (Sent_By__c = null Or Sent_By__r.User__r.isActive = true)) OR type__c = \'Information\') ';
			
		}

		if('mobile'.equalsIgnorecase(origin)) {
			queryStr += ' And Category__c != \'native_video\' ';	
			queryStr += ' And Category__c NOT IN (\'Initiative_Starts\', \'Initiative_Ends\', \'New_Campaign\', \'Campaign_Ends\') ';
		}

	    	
    	if (siteId != null && !'all'.equalsIgnoreCase(siteId)) {
			queryStr += ' And Simpplr_Site__c =: siteId ';
    	}
		
		if(String.isBlank(filter)) {
			queryStr += ' Order By Type__c Asc, Created_DateTime__c desc ';
		} else {
			queryStr += ' Order By Created_DateTime__c desc ';
		}
		
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		
		return Database.query(queryStr);
		
	}
	
	public void createAndSendPushNotifications(String fromUser, List<NotificationDao.Notification> notificationObjList) {
		Map<String, App_Notification__c> userToNotificationMap;
		logger.logDebug('NotificationDao.createAndSendPushNotifications() -> notificationObjList :: ' + notificationObjList);
		List<App_Notification__c> appNotiListToInsert = new List<App_Notification__c>();
		List<Ungrouped_Notification__c> unGroupedNotiListToInsert = new List<Ungrouped_Notification__c>();

		String guId = generateGUID();

		// list of notification that will be grouped
		List<String> groupedNotiCategories = getGroupedNotificationCategories();

		for(Notification notificationWrapperObj : notificationObjList) {
			fromUser = String.isNotBlank(notificationWrapperObj.fromUser) ? notificationWrapperObj.fromUser :  fromUser;
			if(String.isNotBlank(notificationWrapperObj.toUser)) {
				notificationWrapperObj.GUID = guId;
				notificationWrapperObj.isNew = true;
				notificationWrapperObj.isRead = false;
				notificationWrapperObj.isDeleted = false;
				if ('NL OnHold'.equalsIgnoreCase(notificationWrapperObj.subType) || 
					'Must Read'.equalsIgnoreCase(notificationWrapperObj.subType) || 
					'Add Media Moderation'.equalsIgnoreCase(notificationWrapperObj.subType)) {	
					
					if ('Add Media Moderation'.equalsIgnoreCase(notificationWrapperObj.subType)) {
						notificationWrapperObj.isDeleted = true;
					}

					if(groupedNotiCategories.contains(notificationWrapperObj.categoryStr)) {
						unGroupedNotiListToInsert.add(convertToUngroupedNotiObj(notificationWrapperObj));
					} else {
						appNotiListToInsert.add(convertToAppNotiObj(notificationWrapperObj));
					}
				} else if (notificationWrapperObj.toUser != fromUser) {			
					notificationWrapperObj.fromUser = fromUser;
					if(groupedNotiCategories.contains(notificationWrapperObj.categoryStr)) {
						unGroupedNotiListToInsert.add(convertToUngroupedNotiObj(notificationWrapperObj));
					} else {
						appNotiListToInsert.add(convertToAppNotiObj(notificationWrapperObj));
					}
				}
			}
		}

		logger.logDebug('NotificationDao.createAndSendPushNotifications() -> unGroupedNotiListToInsert :: ' + unGroupedNotiListToInsert);
		logger.logDebug('NotificationDao.createAndSendPushNotifications() -> appNotiListToInsert :: ' + appNotiListToInsert);

		userToNotificationMap = getUserToNotificationMap(appNotiListToInsert, unGroupedNotiListToInsert);
		logger.logDebug('NotificationDao.createAndSendPushNotifications() -> userToNotificationMap :: ' + userToNotificationMap);
		
		if (userToNotificationMap.isEmpty() == false && System.isBatch() == false){
			sendPushNotifications(JSON.serialize(userToNotificationMap.values()));
        }
        
	}

	private Map<String, App_Notification__c> getUserToNotificationMap(List<App_Notification__c> appNotiListToInsert, List<Ungrouped_Notification__c> unGroupedNotiListToInsert) {
		Map<String, App_Notification__c> userToNotificationMap = new Map<String, App_Notification__c>();
		// appNotiListToInsert
		if(!appNotiListToInsert.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			SIMPESAPI.accessController().insertAsUser(appNotiListToInsert,
														new List<Schema.SObjectField>{
															App_Notification__c.Action_By__c,
															App_Notification__c.Action_Comment__c,
															App_Notification__c.Action_On__c,
															App_Notification__c.Sent_By__c,
															App_Notification__c.Sent_to__c,
															App_Notification__c.GUID__c,
															App_Notification__c.Object_Id__c,
															App_Notification__c.Object_Type__c,
															App_Notification__c.Status__c,
															App_Notification__c.Type__c,
															App_Notification__c.Sub_Type__c,
															App_Notification__c.Is_Read__c,
															App_Notification__c.Is_New__c,
															App_Notification__c.Parent__c,
															App_Notification__c.Parent_Object_Id__c,
															App_Notification__c.Submitter_Comment__c,
															App_Notification__c.Snippet__c,
															App_Notification__c.Created_DateTime__c,
															App_Notification__c.Content__c,
															App_Notification__c.Simpplr_Site__c,
															App_Notification__c.Is_Deleted__c,
															App_Notification__c.Category__c
														}
													 );


			for(App_Notification__c notiObj : appNotiListToInsert){
				userToNotificationMap.put(notiObj.Sent_to__c, notiObj);
			}
		}

		// unGroupedNotiListToInsert
		if(!unGroupedNotiListToInsert.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			SIMPESAPI.accessController().insertAsUser(unGroupedNotiListToInsert,
														new List<Schema.SObjectField>{
															Ungrouped_Notification__c.App_Notification__c,
															Ungrouped_Notification__c.Sent_By__c,
															Ungrouped_Notification__c.Sent_to__c,
															Ungrouped_Notification__c.GUID__c,
															Ungrouped_Notification__c.Object_Id__c,
															Ungrouped_Notification__c.Object_Type__c,
															Ungrouped_Notification__c.Status__c,
															Ungrouped_Notification__c.Type__c,
															Ungrouped_Notification__c.Sub_Type__c,
															Ungrouped_Notification__c.Is_Read__c,
															Ungrouped_Notification__c.Is_New__c,
															Ungrouped_Notification__c.Parent_Object_Id__c,
															Ungrouped_Notification__c.Submitter_Comment__c,
															Ungrouped_Notification__c.Snippet__c,
															Ungrouped_Notification__c.Created_DateTime__c,
															Ungrouped_Notification__c.Content__c,
															Ungrouped_Notification__c.Simpplr_Site__c,
															Ungrouped_Notification__c.Is_Deleted__c,
															Ungrouped_Notification__c.Category__c
														}
													 );

			for(Ungrouped_Notification__c unGroupedObj : unGroupedNotiListToInsert) {
				userToNotificationMap.put(unGroupedObj.Sent_to__c, ungroupedNotiToAppNotiWrapper(unGroupedObj));
			}
		}

		return userToNotificationMap;
	}

	private App_Notification__c ungroupedNotiToAppNotiWrapper(Ungrouped_Notification__c uNotiObj) {
		App_Notification__c appNotiObj = new App_Notification__c();

		appNotiObj.Id = uNotiObj.App_Notification__c;
		appNotiObj.Sent_By__c = uNotiObj.Sent_By__c;
		appNotiObj.Sent_to__c = uNotiObj.Sent_to__c;
		appNotiObj.GUID__c = uNotiObj.GUID__c;
		appNotiObj.Object_Id__c = uNotiObj.Object_Id__c;
		appNotiObj.Object_Type__c = uNotiObj.Object_Type__c;
		appNotiObj.Status__c = uNotiObj.Status__c;
		appNotiObj.Type__c = uNotiObj.Type__c;
		appNotiObj.Sub_Type__c = uNotiObj.Sub_Type__c;
		appNotiObj.Is_Read__c = uNotiObj.Is_Read__c;
		appNotiObj.Is_New__c = uNotiObj.Is_New__c == NULL ? true : uNotiObj.Is_New__c;
		appNotiObj.Submitter_Comment__c = uNotiObj.Submitter_Comment__c;
		appNotiObj.Snippet__c = uNotiObj.Snippet__c;
		appNotiObj.Created_DateTime__c = uNotiObj.Created_DateTime__c;
		appNotiObj.Content__c = uNotiObj.Content__c;
		appNotiObj.Simpplr_Site__c = uNotiObj.Simpplr_Site__c;
		appNotiObj.Is_Deleted__c = uNotiObj.Is_Deleted__c;
		appNotiObj.Category__c = uNotiObj.Category__c;
		appNotiObj.Parent_Object_Id__c = uNotiObj.Parent_Object_Id__c;
		
		return appNotiObj;
	}

	public List<String> getGroupedNotificationCategories() {
		
		List<String> groupedNotiCategories = new List<String>();

		// SITE
		groupedNotiCategories.add('Private_Site_Membership_Requests');
		groupedNotiCategories.add('Public_Site_Membership_Requests');
		
		// CONTENT
		groupedNotiCategories.add('My_Content_Share');
		groupedNotiCategories.add('Content_Share');
		
		groupedNotiCategories.add('My_Content_Like');
		groupedNotiCategories.add('Content_Like');
		groupedNotiCategories.add('Like_My_Comment_On_Content');
		groupedNotiCategories.add('Like_My_Reply_On_Content');
		
		groupedNotiCategories.add('My_Content_Post');
		groupedNotiCategories.add('Content_Post');
		groupedNotiCategories.add('Also_Replied_On_Comment');
		groupedNotiCategories.add('Also_Replied_On_My_Comment');
		groupedNotiCategories.add('Comments_On_My_Content_Post');

		// FEED
		groupedNotiCategories.add('Shares_My_Post');

		groupedNotiCategories.add('Like_My_Post');
		groupedNotiCategories.add('Like_My_Reply');

		groupedNotiCategories.add('Also_Replied_On_Post');
		groupedNotiCategories.add('Also_Replied_On_My_Post');

		groupedNotiCategories.add('Comments_On_My_Post');
		groupedNotiCategories.add('Also_Replied_On_Comment');
		
		groupedNotiCategories.add('Like_My_Poll');
		groupedNotiCategories.add('Comments_On_My_Poll');
		groupedNotiCategories.add('Comments_On_Post_On_My_Profile');

		// QnA
		groupedNotiCategories.add('Voted_On_Answer');
		groupedNotiCategories.add('New_Answer_To_Question');
		groupedNotiCategories.add('New_Question');
		groupedNotiCategories.add('New_Question_In_Content');
		groupedNotiCategories.add('New_Answer_In_Content');
		return groupedNotiCategories;
	}

	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    private static List<App_Notification__c> convertToAppNotiObjList(List<Notification> ln) {
		
		List<App_Notification__c> listOfNotification=new List<App_Notification__c> ();
		
		for(Notification sn: ln) {
			listOfNotification.add(convertToAppNotiObj(sn));
		}
		return listOfNotification;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    
    private static App_Notification__c convertToAppNotiObj(Notification notificationWrapObj) {
		logger.logDebug('convertToAppNotiObj '+notificationWrapObj);
		return new App_Notification__c(
			//id=nt.id,
			Action_By__c = notificationWrapObj.actionByUser,
			Action_Comment__c = notificationWrapObj.actionComment,
			Action_On__c = notificationWrapObj.actionOn,
			Sent_By__c = notificationWrapObj.fromUser,
			Sent_to__c = notificationWrapObj.toUser,
			GUID__c = notificationWrapObj.GUID,
			Object_Id__c = notificationWrapObj.objectID,
			Object_Type__c = notificationWrapObj.objectType,
			Parent_Object_Id__c = notificationWrapObj.parentObjectID,
			Status__c = notificationWrapObj.status,
			Type__c = notificationWrapObj.type,
			Sub_Type__c = notificationWrapObj.subType,
			Is_Read__c = notificationWrapObj.isRead,
			Is_New__c = notificationWrapObj.isNew == NULL ? true : notificationWrapObj.isNew,
			Parent__c = notificationWrapObj.partentID,
			Submitter_Comment__c = notificationWrapObj.submitterComment,
			Snippet__c = notificationWrapObj.snippet,
			Created_DateTime__c = DateTime.now(),
			Content__c = notificationWrapObj.contentId,
			Simpplr_Site__c = notificationWrapObj.siteId,
			Is_Deleted__c = notificationWrapObj.isDeleted == true ? true : false,
			Category__c = notificationWrapObj.categoryStr
		);
	}

	private static Ungrouped_Notification__c convertToUngroupedNotiObj(Notification notificationWrapObj) {
		return new Ungrouped_Notification__c(
			App_Notification__c = null,
			Sent_By__c = notificationWrapObj.fromUser,
			Sent_to__c = notificationWrapObj.toUser,
			GUID__c = notificationWrapObj.GUID,
			Object_Id__c = notificationWrapObj.objectID,
			Object_Type__c = notificationWrapObj.objectType,
			Parent_Object_Id__c= notificationWrapObj.parentObjectID,
			Status__c = notificationWrapObj.status,
			Type__c = notificationWrapObj.type,
			Sub_Type__c = notificationWrapObj.subType,
			Is_Read__c = notificationWrapObj.isRead,
			Is_New__c = notificationWrapObj.isNew == NULL ? true : notificationWrapObj.isNew,
			Submitter_Comment__c = notificationWrapObj.submitterComment,
			Snippet__c = notificationWrapObj.snippet,
			Created_DateTime__c = DateTime.now(),
			Content__c = notificationWrapObj.contentId,
			Simpplr_Site__c = notificationWrapObj.siteId,
			Is_Deleted__c = notificationWrapObj.isDeleted == true ? true : false,
			Category__c = notificationWrapObj.categoryStr
		);
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static AggregateResult[] getNewNotificationCount(String peopleId) {
		AggregateResult[] groupedResults = [SELECT Type__c notifcationType, Count(Id)
											
											FROM App_Notification__c
											Where ((Is_New__c = true And Type__c = 'Information') OR (Action_By__c = NULL AND Type__c = 'Actionable' AND (Sent_By__c = null Or Sent_By__r.User__r.isActive = true))) 
											And Is_Read__c = false 
											And Is_Deleted__c = false
											And Sent_to__c=:peopleId
											And (Simpplr_Site__c = null OR (Simpplr_Site__r.Is_active__c = true And Simpplr_Site__r.Show_In_Simpplr__c = true))
											AND (Not((Content__c != null) AND (Content__r.Type__c = null)))
											WITH SECURITY_ENFORCED GROUP BY Type__c];
		return groupedResults;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static AggregateResult[] getNewNotificationCountForMobile(String peopleId) { 
		AggregateResult[] groupedResults = [SELECT Type__c notifcationType, Count(Id)
											FROM App_Notification__c
											Where ((Is_New__c = true And Type__c = 'Information') OR (Action_By__c = NULL AND Type__c = 'Actionable' AND (Sent_By__c = null Or Sent_By__r.User__r.isActive = true))) 
											And Is_Read__c = false 
											And Is_Deleted__c = false
											And Sent_to__c=:peopleId
											And (Simpplr_Site__c = null OR (Simpplr_Site__r.Is_active__c = true And Simpplr_Site__r.Show_In_Simpplr__c = true))
											AND Object_Type__c NOT IN: prohibitedObjectTypeSet
											And Category__c NOT IN: prohibitedCategorySet
											AND Sub_Type__c NOT IN :prohibitedSubTypeSet 
											AND (Not((Content__c != null) AND (Content__r.Type__c = null)))
											WITH SECURITY_ENFORCED GROUP BY Type__c];
		return groupedResults;
	}
	
	public static Integer getNewNotificationCount() {
    	String peopleId = UserContext.peopleId;
    	Integer newNotiCount = [SELECT Count() FROM App_Notification__c
				Where ((Is_New__c = true And Type__c = 'Information') OR (Action_By__c = NULL AND Type__c = 'Actionable' AND (Sent_By__c = null Or Sent_By__r.User__r.isActive = true))) 
				And Is_Read__c = false 
				And Is_Deleted__c = false
				And Sent_to__c=:peopleId
				And (Simpplr_Site__c = null OR (Simpplr_Site__r.is_active__c = true And Simpplr_Site__r.Show_In_Simpplr__c = true))
				AND Object_Type__c NOT IN: prohibitedObjectTypeSet
				AND Category__c NOT IN: prohibitedCategorySet
				AND Sub_Type__c NOT IN :prohibitedSubTypeSet
				AND (Not((Content__c != null) AND (Content__r.Type__c = null))) WITH SECURITY_ENFORCED];
    	return newNotiCount;
    }
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static List<App_Notification__c> getTotalNotificationCount(String peopleId) {
		List<App_Notification__c> notificationList = [SELECT Id, Type__c
											FROM App_Notification__c
											Where Is_Deleted__c = false
											And (Simpplr_Site__c = null OR (Simpplr_Site__r.is_active__c = true And Simpplr_Site__r.Show_In_Simpplr__c = true))
											AND ((Action_By__c = NULL AND Type__c = 'Actionable') OR (Type__c = 'Information'))
											AND Sent_to__c=:peopleId
											AND (Not((Content__c != null) AND (Content__r.Type__c = null)))
											WITH SECURITY_ENFORCED LIMIT 1000];
		return notificationList;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static String generateGUID() {
		return UserContext.id + '-' + System.currentTimeMillis();
	}
	
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static Map<String,App_Notification__c> createNotifications(List<App_Notification__c> listOfSN) {
    	Map<String,App_Notification__c> userToNotificationMap = new Map<String,App_Notification__c>();

		List<Schema.SObjectField> listOfColumnsToBeSet = getListOfColumnsToBeSet(listOfSN);

		if(!listOfSN.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(listOfSN,	listOfColumnsToBeSet);

			listOfSN = (List<App_Notification__c>)result.getInsertedObjects();
		}
		
		if(System.isBatch() == false){
    		sendPushNotifications(JSON.serialize(listOfSN));
    	}
    	
		for (App_Notification__c notiObj : listOfSN) {
			userToNotificationMap.put(notiObj.Sent_to__c, notiObj);
		}

		return userToNotificationMap;
	}

	private static List<Schema.SObjectField> getListOfColumnsToBeSet(List<App_Notification__c> listOfSN) {

		List<Schema.SObjectField> listOfColumnsToBeSet = new List<Schema.SObjectField>{
			App_Notification__c.Action_By__c,
			App_Notification__c.Action_Comment__c,
			App_Notification__c.Action_On__c,
			App_Notification__c.Category__c,
			App_Notification__c.Created_DateTime__c,
			App_Notification__c.GUID__c,
			App_Notification__c.Object_Id__c,
			App_Notification__c.Object_Type__c,
			App_Notification__c.Sent_By__c,
			App_Notification__c.Sent_to__c,
			App_Notification__c.Snippet__c,
			App_Notification__c.Status__c,
			App_Notification__c.Sub_Type__c,
			App_Notification__c.Submitter_Comment__c,
			App_Notification__c.Type__c
		};


		if(! listOfSN.isEmpty()) {
			App_Notification__c notiObj = listOfSN[0];

			if(notiObj.Content__c != null) {
				listOfColumnsToBeSet.add(App_Notification__c.Content__c);
			}
			
			if(notiObj.Simpplr_Site__c != null) {
				listOfColumnsToBeSet.add(App_Notification__c.Simpplr_Site__c);
			}

			if(notiObj.Parent__c != null) {
				listOfColumnsToBeSet.add(App_Notification__c.Parent__c);
			}

			if(notiObj.Parent_Object_Id__c != null) {
				listOfColumnsToBeSet.add(App_Notification__c.Parent_Object_Id__c);
			}
		}

		return listOfColumnsToBeSet;
	}
	
	private static Map<String, List<PushNotifcationWrapper>> getPushNotiBasedOnUserPref(List<App_Notification__c> listOfSN) {
		Set<String> targetPeopleSet = new Set<String>();
		Set<Id> siteIdSet = new Set<Id>();
		Set<Id> contentIdSet = new Set<Id>();

		Map<String, List<PushNotifcationWrapper>> pushNotiJsonMap = new Map<String, List<PushNotifcationWrapper>>();

		List<PushNotifcationWrapper> pushNotiListMobile = new List<PushNotifcationWrapper>();
		List<PushNotifcationWrapper> pushNotiListBrowser = new List<PushNotifcationWrapper>();
		
		Set<String> sentByPeopleIdsSet = new Set<String>();
		for(App_Notification__c appNotiObj: listOfSN) {
			targetPeopleSet.add(appNotiObj.Sent_To__c);
			sentByPeopleIdsSet.add(appNotiObj.Sent_By__c);
			if(appNotiObj.Simpplr_Site__c != null) {
				siteIdSet.add(appNotiObj.Simpplr_Site__c);
			}
			if(appNotiObj.Content__c != null) {
				contentIdSet.add(appNotiObj.Content__c);
			}
		}

		Map<String, String> sentByIdVsNameMap = new Map<String, String>();

		if(!sentByPeopleIdsSet.isEmpty()) {
			List<People__c> sentByList = [Select Id, Name, Full_Name__c FROM People__c where id=:sentByPeopleIdsSet WITH SECURITY_ENFORCED];
			for(People__c peopleObj : sentByList) {
				sentByIdVsNameMap.put(peopleObj.Id, peopleObj.Full_Name__c);
			}
		}

		Map<Id, Simpplr_Content__c> contentMap = new Map<Id, Simpplr_Content__c>();
		if(!contentIdSet.isEmpty()) {
			contentMap = new Map<Id, Simpplr_Content__c>([Select id, Type__c, Title__c from Simpplr_Content__c where id=:contentIdSet WITH SECURITY_ENFORCED]);
		}
		Map<Id, Simpplr_Site__c> siteMap = new Map<Id, Simpplr_Site__c>();
		if(!siteIdSet.isEmpty()) {
			siteMap = new Map<Id, Simpplr_Site__c>([Select id, Name from Simpplr_Site__c where id=:siteIdSet WITH SECURITY_ENFORCED]);
		}
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', targetPeopleSet);
		String query = 'SELECT Id,people__r.Full_Name__c,Native_Mob_Content_Submit_Moderation__c, Native_Mob_Private_Site_Membership_Req__c, Native_Mobile_Follows_Me__c,' 
						+ ' Native_Mobile_My_Content_Like_Or_Share__c, Native_Mobile_Event_Invite_More__c, people__r.New_Notification_Count__c, people__r.Mobile_Token_Android__c,'  
						+ ' people__r.Mobile_Token_IOS__c, people__r.Mobile_App_Version_Android__c, people__r.Mobile_App_Version_IOS__c, people__r.Mobile_App_Type_Android__c,' 
						+ ' people__r.Mobile_App_Type_IOS__c, Mobile_Allow_Notifications__c, Mobile_Event_Invite_More__c, Mobile_Comments_After_Me__c, Mobile_Comments_On_My_Post__c,' 
						+ ' people__r.Mobile_FCM_ID_iOS__c, people__r.Mobile_Bundle_ID_iOS__c, people__r.Mobile_FCM_ID_Android__c, people__r.Mobile_Bundle_ID_Android__c,' 
						+ ' Mobile_Comments_On_Post_I_Like__c, Mobile_Content_Useful__c, Receive_Content_Useful_Notifications__c, Mobile_Content_Submitted_For_Moderation__c, Mobile_Endorses_Me__c, Mobile_Follows_Me__c,' 
						+ ' Mobile_Like_My_Post_Or_Comment__c, Mobile_Posts_To_Me__c, Mobile_My_Content_Approved__c, Mobile_My_Content_Post__c, Mobile_My_Content_Rejected__c, Mobile_My_Content_Like_Or_Share__c,'  
						+ ' Mobile_Private_Site_Membership_Requests__c, Mobile_Shares_My_Post__c, Mobile_PrivateSiteMembership_Response__c, Mobile_Content_Submission_Response__c, Allow_Simpplr_Emails__c,' 
						+ ' Native_Mob_Like_My_Post_Or_Comment__c, Native_Mob_Comments_On_My_Post__c, Native_Mob_My_Content_Post__c, Native_Mob_Posts_To_Me__c, User__r.LanguageLocaleKey,' 
						+ ' Native_Mob_Shares_My_Post__c, Native_Mob_Replied_On_liked_Post__c, Native_Mob_Reply_After_Me__c, Native_MobPrivateSiteMembership_Resp__c,' 
						+ ' Native_Mob_Content_ApproveReject__c, Native_Mob_Endorse_Expertise__c,'  
						+ ' Allow_Browser_Notifications__c, Browser_Follows_Me__c, Browser_Event_Invite__c, Browser_Endorse_Expertise__c, Browser_Like_My_Post_Or_Comment__c,'  
						+ ' Browser_Content_LikesShares_On_Published__c, Browser_Shares_My_Post__c, Browser_Site_Membership_Request__c, Browser_Content_Submission__c,'  
						+ ' Browser_Comments_After_Me__c, Browser_Comments_On_Liked_Post__c, Browser_Comments_On_My_Post__c, Browser_Posts_To_Me__c,' 
						+ ' Browser_PrivateSiteMembership_Resp__c, Browser_Content_Approval_Rejection__c, Browser_Content_Feedback__c, Browser_Content_Comments_On_Published__c,' 
						+ ' Browser_Newsletter__c, Browser_Recognition__c, Desktop_Newsletter__c, Email_Newsletter__c, Mobile_Newsletter__c, Native_Mobile_Newsletter__c, Native_Mobile_Surveys__c'  
						+ ' FROM People_Preference__c where People__c IN : soqlParam1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People_Preference__c> peoplePrefList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

		Map<String,People_Preference__c> peoplePrefMap = new Map<String,People_Preference__c>();
		Set<String> localeSet = new Set<String>{'en_US'};
		for(People_Preference__c peoplePref : peoplePrefList) {
			peoplePrefMap.put(peoplePref.people__c,peoplePref);
			localeSet.add(Utility.getSimpplrLanguageLocaleKey(peoplePref.User__r.languagelocalekey));
		}
		LocaleContext.getAllLabelMap('PushNotifications', new List<String>(localeSet));
		for(App_Notification__c noti : listOfSN){
			Boolean sendAndroidNotifications = false;
			Boolean sendIOSNotifications = false;
			Boolean sendWebNotifications = false;

			Boolean sendNativeAndroidNotification = false;
			Boolean sendNativeiOSNotification = false;
			People_Preference__c preferObj = peoplePrefMap.get(noti.Sent_To__c);
			
			String contentType = '';
			String contentTitle = '';
			String siteName = '';
			String mediaType = '';
			if(preferObj != null) {
				if(	(String.isNotBlank(preferObj.people__r.Mobile_Token_Android__c) && !'Native'.equalsIgnoreCase(preferObj.people__r.Mobile_App_Type_Android__c)) ||
						(String.isNotBlank(preferObj.people__r.Mobile_Token_IOS__c) && !'Native'.equalsIgnoreCase(preferObj.people__r.Mobile_App_Type_iOS__c))) {
					if(checkHybridPushNotification(noti, preferObj)) {
						if(String.isNotBlank(preferObj.people__r.Mobile_Token_Android__c) && 
								!'Native'.equalsIgnoreCase(preferObj.people__r.Mobile_App_Type_Android__c)){
							sendAndroidNotifications = true;
						}
						if(String.isNotBlank(preferObj.people__r.Mobile_Token_iOS__c) && 
								!'Native'.equalsIgnoreCase(preferObj.people__r.Mobile_App_Type_iOS__c)){
							sendIOSNotifications = true;
						}
					}
				}
				
				if(	(String.isNotBlank(preferObj.people__r.Mobile_Token_Android__c) && 'Native'.equalsIgnoreCase(preferObj.people__r.Mobile_App_Type_Android__c)) ||
						(String.isNotBlank(preferObj.people__r.Mobile_Token_IOS__c) && 'Native'.equalsIgnoreCase(preferObj.people__r.Mobile_App_Type_iOS__c))) {
					if(checkNativePushNotification(noti, preferObj)) {
						if(String.isNotBlank(preferObj.people__r.Mobile_Token_Android__c) && 
								'Native'.equalsIgnoreCase(preferObj.people__r.Mobile_App_Type_Android__c)){
							sendAndroidNotifications = true;
							sendNativeAndroidNotification = true;
						}
						if(String.isNotBlank(preferObj.people__r.Mobile_Token_iOS__c) && 
								'Native'.equalsIgnoreCase(preferObj.people__r.Mobile_App_Type_iOS__c)){
							sendIOSNotifications = true;
							sendNativeiOSNotification = true;
						}
					}
				}

				if('Yes'.equalsIgnoreCase(preferObj.Allow_Browser_Notifications__c) && hasOptedForBrowserNotification(noti, preferObj)) {
					sendWebNotifications = true;
				}

				if(sendAndroidNotifications) {
					PushNotifcationWrapper pushNotiAndroidObj = new PushNotifcationWrapper();
					pushNotiAndroidObj.deviceToken = preferObj.people__r.Mobile_Token_Android__c;
					pushNotiAndroidObj.deviceType = 'android';
					pushNotiAndroidObj.appType = String.isNotBlank(preferObj.people__r.Mobile_App_Type_Android__c)? preferObj.people__r.Mobile_App_Type_Android__c: 'hybrid';
					pushNotiAndroidObj.appVersion = preferObj.people__r.Mobile_App_Version_Android__c;
					pushNotiAndroidObj.Url = getNotificationURL(noti);
					pushNotiAndroidObj.badge = Integer.valueOf(preferObj.people__r.New_Notification_Count__c);
					pushNotiAndroidObj.sound = 'default';
					pushNotiAndroidObj.contentType = noti.Object_Type__c;
					pushNotiAndroidObj.fcmId = preferObj.people__r.Mobile_FCM_ID_Android__c;
					pushNotiAndroidObj.bundleId = preferObj.people__r.Mobile_Bundle_ID_Android__c;
					pushNotiAndroidObj.isMustRead = 'Must Read'.equalsIgnoreCase(noti.Sub_Type__c)? true : false;
					
					pushNotiAndroidObj.notificationId = noti.id;
					Set<String> contentTypeSet = new Set<String>{'Event', 'Page', 'Album', 'BlogPost'};
					if(contentTypeSet.contains(noti.Object_Type__c) && noti.Parent_Object_Id__c == null){
						pushNotiAndroidObj.notificationType = 'content';
						pushNotiAndroidObj.contentId = noti.Object_Id__c;
						pushNotiAndroidObj.siteId = noti.Simpplr_Site__c;
						
						contentType = noti.Object_Type__c;
					} else if(noti.Parent_Object_Id__c != null && 'Album'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiAndroidObj.notificationType = 'album_media';
						pushNotiAndroidObj.contentId = noti.Parent_Object_Id__c;
						pushNotiAndroidObj.fileId = noti.Object_Id__c;

						contentType = noti.Object_Type__c;
						mediaType = (String.isBlank(pushNotiAndroidObj.fileId) ? 'Photo' : 'Video');
					} else if('Endorse'.equalsIgnoreCase(noti.Sub_Type__c)){
						pushNotiAndroidObj.notificationType = 'endorse';
						pushNotiAndroidObj.sentById = noti.Sent_By__c;
					} else if('Follow'.equalsIgnoreCase(noti.Sub_Type__c)){
						pushNotiAndroidObj.notificationType = 'follow';
						pushNotiAndroidObj.sentById = noti.Sent_By__c;
					} else if('CollaborationGroup'.equalsIgnoreCase(noti.Object_Type__c) 
						|| 'CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)
						|| 'SiteMember'.equalsIgnoreCase(noti.Object_Type__c)
						|| 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)){
						
						pushNotiAndroidObj.notificationType = 'site';
						pushNotiAndroidObj.siteId = noti.Simpplr_Site__c;
						
						if(('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c))
							&& 'Pending'.equalsIgnoreCase(noti.Status__c)){
							pushNotiAndroidObj.privateSiteRequestId = noti.Object_Id__c;	
						}
					} else if('File'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiAndroidObj.notificationType = 'file';
						pushNotiAndroidObj.fileId = noti.Object_Id__c;
					
					} else if('ContentFeedItem'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiAndroidObj.notificationType = 'content_feed';
						pushNotiAndroidObj.feedId = noti.Object_id__c;
						pushNotiAndroidObj.contentId = noti.Content__c;
						
						
					} else if('ContentFeedComment'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiAndroidObj.notificationType = 'content_feed';
						pushNotiAndroidObj.feedId = noti.Parent_Object_id__c;
						pushNotiAndroidObj.feedCommentId = noti.Object_id__c;
						pushNotiAndroidObj.contentId = noti.Content__c;
						
					
					} else if('FeedItem'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiAndroidObj.notificationType = 'home_feed';
						pushNotiAndroidObj.feedId = noti.Object_id__c;
						
						
					} else if('FeedComment'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiAndroidObj.notificationType = 'home_feed';
						pushNotiAndroidObj.feedId = noti.Parent_Object_id__c;
						pushNotiAndroidObj.feedCommentId = noti.Object_id__c;
						
					} else if('Newsletter'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiAndroidObj.notificationType = 'newsletter';
						pushNotiAndroidObj.newsletterId = noti.Parent_Object_id__c;
					}

					if(siteMap.containsKey(noti.Simpplr_Site__c)) {
						siteName = siteMap.get(noti.Simpplr_Site__c).name;
					}
					if(contentMap.containsKey(noti.Content__c)) {
						contentType = contentMap.get(noti.Content__c).Type__c;
						contentTitle = contentMap.get(noti.Content__c).Title__c;
					}

					String languageLocaleKey = Utility.getSimpplrLanguageLocaleKey(preferObj.User__r.LanguageLocaleKey);
					if(sendNativeiOSNotification && (String.isBlank(preferObj.people__r.Mobile_App_Version_Android__c) 
								|| preferObj.people__r.Mobile_App_Version_Android__c.startsWith('1.'))) {
						languageLocaleKey = 'en_US';
					} 
					pushNotiAndroidObj.notificationtext = getNotificationtext(noti, languageLocaleKey, contentType, contentTitle, mediaType, siteName, sentByIdVsNameMap);
					
					if('recognition'.equalsIgnoreCase(noti.category__c) || 'recognition_hub'.endsWithIgnoreCase(noti.Category__c)){
						// this specific change is made to align with mobile notification redirections
						pushNotiAndroidObj.notificationType = noti.Category__c;
						pushNotiAndroidObj.category = noti.Object_Type__c;
						pushNotiAndroidObj.objectId = noti.Object_Id__c;
					} else {
						pushNotiAndroidObj.category = noti.Category__c;
					}
					
					if(String.isBlank(pushNotiAndroidObj.sentById)){
						pushNotiAndroidObj.sentById = noti.Sent_By__c;
					}
					pushNotiAndroidObj.isClickable = true;
					if('Information'.equalsIgnoreCase(noti.Type__c)){
						if('Rejected'.equalsIgnoreCase(noti.Status__c)){
							pushNotiAndroidObj.isClickable = false;	
						}
						pushNotiAndroidObj.isActionable = false; 
					} else {
						pushNotiAndroidObj.isActionable = true;
					}
					if('Actionable'.equalsIgnoreCase(noti.Type__c) 
							&& ('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)) 
							&& 'Pending'.equalsIgnoreCase(noti.Status__c)){
						pushNotiAndroidObj.privateSiteRequestId = noti.Object_Id__c;	
					}
					if('Native'.equalsIgnoreCase(pushNotiAndroidObj.appType)){
						if(sendNativeMobileAppPushNoti(noti) == true){
							pushNotiListMobile.add(pushNotiAndroidObj);
						}
					} else {
						pushNotiListMobile.add(pushNotiAndroidObj);
					}
				}
				if(sendIOSNotifications) {
					PushNotifcationWrapper pushNotiIOSObj = new PushNotifcationWrapper();
					pushNotiIOSObj.deviceToken = preferObj.people__r.Mobile_Token_IOS__c;
					pushNotiIOSObj.deviceType = 'ios';
					pushNotiIOSObj.appType = String.isNotBlank(preferObj.people__r.Mobile_App_Type_iOS__c)?preferObj.people__r.Mobile_App_Type_iOS__c:'hybrid';
					pushNotiIOSObj.appVersion = preferObj.people__r.Mobile_App_Version_iOS__c;
					pushNotiIOSObj.Url = getNotificationURL(noti);
					pushNotiIOSObj.notificationId = noti.id;
					pushNotiIOSObj.badge = Integer.valueOf(preferObj.people__r.New_Notification_Count__c);
					pushNotiIOSObj.sound = 'default';
					pushNotiIOSObj.contentType = noti.Object_Type__c;
					pushNotiIOSObj.fcmId = preferObj.people__r.Mobile_FCM_ID_iOS__c;
					pushNotiIOSObj.bundleId = preferObj.people__r.Mobile_Bundle_ID_iOS__c;
					pushNotiIOSObj.isMustRead = 'Must Read'.equalsIgnoreCase(noti.Sub_Type__c)? true : false;
					
					Set<String> contentTypeSet = new Set<String>{'News','Event', 'Page', 'Album', 'BlogPost'};
					if(contentTypeSet.contains(noti.Object_Type__c) && noti.Parent_Object_Id__c == null){
						pushNotiIOSObj.notificationType = 'content';
						pushNotiIOSObj.contentId = noti.Object_Id__c;
						pushNotiIOSObj.siteId = noti.Simpplr_Site__c;

						contentType = noti.Object_Type__c;
					} else if(noti.Parent_Object_Id__c != null && 'Album'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiIOSObj.notificationType = 'album_media';
						pushNotiIOSObj.contentId = noti.Parent_Object_Id__c;
						pushNotiIOSObj.fileId = noti.Object_Id__c;

						contentType = noti.Object_Type__c;
						mediaType = (String.isBlank(pushNotiIOSObj.fileId) ? 'Photo' : 'Video');
					} else if('Endorse'.equalsIgnoreCase(noti.Sub_Type__c)){
						pushNotiIOSObj.notificationType = 'endorse';
						pushNotiIOSObj.sentById = noti.Object_Id__c;
					} else if('Follow'.equalsIgnoreCase(noti.Sub_Type__c)){
						pushNotiIOSObj.notificationType = 'follow';
						pushNotiIOSObj.sentById = noti.Sent_By__c;
					} else if('CollaborationGroup'.equalsIgnoreCase(noti.Object_Type__c) 
						|| 'CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)
						|| 'SiteMember'.equalsIgnoreCase(noti.Object_Type__c)
						|| 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)){
						
						pushNotiIOSObj.notificationType = 'site';
						pushNotiIOSObj.siteId = noti.Simpplr_Site__c;
						
						if(('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c))
							&& 'Pending'.equalsIgnoreCase(noti.Status__c)){
							pushNotiIOSObj.privateSiteRequestId = noti.Object_Id__c;	
						}
					} else if('File'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiIOSObj.notificationType = 'file';
						pushNotiIOSObj.fileId = noti.Object_Id__c;
					
					} else if('ContentFeedItem'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiIOSObj.notificationType = 'content_feed';
						pushNotiIOSObj.feedId = noti.Object_id__c;
						pushNotiIOSObj.contentId = noti.Content__c;
						
						
					} else if('ContentFeedComment'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiIOSObj.notificationType = 'content_feed';
						pushNotiIOSObj.feedId = noti.Parent_Object_id__c;
						pushNotiIOSObj.feedCommentId = noti.Object_id__c;
						pushNotiIOSObj.contentId = noti.Content__c;
						
					} else if('FeedItem'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiIOSObj.notificationType = 'home_feed';
						pushNotiIOSObj.feedId = noti.Object_id__c;
						
						
					} else if('FeedComment'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiIOSObj.notificationType = 'home_feed';
						pushNotiIOSObj.feedId = noti.Parent_Object_id__c;
						pushNotiIOSObj.feedCommentId = noti.Object_id__c;
						
					} else if('Newsletter'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiIOSObj.notificationType = 'newsletter';
						pushNotiIOSObj.newsletterId = noti.Parent_Object_id__c;
					}
					if(siteMap.containsKey(noti.Simpplr_Site__c)) {
						siteName = siteMap.get(noti.Simpplr_Site__c).name;
					}
					if(contentMap.containsKey(noti.Content__c)) {
							contentType = contentMap.get(noti.Content__c).Type__c;
							contentTitle = contentMap.get(noti.Content__c).Title__c;
					}
					String languageLocaleKey = Utility.getSimpplrLanguageLocaleKey(preferObj.User__r.LanguageLocaleKey);
					if(sendNativeiOSNotification && (String.isBlank(preferObj.people__r.Mobile_App_Version_IOS__c) || 
														preferObj.people__r.Mobile_App_Version_IOS__c.startsWith('1.'))) {
						languageLocaleKey = 'en_US';
					}                                
					pushNotiIOSObj.notificationtext = getNotificationtext(noti, languageLocaleKey, contentType, contentTitle, mediaType, siteName, sentByIdVsNameMap);

					if('recognition'.equalsIgnoreCase(noti.category__c) || 'recognition_hub'.endsWithIgnoreCase(noti.Category__c)){
						// this specific change is made to align with mobile notification redirections
						pushNotiIOSObj.notificationType = noti.Category__c;
						pushNotiIOSObj.category = noti.Object_Type__c;
						pushNotiIOSObj.objectId = noti.Object_Id__c;
					} else {
						pushNotiIOSObj.category = noti.Category__c;
					}

					if(String.isBlank(pushNotiIOSObj.sentById)){
						pushNotiIOSObj.sentById = noti.Sent_By__c;
					}
					
					pushNotiIOSObj.isClickable = true;
					if('Information'.equalsIgnoreCase(noti.Type__c)){
						if('Rejected'.equalsIgnoreCase(noti.Status__c)){
							pushNotiIOSObj.isClickable = false;	
						}
						pushNotiIOSObj.isActionable = false; 
					} else {
						pushNotiIOSObj.isActionable = true;
					}
					if('Actionable'.equalsIgnoreCase(noti.Type__c) &&
						('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c))
						&& 'Pending'.equalsIgnoreCase(noti.Status__c)){
						pushNotiIOSObj.privateSiteRequestId = noti.Object_Id__c;	
					}
					
					if('Native'.equalsIgnoreCase(pushNotiIOSObj.appType)){
						if(sendNativeMobileAppPushNoti(noti)){
							pushNotiListMobile.add(pushNotiIOSObj);
						}
					} else {
						pushNotiListMobile.add(pushNotiIOSObj);
					}
				}

				// send web-push notifications
				if(sendWebNotifications) {
					PushNotifcationWrapper pushNotiWebObj = new PushNotifcationWrapper();
					pushNotiWebObj.deviceType = 'browser';
					pushNotiWebObj.Url = getNotificationURL(noti);
					pushNotiWebObj.notificationId = noti.id;
					pushNotiWebObj.contentType = noti.Object_Type__c;
					pushNotiWebObj.isMustRead = 'Must Read'.equalsIgnoreCase(noti.Sub_Type__c)? true : false;
					
					Set<String> contentTypeSet = new Set<String>{'News','Event', 'Page', 'Album', 'BlogPost'};
					if(contentTypeSet.contains(noti.Object_Type__c) && noti.Parent_Object_Id__c == null){
						pushNotiWebObj.notificationType = 'content';
						pushNotiWebObj.contentId = noti.Object_Id__c;
						pushNotiWebObj.siteId = noti.Simpplr_Site__c;

						contentType = noti.Object_Type__c;
					} else if(noti.Parent_Object_Id__c != null && 'Album'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiWebObj.notificationType = 'album_media';
						pushNotiWebObj.contentId = noti.Parent_Object_Id__c;
						pushNotiWebObj.fileId = noti.Object_Id__c;

						contentType = noti.Object_Type__c;
						mediaType = (String.isBlank(pushNotiWebObj.fileId) ? 'Photo' : 'Video');
					} else if('Endorse'.equalsIgnoreCase(noti.Sub_Type__c)){
						pushNotiWebObj.notificationType = 'endorse';
						pushNotiWebObj.sentById = noti.Object_Id__c;
					} else if('Follow'.equalsIgnoreCase(noti.Sub_Type__c)){
						pushNotiWebObj.notificationType = 'follow';
						pushNotiWebObj.sentById = noti.Sent_By__c;
					} else if('CollaborationGroup'.equalsIgnoreCase(noti.Object_Type__c) 
							|| 'CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)
							|| 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)
							|| 'SiteMember'.equalsIgnoreCase(noti.Object_Type__c)){
						
						pushNotiWebObj.notificationType = 'site';
						pushNotiWebObj.siteId = noti.Simpplr_Site__c;
						
						if(('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c))
							&& 'Pending'.equalsIgnoreCase(noti.Status__c)){
								pushNotiWebObj.privateSiteRequestId = noti.Object_Id__c;	
						}
					} else if('Subscription'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiWebObj.notificationType = 'subscription';
						pushNotiWebObj.siteId = noti.Simpplr_Site__c;
					
					} else if('File'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiWebObj.notificationType = 'file';
						pushNotiWebObj.fileId = noti.Object_Id__c;
					
					} else if('ContentFeedItem'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiWebObj.notificationType = 'content_feed';
						pushNotiWebObj.feedId = noti.Object_id__c;
						pushNotiWebObj.contentId = noti.Content__c;
						
						
					} else if('ContentFeedComment'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiWebObj.notificationType = 'content_feed';
						pushNotiWebObj.feedId = noti.Parent_Object_id__c;
						pushNotiWebObj.feedCommentId = noti.Object_id__c;
						pushNotiWebObj.contentId = noti.Content__c;
						
					} else if('FeedItem'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiWebObj.notificationType = 'home_feed';
						pushNotiWebObj.feedId = noti.Object_id__c;
						
						
					} else if('FeedComment'.equalsIgnorecase(noti.Object_Type__c)) {
						pushNotiWebObj.notificationType = 'home_feed';
						pushNotiWebObj.feedId = noti.Parent_Object_id__c;
						pushNotiWebObj.feedCommentId = noti.Object_id__c;
						
					} else if('Newsletter'.equalsIgnoreCase(noti.Object_Type__c)){
						pushNotiWebObj.notificationType = 'newsletter';
						pushNotiWebObj.newsletterId = noti.Parent_Object_id__c;
					}

					if(siteMap.containsKey(noti.Simpplr_Site__c)) {
						siteName = siteMap.get(noti.Simpplr_Site__c).name;
					}
					if(contentMap.containsKey(noti.Content__c)) {
							contentType = contentMap.get(noti.Content__c).Type__c;
							contentTitle = contentMap.get(noti.Content__c).Title__c;
					}
					String languageLocaleKey = Utility.getSimpplrLanguageLocaleKey(preferObj.User__r.LanguageLocaleKey);
					if(sendNativeiOSNotification && (String.isBlank(preferObj.people__r.Mobile_App_Version_IOS__c) || 
														preferObj.people__r.Mobile_App_Version_IOS__c.startsWith('1.'))) {
						languageLocaleKey = 'en_US';
					}

					pushNotiWebObj.title = SimpplrContext.applicationName;
					pushNotiWebObj.notificationtext = getNotificationtext(noti, languageLocaleKey, contentType, contentTitle, mediaType, siteName, sentByIdVsNameMap);
					pushNotiWebObj.category = noti.Category__c;
					
					pushNotiWebObj.sentToId = ((String)noti.Sent_To__c).substring(0, 15);
					if(String.isBlank(pushNotiWebObj.sentById)){
						pushNotiWebObj.sentById = noti.Sent_By__c;
					}
					
					pushNotiWebObj.isClickable = true;
					if('Information'.equalsIgnoreCase(noti.Type__c)){
						if('Rejected'.equalsIgnoreCase(noti.Status__c)){
							pushNotiWebObj.isClickable = false;	
						}
						pushNotiWebObj.isActionable = false; 
					} else {
						pushNotiWebObj.isActionable = true;
					}
					if('Actionable'.equalsIgnoreCase(noti.Type__c)
							&& ('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c))
							&& 'Pending'.equalsIgnoreCase(noti.Status__c)){
						pushNotiWebObj.privateSiteRequestId = noti.Object_Id__c;	
					}
					
					if('Native'.equalsIgnoreCase(pushNotiWebObj.appType)){
						if(sendNativeMobileAppPushNoti(noti)){
							pushNotiListBrowser.add(pushNotiWebObj);
						}
					} else {
						pushNotiListBrowser.add(pushNotiWebObj);
					}
				}
			}
		}
			
		if( !pushNotiListMobile.isEmpty() ) {
			pushNotiJsonMap.put('pushNotiListMobile', pushNotiListMobile);
		}

		if( !pushNotiListBrowser.isEmpty() ) {
			pushNotiJsonMap.put('pushNotiListBrowser', pushNotiListBrowser);
		}
	
		return pushNotiJsonMap;
	}

	private static Boolean hasOptedForBrowserNotification(App_Notification__c noti, People_Preference__c peoplePref) {
		Boolean sendNotiCheck = false;
		if('Event Invite'.equalsIgnoreCase(noti.Sub_Type__c)){
			if(peoplePref.Browser_Event_Invite__c) {
				sendNotiCheck = true;
			}
		} else if('Endorse'.equalsIgnoreCase(noti.Sub_Type__c)){
			if(peoplePref.Browser_Endorse_Expertise__c) {	
				sendNotiCheck = true;
			}
		} else if('follow'.equalsIgnoreCase(noti.Sub_Type__c)){
			if(peoplePref.Browser_Follows_Me__c) {
				sendNotiCheck = true;
			}
    	} else if('like'.equalsIgnoreCase(noti.Sub_Type__c)){
			Set<String> contentTypeSet = new Set<String>{'News','Event', 'Page', 'Album', 'BlogPost'};
			if(contentTypeSet.contains(noti.Object_Type__c)) {
				if(peoplePref.Browser_Content_LikesShares_On_Published__c) {
                    sendNotiCheck = true;
                }
            } else if(peoplePref.Browser_Like_My_Post_Or_Comment__c){
					sendNotiCheck = true;
			}
    	} else if('share'.equalsIgnoreCase(noti.Sub_Type__c)){
			Set<String> contentTypeSet = new Set<String>{'News','Event', 'Page', 'Album', 'BlogPost'};
			if(contentTypeSet.contains(noti.Object_Type__c)) {
				if(peoplePref.Browser_Content_LikesShares_On_Published__c) {
                    sendNotiCheck = true;
				}
			} 
			if('FeedItem'.equalsIgnoreCase(noti.Object_Type__c)) {
				if(peoplePref.Browser_Shares_My_Post__c) {
					sendNotiCheck = true;	
				}
			}
    	} else if('review'.equalsIgnoreCase(noti.Sub_Type__c)){
			if('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)) {
				if(peoplePref.Browser_Site_Membership_Request__c) {
					sendNotiCheck = true;
				}
			}else {
				if(peoplePref.Browser_Content_Submission__c) {
					sendNotiCheck = true;
				}
			}
    	} else if('Comment'.equalsIgnorecase(noti.Sub_Type__c)){
			if('Also_Replied_On_Post'.equalsIgnorecase(noti.Category__c) || 	
				'Also_Replied_On_My_Post'.equalsIgnorecase(noti.Category__c) ||
				'Also_Replied_On_Comment'.equalsIgnorecase(noti.Category__c) || 
				'Also_Replied_On_My_Comment'.equalsIgnorecase(noti.Category__c)) {
				if(peoplePref.Browser_Comments_After_Me__c) {
					sendNotiCheck = true;
				}
			} else if('Comments_On_Post_I_Like'.equalsIgnorecase(noti.Category__c)) {
				if(peoplePref.Browser_Comments_On_Liked_Post__c) {
					sendNotiCheck = true;
				}
			} else {
				if(peoplePref.Browser_Comments_On_My_Post__c) {
					sendNotiCheck = true;
				}
			}
    	} else if('Post'.equalsIgnorecase(noti.Sub_Type__c)){
			if ('ContentFeedItem'.equalsIgnorecase(noti.Object_Type__c) ){
				if(peoplePref.Browser_Content_Comments_On_Published__c) {
					sendNotiCheck = true;
				}
			} else {
				if(peoplePref.Browser_Posts_To_Me__c) {
					sendNotiCheck = true;
				}
			} 
						
		} else if('Mention'.equalsIgnorecase(noti.Sub_Type__c)){
			if(peoplePref.Browser_Posts_To_Me__c){
				sendNotiCheck = true;
			}
    	} else if('update'.equalsIgnoreCase(noti.Sub_Type__c)){
			if('Approved'.equalsIgnoreCase(noti.status__c)|| 'Rejected'.equalsIgnoreCase(noti.status__c)) {
				if('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)){
					if(peoplePref.Browser_PrivateSiteMembership_Resp__c) {
						sendNotiCheck = true;
					}
				} else {
					if(peoplePref.Browser_Content_Approval_Rejection__c) {
						sendNotiCheck = true;
					}
					
				}
			}
		} else if('Rate Unuseful'.equalsIgnoreCase(noti.Sub_Type__c)) {
			if(peoplePref.Browser_Content_Feedback__c){
				sendNotiCheck = true;
			}
		} else if('Newsletter'.equalsIgnoreCase(noti.Category__c)) {
			if(peoplePref.Browser_Newsletter__c){
				sendNotiCheck = true;
			}
		} else if('Recognition'.equalsIgnoreCase(noti.Category__c)) {
			if(peoplePref.Browser_Recognition__c){
				sendNotiCheck = true;
			}
		}

		return sendNotiCheck;
	}
	
	private static Boolean checkHybridPushNotification(App_Notification__c noti, People_Preference__c peoplePref){
		
		Boolean sendNotiCheck = false;
		
		if(peoplePref.Mobile_Allow_Notifications__c){
			if('follow'.equalsIgnoreCase(noti.Sub_Type__c)){
				if(peoplePref.Mobile_Follows_Me__c) {
					sendNotiCheck = true;
				}
    			} else if('Event Invite'.equalsIgnoreCase(noti.Sub_Type__c)){
				if(peoplePref.Mobile_Event_Invite_More__c) {
					sendNotiCheck = true;
				}
			} else if('Endorse'.equalsIgnoreCase(noti.Sub_Type__c)){
    				if(peoplePref.Mobile_Endorses_Me__c) {
					sendNotiCheck = true;
				}
	    		} else if('update'.equalsIgnoreCase(noti.Sub_Type__c)){
	    			if('Approved'.equalsIgnoreCase(noti.status__c)|| 'Rejected'.equalsIgnoreCase(noti.status__c)) {
	    				if('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)){
	    					if(peoplePref.Mobile_PrivateSiteMembership_Response__c) {
							sendNotiCheck = true;
						}
	    				} else {
	    					if(peoplePref.Mobile_My_Content_Rejected__c) {
							sendNotiCheck = true;
						}
	    				}
	    			}
	    		} else if('post'.equalsIgnoreCase(noti.Sub_Type__c)){
	    			if(String.isBlank(noti.Simpplr_Site__c)){
	    				if(peoplePref.Mobile_Posts_To_Me__c) {
						sendNotiCheck = true;
					}
	    			} else {
	    				if(peoplePref.Mobile_My_Content_Post__c) {
						sendNotiCheck = true;
					}
	    			}
	    		} else if('like'.equalsIgnoreCase(noti.Sub_Type__c)){
    				if('FeedItem'.equalsIgnoreCase(noti.Object_Type__c) || 'FeedComment'.equalsIgnoreCase(noti.Object_Type__c)) {
    					if(peoplePref.Mobile_Like_My_Post_Or_Comment__c) {
						sendNotiCheck = true;
					}
    				} else {
   					if(peoplePref.Mobile_My_Content_Like_Or_Share__c) {
						sendNotiCheck = true;
					}
   				}
	    		} else if('comment'.equalsIgnoreCase(noti.Sub_Type__c)){
	    			if('Also_Replied_On_Post'.equalsIgnorecase(noti.Category__c) || 'Also_Replied_On_My_Post'.equalsIgnorecase(noti.Category__c) ||
									'Also_Replied_On_Comment'.equalsIgnorecase(noti.Category__c) || 'Also_Replied_On_My_Comment'.equalsIgnorecase(noti.Category__c)) {
	    				if(peoplePref.Mobile_Comments_After_Me__c) {
								sendNotiCheck = true;
							}
	    			} else if('Comments_On_Post_I_Like'.equalsIgnorecase(noti.Category__c)) {
		    			if(peoplePref.Mobile_Comments_On_Post_I_Like__c) {
								sendNotiCheck = true;
							}
	    			} else {
	    				if(peoplePref.Mobile_Comments_On_My_Post__c) {
								sendNotiCheck = true;
							}
	    			}
	    		} else if('mention'.equalsIgnoreCase(noti.Sub_Type__c)){
	    			if(peoplePref.Mobile_Posts_To_Me__c) {
					sendNotiCheck = true;
				}
	    		} else if('share'.equalsIgnoreCase(noti.Sub_Type__c)){
	    			if('FeedItem'.equalsIgnoreCase(noti.Object_Type__c)) {
	    				if(peoplePref.Mobile_Shares_My_Post__c) {
						sendNotiCheck = true;	
					}
	    			} else {
	    				if(peoplePref.Mobile_My_Content_Like_Or_Share__c) {
						sendNotiCheck = true;
					}
	    			}
	    		} else if('review'.equalsIgnoreCase(noti.Sub_Type__c)){
	    			if('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequestAutoApprove'.equalsIgnoreCase(noti.Object_Type__c)) {
	    				if(peoplePref.Mobile_Private_Site_Membership_Requests__c) {
						sendNotiCheck = true;
					}
	    			} else {
	    				if(peoplePref.Mobile_Content_Submitted_For_Moderation__c) {
						sendNotiCheck = true;
					}
    				}
	    		} else if('Newsletter'.equalsIgnoreCase(noti.Category__c) && peoplePref.Mobile_Newsletter__c){
					sendNotiCheck = true;
				}
		}
		return sendNotiCheck;
	}
	
	private static Boolean checkNativePushNotification(App_Notification__c noti, People_Preference__c peoplePref){
		Boolean sendNotiCheck = false;
		if('Event Invite'.equalsIgnoreCase(noti.Sub_Type__c)){
			if(peoplePref.Native_Mobile_Event_Invite_More__c) {
				sendNotiCheck = true;
			}
		} else if('Endorse'.equalsIgnoreCase(noti.Sub_Type__c)){
			if(peoplePref.Native_Mob_Endorse_Expertise__c) {
				sendNotiCheck = true;
			}
		} else if('follow'.equalsIgnoreCase(noti.Sub_Type__c)){
			if(peoplePref.Native_Mobile_Follows_Me__c) {
				sendNotiCheck = true;
			}
    	} else if('like'.equalsIgnoreCase(noti.Sub_Type__c)){
			Set<String> contentTypeSet = new Set<String>{'News','Event', 'Page', 'Album', 'BlogPost'};
			if(contentTypeSet.contains(noti.Object_Type__c)) {
				if(peoplePref.Native_Mobile_My_Content_Like_Or_Share__c) {
                    sendNotiCheck = true;
                }
            } else if(peoplePref.Native_Mob_Like_My_Post_Or_Comment__c){
					sendNotiCheck = true;
			}
    	} else if('share'.equalsIgnoreCase(noti.Sub_Type__c)){
			Set<String> contentTypeSet = new Set<String>{'News','Event', 'Page', 'Album', 'BlogPost'};
			if(contentTypeSet.contains(noti.Object_Type__c)) {
				if(peoplePref.Native_Mobile_My_Content_Like_Or_Share__c) {
                    sendNotiCheck = true;
				}
			} 
			if('FeedItem'.equalsIgnoreCase(noti.Object_Type__c)) {
				if(peoplePref.Native_Mob_Shares_My_Post__c) {
					sendNotiCheck = true;	
				}
			}
    	} else if('review'.equalsIgnoreCase(noti.Sub_Type__c)){
			if('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)) {
				if(peoplePref.Native_Mob_Private_Site_Membership_Req__c) {
					sendNotiCheck = true;
				}
			}else {
				if(peoplePref.Native_Mob_Content_Submit_Moderation__c) {
					sendNotiCheck = true;
				}
			}
    	} else if('Comment'.equalsIgnorecase(noti.Sub_Type__c)){
			if('Also_Replied_On_Post'.equalsIgnorecase(noti.Category__c) || 	
				'Also_Replied_On_My_Post'.equalsIgnorecase(noti.Category__c) ||
				'Also_Replied_On_Comment'.equalsIgnorecase(noti.Category__c) || 
				'Also_Replied_On_My_Comment'.equalsIgnorecase(noti.Category__c)) {
				if(peoplePref.Native_Mob_Reply_After_Me__c) {
					sendNotiCheck = true;
				}
			} else if('Comments_On_Post_I_Like'.equalsIgnorecase(noti.Category__c)) {
				if(peoplePref.Native_Mob_Replied_On_liked_Post__c) {
					sendNotiCheck = true;
				}
			} else {
				if(peoplePref.Native_Mob_Comments_On_My_Post__c) {
					sendNotiCheck = true;
				}
			}
    	} else if('Post'.equalsIgnorecase(noti.Sub_Type__c)){
			if ('ContentFeedItem'.equalsIgnorecase(noti.Object_Type__c) ){
				if(peoplePref.Native_Mob_My_Content_Post__c) {
					sendNotiCheck = true;
				}
			} else {
				if(peoplePref.Native_Mob_Posts_To_Me__c) {
					sendNotiCheck = true;
				}
			} 
						
		} else if('Mention'.equalsIgnorecase(noti.Sub_Type__c)){
			if(peoplePref.Native_Mob_Posts_To_Me__c){
				sendNotiCheck = true;
			}
    	} else if('update'.equalsIgnoreCase(noti.Sub_Type__c)){
			if('Approved'.equalsIgnoreCase(noti.status__c)|| 'Rejected'.equalsIgnoreCase(noti.status__c)) {
				if('CollaborationGroupMemberRequest'.equalsIgnoreCase(noti.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(noti.Object_Type__c)){
					if(peoplePref.Native_MobPrivateSiteMembership_Resp__c) {
						sendNotiCheck = true;
					}
				} else {
					if(peoplePref.Native_Mob_Content_ApproveReject__c) {
						sendNotiCheck = true;
					}
					
				}
			}
		} else if('Newsletter'.equalsIgnoreCase(noti.Category__c)){
			if(peoplePref.Native_Mobile_Newsletter__c) {
				sendNotiCheck = true;
			}
		}else if('survey'.equalsIgnoreCase(noti.Category__c) && peoplePref.Native_Mobile_Surveys__c){
			sendNotiCheck = true;
		} else if('recognition'.equalsIgnoreCase(noti.Category__c) || 'recognition_hub'.equalsIgnoreCase(noti.Category__c)){
			sendNotiCheck = true;
		}
		return sendNotiCheck;
	}
	@testVisible
	private static Boolean sendNativeMobileAppPushNoti(App_Notification__c noti){
		Boolean sendNativeAppPushNoti = true;
		if(prohibitedObjectTypeSet.contains(noti.Object_Type__c) || prohibitedSubTypeSet.contains(noti.Sub_Type__c)){
			sendNativeAppPushNoti = false;
		
		} else if (String.isNotBlank(noti.Category__c) && prohibitedCategorySet.contains(noti.Category__c)) {				
			sendNativeAppPushNoti = false;	

		}
		return sendNativeAppPushNoti;
	}
	
	public static String getNotificationURL(App_Notification__c notificationObjArg) {
		String redirectPageName;
		Set<String> contentNameSet = new Set<String>{'Event','Page','Album','BlogPost'};
		String responseUrl = PageContext.getPageURL(Pages.Notifications) + '?origin=pn';
		if('News'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
    		redirectPageName = Pages.SiteContent;
		} else if('Event'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
			redirectPageName = Pages.SiteContent;
		} else if('Page'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
			redirectPageName = Pages.SiteContent; 
		} else if('Album'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
			redirectPageName = Pages.SiteContent;
		} else if('People'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
			redirectPageName = Pages.ProfileAbout;
		} else if('BlogPost'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
			redirectPageName = Pages.ProfileBlogPost;
		} else if('CollaborationGroupMemberRequest'.equalsIgnoreCase(notificationObjArg.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
			redirectPageName = 'NotificationsSiteMemberRequest';
		} else if('CollaborationGroup'.equalsIgnoreCase(notificationObjArg.Object_Type__c) || 'SiteMember'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
			redirectPageName = ServiceConstants.SITE_LANDING_PAGE_STRING;
		} else if ('Subscription'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
			redirectPageName = 'Actionable'.equalsIgnoreCase(notificationObjArg.Type__c) ? 'managesitesubscription' : 'managesegmentsubscription'; 
		
		} else {
			redirectPageName = Pages.HomeFeedSinglePost;
		} 
		Map<String,String> mapOfURLParameters = new Map<String,String> ();
		if ('Information'.equalsIgnoreCase(notificationObjArg.Type__c)) {
			String peopleId = notificationObjArg.Sent_By__c;
			mapOfURLParameters = getMapOfURLParameters(peopleId,notificationObjArg.Object_Type__c,notificationObjArg.Object_Id__c,notificationObjArg.Simpplr_Site__c,redirectPageName,notificationObjArg.id, notificationObjArg.Parent_Object_Id__c);
			if ('Content_Rated_Unuseful'.equalsIgnoreCase(notificationObjArg.category__C)) {
				mapOfURLParameters.put('openUsefulHistory', 'true');										
			} if('CollaborationGroupMemberRequest'.equalsIgnoreCase(notificationObjArg.Object_Type__c) || 'PublicSiteMemberRequest'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
				if(NotificationDao.ACTION_APPROVE.equals(notificationObjArg.Status__c)) {
					Map<String, String> args = new Map<String, String>();
	                args.put('pageToRedirect', ServiceConstants.SITE_LANDING_PAGE_STRING);
	                args.put('siteId', notificationObjArg.Simpplr_Site__c);
	                args.put('origin', 'pn');
	                responseUrl = PageContext.getPageURL(Pages.PageRedirector, args);
				} else {
					responseUrl = PageContext.getPageURL(Pages.Notifications);
				}
			} else if('CollaborationGroup'.equalsIgnoreCase(notificationObjArg.Object_Type__c) || 'SiteMember'.equalsIgnoreCase(notificationObjArg.Object_Type__c)) {
				Map<String, String> args = new Map<String, String>();
				args.put('redirectPageName', ServiceConstants.SITE_LANDING_PAGE_STRING);
                args.put('notificationId', notificationObjArg.Simpplr_Site__c);
                args.put('siteId', notificationObjArg.Simpplr_Site__c);
                responseUrl = PageContext.getPageURL(Pages.NotificationRedirectionServer, args);
			} else if('FeedComment'.equalsIgnorecase(notificationObjArg.Object_Type__c) || 'ContentFeedComment'.equalsIgnorecase(notificationObjArg.Object_Type__c)) {
					Map<String, String> args = new Map<String, String>();
					args.put('feedId', notificationObjArg.Parent_Object_Id__c);
					args.put('feedCommentId', notificationObjArg.Object_Id__c);
					args.put('pageToRedirect', Pages.HomeFeedSinglePost);
					args.put('origin', 'pn');
					args.put('notificationId', notificationObjArg.id);
					responseUrl = PageContext.getPageURL(Pages.PageRedirector , args);								
			} else if('FeedItem'.equalsIgnorecase(notificationObjArg.Object_Type__c) || 'ContentFeedItem'.equalsIgnorecase(notificationObjArg.Object_Type__c)) {
				Map<String, String> args = new Map<String, String>();
				args.put('pageToRedirect', Pages.HomeFeedSinglePost);
				args.put('feedId', notificationObjArg.Object_Id__c);
				args.put('notificationId', notificationObjArg.Id);
				args.put('origin', 'pn');
				responseUrl = PageContext.getPageURL(Pages.PageRedirector , args);
				
			} else if (contentNameSet.contains(notificationObjArg.object_Type__c) && 'share'.equalsIgnoreCase(notificationObjArg.Sub_Type__c)) { 
					Map<String, String> args = new Map<String, String>();
					args.put('pageToRedirect', Pages.HomeFeedSinglePost);
					args.put('feedId', notificationObjArg.Object_Id__c);
					args.put('contentId', notificationObjArg.content__c);
					args.put('notificationId', notificationObjArg.id);
					args.put('origin', 'pn');
					responseUrl = PageContext.getPageURL(Pages.PageRedirector , args);								
				
			} else {
				responseUrl = PageContext.getPageURL(Pages.NotificationRedirectionServer,mapOfURLParameters);
			}
		} else {
			mapOfURLParameters = getMapOfURLParameters('',notificationObjArg.Object_Type__c,notificationObjArg.Object_Id__c,notificationObjArg.Simpplr_Site__c,redirectPageName,notificationObjArg.id, notificationObjArg.Parent_Object_Id__c);
			responseUrl = PageContext.getPageURL(Pages.NotificationRedirectionServer,mapOfURLParameters);
		}
		//responseUrl = responseUrl.replaceFirst('https', 'Simpplr');
		return responseUrl;
	}
	
	/**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
	private static Map<String,String> getMapOfURLParameters(String peopleId,String objectType,String objectId,Id siteId,String redirectPageName,Id notificationId, String parentObjectId){
		Set<String> contentNameSet = new Set<String>{'News','Event','Page','Album','BlogPost'};
		Map<String,String> mapOfURLParameters =  new Map<String,String>{'redirectPageName' 	=>	redirectPageName, 
							   											'notificationId' 	=>	notificationId,
							   											'origin'			=>	'pn'
																		};
		if (!contentNameSet.contains(objectType)){
			if('CollaborationGroupMemberRequest'.equalsIgnorecase(objectType) || 'PublicSiteMemberRequest'.equalsIgnoreCase(objectType)) {
				mapOfURLParameters.put('requestId', objectId);
				mapOfURLParameters.put('siteId', siteId);
				
			} else if('Site'.equalsIgnorecase(objectType)){
				mapOfURLParameters.put('siteId', siteId);
				
			} else if('CollaborationGroup'.equalsIgnorecase(objectType) || 'SiteMember'.equalsIgnoreCase(objectType)){
				mapOfURLParameters.put('siteId', siteId);
			
			} else if('Subscription'.equalsIgnoreCase(objectType)) {
				mapOfURLParameters.put('subscriptionId', objectId);
				mapOfURLParameters.put('siteId', siteId);
				
			}else if('FeedItem'.equalsIgnorecase(objectType) || 'ContentFeedItem'.equalsIgnorecase(objectType)) {
				mapOfURLParameters.put('feedId', objectId);
			
			}else if('FeedComment'.equalsIgnorecase(objectType) || 'ContentFeedComment'.equalsIgnorecase(objectType)) {
				mapOfURLParameters.put('feedId', parentObjectId);
				mapOfURLParameters.put('feedCommentId', objectId);
				
			} else if(!objectType.equalsIgnorecase('People')){
				mapOfURLParameters.put('feedId', objectId);
				
			} else {
				
				mapOfURLParameters.put('profileId', objectId);
			}
		} else {
			if('BlogPost'.equalsIgnorecase(objectType)) {
				mapOfURLParameters.put('contentId', objectId);
				mapOfURLParameters.put('profileId', peopleId);
			} else {
				mapOfURLParameters.put('contentId', objectId);
				mapOfURLParameters.put('showHistory', 'true');
				mapOfURLParameters.put('siteId', siteId);
				mapOfURLParameters.put('type', objectType.toLowerCase());
			}
		}
		
		return mapOfURLParameters;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public static Map<String,App_Notification__c>  markNotificationForContentAsRejected(String actionComment, Simpplr_Content__c contentObj) {
		String notificationGuid = null;
		Map<String,App_Notification__c> userToNotificationMap;
		List<App_Notification__c> listSN = [select Guid__c from App_Notification__c where Is_Deleted__c = false AND Type__c = 'Actionable' And Object_Id__c =:contentObj.Id WITH SECURITY_ENFORCED order by createddate desc LIMIT 1];
		
		if(listSN != null && listSN.size() > 0){
			notificationGuid = ((App_Notification__c)listSN[0]).guid__c;
		}
		
		if(notificationGuid != null){
			userToNotificationMap = generateActionRejectedNotification(notificationGuid, actionComment, contentObj);
		}
		return userToNotificationMap;
			
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static Map<String,App_Notification__c> generateActionRejectedNotification(String guid, String actionComment, Simpplr_Content__c contentObj) {
		try {
			String notificationId = '';
			List<App_Notification__c> listOfSN = prepareActionNotifications(guid, actionComment, ACTION_REJECTED);
			String parentId = ''; 
			for(App_Notification__c sn : listOfSN){
				if(UserContext.peopleId.equals(sn.Sent_to__c)){
					parentId = sn.id;
				}
			}

			// approver is a new manager...
			if(parentId.equals('')) {
				// create notification for new manager

				List<App_Notification__c> notiList = new List<App_Notification__c>{new App_Notification__c(
					GUID__c = guid, Is_Read__c=false, Type__c='Actionable', Sub_Type__c='Review', Category__c = listOfSN[0].Category__c,
					Object_Type__c=listOfSN[0].Object_Type__c, Object_Id__c=listOfSN[0].Object_Id__c, Snippet__c = listOfSN[0].Snippet__c, Submitter_Comment__c = listOfSN[0].Submitter_Comment__c,
					Created_DateTime__c = listOfSN[0].Created_DateTime__c, Sent_By__c=listOfSN[0].Sent_By__c, Is_Deleted__c = false, Is_New__c=true, Sent_to__c=UserContext.peopleId)};

				createNotifications(notiList);
				
				listOfSN=prepareActionNotifications(guid, actionComment, ACTION_REJECTED);

				for(App_Notification__c sn : listOfSN){
					if(UserContext.peopleId.equals(sn.Sent_to__c)){
						parentId = sn.id;
					}
				}
			}

			List<App_Notification__c> appNotiListToInsert = getNotificationsForNotiSettingsEnabledUser(contentObj, actionComment, ACTION_REJECTED, parentId);

			Map<String,App_Notification__c> userToNotificationMap = createNotifications(appNotiListToInsert);

			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_Read__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_On__c,
				App_Notification__c.Action_Comment__c,
				App_Notification__c.Status__c
			};
				
			updateNotification(listOfSN, listOfColumnsToBeUpdated);

			return userToNotificationMap;
		}
		catch(Exception ex) {
			throw ex;
		}
	}

	private static List<App_Notification__c> getNotificationsForNotiSettingsEnabledUser(Simpplr_Content__c simpplrContentObj, String actionComment, String status, String parentId) {
		List<App_Notification__c> notificationObjList = new List<App_Notification__c>();
		
		Set<String> targetPeopleIdSet = NotificationDao.getPeopleIdsWithContentNotificationsEnabled(simpplrContentObj.Id);
		targetPeopleIdSet.add(simpplrContentObj.Primary_Author__c);

		for(String targetPeopleId : targetPeopleIdSet) {
			App_Notification__c notificationObj = new App_Notification__c();
			notificationObj.Snippet__c = Utility.chompString(simpplrContentObj.Title__c,255);
			notificationObj.Type__c = TYPE_INFORMATION;
			notificationObj.Sub_Type__c = 'Update';
			notificationObj.Status__c = status;
			notificationObj.Simpplr_Site__c = simpplrContentObj.Site__c;
			notificationObj.Object_Id__c = simpplrContentObj.Id;
			notificationObj.Object_Type__c = simpplrContentObj.Type__c;
			notificationObj.Sent_to__c = targetPeopleId;
			notificationObj.Sent_By__c = UserContext.peopleId;
			notificationObj.Is_Read__c = false;
			notificationObj.Action_Comment__c = actionComment;
			notificationObj.Action_By__c = UserContext.peopleId;
			
			if(targetPeopleId.equalsIgnoreCase(simpplrContentObj.Primary_Author__c)) {
				notificationObj.Parent__c = parentId; 
				if(ACTION_REJECTED.equalsIgnoreCase(status)) {
					notificationObj.Category__c = CATEGORY_MY_CONTENT_REJECTED;
				} else {
					notificationObj.Category__c = CATEGORY_MY_CONTENT_APPROVED;
				}
			} else {
				notificationObj.Parent__c = null; 
				if(ACTION_REJECTED.equalsIgnoreCase(status)) {
					notificationObj.Category__c = CATEGORY_MANAGE_CONTENT_REJECTED;
				} else {
					notificationObj.Category__c = CATEGORY_MANAGE_CONTENT_APPROVED;
				}
			}
			notificationObj.Created_DateTime__c = DateTime.now();

			notificationObjList.add(notificationObj);
		}
		
		return notificationObjList;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	
	public static void updateNotification(List<App_Notification__c> listOfSN, List<Schema.SObjectField> listOfColumnsToBeUpdated) {
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(listOfSN), listOfColumnsToBeUpdated);
	}
	
	/**
	* 
	* Purpose:  This method is responsible for creating action notification
	*			and also deactivate same notification to other admin user's as its actioned
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    /** **/
	public static List<App_Notification__c> prepareActionNotifications(String guid,String actionComment, String actionType) {
		checkParamerter(guid,'bypass'); //checked passed parm and throw exception if it's not fullfilled requirement
		try {
			List<App_Notification__c> lifOfSN=[SELECT Action_By__c, Category__c, Action_Comment__c,Action_On__c,
												Sent_to__c, Sent_By__c, Sent_By__r.Full_Name__c, GUID__c, Object_Id__c, Object_Type__c, 
												Parent__c, Parent_Object_Id__c, Content__c, Simpplr_Site__c, Is_Read__c, Snippet__c, 
												Submitter_Comment__c, Created_DateTime__c, Sub_Type__c, Type__c 
												FROM App_Notification__c where GUID__c=:guid AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
			for(App_Notification__c sn:lifOfSN )
			{
				sn.Is_Read__c=true;
				sn.Is_New__c=false;
				sn.Action_By__c=UserContext.peopleId;
				sn.Action_On__c=Datetime.now();
				sn.Action_Comment__c= Utility.manageNullForString(actionComment);
				sn.Status__c=actionType;
			}
			return lifOfSN;
		}
		catch(Exception ex) {
			throw ex;
		}
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    private static void checkParamerter(String objectId,String objectType) {
		
		if(String.isBlank(objectId)) {
			throw new SimpplrException(ExceptionCode.NULL_TYPE_OBJECT_ID.name());
		}
		
		if(String.isBlank(objectType)) {
			throw new SimpplrException(ExceptionCode.NULL_TYPE_OBJECT_TYPE.name());
		}
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static Map<String,App_Notification__c> generateActionApprovedNotification(String guid, Simpplr_Content__c contentObj) {
		try {
			String notificationId = '';
			List<App_Notification__c> listOfSN = prepareActionNotifications(guid, null, ACTION_APPROVE);
			String parentId = ''; 
			
			for(App_Notification__c sn : listOfSN){
				if((UserContext.peopleId).equals(sn.Sent_to__c)){
					parentId = sn.id;
				}
			}
			
			// approver is a new manager...
			if(parentId.equals('')) { 
				// create notification for new manager
				createNotifications(new List<App_Notification__c>{new App_Notification__c(
					GUID__c = guid, Is_Read__c=false, Type__c='Review',  Category__c = listOfSN[0].Category__c,
					Object_Type__c=listOfSN[0].Object_Type__c, Object_Id__c=listOfSN[0].Object_Id__c, Submitter_Comment__c = listOfSN[0].Submitter_Comment__c,Snippet__c = listOfSN[0].Snippet__c, 
					Created_DateTime__c = listOfSN[0].Created_DateTime__c, Sent_By__c=listOfSN[0].Sent_By__c, Is_Deleted__c = false, Is_New__c=true, Sent_to__c=UserContext.peopleId)});
				
				listOfSN=prepareActionNotifications(guid, null, ACTION_APPROVE);
				for(App_Notification__c sn : listOfSN){
					if(UserContext.peopleId.equals(sn.Sent_to__c)){
						parentId = sn.id;
					}
				}
			}
			
			List<App_Notification__c> appNotiListToInsert = getNotificationsForNotiSettingsEnabledUser(contentObj, null, ACTION_APPROVE, parentId);
			
			Map<String,App_Notification__c> userToNotificationMap = createNotifications(appNotiListToInsert);
			
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_Read__c,
				App_Notification__c.Is_New__c,
				App_Notification__c.Action_By__c,
				App_Notification__c.Action_On__c,
				App_Notification__c.Action_Comment__c,
				App_Notification__c.Status__c
			};

			updateNotification(listOfSN, listOfColumnsToBeUpdated);

			return userToNotificationMap;
		}
		catch(Exception ex) {
			throw ex;
		}
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static Map<String,App_Notification__c> generateReviewNotifications(String objectId,String objectType,String contentTitle, String siteId,String summary) {
		try {
			List<App_Notification__c> listOFSN=prepareRequestNotifications(objectId,objectType,contentTitle,TYPE_REVIEW,siteId);
			return createNotifications(listOfSN);
		} catch(Exception ex) {
			throw ex;
		}
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    private static List<App_Notification__c> prepareRequestNotifications(String objectId,String objectType,String contentTitle,String reviewType, String siteId) {
		checkParamerter(objectId,objectType); //checked passed parm and throw exception if it's not fullfilled requirement
		try {
			Set<String> setOfAdminUserIds = getAllContentApprovers(objectId, 'appManagerNotifications', false);
			setOfAdminUserIds.addAll(getPeopleIdsWithContentNotificationsEnabled(objectId));

			List<Notification> listOfNotification=new List<Notification>();
			String guid=generateGUID(); // all user share same guid becuase later on we can process same guid's pending requests 
			
			for(String userId : setOfAdminUserIds) {
				Notification nt =new Notification();
				nt.fromUser=UserContext.peopleId;
				nt.GUID=guid;
				nt.objectID=objectId;
				nt.objectType=objectType;
				nt.isRead=false;
				nt.categoryStr= objectType + '_Submitted_For_Moderation';
				nt.contentId=objectId;
				nt.snippet = contentTitle;
				nt.typeOfRequest=reviewType;
				nt.type=TYPE_ACTIONABLE;
				nt.action='Pending';
				nt.status='Pending';
				nt.subType='Review';
				nt.toUser=userId;
				nt.siteId=siteId;
				listOfNotification.add(nt);
			}
			return convertToAppNotiObjList(listOfNotification);
		}
		catch(Exception ex) {
			throw ex;
		}
	}
	
	/**
	* 
	* Purpose:  [Check for the notifications to be sent to different users as per settings]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	
	public List<String> getAlbumNotificationTargetUsers (String contentId) {
		List<String> listOfChatterGroupId=new List<String>();
		List<User> listOfAllManagerAndAdminAndModerator=new List<User> ();

		List<Simpplr_Content__c> listOfSimpplrContent=new List<Simpplr_Content__c>();
		Boolean foundPrivateSite = false;
		listOfSimpplrContent = [Select Site__r.Chatter_Group_Id__c,
								 Site__r.Site_Type__c
								 from Simpplr_Content__c  
								 Where Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true 
							 	 And id=:contentId WITH SECURITY_ENFORCED];
		for(Simpplr_Content__c sc:listOfSimpplrContent) {
			listOfChatterGroupId.add(sc.Site__r.Chatter_Group_Id__c);
			if(ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(sc.Site__r.Site_Type__c)) {
				foundPrivateSite = true;
			}
		}		
		listOfAllManagerAndAdminAndModerator.addAll(getManagersOfSelectedSimpplrGroup(listOfChatterGroupId));
		if(!foundPrivateSite) {
			listOfAllManagerAndAdminAndModerator.addAll(Utility.getAllAppModeratorsWithContentModedrnOn('appManagerUpdateNotification'));
		}		
		return getUniquePeopleIds(listOfAllManagerAndAdminAndModerator);
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static Set<String> getAllContentApprovers(String contentId, String appManagerNotiType, Boolean includeAuthor) {
		Set<String> setOfContentApprovers = new Set<String>();
		
		List<String> listOfChatterGroupId=new List<String>();
		List<User> listOfAllManagerAndAdminAndModerator=new List<User> ();

		Boolean foundPrivateSite = false;
		List<Simpplr_Content__c> listOfSimpplrContent=new List<Simpplr_Content__c>();
		listOfSimpplrContent = [Select Site__c, Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c, Primary_Author__c
								 From Simpplr_Content__c  
								 Where Site__r.Is_Active__c = true And Site__r.Show_In_Simpplr__c = true 
							 	 And id=:contentId WITH SECURITY_ENFORCED];
		
		Simpplr_Content__c sc;
		if( !listOfSimpplrContent.isEmpty() ) {
			sc = listOfSimpplrContent[0];
		}

		if(sc != null) {
			listOfChatterGroupId.add(sc.Site__r.Chatter_Group_Id__c);
			if(ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(sc.Site__r.Site_Type__c)) {
				foundPrivateSite = true;
			}
			
			if(includeAuthor) {
				setOfContentApprovers.add(sc.Primary_Author__c);
			}
		}		
		
		listOfAllManagerAndAdminAndModerator.addAll(getManagersOfSelectedSimpplrGroup(listOfChatterGroupId));
		
		
		if(!foundPrivateSite) {
			listOfAllManagerAndAdminAndModerator.addAll(Utility.getAllAppModeratorsWithContentModedrnOn(appManagerNotiType));
		}
		
		setOfContentApprovers.addAll(getUniquePeopleIds(listOfAllManagerAndAdminAndModerator));

		if(sc != null) {
			SiteDao siteDaoObj = new SiteDao();
			setOfContentApprovers.addAll(siteDaoObj.getSiteContentManagerIdsSet(sc.Site__c));
		}
		
		return setOfContentApprovers;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static Map<String,App_Notification__c> markNotificationForContentAsApproved(Simpplr_Content__c contentObj) {
		
		Map<String,App_Notification__c> userToNotificationMap;
		String notificationGuid = null;
		List<App_Notification__c> listSN = [select guid__c from App_Notification__c where Type__c = 'Actionable' And Object_Id__c =:contentObj.Id AND Is_Deleted__c = false WITH SECURITY_ENFORCED order by createddate desc LIMIT 1];
		if(listSN != null && listSN.size() > 0){
			notificationGuid = ((App_Notification__c)listSN[0]).guid__c;
		}	
		
		if(notificationGuid != null){
			userToNotificationMap = generateActionApprovedNotification(notificationGuid, contentObj);
		}	
		return userToNotificationMap;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public static List<String> getUniquePeopleIds(List<User> listOfUsers) {
		Set<String> uniqueUserIds = new Set<String>();
		for(User u:listOfUsers) {
			uniqueUserIds.add(u.id);
		}
		List<String> idList = new List<String>();
		idList.addAll(uniqueUserIds);
		return Utility.getPeopleIdList(idList);
	}

	public static Set<String> getPeopleIdsWithContentNotificationsEnabled(String contentId) {
		Set<String> peopleIds = new Set<String>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String cnsQuery = 'SELECT Id, People__c FROM Content_Notification_Setting__c WHERE Simpplr_Content__c = :soqlParam1 AND Notification_Enabled__c = true';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_Notification_Setting__c> notiSettingList = (List<Content_Notification_Setting__c>)SIMPESAPI.accessController().queryAsUser(cnsQuery, soqlParamMap);

		for(Content_Notification_Setting__c notiSettingObj : notiSettingList) {
			peopleIds.add(notiSettingObj.People__c);
		}

		return peopleIds;
	}

	public static Set<String> getUserIdsWithContentNotificationsEnabled(String contentId) {
		Set<String> userIds = new Set<String>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String cnsQuery = 'SELECT Id, People__c, People__r.User__c FROM Content_Notification_Setting__c WHERE Simpplr_Content__c = :soqlParam1 AND Notification_Enabled__c = true';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_Notification_Setting__c> notiSettingList = (List<Content_Notification_Setting__c>)SIMPESAPI.accessController().queryAsUser(cnsQuery, soqlParamMap);

		for(Content_Notification_Setting__c notiSettingObj : notiSettingList) {
			userIds.add(notiSettingObj.People__r.User__c);
		}

		return userIds;
	}
	
	/**
	* 
	* Purpose:  return all chatter Group manager,owner(Both treated as admin in chatter terminology, 
	*			for more info see chatter docs) which group(location,site) checked in content
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    /**  **/
	private static List<User> getManagersOfSelectedSimpplrGroup(List<String> listOfIds)
	{
		List<CollaborationGroupMember> listOfGroupAdmin=new List<CollaborationGroupMember>();
		String query = 'Select MemberId From CollaborationGroupMember c where CollaborationRole=\'Admin\' and Member.IsActive=true and CollaborationGroupId =:listOfIds';	
		if(SimpplrContext.isCommunitiesEnabled){
			query = query+' and CollaborationGroup.NetworkId = null';
		}
		query += ' Limit 10000';
		listOfGroupAdmin = Database.query(query);
		List<String> listOfUserId=new List<String>();
		for(CollaborationGroupMember cgm: listOfGroupAdmin) {
		 	listOfUserId.add(cgm.MemberId);
		}
		return [select id,name,isActive from user where name!=null and isActive=true and id=:listOfUserId WITH SECURITY_ENFORCED];
	}
	
	public static Integer getPendingActionableNotificationForContent(String contentId) {
		List<App_Notification__c> notyList = [select id FROM App_Notification__c where Object_Id__c =: contentId AND Type__c =: TYPE_ACTIONABLE 
											 AND Is_Deleted__c = false AND Status__c NOT IN (:ACTION_APPROVE, :ACTION_IGNORE, :ACTION_REJECTED) WITH SECURITY_ENFORCED];
		
		return notyList.size();
	}
	
	@future (callout = true)
	public static void sendPushNotifications(String listOfSN) {
		try{
			List<App_Notification__c> listOfSPN = (List<App_Notification__c>)JSON.deserialize(listOfSN, List<App_Notification__c>.class);
			if( !listOfSPN.isEmpty() ) {
				Map<String, List<PushNotifcationWrapper>> pushNotiJsonMap = getPushNotiBasedOnUserPref(listOfSPN);
                String pushNotiListMobile = null;
                String pushNotiListBrowser = null;

                if(SimpplrContext.SimpplrMobileNotificationAllowed && pushNotiJsonMap.containsKey('pushNotiListMobile')) {
                    pushNotiListMobile = JSON.serialize(pushNotiJsonMap.get('pushNotiListMobile'));
                }

                if(pushNotiJsonMap.containsKey('pushNotiListBrowser')) {
                    pushNotiListBrowser = JSON.serialize(pushNotiJsonMap.get('pushNotiListBrowser'));
                }

				if(String.isNotBlank(pushNotiListMobile) || String.isNotBlank(pushNotiListBrowser)){
					Utility.sendPushNotifications(pushNotiListMobile, pushNotiListBrowser);
				}
			}
		} catch (Exception ex){
    		Utility.sendExceptionEmail('NotificationDao', ex);
    		throw ex;
		}
	}
	
	public void markInActiveSitesNotificationAsDeleted() {
		List<App_Notification__c> appNotificationList= [Select id FROM App_Notification__c where Is_Deleted__c=false
														And Sent_to__c=:UserContext.peopleId And Simpplr_Site__c !=null 
														And (Simpplr_Site__r.is_active__c = false Or Simpplr_Site__r.Show_In_Simpplr__c = false) WITH SECURITY_ENFORCED];
		if(!appNotificationList.isEmpty()) {															
			for(App_Notification__c noti:appNotificationList) {
				noti.is_Deleted__c = true;
			}
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{App_Notification__c.is_Deleted__c};
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(appNotificationList), listOfColumnsToBeUpdated);
		}
	}

	public static String getNotificationtext(App_Notification__c notiObj, String languageLocaleKeyArg, 
					String contentType, String contentTitle, String mediaType, String siteName, Map<String, String> sentByMap) {

		String categoryArg = notiObj.Category__c;
		String snippet = notiObj.Snippet__c;
		String siteId = notiObj.Simpplr_Site__c;
		String stamp = notiObj.Status__c;
		String remaningCount;
		
		String sentByName = UserContext.peopleName;
		if(sentByMap.containsKey(notiObj.Sent_By__c)) { // If notification user is some other user that that on Context - ie. slack comments
			sentByName = sentByMap.get(notiObj.Sent_By__c);
		}

		if (notiObj.Action_Count__c != null && 
                notiObj.Action_Count__c > 4) {
            remaningCount = String.valueOf(notiObj.Action_Count__c - 3); 
        }

		String notificationText = '';
		if ('Also_Replied_On_Post'.equalsIgnoreCase(categoryArg)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_FEED_REPLIED_AFTER);
				notificationText = notificationText.replace('{{fullName}}', sentByName);

		} else if ('Also_Replied_On_My_Post'.equalsIgnoreCase(categoryArg)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_FEED_REPLIED_AFTER_OWN);
				notificationText = notificationText.replace('{{fullName}}', sentByName);

		} else if ('Also_Replied_On_Comment'.equalsIgnoreCase(categoryArg)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_COMMENT_REPLIED_AFTER);
				notificationText = notificationText.replace('{{contentTitle}}', contentTitle);

		} else if ('Also_Replied_On_My_Comment'.equalsIgnoreCase(categoryArg)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_COMMENT_REPLIED_AFTER_OWN);
				notificationText = notificationText.replace('{{contentTitle}}', contentTitle);

		} else if ('Comments_On_Post_On_My_Profile'.equalsIgnoreCase(categoryArg)) {
			if(String.isBlank(snippet)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_SHARED_WITH_YOU_NO_TEXT_REPLY);
			} else {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_SHARED_WITH_YOU_REPLY);
			}
		} else if ('Comments_On_My_Post'.equalsIgnoreCase(categoryArg)) {
			if(String.isBlank(snippet)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_NO_TEXT_REPLY);
			} else {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_REPLY);
			}
			notificationText = notificationText.replace('{{fullName}}', sentByName);
		} else if ('Comments_On_My_Recognition'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION_REPLY);
		} else if ('Comments_On_My_Poll'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_FEED_POLL_REPLY);
		} else if ('Comments_On_My_Post_With_File'.equalsIgnoreCase(categoryArg)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_REPLY_WITH_FILE);
		} else if ('Comments_On_My_Content_Post'.equalsIgnoreCase(categoryArg)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_COMMENT_REPLY);
		} else if ('Comments_On_Post_I_Like'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_YOU_LIKED_REPLY);

		} else if ('Album_Submitted_For_Moderation'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_ALBUM_PENDING_APPROVAL);

		} else if ('Page_Submitted_For_Moderation'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_SUBMITTED_PAGE_FOR_APPROVAL);

		} else if ('Event_Submitted_For_Moderation'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_EVENT_PENDING_APPROVAL);

		} else if ('Endorses_Me'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_PROFILE_EXPERTISE_ENDORSE)
									.replace('{{expertise}}', snippet);
			
		} else if ('Follows_Me'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_IS_FOLLOWING_YOU);
			
		} else if ('Like_My_Post'.equalsIgnoreCase(categoryArg)) {
			if(String.isBlank(snippet)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_NO_TEXT_LIKE);
			} else {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_LIKE);
			}
			
		} else if ('Like_My_Recognition'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION_LIKE);
			
		} else if ('Like_My_Poll'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_FEED_POLL_LIKE);
			
		} else if ('Like_My_Comment_On_Content'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_LIKED_YOUR_COMMENT);
			
		} else if ('Like_My_Reply'.equalsIgnoreCase(categoryArg)) {
			if(String.isBlank(snippet)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_REPLY_NO_TEXT_LIKE);
			} else {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_REPLY_LIKE);
			}
		}else if ('Like_My_Reply_On_Content'.equalsIgnoreCase(categoryArg)) {
			if(String.isBlank(snippet)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_LIKED_YOUR_REPLY_ON_CONTENT_NO_TEXT);
			} else {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_LIKED_YOUR_REPLY_ON_CONTENT);
			}
		} else if ('Mentions_Me_In_Post'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POST_MENTIONED_YOU);
			
		} else if ('Mentions_Me_In_Recognition'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION_MENTIONED_YOU);
			
		} else if ('Mentions_Me_In_Reply'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_REPLY_MENTIONED_YOU);
			
		} else if ('My_Content_Approved'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_APPROVED); 
			
		} else if ('Content_Approved'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_MANAGE_APPROVED); 
			
		} else if ('My_Content_Rejected'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_REJECTED);
			
		} else if ('Content_Rejected'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_MANAGE_REJECTED);
			
		} else if ('My_Content_Like'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_LIKED_CONTENT);
			
		} else if ('Content_Like'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_LIKED_MANAGE_CONTENT);
			
		} else if ('Album_Photo_Like'.equalsIgnoreCase(categoryArg)) {
			mediaType = LocaleContext.getLabel(languageLocaleKeyArg, KEY_MEDIA_TYPE_PHOTO);
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_MEDIA_LIKED);
		
		} else if ('Album_Video_Like'.equalsIgnoreCase(categoryArg)) {
			mediaType = LocaleContext.getLabel(languageLocaleKeyArg, KEY_MEDIA_TYPE_VIDEO);
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_MEDIA_LIKED);

		} else if ('Album_Your_Photo_Like'.equalsIgnoreCase(categoryArg)) {
			mediaType = LocaleContext.getLabel(languageLocaleKeyArg, KEY_MEDIA_TYPE_PHOTO);
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_MEDIA_CONTRIBUTED_LIKED);
		
		} else if ('Album_Your_Video_Like'.equalsIgnoreCase(categoryArg)) {
			mediaType = LocaleContext.getLabel(languageLocaleKeyArg, KEY_MEDIA_TYPE_VIDEO);
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_MEDIA_CONTRIBUTED_LIKED);

		} else if ('Album_Photo_Share'.equalsIgnoreCase(categoryArg)) {
			mediaType = LocaleContext.getLabel(languageLocaleKeyArg, KEY_MEDIA_TYPE_PHOTO);
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_MEDIA_SHARED);
		
		} else if ('Album_Video_Share'.equalsIgnoreCase(categoryArg)) {
			mediaType = LocaleContext.getLabel(languageLocaleKeyArg, KEY_MEDIA_TYPE_VIDEO);
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_MEDIA_SHARED);

		} else if ('Album_Your_Photo_Share'.equalsIgnoreCase(categoryArg)) {
			mediaType = LocaleContext.getLabel(languageLocaleKeyArg, KEY_MEDIA_TYPE_PHOTO);
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_MEDIA_CONTRIBUTED_SHARED);
		
		} else if ('Album_Your_Video_Share'.equalsIgnoreCase(categoryArg)) {
			mediaType = LocaleContext.getLabel(languageLocaleKeyArg, KEY_MEDIA_TYPE_VIDEO);
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_MEDIA_CONTRIBUTED_SHARED);

		} else if ('My_Content_Post'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_COMMENTED_ON_YOUR_CONTENT);

		} else if ('Content_Post'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_COMMENTED_ON_MANAGE_CONTENT);
			notificationText = notificationText.replace('{{contentTitle}}', contentTitle);

		} else if ('My_Content_File_Post'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_FILE_POST);

		} else if ('My_Content_Share'.equalsIgnoreCase(categoryArg)) {
			if('page'.equalsIgnoreCase(contentType)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_PAGE_SHARE);
			} else if('album'.equalsIgnoreCase(contentType)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_ALBUM_SHARE);
			} else if('event'.equalsIgnoreCase(contentType)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_EVENT_SHARE);
			} else if('blogpost'.equalsIgnoreCase(contentType)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_BLOG_POST_SHARE);
			}
			
		} else if ('Content_Share'.equalsIgnoreCase(categoryArg)) {
			if('page'.equalsIgnoreCase(contentType)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_MANAGE_PAGE_SHARE);
			} else if('album'.equalsIgnoreCase(contentType)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_MANAGE_ALBUM_SHARE);
			} else if('event'.equalsIgnoreCase(contentType)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_MANAGE_EVENT_SHARE);
			} else if('blogpost'.equalsIgnoreCase(contentType)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_MANAGE_BLOG_POST_SHARE);
			}
			
		} else if ('Posts_On_My_Profile_With_File'.equalsIgnoreCase(categoryArg)) {
			if(String.isBlank(snippet)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POSTED_TO_YOU_FILE);
			} else {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POSTED_TO_YOU_FILE_WITH_TEXT);
			}

		} else if ('Posts_A_Poll_On_My_Profile'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_POSTED_TO_YOU_POLL);
			
		} else if ('Posts_On_My_Profile'.equalsIgnoreCase(categoryArg)) {
			if(String.isBlank(snippet)) {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_FEED_NO_TEXT_POSTED_TO_YOU);
			} else {
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_FEED_POSTED_TO_YOU);
			}

		} else if ('PrivateSiteMembership_Response'.equalsIgnoreCase(categoryArg) || 'Public_Site_Membership_Response'.equalsIgnoreCase(categoryArg)) {
			if(!'Rejected'.equalsIgnoreCase(stamp)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_PRIVATE_SITE_APPROVAL);
			}
			
		} else if ('Private_Site_Membership_Requests'.equalsIgnoreCase(categoryArg) || 'Public_Site_Membership_Requests'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_REQUESTED_TO_JOIN_SITE);
			
		} else if('Member_Added'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_SITE_MADE_YOU_MEMBER);

		} else if ('Shares_My_Post'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_FEED_POST_SHARE);

		} else if ('Shares_My_Recognition'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_FEED_RECOGNITION_SHARE);

		} else if('Invited_To_Event'.equalsIgnoreCase(categoryArg)){
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_INVITED_YOU_TO_EVENT)
									.replace('{{eventTitle}}', snippet);
		} else if('Subscription_Request'.equalsIgnoreCase(categoryArg)) {
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_SUBSCRIPTION_REQUIRES_ATTENTION);
		} else if('Content_Rated_Unuseful'.equalsIgnoreCase(categoryArg)){
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_CONTENT_NOT_USEFUL)
									.replace('{{eventTitle}}', snippet);
		} else if('Newsletter'.equalsIgnoreCase(categoryArg)){
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_NEWSLETTER);
		} else if('Recognition'.equalsIgnoreCase(categoryArg)){
			notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION);
		} else if('recognition_hub'.equalsIgnoreCase(notiObj.Category__c)){
			if('new_award_10_days_before'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_NEW_AWARD_10_DAYS_BEFORE);
			} else if('existing_award_7_days_before'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_EXISTING_AWARD_7_DAYS_BEFORE);
			} else if('new_award_3_days_before'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_NEW_AWARD_3_DAYS_BEFORE);
			} else if('delegate_open'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_DELEGATE_OPEN);
			} else if('low_participation'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_LOW_PARTICIPATION);
			} else if('delegate_close'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_DELEGATE_CLOSE);
			} else if('overdue_next_open'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_OVERDUE_NEXT_OPEN);
			} else if('overdue_next_close'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_OVERDUE_NEXT_CLOSE);
			} else if('overdue_warning'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_OVERDUE_WARNING);
			} else if('overdue_awarded'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_OVERDUE_AWARDED);
			} else if('award_skipped'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_AWARD_SKIPPED);
			} else if('award_missed'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_AWARD_MISSED);
			} else if('user_open'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_USER_OPEN);
			} else if('user_open_n_awards'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_USER_OPEN_N_AWARDS);
			} else if('award_granted'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_AWARD_GRANTED);
			} else if('award_winner'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_AWARD_WINNER);
			} else if('direct_new_award'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_DIRECT_NEW_AWARD);
			} else if('direct_existing_award'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_DIRECT_EXISTING_AWARD);
			} else if('award_due'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_AWARD_DUE);
			} else if('recognition_recipient'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION);
			} else if('recognition_mention'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_COMMENT_MENTION_RECOGNITION);
			}  else if('award_cheer'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_AWARD_CHEER);
			} else if('recognition_cheer'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_RECOGNITION_CHEER);
			} else if('award_comment'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_AWARD_COMMENT);
			} else if('recognition_comment'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_RECOGNITION_COMMENT);
			} else if('recognition_comment_like'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_RECOGNITION_COMMENT_LIKE);
			} else if('notify_manager_award'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_RECOGNITION_MANAGER_NOTIFY_AWARD);
			} else if('notify_manager_recognition'.equalsIgnoreCase(notiObj.sub_Type__c)){
				notificationText = LocaleContext.getLabel(languageLocaleKeyArg, KEY_RECOGNITION + KEY_RECOGNITION_MANAGER_NOTIFY_RECOGNITION);
			}

		}

		// Replace keys, if exists
		snippet = snippet == null ? '' : snippet;
		notificationText = notificationText.replace('{{snippet}}', snippet);
		notificationText = notificationText.replace('{{fullName}}', UserContext.peopleName);
		notificationText = notificationText.replace('{{postSnippet}}', snippet);
		notificationText = notificationText.replace('{{contentTitle}}', snippet);
		notificationText = notificationText.replace('{{commentSnippet}}', snippet);
		notificationText = notificationText.replace('{{replySnippet}}', snippet);    
		if(String.isNotBlank(contentType))   {
				contentType = LocaleContext.getLocalisedContentTypeLabel(languageLocaleKeyArg, contentType);	 
				notificationText = notificationText.replace('{{contentType, lowercase}}', contentType.toLowerCase());
				notificationText = notificationText.replace('{{contentType}}', contentType);
		}
		notificationText = notificationText.replace('{{siteName}}', siteName);

		notificationText = notificationText.replace('{{mediaType}}', mediaType);
		notificationText = notificationText.replace('{{mediaType, lowercase}}', mediaType.toLowerCase());
		notificationText = notificationText.replace('{{albumTitle}}', snippet);
		notificationText = notificationText.replace('{{commentAuthorUsername}}', snippet);
		notificationText = notificationText.replace('{{postTitle}}', snippet);

		return notificationText;
	}

	public List<Content_Message__c> getContentNotificationMessage(String contentMessageId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentMessageId);
		String queryStr = 'select CreatedDate, Message__c, Sent_By_People__c from Content_Message__c where id=:soqlParam1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Content_Message__c> contentMessageList = (List<Content_Message__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		return contentMessageList;
	}
	
	public class Notification {
	
		public String id{get;set;}
		public String actionByUser{get;set;}
		public String actionComment{get;set;}
		public DateTime actionOn{get;set;}
		public String GUID{get;set;}
		public Boolean isNew{get;set;}
		public Boolean isRead{get;set;}
		public String objectID{get;set;}
		public String objectType{get;set;}
		public String partentID{get;set;}
		public String parentObjectID{get;set;}
		public String contentId{get;set;}
		public String fromUser{get;set;}
		public String toUser{get;set;}
		public String siteId{get;set;}
		public String status{get;set;}
		public String submitterComment{get;set;}
		public String snippet{get;set;}
		public String subType{get;set;}
		public String type{get;set;}
		public String fromUserSmallPhotoUrl{get;set;}	
		public String fromUserPhotoColor{get;set;}
		public String title{get;set;}
		public Boolean isDeleted{get;set;}
		public String categoryStr{get;set;}
	
		public String topicName{get;set;}// to be removed
		public String contentType{get;set;}// to be removed
		public String notificationType{get;set;}//to be removed
		public String action{get;set;}// to be removed
		public String typeOfRequest{get;set;}// to be removed
		public String duration{get;set;}// to be removed
		public boolean isUserFollowFeed {get;set;}// to be removed
		public boolean isTopicEndorsedFeed{get;set;}// to be removed
		public boolean isContentFeed{get;set;}// to be removed
	}

	/**
     * @description based on notificationId select appropriate record
     * @param notificationId 
     * @return App_Notification__c 
     */
	public App_Notification__c getNotificationById(String notificationId){
		List<App_Notification__c> notifications = [select id,Category__c from App_Notification__c where Is_Deleted__c = false AND id =:notificationId WITH SECURITY_ENFORCED];
		if(notifications.isEmpty()){
			return null;
		}else{
			return notifications[0];
		}
	}

	/**
     * @description - to get the content thumbnail image
     * @return contentToImgURL - Map<String, String>
     * @param contentIds - String
     */
    public static Map<String, String> getContentImage(Set<String> contentIds){
		Map<String, String> contentToImgURL = new Map<String, String>();
        List<File__c> filesList = [SELECT Id,Content_Version__c, Simpplr_Content__c FROM File__c WHERE Simpplr_Content__c = :contentIds AND Location__c = 'cover' AND Title_Image_Type__c = :ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL AND Is_Deleted__c = false AND Is_Title_Image__c = true WITH SECURITY_ENFORCED ORDER BY Is_Title_Image__c DESC, Likes__c DESC NULLS last, Order__c desc LIMIT 4];
        if(filesList.size() > 0){
			for(File__c file:filesList){
				contentToImgURL.put(file.Simpplr_Content__c, Utility.getFileDownloadURL(file.Content_Version__c));
			}
        }
        return contentToImgURL;
    }

	/**
	 * @description this method checks if there are any stuck notifications and mark them actioned
	 * @param contentId String type contentId
	 */
	public void checkAndRemoveStuckNotifications(String contentId){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String queryString = 'Select id, Is_Deleted__c from App_Notification__c ' +
								'where Content__c =:soqlParam1 AND Content__r.Content_Sub_Type__c = \'knowledge\' ' +
								'And Is_Deleted__c = false ' +
								'And Category__c=\'Content_For_Review\' ' +
								'And Type__c = \'Actionable\' ' +
								'And Action_By__c = null ';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Notification__c> appNotificationsList = (List<App_Notification__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

		if(!appNotificationsList.isEmpty()) {
			for(App_Notification__c appNotification : appNotificationsList) {
				appNotification.Is_Deleted__c = true;
			}
			List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
				App_Notification__c.Is_Deleted__c
			};

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(appNotificationsList), listOfColumnsToBeUpdated);
		}
	}
}