/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class RsvpDataServer extends DataServer {
    public transient final String STR_ERROR_RSVP_EVENT_FULL { get { return labelMap.get('rsvp.event_full_error_flash');}}
	private final String ACTION_VALUE_GET = 'getRecord';
	private final String ACTION_VALUE_GET_RSVPCSV = 'getRsvpList';
	private final String ACTION_VALUE_SAVE = 'save';
    private final String ACTION_VALUE_DELETE_ATTENDING = 'deleteAttending';
	private final String ACTION_VALUE_DATA = 'data';
	
	private EventDao eventDaoObj;
	
	public RsvpDataServer() {
		eventDaoObj = new EventDao();

    }
	
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
     /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest() {
    	try{
    		logger.logDebug('RsvpDataServer----entered handleRequest----');
    		
           //-----pass controll to check data integrity---------
            Object result = isParameterValid();
            if(!(result instanceof Boolean)){
                throw New SimpplrException(String.valueOf(result));
            }
            String action = readParam(REQUEST_PARAM_ACTION);
        	if(ACTION_VALUE_GET.equalsIgnoreCase(action)) {
                response = getRecord(readParam(ACTION_VALUE_DATA));
                
            }else if(ACTION_VALUE_SAVE.equalsIgnoreCase(action)) {
                response = save(readParam(ACTION_VALUE_DATA));
                
            } else if(ACTION_VALUE_DELETE_ATTENDING.equalsIgnoreCase(action)){
                response = deleteAttending(readParam(ACTION_VALUE_DATA));	        

            } else{
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }

    private ResponseWrapper deleteAttending(String data){
        ResponseWrapper responseWrapperObj;
		try {
			
			logger.logDebug('SiteAddEventDataServer.deleteAttending()----data----' + data);
            
            Criteria.RemoveAntendee removeAntendeeObj = (Criteria.RemoveAntendee) JSON.deserialize(data, Criteria.RemoveAntendee.class);
            
            String contentId = removeAntendeeObj.contentId;
            List<String> peopleIdList = removeAntendeeObj.peopleIds;
            String note = removeAntendeeObj.note;
            
            if(String.isBlank(contentId) || peopleIdList.isEmpty()){
				throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
			}
            
            // Start date time should always be greater or equals to today, only then user is removable
            DateTime todayDateTime = System.now();
            List<Event_RSVP_Response__c> rsvpRespList = [SELECT Id, People__r.User__r.languagelocalekey, People__c FROM Event_RSVP_Response__c WHERE
                                                        Content__c = :contentId AND People__c IN :peopleIdList
                                                        AND Is_Deleted__c = false AND RSVP_Response__c = 'Yes' 
                                                        AND (Content__r.Event_RSVP_By_DateTime__c = null 
                                                                OR 
                                                            Content__r.Event_RSVP_By_DateTime__c >= :todayDateTime) WITH SECURITY_ENFORCED];

            if(!rsvpRespList.isEmpty()){
                List<Simpplr_Content__c> contentList = [SELECT Id, Event_Attending_Count__c, Site__c, Title__c, Site__r.Name,
                                                        Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c,
                                                        Primary_Author__r.First_Name__c,Primary_Author__r.Full_Name__c ,Last_Edited_DateTime__c, Type__c, Event_Is_All_Day__c,
                                                        Event_TimezoneSidKey__c, Event_Start_Datetime__c, Event_End_DateTime__c, Event_Location__c, Publish_Start_DateTime__c,
                                                        (SELECT Id, Content_Version__c, Thumbnail_URL__c, Is_Title_Image__c, Title_Image_Type__c
                                                          FROM File_Simpplr_Content__r  
							                              WHERE Is_Deleted__c = false AND Is_Title_Image__c = true ORDER BY Title_Image_Type__c) 
                                                        FROM Simpplr_Content__c 
                                                        WHERE id = :contentId
                                                        AND Site__r.Is_Deleted__c = false 
                                                        AND Site__r.Is_Active__c = true
                                                        AND Site__r.Show_In_Simpplr__c = true
                                                        AND Is_Deleted__c = false
                                                        AND Type__c =: ServiceConstants.TYPE_EVENT WITH SECURITY_ENFORCED];
                 
                if(!contentList.isEmpty()){
                    
                    String loggedInUserPeopleId = UserContext.peopleId;
                    Map<String, String> peopleIdVsLocaleMap = new Map<String, String>();
                    for(Event_RSVP_Response__c rsvpRespObj : rsvpRespList){
                        // Avoid sending email or in-app notification to the action performing user
                        if(loggedInUserPeopleId.equalsIgnoreCase(rsvpRespObj.People__c)){
                            continue;
                        }

                        String localeKey = Utility.getSimpplrLanguageLocaleKey(rsvpRespObj.People__r.User__r.languagelocalekey);
                        
                        peopleIdVsLocaleMap.put(rsvpRespObj.People__c, localeKey);
                    }

                    // Intialize In App Notification labels, if not done yet. 
                    LocaleContext.getAllLabelMap('EmailNotifications', peopleIdVsLocaleMap.values());
                    Map<String, Object> soqlParamMap = new  Map<String, Object>();
                    soqlParamMap.put('soqlParam1', peopleIdVsLocaleMap.keySet());
                    String query = '';
                    List<People_Preference__c> peoplePreList;
                    if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
                        soqlParamMap.put('soqlParam2', SimpplrContext.packageName);
                        query = 'Select id, people__c, people__r.user__c, People__r.First_Name__c, People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, Email_Content_Submitted_for_Moderation__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey, User__r.timeZonesidkey, people__r.User_Hash__c From People_Preference__c where Allow_Simpplr_Emails__c = true and Email_Notification_Digest_Frequency__c=\'Immediate\' and  people__c IN :soqlParam1 and people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =:soqlParam2)';
                    } else {
                        query = 'Select id, people__c, people__r.user__c, People__r.First_Name__c, People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, Email_Content_Submitted_for_Moderation__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey, User__r.timeZonesidkey, people__r.User_Hash__c From People_Preference__c where Allow_Simpplr_Emails__c = true and Email_Notification_Digest_Frequency__c=\'Immediate\' and  people__c IN :soqlParam1 and people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\'';
                    }
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
                    peoplePreList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);

                    List<App_Notification__c> appNotificationList = new List<App_Notification__c>(); 
                    for(String peopleId : peopleIdVsLocaleMap.keySet()){
                        // Send In-App Notification
                        App_Notification__c notificationObj = new App_Notification__c();
                        notificationObj.GUID__c = UserContext.id + '-' + System.currentTimeMillis();
                        notificationObj.Object_Id__c = contentList[0].Id;
                        notificationObj.Object_Type__c = 'Event';
                        notificationObj.Status__c = 'Pending';
                        notificationObj.Type__c = 'Information';
                        notificationObj.Sub_Type__c = 'Update';
                        notificationObj.Is_Read__c = false;
                        notificationObj.Is_New__c = true;
                        notificationObj.Category__c = 'RSVP_Removed';
                        notificationObj.Snippet__c = UserContext.peopleName;
                        notificationObj.Submitter_Comment__c = note;
                        notificationObj.Sent_to__c = peopleId;
                        notificationObj.Content__c = contentList[0].Id;
                        notificationObj.Sent_By__c = UserContext.getCurrentUserInfo.id;
                        notificationObj.Simpplr_Site__c = contentList[0].Site__c;
                        notificationObj.Created_DateTime__c = DateTime.now();

                        appNotificationList.add(notificationObj);
                    }

                    if(!appNotificationList.isEmpty()){

                        NotificationDao.createNotifications(appNotificationList);
                    }

                    // Send Email Notification
                    if(SimpplrContext.enableEmail && String.isBlank(note)) {
                        String subjectKey='email.notification.content.event.rsvp_removed.subject';
                        List<Messaging.SingleEmailMessage> emailObjList = new List<Messaging.SingleEmailMessage>();
                        for(People_Preference__c peoplePref : peoplePreList){
                            String localeKey = peopleIdVsLocaleMap.get(peoplePref.people__c);
                            String subject = LocaleContext.getLabel(localeKey, subjectKey).replace('{{eventName}}', contentList[0].Title__c.length() > 100 ? contentList[0].Title__c.substring(0, 97) + '...' : contentList[0].Title__c);
                            String emailBody = new NotificationDispatcher().getRSVPRemovedNotificationEmailBody(contentList[0], peoplePref, localeKey, note);

                            
                            emailObjList.add(EmailUtility.getSingleEmailElement(subject, emailBody, peoplePreList[0].people__r.user__c, SimpplrContext.SEDFromEmail));							
                        }

                        if(!emailObjList.isEmpty()){
                            Messaging.sendEmail(emailObjList); 
                        }
                    }

                    // Delete RSVP
                    SIMPESAPI.accessController().deleteAsUser(rsvpRespList);

                }
            } else {
                throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
            }
            
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            
		} catch(Exception ex) {
            logger.logError('SiteAddEventDataServer.deleteAttending()---Exception occured----', ex);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, ex.getMessage(), null);
            
        }
        
		return responseWrapperObj;
    }

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private ResponseWrapper save(String data){
		logger.logDebug('RsvpDataServer.save()----data----'+data);
		ResponseWrapper resultWrapper = New ResponseWrapper();
        logger.logDebug(data);
        Map<String,Object> rsvpResponseMap = (Map<String,Object>)JSON.deserializeUntyped(data);
        String contentId = String.valueOf(rsvpResponseMap.get('id'));
        String choice = String.valueOf(rsvpResponseMap.get('choice'));
        String rsvpNote = String.valueOf(rsvpResponseMap.get('note'));
        if(String.isBlank(contentId) && String.isBlank(choice)){
            throw New SimpplrException(ExceptionCode.INVALID_PARAMETER.name());
        }
        
        List<Simpplr_Content__c> contentList = [Select Id, Status__c, Event_RSVP_Limit__c, Event_Attending_Count__c, Site__c, Title__c, Site__r.Name,
        Primary_Author__r.External_Photo_URL__c, Primary_Author__r.External_Photo_URL_Expiry_Date__c,Publish_Start_DateTime__c,
        Primary_Author__r.First_Name__c, Last_Edited_DateTime__c, Type__c, Event_TimezoneSidKey__c,
        Event_Start_Datetime__c,Event_End_DateTime__c, Event_Location__c, Event_Is_All_Day__c,
        Primary_Author__r.Full_Name__c, Primary_Author__r.Email__c, Display_Excerpt__c,
        (SELECT Collaborator__c, Collaborator__r.User__r.languagelocalekey, Collaborator__r.Full_Name__c,
                 Collaborator__r.Email__c FROM Content_Collaborators_Simpplr_Content__r
                 WHERE Type__c = 'Organizer' AND Is_Deleted__c = false),
        (SELECT Id, Content_Version__c, Thumbnail_URL__c, Is_Title_Image__c, Title_Image_Type__c
                                                        FROM File_Simpplr_Content__r  
							                            WHERE Is_Deleted__c = false AND Is_Title_Image__c = true ORDER BY Title_Image_Type__c) 
                                                        FROM Simpplr_Content__c 
                                                        where id=:contentId
                                                        And Site__r.Is_Deleted__c = false 
                                                        And Site__r.Is_Active__c = true
                                                        And Site__r.Show_In_Simpplr__c = true
                                                        And Is_Deleted__c = false
                                                        AND Type__c =: ServiceConstants.TYPE_EVENT WITH SECURITY_ENFORCED];
		if(contentList.isEmpty()) {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}
		Simpplr_Content__c contentObj = contentList[0];
        Boolean isEventApproved = false;
        
        if('Approved'.equalsIgnoreCase(contentObj.Status__c)) {
        	isEventApproved = true;
        }
        
        if(isEventApproved) {
	        if('Yes'.equalsIgnoreCase(choice) && contentObj.Event_RSVP_Limit__c != null  && contentObj.Event_RSVP_Limit__c <= eventDaoObj.getRSVPVoteCount(contentId, 'Yes')) {
	        	resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_RSVP_EVENT_FULL, null);
	        	logger.logDebug('RsvpDataServer---- Could not RSVP - Event is full----resultWrapper'+resultWrapper);
	        } else {
	        	People__c currentPeopleRecord = UserContext.getCurrentUserInfo;
        		Event_RSVP_Response__c rsvpRecord;
		        rsvpRecord = eventDaoObj.getEventRsvpForUser(contentId,currentPeopleRecord.Id);
		        String previousResponse = '';
                List<Schema.SObjectField> fieldListForUpsert = new List<Schema.SObjectField> {
                    Event_RSVP_Response__c.RSVP_Response__c,
                    Event_RSVP_Response__c.RSVP_Response_Text__c          
                };
		        if(rsvpRecord == null){
		            rsvpRecord = new Event_RSVP_Response__c();
		            rsvpRecord.People__c = currentPeopleRecord.Id;
		            rsvpRecord.Content__c = contentId;
                    fieldListForUpsert.add(Event_RSVP_Response__c.People__c);
                    fieldListForUpsert.add(Event_RSVP_Response__c.Content__c);
		        } else {
		        	previousResponse = rsvpRecord.RSVP_Response__c;
		        }
		        rsvpRecord.RSVP_Response__c = choice ;
		        rsvpRecord.RSVP_Response_Text__c = rsvpNote;
            
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                Map<String,SIMPSFDCAccessControlResults> mapOfUpsertedResult = SIMPESAPI.accessController().upsertAsUser(new List<Event_RSVP_Response__c>{rsvpRecord},fieldListForUpsert);                     
				
                List<Event_RSVP_Response__c> listOfUpsertedRsvp = new List<Event_RSVP_Response__c>();
                for (String key : mapOfUpsertedResult.keySet()) {
                    if (key.equalsIgnoreCase('INSERTED') && mapOfUpsertedResult.get(key) != null) {
                        SIMPSFDCAccessControlResults.InsertResults insertedResults = (SIMPSFDCAccessControlResults.InsertResults)mapOfUpsertedResult.get('INSERTED');
                        listOfUpsertedRsvp.addAll((List<Event_RSVP_Response__c>)insertedResults.getInsertedObjects());
                    }
                    if (key.equalsIgnoreCase('UPDATED') && mapOfUpsertedResult.get(key) != null) {
                        SIMPSFDCAccessControlResults.UpdateResults updatedResults = (SIMPSFDCAccessControlResults.UpdateResults)mapOfUpsertedResult.get('UPDATED');
                        listOfUpsertedRsvp.addAll((List<Event_RSVP_Response__c>)updatedResults.getUpdatedObjects());
                    }
                }
				RsvpWrapper rsvpWrapperObj = new RsvpWrapper();
				rsvpWrapperObj.respondedWith = rsvpRecord.RSVP_Response__c;
				rsvpWrapperObj.acceptedCount = contentObj.Event_Attending_Count__c != null ? Integer.valueOf(contentObj.Event_Attending_Count__c) :0;
                
                if('Yes'.equalsIgnoreCase(choice)){
                    List<Event_RSVP_Response__c> rsvpRespList = [SELECT Id,People__r.User__r.timeZonesidkey, People__r.User__r.languagelocalekey FROM Event_RSVP_Response__c WHERE
                                                          Id = :listOfUpsertedRsvp[0].Id WITH SECURITY_ENFORCED]; 
                
                    Map<String, String> peopleIdVsLocaleMap = new Map<String, String>();
                    for(Event_RSVP_Response__c rsvpRespObj : rsvpRespList){
                        String localeKey = Utility.getSimpplrLanguageLocaleKey(rsvpRespObj.People__r.User__r.languagelocalekey);
                                                                
                        peopleIdVsLocaleMap.put(rsvpRespObj.People__c, localeKey);
                    } 

                    // Intialize In App Notification labels, if not done yet. 
                    LocaleContext.getAllLabelMap('EmailNotifications', peopleIdVsLocaleMap.values());

                    Map<String, Object> soqlParamMap = new  Map<String, Object>();
                    soqlParamMap.put('soqlParam1', peopleIdVsLocaleMap.keySet());
                    String query = '';
                    List<People_Preference__c> peoplePreList;
                    if(String.isNotBlank(SimpplrContext.packageName) && SimpplrContext.isSandbox == false && !Test.isRunningTest()){
                        soqlParamMap.put('soqlParam2', SimpplrContext.packageName);
                        query = 'Select id, People__r.User__r.timeZonesidkey,User__r.timeZonesidkey,people__c, people__r.user__c, People__r.User_Hash__c, People__r.First_Name__c, People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, Email_Content_Submitted_for_Moderation__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey From People_Preference__c where Allow_Simpplr_Emails__c = true and people__c IN :soqlParam1 and people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\' and User__c IN (select userid from UserPackageLicense where PackageLicense.NamespacePrefix =: soqlParam2)';
                    } else {
                        query = 'Select id,People__r.User__r.timeZonesidkey,User__r.timeZonesidkey, people__c, people__r.user__c, People__r.User_Hash__c, People__r.First_Name__c, People__r.Last_Name__c, People__r.About__c, People__r.user__r.userName, Email_Content_Submitted_for_Moderation__c, People__r.Segment__r.Id, People__r.Segment__r.Branding_JSON__c, People__r.Segment__r.Branding_Logo__c, User__r.languagelocalekey From People_Preference__c where Allow_Simpplr_Emails__c = true and people__c IN :soqlParam1 and people__r.User__r.IsActive=true  and people__r.User__r.UserType=\'Standard\'';
                    } 
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
                    peoplePreList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);                                     
                
                    // Send Email Notification
                    if(SimpplrContext.enableEmail && String.isBlank(rsvpNote)) {
                        List<Messaging.SingleEmailMessage> emailObjList = new List<Messaging.SingleEmailMessage>();
                        for(People_Preference__c peoplePref : peoplePreList){
                            String localeKey = peopleIdVsLocaleMap.get(peoplePref.people__c);
                            String subject = LocaleContext.getLabel(localeKey, 'email.notification.content.event.rsvp_confirmed.subject')
                                                                    .replace('{{eventTitle}}', contentList[0].Title__c.length() > 100 ? contentList[0].Title__c.substring(0,97)+'...' : contentList[0].Title__c);
                            String emailBody = new NotificationDispatcher().getRSVPConfirmedNotificationEmailBody(contentList[0], localeKey, peoplePref);

                            
                            emailObjList.add(EmailUtility.getSingleEmailElement(subject, emailBody, peoplePreList[0].people__r.user__c, SimpplrContext.SEDFromEmail));							
                        }

                        if(!emailObjList.isEmpty()){
                            Messaging.sendEmail(emailObjList); 
                        }
                    }
                } 
               
		        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'You responded as '+rsvpRecord.RSVP_Response__c, rsvpWrapperObj);
		        logger.logDebug('RsvpDataServer---- after updating and inserting RSVP records----resultWrapper'+resultWrapper);
            }

        } else {
	        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
	        logger.logDebug('RsvpDataServer---- cannot RSVP for an unapproved event----resultWrapper'+resultWrapper);
        }

        return resultWrapper;
    }

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private ResponseWrapper getRecord(String data){
    	logger.logDebug('RsvpDataServer.getRecord()----data----'+data);
    	ResponseWrapper resultWrapper = New ResponseWrapper();
        Simpplr_Content__c contentRecord = eventDaoObj.getContentForRsvpFields(data);
        List<Event_RSVP_Response__c> contentRsvpList = eventDaoObj.getEventRsvpList(data);
        RsvpWrapper wrapperObj = New RsvpWrapper();
        wrapperObj = convertContentToRsvpWrapper(contentRecord,wrapperObj);
        wrapperObj = convertRsvpRecordToRsvpWrapper(contentRsvpList,wrapperObj);
        resultWrapper = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Successfully fetched rsvp data.', wrapperObj);
        logger.logDebug('RsvpDataServer.getRecord()----resultWrapper----'+resultWrapper);
        return resultWrapper;
    }

    
       /**
   * [Method Name]
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
    private Object isParameterValid(){
        Object result = true;
        if(readParam('action') == null){
            result = 'action is not defined!';
        }
        else if(readParam('data') == null){
            result = 'data can not be empty!';
        }
        return result;
    }

    private RsvpWrapper convertContentToRsvpWrapper(Simpplr_Content__c contentRecord, RsvpWrapper wrapperObj){
    	wrapperObj.capacity = Integer.valueOf(contentRecord.Event_RSVP_Limit__c);
        DateTime DateTimeValue = contentRecord.Event_RSVP_By_DateTime__c;
        
		String rsvpEndTime = contentRecord.Event_RSVP_By_DateTime__c == null ? '':dateToDisplayString(contentRecord.Event_RSVP_By_DateTime__c,'h:mm a');
		if(rsvpEndTime == '12:00 AM') {
			DateTimeValue = DateTimeValue.addSeconds(-1);
		}
    	if(DateTimeValue != null) {
    		wrapperObj.dueAt = DateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}
    	wrapperObj.showMaybeOption = contentRecord.Event_RSVP_Show_Maybe__c;
    	wrapperObj.noteLabel = contentRecord.Event_RSVP_Note__c;
    	wrapperObj.reportUrl = PageContext.getPageURL(Pages.Reports) +'?contentId='+contentRecord.id + '&action='+ ACTION_VALUE_GET_RSVPCSV;
    	wrapperObj.canDownloadReport = AccessManager.hasContentApprovalAccess();
    	return wrapperObj;
    }

    private RsvpWrapper convertRsvpRecordToRsvpWrapper(List<Event_RSVP_Response__c> rsvpRecordList, RsvpWrapper wrapperObj){
    	Integer yesCount = 0;
    	Integer totalrespose = 0;
    	String currentPeopleId = UserContext.getCurrentUserInfo.id;
    	for(Event_RSVP_Response__c rsvpRecord : rsvpRecordList){
    		totalrespose++;
    		if(ServiceConstants.RSVP_YES.equalsIgnoreCase(rsvpRecord.RSVP_Response__c)){
    			yesCount++;
    		}
    		if(currentPeopleId.equalsIgnoreCase(rsvpRecord.People__c)){
    			wrapperObj.noteValue = rsvpRecord.RSVP_Response_Text__c;
    			wrapperObj.respondedWith = rsvpRecord.RSVP_Response__c.toLowerCase();
    		}

    	}
    	wrapperObj.respondedCount = totalrespose;
    	wrapperObj.acceptedCount = yesCount;
    	return wrapperObj;
    }

    @TestVisible 
    private String dateToDisplayString(Object value,String format){
        String result = '';
        if(value != null){
          DateTime dateTimeValue;
          if(value instanceof Datetime){
            dateTimeValue = (Datetime)value;
          }else if(value instanceof Date){
            Date dateValue = (Date)value;
            dateTimeValue = Datetime.newInstance(dateValue.year(), dateValue.month(),dateValue.day());
          }
          result = dateTimeValue.format(format);  
        }
        return result;
    }
    
}