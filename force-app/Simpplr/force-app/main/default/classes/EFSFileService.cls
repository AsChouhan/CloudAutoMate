/*
* Purpose: Service class for the File related activities
* 
* Constructor
* 1. EFSFileService()
* 2. EFSFileService(EFSAccessService)
*  
* Functions defined in the Class
* 01. void close()
* 02. String getFileStorage()
* 03. FileListingWrapper createFolder(Criteria.Folder)
* 04. Boolean updateFileName(String, String)
* 05. Boolean setDescription(String, String)
* 07. Boolean bookmarkFile(String)
* 08. Boolean unBookmarkFile(String)
* 09. FileDetailWrapper addFile(Criteria.File, Blob)
* 10. List<FileListingWrapper> listFiles(String, String, Integer, String, Boolean)
* 11. List<FileListingWrapper> listFiles(String, Criteria.File)
* 12. List<FileListingWrapper> searchFiles(String, Boolean, Criteria.File)
* 16. boolean deleteFile(String)
* 18. static Map<String,People_Preference__c> getEFSEmailIdWithPeoplePref()
* 23. String addDomainReader(String) - Commented
* 24. String addPermission(String, String, String)
* 27. FileDetailWrapper getFileDetail(String)
* 29. String getDownloadURL(String, String)
* 30. List<FileVersionHistoryWrapper> getFileVersions(String)
*/
	
public with sharing class EFSFileService {
	
	private Map<String,Integer> mapOfDayWithNumberOfDaysToAdd = new Map<String,Integer>{
		'Mon'=>0,
		'Tue'=>1,
		'Wed'=>2,
		'Thu'=>3,
		'Fri'=>4,
		'Sat'=>5,
		'Sun'=>6
	};
	// Instance Variables
	public EFSAccessService clientAccess { get; set; }
	public String nextPageToken { get; set; }
	public String nextPageUrl { get; set; }
	public String siteId { get; set; }
	public String msParentPermission { get; set; }

    // For Dropbox Client
	public DBAPIClient dbClient { get; set; }
	public MSAPIClient msClient {get;set;} 

	// Abstract Client for the execution and response handling
	public SCoreClient.AbstractClient client { get; set; }
    
    // list of liked files id
    List<String> listOfFileIdsinListing = new List<String>();
    
    // Map of Permission Set/Folder Id/Path to Site
    public static Map<String, SiteLiteWrapper> permSitesMap = null;
    
    // Map of EFS Id to People Preference
    public static Map<String, People_Integration__c> EFStoSimpplrUserMap = null;
        
    // Constructor for the File Storage Service
    public EFSFileService(String fileStorage) {
		this(new EFSAccessService(fileStorage, false)); 
    }
    
	// Constructor for the File Storage Service
	public EFSFileService(EFSAccessService access) {
		EFSException.addTrace('EFSFileService()');
		// Fetch the Access from the DB
		this.clientAccess = access;
			
			EFSException.addTrace('EFSFileService() Constructor 102 '+access);
			SCoreClient.Credentials cred = null;

			// Function that abstracts the Access Token Refresh from the Service, Provider classes
			if(this.clientAccess.isAccessExpired()) {
				this.clientAccess.refreshToken();
			}				
			try {
				cred = new SCoreClient.Credentials(this.clientAccess.getTokenType(), this.clientAccess.getAccessToken());
			} catch (SCoreSystemException se) {
				throw new EFSException('TokenType Error', se.getMessage());
			}
			// Based on the File Storage type set the client 
			if(this.clientAccess.dropboxFlag) {
				dbClient = new DBAPIClient(cred);
			} else if (this.clientAccess.sharepointFlag || this.clientAccess.onedriveFlag) {
				msClient = new MSAPIClient(cred, getFileStorage());
			}
				
			this.nextPageToken = null;
		//}
	}

	// Function to do the clean ups and final steps
	public void close() {
    	// Function that saves the token to DB
		if(!this.clientAccess.isSaved()) {
			this.clientAccess.saveToken();
		}
	}
	
	// Function to return the storage type
	public String getFileStorage() {
		return this.clientAccess.fileStorage;
	}
	
    // Create Folder in selected File Storage
    public FileListingWrapper createFolder(Criteria.Folder inputFolder) {
		EFSException.addTrace('createFolder');
		
    	FileListingWrapper foldWrapper = new FileListingWrapper();
    	
	    // Execute code based on the storage
	   	if(this.clientAccess.dropboxFlag) {
    		// Convert the input to desired format
    		DBAPIModelFiles.Metadata dpFold = new DBAPIModelFiles.Metadata();
    		
	   		// Set the Folder Name
	   		String foldName = inputFolder.directory + '/' + inputFolder.name;
    		
    		// Create the Resource using recent access token
    		DBAPIFiles fil = this.dbClient.files();
			try {
				// If folder already exist in the Parent
				DBAPIFiles.GetMetadataRequest foldChkReq = fil.getMetadataRequest(foldName, false);
				
				dpFold = (DBAPIModelFiles.Metadata)foldChkReq.execute();
			} catch(SCoreAppException appEx) {
				// nothing to worry
				//logger.logDebug('No existing folder');
    		}
    		
    		if(String.isBlank(dpFold.id)) {
				// Create the HTTP Request
	    		DBAPIFiles.CreateRequest request = fil.getCreateRequest(foldName, true);

	    		// Wrap the output to Simpplr File Format
	    		try {
	    			DBAPIModelFiles.CreateFolderResult addResp = (DBAPIModelFiles.CreateFolderResult)request.execute();
	    			dpFold.tag = 'folder';
					dpFold.id = addResp.metadata.id;
					dpFold.name = addResp.metadata.name;
					dpFold.path_lower = addResp.metadata.path_lower;
					dpFold.path_display = addResp.metadata.path_display;
	    		} catch(SCoreAppException appEx) {
	    			throw new EFSException(request, 'CREATION ERROR using ' + request, appEx.getMessage());
	    		}
			}
			
			checkSiteIdInContext();

			// File Id is always available in FileListingWrapper.fileId field
	    	foldWrapper = toFileListingWrapper(dpFold, null,null, '',null,false,null);
    	} else if(this.clientAccess.sharepointFlag || this.clientAccess.onedriveFlag) {
    		// Convert the input to desired format
    		MSAPIModelDriveItem.CreateFolderArg spFold = new MSAPIModelDriveItem.CreateFolderArg();
    		
	   		// Set the Folder Name
	   		spFold.name = inputFolder.name;
	   		spFold.folder = new MSAPIModelDriveItem.Folder();
    		
    		if(String.isBlank(inputFolder.rootDirectory) || inputFolder.rootDirectory == inputFolder.directory) {
    			inputFolder.rootDirectory = inputFolder.directory; 
    			inputFolder.directory = '';
    		}
    		
    		// Create the Resource using recent access token
    		MSAPIDriveItem fil = this.msClient.driveItems();
			MSAPIModelDriveItem newItem = null;
			// Create the HTTP Request
    		MSAPIDriveItem.CreateFolder request = new MSAPIDriveItem.CreateFolder(fil, 
    																			  inputFolder.rootDirectory, 
    																			  Utility.encodeUrlString(inputFolder.directory), 
    																			  spFold);

    		// Wrap the output to Simpplr File Format
    		try {
    			newItem = (MSAPIModelDriveItem)request.execute();
    		} catch(SCoreAppException appEx) {
    			if('Conflict'.equalsIgnoreCase(appEx.getMessage())){
    				throw new SimpplrException('Folder name already exists');
    			} else if('forbidden'.equalsIgnoreCase(appEx.getMessage())){
    				throw new SimpplrException(ServiceConstants.ERROR_403);
    			} else {
	    			throw new EFSException(request, 'CREATION ERROR using ' + request, appEx.getMessage());
    			}
    		}
			
			checkSiteIdInContext();

			// File Id is always available in FileListingWrapper.fileId field
	    	foldWrapper = toFileListingWrapper(newItem, getEFSIdWithPeoplePref(), inputFolder.rootDirectory, 'readwrite');
    	}
		
    	return foldWrapper;
    }
        
    // Update Folder or File Name
    public Boolean updateFileName(String fileId, String fileName) {
    	//logger.logDebug('EFSFileService updateFileName() ----fileId----' + fileId);
		EFSException.addTrace('updateFileName()');

    	if(this.clientAccess.dropboxFlag) {    		
    		DBAPIFiles dbFiles = this.dbClient.files();
    		
    		// Specific handling for folder move/rename
    		// Renaming request will have the name of the file/folder
    		// Move request will have the path
    		if(!fileName.startsWith('/')) {
    			fileName = fileId.substringBeforeLast('/') + '/' + fileName;		
    		}
			// Create the HTTP Request
	    	DBAPIFiles.MoveRequest request = dbFiles.getMoveRequest(fileId, fileName);
    		try {
    			DBAPIModelFiles.MoveResult outFile = (DBAPIModelFiles.MoveResult)request.execute();
    			return true;
    		} catch(SCoreAppException appEx) {
    			// If the from folder is not existing
    			if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT) {
    				return false;	
    			}
    			this.close();
    			throw new EFSException(request, 'UPDATION ERROR', appEx.getMessage());
    		}
    	}

    	return false;
    }
    
    public Boolean updateItemName(String driveId, String itemId, String newItemName) {  		
		MSAPIDriveItem fil = this.msClient.driveItems();
		
		MSAPIModelDriveItem.UpdateItemArg updItem = new MSAPIModelDriveItem.UpdateItemArg();
		updItem.name = newItemName;
		
		// Create the HTTP Request
    	MSAPIDriveItem.UpdateDriveItem request = new MSAPIDriveItem.UpdateDriveItem(fil, driveId, Utility.encodeURLString(itemId), updItem);
		try {
			request.execute();
			return true;
		} catch(SCoreAppException appEx) {
			this.close();
			if(appEx.getMessage().equalsIgnoreCase('forbidden')) {
				throw new SimpplrException(ServiceConstants.ERROR_403);	
			}
			throw new EFSException(request, 'UPDATION ERROR', appEx.getMessage());
		}
    }
    
    public Boolean moveItem(String driveId, String itemId, String itemName, String parentDriveId, String parentItemId) {  		
		MSAPIDriveItem fil = this.msClient.driveItems();
		
		MSAPIModelDriveItem.ItemReference parentRef = new MSAPIModelDriveItem.ItemReference();
		parentRef.driveId = parentDriveId;
		if(parentItemId == 'root') {
			MSAPIDriveItem.GetItem rootGetRequest = new MSAPIDriveItem.GetItem(fil, parentDriveId, parentItemId);
			try {
				MSAPIModelDriveItem rootItem = (MSAPIModelDriveItem)rootGetRequest.execute();
				parentRef.id = rootItem.id;	
			} catch (Exception getRootEx) {
				this.close();
				if(getRootEx.getMessage().equalsIgnoreCase('forbidden')) {
					throw new SimpplrException(ServiceConstants.ERROR_403);	
				}
				throw new EFSException(rootGetRequest, 'MOVE ERROR', getRootEx.getMessage());
			}
		} else {
			parentRef.id = parentItemId;
		}
		
		MSAPIModelDriveItem.MoveItemArg mvItem = new MSAPIModelDriveItem.MoveItemArg();
		mvItem.name = itemName;
		mvItem.parentReference = parentRef;
		
		// Create the HTTP Request
//		this.msClient.setAdditionalHeaders(new Map<String, String> { 'Prefer' => 'respond-async', 'Accept' => '*/*' });
		this.msClient.addAdditionalHeader('Prefer', 'respond-async');
    	MSAPIDriveItem.Move request = new MSAPIDriveItem.Move(fil, driveId, itemId, mvItem);
		try {
			request.execute();
			return true;
		} catch(SCoreAppException appEx) {
			this.close();
			if(appEx.getMessage().equalsIgnoreCase('forbidden')) {
				throw new SimpplrException(ServiceConstants.ERROR_403);	
			}
			throw new EFSException(request, 'MOVE ERROR', appEx.getMessage());
		}
    	
    }
    
    // Get the Files in the Folder
    public List<FileListingWrapper> listFiles(String qStr, Criteria.File fileCriteriaObj) {
    	EFSException.addTrace('listFiles(String, Criteria.File)');
    	fileCriteriaObj.size = (fileCriteriaObj.size == null ? 16 : fileCriteriaObj.size); 
		List<FileListingWrapper> fileList = new List<FileListingWrapper>();
		this.siteId = fileCriteriaObj.siteId;
		
    	if(this.clientAccess.dropboxFlag){
    		fileList = listFilesDropbox(qStr,fileCriteriaObj);
    	} else if (this.clientAccess.sharepointFlag || this.clientAccess.onedriveFlag) {
    		if(fileCriteriaObj.directory.equalsIgnoreCase('me') || fileCriteriaObj.directory.equalsIgnoreCase('sharedwithme')) {
    			fileList = listFilesMyDrive(fileCriteriaObj);
    		} else {
    			fileList = listFilesSharepoint(qStr,fileCriteriaObj);
    		}
    	}
		
        if(!listOfFileIdsinListing.isEmpty()) {
		    FileDao fileDaoObj = new FileDao();
		    Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfFileIdsinListing);
			for(FileListingWrapper fileWrapObj : fileList) {
				if(setOfLikes.contains(fileWrapObj.id)) {
					fileWrapObj.isLiked = true;
				}	
			}
    	}
    	
        return fileList;
    }
    
    @testVisible
    private String getFilterCondition(String filterArg) {
		String filterConditionStr = '';
		
		DateTime currentTime = DateTime.now();
		DateTime startTime = null;
		DateTime endTime = null;
		Date weekStartDate = (Date.today()).addDays(-mapOfDayWithNumberOfDaysToAdd.get(currentTime.format('EEE')));
		DateTime startDateTimeOfLastWeek = weekStartDate.addDays(-8);
	    
		if('this_week'.equalsIgnoreCase(filterArg)){
            startTime = weekStartDate;
//            endTime = currentTime;
        } else if('last_week'.equalsIgnoreCase(filterArg)){
            startTime = startDateTimeOfLastWeek;
            endTime = (startDateTimeOfLastWeek).addDays(+6);
        } else if('this_month'.equalsIgnoreCase(filterArg)){
            startTime = DateTime.newInstance(currentTime.year(),currentTime.addMonths(-1).month(),Date.daysInMonth(currentTime.year(),currentTime.month()),23,59,59);
//            endTime = currentTime;
    	}
		
		if(startTime != null) {
			filterConditionStr = ' and (modifiedTime >= ' + '\'' + startTime.format('yyyy-MM-dd\'T\'HH:mm:ss') + '\'';
			if(endTime != null){
				filterConditionStr +=  ' and modifiedTime <= ' + '\'' + endTime.format('yyyy-MM-dd\'T\'HH:mm:ss') + '\'' + ') ';
			} else {
				filterConditionStr += ') ';
			}
		}
		
		return filterConditionStr;
	}
	
    // Search Files
    public List<FileListingWrapper> searchFiles(String scope, Criteria.File fileCriteriaObj) {
    	List<FileListingWrapper> listOfFiles = new List<FileListingWrapper>();
    	this.siteId = fileCriteriaObj.siteId;
    	EFSException.addTrace('searchFiles(' + scope + ',' + fileCriteriaObj + ')');
    	
    	if(this.clientAccess.dropboxFlag){
    		//listOfFiles = searchFilesDropbox(scope, fileCriteriaObj);
    	} else if (this.clientAccess.sharepointFlag) {
    		listOfFiles = searchFilesSharepoint(scope, fileCriteriaObj);
    		for(FileListingWrapper fw: listOfFiles) {
    			fw.canMove = false;
    		}
    	} else if (this.clientAccess.onedriveFlag) {
    		listOfFiles = searchFilesOnedrive(scope, fileCriteriaObj);
    	}
    	return listOfFiles;
    }

	// Delete File
	// Dropbox pass the filepath
	public boolean deleteFile(String fileId) {
    	//logger.logDebug('EFSFileService deleteFile() ----fileId----' + fileId);
    	EFSException.addTrace('deleteFile(' + fileId + ')');
    	
    	// Execute code based on the storage
    	if(this.clientAccess.dropboxFlag) {
			// Create the Resource using recent access token
			DBAPIFiles dbFiles = this.dbClient.files();
	
	        DBAPIFiles.DeleteRequest request = dbFiles.getDeleteRequest(fileId);
	        
	        try {
				DBAPIModelFiles.DeleteResult result = (DBAPIModelFiles.DeleteResult)request.execute();
				//logger.logDebug(result);
				return true;
	        } catch(SCoreAppException appEx) {
	        	this.close();
	        	throw new EFSException(request, 'DELETION ERROR',appEx.getMessage());
        	}
    	}
    	return false;
	}
	
	public boolean deleteItem(String driveId, String itemId) {	
		MSAPIDriveItem.DeleteDriveItem request = new MSAPIDriveItem.DeleteDriveItem(this.msClient.driveItems(), driveId, itemId);
		
		try {
			request.executePatch();
			return true;
        } catch(SCoreAppException appEx) {
        	this.close();
        	if(appEx.getMessage().equalsIgnoreCase('forbidden')) {
				throw new SimpplrException(ServiceConstants.ERROR_403);	
			}
        	throw new EFSException(request, 'DELETION ERROR',appEx.getMessage());
    	}			
	}
	
	Integer versionNumber = 1;	
	// Version Wrapper for Dropbox File
	public FileVersionHistoryWrapper toFileVersionWrapper(DBAPIModelFiles.Metadata fileMeta, People_Integration__c prefObj){
		EFSException.addTrace('toFileVersionWrapper(dropbox, ' + prefObj + ')');
		FileVersionHistoryWrapper filVer = new FileVersionHistoryWrapper();
		try{
			filVer.versionId = 'rev:'+fileMeta.rev; 
	    	filVer.versionNumber = String.valueOf(versionNumber);
    		if(fileMeta.client_modified != null){
				filVer.createdAt = Utility.dateTimeToMomentJSDateTime(fileMeta.client_modified);
    		}
	    	
	    	if(prefObj != null){
				filVer.user.Id = prefObj.people__c;
				filVer.user.Name = prefObj.People__r.Full_Name__c;
				filVer.user.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + prefObj.people__c;
	    	}
			
			filVer.canDownload = true;
			
			versionNumber--;
		} catch(NullPointerException npe) {
    		this.close();
        	throw new EFSException('DROPBOX CONVERSION ERROR', npe.getMessage());
    	}
		return filVer;
	}
	@TestVisible
	private static Map<String, People_Integration__c> getEFSEmailIdWithPeoplePref() {
    	Map<String, People_Integration__c> EFSEmailIdWithPeoplePref = new Map<string, People_Integration__c>();
		String queryStr = 'SELECT id,people__c, People__r.Full_Name__c, User_Email__c FROM People_Integration__c  '+
  				' WHERE User_Email__c!=null AND is_deleted__c=false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
  		List<People_Integration__c> listOfPeoplePreferences = new List<People_Integration__c> (
			  (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, null));
    	
    	for(People_Integration__c preferenceObj : listOfPeoplePreferences){
    		EFSEmailIdWithPeoplePref.put(preferenceObj.User_Email__c, preferenceObj);
    	}
    	return EFSEmailIdWithPeoplePref;
  	}
  	
	public static Map<String, People_Integration__c> getEFSIdWithPeoplePref() {
		if(EFStoSimpplrUserMap == null) {
	    	EFStoSimpplrUserMap = new Map<string, People_Integration__c>();
			String queryStr = 'SELECT id, People__c, People__r.Full_Name__c, User_Email__c, External_Id__c FROM People_Integration__c '+
	  				' WHERE External_Id__c!=null and is_deleted__c=false';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	  		List<People_Integration__c> listOfPeoplePreferences = new List<People_Integration__c> (
				(List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, null));
	    	
	    	for(People_Integration__c preferenceObj : listOfPeoplePreferences){
				EFStoSimpplrUserMap.put(preferenceObj.External_Id__c, preferenceObj);
				if(String.isNotBlank(preferenceObj.User_Email__c)){
					EFStoSimpplrUserMap.put(preferenceObj.User_Email__c, preferenceObj);
				}
	    	}
		}
	    
	    return EFStoSimpplrUserMap;
  	}    

    // Convert the Dropbox File to FileListingWrapper
    public FileListingWrapper toFileListingWrapper(DBAPIModelFiles.Metadata fil, String qStr, Map<String, People_Integration__c> EFSIdWithPeoplePrefMap, String dirId, Set<String> readWriteFoldersId, Boolean isSiteRootFolder, String parPermission) {
    	EFSException.addTrace('toFileListingWrapper(' + fil + ',' + qStr + ',' + dirId + ')');
    	FileListingWrapper filWrapper = new FileListingWrapper();
    	try {
	    	filWrapper.title = fil.name;
	    	filWrapper.name = fil.name;
    		filWrapper.id = fil.path_display;
	    	filWrapper.fileId = fil.id;
	    	filWrapper.externalFileId = fil.id;
	    	filWrapper.size = fil.size;
	    	filWrapper.context = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;
	    	filWrapper.provider = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;
	    	filWrapper.location = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;
	    	filWrapper.fileUrl = fil.path_display;

			if(fil.sharing_info != null && fil.sharing_info.read_only) {
				filWrapper.canCreateNewVersion = false;	
				filWrapper.permissions = 'read';
				filWrapper.canDelete = false;
				filWrapper.canChangeName = false;
				filWrapper.canMove = false;
			} else {
				filWrapper.canCreateNewVersion = true;
				filWrapper.permissions = 'readwrite';
				filWrapper.canDelete = true;
				filWrapper.canChangeName = true;
				filWrapper.canMove = true;
			}
			
			String folderId = null;
			String modifiedBy = null;
			try {
				filWrapper.sharedFolderId = fil.sharing_info.shared_folder_id;
				modifiedBy = fil.sharing_info.modified_by;
				if(filWrapper.sharedFolderId == null) {
					folderId = fil.sharing_info.parent_shared_folder_id;
				} else {
					folderId = filWrapper.sharedFolderId;
				} 
			} catch(Exception npe) {	
				// Shared Folder Id will be null for files.
			}
			
			People_Integration__c ownerRef = null;
	    	if(fil.tag.equalsIgnoreCase('folder')) {
	    		filWrapper.type = 'Folder';	
	    		filWrapper.isDir = true;
	    		filWrapper.isFolder = 1;
	    		
				// Get the Owner info
				if (EFSIdWithPeoplePrefMap == null) {
					ownerRef = UserContext.Integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
				} else {
					ownerRef = EFSIdWithPeoplePrefMap.get(folderId);
				}
	    	} else {
	    		filWrapper.id = fil.id;
	    		listOfFileIdsinListing.add(filWrapper.id);
				filWrapper.isDir = false;
				filWrapper.isFolder = 0;
	    		filWrapper.fileExtension = fil.name.substringAfterLast('.').toUpperCase();
	    		filWrapper.type = filWrapper.fileExtension;	    		
	    		filWrapper.isImage = Utility.isImage(filWrapper.type);
				
				// Fix for SV2-15490
				Map<String, String> fileDetailParams = new Map<String, String>{'fileId' => filWrapper.fileId, 'provider' => ServiceConstants.STORAGE_TYPE_DROPBOX_STRING};
				if(String.isNotBlank(siteId)) {
					fileDetailParams.put('siteId', siteId);
				}
				filWrapper.url = PageContext.getPageURL(Pages.FileDetail, fileDetailParams);
				
				// Get the Owner info
				if (EFSIdWithPeoplePrefMap == null) {
					ownerRef = UserContext.Integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
				} else if(EFSIdWithPeoplePrefMap.containsKey(fil.id)) {
					ownerRef = EFSIdWithPeoplePrefMap.get(fil.id);	
				} else {
					ownerRef = EFSIdWithPeoplePrefMap.get(modifiedBy); //getFileOwnerId(fil.id));
				}
	    	}
			
			// Assign the file owner 
			filWrapper.owner = new FileListingWrapper.OwnerWrapper();
			
			if(ownerRef != null) {
				filWrapper.owner.Id = ownerRef.People__c;
				filWrapper.owner.Name = ownerRef.People__r.Full_Name__c;
				filWrapper.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + ownerRef.People__c;
			}
			
	    	if(fil.tag == 'folder') {
	    		filWrapper.type = 'Folder';	
	    		filWrapper.isFolder = 1;
	    		filWrapper.isDir = true;
	    		filWrapper.isImage = false;
	    	} else {
	    		filWrapper.type = filWrapper.fileExtension;
   				filWrapper.isImage = Utility.isImage(filWrapper.type);
				filWrapper.canDownload = true;
				filWrapper.onlyPDFDownload = false;
				filWrapper.dropBoxUrl = 'https://www.dropbox.com/home' + fil.path_display;
				filWrapper.externalUrl = 'https://www.dropbox.com/home'
						+ Utility.encodeUrlString(fil.path_display);
	    	}

    		if(fil.client_modified != null){
				filWrapper.modifiedAt = fil.client_modified.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				filWrapper.modifiedAtDateTime = fil.client_modified;//fil.getModifiedTime();
    		}
    		filWrapper.contentVersionId = 'rev:'+fil.rev;
    		if(String.isBlank(this.siteId)) {
    			filWrapper.listOfSite = fetchSiteInfo(fil.path_display);
    		}
    	} catch(NullPointerException npe) {
    		this.close();
    		//logger.logDebug(filWrapper);
        	throw new EFSException(fil, 'FILE LISTING CONVERSION ERROR', npe.getMessage());
    	}
    	
		return filWrapper;
    }
    
    // Convert the Sharepoint/OneDrive File to FileListingWrapper
    public FileListingWrapper toFileListingWrapper(MSAPIModelDriveItem fil, 
    											   Map<String, People_Integration__c> EFSIdWithPeoplePrefMap, 
    											   String driveId, 
    											   String parPermission) {
    	EFSException.addTrace('toFileListingWrapper(' + fil + ',' + driveId + ',' + parPermission + ')');
    	FileListingWrapper filWrapper = new FileListingWrapper();
		String storage = this.clientAccess.fileStorage;
		
    	try {
	    	filWrapper.title = fil.name;
	    	filWrapper.name = fil.name;
    		filWrapper.id = fil.id;
	    	filWrapper.fileId = fil.id;
	    	filWrapper.externalFileId = fil.id;
	    	filWrapper.size = fil.size;
	    	filWrapper.context = storage; //EFSConstants.SHAREPOINT_STRING;
	    	filWrapper.provider = storage; // EFSConstants.SHAREPOINT_STRING;
	    	filWrapper.location = storage; // EFSConstants.SHAREPOINT_STRING;
	    	filWrapper.fileUrl = fil.webDAVurl;
	    if(String.isBlank(driveId) && fil.parentReference != null) {
				driveId = fil.parentReference.driveId;
			}
	    	filWrapper.rootDirectory = driveId;
	    	
			String modifiedBy = (fil.lastModifiedBy != null && fil.lastModifiedBy.user != null) ? fil.lastModifiedBy.user.displayName : '';
			/*
			if(parPermission.equalsIgnoreCase('read') && !(UserContext.Integrations.get(storage).External_Id__c == fil.createdBy.user.Id)) {
				filWrapper.canCreateNewVersion = false;
				filWrapper.permissions = 'read';
				filWrapper.canDelete = false;
				filWrapper.canChangeName = false;
				filWrapper.canMove = false;
			} else {
				filWrapper.canCreateNewVersion = true;
				filWrapper.permissions = 'readwrite';
				filWrapper.canDelete = true;
				filWrapper.canChangeName = true;
				filWrapper.canMove = true;
			}
			*/
			
				filWrapper.canCreateNewVersion = false;
				filWrapper.permissions = 'readwrite';
				filWrapper.canDelete = false;
				filWrapper.canChangeName = false;
				filWrapper.canMove = false;
			
			People_Integration__c ownerRef = null;
	    	if(fil.folder != null) {
	    		filWrapper.type = 'Folder';	
	    		filWrapper.isDir = true;
	    		filWrapper.isFolder = 1;
	    		filWrapper.isImage = false;
	    	} else {
	    		filWrapper.id = fil.id;
	    		listOfFileIdsinListing.add(fil.id);
				filWrapper.isDir = false;
				filWrapper.isFolder = 0;
	    		filWrapper.fileExtension = fil.name.substringAfterLast('.').toUpperCase();
				filWrapper.type = String.isNotBlank(filWrapper.fileExtension) ? filWrapper.fileExtension.toLowerCase() : fil.file != null ? fil.file.mimeType : null;
				//filWrapper.type = fil.file != null ? fil.file.mimeType : null;
				filWrapper.isImage = Utility.isImage(filWrapper.type);
				// if(filWrapper.isImage) {
				// 	filWrapper.thumbnailImg = String.isNotBlank(filWrapper.fileUrl) ? filWrapper.fileUrl : null; 
				// }
				
				filWrapper.canDownload = true;
				filWrapper.onlyPDFDownload = false;
				filWrapper.externalUrl = +fil.weburl;
				
				Map<String, String> fileDetailParams = new Map<String, String>{'fileId' => filWrapper.fileId, 
																			   'rootDirectory' => driveId,
																			   'provider' => storage,
																			   'permission' => parPermission};
				if(String.isNotBlank(siteId)) {
					fileDetailParams.put('siteId', siteId);
				}
				if('sharepoint'.equalsIgnoreCase(storage)) {
					fileDetailParams.put('externalUrl', EncodingUtil.urlEncode(filWrapper.externalUrl, 'UTF-8'));
				}
				
				filWrapper.url = PageContext.getPageURL(Pages.FileDetail, fileDetailParams);
				
				if(fil.versions != null && fil.versions.isEmpty() == false) {
					filWrapper.contentVersionId = 'rev:' + fil.versions[0].id;
				}
	    	}
			
			//logger.logDebug('done with file/folder');
			
			// Assign the file owner 
			filWrapper.owner = new FileListingWrapper.OwnerWrapper();
			
			if(fil.createdBy != null && fil.createdBy.user != null) {
				String pplKey = String.isNotBlank(fil.createdBy.user.id) ? fil.createdBy.user.id : fil.createdBy.user.email;
				
				if(EFSIdWithPeoplePrefMap == null) { 
					EFSIdWithPeoplePrefMap = getEFSIdWithPeoplePref();
				}
				
				People_Integration__c ppl = EFSIdWithPeoplePrefMap.get(pplKey);
				if(ppl != null) {
					filWrapper.owner.Id = ppl.People__c;
					filWrapper.owner.Name = ppl.People__r.Full_Name__c;
					filWrapper.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ ppl.People__c;
				} else {
					filWrapper.owner.Name = fil.createdBy.user.displayName;
				}			
			}

    		if(fil.lastModifiedDateTime != null){
				filWrapper.modifiedAt = fil.lastModifiedDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				filWrapper.modifiedAtDateTime = fil.lastModifiedDateTime;
    		}
    		if(String.isNotBlank(fil.createdDateTime)){
				filWrapper.createdAtDateTime = Utility.convertStringTodateTime(fil.createdDateTime);
				filWrapper.createdAt = Utility.dateTimeToMomentJSDateTime(filWrapper.createdAtDateTime);
    		}
    		    		
    		if(String.isBlank(this.siteId)) {
				filWrapper.listOfSite = fetchSiteInfo(fil.parentReference);
    		}
    		filWrapper.pathOnClient = (fil.parentReference != null && String.isNotBlank(fil.parentReference.path)) ? fil.parentReference.path : fil.webUrl;
    	} catch(NullPointerException npe) {
    		this.close();
    		logger.logError('EFSFileService.toFileListingWrapper----Exception Occured----', npe);
        	throw new EFSException(fil, 'FILE LISTING CONVERSION ERROR', npe.getMessage());
    	}
    	
		return filWrapper;
    }
    
    public FileDetailWrapper toFileDetailWrapper(DBAPIModelFiles.Metadata dbFileObj, String parDirectory, String siteId, DBAPIUsers apiUsers) {
    	FileDetailWrapper fileDetailWrapObj = new FileDetailWrapper();
    	if(String.isNotBlank(siteId)){
    		this.siteId = siteId;
    	}
    	try {
    		fileDetailWrapObj.id = dbFileObj.id;
    		fileDetailWrapObj.context = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;
    		fileDetailWrapObj.provider = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;
    		fileDetailWrapObj.name = dbFileObj.name;

    		fileDetailWrapObj.fileUrl = dbFileObj.path_display;
    		fileDetailWrapObj.url = 'https://www.dropbox.com/home' + dbFileObj.path_display;
			
			Map<String, String> fileDetailParams = new Map<String, String>{'provider' => ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, 'fileId' => dbFileObj.id};
    	
			if(String.isNotBlank(siteId) && ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(SiteContext.fileStorageSource)) {
				fileDetailParams.put('siteId', siteId);
			}
			fileDetailWrapObj.url = PageContext.getPageURL(Pages.FileDetail, fileDetailParams);
			fileDetailWrapObj.title = dbFileObj.name;

			// Need to get User Info
    	fileDetailWrapObj.owner = new FileDetailWrapper.OwnerWrapper();
    	Map<String, People_Integration__c> EFSIdWithPeoplePrefMap = getEFSIdWithPeoplePref();
    		
    	//String dbId = getFileOwnerId(fileDetailWrapObj.id);
    	String dbId = dbFileObj.sharing_info == null ? '' : dbFileObj.sharing_info.modified_by;
			People_Integration__c usrInfo = null;
    	
    	if(String.isNotBlank(dbId)) {
    		usrInfo = EFSIdWithPeoplePrefMap.get(dbId);
			} else {
    		usrInfo = UserContext.Integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
    	}

			if(usrInfo != null) {
					fileDetailWrapObj.owner.Id = usrInfo.People__c;
					fileDetailWrapObj.owner.Name = usrInfo.People__r.Full_Name__c;
					fileDetailWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ usrInfo.People__c; 
			} else { // ------------- User(File owner/modifier) is not connected to dropbox
					DBAPIUsers.ListRequest listReq = apiUsers.getAccountRequest(dbId);
	 				DBAPIModelUsers.BasicAccount revResp = (DBAPIModelUsers.BasicAccount)listReq.execute();

					fileDetailWrapObj.owner.Name = revResp.name.display_name;
					fileDetailWrapObj.owner.URL = '';
			}

			Boolean isReadOnlyFlag = false;
			if(dbFileObj.sharing_info != null) {
				isReadOnlyFlag = dbFileObj.sharing_info.read_only;
			}
			
			if(dbFileObj.tag != null && dbFileObj.tag.equalsIgnoreCase('folder')) {
				fileDetailWrapObj.isDir = true;
				fileDetailWrapObj.directory = new FileDetailWrapper.DirectoryWrapper();
				fileDetailWrapObj.directory.id = fileDetailWrapObj.id;
				fileDetailWrapObj.directory.name = dbFileObj.name;
				
				if(isReadOnlyFlag) {
					fileDetailWrapObj.directory.permissions = 'read';
				} else {
					fileDetailWrapObj.directory.permissions = 'readwrite';
				}
			} else {
				fileDetailWrapObj.isDir = false;
	    		FileDao fileDaoObj = new FileDao();
	    		fileDetailWrapObj.isBookmarked = fileDaoObj.isFileBookmarked(dbFileObj.id, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
	    		fileDetailWrapObj.latestPublishedVersionId = 'rev:'+dbFileObj.rev;
	    		fileDetailWrapObj.contentVersionId = 'rev:'+dbFileObj.rev;
    		
    		   	fileDetailWrapObj.lastModifiedDate = LocaleContext.getLocalisedDateAsMMMDDYYYYhhmmss(dbFileObj.client_modified, UserContext.languageLocaleKey);
						 fileDetailWrapObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(dbFileObj.client_modified);
				fileDetailWrapObj.fileSize = Utility.byteToHumanReadableFormate(dbFileObj.size);
				fileDetailWrapObj.size = dbFileObj.size;

				//fileDetailWrapObj.thumbnailImg = gdFileObj.getThumbnailLink();
				if(dbFileObj.name.indexOf('.') == -1) {
					fileDetailWrapObj.fileExtension = 'UNKNOWN';
				} else {
					fileDetailWrapObj.fileExtension = dbFileObj.name.substringAfterLast('.').toUpperCase();
				}
				fileDetailWrapObj.fileType = Utility.getFileType(fileDetailWrapObj.fileExtension);
				fileDetailWrapObj.type = fileDetailWrapObj.fileType;
		    	
		    	if (ApexPages.currentPage() != null || SimpplrContext.isRESTServiceContext == true) {
		    		fileDetailWrapObj.isDownloadableOniOS = Utility.isDownloadableOniOS(fileDetailWrapObj.fileType, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
		    	}
		    	
	    		fileDetailWrapObj.isImage = Utility.isImage(fileDetailWrapObj.fileType);
    		
				if(isReadOnlyFlag) {
					fileDetailWrapObj.canCreateNewVersion = false;
				} else {
					fileDetailWrapObj.canCreateNewVersion = true;
				}
			}
			
			// Common params for Files and Folder
			if(isReadOnlyFlag) {
				fileDetailWrapObj.canChangeName = false;
				fileDetailWrapObj.canDelete = false;
			} else {
				fileDetailWrapObj.canChangeName = true;
				fileDetailWrapObj.canDelete = true;
			}
			
			fileDetailWrapObj.canCreatePublicShareLink = false;

    		// fileDetailWrapObj.listOfParents
			String parentPath = dbFileObj.path_display.substringBeforeLast('/');

     		String consolidatedPath = '';
     		Integer pathCount = 0;
     		
     		// List of Parents
			Boolean naParentFlag = true;
			
			// Site File Detail
     		if(String.isNotBlank(this.siteId) && ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(SiteContext.fileStorageSource)) {
				for(String foldName: parentPath.split('/')) {
					pathCount++;
					FileDetailWrapper.ParentWrapper parentWrap = new FileDetailWrapper.ParentWrapper();
					
					if(String.isNotBlank(foldName)) {
						consolidatedPath += '/' + foldName;
						
						if(pathCount == 3) {
							parentWrap.id = consolidatedPath;
							parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.dropbox_files');
						} else if(pathCount > 3) {
							parentWrap.id = consolidatedPath;
							parentWrap.name = foldName;
						}
					}
					
					if(String.isNotBlank(parentwrap.id)) {
						parentWrap.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + this.siteId + '/files' + '#provider='+ServiceConstants.STORAGE_TYPE_DROPBOX_STRING+'&directory='+consolidatedPath+'&permissions=read';
						fileDetailWrapObj.listOfParents.add(parentWrap);
						naParentFlag = false;
					}
				}
			} else {
				fileDetailWrapObj.listOfSite = fetchSiteInfo(dbFileObj.path_display);
				if(fileDetailWrapObj.listOfSite.size() > 0) {
					naParentFlag = false;
				}
			}

			if(naParentFlag) {
				FileDetailWrapper.ParentWrapper parentWrap = new FileDetailWrapper.ParentWrapper();
				parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.location.not_available');
				fileDetailWrapObj.listOfParents.add(parentWrap);
			}
    	} catch (NullPointerException npe) {
    		this.close();
    		//Utility.sendBatchFailedExceptionEmail('toFileDetailWrapper', npe);
        	throw new EFSException(dbFileObj, 'FILE DETAIL CONVERSION ERROR', npe.getMessage());
    	}
    	return fileDetailWrapObj; 
    }
    
    public FileDetailWrapper toFileDetailWrapper(MSAPIModelDriveItem msFileObj, String driveItemId, String siteId, String provider, String parPerm) {
    	FileDetailWrapper fileDetailWrapObj = new FileDetailWrapper();
    	try {
			fileDetailWrapObj.id = msFileObj.id;
			fileDetailWrapObj.fileId = msFileObj.id;
    		fileDetailWrapObj.context = provider;
    		fileDetailWrapObj.provider = provider;
    		fileDetailWrapObj.fileUrl = msFileObj.downloadUrl;
				fileDetailWrapObj.viewInExternalSystem = msFileObj.webUrl;
    		
    		fileDetailWrapObj.name = msFileObj.name;
    		fileDetailWrapObj.title = msFileObj.name;
    		fileDetailWrapObj.owner = new FileDetailWrapper.OwnerWrapper();
    		fileDetailWrapObj.downloadUrl = msFileObj.downloadUrl;
    		
			// Assign the file owner 
			fileDetailWrapObj.owner = new FileDetailWrapper.OwnerWrapper();

			if(msFileObj.createdBy.user != null) {
				String pplKey = String.isNotBlank(msFileObj.createdBy.user.id) ? msFileObj.createdBy.user.id : msFileObj.createdBy.user.email;
				Map<String, People_Integration__c> EFSIdWithPeoplePrefMap = getEFSIdWithPeoplePref();
				
				People_Integration__c ppl = EFSIdWithPeoplePrefMap.get(pplKey);
				if(ppl != null) {
					fileDetailWrapObj.owner.Id = ppl.People__c;
					fileDetailWrapObj.owner.Name = ppl.People__r.Full_Name__c;
					fileDetailWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ ppl.People__c;
				} else {
					fileDetailWrapObj.owner.Name = msFileObj.createdBy.user.displayName;
				}			
			}
			
				fileDetailWrapObj.lastModifiedDate = LocaleContext.getLocalisedDateAsMMMDDYYYYhhmmss(msFileObj.lastModifiedDateTime, UserContext.languageLocaleKey);
				fileDetailWrapObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(msFileObj.lastModifiedDateTime); 
    		fileDetailWrapObj.fileSize = Utility.byteToHumanReadableFormate(msFileObj.size);
    		fileDetailWrapObj.size = msFileObj.size;
    		
    		/*    		
			if(parPerm.equalsIgnoreCase('read') && !(UserContext.Integrations.get(provider).External_Id__c == msFileObj.createdBy.user.Id)) {
				fileDetailWrapObj.canCreateNewVersion = false;
				fileDetailWrapObj.permissions = 'read';
				fileDetailWrapObj.canDelete = false;
				fileDetailWrapObj.canChangeName = false;
			} else {
				fileDetailWrapObj.canCreateNewVersion = true;
				fileDetailWrapObj.permissions = 'readwrite';
				fileDetailWrapObj.canDelete = true;
				fileDetailWrapObj.canChangeName = true;
			}
			*/
			fileDetailWrapObj.canCreateNewVersion = false;
			fileDetailWrapObj.permissions = 'readwrite';
			fileDetailWrapObj.canDelete = false;
			fileDetailWrapObj.canChangeName = false;
    		
    		if(msFileObj.name.indexOf('.') == -1) {
				fileDetailWrapObj.fileExtension = 'UNKNOWN';
			} else {
				fileDetailWrapObj.fileExtension = msFileObj.name.substringAfterLast('.').toUpperCase();
			}
			
			fileDetailWrapObj.fileType = Utility.getFileType(fileDetailWrapObj.fileExtension);
			fileDetailWrapObj.type = fileDetailWrapObj.fileType;
			fileDetailWrapObj.isImage = Utility.isImage(fileDetailWrapObj.fileType);
			fileDetailWrapObj.description = msFileObj.description;
			FolderDao daoObj = new FolderDao();
			Folder__c siteFold;
			Boolean odFlag = ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(provider);
			Map<String, String> driveIdtoDriveNameMap = new Map<String,String>();
			List<Folder__c> folList = daoObj.getEFSFolders(siteId, 'all', provider, null);
			
			for(Folder__c linkedFolder:	folList) {
				driveIdtoDriveNameMap.put(linkedFolder.External_Folder_Id__c,linkedFolder.Name__c);
			}
			
			// List of Parents
			Boolean naParentFlag = false;
 			
 			// Add siteInformation to parent
			if (String.isNotBlank(siteId)) {
				siteFold = daoObj.getEFSSiteFolder(siteId, provider);
				if(siteFold != null) {
					FileDetailWrapper.ParentWrapper parentWrap = new FileDetailWrapper.ParentWrapper();
					parentWrap.id = siteFold.id;
					if(odFlag) {
							parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.onedrive_files');
					} else {
							parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.sharepoint_files');
					}
					parentWrap.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files'
							+ '#provider=' + provider + '&directory=' + parentWrap.id
							+ '&permissions=read';
					fileDetailWrapObj.listOfParents.add(parentWrap);
				} else {
					naParentFlag = true;
				}
			} else {
				naParentFlag = true;
			}
			
			if(naParentFlag) {
					fileDetailWrapObj.listOfSite = fetchSiteInfo(msFileObj.parentReference);
    			if(fileDetailWrapObj.listOfSite.isEmpty()) {
					FileDetailWrapper.ParentWrapper parentWrap = new FileDetailWrapper.ParentWrapper();
					parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.location.not_available');
					fileDetailWrapObj.listOfParents.add(parentWrap);
    			}
			} else {
	    		//fileDetailWrapObj.listOfParents
	    		String parentPath = EncodingUtil.urlDecode(msFileObj.parentReference.path.replaceAll('\\+','%2B'), 'UTF-8');
				String driveId =  parentPath.substringAfter('/drives/').substringBefore('/');
			 	String driveName = driveIdtoDriveNameMap != NULL ? driveIdtoDriveNameMap.get(driveId) : '';
			 	
				// drive information of parent
				if(String.isNotBlank(driveName)) {
					FileDetailWrapper.ParentWrapper parentWrapDrive = new FileDetailWrapper.ParentWrapper();
					parentWrapDrive.id = driveId;
					parentWrapDrive.name = driveName;
					parentWrapDrive.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files'
								 + '#provider=' + provider + '&directory=' + driveId
								+ '&permissions=read';
					fileDetailWrapObj.listOfParents.add(parentWrapDrive);
				}	
						
				String remainingParents = parentPath.substringAfter('root:');
				
				if(String.isNotBlank(remainingParents)) {
					Boolean odLFParsed = false;
					String consolidatedPath = '/root:';
					for(String foldName: remainingParents.split('/')) {
						if(String.isNotBlank(foldName)) {
							consolidatedPath += '/' + foldName;
							FileDetailWrapper.ParentWrapper rParentWrap = new FileDetailWrapper.ParentWrapper();
							rParentWrap.id = consolidatedPath;
							rParentWrap.name = foldName;
							
							if(String.isNotBlank(rParentWrap.id)) {
								if(String.isNotBlank(siteId)) {
									rParentWrap.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files'
											+ '#provider=' + provider + '&directory='
											+ Utility.encodeUrlString(consolidatedPath) + '&rootDirectory=' + driveId + '&permissions=read';
								} else {
									rParentWrap.url = PageContext.getPageURL(Pages.MyFiles) + '#provider='
											+ provider + '&directory=' + Utility.encodeUrlString(consolidatedPath);
								}
								
								if(odFlag && !odLFParsed && driveIdtoDriveNameMap.values().contains(foldName)) {
									odLFParsed = true;		
								}
								
								if(!odFlag || odLFParsed) {
									fileDetailWrapObj.listOfParents.add(rParentWrap);	
								}
							}
						}
					}
				}
			}
    	} catch (NullPointerException npe) {
    		this.close();
        	throw new EFSException(msFileObj, 'FILE DETAIL CONVERSION ERROR', npe.getMessage());
    	}
    	return fileDetailWrapObj;
    }
    
    // Process the path to get the Sites - ONLY for DropBox
    public List<SiteLiteWrapper> fetchSiteInfo(String filepath) {
    	filePath = filePath.toLowerCase();
		List<SiteLiteWrapper> sitesList = new List<SiteLiteWrapper>();
		if(filepath == null) { return sitesList; }
		
		SiteLiteWrapper siteInfo = null;
		
		if(permSitesMap == null) {
			permSitesMap = this.getEFSSiteMap();
		}
		
		Set<Id> uniqueSiteIds = new Set<Id>();
		
		for(String siteRootPath: permSitesMap.keySet()) {
			if(filePath.startsWith(siteRootPath.toLowerCase())) {
				siteInfo = permSitesMap.get(siteRootPath);
				
				if(siteInfo != null && uniqueSiteIds.add(siteinfo.siteId)) { 
					sitesList.add(siteinfo);
				}  
			}	
		}
		
		return sitesList;
    }

	// To get the folder records which can be used to get site details
	private Map<String, SiteLiteWrapper> getEFSSiteMap() {
		Map<String, SiteLiteWrapper> foldMap = new Map<String, SiteLiteWrapper>();
		SiteLiteWrapper siteWrapper;
		String storage = getFileStorage();
		Boolean readSystemFolderFlag = this.clientAccess.dropboxFlag;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', storage);
		soqlParamMap.put('soqlParam2', readSystemFolderFlag);
		soqlParamMap.put('soqlParam3', ServiceConstants.PUBLIC_SITE);
		soqlParamMap.put('soqlParam4', UserContext.sitesIFollowIdSet);
		String folderQuery = 'Select id, Name__c, EFS_Read_Collaboration_Id__c, EFS_Read_Write_Collaboration_Id__c, Path__c, Site__c, ' +
			' External_Folder_Id__c, Permissions__c, EFS_Shared_Folder_Id__c, EFS_Drive_Id__c,  ' +
			' Site__r.Name, Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c, Site__r.Is_Active__c, Site__r.Title_Content_Version__c   ' +
			' FROM Folder__c  ' +
			' WHERE Type__c = :soqlParam1 and Is_System_Folder__c = :soqlParam2 and Is_Deleted__c = false  ' +
			' AND (Site__r.Site_Type__c =: soqlParam3 OR Site__c IN: soqlParam4)  ' +
			' AND Site__r.Is_Active__c = true ' +
			' AND Site__r.File_Storage_Source__c=: soqlParam1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
			siteWrapper = new SiteLiteWrapper();
			siteWrapper.siteId = fold.Site__c;
			siteWrapper.name = fold.Site__r.Name;
			siteWrapper.chatterGroupId = fold.Site__r.Chatter_Group_Id__c;
			siteWrapper.access = fold.Site__r.Site_Type__c;
			siteWrapper.isActive = fold.Site__r.Is_Active__c;
			siteWrapper.url = Pages.app +'?u=/site/' + siteWrapper.siteId + '/files' + '#provider=' + this.getFileStorage();
			if(String.isNotBlank(fold.Site__r.Title_Content_Version__c)){
				siteWrapper.img = Utility.getFileDownloadURLFor720By480(fold.Site__r.Title_Content_Version__c);
	 			siteWrapper.imgThumbnail = Utility.getFileDownloadURLFor120BY90(fold.Site__r.Title_Content_Version__c);
			}
			if(this.clientAccess.dropboxFlag) {
				foldMap.put(fold.Path__c, siteWrapper);	
				siteWrapper.url += '&directory=' + fold.Path__c;			
			} else if(this.clientAccess.sharepointFlag) {
				siteWrapper.url += '&directory=' + fold.External_Folder_Id__c;
				foldMap.put(fold.Site__c + fold.External_Folder_Id__c, siteWrapper);
			} else if(this.clientAccess.onedriveFlag) {
				siteWrapper.url += '&directory=' + fold.External_Folder_Id__c + '&rootDirectory=' + fold.EFS_Drive_Id__c;
				foldMap.put(fold.Site__c + fold.External_Folder_Id__c, siteWrapper);
			}
		}
		
		//Logger.logDebug('Linked Folders -> ' + foldMap);
		return foldMap;
	}
	
    // Process the path to get the Sites - ONLY for Sharepoint
    public List<SiteLiteWrapper> fetchSiteInfo(MSAPIModelDriveItem.ItemReference item) {
		List<SiteLiteWrapper> sitesList = new List<SiteLiteWrapper>();
		if(item == null) { return sitesList; }
		
		SiteLiteWrapper siteInfo = null;
		
		if(permSitesMap == null) {
			permSitesMap = this.getEFSSiteMap();
		}
		
		Set<Id> uniqueSiteIds = new Set<Id>();
		for(String driveId: permSitesMap.keySet()) {
			if(this.clientAccess.sharepointFlag){
				if(item.driveId == driveId.subString(18)) {
					siteInfo = permSitesMap.get(driveId);
				
					if(siteInfo != null && uniqueSiteIds.add(siteinfo.siteId)) { 
						sitesList.add(siteinfo);
					}
				}
			} else if(this.clientAccess.onedriveFlag){	
				if(item.id == driveId.subString(18)) {
					siteInfo = permSitesMap.get(driveId);
				
					if(siteInfo != null && uniqueSiteIds.add(siteinfo.siteId)) { 
						sitesList.add(siteinfo);
					}
				}
			}  
		}
		
		return sitesList;
    }
    
    // Process the path to get the Sites - ONLY for OneDrive
    public List<SiteLiteWrapper> fetchSiteInfo(String webUrl, String driveId) {
		List<SiteLiteWrapper> sitesList = new List<SiteLiteWrapper>();
		if(webUrl == null || driveId == null) { return sitesList; }
		
		SiteLiteWrapper siteInfo = null;
		
		if(permSitesMap == null) {
			permSitesMap = this.getEFSSiteMap();
		}
		//logger.logDebug('linked folders - ' + permSitesMap);
		
		Set<Id> uniqueSiteIds = new Set<Id>();
		
		for(String linkedFolderName: permSitesMap.keySet()) {
			if(webUrl.contains('/' + linkedFolderName + '/')) {
				siteInfo = permSitesMap.get(linkedFolderName);
				
				if(siteInfo != null && uniqueSiteIds.add(siteinfo.siteId) && siteInfo.url.endsWith(driveId)) {
					sitesList.add(siteInfo);
				}
			}
		}

		return sitesList;
    }
	
	// Function to create permission for the Folder Sharing with Members
	// Parameter Details
	// FileId: Unique Id of the file
	// Permission: Read/ReadWrite
	// grpEmail:
	//		id of the group (DropBox)
	public String addPermission(String fileId, String permission, String grpEmail) {
		EFSException.addTrace('addPermission(' + fileId + ',' + permission + ',' + grpEmail + ')');
		
		if(this.clientAccess.dropboxFlag) {
			String access = 'viewer';
    		if(permission.equalsIgnoreCase('READWRITE')) {
    			access = 'editor';
    		}
    		
			DBAPIModelSharing.AddFolderMemberArg args = new DBAPIModelSharing.AddFolderMemberArg(new Map<String, String> { grpEmail => access });
			args.shared_folder_id = fileId;
			
			DBAPISharing sharingRes = new DBAPISharing(this.dbClient);
			DBAPISharing.AddMemberRequest request = new DBAPISharing.AddMemberRequest(sharingRes, args);
			try {
				request.execute();
				return fileId;
			} catch (SCoreAppException appEx) {
				this.close();
				throw new EFSException(request, 'Adding Folder Member ERROR', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
			}
				
		} else {
			
		}
		return '';
	}
	
	// Method to fecth the details of a particular file
	public FileDetailWrapper getFileDetail (String fileId, String parDir, String siteId, String parentPerm) {
 		EFSException.addTrace('getFileDetail(' + fileId + ')');
 		FileDetailWrapper fileDetailWrapObj = new FileDetailWrapper();
 		
 		if(this.clientAccess.dropboxFlag) {
			DBAPIFiles fil = this.dbClient.files();
			DBAPIUsers apiUsers = this.dbClient.users();
			
			try {
				if(String.isNotBlank(fileId)) {
					DBAPIFiles.ListRequest listReq = fil.getRevisionsRequest(fileId, 10);	
					
	 				DBAPIModelFiles.ListRevisionResult revResp = (DBAPIModelFiles.ListRevisionResult)listReq.execute();
					
					if (revResp.is_deleted) {
	 					throw new SimpplrException(ServiceConstants.ERROR_404);	
	 				}
	 								
	 				fileDetailWrapObj = toFileDetailWrapper(revResp.entries[0], parDir, siteId, apiUsers);
	 				
	 				if(!fileDetailWrapObj.isDir && fileDetailWrapObj.canCreateNewVersion) {
	 					fileDetailWrapObj.versionNumber = String.valueOf(revResp.entries.size());
	 				}
				} else {
					DBAPIFiles.GetMetadataRequest mdRequest = fil.getMetadataRequest(parDir, false);
					
					DBAPIModelFiles.Metadata folderObj = (DBAPIModelFiles.Metadata) mdRequest.execute();
					
					fileDetailWrapObj = toFileDetailWrapper(folderObj, '', siteId, apiUsers);
				}
 			} catch (SCoreAppException httpex) { 
                if(httpex.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT && 
                		(httpex.getMessage().contains('not_found') 
                		|| 'conflict'.equalsIgnoreCase(httpex.getMessage()))){
       				this.close();
					throw new SimpplrException(ServiceConstants.ERROR_404);
				}
				
				throw new EFSException('File Detail GET ERROR', httpex.getStatusCode() + httpex.getMessage());
 			} catch (Exception ex) {
				 EFSException.addTrace('EFSFileService.getFileDetail()--Exception Occured----(' + ex.getStackTraceString() + ')');
 				throw new EFSException('Detail Wrapper Conversion ERROR', ex.getMessage());
 			}
 		} else if(this.clientAccess.sharepointFlag || this.clientAccess.onedriveFlag) {
 			try {
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', parDir);
				String folderQuery = 'Select Id, External_Folder_Id__c, Site__c, SP_Instance_Id__c from Folder__c where Type__c=\'sharepoint\' ' +
					' and External_Folder_Id__c=:soqlParam1 and is_deleted__c = false';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
				
				if(this.clientAccess.sharepointFlag && SimpplrContext.isSharepointUpgraded && ( folderList[0].SP_Instance_Id__c!= null && UserContext.spInstanceId != null && !(folderList[0].SP_Instance_Id__c.equalsIgnoreCase(UserContext.spInstanceId)))){
						//file is from different instance
						fileDetailWrapObj.permissions = 'none';
						fileDetailWrapObj.isDifferentSpInstance = true;
						return fileDetailWrapObj;
				}else{
					fileDetailWrapObj.isDifferentSpInstance = false;
				}
				
 				MSAPIDriveItem driveItemObj = this.msClient.driveItems();
				MSAPIDriveItem.GetItem itemObj = new MSAPIDriveItem.GetItem(driveItemObj, parDir, fileId);
				MSAPIModelDriveItem driveItemModel = new MSAPIModelDriveItem();
				driveItemModel = (MSAPIModelDriveItem) itemObj.execute();
				fileDetailWrapObj = toFileDetailWrapper(driveItemModel, parDir, siteId, this.clientAccess.fileStorage, parentPerm);
 			} catch (Exception ex) {
				if(this.clientAccess.sharepointFlag){
					fileDetailWrapObj.permissions = 'none';
					return fileDetailWrapObj;
				}else{
					if (ex.getMessage().containsIgnoreCase('not found')) {
						throw new SimpplrException(ServiceConstants.ERROR_404);
					} else if(ex.getMessage().equalsIgnoreCase('forbidden')) {
						throw new SimpplrException(ServiceConstants.ERROR_403);	
					} else {
						throw ex;
					}
				}
 			}
 		}

		return fileDetailWrapObj;
    }

	public String getDownloadURL(String driveId, String fileId, String versionId) {
		String downloadUrl = '';
		if(this.clientAccess.sharepointFlag) {
			String endPointUrl = 'https://graph.microsoft.com/v1.0/drives/' + driveId + '/items/' + fileId  + '/versions/' + versionId + '/content';

			HttpResponse res = Utility.getJsonResponseFromExternalSystem('GET',endPointUrl ,'Bearer ' +  this.clientAccess.getAccessToken(),null);
			if(res.getStatusCode() == 302) {
				downloadUrl = res.getHeader('Location');
			} 				
		}
		return downloadUrl;
	}
	
	public List<FileVersionHistoryWrapper> getFileVersions(String fileId) {
    	EFSException.addTrace('getFileVersions()');
		List<FileVersionHistoryWrapper> revList = new List<FileVersionHistoryWrapper>();

    	// Execute code based on the storage
    	if (this.clientAccess.dropboxFlag) { // for dropbox only
			DBAPIFiles fil = this.dbClient.files();
			DBAPIFiles.ListRequest listReq = fil.getRevisionsRequest(fileId, 10);
			
			Map<String, People_Integration__c> EFSIdWithPeoplePrefMap = getEFSIdWithPeoplePref();
			
 			try{				
 				DBAPIModelFiles.ListRevisionResult revResp = (DBAPIModelFiles.ListRevisionResult)listReq.execute();
				String dbId = '';
				versionNumber = revResp.entries.size();
 				for(DBAPIModelFiles.Metadata revFile: revResp.entries) {
 					dbId = revFile.sharing_info != null ? revFile.sharing_info.modified_by : UserContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).User__c;
 					People_Integration__c peoplePrefObj = EFSIdWithPeoplePrefMap.get(dbId);
					revList.add(toFileVersionWrapper(revFile, peoplePrefObj));
 				}
 			} catch (SCoreAppException httpex) { 
 				throw new EFSException(listReq, 'File Detail GET ERROR', httpex.getStatusCode() + httpex.getMessage());
 			} catch (Exception ex) {
 				throw new EFSException(listReq, 'Detail Wrapper Conversion ERROR', ex.getMessage());
 			}
    	}

        return revList;
    }
    
    
    public List<FileVersionHistoryWrapper> getFileVersions(String driveId, String fileId) {
    	EFSException.addTrace('getFileVersions()');
		List<FileVersionHistoryWrapper> listOfFileVersionHistory = new List<FileVersionHistoryWrapper>();
		
    	if (this.clientAccess.sharepointFlag || this.clientAccess.onedriveFlag) {
    		MSAPIDriveItem driveItemObj = this.msClient.driveItems();
			MSAPIDriveItem.GetDriveItemVersions itemVersionObj = new MSAPIDriveItem.GetDriveItemVersions(driveItemObj, 
					driveId, fileId);
			MSAPIModelDriveItemVersionContainer diVersionModel = new MSAPIModelDriveItemVersionContainer();
			diVersionModel = (MSAPIModelDriveItemVersionContainer) itemVersionObj.execute();
			
			Boolean firstItem = true;
			for (MSAPIModelDriveItemVersionContainer.MSIAPIModelDriveItemVersion msVerObj: diVersionModel.value) {
				FileVersionHistoryWrapper fileVerWrapObj = new FileVersionHistoryWrapper();
				fileVerWrapObj =  toFileVersionWrapper(msVerObj);
				fileVerWrapObj.versionId = firstItem ? null : fileVerWrapObj.versionNumber;
				listOfFileVersionHistory.add(fileVerWrapObj);
				firstItem = false;
			}
			
    	}
    	    	
    	return listOfFileVersionHistory;
    }
    
    public boolean ownershipTransfer(String fileId, String newOwnerKey) {
    	EFSException.addTrace('ownershipTransfer()');
		boolean statusFlag = false;
		
    	// Execute code based on the storage
    	if(this.clientAccess.dropboxFlag) {
			DBAPISharing shr = new DBAPISharing(this.dbclient);
			DBAPISharing.TransferFolderRequest req = shr.getTransferFolderRequest(fileId, newOwnerKey);
			
			try {
				req.execute();
				statusFlag = true;
			} catch (SCoreAppException ex) { 
				throw new EFSException(req, 'OwnerShip Error', ex.getStatusCode() + ex.getMessage());
			}
		}
    	
    	return statusFlag;    	
    }
    
    public void checkSiteIdInContext() {
    	try {
			if(String.isBlank(siteId) && SiteContext.siteId != null) {
				siteId = SiteContext.siteId;
			}
		} catch (Exception e) {
			siteId = '';
		}
    }
    
    // This is specific to dropbox
    public String shareFolder(String foldName, String sharedFolderId, String viewerGroup, String editorGroup) {				
		DBAPIModelFiles.FolderSharingInfo sharing_info = new DBAPIModelFiles.FolderSharingInfo();
		
		DBAPISharing sharing = new DBAPISharing(this.dbClient);
		DBAPISharing.ShareFolderRequest shrReq = sharing.getShareFolderRequest(foldName);
		
		if(String.isBlank(sharedFolderId)){
			try {
				DBAPIModelSharing.SharedFolderMetadata shrResp = (DBAPIModelSharing.SharedFolderMetadata)shrReq.execute();
				
				sharing_info.shared_folder_id = shrResp.shared_folder_id;					
			} catch (SCoreAppException shrEx) {
				throw new EFSException(shrReq, 'Sharing ERROR using ' + shrReq, shrEx.getMessage());
			}
		} else {
			sharing_info.shared_folder_id = sharedFolderId;
		}
		
		Map<String, String> shrMap = new Map<String, String>();
		if(String.isNotBlank(viewerGroup)) { shrMap.put(viewerGroup, 'viewer'); }
		if(String.isNotBlank(editorGroup)) { shrMap.put(editorGroup, 'editor'); }
		
		if(shrMap.size() > 0) {
			DBAPIModelSharing.AddFolderMemberArg args = new DBAPIModelSharing.AddFolderMemberArg(shrMap);
			args.shared_folder_id = sharing_info.shared_folder_id;
			
			DBAPISharing sharingRes = new DBAPISharing(this.dbClient);
			DBAPISharing.AddMemberRequest request = new DBAPISharing.AddMemberRequest(sharingRes, args);
			try {
				request.execute();
			} catch (SCoreAppException appEx) {
				if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT) {
					return sharing_info.shared_folder_id;
				}
				this.close();
				throw new EFSException(request, 'Adding Folder Member ERROR', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
			}
		} else {
			throw new EFSException(null, 'Please provide group id', '');
		}
		return sharing_info.shared_folder_id;
    }
    
    // This is specific to dropbox
    public String unshareFolder(String sharedFolderId, String grpId) {
    	DBAPISharing.RemoveMemberRequest removeRequest;				
		try {
			DBAPIModelSharing.RemoveFolderMemberArg args = new DBAPIModelSharing.RemoveFolderMemberArg(sharedFolderId, grpId);
			removeRequest = new DBAPISharing.RemoveMemberRequest(new DBAPISharing(this.dbClient), args);
			
			removeRequest.execute();
		} catch(SCoreAppException appEx) {
			// nothing to worry
			throw new EFSException(removeRequest, 'Error unsharing the Folder with the group', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
		}
		
		return sharedFolderId;
    }
    
    // This is specific to dropbox
    public Boolean changeFolderSharing(String sharedFolderId, String grpId, String permission) {
    	Boolean statusFlag = false;
    	DBAPIModelSharing.UpdateFolderMemberArg args = new DBAPIModelSharing.UpdateFolderMemberArg(sharedFolderId, grpId, permission);
    	DBAPISharing.UpdateMemberRequest updateRequest;
    					
		try {
			updateRequest = new DBAPISharing.UpdateMemberRequest(new DBAPISharing(this.dbClient), args);
			
			updateRequest.execute();
			statusFlag = true;
		} catch(SCoreAppException appEx) {
			// nothing to worry
			throw new EFSException(updateRequest, 'Error changing the Folder permission', appEx.getStatusCode() + ' -- ' + appEx.getMessage());
		}
		
    	return statusFlag;
    }
    
    // This is specific to dropbox
    public Map<String, String> listFolders() {
    	Map<String, String> folderPathMap = new Map<String, String>();
    	DBAPISharing sharing = new DBAPISharing(this.dbClient);
    	
    	String cursor = '';
    	// Loop thru the list of mountable folders
    	while(true) {
    		DBAPISharing.ListMountableFolderRequest listReq = sharing.getListMountableFolderRequest(cursor);
    		
			try {
				DBAPIModelSharing.ListFoldersResult listRes = (DBAPIModelSharing.ListFoldersResult)listReq.execute();
				
				for(DBAPIModelSharing.SharedFolderMetadata folderInfo:listRes.entries) {
					folderPathMap.put(folderInfo.shared_folder_id, folderInfo.path_lower);
				}
				
				if(String.isBlank(listRes.cursor)) {
					break;
				} else {
					cursor = listRes.cursor;
				}
			} catch (SCoreAppException shrEx) {
				throw new EFSException(listReq, 'Not able to list the mountable folders', shrEx.getMessage());
			}
			
			if(folderPathMap.size() == 0) {
				break;
			}
    	}
		
		return folderPathMap;
    }

	// This is specific to Dropbox
    public String mountFolder(String shared_folder_id) {
    	String path = ''; 
    	DBAPISharing sharing = new DBAPISharing(this.dbClient);
    	
		DBAPISharing.MountFolderRequest mountReq = sharing.getMountFolderRequest(shared_folder_id);
		
		try {
			DBAPIModelSharing.SharedFolderMetadata mountResp = (DBAPIModelSharing.SharedFolderMetadata)mountReq.execute();
			path = mountResp.path_lower;
		} catch (SCoreAppException shrEx) {
			if (shrEx.getMessage().containsIgnoreCase('already_mounted')) {
				// nothing to worry..
			} else {
				throw new EFSException(mountReq, 'Not able to list the mountable folders', shrEx.getMessage());
			}
			
		}
		
		return path;
    }
    
    // This is specific to Dropbox
    public String getFileOwnerId(String fileId) {
		try {
			DBAPISharing dbSharing = this.dbClient.sharing();
			DBAPISharing.ListFileMembersRequest memReq = dbSharing.getListFileMembersRequest(fileId, '');
			DBAPIModelSharing.SharingListMembersResult memResult = (DBAPIModelSharing.SharingListMembersResult) memReq.execute();
			DBAPIModelSharing.UserInfo ownerInfo = null;
			for(DBAPIModelSharing.UserFileMembershipInfo uInfo: memResult.users) {
				if(uInfo.access_type.get('tag').equalsIgnoreCase('owner')) {
					return uInfo.user.account_id;
				}
			}
		} catch (EFSException oe) {
			// Exception getting the owner info
		}
		
		return null;
    }
    
	public Map<String, Object> searchFilesDropbox (String scope, Criteria.File fileCriteriaObj) {
    	
    	try{
			DBAPIFiles fileReq = this.dbClient.files();
			DBAPIModelFiles.SearchRequestParams args = new DBAPIModelFiles.SearchRequestParams();
			DBAPIModelFiles.Options options = new DBAPIModelFiles.Options();
			Boolean addFilesToResultFlag = false;
			
			if(scope.equalsIgnoreCase('SiteFiles')){
				options.path = '/'+SimpplrContext.ApplicationName+'/'+SiteContext.siteName;
				if (String.isNotBlank(this.siteId) && 'dropbox'.equalsIgnoreCase(SiteContext.fileStorageSource)) {
					addFilesToResultFlag = true;
				}
			} else if(scope.equalsIgnoreCase('MyFiles')){
				options.path = '';
				addFilesToResultFlag = true;
			} else if(scope.equalsIgnoreCase('AppFiles')){
				options.path = String.isNotBlank(fileCriteriaObj.directory) ? fileCriteriaObj.directory : '/'+SimpplrContext.ApplicationName;
			}
			args.query = fileCriteriaObj.term;
			
			options.max_results = fileCriteriaObj.size;

			if(fileCriteriaObj.fullText == false){
				args.mode = 'filename';
			}else{
				args.mode = 'filename_and_content';
			}
			args.options = options;
			
			List<FileListingWrapper> listOfFiles = new List<FileListingWrapper>();
			Map<String, Object> response = new Map<String, Object>();

			if(String.isNotBlank(fileCriteriaObj.nextPageToken)) {
				args.cursor = fileCriteriaObj.nextPageToken;
				DBAPIFiles.SearchContinueRequest searchReq = new DBAPIFiles.SearchContinueRequest(fileReq, args);
				DBAPIModelFiles.SearchResult sr = (DBAPIModelFiles.SearchResult)searchReq.execute();

				for(DBAPIModelFiles.SearchResultItem sRItem :sr.matches) {
					if(sRItem.metadata != null && sRItem.metadata.metadata != null && 'file'.equalsIgnorecase(sRItem.metadata.metadata.tag)){
						FileListingWrapper flw = toFileListingWrapper(sRItem.metadata.metadata, null, null, '', null,false,'');
						if(addFilesToResultFlag || flw.listOfSite.size() > 0) {
							listOfFiles.add(flw);
						}
					}
				}

				response.put('listOfFiles', listOfFiles);
				response.put('totalRecords', fileCriteriaObj.size + '+');
				response.put('cursor', sr.cursor);
				
			} else {
				DBAPIFiles.SearchRequest searchReq = new DBAPIFiles.SearchRequest(fileReq, args);
				DBAPIModelFiles.SearchResult sr = (DBAPIModelFiles.SearchResult)searchReq.execute();

				for(DBAPIModelFiles.SearchResultItem sRItem :sr.matches) {
					if(sRItem.metadata != null && sRItem.metadata.metadata != null && 'file'.equalsIgnorecase(sRItem.metadata.metadata.tag)){
						FileListingWrapper flw = toFileListingWrapper(sRItem.metadata.metadata, null, null, '', null,false,'');
						if(addFilesToResultFlag || flw.listOfSite.size() > 0) {
							listOfFiles.add(flw);
						}
					}
				}

				response.put('listOfFiles', listOfFiles);
				if(sr.has_more) {
					response.put('totalRecords', fileCriteriaObj.size + '+');
				} else {
					response.put('totalRecords', listOfFiles.size());
				}
				response.put('cursor', sr.cursor);
			}

			return response;
		} catch(SCoreAppException appEx){
            
            if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT && appEx.getMessage().contains('not_found')){
   				//Folder not found
   				this.close();
				throw new SimpplrException(ServiceConstants.FILES_NOT_FOUND);
			}
			
			throw new EFSException('Search Listing Error', appEx.getMessage());
        }
    }

    private List<FileListingWrapper> searchFilesSharepoint (String scope, Criteria.File fileCriteriaObj) {
    	try{
			MSAPIDrive fileReq = this.msClient.drives();
			Set<String> driveIdSet = new Set<String>();
			if('SiteFiles'.equalsIgnorecase(scope)){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', fileCriteriaObj.siteId);
				String folderQuery = 'Select Id, External_Folder_Id__c from Folder__c where Type__c=\'sharepoint\' ' +
					' and Site__c=:soqlParam1 and Is_Deleted__c = false and Is_System_Folder__c = false and Site__r.File_Storage_Source__c=\'sharepoint\'';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
					for(Folder__c folderObj : folderList){
						driveIdSet.add(folderObj.External_Folder_Id__c);
					}			
			} else if('AppFiles'.equalsIgnorecase(scope) || 'MyFiles'.equalsIgnorecase(scope)){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', ServiceConstants.PUBLIC_SITE);
				soqlParamMap.put('soqlParam2', UserContext.sitesIFollowIdSet);
				String folderQuery = 'Select Id, External_Folder_Id__c from Folder__c where Type__c=\'sharepoint\' ' +
					' and Is_Deleted__c = false and Is_System_Folder__c = false AND (Site__r.Site_Type__c =: soqlParam1 OR Site__c IN: soqlParam2) and Site__r.File_Storage_Source__c=\'sharepoint\'';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
					for(Folder__c folderObj : folderList){
						driveIdSet.add(folderObj.External_Folder_Id__c);
					}
			}
			List<FileListingWrapper> listOfFiles = new List<FileListingWrapper>();
			if(driveIdSet.isEmpty() == false) {
				MSAPIDrive.SearchMSFiles msChildrenObj = new MSAPIDrive.SearchMSFiles(fileReq, fileCriteriaObj.term.replaceAll('\'',''), driveIdSet);
				MSAPIModelDriveItem.SearchResult searchResult = (MSAPIModelDriveItem.SearchResult)msChildrenObj.execute();
				//This set is used to remove the duplicate files from search result
				Set<String> fileIdSet = new Set<String>();
				for(MSAPIModelDriveItem.SearchResultItem searchItem : searchResult.responses) {
					if(searchItem.body != null && searchItem.body.value != null){
						for(MSAPIModelDriveItem driveItem : searchItem.body.value){
							if(driveItem.file != null){
								if(fileIdSet.add(driveItem.id)){
									listOfFiles.add(toFileListingWrapper(driveItem, getEFSIdWithPeoplePref(), '', 'readwrite'));
								}
							}
						}
					}
				}
			}
			return listOfFiles;
		} catch(SCoreAppException appEx){
			throw new EFSException('Search Listing Error', appEx.getMessage());
        }
	}

	private String getCurrentUserAccessToken(String provider) {
		String accessToken = '';
		
		People_Integration__c integObj = null;
		if(UserContext.Integrations.containsKey(provider)) {
			integObj = UserContext.Integrations.get(provider);
			accessToken = integObj.Access_Token__c;
		}

		return accessToken;
	}

	public Map<String, Object> getMSDriveFilesCuratedSearch (String scope, Criteria.File fileCriteriaObj, Set<String> inaccessibleCGIdSet) {
    	try {
			String inaccessibleCGIdsListString = '';
			if(inaccessibleCGIdSet != null && !inaccessibleCGIdSet.isEmpty()) {
				inaccessibleCGIdsListString = inaccessibleCGIdSet.toString();
			}
			
			String simpDri = Utility.externalRequestAuthToken() + ' '
									+ SimpplrContext.simpplrOrgId.substring(0, 15) + ' '
									+ UserContext.userId.substring(0, 15);
			
			HttpRequest reqObj = new HttpRequest();
			reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint + '/spodbc/search-sp?action=search');
			if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider)){
				reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint + '/spodbc/search-odb?action=search');
			}
			
			reqObj.setTimeout(60000);
			reqObj.setHeader('content-type','application/json');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setHeader('simpplr-dri', simpDri);
			reqObj.setMethod('POST');

			String term = fileCriteriaObj.term.replaceAll('\'','');
			if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileCriteriaObj.provider)){
				term = term + '*';
			}

			Map<String, String> requestMap = new Map<String, String>();
			requestMap.put('orgId', UserInfo.getOrganizationId());
			requestMap.put('simpplrSiteId', fileCriteriaObj.siteId);
			requestMap.put('inaccessibleCGIdList', inaccessibleCGIdsListString);
			requestMap.put('peopleId', UserContext.peopleId);
			requestMap.put('provider', fileCriteriaObj.provider);
			requestMap.put('nextPageToken', fileCriteriaObj.nextPageToken);		
			requestMap.put('term', term);
			requestMap.put('token', getCurrentUserAccessToken(fileCriteriaObj.provider));
			
			reqObj.setBody(Json.serialize(requestMap));
			
			logger.logDebug('EFSFileService.searchFilesViaAWS()----Request Body----' + reqObj.getBody());
			
			Http httpObj = new Http();
			HTTPResponse resObj = httpObj.send(reqObj);
			
			logger.logDebug('EFSFileService.searchFilesViaAWS()----Response Body----' + resObj.getBody());
			
			MSAPIModelDriveItem.AWSSearchResult fullSearchResultObj;
			if(resObj.getStatusCode() == 200) {
				fullSearchResultObj = (MSAPIModelDriveItem.AWSSearchResult)JSON.deserialize(resObj.getBody(), MSAPIModelDriveItem.AWSSearchResult.class);
			}
            List<FileListingWrapper> listOfFiles = new List<FileListingWrapper>();
            for(MSAPIModelDriveItem driveItem : fullSearchResultObj.result){
                listOfFiles.add(toFileListingWrapper(driveItem, getEFSIdWithPeoplePref(), '', 'readwrite'));
			}
			
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('nextPageToken', fullSearchResultObj.nextPageToken);
            responseMap.put('totalRecords', fullSearchResultObj.totalItem);
            responseMap.put('listOfItems', listOfFiles);
			return responseMap;
		} catch(Exception ex) {
			logger.logError('EFSFileService.getMSDriveFilesCuratedSearch()----Exception Occured----', ex);
			throw new EFSException('Search Listing Error', ex.getMessage());
        }
	}

	public Map<String, Object> searchAllFilesSharePoint(Criteria.File fileCriteriaObj) {
		List<FileListingWrapper> listOfFiles = new List<FileListingWrapper>();
		String nextPageToken;
		Integer totalRecords=0;
		HttpRequest reqObj = new HttpRequest();
		reqObj.setEndpoint(SimpplrContext.simpplrIntegrationServiceEndpoint+'?action=mssearch');
		reqObj.setTimeout(60000);
		reqObj.setHeader('content-type','application/json');
		reqObj.setHeader('accept', 'application/json');
		reqObj.setMethod('POST');
		Map<String, String> requestMap = new Map<String, String>();
		requestMap.put('sfOrgId', UserInfo.getOrganizationId());
		requestMap.put('peopleId', UserContext.peopleId);
		requestMap.put('term', fileCriteriaObj.term);
		requestMap.put('accessToken', this.clientAccess.getAccessToken());
		requestMap.put('nextPageToken', fileCriteriaObj.nextPageToken == null ? '0' : fileCriteriaObj.nextPageToken);		
		reqObj.setBody(Json.serialize(requestMap));
		logger.logDebug('EFSFileService.searchAllFilesSharePoint()----Request Body----' + reqObj.getBody());
		Http httpObj = new Http();
		HTTPResponse resObj = httpObj.send(reqObj);
		logger.logDebug('EFSFileService.searchAllFilesSharePoint()----Response Body----' + resObj.getBody());

		if(resObj.getStatusCode() == 200) {
			MSAPIModelDriveItem.FullSearchResult fullSearchResultObj = (MSAPIModelDriveItem.FullSearchResult)JSON.deserialize(resObj.getBody(), MSAPIModelDriveItem.FullSearchResult.class);
			//This set is used to remove the duplicate files from search result
			totalRecords = fullSearchResultObj.totalItem;
			nextPageToken = fullSearchResultObj.nextPageToken;
			Set<String> fileIdSet = new Set<String>();
			for(MSAPIModelDriveItem driveItem : fullSearchResultObj.result){
				if(driveItem.file != null){
					FileListingWrapper wrapperObj = toFileListingWrapper(driveItem, getEFSIdWithPeoplePref(), '', 'readwrite');
					if(wrapperObj.rootDirectory == null) {
						wrapperObj.canDownload = false;
						Map<String, Object> fileDetailObj = new Map<String, Object>();
						fileDetailObj.put('name', wrapperObj.name);
						fileDetailObj.put('externalUrl', wrapperObj.externalUrl);
						fileDetailObj.put('extension', wrapperObj.fileExtension);
						fileDetailObj.put('size', wrapperObj.size);
						wrapperObj.url += '&fileDetailJson=' + EncodingUtil.urlEncode(Json.serialize(fileDetailObj), 'UTF-8');
					}
					listOfFiles.add(wrapperObj);
				}
			}
		}

		Map<String, Object> responseMap = new Map<String, Object>();
		responseMap.put('nextPageToken', nextPageToken);
		responseMap.put('totalRecords', totalRecords);
		responseMap.put('listOfFiles', listOfFiles);
		return responseMap;
	}

	public void insertAWSRecordForFolder(String siteId, String sharepointSiteId, String sharepointInstanceId, String collaborationGroupId, String driveId, String driveItemId, 
											String path, String userName, String storageProvider){
		
		try{
			String simpDri = Utility.externalRequestAuthToken() + ' '
                    			+ SimpplrContext.simpplrOrgId.substring(0, 15) + ' '
                    			+ UserContext.userId.substring(0, 15);
			
			HttpRequest reqObj = new HttpRequest();
			if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(storageProvider)){
				reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint + '/spodbc/search-odb?action=savelinkeditem');
			} else {
				reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint + '/spodbc/search-sp?action=savelinkeditem'); 
			}
			reqObj.setTimeout(60000);
			reqObj.setHeader('content-type','application/json');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setHeader('simpplr-dri', simpDri);
			reqObj.setMethod('POST');

			Map<String, String> requestMap = new Map<String, String>();
			requestMap.put('orgId', UserInfo.getOrganizationId());
			requestMap.put('userName', userName);
			requestMap.put('userId', UserContext.userId);
			requestMap.put('peopleId', UserContext.peopleId);
			requestMap.put('collaborationGroupId', collaborationGroupId);
			requestMap.put('simpplrSiteId', siteId);
			requestMap.put('driveId', driveId);
			requestMap.put('folderId', driveItemId);
			requestMap.put('webUrl', path);
			requestMap.put('provider', storageProvider);
			requestMap.put('sharepointSiteId', sharepointSiteId);
			requestMap.put('sharepointInstanceId', sharepointInstanceId);
			requestMap.put('accessToken', this.clientAccess.getAccessToken());
			
			reqObj.setBody(Json.serialize(requestMap));
			logger.logDebug('EFSFileService.createAWSRecordForFolder()----Request Body----' + reqObj.getBody());
			
			Http httpObj = new Http();
			HTTPResponse resObj = httpObj.send(reqObj);
			
			logger.logDebug('EFSFileService.createAWSRecordForFolder()----Response Body----' + resObj.getBody());
			
			if (resObj.getStatusCode()== 200) {
				String resBodyJSON = resObj.getBody();
				String resHeaderJSON = resObj.getHeader('headerData');
				logger.logDebug('createAWSRecordForFolder()----Response----' + resBodyJSON);
			} else {
				throw new EFSException('Folder Linking Error AWS');	
			}

		} catch(Exception ex){
			logger.logError('EFSFileService Exception:',ex);
			throw new EFSException('Folder Linking Error AWS', ex.getMessage());	
		}
	}

	public void deleteAWSRecordForFolder(String siteId, Boolean removeAllForSite, String driveId, String driveItemId, String userName, String storageProvider){
		
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
			requestMap.put('removeAllForSite', (removeAllForSite ? 'true' : 'false'));
			reqObj.setBody(Json.serialize(requestMap));

			logger.logDebug('EFSFileService.deleteAWSRecordForFolder()----Request Body----' + reqObj.getBody());
			
			Http httpObj = new Http();
			HTTPResponse resObj = httpObj.send(reqObj);
			
			logger.logDebug('EFSFileService.deleteAWSRecordForFolder()----Response Body----' + resObj.getBody());
			
			if (resObj.getStatusCode()== 200) {
				String resBodyJSON = resObj.getBody();
				String resHeaderJSON = resObj.getHeader('headerData');
				logger.logDebug('createAWSRecordForFolder()----Response----' + resBodyJSON);
			} else {
				throw new EFSException('Folder Linking Error AWS');	
			}

		} catch(Exception ex){
			logger.logError('EFSFileService Exception:',ex);
			throw new EFSException('Folder Linking Error AWS', ex.getMessage());	
		}
	}

    private List<FileListingWrapper> searchFilesOnedrive(String scope, Criteria.File fileCriteriaObj) {
    	try{
			MSAPIDrive fileReq = this.msClient.drives();
 			Set<String> driveIdSet = new Set<String>();
 			Set<String> driveItemIdSet = new Set<String>();
 			if('SiteFiles'.equalsIgnorecase(scope)){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', fileCriteriaObj.siteId);
				String folderQuery = 'Select Id, External_Folder_Id__c, EFS_Drive_Id__c from Folder__c where Type__c=\'onedrive\' ' +
					' and Site__c=:soqlParam1 and Is_Deleted__c = false and Is_System_Folder__c = false and Site__r.File_Storage_Source__c=\'onedrive\'';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
 					for(Folder__c folderObj : folderList){
 						driveIdSet.add(folderObj.EFS_Drive_Id__c);
 						driveItemIdSet.add(folderObj.External_Folder_Id__c);
 					}
 			} else if('AppFiles'.equalsIgnorecase(scope) || 'MyFiles'.equalsIgnorecase(scope)){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', ServiceConstants.PUBLIC_SITE);
				soqlParamMap.put('soqlParam2', UserContext.sitesIFollowIdSet);
				String folderQuery = 'Select Id, External_Folder_Id__c, EFS_Drive_Id__c from Folder__c where Type__c=\'onedrive\' ' +
					' and Is_Deleted__c = false and Is_System_Folder__c = false AND (Site__r.Site_Type__c =: soqlParam1 OR Site__c IN: soqlParam2) and Site__r.File_Storage_Source__c=\'onedrive\'';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
 					for(Folder__c folderObj : folderList){
 						driveIdSet.add(folderObj.EFS_Drive_Id__c);
 						driveItemIdSet.add(folderObj.External_Folder_Id__c);
 					}
 			}
 			MSAPIDrive.SearchMSFiles msChildrenObj = new MSAPIDrive.SearchMSFiles(fileReq, fileCriteriaObj.term.replaceAll('\'',''), driveIdSet);
 			MSAPIModelDriveItem.SearchResult searchResult = (MSAPIModelDriveItem.SearchResult)msChildrenObj.execute();
 			List<FileListingWrapper> listOfFiles = new List<FileListingWrapper>();
 			//This set is used to remove the duplicate files from search result
 			Set<String> fileIdSet = new Set<String>();
 			for(MSAPIModelDriveItem.SearchResultItem searchItem : searchResult.responses) {
 				if(searchItem.body != null && searchItem.body.value != null){
 					for(MSAPIModelDriveItem driveItem : searchItem.body.value){
 						if(driveItem.file != null){
 							if(fileIdSet.add(driveItem.id)){
 								//if(driveItemIdSet.contains(driveItem.parentReference.id)){
 									listOfFiles.add(toFileListingWrapper(driveItem, getEFSIdWithPeoplePref(), '', 'readwrite'));
 								//}
 							}
 						}
 					}
 				}
 			}
 			return listOfFiles;
		} catch(SCoreAppException appEx){
			throw new EFSException('Search Listing Error', appEx.getMessage());
        }
    }
    
    private List<FileListingWrapper> listFilesDropbox (String qStr, Criteria.File fileCriteriaObj) {
        List<FileListingWrapper> fileList = new List<FileListingWrapper>();
        DBAPIFiles fil = new DBAPIFiles(this.dbClient);
        DBAPIModelFiles.ListResult listResp;
        DBAPIFiles.ListRequest listReq;
        
        DBAPIModelFiles.ListFolderArg listReqArgs = new DBAPIModelFiles.ListFolderArg();
        listReqArgs.path = qStr;
        listReq = fil.getListRequest(listReqArgs);
        try{
        	listResp = (DBAPIModelFiles.ListResult)listReq.execute();
        } catch(SCoreAppException appEx){
            if(appEx.getStatusCode() == SCoreAppException.ERROR_HTTP_CONFLICT && appEx.getMessage().contains('not_found')){
   				//Folder not found
   				this.close();
				throw new SimpplrException(ServiceConstants.FILES_NOT_FOUND);
			}
			
			throw new EFSException('Dropbox File Listing Error', appEx.getMessage());
		}
		
        listResp.entries.sort();
        
        List<DBAPIModelFiles.Metadata> filesToBeReturned = new List<DBAPIModelFiles.Metadata>();
        
        Integer filesCount = listResp.entries.size();
        Integer size = fileCriteriaObj.size;
		Integer startIndex = fileCriteriaObj.nextPageToken == null ? 0 : 
				integer.valueOf(fileCriteriaObj.nextPageToken) ;
		Integer endIndex = (startIndex + Integer.valueOf(fileCriteriaObj.size)) >= filesCount ? 
				filesCount : startIndex + Integer.valueOf(fileCriteriaObj.size);
		
		for (integer i=startIndex; i< endIndex ; i++) {
			filesToBeReturned.add(listResp.entries.get(i));
		}
		
		if (endIndex < filesCount && endIndex < 2000) {
			this.nextPageToken = String.valueOf(endIndex);
		} else {
			this.nextPageToken = null;
		}
    				
        List<String> filesList = new List<String>();
        Set<String> folderIdSet = new Set<String>();
        Map<String, People_Integration__c> dbUserMap = new Map<String, People_Integration__c>();
        
        // Consolidate the files for getting owner info
        for(DBAPIModelFiles.Metadata metaObj : filesToBeReturned) {
        	if(metaObj.tag == 'file') {
        		filesList.add(metaObj.id);
        	} else {
        		if(metaObj.sharing_info != null) {
        			folderIdSet.add(metaObj.sharing_info.parent_shared_folder_id);
        			folderIdSet.add(metaObj.sharing_info.shared_folder_id);
        		}
        	}
        }
        
    	// Get the dbId to People_Preference__c Map
		dbUserMap = getEFSIdWithPeoplePref();
		
        // Call the list_folder_member to get the folder owner info
        if(folderIdSet.size() > 0) {
        	folderIdSet.remove(null);
        	for(String folderId: folderIdSet) {
	    		// Get the Owner info
	    		try {
	    			DBAPISharing dbSharing = this.dbClient.sharing();
	    			DBAPISharing.ListFolderMembersRequest memReq = dbSharing.getListFolderMembersRequest(folderId, '');
	    			DBAPIModelSharing.SharingListMembersResult memResult = (DBAPIModelSharing.SharingListMembersResult) memReq.execute();
	    			DBAPIModelSharing.UserInfo ownerInfo = null;
	    			for(DBAPIModelSharing.UserFileMembershipInfo uInfo: memResult.users) {
	    				if(uInfo.access_type.get('tag').equalsIgnoreCase('owner')) {
	    					dbUserMap.put(folderId, dbUserMap.get(uInfo.user.account_id));
	    				}
	    			}
	    		} catch (EFSException oe) {
	    			// Exception getting the owner info
	    		}
        	}	        	
        }
        
        for(DBAPIModelFiles.Metadata respMetaObj : filesToBeReturned) {
        	// Fix for not showing the files on Move File Request
        	if(fileCriteriaObj.currentDirectory != null && respMetaObj.tag.equalsIgnoreCase('file')) { 
        		break; 
        	}
        	fileList.add(toFileListingWrapper(respMetaObj, null, dbUserMap, '', null,false,''));
        }
        
        return fileList;
    }
    
    private List<FileListingWrapper> listFilesSharepoint(String qStr, Criteria.File fileCriteriaObj) {
    	//logger.logDebug(fileCriteriaObj);
		List<FileListingWrapper> listToBeReturned = new List<FileListingWrapper>();
    	try {
			MSAPIDrive fileReq = this.msClient.drives();
			MSAPIDrive.DriveItemChildrenListing msChildrenObj;
			MSAPIModelDriveItem msDriveItem;

			if(SimpplrContext.isSharepointUpgraded && ( fileCriteriaObj.spInstanceId  != null && UserContext.spInstanceId != null && !fileCriteriaObj.spInstanceId .equalsIgnoreCase(UserContext.spInstanceId))){
				//folder is from different Instance
				this.msParentPermission = 'none';
				return listToBeReturned;
			}

			if(String.isBlank(fileCriteriaObj.nextPageUrl)) {
				msChildrenObj = new MSAPIDrive.DriveItemChildrenListing(fileReq, 
																		fileCriteriaObj.rootDirectory, 
																		Utility.encodeURLString(fileCriteriaObj.directory), 
																		fileCriteriaObj.sortBy);
				msDriveItem = (MSAPIModelDriveItem)msChildrenObj.execute();
			} else {
				msChildrenObj = new MSAPIDrive.DriveItemChildrenListing(fileReq,
					fileCriteriaObj.nextPageUrl,
					fileCriteriaObj.sortBy);
				MSAPIModelDriveItem msDriveChildrenItem = (MSAPIModelDriveItem)msChildrenObj.execute();
				msDriveItem = new MSAPIModelDriveItem();
				msDriveItem.children = msDriveChildrenItem.value;
				msDriveItem.childrenNextLink = msDriveChildrenItem.childrenNextLink;
				if(msDriveChildrenItem.value != null && msDriveChildrenItem.value.size() > 0) {
					String webUrl = msDriveChildrenItem.value[0].webUrl;
					msDriveItem.webUrl = String.isNotBlank(webUrl) ? webUrl.substringBeforeLast('/') : '';
				}
			}
			
			List<FileListingWrapper> listOfFiles = new List<FileListingWrapper>();
			
			// memberOf API call
			Set<String> memberOf = new Set<String>();
			MSAPIUser usrObj = this.msClient.users();
			
			MSAPIUser.GroupsMemberOf usrGrpReq = new MSAPIUser.GroupsMemberOf(usrObj);
			MSAPIModelUser.GroupList grpList = (MSAPIModelUser.GroupList)usrGrpReq.execute();
			
			if(grpList != null) {
				for(MSAPIModelUser.GraphGroup grpObj: grpList.value) {
					memberOf.add(grpObj.id);
					memberOf.add(grpObj.mail);
				}
			}
			
			String parPerm = 'readwrite';
			this.msParentPermission = parPerm;

			// Map of existing users
			Map<String, People_Integration__c> pplIntegMap = getEFSIdWithPeoplePref();
			
			Boolean writeFolderFlag = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObj.filter);
			if(msDriveItem != null && msDriveItem.children != null) {
				for(MSAPIModelDriveItem driveItem : msDriveItem.children) {
					if(!writeFolderFlag || 
					(writeFolderFlag && 
						driveItem.folder != null && 
						(String.isBlank(fileCriteriaObj.directory) || parPerm.equalsIgnoreCase('readwrite')))) {
						FileListingWrapper fileObj = toFileListingWrapper(driveItem, pplIntegMap, fileCriteriaObj.rootDirectory, parPerm);
						fileObj.pathOnClient = msDriveItem.weburl; 
						fileObj.sortby = fileCriteriaObj.sortBy; 

						listOfFiles.add(fileObj);
					}
				}
			}
			listOfFiles.sort();
			
			FileWrapper.FilePaginationWrapper filePageWrapObj = returnSpecifiedPaginationList(listOfFiles,
					fileCriteriaObj.size, fileCriteriaObj.nextPageToken, msDriveItem.childrenNextLink); 
			List<Object> ObjectList = filePageWrapObj.objectList;
			
			for (Object obj : ObjectList) {
				listToBeReturned.add( (FileListingWrapper) obj); 
			}		
			this.nextPageToken = filePageWrapObj.nextPageToken;
			this.nextPageUrl = String.isNotBlank(filePageWrapObj.nextPageUrl) ? filePageWrapObj.nextPageUrl : fileCriteriaObj.nextPageUrl;
			
			// return parent info in webUrl if there is no children to give parent info
			if (msDriveItem != null && listToBeReturned.isEmpty()) {
				FileListingWrapper flw = new FileListingWrapper(); 
				flw.pathOnClient = msDriveItem.weburl; 
				listToBeReturned.add(flw);
				if(String.isBlank(msDriveItem.childrenNextLink)) {
					this.nextPageToken = null;
				}
				this.nextPageUrl = msDriveItem.childrenNextLink;
			}

			return listToBeReturned;
		} catch(SCoreAppException appEx){
			if(appEx.getMessage().containsIgnoreCase('Not Found') && fileCriteriaObj.isMediaManager == true && String.isBlank(fileCriteriaObj.siteId)
			 	&& String.isNotBlank(fileCriteriaObj.provider) && 'onedrive'.equalsIgnoreCase(fileCriteriaObj.provider)) {
				throw new SimpplrException('fileNoPermission');
			}else if (appEx.getMessage().containsIgnoreCase('Forbidden') || 
			    (appEx.getMessage().containsIgnoreCase('Not Found') && (fileCriteriaObj.provider.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING) ||
 				( fileCriteriaObj.provider.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING) && 
 				 !UserContext.Integrations.get('onedrive').My_Drive_Id__c.equalsIgnoreCase(fileCriteriaObj.rootDirectory)))
			    )) {
				this.msParentPermission = 'none';
 				return listToBeReturned;
 			} else {
				throw new EFSException('Search Listing Error', appEx.getMessage());
			}
        }
    }
    
    private List<FileListingWrapper> listFilesMyDrive(Criteria.File fileCriteriaObj) {
		List<FileListingWrapper> listOfFiles = new List<FileListingWrapper>();
    	try{
			MSAPIDrive fileReq = this.msClient.drives();
			MSAPIDrive.MyDrives odObj = new MSAPIDrive.MyDrives(fileReq, fileCriteriaObj.directory);
			MSAPIModelDrive.ItemListing srchResp = (MSAPIModelDrive.ItemListing)odObj.execute();
			MSAPIModelDriveItem tempItem = null;
			for(MSAPIModelDriveItem driveItem : srchResp.value) {
				tempItem = (driveItem.remoteItem != null) ? driveItem.remoteItem : driveItem;

				if(tempItem.parentReference != null && tempItem.parentReference.driveType == 'business') {
					listOfFiles.add(toFileListingWrapper(tempItem, getEFSIdWithPeoplePref(), '', 'readwrite'));
				}				
			}
			return listOfFiles;
		} catch(SCoreAppException appEx){
			if (appEx.getMessage().containsIgnoreCase('Forbidden')) {
				this.msParentPermission = 'none';
 				return listOfFiles;
 			} else {
				throw new EFSException('Search Listing Error', appEx.getMessage());
			}
        }
    }
    
    // Method to fecth the details of a particular file
	public String getPreviewUrl (String fileId, String driveId, String siteId) {
		MSAPIDriveItem driveItemObj = this.msClient.driveItems();
		MSAPIDriveItem.GetPreview previewObj = new MSAPIDriveItem.GetPreview(driveItemObj, driveId, fileId);
		MSAPIModelDriveItem.Preview previewModelObj = new MSAPIModelDriveItem.Preview();
		previewModelObj = (MSAPIModelDriveItem.Preview) previewObj.execute();
		return previewModelObj.getUrl;
	}

    public MSAPIModelSite.MSSiteListing getMSSiteListing(){
		MSAPISite msSite = new MSAPISite(msClient);
		MSAPISite.SitesSearchList msObj = new MSAPISite.SitesSearchList(msSite);
		MSAPIModelSite.MSSiteListing resp = (MSAPIModelSite.MSSiteListing)msObj.execute();
		return resp;
    }
	
	//Not in use anymore
    public MSAPIModelSite getMSChildrenItemListing(String siteId){
		MSAPIModelSite resp = new MSAPIModelSite();
		MSAPISite msSite = new MSAPISite(msClient);
		MSAPISite.ListSubsitesAndDrives msObj = new MSAPISite.ListSubsitesAndDrives(msSite, siteId);
		resp = (MSAPIModelSite)msObj.execute();
		return resp;
	}
	
	public MSAPIModelSite.SearchResult searchSharepointLinkableItems(String webUrl, String term){
		MSAPISite msSite = new MSAPISite(msClient);
		MSAPISite.Search msObj = new MSAPISite.Search(msSite, webUrl, term);
		MSAPIModelSite.SearchResult resp = (MSAPIModelSite.SearchResult)msObj.execute();
		return resp;
    }
    
    public List<MSAPIModelDriveItem.UIOnedriveLinkingResponse> getOnedriveLinkableItemListing(String folderType, String folderId, String driveId){
		MSAPIDrive drive = this.msClient.drives();
		
		List<MSAPIModelDriveItem.UIOnedriveLinkingResponse> resp = new List<MSAPIModelDriveItem.UIOnedriveLinkingResponse>();
		
		if(String.isNotBlank(folderId) && String.isNotBlank(driveId)){
			MSAPIDrive.DriveItemChildrenListing odItemListObj = new MSAPIDrive.DriveItemChildrenListing(drive, driveId, folderId, null);
			MSAPIModelDriveItem msDriveItem = (MSAPIModelDriveItem)odItemListObj.execute();
			if(msDriveItem.children != null) {
				for(MSAPIModelDriveItem msDriveItemObj : msDriveItem.children) {
					if(msDriveItemObj.folder != null){
						MSAPIModelDriveItem.UIOnedriveLinkingResponse respItem = new MSAPIModelDriveItem.UIOnedriveLinkingResponse();
						respItem.driveId = driveId;
						respItem.id = msDriveItemObj.id;
						respItem.name = msDriveItemObj.name;
						respItem.webUrl = msDriveItemObj.webUrl;
						respItem.owner = new Criteria.OwnerWrapper();
						
						if(msDriveItemObj.createdBy.user != null) {
							People_Integration__c ppl = getEFSIdWithPeoplePref().get(msDriveItemObj.createdBy.user.email);
							if(ppl != null) {
								respItem.owner.Id = ppl.People__c;
								respItem.owner.Name = ppl.People__r.Full_Name__c;
								respItem.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ ppl.People__c;
							} else {
								respItem.owner.Name = msDriveItemObj.createdBy.user.displayName;
							}
						} else {
							respItem.owner.Id = UserContext.peopleId;
					    	respItem.owner.Name = UserContext.getCurrentUserInfo.Full_Name__c;
					    	respItem.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + UserContext.peopleId;
						}

						MSAPIModelDriveItem.ItemReference parent = null;
						parent = (msDriveItemObj.remoteItem == null) ?  msDriveItemObj.parentReference : msDriveItemObj.remoteItem.parentReference;
						
						if(parent.driveType == 'business') {
							respItem.driveId = parent.driveId;
							if(String.isNotBlank(parent.path)) {
								respItem.path = '/root:' + parent.path.substringAfter('root:');
							} else {
								respItem.path = '/root:/' + msDriveItemObj.webUrl.subStringAfter('/Documents/'); 
							}
							respItem.path = EncodingUtil.urlDecode(respItem.path.replaceAll('\\+','%2B'), 'UTF-8');
							resp.add(respItem);
						}
					}
				}	
			}
		} else {
			MSAPIDrive.MyDrives odItemListObj;
			if('shared-folders'.equalsIgnoreCase(folderType)){
				odItemListObj = new MSAPIDrive.MyDrives(drive, null);
			} else if('my-folders'.equalsIgnoreCase(folderType)){
				odItemListObj = new MSAPIDrive.MyDrives(drive, 'me');
			}
			
			MSAPIModelDrive.ItemListing msDriveItem = (MSAPIModelDrive.ItemListing)odItemListObj.execute();
			if(msDriveItem.value != null){
				for(MSAPIModelDriveItem msDriveItemObj : msDriveItem.value){
					if(msDriveItemObj.folder != null) {
						MSAPIModelDriveItem.UIOnedriveLinkingResponse respItem = new MSAPIModelDriveItem.UIOnedriveLinkingResponse();
						respItem.id = msDriveItemObj.id;
						respItem.name = msDriveItemObj.name;
						respItem.webUrl = msDriveItemObj.webUrl;
						respItem.owner = new Criteria.OwnerWrapper();
						
						if(msDriveItemObj.createdBy.user != null) {
							People_Integration__c ppl = getEFSIdWithPeoplePref().get(msDriveItemObj.createdBy.user.email);
							if(ppl != null) {
								respItem.owner.Id = ppl.People__c;
								respItem.owner.Name = ppl.People__r.Full_Name__c;
								respItem.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ ppl.People__c;
							} else {
								respItem.owner.Name = msDriveItemObj.createdBy.user.displayName;
							}
						} else {
							respItem.owner.Id = UserContext.peopleId;
					    	respItem.owner.Name = UserContext.getCurrentUserInfo.Full_Name__c;
					    	respItem.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + UserContext.peopleId;
						}
						
						MSAPIModelDriveItem.ItemReference parent = null;
						parent = (msDriveItemObj.remoteItem == null) ?  msDriveItemObj.parentReference : msDriveItemObj.remoteItem.parentReference;
						
						if(parent.driveType == 'business') {
							respItem.driveId = parent.driveId;
							if(String.isNotBlank(parent.path)) {
								respItem.path = '/root:' + parent.path.substringAfter('root:');
							} else {
								respItem.path = '/root:/' + msDriveItemObj.webUrl.subStringAfter('/Documents/'); 
							}
							respItem.path = EncodingUtil.urlDecode(respItem.path.replaceAll('\\+','%2B'), 'UTF-8');
							resp.add(respItem);
						}
					}
				}	
			}
		}
		return resp;
    }
    
    public FileVersionHistoryWrapper toFileVersionWrapper(
    	MSAPIModelDriveItemVersionContainer.MSIAPIModelDriveItemVersion msVerObj){
		EFSException.addTrace('toFileVersionWrapper()');
		FileVersionHistoryWrapper filVerHistObj = new FileVersionHistoryWrapper();
		
		try {
	    	filVerHistObj.versionNumber = msVerObj.id;
			filVerHistObj.createdAt = msVerObj.lastModifiedDateTime;
			
			if(msVerObj.lastModifiedBy != null && msVerObj.lastModifiedBy.user != null) {
				filVerHistObj.user.Id = msVerObj.lastModifiedBy.user.id;
				filVerHistObj.user.Name = msVerObj.lastModifiedBy.user.displayname;
				String pplKey = msVerObj.lastModifiedBy.user.id;
				if(String.isBlank(pplKey)) {
					filVerHistObj.user.Name = msVerObj.lastModifiedBy.user.displayName;
				} else {
					Map<String, People_Integration__c> EFSIdWithPeoplePrefMap = getEFSIdWithPeoplePref();
					
					People_Integration__c ppl = EFSIdWithPeoplePrefMap.get(pplKey);
					if(ppl != null) {
						filVerHistObj.user.Id = ppl.People__c;
						filVerHistObj.user.Name = ppl.People__r.Full_Name__c;
						filVerHistObj.user.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ ppl.People__c;
					}
				}
			}
			
			filVerHistObj.canDownload = false;
		} catch(NullPointerException npe) {
    		this.close();
        	throw new EFSException('CONVERSION ERROR', npe.getMessage());
    	}
    	
		return filVerHistObj;
	}

	public FileWrapper.FilePaginationWrapper returnSpecifiedPaginationList (List<Object> fullList, Integer size, 
				String nextPageToken, String nextPageUrl) {
		FileWrapper.FilePaginationWrapper filePageWrapObj = new FileWrapper.FilePaginationWrapper();
		List<Object> listToBeReturned = new List<Object>();

		if(fullList.size() > 0) {		
			Integer filesCount = fullList.size();
			Integer startIndex = nextPageToken == null ? 0 : Integer.valueOf(nextPageToken) ;
			Integer endIndex = (startIndex + size) >= filesCount ? filesCount : startIndex + size;
			
			for (integer i=startIndex; i< endIndex ; i++) {
				listToBeReturned.add(fullList.get(i));
			}
			filePageWrapObj.objectList = listToBeReturned;
			if (endIndex < filesCount && endIndex < 2000) {
				filePageWrapObj.nextPageToken = String.valueOf(endIndex);
			} else if(String.isNotBlank(nextPageUrl) && endIndex < 2000) {
				filePageWrapObj.nextPageToken = '0';
				filePageWrapObj.nextPageUrl = nextPageUrl;
			} else {
				filePageWrapObj.nextPageToken = null;
			}
		} else {
			filePageWrapObj.objectList = listToBeReturned;
		}
		
    	return filePageWrapObj;
	}

}