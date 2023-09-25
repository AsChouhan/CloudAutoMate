public with sharing class BoxService {

	private String accessToken;
	private String refreshToken;
	private String adminAccessToken;
	private String adminRefreshToken;
    private String redirectURL;
    public BoxService() {
    	redirectURL = SimpplrContext.salesforceBaseUrl  + Page.StorageSettings.getUrl() + '?type=box';
    }
     
    public BoxWrapper.UserTokens getUserTokens(Boolean updateTokenInPreferenceAllowed,String peopleId) {
    	BoxWrapper.UserTokens returnObj = new BoxWrapper.UserTokens();
		List<People_Preference__c> boxObjectList = [SELECT Id, Box_Enterprise_Id__c, Box_User_Id__c, Box_Username__c, 
				Box_Access_Token__c, Box_Refresh_Token__c , Box_Access_Token_Expires_At__c, Box_Favorite_Collection_Id__c, 
				Box_Refresh_Token_Expires_At__c FROM People_Preference__c WHERE People__c =: peopleId WITH SECURITY_ENFORCED];
    	
    	
	    if (!boxObjectList.isEmpty()) {
	    	
	        if (String.isNotBlank(boxObjectList[0].Box_Refresh_Token__c) && 
	        		(boxObjectList[0].Box_Refresh_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0) &&
	        		(String.isBlank(boxObjectList[0].Box_Access_Token__c) ||
	        		(DateTime.now().getTime() - boxObjectList[0].Box_Access_Token_Expires_At__c.getTime() > 0))) {
	        			
	        	returnObj =  refreshBoxToken(boxObjectList[0], updateTokenInPreferenceAllowed);
	        	
        	} else if(String.isNotBlank(boxObjectList[0].Box_Refresh_Token__c) && 
        			String.isNotBlank(boxObjectList[0].Box_Access_Token__c) &&
	        		(boxObjectList[0].Box_Refresh_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0) &&
	        		(boxObjectList[0].Box_Access_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0)) {
	        	
	        	returnObj =  toWrapper(boxObjectList[0], true);
	        }
	    }
        returnObj.userId = peopleId;
		
    	return returnObj;
    }
	
	public BoxWrapper.UserTokens refreshAdminUserTokens(Boolean updateTokenInPreferenceAllowed, App_config__c appConfig) {
    	BoxWrapper.UserTokens returnObj = new BoxWrapper.UserTokens();
	    if (appConfig != null) {
	        if (String.isNotBlank(appConfig.Box_Refresh_Token__c) && 
				(DateTime.now().addDays(7) >= appConfig.Box_Refresh_Token_Expires_At__c)) {

	        	returnObj =  refreshBoxAdminUserToken(appConfig, updateTokenInPreferenceAllowed);
        	}
	    }
    	return returnObj;
    }
    
    public BoxWrapper.UserTokens getBoxAdminUserTokens(Boolean updateTokenInPreferenceAllowed) {
    	BoxWrapper.UserTokens returnObj = new BoxWrapper.UserTokens();
    	
		String appConfigQuery = 'SELECT Id, Box_Enterprise_Id__c, Box_User_Id__c, Box_Username__c, ' 
										+ 'Box_Access_Token__c, Box_Refresh_Token__c , Box_Access_Token_Expires_At__c, '
										+ 'Box_Refresh_Token_Expires_At__c FROM App_Config__c Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);

	    if (!listOfAppConfig.isEmpty()) {
	    	App_config__c appConfigObj = listOfAppConfig[0];
	    	
	        if (String.isNotBlank(appConfigObj.Box_Refresh_Token__c) && 
	        		(appConfigObj.Box_Refresh_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0) &&
	        		(String.isBlank(appConfigObj.Box_Access_Token__c) ||
	        		(DateTime.now().getTime() - appConfigObj.Box_Access_Token_Expires_At__c.getTime() > 0))) {
	        			
	        	returnObj =  refreshBoxAdminUserToken(appConfigObj, updateTokenInPreferenceAllowed);
	        	
        	} else if(String.isNotBlank(appConfigObj.Box_Refresh_Token__c) && 
        			String.isNotBlank(appConfigObj.Box_Access_Token__c) &&
	        		(appConfigObj.Box_Refresh_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0) &&
	        		(appConfigObj.Box_Access_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0)) {
	        	
	        	returnObj =  toWrapper(appConfigObj, true);
	        }
	    }
		
    	return returnObj;
    }
    
    @testVisible 
    private BoxWrapper.UserTokens toWrapper(People_Preference__c peoplePreferenceObj, Boolean preferenceObjUpdated) {
    	BoxWrapper.UserTokens userTokensObj = new BoxWrapper.UserTokens();
    	userTokensObj.userEmail = peoplePreferenceObj.Box_Username__c;
    	userTokensObj.boxUserId = peoplePreferenceObj.Box_User_Id__c;
    	userTokensObj.userId = peoplePreferenceObj.Box_User_Id__c;
    	userTokensObj.accessToken = peoplePreferenceObj.Box_Access_Token__c;
    	userTokensObj.refreshToken = peoplePreferenceObj.Box_Refresh_Token__c;
    	userTokensObj.accessTokenExpiresIn = peoplePreferenceObj.Box_Access_Token_Expires_At__c;
    	userTokensObj.refreshTokenExpiresIn = peoplePreferenceObj.Box_Refresh_Token_Expires_At__c;
    	userTokensObj.enterpriseId = peoplePreferenceObj.Box_Enterprise_Id__c;
    	userTokensObj.favoriteCollectionId = peoplePreferenceObj.Box_Favorite_Collection_Id__c;
    	userTokensObj.preferenceObjUpdated = preferenceObjUpdated;
    	return userTokensObj;
    }
    
    private BoxWrapper.UserTokens toWrapper(App_Config__c appConfigObj, Boolean preferenceObjUpdated) {
    	BoxWrapper.UserTokens userTokensObj = new BoxWrapper.UserTokens();
    	userTokensObj.userEmail = appConfigObj.Box_Username__c;
    	userTokensObj.boxUserId = appConfigObj.Box_User_Id__c;
    	userTokensObj.userId = appConfigObj.Box_User_Id__c;
    	userTokensObj.accessToken = appConfigObj.Box_Access_Token__c;
    	userTokensObj.refreshToken = appConfigObj.Box_Refresh_Token__c;
    	userTokensObj.accessTokenExpiresIn = appConfigObj.Box_Access_Token_Expires_At__c;
    	userTokensObj.refreshTokenExpiresIn = appConfigObj.Box_Refresh_Token_Expires_At__c;
    	userTokensObj.enterpriseId = appConfigObj.Box_Enterprise_Id__c;
    	userTokensObj.preferenceObjUpdated = preferenceObjUpdated;
    	return userTokensObj;
    }
    @TestVisible 
    private BoxWrapper.UserTokens refreshBoxToken(People_Preference__c peoplePreferenceObj, Boolean updateTokenInPreferenceAllowed) {
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
	        returnTokenObj = toWrapper(peoplePreferenceObj, updateTokenInPreferenceAllowed);
	        if(updateTokenInPreferenceAllowed) {
	        	returnTokenObj.preferenceObjUpdated = false;
	        	updateUserTokensInDB(returnTokenObj);
	        }
        } else {
        	logger.logError('BoxService.refreshBoxToken() - ' + res.getStatusCode() + ' response received from Box while trying to refresh box user for user ' + peoplePreferenceObj);
        }
        return returnTokenObj;
    }
    @TestVisible 
    private BoxWrapper.UserTokens refreshBoxAdminUserToken(App_Config__c appConfigObj, Boolean updateTokenInPreferenceAllowed) {
    	BoxWrapper.UserTokens returnTokenObj = new BoxWrapper.UserTokens();
    	Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://www.box.com/api/oauth2/token';
        req.setEndpoint(endPointValue);
        req.setBody('grant_type=' + EncodingUtil.urlEncode('refresh_token', 'UTF-8') +
                    '&refresh_token=' + EncodingUtil.urlEncode(appConfigObj.Box_Refresh_Token__c, 'UTF-8') +
                    '&client_id=' + EncodingUtil.urlEncode(SimpplrContext.BoxClientId, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(SimpplrContext.BoxClientSecret, 'UTF-8') );
        req.setMethod('POST');
        
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200) {
	        parseAdminAuthJSON(res.getBody());
	        appConfigObj.Box_Access_Token__c = adminAccessToken;
	        appConfigObj.Box_Refresh_Token__c = adminRefreshToken;
	        returnTokenObj = toWrapper(appConfigObj, updateTokenInPreferenceAllowed);
	        if(updateTokenInPreferenceAllowed) {
	        	returnTokenObj.preferenceObjUpdated = false;
	        	updateAdminUserTokensInDB(returnTokenObj);
	        }
        } else {
        	logger.logError('BoxService.refreshBoxAdminUserToken() - ' + res.getStatusCode() + ' response received from Box while trying to refresh box admin token');
        }
        return returnTokenObj;
    }
    
    public void updateUserTokensInDB(BoxWrapper.UserTokens wrapperObj) {
    	if(String.isNotBlank(wrapperObj.accessToken) && !wrapperObj.preferenceObjUpdated) {
	    	List<People_Preference__c> listOfUserPreference = [SELECT Id from People_Preference__c where People__c=:wrapperObj.userId WITH SECURITY_ENFORCED limit 1];
			if(!listOfUserPreference.isEmpty()) {
				listOfUserPreference[0].Box_Access_Token__c = wrapperObj.accessToken;
		        listOfUserPreference[0].Box_Refresh_Token__c = wrapperObj.refreshToken;
		        listOfUserPreference[0].Box_Access_Token_Expires_At__c = DateTime.now().addMinutes(55);
		        listOfUserPreference[0].Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(59);
		        
		        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		    	SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Preference__c>(listOfUserPreference),new List<Schema.SObjectField>{
															People_Preference__c.Box_Access_Token__c, 
															People_Preference__c.Box_Refresh_Token__c, 
															People_Preference__c.Box_Access_Token_Expires_At__c, 
															People_Preference__c.Box_Refresh_Token_Expires_At__c});
			}
    	}
    }
    
    public void updateAdminUserTokensInDB(BoxWrapper.UserTokens wrapperObj) {
    	if(String.isNotBlank(wrapperObj.accessToken) && !wrapperObj.preferenceObjUpdated) {
    		App_Config__c appConfigObj = new App_Config__c();
    		appConfigObj.id = SimpplrContext.Id;
			appConfigObj.Box_Access_Token__c = wrapperObj.accessToken;
	        appConfigObj.Box_Refresh_Token__c = wrapperObj.refreshToken;
	        appConfigObj.Box_Access_Token_Expires_At__c = DateTime.now().addMinutes(55);
	        appConfigObj.Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(59);
	        
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
														App_Config__c.Box_Access_Token__c, 
														App_Config__c.Box_Refresh_Token__c, 
														App_Config__c.Box_Access_Token_Expires_At__c, 
														App_Config__c.Box_Refresh_Token_Expires_At__c});
    	}
    }
    @TestVisible
    private void storeBoxUserDetails(String peopleId) {
    	
        BoxWrapper.MiniBoxUser boxUserObj = getCurrentBoxUser(accessToken);
        String adminEnterpriseId = SimpplrContext.BoxEnterpriseId;
        if(String.isNotBlank(peopleId)) {
        	if(boxUserObj.enterprise == null || !adminEnterpriseId.equalsIgnoreCase(boxUserObj.enterprise.id)) {
        		throw new SimpplrException(BoxConstants.BOX_NON_OFFICIAL_BOX_ACCOUNT);
        	}
        }
        String boxAllComapnyGroupId = SimpplrContext.BoxAllCompanyGroupId;
		String managedPermission = SimpplrContext.boxManagedPermission;
        if(String.isNotBlank(boxAllComapnyGroupId) && String.isNotBlank(managedPermission) && 'simpplr'.equalsIgnoreCase(managedPermission)){
        	//Add current user to All Company Group Here
        	addMemberIntoAllCompanyGroup(boxUserObj.id, boxAllComapnyGroupId, true);
        }
        
        List <People_Preference__c> listOfUserPreference = [select id from People_Preference__c where People__c =:peopleId WITH SECURITY_ENFORCED];
        People_Preference__c peoplePreferenceObj;
        if( listOfUserPreference.isEmpty() ) {
        	peoplePreferenceObj = new People_Preference__c();
        } else {
        	peoplePreferenceObj = new People_Preference__c();
        	peoplePreferenceObj.id = listOfUserPreference[0].id;
        }
    	peoplePreferenceObj.Box_User_Id__c = boxUserObj.id;
        peoplePreferenceObj.Box_Access_Token__c = accessToken;
        peoplePreferenceObj.Box_Refresh_Token__c = refreshToken;
        peoplePreferenceObj.Box_Username__c = boxUserObj.login;
        peoplePreferenceObj.People__c = peopleId;
        peoplePreferenceObj.Box_Enterprise_Id__c = boxUserObj.enterprise.id;
        peoplePreferenceObj.Box_Access_Token_Expires_At__c = DateTime.now().addMinutes(55);
        peoplePreferenceObj.Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(59);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(peoplePreferenceObj, new List<Schema.SObjectField>{
			People_Preference__c.Box_User_Id__c,
			People_Preference__c.Box_Access_Token__c,
			People_Preference__c.Box_Refresh_Token__c,
			People_Preference__c.Box_Username__c,
			People_Preference__c.People__c,
			People_Preference__c.Box_Enterprise_Id__c,
			People_Preference__c.Box_Access_Token_Expires_At__c,
			People_Preference__c.Box_Refresh_Token_Expires_At__c
		});
    }
    
    public void storeBoxAdminDetails() {
        BoxWrapper.MiniBoxUser boxUserObj = getCurrentBoxUser(adminAccessToken);
        String adminEnterpriseId = SimpplrContext.BoxEnterpriseId;
        if(boxUserObj.enterprise == null || !'enterprise'.equalsIgnoreCase(boxUserObj.enterprise.type)) {
        	throw new SimpplrException(BoxConstants.BOX_NON_ENTERPRISE_ACCOUNT);
        }
        if(String.isNotBlank(adminEnterpriseId) && !adminEnterpriseId.equalsIgnoreCase(boxUserObj.enterprise.id)) {
        	throw new SimpplrException(BoxConstants.BOX_SERVICE_USER_FROM_DIFFERENT_ENTERPRISE);
        }
        String boxAllComapnyGroupId = createAllCompanyGroupInBox(adminAccessToken);
		App_Config__c apConfigObj = new App_Config__c();
		apConfigObj.Id = SimpplrContext.Id;
		apConfigObj.Box_User_Id__c = boxUserObj.id;
        apConfigObj.Box_Access_Token__c = adminAccessToken;
        apConfigObj.Box_Refresh_Token__c = adminRefreshToken;
        apConfigObj.Box_Username__c = boxUserObj.login;
        apConfigObj.Box_Enterprise_Id__c = boxUserObj.enterprise.id;
        apConfigObj.Box_Access_Token_Expires_At__c = DateTime.now().addMinutes(55);
        apConfigObj.Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(59);
		apConfigObj.Box_All_Company_Group_Id__c = boxAllComapnyGroupId;
		apConfigObj.Box_Integration_Enabled__c = true;
		apConfigObj.Box_Client_Id__c = EFSConstants.BOX_CLIENT_ID;
		apConfigObj.Box_Client_Secret__c = EFSConstants.BOX_CLIENT_SECRET;
		apConfigObj.Box_Connected_DateTime__c = DateTime.now();
		apConfigObj.Box_Managed_Permissions__c = 'simpplr';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(apConfigObj, new List<Schema.SObjectField>{
			App_Config__c.Box_User_Id__c,
			App_Config__c.Box_Access_Token__c,
			App_Config__c.Box_Refresh_Token__c,
			App_Config__c.Box_Username__c,
			App_Config__c.Box_Enterprise_Id__c,
			App_Config__c.Box_Access_Token_Expires_At__c,
			App_Config__c.Box_Refresh_Token_Expires_At__c,
			App_Config__c.Box_All_Company_Group_Id__c,
			App_Config__c.Box_Integration_Enabled__c,
			App_Config__c.Box_Client_Id__c,
			App_Config__c.Box_Client_Secret__c,
			App_Config__c.Box_Connected_DateTime__c,
			App_Config__c.Box_Managed_Permissions__c
		});
    }
    
    public String getBoxGroupIdFromDB(String simpplrSiteId, String groupType) {
    	String returnValue;
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', simpplrSiteId);
		soqlParamMap.put('soqlParam2', groupType);
    	String query = 'SELECT value__c FROM Simpplr_Metadata__c '
    			+ ' WHERE Simpplr_Site__c =:soqlParam1 AND type__C =: soqlParam2 AND Is_Deleted__c != true';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Simpplr_Metadata__c> listOfMetadataObj = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);			
    	if(!listOfMetadataObj.isEmpty()) {
    		returnValue = listOfMetadataObj[0].value__c;
    	}
    	
    	return returnValue;
    }
    
    public void clearBoxTokens(String peopleId) {
    	String query = 'select id from People_Preference__c where Box_User_Id__c != null ';
		if(String.isNotBlank(peopleId)) {
			query += 'And people__c=: peopleId';
		}
    	List <People_Preference__c> listOfUserPreference = Database.query(query);
        if( !listOfUserPreference.isEmpty() ) {
        	for(People_Preference__c peoplePreferenceObj : listOfUserPreference) {
		    	peoplePreferenceObj.Box_User_Id__c = null;
		        peoplePreferenceObj.Box_Access_Token__c = null;
		        peoplePreferenceObj.Box_Refresh_Token__c = null;
		        peoplePreferenceObj.Box_Username__c = null;
		        peoplePreferenceObj.Box_Access_Token_Expires_At__c = null;
		        peoplePreferenceObj.Box_Refresh_Token_Expires_At__c = null;
		        peoplePreferenceObj.Box_Enterprise_Id__c = null;
		        peoplePreferenceObj.Box_Favorite_Collection_Id__c = null;
        	}
	        //FLS
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,People_Preference__c>(listOfUserPreference), new List<Schema.SObjectField>{
														People_Preference__c.Box_User_Id__c, People_Preference__c.Box_Username__c,
														People_Preference__c.Box_Access_Token__c, People_Preference__c.Box_Refresh_Token__c,
														People_Preference__c.Box_Access_Token_Expires_At__c, People_Preference__c.Box_Enterprise_Id__c,
														People_Preference__c.Box_Favorite_Collection_Id__c, People_Preference__c.Box_Refresh_Token_Expires_At__c});
        }
    }
    
    public void clearBoxAdminTokens() {
    	String query;
        if(String.isNotBlank(SimpplrContext.Id)) {
        		App_config__c appConfigObj = new App_config__c(Id = SimpplrContext.Id);
		    	appConfigObj.Box_User_Id__c = null;
		        appConfigObj.Box_Username__c = null;
		        appConfigObj.Box_Enterprise_Id__c = null;
		        appConfigObj.Box_Managed_Permissions__c = null;
	        //FLS
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
														App_config__c.Box_User_Id__c, App_config__c.Box_Username__c,
														App_config__c.Box_Enterprise_Id__c,
														App_config__c.Box_Managed_Permissions__c});												
        }
    }
    
    private BoxWrapper.MiniBoxUser getCurrentBoxUser(string aToken) {
    	String jsonBody = '';
        HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET', 'https://api.box.com/2.0/users/me?fields=enterprise,login,role', 'Bearer ' + aToken,jsonBody);
        if(res.getStatusCode() != 200) {
        	throw new SimpplrException(ExceptionCode.BOX_CANNOT_GET_USER_DETAILS.name() + res.getStatusCode());
        }
        return BoxWrapper.parseBoxUser(res.getBody());
    }
    
    public void pullBoxToken(String codeFromBox, String peopleId){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://www.box.com/api/oauth2/token';
        req.setEndpoint(endPointValue);
        req.setBody('grant_type=' + EncodingUtil.urlEncode('authorization_code', 'UTF-8') +
                    '&code=' + EncodingUtil.urlEncode(codeFromBox, 'UTF-8') +
                    '&client_id=' + EncodingUtil.urlEncode(SimpplrContext.BoxClientId, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(SimpplrContext.BoxClientSecret, 'UTF-8') );
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        if(res.getStatusCode() != 200) {
        	throw new SimpplrException(ExceptionCode.BOX_CONNECTION_FAILED_WITH_STATUS.name() + res.getStatusCode());
        }
        parseAuthJSON(res.getBody());
        if(accessToken != '' && refreshToken != '') {
    		storeBoxUserDetails(peopleId);
        }
    }
    
    public void pullBoxAdminToken(String codeFromBox){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string endPointValue = 'https://www.box.com/api/oauth2/token';
        req.setEndpoint(endPointValue);
        req.setBody('grant_type=' + EncodingUtil.urlEncode('authorization_code', 'UTF-8') +
                    '&code=' + EncodingUtil.urlEncode(codeFromBox, 'UTF-8') +
                    '&client_id=' + EncodingUtil.urlEncode(EFSConstants.BOX_CLIENT_ID, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(EFSConstants.BOX_CLIENT_SECRET, 'UTF-8') );
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        if(res.getStatusCode() != 200) {
        	throw new SimpplrException(ExceptionCode.BOX_CONNECTION_FAILED_WITH_STATUS.name() + res.getStatusCode());
        }
        parseAdminAuthJSON(res.getBody());
        if(adminAccessToken != '' && adminRefreshToken != '') {
    		storeBoxAdminDetails();
        }
    }
    
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
    
    private void parseAdminAuthJSON(string JSONValue){
        JSONParser parser = JSON.createParser(JSONValue);
        adminAccessToken = '';
        adminRefreshToken = '';
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                if(parser.getText() == 'access_token'){
                    parser.nextToken();
                    adminAccessToken = parser.getText();
                }
                if(parser.getText() == 'refresh_token'){
                    parser.nextToken();
                    adminRefreshToken = parser.getText();
                }
            }
            if(adminAccessToken != '' && adminRefreshToken != ''){
                break;
            }
        }
    }
    
    //--------------------
    public Object getFolderDetails(String folderId,String apiAccessToken,Map<String,Object> paramMap) {
    	String queryString = '';
    	Object returnObject;
    	List<String> queryParamList = new List<String>();
    	if(paramMap != null && paramMap.size() > 0){
    		for(String key : paramMap.keyset()){
    			Object value = paramMap.get(key);
    			if(value instanceof List<String>){
    				List<String> valueList = (List<String>)value;
    				if(valueList.size() > 0){
			    		String valueString = String.join(valueList,',');
			    		queryString = key+'='+valueString;
			    	}
    			}else{
    				queryString = key+'='+value;
    			}
    			queryParamList.add(queryString);
    		}
			if(queryParamList.size() > 0){
				queryString = '?'+String.join(queryParamList,'&');
			}else{
				queryString = '';
			} 
			  		
    	}
    	
        HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,BoxConstants.BOX_HOST+'/'+BoxConstants.BOX_GROUP_FOLDER_REQUEST_URL+'/'+folderId+'/items'+queryString +'&limit=1000', 'Bearer ' + apiAccessToken,null);
        if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
			returnObject = (BoxWrapper.createFolderWrapper)JSON.deserialize(res.getBody(), BoxWrapper.createFolderWrapper.class);
		}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
			if(!String.isBlank(res.getBody())){
				returnObject =  BoxWrapper.parseErrorInfo(res.getBody());
				
			}else{
				returnObject = ServiceConstants.UNEXPECTED_ERROR;
			}
		}else{
			returnObject =  ServiceConstants.UNEXPECTED_ERROR;
		}
        
        return returnObject;
    }
    
    public BoxWrapper.FolderFile getBoxFileDetails(String fileId, String apiAccessToken) {
    	BoxWrapper.FolderFile folderFileObj;
    	string jsonBody = '';
        HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET','https://api.box.com/2.0/files/'+fileId+'?fields=id,type,file_version,name,description,size,path_collection,created_by,modified_by,owned_by,shared_link,parent,item_status,item_collection,created_at,modified_at,shared_link,version_number,permissions,tags,path_collection/content','Bearer ' + apiAccessToken,jsonBody);
    	folderFileObj = BoxWrapper.parseFolderFIle(res.getBody());
    	if('error'.equalsIgnoreCase(folderFileObj.type)){
    		throw new SimpplrException(BoxConstants.BOX_UNAUTHORIZED_USER);
    	}
    	return folderFileObj;
    }
        
    public Boolean deleteBoxFile(String fileId, String etag, String apiAccessToken){
    	string jsonBody = '';
    	Map<String,String> mapOfHeaders=new Map<String,String>();
    	mapOfHeaders.put('If-Match', etag);
        HttpResponse res = Utility.getJsonResponseFromExternalSystem('DELETE','https://api.box.com/2.0/files/'+fileId,'Bearer ' +  apiAccessToken,jsonBody,mapOfHeaders);
        Integer responseCode=res.getStatusCode();
        return (responseCode==204); //204 is returned if file is deleted successfully else "412 Precondition Failed" is returned
    }
    
    @TestVisible 
    public String getPeopleIdFromBoxUserId(String boxUserId) {
    	String peopleId = null;
    	
    	List<People_Preference__c> listOfPeoplePreferences = [select id, People__c from People_Preference__c where Box_User_Id__c = :boxUserId WITH SECURITY_ENFORCED LIMIT 1];
    	
    	if(listOfPeoplePreferences.isEmpty() == false) {
    		peopleId = listOfPeoplePreferences[0].People__c;
    	}
    	
    	return peopleId;
    }
    
    @TestVisible 
    private List<FileListingWrapper> toFileListingWrapperList(List<BoxWrapper.MiniFolderFile> listOfMiniBoxFolderFile, String rootFolderIds,String boxUserId) {

    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper> ();
		String query = 'select id, People__r.Full_Name__c, Box_User_Id__c, People__c,Box_Username__c from People_Preference__c where Box_User_Id__c!=null';
    	Map<string,People_Preference__c> mapOfBoxIdAndUserId = new Map<string,People_Preference__c>();
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People_Preference__c> listOfPeoplePreferences = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
    	for(People_Preference__c preferenceObj : listOfPeoplePreferences){
    		mapOfBoxIdAndUserId.put(preferenceObj.Box_User_Id__c, preferenceObj);
    	}
    	
    	FileListingWrapper fileListWrapObj;
    	for(BoxWrapper.MiniFolderFile miniFolderFileObj: listOfMiniBoxFolderFile) {    
    		if(boxUserId!=null && !boxUserId.equalsIgnoreCase(miniFolderFileObj.created_by.id)){
    			continue;
    		}		
			fileListWrapObj = new FileListingWrapper();
			fileListWrapObj.id = miniFolderFileObj.id;
			fileListWrapObj.fileId = miniFolderFileObj.id;
			fileListWrapObj.externalFileId = miniFolderFileObj.id;
			if(miniFolderFileObj.modified_at != NULL) {
				fileListWrapObj.modifiedAt = miniFolderFileObj.modified_at.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			}
			fileListWrapObj.modifiedAtDateTime = miniFolderFileObj.modified_at;	
			BoxWrapper.MiniBoxUser boxUserObj;
			if(miniFolderFileObj.modified_by != null) {
				boxUserObj = miniFolderFileObj.modified_by;
			} else {
				boxUserObj = miniFolderFileObj.created_by;
			}
			if(boxUserObj != null) {
				if(mapOfBoxIdAndUserId.containsKey(boxUserObj.id)) {
					People_Preference__c peoplePreferenceObj = mapOfBoxIdAndUserId.get(boxUserObj.id);
					fileListWrapObj.owner.Id = peoplePreferenceObj.People__c;
					fileListWrapObj.owner.Name = peoplePreferenceObj.People__r.Full_Name__c;
					fileListWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + peoplePreferenceObj.Id;
				} else {
					fileListWrapObj.owner.Id = boxUserObj.id;
					fileListWrapObj.owner.Name = boxUserObj.name;
				}
			}
				
			if(miniFolderFileObj.type == 'folder'){
				fileListWrapObj.isFolder = 1;
				fileListWrapObj.isDir = true;
				fileListWrapObj.title = miniFolderFileObj.name;
				fileListWrapObj.type = 'Folder';
			} else{
				fileListWrapObj.isFolder = 0;
				fileListWrapObj.isDir = false;
				fileListWrapObj.context = 'Box';
				fileListWrapObj.title = miniFolderFileObj.name;
				fileListWrapObj.type = fileListWrapObj.title.substring(fileListWrapObj.title.lastIndexOf('.')+1).toUpperCase();
				fileListWrapObj.fileExtension = fileListWrapObj.title.substring(fileListWrapObj.title.lastIndexOf('.')+1).toUpperCase();
				fileListWrapObj.isDownloadableOniOS = Utility.isDownloadableOniOS(fileListWrapObj.type, 'BOX');
			}
			
			listOfFileWrapper.add(fileListWrapObj);
	    }
	    return listOfFileWrapper;
    }

    public Folder__c linkFolder(String folderId, String folderName, Criteria.OwnerWrapper owner, 
    		String permissions, String simpplrSiteId, String collaborationIdJson) {
		Boolean alreadyLinked = isFolderAlreadyLinked(folderId, simpplrSiteId);
		
		if(alreadyLinked) {
			throw new SimpplrException(BoxConstants.BOX_FOLDER_ALREADY_LINKED);
		}else {
			String systemBoxFolderName = EFSConstants.EFS_SYSTEM_FOLDERS_MAP.get('box');
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', simpplrSiteId);
			soqlParamMap.put('soqlParam2', systemBoxFolderName);
			String folderQuery = 'SELECT id from Folder__c WHERE Site__c = :soqlParam1 AND Is_System_Folder__c = true AND name__c = :soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> siteSystemBoxFolderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
			
    		Folder__c folderObj = new Folder__c();
	        folderObj.External_Folder_Id__c = folderId;
	        folderObj.Name__c = folderName;
	        folderObj.Type__c = BoxConstants.BOX_FOLDER_TYPE_LABEL;
	        folderObj.Permissions__c = permissions;
	        folderObj.Site__c = simpplrSiteId;
	        folderObj.Box_Collaboration_Id__c = collaborationIdJson;
	        
	        if(!siteSystemBoxFolderList.isEmpty()) {
	        		folderObj.Parent_Folder__c = siteSystemBoxFolderList[0].Id;
	        }
	        
	        if(owner != null) {
				if(String.isNotBlank(owner.id)) {
					folderObj.People__c = getPeopleIdFromBoxUserId(owner.id);
				} 
				
				if(String.isBlank(owner.id) || folderObj.People__c == null) {
					folderObj.Linked_Folder_Owner__c = String.isBlank(owner.name) ? 
								LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.location.not_available')
								: owner.name;
				}
			} else {
				folderObj.People__c = UserContext.peopleId;
			}
			
	        //FLS
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			Folder__c savedFolderObj = (Folder__c) SIMPESAPI.accessController().insertAsUser(folderObj, new List<Schema.SObjectField>{
														Folder__c.External_Folder_Id__c, Folder__c.Name__c, 
														Folder__c.Type__c, Folder__c.Permissions__c,
														Folder__c.People__c, Folder__c.Box_Collaboration_Id__c, 
														Folder__c.Site__c,
														Folder__c.Parent_Folder__c});
			return savedFolderObj;
		}
    }
    
    public Boolean isFolderAlreadyLinked(String folderId, String siteId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', folderId);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'SELECT id from Folder__c where Type__c = \'Box\' and External_Folder_Id__c =: soqlParam1 and site__c =: soqlParam2 and Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfLinkedFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
    												
    	
    	if(listOfLinkedFolders.isEmpty()) {
    		return false;
    	}
    	else {
			return true;
    	}
    }
    
    public String deLinkBoxFolder(String folderId, String siteId) {
    	try {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', folderId);
			soqlParamMap.put('soqlParam2', siteId);
			String folderQuery = 'SELECT id, is_Deleted__c from Folder__c where Type__c = \'Box\' and External_Folder_Id__c =: soqlParam1 and site__c =: soqlParam2 and Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfLinkedFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
			
			if(!listOfLinkedFolders.isEmpty()) {
				listOfLinkedFolders[0].Is_Deleted__c = true;
		        
		        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		    	SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfLinkedFolders),new List<Schema.SObjectField>{
															Folder__c.Is_Deleted__c});
	    		
	    		return 'SUCCESS';
			}
			else {
				return BoxConstants.BOX_FOLDER_ALREADY_UNLINKED;
			}
    	}
    	catch(Exception e) {
    		return e.getMessage();
    	}
    }
    
    public void unlinkAllFolders4User(Id peopleId) {
		String query = 'Select Id, is_Deleted__c from Folder__c ' +
					   'where Type__c = \'Box\' ' +
					   'and Is_System_Folder__c = false ' +
					   'and Is_Deleted__c = false ';
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		if(String.isNotBlank(peopleId)) {
			soqlParamMap.put('soqlParam1', peopleId);
			query += 'And people__c =: soqlParam1 ';
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    	List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	for(Folder__c folderObj : listOfFolders) {
    		folderObj.Is_Deleted__c = true;
    	}
    	if(!listOfFolders.isEmpty()) {
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		    SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfFolders),new List<Schema.SObjectField>{
															Folder__c.Is_Deleted__c});
    	}
    }
    
    public Object createGroup(String groupname,String provenance,String groupId,String description,String apiAccessToken){
    	Object returnObject;
    	Map<String,Object> bodyMap = new Map<String,Object>{
    															'name'                     => groupname,
    															'provenance'               => provenance,
    															'external_sync_identifier' => groupId,
    															'description'              => description
															};
		String jsonBody = JSON.serialize(bodyMap);  															
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_POST, 
																			BoxConstants.BOX_HOST+'/'+BoxConstants.BOX_GROUP_REQUEST_URL, 
																			'Bearer '+ apiAccessToken,jsonBody);
		if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
			returnObject = (BoxWrapper.BoxGroup)JSON.deserialize(res.getBody(), BoxWrapper.BoxGroup.class);
		}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
			if(!String.isBlank(res.getBody())){
				returnObject = BoxWrapper.parseErrorInfo(res.getBody());
			}else{
				returnObject = ServiceConstants.UNEXPECTED_ERROR;
			}
		}else{
			returnObject =  ServiceConstants.UNEXPECTED_ERROR;
		}
    	return returnObject;
    }
    
    
    //-------------Methods related to group Members on Box.com--------------------------------------------------------------
    
    //-------------Methods to create a add a member in a Group--------------------------------------------------------------
    
    public Object addMemberIntoGroup(String boxUserId,String boxGroupId,String apiAccessToken){
    	
    	Object returnObject;
    	if(String.isBlank(boxUserId) || String.isBlank(boxGroupId) || String.isBlank(apiAccessToken)) {
    		returnObject = ServiceConstants.UNEXPECTED_ERROR;
    	} else {
			Map<String,Object> bodyMap = new Map<String,Object>{
	    															'user'	 => new Map<Object,Object>{
																					'id' => boxUserId
																					
																				},
	    															'group'  => new Map<Object,Object>{
				    																'id' => boxGroupId
				    															},
																	'role' => 'member'			    															
																};
			String jsonBody = JSON.serialize(bodyMap); 
			HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_POST, 
																				BoxConstants.BOX_HOST+'/'+BoxConstants.BOX_GROUP_MEMBER_REQUEST_URL, 
																				'Bearer '+ apiAccessToken,jsonBody);
			if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
				returnObject = (BoxWrapper.BoxAddMemberWrapper)JSON.deserialize(res.getBody(), BoxWrapper.BoxAddMemberWrapper.class);
			} else if(res.getStatusCode() == 409) {
				returnObject = getMembershipsIdForGroup(boxUserId, boxGroupId, apiAccessToken);
			}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
				if(!String.isBlank(res.getBody())){
					returnObject = BoxWrapper.parseErrorInfo(res.getBody());
				}else{
					returnObject = ServiceConstants.UNEXPECTED_ERROR;
				}
			}else{
				returnObject =  ServiceConstants.UNEXPECTED_ERROR;
			}
    	}
    	return returnObject;
    }
    @TestVisible 
    private BoxWrapper.BoxAddMemberWrapper getMembershipsIdForGroup(String boxUserId,String boxGroupId,String apiAccessToken) {
    	HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET', 'https://api.box.com/2.0/users/' +boxUserId + '/memberships','Bearer '+ apiAccessToken,null);
    	BoxWrapper.BoxUserMemberships membershipObj= BoxWrapper.parseBoxUserMemberships(res.getBody());
		String membershipId;
		for(BoxWrapper.GroupEntries groupEntry:membershipObj.entries) {
			if(boxGroupId.equalsIgnoreCase(groupEntry.group_x.id)) {
				membershipId = groupEntry.id;
				break;
			}
		}
    	BoxWrapper.BoxAddMemberWrapper memberWrapperObj = new BoxWrapper.BoxAddMemberWrapper();
    	memberWrapperObj.id = membershipId;
    	return memberWrapperObj;
    }
    //------------Method to remove a member from a group-----------------------------------------------------------------------
    
    public Object removeMemberFromGroup(String groupMemberShipId,String apiAccessToken){
		Object returnObject;
	
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_DELETE, 
																			BoxConstants.BOX_HOST+'/'+BoxConstants.BOX_GROUP_MEMBER_REQUEST_URL+'/'+groupMemberShipId, 
																			'Bearer '+ apiAccessToken,null);
		if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
			returnObject = BoxConstants.BOX_EMPTY_SUCCESS_RESPONSE;
		}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
			if(!String.isBlank(res.getBody())){
				returnObject = BoxWrapper.parseErrorInfo(res.getBody());
			}else{
				returnObject = ServiceConstants.UNEXPECTED_ERROR;
			}
		}else{
			returnObject =  ServiceConstants.UNEXPECTED_ERROR;
		}
		return returnObject;
    
    }
    
    public Object pullCollaborationsOnFolder(String folderId, String apiAccessToken) {
    	Object returnObject = 'No Collaborations Found.';
    	HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,BoxConstants.BOX_HOST+'/folders/' + folderId + '/collaborations',
    																		'Bearer '+ apiAccessToken,'');
    	if(res.getStatusCode() == 200) {
    		returnObject = BoxWrapper.parseBoxCollaborationCollections(res.getBody());
    	} else {
    		if(String.isNotBlank(res.getBody())){
				returnObject = BoxWrapper.parseErrorInfo(res.getBody());
			}else{
				returnObject = ServiceConstants.UNEXPECTED_ERROR;
			}
    	}
    	return returnObject;
    }
    
    public Object updateCollaboration(String collaborationId, String role, String apiAccessToken) {
    	Object returnObject;
    	String jsonBody = '{"role": "' + role + '"}';
    	HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_PUT,BoxConstants.BOX_HOST+'/collaborations/' + collaborationId,
    																		'Bearer '+ apiAccessToken, jsonBody);
		if(res.getStatusCode() == 200) {
			returnObject = BoxWrapper.parseBoxCollaboration(res.getBody());
		} else {
    		if(String.isNotBlank(res.getBody())){
				returnObject = BoxWrapper.parseErrorInfo(res.getBody());
			}else{
				returnObject = ServiceConstants.UNEXPECTED_ERROR;
			}
    	}
    	return returnObject;
    }
    //-------------Methods to create a add a folder in a group--------------------------------------------------------------
    
    public Object addFolderIntoGroup(String folderId,String boxGroupId,String role,String apiAccessToken){
    	
    	Object returnObject;
		Map<String,Object> bodyMap = new Map<String,Object>{
		    													'item'	=> new Map<Object,Object>{
																						'id'   => folderId,
																						'type' => 'folder'
																						
																					},
    															'accessible_by'  => new Map<Object,Object>{
			    																'id' => boxGroupId,
			    																'type' => 'group'
			    															},
			    												'role' => role
															};
		String jsonBody = JSON.serialize(bodyMap);  
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_POST, 
																			BoxConstants.BOX_HOST+'/'+BoxConstants.BOX_GROUP_COLLABORATION_REQUEST_URL, 
																			'Bearer '+ apiAccessToken,jsonBody);
		if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
			returnObject = (BoxWrapper.BoxCollaboration)JSON.deserialize(res.getBody(), BoxWrapper.BoxCollaboration.class);
		}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
			if(!String.isBlank(res.getBody())){
				returnObject = BoxWrapper.parseErrorInfo(res.getBody());
			}else{
				returnObject = ServiceConstants.UNEXPECTED_ERROR;
			}
		}else{
			returnObject =  ServiceConstants.UNEXPECTED_ERROR;
		}
    	return returnObject;
    }
    
    
    
    //--------------------------Methods to implement folder rest calls into apex-----------------------------
    
        //---------------------------Method to search in contents of Box.com------------------------------------------
    public Object searchInBoxSystem(Map<String,Object> paramMap,String apiAccessToken){
    	Object returnObject;
    	String queryString = '';
		List<String> queryParamList = new List<String>();
    	if(paramMap != null && paramMap.size() > 0){
    		for(String key : paramMap.keyset()){
				Object value = paramMap.get(key);
    			if(value instanceof List<String>){
    				List<String> valueList = (List<String>)value;
    				if(valueList.size() > 0){
			    		String valueString = String.join(valueList,',');
			    		queryString = key+'='+valueString;
			    	}
    			}else{
    				queryString = key+'='+value;
    			}
    			queryParamList.add(queryString);
    		}
			if(queryParamList.size() > 0){
				queryString = '?'+String.join(queryParamList,'&');
			}else{
				queryString = '';
			} 
			  		
    	}
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,  
																			BoxConstants.BOX_HOST+'/'+BoxConstants.BOX_SEARCH_REQUEST_URL+queryString,
																			'Bearer ' + apiAccessToken,null); 
		if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
			returnObject = (BoxWrapper.createFolderWrapper)JSON.deserialize(res.getBody(), BoxWrapper.createFolderWrapper.class);
		}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
			if(!String.isBlank(res.getBody())){
				returnObject = BoxWrapper.parseErrorInfo(res.getBody());
			}else{
				returnObject = ServiceConstants.UNEXPECTED_ERROR;
			}
		}else{
			returnObject =  ServiceConstants.UNEXPECTED_ERROR;
		}
		return returnObject;
    	
    }
    
    //---------------------------Method to create folder on Box.com------------------------------------------
    public Object createBoxFolder(string parentBoxFolderId, string boxFolderName,String apiAccessToken){
    	Object returnObject;
    	if(string.IsNotBlank(parentBoxFolderId) && string.IsNotBlank(boxFolderName)){
    		if(String.isNotBlank(apiAccessToken)){
    			Map<String,Object> bodyMap = new Map<String,Object>{
    				'name'   => boxFolderName,
    				'parent' => new Map<String,Object>{
    						'id' => parentBoxFolderId
    				}
    			};
    			String jsonBody = JSON.serialize(bodyMap);
	    		HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_POST,  
																					BoxConstants.BOX_HOST+'/'+BoxConstants.BOX_GROUP_FOLDER_REQUEST_URL,
																					'Bearer ' + apiAccessToken,jsonBody);
				if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
					returnObject = (BoxWrapper.createFolderWrapper)JSON.deserialize(res.getBody(), BoxWrapper.createFolderWrapper.class);
				}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
					if(!String.isBlank(res.getBody())){
						returnObject = BoxWrapper.parseErrorInfo(res.getBody());
					}else{
						returnObject = ServiceConstants.UNEXPECTED_ERROR;
					}
				}else{
					returnObject =  ServiceConstants.UNEXPECTED_ERROR;
				}
			}
    	}
    	return returnObject;
    	
    }
    
    //--------------------Method to update folder name on Box.com------------------------------------
    public Object UpdateFolderName(String folderId,String folderName,String apiAccessToken){ 
    	Object returnObject;
    	Map<String,Object> bodyMap = new Map<String,Object>{
	    													'name'	=> folderName
	    													};
		String jsonBody = JSON.serialize(bodyMap);  															
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_PUT, 
																			BoxConstants.BOX_HOST+'/'+BoxConstants.BOX_GROUP_FOLDER_REQUEST_URL+'/'+folderId, 
																			'Bearer '+ apiAccessToken,jsonBody);
		if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
			returnObject = (BoxWrapper.createFolderWrapper)JSON.deserialize(res.getBody(), BoxWrapper.createFolderWrapper.class);
		}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
			returnObject = BoxWrapper.parseErrorInfo(res.getBody());
		}else{
			returnObject =  ServiceConstants.UNEXPECTED_ERROR;
		}
    	
    	return returnObject;
    }
    
    
    
    private String createAllCompanyGroupInBox(String apiAccessToken) {
    	String boxAllComapnyGroupId;
    	String groupname = 'SIMPPLR_' + UserInfo.getOrganizationId() +'_MEMBER';
    	String groupId = UserInfo.getOrganizationId();
		Object result = createGroup(groupname, 'SALESFORCE', groupId, BoxConstants.BOX_GROUP_DESCRIPTION, apiAccessToken);
    	if(result instanceof BoxWrapper.BoxGroup){
			BoxWrapper.BoxGroup resultWrapper = (BoxWrapper.BoxGroup)result;
			if(String.isNotBlank(resultWrapper.id)){
				boxAllComapnyGroupId = resultWrapper.id;
			}
    	}else if(result instanceof BoxWrapper.BoxErrorWrapper) {
    		BoxWrapper.BoxErrorWrapper errorWrapper = (BoxWrapper.BoxErrorWrapper)result;
    		if(errorWrapper.status == 409) {
    			boxAllComapnyGroupId = SimpplrContext.BoxAllCompanyGroupId;
    		} else {
    			throw new SimpplrException(errorWrapper.message);
    		}
    	} else {
    		throw new SimpplrException(BoxConstants.BOX_SERVICE_ACCOUNT_PERMISSION_ERROR);
    	}
    	return boxAllComapnyGroupId;
    } 
    
    @testVisible private void addMemberIntoAllCompanyGroup(String boxUserId, String groupId, Boolean saveInfoInDB) {
    	BoxWrapper.UserTokens adminUserTokens = getBoxAdminUserTokens(false);
    	if(adminUserTokens == null || String.isBlank(adminUserTokens.accessToken)) {
    		throw new SimpplrException(BoxConstants.BOX_SERVICE_ACCOUNT_DISCONNECTED_ERROR);
    	}
    	try {
	    	Object result = addMemberIntoGroup(boxUserId, groupId, adminUserTokens.accessToken);
	    	if(result instanceof BoxWrapper.BoxAddMemberWrapper){
	    		BoxWrapper.BoxAddMemberWrapper resultWrapper = (BoxWrapper.BoxAddMemberWrapper)result;
	    		if(saveInfoInDB && String.isNotBlank(resultWrapper.id)){
	    			Map<String,String> groupAndMemberShipMap = new Map<String,String>();
	    			groupAndMemberShipMap.put(groupId, resultWrapper.id);
	    			
					Simpplr_Metadata__c metadataObj = new Simpplr_Metadata__c(
										value__c = Utility.getJsonFormat(groupAndMemberShipMap),
										User__c = UserContext.id,
										type__C = BoxConstants.BOX_MEMBERSHIP_INFO);
										
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	   				SIMPESAPI.accessController().insertAsUser(metadataObj,new List<Schema.SObjectField>{
	   																		Simpplr_Metadata__c.value__c,
	   																		Simpplr_Metadata__c.User__c,
	   																		Simpplr_Metadata__c.type__C});
	    		}
	    	}
			
    	} catch(Exception ex) {
			throw ex;
		} finally{
			updateAdminUserTokensInDB(adminUserTokens);
		}
    }  
    
    public void removeBoxGroupMembershipIdsfromDB() {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', UserContext.id);
		soqlParamMap.put('soqlParam2', BoxConstants.BOX_MEMBERSHIP_INFO);
    	String query = 'select id from Simpplr_Metadata__c ' 
    						+ ' where User__c =: soqlParam1 '
    						+ ' And type__C =: soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Simpplr_Metadata__c> listOfSimpplrMetadata = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
    	if(!listOfSimpplrMetadata.isEmpty()) {
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().deleteAsUser(listOfSimpplrMetadata);
    	}
    } 

    /*
    // Add User to Box Group, if user is member of current site and its not added to box group already
    */
    
    public void unlinkAndDeleteFolderInDB(String siteId, String boxFolderId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', boxFolderId);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'select Id, Box_Collaboration_Id__c from Folder__c where External_Folder_Id__c=:soqlParam1 and site__c=:soqlParam2 and is_Deleted__c= false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfBoxFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);

		if(!listOfBoxFolders.isEmpty()) {
    		Map<String,String> mapOfcollaborationIds = new Map<String,String>(); 
    		for(Folder__c folderObj : listOfBoxFolders) {
    			folderObj.is_Deleted__c = true;
    			if(String.isNotBlank(folderObj.Box_Collaboration_Id__c)) {
    				mapOfcollaborationIds.putAll((Map<String,String>) Json.deserialize(folderObj.Box_Collaboration_Id__c, Map<String,String>.class));
    			}
    		}

    		if(mapOfcollaborationIds.size() > 0 && (String.isNotBlank(SimpplrContext.boxManagedPermission) && 'simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission))) {
    			deleteCollaborationOnBox(mapOfcollaborationIds.values());
    		}
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfBoxFolders),new List<Schema.SObjectField>{Folder__c.is_Deleted__c});
    	}
    }
    
    public void deleteCollaborationOnBox(List<String> listOfCollaborationIds){
    	BoxWrapper.UserTokens adminUserTokens = getBoxAdminUserTokens(false);
    	if (adminUserTokens != null && String.isNotBlank(adminUserTokens.accessToken)) {
			try {
				for (String collaborationId : listOfCollaborationIds) {
	    			BoxService.deleteCollaborationOnBox(collaborationId, adminUserTokens.accessToken);
		    	}
			} catch(Exception ex) {
				throw ex;
			} finally{
				updateAdminUserTokensInDB(adminUserTokens);
			}
		}
    }
   
    public static Boolean deleteCollaborationOnBox(String boxCollaborationId,String apiAccessToken){
    	HttpResponse res = Utility.getJsonResponseFromExternalSystem('DELETE','https://api.box.com/2.0/collaborations/'+boxCollaborationId ,'Bearer '+ apiAccessToken,null);
    	return (res.getStatusCode()==204);
    }
    
    public void addUserToBoxGroup(String boxUserId, String simpplrSiteId, String chatterGroupId, String userRoleInGroup) {
		
		Boolean groupsCreated = false;
		Boolean groupMembershipUpdated = false;
		BoxWrapper.UserTokens adminUserTokens = getBoxAdminUserTokens(false);
		if(adminUserTokens == null || String.isBlank(adminUserTokens.accessToken)) {
			throw new SimpplrException(BoxConstants.BOX_SERVICE_ACCOUNT_DISCONNECTED_ERROR);
		}
		try {
			List<Simpplr_Metadata__c> listOfBoxGroupInMetadata = new List<Simpplr_Metadata__c>();
			String boxMemberGroupId = getBoxGroupIdFromDB(simpplrSiteId, BoxConstants.BOX_MEMBER_GROUP_TYPE);
			//If Groups is not available, Lets Create it in Box	
			if(String.isBlank(boxMemberGroupId)) {
				String groupname = 'SIMPPLR_' + chatterGroupId +'_MEMBER';
				Object result = createGroup(groupname, 'SALESFORCE', chatterGroupId, BoxConstants.BOX_GROUP_DESCRIPTION, adminUserTokens.accessToken);
				if(result instanceof BoxWrapper.BoxGroup){
					BoxWrapper.BoxGroup resultWrapper = (BoxWrapper.BoxGroup)result;
					if(!String.isBlank(resultWrapper.id)) {
						boxMemberGroupId = resultWrapper.id;
						Simpplr_Metadata__c metadataObj = new Simpplr_Metadata__c(
											value__c = resultWrapper.id,
											Simpplr_Site__c = simpplrSiteId,
											type__C = BoxConstants.BOX_MEMBER_GROUP_TYPE);	
						listOfBoxGroupInMetadata.add(metadataObj);
						groupsCreated = true;	
					}		
				} else {
					//Something is wrong, Lets not create Groups
					updateAdminUserTokensInDB(adminUserTokens);
					
					return;
				}
			}
				
			String boxAdminGroupId = getBoxGroupIdFromDB(simpplrSiteId, BoxConstants.BOX_ADMIN_GROUP_TYPE);
			//If Groups is not available, Lets Create it in Box
			if(String.isBlank(boxAdminGroupId)) {
				String groupname = 'SIMPPLR_' + chatterGroupId +'_ADMIN';
				Object result = createGroup(groupname, 'SALESFORCE', chatterGroupId, BoxConstants.BOX_GROUP_DESCRIPTION, adminUserTokens.accessToken);
				if(result instanceof BoxWrapper.BoxGroup){
					BoxWrapper.BoxGroup resultWrapper = (BoxWrapper.BoxGroup)result;
					if(!String.isBlank(resultWrapper.id)) {
						Object memberResult = addMemberIntoGroup(adminUserTokens.boxUserId, resultWrapper.id, adminUserTokens.accessToken);
						if(memberResult instanceof BoxWrapper.BoxAddMemberWrapper){
							boxAdminGroupId = resultWrapper.id;
							Simpplr_Metadata__c metadataObj = new Simpplr_Metadata__c(
												value__c = resultWrapper.id,
												Simpplr_Site__c = simpplrSiteId,
												type__C = BoxConstants.BOX_ADMIN_GROUP_TYPE);	
							listOfBoxGroupInMetadata.add(metadataObj);
							groupsCreated = true;	
						} else {
							
							updateAdminUserTokensInDB(adminUserTokens);
							return;		
						}
					}		
				} else {
					//Something is wrong, Lets not create Groups
					
					updateAdminUserTokensInDB(adminUserTokens);
					return;
				}
			}
				
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', UserContext.id);
			soqlParamMap.put('soqlParam2', BoxConstants.BOX_MEMBERSHIP_INFO);			
	    	String query = 'select id, value__c from Simpplr_Metadata__c '
	    							+ ' where type__c =: soqlParam2 ' 
	    							+ ' and User__c =: soqlParam1';
	    	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Simpplr_Metadata__c> listOfMetadataObj = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
	    	logger.logDebug('BoxService.addUserToBoxGroup() -------------- listOfMetadataObj :: ' + listOfMetadataObj);
	    	
	    	Simpplr_Metadata__c metadataObj;
	    	Boolean groupMembershipCreated = false;
	    	if(listOfMetadataObj.isEmpty()) {
	    		groupMembershipCreated = true;
	    		metadataObj = new Simpplr_Metadata__c(type__c = BoxConstants.BOX_MEMBERSHIP_INFO, User__c =UserContext.id, value__c='{}');
	    	} else  {
		    	metadataObj = listOfMetadataObj[0];
	    	}
			Map<String,String> groupAndMemberShipMap = (Map<String,String>)Json.deserialize(metadataObj.value__c, Map<String,String>.class);														
    		if(String.isNotBlank(boxMemberGroupId) && groupAndMemberShipMap.get(boxMemberGroupId) == null) {
				Object result = addMemberIntoGroup(boxUserId, boxMemberGroupId, adminUserTokens.accessToken);
	    		if(result instanceof BoxWrapper.BoxAddMemberWrapper){
					BoxWrapper.BoxAddMemberWrapper resultWrapper = (BoxWrapper.BoxAddMemberWrapper)result;
					groupAndMemberShipMap.put(boxMemberGroupId,resultWrapper.id);
					groupMembershipUpdated = true;
	    		}
			}
			
			if('Admin'.equalsIgnoreCase(userRoleInGroup) && String.isNotBlank(boxAdminGroupId) && groupAndMemberShipMap.get(boxAdminGroupId) == null) {
				Object result = addMemberIntoGroup(boxUserId, boxAdminGroupId, adminUserTokens.accessToken);
	    		if(result instanceof BoxWrapper.BoxAddMemberWrapper){
					BoxWrapper.BoxAddMemberWrapper resultWrapper = (BoxWrapper.BoxAddMemberWrapper)result;
					groupAndMemberShipMap.put(boxAdminGroupId,resultWrapper.id);
					groupMembershipUpdated = true;
	    		}
			}
			if(groupMembershipUpdated) {
				metadataObj.value__c = JSON.serialize(groupAndMemberShipMap);
				if(groupMembershipCreated) {
					insert metadataObj;
				} else {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    			SIMPESAPI.accessController().updateAsUser(metadataObj,new List<Schema.SObjectField>{
														Simpplr_Metadata__c.value__c});
				}
			}
			
			if(groupsCreated) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().insertAsUser(listOfBoxGroupInMetadata,new List<Schema.SObjectField>{
													Simpplr_Metadata__c.value__c,
													Simpplr_Metadata__c.Simpplr_Site__c,
													Simpplr_Metadata__c.Type__c});
			}
		} catch(Exception ex) {
			throw ex;
		} finally{
			updateAdminUserTokensInDB(adminUserTokens);
		}
    }
    
}