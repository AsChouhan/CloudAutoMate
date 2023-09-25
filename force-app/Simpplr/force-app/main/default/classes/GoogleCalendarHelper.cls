public with sharing class GoogleCalendarHelper {
    
    private Map<String,Integer> mapOfDayWithNumberOfDaysToAdd = new Map<String,Integer>{
		'Mon'=>6,
		'Tue'=>5,
		'Wed'=>4,
		'Thu'=>3,
		'Fri'=>2,
		'Sat'=>1,
		'Sun'=>0
    };
    private static final String AUTH_INTEGRATION_GOOGLE_ENDPOINT = 'https://accounts.google.com/o/oauth2/auth';
    
    public String getAdminAuthUrl () {
        String googleClientId = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID;
        String googleAuthEndpoint = AUTH_INTEGRATION_GOOGLE_ENDPOINT;
        String googleRedirectURlStr = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager';
        String googleCalendarScopeStr = 'https://www.googleapis.com/auth/userinfo.profile ' + 
                'https://www.googleapis.com/auth/userinfo.email ' +
                'https://www.googleapis.com/auth/calendar ' +  
                'https://www.googleapis.com/auth/calendar.events ';

        String googleStateString = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + 
                '?state=' + IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR + 'admin' + 
                '&orgId=' + SimpplrContext.simpplrOrgId + 
                '&peopleId=' + UserContext.peopleId + 
                '&userId=' + UserContext.userId + 
                '&appName=' + SimpplrContext.applicationName +
                '&multiDomain=' + GoogleDriveService.googleMultiDomainUpgraded();

        String finalRedirectUrl = EmailUtility.format(
                                                    '{0}' + 
                                                    '?response_type=code' + 
                                                    '&client_id={1}' + 
                                                    '&redirect_uri={2}' + 
                                                    '&scope={3}' + 
                                                    '&prompt=consent' + 
                                                    '&access_type=offline' + 
                                                    '&include_granted_scopes=true' + 
                                                    '&state={4}',
            new List<String>{
                googleAuthEndpoint, //0
                EncodingUtil.urlEncode(googleClientId, 'UTF-8'), //1
                EncodingUtil.urlEncode(googleRedirectURlStr, 'UTF-8'), //2
                EncodingUtil.urlEncode(googleCalendarScopeStr, 'UTF-8'), //3
                EncodingUtil.urlEncode(googleStateString, 'UTF-8') //4
            }
        );

        return finalRedirectUrl;  
    }
    
    public String getPeopleAuthUrl () {
        String googleClientId = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID;
        String googleAuthEndpoint = AUTH_INTEGRATION_GOOGLE_ENDPOINT;
        String googleRedirectURlStr = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager';
        String googleCalendarScopeStr = 'https://www.googleapis.com/auth/userinfo.profile ' + 
                                        'https://www.googleapis.com/auth/userinfo.email ' +
                                        'https://www.googleapis.com/auth/calendar ' +  
                                        'https://www.googleapis.com/auth/calendar.events ';

        String googleStateString = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + 
                '?state=' + IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR + 
                '&orgId=' + SimpplrContext.simpplrOrgId + 
                '&peopleId=' + UserContext.peopleId + 
                '&userId=' + UserContext.userId + 
                '&appName=' + SimpplrContext.applicationName +
                '&multiDomain=' + GoogleDriveService.googleMultiDomainUpgraded();

        String finalRedirectUrl = EmailUtility.format('{0}' + 
                                                    '?response_type=code' + 
                                                    '&client_id={1}' + 
                                                    '&redirect_uri={2}' + 
                                                    '&scope={3}' + 
                                                    '&prompt=consent' + 
                                                    '&access_type=offline' + 
                                                    '&include_granted_scopes=true'+
                                                    '&state={4}',
            new List<String>{
                googleAuthEndpoint, //0
                EncodingUtil.urlEncode(googleClientId, 'UTF-8'), //1
                EncodingUtil.urlEncode(googleRedirectURlStr, 'UTF-8'), //2
                EncodingUtil.urlEncode(googleCalendarScopeStr, 'UTF-8'), //3
                EncodingUtil.urlEncode(googleStateString, 'UTF-8') //4
            }
        );

        return finalRedirectUrl; 
    }

    public void createAppIntegrationRecord (String gUserId, String gUserName, String gUserEmail, String gUserDomain) {
        App_Integration__c appntegrationObj = new  App_Integration__c();
        appntegrationObj.Name = IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR;
        appntegrationObj.Connected__c = true;
        appntegrationObj.External_Id__c = gUserId;
        appntegrationObj.User_Email__c = gUserEmail;
        appntegrationObj.User_Name__c = gUserName;
        appntegrationObj.Enterprise_Id__c = gUserDomain; 
        appntegrationObj.Org_Id__c = UserInfo.getOrganizationId();
        appntegrationObj.Client_Id__c = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID;
        appntegrationObj.Client_Secret__c = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_SECRET;
        appntegrationObj.Integration_Enabled__c = true; 
        appntegrationObj.Refresh_Token_Expiration_Datetime__c = null;

        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                            App_Integration__c.Name, 
                            App_Integration__c.Connected__c,
                            App_Integration__c.External_Id__c,
                            App_Integration__c.User_Email__c,
                            App_Integration__c.User_Name__c,
                            App_Integration__c.Enterprise_Id__c,
                            App_Integration__c.Org_Id__c,
                            App_Integration__c.Client_Id__c,
                            App_Integration__c.Client_Secret__c,
                            App_Integration__c.Integration_Enabled__c,
                            App_Integration__c.Refresh_Token_Expiration_Datetime__c
                        };

        if(SimpplrContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR)) {
            appntegrationObj.id = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR).Id;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(appntegrationObj, fieldList);  
        } else {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(appntegrationObj, fieldList);                       
        }
    }
    public void createPeopleIntegrationRecord (String gUserId, String userName, String userEmail, String domain) {
        People_Integration__c peopleIntegrationObj = new  People_Integration__c();
        peopleIntegrationObj.Name = IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR;
        peopleIntegrationObj.People__c = UserContext.peopleId;
        peopleIntegrationObj.Connected__c = true;
        peopleIntegrationObj.External_Id__c = gUserId;
        peopleIntegrationObj.User_Email__c = userEmail;
        peopleIntegrationObj.User_Name__c = userName;
		peopleIntegrationObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR).id;
        peopleIntegrationObj.User__c = UserInfo.getUserID();
        if(UserContext.getCurrentUserInfo != null){
			peopleIntegrationObj.OwnerId = UserContext.getCurrentUserInfo.User__c;
		}	
        peopleIntegrationObj.Domain__c = domain;
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                        People_Integration__c.Name, 
                        People_Integration__c.People__c,
                        People_Integration__c.Connected__c,
                        People_Integration__c.External_Id__c,
                        People_Integration__c.User_Email__c,
                        People_Integration__c.User_Name__c,
                        People_Integration__c.App_Integration__c,
                        People_Integration__c.User__c,                           
                        People_Integration__c.OwnerId,
                        People_Integration__c.Domain__c             
                    };
        if(UserContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR)) {
            peopleIntegrationObj.id = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR).Id;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(peopleIntegrationObj, fieldList);
        } else {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(peopleIntegrationObj, fieldList);      
        }
    }

    public Map<String, Object> getEventsSearchResults (Criteria.Event eventCriteriaObjArg) {
    	logger.logDebug('GoogleCalendarHelper.getEventsSearchResults()----eventCriteriaObjArg----' + eventCriteriaObjArg);
        Integer recordLimit = eventCriteriaObjArg.size;	
        String requestId = UserInfo.getOrganizationId() + '-' + UserInfo.getUserId() + '-' + System.currentTimeMillis();
        HttpRequest reqObj = new HttpRequest();
		reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/gsuite/calendar-event-manager?action=getEventList');
		reqObj.setTimeout(60000);
		reqObj.setHeader('content-type','application/json');
        reqObj.setHeader('accept', 'application/json');
        reqObj.setHeader('x-simpplr-request-id', requestId);
        reqObj.setHeader('simpplr-dri', Utility.getSimpDri());
		reqObj.setMethod('POST');
        Map<String, Object> requestMap = new Map<String, Object>();
		requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('peopleId', UserContext.peopleId);
        requestMap.put('calendarId', eventCriteriaObjArg.calendarId);
        requestMap.put('term', eventCriteriaObjArg.term);
        requestMap.put('size', recordLimit);          
        requestMap.putAll(getTimeConditionMap(eventCriteriaObjArg.period));    
		requestMap.put('nextPageToken', eventCriteriaObjArg.nextPageToken == null ? '0' : eventCriteriaObjArg.nextPageToken);		
        reqObj.setBody(Json.serialize(requestMap));
        logger.logDebug('GoogleCalendarHelper.getEventsSearchResults()----requestId----' + requestId);
		logger.logDebug('GoogleCalendarHelper.getEventsSearchResults()----Request Body----' + reqObj.getBody());
		Http httpObj = new Http();
		HTTPResponse resObj = httpObj.send(reqObj);
        logger.logDebug('GoogleCalendarHelper.getEventsSearchResults()----Response Body----' + resObj.getBody());
        Map<String, Object> resultMap = new Map<String, Object>();
        if(resObj.getStatusCode() == 200) {
            GoogleCalendarWrapper.EventsResponseWrpper resultObj = GoogleCalendarWrapper.parseEventsResponseWrpper(resObj.getBody());
            resultMap.put('listOfItems', convertToListOfContentWrapper(resultObj));
            resultMap.put('nextPageToken', resultObj.nextPageToken);
        } else {
            throw new SimpplrException(ExceptionCode.UNEXPECTED_ERROR.name());
        }	
        
		return resultMap;
    }

    private List<ContentWrapper> convertToListOfContentWrapper(GoogleCalendarWrapper.EventsResponseWrpper responseWrapper) {
        List<ContentWrapper> contentWrapperList = new List<ContentWrapper>();
        if(responseWrapper.items.isEmpty())return contentWrapperList;
        TimeZone tz = Timezone.getTimeZone(responseWrapper.timezone);
        String timezoneName = Utility.timezoneIdToDisplayLabel(responseWrapper.timezone);
        for(GoogleCalendarWrapper.EventWrapper eventDetails : responseWrapper.items) {
            ContentWrapper wrapperObj = new ContentWrapper();
            wrapperObj.id = eventDetails.id;
            wrapperObj.type = 'googleCalendarEvent';
            wrapperObj.excerpt = eventDetails.description;
            wrapperObj.url = eventDetails.htmlLink;
            if(eventDetails.start.date_z != null) {
                wrapperObj.isAllDay = true; 
                wrapperObj.isMultiDay = eventDetails.end_z == null ? false : true;
                wrapperObj.startsAt = Utility.timezoneSecificDateToMomentJSDateTime(eventDetails.start.date_z, tz);            
                if(eventDetails.end_z == null) {
                    Date endDate = eventDetails.start.date_z.addDays(1);
                    wrapperObj.endsAt = Utility.timezoneSecificDateToMomentJSDateTime(endDate, tz);
                } else { 
                    Date endDate = eventDetails.end_z.date_z;
                    String endDateStr =  Utility.timezoneSecificDateToMomentJSDateTime(endDate, tz);
                    DateTime dtime = Utility.momentJSDateTimeStringToDateTime(endDateStr).addSeconds(-1);
                    wrapperObj.endsAt =  Utility.dateTimeToMomentJSDateTime(dtime); 
                }
            } else {
                wrapperObj.isAllDay = false;
                wrapperObj.isMultiDay = !eventDetails.start.dateTime_z.isSameDay(eventDetails.end_z.dateTime_z);
                wrapperObj.startsAt = Utility.dateTimeToMomentJSDateTime(eventDetails.start.dateTime_z);
                wrapperObj.endsAt = Utility.dateTimeToMomentJSDateTime(eventDetails.end_z.dateTime_z);
            }
            
            wrapperObj.timezoneName = timezoneName;
            wrapperObj.timezoneIso = tz.getID();
            wrapperObj.timezoneOffset = tz.getOffset(system.today());
            wrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(eventDetails.created);
            wrapperObj.publishAt = wrapperObj.createdAt;
            wrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(eventDetails.updated);
            wrapperObj.authoredBy.email = eventDetails?.creator?.email;
            wrapperObj.title = !String.isNotBlank(eventDetails.summary) && !String.isNotBlank(wrapperObj.authoredBy.email) && 'private'.equalsIgnoreCase(eventDetails.visibility) ? 'Details unavailable' : eventDetails.summary;
            contentWrapperList.add(wrapperObj);
        }
        return contentWrapperList;
    }

    private Map<String, Object> getTimeConditionMap(String period) {
        Map<String, Object> timeConditionMap = new Map<String, Object>();
        DateTime currentTime = DateTime.now();
        Date weekEndDate = (Date.today()).addDays(mapOfDayWithNumberOfDaysToAdd.get(currentTime.format('EEE')));
        DateTime startDateTimeOfNextWeek = DateTime.newInstance(weekEndDate.addDays(1).year(),weekEndDate.addDays(1).month(),weekEndDate.addDays(1).day(),0,0,0);
        DateTime nextWeekEndDate = startDateTimeOfNextWeek.addDays(6);
        DateTime endDateTimeOfNextweek = DateTime.newInstance(startDateTimeOfNextWeek.addDays(6).year(),startDateTimeOfNextWeek.addDays(6).month(),startDateTimeOfNextWeek.addDays(6).day(),23,59,59);
        DateTime startTime;
        DateTime endTime;
        String dateTimeFormat = 'yyyy-MM-dd\'T\'HH:mm:ss';
            
        if('this_week'.equalsIgnoreCase(period)) {
            endTime = DateTime.newInstance(weekEndDate.year(),weekEndDate.month(),weekEndDate.day(),23,59,59);
            timeConditionMap.put('timeMin', currentTime.formatGMT(dateTimeFormat) + 'Z');
            timeConditionMap.put('timeMax', endTime.formatGMT(dateTimeFormat) + 'Z');

        }else if('next_week'.equalsIgnoreCase(period)) {
            timeConditionMap.put('timeMin', startDateTimeOfNextWeek.formatGMT(dateTimeFormat) + 'Z');
            timeConditionMap.put('timeMax', endDateTimeOfNextweek.formatGMT(dateTimeFormat) + 'Z');
        
        }else if('this_month'.equalsIgnoreCase(period)) {
            startTime = DateTime.newInstance(nextWeekEndDate.addDays(1).year(),nextWeekEndDate.addDays(1).month(),nextWeekEndDate.addDays(1).day(),0,0,0);
            endTime = DateTime.newInstance(currentTime.year(),currentTime.month(),Date.daysInMonth(currentTime.year(),currentTime.month()),23,59,59);
            timeConditionMap.put('timeMin', startTime.formatGMT(dateTimeFormat) + 'Z');
            timeConditionMap.put('timeMax', endTime.formatGMT(dateTimeFormat) + 'Z');
        
        }else if('after_this_month'.equalsIgnoreCase(period)) {
            DateTime startDateAfterNextWeekEndDate = nextWeekEndDate.addDays(1);
            startTime = DateTime.newInstance(startDateAfterNextWeekEndDate.year(),startDateAfterNextWeekEndDate.month(),startDateAfterNextWeekEndDate.day(),0,0,0);
            timeConditionMap.put('timeMin', startTime.formatGMT(dateTimeFormat) + 'Z');
            
        } else {
            timeConditionMap.put('timeMin', currentTime.formatGMT(dateTimeFormat) + 'Z');
        }
        return timeConditionMap;    
    }

    public List<FilterAttributeWrapper> getGoogleCalendars() {
        List<FilterAttributeWrapper> calendarList = new List<FilterAttributeWrapper>();        
        String endPoint = SimpplrContext.simpplrAPIEndpoint+'/gsuite/calendar-manager?action=getCalenders';        
        Map<String, Object> requestMap = new Map<String, Object>();
		requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('peopleId', UserContext.peopleId);
		HTTPResponse resObj = getResponseFromAWS(endPoint, requestMap);
        GoogleCalendarWrapper.CalendarResponseWrpper resultObj = (GoogleCalendarWrapper.CalendarResponseWrpper) JSON.deserialize(resObj.getBody(), GoogleCalendarWrapper.CalendarResponseWrpper.class);
        for(GoogleCalendarWrapper.CalendarWrapper calenderObj : resultObj.items) {
            FilterAttributeWrapper wrapperObj = new FilterAttributeWrapper();
            wrapperObj.id = calenderObj.id;
            wrapperObj.name = calenderObj.summary;
            calendarList.add(wrapperObj);
        }
        calendarList.sort();        
        return calendarList;
    }

    public void disconnectGoogleCalendarAdmin() {
        String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager?action=disconnectGoogleCalendarAdmin';
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        logger.logDebug('GoogleCalendarHelper.disconnectGoogleCalendarAdmin()----request body----' + mapOfRequestParam);
        getResponseFromAWS(endpointURL, mapOfRequestParam);  

    }

    public void disconnectGoogleCalendarPeople() {
        String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager?action=disconnectGoogleCalendarPeople';
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);        
        logger.logDebug('GoogleCalendarHelper.disconnectGoogleCalendarPeople()----request body----' + mapOfRequestParam);
        getResponseFromAWS(endpointURL, mapOfRequestParam);  

    }

    private HttpResponse getResponseFromAWS(String endpoint, Object body) {
        String requestId = UserInfo.getOrganizationId() + '-' + UserInfo.getUserId() + '-' + System.currentTimeMillis();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-simpplr-request-id', requestId);
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setTimeout(60000);
        req.setBody(Json.serialize(body));
        Http http = new Http();
        HttpResponse response = http.send(req);
        logger.logDebug('GoogleCalendarHelper.getResponseFromAWS()----endpoint----' + endpoint);
        logger.logDebug('GoogleCalendarHelper.getResponseFromAWS()----response body----' + response.getBody());
        if(response.getStatusCode() != 200) {
            logger.logDebug('GoogleCalendarHelper.getResponseFromAWS()----response status code----' + response.getStatusCode());
            throw new SimpplrException(ExceptionCode.UNEXPECTED_ERROR.name());
        }
        return response;
    }
    
}