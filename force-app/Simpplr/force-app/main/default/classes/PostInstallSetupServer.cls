/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class PostInstallSetupServer extends DataServer{ 
	public transient final String STR_ERROR_MIGRATION_ALREADY_COMPLETE { get { return labelMap.get('post_install.migration_already_completed_error_flash');}}
	public transient final String STR_ERROR_ANALYTICS_ALREADY_EXISTS { get { return labelMap.get('post_install.analytics_already_exists_error_flash');}}
    private final String ACTION_VALUE_START_INIITAL_SETUP = 'startInitialSetup';
    private final String ACTION_VALUE_START_MIGRATION = 'startMigration';
    private final String ACTION_VALUE_START_TITLE_IMAGE_IMPORT = 'startSiteTitleImpageImport';
    
    private final String ACTION_VALUE_RUN_ANALYTICS_DELETION_BATCH = 'runAnalyticsDeletionBatch';
    private final String ACTION_VALUE_RUN_ANALYTICS_BATCH = 'runAnalyticsBatch';
    
    private final String ACTION_VALUE_RESET_SCHEDULER_CONFIG = 'resetSchedulerConfig';
    private final String ACTION_VALUE_DISABLE_SITE_DASHBOARD_AND_CONTENT_FEATURE = 'disableAllSiteDashboardAndContentFeature';
    
	private final String ACTION_VALUE_CONVERT_ALL_TO_SITE = 'convertAllToSites';
    private final String ACTION_VALUE_REVERT_ALL_TO_CHATTER_GROUP = 'revertAllToChatterGroups';
    private final String ACTION_VALUE_SEND_MONTHLY_ADOPTION_EMAIL = 'sendMonthlyAdoptionEmail';
	private final String ACTION_VALUE_START_PUSH_ANALYTICS_BATCH = 'startPushAnalyticsBatch';
	
	private final String ACTION_VALUE_TOPICS_CLEANUP_BATCH = 'topicsCleanUp';
	private final String ACTION_VALUE_INSERT_PEOPLE_PREFERENCE_RECORDS_BATCH = 'insertPeoplePreferenceRecords';
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
    public override void handleRequest() {
        try{
			String action = readParam(REQUEST_PARAM_ACTION);    
			    	
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            } else if(ACTION_VALUE_START_INIITAL_SETUP.equalsIgnoreCase(action)) {
            	
            	if(SimpplrContext.isSimpplrSetupComplete) {
            		throw new SimpplrException(ExceptionCode.SETUP_PROCESS_STARTED.name());
            	}
        		createAppConfig();
				createAppFeature();
        		createDefaultSiteCategory();
            	createSchedulerRecords();
                startInsertPeopleBatch();
                
	            response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Setup Batches started, You\'ll be notified about their status on your email.', null);
	            response.redirectUrl = SimpplrContext.salesforceBaseUrl  + Page.PostInstallSetup.getUrl() + '?ts=' + System.currentTimeMillis() +'#alert={"type": "success", "message": "Setup Batches started, You\'ll be notified about their status on your email."}';
            
            } else if(ACTION_VALUE_START_MIGRATION.equalsIgnoreCase(action)) {
            		String forceRun = readParam('forceRun');
            	if(SimpplrContext.isMaintenanceInProgress || 'true'.equalsIgnoreCase(forceRun)) {
            		runMigrationBatch();
					response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Migration process successfully started.', null);
            	} else {
            		throw new SimpplrException(STR_ERROR_MIGRATION_ALREADY_COMPLETE); 
            	}
            } else if(ACTION_VALUE_START_TITLE_IMAGE_IMPORT.equalsIgnoreCase(action)) {
            	startSiteTitleImpageImport();        
            
            } else if(ACTION_VALUE_RESET_SCHEDULER_CONFIG.equalsIgnoreCase(action)) {
            	resetSchedulerConfig();
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Scheduler config successfully reset.', null);
                        
            }else if(ACTION_VALUE_DISABLE_SITE_DASHBOARD_AND_CONTENT_FEATURE.equalsIgnoreCase(action)) {
            	disableAllSiteDashboardAndContentFeature();
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Disabling Site Dashboard and Content Features… this may take some time.', null);

            } else if(ACTION_VALUE_RUN_ANALYTICS_DELETION_BATCH.equalsIgnoreCase(action)){
            	runAnalyticsDeletionBatch();
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' Analytics deletion batch started successfully.', null);
            
            } else if(ACTION_VALUE_RUN_ANALYTICS_BATCH.equalsIgnoreCase(action)){
            	runAnalyticsBatch();
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' Analytics batch started successfully.', null);
            
            } else if(ACTION_VALUE_SEND_MONTHLY_ADOPTION_EMAIL.equalsIgnoreCase(action)){
            	sendMonthlyAdoptionEmail();
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' Send adoption mail batch started successfully.' , null);
            
            } else if(ACTION_VALUE_START_PUSH_ANALYTICS_BATCH.equalsIgnoreCase(action)){
            	startPushAnalyticsBatch();	
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' batch started successfully.' , null);
            	
            } else if(ACTION_VALUE_CONVERT_ALL_TO_SITE.equalsIgnoreCase(action)){
            	runSiteConversionBatch(action);
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' Converting Chatter Groups to Sites - this may take some time.', null);
            } else if(ACTION_VALUE_REVERT_ALL_TO_CHATTER_GROUP.equalsIgnoreCase(action)){
            	runSiteConversionBatch(action);
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ' Reverting All Sites to Chatter Groups - this may take some time.', null);
            } else if(ACTION_VALUE_TOPICS_CLEANUP_BATCH.equalsIgnoreCase(action)){
            	topicsCleanUp(action);
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Topics clean up batch started successfully.', null);
            } else if(ACTION_VALUE_INSERT_PEOPLE_PREFERENCE_RECORDS_BATCH.equalsIgnoreCase(action)){
            	insertPeoplePreferenceRecords();
            	response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, 'Insert people preference records batch started successfully.', null);
            } else {
            	throw new SimpplrException(ServiceConstants.ERROR_404);
            } 
        }catch(Exception ex) {
        	response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.resolveMessage(ex.getMessage()), null);
        }
    }
    
    @TestVisible
    private void createSchedulerRecords() {
    	PostInstallHelper helperObj = new PostInstallHelper();
    	helperObj.createSchedulerRecords();
    }
    
    @TestVisible
    private void runMigrationBatch() {
    	String recordType = readParam('recordType');
    	String runNextInSequesnce = readParam('runNextBatchInSequence'); 	
		Boolean runNextBatch = 'true'.equalsIgnoreCase(runNextInSequesnce) ? true : false;

		String endpoint = SimpplrContext.simpplrAPIEndpoint + '/salesforce/package-upgrade';  

		Map<String, Object> mapOfRequestParam = new Map<String, Object>();
		mapOfRequestParam.put('orgId', UserInfo.getOrganizationId());
		mapOfRequestParam.put('orgName', UserInfo.getOrganizationName());
		mapOfRequestParam.put('action', 'registerMigrationJob');
		mapOfRequestParam.put('releaseVersion', ServiceConstants.MIGRATION_VERSION);
		mapOfRequestParam.put('packageVersion', ServiceConstants.PACKAGE_VERSION);
		mapOfRequestParam.put('runNextBatchInSequence', runNextBatch);
		mapOfRequestParam.put('recordType', recordType);
		mapOfRequestParam.put('previousMajorVersion', readParam('previousMajorVersion'));
		mapOfRequestParam.put('previousMinorVersion', readParam('previousMinorVersion'));
		mapOfRequestParam.put('previousPatchVersion', readParam('previousPatchVersion'));

		HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setTimeout(60000);
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        http.send(req);
    }
    
    @TestVisible
    private void startSiteTitleImpageImport() {
    	BatchMigrateSiteRecords job = new BatchMigrateSiteRecords();
   		Database.executeBatch(job,10);
    }
    
    @TestVisible
    private void runSiteConversionBatch(String operationType) {
    	BatchSitesAndChatterGroupsConversion job = new BatchSitesAndChatterGroupsConversion(operationType);
    	Database.executeBatch(job,10);
	}
	
	@TestVisible
    private void topicsCleanUp(String operationType) {
    	BatchMigrateRecords job = new BatchMigrateRecords(operationType, false);
    	Database.executeBatch(job,2000);
	}

	@TestVisible
    private void insertPeoplePreferenceRecords() {
    	DateTime currentTime = DateTime.now().addHours(-1); 			
		List<People__c> peopleList = [SELECT id, user__c, Segment__c 
										FROM people__c 
										WHERE id NOT IN (SELECT people__c FROM people_preference__c)
										AND CreatedDate <=:currentTime
										AND User__r.IsActive = true
										WITH SECURITY_ENFORCED
										Limit 9000];
		if(!peopleList.isEmpty()) {
			PeopleDao peopleDaoObj = new PeopleDao();
			peopleDaoObj.insertPeoplePreference(peopleList);
		}
	}
    
    @TestVisible
    private void resetSchedulerConfig() {
    	PostInstallHelper helperObj = new PostInstallHelper();
    	helperObj.resetSchedulerConfig();
    }
    
    private void disableAllSiteDashboardAndContentFeature() {
    	BatchMigrateSiteRecords job = new BatchMigrateSiteRecords('disableAllSiteDashboardAndContentFeature');
		Database.executeBatch(job,2000);
    }
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	*/
	
	@TestVisible
    private void createAppConfig() {
    	String packageName = PostInstallSetupCtrl.class.getName().substringBefore('PostInstallSetupCtrl').substringBefore('.').toLowerCase();
    	String brandingDocIdJson = new PostInstallHelper().getBrandingDocIdJson();
    	String faviconDefaultpath = ServiceConstants.DEFAULT_BRANDING.get('logo_faviconPath');
    	Blob cryptoKey = Crypto.generateAesKey(128);
    	String dataKey = EncodingUtil.base64Encode(cryptoKey);
    	Boolean autoConvertChatterGroupToSite = false; // default for New installations
    	String appConfigQuery = 'select id from App_Config__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> lstAppConfig = (List<App_config__c>)SIMPESAPI.accessController().queryAsUser(appConfigQuery, null);
		
    	if(lstAppConfig.size() == 0) {  	
	    	App_Config__c appConfigObj = new App_Config__c(Package_Name__c = packageName,
	    													Branding_Document_IDs_JSON__c = brandingDocIdJson, 
	    													Package_Version__c = ServiceConstants.PACKAGE_VERSION,
	    													Favicons_Folder__c = faviconDefaultpath,
	    													Simpplr_Setup_Complete__c = true,
	    													Branding_JSON__c = SimpplrContext.SABrandingJSON,
	    													Data_Key__c = dataKey,
															Embedly_API_Key__c = 'Simpplr',
	    													Auto_Convert_ChatterGroup_To_Site__c = autoConvertChatterGroupToSite,
	    													Last_Major_Upgrade_DateTime__c =  DateTime.now(),
	    													Adoption_Email_Next_Run_Date__c = Utility.adoptionEmailNextRunDate());
	    	SIMPESAPI.accessController().insertAsUser(appConfigObj,new List<Schema.SObjectField>{
	   													App_Config__c.Package_Name__c,
	   													App_Config__c.Package_Version__c,
	   													App_Config__c.Data_Key__c,
														App_Config__c.Embedly_API_Key__c,
	   													App_Config__c.Favicons_Folder__c,
	   													App_Config__c.Branding_JSON__c,
	   													App_Config__c.Branding_Document_IDs_JSON__c,
	   													App_Config__c.Simpplr_Setup_Complete__c,
	   													App_Config__c.Auto_Convert_ChatterGroup_To_Site__c, 
	   													App_Config__c.Last_Major_Upgrade_DateTime__c,
	   													App_Config__c.Adoption_Email_Next_Run_Date__c});
    	}
    }

	/**
	 * @description creates App Feature record if it doesn't exists
	 */
	@TestVisible
    private void createAppFeature() {
    	String appFeatureQuery = 'SELECT Id, AI_Topic_Suggestion_Enabled__c, AI_Related_Content_Enabled__c, AI_Related_Content_Active__c, Newsletter_V2_Enabled__c FROM App_Feature__c limit 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Feature__c> appFeatureList = (List<App_Feature__c>)SIMPESAPI.accessController().queryAsUser(appFeatureQuery, null);
		
    	if(appFeatureList.size() == 0) {  	
	    	App_Feature__c appFeatureObj = new App_Feature__c(	AI_Topic_Suggestion_Enabled__c = false,
																AI_Related_Content_Enabled__c = false,
																AI_Related_Content_Active__c = false,
																Newsletter_V2_Enabled__c = false
															);
	    	SIMPESAPI.accessController().insertAsUser(appFeatureObj,new List<Schema.SObjectField>{
	   													App_Feature__c.AI_Related_Content_Enabled__c,
	   													App_Feature__c.AI_Topic_Suggestion_Enabled__c,
	   													App_Feature__c.AI_Related_Content_Active__c,
														App_Feature__c.Newsletter_V2_Enabled__c
													});
    	}
    }
    
    
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	*/
	
	@TestVisible
	private void createDefaultSiteCategory() {
    	String unCategorizedText = ServiceConstants.UNCATEGORIZED_CATEGORY_STR;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', unCategorizedText);
		String query = 'SELECT Id FROM Site_Category__c WHERE Name__c =:soqlParam1 AND Is_Deleted__c = false LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Site_Category__c> lstSiteCategory = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
    	
    	if(lstSiteCategory.size() == 0) {  	
	    	Site_Category__c siteCategoryObj = new Site_Category__c(Name__c = unCategorizedText, Order__c = 0, access__c = 'all');
	    	SIMPESAPI.accessController().insertAsUser(siteCategoryObj,new List<Schema.SObjectField>	{
	   																									Site_Category__c.Name__c,
	   																									Site_Category__c.Order__c,
    																									Site_Category__c.access__c
	   																								});
    	}
    }
    /**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	*/
	
	@TestVisible
    private void startInsertPeopleBatch(){
			BatchInsertPeopleRecords job = new BatchInsertPeopleRecords(true, true);
			Database.executeBatch(job,200);
    }
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	*/
	
	@TestVisible
	private void runAnalyticsBatch() {
		Date batchDate = stringToDate(readParam('date'));
		if(batchDate != null) {
			List<Analytics_Login__c> listOfLogins = [select id from Analytics_Login__c where date__c =: batchDate WITH SECURITY_ENFORCED limit 1];
    		if(listOfLogins.isEmpty()) {
	    		BatchAdoptionAnalytics job = new BatchAdoptionAnalytics(batchDate);
				Database.executeBatch(job,100);
    		} else {
    			throw new SimpplrException(STR_ERROR_ANALYTICS_ALREADY_EXISTS);
    		}
		} else {
			throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
		}
		
	}
	
	private void startPushAnalyticsBatch(){
        String recordType = readParam('recordType');
        Boolean runNextBatchInSequence =  'true'.equalsIgnoreCase(readParam('runNextBatchInSequence'));
        DateTime startDateTime = stringToDateTime(readParam('startDate'));
        DateTime endDateTime = stringToDateTime(readParam('endDate'));
        if(recordType == 'social_analytics' && startDateTime != null) {
            if(endDateTime == null) {
                endDateTime = startDateTime.addMonths(1);
            }
            BatchPushAnalyticsData job = new BatchPushAnalyticsData(recordType, startDateTime, endDateTime);
            Database.executeBatch(job, 500);
        } else {
            BatchPushAnalyticsData job = new BatchPushAnalyticsData(recordType, runNextBatchInSequence);
            Database.executeBatch(job, 500);
        }
	}
	
	@TestVisible
	private void sendMonthlyAdoptionEmail() {
		Boolean isSendOnlyToMe = 'true'.equalsIgnoreCase(readParam('isSendOnlyToMe'));
		String recordType = String.isBlank(readParam('recordType'))?'sendMonthlyAdoptionEmail':readParam('recordType');
		BatchAdoptionEmail adoptionEmailBatch = new BatchAdoptionEmail(recordType,isSendOnlyToMe);
		Database.executeBatch(adoptionEmailBatch,20);		
	}
	
	@TestVisible
	private void runAnalyticsDeletionBatch() {
		String objectName = readParam('objectName');
		Boolean isAllAnalyticsObjectsRecords =  false;
		if('all'.equalsIgnoreCase(objectName)) {
			objectName = 'Analytics_Content_Count__c';
			isAllAnalyticsObjectsRecords = true;
		}
		Date startDate = stringToDate(readParam('startDate'));
		Date endDate = stringToDate(readParam('endDate'));
		if(startDate != null) {
			BatchDeleteAnalyticsRecords job = new BatchDeleteAnalyticsRecords(startDate, endDate, objectName, isAllAnalyticsObjectsRecords);
			Database.executeBatch(job, 2000);
		}
	}
	
	@TestVisible
	private Date stringToDate(String dateString){
    	Date returnValue;
    	if(String.isNotBlank(dateString)) {
			List<String> strDate = dateString.split('-');
			returnValue=Date.newInstance(Integer.valueOf(strDate[0]),
										Integer.valueOf(strDate[1]),
										Integer.valueOf(strDate[2]));
    	}
		return returnValue;
    }

	@TestVisible
    private DateTime stringToDateTime(String dateString){
        DateTime returnValue;
        if(String.isNotBlank(dateString)) {
            List<String> strDate = dateString.split('-');
            returnValue=DateTime.newInstance(Integer.valueOf(strDate[0]),
                                        Integer.valueOf(strDate[1]),
                                        Integer.valueOf(strDate[2]));
        }
        return returnValue;
    }
}