public with sharing class GoogleDriveService {
    /**Lambda endpoints */
    private static final String GOOGLE_API_CREATE_FOLDER = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=createNewFolder';
    private static final String GOOGLE_API_GET_SHARE_DRIVE = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=getAllSharedDrives';
    private static final String GOOGLE_API_GET_FOLDERS = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=getDriveFolders';
    
    private static final String GOOGLE_API_CREATE_SITE_GROUPS = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=createSiteGroups';
    public static final String GOOGLE_API_DELETE_SITE_GROUPS = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=deleteSiteGroups';
    public static final String GOOGLE_API_DELETE_GROUP = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=deleteGroup';
    public static final String GOOGLE_API_DISCONNECT_DRIVE_ADMIN = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager?action=disconnectGoogleDriveAdmin';

    public static final String API_REMOVE_GROUP_MEMBER = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=removeMemberFromGroup';
    @TestVisible private static final String API_ADD_GROUP_MEMBER = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=addMemberToGroup';
    @TestVisible private static final String API_ADD_GROUP_MEMBER_BULK = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=addmembertogroupbulk';
    @TestVisible private static final String API_REMOVE_GROUP_MEMBER_BULK = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=removememberfromgroupbulk';

    @TestVisible private static final String API_REMOVE_PERMISSION_BULK = SimpplrContext.simpplrAPIEndpoint + '/gsuite/access-manager?action=removePermissionBulk';
    @TestVisible private static final String API_UNLINK_FOLDER = SimpplrContext.simpplrAPIEndpoint + '/gsuite/access-manager?action=unlinkFolder';
    @TestVisible private static final String API_ADD_PERMISSION_BULK = SimpplrContext.simpplrAPIEndpoint + '/gsuite/access-manager?action=addPermissionBulk'; 
    @TestVisible private static final String SITE_ADD_PERMISSIONS_TO_FOLDER = SimpplrContext.simpplrAPIEndpoint + '/gsuite/access-manager?action=addPermissionsToFolderForGroups';
    public static final String GOOGLE_API_REMOVE_GROUP_MEMBER = SimpplrContext.simpplrAPIEndpoint + '/gsuite/group-manager?action=removeMemberFromGroup';
    
    private static final String GOOGLE_API_RENAME =  SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=rename';
    private static final String GOOGLE_API_GET_FILE = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=getFile';
    private static final String GOOGLE_API_MOVE_FILE = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=moveFile';

    private static final String GOOGLE_API_GET_RECENT_FILES = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=getrecentfiles';
    private static final String GOOGLE_API_GET_STARRED_FILES = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=getstarredfiles';
    private static final String GOOGLE_API_GET_TOKEN = SimpplrContext.simpplrAPIEndpoint + '/gsuite/access-manager?action=getPeopleToken';
    @TestVisible private static final String API_MIGRATE_GROUP_FOLDER = SimpplrContext.simpplrAPIEndpoint + '/gsuite/migration-manager?action=migrategroupandfolder';
    private static final String GOOGLE_API_GET_VERSION_HISTORY = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=getversionhistory';
    @TestVisible private static final String API_GET_MIGRATION_FOLDER_SUMMARY = SimpplrContext.simpplrAPIEndpoint + '/gsuite/migration-manager?action=foldersummary';
 
    /**Group suffix while creating groups */
    public static final String READ_GOOGLE_MANAGED_GROUP_SUFFIX = '.r_sfgm@';
    public static final String READ_WRITE_GOOGLE_MANAGED_GROUP_SUFFIX = '.rw_sfgm@';
    public static final String READ_SIMPPLR_MANAGED_GROUP_SUFFIX = '.r_sfsm@';
    public static final String READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX = '.rw_sfsm@';

    public static final String GOOGLE_API_EXPIRE_TOKEN = SimpplrContext.simpplrAPIEndpoint + '/gsuite/access-manager?action=expirePeopleToken';

    
    private static final String GOOGLE_FILES_ENDPOINT = 'https://www.googleapis.com/drive/v3/files';

    public static String googledriveFileFields = 'kind,id,name,description,mimeType,size,createdTime,modifiedTime,capabilities,size,parents,version,owners(emailAddress,displayName),permissions(id,emailAddress,role),starred,trashed,isAppAuthorized,thumbnailLink,webViewLink,iconLink,contentHints';
    public static String googledriveFileListFields = '&fields=kind,nextPageToken,files(' + googledriveFileFields + ')';
    
    //Corpora - Collections of Items
    public static final String CORPORA_USER = 'user';
    public static final String CORPORA_DOMAIN = 'domain';
    public static final String CORPORA_DRIVE = 'drive';
    public static final String CORPORA_ALLDRIVE = 'allDrives';
    public static final String CORPORA_TEAMDRIVE = 'teamDrive';
    public static final String CORPORA_ALLTEAMDRIVES = 'allTeamDrives';
    
    //Corpus - Collections of Items
    public static final String CORPUS_DEFAULT = 'user';
    public static final String CORPUS_DOMAIN = 'domain';
    
    //Spaces - Isolated Storages for Collection of Items   
    public static final String SPACES_DRIVE = 'drive';

    public String createSiteGroups(String chatterGrpId, String siteName) {
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        String rGroupEmailAddress = ''; 
        String rWGroupEmailAddress = ''; 

        if (SimpplrContext.googleManagedPermission) { 
            rGroupEmailAddress = chatterGrpId + READ_GOOGLE_MANAGED_GROUP_SUFFIX + domainStr;
            rWGroupEmailAddress = chatterGrpId + READ_WRITE_GOOGLE_MANAGED_GROUP_SUFFIX + domainStr;

        } else {
            rGroupEmailAddress = chatterGrpId + READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
            rWGroupEmailAddress = chatterGrpId + READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
        }
        
        String rGroupName = siteName + ' Users';
        String rWGroupName = siteName + ' Administrators';

        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('rGroupName', rGroupName);
        mapOfRequestParam.put('rGroupEmailAddress', rGroupEmailAddress);
        mapOfRequestParam.put('rWGroupName', rWGroupName);
        mapOfRequestParam.put('rWGroupEmailAddress', rWGroupEmailAddress);

        logger.logDebug('GoogleDriveSerive.createSiteGroups()----request body----' + mapOfRequestParam);
        HttpResponse responseObj = getResponseFromAWS(GOOGLE_API_CREATE_SITE_GROUPS, 
                mapOfRequestParam);  
        return responseObj.getBody();           
    }

    public GoogleDriveModel.File getFolderDetails(String driveType, String folderId, String folderName) {
        String endpoint = SimpplrContext.simpplrAPIEndpoint + '/gsuite/access-manager?action=getFolderDetails';
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('folderName', folderName);
        mapOfRequestParam.put('folderId', folderName);
        mapOfRequestParam.put('driveType', driveType);

        logger.logDebug('GoogleDriveSerive.getFolderDetails()----request body----' + mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(endpoint, mapOfRequestParam); 
        GoogleDriveModel.File folderDetails = (GoogleDriveModel.File) JSON.deserialize(res.getBody(), GoogleDriveModel.File.class);
        return folderDetails;
    }

    public GoogleDriveModel.GroupPermission addPermissionsToLinkedFolder(String chatterGrpId, String folderId, 
            String siteType, String driveType) {                
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        String rGroupEmail = ''; 
        String rWGroupEmail = ''; 
        String allCompanyGroupEmail;
        String allCompanySearchGroupEmail = SimpplrContext.simpplrOrgId + '_sfgm@' + domainStr;
        
        if (SimpplrContext.googleManagedPermission) { 
            rGroupEmail = chatterGrpId + READ_GOOGLE_MANAGED_GROUP_SUFFIX + domainStr;
            rWGroupEmail = chatterGrpId + READ_WRITE_GOOGLE_MANAGED_GROUP_SUFFIX + domainStr;

        } else {
            rGroupEmail = chatterGrpId + READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
            rWGroupEmail = chatterGrpId + READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
            allCompanyGroupEmail = SimpplrContext.simpplrOrgId + '_sfsm@' + domainStr;
        }

        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('folderId', folderId);
        mapOfRequestParam.put('driveType', driveType);
        mapOfRequestParam.put('siteType', siteType);
        mapOfRequestParam.put('rGroupEmail', rGroupEmail);
        mapOfRequestParam.put('rWGroupEmail', rWGroupEmail);
        mapOfRequestParam.put('searchGroupEmail', allCompanySearchGroupEmail);

        if (siteType == 'public' && !SimpplrContext.googleManagedPermission) {
            mapOfRequestParam.put('publicGroupEmail', allCompanyGroupEmail);
        }
        
        logger.logDebug('GoogleDriveSerive.addPermissionsToLinkedFolder()----request body----' + mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(SITE_ADD_PERMISSIONS_TO_FOLDER, mapOfRequestParam);                
        GoogleDriveModel.GroupPermissionResponse permRespObj = (GoogleDriveModel.GroupPermissionResponse)JSON.deserialize(res.getBody(), GoogleDriveModel.GroupPermissionResponse.class);
        return permRespObj.result;
    }

    public HttpResponse getResponseFromAWS(String endpoint, Object body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setTimeout(60000);
        req.setBody(Json.serialize(body));
        Http http = new Http();
        HttpResponse response = http.send(req);
        logger.logDebug('GoogleDriveSerive.getResponseFromAWS()----endpoint----' + endpoint);
        logger.logDebug('GoogleDriveSerive.getResponseFromAWS()----response body----' + response.getBody());
        if (response.getStatusCode() != 200) {
            logger.logDebug('GoogleDriveSerive.getResponseFromAWS()----response status code ----' + response.getStatusCode());
            if (response.getStatusCode()== 404){
                throw new SimpplrException(ServiceConstants.ERROR_404);
            } else if (response.getStatusCode() == 403){
                throw new SimpplrException(ServiceConstants.ERROR_403);
            } else {
                throw new SimpplrException(ExceptionCode.UNEXPECTED_ERROR.name());
            }
        }
        return response;
    }

    public Map<String, Object> searchFiles(Criteria.File fileCriteriaObj) {        
        Integer size = fileCriteriaObj.size == null ? 16 : fileCriteriaObj.size;
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('peopleId', UserContext.peopleId);	
        requestMap.put('nextPageToken', fileCriteriaObj.nextPageToken);
        requestMap.put('filter', fileCriteriaObj.filter);
        requestMap.put('sortBy', fileCriteriaObj.sortBy);
        requestMap.put('term', fileCriteriaObj.term);
        requestMap.put('size', size);
        //requestMap.put('groupKey', getGroupKeyForFileSearch(fileCriteriaObj.siteId));
        if(String.isBlank(fileCriteriaObj.nextPageToken)) {
            if(!GoogleDriveService.googleMultiDomainUpgraded()){
                requestMap.putAll(getParametersForFileSearch(fileCriteriaObj.siteId));
            }
        }
        String externalEndPoint;
        if(SimpplrContext.sharedDriveEnabled && SimpplrContext.myDriveEnabled && String.isBlank(fileCriteriaObj.siteId)) { 
            requestMap.put('driveType', 'AllDrive');
            externalEndPoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/file-manager?action=search';
        } else if (SimpplrContext.sharedDriveEnabled && String.isNotBlank(fileCriteriaObj.directory)) {
            requestMap.put('driveType', 'singleshareddrive');
            requestMap.put('directory', fileCriteriaObj.directory);
            externalEndPoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/file-manager?action=search';
        } else if (SimpplrContext.myDriveEnabled) {
            requestMap.put('driveType', 'mydrive');
            requestMap.put('simpManagedPermissions', !SimpplrContext.googleManagedPermission);
            externalEndPoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/file-manager?action=search';
        } else {
            externalEndPoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/file-manager?action=searchFilesInBatch';
        } 
        logger.logDebug('GoogleDriveService.searchFiles()----request body----'+ Json.serialize(requestMap));
        HttpResponse res = getResponseFromAWS(externalEndPoint, requestMap);
        GoogleDriveModel.FileListResponse fileListResponse = (GoogleDriveModel.FileListResponse) System.JSON.deserialize(res.getBody(), GoogleDriveModel.FileListResponse.class);
        List<FileListingWrapper> fileList = new List<FileListingWrapper>();
        GoogleDriveDataAdapter converterObj = new GoogleDriveDataAdapter();
        fileList.addAll(converterObj.convertListOfFilesToWrapper(fileListResponse.files));
        Map<String, Object> response = new Map<String, Object>();
        response.put('listOfFiles', fileList);
        response.put('nextPageToken', fileListResponse.nextPageToken);
        response.put('totalRecords', fileListResponse.totalRecords);
        return response; 
    }

    private Map<String, Object> getParametersForFileSearch(String siteId) {
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        Map<String, Object> fileSearchParamMap = new Map<String, Object>();
        Set<String> setOfGroupKeys = new Set<String>();
        
        Set<String> setOfNonPublicFollowedSiteIds = new Set<String>();
        String query =  'Select id, Chatter_Group_Id__c, Site_Type__c FROM Simpplr_Site__c where Is_Active__c = true ' + 
                        'AND Show_In_Simpplr__c = true And File_Storage_Source__c=\'googledrive\' ';

        if(String.isNotBlank(siteId)) {
            query += ' And id=:siteId ';
        } else {
            //All Company public group
            setOfGroupKeys.add(SimpplrContext.simpplrOrgId + '_sfsm@' +  domainStr);
            setOfNonPublicFollowedSiteIds = getSetOfNonPublicFollowedSiteIds();
            query += ' And id =:setOfNonPublicFollowedSiteIds ';
        }
        List<Simpplr_Site__c> siteList = Database.query(query);
        for(Simpplr_Site__c site : siteList) {
            setOfGroupKeys.add(site.Chatter_Group_Id__c + READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr);
        }
        fileSearchParamMap.put('setOfGroupKeys', setOfGroupKeys);

        if(String.isNotBlank(siteId)) {
            if(!siteList.isEmpty()) {
                String chatterGroupId = siteList[0].Chatter_Group_Id__c;
                String groupQueryStr = '"' + chatterGroupId + READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr + '" in readers ';
                fileSearchParamMap.put('setOfGroupQueryStr', new Set<String>{groupQueryStr});
                //Send Public Site owner's People Id if user is not following public site
                if(ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteList[0].Site_Type__c) &&
                    (UserContext.sitesIFollowIdSet.contains(chatterGroupId) == false)) {
                        fileSearchParamMap.put('siteOwnerPeopleId', getSiteOwnerPeopleId(chatterGroupId));
                }
            }
        } else {
            // '0F93t000000I4bhCAC.r_sfsm@simpplr.dev' in readers OR '
            // 1 + 18 + 7 + domain.lenght + 1 + 12 + 3  = 42 + domain.length()
            Integer lengthForOneCondition = 42 + domainStr.length();
            fileSearchParamMap.put('setOfGroupQueryStr', getSetOfGroupQueryStr(setOfGroupKeys, lengthForOneCondition));
        }
        return fileSearchParamMap;

    }

    private Set<String> getSetOfNonPublicFollowedSiteIds() {
        Set<String> setOfNonPublicFollowedSiteIds = new Set<String>();
        for(Simpplr_Site__c site:UserContext.sitesIFollowList) {
            if(!ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(site.Site_Type__C)) {
                setOfNonPublicFollowedSiteIds.add(site.Id);
            }
        }
        return setOfNonPublicFollowedSiteIds;
    }

    private String getSiteOwnerPeopleId(String chatterGroupId) {
        String siteOwnerPeopleId;
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', chatterGroupId);
        String queryStr = 'SELECT people__c from people_integration__c '+
                                                            ' WHERE name=\'googledrive\' '+
                                                            ' AND is_Deleted__c=false and connected__c=true '+
                                                            ' AND user__c in (Select ownerid from collaborationGroup '+
                                                                            ' where id =: soqlParam1)';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<People_Integration__c> peopleIntegrationList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
        if(!peopleIntegrationList.isEmpty()) {
            siteOwnerPeopleId = peopleIntegrationList[0].people__c;
        }
        return SiteOwnerPeopleId;

    }
    private Set<String> getSetOfGroupQueryStr(Set<String> setOfGroupKeys, Integer length) {
        Set<String> setOfGroupQueryStr = new Set<String>();
        Integer maxItems = 1400 /  length;
        Integer index = 1;
        String groupQueryStr = '';
        String seperator = ' OR ';
        for(String key : setOfGroupKeys) {
            groupQueryStr += ('"' + key + '" in readers ' + seperator);
            if(index == maxItems) {
                groupQueryStr = groupQueryStr.removeEnd(seperator);
                setOfGroupQueryStr.add(groupQueryStr.removeEnd(seperator));
                groupQueryStr = '';
                index = 1;
            } else {
                index++;                
            }
        }
        if(String.isNotBlank(groupQueryStr)) {
            setOfGroupQueryStr.add(groupQueryStr.removeEnd(seperator));
        }
        return setOfGroupQueryStr;
    }
    private String getGroupKeyForFileSearch(String siteId) {
        String groupKey;
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        if(String.isBlank(siteId)) {
            groupKey = SimpplrContext.simpplrOrgId + '_sfgm@' +  domainStr;                   
        } else {
            List<Simpplr_Site__c> siteList = [Select Chatter_Group_Id__c FROM Simpplr_Site__c where Id =: siteId WITH SECURITY_ENFORCED];
            String chatterGrpId = siteList[0].Chatter_Group_Id__c;
            if(SimpplrContext.googleManagedPermission) { 
                groupKey = chatterGrpId + READ_GOOGLE_MANAGED_GROUP_SUFFIX + domainStr;
            } else {
                groupKey = chatterGrpId + READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
            }
        }
        return groupKey;

    }

    public Map<String, Object> getFolderContents(Criteria.File fileCriteriaObj) {
        Integer size = fileCriteriaObj.size == null ? 16 : fileCriteriaObj.size;

        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('peopleId', UserContext.peopleId);	
        requestMap.put('nextPageToken', fileCriteriaObj.nextPageToken);
        requestMap.put('directory', fileCriteriaObj.directory);
        requestMap.put('owner', fileCriteriaObj.owner);
        requestMap.put('filter', fileCriteriaObj.filter);
        requestMap.put('sortBy', fileCriteriaObj.sortBy);
        requestMap.put('size', size);
        requestMap.put('driveType', fileCriteriaObj.driveType);
        requestMap.put('gUserEmail', UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE).User_Email__c);

        logger.logDebug('GoogleDriveService.getFolderContents()----request body----'+ requestMap);
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/file-manager?action=getFolderContents';

        Boolean canAccessFolder = true;
        HttpResponse res = new HttpResponse();
        try{
            res = getResponseFromAWS(externalEndPoint, requestMap);
        }catch(SimpplrException e){
            canAccessFolder = false;
        }

        GoogleDriveModel.FileListResponse fileListResponse = new GoogleDriveModel.FileListResponse();
        List<FileListingWrapper> fileList = new List<FileListingWrapper>();
        GoogleDriveDataAdapter converterObj = new GoogleDriveDataAdapter();
        FileListingWrapper.DirectoryWrapper directoryWrapper = new FileListingWrapper.DirectoryWrapper();

        logger.logDebug('canAccessFolder => ' + canAccessFolder);

        if(canAccessFolder == true){
            fileListResponse = (GoogleDriveModel.FileListResponse) System.JSON.deserialize(res.getBody(), GoogleDriveModel.FileListResponse.class);
            for (GoogleDriveModel.File fileObj: fileListResponse.files){
                fileList.add(converterObj.convertGoogleDriveFileToFileListingWrapper(fileObj));
            }
            directoryWrapper = converterObj.convertToDirectoryWrapper(fileListResponse.directory);
            // Google does not return name of shared drive instead always returns 'Drive'
            // Set UI passed name if present
            directoryWrapper.name = fileCriteriaObj.name != null ? fileCriteriaObj.name : directoryWrapper.name;
        }else{
            directoryWrapper = new FileListingWrapper.DirectoryWrapper();
            directoryWrapper.id = fileCriteriaObj.directory;
            directoryWrapper.provider = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
            // Set UI passed name if present else default to Drive or Folder based on driveType
            directoryWrapper.name = fileCriteriaObj.name != null ? fileCriteriaObj.name : (fileCriteriaObj.driveType == ServiceConstants.GOOGLE_DRIVE_TYPE_SHARED_DRIVE ? 'Drive' : 'Folder');
            directoryWrapper.isAccessDenied = true;
        }

        Map<String, Object> response = new Map<String, Object>();
        response.put('listOfItems', fileList);
		response.put('directory', directoryWrapper);
        response.put('nextPageToken', fileListResponse.nextPageToken);
        return response; 
    }

    public FileDetailWrapper getFileDetail(String fileId) {
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('fileId', fileId);

        logger.logDebug('GoogleDriveService.getFileDetail()----request body----'+ mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(GOOGLE_API_GET_FILE, mapOfRequestParam);
        GoogleDriveModel.FileResponse fileResponseObj = (GoogleDriveModel.FileResponse)JSON.deserialize(res.getBody(),
                    GoogleDriveModel.FileResponse.class);
        FileDetailWrapper fileWrapObj = new GoogleDriveDataAdapter().convertToFileDetailWrapper(fileResponseObj.result);
        return fileWrapObj; 
    }
    
    /**
     * @description This method is used to check folder permissions
     * @param fileId 
     * @return `Boolean`
     */
    public Boolean checkFolderPermission(String fileId) {
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('fileId', fileId);

        logger.logDebug('GoogleDriveService.getFolderPermission()----request body----'+ mapOfRequestParam);
        Boolean canAccessFolder = true;
        HttpResponse res = new HttpResponse();
        try{
            res = getResponseFromAWS(GOOGLE_API_GET_FILE, mapOfRequestParam);
        }catch(SimpplrException e){
            canAccessFolder = false;
        }  
        return canAccessFolder; 
    }

    public String getAccessToken() {
        FileDetailWrapper fileWrapObj = new FileDetailWrapper();
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);

        logger.logDebug('GoogleDriveService.getAccessToken()----request body----'+ mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(GOOGLE_API_GET_TOKEN, mapOfRequestParam);
        GoogleDriveModel.AccessResponse accessResponseObj = (GoogleDriveModel.AccessResponse)JSON.deserialize(res.getBody(),
                                    GoogleDriveModel.AccessResponse.class);
        return accessResponseObj.result; 
    }

    public Boolean expireAccessToken () {
        Boolean isSuccess = false;
        logger.logDebug('GoogleDriveSerive.expireAccessToken()');
        FileDetailWrapper fileWrapObj = new FileDetailWrapper();
        String externalEndPoint = GOOGLE_API_EXPIRE_TOKEN;
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(externalEndPoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', simpDri);
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        HttpResponse res;
        res = http.send(req);
        logger.logDebug(res.getStatusCode());
        logger.logDebug(res.getBody());

        if (res.getStatusCode() == 200) {
            String googleResponseStr = res.getBody();
            GoogleDriveModel.AccessResponse accessResponseObj = (GoogleDriveModel.AccessResponse)JSON.deserialize(googleResponseStr,
                    GoogleDriveModel.AccessResponse.class);

            if (accessResponseObj.status == 'success') {
                isSuccess = Boolean.valueOf(accessResponseObj.result);

            } else {
                throw new  SimpplrException('Not able to fetch people token');
            }

        } else {
            throw new  SimpplrException('Not able to fetch people token');
        }

        return isSuccess; 
    }

    public String requestForGoogleDriveSearch(String searchType, Map<String,String> queryStringMap ){
        //SearchType Can be
        logger.logDebug('GoogleDriveService.requestForGoogleDriveSearch()===queryStringMap -->'+ queryStringMap);
        String queryStr='';
        if( queryStringMap.get('q') !=null ){
            queryStr+= 'q='+queryStringMap.get('q');
        }
        if( queryStringMap.get('driveId') != null && !queryStr.contains('q')){
            queryStr+= 'corpora='+CORPORA_DRIVE;
            queryStr+= '&driveId='+queryStringMap.get('driveId');
        }else if(queryStringMap.get('driveId') != null && queryStr.contains('q')){
            queryStr+= '&corpora='+CORPORA_DRIVE;
            queryStr+= '&driveId='+queryStringMap.get('driveId');
        }
        if( queryStringMap.get('driveId') == null || queryStringMap.get('driveId') == ' '){
            queryStr+= '&corpora='+CORPORA_ALLDRIVE;
        }
        queryStr+= '&includeItemsFromAllDrives=true&supportsAllDrives=true';
        logger.logDebug('GoogleDriveService.requestForGoogleDriveSearch()===orderBy -->'+ queryStringMap.containskey('orderBy') +' -- '+queryStringMap.get('orderBy') +'---->'+String.isNotBlank(queryStringMap.get('orderBy')));
        if( queryStringMap.containskey('orderBy') && String.isNotBlank(queryStringMap.get('orderBy'))){
            queryStr+= '&orderBy='+queryStringMap.get('orderBy');
        } else if( String.isBlank( queryStringMap.get('orderBy') )){
            queryStr+= '&orderBy=folder,createdTime desc,name';
        }
        
        queryStr+= googledriveFileListFields+'&pageSize='+queryStringMap.get('pageSize');
        logger.logDebug('GoogleDriveService.requestForGoogleDriveSearch()===queryStr -->'+ queryStr);
        //search
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/drive-search?action='+searchType;        
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('peopleId', UserContext.peopleId);	
        requestMap.put('endpoint', GOOGLE_FILES_ENDPOINT);
        requestMap.put('query', queryStr);
        requestMap.put('pageno', '1');
        requestMap.put('pageToken', queryStringMap.get('pageToken'));
        if( queryStringMap.containskey('pageSize')){
            requestMap.put('pageSize', queryStringMap.get('pageSize'));
        }
        logger.logDebug('GoogleDriveService.requestForGoogleDriveSearch()----request body----'+ requestMap);
        HttpResponse res = getResponseFromAWS(externalEndPoint, requestMap);
        return res.getBody();
    }

    public ResponseWrapper deleteFile(String fileId) {
        String GOOGLE_API_DELETE_FILE = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=deleteFile';
        ResponseWrapper responseWrapObj = new ResponseWrapper();
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('fileId', fileId);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(GOOGLE_API_DELETE_FILE);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        logger.logDebug('GoogleDriveService.deleteFile()----request body----'+ req);
        HttpResponse res = http.send(req);        
        logger.logDebug('GoogleDriveService.deleteFile()----response body----'+ res.getBody());

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            if (responseObj.get('status') == 'success'){
                responseWrapObj.result = responseObj.get('result'); 

            } else {
                throw new  SimpplrException('Not able to delete file');
            }

        } else {
            logger.logDebug('GoogleDriveService.deleteFile()----response code----'+ res.getStatusCode());
            throw new  SimpplrException('Not able to delete file');
        }

        return responseWrapObj;
    }

    public FileListingWrapper createNewFolder (Criteria.Folder folderObjArg) {
        FileListingWrapper wrapperObj = new FileListingWrapper();
        String externalEndPoint = GOOGLE_API_CREATE_FOLDER;
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('parentFolderId', folderObjArg.directory);
        mapOfRequestParam.put('folderName', folderObjArg.name);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(externalEndPoint); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', simpDri);
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();            
        String newFolderId = ''; 

        HttpResponse res = http.send(req);			
        logger.logDebug('FileDataServer.createGoogleFolder----res.getBody()----'+res.getBody());
        
        if (res.getStatusCode() == 200){
            String googleResponseStr = res.getBody();
            Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(googleResponseStr);
            
            if (responseObj.get('status') == 'success') {
                newFolderId =  String.valueOf(responseObj.get('result'));  
                wrapperObj.id = newFolderId;
                wrapperObj.name = folderObjArg.name;
                wrapperObj.isDir = true; 
                wrapperObj.title = folderObjArg.name;
                wrapperObj.provider = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;

            } else {
                throw new SimpplrException('EFS Folder creation error!');
            }

        }  else {
            logger.logDebug('FileDataServer.createGoogleFolder----status code----'+res.getStatusCode());
            throw new SimpplrException('EFS Folder creation error!');
        }

        return wrapperObj;
    } 

    public Map<String, Object> getSharedDrivesForLinking (Criteria.Folder folderObjArg) {
        Integer size = folderObjArg.size == null ? 16 : folderObjArg.size;
        List<FilterAttributeWrapper> listOfLinkFolders = new List<FilterAttributeWrapper>();
        // String directory = String.isBlank(folderObjArg.directory) ? 'root' : folderObjArg.directory;
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        // mapOfRequestParam.put('directory', directory);
        mapOfRequestParam.put('nextPageToken', folderObjArg.nextPageToken);
        mapOfRequestParam.put('size', size);
        mapOfRequestParam.put('term', folderObjArg.term);

        logger.logDebug('GoogleDriveSerive.getSharedDrivesForLinking()----request body----' + mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(GOOGLE_API_GET_SHARE_DRIVE, mapOfRequestParam);
        GoogleDriveModel.DriveListResponse driveListResponseObj = (GoogleDriveModel.DriveListResponse)JSON.deserialize(res.getBody(), GoogleDriveModel.DriveListResponse.class);
        GoogleDriveModel.DriveList driveListObj = driveListResponseObj.result;

        for (GoogleDriveModel.drive driveObj: driveListObj.drives) {                        
            FilterAttributeWrapper filterObj = new FilterAttributeWrapper(driveObj.id, driveObj.name);
            filterObj.type = 'shareddrive';
            filterObj.isLinked = false;     // Only one shared drive can be linked from ui
            listOfLinkFolders.add(filterObj);
        }

        listOfLinkFolders.sort();
        Map<String, Object> result = new Map<String, Object>();
        result.put('listOfItems',listOfLinkFolders );
        result.put('nextPageToken',driveListObj.nextPageToken);
        return result;
    }
    
    public  Map<String, Object> getMyDriveFolderListingForLinking(Criteria.Folder folderObjArg) {
        Integer size = folderObjArg.size == null ? 16 : folderObjArg.size;
        List<FilterAttributeWrapper> listOfLinkFolders = new List<FilterAttributeWrapper>();
        String directory = String.isBlank(folderObjArg.directory) ? 'root' : folderObjArg.directory;
        String siteId = folderObjArg?.siteId;

        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('myDriveId', directory);
        mapOfRequestParam.put('nextPageToken', folderObjArg.nextPageToken);
        mapOfRequestParam.put('size', size);
        mapOfRequestParam.put('term', folderObjArg.term);

        logger.logDebug('GoogleDriveSerive.getMyDriveFolderListingForLinking()----request body----' + mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(GOOGLE_API_GET_FOLDERS, mapOfRequestParam);
        GoogleDriveModel.MyDriveResponse myDriveRespObj = (GoogleDriveModel.MyDriveResponse)JSON.deserialize(res.getBody(), GoogleDriveModel.MyDriveResponse.class);            
        GoogleDriveModel.MyDrive myDriveObj = myDriveRespObj.result;  
        Set<String> externalFolderIdSet = getUniqueExternalFolderIds(siteId, ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
        for (GoogleDriveModel.File fileObj: myDriveObj.files) {
            FilterAttributeWrapper filterObj = new FilterAttributeWrapper();
            filterObj.id = fileObj.id;
            filterObj.name = fileObj.name;
            filterObj.type = 'folder';
            filterObj.isLinked = externalFolderIdSet.contains(fileObj.id);
            listOfLinkFolders.add(filterObj);
        }
        Map<String, Object> result = new Map<String, Object>();
        result.put('listOfItems',listOfLinkFolders );
        result.put('nextPageToken', myDriveObj.nextPageToken);
        return result;
    }

    public Set<String> getUniqueExternalFolderIds(String siteId, string efsProvider) {
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
        soqlParamMap.put('soqlParam2', efsProvider);
        String query = 'SELECT	External_Folder_Id__c FROM Folder__c WHERE site__c =: soqlParam1 AND type__c =: soqlParam2 AND Is_Deleted__c = false AND Is_System_Folder__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
		List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        Set<String> externalFolderIdSet = new Set<String>();
        for (Folder__c fileObj: folderList) {
            externalFolderIdSet.add(fileObj.External_Folder_Id__c);
        }
        return externalFolderIdSet;
    }
 
    public Boolean removePermissionsFromFolders(List<GoogleDriveModel.RemovePermissionReq> listOfFolderWithPermission) {
        logger.logDebug('GoogleDriveService.removePermissionsFromFolders()----listOfFolderWithPermission----' + listOfFolderWithPermission);
        String externalEndPoint = API_REMOVE_PERMISSION_BULK;
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('listOfFolderWithPermission', listOfFolderWithPermission); 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(externalEndPoint); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        HttpResponse res = http.send(req);
        logger.logDebug('------------res.getStatusCode()'+ res.getStatusCode()+ res.getBody());

        if (res.getStatusCode() == 200) {
            GoogleDriveModel.RemovePermissionResp removePermissionResObj = (GoogleDriveModel.RemovePermissionResp)JSON.deserialize(res.getBody(), GoogleDriveModel.RemovePermissionResp.class);
            
            if (removePermissionResObj.status == 'success') {
                return true; 

            } else {
                throw new SimpplrException('Error Occured');
            }
            
        } else {
            throw new SimpplrException('Error Occured');
        }

    }


    public Boolean unlinkFolder(String folderId, List<String> permissionIdList) {
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('folderId', folderId); 
        mapOfRequestParam.put('permissionIdList', permissionIdList); 
        logger.logDebug('GoogleDriveSerive.unlinkFolder()----request body----' + mapOfRequestParam);
        getResponseFromAWS(API_UNLINK_FOLDER, mapOfRequestParam);  
        return true;
    }

    public String addPublicGroupPermission(Set<String> setOfExtFolderId) {
        logger.logDebug('GoogleDriveSerive.addPublicGroupPermission()----request body----' + setOfExtFolderId);
        String externalEndPoint = API_ADD_PERMISSION_BULK;
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        String publicGroupEmail = SimpplrContext.simpplrOrgId;

        if (SimpplrContext.googleManagedPermission) { 
            publicGroupEmail = publicGroupEmail +  '_sfgm@' + domainStr;

        } else {
            publicGroupEmail = publicGroupEmail +  '_sfsm@' + domainStr;
        }

        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('setOfFolderId', setOfExtFolderId); 
        mapOfRequestParam.put('groupEmail', publicGroupEmail);
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(externalEndPoint); 
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        HttpResponse res = http.send(req);
        logger.logDebug('------------res.getStatusCode()' + res.getStatusCode());
        logger.logDebug('------------res.getBody()' + res.getBody());

        if (res.getStatusCode() == 200) {
            
            GoogleDriveModel.GroupPermissionResponse permRespObj = (GoogleDriveModel.GroupPermissionResponse)JSON.deserialize(res.getBody(), GoogleDriveModel.GroupPermissionResponse.class);
            
            if (permRespObj.status == 'success' && permRespObj.result.pubPermissionId != null){
                return permRespObj.result.pubPermissionId;

            } else {
                throw new  SimpplrException('Not able to add permission to folders');
            }

        } else {
            throw new SimpplrException('Error Occured');
        }
    }

    public List<TileDataWrapper.TileData> getGoogleDriveTilesData(String variant) {
        logger.logDebug('GoogleDriveSerive.getGoogleDriveTilesData()----variant----' + variant);
		Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('size', 18);
        String externalEndPoint;
        switch on variant {
            when 'recent' {
                externalEndPoint = GOOGLE_API_GET_RECENT_FILES;
            } when 'starred' {
                externalEndPoint = GOOGLE_API_GET_STARRED_FILES;
            }
        }

        logger.logDebug('GoogleDriveSerive.getGoogleDriveTilesData()----request body----' + mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(externalEndPoint, mapOfRequestParam);               
        GDAPIModelFileList listRes = (GDAPIModelFileList)JSON.deserialize(res.getBody(), GDAPIModelFileList.class);	
        GoogleDriveDataAdapter converterObj = new GoogleDriveDataAdapter();			
        List<TileDataWrapper.TileData> fileList = converterObj.convertToTileDataList(listRes);        			
		return fileList;
	}
    
    public ResponseWrapper renameFolder( String fileId, String newName, String type ) {
        String endpoint = GOOGLE_API_RENAME;
        ResponseWrapper responseWrapObj = new ResponseWrapper();
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapofRequestParam.put('driveFolderId', fileId);
        mapofRequestParam.put('type', type);
        mapofRequestParam.put('name',newName);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', Utility.getSimpDri());
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();

        logger.logDebug('GoogleDriveService.renameFolder()----request body----'+ req);
        HttpResponse res = http.send(req);        
        logger.logDebug('GoogleDriveService.renameFolder()----response body----'+ res.getBody());

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            if (responseObj.get('status') == 'success'){
                responseWrapObj.result = responseObj.get('result'); 

            } else {
                throw new  SimpplrException('Not able to rename folder');
            }

        } else {
            logger.logDebug('GoogleDriveService.renameFolder()----response code----'+ res.getStatusCode());
            throw new  SimpplrException('Not able to rename Folder');
        }

        return responseWrapObj;
    }

    public ResponseWrapper bookmarkFile(String fileId) {
        String GOOGLE_API_BOOKMARK_FILE = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=bookmarkFile';
        ResponseWrapper responseWrapObj = new ResponseWrapper();
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);

        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('fileId', fileId);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(GOOGLE_API_BOOKMARK_FILE);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', simpDri);
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        logger.logDebug('GoogleDriveService.bookmarkFile()----request body----'+ req);
        HttpResponse res = http.send(req);
        logger.logDebug('GoogleDriveService.bookmarkFile()----response body----'+ res.getBody());

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            if (responseObj.get('status') == 'success'){
                responseWrapObj.result = responseObj.get('result'); 

            } else {
                throw new  SimpplrException('Not able to bookmark file');
            }

        } else {
            logger.logDebug('GoogleDriveService.bookmarkFile()----response code----'+ res.getStatusCode());
            throw new  SimpplrException('Not able to bookmark file');
        }
        return responseWrapObj;
    }
    
    public ResponseWrapper unbookmarkFile(String fileId) {
        String GOOGLE_API_BOOKMARK_FILE = SimpplrContext.simpplrAPIEndpoint + '/gsuite/file-manager?action=unbookmarkFile';
        ResponseWrapper responseWrapObj = new ResponseWrapper();
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);

        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('fileId', fileId);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(GOOGLE_API_BOOKMARK_FILE);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('simpplr-dri', simpDri);
        req.setMethod('POST');
        req.setBody(Json.serialize(mapOfRequestParam));
        Http http = new Http();
        logger.logDebug('GoogleDriveService.unbookmarkFile()----request body----'+ req);
        HttpResponse res = http.send(req);
        logger.logDebug('GoogleDriveService.unbookmarkFile()----response body----'+ res.getBody());

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseObj = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            if (responseObj.get('status') == 'success'){
                responseWrapObj.result = responseObj.get('result'); 

            } else {
                throw new  SimpplrException('Not able to unbookmark file');
            }

        } else {
            logger.logDebug('GoogleDriveService.unbookmarkFile()----response code----'+ res.getStatusCode());
            throw new  SimpplrException('Not able to unbookmark file');
        }
        return responseWrapObj;
    }

    public List<FileVersionHistoryWrapper> getversionhistory(String fileId) {
        List<FileVersionHistoryWrapper> listOfFileVersions = new List<FileVersionHistoryWrapper>();
        String endpoint = GOOGLE_API_GET_VERSION_HISTORY;
        String simpDri = Utility.externalRequestAuthToken() + 
                ' ' + SimpplrContext.simpplrOrgId.substring(0, 15) +
                ' ' + UserContext.userId.substring(0, 15);

        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('fileId', fileId);

        logger.logDebug('GoogleDriveSerive.getversionhistory()----request body----' + mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(endpoint, mapOfRequestParam);
        GoogleDriveModel.MyDriveResponse revisionListResponse = (GoogleDriveModel.MyDriveResponse) System.JSON.deserialize(res.getBody(), GoogleDriveModel.MyDriveResponse.class);

        GoogleDriveModel.MyDrive revisionListResponseObj = new GoogleDriveModel.MyDrive();
        revisionListResponseObj  = revisionListResponse.result;
        logger.logDebug('revisionListResponseObj' + revisionListResponseObj);

        if (!revisionListResponseObj.revisions.isEmpty()) {
                    
            Integer versionNumber = 1;
            for (GoogleDriveModel.File fileObj: revisionListResponseObj.revisions) {
                        
                FileVersionHistoryWrapper fileVersionObj = new FileVersionHistoryWrapper();
                fileVersionObj.versionId = fileObj.id;
                fileVersionObj.createdAt = Utility.dateTimeToMomentJSDateTime(fileObj.modifiedTime);
                
                if(fileObj.lastModifyingUser != null) {
                    fileVersionObj.user.Name = fileObj.lastModifyingUser.displayName;
                }
                
                fileVersionObj.versionNumber = String.valueOf(versionNumber);

                listOfFileVersions.add(fileVersionObj);
                versionNumber++;

            }

        }

        return listOfFileVersions;
    }

    public void disconnectGoogleDriveAdmin(List<String> chattergroupIds) {
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('userId', UserContext.userId);
        mapOfRequestParam.put('chattergroupIds', chattergroupIds);
        mapOfRequestParam.put('myDriveEnabled', SimpplrContext.myDriveEnabled);
        mapOfRequestParam.put('sharedDriveEnabled', SimpplrContext.sharedDriveEnabled);
        mapOfRequestParam.put('googleManagedPermission', SimpplrContext.googleManagedPermission);

        String allCompanyGroupEmail = SimpplrContext.simpplrOrgId;
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        
        if (SimpplrContext.googleManagedPermission){
            mapOfRequestParam.put('permission', 'googlemanage');
            mapOfRequestParam.put('allCompanyGroupId', allCompanyGroupEmail +'_sfgm@' + domainStr);
        } else {
            mapOfRequestParam.put('permission', 'simpplrmanage');
            mapOfRequestParam.put('allCompanyGroupId', allCompanyGroupEmail +'_sfsm@' + domainStr);
            mapOfRequestParam.put('allCompanyGroupGoogleId', allCompanyGroupEmail +'_sfgm@' + domainStr);
        }

        logger.logDebug('GoogleDriveSerive.disconnectGoogleDriveAdmin()----request body----' + mapOfRequestParam);
        getResponseFromAWS(GOOGLE_API_DISCONNECT_DRIVE_ADMIN, mapOfRequestParam);  
    }

    public void disconnectGoogleDrivePeople() {
        String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager?action=disconnectGoogleDrivePeople';
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);        
        logger.logDebug('GoogleDriveSerive.disconnectGoogleDrivePeople()----request body----' + mapOfRequestParam);
        getResponseFromAWS(endpointURL, mapOfRequestParam);  

    }

    public String addMembersToGroupBulk(List<GoogleDriveModel.GroupMemberRequest> listOfGrpMemReq) {
        logger.logDebug('GoogleDriveService.addMembersToGroup()----request body----'+ listOfGrpMemReq);
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('listOfGroupWithMember', listOfGrpMemReq);
        logger.logDebug('GoogleDriveSerive.addMembersToGroup()----request body----' + mapOfRequestParam);
        HttpResponse responseObj = getResponseFromAWS(API_ADD_GROUP_MEMBER_BULK, mapOfRequestParam);  
        return responseObj.getBody();           
    }

    public String removeMembersToGroupBulk(List<GoogleDriveModel.GroupMemberRequest> listOfGrpMemReq) {
        logger.logDebug('GoogleDriveService.removeMembersToGroup()----request body----'+ listOfGrpMemReq);
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('listOfGroupWithMember', listOfGrpMemReq);
        logger.logDebug('GoogleDriveSerive.removeMembersToGroup()----request body----' + mapOfRequestParam);
        HttpResponse responseObj = getResponseFromAWS(API_REMOVE_GROUP_MEMBER_BULK, mapOfRequestParam);  
        return responseObj.getBody();           
    }
    
    public String addMemberToGroup(String groupKey, String memberKey) {
        logger.logDebug('GoogleDriveService.addMemberToGroup()----request body----'+ groupKey + memberKey);
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('groupKey', groupKey);
        mapOfRequestParam.put('memberKey', memberKey);
        logger.logDebug('GoogleDriveSerive.addMemberToGroup()----request body----' + mapOfRequestParam);
        HttpResponse responseObj = getResponseFromAWS(API_ADD_GROUP_MEMBER, mapOfRequestParam);  
        return responseObj.getBody();           
    }

    public String removeMemberFromGroup(String groupKey, String memberKey) {
        logger.logDebug('GoogleDriveService.removeMemberFromGroup()----request body----'+ groupKey + memberKey);
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('groupKey', groupKey);
        mapOfRequestParam.put('memberKey', memberKey);
        logger.logDebug('GoogleDriveSerive.removeMemberFromGroup()----request body----' + mapOfRequestParam);
        HttpResponse responseObj = getResponseFromAWS(API_REMOVE_GROUP_MEMBER, mapOfRequestParam);  
        return responseObj.getBody();           
    }

    public String migrateFolderAndGroups(List<GoogleDriveModel.FolderAndGroupReq> listOfFolderAndGroupReq, Integer folderCount) {
        logger.logDebug('GoogleDriveService.migrateFolderAndGroups()----listOfFolderAndGroupReq----'+ listOfFolderAndGroupReq);
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        String publicGroupKey = SimpplrContext.simpplrOrgId + '_sfsm@' + domainStr;
        String searchGroupKey = SimpplrContext.simpplrOrgId + '_sfgm@' + domainStr;
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('publicGroupKey', publicGroupKey);
        mapOfRequestParam.put('searchGroupKey', searchGroupKey);
        mapOfRequestParam.put('listOfFolderAndGroupReq', listOfFolderAndGroupReq);
        Boolean lastBatch = false;

        if (folderCount == 0) {
            lastBatch = true;
        }
        
        mapOfRequestParam.put('lastBatch', lastBatch);
        logger.logDebug('GoogleDriveSerive.removeMemberFromGroup()----mapOfRequestParam----' + mapOfRequestParam);
        HttpResponse responseObj = getResponseFromAWS(API_MIGRATE_GROUP_FOLDER, mapOfRequestParam);  
        return responseObj.getBody();      
    }
         
    public void pushAppIntegrationRecord(App_Integration__c appIntegration) {
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('org_id', UserInfo.getOrganizationId());
        List<People__c> peopleList = [Select id, User_Id__c from People__c where user_id__c =: appIntegration.CreatedById WITH SECURITY_ENFORCED];
        if (!peopleList.isEmpty()) {
            requestMap.put('people_id', peopleList[0].Id); 
        }
        requestMap.put('user_id', appIntegration.createdById);
        requestMap.put('access_token', appIntegration.App_Access_Token__c);
        requestMap.put('refresh_token', appIntegration.App_Refresh_Token__c);
        requestMap.put('scope', appIntegration.Scope__c);
        requestMap.put('gsuite_user_id', appIntegration.External_Id__c);
        requestMap.put('gsuite_user_email', appIntegration.User_Email__c);
        requestMap.put('gsuite_user_name', appIntegration.User_Name__c);
        requestMap.put('gsuite_domain', appIntegration.Enterprise_Id__c);

        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/migration-manager?action=migrateappintegration';  
        getResponseFromAWS(externalEndPoint, requestMap);
        
    }

    public void pushPeopleIntegrationRecords(List<Object> objectList) {
        Map<String, Object> requestMap = new Map<String, Object>();
        String externalEndPoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/migration-manager?action=migratepeopleintegration';  
        getResponseFromAWS(externalEndPoint, objectList);   
    }

    public Boolean moveFile(String fileId, String parentFolderId, List<String> listOfParents) {
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('parentFolderId', parentFolderId);
        mapOfRequestParam.put('listOfParents', listOfParents);
        mapOfRequestParam.put('fileId', fileId);

        logger.logDebug('GoogleDriveSerive.moveFile()----request body----' + mapOfRequestParam);
        getResponseFromAWS(GOOGLE_API_MOVE_FILE, mapOfRequestParam);  
        return true;
    }

    public Boolean deleteSiteGroups(String chatterGrpId) {
        Boolean successFlag = false; 
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        String rGroupKey = ''; 
        String rWGroupkey = ''; 

        if (SimpplrContext.googleManagedPermission) { 
            rGroupKey = chatterGrpId + READ_GOOGLE_MANAGED_GROUP_SUFFIX + domainStr;
            rWGroupkey = chatterGrpId + READ_WRITE_GOOGLE_MANAGED_GROUP_SUFFIX + domainStr;

        } else {
            rGroupKey = chatterGrpId + READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
            rWGroupkey = chatterGrpId + READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
        }

        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('rGroupKey', rGroupKey);
        mapOfRequestParam.put('rWGroupKey', rWGroupkey);

        logger.logDebug('GoogleDriveSerive.deleteSiteGroups()----request body----' + mapOfRequestParam);
        HttpResponse responseObj = getResponseFromAWS(GOOGLE_API_DELETE_SITE_GROUPS, 
                mapOfRequestParam);  
        return true;           
    }

    public String getMigrationFolderSummary() {
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        logger.logDebug('GoogleDriveSerive.getMigrationFolderSummary()----request body----' + mapOfRequestParam);
        HttpResponse responseObj = getResponseFromAWS(API_GET_MIGRATION_FOLDER_SUMMARY, mapOfRequestParam);  
        return responseObj.getBody();
    }
     
    public GoogleDriveModel.FileListResponse getFavoriteFiles(Integer size, String nextPageToken, 
            String term) {
        logger.logDebug('GoogleDriveSerive.getFavoriteFiles()----nextPageToken----' + nextPageToken);
		Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('nextPageToken', nextPageToken);
        mapOfRequestParam.put('size', size);
        mapOfRequestParam.put('term', term);
        String externalEndPoint= GOOGLE_API_GET_STARRED_FILES;

        logger.logDebug('GoogleDriveSerive.getFavoriteFiles()----request body----' + mapOfRequestParam);
        HttpResponse res = getResponseFromAWS(externalEndPoint, mapOfRequestParam);               
        GoogleDriveModel.FileListResponse fileListResp = (GoogleDriveModel.FileListResponse)JSON.deserialize(res.getBody(), 
                GoogleDriveModel.FileListResponse.class);	  
		return fileListResp;
	}

    public void saveFilesIntegrationsConfig(Boolean myDriveEnabled, Boolean sharedDriveEnabled, Boolean googleManagedPermission, Boolean showOpenInGoogleDrive) {        
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('peopleId', UserContext.peopleId);
        requestMap.put('userId', UserContext.Id);	
        requestMap.put('myDriveEnabled', myDriveEnabled);
        requestMap.put('sharedDriveEnabled', sharedDriveEnabled);    
        if (googleManagedPermission){
            requestMap.put('permission', 'googlemanage');

        } else {
            requestMap.put('permission', 'simpplrmanage');
        }
        requestMap.put('showOpenInGoogleDrive', showOpenInGoogleDrive);
        requestMap.put('appName', SimpplrContext.applicationName);
        logger.logDebug('GoogleDriveSerive.saveFilesIntegrationsConfig()----request body----' + requestMap);

        String endpoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/access-manager?action=saveGoogleIntegrationConfig';
        getResponseFromAWS(endpoint, requestMap);
    }

    public void saveDomainsIntegrationsConfig(String type, Map<String, List<Map<String, String>>> googleIntegrationsUpdateMap) {        
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('peopleId', UserContext.peopleId);
        requestMap.put('userId', UserContext.Id);
        requestMap.put('appName', SimpplrContext.applicationName);
        if (String.isNotBlank(type)) requestMap.put('type', type); // type - 'add' or 'remove'
        if (googleIntegrationsUpdateMap != null && !googleIntegrationsUpdateMap.isEmpty()) requestMap.put('googleDomainListsToUpdate', googleIntegrationsUpdateMap);

        logger.logDebug('GoogleDriveSerive.saveDomainsIntegrationsConfig()----request body----' + requestMap);

        String endpoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/access-manager?action=saveGoogleDomainsIntegrationConfig';
        getResponseFromAWS(endpoint, requestMap);
    }

    public Boolean getGoogleDomainExists(String appName) {
        String queryString = 'SELECT Id, Name, Whitelist_Domain__c'
        + ' FROM App_Integration__c'
        + ' WHERE Org_Id__c = :soqlParam1'
        + ' AND Name = :soqlParam2'
        + ' ORDER BY createdDate DESC LIMIT 1';
        Map<String, Object> sqlParamMap = new Map<String, Object>();
		sqlParamMap.put('soqlParam1', SimpplrContext.simpplrOrgId);
        sqlParamMap.put('soqlParam2', appName);

        List<App_integration__c> result = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(queryString, sqlParamMap);
        String googleDomainsListString = !result.isEmpty() ? result[0].Whitelist_Domain__c : null;

        Boolean googleDomainExists = false;
        if (googleDomainsListString != null && String.isNotBlank(googleDomainsListString)) {
            List<Map<String, String>> googleDomainList = (List<Map<String, String>>)JSON.deserialize(googleDomainsListString, List<Map<String, String>>.class);
            googleDomainExists = (googleDomainList.size() > 0);
        }

        return googleDomainExists;
    }

    @future(callout=true)
    public static void startGoogleMultiInstanceUpgradeFlow(Boolean retainGoogleGroups, List<String> chattergroupIds) {
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('orgId', UserInfo.getOrganizationId());
        requestMap.put('peopleId', UserContext.peopleId);
        requestMap.put('userId', UserContext.Id);
        requestMap.put('appName', SimpplrContext.applicationName);
        requestMap.put('retainGoogleGroups', retainGoogleGroups);
        if (retainGoogleGroups == false) requestMap.put('chattergroupIds', chattergroupIds);
        requestMap.put('upgradeStage', 'adddomainconfig');
        String allCompanyGroupEmail = SimpplrContext.simpplrOrgId;
        if(SimpplrContext.Integrations.containsKey(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING)){
            String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
            if (SimpplrContext.googleManagedPermission){
                requestMap.put('permission', 'googlemanage');
                requestMap.put('allCompanyGroupId', allCompanyGroupEmail +'_sfgm@' + domainStr);
            } else {
                requestMap.put('permission', 'simpplrmanage');
                requestMap.put('allCompanyGroupId', allCompanyGroupEmail +'_sfsm@' + domainStr);
                requestMap.put('allCompanyGroupGoogleId', allCompanyGroupEmail +'_sfgm@' + domainStr);
            }
        }
        String endpoint = SimpplrContext.simpplrAPIEndpoint +'/gsuite/access-manager?action=startGoogleMultiInstanceUpgradeFlow';
        Utility.getResponseFromAWS(endpoint, requestMap);
    }

    public void deleteAllGoogleGroups(List<String> chattergroupIds) {
        String endpointURL = SimpplrContext.simpplrAPIEndpoint + '/oauth/google-oauth-manager?action=deleteAllGoogleGroups';
        Map<String, Object> mapOfRequestParam = new Map<String, Object>();
        mapOfRequestParam.put('orgId', SimpplrContext.simpplrOrgId);
        mapOfRequestParam.put('peopleId', UserContext.peopleId);
        mapOfRequestParam.put('userId', UserContext.userId);
        mapOfRequestParam.put('chattergroupIds', chattergroupIds);
        String allCompanyGroupEmail = SimpplrContext.simpplrOrgId;
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
        // delete all the groups created with simpplr managed permission
        mapOfRequestParam.put('permission', 'simpplrmanage');
        mapOfRequestParam.put('allCompanyGroupId', allCompanyGroupEmail +'_sfsm@' + domainStr);
        mapOfRequestParam.put('allCompanyGroupGoogleId', allCompanyGroupEmail +'_sfgm@' + domainStr);

        logger.logDebug('GoogleDriveSerive.deleteAllGoogleGroups()----request body----' + mapOfRequestParam);
        getResponseFromAWS(endpointURL, mapOfRequestParam);  
    }

    public static String validateGoogleMultiDomainStatus(){
        String status = ServiceConstants.UPGRADE_STATUS_IN_PROGRESS;
        try{
            String query = 'SELECT Google_Multi_Domain_Upgrade_Status__c from App_Config__c LIMIT 1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            App_Config__c appConfig = ((List<App_config__c>)SIMPESAPI.accessController().queryAsUser(query, null))[0];
            if(String.isNotBlank(appConfig.Google_Multi_Domain_Upgrade_Status__c)){
                status =  appConfig.Google_Multi_Domain_Upgrade_Status__c;
            }
            return status;
        }
        catch(Exception ex){
            return status;
        }
    }

    public static Boolean googleMultiDomainUpgraded(){
        Boolean status = (SimpplrContext.isGoogleMultiDomainUpgraded ||  
        ( GoogleDriveService.validateGoogleMultiDomainStatus().equalsIgnoreCase(ServiceConstants.UPGRADE_STATUS_COMPLETED) && SimpplrContext.isGoogleMultiDomainEnabled));
        return status;
    }

}