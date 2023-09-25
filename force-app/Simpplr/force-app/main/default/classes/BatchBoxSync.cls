/**
* Class BatchBoxSync
* Purpose:  Batch to refresh user's Box integration token if the token is valid 
* else disconnect Box and send email to users
*
*/
public with sharing class BatchBoxSync implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private String batchContext;
    private String accessToken;
    private String refreshToken;
    private final String BATCH_REFRESH_ADMIN_TOKEN = 'refreshAdminToken';
    private final String BATCH_REFRESH_USER_TOKEN = 'refreshUserToken';
    public Boolean runNext;

    public BatchBoxSync(String batchContext) {
        this.batchContext = batchContext;
        this.runNext = false;
    }

    public BatchBoxSync(String batchContext,Boolean runNext) {
        this.batchContext = batchContext;
        this.runNext = runNext;
    }

    public database.querylocator start(Database.BatchableContext bc) {
        String packageName = SimpplrContext.packageName;
        String query;
        if(BATCH_REFRESH_USER_TOKEN == batchContext && SimpplrContext.IsBoxIntegrationEnabled) {
            query = 'SELECT Id, People__c, Box_Enterprise_Id__c, Box_User_Id__c, Box_Username__c,'+
            'Box_Access_Token__c, Box_Refresh_Token__c , Box_Access_Token_Expires_At__c, Box_Favorite_Collection_Id__c, '+
            'Box_Refresh_Token_Expires_At__c FROM People_Preference__c WHERE Box_Refresh_Token_Expires_At__c = NEXT_N_DAYS:7 ' +
            'AND people__r.User__r.IsActive=true ';
            if(!Test.isRunningTest() && String.isNotBlank(packageName) && SimpplrContext.isSandbox == false) {
                query = query + ' AND User__c IN (SELECT userid FROM UserPackageLicense WHERE PackageLicense.NamespacePrefix =: packageName)';
            }
            query = query + ' ORDER BY Box_Refresh_Token_Expires_At__c';
        } else if(BATCH_REFRESH_ADMIN_TOKEN == batchContext && SimpplrContext.IsBoxIntegrationEnabled) {
            query = 'SELECT Id, Box_Enterprise_Id__c, Box_User_Id__c, Box_Username__c, '+
            'Box_Access_Token__c, Box_Refresh_Token__c , Box_Access_Token_Expires_At__c, '+
            'Box_Refresh_Token_Expires_At__c FROM App_Config__c limit 1';
        }
        else{
            query = 'SELECT Id from People_Preference__c where Id = null';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
        try {
            BoxService boxServiceObj = new BoxService();
            if(BATCH_REFRESH_USER_TOKEN == batchContext) {
                List<People_Preference__c> listOfPeoplePref = (List<People_Preference__c>)listOfsObject;
                refreshUserToken(listOfPeoplePref);
            } else if(BATCH_REFRESH_ADMIN_TOKEN == batchContext) {
                List<App_Config__c> listOfAppConfig = (List<App_Config__c>)listOfsObject;
                boxServiceObj.refreshAdminUserTokens(true, listOfAppConfig[0]);
            }
        } catch(Exception ex) {
            Utility.sendBatchFailedExceptionEmail('BatchBoxSync', ex);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if(BATCH_REFRESH_USER_TOKEN == batchContext) {
            App_Config__c appConfig = [select Id, Box_Refresh_Token__c , Box_Refresh_Token_Expires_At__c FROM App_Config__c limit 1];
            if (String.isNotBlank(appConfig.Box_Refresh_Token__c) && 
				(DateTime.now().addDays(7) >= appConfig.Box_Refresh_Token_Expires_At__c)) {
                
                BatchBoxSync batch = new BatchBoxSync(BATCH_REFRESH_ADMIN_TOKEN);
                Database.executeBatch(batch);
            }
            if(runNext){
                BatchCheckUserSlackIntegration slackBatch = new BatchCheckUserSlackIntegration(runNext);
                Database.executeBatch(slackBatch, 100);
            }
        }
    }

    /**
     * @description method to call refresh token method and update in db method
     * @param listOfPeoplePref
     */
    @testVisible
    private void refreshUserToken(List<People_Preference__c> listOfPeoplePref) {
        Map<String, BoxWrapper.UserTokens> userTokensObjectMap = new Map<String, BoxWrapper.UserTokens>();
        Set<Id> disconnectedPeopleIds = new Set<Id>();
        for(People_Preference__c peoplePref : listOfPeoplePref) {
            BoxWrapper.UserTokens userTokensObj = new BoxWrapper.UserTokens();
            if (String.isNotBlank(peoplePref.Box_Refresh_Token__c) && 
                (DateTime.now().addDays(7) >= peoplePref.Box_Refresh_Token_Expires_At__c)) {
                try{
                    userTokensObj = getRefreshToken(peoplePref);
                }catch(Exception ex){
                    break;
                }
                
                if(String.isNotEmpty(userTokensObj.userId)) {
                    userTokensObjectMap.put(userTokensObj.userId, userTokensObj);
                    if(String.isBlank(userTokensObj.refreshToken)){
                        disconnectedPeopleIds.add((Id)userTokensObj.userId);
                    }
                }
            }
        }
        List<String> peopleIds = new List<String>();
        peopleIds.addAll(userTokensObjectMap.keySet());
        updateUserTokensInDB(userTokensObjectMap, peopleIds,disconnectedPeopleIds);
    }

    /**
     * @description method to make callout to refresh token
     * @param peoplePreferenceObj
     * @return BoxWrapper.UserTokens
     */
    @testVisible
    private BoxWrapper.UserTokens getRefreshToken(People_Preference__c peoplePreferenceObj) {
        BoxWrapper.UserTokens returnTokenObj = new BoxWrapper.UserTokens();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://www.box.com/api/oauth2/token';
        req.setEndpoint(endPointValue);
        req.setBody('grant_type=' + EncodingUtil.urlEncode('refresh_token', 'UTF-8') +
                    '&refresh_token=' + EncodingUtil.urlEncode(peoplePreferenceObj.Box_Refresh_Token__c, 'UTF-8') +
                    '&client_id=' + EncodingUtil.urlEncode(SimpplrContext.BoxClientId, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(SimpplrContext.BoxClientSecret, 'UTF-8') );
        req.setMethod('POST');
        
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200) {
            parseAuthJSON(res.getBody());
            peoplePreferenceObj.Box_Access_Token__c = accessToken;
	        peoplePreferenceObj.Box_Refresh_Token__c = refreshToken;
            returnTokenObj = toWrapper(peoplePreferenceObj);
        } else {
            peoplePreferenceObj.Box_Access_Token__c = '';
            peoplePreferenceObj.Box_Refresh_Token__c = '';
            returnTokenObj = toWrapper(peoplePreferenceObj);
        }
        return returnTokenObj;
    }

    /**
     * @description method parse hhtp response
     * @param JSONValue
     */
    private void parseAuthJSON(string JSONValue){
        JSONParser parser = JSON.createParser(JSONValue);
        accessToken = '';
        refreshToken = '';
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if(parser.getText() == 'access_token'){
                    parser.nextToken();
                    accessToken = parser.getText();
                }
                if(parser.getText() == 'refresh_token'){
                    parser.nextToken();
                    refreshToken = parser.getText();
                }
            }
            if(accessToken != '' && refreshToken != ''){
                break;
            }
        }
    }
  
    /**
     * @description wrapper for box token
     * @param peoplePreferenceObj
     * @return BoxWrapper.UserTokens
     */
    @testVisible 
    private BoxWrapper.UserTokens toWrapper(People_Preference__c peoplePreferenceObj) {
    	BoxWrapper.UserTokens userTokensObj = new BoxWrapper.UserTokens();
    	userTokensObj.userEmail = peoplePreferenceObj.Box_Username__c;
    	userTokensObj.boxUserId = peoplePreferenceObj.Box_User_Id__c;
    	userTokensObj.userId = peoplePreferenceObj.People__c;
    	userTokensObj.accessToken = peoplePreferenceObj.Box_Access_Token__c;
    	userTokensObj.refreshToken = peoplePreferenceObj.Box_Refresh_Token__c;
    	userTokensObj.accessTokenExpiresIn = peoplePreferenceObj.Box_Access_Token_Expires_At__c;
    	userTokensObj.refreshTokenExpiresIn = peoplePreferenceObj.Box_Refresh_Token_Expires_At__c;
    	userTokensObj.enterpriseId = peoplePreferenceObj.Box_Enterprise_Id__c;
    	userTokensObj.favoriteCollectionId = peoplePreferenceObj.Box_Favorite_Collection_Id__c;
    	return userTokensObj;
    }

    /**
     * @description method to update token values in salesforce
     * @param userTokensObjectMap
     * @param peopleIds
     * @param disconnectedPeopleIds
     */
    public void updateUserTokensInDB(Map<String, BoxWrapper.UserTokens> userTokensObjectMap, List<String> peopleIds,Set<Id> disconnectedPeopleIds) {
        BoxWrapper.UserTokens wrapperObj;
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', peopleIds);
        String query = 'SELECT Id, People__c, Box_Access_Token_Expires_At__c, Box_Refresh_Token_Expires_At__c from People_Preference__c where People__c=:soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<People_Preference__c> listOfUserPreference = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        for(People_Preference__c peoplePref : listOfUserPreference) {
            wrapperObj = userTokensObjectMap.get(peoplePref.People__c);
            peoplePref.Box_Access_Token__c = wrapperObj.accessToken;
            peoplePref.Box_Refresh_Token__c = wrapperObj.refreshToken;
            if(String.isNotEmpty(wrapperObj.accessToken)) {
                peoplePref.Box_Access_Token_Expires_At__c = DateTime.now().addMinutes(55);
            }
            if(String.isNotEmpty(wrapperObj.refreshToken)) {
                peoplePref.Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(59);
            }
        }
        if(listOfUserPreference.size() > 0) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(listOfUserPreference),new List<Schema.SObjectField>{
                                                        People_Preference__c.Box_Access_Token__c, 
                                                        People_Preference__c.Box_Refresh_Token__c, 
                                                        People_Preference__c.Box_Access_Token_Expires_At__c, 
                                                        People_Preference__c.Box_Refresh_Token_Expires_At__c});
        }
        if(disconnectedPeopleIds.size()>0){
            NotificationDispatcher.userIntegrationTokenExpireSendEmailSaveLogs(disconnectedPeopleIds,'Box');
        }
    }
}