/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class AppCtrl extends BaseCtrl {
    
    /*
    *
    */
    public String getPageTitle() {
    	return  'App' + AppPageTitle;
    }
    
    public override String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
   /**
   * 
   * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
   * Parameters:
   *      parameter_name -- [Explanation of the purpose of this parameter to the method.
   *      
   * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
   */
    public PageReference init() {
	    return null;
    }
    public PageReference urlRedirection() {
        if (!SimpplrContext.isFileServiceAuthEnabled || String.isBlank(SimpplrContext.uuid)) {
            return null;
        }

        Map<String,String> jsonBody = new Map<String,String>();
        jsonBody.put('userId',UserContext.uuid);
        /* There are two calls for onboarding.  BaseTemplateCtrl , AppCtrl 
            Due to sequence if baseTemplate onboarding init method don't get called and user is not 
            onboarded then we are onboarding user here. 
        */
        if (String.isBlank(UserContext.uuid)) {
            String peopleOnboardingEndpoint = SimpplrContext.simpplrAPIEndpoint + '/people-onboarding';
            Map<String, Object> request = Utility.getPeopleOnboardingRequestBody();
            HttpResponse respPeopleOnboard = Utility.getResponseFromAWS(peopleOnboardingEndpoint, request);
            
            if (respPeopleOnboard.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(respPeopleOnboard.getBody());
               
                if (results.containsKey('peopleUuid')) {
                    jsonBody.put('userId',(String)results.get('peopleUuid'));
                }

            }   

        }

        try {
            Map<String, String> sessionMap = new Map<String, String>();

            if (!Test.isRunningTest()) {
                sessionMap = Auth.SessionManagement.getCurrentSession();
            }

            String sessionId = sessionMap.get('SessionId');
            
            Cookie storageServiceCookie = ApexPages.currentPage().getCookies().get('storage-service-redirect');
            
            if (storageServiceCookie == null || storageServiceCookie.getValue() != sessionId) {
                storageServiceCookie = new Cookie('storage-service-redirect',sessionId,'/',900,true,'None');
                ApexPages.currentPage().setCookies(new Cookie[]{storageServiceCookie});
                Map<String,String> mapOfHeaders = new Map<String,String>();
                mapOfHeaders.put('grant_type','client_credentials');
                mapOfHeaders.put('client_id',SimpplrContext.zeusClientId);
                mapOfHeaders.put('client_secret',SimpplrContext.zeusClientSecret);
                mapOfHeaders.put('account_id',SimpplrContext.uuid);
                HttpResponse res = Utility.getJsonResponseFromExternalSystem('POST',SimpplrContext.zeusMicroserviceUrl+'/v1/identity/oauth/client/token',null,JSON.serialize(mapOfHeaders));
                String body = res.getBody();
                Map<String,String> responseBodyMap = (Map<String,String>)JSON.deserialize(body, Type.forName('Map<String,String>'));
                String authCode = responseBodyMap.get('access_token');
                
                
                if (String.isBlank(jsonBody.get('userId'))) {
                    return null;
                }                
                jsonBody.put('redirectUrl',SimpplrContext.salesforceBaseUrl  + ApexPages.currentPage().getUrl());
                HttpResponse resp = Utility.getJsonResponseFromExternalSystem('POST',SimpplrContext.zeusMicroserviceUrl+'/v1/identity/fs/generateAuthCode','Bearer '+authCode,JSON.serialize(jsonBody));
                responseBodyMap = (Map<String,String>)JSON.deserialize(resp.getBody(), Type.forName('Map<String,String>'));
                authCode = responseBodyMap.get('authCode');
                string url = SimpplrContext.zeusRedirectUrl+'/fs/authorize?authCode=' + authCode;
                PageReference page = new PageReference(url);
                page.setRedirect(true);
                return page;

            } else {
                return null;
            }
        }   catch(Exception e){
            logger.logError('AppCtrl.urlRedirection()----Exception Occured----', e);
            throw new SImpplrException(ServiceConstants.ERROR_403, e);			
        }
    }
}