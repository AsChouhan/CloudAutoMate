/**
* Class BatchCheckUserTwitterIntegration
* Purpose:  Batch to authenticate user's twitter integration token if the token is invalid 
* disconnect twitter and send email to users
*
*/
public with sharing class BatchCheckUserTwitterIntegration implements Database.Batchable<SObject>,Database.AllowsCallouts, Database.Stateful{
    public String query;
    public String integrationType;
    public Exception exceptionDetailsObj;
    public Boolean runNext;
    public static final String TWITTER = 'Twitter';
    public static final String API_URL = 'https://api.twitter.com/1.1/account/verify_credentials.json';
    public static final String OAUTH_VERSION = 'oauth_version';
    public static final String OAUTH_NONCE = 'oauth_nonce';
    public static final String OAUTH_TIMESTAMP = 'oauth_timestamp';
    public static final String OAUTH_CONSUMER_KEY = 'oauth_consumer_key';
    public static final String OAUTH_SIGNATURE_METHOD = 'oauth_signature_method';
    public static final String OAUTH_TOKEN = 'oauth_token';
    public static final String HTTP_METHOD = 'httpMethod';
    public static final String CONSUMER_SECRET = 'consumerSecret';
    public static final String OAUTH_SIGNATURE = 'oauth_signature';
    public static final String SECRET_KEY = 'secret';

    public BatchCheckUserTwitterIntegration(Boolean runNext) {
        String integrationType = IntegrationConstants.INTEGRATION_TYPE_TWITTER;
        this.integrationType = integrationType;
        this.runNext = runNext;
        String query;
        if(SimpplrContext.isTwitterConnected){
            query =  ' SELECT Id,Access_Token__c,Access_Token_Secret__c,People__c,People__r.User__c,';
            query += ' App_Integration__r.Client_Id__c,App_Integration__r.Client_Secret__c';
            query += ' FROM People_Integration__c WHERE Active__c = TRUE AND';
            query += ' Is_Deleted__c = FALSE AND App_Integration__r.Name =:integrationType';
        }
        else{
            query = 'SELECT Id from People_Integration__c where Id = null';
        }
        this.query=query;
    }

    public database.querylocator start(Database.BatchableContext bc){
    	return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<People_Integration__c> peopleIntList){
    	try{
			Set<Id> peopleIds = new Set<Id>();
            List<People_Integration__c> disconnectList = validateTwitterToken(peopleIntList);
            for(People_Integration__c peopleInt : disconnectList){
                peopleIds.add(peopleInt.People__c);
            }
            if(disconnectList.size()>0){
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().deleteAsUser(disconnectList);
            } 
            if(peopleIds.size()>0){
                NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(peopleIds,TWITTER);
            }
    	}catch(Exception ex){
    		exceptionDetailsObj =  ex;
    		throw ex;
    	}
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob currentJob = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, 
        TotalJobItems, CreatedBy.Email, ExtendedStatus 
        FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        Boolean canStartNextBatch = false;
        if(currentJob.Status.equalsIgnoreCase(IntegrationConstants.COMPLETED) && currentJob.NumberOfErrors == 0) {
            canStartNextBatch = true;
        } else {
            Utility.sendExceptionEmail(BatchCheckUserTwitterIntegration.class.getName(), exceptionDetailsObj);
        }
        if(runNext){
            CheckUserConfluenceIntegration.callConfluenceLambda(runNext);
        }
    }

    /**
     * @description check whether twitter auth token is valid or not
     * @param peopleIntList
	 * @return List<People_Integration__c> to disconnect/delete
     */
    public List<People_Integration__c> validateTwitterToken(List<People_Integration__c> peopleIntList){
        List<People_Integration__c> disconnectList = new List<People_Integration__c>();
        Map<Id,People_Integration__c> updateMap = new Map<Id,People_Integration__c>();
        try{
            for(People_Integration__c peopleInt : peopleIntList){
                HttpResponse resObj = makeCallout(peopleInt);
                if (resObj.getStatusCode()== 200) { 
                    String resBodyJSON = resObj.getBody();
                    Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyJSON);
                    if(String.isBlank(String.valueOf(resBody.get('name')))) {
                        disconnectList.add(peopleInt);
                    }
                }
                else{
                    disconnectList.add(peopleInt);
                }  
            }
        }
        catch(Exception ex){
            exceptionDetailsObj =  ex;
            throw ex;
        }
        return disconnectList;
    }

    /**
     * @description generate auth header for twitter callout
     * @param peopleInt people integration record
	 * @return String auth header
     */
    public String generateTwitterAuthorisationString(People_Integration__c peopleInt){
		String headerString = '';
        String token = peopleInt.Access_Token__c;
        String secret = peopleInt.Access_Token_Secret__c;
        String consumerKey = peopleInt.App_Integration__r.Client_Id__c;
        String consumerSecret = peopleInt.App_Integration__r.Client_Secret__c;
        String signature = '';
        Map<String, String> twitterSignatureMap = new Map<String, String>();
        String timestamp = String.valueOf(DateTime.now().getTime()/1000); 
        String nonce = String.valueOf(UserInfo.getUserId() + String.valueOf(DateTime.now().getTime()));
        Map<String, String> oauth_params = new Map<String, String>(); //store oauth params for signature generation   
        oauth_params.put(EncodingUtil.urlEncode(OAUTH_VERSION, IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode('1.0', IntegrationConstants.CHARSET_UTF8));
        oauth_params.put(EncodingUtil.urlEncode(OAUTH_NONCE, IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(nonce, IntegrationConstants.CHARSET_UTF8));
        oauth_params.put(EncodingUtil.urlEncode(OAUTH_TIMESTAMP, IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(timestamp, IntegrationConstants.CHARSET_UTF8));
        oauth_params.put(EncodingUtil.urlEncode(OAUTH_CONSUMER_KEY, IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(consumerKey, IntegrationConstants.CHARSET_UTF8));
        oauth_params.put(EncodingUtil.urlEncode(OAUTH_SIGNATURE_METHOD, IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode('HMAC-SHA1', IntegrationConstants.CHARSET_UTF8));
        oauth_params.put(EncodingUtil.urlEncode(OAUTH_TOKEN, IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(token, IntegrationConstants.CHARSET_UTF8));
        twitterSignatureMap.put(HTTP_METHOD, IntegrationConstants.GET_REQUEST_TYPE);
        twitterSignatureMap.put(SECRET_KEY, secret);
        twitterSignatureMap.put(CONSUMER_SECRET, consumerSecret);
        signature = generateTwitterSignatureString(twitterSignatureMap, oauth_params);
        if(String.isNotBlank(signature)){
            oauth_params.put(EncodingUtil.urlEncode(OAUTH_SIGNATURE, IntegrationConstants.CHARSET_UTF8), EncodingUtil.urlEncode(signature, IntegrationConstants.CHARSET_UTF8));
        }
        headerString = 'OAuth ';
        for(String paramKey : oauth_params.keySet()) {
            headerString += paramKey + '="' + oauth_params.get(paramkey) + '", ';
        }
		return headerString;	
	} 

    /**
     * @description generate encrypted signature for auth header
     * @param twitterSignatureMap parameters needed to generate signature
     * @param oauth_params parameters needed to generate signature
	 * @return String signature
     */
    public String generateTwitterSignatureString(Map<String, String> twitterSignatureMap, Map<String, String> oauth_params) { 
	    Blob signature;	
        String httpMethod = twitterSignatureMap.containsKey(HTTP_METHOD)?twitterSignatureMap.get(HTTP_METHOD):'';
        String secret = twitterSignatureMap.containsKey(SECRET_KEY)?twitterSignatureMap.get(SECRET_KEY):'';
        String consumerSecret = twitterSignatureMap.containsKey(CONSUMER_SECRET)?twitterSignatureMap.get(CONSUMER_SECRET):'';
        String signatureBase = API_URL;
        signatureBase = httpMethod.toUpperCase() + '&' + EncodingUtil.urlEncode(signatureBase, IntegrationConstants.CHARSET_UTF8) + '&';
        //sort parameters  before appending to signature 
        List<string> sortParams = new List<string>(oauth_params.keySet());
        sortParams.sort();
        String paramString = '';
        //append all the params for signature
        for(String param_key : sortParams) {
            paramString += param_key + '=' + oauth_params.get(param_key) + '&';
        }
        paramString = paramString.removeEndIgnoreCase('&');
        signatureBase += EncodingUtil.urlEncode(paramString, IntegrationConstants.CHARSET_UTF8);
        String signatureKey = EncodingUtil.urlEncode(consumerSecret, IntegrationConstants.CHARSET_UTF8) + '&' + (String.isNotBlank(secret)? EncodingUtil.urlEncode(secret, IntegrationConstants.CHARSET_UTF8):'');
        signature = Crypto.generateMac('HmacSHA1', Blob.valueOf(signatureBase), Blob.valueOf(signatureKey));
	    return EncodingUtil.base64Encode(signature);
	}

    /**
     * @description make api callout to validate twitter token
     * @param  peopleInt  People_Integration__c record
	 * @return HttpResponse of request
     */
    public HttpResponse makeCallout(People_Integration__c peopleInt){
        HttpResponse resObj;
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            String authorisationString = generateTwitterAuthorisationString(peopleInt);
            String endPoint = API_URL;
            req.setEndpoint(endPoint);
            req.setHeader(IntegrationConstants.AUTHORIZATION, authorisationString);
            req.setHeader(IntegrationConstants.CONTENT_TYPE, IntegrationConstants.CONTNENT_TYPE_JSON);
            req.setMethod(IntegrationConstants.GET_REQUEST_TYPE);
            req.setTimeout(120000);
            resObj = http.send(req);
        }
        catch(Exception ex){
            exceptionDetailsObj =  ex;
            throw ex;
        }
        return resObj;
    }
}