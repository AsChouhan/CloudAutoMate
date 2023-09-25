/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public without sharing class BatchNotificationsOnContentUpdate implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
  
    public String packageName = SimpplrContext.packageName;
    Simpplr_Content__c contentObj = null;
    List<Simpplr_Content__c> contentList = new List<Simpplr_Content__c>();
    List<People_Preference__c> peoplePreList;
    String contentObjId;
    public Integer batchNumber = 1;
    String message;
    String guid;
    String cgId = '';
    private Exception exceptionDetailsObj;
	private String contentId;
    private String eventAction;
    private Boolean sendInAppNotification = true;
    private Boolean sendEmailNotification = true;
    private String batchType;
    private DateTime conditionDateTime;
    
    /**
    * 
    * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
    * Parameters:
    * parameter_name -- [Explanation of the purpose of this parameter to the method.
    *      
    * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    public BatchNotificationsOnContentUpdate(String contentId) {
    }

    public BatchNotificationsOnContentUpdate(String contentId, String message) {
        this.contentObjId = contentId;
        this.message = message;
        List<Simpplr_Content__c> simContentList = [select id, Is_Published__c,Is_Deleted__c, title__c,type__c,site__c,Site__r.Site_type__c, Site__r.Chatter_Group_Id__c, Primary_Author__c,Display_Excerpt__c, Site__r.Name,Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c from simpplr_content__c where id=:contentId limit 1];
        if(!simContentList.isEmpty()) {
            contentObj = simContentList[0];
            cgId = contentObj.Site__r.Chatter_Group_Id__c;
            if(contentObj.Is_Deleted__c == true) {
                throw new SimpplrException('Could not perform action - Content has been deleted');
            }
            if(contentObj.Is_Published__c == false) {
                throw new SimpplrException('You can send update notifications for Published Contents only');
            }
        }
    }

    public BatchNotificationsOnContentUpdate(String contentId, String message, String batchType, String memberType) {
        this.contentObjId = contentId;
        this.message = message;
        this.batchType = batchType;
        List<Simpplr_Content__c> simContentList = [select id, Is_Published__c,Is_Deleted__c, title__c,type__c,site__c,Site__r.Site_type__c, Site__r.Chatter_Group_Id__c, Primary_Author__c,Display_Excerpt__c, Site__r.Name,Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__r.Full_Name__c from simpplr_content__c where id=:contentId limit 1];
        if(!simContentList.isEmpty()) {
            contentObj = simContentList[0];
            cgId = contentObj.Site__r.Chatter_Group_Id__c;
            if(contentObj.Is_Deleted__c == true) {
                throw new SimpplrException('Could not perform action - Content has been deleted');
            }
            if(contentObj.Is_Published__c == false) {
                throw new SimpplrException('You can send update notifications for Published Contents only');
            }
        }
    }

    /**
     * @description BatchNotificationsOnContentUpdate constructore
     * @param batchType
     * @param contentIdOrGuid
     * @param eventAction
     */
	public BatchNotificationsOnContentUpdate(String batchType, String contentIdOrGuid, String eventAction) {
		this.batchType = batchType;
        if('sendPushNotificationBatch'.equalsIgnoreCase(batchType)) {
            this.guid = contentIdOrGuid;
        } else {
		    this.contentId = contentIdOrGuid;
        }
		this.eventAction = eventAction;
    	
    }

    public BatchNotificationsOnContentUpdate(String batchType, String contentId, String eventAction, Boolean sendInAppNotification, Boolean sendEmailNotification) {
		this.batchType = batchType;
		this.contentId = contentId;
        this.eventAction = eventAction;
        this.sendInAppNotification = sendInAppNotification;
        this.sendEmailNotification = sendEmailNotification;
    	
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    public database.querylocator start(Database.BatchableContext bc) {
        
        String query = '';
        String loggedInUserPeopleId = UserContext.peopleId;
        String typeEvent = ServiceConstants.TYPE_EVENT;

        if('sendEmailToAuthorOnEventAction'.equalsIgnoreCase(batchType)){
			query = 'SELECT Id, Primary_Author__r.User__r.languagelocalekey, Primary_Author__c '
					+ ' FROM Simpplr_Content__c ' 
                    + ' WHERE id = :contentId '
                    + ' AND Primary_Author__c != :loggedInUserPeopleId ';

		} else if('sendEmailToCollaboratorsOnEventAction'.equalsIgnoreCase(batchType)){
			query = 'SELECT Collaborator__c, Collaborator__r.User__r.languagelocalekey FROM Content_Collaborator__c '
					+ '	WHERE Is_Deleted__c = false AND Simpplr_Content__c = :contentId '
                    + ' AND Collaborator__c != :loggedInUserPeopleId ';

		} else if('sendEmailToRsvpYesUsersOnEventAction'.equalsIgnoreCase(batchType)){
			query = 'SELECT Id, People__r.User__r.languagelocalekey FROM Event_RSVP_Response__c WHERE '
					+ ' Content__c = :contentId AND Is_Deleted__c = false AND RSVP_Response__c = \'Yes\' '
                    + ' AND People__c != :loggedInUserPeopleId ';

		} else if('sendNotificationOnRSVPActionToAuthorAndOrganizer'.equalsIgnoreCase(batchType)){
            Date yesterdayDate = Date.today().addDays(-1);
            Time batchTime = Time.newInstance(17, 0, 0, 0); // 5 PM
            conditionDateTime = DateTime.newInstance(yesterdayDate, batchTime);

            query = 'SELECT Id, Event_Attending_Count__c, Site__c, Title__c, Site__r.Name, '
                    + ' Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c, '
                    + ' Primary_Author__r.First_Name__c, Last_Edited_DateTime__c, Type__c, Primary_Author__r.User__r.languagelocalekey, '
                    + ' Event_TimezoneSidKey__c, Event_Is_All_Day__c, Event_Start_Datetime__c, Event_End_DateTime__c, Event_Location__c, Publish_Start_DateTime__c, Primary_Author__c, '
                    + ' (SELECT Id, People__c, People__r.Full_Name__c FROM Event_RSVP_Responses__r '
                        + ' WHERE is_deleted__c = false '
                        + ' AND (createddate > :conditionDateTime OR lastmodifieddate > :conditionDateTime) '
                        + ' ORDER BY LastModifiedDate DESC LIMIT 2), '                                                      
                    + ' (SELECT Collaborator__c, Collaborator__r.User__r.languagelocalekey FROM Content_Collaborators_Simpplr_Content__r '
                        + ' WHERE Type__c = \'Organizer\' AND Is_Deleted__c = false) '
                    + ' FROM Simpplr_Content__c '
                    + ' WHERE '
                    + ' Site__r.Is_Deleted__c = false ' 
                    + ' AND Site__r.Is_Active__c = true '
                    + ' AND Site__r.Show_In_Simpplr__c = true '
                    + ' AND Is_Deleted__c = false '
                    + ' AND Type__c =:typeEvent '
                    + ' AND Id IN (SELECT Content__c FROM Event_RSVP_Response__c ' 
                                    + ' WHERE Is_Deleted__c = false '
                                    + ' AND (createddate > :conditionDateTime OR lastmodifieddate > :conditionDateTime)) '; 

        } else if('sendPushNotificationBatch'.equalsIgnoreCase(batchType)) {
            query = 'Select Id, Sent_By__c, GUID__c, Object_Id__c, content__c, Object_Type__c, Status__c, Type__c,'
                + ' Sub_Type__c, Is_Read__c, Is_New__c, category__c, Snippet__c, Sent_to__c, Simpplr_Site__c,'
                + ' Created_DateTime__c, Parent_Object_Id__c from App_Notification__c where GUID__c = :guid AND Is_Deleted__c = false';

        } else {
            //this part will call 'sendPushNotificationBatch' in finish method
            guid = createContentMessage();
            Set<String> userIdSet = new Set<String>();
            List<CollaborationGroupMember> cgmList = [SELECT MemberId FROM CollaborationGroupMember Where CollaborationGroupId =:cgId];
            for(CollaborationGroupMember cgm : cgmList){
                userIdSet.add(cgm.MemberId);
            }
            if('Public'.equalsIgnoreCase(contentObj.Site__r.Site_type__c)) {
                Set<User> allAppModertrWithContentModedrnOnSet = Utility.getAllAppModeratorsWithContentModedrnOn('appManagerUpdateNotification');
                for(User usr : allAppModertrWithContentModedrnOnSet){
                    userIdSet.add(usr.Id);
                }
            }

            if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false){
                query = 'Select id, SMS_Alerts__c, SMS_Content_Promotion_Message__c, People__r.Mobile_Phone__c, people__c, people__r.user__c, People__r.First_Name__c,People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, People__r.user__r.languagelocalekey, Email_Content_Submitted_for_Moderation__c,People__r.External_Photo_URL__c, Email_Updates_Content_Sites_I_Follow__c, People__r.External_Photo_URL_Expiry_Date__c, Email_Notification_Digest_Frequency__c, Allow_Simpplr_Emails__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.TimeZoneSidKey, User__r.languagelocalekey From People_Preference__c where people__r.User__r.IsActive=true and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName)';
            } else {
                query = 'Select id, SMS_Alerts__c, SMS_Content_Promotion_Message__c, People__r.Mobile_Phone__c, people__c, people__r.user__c, People__r.First_Name__c,People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, People__r.user__r.languagelocalekey, Email_Content_Submitted_for_Moderation__c,People__r.External_Photo_URL__c, Email_Updates_Content_Sites_I_Follow__c, People__r.External_Photo_URL_Expiry_Date__c, Email_Notification_Digest_Frequency__c, Allow_Simpplr_Emails__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.TimeZoneSidKey, User__r.languagelocalekey From People_Preference__c where people__r.User__r.IsActive=true';
            }
            query += ' and User__c  IN : userIdSet';

            if('sendNotificationToSiteMembers'.equalsIgnoreCase(batchType)) {
                query += ' AND people__c in (Select People__c FROM Site_Role__c WHERE Is_Member__c = true AND Is_Deleted__c = false AND (Site__r.Chatter_Group_Id__c=:cgId)) '; 
            }
        }

        return Database.getQueryLocator(query);
    }
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject) {
        try{
            if('sendEmailToAuthorOnEventAction'.equalsIgnoreCase(batchType)) {
                List<Simpplr_Content__c> contentList = (List<Simpplr_Content__c>)listOfsObject;
                Map<String, String> peopleIdVsLocaleMap = new Map<String, String>();
    
                String localeKey = Utility.getSimpplrLanguageLocaleKey(contentList[0].Primary_Author__r.User__r.languagelocalekey);
                peopleIdVsLocaleMap.put(contentList[0].Primary_Author__c, localeKey);
    
                sendEventActionEmail(peopleIdVsLocaleMap);
    
            } else if('sendEmailToCollaboratorsOnEventAction'.equalsIgnoreCase(batchType)) {
                List<Content_Collaborator__c> contentCollaboratorList = (List<Content_Collaborator__c>)listOfsObject;
                
                Map<String, String> peopleIdVsLocaleMap = new Map<String, String>();
                for(Content_Collaborator__c contentCollaborators : contentCollaboratorList){
                    String localeKey = Utility.getSimpplrLanguageLocaleKey(contentCollaborators.Collaborator__r.User__r.languagelocalekey);
    
                    peopleIdVsLocaleMap.put(contentCollaborators.Collaborator__c, localeKey);
                }
    
                sendEventActionEmail(peopleIdVsLocaleMap);
    
            } else if('sendEmailToRsvpYesUsersOnEventAction'.equalsIgnoreCase(batchType)) {
                List<Event_RSVP_Response__c> eventRsvpResponseList = (List<Event_RSVP_Response__c>)listOfsObject;
                
                Map<String, String> peopleIdVsLocaleMap = new Map<String, String>();
                for(Event_RSVP_Response__c rsvpResponse : eventRsvpResponseList){
                    String localeKey = Utility.getSimpplrLanguageLocaleKey(rsvpResponse.People__r.User__r.languagelocalekey);
    
                    peopleIdVsLocaleMap.put(rsvpResponse.People__c, localeKey);
                }
    
                sendEventActionEmail(peopleIdVsLocaleMap);
    
            } else if('sendNotificationOnRSVPActionToAuthorAndOrganizer'.equalsIgnoreCase(batchType)) {
                List<Simpplr_Content__c> contentList = (List<Simpplr_Content__c>) listOfsObject;

                sendNotificationOnRSVPActionToAuthorAndOrganizer(contentList);
    
            } else if('sendPushNotificationBatch'.equalsIgnoreCase(batchType)) {
                List<App_Notification__c> appNotifList = (List<App_Notification__c>) listOfsObject;
                sendPushNotification(appNotifList);

            } else {
                List<People_Preference__c> peoplePreList = (List<People_Preference__c>)listOfsObject;
                List<App_Notification__c> listOfNotificationTemp = new List<App_Notification__c>();
                List<People_Preference__c> revisedPeoplePrefList = new List<People_Preference__c>();
                List<Map<String, String>> listOfMapOfSmsDetails = new List<Map<String, String>>();

                for (People_Preference__c peoplePrefObj : peoplePreList) {
                    String peopleId = peoplePrefObj.people__c;
                    App_Notification__c notificationObject = new App_Notification__c();
                    notificationObject.Sent_By__c = UserContext.peopleId;
                    notificationObject.GUID__c = guid;
                    notificationObject.Object_Id__c = contentObj.id;
                    notificationObject.content__c = contentObj.id;
                    notificationObject.Object_Type__c = contentObj.type__c;
                    notificationObject.Status__c = 'Pending';
                    notificationObject.Type__c = 'Information';
                    notificationObject.Sub_Type__c = 'Content Update';
                    notificationObject.Is_Read__c = false;
                    notificationObject.Is_New__c = true;
                    notificationObject.category__c = 'Content_Notification';
                    notificationObject.Snippet__c =  Utility.chompString(contentObj.title__c, 255);
                    notificationObject.Sent_to__c = peopleId;
                    notificationObject.Simpplr_Site__c = contentObj.site__c;
                    notificationObject.Created_DateTime__c = DateTime.now();
                    listOfNotificationTemp.add(notificationObject);
                    
                    if (peoplePrefObj.Allow_Simpplr_Emails__c && 'Immediate'.equalsIgnoreCase(peoplePrefObj.Email_Notification_Digest_Frequency__c) && peoplePrefObj.Email_Updates_Content_Sites_I_Follow__c){
                        revisedPeoplePrefList.add(peoplePrefObj);   
                    }

                    if (SimpplrContext.isSMSEnabled && peoplePrefObj.SMS_Content_Promotion_Message__c == true &&  
                            peoplePrefObj.People__r.Mobile_Phone__c != null) {
                        Map<String, String> mapOfSmsDetail = new Map<String, String>();
                        mapOfSmsDetail.put('people_id', peoplePrefObj.People__c);
                        mapOfSmsDetail.put('mobile_number', peoplePrefObj.People__r.Mobile_Phone__c);
                        mapOfSmsDetail.put('languageLocaleKey', 
                                Utility.getSimpplrLanguageLocaleKey(peoplePrefObj.people__r.User__r.languagelocalekey).replace('_', '-'));
                        listOfMapOfSmsDetails.add(mapOfSmsDetail);
                    }

                }

                if (listOfMapOfSmsDetails.size() > 0 && !test.isRunningTest()) {
                    sendSms(listOfMapOfSmsDetails, contentObj, guid);
                    batchNumber = batchNumber + 1;
                }

                createNotifications(listOfNotificationTemp);

                if (SimpplrContext.enableEmail) {
                    NotificationDispatcher.sendEmailForContentPromote(revisedPeoplePrefList, contentObj, message, guid);
                } 

            }

        }catch(Exception ex) {
    		exceptionDetailsObj =  ex;
    		throw ex;
   		}
    }
    @TestVisible
    private ResponseWrapper sendSms (List<Map<String, String>> mobileLanguageMapList, 
            Simpplr_Content__c contentObj, String guid) {
		String SMS_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/notifications/sms-processor?utm_medium=sms&utm_source=content_notifications'; 
		ResponseWrapper response;
		Http httpObj = new Http();
		String simpplrDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);
        HttpRequest req = new HttpRequest();
		req.setEndpoint(SMS_ENDPOINT);
		
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('mobileLanguageMapList', mobileLanguageMapList);
        requestBody.put('appName', SimpplrContext.applicationName);
        requestBody.put('sms_type', 'content_notifications');
        requestBody.put('sender_id', UserContext.peopleId);
        requestBody.put('batch_number', batchNumber);
        requestBody.put('org_id', SimpplrContext.simpplrOrgId.substring(0, 15));
        requestBody.put('contentTitle', contentObj.Title__c);
        requestBody.put('contentType', contentObj.Type__c);
        requestBody.put('content_id', contentObj.Id);
        requestBody.put('userName', UserContext.peopleName);
        requestBody.put('releaseVersion', ServiceConstants.RELEASE_VERSION);
        requestBody.put('url', SimpplrContext.salesForceBaseUrl + 
                Page.PageRedirector.getUrl() + '?siteId=' + contentObj.site__c + 
                '&contentId='+contentObj.id + '&pageToRedirect=ContentDetailPage' + 
                '&origin=ne&contentType=' + contentObj.type__c.tolowercase() + 
                '&utm_source=content_notifications&utm_medium=sms&showContentNotification='+guid);
        
		req.setBody(Json.serialize(requestBody));
		req.setHeader('simpplr-dri', simpplrDri); 
        req.setMethod('POST');
        if (!test.isRunningTest()){
            HttpResponse res = httpObj.send(req);
		    String smsResponse= res.getBody();
        }
		return response;
	}
    // Max emails per content could be 6(5 organizer, 1 Author)
    @TestVisible
    private void sendNotificationOnRSVPActionToAuthorAndOrganizer(List<Simpplr_Content__c> contentList){
        Set<String> contentIdSet = new Set<String>();
        for(Simpplr_Content__c contentObj : contentList){
            contentIdSet.add(contentObj.Id);
        }
        List<AggregateResult> aggrList = [SELECT COUNT(Id) responseCount, content__c contentId FROM Event_RSVP_Response__c WHERE
                                         is_deleted__c = false
                                         AND (createddate > :conditionDateTime OR lastmodifieddate > :conditionDateTime) 
                                         AND content__c IN :contentIdSet GROUP BY content__c];
        Map<String, Integer> contentVsNewOrEditedRsvpCount = new Map<String, Integer>();
        for(AggregateResult ar: aggrList) {
            contentVsNewOrEditedRsvpCount.put((String) ar.get('contentId'), (Integer) ar.get('responseCount'));
        }

        Map<String, String> peopleIdVsLocaleMap = new Map<String, String>();
        Map<String, List<Simpplr_Content__c>> peopleIdVsContentListMap = new Map<String, List<Simpplr_Content__c>>();
        for(Simpplr_Content__c contentObj : contentList){
            String localeKey = Utility.getSimpplrLanguageLocaleKey(contentObj.Primary_Author__r.User__r.languagelocalekey);

            peopleIdVsLocaleMap.put(contentObj.Primary_Author__c, localeKey);
            if(peopleIdVsContentListMap.containsKey(contentObj.Primary_Author__c)) {
                peopleIdVsContentListMap.get(contentObj.Primary_Author__c).add(contentObj);
            } else {
                peopleIdVsContentListMap.put(contentObj.Primary_Author__c, new List<Simpplr_Content__c>{contentObj});
            }

            for(Content_Collaborator__c collabObj : contentObj.Content_Collaborators_Simpplr_Content__r){
                if(collabObj.Collaborator__c != contentObj.Primary_Author__c) {
                    localeKey = Utility.getSimpplrLanguageLocaleKey(collabObj.Collaborator__r.User__r.languagelocalekey);

                    peopleIdVsLocaleMap.put(collabObj.Collaborator__c, localeKey);
                    if(peopleIdVsContentListMap.containsKey(collabObj.Collaborator__c)) {
                        peopleIdVsContentListMap.get(collabObj.Collaborator__c).add(contentObj);
                    } else {
                        peopleIdVsContentListMap.put(collabObj.Collaborator__c, new List<Simpplr_Content__c>{contentObj});
                    }
                }
            }
        }

        // Intialize In App Notification labels, if not done yet. 
        LocaleContext.getAllLabelMap('EmailNotifications', peopleIdVsLocaleMap.values());

        List<People_Preference__c> peoplePreList;
        if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
            peoplePreList = [Select id, people__c, people__r.user__c, People__r.First_Name__c, People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, Email_Content_Submitted_for_Moderation__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey, User__r.timeZonesidkey, people__r.User_Hash__c From People_Preference__c where Allow_Simpplr_Emails__c = true and (Email_Notification_Digest_Frequency__c='Immediate' or Email_Notification_Digest_Frequency__c='Daily') and Email_Updates_Event_I_Author_Organize__c = true and  people__c IN :peopleIdVsLocaleMap.keySet() and people__r.User__r.IsActive=true  and people__r.User__r.UserType='Standard' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: SimpplrContext.packageName)];
        } else {
            peoplePreList = [Select id, people__c, people__r.user__c, People__r.First_Name__c, People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, Email_Content_Submitted_for_Moderation__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey, User__r.timeZonesidkey, people__r.User_Hash__c From People_Preference__c where Allow_Simpplr_Emails__c = true and (Email_Notification_Digest_Frequency__c='Immediate' or Email_Notification_Digest_Frequency__c='Daily') and Email_Updates_Event_I_Author_Organize__c = true and  people__c IN :peopleIdVsLocaleMap.keySet() and people__r.User__r.IsActive=true  and people__r.User__r.UserType='Standard'];
        }

         // Send Email Notification
         if(SimpplrContext.enableEmail) {
            List<Messaging.SingleEmailMessage> emailObjList = new List<Messaging.SingleEmailMessage>();
            for(People_Preference__c peoplePref : peoplePreList){
                String localeKey = peopleIdVsLocaleMap.get(peoplePref.people__c);

                for(Simpplr_Content__c contentObj:peopleIdVsContentListMap.get(peoplePref.people__c)) {

                    // New respondents: {{eventName}}
                    String subject = LocaleContext.getLabel(localeKey, 'email.notification.event.new_respondents.subject')
                                                                        .replace('{{eventName}}', contentObj.Title__c.length() > 100 ? contentObj.Title__c.substring(0, 97) + '...' : contentObj.Title__c);
                    
                    Integer respondentCount =  contentVsNewOrEditedRsvpCount.get(contentObj.Id);

                    List<String> respondentNameList = new List<String>();
                    for(Event_RSVP_Response__c rsvpRespObj : contentObj.Event_RSVP_Responses__r){
                        respondentNameList.add(rsvpRespObj.People__r.Full_Name__c);
                    }
                    String emailBody = new NotificationDispatcher().getRespondentsEmailBody(contentObj, localeKey, peoplePref, respondentNameList, respondentCount);

                    
                    emailObjList.add(EmailUtility.getSingleEmailElement(subject, emailBody, peoplePref.people__r.user__c, SimpplrContext.SEDFromEmail));							
                }
            }

            if(!emailObjList.isEmpty()){
                Messaging.sendEmail(emailObjList); 
            }
        }

         // Send In app notifications
		List<App_Notification__c> appNotificationList = new List<App_Notification__c>(); 
		for(String peopleId : peopleIdVsLocaleMap.keySet()){
            // Send In-App Notification
            
            for(Simpplr_Content__c contentObj:peopleIdVsContentListMap.get(peopleId)) {
                Integer respondentCount = contentVsNewOrEditedRsvpCount.get(contentObj.Id);

                List<String> respondentNameList = new List<String>();
                String lastSentByPeopleId = null;
                for(Event_RSVP_Response__c rsvpRespObj : contentObj.Event_RSVP_Responses__r){
                    respondentNameList.add(rsvpRespObj.People__r.Full_Name__c);
                    
                    if(String.isBlank(lastSentByPeopleId)) {
                        lastSentByPeopleId = rsvpRespObj.People__c;
                    }
                }

                App_Notification__c notificationObj = new App_Notification__c();
                notificationObj.GUID__c = UserContext.id + '-' + System.currentTimeMillis();
                notificationObj.Object_Id__c = contentObj.Id;
                notificationObj.Content__c=contentObj.Id;
                notificationObj.Object_Type__c = 'Event';
                notificationObj.Status__c = 'Pending';
                notificationObj.Type__c = 'Information';
                notificationObj.Sub_Type__c = 'Update';
                notificationObj.Is_Read__c = false;
                notificationObj.Is_New__c = true;
                notificationObj.Category__c = 'Event_Responses';
                notificationObj.Snippet__c = String.join(respondentNameList,',');
                notificationObj.Submitter_Comment__c = String.valueOf(respondentCount);
                notificationObj.Sent_to__c = peopleId;
                notificationObj.Sent_By__c = lastSentByPeopleId;
                notificationObj.Simpplr_Site__c = contentObj.Site__c;
                notificationObj.Created_DateTime__c = DateTime.now();

                appNotificationList.add(notificationObj);
            }
		}

		if(!appNotificationList.isEmpty()){

			NotificationDao.createNotifications(appNotificationList);
		}
        
    }
    // Send event action(delete, unpublished and update) email and notification to author, collaborators, organizers and rsvp yes users
    @TestVisible
    private void sendEventActionEmail(Map<String, String> peopleIdVsLocaleMap){
		List<Simpplr_Content__c> contentList = [SELECT Id, Event_Attending_Count__c, Site__c, Title__c, Site__r.Name,
														Primary_Author__r.User__r.languagelocalekey, Primary_Author__r.External_Photo_URL__c,
														Primary_Author__r.External_Photo_URL_Expiry_Date__c, Primary_Author__c, Event_End_DateTime__c,
														Primary_Author__r.First_Name__c,Primary_Author__r.Full_Name__c, Last_Edited_DateTime__c, Type__c, 
														Event_TimezoneSidKey__c, Event_Is_All_Day__c, Event_Start_Datetime__c, Event_Location__c, Publish_Start_DateTime__c,
														(SELECT Id, Content_Version__c, Thumbnail_URL__c, Is_Title_Image__c, Title_Image_Type__c
															FROM File_Simpplr_Content__r  
															WHERE Is_Deleted__c = false AND Is_Title_Image__c = true ORDER BY Title_Image_Type__c),
														(SELECT Collaborator__c FROM Content_Collaborators_Simpplr_Content__r WHERE
														 	Type__c = 'Organizer' And Is_Deleted__c = false AND Collaborator__c IN :peopleIdVsLocaleMap.keySet())   
														FROM Simpplr_Content__c 
														WHERE id = :contentId];

		// Create set of managing people, to avoid duplicate emails to users(rsvpd user may also be managing the event)
		Set<String> managingPeopleIdSet = new Set<String>();
		managingPeopleIdSet.add(contentList[0].Primary_Author__c);

		if(contentList[0].Content_Collaborators_Simpplr_Content__r != null &&
				!contentList[0].Content_Collaborators_Simpplr_Content__r.isEmpty()){

			for(Content_Collaborator__c ccObj : contentList[0].Content_Collaborators_Simpplr_Content__r){
				managingPeopleIdSet.add(ccObj.Collaborator__c);
			}	
		}															

		String eventCategory = null;
		String subjectKey = null;
		if('eventDeleted'.equalsIgnoreCase(eventAction)){
			eventCategory = 'Event_Deleted';
			subjectKey = 'email.notification.event.delete.managing_subject';

		} else if('eventUnpublished'.equalsIgnoreCase(eventAction)){
			eventCategory = 'Event_Unpublished';
			subjectKey = 'email.notification.event.unpublished.managing_subject';

		} else if('eventUpdated'.equalsIgnoreCase(eventAction)){
			eventCategory = 'Event_Updated';
			subjectKey = 'email.notification.event.updated.managing_subject';

		}

        // Send In app notifications
        String author = contentList[0].Primary_Author__c;
        if(sendInAppNotification == true){
            List<App_Notification__c> appNotificationList = new List<App_Notification__c>(); 
            for(String peopleId : peopleIdVsLocaleMap.keySet()){
                // Send In-App Notification
                if('sendEmailToRsvpYesUsersOnEventAction'.equalsIgnoreCase(batchType)) {
                    if(managingPeopleIdSet.contains(peopleId)) {
                        continue;
                    }                    
                } else if('sendEmailToCollaboratorsOnEventAction'.equalsIgnoreCase(batchType)) {
                    if(author.equalsIgnoreCase(peopleId)) {
                        continue;
                    }
                }
                App_Notification__c notificationObj = new App_Notification__c();
                notificationObj.GUID__c = UserContext.id + '-' + System.currentTimeMillis();
                notificationObj.Object_Id__c = contentList[0].Id;
                notificationObj.Content__c = contentList[0].Id;
                notificationObj.Object_Type__c = 'Event';
                notificationObj.Status__c = 'Pending';
                notificationObj.Type__c = 'Information';
                notificationObj.Sub_Type__c = 'Update';
                notificationObj.Is_Read__c = false;
                notificationObj.Is_New__c = true;
                notificationObj.Category__c = eventCategory;
                notificationObj.content__c = contentList[0].id;
                notificationObj.Snippet__c = UserContext.peopleName;
                notificationObj.Submitter_Comment__c = '';
                notificationObj.Sent_to__c = peopleId;
                notificationObj.Sent_By__c = UserContext.getCurrentUserInfo.id;
                notificationObj.Simpplr_Site__c = contentList[0].Site__c;
                notificationObj.Created_DateTime__c = DateTime.now();

                appNotificationList.add(notificationObj);
            }

            if(!appNotificationList.isEmpty()){

                NotificationDao.createNotifications(appNotificationList);
            }
        }	

        if(SimpplrContext.enableEmail && (sendEmailNotification == true)){
            // Intialize In App Notification labels, if not done yet. 
            LocaleContext.getAllLabelMap('EmailNotifications', peopleIdVsLocaleMap.values());
                        
            String query;
            Set<String> peopleIdSet = peopleIdVsLocaleMap.keySet();            
            if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
                query = 'Select id, people__c, people__r.user__c, People__r.First_Name__c, People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, Email_Content_Submitted_for_Moderation__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey, User__r.timeZonesidkey, people__r.User_Hash__c  From People_Preference__c where Allow_Simpplr_Emails__c = true and people__c IN :peopleIdSet and people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: packageName) ';
            } else {
                query = 'Select id, people__c, people__r.user__c, People__r.First_Name__c, People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, Email_Content_Submitted_for_Moderation__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey, User__r.timeZonesidkey, people__r.User_Hash__c From People_Preference__c where Allow_Simpplr_Emails__c = true and people__c IN :peopleIdSet and people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\' ';
            }
            
            if('sendEmailToRsvpYesUsersOnEventAction'.equalsIgnoreCase(batchType)) {
                query += ' And Email_Updates_Event_I_RSVP_Yes__c = true AND People__c !=: managingPeopleIdSet ';

            } else if('sendEmailToCollaboratorsOnEventAction'.equalsIgnoreCase(batchType)) {
                
                query += ' And Email_Updates_Event_I_Author_Organize__c = true AND People__c !=: author';

            } else {
                query += ' And Email_Updates_Event_I_Author_Organize__c = true ';
            }
            List<People_Preference__c> peoplePreList = Database.query(query);
            // Send Email Notification
            List<Messaging.SingleEmailMessage> emailObjList = new List<Messaging.SingleEmailMessage>();
            String localeKey = null;
            String subject = null ;                
            for(People_Preference__c peoplePref : peoplePreList){
                localeKey = peopleIdVsLocaleMap.get(peoplePref.people__c);
                subject = LocaleContext.getLabel(localeKey, subjectKey).replace('{{eventName}}', contentList[0].Title__c.length() > 100 ? contentList[0].Title__c.substring(0, 97) + '...' : contentList[0].Title__c);
                
                String emailBody = new NotificationDispatcher().getEventActionNotificationEmailBody(contentList[0], peoplePref, localeKey, eventAction, managingPeopleIdSet.contains(peoplePref.people__c));
                
                emailObjList.add(EmailUtility.getSingleEmailElement(subject, emailBody, peoplePref.people__r.user__c, SimpplrContext.SEDFromEmail));							
            }

            if(!emailObjList.isEmpty()){
                Messaging.sendEmail(emailObjList); 
            }
        }
	}

    private String createContentMessage() {
        Content_Message__c messageObj = new Content_Message__c();
        messageObj.message__c = message;
        messageObj.content__c = contentObjId;
        messageObj.Sent_By_People__c = UserContext.peopleId; 

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SObject contentMessageInsertedObj = SIMPESAPI.accessController().insertAsUser(messageObj, new List<Schema.SObjectField> { 
                Content_Message__c.message__c,
                Content_Message__c.content__c,
                Content_Message__c.Sent_By_People__c}); 

        messageObj = (Content_Message__c) contentMessageInsertedObj;
        
        return messageObj.Id;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :bc.getJobId()];
        if(currentJob.Status == 'Completed' && currentJob.NumberOfErrors == 0) {
            if('sendEmailToAuthorOnEventAction'.equalsIgnoreCase(batchType)) {
				BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate('sendEmailToCollaboratorsOnEventAction', contentId, eventAction, sendInAppNotification, sendEmailNotification);
				Database.executeBatch(job, 25);
	
			} else if('sendEmailToCollaboratorsOnEventAction'.equalsIgnoreCase(batchType)) {
				BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate('sendEmailToRsvpYesUsersOnEventAction', contentId, eventAction, sendInAppNotification, sendEmailNotification);
				Database.executeBatch(job, 25);
	
			} else if('sendEmailToRsvpYesUsersOnEventAction'.equalsIgnoreCase(batchType)) {
				// Do nothing
	
			} else {
                if(SimpplrContext.SimpplrMobileNotificationAllowed && String.isNotBlank(guid) && !'sendPushNotificationBatch'.equalsIgnoreCase(batchType)){
                    BatchNotificationsOnContentUpdate job = new BatchNotificationsOnContentUpdate('sendPushNotificationBatch', guid, null);
				    Database.executeBatch(job, 100);
                }
            }    
        } else {
            Utility.sendExceptionEmail('BatchNotificationsOnContentUpdate', exceptionDetailsObj);
        }
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
     public static Map<String,App_Notification__c> createNotifications(List<App_Notification__c> listOfSN) {
        //insert listOfSN;
        Map<String,App_Notification__c> userToNotificationMap = new Map<String,App_Notification__c>();
        List<String> insertedNotificationIdList = new List<String>();

        if(listOfSN.isEmpty() == false){
            
            SIMPESAPI.accessController().setArrayOperationMode(SIMPSFDCAccessController.OperationMode.BEST_EFFORT);
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPSFDCAccessControlResults.InsertResults insertResults = SIMPESAPI.accessController().insertAsUser(listOfSN, new List<Schema.SObjectField> { 
                    App_Notification__c.Sent_By__c,
                    App_Notification__c.GUID__c,
                    App_Notification__c.Object_Id__c,
                    App_Notification__c.content__c,
                    App_Notification__c.Object_Type__c,
                    App_Notification__c.Status__c,
                    App_Notification__c.Type__c,
                    App_Notification__c.Sub_Type__c,
                    App_Notification__c.Is_Read__c,
                    App_Notification__c.Is_New__c,
                    App_Notification__c.category__c,
                    App_Notification__c.Snippet__c,
                    App_Notification__c.Sent_to__c,
                    App_Notification__c.Simpplr_Site__c,
                    App_Notification__c.Created_DateTime__c});
    
            List<App_Notification__c> insertedAppNotificationList = (List<App_Notification__c>) insertResults.getInsertedObjects();
            for (App_Notification__c appNotificationObj : insertedAppNotificationList) {
    
                if(String.isNotBlank(appNotificationObj.Id)){
                    
                    userToNotificationMap.put(appNotificationObj.Sent_to__c, appNotificationObj); 
                }
            }
        }
        
        return userToNotificationMap ;
    }
    
    /**
     * @description sendPushNotification : used for sending push notification to mobile app
     * @param listOfSPN
    */
    private static void sendPushNotification(List<App_Notification__c> listOfSPN) {
        try{
            if( !listOfSPN.isEmpty() ) {                    
                Map<String, List<PushNotifcationWrapper>> pushNotiJsonMap = getPullNotiBasedOnUserPref(listOfSPN);
                String pushNotiListMobile = null;
                String pushNotiListBrowser = null;

                if(pushNotiJsonMap.containsKey('pushNotiListMobile')) {
                    pushNotiListMobile = JSON.serialize(pushNotiJsonMap.get('pushNotiListMobile'));
                }

                if(pushNotiJsonMap.containsKey('pushNotiListBrowser')) {
                    pushNotiListBrowser = JSON.serialize(pushNotiJsonMap.get('pushNotiListBrowser'));
                }

                Utility.sendPushNotifications(pushNotiListMobile, pushNotiListBrowser);
            }
        } catch (Exception ex){
            Utility.sendExceptionEmail('NotificationDao', ex);
            throw ex;
        }
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
    private static Map<String, List<PushNotifcationWrapper>> getPullNotiBasedOnUserPref(List<App_Notification__c> listOfSN) {
        Set<String> targetPeopleSet = new Set<String>();

        Map<String, List<PushNotifcationWrapper>> pushNotiJsonMap = new Map<String, List<PushNotifcationWrapper>>();

        List<PushNotifcationWrapper> pushNotiListMobile = new List<PushNotifcationWrapper>();
        List<PushNotifcationWrapper> pushNotiListBrowser = new List<PushNotifcationWrapper>();

        for(App_Notification__c listOfSNObj: listOfSN) {
            targetPeopleSet.add(listOfSNObj.Sent_to__c);
        }
        List<People_Preference__c> peoplePrefList= [SELECT Id,Native_Mob_Update_Content_Site_I_Follow__c,people__r.Full_Name__c,people__r.New_Notification_Count__c, 
        											people__r.Mobile_App_Type_iOS__c,  people__r.Mobile_App_Type_Android__c, people__r.Mobile_Token_Android__c, 
        											people__r.Mobile_Token_iOS__c, Mobile_Allow_Notifications__c, Mobile_Event_Invite_More__c, Mobile_Comments_After_Me__c, 
        											Mobile_Comments_On_My_Post__c, Mobile_Comments_On_Post_I_Like__c, Mobile_Content_Useful__c, 
        											Receive_Content_Useful_Notifications__c, Mobile_Content_Submitted_For_Moderation__c, Mobile_Endorses_Me__c, 
        											Mobile_Follows_Me__c, Mobile_Like_My_Post_Or_Comment__c, Mobile_My_Content_Approved__c, Mobile_My_Content_Post__c, 
        											Mobile_My_Content_Rejected__c, Mobile_My_Content_Like_Or_Share__c, Mobile_Posts_To_Me__c, 
        											Mobile_Private_Site_Membership_Requests__c, Mobile_Shares_My_Post__c, Mobile_PrivateSiteMembership_Response__c, 
        											Mobile_Content_Submission_Response__c, Mobile_Updates_Content_Sites_I_Follow__c, Allow_Simpplr_Emails__c,
        											people__r.Mobile_FCM_ID_iOS__c, people__r.Mobile_Bundle_ID_iOS__c, people__r.Mobile_FCM_ID_Android__c, people__r.Mobile_Bundle_ID_Android__c, 
                                                    Allow_Browser_Notifications__c, Browser_Update_Content_Site_I_Follow__c, User__r.languagelocalekey
                                                    FROM People_Preference__c where People__c IN : targetPeopleSet ];

        Map<String,People_Preference__c> peoplePrefMap = new Map<String,People_Preference__c>();
        Set<String> localeSet = new Set<String>();
        for(People_Preference__c peoplePref : peoplePrefList) {
            peoplePrefMap.put(peoplePref.people__c,peoplePref);
            localeSet.add(Utility.getSimpplrLanguageLocaleKey(peoplePref.User__r.languagelocalekey));
        }
		LocaleContext.getAllLabelMap('PushNotifications', new List<String>(localeSet));

        for(App_Notification__c noti : listOfSN) {
            Boolean sendNotiCheck = false;
            Boolean sendNotiCheckAndroid = false;
            Boolean sendNotiCheckIOS = false;
            Boolean sendNotiCheckWeb = false;
            People_Preference__c peoplePref = peoplePrefMap.get(noti.Sent_To__c);
            if(peoplePref != null){
                if(String.isNotBlank(peoplePref.people__r.Mobile_Token_Android__c)
                    || String.isNotBlank(peoplePref.people__r.Mobile_Token_IOS__c)
                    || 'Yes'.equalsIgnoreCase(peoplePref.Allow_Browser_Notifications__c)) {
                
                	if(noti.sub_type__c.equalsIgnoreCase('Content Update')){
                        if(((String.isNotBlank(peoplePref.people__r.Mobile_Token_Android__c) && !'Native'.equalsIgnoreCase(peoplePref.people__r.Mobile_App_Type_Android__c)) && 
                                peoplePref.Mobile_Allow_Notifications__c && peoplePref.Mobile_Updates_Content_Sites_I_Follow__c) ||
                                ((String.isNotBlank(peoplePref.people__r.Mobile_Token_Android__c) && 'Native'.equalsIgnoreCase(peoplePref.people__r.Mobile_App_Type_Android__c)) &&
                                peoplePref.Native_Mob_Update_Content_Site_I_Follow__c)) {

                            sendNotiCheckAndroid = true;
                        }
                            
                        if(((String.isNotBlank(peoplePref.people__r.Mobile_Token_IOS__c) && !'Native'.equalsIgnoreCase(peoplePref.people__r.Mobile_App_Type_iOS__c)) && 
                                peoplePref.Mobile_Allow_Notifications__c && peoplePref.Mobile_Updates_Content_Sites_I_Follow__c) ||
                                ((String.isNotBlank(peoplePref.people__r.Mobile_Token_IOS__c) && 'Native'.equalsIgnoreCase(peoplePref.people__r.Mobile_App_Type_iOS__c)) &&
                                peoplePref.Native_Mob_Update_Content_Site_I_Follow__c)) {

                            sendNotiCheckIOS = true;
                        }

                        if(peoplePref.Browser_Update_Content_Site_I_Follow__c) {

                            sendNotiCheckWeb = true;
                        }
                    }

                    String userLanguage = Utility.getSimpplrLanguageLocaleKey(peoplePref.User__r.languagelocalekey);
                    String localizedContentType = LocaleContext.getLocalisedContentTypeLabel(userLanguage, noti.Object_Type__c);
                    if(sendNotiCheckAndroid && String.isNotBlank(peoplePref.people__r.Mobile_Token_Android__c)){
                        PushNotifcationWrapper pushNotiAndroidObj = new PushNotifcationWrapper();
                        pushNotiAndroidObj.notificationtext = LocaleContext.getLabel(userLanguage, 'push.content.promote.notification')
                                                                .replace('{{fullName}}', UserContext.peopleName)
                                                                .replace('{{contentType}}', localizedContentType)
                                                                .replace('{{contentType, lowercase}}', localizedContentType.toLowerCase())
                                                                .replace('{{contentTitle}}', noti.snippet__c);
                        pushNotiAndroidObj.deviceToken = peoplePref.people__r.Mobile_Token_Android__c;
                        pushNotiAndroidObj.deviceType = 'android';
                        pushNotiAndroidObj.appType = String.isNotBlank(peoplePref.people__r.Mobile_App_Type_Android__c)?peoplePref.people__r.Mobile_App_Type_Android__c:'hybrid';
                        pushNotiAndroidObj.Url = NotificationDao.getNotificationURL(noti);
                        pushNotiAndroidObj.notificationId = noti.id;
						pushNotiAndroidObj.notificationType = 'content';
						pushNotiAndroidObj.sentById = UserContext.peopleId;
						pushNotiAndroidObj.siteId = noti.Simpplr_Site__c;
						pushNotiAndroidObj.contentId = noti.Object_Id__c;
						pushNotiAndroidObj.contentType = noti.Object_Type__c;
						pushNotiAndroidObj.privateSiteRequestId = '';
						pushNotiAndroidObj.isClickable = true;
						pushNotiAndroidObj.isActionable = false;
						pushNotiAndroidObj.badge = Integer.valueOf(peoplePref.people__r.New_Notification_Count__c);
						pushNotiAndroidObj.sound = 'default';
						pushNotiAndroidObj.fcmId = peoplePref.people__r.Mobile_FCM_ID_Android__c;
		    			pushNotiAndroidObj.bundleId = peoplePref.people__r.Mobile_Bundle_ID_Android__c;
                        pushNotiListMobile.add(pushNotiAndroidObj);
                    }

                    if(sendNotiCheckIOS && String.isNotBlank(peoplePref.people__r.Mobile_Token_IOS__c)){
                        PushNotifcationWrapper pushNotiIOSObj = new PushNotifcationWrapper();
                        pushNotiIOSObj.notificationtext = LocaleContext.getLabel(userLanguage, 'push.content.promote.notification')
                                                                .replace('{{fullName}}', UserContext.peopleName)
                                                                .replace('{{contentType}}', localizedContentType)
                                                                .replace('{{contentType, lowercase}}', localizedContentType.toLowerCase())
                                                                .replace('{{contentTitle}}', noti.snippet__c);
                        pushNotiIOSObj.deviceToken = peoplePref.people__r.Mobile_Token_IOS__c;
                        pushNotiIOSObj.deviceType = 'ios';
                        pushNotiIOSObj.appType = String.isNotBlank(peoplePref.people__r.Mobile_App_Type_IOS__c)?peoplePref.people__r.Mobile_App_Type_IOS__c:'hybrid';
                        pushNotiIOSObj.Url = NotificationDao.getNotificationURL(noti);
                        pushNotiIOSObj.notificationId = noti.id;
						pushNotiIOSObj.notificationType = 'content';
						pushNotiIOSObj.sentById = UserContext.peopleId;
						pushNotiIOSObj.siteId = noti.Simpplr_Site__c;
						pushNotiIOSObj.contentId = noti.Object_Id__c;
						pushNotiIOSObj.contentType = noti.Object_Type__c;
						pushNotiIOSObj.privateSiteRequestId = '';
						pushNotiIOSObj.isClickable = true;
						pushNotiIOSObj.isActionable = false;
						pushNotiIOSObj.badge = Integer.valueOf(peoplePref.people__r.New_Notification_Count__c);
						pushNotiIOSObj.sound = 'default';
						pushNotiIOSObj.fcmId = peoplePref.people__r.Mobile_FCM_ID_iOS__c;
		    			pushNotiIOSObj.bundleId = peoplePref.people__r.Mobile_Bundle_ID_iOS__c;
                        pushNotiListMobile.add(pushNotiIOSObj);
                    }

                    // web-browser notifications
                    if(sendNotiCheckWeb) {
                        PushNotifcationWrapper webNotiObj = new PushNotifcationWrapper();
                        webNotiObj.notificationtext = LocaleContext.getLabel(userLanguage, 'push.content.promote.notification')
                                                                .replace('{{fullName}}', UserContext.peopleName)
                                                                .replace('{{contentType}}', localizedContentType)
                                                                .replace('{{contentType, lowercase}}', localizedContentType.toLowerCase())
                                                                .replace('{{contentTitle}}', noti.snippet__c);
                        
                        webNotiObj.title = SimpplrContext.applicationName;
                        webNotiObj.Url = NotificationDao.getNotificationURL(noti);
                        webNotiObj.notificationId = noti.id;
						webNotiObj.notificationType = 'content';
                        webNotiObj.sentById = UserContext.peopleId;
                        webNotiObj.sentToId = ((String)peoplePref.people__c).substring(0, 15);
						webNotiObj.siteId = noti.Simpplr_Site__c;
						webNotiObj.contentId = noti.Object_Id__c;
						webNotiObj.contentType = noti.Object_Type__c;
						webNotiObj.privateSiteRequestId = '';
						webNotiObj.isClickable = true;
                        webNotiObj.isActionable = false;
                        
                        pushNotiListBrowser.add(webNotiObj);
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
}