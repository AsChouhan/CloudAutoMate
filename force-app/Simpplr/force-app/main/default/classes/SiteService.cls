/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public without sharing class SiteService {

	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public Simpplr_Site__c saveSiteDetails(SiteDetailWrapper sDWrapperObj) {
		logger.logDebug('SiteService.saveSiteDetails()----sDWrapperObj----'+sDWrapperObj);
		Site_Category__c siteCategoryObj;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
       	soqlParamMap.put('soqlParam1', sDWrapperObj.siteId);
		String query = 'SELECT Id, Name, Chatter_Group_Id__c, Site_Category__c, Question_Answer_Enabled__c,Landing_Page__c,'+
		'Site_Type__c, Title_Content_Version__c,Title_Content_Document__c,File_Storage_Source__c, Is_Content_Unfurl_Enabled__c,'+
		'(Select Permissions__c From Simpplr_Folders__r WHERE Type__c = \'dropbox\' AND Is_Deleted__c = false '+
		'AND Is_System_Folder__c = true AND Parent_Folder__c = null LIMIT 1) '+
		'FROM Simpplr_Site__c WHERE Id =: soqlParam1';

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Simpplr_Site__c> siteObj = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);  
		
		// update the folder record and do sharing changes only if folder already created and old permission - 
		// does not match the new one, saveSiteStorageConfig() method will take care of insertion and giving -
		//  permissions to folder
		String oldPermission;
		if (siteObj[0].Simpplr_Folders__r.size() > 0 && String.isNotBlank(sDWrapperObj.dropboxRootPermission) 
				&& !sDWrapperObj.dropboxRootPermission.equalsIgnoreCase(siteObj[0].Simpplr_Folders__r[0].permissions__c) ) {
			oldPermission = siteObj[0].Simpplr_Folders__r[0].permissions__c;
			updateFolderPermissions(sDWrapperObj.dropboxRootPermission, SiteContext.siteId);
			logger.logDebug('SiteService.saveSiteDetails()----updateFolderPermissions--oldPermission--'+ oldPermission);
		}
		
		try {
			String oldStorageSource = SiteContext.fileStorageSource;
			
			if(String.isNotBlank(sDWrapperObj.storageProvider) && !oldStorageSource.equalsIgnoreCase(sDWrapperObj.storageProvider)){
				if(!SiteContext.isCurrentUserSiteOwner){
		    		throw new SimpplrException('Only Site owner can change the storage settings');
		    	} else {
					saveSiteStorageConfig(siteObj[0].Id, sDWrapperObj.dropboxRootPermission,oldStorageSource,sDWrapperObj.storageProvider);
				}
			}
		
			String siteOldName = siteObj[0].Name;
			List<CollaborationGroup> cgList = [SELECT id, CanHaveGuests, CollaborationType FROM CollaborationGroup WHERE id=:siteObj[0].Chatter_Group_Id__c LIMIT 1]; 
			if(!cgList.isEmpty() && (ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(cgList[0].CollaborationType) || ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(cgList[0].CollaborationType)) && cgList[0].CanHaveGuests && ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(sDWrapperObj.access)){
				throw new SimpplrException('It\'s not possible to make this Site Public, "Allow Customers" is enabled');
			}

			if(!cgList.isEmpty() && ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(sDWrapperObj.access) &&  (ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(cgList[0].CollaborationType) || ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(cgList[0].CollaborationType))) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
	    	
	    	siteObj[0].Name = sDWrapperObj.name;
			
	    	siteObj[0].Site_Category__c = sDWrapperObj.Category.id;
	    	siteObj[0].Site_Type__c = sDWrapperObj.access;
	    	siteObj[0].Last_Edited_DateTime__c = DateTime.now();
	    	siteObj[0].Has_Albums__c = sDWrapperObj.hasAlbums;
		    siteObj[0].Has_Events__c = sDWrapperObj.hasEvents;
		    siteObj[0].Has_Pages__c = sDWrapperObj.hasPages;
		    siteObj[0].Landing_Page__c = sDWrapperObj.landingPage;
		    siteObj[0].Allow_Public_Contribution__c = sDWrapperObj.isContentSubmissionsEnabled;
			siteObj[0].File_Storage_Source__c = sDWrapperObj.storageProvider;
			siteObj[0].Is_Content_Unfurl_Enabled__c = sDWrapperObj.isContentUnfurlEnabled;
			if(SimpplrContext.isQuestionAnswerEnabled) { 
				siteObj[0].Question_Answer_Enabled__c = sDWrapperObj.isQuestionAnswerEnabled;
			}
			if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(sDWrapperObj.access)) {
				siteObj[0].Is_Membership_Auto_Approved__c =  sDWrapperObj.isMembershipAutoApproved == true ? true : false;
			} else {
				siteObj[0].Is_Membership_Auto_Approved__c = false;

			}
			siteObj[0].Allow_Comments__c = sDWrapperObj.isContentFeedEnabled;
			/**
				Update Layout to 'D' (3 - column layout) and add 'Feed' to feature list as a first element if not there or is not at first position, if
				- Current layout is 'E' 
				- 'Dashboard' feature is OFF
				- Global 'Feed' is ON
			**/
			if((!'Dashboard'.equalsIgnoreCase(sDWrapperObj.landingPage)) && SimpplrContext.isFeedEnabled &&
				ServiceConstants.FEED_ON_DASHBOARD_LAYOUT_SET.contains(SiteContext.tileLayout)){
					siteObj[0].Layout__c = 'D';
			} else if(String.isNotBlank(sDWrapperObj.dashboardLayout)){
				siteObj[0].Layout__c = sDWrapperObj.dashboardLayout;
			}
			if(siteObj[0].Is_Membership_Auto_Approved__c) {
				Utility.IsSiteCreationFromSimpplrUI = true;
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(siteObj[0], new List<Schema.SObjectField>{
				Simpplr_Site__c.Name, 
				Simpplr_Site__c.Site_Category__c, 
				Simpplr_Site__c.Site_Type__c, 
				Simpplr_Site__c.Has_Albums__c, 
				Simpplr_Site__c.Has_Events__c, 
				Simpplr_Site__c.Has_Pages__c, 
				Simpplr_Site__c.Landing_Page__c, 
				Simpplr_Site__c.Allow_Public_Contribution__c, 
				Simpplr_Site__c.File_Storage_Source__c, 
				Simpplr_Site__c.Question_Answer_Enabled__c, 
				Simpplr_Site__c.Is_Membership_Auto_Approved__c, 
				Simpplr_Site__c.Allow_Comments__c, 
				Simpplr_Site__c.Layout__c,
				Simpplr_Site__c.Is_Content_Unfurl_Enabled__c
			});

			CollaborationGroup cgObj = new CollaborationGroup(Id=siteObj[0].Chatter_Group_Id__c,Name = sDWrapperObj.name,isBroadcast= sDWrapperObj.isBroadcast, 
											Description=sDWrapperObj.description, CollaborationType=sDWrapperObj.access);
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
			SIMPESAPI.accessController().updateAsUser(cgObj, new List<Schema.SObjectField>{
				CollaborationGroup.Name, 
				CollaborationGroup.isBroadcast, 
				CollaborationGroup.Description, 
				CollaborationGroup.CollaborationType
			});
	        
		} catch (Exception e) {
			logger.logDebug('SiteService.saveSiteDetails()----In Rollback Exception---- ' + e.getMessage());
			// rollback folder changes
			if (String.isNotBlank(oldPermission)) {
				rollbackFolderPermissions(oldPermission, SiteContext.siteId);
			}
			
			throw e;
		}	
		
    	logger.logDebug('SiteService.saveSiteDetails()----siteObj----'+siteObj[0]);
    	return siteObj[0];
	}
	
	@TestVisible 
    public void saveSiteStorageConfig(String siteId,String dropboxRootPermission,String oldStorageSource,String newStorageSource){
    	logger.logDebug('SiteService.saveSiteStorageConfig()----siteId----'+siteId + + '----dropboxRootPermission----'+dropboxRootPermission);

    	if(SimpplrContext.integrations.containsKey(oldStorageSource) && 
    	   SimpplrContext.integrations.get(oldStorageSource).Batch_Processing__c) {
    		throw new SimpplrException('Unable to perform action, please try again after some time.');
    	} else {
        	if(ServiceConstants.STORAGE_TYPE_BOX_STRING.equalsIgnoreCase(newStorageSource)) {
    			if(SimpplrContext.IsBoxIntegrationEnabled){
        			if(String.isBlank(SimpplrContext.BoxUsername)){
						throw new SimpplrException(EFSConstants.getConnectErrorMessage('box'));		
					}
    			} else {
    				throw new SimpplrException('Box Integration is not enabled.');
    			}
    		} else if(	(!SimpplrContext.Integrations.containsKey(newStorageSource)) || 
    					(!SimpplrContext.Integrations.get(newStorageSource).Integration_Enabled__c) ||
    					(!UserContext.Integrations.containsKey(newStorageSource)) || 
    					String.isBlank(UserContext.Integrations.get(newStorageSource).User_Email__c)) {
    			if(EFSConstants.storageTypes.contains(newStorageSource)) {
    				throw new SimpplrException(EFSConstants.getConnectErrorMessage(newStorageSource));
    			}	
    		}
        	
        	String extraURL = '';
        	// If storage is not changed don't update Site Config record and call BatchEFSFolderSync
        	if(!newStorageSource.equalsIgnoreCase(oldStorageSource)) {
	        	saveSiteStorageType(newStorageSource, siteId);
	        	
	        	if(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(newStorageSource) || 
	        	   ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(newStorageSource) ||
	        	   ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(newStorageSource) || 
	        	   ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(newStorageSource)) {
					if(dropboxRootPermission != null && dropboxRootPermission.equalsIgnoreCase('readwrite')) {
						extraURL = '&permission=' + dropboxRootPermission; 
						Database.executeBatch(new BatchEFSFolderSync('SITERW', '["' + siteId + '"]',newStorageSource), 1);
					} else {
						Database.executeBatch(new BatchEFSFolderSync('SITE', '["' + siteId + '"]',newStorageSource), 1);
					}
	        	} else {
	        		if(ServiceConstants.SITE_SYSTEM_FOLDERS_TYPE_MAP.get('CRM_FILES').equalsIgnoreCase(newStorageSource) ||
		        			ServiceConstants.SITE_SYSTEM_FOLDERS_TYPE_MAP.get('BOX_FILES').equalsIgnoreCase(newStorageSource)) {
		        		createStorageFolderIfNotExists(newStorageSource, siteId);
		        	}
		        	
	        		if(oldStorageSource != null && UserContext.Integrations.containsKey(oldStorageSource)) {
		        		Database.executeBatch(new BatchEFSFolderSync('sitedel', '["' + siteId + '"]',oldStorageSource), 1);
		        	}
	        	}
        	} else if(dropboxRootPermission != null && ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(newStorageSource)) {
     			EFSFileService fs = new EFSFileService(newStorageSource);
     			FolderDao folderDaoObj = new FolderDao();
     			
     			Folder__c siteFold = folderDaoObj.getEFSSiteFolder(SiteContext.siteId, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
     			logger.logDebug(siteFold);
     			Boolean success = fs.changeFolderSharing(siteFold.EFS_Shared_Folder_Id__c, siteFold.EFS_Read_Collaboration_Id__c, dropboxRootPermission);
     			
		 		if (success == true) {
		 			folderDaoObj.setExternalFolderPermissions(SiteContext.siteId, siteFold.External_Folder_Id__c, dropboxRootPermission, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
		 			extraURL = '&permission=' + dropboxRootPermission;
		 		}
        	}        
    	}
        logger.logDebug('SiteService.saveSiteStorageConfig()----Finished----');
    }
    
    public static void createStorageFolderIfNotExists(String storageSource, String siteId) {
    	
    	String folderType = 'box'.equalsIgnoreCase(storageSource) ? ServiceConstants.SITE_SYSTEM_FOLDERS_TYPE_MAP.get('BOX_FILES') : ServiceConstants.SITE_SYSTEM_FOLDERS_TYPE_MAP.get('CRM_FILES');
    	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', storageSource);
		String folderQuery = 'Select id From Folder__c WHERE Site__c = : soqlParam1 AND Type__c = :soqlParam2 AND Is_Deleted__c = false AND Is_System_Folder__c = true AND Parent_Folder__c = null LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
    	
    	if(folderList.isEmpty()) {
    		Folder__c systemFolder = new Folder__c();
			systemFolder.Name__c = 'box'.equalsIgnoreCase(storageSource) ? EFSConstants.EFS_SYSTEM_FOLDERS_MAP.get('box') : ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.get('CRM_FILES');
			systemFolder.Site__c = siteId;
			systemFolder.Is_System_Folder__c  = true;
			systemFolder.Type__c = folderType;
			systemFolder.Permissions__c = 'Read';
			systemFolder.Is_Hidden__c = false;
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().insertAsUser(systemFolder, new List<Schema.SObjectField>{
					Folder__c.Name__c,
					Folder__c.Site__c,
					Folder__c.Is_System_Folder__c,
					Folder__c.Type__c,
					Folder__c.Permissions__c,
					Folder__c.Is_Hidden__c
					});

    	}
    }
    
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public List<ContentWorkspace> fetchAllCRMLibList() { // TODO please check, it is not returning any value.
		List<ContentWorkspace> allCRMLibList = [Select Id, Name From ContentWorkspace order by Name limit 50000];
		logger.logDebug('SiteService.fetchAllCRMLibList()----allCRMLibList----'+allCRMLibList);
		return allCRMLibList;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public List<Folder__c> fetchSiteCRMLibList(String siteId) {
		logger.logDebug('SiteService.fetchSiteCRMLibList()----siteId----'+siteId);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', ServiceConstants.STORAGE_TYPE_CRM_STRING);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'SELECT id, Name__c, Site__c, External_Folder_Id__c FROM Folder__c WHERE Type__c = :soqlParam1 ' +
			' and Is_Deleted__c = false and Site__c =: soqlParam2 and External_Folder_Id__c != null';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> siteCRMLibList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		logger.logDebug('SiteService.fetchSiteCRMLibList()----siteCRMLibList----'+siteCRMLibList);
		return siteCRMLibList;
	}
	
	/**
	* 
	* Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
	* Parameters:
	*      parameter_name -- [Explanation of the purpose of this parameter to the method.
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	public void saveSiteStorageType(String storageType, String siteId) {
		logger.logDebug('SiteService.saveSiteStorageType()----storageType----'+storageType+'----siteId---'+siteId);
		List<Simpplr_Site__c> siteObjList = [SELECT Id, File_Storage_Source__c FROM Simpplr_Site__c WHERE Id =: siteId];

		if(siteObjList != null && siteObjList.size() > 0 && (!storageType.equalsIgnoreCase(siteObjList[0].File_Storage_Source__c))) {
			Simpplr_Site__c siteObj = new Simpplr_Site__c(id=siteId, File_Storage_Source__c = storageType);
	            	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	   				SIMPESAPI.accessController().updateAsUser(siteObj,new List<Schema.SObjectField>{
	    													Simpplr_Site__c.File_Storage_Source__c});
		}
	}
	
	public Folder__c linkCRMFolderToSite(String crmFolderId, String crmFolderName, String siteId) {
		logger.logDebug('SiteService.linkCRMFolderToSite()----crmFolderId----'+crmFolderId+'----siteId---'+siteId);
		String rootFolderId = getSystemFolder(siteId, ServiceConstants.STORAGE_TYPE_CRM_STRING); 
		Folder__c folderObj = new Folder__c();
		folderObj.Name__c = crmFolderName;
		folderObj.Site__c = siteId;
		folderObj.Type__c = ServiceConstants.STORAGE_TYPE_CRM_STRING;
		folderObj.Permissions__c = 'Read';
		folderObj.Parent_Folder__c = rootFolderId;
		folderObj.External_Folder_Id__c = crmFolderId;
		
		// Insert Folder
	    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	   	SIMPESAPI.accessController().insertAsUser(folderObj,new List<Schema.SObjectField>{
   											Folder__c.Name__c, Folder__c.Site__c, Folder__c.Type__c, Folder__c.Permissions__c, Folder__c.Parent_Folder__c, Folder__c.External_Folder_Id__c});
		
		FolderDao folderDaoObj = new FolderDao();
		List<Folder__c> listOfFolderDetails = folderDaoObj.getCRMFolderDetails(crmFolderId, siteId);
		
		logger.logDebug('SiteService.linkCRMFolderToSite()----listOfFolderDetails----'+listOfFolderDetails);
		return listOfFolderDetails[0];
	}
	
	private String getSystemFolder(String siteId, String type) {
		String rootFolderId;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', type);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'select Id from Folder__c where Type__c =:soqlParam1 and site__c=:soqlParam2 and Is_System_Folder__c=true';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(!folderList.isEmpty()) {
			rootFolderId = folderList[0].id;
		}
		return rootFolderId;
	}
	
	public void unlinkCRMFolderFromSite(String crmFolderId, String siteId) {
		logger.logDebug('SiteService.unlinkCRMFolderFromSite()----crmFolderId----'+crmFolderId+'----siteId---'+siteId);
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', crmFolderId);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'select Id from Folder__c where Type__c = \'crm\' and External_Folder_Id__c = :soqlParam1 and Site__c = :soqlParam2 and Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> toBeUnlinkededFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		
		for(Folder__c folderObj : toBeUnlinkededFolders) {
			folderObj.Is_Deleted__c = true;
		}
		
		if(toBeUnlinkededFolders.size() > 0) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
   			SIMPESAPI.accessController().updateAsUser(
   														new Map<Id,Folder__c>(toBeUnlinkededFolders),
   														new List<Schema.SObjectField>{Folder__c.Is_Deleted__c}
													 );
		}
	}
	
    public List<ManageSiteWrapper.SiteExternalAppWrapper> getExternalAppsSettings(String siteId) {
		List<ManageSiteWrapper.SiteExternalAppWrapper> appsWrapperList = new List<ManageSiteWrapper.SiteExternalAppWrapper>();

		List<Simpplr_Site__c> siteList = [SELECT Id, Slack_Channel_Id__c, Slack_Access_Token__c,Slack_Channel_Name__c, Slack_Url__c,  Slack_Comment_Enabled__c, 
											Slack_Post_Enabled__c, Slack_Site_Manager__r.Name, Slack_Site_Manager__c, Slack_Integration_Enabled__c, Microsoft_Teams_Webhook_URL__c, 
											Microsoft_Teams_Integration_Enabled__c, Microsoft_Teams_Comment_Enabled__c,Microsoft_Teams_Site_Manager__r.User__c,
											External_Apps_Site_Config_Json__c FROM Simpplr_Site__c  WHERE Id =: siteId]; 

		Simpplr_Site__c siteObj = 	siteList[0];											
		ManageSiteWrapper.SiteExternalAppWrapper wrapperObj;
		if(SimpplrContext.slackIntegrationEnabled) {
			wrapperObj = new ManageSiteWrapper.SiteExternalAppWrapper();
			wrapperObj.name = IntegrationConstants.INTEGRATION_TYPE_SLACK;
			wrapperObj.isConnected = false;
			if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded){
				if(siteObj.Slack_Integration_Enabled__c){
					wrapperObj.isConnected = true;
				}
			} else {
				wrapperObj.isConnected = String.isNotBlank(siteObj.Slack_Channel_Id__c) || String.isNotBlank(siteObj.Slack_Url__c);	
			}
			wrapperObj.options = new ManageSiteWrapper.Options();
			if(String.isNotBlank(siteObj.External_Apps_Site_Config_Json__c)){
				wrapperObj.Options = (ManageSiteWrapper.Options)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.Options.class);
				wrapperObj.Options.msTeamsSiteConfig = null;
			}
			//Don't send channelId to UI if user has added channelUrl
			wrapperObj.options.channelId = String.isBlank(siteObj.Slack_Url__c) ? siteObj.Slack_Channel_Id__c : null;
			wrapperObj.options.channelUrl = siteObj.Slack_Url__c;
			wrapperObj.options.channelName = siteObj.Slack_Channel_Name__c;
			wrapperObj.options.sendFeed = siteObj.Slack_Comment_Enabled__c ? 'posts-and-replies' : 'only-posts';			
			appsWrapperList.add(wrapperObj);
		}

		if(SimpplrContext.microsoftTeamsIntegrationEnabled) {
			wrapperObj = new ManageSiteWrapper.SiteExternalAppWrapper();
			wrapperObj.name = 'teams';
			wrapperObj.Options = new ManageSiteWrapper.Options();
			if(SimpplrContext.isFeatureMicrosoftTeamsEnabledPhase2){
				wrapperObj.isConnected = false;
				if(siteObj.Microsoft_Teams_Integration_Enabled__c){
					wrapperObj.isConnected = true;
				}
				if(String.isNotBlank(siteObj.External_Apps_Site_Config_Json__c)){
					wrapperObj.Options = (ManageSiteWrapper.Options)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.Options.class);
					wrapperObj.Options.slackSiteConfig = null;
				}
			} else{
				wrapperObj.Options.webhookUrl = siteObj.Microsoft_Teams_Webhook_URL__c;
				wrapperObj.Options.sendFeed = siteObj.Microsoft_Teams_Comment_Enabled__c ? 'posts-and-replies' : 'only-posts';
				wrapperObj.isConnected = siteObj.Microsoft_Teams_Integration_Enabled__c;
			}
			
			appsWrapperList.add(wrapperObj);
		}

		return appsWrapperList;
	}
	
	 public void saveSiteExternalAppsConfig(ManageSiteWrapper.SiteExternalAppsWrapper siteExternalAppObj) {
		logger.logDebug('SiteService.saveSiteExternalAppsConfig()----siteExternalAppObj----'+siteExternalAppObj);
		Simpplr_Site__c siteObj = [SELECT Id, Slack_Channel_Id__c, Slack_Comment_Enabled__c, Slack_Channel_Name__c, Slack_Url__c, Slack_Integration_Enabled__c,
									 Slack_Post_Enabled__c, Slack_Site_Manager__c, Microsoft_Teams_Integration_Enabled__c, Microsoft_Teams_Webhook_URL__c, 
									 Microsoft_Teams_Comment_Enabled__c, External_Apps_Site_Config_Json__c FROM Simpplr_Site__c WHERE Id =: siteExternalAppObj.siteId];
		
		if(SimpplrContext.isSlackPhase2FeatureEnabled && SimpplrContext.isSlackUpgraded && siteExternalAppObj != null){
			siteObj.Slack_Site_Manager__c = siteExternalAppObj.slackSiteManager;
			siteObj.Slack_Integration_Enabled__c = siteExternalAppObj.slackIntegrationEnabled;
		} else{
			if(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE) != null && String.isNotBlank(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE).Access_Token__c)){
				if(siteExternalAppObj != null && siteExternalAppObj.slackChannel != null && siteExternalAppObj.slackChannel.id != null){
					siteObj.Slack_Channel_Id__c = siteExternalAppObj.slackChannel.id;
					siteObj.Slack_Channel_Name__c = siteExternalAppObj.slackChannel.Name;
					siteObj.Slack_Site_Manager__c = UserContext.peopleId; 
					siteObj.Slack_Comment_Enabled__c = siteExternalAppObj.slackCommentEnabled;
					siteObj.Slack_Integration_Enabled__c = true;
					siteObj.Slack_Post_Enabled__c= siteExternalAppObj.slackPostEnabled;
					siteObj.Slack_Url__c= siteExternalAppObj.slackUrl;	
				}
			} 
		}
		siteObj.Microsoft_Teams_Integration_Enabled__c= siteExternalAppObj.microsoftTeamsIntegrationEnabled;
		siteObj.Microsoft_Teams_Webhook_URL__c= siteExternalAppObj.microsoftTeamsWebhookURL;
		siteObj.Microsoft_Teams_Site_Manager__c= siteExternalAppObj.microsoftTeamsSiteManager;
		siteObj.Microsoft_Teams_Comment_Enabled__c= siteExternalAppObj.microsoftTeamsCommentEnabled;
		if (siteExternalAppObj.ExternalAppsSiteConfig != null) {
			siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(siteExternalAppObj.ExternalAppsSiteConfig,true);
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	   	SIMPESAPI.accessController().updateAsUser(siteObj,new List<Schema.SObjectField>{
	    													Simpplr_Site__c.Slack_Channel_Id__c, 
	    													Simpplr_Site__c.Slack_Comment_Enabled__c,
	    													Simpplr_Site__c.Slack_Post_Enabled__c,
	    													Simpplr_Site__c.Slack_Channel_Name__c,
	    													Simpplr_Site__c.Slack_Url__c,
															Simpplr_Site__c.Slack_Integration_Enabled__c,
															Simpplr_Site__c.Slack_Site_Manager__c,
	    													Simpplr_Site__c.Microsoft_Teams_Integration_Enabled__c,
	    													Simpplr_Site__c.Microsoft_Teams_Comment_Enabled__c, 
	    													Simpplr_Site__c.Microsoft_Teams_Webhook_URL__c,
	    													Simpplr_Site__c.Microsoft_Teams_Site_Manager__c,
															Simpplr_Site__c.External_Apps_Site_Config_Json__c
															}
	    											  );
	} 
	
	public void disconnectApp(String siteId, String appName){
		logger.logDebug('SiteService.disconnectApp()----siteId---- ' +siteId + '----appname---- ' + appName);
		
		if(IntegrationConstants.INTEGRATION_TYPE_SLACK.equalsIgnoreCase(appName)){
			Simpplr_Site__c siteObj = [SELECT Id, Slack_Access_Token__c,Slack_Channel_Name__c, Slack_Site_Manager__c, Slack_Url__c, Slack_Channel_Id__c, Slack_Integration_Enabled__c, External_Apps_Site_Config_Json__c FROM Simpplr_Site__c WHERE Id =: siteId];
			siteObj.Slack_Channel_Id__c= null;
			siteObj.Slack_Access_Token__c= null;
			siteObj.Slack_Channel_Name__c= null;
			siteObj.Slack_Url__c= null;
			siteObj.Slack_Post_Enabled__c= true;
			siteObj.Slack_Comment_Enabled__c= false;
			siteObj.Slack_Site_Manager__c = null;
			siteObj.Slack_Integration_Enabled__c = false;
			if(siteObj.External_Apps_Site_Config_Json__c != null){
				ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
				externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
				externalAppsSiteConfig.SlackSiteConfig = null;
				siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		   	SIMPESAPI.accessController().updateAsUser(siteObj,new List<Schema.SObjectField>{
		    													Simpplr_Site__c.Slack_Channel_Id__c, 
		    													Simpplr_Site__c.Slack_Access_Token__c,
		    													Simpplr_Site__c.Slack_Url__c,
		    													Simpplr_Site__c.Slack_Post_Enabled__c,
		    													Simpplr_Site__c.Slack_Comment_Enabled__c,
		    													Simpplr_Site__c.Slack_Channel_Name__c,
																Simpplr_Site__c.Slack_Site_Manager__c,
																Simpplr_Site__c.Slack_Integration_Enabled__c,
																Simpplr_Site__c.External_Apps_Site_Config_Json__c
		    													}
		    											  );	
			// invoke a method to delete epople Integ record for content share			
		
		} else if(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS.equalsIgnoreCase(appName)){
			Simpplr_Site__c siteObj = [SELECT Id, Microsoft_Teams_Integration_Enabled__c, Microsoft_Teams_Webhook_URL__c, Microsoft_Teams_Comment_Enabled__c, External_Apps_Site_Config_Json__c, Microsoft_Teams_Site_Manager__c FROM Simpplr_Site__c WHERE Id =: siteId];	
			siteObj.Microsoft_Teams_Integration_Enabled__c = false;
			siteObj.Microsoft_Teams_Webhook_URL__c = null;
			siteObj.Microsoft_Teams_Comment_Enabled__c = false;
			siteObj.Microsoft_Teams_Site_Manager__c = null;
			if(siteObj.External_Apps_Site_Config_Json__c != null){
				ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
				externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
				externalAppsSiteConfig.MsTeamsSiteConfig = null;
				siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
			}
			
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		   	SIMPESAPI.accessController().updateAsUser(siteObj,new List<Schema.SObjectField>{
		   														Simpplr_Site__c.Microsoft_Teams_Comment_Enabled__c,
		    													Simpplr_Site__c.Microsoft_Teams_Integration_Enabled__c, 
		    													Simpplr_Site__c.Microsoft_Teams_Webhook_URL__c,
																Simpplr_Site__c.External_Apps_Site_Config_Json__c,
																Simpplr_Site__c.Microsoft_Teams_Site_Manager__c
		    													}
		    											  );			
		}

	}
	
	public static void updateFolderPermissions (String permissions, String siteId) {
		try {
			String siteIdStr = siteId;
			FolderDao folderDaoObj = new FolderDao();
 			EFSFileService fs = new EFSFileService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
 			Folder__c siteFold = folderDaoObj.getEFSSiteFolder(siteIdStr, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
 			Boolean success = fs.changeFolderSharing(siteFold.EFS_Shared_Folder_Id__c, siteFold.EFS_Read_Collaboration_Id__c, permissions);
 			
	 		if (success == true) {
	 			folderDaoObj.setExternalFolderPermissions(siteIdStr, siteFold.External_Folder_Id__c, permissions, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
	 		}
 		} catch(EFSException reqEx) {
	     	logger.logDebug(reqEx.getMessage());
 		}
	}
	
	@future (callout=true)
	public static void rollbackFolderPermissions (String oldPermission, String siteId) {
		updateFolderPermissions(oldPermission,siteId);
	}

	/**
	 * @description used to get the site data based on the given site id
	 * @param List<String> list of site ids
	 * @return Map<Id, Simpplr_Site__c> a site data with site Id map
	 */
	public static Map<Id, Simpplr_Site__c> getSiteDataMap(List<String> siteChatterIdList) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteChatterIdList);
		String siteQuery  = 'SELECT Id, chatter_group_id__c, Allow_File_Upload_App_Permission__c, Is_Leadercast_Enabled__c  FROM Simpplr_Site__c where Id IN :soqlParam1 OR chatter_group_id__c In :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<Simpplr_Site__c> siteObjList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUser(siteQuery, soqlParamMap);
		
		return new Map<Id, Simpplr_Site__c>(siteObjList);
	}
	
	/**
	 * @description used to get the collaboration data based on the given id
	 * @param List<String> list of collaboration ids
	 * @return Map<Id, CollaborationGroup> a collaboration data with collaboration Id map
	 */
	public static Map<Id, CollaborationGroup> getChatterGroupDataMap(List<String> chatterIdList) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', chatterIdList);
		String query  = 'SELECT Id, IsBroadcast FROM CollaborationGroup where Id IN :soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		List<CollaborationGroup> siteObjList = (List<CollaborationGroup>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		
		return new Map<Id, CollaborationGroup>(siteObjList);
	}

	public static void updateSiteRequestNotifications(String guid, String siteId, String siteName, String siteType,  String status, String actionComment) {
		String STATUS_APPROVED='Approved';
		String TYPE_INFORMATION='Information';

		List<Ungrouped_Notification__c> ungroupedNotifList = [SELECT Id, App_Notification__c, Old_Notification_Id__c, Is_Deleted__c, Object_Type__c, Object_Id__c, Sent_By__c FROM Ungrouped_Notification__c WHERE GUID__c = :guid AND Is_Deleted__c = false];
		Set<String> appNotifIds = new Set<String>();
		for(Ungrouped_Notification__c notifRec : ungroupedNotifList) {
			appNotifIds.add(notifRec.Old_Notification_Id__c);
			appNotifIds.add(notifRec.App_Notification__c);
			notifRec.Is_Deleted__c = true;
			notifRec.Status__c = status;
		}
		appNotifIds.remove(null);
		update ungroupedNotifList;

		if(status == STATUS_APPROVED) {
			String category = 'private'.equalsIgnoreCase(siteType) ? 'PrivateSiteMembership_Response' : 'Public_Site_Membership_Response';
			App_Notification__c notificationObj = new App_Notification__c(Category__c=category,Is_Read__c=false,type__c=TYPE_INFORMATION, Sub_Type__c = 'Update',
				Status__c=STATUS_APPROVED,Object_Type__c=ungroupedNotifList[0].Object_Type__c,Object_Id__c=ungroupedNotifList[0].Object_Id__c,Sent_By__c=UserContext.peopleId, Simpplr_site__c = siteId,
				Sent_to__c=ungroupedNotifList[0].Sent_By__c,Action_Comment__c=actionComment,Action_By__c=UserContext.peopleId, Parent__c=ungroupedNotifList[0].App_Notification__c, Created_DateTime__c = DateTime.now(),
				Snippet__c = siteName);
			
			NotificationDao.createNotifications(new List<App_Notification__c>{notificationObj});
		}

		List<Ungrouped_Notification__c> ungroupedNotifList2 = [SELECT Id, App_Notification__c FROM Ungrouped_Notification__c WHERE App_Notification__c = :appNotifIds AND Is_Deleted__c = false];
		for(Ungrouped_Notification__c notifRec : ungroupedNotifList2) {
			notifRec.Old_Notification_Id__c = notifRec.App_Notification__c;
			notifRec.App_Notification__c = null;
		}

		List<App_Notification__c> appNotiList = [SELECT Id, RAB_1__c, RAB_2__c, RAB_3__c, Is_Read__c, Is_New__c, Action_By__c, Action_On__c, Action_Comment__c FROM App_Notification__c WHERE Id =: appNotifIds AND Is_Deleted__c = false];
		for(App_Notification__c notifRec : appNotiList) {
			if(notifRec.RAB_3__c != null || notifRec.RAB_2__c != null) {
				notifRec.RAB_3__c = null;
				notifRec.RAB_2__c = null;
				notifRec.RAB_1__c = null;
				notifRec.Is_Read__c = false;
				notifRec.Is_New__c = true;

			} else {
				notifRec.Is_Read__c = true;
				notifRec.Is_New__c = false;
				notifRec.Action_By__c = UserContext.peopleId;
				notifRec.Action_On__c = Datetime.now();
				notifRec.Action_Comment__c = Utility.manageNullForString(actionComment);
			}
		}

		List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
			App_Notification__c.Is_Read__c,
			App_Notification__c.Is_New__c,
			App_Notification__c.Action_By__c,
			App_Notification__c.Action_On__c,
			App_Notification__c.Action_Comment__c,
			App_Notification__c.RAB_1__c,
			App_Notification__c.RAB_2__c,
			App_Notification__c.RAB_3__c
		};
		NotificationDao.updateNotification(appNotiList, listOfColumnsToBeUpdated);
		update ungroupedNotifList2;
	}
}