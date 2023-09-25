public with sharing class OutlookCalendarHelper {

    public static final String OUTLOOK_SAVE_DOMAIN_ENPOINT = SimpplrContext.simpplrAPIEndpoint + '/outlook/v1/calendar/update-app-integration';
    public static final String OUTLOOK_VERIFY_USER_CONNECTION = SimpplrContext.simpplrAPIEndpoint + '/outlook/v1/calendar/verify-user-connection';
    public static final String JWT_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/jwt';
    public static final String OUTLOOK_DISCONNECT_USER_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/outlook/v1/calendar/disconnect-user';
    public static final String BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION = 'removeDomainPeopleIntegration';
    
    public void disconnectOutlookCalendarPeople() {
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);        
        logger.logDebug('OutlookCalendarHelper.disconnectOutlookCalendarPeople()----request body----' + mapOfRequestParam);
        getResponseFromOutlookMS(OUTLOOK_DISCONNECT_USER_ENDPOINT, mapOfRequestParam, IntegrationConstants.POST_REQUEST_TYPE);  

    }

    public HttpResponse getResponseFromOutlookMS(String endpoint, Object body, String method) {
        HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);     
        req.setHeader('jwttoken', Utility.getJwtToken());
        req.setMethod(method);
        req.setTimeout(60000);
        if(body != null) {
            req.setHeader('Content-Type', 'application/json');   
            req.setBody(Json.serialize(body));
        }
        Http http = new Http();
        HttpResponse response = http.send(req);
		logger.logDebug('OutlookCalendarHelper.getResponseFromOutlookMS()----endpoint----' + endpoint);
		logger.logDebug('OutlookCalendarHelper.getResponseFromOutlookMS()----request body----' + body);
        logger.logDebug('OutlookCalendarHelper.getResponseFromOutlookMS()----response body----' + response.getBody());
        if (response.getStatusCode() != 200) {
            throw new SimpplrException(ExceptionCode.UNEXPECTED_ERROR.name());
        }
        return response;                
    }   

    public HttpResponse saveOutlookManageAppInfo(Boolean outlookEnabled, List<String> listOfDomains) {
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('outlookEnabled', outlookEnabled);
        requestBody.put('outlookDomainList', listOfDomains);

        HttpResponse res = getResponseFromOutlookMS(OUTLOOK_SAVE_DOMAIN_ENPOINT, requestBody, IntegrationConstants.POST_REQUEST_TYPE);
        return res;
    }

    public void createPeopleIntegrationRecord (String userEmail, String userName, String externalId, String domain) {
        
        People_Integration__c peopleIntegrationObj = new  People_Integration__c();
        peopleIntegrationObj.Name = IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR;
        peopleIntegrationObj.People__c = UserContext.peopleId;
        peopleIntegrationObj.Connected__c = true;
        peopleIntegrationObj.User_Email__c = userEmail;
        peopleIntegrationObj.User_Name__c = userName;
        peopleIntegrationObj.External_Id__c =  externalId;
        peopleIntegrationObj.Domain__c = domain;
        peopleIntegrationObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR).id;
        peopleIntegrationObj.User__c = UserInfo.getUserID();
        if(UserContext.getCurrentUserInfo != null){
            peopleIntegrationObj.OwnerId = UserContext.getCurrentUserInfo.User__c;
        }	
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                        People_Integration__c.Name, 
                        People_Integration__c.People__c,
                        People_Integration__c.Connected__c,
                        People_Integration__c.User_Email__c,
                        People_Integration__c.App_Integration__c,
                        People_Integration__c.User__c,                           
                        People_Integration__c.OwnerId,
                        People_Integration__c.User_Name__c,
                        People_Integration__c.External_Id__c,
                        People_Integration__c.Domain__c
                    };
        if(UserContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR)) {
            peopleIntegrationObj.id = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR).Id;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(peopleIntegrationObj, fieldList);
        } else {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(peopleIntegrationObj, fieldList);      
        }	        
    }

    public Map<String, String> verifyAndGetUserDetails () { 

        Map<String, String> userProfileMap = null;
        HttpResponse res = getResponseFromOutlookMS(OUTLOOK_VERIFY_USER_CONNECTION, null, IntegrationConstants.GET_REQUEST_TYPE);
        Map<String, Object> resBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        if(resBodyMap.get('result') != null) {
            userProfileMap = new Map<String, String>();
            Map<String, Object> resultMap = (Map<String, Object>) resBodyMap.get('result');
            userProfileMap.put('email', (String) resultMap.get('mail'));
            userProfileMap.put('userName', (String) resultMap.get('displayName'));
            userProfileMap.put('externalId', (String) resultMap.get('id'));
        }
        return userProfileMap;
    }
}