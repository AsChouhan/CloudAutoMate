public with sharing class StorageSettingsCtrl {
	private BoxService boxServiceObj = new BoxService();
	public final String STR_DOMAIN_OR_ACCOUNT_MISMATCH = 'domain_or_account_mismatch';// NOPMD - correct naming convension, suppressed codacy error
	public final String STR_NOT_A_GSUITE_ACC = 'not_a_gsuite_account';// NOPMD - correct naming convension, suppressed codacy error
	public final String STR_SETUP_DOMAIN_MISMATCH ='setup_domain_mismatch';// NOPMD - correct naming convension, suppressed codacy error
	public final String STR_DOMAIN_MISMATCH_ERR_CODE ='domain_mismatch';// NOPMD - correct naming convension, suppressed codacy error
	public Map<String,String> labelMap = LocaleContext.getLabelMap(PageContext.currentPageName, UserContext.languageLocaleKey);
	public transient final String STR_APPS_CONNECTION_SUCCESS_LABEL { get { return labelMap.get('apps.connection.success');}}
	public transient final String STR_APPS_CONNECTION_ERROR_LABEL { get { return labelMap.get('apps.connection.error_flash');}}
	public transient final String STR_BATCH_PROCESSING_TRY_LATER { get { return labelMap.get('apps.connection.batch_processing_try_later');}}
	/**
    * @description This constant is used to fetch the error message from labelMap
    */
    public transient final String STR_SHAREPOINT_CONNECTION_ERROR { get { return labelMap.get('apps.connection.sharepoint.admin_not_connected');}}
	
	/*
	public transient final String STR_KEY_1 { get { return labelMap.get('apps.connection.google.domain_or_account_mismatch');}}
	public transient final String STR_KEY_2 { get { return labelMap.get('apps.connection.google.user_account_mismatch');}}
	public transient final String STR_KEY_3 { get { return labelMap.get('apps.connection.google.not_a_gsuite_account');}}
	public transient final String STR_KEY_4 { get { return labelMap.get('apps.connection.google.invalid_integration_type');}}
	public transient final String STR_KEY_5 { get { return labelMap.get('apps.connection.google.setup_domain_mismatch');}}	
	*/
	public static String pageName {get{
    	if(String.isEmpty(pageName)){
    		pageName = PageContext.namespacePrefix + 'StorageSettings';
    	}
    	return pageName;
    }set;} 

    public PageReference saveUserDetails() {
    	PageReference returnPage;
    	String storageType = readSafeParam('state');
		String codeArg = readParam('code');
		String errorArg = readSafeParam('error');
		String errorCodeArg = readSafeParam('error_code');
		
		if (String.isNotBlank(storageType) && storageType.containsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
			errorArg = readSafeParam('error_description');
		}

		//Protect from forgery 
		AccessManager.protectFromRequestForgery();

    	if ('Box'.equalsIgnoreCase(storageType)) {
    		try {
		    	if(String.isNotBlank(codeArg)) {
			    	boxServiceObj.pullBoxToken(codeArg, UserContext.peopleId); 
			    	returnPage = Page.app;
					returnPage.getParameters().put('u', '/my-settings/external-apps');
					returnPage.getParameters().put('alert',prepareMessage('success',  STR_APPS_CONNECTION_SUCCESS_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(storageType.toLowercase()))));
	    			returnPage.setRedirect(true);
		    	} else {
		    		returnPage = Page.app;
			    	returnPage.getParameters().put('u', '/my-settings/external-apps');
	    			returnPage.setRedirect(true);
	    			returnPage.getParameters().put('alert',prepareMessage('danger', errorArg));
		    	}
    		} catch(Exception ex) {
    			returnPage = Page.app;
				returnPage.getParameters().put('u', '/my-settings/external-apps');
    			returnPage.setRedirect(true);
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    		}
    	} else if('BoxAdmin'.equalsIgnoreCase(storageType)) {
    		try {
		    	if(String.isNotBlank(codeArg)) {
					boxServiceObj.pullBoxAdminToken(codeArg);
					returnPage = Page.app;
					returnPage.getParameters().put('u', '/manage/app/integrations/files');
					returnPage.getParameters().put('alert', prepareMessage('success', STR_APPS_CONNECTION_SUCCESS_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get('box'))));
	    			returnPage.setRedirect(true);
		    	} else {
		    		returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
    				returnPage.setRedirect(true);
    				returnPage.getParameters().put('alert',prepareMessage('danger', errorArg));
		    	}
    		} catch(Exception ex) {
    			returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
    			returnPage.setRedirect(true);
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    		}
    	} else if('dropbox'.equalsIgnoreCase(storageType) ||
    			  'onedrive'.equalsIgnoreCase(storageType) || 
    			  'sharepoint'.equalsIgnoreCase(storageType)) { 
    		// 08MAY17 - Changes added for Google Drive Integration
    		EFSAccessService gdAccess = new EFSAccessService(storageType, false);
    		returnPage = Page.app;
			returnPage.getParameters().put('u', '/my-settings/external-apps');
    		returnPage.setRedirect(true);
    		try {
                Boolean canProcessRequest = String.isNotBlank(codeArg) && SimpplrContext.Integrations.containsKey(storageType) && !SimpplrContext.Integrations.get(storageType).Batch_Processing__c;
                if(canProcessRequest && IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT.equalsIgnoreCase(storageType) && SimpplrContext.isSharepointUpgraded) {
                    isSharepointConnected(returnPage, gdAccess, codeArg);
                } else if(canProcessRequest) {
                    Boolean status = gdAccess.refreshToken(codeArg);
                    if(!status) {
                        returnPage.getParameters().put('status', 'false');
                    } else if('dropbox'.equalsIgnoreCase(storageType)) {
                        Database.executeBatch(new BatchEFSFolderSync('USER', UserContext.Id, storageType), 1);
                    }
                    returnPage.getParameters().put('alert',prepareMessage('success',  STR_APPS_CONNECTION_SUCCESS_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(storageType))));
		    	} else {
	    			if(SimpplrContext.Integrations.containsKey(storageType) && SimpplrContext.Integrations.get(storageType).Batch_Processing__c) {
	    				returnPage.getParameters().put('alert',prepareMessage('danger', STR_BATCH_PROCESSING_TRY_LATER));
	    			} else if(!errorArg.equalsIgnoreCase(EFSConstants.userCancelledAuthMsg)) {
						if('dropbox'.equalsIgnoreCase(storageType) ){
							returnPage.getParameters().put('alert',prepareMessage('danger', errorArg));
						}	
	    			}
		    	}
    		} catch(Exception ex) {
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    		}
            gdAccess.close();
            
    	} else if ('dropboxadmin'.equalsIgnoreCase(storageType) || 
    			  'onedriveadmin'.equalsIgnoreCase(storageType) ||
    			  'sharepointadmin'.equalsIgnoreCase(storageType)) { 
    		// 08MAY17 - Changes added for Google Drive Integration
    		String storageStr = storageType.replace('admin','');
    		EFSAccessService efsAccess = new EFSAccessService(storageStr, true);
    		try {
		    	if(String.isNotBlank(codeArg) && (!SimpplrContext.Integrations.containsKey(storageStr) || (SimpplrContext.Integrations.containsKey(storageStr) 
		    			&& !SimpplrContext.Integrations.get(storageStr).Batch_Processing__c))) {
			    	Boolean status = efsAccess.refreshToken(codeArg);
					efsAccess.close();
			    	returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
			    	if(!status) {
			    		returnPage.getParameters().put('status', 'false');
			    	} else if('dropboxadmin'.equalsIgnoreCase(storageType)) {
						Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('SETMOUNTFLAG'), 5000);
			    	}
			    	returnPage.getParameters().put('alert',prepareMessage('success',  STR_APPS_CONNECTION_SUCCESS_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(storageStr))));
	    			returnPage.setRedirect(true);
		    	} else {
		    		returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
    				returnPage.setRedirect(true);
	    			if(SimpplrContext.connectedStorages.contains(storageStr)!=null && SimpplrContext.Integrations.get(storageStr).Batch_Processing__c) {
	    				returnPage.getParameters().put('alert',prepareMessage('danger', STR_BATCH_PROCESSING_TRY_LATER));
	    			} else if(!errorArg.equalsIgnoreCase(EFSConstants.userCancelledAuthMsg)) {
	    				returnPage.getParameters().put('alert',prepareMessage('danger', errorArg));	
	    			}
		    	}
    		} catch(Exception ex) {
    			returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
    			returnPage.setRedirect(true);
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    			returnPage.getParameters().put('Args',JSON.serialize(SimpplrContext.integrations.get(storageType)));
    		}
    	} else if('adsi'.equalsIgnoreCase(storageType)) {
    		try {
    			IntegrationService adIS = new IntegrationService('adsi', null);
	    		adIS.retrieveIntegrator();
	    		adIS.exchangeCode(codeArg, true);
	    		adIS.saveToken();
	    		adIS.close();
	    		returnPage = Page.ManageApplicationIntegrations;//To be changed
	    		returnPage.getParameters().put('status', 'true');
    		} catch (Exception ex) {
    			returnPage = Page.ManageApplicationIntegrations;//To be changed
    			returnPage.setRedirect(true);
    			returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    			returnPage.getParameters().put('Args',JSON.serialize(SimpplrContext.integrations.get(storageType)));    		
            }
            
    	} else if ('googledriveadmin'.equalsIgnoreCase(storageType)) {
			returnPage = new Pagereference(PageContext.getPageURL(Pages.app) + '?u=/manage/app/integrations/files');
			returnPage.setRedirect(true);
            try {
				if(String.isNotBlank(errorCodeArg)) {
					String errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'apps.connection.google.' + errorCodeArg);
					returnPage.getParameters().put('alert', prepareMessage('danger', errorMessage));

				} else if(String.isNotBlank(errorArg)) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_APPS_CONNECTION_ERROR_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(storageType.toLowercase()))));

				} else {
					Map<String,String> params = System.currentPageReference().getParameters();
					String isGoogleDriveConnected = params.get('isConnected');
					String gUserId =  params.get('gUserId');
					String gUserName =  params.get('gUserName');
					String gUserEmail = params.get('gUserEmail');
					String gUserDomain = params.get('gUserDomain');
					String allCompanyGrpId = params.get('allCompanyGroupId');
					String isSuccess = params.get('isSuccess');

					if (Boolean.valueOf(isGoogleDriveConnected)) {
						// Create app config record 
						GoogleDriveHelper googleDriveHelperObj = new GoogleDriveHelper();
						Boolean appConfigRecordCreated = googleDriveHelperObj.upsertAppIntegrationRecord(gUserId, gUserName,
								gUserEmail, gUserDomain, allCompanyGrpId);
						returnPage.getParameters().put('alert',prepareMessage('success',  
								STR_APPS_CONNECTION_SUCCESS_LABEL.replace('{{appName}}', 
								EFSConstants.storageCamelCaseMap.get('googledrive'))));
					} else {
						returnPage.getParameters().put('alert',prepareMessage('danger',  STR_APPS_CONNECTION_ERROR_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(storageType.toLowercase()))));
					}
				}

            } catch(Exception ex) {
				returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    		}
            
        } else if ('googledrive'.equalsIgnoreCase(storageType)) {
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
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_APPS_CONNECTION_ERROR_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(storageType.toLowercase()))));


				} else if(SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE) == null) {
					returnPage.getParameters().put('alert',prepareMessage('danger',  STR_APPS_CONNECTION_ERROR_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(storageType.toLowercase()))));

				} else {
					String isGoogleDriveConnected = readParam('isConnected');
					String gUserId = readParam('gUserId');
					String gUserName =  readParam('gUserName');
					String gUserEmail = readParam('gUserEmail');
					String myDriveId = readParam('myDriveId');
					String domain = readParam('gUserDomain');
					if (Boolean.valueOf(isGoogleDriveConnected)) {
						// Create People Integration record 
						GoogleDriveHelper googleDriveHelperObj = new GoogleDriveHelper();
						Boolean peopleIntegrationRecordCreated = googleDriveHelperObj.createPeopleIntegrationRecord(gUserId, gUserName,
								gUserEmail, myDriveId, domain);
						returnPage.getParameters().put('alert',prepareMessage('success',  
								STR_APPS_CONNECTION_SUCCESS_LABEL.replace('{{appName}}', 
								EFSConstants.storageCamelCaseMap.get('googledrive'))));
					} else {
						returnPage.getParameters().put('alert',prepareMessage('danger',  STR_APPS_CONNECTION_ERROR_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(storageType.toLowercase()))));
					}
				}

            } catch(Exception ex) {
				returnPage.getParameters().put('alert',prepareMessage('danger',  ex.getMessage()));
    		}
            
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
		Set<String> googleIntegrationType = new Set<String> {IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE};
		sqlParamMap.put('soqlParam1', googleIntegrationType);
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegObj = ((List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap));
		String userDomain = !appIntegObj.isEmpty() ? appIntegObj[0].User_Email__c.split('@').get(1) : '';
		return userDomain;
	}
    
    private String prepareMessage(String type, String message) {
    		Map<String, String> messageMap = new Map<String, String>();
    		messageMap.put('type', type);
    		messageMap.put('message', message);
    		return JSON.serialize(messageMap);
    }

    private void isSharepointConnected(PageReference returnPage, EFSAccessService efsAccess, String codeArg) {
        Boolean isSharepointConnected = efsAccess.isSharepointConnected(codeArg);
        String messageType = isSharepointConnected ? 'success' : 'danger';
        String messageBody = isSharepointConnected ? STR_APPS_CONNECTION_SUCCESS_LABEL.replace('{{appName}}', EFSConstants.storageCamelCaseMap.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING)) : STR_SHAREPOINT_CONNECTION_ERROR;
        returnPage.getParameters().put('alert', prepareMessage(messageType, messageBody));
        if(!isSharepointConnected) {
            returnPage.getParameters().put('status', 'false');
        }
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