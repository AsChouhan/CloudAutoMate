/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FolderDao {
	
	
	private final String BASE_QUERY = 	'select Id, Path__c, External_Folder_Id__c, EFS_Drive_Id__c, Name__c, Parent_Folder__c, Site__c, Permissions__c, ' + 
										'Parent_Folder__r.External_Folder_Id__c, Parent_Folder__r.Is_System_Folder__c, Is_System_Folder__c, Site__r.Name, Site__r.chatter_Group_id__c, ' + 
										'EFS_All_Company_Collaboration_Id__c, EFS_Read_Collaboration_Id__c, EFS_Read_Write_Collaboration_Id__c, ' +
										'EFS_Search_Collaboration_Id__c, lastmodifieddate, Owner.id, Owner.Name, Type__c, People__c, People__r.Full_Name__c, ' +
										'EFS_Shared_Folder_Id__c, Linked_Folder_Owner__c, Is_External_System_Folder__c, Drive_Type__c, Sp_Instance_Id__c ' +  
										'from Folder__c where is_deleted__c=false ';
	 		
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Folder__c createChatterFolder(Folder__c folderObj) {
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		Folder__c savedFolderObj = (Folder__c) SIMPESAPI.accessController().insertAsUser(folderObj,new List<Schema.SObjectField>{Folder__c.name__c,
   																						  Folder__c.Parent_Folder__c,
   																						  Folder__c.Site__c, 
   																						  Folder__c.Type__c,  
   																						  Folder__c.Path__c,  
   																						  Folder__c.Permissions__c,
   																						  Folder__c.People__c});
		return savedFolderObj;
	}
	
	/**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public Map<Id, Folder__c> getIntranetFolderDetails(List<String> listOfFolderIds) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfFolderIds);
    	String queryStr = BASE_QUERY + 'And type__c =\'Intranet\' And id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return new Map<Id, Folder__c>((List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap));
	}
	
	public Map<Id, Folder__c> getIntranetFolderAndSubFolderDetails(String folderId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', folderId);
    	String queryStr = BASE_QUERY + 'And type__c =\'Intranet\' And (id=:soqlParam1 OR Path__c like \'%' + folderId+ '%\') order by CreatedDate';
    	logger.logDebug('FolderDao.getIntranetFolderAndSubFolderDetails --> queryStr :: ' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return new Map<Id, Folder__c>((List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap));
	}
	
	public List<Folder__c> getBoxFolderDetails(List<String> listOfBoxFolderIds, String siteId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfBoxFolderIds);
		soqlParamMap.put('soqlParam2', siteId);
    	String queryStr = BASE_QUERY + 'And type__c=\'Box\' And External_Folder_Id__c=:soqlParam1 And site__c=:soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}
	
	public List<Folder__c> getCRMFolderDetails(String libraryId, String siteId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', libraryId);
		soqlParamMap.put('soqlParam2', siteId);
    	String queryStr = BASE_QUERY + 'And type__c=\'CRM\' And External_Folder_Id__c=:soqlParam1 And site__c=:soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}

	public List<Folder__c> getExternalFolderDetails(String storage, String externalFolderId, String siteId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', storage);
		soqlParamMap.put('soqlParam2', externalFolderId);
		soqlParamMap.put('soqlParam3', siteId);
		String queryStr = BASE_QUERY + 'And type__c=:soqlParam1 And External_Folder_Id__c=:soqlParam2 And site__c=:soqlParam3';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}
	
	public void deleteFolder(String folderId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', folderId);
		String folderQuery = 'select id,Parent_Folder__r.name__c, External_Folder_Id__c from Folder__c where id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(!listOfFolders.isEmpty()) {
			for(Folder__c folderObj : listOfFolders) {
    			folderObj.is_Deleted__c = true;
    		}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfFolders),new List<Schema.SObjectField>{Folder__c.is_Deleted__c});
	    	FolderDao.deleteAllIntranetSubFoldersAndFiles(folderId);
	    	if('Albums'.equalsIgnoreCase(listOfFolders[0].Parent_Folder__r.name__c)){
	    		Simpplr_Content__c simContent = new Simpplr_Content__c (id=listOfFolders[0].External_Folder_Id__c);
	    		simContent.Is_Deleted__c = true;
	    		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
	    		SIMPESAPI.accessController().updateAsUser(simContent,new List<Schema.SObjectField>{Simpplr_Content__c.is_Deleted__c});
	    	}
		}
	}
	
	public void setFolderName(String folderId, String name) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', folderId);
		String folderQuery = 'select id, Parent_Folder__c, Parent_Folder__r.name__c,External_Folder_Id__c, Site__c from Folder__c where id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		
		String siteId = null;
		String parentFolderId = null;
		if(!listOfFolders.isEmpty()) {
			siteId = listOfFolders[0].Site__c;
			parentFolderId = listOfFolders[0].Parent_Folder__c;
		}
		
		if(isDuplicateFolder(siteId, folderId, name, parentFolderId)) {
    		throw new SimpplrException(ServiceConstants.FOLDER_DUPLICATE_NAME_ERROR_MESSAGE);
    	} else {
			if(!listOfFolders.isEmpty()) {
				Folder__c folderObj = listOfFolders[0];
				if('Albums'.equalsIgnoreCase(folderObj.Parent_Folder__r.name__c)){
					List<Simpplr_Content__c> listOfAlbumContent = [Select id From Simpplr_Content__c Where id =:folderObj.External_Folder_Id__c WITH SECURITY_ENFORCED];
					if(!listOfAlbumContent.isEmpty()){
						listOfAlbumContent[0].Title__c = name;
		    			SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Content__c> (listOfAlbumContent),
		    												new List<Schema.SObjectField>{
																	Simpplr_Content__c.Title__c});	
						
					}
				}
				folderObj.name__c = name;
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		    	SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c> (listOfFolders),
		    												new List<Schema.SObjectField>{
																	Folder__c.name__c});															
			}
		}
	}
	
	public void setExternalFolderName(String externalFolderId, String name, String folderType) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', externalFolderId);
		soqlParamMap.put('soqlParam2', folderType);
		String folderQuery = 'select id, name__c from Folder__c where External_Folder_Id__c=:soqlParam1 and Type__c=:soqlParam2 And is_Deleted__c=false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		
		if(!listOfFolders.isEmpty()) {
			for(Folder__c folderObj : listOfFolders) {
				folderObj.name__c = name;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c> (listOfFolders),
	    												new List<Schema.SObjectField>{
																Folder__c.name__c});
		}
	}
	
	public FileListingWrapper setFolderPermissions(String folderId, String permissions) {
		List<Folder__c> listOfFolders = getIntranetFolderAndSubFolderDetails(folderId).values();
		
		logger.logDebug('FolderDao.setFolderPermissions --> listOfFolders :: ' + listOfFolders);
		if(!listOfFolders.isEmpty()) {
			for(Folder__c folderObj : listOfFolders) {
				folderObj.Permissions__c = permissions;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c> (listOfFolders),
	    												new List<Schema.SObjectField>{
																Folder__c.Permissions__c});
		}
		
    	FileListingWrapper wrapperObj = ObjectToWrapperAdapter.folderToWrapper(listOfFolders[0],null);
     	wrapperObj.canChangeName = true;
     	wrapperObj.canSetPermissions = true;
     	return wrapperObj;
	}
	
	public void setExternalFolderPermissions(String siteId, String externalFolderId, String permissions, String folderType) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', externalFolderId);
		String folderQuery = 'select id from Folder__c where External_Folder_Id__c=:soqlParam1 And is_Deleted__c=false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(!listOfFolders.isEmpty()) {
			for(Folder__c folderObj : listOfFolders) {
				folderObj.Permissions__c = permissions;
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c> (listOfFolders),
	    												new List<Schema.SObjectField>{
																Folder__c.Permissions__c});
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
    public List<Folder__c> getSiteChatterWriteFolders(String directory, String termArg,
			String filterArg, String siteId, String sortBy ) {
		
		String gDriveString = ServiceConstants.STORAGE_TYPE_GDRIVE_STRING;
		List<String> unlistedSiteRestrictedSystemFolderList = null;		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', gDriveString);
		soqlParamMap.put('soqlParam3', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
		String queryStr = BASE_QUERY + 'And Site__c=:soqlParam1 And Is_Hidden__c = false And Is_System_Folder__c = false AND Type__c != :soqlParam2 ';
		queryStr += 'AND Type__c != :soqlParam3 ';
		if(String.isNotBlank(termArg)){
			queryStr += 'And Name__c like \'%'+termArg+'%\' '; 
		}
		if(String.isNotBlank(directory)) {
			soqlParamMap.put('soqlParam3', directory);
			queryStr += 'And Parent_Folder__c =:soqlParam3 '; 
		} else if(String.isBlank(termArg)){
			queryStr += 'And Parent_Folder__c =null '; 
		}
		
		if(SiteContext.isCurrentUserSiteManager ||
    		 (UserContext.isUserAppModerator && SiteContext.isPublicSite)) {
    		// Pull ReadOnly folders as well 	
		} else {
			queryStr += 'And Permissions__c=\'readwrite\' '; 
		}
		
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			queryStr += 'Order by CreatedDate desc ';
		} else {
			queryStr += 'Order by Name__c asc ';
		}

		logger.logDebug('FolderDao.getSiteChatterWriteFolders --> queryStr :: ' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}

	public List<Folder__c> getGoogleDriveLinkedFolderForASite(String siteId, Integer offset, Integer recordLimit, String sortBy, String ownedById, String filter) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String queryStr = BASE_QUERY;
		logger.logDebug('FolderDao.getGoogleDriveLinkedFolderForASite.siteId--->' + siteId);
		soqlParamMap.put('soqlParam1', siteId);
		queryStr+= ' And Site__c =:soqlParam1  AND type__c =\''+IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE+'\' ';
		queryStr += ' AND  Is_System_folder__c = false '; 
		if(String.isNotBlank(ownedById)) {
			soqlParamMap.put('soqlParam2', ownedById);
			queryStr += ' AND OwnerId =: soqlParam2 '; 
		}
		if(String.isNotBlank(filter)) {
			queryStr += getFilterCondition(filter);
		}
		queryStr += getSortOrderCondition(sortBy);
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		logger.logDebug('FolderDao.getGoogleDriveLinkedFolderForASite.query------->' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		
	}

    
	public List<Folder__c> getSiteChatterFolders(String directory, String termArg, Integer offset, Integer recordLimit,
			String filterArg, String siteId, String sortBy, Boolean isMediaManager) {
		List<String> unlistedSiteRestrictedSystemFolderList = null;	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);	
		String queryStr = BASE_QUERY + 'And Site__c=:soqlParam1 ';
		if(String.isNotBlank(termArg)){
			queryStr += 'And Name__c like \'%'+termArg+'%\' '; 
		}
		if(String.isNotBlank(directory)) {
			soqlParamMap.put('soqlParam2', directory);
			queryStr += 'And Parent_Folder__c =:soqlParam2 '; 
		} else if(String.isBlank(termArg)){
			queryStr += 'And Parent_Folder__c =null '; 
		}
		
		// Do not fetch Box/CRM System Folders for Media-manager 
		if(isMediaManager != null && isMediaManager) {
			queryStr += 'And (Name__c NOT IN (\'Box Files\', \'CRM Files\', \'Sharepoint Files\', \'Onedrive Files\', \'Google Drive Files\', \'Dropbox Files\') OR Is_System_Folder__c = false) ';
		}
		
		// Hide box folder if box is not connected or Site storage location is not box
		Boolean isStorageLocationBox = 'Box'.equalsIgnoreCase(SiteContext.fileStorageSource);
		if(UserContext.isBoxConnected == false || isStorageLocationBox == false) {
			String boxSystemFolderName = EFSConstants.EFS_SYSTEM_FOLDERS_MAP.get('box');
			soqlParamMap.put('soqlParam3', boxSystemFolderName);
			queryStr += 'And Name__c != :soqlParam3 ';
		} 
		
		// Hide CRM folder ifSite storage location is not CRM
		Boolean isStorageLocationCRM = 'CRM'.equalsIgnoreCase(SiteContext.fileStorageSource);
		if(isStorageLocationCRM == false) {
			String crmSystemFolderName = ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.get('CRM_FILES');
			soqlParamMap.put('soqlParam4', crmSystemFolderName);
			queryStr += 'And Name__c != :soqlParam4 ';
		}
		if(!SimpplrContext.isNativeVideo) {
			queryStr += 'And Type__c != \'native_video\' ';
		}
		
		if(SimpplrContext.showHiddenFolders == false){
			queryStr += 'And Is_Hidden__c = false ';
		}
		
		queryStr += getSortOrderCondition(sortBy);
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		logger.logDebug('FolderDao.getSiteChatterFolders --> queryStr :: ' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}
	
	public Boolean isSystemFolder(String siteId, String directory) {
		Boolean isSystemFolder = false;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', directory);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'Select id from Folder__c where is_deleted__c = false AND Is_System_Folder__c=true And id=:soqlParam1 and site__c=:soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(listOfFolders.size() > 0) {
			isSystemFolder = true;
		}
		return isSystemFolder;
	}
	
	public List<Folder__c> getSystemFoldersForSite(String siteId, String folderName) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		String queryStr = 'Select id, Name__c From Folder__c Where Site__c =:soqlParam1 and Is_System_Folder__c = true And Is_Deleted__c=false ';
		if(String.isNotBlank(folderName)) {
			soqlParamMap.put('soqlParam2', folderName);
			queryStr += 'And Name__c =:soqlParam2 ';
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfSystemFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		return listOfSystemFolders;
	}
	
	public List<Folder__c> getSiteLinkedBoxFolders(Integer offset, Integer recordLimit, String siteId, String sortBy) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
   		String queryStr = BASE_QUERY + 'And is_System_Folder__c=false And type__c=\'Box\' And Site__c=:soqlParam1 ';
   							
		queryStr += getSortOrderCondition(sortBy);
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}
	
	public List<Folder__c> getSiteCRMLibraries(Integer offset, Integer recordLimit, String siteId, String sortBy) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
   		String queryStr = BASE_QUERY + 'And type__c=\'CRM\' And Site__c=:soqlParam1 AND Is_System_Folder__c = false ';
   							
		queryStr += getSortOrderCondition(sortBy);
		queryStr += ' limit ' + recordLimit + ' offset '+offset;
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}
	
	public Map<String, String> getboxCollaborationIdMap(String externalFolderId, String siteId) {
		Map<String, String> boxCollaborationIdMap = new Map<String, String>();
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', externalFolderId);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'select Box_Collaboration_Id__c from Folder__c ' +
			' where External_Folder_Id__c =: soqlParam1 ' +
			' And site__c=:soqlParam2 And is_Deleted__c=false and Type__c=\'Box\'';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		
		for(Folder__c folderObj:listOfFolders) {
			Map<String, String> folderCollaborationIdMap = (Map<String, String>)JSON.deserialize(folderObj.Box_Collaboration_Id__c, Map<String, String>.class);
			boxCollaborationIdMap.putAll(folderCollaborationIdMap);
		}
		return boxCollaborationIdMap;
	}
	
	public String getExternalFolderPermissions(String externalFolderId, String siteId) {
		String permissions = 'read';
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', externalFolderId);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'select permissions__c from Folder__c ' +
			' where External_Folder_Id__c =: soqlParam1 ' +
			' And site__c=:soqlParam2 And is_Deleted__c=false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(!listOfFolders.isEmpty()) {
			if('read'.equalsIgnoreCase(listOfFolders[0].permissions__c)) {
				permissions = 'read';
			} else {
				permissions = 'readwrite';
			}
		}
		return permissions;
	}
	
	private String getSortOrderCondition(String sortby){
		String queryStr = '';
		if(String.isNotBlank(sortby)){
			String orderByField = '';
	        String order = '';
	        if (sortby.equalsIgnoreCase('alphabetical')) {
	        	if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					orderByField = 'CreatedDate';
					order = 'DESC';
				} else {
					orderByField = 'Name__c';
					order = 'ASC';
				}
	        }else if (sortby.equalsIgnoreCase('createdNewest') || sortBy.equalsIgnoreCase('createdOldest')) {
				orderByField = 'CreatedDate';
		    	order = sortBy.equalsIgnoreCase('createdNewest')? 'DESC' : 'ASC';
            } else if (sortby.equalsIgnoreCase('modifiedNewest') || sortby.equalsIgnoreCase('modifiedOldest')) {
            	orderByField = 'LastModifiedDate';
		        order = sortBy.equalsIgnoreCase('modifiedNewest')? 'DESC' : 'ASC';
			}
			
			queryStr += ' ORDER BY Is_External_System_Folder__c DESC, Is_System_Folder__c DESC, ' + orderByField + ' ' + order ;

			if( !SimpplrContext.isFeatureEnabled('Full_External_Search')) {
				queryStr += ', Name__c ';
			}
		} else {
			queryStr += ''; 
		}
        return queryStr;
	}

	private String getFilterCondition(String filterArg) {
		String filterCondition = ' ';
		
		if('this_week'.equalsIgnoreCase(filterArg)) {
			filterCondition = ' And  LastModifiedDate = THIS_WEEK ';
		}
		else if('last_week'.equalsIgnoreCase(filterArg)) {
			filterCondition = ' And  LastModifiedDate = LAST_WEEK ';
		}
		else if('this_month'.equalsIgnoreCase(filterArg)) {
			filterCondition = ' And  LastModifiedDate = THIS_MONTH ';
		}
		
		return filterCondition;
	}
	
	@future
	public static void deleteAllIntranetSubFoldersAndFiles(String folderId) {
		String folderPath = '%' + folderId + '%';
		List<String> listOfFolderIds = new List<String>(); 
		listOfFolderIds.add(folderId); 
		List<Folder__c> listOfFoldersToDelete  = [select id, name__c from  folder__c where Is_System_Folder__c = false AND path__c like :folderPath WITH SECURITY_ENFORCED];
		if(listOfFoldersToDelete.size() > 0) {
			for(Folder__c folderObj:listOfFoldersToDelete) {
				folderObj.is_Deleted__c = true;
				listOfFolderIds.add(folderObj.Id); 
			}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfFoldersToDelete),new List<Schema.SObjectField>{Folder__c.is_Deleted__c});
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfFolderIds);
    	String filesQuery = 'select Content_Document__c from File__c where Folder__c =:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<File__c> listOfFilesToDelete = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
    	if(listOfFilesToDelete.size() > 0) {
	    	List<ContentDocument> listOfContentDocuments = new List<ContentDocument>();
	    	for(File__c fileObj:listOfFilesToDelete) {
	    		if(String.isNotBlank(fileObj.Content_Document__c)){
		    		ContentDocument documentObj = new ContentDocument(Id=fileObj.Content_Document__c);
		    		listOfContentDocuments.add(documentObj); 
	    		}
	    		fileObj.is_Deleted__c = true;
	    	}
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().deleteAsUser(listOfContentDocuments);
			
	    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(listOfFilesToDelete),new List<Schema.SObjectField>{File__c.is_Deleted__c});
    	}
	}
	
	@TestVisible 
    public Boolean isCRMAvailable() {
    	String queryStr = 'select Id from ContentVersion where Origin = \'C\'';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND networkid = null';
    	}
    	
    	queryStr += ' LIMIT 1';
    	
		List<ContentVersion> listOfContentVersion = Database.query(queryStr);
										 
		return (listOfContentVersion.size() > 0) ? true : false;
    }
    
    public Boolean isDuplicateFolder(String siteId, String folderId, String folderName, String parentFolderId) {
    	boolean returnVal = false;
    	Boolean isSystemFolder = false;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', folderName);
		soqlParamMap.put('soqlParam2', siteId);
		soqlParamMap.put('soqlParam3', parentFolderId);
		soqlParamMap.put('soqlParam4', folderId);
		String folderQuery = 'select id from Folder__c where Name__c = :soqlParam1 And Is_Deleted__c = false ' +
			' And site__c = :soqlParam2 And Parent_Folder__c = :soqlParam3 And id != :soqlParam4';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(listOfFolders.size() > 0) {
			returnVal = true;
		}
    	return returnVal;
	}	
    
	// Function to get the Site Root Folder Details
	public List<Folder__c> getEFSFolders(String siteId, String externalFolderId, String storageType, String orderBy) {
		Logger.logDebug('FolderDao.getEFSFolders(' + siteId + ',' + externalFolderId + ')');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String queryStr = '';
		if(String.isNotBlank(externalFolderId)) {
			// Returns the non-system folders
			if(storageType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING) ||
				storageType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING)  ||
			   storageType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING) || 
			   storageType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING)) {
			   	if(externalFolderId == 'all') {
			   		// Returns all non-system folder
					soqlParamMap.put('soqlParam1', storageType);
			   		queryStr = BASE_QUERY + 'And type__c=:soqlParam1 And Is_System_Folder__c=false';
			   	} else {
			   		// Returns specific non-system folder
					soqlParamMap.put('soqlParam1', storageType);
					soqlParamMap.put('soqlParam2', externalFolderId);
			   		queryStr = BASE_QUERY + 'And type__c=:soqlParam1 And Is_System_Folder__c=false And External_Folder_Id__c=:soqlParam2';	
			   	}
			} else if(storageType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
				soqlParamMap.put('soqlParam1', storageType);
				soqlParamMap.put('soqlParam2', externalFolderId);
				queryStr = BASE_QUERY + 'And type__c=:soqlParam1 And Is_System_Folder__c=false And Path__c=:soqlParam2';	
			}
			
			if(String.isNotBlank(siteId)) {
				soqlParamMap.put('soqlParam3', siteId);
				queryStr += ' And site__c=:soqlParam3';
			}
		} else if(String.isNotBlank(siteId)){
			// Return the system folders
			soqlParamMap.put('soqlParam1', storageType);
			soqlParamMap.put('soqlParam3', siteId);
			queryStr = BASE_QUERY + 'And type__c=:soqlParam1 And Is_System_Folder__c=true And site__c=:soqlParam3';
		} else {
			soqlParamMap.put('soqlParam1', storageType);
			queryStr = BASE_QUERY + 'And type__c=:soqlParam1 And Is_System_Folder__c=true';
		}
		
		queryStr += ' And site__r.Is_Active__c=true AND site__r.Is_Deleted__c=false ';
		logger.logDebug('FolderDao.getEFSFolders()-411-query--->'+queryStr);
		if(String.isNotBlank(orderBy)){
			if('createdOldest'.equalsIgnoreCase(orderBy)){
				queryStr += ' order by createdDate asc ';
			} else if('createdNewest'.equalsIgnoreCase(orderBy)){
				queryStr += ' order by createdDate desc ';
			} else if('modifiedOldest'.equalsIgnoreCase(orderBy)){
				queryStr += ' order by lastmodifiedDate asc ';
			} else if('modifiedNewest'.equalsIgnoreCase(orderBy)){
				queryStr += ' order by lastmodifiedDate desc ';
			} else if('alphabetical'.equalsIgnoreCase(orderBy)){
				if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
					queryStr += ' order by CreatedDate desc ';
				} else {
					queryStr += ' order by Name__c ';
				}
			}
		}
		logger.logDebug('FolderDao.getEFSFolders()-425-query--->'+queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}
	
	// Function to get the Folder Details
	public Folder__c getEFSSiteFolder(String siteId, String storageType) {
		List<Folder__c> folds = getEFSFolders(siteId, '', storageType, null);
		
		return (folds.size() > 0 ? folds[0]: null);
	}
	
	// Function to get the Folder Details For MyFiles Page
	public List<Folder__c> getEFSSiteFolderForMyFilesPage(String storageType) {
		String queryStr = '';
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', storageType);
		queryStr = BASE_QUERY + 'And type__c=:soqlParam1 And Is_System_Folder__c=true' ;
				
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}
		
	public Folder__c getSystemFolder(String directory) {
		String queryStr = '';
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', directory);
		queryStr = BASE_QUERY + 'And Is_System_Folder__c=true AND id=:soqlParam1' ;
				
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folds = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		return (folds.size() > 0 ? folds[0]: null);
	}
    
    public void deleteEFSFolderRecord(Id foldId) {
    	Folder__c newFold = new Folder__c(Id=foldId);
    	
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().deleteAsUser(newFold);
    }
    
    public static Boolean syncPathName(String provider, String appName, Set<Id> folderIds) {
    	Boolean statusFlag = false;
		List<Folder__c> listOfFolders = new List<Folder__c>();

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String query = 'select Id, Path__c, Site__r.Name from Folder__c where ';
		if(folderIds != NULL && !folderIds.isEmpty()) {
			// Execute for the selected folder record
			soqlParamMap.put('soqlParam1', folderIds);
			query += 'Id IN :soqlParam1 AND ';
		}
		
		soqlParamMap.put('soqlParam2', provider);
		query += 'Type__c=:soqlParam2 AND Is_System_Folder__c=true AND is_Deleted__c=false';
		
		String newPath = '/' + appName + '/';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		for(Folder__c folderObj : (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap)) {
			folderObj.Path__c = newPath + folderObj.Site__r.Name;
			folderObj.External_Folder_Id__c = newPath + folderObj.Site__r.Name;
			listOfFolders.add(folderObj);					
		}
		
		if(!listOfFolders.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    		SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c> (listOfFolders),
    												  new List<Schema.SObjectField>{Folder__c.Path__c,
    												  								Folder__c.External_Folder_Id__c});
			statusFlag = true;
		}
		
		return statusFlag;
    }
    
    // Function to return the List of SiteLiteWrapper linked to a box file 
    public Map<String, List<SiteLiteWrapper>> getBFRelatedSites(Set<String> rootFolderIds) {
    	
    	Map<String, List<SiteLiteWrapper>> boxFolderAndSitesMap = new Map<String, List<SiteLiteWrapper>>();
    	
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', rootFolderIds);
    	String queryStr = 'Select Id, Name__c, External_Folder_Id__c, '
    			 + ' Site__c, Site__r.Name, Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c, Site__r.Landing_Page__c, Site__r.Title_Content_Version__c'
    			 + ' FROM Folder__c' 
    			 + ' where External_Folder_Id__c = :soqlParam1 And Is_Deleted__c = false and Type__c = \'box\' AND Site__r.Is_Deleted__c = false'; 
		
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> lstOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
    	
    	List<SiteLiteWrapper> siteWrapList = null;
    	
    	for(Folder__c folderObj : lstOfFolders) {
			siteWrapList = new List<SiteLiteWrapper>();
		
			if(boxFolderAndSitesMap.containsKey(folderObj.External_Folder_Id__c)){
				siteWrapList = boxFolderAndSitesMap.get(folderObj.External_Folder_Id__c);
			}
			
			siteWrapList.add(getSiteWrapperObjFromFolder(folderObj));
			boxFolderAndSitesMap.put(folderObj.External_Folder_Id__c, siteWrapList);
		}
		
		return boxFolderAndSitesMap;
    }
    
    private SiteLiteWrapper getSiteWrapperObjFromFolder(Folder__c folderObj) {
    	SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
    	
		siteWrapObj.siteId= folderObj.Site__r.id;
		siteWrapObj.name=folderObj.Site__r.Name;
		siteWrapObj.url= PageContext.getPageURL(Pages.app) +'?u=/site/' + folderObj.Site__r.id + '/' + folderObj.Site__r.Landing_Page__c;
		//siteWrapObj.fileURL = PageContext.getPageURL(Pages.FileDetail) +'?fileId=' + cdl.ContentDocumentId+'&siteId=' + siteObj.id;
		siteWrapObj.img = String.isNotBlank(folderObj.Site__r.Title_Content_Version__c) ? Utility.getFileDownloadURLFor720By480(folderObj.Site__r.Title_Content_Version__c) : null;
		siteWrapObj.access = folderObj.Site__r.Site_Type__c; 
		siteWrapObj.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(folderObj.Site__r.Site_Type__c)?true:false;
		siteWrapObj.isListed = ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(folderObj.Site__r.Site_Type__c)?false:true;

		return siteWrapObj;
    }
	    
    public void createMSStorageFoldersForSite(String siteId, String sharepointInstanceId, String storageType, Boolean isSystemFolder, String externalFolderId, String externalDriveId, String folderName, Criteria.OwnerWrapper owner, String webUrl) {
    	Folder__c storageFolder = new Folder__c();
		storageFolder.Name__c = String.isBlank(folderName)? EFSConstants.EFS_SYSTEM_FOLDERS_MAP.get(storageType):folderName;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', storageType);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'SELECT id FROM Folder__c WHERE  Type__c=:soqlParam1 AND Site__c=:soqlParam2  ORDER BY Is_System_Folder__c DESC';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		
		storageFolder.Site__c = siteId;
		storageFolder.Is_System_Folder__c  = isSystemFolder;
		storageFolder.Type__c = storageType;
		storageFolder.Permissions__c = 'Read';
		storageFolder.Is_Hidden__c = false;
		storageFolder.SP_Instance_Id__c = sharepointInstanceId;
		if(storageType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING)) {
			storageFolder.External_Folder_Id__c = externalDriveId;
			storageFolder.Path__c = webUrl;
		} else {
			storageFolder.External_Folder_Id__c = externalFolderId;
			storageFolder.EFS_Drive_Id__c = externalDriveId;
			storageFolder.Path__c = folderName;
		}
		storageFolder.Is_Deleted__c = false;
		if(owner != null) {
			if(String.isNotBlank(owner.id)) {
				storageFolder.People__c = owner.id;
			} else {
				storageFolder.Linked_Folder_Owner__c = String.isBlank(owner.name) ? 
						LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.location.not_available') 
						: owner.name;
			}
		} else {
			storageFolder.People__c = UserContext.peopleId;
		}
		if(isSystemFolder == false){
			if(String.isNotBlank(folderName) && folderList.isEmpty() == false){
				storageFolder.Parent_Folder__c = folderList[0].id;
			}
			List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
				Folder__c.Name__c,
				Folder__c.Parent_Folder__c,
				Folder__c.Site__c,
				Folder__c.Is_System_Folder__c,
				Folder__c.Type__c,
				Folder__c.Permissions__c,
				Folder__c.Is_Hidden__c,
				Folder__c.SP_Instance_Id__c,
				Folder__c.External_Folder_Id__c,
				Folder__c.Path__c,
				Folder__c.Is_Deleted__c,
				Folder__c.People__c,
				Folder__c.EFS_Drive_Id__c
			};
			List<Folder__c> recordToUpsert = new List<Folder__c>();
			recordToUpsert.add(storageFolder);
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().upsertAsUser(recordToUpsert,fieldList);
		} else {
			if(folderList.isEmpty() == false){
				storageFolder.id = folderList[0].id;
			}
			upsert storageFolder;
		}
    }
    
    public void deleteMSStorageFoldersForSite(String siteId, String storageType, Boolean isSystemFolder, String externalFolderId, String externalDriveId) {
    	String efId = '';
    	if(storageType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING)) {
    		efId = externalDriveId;
    	} else {
    		efId = externalFolderId;
    	}
    	
    	if(String.isNotBlank(efId)) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', efId);
			soqlParamMap.put('soqlParam2', siteId);
			String folderQuery = 'select Id, Is_Deleted__c from Folder__c where External_Folder_Id__c=:soqlParam1 and site__c=:soqlParam2 and is_Deleted__c= false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
	    	for(Folder__c folderObj : listOfFolders){
	    		folderObj.Is_Deleted__c = true;
	    	}
	
			if(!listOfFolders.isEmpty()) {
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    		SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c> (listOfFolders),
	    												  new List<Schema.SObjectField>{Folder__c.Is_Deleted__c});
			}
    	}
	}
    
    public void deletLinkedFoldersForSite(String storageType, String externalFolderId, String externalDriveId) {
    	String efId = '';
    	if(storageType.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING)) {
    		efId = String.isBlank(externalFolderId) ? externalDriveId : '';
    	} else {
    		efId = externalFolderId;
    	}
    	
    	if(String.isNotBlank(efId)) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', efId);
			String folderQuery = 'select Id, Is_Deleted__c, OwnerId from Folder__c where External_Folder_Id__c=:soqlParam1 and is_Deleted__c= false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
	    	if(listOfFolders.isEmpty() == false){
	    		for(Folder__c folderRecord : listOfFolders) {			
	    			folderRecord.Is_Deleted__c = true;
	    		}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(listOfFolders), new List<Schema.SObjectField>{
					Folder__c.Is_Deleted__c
				});
	    	}
    	}
	}
	
	public Integer getTotalLinkedFoldersCount(String storageProvider, String siteId) {
		//drive type is NA for non google drive file management systems
		return getTotalLinkedFoldersCount(storageProvider, siteId, null);
	}

	//Overloaded method with 3 input paraments, used in google drive linked sites by driveType
	public Integer getTotalLinkedFoldersCount(String storageProvider, String siteId, String driveType) {
		Integer recordCount = 0;

		Map<String, Object> soqlParamMap = new Map<String, Object>();
		
		String query = 'SELECT count() FROM Folder__c WHERE Is_System_Folder__c = false AND Is_Deleted__c = false';

		if(storageProvider == ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING && String.isNotBlank(driveType)){
			soqlParamMap.put('soqlParam1', driveType);
			query += ' AND Type__c=\'' + ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING + '\' AND Drive_Type__c = :soqlParam1';
		}else{
			soqlParamMap.put('soqlParam1', storageProvider);
			query += ' AND Type__c = :soqlParam1';
		}

		if(String.isNotBlank(siteId)) {
			soqlParamMap.put('soqlParam2', siteId);
			query += ' AND Site__c = :soqlParam2';
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		recordCount = SIMPESAPI.accessController().countQueryAsUser(query, soqlParamMap);

		return recordCount;
	}

	public List<Folder__c> getSitesWithFileStortage(Criteria.File fileCriteriaObjArg, Integer recordLimit, Integer offset) {		
		List<CollaborationGroupMember> cgmList = [SELECT  CollaborationGroupId FROM CollaborationGroupMember where CollaborationGroup.collaborationType !='public' and MemberId =:UserInfo.getUserId() WITH SECURITY_ENFORCED];
		Set<Id> cgIdSet = new Set<Id>();
		for(CollaborationGroupMember cgm: cgmList){
			cgIdSet.add(cgm.CollaborationGroupId);
		}
		String filter = fileCriteriaObjArg.filter;
		String ownedById = null;
		if(String.isNotBlank(fileCriteriaObjArg.owner) && 'owned_by_me'.equalsIgnoreCase(fileCriteriaObjArg.owner)) {
			ownedById = UserContext.id;
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String queryStr = BASE_QUERY;
		soqlParamMap.put('soqlParam1', fileCriteriaObjArg.provider);
		queryStr += ' AND type__c =: soqlParam1 AND Is_System_folder__c = true ';
		queryStr += ' AND Site__r.Is_Active__c=true AND Site__r.Is_Deleted__c = false AND Site__r.Show_In_Simpplr__c = true '; 
		soqlParamMap.put('soqlParam2', cgIdSet);
		queryStr += ' AND Site__r.File_Storage_Source__c=: soqlParam1 AND (Site__r.Site_Type__c = \'Public\' OR Site__r.Chatter_Group_Id__c IN: soqlParam2)  '; 
		if(String.isNotBlank(ownedById)) {
			soqlParamMap.put('soqlParam3', ownedById);
			queryStr += ' AND OwnerId =: soqlParam3 '; 
		}
		if(String.isNotBlank(filter)) {
			queryStr += getFilterCondition(filter);
		}
		queryStr += getSortOrderCondition(fileCriteriaObjArg.sortBy);	
		queryStr += ' limit ' + recordLimit + ' offset ' + offset;
		logger.logDebug('FolderDao.getSitesWithFileStortage()----queryStr----' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

	}

	public Map<Id, Folder__c> getVideoFolderDetails(List<String> listOfFolderIds) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfFolderIds);
    	String queryStr = BASE_QUERY + 'And id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return new Map<Id, Folder__c>((List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap));
	}

	public List<Folder__c> getFoldersById(List<String> listOfFolderIds) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', listOfFolderIds);
    	String queryStr = BASE_QUERY + 'And id=:soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}

	public String getSiteVideosSystemFolderId(String siteId) {
		String siteVideosSystemFolderId;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', ServiceConstants.SITE_VIDEOS_SYSTEM_FOLDER);
		soqlParamMap.put('soqlParam2', siteId);
		String folderQuery = 'select id from Folder__c where Name__c=:soqlParam1 And Site__c=:soqlParam2 And Is_System_Folder__c = true AND Parent_Folder__c=null ' + 
			' AND Is_Deleted__c = FALSE';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(!folderList.isEmpty()) {
			siteVideosSystemFolderId = folderList[0].id;
		}
		return siteVideosSystemFolderId;
	}
	public List<Folder__c> getSiteVideoFolders(Criteria.File fileCriteriaObjArg) {
		String siteId = fileCriteriaObjArg.siteId;
		String folderId =  fileCriteriaObjArg.directory;
		String folderPath;
		String siteVideosSystemFolderId;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', folderId);
		String query = 	'SELECT name__c, Is_System_Folder__c, Parent_Folder__r.name__c, Permissions__c, Parent_Folder__r.Is_System_Folder__c, ' +
						'Site__c, People__c, People__r.Full_Name__c, LastModifiedDate ' +
						'FROM Folder__c ' +
						'WHERE site__c=:soqlParam1 AND is_deleted__c=false ' +
						'AND Parent_Folder__c =: soqlParam2 ';
		if(ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter)) {
			query += 'AND Type__c = \'native_video\' ';
			if(String.isNotBlank(folderPath)) {
				siteVideosSystemFolderId = siteVideosSystemFolderId = getSiteVideosSystemFolderId(siteId);
				folderPath = siteVideosSystemFolderId + '%';
				soqlParamMap.put('soqlParam3', folderPath);
				query += ' AND Path__c like : soqlParam3 ';
			}
		}
		if(fileCriteriaObjArg.isMediaManager != null && fileCriteriaObjArg.isMediaManager) {
			query += ' And (Name__c NOT IN (\'Box Files\', \'CRM Files\', \'Sharepoint Files\', \'Onedrive Files\', \'Google Drive Files\', \'Dropbox Files\') OR Is_System_Folder__c = false) ';
		}
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
		return folderList;
    }
    
    public List<Folder__c> getGoogleDriveLinkedFolder(String folderId) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		String queryStr = BASE_QUERY;
		logger.logDebug('FolderDao.getGoogleDriveLinkedFolder.folderId--->' + folderId);
		soqlParamMap.put('soqlParam1', folderId);
		queryStr+= ' And id =:soqlParam1  AND type__c =\''+IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE+'\' ';
		queryStr += ' AND  Is_System_folder__c = false'; 
		logger.logDebug('FolderDao.getGoogleDriveLinkedFolder.query------->' + queryStr);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		
	}

	public List<Folder__c> getSiteGoogleSharedDriveDetails(String siteId, String storage){
		Map<String, Object> soqlParamMap = new Map<String, Object>();

		String queryStr = 'SELECT Id, Name__c, Type__c, Site__c, External_Folder_Id__c, Drive_Type__c FROM Folder__c WHERE Is_System_folder__c = false AND Is_Deleted__c = false';

		soqlParamMap.put('soqlParam1', siteId);
		queryStr += ' AND Site__c =:soqlParam1';

		soqlParamMap.put('soqlParam2', storage);
		queryStr += ' AND Type__c =:soqlParam2';

		soqlParamMap.put('soqlParam3', ServiceConstants.GOOGLE_DRIVE_TYPE_SHARED_DRIVE);
		queryStr += ' AND Drive_Type__c =:soqlParam3';

		logger.logDebug('FolderDao.getSiteGoogleSharedDriveDetails.query------->' + queryStr);

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		return (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
	}

	public void unlinkAllSharedDriveFolder() {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
		soqlParamMap.put('soqlParam2', ServiceConstants.GOOGLE_DRIVE_TYPE_SHARED_DRIVE);
		String queryStr = 'SELECT Id FROM Folder__c WHERE Type__c=: soqlParam1 And Site__c != null And Drive_Type__c =: soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList =  (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(!folderList.isEmpty()) {
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().deleteAsUser(folderList);
		}
	}

    /**	
    * @description This method unlinks all folders from a site and related to a storage type
    * @param siteId This is the SFDC Id for the site whose folders will be unlinked
	* @param storageType This is the storageType whose folders will be unlinked
    * @return void
    */	
	public void unlinkAllFoldersFromSite(String siteId, String storageType){
		
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', storageType);
		String queryStr = 'SELECT Id FROM Folder__c WHERE Site__c=: soqlParam1 And Type__c =: soqlParam2 and Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> siteFolders =  (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);				
		
		for(Folder__c folder : siteFolders){
			folder.Is_Deleted__c = true;
		}

		if(!siteFolders.isEmpty()){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(siteFolders), new List<Schema.SObjectField>{
				Folder__c.Is_Deleted__c
			});
		}

	}


	/**
	 * @description This method checks if any my drive folder is linked to a site
	 * @param siteId
	 * @return result of type boolean
	 */
	public Boolean isMyDriveFolderLinkedForSite(String siteId) {
		Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
		soqlParamMap.put('soqlParam2', IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE);
		soqlParamMap.put('soqlParam3', IntegrationConstants.GOOGLE_DRIVE_TYPE_MYDRIVE);
		String query = 'SELECT Id, Site__c, Name__c, Type__c, Drive_Type__c, External_Folder_Id__c, Is_Deleted__c '+
						' FROM Folder__c where Type__c =: soqlParam2  and Drive_Type__c =: soqlParam3 '+
						' and Is_Deleted__c = false and Site__c =: soqlParam1 LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
		Boolean result = folderList.size() > 0 ? true : false; 
		return result;
	}

	/**
	 * @description This method checks if the current folder is linked to a site
	 * @param folderId
	 * @param siteId
	 * @param type
	 * @return result of type boolean
	 */
	public Boolean isFolderAlreadyLinkedForSite(String folderId, String siteId, String type) {
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', folderId);
		soqlParamMap.put('soqlParam2', siteId);
		soqlParamMap.put('soqlParam3', type);
		String folderQuery = 'SELECT id from Folder__c where Type__c =: soqlParam3 and External_Folder_Id__c =: soqlParam1 and site__c =: soqlParam2 and Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfLinkedFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);											   	
		Boolean result = listOfLinkedFolders.size() > 0 ? true : false; 
		return result;
	}
	
}