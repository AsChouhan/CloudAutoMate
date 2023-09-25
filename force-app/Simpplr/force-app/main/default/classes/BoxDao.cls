public with sharing class BoxDao {

	private String accessToken;
	private String refreshToken;
	private String adminAccessToken;
	private String adminRefreshToken;
    private string expiresInTime;
    private String redirectURL;
    
    public BoxDao(){
    	redirectURL = SimpplrContext.salesforceBaseUrl  + Page.StorageSettings.getUrl() + '?type=box';
    }
 	
 	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
 	public PageReference redirectToBoxLoginPage(String state) {
    	//Redirect to the OAuth page at Box so the login credentials can be entered.       
        PageReference pref = new PageReference('https://www.box.com/api/oauth2/authorize?response_type=code' +
            '&state=' + state +
            '&client_id=' + SimpplrContext.BoxClientId +
            '&redirect_uri=' +  redirectURL);
        return pref;
    }
 	
 	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
 	public BoxWrapper.UserTokens getBoxAdminUserTokens(Boolean updateTokenInPreferenceAllowed) {
    	BoxWrapper.UserTokens returnObj = new BoxWrapper.UserTokens();
    	
		String appConfigQuery = 'SELECT Id, Box_Enterprise_Id__c, Box_User_Id__c, Box_Username__c, ' 
										+ 'Box_Access_Token__c, Box_Refresh_Token__c , Box_Access_Token_Expires_At__c, '
										+ 'Box_Refresh_Token_Expires_At__c FROM App_Config__c Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
											   

    	App_config__c appConfigObj = listOfAppConfig[0];
    	
    	if(appConfigObj==null){
			throw new SimpplrException(ExceptionCode.CONFIGURATION_ERROR.name());
		}
		
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
		
    	return returnObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
 	public BoxWrapper.UserTokens getUserTokens(Boolean updateTokenInPreferenceAllowed,String peopleId) {
    	BoxWrapper.UserTokens returnObj = new BoxWrapper.UserTokens();
    	
		List<People_Preference__c> peopleList = [SELECT Id, Box_Enterprise_Id__c, Box_User_Id__c, Box_Username__c, 
				Box_Access_Token__c, Box_Refresh_Token__c , Box_Access_Token_Expires_At__c, people__c,Box_Favorite_Collection_Id__c,
				Box_Refresh_Token_Expires_At__c FROM People_Preference__c WHERE People__c =: peopleId WITH SECURITY_ENFORCED];
				
		People_Preference__c peoplePreferenceObj = peopleList.size()>0? peopleList.get(0) : null;
		
		if(peoplePreferenceObj==null){
			throw new SimpplrException(ExceptionCode.MISSING_PEOPLE_PREFERENCE.name());
		}
				
    	
    	
        if (String.isNotBlank(peoplePreferenceObj.Box_Refresh_Token__c) && 
        		(peoplePreferenceObj.Box_Refresh_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0) &&
        		(String.isBlank(peoplePreferenceObj.Box_Access_Token__c) ||
        		(DateTime.now().getTime() - peoplePreferenceObj.Box_Access_Token_Expires_At__c.getTime() > 0))) {
        			
        	returnObj =  refreshBoxToken(peoplePreferenceObj, updateTokenInPreferenceAllowed);
        	
    	} else if(String.isNotBlank(peoplePreferenceObj.Box_Refresh_Token__c) && 
    			String.isNotBlank(peoplePreferenceObj.Box_Access_Token__c) &&
        		(peoplePreferenceObj.Box_Refresh_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0) &&
        		(peoplePreferenceObj.Box_Access_Token_Expires_At__c.getTime() - DateTime.now().getTime() > 0)) {
        	
        	returnObj =  toWrapper(peoplePreferenceObj, true);
        }
        returnObj.peopleId = peopleId;
    	return returnObj;
    }
    
    public void pullBoxUserToken(String codeFromBox){
    	String body = pullBoxToken(codeFromBox);
    	Boolean isSuccess = parseAuthJSON(body);
    	if(isSuccess){
    		storeBoxUserDetails();
    	}
    }
    
    private String pullBoxToken(String codeFromBox){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BoxConstants.BOX_OAUTH_END_POINT_URL);
        req.setBody('grant_type=' + EncodingUtil.urlEncode('authorization_code', 'UTF-8') +
                    '&code=' + EncodingUtil.urlEncode(codeFromBox, 'UTF-8') +
                    '&client_id=' + EncodingUtil.urlEncode(SimpplrContext.BoxClientId, 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(SimpplrContext.BoxClientSecret, 'UTF-8') );
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        if(res.getStatusCode() != 200) {
        	throw new SimpplrException(ExceptionCode.BOX_CONNECTION_FAILED_WITH_STATUS.name() + res.getStatusCode());
        }
        return res.getBody();
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
    private BoxWrapper.UserTokens refreshBoxAdminUserToken(App_Config__c appConfigObj, Boolean updateTokenInPreferenceAllowed) {
    	BoxWrapper.UserTokens returnTokenObj = new BoxWrapper.UserTokens();
    	Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(BoxConstants.BOX_OAUTH_END_POINT_URL);
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
        	logger.logError('BoxDao.refreshBoxAdminUserToken() - ' + res.getStatusCode() + ' response received from Box while trying to refresh box admin token');
        }
        return returnTokenObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public BoxWrapper.UserTokens refreshBoxToken(People_Preference__c peoplePreferenceObj, Boolean updateTokenInPreferenceAllowed) {
    	BoxWrapper.UserTokens returnTokenObj = new BoxWrapper.UserTokens();
    	Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BoxConstants.BOX_OAUTH_END_POINT_URL);
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
        	logger.logError('BoxDao.refreshBoxToken() - ' + res.getStatusCode() + ' response received from Box while trying to refresh box user for user ' + peoplePreferenceObj);
        }
        return returnTokenObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void updateAdminUserTokensInDB(BoxWrapper.UserTokens wrapperObj) {
    	if(String.isNotBlank(wrapperObj.accessToken) && !wrapperObj.preferenceObjUpdated) {
    		App_Config__c appConfigObj = new App_Config__c();
    		appConfigObj.id = SimpplrContext.Id;
			appConfigObj.Box_Access_Token__c = wrapperObj.accessToken;
	        appConfigObj.Box_Refresh_Token__c = wrapperObj.refreshToken;
	        appConfigObj.Box_Access_Token_Expires_At__c = DateTime.now().addMinutes(55);
	        appConfigObj.Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(59);
	        
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	    	SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
														App_Config__c.Box_Access_Token__c, 
														App_Config__c.Box_Refresh_Token__c, 
														App_Config__c.Box_Access_Token_Expires_At__c, 
														App_Config__c.Box_Refresh_Token_Expires_At__c});
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
    public void storeBoxUserDetails() {
    	
        BoxWrapper.MiniBoxUser boxUserObj = getCurrentBoxUser(accessToken);
        String adminEnterpriseId = SimpplrContext.BoxEnterpriseId;
        
    	if(boxUserObj.enterprise == null || !adminEnterpriseId.equalsIgnoreCase(boxUserObj.enterprise.id)) {
    		throw new SimpplrException(ExceptionCode.BOX_NON_OFFICIAL_BOX_ACCOUNT.name());
    	}
        
        List <People_Preference__c> listOfUserPreference = [select id,Box_User_Id__c,Box_Access_Token__c,Box_Refresh_Token__c,
        					Box_Username__c,People__c,Box_Enterprise_Id__c,Box_Access_Token_Expires_At__c,Box_Refresh_Token_Expires_At__c
        					 from People_Preference__c where People__c =:UserContext.peopleId WITH SECURITY_ENFORCED];
        
        People_Preference__c peoplePreferenceObj = listOfUserPreference.size()>0? listOfUserPreference[0] : null;
        
        if(peoplePreferenceObj==null){
        	throw new SimpplrException(ExceptionCode.MISSING_PEOPLE_PREFERENCE.name());
        }
    	
    	peoplePreferenceObj.Box_User_Id__c = boxUserObj.id;
        peoplePreferenceObj.Box_Access_Token__c = accessToken;
        peoplePreferenceObj.Box_Refresh_Token__c = refreshToken;
        peoplePreferenceObj.Box_Username__c = boxUserObj.login;
        peoplePreferenceObj.People__c = UserContext.peopleId;
        peoplePreferenceObj.Box_Enterprise_Id__c = boxUserObj.enterprise.id;
        peoplePreferenceObj.Box_Access_Token_Expires_At__c = DateTime.now().addMinutes(55);
        peoplePreferenceObj.Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(59);
        
		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
			People_Preference__c.Box_User_Id__c,
			People_Preference__c.Box_Access_Token__c,
			People_Preference__c.Box_Refresh_Token__c,
			People_Preference__c.Box_Username__c,
			People_Preference__c.People__c,
			People_Preference__c.Box_Enterprise_Id__c,
			People_Preference__c.Box_Access_Token_Expires_At__c,
			People_Preference__c.Box_Refresh_Token_Expires_At__c 
		};
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(peoplePreferenceObj, fieldList);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void updateUserTokensInDB(BoxWrapper.UserTokens wrapperObj) {
    	
    	if(wrapperObj==null || (String.isBlank(wrapperObj.accessToken)  && wrapperObj.preferenceObjUpdated)) {
    		throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
    	}

		//Don't updated token in db if its already updated
    	if(!wrapperObj.preferenceObjUpdated) {
	    	List<People_Preference__c> peopleList = [SELECT Id from People_Preference__c where People__c=:wrapperObj.peopleId WITH SECURITY_ENFORCED limit 1];
	    	
	    	People_Preference__c peoplePreferenceObj = peopleList.size()>0? peopleList.get(0) : null;
	    	if(peoplePreferenceObj==null){
				throw new SimpplrException(ExceptionCode.MISSING_PEOPLE_PREFERENCE.name());
			}
			peoplePreferenceObj.Box_Access_Token__c = wrapperObj.accessToken;				
	        peoplePreferenceObj.Box_Refresh_Token__c = wrapperObj.refreshToken;
	        peoplePreferenceObj.Box_Access_Token_Expires_At__c = DateTime.now().addMinutes(55);
	        peoplePreferenceObj.Box_Refresh_Token_Expires_At__c = DateTime.now().addDays(59);
	     	
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField> {
				People_Preference__c.Box_Access_Token__c,
				People_Preference__c.Box_Refresh_Token__c,
				People_Preference__c.Box_Access_Token_Expires_At__c,
				People_Preference__c.Box_Refresh_Token_Expires_At__c 
			};

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().upsertAsUser(new List<People_Preference__c>{peoplePreferenceObj}, fieldList);
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
    private BoxWrapper.MiniBoxUser getCurrentBoxUser(string aToken) {
    	String jsonBody = '';
        HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET', 'https://api.box.com/2.0/users/me?fields=enterprise,login,role', 'Bearer ' + aToken,jsonBody);
        if(res.getStatusCode() != 200) {
        	throw new SimpplrException(ExceptionCode.BOX_CANNOT_GET_USER_DETAILS.name() + res.getStatusCode());
        }
        return BoxWrapper.parseBoxUser(res.getBody());
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private Boolean parseAuthJSON(string JSONValue){
    	Boolean successFlag = false; 
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
        if(accessToken != '' && refreshToken != '') {
    		successFlag = true;
    	}
    	return successFlag;	
    }
    
    private Boolean parseAdminAuthJSON(string JSONValue){
    	Boolean successFlag = false; 
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
        if(AdminAccessToken != '' && adminRefreshToken != '') {
    		successFlag = true;
    	}
    	return successFlag;	
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @testVisible 
    private BoxWrapper.UserTokens toWrapper(People_Preference__c peoplePreferenceObj, Boolean preferenceObjUpdated) {
    	BoxWrapper.UserTokens userTokensObj = new BoxWrapper.UserTokens();
    	userTokensObj.userEmail = peoplePreferenceObj.Box_Username__c;
    	userTokensObj.boxUserId = peoplePreferenceObj.Box_User_Id__c;
    	userTokensObj.peopleId = peoplePreferenceObj.people__c;
    	userTokensObj.accessToken = peoplePreferenceObj.Box_Access_Token__c;
    	userTokensObj.refreshToken = peoplePreferenceObj.Box_Refresh_Token__c;
    	userTokensObj.accessTokenExpiresIn = peoplePreferenceObj.Box_Access_Token_Expires_At__c;
    	userTokensObj.refreshTokenExpiresIn = peoplePreferenceObj.Box_Refresh_Token_Expires_At__c;
    	userTokensObj.enterpriseId = peoplePreferenceObj.Box_Enterprise_Id__c;
    	userTokensObj.favoriteCollectionId = peoplePreferenceObj.Box_Favorite_Collection_Id__c;
    	userTokensObj.preferenceObjUpdated = preferenceObjUpdated;
    	return userTokensObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @testVisible
    private BoxWrapper.UserTokens toWrapper(App_Config__c appConfigObj, Boolean preferenceObjUpdated) {
    	BoxWrapper.UserTokens userTokensObj = new BoxWrapper.UserTokens();
    	userTokensObj.userEmail = appConfigObj.Box_Username__c;
    	userTokensObj.boxUserId = appConfigObj.Box_User_Id__c;
    	userTokensObj.accessToken = appConfigObj.Box_Access_Token__c;
    	userTokensObj.refreshToken = appConfigObj.Box_Refresh_Token__c;
    	userTokensObj.accessTokenExpiresIn = appConfigObj.Box_Access_Token_Expires_At__c;
    	userTokensObj.refreshTokenExpiresIn = appConfigObj.Box_Refresh_Token_Expires_At__c;
    	userTokensObj.enterpriseId = appConfigObj.Box_Enterprise_Id__c;
    	userTokensObj.preferenceObjUpdated = preferenceObjUpdated;
    	return userTokensObj;
    }
    
    public BoxWrapper.FolderFile getContentsAssociatedToFolder(String boxFolderId, Integer offset, Integer recordLimit) {
    	BoxWrapper.FolderFile folderFileObj;
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
    	if(userTokensObj!=null && String.isNotBlank(userTokensObj.accessToken)) {
			try {
				HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET, 'https://api.box.com/2.0/folders/'+boxFolderId+'?limit=' + recordLimit +'&offset=' + offset +'&fields=id,modified_at,created_at,name,created_by,size,path_collection,item_collection,parent,permissions&limit=' + recordLimit + '&offset=' + offset, 'Bearer ' + userTokensObj.accessToken,null);
				if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
	    			folderFileObj = BoxWrapper.parseFolderFile(res.getBody());
	    			folderFileObj.isAccessDenied = false;
	    		}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
	    			BoxWrapper.BoxErrorWrapper errorObject = BoxWrapper.parseErrorInfo(res.getBody());
	    			if(errorObject.status == 404 && errorObject.code.equalsIgnoreCase('trashed')){
	    				deleteBoxFolderInDB(boxFolderId);
	    				throw new SimpplrException(BoxConstants.BOX_FOLDER_TRASHED_ERROR);
	    			} else if(errorObject.status == 404 && errorObject.code.equalsIgnoreCase('not_found')){
	    				folderFileObj = new BoxWrapper.FolderFile();
	    				folderFileObj.isAccessDenied = true;
	    			} else {
	    				throw new SimpplrException(errorObject.message);
	    			}
	    		} else {
	    			throw new SimpplrException('BoxDao.getContentsAssociatedToFolder() - ' + res + ' returned by Box API.');
	    		}
			} catch(Exception ex) {
				logger.logError('BoxDao.getContentsAssociatedToFolder() - Exception occurred while trying to get contents of folder with Id ' + boxFolderId,ex);
			} finally {
				updateUserTokensInDB(userTokensObj);
			}
    	}
    	return folderFileObj;
    }
    
    public BoxWrapper.MiniFolderFile moveBoxFiles(String fileId, String sourceFolderId, String destinationFolderId) {
    	BoxWrapper.MiniFolderFile folderFileObj = new BoxWrapper.MiniFolderFile();
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
    	if(userTokensObj!=null && String.isNotBlank(userTokensObj.accessToken)) {
			try {
				Map<String,Object> bodyMap = new Map<String,Object>{
    				'parent' => new Map<String,Object>{
    						'id' => destinationFolderId
    				}
    			};
    			String jsonBody = JSON.serialize(bodyMap);
				HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_PUT, 'https://api.box.com/2.0/files/' + fileId, 'Bearer ' + userTokensObj.accessToken, jsonBody);
	    		if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())){
	    			folderFileObj = BoxWrapper.parseMiniFolderFile(res.getBody());
	    		}else if(BoxConstants.BOX_ERROR_CODE_SET.contains(res.getStatusCode())){
	    			BoxWrapper.BoxErrorWrapper errorObject = BoxWrapper.parseErrorInfo(res.getBody());
	    			if(errorObject.status == 404 && errorObject.code.equalsIgnoreCase('trashed')){
	    				throw new SimpplrException(BoxConstants.BOX_FOLDER_TRASHED_ERROR);
	    			} else {
	    				throw new SimpplrException(errorObject.message);
	    			}
	    		} else {
	    			throw new SimpplrException('BoxDao.moveBoxFiles() - ' + res + ' returned by Box API.');
	    		}
			} catch(Exception ex) {
				logger.logError('BoxDao.moveBoxFiles() - Exception occurred while trying to move box file ' + fileId,ex);
			} finally {
				updateUserTokensInDB(userTokensObj);
			}
    	}
    	return folderFileObj;
    }
    
    public BoxWrapper.BoxItemCollection getFileVersionInformation(String fileId) {
    	BoxWrapper.BoxItemCollection boxItemCollectionsObj;
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
    	if(userTokensObj!=null && String.isNotBlank(userTokensObj.accessToken)) {
			try {
				HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,'https://api.box.com/2.0/files/'+fileId+'/versions','Bearer ' + userTokensObj.accessToken, null); 
        		boxItemCollectionsObj = BoxWrapper.parseBoxItems(res.getBody());
        		res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,'https://api.box.com/2.0/files/'+fileId+'?fields=id,type,name,size,created_by,owned_by,created_at,modified_at','Bearer ' + userTokensObj.accessToken,null);
        		List<BoxWrapper.MiniFolderFile> listOfFileVersion = new List<BoxWrapper.MiniFolderFile>();	
        		listOfFileVersion.add(BoxWrapper.parseMiniFolderFile(res.getBody()));
        		listOfFileVersion.addAll(boxItemCollectionsObj.entries);
        		boxItemCollectionsObj.entries = listOfFileVersion;
			} catch(Exception ex) {
				logger.logError('BoxDao.getFileVersionInformation() - Exception occurred while trying to get versions of file with Id ' + fileId, ex);
			} finally {
				updateUserTokensInDB(userTokensObj);
			}
    	}
    	return boxItemCollectionsObj;
    }
    
    public void deleteBoxFolderInDB(String boxFolderId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', boxFolderId);
		String folderQuery = 'select Id from Folder__c where External_Folder_Id__c=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfBoxFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
    	if(!listOfBoxFolders.isEmpty()) {
    		for(Folder__c folderObj : listOfBoxFolders) {
    			folderObj.is_Deleted__c = true;
    		}
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfBoxFolders),new List<Schema.SObjectField>{Folder__c.is_Deleted__c});
    	}
    }
    
    public BoxWrapper.FolderFile getBoxFileDetails(String fileId) {
    	BoxWrapper.FolderFile folderFileObj;
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
    	if(userTokensObj!=null && String.isNotBlank(userTokensObj.accessToken)) {
			try {
				HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,'https://api.box.com/2.0/files/'+fileId+'?fields=id,type,file_version,name,description,size,path_collection,created_by,owned_by,shared_link,parent,item_status,item_collection,created_at,modified_at,shared_link,version_number,permissions,tags,path_collection,expiring_embed_link','Bearer ' + userTokensObj.accessToken,null);
        		Integer responseCode=res.getStatusCode();
		        if(responseCode == 200) {
	        		folderFileObj = BoxWrapper.parseFolderFile(res.getBody());
				} else if(responseCode == 404) {
					throw new SimpplrException(ExceptionCode.NO_ACCESS.name());
		        } else if(responseCode == 415) {
		        	res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,'https://api.box.com/2.0/files/'+fileId+'?fields=id,type,file_version,name,description,size,path_collection,created_by,owned_by,shared_link,parent,item_status,item_collection,created_at,modified_at,shared_link,version_number,permissions,tags,path_collection','Bearer ' + userTokensObj.accessToken,null);
		        	responseCode=res.getStatusCode();
		        	if(responseCode == 200) {
		        		folderFileObj = BoxWrapper.parseFolderFile(res.getBody());
		        	} else {
			        	logger.logError('BoxDao.getBoxFileDetails() - ' + responseCode + ' response received from Box API while trying to get box file - ' + fileId);
			        	throw new SimpplrException(ExceptionCode.BOX_FILE_NOT_FOUND.name());
			        }
		        } else {
		        	logger.logError('BoxDao.getBoxFileDetails() - ' + responseCode + ' response received from Box API while trying to get box file - ' + fileId);
		        	throw new SimpplrException(ExceptionCode.BOX_FILE_NOT_FOUND.name());
		        }
			} finally {
				updateUserTokensInDB(userTokensObj);
			}
    	}
    	return folderFileObj;
    }
    
    public Boolean deleteFile(String fileId, String etag){
    	Integer responseCode;
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
    	if(userTokensObj!=null && String.isNotBlank(userTokensObj.accessToken)) {
    		try {
		    	Map<String,String> mapOfHeaders=new Map<String,String>();
		    	if(String.isNotBlank(etag)) {
		    		mapOfHeaders.put('If-Match', etag);
		    	}
		        HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_DELETE,'https://api.box.com/2.0/files/'+fileId,'Bearer ' +  userTokensObj.accessToken,null,mapOfHeaders);
		        responseCode=res.getStatusCode();
		        //204 is returned if file is deleted successfully else "412 Precondition Failed" is returned
		        if(responseCode != 204) {
		        	logger.logError('BoxDao.deleteFile() - ' + responseCode + ' response received from Box API while trying to delete box file - ' + fileId);
		        	throw new SimpplrException('Failed to delete box file, ' + responseCode + ' response received from Box.');
		        }
	    	} finally {
				updateUserTokensInDB(userTokensObj);
			}
    	}
        return (responseCode==204);
    }
    
    public Boolean deleteFolder(String folderId){
    	Integer responseCode;
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
    	if(userTokensObj!=null && String.isNotBlank(userTokensObj.accessToken)) {
    		try {
		        HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_DELETE,'https://api.box.com/2.0/folders/'+folderId+'?recursive=true','Bearer ' +  userTokensObj.accessToken,null);
		        responseCode=res.getStatusCode();
		        //204 is returned if file is deleted successfully else "412 Precondition Failed" is returned
			    if(responseCode == 403) {
			    	logger.logError('BoxDao.deleteFolder() - ' + responseCode + ' response received from Box API while trying to delete box folder - ' + folderId);
			    	throw new SimpplrException(BoxConstants.BOX_PERMISSION_ERROR);
	    		} else if(responseCode != 204) {
		        	logger.logError('BoxDao.deleteFolder() - ' + responseCode + ' response received from Box API while trying to delete box folder - ' + folderId);
		        	throw new SimpplrException('Failed to delete box folder, ' + responseCode + ' response received from Box.');
		        }
	    	} finally {
				updateUserTokensInDB(userTokensObj);
			}
    	}
        return (responseCode==204);
    }
    
    public Boolean setFolderName(String folderId, String folderName){
    	Boolean success=false;
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
    	if(userTokensObj!=null && String.isNotBlank(userTokensObj.accessToken)) {
    		try {
    			Map<String,String> bodyMap = new Map<String,String>{'name'	=> folderName};
    			String jsonBody = JSON.serialize(bodyMap);
    			
		        HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_PUT,'https://api.box.com/2.0/folders/'+folderId,'Bearer ' +  userTokensObj.accessToken,jsonBody);
		        if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())) {
		        	success = true;
		        } else {
		        	logger.logError('BoxDao.setFolderName() - ' + res.getStatusCode() + ' response received from Box API while trying to set Folder Name for folder - ' + folderId);
		        	throw new SimpplrException('Failed to set Folder name for box folder, ' + res.getStatusCode() + ' response received from Box.');
		        }
	    	} finally {
				updateUserTokensInDB(userTokensObj);
			}
    	}
        return success;
    }
    
    public Boolean setFileDescription(String fileId, String description){
    	Boolean success=false;
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
    	if(userTokensObj!=null && String.isNotBlank(userTokensObj.accessToken)) {
    		try {
    			Map<String,String> bodyMap = new Map<String,String>{'description'	=> description};
    			String jsonBody = JSON.serialize(bodyMap);
    			
		        HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_PUT,'https://api.box.com/2.0/files/'+fileId,'Bearer ' +  userTokensObj.accessToken,jsonBody);
		        if(BoxConstants.BOX_SUCCESS_CODE_SET.contains(res.getStatusCode())) {
		        	success = true;
		        } else {
		        	logger.logError('BoxDao.setFileDescription() - ' + res.getStatusCode() + ' response received from Box API while trying to set File Description for file - ' + fileId);
		        	throw new SimpplrException('Failed to set description for file, ' + res.getStatusCode() + ' response received from Box.');
		        }
	    	} finally {
				updateUserTokensInDB(userTokensObj);
			}
    	}
        return success;
    }
    
    public BoxWrapper.BoxItemCollection searchBoxContents(Set<String> setOfRootFolderIds, String searchText, Integer offset, Integer recordLimit, Boolean fullText) {
    	BoxWrapper.BoxItemCollection folderFileObj;
    	String encodedSearchText = EncodingUtil.urlEncode(searchText, 'UTF-8');
    	BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
		if(userTokensObj != null && String.isNotBlank(userTokensObj.accessToken)) {
			try {
				HttpResponse res;
				if(fullText == false){
					
					res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,'https://api.box.com/2.0/search?query='+ encodedSearchText +'&content_types=name&type=file&fields=name,size,modified_at,created_at,created_by,path_collection,item_collection,parent,permissions&ancestor_folder_ids=' + Utility.convertToCommaSeparatedString(new List<String>(setOfRootFolderIds)) + '&limit=' + recordLimit + '&offset=' + offset, 'Bearer ' + userTokensObj.accessToken,null);
				}
				else{
		    			res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,'https://api.box.com/2.0/search?query='+ encodedSearchText +'&type=file&fields=name,size,modified_at,created_at,created_by,path_collection,item_collection,parent,permissions&ancestor_folder_ids=' + Utility.convertToCommaSeparatedString(new List<String>(setOfRootFolderIds)) + '&limit=' + recordLimit + '&offset=' + offset, 'Bearer ' + userTokensObj.accessToken,null);
				}
		    	if(res.getStatusCode() == 200){
		        	folderFileObj = BoxWrapper.parseBoxItems(res.getBody());
		        } else {
		        	logger.logError('BoxDao.searchBoxContents() - ' + res.getStatusCode() + ' response received from Box API while searching for text - ' + searchText);
		        	throw new SimpplrException('Failed to search box files, ' + res.getStatusCode() + ' response received from Box.');
		        }
			} finally {
				updateUserTokensInDB(userTokensObj);
			}
		}
    	return folderFileObj;
    }
    
    public String getFileDownloadURL(String fileId, String versionId) {
    	String boxFileDownloadUrl;
  		BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
  		if(userTokensObj!=null && !String.isBlank(userTokensObj.accessToken)){
			try {
				String apiURL = 'https://api.box.com/2.0/files/'+fileId+'/content';
				if(String.isNotBlank(versionId) && !fileId.equalsIgnoreCase(versionId)) {
					apiURL += '?version='+versionId;
				}

				HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,apiURL,'Bearer ' +  userTokensObj.accessToken,null);
				if(res.getStatusCode() == 302) {
		        	boxFileDownloadUrl = String.isNotEmpty(res.getHeader('location')) ?
																	res.getHeader('location') :
																	res.getHeader('Location');
		        } else {
		        	throw new SimpplrException(ExceptionCode.BOX_FILE_NOT_FOUND.name());
		        }
			} finally {
				updateUserTokensInDB(userTokensObj);
			}
		}
		return boxFileDownloadUrl;
    }
    
    public Set<String> getRootFolderIdsForSearch(String siteId) {
    	Set<String> setOfRootFolderIds = new Set<String>();
    	if(String.isBlank(siteId) || (String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission))) {
    		setOfRootFolderIds.add('0');
    	} else {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId);
			String folderQuery = 'Select External_Folder_Id__c from Folder__c where Type__c = \'Box\' And site__c =:soqlParam1 And Is_Deleted__c = false AND Is_System_Folder__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfLinkedFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
	    	for(Folder__c folderObj:listOfLinkedFolders) {
	    		setOfRootFolderIds.add(folderObj.External_Folder_Id__c);
	    	} 
    	}
    	return setOfRootFolderIds;
    }
    
    public Boolean bookmarkFile(String fileId) {
  		Boolean success = false;
  		BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
		if(userTokensObj != null && String.isNotBlank(userTokensObj.accessToken)) {
	  		String favoriteCollectionId = userTokensObj.favoriteCollectionId;
			try {	
		  		if(String.isBlank(favoriteCollectionId)) {
		  			favoriteCollectionId = getFavoriteCollectionId(userTokensObj.boxUserId, userTokensObj.accessToken);
		  		}
		  		success = addFileToCollection(fileId, favoriteCollectionId, userTokensObj.accessToken);
			} finally {
				updateUserTokensInDB(userTokensObj);
				//Update Favorite Collection ID in DB, should not be done in updateUserTokensInDB 
				if(String.isBlank(userTokensObj.favoriteCollectionId) &&
				   String.isNotBlank(favoriteCollectionId)) {
				  	updateFavoriteCollectionIdInDB(UserContext.peopleId, favoriteCollectionId);
				}
			}
		}
  		return success;
  	}
  	
  	public Boolean unbookmarkFile(String fileId) {
  		Boolean success = false;
  		BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
		if(userTokensObj != null && String.isNotBlank(userTokensObj.accessToken)) {
	  		String favoriteCollectionId = userTokensObj.favoriteCollectionId;
			try {	
		  		if(String.isBlank(favoriteCollectionId)) {
		  			favoriteCollectionId = getFavoriteCollectionId(userTokensObj.boxUserId, userTokensObj.accessToken);
		  		}
		  		success = removeFileFromCollection(fileId, favoriteCollectionId, userTokensObj.accessToken);
			} finally {
				updateUserTokensInDB(userTokensObj);
				//Update Favorite Collection ID in DB, should not be done in updateUserTokensInDB 
				if(String.isBlank(userTokensObj.favoriteCollectionId) &&
				   String.isNotBlank(favoriteCollectionId)) {
				  	updateFavoriteCollectionIdInDB(UserContext.peopleId, favoriteCollectionId);
				}
			}
		}
  		return success;
  	}
  	
    public Boolean addFileToCollection(String fileId, String collectionId, String apiAccessToken) {
    	Boolean success = false;
    	String jsonBody = '{"collections": [{"id":"' + collectionId + '"}]}';
    	HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_PUT,'https://api.box.com/2.0/files/' + fileId, 'Bearer ' + apiAccessToken,jsonBody);
    	if(res.getStatusCode() == 200){
    		success = true;
    	}
    	return success;
    }
    
    public Boolean removeFileFromCollection(String fileId, String collectionId, String apiAccessToken) {
    	Boolean success = false;
    	String jsonBody = '{"collections": []}';
    	HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_PUT,'https://api.box.com/2.0/files/' + fileId, 'Bearer ' + apiAccessToken,jsonBody);
    	if(res.getStatusCode() == 200){
    		success = true;
    	}
    	return success;
    }
    
    public String getFavoriteCollectionId(String boxUserId, String apiAccessToken) {
    	String favoriteCollectionId;
		BoxWrapper.BoxCollectionWrapper collectionWrapper;
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,'https://api.box.com/2.0/collections/', 'Bearer ' + apiAccessToken,null);
    	if(res.getStatusCode() == 200){
        	collectionWrapper = BoxWrapper.parseBoxCollections(res.getBody());
        } else {
        	logger.logError('BoxDao.getFavoriteCollectionId() - ' + res.getStatusCode() + ' response received from Box API while getting box collections for user - ' + boxUserId);
	        throw new SimpplrException('Failed to get favorite collections from Box, ' + res.getStatusCode() + ' response received from Box.');
        }
        for(BoxWrapper.BoxCollection collectionObj : collectionWrapper.entries) {
        	if('favorites'.equalsIgnoreCase(collectionObj.collection_type)) {
        		favoriteCollectionId = collectionObj.id;
        		break;
        	}
        }
        return favoriteCollectionId;
    }
    
    public void updateFavoriteCollectionIdInDB(String peopleId, String favoriteCollectionId) {
 		List<People_Preference__c> listOfPeoplePreference = [SELECT Id from People_Preference__c where People__c=:peopleId WITH SECURITY_ENFORCED limit 1];
 		if(!listOfPeoplePreference.isEmpty()) {
 			People_Preference__c peoplePreferenceObj = listOfPeoplePreference[0];
 			peoplePreferenceObj.Box_Favorite_Collection_Id__c = favoriteCollectionId;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(peoplePreferenceObj, new List<Schema.SObjectField>{
                People_Preference__c.Box_Favorite_Collection_Id__c});
		}
    }
    
    public List<BoxWrapper.MiniFolderFile> getBookmarkedFiles(Integer offset, Integer recordLimit) {
    	List<BoxWrapper.MiniFolderFile> listOfMiniFolderFile = new List<BoxWrapper.MiniFolderFile>();
  		BoxWrapper.UserTokens userTokensObj = getUserTokens(false,UserContext.peopleId);
		if(userTokensObj != null && String.isNotBlank(userTokensObj.accessToken)) {
	  		String favoriteCollectionId = userTokensObj.favoriteCollectionId;
			try {	
		  		if(String.isBlank(favoriteCollectionId)) {
		  			favoriteCollectionId = getFavoriteCollectionId(userTokensObj.boxUserId, userTokensObj.accessToken);
		  		}
		  		listOfMiniFolderFile = getFavoriteCollectionItems(favoriteCollectionId, userTokensObj.accessToken, offset, recordLimit);
			} finally {
				updateUserTokensInDB(userTokensObj);
				//Update Favorite Collection ID in DB, should not be done in updateUserTokensInDB 
				if(String.isBlank(userTokensObj.favoriteCollectionId) &&
				   String.isNotBlank(favoriteCollectionId)) {
				  	updateFavoriteCollectionIdInDB(UserContext.peopleId, favoriteCollectionId);
				}
			}
		}
  		return listOfMiniFolderFile;
    }
    
    public List<BoxWrapper.MiniFolderFile> getFavoriteCollectionItems(String favoriteCollectionId, String apiAccessToken, Integer offset, Integer recordLimit) {
		List<BoxWrapper.MiniFolderFile> listOfMiniFolderFile = new List<BoxWrapper.MiniFolderFile>();
		HttpResponse res = Utility.getJsonResponseFromExternalSystem(BoxConstants.INT_GET,'https://api.box.com/2.0/collections/' + favoriteCollectionId + '/items?type=files&fields=id,modified_at,created_at,name,created_by,size,path_collection,item_collection,parent,permissions&limit=' + recordLimit +'&offset=' + offset +'&fields=id,size,modified_at,created_at,name,created_by,path_collection,item_collection,parent,permissions&limit=' + recordLimit + '&offset=' + offset, 'Bearer ' + apiAccessToken,null);
    	if(res.getStatusCode() == 200){
    		
    		BoxWrapper.BoxItemCollection boxItemCollectionObj = BoxWrapper.parseBoxItems(res.getBody());
    		//filter only files and store in db
    		listOfMiniFolderFile = filterFilesAndStoreInDB(boxItemCollectionObj);
        } else {
        	logger.logError('BoxDao.getFavoriteCollectionItems() - ' + res.getStatusCode() + ' response received from Box API while get box collection items for  collection Id - ' + favoriteCollectionId);
        	throw new SimpplrException('Failed to get box collection items, ' + res.getStatusCode() + ' response received from Box.');
        }
        return listOfMiniFolderFile;
    }
    
    public List<BoxWrapper.MiniFolderFile> filterFilesAndStoreInDB(BoxWrapper.BoxItemCollection boxItemCollectionObj) {
    	List<BoxWrapper.MiniFolderFile> listOfMiniFolderFile = new List<BoxWrapper.MiniFolderFile>();
    	Set<String> setOfExternalFileIds = new Set<String>();
    	for(BoxWrapper.MiniFolderFile miniFolderFile : boxItemCollectionObj.entries) {
    		if('file'.equalsIgnoreCase(miniFolderFile.type)) {
    			listOfMiniFolderFile.add(miniFolderFile);
    			setOfExternalFileIds.add(miniFolderFile.id);
    		}
    	}
    	updateBookmarksInDB(setOfExternalFileIds);
    	return listOfMiniFolderFile;
    }
    
    public void updateBookmarksInDB(Set<String> setOfExternalFileIds) {
    	
    	List<Bookmark__c> listOfBookmarks = [Select id, External_File_Id__c from Bookmark__c where people__c=:UserContext.peopleId and Type__c='Box'  AND Is_Deleted__c = false WITH SECURITY_ENFORCED];
    	List<Bookmark__c> listOfDeletedBookmarks = new List<Bookmark__c>();
		for(Bookmark__c bookmarkObj:listOfBookmarks) {
			if(setOfExternalFileIds.contains(bookmarkObj.External_File_Id__c)) {
				setOfExternalFileIds.remove(bookmarkObj.External_File_Id__c);
			} else {
				listOfDeletedBookmarks.add(bookmarkObj);
			}
    	}
    	if(listOfDeletedBookmarks.size() > 0) {
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().deleteAsUser(listOfDeletedBookmarks);
    	}
    	
    	List<Bookmark__c> listOfNewBookmarks = new List<Bookmark__c>();
    	for(String externalFileId:setOfExternalFileIds) {
    		Bookmark__c  bookmarkObj = new Bookmark__c(External_File_Id__c = externalFileId,
														Type__c = 'Box', 
														People__c = UserContext.peopleId);
			listOfNewBookmarks.add(bookmarkObj);		
    	}
    	if(listOfNewBookmarks.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	   		SIMPESAPI.accessController().insertAsUser(listOfNewBookmarks,
	   												new List<Schema.SObjectField>{
	   													Bookmark__c.External_File_Id__c,
	   													Bookmark__c.Type__c, 
	   													Bookmark__c.People__c});
    	}
    }
}