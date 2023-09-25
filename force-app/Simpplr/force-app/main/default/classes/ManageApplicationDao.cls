/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class ManageApplicationDao{
	private final String SETTINGS_UPDATED = 'Settings are being updated';
	private static final String PERMISSIONSET_ERROR_SUBSTRING = ' permission set does not exists.';
	private static final String UNLISTED_SITE_MANAGERS_PERMISSION_NAME = 'Simpplr_Unlisted_Site_Managers';
    private static final String UNLISTED_SITE_MANAGER_PERMISSION_SET_ERROR = UNLISTED_SITE_MANAGERS_PERMISSION_NAME + PERMISSIONSET_ERROR_SUBSTRING;
    private static final String APP_MANAGERS_PERMISSION_NAME = 'Simpplr_App_Managers';
    private static final String APP_MANAGERS_PERMISSION_SET_ERROR = APP_MANAGERS_PERMISSION_NAME + PERMISSIONSET_ERROR_SUBSTRING;
    private static final String APP_MANAGER_VIEW_ALL_PERMISSION_NAME = 'Simpplr_App_Manager_View_All';
    private static final String ERROR_SOCIAL_CAMPAIGN_ENABLED_WITHOUT_NETWORK = 'manage_app.integration.social_campaign.network_config.flash_warning';
    private static final String ERROR_SOCIAL_CAMPAIGN_ENABLED_WITHOUT_BOTH_KEYS = 'manage_app.integration.social_campaign.client_id_secret.flash_warning';
	private static final String ERROR_SYNCING_DUPLICATE_CUSTOM_FIELD = 'manage_app.people.syncing.add.duplicate_error_flash';
	private static final String ERROR_SYNCING_IN_PROGRESS = 'manage_app.people.syncing.save.processing_error_flash';
	private static final String ERROR_PROVISIONING_IN_PROGRESS = 'manage_app.people.provisioning.save.processing_error_flash';
	private static final String ERROR_UKGPRO_API = 'profile_fields.syncing.ukgpro.api_error_flash';
	private static final String ERROR_AD_SELECTED_GROUP_MINIMUM_COUNT = 'manage_app.integrations.active_directory.selected_count.flash_warning';
	public final String UKGPRO_USERNAME = 'manage_app.integrations.people.ukgpro.username.label';
	public final String UKGPRO_PASSWORD = 'manage_app.integrations.people.ukgpro.password.label';
	public final String UKGPRO_APIKEY = 'manage_app.integrations.people.ukgpro.api_key.label';
	public final String UKGPRO_BASE_URL = 'manage_app.integrations.people.ukgpro.base_url.label';
	private static final String ERROR_DOMAIN_TO_DELETE_ONLY_ONE_APP_DOMAIN_ALLOWED = 'manage_app.integrations.domains.remove.multiple_apps.invalid_error_flash';
	private static final String ERROR_DOMAIN_TO_ADD_ONLY_ONE_DOMAIN_ALLOWED = 'manage_app.integrations.domains.add.multiple_domains.invalid_error_flash';
	private static final String ERROR_DOMAIN_TO_DELETE_ONLY_ONE_DOMAIN_ALLOWED = 'manage_app.integrations.domains.remove.multiple_domains.invalid_error_flash';
	private static final String ERROR_DOMAIN_TO_DELETE_DOES_NOT_EXIST = 'manage_app.integrations.domains.remove.missing_error_flash';
	private static final String ERROR_DOMAIN_TO_ADD_ALREADY_EXISTS = 'manage_app.integrations.domains.domain_list.duplicate_domain_error';
	private static final String BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION = 'removeDomainPeopleIntegration';
	private static final String ERROR_GOOGLE_MULTI_INSTANCE_UPGRADE_ALREADY_DONE = 'manage_app.integrations.file_management.upgrade.invalid_error_flash';
	private static final String ERROR_DOMAIN_CONFIG_NOT_SETUP = 'manage_app.integrations.domains.setup.missing_config_error_flash';

	public ManageApplicationWrapper.AppConfigEmailWrapper populateAppConfigEmailWrapper() {
    	
    	ManageApplicationWrapper.AppConfigEmailWrapper emailSettings = new ManageApplicationWrapper.AppConfigEmailWrapper();
    	String profilesNotReceiveEmails;
		emailSettings.enableEmail = SimpplrContext.enableEmail!=null? SimpplrContext.enableEmail : false;
		emailSettings.enableTopStoriesEmails = SimpplrContext.enableTopStoriesEmails != null? SimpplrContext.enableTopStoriesEmails : false;
		
		if(String.isNotBlank(SimpplrContext.SEDFromEmail)){
			emailSettings.emailSender = SimpplrContext.SEDFromEmail;
		}
		
		if(SimpplrContext.chatterEmailOffForProfiles!=null){
			emailSettings.profilesNotReceiveEmails.addAll(SimpplrContext.chatterEmailOffForProfiles);
			for(String s : emailSettings.profilesNotReceiveEmails){
	    		profilesNotReceiveEmails += s + ',';
	    	}
		}
		
		emailSettings.chatterEmails = SimpplrContext.chatterEmails; 
		FilterService serviceObj = new FilterService();
		emailSettings.availableSenders = serviceObj.getOrgWideEmailsForFilters();
		emailSettings.availableProfiles = serviceObj.getAllProfilesListForFilters();

		return emailSettings;
    }
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void saveGeneralPeopleConfig(ManageApplicationWrapper.GeneralPeopleWrapper genPeopleObj) {
		String appConfigQuery = 'SELECT id, People_Category_Enabled__c,People_Catgeory_Singular__c, People_Catgeory_Plural__c,'
										+ ' Auto_provisioning_Process_Enabled__c, Auto_Free_Simpplr_License_Enabled__c, Last_Edited_DateTime__c'
										+ ' FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
										
		App_Config__c apConfigObj = listOfAppConfig[0];
		if(genPeopleObj.peopleCategoryEnabled){
			apConfigObj.People_Catgeory_Plural__c = genPeopleObj.peopleCategoryPlural;
    		apConfigObj.People_Catgeory_Singular__c = genPeopleObj.peopleCategorySingular;
			apConfigObj.Last_Edited_DateTime__c = DateTime.now();
		} else if(apConfigObj.People_Category_Enabled__c == true && isPeopleCategoryUsedForAudience() == true) {
			throw new SimpplrException(ServiceConstants.SF_EXCEPTION);
		}
		
		apConfigObj.People_Category_Enabled__c = genPeopleObj.peopleCategoryEnabled;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(apConfigObj, new List<Schema.SObjectField>{
																							App_Config__c.People_Category_Enabled__c,
																							App_Config__c.People_Catgeory_Plural__c,
																							App_Config__c.People_Catgeory_Singular__c,
																							App_Config__c.Last_Edited_DateTime__c
																							});
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public static void saveUserSyncingPeopleConfig(ManageApplicationWrapper.UserSyncingPeopleWrapper userSyncPeopleObj) {
    	String appConfigQuery = 'Select Id, PDS_Title__c, PDS_First_Name__c, PDS_Last_Name__c, PDS_About_Me__c, PDS_Email__c, PDS_Birth_Date__c, '
									+ ' PDS_Joining_Date_Key__c, PDS_Birth_Date_Key__c, PDS_Company_Name_Key__c, PDS_User_Division_Key__c, PDS_Federation_Id__c, '
									+ ' PDS_Employee_Number__c, PDS_Department__c, PDS_Division__c, PDS_Street__c, PDS_City__c, PDS_State__c, PDS_Country__c, '
									+ ' PDS_Street_Key__c, PDS_City_Key__c, PDS_State_Key__c, PDS_Country_Key__c, PDS_Postal_Code_Key__c, '
									+ ' PDS_Community_Nickname__c, PDS_Joining_Date__c, PDS_Manager_Id__c, PDS_Company_Name__c, PDS_Extension__c, PDS_Fax__c, '
									+ ' PDS_Mobile_Phone__c, PDS_Phone__c, PDS_Postal_Code__c, PDS_Role__c, PDS_Middle_Name__c, PDS_Enable_Formatting__c, '
									+ ' PDS_Unique_Identifier__c, PDS_Max_Sync_Attempts__c, PDS_Source_Application__c, PDS_Photo__c, AD_Integration_Enabled__c, PDS_Query_Filter__c, '
									+ ' PDS_Manager_Unique_Identifier_Key__c, PP_User_Custom_Fields__c, Last_Edited_DateTime__c, Ad_Delta_Token__c, PDS_Department_Key__c from App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
												
		List<String> fieldListToEmpty = new List<String>();									  
		if(!listOfAppConfig.isEmpty()) {
    		App_Config__c apConfigObj = listOfAppConfig[0];
			
			
			String oldSyncSource = apConfigObj.PDS_Source_Application__c;
			apConfigObj.PDS_Source_Application__c = userSyncPeopleObj.syncSource;
			apConfigObj.Last_Edited_DateTime__c = DateTime.now();
			if('None'.equalsIgnoreCase(userSyncPeopleObj.syncSource) == false) {
				apConfigObj.PDS_Enable_Formatting__c = (userSyncPeopleObj.enableFormatting == null) ? apConfigObj.PDS_Enable_Formatting__c : userSyncPeopleObj.enableFormatting;
				apConfigObj.PDS_First_Name__c = (userSyncPeopleObj.firstName == null) ? apConfigObj.PDS_First_Name__c : userSyncPeopleObj.firstName;
				apConfigObj.PDS_Middle_Name__c = (userSyncPeopleObj.middleName == null) ? apConfigObj.PDS_Middle_Name__c : userSyncPeopleObj.middleName;
				apConfigObj.PDS_Last_Name__c = (userSyncPeopleObj.lastName == null) ? apConfigObj.PDS_Last_Name__c : userSyncPeopleObj.lastName;
				apConfigObj.PDS_Title__c = (userSyncPeopleObj.userTitle == null) ? apConfigObj.PDS_Title__c : userSyncPeopleObj.userTitle;
				apConfigObj.PDS_Birth_Date__c = (userSyncPeopleObj.birthDate == null) ? apConfigObj.PDS_Birth_Date__c : userSyncPeopleObj.birthDate;
				apConfigObj.PDS_Email__c = (userSyncPeopleObj.userEmail == null) ? apConfigObj.PDS_Email__c : userSyncPeopleObj.userEmail;
				apConfigObj.PDS_Community_Nickname__c = (userSyncPeopleObj.communityNickname == null) ? apConfigObj.PDS_Community_Nickname__c : userSyncPeopleObj.communityNickname;
				apConfigObj.PDS_About_Me__c = (userSyncPeopleObj.aboutMe == null) ? apConfigObj.PDS_About_Me__c : userSyncPeopleObj.aboutMe;
				apConfigObj.PDS_Employee_Number__c = (userSyncPeopleObj.employeeNumber == null) ? apConfigObj.PDS_Employee_Number__c : userSyncPeopleObj.employeeNumber;
				apConfigObj.PDS_Manager_Id__c = (userSyncPeopleObj.manager == null) ? apConfigObj.PDS_Manager_Id__c : userSyncPeopleObj.manager;
				apConfigObj.PDS_Department__c = (userSyncPeopleObj.department == null) ? apConfigObj.PDS_Department__c : userSyncPeopleObj.department;
				apConfigObj.PDS_Division__c = (userSyncPeopleObj.userDivision == null) ? apConfigObj.PDS_Division__c : userSyncPeopleObj.userDivision;
				apConfigObj.PDS_Company_Name__c = (userSyncPeopleObj.companyName == null) ? apConfigObj.PDS_Company_Name__c : userSyncPeopleObj.companyName;
				apConfigObj.PDS_Joining_Date__c = (userSyncPeopleObj.joiningDate == null) ? apConfigObj.PDS_Joining_Date__c : userSyncPeopleObj.joiningDate;
				apConfigObj.PDS_Role__c = (userSyncPeopleObj.userRole == null) ? apConfigObj.PDS_Role__c : userSyncPeopleObj.userRole;
				apConfigObj.PDS_Street__c = (userSyncPeopleObj.street == null) ? apConfigObj.PDS_Street__c : userSyncPeopleObj.street;
				apConfigObj.PDS_Postal_Code__c = (userSyncPeopleObj.postalCode == null) ? apConfigObj.PDS_Postal_Code__c : userSyncPeopleObj.postalCode;
				apConfigObj.PDS_City__c = (userSyncPeopleObj.city == null) ? apConfigObj.PDS_City__c : userSyncPeopleObj.city;
				apConfigObj.PDS_State__c = (userSyncPeopleObj.state == null) ? apConfigObj.PDS_State__c : userSyncPeopleObj.state;
				apConfigObj.PDS_Country__c = (userSyncPeopleObj.country == null) ? apConfigObj.PDS_Country__c : userSyncPeopleObj.country;
				apConfigObj.PDS_Phone__c = (userSyncPeopleObj.phone == null) ? apConfigObj.PDS_Phone__c : userSyncPeopleObj.phone;
				apConfigObj.PDS_Extension__c = (userSyncPeopleObj.extension == null) ? apConfigObj.PDS_Extension__c : userSyncPeopleObj.extension;
				apConfigObj.PDS_Mobile_Phone__c = (userSyncPeopleObj.mobilePhone == null) ? apConfigObj.PDS_Mobile_Phone__c : userSyncPeopleObj.mobilePhone;
				apConfigObj.PDS_Fax__c = (userSyncPeopleObj.fax == null) ? apConfigObj.PDS_Fax__c : userSyncPeopleObj.fax;
				apConfigObj.PDS_Photo__c = (userSyncPeopleObj.photo == null) ? apConfigObj.PDS_Photo__c : userSyncPeopleObj.photo;
				apConfigObj.PDS_Joining_Date_Key__c = userSyncPeopleObj.joiningDateKey;
				apConfigObj.PDS_Company_Name_Key__c = userSyncPeopleObj.companyNameKey;
				apConfigObj.PDS_Federation_Id__c = (userSyncPeopleObj.federationId == null) ? apConfigObj.PDS_Federation_Id__c : userSyncPeopleObj.federationId;
				apConfigObj.PDS_Query_Filter__c = userSyncPeopleObj.queryFilter;				
				apConfigObj.PDS_Manager_Id__c = (userSyncPeopleObj.manager == null) ? apConfigObj.PDS_Manager_Id__c : userSyncPeopleObj.manager;
				if('UkgPro'.equalsIgnoreCase(userSyncPeopleObj.syncSource)) { 
					userSyncPeopleObj.uniqueIdentifier = (userSyncPeopleObj.uniqueIdentifier == null) ? 'email' : userSyncPeopleObj.uniqueIdentifier;
					apConfigObj.PDS_Unique_Identifier__c = userSyncPeopleObj.uniqueIdentifier;
					apConfigObj.PDS_Birth_Date_Key__c = userSyncPeopleObj.ukgProBirthDateKey;
					apConfigObj.PDS_User_Division_Key__c = userSyncPeopleObj.ukgProUserDivisionKey;
					apConfigObj.PDS_Department_Key__c = userSyncPeopleObj.ukgProDepartmentKey;
					
				} else {
					apConfigObj.PDS_Unique_Identifier__c = userSyncPeopleObj.uniqueIdentifier;
					apConfigObj.PDS_Birth_Date_Key__c = userSyncPeopleObj.birthDateKey;
                	apConfigObj.PDS_User_Division_Key__c = userSyncPeopleObj.userDivisionKey;
					apConfigObj.PDS_Department_Key__c = null;
				}
				if('Google'.equalsIgnoreCase(userSyncPeopleObj.syncSource)){
					if(userSyncPeopleObj.streetKey != null && 'custom'.equalsIgnoreCase(userSyncPeopleObj.streetKey)){
						apConfigObj.PDS_Street_Key__c = (userSyncPeopleObj.streetNamekey == null) ? apConfigObj.PDS_Street_Key__c : userSyncPeopleObj.streetNamekey;
					} else if(userSyncPeopleObj.streetKey != null && 'standard'.equalsIgnoreCase(userSyncPeopleObj.streetKey)){
						apConfigObj.PDS_Street_Key__c = '';
					} 
					if(userSyncPeopleObj.cityKey != null && 'custom'.equalsIgnoreCase(userSyncPeopleObj.cityKey)){
						apConfigObj.PDS_City_Key__c = (userSyncPeopleObj.cityNameKey == null) ? apConfigObj.PDS_City_Key__c : userSyncPeopleObj.cityNameKey;
					} else if(userSyncPeopleObj.cityKey != null && 'standard'.equalsIgnoreCase(userSyncPeopleObj.cityKey)){
						apConfigObj.PDS_City_Key__c = '';
					}
					if(userSyncPeopleObj.stateKey != null && 'custom'.equalsIgnoreCase(userSyncPeopleObj.stateKey)){
						apConfigObj.PDS_State_Key__c = (userSyncPeopleObj.stateNameKey == null) ? apConfigObj.PDS_State_Key__c : userSyncPeopleObj.stateNameKey;
					} else if(userSyncPeopleObj.stateKey != null && 'standard'.equalsIgnoreCase(userSyncPeopleObj.stateKey)){
						apConfigObj.PDS_State_Key__c = '';
					} 
					if(userSyncPeopleObj.countryKey != null && 'custom'.equalsIgnoreCase(userSyncPeopleObj.countryKey)){
						apConfigObj.PDS_Country_Key__c = (userSyncPeopleObj.countryNameKey == null) ? apConfigObj.PDS_Country_Key__c : userSyncPeopleObj.countryNameKey;
					} else if(userSyncPeopleObj.countryKey != null && 'standard'.equalsIgnoreCase(userSyncPeopleObj.countryKey)){
						apConfigObj.PDS_Country_Key__c = '';
					} 
					if(userSyncPeopleObj.postalCodeKey != null && 'custom'.equalsIgnoreCase(userSyncPeopleObj.postalCodeKey)){
						apConfigObj.PDS_Postal_Code_Key__c = (userSyncPeopleObj.postalCodeNameKey == null) ? apConfigObj.PDS_Postal_Code_Key__c : userSyncPeopleObj.postalCodeNameKey;
					} else if(userSyncPeopleObj.postalCodeKey != null && 'standard'.equalsIgnoreCase(userSyncPeopleObj.postalCodeKey)){
						apConfigObj.PDS_Postal_Code_Key__c = '';
					}
				}
				
				apConfigObj.PDS_Manager_Unique_Identifier_Key__c = userSyncPeopleObj.uniqueIdentifier;
				Map<String, CustomProfileField> newfieldMap = new Map<String, CustomProfileField>();
				if(userSyncPeopleObj.additionalFields != null) {
					for(CustomProfileField customField : userSyncPeopleObj.additionalFields) {
						// check for duplicate names
						if(newfieldMap.containsKey(customField.fieldName) == false){
							newfieldMap.put(customField.fieldName, customField);

						} else {
							// throw exception
							throw new SimpplrException(LocaleContext.getLabel(UserContext.languageLocaleKey, ERROR_SYNCING_DUPLICATE_CUSTOM_FIELD));

						}
					}
					String jsonString = String.isBlank(apConfigObj.PP_User_Custom_Fields__c) ? '[]' : apConfigObj.PP_User_Custom_Fields__c;
					List<CustomProfileField> updatedAdditionalFields = new List<CustomProfileField>();
					List<CustomProfileField> oldAdditionalFields = (List<CustomProfileField>)
													Json.deserialize(jsonString, Type.forName('List<CustomProfileField>'));
										
					List<String> columnNames = new List<String>{	'Custom_Field_1__c', 'Custom_Field_2__c', 'Custom_Field_3__c',
																'Custom_Field_4__c', 'Custom_Field_5__c', 'Custom_Field_6__c',
																'Custom_Field_7__c', 'Custom_Field_8__c', 'Custom_Field_9__c',
																'Custom_Field_10__c', 'Custom_Field_11__c', 'Custom_Field_12__c',
																'Custom_Field_13__c', 'Custom_Field_14__c', 'Custom_Field_15__c',
																'Custom_Field_16__c', 'Custom_Field_17__c', 'Custom_Field_18__c',
																'Custom_Field_19__c', 'Custom_Field_20__c', 'Custom_Field_21__c',
																'Custom_Field_22__c', 'Custom_Field_23__c', 'Custom_Field_24__c',
																'Custom_Field_25__c'
															 };
					Map<String, String> csvFieldNameToColumnName = new Map<String, String> {
																	'custom_field_1' => 'Custom_Field_1__c', 'custom_field_2' => 'Custom_Field_2__c',
																	'custom_field_3' => 'Custom_Field_3__c', 'custom_field_4' => 'Custom_Field_4__c',
																	'custom_field_5' => 'Custom_Field_5__c', 'custom_field_6' => 'Custom_Field_6__c', 
																	'custom_field_7' => 'Custom_Field_7__c', 'custom_field_8' => 'Custom_Field_8__c',
																	'custom_field_9' => 'Custom_Field_9__c', 'custom_field_10' => 'Custom_Field_10__c',
																	'custom_field_11' => 'Custom_Field_11__c', 'custom_field_12' => 'Custom_Field_12__c',
																	'custom_field_13' => 'Custom_Field_13__c', 'custom_field_14' => 'Custom_Field_14__c',
																	'custom_field_15' => 'Custom_Field_15__c', 'custom_field_16' => 'Custom_Field_16__c',
																	'custom_field_17' => 'Custom_Field_17__c', 'custom_field_18' => 'Custom_Field_18__c',
																	'custom_field_19' => 'Custom_Field_19__c', 'custom_field_20' => 'Custom_Field_20__c',
																	'custom_field_21' => 'Custom_Field_21__c', 'custom_field_22' => 'Custom_Field_22__c',
																	'custom_field_23' => 'Custom_Field_23__c', 'custom_field_24' => 'Custom_Field_24__c',
																	'custom_field_25' => 'Custom_Field_25__c'
																};
					for(CustomProfileField existingCustomField : oldAdditionalFields) {
						if(String.isBlank(existingCustomField.syncSource)) {
							updatedAdditionalFields.add(existingCustomField);

						} else if(newfieldMap.containsKey(existingCustomField.fieldName)) {
							CustomProfileField additionalField = newfieldMap.get(existingCustomField.fieldName);
							additionalField.syncSource = userSyncPeopleObj.syncSource.toLowerCase();
							if(!'CsvFile'.equalsIgnoreCase(userSyncPeopleObj.syncSource)){ 	
								if(String.isBlank(additionalField.columnName)) {							
									additionalField.columnName = existingCustomField.columnName;
									additionalField.onOff = true;
									additionalField.isEditable = false;
									additionalField.itemOrder = existingCustomField.itemOrder;
								}
								columnNames.remove(columnNames.indexOf(existingCustomField.columnName));
								
							} else if(String.isBlank(additionalField.columnName)) {
								continue;
							}
							newfieldMap.remove(additionalField.fieldName);
							updatedAdditionalFields.add(additionalField);					

						} else {
							fieldListToEmpty.add(existingCustomField.columnName);
						}
					}
					Integer itemOrder = updatedAdditionalFields.size();
					for(CustomProfileField newCustomField : newfieldMap.values()) {
						newCustomField.syncSource = userSyncPeopleObj.syncSource.toLowerCase();
						newCustomField.onOff = true;
						newCustomField.isEditable = false;
						newCustomField.itemOrder = itemOrder++;
						if('CsvFile'.equalsIgnoreCase(userSyncPeopleObj.syncSource)){ 
							newCustomField.columnName = csvFieldNameToColumnName.get(newCustomField.fieldName);
						} else {
							newCustomField.columnName = columnNames[0];
							columnNames.remove(0);
						}
						updatedAdditionalFields.add(newCustomField);
					}
					apConfigObj.PP_User_Custom_Fields__c = JSON.serialize(updatedAdditionalFields);
				}				
	
			} else {
				apConfigObj.PDS_First_Name__c = false;
				apConfigObj.PDS_Last_Name__c = false;
				apConfigObj.PDS_Title__c = false;
				apConfigObj.PDS_Birth_Date__c = false;
				apConfigObj.PDS_Email__c = false;
				apConfigObj.PDS_Community_Nickname__c = false;
				apConfigObj.PDS_About_Me__c = false;
				apConfigObj.PDS_Employee_Number__c = false;
				apConfigObj.PDS_Manager_Id__c = false;
				apConfigObj.PDS_Department__c = false;
				apConfigObj.PDS_Division__c = false;
				apConfigObj.PDS_Company_Name__c = false;
				apConfigObj.PDS_Joining_Date__c = false;
				apConfigObj.PDS_Role__c = false;
				apConfigObj.PDS_Street__c = false;
				apConfigObj.PDS_Postal_Code__c = false;
				apConfigObj.PDS_City__c = false;
				apConfigObj.PDS_State__c = false;
				apConfigObj.PDS_Country__c = false;
				apConfigObj.PDS_Phone__c = false;
				apConfigObj.PDS_Extension__c = false;
				apConfigObj.PDS_Mobile_Phone__c = false;
				apConfigObj.PDS_Fax__c = false;
				apConfigObj.PDS_Photo__c = false;
				apConfigObj.PDS_Joining_Date_Key__c = null;
				apConfigObj.PDS_Birth_Date_Key__c = null;
				apConfigObj.PDS_Company_Name_Key__c = null;
				apConfigObj.PDS_User_Division_Key__c = null;
				apConfigObj.PDS_Department_Key__c = null;
				apConfigObj.PDS_Federation_Id__c = false;
				apConfigObj.PDS_Query_Filter__c = null;
				apConfigObj.PDS_Unique_Identifier__c = null;
				apConfigObj.PDS_Manager_Unique_Identifier_Key__c = null;
				List<CustomProfileField> updatedAdditionalFields = new List<CustomProfileField>();
				String jsonString = String.isBlank(apConfigObj.PP_User_Custom_Fields__c) ? '[]' : apConfigObj.PP_User_Custom_Fields__c;
				List<CustomProfileField> oldAdditionalFields = (List<CustomProfileField>)
													Json.deserialize(jsonString, Type.forName('List<CustomProfileField>'));
				for(CustomProfileField existingCustomField : oldAdditionalFields) {
					if(String.isBlank(existingCustomField.syncSource)) {
						updatedAdditionalFields.add(existingCustomField);
					} else {
						fieldListToEmpty.add(existingCustomField.columnName);
					}
				}
				apConfigObj.PP_User_Custom_Fields__c = JSON.serialize(updatedAdditionalFields);
			}
			
			// Do not clear the flag when Active directory is the old as well as the new source.
			if(('ActiveDirectory'.equalsIgnoreCase(oldSyncSource) == false) || ('ActiveDirectory'.equalsIgnoreCase(userSyncPeopleObj.syncSource) == false)){
				apConfigObj.Ad_Delta_Token__c = '';
			}
			if('UkgPro'.equalsIgnoreCase(userSyncPeopleObj.syncSource)) { 
				sendUkgProSyncingInfoToAWS(userSyncPeopleObj);
			}
			if('CsvFile'.equalsIgnoreCase(userSyncPeopleObj.syncSource)){ 
				sendSpsSyncingInfoToAWS(userSyncPeopleObj);

			} else if('CsvFile'.equalsIgnoreCase(oldSyncSource) && !'CsvFile'.equalsIgnoreCase(userSyncPeopleObj.syncSource)) {
				sendSpsSyncingInfoToAWS(null);
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(apConfigObj,new List<Schema.SObjectField>{App_Config__c.PDS_Source_Application__c,
																								App_Config__c.PDS_First_Name__c,
																								App_Config__c.PDS_Middle_Name__c,
																								App_Config__c.PDS_Last_Name__c,
																								App_Config__c.PDS_Title__c,
																								App_Config__c.PDS_Birth_Date__c,
																								App_Config__c.PDS_Email__c,
																								App_Config__c.PDS_Community_Nickname__c,
																								App_Config__c.PDS_About_Me__c,
																								App_Config__c.PDS_Employee_Number__c,
																								App_Config__c.PDS_Manager_Id__c,
																								App_Config__c.PDS_Department__c,
																								App_Config__c.PDS_Division__c,
																								App_Config__c.PDS_Company_Name__c,
																								App_Config__c.PDS_Joining_Date__c,
																								App_Config__c.PDS_Role__c,
																								App_Config__c.PDS_Street__c,
																								App_Config__c.PDS_Postal_Code__c,
																								App_Config__c.PDS_City__c,
																								App_Config__c.PDS_State__c,
																								App_Config__c.PDS_Country__c,
																								App_Config__c.PDS_Phone__c,
																								App_Config__c.PDS_Extension__c,
																								App_Config__c.PDS_Mobile_Phone__c,
																								App_Config__c.PDS_Fax__c,
																								App_Config__c.PDS_Photo__c,
																								App_Config__c.PDS_Max_Sync_Attempts__c,
																								App_Config__c.PDS_Enable_Formatting__c,
																								App_Config__c.PP_User_Custom_Fields__c,
																								App_Config__c.Last_Edited_DateTime__c,
																								App_Config__c.PDS_Joining_Date_Key__c,
																								App_Config__c.PDS_Birth_Date_Key__c,
																								App_Config__c.Ad_Delta_Token__c,
																								App_Config__c.PDS_Company_Name_Key__c,
																								App_Config__c.PDS_User_Division_Key__c,
																								App_Config__c.PDS_Department_Key__c,
																								App_Config__c.PDS_Federation_Id__c,
																								App_Config__c.PDS_Query_Filter__c,
																								App_Config__c.PDS_Unique_Identifier__c,
																								App_Config__c.PDS_Manager_Unique_Identifier_Key__c,
																								App_Config__c.PDS_Street_Key__c,
																								App_Config__c.PDS_City_Key__c,
																								App_Config__c.PDS_State_Key__c,
																								App_Config__c.PDS_Country_Key__c,
																								App_Config__c.PDS_Postal_Code_Key__c
																								});  

			if(!fieldListToEmpty.isEmpty()){
				BatchUpdatePeopleRecords job = new BatchUpdatePeopleRecords('clearCustomFields', fieldListToEmpty);
				Database.executeBatch(job, 1000);
			}
			if(('Okta'.equalsIgnoreCase(oldSyncSource) && 'Okta'.equalsIgnoreCase(userSyncPeopleObj.syncSource) == false) || 
						('ActiveDirectory'.equalsIgnoreCase(oldSyncSource) && 'ActiveDirectory'.equalsIgnoreCase(userSyncPeopleObj.syncSource) == false ) ||
						('Google'.equalsIgnoreCase(oldSyncSource) && 'Google'.equalsIgnoreCase(userSyncPeopleObj.syncSource) == false )){
				
				BatchUpdatePeopleRecords job = new BatchUpdatePeopleRecords('clearSyncField', null);
				Database.executeBatch(job, 1000);

			}
			
			// create audit trail
			auditUserSyncProvSource(true, userSyncPeopleObj.syncSource, oldSyncSource);
    	}
	}
	// Save User Provisioning
	public static void saveUserProvisioningConfig(ManageApplicationWrapper.UserProvisioningWrapper userProvisioningObj) {

		String query = 'SELECT Id, Provisioning_Source__c, Query_Filter__c, ' +
			' Birthdate_Field__c,Birthdate__c,City__c, Company_Name_Field__c, ' +
			' Company_Name__c, Country__c, Create_New_Users__c, Deactive_User__c,Department__c, ' +
			' Employee_Number__c,Fax__c,FedrationId__c,Firstname__c,Joining_Date_Field__c, ' +
			' Joining_Date__c,Lastname__c,Manager__c,MobilePhone__c,Phone__c,PostalCode__c, ' +
			' Profile_Type__c, Profile__c,State__c,Street__c,TimezoneSidKey__c,Timezone__c, ' +
			' Username_Suffix__c,Username__c,User_Email__c,User_Title__c, ' +
			' Street_Field__c, City_Field__c, State_Field__c, Country_Field__c, Postal_Code_Field__c, ' +
			' Locale__c, Locale_Type__c, Language__c, Language_Type__c, PhoneExtension__c, Send_Emails__c, ' +
			' About__c,Division__c,Manager_Unique_Identifier__c, User_Deprovisioning_Identifier__c ' +
			' FROM User_Provisioning_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<User_Provisioning_Config__c> listOfUserProvisionConfig = (List<User_Provisioning_Config__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		
		List<String> fieldListToEmpty = new List<String>();	
		String oldUserProvisioning = 'None';
		User_Provisioning_Config__c userProvisionConfigObj;
		if(!listOfUserProvisionConfig.isEmpty()) {
			userProvisionConfigObj = listOfUserProvisionConfig[0];
			oldUserProvisioning = listOfUserProvisionConfig[0].Provisioning_Source__c;
		} else {
			userProvisionConfigObj = new User_Provisioning_Config__c();
		}		
		if('None'.equalsIgnoreCase(userProvisioningObj.provisioningSource) == false) {
			userProvisionConfigObj.Provisioning_Source__c = userProvisioningObj.provisioningSource;			  
			userProvisionConfigObj.Query_Filter__c = userProvisioningObj.queryFilter;
			userProvisionConfigObj.Create_New_Users__c = (userProvisioningObj.createNewUser == null) ? userProvisionConfigObj.Create_New_Users__c : Boolean.valueOf(userProvisioningObj.createNewUser);
			
			if(userProvisionConfigObj.Create_New_Users__c){
				userProvisionConfigObj.Profile__c = true;
				userProvisionConfigObj.Profile_Type__c = (userProvisioningObj.profileType == null) ? userProvisionConfigObj.Profile_Type__c : userProvisioningObj.profileType;
				userProvisionConfigObj.Username__c = (userProvisioningObj.username == null) ? userProvisionConfigObj.Username__c : userProvisioningObj.username;
				userProvisionConfigObj.Username_Suffix__c = userProvisioningObj.usernameSuffix;
				userProvisionConfigObj.Firstname__c = (userProvisioningObj.firstName == null) ? userProvisionConfigObj.Firstname__c : userProvisioningObj.firstName;
				userProvisionConfigObj.Lastname__c = true;
				userProvisionConfigObj.User_Title__c = (userProvisioningObj.userTitle == null) ? userProvisionConfigObj.User_Title__c : userProvisioningObj.userTitle;
				userProvisionConfigObj.Birthdate__c = (userProvisioningObj.birthDate == null) ? userProvisionConfigObj.Birthdate__c : userProvisioningObj.birthDate;
				userProvisionConfigObj.Birthdate_Field__c = (userProvisioningObj.birthDateField == null) ? userProvisionConfigObj.Birthdate_Field__c : userProvisioningObj.birthDateField;
				userProvisionConfigObj.Joining_Date__c = (userProvisioningObj.joiningDate == null) ? userProvisionConfigObj.Joining_Date__c : userProvisioningObj.joiningDate;
				userProvisionConfigObj.Joining_Date_Field__c = (userProvisioningObj.joiningDateField == null) ? userProvisionConfigObj.Joining_Date_Field__c : userProvisioningObj.joiningDateField;
				userProvisionConfigObj.Company_Name__c = (userProvisioningObj.companyName == null) ? userProvisionConfigObj.Company_Name__c : userProvisioningObj.companyName;
				userProvisionConfigObj.Company_Name_Field__c = (userProvisioningObj.companyNameField == null) ? userProvisionConfigObj.Company_Name_Field__c : userProvisioningObj.companyNameField;
				userProvisionConfigObj.Department__c = (userProvisioningObj.department == null) ? userProvisionConfigObj.Department__c : userProvisioningObj.department;
				userProvisionConfigObj.Manager__c = (userProvisioningObj.manager == null) ? userProvisionConfigObj.Manager__c : userProvisioningObj.manager;
				userProvisionConfigObj.Employee_Number__c = (userProvisioningObj.employeeNumber == null) ? userProvisionConfigObj.Employee_Number__c : userProvisioningObj.employeeNumber;
				userProvisionConfigObj.FedrationId__c = (userProvisioningObj.federationId == null) ? userProvisionConfigObj.FedrationId__c : userProvisioningObj.federationId;
				userProvisionConfigObj.Phone__c = (userProvisioningObj.phone == null) ? userProvisionConfigObj.Phone__c : userProvisioningObj.phone;
				userProvisionConfigObj.MobilePhone__c = (userProvisioningObj.mobilePhone == null) ? userProvisionConfigObj.MobilePhone__c : userProvisioningObj.mobilePhone;
				userProvisionConfigObj.User_Email__c = (userProvisioningObj.userEmail == null) ? userProvisionConfigObj.User_Email__c : userProvisioningObj.userEmail;
				userProvisionConfigObj.fax__c = (userProvisioningObj.fax == null) ? userProvisionConfigObj.fax__c : userProvisioningObj.fax;
				userProvisionConfigObj.street__c = (userProvisioningObj.street == null) ? userProvisionConfigObj.street__c : userProvisioningObj.street;
				userProvisionConfigObj.city__c = (userProvisioningObj.city == null) ? userProvisionConfigObj.city__c : userProvisioningObj.city;
				userProvisionConfigObj.country__c = (userProvisioningObj.country == null) ? userProvisionConfigObj.country__c : userProvisioningObj.country;
				userProvisionConfigObj.state__c = (userProvisioningObj.state == null) ? userProvisionConfigObj.state__c : userProvisioningObj.state;
				userProvisionConfigObj.postalCode__c = (userProvisioningObj.postalCode == null) ? userProvisionConfigObj.postalCode__c : userProvisioningObj.postalCode;
				userProvisionConfigObj.Timezone__c = (userProvisioningObj.timezone == null) ? userProvisionConfigObj.timezone__c : userProvisioningObj.timezone;
				userProvisionConfigObj.TimezoneSidKey__c = (userProvisioningObj.timezoneIso == null) ? userProvisionConfigObj.TimezoneSidKey__c : userProvisioningObj.timezoneIso;
				userProvisionConfigObj.Deactive_User__c = (userProvisioningObj.deactiveUsers == null) ? userProvisionConfigObj.Deactive_User__c : Boolean.valueOf(userProvisioningObj.deactiveUsers);
				userProvisionConfigObj.Manager_Unique_Identifier__c = (userProvisioningObj.managerUniqueIdentifier == null) ? userProvisionConfigObj.Manager_Unique_Identifier__c : userProvisioningObj.managerUniqueIdentifier;
				userProvisionConfigObj.User_Deprovisioning_Identifier__c = (userProvisioningObj.userDeprovisioningIdentifier == null) ? userProvisionConfigObj.User_Deprovisioning_Identifier__c : userProvisioningObj.userDeprovisioningIdentifier;
				userProvisionConfigObj.Locale__c = true;
				userProvisionConfigObj.Locale_Type__c = (userProvisioningObj.localeType == null) ? userProvisionConfigObj.Locale_Type__c : userProvisioningObj.localeType;
				userProvisionConfigObj.Language__c = true;
				userProvisionConfigObj.Language_Type__c = (userProvisioningObj.languageType == null) ? userProvisionConfigObj.Language_Type__c : userProvisioningObj.languageType;
				userProvisionConfigObj.PhoneExtension__c = (userProvisioningObj.phoneExtension == null) ? userProvisionConfigObj.PhoneExtension__c : userProvisioningObj.phoneExtension;
				userProvisionConfigObj.Send_Emails__c = (userProvisioningObj.sendEmails == null) ? userProvisionConfigObj.Send_Emails__c : Boolean.valueOf(userProvisioningObj.sendEmails);
				userProvisionConfigObj.About__c = (userProvisioningObj.about == null) ? userProvisionConfigObj.About__c : userProvisioningObj.about;
				userProvisionConfigObj.Division__c = (userProvisioningObj.division == null) ? userProvisionConfigObj.Division__c : userProvisioningObj.division;
				if('Google'.equalsIgnoreCase(userProvisioningObj.provisioningSource)){
					if(userProvisioningObj.streetKey != null && 'custom'.equalsIgnoreCase(userProvisioningObj.streetKey)){
						userProvisionConfigObj.Street_Field__c = (userProvisioningObj.streetNamekey == null) ? userProvisionConfigObj.Street_Field__c : userProvisioningObj.streetNamekey;
					} else if(userProvisioningObj.streetKey != null && 'standard'.equalsIgnoreCase(userProvisioningObj.streetKey)){
						userProvisionConfigObj.Street_Field__c = '';
					}
					if(userProvisioningObj.cityKey != null && 'custom'.equalsIgnoreCase(userProvisioningObj.cityKey)){
						userProvisionConfigObj.City_Field__c = (userProvisioningObj.cityNameKey == null) ? userProvisionConfigObj.City_Field__c : userProvisioningObj.cityNameKey;
					} else if(userProvisioningObj.cityKey != null && 'standard'.equalsIgnoreCase(userProvisioningObj.cityKey)){
						userProvisionConfigObj.City_Field__c = '';
					}
					if(userProvisioningObj.stateKey != null && 'custom'.equalsIgnoreCase(userProvisioningObj.stateKey)){
						userProvisionConfigObj.State_Field__c = (userProvisioningObj.stateNameKey == null) ? userProvisionConfigObj.State_Field__c : userProvisioningObj.stateNameKey;
					} else if(userProvisioningObj.stateKey != null && 'standard'.equalsIgnoreCase(userProvisioningObj.stateKey)){
						userProvisionConfigObj.State_Field__c = '';
					}
					if(userProvisioningObj.countryKey != null && 'custom'.equalsIgnoreCase(userProvisioningObj.countryKey)){
						userProvisionConfigObj.Country_Field__c = (userProvisioningObj.countryNameKey == null) ? userProvisionConfigObj.Country_Field__c : userProvisioningObj.countryNameKey;
					} else if(userProvisioningObj.countryKey != null && 'standard'.equalsIgnoreCase(userProvisioningObj.countryKey)){
						userProvisionConfigObj.Country_Field__c = '';
					}
					if(userProvisioningObj.postalCodeKey != null && 'custom'.equalsIgnoreCase(userProvisioningObj.postalCodeKey)){
						userProvisionConfigObj.Postal_Code_Field__c = (userProvisioningObj.postalCodeNameKey == null) ? userProvisionConfigObj.Postal_Code_Field__c : userProvisioningObj.postalCodeNameKey;
					} else if(userProvisioningObj.postalCodeKey != null && 'standard'.equalsIgnoreCase(userProvisioningObj.postalCodeKey)){
						userProvisionConfigObj.Postal_Code_Field__c = '';
					}
				}
				
			} else {
				userProvisionConfigObj.Create_New_Users__c = false;
				userProvisionConfigObj.Profile__c = true;
				userProvisionConfigObj.Profile_Type__c = '';
				userProvisionConfigObj.Username__c = false;
				userProvisionConfigObj.Username_Suffix__c = '';
				userProvisionConfigObj.Firstname__c = false;
				userProvisionConfigObj.Lastname__c = true;
				userProvisionConfigObj.User_Title__c = false;
				userProvisionConfigObj.Birthdate__c = false;
				userProvisionConfigObj.Birthdate_Field__c = '';
				userProvisionConfigObj.Joining_Date__c = false;
				userProvisionConfigObj.Joining_Date_Field__c = '';
				userProvisionConfigObj.Company_Name__c = false;
				userProvisionConfigObj.Company_Name_Field__c = '';
				userProvisionConfigObj.Department__c = false;
				userProvisionConfigObj.Manager__c = false;
				userProvisionConfigObj.Employee_Number__c = false;
				userProvisionConfigObj.FedrationId__c = false;
				userProvisionConfigObj.Phone__c = false;
				userProvisionConfigObj.MobilePhone__c = false;
				userProvisionConfigObj.User_Email__c = false;
				userProvisionConfigObj.fax__c = false;
				userProvisionConfigObj.street__c = false;
				userProvisionConfigObj.city__c = false;
				userProvisionConfigObj.country__c = false;
				userProvisionConfigObj.state__c = false;
				userProvisionConfigObj.postalCode__c = false;
				userProvisionConfigObj.Timezone__c = false;
				userProvisionConfigObj.TimezoneSidKey__c = '';
				userProvisionConfigObj.Deactive_User__c = (userProvisioningObj.deactiveUsers == null) ? userProvisionConfigObj.Deactive_User__c : Boolean.valueOf(userProvisioningObj.deactiveUsers);
				userProvisionConfigObj.Manager_Unique_Identifier__c = 'username';
				userProvisionConfigObj.User_Deprovisioning_Identifier__c = (userProvisioningObj.userDeprovisioningIdentifier == null) ? userProvisionConfigObj.User_Deprovisioning_Identifier__c : userProvisioningObj.userDeprovisioningIdentifier;
				userProvisionConfigObj.Locale__c = true;
				userProvisionConfigObj.Locale_Type__c = '';
				userProvisionConfigObj.Language__c = true;
				userProvisionConfigObj.Language_Type__c = '';
				userProvisionConfigObj.PhoneExtension__c = false;
				userProvisionConfigObj.Send_Emails__c = false;
				userProvisionConfigObj.About__c = false;
				userProvisionConfigObj.Division__c = false;
				userProvisionConfigObj.Street_Field__c = '';
				userProvisionConfigObj.City_Field__c = '';
				userProvisionConfigObj.State_Field__c = '';
				userProvisionConfigObj.Country_Field__c = '';
				userProvisionConfigObj.Postal_Code_Field__c = '';
			}
		} else {
			userProvisionConfigObj.Provisioning_Source__c = 'None';
			userProvisionConfigObj.Query_Filter__c = '';
			userProvisionConfigObj.Create_New_Users__c = false;
			
		}
		if('CsvFile'.equalsIgnoreCase(userProvisioningObj.provisioningSource)) {  
			sendProvisioningInfoToAWS(userProvisioningObj);

		} else if('CsvFile'.equalsIgnoreCase(oldUserProvisioning) && !'CsvFile'.equalsIgnoreCase(userProvisioningObj.provisioningSource)) {
			sendProvisioningInfoToAWS(null);
		}
		upsert userProvisionConfigObj;
		
		// create audit
		auditUserSyncProvSource(false, userProvisioningObj.provisioningSource, oldUserProvisioning);
	}
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public static void saveProfileFieldsPeopleConfig(ManageApplicationWrapper.ProfileFieldsWrapper pPFObj) {
    	String appConfigQuery = 'Select Id, PP_FirstName_Display__c, PP_FirstName_Editable__c, PP_LastName_Display__c, PP_LastName_Editable__c, PP_Title_Display__c, PP_Title_Editable__c, '
									+ ' PP_About_Me_Display__c, PP_About_Me_Editable__c, PP_Department_Display__c, PP_Department_Editable__c, PP_State_Display__c, PP_State_Editable__c, ' 
									+ ' PP_Country_Display__c, PP_Country_Editable__c,PP_Street_Display__c,PP_Street_Editable__c, PP_Phone_Display__c, PP_Phone_Editable__c, PP_Extension_Display__c, PP_Extension_Editable__c, '
									+ ' PP_MobilePhone_Display__c, PP_MobilePhone_Editable__c, PP_Category_Display__c, PP_Category_Editable__c, PP_City_Display__c, PP_City_Editable__c, '
									+ ' PP_Manager_Display__c, PP_Manager_Editable__c, PP_User_Custom_Fields__c,PP_Timezone_Display__c,PP_Timezone_Editable__c, '
									+ ' PP_Video_Display__c, PP_Video_Editable__c, PP_Video_Provider__c, '
									+ ' PP_BirthDate_Editable__c, PP_JoiningDate_Editable__c, PP_JoiningDate_Display__c, PP_BirthDate_Display__c, '
									+ ' PP_Company_Name_Editable__c, PP_Company_Name_Display__c, PP_Division_Editable__c, PP_Division_Display__c, '
									+ ' PP_Language_Editable__c, PP_Language_Display__c from App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
										  
		App_Config__c apConfigObj = listOfAppConfig[0];
		
		apConfigObj.PP_FirstName_Display__c = (pPFObj.firstName == null) ? apConfigObj.PP_FirstName_Display__c : pPFObj.firstName;
		apConfigObj.PP_FirstName_Editable__c = (pPFObj.editableFirstName == null) ? apConfigObj.PP_FirstName_Editable__c : (pPFObj.editableFirstName && pPFObj.firstName);
		apConfigObj.PP_LastName_Display__c = (pPFObj.lastName == null) ? apConfigObj.PP_LastName_Display__c : pPFObj.lastName;
		apConfigObj.PP_LastName_Editable__c = (pPFObj.editableLastName == null) ? apConfigObj.PP_LastName_Editable__c : (pPFObj.editableLastName && pPFObj.lastName);
		apConfigObj.PP_Title_Display__c = (pPFObj.userTitle == null) ? apConfigObj.PP_Title_Display__c : pPFObj.userTitle;
		apConfigObj.PP_Title_Editable__c = (pPFObj.editableUserTitle == null) ? apConfigObj.PP_Title_Editable__c : (pPFObj.editableUserTitle && pPFObj.userTitle);
		apConfigObj.PP_About_Me_Display__c = (pPFObj.aboutMe == null) ? apConfigObj.PP_About_Me_Display__c : pPFObj.aboutMe;
		apConfigObj.PP_About_Me_Editable__c = (pPFObj.editableAboutMe == null) ? apConfigObj.PP_About_Me_Editable__c : (pPFObj.editableAboutMe && pPFObj.aboutMe);
		apConfigObj.PP_Department_Display__c = (pPFObj.department == null) ? apConfigObj.PP_Department_Display__c : pPFObj.department;
		apConfigObj.PP_Department_Editable__c = (pPFObj.editableDepartment == null) ? apConfigObj.PP_Department_Editable__c : (pPFObj.editableDepartment && pPFObj.department);
		apConfigObj.PP_State_Display__c = (pPFObj.state == null) ? apConfigObj.PP_State_Display__c : pPFObj.state;
		apConfigObj.PP_State_Editable__c = (pPFObj.editableState == null) ? apConfigObj.PP_State_Editable__c : (pPFObj.editableState && pPFObj.state);
		apConfigObj.PP_Country_Display__c = (pPFObj.country == null) ? apConfigObj.PP_Country_Display__c : pPFObj.country;
		apConfigObj.PP_Country_Editable__c = (pPFObj.editableCountry == null) ? apConfigObj.PP_Country_Editable__c : (pPFObj.editableCountry && pPFObj.country);
		apConfigObj.PP_Phone_Display__c = (pPFObj.phone == null) ? apConfigObj.PP_Phone_Display__c : pPFObj.phone;
		apConfigObj.PP_Phone_Editable__c = (pPFObj.editablePhone == null) ? apConfigObj.PP_Phone_Editable__c : (pPFObj.editablePhone && pPFObj.phone);
		apConfigObj.PP_Extension_Display__c = (pPFObj.extension == null) ? apConfigObj.PP_Extension_Display__c : pPFObj.extension;
		apConfigObj.PP_Extension_Editable__c = (pPFObj.editableExtension == null) ? apConfigObj.PP_Extension_Editable__c : (pPFObj.editableExtension && pPFObj.extension);
		apConfigObj.PP_MobilePhone_Display__c = (pPFObj.mobilePhone == null) ? apConfigObj.PP_MobilePhone_Display__c : pPFObj.mobilePhone;
		apConfigObj.PP_MobilePhone_Editable__c = (pPFObj.editableMobilePhone == null) ? apConfigObj.PP_MobilePhone_Editable__c : (pPFObj.editableMobilePhone && pPFObj.mobilePhone);
		apConfigObj.PP_Category_Display__c = (pPFObj.userCategory == null) ? apConfigObj.PP_Category_Display__c : pPFObj.userCategory;
		apConfigObj.PP_Category_Editable__c = (pPFObj.editableUserCategory == null) ? apConfigObj.PP_Category_Editable__c : (pPFObj.editableUserCategory && pPFObj.userCategory);
		apConfigObj.PP_City_Display__c = (pPFObj.city == null) ? apConfigObj.PP_City_Display__c : pPFObj.city;
		apConfigObj.PP_City_Editable__c = (pPFObj.editableCity == null) ? apConfigObj.PP_City_Editable__c : (pPFObj.editableCity && pPFObj.city);
		apConfigObj.PP_Street_Display__c = (pPFObj.street == null) ? apConfigObj.PP_Street_Display__c : pPFObj.street;
		apConfigObj.PP_Street_Editable__c = (pPFObj.editableStreet == null) ? apConfigObj.PP_Street_Editable__c : (pPFObj.editableStreet && pPFObj.street);
		apConfigObj.PP_Manager_Display__c = (pPFObj.manager == null) ? apConfigObj.PP_Manager_Display__c : pPFObj.manager;
		apConfigObj.PP_Manager_Editable__c = (pPFObj.editableManager == null) ? apConfigObj.PP_Manager_Editable__c : (pPFObj.editableManager && pPFObj.manager);
		apConfigObj.PP_Timezone_Display__c = (pPFObj.timezone == null) ? apConfigObj.PP_Timezone_Display__c : pPFObj.timezone;
		apConfigObj.PP_Timezone_Editable__c = (pPFObj.editableTimezone == null) ? apConfigObj.PP_Timezone_Editable__c : (pPFObj.editableTimezone && pPFObj.timezone);
		apConfigObj.PP_BirthDate_Editable__c = (pPFObj.editableBirthDate == null) ? apConfigObj.PP_BirthDate_Editable__c : (pPFObj.editableBirthDate && pPFObj.birthDate);
		apConfigObj.PP_JoiningDate_Editable__c = (pPFObj.editableJoiningDate == null) ? apConfigObj.PP_JoiningDate_Editable__c : (pPFObj.editableJoiningDate && pPFObj.joiningDate);
		apConfigObj.PP_JoiningDate_Display__c = (pPFObj.joiningDate == null) ? apConfigObj.PP_JoiningDate_Display__c : pPFObj.joiningDate;
		apConfigObj.PP_BirthDate_Display__c = (pPFObj.birthDate == null) ? apConfigObj.PP_BirthDate_Display__c : pPFObj.birthDate;
		apConfigObj.PP_Company_Name_Editable__c = (pPFObj.editableCompanyName == null) ? apConfigObj.PP_Company_Name_Editable__c : (pPFObj.editableCompanyName && pPFObj.companyName);
		apConfigObj.PP_Company_Name_Display__c = (pPFObj.companyName == null) ? apConfigObj.PP_Company_Name_Display__c : pPFObj.companyName;
		apConfigObj.PP_Division_Editable__c = (pPFObj.editableDivision == null) ? apConfigObj.PP_Division_Editable__c : (pPFObj.editableDivision && pPFObj.division);
		apConfigObj.PP_Division_Display__c = (pPFObj.division == null) ? apConfigObj.PP_Division_Display__c : pPFObj.division;		
		apConfigObj.PP_Video_Editable__c = (pPFObj.editableVideo == null) ? apConfigObj.PP_Video_Editable__c : (pPFObj.editableVideo && pPFObj.video);
		apConfigObj.PP_Video_Display__c = (pPFObj.video == null) ? apConfigObj.PP_Video_Display__c : pPFObj.video;
		apConfigObj.PP_Video_Provider__c = (pPFObj.videoProvider == null) ? apConfigObj.PP_Video_Provider__c : pPFObj.videoProvider;
		apConfigObj.PP_Language_Editable__c = (pPFObj.editableLanguage == null) ? apConfigObj.PP_Language_Editable__c : (pPFObj.editableLanguage && pPFObj.language);
		apConfigObj.PP_Language_Display__c = (pPFObj.language == null) ? apConfigObj.PP_Language_Display__c : pPFObj.language;

		List<String> columnNames = new List<String>{'User_Custom_Field_1__c', 'User_Custom_Field_2__c', 'User_Custom_Field_3__c',
													'User_Custom_Field_4__c', 'User_Custom_Field_5__c', 'User_Custom_Field_6__c',
													'User_Custom_Field_7__c', 'User_Custom_Field_8__c', 'User_Custom_Field_9__c',
													'User_Custom_Field_10__c', 'User_Custom_Field_11__c', 'User_Custom_Field_12__c',
													'User_Custom_Field_13__c', 'User_Custom_Field_14__c', 'User_Custom_Field_15__c',
													'User_Custom_Field_16__c', 'User_Custom_Field_17__c', 'User_Custom_Field_18__c',
													'User_Custom_Field_19__c', 'User_Custom_Field_20__c', 'User_Custom_Field_21__c',
													'User_Custom_Field_22__c', 'User_Custom_Field_23__c', 'User_Custom_Field_24__c',
													'User_Custom_Field_25__c'

													};

		if(pPFObj.customFields != null) {											
			for(CustomProfileField customField : pPFObj.customFields) {
				if(String.isNotBlank(customField.columnName) && String.isBlank(customField.syncSource)) {
					columnNames.remove(columnNames.indexOf(customField.columnName));
				}
			}
		}
			
		if(pPFObj.customFields != null) {
			for(CustomProfileField item : pPFObj.customFields){
				if(String.isBlank(item.syncSource)) {
					if(item.onOff==null) {
						item.onOff = false;
					}
					if(item.isEditable ==null) {
						item.isEditable = false;
					}
					if(item.columnName == null) {
						item.columnName = columnNames[0];
						columnNames.remove(0);

					}
				}
			}
		}
		apConfigObj.PP_User_Custom_Fields__c = (pPFObj.customFields == null || pPFObj.customFields.size()<1) ? '' : JSON.serialize(pPFObj.customFields);
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(apConfigObj,new List<Schema.SObjectField>{
																							App_Config__c.PP_FirstName_Display__c,
																							App_Config__c.PP_FirstName_Editable__c,
																							App_Config__c.PP_LastName_Display__c,
																							App_Config__c.PP_LastName_Editable__c,
																							App_Config__c.PP_Title_Display__c,
																							App_Config__c.PP_Title_Editable__c,
																							App_Config__c.PP_About_Me_Display__c,
																							App_Config__c.PP_About_Me_Editable__c,
																							App_Config__c.PP_Department_Display__c,
																							App_Config__c.PP_Department_Editable__c,
																							App_Config__c.PP_State_Display__c,
																							App_Config__c.PP_State_Editable__c,
																							App_Config__c.PP_Country_Display__c,
																							App_Config__c.PP_Country_Editable__c,
																							App_Config__c.PP_Phone_Display__c,
																							App_Config__c.PP_Phone_Editable__c,
																							App_Config__c.PP_Extension_Display__c,
																							App_Config__c.PP_Extension_Editable__c,
																							App_Config__c.PP_MobilePhone_Display__c,
																							App_Config__c.PP_MobilePhone_Editable__c,
																							App_Config__c.PP_Category_Display__c,
																							App_Config__c.PP_Category_Editable__c,
																							App_Config__c.PP_City_Display__c,
																							App_Config__c.PP_City_Editable__c,
																							App_Config__c.PP_Street_Display__c,
																							App_Config__c.PP_Street_Editable__c,
																							App_Config__c.PP_Manager_Display__c,
																							App_Config__c.PP_Manager_Editable__c,
																							App_Config__c.PP_Timezone_Display__c,
																							App_Config__c.PP_Timezone_Editable__c,
																							App_Config__c.PP_User_Custom_Fields__c,
																							App_Config__c.PP_BirthDate_Editable__c,
																							App_Config__c.PP_JoiningDate_Editable__c,
																							App_Config__c.PP_JoiningDate_Display__c,
																							App_Config__c.PP_BirthDate_Display__c,
																							App_Config__c.PP_Company_Name_Editable__c,
																							App_Config__c.PP_Company_Name_Display__c,
																							App_Config__c.PP_Division_Editable__c,
																							App_Config__c.PP_Division_Display__c,
																							App_Config__c.PP_Video_Display__c, 
																							App_Config__c.PP_Video_Editable__c,
																							App_Config__c.PP_Video_Provider__c,
																							App_Config__c.PP_Language_Editable__c,
																							App_Config__c.PP_Language_Display__c
																							});
			
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public static void saveEmailSetupConfig(ManageApplicationWrapper.AppConfigEmailWrapper appConfEmailObj){
        App_Config__c appConfObj= SimpplrContext.appConfig != NULL ? SimpplrContext.appConfig : NULL;
        
		appConfObj.Last_Edited_DateTime__c = DateTime.now();
        String existingProfileWithChatterEmailOff = '';
        String existingChatterEmailsSettings = appConfObj.GoLive_Chatter_Email_Setup__c;
        if(String.isNotBlank(appConfObj.Chatter_Email_Off_Profiles__c)) {
        	existingProfileWithChatterEmailOff = appConfObj.Chatter_Email_Off_Profiles__c;
        }
        List<String> listOfNewProfilesWithChatterEmailOff = new List<String>();
        
    	String profilesNotReceiveEmails = '';
    	if(appConfEmailObj.profilesNotReceiveEmails != NULL){
    		for(String s : appConfEmailObj.profilesNotReceiveEmails){ 
	        	profilesNotReceiveEmails += s + ',';
	        	if(!existingProfileWithChatterEmailOff.containsIgnoreCase(s) || !'Off For Selected Profiles'.equalsIgnoreCase(appConfObj.Chatter_Email_Off_Profiles__c)) {
	        		listOfNewProfilesWithChatterEmailOff.add(s);
	        	}
	        }
    	}
        profilesNotReceiveEmails = profilesNotReceiveEmails.removeEnd(',');
        appConfObj.Chatter_Email_Off_Profiles__c = String.valueOf(appConfEmailObj.chatterEmails).equalsIgnoreCase('Off For Selected Profiles') ? profilesNotReceiveEmails : appConfObj.Chatter_Email_Off_Profiles__c ;
        appConfObj.GoLive_Chatter_Email_Setup__c = appConfEmailObj.chatterEmails;
        appConfObj.Simpplr_Emails_Allowed__c = appConfEmailObj.enableEmail!=null? appConfEmailObj.enableEmail : false;
        appConfObj.Simpplr_Top_Stories_Emails_Allowed__c = appConfEmailObj.enableTopStoriesEmails != null? appConfEmailObj.enableTopStoriesEmails : false;
        appConfObj.SED_From_Email__c = appConfEmailObj.emailSender;

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Config__c>(new List<App_Config__c>{appConfObj}),new List<Schema.SObjectField>{
                                                        App_Config__c.GoLive_Chatter_Email_Setup__c,App_Config__c.Chatter_Email_Off_Profiles__c,
                                                        App_Config__c.Simpplr_Emails_Allowed__c,App_Config__c.Simpplr_Top_Stories_Emails_Allowed__c,App_Config__c.SED_From_Email__c,App_Config__c.Last_Edited_DateTime__c});
        
        if(!'Do Not Change'.equalsIgnoreCase(appConfEmailObj.chatterEmails)) {
        	
        	if(('Off For Selected Profiles'.equalsIgnoreCase(appConfEmailObj.chatterEmails) && !listOfNewProfilesWithChatterEmailOff.isEmpty()) || 
        		!existingChatterEmailsSettings.equalsIgnoreCase(appConfEmailObj.chatterEmails)) {                                                
				UserDao.setChatterEmailSettingsForUsers(appConfEmailObj.chatterEmails, listOfNewProfilesWithChatterEmailOff);
        	}
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
    public App_Config__c saveLicensingPeopleConfig(ManageApplicationWrapper.LicensingPeopleWrapper licensingWrapper) { 	
        String appConfigQuery = 'SELECT Last_Edited_DateTime__c, Auto_provisioning_Process_Enabled__c ,Auto_Free_Simpplr_License_Enabled__c From App_Config__c LIMIT 1';
	    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);

		App_Config__c appConfigObj = listOfAppConfig[0];
        appConfigObj.Last_Edited_DateTime__c = Datetime.now();

		if(!listOfAppConfig.isEmpty()) {
		    appConfigObj.Auto_provisioning_Process_Enabled__c = licensingWrapper.autoProvisioningProcessEnabled;
            appConfigObj.Auto_Free_Simpplr_License_Enabled__c = licensingWrapper.autoFreeSimpplrLicenseEnabled;
	    }
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(new Map<id,App_Config__c>(listOfAppConfig), 
												  new List<Schema.SObjectField>{
														App_Config__c.Auto_provisioning_Process_Enabled__c,
														App_Config__c.Auto_Free_Simpplr_License_Enabled__c,
														App_Config__c.Last_Edited_DateTime__c});

	    return appConfigObj;			
	}

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void saveSMSNotificationsSettings(String requestData) { 	
		String query = 'select id, Type__c,Sync_Status__c, Data__c, OverwriteBatchInProgress__c from App_Default__c where Type__c = \'sms_notifications\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		if(!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)){
			if(listOfAppDefault[0].OverwriteBatchInProgress__c){
				throw new SimpplrException(SETTINGS_UPDATED);	
			}
			listOfAppDefault[0].Data__c = requestData;
			listOfAppDefault[0].Sync_Status__c = null;
        	listOfAppDefault[0].Last_Modified_By_People__c = UserContext.peopleId;
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        	SIMPESAPI.accessController().updateAsUser(listOfAppDefault[0], new List<Schema.SObjectField>{
            	                       App_Default__c.Data__c,
									   App_Default__c.Last_Modified_By_People__c,
									   App_Default__c.Sync_Status__c});        
		}
		else{
        	App_Default__c appDefault = new App_Default__c(Type__c = 'sms_notifications',
        												   Data__c = requestData, 
        												   Last_Modified_By_People__c = UserContext.peopleId);

        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        	SIMPESAPI.accessController().insertAsUser(appDefault, new List<Schema.SObjectField>{
									   App_Default__c.Data__c,
									   App_Default__c.Type__c,
                	                   App_Default__c.Last_Modified_By_People__c});        
        
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
    public void saveNativeMobileAppNotificationsSettings(String requestData) { 	
		String query = 'select id,Sync_Status__c, Data__c, Type__c, OverwriteBatchInProgress__c from App_Default__c where Type__c = \'native_mobile_notifications\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		if(!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)){
			if(listOfAppDefault[0].OverwriteBatchInProgress__c){
				throw new SimpplrException(SETTINGS_UPDATED);	
			}
			listOfAppDefault[0].Data__c = requestData;
			listOfAppDefault[0].Sync_Status__c = null;
        	listOfAppDefault[0].Last_Modified_By_People__c = UserContext.peopleId;
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        	SIMPESAPI.accessController().updateAsUser(listOfAppDefault[0], new List<Schema.SObjectField>{
            	                       App_Default__c.Data__c,
									   App_Default__c.Last_Modified_By_People__c,
									   App_Default__c.Sync_Status__c});        
		}
		else{
        	App_Default__c appDefault = new App_Default__c(Type__c = 'native_mobile_notifications',
        												   Data__c = requestData, 
        												   Last_Modified_By_People__c = UserContext.peopleId);

        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        	SIMPESAPI.accessController().insertAsUser(appDefault, new List<Schema.SObjectField>{
									   App_Default__c.Data__c,
									   App_Default__c.Type__c,
                	                   App_Default__c.Last_Modified_By_People__c});        
        
      	}
			
	}
	
	public App_Config__c savePeopleIntegrationsConfig(ManageApplicationWrapper.PeopleIntegrationsWrapper peopleIntegrationWrapperObj, Boolean isADGroupsV2Enabled) { 	
        String appConfigQuery = 'SELECT PDS_Workday_Enabled__c, Last_Edited_DateTime__c, PDS_Workday_Endpoint__c, PDS_Source_Application__c, PDS_Workday_Password__c, PDS_Workday_Username__c, AD_Integration_Enabled__c, ' +
			' PDS_UKG_Pro_Enabled__c, PDS_UKG_Pro_Username__c, PDS_UKG_Pro_Password__c, PDS_UKG_Pro_Endpoint__c, PDS_UKG_Pro_API_Key__c FROM App_Config__c limit 1';
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);

		App_Config__c appConfig = listOfAppConfig[0];
		// UKG Pro People Data
		appConfig.PDS_UKG_Pro_Enabled__c = peopleIntegrationWrapperObj.ukgPro; 
		if(peopleIntegrationWrapperObj.ukgPro){
			Map<String, String> mapRequestParam = new Map<String, String>();
			if(String.isNotBlank(peopleIntegrationWrapperObj.ukgProPassword)) {
	        	Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
	        	Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
	            Blob blobPassword = Blob.valueOf(peopleIntegrationWrapperObj.ukgProPassword);
	            appConfig.PDS_UKG_Pro_Password__c = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, blobPassword));
				mapRequestParam.put('ukgProPassword', peopleIntegrationWrapperObj.ukgProPassword);
			} else {
				Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
				Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
				Blob cipherText = EncodingUtil.base64Decode(appConfig.PDS_UKG_Pro_Password__c);
				String ukgProPassword = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();
				mapRequestParam.put('ukgProPassword', ukgProPassword);
			}

			if(String.isNotBlank(peopleIntegrationWrapperObj.ukgProApiKey)) {
	        	Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
	        	Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
	            Blob ukgProApiKey = Blob.valueOf(peopleIntegrationWrapperObj.ukgProApiKey);
	            appConfig.PDS_UKG_Pro_API_Key__c = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, ukgProApiKey));
				mapRequestParam.put('ukgProApiKey', peopleIntegrationWrapperObj.ukgProApiKey);
			} else {
				Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
				Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
				Blob cipherText = EncodingUtil.base64Decode(appConfig.PDS_UKG_Pro_API_Key__c);
				String ukgProApiKey = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();
				mapRequestParam.put('ukgProApiKey', ukgProApiKey);
			}
	
			
			appConfig.PDS_UKG_Pro_Username__c=peopleIntegrationWrapperObj.ukgProUsername;
			appConfig.PDS_UKG_Pro_Endpoint__c=peopleIntegrationWrapperObj.ukgProBaseUrl;			
			mapRequestParam.put('ukgProUsername',peopleIntegrationWrapperObj.ukgProUsername);
			mapRequestParam.put('ukgProBaseUrl',peopleIntegrationWrapperObj.ukgProBaseUrl);
			mapRequestParam.put('action','getUserDefinedFieldConfig');
			getUKGUserFieldConfigData(mapRequestParam);	
		} else {
			if('UkgPro'.equalsIgnoreCase(appConfig.PDS_Source_Application__c)){
        		appConfig.PDS_Source_Application__c = 'None';

				// create audit trail
				auditUserSyncProvSource(true, 'None', 'UkgPro');
    		}
		}
        
		if(!peopleIntegrationWrapperObj.googleIntegrationEnabled &&
				 SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC) != null){
			
			updateIntegrationDisconnectOnAWS('disconnectgoogleusersyncadmin');
		}
		appConfig.Last_Edited_DateTime__c = DateTime.now();
		appConfig.PDS_Workday_Enabled__c = peopleIntegrationWrapperObj.workday; 
		if(peopleIntegrationWrapperObj.workday){
			if(String.isNotBlank(peopleIntegrationWrapperObj.workdayPassword)) {
	        	Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
	        	Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
	                Blob blobPassword = Blob.valueOf(peopleIntegrationWrapperObj.workdayPassword);
	                appConfig.PDS_Workday_Password__c = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, blobPassword));
			}
			appConfig.PDS_Workday_Username__c=peopleIntegrationWrapperObj.workdayUsername;
			appConfig.PDS_Workday_Endpoint__c=peopleIntegrationWrapperObj.workdayEndpointUrl;
		} else {
			if('workday'.equalsIgnoreCase(appConfig.PDS_Source_Application__c)){
        		appConfig.PDS_Source_Application__c = 'None';

				// create audit trail
				auditUserSyncProvSource(true, 'None', 'workday');
    		}
		}

		appConfig.AD_Integration_Enabled__c = peopleIntegrationWrapperObj.activeDirectoryIntegrationEnabled || peopleIntegrationWrapperObj.adIntegrationEnabled; 
		String integrationType = peopleIntegrationWrapperObj.adIntegrationEnabled ? IntegrationConstants.INTEGRATION_TYPE_ADSI : IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY;
		Boolean isActiveDirectoryIntegrationDisabled = SimpplrContext.isActiveDirectoryEnabled && !peopleIntegrationWrapperObj.activeDirectoryIntegrationEnabled;
		logger.logDebug('isActiveDirectoryIntegrationDisabled---' + isActiveDirectoryIntegrationDisabled);		
		if(peopleIntegrationWrapperObj.adIntegrationEnabled || peopleIntegrationWrapperObj.activeDirectoryIntegrationEnabled){
			try {
				String clientId = peopleIntegrationWrapperObj.activeDirectoryIntegrationEnabled ? 'not required' : IntegrationConstants.ADSI_CLIENT_ID;
				String clientSecret = peopleIntegrationWrapperObj.activeDirectoryIntegrationEnabled ? 'not required' : IntegrationConstants.ADSI_CLIENT_SECRET;
				IntegrationService adObj = new IntegrationService(integrationType, null);
				
				if((adObj.appIntegrator == null) || String.isBlank(adObj.appIntegrator.Id)) {
					// Domain not needed for Microsoft API (Azure API would need it).
					IntegrationService.createAppIntegration(integrationType, clientId, clientSecret, null);	
				} else {
					IntegrationService.updateADIntegRecords(integrationType, clientId, clientSecret);
				}

				if(peopleIntegrationWrapperObj.activeDirectoryIntegrationEnabled) {
					
					if(peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled && 
						peopleIntegrationWrapperObj.listOfActiveDirectoryGroupsSelected.isEmpty()) {
						// get count from DB
						String query = 'SELECT COUNT(Id) adCount FROM Active_Directory_Group__c WHERE Is_Deleted__c = false';
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						List<AggregateResult> aggrList  = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, null);
						Integer activeDirectoryDBCount = (Integer)aggrList[0].get('adCount');	

						Set<String> adGroupIds = getADGroupIds(peopleIntegrationWrapperObj.listOfActiveDirectoryGroupsRemoved);
						Map<String, Object> sqlParamMap = new Map<String, Object>();
						sqlParamMap.put('soqlParam1', adGroupIds);												
						query = 'SELECT COUNT(Id) adCount FROM Active_Directory_Group__c WHERE AD_Object_Id__c =: soqlParam1 AND Is_Deleted__c = false';
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
						aggrList  = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, sqlParamMap);
						Integer removedActiveDirectoryDBCount = (Integer)aggrList[0].get('adCount');							

						// compare count from removed groups
						if((activeDirectoryDBCount - removedActiveDirectoryDBCount) < 1) {
							// throw Exception
							LocaleContext.getAllLabelMap('SettingDataServer', new List<String>{UserContext.languageLocaleKey});
							throw new SimpplrException(LocaleContext.getLabel(UserContext.languageLocaleKey,ERROR_AD_SELECTED_GROUP_MINIMUM_COUNT));							
						}
					}
					
					String appIntQuery = 'SELECT Id, Integration_Enabled__c, Active_Directory_Groups_Enabled__c,'
						+ ' Auto_Audience_creation__c'
						+ ' FROM App_Integration__c'
						+ ' WHERE Name = :soqlParam1'
						+ ' AND Integration_Enabled__c = true LIMIT 1';
					Map<String, Object> sqlParamMap = new Map<String, Object>();

					sqlParamMap.put('soqlParam1', integrationType);

					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<App_integration__c> appIntList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);				
					App_Integration__c adAppIntegrationObj = appIntList[0];
					
					Boolean isModified = false;

					peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled = peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled != null ?
						peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled : false;
					peopleIntegrationWrapperObj.autoCreateActiveDirectoryAudience = peopleIntegrationWrapperObj.autoCreateActiveDirectoryAudience != null ?
					peopleIntegrationWrapperObj.autoCreateActiveDirectoryAudience : false;	

					if(peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled && !adAppIntegrationObj.Active_Directory_Groups_Enabled__c
						|| !peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled && adAppIntegrationObj.Active_Directory_Groups_Enabled__c) {
						adAppIntegrationObj.Active_Directory_Groups_Enabled__c = peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled;
						logger.logDebug('AD Group Flag updated');
						isModified = true;
						if(!peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled) {
							// call batch to delete all AD audiences
							logger.logDebug('Initiating batch to delete all AD Groups and Audiences');
							Database.executeBatch(new BatchSyncAudienceMembersFromAD('deleteAllADGroupAudience'), 2000);
						}
					}
					if(peopleIntegrationWrapperObj.autoCreateActiveDirectoryAudience && !adAppIntegrationObj.Auto_Audience_creation__c
						|| !peopleIntegrationWrapperObj.autoCreateActiveDirectoryAudience && adAppIntegrationObj.Auto_Audience_creation__c) {
						adAppIntegrationObj.Auto_Audience_creation__c = peopleIntegrationWrapperObj.autoCreateActiveDirectoryAudience;
						logger.logDebug('Auto created audience flag updated');
						isModified = true;
						if(!peopleIntegrationWrapperObj.autoCreateActiveDirectoryAudience) {
							// call batch to delete auto created audience
							logger.logDebug('Initiating batch to delete all Auto Created Audiences');
							Database.executeBatch(new BatchSyncAudienceMembersFromAD('deleteAutoCreatedAudiences'), 2000);
						}
					}
				
					if(isModified) {
						SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
						SIMPESAPI.accessController().updateAsUser(adAppIntegrationObj, new List<Schema.SObjectField>{
																				App_Integration__c.Active_Directory_Groups_Enabled__c,
																				App_Integration__c.Auto_Audience_creation__c});						
					}

					logger.logDebug('Updating AD Groups in DB');
					ActiveDirectoryHelper adHelperObj = new ActiveDirectoryHelper();
					adHelperObj.updateADGroupsInDB(peopleIntegrationWrapperObj.listOfActiveDirectoryGroupsSelected, 
						peopleIntegrationWrapperObj.listOfActiveDirectoryGroupsRemoved, isADGroupsV2Enabled);					

					if(peopleIntegrationWrapperObj.isActiveDirectoryGroupsEnabled) {

						Boolean runCompleteSync = false;
	
						if(!peopleIntegrationWrapperObj.listOfActiveDirectoryGroupsRemoved.isEmpty()) {
							// delete/update audiences with these groups
							Set<String> adGroupIds = new Set<String>();
							for(ActiveDirectoryModel.ADGroup removedGroup : peopleIntegrationWrapperObj.listOfActiveDirectoryGroupsRemoved) {
								adGroupIds.add(removedGroup.id);
							}
							logger.logDebug('Initiating batch to delete/update removed group audience');
							Database.executeBatch(new BatchSyncAudienceMembersFromAD('updateRemovedADGroupAudience', adGroupIds, false), 1);
						}
						if(peopleIntegrationWrapperObj.autoCreateActiveDirectoryAudience) {
							
							if(!peopleIntegrationWrapperObj.listOfActiveDirectoryGroupsSelected.isEmpty()) {
								runCompleteSync = true;
							}
							logger.logDebug('Initiating batch to Auto create audience if not exist');
							Database.executeBatch(new BatchSyncAudienceMembersFromAD('createAutomaticAudienceAD', runCompleteSync), 2000);
						} else {
							if(!peopleIntegrationWrapperObj.listOfActiveDirectoryGroupsSelected.isEmpty()) {
								logger.logDebug('Initiating AD Group Sync on AWS');
								Database.executeBatch(new BatchSyncAudienceMembersFromAD('initiateADGroupSync'), 1);
								runCompleteSync = true;
							}
						}
						if(runCompleteSync) {
							ActiveDirectoryService.updateBatchProcessingFlag(true);
						}

					}

				}



			} catch (Exception e) {
				throw new SimpplrException(e.getMessage());
			}
		} else {

			String appIntQuery = 'SELECT Id, Integration_Enabled__c FROM App_Integration__c'
													+ ' WHERE Name = :soqlParam1'
													+ ' AND Integration_Enabled__c = true LIMIT 1';
			Map<String, Object> sqlParamMap = new Map<String, Object>();

			sqlParamMap.put('soqlParam1', integrationType);
	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_integration__c> appIntList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
			
			if(appIntList != null && !appIntList.isEmpty()){
				appIntList[0].Integration_Enabled__c = false;

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(new Map<id,App_Integration__c>(appIntList), new List<Schema.SObjectField>{
																		App_Integration__c.Integration_Enabled__c});
			}

			if('activedirectory'.equalsIgnoreCase(appConfig.PDS_Source_Application__c)){
        		appConfig.PDS_Source_Application__c = 'None';

				// create audit trail
				auditUserSyncProvSource(true, 'None', 'activedirectory');
    		}

			if(isActiveDirectoryIntegrationDisabled) {
				// initiate batch to delete all AD audiences.
				Database.executeBatch(new BatchSyncAudienceMembersFromAD('deleteAllADGroupAudience'), 2000);									
			}
			
		}
		
		// Add app inegration record for google user syncing
		if(peopleIntegrationWrapperObj.googleIntegrationEnabled) {
			App_Integration__c appInteg = new App_Integration__c();				
			appInteg.Integration_Enabled__c = true;
			appInteg.Name = IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC;
			appInteg.Org_Id__c = SimpplrContext.simpplrOrgId;   				
			appInteg.Client_Id__c = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID;
			appInteg.Client_Secret__c = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_SECRET;
			appInteg.Token_Type__c = 'DUMMY';
			appInteg.Access_Token_Expiry__c = 99999.00;
			appInteg.Access_Token_Requested_Datetime__c = DateTime.valueOfGmt('2019-12-31 23:59:59').addYears(10);
			appInteg.App_Access_Token__c = 'DUMMYACCCESSTOKEN';
			appInteg.App_Refresh_Token__c = 'DUMMYREFRESHTOKEN';
			if(SimpplrContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC)) {
				appInteg.id = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC).Id;
				update appInteg;
			} else {				
				insert appInteg;
			}
		} else {

			peopleIntegrationWrapperObj.googleConnectedAs = '';
			String appIntQuery = 'SELECT Id FROM App_Integration__c'
															+ ' WHERE Name = :soqlParam1'
															+ ' AND Org_Id__c = :soqlParam2';
			Map<String, Object> sqlParamMap = new Map<String, Object>();
			sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC);
			sqlParamMap.put('soqlParam2', SimpplrContext.simpplrOrgId);
	
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_integration__c> appIntegrationList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
															
			if(!appIntegrationList.isEmpty()) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(appIntegrationList);
			}

			// Make Sync source none if it was set to Google for provisioning.
			String query = 'SELECT Id, Provisioning_Source__c FROM User_Provisioning_Config__c LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<User_Provisioning_Config__c> userProvConfigObjList = (List<User_Provisioning_Config__c>)SIMPESAPI.accessController().queryAsUser(query, null);
			if(!userProvConfigObjList.isEmpty()){
				if(userProvConfigObjList[0] != null && 'Google'.equalsIgnoreCase(userProvConfigObjList[0].Provisioning_Source__c)){
					userProvConfigObjList[0].Provisioning_Source__c = 'None';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(userProvConfigObjList[0], new List<Schema.SObjectField>{ User_Provisioning_Config__c.Provisioning_Source__c });
				}
			}

			// Make changes only if the previous source was Google
			if('google'.equalsIgnoreCase(appConfig.PDS_Source_Application__c)){
        		appConfig.PDS_Source_Application__c = 'None';

				// create audit trail
				auditUserSyncProvSource(true, 'None', 'google');

				BatchGoogleUserSync job = new BatchGoogleUserSync('CleanSyncField');
				Database.executeBatch(job, 1);
    		}
		}

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appConfig,  new List<Schema.SObjectField>{																												
														App_Config__c.PDS_Workday_Enabled__c,
														App_Config__c.PDS_Workday_Endpoint__c,
														App_Config__c.PDS_Workday_Password__c,
														App_Config__c.PDS_Workday_Username__c,
														App_Config__c.AD_Integration_Enabled__c,
														App_Config__c.PDS_Source_Application__c,
														App_Config__c.PDS_UKG_Pro_Enabled__c,
														App_Config__c.PDS_UKG_Pro_Username__c,
														App_Config__c.PDS_UKG_Pro_Password__c,
														App_Config__c.PDS_UKG_Pro_Endpoint__c,
														App_Config__c.PDS_UKG_Pro_API_Key__c,
														App_Config__c.Last_Edited_DateTime__c});
														
     return appConfig;
}

public Set<String> getADGroupIds(List<ActiveDirectoryModel.ADGroup> listOfActiveDirectoryGroups) {
	Set<String> setOfADGroupIds = new Set<String>();
	for(ActiveDirectoryModel.ADGroup adGroup : listOfActiveDirectoryGroups) {
		setOfADGroupIds.add(adGroup.id);
	}
	return setOfADGroupIds;
}

/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public App_Config__c saveSsoIntegrationsConfig(ManageApplicationWrapper.SingleSignOnIntegrationsWrapper SingleSignOnIntegrationsObj) { 	
        String appConfigQuery = 'SELECT Okta_Enabled__c, Okta_Link__c, Okta_API_Token__c, Okta_People_Name_Format__c, OneLogin_Enabled__c, '
				+ ' OneLogin_API_Token__c, OneLogin_Embedding_Token__c, OneLogin_Link__c, PDS_Source_Application__c FROM App_Config__c limit 1';
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);

		App_Config__c appConfig = listOfAppConfig[0];

        appConfig.Last_Edited_DateTime__c = DateTime.now();
		appConfig.Okta_Enabled__c = SingleSignOnIntegrationsObj.okta;
		if(SingleSignOnIntegrationsObj.okta){
			appConfig.Okta_Link__c=SingleSignOnIntegrationsObj.oktaLink;
			
			if(String.isNotBlank(SingleSignOnIntegrationsObj.oktaApiToken)){
				Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
				Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
				Blob blobToken = Blob.valueOf(SingleSignOnIntegrationsObj.oktaApiToken);

				appConfig.Okta_API_Token__c = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, blobToken));
			}

			appConfig.Okta_People_Name_Format__c=SingleSignOnIntegrationsObj.oktaUserNameFormat;

		} else {
			// remove Okta as syncing source(if was set) when Okta is disabled.
			if('okta'.equalsIgnoreCase(appConfig.PDS_Source_Application__c)){
        		appConfig.PDS_Source_Application__c = 'None';

				// create audit trail
				auditUserSyncProvSource(true, 'None', 'okta');
    		}

		}
		
		appConfig.OneLogin_Enabled__c = SingleSignOnIntegrationsObj.onelogin;
		if(SingleSignOnIntegrationsObj.onelogin){

			if(String.isNotBlank(SingleSignOnIntegrationsObj.oneLoginApiKey)){
				Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
				Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
				Blob blobApiKey = Blob.valueOf(SingleSignOnIntegrationsObj.oneLoginApiKey);

				appConfig.OneLogin_API_Token__c = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, blobApiKey));
			}

			appConfig.OneLogin_Embedding_Token__c=SingleSignOnIntegrationsObj.oneLoginEmbeddingCode;
			appConfig.OneLogin_Link__c=SingleSignOnIntegrationsObj.oneLoginEmbeddingUrl;
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appConfig,  new List<Schema.SObjectField>{
												App_Config__c.Last_Edited_DateTime__c,												
												App_Config__c.Okta_Enabled__c,
												App_Config__c.Okta_Link__c,
												App_Config__c.Okta_API_Token__c,
												App_Config__c.Okta_People_Name_Format__c,
												App_Config__c.OneLogin_Enabled__c,
												App_Config__c.OneLogin_API_Token__c,
												App_Config__c.OneLogin_Embedding_Token__c,
												App_Config__c.OneLogin_Link__c,
												App_Config__c.PDS_Source_Application__c});
																										
    return appConfig;
}

/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public void saveCalendarIntegrationsConfig(ManageApplicationWrapper.CalendarIntegrationsWrapper calendarIntegrationsObj) { 			
		List<App_Integration__c> listToUpdate = new List<App_Integration__c>();
		List<App_Integration__c> listToInsert = new List<App_Integration__c>();
		App_Integration__c appInteg;
		Boolean googleCalendarDelete = false;
		Boolean outlookCalendarDelete = false;
		Set<String> outlookDomainsRemovedSet = new Set<String>();

		String appIntQuery = 'SELECT Id, Name,'
						+ ' Scope__c, Scope_Required__c, User_Name__c, User_Email__c,'  
						+ ' Extra_Url_Parameters__c, Client_Secret__c, Client_Id__c,'
						+ ' DB_User_Client_Id__c, DB_User_Client_Secret__c,'
						+ ' App_Access_Token__c, App_Refresh_Token__c, Whitelist_Domain__c, '
						+ ' Token_Type__c, Redirect_Uri__c, App_Installed__c,'
						+ ' Access_Token_Requested_Datetime__c, Refresh_Token_Requested_Datetime__c,'
						+ ' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,'
						+ ' Access_Token_Expiry__c,  External_Id__c, Integration_Enabled__c, Connected__c,'
						+ ' Is_Deleted__c ,All_Company_Group_Id__c, Batch_Processing__c,'
						+ ' Root_Folder_Id__c, Enterprise_Id__c, Endpoint_Url__c, Data__c,'
						+ ' Is_My_Drive_Enabled__c, Simpplr_Managed_Permission__c'
						+ ' FROM App_Integration__c'
						+ ' WHERE Is_Deleted__c = false AND (Name = :soqlParam1 OR Name = : soqlParam3) '
						+ ' AND Org_Id__c = :soqlParam2';
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR);
		sqlParamMap.put('soqlParam2', SimpplrContext.simpplrOrgId);
		sqlParamMap.put('soqlParam3', IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegrationList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);			
		
		Map<String, App_Integration__c> mapOfAppIntObject = new Map<String, App_Integration__c>();
		for(App_Integration__c appIntegartion : appIntegrationList) {
			mapOfAppIntObject.put(appIntegartion.Name, appIntegartion);
		}

		for(String calendarName: IntegrationConstants.calendarTypes) {
			if(mapOfAppIntObject.containsKey(calendarName)) {
				appInteg = mapOfAppIntObject.get(calendarName);
			} else {
				appInteg = new App_Integration__c();
			}
			if(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(calendarName)) {
				logger.logDebug('calendarName---'+calendarName);
				Boolean isGoogleMultiDomainUpgraded = GoogleDriveService.googleMultiDomainUpgraded();
				if(calendarIntegrationsObj.googleCalendar ==  true) {	
					if (isGoogleMultiDomainUpgraded) {
						GoogleDriveService googleServiceObj = new GoogleDriveService();
						Boolean googleCalendarDomainExists = googleServiceObj.getGoogleDomainExists(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR);
						if (!googleCalendarDomainExists) {
							throw new SimpplrException(ERROR_DOMAIN_CONFIG_NOT_SETUP);
						}
						appInteg.Connected__c = true;
					}
					appInteg.Integration_Enabled__c = true;
					appInteg.Name = IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR;
					appInteg.Org_Id__c = SimpplrContext.simpplrOrgId;   				
					appInteg.Client_Id__c = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID;
					appInteg.Client_Secret__c = IntegrationConstants.GOOGLE_CALENDAR_CLIENT_SECRET;
					appInteg.Token_Type__c = 'DUMMY';
					appInteg.Access_Token_Expiry__c = 99999.00;
					appInteg.Access_Token_Requested_Datetime__c = DateTime.valueOfGmt('2019-12-31 23:59:59').addYears(10);
					appInteg.App_Access_Token__c = 'DUMMYACCCESSTOKEN';
					appInteg.App_Refresh_Token__c = 'DUMMYREFRESHTOKEN';
					appInteg.Refresh_Token_Expiration_Datetime__c = null;

				} else if(calendarIntegrationsObj.googleCalendar == false && appInteg != null && appInteg.Integration_Enabled__c == true) {
					googleCalendarDelete = true;
					if (isGoogleMultiDomainUpgraded) {
						appInteg.Connected__c = false;
						appInteg.Integration_Enabled__c = false;
					} else {
						appInteg.Is_Deleted__c = true;
					}
					// disable google calendar on AWS		
					updateIntegrationDisconnectOnAWS('disconnectGoogleCalendarAdmin');

				}
			
			} else if(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(calendarName)) {
				logger.logDebug('calendarName---'+calendarName);
				if(calendarIntegrationsObj.outlookCalendar == true) {		
					
					appInteg.Connected__c = true;
					appInteg.Name = IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR;
					appInteg.Org_Id__c = SimpplrContext.simpplrOrgId;   				
					appInteg.Client_Id__c = IntegrationConstants.OUTLOOK_CALENDAR_CLIENT_ID;
					appInteg.Client_Secret__c = IntegrationConstants.OUTLOOK_CALENDAR_CLIENT_SECRET;
					if(calendarIntegrationsObj.outlookCalendarDomainWhitelist != null && calendarIntegrationsObj.outlookCalendarDomainWhitelist.size() > 0) {
						appInteg.Whitelist_Domain__c = appInteg.Whitelist_Domain__c != null ? appInteg.Whitelist_Domain__c : '';
						Set<String> existingDomainSet = new Set<String>(appInteg.Whitelist_Domain__c.split(','));
						Set<String> outlookCalendarDomainSet = new Set<string>();
						List<String> outlookCalendarDomainList = new List<String>();
						outlookCalendarDomainSet.addAll(calendarIntegrationsObj.outlookCalendarDomainWhitelist);
						outlookCalendarDomainList.addAll(outlookCalendarDomainSet);
						appInteg.Whitelist_Domain__c = Utility.convertToCommaSeparatedString(outlookCalendarDomainList);

						// Get set difference
						Map<String, Set<String>> setDifference = Utility.getSetDifference(existingDomainSet, outlookCalendarDomainSet);

						outlookDomainsRemovedSet = setDifference.get('entriesRemoved');

						if(!setDifference.get('entriesAdded').isEmpty() || !setDifference.get('entriesRemoved').isEmpty() ||
							!appInteg.Integration_Enabled__c) {
							// send change in domain info to outlook MS
							OutlookCalendarHelper outlookCalendarHelperObj = new OutlookCalendarHelper();
							outlookCalendarHelperObj.saveOutlookManageAppInfo(true, outlookCalendarDomainList);
						}
						appInteg.Integration_Enabled__c = true;											
					}

				} else if (calendarIntegrationsObj.outlookCalendar == false && appInteg != null && appInteg.Integration_Enabled__c == true){

					outlookCalendarDelete = true;
					appInteg.Connected__c = false;
					appInteg.Integration_Enabled__c = false;
					Set<String> existingDomainSet = new Set<String>(appInteg.Whitelist_Domain__c.split(','));
					Set<String> outlookCalendarDomainSet = new Set<string>();
					List<String> outlookCalendarDomainList = new List<String>();
					outlookCalendarDomainSet.addAll(calendarIntegrationsObj.outlookCalendarDomainWhitelist);
					outlookCalendarDomainList.addAll(outlookCalendarDomainSet);
					appInteg.Whitelist_Domain__c = Utility.convertToCommaSeparatedString(outlookCalendarDomainList);

					// Get set difference
					Map<String, Set<String>> setDifference = Utility.getSetDifference(existingDomainSet, outlookCalendarDomainSet);

					outlookDomainsRemovedSet = setDifference.get('entriesRemoved');				

					// send change in integration info to outlook MS
					OutlookCalendarHelper outlookCalendarHelperObj = new OutlookCalendarHelper();
					outlookCalendarHelperObj.saveOutlookManageAppInfo(false, outlookCalendarDomainList);
				}
			}
			
			if(String.isNotBlank(appInteg.Client_Id__c)) {
				if(String.isBlank(appInteg.Id)) {
					listToInsert.add(appInteg);
				} else {
					listToUpdate.add(appInteg);
				}
			}
		}

		if(googleCalendarDelete == true) {
			List<String> connectedApps = new List<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR};
			if (GoogleDriveService.googleMultiDomainUpgraded()) {
				Database.executeBatch(new BatchDeleteIntegrationRecords(connectedApps, BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION, null),2000);
			} else {
				Database.executeBatch(new BatchDeleteIntegrationRecords(connectedApps),2000);
			}
		}
        
		if(!outlookDomainsRemovedSet.isEmpty()) {
			List<String> connectedApps = new List<String>{IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR};
			Database.executeBatch(new BatchDeleteIntegrationRecords(connectedApps, 
					'removeDomainPeopleIntegration', outlookDomainsRemovedSet),2000);
		}
		
		if(listToUpdate.size()>0){
			update listToUpdate;
		}
			
		if(listToInsert.size()>0){
			insert listToInsert;
		}

	}

	public static void updateIntegrationDisconnectOnAWS(String action){
		try{
			
			String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager?action=' + action;
			Map<String, Object> mapOfRequestParam = new Map<String, Object>();
			mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
			logger.logDebug(action + ' called for orgId: ' + SimpplrContext.simpplrOrgId);
			Utility.getResponseFromAWS(endpointURL, mapOfRequestParam);

		}catch(Exception ex){
			logger.logDebug('Exception while disconnecting' + ex);
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
	public Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration> saveSearchIntegrationsConfig(Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration> searchIntegrationMap) { 	
       
		String appIntQueryString = 'SELECT Id, Name, Integration_Enabled__c, Connected__c, Is_Deleted__c, Endpoint_Url__c, Data__c, Org_Id__c, Client_Id__c, Client_Secret__c '
									+ ' FROM App_Integration__c'
									+ ' WHERE Name = :soqlParam1'
									+ ' AND Org_Id__c = :soqlParam2 ';
									
		List<String> enterpriseSearchIntegrationNameList = IntegrationConstants.ENTERPRISE_SEARCH_INTEGRATION_NAME_LIST;

		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', enterpriseSearchIntegrationNameList);
		sqlParamMap.put('soqlParam2', SimpplrContext.simpplrOrgId);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Integration__c> appIntegrationList = (List<App_Integration__c>) SIMPESAPI.accessController().queryAsUser(appIntQueryString, sqlParamMap);
		
		Map<String, App_Integration__c> nameVsAppIntMap = new Map<String, App_Integration__c>();
		for(App_Integration__c appIntObj : appIntegrationList){

			nameVsAppIntMap.put(appIntObj.Name, appIntObj);
		}

		List<App_Integration__c> newAppIntegrationList = new List<App_Integration__c>();
		for(String searchIntegrationName : searchIntegrationMap.keySet()){

			Boolean isEnabled = searchIntegrationMap.get(searchIntegrationName).isEnabled != null ? searchIntegrationMap.get(searchIntegrationName).isEnabled : false;
			String url = String.isNotBlank(searchIntegrationMap.get(searchIntegrationName).url) ? searchIntegrationMap.get(searchIntegrationName).url : '';
			String provider = String.isNotBlank(searchIntegrationMap.get(searchIntegrationName).provider) ? searchIntegrationMap.get(searchIntegrationName).provider : '';
			App_Integration__c appIntegrationObj = null;

			if(nameVsAppIntMap.size() > 0 && nameVsAppIntMap.containsKey(searchIntegrationName)){

				appIntegrationObj = nameVsAppIntMap.get(searchIntegrationName);
				
			} else {

				appIntegrationObj = new App_Integration__c();

				appIntegrationObj.Client_Id__c = 'DUMYY_CLIENT_ID';
				appIntegrationObj.Client_Secret__c = 'DUMYY_SECRET_ID';
				appIntegrationObj.Name = searchIntegrationName;
			    appIntegrationObj.Is_Deleted__c = false;
				appIntegrationObj.Org_Id__c = UserInfo.getOrganizationId();
			}

			appIntegrationObj.Data__c = provider;
			appIntegrationObj.Integration_Enabled__c = isEnabled;
			appIntegrationObj.Connected__c = isEnabled;
			appIntegrationObj.Endpoint_Url__c = url;

			newAppIntegrationList.add(appIntegrationObj);
		}
		
		if(newAppIntegrationList.size() > 0){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().upsertAsUser(newAppIntegrationList, new List<Schema.SObjectField>{
				App_Integration__c.Name,
				App_Integration__c.Integration_Enabled__c,
				App_Integration__c.Connected__c,
				App_Integration__c.Is_Deleted__c,
				App_Integration__c.Endpoint_Url__c,
				App_Integration__c.Org_Id__c,
				App_Integration__c.Data__c,
				App_Integration__c.Client_Id__c,
				App_Integration__c.Client_Secret__c
			});      
		}

    return searchIntegrationMap;
}


	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public App_Config__c saveAnalyticsEmbedsIntegrationsConfig(ManageApplicationWrapper.AnalyticsEmbedsIntegrationsWrapper analyticsEmbedsWrapper , Boolean ga4_integration_Flag) { 	
        String appConfigQuery = 'SELECT GA_Enabled__c,GA_Tracking_Code__c,GA_Enhanced_Link_Attribution__c,'+ 
				'GA_Tracking_Code4__c, Enable_Google_Analytics4__c, Enable_Google_Analytics3__c, ' + 
				' GA_Demography_Interests__c,' + 
				' vbrick_Enabled__c, Vbrick_Base_Url__c, Last_Edited_DateTime__c FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);

		App_Config__c appConfigObj = listOfAppConfig[0];

		if(!listOfAppConfig.isEmpty()) {
		    appConfigObj.GA_Enabled__c = analyticsEmbedsWrapper.enableGoogleAnalytics;
			appConfigObj.Enable_Google_Analytics4__c = analyticsEmbedsWrapper.enableGoogleAnalytics4;
			appConfigObj.Enable_Google_Analytics3__c = analyticsEmbedsWrapper.googleAnalytics;
            appConfigObj.GA_Tracking_Code__c = analyticsEmbedsWrapper.analyticsTrackingId;
			appConfigObj.GA_Tracking_Code4__c = analyticsEmbedsWrapper.analyticsTrackingId4;
			appConfigObj.GA_Enhanced_Link_Attribution__c = analyticsEmbedsWrapper.analyticsEnhancedLinkAttribution;
			appConfigObj.GA_Demography_Interests__c = analyticsEmbedsWrapper.analyticsDemographicsInterestsReports;
            appConfigObj.vbrick_Enabled__c = analyticsEmbedsWrapper.vbrick;
            appConfigObj.Vbrick_Base_Url__c = analyticsEmbedsWrapper.vbrickBaseURL;
			appConfigObj.Last_Edited_DateTime__c = DateTime.now();
	    }
		
		if( (appConfigObj.GA_Enabled__c == true && (appConfigObj.Enable_Google_Analytics4__c == true || appConfigObj.Enable_Google_Analytics3__c == true)) || appConfigObj.GA_Enabled__c == false || (ga4_integration_Flag == false && appConfigObj.Enable_Google_Analytics3__c == false)){					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,App_Config__c>(listOfAppConfig), 
													new List<Schema.SObjectField>{
															App_Config__c.GA_Enabled__c,
															App_Config__c.GA_Tracking_Code__c,
															App_Config__c.GA_Tracking_Code4__c,
															App_Config__c.Enable_Google_Analytics4__c,
															App_Config__c.Enable_Google_Analytics3__c,
															App_Config__c.GA_Enhanced_Link_Attribution__c,
															App_Config__c.GA_Demography_Interests__c,
															App_Config__c.vbrick_Enabled__c,
															App_Config__c.Vbrick_Base_Url__c,
															App_Config__c.Last_Edited_DateTime__c});

			return appConfigObj;
		}
		else{
			throw new SimpplrException('Please select GA3 or GA4');
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
    public App_Config__c saveCampaignsIntegrationsConfig(ManageApplicationWrapper.CampaignsIntegrationsWrapper integrationObj) {
		if(integrationObj.employeeAdvocacy == true && integrationObj.facebookEnabled == false && integrationObj.twitterEnabled == false && integrationObj.linkedInEnabled == false) {
			LocaleContext.getAllLabelMap('SettingDataServer', new List<String>{UserContext.languageLocaleKey});
			throw new SimpplrException(LocaleContext.getLabel(UserContext.languageLocaleKey,ERROR_SOCIAL_CAMPAIGN_ENABLED_WITHOUT_NETWORK));
		}

    	String appConfigQuery = 'SELECT Id , Employee_Advocacy_Enabled__c, App_Integrations_Enabled__c, Last_Edited_DateTime__c FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		App_Config__c appConfig = listOfAppConfig[0];

		String appIntegrationsEnabled = '';
		if(integrationObj.employeeAdvocacy == true){
			if((integrationObj.facebookEnabled == false) || (integrationObj.twitterEnabled == false) || (integrationObj.linkedInEnabled == false)){
				expireActiveCampaigns(integrationObj);	
			}
			if(integrationObj.facebookEnabled == true) {
				appIntegrationsEnabled = IntegrationConstants.INTEGRATION_TYPE_FACEBOOK;
			}
			if(integrationObj.twitterEnabled == true) {
				appIntegrationsEnabled = (String.isBlank(appIntegrationsEnabled) ?  '' : appIntegrationsEnabled + ';') + IntegrationConstants.INTEGRATION_TYPE_TWITTER;
			}
			if(integrationObj.linkedInEnabled == true) {
				appIntegrationsEnabled = (String.isBlank(appIntegrationsEnabled) ?  '' : appIntegrationsEnabled + ';') + IntegrationConstants.INTEGRATION_TYPE_LINKEDIN;
			}
		} else{
			integrationObj.facebookEnabled = false;
			integrationObj.twitterEnabled = false;
			integrationObj.linkedInEnabled = false;
			expireActiveCampaigns(integrationObj);
			Database.executeBatch(new BatchDeleteIntegrationRecords(new List<String>{'facebook','twitter','linkedin'}),2000);
		}
		
		updateAppIntegration(integrationObj);
		appConfig.App_Integrations_Enabled__c = appIntegrationsEnabled;
		appConfig.Employee_Advocacy_Enabled__c = integrationObj.employeeAdvocacy;
		appConfig.Last_Edited_DateTime__c = DateTime.now();
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(new Map<id,App_Config__c>(listOfAppConfig),  new List<Schema.SObjectField>{
														App_Config__c.Employee_Advocacy_Enabled__c,
                                                        App_Config__c.App_Integrations_Enabled__c,
														App_Config__c.Last_Edited_DateTime__c});
                                                            
	    return appConfig;													
    } 
    
    private static void expireActiveCampaigns(ManageApplicationWrapper.CampaignsIntegrationsWrapper integrationObj){
    	String queryString = 'SELECT id, Facebook_Share_Enabled__c, Twitter_Share_Enabled__c, Linkedin_Share_Enabled__c, Is_Active__c FROM Social_Campaign__c WHERE Is_Active__c = true AND Is_Deleted__c = false';
		String queryStringOrCondition = '';
		if(integrationObj.facebookEnabled == false){
			queryStringOrCondition += 'Facebook_Share_Enabled__c = true';	
		}  
		if(integrationObj.twitterEnabled == false){
			queryStringOrCondition += ' OR Twitter_Share_Enabled__c = true';	
		} 
		if(integrationObj.linkedInEnabled == false){
			queryStringOrCondition += ' OR Linkedin_Share_Enabled__c = true';	
		} 				 
		if(String.isNotBlank(queryStringOrCondition) && queryStringOrCondition.startsWith(' OR ')){
			queryStringOrCondition = queryStringOrCondition.removeStart(' OR ');	
		}
		if(String.isNotBlank(queryStringOrCondition)) {
			queryString += ' AND (' + queryStringOrCondition + ')';	
		}	
		queryString += ' ORDER BY createdDate desc LIMIT 9000';
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Social_Campaign__c> socialCampaignsActiveList = (List<Social_Campaign__c>)SIMPESAPI.accessController().queryAsUser(queryString, null);
		if(!socialCampaignsActiveList.isEmpty()){
			for(Social_Campaign__c socialCampaignsActive : socialCampaignsActiveList){
				if(integrationObj.facebookEnabled == false){
					socialCampaignsActive.Facebook_Share_Enabled__c = false;	
				}
				if(integrationObj.twitterEnabled == false){
					socialCampaignsActive.Twitter_Share_Enabled__c = false;	
				}
				if(integrationObj.linkedInEnabled == false){
					socialCampaignsActive.Linkedin_Share_Enabled__c = false;	
				}
				
				if((socialCampaignsActive.Facebook_Share_Enabled__c == false) && (socialCampaignsActive.Twitter_Share_Enabled__c == false) && (socialCampaignsActive.Linkedin_Share_Enabled__c == false)){
					socialCampaignsActive.Is_Active__c = false;	
				}								
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Social_Campaign__c>(socialCampaignsActiveList),  new List<Schema.SObjectField>{
				Social_Campaign__c.Facebook_Share_Enabled__c,
				Social_Campaign__c.Twitter_Share_Enabled__c,
				Social_Campaign__c.Linkedin_Share_Enabled__c,
				Social_Campaign__c.Is_Active__c});			
		}				
    } 
    
    private static void updateAppIntegration(ManageApplicationWrapper.CampaignsIntegrationsWrapper integrationObj){
    	Map<String,App_Integration__c> mapOfAppIntObject= new Map<String,App_Integration__c>();
    	List<App_Integration__c> listToUpdate = new List<App_Integration__c>();
    	List<App_Integration__c> listToInsert = new List<App_Integration__c>();
    	List<App_Integration__c> listToDelete = new List<App_Integration__c>();
    	
    	List<String> connectedAppsToDelete = new List<String>();
    	
    	mapOfAppIntObject.putAll(SimpplrContext.Integrations);
    	
    	if(mapOfAppIntObject.containsKey('facebook')){
    		if(integrationObj.facebookEnabled == true) {
    			listToUpdate.add(new App_Integration__c(Id=mapOfAppIntObject.get('facebook').Id, 
    													Connected__c=integrationObj.facebookEnabled,
														Integration_Enabled__c = true,
    													Client_Id__c=IntegrationConstants.FACEBOOK_CLIENT_ID,
    													Client_Secret__c=IntegrationConstants.FACEBOOK_CLIENT_SECRET,
    													name='facebook', 
    													Scope_Required__c=true, 
    													Org_Id__c = UserInfo.getOrganizationId(),
    													Scope__c='publish_actions'));
    		} else {
    			connectedAppsToDelete.add('facebook');
    		}
    	} else if((integrationObj.facebookEnabled == true) && !mapOfAppIntObject.containsKey('facebook')){
    		listToInsert.add(new App_Integration__c(Connected__c=integrationObj.facebookEnabled,
													Integration_Enabled__c = true,
    												Client_Id__c=IntegrationConstants.FACEBOOK_CLIENT_ID,
    												Client_Secret__c=IntegrationConstants.FACEBOOK_CLIENT_SECRET,
    												name='facebook',
    												Scope_Required__c=true,
    												Org_Id__c = UserInfo.getOrganizationId(), 
    												Scope__c='publish_actions'));
    	}
    	
    	if(mapOfAppIntObject.containsKey('twitter')){
    		if(integrationObj.twitterEnabled == true) {
    			listToUpdate.add(new App_Integration__c(Id=mapOfAppIntObject.get('twitter').Id,
    													Integration_Enabled__c = true,
														Connected__c=integrationObj.twitterEnabled, 
    													Client_Id__c=IntegrationConstants.TWITTER_CLIENT_ID,
    													Client_Secret__c=IntegrationConstants.TWITTER_CLIENT_SECRET,
														Scope_Required__c=false,
    													Org_Id__c = UserInfo.getOrganizationId(),
    													name='twitter'));
    		} else {
    			connectedAppsToDelete.add('twitter');
    		}
    	} else if(integrationObj.twitterEnabled == true && !mapOfAppIntObject.containsKey('twitter')){
    		listToInsert.add(new App_Integration__c(Connected__c=integrationObj.twitterEnabled,
    												Integration_Enabled__c = true,
													Client_Id__c=IntegrationConstants.TWITTER_CLIENT_ID,
    												Client_Secret__c=IntegrationConstants.TWITTER_CLIENT_SECRET,
													Scope_Required__c=false,
    												Org_Id__c = UserInfo.getOrganizationId(),
    												name='twitter'));
    	}
    	
    	if(mapOfAppIntObject.containsKey('linkedin')){
    		if(integrationObj.linkedInEnabled == true) {
    			listToUpdate.add(new App_Integration__c(Id=mapOfAppIntObject.get('linkedin').Id, 
														Integration_Enabled__c = true,
    													Connected__c=integrationObj.linkedInEnabled,
    													Client_Id__c=IntegrationConstants.LINKEDIN_CLIENT_ID,
    													Client_Secret__c=IntegrationConstants.LINKEDIN_CLIENT_SECRET,
    													Org_Id__c = UserInfo.getOrganizationId(),
														Scope__c='r_liteprofile%20w_member_social',
														Scope_Required__c=true,
    													name='linkedin'));    		
    		} else {
    			connectedAppsToDelete.add('linkedin');
    		}
    	} else if(integrationObj.linkedInEnabled == true && !mapOfAppIntObject.containsKey('linkedin')){
    		listToInsert.add(new App_Integration__c(Connected__c=integrationObj.linkedInEnabled,
    												Integration_Enabled__c = true,
													Client_Id__c=IntegrationConstants.LINKEDIN_CLIENT_ID,
    												Client_Secret__c=IntegrationConstants.LINKEDIN_CLIENT_SECRET,
    												Org_Id__c = UserInfo.getOrganizationId(),
													Scope__c='r_liteprofile%20w_member_social',
													Scope_Required__c=true,
    												name='linkedin'));
    	}
    	
    	if(listToUpdate.size()>0){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Integration__c>(listToUpdate),  new List<Schema.SObjectField>{
				App_Integration__c.Integration_Enabled__c,
				App_Integration__c.Connected__c,
				App_Integration__c.Client_Id__c,
				App_Integration__c.Client_Secret__c,
				App_Integration__c.Org_Id__c,
				App_Integration__c.Scope__c,
				App_Integration__c.Scope_Required__c,
				App_Integration__c.Name});
    	}
    	
    	if(listToInsert.size()>0){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        	SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
				App_Integration__c.Integration_Enabled__c,
				App_Integration__c.Connected__c,
				App_Integration__c.Client_Id__c,
				App_Integration__c.Client_Secret__c,
				App_Integration__c.Org_Id__c,
				App_Integration__c.Scope__c,
				App_Integration__c.Scope_Required__c,
				App_Integration__c.Name});      
    	}
    	
    	if(connectedAppsToDelete.size()>0){
    		Database.executeBatch(new BatchDeleteIntegrationRecords(connectedAppsToDelete),2000);
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
	public ManageApplicationWrapper.LicensingPeopleWrapper fetchLincensingPeople(){
		ManageApplicationWrapper.LicensingPeopleWrapper licensingPeopleWrapper = new ManageApplicationWrapper.licensingPeopleWrapper();
        String appConfigQuery = 'SELECT Auto_provisioning_Process_Enabled__c ,Auto_Free_Simpplr_License_Enabled__c From App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
	    licensingPeopleWrapper = toLincensingPeopleWrapper(listOfAppConfig);
	    return licensingPeopleWrapper;
	}

	private ManageApplicationWrapper.LicensingPeopleWrapper toLincensingPeopleWrapper(List<App_Config__c> appConfigObj) {
        ManageApplicationWrapper.LicensingPeopleWrapper licensingPeopleWrapper = new ManageApplicationWrapper.licensingPeopleWrapper();   	
 
		licensingPeopleWrapper.autoProvisioningProcessEnabled = appConfigObj[0].Auto_provisioning_Process_Enabled__c;
		licensingPeopleWrapper.autoFreeSimpplrLicenseEnabled = appConfigObj[0].Auto_Free_Simpplr_License_Enabled__c;

	    return licensingPeopleWrapper;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public ManageApplicationWrapper.SMSNotificationWrapper getSMSNotificationsSettings(List<App_Default__c> listOfAppDefault){
		ManageApplicationWrapper.SMSNotificationWrapper defaultSMSNotificationsWrapper = new ManageApplicationWrapper.SMSNotificationWrapper();

		defaultSMSNotificationsWrapper.isProcessing = false;
		if(!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)){
			defaultSMSNotificationsWrapper.isProcessing = listOfAppDefault[0].OverwriteBatchInProgress__c;
			defaultSMSNotificationsWrapper = (ManageApplicationWrapper.SMSNotificationWrapper)JSON.deserialize(listOfAppDefault[0].Data__c,ManageApplicationWrapper.SMSNotificationWrapper.class);		
			
			defaultSMSNotificationsWrapper.modifiedAt = Utility.dateTimeToMomentJSDateTime(listOfAppDefault[0].LastModifiedDate);
			defaultSMSNotificationsWrapper.modifiedBy = new ManageApplicationWrapper.UserWrapper();
			defaultSMSNotificationsWrapper.modifiedBy.peopleId = listOfAppDefault[0].Last_Modified_By_People__c;
			defaultSMSNotificationsWrapper.modifiedBy.name = listOfAppDefault[0].Last_Modified_By_People__r.Full_Name__c;
		} else {  
			PostInstallHelper piHelper = new PostInstallHelper();
			defaultSMSNotificationsWrapper = piHelper.getDefaultSMSNotificationSettings();
		}     
        
		defaultSMSNotificationsWrapper.isApplyToAllUsers = null;

	    return defaultSMSNotificationsWrapper;
	}

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public ManageApplicationWrapper.MobileAppNotificationWrapper getNativeMobileAppNotificationsSettings(List<App_Default__c> listOfAppDefault){
		ManageApplicationWrapper.MobileAppNotificationWrapper mobileAppNotificationsWrapper = new ManageApplicationWrapper.MobileAppNotificationWrapper();
		
		mobileAppNotificationsWrapper.isProcessing = false;
		if(!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)){
			mobileAppNotificationsWrapper.isProcessing = listOfAppDefault[0].OverwriteBatchInProgress__c;
			mobileAppNotificationsWrapper = (ManageApplicationWrapper.MobileAppNotificationWrapper)JSON.deserialize(listOfAppDefault[0].Data__c,ManageApplicationWrapper.MobileAppNotificationWrapper.class);		
			
			mobileAppNotificationsWrapper.modifiedAt = Utility.dateTimeToMomentJSDateTime(listOfAppDefault[0].LastModifiedDate);
			mobileAppNotificationsWrapper.modifiedBy = new ManageApplicationWrapper.UserWrapper();
			mobileAppNotificationsWrapper.modifiedBy.peopleId = listOfAppDefault[0].Last_Modified_By_People__c;
			mobileAppNotificationsWrapper.modifiedBy.name = listOfAppDefault[0].Last_Modified_By_People__r.Full_Name__c;
		} else {  
			PostInstallHelper piHelper = new PostInstallHelper();
			mobileAppNotificationsWrapper = piHelper.getDefaultMobileAppNotificationSettings();
    	}
		mobileAppNotificationsWrapper.isApplyToAllUsers = null;

	    return mobileAppNotificationsWrapper;
	}
    
    /**
     * 
     * @param onboardingSiteList set of ids for selected onboarding sites
     */
    private void updateSiteAndSiteRole(Set<String> onboardingSiteList,String onboardingSitePermission) {
        String siteQuery = 'SELECT Id, Chatter_Group_Id__c, Is_Onboarding_Enabled__c, (SELECT Id, Is_Manager__c, Is_Content_Manager__c, People__c FROM Site_Roles__r WHERE Is_Deleted__c = false) '+
                                'FROM Simpplr_Site__c WHERE Is_Active__c = true and Is_Deleted__c = false AND (Id IN :soqlParam1 OR Is_Onboarding_Enabled__c = true)';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        Map<String, Object> soqlParams = new Map<String, Object>();
        soqlParams.put('soqlParam1', onboardingSiteList);
        List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>) SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParams);
        for(Simpplr_Site__c siteObj:siteList) {
            siteObj.Is_Onboarding_Enabled__c = ServiceConstants.CONTENT_ONBOARDING_ALL_SITES.equals(onboardingSitePermission) ? false : (onboardingSiteList.contains(siteObj.Id) ? true : false);
        }
        SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{Simpplr_Site__c.Is_Onboarding_Enabled__c});
    }

    public void savePrivilegesConfigData (ManageApplicationWrapper.PrivilegesSetsWrapper privilegesSetupObj, Boolean isCampaignManagerFeatureEnabled) {
		Set<String> influencersset = new Set<String>(); 
		Set<String> newsletterControlPeople = new Set<String>(); 
		Set<String> canAccessAnalyticsset = new Set<String>(); 
		Set<String> isNewsletterAllowedset = new Set<String>(); 
		Set<String> mustReadEnabledSites = new Set<String>();
		Set<String> canAccessAlertsPeople = new Set<String>();
		Set<String> alertsControlSite = new Set<String>();
		Set<String> canControlHomeDashboard = new Set<String>();
		Set<String> canManageSocialCampaign = new Set<String>();
		Set<String> unlistedSitesManagingPeopleIdSet = new Set<String>();
    	Set<String> appManagingPeopleIdSet = new Set<String>();
    	Set<String> campaignManagingPeopleIdSet = new Set<String>();
    	Set<String> userIdSet = new Set<String>();
		Set<String> addSitesUserSet = new Set<String>();
		Set<String> protectedAuthorAllowlistedSet = new Set<String>();
		Set<String> protectedAuthorSet = new Set<String>();
    	String addSitesPermission = '';
		Set<String> onboardingPeopleList = new Set<String>();
		Set<String> onboardingSiteList = new Set<String>();
    	String onboardingSitePermission = '';
		String leadercastPermission;
		Set<String> leadercastControlPeopleSet;
		Set<String> leadercastControlSitesSet;
		Set<String> initiativesAndCampaignsManagers = new Set<String>();
		Boolean isAIContentModerationEnabled;
		Set<String> contentModeratorPeoplelist = new Set<String>();
		Boolean isOnboardingEnabled;
		Boolean isMyTeamsAnalyticsSettingEnabled;
		
		influencersset = ((privilegesSetupObj.influencers == null) ? influencersset : privilegesSetupObj.influencers);
		newsletterControlPeople = ((privilegesSetupObj.newsletterControlPeople == null) ? newsletterControlPeople : privilegesSetupObj.newsletterControlPeople);
		canAccessAnalyticsset = ((privilegesSetupObj.analyticsAccess == null) ? canAccessAnalyticsset : privilegesSetupObj.analyticsAccess);
		canAccessAlertsPeople = ((privilegesSetupObj.canAccessAlertsPeople == null) ?  canAccessAlertsPeople : privilegesSetupObj.canAccessAlertsPeople);
		alertsControlSite = ((privilegesSetupObj.alertsControlSite == null) ? alertsControlSite : privilegesSetupObj.alertsControlSite);
		canControlHomeDashboard = ((privilegesSetupObj.canControlHomeDashboard == null) ? canControlHomeDashboard : privilegesSetupObj.canControlHomeDashboard);
		canManageSocialCampaign = ((privilegesSetupObj.canManageSocialCampaign == null) ? canManageSocialCampaign : privilegesSetupObj.canManageSocialCampaign);
		unlistedSitesManagingPeopleIdSet = ((privilegesSetupObj.unlistedSitesManagingPeopleIdSet == null) ? unlistedSitesManagingPeopleIdSet : privilegesSetupObj.unlistedSitesManagingPeopleIdSet);
		appManagingPeopleIdSet = ((privilegesSetupObj.appManagingPeopleIdSet == null) ? appManagingPeopleIdSet : privilegesSetupObj.appManagingPeopleIdSet);
		campaignManagingPeopleIdSet = ((privilegesSetupObj.campaignManagingPeopleIdSet == null) ? campaignManagingPeopleIdSet : privilegesSetupObj.campaignManagingPeopleIdSet);
		addSitesUserSet = ((privilegesSetupObj.addSitesUserSet == null) ? addSitesUserSet : privilegesSetupObj.addSitesUserSet);
		protectedAuthorAllowlistedSet = ((privilegesSetupObj.protectedAuthorAllowlisted == null) ? protectedAuthorAllowlistedSet : privilegesSetupObj.protectedAuthorAllowlisted);
		protectedAuthorSet = ((privilegesSetupObj.protectedAuthor == null) ? protectedAuthorSet : privilegesSetupObj.protectedAuthor);
		addSitesPermission = privilegesSetupObj.addSitesPermission;

        onboardingPeopleList = ((privilegesSetupObj.onboardingPeopleList == null) ? onboardingPeopleList : privilegesSetupObj.onboardingPeopleList);
		onboardingSiteList = ((privilegesSetupObj.onboardingSiteList == null) ? onboardingSiteList : privilegesSetupObj.onboardingSiteList);
        onboardingSitePermission = ((privilegesSetupObj.onboardingSitePermission == null) ? onboardingSitePermission  : privilegesSetupObj.onboardingSitePermission);
		leadercastPermission = privilegesSetupObj.leadercastPermission;
		leadercastControlPeopleSet = privilegesSetupObj.leadercastControlPeople;
		leadercastControlSitesSet = privilegesSetupObj.leadercastControlSites;
		initiativesAndCampaignsManagers = ((privilegesSetupObj.initiativesAndCampaignsManagers == null) ? initiativesAndCampaignsManagers : privilegesSetupObj.initiativesAndCampaignsManagers);
		
		isAIContentModerationEnabled = privilegesSetupObj.isAIContentModerationEnabled != null ? privilegesSetupObj.isAIContentModerationEnabled : false;
		contentModeratorPeoplelist = ((privilegesSetupObj.contentModeratorPeoplelist == null) ? contentModeratorPeoplelist : privilegesSetupObj.contentModeratorPeoplelist);
		isOnboardingEnabled = privilegesSetupObj.isOnboardingEnabled != null ? privilegesSetupObj.isOnboardingEnabled : true;
		isMyTeamsAnalyticsSettingEnabled = privilegesSetupObj.isMyTeamsAnalyticsSettingEnabled != null ? privilegesSetupObj.isMyTeamsAnalyticsSettingEnabled : true;

		if (String.isNotBlank(addSitesPermission)) {
			updateAppConfig(addSitesPermission, leadercastPermission);
		}
		isNewsletterAllowedset = privilegesSetupObj.newsletterControlSite;
		mustReadEnabledSites = privilegesSetupObj.mustReadsControlSite;

		List<People__c> listOfPplObjToUpdate = new List<People__c>();
		List<People__c> peopleList = new List<People__c>();
		Set<String> grantedUserForOrgOnboardingSet = new Set<String>();

		if(isOnboardingEnabled != null) {
            App_Config__c appConfigObj = new App_Config__c(Id = SimpplrContext.appConfig.Id);
            appConfigObj.Is_Onboarding_Disabled__c = ('true'.equalsIgnoreCase(String.valueOf(isOnboardingEnabled))) ? false : true;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{App_Config__c.Is_Onboarding_Disabled__c});
        }
		
		if(isMyTeamsAnalyticsSettingEnabled != null) {
            App_Config__c appConfigObj = new App_Config__c(Id = SimpplrContext.appConfig.Id);
            appConfigObj.Is_My_Teams_Analytics_Enabled__c = isMyTeamsAnalyticsSettingEnabled;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{App_Config__c.Is_My_Teams_Analytics_Enabled__c});
        }

        if(onboardingPeopleList != null) {
            String pplQuery = 'SELECT Id, Enable_Org_Level_Onboarding__c, User__c FROM People__c WHERE  User__r.IsActive = true AND (Id IN :soqlParam1 OR Enable_Org_Level_Onboarding__c = true)';
            Map<String, Object> soqlParams = new Map<String, Object>();
            soqlParams.put('soqlParam1', onboardingPeopleList);
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            peopleList = (List<People__c>) SIMPESAPI.accessController().queryAsUser(pplQuery, soqlParams);
			for (People__c ppl: peopleList) {
				if (ppl.Enable_Org_Level_Onboarding__c == false) {
					grantedUserForOrgOnboardingSet.add(ppl.User__c);
				}
                ppl.Enable_Org_Level_Onboarding__c = onboardingPeopleList.contains(ppl.Id) ? true : false;
            }
			SIMPESAPI.accessController().updateAsUser(new Map<Id, People__c>(peopleList), new List<Schema.SObjectField>{People__c.Enable_Org_Level_Onboarding__c});
        }

		if(!String.isBlank(onboardingSitePermission) && 
            ServiceConstants.CONTENT_ONBOARDING_SELECTED_SITES.equals(onboardingSitePermission)) {
            App_Config__c appConfigObj = new App_Config__c(Id = SimpplrContext.appConfig.Id);
            appConfigObj.Site_Level_Onboarding__c = onboardingSitePermission;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{App_Config__c.Site_Level_Onboarding__c});
        }

		if(!String.isBlank(onboardingSitePermission) && 
            ServiceConstants.CONTENT_ONBOARDING_ALL_SITES.equals(onboardingSitePermission)) {
            App_Config__c appConfigObj = new App_Config__c(Id = SimpplrContext.appConfig.Id);
			appConfigObj.Site_Level_Onboarding__c = onboardingSitePermission;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{App_Config__c.Site_Level_Onboarding__c});
            if(onboardingSiteList != null) {
                updateSiteAndSiteRole(onboardingSiteList,onboardingSitePermission);
            }
        }

        if(onboardingSiteList != null && 
            !String.isBlank(onboardingSitePermission) && 
            !ServiceConstants.CONTENT_ONBOARDING_ALL_SITES.equals(onboardingSitePermission)) {
                updateSiteAndSiteRole(onboardingSiteList,onboardingSitePermission);
        }

		if(isAIContentModerationEnabled != null) {
            App_Config__c appConfigObj = new App_Config__c(Id = SimpplrContext.appConfig.Id);
            appConfigObj.Content_Moderation_Enabled__c = isAIContentModerationEnabled;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{App_Config__c.Content_Moderation_Enabled__c});
        }
        

		
        
		String query =  'Select Id, Can_Control_Dashboard__c from People__c Where (Id IN : canControlHomeDashboard or Can_Control_Dashboard__c = true )';	
		
		if (Utility.isApiOnlyUserQueryable()) {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false))';

		} else {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\'))';
		}
		
		peopleList = DataBase.query(query);	
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList) {
				
				if (canControlHomeDashboard != null && canControlHomeDashboard.contains(ppl.id)) {
					ppl.Can_Control_Dashboard__c = true;
				
				} else {
					ppl.Can_Control_Dashboard__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.Can_Control_Dashboard__c});
		}
		
		listOfPplObjToUpdate.clear();
		peopleList.clear();
		
		query =  'Select Id, Is_Campaign_Manager__c from People__c Where (Id IN : canManageSocialCampaign or Is_Campaign_Manager__c = true )';	
		
		if (Utility.isApiOnlyUserQueryable()) {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false))';
		
		} else {
			query += ' AND (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\'))';
		}
		
		peopleList = DataBase.query(query);
		Set<String> grantedUserForEmployeeAdvocacy = new Set<String>();
		
		if (!SimpplrContext.isEmployeeAdvocacyEnabled && !peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList) {
				ppl.Is_Campaign_Manager__c = true;
				listOfPplObjToUpdate.add(ppl);
			}
			
		} else if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList) {
				
				if (canManageSocialCampaign != null && canManageSocialCampaign.contains(ppl.id)) {
					
					if (ppl.Is_Campaign_Manager__c == false) {
						grantedUserForEmployeeAdvocacy.add(ppl.Id);
					}
					
					ppl.Is_Campaign_Manager__c = true;
				
				} else {
					ppl.Is_Campaign_Manager__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.Is_Campaign_Manager__c});
		}
		
		listOfPplObjToUpdate.clear();
		peopleList.clear();

		peopleList = [SELECT Id, CI_Moderation_Permission__c FROM People__c WHERE Id IN : initiativesAndCampaignsManagers or CI_Moderation_Permission__c = true WITH SECURITY_ENFORCED ];	
		for (People__c ppl: peopleList) {
				
			if (initiativesAndCampaignsManagers != null && initiativesAndCampaignsManagers.contains(ppl.id)) {
				ppl.CI_Moderation_Permission__c = true;
			} else {
				ppl.CI_Moderation_Permission__c = false;					
			}
			
			listOfPplObjToUpdate.add(ppl);
		}
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.CI_Moderation_Permission__c});
		}
		listOfPplObjToUpdate.clear();
		peopleList.clear();

		peopleList = [SELECT Id, Is_Influencer__c 
				FROM People__c 
				WHERE User__r.IsActive = true AND (Id IN : influencersset or Is_Influencer__c = true) WITH SECURITY_ENFORCED];	
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList){
			
				if (influencersset != null && influencersset.contains(ppl.id)) {
					ppl.Is_Influencer__c = true;
					
				} else {
					ppl.Is_Influencer__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate), 
					new List<Schema.SObjectField>{People__c.Is_Influencer__c});
		}
		
		listOfPplObjToUpdate.clear();
		peopleList.clear();
		peopleList = [SELECT Id, Can_Send_Newsletter__c, User__c 
				FROM People__c 
				WHERE User__r.IsActive = true and 
				(Id IN : newsletterControlPeople or Can_Send_Newsletter__c = true) WITH SECURITY_ENFORCED];	
		Set<String> grantedUserForNewsletterSet = new Set<String>();
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl : peopleList) {
			
				if (newsletterControlPeople != null && newsletterControlPeople.contains(ppl.id)) {
					
					if (ppl.Can_Send_Newsletter__c == false) {
						grantedUserForNewsletterSet.add(ppl.User__c);
					}
					
					ppl.Can_Send_Newsletter__c = true;
				
				} else {
					ppl.Can_Send_Newsletter__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),
					new List<Schema.SObjectField>{People__c.Can_Send_Newsletter__c});
		}
		
		listOfPplObjToUpdate.clear();
		peopleList.clear();
		peopleList = [SELECT Id, Can_Access_Analytics__c 
				FROM People__c 
				WHERE User__r.IsActive = true and 
				(Id IN : canAccessAnalyticsset or Can_Access_Analytics__c = true) WITH SECURITY_ENFORCED];	
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList) {
				
				if (canAccessAnalyticsset != null && canAccessAnalyticsset.contains(ppl.id)) {
					ppl.Can_Access_Analytics__c = true;
					
				} else {
					ppl.Can_Access_Analytics__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id, People__c>(listOfPplObjToUpdate),
					new List<Schema.SObjectField>{People__c.Can_Access_Analytics__c});
		}
		
		listOfPplObjToUpdate.clear();
		peopleList = [SELECT Id, Can_Send_Alert__c 
				FROM People__c 
				WHERE User__r.IsActive = true AND 
				(Id IN : canAccessAlertsPeople or Can_Send_Alert__c = true) WITH SECURITY_ENFORCED];	
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList){
				
				if (canAccessAlertsPeople != null && canAccessAlertsPeople.contains(ppl.id)) {
					ppl.Can_Send_Alert__c = true;
					
				} else {
					ppl.Can_Send_Alert__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.Can_Send_Alert__c});
		}

		listOfPplObjToUpdate.clear();
		peopleList = [SELECT Id, Can_Access_Leadercast__c 
				FROM People__c 
				WHERE User__r.IsActive = true AND 
				(Id IN : leadercastControlPeopleSet or Can_Access_Leadercast__c = true) WITH SECURITY_ENFORCED];	
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList){
				
				if (leadercastControlPeopleSet != null && leadercastControlPeopleSet.contains(ppl.id)) {
					ppl.Can_Access_Leadercast__c = true;
					
				} else {
					ppl.Can_Access_Leadercast__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.Can_Access_Leadercast__c});
		}

		listOfPplObjToUpdate.clear();
		peopleList = [SELECT Id, Is_Protected_Author_Allowlisted__c 
				FROM People__c 
				WHERE User__r.IsActive = true AND 
				(Id IN : protectedAuthorAllowlistedSet or Is_Protected_Author_Allowlisted__c = true) WITH SECURITY_ENFORCED];	
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList){
				
				if (protectedAuthorAllowlistedSet != null && protectedAuthorAllowlistedSet.contains(ppl.id)) {
					ppl.Is_Protected_Author_Allowlisted__c = true;
					
				} else {
					ppl.Is_Protected_Author_Allowlisted__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.Is_Protected_Author_Allowlisted__c});
		}

		listOfPplObjToUpdate.clear();
		peopleList = [SELECT Id, Is_Protected_Author__c 
				FROM People__c 
				WHERE User__r.IsActive = true AND 
				(Id IN : protectedAuthorSet or Is_Protected_Author__c = true) WITH SECURITY_ENFORCED];	
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList){
				
				if (protectedAuthorSet != null && protectedAuthorSet.contains(ppl.id)) {
					ppl.Is_Protected_Author__c = true;
					
				} else {
					ppl.Is_Protected_Author__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.Is_Protected_Author__c});
		}

		// update users list who can add site
		listOfPplObjToUpdate.clear();
		listOfPplObjToUpdate = updatePeopleWhoCanAddSites(addSitesUserSet); 
		
		// update users list who have AI content moderator permissions
		listOfPplObjToUpdate.clear();
		listOfPplObjToUpdate = updatePeopleWhoAreContentModerator(contentModeratorPeoplelist); 

		// Allow UnlistedSiteManger/App Manager editing only if the user have manage user permissions
		if(UserContext.canManageInternalUsers){
			String simpplrUnlistedSiteMangerPermSet = UNLISTED_SITE_MANAGERS_PERMISSION_NAME;
			// User id set whom permission set assignment has to be removed.
			Set<String> removePermissionsUserIdSet = new Set<String>();
			// User ids of the users who are not assigned to this PS or already have this PS.
			Set<String> newOrExistingPermissionsUserIdIdSet = new Set<String>();
			
			List<PermissionSet> permissionSetList = [SELECT Id FROM PermissionSet WHERE Name = :simpplrUnlistedSiteMangerPermSet WITH SECURITY_ENFORCED];
			if(permissionSetList.isEmpty()){
				throw new SimpplrException(UNLISTED_SITE_MANAGER_PERMISSION_SET_ERROR);
			}
			List<String> permissionSetIdList = new List<String>();
			for(PermissionSet obj : permissionSetList) {
				permissionSetIdList.add(obj.Id);
			}
			
			listOfPplObjToUpdate.clear();
			userIdSet.clear();
			peopleList = [SELECT Id, Unlisted_Site_Moderation_Permission__c, User__c   
					FROM People__c 
					WHERE User__r.IsActive = true AND 
					(Id IN : unlistedSitesManagingPeopleIdSet OR Unlisted_Site_Moderation_Permission__c = 'Yes') WITH SECURITY_ENFORCED];	
			
			if (!peopleList.isEmpty()) {
				
				for (People__c ppl: peopleList){
					
					if (unlistedSitesManagingPeopleIdSet.contains(ppl.id)) {
						newOrExistingPermissionsUserIdIdSet.add(ppl.User__c);
						
						ppl.Unlisted_Site_Moderation_Permission__c = 'Yes';
					} else {
						ppl.Unlisted_Site_Moderation_Permission__c = 'No';
						
						removePermissionsUserIdSet.add(ppl.User__c);					
					}
					
					userIdSet.add(ppl.User__c);
					listOfPplObjToUpdate.add(ppl);
	    		} 
			}

			// Update sharing of draft content's titleimages(ContentDocument)'s with unlisted Site Managers
			updateAccessToUnlistedSiteFiles(newOrExistingPermissionsUserIdIdSet, removePermissionsUserIdSet);
			
			if (listOfPplObjToUpdate.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),
						new List<Schema.SObjectField>{People__c.Unlisted_Site_Moderation_Permission__c});
				
				syncGroupMembers(simpplrUnlistedSiteMangerPermSet, newOrExistingPermissionsUserIdIdSet);
				// assign/remove unlisted site manager permission set
				assignRemovePermissionSet(permissionSetIdList, newOrExistingPermissionsUserIdIdSet, removePermissionsUserIdSet);
			}
			
			if(UserContext.canManageInternalUsers){
				String simpplrAppMangerPermSet = APP_MANAGERS_PERMISSION_NAME;
				String simpplrAppMangerViewAllPermSet = APP_MANAGER_VIEW_ALL_PERMISSION_NAME;
				// User id set whom permission set assignment has to be removed.
				Set<String> removeAppPermissionsUserIdSet = new Set<String>();
				// User ids of the users who are not assigned to this PS or already have this PS.
				Set<String> newOrExistingAppPermissionsUserIdIdSet = new Set<String>();
				
				List<PermissionSet> appPermissionSetList = [SELECT Id FROM PermissionSet WHERE Name = :simpplrAppMangerPermSet or (Name = :simpplrAppMangerViewAllPermSet AND NamespacePrefix = :SimpplrContext.packageName) WITH SECURITY_ENFORCED];
				if(appPermissionSetList.size() < 2){
					throw new SimpplrException(APP_MANAGERS_PERMISSION_SET_ERROR);
				}
				List<String> appPermissionSetIdList = new List<String>();
				for(PermissionSet obj : appPermissionSetList) {
					appPermissionSetIdList.add(obj.Id);
				}
				
				listOfPplObjToUpdate.clear();
				userIdSet.clear();
				peopleList = [SELECT Id, App_Moderation_Permission__c, User__c   
						FROM People__c 
						WHERE User__r.IsActive = true AND User__r.UserType = 'Standard' AND 
						(Id IN : appManagingPeopleIdSet OR App_Moderation_Permission__c = 'Yes') WITH SECURITY_ENFORCED];	
				
				if (!peopleList.isEmpty()) {
					for (People__c ppl: peopleList){
						if (appManagingPeopleIdSet.contains(ppl.id)) {
							newOrExistingAppPermissionsUserIdIdSet.add(ppl.User__c);
							
							ppl.App_Moderation_Permission__c = 'Yes';
						} else {
							ppl.App_Moderation_Permission__c = 'No';
							
							removeAppPermissionsUserIdSet.add(ppl.User__c);					
						}
						
						userIdSet.add(ppl.User__c);
						listOfPplObjToUpdate.add(ppl);
		    		}
				}
				
				// Update sharing of draft content's titleimages(ContentDocument)'s with appManagers
				updateAccessToFiles(newOrExistingAppPermissionsUserIdIdSet, removeAppPermissionsUserIdSet);
				
				if (listOfPplObjToUpdate.size() > 0) {
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),
							new List<Schema.SObjectField>{People__c.App_Moderation_Permission__c});
					
					syncGroupMembers(simpplrAppMangerPermSet, newOrExistingAppPermissionsUserIdIdSet);
					
					// assign/remove app manager permission set
					assignRemovePermissionSet(appPermissionSetIdList, newOrExistingAppPermissionsUserIdIdSet, removeAppPermissionsUserIdSet);
				}
			}
		}

		if(isCampaignManagerFeatureEnabled == true){
		    listOfPplObjToUpdate.clear();
			userIdSet.clear();
			Set<String> newOrExistingPermissionsUserIdIdSet = new Set<String>();
			peopleList = [SELECT Id, Campaign_Moderation_Permission__c, User__c   
					FROM People__c 
					WHERE User__r.IsActive = true AND User__r.UserType = 'Standard' AND 
					(Id IN : campaignManagingPeopleIdSet OR Campaign_Moderation_Permission__c = 'Yes') WITH SECURITY_ENFORCED];	
				
			if (!peopleList.isEmpty()) {
				for (People__c ppl: peopleList){
					if (campaignManagingPeopleIdSet.contains(ppl.id)) {
						ppl.Campaign_Moderation_Permission__c = 'Yes';
					} else {
						ppl.Campaign_Moderation_Permission__c = 'No';				
					}
						
					userIdSet.add(ppl.User__c);
					listOfPplObjToUpdate.add(ppl);
		    	}
			}
				
			if (listOfPplObjToUpdate.size() > 0) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),
						new List<Schema.SObjectField>{People__c.Campaign_Moderation_Permission__c});
			}
		}
		
		listOfPplObjToUpdate.clear();
		List<Simpplr_Site__c> listOfSitesToUpdate = new List<Simpplr_Site__c>();
		List<Simpplr_Site__c> siteList = new List<Simpplr_Site__c>(); 
		siteList = [SELECT Id, Chatter_Group_Id__c, Is_Newsletter_Allowed__c, Last_Edited_DateTime__c   
				FROM Simpplr_Site__c 
				WHERE Is_Active__c = true and Is_Deleted__c = false and 
				(Id IN :mustReadEnabledSites or Is_Must_Read_Enabled__c = true or Id IN : isNewsletterAllowedset or Is_Newsletter_Allowed__c = true) WITH SECURITY_ENFORCED];
    	Set<String> grantedGrpsForNewsletterSet = new Set<String>();
    	Map<String, String> siteIdWithGrpIdMap = new Map<String,String>();
    	
    	if (!siteList.isEmpty()) {
    		
			for (Simpplr_Site__c site: siteList) {
				
				if (isNewsletterAllowedset != null && isNewsletterAllowedset.contains(site.Id)) {
					
					if (site.Is_Newsletter_Allowed__c == false) {
						siteIdWithGrpIdMap.put(site.chatter_group_id__c,site.Id);
					}
					
					site.Is_Newsletter_Allowed__c = true;
					site.Last_Edited_DateTime__c = DateTime.now();
				
				} else {
					site.Is_Newsletter_Allowed__c = false;	
					site.Last_Edited_DateTime__c = DateTime.now();				
				}

				if (mustReadEnabledSites != null && mustReadEnabledSites.contains(site.Id)) {
					site.Is_Must_Read_Enabled__c = true;
				} else {
					site.Is_Must_Read_Enabled__c = false;					
				}
				
				listOfSitesToUpdate.add(site);
    		} 
    		
		}
		
		if (listOfSitesToUpdate != null && listOfSitesToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id, Simpplr_Site__c>(listOfSitesToUpdate), 
					new List<Schema.SObjectField>{Simpplr_Site__c.Is_Newsletter_Allowed__c, Simpplr_Site__c.Is_Must_Read_Enabled__c, Simpplr_Site__c.Last_Edited_DateTime__c});
		}
		
		listOfSitesToUpdate.clear();
		// send notification for granted people and site managers to access newsletter
		grantedGrpsForNewsletterSet.addAll(siteIdWithGrpIdMap.keySet());
		siteList = [SELECT Id, Chatter_Group_Id__c, Is_Alert_Enabled__c, Last_Edited_DateTime__c 
				FROM Simpplr_Site__c 
				WHERE Is_Active__c = true and Is_Deleted__c = false and 
				(Id IN : alertsControlSite or Is_Alert_Enabled__c = true) WITH SECURITY_ENFORCED];
    	
    	if (!siteList.isEmpty()) {
    		
			for (Simpplr_Site__c site : siteList){
			
				if (alertsControlSite != null && alertsControlSite.contains(site.Id)) {
					site.Is_Alert_Enabled__c = true;
					site.Last_Edited_DateTime__c = DateTime.now();
				
				} else {
					site.Is_Alert_Enabled__c = false;	
					site.Last_Edited_DateTime__c = DateTime.now();				
				}
				
				listOfSitesToUpdate.add(site);
    		} 
    		
		}
		
		if (listOfSitesToUpdate !=null && listOfSitesToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id, Simpplr_Site__c>(listOfSitesToUpdate), 
					new List<Schema.SObjectField>{Simpplr_Site__c.Is_Alert_Enabled__c, Simpplr_Site__c.Last_Edited_DateTime__c});
		}

		listOfSitesToUpdate.clear();
		siteList = [SELECT Id, Chatter_Group_Id__c, Is_Leadercast_Enabled__c 
				FROM Simpplr_Site__c 
				WHERE Is_Active__c = true and Is_Deleted__c = false and 
				(Id IN : leadercastControlSitesSet or Is_Leadercast_Enabled__c = true) WITH SECURITY_ENFORCED];
    	
    	if (!siteList.isEmpty()) {
    		
			for (Simpplr_Site__c site : siteList){
			
				if (leadercastControlSitesSet != null && leadercastControlSitesSet.contains(site.Id)) {
					site.Is_Leadercast_Enabled__c = true;
				
				} else {
					site.Is_Leadercast_Enabled__c = false;					
				}
				
				listOfSitesToUpdate.add(site);
    		} 
    		
		}
		
		if (listOfSitesToUpdate !=null && listOfSitesToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id, Simpplr_Site__c>(listOfSitesToUpdate), 
					new List<Schema.SObjectField>{Simpplr_Site__c.Is_Leadercast_Enabled__c});
		}		
		
		Map<String, List<CollaborationGroupMember>> userIdWithCollabGrpMemberMap = new Map<String, List<CollaborationGroupMember>>();
		List<CollaborationGroupMember> grpMemberList = [SELECT memberId, CollaborationGroupId,
				CollaborationGroup.Name 
				FROM CollaborationGroupMember 
				WHERE CollaborationGroupId IN :grantedGrpsForNewsletterSet AND CollaborationRole='Admin' WITH SECURITY_ENFORCED];
		
		for (CollaborationGroupMember grpMember: grpMemberList) {
			
			if (userIdWithCollabGrpMemberMap.get(grpMember.memberId) == null) {
				userIdWithCollabGrpMemberMap.put(grpMember.memberId, new List<CollaborationGroupMember>());
			}
			
			userIdWithCollabGrpMemberMap.get(grpMember.memberId).add(grpMember);
		}
		NotificationDispatcher.sendNotificationForGrantingNewsletterAccess(grantedUserForNewsletterSet, userIdWithCollabGrpMemberMap, siteIdWithGrpIdMap);	
		NotificationDispatcher.notifyForEmployeeAdvocacyAccess(grantedUserForEmployeeAdvocacy); 
		if(SimpplrContext.isFeatureContentOnboardingEnabled) {
		NotificationDispatcher.sendNotificationForOnboardingPrivilege(grantedUserForOrgOnboardingSet);
		}	
	}

	/**
	 * @description fetch ListenerSuite Configuration
	 * @param listenerSuiteSetsWrapObj
	 * @return ManageApplicationWrapper.ListenerSuiteSetupWrapper
	 */
	public ManageApplicationWrapper.ListenerSuiteSetupWrapper getListenerSuiteSetupConfig(){
		
		ManageApplicationWrapper.ListenerSuiteSetupWrapper  listenerSuiteSetsWrapObj = new ManageApplicationWrapper.ListenerSuiteSetupWrapper();
		List<PeopleWrapper> sentimentCheckControlPeopleList = new List<PeopleWrapper>();
		List<SiteLiteWrapper> sentimentCheckControlSiteList = new List<SiteLiteWrapper>();	
		List<PeopleWrapper> surveysControlPeopleList = new List<PeopleWrapper>();	
		
		String query = 'Select Id, Full_Name__c, User__r.SmallPhotoUrl, Can_Manage_Sentiment_Check__c, Can_Manage_Surveys__c From People__c where (Can_Manage_Sentiment_Check__c = true OR Can_Manage_Surveys__c = true) ';						
		if (Utility.isApiOnlyUserQueryable()) {
			query  += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false))';
		} else {
			query  += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\'))';
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUSer(query, null);
			
		for(People__c ppl: peopleList){
			PeopleWrapper pplWraperObj = new PeopleWrapper();		
			pplWraperObj.id = ppl.id;
			pplWraperObj.peopleId = ppl.id;
			pplWraperObj.name = ppl.Full_Name__c;
			pplWraperObj.smallPhotoUrl = ppl.User__r.SmallPhotoUrl;
			pplWraperObj.jsonDataString = createDataParam(pplWraperObj.id,pplWraperObj.name,pplWraperObj.smallPhotoUrl);
			
			if(ppl.Can_Manage_Sentiment_Check__c == true){
				sentimentCheckControlPeopleList.add(pplWraperObj);
			}
			if(ppl.Can_Manage_Surveys__c == true){
				surveysControlPeopleList.add(pplWraperObj);
			}
		}
		sentimentCheckControlPeopleList.sort();
		listenerSuiteSetsWrapObj.sentimentCheckControlPeople = sentimentCheckControlPeopleList;

		surveysControlPeopleList.sort();
		listenerSuiteSetsWrapObj.surveysControlPeople = surveysControlPeopleList;
		
		List<Simpplr_Site__c> listOfSite = [Select Id,Name, Chatter_Group_Id__c, Site_Type__c,Title_Content_Version__c,Landing_Page__c,Is_Sentiment_Check_Enabled__c  												
																					FROM Simpplr_Site__c WHERE Is_Active__c = true AND Is_Deleted__c = false And Show_In_Simpplr__c = true And  
																					Is_Sentiment_Check_Enabled__c = true WITH SECURITY_ENFORCED order by Name];

		for(Simpplr_Site__c siteObj : listOfSite){
			SiteLiteWrapper siteWrapperObj = new SiteLiteWrapper ();
			if(siteObj.Is_Sentiment_Check_Enabled__c == true){
				siteWrapperObj.siteId = siteObj.id;
				siteWrapperObj.name = siteObj.Name;
				siteWrapperObj.img = String.isBlank(siteObj.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(siteObj.Title_Content_Version__c);
				siteWrapperObj.imgThumbnail = String.isBlank(siteObj.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(siteObj.Title_Content_Version__c);
				siteWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.Id + '/' + siteObj.Landing_Page__c;
				siteWrapperObj.access = siteObj.Site_Type__c;
				siteWrapperObj.isMember = UserContext.sitesIFollowIdSet.contains(siteObj.id);
				siteWrapperObj.jsonDataString = JSON.serialize(siteWrapperObj);
				sentimentCheckControlSiteList.add(siteWrapperObj);
			}
	
		}
		listenerSuiteSetsWrapObj.sentimentCheckControlSites = sentimentCheckControlSiteList;

		String appConfigQuery = 'SELECT id, Is_My_Teams_Listener_Suite_Enabled__c FROM App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		if (appConfigList.size() > 0 ){
			listenerSuiteSetsWrapObj.isListenerSuiteForMyTeamsEnabled = appConfigList[0].Is_My_Teams_Listener_Suite_Enabled__c;
		}
		return listenerSuiteSetsWrapObj;
	}

	/**
	 * @description save ListenerSuite Configuration
	 * @param listenerSuiteSetsWrapObj
	 */
	public void saveListenerSuiteSetupConfig (ManageApplicationWrapper.ListenerSuiteSetupWrapper listenerSuiteSetsWrapObj) {
		List<PeopleWrapper> sentimentCheckControlPeopleList = new List<PeopleWrapper>();
		List<SiteLiteWrapper> sentimentCheckControlSiteList = new List<SiteLiteWrapper>();
		List<PeopleWrapper> surveysControlPeopleList = new List<PeopleWrapper>();
		Boolean isListenerSuiteForMyTeamsEnabled;

		sentimentCheckControlPeopleList = ((listenerSuiteSetsWrapObj.sentimentCheckControlPeople == null) ?  sentimentCheckControlPeopleList : listenerSuiteSetsWrapObj.sentimentCheckControlPeople);
		sentimentCheckControlSiteList = ((listenerSuiteSetsWrapObj.sentimentCheckControlSites == null) ? sentimentCheckControlSiteList : listenerSuiteSetsWrapObj.sentimentCheckControlSites);
		surveysControlPeopleList = ((listenerSuiteSetsWrapObj.surveysControlPeople == null) ? surveysControlPeopleList : listenerSuiteSetsWrapObj.surveysControlPeople);
		isListenerSuiteForMyTeamsEnabled = listenerSuiteSetsWrapObj.isListenerSuiteForMyTeamsEnabled != null ? listenerSuiteSetsWrapObj.isListenerSuiteForMyTeamsEnabled : true;
		
		Set<String> sentimentCheckControlPeopleIdSet = new Set<String>();
		Set<String> surveysControlPeopleIdSet = new Set<String>();
		Set<String> listOfSiteId = new Set<String>();
		for(PeopleWrapper PeopleWrap : sentimentCheckControlPeopleList) {
			sentimentCheckControlPeopleIdSet.add(PeopleWrap.id);
		}
		for(SiteLiteWrapper siteWrap : sentimentCheckControlSiteList) {
			listOfSiteId.add(siteWrap.siteId);
		}
		for(PeopleWrapper PeopleWrap : surveysControlPeopleList) {
			surveysControlPeopleIdSet.add(PeopleWrap.id);
		}

		List<People__c> listOfPplObjToUpdate = new List<People__c>();

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', sentimentCheckControlPeopleIdSet);
		soqlParamMap.put('soqlParam2', surveysControlPeopleIdSet);
		string query = 'SELECT Id, Can_Manage_Sentiment_Check__c '+
				' FROM People__c '+
				' WHERE User__r.IsActive = true AND '+
				' ((Id IN : soqlParam1 or Can_Manage_Sentiment_Check__c = true) OR '+
				' (Id IN : soqlParam2 or Can_Manage_Surveys__c = true)) ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	
		
		if (!peopleList.isEmpty()) {	
			for (People__c ppl: peopleList){
				if (sentimentCheckControlPeopleList != null && sentimentCheckControlPeopleIdSet.contains(ppl.id)) {
					ppl.Can_Manage_Sentiment_Check__c = true;
					
				} else {
					ppl.Can_Manage_Sentiment_Check__c = false;					
				}
				
				if (surveysControlPeopleList != null && surveysControlPeopleIdSet.contains(ppl.id)) {
					ppl.Can_Manage_Surveys__c = true;
					
				} else {
					ppl.Can_Manage_Surveys__c = false;					
				}

				listOfPplObjToUpdate.add(ppl);
			} 
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.Can_Manage_Sentiment_Check__c, People__c.Can_Manage_Surveys__c});
		}
		listOfPplObjToUpdate.clear();
		
		List<Simpplr_Site__c> listOfSitesToUpdate = new List<Simpplr_Site__c>();
		List<Simpplr_Site__c> siteList = new List<Simpplr_Site__c>(); 
		
		siteList = [SELECT Id, Chatter_Group_Id__c, Is_Sentiment_Check_Enabled__c 
				FROM Simpplr_Site__c 
				WHERE Is_Active__c = true and Is_Deleted__c = false and Show_In_Simpplr__c = true and 
				(Id IN : listOfSiteId or Is_Sentiment_Check_Enabled__c = true) WITH SECURITY_ENFORCED];
		
		if (!siteList.isEmpty()) {		
			for (Simpplr_Site__c site : siteList) {
				if (sentimentCheckControlSiteList != null && listOfSiteId.contains(site.Id)) {
					site.Is_Sentiment_Check_Enabled__c = true;
				} else {
					site.Is_Sentiment_Check_Enabled__c = false;					
				}
				listOfSitesToUpdate.add(site);
			} 
		}
		
		if (listOfSitesToUpdate !=null && listOfSitesToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id, Simpplr_Site__c>(listOfSitesToUpdate), 
					new List<Schema.SObjectField>{Simpplr_Site__c.Is_Sentiment_Check_Enabled__c});
		}

		if(isListenerSuiteForMyTeamsEnabled != null) {
            App_Config__c appConfigObj = new App_Config__c(Id = SimpplrContext.appConfig.Id);
            appConfigObj.Is_My_Teams_Listener_Suite_Enabled__c = isListenerSuiteForMyTeamsEnabled;
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(appConfigObj, new List<Schema.SObjectField>{App_Config__c.Is_My_Teams_Listener_Suite_Enabled__c});
        }

	}
	
	@future 
	public static void updateAccessToFiles(Set<String> newOrExistingAppPermissionsUserIdIdSet, Set<String> removeAppPermissionsUserIdSet) {		
		// Get all Files(ContentDocument) that are title images to the above fetched Simpplr-Content
		String filesQuery = 'SELECT Id, Content_Document__c, Repository__c '+
									' FROM File__c '+
									' WHERE Simpplr_Content__r.Status__c = \'Draft\' AND Simpplr_Content__r.Is_Deleted__c = false'+
									' AND Content_Document__c != null'+
									' AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, null);
		// share Files With User
		FileDao fileDaoObj = new FileDao();
		if( !newOrExistingAppPermissionsUserIdIdSet.isEmpty() ) {
			fileDaoObj.createContentDocumentLinks(fileList, newOrExistingAppPermissionsUserIdIdSet);
		}
		if( !removeAppPermissionsUserIdSet.isEmpty() ) {
			fileDaoObj.removeContentDocumentLinks(fileList, removeAppPermissionsUserIdSet);
		}
	}

	private void updateAccessToUnlistedSiteFiles(Set<String> newOrExistingPermissionsUserIdIdSet, Set<String> removePermissionsUserIdSet) {
		// Get all draft contents for site
		Map<Id, Simpplr_Content__c> contentMap = new Map<Id, Simpplr_Content__c>([SELECT Id, Title__c, Site__r.Name, Site__r.Site_Type__c FROM Simpplr_Content__c 
																					WHERE Status__c = 'Draft' AND  Site__r.Site_Type__c = :ServiceConstants.UNLISTED_SITE AND Is_Deleted__c = false]);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', contentMap.keySet());
		// Get all Files(ContentDocument) that are title images to the above fetched Simpplr-Content
		String filesQuery = 'SELECT Id, Content_Document__c, Repository__c '+
									' FROM File__c '+
									' WHERE Simpplr_Content__c = :soqlParam1 AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
		// share Files With User
		FileDao fileDaoObj = new FileDao();
		if( !newOrExistingPermissionsUserIdIdSet.isEmpty() ) {
			fileDaoObj.createContentDocumentLinks(fileList, newOrExistingPermissionsUserIdIdSet);
		}
		if( !removePermissionsUserIdSet.isEmpty() ) {
			fileDaoObj.removeContentDocumentLinks(fileList, removePermissionsUserIdSet);
		}
	}
    
    // sync GroupMembers
    @future
    private static void syncGroupMembers(String groupDevName, set<String> userIdSet){
    	List<Group> userGroup = [SELECT Id FROM Group WHERE
 						DeveloperName = :groupDevName WITH SECURITY_ENFORCED];
    	String groupId;
    	if (userGroup.isEmpty()) {
			Group groupObj = new Group();
	    		groupObj.DeveloperName = groupDevName;
	    		groupObj.DoesSendEmailToMembers = false;
	    		groupObj.type='Regular';
	    		groupObj.Name = groupObj.DeveloperName; 
	    		insert groupObj;
    			groupId = groupObj.id;
    		
    	} else {
    		groupId = userGroup[0].id;
    	}
    	
    	List<GroupMember> listOfOldGroupMember = [SELECT UserOrGroupId FROM GroupMember 
				WHERE groupId = :groupId WITH SECURITY_ENFORCED];
		Set<String> setOfOldMembers = new Set<String>();
		
		for (GroupMember groupMemberObj : listOfOldGroupMember) {
			setOfOldMembers.add(groupMemberObj.UserOrGroupId);
		}
		
		Set<String> setOfNewMembers = new Set<String>();
		for (String userId : userIdSet) {
			if (setOfOldMembers.contains(userId)) {
				setOfOldMembers.remove(userId);
			} else {
				setOfNewMembers.add(userId);
			}
		}
		
		if (setOfOldMembers.size() > 0) {
			List<GroupMember> listOfGroupMemberToDelete = [SELECT Id, groupId, UserOrGroupId 
					FROM GroupMember WHERE groupId = :groupId AND UserOrGroupId =:setOfOldMembers WITH SECURITY_ENFORCED];
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(listOfGroupMemberToDelete);
		}
		
		if (setOfNewMembers.size() > 0) {
			List<GroupMember> listOfGroupMemberToInsert = new List<GroupMember>();
			
			for (String userId : setOfNewMembers) {
    			listOfGroupMemberToInsert.add(new GroupMember(groupId = groupId, UserOrGroupId = userId));
    		}
    		
    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().insertAsUser(listOfGroupMemberToInsert, 
    				new List<Schema.SObjectField>{GroupMember.groupId, GroupMember.UserOrGroupId});
		}
    }
    
    /**
     * assignRemovePermissionSet
     *
     * Future job to add/remove user's permission set(simpplr unlisted site manager)
    */
    @future
    public static void assignRemovePermissionSet(List<String> permissionSetIdList, 
												Set<String> newAndExistingAsigneeUserIdsSet,
												Set<String> userIdsToRemoveSet){
    	
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		if(!newAndExistingAsigneeUserIdsSet.isEmpty()){
			// Filter users to whom licence is to be assigned by filtering out the users who already have assigned licence. 
    		List<User> userList = [
				SELECT Id, (SELECT PermissionSetId FROM PermissionSetAssignments WHERE 
					PermissionSetId IN :permissionSetIdList) 
				FROM User WHERE Id =:newAndExistingAsigneeUserIdsSet];
			
			List<PermissionSetAssignment> newPermissionSetList = new List<PermissionSetAssignment>();
			Set<String> assignedPermissionSetId;
    		for(User userObj : userList){
				assignedPermissionSetId = new Set<String>();
				for(PermissionSetAssignment assignedPermissionSet : userObj.PermissionSetAssignments) {
					assignedPermissionSetId.add(assignedPermissionSet.PermissionSetId);
				}
				for(String permissionSetId : permissionSetIdList) {
					if(!assignedPermissionSetId.contains(permissionSetId)) {
						newPermissionSetList.add(new PermissionSetAssignment(PermissionSetId = permissionSetId, AssigneeId = userObj.Id));
					}
				}
			}
			
			// Assign permission set, if any
			if(!newPermissionSetList.isEmpty()){
				SIMPESAPI.accessController().insertAsUser(newPermissionSetList, new List<Schema.SObjectField>{
	        	                       PermissionSetAssignment.PermissionSetId,
	            	                   PermissionSetAssignment.AssigneeId});
			}												
    	}
    	
		// Remove the permission set, if any
		if(!userIdsToRemoveSet.isEmpty()){
			List<PermissionSetAssignment> psToRemove = [SELECT Id FROM PermissionSetAssignment WHERE 
															PermissionSetId IN :permissionSetIdList AND
															AssigneeId = :userIdsToRemoveSet];
			
			if(!psToRemove.isEmpty()){
				SIMPESAPI.accessController().deleteAsUser(psToRemove);
			}
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
     
     public ManageApplicationWrapper.GovernanceSetupWrapper getGovernanceData(){
     	ManageApplicationWrapper.GovernanceSetupWrapper governanceObj = new ManageApplicationWrapper.GovernanceSetupWrapper();
     	String appConfigQuery = 'Select Allow_Comments__c, Home_Carousel_Enabled__c, Site_Carousel_Enabled__c,Allow_Public_Contribution__c, Feed_Mode__c, '
		 							+ ' Feed_Placeholder__c, Feed_Show_Track_Change_Posts__c,App_Languages_Enabled__c, Allow_File_Upload_Site_Managers__c,'
									+ ' App_Dashboard_Mode__c, Site_Dashboard_Mode__c, Allow_File_Share_With_Public_Link__c,'
									+ ' Auto_Convert_ChatterGroup_To_Site__c, Allow_File_Upload__c, Expertise_Controlled_By__c,'
									+ ' Content_Governance_Enabled__c, Validation_Period__c, Expertise_Create_Controlled_By__c, HTML_tile_enabled__c'
									+ ' FROM App_Config__c order by createddate desc limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfApplicationObjs = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		 
    	
    	for(App_Config__c appConfObj: listOfApplicationObjs) {
        	governanceObj.feedMode = appConfObj.Feed_Mode__c;
        	governanceObj.showTrackChangesFeedPosts = appConfObj.Feed_Show_Track_Change_Posts__c;
			governanceObj.autoConvertChatterGroupToSite = appConfObj.Auto_Convert_ChatterGroup_To_Site__c ? 'true': 'false';
			governanceObj.filePermission = appConfObj.Allow_File_Upload__c;

			governanceObj.siteFilePermission = appConfObj.Allow_File_Upload_Site_Managers__c;
			governanceObj.sitesToUploadFiles = getAllowedFileUploadSites();
			
			governanceObj.homeDashboardSetup = appConfObj.App_Dashboard_Mode__c;
			governanceObj.siteDashboardSetup = appConfObj.Site_Dashboard_Mode__c;
			governanceObj.homeCarouselEnabled = appConfObj.Home_Carousel_Enabled__c;
			governanceObj.siteCarouselEnabled = appConfObj.Site_Carousel_Enabled__c;
			governanceObj.allowFileShareWithPublicLink = appConfObj.Allow_File_Share_With_Public_Link__c;
			governanceObj.contentComments = appConfObj.Allow_Comments__c;
			governanceObj.contentSubmissions = appConfObj.Allow_Public_Contribution__c;
			
			governanceObj.multipleLanguagesEnabled = appConfObj.App_Languages_Enabled__c.split(';').size() > 1;
			governanceObj.customFeedPlaceholderText = appConfObj.Feed_Placeholder__c;
			governanceObj.feedPlaceholderToggle = String.isBlank(appConfObj.Feed_Placeholder__c) ? 'on' : 'off';
			
			governanceObj.expertiseControlledByManager = 'manager'.equalsIgnoreCase(appConfObj.Expertise_Controlled_By__c)?	'true' : 'false';
			governanceObj.expertiseCreateControlledByManager = 'manager'.equalsIgnoreCase(appConfObj.Expertise_Create_Controlled_By__c)? 'true' : 'false';

			governanceObj.autoGovernanceEnabled = appConfObj.Content_Governance_Enabled__c ? 'true' : 'false';
			governanceObj.autoGovValidationPeriod = appConfObj.Validation_Period__c;
			governanceObj.htmlTileEnabled = appConfObj.HTML_tile_enabled__c ? 'true' : 'false';
    	}
		
    	return governanceObj;
     }

	 private List<SiteLiteWrapper> getAllowedFileUploadSites() {
		List<SiteLiteWrapper> allowedFileUploadSiteList = new List<SiteLiteWrapper>();

		String siteQuery  = 'SELECT Id, Name, Site_Type__c, Allow_File_Upload_App_Permission__c FROM Simpplr_Site__c WHERE Is_Active__c = true AND Is_Deleted__c = false AND Allow_File_Upload_App_Permission__c=true';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Simpplr_Site__c> siteObjList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, null);

		for(Simpplr_Site__c siteObj : siteObjList){
			SiteLiteWrapper siteWrapperObj = new SiteLiteWrapper();
			siteWrapperObj.siteId = siteObj.id;
			siteWrapperObj.name = siteObj.Name;
			
			allowedFileUploadSiteList.add(siteWrapperObj);
		}

		return allowedFileUploadSiteList;
	 }
     
     public  ManageApplicationWrapper.NavigationSetupWrapper getNavigationDetails(){
     	ManageApplicationWrapper.NavigationSetupWrapper navigationObj = new ManageApplicationWrapper.NavigationSetupWrapper();

		String appConfigQuery = 'SELECT id, Go_To_Salesforce_Enabled__c,'
									+ ' Org_Chart_Enabled__c, Lightning_UX_Tab_Open_Setting__c'
									+ ' FROM App_Config__c '
									+ ' LIMIT 1 ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
     	navigationObj.goToSalesforceEnabled = appConfigObj.Go_To_Salesforce_Enabled__c;
		navigationObj.isOrgChartEnabled = appConfigObj.Org_Chart_Enabled__c;
		navigationObj.appLightningSetting = appConfigObj.Lightning_UX_Tab_Open_Setting__c;
     	return navigationObj;
     }
     
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
     public void saveNavigationConfig(ManageApplicationWrapper.NavigationSetupWrapper navigationObj){
		String appConfigQuery = 'SELECT Id, '
									+ ' Go_To_Salesforce_Enabled__c, Last_Edited_DateTime__c, Lightning_UX_Tab_Open_Setting__c,'
									+ ' Org_Chart_Enabled__c'
									+ ' FROM App_Config__c order by createddate desc limit 1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> configObjList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
		App_Config__c configObj = configObjList[0];

		configObj.Last_Edited_DateTime__c = DateTime.now();
		configObj.Go_To_Salesforce_Enabled__c = navigationObj.goToSalesforceEnabled;
		configObj.Lightning_UX_Tab_Open_Setting__c = navigationObj.appLightningSetting;
		if(navigationObj.isOrgChartEnabled != null) {
			configObj.Org_Chart_Enabled__c = navigationObj.isOrgChartEnabled;
		}
		
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
   		SIMPESAPI.accessController().updateAsUser(configObj,new List<Schema.SObjectField>{
   							App_Config__c.Go_To_Salesforce_Enabled__c,
   							App_Config__c.Org_Chart_Enabled__c, App_Config__c.Lightning_UX_Tab_Open_Setting__c,
							App_Config__c.Last_Edited_DateTime__c}
					  );
     }
      
     public void saveAppGovernance(ManageApplicationWrapper.GovernanceSetupWrapper appGovernanceObj){
		system.debug('****appGovernanceObj***** 3093' + appGovernanceObj);
     	String appConfigQuery = 'Select Allow_Comments__c, Allow_Public_Contribution__c, Feed_Mode__c,'
									+ ' Feed_Placeholder__c,Feed_Show_Track_Change_Posts__c, Auto_Convert_ChatterGroup_To_Site__c,'
									+ ' Allow_File_Upload__c,Allow_File_Share_With_Public_Link__c,'
									+ ' App_Dashboard_Mode__c, Site_Dashboard_Mode__c, Expertise_Controlled_By__c, HTML_tile_enabled__c,'
									+ ' Content_Governance_Enabled__c, Validation_Period__c, Last_Edited_DateTime__c, Expertise_Create_Controlled_By__c'
									+ ' FROM App_Config__c order by createddate desc limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> configObjList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		system.debug('****configObjList***** 30102  '+ configObjList);

		App_Config__c configObj = configObjList[0];
		system.debug('****configObj***** 30102  '+ configObj);


		List<Schema.SObjectField> fieldsToSave = new List<Schema.SObjectField>{
				App_Config__c.Last_Edited_DateTime__c,
				App_Config__c.Allow_Comments__c, 
				App_Config__c.Auto_Convert_ChatterGroup_To_Site__c,
				App_Config__c.Allow_File_Upload__c,
				App_Config__c.Allow_Public_Contribution__c, 
				App_Config__c.Feed_Mode__c,
				App_Config__c.Home_Carousel_Enabled__c,
				App_Config__c.Site_Carousel_Enabled__c,
				App_Config__c.Feed_Show_Track_Change_Posts__c,
				App_Config__c.Feed_Placeholder__c, 
				App_Config__c.App_Dashboard_Mode__c, 
				App_Config__c.Site_Dashboard_Mode__c,
				App_Config__c.Expertise_Controlled_By__c,
				App_Config__c.Allow_File_Share_With_Public_Link__c,
				App_Config__c.Expertise_Create_Controlled_By__c,
				App_Config__c.Allow_File_Upload_Site_Managers__c,
				App_Config__c.HTML_tile_enabled__c	
		};
		system.debug('****fieldsToSave***** 30127  '+ fieldsToSave);

		
		String appDefaultLayout;
		configObj.Feed_Mode__c= appGovernanceObj.feedMode;
		if('timeline'.equalsIgnoreCase(appGovernanceObj.feedMode)) {
			configObj.Allow_Comments__c = false;
		} else {
			configObj.Allow_Comments__c = appGovernanceObj.contentComments;
		}
		
		configObj.Allow_File_Share_With_Public_Link__c = appGovernanceObj.allowFileShareWithPublicLink;
		configObj.Feed_Mode__c = String.valueOf(appGovernanceObj.feedMode);
		configObj.Feed_Show_Track_Change_Posts__c = appGovernanceObj.showTrackChangesFeedPosts == true ? true : false;
		
		configObj.Auto_Convert_ChatterGroup_To_Site__c = ('true'.equals(appGovernanceObj.autoConvertChatterGroupToSite)) ? true : false;
		configObj.Allow_File_Upload__c = appGovernanceObj.filePermission;
		configObj.Allow_File_Upload_Site_Managers__c = appGovernanceObj.siteFilePermission;
		configObj.App_Dashboard_Mode__c = appGovernanceObj.homeDashboardSetup;
		string appDasMode = appGovernanceObj.homeDashboardSetup;
		system.debug('****appDasMode***** 30147  '+ appDasMode);

		configObj.Site_Dashboard_Mode__c = appGovernanceObj.siteDashboardSetup;
		string siteDasMode = appGovernanceObj.homeDashboardSetup;
		system.debug('****siteDasMode***** 3151  '+ siteDasMode);

		configObj.Allow_Public_Contribution__c = appGovernanceObj.contentSubmissions;		
		configObj.Expertise_Controlled_By__c = Boolean.valueOf(appGovernanceObj.expertiseControlledByManager) == true ? 'manager' : 'user';
		configObj.Expertise_Create_Controlled_By__c = Boolean.valueOf(appGovernanceObj.expertiseCreateControlledByManager) == true ? 'manager' : 'user';
		configObj.Feed_Placeholder__c = appGovernanceObj.customFeedPlaceholderText;
		
		configObj.Home_Carousel_Enabled__c = appGovernanceObj.homeCarouselEnabled;
		configObj.Site_Carousel_Enabled__c = appGovernanceObj.siteCarouselEnabled;
		configObj.Last_Edited_DateTime__c = Datetime.now();
		configObj.HTML_tile_enabled__c =  ('true'.equals(appGovernanceObj.htmlTileEnabled)) ? true : false;
		Boolean isContentGovUpdated = false;
		if(SimpplrContext.isFeatureEnabled('Content_Governance')){
			// If Content-Governance is switched-off
			if(configObj.Content_Governance_Enabled__c == true && Boolean.valueOf(appGovernanceObj.autoGovernanceEnabled)) {
				isContentGovUpdated = true;
			}

			// If Content-Governance validation period is updated
			if(String.isNotBlank(configObj.Validation_Period__c) && ((configObj.Validation_Period__c).equalsIgnoreCase(appGovernanceObj.autoGovValidationPeriod)) ) {
				isContentGovUpdated = true;
			}

			configObj.Content_Governance_Enabled__c = Boolean.valueOf(appGovernanceObj.autoGovernanceEnabled);
			configObj.Validation_Period__c = appGovernanceObj.autoGovValidationPeriod;
	        
			fieldsToSave.add(App_Config__c.Content_Governance_Enabled__c);
			fieldsToSave.add(App_Config__c.Validation_Period__c);
		}

		if (appGovernanceObj.siteFilePermission == ServiceConstants.ALLOW_FILE_UPLOAD_IN_SELECTED_SITE) {
			List<Id> siteIdsList = new List<Id>();
			for (SiteLiteWrapper siteWrapperObj : appGovernanceObj.sitesToUploadFiles) {
				siteIdsList.add(siteWrapperObj.siteId);
			}
			updateAllowedFileUploadSites(siteIdsList);
		}

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(configObj, fieldsToSave);
		
		System.debug(LoggingLevel.DEBUG, 'isContentGovUpdated => ' + isContentGovUpdated);
		if(isContentGovUpdated == true) {
			BatchContentAutoGovNotifications batchObj = new BatchContentAutoGovNotifications('deleteContentGovActionableNotifications');
			Database.executeBatch(batchObj, 2000);
		}
	 }

	private void updateAllowedFileUploadSites(List<Id> siteIdsList) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteIdsList);

		String siteQuery  = 'SELECT Id, Allow_File_Upload_App_Permission__c FROM Simpplr_Site__c WHERE Is_Active__c = true AND Is_Deleted__c = false AND (Allow_File_Upload_App_Permission__c=true OR Id in:soqlParam1)';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Simpplr_Site__c> siteObjList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);

		for (Simpplr_Site__c siteObj : siteObjList) {
			if (siteIdsList.contains(siteObj.id)) {
				siteObj.Allow_File_Upload_App_Permission__c = true;
			} else {
				siteObj.Allow_File_Upload_App_Permission__c = false;
			}
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(siteObjList), new List<Schema.SObjectField>{
													Simpplr_Site__c.Allow_File_Upload_App_Permission__c
												});
	}
	 
	public static void deleteContentGovernanceActionableNotifications(List<App_Notification__c> appNotiList) {
		for(App_Notification__c appNotiObj : appNotiList) {
			appNotiObj.Is_Deleted__c = true;
		}

		if(!appNotiList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,App_Notification__c>(appNotiList), new List<Schema.SObjectField>{App_Notification__c.Is_Deleted__c });
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
    public static void saveTroubleshootingData(ManageApplicationWrapper.TroubleshootingWrapper troubleshootingObj){
    	List<App_Config__c> listOfAppConfObject= new List<App_Config__c>();
    	
		String appConfigQuery = 'SELECT Id, Simpplr_Domain__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigObjList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
    	listOfAppConfObject.addAll(appConfigObjList);
    	
		listOfAppConfObject[0].Last_Edited_DateTime__c = DateTime.now();
		listOfAppConfObject[0].AT_CollaborationGroup_Enabled__c=troubleshootingObj.collaborationGroup;
		listOfAppConfObject[0].AT_CollaborationGroupMember_Enabled__c=troubleshootingObj.collaborationGroupMember;
		listOfAppConfObject[0].AT_ContentVersion_Enabled__c=troubleshootingObj.contentVersion;
		listOfAppConfObject[0].AT_ContentDocument_Enabled__c=troubleshootingObj.contentDocument;
		listOfAppConfObject[0].AT_Feed_ItemEnabled__c=troubleshootingObj.feedItem;
		listOfAppConfObject[0].AT_FeedComment_Enabled__c=troubleshootingObj.feedComment;
		listOfAppConfObject[0].AT_User_Enabled__c=troubleshootingObj.user;
		listOfAppConfObject[0].EH_Debug_Enabled__c=troubleshootingObj.debugEnabled;
		listOfAppConfObject[0].EH_JS_Debug_Enabled__c=troubleshootingObj.jsDebugEnabled;
		listOfAppConfObject[0].EH_UI_Stack_Trace_Enabled__c=troubleshootingObj.errorStack;
		if(troubleshootingObj.updateSimpplrDomain == true) {
			listOfAppConfObject[0].Simpplr_Domain__c = SimpplrContext.salesforceBaseUrl;
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(new Map<id,App_Config__c>(listOfAppConfObject), 
												  new List<Schema.SObjectField>{
														App_Config__c.AT_CollaborationGroup_Enabled__c,
														App_Config__c.AT_CollaborationGroupMember_Enabled__c,
														App_Config__c.AT_ContentVersion_Enabled__c,
														App_Config__c.AT_ContentDocument_Enabled__c,
														App_Config__c.AT_Feed_ItemEnabled__c,
														App_Config__c.AT_FeedComment_Enabled__c,
														App_Config__c.AT_User_Enabled__c,
														App_Config__c.EH_Debug_Enabled__c,
														App_Config__c.EH_JS_Debug_Enabled__c,
														App_Config__c.EH_UI_Stack_Trace_Enabled__c,
														App_Config__c.Simpplr_Domain__c,
														App_Config__c.Last_Edited_DateTime__c });
    }
    
	/**
	 * @description saveMobileAppData : get wrapper object for mobile app configuration
	 * @param mobileAppWrapperObj
	 * @return ManageApplicationWrapper.MobileAppWrapper
	*/
	public ManageApplicationWrapper.MobileAppWrapper saveMobileAppData(ManageApplicationWrapper.MobileAppWrapper mobileAppWrapperObj){
		String appConfigQuery = 'Select Id, Native_App_Enabled__c, Login_From_Generic_App_Allowed__c,'
			+ ' Mobile_Promotion_Enabled__c, Branded_App_Distribution_Enabled__c,'
			+ ' Mobile_App_Additional_Security_Enabled__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfApplicationObjs = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);

		Boolean isMobilePromotionEnabled = listOfApplicationObjs[0].Native_App_Enabled__c && listOfApplicationObjs[0].Login_From_Generic_App_Allowed__c;
		Boolean isBrandedDistributionEnabled = listOfApplicationObjs[0].Native_App_Enabled__c && listOfApplicationObjs[0].Login_From_Generic_App_Allowed__c == false;

		listOfApplicationObjs[0].Mobile_Promotion_Enabled__c = isMobilePromotionEnabled && 'true'.equalsIgnoreCase(mobileAppWrapperObj.mobilePromotionEnabled);
		listOfApplicationObjs[0].Branded_App_Distribution_Enabled__c = isBrandedDistributionEnabled && 'true'.equalsIgnoreCase(mobileAppWrapperObj.brandedAppDistributionEnabled);
		listOfApplicationObjs[0].Mobile_App_Additional_Security_Enabled__c = 'true'.equalsIgnoreCase(mobileAppWrapperObj.mobileAppAdditionalSecurityEnabled);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(listOfApplicationObjs[0],new List<Schema.SObjectField>{
			App_Config__c.Mobile_Promotion_Enabled__c,
			App_Config__c.Branded_App_Distribution_Enabled__c,
			App_Config__c.Mobile_App_Additional_Security_Enabled__c});
		
		mobileAppWrapperObj.nativeAppEnabled = listOfApplicationObjs[0].Native_App_Enabled__c;
		mobileAppWrapperObj.brandedAppEnabled = isBrandedDistributionEnabled;
		mobileAppWrapperObj.mobilePromotionEnabled = listOfApplicationObjs[0].Mobile_Promotion_Enabled__c ? 'true' : 'false';
		mobileAppWrapperObj.brandedAppDistributionEnabled = listOfApplicationObjs[0].Branded_App_Distribution_Enabled__c ? 'true' : 'false';
		return mobileAppWrapperObj;
	}

	/**
	 * @description getMobileAppConfig : get wrapper object for mobile app configuration
	 * @return ManageApplicationWrapper.MobileAppWrapper
	*/
	public ManageApplicationWrapper.MobileAppWrapper getMobileAppConfig(){
		ManageApplicationWrapper.MobileAppWrapper mobileAppWrapperObj = new ManageApplicationWrapper.MobileAppWrapper();
		String appConfigQuery = 'Select Native_App_Enabled__c, Login_From_Generic_App_Allowed__c, '
									+ ' Mobile_Promotion_Enabled__c, Branded_App_Distribution_Enabled__c,'
									+ ' Mobile_App_Additional_Security_Enabled__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfApplicationObjs = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
																		
		for(App_Config__c appConfObj: listOfApplicationObjs) {
			mobileAppWrapperObj.nativeAppEnabled = appConfObj.Native_App_Enabled__c;
			mobileAppWrapperObj.brandedAppEnabled = appConfObj.Native_App_Enabled__c && appConfObj.Login_From_Generic_App_Allowed__c == false;
			mobileAppWrapperObj.mobilePromotionEnabled = (mobileAppWrapperObj.nativeAppEnabled && !mobileAppWrapperObj.brandedAppEnabled && appConfObj.Mobile_Promotion_Enabled__c) ? 'true' : 'false';
			mobileAppWrapperObj.brandedAppDistributionEnabled = (mobileAppWrapperObj.brandedAppEnabled && appConfObj.Branded_App_Distribution_Enabled__c) ? 'true' : 'false';
			mobileAppWrapperObj.mobileAppAdditionalSecurityEnabled = appConfObj.Mobile_App_Additional_Security_Enabled__c ? 'true' : 'false';
		}
		return mobileAppWrapperObj;
	}

    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public ManageApplicationWrapper.TroubleshootingWrapper getTroubleshootingData(){
    	ManageApplicationWrapper.TroubleshootingWrapper troubleshootingObj= new ManageApplicationWrapper.TroubleshootingWrapper();
    	String appConfigQuery = 'Select AT_CollaborationGroup_Enabled__c, Simpplr_Domain__c, EH_UI_Stack_Trace_Enabled__c,EH_Debug_Enabled__c,'
									+ ' EH_JS_Debug_Enabled__c,AT_User_Enabled__c,AT_Simpplr_Site_Enabled__c,AT_Simpplr_Content_Enabled__c,'
									+ ' AT_CollaborationGroupMember_Enabled__c,AT_ContentVersion_Enabled__c,AT_ContentDocument_Enabled__c,'
									+ ' AT_Feed_ItemEnabled__c,AT_FeedComment_Enabled__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfApplicationObjs = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
																		
    	for(App_Config__c appConfObj: listOfApplicationObjs) {
			troubleshootingObj.collaborationGroup = appConfObj.AT_CollaborationGroup_Enabled__c;	
			troubleshootingObj.collaborationGroupMember = appConfObj.AT_CollaborationGroupMember_Enabled__c;
			troubleshootingObj.contentVersion = appConfObj.AT_ContentVersion_Enabled__c;
			troubleshootingObj.contentDocument = appConfObj.AT_ContentDocument_Enabled__c;	
			troubleshootingObj.feedItem = appConfObj.AT_Feed_ItemEnabled__c;
			troubleshootingObj.feedComment = appConfObj.AT_FeedComment_Enabled__c;	
			troubleshootingObj.user = appConfObj.AT_User_Enabled__c;	
			troubleshootingObj.debugEnabled = appConfObj.EH_Debug_Enabled__c;
			troubleshootingObj.jsDebugEnabled = appConfObj.EH_JS_Debug_Enabled__c;
			troubleshootingObj.errorStack = appConfObj.EH_UI_Stack_Trace_Enabled__c;	
			troubleshootingObj.currentSimpplrDomain = appConfObj.Simpplr_Domain__c;	
    	}
    	return troubleshootingObj;
    }

    public ManageApplicationWrapper.AnalyticsEmbedsIntegrationsWrapper getAnalyticsEmbedsIntegrationsConfig(){
    	ManageApplicationWrapper.AnalyticsEmbedsIntegrationsWrapper analyticsEmbedsObj= new ManageApplicationWrapper.AnalyticsEmbedsIntegrationsWrapper();
    	
    	String appConfigQuery= 'SELECT GA_Enabled__c, Enable_Google_Analytics4__c, Enable_Google_Analytics3__c, ' + 
				' GA_Tracking_Code__c,GA_Enhanced_Link_Attribution__c,' + 
				'GA_Tracking_Code4__c, GA_Demography_Interests__c,' + 
				' vbrick_Enabled__c, Vbrick_Base_Url__c FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfApplicationIntegrations = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
															
		analyticsEmbedsObj.enableGoogleAnalytics = listOfApplicationIntegrations[0].GA_Enabled__c;  
		analyticsEmbedsObj.enableGoogleAnalytics4 = listOfApplicationIntegrations[0].Enable_Google_Analytics4__c; 
		analyticsEmbedsObj.googleAnalytics = listOfApplicationIntegrations[0].Enable_Google_Analytics3__c; 
		analyticsEmbedsObj.analyticsTrackingId = listOfApplicationIntegrations[0].GA_Tracking_Code__c;	
		analyticsEmbedsObj.analyticsTrackingId4 = listOfApplicationIntegrations[0].GA_Tracking_Code4__c;	
		analyticsEmbedsObj.analyticsEnhancedLinkAttribution = listOfApplicationIntegrations[0].GA_Enhanced_Link_Attribution__c;
		analyticsEmbedsObj.analyticsDemographicsInterestsReports = listOfApplicationIntegrations[0].GA_Demography_Interests__c;
		analyticsEmbedsObj.vbrick = listOfApplicationIntegrations[0].vbrick_Enabled__c && String.isNotBlank(listOfApplicationIntegrations[0].Vbrick_Base_Url__c);
		analyticsEmbedsObj.vbrickBaseURL = listOfApplicationIntegrations[0].Vbrick_Base_Url__c;
		
		return analyticsEmbedsObj;
    }

	public ManageApplicationWrapper.CampaignsIntegrationsWrapper getCampaignsIntegrationsConfig(){
    	ManageApplicationWrapper.CampaignsIntegrationsWrapper campaignsIntegrationObj= new ManageApplicationWrapper.CampaignsIntegrationsWrapper();
		
		String appConfigQuery = 'SELECT Employee_Advocacy_Enabled__c From App_Config__c';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
		List<App_Integration__c> appIntegration = SimpplrContext.Integrations.values();
        for(App_Integration__c obj : appIntegration){
			if(IntegrationConstants.INTEGRATION_TYPE_FACEBOOK.equalsIgnoreCase(obj.Name)){
				campaignsIntegrationObj.facebookEnabled = obj.Connected__c;
			} else if(IntegrationConstants.INTEGRATION_TYPE_TWITTER.equalsIgnoreCase(obj.Name)){
				campaignsIntegrationObj.twitterEnabled = obj.Connected__c;
			} else if(IntegrationConstants.INTEGRATION_TYPE_LINKEDIN.equalsIgnoreCase(obj.Name)){
				campaignsIntegrationObj.linkedInEnabled = obj.Connected__c;
            }
		}
		campaignsIntegrationObj.employeeAdvocacy = appConfigObj.Employee_Advocacy_Enabled__c;
		return campaignsIntegrationObj;
    }

	public App_Config__c fetchSyncingSettings() {
		String appConfigQuery = 'SELECT PDS_Title__c, PDS_First_Name__c, PDS_Last_Name__c, PDS_About_Me__c, PDS_Email__c,'
									+ ' PDS_Birth_Date__c, PDS_Employee_Number__c, PDS_Department__c, PDS_Division__c, PDS_Street__c,'
									+ ' PDS_City__c, PDS_State__c, PDS_Country__c, PDS_Community_Nickname__c, PDS_Joining_Date__c,'
									+ ' PDS_Manager_Id__c, PDS_Company_Name__c, PDS_Extension__c, PDS_Fax__c, PDS_Mobile_Phone__c,'
									+ ' PDS_Phone__c, PDS_Postal_Code__c, PDS_Role__c, PDS_Middle_Name__c, PDS_Enable_Formatting__c,'
									+ ' PDS_Max_Sync_Attempts__c, PDS_Source_Application__c, PDS_Photo__c, PP_User_Custom_Fields__c,'
									+ ' PDS_Street_Key__c, PDS_City_Key__c, PDS_State_Key__c, PDS_Country_Key__c, PDS_Postal_Code_Key__c, '
									+ ' PDS_Birth_Date_Key__c, PDS_Joining_Date_Key__c, PDS_Company_Name_Key__c, PDS_User_Division_Key__c,'
									+ ' PDS_Federation_Id__c, PDS_Query_Filter__c, '
									+ ' PDS_Unique_Identifier__c, PDS_Department_Key__c,PDS_Manager_Unique_Identifier_Key__c '
									+ ' From App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

		return appConfigObj;
	}

	public User_Provisioning_Config__c fetchUserProvisioningSettings() {
		String query = 'Select Id, Provisioning_Source__c, Query_Filter__c,Birthdate_Field__c,Birthdate__c,City__c,Company_Name_Field__c, ' +
			' Company_Name__c, Country__c, Create_New_Users__c, Deactive_User__c,Department__c, ' +
			' Employee_Number__c,Fax__c,FedrationId__c,Firstname__c,Joining_Date_Field__c, ' +
			' Joining_Date__c,Lastname__c,Manager__c,MobilePhone__c,Phone__c,PostalCode__c, ' +
			' Profile_Type__c, Profile__c,State__c,Street__c,TimezoneSidKey__c,Timezone__c, ' +
			' Street_Field__c, City_Field__c, State_Field__c, Country_Field__c, Postal_Code_Field__c, ' +
			' Username_Suffix__c,Username__c,User_Email__c,User_Title__c, Locale__c,Locale_Type__c,Language__c, ' +
			' Language_Type__c,PhoneExtension__c,Send_Emails__c,About__c,Division__c, Manager_Unique_Identifier__c, User_Deprovisioning_Identifier__c ' +
			' FROM User_Provisioning_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<User_Provisioning_Config__c> userProvisioningList = (List<User_Provisioning_Config__c>)SIMPESAPI.accessController().queryAsUser(query, null);

		User_Provisioning_Config__c configObj; 
		if (userProvisioningList!=null && userProvisioningList.size()>0){
			configObj = userProvisioningList[0];
		} else {
			configObj = new User_Provisioning_Config__c();
		}
		return configObj;
	}

	public ManageApplicationWrapper.UserSyncingPeopleWrapper loadSyncingSettings() {
        ManageApplicationWrapper.UserSyncingPeopleWrapper syncingSettings = null;
        try {
			App_Config__c configObj = fetchSyncingSettings();
			syncingSettings = toUserSyncingPeopleWrapper(configObj);
        }
		catch(Exception e) {
            logger.logError('ManageApplicationDao.loadSyncingSettings()----Exception occured----', e);
        }
        return syncingSettings;
	}
	
	public ManageApplicationWrapper.UserProvisioningWrapper loadUserProvisioningSettings() {
		ManageApplicationWrapper.UserProvisioningWrapper provisioningSettings = null;
		try {
			User_Provisioning_Config__c configObj = fetchUserProvisioningSettings();
			provisioningSettings = toUserProvisioningWrapper(configObj);
				
        }
		catch(Exception e) {
            logger.logError('ManageApplicationDao.loadUserProvisioningSettings()----Exception occured----', e);
        }
        return provisioningSettings;
	}
	
	private ManageApplicationWrapper.UserProvisioningWrapper toUserProvisioningWrapper(User_Provisioning_Config__c configObj) {
		ManageApplicationWrapper.UserProvisioningWrapper provisioningWrapper = new ManageApplicationWrapper.UserProvisioningWrapper();
		
		provisioningWrapper.provisioningSource = (configObj.Provisioning_Source__c == null) ? 'Google' : configObj.Provisioning_Source__c;
		provisioningWrapper.queryFilter = (configObj.Query_Filter__c == null) ? '' : configObj.Query_Filter__c;
		provisioningWrapper.createNewUser = (configObj.Create_New_Users__c == null) ? 'false' : String.valueOf(configObj.Create_New_Users__c);
		provisioningWrapper.profile = true;
		FilterService serviceObj = new FilterService();
		provisioningWrapper.availableProfiles = serviceObj.getAllProfilesListForFilters();
		provisioningWrapper.profileType = (configObj.Profile_Type__c == null) ? '' : configObj.Profile_Type__c;
		provisioningWrapper.username = (configObj.Username__c == null) ? false : configObj.Username__c;
		provisioningWrapper.usernameSuffix = (configObj.Username_Suffix__c == null) ? '' : configObj.Username_Suffix__c;
		provisioningWrapper.firstName = (configObj.Firstname__c == null) ? false : configObj.Firstname__c;
		provisioningWrapper.lastName = true;
		provisioningWrapper.userTitle = (configObj.User_Title__c == null) ? false : configObj.User_Title__c;
		provisioningWrapper.birthDate = (configObj.Birthdate__c == null) ? false : configObj.Birthdate__c;
		provisioningWrapper.birthDateField = (configObj.Birthdate_Field__c == null) ? '' : configObj.Birthdate_Field__c;
		provisioningWrapper.joiningDate = (configObj.Joining_Date__c == null) ? false : configObj.Joining_Date__c;
		provisioningWrapper.joiningDateField = (configObj.Joining_Date_Field__c == null) ?  '' : configObj.Joining_Date_Field__c;
		provisioningWrapper.companyName = (configObj.Company_Name__c == null) ? false : configObj.Company_Name__c;
		provisioningWrapper.companyNameField = (configObj.Company_Name_Field__c == null) ?  '' : configObj.Company_Name_Field__c;
		provisioningWrapper.department = (configObj.Department__c == null) ? false : configObj.Department__c;
		provisioningWrapper.manager = (configObj.Manager__c == null) ? false : configObj.Manager__c;
		provisioningWrapper.employeeNumber = (configObj.Employee_Number__c == null) ? false : configObj.Employee_Number__c;
		provisioningWrapper.federationId = (configObj.FedrationId__c == null) ? false : configObj.FedrationId__c;
		provisioningWrapper.phone = (configObj.Phone__c == null) ? false : configObj.Phone__c;
		provisioningWrapper.mobilePhone = (configObj.MobilePhone__c == null) ? false : configObj.MobilePhone__c;
		provisioningWrapper.userEmail = (configObj.User_Email__c == null) ? false : configObj.User_Email__c;
		provisioningWrapper.fax = (configObj.fax__c == null) ? false : configObj.fax__c;
		provisioningWrapper.street = (configObj.street__c == null) ? false : configObj.street__c;
		provisioningWrapper.city = (configObj.city__c == null) ? false : configObj.city__c;
		provisioningWrapper.country = (configObj.country__c == null) ? false : configObj.country__c;
		provisioningWrapper.state = (configObj.state__c == null) ?  false : configObj.state__c;
		provisioningWrapper.postalCode = (configObj.postalCode__c == null) ?  false : configObj.postalCode__c;
		provisioningWrapper.timezone = (configObj.Timezone__c == null) ?  false : configObj.Timezone__c;
		provisioningWrapper.managerUniqueIdentifier = (configObj.Manager_Unique_Identifier__c == null) ? 'username' : configObj.Manager_Unique_Identifier__c;
		provisioningWrapper.userDeprovisioningIdentifier = (configObj.User_Deprovisioning_Identifier__c == null) ? 'username' : configObj.User_Deprovisioning_Identifier__c;
		provisioningWrapper.locale = (configObj.Locale__c == null) ?  false : configObj.Locale__c;
		provisioningWrapper.localeType = (configObj.Locale_Type__c == null) ?  '' : configObj.Locale_Type__c;
		provisioningWrapper.language = (configObj.Language__c == null) ?  false : configObj.Language__c;
		provisioningWrapper.languageType = (configObj.Language_Type__c == null) ?  '' : configObj.Language_Type__c;
		provisioningWrapper.phoneExtension = (configObj.PhoneExtension__c == null) ?  false : configObj.PhoneExtension__c;
		provisioningWrapper.sendEmails = (configObj.Send_Emails__c == null) ?  'false' : String.valueOf(configObj.Send_Emails__c);
		provisioningWrapper.about = (configObj.About__c == null) ?  false : configObj.About__c;
		provisioningWrapper.division = (configObj.Division__c == null) ?  false : configObj.Division__c	;
		provisioningWrapper.availableLocale = serviceObj.getAllLocale();
		String appConfigQuery = 'SELECT PDS_Source_Application__c From App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c checkSyncSource = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		if(('CsvFile'.equalsIgnoreCase(checkSyncSource.PDS_Source_Application__c) == true )|| ('CsvFile'.equalsIgnoreCase(configObj.Provisioning_Source__c) == true)){
			provisioningWrapper.CsvSaved = true;
		}
		else {provisioningWrapper.CsvSaved = false;}
		if (provisioningWrapper.timezone){
			if (configObj.TimezoneSidKey__c!=null){
				TimeZone tz = Timezone.getTimeZone(configObj.TimezoneSidKey__c);
				provisioningWrapper.timezoneName = Utility.timezoneIdToDisplayLabel(configObj.TimezoneSidKey__c);
				provisioningWrapper.timezoneIso = tz.getID();
			} else {
				provisioningWrapper.timezoneName = '';
				provisioningWrapper.timezoneIso = '';
			}
		} else {
			provisioningWrapper.timezoneName = '';
			provisioningWrapper.timezoneIso = '';
		}
		if('Google'.equalsIgnoreCase(provisioningWrapper.provisioningSource)){
			if(String.isNotBlank(configObj.Street_Field__c)){
				provisioningWrapper.streetNameKey = configObj.Street_Field__c;
				provisioningWrapper.streetKey = 'custom';
			}else{
				provisioningWrapper.streetKey = 'standard';
			}
			if(String.isNotBlank(configObj.City_Field__c)){
				provisioningWrapper.cityNameKey = configObj.City_Field__c;
				provisioningWrapper.cityKey = 'custom';
			}else{
				provisioningWrapper.cityKey = 'standard';
			}
			if(String.isNotBlank(configObj.State_Field__c)){
				provisioningWrapper.stateNameKey = configObj.State_Field__c;
				provisioningWrapper.stateKey = 'custom';
			}else{
				provisioningWrapper.stateKey = 'standard';
			}
			if(String.isNotBlank(configObj.Country_Field__c)){
				provisioningWrapper.countryNameKey = configObj.Country_Field__c;
				provisioningWrapper.countryKey = 'custom';
			}else{
				provisioningWrapper.countryKey = 'standard';
			}
			if(String.isNotBlank(configObj.Postal_Code_Field__c)){
				provisioningWrapper.postalCodeNameKey = configObj.Postal_Code_Field__c;
				provisioningWrapper.postalCodeKey = 'custom';
			}else{
				provisioningWrapper.postalCodeKey = 'standard';
			}
		}
		provisioningWrapper.deactiveUsers = (configObj.Deactive_User__c == null) ?  'false' : String.valueOf(configObj.Deactive_User__c);
		
		return provisioningWrapper;
	}
    
    private ManageApplicationWrapper.UserSyncingPeopleWrapper toUserSyncingPeopleWrapper(App_Config__c configObj) {
    	ManageApplicationWrapper.UserSyncingPeopleWrapper syncingWrapper = new ManageApplicationWrapper.UserSyncingPeopleWrapper();
    	
		syncingWrapper.syncSource = configObj.PDS_Source_Application__c;
		syncingWrapper.uniqueIdentifier = configObj.PDS_Unique_Identifier__c;
		syncingWrapper.queryFilter = configObj.PDS_Query_Filter__c;
		syncingWrapper.enableFormatting = configObj.PDS_Enable_Formatting__c;
		 
		syncingWrapper.firstName = configObj.PDS_First_Name__c;
		syncingWrapper.middleName = configObj.PDS_Middle_Name__c;
		syncingWrapper.lastName = configObj.PDS_Last_Name__c;
		syncingWrapper.birthDate = configObj.PDS_Birth_Date__c;
		
		syncingWrapper.userTitle = configObj.PDS_Title__c;
		syncingWrapper.userEmail = configObj.PDS_Email__c;
		syncingWrapper.communityNickname = configObj.PDS_Community_Nickname__c;
		syncingWrapper.aboutMe = configObj.PDS_About_Me__c;
		
		syncingWrapper.employeeNumber = configObj.PDS_Employee_Number__c;
		syncingWrapper.manager = configObj.PDS_Manager_Id__c;
		syncingWrapper.department = configObj.PDS_Department__c;
		syncingWrapper.userDivision = configObj.PDS_Division__c;
		syncingWrapper.companyName = configObj.PDS_Company_Name__c;
		syncingWrapper.joiningDate = configObj.PDS_Joining_Date__c;
		syncingWrapper.userRole = configObj.PDS_Role__c;
		
		syncingWrapper.street = configObj.PDS_Street__c;
		syncingWrapper.postalCode = configObj.PDS_Postal_Code__c;
		syncingWrapper.city = configObj.PDS_City__c;
		syncingWrapper.state = configObj.PDS_State__c;
		syncingWrapper.country = configObj.PDS_Country__c;
		
		syncingWrapper.phone = configObj.PDS_Phone__c;
		syncingWrapper.extension = configObj.PDS_Extension__c;
		syncingWrapper.mobilePhone = configObj.PDS_Mobile_Phone__c;
		syncingWrapper.fax = configObj.PDS_Fax__c;
		syncingWrapper.photo = configObj.PDS_Photo__c;

		syncingWrapper.joiningDateKey = configObj.PDS_Joining_Date_Key__c;
		syncingWrapper.companyNameKey = configObj.PDS_Company_Name_Key__c;
		
		syncingWrapper.federationId = configObj.PDS_Federation_Id__c;
		syncingWrapper.manager = configObj.PDS_Manager_Id__c;
		if('UkgPro'.equalsIgnoreCase(syncingWrapper.syncSource)){
			syncingWrapper.ukgProBirthDateKey = configObj.PDS_Birth_Date_Key__c;
			syncingWrapper.ukgProUserDivisionKey = configObj.PDS_User_Division_Key__c;
			syncingWrapper.ukgProDepartmentKey = configObj.PDS_Department_Key__c;
		}
		else{
			syncingWrapper.birthDateKey = configObj.PDS_Birth_Date_Key__c;
			syncingWrapper.userDivisionKey = configObj.PDS_User_Division_Key__c;
			syncingWrapper.ukgProDepartmentKey = configObj.PDS_Department_Key__c;
		}
		if('Google'.equalsIgnoreCase(syncingWrapper.syncSource)){
			if(String.isNotBlank(configObj.PDS_Street_Key__c)){
				syncingWrapper.streetNameKey = configObj.PDS_Street_Key__c;
				syncingWrapper.streetKey = 'custom';
			}else{
				syncingWrapper.streetKey = 'standard';
			}
			if(String.isNotBlank(configObj.PDS_City_Key__c)){
				syncingWrapper.cityNameKey = configObj.PDS_City_Key__c;
				syncingWrapper.cityKey = 'custom';
			}else{
				syncingWrapper.cityKey = 'standard';
			}
			if(String.isNotBlank(configObj.PDS_State_Key__c)){
				syncingWrapper.stateNameKey = configObj.PDS_State_Key__c;
				syncingWrapper.stateKey = 'custom';
			}else{
				syncingWrapper.stateKey = 'standard';
			}
			if(String.isNotBlank(configObj.PDS_Country_Key__c)){
				syncingWrapper.countryNameKey = configObj.PDS_Country_Key__c;
				syncingWrapper.countryKey = 'custom';
			}else{
				syncingWrapper.countryKey = 'standard';
			}
			if(String.isNotBlank(configObj.PDS_Postal_Code_Key__c)){
				syncingWrapper.postalCodeNameKey = configObj.PDS_Postal_Code_Key__c;
				syncingWrapper.postalCodeKey = 'custom';
			}else{
				syncingWrapper.postalCodeKey = 'standard';
			}
		} 
		String userProvQuery = 'SELECT Provisioning_Source__c From User_Provisioning_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<User_Provisioning_Config__c> userProvList = ((List<User_Provisioning_Config__c>)SIMPESAPI.accessController().queryAsUser(userProvQuery, null));

		if((!userProvList.isEmpty() && 'CsvFile'.equalsIgnoreCase(userProvList[0].Provisioning_Source__c) == true ) 
			|| ('CsvFile'.equalsIgnoreCase(configObj.PDS_Source_Application__c) == true)) {
			syncingWrapper.CsvSaved = true;
		} else {
			syncingWrapper.CsvSaved = false;
		}

		
		ManageApplicationWrapper.LastSyncInfoWrapper lastsyncInfoObj = null;
		if('None'.equalsIgnoreCase(syncingWrapper.syncSource) == false){

			List<Audit_Trail__c> auditTrailList = [SELECT Id, New_Value__c, CreatedDate FROM Audit_Trail__c
													 WHERE Object_Name__c = 'User Sync' WITH SECURITY_ENFORCED
													 ORDER BY createddate DESC LIMIT 1];

			if(auditTrailList != null 
					&& !auditTrailList.isEmpty() 
					&& syncingWrapper.syncSource.equalsIgnoreCase(auditTrailList[0].New_Value__c)){
				
				String sourceInfo = 'User Sync ' + syncingWrapper.syncSource;		
				List<Logs__c> logsList = [SELECT Id, CreatedDate, Log_Data__c FROM Logs__c 
											WHERE CreatedDate > :auditTrailList[0].CreatedDate AND Log_Type__c = 'INFO' AND
											Is_Deleted__c = false AND Source_Info__c = :sourceInfo WITH SECURITY_ENFORCED
											ORDER BY createddate desc limit 1];

				if(logsList != null && !logsList.isEmpty()){
					lastsyncInfoObj = new ManageApplicationWrapper.LastSyncInfoWrapper();
					lastsyncInfoObj.lastRunAt = logsList[0].CreatedDate == null ? '' : logsList[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
					lastsyncInfoObj.status = logsList[0].Log_Data__c;

				} else {
					// logs not found i.e. job hasn't run yet
				}							

			} else {
				// audit trail entry not found i.e. data source not selected yet

			}

		}

		syncingWrapper.lastSyncInfo = lastsyncInfoObj;
		
		syncingWrapper.additionalFields = new List<CustomProfileField>();
		if(String.isNotBlank(configObj.PP_User_Custom_Fields__c)) {
			List<CustomProfileField> allCustomFields = (List<CustomProfileField>)
													Json.deserialize(configObj.PP_User_Custom_Fields__c, 
													Type.forName('List<CustomProfileField>'));
			
			if(!allCustomFields.isEmpty()) {
				String audienceQuery = 'SELECT id, Has_Custom_Field_1_Condition__c, Has_Custom_Field_2_Condition__c, Has_Custom_Field_3_Condition__c, Has_Custom_Field_4_Condition__c, Has_Custom_Field_5_Condition__c, '+
									' Has_Custom_Field_6_Condition__c, Has_Custom_Field_7_Condition__c, Has_Custom_Field_8_Condition__c, Has_Custom_Field_9_Condition__c, Has_Custom_Field_10_Condition__c, '+
									' Has_Custom_Field_11_Condition__c, Has_Custom_Field_12_Condition__c, Has_Custom_Field_13_Condition__c, Has_Custom_Field_14_Condition__c, Has_Custom_Field_15_Condition__c, '+
									' Has_Custom_Field_16_Condition__c, Has_Custom_Field_17_Condition__c, Has_Custom_Field_18_Condition__c, Has_Custom_Field_19_Condition__c, Has_Custom_Field_20_Condition__c, '+
									' Has_Custom_Field_21_Condition__c, Has_Custom_Field_22_Condition__c, Has_Custom_Field_23_Condition__c, Has_Custom_Field_24_Condition__c, Has_Custom_Field_25_Condition__c '+
									' FROM Audience__c where Is_Deleted__c = false ';

				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Audience__c> audienceList = (List<Audience__c>)SIMPESAPI.accessController().queryAsUser(audienceQuery, null);

				Boolean hasCustomField1 = false;
				Boolean hasCustomField2 = false;
				Boolean hasCustomField3 = false;
				Boolean hasCustomField4 = false;
				Boolean hasCustomField5 = false;
				Boolean hasCustomField6 = false;
				Boolean hasCustomField7 = false;
				Boolean hasCustomField8 = false;
				Boolean hasCustomField9 = false;
				Boolean hasCustomField10 = false;
				Boolean hasCustomField11 = false;
				Boolean hasCustomField12 = false;
				Boolean hasCustomField13 = false;
				Boolean hasCustomField14 = false;
				Boolean hasCustomField15 = false;
				Boolean hasCustomField16 = false;
				Boolean hasCustomField17 = false;
				Boolean hasCustomField18 = false;
				Boolean hasCustomField19 = false;
				Boolean hasCustomField20 = false;
				Boolean hasCustomField21 = false;
				Boolean hasCustomField22 = false;
				Boolean hasCustomField23 = false;
				Boolean hasCustomField24 = false;
				Boolean hasCustomField25 = false;


				for(Audience__c audienceObj : audienceList) {
					if(audienceObj.Has_Custom_Field_1_Condition__c) {
						hasCustomField1 = true;
					}
					if(audienceObj.Has_Custom_Field_2_Condition__c) {
						hasCustomField2 = true;
					}
					if(audienceObj.Has_Custom_Field_3_Condition__c) {
						hasCustomField3 = true;
					}
					if(audienceObj.Has_Custom_Field_4_Condition__c) {
						hasCustomField4 = true;
					}
					if(audienceObj.Has_Custom_Field_5_Condition__c) {
						hasCustomField5 = true;
					}
					if(audienceObj.Has_Custom_Field_6_Condition__c) {
						hasCustomField6 = true;
					}
					if(audienceObj.Has_Custom_Field_7_Condition__c) {
						hasCustomField7 = true;
					}
					if(audienceObj.Has_Custom_Field_8_Condition__c) {
						hasCustomField8 = true;
					}
					if(audienceObj.Has_Custom_Field_9_Condition__c) {
						hasCustomField9 = true;
					}
					if(audienceObj.Has_Custom_Field_10_Condition__c) {
						hasCustomField10 = true;
					}
					if(audienceObj.Has_Custom_Field_11_Condition__c) {
						hasCustomField11 = true;
					}
					if(audienceObj.Has_Custom_Field_12_Condition__c) {
						hasCustomField12 = true;
					}
					if(audienceObj.Has_Custom_Field_13_Condition__c) {
						hasCustomField13 = true;
					}
					if(audienceObj.Has_Custom_Field_14_Condition__c) {
						hasCustomField14 = true;
					}
					if(audienceObj.Has_Custom_Field_15_Condition__c) {
						hasCustomField15 = true;
					}

					if(audienceObj.Has_Custom_Field_16_Condition__c) {
						hasCustomField16 = true;
					}
					if(audienceObj.Has_Custom_Field_17_Condition__c) {
						hasCustomField17 = true;
					}

					if(audienceObj.Has_Custom_Field_18_Condition__c) {
						hasCustomField18 = true;
					}
					if(audienceObj.Has_Custom_Field_19_Condition__c) {
						hasCustomField19 = true;
					}
					if(audienceObj.Has_Custom_Field_20_Condition__c) {
						hasCustomField20 = true;
					}
					if(audienceObj.Has_Custom_Field_21_Condition__c) {
						hasCustomField21 = true;
					}
					if(audienceObj.Has_Custom_Field_22_Condition__c) {
						hasCustomField22 = true;
					}
					if(audienceObj.Has_Custom_Field_23_Condition__c) {
						hasCustomField23 = true;
					}
					if(audienceObj.Has_Custom_Field_24_Condition__c) {
						hasCustomField24 = true;
					}
					if(audienceObj.Has_Custom_Field_25_Condition__c) {
						hasCustomField25 = true;
					}
					
				}

				for(CustomProfileField customField : allCustomFields) {
					if(String.isNotBlank(customField.syncSource) && customField.syncSource.equalsIgnoreCase(syncingWrapper.syncSource)) {

						if( (hasCustomField1 && 'Custom_Field_1__c'.equalsIgnoreCase(customField.columnName))
								|| (hasCustomField2 && 'Custom_Field_2__c'.equalsIgnoreCase(customField.columnName))
								|| (hasCustomField3 && 'Custom_Field_3__c'.equalsIgnoreCase(customField.columnName))
								|| (hasCustomField4 && 'Custom_Field_4__c'.equalsIgnoreCase(customField.columnName))
								|| (hasCustomField5 && 'Custom_Field_5__c'.equalsIgnoreCase(customField.columnName))
								|| (hasCustomField6 && 'Custom_Field_6__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField7 && 'Custom_Field_7__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField8 && 'Custom_Field_8__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField9 && 'Custom_Field_9__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField10 && 'Custom_Field_10__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField11 && 'Custom_Field_11__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField12 && 'Custom_Field_12__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField13 && 'Custom_Field_13__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField14 && 'Custom_Field_14__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField15 && 'Custom_Field_15__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField16 && 'Custom_Field_16__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField17 && 'Custom_Field_17__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField18 && 'Custom_Field_18__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField19 && 'Custom_Field_19__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField20 && 'Custom_Field_20__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField21 && 'Custom_Field_21__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField22 && 'Custom_Field_22__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField23 && 'Custom_Field_23__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField24 && 'Custom_Field_24__c'.equalsIgnoreCase(customField.columnName)) 
								|| (hasCustomField25 && 'Custom_Field_25__c'.equalsIgnoreCase(customField.columnName)) ) {
							
							customField.usedForAudience = true;
						}

						syncingWrapper.additionalFields.add(customField);
					}
				}
			}
		}
    	
    	return syncingWrapper;
    }    
	
	public ManageApplicationWrapper.PrivilegesSetupWrapper fetchAllPrivileges(String peopleSearchLabel, String siteSearchLabel, Boolean isCampaignManagerFeatureEnabled){
		
		ManageApplicationWrapper.PrivilegesSetupWrapper  privilegesSetupObj = new ManageApplicationWrapper.PrivilegesSetupWrapper();
		
		String appConfigQuery = 'SELECT id, Allow_Site_Add__c, Employee_Advocacy_Enabled__c, Segment_Enabled__c, Site_Level_Onboarding__c, Allow_Leadercast__c, Content_Moderation_Enabled__c, Is_Onboarding_Disabled__c, Is_My_Teams_Analytics_Enabled__c FROM App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
		List<PeopleWrapper> influencersList = new List<PeopleWrapper>();
		List<PeopleWrapper> newsletterControlPeople = new List<PeopleWrapper>();
		List<PeopleWrapper> canAccessAnalyticsList = new List<PeopleWrapper>();
		List<PeopleWrapper> canAccessAlertsPeople = new List<PeopleWrapper>();
		List<SiteLiteWrapper> isNewsletterAllowedList = new List<SiteLiteWrapper>();
		List<SiteLiteWrapper> mustReadsEnabledSites = new List<SiteLiteWrapper>();
		List<SiteLiteWrapper> alertsControlSite = new List<SiteLiteWrapper>();
		List<PeopleWrapper> listOfPplToControlDashboard = new List<PeopleWrapper>();
		List<PeopleWrapper> listOfPplToManageCampaign = new List<PeopleWrapper>();
		List<PeopleWrapper> listOfPplToControlUnlistedSites = new List<PeopleWrapper>();
		List<PeopleWrapper> listOfPplToControlApp = new List<PeopleWrapper>();
		List<PeopleWrapper> listOfPplToControlCampaign = new List<PeopleWrapper>();
		List<PeopleWrapper> addSiteUsers = new List<PeopleWrapper>();
		List<PeopleWrapper> listOfProtectedAuthorAllowlisted = new List<PeopleWrapper>();
		List<PeopleWrapper> listOfProtectedAuthor = new List<PeopleWrapper>();
		List<PeopleWrapper> leadercastControlPeopleList = new List<PeopleWrapper>();
		List<SiteLiteWrapper> leadercastControlSitesList = new List<SiteLiteWrapper>();
		Boolean canControlDashboard =  false;
        List<PeopleWrapper> onboardingPeopleList = new List<PeopleWrapper>();
        List<SiteLiteWrapper> onboardingSiteList = new List<SiteLiteWrapper>();
		List<PeopleWrapper> initiativesAndCampaignsManagers = new List<PeopleWrapper>();
		List<PeopleWrapper> addContentModerationUsers = new List<PeopleWrapper>();
		List<People__c> peopleList = new List<People__c>();  
		
		String query = 'Select Id, Full_Name__c,User__r.SmallPhotoUrl,Is_Influencer__c,Can_Access_Analytics__c,Can_Control_Dashboard__c, Can_Access_Leadercast__c, '+
							' CI_Moderation_Permission__c, Can_Add_Sites__c, Can_Send_Newsletter__c,Can_Send_Alert__c,Is_Campaign_Manager__c,App_Moderation_Permission__c,Campaign_Moderation_Permission__c,Unlisted_Site_Moderation_Permission__c,Is_Protected_Author_Allowlisted__c,Is_Protected_Author__c, Enable_Org_Level_Onboarding__c , Is_Content_Moderator__c from People__c where (Is_Influencer__c = true OR Can_Access_Analytics__c = true OR '+
							' Can_Send_Newsletter__c = true OR Can_Control_Dashboard__c = true OR Is_Campaign_Manager__c = true OR Can_Add_Sites__c = true OR Is_Protected_Author_Allowlisted__c = true OR Is_Protected_Author__c = true OR'+
							' Can_Send_Alert__c = true OR Can_Access_Leadercast__c = true OR App_Moderation_Permission__c = \'Yes\' OR Campaign_Moderation_Permission__c = \'Yes\' OR Unlisted_Site_Moderation_Permission__c = \'Yes\' OR Enable_Org_Level_Onboarding__c = true OR Is_Content_Moderator__c = true OR'+
							' CI_Moderation_Permission__c = true )';
							
		if (Utility.isApiOnlyUserQueryable()) {
			query  += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\' AND user__r.Profile.PermissionsApiUserOnly = false))';
		} else {
			query  += ' And (User__r.Show_Simpplr__c =\'Yes\' OR (user__r.Show_Simpplr__c != \'No\' AND user__r.isActive=true AND user__r.UserType=\'Standard\'))';
		}		
					
		peopleList = DataBase.query(query);
	    	
		for(People__c ppl: peopleList){
			PeopleWrapper pplWraperObj = new PeopleWrapper();
			
			pplWraperObj.id = ppl.id;
			pplWraperObj.peopleId = ppl.id;
    		pplWraperObj.name = ppl.Full_Name__c;
    		pplWraperObj.smallPhotoUrl = ppl.User__r.SmallPhotoUrl;
    		pplWraperObj.jsonDataString = createDataParam(pplWraperObj.id,pplWraperObj.name,pplWraperObj.smallPhotoUrl);
			
			if(ppl.Is_Protected_Author_Allowlisted__c == true ){
	    		listOfProtectedAuthorAllowlisted.add(pplWraperObj);
			}

			if(ppl.Is_Protected_Author__c == true ){
	    		listOfProtectedAuthor.add(pplWraperObj);
			}

			if(ppl.Is_Influencer__c == true ){
	    		influencersList.add(pplWraperObj);
			}
			
			if(ppl.Can_Access_Analytics__c == true){
	    		canAccessAnalyticsList.add(pplWraperObj);
			}
			
			if(ppl.Can_Send_Newsletter__c == true){
	    		newsletterControlPeople.add(pplWraperObj);
			}
			
			if(ppl.Can_Send_Alert__c == true){
	    		canAccessAlertsPeople.add(pplWraperObj);
			}
			
			if(ppl.Can_Control_Dashboard__c == true){
	    		listOfPplToControlDashboard.add(pplWraperObj);
			}
			
			if(appConfigList[0].Employee_Advocacy_Enabled__c && ppl.Is_Campaign_Manager__c == true){
	    		listOfPplToManageCampaign.add(pplWraperObj);
			}
			
			if('Yes'.equalsIgnoreCase(ppl.Unlisted_Site_Moderation_Permission__c)){
	    		listOfPplToControlUnlistedSites.add(pplWraperObj);
			}
			
			if('Yes'.equalsIgnoreCase(ppl.App_Moderation_Permission__c)){
	    		listOfPplToControlApp.add(pplWraperObj);
			}

			if('Yes'.equalsIgnoreCase(ppl.Campaign_Moderation_Permission__c) && isCampaignManagerFeatureEnabled == true){
	    		listOfPplToControlCampaign.add(pplWraperObj);
			}
			
			if (ppl.Can_Add_Sites__c == true) {
				addSiteUsers.add(pplWraperObj);
			}

			if (ppl.Is_Content_Moderator__c == true) {
				addContentModerationUsers.add(pplWraperObj);
			}

            if(ppl.Enable_Org_Level_Onboarding__c) {
                onboardingPeopleList.add(pplWraperObj);
            }
			if(ppl.Can_Access_Leadercast__c == true) {
				leadercastControlPeopleList.add(pplWraperObj);
			}

			if (ppl.CI_Moderation_Permission__c == true) {
				initiativesAndCampaignsManagers.add(pplWraperObj);
			}
		}
		influencersList.sort();
		newsletterControlPeople.sort();
		canAccessAnalyticsList.sort();
		canAccessAlertsPeople.sort();
		listOfPplToControlDashboard.sort();
		listOfPplToControlUnlistedSites.sort();
		listOfPplToControlApp.sort();
		listOfPplToControlCampaign.sort();
		addSiteUsers.sort();
		listOfProtectedAuthor.sort();
		listOfProtectedAuthorAllowlisted.sort();
		onboardingPeopleList.sort();
		leadercastControlPeopleList.sort();
		initiativesAndCampaignsManagers.sort();
		
		privilegesSetupObj.isEmployeeAdvocacyEnabled  = SimpplrContext.isFeatureEnabled('Employee_Advocacy') && appConfigList[0].Employee_Advocacy_Enabled__c;
		privilegesSetupObj.isHomeManagementEnabled = appConfigList[0].Segment_Enabled__c ?false:true;
		if(privilegesSetupObj.isEmployeeAdvocacyEnabled){
			listOfPplToManageCampaign.sort();
			privilegesSetupObj.canManageSocialCampaign = listOfPplToManageCampaign;
		}
		
		privilegesSetupObj.influencers = influencersList;
		privilegesSetupObj.newsletterControlPeople = newsletterControlPeople;
		privilegesSetupObj.analyticsAccess = canAccessAnalyticsList;
		privilegesSetupObj.canAccessAlertsPeople = canAccessAlertsPeople;
		privilegesSetupObj.canControlHomeDashboard = listOfPplToControlDashboard;
		privilegesSetupObj.protectedAuthorAllowlisted = listOfProtectedAuthorAllowlisted;
		privilegesSetupObj.protectedAuthor = listOfProtectedAuthor;
		privilegesSetupObj.unlistedSitesManagingPeopleIdSet = new Set<PeopleWrapper>(listOfPplToControlUnlistedSites);
		privilegesSetupObj.appManagingPeopleIdSet = new Set<PeopleWrapper>(listOfPplToControlApp);
		if(isCampaignManagerFeatureEnabled)
			privilegesSetupObj.campaignManagingPeopleIdSet = new Set<PeopleWrapper>(listOfPplToControlCampaign);
		privilegesSetupObj.addSitesPermission = appConfigList[0].Allow_Site_Add__c;
		privilegesSetupObj.addSitesUserSet = new Set<PeopleWrapper>(addSiteUsers);
		privilegesSetupObj.leadercastPermission = appConfigList[0].Allow_Leadercast__c;
		privilegesSetupObj.leadercastControlPeople = leadercastControlPeopleList;
		privilegesSetupObj.initiativesAndCampaignsManagers = initiativesAndCampaignsManagers;
		if(SimpplrContext.aiContentModerationFeatureEnabled){
			privilegesSetupObj.isAIContentModerationEnabled = appConfigList[0].Content_Moderation_Enabled__c;
			privilegesSetupObj.contentModeratorPeopleList = new List<PeopleWrapper>(addContentModerationUsers);
		}
		List<Simpplr_Site__c> listOfSite = [ Select Id,Name, Chatter_Group_Id__c, Site_Type__c,Title_Content_Version__c,Landing_Page__c,Is_Alert_Enabled__c,
                                            Is_Newsletter_Allowed__c, Is_Must_Read_Enabled__c, Is_Onboarding_Enabled__c, Is_Leadercast_Enabled__c 
                                            from Simpplr_Site__c WHERE Is_Active__c = true AND Is_Deleted__c = false 
                                            AND (Is_Must_Read_Enabled__c = true OR Is_Alert_Enabled__c = true OR Is_Newsletter_Allowed__c = true OR Is_Leadercast_Enabled__c = true OR Is_Onboarding_Enabled__c = true) WITH SECURITY_ENFORCED order by Name];

		for(Simpplr_Site__c siteObj : listOfSite){
			SiteLiteWrapper siteWrapperObj = new SiteLiteWrapper ();
            siteWrapperObj.siteId = siteObj.id;
            siteWrapperObj.name = siteObj.Name;
            siteWrapperObj.img = String.isBlank(siteObj.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(siteObj.Title_Content_Version__c);
            siteWrapperObj.imgThumbnail = String.isBlank(siteObj.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(siteObj.Title_Content_Version__c);
            siteWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.Id + '/' + siteObj.Landing_Page__c;
            siteWrapperObj.access = siteObj.Site_Type__c;
            siteWrapperObj.isMember = UserContext.sitesIFollowIdSet.contains(siteObj.id);
            siteWrapperObj.jsonDataString = JSON.serialize(siteWrapperObj);
            
			if(siteObj.Is_Newsletter_Allowed__c){
	        	isNewsletterAllowedList.add(siteWrapperObj);
			}
			
			if(siteObj.Is_Must_Read_Enabled__c){
				mustReadsEnabledSites.add(siteWrapperObj);
			}

			if(siteObj.Is_Alert_Enabled__c){
	        	alertsControlSite.add(siteWrapperObj);
			}

            if(siteObj.Is_Onboarding_Enabled__c) {
                onboardingSiteList.add(siteWrapperObj);
            }
			if(siteObj.Is_Leadercast_Enabled__c == true) {
				siteWrapperObj.siteId = siteObj.id;
				siteWrapperObj.name = siteObj.Name;
				siteWrapperObj.img = String.isBlank(siteObj.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(siteObj.Title_Content_Version__c);
	        	siteWrapperObj.imgThumbnail = String.isBlank(siteObj.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(siteObj.Title_Content_Version__c);
	        	siteWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.Id + '/' + siteObj.Landing_Page__c;
	        	siteWrapperObj.access = siteObj.Site_Type__c;
	        	siteWrapperObj.isMember = UserContext.sitesIFollowIdSet.contains(siteObj.id);
	        	siteWrapperObj.jsonDataString = JSON.serialize(siteWrapperObj);
	        	
	        	leadercastControlSitesList.add(siteWrapperObj);
			}
		}

		privilegesSetupObj.newsletterControlSite = isNewsletterAllowedList;
		privilegesSetupObj.mustReadsControlSite = mustReadsEnabledSites;
		privilegesSetupObj.alertsControlSite = alertsControlSite;
		privilegesSetupObj.onboardingSiteList = onboardingSiteList;
		privilegesSetupObj.onboardingPeopleList = onboardingPeopleList;
		privilegesSetupObj.onboardingSitePermission = appConfigList[0].Site_Level_Onboarding__c;
		privilegesSetupObj.leadercastControlSites = leadercastControlSitesList;
		privilegesSetupObj.isOnboardingEnabled = appConfigList[0].Is_Onboarding_Disabled__c ? false : true ; 
		privilegesSetupObj.isMyTeamsAnalyticsSettingEnabled = appConfigList[0].Is_My_Teams_Analytics_Enabled__c ; 
		return privilegesSetupObj;
	}

	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static String createDataParam(String id, String name, String profImg) {
		Map<String,Object> mapOfListingParams = new Map<String,Object>();
	    String profileImg = profImg.endsWith('005/T') ? null : profImg;
	    mapOfListingParams.put('id',id);
	    mapOfListingParams.put('name',name);
	    mapOfListingParams.put('img',profileImg);
	    return JSON.serialize(mapOfListingParams);
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public  ManageApplicationWrapper.DefaultFeedSettingsWrapper getDefaultFeedSettings(){
    	ManageApplicationWrapper.DefaultFeedSettingsWrapper defaultFeedObj = new ManageApplicationWrapper.DefaultFeedSettingsWrapper();
		String query = 'select id, Data__c,OverwriteBatchInProgress__c, LastModifiedDate, Last_Modified_By_People__c, Last_Modified_By_People__r.Full_Name__c from App_Default__c where Type__c =\'home-feed\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
    	if(appDefaultList.isEmpty()) {
    		defaultFeedObj = new ManageApplicationWrapper.DefaultFeedSettingsWrapper();
    		PostInstallHelper piHelper = new PostInstallHelper();
    		ManageApplicationWrapper.DefaultFeedSettingsWrapper feedObj = piHelper.getDefaultFeedSettings();
			defaultFeedObj.feedSetting = String.isNotBlank(defaultFeedObj.feedSetting) ?  defaultFeedObj.feedSetting : 'news';
    		defaultFeedObj.feedFilter = String.isNotBlank(defaultFeedObj.feedFilter) ?  defaultFeedObj.feedFilter : 'date';
    	} else {
    		defaultFeedObj = (ManageApplicationWrapper.DefaultFeedSettingsWrapper)JSON.deserialize(appDefaultList[0].Data__c,ManageApplicationWrapper.DefaultFeedSettingsWrapper.class);
			defaultFeedObj.isProcessing = appDefaultList[0].OverwriteBatchInProgress__c;
			defaultFeedObj.isApplyToAllUsers = null;
    		defaultFeedObj.appDefaultLastModifiedDate = appDefaultList[0].LastModifiedDate.format('MMM d, YYYY');
    		defaultFeedObj.appDefaultLastModifiedByURL = PageContext.getPageURL(Pages.app) + '?u=/people/' + appDefaultList[0].Last_Modified_By_People__c;
    		defaultFeedObj.appDefaultLastModifiedByName = appDefaultList[0].Last_Modified_By_People__r.Full_Name__c;
    		
    	}
    	return defaultFeedObj;
    }
	
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public ManageApplicationWrapper.GeneralSetupWrapper fetchAppGeneralSetup(){
    	
		String appConfigQuery = 'SELECT Id, App_Name__c, Login_Timeout__c,'
				+ ' Logout_Custom_Page_URL__c, Feedback_To_Emails__c, Feedback_Share_with_Simpplr__c,'
				+ ' Simpplr_Mobile_Notification_Allowed__c, Simpplr_Desktop_Notification_Allowed__c,'
				+ ' Employee_Advocacy_Enabled__c, App_Languages_Enabled__c, Calendar_Office365_URL__c,'
				+ ' Allowed_Features__c, Social_Campaign_Policy_URL__c, Calendar_Outlook_Web_Enabled__c,'
				+ ' Allow_Only_Influencers_To_Create_Blog__c, Mobile_Promotion_Enabled__c, Mobile_App_Additional_Security_Enabled__c, Question_Answer_Enabled__c,'
				+ ' Branded_App_Distribution_Enabled__c, Native_App_Enabled__c, Login_From_Generic_App_Allowed__c, '
				+ ' Calendar_App_Enabled__c, Calendar_Office365_Enabled__c, Calendar_Google_Enabled__c, Automated_Translation_Enabled__c, SMS_Enabled__c'
				+ ' FROM App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c configObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
    	return toAppGeneralSetupWrapper(configObj);
    }
    
    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    private ManageApplicationWrapper.GeneralSetupWrapper toAppGeneralSetupWrapper(App_Config__c configObj) {
		ManageApplicationWrapper.GeneralSetupWrapper wrapperObj = new ManageApplicationWrapper.GeneralSetupWrapper();
		
		wrapperObj.applicationName = configObj.App_Name__c;
        
        if (configObj.Login_Timeout__c != null) {
	        wrapperObj.loginTimeoutSeconds = String.valueOf(configObj.Login_Timeout__c);
        } else {
        	wrapperObj.loginTimeoutSeconds = 'none';
        }
        
		wrapperObj.postLogoutUrl = configObj.Logout_Custom_Page_URL__c;
		wrapperObj.mobileAppAdditionalSecurityEnabled = configObj.Mobile_App_Additional_Security_Enabled__c ? 'true' : 'false';
		wrapperObj.automatedTranslationEnabled = configObj.Automated_Translation_Enabled__c ? 'true' : 'false';
		wrapperObj.nativeAppEnabled = configObj.Native_App_Enabled__c ;
		wrapperObj.brandedAppEnabled = (wrapperObj.nativeAppEnabled  && (configObj.Login_From_Generic_App_Allowed__c == false));
		wrapperObj.mobilePromotionEnabled = (wrapperObj.nativeAppEnabled && !wrapperObj.brandedAppEnabled && configObj.Mobile_Promotion_Enabled__c) ? 'true' : 'false';
		wrapperObj.brandedAppDistributionEnabled = (wrapperObj.nativeAppEnabled && wrapperObj.brandedAppEnabled && configObj.Branded_App_Distribution_Enabled__c) ? 'true' : 'false';

        if (configObj.Feedback_To_Emails__c != null) {
        	wrapperObj.feedbackRecipients = (configObj.Feedback_To_Emails__c).split(',');
        }

        wrapperObj.shareFeedback = configObj.Feedback_Share_with_Simpplr__c;
        
        wrapperObj.enablePushNotificationDesktop = configObj.Simpplr_Desktop_Notification_Allowed__c;
        wrapperObj.enablePushNotificationMobile = configObj.Simpplr_Mobile_Notification_Allowed__c;
        
		wrapperObj.socialCampaignEnabled = configObj.Employee_Advocacy_Enabled__c ? 'true' : 'false';
		wrapperObj.socialCampaignPolicyURL = configObj.Social_Campaign_Policy_URL__c;
        
        wrapperObj.calendarAppEnabled = configObj.Calendar_App_Enabled__c;
        wrapperObj.calendarOffice365Enabled = configObj.Calendar_Office365_Enabled__c;
		wrapperObj.calendarOffice365URL = configObj.Calendar_Office365_URL__c;
        wrapperObj.calendarGoogleEnabled = configObj.Calendar_Google_Enabled__c;
		wrapperObj.calendarOutlookEnabled = configObj.Calendar_Outlook_Web_Enabled__c;
		wrapperObj.enableSMSNotifications = configObj.SMS_Enabled__c;

		wrapperObj.questionAnswerEnabled = configObj.Question_Answer_Enabled__c ? 'true' : 'false';
	        
		// adding active features with true and nonactive with false 
		String allowedFeatures = configObj.Allowed_Features__c;
		Integer counter = 0;
		String defaultAppFeatures = 'Page,Event,File,Album,Blog'; 
		wrapperObj.blogPostSetup = 'disable';
		if(String.isNotBlank(allowedFeatures)){
			List<String> allowedFeaturesList = allowedFeatures.split(',');
			allowedFeaturesList.sort();
			for(String feature : allowedFeaturesList) {
				if(feature.containsIgnoreCase('Page')){
					wrapperObj.pagesFeatureEnabled = true;
				} else if(feature.containsIgnoreCase('Event')){
					wrapperObj.eventsFeatureEnabled = true;
				} else if(feature.containsIgnoreCase('File')){
					wrapperObj.fileFeatureEnabled = true;
				} else if(feature.containsIgnoreCase('Album')){
					wrapperObj.albumsFeatureEnabled = true;
				} else if(feature.containsIgnoreCase('Blog')){
					wrapperObj.blogPostSetup = 'enable';
				}
			}
			if(configObj.Allow_Only_Influencers_To_Create_Blog__c) {
				wrapperObj.blogPostSetup = 'influencer';
			}
		}

		List<String> defaultLanguageList = new List<String>{'en_US','hy_AM','bg_BG','zh_CN','da_DA','nl_NL', 'en_GB','fr_FR','fr_CA','de_DE','el_GR','it_IT','ja_JP','ms_MY','pt_BR','ro_RO','es_ES', 'th_TH'};
		Set<String> enabledLanguageSet = new Set<String>(configObj.App_Languages_Enabled__c.split(';'));
		wrapperObj.languages = new List<ManageApplicationWrapper.CheckboxItem>();
		for(String language : defaultLanguageList) {
			ManageApplicationWrapper.CheckboxItem languageWrapper = new ManageApplicationWrapper.CheckboxItem();
			languageWrapper.label = LocaleContext.getLabel(UserContext.languageLocaleKey, 'language.' + language.toLowerCase());
			languageWrapper.name = language;
			languageWrapper.onOff = enabledLanguageSet.contains(languageWrapper.name);
			wrapperObj.languages.add(languageWrapper);
		}
		return wrapperObj;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
	public static void saveAppGeneralSetup(String appFeaturesString, ManageApplicationWrapper.GeneralSetupWrapper wrapperObj) {
		
		String appConfigQuery = 'select Id, App_Name__c, Feedback_To_Emails__c,'
				+ ' Feedback_Share_with_Simpplr__c, Mobile_App_Additional_Security_Enabled__c,'
				+ ' Simpplr_Mobile_Notification_Allowed__c, Simpplr_Desktop_Notification_Allowed__c,'
				+ ' Employee_Advocacy_Enabled__c,Feed_Placeholder__c,Calendar_Office365_URL__c,'
				+ ' Allowed_Features__c, Social_Campaign_Policy_URL__c, App_Languages_Enabled__c,'
				+ ' Calendar_App_Enabled__c, Calendar_Office365_Enabled__c, Mobile_Promotion_Enabled__c,'
				+ ' Branded_App_Distribution_Enabled__c, Logout_Custom_Page_URL__c,'
				+ ' Calendar_Google_Enabled__c, Calendar_Outlook_Web_Enabled__c, Last_Edited_DateTime__c,'
				+ ' Automated_Translation_Enabled__c, SMS_Enabled__c, Question_Answer_Enabled__c'
				+ ' from App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> configObjList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
				
		if (configObjList != null && configObjList.size() > 0) {
			App_Config__c configObj = configObjList[0];
			configObj.Last_Edited_DateTime__c = Datetime.now();
			boolean appNameChanged = (!configObj.App_Name__c.equalsIgnoreCase(wrapperObj.applicationName));
			boolean logoutUrlChanged = (!configObj.Logout_Custom_Page_URL__c.equalsIgnoreCase(wrapperObj.postLogoutURL));
			configObj.App_Name__c = wrapperObj.applicationName;	
			configObj.Mobile_Promotion_Enabled__c = Boolean.valueOf(wrapperObj.mobilePromotionEnabled);
			configObj.Branded_App_Distribution_Enabled__c = Boolean.valueOf(wrapperObj.brandedAppDistributionEnabled);
			configObj.Mobile_App_Additional_Security_Enabled__c = Boolean.valueOf(wrapperObj.mobileAppAdditionalSecurityEnabled);
			configObj.Automated_Translation_Enabled__c = Boolean.valueOf(wrapperObj.automatedTranslationEnabled);
			configObj.SMS_Enabled__c = Boolean.valueOf(wrapperObj.enableSMSNotifications);
			configObj.Question_Answer_Enabled__c = Boolean.valueOf(wrapperObj.questionAnswerEnabled);
	        if (String.isNotBlank(wrapperObj.loginTimeoutSeconds) && !'none'.equalsIgnoreCase(wrapperObj.loginTimeoutSeconds)) {
	        	configObj.Login_Timeout__c = Integer.valueOf(wrapperObj.loginTimeoutSeconds);
	        
			} else {
	        	configObj.Login_Timeout__c = null;
	        }
	        configObj.Logout_Custom_Page_URL__c = wrapperObj.postLogoutURL;
	        
	        if(wrapperObj.feedbackRecipients != null && wrapperObj.feedbackRecipients.size() > 0) {
			Set<String> feedbackRecipientsSet = new Set<string>();
			List<String> feedbackRecipientsList = new List<String>();
			feedbackRecipientsSet.addAll(wrapperObj.feedbackRecipients);
			feedbackRecipientsList.addAll(feedbackRecipientsSet);
			configObj.Feedback_To_Emails__c = Utility.convertToCommaSeparatedString(feedbackRecipientsList);
            } else {
	        	configObj.Feedback_To_Emails__c = '';
	        }
	        configObj.Feedback_Share_with_Simpplr__c = wrapperObj.shareFeedback;
	        
            configObj.Simpplr_Mobile_Notification_Allowed__c = wrapperObj.enablePushNotificationMobile;
	        
	        if('true'.equalsIgnoreCase(wrapperObj.socialCampaignEnabled)) {
	        	configObj.Social_Campaign_Policy_URL__c = wrapperObj.socialCampaignPolicyURL;
	        }
	        
	        configObj.Calendar_App_Enabled__c = wrapperObj.calendarAppEnabled; 
         	configObj.Calendar_Office365_Enabled__c = wrapperObj.calendarOffice365Enabled;
			configObj.Calendar_Office365_URL__c = wrapperObj.calendarOffice365URL;
        	configObj.Calendar_Google_Enabled__c = wrapperObj.calendarGoogleEnabled;
         	configObj.Calendar_Outlook_Web_Enabled__c = wrapperObj.calendarOutlookEnabled;
			configObj.App_Languages_Enabled__c = '';
			String seperator = '';
			for(ManageApplicationWrapper.CheckboxItem languageWrapper : wrapperObj.languages) {
				if(languageWrapper.onOff) {
					configObj.App_Languages_Enabled__c += seperator + languageWrapper.name;
					if(String.isBlank(seperator)) {
						configObj.App_Default_Language__c = languageWrapper.name;
						seperator = ';';
					}
				}
			}
			if(configObj.app_Languages_Enabled__c.split(';').size() > 1) {
				configObj.Feed_Placeholder__c = null;
			}
	        
	        configObj.Allowed_Features__c = appFeaturesString;
	        configObj.Allow_Only_Influencers_To_Create_Blog__c = 'influencer'.equalsIgnoreCase(wrapperObj.blogPostSetup);
			if (logoutUrlChanged == true) {
				savePostLogoutURL(wrapperObj.postLogoutURL);
			}
	        
	        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	   		SIMPESAPI.accessController().updateAsUser(configObj,new List<Schema.SObjectField>{
					App_Config__c.App_Name__c, 
					App_Config__c.Login_Timeout__c,
					App_Config__c.Logout_Custom_Page_URL__c,
					App_Config__c.Feedback_To_Emails__c, 
					App_Config__c.Feedback_Share_with_Simpplr__c, 
					App_Config__c.Simpplr_Mobile_Notification_Allowed__c,
					App_Config__c.Social_Campaign_Policy_URL__c,
					App_Config__c.Allowed_Features__c,
					App_Config__c.Calendar_App_Enabled__c,
					App_Config__c.Calendar_Office365_Enabled__c,
					App_Config__c.Calendar_Office365_URL__c,
					App_Config__c.Calendar_Google_Enabled__c,
					App_Config__c.Allow_Only_Influencers_To_Create_Blog__c,
					App_Config__c.App_Languages_Enabled__c,
					App_Config__c.Feed_Placeholder__c,
					App_Config__c.App_Default_Language__c,
					App_Config__c.Calendar_Outlook_Web_Enabled__c,
					App_Config__c.Mobile_Promotion_Enabled__c,
					App_Config__c.Automated_Translation_Enabled__c,
					App_Config__c.Mobile_App_Additional_Security_Enabled__c,
					App_Config__c.Last_Edited_DateTime__c,
					App_Config__c.SMS_Enabled__c,
					App_Config__c.Branded_App_Distribution_Enabled__c,
					App_Config__c.Question_Answer_Enabled__c});

	    	if (appNameChanged) {

	    		// check if we are connected to gdrive / dropbox
	    		if (SimpplrContext.isGdriveConnected || SimpplrContext.isDropboxConnected) {
	    			Database.executeBatch(new BatchEFSFolderSync('APPNAME', configObj.App_Name__c,SimpplrContext.isGdriveConnected ? ServiceConstants.STORAGE_TYPE_GDRIVE_STRING : ServiceConstants.STORAGE_TYPE_DROPBOX_STRING), 1);
	    		}
	    	}
		} 

		if  (!configObjList.isEmpty() && 
				(configObjList[0].Mobile_Promotion_Enabled__c == null || 
				configObjList[0].Mobile_Promotion_Enabled__c == false) && 
				Boolean.valueOf(wrapperObj.mobilePromotionEnabled)) {
			Audit_Trail__c auditTrailObj = new Audit_Trail__c();
			auditTrailObj.Created_By__c = UserContext.peopleId;
			auditTrailObj.Object_Name__c = 'App_Config__c';
			auditTrailObj.Column_Name__c = 'Mobile_Promotion_Enabled__c';
			insert auditTrailObj;
		}
		if  (!configObjList.isEmpty() && 
				(configObjList[0].Branded_App_Distribution_Enabled__c == null || 
				configObjList[0].Branded_App_Distribution_Enabled__c == false) && 
				Boolean.valueOf(wrapperObj.brandedAppDistributionEnabled)) {
			Audit_Trail__c auditTrailObj = new Audit_Trail__c();
			auditTrailObj.Created_By__c = UserContext.peopleId;
			auditTrailObj.Object_Name__c = 'App_Config__c';
			auditTrailObj.Column_Name__c = 'Branded_App_Distribution_Enabled__c';
			insert auditTrailObj;
		} 
	}

	public static void savePostLogoutURL(String logoutURL){
		try{
			logger.logDebug('ManageApplicationDao.savePostLogoutURL()---logoutURL' + logoutURL);
			String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/salesforce/setup-manager';
			Map<String, Object> mapOfRequestParam = new Map<String, Object>();
			mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
			mapOfRequestParam.put('peopleId', UserContext.peopleId);
			mapOfRequestParam.put('userId', UserContext.userId);
			mapOfRequestParam.put('logoutUrl', logoutURL);
			Utility.getResponseFromAWS(endpointURL, mapOfRequestParam);

		} catch(Exception ex){
			logger.logDebug('Exception while saving post logout URL' + ex);
			throw ex;
		}
	}

    public static void disconnectEFSAdmin(String efsType) {
		removeEFSFields(true, efsType);
		BatchEFSPeoplePreferenceUpdate batchObj = new BatchEFSPeoplePreferenceUpdate('ADMINDEL');
		Database.executeBatch(batchObj, 5000);
    }
    
    public static void removeEFSFields(Boolean adminFlag, String efsType) {
    	if(adminFlag) {
			if(SimpplrContext.integrations.get(efsType) != null) {
				App_Integration__c appIntegObj = new App_Integration__c(Id = SimpplrContext.integrations.get(efsType).id);
				appIntegObj.Is_Deleted__c = true;
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(appIntegObj, new List<Schema.SObjectField>{App_Integration__c.Is_Deleted__c});
			}
    	} else {
			// This is required because peeople integ record is getting deleted 
			//in PepleDataServer.disconnectApp before this method is invoked via  BatchEfsFolderSync
			if(UserContext.integrations.get(efsType) != null){
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().deleteAsUser(new People_Integration__c(Id = UserContext.integrations.get(efsType).Id));
			}
		}
    }
   
    public static void disconnectEFSUser(String efsType, String gdUserEmailArg){
		removeEFSFields(false, efsType);
	}
   
   
  /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public void saveEmailNotificationsSettings(String requestData) {
        String query = 'SELECT id, Data__c, Sync_Status__c, OverwriteBatchInProgress__c FROM App_Default__c WHERE type__c = \'email_notifications\'';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);

		if (!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)) {
            
            if (listOfAppDefault[0].OverwriteBatchInProgress__c) {
				throw new SimpplrException(SETTINGS_UPDATED);	
            }
            
			listOfAppDefault[0].Data__c = requestData;
			listOfAppDefault[0].Sync_Status__c = null ;
        	listOfAppDefault[0].Last_Modified_By_People__c = UserContext.peopleId;
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(listOfAppDefault[0], 
                    new List<Schema.SObjectField>{
            	    App_Default__c.Data__c,
					App_Default__c.Last_Modified_By_People__c,
                    App_Default__c.Sync_Status__c});     
                       
      	} else {
        	App_Default__c appDefault = new App_Default__c(Type__c = 'email_notifications', 
                    Data__c = requestData, Last_Modified_By_People__c = UserContext.peopleId);

        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(appDefault, 
                    new List<Schema.SObjectField>{
            	    App_Default__c.Data__c,
                	App_Default__c.Type__c,
                	App_Default__c.Last_Modified_By_People__c});        
        
      	}
          
    }

    public void saveSummariesAndDigestSettings(String requestData) {
        String query = 'SELECT id, Data__c, Sync_Status__c, OverwriteBatchInProgress__c FROM App_Default__c WHERE type__c = \'summaries_and_digest\'';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);

		if (!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)) {
            
            if (listOfAppDefault[0].OverwriteBatchInProgress__c) {
				throw new SimpplrException(SETTINGS_UPDATED);	
            }
            
			listOfAppDefault[0].Data__c = requestData;
			listOfAppDefault[0].Sync_Status__c = null ;
        	listOfAppDefault[0].Last_Modified_By_People__c = UserContext.peopleId;
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(listOfAppDefault[0], 
                    new List<Schema.SObjectField>{
            	    App_Default__c.Data__c,
					App_Default__c.Last_Modified_By_People__c,
                    App_Default__c.Sync_Status__c});     
                       
      	} else {
        	App_Default__c appDefault = new App_Default__c(Type__c = 'summaries_and_digest', 
                    Data__c = requestData, Last_Modified_By_People__c = UserContext.peopleId);

        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(appDefault, 
                    new List<Schema.SObjectField>{
            	    App_Default__c.Data__c,
                	App_Default__c.Type__c,
                	App_Default__c.Last_Modified_By_People__c});        
        
      	}
      	
	}
	
	public void saveBrowserNotificationsSettings(String requestData) {
        String query = 'SELECT id, Data__c, Sync_Status__c, OverwriteBatchInProgress__c FROM App_Default__c WHERE type__c = \'browser_notifications\'';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_Default__c> listOfAppDefault = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
		if(!listOfAppDefault.isEmpty() && String.isNotBlank(listOfAppDefault[0].Data__c)){
			if(listOfAppDefault[0].OverwriteBatchInProgress__c){
				throw new SimpplrException(SETTINGS_UPDATED);	
			}
			listOfAppDefault[0].Data__c = requestData;
			listOfAppDefault[0].Sync_Status__c=null ;
        	listOfAppDefault[0].Last_Modified_By_People__c = UserContext.peopleId;
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        	SIMPESAPI.accessController().updateAsUser(listOfAppDefault[0], new List<Schema.SObjectField>{
            	                       App_Default__c.Data__c,
									   App_Default__c.Last_Modified_By_People__c,
									   App_Default__c.Sync_Status__c});        
      	}
      	else{
        	App_Default__c appDefault = new App_Default__c(Type__c = 'browser_notifications', 
        												   Data__c = requestData, 
        												   Last_Modified_By_People__c = UserContext.peopleId);

        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        	SIMPESAPI.accessController().insertAsUser(appDefault, new List<Schema.SObjectField>{
            	                       App_Default__c.Data__c,
                	                   App_Default__c.Type__c,
                	                   App_Default__c.Last_Modified_By_People__c});        
        
      	}
      	
    }

    public void saveDefaultFeedSettings(String requestData) {
        String query = 'select id,Sync_Status__c, Data__c,OverwriteBatchInProgress__c, Last_Modified_By_People__c from App_Default__c where Type__c =\'home-feed\'';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
    	
    	if(!appDefaultList.isEmpty() && String.isNotBlank(appDefaultList[0].Data__c)){
    		if(appDefaultList[0].OverwriteBatchInProgress__c){
				throw new SimpplrException(SETTINGS_UPDATED);	
			}
			appDefaultList[0].Data__c = requestData;
			appDefaultList[0].Sync_Status__c = null;
    		appDefaultList[0].Last_Modified_By_People__c = UserContext.peopleId;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        	SIMPESAPI.accessController().updateAsUser(appDefaultList[0], new List<Schema.SObjectField>{
            	                       App_Default__c.Data__c,
									   App_Default__c.Last_Modified_By_People__c,
									   App_Default__c.Sync_Status__c});
    		
    	} else{
    		App_Default__c defaultObj = new App_Default__c();
			defaultObj.Data__c = requestData;
   			defaultObj.Type__c = 'home-feed';
   			defaultObj.Last_Modified_By_People__c = UserContext.peopleId;
   			insert defaultObj;
    	}
    	
    	ManageApplicationWrapper.DefaultFeedSettingsWrapper defaultFeedWrapper =  (ManageApplicationWrapper.DefaultFeedSettingsWrapper) JSON.deserialize(requestData, ManageApplicationWrapper.DefaultFeedSettingsWrapper.class);
    	
    	if('1'.equalsIgnoreCase(defaultFeedWrapper.isApplyToAllUsers)){
      		applyFeedDefaultToAllUsers();		
      	}
    }

	public ManageApplicationWrapper.GeneralPeopleWrapper getGeneralPeopleConfig() {

		ManageApplicationWrapper.GeneralPeopleWrapper genPeopleObj = new ManageApplicationWrapper.GeneralPeopleWrapper();
    	String appConfigQuery = 'select id,People_Category_Enabled__c, People_Catgeory_Singular__c, People_Catgeory_Plural__c,'
									+ ' PP_Departments_Count__c, PP_Employees_Count__c, PP_Locations_Count__c'
									+ ' From App_Config__c Limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
		if(!listOfAppConfig.isEmpty()) {
    		genPeopleObj.peopleCategoryEnabled = listOfAppConfig[0].People_Category_Enabled__c;
    		genPeopleObj.peopleCategorySingular = listOfAppConfig[0].People_Catgeory_Singular__c;
			genPeopleObj.peopleCategoryPlural = listOfAppConfig[0].People_Catgeory_Plural__c;
			
			genPeopleObj.peopleCategoryUsedForAudience = isPeopleCategoryUsedForAudience();
		} 
		
		return genPeopleObj;
	}

	public ManageApplicationWrapper.PeopleIntegrationsWrapper getPeopleIntegrationsConfig() {

	    ManageApplicationWrapper.PeopleIntegrationsWrapper peopleIntegrationObj= new ManageApplicationWrapper.PeopleIntegrationsWrapper();
		String appConfigQuery = 'SELECT PDS_Workday_Enabled__c, PDS_Workday_Endpoint__c, PDS_Workday_Password__c,'
									+ ' PDS_Workday_Username__c, AD_Integration_Enabled__c ,'
									+ ' PDS_UKG_Pro_Enabled__c, PDS_UKG_Pro_Username__c,PDS_UKG_Pro_Password__c,'
									+ ' PDS_UKG_Pro_Endpoint__c, PDS_UKG_Pro_API_Key__c '
									+ ' FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfApplicationIntegrations = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
															
		peopleIntegrationObj.workday = listOfApplicationIntegrations[0].PDS_Workday_Enabled__c && String.isNotBlank(listOfApplicationIntegrations[0].PDS_Workday_Username__c) && String.isNotBlank(listOfApplicationIntegrations[0].PDS_Workday_Endpoint__c);
		peopleIntegrationObj.workdayUsername = listOfApplicationIntegrations[0].PDS_Workday_Username__c;
		peopleIntegrationObj.workdayEndpointUrl = listOfApplicationIntegrations[0].PDS_Workday_Endpoint__c;
		if(String.isNotBlank(listOfApplicationIntegrations[0].PDS_Workday_Password__c)){
			peopleIntegrationObj.workdayPasswordSaved = true; 
		}else {
			peopleIntegrationObj.workdayPasswordSaved = false; 
		}
        
		peopleIntegrationObj.ukgPro = listOfApplicationIntegrations[0].PDS_UKG_Pro_Enabled__c && String.isNotBlank(listOfApplicationIntegrations[0].PDS_UKG_Pro_Username__c) && String.isNotBlank(listOfApplicationIntegrations[0].PDS_UKG_Pro_Endpoint__c);
		peopleIntegrationObj.ukgProUsername = listOfApplicationIntegrations[0].PDS_UKG_Pro_Username__c;
		peopleIntegrationObj.ukgProBaseUrl = listOfApplicationIntegrations[0].PDS_UKG_Pro_Endpoint__c;
		if(String.isNotBlank(listOfApplicationIntegrations[0].PDS_UKG_Pro_Password__c)){
			peopleIntegrationObj.ukgProPasswordSaved = true; 
		}else {
			peopleIntegrationObj.ukgProPasswordSaved = false; 
		}
		if(String.isNotBlank(listOfApplicationIntegrations[0].PDS_UKG_Pro_API_Key__c)){
			peopleIntegrationObj.ukgProApiKeySaved = true; 
		}else {
			peopleIntegrationObj.ukgProApiKeySaved = false; 
		}
		SimpplrContext.voidIntegrationsMap();
		List<App_Integration__c> appIntegration = SimpplrContext.Integrations.values();

		peopleIntegrationObj.adIntegrationEnabled = false;
		peopleIntegrationObj.activeDirectoryIntegrationEnabled = false;
		if(listOfApplicationIntegrations[0].AD_Integration_Enabled__c) {
			if(SimpplrContext.isAdsiIntegrationEnabled) {
				peopleIntegrationObj.adIntegrationEnabled = true;
			} else {
				peopleIntegrationObj.activeDirectoryIntegrationEnabled = true;
			}
		}
		
		peopleIntegrationObj.googleIntegrationEnabled = false;

		for(App_Integration__c obj : appIntegration){
			if(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY.equalsIgnoreCase(obj.Name) && SimpplrContext.isActiveDirectoryEnabled) {
				String userPrincipalName = obj.User_Principal_Name__c != null ? ' - ' + obj.User_Principal_Name__c : '';
				peopleIntegrationObj.activeDirectoryConnectedAs = obj.User_Name__c + userPrincipalName;
				peopleIntegrationObj.adRedirectURL = (new IntegrationService('activedirectory', null)).getAuthPage(true);
			} else if(IntegrationConstants.INTEGRATION_TYPE_ADSI.equalsIgnoreCase(obj.Name) && SimpplrContext.isAdsiIntegrationEnabled) {
				peopleIntegrationObj.adConnectedAs = obj.User_Name__c;
				peopleIntegrationObj.adRedirectURL = (new IntegrationService('adsi', null)).getAuthPage();
			} else if(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_USER_SYNC.equalsIgnoreCase(obj.Name)) {
				peopleIntegrationObj.googleConnectedAs = obj.User_Email__c;
				peopleIntegrationObj.googleIntegrationEnabled = obj.Integration_Enabled__c;
				if (obj.Refresh_Token_Expiration_Datetime__c != null) {
					Integer noOfDays = obj.Refresh_Token_Expiration_Datetime__c.date().daysBetween(Date.today());
					peopleIntegrationObj.isGooglePeopleDataAccountReconnectRequired = (noOfDays >=0 && noOfDays <= 15) ? true : false;
				} else {
					peopleIntegrationObj.isGooglePeopleDataAccountReconnectRequired = false;
				}
			}
        }

		peopleIntegrationObj.isActiveDirectoryGroupsEnabled = SimpplrContext.isActiveDirectoryEnabled && SimpplrContext.isActiveDirectoryGroupsEnabled;
		peopleIntegrationObj.autoCreateActiveDirectoryAudience = peopleIntegrationObj.isActiveDirectoryGroupsEnabled &&
			SimpplrContext.autoCreateActiveDirectoryAudience;

		if(peopleIntegrationObj.isActiveDirectoryGroupsEnabled) {			
			ManageApplicationWrapper.ActiveDirectorySyncInfoWrapper adSyncInfoWrapperObj = getActiveDirectorySyncInfo();
			peopleIntegrationObj.activeDirectorySyncInfo = adSyncInfoWrapperObj;
		}

		if(SimpplrContext.isActiveDirectoryEnabled) {
			String query = 'SELECT COUNT(Id) adCount FROM Active_Directory_Group__c WHERE Is_Deleted__c = false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<AggregateResult> aggrList  = (List<AggregateResult>)SIMPESAPI.accessController().queryAsUser(query, null);
			peopleIntegrationObj.selectedActiveDirectoryGroupCount = (Integer)aggrList[0].get('adCount');
		}

    	return peopleIntegrationObj;
    }

	private static ManageApplicationWrapper.ActiveDirectorySyncInfoWrapper getActiveDirectorySyncInfo() {

		ManageApplicationWrapper.ActiveDirectorySyncInfoWrapper adSyncInfoWrapperObj = new ManageApplicationWrapper.ActiveDirectorySyncInfoWrapper();
		// get scheduler next run info
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', 'SchedulerSimpplrServices'); 			
		String query = 'SELECT Id, nextfiretime FROM CronTrigger WHERE cronjobdetail.name =: soqlParam1 order by createdDate desc LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<CronTrigger> jobDetalilsList = (List<CronTrigger>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		if(!jobDetalilsList.isEmpty()) {
			adSyncInfoWrapperObj.nextRunAt = jobDetalilsList[0].nextfiretime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		}			
		String sourceInfo = 'Group Sync activedirectory';	
		soqlParamMap = new  Map<String, Object>();	
		soqlParamMap.put('soqlParam1', sourceInfo); 
		query = 'SELECT Id, CreatedDate, Log_Data__c FROM Logs__c ' +  
			'WHERE Log_Type__c = \'INFO\' AND ' + 
			'Is_Deleted__c = false AND Source_Info__c = :soqlParam1 ' + 
			'ORDER BY createddate desc limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Logs__c> logsList  = (List<Logs__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);

		if(logsList != null && !logsList.isEmpty()){
			adSyncInfoWrapperObj.lastRunAt = logsList[0].CreatedDate == null ? null : logsList[0].CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			adSyncInfoWrapperObj.isSuccessful = logsList[0].Log_Data__c == 'successful' ? true : false;
		}	
		adSyncInfoWrapperObj.isInProgress = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_ACTIVE_DIRECTORY).Batch_Processing__c;
		
		return adSyncInfoWrapperObj;
	}
    
	public ManageApplicationWrapper.SingleSignOnIntegrationsWrapper getSsoIntegrationsConfig() {

	    ManageApplicationWrapper.SingleSignOnIntegrationsWrapper singlesignOnIntegrationObj= new ManageApplicationWrapper.SingleSignOnIntegrationsWrapper();
    	String appConfigQuery = 'SELECT Okta_Enabled__c, Okta_Link__c, Okta_API_Token__c, Okta_People_Name_Format__c, OneLogin_Enabled__c,'
									+ ' OneLogin_API_Token__c, OneLogin_Embedding_Token__c, OneLogin_Link__c FROM App_Config__c limit 1';
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfApplicationIntegrations = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
		App_Config__c appConfObj = listOfApplicationIntegrations[0];

		singlesignOnIntegrationObj.okta = appConfObj.Okta_Enabled__c && String.isNotBlank(appConfObj.Okta_Link__c) && String.isNotBlank(appConfObj.Okta_API_Token__c) && String.isNotBlank(appConfObj.Okta_People_Name_Format__c);
		singlesignOnIntegrationObj.oktaLink = appConfObj.Okta_Link__c;	
		singlesignOnIntegrationObj.oktaUserNameFormat = appConfObj.Okta_People_Name_Format__c;
		if(String.isNotBlank(appConfObj.Okta_API_Token__c)){
			singlesignOnIntegrationObj.oktaApiTokenSaved = true; 
		} else {
			singlesignOnIntegrationObj.oktaApiTokenSaved = false; 
		}
		
		singlesignOnIntegrationObj.onelogin = appConfObj.OneLogin_Enabled__c && String.isNotBlank(appConfObj.OneLogin_API_Token__c) && String.isNotBlank(appConfObj.OneLogin_Embedding_Token__c) && String.isNotBlank(appConfObj.OneLogin_Link__c);	
		singlesignOnIntegrationObj.oneLoginEmbeddingCode = appConfObj.OneLogin_Embedding_Token__c;	
		singlesignOnIntegrationObj.oneLoginEmbeddingUrl = appConfObj.OneLogin_Link__c;
		if(String.isNotBlank(appConfObj.OneLogin_API_Token__c)){
			singlesignOnIntegrationObj.oneLoginApiKeySaved = true; 
		} else {
			singlesignOnIntegrationObj.oneLoginApiKeySaved = false; 
		}
		
    	return singlesignOnIntegrationObj;
	}
	
	public ManageApplicationWrapper.CalendarIntegrationsWrapper getCalendarIntegrationsConfig() {
		ManageApplicationWrapper.CalendarIntegrationsWrapper calendarIntegrationObj= new ManageApplicationWrapper.CalendarIntegrationsWrapper();
		
		calendarIntegrationObj.googleCalendar = false;
		calendarIntegrationObj.outlookCalendar = false;
		if (GoogleDriveService.googleMultiDomainUpgraded()) {
			GoogleDriveService googleServiceObj = new GoogleDriveService();
			calendarIntegrationObj.googleCalendarDomainExists = googleServiceObj.getGoogleDomainExists(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR);
		}
		calendarIntegrationObj.googleMultiDomainUpgradeStatus = SimpplrContext.googleMultiDomainUpgradeStatus != 
		ServiceConstants.UPGRADE_STATUS_IN_PROGRESS ? SimpplrContext.googleMultiDomainUpgradeStatus : GoogleDriveService.validateGoogleMultiDomainStatus();

		String appIntQuery = 'SELECT Id, Name,'
                + ' Scope__c, Scope_Required__c, User_Name__c, User_Email__c,'  
                + ' Extra_Url_Parameters__c, Client_Secret__c, Client_Id__c,'
                + ' DB_User_Client_Id__c, DB_User_Client_Secret__c,'
                + ' App_Access_Token__c, App_Refresh_Token__c,'
                + ' Token_Type__c, Redirect_Uri__c, App_Installed__c,'
                + ' Access_Token_Requested_Datetime__c, Refresh_Token_Requested_Datetime__c,'
                + ' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,'
                + ' Access_Token_Expiry__c,  External_Id__c, Integration_Enabled__c, Connected__c,'
                + ' Is_Deleted__c ,All_Company_Group_Id__c, Batch_Processing__c,'
                + ' Root_Folder_Id__c, Enterprise_Id__c, Endpoint_Url__c, Data__c,'
                + ' Is_My_Drive_Enabled__c, Simpplr_Managed_Permission__c, Whitelist_Domain__c'
                + ' FROM App_Integration__c'
                + ' WHERE Is_Deleted__c = false AND ( Name = :soqlParam2 OR Name = :soqlParam3 )'
                + ' AND Org_Id__c = :soqlParam1';
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', SimpplrContext.simpplrOrgId);
		sqlParamMap.put('soqlParam2', IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR);
		sqlParamMap.put('soqlParam3', IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegrationList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
		
		for(App_Integration__c integration : appIntegrationList) {
			if(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(integration.Name)) {
				calendarIntegrationObj.googleCalendar = integration.Integration_Enabled__c;
				calendarIntegrationObj.googleCalendarConnectedAs = integration.User_Email__c;
				if (integration.Refresh_Token_Expiration_Datetime__c != null) {
					Integer noOfDays = integration.Refresh_Token_Expiration_Datetime__c.date().daysBetween(Date.today());
					calendarIntegrationObj.isGoogleCalendarAccountReconnectRequired = (noOfDays >=0 && noOfDays <= 15) ? true : false;
				} else {
					calendarIntegrationObj.isGoogleCalendarAccountReconnectRequired = false;
				}
			} else if(IntegrationConstants.INTEGRATION_TYPE_OUTLOOK_CALENDAR.equalsIgnoreCase(integration.Name)) {
				calendarIntegrationObj.outlookCalendar = integration.Integration_Enabled__c;
				if (integration.Whitelist_Domain__c != null) {
					calendarIntegrationObj.outlookCalendarDomainWhitelist = (integration.Whitelist_Domain__c).split(',');
				}
			}

		}
                
		return calendarIntegrationObj;
    }

	public Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration> getSearchIntegrationsConfig() {

	    Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration> searchIntegrationMap = new Map<String, ManageApplicationWrapper.EnterpriseSearchIntegration>();
		String appIntQueryString = 'SELECT Id, Name, Integration_Enabled__c, Connected__c, Is_Deleted__c, Endpoint_Url__c, Data__c'
									+ ' FROM App_Integration__c'
									+ ' WHERE Name = :soqlParam1'
									+ ' AND Org_Id__c = :soqlParam2 ';

		List<String> enterpriseSearchIntegrationNameList = IntegrationConstants.ENTERPRISE_SEARCH_INTEGRATION_NAME_LIST;

		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', enterpriseSearchIntegrationNameList);
		sqlParamMap.put('soqlParam2', SimpplrContext.simpplrOrgId);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Integration__c> appIntegrationList = (List<App_Integration__c>) SIMPESAPI.accessController().queryAsUser(appIntQueryString, sqlParamMap);

		Map<String, App_Integration__c> nameVsAppIntgObjMap = new Map<String, App_Integration__c>();
		for(App_Integration__c appIntObj : appIntegrationList){
			nameVsAppIntgObjMap.put(appIntObj.Name, appIntObj);
		}
		
		for(String searchIntgName : enterpriseSearchIntegrationNameList){
			ManageApplicationWrapper.EnterpriseSearchIntegration wrapperObj = new ManageApplicationWrapper.EnterpriseSearchIntegration();
			wrapperObj.isEnabled = false;
			wrapperObj.url = '';
			wrapperObj.provider = '';

			if(nameVsAppIntgObjMap.size() > 0 && nameVsAppIntgObjMap.containsKey(searchIntgName)){
				App_Integration__c appIntgObj = nameVsAppIntgObjMap.get(searchIntgName);

				wrapperObj.isEnabled = appIntgObj.Integration_Enabled__c;
				wrapperObj.url = appIntgObj.Endpoint_Url__c;
				wrapperObj.provider = appIntgObj.Data__c;

			}

			searchIntegrationMap.put(searchIntgName, wrapperObj);
		}

    	return searchIntegrationMap;
    }
	
	private Boolean isPeopleCategoryUsedForAudience() {
		List<Audience__c> audienceList = [SELECT id from Audience__c where Has_People_Category_Condition__c = true AND Is_Deleted__c = false WITH SECURITY_ENFORCED LIMIT 1];
		if(!audienceList.isEmpty()) {
			return true;
		} else {
			return false;
		}
	}
    
    private void applyFeedDefaultToAllUsers(){
    	try{
            String query = 'Select id From App_Default__c where Type__c=\'home-feed\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> appDefaultList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
   			if(!appDefaultList.isEmpty()){
   				appDefaultList[0].OverwriteBatchInProgress__c = true;
	        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        	SIMPESAPI.accessController().updateAsUser(appDefaultList[0], new List<Schema.SObjectField>{
	                       				   App_Default__c.OverwriteBatchInProgress__c}); 
   			}
   			BatchOverwriteAppDefaults applyDefaultFeed = new BatchOverwriteAppDefaults('Default Feed', false, null);
			Database.executeBatch(applyDefaultFeed,100);			
   		}catch(Exception e) {            
    		logger.logError(e.getStackTraceString());
   		}
    }

   	public void applyEmailDefaultToAllUsers() {

   		try {
            String query = 'select id from App_Default__c where Type__c = \'email_notifications\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> appDefaultEmailList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
               
            if (!appDefaultEmailList.isEmpty()) {
                appDefaultEmailList[0].OverwriteBatchInProgress__c = true;
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(appDefaultEmailList[0], 
                        new List<Schema.SObjectField>{
                        App_Default__c.OverwriteBatchInProgress__c}); 
            }

   			BatchOverwriteAppDefaults applyEmailDefault = new BatchOverwriteAppDefaults('email_notifications', false, null);
            Database.executeBatch(applyEmailDefault, 100);
            			
   		} catch (Exception e) {            
    		logger.logError(e.getStackTraceString());
        }
           
	}
	   
	public void applySMSDefaultToAllUsers(){
    	try{
            String query = 'select id from App_Default__c where Type__c = \'sms_notifications\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> appDefaultSMSList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
   			if(!appDefaultSMSList.isEmpty()){
				appDefaultSMSList[0].OverwriteBatchInProgress__c = true;
	        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        	SIMPESAPI.accessController().updateAsUser(appDefaultSMSList[0], new List<Schema.SObjectField>{
	                       				   App_Default__c.OverwriteBatchInProgress__c}); 
   			}
   			BatchOverwriteAppDefaults applyDefaultFeed = new BatchOverwriteAppDefaults('sms_notifications', false, null);
			Database.executeBatch(applyDefaultFeed,100);			
   		}catch(Exception e) {            
    		logger.logError(e.getStackTraceString());
   		}
	}
	
	public void applyNativeMobileDefaultToAllUsers(){
    	try{
	   		String query = 'select id from App_Default__c where Type__c = \'native_mobile_notifications\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> appDefaultNativeMobileList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
   			if(!appDefaultNativeMobileList.isEmpty()){
				appDefaultNativeMobileList[0].OverwriteBatchInProgress__c = true;
	        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        	SIMPESAPI.accessController().updateAsUser(appDefaultNativeMobileList[0], new List<Schema.SObjectField>{
	                       				   App_Default__c.OverwriteBatchInProgress__c}); 
   			}
   			BatchOverwriteAppDefaults applyDefaultFeed = new BatchOverwriteAppDefaults('Native Mobile Notifications', false, null);
			Database.executeBatch(applyDefaultFeed,100);			
   		}catch(Exception e) {            
    		logger.logError(e.getStackTraceString());
   		}
	}
	
	public void applyBrowserDefaultToAllUsers(){
    	try{
	   		String query = 'select id from App_Default__c where Type__c = \'browser_notifications\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> appDefaultBrowserList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
   			if(!appDefaultBrowserList.isEmpty()){
				appDefaultBrowserList[0].OverwriteBatchInProgress__c = true;
	        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	        	SIMPESAPI.accessController().updateAsUser(appDefaultBrowserList[0], new List<Schema.SObjectField>{
	                       				   App_Default__c.OverwriteBatchInProgress__c}); 
   			}
   			BatchOverwriteAppDefaults applyDefaultFeed = new BatchOverwriteAppDefaults('browser_notifications', false, null);
			Database.executeBatch(applyDefaultFeed,100);			
   		}catch(Exception e) {            
    		logger.logError(e.getStackTraceString());
   		}
	}
	
	public void applySummariesAndDigestDefaultToAllUsers() {
		try {
            String query = 'select id from App_Default__c where Type__c = \'summaries_and_digest\'';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_Default__c> appDefaultSummariesList = (List<App_Default__c>)SIMPESAPI.accessController().queryAsUser(query, null);
			
		 	if (!appDefaultSummariesList.isEmpty()) {
				appDefaultSummariesList[0].OverwriteBatchInProgress__c = true;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(appDefaultSummariesList[0], 
									new List<Schema.SObjectField>{
									App_Default__c.OverwriteBatchInProgress__c}); 
			}

			BatchOverwriteAppDefaults applySummariesDefault = new BatchOverwriteAppDefaults('summaries_and_digest', false, null);
			Database.executeBatch(applySummariesDefault, 100);		

		} catch (Exception e) {            
			logger.logError(e.getStackTraceString());
		}
	}

	public static void resetSiteConfigStorage(Id usrId, String oldStorage, String newStorage, String siteId) {
        Map<Id, Simpplr_Site__c> siteMap = new Map<Id, Simpplr_Site__c>();
        
		// change loaction to intranet for sites that current user manages
		if(usrId != null) {
			Set<Id> grpIds = new Set<Id>();
	        for(CollaborationGroup cg : [Select Id from CollaborationGroup where OwnerId =:UserContext.Id WITH SECURITY_ENFORCED]){
	        	grpIds.add(cg.Id);
	        }
		        
	        for(Simpplr_Site__c siteObj : [SELECT Id, File_Storage_Source__c FROM Simpplr_Site__c WHERE
	        		Chatter_Group_Id__c IN:grpIds AND File_Storage_Source__c=:oldStorage AND Is_Deleted__c = false WITH SECURITY_ENFORCED]){
	       		siteMap.put(siteObj.Id, new Simpplr_Site__c(Id=siteObj.Id, File_Storage_Source__c=newStorage));
	        }
		} else if(String.isNotBlank(siteId)){
			for(Simpplr_Site__c siteObj : [SELECT Id, File_Storage_Source__c FROM Simpplr_Site__c WHERE 
					Id =:siteId AND File_Storage_Source__c=:oldStorage AND Is_Deleted__c = false WITH SECURITY_ENFORCED]){
	       		siteMap.put(siteObj.Id, new Simpplr_Site__c(Id=siteObj.Id, File_Storage_Source__c=newStorage));
	        }
		} else {
	        for(Simpplr_Site__c siteObj : [SELECT Id, File_Storage_Source__c FROM Simpplr_Site__c WHERE 
	        		File_Storage_Source__c=:oldStorage AND Is_Deleted__c = false WITH SECURITY_ENFORCED]){
	       		siteMap.put(siteObj.Id, new Simpplr_Site__c(Id=siteObj.Id, File_Storage_Source__c=newStorage));
	        }
		}

        if(siteMap.size()>0){
        	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        	SIMPESAPI.accessController().updateAsUser(siteMap, new List<Schema.SObjectField>{Simpplr_Site__c.File_Storage_Source__c});

			// Once the storage is updated, call the SITEDEL to remove the sites EFS records
			if((usrId == null && SimpplrContext.integrations.get(oldStorage).Connected__c) ||
			    (usrId != null && SimpplrContext.connectedStorages.contains(oldStorage) && UserContext.connectedStorages.contains(oldStorage))) {
	        	for(Simpplr_Site__c site : siteMap.values()) {
	        		Database.executeBatch(new BatchEFSFolderSync('SITEDEL', '["' + site.Id + '"]', oldStorage), 1);
	        	} 				
			}
        }
	}

	public static void setEFSBatchProcessingFlag(boolean newValue, String efsType) {
		List<App_Integration__c> appIntegList = new List<App_Integration__c>();
		
		if(efsType == null) {
			if(UserContext.isGdriveConnected) {
				appIntegList.add(new App_Integration__c(id=SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING).Id,
							  						    Batch_Processing__c = newValue));				
			}
			if(UserContext.isDropboxConnected) {
				appIntegList.add(new App_Integration__c(id=SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Id,
							  						    Batch_Processing__c = newValue));				
			}
		} else if(SimpplrContext.Integrations.get(efsType) != null) {
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', efsType);
			String query = 'SELECT Id, Batch_Processing__c FROM App_Integration__c WHERE name = : soqlParam1 AND Is_Deleted__c = false FOR UPDATE ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<App_Integration__c> appIntegQueriedList = (List<App_Integration__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
			if(appIntegQueriedList <> NULL && appIntegQueriedList.size()>0){
				appIntegList.add(new App_Integration__c(id=appIntegQueriedList[0].Id,
						  						    Batch_Processing__c = newValue));
			}
		}
		if(!appIntegList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appIntegList), 
												new List<Schema.SObjectField>{App_Integration__c.Batch_Processing__c}); 
		}
	}
	
	public static void setEFSRootFolderId(String newValue) {
		App_Integration__c apintegObj = new App_Integration__c(id=SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Id);
		apintegObj.Root_Folder_Id__c = newValue;
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(apintegObj, new List<Schema.SObjectField>{App_Integration__c.Root_Folder_Id__c}); 
	}
	
	public Static List<People__c> updatePeopleWhoCanAddSites(Set<String> addSitePeopleSet) {
		List<People__c> listOfPplObjToUpdate = new List<People__c>();		
		List<People__c> peopleList = new List<People__c>();
		
		peopleList = [SELECT Id, Can_Add_Sites__c FROM People__c 
				WHERE User__r.IsActive = true AND (Id IN : addSitePeopleSet or Can_Add_Sites__c = true) WITH SECURITY_ENFORCED];	
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList){
			
				if (addSitePeopleSet != null && addSitePeopleSet.contains(ppl.id)) {
					ppl.Can_Add_Sites__c = true;
					
				} else {
					ppl.Can_Add_Sites__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate), 
					new List<Schema.SObjectField>{People__c.Can_Add_Sites__c});
		}
		return listOfPplObjToUpdate;
	}
	
	/**
	 * @description This method is used to update People__c records who are Content Moderator
	 * @param contentModeratorPeoplelist
	 * @return  `List<People__c>`
	*/
	public static List<People__c> updatePeopleWhoAreContentModerator(Set<String> contentModeratorPeoplelist) {
		List<People__c> listOfPplObjToUpdate = new List<People__c>();		
		List<People__c> peopleList = new List<People__c>();
		
		String pplQuery = 'SELECT Id, Is_Content_Moderator__c FROM People__c WHERE User__r.IsActive = true AND (Id IN : soqlParam1 or Is_Content_Moderator__c = true)';
		Map<String, Object> soqlParams = new Map<String, Object>();
		soqlParams.put('soqlParam1', contentModeratorPeoplelist);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		peopleList = (List<People__c>) SIMPESAPI.accessController().queryAsUser(pplQuery, soqlParams);
		
		if (!peopleList.isEmpty()) {
			
			for (People__c ppl: peopleList){
			
				if (contentModeratorPeoplelist != null && contentModeratorPeoplelist.contains(ppl.id)) {
					ppl.Is_Content_Moderator__c = true;
					
				} else {
					ppl.Is_Content_Moderator__c = false;					
				}
				
				listOfPplObjToUpdate.add(ppl);
    		} 
    		
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate), 
					new List<Schema.SObjectField>{People__c.Is_Content_Moderator__c});
		}
		return listOfPplObjToUpdate;
	}

	public static void updateAppConfig(String addSitesPermission, String leadercastPermission) {
		String appConfigQuery = 'SELECT id, Allow_Site_Add__c FROM App_Config__c LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfigList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
		if (appConfigList.size() > 0 ){
			appConfigList[0].Allow_Site_Add__c = addSitesPermission;
			appConfigList[0].Allow_Leadercast__c = leadercastPermission;
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(new Map<id,App_Config__c>(appConfigList), 
					new List<Schema.SObjectField>{App_Config__c.Allow_Site_Add__c, App_Config__c.Allow_Leadercast__c});
		}
	}

	public ManageApplicationWrapper.ProfileFieldsWrapper loadPeopleProfileConfig() {
		ManageApplicationWrapper.ProfileFieldsWrapper wrapperObj = null;

		wrapperObj = new ManageApplicationWrapper.ProfileFieldsWrapper();

		wrapperObj.lastNameSynced = SimpplrContext.isPDSLastName;
		wrapperObj.firstNameSynced = SimpplrContext.isPDSFirstName;
		wrapperObj.userTitleSynced = SimpplrContext.isPDSTitle;
		wrapperObj.aboutMeSynced = SimpplrContext.isPDSAboutMe;
		wrapperObj.departmentSynced = SimpplrContext.isPDSDepartment;
		wrapperObj.stateSynced = SimpplrContext.isPDSState;
		wrapperObj.countrySynced = SimpplrContext.isPDSCountry;
		wrapperObj.phoneSynced = SimpplrContext.isPDSPhone;
		wrapperObj.extensionSynced = SimpplrContext.isPDSExtension;
		wrapperObj.mobilePhoneSynced = SimpplrContext.isPDSMobilePhone;
		wrapperObj.userCategorySynced = false;
		wrapperObj.citySynced = SimpplrContext.isPDSCity;
		wrapperObj.streetSynced = SimpplrContext.isPDSStreet;
		wrapperObj.managerSynced = SimpplrContext.isPDSManagerId;
		wrapperObj.timezoneSynced = false;
		wrapperObj.birthDateSynced = SimpplrContext.isPDSBirthDate;
		wrapperObj.joiningDateSynced = SimpplrContext.isPDSJoiningDate;
		wrapperObj.companyNameSynced = SimpplrContext.isPDSCompanyName;
		wrapperObj.divisionSynced = SimpplrContext.isPDSDivision;
		wrapperObj.videoSynced = false;	
        wrapperObj.languageSynced = false;
		
		wrapperObj.firstName = SimpplrContext.isPPFirstNameDisplay;
		wrapperObj.editableFirstName = !SimpplrContext.isPDSFirstName && SimpplrContext.isPPFirstNameEditable;
		wrapperObj.lastName = SimpplrContext.isPPLastNameDisplay;
		wrapperObj.editableLastName = !SimpplrContext.isPDSLastName && SimpplrContext.isPPLastNameEditable;
		wrapperObj.userTitle = SimpplrContext.isPPTitleDisplay;
		wrapperObj.editableUserTitle = !SimpplrContext.isPDSTitle && SimpplrContext.isPPTitleEditable;
		wrapperObj.aboutMe = SimpplrContext.isPPAboutMeDisplay;
		wrapperObj.editableAboutMe = !SimpplrContext.isPDSAboutMe && SimpplrContext.isPPAboutMeEditable;
		wrapperObj.department = SimpplrContext.isPPDepartmentDisplay;
		wrapperObj.editableDepartment = !SimpplrContext.isPDSDepartment && SimpplrContext.isPPDepartmentEditable;
		wrapperObj.state = SimpplrContext.isPPStateDisplay;
		wrapperObj.editableState = !SimpplrContext.isPDSState && SimpplrContext.isPPStateEditable;
		wrapperObj.country = SimpplrContext.isPPCountryDisplay;
		wrapperObj.editableCountry = !SimpplrContext.isPDSCountry && SimpplrContext.isPPCountryEditable;
		wrapperObj.phone = SimpplrContext.isPPPhoneDisplay;
		wrapperObj.editablePhone = !SimpplrContext.isPDSPhone && SimpplrContext.isPPPhoneEditable;
		wrapperObj.extension = SimpplrContext.isPPExtensionDisplay;
		wrapperObj.editableExtension = !SimpplrContext.isPDSExtension && SimpplrContext.isPPExtensionEditable;
		wrapperObj.mobilePhone = SimpplrContext.isPPMobilePhoneDisplay;
		wrapperObj.editableMobilePhone = !SimpplrContext.isPDSMobilePhone && SimpplrContext.isPPMobilePhoneEditable;
		wrapperObj.userCategory = SimpplrContext.isPPCategoryDisplay;
		wrapperObj.editableUserCategory = SimpplrContext.isPPCategoryEditable;
		wrapperObj.city = SimpplrContext.isPPCityDisplay;
		wrapperObj.editableCity = !SimpplrContext.isPDSCity && SimpplrContext.isPPCityEditable;
		wrapperObj.street = SimpplrContext.isPPStreetDisplay;
		wrapperObj.editableStreet = !SimpplrContext.isPDSStreet && SimpplrContext.isPPStreetEditable;
		wrapperObj.manager = SimpplrContext.isPPManagerDisplay;
		wrapperObj.editableManager = !SimpplrContext.isPDSManagerId && SimpplrContext.isPPManagerEditable;
		wrapperObj.timezone = SimpplrContext.isPPTimezoneDisplay;
		wrapperObj.editableTimezone = SimpplrContext.isPPTimezoneEditable;
		wrapperObj.birthDate = SimpplrContext.isPPBirthDateDisplay;
		wrapperObj.editableBirthDate = !SimpplrContext.isPDSBirthDate && SimpplrContext.isPPBirthDateEditable;
		wrapperObj.joiningDate = SimpplrContext.isPPJoiningDateDisplay;
		wrapperObj.editableJoiningDate = !SimpplrContext.isPDSJoiningDate && SimpplrContext.isPPJoiningDateEditable;
		wrapperObj.companyName = SimpplrContext.isPPCompanyNameDisplay;
		wrapperObj.editableCompanyName = !SimpplrContext.isPDSCompanyName && SimpplrContext.isPPCompanyNameEditable;
		wrapperObj.division = SimpplrContext.isPPDivisionDisplay;
		wrapperObj.editableDivision = !SimpplrContext.isPDSDivision && SimpplrContext.isPPDivisionEditable;
		wrapperObj.video = SimpplrContext.isPPVideoDisplay;
		wrapperObj.editableVideo = SimpplrContext.isPPVideoEditable;
		wrapperObj.videoProvider = String.isNotBlank(SimpplrContext.PPVideoProvider)  ? SimpplrContext.PPVideoProvider.toLowerCase() : 'none';
		wrapperObj.language = SimpplrContext.isPPLanguageDisplay;
		wrapperObj.editableLanguage = SimpplrContext.isPPLanguageEditable;
	
		if(String.isNotBlank(SimpplrContext.PPUserCustomFields)) {
			wrapperObj.customFields = (List<CustomProfileField>)Json.deserialize(SimpplrContext.PPUserCustomFields, List<CustomProfileField>.class);
		} else {
			wrapperObj.customFields = new List<CustomProfileField>();
		}

		wrapperObj.availableFields = getAvailableCustomFields();

        return wrapperObj;
	}

	public Map<String, String> getAvailableCustomFields() {
		Map<String, String> availableFields = new Map<String, String>();
		Set<String> setOfAllowedFieldTypes = new Set<String>{'email','multipicklist', 'phone', 'picklist', 'string', 'url','date'};
		
		SObjectType userType = Schema.getGlobalDescribe().get('User');
		Map<String,Schema.SObjectField> mapOfUserFields = userType.getDescribe().fields.getMap();
		
		// on - off checkboxes already available on manageapplicationprofilefields page so no need to add following fields in list.  
		Set<String> profileFields = new Set<String>();
		profileFields.add('firstname');
		profileFields.add('lastname');
		profileFields.add('title');
		profileFields.add('aboutme');
		profileFields.add('managerid');
		profileFields.add('department');
		profileFields.add('city');
		profileFields.add('state');
		profileFields.add('country');
		profileFields.add('phone');
		profileFields.add('mobilephone');
		profileFields.add('timezonesidkey');
		
		for(Schema.SObjectField fieldObj : mapOfUserFields.values()) {
		    Schema.describefieldresult dfield = fieldObj.getDescribe();
		    if(!dfield.getName().startsWith('Simpplr__')) {
				String fieldType = dfield.getType().name().toLowerCase();
				if(setOfAllowedFieldTypes.contains(fieldType) && !profileFields.contains(dfield.getName().toLowerCase())){
			    	availableFields.put(dfield.getName(), dfield.getName());
		    	}
			}
		}
		
		return availableFields;
	}

	public ManageApplicationWrapper.MessagingIntegrationWrapper getMessagingIntegrationsConfig(Boolean isSlackUnfurlAppInstalled){ 
		ManageApplicationWrapper.MessagingIntegrationWrapper wrapperObj = new ManageApplicationWrapper.MessagingIntegrationWrapper();
		String appIntQuery = 'Select Integration_Enabled__c, Client_Id__c, Client_Secret__c, Connected__c, Name, Alerts_For_App_Enabled__c, User_Name__c, User_Email__c, Enterprise_Id__c, Custom_Name_Enabled__c, Custom_App_Name__c, Custom_App_Icon_Url__c from App_Integration__c Where Is_Deleted__c = false AND Org_Id__c = :soqlParam1';		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', SimpplrContext.simpplrOrgId);
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, soqlParamMap);

		for (App_Integration__c appIntegObj : appIntegList) { 
			if (appIntegObj.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS) && (SimpplrContext.isFeatureMicrosoftTeamsEnabled)) {
				wrapperObj.microsoftTeamsIntegrationEnabled = appIntegObj.Integration_Enabled__c;
				wrapperObj.microsoftTeamsConnected = appIntegObj.Connected__c;
				wrapperObj.isAlertsForTeamsEnabled = SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 ? appIntegObj.Alerts_For_App_Enabled__c : false;
				wrapperObj.isAddToMicrosoftTeamsButtonEnabled = false;
				if(wrapperObj.microsoftTeamsIntegrationEnabled && String.isNotBlank(appIntegObj.Client_Id__c) &&  String.isNotBlank(appIntegObj.Client_Secret__c)){

					wrapperObj.isAddToMicrosoftTeamsButtonEnabled = true;
					wrapperObj.addToMicrosoftTeamsUrl = (new IntegrationService(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS, null)).getAuthPage(false);
				}
				if(wrapperObj.microsoftTeamsConnected) {
					wrapperObj.msTeamsConnectedAs = SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 ? appIntegObj.User_Email__c : null;
					wrapperObj.msTeamsDomainID = SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2 ? appIntegObj.Enterprise_Id__c : null;
				}
			} else if (appIntegObj.name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_SLACK)) {
				wrapperObj.slackIntegrationEnabled = appIntegObj.Integration_Enabled__c;
				wrapperObj.slackConnected = appIntegObj.Connected__c;
				if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded) {
					wrapperObj.isSlackUnfurlAppInstalled = new SlackHelper().getSlackAppInstalledInfo();
				} else {
					wrapperObj.isSlackUnfurlAppInstalled = isSlackUnfurlAppInstalled;
				}
				wrapperObj.slackCustomNameIconEnabled = appIntegObj.Custom_Name_Enabled__c;
				wrapperObj.slackAppName = appIntegObj.Custom_App_Name__c;
				wrapperObj.slackAppIconConfig = appIntegObj.Custom_App_Icon_Url__c;
				wrapperObj.isAddToSlackButtonEnabled = false;
				if(wrapperObj.slackIntegrationEnabled && String.isNotBlank(appIntegObj.Client_Id__c) &&  String.isNotBlank(appIntegObj.Client_Secret__c)){

					wrapperObj.isAddToSlackButtonEnabled = true;

					String baseUrl = SimpplrContext.salesforceBaseUrl+'/';
					Map<String,Object> stateMap = new Map<String,Object>();
					stateMap.put('redirectUrl',PageContext.getPageURL(Pages.ConnectExternalApp)+'?state=slackAppInstall');
					stateMap.put('appName',SimpplrContext.applicationName);
					stateMap.put('sfOrgId',SimpplrContext.simpplrOrgId);
					stateMap.put('baseUrl',baseUrl);
					stateMap.put('isSandBox',SimpplrContext.isSandbox);
					String slackStateJSON = JSON.serialize(stateMap);
					slackStateJSON = EncodingUtil.urlEncode(slackStateJSON,'UTF-8');
					wrapperObj.addToSlackUrl = 'https://slack.com/oauth/authorize?client_id=' + SimpplrContext.SlackClientId +'&scope=groups:read,channels:read,links:read,links:write,chat:write:bot,team:read,users:read&state=' + slackStateJSON;
				}
				wrapperObj.slackUninstallUrl = PageContext.getPageURL(Pages.ConnectExternalApp)+'?state=slackAppUninstall&source=salesforce';
			}
        }

		if(!SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
            String appConfigQuery = 'SELECT Id, Microsoft_Teams_Integration_Enabled__c FROM App_Config__c';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            App_Config__c appConfigObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
            
            wrapperObj.microsoftTeams = appConfigObj.Microsoft_Teams_Integration_Enabled__c;
        }

		return wrapperObj;
	}
	
	public Boolean  getSlackAppInstalledInfo(String sfOrgId){
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		String dri = Utility.requestAdoptionDataAuthToken();
		String endPoint = 'https://services.simpplr.com/integration/manage-slack.php';
		req.setEndpoint(endPoint);
		req.setHeader('Content-Type','application/x-www-form-urlencoded');
		req.setMethod('POST');
		req.setBody('{"data":{"sfOrgId":"'+sfOrgId+'","dri":"'+dri+'","action_name":"getSlackAppInstalledInfo"}}');
		req.setTimeout(60000);
		HttpResponse res = h.send(req);
		return  Boolean.valueOf(res.getBody());
	}

	public ManageApplicationWrapper.FilesIntegrationWrapper getFilesIntegrationsConfig(){
		ManageApplicationWrapper.FilesIntegrationWrapper integrations= new ManageApplicationWrapper.FilesIntegrationWrapper();
		String appConfigQuery = 'SELECT Box_Client_Id__c, Box_Username__c, SP_Upgrade_Status__c, Box_Managed_Permissions__c, Box_Access_Permissions__c, '
                						+ ' Box_Refresh_Token_Expires_At__c, Box_Client_Secret__c,Box_Integration_Enabled__c FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfObj = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		
		integrations.boxStorage = appConfObj.Box_Integration_Enabled__c; 
		integrations.boxConnectedAs = appConfObj.Box_Username__c;
		integrations.boxManagedPermission = appConfObj.Box_Managed_Permissions__c;
		if('box'.equalsIgnoreCase(integrations.boxManagedPermission)) {
			integrations.showOpenInBox = appConfObj.Box_Access_Permissions__c;	
		} 
		if (appConfObj.Box_Refresh_Token_Expires_At__c != null) {
			Integer noOfDays = appConfObj.Box_Refresh_Token_Expires_At__c.date().daysBetween(Date.today());
			integrations.isBoxAccountReconnectRequired = (noOfDays >=0 && noOfDays <= 15) ? true : false;
		} else {
			integrations.isBoxAccountReconnectRequired = false;
		}
		integrations.dropboxEnabled = false;
		integrations.spIntegrationEnabled = false;
		integrations.odIntegrationEnabled = false;
		integrations.spUpgradeStatus = SimpplrContext.isSharepointUpgraded ? ServiceConstants.SP_UPGRADE_STATUS_COMPLETED : appConfObj.SP_Upgrade_Status__c;
		integrations.showOpenInSharePoint = SimpplrContext.showOpenInSharePoint;

		if (GoogleDriveService.googleMultiDomainUpgraded()) {
			GoogleDriveService googleServiceObj = new GoogleDriveService();
			integrations.googleDriveDomainExists = googleServiceObj.getGoogleDomainExists(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
		}
		integrations.googleMultiDomainUpgradeStatus = SimpplrContext.googleMultiDomainUpgradeStatus != 
		ServiceConstants.UPGRADE_STATUS_IN_PROGRESS ? SimpplrContext.googleMultiDomainUpgradeStatus : GoogleDriveService.validateGoogleMultiDomainStatus();

		String appIntQuery = 'SELECT Id, Name,'
                + ' Scope__c, Scope_Required__c, User_Name__c, User_Email__c,' 
                + ' Extra_Url_Parameters__c, Client_Secret__c, Client_Id__c,'
                + ' DB_User_Client_Id__c, DB_User_Client_Secret__c,'
                + ' App_Access_Token__c, App_Refresh_Token__c,'
                + ' Token_Type__c, Redirect_Uri__c, App_Installed__c,'
                + ' Access_Token_Requested_Datetime__c, Refresh_Token_Requested_Datetime__c,'
                + ' Access_Token_Expiration_Datetime__c, Refresh_Token_Expiration_Datetime__c,' 
                + ' Access_Token_Expiry__c,  External_Id__c, Integration_Enabled__c, Connected__c,'
                + ' Is_Deleted__c ,All_Company_Group_Id__c, Batch_Processing__c,'
                + ' Root_Folder_Id__c, Enterprise_Id__c, Endpoint_Url__c, Data__c,'
                + ' Is_My_Drive_Enabled__c, Simpplr_Managed_Permission__c,'
                + ' Is_Shared_Drive_Enabled__c, Show_Open_In_Google_Drive__c, Whitelist_Domain__c'
                + ' FROM App_Integration__c'
                + ' WHERE Is_Deleted__c = false'
                + ' AND Org_Id__c = :soqlParam1';
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', SimpplrContext.simpplrOrgId);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegrationList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
	
        for (App_Integration__c obj: appIntegrationList) {

			if (ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(obj.Name)) {
				integrations.dropboxEnabled = obj.Integration_Enabled__c;
                
                if (EFSConstants.storageTypes.contains(obj.Name) && 
                        obj.Integration_Enabled__c == true && obj.Connected__c == true){
					integrations.dbConnectedAs = obj.User_Email__c;
                }
                
			} else if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(obj.Name)) {
				integrations.spIntegrationEnabled = obj.Integration_Enabled__c;
				if (obj.Whitelist_Domain__c != null) {
					integrations.sharepointDomainWhitelist = (obj.Whitelist_Domain__c).split(',');
				}
                if (EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID.equalsIgnoreCase(obj.Client_Id__c)) {
					integrations.spFullSearchEnabled = true;
					integrations.spConnected = integrations.spIntegrationEnabled && (String.isNotBlank(obj.User_Email__c) || String.isNotBlank(obj.User_Name__c));
					integrations.spConnectedAs = String.isNotBlank(obj.User_Email__c) ? obj.User_Email__c : obj.User_Name__c;

				} else {
					integrations.spFullSearchEnabled = false;
					integrations.spConnected = integrations.spIntegrationEnabled;

				}

			} else if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(obj.Name)) {
				integrations.odIntegrationEnabled = obj.Integration_Enabled__c;	
                integrations.odConnected = integrations.odIntegrationEnabled;
                
            } else if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(obj.Name)) {
				integrations.googleDriveEnabled = obj.Integration_Enabled__c;
				if (obj.Refresh_Token_Expiration_Datetime__c != null) {
					Integer noOfDays = obj.Refresh_Token_Expiration_Datetime__c.date().daysBetween(Date.today());
					integrations.isGoogleDriveAccountReconnectRequired = (noOfDays >=0 && noOfDays <= 15) ? true : false;
				} else {
					integrations.isGoogleDriveAccountReconnectRequired = false;
				}
                if (EFSConstants.storageTypes.contains(obj.Name) && obj.Connected__c == true){
                    integrations.googleDriveConnectedAs = obj.User_Email__c;
					if(obj.Is_My_Drive_Enabled__c == false) {
						integrations.myDriveEnabled = null;
						integrations.sharedDriveEnabled = null;
						integrations.showOpenInGoogleDrive = null;
						integrations.googleManagedPermission = null;
					} else {
						integrations.myDriveEnabled = obj.Is_My_Drive_Enabled__c;
						integrations.sharedDriveEnabled = obj.Is_Shared_Drive_Enabled__c;
						if(obj.Simpplr_Managed_Permission__c) {
							integrations.showOpenInGoogleDrive = null;
						} else {
							integrations.showOpenInGoogleDrive = obj.Show_Open_In_Google_Drive__c;
						}
						integrations.googleManagedPermission = !obj.Simpplr_Managed_Permission__c;
					}
				}
			}
        }

		return integrations;
	}

	public void saveFilesIntegrationsConfig(ManageApplicationWrapper.FilesIntegrationWrapper integrationObj){
    	List<App_Integration__c> listToUpdate = new List<App_Integration__c>();
    	List<App_Integration__c> listToInsert = new List<App_Integration__c>();
		Boolean BoxPermissionChanged = false;
		Set<String> sharepointDomainsRemovedSet = new Set<String>();
		Boolean googleDriveDelete = false;
		String appConfigQuery  = 'SELECT Id,Box_Client_Id__c, Box_Username__c, Box_Client_Secret__c, Box_Integration_Enabled__c, Box_Managed_Permissions__c, Box_Access_Permissions__c, Box_Connected_Datetime__c FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		List<Schema.SObjectField> modifiedColumns = new List<Schema.SObjectField>();

		if(appConfig != null && String.isNotBlank(appConfig.Box_Username__c) && String.isNotBlank(appConfig.Box_Managed_Permissions__c) && 'simpplr'.equalsIgnoreCase(appConfig.Box_Managed_Permissions__c) &&    
			String.isNotBlank(integrationObj.boxManagedPermission) && 'box'.equalsIgnoreCase(integrationObj.boxManagedPermission)) {
				logger.logDebug('Changed permission from simpplr to box managed..');
				BoxPermissionChanged = true;
		}
		
    	Map<String,App_Integration__c> mapOfAppIntObject= new Map<String,App_Integration__c>();
    	mapOfAppIntObject.putAll(SimpplrContext.Integrations);
    	
    	App_Integration__c appInteg;
    	for(String storage: EFSConstants.storageTypes) {
    		if(mapOfAppIntObject.containsKey(storage)) {
    			appInteg = mapOfAppIntObject.get(storage);
    		} else {
    			appInteg = new App_Integration__c();
    		}
    		if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(storage) && integrationObj.spIntegrationEnabled == true && appInteg != null && appInteg.Connected__c == false) {
				appInteg.Connected_DateTime__c = DateTime.now();
			} else if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(storage) && integrationObj.odIntegrationEnabled == true &&  appInteg != null && appInteg.Connected__c == false) {
				appInteg.Connected_DateTime__c = DateTime.now();	
			}
			Boolean isSharepointPreviouslyConnected = appInteg.Integration_Enabled__c;
			Boolean isGDrivePreviouslyConnected = appInteg.Integration_Enabled__c;
    		appInteg.Name = storage;
    		appInteg.Org_Id__c = UserInfo.getOrganizationId();
   			appInteg.Connected__c = String.isNotBlank(appInteg.User_Name__c);	
    		appInteg.Integration_Enabled__c = false;
	    	if(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(storage)) {
				Boolean isGoogleMultiDomainUpgraded = GoogleDriveService.googleMultiDomainUpgraded();
				if (integrationObj.googleDriveEnabled == true) {
					if (isGoogleMultiDomainUpgraded) {
						GoogleDriveService googleServiceObj = new GoogleDriveService();
						Boolean googleDriveDomainExists = googleServiceObj.getGoogleDomainExists(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
						if (!googleDriveDomainExists) {
							throw new SimpplrException(ERROR_DOMAIN_CONFIG_NOT_SETUP);
						}
						appInteg.Connected__c = true;
					}
					Boolean oldSharedDriveEnabled = appInteg.Is_Shared_Drive_Enabled__c;
					Boolean oldMyDriveEnabled = appInteg.Is_My_Drive_Enabled__c;
					Boolean oldSimpManagedPermission = appInteg.Simpplr_Managed_Permission__c;
					
                    GoogleDriveService googleServiceObj = new GoogleDriveService();
                    Boolean myDriveEnabled = isGoogleMultiDomainUpgraded ? integrationObj.googleDriveEnabled : integrationObj.myDriveEnabled;
                    Boolean sharedDriveEnabled = integrationObj.sharedDriveEnabled;
                    Boolean googleManagedPermission = integrationObj.googleManagedPermission;
                    Boolean showOpenInGoogleDrive = integrationObj.showOpenInGoogleDrive;
                    googleServiceObj.saveFilesIntegrationsConfig(myDriveEnabled, sharedDriveEnabled, googleManagedPermission, showOpenInGoogleDrive);

		    		appInteg.Integration_Enabled__c = true;
					if (isGoogleMultiDomainUpgraded) {
						appInteg.Is_My_Drive_Enabled__c = integrationObj.googleDriveEnabled == true ? true : false;
					} else {
						appInteg.Is_My_Drive_Enabled__c = integrationObj.myDriveEnabled == true ? true : false;
					}
					if(appInteg != Null && oldMyDriveEnabled == false && appInteg.Is_My_Drive_Enabled__c == true) {
						appInteg.Connected_Datetime__c = DateTime.now();
					}

                    if(integrationObj.sharedDriveEnabled == true) {
                        appInteg.Simpplr_Managed_Permission__c = false; 
                    }   
                    else {
					    appInteg.Simpplr_Managed_Permission__c =  integrationObj.googleManagedPermission == true ? false : true;
                    }
					appInteg.Is_Shared_Drive_Enabled__c = integrationObj.sharedDriveEnabled == true ? true : false;
					appInteg.Show_Open_In_Google_Drive__c = integrationObj.showOpenInGoogleDrive;
					appInteg.Client_Id__c = EFSConstants.GOOGLEDRIVE_CLIENT_ID;
					appInteg.Client_Secret__c = EFSConstants.GOOGLEDRIVE_CLIENT_SECRET;
					// Shared drive turned OFF
					if(appInteg != Null && oldSharedDriveEnabled == true && integrationObj.sharedDriveEnabled == false) {
						FolderDao folderDaoObj = new FolderDao();
						folderDaoObj.unlinkAllSharedDriveFolder();
					}
					// Permission changed from simpplr to google managed
					// 1. MyDrive Simpplr Managed(SM) to MyDrive Google Managed(GM)
					// 2. MyDrive Simpplr Managed(SM) to Shared Drive(Always Google Managed)
					if(appInteg != Null && oldSharedDriveEnabled == false && oldSimpManagedPermission == true && (integrationObj.sharedDriveEnabled == true || (integrationObj.sharedDriveEnabled == false && integrationObj.googleManagedPermission == true) )) {
						logger.logDebug('Changed permission from simpplr to google managed..');
						List<String> chattergroupIds = new List<String>();
						List<Simpplr_Site__c> siteList = [Select id, Chatter_Group_Id__c, File_Storage_Source__c from Simpplr_Site__c where File_Storage_Source__c ='googledrive' WITH SECURITY_ENFORCED];
						for(Simpplr_Site__c siteObj : siteList) {
							chattergroupIds.add(siteObj.Chatter_Group_Id__c);
						}
						GoogleDriveService gdService = new GoogleDriveService();
						gdService.deleteAllGoogleGroups(chattergroupIds);
					}
				} else if(integrationObj.googleDriveEnabled == false && appInteg != null && isGDrivePreviouslyConnected && isGoogleMultiDomainUpgraded) {
					googleDriveDelete = true;
					appInteg.Connected__c = false;
					// disable google drive on AWS
					updateIntegrationDisconnectOnAWS('disconnectGoogleDriveAdmin');
				}
				
	    	} else if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(storage)) {
	    		if(integrationObj.dropboxEnabled == true) {
		    		appInteg.Integration_Enabled__c = true;
		    		appInteg.Client_Id__c = EFSConstants.DROPBOX_ADMIN_CLIENT_ID;
		    		appInteg.Client_Secret__c = EFSConstants.DROPBOX_ADMIN_CLIENT_SECRET;
		    		appInteg.DB_User_Client_Id__c = EFSConstants.DROPBOX_USER_CLIENT_ID;
		    		appInteg.DB_User_Client_Secret__c = EFSConstants.DROPBOX_USER_CLIENT_SECRET;
		    		appInteg.Extra_URL_Parameters__c = 'force_reapprove=true';
		    		
		    		Database.executeBatch(new BatchEFSPeoplePreferenceUpdate('SETMOUNTFLAG'), 5000);
	    		} 
				
			} else if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(storage)) {
				if(integrationObj.spIntegrationEnabled == true) {			
					appInteg.Integration_Enabled__c = true;
					appInteg.Client_Id__c = String.isBlank(appInteg.Client_Id__c) ? EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_ID:appInteg.Client_Id__c;
					appInteg.Client_Secret__c = String.isBlank(appInteg.Client_Secret__c) ? EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_SECRET:appInteg.Client_Secret__c;
					appInteg.Connected__c = true;
					appInteg.Token_Type__c = 'DUMMY';
					appInteg.Access_Token_Expiry__c = 99999.00;
					appInteg.Access_Token_Requested_Datetime__c = DateTime.valueOfGmt('2019-12-31 23:59:59').addYears(10);
					appInteg.App_Access_Token__c = 'DUMMYACCCESSTOKEN';
					appInteg.App_Refresh_Token__c = 'DUMMYREFRESHTOKEN';
					appInteg.Extra_URL_Parameters__c = 'prompt=admin_consent';
					
					Map<String, Boolean> showOpenInSharePoint = new Map<String, Boolean>{
						'showOpenInSharePoint' => integrationObj.showOpenInSharePoint
					};
					appInteg.Data__c = JSON.serialize(showOpenInSharePoint);
					if(integrationObj.sharepointDomainWhitelist != null && integrationObj.sharepointDomainWhitelist.size() > 0) {
						appInteg.Whitelist_Domain__c = appInteg.Whitelist_Domain__c != null ? appInteg.Whitelist_Domain__c : '';
						Set<String> existingDomainSet = new Set<String>(appInteg.Whitelist_Domain__c.split(','));
						Set<String> sharepointDomainSet = new Set<string>();
						List<String> sharepintDomainList = new List<String>();
						sharepointDomainSet.addAll(integrationObj.sharepointDomainWhitelist);
						sharepintDomainList.addAll(sharepointDomainSet);
						appInteg.Whitelist_Domain__c = Utility.convertToCommaSeparatedString(sharepintDomainList);

						// Get set difference
						Map<String, Set<String>> setDifference = Utility.getSetDifference(existingDomainSet, sharepointDomainSet);
						sharepointDomainsRemovedSet = setDifference.get('entriesRemoved');				
					}
				}
				else if (integrationObj.spIntegrationEnabled == false && mapOfAppIntObject.containsKey(storage) && isSharepointPreviouslyConnected){
					Set<String> existingDomainSet = new Set<String>(appInteg.Whitelist_Domain__c.split(','));
					appInteg.Connected__c = false;
					appInteg.Integration_Enabled__c = false;
					Set<String> sharepointDomainSet = new Set<String>();
					List<String> sharepintDomainList = new List<String>();
					sharepointDomainSet.addAll(integrationObj.sharepointDomainWhitelist);
					sharepintDomainList.addAll(sharepointDomainSet);
					appInteg.Whitelist_Domain__c = Utility.convertToCommaSeparatedString(sharepintDomainList);

					// Get set difference
					Map<String, Set<String>> setDifference = Utility.getSetDifference(existingDomainSet, sharepointDomainSet);
					sharepointDomainsRemovedSet = setDifference.get('entriesRemoved');				
				}

	    	} else if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(storage)) {
	    		if(integrationObj.odIntegrationEnabled == true) {
		    		appInteg.Integration_Enabled__c = true;
		    		appInteg.Client_Id__c = EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_ID;
		    		appInteg.Client_Secret__c = EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_SECRET;
		    		appInteg.Connected__c = true;
		    		appInteg.Token_Type__c = 'DUMMY';
		    		appInteg.Access_Token_Expiry__c = 99999.00;
		    		appInteg.Access_Token_Requested_Datetime__c = DateTime.valueOfGmt('2019-12-31 23:59:59').addYears(10);
		    		appInteg.App_Access_Token__c = 'DUMMYACCCESSTOKEN';
		    		appInteg.App_Refresh_Token__c = 'DUMMYREFRESHTOKEN';
		    		appInteg.Extra_URL_Parameters__c = 'prompt=admin_consent';
	    		}
	    	}
	    	
	    	if(String.isNotBlank(appInteg.Client_Id__c)) {
		    	if(String.isBlank(appInteg.Id)) {
		    		listToInsert.add(appInteg);
		    	} else {
		    		listToUpdate.add(appInteg);
		    	}
	    	}
    	}
    	
    	if(listToUpdate.size()>0){
    		update listToUpdate;
    	}
    	
    	if(listToInsert.size()>0){
    		insert listToInsert;
    	}

		appConfig.Box_Integration_Enabled__c = integrationObj.boxStorage;
		appConfig.Box_Client_Id__c = String.isBlank(appConfig.Box_Client_Id__c) ? EFSConstants.BOX_CLIENT_ID:appConfig.Box_Client_Id__c;
		appConfig.Box_Client_Secret__c = String.isBlank(appConfig.Box_Client_Secret__c) ? EFSConstants.BOX_CLIENT_SECRET:appConfig.Box_Client_Secret__c;
		appConfig.Box_Managed_Permissions__c = String.isNotBlank(appConfig.Box_Username__c) ? integrationObj.boxManagedPermission : null;
		appConfig.Box_Access_Permissions__c = integrationObj.showOpenInBox != null ? integrationObj.showOpenInBox : false;
		
		modifiedColumns.add(App_Config__c.Box_Integration_Enabled__c);
		modifiedColumns.add(App_Config__c.Box_Client_Id__c);
		modifiedColumns.add(App_Config__c.Box_Client_Secret__c);
		modifiedColumns.add(App_Config__c.Box_Managed_Permissions__c);
		modifiedColumns.add(App_Config__c.Box_Access_Permissions__c);
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appConfig, modifiedColumns);

		if(BoxPermissionChanged == true) {												
			BatchRemoveBoxGroup job = new BatchRemoveBoxGroup('boxAdminDisconnect');			
			Database.executeBatch(job,200);
		}

		if(!sharepointDomainsRemovedSet.isEmpty()) {
			List<String> connectedApps = new List<String>{ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING};
			Database.executeBatch(new BatchDeleteIntegrationRecords(connectedApps, 
								'removeDomainPeopleIntegration', sharepointDomainsRemovedSet),2000);
		}

		if (googleDriveDelete == true) {
			List<String> connectedApps = new List<String>{ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING};
			Database.executeBatch(new BatchDeleteIntegrationRecords(connectedApps, BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION, null),2000);
		}
		
	}

	public ManageApplicationWrapper.DomainsIntegrationResWrapper getDomainsIntegrationsConfig() {
		ManageApplicationWrapper.DomainsIntegrationResWrapper integrations = new ManageApplicationWrapper.DomainsIntegrationResWrapper();
		String appIntQuery = 'SELECT Id, Name,'
                + ' Client_Id__c, Client_Secret__c,'
                + ' Is_Deleted__c, Whitelist_Domain__c, Org_Id__c'
                + ' FROM App_Integration__c'
                + ' WHERE Is_Deleted__c = false'
                + ' AND Name IN :soqlParam1';
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', IntegrationConstants.MULTI_DOMAIN_APPS_NAME_LIST);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegrationList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);
		
		Map<String, List<Map<String, String>>> googleDomainList = new Map<String, List<Map<String, String>>>();
		for (App_Integration__c obj: appIntegrationList) {
			if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE.equalsIgnoreCase(obj.Name) && String.isNotBlank(obj.Whitelist_Domain__c)) {
				List<Map<String, String>> googleDriveDomainList = (List<Map<String, String>>)JSON.deserialize(obj.Whitelist_Domain__c, List<Map<String, String>>.class);
				googleDomainList.put('googleDriveDomainList', googleDriveDomainList);
			}
			if (IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(obj.Name) && String.isNotBlank(obj.Whitelist_Domain__c)) {
				List<Map<String, String>> googleCalendarDomainList = (List<Map<String, String>>)JSON.deserialize(obj.Whitelist_Domain__c, List<Map<String, String>>.class);
				googleDomainList.put('googleCalendarDomainList', googleCalendarDomainList);
			}
		}
		integrations.googleDomainList = googleDomainList;
		return integrations;
	}

	public static void removeDomains(List<Object> target, Object toRemove) {
		for(Integer i = target.size() - 1; i >= 0; i--) {
			if(target[i].equals(toRemove)) {
				target.remove(i);
			}
		}
	}

	public void insertOrUpdateDomainList(String multiDomainApp, App_Integration__c appInteg, List<Map<String, String>> domainListToAdd, String clientId, String clientSecret) {
		if(domainListToAdd != null && domainListToAdd.size() > 1) {
			throw new SimpplrException(ERROR_DOMAIN_TO_ADD_ONLY_ONE_DOMAIN_ALLOWED);
		}
		
		List<Map<String, String>> oldDomainList = String.isNotBlank(appInteg.Whitelist_Domain__c) ? (List<Map<String, String>>)JSON.deserialize(appInteg.Whitelist_Domain__c, List<Map<String, String>>.class) : null;
		Map<String, String> domainToAdd = domainListToAdd[0];

		logger.logDebug('ManageApplicationDao.insertOrUpdateDomainList()---oldDomainList' + oldDomainList);
    	logger.logDebug('ManageApplicationDao.insertOrUpdateDomainList()---domainToAdd' + domainToAdd);

		// Insert new record if it doesn't exist
		if (oldDomainList == null || oldDomainList.isEmpty()) {
			List<Map<String, String>> newDomainList = new List<Map<String, String>>();
			newDomainList.add(domainToAdd);
			logger.logDebug('ManageApplicationDao.removeDomainFromDomainList()---newDomainList' + newDomainList);

			// NEW DATA
			appInteg.Whitelist_Domain__c = (String)JSON.serialize(newDomainList);
			appInteg.Client_Id__c = clientId;
			appInteg.Client_Secret__c = clientSecret;
			appInteg.Is_Deleted__c = false;
			appInteg.Name = multiDomainApp;
			appInteg.Org_Id__c = SimpplrContext.simpplrOrgId;
			appInteg.Integration_Enabled__c = true;
			appInteg.Connected__c = true;
			appInteg.Is_My_Drive_Enabled__c = true;
			appInteg.Is_Shared_Drive_Enabled__c = true;
			appInteg.Show_Open_In_Google_Drive__c = true;
		}

		// Update existing record if it exists
		if (oldDomainList != null && !oldDomainList.isEmpty()) {
			// Add domain if it doesn't exist, else throw error
			if (!oldDomainList.contains(domainToAdd)) {
				List<Map<String, String>> newDomainList = oldDomainList;
				newDomainList.add(domainToAdd);

				// NEW DATA
				appInteg.Whitelist_Domain__c = (String)JSON.serialize(newDomainList);
			}
			else {
				throw new SimpplrException(ERROR_DOMAIN_TO_ADD_ALREADY_EXISTS); 
			}
		}
	}

	public void removeDomainFromDomainList(String multiDomainApp, App_Integration__c appInteg, List<Map<String, String>> domainListToRemove) {
		if(domainListToRemove != null && domainListToRemove.size() > 1) {
			throw new SimpplrException(ERROR_DOMAIN_TO_DELETE_ONLY_ONE_DOMAIN_ALLOWED);
		}
		
		List<Map<String, String>> oldDomainList = String.isNotBlank(appInteg.Whitelist_Domain__c) ? (List<Map<String, String>>)JSON.deserialize(appInteg.Whitelist_Domain__c, List<Map<String, String>>.class) : null;
		Map<String, String> domainToRemove = domainListToRemove[0];

		logger.logDebug('ManageApplicationDao.removeDomainFromDomainList()---oldDomainList' + oldDomainList);
    	logger.logDebug('ManageApplicationDao.removeDomainFromDomainList()---domainToRemove' + domainToRemove);

		// Throw error if the domain list record doesn't exist
		if (oldDomainList == null || oldDomainList.isEmpty()) {
			throw new SimpplrException(ERROR_DOMAIN_TO_DELETE_DOES_NOT_EXIST);
		}

		// Update existing record if it exists
		if (oldDomainList != null && !oldDomainList.isEmpty()) {
			// Delete domain if it exists, else throw error
			if (oldDomainList.contains(domainToRemove)) {
				List<Map<String, String>> newDomainList = oldDomainList;
				removeDomains(newDomainList, domainToRemove);
				logger.logDebug('ManageApplicationDao.removeDomainFromDomainList()---newDomainList' + newDomainList);
				
				// NEW DATA
				appInteg.Whitelist_Domain__c = (String)JSON.serialize(newDomainList);
				if (newDomainList.isEmpty()){
					appInteg.Integration_Enabled__c = false;
					appInteg.Connected__c = false;
					appInteg.Is_Deleted__c = true;
				} 
			} else {
				throw new SimpplrException(ERROR_DOMAIN_TO_DELETE_DOES_NOT_EXIST); 
			}
		}
	}

	public void saveDomainsIntegrationsConfig(ManageApplicationWrapper.DomainsIntegrationReqWrapper integrationObj) {
		List<String> multiDomainAppListToQuery = new List<String>();
		Map<String, List<Map<String, String>>> googleIntegrationsUpdateMap = new Map<String, List<Map<String, String>>>();
		if(integrationObj.googleDriveDomainList != null && !integrationObj.googleDriveDomainList.isEmpty()) {
			multiDomainAppListToQuery.add(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE);
			googleIntegrationsUpdateMap.put(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE, integrationObj.googleDriveDomainList);
		}
		if(integrationObj.googleCalendarDomainList != null && !integrationObj.googleCalendarDomainList.isEmpty()) {
			multiDomainAppListToQuery.add(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR);
			googleIntegrationsUpdateMap.put(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR, integrationObj.googleCalendarDomainList);
		}

		if(integrationObj.type == ServiceConstants.SAVE_DOMAIN_INTEGRATION_TYPE_REMOVE && multiDomainAppListToQuery.size() > 1) {
			throw new SimpplrException(ERROR_DOMAIN_TO_DELETE_ONLY_ONE_APP_DOMAIN_ALLOWED);
		}
		
		String appIntQuery = 'SELECT Id, Name,'
                + ' Client_Id__c, Client_Secret__c, Integration_Enabled__c, Connected__c, '
				+ ' Is_My_Drive_Enabled__c, Is_Shared_Drive_Enabled__c, Show_Open_In_Google_Drive__c, '
                + ' Is_Deleted__c, Whitelist_Domain__c, Org_Id__c'
                + ' FROM App_Integration__c'
                + ' WHERE Is_Deleted__c = false'
                + ' AND Name IN :soqlParam1';
		Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', multiDomainAppListToQuery);

		List<App_Integration__c> listToUpdate = new List<App_Integration__c>();
		List<App_Integration__c> listToInsert = new List<App_Integration__c>();

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegrationList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, sqlParamMap);

		Map<String, App_Integration__c> mapOfAppIntObject = new Map<String, App_Integration__c>();
		for(App_Integration__c appIntegration : appIntegrationList) {
			mapOfAppIntObject.put(appIntegration.Name, appIntegration);
		}

    	logger.logDebug('ManageApplicationDao.saveDomainsIntegrationsConfig()---multiDomainAppListToQuery' + multiDomainAppListToQuery);
		App_Integration__c appInteg;
		for(String multiDomainApp: multiDomainAppListToQuery) {
			if(mapOfAppIntObject.containsKey(multiDomainApp)) {
				appInteg = mapOfAppIntObject.get(multiDomainApp);
			} else {
				appInteg = new App_Integration__c();
			}

			if (integrationObj.type == ServiceConstants.SAVE_DOMAIN_INTEGRATION_TYPE_ADD) {
				if(integrationObj.googleDriveDomainList != null && !integrationObj.googleDriveDomainList.isEmpty() && integrationObj.googleDriveDomainList.size() > 0 && IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE.equalsIgnoreCase(multiDomainApp)) {
					insertOrUpdateDomainList(multiDomainApp, appInteg, integrationObj.googleDriveDomainList, EFSConstants.GOOGLEDRIVE_CLIENT_ID, EFSConstants.GOOGLEDRIVE_CLIENT_SECRET);
				}
				if(integrationObj.googleCalendarDomainList != null && !integrationObj.googleCalendarDomainList.isEmpty() && integrationObj.googleCalendarDomainList.size() > 0 && IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(multiDomainApp)) {
					insertOrUpdateDomainList(multiDomainApp, appInteg, integrationObj.googleCalendarDomainList, IntegrationConstants.GOOGLE_CALENDAR_CLIENT_ID, IntegrationConstants.GOOGLE_CALENDAR_CLIENT_SECRET);
				}
			}

			if (integrationObj.type == ServiceConstants.SAVE_DOMAIN_INTEGRATION_TYPE_REMOVE) {
				if(integrationObj.googleDriveDomainList != null && !integrationObj.googleDriveDomainList.isEmpty() && integrationObj.googleDriveDomainList.size() > 0 && IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE.equalsIgnoreCase(multiDomainApp)) {
					removeDomainFromDomainList(multiDomainApp, appInteg, integrationObj.googleDriveDomainList);
				}
				if(integrationObj.googleCalendarDomainList != null && !integrationObj.googleCalendarDomainList.isEmpty() && integrationObj.googleCalendarDomainList.size() > 0 && IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR.equalsIgnoreCase(multiDomainApp)) {
					removeDomainFromDomainList(multiDomainApp, appInteg, integrationObj.googleCalendarDomainList);
				}
			}

			if(String.isNotBlank(appInteg.Client_Id__c)) {
				if (String.isNotBlank(appInteg.Id)) {
					listToUpdate.add(appInteg);
				} else {
					listToInsert.add(appInteg);
				}
			}
		}

		logger.logDebug('ManageApplicationDao.saveDomainsIntegrationsConfig()---googleIntegrationsUpdateMap' + googleIntegrationsUpdateMap);
		if (googleIntegrationsUpdateMap != null && !googleIntegrationsUpdateMap.isEmpty()) {
			GoogleDriveService googleServiceObj = new GoogleDriveService();
			googleServiceObj.saveDomainsIntegrationsConfig(integrationObj.type, googleIntegrationsUpdateMap);
		}

		List<Schema.SObjectField> modifiedColumns = new List<Schema.SObjectField>{
			App_Integration__c.Name,
			App_Integration__c.Is_Deleted__c,
			App_Integration__c.Integration_Enabled__c,
			App_Integration__c.Client_Id__c,
			App_Integration__c.Client_Secret__c,
			App_Integration__c.Whitelist_Domain__c,
			App_Integration__c.Connected__c,
			App_Integration__c.Is_My_Drive_Enabled__c,
			App_Integration__c.Is_Shared_Drive_Enabled__c,
			App_Integration__c.Show_Open_In_Google_Drive__c,
			App_Integration__c.Org_Id__c};
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		if(!listToUpdate.isEmpty() && listToUpdate.size() > 0) {
			SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Integration__c>(listToUpdate), modifiedColumns);
		}
			
		if(!listToInsert.isEmpty() && listToInsert.size() > 0) {
			SIMPESAPI.accessController().insertAsUser(listToInsert, modifiedColumns);
		}
		logger.logDebug('listToUpdate'+ JSON.serialize(listToUpdate));
		if(integrationObj.type == ServiceConstants.SAVE_DOMAIN_INTEGRATION_TYPE_REMOVE){
			if(integrationObj.googleDriveDomainList != null && !integrationObj.googleDriveDomainList.isEmpty()){
				removeGooogleDriveDomain(integrationObj.googleDriveDomainList[0].get('domainName'));
			}
			else if(integrationObj.googleCalendarDomainList != null && !integrationObj.googleCalendarDomainList.isEmpty()){
				Boolean deleteTiles = false;
				for(App_Integration__c appInt : listToUpdate){
					if(appInt.Name.equalsIgnoreCase(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR) && appInt.Is_Deleted__c == true){
						deleteTiles = true;
					}
				}
				removeGooogleCalendarDomain(integrationObj.googleCalendarDomainList[0].get('domainName'), deleteTiles);
			}
		}
	}

	public void startGoogleMultiInstanceUpgradeFlow(ManageApplicationWrapper.GoogleManualUpgradeFlowReqWrapper reqObj) {

		if(GoogleDriveService.googleMultiDomainUpgraded()) {
			throw new SimpplrException(ERROR_GOOGLE_MULTI_INSTANCE_UPGRADE_ALREADY_DONE);
		} else {
			logger.logDebug('ManageApplicationDao.startGoogleMultiInstanceUpgradeFlow()---googleMultiDomainUpgradeStatus' + SimpplrContext.googleMultiDomainUpgradeStatus);

			String appConfigQuery = 'SELECT Id, Google_Multi_Domain_Upgrade_Status__c FROM App_Config__c LIMIT 1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<App_Config__c> listOfAppConfig = ((List<App_config__c>) SIMPESAPI.accessController().queryAsUser(appConfigQuery, null));
			if(listOfAppConfig.size() > 0) {
				App_Config__c appConfig = listOfAppConfig.get(0);
				appConfig.Google_Multi_Domain_Upgrade_Status__c = ServiceConstants.UPGRADE_STATUS_IN_PROGRESS;
				SIMPESAPI.accessController().updateAsUser(appConfig, new List<Schema.SObjectField>{
					App_Config__c.Google_Multi_Domain_Upgrade_Status__c});
			}

			List<String> chattergroupIds = new List<String>();
			List<Simpplr_Site__c> siteList = [Select id, Chatter_Group_Id__c, File_Storage_Source__c from Simpplr_Site__c where File_Storage_Source__c ='googledrive' WITH SECURITY_ENFORCED] ;
			for(Simpplr_Site__c siteObj : siteList) {
				chattergroupIds.add(siteObj.Chatter_Group_Id__c);
			}

			GoogleDriveService.startGoogleMultiInstanceUpgradeFlow(reqObj.retainGoogleGroups, chattergroupIds);
		}
	}

    /**
     * @description this is used to save upgrade status and app integration record
     */
	public void saveSharepointUpgradeConfig(){
		String appConfigQuery  = 'SELECT Id, SP_Upgrade_Status__c FROM App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];
		appConfig.SP_Upgrade_Status__c = ServiceConstants.SP_UPGRADE_STATUS_IN_PROGRESS;
		SIMPESAPI.accessController().updateAsUser(appConfig,  new List<Schema.SObjectField>{
														App_Config__c.SP_Upgrade_Status__c});
        if(!SimpplrContext.isSharepointConnected) {
            App_Integration__c appInteg = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
            appInteg.Integration_Enabled__c = true;
            appInteg.Connected__c = true;
            SIMPESAPI.accessController().updateAsUser(appInteg,  new List<Schema.SObjectField>{
                App_Integration__c.Integration_Enabled__c, App_Integration__c.Connected__c});
        }
    }
	
	public void saveSupportIntegrationsConfig(ManageApplicationWrapper.SupportIntegrationWrapper integrationObj){
    	List<App_Integration__c> listToUpdate = new List<App_Integration__c>();
    	List<App_Integration__c> listToInsert = new List<App_Integration__c>();
    	Map<String,App_Integration__c> mapOfAppIntObject= new Map<String,App_Integration__c>();
    	mapOfAppIntObject.putAll(SimpplrContext.Integrations);
		ServiceNowWrapper.SNWrapper snIntegObj = integrationObj.serviceNow;
		AtlassianWrapper atlassianIntegrationWrapperObj = integrationObj.atlassian;
    	
    	if(mapOfAppIntObject.containsKey(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW)){
    		if(snIntegObj.snEnabled == true) {

				String snKBJSON = snIntegObj.kbWrapperList != null ? JSON.serialize(snIntegObj.kbWrapperList):'';
				
				Map<String,String> dataMap = new Map<String,String>();
				if(snIntegObj.isSNTicketingDefaultSelected == false){
					dataMap.put('CustomTicketingName',snIntegObj.customSNTicketingSystemName);
				} else {
					dataMap.put('CustomTicketingName','');
				}
				if(integrationObj.serviceNow != null && integrationObj.serviceNow.snKnowledgebaseEnabled !=null && integrationObj.serviceNow.snKnowledgebaseEnabled) {
					dataMap.put('snKnowledgebaseEnabled', 'true');
				} else {
					dataMap.put('snKnowledgebaseEnabled', 'false');
				}
				if(snIntegObj.isSNKnowledgeDefaultSelected == false){
					dataMap.put('customKBName',snIntegObj.customSNKnowledgebaseName);
				} else {
					dataMap.put('customKBName','');
				}
				if(snIntegObj.isSNKnowledgebaseUrlDefaultSelected == false){
					dataMap.put('customSNKnowledgebaseUrl',snIntegObj.customSNKnowledgebaseUrl);
				} else {
					dataMap.put('customSNKnowledgebaseUrl','');
				} 
				if(integrationObj.serviceNow != null && integrationObj.serviceNow.snTicketEnabled !=null && integrationObj.serviceNow.snTicketEnabled) {
					dataMap.put('snTicketEnabled', 'true');
				} else {
					dataMap.put('snTicketEnabled', 'false');
				}
				if(integrationObj.serviceNow != null && integrationObj.serviceNow.snTicketCreationEnabled) {
					dataMap.put('snTicketCreationEnabled', 'true');
				} else {
					dataMap.put('snTicketCreationEnabled', 'false');
				}
				if(snIntegObj.isSNTicketsUrlDefaultSelected == false){
					dataMap.put('customServiceNowTicketsUrl',snIntegObj.customServiceNowTicketsUrl);
				} else {
					dataMap.put('customServiceNowTicketsUrl','');
				} 
				String dataJSON;
				if(dataMap.keySet().isEmpty() == false){
					dataJSON = JSON.serialize(dataMap);
				}
				App_Integration__c appIntegrationObj = new App_Integration__c(Id=mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Id,
																				Integration_Enabled__c=snIntegObj.snEnabled,
																				Endpoint_Url__c = snIntegObj.servicenowInstanceUrl,
																				Extra_Url_Parameters__c = snKBJSON,
																				Org_Id__c = UserInfo.getOrganizationId(),
																				Data__c = dataJSON,
																				name=IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW);
				
				if(snIntegObj.snClientId != null){
					appIntegrationObj.Client_Id__c = Utility.encryptFn(snIntegObj.snClientId);
				}																
				if(snIntegObj.snClientSecret != null){
					appIntegrationObj.Client_Secret__c = Utility.encryptFn(snIntegObj.snClientSecret);
				}
				listToUpdate.add(appIntegrationObj);										
    		} else {
				disableServiceNowNotificationsInAWS();
				App_Integration__c appintegObj = new App_Integration__c(Id = mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Id);
				appintegObj.App_Access_Token__c = null;
				appintegObj.App_Refresh_Token__c = null;
				appintegObj.Is_Deleted__c = true;
				appintegObj.Extra_Url_Parameters__c = null;
				appintegObj.Endpoint_Url__c = null;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        		SIMPESAPI.accessController().updateAsUser(appintegObj, new List<Schema.SObjectField>{
        			App_Integration__c.App_Access_Token__c, App_Integration__c.App_Refresh_Token__c, App_Integration__c.Is_Deleted__c, App_Integration__c.Extra_Url_Parameters__c, App_Integration__c.Endpoint_Url__c});
				
				Database.executeBatch(new BatchDeleteIntegrationRecords(new List<String>{IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW}),2000);
				
				
    		}
			
    	} else if((snIntegObj.snEnabled == true) &&
						 String.isNotBlank(snIntegObj.snClientId) &&
						 	String.isNotBlank(snIntegObj.snClientSecret)) {
			String snKBJSON = snIntegObj.kbWrapperList != null ? JSON.serialize(snIntegObj.kbWrapperList):'';
			Map<String,String> dataMap = new Map<String,String>();
			
			if(snIntegObj.isSNTicketingDefaultSelected == false){
				dataMap.put('CustomTicketingName',snIntegObj.customSNTicketingSystemName);
			} else {
				dataMap.put('CustomTicketingName','');
			}
			if(integrationObj.serviceNow != null) {
				dataMap.put('snKnowledgebaseEnabled', 'true');
				dataMap.put('snTicketEnabled', 'true');
			} else {
				dataMap.put('snKnowledgebaseEnabled', 'false');
				dataMap.put('snTicketEnabled', 'false');
			}
			if(snIntegObj.isSNKnowledgeDefaultSelected == false){
				dataMap.put('customKBName',snIntegObj.customSNKnowledgebaseName);
			} else {
				dataMap.put('customKBName','');
			}
			if(integrationObj.serviceNow != null ) {
				dataMap.put('snTicketCreationEnabled', 'true');
			} else {
				dataMap.put('snTicketCreationEnabled', 'false');
			}
			if(snIntegObj.isSNKnowledgebaseUrlDefaultSelected == false){
				dataMap.put('customSNKnowledgebaseUrl',snIntegObj.customSNKnowledgebaseUrl);
			} else {
				dataMap.put('customSNKnowledgebaseUrl','');
			}
			if(snIntegObj.isSNTicketsUrlDefaultSelected == false){
				dataMap.put('customServiceNowTicketsUrl',snIntegObj.customServiceNowTicketsUrl);
			} else {
				dataMap.put('customServiceNowTicketsUrl','');
			}
				
			String dataJSON;
			if(dataMap.keySet().isEmpty() == false){
				dataJSON = JSON.serialize(dataMap);
			}			
			Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
	        Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
	        Blob blobClientId = Blob.valueOf(snIntegObj.snClientId);
	        String snClientIdEncoded = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, blobClientId));
			Blob blobClientSecret = Blob.valueOf(snIntegObj.snClientSecret);
	        String snClientSecretEncoded = EncodingUtil.base64Encode(Crypto.encrypt('AES128', cryptoKey, vector, blobClientSecret));
				
			listToInsert.add(new App_Integration__c(Integration_Enabled__c=snIntegObj.snEnabled,
    												Client_Id__c=snClientIdEncoded,
    												Client_Secret__c=snClientSecretEncoded,
													Endpoint_Url__c = snIntegObj.servicenowInstanceUrl,
													Extra_Url_Parameters__c = snKBJSON,
    												Org_Id__c = UserInfo.getOrganizationId(),
													Data__c = dataJSON,
    												name=IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW));
													
		}
		
		if(mapOfAppIntObject.containsKey(IntegrationConstants.INTEGRATION_TYPE_SALESFORCE)){
			if(snIntegObj.snNotificationsEnabled == false || snIntegObj.snTicketEnabled == false) {
				disableServiceNowNotificationsInAWS();			
				listToUpdate.add(new App_Integration__c(Id=mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_SALESFORCE).Id,
													Is_Deleted__c = true));
			}
													
		} else if(snIntegObj.snNotificationsEnabled && snIntegObj.snTicketEnabled){
			enableServiceNowNotificationsInAWS();
			listToInsert.add(new App_Integration__c(Integration_Enabled__c=snIntegObj.snNotificationsEnabled,
													Org_Id__c = UserInfo.getOrganizationId(),
													Client_Id__c = 'Dummy',
													Client_Secret__c = 'Dummy',
													name=IntegrationConstants.INTEGRATION_TYPE_SALESFORCE));
		}

		if(mapOfAppIntObject.containsKey(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN)){
    		if(atlassianIntegrationWrapperObj !=null && atlassianIntegrationWrapperObj.atlassianEnabled == true &&
						 String.isNotBlank(atlassianIntegrationWrapperObj.atlassianConnectedAs)) {
				String confluenceKBJSON = atlassianIntegrationWrapperObj.confluenceEnabled == true  && atlassianIntegrationWrapperObj.confluenceKBWrapperList != null ? JSON.serialize(atlassianIntegrationWrapperObj.confluenceKBWrapperList):'';
				Map<String,String> dataMap = new Map<String,String>();
				String dataJSON;
				String customConfluenceKBName = atlassianIntegrationWrapperObj.customConfluenceKnowledgeBaseName;
				if(String.isNotBlank(SimpplrContext.atlassianUserEmail)) {
					if(atlassianIntegrationWrapperObj.isConfluenceKnowledgeDefaultSelected == false){
						if(customConfluenceKBName.length() > 25 || 'Confluence knowledge base'.equalsIgnoreCase(customConfluenceKBName) || customConfluenceKBName.length() < 1 || !Pattern.matches('^([a-zA-Z0-9- _$#&@{}])*$', customConfluenceKBName)) {
							String commonErrorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'common.error_message');
							throw new SimpplrException(commonErrorMessage); 
						} else {
							dataMap.put('customKBName',atlassianIntegrationWrapperObj.customConfluenceKnowledgeBaseName);
						}
					} else {
						dataMap.put('customKBName','');
					} 
					if(atlassianIntegrationWrapperObj.isConfluenceKnowledgeSpacesSelected == true){
						dataMap.put('confluenceSpaceDefault','true');
					} else {
						dataMap.put('confluenceSpaceDefault','false');
						dataMap.put('confluenceKBWrapperList',JSON.serialize(atlassianIntegrationWrapperObj.confluenceKBWrapperList));
					}

					if(dataMap.keySet().isEmpty() == false){
						dataJSON = JSON.serialize(dataMap);
					}
				}

																	
				listToUpdate.add(new App_Integration__c(Id=mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Id,
													Integration_Enabled__c=atlassianIntegrationWrapperObj.atlassianEnabled,
													Endpoint_Url__c = atlassianIntegrationWrapperObj.atlassianInstanceUrl,
													Show_Atlassian_VPN_Message__c = atlassianIntegrationWrapperObj.showAtlassianVPNMessage <> NULL ? atlassianIntegrationWrapperObj.showAtlassianVPNMessage :false,
													Extra_Url_Parameters__c = confluenceKBJSON,	
    												Org_Id__c = UserInfo.getOrganizationId(),
													Data__c = dataJSON,
    												name=IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN,
													Client_Id__c = 'DUMMY'));
			} else if(atlassianIntegrationWrapperObj !=null && atlassianIntegrationWrapperObj.atlassianEnabled == true &&
			String.isBlank(atlassianIntegrationWrapperObj.atlassianConnectedAs)) { 
				App_Integration__c appintegObj = new App_Integration__c(Id = mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Id);
				appintegObj.Endpoint_Url__c = atlassianIntegrationWrapperObj.atlassianInstanceUrl;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
        		SIMPESAPI.accessController().updateAsUser(appintegObj, new List<Schema.SObjectField>{
        			 App_Integration__c.Endpoint_Url__c});
			} else {
				disconnectAtlassianAdmin();
        	}
		} else if(atlassianIntegrationWrapperObj !=null && atlassianIntegrationWrapperObj.atlassianEnabled == true) {
				listToInsert.add(new App_Integration__c(Integration_Enabled__c=atlassianIntegrationWrapperObj.atlassianEnabled,
														Org_Id__c = UserInfo.getOrganizationId(),
														Endpoint_Url__c = atlassianIntegrationWrapperObj.atlassianInstanceUrl,
														Show_Atlassian_VPN_Message__c = atlassianIntegrationWrapperObj.showAtlassianVPNMessage <> NULL ? atlassianIntegrationWrapperObj.showAtlassianVPNMessage :false,
														name=IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN,
														Client_Id__c = 'DUMMY',Client_Secret__c = 'DUMMY'));
		}
	
    	if(listToUpdate.size()>0){
    		update listToUpdate;
    	}
    	
    	if(listToInsert.size()>0){
    		insert listToInsert;
    	}
	}

	public void disableServiceNowNotifications(){			
		disableServiceNowNotificationsInAWS();
		App_Integration__c appintegObj = new App_Integration__c(Id = SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_SALESFORCE).Id);
				appintegObj.Is_Deleted__c = true;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
				SIMPESAPI.accessController().updateAsUser(appintegObj, new List<Schema.SObjectField>{App_Integration__c.Is_Deleted__c});
	}

	public void saveMessagingIntegrationsConfig(ManageApplicationWrapper.MessagingIntegrationWrapper integrationObj){
    	List<App_Integration__c> listToUpdate = new List<App_Integration__c>();
    	List<App_Integration__c> listToInsert = new List<App_Integration__c>();
    	Map<String,App_Integration__c> mapOfAppIntObject= new Map<String,App_Integration__c>();
		HttpResponse res = new HttpResponse();
		HttpResponse slackInteRespone = new HttpResponse();
		SlackHelper slackHelperObj = new SlackHelper();
		Boolean isRemoveSlackPeopleAndSiteIntegrations = false;
    	mapOfAppIntObject.putAll(SimpplrContext.Integrations);
    	
    	if(mapOfAppIntObject.containsKey(IntegrationConstants.INTEGRATION_TYPE_SLACK)){
			App_Integration__c slackInteObj;
			Boolean isSlackUpgraded = mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Is_Slack_Upgraded__c;
    		if(integrationObj.slackIntegrationEnabled == true) {
    			slackInteObj = new App_Integration__c(Id=mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Id,
    													Integration_Enabled__c=integrationObj.slackIntegrationEnabled, 
    													Client_Id__c=IntegrationConstants.SLACK_CLIENT_ID,
    													Client_Secret__c=IntegrationConstants.SLACK_CLIENT_SECRET,
    													Org_Id__c = UserInfo.getOrganizationId(),
    													name=IntegrationConstants.INTEGRATION_TYPE_SLACK);
				slackInteObj.Custom_Name_Enabled__c = integrationObj.slackCustomNameIconEnabled != null ? integrationObj.slackCustomNameIconEnabled : false;
				slackInteObj.Custom_App_Name__c = integrationObj.slackAppName != null ? integrationObj.slackAppName : '';
				slackInteObj.Custom_App_Icon_Url__c = integrationObj.slackAppIconConfig != null ? integrationObj.slackAppIconConfig : '';	
    		} else {
				slackInteObj = new App_Integration__c(Id=mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_SLACK).Id,
    													Integration_Enabled__c=integrationObj.slackIntegrationEnabled, App_installed__c = false,
														Custom_Name_Enabled__c = false, Custom_App_Name__c = '', Custom_App_Icon_Url__c = '');
    		}
			if (SimpplrContext.isSlackPhase2FeatureEnabled && isSlackUpgraded) {//slack is enabled in phase2
				boolean slackUnfurlAppInstalled = integrationObj.isSlackUnfurlAppInstalled == null ? false : integrationObj.isSlackUnfurlAppInstalled;
				if(integrationObj.slackIntegrationEnabled == false) {//deleting user connection when app connection disabled
					HttpResponse response = new SlackHelper().processSlackDisconnectionAtZeus(IntegrationConstants.INTEGRATION_SLACK_UNFURL, IntegrationConstants.INTEGRATION_FLOW_APP, slackUnfurlAppInstalled, true);
				}
				Map<String, Object> mapOfSlackConfig = new Map<String, Object>();
				mapOfSlackConfig.put('slackEnabledFlag', integrationObj.slackIntegrationEnabled);
				mapOfSlackConfig.put('slackUnfurlFlag', slackUnfurlAppInstalled);
				mapOfSlackConfig.put('customAppName', slackInteObj.Custom_App_Name__c);
				if(String.isNotBlank(slackInteObj.Custom_App_Icon_Url__c)) {
					//extracting icon url from Json string Custom_App_Icon_Url__c = '{"url":"https://www.slack.com/icon-image","size":"2MB","name":"file"}'
					Map<String,Object> mapOfSlackIconDetails = (Map<String,Object>)JSON.deserializeUntyped(slackInteObj.Custom_App_Icon_Url__c);
					mapOfSlackConfig.put('customAppIconUrl', mapOfSlackIconDetails.get('url'));
				} else {
					mapOfSlackConfig.put('customAppIconUrl', '');
				}
				slackInteRespone = slackHelperObj.saveSlackManageAppInfo(mapOfSlackConfig);
				if (slackInteRespone.getStatusCode() == 200) {
					listToUpdate.add(slackInteObj);
					isRemoveSlackPeopleAndSiteIntegrations = true;
				}
			} else {//slack is enabled in phase1
				listToUpdate.add(slackInteObj);
				if(integrationObj.slackIntegrationEnabled == false) {
					isRemoveSlackPeopleAndSiteIntegrations = true;
				}
			}
    	} else if(integrationObj.slackIntegrationEnabled == true) {
    		App_Integration__c slackInteObj = new App_Integration__c(Integration_Enabled__c=integrationObj.slackIntegrationEnabled,
    												Client_Id__c=IntegrationConstants.SLACK_CLIENT_ID,
    												Client_Secret__c=IntegrationConstants.SLACK_CLIENT_SECRET,
    												Org_Id__c = UserInfo.getOrganizationId(),
    												name=IntegrationConstants.INTEGRATION_TYPE_SLACK);
			slackInteObj.Custom_Name_Enabled__c = integrationObj.slackCustomNameIconEnabled != null ? integrationObj.slackCustomNameIconEnabled : false;
			slackInteObj.Custom_App_Name__c = integrationObj.slackAppName != null ? integrationObj.slackAppName : '';
			slackInteObj.Custom_App_Icon_Url__c = integrationObj.slackAppIconConfig != null ? integrationObj.slackAppIconConfig : '';
			if (SimpplrContext.isSlackPhase2FeatureEnabled) {
				slackInteObj.Is_Slack_Upgraded__c = true;
				boolean slackUnfurlAppInstalled = integrationObj.isSlackUnfurlAppInstalled == null ? false : integrationObj.isSlackUnfurlAppInstalled;
				Map<String, Object> mapOfSlackConfig = new Map<String, Object>();
				mapOfSlackConfig.put('slackEnabledFlag', integrationObj.slackIntegrationEnabled);
				mapOfSlackConfig.put('slackUnfurlFlag', slackUnfurlAppInstalled);
				mapOfSlackConfig.put('customAppName', slackInteObj.Custom_App_Name__c);
				if(String.isNotBlank(slackInteObj.Custom_App_Icon_Url__c)) {
					//extracting icon url from Json string Custom_App_Icon_Url__c = '{"url":"https://www.slack.com/icon-image","size":"2MB","name":"file"}'
					Map<String,Object> mapOfSlackIconDetails = (Map<String,Object>)JSON.deserializeUntyped(slackInteObj.Custom_App_Icon_Url__c);
					mapOfSlackConfig.put('customAppIconUrl', mapOfSlackIconDetails.get('url'));
				} else {
					mapOfSlackConfig.put('customAppIconUrl', '');
				}
				slackInteRespone = slackHelperObj.saveSlackManageAppInfo(mapOfSlackConfig);
				if (slackInteRespone.getStatusCode() == 200) {
					listToInsert.add(slackInteObj);
				}
			} else {
				listToInsert.add(slackInteObj);
			}
    	}
        if(SimpplrContext.isFeatureMicrosoftTeamsEnabled) {
			MicrosoftTeamsHelper microsoftTeamsHelperObj = new MicrosoftTeamsHelper();
			HttpResponse appInstalledResponse;
            if(mapOfAppIntObject.containsKey(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS)){
				App_Integration__c msTeamInteObj;
                if(integrationObj.microsoftTeamsIntegrationEnabled == true) {
                    msTeamInteObj = new App_Integration__c(Id=mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS).Id,
                                                            Integration_Enabled__c=integrationObj.microsoftTeamsIntegrationEnabled, 
                                                            Client_Id__c=IntegrationConstants.MICROSOFT_TEAMS_CLIENT_ID,
                                                            Client_Secret__c=IntegrationConstants.MICROSOFT_TEAMS_CLIENT_SECRET,
                                                            Org_Id__c = UserInfo.getOrganizationId(),
                                                            name=IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS);
					
					msTeamInteObj.Alerts_For_App_Enabled__c = integrationObj.isAlertsForTeamsEnabled != null ? integrationObj.isAlertsForTeamsEnabled : false;
                } else {
					msTeamInteObj = new App_Integration__c(Id=mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS).Id,
                                                            Integration_Enabled__c=integrationObj.microsoftTeamsIntegrationEnabled,
															Alerts_For_App_Enabled__c = false);
                }

				if (SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2) {//ms teams is enabled in phase2
					msTeamInteObj.Integration_Enabled__c = integrationObj.microsoftTeamsIntegrationEnabled && mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS).Connected__c;
					res = microsoftTeamsHelperObj.saveMicrosoftTeamsManageAppInfo(integrationObj.microsoftTeamsIntegrationEnabled);
					if (res.getStatusCode() == 200){
						listToUpdate.add(msTeamInteObj);
					}
					if(integrationObj.microsoftTeamsIntegrationEnabled == false && res.getStatusCode() == 200) {
						microsoftTeamsHelperObj.processMSTeamsAdminDisconnect(false);
					}
				} else {//ms teams is enabled in phase1
					listToUpdate.add(msTeamInteObj);
					if(integrationObj.microsoftTeamsIntegrationEnabled == false) {
						microsoftTeamsHelperObj.updateAndDeletePeopleAndSiteRecords();
					}
				}
            } else if(integrationObj.microsoftTeamsIntegrationEnabled == true) {
                App_Integration__c msTeamInteObj = new App_Integration__c(Integration_Enabled__c=integrationObj.microsoftTeamsIntegrationEnabled,
                                                        Client_Id__c=IntegrationConstants.MICROSOFT_TEAMS_CLIENT_ID,
                                                        Client_Secret__c=IntegrationConstants.MICROSOFT_TEAMS_CLIENT_SECRET,
                                                        Org_Id__c = UserInfo.getOrganizationId(),
                                                        name=IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS);
				
				msTeamInteObj.Alerts_For_App_Enabled__c = integrationObj.isAlertsForTeamsEnabled != null ? integrationObj.isAlertsForTeamsEnabled : false;
				// send info to Microsoft Teams MS
				if (SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2) {
					Boolean isAppManagerConnected = mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS) != null ? mapOfAppIntObject.get(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS).Connected__c : false;
					msTeamInteObj.Integration_Enabled__c = integrationObj.microsoftTeamsIntegrationEnabled && isAppManagerConnected;
					res = microsoftTeamsHelperObj.saveMicrosoftTeamsManageAppInfo(integrationObj.microsoftTeamsIntegrationEnabled);
					if(res.getStatusCode() == 200) {
						listToInsert.add(msTeamInteObj);
					}
				} else {
					listToInsert.add(msTeamInteObj);
				}
            }
        } else {
            String appConfigQuery  = 'SELECT Id,Microsoft_Teams_Integration_Enabled__c FROM App_Config__c limit 1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null))[0];

            appConfig.Microsoft_Teams_Integration_Enabled__c = integrationObj.microsoftTeams;
                    
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(appConfig,  new List<Schema.SObjectField>{
                                                            App_Config__c.Microsoft_Teams_Integration_Enabled__c});
        }
		
		if(isRemoveSlackPeopleAndSiteIntegrations) {
			slackHelperObj.updateAndDeletePeopleAndSiteRecords(true);
		}
		if(listToUpdate.size() > 0) {
			update listToUpdate;
		}
		if (listToInsert.size() > 0){
			insert listToInsert;
		}
    }
	
	public void disconnectServiceNowAdmin(){
		App_Integration__c appintegObj = new App_Integration__c(Id = SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW).Id);
		appintegObj.App_Access_Token__c = null;
		appintegObj.App_Refresh_Token__c = null;
		appintegObj.Is_Deleted__c = true;
		appintegObj.Extra_Url_Parameters__c = null;
		appintegObj.Endpoint_Url__c = null;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appintegObj, new List<Schema.SObjectField>{
			App_Integration__c.App_Access_Token__c, App_Integration__c.App_Refresh_Token__c, App_Integration__c.Is_Deleted__c, App_Integration__c.Extra_Url_Parameters__c, App_Integration__c.Endpoint_Url__c});
		
		Database.executeBatch(new BatchDeleteIntegrationRecords(new List<String>{IntegrationConstants.INTEGRATION_TYPE_SERVICE_NOW}),2000);	
	}

	public void disconnectAtlassianAdmin(){

		String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/atlassian?action=disconnectatlassianadmin';
		Map<String, Object> mapOfRequestParam = new Map<String, Object>();
		mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
		mapOfRequestParam.put('peopleId', UserContext.peopleId);
		HTTPResponse res = Utility.getResponseFromAWS(endpointURL, mapOfRequestParam);
				

		App_Integration__c appintegObj = new App_Integration__c(Id = SimpplrContext.integrations.get(IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN).Id);
		appintegObj.Is_Deleted__c = true;
		appintegObj.Extra_Url_Parameters__c = null;
		appintegObj.Endpoint_Url__c = null;
		appintegObj.External_id__c = null;
		appintegObj.App_Refresh_Token__c = null;
		appintegObj.App_Access_Token__c = null;
		appintegObj.User_email__c = null;
		appintegObj.User_name__c = null;
		appintegObj.Refresh_Token_Expiration_Datetime__c = null;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().updateAsUser(appintegObj, new List<Schema.SObjectField>{
			App_Integration__c.User_name__c,App_Integration__c.User_email__c,App_Integration__c.App_Access_Token__c, App_Integration__c.App_Refresh_Token__c, App_Integration__c.Is_Deleted__c, App_Integration__c.Extra_Url_Parameters__c, App_Integration__c.Endpoint_Url__c,App_Integration__c.External_id__c, App_Integration__c.Refresh_Token_Expiration_Datetime__c});
		
		Database.executeBatch(new BatchDeleteIntegrationRecords(new List<String>{IntegrationConstants.INTEGRATION_TYPE_ATLASSIAN}),2000);	
	}

	/**
	 * @description method to disconnect Active Directory admin integration
	 */
	public void disconnectActiveDirectory(){
    	logger.logDebug('ManageApplication.disconnectActiveDirectory()');

		if(UserContext.isUserAppModerator){
			String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/ad-oauth-manager?action=disconnectactivedirectoryadmin';
			Map<String, Object> mapOfRequestParam = new Map<String, Object>();
			mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
			mapOfRequestParam.put('peopleId', UserContext.peopleId);
			HTTPResponse res = Utility.getResponseFromAWS(endpointURL, mapOfRequestParam);

			if(res.getStatusCode() == 200){
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
				String appIntQuery = 'SELECT Id, External_Id__c, App_Access_Token__c, App_Refresh_Token__c, Token_Type__c, User_Email__c, User_Name__c, Access_Token_Expiration_Datetime__c, Access_Token_Expiry__c, Integration_Enabled__c, Connected__c,   Client_Id__c, Client_Secret__c FROM App_Integration__c WHERE Name = \'activedirectory\' AND Is_Deleted__c = false LIMIT 1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<App_integration__c> appIntList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, null);

				if(!appIntList.isEmpty()){
					appIntList[0].External_Id__c = null;
					appIntList[0].App_Access_Token__c = '';
					appIntList[0].App_Refresh_Token__c = '';
					appIntList[0].Token_Type__c = '';
					appIntList[0].User_Name__c = '';
					appIntList[0].Access_Token_Expiration_Datetime__c = null;
					appIntList[0].Access_Token_Expiry__c = null;
					appIntList[0].Integration_Enabled__c = false;
					appIntList[0].Connected__c = false;
					appIntList[0].Client_Id__c = 'null';
					appIntList[0].Client_Secret__c = 'null';
					
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, App_Integration__c>(appIntList), 
															new List<Schema.SObjectField>{
																App_Integration__c.External_Id__c,
																App_Integration__c.App_Access_Token__c,
																App_Integration__c.App_Refresh_Token__c,
																App_Integration__c.Token_Type__c,
																App_Integration__c.User_Name__c,
																App_Integration__c.Access_Token_Expiration_Datetime__c,
																App_Integration__c.Access_Token_Expiry__c,
																App_Integration__c.Integration_Enabled__c,
																App_Integration__c.Connected__c,
																App_Integration__c.Client_Id__c,
																App_Integration__c.Client_Secret__c
																});						    		
				}        		
			} else {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}

			
		} else {
			throw new SimpplrException(ServiceConstants.ERROR_403);
		}
	}

	public void enableServiceNowNotificationsInAWS(){
		try{
			HttpRequest reqObj = new HttpRequest();
			reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/api-proxy/simpplr-integration-service?action=enableServiceNowNotifications');
			reqObj.setHeader('content-type','application/json');			
			reqObj.setHeader('accept', 'application/json');
			reqObj.setMethod('POST');
			reqObj.setBody('{"isSandbox":'+SimpplrContext.isSandbox+',"isTest":'+SimpplrContext.isTestOrg+',"peopleId":"'+UserContext.peopleId+'","orgId":"'+SimpplrContext.simpplrOrgId+'","baseUrl":"'+SimpplrContext.salesforceBaseUrl+'","instanceUrl":"'+SimpplrContext.salesforceHost+'","snInstanceUrl":"'+SimpplrContext.serviceNowInstanceUrl+'"}');
			Http httpObj = new Http();
			HTTPResponse resObj = httpObj.send(reqObj);
			logger.logDebug('ManageApplicationDao.enableServiceNowNotificationsInAWS :'+resObj.getBody());
		} catch(Exception ex){
			logger.logError('ManageApplicationDao.enableServiceNowNotificationsInAWS error:'+ex);
		}
	}

	public static void deleteLinkedFoldersByUser(String userId, String efsType){
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', efsType);
		soqlParamMap.put('soqlParam2', userId);
		String folderQuery = 'SELECT Id , Is_Deleted__c  from Folder__c WHERE Is_Deleted__c = false AND Type__c=:soqlParam1 AND OwnerId=:soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolderToBeDeleted = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		for(Folder__c folderObj : listOfFolderToBeDeleted) {
			folderObj.Is_Deleted__c = true;
		}
		if(!listOfFolderToBeDeleted.isEmpty()) {
			deleteAWSRecordForFolder(null, null, null, null, efsType);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,Folder__c>(listOfFolderToBeDeleted), 
													new List<Schema.SObjectField>{
															Folder__c.Is_Deleted__c});
		}
	}

	public static void deleteAWSRecordForFolder(String siteId, String driveId, String driveItemId, String userName, String storageProvider){
		
		try{
			String simpDri = Utility.externalRequestAuthToken() + ' '
                    			+ SimpplrContext.simpplrOrgId.substring(0, 15) + ' '
								+ UserContext.userId.substring(0, 15);
			
			HttpRequest reqObj = new HttpRequest();
			if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(storageProvider)){
				reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint + '/spodbc/search-odb?action=removelinkeditem');
			} else {
				reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint + '/spodbc/search-sp?action=removelinkeditem'); 
			}
			reqObj.setTimeout(60000);
			reqObj.setHeader('content-type','application/json');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setHeader('simpplr-dri', simpDri);
			reqObj.setMethod('POST');

			Map<String, String> requestMap = new Map<String, String>();
			requestMap.put('orgId', UserInfo.getOrganizationId());
			requestMap.put('simpplrSiteId', siteId);
			requestMap.put('driveId', driveId);
			requestMap.put('folderId', driveItemId);
			requestMap.put('provider', storageProvider);
			requestMap.put('userId', UserContext.userId);
			requestMap.put('removeAllForUser','true');
			reqObj.setBody(Json.serialize(requestMap));

			logger.logDebug('createAWSRecordForFolder()----Request Body----' + reqObj.getBody());
			
			Http httpObj = new Http();
			HTTPResponse resObj = httpObj.send(reqObj);
			
			logger.logDebug('createAWSRecordForFolder()----Response Body----' + resObj.getBody());
			if (resObj.getStatusCode()== 200) {
				String resBodyJSON = resObj.getBody();
				String resHeaderJSON = resObj.getHeader('headerData');
				logger.logDebug('createAWSRecordForFolder()----Response----' + resBodyJSON);
			} else {
				throw new EFSException('Folder Linking Error AWS');	
			}

		} catch(Exception ex){
			logger.logError(' Exception:',ex);
			throw new EFSException('Folder Linking Error AWS', ex.getMessage());	
		}
	}

	public void disableServiceNowNotificationsInAWS(){
		try{
			HttpRequest reqObj = new HttpRequest();
			reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/api-proxy/simpplr-integration-service?action=disableServiceNowNotifications');
			reqObj.setHeader('content-type','application/json');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setMethod('POST');
			reqObj.setBody('{"orgId":"'+SimpplrContext.simpplrOrgId+'"}');
			Http httpObj = new Http();
			HTTPResponse resObj = httpObj.send(reqObj);
			logger.logDebug('ManageApplicationDao.disableServiceNowNotificationsInAWS :'+resObj.getBody());
		} catch(Exception ex){
			logger.logError('ManageApplicationDao.disableServiceNowNotificationsInAWS error:'+ex);
		}
	}

	public static void auditUserSyncProvSource(Boolean isSyncing, String newSource, String oldSource){

		newSource = String.isBlank(newSource) ? '' : newSource;
		oldSource = String.isBlank(oldSource) ? '' : oldSource;

		// Avoid creating records if new and old source values are same.
		if(newSource.equalsIgnoreCase(oldSource) == false){
			
			String objectName = isSyncing ? 'User Sync' : 'User Prov';
			Audit_Trail__c auditTrailObj = new Audit_Trail__c(
				Object_Name__c = objectName,
				Created_By__c = UserContext.peopleId,
				New_Value__c = newSource,
				Old_Value__c = oldSource,
				Content__c = null,
				People__c = null,
				Segment__c = null,
				Site__c = null
			);

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().insertAsUser(auditTrailObj, new List<Schema.SObjectField>{
																			Audit_Trail__c.Object_Name__c,
																			Audit_Trail__c.Created_By__c,
																			Audit_Trail__c.New_Value__c,
																			Audit_Trail__c.Old_Value__c,
																			Audit_Trail__c.Content__c,
																			Audit_Trail__c.Segment__c,
																			Audit_Trail__c.Site__c});

		}
	}

	public static void logUserSyncProvStatus(String status, String sourceInfo){

		Logs__c logsObj = new Logs__c(
			Log_Data__c = status,
			Log_Type__c = 'INFO',
			Source_Info__c = sourceInfo,
			Data_Counter__c = 0,
			Is_Deleted__c = false,
			Unique_Token__c = null
		);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(logsObj, new List<Schema.SObjectField>{
																		Logs__c.Log_Data__c,
																		Logs__c.Log_Type__c,
																		Logs__c.Source_Info__c,
																		Logs__c.Data_Counter__c,
																		Logs__c.Is_Deleted__c,
																		Logs__c.Unique_Token__c});

	}

	public static void sendProvisioningInfoToAWS(ManageApplicationWrapper.UserProvisioningWrapper userProvisioningObj){
		String requestId = UserInfo.getOrganizationId() + '-' + UserInfo.getUserId() + '-' + System.currentTimeMillis();
		HttpRequest reqObj = new HttpRequest();
		reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/people-data/configure-simpplr-people-service');
		reqObj.setTimeout(60000);
		reqObj.setHeader('content-type','application/json');
		reqObj.setHeader('accept', 'application/json');
		//reqObj.setHeader('x-simpplr-request-id', requestId);
		reqObj.setHeader('simpplr-dri', Utility.getSimpDri());
		reqObj.setMethod('POST');
		Map<String, Object> requestMap = new Map<String, Object>();
		Map<String, Object> requestMap1 = new Map<String, Object>();
		Map<String, Object> mapOfRequestParam = new Map<String,Object>();
		mapOfRequestParam.put('action','saveconfigprovision');
		mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
		mapOfRequestParam.put('receiverEmail',UserInfo.getUserEmail());
		mapOfRequestParam.put('appName', SimpplrContext.applicationName);
		mapOfRequestParam.put('source', 'provisioning');
		if(userProvisioningObj != null) {
			if(userProvisioningObj.deactiveUsers == 'true'){
				requestMap.put('user_deprovisioning','1');
				requestMap.put('user_deprovisioning_identifier',userProvisioningObj.userDeprovisioningIdentifier);
			} else {
				requestMap.put('user_deprovisioning','0');
			}
			if(userProvisioningObj.createNewUser == 'true'){
				requestMap.put('user_provisioning','1');
				requestMap.put('manager_identifier',userProvisioningObj.managerUniqueIdentifier);
				requestMap.put('user_provisioning_identifier','username');
				requestMap1.put('timezone',userProvisioningObj.timezoneIso);
				requestMap1.put('language',userProvisioningObj.languageType.replace('-','_'));
				requestMap1.put('profile',userProvisioningObj.profileType);
				requestMap1.put('locale',userProvisioningObj.localeType);   
				requestMap.put('default',requestMap1);
				List<String> provisioningFields = new List<String>();
				if(userProvisioningObj.firstName == true){provisioningFields.add('first_name');}
				if(userProvisioningObj.lastName == true){provisioningFields.add('last_name');}
				if(userProvisioningObj.userTitle == true){provisioningFields.add('job_title');}
				if(userProvisioningObj.birthDate == true){provisioningFields.add('birthday');}
				if(userProvisioningObj.joiningDate == true){provisioningFields.add('hire_date');}
				if(userProvisioningObj.about == true){provisioningFields.add('about');}
				if(userProvisioningObj.username == true){provisioningFields.add('username');}
				if(userProvisioningObj.employeeNumber == true){provisioningFields.add('employee_number');}
				if(userProvisioningObj.companyName == true){provisioningFields.add('company');}
				if(userProvisioningObj.division == true){provisioningFields.add('division');}
				if(userProvisioningObj.department == true){provisioningFields.add('department');}
				if(userProvisioningObj.manager == true){provisioningFields.add('manager_unique_identifier');}
				if(userProvisioningObj.locale == true){provisioningFields.add('locale');}
				if(userProvisioningObj.language == true){provisioningFields.add('language');}
				if(userProvisioningObj.timezone == true){provisioningFields.add('time_zone');}
				if(userProvisioningObj.profile == true){provisioningFields.add('profile');}
				if(userProvisioningObj.phone == true){provisioningFields.add('phone');}
				if(userProvisioningObj.phoneExtension == true){provisioningFields.add('phone_extension');}
				if(userProvisioningObj.mobilePhone == true){provisioningFields.add('mobile_phone');}
				if(userProvisioningObj.userEmail == true){provisioningFields.add('email');}
				if(userProvisioningObj.street == true){provisioningFields.add('street');}
				if(userProvisioningObj.city == true){provisioningFields.add('city');}
				if(userProvisioningObj.state == true){provisioningFields.add('state');}
				if(userProvisioningObj.country == true){provisioningFields.add('country');}
				if(userProvisioningObj.postalCode == true){provisioningFields.add('postal_code');}
				requestMap.put('federation_identifier', userProvisioningObj.federationId);
				requestMap.put('fields_to_provision',provisioningFields);
				if(userProvisioningObj.sendEmails == 'true'){
					requestMap.put('send_reset_password_emails','1');
				} else {
					requestMap.put('send_reset_password_emails','0');
				}
			} else {
				requestMap.put('user_provisioning','0');
			}
			mapOfRequestParam.put('provisionConfigJson',requestMap);
		}
		reqObj.setBody(Json.serialize(mapOfRequestParam));
		Http httpObj = new Http();
		HTTPResponse resObj = httpObj.send(reqObj);
		if(resObj.getStatusCode() == 423) {
			throw new SimpplrException(LocaleContext.getLabel(UserContext.languageLocaleKey, ERROR_PROVISIONING_IN_PROGRESS));
		} else if(resObj.getStatusCode() != 200) {
			throw new SimpplrException(resObj.getBody());
		}
		logger.logDebug('ManageApplicationDao.sendProvisioningInfoToAWS()----response body----' + resObj.getBody());
		
	}
	public static void sendSpsSyncingInfoToAWS(ManageApplicationWrapper.UserSyncingPeopleWrapper userSyncPeopleObj){
			String reqId = UserInfo.getOrganizationId() + '-' + UserInfo.getUserId() + '-' + System.currentTimeMillis();
			HttpRequest requestObj = new HttpRequest();
			requestObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/people-data/configure-simpplr-people-service');
			requestObj.setTimeout(60000);
			requestObj.setHeader('content-type','application/json');
			requestObj.setHeader('accept', 'application/json');
			requestObj.setHeader('x-simpplr-request-id', reqId);
			requestObj.setHeader('simpplr-dri', Utility.getSimpDri());
			requestObj.setMethod('POST');				
			Map<String, Object> responseAWS = new Map<String, Object>();
			Map<String, Object> mapOfRequestParam = new Map<String, Object>();
			mapOfRequestParam.put('action','saveconfigsync');
			mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
			mapOfRequestParam.put('receiverEmail',UserInfo.getUserEmail());
			mapOfRequestParam.put('appName', SimpplrContext.applicationName);
			mapOfRequestParam.put('source', 'syncing');
			if(userSyncPeopleObj != null) {
				responseAWS.put('user_identifier',userSyncPeopleObj.uniqueIdentifier);				
				if(userSyncPeopleObj.manager == true) {
					responseAWS.put('manager_identifier',userSyncPeopleObj.uniqueIdentifier);
				}
				List<String> syncingFields = new List<String>();
				if(userSyncPeopleObj.firstName == true){syncingFields.add('first_name');}
				if(userSyncPeopleObj.lastName == true){syncingFields.add('last_name');}
				if(userSyncPeopleObj.userTitle == true){syncingFields.add('job_title');}
				if(userSyncPeopleObj.birthDate == true){syncingFields.add('birthday');}
				if(userSyncPeopleObj.joiningDate == true){syncingFields.add('hire_date');}
				if(userSyncPeopleObj.aboutMe == true){syncingFields.add('about');}
				if(userSyncPeopleObj.locale == true){syncingFields.add('locale');}
				if(userSyncPeopleObj.language == true){syncingFields.add('language');}
				if(userSyncPeopleObj.timeZone == true){syncingFields.add('time_zone');}
				if(userSyncPeopleObj.companyName == true){syncingFields.add('company');}
				if(userSyncPeopleObj.userDivision == true){syncingFields.add('division');}
				if(userSyncPeopleObj.department == true){syncingFields.add('department');}
				if(userSyncPeopleObj.phone == true){syncingFields.add('phone');}
				if(userSyncPeopleObj.extension == true){syncingFields.add('phone_extension');}
				if(userSyncPeopleObj.mobilePhone == true){syncingFields.add('mobile_phone');}
				if(userSyncPeopleObj.street == true){syncingFields.add('street');}
				if(userSyncPeopleObj.city == true){syncingFields.add('city');}
				if(userSyncPeopleObj.employeeNumber == true){syncingFields.add('employee_number');}
				if(userSyncPeopleObj.state == true){syncingFields.add('state');}
				if(userSyncPeopleObj.country == true){syncingFields.add('country');}
				if(userSyncPeopleObj.postalCode == true){syncingFields.add('postal_code');}
				if(userSyncPeopleObj.manager == true){syncingFields.add('manager_unique_identifier');}
				String customFields = '';
				for (CustomProfileField a : userSyncPeopleObj.additionalFields) {
					customFields += String.valueOf(a) + '\n';
				}
				if(customFields.containsIgnoreCase('Custom_Field_1__c') == true){syncingFields.add('custom_field_1');}
				if(customFields.containsIgnoreCase('Custom_Field_2__c') == true){syncingFields.add('custom_field_2');}
				if(customFields.containsIgnoreCase('Custom_Field_3__c') == true){syncingFields.add('custom_field_3');}
				if(customFields.containsIgnoreCase('Custom_Field_4__c') == true){syncingFields.add('custom_field_4');}
				if(customFields.containsIgnoreCase('Custom_Field_5__c') == true){syncingFields.add('custom_field_5');}
				if(customFields.containsIgnoreCase('Custom_Field_6__c') == true){syncingFields.add('custom_field_6');}
				if(customFields.containsIgnoreCase('Custom_Field_7__c') == true){syncingFields.add('custom_field_7');}
				if(customFields.containsIgnoreCase('Custom_Field_8__c') == true){syncingFields.add('custom_field_8');}
				if(customFields.containsIgnoreCase('Custom_Field_9__c') == true){syncingFields.add('custom_field_9');}
				if(customFields.containsIgnoreCase('Custom_Field_10__c') == true){syncingFields.add('custom_field_10');}
				if(customFields.containsIgnoreCase('Custom_Field_11__c') == true){syncingFields.add('custom_field_11');}
				if(customFields.containsIgnoreCase('Custom_Field_12__c') == true){syncingFields.add('custom_field_12');}
				if(customFields.containsIgnoreCase('Custom_Field_13__c') == true){syncingFields.add('custom_field_13');}
				if(customFields.containsIgnoreCase('Custom_Field_14__c') == true){syncingFields.add('custom_field_14');}
				if(customFields.containsIgnoreCase('Custom_Field_15__c') == true){syncingFields.add('custom_field_15');}
				if(customFields.containsIgnoreCase('Custom_Field_16__c') == true){syncingFields.add('custom_field_16');}
				if(customFields.containsIgnoreCase('Custom_Field_17__c') == true){syncingFields.add('custom_field_17');}
				if(customFields.containsIgnoreCase('Custom_Field_18__c') == true){syncingFields.add('custom_field_18');}
				if(customFields.containsIgnoreCase('Custom_Field_19__c') == true){syncingFields.add('custom_field_19');}
				if(customFields.containsIgnoreCase('Custom_Field_20__c') == true){syncingFields.add('custom_field_20');}
				if(customFields.containsIgnoreCase('Custom_Field_21__c') == true){syncingFields.add('custom_field_21');}
				if(customFields.containsIgnoreCase('Custom_Field_22__c') == true){syncingFields.add('custom_field_22');}
				if(customFields.containsIgnoreCase('Custom_Field_23__c') == true){syncingFields.add('custom_field_23');}
				if(customFields.containsIgnoreCase('Custom_Field_24__c') == true){syncingFields.add('custom_field_24');}
				if(customFields.containsIgnoreCase('Custom_Field_25__c') == true){syncingFields.add('custom_field_25');}

				responseAWS.put('fields_to_sync',syncingFields);
				mapOfRequestParam.put('syncConfigJson', responseAWS);
			}
			requestObj.setBody(Json.serialize(mapOfRequestParam));
			Http http = new Http();
			HTTPResponse responseObj = http.send(requestObj);
			if(responseObj.getStatusCode() == 423) {
				throw new SimpplrException(LocaleContext.getLabel(UserContext.languageLocaleKey, ERROR_SYNCING_IN_PROGRESS));
			} else if(responseObj.getStatusCode() != 200) {
				throw new SimpplrException(responseObj.getBody());
			}
			logger.logDebug('ManageApplicationDao.sendSpsSyncingInfoToAWS :'+responseObj.getStatusCode() + responseObj.getBody());
	}

	public ManageApplicationWrapper.UKGUserFieldConfig getUKGUserFieldConfig() {
		ManageApplicationWrapper.UKGUserFieldConfig fieldsDataWrapper = new ManageApplicationWrapper.UKGUserFieldConfig();
		String reqId = UserInfo.getOrganizationId() + '-' + UserInfo.getUserId() + '-' + System.currentTimeMillis();
		Map<String, String> mapRequestParam = new Map<String, String>();
		String appConfigQuery = 'SELECT PDS_UKG_Pro_Username__c, PDS_UKG_Pro_Password__c,PDS_UKG_Pro_API_Key__c,PDS_UKG_Pro_Endpoint__c from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> appConfgList = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		App_Config__c appConfigObj = appConfgList[0];

		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		Blob cipherText = EncodingUtil.base64Decode(appConfigObj.PDS_UKG_Pro_Password__c);
		String ukgProPassword = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();

		cipherText = EncodingUtil.base64Decode(appConfigObj.PDS_UKG_Pro_API_Key__c);
		String ukgProApiKey = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();

		mapRequestParam.put('ukgProUsername',appConfigObj.PDS_UKG_Pro_Username__c);
		mapRequestParam.put('ukgProPassword', ukgProPassword);
		mapRequestParam.put('ukgProApiKey', ukgProApiKey);
		mapRequestParam.put('ukgProBaseUrl',appConfigObj.PDS_UKG_Pro_Endpoint__c);
		mapRequestParam.put('action','getUserDefinedFieldConfig');
		fieldsDataWrapper = getUKGUserFieldConfigData(mapRequestParam);	
		return fieldsDataWrapper;
	}

	public ManageApplicationWrapper.UKGUserFieldConfig getUKGUserFieldConfigData(Map<String, String> mapRequestParam) {
		ManageApplicationWrapper.UKGUserFieldConfig fieldsDataWrap = new ManageApplicationWrapper.UKGUserFieldConfig();
		String reqId = UserInfo.getOrganizationId() + '-' + UserInfo.getUserId() + '-' + System.currentTimeMillis();
		HttpRequest requestObj = new HttpRequest();
		requestObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/people-data/configure-ukg-pro-sync-service');
		requestObj.setTimeout(60000);
		requestObj.setHeader('content-type','application/json');
		requestObj.setHeader('accept', 'application/json');
		requestObj.setHeader('simpplr-dri', Utility.getSimpDri());
		requestObj.setMethod('POST');
		requestObj.setBody(Json.serialize(mapRequestParam));
		Http http = new Http();
		HTTPResponse responseObj = http.send(requestObj);
		logger.logDebug('ManageApplicationDao.getUKGUserFieldConfigData :'+responseObj.getBody());
		if (responseObj.getStatusCode() == 200) {
			fieldsDataWrap = (ManageApplicationWrapper.UKGUserFieldConfig)JSON.deserialize(responseObj.getBody(),ManageApplicationWrapper.UKGUserFieldConfig.class);			
		} else if (responseObj.getStatusCode() == 401) {
			string err = LocaleContext.getLabel(UserContext.languageLocaleKey, ERROR_UKGPRO_API);
			throw new SimpplrException(err.replace('{{fieldName}}', LocaleContext.getLabel(UserContext.languageLocaleKey, UKGPRO_USERNAME)));	
		} else if (responseObj.getStatusCode() == 402) {
			string err = LocaleContext.getLabel(UserContext.languageLocaleKey, ERROR_UKGPRO_API);
			throw new SimpplrException(err.replace('{{fieldName}}', LocaleContext.getLabel(UserContext.languageLocaleKey, UKGPRO_PASSWORD)));		
		} else if (responseObj.getStatusCode() == 404) {
			string err = LocaleContext.getLabel(UserContext.languageLocaleKey, ERROR_UKGPRO_API);
			throw new SimpplrException(err.replace('{{fieldName}}', LocaleContext.getLabel(UserContext.languageLocaleKey, UKGPRO_APIKEY)));	
		} else if (responseObj.getStatusCode() == 400) {
			string err = LocaleContext.getLabel(UserContext.languageLocaleKey, ERROR_UKGPRO_API);
			throw new SimpplrException(err.replace('{{fieldName}}', LocaleContext.getLabel(UserContext.languageLocaleKey, UKGPRO_BASE_URL)));	
		} else if(responseObj.getStatusCode() != 200) {
			throw new SimpplrException(responseObj.getBody());
		}
		return fieldsDataWrap;
	}

	public static void initiateUkgProSyncService() {
		Map<String, String> mapRequestParam = new Map<String, String>();
		List<App_Config__c> appConfgList = [SELECT PDS_UKG_Pro_Username__c, PDS_UKG_Pro_Password__c,PDS_UKG_Pro_API_Key__c,PDS_UKG_Pro_Endpoint__c from App_Config__c WITH SECURITY_ENFORCED limit 1];
		App_Config__c appConfigObj = appConfgList[0];

		Blob vector = Blob.valueOf(ServiceConstants.CRYPTO_INITIALIZATION_VECTOR);
		Blob cryptoKey = EncodingUtil.base64Decode(SimpplrContext.DataKey);
		Blob cipherText = EncodingUtil.base64Decode(appConfigObj.PDS_UKG_Pro_Password__c);
		String ukgProPassword = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();

		cipherText = EncodingUtil.base64Decode(appConfigObj.PDS_UKG_Pro_API_Key__c);
		String ukgProApiKey = Crypto.decrypt('AES128', cryptoKey, vector, cipherText).toString();

		mapRequestParam.put('ukgProUsername',appConfigObj.PDS_UKG_Pro_Username__c);
		mapRequestParam.put('ukgProPassword', ukgProPassword);
		mapRequestParam.put('ukgProApiKey', ukgProApiKey);
		mapRequestParam.put('ukgProBaseUrl',appConfigObj.PDS_UKG_Pro_Endpoint__c);
		mapRequestParam.put('orgId', UserInfo.getOrganizationId());
		mapRequestParam.put('action','initiateUkgProSyncServiceProcessor');

		HttpRequest requestObj = new HttpRequest();
		requestObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/people-data/init-ukg-pro-sync-service');
		requestObj.setTimeout(60000);
		requestObj.setHeader('content-type','application/json');
		requestObj.setHeader('accept', 'application/json');
		requestObj.setHeader('simpplr-dri', Utility.getSimpDri());
		requestObj.setMethod('POST');
		requestObj.setBody(Json.serialize(mapRequestParam));
		Http http = new Http();
		HTTPResponse responseObj = http.send(requestObj);
		logger.logDebug('ManageApplicationDao.initiateSimpplrPeopleService :'+responseObj.getBody());
		if (responseObj.getStatusCode() == 200) {
			logUserSyncProvStatus('successful', 'UkgPro');
		} else {
			logUserSyncProvStatus('failed', 'UkgPro');
		}
	}

	public static void sendUkgProSyncingInfoToAWS(ManageApplicationWrapper.UserSyncingPeopleWrapper userSyncPeopleObj){
		String reqId = UserInfo.getOrganizationId() + '-' + UserInfo.getUserId() + '-' + System.currentTimeMillis();
		HttpRequest requestObj = new HttpRequest();
		requestObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/people-data/configure-ukg-pro-sync-service');
		requestObj.setTimeout(60000);
		requestObj.setHeader('content-type','application/json');
		requestObj.setHeader('accept', 'application/json');
		requestObj.setHeader('x-simpplr-request-id', reqId);
		requestObj.setHeader('simpplr-dri', Utility.getSimpDri());
		requestObj.setMethod('POST');
		Map<String, Object> responseAWS = new Map<String, Object>();
		Map<String, Object> mapRequestParam = new Map<String, Object>();
		mapRequestParam.put('action','saveConfigSync');
		mapRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
		responseAWS.put('unique_field', userSyncPeopleObj.uniqueIdentifier);
		if(userSyncPeopleObj.userDivision == true){responseAWS.put('division_key', userSyncPeopleObj.ukgProUserDivisionKey);}
		if(userSyncPeopleObj.department == true){responseAWS.put('department_key', userSyncPeopleObj.ukgProDepartmentKey);}
		if(userSyncPeopleObj.birthDate == true){responseAWS.put('birthday_key', userSyncPeopleObj.ukgProBirthDateKey);}
		List<String> syncingFields = new List<String>();
		if(userSyncPeopleObj.uniqueIdentifier != 'employee_id'){syncingFields.add('employee_id');}
		if(userSyncPeopleObj.uniqueIdentifier != 'email'){syncingFields.add('email');}
		if(userSyncPeopleObj.firstName == true){syncingFields.add('first_name');}
		if(userSyncPeopleObj.lastName == true){syncingFields.add('last_name');}
		if(userSyncPeopleObj.userTitle == true){syncingFields.add('title');}
		if(userSyncPeopleObj.birthDate == true){syncingFields.add('birthday');}
		if(userSyncPeopleObj.joiningDate == true){syncingFields.add('hire_date');}
		if(userSyncPeopleObj.employeeNumber == true){syncingFields.add('employee_number');}
		if(userSyncPeopleObj.companyName == true){syncingFields.add('company');}		
		if(userSyncPeopleObj.userDivision == true){syncingFields.add('division');}
		if(userSyncPeopleObj.department == true){syncingFields.add('department');}
		if(userSyncPeopleObj.phone == true){syncingFields.add('phone');}
		if(userSyncPeopleObj.mobilePhone == true){syncingFields.add('mobile_phone');}
		if(userSyncPeopleObj.street == true){syncingFields.add('street');}
		if(userSyncPeopleObj.city == true){syncingFields.add('city');}
		if(userSyncPeopleObj.manager == true){syncingFields.add('manager');}
		if(userSyncPeopleObj.state == true){syncingFields.add('state');}
		if(userSyncPeopleObj.country == true){syncingFields.add('country');}
		if(userSyncPeopleObj.postalCode == true){syncingFields.add('postal_code');}
		syncingFields.add('company_id');
		responseAWS.put('fields_to_sync',syncingFields);
		Map<String, String> employeeFieldMap = new Map<String, String>();
		Map<String, String> employeeUserDefinedFieldMap = new Map<String, String>();
		for (CustomProfileField a : userSyncPeopleObj.additionalFields) {
			if('EmploymentRecords'.equalsIgnoreCase(a.category)){
				employeeFieldMap.put(a.fieldName, a.columnName);
			}
			else {
				employeeUserDefinedFieldMap.put(a.fieldName, a.columnName);
			}
		  }
		responseAWS.put('employement_records',employeeFieldMap);	
		responseAWS.put('user_defined_fields',employeeUserDefinedFieldMap);
		mapRequestParam.put('syncConfigJson', responseAWS);
		requestObj.setBody(Json.serialize(mapRequestParam));
		Http http = new Http();
		HTTPResponse responseObj = http.send(requestObj);
		logger.logDebug('ManageApplicationDao.sendUkgProSyncingInfoToAWS :'+responseObj.getBody());
	}

	public static void initiateCsvFileProvSyncService() {
		Map<String, String> mapRequestParam = new Map<String, String>();		
		mapRequestParam.put('orgId', UserInfo.getOrganizationId());
		mapRequestParam.put('action','initiateCsvFileProvSyncService');

		HttpRequest requestObj = new HttpRequest();
		requestObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/people-data/init-simpplr-people-service');
		requestObj.setTimeout(60000);
		requestObj.setHeader('content-type','application/json');
		requestObj.setHeader('accept', 'application/json');
		requestObj.setHeader('simpplr-dri', Utility.getSimpDri());
		requestObj.setMethod('POST');
		requestObj.setBody(Json.serialize(mapRequestParam));
		Http http = new Http();
		HTTPResponse responseObj = http.send(requestObj);
		logger.logDebug('ManageApplicationDao.initiateCsvFileProvSyncService :'+responseObj.getBody());
		if (responseObj.getStatusCode() != 200) {
			logUserSyncProvStatus('failed', 'CsvFile');
		}
	}

	public void disconnectGoogleDriveAdmin(String storage){
		logger.logDebug('ManageApplicationDao.disconnectGoogleDriveAdmin()----storage----'+storage);
		List<String> chattergroupIds = new List<String>();
		List<Simpplr_Site__c> siteList = [Select id, Chatter_Group_Id__c, File_Storage_Source__c from Simpplr_Site__c where File_Storage_Source__c ='googledrive' WITH SECURITY_ENFORCED] ;
		for(Simpplr_Site__c siteObj : siteList) {
			chattergroupIds.add(siteObj.Chatter_Group_Id__c);
		}
		GoogleDriveService gdService = new GoogleDriveService();
		gdService.disconnectGoogleDriveAdmin(chattergroupIds);

		App_Integration__c appIntegrationObj = new App_Integration__c();
		//Delete App Integration Record
		String appIntQuery = 'SELECT Id, Is_Deleted__c FROM App_Integration__c WHERE Name = \'googledrive\' and Is_Deleted__c=false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_integration__c> appIntegrationList = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, null);

		//Batch For deleting ALL Google Drive folders
		Database.executeBatch(new BatchDeleteFolderRecords(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING, true), 200);
			
		//Make file storage of sites from googledrive to blank 
		for(Simpplr_Site__c siteObj: siteList){
			siteObj.File_Storage_Source__c = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
		}
			
		if(!siteList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
																			Simpplr_Site__c.File_Storage_Source__c
																		});
		}
			
		if(!appIntegrationList.isEmpty()) {				
			appIntegrationList[0].Is_Deleted__c = true;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,App_Integration__c>(appIntegrationList), new List<Schema.SObjectField>{
																				App_Integration__c.Is_Deleted__c
																			});
				
			Database.executeBatch(new BatchDeleteIntegrationRecords(new List<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE}),2000);
		}
	}

	/**
	 * @description save Recognition Configuration
	 * @param recognitionWrapperObj
	 */
	public void saveRecognitionSetupConfig (ManageApplicationWrapper.RecognitionSetupWrapper recognitionWrapperObj) {
		List<People__c> listOfPplObjToUpdate = new List<People__c>();
		

		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', recognitionWrapperObj.recognitionManagersIds);
		string query = 'SELECT Id, Is_Recognition_Manager__c '+
				' FROM People__c '+
				' WHERE User__r.IsActive = true AND '+
				' (Id IN : soqlParam1 or Is_Recognition_Manager__c = true) ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	
		
		if (!peopleList.isEmpty()) {	
			for (People__c ppl: peopleList){
				if (recognitionWrapperObj.recognitionManagersIds.contains(ppl.id)) {
					ppl.Is_Recognition_Manager__c = true;
					
				} else {
					ppl.Is_Recognition_Manager__c = false;					
				}			
				listOfPplObjToUpdate.add(ppl);
			} 
		}
		
		if (listOfPplObjToUpdate.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<id,People__c>(listOfPplObjToUpdate),new List<Schema.SObjectField>{People__c.Is_Recognition_Manager__c});
		}
	}

	/**
	 * @description fetch Recognition Configuration
	 * @return ManageApplicationWrapper.RecognitionSetupWrapper
	 */
	public ManageApplicationWrapper.RecognitionSetupWrapper getRecognitionSetupConfig(){
		
		ManageApplicationWrapper.RecognitionSetupWrapper  recognitionSetupWrapObj = new ManageApplicationWrapper.RecognitionSetupWrapper();
		List<PeopleLiteWrapper.PeopleMinWrapper> recognitionManagerList = new List<PeopleLiteWrapper.PeopleMinWrapper>();

		string query = 'SELECT Id, Full_Name__c, User_Id__c, Is_Recognition_Manager__c '+
				' FROM People__c '+
				' WHERE User__r.IsActive = true AND '+
				' Is_Recognition_Manager__c = true ';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People__c> peopleList = (List<People__c>)SIMPESAPI.accessController().queryAsUSer(query, null);	
		
		if (!peopleList.isEmpty()) {	
			for (People__c ppl: peopleList){
				PeopleLiteWrapper.PeopleMinWrapper pplLite = new PeopleLiteWrapper.PeopleMinWrapper();
				pplLite.peopleId = ppl.Id;
				pplLite.sfUserId = ppl.User_Id__c;
				pplLite.name = ppl.Full_Name__c;
				recognitionManagerList.add(pplLite);
			} 
		}
		
		recognitionSetupWrapObj.recognitionManagers = recognitionManagerList;
		return recognitionSetupWrapObj;
	}

	/**
	* @description - method added to call cdc lambda to migrate historical records
	*/
	public static void cdcHistoricalMigration() {
		Map<String, Object> mapRequestParam = new Map<String, Object>();
		mapRequestParam.put('orgId', UserInfo.getOrganizationId());
		mapRequestParam.put('stageName', SimpplrContext.environmentStageName);

		List<String> tableList = new List<String>{'Simpplr__Alert__c','Simpplr__Content_Template__c','Simpplr__Event_RSVP_Response__c','Simpplr__Expertise__c','Simpplr__File__c','Simpplr__Pages_Category__c','Simpplr__People__c','Simpplr__People_Category__c','Simpplr__People_Expertise__c','Simpplr__Simpplr_Content__c','Simpplr__Simpplr_Site__c','Simpplr__Site_Category__c','Simpplr__Site_Membership_Request__c','Simpplr__Site_Role__c','Simpplr__Tiles_Config__c','Simpplr__Active_Directory_Group__c','Simpplr__App_Config__c','Simpplr__App_Default__c','Simpplr__App_Feature__c','Simpplr__App_Integration__c','Simpplr__App_Notification__c','Simpplr__Audience__c','Simpplr__Audience_Member__c','Simpplr__Audit_Trail__c','Simpplr__Bookmark__c','Simpplr__Branded_App_Distribution__c','Simpplr__Carousel_Content__c','Simpplr__Content_Audit_Trail__c','Simpplr__Content_Collaborator__c','Simpplr__Content_Feedback__c','Simpplr__Content_History__c','Simpplr__Content_Interaction__c','Simpplr__Content_Lock_Status__c','Simpplr__Content_Message__c','Simpplr__Content_Notification_Setting__c','Simpplr__Csv_Download_Request__c','Simpplr__Email_Log__c','Simpplr__Event_Invitee__c','Simpplr__Feed_Cache__c','Simpplr__Feedback__c','Simpplr__Folder__c','Simpplr__Help_Text__c','Simpplr__Help_Text_View__c','Simpplr__Like__c','Simpplr__Mailer__c','Simpplr__Mailer_Details__c','Simpplr__Must_Read_Audit__c','Simpplr__Must_Read_Confirm_History__c','Simpplr__Package_Upgrade_History__c','Simpplr__People_Expertise_Detail__c','Simpplr__People_Integration__c','Simpplr__People_Interaction__c','Simpplr__People_Preference__c','Simpplr__Question__c','Simpplr__Segment__c','Simpplr__Segment_Rule__c','Simpplr__Segment_Site__c','Simpplr__Share__c','Simpplr__Simpplr_Metadata__c','Simpplr__Site_Config__c','Simpplr__Social_Campaign__c','Simpplr__Social_Campaign_Share__c','Simpplr__Subscription__c','Simpplr__Subscription_Entity__c','Simpplr__Ungrouped_Notification__c','Simpplr__User_Provisioning_Config__c','CollaborationGroup','CollaborationGroupMember','ContentDocument','ContentDocumentLink','FeedComment','FeedItem','Topic','ContentVersion','TopicAssignment'};

		// enabled in jackson 1.0.0
		tableList.addAll(new List<String>{'ContentDistribution', 'Simpplr__Simpplr_Social_Analytics__c', 'Simpplr__Adoption_Email__c', 'Simpplr__Analytics_Alert__c', 'Simpplr__Analytics_File__c', 'Simpplr__Analytics_Mailer__c', 'Simpplr__Analytics_Search_Result_Select__c', 'Simpplr__Analytics_Social_Campaign__c', 'Simpplr__Analytics_Topic_Suggestion__c', 'Simpplr__Analytics_Weekly_Content_Readership__c'});

		tableList.addAll(BatchPushExternalData.CDC_SCHEDULED_SOBJECTS);

		mapRequestParam.put('tableList', tableList);
		HttpRequest requestObj = new HttpRequest();
		requestObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint+'/cdc/historical-migration');
		requestObj.setTimeout(60000);
		requestObj.setHeader('content-type','application/json');
		requestObj.setHeader('accept', 'application/json');
		requestObj.setHeader('simpplr-dri', Utility.getSimpDri());
		requestObj.setMethod('POST');
		requestObj.setBody(Json.serialize(mapRequestParam));
		Http http = new Http();
		HTTPResponse responseObj = http.send(requestObj);
	}

	/**
     * @description this is used to remove people integration and linked folders 
	 * of specific google drive domain
     */
	private void removeGooogleDriveDomain(String domain){
		//Batch For deleting specific domain Google Drive folders
		Database.executeBatch(new BatchDeleteFolderRecords(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING, new Set<String>{domain} ,true), 200);
		// future method callout to update entries in aws db
		updateGooglePeopleRecInAWSDB(domain, ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
	}

	/**
     * @description this is used to remove people integration and linked folders 
	 * of specific google drive domain
     */
	private void removeGooogleCalendarDomain(String domain, Boolean deleteTiles){
		if(deleteTiles){
			Database.executeBatch(new BatchDeleteTilesConfigRecords(null, 'googleCalendar'), 2000);
		}
		//Batch For deleting specific domain Google Drive people integration
		Database.executeBatch(new BatchDeleteIntegrationRecords( new List<String>{IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR}, BATCH_REMOVE_DOMAIN_PEOPLE_INTEGRATION ,new Set<String>{domain}), 200);
		// future method callout to update entries in aws db
		updateGooglePeopleRecInAWSDB(domain, IntegrationConstants.INTEGRATION_TYPE_GOOGLE_CALENDAR);
	}

	/**
     * @description this is used to update people integration in aws db
     */
	@Future(callout=true)
	private static void updateGooglePeopleRecInAWSDB(String domain, String connectedApp){
		String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager?action=disconnectUsersWithDomain';
		Map<String, Object> mapOfRequestParam = new Map<String, Object>();
		mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
		mapOfRequestParam.put('domain', domain);
		mapOfRequestParam.put('connectedApp', connectedApp);
		Utility.getResponseFromAWS(endpointURL, mapOfRequestParam);  
	}

	/**
     * @description This is used to enable slack phase2
     */
	public Boolean processSlackPhase2Upgrade() {
		//Adding slack phase2 configs
		SlackHelper slackObj = new SlackHelper();
		Map<String, Object> mapOfSlackConfig = new Map<String, Object>();
		mapOfSlackConfig.put('slackEnabledFlag', true);
		mapOfSlackConfig.put('slackUnfurlFlag', false);
		mapOfSlackConfig.put('customAppName', '');
		mapOfSlackConfig.put('customAppIconUrl', '');
		HttpResponse response = slackObj.saveSlackManageAppInfo(mapOfSlackConfig);
		logger.logDebug('ManageApplicationDao.processSlackUpgrade()---------response body---'+response.getBody());
		logger.logDebug('ManageApplicationDao.processSlackUpgrade()---------response code---'+response.getStatusCode());
		if(response.getStatusCode() == 200) {
			return true;
		}
		return false;
	}
}