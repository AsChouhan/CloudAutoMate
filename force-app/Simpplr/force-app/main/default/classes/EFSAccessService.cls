/*
* Purpose: Service class for the Access related activities
*
* Constructors in EFSAccessService
* 01. EFSAccessService(Boolean)
*
* Functions in EFSAccessService
* 01. String getTokenType()
* 02. String getAccessToken()
* 03. Datetime getAccessTokenExpiresIn()
* 04. String getStorageType()
* 05. Boolean isAdmin()
* 06. Boolean isSaved()
* 07. void setUser(String)
* 08. void close()
* 09. Boolean isAccessValid()
* 10. Boolean isAccessExpired()
* 11. System.PageReference getAuthPage()
* 12. Boolean refreshToken(String)
* 13. Boolean refreshToken()
* 14. Boolean setToken(AccessTokenResponse, Boolean)
* 15. Boolean saveToken()
* 16. String getAccessTypeAndToken()
* 17. String getAuthURL(String)
* 18. String getAuthorizationEndpoint()
* 19. String getTokenEndpoint()
* 20. String getClientId()
* 21. String getClientSecret()
* 22. String getRedirectUri()
* 23. String getExtraUrlParameters()
*/
public with sharing class EFSAccessService implements SCoreIConnectorType {

	
	//Instance Constants
	public static final Integer EXPIRY_HEADROOM_TIME_SECONDS = 300; // 5 minutes
	
	//Instance variables
	public App_Integration__c appInteg { get; set; }
	public People_Integration__c pplInteg { get; set; }
	
	public String fileStorage { get; set; }
	
	// Flag to read Simpplr Context or User Context
	private Boolean adminFlag { get; set; }	
	public Boolean isAdmin() { return adminFlag; }
	
	// Flag to track whether the refreshed Token is Saved to the DB or not
	private Boolean dbSavedFlag { get; set; }	
	public Boolean isSaved() { return dbSavedFlag; }
	
	// Storage Type Flags
	public Boolean dropboxFlag = false;
	public Boolean boxFlag = false;
	public Boolean sharepointFlag = false;
	public Boolean onedriveFlag = false;
	
	// Others
	private SCoreOAuthClient client { get; set; }
    private String tokenType { get; set; }
    private String accessToken { get; set; }
    private String refreshToken { get; set; }
    private DateTime accessTokenExpiresIn { get; set; }
	
	public String getTokenType() { return tokenType; }
	public String getAccessToken() { return accessToken; }
	public DateTime getAccessTokenExpiresIn() { return accessTokenExpiresIn; }

	private List<Schema.SObjectField> fieldListForUpsert;

	private static final Map<String, String> AUTH_ENDPOINT_MAP = new Map<String, String> {
		'dropbox' => 'https://www.dropbox.com/oauth2/authorize',
		'sharepoint' => 'https://login.microsoftonline.com/common/oauth2/authorize',
		'onedrive' => 'https://login.microsoftonline.com/common/oauth2/authorize'
	};
	
    public EFSAccessService(People_Integration__c pplInteg, String storage, Boolean adminFlg) {
        fileStorage = storage;	
        dbSavedFlag = true;
        adminFlag = adminFlg;

		fieldListForUpsert = new List<Schema.SObjectField>();

        checkEFSBlank();

        if ('dropbox'.equalsIgnoreCase(fileStorage)) {
			dropboxFlag = true;	
		} else if ('sharepoint'.equalsIgnoreCase(fileStorage)) {
			sharepointFlag = true;	
		} else if ('onedrive'.equalsIgnoreCase(fileStorage)) {
			onedriveFlag = true;	
		}
        appInteg = SimpplrContext.Integrations.get(storage);
        if(pplInteg != null && pplInteg.Access_Token_Requested_Datetime__c != null && pplInteg.Access_Token_Expiry__c != null) {
            Datetime expIn = pplInteg.Access_Token_Requested_Datetime__c;
            accessTokenExpiresIn = expIn.addSeconds((Integer)(pplInteg.Access_Token_Expiry__c - EXPIRY_HEADROOM_TIME_SECONDS));
        } 
        
        if(pplInteg != null && pplInteg.Token_Type__c != null && pplInteg.Access_Token__c != null) {
            tokenType = pplInteg.Token_Type__c;
            accessToken = pplInteg.Access_Token__c;
            refreshToken = pplInteg.Refresh_Token__c;
        }
    }

	// Constructor for Admin/User
	public EFSAccessService(String storage, Boolean adminFlg) {
		EFSException.addTrace('EFSAccessService(' + storage + ',' + adminFlg + ')');
		
		fileStorage = storage;	
		adminFlag = adminFlg;
		
		dbSavedFlag = true;

		fieldListForUpsert = new List<Schema.SObjectField>();
		
		checkEFSBlank();
		
		if ('dropbox'.equalsIgnoreCase(fileStorage)) {
			dropboxFlag = true;	
		} else if ('sharepoint'.equalsIgnoreCase(fileStorage)) {
			sharepointFlag = true;	
		} else if ('onedrive'.equalsIgnoreCase(fileStorage)) {
			onedriveFlag = true;	
		}
		
		appInteg = SimpplrContext.Integrations.get(storage);
		if(adminFlag) {
			if(appInteg != null && appInteg.Access_Token_Requested_Datetime__c != null && appInteg.Access_Token_Expiry__c != null) {
				Datetime expIn = appInteg.Access_Token_Requested_Datetime__c;
				accessTokenExpiresIn = expIn.addSeconds((Integer)(appInteg.Access_Token_Expiry__c - EXPIRY_HEADROOM_TIME_SECONDS));
			} 
			
			if(appInteg != null && appInteg.Token_Type__c != null && appInteg.App_Access_Token__c != null) {
				tokenType = appInteg.Token_Type__c;
				accessToken = appInteg.App_Access_Token__c;
				refreshToken = appInteg.App_Refresh_Token__c;
			}
		} else {
		
			pplInteg = UserContext.Integrations.get(storage);
		
			if(pplInteg != null && pplInteg.Access_Token_Requested_Datetime__c != null && pplInteg.Access_Token_Expiry__c != null) {
				Datetime expIn = pplInteg.Access_Token_Requested_Datetime__c;
				accessTokenExpiresIn = expIn.addSeconds((Integer)(pplInteg.Access_Token_Expiry__c - EXPIRY_HEADROOM_TIME_SECONDS));
			} 
			
			if(pplInteg != null && pplInteg.Token_Type__c != null && pplInteg.Access_Token__c != null) {
				tokenType = pplInteg.Token_Type__c;
				accessToken = pplInteg.Access_Token__c;
				refreshToken = pplInteg.Refresh_Token__c;
			}
		}
	}
	
	public void checkEFSBlank() {
		if(adminFlag && SimpplrContext.integrations == null) {
			logger.logError('EFSFileService EFSAccessService()');
        	throw new EFSException('BLANKVALUES','No Admin Account is setup');	
		}
		
		if(!adminFlag && (SimpplrContext.integrations == null || UserContext.integrations == null)) {
			logger.logError('EFSFileService EFSAccessService() - ');
        	throw new EFSException('BLANKVALUES','No Admin Account or User Account is setup');
		}
	}
	
	// Method to override the UserContext.Integrations
	public static void setUser(String usrId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', usrId);
		String queryStr = 'Select Id, Unsuccessful_Group_Id_Set__c,My_Drive_Id__c,'+
				' Connected__c, name, Group_Id_Set__c, Access_Token_Expiry__c,People__c, People__r.Id,People__r.Full_Name__c, '+
				' Access_Token_Requested_Datetime__c, User_Name__c,User_Email__c, user__c,People__r.Name,'+
				' Access_Token__c, Refresh_Token_Requested_Datetime__c, Refresh_Token__c, Token_Type__c '+
				' From People_Integration__c WHERE (People__r.User__c=:soqlParam1 OR People__c=:soqlParam1) and is_deleted__c=false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleIntegList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		for(People_Integration__c obj : peopleIntegList) {
			UserContext.integrations.put(obj.name, obj);
		}  
	}
	
	// Function to do the clean ups and final steps
	public void close() {
		EFSException.addTrace('close()');
		
    	// Function that saves the token to DB
		if(!this.dbSavedFlag) {
			saveToken();
		}
	}
    
    // Function to check whether AccessToken and RefreshToken exist
    public Boolean isAccessValid() {
    	EFSException.addTrace('isAccessValid()');
    	
    	if(String.isBlank(accessToken) || String.isBlank(refreshToken)) {
    		return false;
    	}
    	return true;
    }
    
    // Function to check whether existing Access Token is valid or not
    public Boolean isAccessExpired() {
    	EFSException.addTrace('isAccessExpired()');
    	
    	return (accessTokenExpiresIn < System.now());
    }
	
	// Function to refresh the AccessToken using Auth Code
	public Boolean refreshToken(String codefromPage) {
		//logger.logDebug('EFSAccessService refreshToken() ----codefromPage----' + codefromPage);
		EFSException.addTrace('refreshToken(' + codefromPage + ')');
		
		try {
			SCoreOAuthClient client = new SCoreOAuthClient();
			client.setClientType(fileStorage);
			
			SCoreOAuthClient.AccessTokenResponse response;
	
			SCoreOAuthClient.ExchangeAuthCodeRequest accessRequest = null;
			if(sharepointFlag || onedriveFlag) {
				IntegrationService.ADAuthCodeRequestBody content = new IntegrationService.ADAuthCodeRequestBody(this, 'authorization_code', codefromPage, 'https://graph.microsoft.com', '');
				accessRequest = new SCoreOAuthClient.ExchangeAuthCodeRequest(client, this.getTokenEndpoint(), (SCoreIHttpContent)content);	
			} else {
				accessRequest = client.exchangeAuthCodeRequest(this, codefromPage);
			}
			response = (SCoreOAuthClient.AccessTokenResponse)accessRequest.execute();
			
			tokenType =  (dropboxFlag && 'bearer'.equals(response.token_type)) ? 'Bearer' : response.token_type;
		    accessToken = response.access_token;

		    
			accessTokenExpiresIn = System.now().addSeconds((Integer)response.expires_in - 
					EXPIRY_HEADROOM_TIME_SECONDS);
		    
			if(this.adminFlag) {
				return setToken(response, true);
			} else {
				if(setToken(response, true)) {
					return saveToken();
				} else if(!this.isAccessExpired()) {
					return saveToken();
				}
			}
			return false;
		} catch(Exception e) {
			this.close();
        	throw new EFSException('refreshToken(auth) PROCESS ERROR',e.getMessage());
		}
	}
	
	/**
	* @description Function to refresh the AccessToken using Refresh Token
	* @return 'Boolean' true when there is no error otherwise false
	*/
	public Boolean isRefreshTokenValid() {
		EFSException.addTrace('refreshToken()');
		// If Access is not Valid return false
		if(!isAccessValid()) {
			//logger.logError('EFSFileService refreshToken()');
			throw new EFSException('AccessException', 'Invalid Access/Refresh Token');
		}
		
		try {
			SCoreOAuthClient client = new SCoreOAuthClient();
			client.setClientType(fileStorage);
			
			SCoreOAuthClient.AccessTokenResponse response;
	
			SCoreOAuthClient.ExchangeRefreshTokenRequest refreshRequest = null;
			if(sharepointFlag || onedriveFlag) {
				IntegrationService.ADAuthCodeRequestBody content = new IntegrationService.ADAuthCodeRequestBody(this, 'refresh_token', '', 'https://graph.microsoft.com', this.refreshToken);
				refreshRequest = new SCoreOAuthClient.ExchangeRefreshTokenRequest(client, this.getTokenEndpoint(), (SCoreIHttpContent)content);
			} else { 
				refreshRequest = client.exchangeRefreshTokenRequest(this, this.refreshToken);
			}
			
			response = (SCoreOAuthClient.AccessTokenResponse)refreshRequest.execute();
			
			this.tokenType =  (dropboxFlag && 'bearer'.equals(response.token_type)) ? 'Bearer' : response.token_type;
			this.accessToken = response.access_token;
			this.accessTokenExpiresIn = System.now().addSeconds((Integer)response.expires_in - 
					EXPIRY_HEADROOM_TIME_SECONDS);
			
			return setToken(response, false);
		} catch(SCoreAppException appEx) {			
			this.close();
			return false;
		}
	}

	// Function to refresh the AccessToken using Refresh Token
	public Boolean refreshToken() {
		EFSException.addTrace('refreshToken()');
		// If Access is not Valid return false
		if(!isAccessValid()) {
        	//logger.logError('EFSFileService refreshToken()');
        	throw new EFSException('AccessException', 'Invalid Access/Refresh Token');
		}
		
		try {
			SCoreOAuthClient client = new SCoreOAuthClient();
			client.setClientType(fileStorage);
			
			SCoreOAuthClient.AccessTokenResponse response;
	
			SCoreOAuthClient.ExchangeRefreshTokenRequest refreshRequest = null;
			if(sharepointFlag || onedriveFlag) {
				IntegrationService.ADAuthCodeRequestBody content = new IntegrationService.ADAuthCodeRequestBody(this, 'refresh_token', '', 'https://graph.microsoft.com', this.refreshToken);
				refreshRequest = new SCoreOAuthClient.ExchangeRefreshTokenRequest(client, this.getTokenEndpoint(), (SCoreIHttpContent)content);
			} else { 
				refreshRequest = client.exchangeRefreshTokenRequest(this, this.refreshToken);
			}
			
			response = (SCoreOAuthClient.AccessTokenResponse)refreshRequest.execute();
			
		    this.tokenType =  (dropboxFlag && 'bearer'.equals(response.token_type)) ? 'Bearer' : response.token_type;
		    this.accessToken = response.access_token;
		    this.accessTokenExpiresIn = System.now().addSeconds((Integer)response.expires_in - 
		    		EXPIRY_HEADROOM_TIME_SECONDS);
		    
			return setToken(response, false);
		} catch(SCoreAppException appEx) {			
			this.close();
			List<People_Integration__c> listOfPeopleInte = [Select Id, Name, People__c 
					FROM People_Integration__c 
					WHERE People__c = :UserContext.peopleId
					AND name=:fileStorage WITH SECURITY_ENFORCED];

			if (!listOfPeopleInte.isEmpty()) {
				listOfPeopleInte[0].Is_Deleted__c = true;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(listOfPeopleInte[0], new List<Schema.SObjectField>{									
																People_Integration__c.Is_Deleted__c
															});
			}

			return false;
		}
	}

    /**
    * @description This method is used to get access token for sharepoint
    * @param codefromPage this is the authorization code received from redirectUrl of PeopleDataServer
    * @return SCoreOAuthClient.AccessTokenResponse this is the returned response from access token request
    */
    public SCoreOAuthClient.AccessTokenResponse getSPAccessToken(String codefromPage) {
        SCoreOAuthClient.AccessTokenResponse response;
        if(!String.isBlank(codefromPage)) {
            SCoreOAuthClient client = new SCoreOAuthClient();
            client.setClientType(fileStorage);
            IntegrationService.ADAuthCodeRequestBody content = new IntegrationService.ADAuthCodeRequestBody(this, 'authorization_code', codefromPage, 'https://graph.microsoft.com', '');
            SCoreOAuthClient.ExchangeAuthCodeRequest accessRequest = new SCoreOAuthClient.ExchangeAuthCodeRequest(client, this.getTokenEndpoint(), (SCoreIHttpContent)content);	
            response = (SCoreOAuthClient.AccessTokenResponse)accessRequest.execute();
            if(response != null) {
                tokenType =  'bearer'.equals(response.token_type) ? 'Bearer' : response.token_type;
                accessToken = response.access_token;
                accessTokenExpiresIn = System.now().addSeconds((Integer)response.expires_in - EXPIRY_HEADROOM_TIME_SECONDS);
            }
        }
        return response;
    }

    /**
    * @description This method finds the instance id of sharepoint logged in user
    * @return String having instance id
    */
    public MSAPIModelUser.Organization getSPInstanceInfo() {
        if(getTokenType() != null && getAccessToken() != null) {
            SCoreClient.Credentials cred = new SCoreClient.Credentials(getTokenType(), getAccessToken());
            MSAPIClient msapiClient = new MSAPIClient(cred, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
            MSAPIUser usr = new MSAPIUser(msapiClient);
            
            MSAPIUser.OrganizationDetail orgReq = new MSAPIUser.OrganizationDetail(usr);
            MSAPIModelUser.OrganizationList orgInfo = (MSAPIModelUser.OrganizationList) orgReq.execute();
            return orgInfo.value.size() > 0 ? orgInfo.value[0] : null;
        }
        return null;
    }

    /**
    * @description This method finds the weather a sharepint user is admin or not
    * @return String having instance id
    */
   public Boolean isSPAdmin() {
        Boolean isAdmin = false;
        if(getTokenType() != null && getAccessToken() != null) {
            SCoreClient.Credentials cred = new SCoreClient.Credentials(getTokenType(), getAccessToken());
            MSAPIClient msapiClient = new MSAPIClient(cred, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
            MSAPIUser usr = new MSAPIUser(msapiClient);
            
            MSAPIUser.GroupsMemberOf usrReq = new MSAPIUser.GroupsMemberOf(usr);
            MSAPIModelUser.GroupList groupInfo = (MSAPIModelUser.GroupList) usrReq.execute();
            for(MSAPIModelUser.GraphGroup grp:groupInfo.value) {
                if(grp.displayName == ServiceConstants.SHAREPOINT_ADMINISTRATOR) {
                    isAdmin = true;
                    break;
                }
            }
        }
        return isAdmin;
    }

    /**
    * @description This method checks if a sharepoint administrator is already connected or not, if not then connect
    * @param codefromPage this is the authorization code received from redirectUrl of PeopleDataServer
    * @return Boolean flag is an admin is connect or not
    */
    public Boolean isSharepointConnected(String codefromPage) {
        Boolean isConnected = false;
        try {
            SCoreOAuthClient.AccessTokenResponse response = getSPAccessToken(codefromPage);
            MSAPIModelUser.Organization orgInfo = getSPInstanceInfo();
            String instanceId = orgInfo?.id;
            Boolean isUserSPAdmin = isSPAdmin();
            
            isConnected = populatePeopleIntegration(response, orgInfo, isUserSPAdmin);
        } catch(SCoreAppException eX) {			
            logger.logError('EFSAccessService.isSharepointAdminConnected()---Exception occured----', ex);
        }
        return isConnected;
    }

    /**
    * @description This method populates admin and instance id on the people integration record
    * @param response this is the callout response for access token, instanceId is th id of the sharepoint org
    * @param orgInfo this is object having intance id and name of the sharepoint instance current user is connected to
    * @param isSPAdmin this tells if the logged in user is sharepoitn admin or not
    * @return Boolean flag true if token saved successfully
    */
    public Boolean populatePeopleIntegration(SCoreOAuthClient.AccessTokenResponse response, MSAPIModelUser.Organization orgInfo, Boolean isSPAdmin) {
        pplInteg = pplInteg == null ? new People_Integration__c() : pplInteg;
        pplInteg.Is_SP_Admin__c = isSPAdmin;
        pplInteg.SP_Instance_Id__c = orgInfo?.id;
        pplInteg.SP_Instance_Name__c = orgInfo?.displayName;
		fieldListForUpsert.add(People_Integration__c.Is_SP_Admin__c);
		fieldListForUpsert.add(People_Integration__c.SP_Instance_Id__c);
		fieldListForUpsert.add(People_Integration__c.SP_Instance_Name__c);
		if(setToken(response, true)) {
			return saveToken();
		} else {
			return false;
		}
    }

    /**
    * @description This method finds if folder is accessible or not by logged in user
    * @return Boolean for accessibility
    * @param folderId is the external id of the folder
    */
    public Boolean isSPFolderAccessible(String folderId) {
        Boolean isAccessible = false;
        if(folderId != null) {
            if(isAccessExpired()) {
                refreshToken();
            }
            SCoreClient.Credentials cred = new SCoreClient.Credentials(getTokenType(), getAccessToken());
            MSAPIClient msapiClient = new MSAPIClient(cred, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
            MSAPIUser usr = new MSAPIUser(msapiClient);
            
            MSAPIUser.FolderAccess orgReq = new MSAPIUser.FolderAccess(usr, folderId);
            MSAPIModelUser.FolderPermissionResponse folderAccess = (MSAPIModelUser.FolderPermissionResponse) orgReq.execute();
            isAccessible = folderAccess != null && folderAccess.error == null ? true : false;
        }
        return isAccessible;
    }

	// Function that sets the Access Token to EFSFields 
	public Boolean setToken(SCoreOAuthClient.AccessTokenResponse response, Boolean authFlag) {
		EFSException.addTrace('setToken(' + response + ')');
		
		String usrName = '';
		String usrId = '';
		String usrEmail = '';
		String userMyDriveId = '';
		String sharepointDomain = '';
		if(this.adminFlag && appInteg == null) {
			appInteg = new App_Integration__c();
			appInteg.Name = fileStorage;
			appInteg.Org_Id__c = UserInfo.getOrganizationId();

			fieldListForUpsert.add(App_Integration__c.Name);
			fieldListForUpsert.add(App_Integration__c.Org_Id__c);
			
			if(dropboxFlag) {
				appInteg.Client_Id__c = EFSConstants.DROPBOX_ADMIN_CLIENT_ID;
				appInteg.Client_Secret__c = EFSConstants.DROPBOX_ADMIN_CLIENT_SECRET;
				appInteg.DB_User_Client_Id__c = EFSConstants.DROPBOX_USER_CLIENT_ID;
				appInteg.DB_User_Client_Secret__c = EFSConstants.DROPBOX_USER_CLIENT_SECRET;
				appInteg.Extra_URL_Parameters__c = 'force_reapprove=true';

				fieldListForUpsert.add(App_Integration__c.Client_Id__c);
				fieldListForUpsert.add(App_Integration__c.Client_Secret__c);
				fieldListForUpsert.add(App_Integration__c.DB_User_Client_Id__c);
				fieldListForUpsert.add(App_Integration__c.DB_User_Client_Secret__c);
				fieldListForUpsert.add(App_Integration__c.Extra_URL_Parameters__c);

			} else if(sharepointFlag || onedriveFlag) {
				appInteg.Client_Id__c = EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_ID;
				appInteg.Client_Secret__c = EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_SECRET;
				appInteg.Extra_URL_Parameters__c = 'prompt=admin_consent';

				fieldListForUpsert.add(App_Integration__c.Client_Id__c);
				fieldListForUpsert.add(App_Integration__c.Client_Secret__c);
				fieldListForUpsert.add(App_Integration__c.Extra_URL_Parameters__c);
			}
		}
		
		if(authFlag) {
			try {
				// Get the Credentials
				String tknType = 'bearer'.equalsIgnoreCase(response.token_type) ? 'Bearer' : response.token_type; 
		   		SCoreClient.Credentials cred = new SCoreClient.Credentials(tknType, response.access_token);
				
				// About call to get the user details			
				if(dropboxFlag) {
			    	// Call to get the user details
				    DBAPIClient client = new DBAPIClient(cred);
					DBAPIMember mem = new DBAPIMember(client);
									    	
			    	if(adminFlag) {
			    		DBAPIMember.AdminAccount admReq = new DBAPIMember.AdminAccount(mem);
						Map<String, DBAPIModelUser> admResp = (Map<String, DBAPIModelUser>)admReq.execute();
					    
					    DBAPIModelUser adm = admResp.get('admin_profile');
						usrName = adm.name.display_name;
						usrId = adm.account_id;
						usrEmail = adm.email;
						userMyDriveId = adm.member_folder_id;					    	
			    	} else {
						DBAPIMember.UserAccount usrReq = new DBAPIMember.UserAccount(mem);
						DBAPIModelUser usr = (DBAPIModelUser)usrReq.execute();
					    	
					   	usrName = usr.name.display_name;
					   	usrId = usr.account_id;
					   	usrEmail = usr.email;
					   	userMyDriveId = SimpplrContext.ApplicationName;
			    	}   	
			    } else if(sharepointFlag) {
				    MSAPIClient client = new MSAPIClient(cred, fileStorage);
					MSAPIUser usr = new MSAPIUser(client);
					
					MSAPIUser.CurrentUserDetail usrReq = new MSAPIUser.CurrentUserDetail(usr);
					MSAPIModelUser ownerInfo = (MSAPIModelUser)usrReq.execute();

				   	usrName = ownerInfo.displayName;
				   	usrId = ownerInfo.id;
					usrEmail = ownerInfo.mail != null ? ownerInfo.mail : ownerInfo.userPrincipalName;
					if(adminFlag) {
						sendSharepointTokenResponseToAWS(response);
					} else {
						if(SimpplrContext.isSharepointUpgraded) {
							List<App_Integration__c> appIntegList = new List<App_Integration__c>();
							Map<String, Object> soqlParamMap = new Map<String, Object>();
							soqlParamMap.put('soqlParam1', ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
							soqlParamMap.put('soqlParam2', SimpplrContext.simpplrOrgId);
								
							String appIntQuery = 'SELECT Id, Name, Whitelist_Domain__c FROM App_Integration__c where Is_Deleted__c = false and Integration_Enabled__c = true and Name =: soqlParam1 and Org_Id__c =: soqlParam2';
								
							SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
							appIntegList = (List<App_Integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, soqlParamMap);
							SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
							Boolean domainExists = false; 
							if(appIntegList != null && appIntegList.size() > 0 && String.isNotBlank(appIntegList[0].Whitelist_Domain__c)) {
								sharepointDomain = usrEmail.split('@')[1];
								Set<String> existingSharepointDomainSet = new Set<String>(appInteg.Whitelist_Domain__c.split(','));
								for(String domain : existingSharepointDomainSet){
									if(domain.equalsIgnoreCase(sharepointDomain)){
										domainExists = true;
									}
								}
								if (!domainExists) {
									return false;
								}
							} else {
								return false;
							}
						}

						if(EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID.equalsIgnoreCase(SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).Client_Id__c)){
							sendUserSharepointTokenResponseToAWS(response);
						}
					}   
			    } else if (onedriveFlag) {
				    MSAPIClient client = new MSAPIClient(cred, fileStorage);
					MSAPIUser usr = new MSAPIUser(client);
					
					MSAPIUser.CurrentUserDriveDetail usrDriveReq = new MSAPIUser.CurrentUserDriveDetail(usr);
					MSAPIModelDrive driveResp = (MSAPIModelDrive)usrDriveReq.execute();
				
					MSAPIModelUser.Identity ownerInfo = driveResp.owner.user;
				    	
				   	usrName = ownerInfo.displayName;
				   	usrId = ownerInfo.id;
				   	usrEmail = ownerInfo.email;
				   	userMyDriveId = driveResp.id;
			    }
			    
			    if(String.isNotBlank(usrEmail)) {
					String domainName = usrEmail.split('@')[1];
	
				   	// Check the domain existance when connecting the Service Account
				   	if(adminFlag) {
						appInteg.Enterprise_Id__c = domainName;
						fieldListForUpsert.add(App_Integration__c.Enterprise_Id__c);
				   	}
			    }
			} catch(Exception e) {
				this.close();
	        	throw new EFSException('setToken() PROCESS ERROR', e.getMessage());
			}
		}
		
		if(this.adminFlag) {
			appInteg.App_Access_Token__c = response.access_token;
			fieldListForUpsert.add(App_Integration__c.App_Access_Token__c);
			if(String.isNotBlank(response.refresh_token)) {
				appInteg.App_Refresh_Token__c = response.refresh_token;
				fieldListForUpsert.add(App_Integration__c.App_Refresh_Token__c);
			}
			if(authFlag) {				
				appInteg.User_Name__c = usrName;
				appInteg.User_Email__c = usrEmail;
				appInteg.External_Id__c = usrId;

				fieldListForUpsert.add(App_Integration__c.User_Name__c);
				fieldListForUpsert.add(App_Integration__c.User_Email__c);
				fieldListForUpsert.add(App_Integration__c.External_Id__c);
			}

		    appInteg.Token_Type__c = (dropboxFlag && 'bearer'.equals(response.token_type)) ? 'Bearer' : response.token_type;
		    appInteg.Access_Token_Expiry__c = response.expires_in;
		    appInteg.Access_Token_Requested_Datetime__c = System.now();
		    appInteg.Connected__c = true;
		    appInteg.Integration_Enabled__c = true;

			fieldListForUpsert.add(App_Integration__c.Token_Type__c);
			fieldListForUpsert.add(App_Integration__c.Access_Token_Expiry__c);
			fieldListForUpsert.add(App_Integration__c.Access_Token_Requested_Datetime__c);
			fieldListForUpsert.add(App_Integration__c.Connected__c);
			fieldListForUpsert.add(App_Integration__c.Integration_Enabled__c);
			
			if(dropboxFlag) {
				appInteg.Connected_DateTime__c = DateTime.now();
				EFSGroupService gs = new EFSGroupService(this);
				appInteg.All_Company_Group_Id__c = gs.createGroup(SimpplrContext.applicationName + '[' + UserInfo.getOrganizationId()+ '] Company Group', 'Read Group for All Company', UserInfo.getOrganizationId()+'@'+appInteg.Enterprise_Id__c);
				appInteg.Root_Folder_Id__c = '/' + SimpplrContext.applicationName;

				fieldListForUpsert.add(App_Integration__c.Connected_DateTime__c);
				fieldListForUpsert.add(App_Integration__c.All_Company_Group_Id__c);
				fieldListForUpsert.add(App_Integration__c.Root_Folder_Id__c);

				gs.close();
			}
		    SimpplrContext.integrations.put(fileStorage, appInteg);
		} else {
			if(pplInteg == null) { pplInteg = new People_Integration__c(); }
			// Parent Records
			pplInteg.people__c = UserContext.PeopleId; 
			pplInteg.User__c = UserContext.Id;
			pplInteg.App_Integration__c = appInteg.Id;
			pplInteg.Name = fileStorage;
			if(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT.equalsIgnoreCase(fileStorage)) {
				pplInteg.Domain__c = sharepointDomain;
				fieldListForUpsert.add(People_Integration__c.Domain__c);
			}
			
			pplInteg.Access_Token__c = response.access_token;

			fieldListForUpsert.add(People_Integration__c.people__c);
			fieldListForUpsert.add(People_Integration__c.User__c);
			fieldListForUpsert.add(People_Integration__c.App_Integration__c);
			fieldListForUpsert.add(People_Integration__c.Name);
			fieldListForUpsert.add(People_Integration__c.Access_Token__c);

			if(String.isNotBlank(response.refresh_token)) {
				pplInteg.Refresh_Token__c = response.refresh_token;
				fieldListForUpsert.add(People_Integration__c.Refresh_Token__c);
			}
			if(authFlag) {				
				pplInteg.User_Name__c = usrName;
				pplInteg.User_Email__c = usrEmail;
				pplInteg.External_Id__c = usrId;
				pplInteg.My_Drive_Id__c = userMyDriveId;

				fieldListForUpsert.add(People_Integration__c.User_Name__c);
				fieldListForUpsert.add(People_Integration__c.User_Email__c);
				fieldListForUpsert.add(People_Integration__c.External_Id__c);
				fieldListForUpsert.add(People_Integration__c.My_Drive_Id__c);				
			}
		    pplInteg.Token_Type__c = (dropboxFlag && 'bearer'.equals(response.token_type)) ? 'Bearer' : response.token_type;
		    pplInteg.Access_Token_Expiry__c = response.expires_in;
		    pplInteg.Access_Token_Requested_Datetime__c = System.now();
		    pplInteg.Connected__c = true;

			fieldListForUpsert.add(People_Integration__c.Token_Type__c);
			fieldListForUpsert.add(People_Integration__c.Access_Token_Expiry__c);
			fieldListForUpsert.add(People_Integration__c.Access_Token_Requested_Datetime__c);
			fieldListForUpsert.add(People_Integration__c.Connected__c);		
		   UserContext.integrations.put(fileStorage, pplInteg);
		}
		
		this.dbSavedFlag = false;
		return true;
	}
	
	// Function to save the token to the DB
	public boolean saveToken() {
		EFSException.addTrace('saveToken()');
		
		try {
			if(this.adminFlag) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().upsertAsUser(new List<App_Integration__c>{appInteg},fieldListForUpsert); 			
			} else {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().upsertAsUser(new List<People_Integration__c>{pplInteg},fieldListForUpsert); 	
			}
			dbSavedFlag = true;
		} catch(Exception e) {
			dbSavedFlag = false;
        	throw new EFSException('saveToken() PROCESS ERROR',e.getMessage());
		}
		return dbSavedFlag;
	}
	
    // Function to get the Access Token for the User
    public String getAccessTypeAndToken() {
    	//logger.logDebug('EFSAccessService getAccessTypeAndToken()');
    	EFSException.addTrace('getAccessTypeAndToken()');
    	
    	return tokenType + ' ' + accessToken;
    }
    
    // Function to get user external id
    public string getEFSUserId() {
    	try {
    		return this.pplInteg.External_Id__c;
    	} catch (NullPointerException np) {
    		return '';
    	}
    }

	// Function/Page to get the Authorization from the User
	public PageReference getAuthPage() {
		EFSException.addTrace('getAuthPage()');
		
		this.client = new SCoreOAuthClient();
		String url = this.client.generateAuthorizationUrl((SCoreIConnectorType)this, fileStorage + (adminFlag ? 'admin' : ''));
		
		if(dropboxFlag) {
			url += '&force_reapprove=true';	
		} else if(sharepointFlag || onedriveFlag) {
			url += '&response_mode=query'; //'&prompt=admin_consent';				
		}
		
		return new PageReference(url);
	}

	public String getAuthUrlAdmin() {
		EFSException.addTrace('getAuthPage()');
		
		this.client = new SCoreOAuthClient();
		String url = this.client.generateAuthorizationUrl((SCoreIConnectorType)this, fileStorage + (adminFlag ? 'admin' : ''));
		
		if(dropboxFlag) {
			url += '&force_reapprove=true&token_access_type=offline';
		} else if(sharepointFlag || onedriveFlag) {
			url += '&response_mode=query'; //'&prompt=admin_consent';				
		}
		
		return url;
	}

	private void sendSharepointTokenResponseToAWS(SCoreOAuthClient.AccessTokenResponse accessTokenResponse) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=saveSharepointToken');
        req.setTimeout(60000);
        req.setHeader('Content-Type', 'application/json');
		req.setMethod('POST');
		Map<String, String> requestBody = new Map<String, String>();
		requestBody.put('orgId', UserInfo.getOrganizationId());
		requestBody.put('token_type', accessTokenResponse.token_type);
		requestBody.put('access_token', accessTokenResponse.access_token);
		requestBody.put('refresh_token', accessTokenResponse.refresh_token);
		requestBody.put('id_token', accessTokenResponse.id_token);
		requestBody.put('resource', accessTokenResponse.resource);
		requestBody.put('scope', accessTokenResponse.scope);
		requestBody.put('expires_in', String.valueOf(accessTokenResponse.expires_in));
		requestBody.put('ext_expires_in', String.valueOf(accessTokenResponse.ext_expires_in));
		requestBody.put('expires_on', accessTokenResponse.expires_on);
		requestBody.put('not_before', accessTokenResponse.not_before);

		logger.logDebug('EFSAccessService.sendSharepointTokenResponseToAWS()----requestBody----' + requestBody);
		req.setBody(Json.serialize(requestBody));
        HttpResponse res = h.send(req); 		
	}

	private void sendUserSharepointTokenResponseToAWS(SCoreOAuthClient.AccessTokenResponse accessTokenResponse) {
		Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getDrivesForUser');
        req.setTimeout(60000);
        req.setHeader('Content-Type', 'application/json');
		req.setMethod('POST');
		Map<String, String> requestBody = new Map<String, String>();
		requestBody.put('orgId', UserInfo.getOrganizationId());
		requestBody.put('token_type', accessTokenResponse.token_type);
		requestBody.put('access_token', accessTokenResponse.access_token);
		requestBody.put('refresh_token', accessTokenResponse.refresh_token);
		requestBody.put('id_token', accessTokenResponse.id_token);
		requestBody.put('resource', accessTokenResponse.resource);
		requestBody.put('scope', accessTokenResponse.scope);
		requestBody.put('expires_in', String.valueOf(accessTokenResponse.expires_in));
		requestBody.put('ext_expires_in', String.valueOf(accessTokenResponse.ext_expires_in));
		requestBody.put('expires_on', accessTokenResponse.expires_on);
		requestBody.put('not_before', accessTokenResponse.not_before);
		req.setBody(Json.serialize(requestBody));
        HttpResponse res = h.send(req); 		
	}
	
	// Method to return the Auth URL for the Users
	public static String getAuthURL(String state) {
		String clientId = SimpplrContext.Integrations.get(state).Client_Id__c;
		if(state.equalsIgnoreCase('dropbox')) {
			clientId = SimpplrContext.Integrations.get(state).DB_User_Client_Id__c;
		}
		
		String url = EmailUtility.format(
    		'{0}?response_type=code&client_id={1}&redirect_uri={2}',
    		new List<String>{
    			AUTH_ENDPOINT_MAP.get(state.replace('admin', '')),
    			EncodingUtil.urlEncode(clientId, 'UTF-8'),
    			EncodingUtil.urlEncode('https://services.simpplr.com/oauth/redirect/code_passthrough.php',  'UTF-8')    			
    		}
		);

		if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(state)) {
			url += '&force_reapprove=true&token_access_type=offline';
		} else if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(state) || ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(state)) {
			url += '&response_mode=query';
		}
		url += '&state=' + EncodingUtil.urlEncode(PageContext.getPageURL(Pages.StorageSettings).toLowerCase()+ '?state=' + state, 'UTF-8');
		
		return url;
	}
	
	// IConnectorType Implementation
	public String getAuthorizationEndpoint() {		
		return AUTH_ENDPOINT_MAP.get(fileStorage);
	}
	
	public String getTokenEndpoint() {
		return IntegrationConstants.TOKEN_ENDPOINT_MAP.get(fileStorage);
	}
	
	public String getClientId() {
		return dropboxFlag ? (this.adminFlag ? EFSConstants.DROPBOX_ADMIN_CLIENT_ID : EFSConstants.DROPBOX_USER_CLIENT_ID) : EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_ID;
	}
	
	public String getClientSecret() {
		return dropboxFlag ? (this.adminFlag ? EFSConstants.DROPBOX_ADMIN_CLIENT_SECRET : EFSConstants.DROPBOX_USER_CLIENT_SECRET) : EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_SECRET;
	}
	
	public String getRedirectUri() {
		return PageContext.getPageURL(Pages.StorageSettings).toLowerCase();	
	}
	
	public String getExtraUrlParameters() {
		if (appInteg == null) { 
			return dropboxFlag ? 'force_reapprove=true' : 'prompt=admin_consent';
		}
		
		if (!String.isEmpty(appInteg.Extra_URL_Parameters__c)) {
			return appInteg.Extra_URL_Parameters__c;
		}
		
		return '';
	}
}