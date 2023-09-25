public with sharing class PostInstallSetupCtrl extends BaseCtrl {
	
	protected final String REQUEST_PARAM_ACTION = 'action'; 

	//No loggers should be present in this class. 
    public Integer numberOfPeopleRecordsTobeCreated{get;set;}
    public Integer numberOfSiteRecordsTobeCreated{get;set;}
	public Integer numberOfSitesToImportTitleImage{get;set;}
	public Integer numberOfTopicsToBeCleanedUp{get;set;}

    public Boolean canSetupStartedAgain{get;set;}
	public Boolean canMaintenanceStarted{get;set;}
	public Boolean isPermissionSetsMissing{get;set;}
	public String serviceAccountConnectUrl{get;set;}
	public String serviceAccountUserName{get;set;}
	public Boolean isServiceAccount{get;set;}
	public Boolean isSandbox{get;set;}
	public Boolean isPhoneNoAndMobileTokenRemovableFeatureEnabled{get;set;}
    
    public Boolean isMaintenanceInProgress{get{
		return SimpplrContext.isMaintenanceInProgress; 
	}set;}
	
	public Integer totalMigrationBatches{get{
		return ServiceConstants.TOTAL_NUMBER_OF_MIGRATION_BATCHES; 
	}set;}
	
	public Integer pendingMigrationBatches{get{
		if(isMaintenanceInProgress && SimpplrContext.appConfig != null) {
			return Integer.valueOf(SimpplrContext.appConfig.Maintenance_Batches_Pending_Count__c);
		} else {
			return 0;
		} 
	}set;}
    
    public String getPageTitle() {
    	return  'Post Installation Instructions';
    }
    
    public String salesforceHost{get{
		return BaseCtrl.salesforceHost;
	}}
    public String zeusMSUrl{get{
		return SimpplrContext.zeusMicroserviceUrl;
	}}
	
	public override String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public PageReference init(){
        PageReference returnPage = null;
        try{
	        if(!checkPostInstallSetupPermission()) {
        		throw new SimpplrException(ServiceConstants.ERROR_404);
	        }
		    List<User> listOfUsers = [select id from User where ((isActive=true And UserType='Standard') Or Show_Simpplr__c='Yes') And id not in (select user__c from People__c) WITH SECURITY_ENFORCED];
	        numberOfPeopleRecordsTobeCreated = listOfUsers.size();
	        
	        List<String> listOfChatterGroupIds = new List<String>();
	        Set<String> setOfChatterGroupIdsInSimpplrWithOutTitleImage = new Set<String>();
	        for(Simpplr_Site__c siteObj : [select chatter_group_id__c, Title_Content_Version__c from Simpplr_Site__c where chatter_group_id__c != 'S06I000000MPPLR' WITH SECURITY_ENFORCED]) {
	        	listOfChatterGroupIds.add(siteObj.chatter_group_id__c);
	        	if(siteObj.Title_Content_Version__c == null) {
	        		setOfChatterGroupIdsInSimpplrWithOutTitleImage.add(siteObj.chatter_group_id__c);
	        	}
	        }
	        List<CollaborationGroup> listOfCollaborationGroups = new List<CollaborationGroup>();
	        String BASE_QUERY= 'select id from CollaborationGroup where id not in :listOfChatterGroupIds ';
			if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+'AND NetworkId = null';
	    	}
			listOfCollaborationGroups = Database.query(BASE_QUERY);
	        numberOfSiteRecordsTobeCreated = listOfCollaborationGroups.size();
	        
	        
	        BASE_QUERY= 'select id from CollaborationGroup where id in :setOfChatterGroupIdsInSimpplrWithOutTitleImage And isArchived=false and (not FullPhotoUrl like \'%/0F9/F%\')';
	        if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+'AND NetworkId = null';
	    	}
	    	listOfCollaborationGroups = Database.query(BASE_QUERY);
			numberOfSitesToImportTitleImage = listOfCollaborationGroups.size();
			
			TopicDao topicDaoObj = new TopicDao();
			numberOfTopicsToBeCleanedUp = topicDaoObj.getTopicCountForCleanUp();
	    	
	        if(SimpplrContext.isSimpplrSetupComplete == false && (numberOfPeopleRecordsTobeCreated > 0 || numberOfSiteRecordsTobeCreated > 0)) {
	        	canSetupStartedAgain = !checkBatchRunning(new List<String>{'BatchInsertPeopleRecords', 'BatchInsertSiteRecords','BatchUpdateManagerInPeopleRecords'});
	        } else{
	        	canSetupStartedAgain = false;
	        }
	        
	        if(SimpplrContext.isMaintenanceInProgress && pendingMigrationBatches == totalMigrationBatches && !checkBatchRunning(new List<String> {'BatchMigrateRecords'})) {
	        	canMaintenanceStarted = true;
	        } else {
	        	canMaintenanceStarted = false;
	        }
	        
	        // Check if the app manager and unlisted site manager permission sites are there, then only proceed.
	        List<String> permissionSetnameList = new List<String>{'Simpplr_App_Managers', 'Simpplr_Unlisted_Site_Managers'};
	        List<PermissionSet> permissionSetList = [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetnameList WITH SECURITY_ENFORCED];
			if(!permissionSetList.isEmpty() && permissionSetList.size() == 2){
				isPermissionSetsMissing = false;
			} else {
				isPermissionSetsMissing = true;
			}
			isServiceAccount = UserInfo.getUserName().startsWithIgnoreCase('simpplr.serviceaccount@');
			isSandbox = SimpplrContext.isSandbox;
			isPhoneNoAndMobileTokenRemovableFeatureEnabled = SimpplrContext.isPhoneNoAndMobileTokenRemovableFeatureEnabled;
			if(SimpplrContext.Integrations.containsKey(IntegrationConstants.INTEGRATION_TYPE_SERVICE_ACCOUNT)) {
				serviceAccountUserName = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SERVICE_ACCOUNT).User_Email__c;
			} else {
				String stateArg = PageContext.getPageURL(Pages.ConnectExternalApp) + 
									'?state=ServiceAccount' + 
									'&orgId=' + UserInfo.getOrganizationId();
				if(SimpplrContext.isExternalSearchEnabled && SimpplrContext.isExternalSearchAppConnected && SimpplrContext.appConfig.External_Search_Active__c && Utility.isSmartSearchTokenValid()) {
					//Smart search is already active
				} else {
					stateArg += '&searchActivationRequired=true';
				}

				//Onboard tenants in Zeus platform if uuid missing in app_config
				stateArg += '&onboardTenant=true';
				if(String.isNotBlank(SimpplrContext.uuid)) {
					stateArg += '&cleanupPeopleRequired=true';
				}

				serviceAccountConnectUrl = SimpplrContext.salesforceBaseUrl+'/services/oauth2/authorize?'+
											'response_type=code&'+
											'client_id=3MVG9xOCXq4ID1uEnQ5w_SQi9IMd9JBdKIQH0shPVap_mFXHZCDaw.zxkMRAXYjQdv93MveFlmXCvWnVyLUMV'+
											'&redirect_uri='+ EncodingUtil.urlEncode(SimpplrContext.simpplrAPIEndpoint + '/oauth/salesforce-oauth-manager', 'UTF-8') +
											'&state='+EncodingUtil.urlEncode(stateArg, 'UTF-8');
			}
        }catch(Exception e){
        	returnPage = handleAndTranslateException(returnPage, e);
        }
	    return returnPage;
    }
    
    private Boolean checkBatchRunning(List<String> listOfBatchClasses) {
		Boolean jobRunning = false;
		List<String> listOfNonRunningJobStatus = new List<String>{'Aborted', 'Completed','Failed'};
		
		List<AsyncApexJob> listOfApexJob = [select id from AsyncApexJob 
											where ApexClass.name =: listOfBatchClasses 
											And status not in:listOfNonRunningJobStatus];
		if(listOfApexJob.size() > 0) {
			jobRunning=true;
		}
		return jobRunning;
    }
    
    private Boolean checkPostInstallSetupPermission() {
    		Boolean hasPostInstallSetupPermission = false;
    		User userObj = [select id, Profile.PermissionsModifyAllData from User where id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
    		if(userObj.Profile.PermissionsModifyAllData) {
    			hasPostInstallSetupPermission = true;
    		} else {
    			List<PermissionSetAssignment> permissionSetList = UserContext.getCurrentUserPermissionSetList;
			for(PermissionSetAssignment assignmentObj: permissionSetList) {
				if(assignmentObj.PermissionSet.PermissionsModifyAllData) {
					hasPostInstallSetupPermission = true;
					break;
				}
			}
    		}
    		return hasPostInstallSetupPermission;
    }
}