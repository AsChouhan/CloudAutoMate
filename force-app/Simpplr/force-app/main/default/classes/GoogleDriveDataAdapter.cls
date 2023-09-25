public with sharing class GoogleDriveDataAdapter {
    
    public String siteId{get;set;}
    public static Map<String, People_Integration__c> simpplrUserMap = null;

    public FileDetailWrapper convertToFileDetailWrapper(GoogleDriveModel.File fileObj){
        FileDetailWrapper fileDetailWrapObj = new FileDetailWrapper();
        fileDetailWrapObj.id = fileObj.id; 
        fileDetailWrapObj.name = fileObj.name;  
        fileDetailWrapObj.title = fileObj.name; 
        fileDetailWrapObj.fileSize = Utility.byteToHumanReadableFormate(fileObj.size); 
        fileDetailWrapObj.size = fileObj.size; 
        fileDetailWrapObj.description = fileObj.description;  
        fileDetailWrapObj.isBookmarked = fileObj.starred;
        fileDetailWrapObj.viewInGoogleDrive = fileObj.webViewLink;
        fileDetailWrapObj.context = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
        fileDetailWrapObj.provider = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
        fileDetailWrapObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(fileObj.modifiedTime);
        fileDetailWrapObj.lastModifiedDate = LocaleContext.getLocalisedDateAsMMMDDYYYYhhmmss(fileObj.modifiedTime, UserContext.languageLocaleKey);

        if (ApexPages.currentPage() != null || SimpplrContext.isRESTServiceContext == true) {
            fileDetailWrapObj.isDownloadableOniOS = Utility.isDownloadableOniOS(fileDetailWrapObj.fileType, 
                    ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
        }

        if (fileObj.name.indexOf('.') == -1) {
            fileDetailWrapObj.fileExtension = fileObj.mimeType.substringAfterLast('/').toUpperCase();
            
            if (!googleDriveDownloadSupported(fileDetailWrapObj.fileExtension)) {
                fileDetailWrapObj.canDownload = false;

            } else {

                fileDetailWrapObj.onlyPDFDownload = true;
                fileDetailWrapObj.canCreateNewVersion = false;
            }

        } else {
            fileDetailWrapObj.fileExtension = fileObj.name.substringAfterLast('.').toUpperCase();
        }

        fileDetailWrapObj.fileType = Utility.getFileType(fileDetailWrapObj.fileExtension);
        fileDetailWrapObj.type = fileDetailWrapObj.fileType;
        Set<String> setOfImageExtSupported = new Set<String>{'jpg', 'jpeg', 'png'};
        fileDetailWrapObj.isImage = setOfImageExtSupported.contains(fileDetailWrapObj.fileType.toLowerCase()); 
        fileDetailWrapObj.versionNumber = String.valueOf(fileObj.version);
        //fileDetailWrapObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(fileObj.getModifiedTime);
        fileDetailWrapObj.owner = new FileDetailWrapper.OwnerWrapper();
        
        if (fileObj.owners != null && !fileObj.owners.isEmpty()) {
            fileDetailWrapObj.owner.name = fileObj.owners[0].displayName;

            if (fileObj.owners[0].emailAddress!=null ){ 
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', fileObj.owners[0].emailAddress);
                String queryStr = 'SELECT id, People__c, People__r.Full_Name__c, User_Email__c, External_Id__c '+
                                                                    ' FROM People_Integration__c '+
                                                                    ' WHERE User_Email__c=:soqlParam1 '+
                                                                    ' AND name = \'googledrive\''+
                                                                    ' AND is_deleted__c=false';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<People_Integration__c> peopleIntegrationList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);                                  
                if (!peopleIntegrationList.isEmpty()) {
                    fileDetailWrapObj.owner.Id = peopleIntegrationList[0].People__c;
                    fileDetailWrapObj.owner.Name = peopleIntegrationList[0].People__r.Full_Name__c;
                    fileDetailWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ peopleIntegrationList[0].People__c;
                }
            }
        }
        	
        if (fileObj.capabilities != null) {
            fileDetailWrapObj.canChangeName = fileObj.capabilities.canRename;
            fileDetailWrapObj.canCreatePublicShareLink = fileObj.capabilities.canShare;
            fileDetailWrapObj.canCreateNewVersion = fileObj.capabilities.canEdit;
            fileDetailWrapObj.canDelete = false;

            if (fileObj.capabilities.canAddChildren) {	
                fileDetailWrapObj.permissions = 'readwrite';
            } else {
               fileDetailWrapObj.permissions = 'read';
           }

        }

        if (fileObj.parents != null && !fileObj.parents.isEmpty()) {
            List<FileDetailWrapper.ParentWrapper> listOfFileLocation = checkFileLocation(fileObj.parents[0]);

            if (!listOfFileLocation.isEmpty()) {
                fileDetailWrapObj.listOfParents.addAll(listOfFileLocation);

            } else {

                if (fileDetailWrapObj.listOfSite.size() == 0) {
                    FileDetailWrapper.ParentWrapper parentWrap = new FileDetailWrapper.ParentWrapper();
                    parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.location.not_available');
                    fileDetailWrapObj.listOfParents.add(parentWrap);
                }

            }

        }

        if (String.isBlank(this.siteId)) {
            fileDetailWrapObj.listOfSite = fetchSiteInfo(fileObj.permissions);
        }

        return fileDetailWrapObj; 
    }  

    private List<FileDetailWrapper.ParentWrapper> checkFileLocation(String parentId) {
        List<FileDetailWrapper.ParentWrapper> listOfFileLocation = new List<FileDetailWrapper.ParentWrapper>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', parentId);
        String folderQuery = 'SELECT id, site__c, External_folder_id__c, Site__r.Name FROM Folder__c WHERE External_folder_id__c=:soqlParam1 AND Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Folder__c> listOfFolder = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);

        for (Folder__c folderObj: listOfFolder) {
            FileDetailWrapper.ParentWrapper parentWrap = new FileDetailWrapper.ParentWrapper();
            parentWrap.id = folderObj.Site__c;
            parentWrap.name = folderObj.Site__r.Name;
            parentWrap.url = Pages.app +'?u=/site/' + parentWrap.id + '/files' + '#provider=' + ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
            listOfFileLocation.add(parentWrap);
        }
		
        return listOfFileLocation;
    }

    public static boolean googleDriveDownloadSupported(String filType) {
    	return ServiceConstants.GDRIVE_DOWNLOADABLE_TYPES.contains(filType);
    }

    public List<SiteLiteWrapper> fetchSiteInfo(List<GoogleDriveModel.Permission> listOfPermissions) {
        List<SiteLiteWrapper> sitesList = new List<SiteLiteWrapper>();
        Map<String, SiteLiteWrapper> permSitesMap = getGoogleSiteMap();

        if (listOfPermissions == null) { 
            return sitesList; 
        }
		 		
		SiteLiteWrapper siteInfo = null;
		
		//logger.logDebug(permSitesMap);
		Set<Id> uniqueSiteIds = new Set<Id>();
		
		for(GoogleDriveModel.Permission perm: listOfPermissions) {
            siteInfo = permSitesMap.get(perm.Id);
            
			if(siteInfo != null && uniqueSiteIds.add(siteinfo.siteId)) { 
				sitesList.add(siteinfo);  
            }	
            
		}
		
		return sitesList;
    }
    
    private Map<String, SiteLiteWrapper> getGoogleSiteMap() {
		Map<String, SiteLiteWrapper> foldMap = new Map<String, SiteLiteWrapper>();
		SiteLiteWrapper siteWrapper;
		String storage = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
        
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', storage);
        soqlParamMap.put('soqlParam2', ServiceConstants.PUBLIC_SITE);
        soqlParamMap.put('soqlParam3', UserContext.sitesIFollowIdSet);
        String folderQuery = 'Select id, Name__c, EFS_Read_Collaboration_Id__c, ' +
            ' EFS_Read_Write_Collaboration_Id__c, Path__c, Site__c,  ' +
            ' External_Folder_Id__c, Permissions__c, EFS_Shared_Folder_Id__c, EFS_Drive_Id__c,  ' +
            ' Site__r.Name, Site__r.Chatter_Group_Id__c, Site__r.Site_Type__c,  ' +
            ' Site__r.Is_Active__c, Site__r.Title_Content_Version__c   ' +
            ' FROM Folder__c  ' +
            ' WHERE Type__c = :soqlParam1 and Is_System_Folder__c = true and Is_Deleted__c = false  ' +
            ' AND (Site__r.Site_Type__c =: soqlParam2 OR Site__c IN: soqlParam3)  ' +
            ' AND Site__r.Is_Active__c = true AND Site__r.File_Storage_Source__c=: soqlParam1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        for(Folder__c fold: (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap)) {
			siteWrapper = new SiteLiteWrapper();
			siteWrapper.siteId = fold.Site__c;
			siteWrapper.name = fold.Site__r.Name;
			siteWrapper.chatterGroupId = fold.Site__r.Chatter_Group_Id__c;
			siteWrapper.access = fold.Site__r.Site_Type__c;
			siteWrapper.isActive = fold.Site__r.Is_Active__c;
			siteWrapper.url = Pages.app +'?u=/site/' + siteWrapper.siteId + '/files' + '#provider=' + storage;
            
            if (String.isNotBlank(fold.Site__r.Title_Content_Version__c)){
				siteWrapper.img = Utility.getFileDownloadURLFor720By480(fold.Site__r.Title_Content_Version__c);
	 			siteWrapper.imgThumbnail = Utility.getFileDownloadURLFor120BY90(fold.Site__r.Title_Content_Version__c);
			}
			
            siteWrapper.url += '&directory=' + fold.External_Folder_Id__c;
            foldMap.put(fold.EFS_Read_Collaboration_Id__c, siteWrapper);
        
		}
		
		return foldMap;
    }
    
    public FileListingWrapper.DirectoryWrapper convertToDirectoryWrapper(GoogleDriveModel.File fileObj) {
        FileListingWrapper.DirectoryWrapper wrapperObj = new FileListingWrapper.DirectoryWrapper();
        if( fileObj.id!=null ){
            wrapperObj.id = fileObj.id;
            wrapperObj.provider = 'googledrive';
            wrapperObj.name = fileObj.name;
            wrapperObj.permissions = fileObj.capabilities.canAddChildren ? 'readwrite' : 'read';
            wrapperObj.canCreateFolder = fileObj.capabilities.canAddChildren;
        }
        return wrapperObj;
    }
    
    public List<FileListingWrapper> convertListOfFilesToWrapper(List<GoogleDriveModel.File> listOfFile) {
        List<FileListingWrapper> listOfFileWrap = new List<FileListingWrapper>();
        Map<String, Set<String>> mapOfFileIdWithChatterGrpIdSet = new Map<String, Set<String>>();
        Set<String> setOfChatterGrpIdForQuery = new Set<String>();

        for (GoogleDriveModel.File fileObj: listOfFile) {
            
            Set<String> setOfChatterGrpId = new Set<String>();

            if(fileObj.permissions != null) {
                for (GoogleDriveModel.Permission permissionObj : fileObj.permissions) {
                    // Fetch the group permissions for file
                    if (String.isNotBlank(permissionObj.emailAddress) && 
                        permissionObj.emailAddress.startsWith('0F9')) {
                        String chatterGroupEmail;
                        chatterGroupEmail = permissionObj.emailAddress;
                        chatterGroupEmail = chatterGroupEmail.substring(0, chatterGroupEmail.indexOf('.'));
                        setOfChatterGrpId.add(chatterGroupEmail);
                        setOfChatterGrpIdForQuery.add(chatterGroupEmail);
                    }

                }
            }
            
             // Add chatterGroups added for file 
            if (!setOfChatterGrpId.isEmpty()) {
                mapOfFileIdWithChatterGrpIdSet.put(fileObj.id, setOfChatterGrpId);
            }

        }

        // Fetch site data for chatter groupId's from permissions
        List<Simpplr_Site__c> listOfSite = [SELECT id, name, Chatter_Group_Id__c, site_type__c 
                FROM Simpplr_Site__c 
                WHERE Chatter_Group_Id__c IN :setOfChatterGrpIdForQuery WITH SECURITY_ENFORCED];
        Map<String, Simpplr_Site__c> mapOfChatterGrpIdWithSiteObj = new Map<String, Simpplr_Site__c>();

        for (Simpplr_Site__c siteObj : listOfSite) {
            mapOfChatterGrpIdWithSiteObj.put(siteObj.Chatter_Group_Id__C, siteObj);
        }

        for (GoogleDriveModel.File fileObj: listOfFile) {
            FileListingWrapper fileListingWrapObj = new FileListingWrapper();
            fileListingWrapObj = convertGoogleDriveFileToFileListingWrapper(fileObj);
            fileListingWrapObj.listOfSite = new List<SiteLiteWrapper>();
            Set<String> setOfChatterGroupId =  mapOfFileIdWithChatterGrpIdSet.get(fileObj.id);

            if (setOfChatterGroupId != null && !setOfChatterGroupId.isEmpty()) {
            
                for (String chatterGroupIdStr : setOfChatterGroupId) {
                    if(mapOfChatterGrpIdWithSiteObj.containsKey(chatterGroupIdStr)) {
                        SiteLiteWrapper siteliteWrapObj = new SiteLiteWrapper();
                        Simpplr_Site__c siteObj = mapOfChatterGrpIdWithSiteObj.get(chatterGroupIdStr);
                        siteliteWrapObj.siteId = siteObj.id;
                        siteliteWrapObj.name = siteObj.name;
                        siteliteWrapObj.access = siteObj.site_type__c;
                        siteliteWrapObj.url = PageContext.getPageURL(Pages.app)  + 
                                '?u=/site/' + siteObj.id + '/files' + '#provider=' + 
                                ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING; 
                        fileListingWrapObj.listOfSite.add(siteliteWrapObj);
                    }
                }

            }

            listOfFileWrap.add(fileListingWrapObj);
        }

        return listOfFileWrap;
    }

    public FileListingWrapper convertGoogleDriveFileToFileListingWrapper(GoogleDriveModel.File fileObj) {
        FileListingWrapper wrapperObj = new FileListingWrapper();
        wrapperObj.id = fileObj.id; 
        wrapperObj.fileId = fileObj.id; 
        wrapperObj.name = fileObj.name;
        wrapperObj.title = fileObj.name; 
        wrapperObj.gdriveUrl = fileObj.webViewLink;
        wrapperObj.externalUrl = fileObj.webViewLink;
        wrapperObj.thumbnailImg = fileObj.thumbnailLink;
        wrapperObj.context = 'googledrive';
        wrapperObj.provider = 'googledrive';
        wrapperObj.location = 'googledrive';  
        wrapperObj.isFavorited = fileObj.starred;
        wrapperObj.url = PageContext.getPageURL(Pages.FileDetail) + '?fileId=' + wrapperObj.fileId + '&provider=' + ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
        wrapperObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(fileObj.modifiedTime);
        if(fileObj.capabilities != null) {
            wrapperObj.canChangeName = fileObj.capabilities.canRename;
            wrapperObj.canCreatePublicShareLink = fileObj.capabilities.canShare;
            wrapperObj.canCreateNewVersion = fileObj.capabilities.canEdit;
            wrapperObj.canDelete = false;
            wrapperObj.canMove = fileObj.capabilities.canTrash;
            wrapperObj.canDownload = fileObj.capabilities.canDownload;
        }                        

        if(fileObj.mimeType!=null ) {
            wrapperObj.isImage = fileObj.mimeType.contains('image');
            if('application/vnd.google-apps.folder'.equalsIgnoreCase(fileObj.mimeType)) {
                wrapperObj.isFolder = 1;
                wrapperObj.isDir = true;
                wrapperObj.type = 'Folder';	
                wrapperObj.permissions = fileObj.capabilities.canAddChildren ? 'readwrite' : 'read';
                wrapperObj.canChangeName = false;
            } else {
                wrapperObj.isFolder = 0;
                wrapperObj.isDir = false;                     
                if(fileObj.name.indexOf('.') == -1) {
                    wrapperObj.fileExtension = fileObj.mimeType.substringAfterLast('/').toUpperCase();
                    if(!ServiceConstants.GDRIVE_DOWNLOADABLE_TYPES.contains(wrapperObj.fileExtension) ){
                        wrapperObj.canDownload = false;
                    } else {
                        wrapperObj.onlyPDFDownload = true;
                        wrapperObj.canCreateNewVersion = false;
                    }
                } else { 
                    wrapperObj.fileExtension = fileObj.name.substringAfterLast('.').toUpperCase();
                }
                wrapperObj.type = Utility.getFileType(wrapperObj.fileExtension);
                wrapperObj.fileExtension =  wrapperObj.type;
                if(String.isNotBlank(wrapperObj.fileExtension) && ('GSHEET'.equalsIgnoreCase(wrapperObj.fileExtension) || 'GDOC'.equalsIgnoreCase(wrapperObj.fileExtension) || 'GSLIDES'.equalsIgnoreCase(wrapperObj.fileExtension))) {
                    wrapperObj.thumbnailImg = '';
                }
                wrapperObj.size = fileObj.size;
            }
        }       
        
        if (fileObj.owners != null && !fileObj.owners.isEmpty()) {
            wrapperObj.owner = new FileListingWrapper.OwnerWrapper();
            wrapperObj.owner.name = fileObj.owners[0].displayName;
        }
        
        return wrapperObj;
    }

    public List<TileDataWrapper.TileData> convertToTileDataList(GDAPIModelFileList listRes) {
		List<TileDataWrapper.TileData> fileList = new List<TileDataWrapper.TileData>();

		for(GDAPIModelFile gDriveFile : listRes.getFiles()) {
			TileDataWrapper.TileData tileDataObj = new TileDataWrapper.TileData();

			tileDataObj.id = gDriveFile.getId();
            tileDataObj.title = gDriveFile.getName();            
            tileDataObj.canDownload = false;
            if(gDriveFile.getCapabilities() != null && gDriveFile.getCapabilities().getCanDownload() != null) {
                tileDataObj.canDownload = true;
            }
            if(gDriveFile.getName().indexOf('.') == -1) {
                tileDataObj.fileExtension = gDriveFile.getMimeType().substringAfterLast('/').toUpperCase();
                if(!ServiceConstants.GDRIVE_DOWNLOADABLE_TYPES.contains(tileDataObj.fileExtension)) {
                    tileDataObj.canDownload = false;
                } 
            } else {
                tileDataObj.fileExtension = gDriveFile.getName().substringAfterLast('.').toUpperCase();
            }
            tileDataObj.type = Utility.getFileType(tileDataObj.fileExtension);
            tileDataObj.provider = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
			
			if(tileDataObj.fileExtension.equalsIgnoreCase('jpeg') 
					|| tileDataObj.fileExtension.equalsIgnoreCase('jpg') 
					|| tileDataObj.fileExtension.equalsIgnoreCase('png') 
					|| tileDataObj.fileExtension.equalsIgnoreCase('gif')) {

				tileDataObj.thumbnail = gDriveFile.getThumbnailLink();
			}

			tileDataObj.size = (Integer)gDriveFile.getSize();
			
			if(gDriveFile.getModifiedTime() != NULL) {
				tileDataObj.modifiedAt = gDriveFile.getModifiedTime().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			}
            
            tileDataObj.url = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => tileDataObj.id, 'provider' => 'googledrive'});

			fileList.add(tileDataObj);
		}

		return fileList;
	}

}