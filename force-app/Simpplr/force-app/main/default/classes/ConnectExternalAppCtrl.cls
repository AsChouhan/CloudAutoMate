public with sharing class ConnectExternalAppCtrl {

	public final String STR_DOMAIN_OR_ACCOUNT_MISMATCH = 'domain_or_account_mismatch';// NOPMD - correct naming convension, suppressed codacy error
	public final String STR_NOT_A_GSUITE_ACC = 'not_a_gsuite_account';// NOPMD - correct naming convension, suppressed codacy error
	public final String STR_SETUP_DOMAIN_MISMATCH ='setup_domain_mismatch';// NOPMD - correct naming convension, suppressed codacy error
	public final String STR_DOMAIN_MISMATCH_ERR_CODE ='domain_mismatch';// NOPMD - correct naming convension, suppressed codacy error
	Map<String,String> labelMap = LocaleContext.getLabelMap(PageContext.currentPageName, UserContext.languageLocaleKey);
	public transient final String STR_SLACK_INSTALL_SUCCESS_FLASH { get { return labelMap.get('slack.install.success_flash');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_SLACK_INSTALL_ERROR_FLASH { get { return labelMap.get('slack.install.error_flash');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_SLACK_UNINSTALL_SUCCESS_FLASH { get { return labelMap.get('slack.uninstall.success_flash');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_SLACK_UNINSTALL_ERROR_FLASH { get { return labelMap.get('slack.uninstall.error_flash');}} // NOPMD - correct naming convension, suppressed codacy error

	public transient final String STR_CONNECTION_SUCCESS { get { return labelMap.get('apps.connection.success');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_CONNECTION_ERROR_FLASH { get { return labelMap.get('apps.connection.error_flash');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_GOOGLE_CALENDAR { get { return labelMap.get('app.google_calendar');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_OUTLOOK_CALENDAR { get { return labelMap.get('app.outlook_calendar');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_GOOGLE_USER_SYNC { get { return labelMap.get('app.google');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_BROWSER_NOTIFICATIONS_SUCCESS_FLASH { get { return labelMap.get('browser_notifications.success_flash');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_BROWSER_NOTIFICATIONS_ERROR_FLASH { get { return labelMap.get('browser_notifications.error_flash');}} // NOPMD - correct naming convension, suppressed codacy error
	
	public transient final String STR_ATLASSIAN { get { return labelMap.get('app.atlassian');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_ACTIVE_DIRECTORY { get { return labelMap.get('app.activedirectory');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_LINKEDIN { get { return labelMap.get('app.linkedin');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_TWITTER { get { return labelMap.get('app.twitter');}} // NOPMD - correct naming convension, suppressed codacy error	
	public transient final String STR_MICROSOFT_TEAMS { get { return labelMap.get('app.microsoftteams');}} // NOPMD - correct naming convension, suppressed codacy error
	public transient final String STR_AD_DOMAIN_MISMATCH { get { return labelMap.get('apps.connection.activedirectory.domain_mismatch');}}
	public transient final String STR_SLACK { get { return labelMap.get('app.slack');}} // NOPMD - correct naming convension, suppressed codacy error
    
	/*
	public transient final String STR_KEY_1 { get { return labelMap.get('apps.connection.google.domain_or_account_mismatch');}}
	public transient final String STR_KEY_2 { get { return labelMap.get('apps.connection.google.user_account_mismatch');}}
	public transient final String STR_KEY_3 { get { return labelMap.get('apps.connection.google.not_a_gsuite_account');}}
	public transient final String STR_KEY_4 { get { return labelMap.get('apps.connection.google.invalid_integration_type');}}
	public transient final String STR_KEY_5 { get { return labelMap.get('apps.connection.google.setup_domain_mismatch');}}
	public transient final String STR_KEY_6 { get { return labelMap.get('apps.connection.google.OAuthError');}}	
	
	public transient final String STR_KEY_4 { get { return labelMap.get('apps.connection.atlassian.invalid_integration_type');}}
	public transient final String STR_KEY_5 { get { return labelMap.get('apps.connection.atlassian.setup_domain_mismatch');}}
	public transient final String STR_KEY_6 { get { return labelMap.get('apps.connection.atlassian.OAuthError');}}	
	*/

    public PageReference saveAppDetails() {
		
		PageReference returnPage;
		String stateArg = readSafeParam('state');
		String codeArg = '';
		String errorArg = '';
		String tokenArg = '';
		String errorCodeArg = '';

		// Read the Code
		if('twitter'.equalsIgnoreCase(stateArg)){
			codeArg = readParam('oauth_verifier');	
			tokenArg = readParam('oauth_token');
			errorArg = readSafeParam('denied');
			if(String.isNotBlank(errorArg)){
				errorArg = 'denied';	
			}
		} else {
			errorArg = readSafeParam('error');
			errorCodeArg = readSafeParam('error_code');
			codeArg = readParam('code');
		}

		//Protect from forgery 
		AccessManager.protectFromRequestForgery();

		if('bn'.equalsIgnoreCase(stateArg)) {
			//{BrowserbasedURL}?redirect_uri={baseurl}/apex/connectexternalapp?state=bn&retURL={currentURl encoded}&code={codeHere}&error=denied&userAgent=chrome
			String retURL = readParam('retURL');
			String returnURL = null;
			if(String.isNotBlank(retURL)) {
				returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
			}

			String userAgent = readParam('userAgent');

			returnPage = new PageReference(returnURL);
			returnPage.setRedirect(true);
			if(String.isNotBlank(codeArg)) {
				// user has allowed web push notifications - save and send info to Lambda
				saveUserWebPushConfig(codeArg, userAgent);
				//returnPage.getParameters().put('alert',prepareMessage('success', STR_BROWSER_NOTIFICATIONS_SUCCESS_FLASH));
			} else {
				//returnPage.getParameters().put('alert',prepareMessage('danger', STR_BROWSER_NOTIFICATIONS_ERROR_FLASH));
			}
			
		} else if('googlecalendar'.equalsIgnoreCase(stateArg)){
			try {
				String retURL = readParam('retURL');
				String returnURL = null;
				if(String.isNotBlank(retURL)) {
					returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
				}
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
														new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
				returnPage.setRedirect(true);
				if(String.isNotBlank(errorCodeArg)) {
					String errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'apps.connection.google.' + errorCodeArg);
					if(errorCodeArg.equalsIgnoreCase(STR_DOMAIN_OR_ACCOUNT_MISMATCH) || errorCodeArg.equalsIgnoreCase(STR_NOT_A_GSUITE_ACC) || errorCodeArg.equalsIgnoreCase(STR_SETUP_DOMAIN_MISMATCH)){
						if(GoogleDriveService.googleMultiDomainUpgraded()){
							errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'apps.connection.google.' + STR_SETUP_DOMAIN_MISMATCH);
						} else{
							errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'apps.connection.google.' + STR_DOMAIN_MISMATCH_ERR_CODE);
							String domainName = getDomainName();
							errorMessage = domainName!=null && domainName!='' ? errorMessage.replace('{{domainName}}','@'+domainName) : errorMessage.replace('{{domainName}}','existing');
						}
					}
					returnPage.getParameters().put('alert', prepareMessage('danger', errorMessage));

				} else if(String.isNotBlank(errorArg)) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_GOOGLE_CALENDAR)));

				} else if(SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR) == null) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_GOOGLE_CALENDAR)));

				}else{
					String gUserId =  readParam('gUserId');
					String gUserName =  readParam('gUserName');
					String gUserEmail = readParam('gUserEmail');
					String domain = readParam('gUserDomain');
					// Create People Integration record 
					GoogleCalendarHelper googleCalendarHelperObj = new GoogleCalendarHelper();
					googleCalendarHelperObj.createPeopleIntegrationRecord(gUserId, gUserName, gUserEmail, domain);
					returnPage.getParameters().put('alert',prepareMessage('success', STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_GOOGLE_CALENDAR)));
					
				}				

            } catch(Exception ex) {
    			returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
    			returnPage.setRedirect(true);
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
			}
		} else if(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(stateArg)) {
			try {

				String retURL = readParam('retURL');
				String returnURL = null;
				if(String.isNotBlank(retURL)) {
					returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
				}
				
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
														new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
				returnPage.setRedirect(true);				

				String alert = readParam('alert');
				Map<String, Object> alertParamMap = (Map<String, Object>) JSON.deserializeUntyped(alert);

				String type = (String) alertParamMap.get('type');

				if(type.equalsIgnoreCase('danger')) {

					String translationCode = (String) alertParamMap.get('translationCode');
					// check if we got domain mismatch translation code
					if(translationCode.equalsIgnoreCase('apps.connection.outlook.setup_domain_mismatch')) {
						String errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, translationCode);
						returnPage.getParameters().put('alert', prepareMessage('danger', errorMessage));
					} else {
						returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_OUTLOOK_CALENDAR)));						
					}

				} else {
					// Hit Outlook MS to validate user connection and fetch user details
					OutlookCalendarHelper helperObj = new OutlookCalendarHelper();
					Map<String, String> userProfileMap = helperObj.verifyAndGetUserDetails();
					String email = userProfileMap.get('email');
					String userName = userProfileMap.get('userName');
					String externalId = userProfileMap.get('externalId');
					String domain = email.split('@').get(1);
					helperObj.createPeopleIntegrationRecord(email, userName, externalId, domain);
					returnPage.getParameters().put('alert',prepareMessage('success', STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_OUTLOOK_CALENDAR)));	
				}			

			} catch (Exception ex) {
    			returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
    			returnPage.setRedirect(true);
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));				
			}
		} else if('googleusersyncadmin'.equalsIgnoreCase(stateArg)){
			try {
				String retURL = readParam('retURL');
				String returnURL = null;
				if(String.isNotBlank(retURL)) {
					returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
				}
				
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
														new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/people');
				returnPage.setRedirect(true);
				if(String.isNotBlank(errorCodeArg)) {
					String errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'apps.connection.google.' + errorCodeArg);
					returnPage.getParameters().put('alert', prepareMessage('danger', errorMessage));

				} else if(String.isNotBlank(errorArg)) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_GOOGLE_USER_SYNC)));

				} else {
					String gUserId =  readParam('gUserId');
					String gUserName =  readParam('gUserName');
					String gUserEmail = readParam('gUserEmail');
					String gUserDomain = readParam('gUserDomain');	
					// Create App Integration record 
					
					App_Integration__c appntegrationObj = new  App_Integration__c();
					appntegrationObj.Name = IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC;
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

					if(SimpplrContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC)) {
						appntegrationObj.id = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC).Id;
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPESAPI.accessController().updateAsUser(appntegrationObj, fieldList);  
					} else {
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPESAPI.accessController().insertAsUser(appntegrationObj, fieldList);                       
					}

					returnPage.getParameters().put('alert',prepareMessage('success', STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_GOOGLE_USER_SYNC)));
					
				}				

            } catch(Exception ex) {
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
			}
		} else if('ServiceAccount'.equalsIgnoreCase(stateArg)) {
			try {
				returnPage = new Pagereference(PageContext.getPageURL(Pages.PostInstallSetup));
				returnPage.setRedirect(true);
				if(String.isNotBlank(errorArg)) {
					returnPage.getParameters().put('alert', prepareMessage('danger', errorArg));

				}else{
					processResponseForServiceAccount();
				}
			} catch(Exception ex) {
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    		}

		} else if('googlecalendaradmin'.equalsIgnoreCase(stateArg)){
			try {
				returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/calendar');
				returnPage.setRedirect(true);
				if(String.isNotBlank(errorCodeArg)) {
					String errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'apps.connection.google.' + errorCodeArg);
					returnPage.getParameters().put('alert', prepareMessage('danger', errorMessage));

				} else if(String.isNotBlank(errorArg)) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_GOOGLE_CALENDAR)));

				}else{
					String gUserId =  readParam('gUserId');
					String gUserName =  readParam('gUserName');
					String gUserEmail = readParam('gUserEmail');
					String gUserDomain = readParam('gUserDomain');	
					// Create App Integration record 
					GoogleCalendarHelper googleCalendarHelperObj = new GoogleCalendarHelper();
					googleCalendarHelperObj.createAppIntegrationRecord(gUserId, gUserName, gUserEmail, gUserDomain);
					returnPage.getParameters().put('alert',prepareMessage('success', STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_GOOGLE_CALENDAR)));
					
				}				

            } catch(Exception ex) {
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    		}
		} else if ('atlassianadmin'.equalsIgnoreCase(stateArg) || 'atlassianuser'.equalsIgnoreCase(stateArg)) {

			String retURL = readParam('retURL');
			String returnURL = null;
			if(String.isNotBlank(retURL)) {
				returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
			}
			
			if ('atlassianadmin'.equalsIgnoreCase(stateArg)) {
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
								new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/support');
			} else {
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
								new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
			}
			returnPage.setRedirect(true);
			try {
				if(String.isNotBlank(errorCodeArg)) {
					String errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'apps.connection.atlassian.' + errorCodeArg);
					returnPage.getParameters().put('alert', prepareMessage('danger', errorMessage));
	
				} else if(String.isNotBlank(errorArg)) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_ATLASSIAN)));
	
				} else {
					Map<String,String> params = System.currentPageReference().getParameters();
					String isAtlassianeConnected = params.get('isConnected');
					String aUserId =  params.get('aUserId');
					String aUserName =  params.get('aUserName');
					String aUserEmail = params.get('aUserEmail');
					String isSuccess = params.get('isSuccess');
					if (Boolean.valueOf(isAtlassianeConnected)) {	
						AtlassianHelper atlassianHelperObj = new AtlassianHelper();
						if('atlassianadmin'.equalsIgnoreCase(stateArg)) {
							// Create app config record 
							atlassianHelperObj.upsertAppIntegrationRecord(aUserId, aUserName,aUserEmail);
						}
						else {
							// Create People Integration record 
							atlassianHelperObj.createPeopleIntegrationRecord(aUserId, aUserName,aUserEmail);
						}

						String msgStr = prepareMessage('success',  STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_ATLASSIAN));
						returnPage.getParameters().put('alert', msgStr);
					} else {
						returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_ATLASSIAN)));
					}
				}
			} catch(Exception ex) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
			}

		} else if ('activedirectoryadmin'.equalsIgnoreCase(stateArg)) {

			String retURL = readParam('retURL');
			String returnURL = null;
			if(String.isNotBlank(retURL)) {
				returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
			}
			
			if ('activedirectoryadmin'.equalsIgnoreCase(stateArg)) {
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
								new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/people');
			} else {
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
								new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
			}
			returnPage.setRedirect(true);
			try {
				if(String.isNotBlank(errorCodeArg) && errorCodeArg.equalsIgnoreCase(STR_DOMAIN_OR_ACCOUNT_MISMATCH)) {
					String errorMessage = STR_AD_DOMAIN_MISMATCH;
					String domainName = getActiveDirectoryDomainName();
					errorMessage = domainName != null && domainName != '' ? errorMessage.replace('{{domainName}}', '@' + domainName) : errorMessage.replace('{{domainName}}', 'existing');
					returnPage.getParameters().put('alert', prepareMessage('danger', errorMessage));

				} else if(String.isNotBlank(errorArg)) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_ACTIVE_DIRECTORY)));
	
				} else {
					Map<String,String> params = System.currentPageReference().getParameters();
					String externalId =  params.get('externalId');
					String email =  params.get('email');
					String displayName =  params.get('displayName');
					String isSuccess = params.get('isSuccess');
					String userPrincipalName = params.get('userPrincipalName');
					if (Boolean.valueOf(isSuccess)) {
						if('activedirectoryadmin'.equalsIgnoreCase(stateArg)) {
							// Create app integration record
							IntegrationService adIntegration = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY, null);
							adIntegration.updateUserInfo(externalId, email, displayName, userPrincipalName);
							adIntegration.close();
						}

						String msgStr = prepareMessage('success',  STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_ACTIVE_DIRECTORY));
						returnPage.getParameters().put('alert', msgStr);
					} else {
						returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_ACTIVE_DIRECTORY)));
					}
				}
			} catch(Exception ex) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
			}

		} else if ('microsoftTeamsAdmin'.equalsIgnoreCase(stateArg)) {
			String retURL = readParam('retURL');
			String returnURL = null;
			if(String.isNotBlank(retURL)) {
				returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
			}
			
			returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
							new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/messaging');

			returnPage.setRedirect(true);
			try{
				String alert = readParam('alert');
				Map<String, Object> alertParamMap = (Map<String, Object>) JSON.deserializeUntyped(alert);
				String type = (String) alertParamMap.get('type');
				if(type.equalsIgnoreCase('danger')) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_MICROSOFT_TEAMS)));
				} else {
					MicrosoftTeamsHelper msTeamsHelperObj = new MicrosoftTeamsHelper();
					Map<String, String> tenantDetailMap = msTeamsHelperObj.getMSTeamsTenantInfo();
					String tenantId = tenantDetailMap.get('tenantId');
					msTeamsHelperObj.createAppIntegrationRecord(tenantId);
					String msgStr = prepareMessage('success',  STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_MICROSOFT_TEAMS));
					returnPage.getParameters().put('alert', msgStr);
				}
			} catch(Exception ex) {
				returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
			}

		} else if ('microsoftteams'.equalsIgnoreCase(stateArg)) {
			if(!SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2){
				String retURL = readParam('retURL');
				String returnURL = null;
				if(String.isNotBlank(retURL)) {
					returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
				}
				
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
							new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');

				returnPage.setRedirect(true);
				try {
					if(String.isNotBlank(errorArg)) {
						returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_MICROSOFT_TEAMS)));

					} else {
						Map<String,String> params = System.currentPageReference().getParameters();
						String externalId =  params.get('externalId');
						String email =  params.get('email');
						String displayName =  params.get('displayName');
						String isSuccess = params.get('isSuccess');
						String tenantId = params.get('tenantId');

						if (Boolean.valueOf(isSuccess)) {
							MicrosoftTeamsHelper msTeamsHelperObj = new MicrosoftTeamsHelper();
							msTeamsHelperObj.createPeopleIntegrationRecord(externalId, displayName, email, tenantId);

							String msgStr = prepareMessage('success',  STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_MICROSOFT_TEAMS));
							returnPage.getParameters().put('alert', msgStr);
						} else {
							returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_MICROSOFT_TEAMS)));
						}
					}
				} catch(Exception ex) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
				}
			} else if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2){
				String retURL = readParam('retURL');
				String returnURL = null;
				if(String.isNotBlank(retURL)) {
					returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
				}
				
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
							new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');

				returnPage.setRedirect(true);
				try { 
					String alert = readParam('alert');
					Map<String, Object> alertParamMap = (Map<String, Object>) JSON.deserializeUntyped(alert);
					String type = (String) alertParamMap.get('type');
					if(type.equalsIgnoreCase('danger')) {
						returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_MICROSOFT_TEAMS)));
					} else {
						// Hit MicrosoftTeams MS to validate user connection and fetch user details
						MicrosoftTeamsHelper msTeamsHelperObj = new MicrosoftTeamsHelper();
						Map<String, String> userProfileMap = msTeamsHelperObj.verifyAndGetUserDetails(false);
						String email = userProfileMap.get('email');
						String displayName = userProfileMap.get('userName');
						String externalId = userProfileMap.get('externalId');
						String tenantId = userProfileMap.get('tenantId');
						msTeamsHelperObj.createPeopleIntegrationRecord(externalId, displayName, email, tenantId);
						String msgStr = prepareMessage('success',  STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_MICROSOFT_TEAMS));
						returnPage.getParameters().put('alert', msgStr);
					}
				} catch(Exception ex) {
						returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
				}
			}
		} else if(IntegrationConstants.INTEGRATION_TYPE_SLACK.equalsIgnoreCase(stateArg)) {
			try {
				String retURL = readParam('retURL');
				String returnURL = null;
				if(String.isNotBlank(retURL)) {
					returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
				}
				
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
														new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
				returnPage.setRedirect(true);				
				String alert = readParam('alert');
				Map<String, Object> alertParamMap = (Map<String, Object>) JSON.deserializeUntyped(alert);
				String type = (String) alertParamMap.get('type');
				if(type.equalsIgnoreCase('danger')){
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', STR_SLACK)));
				} else {
					// Hit zeus MS to fetch slack user details
					SlackHelper helperObj = new SlackHelper();
					Map<String, String> userProfileMap = helperObj.getUserDetails();
					String userName = userProfileMap.get('userName');
					String userId = userProfileMap.get('userId');
					String teamId = userProfileMap.get('teamId');
					helperObj.createPeopleIntegrationRecord(userName,userId,teamId);
					returnPage.getParameters().put('alert',prepareMessage('success', STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_SLACK)));
				}
			} catch (Exception ex) {
				returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
    			returnPage.setRedirect(true);
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));				
			}
		} else if(IntegrationConstants.INTEGRATION_TYPE_SLACK_UNFURL.equalsIgnoreCase(stateArg)) {
			try {
				String retURL = readParam('retURL');
				String returnURL = null;
				if(String.isNotBlank(retURL)) {
					returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
				}
				
				returnPage = String.isNotBlank(retURL) ? new PageReference(returnURL) : 
														new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/messaging');
				returnPage.setRedirect(true);				
				String alert = readParam('alert');
				Map<String, Object> alertParamMap = (Map<String, Object>) JSON.deserializeUntyped(alert);
				String type = (String) alertParamMap.get('type');
				if(type.equalsIgnoreCase('danger')){
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_SLACK_INSTALL_ERROR_FLASH));
				} else {
					SlackHelper helperObj = new SlackHelper();
					helperObj.updateAppIntegrationRecord();
					returnPage.getParameters().put('alert',prepareMessage('success', STR_SLACK_INSTALL_SUCCESS_FLASH));	
				}
			} catch (Exception ex) {
				returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps');
    			returnPage.setRedirect(true);
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));				
			}
		} else if(String.isNotBlank(codeArg)) {
	    	if('facebook'.equalsIgnoreCase(stateArg)) {
	    		returnPage = processCodeFromFacebook(codeArg);
	    	} else if('twitter'.equalsIgnoreCase(stateArg)) {
	    		returnPage = processCodeFromTwitter(tokenArg, codeArg);
	    	} else if('linkedin'.equalsIgnoreCase(stateArg)) {
	    		returnPage = processCodeFromLinkedln(codeArg);
	    	} else if('adsi'.equalsIgnoreCase(stateArg)) {
	    		returnPage = processCodeFromAdsi(codeArg);
	    	} else if('ServiceNow'.equalsIgnoreCase(stateArg) || 'ServiceNowAdmin'.equalsIgnoreCase(stateArg)) {
	    		returnPage = processCodeFromServiceNow(stateArg, codeArg);
	    	} else if(EFSConstants.integrationStates.contains(stateArg.toLowerCase())) {
	    		// Service Account handling
	    		if(stateArg.endsWithIgnoreCase('admin')) {
	    			String storageStr = stateArg.replace('admin','').toLowerCase();
		    		EFSAccessService efsAccess = new EFSAccessService(storageStr, true);
		    		try {
				    	if(SimpplrContext.connectedStorages.contains(storageStr) && !SimpplrContext.Integrations.get(storageStr).Batch_Processing__c) {
					    	Boolean status = efsAccess.refreshToken(codeArg);
					    	returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
					    	if(!status) {
					    		returnPage.getParameters().put('status', 'false');
					    	} else {
					    		if('sharepointadmin'.equalsIgnoreCase(stateArg) || 'onedriveadmin'.equalsIgnoreCase(stateArg)) {
					    			// Since SharePoint/OneDrive is Client Managed, do nothing
					    		} else {					    
								    // All Company group
								    EFSGroupService gs = new EFSGroupService(storageStr);
								    String allCompanyGroupId;
								    
								    if('dropboxadmin'.equalsIgnoreCase(stateArg)) {
								    	allCompanyGroupId = gs.createGroup(SimpplrContext.applicationName + '[' + UserInfo.getOrganizationId()+ '] Company Group', 'Read Group for All Company', UserInfo.getOrganizationId()+'@'+SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Enterprise_Id__c);
								    }
								    
								    List<App_Integration__c> appIntegList = new List<App_Integration__c>();
									if('dropboxadmin'.equalsIgnoreCase(stateArg)){
										appIntegList.add(SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING));
									}
									
									EFSFileService EFSFileServiceObj = null;
									
									if(!appIntegList.isEmpty()){																			    
									    // For Dropbox Integration
									    // Update the All Company Group ID and EFS Root Folder in the App Config
									    // Set the Batch_Flag__c for all the people records
										if('dropboxadmin'.equalsIgnoreCase(stateArg)) {
									    	appIntegList[0].All_Company_Group_Id__c = allCompanyGroupId;
									    	appIntegList[0].Root_Folder_Id__c = '/' + SimpplrContext.applicationName;
									    	
									    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				    						SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appIntegList),
				    																  new List<Schema.SObjectField>{App_Integration__c.All_Company_Group_Id__c,
				    																  								App_Integration__c.Root_Folder_Id__c});
											// For Dropbox, the Batch_Flag__c has to be set for all users whose flag is false
											Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('SETMOUNTFLAG'), 5000);
									    }
									    
									    // The approach is yet to be finalized
								    }
								    
								    gs.close();
								    if(EFSFileServiceObj != null) {
								    	EFSFileServiceObj.close();
								    }
					    		}
					    	}
			    			returnPage.setRedirect(true);
				    	} else {
				    		returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
		    				returnPage.setRedirect(true);
			    			if(SimpplrContext.connectedStorages.contains(storageStr) && SimpplrContext.Integrations.get(storageStr).Batch_Processing__c) {
			    				returnPage.getParameters().put('alert',prepareMessage('danger',  'Unable to perform action - please try again after some time'));
			    			} else if(!errorArg.equalsIgnoreCase(EFSConstants.userCancelledAuthMsg)) {
			    				returnPage.getParameters().put('alert',prepareMessage('danger', errorArg));	
			    			}
				    	}
		    		} catch(Exception ex) {
		    			returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
		    			returnPage.setRedirect(true);
		    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
		    			returnPage.getParameters().put('Args', JSON.serialize(SimpplrContext.integrations.get(storageStr)));
		    		}
		    		efsAccess.close();
	    		} else { // User Account handling
	    			String storageArg = stateArg.toLowerCase();
		    		EFSAccessService gdAccess = new EFSAccessService(storageArg, false);
		    		returnPage = Page.MySettingsExternalapps;
		    		returnPage.getParameters().put('profileId', UserContext.peopleId);
		    		returnPage.setRedirect(true);
		    		try {
				    	if(String.isNotBlank(codeArg) && SimpplrContext.connectedStorages.contains(storageArg) &&  !SimpplrContext.Integrations.get(storageArg).Batch_Processing__c) {
					    	Boolean status = gdAccess.refreshToken(codeArg);
					    	if(!status) {
					    		returnPage.getParameters().put('status', 'false');
					    	}else{
					    		Database.executeBatch(new BatchEFSFolderSync('USER', UserContext.Id, stateArg), 1);
					    	}
			    			returnPage.setRedirect(true);
				    	} else {
			    			if(SimpplrContext.connectedStorages.contains(storageArg) && SimpplrContext.Integrations.get(storageArg).Batch_Processing__c) {
			    				returnPage.getParameters().put('alert',prepareMessage('danger',  'Unable to perform action - please try again after some time'));
			    			} else if(!errorArg.equalsIgnoreCase(EFSConstants.userCancelledAuthMsg)) {
			    				returnPage.getParameters().put('alert',prepareMessage('danger', errorArg));	
			    			}
				    	}
		    		} catch(Exception ex) {
		    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
		    		}
	    		}
	    	}
		} else if(String.isBlank(codeArg)) {
			returnPage = initReturnPageReference();
			if(String.isBlank(errorArg) || 'user_cancelled_login'.equalsIgnoreCase(errorArg) || 'user_cancelled_authorize'.equalsIgnoreCase(errorArg) || 'access_denied'.equalsIgnoreCase(errorArg) || 'denied'.equalsIgnoreCase(errorArg)){
				
			} else {
				returnPage.getParameters().put('alert', prepareMessage('danger', errorArg));
			}	
		}
		if('slackAppInstall'.equalsIgnoreCase(stateArg)){
			returnPage = processSlackAppInstall();
		} else if('slackAppInstallRedirect'.equalsIgnoreCase(stateArg)){
			returnPage = redirectToSlackAppInstallUrl();
		} else if('slackAppUninstall'.equalsIgnoreCase(stateArg)){
			returnPage = processSlackAppUninstall();
		}	else if('enableSlackForSite'.equalsIgnoreCase(stateArg)){
			String siteId = SiteContext.siteId;
			returnPage = enableSlackForSite(siteId);
		} else if('removeSlackFromSite'.equalsIgnoreCase(stateArg)){
			String siteId = SiteContext.siteId;
			returnPage = removeSlackFromSite(siteId);
		} else if('resetSiteSlackSetting'.equalsIgnoreCase(stateArg)){
			String siteId = SiteContext.siteId;
			returnPage = resetSiteSlackSetting(siteId);
		}
		
		return returnPage;
	}
	
	/**
	 * @description getDomainName from email address
	 * @return String
	 */
	private String getDomainName(){
		String appIntQuery = 'Select Id, User_Email__c From App_Integration__c'
							+ ' Where  Name in :soqlParam1 AND Integration_Enabled__c=true AND Connected__c = true '										 
							+ ' AND Is_Deleted__c = false limit 1';
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		Set<String> googleIntegrationType = new Set<String> {IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR};
		sqlParamMap.put('soqlParam1', googleIntegrationType);
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegObj = ((List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap));
		String userDomain = !appIntegObj.isEmpty() ? appIntegObj[0].User_Email__c.split('@').get(1) : '';
		return userDomain;
	}

	/**
	 * @description getDomainName from email address
	 * @return String
	 */
	private String getActiveDirectoryDomainName(){
		String appIntQuery = 'Select Id, User_Email__c From App_Integration__c'
							+ ' Where  Name =: soqlParam1'
							+ ' limit 1';
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY);
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegrationList = ((List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap));
		String userDomain = !appIntegrationList.isEmpty() ? appIntegrationList[0].User_Email__c?.split('@').get(1) : '';
		return userDomain;
	}	

	private void saveUserWebPushConfig(String webPushToken, String userAgent) {
		String peopleId = UserContext.peopleId;
		
		// send info/details to Lambda
		Utility.sendWebPushConfigInfoToLambda(peopleId, webPushToken, userAgent);
		
		List<People_Preference__c> notificationPrefList = [SELECT id, Allow_Browser_Notifications__c FROM People_Preference__c WHERE People__r.Id =: peopleId WITH SECURITY_ENFORCED];

		if(!notificationPrefList.isEmpty()) {
			People_Preference__c ppObj = notificationPrefList[0];
			ppObj.Allow_Browser_Notifications__c = 'Yes';

			// Save user preference - Web push notifications
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(ppObj, new List<Schema.SObjectField>{
							People_Preference__c.Allow_Browser_Notifications__c
			});
		}
	}
    
    private PageReference processCodeFromFacebook (String code) {
    		PageReference returnPage = initReturnPageReference();
    		
    		try {
    			IntegrationService integrationServiceObj = new IntegrationService('facebook', UserContext.peopleId);
    			integrationServiceObj.validateIntegrator();
    			integrationServiceObj.exchangeCode(code, true);
    			String access_token = integrationServiceObj.getAccessToken();
    			
    			String permissionCheckURL = IntegrationConstants.FACEBOOK_POSTING_ENDPOINT + 
						'me/permissions';
				HttpRequest reqObj = new HttpRequest();
	    		reqObj.setEndpoint(permissionCheckURL);
	    		String authorizationHeader = 'Bearer ' + access_token;
	    		reqObj.setHeader('Authorization', authorizationHeader);
	    		reqObj.setMethod('GET');
	    		Http httpObj = new Http();
	    		HTTPResponse resObj = httpObj.send(reqObj);
	    		
	    		if (resObj.getStatusCode()== 200) { 
	    			String fbResponse = resObj.getBody();
	    			FacebookService.PermissionContainerWrapper fbResponseObj = new FacebookService.PermissionContainerWrapper();
	    			fbResponseObj = (FacebookService.PermissionContainerWrapper)JSON.deserialize(fbResponse, 
	    					FacebookService.PermissionContainerWrapper.class);
	    			
	    			if (!fbResponseObj.data.isEmpty()) {
		    			
		    			for (FacebookService.PermissionWrapper permissionObj: fbResponseObj.data) {
			    			
			    			if (permissionObj.permission == 'publish_actions' && 
			    					permissionObj.status =='declined') {
			    				throw new SimpplrException('Unable to connect with Social Network - please try again');
			    			}	
			    			
		    			} 
		    			
	    			}
	    			
	    		}
	    		
	    		if(!Test.isRunningTest()){
	    			HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET', 'https://graph.facebook.com/me?fields=id,name', 'Bearer ' + access_token,'');
	       			Map<String, Object> profileData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
	       			integrationServiceObj.updateUserInfo((String)profileData.get('id'), null, (String)profileData.get('name'), null);
	    			integrationServiceObj.close();
	    		}
    		
    		} catch (Exception ex) {
    			returnPage.getParameters().put('alert',prepareMessage('danger', ex.getMessage()));
    		}
    		
    		return returnPage;
    }
    
    private PageReference processCodeFromTwitter (String token, String code) {
		PageReference returnPage = initReturnPageReference();	    		
    	try {
    		TwitterService twtService = new TwitterService();
    		Boolean isAccessTokenSaved = twtService.saveAccessToken(token, code);
			if(isAccessTokenSaved){
    			returnPage.getParameters().put('alert',prepareMessage('success', STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_TWITTER)));			
			}
    	} catch (Exception ex) {
    		returnPage.getParameters().put('alert',prepareMessage('danger', ex.getMessage()));
    	}	    		
    	return returnPage;
    }
    
    private PageReference processCodeFromLinkedln(String code){
     	PageReference returnPage = initReturnPageReference();
     	try {
    			IntegrationService linkelnIntegration = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN, UserContext.peopleId);
    			linkelnIntegration.validateIntegrator();
    			linkelnIntegration.exchangeCode(code, true);
    			String access_token = linkelnIntegration.getAccessToken();
    			
        		HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET', 'https://api.linkedin.com/v2/me', 'Bearer ' + access_token,'');
       		if(res.getStatusCode() == 200) {
						Map<String, Object> profileData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
						linkelnIntegration.updateUserInfo((String)profileData.get('id'), null, (String)profileData.get('localizedFirstName') +' ' +(String)profileData.get('localizedLastName'), null);
						returnPage.getParameters().put('alert',prepareMessage('success', STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_LINKEDIN)));
					 } else {
						 throw new SimpplrException(res.getStatus());
					 }
						linkelnIntegration.close();
					 
    			
    		} catch (Exception ex) {
    			returnPage.getParameters().put('alert',prepareMessage('danger', ex.getMessage()));
    		}
    		return returnPage;
     }
     
	 private PageReference processCodeFromAdsi(String code){
     	PageReference returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/people');
     	returnPage.setRedirect(true);
     	
 		try {
 			IntegrationService adIntegration = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_ADSI, null);
			adIntegration.exchangeCode(code, true);
			String access_token = adIntegration.getAppAccessToken();
			
			Map<String, String> headerMap = new Map<String, String>();
			headerMap.put('Accept', '*/*');
    		HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET', 'https://graph.microsoft.com/v1.0/me', 'Bearer ' + access_token, '', headerMap);
       		
       		if(res.getStatusCode() == 200){
       			Map<String, Object> profileData = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
	       		adIntegration.updateUserInfo((String)profileData.get('id'), (String)profileData.get('mail'), (String)profileData.get('displayName'), null);
				
				adIntegration.close();
				String msgStr = prepareMessage('success',  STR_CONNECTION_SUCCESS.replace('{{appName}}', STR_ACTIVE_DIRECTORY));
				returnPage.getParameters().put('alert', msgStr);
			} else {
       			returnPage.getParameters().put('alert',prepareMessage('danger', 'Unable to get user info.'));
       		}
		} catch (Exception ex) {
			returnPage.getParameters().put('alert',prepareMessage('danger', ex.getMessage()));
		}
    		
		return returnPage;
     }

     private PageReference processCodeFromServiceNow(String state, String code){
     	PageReference returnPage = initReturnPageReference();
    		try {
				String clientIdDecrypted = Utility.decryptFn(SimpplrContext.serviceNowClientId);
				String clientSecretDecrypted = Utility.decryptFn(SimpplrContext.serviceNowClientSecret);
				Blob headerValue = Blob.valueOf(clientIdDecrypted + ':' + clientSecretDecrypted);
				String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
				HttpRequest reqObj = new HttpRequest();
				reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getaccesstoken');
				reqObj.setHeader('content-type','application/x-www-form-urlencoded');
				reqObj.setHeader('accept', 'application/json');
				reqObj.setMethod('POST');
				String redUrl = EncodingUtil.urlEncode('https://services.simpplr.com/oauth/redirect/code_passthrough.php', 'UTF-8');
				reqObj.setBody('{"code":"'+code + '","grantType":"authorization_code","tokenUrl":"' + SimpplrContext.serviceNowInstanceUrl + '/oauth_token.do","integrationname":"servicenow","redirectUrl":"'+redUrl+'","scope":"useraccount","method":"POST", "authorizationHeader": "'+authorizationHeader+'" }');
				Http httpObj = new Http();
				HTTPResponse resObj = httpObj.send(reqObj);
				if (resObj.getStatusCode()== 200) { 
					String resBodyJSON = resObj.getBody();
					Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyJSON);
					if(resBody.get('access_token') != null){
						ServiceNowWrapper serviceNowUser = getServiceNowUser(String.valueOf(resBody.get('access_token')));
						if(serviceNowUser != null){
							String retURL = readParam('retURL');
							if('ServiceNowAdmin'.equalsIgnoreCase(state)) {
								updateAppIntegRecord(serviceNowUser, resBody);
							} else {
								createPeopleIntegRecord(serviceNowUser, resBody);
							}
							
						} else {
							returnPage.getParameters().put('alert','{"type": "success", "message": "'+STR_CONNECTION_SUCCESS.replace('{{appName}}', 'ServiceNow')+'"}');
						}

						returnPage.getParameters().put('alert','{"type": "success", "message": "'+STR_CONNECTION_SUCCESS.replace('{{appName}}', 'ServiceNow')+'"}');
					} else {
						returnPage.getParameters().put('alert',prepareMessage('danger', STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', 'ServiceNow')));
					} 
				} else {
					returnPage.getParameters().put('alert',prepareMessage('danger', STR_CONNECTION_ERROR_FLASH.replace('{{appName}}', 'ServiceNow')));
				}
			} catch (Exception ex) {
    			returnPage.getParameters().put('alert',prepareMessage('danger', ex.getMessage()));
    		}
    		
    		
		return returnPage;
     }
	@testVisible
	private void createPeopleIntegRecord(ServiceNowWrapper serviceNowUser, Map<String,Object> resBody){
		if(UserContext.Integrations != null && UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) !=  null){
			People_Integration__c peopleIntegObj = UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
			peopleIntegObj.Is_Deleted__c = true;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(peopleIntegObj, new List<Schema.SObjectField>{
									People_Integration__c.Is_Deleted__c
								});
			
		}
		People_Integration__c peopleIntegObj = new People_Integration__c();
		peopleIntegObj.Access_Token__c = String.valueOf(resBody.get('access_token'));
		peopleIntegObj.Refresh_Token__c = String.valueOf(resBody.get('refresh_token'));
		if(serviceNowUser != null && serviceNowUser.result != null && serviceNowUser.result.isEmpty()==false){
			peopleIntegObj.User_Name__c = serviceNowUser.result[0].user_name.display_value;
			peopleIntegObj.User_Email__c = serviceNowUser.result[0].user_name.display_value;
			peopleIntegObj.External_id__c = serviceNowUser.result[0].sys_id.value;
		}
		peopleIntegObj.Access_Token_Expiry__c =  (Decimal)resBody.get('expires_in');
		peopleIntegObj.Access_Token_Expiration_Datetime__c = DateTime.now().addSeconds(peopleIntegObj.Access_Token_Expiry__c.intValue());
		peopleIntegObj.Access_Token_Requested_Datetime__c = DateTime.now();
		peopleIntegObj.Name = IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW;
		peopleIntegObj.Connected__c = true;
		peopleIntegObj.People__c = UserContext.peopleId;
		if(UserContext.getCurrentUserInfo != null){
			peopleIntegObj.OwnerId = UserContext.getCurrentUserInfo.User__c;
		}			
		peopleIntegObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).id;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(peopleIntegObj, new List<Schema.SObjectField>{
				People_Integration__c.Access_Token__c,
				People_Integration__c.Refresh_Token__c,
				People_Integration__c.User_Name__c,
				People_Integration__c.User_Email__c,
				People_Integration__c.Access_Token_Expiry__c,
				People_Integration__c.Access_Token_Expiration_Datetime__c,
				People_Integration__c.Access_Token_Requested_Datetime__c,
				People_Integration__c.Name,
				People_Integration__c.Connected__c,
				People_Integration__c.People__c,
				People_Integration__c.App_Integration__c,
				People_Integration__c.External_Id__c,
				People_Integration__c.OwnerId
		});
	}
	@testVisible
	private void updateAppIntegRecord(ServiceNowWrapper serviceNowUser, Map<String,Object> resBody){ 
		String orgId = UserInfo.getOrganizationId();
		String appIntQuery = 'Select Id, Connected__c, App_Access_Token__c, App_Refresh_Token__c, User_Name__c, External_id__c,'
										 + ' Access_Token_Expiry__c, Access_Token_Expiration_Datetime__c,'
										 + ' Access_Token_Requested_Datetime__c, Connected_DateTime__c From App_Integration__c'
										 + ' Where  Name = :soqlParam1'
										 + ' AND Integration_Enabled__c=true'
										 + ' AND Org_Id__c = :soqlParam2'
										 + ' AND Is_Deleted__c = false limit 1';

		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
		sqlParamMap.put('soqlParam2', orgId);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_integration__c appIntegObj = ((List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap))[0];

		appIntegObj.App_Access_Token__c = String.valueOf(resBody.get('access_token'));
		appIntegObj.App_Refresh_Token__c = String.valueOf(resBody.get('refresh_token'));
		appIntegObj.Refresh_Token_Expiration_Datetime__c = DateTime.now().addDays(100);
		appIntegObj.Access_Token_Expiry__c =  (Decimal)resBody.get('expires_in');
		appIntegObj.Access_Token_Expiration_Datetime__c = DateTime.now().addSeconds(appIntegObj.Access_Token_Expiry__c.intValue());
		appIntegObj.Access_Token_Requested_Datetime__c = DateTime.now();
		appIntegObj.Name = IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW;
		appIntegObj.Connected__c = true;
		appIntegObj.Connected_DateTime__c = DateTime.now();

		if(serviceNowUser != null && serviceNowUser.result != null && serviceNowUser.result.isEmpty()==false){
			appIntegObj.User_Name__c = serviceNowUser.result[0].user_name.display_value;
			appIntegObj.External_id__c = serviceNowUser.result[0].sys_id.value;
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appIntegObj, new List<Schema.SObjectField>{
				App_Integration__c.App_Access_Token__c,
				App_Integration__c.App_Refresh_Token__c,
				App_Integration__c.User_Name__c,
				App_Integration__c.Access_Token_Expiry__c,
				App_Integration__c.Access_Token_Expiration_Datetime__c,
				App_Integration__c.Access_Token_Requested_Datetime__c,
				App_Integration__c.Connected__c,
				App_Integration__c.External_Id__c,
				App_Integration__c.Connected_DateTime__c
		});
	}
	@testVisible
	private ServiceNowWrapper getServiceNowUser(String accessToken){
		ServiceNowWrapper serviceNowWrapperObj;
		HttpRequest reqObj = new HttpRequest();
		reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=getUserDetail');
		reqObj.setHeader('content-type','application/json');
		reqObj.setHeader('accept', 'application/json');
		reqObj.setMethod('POST');
		reqObj.setBody('{"accessToken":"'+accessToken+'","endpoint":"'+SimpplrContext.serviceNowInstanceUrl+'/api/now/table/sys_user?sysparm_display_value=all&sysparm_fields=user_name%2Csys_id&sysparm_query=sys_id%3Djavascript%3Ags.getUserID()%3B","integrationname":"servicenow"}');
		Http httpObj = new Http();
		HTTPResponse resObj = httpObj.send(reqObj);
		if (resObj.getStatusCode()== 200) { 
			String resBodyJSON = resObj.getBody();
			serviceNowWrapperObj = (ServiceNowWrapper)JSON.deserialize(resBodyJSON,ServiceNowWrapper.class);			
		}
		return serviceNowWrapperObj;
	}

	private PageReference processSlackAppInstall(){
     	PageReference returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/messaging');
     	returnPage.setRedirect(true);
     	String status = readParam('status');
 		try {
 			if(String.isNotBlank(status) && 'success'.equalsIgnoreCase(status)){
				String appIntQuery = 'select id, App_Installed__c from App_Integration__c where name = :soqlParam1 AND Integration_Enabled__c = true AND Is_Deleted__c = false';
				Map<String, Object> sqlParamMap = new Map<String, Object>();
				sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SLACK);

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
				
				if(appIntegList.isEmpty()==false){
					if(appIntegList[0].App_installed__c == false) {
						appIntegList[0].App_installed__c = true;

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appIntegList),
																	new List<Schema.SObjectField>{App_Integration__c.App_installed__c});
					}
				} else {
					App_Integration__c appIntegObj = new App_Integration__c(Integration_Enabled__c=true,
    												Client_Id__c=IntegrationConstants.SLACK_CLIENT_ID,
    												Client_Secret__c=IntegrationConstants.SLACK_CLIENT_SECRET,
    												Org_Id__c = UserInfo.getOrganizationId(),
    												name=IntegrationConstants.INTEGRATION_TYPE_SLACK);
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().insertAsUser(appIntegObj,
							new List<Schema.SObjectField>{
								App_Integration__c.Integration_Enabled__c, 
								App_Integration__c.Name, 
								App_Integration__c.Client_Id__c, 
								App_Integration__c.Client_Secret__c, 
								App_Integration__c.Org_Id__c});
				}
				returnPage.getParameters().put('alert',prepareMessage('success', STR_SLACK_INSTALL_SUCCESS_FLASH));

			} else {
				returnPage.getParameters().put('alert',prepareMessage('danger', STR_SLACK_INSTALL_ERROR_FLASH));
			}
		} catch (Exception ex) {
			returnPage.getParameters().put('alert',prepareMessage('danger', ex.getMessage()));
		}
    		
		return returnPage;
     }

	 private PageReference redirectToSlackAppInstallUrl(){
     	String baseUrl = SimpplrContext.salesforceBaseUrl+'/';
		String slackStateJSON = '{"redirectUrl":"'+PageContext.getPageURL(Pages.ConnectExternalApp)+'?state=slackAppInstall'+'","appName":"'+SimpplrContext.applicationName+'","sfOrgId":"'+ SimpplrContext.simpplrOrgId+'","baseUrl":"'+baseUrl+'","isSandBox":'+SimpplrContext.isSandbox+'}';
		String addToSlackUrl = 'https://slack.com/oauth/authorize?client_id=' + IntegrationConstants.SLACK_CLIENT_ID +'&scope=groups:read,channels:read,links:read,links:write,chat:write:bot,team:read,users:read&state=' + slackStateJSON;
		PageReference returnPage = new PageReference(addToSlackUrl);
     	returnPage.setRedirect(true);
     	return returnPage;
     }


	private PageReference processSlackAppUninstall(){
     	PageReference returnPage = new PageReference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/messaging');
     	returnPage.setRedirect(true);
     	String status = readParam('status');
		try {
			String source = readParam('source');
			if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded) {
				HttpResponse response = new SlackHelper().processSlackDisconnectionAtZeus(IntegrationConstants.INTEGRATION_SLACK_UNFURL, IntegrationConstants.INTEGRATION_FLOW_APP, false, false);
			}
			else if(String.isNotBlank(source) && 'salesforce'.equalsIgnoreCase(source)){
				clearInstallationDetailFromAWS();
			}
			
			String appIntQuery = 'select id, App_Installed__c from App_Integration__c where name = :soqlParam1 AND Is_Deleted__c = false';
			Map<String, Object> sqlParamMap = new Map<String, Object>();
			sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SLACK);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
			
			if(appIntegList.isEmpty()==false) {
				if(appIntegList[0].App_installed__c == true) {
					appIntegList[0].App_installed__c = false;
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appIntegList), new List<Schema.SObjectField>{									
						App_Integration__c.App_installed__c
							});
				}
				if(!(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded)) {
					BatchSlackDisconnectUsers job = new BatchSlackDisconnectUsers();
					Database.executeBatch(job,2000);
				}	
				returnPage.getParameters().put('alert',prepareMessage('success', STR_SLACK_UNINSTALL_SUCCESS_FLASH));
			} else {
				returnPage.getParameters().put('alert',prepareMessage('danger', STR_SLACK_UNINSTALL_ERROR_FLASH));
			}
		} catch (Exception ex) {
			returnPage.getParameters().put('alert',prepareMessage('danger', ex.getMessage()));
		}
		return returnPage;
    } 

	@future (callout =true)
	public static void clearInstallationDetailFromAWS(){
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		String dri = Utility.requestAdoptionDataAuthToken();
		String endPoint = 'https://services.simpplr.com/integration/manage-slack.php';
		req.setEndpoint(endPoint);
		req.setBody('{"data":{"action_name":"clearInstallationDetail","sfOrgId":"'+SimpplrContext.simpplrOrgId+'","dri":"'+dri+'"}}');
		req.setHeader('Content-Type','application/x-www-form-urlencoded');
		req.setMethod('POST');
		req.setTimeout(60000);
		HttpResponse res = h.send(req);
	} 
	private PageReference removeSlackFromSite(String siteId){
		PageReference returnPage = new PageReference(PageContext.getPageURL(Pages.app)+ '?u=/manage/sites/'+ siteId + '/external-apps');
		returnPage.setRedirect(true);
		try {
 			List<Simpplr_Site__c> siteList = [SELECT Id, Slack_Access_Token__c, Slack_Channel_Name__c, Slack_Url__c, Slack_Post_Enabled__c,
			 					 Slack_Integration_Enabled__c, Slack_Comment_Enabled__c, Slack_Site_Manager__c FROM Simpplr_Site__c where Id =: siteId WITH SECURITY_ENFORCED];
	  	if(siteList.isEmpty()==false){
		  	siteList[0].Slack_Access_Token__c = null;
		  	siteList[0].Slack_Channel_Name__c = null;
			siteList[0].Slack_Url__c = null;
			siteList[0].Slack_Post_Enabled__c = false;
			siteList[0].Slack_Integration_Enabled__c = false;
			siteList[0].Slack_Comment_Enabled__c = false;
			siteList[0].Slack_Site_Manager__c = null;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
				Simpplr_Site__c.Slack_Access_Token__c,
				Simpplr_Site__c.Slack_Channel_Name__c,
				Simpplr_Site__c.Slack_Url__c,
				Simpplr_Site__c.Slack_Post_Enabled__c,
				Simpplr_Site__c.Slack_Integration_Enabled__c,
				Simpplr_Site__c.Slack_Comment_Enabled__c,
				Simpplr_Site__c.Slack_Site_Manager__c
			});	

	  		returnPage.getParameters().put('alert',prepareMessage('success', 'Successfully removed Slack integration from the site'));
			} else {
				returnPage.getParameters().put('alert',prepareMessage('danger', 'Unable to remove Slack integration from the site'));
			}

		} catch (Exception ex) {
			returnPage.getParameters().put('alert',prepareMessage('danger', ex.getMessage()));
		}
    		
		return returnPage;
  }

	private PageReference enableSlackForSite(String siteId){
		PageReference returnPage = new PageReference(PageContext.getPageURL(Pages.app)+'?u=/manage/sites/'+ siteId + '/external-apps&slackEnabled=true');
		returnPage.setRedirect(true);
		return returnPage;
  }

	private PageReference resetSiteSlackSetting(String siteId){
		SiteService service = new SiteService();
		service.disconnectApp(siteId, IntegrationConstants.INTEGRATION_TYPE_SLACK);
		PageReference returnPage = new PageReference(PageContext.getPageURL(Pages.app)+'?u=/manage/sites/'+ siteId + '/external-apps&slackEnabled=true');
		returnPage.setRedirect(true);
		return returnPage;
  }

  private void processResponseForServiceAccount(){
		String appIntQuery = 'Select Id From App_Integration__c'
													  + ' Where Name = :soqlParam1'
													  + ' AND  Org_Id__c = :soqlParam2'
													  + ' AND Is_Deleted__c = false';
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_SERVICE_ACCOUNT);
		sqlParamMap.put('soqlParam2', UserInfo.getOrganizationId());

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
													  
		if(appIntegList.isEmpty()){
			App_Integration__c appIntegRecord = new App_Integration__c();
			appIntegRecord.Name = IntegrationConstants.INTEGRATION_TYPE_SERVICE_ACCOUNT;
			appIntegRecord.User_Email__c = UserInfo.getUserName();
			appIntegRecord.User_Name__c = UserContext.getCurrentUserInfo.Full_Name__c;
			appIntegRecord.App_Access_Token__c ='DUMMY';
			appIntegRecord.Client_Id__c ='DUMMY';
			appIntegRecord.Client_Secret__c ='DUMMY';
			appIntegRecord.App_Refresh_Token__c='DUMMY';
			appIntegRecord.Connected__c = true;
			appIntegRecord.Org_Id__c = UserInfo.getOrganizationId();

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(appIntegRecord, new List<Schema.SObjectField>{
				App_Integration__c.Name,
				App_Integration__c.User_Email__c,
				App_Integration__c.User_Name__c,
				App_Integration__c.App_Access_Token__c,
				App_Integration__c.Client_Id__c,
				App_Integration__c.Client_Secret__c,
				App_Integration__c.App_Refresh_Token__c,
				App_Integration__c.Connected__c,
				App_Integration__c.Org_Id__c});

		}
		
		String appConfigQuery = 'select id,External_Search_Connected_By_People__c, AWS_Access_Token__c, External_Search_Enabled__c  from app_config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c configObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
		configObj.External_search_app_connected__c = true;
		configObj.External_Search_Enabled__c = true;
		configObj.External_Search_Connected_By_People__c = UserContext.peopleId;
		configObj.Simpplr_Domain__c = SimpplrContext.salesforceBaseUrl;
		configObj.AWS_Access_Token__c = SimpplrContext.simpplrOrgId + ':';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(configObj, new List<Schema.SObjectField>{
			App_Config__c.External_search_app_connected__c,
			App_Config__c.External_Search_Enabled__c,
			App_Config__c.External_Search_Connected_By_People__c,
			App_Config__c.Simpplr_Domain__c,
			App_Config__c.AWS_Access_Token__c
		});

		try{
			SchedulerDao schedulerDaoObj= new SchedulerDao();
			schedulerDaoObj.abortNonServiceAccountScheduledJob(UserContext.id);
			schedulerDaoObj.scheduleAllSchedulerNow();
		}catch(Exception e){}
  }

	private PageReference initReturnPageReference() {
		PageReference returnPage;
		String retURL = readParam('retURL');
		String returnURL = null;
		if(String.isNotBlank(retURL)) {
			returnURL = SimpplrContext.salesforceBaseUrl + new Url(retUrl).getPath() + '?' + new Url(retUrl).getQuery();
		}

		if(String.isNotBlank(retURL)) {
			returnPage = new PageReference(returnURL);
			returnPage.setRedirect(true);	
		} else {
			returnPage = Page.app;
			returnPage.getParameters().put('u', '/my-settings/external-apps');
			returnPage.setRedirect(true);
		}

		return returnPage;
	}
    
    private String prepareMessage(String type, String message) {
	    	Map<String, String> messageMap = new Map<String, String>();
	    	messageMap.put('type', type);
	    	messageMap.put('message', message);
	    	return JSON.serialize(messageMap);
    }
    
    private class FBAccessTokenWrapper {
	    	public String access_token {get;set;}
	    	public String token_type {get;set;}
	    	public Integer expires_in {get;set;}
    }

	/**
	* @description read request parameters
	* @param requestParamName request param key
	* @return String request param value
	**/
	public String readParam(String requestParamName){
    	String requestParamValue;
		if (System.currentPageReference() != null) {
			requestParamValue = System.currentPageReference().getParameters().get(requestParamName);
		}
		return requestParamValue;
	}

	/**
	* @description JS encode and read request parameters
	* @param requestParamName request param key
	* @return String request param value
	**/
	public String readSafeParam(String requestParamName){
		return SIMPESAPI.encoder().SFDC_JSENCODE(readparam(requestParamName));
	}
}