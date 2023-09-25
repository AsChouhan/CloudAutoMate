public with sharing class FileContentProvider {
	
	private static final String FILE_TYPE_INTRANET = 'Intranet';
	private static final String FILE_TYPE_CRM = 'CRM';
	private static final String FILE_TYPE_BOX = 'Box';
	private static final String SFDC_REST_API_CHATTER_FILE = '/services/data/v35.0/chatter/files/';
	private static final String CONTENT_DISTRIBUTION_IDENTIFIER_STRING = 'D6irslCD__';
	
	
    public static List<FileListingWrapper> getMyFilesIntranetFiles(Criteria.File fileCriteriaObjArg, Integer recordLimit) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	
    	String ownedById = null;
    	if('owned_by_me'.equalsIgnoreCase(fileCriteriaObjArg.owner)) {
    		ownedById = UserContext.userId;
    	}
    	
    	FileDao fileDaoObj = new FileDao();
    	listOfContentDoc = fileDaoObj.getMyFilesIntranetFiles(fileCriteriaObjArg, ownedById, recordLimit);
    	if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.myFileToWrapper(contentDocObj);
    			fileWrapObj.context = FILE_TYPE_INTRANET;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(listOfContentDocumentIds, FILE_TYPE_INTRANET);
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isFavorited = setOfBookmarks.contains(fileWrapObj.id);
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    	}
    	
    	return listOfFileWrapper;
    }
    
    public static List<FileListingWrapper> getMyFilesCRMLibFiles(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	
    	String ownedById = null;
    	if('owned_by_me'.equalsIgnoreCase(fileCriteriaObjArg.owner)) {
    		ownedById = UserContext.userId;
    	}
    	
    	FileDao fileDaoObj = new FileDao();
    	listOfContentDoc = fileDaoObj.getMyFilesCRMLibFiles(fileCriteriaObjArg, ownedById);
    	if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.myFileToWrapper(contentDocObj);
    			fileWrapObj.context = FILE_TYPE_CRM;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(listOfContentDocumentIds, FILE_TYPE_CRM);
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isFavorited = setOfBookmarks.contains(fileWrapObj.id);
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    	}
    	
    	return listOfFileWrapper;
    }

	public static List<FileListingWrapper> getMyFilesBookmarkedFiles(List<String> fileIds) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
		List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	FileDao fileDaoObj = new FileDao();
		listOfContentDoc = fileDaoObj.getMyFilesBookmarkedFiles(fileIds);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		Set<Id> setOfContentDocumentIds = new Set<Id>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.myFileToWrapper(contentDocObj);
    			fileWrapObj.isFavorited = true;
    			fileWrapObj.context = FILE_TYPE_INTRANET;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    			setOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    		
    		// Get list of Site these files belongs to..
    		Map<Id,List<SiteLiteWrapper>> mapOfsiteDetailsWRTFile = new Map<Id,List<SiteLiteWrapper>>();
	    	mapOfsiteDetailsWRTFile = fileDaoObj.getCDRelatedSites(setOfContentDocumentIds, 'intranet');
	    	
	    	for(FileListingWrapper fLWItem :listOfFileWrapper) {
	    		fLWItem.listOfSite = mapOfsiteDetailsWRTFile.get(fLWItem.ContentDocumentId);
	    	}
    	
    	}
    	return listOfFileWrapper;
	}
    
    public static List<FileListingWrapper> getMyFilesBookmarkedFiles(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	FileDao fileDaoObj = new FileDao();
    	listOfContentDoc = fileDaoObj.getMyFilesBookmarkedFiles(fileCriteriaObjArg);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		Set<Id> setOfContentDocumentIds = new Set<Id>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.myFileToWrapper(contentDocObj);
    			fileWrapObj.isFavorited = true;
    			fileWrapObj.context = FILE_TYPE_INTRANET;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    			setOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    		
    		// Get list of Site these files belongs to..
    		Map<Id,List<SiteLiteWrapper>> mapOfsiteDetailsWRTFile = new Map<Id,List<SiteLiteWrapper>>();
	    	mapOfsiteDetailsWRTFile = fileDaoObj.getCDRelatedSites(setOfContentDocumentIds, 'intranet');
	    	
	    	for(FileListingWrapper fLWItem :listOfFileWrapper) {
	    		fLWItem.listOfSite = mapOfsiteDetailsWRTFile.get(fLWItem.ContentDocumentId);
	    	}
    	
    	}
    	return listOfFileWrapper;
	}

	public static List<FileListingWrapper> getBookmarkedNativeVideoFiles(List<String> externalFileIds) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
		FileDao fileDaoObj = new FileDao();
    	List<File__c> fileList = fileDaoObj.getBookmarkedNativeVideoFiles(externalFileIds);
		if (!fileList.isEmpty()) {
			
			List<String> externalIdList = new List<String>();
			map<String,File__c> mapOfFile = new map<String,File__c>();
			for (File__c fileObj : fileList) {
				mapOfFile.put(fileObj.External_Id__c,fileObj);
			}
			for (String extId : mapOfFile.keyset()) {
					FileListingWrapper fileWrapObj = new FileListingWrapper();	
					fileWrapObj = ObjectToWrapperAdapter.videoToWrapper(mapOfFile.get(extId));
					fileWrapObj.isFavorited = true;	
					listOfFileWrapper.add(fileWrapObj);
					externalIdList.add(extId);						
			}
			Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(externalIdList);
			for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
				fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
			}
		}
		return listOfFileWrapper;
	}
	
	public static List<FileListingWrapper> getBookmarkedNativeVideoFiles(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	Integer recordLimit = fileCriteriaObjArg.size + 1;
    	FileDao fileDaoObj = new FileDao();
    	List<File__c> fileList = fileDaoObj.getBookmarkedVideoFiles(fileCriteriaObjArg.term, fileCriteriaObjArg.offset,
    			recordLimit, fileCriteriaObjArg.filter, fileCriteriaObjArg.siteId, fileCriteriaObjArg.sortBy);
    	
				if (!fileList.isEmpty()) {
					List<String> externalIdList = new List<String>();
					map<String,File__c> mapOfFile = new map<String,File__c>();
					for (File__c fileObj : fileList) {
						mapOfFile.put(fileObj.External_Id__c,fileObj);
					}
					for (String extId : mapOfFile.keyset()) {
						
							FileListingWrapper fileWrapObj = new FileListingWrapper();
							
							fileWrapObj = ObjectToWrapperAdapter.videoToWrapper(mapOfFile.get(extId));
							fileWrapObj.isFavorited = true;
							
							listOfFileWrapper.add(fileWrapObj);
							externalIdList.add(extId);
							
							
					}
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(externalIdList);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    	}
    	return listOfFileWrapper;
    }
	
    public static List<FileListingWrapper> getFavoriteFiles(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	Integer recordLimit = fileCriteriaObjArg.size + 1;
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	FileDao fileDaoObj = new FileDao();
    	listOfContentDoc = fileDaoObj.getBookmarkedFiles(fileCriteriaObjArg.term, fileCriteriaObjArg.offset,
    			recordLimit, fileCriteriaObjArg.filter, fileCriteriaObjArg.siteId, fileCriteriaObjArg.sortBy);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.myFileToWrapper(contentDocObj);
    			fileWrapObj.isFavorited = true;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    	}
    	return listOfFileWrapper;
    }
    
    public static List<FileListingWrapper> getMyFilesFavoriteCRMFiles(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	FileDao fileDaoObj = new FileDao();
    	listOfContentDoc = fileDaoObj.getMyFilesFavoriteCRMFiles(fileCriteriaObjArg);
    	if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		Set<Id> setOfContentDocumentIds = new Set<Id>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.myFileToWrapper(contentDocObj);
    			fileWrapObj.isFavorited = true;
    			fileWrapObj.context = FILE_TYPE_CRM;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    			setOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    		
    		// Get list of Site these files belongs to..
    		Map<Id,List<SiteLiteWrapper>> mapOfsiteDetailsWRTFile = new Map<Id,List<SiteLiteWrapper>>();
	    	mapOfsiteDetailsWRTFile = fileDaoObj.getCDRelatedSites(setOfContentDocumentIds, 'crm');
	    	
	    	for(FileListingWrapper fLWItem :listOfFileWrapper) {
	    		fLWItem.listOfSite = mapOfsiteDetailsWRTFile.get(fLWItem.ContentDocumentId);
	    	}
    	}
    	return listOfFileWrapper;
    }
    
    public static List<FileListingWrapper> getSiteFilesAllFiles(Criteria.File fileCriteriaObjArg, Integer recordLimit) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	Boolean canRemove = true;
    	Boolean canDelete = true;
    	Boolean canMove = false;
    	Boolean isAlbum = false;
    	FileDao fileDaoObj = new FileDao();
    	List<File__c> fileDetails;
    	
    	String ownedById = null;
    	if('owned_by_me'.equalsIgnoreCase(fileCriteriaObjArg.owner)) {
    		ownedById = UserContext.userId;
    	}
    	
    	listOfContentDoc = fileDaoObj.getSiteFilesAllFiles(fileCriteriaObjArg,recordLimit, ownedById);
    	if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if(String.isBlank(fileCriteriaObjArg.directory)){
			// Root file case
			canMove = true;
    	} else {
    		if(String.isBlank(fileCriteriaObjArg.term)){
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', fileCriteriaObjArg.directory);
				String folderQuery = 'SELECT name__c, Is_System_Folder__c, Parent_Folder__r.name__c, Permissions__c, Parent_Folder__r.Is_System_Folder__c from Folder__c Where id =: soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		    	
		    	if(folderList.size() > 0){						
			    	if((ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.get('FEED_FILES')).equalsIgnoreCase(folderList[0].name__c) &&
			    			folderList[0].Is_System_Folder__c){
			    		canDelete = false;
			    		canRemove = false;
			    	} else if((ServiceConstants.DEFAULT_SITE_SYSTEM_SUB_FOLDERS_MAP.get('ALBUMS')).equalsIgnoreCase(folderList[0].Parent_Folder__r.name__c) &&
			    			folderList[0].Parent_Folder__r.Is_System_Folder__c){
			    		isAlbum = true;
			    	}
			    	
			    	if('readwrite'.equalsIgnoreCase(folderList[0].permissions__c)) {
			    		canMove = true;
			    	} else if(folderList[0].Is_System_Folder__c == false) {
			    		if(SiteContext.isCurrentUserSiteManager || (UserContext.isUserAppModerator && SiteContext.isPublicSite)) {
			    			canMove = true;
			    		}
			    	}
		    	}
    		}
    	}
    	
    	if (!listOfContentDoc.isEmpty()) {
    		Boolean isSitePrivate = null;
    		SiteDao siteDaoObj = new SiteDao();
	    	isSitePrivate = siteDaoObj.isSitePrivate(fileCriteriaObjArg.siteId);
	    	
	    	Set<Id> siteManagersIdsSet = siteDaoObj.getSiteManagerIdsSet(fileCriteriaObjArg.siteId);
	    	Set<Id> appManagersIdsSet = Utility.getAppModeratorsList();
	    	
    		List<String> listOfContentDocumentIds = new List<String>();
    		
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			canDelete = (UserContext.userId.equalsIgnoreCase(contentDocObj.OwnerId)) ? true : false;
    			canRemove = canLoggedInUserRemoveFile(contentDocObj, fileCriteriaObjArg.siteId, isSitePrivate, appManagersIdsSet, siteManagersIdsSet);
    			
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			if(isAlbum){
    				fileWrapObj = ObjectToWrapperAdapter.siteFileToWrapper(contentDocObj, fileCriteriaObjArg.siteId, false, false, false);
    			}else{
    				fileWrapObj = ObjectToWrapperAdapter.siteFileToWrapper(contentDocObj, fileCriteriaObjArg.siteId, canRemove, canDelete, canMove);
       			}
    			fileWrapObj.context = FILE_TYPE_INTRANET;
    			fileWrapObj.provider = fileCriteriaObjArg.provider;
    			fileWrapObj.location = fileWrapObj.provider;
    			fileWrapObj.name = fileWrapObj.title;
    			fileWrapObj.canDownload = true;
    			fileWrapObj.url += '&provider=' + fileCriteriaObjArg.provider;
    			
    			if(String.isNotBlank(fileCriteriaObjArg.directory)) {
    				fileWrapObj.url += '&directory=' + fileCriteriaObjArg.directory;
    			}
    			
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(listOfContentDocumentIds,fileCriteriaObjArg.provider);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    			fileWrapObj.isFavorited = setOfBookmarks.contains(fileWrapObj.id);
    		}
    		
    	}
    	return listOfFileWrapper;
    }
    
    private static Boolean canLoggedInUserRemoveFile(ContentDocument cdObject, String siteId, Boolean isSitePrivate, Set<Id> appManagersIdsSet, Set<Id> siteManagersIdsSet) {
    	Boolean canRemove = false;
    	String loggedInUserId = UserContext.userId;
    	
    	if(siteManagersIdsSet.contains(loggedInUserId)  || (isSitePrivate == false && appManagersIdsSet.contains(loggedInUserId))) {
    		canRemove = true;
    	}
    	
    	return canRemove;
    }

    public static FileListingWrapper createChatterFolder(String folderName, String parentFolderId, String siteId, String permissions) {
    	FileListingWrapper wrapperObj = null;
    	String folderPath;
    	String folderId = null;
    	FolderDao folderDaoObj = new FolderDao();
		Boolean isRootFolder = true; 
		String parentFolderType;   	
    	if(folderDaoObj.isDuplicateFolder(siteId, folderId, folderName, parentFolderId)) {
    		throw new SimpplrException(ServiceConstants.FOLDER_DUPLICATE_NAME_ERROR_MESSAGE);
    	} else {
	    	if(String.isNotBlank(parentFolderId)) {
	    		isRootFolder = false;
	    		List<Folder__c> listOfFolders = folderDaoObj.getFoldersById(new List<String>{parentFolderId});
	    		if(!listOfFolders.isEmpty()) {
					Folder__c parentFolderObj = listOfFolders[0];
					parentFolderType = parentFolderObj.Type__c;
	    			if(String.isNotBlank(parentFolderObj.path__c)) {
	    				folderPath = parentFolderObj.path__c + ',' +  parentFolderId;
	    			} else {
	    				folderPath = parentFolderId;
	    			}
					permissions = parentFolderObj.Permissions__c;
					if('read'.equalsIgnoreCase(permissions) && 
						UserContext.sitesIManageIdSet.contains(siteId) == false && 
						UserContext.isUserAppModerator == false) {
						throw new SimpplrException(ServiceConstants.ERROR_403);	
					}
	    		} else {
					throw new SimpplrException(ServiceConstants.ERROR_403);	
				}
	    	} else if (SiteContext.canManage() == false) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(parentFolderType)) {
				Folder__c folderObj = new Folder__c(Name__c = folderName, Parent_Folder__c = parentFolderId, type__c=ServiceConstants.VIDEO_PROVIDER_NATIVE, 
													path__c = folderPath, Site__c = siteId, Permissions__c = 'read', People__c = UserContext.peopleId);
				folderObj = folderDaoObj.createChatterFolder(folderObj);
				wrapperObj = ObjectToWrapperAdapter.videoFolderToWrapper(folderObj);
				wrapperObj.owner.name = UserContext.peopleName;
			} else {
				Folder__c folderObj = new Folder__c(Name__c = folderName, Parent_Folder__c = parentFolderId, type__c='Intranet', path__c = folderPath,
													Site__c = siteId, Permissions__c = permissions, People__c = UserContext.peopleId);
				folderObj = folderDaoObj.createChatterFolder(folderObj);
				List<Folder__c> listOfFolderDetails = folderDaoObj.getIntranetFolderDetails(new List<String>{folderObj.id}).values();
				wrapperObj = ObjectToWrapperAdapter.folderToWrapper(listOfFolderDetails[0],null);
				wrapperObj.canChangeName = true;
				wrapperObj.canSetPermissions = isRootFolder;
			}
    	}
     	return wrapperObj;
    } 
    
     public static List<FileListingWrapper> getSiteAlbumDetailAllFiles(Criteria.File fileCriteriaObjArg) {
		List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	    	List<File__c> listOfFiles = new List<File__c>();
	    	FileDao fileDaoObj = new FileDao();
	    
		listOfFiles = fileDaoObj.getSiteAlbumDetailAllFiles(fileCriteriaObjArg.offset,
		    			fileCriteriaObjArg.size, fileCriteriaObjArg.id);
		    			
	    	if (!listOfFiles.isEmpty()) {
	    		for (File__c contentDocObj : listOfFiles) {
	    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
	    			fileWrapObj = ObjectToWrapperAdapter.fileToWrapper(contentDocObj);
	    			listOfFileWrapper.add(fileWrapObj);
	    		}
	    	}
	    	return listOfFileWrapper;
    }
    
    public static List<FileListingWrapper> getSiteChatterWriteFolders(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	
    	FolderDao folderDaoObj = new FolderDao();
    	List<Folder__c> listOfFolders = folderDaoObj.getSiteChatterWriteFolders(fileCriteriaObjArg.directory, fileCriteriaObjArg.term, 
    			fileCriteriaObjArg.filter, fileCriteriaObjArg.siteId, fileCriteriaObjArg.sortBy);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (Folder__c folderObj : listOfFolders) {
				userIds.add(folderObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}		
		FileListingWrapper fileWrapObj;     			
    	for(Folder__c folderObj : listOfFolders){
    		fileWrapObj = ObjectToWrapperAdapter.folderToWrapper(folderObj,null);
    		listOfFileWrapper.add(fileWrapObj);	
    	}
    	return 	listOfFileWrapper;	
    }
    
    public static List<FileListingWrapper> getSiteChatterFolders(Criteria.File fileCriteriaObjArg) {
		logger.logDebug('FileContentProvider.getSiteChatterFolders() --- '+fileCriteriaObjArg);
		List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	Integer recordLimit = fileCriteriaObjArg.size + 1;
    	FolderDao folderDaoObj = new FolderDao();
    	List<Simpplr_Content__c> listOfValidContents;
    	Set<String> validContentsSet = new Set<String>();
    	Boolean isAlbum = false;
    	Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter);
		
		List<Folder__c> listOfFolders = folderDaoObj.getSiteChatterFolders(fileCriteriaObjArg.directory, fileCriteriaObjArg.term, fileCriteriaObjArg.offset,
    			recordLimit, fileCriteriaObjArg.filter, fileCriteriaObjArg.siteId, fileCriteriaObjArg.sortBy, fileCriteriaObjArg.isMediaManager);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (Folder__c folderObj : listOfFolders) {
				userIds.add(folderObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileCriteriaObjArg.siteId);
		String folderQuery = 'Select id, name__c, Type__c, Path__c From Folder__c Where Site__c =:soqlParam1 and Is_System_Folder__c = true';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfSystemFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		logger.logDebug('FileContentProvider.getSiteChatterFolders() -listOfSystemFolders-- '+listOfSystemFolders.size());
		Map<Id,String> mapOfSystemFolders = new Map<Id,String>();
    	Boolean isUnlistedSite = SiteContext.isUnlistedSite;
    	for(Folder__c folder : listOfSystemFolders){
   			mapOfSystemFolders.put(folder.id, folder.name__c);
    	}
    	logger.logDebug('FileContentProvider.getSiteChatterFolders() -mapOfSystemFolders-- '+mapOfSystemFolders);
    	if(mapOfSystemFolders.containsKey(fileCriteriaObjArg.directory)){
    		if((ServiceConstants.DEFAULT_SITE_SYSTEM_SUB_FOLDERS_MAP.get('ALBUMS')).equalsIgnoreCase(mapOfSystemFolders.get(fileCriteriaObjArg.directory))){
    			isAlbum = true;
    			listOfValidContents = [Select id from Simpplr_Content__c Where Is_Deleted__c = false and Type__c = 'Album' and Site__c =:fileCriteriaObjArg.siteId
    									and Status__c not in ('PreDraft', 'Draft','Submitted','Rejected') WITH SECURITY_ENFORCED];
				for(Simpplr_Content__c content : listOfValidContents){
					validContentsSet.add(content.id);
				}    									
    		}
    	}
    	logger.logDebug('FileContentProvider.getSiteChatterFolders() -mapOfSystemFolders-- '+mapOfSystemFolders);
    	Boolean isFolderLoggedInUserAccessible;
		for (Folder__c folderObj : listOfFolders) {
			if(folderObj.Is_External_System_Folder__c && ((folderObj.Type__c).equalsIgnoreCase(SiteContext.fileStorageSource) == false)){
				continue;	
			}
			FileListingWrapper fileWrapObj = new FileListingWrapper();
			isFolderLoggedInUserAccessible = false;
			// Check if 'write_folders' filter is applied
			if(isWriteFolderFilter){
				// If the user is app or site manager
				if(UserContext.isUserAppModerator || SiteContext.isCurrentUserSiteManager){
					// And (Either folder or its parent is not system OR it is a system and is a Content Image system folder)
					if((!folderObj.Is_System_Folder__c && (folderObj.Parent_Folder__c == null || !folderObj.Parent_Folder__r.Is_System_Folder__c))) {
				 		isFolderLoggedInUserAccessible = true; 	
		 			}
				} else if('readwrite'.equalsIgnoreCase(folderObj.Permissions__c)){
					// Standard User and folder has 'readwrite' permissions
					isFolderLoggedInUserAccessible = true;
				}
			} else {
				// Add all the folders
				isFolderLoggedInUserAccessible = true;
			}
			
			// Skip the GDRIVE type non-system folders and any folder when not connected
			if((folderObj.Type__c == ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING && !folderObj.Is_System_Folder__c) || 
				(folderObj.Type__c == ServiceConstants.STORAGE_TYPE_GDRIVE_STRING && !folderObj.Is_System_Folder__c)) {
				isFolderLoggedInUserAccessible = false;
			}
			
			// If the integration is disabled hide the system folder
			if(EFSConstants.storageTypes.contains(folderObj.Type__c.toLowerCase())) {
				if(folderObj.Type__c.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_BOX_STRING)) {
					if(UserContext.isBoxConnected == false) {
						isFolderLoggedInUserAccessible = false;
					}
				} else {
					if(!SimpplrContext.integrations.containsKey(folderObj.Type__c.toLowerCase())|| SimpplrContext.integrations.get(folderObj.Type__c.toLowerCase()).Integration_Enabled__c == false) {
						isFolderLoggedInUserAccessible = false;
					}
				}
			}
			logger.logDebug('FileContentProvider.getSiteChatterFolders() 418 '+isFolderLoggedInUserAccessible);	
			if(isFolderLoggedInUserAccessible){
				if(isAlbum){
					if(!validContentsSet.isEmpty() && validContentsSet.contains(folderObj.External_Folder_Id__c)){
						fileWrapObj = ObjectToWrapperAdapter.folderToWrapper(folderObj,mapOfSystemFolders);
						fileWrapObj.canUnlink = false;
						fileWrapObj.canChangeName = false;
						listOfFileWrapper.add(fileWrapObj);
					}
				} else {
					fileWrapObj = ObjectToWrapperAdapter.folderToWrapper(folderObj,mapOfSystemFolders);
					listOfFileWrapper.add(fileWrapObj);
				}
			}
		}
		return listOfFileWrapper;
    }
    
    /**
	* 
	* Purpose:  [Adding video/s to open album by another user after the abbum is created and send notifications ]
	* Parameters:
	*      albumCriteriaObj -- [Explanation of the purpose of this parameter to the method.]
	*      
	* Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
	*/
	
	public static void submitMediaToAlbum (String albumId, List<ContentWrapper.MediaWrapper> mediaWrapperList) {
		FileDao fileDaoObj = new FileDao();
    	Map<String,Integer> albumMediaCountMap = fileDaoObj.submitMediaToAlbum(albumId, mediaWrapperList);
    	Integer videoCount = albumMediaCountMap.get('videoCount') != NULL ? albumMediaCountMap.get('videoCount') : 0;
    	Integer photoCount = albumMediaCountMap.get('photoCount') != NULL ? albumMediaCountMap.get('photoCount') : 0;
    	
    	// update count of video and photos in album
    	AlbumDao albumDaoObj = new AlbumDao();
    	Simpplr_Content__c albumObj = albumDaoObj.updateAlbumWithLatestCount(albumId, videoCount, photoCount);
    	
    	// send notfication for adding videos or photos
    	if (albumObj.Album_Allow_All_to_Upload__c) {
    		NotificationDispatcher.sendNotificationForAddInAlbum(albumObj, videoCount, photoCount);
    	}
	}
    
    public static FileListingWrapper addVideoToAlbum(Criteria.Album albumCriteriaObj) {
    	FileListingWrapper fileWrapperObj = new FileListingWrapper();
    	
    	File__c fileObj = new File__c();
    	FileDao fileDaoObj = new FileDao();
    	fileObj = fileDaoObj.addVideoToAlbum(albumCriteriaObj.videoUrl, albumCriteriaObj.id, albumCriteriaObj.videoId,
    			albumCriteriaObj.videoThumbsnailImg, albumCriteriaObj.videoTitle, albumCriteriaObj.videoProvider, albumCriteriaObj.size);
    			
    	
    	if (fileObj != null) {
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fileObj.id);
	    	String fileQuery = 'SELECT Title__c, Content_Name__c, Content_Document__c, Author__c,Author__r.name, Author__r.User__r.SmallPhotoUrl, Author__r.User__c,Location__c,Simpplr_Content__r.Album_Image_Count__c, '+
	    									' Simpplr_Content__r.Album_Video_Count__c, Content_Version__c, '+
	    									' External_Id__c, Is_Title_Image__c, Thumbnail_URL__c, name,Description__c, '+
	    									' Simpplr_Content__c, Url__c, MIME_Type__c, Likes__c,Video_Status__c,'+
	    									' Simpplr_Content__r.Album_Allow_All_to_Upload__c, Order__c,CreatedDate,'+
	    									' Author__r.Zoom_Id__c, Author__r.Skype_Id__c, Video_Provider__c'+
	    									' FROM File__c '+
											' WHERE id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			File__c fileObjWithMediaCount = ((List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap)).get(0);
    		fileWrapperObj = ObjectToWrapperAdapter.fileToWrapper(fileObjWithMediaCount);
    	}    	
    	return fileWrapperObj;
    }
    
    public static FileListingWrapper addPhotoToAlbum (Criteria.Album albumCriteriaObj) {
    	FileListingWrapper fileWrapperObj = new FileListingWrapper();
    	FileDao fileDaoObj = new FileDao();
		File__c fileObj = new File__c();
		String parentFolderId;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', albumCriteriaObj.Id);
		String folderQuery = 'Select id from Folder__c where Name__c=\'Images\' And Parent_Folder__r.External_Folder_Id__c =:soqlParam1 and Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		if(!folderList.isEmpty()) {
			parentFolderId = folderList[0].id;
		}
    	fileObj = fileDaoObj.addPhotoToAlbum(albumCriteriaObj.photoUrl, albumCriteriaObj.Id, 
    			albumCriteriaObj.fileDescription, albumCriteriaObj.fileContentDocId, 
    			albumCriteriaObj.fileContentVersionId, albumCriteriaObj.thumbsnailUrl, parentFolderId);
    	
    	if (fileObj != null) {
			soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', fileObj.id);
	    	String fileQuery = 'SELECT Title__c, Content_Name__c,Author__c,Author__r.name, Author__r.User__r.SmallPhotoUrl, Author__r.User__c,Location__c, Simpplr_Content__r.Album_Image_Count__c, '+
	    								' Simpplr_Content__r.Album_Video_Count__c, Content_Document__c, '+
	    								' Content_Version__c, Is_Title_Image__c, Thumbnail_URL__c,Video_Status__c,'+
	    								' Description__c, Likes__c,Simpplr_Content__c, Url__c, CreatedDate,'+
	    								' MIME_Type__c,Simpplr_Content__r.Album_Allow_All_to_Upload__c,Order__c,'+
	    								' Author__r.Zoom_Id__c, Author__r.Skype_Id__c'+
	    								' FROM File__c WHERE id=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			File__c fileObjWithMediaCount = ((List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap)).get(0);
    		fileWrapperObj = ObjectToWrapperAdapter.fileToWrapper(fileObjWithMediaCount);
    	}
    	
    	return fileWrapperObj;
    }
    
    public static List<FileListingWrapper> getSiteCRMLibraries(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	Integer recordLimit = fileCriteriaObjArg.size + 1;
    	FolderDao folderDaoObj = new FolderDao();
    	List<Folder__c> listOfFolders = folderDaoObj.getSiteCRMLibraries(fileCriteriaObjArg.offset,
    									recordLimit, fileCriteriaObjArg.siteId, fileCriteriaObjArg.sortBy);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (Folder__c folderObj : listOfFolders) {
				userIds.add(folderObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	
		for (Folder__c folderObj : listOfFolders) {
			FileListingWrapper  fileWrapObj = new FileListingWrapper();
			fileWrapObj = ObjectToWrapperAdapter.folderToWrapper(folderObj,null);
			listOfFileWrapper.add(fileWrapObj);
		}
    		
    	return listOfFileWrapper;
    }
    
    public static List<FileListingWrapper> getSiteCRMFilesInLibrary(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	Integer recordLimit = fileCriteriaObjArg.size + 1;
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	
    	String ownedById = null;
    	if('owned_by_me'.equalsIgnoreCase(fileCriteriaObjArg.owner)) {
    		ownedById = UserContext.userId;
    	}
    	
    	FileDao fileDaoObj = new FileDao();
    	listOfContentDoc = fileDaoObj.getSiteCRMFilesInLibrary(fileCriteriaObjArg.directory, fileCriteriaObjArg.offset,
    			fileCriteriaObjArg.filter, recordLimit, fileCriteriaObjArg.sortBy, ownedById);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.siteFileToWrapper(contentDocObj, fileCriteriaObjArg.siteId, false, false, false);
    			fileWrapObj.context = FILE_TYPE_CRM;
    			fileWrapObj.url += '&directory=' + fileCriteriaObjArg.directory;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(listOfContentDocumentIds, FILE_TYPE_CRM);
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isFavorited = setOfBookmarks.contains(fileWrapObj.id);
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    		
    	}
    	return listOfFileWrapper;
    }
    
    public static List<FileListingWrapper> searchSiteCRMFilesInAllLibraries(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	Integer recordLimit = fileCriteriaObjArg.size + 1;
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	FileDao fileDaoObj = new FileDao();
    	listOfContentDoc = fileDaoObj.searchSiteCRMFilesInAllLibraries(fileCriteriaObjArg);
		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.siteFileToWrapper(contentDocObj, fileCriteriaObjArg.siteId, false, false, false);
    			fileWrapObj.context = FILE_TYPE_CRM;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(listOfContentDocumentIds, FILE_TYPE_CRM);
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isFavorited = setOfBookmarks.contains(fileWrapObj.id);
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    		
    	}
    	return listOfFileWrapper;
    }
    
    public static List<FileListingWrapper> getSiteCRMBookmarkedFiles(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	FileDao fileDaoObj = new FileDao();
    	Integer recordLimit = fileCriteriaObjArg.size + 1;
    	listOfContentDoc = fileDaoObj.getSiteCRMBookmarkedFiles(fileCriteriaObjArg.directory, fileCriteriaObjArg.term, fileCriteriaObjArg.offset,
    			recordLimit, fileCriteriaObjArg.siteId, fileCriteriaObjArg.sortBy);

		if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		for (ContentDocument contentDocObj : listOfContentDoc) { 
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.siteFileToWrapper(contentDocObj, fileCriteriaObjArg.siteId, false, false, false);
    			fileWrapObj.isFavorited = true;
    			fileWrapObj.context = FILE_TYPE_CRM;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    	}
    	return listOfFileWrapper;
    }
    
    public static List<FileListingWrapper.ParentWrapper> getListOfParentsForChatterFolder(List<String> listOfFolderIds) {
    	List<FileListingWrapper.ParentWrapper> listOfParents = new List<FileListingWrapper.ParentWrapper>();
			FolderDao folderDaoObj = new FolderDao();
    	Map<Id, Folder__c> mapOfFolders = folderDaoObj.getIntranetFolderDetails(listOfFolderIds);
    	for(String folderId : listOfFolderIds) {
    		Folder__c folderDetails = mapOfFolders.get(folderId);
    		FileListingWrapper.ParentWrapper parentFolder = new FileListingWrapper.ParentWrapper();
				parentFolder.id = folderDetails.Id;
    		if(folderDetails.Is_System_Folder__c) {
					parentFolder.name = ObjectToWrapperAdapter.getSystemFolderName('intranet', folderDetails.Name__c);
    		} else {
    			parentFolder.name = folderDetails.name__c;
    		}
    		parentFolder.isSystemFolder = folderDetails.Is_System_Folder__c;
    		listOfParents.add(parentFolder);
    	}

    	return listOfParents;
    }
    
    public static FileListingWrapper.DirectoryWrapper getIntranetFolderDetails(String folderId) {
 		FileListingWrapper.DirectoryWrapper dirWrapObj = new FileListingWrapper.DirectoryWrapper();
 		FolderDao folderDaoObj = new FolderDao(); 
 		Folder__c folderObj = folderDaoObj.getIntranetFolderDetails(new List<String>{folderId}).get(folderId);
 		if(folderObj != null) {
 			dirWrapObj.id = folderObj.id;
 			if(folderObj.Is_System_Folder__c) {
				 dirWrapObj.name = ObjectToWrapperAdapter.getSystemFolderName('intranet', folderObj.Name__c);
			} else {
				dirWrapObj.name = folderObj.Name__c;
			}
			 //dirWrapObj.name = folderObj.Name__c;
 			dirWrapObj.path = folderObj.path__c;
 			if('read'.equalsIgnoreCase(folderObj.permissions__c)) {	 
	 			dirWrapObj.permissions = 'read';
	    	} else {
	    		dirWrapObj.permissions = 'readwrite';
	    	}
	    	dirWrapObj.isSystemDir = folderObj.Is_System_Folder__c;
			dirWrapObj.provider = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
 		}   
 		return dirWrapObj;	
    }
    
    public static FileListingWrapper.DirectoryWrapper getCRMFolderDetails(String folderId, String siteId) {
 		FileListingWrapper.DirectoryWrapper dirWrapObj = new FileListingWrapper.DirectoryWrapper();
 		FolderDao folderDaoObj = new FolderDao(); 
 		List<Folder__c> listOfFolderObj = folderDaoObj.getCRMFolderDetails(folderId, siteId);
 		if(!listOfFolderObj.isEmpty()) {
 			Folder__c folderObj = listOfFolderObj[0];
 			dirWrapObj.id = folderObj.id;
 			dirWrapObj.name = folderObj.Name__c;
 			dirWrapObj.permissions = folderObj.permissions__c;
			dirWrapObj.provider = ServiceConstants.STORAGE_TYPE_CRM_STRING;
 		}   
 		return dirWrapObj;	
    }
    
    public static List<FileDetailWrapper.ParentWrapper> getListOfParents(String siteId, String fileStorageSource, String directory, String fileId) {
    	FileDetailWrapper.ParentWrapper fileWrapperObj = new FileDetailWrapper.ParentWrapper();
		FolderDao folderDaoObj = new FolderDao();
		
		if(FILE_TYPE_CRM.equalsIgnoreCase(fileStorageSource)) {
			Folder__c folderObj = folderDaoObj.getSystemFoldersForSite(siteId, 'CRM Files')[0];
			fileWrapperObj.Name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.crm_files');
			fileWrapperObj.Id = folderObj.id;
		} else if(FILE_TYPE_BOX.equalsIgnoreCase(fileStorageSource)) {
			fileWrapperObj.Name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.box_files');
		} else {
			fileWrapperObj.Name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.site_files');
		}
    	if(String.isNotBlank(siteId) && FILE_TYPE_CRM.equalsIgnoreCase(fileStorageSource)) {
			fileWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files' + '#provider=' + fileStorageSource.toLowerCase() + '&directory=' + fileWrapperObj.Id;

		} else if(String.isNotBlank(siteId) && ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileStorageSource)) {
			fileWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files';

		}else if(String.isNotBlank(siteId)) {
			fileWrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files' + '#provider=' + fileStorageSource.toLowerCase();
			
    	} else {
    		fileWrapperObj.url = PageContext.getPageURL(Pages.MyFiles) + '#provider=' + fileStorageSource.toLowerCase();
    	}
    	List<FileDetailWrapper.ParentWrapper> listOfParents = new List<FileDetailWrapper.ParentWrapper>();
    	listOfParents.add(fileWrapperObj);
    	
		FileDetailWrapper.ParentWrapper wrapperObj = null;
    	if(FILE_TYPE_CRM.equalsIgnoreCase(fileStorageSource)) {
    		List<Folder__c> listOfFolders = folderDaoObj.getCRMFolderDetails(directory, siteId);
    		if(!listOfFolders.isEmpty()) {
    			wrapperObj = new FileDetailWrapper.ParentWrapper();
    			wrapperObj.Id = listOfFolders[0].External_Folder_Id__c;
    			wrapperObj.Name = listOfFolders[0].name__c;
    			wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files' + '#provider=' + fileStorageSource.toLowerCase() + '&directory=' + wrapperObj.Id;
    			listOfParents.add(wrapperObj);
    		}
    	} else if(FILE_TYPE_INTRANET.equalsIgnoreCase(fileStorageSource) && String.isNotBlank(directory)) {
    		Folder__c folderObj = folderDaoObj.getIntranetFolderDetails(new List<String>{directory}).get(directory);
 			if(folderObj != null) {
    			if(String.isNotBlank(folderObj.path__c)) {
    				List<String> listOfParentFolderIds = folderObj.path__c.split(',');
 					Map<Id, Folder__c> mapOfFolders = folderDaoObj.getIntranetFolderDetails(listOfParentFolderIds);
 					for(String folderId : listOfParentFolderIds) {
			    		Folder__c folderDetails = mapOfFolders.get(folderId);
			    		wrapperObj = new FileDetailWrapper.ParentWrapper();
						wrapperObj.id = folderDetails.Id;
			    		wrapperObj.name = folderDetails.name__c;
			    		wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files' + '#provider=' + fileStorageSource.toLowerCase() + '&directory=' + wrapperObj.Id;
			    		listOfParents.add(wrapperObj);
			    	}
    			}
 				wrapperObj = new FileDetailWrapper.ParentWrapper();
    			wrapperObj.Id = folderObj.Id;
					if(folderObj.Is_System_Folder__c) {
						wrapperObj.Name = ObjectToWrapperAdapter.getSystemFolderName('intranet', folderObj.name__c);
					} else {
    				wrapperObj.Name = folderObj.name__c;
					}
    			wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files' + '#provider=' + fileStorageSource.toLowerCase() + '&directory=' + wrapperObj.Id;
    			listOfParents.add(wrapperObj);
 			}
		
		
		}else if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileStorageSource) ) {
    		Folder__c folderObj = folderDaoObj.getVideoFolderDetails(new List<String>{directory}).get(directory);
 			if(folderObj != null) {
    			if(String.isNotBlank(folderObj.path__c)) {
    				List<String> listOfParentFolderIds = folderObj.path__c.split(',');
 					Map<Id, Folder__c> mapOfFolders = folderDaoObj.getVideoFolderDetails(listOfParentFolderIds);
 					for(String folderId : listOfParentFolderIds) {
			    		Folder__c folderDetails = mapOfFolders.get(folderId);
			    		wrapperObj = new FileDetailWrapper.ParentWrapper();
						wrapperObj.id = folderDetails.Id;
			    		wrapperObj.name = folderDetails.name__c;
			    		wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files' + '#provider=' + folderDetails.Type__c + '&directory=' + wrapperObj.Id;
			    		listOfParents.add(wrapperObj);
			    	}
    			}
 				wrapperObj = new FileDetailWrapper.ParentWrapper();
    			wrapperObj.Id = folderObj.Id;
					if(folderObj.Is_System_Folder__c) {
						wrapperObj.Name = ObjectToWrapperAdapter.getSystemFolderName('native_video', folderObj.name__c);
					} else {
    				wrapperObj.Name = folderObj.name__c;
					}
    			wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files' + '#provider=' + fileStorageSource.toLowerCase() + '&directory=' + wrapperObj.Id;
    			listOfParents.add(wrapperObj);
 			}
		}
		
    	return listOfParents;
    }
    
    public static List<FileVersionHistoryWrapper> getVersionHistory(String fileId) {
    	List<FileVersionHistoryWrapper> listOfFileVersionHistoryWrapper = new List<FileVersionHistoryWrapper>();
    	List<ContentVersion> listContentVersion = new FileDao().getVersionHistory(fileId);
		Set<String> userIds = new Set<String>();
		for (ContentVersion contentDocObj : listContentVersion) {
			userIds.add(contentDocObj.Owner.Id);
			userIds.add(contentDocObj.contentModifiedById);
			userIds.add(contentDocObj.LastModifiedBy.id);
		}
		PeopleDao.setPeopleNameMapByUserId(userIds);
    	for (ContentVersion contentVersionObj : listContentVersion) {
			FileVersionHistoryWrapper  versionHistoryWrapObj = new FileVersionHistoryWrapper();
			versionHistoryWrapObj = ObjectToWrapperAdapter.contentVersionToFileListingWrapper(contentVersionObj);
			listOfFileVersionHistoryWrapper.add(versionHistoryWrapObj);
		}
    	return listOfFileVersionHistoryWrapper;
    }
    
    public static String getPublicUrl(String fileId) {
    	String publicURL;
    	
    	String queryStr = 'SELECT LatestPublishedVersionId from ContentDocument where id = :fileId';
    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND LatestPublishedVersion.networkid = null';
    	}
    	
    	List<ContentDocument> listOfContentDocument = Database.query(queryStr);
    	
    	if(listOfContentDocument.size() > 0) {
    		String latestContentVersionId = listOfContentDocument[0].LatestPublishedVersionId;
    		publicURL = generatePublicUrl(new List<Id>{latestContentVersionId}).get(latestContentVersionId);
    	}
    	
    	return publicURL;
    }
    
    public static Map<Id, String> generateEmbedPublicUrl(List<Id> cvIdsList) {
    	Map<Id, String> mapOfPublicURLs = generatePublicUrl(cvIdsList);
    	Map<Id, String> mapOfEmbedPublicURLs = new Map<Id, String>();
    	for(Id key:mapOfPublicURLs.keySet()) {
    		if(String.isNotBlank(mapOfPublicURLs.get(key))) {
    			mapOfEmbedPublicURLs.put(key, converDistributionPublicUrlToImageURL(key, mapOfPublicURLs.get(key)));
    		}
    	}
    	return mapOfEmbedPublicURLs;
    }
    
    public static Map<Id, String> generatePublicUrl(List<Id> cvIdsList) {
    	Map<Id, String> cvIdNUrlMap = new Map<Id, String>();
    	
    	List<ContentDistribution> newDistributions = new List<ContentDistribution>();
    	List<ContentDistribution> listOfExistingDistribution = [SELECT Id, ContentVersionId, DistributionPublicUrl FROM ContentDistribution 
    														WHERE Name =:CONTENT_DISTRIBUTION_IDENTIFIER_STRING AND ContentVersionId IN :cvIdsList WITH SECURITY_ENFORCED];
    	
    	List<Id> existingCVIdsList = new List<Id>();
    	for(ContentDistribution cDObjExisting : listOfExistingDistribution) {
			cvIdNUrlMap.put(cDObjExisting.ContentVersionId, cDObjExisting.DistributionPublicUrl);
			existingCVIdsList.add(cDObjExisting.ContentVersionId);
    	}
    	if(cvIdsList.size() != existingCVIdsList.size()){
    		String queryStr = 'SELECT Id, Title FROM ContentVersion where Id IN :cvIdsList AND Id NOT IN :existingCVIdsList';
	    	
	    	if(SimpplrContext.isCommunitiesEnabled){
	    		queryStr += ' AND networkid = null';
	    	}
	    	
			List<ContentVersion> cvList = Database.query(queryStr);
			
	    	for(ContentVersion cvObject : cvList) {
	    		ContentDistribution cdObj = new ContentDistribution();
				cdObj.ContentVersionId = cvObject.Id;
				cdObj.Name = CONTENT_DISTRIBUTION_IDENTIFIER_STRING;
				cdObj.PreferencesAllowOriginalDownload = true;
				cdObj.PreferencesAllowPDFDownload  = false;
				cdObj.PreferencesAllowViewInBrowser  = false;
				cdObj.PreferencesExpires  = false;
				cdObj.PreferencesLinkLatestVersion = true;
				cdObj.PreferencesNotifyOnVisit = false;
				cdObj.PreferencesPasswordRequired = false;
				
				newDistributions.add(cdObj);
	    	}
	    	
	    	
	    	//insert new Distributions;
	    	if(!newDistributions.isEmpty()) {
	    		FileDao daoObj = new FileDao();
		    	daoObj.insertContentDistributionList(newDistributions);
	    	}
	    	
	    	List<ContentDistribution> listOfNewContentDistribution = [SELECT Id, ContentVersionId, DistributionPublicUrl FROM ContentDistribution 
	    														WHERE Name=:CONTENT_DISTRIBUTION_IDENTIFIER_STRING AND ContentVersionId IN :cvList WITH SECURITY_ENFORCED];
	    														
	    	for(ContentDistribution cdistObj : listOfNewContentDistribution) {
				cvIdNUrlMap.put(cdistObj.ContentVersionId, cdistObj.DistributionPublicUrl);
	    	}
    	}
    	return cvIdNUrlMap;
    }
    
    public static String converDistributionPublicUrlToImageURL(String contentVersionId, String distributionPublicUrl) {
    	String urlPart = distributionPublicUrl.substringAfter(UserInfo.getOrganizationId().mid(3,12));
    	String publicURL = SimpplrContext.salesforceHost + '/sfc/dist/version/renditionDownload?versionId=' + contentVersionId + '&d=' + urlPart + '&oid=' + UserInfo.getOrganizationId() + '&rendition=THUMB240BY180';
    	return publicURL;
    }
    
    public static Boolean canUserUploadNewVersion(String fileId) {
    	FileDao daoObj = new FileDao(); 
    	List<ContentDocumentLink> listOfContentDocumentLinks = daoObj.getContentDocumentLinks(fileId);
    	return ObjectToWrapperAdapter.checkUploadNewVersionPermission(listOfContentDocumentLinks);
    }
    
    public static List<FileListingWrapper> autoComplete(Criteria.File fileCriteriaObjArg) {
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
    	List<ContentDocument> listOfContentDoc = new List<ContentDocument>();
    	FileDao fileDaoObj = new FileDao();
    	listOfContentDoc = fileDaoObj.autoComplete(fileCriteriaObjArg.term, fileCriteriaObjArg.siteId);
    	if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {
			Set<String> userIds = new Set<String>();
			for (ContentDocument contentDocObj : listOfContentDoc) {
				userIds.add(contentDocObj.Owner.Id);
			}
			PeopleDao.setPeopleNameMapByUserId(userIds);
		}
    	if (!listOfContentDoc.isEmpty()) {
    		List<String> listOfContentDocumentIds = new List<String>();
    		for (ContentDocument contentDocObj : listOfContentDoc) {
    			FileListingWrapper  fileWrapObj = new FileListingWrapper();
    			fileWrapObj = ObjectToWrapperAdapter.myFileToWrapper(contentDocObj);
    			fileWrapObj.context = FILE_TYPE_INTRANET;
    			listOfFileWrapper.add(fileWrapObj);
    			listOfContentDocumentIds.add(contentDocObj.id);
    		}
    		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(listOfContentDocumentIds, FILE_TYPE_INTRANET);
    		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfContentDocumentIds);
    		for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
    			fileWrapObj.isFavorited = setOfBookmarks.contains(fileWrapObj.id);
    			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
    		}
    	}
    	
    	return listOfFileWrapper;
    }
    
    /**
		Method to create files entry in Files__c.obj after creating entry in FeedItem.obj    
    **/
    
    @future
    public static void insertSiteFile(String parentId, String contentVersionId){
    	String feedFileFolderName = ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.get('FEED_FILES');
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', parentId);
		soqlParamMap.put('soqlParam2', feedFileFolderName);
		String folderQuery = 'Select Id, Site__c from Folder__c where Site__r.Chatter_Group_Id__c = :soqlParam1 And Is_System_Folder__c = true And Name__c = :soqlParam2';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
    	File__c fileObj = new File__c();
    		
    	if(!folderList.isEmpty()){
    		String queryStr = 'select ContentDocumentId FROM ContentVersion where Id = :contentVersionId';
	    	
	    	if(SimpplrContext.isCommunitiesEnabled){
	    		queryStr += ' AND networkid = null';
	    	}
	    	
			List<ContentVersion> cvList = Database.query(queryStr);
    		If(cvList.size() > 0) {
    			 fileObj.Content_Document__c = cvList[0].ContentDocumentId;
    		}
    		
    		fileObj.Content_Version__c = contentVersionId;
    		fileObj.External_Id__c = null;
    		fileObj.Folder__c = folderList[0].Id;
    	} else {
    		List<Simpplr_content__c> simpplrContentList =  [SELECT Id, Site__c  
											FROM Simpplr_Content__c WHERE Id = :parentId WITH SECURITY_ENFORCED]; 
			
			if (!simpplrContentList.isEmpty()) {
				String siteId = simpplrContentList[0].Site__c;
				soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', siteId);
				soqlParamMap.put('soqlParam2', feedFileFolderName);
				folderQuery = 'Select Id from Folder__c where Site__c = :soqlParam1 And Is_System_Folder__c = true And Name__c = :soqlParam2';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				List<Folder__c> contentFolderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
				
				if(!contentFolderList.isEmpty()){
					String queryStr = 'select ContentDocumentId FROM ContentVersion where Id = :contentVersionId';
	    	
			    	if(SimpplrContext.isCommunitiesEnabled){
			    		queryStr += ' AND networkid = null';
			    	}
			    	
					List<ContentVersion> cvList = Database.query(queryStr);
		    		If(cvList.size() > 0) {
		    			 fileObj.Content_Document__c = cvList[0].ContentDocumentId;
		    		}
		    		
					fileObj.Content_Version__c = contentVersionId;
		    		fileObj.External_Id__c = parentId;
		    		fileObj.Folder__c = contentFolderList[0].Id;
				}
			}
    	}
    	
    	if(String.isNotBlank(fileObj.Folder__c)){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
	    	fileObj = (File__c)SIMPESAPI.accessController().insertAsUser(fileObj, new List<Schema.SObjectField>{
	    		File__c.Content_Version__c, File__c.External_Id__c,File__c.Folder__c});
    	}
    }
    
    public static Set<Id> getLinkedLibraryIds4Site(String siteId) {
    	SiteService serviceObj = new SiteService(); 
    	Set<Id> linkedIds = new Set<Id>();
    	
    	List<Folder__c> linkedLibs = serviceObj.fetchSiteCRMLibList(siteId);
    	
    	for(Folder__c folderObj : linkedLibs) {
    		linkedIds.add(folderObj.External_Folder_Id__c);
    	}
    	
    	return linkedIds;
	}
	
	public List<FileListingWrapper> getGoogleDriveLinkedFolderForASite(Criteria.File fileCriteriaObjArg){
		List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
		FolderDao folderDaoObj = new FolderDao();
		Integer recordLimit = fileCriteriaObjArg.size + 1;
		String ownedById = null;
		if(String.isNotBlank(fileCriteriaObjArg.owner) && 'owned_by_me'.equalsIgnoreCase(fileCriteriaObjArg.owner)) {
			ownedById = UserContext.id;
		}
		
		List<Folder__c> listOfFolders = folderDaoObj.getGoogleDriveLinkedFolderForASite(fileCriteriaObjArg.siteId, fileCriteriaObjArg.offset, recordLimit, fileCriteriaObjArg.sortBy, ownedById, fileCriteriaObjArg.filter);
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', fileCriteriaObjArg.siteId);
		soqlParamMap.put('soqlParam2', IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE);
		String folderQuery = 'Select id, name__c, Type__c, Path__c From Folder__c Where Site__c =:soqlParam1 AND type__c =:soqlParam2 AND Is_System_Folder__c = true AND Is_Deleted__c = false';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<Folder__c> listOfSystemFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
		
		Map<Id,String> mapOfSystemFolders = new Map<Id,String>();
    	for(Folder__c folder : listOfSystemFolders){
   			mapOfSystemFolders.put(folder.id, folder.name__c);
		}
		for (Folder__c folderObj : listOfFolders) {
			listOfFileWrapper.add(ObjectToWrapperAdapter.folderToWrapper(folderObj,mapOfSystemFolders));
		}
		return listOfFileWrapper;
	}

	public List<FileListingWrapper> getSitesWithFileStortage(Criteria.File fileCriteriaObjArg) {
		List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
		FolderDao folderDaoObj = new FolderDao();
		Integer recordLimit = fileCriteriaObjArg.size + 1;

		Integer offset = fileCriteriaObjArg.nextPageToken != null ? Integer.valueOf(fileCriteriaObjArg.nextPageToken) : 0;
		List<Folder__c> listOfFolders = folderDaoObj.getSitesWithFileStortage(fileCriteriaObjArg, recordLimit, offset);
		Set<String> userIds = new Set<String>();
		for (Folder__c folderObj : listOfFolders) {
			userIds.add(folderObj.Owner.Id);
		}
		PeopleDao.setPeopleNameMapByUserId(userIds);
		for (Folder__c folderObj : listOfFolders) {
			FileListingWrapper wrapperObj = new FileListingWrapper();
			wrapperObj.id = folderObj.Site__c;
			wrapperObj.name = folderObj.Site__r.Name;
			wrapperObj.title = wrapperObj.name;
			wrapperObj.provider = fileCriteriaObjArg.provider;
			wrapperObj.permissions = 'read';
			wrapperObj.isFolder = 1;
			wrapperObj.isDir = true;
			wrapperObj.type = 'Site';	
			wrapperObj.canDelete = false;
			wrapperObj.owner.id = folderObj.Owner.id;
			wrapperObj.owner.name = PeopleDao.mapUserIdToPeopleName.containsKey(folderObj.Owner.id) ? PeopleDao.mapUserIdToPeopleName.get(folderObj.Owner.id) : folderObj.Owner.name;
			wrapperObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + folderObj.Owner.id; 
			wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + folderObj.Site__c + '/files';
			
			if(folderObj.LastModifiedDate != NULL) {
				wrapperObj.modifiedAt = folderObj.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			}
			listOfFileWrapper.add(wrapperObj);
		}
		return listOfFileWrapper;
	}
	public String uploadImageToAWS(String fileName, String contentVersionId) {
		Http httpObj = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(SimpplrContext.salesforceHost + '/services/data/v42.0/sobjects/ContentVersion/' + contentVersionId + '/VersionData');
		req.setMethod('GET');
		req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
		req.setHeader('Content-Type', 'application/json');
		HttpResponse response = httpObj.send(req);

		String boundary = UserContext.peopleId + contentVersionId;
		String base64EncodeBody = EncodingUtil.base64Encode(response.getBodyAsBlob());
		Blob blobBody = getBlobBody(base64EncodeBody, fileName, boundary, contentVersionId);
		String endpoint = 'https://services.simpplr.com/upload/s3/app_asset_upload.php';
					
		req = new HttpRequest();
		req.setHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
		req.setHeader('Content-Length',String.valueof(blobBody.size()));
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		req.setTimeout(60000);
		req.setBodyAsBlob(blobBody);
		response = httpObj.send(req);

		Map<String, String> responseObj = (Map<String, String>)Json.deserialize(response.getBody(), Map<String,String>.class);
		String publicURL = responseObj.get('imageURL');
		logger.logDebug('FileContentProvider.uploadImageToAWS()----response----' + publicURL);
		return publicURL;
	}

	private Blob getBlobBody(String bodyEncoded, String fileName, String boundary, String contentVersionId){		

		// Repost of code  with fix for file corruption issue
		// Orignal code postings and explanations
		// http://enreeco.blogspot.in/2013/01/salesforce-apex-post-mutipartform-data.html
		// http://salesforce.stackexchange.com/questions/24108/post-multipart-without-base64-encoding-the-body
		String header = '--'+boundary+'\r\nContent-Disposition: form-data; name="rat"\r\n\r\n' + Utility.externalRequestAuthToken() + '\r\n' +
						'--'+boundary+'\r\nContent-Disposition: form-data; name="org_id"\r\n\r\n' + UserInfo.getOrganizationId() + '\r\n' +
						'--'+boundary+'\r\nContent-Disposition: form-data; name="folder_name"\r\n\r\nnewsletter' + '\r\n' +
						'--'+boundary+'\r\nContent-Disposition: form-data; name="content_version_id"\r\n\r\n' + contentVersionId + '\r\n' +
						'--'+boundary+'\r\nContent-Disposition: form-data; name="type"\r\n\r\nlogo' + '\r\n' +
						'--'+boundary+'\r\nContent-Disposition: form-data; name="image"; filename="'+fileName+'"\nContent-Type: application/octet-stream';

		String footer = '--'+boundary+'--';             
		String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
		while(headerEncoded.endsWith('=')) {
			header+=' ';
			headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
		}
	
		Blob bodyBlob = null;
		String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
	   	if(last4Bytes.endsWith('==')) {
			// The '==' sequence indicates that the last group contained only one 8 bit byte
			// 8 digit binary representation of CR is 00001101
			// 8 digit binary representation of LF is 00001010
			// Stitch them together and then from the right split them into 6 bit chunks
			// 0000110100001010 becomes 0000 110100 001010
			// Note the first 4 bits 0000 are identical to the padding used to encode the
			// second original 6 bit chunk, this is handy it means we can hard code the response in
			// The decimal values of 110100 001010 are 52 10
			// The base64 mapping values of 52 10 are 0 K
			// See http://en.wikipedia.org/wiki/Base64 for base64 mapping table
			// Therefore, we replace == with 0K
			// Note: if using \n\n instead of \r\n replace == with 'oK'
			last4Bytes = last4Bytes.substring(0,2) + '0K';
			bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
			// We have appended the \r\n to the Blob, so leave footer as it is.
			String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
			bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
		} else if(last4Bytes.endsWith('=')) {
			// '=' indicates that encoded data already contained two out of 3x 8 bit bytes
			// We replace final 8 bit byte with a CR e.g. \r
			// 8 digit binary representation of CR is 00001101
			// Ignore the first 2 bits of 00 001101 they have already been used up as padding
			// for the existing data.
			// The Decimal value of 001101 is 13
			// The base64 value of 13 is N
			// Therefore, we replace = with N
			// Note: if using \n instead of \r replace = with 'K'
			last4Bytes = last4Bytes.substring(0,3) + 'N';
			bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
			// We have appended the CR e.g. \r, still need to prepend the line feed to the footer
			footer = '\n' + footer;
			String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
			bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
		} else {
			// Prepend the CR LF to the footer
			footer = '\r\n' + footer;
			String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
			bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
		}
		return bodyBlob;
	}  

	public void updateThumbnailURL(List<File__c> fileList, Map<String, String> contentVersionPublicURLMap) {
		for(File__c fileObj : fileList) {
			if(contentVersionPublicURLMap.containsKey(fileObj.Content_Version__c)) {
				fileObj.thumbnail_url__c = contentVersionPublicURLMap.get(fileObj.Content_Version__c); 
			}
		}

		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{
														File__c.thumbnail_url__c
													});
	}

	public FileListingWrapper.DirectoryWrapper getVideoFolderDetails(String folderId) {
		FileListingWrapper.DirectoryWrapper dirWrapObj = new FileListingWrapper.DirectoryWrapper();
		Boolean isSiteVideosFolder = false;
		FolderDao folderDaoObj = new FolderDao(); 
		Folder__c folderObj = folderDaoObj.getVideoFolderDetails(new List<String>{folderId}).get(folderId);
		if(folderObj != null) {
			dirWrapObj.id = folderObj.id;
			if(folderObj.Is_System_Folder__c) {
				dirWrapObj.name = ObjectToWrapperAdapter.getSystemFolderName('native_video', folderObj.Name__c);
				isSiteVideosFolder = ServiceConstants.SITE_VIDEOS_SYSTEM_FOLDER.equalsIgnoreCase(folderObj.Name__c);
			} else {
				dirWrapObj.name = folderObj.Name__c;
			}
			dirWrapObj.canCreateFolder = isSiteVideosFolder || SiteContext.canManage();

			dirWrapObj.path = folderObj.path__c;
			if('read'.equalsIgnoreCase(folderObj.permissions__c)) {	 
				dirWrapObj.permissions = 'read';
		   } else {
			   dirWrapObj.permissions = 'readwrite';
		   }
			dirWrapObj.canCreateFolder = SiteContext.canManage() && (!folderObj.Is_System_Folder__c || isSiteVideosFolder);
		   	dirWrapObj.isSystemDir = folderObj.Is_System_Folder__c;
		   	dirWrapObj.provider = ServiceConstants.VIDEO_PROVIDER_NATIVE;
		}   
		return dirWrapObj;	
   }

	public List<FileListingWrapper> getSiteVideoFolders(Criteria.File fileCriteriaObjArg) {
		FolderDao daoObj = new FolderDao();
		List<Folder__c> folderList = daoObj.getSiteVideoFolders(fileCriteriaObjArg);
		List<FileListingWrapper> fileWrapperList = new List<FileListingWrapper>();
		for(Folder__c folderObj : folderList) {						
			fileWrapperList.add(ObjectToWrapperAdapter.videoFolderToWrapper(folderObj));
		}
		return fileWrapperList;
	}

	public FileListingWrapper addToFolder(String siteId, String directory, NativeVideoWrapper.Video mediaParams, NativeVideoWrapper.UploadResponse uploadVideoResponse) {
		File__c fileObj = new File__c();
		List<String> extensionPart = mediaParams.name.split('\\.');
		fileObj.Title__c = mediaParams.name;
		fileObj.size__c = uploadVideoResponse.fileSize !=null ? Decimal.valueOf(uploadVideoResponse.fileSize) : 0;
        fileObj.description__c = mediaParams.description;
        fileObj.site__c = siteId;
        fileObj.Folder__c = directory;
		fileObj.Repository__c = ServiceConstants.VIDEO_PROVIDER_NATIVE;
        fileObj.External_Id__c = mediaParams.id;
        fileObj.MIME_Type__c = extensionPart.get(extensionPart.size() - 1);
        fileObj.Author__c = UserContext.peopleId;
        fileObj.Video_Provider__c = ServiceConstants.VIDEO_PROVIDER_NATIVE;
        fileObj.Thumbnail_URL__c = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + mediaParams.id +'/width/550/height/480';

		fileObj.Video_Caption_Language__c = '';
		Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);

		if(captionLanguageId != null){
			fileObj.Video_Caption_Language__c = String.valueOf(captionLanguageId);
		}

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().insertAsUser(fileObj, new List<Schema.SObjectField>{
            File__c.Title__c,
            File__c.size__c,
            File__c.description__c,
            File__c.site__c,
            File__c.Folder__c,
            File__c.Repository__c,
            File__c.External_Id__c,
            File__c.MIME_Type__c,
            File__c.Author__c,
            File__c.Video_Provider__c,
            File__c.Thumbnail_URL__c,
			File__c.Video_Caption_Language__c
        });

		fileObj = FileDao.getFileRecordDetails(mediaParams.id);
		FileListingWrapper wrapperObj = ObjectToWrapperAdapter.videoToWrapper(fileObj);   
		wrapperObj.canMove = true;
		wrapperObj.canRemove = true;   

        return wrapperObj;
	}
	
	public List<FileListingWrapper> getSiteVideoFiles(Criteria.File fileCriteriaObjArg, Integer recordLimit) {
		FileDao fileDaoObj = new FileDao();
		List<File__c> fileList = fileDaoObj.getSiteVideoFiles(fileCriteriaObjArg, recordLimit);
		Map<String, File__c> externalIdToFileMap = new Map<String, File__c>();
		for(File__c fileObj : fileList) {
			externalIdToFileMap.put(fileObj.External_Id__c, fileObj);
		}
		List<FileListingWrapper> wrapperList = new List<FileListingWrapper>(); 
		List<String> videoFileIdList = new List<String>();
		String siteVideosFolderId = fileDaoObj.getSiteVideosFolderId(fileCriteriaObjArg.siteId);
		for(File__c fileObj : externalIdToFileMap.values()) {
			FileListingWrapper wrapperObj = ObjectToWrapperAdapter.videoToWrapper(fileObj); 
			if(String.isNotBlank(siteVideosFolderId) && 
				(siteVideosFolderId.equalsIgnoreCase(fileObj.Folder__c) || 
					(String.isNotBlank(fileObj.Folder__r.Path__c) && 
					fileObj.Folder__r.Path__c.startsWith(siteVideosFolderId))) &&
				(SiteContext.isCurrentUserSiteManager ||
				(UserContext.isUserAppModerator && SiteContext.isPublicSite))){
					wrapperObj.canMove = true;	
					wrapperObj.canRemove = true;	
			}
			videoFileIdList.add(fileObj.External_Id__c);
			wrapperList.add(wrapperObj);
		} 
		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(videoFileIdList);
		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(videoFileIdList, ServiceConstants.VIDEO_PROVIDER_NATIVE);
		for(FileListingWrapper fileWrapObj : wrapperList) {
			fileWrapObj.isLiked = setOfLikes.contains(fileWrapObj.id);
			fileWrapObj.isFavorited = setOfBookmarks.contains(fileWrapObj.id);
		}
		return wrapperList;
	}

	public static List<FileListingWrapper.ParentWrapper> getListOfParentsForVideoFolder(List<String> listOfFolderIds) {
    	List<FileListingWrapper.ParentWrapper> listOfParents = new List<FileListingWrapper.ParentWrapper>();
			FolderDao folderDaoObj = new FolderDao();
    	Map<Id, Folder__c> mapOfFolders = folderDaoObj.getVideoFolderDetails(listOfFolderIds);
    	for(String folderId : listOfFolderIds) {
    		Folder__c folderDetails = mapOfFolders.get(folderId);
    		FileListingWrapper.ParentWrapper parentFolder = new FileListingWrapper.ParentWrapper();
			parentFolder.id = folderDetails.Id;
    		if(folderDetails.Is_System_Folder__c) {
					parentFolder.name = ObjectToWrapperAdapter.getSystemFolderName('native_video', folderDetails.Name__c);
    		} else {
    			parentFolder.name = folderDetails.name__c;
    		}
			parentFolder.isSystemFolder = folderDetails.Is_System_Folder__c;
			parentFolder.provider = folderDetails.Type__c;
    		listOfParents.add(parentFolder);
    	}

    	return listOfParents;
    }
}