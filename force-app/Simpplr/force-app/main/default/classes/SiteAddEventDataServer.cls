/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/ 
public with sharing class SiteAddEventDataServer extends ContentDataServer{
	private EventDao eventDaoObj;
	private Boolean hasContentApprovalAccess;
	private final String ACTION_VALUE_PUBLISH = 'publish';
	private final String ACTION_VALUE_DRAFT = 'saveDraft';
	private final String ACTION_VALUE_UPDATE_DRAFT = 'updateDraft';
	private final String ACTION_VALUE_UPDATE = 'update';
	private final String ACTION_VALUE_APPROVE = 'approve';
	private final String ACTION_VALUE_GET = 'get'; 
    private final String ACTION_VALUE_INVITED_USERS = 'invitedUsers';
    private final String ACTION_VALUE_ATTENDING_USERS = 'getAttending';
    private final String ACTION_VALUE_INVITE = 'invite';
    private final String ACTION_VALUE_START_CONTENT_EDIT = 'startContentEdit';
    private final String ACTION_VALUE_SEND_EVENT_UPDATE_MAIL = 'sendEventUpdateMail';
	//private final String ACTION_VALUE_PREVIEW = 'preview';
    private final String REQUEST_PARAM_DATA = 'data';
    private final String CONTENT_LASTMODIFIEDDATETIMESTAMP = 'lastModifiedDateTimeStamp';
	private DateTime currentDateTime = DateTime.now();
	private String loggedInPeopleId = UserContext.peopleId;
    
    public SiteAddEventDataServer() {
		eventDaoObj = new EventDao();
    }
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {
    	Savepoint sp;

    	try {
			logger.logDebug('SiteAddEventDataServer.handleRequest()----Start----');
			String action = readParam(REQUEST_PARAM_ACTION);
            String requestData = readParam(REQUEST_PARAM_DATA);
    		
            if (String.isBlank(requestData) && !ACTION_VALUE_GET.equalsIgnoreCase(action)) {
	            throw New SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	        }
	        
	        if (ACTION_VALUE_GET.equalsIgnoreCase(action)) {
                if(String.isNotBlank(readParam('versionHistoryId'))){
					response = getEventByVersionHistoryId(readParam('contentId'), readParam('versionHistoryId'));

				} else {
					response = getContent(readParam('contentId'));

				}

			} else if (ACTION_VALUE_INVITED_USERS.equalsIgnoreCase(action)) {
                response = invitedUsers(readParam(REQUEST_PARAM_DATA));
            
            } else if (ACTION_VALUE_ATTENDING_USERS.equalsIgnoreCase(action)) {
                response = getAttending(readParam(REQUEST_PARAM_DATA));
            
            } else if (ACTION_VALUE_INVITE.equalsIgnoreCase(action)) {
                sp = Database.setSavepoint();
                response = invite(readParam(REQUEST_PARAM_DATA));	        
	        
	        } else if(ACTION_VALUE_START_CONTENT_EDIT.equalsIgnoreCase(action)){
                sp = Database.setSavepoint();
				response = startContentEdit(requestData);

			} else if(ACTION_VALUE_SEND_EVENT_UPDATE_MAIL.equalsIgnoreCase(action)){
                sp = Database.setSavepoint();
				response = sendEventUpdateMail(requestData);

			} else {
                Utility.isContentEditFromContentDetailPage = true;
                hasContentApprovalAccess = AccessManager.hasContentApprovalAccess();
                
                if (ACTION_VALUE_PUBLISH.equalsIgnoreCase(action)) {
	                response = hasContentApprovalAccess ? publish(requestData) : submitForApproval(requestData);
	            
	            } else if (ACTION_VALUE_APPROVE.equalsIgnoreCase(action) && hasContentApprovalAccess) {
					response = publish(requestData);
					    
	            } else if (ACTION_VALUE_DRAFT.equalsIgnoreCase(action)) {
	            	response = draft(requestData);
	            	
	           	} else if (ACTION_VALUE_UPDATE_DRAFT.equalsIgnoreCase(action)) {
	            	response = updateDraft(requestData);
	            
	            } else if (ACTION_VALUE_UPDATE.equalsIgnoreCase(action)) {
	            	response = hasContentApprovalAccess ? updateEvent(requestData) : submitForApproval(requestData);
	            
	            } else {
	                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
	            }

	        }
            
        } catch (Exception ex) {
        	logger.logError('SiteAddEventDataServer.handleRequest()---Exception occured----', ex);
        	if(sp!=null){
				Database.rollback(sp);
			}
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }

    }

    @TestVisible
	private ResponseWrapper sendEventUpdateMail(String requestData){
		logger.logDebug('SiteAddEventDataServer.sendEventUpdateMail()---data---' + requestData);
		ResponseWrapper resultWrapper = New ResponseWrapper();

		Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
		String contentId = (String) requestDataMap.get('contentId');

		if(!checkContentModerationAccess(contentId)){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
        
        // fire batch to email notifications
		BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate('sendEmailToAuthorOnEventAction', contentId, 'eventUpdated', false, true);
        Database.executeBatch(job, 25);
		
		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

		return resultWrapper;
    }

    @TestVisible
	private ResponseWrapper startContentEdit(String requestData){
		logger.logDebug('SiteAddEventDataServer.startContentEdit()---data---' + requestData);
		ResponseWrapper resultWrapper = New ResponseWrapper();

		Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
		String contentId = (String) requestDataMap.get('contentId');
		Integer versionNumber = (Integer) requestDataMap.get('versionNumber');

		if(!checkContentModerationAccess(contentId)){
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}

		ContentLockWrapper contentLockWrapperObj = new ContentLockWrapper();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentId);
		String lockStatusQuery = 'SELECT Id, Content__r.Version__c, Last_Renew_DateTime__c, ' +
			' Start_DateTime__c, Locked_By_People__c FROM Content_Lock_Status__c ' +
			' WHERE Content__c =:soqlParam1 ' +
			' ORDER BY LastModifiedDate DESC LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Content_Lock_Status__c> contentLockStatusList = (List<Content_Lock_Status__c>)SIMPESAPI.accessController().queryAsUser(lockStatusQuery, soqlParamMap);

		if(!contentLockStatusList.isEmpty()){
			// Check if lock is still alive
			if(contentLockStatusList[0].Last_Renew_DateTime__c >= currentDateTime.addSeconds(-90)){
				// Content was locked 

				contentLockWrapperObj.isLocked = true;
				contentLockWrapperObj.lockedBy = getPeopleListWrapper(contentLockStatusList[0].Locked_By_People__c);
				
				// Content was locked so no need to create content wrapper.
				contentLockWrapperObj.content = null;

			} else {
				// Content is not locked

				contentLockWrapperObj.isLocked = false;															
			}
		} else {
			// If list is empty then there wasn't any lock
			
			contentLockWrapperObj.isLocked = false;
		}
		
		if(contentLockWrapperObj.isLocked == false){
			// Create lock on this content for current user
			Content_Lock_Status__c contentLockStatusObj = new Content_Lock_Status__c();
			contentLockStatusObj.Content__c = contentId;
			contentLockStatusObj.Last_Renew_DateTime__c = currentDateTime;
			contentLockStatusObj.Start_DateTime__c = currentDateTime;
			contentLockStatusObj.Locked_By_People__c = UserContext.peopleId;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        SIMPESAPI.accessController().insertAsUser(contentLockStatusObj, new List<Schema.SObjectField>{
																			Content_Lock_Status__c.Content__c,
																			Content_Lock_Status__c.Last_Renew_DateTime__c,
																			Content_Lock_Status__c.Start_DateTime__c,
																			Content_Lock_Status__c.Locked_By_People__c});

			contentLockWrapperObj.lockedBy = getPeopleListWrapper(UserContext.peopleId);

			// Check if the version is same then do not send content wrapper
			contentLockWrapperObj.content = null;

			List<Simpplr_Content__c> contentList = getEventById(contentId);
			if(!contentList.isEmpty() && versionNumber != contentList[0].Version__c){
                contentLockWrapperObj.content = convertToContentWrapper(contentList[0]);
                // This is to handle existing content records created before this change.
				ManageContentDao contentDoa = new ManageContentDao();
				contentDoa.checkAndCreateContentHistory(contentList[0], ServiceConstants.TYPE_EVENT);
			}
			
		}
		
		resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, contentLockWrapperObj);

		return resultWrapper;
    }    
    
    private ResponseWrapper updateEvent(String data) {
        ContentWrapper localContWrapObj = ContentWrapper.parse(data);
        String contentId = localContWrapObj.id == null ? readParam('contentId') : localContWrapObj.id;
        Boolean isContentPublishedBeforeUpdate = isContentPublished(contentId);
        ResponseWrapper resultObj = processContentData(data,ACTION_VALUE_UPDATE, null);

        if (resultObj.status == RESPONSE_STATUS_SUCCESS)  {
			ContentWrapper contWrapObj = new ContentWrapper();
			contWrapObj = ((ContentWrapper)(resultObj.result));

            if (!isContentPublishedBeforeUpdate  && 
                    contWrapObj.isPublished && !isTimeLineCreatedForContent(contWrapObj.id)) { 
                String grpMentionStr = ''; 

				if ('Public'.equalsIgnoreCase(contWrapObj.site.access) || 
                        ('Private'.equalsIgnoreCase(contWrapObj.site.access) && 
					    UserContext.chatterGroupsIFollowIdSet.contains(contWrapObj.site.chatterGroupId))) {
					 
                    grpMentionStr = '@[' + contWrapObj.site.chatterGroupId + ']';
                } 
                if (!test.isRunningTest()) {
                    RecursionCheck.stopRecursion();
                    if(SiteContext.isBroadcastSite && SiteContext.isCurrentUserSiteContentManager) {
                        SiteDao siteDaoObj = new siteDao();
                        siteDaoObj.ToggleMemberManager(contWrapObj.site.chatterGroupId ,UserContext.id,'Admin');
                        FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, 
                            contWrapObj.title, grpMentionStr);

                        siteDaoObj.ToggleMemberManager(contWrapObj.site.chatterGroupId ,UserContext.id,'Standard');
                    }
                    else {
                        FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, 
                            contWrapObj.title, grpMentionStr);
                    }
                }
            }

            // fire batch to send in-app notifications only for update event
            BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate('sendEmailToAuthorOnEventAction', contWrapObj.id, 'eventUpdated', true, false);
            Database.executeBatch(job, 25);
            
        }

        return resultObj;
    }

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible
    private ResponseWrapper publish(String data) {
    	ResponseWrapper resultObj = processContentData(data,ServiceConstants.CONTENT_STATUS_APPROVED, null);

        if (resultObj.status == RESPONSE_STATUS_SUCCESS)  {
			ContentWrapper contWrapObj = new ContentWrapper();
			contWrapObj = ((ContentWrapper)(resultObj.result));

            if (contWrapObj.isPublished ) {
                publishTimeLine(contWrapObj);
            }
        }

		return resultObj;
    }

    private void publishTimeLine(ContentWrapper contWrapObj) {
        String grpMentionStr = ''; 

        if('Public'.equalsIgnoreCase(contWrapObj.site.access) || 
            ('Private'.equalsIgnoreCase(contWrapObj.site.access) && 
             UserContext.chatterGroupsIFollowIdSet.contains(contWrapObj.site.chatterGroupId))) {
            grpMentionStr = '@[' + contWrapObj.site.chatterGroupId + ']';
        }
        
        RecursionCheck.stopRecursion();
        if(SiteContext.isBroadcastSite && SiteContext.isCurrentUserSiteContentManager) {
            SiteDao siteDaoObj = new siteDao();
            siteDaoObj.ToggleMemberManager(contWrapObj.site.chatterGroupId ,UserContext.id,'Admin');
            FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, contWrapObj.title, grpMentionStr);
            siteDaoObj.ToggleMemberManager(contWrapObj.site.chatterGroupId ,UserContext.id,'Standard');
        }else if(SiteContext.isBroadcastSite && UserContext.isUserAppModerator){
			FeedServiceProvider.createTimeLineFeedForBroadcastSiteByAppModerators(contWrapObj.site.chatterGroupId, contWrapObj.id, contWrapObj.url, contWrapObj.title, grpMentionStr);
		}else {
            FeedServiceProvider.createTimeLine(null, contWrapObj.id, contWrapObj.url, contWrapObj.title, grpMentionStr);
        }

        if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 && SiteContext.MicrosoftTeamsIntegrationEnabled){
            new MicrosoftTeamsHelper().getContentInfo(contWrapObj.id, 'event');
        }

        if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && SiteContext.SlackIntegrationEnabled){
            new SlackHelper().getContentInfo(contWrapObj.id, null, '');
        }


    }
   
    private ResponseWrapper draft(String data) {
    	ResponseWrapper result = processContentData(data,ServiceConstants.CONTENT_STATUS_DRAFT, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT);
        return result;
    }
    
    private ResponseWrapper updateDraft(String data) {
    	ResponseWrapper result = processContentData(data,ServiceConstants.CONTENT_STATUS_DRAFT, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT);
        return result;
    }

    private ResponseWrapper submitForApproval(String data) {
        ResponseWrapper result = processContentData(data,ServiceConstants.CONTENT_STATUS_SUBMIITED, null);
        return result;
    }
    
    private ResponseWrapper invitedUsers(String data) {
        ResponseWrapper resultWrapper = new ResponseWrapper();
        Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
        String contentId = String.valueOf(requestData.get('contentId'));

        if (String.isBlank(contentId)) {
            throw new SimpplrException(ServiceConstants.ERROR_INVALID_REQUEST_PARAMETERS);
        }

        Integer nextPageToken = 0;
        
        if (requestData.get('nextPageToken') != null) {
            nextPageToken = Integer.valueOf(requestData.get('nextPageToken'));
        }
        String sortBy;
        if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
            sortBy = 'CreatedDate';
        } else {
            sortBy = 'InviteeName';
        }
        List<Event_Invitee__c> invitedUsersList = eventDaoObj.getEventInvitedUsersList(contentId,nextPageToken, sortBy);
        List<PeopleLiteWrapper> peopleWrapperList = convertInviteeToWrapper(invitedUsersList);
        Map<Object,Object> result = New Map<Object,Object>();
        nextPageToken = peopleWrapperList.size() < SimpplrContext.simpplrDefaultPageSize ? null : nextPageToken+SimpplrContext.simpplrDefaultPageSize;
        result.put('nextPageToken',nextPageToken);
        result.put('listOfItems',peopleWrapperList);
        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 
                'Invited users list fetched!', result);
        return resultWrapper;
    }
    
    private ResponseWrapper getAttending(String data) {
        ResponseWrapper resultWrapper = New ResponseWrapper();
        Map<String,Object> requestData = (Map<String,Object>)JSON.deserializeUntyped(data);
        String contentId = String.valueOf(requestData.get('contentId'));

        if (String.isBlank(contentId)) {
            throw New SimpplrException(ServiceConstants.ERROR_INVALID_REQUEST_PARAMETERS);
        }

        Integer nextPageToken = 0;
        
        if (requestData.get('nextPageToken') != null) {
            nextPageToken = Integer.valueOf(requestData.get('nextPageToken'));
        }
        String sortBy;
        if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
            sortBy = 'CreatedDate';
        } else {
            sortBy = 'PeopleName';
        }
        List<Event_RSVP_Response__c> attendingUsersList = eventDaoObj.getEventAttendingList(contentId,nextPageToken, sortBy);
        List<PeopleLiteWrapper> peopleWrapperList = convertAttendingToWrapper(attendingUsersList);
        Map<Object,Object> result = New Map<Object,Object>();
        if (peopleWrapperList.size() == (SimpplrContext.simpplrDefaultPageSize + 1)){
            peopleWrapperList.remove((peopleWrapperList.size()-1));
            nextPageToken = nextPageToken+SimpplrContext.simpplrDefaultPageSize;	
        }else{
            nextPageToken = null;
        }
        result.put('nextPageToken',nextPageToken);
        result.put('listOfItems',peopleWrapperList);
        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Attending users list fetched!', result);
        return resultWrapper;
    }

	public class Invitee {
		public String id;
        public List<String> peopleList;
        public Boolean sendInvitationMail;
		
        public Invitee() {
			peopleList = new List<String>();
		}

	}
	
    private ResponseWrapper invite(String data) {
        ResponseWrapper resultWrapper = new ResponseWrapper();
        Integer nextPageToken = 0;
        logger.logDebug('invite()---before deserialize----data---'+ data);
        //------------Check and insert new organizers-----------------------
        SiteAddEventDataServer.Invitee inviteeObj  = (SiteAddEventDataServer.Invitee)JSON.deserialize(data, SiteAddEventDataServer.Invitee.class);
        logger.logDebug('invite()---after deserialize----inviteesObj---'+ inviteeObj);
        
        if (inviteeObj == null || String.isEmpty(inviteeObj.id) || 
                inviteeObj.peopleList == null || inviteeObj.peopleList.size() == 0) {
            throw New SimpplrException(ServiceConstants.ERROR_INVALID_REQUEST_PARAMETERS);
        }
        
        List<Simpplr_Content__c> listOfContentObj = [SELECT id,Site__c, Title__c, 
                Is_Published__c 
                FROM Simpplr_Content__c 
                WHERE id =:inviteeObj.id WITH SECURITY_ENFORCED];
        
        if (!listOfContentObj.isEmpty() && !listOfContentObj[0].Is_Published__c) {
        	throw new SimpplrException(ExceptionCode.EVENT_STATUS_UNPUBLISHED.name());
        }

        String contentTitle ='';
        String siteId = listOfContentObj[0].Site__c;
		contentTitle = (listOfContentObj.size() > 0 ? + listOfContentObj[0].title__c : '');

        // User cannot invite himself
        if (inviteeObj.peopleList.contains(UserContext.peopleId) || inviteeObj.peopleList.contains(UserContext.Id)) {
	        throw New SimpplrException(ExceptionCode.EVENT_CANNOT_INVITE_SELF.name());
        }
        
        List<Event_Invitee__c> listOfAlreadyInvitedPeople = eventDaoObj.getEventInvitedUserMapById(inviteeObj.id, inviteeObj.peopleList).values();
        Set<String> setOfAlreadyInvitedPeopleId = new Set<String>();

        for (Event_Invitee__c evtInvitee: listOfAlreadyInvitedPeople) {
        	setOfAlreadyInvitedPeopleId.add(evtInvitee.Invitee__c);
        }

        Set<String> setOfInviteePeople = new Set<String>();
        setOfInviteePeople.addAll(inviteeObj.peopleList);
        List<String> listOfPeopleToRemove = new List<String>();
        
        for (Integer indx = 0; indx < listOfAlreadyInvitedPeople.size(); indx++ ) {

        	if (setOfAlreadyInvitedPeopleId.contains(listOfAlreadyInvitedPeople[indx].Invitee__c)) {
        		listOfPeopleToRemove.add(listOfAlreadyInvitedPeople[indx].Invitee__c);
        	}

        }
        
        //remove current user from invitees list
        listOfPeopleToRemove.add(UserContext.id);
        listOfPeopleToRemove.add(UserContext.peopleId);
        setOfInviteePeople.removeAll(listOfPeopleToRemove);

        if (setOfInviteePeople.size() == 0) {
        	throw new SimpplrException(ExceptionCode.EVENT_USER_ALREADY_INVITED.name());
        }

		inviteeObj.peopleList = new List<String>(setOfInviteePeople);
        List<Event_Invitee__c> inviteeRecords = convertPeopleWrapperToInviteeObject(inviteeObj);

        if (inviteeRecords.size() > 0) {
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(inviteeRecords, 
                    new List<Schema.SObjectField>{
                    Event_Invitee__c.Invitee__c,
                    Event_Invitee__c.Invited_By__c,
                    Event_Invitee__c.Content__c});
        }

        List<App_Notification__c> notificationForInviteeList = new List<App_Notification__c>();
        Set<String> inviteesSet = new Set<String>();
        
        for (Event_Invitee__c invitee : inviteeRecords) {
        	App_Notification__c notificationObj = new App_Notification__c(category__c = 'Invited_To_Event', 
                    Is_Read__c=false,type__c='Information',
                    Status__c='Pending',Object_Type__c='Event', 
                    Object_Id__c=inviteeObj.id,Sent_By__c=UserContext.peopleId, 
                    Simpplr_Site__c = siteId, Sub_Type__c = 'Event Invite',
                    Created_DateTime__c = DateTime.now(), Sent_to__c=invitee.Invitee__c, 
                    Snippet__c = contentTitle);
        	
        	if (inviteesSet.contains(invitee.Invitee__c) == false) {
        		notificationForInviteeList.add(notificationObj);
        	}

        	inviteesSet.add(invitee.Invitee__c);
        }

        NotificationDao.createNotifications(notificationForInviteeList);
        List<Event_Invitee__c>invitedUsersList = eventDaoObj.getEventInvitedUserMapById(inviteeObj.id, inviteeObj.peopleList).values();
        logger.logDebug('====== invitedUsersList---- '+ JSON.serialize(invitedUsersList));
        
        // Send emails on if user selects to send invitation email
        if(inviteeObj.sendInvitationMail != null && inviteeObj.sendInvitationMail){
            new NotificationDispatcher().sendNotificationEmailForEventInviteMore(contentTitle, inviteesSet, notificationForInviteeList);

        }
        List<PeopleLiteWrapper> peopleWrapperList = convertInviteeToWrapper(invitedUsersList);
        Map<String, Object> result = new Map<String, Object>();
        result.put('listOfItems', peopleWrapperList);         
        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'users have been invited!', result);
        return resultWrapper;
    }
    

    private Simpplr_Content__c saveContentObjectToDB(Boolean isEdit, ContentWrapper localWrapperObj, 
            Map<String, String> mapOfNewTopics) {
        Simpplr_Content__c contentObj;
        ManageContentDao manageContentDaoObj = new ManageContentDao();
        String oldAuthorId;
        String oldStatus;

        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

        if (isEdit) {
            contentObj = [SELECT Id, Type__c, Site__c, Status__c, Version__c, Is_Published__c,
                    Primary_Author__c, Primary_Author__r.Full_Name__c, Publish_Start_DateTime__c,
                    Primary_Author__r.Is_Protected_Author__c 
            		FROM Simpplr_Content__c 
            		WHERE id =: localWrapperObj.id 
            		And Type__c =: ServiceConstants.TYPE_EVENT
            		And Site__c=: localWrapperObj.siteId WITH SECURITY_ENFORCED]; 
            
            oldStatus = contentObj.Status__c;

            // Update version        
            if(contentObj.Version__c != null){
                contentObj.Version__c = contentObj.Version__c + 1;
                fieldList.add(Simpplr_Content__c.Version__c);
            }

            if (!AccessManager.hasContentEditAccess(contentObj.Status__c, 
                    Usercontext.peopleId.equalsIgnoreCase(contentObj.Primary_Author__c))) {
                throw new SimpplrException(ServiceConstants.ERROR_403);
                
            } else if(contentObj.Primary_Author__r.Is_Protected_Author__c && 
                        (!UserContext.peopleId.equalsIgnoreCase(contentObj.Primary_Author__c) && 
                        !UserContext.isProtectedAuthorAllowlisted && 
                        !UserContext.isUserAppModerator)) {
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }
            
            if (ACTION_VALUE_UPDATE.equalsIgnoreCase(localWrapperObj.status)) {
            	
                if (ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(contentObj.Status__c)) {
            	    contentObj.Status__c = hasContentApprovalAccess ? 
                            ServiceConstants.CONTENT_STATUS_APPROVED : ServiceConstants.CONTENT_STATUS_SUBMITTED;
            	}

            } else {
            	contentObj.Status__c = localWrapperObj.status;
            }

        } else {

            Utility.checkForRateLimit('content');
                        
	        contentObj = New Simpplr_Content__c();
	        contentObj.Type__c = ServiceConstants.TYPE_EVENT;
	        contentObj.Site__c = localWrapperObj.siteId;
	        contentObj.Status__c = localWrapperObj.status;

            fieldList.add(Simpplr_Content__c.Type__c);
            fieldList.add(Simpplr_Content__c.Site__c);
        }

        fieldList.add(Simpplr_Content__c.Status__c);
        
        contentObj.Title__c = localWrapperObj.title;
        fieldList.add(Simpplr_Content__c.Title__c);
        
        if(localWrapperObj.bodyJson!=null){
            List<String> contentBodyJsonParts = getContentJsonBodyParts(JSON.serialize(localWrapperObj.bodyJson,true), mapOfNewTopics);
			contentObj.Text_Json__c =  contentBodyJsonParts[0];
			contentObj.Text_Main_Json__c =  contentBodyJsonParts[1];
			contentObj.Text_Main_Continued_Json__c =  contentBodyJsonParts[2];	
			fieldList.add(Simpplr_Content__c.Text_Json__c);
			fieldList.add(Simpplr_Content__c.Text_Main_Json__c);
			fieldList.add(Simpplr_Content__c.Text_Main_Continued_Json__c);
		}

        List<String> contentBodyParts = getContentBodyParts(localWrapperObj.body, mapOfNewTopics);
        contentObj.Text_Intro__c = contentBodyParts[0];
        contentObj.Text_Main__c = contentBodyParts[1];
        contentObj.Text_Main_Continued__c = contentBodyParts[2];
        contentObj.Excerpt__c = Utility.getPlainText(contentObj.Text_Intro__c, 250, true);
        contentObj.Summary_1__c	= String.valueOf(String.isEmpty(localWrapperObj.summary) 
                ? '' : localWrapperObj.summary.unescapeHtml4()).replace('&#8203;','');

        fieldList.add(Simpplr_Content__c.Text_Intro__c);
        fieldList.add(Simpplr_Content__c.Text_Main__c);
        fieldList.add(Simpplr_Content__c.Text_Main_Continued__c);
        fieldList.add(Simpplr_Content__c.Excerpt__c);
        fieldList.add(Simpplr_Content__c.Summary_1__c);
        
        if(SiteContext.isQuestionAnswerEnabled && localWrapperObj.isQuestionAnswerEnabled != null) {
			contentObj.Question_Answer_Enabled__c = localWrapperObj.isQuestionAnswerEnabled;
            fieldList.add(Simpplr_Content__c.Question_Answer_Enabled__c);
		}
        contentObj.Cover_Image_Layout__c = localWrapperObj.imgLayout;
        contentObj.Title_Image_Caption__c = localWrapperObj.imgCaption;        
        contentObj.Display_Excerpt__c = Utility.getDisplayExcerpt(contentObj.Excerpt__c,contentObj.Summary_1__c);	

        fieldList.add(Simpplr_Content__c.Cover_Image_Layout__c);
        fieldList.add(Simpplr_Content__c.Title_Image_Caption__c);
        fieldList.add(Simpplr_Content__c.Display_Excerpt__c);

        if (String.isNotBlank(localWrapperObj.publishAt)) {
            // publishAt => 2022-07-04T00:00:00 from UI
			contentObj.Publish_Start_DateTime__c = Utility.momentJSDateTimeStringToDateTime(localWrapperObj.publishAt);
            fieldList.add(Simpplr_Content__c.Publish_Start_DateTime__c);
        } else {
            throw New SimpplrException(ExceptionCode.EMPTY_PUBLISH_START_DATE.name());
        }

        contentObj.Publish_End_DateTime__c = String.isNotBlank(localWrapperObj.publishTo) ? 
                Utility.momentJSDateTimeStringToDateTime(localWrapperObj.publishTo) : null;
        contentObj.Allow_comments__c = localWrapperObj.isFeedEnabled == true ? true : false;
		contentObj.Last_Edited_DateTime__c = DateTime.now();
        contentObj.Last_Updated_DateTime__c = DateTime.now();
		contentObj.Last_UpdatedBy_People__c = UserContext.getCurrentUserInfo.Id;

        fieldList.add(Simpplr_Content__c.Publish_End_DateTime__c);
        fieldList.add(Simpplr_Content__c.Allow_comments__c);
        fieldList.add(Simpplr_Content__c.Last_Edited_DateTime__c);
        fieldList.add(Simpplr_Content__c.Last_Updated_DateTime__c);
        fieldList.add(Simpplr_Content__c.Last_UpdatedBy_People__c);

        //----------------Event specific fields wrapping--------------------------------------------------------
        contentObj.Event_TimezoneSidKey__c = localWrapperObj.timezoneIso;
        contentObj.Event_Is_All_Day__c = localWrapperObj.isAllDay == true ? true : false;
        contentObj.Event_Start_DateTime__c = String.isNotBlank(localWrapperObj.startsAt) ? 
                Utility.momentJSDateTimeStringToDateTime(localWrapperObj.startsAt) : null;
        contentObj.Event_End_DateTime__c = String.isNotBlank(localWrapperObj.endsAt) ? 
                Utility.momentJSDateTimeStringToDateTime(localWrapperObj.endsAt) : null;
        contentObj.Event_RSVP_Allowed__c = localWrapperObj.hasRsvp;
        contentObj.Event_RSVP_Show_Maybe__c = false; 

        fieldList.add(Simpplr_Content__c.Event_TimezoneSidKey__c);
        fieldList.add(Simpplr_Content__c.Event_Is_All_Day__c);
        fieldList.add(Simpplr_Content__c.Event_Start_DateTime__c);
        fieldList.add(Simpplr_Content__c.Event_End_DateTime__c);
        fieldList.add(Simpplr_Content__c.Event_RSVP_Allowed__c);
        fieldList.add(Simpplr_Content__c.Event_RSVP_Show_Maybe__c);

        if (contentObj.Event_RSVP_Allowed__c && localWrapperObj.rsvp != null) {
            contentObj.Event_RSVP_Show_Maybe__c = localWrapperObj.rsvp.hasMaybeOption == true ? true : false;
            contentObj.Event_RSVP_Note__c = localWrapperObj.rsvp.noteLabel;
            contentObj.Event_RSVP_Limit__c = localWrapperObj.rsvp.capacityCount;
            
            if (String.isNotBlank(localWrapperObj.rsvp.dueAtDate)) {
            	contentObj.Event_RSVP_By_DateTime__c = Utility.momentJSDateTimeStringToDateTime(localWrapperObj.rsvp.dueAtDate);
            
            } else {
            	contentObj.Event_RSVP_By_DateTime__c = null;
            }

            fieldList.add(Simpplr_Content__c.Event_RSVP_Note__c);
            fieldList.add(Simpplr_Content__c.Event_RSVP_Limit__c);
            fieldList.add(Simpplr_Content__c.Event_RSVP_By_DateTime__c);
        }

        contentObj.Event_Location__c = localWrapperObj.location;
        contentObj.Event_Map_URL__c = localWrapperObj.mapUrl;
        contentObj.Event_Directions_Enabled__c = localWrapperObj.hasDirections == true ? true : false;
        contentObj.Event_Directions__c = '[]';

        fieldList.add(Simpplr_Content__c.Event_Location__c);
        fieldList.add(Simpplr_Content__c.Event_Map_URL__c);
        fieldList.add(Simpplr_Content__c.Event_Directions_Enabled__c);
        fieldList.add(Simpplr_Content__c.Event_Directions__c);

        if (contentObj.Event_Directions_Enabled__c) {
            
            if (localWrapperObj.directions != null && localWrapperObj.directions.size() > 0) {
                contentObj.Event_Directions__c = JSON.serialize(localWrapperObj.directions);
            }
        }
        
        if (isEdit) {
            oldAuthorId = String.valueOf(contentObj.Primary_Author__c);
	        
            if (hasContentApprovalAccess && localWrapperObj.authoredBy != null && 
                    String.isNotBlank(localWrapperObj.authoredBy.peopleId)) {

	            contentObj.Primary_Author__c = localWrapperObj.authoredBy.peopleId;
                fieldList.add(Simpplr_Content__c.Primary_Author__c);
	        }
	        
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
 			SIMPESAPI.accessController().updateAsUser(contentObj, fieldList);

            // enable content notifications for the user
            if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
				Content_Notification_Setting__c contentNotiSettingObj = manageContentDaoObj.getNotificationSetting(contentObj.Id, UserContext.peopleId);

				if(contentNotiSettingObj == null) {
					manageContentDaoObj.insertContentNotificationSettingForUser(contentObj.Id, UserContext.peopleId);
				}
			}

            if (localWrapperObj.authoredBy != null) {
                if(ServiceConstants.CONTENT_STATUS_DRAFT.equalsIgnoreCase(oldStatus) && ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
                    sendNotificationForPublishedOnYourBehalf(localWrapperObj.authoredBy.peopleId, contentObj);
                    
                } else if(localWrapperObj.authoredBy.peopleId != oldAuthorId) {
                    sendNotificationOnAuthorChange(oldAuthorId, localWrapperObj.authoredBy.peopleId, contentObj);

                }
            }
            
            logger.logDebug('SiteAddEventDataServer.saveContentObjectToDB()----oldAuthorId----'+oldAuthorId+'--localWrapperObj.authoredBy.peopleId--'+localWrapperObj.authoredBy.peopleId+'--contentObj--'+contentObj);
	     
        } else {
            contentObj.Created_DateTime__c = DateTime.now();
			contentObj.CreatedBy_People__c = UserContext.getCurrentUserInfo.Id;
        	contentObj.OwnerId = eventDaoObj.getContentOwnerId('Simpplr_' + SiteContext.chatterGroupId + '_Admin');
        	contentObj.Primary_Author__c = UserContext.getCurrentUserInfo.Id;

            fieldList.add(Simpplr_Content__c.Created_DateTime__c);
 			fieldList.add(Simpplr_Content__c.CreatedBy_People__c);
 			fieldList.add(Simpplr_Content__c.OwnerId);
            fieldList.add(Simpplr_Content__c.Primary_Author__c);
 			
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(
					new List<Simpplr_Content__c>{contentObj}, fieldList);
            
            List<Simpplr_Content__c> listOfContentObj = new List<Simpplr_Content__c>();
			listOfContentObj = (List<Simpplr_Content__c>) result.getInsertedObjects();
            contentObj = listOfContentObj[0];

            // enable content notifications for the user
			if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(contentObj.Status__c)) {
				manageContentDaoObj.insertContentNotificationSettingForUser(contentObj.Id, UserContext.peopleId);
			}
        }

        return contentObj;
    }

    private List<PeopleLiteWrapper> convertInviteeToWrapper (List<Event_Invitee__c> inviteeList) {
        List<PeopleLiteWrapper> wrapperList = New List<PeopleLiteWrapper>();
        PeopleLiteWrapper peopleWrapperObj;
        
        if (!inviteeList.isEmpty()) {
        	Set<Id> setOfPeopleIdOfInvitee =  new set<Id>();
      		String loggedInUserPeopleId = UserContext.peopleId;
      		
      		for (Event_Invitee__c inviteeRecord : inviteeList) {
      			setOfPeopleIdOfInvitee.add(inviteeRecord.Invitee__c);
      		}
      		
      		Set<Id> setOfFavoritePeopleId = new Set<Id>();
      		
      		if (!setOfPeopleIdOfInvitee.isEmpty()) {
      			List<Bookmark__c > listOfFavorite = [SELECT Id, People__c, 	Type__c, 
      					Bookmark_Receiver__c 
    					FROM Bookmark__c 
    					WHERE People__c =:loggedInUserPeopleId AND Type__c='People' 
    					AND Bookmark_Receiver__c IN: setOfPeopleIdOfInvitee  AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
    			
    			for (Bookmark__c favObj : listOfFavorite) {
    				setOfFavoritePeopleId.add(favObj.Bookmark_Receiver__c);
    			}
    			
      		}
      		
            for (Event_Invitee__c inviteeRecord : inviteeList) {
                peopleWrapperObj = new PeopleLiteWrapper();
                peopleWrapperObj.id = inviteeRecord.Invitee__c;
                peopleWrapperObj.sfUserId = inviteeRecord.Invitee__r.User__r.Id;
                peopleWrapperObj.peopleId = inviteeRecord.Invitee__c;
                peopleWrapperObj.name = inviteeRecord.Invitee__r.Full_Name__c; 
               	peopleWrapperObj.isFavorited = setOfFavoritePeopleId.contains(inviteeRecord.Invitee__c)? true: false;
               	peopleWrapperObj.isFollowing = UserContext.usersIFollowIdSet.contains(inviteeRecord.Invitee__r.User__c);
                peopleWrapperObj.department = SimpplrContext.isPPDepartmentDisplay == false ? null:inviteeRecord.Invitee__r.Department__c;
                peopleWrapperObj.title = SimpplrContext.isPPTitleDisplay == false ? null:inviteeRecord.Invitee__r.title__c;
                peopleWrapperObj.city = SimpplrContext.isPPCityDisplay == false ? null:inviteeRecord.Invitee__r.city__c;
                peopleWrapperObj.state = SimpplrContext.isPPStateDisplay == false ? null:inviteeRecord.Invitee__r.state__c;
                peopleWrapperObj.country = SimpplrContext.isPPCountryDisplay == false ? null:inviteeRecord.Invitee__r.country__c;
                peopleWrapperObj.location = Utility.buildLocation(peopleWrapperObj.city, peopleWrapperObj.state, peopleWrapperObj.country);
                peopleWrapperObj.email = inviteeRecord.Invitee__r.Email__c;
                peopleWrapperObj.mobile = SimpplrContext.isPPMobilePhoneDisplay == false ? null:inviteeRecord.Invitee__r.Mobile_Phone__c;
                peopleWrapperObj.phone = SimpplrContext.isPPPhoneDisplay == false ? null:inviteeRecord.Invitee__r.Phone__c;
                peopleWrapperObj.phoneExtension = SimpplrContext.isPPExtensionDisplay == false ? null:inviteeRecord.Invitee__r.Extension__c;
                peopleWrapperObj.isActive = inviteeRecord.Invitee__r.User__r.isactive;
                peopleWrapperObj.img = inviteeRecord.Invitee__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null:inviteeRecord.Invitee__r.User__r.SmallPhotoUrl;
                peopleWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleWrapperObj.peopleId;
				peopleWrapperObj.canFollow = UserContext.getCurrentUserInfo.Id == peopleWrapperObj.Id ? false : peopleWrapperObj.isActive;
				
				if (ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
					peopleWrapperObj.videoCallUsername = inviteeRecord.Invitee__r.Zoom_Id__c;

				} else if (ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
					peopleWrapperObj.videoCallUsername = inviteeRecord.Invitee__r.Skype_Id__c;
				}

				peopleWrapperObj.videoCallProvider = SimpplrContext.PPVideoProvider;
                wrapperList.add(peopleWrapperObj);
            }
            
        }
        
        return wrapperList;
    }
	
	private List<PeopleLiteWrapper> convertAttendingToWrapper (List<Event_RSVP_Response__c> attendingUsersList) {
        List<PeopleLiteWrapper> wrapperList = New List<PeopleLiteWrapper>();
        PeopleLiteWrapper peopleWrapperObj;
        
        if (!attendingUsersList.isEmpty()) {
        	Set<Id> setOfPeopleIdOfAttending =  new set<Id>();
      		String loggedInUserPeopleId = UserContext.peopleId;
      		
      		for (Event_RSVP_Response__c attendingRecord : attendingUsersList) {
      			setOfPeopleIdOfAttending.add(attendingRecord.People__r.Id);
      		}
      		
      		Set<Id> setOfFavoritePeopleId = new Set<Id>();
      		
      		if (!setOfPeopleIdOfAttending.isEmpty()) {
      			List<Bookmark__c > listOfFavorite = [SELECT Id, People__c, 	Type__c, 
      					Bookmark_Receiver__c 
    					FROM Bookmark__c 
    					WHERE People__c =:loggedInUserPeopleId AND Type__c='People' 
    					AND Bookmark_Receiver__c IN: setOfPeopleIdOfAttending AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
    			
    			for (Bookmark__c favObj : listOfFavorite) {
    				setOfFavoritePeopleId.add(favObj.Bookmark_Receiver__c);
    			}
    			
      		}
      		
            for (Event_RSVP_Response__c attendingRecord : attendingUsersList) {
                peopleWrapperObj = new PeopleLiteWrapper();
                peopleWrapperObj.Id = attendingRecord.People__c;
                peopleWrapperObj.sfUserId = attendingRecord.People__r.User__c;
                peopleWrapperObj.peopleId = attendingRecord.People__r.Id;
                peopleWrapperObj.name = attendingRecord.People__r.Full_Name__c; 
               	peopleWrapperObj.isFavorited = setOfFavoritePeopleId.contains(attendingRecord.People__r.Id)? true: false;
               	peopleWrapperObj.isFollowing = UserContext.usersIFollowIdSet.contains(attendingRecord.People__r.User__c);
                peopleWrapperObj.department = SimpplrContext.isPPDepartmentDisplay == false ? null:attendingRecord.People__r.Department__c;
                peopleWrapperObj.title = SimpplrContext.isPPTitleDisplay == false ? null:attendingRecord.People__r.title__c;
                peopleWrapperObj.city = SimpplrContext.isPPCityDisplay == false ? null:attendingRecord.People__r.city__c;
                peopleWrapperObj.state = SimpplrContext.isPPStateDisplay == false ? null:attendingRecord.People__r.state__c;
                peopleWrapperObj.email = attendingRecord.People__r.Email__c;
                peopleWrapperObj.mobile = SimpplrContext.isPPMobilePhoneDisplay == false ? null:attendingRecord.People__r.Mobile_Phone__c;
                peopleWrapperObj.phone = SimpplrContext.isPPPhoneDisplay == false ? null:attendingRecord.People__r.Phone__c;
                peopleWrapperObj.phoneExtension = SimpplrContext.isPPExtensionDisplay == false ? null:attendingRecord.People__r.Extension__c;
                peopleWrapperObj.country = SimpplrContext.isPPCountryDisplay == false ? null:attendingRecord.People__r.country__c;
                peopleWrapperObj.location = Utility.buildLocation(peopleWrapperObj.city, peopleWrapperObj.state, peopleWrapperObj.country);
                peopleWrapperObj.email = attendingRecord.People__r.Email__c;
                peopleWrapperObj.isActive = attendingRecord.People__r.User__r.isactive;
                peopleWrapperObj.img = attendingRecord.People__r.User__r.SmallPhotoUrl.endsWith('005/T') ? null:attendingRecord.People__r.User__r.SmallPhotoUrl;
                peopleWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + peopleWrapperObj.peopleId;
                peopleWrapperObj.canFollow = UserContext.getCurrentUserInfo.Id == peopleWrapperObj.Id ? false : peopleWrapperObj.isActive; 
                
                if (ServiceConstants.VIDEO_PROVIDER_ZOOM.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
					peopleWrapperObj.videoCallUsername = attendingRecord.People__r.Zoom_Id__c;

				} else if (ServiceConstants.VIDEO_PROVIDER_SKYPE.equalsIgnoreCase(SimpplrContext.PPVideoProvider)) {
					peopleWrapperObj.videoCallUsername = attendingRecord.People__r.Skype_Id__c;
				}

				peopleWrapperObj.videoCallProvider = SimpplrContext.PPVideoProvider;
                wrapperList.add(peopleWrapperObj);
            }
            
        }
        
        return wrapperList;
    }
    private List<Event_Invitee__c> convertPeopleWrapperToInviteeObject (SiteAddEventDataServer.Invitee 
    		inviteeObj) {
        List<Event_Invitee__c> result = new List<Event_Invitee__c>();
        Event_Invitee__c inviteeRecord;
        
        if (inviteeObj.peopleList != null && inviteeObj.peopleList.size() > 0) {
        	
            for (String pplId : inviteeObj.peopleList) {
                inviteeRecord = new Event_Invitee__c();
                inviteeRecord.Invitee__c = pplId;
                inviteeRecord.Invited_By__c = UserContext.peopleId;
                inviteeRecord.Content__c = inviteeObj.id;
                result.add(inviteeRecord);
            }
            
        }

        return result;
    }

    private ResponseWrapper processContentData(String data, String status, String draftType) {
        logger.logDebug('SiteAddEventDataServer.processContentData()----status----' + status);
        ContentWrapper wrapperObj = ContentWrapper.parse(data);
        Savepoint sp;
		ResponseWrapper result;
		try{
            wrapperObj.status = status ;
            wrapperObj.id = wrapperObj.id == null ? readParam('contentId') : wrapperObj.id;
            Boolean isEdit = String.isNotBlank(wrapperObj.id);

            String contentStatusOld = '';
            // Check if content update is there then pass exsiting content object to create history and trails
            Simpplr_Content__c content = ManageContentDao.getContentById(wrapperObj.id);
            if(content != null) {
                contentStatusOld = content.Status__c;
            }

            //sanitize content data before savepoint
            if(wrapperObj.bodyJson!=null) {
                String sanitizedHTML = Utility.getSanitizedHTMLfromLambda(wrapperObj.body);
                wrapperObj.body = sanitizedHTML;
            }

            sp = Database.setSavepoint();

            // Step 1: Create new topics or get existing topicId if topic exists already
            Map<String, String> mapOfNewTopics = createNewTopics(wrapperObj.listOfTopics, 
                    wrapperObj.listOfContentTopicIds);
        
            // Step 2: Save Simpplr_Content__c record
            ContentTriggerHandler.isCalledFromEditContentScreen = true;
            wrapperObj.id = wrapperObj.id == null ? readParam('contentId') : wrapperObj.id;
            wrapperObj.siteId = wrapperObj.siteId == null ? SiteContext.siteId : wrapperObj.siteId;
            Simpplr_Content__c contentObj = saveContentObjectToDB(isEdit, wrapperObj, mapOfNewTopics);
            
            // Step 3: Send approval notification if required
            if (isEdit && ServiceConstants.CONTENT_STATUS_APPROVED.equals(status)) {
                    AllContentDataServer contentServerObj =  new AllContentDataServer();
                    contentServerObj.checkAndApproveNotifications(contentObj);
            }
            
            // Step 4: Save File__c records
            saveContentFilesToDB(isEdit, contentObj.id, wrapperObj, status);
            // Step 5: Save TopicAssignment records
            saveTopicAssignmentsToDB(isEdit, contentObj.id, wrapperObj.listOfTopics, 
                    wrapperObj.listOfContentTopicIds, mapOfNewTopics);
            
            // Save Suggested Topics from AI 
            if(wrapperObj.listOfSuggestedTopics!=null){
                saveAISuggestedTopicsToDB(wrapperObj.listOfSuggestedTopics, contentObj.id, wrapperObj.listOfTopics, mapOfNewTopics);
            }  
                
            //------------Check and insert new organizers-----------------------
            
            if (SimpplrContext.isExternalSearchAppConnected) {
                ManageContentDao.insertSearchTrailObjectForContentAsync(contentObj.id);
            }
            
            // Step 6: Save Content_Collaborator__c records
            saveEventOrganizersToDB(isEdit, contentObj.id, wrapperObj.listOfOrganizers);

            //Create content history record asynchronously
            if(isEdit){
                if(ACTION_VALUE_UPDATE.equalsIgnoreCase(status)){
                    ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_UPDATE, ServiceConstants.TYPE_EVENT);

                } else if(ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT.equalsIgnoreCase(draftType)){
                    ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT, ServiceConstants.TYPE_EVENT);

                } else if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(status) && 
                    ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(contentStatusOld)) {
                    ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_UPDATE, ServiceConstants.TYPE_EVENT);
                
                } else if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(status)) {
                    ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_UPDATE_DRAFT, ServiceConstants.TYPE_EVENT);

                } 
            }else{
                if(ServiceConstants.CONTENT_STATUS_CREATE_DRAFT.equalsIgnoreCase(draftType)){
                    ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT, ServiceConstants.TYPE_EVENT);

                } else if(ServiceConstants.CONTENT_STATUS_APPROVED.equalsIgnoreCase(status)){
                    ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_APPROVED, ServiceConstants.TYPE_EVENT);

                } else if(ServiceConstants.CONTENT_STATUS_SUBMITTED.equalsIgnoreCase(status)) {
                    ManageContentDao.createContentHistoryAndAuditRecordsAsync(contentObj.id, ServiceConstants.CONTENT_STATUS_CREATE_DRAFT, ServiceConstants.TYPE_EVENT);
                }
            }

            if (ServiceConstants.CONTENT_STATUS_SUBMIITED.equalsIgnoreCase(status)) {
                ManageContentDao daoObj = new ManageContentDao();
                daoObj.createContentAuditTrail(contentObj.id, status, null); 
                Map<String,App_Notification__c> userToNotificationMap = NotificationDao.generateReviewNotifications(contentObj.Id, 
                        ServiceConstants.TYPE_EVENT, contentObj.title__c, contentObj.site__c, 
                        contentObj.Summary_1__c);
                NotificationDispatcher.sendEmailForContentModeration(contentObj);
            }

            result = getContent(contentObj.Id);

        }catch(Exception ex) {
            logger.logError('SiteAddEventDataServer.processContentData()---Exception occured----', ex);
			if(sp!=null){
				Database.rollback(sp);
			}
            result = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
       	
        return result;
    }
    
    private void saveEventOrganizersToDB(Boolean isEdit, Id contentId, 
            List<PeopleListWrapper> listOfOrganizers) {
    	Map<Id, Content_Collaborator__c> mapOfExistingOrganizers = new Map<Id, Content_Collaborator__c>();
        
        if (isEdit) {
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('soqlParam1', contentId);
            String collaboratorQuery = 'SELECT Id FROM Content_Collaborator__c WHERE Simpplr_Content__c=:soqlParam1 And Type__c=\'Organizer\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        mapOfExistingOrganizers = new Map<Id, Content_Collaborator__c>((List<Content_Collaborator__c>)SIMPESAPI.accessController().queryAsUser(collaboratorQuery, soqlParamMap));
        }

        if (listOfOrganizers != null && listOfOrganizers.size() > 0) {
        	List<Content_Collaborator__c> listOfNewContentCollaborator = new List<Content_Collaborator__c>();
            
            for (PeopleListWrapper organizer : listOfOrganizers) {
            	
                if (mapOfExistingOrganizers.containsKey(organizer.Id)) {
            		mapOfExistingOrganizers.remove(organizer.Id);
            	
                } else {
            		Content_Collaborator__c newOrganizer = new Content_Collaborator__c();
            		newOrganizer.Simpplr_Content__c = contentId;
            		newOrganizer.Type__c = 'Organizer';
            		newOrganizer.Collaborator__c =  organizer.peopleId;
            		listOfNewContentCollaborator.add(newOrganizer);
            	}

            }

            if (listOfNewContentCollaborator.isEmpty() == false) {
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().insertAsUser(listOfNewContentCollaborator, 
                        new List<Schema.SObjectField>{
                        Content_Collaborator__c.Simpplr_Content__c,
                        Content_Collaborator__c.Type__c,
                        Content_Collaborator__c.Collaborator__c});
            }

        }

        if (mapOfExistingOrganizers.isEmpty() == false) {
            List<Content_Collaborator__c> listOfDeletedContentCollaborator = new List<Content_Collaborator__c>();
            
            for (Content_Collaborator__c deletedOrganizer : mapOfExistingOrganizers.values()) {
                deletedOrganizer.Is_Deleted__c = true;
                listOfDeletedContentCollaborator.add(deletedOrganizer);
            }

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, Content_Collaborator__c>(listOfDeletedContentCollaborator),
            new List<Schema.SObjectField>{
                Content_Collaborator__c.Is_Deleted__c
            });
        }

    }

    private ResponseWrapper getEventByVersionHistoryId(String contentId, String versionId){
		logger.logDebug('SiteAddEventDataServer.getEventByVersionHistoryId()---data---' + contentId);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	String redirectUrl = null;
    	
    	try {
    		String content_LastModifiedTimeStamp = readParam(CONTENT_LASTMODIFIEDDATETIMESTAMP);
    		
    		if (String.valueOf(SimpplrContext.allowedFeatures).containsIgnoreCase(ServiceConstants.TYPE_PAGE) == false) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
			}

            List<String> eventFieldList = new List<String>{
                'Last_Moved_DateTime__c',
    			'Event_Location__c',
				'Event_Is_All_Day__c',
				'Event_Start_DateTime__c',
				'Event_End_DateTime__c',
				'Event_RSVP_Allowed__c',
				'Event_RSVP_Show_Maybe__c',
				'Event_RSVP_Note__c',
				'Event_RSVP_Limit__c',
				'Event_RSVP_By_DateTime__c',
				'Event_Directions_Enabled__c',
				'Event_Map_URL__c',
				'Event_Directions__c',
                'Event_Attending_Count__c',
                'Event_TimezoneSidKey__c'
			};
			eventFieldList.addAll(getContentDetailFieldList());	
	    	String query = 'SELECT '+ String.join(eventFieldList,',') + 
					' FROM Simpplr_Content__c WHERE id=:contentId AND Type__c = \'Event\' ';
	    	List<Simpplr_Content__c> contentObjList = Database.query(query); 
	  
	    	if (contentObjList.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	
	    	} else if (contentObjList[0].Site__r.Show_In_Simpplr__c == false) {
	    		redirectUrl = SimpplrContext.salesforceBaseUrl + '/' + 
						contentObjList[0].Site__r.Chatter_Group_Id__c;
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    
	    	} else if (contentObjList[0].Is_Deleted__c || 
					(contentObjList[0].Activated_By_Feature__c == false) || 
					(contentObjList[0].Site__r.Is_Active__c == false)) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    	
            } else if(AccessManager.calculateContentViewAccess(contentObjList[0].Type__c,
                             contentObjList[0].Is_Published__c,
                             contentObjList[0].Site__c, contentObjList[0].Site__r.Site_Type__c,
                             contentObjList[0].Status__c, contentObjList[0].Primary_Author__r.User__c)) {

    			ContentWrapper wrapperObj = getEventWrapperByVersion(contentId, versionId);

				resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
				
			} else {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}

    	} catch (exception ex) {
    		logger.logError('Exception Details', ex);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);

        	if (String.isNotBlank(redirectUrl)) {
        		resultWrapper.redirectUrl = redirectUrl;
        	}

        }

        return resultWrapper;
	}

	public ContentWrapper getEventWrapperByVersion(String contentId, String versionId){
        ContentWrapper wrapperObj  	= New ContentWrapper();
        List<Content_History__c> contentHistoryList = [SELECT Id, Content__c, Collaborator_Json__c, Content_Json_Part1__c,
                                                        Content_Json_Part2__c, Content_Json_Part3__c, Content_Json_Part4__c,
                                                        Content_Json_Part5__c, File_Json__c, File_Json_Part1__c, File_Json_Part2__c,
                                                        File_Json_Part3__c, Topic_Json__c, Version__c FROM Content_History__c
														WHERE Content__c = :contentId AND Version__c = :Decimal.valueOf(versionId) AND IsDeleted = false WITH SECURITY_ENFORCED ORDER BY Version__c ASC];

		if(!contentHistoryList.isEmpty() && contentHistoryList.size() > 0){
            ManageContentDao contentDao = new ManageContentDao();
            String contentJsonStr = contentDao.mergeContentHistoryJsonStrings(contentHistoryList[0], 'content');
            
			String unescapedContentJsonStr= contentJsonStr.unescapeUnicode();
			Simpplr_Content__c contentRecord;
			
			try{
				contentRecord = (Simpplr_Content__c) JSON.deserialize(unescapedContentJsonStr, Type.forName('Simpplr_Content__c'));
			}catch(Exception e) {                    
				contentRecord = (Simpplr_Content__c) JSON.deserialize(contentJsonStr, Type.forName('Simpplr_Content__c'));
			}

			Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
			
			wrapperObj.id = contentRecord.id;
			wrapperObj.isLatest = false;
			wrapperObj.versionId = contentHistoryList[0].Version__c;
			wrapperObj.contentId = contentRecord.id;
			wrapperObj.contentBodyUrl = PageContext.getPageURL(Pages.ContentBody) + '?contentId=' + contentRecord.id;
			wrapperObj.title = Utility.getAllValidWords(contentRecord.Title__c, contentRecord.Title__c.length(), false);
			wrapperObj.type = contentRecord.Type__c.toLowerCase();
			wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c) ? '': contentRecord.Display_Excerpt__c.unescapeHtml4();
			wrapperObj.summary = String.isBlank(contentRecord.Summary_1__c) ? '' : contentRecord.Summary_1__c.unescapeHtml4();
			wrapperObj.isPublished = contentRecord.Is_Published__c;
            wrapperObj.status = getContentStatus(contentRecord.Status__c, contentRecord.Is_Published__c);
            wrapperObj.isScheduled = checkIfContentScheduled(wrapperObj.status, contentRecord.Publish_Start_DateTime__c);
			wrapperObj.isFeedEnabled = contentRecord.Allow_comments__c;
			wrapperObj.imgLayout = contentRecord.Cover_Image_Layout__c;
			wrapperObj.lastMovedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Moved_DateTime__c);
			wrapperObj.isMustRead 		= false;
			wrapperObj.MustReadDetails = null;
			wrapperObj.imgCaption = contentRecord.Title_Image_Caption__c;
			wrapperObj.isLiked = false;
			wrapperObj.likeCount = Integer.valueOf(contentRecord.Likes__c);
			wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/event/'+contentRecord.Id;
			wrapperObj.editUrl = wrapperObj.url + '/edit';
            if(String.isNotBlank(contentRecord.Text_Json__c)) {
                String bodyJsonData =  getMergedBodyJson(contentRecord.Text_Json__c, contentRecord.Text_Main_Json__c, contentRecord.Text_Main_Continued_Json__c );
			    wrapperObj.bodyJson = (TipTapBodyWrapper)JSON.deserialize(bodyJsonData, TipTapBodyWrapper.class);
            } 
            wrapperObj.body = (String.isNotBlank(contentRecord.Text_Intro__c) ? 
                    contentRecord.Text_Intro__c : '') +
                    (String.isNotBlank(contentRecord.Text_Main__c) ? contentRecord.Text_Main__c : '') +
                    (String.isNotBlank(contentRecord.Text_Main_Continued__c) ? 
                    contentRecord.Text_Main_Continued__c : '');
            
			wrapperObj.isFavorited = false;
			wrapperObj.favoriteContext = contentRecord.Type__c;
			wrapperObj.hasRead = false;
            wrapperObj.readAt = null;
            wrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Edited_DateTime__c);
			wrapperObj.publishAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_Start_DateTime__c);
			wrapperObj.publishTo = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_End_DateTime__c);
			wrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(contentRecord.CreatedDate);
			wrapperObj.lastModifiedDateTimeStamp = contentRecord.Last_Updated_DateTime__c != null ? contentRecord.Last_Updated_DateTime__c.getTime() : 0;
			wrapperObj.firstPublishedAt = contentRecord.First_Publish_DateTime__c  != null ? Utility.dateTimeToMomentJSDateTime(contentRecord.First_Publish_DateTime__c) : null; 
			wrapperObj.site = getSiteDetails(contentRecord.Site__c);
            
            if(String.isNotBlank(contentRecord.Primary_Author__c)){
				wrapperObj.authoredBy = getPeopleListWrapper(contentRecord.Primary_Author__c);
            }

            wrapperObj.canEdit = AccessManager.calculateEditAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);

            App_Config__c appConfigObj = SimpplrContext.appConfig;
            String baseURL = 'https://outlook.office365.com';
            if(String.isNotBlank(appConfigObj.Calendar_Office365_URL__c)){
                baseURL = appConfigObj.Calendar_Office365_URL__c;
            }
            CalendarUtility utilityObj = new CalendarUtility();
            wrapperObj.googleCalendarWebUrl = appConfigObj.Calendar_Google_Enabled__c ? 
                    utilityObj.getGoogleCalendarWebUrl(contentRecord) : '';
            wrapperObj.outlookWebUrl = appConfigObj.Calendar_Outlook_Web_Enabled__c ? 
                    utilityObj.getOutlookWebUrl(contentRecord) : '';
            wrapperObj.icsDownloadUrl = appConfigObj.Calendar_App_Enabled__c ? 
                    utilityObj.getIcsDownloadUrl(contentRecord) : '';
            wrapperObj.office365WebUrl = appConfigObj.Calendar_Office365_Enabled__c ? 
                    utilityObj.getOffice365WebUrl(contentRecord,baseURL) : '';
            wrapperObj.location = contentRecord.Event_Location__c;
            wrapperObj.hasDirections = contentRecord.Event_Directions_Enabled__c;
            wrapperObj.mapUrl = contentRecord.Event_Map_URL__c;
            wrapperObj.isAllDay = contentRecord.Event_Is_All_Day__c;

            if(String.isNotBlank(contentRecord.Event_TimezoneSidKey__c)) {
                TimeZone tz = Timezone.getTimeZone(contentRecord.Event_TimezoneSidKey__c);
                wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentRecord.Event_TimezoneSidKey__c);
                wrapperObj.timezoneIso = tz.getID();
                wrapperObj.timezoneOffset = tz.getOffset(system.today());

            } else if(String.isNotBlank(contentRecord.Primary_Author__c)) {
                List<People__c> peopleList = [select id, User__r.TimezoneSidKey from People__c where id=:contentRecord.Primary_Author__c WITH SECURITY_ENFORCED];
                String timezoneSidKey = peopleList[0].User__r.TimezoneSidKey;
                TimeZone tz = Timezone.getTimeZone(timezoneSidKey);
                wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(timezoneSidKey);
                wrapperObj.timezoneIso = tz.getID();
                wrapperObj.timezoneOffset = tz.getOffset(system.today());
            }
            wrapperObj.startsAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Event_Start_DateTime__c);
            wrapperObj.endsAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Event_End_DateTime__c);
            wrapperObj.isMultiDay = contentRecord.Event_Start_DateTime__c.isSameDay(contentRecord.Event_End_DateTime__c) ? false : true;
            wrapperObj.hasRsvp = contentRecord.Event_RSVP_Allowed__c;

            wrapperObj.listOfOrganizers = new List<PeopleListWrapper>();

            String collaboratorJsonStr = contentHistoryList[0].Collaborator_Json__c;

            List<Object> collaboratorList = (List<Object>) JSON.deserializeUntyped(collaboratorJsonStr);

            List<String> collabIdList = new List<String>(); 
            for(Object obj : collaboratorList){
                Map<String, Object> collaboratorMap = (Map<String, Object>) obj;

                collabIdList.add((String) collaboratorMap.get('Collaborator__c'));
            }

            if(!collabIdList.isEmpty()){
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', collabIdList);
                String collaboratorQuery = 'SELECT Id, Collaborator__c, Collaborator__r.User__c, Collaborator__r.Full_Name__c, ' +
                    ' Collaborator__r.User__r.FullPhotoUrl, Collaborator__r.title__c, ' +
                    ' Collaborator__r.city__c, Collaborator__r.state__c, Collaborator__r.country__c, ' +
                    ' Collaborator__r.Department__c, Collaborator__r.User__r.IsActive  ' +
                    ' FROM Content_Collaborator__c WHERE Id IN :soqlParam1';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<Content_Collaborator__c> contCollabList = (List<Content_Collaborator__c>)SIMPESAPI.accessController().queryAsUser(collaboratorQuery, soqlParamMap);
                for (Content_Collaborator__c contentCollaborator : contCollabList) {
                    PeopleListWrapper organizer = new PeopleListWrapper();
                    organizer.id = contentCollaborator.id;
                    organizer.peopleId = contentCollaborator.Collaborator__c;
                    organizer.sfUserId = contentCollaborator.Collaborator__r.User__c;
                    organizer.name = contentCollaborator.Collaborator__r.Full_Name__c;
                    organizer.img = Utility.getProfilePhotoURL(contentCollaborator.Collaborator__r.User__r.FullPhotoUrl);
                    organizer.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentCollaborator.Collaborator__c;
                    organizer.title = SimpplrContext.isPPTitleDisplay ? contentCollaborator.Collaborator__r.title__c : null;
                    organizer.location = Utility.buildLocation(contentCollaborator.Collaborator__r.city__c,contentCollaborator.Collaborator__r.state__c,contentCollaborator.Collaborator__r.country__c);
                    organizer.isFollowing = UserContext.usersIFollowIdSet.contains(organizer.sfUserId);
                    organizer.department = SimpplrContext.isPPDepartmentDisplay ? 
                            contentCollaborator.Collaborator__r.Department__c : null;
                    organizer.isActive = contentCollaborator.Collaborator__r.User__r.IsActive;
    
                    wrapperObj.listOfOrganizers.add(organizer);
                }
            }

            if (contentRecord.Event_Directions_Enabled__c && 
                    string.isNotBlank(contentRecord.Event_Directions__c)) {
                    wrapperObj.directions = (List<String>)JSON.deserialize(contentRecord.Event_Directions__c, List<String>.class);
            }
            
            if (contentRecord.Event_RSVP_Allowed__c) {
                wrapperObj.rsvp = new ContentWrapper.RsvpWrapper();
                wrapperObj.rsvp.hasMaybeOption = contentRecord.Event_RSVP_Show_Maybe__c;
                wrapperObj.rsvp.noteLabel = contentRecord.Event_RSVP_Note__c ;
                wrapperObj.rsvp.capacityCount = Integer.valueOf(contentRecord.Event_RSVP_Limit__c);
                wrapperObj.rsvp.attendingCount = contentRecord.Event_Attending_Count__c != null && 
                        contentRecord.Event_Attending_Count__c > 0 ? 
                        Integer.valueOf(contentRecord.Event_Attending_Count__c) : null;
                wrapperObj.rsvp.dueAtDate = Utility.dateTimeToMomentJSDateTime(contentRecord.Event_RSVP_By_DateTime__c);
                wrapperObj.rsvp.reportUrl = PageContext.getPageURL(Pages.Reports) + 
                        '?contentId=' + contentRecord.id + '&action=getRsvpList';
                wrapperObj.rsvp.canDownloadReport = true;
                wrapperObj.rsvp.isExpired = contentRecord.Event_RSVP_By_DateTime__c < System.now() ? true : false;
                
                if (contentRecord.Event_RSVP_Responses__r.isEmpty() == false) {
                    Event_RSVP_Response__c rsvpResponse = contentRecord.Event_RSVP_Responses__r[0];
                    wrapperObj.rsvp.noteValue = rsvpResponse.RSVP_Response_Text__c;
                    wrapperObj.rsvp.respondedWith = rsvpResponse.RSVP_Response__c.toLowerCase();
                }

            }

			wrapperObj.listOfTopics = String.isNotBlank(contentHistoryList[0].Topic_Json__c) ? convertToListOfTopicWrapper(contentHistoryList[0].Topic_Json__c) : null;
            
			if(String.isNotBlank(contentHistoryList[0].File_Json__c)){

                String fileJsonStr = contentDao.mergeContentHistoryJsonStrings(contentHistoryList[0], 'file');
				String unescapedFileJsonStr = fileJsonStr.unescapeUnicode();
				List<File__c> fileList;
			
				try{
					fileList = (List<File__c>) JSON.deserialize(unescapedFileJsonStr, Type.forName('List<File__c>'));
				}catch(Exception e) {           
					fileList = (List<File__c>) JSON.deserialize(fileJsonStr, Type.forName('List<File__c>'));
				}

                for (File__c fileObj : fileList) {
					
					if (ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
							fileObj.Is_Title_Image__c) {
						wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj);
					
					} else if (ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
							fileObj.Is_Title_Image__c) {
						wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						wrapperObj.imgLandscapeFile = convertFileToFileContentWrapper(fileObj);
						
					} else if (ServiceConstants.TITLE_IMAGE_TYPE_ORIGINAL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
							fileObj.Is_Title_Image__c) {
						wrapperObj.imgOriginal = Utility.getFileDownloadURL(fileObj.Content_Version__c);
						wrapperObj.imgOriginalFile = convertFileToFileContentWrapper(fileObj);
					
					} else if (ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(fileObj.Location__c)) {
						wrapperObj.listOfFiles.add(convertFileToFileContentWrapper(fileObj));
					
                    }else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
                        wrapperObj.listOfInlineVideos.add(convertFileToFileContentWrapper(fileObj));
                    
                    } else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
						wrapperObj.listOfInlineImages.add(convertFileToFileContentWrapper(fileObj));
                    
                    }
		
				}
			}

		}	

		return wrapperObj;
    }
    
    private List<Simpplr_Content__c> getEventById(String contentId){
        List<String> eventFieldList = new List<String>{
            'Last_Moved_DateTime__c',
            'Event_Location__c',
            'Event_Is_All_Day__c',
            'Event_Start_DateTime__c',
            'Event_End_DateTime__c',
            'Event_RSVP_Allowed__c',
            'Event_RSVP_Show_Maybe__c',
            'Event_RSVP_Note__c',
            'Event_RSVP_Limit__c',
            'Event_RSVP_By_DateTime__c',
            'Event_Directions_Enabled__c',
            'Event_Map_URL__c',
            'Event_Directions__c',
            'Event_Attending_Count__c',
            'Event_TimezoneSidKey__c',
            '(Select Id,Rsvp_Response__c,RSVP_Response_Text__c from Event_RSVP_Responses__r where is_deleted__c = false And People__c=:loggedInPeopleId)',
            '(select Collaborator__c, Collaborator__r.Email__c, Collaborator__r.Full_Name__c, Collaborator__r.Title__c, Collaborator__r.User__c,Collaborator__r.Department__c, Collaborator__r.city__c, Collaborator__r.state__c, Collaborator__r.country__c, Collaborator__r.User__r.isactive, Collaborator__r.User__r.SmallPhotoUrl, Collaborator__r.User__r.FullPhotoUrl from Content_Collaborators_Simpplr_Content__r where Type__c=\'Organizer\' And Is_Deleted__C = false)'
        };

        eventFieldList.addAll(getContentDetailFieldList());												
        String query = 'SELECT '+String.join(eventFieldList,',')+' FROM Simpplr_Content__c where id=:contentId ';
        
        return Database.query(query);
    }
    @TestVisible    
    private ResponseWrapper getContent(String contentId) {
    	logger.logDebug('SiteAddEventDataServer.getContent()---data---' + contentId);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
    	String redirectUrl = null;
    	
    	try {
    		String content_LastModifiedTimeStamp = readParam(CONTENT_LASTMODIFIEDDATETIMESTAMP);
    		DateTime lastModifiedDateTimeStamp =  content_LastModifiedTimeStamp != null && 
                    content_LastModifiedTimeStamp != '0' ? 
                    DateTime.newInstance(long.valueOf(content_LastModifiedTimeStamp)) : null;
    		
    		if (String.valueOf(SimpplrContext.allowedFeatures).containsIgnoreCase(ServiceConstants.TYPE_EVENT) == false) {
    			throw new SimpplrException(ServiceConstants.ERROR_404);
    		}

    		List<Simpplr_Content__c> contentObjList = getEventById(contentId);
	    	
			if (contentObjList.size() == 0) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    
	    	} else if (contentObjList[0].Site__r.Show_In_Simpplr__c == false) {
	    		redirectUrl = SimpplrContext.salesforceBaseUrl + '/' + contentObjList[0].Site__r.Chatter_Group_Id__c;
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
	    
	    	} else if (lastModifiedDateTimeStamp != null && 
                    contentObjList[0].Last_Updated_DateTime__c == lastModifiedDateTimeStamp) {
			    resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Content data Not changed!', null);

	    	} else if (contentObjList[0].Is_Deleted__c || 
                    (contentObjList[0].Activated_By_Feature__c == false) || 
                    (contentObjList[0].Site__r.Is_Active__c == false)) {
	    		throw new SimpplrException(ServiceConstants.ERROR_404);
    		
    		} else if (AccessManager.calculateContentViewAccess(contentObjList[0].Type__c, contentObjList[0].Is_Published__c, contentObjList[0].Site__c, contentObjList[0].Site__r.Site_Type__c, contentObjList[0].Status__c, contentObjList[0].Primary_Author__r.User__c)) {
                ContentWrapper wrapperObj = convertToContentWrapper(contentObjList[0]);
                SiteDao siteDaoObj = new siteDao();
				CollaborationGroup collaborationGroupObj = siteDaoObj.getChatterGroupDetails(contentObjList[0].Site__r.Chatter_Group_Id__c);
				wrapperObj.site.isBroadcast = collaborationGroupObj?.IsBroadcast;
			
			if ('mobile'.equalsIgnoreCase(readParam('origin'))) {
				wrapperObj.isFeedEnabled = SimpplrContext.isCommentsAllowed && contentObjList[0].Site__r.Allow_Comments__c && wrapperObj.isFeedEnabled;
        		if(String.isNotBlank(wrapperObj.body) && wrapperObj.body.containsIgnoreCase('<iframe') ){
                    wrapperObj.body = Utility.getUpdatedMobileWapperBody(wrapperObj.body);
                }
                Utility.insertMobileAnalyticsRecord('EventDetail', 
                        new Map<String,String>{
                        'siteId'=>wrapperObj.site.siteId,
                        'contentId'=>contentId, 
                        'userAgent'=>readHeader('User-Agent')
                        });
            }
                
			resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
		
        } else {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		
		}
			
    	} catch (exception e){
    		logger.logError('Exception Details', e);
        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);

        	if (String.isNotBlank(redirectUrl)) {
        		resultWrapper.redirectUrl = redirectUrl;
        	}

        }
        return resultWrapper;
    }
    
    @testVisible 
    private ContentWrapper convertToContentWrapper (Simpplr_Content__c contentRecord) {
    	Set<Id> sitesIManageIdSet = UserContext.sitesIManageIdSet;
		ContentWrapper wrapperObj = new ContentWrapper();
        wrapperObj.id = contentRecord.id;
		wrapperObj.isLatest = true;
		wrapperObj.versionId = contentRecord.Version__c;
        wrapperObj.contentId = contentRecord.id;
        wrapperObj.contentBodyUrl = PageContext.getPageURL(Pages.ContentBody)+'?contentId='+contentRecord.id;
        wrapperObj.title = Utility.getAllValidWords(contentRecord.Title__c, contentRecord.Title__c.length(), false);
        wrapperObj.type	= contentRecord.Type__c.toLowerCase();
       	wrapperObj.excerpt = String.isBlank(contentRecord.Display_Excerpt__c)?'':contentRecord.Display_Excerpt__c.unescapeHtml4();
		wrapperObj.summary = String.isBlank(contentRecord.Summary_1__c)?'':contentRecord.Summary_1__c.unescapeHtml4();
        wrapperObj.isPublished = contentRecord.Is_Published__c;
        wrapperObj.status = getContentStatus(contentRecord.Status__c, contentRecord.Is_Published__c);
        wrapperObj.isScheduled = checkIfContentScheduled(wrapperObj.status, contentRecord.Publish_Start_DateTime__c);
        wrapperObj.isFeedEnabled = contentRecord.Allow_comments__c;
        wrapperObj.imgLayout = contentRecord.Cover_Image_Layout__c;
        wrapperObj.lastMovedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Moved_DateTime__c);

        Map<Id, Site_Role__c> mapofSiteIdAndSiteRole = new Map<Id, Site_Role__c>();
        mapofSiteIdAndSiteRole = UserContext.mySiteRolesMap;
        if (contentRecord.Must_Read_Audits__r != null && contentRecord.Must_Read_Audits__r.isEmpty() == false) {
			List<Must_Read_Audit__c> mustReadAudList = contentRecord.Must_Read_Audits__r;

			if (( mustReadAudList[0].Expiry_DateTime__c == null || 
                    mustReadAudList[0].Expiry_DateTime__c > DateTime.now()) && 
                    mustReadAudList[0].Removed_DateTime__c == null) {
				//wrapperObj.isMustRead 		= true;
            
				if(mustReadAudList[0].Audience_Type__c == 'site_members') {
					Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentRecord.Site__c);
					if(siteRoleForContentSite != null && siteRoleForContentSite.Is_Member__c == true) {
						wrapperObj.isMustRead = true;
					} else {
						wrapperObj.isMustRead = false;
					}
				} else {
					wrapperObj.isMustRead = true;
                }
                
            } else {
				wrapperObj.isMustRead 		= false;
			}

			wrapperObj.MustReadDetails = getMustReadDetails(mustReadAudList[0]);
            Map<String,Integer> contentIdToAudienceCountMap = new Map<String,Integer>();
			contentIdToAudienceCountMap = new ManageContentDao().getContentIdToAudienceCountMap(new List<Simpplr_Content__c>{contentRecord});
			if(contentIdToAudienceCountMap != null) {
				wrapperObj.mustReadDetails.audienceCount = contentIdToAudienceCountMap.get(contentRecord.id) != null ?contentIdToAudienceCountMap.get(contentRecord.id) : 0;
			}

		} else {
			wrapperObj.isMustRead 		= false;
			wrapperObj.MustReadDetails = null;
		}

        wrapperObj.imgCaption = contentRecord.Title_Image_Caption__c;
        wrapperObj.isLiked = contentRecord.Likes_Simpplr_Content__r.isEmpty() ? false : true;
        wrapperObj.likeCount = Integer.valueOf(contentRecord.Likes__c);
        wrapperObj.postCount = contentRecord.Feed_Posts__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Posts__c);
        wrapperObj.questionCount = contentRecord.Feed_Questions__c == null ? 0 : Integer.valueOf(contentRecord.Feed_Questions__c);
        wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+contentRecord.site__c+'/event/'+contentRecord.Id;
        wrapperObj.editUrl = wrapperObj.url + '/edit';
        if(String.isNotBlank(contentRecord.Text_Json__c)) {
            String bodyJsonData = getMergedBodyJson(contentRecord.Text_Json__c, contentRecord.Text_Main_Json__c, contentRecord.Text_Main_Continued_Json__c );
            wrapperObj.bodyJson = (TipTapBodyWrapper)JSON.deserialize(bodyJsonData, TipTapBodyWrapper.class);
        } 
        wrapperObj.body = (String.isNotBlank(contentRecord.Text_Intro__c) ? 
                contentRecord.Text_Intro__c : '') +
                (String.isNotBlank(contentRecord.Text_Main__c) ? contentRecord.Text_Main__c : '') +
                (String.isNotBlank(contentRecord.Text_Main_Continued__c) ? 
                contentRecord.Text_Main_Continued__c : '');
        wrapperObj.isFavorited = !contentRecord.Bookmarked_Content__r.isEmpty();
        wrapperObj.isOpenToNotification = !contentRecord.Content_Notification_Setting__r.isEmpty();
        wrapperObj.favoriteContext = contentRecord.Type__c;
        wrapperObj.site = New SiteLiteWrapper();
        wrapperObj.site.siteId = contentRecord.Site__c;
        wrapperObj.site.name = contentRecord.Site__r.name;
        wrapperObj.site.img = String.isBlank(contentRecord.Site__r.Title_Content_Version__c) ? 
                null : Utility.getFileDownloadURLFor720By480(contentRecord.Site__r.Title_Content_Version__c);
        wrapperObj.site.imgThumbnail = String.isBlank(contentRecord.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(contentRecord.Site__r.Title_Content_Version__c);
        wrapperObj.site.url = PageContext.getPageURL(Pages.app) + '?u=/site/' + contentRecord.Site__c + '/' + contentRecord.Site__r.Landing_Page__c;
        wrapperObj.site.access = contentRecord.Site__r.Site_Type__c;
        wrapperObj.site.isActive = contentRecord.site__r.Is_Active__c;
        wrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
        wrapperObj.site.isPublic = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
        if(SimpplrContext.isSegmentsEnabled){
			String segmentId = String.isBlank(UserContext.SegmentId) ? '' : UserContext.SegmentId;
			if(String.isNotBlank(segmentId)) {
				List<Segment_Site__c> segList = [SELECT id, Is_Featured__c from Segment_Site__c where site__c =: contentRecord.Site__c and segment__c =:segmentId WITH SECURITY_ENFORCED limit 1];
				wrapperObj.site.isFeatured = segList.size()>0 ? segList[0].Is_Featured__c : false;
			} else {
				wrapperObj.site.isFeatured = false;
			}
		} else {
			wrapperObj.site.isFeatured = contentRecord.Site__r.Is_Featured__c;
		}
        wrapperObj.site.isMember = false;
		wrapperObj.site.isFollower = false;
		if(mapofSiteIdAndSiteRole.containsKey(contentRecord.Site__c)) {
            Site_Role__c siteRoleForContentSite = mapofSiteIdAndSiteRole.get(contentRecord.Site__c);
                if(siteRoleForContentSite.Is_Member__c == true) {
                    wrapperObj.site.isMember = true;
                    wrapperObj.site.isFollower = false;
                } else {
                    wrapperObj.site.isMember = false;
                    wrapperObj.site.isFollower = true;
                }
		}
        if(UserContext.sitesIManageIdSet.contains(contentRecord.Site__c) || UserContext.sitesIManageContentsIdSet.contains(contentRecord.Site__c)) {
			if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_ALL_SITES.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
				wrapperObj.site.canUploadAllFileTypes =  true;
			} else if (ServiceConstants.ALLOW_FILE_UPLOAD_AS_All_USER.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)) {
				wrapperObj.site.canUploadAllFileTypes =  false;
			} else if (ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE.equalsIgnoreCase(SimpplrContext.appConfig.Allow_File_Upload_Site_Managers__c)){
				wrapperObj.site.canUploadAllFileTypes = contentRecord.site__r.Allow_File_Upload_App_Permission__c;
			}
		}else{
			wrapperObj.site.canUploadAllFileTypes = false;
		}
        wrapperObj.site.isManager = UserContext.sitesIManageIdSet.contains(contentRecord.Site__c);
        wrapperObj.site.isContentManager = UserContext.sitesIManageContentsIdSet.contains(contentRecord.Site__c);
        wrapperObj.site.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(contentRecord.Site__r.Site_Type__c);
        wrapperObj.site.chatterGroupId = contentRecord.Site__r.Chatter_Group_Id__c;
        wrapperObj.site.isContentUnfurlEnabled = contentRecord.Site__r.Is_Content_Unfurl_Enabled__c;
        wrapperObj.isQuestionAnswerEnabled = SimpplrContext.isQuestionAnswerEnabled && contentRecord.Site__r.Question_Answer_Enabled__c == true && contentRecord.Question_Answer_Enabled__c == true;
        wrapperObj.hasRead = !contentRecord.Must_Read_Confirm_History__r.isEmpty();
        wrapperObj.readAt = wrapperObj.hasRead ? 
                Utility.dateTimeToMomentJSDateTime(contentRecord.Must_Read_Confirm_History__r[0].Confirm_DateTime__c) : null;
        wrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Last_Updated_DateTime__c);
		wrapperObj.publishAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_Start_DateTime__c);
		wrapperObj.publishTo = Utility.dateTimeToMomentJSDateTime(contentRecord.Publish_End_DateTime__c);
		wrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Created_DateTime__c);
		wrapperObj.lastModifiedDateTimeStamp = contentRecord.Last_Updated_DateTime__c != null ? 
                contentRecord.Last_Updated_DateTime__c.getTime() : 0;
        wrapperObj.firstPublishedAt = contentRecord.First_Publish_DateTime__c  != null ? 
                Utility.dateTimeToMomentJSDateTime(contentRecord.First_Publish_DateTime__c) : null;
		App_Config__c appConfigObj = SimpplrContext.appConfig;
        String baseURL = 'https://outlook.office365.com';
        if(String.isNotBlank(appConfigObj.Calendar_Office365_URL__c)){
            baseURL = appConfigObj.Calendar_Office365_URL__c;
        }
        CalendarUtility utilityObj = new CalendarUtility();
        wrapperObj.googleCalendarWebUrl = appConfigObj.Calendar_Google_Enabled__c ? 
                utilityObj.getGoogleCalendarWebUrl(contentRecord) : '';
        wrapperObj.outlookWebUrl = appConfigObj.Calendar_Outlook_Web_Enabled__c ? 
                utilityObj.getOutlookWebUrl(contentRecord) : '';
        wrapperObj.icsDownloadUrl = appConfigObj.Calendar_App_Enabled__c ? 
                utilityObj.getIcsDownloadUrl(contentRecord) : '';
    	wrapperObj.office365WebUrl = appConfigObj.Calendar_Office365_Enabled__c ? 
                utilityObj.getOffice365WebUrl(contentRecord,baseURL) : '';
        wrapperObj.location = contentRecord.Event_Location__c;
        wrapperObj.hasDirections = contentRecord.Event_Directions_Enabled__c;
        wrapperObj.mapUrl = contentRecord.Event_Map_URL__c;
        wrapperObj.isAllDay = contentRecord.Event_Is_All_Day__c;
                
        TimeZone tz = Timezone.getTimeZone(contentRecord.Event_TimezoneSidKey__c);
        wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(contentRecord.Event_TimezoneSidKey__c);
        wrapperObj.timezoneIso = tz.getID();
        wrapperObj.timezoneOffset = tz.getOffset(system.today());

    	wrapperObj.startsAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Event_Start_DateTime__c);
    	wrapperObj.endsAt = Utility.dateTimeToMomentJSDateTime(contentRecord.Event_End_DateTime__c);
    	wrapperObj.isMultiDay = contentRecord.Event_Start_DateTime__c.isSameDay(contentRecord.Event_End_DateTime__c) ? false : true;
		wrapperObj.hasRsvp = contentRecord.Event_RSVP_Allowed__c;
        Set<Id>	setOfMyFavouritePeopleId = UserContext.setOfMyFavouritePeopleId;
        Boolean isCurrentUserEventOrganizer = false;
        wrapperObj.listOfOrganizers = new List<PeopleListWrapper>();

        for (Content_Collaborator__c contentCollaborator : contentRecord.Content_Collaborators_Simpplr_Content__r) {
            PeopleListWrapper organizer = new PeopleListWrapper();
            organizer.id = contentCollaborator.id;
            organizer.peopleId = contentCollaborator.Collaborator__c;
            organizer.sfUserId = contentCollaborator.Collaborator__r.User__c;
	        organizer.name = contentCollaborator.Collaborator__r.Full_Name__c;
	        organizer.img = Utility.getProfilePhotoURL(contentCollaborator.Collaborator__r.User__r.FullPhotoUrl);
	        organizer.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentCollaborator.Collaborator__c;
            organizer.title = SimpplrContext.isPPTitleDisplay ? contentCollaborator.Collaborator__r.title__c : null;
		    organizer.location = Utility.buildLocation(contentCollaborator.Collaborator__r.city__c,contentCollaborator.Collaborator__r.state__c,contentCollaborator.Collaborator__r.country__c);
	        organizer.isFollowing = UserContext.usersIFollowIdSet.contains(organizer.sfUserId);
            organizer.department = SimpplrContext.isPPDepartmentDisplay ? 
                    contentCollaborator.Collaborator__r.Department__c : null;

            if (UserContext.peopleId == organizer.peopleId) {
                isCurrentUserEventOrganizer = true;
				organizer.canFollow = false;
				organizer.isFavorited = false;
			
			} else {
				organizer.canFollow = contentCollaborator.Collaborator__r.User__r.IsActive;
				organizer.isFavorited = setOfMyFavouritePeopleId.contains(contentCollaborator.Collaborator__c);
				
			}

			organizer.isActive = contentCollaborator.Collaborator__r.User__r.IsActive;
            wrapperObj.listOfOrganizers.add(organizer);
        }
    	
        if (contentRecord.Event_Directions_Enabled__c && 
                string.isNotBlank(contentRecord.Event_Directions__c)) {
	        	wrapperObj.directions = new List<String>();
	        	wrapperObj.directions = (List<String>)JSON.deserialize(contentRecord.Event_Directions__c, List<String>.class);
        }
        
        if (contentRecord.Event_RSVP_Allowed__c) {
        	wrapperObj.rsvp = new ContentWrapper.RsvpWrapper();
            wrapperObj.rsvp.hasMaybeOption = contentRecord.Event_RSVP_Show_Maybe__c;
            wrapperObj.rsvp.noteLabel = contentRecord.Event_RSVP_Note__c ;
            wrapperObj.rsvp.capacityCount = Integer.valueOf(contentRecord.Event_RSVP_Limit__c);
            wrapperObj.rsvp.attendingCount = contentRecord.Event_Attending_Count__c != null && 
                    contentRecord.Event_Attending_Count__c > 0 ? 
        			Integer.valueOf(contentRecord.Event_Attending_Count__c) : null;
            wrapperObj.rsvp.dueAtDate = Utility.dateTimeToMomentJSDateTime(contentRecord.Event_RSVP_By_DateTime__c);
		    wrapperObj.rsvp.reportUrl = PageContext.getPageURL(Pages.Reports) + 
                    '?contentId=' + contentRecord.id + '&action=getRsvpList';
		    wrapperObj.rsvp.canDownloadReport = isCurrentUserEventOrganizer || 
                    AccessManager.hasContentApprovalAccess(wrapperObj.site.siteId, 
                    wrapperObj.site.isPublic);
		    wrapperObj.rsvp.isExpired = contentRecord.Event_RSVP_By_DateTime__c < System.now() ? true : false;
            
            wrapperObj.rsvp.isRemovedFromAttendeeList = false;
            wrapperObj.rsvp.removedFromAttendeeListMessage = '';
	        if (contentRecord.Event_RSVP_Responses__r.isEmpty() == false) {
                Event_RSVP_Response__c rsvpResponse = contentRecord.Event_RSVP_Responses__r[0];
                wrapperObj.rsvp.noteValue = rsvpResponse.RSVP_Response_Text__c;
                wrapperObj.rsvp.respondedWith = rsvpResponse.RSVP_Response__c.toLowerCase();
                
            } else {
                // Check if logged in user was removed from this event's attendee list
                // Pick the latest one 
                List<App_Notification__c> appNotificationList = [SELECT Id, Submitter_Comment__c FROM App_Notification__c WHERE
                        Object_Id__c = :wrapperObj.id AND Object_Type__c = 'Event' AND
                        Is_Deleted__c = false AND Category__c = 'RSVP_Removed' AND
                        Sent_to__c =: UserContext.getCurrentUserInfo.Id WITH SECURITY_ENFORCED ORDER BY createddate DESC LIMIT 1];
                if(!appNotificationList.isEmpty()){
                    wrapperObj.rsvp.isRemovedFromAttendeeList = true;
                    wrapperObj.rsvp.removedFromAttendeeListMessage = appNotificationList[0].Submitter_Comment__c;

                }
            }
        }

        wrapperObj.authoredBy.Id = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.sfUserId = contentRecord.Primary_Author__r.User__c;
        wrapperObj.authoredBy.peopleId = contentRecord.Primary_Author__c;
        wrapperObj.authoredBy.name = contentRecord.Primary_Author__r.Full_Name__c;
        wrapperObj.authoredBy.img = Utility.getProfilePhotoURL(contentRecord.Primary_Author__r.User__r.FullPhotoUrl);
        wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + contentRecord.Primary_Author__c;
    	wrapperObj.authoredBy.title = SimpplrContext.isPPTitleDisplay ? contentRecord.Primary_Author__r.title__c : null;
	    wrapperObj.authoredBy.location = Utility.buildLocation(contentRecord.Primary_Author__r.city__c,contentRecord.Primary_Author__r.state__c,contentRecord.Primary_Author__r.country__c);
        wrapperObj.authoredBy.isFollowing = UserContext.usersIFollowIdSet.contains(wrapperObj.authoredBy.sfUserId);
    	wrapperObj.authoredBy.department = SimpplrContext.isPPDepartmentDisplay ? contentRecord.Primary_Author__r.Department__c : null;
    	wrapperObj.authoredBy.isFavorited = setOfMyFavouritePeopleId.contains(contentRecord.Primary_Author__c);
    	wrapperObj.authoredBy.canFollow = UserContext.peopleId.equalsIgnoreCase(wrapperObj.authoredBy.peopleId) ?  false : contentRecord.Primary_Author__r.User__r.isActive;
    	wrapperObj.authoredBy.mediumPhotoUrl = Utility.getUserProfileImgUrl(contentRecord.Primary_Author__r.User__r.MediumPhotoURL, contentRecord.Primary_Author__r.User__r.FullPhotoURL);
    	wrapperObj.authoredBy.street = contentRecord.Primary_Author__r.Street__c;
    	wrapperObj.authoredBy.city = contentRecord.Primary_Author__r.City__c;
		wrapperObj.authoredBy.state = contentRecord.Primary_Author__r.State__c;
    	wrapperObj.authoredBy.country = contentRecord.Primary_Author__r.Country__c;
    	wrapperObj.authoredBy.email = contentRecord.Primary_Author__r.Email__c;
    	wrapperObj.authoredBy.mobile = contentRecord.Primary_Author__r.Mobile_Phone__c;
    	wrapperObj.authoredBy.phone = contentRecord.Primary_Author__r.Phone__c;
    	wrapperObj.authoredBy.phoneExtension = contentRecord.Primary_Author__r.Extension__c;
    	wrapperObj.authoredBy.firstName = contentRecord.Primary_Author__r.First_Name__c;
		wrapperObj.authoredBy.lastName = contentRecord.Primary_Author__r.Last_Name__c;
		wrapperObj.authoredBy.isActive = contentRecord.Primary_Author__r.User__r.IsActive;
        wrapperObj.canPublishUnpublish = AccessManager.calculatePublishUnpublishAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
				wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canModerate = AccessManager.calculateModerateAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
        	    wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canDelete = AccessManager.calculateDeleteAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
        		wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canEdit 	= AccessManager.calculateEditAccess(wrapperObj.site.isManager, wrapperObj.site.isContentManager,
        		wrapperObj.status, wrapperObj.authoredBy.sfUserId, wrapperObj.site.access);
        wrapperObj.canSendUpdateNotification = wrapperObj.canEdit;		
        wrapperObj.canMakeMustRead = AccessManager.calculateCanMakeMustRead(wrapperObj.type, wrapperObj.isPublished, wrapperObj.site.access, 
                contentRecord.Site__r.Is_Must_Read_Enabled__c, wrapperObj.site.isManager, wrapperObj.site.isContentManager);							  
        if(SimpplrContext.isFeatureContentOnboardingEnabled) {
            wrapperObj.canManageOnboardingContent = AccessManager.calculateCanManageOnboarding(wrapperObj.isPublished, contentRecord.Site__c, contentRecord.Site__r.Is_Onboarding_Enabled__c, wrapperObj.site.isFeatured);
            wrapperObj.onboardingStatus = contentRecord.Content_Onboarding_Status__c;
        } else {
            wrapperObj.canManageOnboardingContent = false;
            wrapperObj.onboardingStatus = ServiceConstants.CONTENT_STATUS_NOT_ONBOARDING;
        }
        wrapperObj.usefulContent.canViewHistory = wrapperObj.canPublishUnpublish;

	    if (contentRecord.Simpplr_Content_Feedback__r.isEmpty()) {
	    		wrapperObj.usefulContent.hasUserRated		= false;
	    
        } else {
	    		wrapperObj.usefulContent.hasUserRated		= true;
	    		wrapperObj.usefulContent.hasUserRatedUseful	= contentRecord.Simpplr_Content_Feedback__r[0].Was_Content_Useful__c;
	    }
        
		wrapperObj.listOfTopics = convertToListOfTopicWrapper(contentRecord.Id, 
                PageContext.getPageURL(Pages.app));
		wrapperObj.recentViewCount = getViewCountInLast30Days(contentRecord.Id);
		List<File__c> fileList = getFilesByContentId(contentRecord.Id);

		for (File__c fileObj : fileList) {
			
            if (ServiceConstants.TITLE_IMAGE_TYPE_THUMBNAIL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
                    fileObj.Is_Title_Image__c){
				wrapperObj.img = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			wrapperObj.imgFile = convertFileToFileContentWrapper(fileObj);
    		
    		} else if (ServiceConstants.TITLE_IMAGE_TYPE_WIDESCREEN.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
                    fileObj.Is_Title_Image__c){
    			wrapperObj.imgLandscape = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			wrapperObj.imgLandscapeFile = convertFileToFileContentWrapper(fileObj);
    			
    		} else if (ServiceConstants.TITLE_IMAGE_TYPE_ORIGINAL.equalsIgnoreCase(fileObj.Title_Image_Type__c) && 
                    fileObj.Is_Title_Image__c) {
    			wrapperObj.imgOriginal = Utility.getFileDownloadURL(fileObj.Content_Version__c);
    			wrapperObj.imgOriginalFile = convertFileToFileContentWrapper(fileObj);
    		
    		} else if (ServiceConstants.FILE_LOCATION_ATTACHMENT.equalsIgnoreCase(fileObj.Location__c)) {
    			wrapperObj.listOfFiles.add(convertFileToFileContentWrapper(fileObj));
    		
            } else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileObj.Repository__c)) {
    			wrapperObj.listOfInlineVideos.add(convertFileToFileContentWrapper(fileObj));
            
            } else if (ServiceConstants.FILE_LOCATION_INLINE.equalsIgnoreCase(fileObj.Location__c)) {
    			wrapperObj.listOfInlineImages.add(convertFileToFileContentWrapper(fileObj));
  
            }
    	}
        
        wrapperObj.isInHomeCarousel = false;
        wrapperObj.isInSiteCarousel = false;
        wrapperObj.addedToSegmentCarouselList = new List<ContentWrapper.SegmentWrapper>();

		if (contentRecord.Is_Published__c) {
			
            for (Carousel_Content__c carouselObj : contentRecord.Simpplr_Carousel_Contents__r) {
				
                if (String.isNotBlank(carouselObj.Site__c)) {
					wrapperObj.isInSiteCarousel = true;
				
                } else {
					wrapperObj.isInHomeCarousel = true;
                }
                
                if (String.isNotBlank(carouselObj.Segment__c)) {
					ContentWrapper.SegmentWrapper segWrapObj = new ContentWrapper.SegmentWrapper();
					segWrapObj.segmentId = carouselObj.Segment__c;
					segWrapObj.segmentName = carouselObj.Segment__r.Name__c;
					wrapperObj.addedToSegmentCarouselList.add(segWrapObj);
				}

			}
        }
        
        wrapperObj.authoredBy.isProtectedAuthor = contentRecord.Primary_Author__r.Is_Protected_Author__c;
        if(ServiceConstants.CONTENT_STATUS_REJECTED.equalsIgnoreCase(wrapperObj.status)) {
			wrapperObj.rejectionDetails = getRejectionComment(wrapperObj.id);
		}

    	return wrapperObj;
    }
}