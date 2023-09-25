public with sharing class BoxContentProvider {
	
	
    public static FileListingWrapper createFolder(Criteria.Folder folderObjArg) {
    	FileListingWrapper fileListWrapObj = new FileListingWrapper();
    	String folderName =  folderObjArg.name;
    	if(folderName.containsAny('/\\')){
    		throw new SimpplrException(ServiceConstants.FOLDER_NAME_ERROR_MESSAGE);
    	}
    	BoxService service = new BoxService();
    	BoxWrapper.UserTokens userTokensObj = service.getUserTokens(false,UserContext.peopleId);
		if(userTokensObj!=null && !String.isBlank(userTokensObj.accessToken)){
			try {
				FolderDao folderDaoObj = new FolderDao(); 
				if(folderDaoObj.isSystemFolder(folderObjArg.siteId, folderObjArg.directory)) {
					folderObjArg.directory = '';
				}
				String parentBoxFolderId = String.isBlank(folderObjArg.directory) ? '0': folderObjArg.directory;
				Object result = service.createBoxFolder(parentBoxFolderId, folderObjArg.name, userTokensObj.accessToken);
				if(result instanceof BoxWrapper.createFolderWrapper){
					BoxWrapper.createFolderWrapper boxFolderObj = (BoxWrapper.createFolderWrapper)result;
					if(parentBoxFolderId.equalsIgnoreCase('0') && String.isNotBlank(folderObjArg.siteId)){
						String collaborationIdJson = '';
						if(String.isNotBlank(SimpplrContext.boxManagedPermission) && 'simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)) {
							List<Object> resultsFromCollaboration = createCollaboration(boxFolderObj.id,folderObjArg.siteId,folderObjArg.permissions,userTokensObj.accessToken);
							Map<String,String> mapOfCollaborationIds = new Map<String,String>();
							for(Object collaborationObj:resultsFromCollaboration) {
								if(collaborationObj instanceof BoxWrapper.BoxCollaboration) {
									BoxWrapper.BoxCollaboration collabObj = (BoxWrapper.BoxCollaboration)collaborationObj;
									mapOfCollaborationIds.put(collabObj.accessible_by.id, collabObj.id);
								}
							}
							collaborationIdJson = Utility.getJsonFormat(mapOfCollaborationIds);
						}
						service.linkFolder(boxFolderObj.id, boxFolderObj.name, null, folderObjArg.permissions, 
								folderObjArg.siteId, collaborationIdJson);
						fileListWrapObj.canUnlink = true;
						fileListWrapObj.canSetPermissions = String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : true;
						fileListWrapObj.rootDirectory = boxFolderObj.id;
					} else {
						fileListWrapObj.rootDirectory = String.isBlank(folderObjArg.rootDirectory) ? '0' : folderObjArg.rootDirectory;
					}
					fileListWrapObj.permissions = folderObjArg.permissions;
					fileListWrapObj.provider = 'box';
					fileListWrapObj.id = boxFolderObj.id;
					fileListWrapObj.isDir = true;
					fileListWrapObj.title = boxFolderObj.name;
					fileListWrapObj.type = 'Folder';
					if(boxFolderObj.modified_at != NULL) {
						fileListWrapObj.modifiedAt = boxFolderObj.modified_at.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
					}
					fileListWrapObj.modifiedAtDateTime = boxFolderObj.modified_at;
					fileListWrapObj.owner.Id = UserContext.peopleId;
					fileListWrapObj.owner.Name = UserContext.getCurrentUserInfo.Full_Name__c;
					fileListWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + UserContext.peopleId;
					fileListWrapObj.canChangeName = String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : true;
					
				}else if(result instanceof BoxWrapper.BoxErrorWrapper){
					BoxWrapper.BoxErrorWrapper errorResult = (BoxWrapper.BoxErrorWrapper)result;
					throw new SimpplrException(errorResult.message);
				}
				else{
					throw new SimpplrException(ServiceConstants.UNEXPECTED_ERROR);
				}
			} finally {
				service.updateUserTokensInDB(userTokensObj);
			}
		}else{
    		throw new SimpplrException(BoxConstants.BOX_CURRENT_USER_IS_NOT_CONNECTED);
    	}    	
    	return fileListWrapObj;
     }
     
     private static List<Object> createCollaboration(String folderId,String siteId,String permission,String accessToken){
    	
    	BoxService service = new BoxService();
    	List<Object> resultToReturn = new List<Object>();
    	if(!String.isBlank(folderId)){
			Set<String> groupTypeSet = new Set<String>{BoxConstants.BOX_ADMIN_GROUP_TYPE,BoxConstants.BOX_MEMBER_GROUP_TYPE};
			Map<String, Object> soqlParamMap = new  Map<String, Object>();
			soqlParamMap.put('soqlParam1', siteId);
			soqlParamMap.put('soqlParam2', groupTypeSet);
			String query  = 'SELECT Value__c,Chatter_Group_Id__c,Type__c ' 
								+ ' FROM Simpplr_Metadata__c '
								+ ' WHERE Simpplr_Site__c =:soqlParam1 '
								+ '	AND Type__c IN :soqlParam2 ' 
								+ '	order by LastModifiedDate ';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
			List<Simpplr_Metadata__c> listOfGroupsMetadata = (List<Simpplr_Metadata__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);	
			String boxAllComapnyGroupId = SimpplrContext.BoxAllCompanyGroupId;
			if(SiteContext.isPublicSite && String.isNotBLank(boxAllComapnyGroupId)){
				listOfGroupsMetadata.add(new Simpplr_Metadata__c(value__c = boxAllComapnyGroupId,Simpplr_Site__c =siteId,Type__c = BoxConstants.BOX_MEMBER_GROUP_TYPE ));
			}	
			Object result;
			BoxWrapper.BoxCollaborationCollection existingCollaborations;
			Boolean pullExistingCollaborations = true;
			for(Simpplr_Metadata__c groupMetaInfo : listOfGroupsMetadata){
				if(String.isNotBlank(groupMetaInfo.value__c)){
					String roleType = groupMetaInfo.Type__c.equalsIgnoreCase(BoxConstants.BOX_ADMIN_GROUP_TYPE) ?'editor':
												permission.equalsIgnoreCase('Read')? BoxConstants.BOX_READ_ONLY_PERMISSION:BoxConstants.BOX_READ_WRITE_PERMISSION;
					
					result =  service.addFolderIntoGroup(folderId, groupMetaInfo.value__c, roleType, accessToken);
					if(result instanceof BoxWrapper.BoxCollaboration){
						BoxWrapper.BoxCollaboration collabObj = (BoxWrapper.BoxCollaboration)result;
						resultToReturn.add(collabObj);
					} else if(result instanceof BoxWrapper.BoxErrorWrapper){
						BoxWrapper.BoxErrorWrapper errorObj = (BoxWrapper.BoxErrorWrapper)result;
						if(errorObj.status == 409) {
							if(pullExistingCollaborations) {
								pullExistingCollaborations = false;
								result = service.pullCollaborationsOnFolder(folderId, accessToken);
								if(result instanceof BoxWrapper.BoxCollaborationCollection) {
									existingCollaborations = (BoxWrapper.BoxCollaborationCollection)result;
								}
							}
							if(existingCollaborations != null && existingCollaborations.entries != null) {
								for(BoxWrapper.BoxCollaboration collabObj:existingCollaborations.entries) {
									if(groupMetaInfo.value__c.equalsIgnoreCase(collabObj.accessible_by.id)) {
										if(roleType.equalsIgnoreCase(collabObj.role)) {
											resultToReturn.add(collabObj);
										} else {
											result = service.updateCollaboration(collabObj.id, roleType, accessToken);
											resultToReturn.add(result);
										}
										break;
									}
								}
							}
						} else {
							resultToReturn.add(result);
						}
					} else{
						
						resultToReturn.add(ServiceConstants.UNEXPECTED_ERROR);
					}
				}
				
			}	
		}
		
		return resultToReturn;
	}
	
	public static List<FileListingWrapper> getSiteLinkedBoxFolders(Criteria.File fileObjArg) {
		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileObjArg.filter);
		List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
		Boolean canModifyFolderProperties = false;
		Simpplr_Site__c siteObj = UserContext.sitesIFollowMap.get(fileObjArg.siteId);
		if(siteObj != null) {
			String groupId = siteObj.Chatter_group_Id__c;
			String currentUserId = UserContext.id;
			List<CollaborationGroupMember> listOfCollaborationGroupMember = new List<CollaborationGroupMember>();
			String BASE_QUERY = 'Select CollaborationRole From CollaborationGroupMember where MemberId =:currentUserId And CollaborationGroupId =:groupId';
			if(SimpplrContext.isCommunitiesEnabled){
	    		BASE_QUERY = BASE_QUERY+' and CollaborationGroup.NetworkId = null';
	    	}
	    	listOfCollaborationGroupMember = Database.query(BASE_QUERY);
			BoxService serviceObj = new BoxService();
			canModifyFolderProperties = listOfCollaborationGroupMember[0].CollaborationRole == 'Admin' ? true : false;
			if(String.isNotBlank(SimpplrContext.boxManagedPermission) && 'simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)) {
    			serviceObj.addUserToBoxGroup(UserContext.boxUserId, fileObjArg.siteId, siteObj.Chatter_group_Id__c, listOfCollaborationGroupMember[0].CollaborationRole);
			}
		}
		FolderDao folderDaoObj = new FolderDao();
		List<Folder__c> listOfFolders = folderDaoObj.getSiteLinkedBoxFolders(fileObjArg.offset, fileObjArg.size + 1, fileObjArg.siteId, fileObjArg.sortBy);

		for (Folder__c folderObj : listOfFolders) {
			if((isWriteFolderFilter && ('readwrite'.equalsIgnoreCase(folderObj.Permissions__c) || canModifyFolderProperties)) || !isWriteFolderFilter){
				FileListingWrapper  fileWrapObj = new FileListingWrapper();
				fileWrapObj = ObjectToWrapperAdapter.folderToWrapper(folderObj,null);
				
				if(folderObj.People__c != null) {
		     		fileWrapObj.owner.id = folderObj.People__c;
					fileWrapObj.owner.name = folderObj.People__r.Full_Name__c;
					fileWrapObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + folderObj.People__c; 
		     	} else {
		     		fileWrapObj.owner.Name = folderObj.Linked_Folder_Owner__c;
		     	}
		     	
				fileWrapObj.rootDirectory = fileWrapObj.id;
				fileWrapObj.canUnlink = canModifyFolderProperties;
				if(String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)) {
					fileWrapObj.canChangeName = false;
					fileWrapObj.canSetPermissions = false;
					fileWrapObj.canDelete = false;

				} else {
					fileWrapObj.canChangeName = canModifyFolderProperties || 'readwrite'.equalsIgnoreCase(folderObj.Permissions__c);
					fileWrapObj.canSetPermissions = canModifyFolderProperties;
				}
				listOfFileWrapper.add(fileWrapObj);
			}
		}
    		
    	return listOfFileWrapper;
    }
	
	public static FileListingWrapper.BoxFolderContentsWrapper getContentsAssociatedToFolder(Criteria.File fileObjArg, String folderPermission) {
		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileObjArg.filter);
		BoxDao boxDaoObj = new BoxDao();
		FolderDao folderDaoObj = new FolderDao();
		String folderId = String.isBlank(fileObjArg.directory) ? '0' : fileObjArg.directory;
		String rootFolderId = String.isBlank(fileObjArg.rootDirectory) ? folderId : fileObjArg.rootDirectory;
		Integer offset = 'alphabetical'.equalsIgnoreCase(fileObjArg.sortBy) ? fileObjArg.offset : 0;
		Integer recordLimit = 'alphabetical'.equalsIgnoreCase(fileObjArg.sortBy) ? fileObjArg.size + 1 : 500;
		
		BoxWrapper.FolderFile folderFileObj = boxDaoObj.getContentsAssociatedToFolder(folderId, offset, recordLimit);
		FileListingWrapper.BoxFolderContentsWrapper boxFolderContents = new FileListingWrapper.BoxFolderContentsWrapper();
		if(folderFileObj.isAccessDenied == true) {
			FileListingWrapper.ParentWrapper parentWrapperObj = new FileListingWrapper.ParentWrapper(); 
			Folder__c folderObj = folderDaoObj.getSystemFoldersForSite(fileObjArg.siteId, EFSConstants.EFS_SYSTEM_FOLDERS_MAP.get('box'))[0];
			parentWrapperObj.id =  folderObj.id;
			parentWrapperObj.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.box_files');
			parentWrapperObj.canCreateBoxFolder = String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : UserContext.sitesIManageIdSet.contains(fileObjArg.siteId);
			parentWrapperObj.canLinkBoxFolder = UserContext.sitesIManageIdSet.contains(fileObjArg.siteId);
			boxFolderContents.listOfParents.add(parentWrapperObj);
			boxFolderContents.listOfFile = new List<FileListingWrapper>();
			boxFolderContents.isAccessDenied = true;
		} else {
			if(folderFileObj != null) {
				boxFolderContents.folderName = folderFileObj.name;
				boxFolderContents.canUpload = folderFileObj.permissions.can_upload;
				boxFolderContents.listOfParents = new List<FileListingWrapper.ParentWrapper>();
				if(String.isNotBlank(fileObjArg.siteId)) {
					FileListingWrapper.ParentWrapper parentWrapperObj = new FileListingWrapper.ParentWrapper(); 
					Folder__c folderObj = folderDaoObj.getSystemFoldersForSite(fileObjArg.siteId, EFSConstants.EFS_SYSTEM_FOLDERS_MAP.get('box'))[0];
					parentWrapperObj.id =  folderObj.id;
					parentWrapperObj.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.box_files');
					parentWrapperObj.canCreateBoxFolder =  String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : UserContext.sitesIManageIdSet.contains(fileObjArg.siteId);
					parentWrapperObj.canLinkBoxFolder = UserContext.sitesIManageIdSet.contains(fileObjArg.siteId);
					boxFolderContents.listOfParents.add(parentWrapperObj);
				} else if(String.isNotBlank(fileObjArg.directory)){
					FileListingWrapper.ParentWrapper parentWrapperObj = new FileListingWrapper.ParentWrapper(); 
					parentWrapperObj.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.box_files');
					parentWrapperObj.canCreateBoxFolder =  String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : true;
					boxFolderContents.listOfParents.add(parentWrapperObj);
				}
				
				boxFolderContents.listOfParents.addAll(toListOfParents(folderFileObj.path_collection.entries, rootFolderId));
				
				boxFolderContents.listOfFile = toFileListingWrapperList(folderFileObj.item_collection.entries, new Set<String>{rootFolderId}, fileObjArg.siteId,fileObjArg.sortBy, isWriteFolderFilter, folderPermission);
				folderDaoObj.setExternalFolderName(folderId, boxFolderContents.folderName, 'Box');
			}
			if(!('alphabetical'.equalsIgnoreCase(fileObjArg.sortBy))) {
				boxFolderContents.listOfFile.sort();
				boxFolderContents.listOfFile = getSelectedPageRecords(boxFolderContents.listOfFile, fileObjArg.offset, fileObjArg.size + 1);
			}
		}

		return boxFolderContents;
	}
	
	private static List<FileListingWrapper.ParentWrapper> toListOfParents(List<BoxWrapper.MiniFolderFile> listOfMiniBoxFolderFile, String rootFolderId) {
		List<FileListingWrapper.ParentWrapper> listOfParents = new List<FileListingWrapper.ParentWrapper>();
		Boolean rootFolderFound = false;
		for(BoxWrapper.MiniFolderFile miniFolderFileObj: listOfMiniBoxFolderFile) {
        	if(rootFolderFound || miniFolderFileObj.id.equalsIgnoreCase(rootFolderId)) {
        		rootFolderFound = true;
        		if(!'0'.equalsIgnoreCase(miniFolderFileObj.id)) {
	        		FileListingWrapper.ParentWrapper parentObj = new FileListingWrapper.ParentWrapper();
	        		parentObj.id = miniFolderFileObj.id;
	        		parentObj.name = Utility.chompString(miniFolderFileObj.name, 16);
	        		listOfParents.add(parentObj);
        		}
        	}
        }
		return listOfParents;
	}
	
	private static List<FileListingWrapper> toFileListingWrapperList(List<BoxWrapper.MiniFolderFile> listOfMiniBoxFolderFile, Set<String> setOfRootFolderIds, String siteId,String sortBy, Boolean isWriteFolderFilter, String folderPermission) {
		return toFileListingWrapperList(listOfMiniBoxFolderFile, setOfRootFolderIds, siteId, sortBy, isWriteFolderFilter, folderPermission, null);
	}
	
	private static List<FileListingWrapper> toFileListingWrapperList(List<BoxWrapper.MiniFolderFile> 
			listOfMiniBoxFolderFile, Set<String> setOfRootFolderIds, String siteId, String sortBy, 
			Boolean isWriteFolderFilter, String folderPermission, Map<String, 
			List<SiteLiteWrapper>> mapOfFolderIdAndLinkedSites) {
		List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper> ();
    	Map<string,People_Preference__c> mapOfBoxIdAndUserId = getMapOfBoxUserIdWithBoxAccount();
    	
    	FileListingWrapper fileListWrapObj;
    	List<String> listOfBoxFileIds = new List<String>();
    	for(BoxWrapper.MiniFolderFile miniFolderFileObj: listOfMiniBoxFolderFile) {
    		// Add only folders if 'isWriteFolderFilter' is TRUE, Otherwise Add all
    		if((isWriteFolderFilter && ('folder'.equalsIgnoreCase(miniFolderFileObj.type)) && miniFolderFileObj.permissions.can_upload) ||
    										!isWriteFolderFilter){
    			fileListWrapObj = new FileListingWrapper();
				fileListWrapObj.id = miniFolderFileObj.id; 
				fileListWrapObj.sortBy = sortBy;
				fileListWrapObj.fileId = miniFolderFileObj.id;
				fileListWrapObj.externalFileId = miniFolderFileObj.id;
				fileListWrapObj.context = 'box';
				fileListWrapObj.provider = ServiceConstants.STORAGE_TYPE_BOX_STRING;
				if(miniFolderFileObj.modified_at != NULL) {
					fileListWrapObj.modifiedAt = miniFolderFileObj.modified_at.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				}
				fileListWrapObj.modifiedAtDateTime = miniFolderFileObj.modified_at;
				if(miniFolderFileObj.created_at != NULL) {
					fileListWrapObj.createdAt = miniFolderFileObj.created_at.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
				}
				fileListWrapObj.createdAtDateTime = miniFolderFileObj.created_at;
				BoxWrapper.MiniBoxUser boxUserObj;
				if(miniFolderFileObj.modified_by != null) {
					boxUserObj = miniFolderFileObj.modified_by;
				} else {
					boxUserObj = miniFolderFileObj.created_by;
				}
				if(boxUserObj != null) {
					if(mapOfBoxIdAndUserId.containsKey(boxUserObj.id)) {
						People_Preference__c peoplePreferenceObj = mapOfBoxIdAndUserId.get(boxUserObj.id);
						fileListWrapObj.owner.Id = peoplePreferenceObj.People__c;
						fileListWrapObj.owner.Name = peoplePreferenceObj.People__r.Full_Name__c;
						fileListWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + peoplePreferenceObj.People__c;
					} else {
						fileListWrapObj.owner.Id = boxUserObj.id;
						fileListWrapObj.owner.Name = boxUserObj.name;
					}
				}
				if(String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)) {
					fileListWrapObj.canDelete = false;
					fileListWrapObj.canChangeName = false;
				} else {
					fileListWrapObj.canDelete = miniFolderFileObj.permissions.can_delete;
					fileListWrapObj.canChangeName = miniFolderFileObj.permissions.can_rename;
				}
				List<SiteLiteWrapper> linkedSitesList = new List<SiteLiteWrapper>();
				
				//Locate rootfolderId
				String rootFolderId;
				
				Set<Id> setOfAddedSites = new Set<Id>();
				if(setOfRootFolderIds.size() > 0) {
					for(BoxWrapper.MiniFolderFile parentFolder:miniFolderFileObj.path_collection.entries) {
						if(String.isBlank(rootFolderId) && setOfRootFolderIds.contains(parentFolder.id)) {
							rootFolderId = parentFolder.id;
						}
						if(mapOfFolderIdAndLinkedSites != null) {
							List<SiteLiteWrapper> boxFolderLinkedSites = mapOfFolderIdAndLinkedSites.get(parentFolder.id);
							if(boxFolderLinkedSites != null) {
								for(SiteLiteWrapper siteWrapperObj : boxFolderLinkedSites) {
									if(setOfAddedSites.contains(siteWrapperObj.siteId) == false) {
										linkedSitesList.add(siteWrapperObj);
										setOfAddedSites.add(siteWrapperObj.siteId);
									}
								}
							}
						}
						
					}
				}
				
				fileListWrapObj.listOfSite = linkedSitesList;
				
				if(miniFolderFileObj.type == 'folder'){
					fileListWrapObj.isFolder = 1;
					fileListWrapObj.isDir = true;
					fileListWrapObj.title = miniFolderFileObj.name;
					fileListWrapObj.type = 'Folder';
					fileListWrapObj.rootDirectory = rootFolderId;
					if(String.isNotBlank(folderPermission)) {
						fileListWrapObj.permissions = folderPermission;
					}else {
						fileListWrapObj.permissions = miniFolderFileObj.permissions.can_upload ? 'readwrite' : 'read';
					}
				} else{
					listOfBoxFileIds.add(miniFolderFileObj.id);
					
					fileListWrapObj.size = miniFolderFileObj.size;
					fileListWrapObj.isFolder = 0;
					fileListWrapObj.isDir = false;
					fileListWrapObj.context = 'Box';
					fileListWrapObj.provider = ServiceConstants.STORAGE_TYPE_BOX_STRING;
					fileListWrapObj.title = miniFolderFileObj.name;
					fileListWrapObj.fileExtension = fileListWrapObj.title.substring(fileListWrapObj.title.lastIndexOf('.')+1);
					fileListWrapObj.canMove = miniFolderFileObj.permissions.can_delete;
					fileListWrapObj.canDownload = true;
					fileListWrapObj.name = miniFolderFileObj.name;
					fileListWrapObj.type = Utility.getFileType(fileListWrapObj.title.substring(fileListWrapObj.title.lastIndexOf('.')+1).toUpperCase());
					Map<String, String> fileDetailParams = new Map<String, String>{'fileId' => fileListWrapObj.id, 'rootDirectory' => rootFolderId, 'provider' => 'box'};
					if(String.isNotBlank(siteId)) {
						fileDetailParams.put('siteId', siteId);
					}
					
					fileListWrapObj.url = PageContext.getPageURL(Pages.FileDetail, fileDetailParams);
					
					fileListWrapObj.canCreateNewVersion = miniFolderFileObj.permissions.can_upload;
					if(miniFolderFileObj.parent !=null) {
						fileListWrapObj.url += '&directory=' + miniFolderFileObj.parent.id;
						fileListWrapObj.boxUrl = 'https://app.box.com/files/0/f/' + miniFolderFileObj.parent.id + '/1/f_' + miniFolderFileObj.id;
						fileListWrapObj.externalUrl = fileListWrapObj.boxUrl;
					}
				}
				
				fileListWrapObj.location = 'Box';
				fileListWrapObj.isDownloadableOniOS = Utility.isDownloadableOniOS(fileListWrapObj.type, 'BOX');
				listOfFileWrapper.add(fileListWrapObj);
    		}
	    }
	    //Pull bookmark/like information from Bookmark/like object
	    if(!listOfBoxFileIds.isEmpty()) {
		    FileDao fileDaoObj = new FileDao();
		    Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(listOfBoxFileIds, 'Box');
		    Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(listOfBoxFileIds);
			for(FileListingWrapper fileWrapObj : listOfFileWrapper) {
				if(setOfBookmarks.contains(fileWrapObj.id)) {
					fileWrapObj.isFavorited = true;
				}
				if(setOfLikes.contains(fileWrapObj.id)) {
					fileWrapObj.isLiked = true;
				}	
			}
	    }
	    return listOfFileWrapper;
	}
	
	private static List<FileListingWrapper> getSelectedPageRecords(List<FileListingWrapper> listOfAllBoxRecords, Integer offset, Integer recordLimit) {
		List<FileListingWrapper> listOfSelectedPageRecords = new List<FileListingWrapper>();
		Integer totalRecordCount = listOfAllBoxRecords.size();
		if(totalRecordCount > offset) {
			for(Integer index = offset; index < totalRecordCount && index < offset + recordLimit; index++) {
				listOfSelectedPageRecords.add(listOfAllBoxRecords[index]);
			}
		}
		return listOfSelectedPageRecords;
	}
  	public static List<BoxWrapper.MiniFolderFile> getFolders(String folderId) {
  		BoxService service = new BoxService();
  		List<BoxWrapper.MiniFolderFile> listOfFolders = new List<BoxWrapper.MiniFolderFile>();
  		List<String> extraRequestingFieldsInRequest = new List<String>{'owned_by','created_by','name','permissions'};
		BoxWrapper.UserTokens userTokensObj = service.getUserTokens(false,UserContext.peopleId);
		if(String.isNotBlank(userTokensObj.accessToken)){
			try {
				Map<String,Object> paramMap = new Map<String,Object>{'fields' => extraRequestingFieldsInRequest};
				Object result = service.getFolderDetails(folderId,userTokensObj.accessToken,paramMap);
				if(result instanceof BoxWrapper.createFolderWrapper){
					BoxWrapper.CreateFolderWrapper resultWrapper = (BoxWrapper.createFolderWrapper)result;
					listOfFolders = getListOfLinkableFolders(resultWrapper.entries);
				}else if(result instanceof BoxWrapper.BoxErrorWrapper){
					BoxWrapper.BoxErrorWrapper errorResult = (BoxWrapper.BoxErrorWrapper)result;
					throw new SimpplrException(errorResult.message);
				}else{
					throw new SimpplrException(ExceptionCode.BOX_EXCEPTION_GET_FOLDER.name());
				}
			} finally {
				service.updateUserTokensInDB(userTokensObj);
			}
		}
  		return listOfFolders;
  	}
  	
  	private static List<BoxWrapper.MiniFolderFile> getListOfLinkableFolders(List<BoxWrapper.MiniFolderFile> listOfMiniBoxFolderFile) {
  		List<BoxWrapper.MiniFolderFile> listOfFolders = new List<BoxWrapper.MiniFolderFile>();
  		for(BoxWrapper.MiniFolderFile miniFolderFileObj: listOfMiniBoxFolderFile) { 
  			if('folder'.equalsIgnoreCase(miniFolderFileObj.type)) { 
  				logger.logDebug('### miniFolderFileObj ###'+ miniFolderFileObj);
	  			if(miniFolderFileObj.permissions.can_invite_collaborator != null 
	  					&& miniFolderFileObj.permissions.can_set_share_access != null
	  			   		&& miniFolderFileObj.permissions.can_invite_collaborator 
	  			   		&& miniFolderFileObj.permissions.can_set_share_access) {
	  			   		miniFolderFileObj.owner = miniFolderFileObj.owned_by;
	  				   //FilterAttributeWrapper wrapperObj = new FilterAttributeWrapper(miniFolderFileObj.id, miniFolderFileObj.name);
	  				   	listOfFolders.add(miniFolderFileObj);
	  			}
  			}
  		}
  		listOfFolders.sort();
  		return listOfFolders;
  	}
  	
  	public static FileListingWrapper linkFolder(Criteria.Folder folderObjArg) {
    	FileListingWrapper fileListWrapObj = new FileListingWrapper();
    	BoxService service = new BoxService();
    	BoxWrapper.UserTokens userTokensObj = service.getUserTokens(false,UserContext.peopleId);
		if(userTokensObj!=null && !String.isBlank(userTokensObj.accessToken)){
			try {
				String collaborationIdJson = '';
				if(String.isNotBlank(SimpplrContext.boxManagedPermission) && 'simpplr'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)) {		
					List<Object> resultsFromCollaboration = createCollaboration(folderObjArg.directory,folderObjArg.siteId,folderObjArg.permissions,userTokensObj.accessToken);
					Map<String,String> mapOfCollaborationIds = new Map<String,String>();
					for(Object collaborationObj:resultsFromCollaboration) {
						if(collaborationObj instanceof BoxWrapper.BoxCollaboration) {
							BoxWrapper.BoxCollaboration collabObj = (BoxWrapper.BoxCollaboration)collaborationObj;
							mapOfCollaborationIds.put(collabObj.accessible_by.id, collabObj.id);
						}
					}
					collaborationIdJson = Utility.getJsonFormat(mapOfCollaborationIds);
				}
				Folder__c folderObj = service.linkFolder(folderObjArg.directory, folderObjArg.name, 
						folderObjArg.owner, folderObjArg.permissions, folderObjArg.siteId, collaborationIdJson);
				List<Folder__c> listOfLinkedFolder = new FolderDao().getBoxFolderDetails(new List<String>{folderObj.External_Folder_Id__c}, folderObjArg.siteId);
				fileListWrapObj = ObjectToWrapperAdapter.folderToWrapper(listOfLinkedFolder[0],null);
				
				if(listOfLinkedFolder[0].People__c != null) {
		     		fileListWrapObj.owner.id = listOfLinkedFolder[0].People__c;
					fileListWrapObj.owner.name = listOfLinkedFolder[0].People__r.Full_Name__c;
					fileListWrapObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + listOfLinkedFolder[0].People__c; 
		     	} else {
		     		fileListWrapObj.owner.Name = listOfLinkedFolder[0].Linked_Folder_Owner__c;
		     	}
				fileListWrapObj.rootDirectory = folderObjArg.directory;
				fileListWrapObj.canUnlink = true;
				if(String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission)) {
					fileListWrapObj.canChangeName = false;
					fileListWrapObj.canSetPermissions = false;
					fileListWrapObj.canDelete = false;

				} else {
					fileListWrapObj.canChangeName = true;
					fileListWrapObj.canSetPermissions = true;
				}
			} finally {
				service.updateUserTokensInDB(userTokensObj);
			}
		}
		return fileListWrapObj;
  	}
  	
  	public static List<FileVersionHistoryWrapper> getVersionHistory(String fileId) {
  		BoxDao daoObj = new BoxDao();
  		BoxWrapper.BoxItemCollection boxItemCollectionsObj = daoObj.getFileVersionInformation(fileId);
  		List<FileVersionHistoryWrapper> fileVersionHistory = toFileVersionHistoryWrapper(boxItemCollectionsObj.entries);
  		return fileVersionHistory;
  	}
  	
  	public static void deleteFolder(String folderId) {
  		BoxDao daoObj = new BoxDao();
  		Boolean success = daoObj.deleteFolder(folderId);
  		if(success) {
        	daoObj.deleteBoxFolderInDB(folderId);
  		} 
  	}
  	
  	private static List<FileVersionHistoryWrapper> toFileVersionHistoryWrapper(List<BoxWrapper.MiniFolderFile> listOfMiniBoxFolderFile) {
  		List<FileVersionHistoryWrapper> listOfFileVersions = new List<FileVersionHistoryWrapper>();
  		Map<string,People_Preference__c> mapOfBoxIdAndUserId = getMapOfBoxUserIdWithBoxAccount();
  		FileVersionHistoryWrapper versionHistoryWrapperObj;
  		Integer versionNumner = listOfMiniBoxFolderFile.size();
  		for(BoxWrapper.MiniFolderFile miniFolderFileObj: listOfMiniBoxFolderFile) {    
			versionHistoryWrapperObj = new FileVersionHistoryWrapper();
			versionHistoryWrapperObj.versionId = miniFolderFileObj.id;
	    	versionHistoryWrapperObj.versionNumber = String.valueOf(versionNumner--);
	    	versionHistoryWrapperObj.createdAt = Utility.dateTimeToMomentJSDateTime(miniFolderFileObj.modified_at);
	    	BoxWrapper.MiniBoxUser boxUserObj;
			if(miniFolderFileObj.modified_by != null) {
				boxUserObj = miniFolderFileObj.modified_by;
			} else {
				boxUserObj = miniFolderFileObj.created_by;
			}
	    	if(mapOfBoxIdAndUserId.containsKey(boxUserObj.id)) {
				People_Preference__c peoplePreferenceObj = mapOfBoxIdAndUserId.get(boxUserObj.id);
				versionHistoryWrapperObj.user.Id = peoplePreferenceObj.People__c;
				versionHistoryWrapperObj.user.Name = peoplePreferenceObj.People__r.Full_Name__c;
				versionHistoryWrapperObj.user.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + peoplePreferenceObj.People__c;
			} else {
				versionHistoryWrapperObj.user.Id = boxUserObj.id;
				versionHistoryWrapperObj.user.Name = boxUserObj.name;
			}
			listOfFileVersions.add(versionHistoryWrapperObj);
  		}
  		return listOfFileVersions;
  	}
  	
  	public static void disconnectUser() {
  		BoxService boxServiceObj = new BoxService();
  		boxserviceObj.unlinkAllFolders4User(UserContext.peopleId);
    	boxserviceObj.clearBoxTokens(UserContext.peopleId);
    	boxserviceObj.removeBoxGroupMembershipIdsfromDB();
  	}
  	
  	public static void disconnectAdmin() {
  		BoxService boxServiceObj = new BoxService();
  		boxserviceObj.clearBoxTokens(null);
  		boxserviceObj.clearBoxAdminTokens();
    	boxserviceObj.unlinkAllFolders4User(null);
    	BatchRemoveBoxGroup job = new BatchRemoveBoxGroup('boxAdminDisconnect');
    	Database.executeBatch(job,200);
  	}
  	
  	private static Map<String,People_Preference__c> getMapOfBoxUserIdWithBoxAccount() {
    	Map<String,People_Preference__c> mapOfBoxIdAndUserId = new Map<string,People_Preference__c>();
		String query = 'select id, People__r.Full_Name__c, Box_User_Id__c, People__c,Box_Username__c from People_Preference__c where Box_User_Id__c!=null';
    	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<People_Preference__c> listOfPeoplePreferences = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, null);		
    	for(People_Preference__c preferenceObj : listOfPeoplePreferences){
    		mapOfBoxIdAndUserId.put(preferenceObj.Box_User_Id__c, preferenceObj);
    	}
    	return mapOfBoxIdAndUserId;
  	}
  	
  	public static FileDetailWrapper getBoxFileDetails(String fileId, String rootFolderId) {
  		FileDetailWrapper fileDetails = new FileDetailWrapper();
  		BoxDao daoObj = new BoxDao();
  		BoxWrapper.FolderFile boxFileDetails = daoObj.getBoxFileDetails(fileId);
  		if('error'.equalsIgnoreCase(boxFileDetails.type)){
  			throw new SimpplrException(BoxConstants.BOX_UNAUTHORIZED_USER);
  		} else {
  			fileDetails = toFileDetailWrapper(boxFileDetails);
	  		fileDetails.isBookmarked = checkIfFileBookmarked(fileId);
    		FileDetailWrapper.ParentWrapper rootFolderObj = new FileDetailWrapper.ParentWrapper();
    		
    		fileDetails.listOfSite = null;
    		FolderDao folderDaoObj = new FolderDao();
    		Map<String, List<SiteLiteWrapper>> boxFolderRelatedSitesMap = folderDaoObj.getBFRelatedSites(new Set<String>{rootFolderId});
    		Boolean isRootFolderUnlinked = true;
    		
    		if (boxFolderRelatedSitesMap != NULL && boxFolderRelatedSitesMap.containsKey(rootFolderId)) {
    			isRootFolderUnlinked = false;
    		}	
    		if(String.isBlank(SiteContext.siteId) || isRootFolderUnlinked) {
				try {
					fileDetails.listOfSite = boxFolderRelatedSitesMap.get(rootFolderId);
					FileDetailWrapper.ParentWrapper parentObj = new FileDetailWrapper.ParentWrapper();
		        	parentObj.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.location.not_available');
		        	fileDetails.listOfParents.add(parentObj);
				} catch (Exception e) {
					logger.logDebug('BoxContentProvider.getBoxFileDetails --------------- Exception.Id :: ' + e);
					// Exception in getting the site details
				}
    		} else {
	    		if(!'0'.equalsIgnoreCase(rootFolderId)) {
		    		rootFolderObj.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.box_files');
		    		rootFolderObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + SiteContext.siteId + '/files';
		    		fileDetails.listOfParents.add(rootFolderObj);
	    		}
	  			Boolean rootFolderFound = false;
				for(BoxWrapper.MiniFolderFile miniFolderFileObj: boxFileDetails.path_collection.entries) {
		        	if(rootFolderFound || miniFolderFileObj.id.equalsIgnoreCase(rootFolderId)) {
		        		FileDetailWrapper.ParentWrapper parentObj = new FileDetailWrapper.ParentWrapper();
		        		parentObj.id = miniFolderFileObj.id;
		        		parentObj.name = '0'.equalsIgnoreCase(miniFolderFileObj.id) ? LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.box_files') : Utility.chompString(miniFolderFileObj.name, 16);
	        			parentObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + SiteContext.siteId + '/files' + '#provider=box&directory=' + parentObj.id + '&rootDirectory=' + rootFolderId;
		        		fileDetails.listOfParents.add(parentObj);
		        		rootFolderFound = true;
		        	}
		        }
			}
  		}
  		
  		return fileDetails;
  	}
  	
  	private static FileDetailWrapper toFileDetailWrapper(BoxWrapper.FolderFile boxFileDetails) {
  		FileDetailWrapper fileDetails = new FileDetailWrapper();
  		Map<string,People_Preference__c> mapOfBoxIdAndUserId = getMapOfBoxUserIdWithBoxAccount();
  		fileDetails.canDelete = String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : boxFileDetails.permissions.can_delete;
  		fileDetails.id = boxFileDetails.id;
  		fileDetails.fileId = boxFileDetails.id;
  		fileDetails.context = ServiceConstants.STORAGE_TYPE_BOX_STRING;
  		fileDetails.provider = ServiceConstants.STORAGE_TYPE_BOX_STRING;
  		fileDetails.title = boxFileDetails.name;
  		fileDetails.fileType = fileDetails.title.substring(fileDetails.title.lastIndexOf('.')+1).toUpperCase();
  		fileDetails.type = fileDetails.fileType;
  		fileDetails.fileExtension = fileDetails.title.substring(fileDetails.title.lastIndexOf('.')+1);
  		fileDetails.fileSize = Utility.byteToHumanReadableFormate(boxFileDetails.size);
  		fileDetails.size = (Integer)boxFileDetails.size;
  		fileDetails.lastModifiedDate = boxFileDetails.modified_at.format(SimpplrContext.DATE_TIME_FORMAT);
  		fileDetails.modifiedAt = Utility.dateTimeToMomentJSDateTime(boxFileDetails.modified_at);
  		fileDetails.versionNumber = boxFileDetails.version_number;
  		fileDetails.description = boxFileDetails.description;
  		fileDetails.canCreateNewVersion = boxFileDetails.permissions.can_upload;
  		fileDetails.canCreatePublicShareLink = false;
  		if(String.isNotBlank(fileDetails.description)) {
  			fileDetails.htmlDescription = fileDetails.description.replace('\n','<br>');
  		}
  		if(boxFileDetails.expiring_embed_link != null) {
  			fileDetails.fileurl = boxFileDetails.expiring_embed_link.url;
  		}
  		BoxWrapper.MiniBoxUser boxUserObj;
  		if(boxFileDetails.modified_by != null) {
			boxUserObj = boxFileDetails.modified_by;
		} else {
			boxUserObj = boxFileDetails.created_by;
		}
    	if(mapOfBoxIdAndUserId.containsKey(boxUserObj.id)) {
			People_Preference__c peoplePreferenceObj = mapOfBoxIdAndUserId.get(boxUserObj.id);
			fileDetails.owner.Id = peoplePreferenceObj.People__c;
			fileDetails.owner.Name = peoplePreferenceObj.People__r.Full_Name__c;
			fileDetails.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + peoplePreferenceObj.People__c;
		} else {
			fileDetails.owner.Id = boxUserObj.id;
			fileDetails.owner.Name = boxUserObj.name;
		}
		
		fileDetails.isDownloadableOniOS = Utility.isDownloadableOniOS(fileDetails.fileType, 'BOX');
		
  		return fileDetails;
  	}
  	
  	public static Boolean deleteFile(String fileId, String eTag) {
  		BoxDao boxDaoObj = new BoxDao();
  		Boolean success = boxDaoObj.deleteFile(fileId, eTag);
  		return success;
  	}
  	public static List<FileListingWrapper> searchFiles(Criteria.File fileObjArg) {
  		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileObjArg.filter);
  		List<FileListingWrapper> listOfFile = new List<FileListingWrapper>();
  		Integer offset = 0;
		Integer recordLimit = 200;
		
		BoxDao boxDaoObj = new BoxDao();
		Set<String> setOfRootFolderIds = boxDaoObj.getRootFolderIdsForSearch(fileObjArg.siteId);
		if(setOfRootFolderIds.size() > 0) {
			BoxWrapper.BoxItemCollection itemCollections = boxDaoObj.searchBoxContents(setOfRootFolderIds, fileObjArg.term, offset, recordLimit, fileObjArg.fullText);
	  		
	  		Map<String, List<SiteLiteWrapper>> mapOfFolderIdAndLinkedSites = getMapOfFolderIdAndLinkedSites(itemCollections.entries);
	  		
	  		listOfFile = toFileListingWrapperList(itemCollections.entries, setOfRootFolderIds, fileObjArg.siteId,fileObjArg.sortBy, isWriteFolderFilter, null, mapOfFolderIdAndLinkedSites);
	  		if(fileObjArg.isGlobalSearchReq == false) {
		  		if(!('alphabetical'.equalsIgnoreCase(fileObjArg.sortBy))) {
		  			listOfFile.sort();
				}
				listOfFile = getSelectedPageRecords(listOfFile, fileObjArg.offset, fileObjArg.size + 1);
	  		}
		}
  		return listOfFile;
  	}
  	
  	private static Map<String, List<SiteLiteWrapper>> getMapOfFolderIdAndLinkedSites(List<BoxWrapper.MiniFolderFile> bFList) {
  		Map<String, List<SiteLiteWrapper>> mapOfFolderIdAndLinkedSite = new Map<String, List<SiteLiteWrapper>>();
	  	
  		Set<String> setOfAllPathFolderIds = new Set<String>();
  		
  		for(BoxWrapper.MiniFolderFile mff : bFList) {
	  		for(BoxWrapper.MiniFolderFile parentFolder : mff.path_collection.entries) {
	  			if(!'0'.equals(parentFolder.id)) {
	  				setOfAllPathFolderIds.add(parentFolder.id);
	  			}
	  		}
		}
		
		FolderDao folderObj = new FolderDao();
		
		try {
			FolderDao folderDaoObj = new FolderDao();
			mapOfFolderIdAndLinkedSite = folderDaoObj.getBFRelatedSites(setOfAllPathFolderIds);
		} catch (Exception e) {
			logger.logDebug('BoxContentProvider.getMapOfFolderIdAndLinkedSites --------------- Exception.Id :: ' + e);
			// Exception in getting the site details
		}
		
		return mapOfFolderIdAndLinkedSite;
  	}
  	
  	public static List<FileListingWrapper> autoComplete(Criteria.File fileObjArg) {
  		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileObjArg.filter);
  		List<FileListingWrapper> listOfFile = new List<FileListingWrapper>();
  		Integer offset = 0;
		Integer recordLimit = 200;
		
		BoxDao boxDaoObj = new BoxDao();
		Set<String> setOfRootFolderIds = boxDaoObj.getRootFolderIdsForSearch(fileObjArg.siteId);
		if(setOfRootFolderIds.size() > 0) {
			BoxWrapper.BoxItemCollection itemCollections = boxDaoObj.searchBoxContents(setOfRootFolderIds, fileObjArg.term, offset, recordLimit, fileObjArg.fullText);
	  		
	  		listOfFile = toFileListingWrapperList(itemCollections.entries, setOfRootFolderIds, fileObjArg.siteId,fileObjArg.sortBy, isWriteFolderFilter, null);
		}
  		return listOfFile;
  	}
  	
  	public static Boolean setFolderPermissions(String folderId, String permissions) {
		Boolean success = true;
		String boxPermissions=('read'.equalsIgnoreCase(permissions))?BoxConstants.BOX_READ_ONLY_PERMISSION:BoxConstants.BOX_READ_WRITE_PERMISSION;
		List<String> nonAdminBoxCollaborationIds=new List<String>();
		BoxService serviceObj = new BoxService();
		FolderDao folderDaoObj = new FolderDao();
		Map<String,String> mapOfCollaborationId = folderDaoObj.getboxCollaborationIdMap(folderId, SiteContext.siteId);
		if(SiteContext.isPublicSite) {
			if(String.isNotBlank(SimpplrContext.BoxAllCompanyGroupId)) {
				nonAdminBoxCollaborationIds.add(mapOfCollaborationId.get(SimpplrContext.BoxAllCompanyGroupId));
			}
		}
		String boxMemberGroupId=serviceObj.getBoxGroupIdFromDB(SiteContext.siteId, BoxConstants.BOX_MEMBER_GROUP_TYPE);
		if(String.isNotBlank(boxMemberGroupId)) {
			nonAdminBoxCollaborationIds.add(mapOfCollaborationId.get(boxMemberGroupId));
		}		
		
		BoxWrapper.UserTokens adminUserTokensObj = serviceObj.getBoxAdminUserTokens(false);
		try {
			for(String collabId: nonAdminBoxCollaborationIds){
				Object updateCollaborationResult= serviceObj.updateCollaboration(collabId,boxPermissions,adminUserTokensObj.accessToken);
				if(!(updateCollaborationResult instanceof BoxWrapper.BoxCollaboration)){
					success=false;
				}
			}
		} catch(Exception ex) {
			throw ex;
		} finally{
			serviceObj.updateAdminUserTokensInDB(adminUserTokensObj);
		}
		
		return success;
  	}
  	
  	public static Boolean checkIfFileBookmarked(String fileId) {
  		FileDao fileDaoObj = new FileDao();
  		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(new List<String>{fileId}, 'Box');
  		return setOfBookmarks.contains(fileId);
  	}
  	
  	public static List<FileListingWrapper> getBookmarkedFiles(Criteria.File fileObjArg) {
  		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileObjArg.filter);
		List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
		BoxDao boxDaoObj = new BoxDao();
		Set<String> setOfRootFolderIds = boxDaoObj.getRootFolderIdsForSearch(fileObjArg.siteId);
		if(String.isBlank(fileObjArg.siteId) ||  
		  (String.isNotBlank(fileObjArg.siteId) && setOfRootFolderIds.size() > 0)) {
			Integer offset = 0;
			Integer recordLimit = 1000;
			
	  		List<BoxWrapper.MiniFolderFile> listOfMiniFolderFiles = boxDaoObj.getBookmarkedFiles(offset, recordLimit);
	  		if(String.isNotBlank(fileObjArg.siteId)) {
	  			listOfMiniFolderFiles = getListOfSiteFiles(listOfMiniFolderFiles, setOfRootFolderIds);
	  		}
	  		
	  		listOfFileWrapper = toFileListingWrapperList(listOfMiniFolderFiles, setOfRootFolderIds, fileObjArg.siteId,fileObjArg.sortBy, isWriteFolderFilter, null);
	  		if(!('alphabetical'.equalsIgnoreCase(fileObjArg.sortBy))) {
	  			listOfFileWrapper.sort();
			}
			listOfFileWrapper = getSelectedPageRecords(listOfFileWrapper, fileObjArg.offset, fileObjArg.size + 1);
	  }
  		return listOfFileWrapper;
  	}
  	
  	public static List<BoxWrapper.MiniFolderFile> getListOfSiteFiles(List<BoxWrapper.MiniFolderFile> listOfAllFiles, Set<String> setOfRootFolderIds) {
  		List<BoxWrapper.MiniFolderFile> listOfSiteFiles = new List<BoxWrapper.MiniFolderFile>();
  		for(BoxWrapper.MiniFolderFile miniFolderFileObj : listOfAllFiles) {
  			if('file'.equalsIgnoreCase(miniFolderFileObj.type)){
	  			if(miniFolderFileObj.parent != null && setOfRootFolderIds.contains(miniFolderFileObj.parent.id)) {
	  				listOfSiteFiles.add(miniFolderFileObj);
	  				continue;
	  			} 
  				if(miniFolderFileObj.path_collection != null && miniFolderFileObj.path_collection.entries !=null) {
	  				for(BoxWrapper.MiniFolderFile parentFolderFileObj: miniFolderFileObj.path_collection.entries) {
	  					if(setOfRootFolderIds.contains(parentFolderFileObj.id)) {
	  						listOfSiteFiles.add(miniFolderFileObj);
	  						break;
	  					}
	  				}
  				}
  			}
  		}	
  		return listOfSiteFiles;
  	}
  	
  	public static void resetCurrentUserBoxAccessToken() {
  		BoxDao daoObj = new BoxDao();
  		list<People_Preference__c> peoplePreference = [Select  Box_Username__c, Box_User_Id__c, people__c, Box_Access_Token__c, Box_Refresh_Token__c,
  						 Box_Access_Token_Expires_At__c, Box_Refresh_Token_Expires_At__c, Box_Enterprise_Id__c, Box_Favorite_Collection_Id__c  
  						 From People_Preference__c WHERE People__r.User__c=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
		
		// expecting People_Preference__c record so no need to add null or size check.
  		BoxWrapper.UserTokens userTokensObj = daoObj.refreshBoxToken(peoplePreference[0], false);
  		if(userTokensObj!=null && !String.isBlank(userTokensObj.accessToken)){
  			daoObj.updateUserTokensInDB(userTokensObj);
  		}
  	} 
  	
}