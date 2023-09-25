/**
* @Class [Class Name] 
* @Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public without sharing class ManageSiteDataServer extends DataServer{
    public transient final String STR_ERROR_DUPLICATE_FLASH { get { return labelMap.get('manage_site.duplicate_error_flash');}}
    public transient final String STR_ERROR_WEBHOOK { get { return labelMap.get('manage_site.outlook_webhook_error_flash');}}
    public transient final String STR_ERROR_PRIVILEGE_SITE_OWNER { get { return labelMap.get('manage_app.setup.privileges.site_owner');}}
    public transient final String STR_SLACK_RECONNECT_ACCOUNT { get { return labelMap.get('manage_site.apps.reconnect_account');}}
    public transient final String STR_UNABLE_TO_LOCK_ROW_ERROR {get { return labelMap.get('manage_site.unable_to_lock_row_error_message') ;}}
    public transient final String STR_BLANK_SLACK_CHANNEL_ERROR {get { return labelMap.get('manage_site.slack.blank_slack_channel') ;}}
	/**
	 * @description error message when Site owner tries to remove user part of mandatory subscrition audience
	 * @return String
	 */	    
    public transient final String STR_ERROR_MANDATORY_USER_REMOVE { get { return labelMap.get('manage_site.mandatory_subscription_remove');}}

    public transient final String STR_KEY_SITE_DUPLICATE_NAME_NOT_ALLOWED {get {return labelMap.get('manage_sites.duplicate_site_name_error_message');}}

    public static final String STATUS_APPROVED='Approved';
    
    private final String ACTION_SET_PERMISSION = 'setPeoplePermission';
    private final String ACTION_MAKE_MANAGER = 'makeManager';
    private final string ACTION_MAKE_CONTENT_MANAGER= 'makeContentManager';
    private final String ACTION_MAKE_OWNER = 'makeOwner';
    private final String ACTION_MAKE_MEMBER = 'makeMember';
    private final String ACTION_MAKE_FOLLOWER = 'makeFollower';
    private final String ACTION_REMOVE = 'removeMember';
    private final String ACTION_REMOVE_PEOPLE = 'removePeople';
    private final String ACTION_ADD_MEMBER='addMember';
    private final String ACTION_ADD_PEOPLE  = 'addPeople';
    private final String ACTION_SAVE_SITE_DETAIL = 'saveSiteDetail';
    private final String ACTION_SAVE_SITE_EXTERNAL_APPS_CONFIG = 'saveSiteExternalAppsConfig';
    private final String ACTION_GET_SITE_EXTERNAL_APPS_CONFIG = 'getExternalAppsSettings';
    private final String ACTION_DISCONNECT_APP = 'disconnectApp';
    private final String ACTION_TRANSFER_ACCOUNT = 'transferAccount';
    
    private final String SITE_PER_USER_LIMIT_EXCEEDED_ERR_MSG = 'Unable to update site cover image. Please unfollow a site and try again';
    private final String EXISTING_GROUP_UNLISTED_ERR_MSG = 'You can\'t make existing group unlisted.';
    private final String UNLISTED_SITE_SAME_NAME ='A Site already exists with this name - please change the name and try again.'; 
    private final String REQUEST_PARAM_DATA = 'data';
    private final String SLACK_CHANNEL_NOT_FOUND = 'channel_not_found';
    
    public ManageSiteDataServer() {

    }

    public String getPageFeature() {
        return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest(){
        try{
            logger.logDebug('ManageSiteDataServer----entered handleRequest----');
            String action = readParam(REQUEST_PARAM_ACTION);
            
            if(String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if((AccessManager.USER_ROLE_MEMBER).equalsIgnoreCase(UserContext.primaryRole)) {
                //throw new SimpplrException(ExceptionCode.INVALID_USER_ID.name());
            }
            if(ACTION_SET_PERMISSION.equalsIgnoreCase(action)){
                Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(readParam(REQUEST_PARAM_DATA));
                String permission = requestMap.get('permission') != null ? String.valueOf(requestMap.get('permission')) : '';
                if('owner'.equalsIgnoreCase(permission)){
                    action = 'makeOwner' ; 
                } else if('manager'.equalsIgnoreCase(permission)){
                    action = 'makeManager';
                } else if('contentManager'.equalsIgnoreCase(permission)){
                    action = 'makeContentManager';
                } else if('member'.equalsIgnoreCase(permission)){
                    action = 'makeMember';
                } else if('follower'.equalsIgnoreCase(permission)){
                    action = 'makeFollower';
                } else if('removePeople'.equalsIgnoreCase(permission)){
                    action = 'removePeople';
                }
            }
            if(ACTION_SAVE_SITE_DETAIL.equalsIgnoreCase(action)) {
                response = saveSiteDetail(readParam(REQUEST_PARAM_DATA));
                
            }else if(ACTION_MAKE_CONTENT_MANAGER.equalsIgnoreCase(action)){
                response = makeContentManager(readParam(REQUEST_PARAM_DATA));
                
            }else if(ACTION_MAKE_MANAGER.equalsIgnoreCase(action)){
                response = addMemberToManagerGroup(readParam(REQUEST_PARAM_DATA));
            
            }else if(ACTION_MAKE_OWNER.equalsIgnoreCase(action)){
                response = makeOwner(readParam(REQUEST_PARAM_DATA));
                
            }else if(ACTION_MAKE_FOLLOWER.equalsIgnoreCase(action)){
                response = makeFollower(readParam(REQUEST_PARAM_DATA));
                
            }else if(ACTION_MAKE_MEMBER.equalsIgnoreCase(action)){
                response = removeMemberFromManagerGroup(readParam(REQUEST_PARAM_DATA));
                
            }else if(ACTION_REMOVE.equalsIgnoreCase(action)){
                response = removeMember(readParam(REQUEST_PARAM_DATA));
                
            } else if(ACTION_REMOVE_PEOPLE.equalsIgnoreCase(action)){
                response = removeMember(readParam(REQUEST_PARAM_DATA));
                
            } else if (ACTION_ADD_MEMBER.equalsIgnoreCase(action)){
                response = addMember(readParam(REQUEST_PARAM_DATA));
                
            } else if (ACTION_ADD_PEOPLE.equalsIgnoreCase(action)){
                response = addPeople(readParam(REQUEST_PARAM_DATA));
                
            } else if (ACTION_GET_SITE_EXTERNAL_APPS_CONFIG.equalsIgnoreCase(action)){
                response = getExternalAppsSettings();

            } else if (ACTION_SAVE_SITE_EXTERNAL_APPS_CONFIG.equalsIgnoreCase(action)){
                response = saveSiteExternalAppsConfig(readParam(REQUEST_PARAM_DATA));

            } else if(ACTION_DISCONNECT_APP.equalsIgnoreCase(action)){
                response = disconnectApp(readParam('siteId'), readParam('appName'));
            
            } else if(ACTION_TRANSFER_ACCOUNT.equalsIgnoreCase(action)){
                response = transferAccount(readParam(REQUEST_PARAM_DATA));
            
            } else{
                throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
            
        }catch(Exception ex){
            logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR,MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }
    
    @TestVisible
    private ResponseWrapper makeContentManager(String requestData){
        logger.logDebug('ManageSiteDataServer.makeContentManager()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
            GroupMemberParams params= (GroupMemberParams)Json.deserialize(requestData,GroupMemberParams.class);
            SiteDao siteDaoObj = new SiteDao();
            List<Site_Role__c> siteRoleList = [Select id, Is_Content_Manager__c , Is_Manager__c 
                                    FROM Site_Role__c 
                        WHERE People__r.User__c =: params.sfUserId and Site__c = :params.siteId and Is_Deleted__c = false];
            // remove as site manager 
            removeMemberFromManagerGroup(requestData);
            if(!siteRoleList[0].Is_Manager__c && SimpplrContext.isnativeVideo){
                VideoDao.addManagerToGroup(params.siteId, params.sfUserId);   
            }
            // add as content manager
            RecursionCheck.allowToRun();
            siteDaoObj.assignSiteRoles(params.siteId, params.sfUserId, 'contentManager', false, true);
            
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            NotificationDispatcher.sendNotificationForMakeManager(params.sfUserId, params.siteId, 'Made_Site_Content_Manager');
            
        }catch( Exception e){
            logger.logError('ManageSiteDatoaServer------could not make content manager',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('ManageSiteDataServer.makeContentManager()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    @TestVisible 
    private ResponseWrapper addMemberToManagerGroup(String requestData){
        logger.logDebug('ManageSiteDataServer.addMemberToManagerGroup()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
            GroupMemberParams params= (GroupMemberParams)Json.deserialize(requestData,GroupMemberParams.class);
            
            String collabGroupId= SiteContext.currentChatterGroup.Id;
            
            //Member will be added to RWGroup only in Simpplr managed case
            if (SiteContext.fileStorageSource == 'googledrive' && !SimpplrContext.googleManagedPermission) {
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', params.sfUserId);
                soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
                String queryStr = 'SELECT id, name, user_email__c,  '+
                        ' user__c'+
                        ' FROM People_Integration__c '+
                        ' WHERE user__c =:soqlParam1 AND '+
                        ' name=:soqlParam2';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
                if (!listOfPeopleInteg.isEmpty()) {
                    String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
                    String groupKey = collabGroupId + GoogleDriveService.READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                    String memberKey = listOfPeopleInteg[0].user_email__c;
                    String response = new GoogleDriveService().addMemberToGroup(groupKey, memberKey);
                }

            }

            SiteDao siteDaoObj = new SiteDao();
            if(SimpplrContext.isNativeVideo) {
                List<Site_Role__c> siteRoleList = [Select id, Is_Content_Manager__c , Is_Manager__c
                                        FROM Site_Role__c 
                                        WHERE People__r.User__c =: params.sfUserId and Site__c = :params.siteId and Is_Deleted__c = false];
                if(!siteRoleList[0].Is_Content_Manager__c){
                    VideoDao.addManagerToGroup(params.siteId, params.sfUserId);
                }
            }
            // add as site manager
            RecursionCheck.stopRecursion();
            siteDaoObj.ToggleMemberManager(collabGroupId,params.sfUserId,'Admin');
            // remove as content manager
            
            RecursionCheck.allowToRun(); 
            siteDaoObj.assignSiteRoles(params.siteId, params.sfUserId, 'manager', true, false);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            NotificationDispatcher.sendNotificationForMakeManager(params.sfUserId, params.siteId, 'Made_Site_Manager');
        } catch (Exception e) {
            logger.logError('ManageSiteDataServer------could not make member manager',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('ManageSiteDataServer.addMemberToManagerGroup()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    @TestVisible 
    private ResponseWrapper makeOwner(String requestData){
        logger.logDebug('ManageSiteDataServer.makeOwer()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        
        try{
            // Throw Error when EFS Batch is running
            if(SimpplrContext.connectedStorages.contains(SiteContext.fileStorageSource) && SimpplrContext.Integrations.get(SiteContext.fileStorageSource).Batch_Processing__c){
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR,STR_UNABLE_TO_LOCK_ROW_ERROR, null);
            } else if(!SiteContext.isCurrentUserSiteOwner && !UserContext.isUserAppModerator){
                throw new SimpplrException(ServiceConstants.ERROR_403);
            } else{
                GroupMemberParams params= (GroupMemberParams)Json.deserialize(requestData,GroupMemberParams.class);
                
                String collabGroupId= SiteContext.currentChatterGroup.Id;
                
                if (SiteContext.fileStorageSource == 'googledrive' && !SimpplrContext.googleManagedPermission) {
                    Map<String, Object> soqlParamMap1 = new Map<String, Object>();
                    soqlParamMap1.put('soqlParam1', params.sfUserId);
                    soqlParamMap1.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
                    String queryStr = 'SELECT id, user_email__c,  user__c'+
                            ' FROM People_Integration__c '+
                            ' WHERE user__c =:soqlParam1 AND '+
                            ' name=:soqlParam2';
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap1);
                    if (!listOfPeopleInteg.isEmpty()) { 
                        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
                        String groupKey = collabGroupId + GoogleDriveService.READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                        String memberKey = listOfPeopleInteg[0].user_email__c;
                        String response = new GoogleDriveService().addMemberToGroup(groupKey, memberKey);
                    
                    } else {
                        Map<String, Object> soqlParamMap = new Map<String, Object>();
                        soqlParamMap.put('soqlParam1', params.siteId);
                        String folderQuery = 'SELECT Id, Type__c, Site__c, ' +
                            ' Site__r.Site_Type__c, EFS_All_Company_Collaboration_Id__c, ' +
                            ' EFS_Search_Collaboration_Id__c, Is_system_folder__c, ' +
                            ' External_Folder_Id__c ,EFS_Read_Collaboration_Id__c, ' +
                            ' EFS_Read_Write_Collaboration_Id__c ' +
                            ' FROM folder__C ' +
                            ' WHERE type__C=\'googledrive\' AND site__c=:soqlParam1';
                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                        List<Folder__c> listOfLinkedFolder = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);

                        List<GoogleDriveModel.RemovePermissionReq> listOfFolderWithPermission = new List<GoogleDriveModel.RemovePermissionReq>();
                        
                        for (Folder__c folderObj : listOfLinkedFolder) {

                            // System folder don't exist in google 
                            if (!folderObj.Is_system_folder__c) {
                                
                                // For public site removing all company group permission
                                if ('public'.equalsIgnoreCase(folderObj.Site__r.Site_Type__c)) {
                                    GoogleDriveModel.RemovePermissionReq pubReqObj = new GoogleDriveModel.RemovePermissionReq();
                                    pubReqObj.folderId = folderObj.External_folder_id__c;
                                    pubReqObj.permissionId = folderObj.EFS_All_Company_Collaboration_Id__c;
                                    listOfFolderWithPermission.add(pubReqObj);
                                } 

                                // For every folder removing search group permission
                                GoogleDriveModel.RemovePermissionReq reqObj = new GoogleDriveModel.RemovePermissionReq();
                                reqObj.folderId = folderObj.External_folder_id__c;
                                reqObj.permissionId = folderObj.EFS_Search_Collaboration_Id__c;
                                listOfFolderWithPermission.add(reqObj);

                                // For every folder removing admin group permission
                                GoogleDriveModel.RemovePermissionReq rReqObj = new GoogleDriveModel.RemovePermissionReq();
                                rReqObj.folderId = folderObj.External_folder_id__c;
                                rReqObj.permissionId = folderObj.EFS_Read_Collaboration_Id__c;
                                listOfFolderWithPermission.add(rReqObj);

                                // For every folder removing admin group permission
                                GoogleDriveModel.RemovePermissionReq rWReqObj = new GoogleDriveModel.RemovePermissionReq();
                                rWReqObj.folderId = folderObj.External_folder_id__c;
                                rWReqObj.permissionId = folderObj.EFS_Read_Write_Collaboration_Id__c;
                                listOfFolderWithPermission.add(rWReqObj);
                            }

                            
                        }
                       
                        Boolean responseFlag = new GoogleDriveService().removePermissionsFromFolders(listOfFolderWithPermission);
                        responseFlag = new GoogleDriveService().deleteSiteGroups(collabGroupId);
                        Simpplr_Site__c siteObj = [SELECT Id, File_Storage_Source__c, 
                                Chatter_Group_Id__c, site_type__c
                                FROM Simpplr_Site__c 
                                WHERE Id =:params.siteId];
                        siteObj.File_Storage_Source__c = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;

                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                        SIMPESAPI.accessController().updateAsUser(siteObj, 
                                new List<Schema.SObjectField>{
                                    Simpplr_Site__c.File_Storage_Source__c
                                });

                        if (!listOfLinkedFolder.isEmpty()) {
                            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                            SIMPESAPI.accessController().deleteAsUser(listOfLinkedFolder);
                        }

                    }
                
                // For GSD and Google managed permissions with MyDrive
                } else if (SiteContext.fileStorageSource == 'googledrive' && SimpplrContext.googleManagedPermission) {
                    Map<String, Object> soqlParamMap1 = new Map<String, Object>();
                    soqlParamMap1.put('soqlParam1', params.sfUserId);
                    soqlParamMap1.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
                    String queryStr = 'SELECT id, user_email__c,  user__c'+
                            ' FROM People_Integration__c '+
                            ' WHERE user__c =:soqlParam1 AND '+
                            ' name=:soqlParam2';
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap1);
                    
                    if (listOfPeopleInteg.isEmpty()) { 
                        Map<String, Object> soqlParamMap = new Map<String, Object>();
                        soqlParamMap.put('soqlParam1', params.siteId);
                        String folderQuery = 'SELECT Id, Type__c, Site__c, ' +
                            ' Site__r.Site_Type__c, EFS_All_Company_Collaboration_Id__c, ' +
                            ' EFS_Search_Collaboration_Id__c, Is_system_folder__c, ' +
                            ' External_Folder_Id__c ,EFS_Read_Collaboration_Id__c, ' +
                            ' EFS_Read_Write_Collaboration_Id__c ' +
                            ' FROM folder__C ' +
                            ' WHERE type__C=\'googledrive\' AND site__c=:soqlParam1';
                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                        List<Folder__c> listOfLinkedFolder = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);

                        Simpplr_Site__c siteObj = [SELECT Id, File_Storage_Source__c, 
                                Chatter_Group_Id__c, site_type__c
                                FROM Simpplr_Site__c 
                                WHERE Id =:params.siteId];
                        siteObj.File_Storage_Source__c = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;

                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                        SIMPESAPI.accessController().updateAsUser(siteObj, 
                                new List<Schema.SObjectField>{
                                    Simpplr_Site__c.File_Storage_Source__c
                                });

                        if (!listOfLinkedFolder.isEmpty()) {
                            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                            SIMPESAPI.accessController().deleteAsUser(listOfLinkedFolder);
                        }

                    }

                }
                People_Integration__c pplInteg = UserContext.Integrations.get(SiteContext.fileStorageSource);
                if (pplInteg != null) {
                    PeopleDao peopleDaoObj = new PeopleDao();
                    String peopleId = '';
                    List<People__c> newOwnerPeopleList = new List<People__c>();
                    newOwnerPeopleList = peopleDaoObj.getPeopleByUserId(params.sfUserId);
                    if(newOwnerPeopleList <> NULL && newOwnerPeopleList.size() > 0){
                        peopleId = newOwnerPeopleList[0].Id;
                    }else{
                        peopleId = pplInteg.People__c;
                    }

                    Map<String, Object> soqlParamMap = new Map<String, Object>();
                    soqlParamMap.put('soqlParam1', ServiceConstants.STORAGE_TYPE_INTRANET_STRING);
                    soqlParamMap.put('soqlParam2', params.siteId);
                    String folderQuery = 'SELECT Id, Type__c, Site__c, ' +
                        ' Site__r.Site_Type__c, EFS_All_Company_Collaboration_Id__c, ' +
                        ' EFS_Search_Collaboration_Id__c, Is_system_folder__c, ' +
                        ' External_Folder_Id__c ,EFS_Read_Collaboration_Id__c, ownerId, ' +
                        ' EFS_Read_Write_Collaboration_Id__c, Is_External_System_Folder__c ' +
                        ' FROM folder__C ' +
                        ' WHERE type__c!=:soqlParam1 AND site__c=:soqlParam2 AND Is_system_folder__c=true';
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    List<Folder__c> listOfLinkedFolder = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
                    if (listOfLinkedFolder != null && listOfLinkedFolder.size() > 0) {
                        for (Folder__c folderObj : listOfLinkedFolder)  {
                            folderObj.ownerId = params.sfUserId;
                            folderObj.People__c = peopleId;
                        }
                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                        SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfLinkedFolder), 
                                    new List<Schema.SObjectField>{
                                        Folder__c.ownerId,
                                        Folder__c.People__c
                                    });
                    }
                }

                Boolean respFlag = false;
                SiteDao siteDaoObj = new SiteDao();
                List<Site_Role__c> siteRoleList = [Select id, Is_Content_Manager__c , Is_Manager__c, site__r.Chatter_Group_Id__C
                        FROM Site_Role__c 
                        WHERE People__r.User__c =: params.sfUserId and Site__c = :params.siteId and Is_Deleted__c = false];
                Boolean isManager = false;
                
                if(siteRoleList[0].Is_Content_Manager__c || siteRoleList[0].Is_Manager__c){
                    isManager = true; 
                }
                if(SimpplrContext.isNativeVideo) {
                    CollaborationGroup colGroupObj = [SELECT id,OwnerId from CollaborationGroup WHERE Id =:collabGroupId];
                    String prevOwnerId = colGroupObj.OwnerId;
                    VideoDao.makeOwner(params.siteId, params.sfUserId, isManager, prevOwnerId);
                }
                RecursionCheck.stopRecursion();
                List<String> siteRoleIdsList = new List<String>();
                List<collaborationGroup> listOfCollbGrp = [SELECT id, ownerId, name 
                        FROM collaborationGroup 
                        WHERE id =:siteRoleList[0].site__r.Chatter_Group_Id__c];
                String userId = String.ValueOf(listOfCollbGrp[0].ownerId);
                List<Site_Role__c> oldOwnerSiteRole = [SELECT id, People__c, People__r.User__c FROM Site_Role__c
                        WHERE Site__c =: siteRoleList[0].site__c AND Is_Deleted__c = false];
                for(Site_Role__c siteRoleObj : oldOwnerSiteRole) {
                    if(((String)siteRoleObj.People__r.User__c).equalsIgnoreCase(listOfCollbGrp[0].OwnerId)) {
                        siteRoleIdsList.add(siteRoleObj.id);
                    }
                }
                 
                // add as site manager
                siteDaoObj.ToggleMemberManager(collabGroupId,params.sfUserId,'Admin');
                
                // make owner
                siteDaoObj.makeOwner(collabGroupId,params.sfUserId);

                // remove as content manager
                siteDaoObj.assignSiteRoles(params.siteId, params.sfUserId, '', true, false);
            
                if(SimpplrContext.isFeatureEnabled('Full_External_Search')) {   
                    List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                    fieldList.add(External_Search_Data_Trail__c.Site_Role__c);
                    fieldList.add(External_Search_Data_Trail__c.Type__c);

                    //Don't combine the below methhod
                    // sending request to elastic for new user           
                    External_Search_Data_Trail__c newOwnerExternalSearchDataTrailObj= new External_Search_Data_Trail__c();
                    newOwnerExternalSearchDataTrailObj.Site_Role__c = siteRoleList[0].id;
                    newOwnerExternalSearchDataTrailObj.Type__c = 'Site_Role';
                    
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().insertAsUser(newOwnerExternalSearchDataTrailObj, fieldList);

                    // sending request to elastic for old user    
                    External_Search_Data_Trail__c oldOwnerExternalSearchDataTrailObj = new External_Search_Data_Trail__c();
                    oldOwnerExternalSearchDataTrailObj.Site_Role__c = siteRoleIdsList[0];
                    oldOwnerExternalSearchDataTrailObj.Type__c = 'Site_Role';
                    
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    SIMPESAPI.accessController().insertAsUser(oldOwnerExternalSearchDataTrailObj, fieldList);
                }
                
                
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
                NotificationDispatcher.sendNotificationForMakeOwner(params.sfUserId, params.siteId);
            }
        } catch (Exception e) {
            String errorMessage = '';
            if(String.isNotBlank(e.getMessage()) && e.getMessage().containsIgnoreCase('INVALID_CROSS_REFERENCE_KEY')){
                errorMessage = STR_ERROR_PRIVILEGE_SITE_OWNER;
            } else{
                errorMessage = e.getMessage();
            }

            logger.logError('ManageSiteDataServer------could not change owner', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errorMessage, null);
        }
        logger.logDebug('ManageSiteDataServer.makeOwer()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper removeMemberFromManagerGroup(String requestData){
        logger.logDebug('ManageSiteDataServer.removeMemberFromManagerGroup()----requestData----' + requestData);
        ResponseWrapper responseWrapperObj = null;
        List<PeopleListWrapper> peopleList = null;
        PeopleListWrapper peopleObj = null; 
        
        try {
            GroupMemberParams params = (GroupMemberParams)Json.deserialize(requestData, 
                    GroupMemberParams.class);
            String collabGroupId = SiteContext.currentChatterGroup.Id;
            List<Site_Role__c> siteRoleList = [Select id, Is_Content_Manager__c , Is_Manager__c, Is_Member__c
            FROM Site_Role__c 
            WHERE People__r.User__c =: params.sfUserId and Site__c = :params.siteId and Is_Deleted__c = false];
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
            String permission = requestMap.get('permission') != null ? String.valueOf(requestMap.get('permission')) : '';            

            // Member will be removed from RWGroup in both case Simp/Google Managed permissions
            if (SiteContext.fileStorageSource == 'googledrive') {
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', params.sfUserId);
                soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
                String queryStr = 'SELECT id, user_email__c,  user__c'+
                        ' FROM People_Integration__c '+
                        ' WHERE user__c =:soqlParam1 AND '+
                        ' name=:soqlParam2';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

                if (!listOfPeopleInteg.isEmpty()) {
                    String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
                    String groupKey = collabGroupId + GoogleDriveService.READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                    String memberKey = listOfPeopleInteg[0].user_email__c;
                    String response = new GoogleDriveService().removeMemberFromGroup(groupKey, memberKey);
                }

            }
            if(SimpplrContext.isnativeVideo && (siteRoleList[0].Is_Content_Manager__c || siteRoleList[0].Is_Manager__c) && !permission.equalsIgnoreCase('contentManager')){
                VideoDao.removeManagerFromGroup(params.siteId, params.sfUserId);
            }

            SiteDao siteDaoObj = new SiteDao();

            // remove as content manager
            RecursionCheck.stopRecursion();
        
            siteDaoObj.assignSiteRoles(params.siteId, params.sfUserId, '', false, false);
            // remove as site manager
            Boolean isToggleMemberManagerSuccess = siteDaoObj.ToggleMemberManager(collabGroupId,params.sfUserId,'Standard');
            
            Criteria.People criteriaPeopleObj = new Criteria.People();
            criteriaPeopleObj.siteId = SiteContext.siteId;
            criteriaPeopleObj.offset = 0;
            
            if(isToggleMemberManagerSuccess) {
                peopleList = PeopleContentProvider.getSitesMembersEveryone(criteriaPeopleObj, new List<String> {params.sfUserId});
                if(peopleList != null && !peopleList.isEmpty()) {
                    peopleObj = peopleList[0];
                }

                Simpplr_Site__c siteObj = [Select Id, Site_Type__c, Name From Simpplr_Site__c Where Id = :params.siteId];
                List<People__c> listOfPeople = [Select Id, Joining_Date__c From People__c Where User__c = :params.sfUserId];
                
                if(siteObj.Site_Type__c == 'Public') {
                    Map<String, Object> soqlParamMap = new Map<String, Object>();
                    soqlParamMap.put('soqlParam1', siteObj.Id);
                    soqlParamMap.put('soqlParam2', listOfPeople[0].Id);
                    String query = 'SELECT Id, Request_By__c, Site__c, Status__c FROM Site_Membership_Request__c Where Status__c = \'Pending\' AND Site__c = :soqlParam1 AND Request_By__c = :soqlParam2';
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    List<Site_Membership_Request__c> membershipRequestList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
                    
                    if(!membershipRequestList.isEmpty()){
                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                        SIMPESAPI.accessController().deleteAsUser(membershipRequestList);
                    }
                }
                if(listOfPeople[0].Id != UserContext.peopleId && permission.equalsIgnoreCase('member')) {
                    NotificationDispatcher.sendMemberAddedNotification(String.valueOf(siteObj.Id), siteObj.Name, listOfPeople);
                    list<Simpplr_Content__c> onboardingObjList = [Select Id From Simpplr_Content__c Where Content_Onboarding_Status__c != 'none' And Site__c = :siteObj.Id AND Is_Deleted__c = false AND Is_Published__c = true];  
					if(SimpplrContext.isFeatureContentOnboardingEnabled && !onboardingObjList.isEmpty() && listOfPeople[0].Joining_Date__c != null && listOfPeople[0].Joining_Date__c.daysBetween(Date.today())<=30) {
						NotificationDispatcher.sendNewSiteOnboardingNotification(String.valueOf(siteObj.Id), siteObj.Name, listOfPeople);
						
					}
                }

            }
            List<Site_Role__c> newSiteRoleList = [Select id, Is_Content_Manager__c , Is_Manager__c, Is_Member__c
            FROM Site_Role__c 
            WHERE People__r.User__c =: params.sfUserId and Site__c = :params.siteId and Is_Deleted__c = false];
            List<External_Search_Data_Trail__c> listToInsert = new List<External_Search_Data_Trail__c>();

            if(SimpplrContext.isFeatureEnabled('Full_External_Search') && permission != null && !'contentManager'.equalsIgnoreCase(permission)) {
	    		External_Search_Data_Trail__c obj = new External_Search_Data_Trail__c();
	    		obj.Site_Role__c = newSiteRoleList[0].Id;
	    		obj.Type__c = 'Site_Role';
	    		listToInsert.add(obj);

                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().insertAsUser(listToInsert, new List<Schema.SObjectField>{
                    External_Search_Data_Trail__c.Site_Role__c,
                    External_Search_Data_Trail__c.Type__c
                });
            }
            
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleObj);
            
        } catch (Exception e) {
            logger.logError('ManageSiteDataServer------could not make manager a member',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('ManageSiteDataServer.removeMemberFromManagerGroup()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    @TestVisible
    private ResponseWrapper removeMember(String requestData){
        logger.logDebug('ManageSiteDataServer.removeMember()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try { 
            GroupMemberParams params= (GroupMemberParams)Json.deserialize(requestData,GroupMemberParams.class);
            if(SiteContext.siteHasMandatorySubscription) {
                Set<Id> mandatorySubscriptionAudienceIdSet = SiteContext.mandatorySubscriptionAudienceIdSet;
                AudienceService audienceServiceObj = new AudienceService();
                Boolean isUserMemberOfAudiences =  audienceServiceObj.isUserMemberOfAudiences(params.sfUserId, mandatorySubscriptionAudienceIdSet);
                if(isUserMemberOfAudiences) {
                    PeopleDao peopleDaoObj = new PeopleDao();
                    People__c peopleToBeRemoved = peopleDaoObj.getPeopleByUserId(params.sfUserId)[0];
                    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, STR_ERROR_MANDATORY_USER_REMOVE.replace('{{name}}', peopleToBeRemoved.Full_Name__c), null);
                    return responseWrapperObj;
                }
            }
            List<Simpplr_Site__c> siteList = [SELECT Chatter_Group_Id__c FROM Simpplr_Site__c WHERE Id=:params.siteId];
            String collabGroupId = siteList.isEmpty() == false ?siteList[0].Chatter_Group_Id__c :null;

            if (SiteContext.fileStorageSource == 'googledrive' && SimpplrContext.googleManagedPermission != true) {
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', params.sfUserId);
                soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
                String queryStr = 'SELECT id, user_email__c,  user__c'+
                        ' FROM People_Integration__c '+
                        ' WHERE user__c =:soqlParam1 AND '+
                        ' name=:soqlParam2';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

                if (!listOfPeopleInteg.isEmpty()) {
                    String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
                    String groupKey = collabGroupId + GoogleDriveService.READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                    String memberKey = listOfPeopleInteg[0].user_email__c;
                    String response = new GoogleDriveService().removeMemberFromGroup(groupKey, memberKey);
                }

            }

            SiteDao siteDaoObj = new SiteDao(); 
            siteDaoObj.removeMember(collabGroupId,params.sfUserId);
            removeMemberFromSiteRole(params.siteId, params.sfUserId);

            if(SimpplrContext.isNativeVideo) {
                VideoDao.removeUserFromGroup(SiteContext.siteId, params.sfUserId);
            }

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

        } catch (Exception e) {
            logger.logError('ManageSiteDataServer------could not remove member',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('ManageSiteDataServer.removeMember()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }
    
    @TestVisible
    private void removeMemberFromSiteRole(String siteId, String userId){
        if(String.isBlank(siteId) || String.isBlank(userId))
            return;
        
        Site_Role__c[] siteRolesToUpdate = getSiteRoleBySiteIdUserId(siteId, userId);
        if(siteRolesToUpdate!=null && siteRolesToUpdate.size()>0){
            for(Site_Role__c siteRole : siteRolesToUpdate){
                siteRole.Is_Member__c = false;
                siteRole.Is_Deleted__c = true;
                siteRole.Sync_Status__c = 0;
            }
            update siteRolesToUpdate;
        }

    }

    public Site_Role__c[] getSiteRoleBySiteIdUserId(String siteId, String userId){
        if(String.isBlank(siteId) || String.isBlank(userId))
            return null;

        return [SELECT 
                    Id,
                    Is_Member__c,
                    Is_Deleted__c
                FROM Site_Role__c 
                WHERE 
                    Site__c =: siteId AND
                    People__r.User__c =: userId];
    }

    @TestVisible 
    private ResponseWrapper addMember(String requestData){
        logger.logDebug('ManageSiteDataServer.addMember()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        List<PeopleListWrapper> peopleList = null;
        AddGroupMemberParams params;

        try {
            params = (AddGroupMemberParams)Json.deserialize(requestData, AddGroupMemberParams.class);
            String collabGroupId= SiteContext.currentChatterGroup.Id;

            //Member will be added to RGroup only when permission is Simp Managed
            if (SiteContext.fileStorageSource == 'googledrive' && SimpplrContext.googleManagedPermission != true) {
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', params.sfUserIds);
                soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
                String queryStr = 'SELECT id, user_email__c,  user__c'+
                ' FROM People_Integration__c '+
                ' WHERE user__c IN : soqlParam1 AND '+
                ' name=:soqlParam2';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<People_Integration__c> listOfPeopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);

                if (!listOfPeopleInteg.isEmpty()) {
                    String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;

                    if (listOfPeopleInteg.size() == 1) {
                        String groupKey = collabGroupId + GoogleDriveService.READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                        String memberKey = listOfPeopleInteg[0].user_email__c;
                        String response = new GoogleDriveService().addMemberToGroup(groupKey, memberKey);
                    
                    } else {
                        List<GoogleDriveModel.GroupMemberRequest> listOfGrpMemReq = new List<GoogleDriveModel.GroupMemberRequest>();

                        for (People_Integration__c peopleIntegObj: listOfPeopleInteg) {
                            GoogleDriveModel.GroupMemberRequest addRGroupMemberReq = new GoogleDriveModel.GroupMemberRequest();
                            String rGroupEmail = collabGroupId + GoogleDriveService.READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                            addRGroupMemberReq.groupEmail = rGroupEmail;
                            addRGroupMemberReq.memberEmail = peopleIntegObj.User_Email__c;
                            listOfGrpMemReq.add(addRGroupMemberReq);
                        }

                       String resultBody = new GoogleDriveService().addMembersToGroupBulk(listOfGrpMemReq);
                    }

                }
                
            }

            SiteDao siteDaoObj = new SiteDao();
            Boolean success = SiteDao.addMember(collabGroupId,params.sfUserIds);         
            Criteria.People criteriaPeopleObj = new Criteria.People();
            criteriaPeopleObj.siteId = SiteContext.siteId;
            criteriaPeopleObj.offset = 0;
            
            if(success) {
                if( params.sfUserIds != null && !params.sfUserIds.isEmpty() && params.sfUserIds.size() > 0 ) {
                    PeopleDao peopleDaoObj = new PeopleDao();
                    List<People__c> peopleObjList = peopleDaoObj.getPeopleByUserId(params.sfUserIds[0]);
                    peopleList = PeopleListWrapper.peopleListToWrapper(peopleObjList);

                    for(PeopleListWrapper peopleWrapObj : peopleList) {
                        peopleWrapObj.canRemove = true;
                        peopleWrapObj.canMakeOwner = true;
                        peopleWrapObj.canMakeManager = true;
                        peopleWrapObj.canMakeContentManager = true;
                        peopleWrapObj.canMakeNotManager = false;
                        peopleWrapObj.canMakeNotContentManager = false;
                        peopleWrapObj.isOwner = false;
                        peopleWrapObj.isManager = false;
                        peopleWrapObj.isContentManager = false;
                    }
                }
            }

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleList);
            responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.ManageSitesMembers)+'?siteId=' + SiteContext.siteId + '&ts=' + dateTime.now().getTime();
        } catch (Exception e) {
            logger.logError('ManageSiteDataServer------could not add member',e);
            String errorMessage = e.getMessage();
            if(errorMessage.containsIgnoreCase('DUPLICATE_VALUE')) {
                if(params != null && params.sfUserIds != null && params.sfUserIds.size() > 1) {
                    errorMessage = 'It\'s not possible to add duplicate Site Members';
                } else if (params != null && params.sfUserIds != null && params.sfUserIds.size() == 1){
                    errorMessage = 'It\'s not possible to add duplicate Site Members';
                }
            } else if(errorMessage.containsIgnoreCase('Maximum per user active group limit reached')) {
                errorMessage = 'User has reached Site limit. It\'s not possible for them to be member of more Sites';
            }
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
            responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.ManageSitesMembers)+'?siteId=' + SiteContext.siteId + '&ts=' + dateTime.now().getTime();
        }
        logger.logDebug('ManageSiteDataServer.addMember()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    public ResponseWrapper addPeople(String requestData){
        logger.logDebug('ManageSiteDataServer.addPeople()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        
        if(!(SiteContext.isCurrentUserSiteManager || SiteContext.isCurrentUserSiteOwner || UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission)
             && !(SiteContext.isUnlistedSite && UserContext.hasManageUnlistedSitePermission)) {
            throw new SimpplrException(ServiceConstants.ERROR_403);
        }
        
        List<PeopleListWrapper> peopleList = null;
        SiteWrapper.AddPeopleParams params;
        List<String> userIds = new List<String>();

        Map<Id, Site_Membership_Request__c> mapofpeopleIdAndMembershipRequest = new Map<Id, Site_Membership_Request__c>();

        try {
            params = (SiteWrapper.AddPeopleParams)Json.deserialize(requestData, SiteWrapper.AddPeopleParams.class);
            
            String collabGroupId= SiteContext.currentChatterGroup.Id;

            SiteDao siteDaoObj = new SiteDao();
            Boolean success = siteDaoObj.addPeople(collabGroupId,params.userDetail);         
            Criteria.People criteriaPeopleObj = new Criteria.People();
            criteriaPeopleObj.siteId = SiteContext.siteId;
            criteriaPeopleObj.offset = 0;
            
            if(success) {
                for(SiteWrapper.UserDetail userDetailObj : params.userDetail) {
                    userIds.add(userDetailObj.sfUserId);
                    siteDaoObj.assignSiteRoles(params.siteId, userDetailObj.sfUserId, userDetailObj.membershipType, false, false);
                }
                if(SimpplrContext.isNativeVideo && userIds.isEmpty() == false) {
                    VideoDao.addUserToGroup(SiteContext.siteId, userIds);
                }
                
                Simpplr_Site__c siteObj = [Select Id, Site_Type__c, Name From Simpplr_Site__c Where Id = :params.siteId];
                list<Simpplr_Content__c> onboardingObjList = [Select Id From Simpplr_Content__c Where Content_Onboarding_Status__c != 'none' And Site__c = :params.siteId AND Is_Deleted__c = false AND Is_Published__c = true];
                if(siteObj.Site_Type__c == 'Public') {
                    Map<String, Object> soqlParamMap = new Map<String, Object>();
                    soqlParamMap.put('soqlParam1', siteObj.Id);
                    String query = 'SELECT Id, Request_By__c, Site__c, Status__c FROM Site_Membership_Request__c Where Status__c = \'Pending\' AND Site__c = :soqlParam1';
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    List<Site_Membership_Request__c> membershipRequestList = (List<Site_Membership_Request__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
			    
			        for(Site_Membership_Request__c membershipRequestObj : membershipRequestList) {
				        mapofpeopleIdAndMembershipRequest.put(membershipRequestObj.Request_By__c, membershipRequestObj);
			        }
                }

                if( userIds != null && !userIds.isEmpty() && userIds.size() > 0 ) {
                    PeopleDao peopleDaoObj = new PeopleDao();
                    List<People__c> peopleObjList = peopleDaoObj.getPeopleByUserId(userIds[0]);

                    Map<String, People_Integration__c> pplIntegrationMap = new Map<String, People_Integration__c>();
                    if(SimpplrContext.isSharepointConnected) {
                        pplIntegrationMap = PeopleContentProvider.getSharepointPeopleIntegrations(peopleObjList);
                    }
                    peopleList = PeopleListWrapper.peopleListToWrapper(peopleObjList);

                    for(PeopleListWrapper peopleWrapObj : peopleList) {
                        peopleWrapObj.canRemove = true;
                        peopleWrapObj.canMakeOwner = true;
                        peopleWrapObj.canMakeManager = true;
                        peopleWrapObj.canMakeContentManager = true;
                        peopleWrapObj.canMakeNotManager = false;
                        peopleWrapObj.canMakeNotContentManager = false;
                        peopleWrapObj.isOwner = false;
                        peopleWrapObj.isManager = false;
                        peopleWrapObj.isContentManager = false;
                        if(params.userDetail[0].membershipType == 'member') {
                            peopleWrapObj.isMember = true;
                            peopleWrapObj.isFollower = false;
                        } else {
                            peopleWrapObj.isMember = false;
                            peopleWrapObj.isFollower = true;
                        }
                        if (UserContext.spInstanceId != null && pplIntegrationMap.get(peopleWrapObj.peopleId) != null && (UserContext.spInstanceId.equals(pplIntegrationMap.get(peopleWrapObj.peopleId).SP_Instance_Id__c))) {
                            peopleWrapObj.canSPTransferOwnership = true;
                        } else {
                            peopleWrapObj.canSPTransferOwnership = false;
                        }
                        if(SimpplrContext.isSharepointConnected && pplIntegrationMap.get(peopleWrapObj.peopleId) != null) {
                            peopleWrapObj.hasConnectedSharePointAccount = pplIntegrationMap.get(peopleWrapObj.peopleId).connected__c;
                        }
                    }

                    if(params.userDetail[0].membershipType == 'member') {
                        List<People__c> listOfPeopleForNotification = new List<People__c>();
                        List<People__c> listOfPeopleForOnboardingNotification = new List<People__c>();
                        Set<String> membershipRequestIds = new Set<String>();
                        for(People__c peopleObj : peopleObjList) {
                            if(peopleObj.Id != UserContext.peopleId) {
                                listOfPeopleForNotification.add(peopleObj);
                            }

                            if(SimpplrContext.isFeatureContentOnboardingEnabled && !onboardingObjList.isEmpty() && peopleObj.Joining_Date__c != null && peopleObj.Joining_Date__c.daysBetween(Date.today())<=30) {
                                listOfPeopleForOnboardingNotification.add(peopleObj);
                            }

                            if(siteObj.Site_Type__c == 'Public') {
                                if(mapofpeopleIdAndMembershipRequest.containsKey(peopleObj.Id)){
                                    Site_Membership_Request__c siteMembershipRequestObj = mapofpeopleIdAndMembershipRequest.get(peopleObj.Id);
                                    membershipRequestIds.add(siteMembershipRequestObj.Id);
                                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                                    SIMPESAPI.accessController().deleteAsUser(siteMembershipRequestObj);
                                }
                            }

                        }

                        if(siteObj.Site_Type__c == 'Private') {
                            for(CollaborationGroupMemberRequest cgmr : [select Id from CollaborationGroupMemberRequest where CollaborationGroupId = :collabGroupId and RequesterId = :userIds[0]]) {
                                membershipRequestIds.add(cgmr.Id);
                            }
                        }
                        List<App_Notification__c> appNotiList = [SELECT Action_By__c, Action_Comment__c,Action_On__c,
                            Is_Read__c from App_Notification__c WHERE Sent_By__c IN : peopleObjList and Object_Id__c = :membershipRequestIds and Type__c = 'Actionable' and Status__c = 'Pending'];
                        for(App_Notification__c sn : appNotiList) {
                            sn.Is_Read__c = true;
                            sn.Is_New__c = false;
                            sn.Action_By__c = UserContext.peopleId;
                            sn.Action_On__c = Datetime.now();
                            sn.Action_Comment__c = 'Request approved by ' + UserContext.id;
                            sn.Status__c = STATUS_APPROVED;
                        }

                        List<Schema.SObjectField> listOfColumnsToBeUpdated = new List<Schema.SObjectField>{
                            App_Notification__c.Is_Read__c,
                            App_Notification__c.Is_New__c,
                            App_Notification__c.Action_By__c,
                            App_Notification__c.Action_On__c,
                            App_Notification__c.Action_Comment__c,
                            App_Notification__c.Status__c
                        };

                        NotificationDao.updateNotification(appNotiList, listOfColumnsToBeUpdated);

                        NotificationDispatcher.sendMemberAddedNotification(String.valueOf(siteObj.Id), siteObj.Name, listOfPeopleForNotification);

                        if(SimpplrContext.isFeatureContentOnboardingEnabled) {
                            NotificationDispatcher.sendNewSiteOnboardingNotification(String.valueOf(siteObj.Id), siteObj.Name, listOfPeopleForOnboardingNotification);
                        }
                    }

                }
            }
            
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, peopleList);
            responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.ManageSitesMembers)+'?siteId=' + SiteContext.siteId + '&ts=' + dateTime.now().getTime();
        } catch (Exception e) {
            logger.logError('ManageSiteDataServer------could not add people',e);
            String errorMessage = e.getMessage();
            if(errorMessage.containsIgnoreCase('DUPLICATE_VALUE')) {
                if(params != null && userIds != null && userIds.size() > 1) {
                    errorMessage = 'It\'s not possible to add duplicate People';
                } else if (params != null && userIds != null && userIds.size() == 1){
                    errorMessage = 'It\'s not possible to add duplicate People';
                }
            } else if(errorMessage.containsIgnoreCase('Maximum per user active group limit reached')) {
                errorMessage = 'User has reached Site limit. It\'s not possible for them to be member of more Sites';
            }
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
            responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.ManageSitesMembers)+'?siteId=' + SiteContext.siteId + '&ts=' + dateTime.now().getTime();
        }
        logger.logDebug('ManageSiteDataServer.addMember()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper saveSiteDetail(String requestData){
        logger.logDebug('ManageSiteDataServer.saveSiteDetail()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try {
            SiteDetailWrapper siteDetailsObj = (SiteDetailWrapper)Json.deserialize(requestData, SiteDetailWrapper.class);
            logger.logDebug(siteDetailsObj);
            Simpplr_Site__c existingSiteObj = [SELECT Id, name, Title_Content_Version__c, 
                    Title_Content_Document__c, Is_Featured__c, File_Storage_Source__c, Question_Answer_Enabled__c,
                    Chatter_Group_Id__c, site_type__c, Is_Membership_Auto_Approved__c,
                    (Select Id, People__c, Is_Manager__c FROM Site_Roles__r WHERE People__c = :UserContext.peopleId AND Is_Deleted__c = false)
                    FROM Simpplr_Site__c 
                    WHERE Id =:siteDetailsObj.siteId];

            List<Site_Role__c> userRoleInSite = existingSiteObj.Site_Roles__r;

            Boolean hasSiteEditAccess = false;

            if( UserContext.hasManageUnlistedSitePermission && existingSiteObj.Site_Type__c.equalsIgnoreCase(ServiceConstants.UNLISTED_SITE) ) {
                hasSiteEditAccess = true;
            } else if(
                (UserContext.isUserAppModerator && existingSiteObj.Site_Type__c.equalsIgnoreCase(ServiceConstants.PUBLIC_SITE))
                || ('Private'.equalsIgnoreCase(existingSiteObj.Site_Type__c) && UserContext.hasModifyAllDataPermission)
                || (userRoleInSite.isEmpty() == false && userRoleInSite[0].Is_Manager__c == true) ) {

                hasSiteEditAccess = true;
            }
                        
            if(hasSiteEditAccess == false) {
                throw new SimpplrException(ServiceConstants.ERROR_403);
            }    
            
            if (ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(existingSiteObj.File_Storage_Source__c) &&
                !ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(siteDetailsObj.storageProvider)) {
                 
                String siteId = siteDetailsObj.siteId;   

                EFSAccessService efsAccess = new EFSAccessService(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, false);
                EFSFileService efs = new EFSFileService(efsAccess);  
                People_Integration__c pplIntegrationObj = UserContext.integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
                efs.deleteAWSRecordForFolder(siteId, true, null, null, pplIntegrationObj.User_Name__c, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING); 

                
                FolderDao fdaoObj = new FolderDao();
                fdaoObj.unlinkAllFoldersFromSite(siteId, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
                             
            }

            if (ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(existingSiteObj.File_Storage_Source__c) &&
                !ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(siteDetailsObj.storageProvider)) {
                    String siteId = siteDetailsObj.siteId;
                    EFSAccessService efsAccess = new EFSAccessService(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, false);
                    EFSFileService efs = new EFSFileService(efsAccess);     
                    efs.deleteAWSRecordForFolder(siteId, false, '', '', '', ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);                
            }

            if(!siteDetailsObj.access.equalsIgnoreCase(existingSiteObj.site_type__c)) {
                if(siteDetailsObj.access.equalsIgnoreCase(ServiceConstants.PRIVATE_SITE) || siteDetailsObj.access.equalsIgnoreCase(ServiceConstants.UNLISTED_SITE)) {
                    Set<Id> siteIdSet = new Set<Id>();
                    siteIdSet.add(siteDetailsObj.siteId);
                    BatchManageSiteConversionActivities job = new BatchManageSiteConversionActivities(JSON.serialize(siteIdSet), existingSiteObj.site_type__c, siteDetailsObj.access);
                    Database.executeBatch(job,100);
                }
            }

            /**If storage is changed to or from GoogleDrive */
            if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(siteDetailsObj.storageProvider) || 
                    existingSiteObj.File_Storage_Source__c == ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING) {
                
                // Any other to google
                if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(siteDetailsObj.storageProvider) &&  
                        existingSiteObj.File_Storage_Source__c != ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING ) {

                    // Create group and add member in case of Simpplr managed only 
                    if (!SimpplrContext.googleManagedPermission) {
                        new GoogleDriveService().createSiteGroups(existingSiteObj.Chatter_Group_Id__c, existingSiteObj.name);
                        BatchGoogleDriveSync job = new BatchGoogleDriveSync('addMembersToGoogleGroup', false, existingSiteObj.Chatter_Group_Id__c);
                        Database.executeBatch(job, 200);
                    }
                   
                    new GoogleDriveHelper().createSiteRootFolder(existingSiteObj.id);
                            
                // Google to any other
                } else if (!ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(siteDetailsObj.storageProvider) &&  
                        existingSiteObj.File_Storage_Source__c == ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING) {
                    
                    // Remove permissions for folders linked for public and search group. 
                    Map<String, Object> soqlParamMap = new Map<String, Object>();
                    soqlParamMap.put('soqlParam1', existingSiteObj.id);
                    String folderQuery = 'SELECT Id, Type__c, Site__c, ' +
                        ' Site__r.Site_Type__c, EFS_All_Company_Collaboration_Id__c, ' +
                        ' EFS_Read_Collaboration_Id__c, EFS_Read_Write_Collaboration_Id__c, ' +
                        ' EFS_Search_Collaboration_Id__c, Is_system_folder__c, ' +
                        ' External_Folder_Id__c ' +
                        ' FROM folder__C ' +
                        ' WHERE type__C=\'googledrive\' AND site__c=:soqlParam1';
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                    List<Folder__c> listOfLinkedFolder = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
                    
                    // we have to delete groups in case of Simpplr managed permssions only 
                    if (!SimpplrContext.googleManagedPermission) {
                        List<GoogleDriveModel.RemovePermissionReq> listOfFolderWithPermission = new List<GoogleDriveModel.RemovePermissionReq>();
                        
                        for (Folder__c folderObj : listOfLinkedFolder) {

                            // System folder don't exist in google 
                            if (!folderObj.Is_system_folder__c) {
                                
                                // For public site removing all company group permission
                                if ('public'.equalsIgnoreCase(folderObj.Site__r.Site_Type__c)) {
                                    GoogleDriveModel.RemovePermissionReq pubReqObj = new GoogleDriveModel.RemovePermissionReq();
                                    pubReqObj.folderId = folderObj.External_folder_id__c;
                                    pubReqObj.permissionId = folderObj.EFS_All_Company_Collaboration_Id__c;
                                    listOfFolderWithPermission.add(pubReqObj);
                                } 

                                // For every folder removing search group permission
                                GoogleDriveModel.RemovePermissionReq searchReqObj = new GoogleDriveModel.RemovePermissionReq();
                                searchReqObj.folderId = folderObj.External_folder_id__c;
                                searchReqObj.permissionId = folderObj.EFS_Search_Collaboration_Id__c;
                                listOfFolderWithPermission.add(searchReqObj);

                                // For every folder removing admin group permission
                                GoogleDriveModel.RemovePermissionReq rReqObj = new GoogleDriveModel.RemovePermissionReq();
                                rReqObj.folderId = folderObj.External_folder_id__c;
                                rReqObj.permissionId = folderObj.EFS_Read_Collaboration_Id__c;
                                listOfFolderWithPermission.add(rReqObj);

                                // For every folder removing admin group permission
                                GoogleDriveModel.RemovePermissionReq rWReqObj = new GoogleDriveModel.RemovePermissionReq();
                                rWReqObj.folderId = folderObj.External_folder_id__c;
                                rWReqObj.permissionId = folderObj.EFS_Read_Write_Collaboration_Id__c;
                                listOfFolderWithPermission.add(rWReqObj);
                            }

                            
                        }
                        
                        Boolean responseFlag = new GoogleDriveService().removePermissionsFromFolders(listOfFolderWithPermission);
                        // On site storage changed from google to anyother deleting site groups
                        responseFlag = new GoogleDriveService().deleteSiteGroups(existingSiteObj.Chatter_Group_Id__c);
                    }

                    if (!listOfLinkedFolder.isEmpty()) {
                        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                        SIMPESAPI.accessController().deleteAsUser(listOfLinkedFolder);
                    }
                    
                }

            }

             /**If site type is changing & storage is GoogleDrive permission along with SimpplrManaged*/
             if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(siteDetailsObj.storageProvider) && 
                    !siteDetailsObj.access.equalsIgnoreCase(existingSiteObj.site_type__c) && 
                    !SimpplrContext.googleManagedPermission) {
                Boolean successFlag = false;
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', existingSiteObj.id);
                String folderQuery = ' SELECT Id, name, name__C, ' +
                    ' Type__c, Site__c, Drive_type__C, ' +
                    ' EFS_All_Company_Collaboration_Id__c, ' +
                    ' Is_system_folder__c,External_folder_id__c ' +
                    ' FROM folder__C ' +
                    ' WHERE type__C=\'googledrive\' AND site__c=:soqlParam1 ' +
                    ' AND Is_System_Folder__c=false';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<Folder__c> listOfFolderToProcess = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
                Set<String> setOfExtFolderId = new Set<String>();

                if (!listOfFolderToProcess.isEmpty()) {

                    for (Folder__c folderObj : listOfFolderToProcess) {
                        setOfExtFolderId.add(folderObj.External_folder_id__c);
                    }

                    //private to public
                    if (siteDetailsObj.access.equalsIgnoreCase('public')) {
                        String publicPermissionId = new GoogleDriveService().addPublicGroupPermission(setOfExtFolderId);
                        
                        if (publicPermissionId != null) {

                            for (Folder__c folderObj : listOfFolderToProcess) {
                                folderObj.EFS_All_Company_Collaboration_Id__c = publicPermissionId;
                            }

                            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                            SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfFolderToProcess),
                                    new List<Schema.SObjectField>{
                                        Folder__c.EFS_All_Company_Collaboration_Id__c
                                    });

                        }

                    // public to private. Removing all the permissions for public group on site folders
                    } else {
                        String allCompanyGroupPermissionId = listOfFolderToProcess[0].EFS_All_Company_Collaboration_Id__c;
                        List<GoogleDriveModel.RemovePermissionReq> listOfFolderWithPermission = new List<GoogleDriveModel.RemovePermissionReq>();
                        
                        for (String extFolderId : setOfExtFolderId) {
                            GoogleDriveModel.RemovePermissionReq reqObj = new GoogleDriveModel.RemovePermissionReq();
                            reqObj.folderId = extFolderId;
                            reqObj.permissionId = allCompanyGroupPermissionId;
                            listOfFolderWithPermission.add(reqObj);
                        }

                        successFlag = new GoogleDriveService().removePermissionsFromFolders(listOfFolderWithPermission);
 
                        if (successFlag) {

                            for (Folder__c folderObj : listOfFolderToProcess) {
                                folderObj.EFS_All_Company_Collaboration_Id__c = '';
                            }

                            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                            SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(listOfFolderToProcess),
                                    new List<Schema.SObjectField>{
                                        Folder__c.EFS_All_Company_Collaboration_Id__c
                                    });

                        }

                    }

                }

            }

            if (siteDetailsObj.Category.id == null) {
                String categoryName = siteDetailsObj.Category.name.trim();
                Site_Category__c siteCategoryObj = new Site_Category__c();
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', categoryName);
                String query = 'SELECT Id, Name__c FROM Site_Category__c WHERE Name__c =:soqlParam1 AND Is_Deleted__c = false';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<Site_Category__c> listOfCategories = (List<Site_Category__c>)SIMPESAPI.accessController().queryAsUser(query, soqlParamMap);
                        
                if (!listOfCategories.isEmpty()){
                    siteDetailsObj.Category.id = listOfCategories[0].Id;
                
                } else {
                    CategoryDao catDaoObj = new CategoryDao();
                    siteCategoryObj = catDaoObj.addSiteCategory(categoryName);
                    siteDetailsObj.Category.id = siteCategoryObj.Id;
                }

            }
            if(SimpplrContext.isnativeVideo) {
                if(!siteDetailsObj.access.equalsIgnoreCase(existingSiteObj.site_type__c) && !(siteDetailsObj.access.equalsIgnoreCase('private') && existingSiteObj.site_type__c.equalsIgnoreCase('unlisted'))){
                    if(siteDetailsObj.access.equalsIgnoreCase('public')){
                        VideoDao.PrivateToPublic(siteDetailsObj.siteId,existingSiteObj.site_type__c);
                    } else if(siteDetailsObj.access.equalsIgnoreCase('private') || siteDetailsObj.access.equalsIgnoreCase('unlisted')){
                        VideoDao.PublicToPrivate(siteDetailsObj.siteId,existingSiteObj.site_type__c);
                    }
                }
                if(!siteDetailsObj.name.equalsIgnoreCase(existingSiteObj.name)){
                    VideoDao.updateCategoryName(siteDetailsObj.siteId,siteDetailsObj.name);
                }
            }
            
            SiteService service = new SiteService();
            Simpplr_Site__c siteObj = service.saveSiteDetails(siteDetailsObj);
            
            siteDetailsObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteObj.Id + '/' + siteObj.Landing_Page__c;
            
            SiteContentProvider scpObj = new SiteContentProvider();
            SiteDetailWrapper wrapperObj = scpObj.getsiteDetailData(siteDetailsObj.siteId, null);
            wrapperObj.dropboxRootPermission = String.isBlank(wrapperObj.dropboxRootPermission) ? 
                    siteDetailsObj.dropboxRootPermission : wrapperObj.dropboxRootPermission;           
            if(siteObj.Is_Membership_Auto_Approved__c && existingSiteObj.Is_Membership_Auto_Approved__c != siteObj.Is_Membership_Auto_Approved__c){
                SiteDao siteDaoObj = new SiteDao();
                Set<Id> listOfAdminUsers = siteDaoObj.getSiteManagerIdsSet(siteObj.Id);
                SiteDao.approveSiteMembershipRequests(siteObj.Id, listOfAdminUsers);
            }
            if(!Test.isRunningTest() && ((existingSiteObj.Question_Answer_Enabled__c && !siteObj.Question_Answer_Enabled__c) ||
                (ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(existingSiteObj.site_type__c) && !ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(siteObj.site_type__c)))) {

                unlinkQuestionDuplicates(siteObj.Id);
            }
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
            responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.app) +'?u=/manage/sites/' + SiteContext.siteId + '&ts=' + dateTime.now().getTime();
        }catch(Exception e){
            logger.logError('ManageSiteDataServer------could not save site details',e);
            if(e.getMessage().containsIgnoreCase('Maximum per user active group limit reached')) {
                responseWrapperObj = buildResponseWrapper('error', SITE_PER_USER_LIMIT_EXCEEDED_ERR_MSG, null);
            } else if(e.getMessage().containsIgnoreCase('INVALID_STATUS, You can\'t make an existing group unlisted.')) {
                responseWrapperObj = buildResponseWrapper('error', null, null);
            } else if(e.getmessage().containsIgnoreCase('DUPLICATE_VALUE') || e.getMessage().containsIgnoreCase(STR_KEY_SITE_DUPLICATE_NAME_NOT_ALLOWED)){
                responseWrapperObj = buildResponseWrapper('error', STR_ERROR_DUPLICATE_FLASH, null);
            } else if(e.getmessage().containsIgnoreCase('UNABLE_TO_LOCK_ROW')){
                responseWrapperObj = buildResponseWrapper('error',STR_UNABLE_TO_LOCK_ROW_ERROR , null);
            } else if(e.getmessage().containsIgnoreCase('Unable to perform action, please try again after some time.')){
                responseWrapperObj = buildResponseWrapper('error',STR_UNABLE_TO_LOCK_ROW_ERROR , null);
            } else {
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
            }
        }
        logger.logDebug('ManageSiteDataServer.saveSiteDetail()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    @future(callout=true)
    private static void unlinkQuestionDuplicates(String siteId) {
        String endpoint = '/v1/question/unlink-duplicates/'+siteId;
        if(SimpplrContext.isQuestionAnswerFeatureEnabled) {
            QuestionAnswerService.getQnARepsonseFromAWS(endpoint, 'POST', null, true);
        }
    }
    @TestVisible 
    private void createFileRecord(String cvId, ContentDocument contentDoc) {
        
        SiteDao siteDaoObj = new SiteDao();
        Map<String, Folder__c> mapOfSystemFolders4Site = siteDaoObj.getMapOfSystemFoldersForSite(SiteContext.siteId);
        Folder__c contentImagesFolder = mapOfSystemFolders4Site.get('Content Files.Images');
        
        File__c fileObj = new File__c();
        
        fileObj.Content_Version__c = cvId;
        fileObj.Url__c = Utility.getFileDownloadURL(cvId);
        fileObj.Thumbnail_URL__c = Utility.getFileDownloadURLFor720By480(cvId);
        
        if(SiteContext.isUnlistedSite == false) {
            fileObj.Folder__c = contentImagesFolder.Id;
        }
        fileObj.Content_Document__c = contentDoc.Id;
        fileObj.Title__c = contentDoc.Title;
        fileObj.Content_Name__c = contentDoc.Title;
        fileObj.Size__c = contentDoc.ContentSize;
        fileObj.MIME_Type__c = contentDoc.FileType;
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().insertAsUser(fileObj, new List<Schema.SObjectField>{
            File__c.Content_Version__c,
            File__c.Url__c,
            File__c.Thumbnail_URL__c,
            File__c.Folder__c,
            File__c.Content_Document__c,
            File__c.Title__c,
            File__c.Content_Name__c,
            File__c.Size__c,
            File__c.MIME_Type__c
        });
    }
    
    @TestVisible 
    private class GroupMemberParams {
        public String siteId;
        public String sfUserId;
        public String provider;
    }
    
    @TestVisible 
    private class AddGroupMemberParams {
        public String siteId;
        public List<String> sfUserIds;
        public String provider; 
    }

    @TestVisible 
    private ResponseWrapper getExternalAppsSettings(){
        String siteId = readParam('siteId');
        logger.logDebug('ManageSiteDataServer.getExternalAppsSettings()----siteId----' + siteId);
        ResponseWrapper responseWrapperObj = null;
        try{
            SiteService serviceObj = new SiteService();
            List<ManageSiteWrapper.SiteExternalAppWrapper> settingsWrapperList = serviceObj.getExternalAppsSettings(siteId);
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('listOfApps', settingsWrapperList);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseMap);
        }catch(Exception e){
            logger.logError('ManageSiteDataServer----Exception Occured----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper saveSiteExternalAppsConfig(String requestData){
        logger.logDebug('ManageSiteDataServer.saveSiteExternalAppsConfig()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
            Map<String, Object> trasformReqJsonObj = (Map<String,Object>)JSON.deserializeUntyped(requestData);
            ManageSiteWrapper.SiteExternalAppsWrapper siteExternalAppObj = new ManageSiteWrapper.SiteExternalAppsWrapper();
            siteExternalAppObj.siteId = (String)trasformReqJsonObj.get('siteId');
            siteExternalAppObj.slackAccessToken = (String)trasformReqJsonObj.get('slackAccessToken');
            siteExternalAppObj.slackSendFeed = (String)trasformReqJsonObj.get('slackSendFeed');
            SlackChannelsWrapper.SlackChannels channelObj = new SlackChannelsWrapper.SlackChannels();
            String channelId = (String)trasformReqJsonObj.get('channelId');
            String channelName = (String)trasformReqJsonObj.get('channelName');
            String slackChannelUrl = (String)trasformReqJsonObj.get('channelUrl');
            String microsoftTeamsWebhookURL = (String)trasformReqJsonObj.get('teamsWebhookUrl');
            siteExternalAppObj.ExternalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
            siteExternalAppObj.ExternalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(JSON.serialize(trasformReqJsonObj.get('externalAppsSiteConfig')),ManageSiteWrapper.ExternalAppsSiteConfig.class);
            
            if(siteExternalAppObj.ExternalAppsSiteConfig!=null && siteExternalAppObj.ExternalAppsSiteConfig.slackSiteConfig!=null && String.isNotBlank(siteExternalAppObj.ExternalAppsSiteConfig.SlackSiteConfig.slackConnectedAs)){
                siteExternalAppObj.slackIntegrationEnabled = true;
                siteExternalAppObj.slackSiteManager = UserContext.peopleId; 
            } else {
                siteExternalAppObj.slackIntegrationEnabled = false;
                siteExternalAppObj.slackSiteManager = null;
            }
            
            if(String.isNotBlank(channelId)){
                channelObj.id = channelId;
                channelObj.name = channelName;
                siteExternalAppObj.slackSiteManager = UserContext.peopleId; 
                siteExternalAppObj.slackChannel = channelObj;
            }   
            if(String.isNotBlank(slackChannelUrl)){
                siteExternalAppObj.slackUrl = slackChannelUrl;
                List<String> urlTokens = slackChannelUrl.split('/');
                if(urlTokens.isEmpty() == false && urlTokens.size()>4){
                    channelObj.id = urlTokens[4];
                    channelName = getSlackChannelName(UserContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE).Access_Token__c, channelObj.id);//Make a callout to channel.infor to get channel name
                    if(String.isNotBlank(channelName)){
                        channelObj.name = channelName;
                        siteExternalAppObj.slackSiteManager = UserContext.peopleId; 
                        siteExternalAppObj.slackChannel = channelObj;
                    }
                }
            }
            
            if('only-posts'.equalsIgnoreCase(siteExternalAppObj.slackSendFeed)){
                siteExternalAppObj.slackPostEnabled = true;
                siteExternalAppObj.slackCommentEnabled = false;
            }else{
                siteExternalAppObj.slackPostEnabled = true;
                siteExternalAppObj.slackCommentEnabled = true;
            }

            if(siteExternalAppObj.ExternalAppsSiteConfig!=null && siteExternalAppObj.ExternalAppsSiteConfig.MsTeamsSiteConfig!=null && String.isNotBlank(siteExternalAppObj.ExternalAppsSiteConfig.MsTeamsSiteConfig.microsoftTeamsConnectedAs)){
                siteExternalAppObj.microsoftTeamsIntegrationEnabled = true;
                siteExternalAppObj.microsoftTeamsSiteManager = UserContext.peopleId;
            } else {
                siteExternalAppObj.microsoftTeamsIntegrationEnabled = false;
                siteExternalAppObj.microsoftTeamsSiteManager = null;
            }
            siteExternalAppObj.microsoftTeamsCommentEnabled = false;
            siteExternalAppObj.microsoftTeamsWebhookURL=null;
            if(String.isNotBlank(microsoftTeamsWebhookURL)){
                siteExternalAppObj.microsoftTeamsWebhookURL = microsoftTeamsWebhookURL;
                siteExternalAppObj.microsoftTeamsIntegrationEnabled = true;
                siteExternalAppObj.microsoftTeamsSiteManager = UserContext.peopleId;
                siteExternalAppObj.teamsSendFeed = (String)trasformReqJsonObj.get('teamsSendFeed');
                if('only-posts'.equalsIgnoreCase(siteExternalAppObj.teamsSendFeed)){
                    siteExternalAppObj.microsoftTeamsCommentEnabled = false;
                } else{
                    siteExternalAppObj.microsoftTeamsCommentEnabled = true;
                }                
            }
                           
            SiteService service = new SiteService();
            service.saveSiteExternalAppsConfig(siteExternalAppObj);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null , siteExternalAppObj);
            responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.app)+'?u=/manage/sites/'+ siteExternalAppObj.siteId + '/external-apps' + '&ts=' + dateTime.now().getTime();
        } catch(Exception e){       
            String errMsg = (e instanceof SimpplrException) ? e.getMessage() : null;    
            if (errMsg.equalsIgnoreCase(SLACK_CHANNEL_NOT_FOUND)) {
                errMsg = STR_BLANK_SLACK_CHANNEL_ERROR;
            }
            logger.logError('ManageSiteDataServer----Could not save site external apps config',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errMsg, null);
        }
        logger.logDebug('ManageSiteDataServer.saveSiteExternalAppsConfig()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper transferAccount(String requestData){
        logger.logDebug('ManageSiteDataServer.transferAccount()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
            Map<String, Object> trasformReqJsonObj = (Map<String,Object>)JSON.deserializeUntyped(requestData);
            String siteId = (String)trasformReqJsonObj.get('siteId');
            String retURL = (String)trasformReqJsonObj.get('returnUrl');
            String appName = (String)trasformReqJsonObj.get('name');
            if(String.isEmpty(retURL)){
                retURL = PageContext.getPageURL(Pages.app)+'?u=/manage/sites/'+ siteId + '/external-apps' + '&ts=' + dateTime.now().getTime();
            }
            Simpplr_Site__c siteObj = [SELECT Id, External_Apps_Site_Config_Json__c FROM Simpplr_Site__c WHERE Id = :siteId];
            String redirectUrl = '';
            ManageSiteWrapper.ExternalAppsSiteConfig externalAppsSiteConfig = new ManageSiteWrapper.ExternalAppsSiteConfig();
            if(siteObj.External_Apps_Site_Config_Json__c != null){
                externalAppsSiteConfig = (ManageSiteWrapper.ExternalAppsSiteConfig)JSON.deserialize(siteObj.External_Apps_Site_Config_Json__c, ManageSiteWrapper.ExternalAppsSiteConfig.class);
            }
            if(IntegrationConstants.INTEGRATION_TYPE_MICROSOFT_TEAMS.equalsIgnoreCase(appName)){
                siteObj.Microsoft_Teams_Site_Manager__c = UserContext.peopleId;
                siteObj.Microsoft_Teams_Integration_Enabled__c = true;
                externalAppsSiteConfig.MsTeamsSiteConfig.microsoftTeamsConnectedAs = UserContext.microsoftTeamsConnectedAs;
                externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsConnectedUserId = UserContext.microsoftTeamsUserId;
                externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsChannelId = null;
                externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsChannelName = null;
                externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsTeamId = null;
                externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsTeamName = null;
                externalAppsSiteConfig.MsTeamsSiteConfig.webUrl = null;
                externalAppsSiteConfig.MsTeamsSiteConfig.msTeamsSiteFeedOptions = null;

                siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().updateAsUser(siteObj,new List<Schema.SObjectField>{
                                                                Simpplr_Site__c.Microsoft_Teams_Site_Manager__c,
                                                                Simpplr_Site__c.Microsoft_Teams_Integration_Enabled__c,
                                                                Simpplr_Site__c.External_Apps_Site_Config_Json__c
                                                                });
            } else if(IntegrationConstants.INTEGRATION_TYPE_SLACK.equalsIgnoreCase(appName)){
                siteObj.Slack_Site_Manager__c = UserContext.peopleId;
                siteObj.Slack_Integration_Enabled__c = true;
                externalAppsSiteConfig.SlackSiteConfig.slackConnectedAs = UserContext.slackConnectedAs;
                externalAppsSiteConfig.SlackSiteConfig.slackConnectedUserId = UserContext.slackUserId;
                externalAppsSiteConfig.SlackSiteConfig.slackChannelId = null;
                externalAppsSiteConfig.SlackSiteConfig.slackChannelName = null;
                externalAppsSiteConfig.SlackSiteConfig.slackWebUrl = null;
                externalAppsSiteConfig.SlackSiteConfig.slackSiteFeedOptions = null;
                siteObj.External_Apps_Site_Config_Json__c = JSON.serializePretty(externalAppsSiteConfig,true);
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
                SIMPESAPI.accessController().updateAsUser(siteObj,new List<Schema.SObjectField>{
                                                                Simpplr_Site__c.Slack_Site_Manager__c,
                                                                Simpplr_Site__c.Slack_Integration_Enabled__c,
                                                                Simpplr_Site__c.External_Apps_Site_Config_Json__c
                                                                });
            }                                              
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            responseWrapperObj.redirectUrl = retURL;
        } catch(Exception e){            
            logger.logError('ManageSiteDataServer----Could not transfer teams account',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('ManageSiteDataServer.transferAccount()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    @TestVisible
    private  String getSlackChannelName(String access_token, String channelId){
        String payLoadChannels = 'token='+access_token+'&channel='+channelId;
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = null;
                
        req.setEndpoint('https://slack.com/api/conversations.info');
        req.setMethod('GET');
        req.setBody(payLoadChannels);
        res = http.send(req);
        String resBody = res.getBody();
        SlackChannelsWrapper channelList = (SlackChannelsWrapper)JSON.deserialize(resBody,SlackChannelsWrapper.class);          
        if(channelList.ok){
            if(channelList.channel != null){
                if(channelList.channel.is_mpim == false && channelList.channel.is_im == false){
                    if(channelList.channel.is_channel){
                        return channelList.channel.name;
                    } else if(channelList.channel.is_group){
                        return channelList.channel.name + ' (Private)';
                    }
                }
            }   
        } else {
            if('token_revoked'.equalsIgnoreCase(channelList.error)){
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', UserContext.peopleId);
                soqlParamMap.put('soqlParam2', integrationConstants.INTEGRATION_TYPE_SLACK_CONTENT_SHARE);
                String queryStr = 'Select Id, Connected__c from People_Integration__c where people__c = :soqlParam1 AND Name=:soqlParam2 AND Connected__c =true';                     
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<People_Integration__c> peopleInteg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
                if(!peopleInteg.isEmpty()){
                    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().deleteAsUser(peopleInteg);
                    new SiteDao().disconnectSlackForSitesConnectedByLoggedInUser();
                }
                throw  new SimpplrException(STR_SLACK_RECONNECT_ACCOUNT);
            } else {
                throw  new SimpplrException(channelList.error);
            }
        }
        return null;
    }
    
    @TestVisible 
    private ResponseWrapper disconnectApp(String siteId, String appName){
        logger.logDebug('ManageSiteDataServer.disconnectApp()----requestData----');
        ResponseWrapper responseWrapperObj = null;
        try{
            SiteService service = new SiteService();
            service.disconnectApp(siteId, appname);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            responseWrapperObj.redirectUrl = PageContext.getPageURL(Pages.app)+'?u=/manage/sites/'+ siteId + '/external-apps' + '&ts=' + dateTime.now().getTime();
        }catch(Exception e){
            logger.logError('ManageSiteDataServer----Could not remove ' + appName + ' connection',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        logger.logDebug('ManageSiteDataServer.disconnectApp()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj; 
    }

    @TestVisible 
    private ResponseWrapper makeFollower(String requestData){
        logger.logDebug('ManageSiteDataServer.makeFollower()----requestData----'+requestData);
        ResponseWrapper responseWrapperObj = null;
        try{
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestData);
            String userId = requestMap.get('sfUserId') != null ? String.valueOf(requestMap.get('sfUserId')):'';
            String siteId = requestMap.get('siteId') != null ? String.valueOf(requestMap.get('siteId')):'';
            String permission = requestMap.get('permission') != null ? String.valueOf(requestMap.get('permission')):'';
            SiteDao siteDaoObj = new SiteDao();
            siteDaoObj.ToggleMemberManager(SiteContext.currentChatterGroup.Id,userId,'Standard');
            siteDaoObj.assignSiteRoles(siteId, userId, permission, false, false);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
                
        } catch (Exception e) {
            logger.logError('ManageSiteDataServer------could not make follower', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), null);
        }
        logger.logDebug('ManageSiteDataServer.makeFollower()----responseWrapperObj----'+responseWrapperObj);
        return responseWrapperObj;
    }

    @TestVisible 
    private Set<String> setOfSiteFeaturesForMustRead = new Set<String>{'Page','Event','Album'};
}