/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/
 
/**
 * IntegrationService
 */
public with sharing class IntegrationService implements SCoreIConnectorType {
	//Statics
	public static final Integer EXPIRY_HEADROOM_TIME_SECONDS = 600; //10 minutes
	
	//Instance variables
	private Boolean dbSavedFlag { get; set; }	// Flag to track whether the refreshed Token is Saved to the DB or not
	public String intType { get; set; }
	public String peopleId { get; set; }
	public People_Integration__c integrator {get;set;}
	public App_Integration__c appIntegrator {get;set;}
    private String tokenType {get;set;}
    private String accessToken {get;set;}
    private String refreshToken {get;set;}
    private DateTime accessTokenExpiresIn {get;set;}
    private Map<String, App_Integration__c>mapIntTypeApp {get;set;}
	private List<Schema.SObjectField> fieldListForUpsert;
	private static final Map<String, String> AUTH_ENDPOINT_MAP = new Map<String, String> {
		'box' => '',
		'gdrive' => 'https://accounts.google.com/o/oauth2/auth',
		'googledrive' => 'https://accounts.google.com/o/oauth2/auth',
		'googlecalendar' => 'https://accounts.google.com/o/oauth2/auth',
		'googleusersync' => 'https://accounts.google.com/o/oauth2/auth',
		'dropbox' => 'https://www.dropbox.com/oauth2/authorize',
		'sharepoint' => 'https://login.microsoftonline.com/common/oauth2/authorize',
		'onedrive' => 'https://login.microsoftonline.com/common/oauth2/authorize',
		'adsi' => 'https://login.microsoftonline.com/common/oauth2/authorize',
		'activedirectory' => 'https://login.microsoftonline.com/common/oauth2/authorize',
		'facebook' => 'https://www.facebook.com/v2.10/dialog/oauth',
		'linkedin' => 'https://www.linkedin.com/oauth/v2/authorization',
		//'linkedin' => 'https://www.linkedin.com/oauth/rest/authorization',   //CONT-11331

		'servicenow' => SimpplrContext.serviceNowInstanceUrl + '/oauth_auth.do',
		'salesforce' => 'https://' + (SimpplrContext.isSandbox == true ? 'test' : 'login') + '.salesforce.com/services/oauth2/authorize',
		'atlassian' => 'https://auth.atlassian.com/authorize',
		'microsoftteams' => 'https://login.microsoftonline.com/common/oauth2/authorize'
	};
    
    private boolean adminFlag { get; set; }
    
	public String getTokenType () { 
		return tokenType;
	}
	
	public DateTime getAccessTokenExpiresIn () { 
		return accessTokenExpiresIn; 
	}
	
	// Instance Methods
	public Boolean isSaved() { 
		return this.dbSavedFlag; 
	}
	
	public IntegrationService (String integrationType, String inputId) {
		this.intType = integrationType;
		this.dbSavedFlag = true;
		this.peopleId = inputId;
		fieldListForUpsert = new List<Schema.SObjectField>();
		
		if(inputId != null) {
			// Get the Integrator record or create an Instance
			integrator = retrieveIntegrator();
		} else {
			retrieveAllAppIntegration();
			appIntegrator = mapIntTypeApp.get(intType);
			integrator = null;
		}
	}
	
	public IntegrationService (String inputId) {
		this.peopleId = inputId;
		retrieveAllAppIntegration();
		fieldListForUpsert = new List<Schema.SObjectField>();
	}
	
	public void retrieveAllAppIntegration(){
		mapIntTypeApp = new Map<String, App_Integration__c>();
	
		String appIntQuery;
		Map<String, Object> sqlParamMap = new Map<String, Object>();

		if(peopleId != null) {		
			appIntQuery = 'SELECT Id, Scope__c,'
						+ ' Scope_Required__c, Name, User_Email__c,'
				   		+ ' Extra_Url_Parameters__c, Client_Secret__c, Client_Id__c,'
				   		+ ' App_Access_Token__c, App_Refresh_Token__c,'
				   		+ ' Access_Token_Requested_Datetime__c, Refresh_Token_Requested_Datetime__c,'
				   		+ ' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,'
						+ ' Access_Token_Expiry__c, External_Id__c, User_Name__c,'
				   		+ ' (Select Token_Type__c,'
						+ ' Refresh_Token__c, Refresh_Token_Requested_Datetime__c, Name, Id,'
						+ ' Access_Token__c, Access_Token_Requested_Datetime__c, Access_Token_Expiry__c,'
						+ ' External_Id__c, People__c, User__c,  User_Email__c, User_Name__c,'
						+ ' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,'
					   	+ ' App_Integration__r.Scope_Required__c,'
					   	+ ' App_Integration__r.Name, App_Integration__r.Id, App_Integration__r.Scope__c,'
					   	+ ' App_Integration__r.Extra_Url_Parameters__c, App_Integration__r.Client_Secret__c,'
					   	+ ' App_Integration__r.Client_Id__c from People_Integrations__r' 
						+ ' WHERE People__c =: soqlParam1 AND Is_Deleted__c = false)'
				   		+ ' FROM App_Integration__c'
				   		+ ' WHERE Is_Deleted__c = false';
						
			sqlParamMap.put('soqlParam1', peopleId);
		} else {
			appIntQuery = 'SELECT Id, Scope__c,'
						+ ' Scope_Required__c, Name, User_Email__c,'
				   		+ ' Extra_Url_Parameters__c, Client_Secret__c, Client_Id__c,'
				   		+ ' App_Access_Token__c, App_Refresh_Token__c,'
				   		+ ' Access_Token_Requested_Datetime__c, Refresh_Token_Requested_Datetime__c,'
				   		+ ' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,'
						+ ' Access_Token_Expiry__c,  External_Id__c, User_Name__c'
				   		+ ' FROM App_Integration__c'
				   		+ ' WHERE Is_Deleted__c = false';
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> listOfAppIntegration = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
		
		for(App_Integration__c appInt : listOfAppIntegration)	{
			mapIntTypeApp.put(appInt.Name, appInt);
		}
	}
	
	public void setIntegrationVariables(String integrationType){
		this.intType = integrationType;
		appIntegrator = mapIntTypeApp.get(intType);
    	integrator = mapIntTypeApp.get(intType).People_Integrations__r.isEmpty() ? covertToDefaultPeopleIntegration(appIntegrator) : mapIntTypeApp.get(intType).People_Integrations__r[0];
	}
	
	// Function to do the clean ups and final steps
	public void close() {
    	// Function that saves the token to DB
		if (!this.dbSavedFlag) {
			saveToken();
		}
		
	}
	
	// Function to save the token to the DB
	public boolean saveToken() {
		try {
			if(integrator != null) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().upsertAsUser(new List<People_Integration__c>{integrator},fieldListForUpsert);
			} else if(appIntegrator != null) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().upsertAsUser(new List<App_Integration__c>{appIntegrator},fieldListForUpsert); 
			}

			this.dbSavedFlag = true;			
		} catch (Exception e) {
			this.dbSavedFlag = false;
		}
		
		return this.dbSavedFlag;
	}
	
	// Function/Page to get the Authorization from the User
	public String getAuthPage() {		
		SCoreOAuthClient client = new SCoreOAuthClient();
		String url = '';
		if(this.adminFlag == null) {
			this.adminFlag = false;
		}
		
		if(this.adminFlag) {
			url = client.generateAuthorizationUrl((SCoreIConnectorType)this, this.intType+'admin');
		} else {
			url = client.generateAuthorizationUrl((SCoreIConnectorType)this, this.intType);
		}
		
		if(this.intType.equalsIgnoreCase('adsi')) {
			// url += '&response_mode=query&resource=' + this.getClientId() + '&prompt=admin_consent';
			// Microsoft API dont require resource but Azure does
			url += '&response_mode=query&prompt=admin_consent';
		}
		
	   	return url;
	}
	
	public String getAuthPage(boolean adminFlg) {
		this.adminFlag = adminFlg;
		return getAuthPage();
	}
	
	// Update the User Related Fields from the Integration
 	public void updateUserInfo(String extId, String usrEmail, String usrName, String userPrincipalName) {
 		if(integrator != null) {
 			integrator.External_Id__c = extId;
 			integrator.User_Email__c = usrEmail;
 			integrator.User_Name__c = usrName;
			integrator.Connected__c = true; 
			fieldListForUpsert.add(People_Integration__c.External_Id__c);
			fieldListForUpsert.add(People_Integration__c.User_Email__c);
			fieldListForUpsert.add(People_Integration__c.User_Name__c);
			fieldListForUpsert.add(People_Integration__c.Connected__c);
			this.dbSavedFlag = false;
 		} else if(appIntegrator != null) {
 			appIntegrator.External_Id__c = extId;
 			appIntegrator.User_Email__c = usrEmail;
 			appIntegrator.User_Name__c = usrName;
			appIntegrator.Integration_Enabled__c = true;
			appIntegrator.Connected__c = true;	
			appIntegrator.User_Principal_Name__c = userPrincipalName;
			fieldListForUpsert.add(App_Integration__c.External_Id__c);
			fieldListForUpsert.add(App_Integration__c.User_Email__c);
			fieldListForUpsert.add(App_Integration__c.User_Name__c);
			fieldListForUpsert.add(App_Integration__c.Integration_Enabled__c);
			fieldListForUpsert.add(App_Integration__c.Connected__c);
			fieldListForUpsert.add(App_Integration__c.User_Principal_Name__c);
 			this.dbSavedFlag = false;			
 		} else {
 			this.dbSavedFlag = true;
 		}
 		
 	}
	
	/**
	 * Retrieve the Integrator for the given IntegratorId
	 *
	 * Note: for separation of concerns consider using a selector pattern.
	 * See https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer
	 */
	public People_Integration__c retrieveIntegrator() {
		if (String.isBlank(intType)) {
			return null;
		}

		if(String.isBlank(peopleId)) {
			peopleId = UserContext.peopleId;
		}
		
		if (integrator == null) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', peopleId);
			soqlParamMap.put('soqlParam2', intType);
			String queryStr = 'SELECT Token_Type__c, '+
					' Refresh_Token__c, Refresh_Token_Requested_Datetime__c, Name, Id, '+
					' Access_Token__c, Access_Token_Requested_Datetime__c, Access_Token_Expiry__c, '+
					' External_Id__c, People__c, User__c,  User_Email__c, User_Name__c, '+
					' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,'+
				   	' App_Integration__r.Scope_Required__c, '+
				   	' App_Integration__r.Name, App_Integration__r.Id, App_Integration__r.Scope__c,  '+
				   	' App_Integration__r.Extra_Url_Parameters__c, App_Integration__r.Client_Secret__c,'+ 
				   	' App_Integration__r.Client_Id__c '+
					' FROM People_Integration__c '+
					' WHERE People__c =: soqlParam1  '+
					' AND Is_Deleted__c = false  '+
					' AND Name = :soqlParam2 '+
					' LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<People_Integration__c> listOfPeopleIntegrator = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);				
			if (!listOfPeopleIntegrator.isEmpty()) {
				integrator = listOfPeopleIntegrator[0];
			
			} else {
				// When no integrator records exist
				appIntegrator = new App_Integration__c();
				String appIntQuery = 'SELECT Id, Scope__c,'
						+ ' Scope_Required__c, Name, User_Email__c,'
				   		+ ' Extra_Url_Parameters__c, Client_Secret__c, Client_Id__c'
				   		+ ' FROM App_Integration__c'
				   		+ ' WHERE Name = :soqlParam1'
				   		+ ' AND Is_Deleted__c = false'
				   		+ ' LIMIT 1';
				Map<String, Object> sqlParamMap = new Map<String, Object>();
				sqlParamMap.put('soqlParam1', intType);
		
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<App_integration__c> listOfAppIntegration = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
						   
				if (!listOfAppIntegration.isEmpty()) {
					 appIntegrator = listOfAppIntegration[0];
				}
				
				integrator = covertToDefaultPeopleIntegration(appIntegrator);
			}
		}
		return integrator;
	}
	
	private People_Integration__c covertToDefaultPeopleIntegration(App_Integration__c appIntegrator) {
		People_Integration__c integrator = new People_Integration__c();
		if(appIntegrator != NULL && String.isNotBlank(appIntegrator.Client_Id__c)) {
			integrator.People__c = peopleId;	
			integrator.User__c = UserContext.Id;
			integrator.User_Email__c = appIntegrator.User_Email__c;	
			integrator.Name = intType;
			integrator.App_Integration__c = appIntegrator.Id;
			integrator.Access_Token__c = null;
			integrator.Access_Token_Requested_Datetime__c = null;
			integrator.Access_Token_Expiration_Datetime__c = null;
			integrator.Refresh_Token__c = null;
			integrator.Refresh_Token_Requested_Datetime__c = null;
			integrator.Refresh_Token_Expiration_Datetime__c = null;
			integrator.Is_Deleted__c = false;			

			fieldListForUpsert.add(People_Integration__c.People__c);
			fieldListForUpsert.add(People_Integration__c.User__c);
			fieldListForUpsert.add(People_Integration__c.User_Email__c);
			fieldListForUpsert.add(People_Integration__c.Name);
			fieldListForUpsert.add(People_Integration__c.App_Integration__c);
			fieldListForUpsert.add(People_Integration__c.Access_Token__c);
			fieldListForUpsert.add(People_Integration__c.Access_Token_Requested_Datetime__c);
			fieldListForUpsert.add(People_Integration__c.Access_Token_Expiration_Datetime__c);
			fieldListForUpsert.add(People_Integration__c.Refresh_Token__c);
			fieldListForUpsert.add(People_Integration__c.Refresh_Token_Requested_Datetime__c);
			fieldListForUpsert.add(People_Integration__c.Refresh_Token_Expiration_Datetime__c);
			fieldListForUpsert.add(People_Integration__c.Is_Deleted__c);
		}
		
		return integrator;
	}
	
	// Create App Integration Record for the selected integration type
	public static boolean createAppIntegration (String intType, String clientId, 
			String clientSecret, String domain) {
		Boolean statusFlag = false;

		List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

		fieldList.add(App_Integration__c.Name);
		fieldList.add(App_Integration__c.Scope__c);
		fieldList.add(App_Integration__c.Scope_Required__c);
		fieldList.add(App_Integration__c.Extra_Url_Parameters__c);
		fieldList.add(App_Integration__c.Client_Secret__c);
		fieldList.add(App_Integration__c.Client_Id__c);
		fieldList.add(App_Integration__c.Org_Id__c);
		
		if (IntegrationConstants.INTEGRATION_TYPE_ADSI.equalsIgnoreCase(intType) || IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY.equalsIgnoreCase(intType)) {
			App_Integration__c adsiAppInteg = new App_Integration__c();
			adsiAppInteg.Name = intType;
			adsiAppInteg.Scope__c = '';
			adsiAppInteg.Scope_Required__c = false;
			adsiAppInteg.Extra_Url_Parameters__c = '';
			adsiAppInteg.Client_Secret__c = clientSecret;
			adsiAppInteg.Client_Id__c = clientId;
			adsiAppInteg.Org_Id__c = UserInfo.getOrganizationId();
			
			try {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(adsiAppInteg, fieldList);
				
				statusFlag = true;
			} catch(Exception e) {
				throw new SimpplrException(e);
			}
		} else if (IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS.equalsIgnoreCase(intType)) {
			App_Integration__c microsoftTeamsAppInteg = new App_Integration__c();
			microsoftTeamsAppInteg.Name = intType;
			microsoftTeamsAppInteg.Scope__c = '';
			microsoftTeamsAppInteg.Scope_Required__c = false;
			microsoftTeamsAppInteg.Extra_Url_Parameters__c = '';
			microsoftTeamsAppInteg.Client_Secret__c = clientSecret;
			microsoftTeamsAppInteg.Client_Id__c = clientId;
			microsoftTeamsAppInteg.Org_Id__c = UserInfo.getOrganizationId();

			try {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().insertAsUser(microsoftTeamsAppInteg, fieldList);

				statusFlag = true;
			} catch(Exception e) {
				throw new SimpplrException(e);
			}
		}
		
		return statusFlag;
	}
	
	// Update Active directory credentials
	public static boolean updateADIntegRecords(String integrationType, String clientId, String clientSecret) {
		Boolean statusFlag = false;
		String appIntQuery = 'SELECT Id, Client_Id__c, Client_Secret__c, Integration_Enabled__c FROM App_Integration__c WHERE Name = :soqlParam1 LIMIT 1';

		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', integrationType);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
		
    	if(!appIntList.isEmpty() && String.isNotBlank(clientSecret) && String.isNotBlank(clientId)){
    		appIntList[0].Client_Secret__c = clientSecret;
			appIntList[0].Client_Id__c = clientId;
			appIntList[0].Integration_Enabled__c = true;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_integration__c>(appIntList), new List<Schema.SObjectField>{
				App_integration__c.Client_Secret__c,
				App_integration__c.Client_Id__c,
				App_integration__c.Integration_Enabled__c
			});

			statusFlag = true;
    	}
		
		return statusFlag;
	}
	
	/**
     * Determines whether the Integrator is valid.
     * Returns the appropriate error message. 
     */
    public String validateIntegrator () {    	
    	if (this.integrator == null) {
        	return 'No Integration Type found.';
        } else if (this.integrator.Access_Token__c == null) {
        	return 'The Integration Type ' + Integrator.Name + ' has not been authorized.';
        } else if (accessTokenExpired()) {
	        	if (integrator.Refresh_Token__c == null) {
	        		return 'The Integration Type ' + integrator.Name + ' needs to be reauthorized.';
	        	} else {
		        	//In this case the access_token has expired and needs reauthorising.
		        	//Given that we have the refresh token we can use an OAuthClient call to do this.
		        	exchangeCode(integrator.Refresh_Token__c, false);
	        	}
        }
        
        return null;
    }
    
	/**
     * Determines whether the Integrator is valid.
     * Returns the appropriate error message. 
     */
    public String validateAppIntegrator () {    	
    	if (this.appIntegrator == null) {
        	return 'No Integration Type found.';
        } else if (this.appIntegrator.App_Access_Token__c == null) {
        	return 'The Integration Type ' + Integrator.Name + ' has not been authorized.';
        } else if (appAccessTokenExpired()) {
        	if (appIntegrator.App_Refresh_Token__c == null) {
        		return 'The Integration Type ' + appIntegrator.Name + ' needs to be reauthorized.';
        	} else {
	        	//In this case the access_token has expired and needs reauthorising.
	        	//Given that we have the refresh token we can use an OAuthClient call to do this.
	        	exchangeCode(appIntegrator.App_Refresh_Token__c, false);
        	}
        }
        
        return null;
    }
    
    /**
     * Check whether the access token has expired.
     * If a token is within 10 minutes of expiring then deal with it as if it has expired.
     */
    public Boolean accessTokenExpired() {
    	//If we don't know when the token was requested, or when it will expire, then treat it like it hasn't expired.
    	if (integrator == null || 
    		integrator.Access_Token_Requested_Datetime__c == null || 
    		integrator.Access_Token_Expiry__c == null || 
    		integrator.Access_Token_Expiration_Datetime__c == null ||
    		String.isBlank(integrator.Access_Token__c)) {
    		return true;
    	}

    	return integrator.Access_Token_Expiration_Datetime__c < System.now();
    }

    /**
     * Check whether the access token has expired.
     * If a token is within 10 minutes of expiring then deal with it as if it has expired.
     */
    public Boolean appAccessTokenExpired() {
    	//If we don't know when the token was requested, or when it will expire, then treat it like it hasn't expired.
    	if (appIntegrator == null || 
    		appIntegrator.Access_Token_Requested_Datetime__c == null || 
    		appIntegrator.Access_Token_Expiry__c == null || 
    		appIntegrator.Access_Token_Expiration_Datetime__c == null) {
    		return true;
    	}

    	return appIntegrator.Access_Token_Expiration_Datetime__c < System.now();
    }

    
    public void exchangeCode(String code, boolean authCode) {
    	this.dbSavedFlag = false;
    	if(integrator != null) {
    		integrator.Access_Token_Requested_Datetime__c = System.now();
			integrator.Refresh_Token_Requested_Datetime__c = integrator.Access_Token_Requested_Datetime__c;	
			fieldListForUpsert.add(People_Integration__c.Access_Token_Requested_Datetime__c);
			fieldListForUpsert.add(People_Integration__c.Refresh_Token_Requested_Datetime__c);
    	} else {
    		appIntegrator.Access_Token_Requested_Datetime__c = System.now();
			appIntegrator.Refresh_Token_Requested_Datetime__c = appIntegrator.Access_Token_Requested_Datetime__c;  
			fieldListForUpsert.add(App_Integration__c.Access_Token_Requested_Datetime__c);
			fieldListForUpsert.add(App_Integration__c.Refresh_Token_Requested_Datetime__c);  		
    	}
		
		SCoreOAuthClient client = new SCoreOAuthClient();
		
		SCoreOAuthClient.AccessTokenResponse response;
		
		if (authCode) {
			SCoreOAuthClient.ExchangeAuthCodeRequest accessRequest = null;
			if(this.intType.equalsIgnoreCase('adsi')) {
				ADAuthCodeRequestBody content = new ADAuthCodeRequestBody(this, 'authorization_code', code, 'https://graph.microsoft.com', '');
				accessRequest = new SCoreOAuthClient.ExchangeAuthCodeRequest(client, this.getTokenEndpoint(), (SCoreIHttpContent)content);
			} else {
				accessRequest = client.exchangeAuthCodeRequest(this, code);
			}

			response = (SCoreOAuthClient.AccessTokenResponse)accessRequest.execute();
		} else {
			SCoreOAuthClient.ExchangeRefreshTokenRequest refreshRequest = null;
			if(this.intType.equalsIgnoreCase('adsi')) {
				ADAuthCodeRequestBody content = new ADAuthCodeRequestBody(this, 'refresh_token', '', 'https://graph.microsoft.com', code);
				refreshRequest = new SCoreOAuthClient.ExchangeRefreshTokenRequest(client, this.getTokenEndpoint(), (SCoreIHttpContent)content);
			} else { 
				refreshRequest = client.exchangeRefreshTokenRequest(this, code);
			}
			
			response = (SCoreOAuthClient.AccessTokenResponse)refreshRequest.execute();
		}
		if(integrator != null) {
	    	integrator.Access_Token__c = response.access_token;
		    integrator.Refresh_Token__c = response.refresh_token;
		    integrator.Token_Type__c = response.token_type;

			fieldListForUpsert.add(People_Integration__c.Access_Token__c);
			fieldListForUpsert.add(People_Integration__c.Refresh_Token__c);
			fieldListForUpsert.add(People_Integration__c.Token_Type__c);
		    
		    if(response.expires_in != null) {
		    	integrator.Access_Token_Expiry__c = response.expires_in;
				fieldListForUpsert.add(People_Integration__c.Access_Token_Expiry__c);
		    } else {
		    	integrator.Access_Token_Expiry__c = 946080000000.00; // 30 Years
				fieldListForUpsert.add(People_Integration__c.Access_Token_Expiry__c);
		    }
		    
    		Integer accessTokenExpiry = (Integer)integrator.Access_Token_Expiry__c;
    		integrator.Access_Token_Expiration_Datetime__c = System.now().addSeconds(accessTokenExpiry - EXPIRY_HEADROOM_TIME_SECONDS);
			fieldListForUpsert.add(People_Integration__c.Access_Token_Expiration_Datetime__c);
		} else {
			appIntegrator.App_Access_Token__c = response.access_token;
		    appIntegrator.App_Refresh_Token__c = response.refresh_token;
		    appIntegrator.Token_Type__c = response.token_type;

			fieldListForUpsert.add(App_Integration__c.App_Access_Token__c);
			fieldListForUpsert.add(App_Integration__c.App_Refresh_Token__c);
			fieldListForUpsert.add(App_Integration__c.Token_Type__c);

		    if(response.expires_in != null) {
		    	appIntegrator.Access_Token_Expiry__c = response.expires_in;
				fieldListForUpsert.add(App_Integration__c.Access_Token_Expiry__c);
		    } else {
		    	appIntegrator.Access_Token_Expiry__c = 946080000000.00; // 30 Years
				fieldListForUpsert.add(App_Integration__c.Access_Token_Expiry__c);
		    }
		    
	    	Integer appAccessTokenExpiry = (Integer)appIntegrator.Access_Token_Expiry__c;
	    	appIntegrator.Access_Token_Expiration_Datetime__c = System.now().addSeconds(appAccessTokenExpiry - EXPIRY_HEADROOM_TIME_SECONDS);
			fieldListForUpsert.add(App_Integration__c.Access_Token_Expiration_Datetime__c);
		}
    }
    
    /**
     * Returns the access token for this Integrator
     */
	public String getAccessToken () {	
		if (validateIntegrator() != null) {
			return null;
		}
		return integrator.Access_Token__c;
	}


    /**
     * Returns the access token for this Integrator
     */
	public String getAppAccessToken () {	
		if (validateAppIntegrator() != null) {
			return null;
		}
		return appIntegrator.App_Access_Token__c;
	}


	/**
	 * IIntegratorType implementation
	 */
	public String getAuthorizationEndpoint () {
		return AUTH_ENDPOINT_MAP.get(intType);
	}

	public String getTokenEndpoint() {
		return IntegrationConstants.TOKEN_ENDPOINT_MAP.get(intType);
	}
	public String getClientId() {
        if(integrator == null) { return IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appIntegrator.Name) ? Utility.decryptFn(appIntegrator.Client_Id__c) : appIntegrator.Client_Id__c; }
        return integrator.Id == null ? IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appIntegrator.Name) ? Utility.decryptFn(appIntegrator.Client_Id__c) : appIntegrator.Client_Id__c : IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(integrator.App_Integration__r.name) ? Utility.decryptFn(integrator.App_Integration__r.Client_Id__c) : integrator.App_Integration__r.Client_Id__c;
    }
	public String getClientSecret() {
		if(integrator == null) { return IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appIntegrator.Name) ? Utility.decryptFn(appIntegrator.Client_Secret__c) : appIntegrator.Client_Secret__c; }
        return integrator.Id == null ? IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appIntegrator.Name) ? Utility.decryptFn(appIntegrator.Client_Secret__c) : appIntegrator.Client_Secret__c : IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(integrator.App_Integration__r.name) ? Utility.decryptFn(integrator.App_Integration__r.Client_Secret__c) : integrator.App_Integration__r.Client_Secret__c;
	}
	public String getUserEmail() {
		if(integrator == null) { return appIntegrator.User_Email__c; }
		return String.isBlank(integrator.User_Email__c) ? appIntegrator.User_Email__c : integrator.User_Email__c;
	}
	public String getRedirectUri() {
		return PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase();
	}
	
	public String getExtraUrlParameters() {
		String eStr = '';
		if('servicenow'.equalsIgnoreCase(intType)) {
			//Do nothing
		} else {
			if (integrator == null || integrator.Id == null) { 
				if (appIntegrator.Scope_Required__c == true) {
					eStr = 'scope=' + appIntegrator.Scope__c;
					if (!String.isEmpty(appIntegrator.Extra_Url_Parameters__c)) {
						eStr += '&' + appIntegrator.Extra_Url_Parameters__c;
					}
				} else if (!String.isEmpty(appIntegrator.Extra_Url_Parameters__c)) {
					eStr = appIntegrator.Extra_Url_Parameters__c;
				}
			} else {
				if (integrator.App_Integration__r.Scope_Required__c == true) {
					eStr = 'scope=' + Integrator.App_Integration__r.Scope__c;
		
					if (!String.isEmpty(integrator.App_Integration__r.Extra_Url_Parameters__c)) {
						eStr += '&' + Integrator.App_Integration__r.Extra_Url_Parameters__c;
					}
				} else if (!String.isEmpty(integrator.App_Integration__r.Extra_Url_Parameters__c)) {
					eStr = integrator.App_Integration__r.Extra_Url_Parameters__c;
				}
			}
		}
		
		return eStr;
	}
	
	// Override for AD code exchange
	public class ADAuthCodeRequestBody implements SCoreIHttpContent {
		String grantType;
		String code;
		String clientId;
		String clientSecret;
		String redirectUri;
		String resource;
		String refreshToken;
		String scope;
		
		public ADAuthCodeRequestBody(SCoreIConnectorType ct, String grantType, String code, String res, String refreshToken) {
			this.clientId = ct.getClientId();
			this.clientSecret = ct.getClientSecret();
			this.refreshToken = refreshToken;
			this.grantType = grantType;
			this.code = code;
			this.resource = res;
			
			if(String.isNotBlank(refreshToken)){
				this.redirectUri = '';
				this.scope = '';
			} else {
				this.redirectUri = 'https://services.simpplr.com/oauth/redirect/code_passthrough.php';
				this.scope = 'https://graph.microsoft.com';
			}
		}
		
		/**
		 * IHttpContent implementation
		 */
		public String getHttpContentType() {
			return 'application/x-www-form-urlencoded';
		}
	
		public Object getHttpContent() {	
			String content = '';
			content = addParameterIfStringNotEmpty(content, 'code', code, false);
			content = addParameterIfStringNotEmpty(content, 'grant_type', grantType, false);
			content = addParameterIfStringNotEmpty(content, 'client_id', clientId, true);
			content = addParameterIfStringNotEmpty(content, 'client_secret', clientSecret, false);
			content = addParameterIfStringNotEmpty(content, 'redirect_uri', redirectUri, true);
			content = addParameterIfStringNotEmpty(content, 'scope', scope, true);
			content = addParameterIfStringNotEmpty(content, 'resource', resource, true);
			content = addParameterIfStringNotEmpty(content, 'refresh_token', refreshToken, true);
					
			return content;
		}
		
		private String addParameterIfStringNotEmpty(String content, String parameter, String value, Boolean encode) {
			if (String.isEmpty(value))
			{
				return content;
			}
			
			if (!String.isEmpty(content))
			{
				content += SCoreClient.HTTP_REQUEST_ENDPOINT_SEPARATOR;
			}
			
			if (encode)
			{
				value = EncodingUtil.urlEncode(value, SCoreClient.CHARSET_UTF8);
			}
			
			return content += parameter + SCoreClient.HTTP_REQUEST_PARAMETER_SEPARATOR + value;
		}
	}
}