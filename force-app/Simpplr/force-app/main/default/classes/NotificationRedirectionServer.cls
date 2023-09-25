public with sharing class NotificationRedirectionServer {
	

    private final String NOTIFICATION_TYPE = 'Information';
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public PageReference init(){
    	PageReference pgRef; 
    	try{
			Map<String, String> mapOfRequestParameters = ApexPages.currentPage().getParameters();
			String notificationId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParameters.get('notificationId'));
			String redirectPageName = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParameters.get('redirectPageName'));
			String siteId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParameters.get('siteId'));
            String origin = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParameters.get('origin'));
			String csvDownloadRequestId = SIMPESAPI.encoder().SFDC_JSENCODE(mapOfRequestParameters.get('Id'));
            markNotificationStatusAsRead(notificationId);
            String pageUrl = '';
            if(redirectPageName.equalsIgnoreCase(ServiceConstants.SITE_LANDING_PAGE_STRING)) {
				pageUrl = BaseCtrl.salesForceBaseUrl + Page.PageRedirector.getUrl() + '?siteId=' + siteId + '&pageToRedirect='+ ServiceConstants.SITE_LANDING_PAGE_STRING + '&origin=ne';
            } else if(redirectPageName.containsIgnoreCase('newsletterv2')) {
				pageUrl = PageContext.getPageURL(Pages.app) + '?u=/premier-newsletter';
	            	String newsletterId = mapOfRequestParameters.get('newsletterId');
				if(String.isNotBlank(newsletterId)) {
					pageUrl += '/view/'+newsletterId;
				}
            } else if(redirectPageName.containsIgnoreCase('newsletter')) {
				pageUrl = PageContext.getPageURL(Pages.app) + '?u=/newsletter/';
	            	String newsletterId = mapOfRequestParameters.get('newsletterId');
				if(String.isNotBlank(newsletterId)) {
					pageUrl += newsletterId +'/review';
				}
            } else if('survey'.equalsIgnoreCase(redirectPageName)){
				pageUrl = PageContext.getPageURL(Pages.app) + '?u=/surveys/';
	            String objectId = mapOfRequestParameters.get('objectId');
				String subType = mapOfRequestParameters.containsKey('subType') ? mapOfRequestParameters.get('subType') : null;
				if(String.isNotBlank(objectId)){
					if(string.isNotBlank(subType) && ('action_instance'.equalsIgnoreCase(subType) || 'action_survey'.equalsIgnoreCase(subType))){
						pageUrl += 'reporting/'+objectId;
					} else {
						pageUrl += 'participation/'+objectId;
					}
					pageUrl += '&source=notification';
				}

			} else if('recognition_hub'.equalsIgnoreCase(redirectPageName)){
				pageUrl = PageContext.getPageURL(Pages.app) + '?u=/recognition-hub';
	            String objectId = mapOfRequestParameters.get('objectId');
				String objectType = mapOfRequestParameters.get('objectType');
				if('recognition'.equalsIgnoreCase(objectType) && String.isNotBlank(objectId)){
						pageUrl += '/recognition/'+objectId;
				}

			}  else if('managesitesubscription'.equalsIgnoreCase(redirectPageName)) {
				pageUrl = PageContext.getPageURL(Pages.app);
				if(String.isNotBlank(siteId)) {
					pageUrl += '?u=/manage/sites/' + siteId + '/subscriptions';
				}
				String subscriptionId = mapOfRequestParameters.get('subscriptionId');

				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', subscriptionId);

				String queryString = 'SELECT Status__c FROM Subscription_Entity__c WHERE Subscription__c = :soqlParam1';
						
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Subscription_Entity__c> subscriptionEntityList = (List<Subscription_Entity__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);
			
				if(subscriptionEntityList.isEmpty() || (!subscriptionEntityList.isEmpty() && !'Pending'.equalsIgnoreCase(subscriptionEntityList[0].Status__c))) {
					markNotificationAsActioned(notificationId);
				}

			} else if('ManageApplicationEmailNotificationsDefault'.equalsIgnoreCase(redirectPageName)) {
				pageUrl = PageContext.getPageURL(Pages.app);
				pageUrl += '?u=/manage/app/defaults/email-notifications';
			
			} else if('ManageApplicationFeedDefault'.equalsIgnoreCase(redirectPageName)) {
				pageUrl = PageContext.getPageURL(Pages.app);
				pageUrl += '?u=/manage/app/defaults/home-feed';

			} else if('ManageApplicationSMSDefault'.equalsIgnoreCase(redirectPageName)) {
				pageUrl = PageContext.getPageURL(Pages.app);
				pageUrl += '?u=/manage/app/defaults/sms-notifications';

			} else if('ManageApplicationNativeMobileAppDefault'.equalsIgnoreCase(redirectPageName)) {
				pageUrl = PageContext.getPageURL(Pages.app);
				pageUrl += '?u=/manage/app/defaults/mobile-app';

            } else if('ManageApplicationBrowserDefault'.equalsIgnoreCase(redirectPageName)) {
				pageUrl = PageContext.getPageURL(Pages.app);
				pageUrl += '?u=/manage/app/defaults/browser-notifications';

			} else if('ManageApplicationFileIntegration'.equalsIgnoreCase(redirectPageName)) {
                pageUrl = PageContext.getPageURL(Pages.app);
				pageUrl += '?u=/manage/app/integrations/files';

            } else if('managesegmentsubscription'.equalsIgnoreCase(redirectPageName)) {
				pageUrl = PageContext.getPageURL(Pages.app);
				pageUrl += '?u=/subscriptions';
				String subscriptionId = mapOfRequestParameters.get('subscriptionId');
				
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', subscriptionId);
				
				String queryString = 'SELECT Audience__r.Segment__c from Subscription__c where id=:soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Subscription__c> subscriptionList = (List<Subscription__c>)SIMPESAPI.accessController().queryAsUser(queryString, soqlParamMap);

				if(SimpplrContext.isSegmentsEnabled && 
							!subscriptionList.isEmpty() && 
							String.isNotBlank(subscriptionList[0].Audience__r.Segment__c)) {
					pageUrl += '/' + subscriptionList[0].Audience__r.Segment__c;
				
				} else {
					pageUrl += '/org';
				
				}
            } else if('manageContent'.equalsIgnoreCase(redirectPageName)) {				
				pageUrl = PageContext.getPageURL(Pages.App)+'?u=/manage/content';
				String status = mapOfRequestParameters.get('status');
				String filter = mapOfRequestParameters.get('filter');
				if(String.isNotBlank(status)) {					
					pageUrl += '&status=' + status;
				}
				if(String.isNotBlank(filter)) {					
					pageUrl += '&filter=' + filter;
				}  
			} else if(redirectPageName.containsIgnoreCase('onboarding')) {				
				pageUrl = PageContext.getPageURL(Pages.App)+'?u=/onboarding';
				String sortBy = mapOfRequestParameters.get('sortBy');
				String referralSource = mapOfRequestParameters.get('referralSource');
				if(String.isNotBlank(sortBy)) {					
					pageUrl += '&sortBy=' + sortBy;
				}  
				if(String.isNotBlank(referralSource)) {					
					pageUrl += '&referralSource=' + referralSource;
				}  

			} else if(redirectPageName.containsIgnoreCase('campaigns')) {
	            	String campaignId = mapOfRequestParameters.get('campaignId');
	            	Boolean campaignExist = checkIfCampaignExists(campaignId);
	            	if(campaignExist){
	            		pageUrl = PageContext.getPageURL(Pages.app)+'?u=/campaigns/latest&campaignId='+campaignId;
	            	}else{
	            		pageUrl = PageContext.getPageURL(Pages.app)+'?u=/campaigns';
	            	}
            } else if(redirectPageName.containsIgnoreCase('ManageCsvDownload') && String.isNotBlank(csvDownloadRequestId)) {
				String downloadUrl = '';
				Boolean isDownloadLinkActive = false;
				Boolean isSameUser = false;
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', csvDownloadRequestId);
				String query = 'SELECT Id, CreatedDate, CreatedById, LastModifiedDate, Content__c, Csv_Url__c, People__c, ' +
								'Request_DateTime__c, Download_Count_In_App_Link__c, Download_Count_Email_Link__c ' +
								' FROM Csv_Download_Request__c WHERE Id =: soqlParam1';

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<Csv_Download_Request__c> csvDownloadRequestList = (List<Csv_Download_Request__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
				if(!csvDownloadRequestList.isEmpty()) {
					Csv_Download_Request__c csvDownloadRequestRecord = csvDownloadRequestList[0];
					downloadUrl = String.isNotBlank(csvDownloadRequestRecord.Csv_Url__c) ? (String) csvDownloadRequestRecord.Csv_Url__c: null;
					Datetime requestDateTime = csvDownloadRequestRecord.CreatedDate != null ? (Datetime) csvDownloadRequestRecord.CreatedDate: null;
					String peopleIdVal = String.isNotBlank(csvDownloadRequestRecord.People__c) ? (String) csvDownloadRequestRecord.People__c: null;
					
					Datetime currentDateTime = datetime.NOW();
					decimal millisecs = decimal.valueOf(currentDateTime.getTime() - requestDateTime.getTime());
					decimal diffInMinutes = millisecs/1000/60;
					isDownloadLinkActive = diffInMinutes < 4315.0 ? true : false;
					isSameUser = UserContext.PeopleId != null && peopleIdVal.equalsIgnoreCase(UserContext.peopleId) ? true : false;
				}
				if(String.isNotBlank(downloadUrl) && isDownloadLinkActive && isSameUser){
					Csv_Download_Request__c csvDownloadRequestRecord = csvDownloadRequestList[0];
					csvDownloadRequestRecord.Download_Count_In_App_Link__c = Integer.valueOf(csvDownloadRequestRecord.Download_Count_In_App_Link__c) + 1 ;
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
					SIMPESAPI.accessController().updateAsUser(csvDownloadRequestRecord, new List<Schema.SObjectField>{
						Csv_Download_Request__c.Download_Count_In_App_Link__c});
					pageUrl = downloadUrl;
				}else{
					pageUrl = PageContext.getPageURL(Pages.app);
					pageUrl += '?u=/error/404';
				}
				List<App_Notification__c> csvNotificationList = [select id from App_Notification__c where sent_to__c=:UserContext.peopleId and Object_Type__c='CsvDownloadRequest' and is_read__c=false AND Is_Deleted__c = false AND Csv_Download_Request__c=:csvDownloadRequestId WITH SECURITY_ENFORCED];
					if(csvNotificationList.isEmpty() == false) {
						for(App_Notification__c notiObj : csvNotificationList){
							notiObj.Action_By__c = UserContext.peopleId;
							notiObj.Action_On__c = DateTime.now();
							notiObj.Is_Read__c = true;
							notiObj.Is_New__c = false;
						}
						
						List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
							App_Notification__c.Action_By__c,
							App_Notification__c.Action_On__c,
							App_Notification__c.Is_Read__c,
							App_Notification__c.Is_New__c
						};
		
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(csvNotificationList), listOfColumnsToBeUpdated);
					}	
				
			} else if(redirectPageName.containsIgnoreCase('QuestionDetail')) {
				String questionId = mapOfRequestParameters.get('questionId');
				String contentId = mapOfRequestParameters.get('contentId');
				String contentType = mapOfRequestParameters.get('type');
				questionId = String.isNotBlank(questionId) ? questionId : '';
				pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+siteId+'/questions/'+questionId;

				if(String.isBlank(questionId) && String.isNotBlank(contentId) && String.isNotBlank(contentType)) {
					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+siteId+'/'+contentType+'/'+contentId;
				}

			} else if(redirectPageName.containsIgnoreCase('AnswerDetail')) {
				String answerId = mapOfRequestParameters.get('answerId');
				pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+siteId+'/answers/'+answerId;

			} else if (redirectPageName.containsIgnoreCase('CnIInitiative')) {
				String initiativeId = mapOfRequestParameters.get('initiativeId');
				pageUrl = PageContext.getPageURL(Pages.app)+'?u=/manage/initiatives/'+initiativeId;

			} else if(redirectPageName.containsIgnoreCase('CnICampaign')) {
				String campaignId = mapOfRequestParameters.get('campaignId');
				pageUrl = PageContext.getPageURL(Pages.app)+'?u=/manage/campaigns/'+campaignId;

			} else if(redirectPageName.containsIgnoreCase('SiteContent')){
				String contentType = mapOfRequestParameters.get('type');
				String contentID = mapOfRequestParameters.get('contentId');
				String parentObjectID = mapOfRequestParameters.get('parentObjectID');
				String fileId = mapOfRequestParameters.get('fileId');
				String mustRead = mapOfRequestParameters.get('mustRead');
				String openModerationHistory = mapOfRequestParameters.get('openModerationHistory');
				String showContentNotification = mapOfRequestParameters.get('showContentNotification');
				Set<String> contentNameSet = new Set<String>{'event','page','album'};

				NotificationDao notificationDaoObj = new NotificationDao();
				App_Notification__c notificationObj = notificationDaoObj.getNotificationById(notificationId);

				if(String.isNotBlank(parentObjectID)){
					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+siteId+'/'+contentType+'/'+parentObjectID+'/gallery/'+fileId;

				}
				else if(notificationObj==null){
					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+siteId+'/'+contentType+'/'+contentID;
                    pageUrl += '&utm_medium=internal&utm_source=in_app_notification';
				} 
				else if(contentType !=null && contentNameSet.contains(contentType)){
					pageUrl = PageContext.getPageURL(Pages.app)+'?u=/site/'+siteId+'/'+contentType+'/'+contentID;
					pageUrl += '&utm_medium=internal&utm_source=in_app_notification';

					if('My_Content_Like'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=content_like';					

					}else if('My_Content_Share'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=content_share';

					}else if('Content_Rated_Unuseful'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=content_flagged_not_useful';

					}else if('Must_Read'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=content_marked_must_read';
						if(isContentRead(UserContext.peopleId, contentID)) {
							markNotificationAsActioned(notificationId);
						}

					}else if('My_Content_Approved'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=content_approved';

					}else if('Made_Content_Author'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=made_content_author';
						
					}else if('Published_On_Behalf'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=published_on_behalf';
						
					}else if('Content_Submitted_For_Moderation'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=content_moderation';

					}else if('Content_Notification'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=content_promotion_from_site';

					}else if('Invited_To_Event'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=invited_to_event';

					}else if('RSVP_Removed'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=event_removed_from_rsvp';

					}else if('Event_Deleted'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=event_delete';

					}else if('Event_Unpublished'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=event_unpublished';

					}else if('Event_Updated'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=event_updated';

					}else if('Event_Responses'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=event_responses';

					} else if('Content_For_Review'.equalsIgnoreCase(notificationObj.Category__c)){
						pageUrl += '&utm_content=Content_For_Review';

					}

					if(String.isNotBlank(mustRead)) {
						DateTime currentDateTime = DateTime.now();
						List<Must_Read_Audit__c> mrAuditList = [SELECT id from Must_Read_Audit__c 
																										WHERE content__c=:contentId 
																										AND Removed_DateTime__c = null  
																										AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime)
																										WITH SECURITY_ENFORCED
																										ORDER BY CreatedDate desc Limit 1];
						if(String.isNotBlank(notificationId) && mrAuditList.isEmpty()) {
							markNotificationAsActioned(notificationId);
						}
						pageUrl += '&mustRead=1';
					} else if(String.isNotBlank(openModerationHistory)) {
						pageUrl += '&openModerationHistory=1';
					
					} else if(String.isNotBlank(showContentNotification)) {
						pageUrl += '&showContentNotification=' + showContentNotification;
					}
				}
            }else if(redirectPageName.containsIgnoreCase('ProfileBlogPost')){
            	String mustRead = mapOfRequestParameters.get('mustRead');
				String profileId = mapOfRequestParameters.get('profileId');
				String contentID = mapOfRequestParameters.get('contentId');
				pageUrl = PageContext.getPageURL(Pages.app)+'?u=/people/'+profileId+'/blog/'+contentID;
				if(String.isNotBlank(mustRead)) {
					DateTime currentDateTime = DateTime.now();
					List<Simpplr_Content__c> contentList = [SELECT id, Primary_Author__c,  
																									(SELECT id FROM Must_Read_Audits__r 
																															WHERE Removed_DateTime__c = null  
																															AND (Expiry_DateTime__c = null OR Expiry_DateTime__c >: currentDateTime))
																									FROM Simpplr_Content__c where id=: contentId WITH SECURITY_ENFORCED];
						if(!contentList.isEmpty()) {
							if(String.isNotBlank(notificationId) && contentList[0].Must_Read_Audits__r.isEmpty()) {
								markNotificationAsActioned(notificationId);
							}
							pageUrl = PageContext.getPageURL(Pages.app)+'?u=/people/' +contentList[0].Primary_Author__c+ '/blog/'+contentID + '&mustRead=1';
						}
				}
            } else if (redirectPageName.equalsIgnoreCase('HomeFeedSinglePost')) {
            	String feedId = mapOfRequestParameters.get('feedId');
            	String feedCommenId = mapOfRequestParameters.get('feedCommentId');
            	siteId = mapOfRequestParameters.get('siteId');
				pageUrl = PageContext.getPageURL(Pages.App)+'?u=/feed/'+feedId+'&notificationId='+notificationId+
						'&origin='+origin;
				
				if(String.isNotBlank(feedCommenId)) {
					pageUrl += '&feedCommentId=' + feedCommenId;
				}
				if(String.isNotBlank(siteId) && (UserContext.hasModifyAllDataPermission == false) && (UserContext.sitesIFollowIdSet.contains(siteId) == false)) {
					List<UserRecordAccess> userRecordAccessList = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :userContext.id AND RecordId = :feedId WITH SECURITY_ENFORCED];
					if(!userRecordAccessList.isEmpty() && (userRecordAccessList[0].HasReadAccess == false)){
						//Look for Private Site
						List<Simpplr_Site__c> siteList = [SELECT Site_Type__c FROM Simpplr_Site__c WHERE id = :siteId WITH SECURITY_ENFORCED];
						if(!siteList.isEmpty() && 'Private'.equalsIgnoreCase(siteList[0].Site_Type__c)) {
							pageUrl = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId;
						} 
					}
					
				}
            } else if (redirectPageName.containsIgnoreCase('homeDefault')) {
            	pageUrl = PageContext.getPageURL(Pages.App)+'?u=/manage/home-default&notificationId='+notificationId+
						'&origin='+origin;
            } else if (redirectPageName.containsIgnoreCase(Pages.ProfileAbout)) {
            	String profileId = mapOfRequestParameters.get('profileId');
            	pageUrl = PageContext.getPageURL(Pages.App)+'?u=/people/'+profileId+'&notificationId='+notificationId+
						'&origin='+origin;
    	    } else if (redirectPageName.containsIgnoreCase('AppManagerAnalytics')) {
            	pageUrl = PageContext.getPageURL(Pages.app) + '?u=/analytics'+'&utm_medium=internal&utm_source=in_app_notification&utm_content=last_month_app_analytics';
    	    } else if (redirectPageName.containsIgnoreCase('SiteAnalytics')) {
            	pageUrl = PageContext.getPageURL(Pages.app) + '?u=/manage/sites/' + siteId + '/analytics'+'&utm_medium=internal&utm_source=in_app_notification&utm_content=last_month_site_analytics';
    	    } else if (redirectPageName.containsIgnoreCase('ContentAnalytics')) {
            	pageUrl = PageContext.getPageURL(Pages.app) + '?u=/analytics'+'&utm_medium=internal&utm_source=in_app_notification&utm_content=last_month_content_analytics';
			} else if (redirectPageName.containsIgnoreCase('NotificationsSiteMemberRequestAutoApproved')) {
				pageUrl = PageContext.getPageURL(Pages.app) +'?u=/manage/sites/' + siteId+'/people/members';
    	    } else if (redirectPageName.containsIgnoreCase('NotificationsSiteMemberRequest') || redirectPageName.containsIgnoreCase('NotificationsPrivateSiteRequest')) {
				if(!isSiteMemberRequestPending(notificationId))
				{
					markNotificationAsActioned(notificationId);
				}
				String requestId = mapOfRequestParameters.get('requestId');
				pageUrl = PageContext.getPageURL(Pages.app) +'?u=/manage/sites/' + siteId+'/people/requests';
			} else if(redirectPageName.containsIgnoreCase('manageVideo')) {
				markNotificationAsActioned(notificationId);
				pageUrl = PageContext.getPageURL(Pages.app)+'?u=/manage/videos';
			
			} else {
				pageUrl = PageContext.getPageURL(redirectPageName,mapOfRequestParameters);	
            }
            
            String openUsefulHistory = mapOfRequestParameters.get('openUsefulHistory');
            if(String.isNotBlank(openUsefulHistory)) {
            		pageUrl += '&openUsefulHistory=1';
            }
            pgRef = new PageReference(pageUrl);
			if(redirectPageName.containsIgnoreCase('ManageCsvDownload')){
				pgRef.setRedirect(true);
				pgRef.setRedirectCode(301);
			}else{
				pgRef.setRedirect(true);
			}
            
        } catch(Exception ex){
			logger.logError('NotificationRedirectionServer.init()-----could not retrieve data----',ex);
        }
        
        return pgRef;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    private void markNotificationAsActioned(String notificationId) {
    	List<App_Notification__c> notificationList = [SELECT Id, Is_Read__c, Is_New__c,Action_On__c,Action_By__c  FROM App_Notification__c 
    															WHERE Id = :notificationId AND Action_By__c = null
    															AND Is_Deleted__c = false WITH SECURITY_ENFORCED LIMIT 1];
    	if(!notificationList.isEmpty()){
    		notificationList[0].Is_Read__c = true;
    		notificationList[0].Is_New__c = false;
    		notificationList[0].Action_On__c = DateTime.now();
    		notificationList[0].Action_By__c = UserContext.peopleId;
    		
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notificationList),new List<Schema.SObjectField>{
																																App_Notification__c.Is_Read__c,
																																App_Notification__c.Is_New__c,
																																App_Notification__c.Action_On__c,
																																App_Notification__c.Action_By__c
																																	});
    		
    	}
    }
	
    private void markNotificationStatusAsRead(String notificationId) {
		if(!String.isBlank(notificationId)) {
			List<App_Notification__c> notificationList = [select id, Is_Read__c from App_Notification__c 
																	where id=:notificationId and Is_Read__c=false 
																	and Is_Deleted__c=false and type__c=:NOTIFICATION_TYPE WITH SECURITY_ENFORCED limit 1];
			if(!notificationList.isEmpty()){
				notificationList[0].Is_Read__c = true;
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Notification__c>(notificationList),new List<Schema.SObjectField>{
																																	App_Notification__c.Is_Read__c
																																		});
				
			}
		}
    }

    private Boolean isContentRead(String peopleId, String contentId) {
		Boolean isRead = false;
		DateTime currentDateTime = DateTime.now();

		List<Must_Read_Audit__c> mustReadAudList = [SELECT Id, Expiry_DateTime__c, Removed_DateTime__c FROM Must_Read_Audit__c 
													WHERE Content__c = :contentId 
													AND (Expiry_DateTime__c = null OR Expiry_DateTime__c > :currentDateTime)
													AND Removed_DateTime__c = null
													WITH SECURITY_ENFORCED
													ORDER BY CreatedDate DESC LIMIT 1];

		if( mustReadAudList.isEmpty() ){
			isRead = true;
		} else {
			String mRAId = mustReadAudList[0].id;
			
			List<Must_Read_Confirm_History__c> listOfRecords= [Select Id, Content__c, People__c From Must_Read_Confirm_History__c 
						WHERE Must_Read_Audit__c = :mRAId AND People__c = :peopleId WITH SECURITY_ENFORCED];

			if( !listOfRecords.isEmpty() ){
				isRead = true;
			}
		}
		
		return isRead;
	}
	private Boolean isSiteMemberRequestPending(String notificationId) {
		List<App_Notification__c> notificationList = [SELECT Id, GUID__c, Simpplr_Site__c, Simpplr_Site__r.Chatter_Group_Id__c, Simpplr_Site__r.Site_Type__c, Sent_By__c, Sent_By__r.User__c FROM App_Notification__c WHERE Id =: notificationId AND Action_On__c = NULL AND Is_Deleted__c = FALSE WITH SECURITY_ENFORCED LIMIT 1];
		if(!notificationList.isEmpty()) {
			App_Notification__c notificationRec = notificationList[0];
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			Boolean useRequesterCheck = String.isNotBlank(notificationRec.GUID__c);
			if(notificationRec.Simpplr_Site__c != null && 'Private'.equalsIgnoreCase(notificationRec.Simpplr_Site__r.Site_Type__c)) {
				soqlParamMap.put('soqlParam1', notificationRec.Simpplr_Site__r.Chatter_Group_Id__c);
				soqlParamMap.put('soqlParam2', notificationRec.Sent_By__r.User__c);
				String query = 'SELECT count() FROM CollaborationGroupMemberRequest ' +
					' WHERE CollaborationGroupId = :soqlParam1 ' + (useRequesterCheck ? ' AND RequesterId = :soqlParam2 ' : '') +
					' AND Status = \'Pending\'';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				Integer cgmrCount = SIMPESAPI.accessController().countQueryAsUser(query, soqlParamMap);
				if(cgmrCount > 0) {
					return true;
				}
			} else if(notificationRec.Simpplr_Site__c != null && 'Public'.equalsIgnoreCase(notificationRec.Simpplr_Site__r.Site_Type__c)) {
				soqlParamMap.put('soqlParam1', notificationRec.Simpplr_Site__c);
				soqlParamMap.put('soqlParam2', notificationRec.Sent_By__c);
				String query = 'SELECT count() FROM Site_Membership_Request__c WHERE Status__c = \'Pending\' ' +
					' AND Site__c =: soqlParam1 ' + (useRequesterCheck ? ' AND Request_By__c = :soqlParam2 ' : '');
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				Integer membershipRequestCount = SIMPESAPI.accessController().countQueryAsUser(query, soqlParamMap);
				if(membershipRequestCount > 0) {
					return true;
				}
			}
		}
		return false;
	}
	private Boolean checkIfCampaignExists(String campaignId) {
		if(String.isBlank(campaignId)) {
			return false;
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', campaignId);
		String queryStr = 'SELECT Id, Is_Deleted__c, Is_Active__c FROM Social_Campaign__c WHERE Id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Social_Campaign__c> campaignList = (List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(campaignList.isEmpty() || campaignList[0].Is_Deleted__c || campaignList[0].Is_Active__c == false) {
			if(!campaignList.isEmpty()) {
				BatchCampaignNotifications job = new BatchCampaignNotifications(campaignList[0].id, 'DeleteCampaignNotifcations');
				Database.executeBatch(job, 2000);
			}
			return false;
		}
		return true;
	}
}