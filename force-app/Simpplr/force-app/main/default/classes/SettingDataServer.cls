/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class SettingDataServer extends DataServer{  	
	
	private final String ACTION_VALUE_GET_GEN_SETUP = 'getGeneralSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_GOVERNANCE_SETUP = 'getGovernanceSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_GET_NAVIGATION_SETUP ='getNavigationSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_FEED_DEFAULT = 'getDefaultFeedSettings'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_PRIVILEGES_SETUP = 'getPrivilegesConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_TROUBLESHOOTING_CONFIG = 'getTroubleshootingConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_EMAIL_SETUP = 'getEmailSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_MOBILE_APP = 'getMobileAppConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_CONNECT_APP = 'connectApp'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_EMAILNOTIFICATIONS = 'getEmailNotificationsSettings'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_DEFAULT_SMS_NOTIFICATIONS = 'getSMSNotificationsSettings'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_NATIVE_MOBILE_APP_NOTIFICATIONS = 'getNativeMobileAppNotificationsSettings'; // NOPMD - correct naming convension, suppressed codacy error

	private final String ACTION_VALUE_GET_USER_SYNCING_PEOPLE = 'getUserSyncingPeopleConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_PEOPLE_CATEGORY_CONFIG = 'getCategoryPeopleConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_GET_LICENSING_PEOPLE = 'getLicensingPeopleConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_PROFILE_FIELDS_PEOPLE = 'getProfileFieldsPeopleConfig'; // NOPMD - correct naming convension, suppressed codacy error

    private final String ACTION_VALUE_SAVE_GEN_SETUP = 'saveGeneralSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_GOVERNANCE_SETUP = 'saveGovernanceSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error 
    private final String ACTION_VALUE_SAVE_NAVIGATION_SETUP = 'saveNavigationSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_EMAIL_SETUP = 'saveEmailSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_PEOPLE_CATEGORY_CONFIG = 'saveCategoryPeopleConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_USER_SYNCING_PEOPLE = 'saveUserSyncingPeopleConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_PROFILE_FIELDS_PEOPLE = 'saveProfileFieldsPeopleConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_TROUBLESHOOTING = 'saveTroubleshootingConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_MOBILE_APP = 'saveMobileAppConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_PRIVILEGES = 'savePrivilegesConfig'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_DISCONNECT_DB_ADMIN = 'disconnectDropboxAdmin'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_DISCONNECT_SERVICENOW_ADMIN = 'disconnectServicenowAdmin'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_DISCONNECT_ATLASSIAN_ADMIN = 'disconnectAtlassianAdmin'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_DISCONNECT_APP = 'disconnectApp'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_EMAILNOTIFICATIONS = 'saveEmailNotificationsSettings'; // NOPMD - correct naming convension, suppressed codacy error
    
    private final String ACTION_VALUE_SAVE_FEED = 'saveDefaultFeedSettings'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_LICENSING_PEOPLE = 'saveLicensingPeopleConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_DEFAULT_SMS_NOTIFICATIONS = 'saveSMSNotificationsSettings'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_NATIVE_MOBILE_APP_NOTIFICATIONS = 'saveNativeMobileAppNotificationsSettings'; // NOPMD - correct naming convension, suppressed codacy error

	private final String ACTION_VALUE_GET_ANALYTICS_EMBED_CONFIG = 'getAnalyticsEmbedsIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_FILES_INTEGRATION_CONFIG = 'getFilesIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_MESSAGING_CONFIG = 'getMessagingIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_PEOPLE_INTEGRATION_CONFIG = 'getPeopleIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_SEARCH_INTEGRATION_CONFIG = 'getSearchIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_SSO_INTEGRATION_CONFIG = 'getSsoIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_SUPPORT_INTEGRATION_CONFIG = 'getSupportIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_CAMPAIGN_CONFIG = 'getCampaignsIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_CALENDAR_CONFIG = 'getCalendarIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_LISTENER_SUITE_CONFIG = 'getListenerSuiteSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_RECOGNITION_CONFIG = 'getRecognitionSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_GET_DOMAINS_INTEGRATION_CONFIG = 'getDomainsIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error

	private final String ACTION_VALUE_SAVE_ANALYTICS_EMBED_CONFIG = 'saveAnalyticsEmbedsIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_FILES_INTEGRATION_CONFIG = 'saveFilesIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_MESSAGING_CONFIG = 'saveMessagingIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_PEOPLE_INTEGRATION_CONFIG = 'savePeopleIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_SEARCH_INTEGRATION_CONFIG = 'saveSearchIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_SSO_INTEGRATION_CONFIG = 'saveSsoIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_SUPPORT_INTEGRATION_CONFIG = 'saveSupportIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_CAMPAIGN_CONFIG = 'saveCampaignsIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_CALENDAR_CONFIG = 'saveCalendarIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_LISTENER_SUITE_CONFIG = 'saveListenerSuiteSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_RECOGNITION_CONFIG = 'saveRecognitionSetupConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_DOMAIN_INTEGRATION_CONFIG = 'saveDomainsIntegrationsConfig'; // NOPMD - correct naming convension, suppressed codacy error

	private final String ACTION_VALUE_GET_BROWSERNOTIFICATIONS = 'getBrowserNotificationsSettings'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_BROWSERNOTIFICATIONS = 'saveBrowserNotificationsSettings'; // NOPMD - correct naming convension, suppressed codacy error
    private final String REQUEST_PARAM_DATA = 'data'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_GET_SUMMARIES_AND_DIGEST_SETTING = 'getSummariesAndDigestSettings'; // NOPMD - correct naming convension, suppressed codacy error
    private final String ACTION_VALUE_SAVE_SUMMARIES_AND_DIGEST_SETTING = 'saveSummariesAndDigestSettings'; // NOPMD - correct naming convension, suppressed codacy error

	public transient final String STR_PRIV_PS_LABEL { get { return labelMap.get('field.people_search.label');}}
	public transient final String STR_PRIV_SS_PLACEHOLDER { get { return labelMap.get('sites.search.placeholder');}}
	public transient final String STR_UNABLE_TO_LOCK_ROW_ERROR {get { return labelMap.get('manage_app.unable_to_lock_row_error_message') ;}}

	private final String ACTION_VALUE_GET_USER_PROVISIONING = 'getUserProvisioningConfig'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_SAVE_USER_PROVISIONING = 'saveUserProvisioningConfig'; // NOPMD - correct naming convension, suppressed codacy error

	private final String ACTION_VALUE_GET_UKG_USER_FIELD_CONFIG = 'getUKGUserFieldConfig'; // NOPMD - correct naming convension, suppressed codacy error

	private final String ACTION_VALUE_ENABLE_FEATURE = 'enableFeature'; // NOPMD - correct naming convension, suppressed codacy error
	private final String ACTION_VALUE_DISABLE_FEATURE = 'disableFeature'; // NOPMD - correct naming convension, suppressed codacy error

	private final String ACTION_VALUE_GET_GOOGLE_MULTI_DOMAIN_CONFIG = 'getGoogleMultiDomainConfig'; 

	private final String ACTION_START_GOOGLE_MULTI_INSTANCE_UPGRADE_FLOW = 'startGoogleMultiInstanceUpgradeFlow';

	private final String ACTION_START_SLACK_UPGRADE_FLOW = 'startSlackUpgradeFlow'; // NOPMD - correct naming convension, suppressed codacy

	private final String ACTION_DISABLE_SLACK_WHEN_APP_REMOVED_FROM_WORKSPACE = 'disableSlackWhenAppRemovedFromWorkspace'; // NOPMD - correct naming convension, suppressed codacy

	public final String STR_FIELD_USED_WARN_SEGMENT { get { return labelMap.get('manage_app.profile_field_used.warning.segment');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_FIELD_USED_WARN_AUDIENCE { get { return labelMap.get('manage_app.profile_field_used.warning.audience');}} // NOPMD - correct naming convension, suppressed codacy error

	public final String STR_DIVISION { get { return labelMap.get('profile_fields.division');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_DEPARTMENT { get { return labelMap.get('profile_fields.department');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_COMPANY { get { return labelMap.get('profile_fields.company');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_COUNTRY { get { return labelMap.get('profile_fields.country');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_CITY { get { return labelMap.get('profile_fields.city');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_STATE { get { return labelMap.get('profile_fields.state');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_PEOPLE_CATEGORY { get { return labelMap.get('profile_fields.category');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_PEOPLE_HIRE_DATE { get { return labelMap.get('profile_fields.hire_date');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_TITLE { get { return labelMap.get('profile_fields.title');}} // NOPMD - correct naming convension, suppressed codacy error
	
	public final String STR_ERROR_UKGPRO { get { return labelMap.get('profile_fields.syncing.ukgpro.api_error_flash');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_UKGPRO_USERNAME { get { return labelMap.get('manage_app.integrations.people.ukgpro.username.label');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_UKGPRO_PASSWORD { get { return labelMap.get('manage_app.integrations.people.ukgpro.password.label');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_UKGPRO_APIKEY { get { return labelMap.get('manage_app.integrations.people.ukgpro.api_key.label');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String STR_UKGPRO_BASE_URL { get { return labelMap.get('manage_app.integrations.people.ukgpro.base_url.label');}} // NOPMD - correct naming convension, suppressed codacy error
	public final String ERROR_SLACK_UPGRADE = 'manage_app.integration.slack.slack_upgrade.error'; // NOPMD - correct naming convension, suppressed codacy error;

	/*
	String STR_15 { get { return labelMap.get('manage_app.integration.social_campaign.client_id_secret.flash_warning');}}
	String STR_16 { get { return labelMap.get('manage_app.integration.social_campaign.network_config.flash_warning');}}
	String STR_17 { get { return labelMap.get('manage_app.people.syncing.add.duplicate_error_flash');}}
	String STR_18 { get { return labelMap.get('manage_app.people.provisioning.save.processing_error_flash');}}
	String STR_19 { get { return labelMap.get('manage_app.people.syncing.save.processing_error_flash');}}
	*/

	private static final String AUTH_INTEGRATION_GOOGLE_USER_SYNC_ENDPOINT = 'https://accounts.google.com/o/oauth2/auth';
	private static final String AUTH_INTEGRATION_TYPE_SALESFORCE_ENDPOINT = 'https://' + (SimpplrContext.isSandbox == true ? 'test' : 'login') + '.salesforce.com/services/oauth2/authorize';
    
    /**
     *
     */
    public SettingDataServer() {
			featureFlagList = new List<String> {
				'ad_groups_v2',
				'zu_odin_manageapp_campaign'
			};
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest() {
        try{
        	logger.logDebug('SettingDataServer----entered handleRequest----');

			String action = readParam(REQUEST_PARAM_ACTION);
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if(ACTION_VALUE_GET_GEN_SETUP.equalsIgnoreCase(action)) {
				response = getGeneralSetupConfig();

			} else if(ACTION_VALUE_GET_GOVERNANCE_SETUP.equalsIgnoreCase(action)) {
				response = getGovernanceSetupConfig();

			} else if(ACTION_VALUE_GET_NAVIGATION_SETUP.equalsIgnoreCase(action)) {
                response = getNavigationSetupConfig();

			} else if(ACTION_VALUE_GET_PRIVILEGES_SETUP.equalsIgnoreCase(action)) {
				response = getPrivilegesConfig();

			} else if(ACTION_VALUE_GET_TROUBLESHOOTING_CONFIG.equalsIgnoreCase(action)) {
				response = getTroubleshootingConfig();

			} else if(ACTION_VALUE_GET_EMAIL_SETUP.equalsIgnoreCase(action)) {
				response = getEmailSetupConfig();

			} else if(ACTION_VALUE_GET_MOBILE_APP.equalsIgnoreCase(action)) {
				response = getMobileAppConfig();

			} else if(ACTION_VALUE_GET_USER_SYNCING_PEOPLE.equalsIgnoreCase(action)) {
				response = getUserSyncingPeopleConfig();

			} else if (ACTION_VALUE_GET_USER_PROVISIONING.equalsIgnoreCase(action)){
				response = getUserProvisioningConfig();

			} else if(ACTION_VALUE_GET_EMAILNOTIFICATIONS.equalsIgnoreCase(action)) {
				response = getEmailNotificationsSettings();

			} else if(ACTION_VALUE_GET_BROWSERNOTIFICATIONS.equalsIgnoreCase(action)) {
				response = getBrowserNotificationsSettings();

			} else if(ACTION_VALUE_GET_PEOPLE_CATEGORY_CONFIG.equalsIgnoreCase(action)) {
				response = getGeneralPeopleConfig();

            } else if(ACTION_VALUE_GET_FEED_DEFAULT.equalsIgnoreCase(action)) {
                response = getDefaultFeedSettings();
            
            } else if(ACTION_VALUE_GET_LICENSING_PEOPLE.equalsIgnoreCase(action)) {
               response = getLicensingPeopleConfig();

			} else if(ACTION_VALUE_GET_PROFILE_FIELDS_PEOPLE.equalsIgnoreCase(action)) {
				response = getProfileFieldsPeopleConfig();

            } else if(ACTION_VALUE_GET_LISTENER_SUITE_CONFIG.equalsIgnoreCase(action)) {
                response = getListenerSuiteSetupConfig();

            } else if(ACTION_VALUE_GET_RECOGNITION_CONFIG.equalsIgnoreCase(action)) {
                response = getRecognitionSetupConfig();

            } else if(ACTION_VALUE_SAVE_GEN_SETUP.equalsIgnoreCase(action)) {
                response = saveGeneralSetupConfig(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_VALUE_SAVE_GOVERNANCE_SETUP.equalsIgnoreCase(action)) {
                response = saveGovernanceSetupConfig(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_VALUE_SAVE_NAVIGATION_SETUP.equalsIgnoreCase(action)) {
                response = saveNavigationSetupConfig(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_VALUE_SAVE_EMAIL_SETUP.equalsIgnoreCase(action)) {
                response = saveEmailSetupConfig(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_VALUE_SAVE_PEOPLE_CATEGORY_CONFIG.equalsIgnoreCase(action)) {
                response = saveGeneralPeopleConfig(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_VALUE_SAVE_USER_SYNCING_PEOPLE.equalsIgnoreCase(action)) {
                response = saveUserSyncingPeopleConfig(readParam(REQUEST_PARAM_DATA));
                
			} else if(ACTION_VALUE_SAVE_USER_PROVISIONING.equalsIgnoreCase(action)){
				response = saveUserProvisioningConfig(readParam(REQUEST_PARAM_DATA));

			} else if(ACTION_VALUE_SAVE_PROFILE_FIELDS_PEOPLE.equalsIgnoreCase(action)) {
                response = saveProfileFieldsPeopleConfig(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_VALUE_SAVE_TROUBLESHOOTING.equalsIgnoreCase(action)){
            	response = saveTroubleshootingConfig(readParam(REQUEST_PARAM_DATA));
            	
            } else if(ACTION_VALUE_SAVE_MOBILE_APP.equalsIgnoreCase(action)){
            	response = saveMobileAppConfig(readParam(REQUEST_PARAM_DATA));
            	
            } else if(ACTION_VALUE_SAVE_PRIVILEGES.equalsIgnoreCase(action)){
            	response = savePrivilegesConfig(readParam(REQUEST_PARAM_DATA));

			} else if(ACTION_VALUE_SAVE_LICENSING_PEOPLE.equalsIgnoreCase(action)) {
					response = saveLicensingPeopleConfig(readParam(REQUEST_PARAM_DATA));
					
			}else if( ACTION_VALUE_DISCONNECT_DB_ADMIN.equalsIgnoreCase(action) ){   
				response = disconnectEFSAdmin(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING); 
		
			} else if(ACTION_VALUE_DISCONNECT_SERVICENOW_ADMIN.equalsIgnoreCase(action)) {
            	response = disconnectServicenowAdmin();     

            } else if(ACTION_VALUE_DISCONNECT_ATLASSIAN_ADMIN.equalsIgnoreCase(action)) {
            	response = disconnectAtlassianAdmin();     

            } else if(ACTION_VALUE_SAVE_EMAILNOTIFICATIONS.equalsIgnoreCase(action)){
            	response = saveEmailNotificationsSettings(readParam(REQUEST_PARAM_DATA));

            } else if(ACTION_VALUE_SAVE_BROWSERNOTIFICATIONS.equalsIgnoreCase(action)){
            	response = saveBrowserNotificationsSettings(readParam(REQUEST_PARAM_DATA));

            } else if(ACTION_VALUE_SAVE_FEED.equalsIgnoreCase(action)){
            	response = saveDefaultFeedSettings(readParam(REQUEST_PARAM_DATA));

            } else if(ACTION_VALUE_DISCONNECT_APP.equalsIgnoreCase(action)){
            	response = disconnectApp(readParam(REQUEST_PARAM_DATA));

			} else if(ACTION_VALUE_GET_ANALYTICS_EMBED_CONFIG.equalsIgnoreCase(action)) {
				response = getAnalyticsEmbedsIntegrationsConfig();

			} else if(ACTION_VALUE_GET_FILES_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
				response = getFilesIntegrationsConfig();

			} else if(ACTION_VALUE_GET_DOMAINS_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
				response = getDomainsIntegrationsConfig();

			} else if(ACTION_VALUE_GET_MESSAGING_CONFIG.equalsIgnoreCase(action)) {
				response = getMessagingIntegrationsConfig();

			} else if(ACTION_VALUE_GET_PEOPLE_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
				response = getPeopleIntegrationsConfig();

			} else if(ACTION_VALUE_GET_SEARCH_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
				response = getSearchIntegrationsConfig();

			} else if(ACTION_VALUE_GET_SSO_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
				response = getSsoIntegrationsConfig();

			} else if(ACTION_VALUE_GET_SUPPORT_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
				response = getSupportIntegrationsConfig();

			} else if(ACTION_VALUE_GET_CAMPAIGN_CONFIG.equalsIgnoreCase(action)) {
				response = getCampaignsIntegrationsConfig();
				
			} else if(ACTION_VALUE_GET_CALENDAR_CONFIG.equalsIgnoreCase(action)) {
				response = getCalendarIntegrationsConfig();

			} else if(ACTION_VALUE_GET_DEFAULT_SMS_NOTIFICATIONS.equalsIgnoreCase(action)) {
				response = getSMSNotificationsSettings();
				
			} else if(ACTION_VALUE_GET_NATIVE_MOBILE_APP_NOTIFICATIONS.equalsIgnoreCase(action)) {
				response = getNativeMobileAppNotificationsSettings();
				
			} else if(ACTION_VALUE_SAVE_DEFAULT_SMS_NOTIFICATIONS.equalsIgnoreCase(action)) {
				response = saveSMSNotificationsSettings(readParam(REQUEST_PARAM_DATA));
				
			} else if(ACTION_VALUE_SAVE_NATIVE_MOBILE_APP_NOTIFICATIONS.equalsIgnoreCase(action)) {
				response = saveNativeMobileAppNotificationsSettings(readParam(REQUEST_PARAM_DATA));
				
			} else if(ACTION_VALUE_SAVE_ANALYTICS_EMBED_CONFIG.equalsIgnoreCase(action)) {
                response = saveAnalyticsEmbedsIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

			}else if(ACTION_VALUE_SAVE_FILES_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
                response = saveFilesIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

			}else if(ACTION_VALUE_SAVE_MESSAGING_CONFIG.equalsIgnoreCase(action)) {
                response = saveMessagingIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

			}else if(ACTION_VALUE_SAVE_PEOPLE_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
                response = savePeopleIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

			}else if(ACTION_VALUE_SAVE_SEARCH_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
				response = saveSearchIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

			}else if(ACTION_VALUE_SAVE_SSO_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
                response = saveSsoIntegrationsConfig(readParam(REQUEST_PARAM_DATA));
			
			}else if(ACTION_VALUE_SAVE_SUPPORT_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
                response = saveSupportIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

			}else if(ACTION_VALUE_SAVE_CAMPAIGN_CONFIG.equalsIgnoreCase(action)) {
                response = saveCampaignsIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

		    } else if(ACTION_VALUE_SAVE_CALENDAR_CONFIG.equalsIgnoreCase(action)) {
                	response = saveCalendarIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

			} else if (ACTION_VALUE_SAVE_DOMAIN_INTEGRATION_CONFIG.equalsIgnoreCase(action)) {
				response = saveDomainsIntegrationsConfig(readParam(REQUEST_PARAM_DATA));

			} else if(ACTION_VALUE_SAVE_LISTENER_SUITE_CONFIG.equalsIgnoreCase(action)) {
                response = saveListenerSuiteSetupConfig(readParam(REQUEST_PARAM_DATA));

            } else if(ACTION_VALUE_SAVE_RECOGNITION_CONFIG.equalsIgnoreCase(action)) {
                response = saveRecognitionSetupConfig(readParam(REQUEST_PARAM_DATA));

            } else if(ACTION_VALUE_CONNECT_APP.equalsIgnoreCase(action)) {
                response = connectApp(readParam(REQUEST_PARAM_DATA));

            } else if (ACTION_VALUE_GET_SUMMARIES_AND_DIGEST_SETTING.equalsIgnoreCase(action)) {
                response = getSummariesAndDigestSettings();
            
            } else if (ACTION_VALUE_SAVE_SUMMARIES_AND_DIGEST_SETTING.equalsIgnoreCase(action)){
                response = saveSummariesAndDigestSettings(readParam(REQUEST_PARAM_DATA));

            } else if (ACTION_VALUE_ENABLE_FEATURE.equalsIgnoreCase(action)){
                response = enableFeature(readParam('name'), readParam('features'));
			
			} else if (ACTION_VALUE_DISABLE_FEATURE.equalsIgnoreCase(action)){
                response = disableFeature(readParam('name'), readParam('features'));
			
			} else if (ACTION_VALUE_GET_UKG_USER_FIELD_CONFIG.equalsIgnoreCase(action)){
				response = getUKGUserFieldConfig();

            } else if (ACTION_VALUE_GET_GOOGLE_MULTI_DOMAIN_CONFIG.equalsIgnoreCase(action)){
				response = getGoogleMultiDomainConfig();

            } else if(ACTION_START_GOOGLE_MULTI_INSTANCE_UPGRADE_FLOW.equalsIgnoreCase(action)){
				response = startGoogleMultiInstanceUpgradeFlow(readParam(REQUEST_PARAM_DATA));
			
			} else if(ACTION_START_SLACK_UPGRADE_FLOW.equalsIgnoreCase(action)){
				response = startSlackUpgradeFlow();
			
			} else if(ACTION_DISABLE_SLACK_WHEN_APP_REMOVED_FROM_WORKSPACE.equalsIgnoreCase(action)){
				response = disableSlackWhenAppRemovedFromWorkspace(readParam(REQUEST_PARAM_DATA));
			
			} else{
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        }catch(Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
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

	private ResponseWrapper getGeneralSetupConfig(){
        logger.logDebug('SettingDataServer.getGeneralSetupConfig()');
		ResponseWrapper responseWrapperObj = null;
        try {
            ManageApplicationWrapper.GeneralSetupWrapper generalSetupObj  = new ManageApplicationDao().fetchAppGeneralSetup();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, generalSetupObj);

		} catch (Exception e) {
			logger.logError('SettingDataServer.getGeneralSetupConfig()----could not get general setup configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null); 			
		}
		return responseWrapperObj;
    }

	private ResponseWrapper getGovernanceSetupConfig(){
        logger.logDebug('SettingDataServer.getGovernanceSetupConfig()');
		ResponseWrapper responseWrapperObj = null;
        try {
            ManageApplicationWrapper.GovernanceSetupWrapper governanceDataObj  = new ManageApplicationDao().getGovernanceData();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, governanceDataObj);

		} catch (Exception e) {
			logger.logError('SettingDataServer.getGovernanceSetupConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null); 			
		}
		return responseWrapperObj;
    }

	 private ResponseWrapper getNavigationSetupConfig(){
		logger.logDebug('SettingDataServer.getNavigationSetupConfig()');
        ResponseWrapper responseWrapperObj;

		try {
        ManageApplicationWrapper.NavigationSetupWrapper navigationSetupWrapObj = new ManageApplicationDao().getNavigationDetails();
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, navigationSetupWrapObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getNavigationSetupConfig()----could not get Navigation setup configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 			
		}
		return responseWrapperObj;
	 }

	 private ResponseWrapper getDefaultFeedSettings(){
		logger.logDebug('SettingDataServer.getDefaultFeedSettings()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.DefaultFeedSettingsWrapper defaultFeedObj = new ManageApplicationDao().getDefaultFeedSettings();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, defaultFeedObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getDefaultFeedSettings()----could not get default feed configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }

		return responseWrapperObj;
    }

	private ResponseWrapper getGeneralPeopleConfig(){
		logger.logDebug('SettingDataServer.getGeneralPeopleConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.GeneralPeopleWrapper generalPeopleWrapObj = new ManageApplicationDao().getGeneralPeopleConfig();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, generalPeopleWrapObj);

		} catch (Exception e) {
        	logger.logError('SettingDataServer.getGeneralPeopleConfig()----could not get general people configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper getAnalyticsEmbedsIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getAnalyticsEmbedsIntegrationsConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.AnalyticsEmbedsIntegrationsWrapper WrapperObj = new ManageApplicationDao().getAnalyticsEmbedsIntegrationsConfig();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, WrapperObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getAnalyticsEmbedsIntegrationsConfig()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper getFilesIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getFilesIntegrationsConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.FilesIntegrationWrapper WrapperObj = new ManageApplicationDao().getFilesIntegrationsConfig();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, WrapperObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getFilesIntegrationsConfig()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper getDomainsIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getDomainsIntegrationsConfig()');
		ResponseWrapper responseWrapperObj = null;
		try {
			ManageApplicationWrapper.DomainsIntegrationResWrapper WrapperObj = new ManageApplicationDao().getDomainsIntegrationsConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, WrapperObj);

		} catch (Exception e) {
			logger.logError('SettingDataServer.getDomainsIntegrationsConfig()----Exception Occured',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
		}
		return responseWrapperObj;
	}

	@TestVisible
	private ResponseWrapper getMessagingIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getMessagingIntegrationsConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
			ManageApplicationDao maDaoObj = new ManageApplicationDao();
			Boolean isSlackUnfurlAppInstalled;
            if(!(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded)) {
                isSlackUnfurlAppInstalled = maDaoObj.getSlackAppInstalledInfo(SimpplrContext.simpplrOrgId);
            }
            ManageApplicationWrapper.MessagingIntegrationWrapper WrapperObj = maDaoObj.getMessagingIntegrationsConfig(isSlackUnfurlAppInstalled);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, WrapperObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getMessagingIntegrationsConfig()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper getPeopleIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getPeopleIntegrationsConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.PeopleIntegrationsWrapper WrapperObj = new ManageApplicationDao().getPeopleIntegrationsConfig();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, WrapperObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getPeopleIntegrationsConfig()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper getSearchIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getSearchIntegrationsConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
			Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration> enterpriseSearchIntMap = new ManageApplicationDao().getSearchIntegrationsConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, enterpriseSearchIntMap);
			
		}catch (Exception e) {
        	logger.logError('SettingDataServer.getSearchIntegrationsConfig()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper getSsoIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getSsoIntegrationsConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
			if(!UserContext.isUserAppModerator && !UserContext.hasModifyAllDataPermission) {
				throw new SimpplrException(ExceptionCode.NO_ACCESS.name());
			}
            ManageApplicationWrapper.SingleSignOnIntegrationsWrapper WrapperObj = new ManageApplicationDao().getSsoIntegrationsConfig();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, WrapperObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getSsoIntegrationsConfig()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper getSupportIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getSupportIntegrationsConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
			ManageApplicationWrapper.SupportIntegrationWrapper integrationWrapperObj = new ManageApplicationWrapper.SupportIntegrationWrapper();
			ServiceNowIntegrationService snIntegServiceObj = new ServiceNowIntegrationService();
			AtlassianService atlassianIntegServiceObj = new AtlassianService();
			ServiceNowWrapper.SNWrapper serviceNowWapperObj = snIntegServiceObj.getSupportIntegrationsConfig();
			AtlassianWrapper atlassianWrapperObj = atlassianIntegServiceObj.getSupportIntegrationsConfig();
			integrationWrapperObj.atlassian = atlassianWrapperObj;
			integrationWrapperObj.serviceNow = serviceNowWapperObj;
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, integrationWrapperObj);
		}catch (Exception e) {
        	logger.logError('SettingDataServer.getSupportIntegrationsConfig()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper getCampaignsIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getCampaignsIntegrationsConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.CampaignsIntegrationsWrapper WrapperObj = new ManageApplicationDao().getCampaignsIntegrationsConfig();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, WrapperObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getCampaignsIntegrationsConfig()----Exception Occured',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
	}
	
	private ResponseWrapper getCalendarIntegrationsConfig(){
		logger.logDebug('SettingDataServer.getCalendarIntegrationsConfig()');
        	ResponseWrapper responseWrapperObj = null;

		try {
            	   ManageApplicationWrapper.CalendarIntegrationsWrapper WrapperObj = new ManageApplicationDao().getCalendarIntegrationsConfig();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, WrapperObj);

		}catch (Exception e) {
        		logger.logError('SettingDataServer.getCalendarIntegrationsConfig()----Exception Occured',e);
               	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private ResponseWrapper enableFeature(String name, String features) {
		logger.logDebug('SettingDataServer.enableFeature()');
        ResponseWrapper responseWrapperObj = null;

		try {
			if('AI'.equalsIgnoreCase(name)){
				enableAIFeatures(features);	
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			} else {
				throw new SimpplrException('Unknown Parameter');
			}

		} catch (Exception e) {
			logger.logError('SettingDataServer.enableFeature()----Exception Occured',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private void enableAIFeatures(String features) {
		logger.logDebug('SettingDataServer.enableAIFeatures()');

		String appFeatureQuery = 'Select Id, AI_Topic_Suggestion_Enabled__c, AI_Related_Content_Enabled__c From App_Feature__c Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Feature__c> appFeatureList = (List<App_Feature__c>)SIMPESAPI.accessController().queryAsUser(appFeatureQuery, null);
		
		if(appFeatureList.size() > 0) {
			appFeatureList[0].AI_Topic_Suggestion_Enabled__c = features.containsIgnoreCase('AI_Topic_Suggestions') ? true : appFeatureList[0].AI_Topic_Suggestion_Enabled__c;
			appFeatureList[0].AI_Related_Content_Enabled__c = features.containsIgnoreCase('AI_Related_Content') ? true : appFeatureList[0].AI_Related_Content_Enabled__c;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(appFeatureList[0], 
					new List<Schema.SObjectField>{
						App_Feature__c.AI_Topic_Suggestion_Enabled__c,
						App_Feature__c.AI_Related_Content_Enabled__c
			});
		} else {
			App_Feature__c appFeatureObj = new App_Feature__c();
			appFeatureObj.AI_Topic_Suggestion_Enabled__c = features.containsIgnoreCase('AI_Topic_Suggestions') ? true : false;
			appFeatureObj.AI_Related_Content_Enabled__c = features.containsIgnoreCase('AI_Related_Content') ? true : false;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(appFeatureObj, 
					new List<Schema.SObjectField>{
						App_Feature__c.AI_Topic_Suggestion_Enabled__c,
						App_Feature__c.AI_Related_Content_Enabled__c
			});
		}

		if(features.containsIgnoreCase('AI_Related_Content')){
			BatchPushContentDataForAI job = new BatchPushContentDataForAI();
			Database.executeBatch(job,20);
		}
    }

	private ResponseWrapper disableFeature(String name, String features) {
		logger.logDebug('SettingDataServer.disableFeature()');
        ResponseWrapper responseWrapperObj = null;

		try {
			if('AI'.equalsIgnoreCase(name)){
				disableAIFeatures(features);	
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			}else if('NewsletterPlus'.equalsIgnoreCase(name)){
				disableNewsletterFeature();	
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			} else {
				throw new SimpplrException('Unknown Parameter');
			}

		} catch (Exception e) {
			logger.logError('SettingDataServer.disableFeature()----Exception Occured',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

	private void disableAIFeatures(String features) {
		logger.logDebug('SettingDataServer.disableAIFeatures()');

		String appFeatureQuery = 'Select Id, AI_Topic_Suggestion_Enabled__c, AI_Related_Content_Enabled__c From App_Feature__c Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Feature__c> appFeatureList = (List<App_Feature__c>)SIMPESAPI.accessController().queryAsUser(appFeatureQuery, null);
		
		if(appFeatureList.size() > 0) {
			appFeatureList[0].AI_Topic_Suggestion_Enabled__c = features.containsIgnoreCase('AI_Topic_Suggestions') ? false : appFeatureList[0].AI_Topic_Suggestion_Enabled__c;
			appFeatureList[0].AI_Related_Content_Enabled__c = features.containsIgnoreCase('AI_Related_Content') ? false : appFeatureList[0].AI_Related_Content_Enabled__c;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(appFeatureList[0], 
					new List<Schema.SObjectField>{
						App_Feature__c.AI_Topic_Suggestion_Enabled__c,
						App_Feature__c.AI_Related_Content_Enabled__c
			});
		}
    }

	private void disableNewsletterFeature() {
		logger.logDebug('SettingDataServer.disableNewsletterFeature()');

		String appFeatureQuery = 'Select Id, Newsletter_V2_Enabled__c From App_Feature__c Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Feature__c> appFeatureList = (List<App_Feature__c>)SIMPESAPI.accessController().queryAsUser(appFeatureQuery, null);
		
		if(appFeatureList.size() > 0) {
			appFeatureList[0].Newsletter_V2_Enabled__c = false;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(appFeatureList[0], 
					new List<Schema.SObjectField>{
						App_Feature__c.Newsletter_V2_Enabled__c
			});
		}
    }
	
	@TestVisible private ResponseWrapper saveAnalyticsEmbedsIntegrationsConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveAnalyticsEmbedsIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
			ManageApplicationWrapper.AnalyticsEmbedsIntegrationsWrapper analyticsEmbedsWrapperObj =(ManageApplicationWrapper.AnalyticsEmbedsIntegrationsWrapper)Json.deserialize(requestData, ManageApplicationWrapper.AnalyticsEmbedsIntegrationsWrapper.class);
        	ManageApplicationDao daObj = new ManageApplicationDao();
			daObj.saveAnalyticsEmbedsIntegrationsConfig(analyticsEmbedsWrapperObj , FeatureFlagManager.isFeatureEnabled('ga4_integration'));            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, analyticsEmbedsWrapperObj);
        	
        }catch(Exception e){
        	logger.logError('SettingDataServer.saveAnalyticsEmbedsIntegrationsConfig()----Exception Occured----',e);
			String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);
        }
        logger.logDebug('SettingDataServer.saveAnalyticsEmbedsIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@TestVisible private ResponseWrapper saveFilesIntegrationsConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveFilesIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
			ManageApplicationWrapper.FilesIntegrationWrapper integrationObj =(ManageApplicationWrapper.FilesIntegrationWrapper)Json.deserialize(requestData, ManageApplicationWrapper.FilesIntegrationWrapper.class);
            ManageApplicationWrapper.FilesIntegrationWrapper responseIntegrationObj = new ManageApplicationWrapper.FilesIntegrationWrapper();
            if ((SimpplrContext.connectedStorages.contains(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) && SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Batch_Processing__c)) {
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_UNABLE_TO_LOCK_ROW_ERROR, null);        		
            
            } else {
        		ManageApplicationDao madObj = new ManageApplicationDao();
				madObj.saveFilesIntegrationsConfig(integrationObj);
				responseIntegrationObj = madObj.getFilesIntegrationsConfig();
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseIntegrationObj);
        	}
        }catch(Exception e){
        	logger.logError('SettingDataServer.saveFilesIntegrationsConfig()----Exception Occured----',e);
			String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);
        }
        logger.logDebug('SettingDataServer.saveFilesIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@TestVisible private ResponseWrapper saveDomainsIntegrationsConfig(String requestData){
		logger.logDebug('SettingDataServer.saveDomainsIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
		try {
			ManageApplicationWrapper.DomainsIntegrationReqWrapper integrationObj = (ManageApplicationWrapper.DomainsIntegrationReqWrapper) Json.deserialize(requestData, ManageApplicationWrapper.DomainsIntegrationReqWrapper.class);
			ManageApplicationWrapper.DomainsIntegrationResWrapper responseIntegrationObj = new ManageApplicationWrapper.DomainsIntegrationResWrapper();
			
			ManageApplicationDao madObj = new ManageApplicationDao();
			madObj.saveDomainsIntegrationsConfig(integrationObj);
			responseIntegrationObj = madObj.getDomainsIntegrationsConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseIntegrationObj);

		} catch(Exception e){
			String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;
			logger.logError('SettingDataServer.saveDomainsIntegrationsConfig()----Exception Occured----', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);
		}
		logger.logDebug('SettingDataServer.saveDomainsIntegrationsConfig()----responseWrapperObj----' + responseWrapperObj);
		return responseWrapperObj;
	}

	/**
	* @description This method is used for starting the process of Google Multi-Instance Manual Upgrade Flow
	*/
	@TestVisible private ResponseWrapper startGoogleMultiInstanceUpgradeFlow(String requestData) {
		logger.logDebug('SettingDataServer.startGoogleMultiInstanceUpgradeFlow()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
		try {
			ManageApplicationWrapper.GoogleManualUpgradeFlowReqWrapper reqObj = (ManageApplicationWrapper.GoogleManualUpgradeFlowReqWrapper) Json.deserialize(requestData, ManageApplicationWrapper.GoogleManualUpgradeFlowReqWrapper.class);
			
			ManageApplicationDao madObj = new ManageApplicationDao();
			madObj.startGoogleMultiInstanceUpgradeFlow(reqObj);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

		} catch(Exception e) {
			String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;
			logger.logError('SettingDataServer.startGoogleMultiInstanceUpgradeFlow()----Exception Occured----', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);
		}
		logger.logDebug('SettingDataServer.startGoogleMultiInstanceUpgradeFlow()----responseWrapperObj----' + responseWrapperObj);
		return responseWrapperObj;
	}

	@TestVisible private ResponseWrapper saveMessagingIntegrationsConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveMessagingIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
        	ManageApplicationWrapper.MessagingIntegrationWrapper integrationObj =(ManageApplicationWrapper.MessagingIntegrationWrapper)Json.deserialize(requestData, ManageApplicationWrapper.MessagingIntegrationWrapper.class);
        	ManageApplicationDao madObj = new ManageApplicationDao();
			Boolean isSlackUnfurlAppInstalled;
            if(!(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded)) {
                isSlackUnfurlAppInstalled = madObj.getSlackAppInstalledInfo(SimpplrContext.simpplrOrgId);
            }
			madObj.saveMessagingIntegrationsConfig(integrationObj);	  		
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, madObj.getMessagingIntegrationsConfig(isSlackUnfurlAppInstalled));
        }catch(Exception e){
        	logger.logError('SettingDataServer.saveMessagingIntegrationsConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.saveMessagingIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@TestVisible private ResponseWrapper savePeopleIntegrationsConfig(String requestData){
    	logger.logDebug('SettingDataServer.savePeopleIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
					Boolean isADGroupsV2Enabled = FeatureFlagManager.isFeatureEnabled('ad_groups_v2');
			ManageApplicationWrapper.PeopleIntegrationsWrapper peopleIntegrationWrapperObj =(ManageApplicationWrapper.PeopleIntegrationsWrapper)Json.deserialize(requestData, ManageApplicationWrapper.PeopleIntegrationsWrapper.class);
			ManageApplicationWrapper.PeopleIntegrationsWrapper peopleIntegrationWrapRespObj = new ManageApplicationWrapper.PeopleIntegrationsWrapper();
        	ManageApplicationDao daObj = new ManageApplicationDao();
			daObj.savePeopleIntegrationsConfig(peopleIntegrationWrapperObj, isADGroupsV2Enabled);
			peopleIntegrationWrapRespObj = daObj.getPeopleIntegrationsConfig();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleIntegrationWrapRespObj);
        	
        }catch(Exception e){
			String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;
        	logger.logError('SettingDataServer.savePeopleIntegrationsConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);
        }
        logger.logDebug('SettingDataServer.savePeopleIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@TestVisible private ResponseWrapper saveSearchIntegrationsConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveSearchIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{

			responseWrapperObj = saveSearchIntegrationsConfigs(requestData);
        }catch(Exception e){
        	logger.logError('SettingDataServer.saveSearchIntegrationsConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.saveSearchIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	private ResponseWrapper saveSearchIntegrationsConfigs(String requestData){
		ResponseWrapper responseWrapperObj = null;
		try{
			Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration> searchIntegrationsObj = 
						(Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration>) Json.deserialize(requestData, Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration>.class);
				
			ManageApplicationDao daObj = new ManageApplicationDao();
			daObj.saveSearchIntegrationsConfig(searchIntegrationsObj);

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, searchIntegrationsObj);
		}catch(Exception e){
        	logger.logError('SettingDataServer.saveSearchIntegrationsConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
		
		return responseWrapperObj;
	}
	
	@TestVisible private ResponseWrapper saveSsoIntegrationsConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveSsoIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
			ManageApplicationWrapper.SingleSignOnIntegrationsWrapper singleSignOnIntegrationWrapperObj =(ManageApplicationWrapper.SingleSignOnIntegrationsWrapper)Json.deserialize(requestData, ManageApplicationWrapper.SingleSignOnIntegrationsWrapper.class);
        	ManageApplicationWrapper.SingleSignOnIntegrationsWrapper wrapperObj = new ManageApplicationWrapper.SingleSignOnIntegrationsWrapper();
			ManageApplicationDao daObj = new ManageApplicationDao();
			daObj.saveSsoIntegrationsConfig(singleSignOnIntegrationWrapperObj);
			wrapperObj = daObj.getSsoIntegrationsConfig();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);

        	
        }catch(Exception e){
        	logger.logError('SettingDataServer.saveSsoIntegrationsConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.saveSsoIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@TestVisible private ResponseWrapper saveSupportIntegrationsConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveSupportIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
			ManageApplicationWrapper.SupportIntegrationWrapper integrationObj =(ManageApplicationWrapper.SupportIntegrationWrapper)Json.deserialize(requestData, ManageApplicationWrapper.SupportIntegrationWrapper.class);        	
			new ManageApplicationDao().saveSupportIntegrationsConfig(integrationObj);	
			integrationObj.serviceNow.snKeysSaved = integrationObj.serviceNow.snEnabled;
			integrationObj.atlassian.atlassianKeysSaved = integrationObj.atlassian.atlassianEnabled;
			if(integrationObj.serviceNow.snEnabled == false){
				integrationObj.serviceNow = new ServiceNowWrapper.SNWrapper();
				integrationObj.serviceNow.snTicketEnabled = true;
				integrationObj.serviceNow.snTicketCreationEnabled = true;
				integrationObj.serviceNow.snNotificationsEnabled = false;
				integrationObj.serviceNow.snKnowledgebaseEnabled = true;
				integrationObj.serviceNow.snKeysSaved = false;
      			integrationObj.serviceNow.snEnabled = false;
				integrationObj.serviceNow.snConnectedAs = '';
				integrationObj.serviceNow.servicenowInstanceUrl = '';
				integrationObj.serviceNow.isSNTicketsUrlDefaultSelected = true;
				integrationObj.serviceNow.isSNTicketingDefaultSelected = true;
				integrationObj.serviceNow.isSNKnowledgeDefaultSelected = true;
				integrationObj.serviceNow.isSNKnowledgebaseUrlDefaultSelected = true;
				integrationObj.serviceNow.customSNTicketingSystemName = '';
				integrationObj.serviceNow.customSNKnowledgebaseUrl = '';
				integrationObj.serviceNow.customSNKnowledgebaseName = '';
				integrationObj.serviceNow.customServiceNowTicketsUrl = '';
			} else {
				integrationObj.serviceNow.snKeysSaved = true;
				integrationObj.serviceNow.snClientId = null;
				integrationObj.serviceNow.snClientSecret = null;
			}
			if(integrationObj.atlassian.atlassianEnabled  == false){
				integrationObj.atlassian.atlassianKeysSaved  = false;
				integrationObj.atlassian.atlassianConnectedAs = '';
				integrationObj.atlassian.atlassianInstanceUrl = '';
				integrationObj.atlassian.atlassianKeysSaved = false;
				integrationObj.atlassian.confluenceEnabled = false;
				integrationObj.atlassian.confluenceKBWrapperList = new List<AtlassianWrapper.KnowledgeBaseWrapper>();
				integrationObj.atlassian.customConfluenceKnowledgeBaseName = '';
				integrationObj.atlassian.isConfluenceKnowledgeDefaultSelected = true;
				integrationObj.atlassian.isConfluenceKnowledgeSpacesSelected = true;
			} else {
				integrationObj.atlassian.atlassianKeysSaved  = true;
				if(integrationObj.atlassian.isConfluenceKnowledgeSpacesSelected){
					integrationObj.atlassian.confluenceKBWrapperList = new List<AtlassianWrapper.KnowledgeBaseWrapper>();
				}
			}

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, integrationObj);
        }catch(Exception e){
        	logger.logError('SettingDataServer.saveSupportIntegrationsConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.saveSupportIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@TestVisible private ResponseWrapper saveCampaignsIntegrationsConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveCampaignsIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
			ManageApplicationWrapper.CampaignsIntegrationsWrapper campaignsIntegrationObj =(ManageApplicationWrapper.CampaignsIntegrationsWrapper)Json.deserialize(requestData, ManageApplicationWrapper.CampaignsIntegrationsWrapper.class);
        	ManageApplicationDao daObj = new ManageApplicationDao();
			daObj.saveCampaignsIntegrationsConfig(campaignsIntegrationObj);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, campaignsIntegrationObj);
        	
        }catch(Exception e){
        	logger.logError('SettingDataServer.saveCampaignsIntegrationsConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.saveCampaignsIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
	}
	
	@TestVisible private ResponseWrapper saveCalendarIntegrationsConfig(String requestData){
    		logger.logDebug('SettingDataServer.saveCalendarIntegrationsConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
			ManageApplicationWrapper.CalendarIntegrationsWrapper calendarIntegrationObj =(ManageApplicationWrapper.CalendarIntegrationsWrapper)Json.deserialize(requestData, ManageApplicationWrapper.CalendarIntegrationsWrapper.class);
        	ManageApplicationDao daObj = new ManageApplicationDao();
			daObj.saveCalendarIntegrationsConfig(calendarIntegrationObj);
			calendarIntegrationObj.googleCalendarConnectedAs = calendarIntegrationObj.googleCalendar ? calendarIntegrationObj.googleCalendarConnectedAs : null;
			calendarIntegrationObj.outlookCalendarDomainWhitelist = calendarIntegrationObj.outlookCalendarDomainWhitelist;

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, calendarIntegrationObj);
        	
        }catch(Exception e){
        	logger.logError('SettingDataServer.saveCalendarIntegrationsConfig()----Exception Occured----',e);
			String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);
		}
        logger.logDebug('SettingDataServer.saveCalendarIntegrationsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	private ResponseWrapper getPrivilegesConfig() {   
		logger.logDebug('SettingDataServer.getPrivilegesConfig()');
	    ResponseWrapper responseWrapperObj;

	    try {
            ManageApplicationWrapper.PrivilegesSetupWrapper privilegesSetupWrapObj = new ManageApplicationDao().fetchAllPrivileges(STR_PRIV_PS_LABEL, STR_PRIV_SS_PLACEHOLDER,FeatureFlagManager.isFeatureEnabled('zu_odin_manageapp_campaign'));
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, privilegesSetupWrapObj);

		}catch(Exception e){
        	logger.logError('SettingDataServer.getPrivilegesConfig()----could not get Privileges Setup Config', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

		return responseWrapperObj;
	}

	private ResponseWrapper getTroubleshootingConfig() {
		logger.logDebug('SettingDataServer.getTroubleshootingConfig()');
        ResponseWrapper responseWrapperObj = null;
		
        try {
			ManageApplicationWrapper.TroubleshootingWrapper troubleshootingSetupWrapObj = new ManageApplicationDao().getTroubleshootingData();
	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, troubleshootingSetupWrapObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getTroubleshootingConfig()----could not get troubleshooting configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }

		return responseWrapperObj;
	}

	private ResponseWrapper getEmailSetupConfig() {
        logger.logDebug('SettingDataServer.getEmailSetupConfig()');
        ResponseWrapper responseWrapperObj = null;
		try {
            ManageApplicationWrapper.AppConfigEmailWrapper appConfigEmailSetupWrapObj = new ManageApplicationDao().populateAppConfigEmailWrapper();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, appConfigEmailSetupWrapObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getEmailSetupConfig()----could not get email setup configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 		
        }

		return responseWrapperObj;
	}

	private ResponseWrapper getEmailNotificationsSettings(){
		logger.logDebug('SettingDataServer.getEmailNotificationsSettings()');
        ResponseWrapper responseWrapperObj = null;

		try {  
            ManageApplicationWrapper.EmailNotificationWrapper emailNotificationWrapObj = new ManageApplicationWrapper.EmailNotificationWrapper();
            String query = 'select id, Data__c, OverwriteBatchInProgress__c, LastModifiedDate, Last_Modified_By_People__c, Last_Modified_By_People__r.Full_Name__c from App_Default__c where Type__c = \'email_notifications\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
            emailNotificationWrapObj = toEmailNotificationWrapper(listOfAppDefault);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, emailNotificationWrapObj);

		} catch (Exception e) {
        	logger.logError('SettingDataServer.getEmailNotificationsSettings()----could not get email notification configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 			
        }

		return responseWrapperObj;
	}
	@TestVisible
	private ResponseWrapper getBrowserNotificationsSettings(){
		logger.logDebug('SettingDataServer.getBrowserNotificationsSettings()');
        ResponseWrapper responseWrapperObj = null;

		try {
        ManageApplicationWrapper.BrowserNotificationWrapper browserNotificationWrapObj = new ManageApplicationWrapper.BrowserNotificationWrapper();
        String query = 'select id, Data__c, OverwriteBatchInProgress__c, LastModifiedDate, Last_Modified_By_People__c, Last_Modified_By_People__r.Full_Name__c from App_Default__c where Type__c = \'browser_notifications\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);	
		browserNotificationWrapObj = toBrowserNotificationWrapper(listOfAppDefault);
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, browserNotificationWrapObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getBrowserNotificationsSettings()----could not get browser notification configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 			
        }

		return responseWrapperObj;
	}
	
	private ManageApplicationWrapper.BrowserNotificationWrapper toBrowserNotificationWrapper(List<App_Default__c> listOfAppDefault) {
		ManageApplicationWrapper.BrowserNotificationWrapper notificationSettings = new ManageApplicationWrapper.BrowserNotificationWrapper();
		notificationSettings.isProcessing = false;
		if(!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)) {
			notificationSettings.isProcessing = listOfAppDefault[0].OverwriteBatchInProgress__c;
			notificationSettings = (ManageApplicationWrapper.BrowserNotificationWrapper)JSON.deserialize(listOfAppDefault[0].Data__c,ManageApplicationWrapper.BrowserNotificationWrapper.class);		
			
			notificationSettings.modifiedAt = Utility.dateTimeToMomentJSDateTime(listOfAppDefault[0].LastModifiedDate);
			notificationSettings.modifiedBy = new ManageApplicationWrapper.UserWrapper();
			notificationSettings.modifiedBy.peopleId = listOfAppDefault[0].Last_Modified_By_People__c;
			notificationSettings.modifiedBy.name = listOfAppDefault[0].Last_Modified_By_People__r.Full_Name__c;
		} else {
			PostInstallHelper piHelper = new PostInstallHelper();
			notificationSettings = piHelper.getDefaultBrowserNotificationSettings();
		}

		notificationSettings.isApplyToAllUsers = null;

		return 	notificationSettings;
    }

	private ManageApplicationWrapper.EmailNotificationWrapper toEmailNotificationWrapper(List<App_Default__c> listOfAppDefault) {
		ManageApplicationWrapper.EmailNotificationWrapper notificationSettings = new ManageApplicationWrapper.EmailNotificationWrapper();
        notificationSettings.isProcessing = false;
        
		if (!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)) {
			notificationSettings.isProcessing = listOfAppDefault[0].OverwriteBatchInProgress__c;
			notificationSettings = (ManageApplicationWrapper.EmailNotificationWrapper)JSON.deserialize(
                    listOfAppDefault[0].Data__c, ManageApplicationWrapper.EmailNotificationWrapper.class);		
            notificationSettings.modifiedAt = Utility.dateTimeToMomentJSDateTime(listOfAppDefault[0].LastModifiedDate);
            notificationSettings.modifiedBy = new ManageApplicationWrapper.UserWrapper();
            notificationSettings.modifiedBy.peopleId = listOfAppDefault[0].Last_Modified_By_People__c;
            notificationSettings.modifiedBy.name = listOfAppDefault[0].Last_Modified_By_People__r.Full_Name__c;
           
		} else {  
			PostInstallHelper piHelper = new PostInstallHelper();
			notificationSettings = piHelper.getDefaultEmailNotificationsSettings();
    	}

		if ('Never'.equalsIgnoreCase(notificationSettings.emailNotificationFrequency)) {
			notificationSettings.allowSimpplrEmails = 'none';
			notificationSettings.emailNotificationFrequency = 'none';
        }

        
       

		notificationSettings.isApplyToAllUsers = null;
		return 	notificationSettings;
    }

    private ResponseWrapper getSummariesAndDigestSettings(){
		logger.logDebug('SettingDataServer.getSummariesAndDigestSettings()');
        ResponseWrapper responseWrapperObj = null;

		try {  
            ManageApplicationWrapper.SummariesAndDigestWrapper emailNotificationWrapObj = new ManageApplicationWrapper.SummariesAndDigestWrapper();
            String query = 'select id, Data__c, OverwriteBatchInProgress__c, LastModifiedDate, Last_Modified_By_People__c, Last_Modified_By_People__r.Full_Name__c from App_Default__c where Type__c = \'summaries_and_digest\'';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
            emailNotificationWrapObj = toSummariesAndDigestWrapper(listOfAppDefault);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, emailNotificationWrapObj);

		} catch (Exception e) {
        	logger.logError('SettingDataServer.getSummariesAndDigestSettings()----could not get SummariesAndDigest notification configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 			
        }

		return responseWrapperObj;
    }

	private ManageApplicationWrapper.SummariesAndDigestWrapper toSummariesAndDigestWrapper(List<App_Default__c> listOfAppDefault) {
		ManageApplicationWrapper.SummariesAndDigestWrapper summariesAndDigestWrap = new ManageApplicationWrapper.SummariesAndDigestWrapper();
        summariesAndDigestWrap.isProcessing = false;
        
		if (!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)) {
			summariesAndDigestWrap.isProcessing = listOfAppDefault[0].OverwriteBatchInProgress__c;
			summariesAndDigestWrap = (ManageApplicationWrapper.SummariesAndDigestWrapper)JSON.deserialize(
                    listOfAppDefault[0].Data__c, 
                    ManageApplicationWrapper.SummariesAndDigestWrapper.class);	
            summariesAndDigestWrap.modifiedAt = Utility.dateTimeToMomentJSDateTime(listOfAppDefault[0].LastModifiedDate);
            summariesAndDigestWrap.modifiedBy = new ManageApplicationWrapper.UserWrapper();
            summariesAndDigestWrap.modifiedBy.peopleId = listOfAppDefault[0].Last_Modified_By_People__c;
            summariesAndDigestWrap.modifiedBy.name = listOfAppDefault[0].Last_Modified_By_People__r.Full_Name__c;	
		
		} else {  
			PostInstallHelper piHelper = new PostInstallHelper();
			summariesAndDigestWrap = piHelper.getDefaultSummariesAndDigestSettings();
    	}

		summariesAndDigestWrap.isApplyToAllUsers = null;
		return 	summariesAndDigestWrap;
    }
	
	private ResponseWrapper getUserSyncingPeopleConfig(){
		logger.logDebug('SettingDataServer.getUserSyncingPeopleConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.UserSyncingPeopleWrapper userSyncingWrapObj = new ManageApplicationWrapper.UserSyncingPeopleWrapper();
            userSyncingWrapObj = new ManageApplicationDao().loadSyncingSettings();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, userSyncingWrapObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getUserSyncingPeopleConfig()----could not get user syncing people configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		return responseWrapperObj;
	}
	
	private ResponseWrapper getUserProvisioningConfig(){
		logger.logDebug('SettingDataServer.getUserProvisioningConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.UserProvisioningWrapper userProvisioningWrapObj = new ManageApplicationWrapper.UserProvisioningWrapper();
			userProvisioningWrapObj = new ManageApplicationDao().loadUserProvisioningSettings();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, userProvisioningWrapObj);

		}catch (Exception e) {
        	logger.logError('SettingDataServer.getUserProvisioningConfig()----could not get user syncing people configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		return responseWrapperObj;
    }

    private ResponseWrapper getProfileFieldsPeopleConfig(){
		logger.logDebug('SettingDataServer.getProfileFieldsPeopleConfig()');
        ResponseWrapper responseWrapperObj = null;

        try {
            ManageApplicationWrapper.ProfileFieldsWrapper fieldPeopleWrapObj = new ManageApplicationDao().loadPeopleProfileConfig();
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fieldPeopleWrapObj);

	    }catch (Exception e) {
        	logger.logError('SettingDataServer.getProfileFieldsPeopleConfig()----could not get profile field configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }

		return responseWrapperObj;
    }

	private ResponseWrapper getLicensingPeopleConfig(){
        logger.logDebug('SettingDataServer.getLicensingPeopleConfig()');
		ResponseWrapper responseWrapperObj = null;
        try {
            ManageApplicationWrapper.LicensingPeopleWrapper licensingPeopleObj  = new ManageApplicationWrapper.LicensingPeopleWrapper();
	        licensingPeopleObj = new ManageApplicationDao().fetchLincensingPeople();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, licensingPeopleObj);

		}catch (Exception e) {
			logger.logError('SettingDataServer.getLicensingPeopleConfig()----could not get people licensing configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null); 			
		}
		return responseWrapperObj;
	}
	@TestVisible
	private ResponseWrapper getSMSNotificationsSettings(){
        logger.logDebug('SettingDataServer.getSMSNotificationsSettings()');
	ResponseWrapper responseWrapperObj = null;
        try {
			ManageApplicationWrapper.SMSNotificationWrapper sMSNotificationObj  = new ManageApplicationWrapper.SMSNotificationWrapper();
			String query = 'select id, Data__c, OverwriteBatchInProgress__c, LastModifiedDate, Last_Modified_By_People__c, Last_Modified_By_People__r.Full_Name__c from App_Default__c where Type__c = \'sms_notifications\'';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
	        	sMSNotificationObj = new ManageApplicationDao().getSMSNotificationsSettings(listOfAppDefault);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, sMSNotificationObj);

		}catch (Exception e) {
			logger.logError('SettingDataServer.getSMSNotificationsSettings()----could not get SMS notifications',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null); 			
		}
		return responseWrapperObj;
	} 
	
	private ResponseWrapper getNativeMobileAppNotificationsSettings(){
        logger.logDebug('SettingDataServer.getNativeMobileAppNotificationsSettings()');
	ResponseWrapper responseWrapperObj = null;
        try {
			ManageApplicationWrapper.MobileAppNotificationWrapper mobileAppNotificationObj  = new ManageApplicationWrapper.MobileAppNotificationWrapper();
			String query = 'select id, Data__c, OverwriteBatchInProgress__c, LastModifiedDate, Last_Modified_By_People__c, Last_Modified_By_People__r.Full_Name__c from App_Default__c where Type__c = \'native_mobile_notifications\'';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
	        	mobileAppNotificationObj = new ManageApplicationDao().getNativeMobileAppNotificationsSettings(listOfAppDefault);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, mobileAppNotificationObj);

		}catch (Exception e) {
			logger.logError('SettingDataServer.getNativeMobileAppNotificationsSettings()----could not get mobile app notifications',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,null, null); 			
		}
		return responseWrapperObj;
    }

	/**
	 * @api {get} /apex/DataServerRO?target=SettingDataServer&action=saveGeneralSetupConfig saveGeneralSetupConfig
	 * @apiVersion 1.0.0
	 * @apiGroup SettingDataServer
	 * @apiName saveGeneralSetupConfig
	 *
	 * @apiParam {String} action=saveGeneralSetupConfig saveGeneralSetupConfig is the action used for saving the setup data
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.ManageApp.saveGeneralSetupConfig
	 * 2. Used in Manage Application Setup
	 * 3. Used to invoke BatchResetMustRead batch when SiteFeaturesForMustRead contains any value
	 * 
	 * @apiSuccess {ManageApplicationWrapper.GeneralSetupWrapper} Response.listOfItems General Setup Wrapper
	 * @apiUse ManageApplicationWrapperGeneralSetupWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */   
    @TestVisible private ResponseWrapper saveGeneralSetupConfig(String requestData) {
    	logger.logDebug('SettingDataServer.saveGeneralSetupConfig()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null; 

        try {
			ManageApplicationWrapper.GeneralSetupWrapper generalSetupObj = (ManageApplicationWrapper.GeneralSetupWrapper)Json.deserialize(requestData, ManageApplicationWrapper.GeneralSetupWrapper.class);
        	
			if (generalSetupObj.mobilePromotionEnabled == null) {
				generalSetupObj.mobilePromotionEnabled = 'false';
			}
			if (generalSetupObj.brandedAppDistributionEnabled == null) {
				generalSetupObj.brandedAppDistributionEnabled = 'false';
			}

        	String siteFeaturesString = '';
	        String comma = '';
	        
			if (generalSetupObj.pagesFeatureEnabled) {
				siteFeaturesString += comma + 'Page'  ;
			    comma = ',';
				setOfSiteFeaturesForMustRead.remove('Page');
			} 

			if (generalSetupObj.eventsFeatureEnabled) {
				siteFeaturesString += comma + 'Event'  ;
			    comma = ',';
				setOfSiteFeaturesForMustRead.remove('Event');
			}
			
			if (generalSetupObj.albumsFeatureEnabled) {
				siteFeaturesString += comma + 'Album'  ;
			    comma = ',';
				setOfSiteFeaturesForMustRead.remove('Album');
			}

			if (!'disable'.equalsIgnoreCase(generalSetupObj.blogPostSetup)) {
				siteFeaturesString += comma + 'Blog' ;
			    comma = ',';
				setOfSiteFeaturesForMustRead.remove('BlogPost');
			}

			//Add File feature, otherwise My Files will not work
		    siteFeaturesString += comma + 'File';
        	ManageApplicationDao.saveAppGeneralSetup(siteFeaturesString, generalSetupObj);
        	Map<String, Object> mapOfActivityParams = new Map<String, Object>();
        	List<String> listOfInactiveFeatures = new List<String>();
		    List<String> listOfSitesWithInactiveFeatures = new List<String>();
		    
			listOfInactiveFeatures.addAll(setOfSiteFeaturesForMustRead);
		    listOfSitesWithInactiveFeatures.add('all');
		    
			if (listOfInactiveFeatures.size() > 0) {
		    	mapOfActivityParams.put('InactiveFeatures',listOfInactiveFeatures);
		    	mapOfActivityParams.put('listOfSitesWithInactiveFeatures',listOfSitesWithInactiveFeatures);
				BatchResetMustRead job = new BatchResetMustRead('FeaturesInactive', true, 
						mapOfActivityParams);
				Database.executeBatch(job,2000);
		    }
		    
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, generalSetupObj);
        
		} catch (Exception e) {
        	logger.logError('SettingDataServer----could not save general setup configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(e), null);
        }

        logger.logDebug('SettingDataServer.saveGeneralSetupConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
	/**
	 * @description disconnect ADSI admin integration
	 * @return response of type ResponseWrapper
	 */
    @TestVisible private ResponseWrapper disconnectADSI(){
    	logger.logDebug('SettingDataServer.disconnectADSI()');
        ResponseWrapper responseWrapperObj = null;
        
        try{
        	if(UserContext.isUserAppModerator){
        		// Make Sync source none if it was set to Active Directory.
        		String appConfigQuery = 'SELECT Id, PDS_Source_Application__c FROM App_Config__c LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
				
        		if('activedirectory'.equalsIgnoreCase(appConfigObj.PDS_Source_Application__c)){
	        		appConfigObj.PDS_Source_Application__c = 'None';
	        		
	        		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	        		SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
																			App_Config__c.PDS_Source_Application__c});
        		}
	
				// create audit trail
				ManageApplicationDao.auditUserSyncProvSource(true, 'None', 'activedirectory');

        		// Remove App Int 
        		String appIntQuery = 'SELECT Id, Client_Id__c, Client_Secret__c FROM App_Integration__c WHERE Name = \'adsi\' AND Is_Deleted__c = false LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<App_integration__c> appIntList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, null);

		    	if(!appIntList.isEmpty()){
		    		appIntList[0].App_Access_Token__c = '';
					appIntList[0].App_Refresh_Token__c = '';
					appIntList[0].Token_Type__c = '';
					appIntList[0].User_Email__c = '';
					appIntList[0].User_Name__c = '';
					appIntList[0].Access_Token_Expiration_Datetime__c = null;
					appIntList[0].Access_Token_Expiry__c = null;
					appIntList[0].Integration_Enabled__c = false;
					appIntList[0].Connected__c = false;
		    		
		    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	        		SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appIntList), 
	        												new List<Schema.SObjectField>{
																App_Integration__c.App_Access_Token__c,
																App_Integration__c.App_Refresh_Token__c,
																App_Integration__c.Token_Type__c,
																App_Integration__c.User_Email__c,
																App_Integration__c.User_Name__c,
																App_Integration__c.Access_Token_Expiration_Datetime__c,
																App_Integration__c.Access_Token_Expiry__c,
																App_Integration__c.Integration_Enabled__c,
																App_Integration__c.Connected__c
																});
	
		            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Active Directory account disconnect successful !', null);						    		
		    	}        		
        	} else {
        		throw new SimpplrException(ServiceConstants.ERROR_403);
        	}
        }catch(Exception ex){
        	logger.logError('SettingDataServer----Could not disconnect Active Directory', ex);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        logger.logDebug('SettingDataServer.disconnectADSI()----responseWrapperObj----' + responseWrapperObj);
        
        return responseWrapperObj;
	}

	/**
	 * @description disconnect active directory admin integration
	 * @return response of type ResponseWrapper
	 */
	@TestVisible private ResponseWrapper disconnectActiveDirectory(){
    	logger.logDebug('SettingDataServer.disconnectActiveDirectory()');
        ResponseWrapper responseWrapperObj = null;
        try{
        	if(SimpplrContext.integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY) == false) {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	} else {
				ManageApplicationDao madObj = new ManageApplicationDao();
				madObj.disconnectActiveDirectory();
				if(SimpplrContext.isActiveDirectoryGroupsEnabled) {
					// initiate batch to delete all AD audiences.
					Database.executeBatch(new BatchSyncAudienceMembersFromAD('deleteAllADGroupAudience'), 2000);					
				}				
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Active Directory account disconnect successful !', null);        		
        	}
        } catch(Exception ex){
        	logger.logError('SettingDataServer----Could not disconnect Active Directory', ex);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        logger.logDebug('SettingDataServer.disconnectActiveDirectory()----responseWrapperObj----' + responseWrapperObj);
        return responseWrapperObj;
    }
    
    @TestVisible private ResponseWrapper disconnectEFSAdmin(String storage){
    	logger.logDebug('SettingDataServer.disconnectEFSAdmin()');
        ResponseWrapper responseWrapperObj = null;
        try{
        	if(SimpplrContext.integrations.containsKey(storage) && SimpplrContext.integrations.get(storage).Batch_Processing__c) {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	} else {
        		// Set the EFS Connected Flag to false
        		App_Integration__c appintegObj = new App_Integration__c(Id = SimpplrContext.integrations.get(storage).Id);
        		appintegObj.Connected__c = false;
        		appintegObj.All_Company_Group_Id__c = null;
        		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        		SIMPESAPI.accessController().updateAsUser(appintegObj, new List<Schema.SObjectField>{
        					App_Integration__c.Connected__c, App_Integration__c.All_Company_Group_Id__c});

	       		// Set the EFS Connected Flag to false for the users
	       		Map<Id, People_Integration__c> pplIntegMap = new Map<Id, People_Integration__c>();
	       		for(People_Integration__c obj : [SELECT Id from People_Integration__c 
	       				WHERE Name = :storage AND Connected__c = true WITH SECURITY_ENFORCED]) {
	       			pplIntegMap.put(obj.Id, new People_Integration__c(id=obj.Id, Connected__c = false));
	       		}
			
				if(pplIntegMap.size() > 0) {
		       		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		       		SIMPESAPI.accessController().updateAsUser(pplIntegMap, new List<Schema.SObjectField>{
		       					People_Integration__c.Connected__c});					
				}
        		Database.executeBatch(new BatchEFSFolderSync('ADMINDEL',null,storage),01);
	            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);        		
        	}
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not disconnect ' + storage + ' admin', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.disconnectEFSAdmin()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
	}
	
	@TestVisible private ResponseWrapper disconnectGoogleUserSyncAdmin() {
        ResponseWrapper responseWrapperObj = null;
        try{
        	if(SimpplrContext.integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC) == false ) {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	} else {    
				
				// disable integration on AWS 
				ManageApplicationDao.updateIntegrationDisconnectOnAWS('disconnectgoogleusersyncadmin');

				App_Integration__c appintegObj = new App_Integration__c(Id = SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC).Id);        					
				if(appintegObj != null){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(appintegObj);	
				}

				// Make Sync source none if it was set to Google for user syncing.
        		String appConfigQuery = 'SELECT Id, PDS_Source_Application__c FROM App_Config__c LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
				
        		if('Google'.equalsIgnoreCase(appConfigObj.PDS_Source_Application__c)){
	        		appConfigObj.PDS_Source_Application__c = 'None';
	        		
	        		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	        		SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
																			App_Config__c.PDS_Source_Application__c});
				}

				// create audit trail
				ManageApplicationDao.auditUserSyncProvSource(true, 'None', 'Google');

				// Make Sync source none if it was set to Google for provisioning.
				String query = 'SELECT Id, Provisioning_Source__c FROM User_Provisioning_Config__c LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<User_Provisioning_Config__c> userProvConfigList = ((List<User_Provisioning_Config__c>)SIMPESAPI.accessController().queryAsUser(query, null));
        		if(!userProvConfigList.isEmpty()){
					if('Google'.equalsIgnoreCase(userProvConfigList[0].Provisioning_Source__c)){
						userProvConfigList[0].Provisioning_Source__c = 'None';
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						SIMPESAPI.accessController().updateAsUser(userProvConfigList[0], new List<Schema.SObjectField>{
																					User_Provisioning_Config__c.Provisioning_Source__c});
					}
				}
				

				BatchGoogleUserSync job = new BatchGoogleUserSync('CleanSyncField');
				Database.executeBatch(job, 1);

				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);        		
        	}
        }catch(Exception e) {
        	logger.logError('SettingDataServer.disconnectGoogleUserSyncAdmin()----Exception occured----', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
	}

	@TestVisible private ResponseWrapper disconnectGoogleCalendarAdmin() {
        ResponseWrapper responseWrapperObj = null;
        try{
        	if(SimpplrContext.integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR) == false ) {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	} else {    
				GoogleCalendarHelper gdService = new GoogleCalendarHelper();				
				gdService.disconnectGoogleCalendarAdmin();    		
				App_Integration__c appintegObj = new App_Integration__c(Id = SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR).Id);        					
				appintegObj.Is_Deleted__c = true;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        		SIMPESAPI.accessController().updateAsUser(appintegObj, new List<Schema.SObjectField>{
																				App_Integration__c.Is_Deleted__c
																			});
				
				Database.executeBatch(new BatchDeleteIntegrationRecords(new List<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR}),2000);
				Database.executeBatch(new BatchDeleteTilesConfigRecords(null, 'googleCalendar'), 2000);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);        		
        	}
        }catch(Exception e) {
        	logger.logError('SettingDataServer.disconnectGoogleCalendarAdmin()----Exception occured----', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
	}

	@TestVisible private ResponseWrapper disconnectServicenowAdmin(){
    	logger.logDebug('SettingDataServer.disconnectServicenowAdmin()');
        ResponseWrapper responseWrapperObj = null;
        try{
        	if(SimpplrContext.integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW) == false ) {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	} else {
				ManageApplicationDao madObj = new ManageApplicationDao();
				if(SimpplrContext.integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SALESFORCE)) {
					madObj.disableServiceNowNotifications();
				}
				madObj.disconnectServiceNowAdmin();
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);        		
        	}
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not disconnect ' + IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW + ' admin', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.disconnectServicenowAdmin()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@TestVisible private ResponseWrapper disconnectAtlassianAdmin(){
    	logger.logDebug('SettingDataServer.disconnectAtlassianAdmin()');
        ResponseWrapper responseWrapperObj = null;
        try{
        	if(SimpplrContext.integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN) == false) {
        		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	} else {
				ManageApplicationDao madObj = new ManageApplicationDao();
				madObj.disconnectAtlassianAdmin();
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);        		
        	}
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not disconnect ' + IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN + ' admin', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.disconnectAtlassianAdmin()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
	
	
	

	/**
	 * @api {get} /apex/DataServerRO?target=SettingDataServer&action=disconnectApp disconnectApp
	 * @apiVersion 1.0.0
	 * @apiGroup SettingDataServer
	 * @apiName disconnectApp
	 *
	 * @apiParam {String} action=disconnectApp disconnectApp is the action for disconnecting the Admin accounts for Active Directory, External Search
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Global.disconnectApp
	 * 2. Used in Manage Application Integrations
	 * 
	 * @apiSuccess {Null} Response.result Null
	 *
	 * @apiError SimpplrException Simpplr Exception
	 */ 
    @TestVisible private ResponseWrapper disconnectApp(String requestData){
    	ResponseWrapper response = null;
		Map<String, String> appNameMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
		String appName = appNameMap.get('appName');

    	if(IntegrationConstants.INTEGRATION_TYPE_ADSI.equalsIgnoreCase(appName)){
    		response = disconnectADSI();
    	
		} else if(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY.equalsIgnoreCase(appName)){
    		response = disconnectActiveDirectory();
    	
		} else if('smartsearch'.equalsIgnoreCase(appName)){
    		response = updateExternalSearchConnectFlag();
    	
		} else if(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appName)){
			response =  disconnectServicenowAdmin();

		} else if(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN.equalsIgnoreCase(appName) ){
				response =  disconnectAtlassianAdmin();
		
		} else if(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT.equalsIgnoreCase(appName)) {
            String isUpgradeAndDisconnect = appNameMap.get('spUpgradeAndDisconnect');
            if(!String.isBlank(isUpgradeAndDisconnect) && Boolean.valueOf(isUpgradeAndDisconnect)) {
                ManageApplicationDao madObj = new ManageApplicationDao();
                madObj.saveSharepointUpgradeConfig();
                Database.executeBatch(new BatchSPMultiInstanceUpgrade('unlinkFolders', true), 2000);
                response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            } else {
                response =  disconnectEFSAdmin(appName);
            }
            
		} else if(IntegrationConstants.INTEGRATION_TYPE_DROPBOX.equalsIgnoreCase(appName)){
            response =  disconnectEFSAdmin(appName);
        
        } else if(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE.equalsIgnoreCase(appName) ){
			ManageApplicationDao daoObj = new ManageApplicationDao();
			daoObj.disconnectGoogleDriveAdmin(appName);
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

		} else if(IntegrationConstants.INTEGRATION_TYPE_BOX.equalsIgnoreCase(appName)){
			BoxContentProvider.disconnectAdmin();
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

		} else if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(appName)) {
			response =  disconnectGoogleCalendarAdmin();

		} else if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC.equalsIgnoreCase(appName)) {
			response =  disconnectGoogleUserSyncAdmin();

		} else if (IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS_ADMIN.equalsIgnoreCase(appName)) {
			MicrosoftTeamsHelper msTeamsHelperObj = new MicrosoftTeamsHelper();
			msTeamsHelperObj.processMSTeamsAdminDisconnect(true);
			
			response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);	
		} else {
			throw new SimpplrException(ExceptionCode.INVALID_REQUEST_PARAM_VALUE.name());
    	}
    	
    	return response;
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
	private ResponseWrapper saveGovernanceSetupConfig(String requestData) { 
        ResponseWrapper responseWrapperObj = null;

        try {
        	logger.logDebug('SettingDataServer.saveGovernanceSetupConfig()----requestData----'+requestData);
        	ManageApplicationWrapper.GovernanceSetupWrapper governanceSetupWrapObj = (ManageApplicationWrapper.GovernanceSetupWrapper)Json.deserialize(requestData, ManageApplicationWrapper.GovernanceSetupWrapper.class);
        	logger.logDebug('SettingDataServer.saveGovernanceSetupConfig()----governanceSetupWrapObj----'+governanceSetupWrapObj);
        	
			if (governanceSetupWrapObj.feedPlaceholderToggle == 'on') {
				governanceSetupWrapObj.customFeedPlaceholderText = '';
			}

        	ManageApplicationDao ManageApplicationDaoObj = new ManageApplicationDao();
        	ManageApplicationDaoObj.saveAppGovernance(governanceSetupWrapObj);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, 
					governanceSetupWrapObj);
        
		} catch (Exception e) {
        	logger.logError('SettingDataServer----could not save listOfGovernanceSetupData setup configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
					MessageHelper.translateSFMessageToErrorCode(e), null);
        }

        logger.logDebug('SettingDataServer.saveGovernanceSetupConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper saveNavigationSetupConfig(String requestData){ 
    	logger.logDebug('SettingDataServer.saveNavigationSetupConfig()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{ 
        	ManageApplicationWrapper.NavigationSetupWrapper navigationObj =(ManageApplicationWrapper.NavigationSetupWrapper)Json.deserialize(requestData, ManageApplicationWrapper.NavigationSetupWrapper.class);
        	ManageApplicationDao ManageApplicationDaoObj = new ManageApplicationDao();
        	ManageApplicationDaoObj.saveNavigationConfig(navigationObj);
			navigationObj = ManageApplicationDaoObj.getNavigationDetails();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, navigationObj);            
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save navigation setup configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveNavigationSetupConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper saveEmailSetupConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveEmailSetupConfig()----requestData----'+requestData);
        	ResponseWrapper responseWrapperObj = null;
        try{
        	ManageApplicationWrapper.AppConfigEmailWrapper appConfEmailObj =(ManageApplicationWrapper.AppConfigEmailWrapper)Json.deserialize(requestData, ManageApplicationWrapper.AppConfigEmailWrapper.class);
            ManageApplicationDao.saveEmailSetupConfig(appConfEmailObj);
            if(appConfEmailObj != null){
				if(appConfEmailObj.enableEmail && String.isNotBlank(appConfEmailObj.emailSender)){
					sendOrgWideEmailVerificationStatus(appConfEmailObj.emailSender);
            	}
			}
			FilterService serviceObj = new FilterService();
			appConfEmailObj.availableSenders = serviceObj.getOrgWideEmailsForFilters();
			appConfEmailObj.availableProfiles = serviceObj.getAllProfilesListForFilters();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, appConfEmailObj);
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save email setup configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveEmailSetupConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    @future 
    @TestVisible private static void sendOrgWideEmailVerificationStatus(String orgWideEmailId){
    	try {
			Messaging.SingleEmailMessage successEmail = new Messaging.SingleEmailMessage();
			successEmail.setOrgWideEmailAddressId(orgWideEmailId);
			
			String mailBodyHtml='Dear User'+ ', <br/><br/> Sender address for Notifications, Digest, Top Stories and Newsletter emails is verfied.';
			mailBodyHtml+=' <br/><br/>Org Details:<br/>';
			mailBodyHtml+=' <br/>OrgId - '+ UserInfo.getOrganizationId();
			mailBodyHtml+=' <br/>Org Name - '+ UserInfo.getOrganizationName();
			mailBodyHtml+=' <br/>UserId - '+ UserContext.id;
			mailBodyHtml+=' <br/>User Name - '+ UserContext.peopleName;
			mailBodyHtml+=' <br/> <br/> Thanks.!';
			successEmail.setHtmlBody(mailBodyHtml);
			successEmail.setCharset('UTF-8');
			successEmail.setUseSignature(false);

			successEmail.setSubject('Email sender address Verified');
			successEmail.setToAddresses(new List<string> {UserInfo.getUserEmail()});
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { successEmail } );
        } catch(EmailException e){
			Messaging.SingleEmailMessage failureEmail = new Messaging.SingleEmailMessage();
			
			String mailBodyHtml='Dear User'+ ', <br/><br/> Sender address for Notifications, Digest, Top Stories and Newsletter emails is not verfied, please verify.';
			mailBodyHtml+=' <br/><br/>Org Details:<br/>';
			mailBodyHtml+=' <br/>OrgId - '+ UserInfo.getOrganizationId();
			mailBodyHtml+=' <br/>Org Name - '+ UserInfo.getOrganizationName();
			mailBodyHtml+=' <br/>UserId - '+ UserContext.id;
			mailBodyHtml+=' <br/>User Name - '+ UserContext.peopleName;
			mailBodyHtml+=' <br/> <br/> Thanks.!';
			failureEmail.setHtmlBody(mailBodyHtml);
			failureEmail.setCharset('UTF-8');
			failureEmail.setUseSignature(false);
			
			failureEmail.setSubject('Email sender address not Verified');
			failureEmail.setToAddresses(new List<string> {UserInfo.getUserEmail()});
    		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { failureEmail } ); 
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
    @TestVisible private ResponseWrapper saveGeneralPeopleConfig(String requestData){
        	ResponseWrapper responseWrapperObj = null;
        try{
        	logger.logDebug('SettingDataServer.saveGeneralPeopleConfig()----requestData----'+requestData);
            ManageApplicationWrapper.GeneralPeopleWrapper genPeopleObj =(ManageApplicationWrapper.GeneralPeopleWrapper)Json.deserialize(requestData, ManageApplicationWrapper.GeneralPeopleWrapper.class);
			ManageApplicationDao daoObj = new ManageApplicationDao();
			daoObj.saveGeneralPeopleConfig(genPeopleObj);
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, genPeopleObj);
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save general people configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveGeneralPeopleConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper saveUserSyncingPeopleConfig(String requestData){
        ResponseWrapper responseWrapperObj = null;
        try{
        	logger.logDebug('SettingDataServer.saveUserSyncingPeopleConfig()----requestData----'+requestData);
            ManageApplicationWrapper.UserSyncingPeopleWrapper userSyncPeopleObj =(ManageApplicationWrapper.UserSyncingPeopleWrapper)Json.deserialize(requestData, ManageApplicationWrapper.UserSyncingPeopleWrapper.class);
        	ManageApplicationDao.saveUserSyncingPeopleConfig(userSyncPeopleObj);
        	
			userSyncPeopleObj = new ManageApplicationDao().loadSyncingSettings();
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, userSyncPeopleObj);
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save user syncing people configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveUserSyncingPeopleConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
	
	@TestVisible private ResponseWrapper saveUserProvisioningConfig(String requestData){
        ResponseWrapper responseWrapperObj = null;
        try{
        	logger.logDebug('SettingDataServer.saveUserProvisioningConfig()----requestData----'+requestData);
            ManageApplicationWrapper.UserProvisioningWrapper userProvisioningObj =(ManageApplicationWrapper.UserProvisioningWrapper)Json.deserialize(requestData, ManageApplicationWrapper.UserProvisioningWrapper.class);
        	
        	ManageApplicationDao.saveUserProvisioningConfig(userProvisioningObj);

			userProvisioningObj = new ManageApplicationDao().loadUserProvisioningSettings();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, userProvisioningObj);
		
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save user provisioning configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveUserProvisioningConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    
    @TestVisible private ResponseWrapper saveProfileFieldsPeopleConfig(String requestData){
        ResponseWrapper responseWrapperObj = null;
        try{
        	logger.logDebug('SettingDataServer.saveProfileFieldsPeopleConfig()----requestData----'+requestData);
            ManageApplicationWrapper.ProfileFieldsWrapper profileFieldsObj =(ManageApplicationWrapper.ProfileFieldsWrapper)Json.deserialize(requestData, ManageApplicationWrapper.ProfileFieldsWrapper.class);
        	
        	restrictSegmentationFieldUserEditable(profileFieldsObj);
        	
        	ManageApplicationDao.saveProfileFieldsPeopleConfig(profileFieldsObj);
        	
        	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, profileFieldsObj);
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save profile fields people configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveProfileFieldsPeopleConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    // Check if segmentation is enabled and app manager is trying to make the segmentation field user editable.
    private void restrictSegmentationFieldUserEditable(ManageApplicationWrapper.ProfileFieldsWrapper profileFieldsObj){
    	Map<String, String> fieldApiVsNameMap = new Map<String, String>{
													'Division__c' => STR_DIVISION,
													'Department__c' => STR_DEPARTMENT,
													'Company_Name__c' => STR_COMPANY, 
													'Country__c' => STR_COUNTRY,
													'City__c' => STR_CITY,
													'State__c' => STR_STATE,
													'People_Category__c' => STR_PEOPLE_CATEGORY,
													'Joining_Date__c' => STR_PEOPLE_HIRE_DATE,
													'Title__c' => STR_TITLE 
    	};

		if (SimpplrContext.isSegmentsEnabled && UserContext.isUserAppModerator){
    		String segmentFieldName = SimpplrContext.segmentColumnName;
    		String fieldNameInErrorMsg = '';
    		
    		// Check for Segmentation..
    		if(('Division__c').equalsIgnoreCase(segmentFieldName)){
    			if(profileFieldsObj.editableDivision == true){
    				fieldNameInErrorMsg = fieldApiVsNameMap.get(segmentFieldName);
    			}
    		} else if(('Company_Name__c').equalsIgnoreCase(segmentFieldName)){
    			if(profileFieldsObj.editableCompanyName == true){
    				fieldNameInErrorMsg = fieldApiVsNameMap.get(segmentFieldName);
    			}
    		} else if(('Country__c').equalsIgnoreCase(segmentFieldName)){
    			if(profileFieldsObj.editableCountry == true){
    				fieldNameInErrorMsg = fieldApiVsNameMap.get(segmentFieldName);
    			}
    		} else if(('Department__c').equalsIgnoreCase(segmentFieldName)){
    			if(profileFieldsObj.editableDepartment == true){
    				fieldNameInErrorMsg = fieldApiVsNameMap.get(segmentFieldName);
    			}
    		} else if(('State__c').equalsIgnoreCase(segmentFieldName)){
    			if(profileFieldsObj.editableState == true){
    				fieldNameInErrorMsg = fieldApiVsNameMap.get(segmentFieldName);
    			}
    		} else if(('City__c').equalsIgnoreCase(segmentFieldName)){
    			if(profileFieldsObj.editableCity == true){
    				fieldNameInErrorMsg = fieldApiVsNameMap.get(segmentFieldName);
    			}
    		}
    		
			if(String.isNotBlank(fieldNameInErrorMsg)){
				throw new SimpplrException(STR_FIELD_USED_WARN_SEGMENT.replace('{{fieldName}}', fieldNameInErrorMsg));
			}
    	}
		
		List<Subscription__c> subscriptionList = null;
		List<Social_Campaign__c> socialCampaignList = null;

		// Check for subscription fields
		if(profileFieldsObj.editableDivision == true){
			throwException(fieldApiVsNameMap.get('Division__c'), 'Has_Division_Condition__c');
		} 
		if(profileFieldsObj.editableCompanyName == true){
			throwException(fieldApiVsNameMap.get('Company_Name__c'), 'Has_Company_Name_Condition__c');
		} 
		if(profileFieldsObj.editableCountry == true){
			throwException(fieldApiVsNameMap.get('Country__c'), 'Has_Country_Condition__c');
		}
		if(profileFieldsObj.editableDepartment == true){
			throwException(fieldApiVsNameMap.get('Department__c'), 'Has_Department_Condition__c');
		}
		if(profileFieldsObj.editableCity == true){
			throwException(fieldApiVsNameMap.get('City__c'), 'Has_City_Condition__c');
		}
		if(profileFieldsObj.editableState == true){
			throwException(fieldApiVsNameMap.get('State__c'), 'Has_State_Condition__c');
		}
		if(profileFieldsObj.editableUserCategory == true){
			throwException(fieldApiVsNameMap.get('People_Category__c'), 'Has_People_Category_Condition__c');
		}
		if(profileFieldsObj.editableUserTitle == true){
			throwException(fieldApiVsNameMap.get('Title__c'), 'Has_Title_Condition__c');
		}

		if(profileFieldsObj.editableJoiningDate == true){
			throwException(fieldApiVsNameMap.get('Joining_Date__c'), 'Has_Joining_Date_Condition__c');
		}
    }
    
    private void throwException(String fieldNameInErrorMsg, String booleanAudienceField){
        String audienceQuery = 'SELECT Id FROM Audience__c WHERE Is_Deleted__c = false AND ' + booleanAudienceField + ' = TRUE WITH SECURITY_ENFORCED LIMIT 1';
        List<Audience__c> audienceList = Database.query(audienceQuery);
        if(!audienceList.isEmpty()){
            throw new SimpplrException(STR_FIELD_USED_WARN_AUDIENCE.replace('{{fieldName}}', fieldNameInErrorMsg));
        }
    }
    
    @TestVisible private ResponseWrapper savePrivilegesConfig(String requestData){
    	logger.logDebug('SettingDataServer.savePrivilegesConfig()----requestData----'+requestData);
    	ResponseWrapper responseWrapperObj = null;
    	
    	try{
    		ManageApplicationWrapper.PrivilegesSetsWrapper privilegesSetupObj= (ManageApplicationWrapper.PrivilegesSetsWrapper)Json.deserialize(requestData, ManageApplicationWrapper.PrivilegesSetsWrapper.class);
	    	ManageApplicationDao daoObj = new ManageApplicationDao();
			ManageApplicationWrapper.PrivilegesSetupWrapper privilegesSetupWrapObj;
			if(Test.isRunningTest()){
				daoObj.savePrivilegesConfigData(privilegesSetupObj, true);
				privilegesSetupWrapObj = daoObj.fetchAllPrivileges(STR_PRIV_PS_LABEL, STR_PRIV_SS_PLACEHOLDER, true);
			}
			else{
				daoObj.savePrivilegesConfigData(privilegesSetupObj, FeatureFlagManager.isFeatureEnabled('zu_odin_manageapp_campaign'));
				privilegesSetupWrapObj = daoObj.fetchAllPrivileges(STR_PRIV_PS_LABEL, STR_PRIV_SS_PLACEHOLDER, FeatureFlagManager.isFeatureEnabled('zu_odin_manageapp_campaign'));
			}
	    	
	    	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, privilegesSetupWrapObj);
    	}catch(Exception e){
        	logger.logError('SettingDataServer----could not save privileges data',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        return responseWrapperObj;
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible private ResponseWrapper saveTroubleshootingConfig(String requestData){
    	logger.logDebug('SettingDataServer.saveTroubleshootingConfig()----requestData----'+requestData);
        	ResponseWrapper responseWrapperObj = null;
        try{
        	Map<String, Object> mapOfData = (Map<String,Object>) JSON.deserializeUntyped(requestData);
        	ManageApplicationWrapper.TroubleshootingWrapper troubleshootingObj= (ManageApplicationWrapper.TroubleshootingWrapper)Json.deserialize(requestData, ManageApplicationWrapper.TroubleshootingWrapper.class);
			if(troubleshootingObj.updateSimpplrDomain == true){				
				String endpoint = SimpplrContext.simpplrAPIEndpoint + '/mobile/update-simpplr-base-domain';
				Map<String, String> mapOfRequestParam = new Map<String, String>();
				mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
				mapOfRequestParam.put('baseUrl', SimpplrContext.salesforceBaseUrl);
				logger.logDebug('SettingDataServer.saveTroubleshootingConfig()----request body----' + mapOfRequestParam);
				new GoogleDriveService().getResponseFromAWS(endpoint, mapOfRequestParam);
			
			}
			ManageApplicationDao.saveTroubleshootingData(troubleshootingObj);
			troubleshootingObj.currentSimpplrDomain = SimpplrContext.salesforceBaseUrl;
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, troubleshootingObj);
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save troubleshooting configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveTroubleshootingConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    @TestVisible private ResponseWrapper saveMobileAppConfig(String requestData){
        logger.logDebug('SettingDataServer.saveMobileAppConfig()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
            ManageApplicationWrapper.MobileAppWrapper mobileAppWrapperObj = (ManageApplicationWrapper.MobileAppWrapper)Json.deserialize(requestData, ManageApplicationWrapper.MobileAppWrapper.class);
            mobileAppWrapperObj = new ManageApplicationDao().saveMobileAppData(mobileAppWrapperObj);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, mobileAppWrapperObj);
        }catch(Exception e){
            logger.logError('SettingDataServer----could not save mobile app config configuration', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.saveMobileAppConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
	
	private ResponseWrapper getMobileAppConfig() {
		logger.logDebug('SettingDataServer.getMobileAppConfig()');
		ResponseWrapper responseWrapperObj = null;
		try {
			ManageApplicationWrapper.MobileAppWrapper mobileAppSetupWrapObj = new ManageApplicationDao().getMobileAppConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, mobileAppSetupWrapObj);

		}catch (Exception e) {
			logger.logError('SettingDataServer.getMobileAppConfig()----could not get mobile app configuration', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
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
    private ResponseWrapper saveEmailNotificationsSettings(String requestData){
    	logger.logDebug('SettingDataServer.saveEmailNotificationsSettings()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;

        try {  
			ManageApplicationWrapper.EmailNotificationWrapper emailWrapper =  (ManageApplicationWrapper.EmailNotificationWrapper) JSON.deserialize(requestData, ManageApplicationWrapper.EmailNotificationWrapper.class);
			ManageApplicationDao daObj = new ManageApplicationDao();       	
			daObj.saveEmailNotificationsSettings(requestData); 
			
			if ('1'.equalsIgnoreCase(emailWrapper.isApplyToAllUsers)) {	
				daObj.applyEmailDefaultToAllUsers();
				emailWrapper.isProcessing = true;
				emailWrapper.isApplyToAllUsers = null;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, emailWrapper);
            
            } else {
				emailWrapper.isProcessing = false;
				emailWrapper.isApplyToAllUsers = null;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, emailWrapper);
            }
            
        } catch (Exception e) {
        	logger.logError('SettingDataServer----could not save application email notifications',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        logger.logDebug('SettingDataServer.saveEmailNotificationsSettings()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }   

    @TestVisible 
    private ResponseWrapper saveSummariesAndDigestSettings(String requestData){
    	logger.logDebug('SettingDataServer.saveSummariesAndDigestSettings()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;

        try {  
            ManageApplicationWrapper.SummariesAndDigestWrapper emailWrapper =  (ManageApplicationWrapper.SummariesAndDigestWrapper) JSON.deserialize(requestData, 
                    ManageApplicationWrapper.SummariesAndDigestWrapper.class);
			ManageApplicationDao daObj = new ManageApplicationDao();       	
			daObj.saveSummariesAndDigestSettings(requestData); 
			
			if ('1'.equalsIgnoreCase(emailWrapper.isApplyToAllUsers)) {	
				daObj.applySummariesAndDigestDefaultToAllUsers();
				emailWrapper.isProcessing = true;
				emailWrapper.isApplyToAllUsers = null;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, emailWrapper);
            
            } else {
				emailWrapper.isProcessing = false;
				emailWrapper.isApplyToAllUsers = null;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, emailWrapper);
            }
            
        } catch (Exception e) {
        	logger.logError('SettingDataServer----could not save application Summaries and digest notifications',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        
        logger.logDebug('SettingDataServer.saveSummariesAndDigestSettings()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
	  
	
	@TestVisible private ResponseWrapper saveBrowserNotificationsSettings(String requestData){
		logger.logDebug('SettingDataServer.saveBrowserNotificationsSettings()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
		try{
			ManageApplicationWrapper.BrowserNotificationWrapper browserNotificationWrapperObj =  (ManageApplicationWrapper.BrowserNotificationWrapper) JSON.deserialize(requestData, ManageApplicationWrapper.BrowserNotificationWrapper.class);
			ManageApplicationDao daObj = new ManageApplicationDao();       	
			daObj.saveBrowserNotificationsSettings(requestData);
			
			if('1'.equalsIgnoreCase(browserNotificationWrapperObj.isApplyToAllUsers)) {	
				daObj.applyBrowserDefaultToAllUsers();
				browserNotificationWrapperObj.isProcessing = true;
				browserNotificationWrapperObj.isApplyToAllUsers = null;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, browserNotificationWrapperObj);
			} else {
				browserNotificationWrapperObj.isProcessing = false;
				browserNotificationWrapperObj.isApplyToAllUsers = null;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, browserNotificationWrapperObj);
			}
		}catch(Exception e){
			logger.logError('SettingDataServer----could not save application browser notifications',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		logger.logDebug('SettingDataServer.saveBrowserNotificationsSettings()----responseWrapperObj----'+responseWrapperObj);
		return responseWrapperObj;
	} 
    
    @TestVisible private ResponseWrapper saveDefaultFeedSettings(String requestData){
    	logger.logDebug('SettingDataServer.saveDefaultFeedSettings()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
        	ManageApplicationDao daObj = new ManageApplicationDao();       	
        	daObj.saveDefaultFeedSettings(requestData);		    
			ManageApplicationWrapper.DefaultFeedSettingsWrapper defaultFeedObj = daObj.getDefaultFeedSettings();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, defaultFeedObj);
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save application email notifications',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveDefaultFeedSettings()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    } 
    
    private Set<String> setOfSiteFeaturesForMustRead = new Set<String>{'Page','Event','Album','BlogPost'};
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    @TestVisible 
	private ResponseWrapper saveLicensingPeopleConfig(String requestData){ 
    	logger.logDebug('SettingDataServer.saveLicensingPeopleConfig()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try { 
        	ManageApplicationWrapper.LicensingPeopleWrapper licensingObj =(ManageApplicationWrapper.LicensingPeopleWrapper)Json.deserialize(requestData, ManageApplicationWrapper.LicensingPeopleWrapper.class);
        	ManageApplicationDao daObj = new ManageApplicationDao();
			daObj.saveLicensingPeopleConfig(licensingObj);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, licensingObj);
           
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save licensing people configuration',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveLicensingPeopleConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
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
	private ResponseWrapper saveSMSNotificationsSettings(String requestData){ 
		logger.logDebug('SettingDataServer.saveSMSNotificationsSettings()----requestData----'+requestData);
		
		ResponseWrapper responseWrapperObj = null;
        try {
        	ManageApplicationWrapper.SMSNotificationWrapper defaultSMSNotificationObj =(ManageApplicationWrapper.SMSNotificationWrapper)Json.deserialize(requestData, ManageApplicationWrapper.SMSNotificationWrapper.class);
        	ManageApplicationDao daObj = new ManageApplicationDao();
			daObj.saveSMSNotificationsSettings(requestData);
			
			if('1'.equalsIgnoreCase(defaultSMSNotificationObj.isApplyToAllUsers)) {	
				daObj.applySMSDefaultToAllUsers();
				defaultSMSNotificationObj.isProcessing = true;
				defaultSMSNotificationObj.isApplyToAllUsers = null;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, defaultSMSNotificationObj);
			} else {
				defaultSMSNotificationObj.isProcessing = false;
				defaultSMSNotificationObj.isApplyToAllUsers = null;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, defaultSMSNotificationObj);
			}
            
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save default SMS notifications configuration',e);
              responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveSMSNotificationsSettings()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
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
	private ResponseWrapper saveNativeMobileAppNotificationsSettings(String requestData){ 
    	logger.logDebug('SettingDataServer.saveNativeMobileAppNotificationsSettings()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try {
        	ManageApplicationWrapper.MobileAppNotificationWrapper mobileAppNotificationObj =(ManageApplicationWrapper.MobileAppNotificationWrapper)Json.deserialize(requestData, ManageApplicationWrapper.MobileAppNotificationWrapper.class);
        	ManageApplicationDao daObj = new ManageApplicationDao();
		daObj.saveNativeMobileAppNotificationsSettings(requestData);
		if('1'.equalsIgnoreCase(mobileAppNotificationObj.isApplyToAllUsers)) {	
			daObj.applyNativeMobileDefaultToAllUsers();
			mobileAppNotificationObj.isProcessing = true;
			mobileAppNotificationObj.isApplyToAllUsers = null;
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, mobileAppNotificationObj);
		} else {
			mobileAppNotificationObj.isProcessing = false;
			mobileAppNotificationObj.isApplyToAllUsers = null;
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS,null, mobileAppNotificationObj);
		}
            
        }catch(Exception e){
        	logger.logError('SettingDataServer----could not save default SMS notifications configuration',e);
              responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        }
        logger.logDebug('SettingDataServer.saveNativeMobileAppNotificationsSettings()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    private ResponseWrapper updateExternalSearchConnectFlag(){
    	ResponseWrapper responseWrapperObj = null;
    	String appConfigQuery = 'select id, External_search_app_connected__c,External_Search_Active__c,External_Search_Connected_By_People__c,Flow_External_Search_Enabled__c from App_Config__c limit 1';
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
    	appConfigObj.External_search_app_connected__c = false;
    	appConfigObj.External_Search_Connected_By_People__c = null;
    	appConfigObj.Flow_External_Search_Enabled__c = false;
    	appConfigObj.External_Search_Active__c = false;

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
			App_Config__c.External_search_app_connected__c, 
			App_Config__c.External_Search_Connected_By_People__c, 
			App_Config__c.Flow_External_Search_Enabled__c, 
			App_Config__c.External_Search_Active__c
		});

    	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
    	
    	return responseWrapperObj;
    }
    
	@TestVisible
    private ResponseWrapper deleteSecretTokenForExternalSearch(){
    	ResponseWrapper responseWrapperObj = null;
    	try{
			String appConfigQuery = 'select id,AWS_Access_Token__c from App_Config__c limit 1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
			
			appConfigObj.AWS_Access_Token__c = null;

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{
				App_Config__c.AWS_Access_Token__c
			});

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
	    }catch(Exception ex){
			logger.logError('SettingDataServer.deleteSecretTokenForExternalSearch()----Exception Occured', ex);
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
    	}
    	return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper connectApp(String requestData){
    	logger.logDebug('SettingDataServer.connectApp()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
        try{
			Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
			logger.logDebug('SettingDataServer.connectApp()----requestMap----' + requestMap);
            String appName = requestMap.get('appName');

			if(IntegrationConstants.INTEGRATION_TYPE_ADSI.equalsIgnoreCase(appName)){
				appName = IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY;
			}
            
            if(String.isBlank(appName)){
				throw new SimpplrException('Application name missing.');
			}
            String redirectUrl = '';
			
			if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE.equalsIgnoreCase(appName) ) {
				redirectUrl = new GoogleDriveHelper().getAdminAuthUrl();
				
			} else if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(appName) ) {
					redirectUrl = new GoogleCalendarHelper().getAdminAuthUrl();

            } else if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC.equalsIgnoreCase(appName) ) {
				String googleClientId = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID;
				String googleAuthEndpoint = AUTH_INTEGRATION_GOOGLE_USER_SYNC_ENDPOINT;
				String googleRedirectURlStr = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager';

				String googleUserSyncScopeStr = 'https://www.googleapis.com/auth/userinfo.profile ' + 
                'https://www.googleapis.com/auth/userinfo.email ' +
				'https://www.googleapis.com/auth/admin.directory.user.readonly ';
				
				String googleStateString = PageContext.getPageURL(Pages.ConnectExternalApp).toLowerCase() + 
						'?state=' + IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC + 'admin' + 
						'&orgId=' + SimpplrContext.simpplrOrgId + 
						'&peopleId=' + UserContext.peopleId + 
						'&userId=' + UserContext.userId + 
						'&appName=' + SimpplrContext.applicationName + 
						'&multiDomain=' + GoogleDriveService.googleMultiDomainUpgraded();

				redirectUrl = EmailUtility.format(
													'{0}' + 
													'?response_type=code' + 
													'&client_id={1}' + 
													'&redirect_uri={2}' + 
													'&scope={3}' + 
													'&prompt=consent' + 
													'&access_type=offline' + 
													'&include_granted_scopes=true' + 
													'&state={4}',
													new List<String>{
														googleAuthEndpoint, //0
														EncodingUtil.urlEncode(googleClientId, 'UTF-8'), //1
														EncodingUtil.urlEncode(googleRedirectURlStr, 'UTF-8'), //2
														EncodingUtil.urlEncode(googleUserSyncScopeStr, 'UTF-8'), //3
														EncodingUtil.urlEncode(googleStateString, 'UTF-8') //4
													}
									);

			} else 	if (IntegrationConstants.INTEGRATION_TYPE_DROPBOX.equalsIgnoreCase(appName)) {
				EFSAccessService EFSAccessServiceObj = new EFSAccessService(appName, true);
				redirectUrl = EFSAccessServiceObj.getAuthUrlAdmin();
				EFSAccessServiceObj.close();
			
			} else if (IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT.equalsIgnoreCase(appName) && SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT) != null && SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT).Integration_Enabled__c) {
					EFSAccessService EFSAccessServiceObj = new EFSAccessService(appName, true);
					redirectUrl = EFSAccessServiceObj.getAuthUrlAdmin();
					EFSAccessServiceObj.close();

			} else 	if (IntegrationConstants.INTEGRATION_TYPE_BOX.equalsIgnoreCase(appName)) {
				redirectUrl = 'https://www.box.com/api/oauth2/authorize?response_type=code' +
									'&client_id=' + EFSConstants.BOX_CLIENT_ID +
									'&redirect_uri=' +  EncodingUtil.urlEncode(SimpplrContext.simpplrAPIEndpoint + '/oauth/box-oauth-manager', 'UTF-8') + 
									'&state=' + EncodingUtil.urlEncode(PageContext.getPageURL(Pages.StorageSettings) + '?state=BoxAdmin', 'UTF-8');	
				
			} else 	if (IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW.equalsIgnoreCase(appName) && SimpplrContext.serviceNowIntegrationEnabled) {
				String snRedirectUrl = 'https://services.simpplr.com/oauth/redirect/code_passthrough.php';
				String snStateArgs = EncodingUtil.urlEncode(PageContext.getPageURL(Pages.ConnectExternalApp)+'?retUrl='+PageContext.getPageURL(Pages.app)+'?u=/manage/app/integrations/support'+'&state=ServiceNowAdmin','UTF-8');
				String clientIdDecrypted = Utility.decryptFn(SimpplrContext.serviceNowClientId);
				redirectUrl = SimpplrContext.serviceNowInstanceUrl+'/oauth_auth.do?scope=useraccount&response_type=code&client_id='+clientIdDecrypted+'&redirect_uri='+snRedirectUrl+'&state='+snStateArgs;	
			
			} else 	if (IntegrationConstants.INTEGRATION_TYPE_SALESFORCE.equalsIgnoreCase(appName)) {
				String redirectUri = EncodingUtil.urlEncode('https://services.simpplr.com/oauth/redirect/code_passthrough.php','UTF-8');
				String stateJSON = EncodingUtil.urlEncode(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=salesforceOauth&state={"isSandbox":'+SimpplrContext.isSandbox+',"peopleId":"'+UserContext.peopleId+'","orgId":"'+SimpplrContext.simpplrOrgId+'","baseUrl":"'+SimpplrContext.salesforceBaseUrl+'","instanceUrl":"'+SimpplrContext.salesforceHost+'","snInstanceUrl":"'+SimpplrContext.serviceNowInstanceUrl+'","redirectionUrl":"'+PageContext.getPageURL(Pages.ConnectExternalApp)+'?state=salesforce'+'"}','UTF-8');
				redirectUrl = AUTH_INTEGRATION_TYPE_SALESFORCE_ENDPOINT + '?response_type=code&client_id=3MVG9xOCXq4ID1uEnQ5w_SQi9IPX16f2cJk0OcFZtVwWtHsx.xpNmuO6xKqARcdhyJNhWMmEgTTXxWMpm7d.T&redirect_uri='+redirectUri+'&state='+stateJSON;
			
			} else 	if (IntegrationConstants.INTEGRATION_TYPE_ADSI.equalsIgnoreCase(appName)) {
				try {
					IntegrationService adObj = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_ADSI, null);
					
					if((adObj.appIntegrator == null) || String.isBlank(adObj.appIntegrator.Id)) {
						// Domain not needed for Microsoft API (Azure API would need it).
						IntegrationService.createAppIntegration(IntegrationConstants.INTEGRATION_TYPE_ADSI, IntegrationConstants.ADSI_CLIENT_ID, IntegrationConstants.ADSI_CLIENT_SECRET, null);	
					} else {
						IntegrationService.updateADIntegRecords(IntegrationConstants.INTEGRATION_TYPE_ADSI, IntegrationConstants.ADSI_CLIENT_ID, IntegrationConstants.ADSI_CLIENT_SECRET);
					}

					String appConfigQuery = 'SELECT Id, AD_Integration_Enabled__c FROM App_Config__c limit 1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
					
					if(appConfigList != null && !appConfigList.isEmpty()){
						appConfigList[0].AD_Integration_Enabled__c = true;

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	        			SIMPESAPI.accessController().updateAsUser(appConfigList[0], new List<Schema.SObjectField>{
																	App_Config__c.AD_Integration_Enabled__c}); 
					}
				} catch (Exception e) {
					throw new SimpplrException(e.getMessage());
				}
				redirectUrl = (new IntegrationService('adsi', null)).getAuthPage();

			} else 	if (IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY.equalsIgnoreCase(appName)) {
				try {
					IntegrationService adObj = new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY, null);
					
					if((adObj.appIntegrator == null) || String.isBlank(adObj.appIntegrator.Id)) {
						// Domain not needed for Microsoft API (Azure API would need it).
						IntegrationService.createAppIntegration(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY, 'clientId', 'ClientSecret', null);	
					}

					String appConfigQuery = 'SELECT Id, AD_Integration_Enabled__c FROM App_Config__c limit 1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
					
					if(appConfigList != null && !appConfigList.isEmpty()){
						appConfigList[0].AD_Integration_Enabled__c = true;

						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	        			SIMPESAPI.accessController().updateAsUser(appConfigList[0], new List<Schema.SObjectField>{
																	App_Config__c.AD_Integration_Enabled__c}); 
					}
				} catch (Exception e) {
					throw new SimpplrException(e.getMessage());
				}

				redirectUrl = (new IntegrationService('activedirectory', null)).getAuthPage(true);

			} else if('smartsearch'.equalsIgnoreCase(appName)) {
				redirectUrl = SimpplrContext.salesforceBaseUrl+'/services/oauth2/authorize?'+
                                           'response_type=code&'+
                                           'client_id=3MVG9xOCXq4ID1uEnQ5w_SQi9IMao6V_xPDZAIXBvWde9A2ad9Bi25N7wBDRLz8OplzCX3Ew6D8omR4X6fSP2'+
                                           '&redirect_uri='+ EncodingUtil.urlEncode(SimpplrContext.simpplrAPIEndpoint + '/oauth/callback', 'UTF-8') +
										   '&state='+EncodingUtil.urlEncode(PageContext.getPageURL(Pages.ConnectExternalApp), 'UTF-8')+'%3ForgId%3D'+UserInfo.getOrganizationId();
			
			} else if (IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN.equalsIgnoreCase(appName)) {
				redirectUrl = new AtlassianHelper().getAdminAuthUrl();
				
			} else {
				
				throw new SimpplrException('Unable to perform action.');
			}

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        	responseWrapperObj.redirectUrl = redirectUrl;
        }catch(Exception e){
        	logger.logError('SettingDataServer.connectApp()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('SettingDataServer.connectApp()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

	@TestVisible 
	private ResponseWrapper getUKGUserFieldConfig(){
		logger.logDebug('SettingDataServer.getUKGUserFieldConfig()');
        ResponseWrapper responseWrapperObj = null;

		try {
            ManageApplicationWrapper.UKGUserFieldConfig userFieldConfigWrapObj = new ManageApplicationWrapper.UKGUserFieldConfig();
			userFieldConfigWrapObj = new ManageApplicationDao().getUKGUserFieldConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, userFieldConfigWrapObj);

		}catch (Exception e) {
        	String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;
        	logger.logError('SettingDataServer.getUKGUserFieldConfig()----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);			
        }
		return responseWrapperObj;
		
    }

	
	/**
	 * @description fetch ListenerSuite Configuration
	 * @return ResponseWrapper
	 */
	private ResponseWrapper getListenerSuiteSetupConfig() {   
		logger.logDebug('SettingDataServer.getListenerSuiteSetupConfig()');
		ResponseWrapper responseWrapperObj;

		try {
			ManageApplicationWrapper.ListenerSuiteSetupWrapper listenerSuiteSetsWrapObj = new ManageApplicationDao().getListenerSuiteSetupConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listenerSuiteSetsWrapObj);

		}catch(Exception e){
			logger.logError('SettingDataServer.getListenerSuiteSetupConfig()----could not get listenerSuite Config', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}

	/**
	 * @description save ListenerSuite Configuration
	 * @param requestData
	 * @return ResponseWrapper
	 */
	@TestVisible private ResponseWrapper saveListenerSuiteSetupConfig(String requestData){
		logger.logDebug('SettingDataServer.saveListenerSuiteSetupConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
	
		try{
			ManageApplicationWrapper.ListenerSuiteSetupWrapper listenerSuiteSetsWrapObj= (ManageApplicationWrapper.ListenerSuiteSetupWrapper)Json.deserialize(requestData, ManageApplicationWrapper.ListenerSuiteSetupWrapper.class);
			ManageApplicationDao daoObj = new ManageApplicationDao();
			daoObj.saveListenerSuiteSetupConfig(listenerSuiteSetsWrapObj);

			ManageApplicationWrapper.ListenerSuiteSetupWrapper listenerSuiteSetupWrapObj = new ManageApplicationDao().getListenerSuiteSetupConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listenerSuiteSetupWrapObj);
		}catch(Exception e){
			logger.logError('SettingDataServer----could not save listenerSuite data',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}

		return responseWrapperObj;
	}

	/**
	 * @description fetch Recognition Configuration
	 * @return ResponseWrapper
	 */
	private ResponseWrapper getRecognitionSetupConfig() {   
		logger.logDebug('SettingDataServer.getRecognitionSetupConfig()');
		ResponseWrapper responseWrapperObj;

		try {
			ManageApplicationWrapper.RecognitionSetupWrapper recognitionSetupWrapObj = new ManageApplicationDao().getRecognitionSetupConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, recognitionSetupWrapObj);

		}catch(Exception e){
			logger.logError('SettingDataServer.getRecognitionSetupConfig()----could not get listenerSuite Config', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
	}

	/**
	 * @description save Recognition Configuration
	 * @param requestData
	 * @return ResponseWrapper
	 */
	@TestVisible private ResponseWrapper saveRecognitionSetupConfig(String requestData){
		logger.logDebug('SettingDataServer.saveRecognitionSetupConfig()----requestData----'+requestData);
		ResponseWrapper responseWrapperObj = null;
	
		try{
			ManageApplicationWrapper.RecognitionSetupWrapper recognitionSetupWrapObj= (ManageApplicationWrapper.RecognitionSetupWrapper)Json.deserialize(requestData, ManageApplicationWrapper.RecognitionSetupWrapper.class);
			ManageApplicationDao daoObj = new ManageApplicationDao();
			daoObj.saveRecognitionSetupConfig(recognitionSetupWrapObj);

			recognitionSetupWrapObj = new ManageApplicationDao().getRecognitionSetupConfig();
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, recognitionSetupWrapObj);
		}catch(Exception e){
			logger.logError('SettingDataServer----could not save Recognition data',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}

		return responseWrapperObj;
	}

	@TestVisible private ResponseWrapper getGoogleMultiDomainConfig(){
		logger.logDebug('SettingDataServer.getGoogleMultiDomainCofig()');
		ResponseWrapper responseWrapperObj = null;
		try{
			Map<String, String> configMap = new Map<String, String>();
			configMap.put('isGoogleMultiDomainEnabled', String.valueOf(SimpplrContext.isGoogleMultiDomainEnabled));
			configMap.put('googleMultiDomainUpgradeStatus', SimpplrContext.googleMultiDomainUpgradeStatus);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, configMap);
		}
		catch(Exception e){
			logger.logError('SettingDataServer----could not getGoogleMultiDomainCofig',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		return responseWrapperObj;
	}

	@TestVisible private ResponseWrapper startSlackUpgradeFlow() {
		logger.logDebug('SettingDataServer.startSlackUpgradeFlow()------------');
		ResponseWrapper responseWrapperObj = null;
		try {
			SlackHelper slackObj = new SlackHelper();
			ManageApplicationDao daoObj = new ManageApplicationDao();
			Boolean isSuccess = daoObj.processSlackPhase2Upgrade();
			if(isSuccess) {
				Boolean isSlackUnfurlAppInstalled = slackObj.getSlackAppInstalledInfo();
				BatchSlackUpgrade job = new BatchSlackUpgrade('removeSiteConfigs');
            	Database.executeBatch(job, 1000);
				if(isSlackUnfurlAppInstalled) {
					ConnectExternalAppCtrl.clearInstallationDetailFromAWS();
				}
				new SlackHelper().updateDetailsInAppIntegration();
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			} else {
				throw new SimpplrException(LocaleContext.getLabel(UserContext.languageLocaleKey,ERROR_SLACK_UPGRADE));
			}
		} catch (Exception ex){
			logger.logDebug('SettingDataServer----error in upgrading slack---'+ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
		}
		return responseWrapperObj;
	}
	/**
	 * This API will be called from SF-Proxy microservice only when slack app would be removed from workspace.
	 */
	@TestVisible
	private ResponseWrapper disableSlackWhenAppRemovedFromWorkspace(String requestObj) {
		logger.logDebug('SettingDataServer.disableSlackWhenAppRemovedFromWorkspace()---------RequestDate---'+requestObj);
		ResponseWrapper responseWrapperObj = new ResponseWrapper();
		try{
			ManageApplicationWrapper.MessagingIntegrationWrapper integrationObj =(ManageApplicationWrapper.MessagingIntegrationWrapper)Json.deserialize(requestObj, ManageApplicationWrapper.MessagingIntegrationWrapper.class);
			SlackHelper slackHelper = new SlackHelper();
			slackHelper.handleSlackAppDisconnect(integrationObj);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

		} catch(Exception ex) {
			logger.logDebug('SettingDataServer----error in disabling slack---'+ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
		}
		return responseWrapperObj;
	}
}