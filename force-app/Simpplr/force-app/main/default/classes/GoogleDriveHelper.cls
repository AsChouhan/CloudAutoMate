public with sharing class GoogleDriveHelper { 
    
    private static final String AUTH_INTEGRATION_GOOGLE_DRIVE_ENDPOINT = 'https://accounts.google.com/o/oauth2/auth';
    
    public String getAdminAuthUrl () {
        String googleClientId = EFSConstants.GOOGLEDRIVE_CLIENT_ID;
        String googleAuthEndpoint = AUTH_INTEGRATION_GOOGLE_DRIVE_ENDPOINT;
        String googleRedirectURlStr = SimpplrContext.simpplrAPIEndpoint + 
                '/oauth/google-oauth-manager';
        String googleDriveScopeStr ='https://www.googleapis.com/auth/drive ' + 
                                    'https://www.googleapis.com/auth/userinfo.profile ' + 
                                    'https://www.googleapis.com/auth/userinfo.email ' +
                                    EFSConstants.GDRIVE_ADMIN_SCOPE;

        String googleStateString = PageContext.getPageURL(Pages.StorageSettings).toLowerCase() + 
                '?state=' + IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE + 'admin' + 
                '&orgId=' + SimpplrContext.simpplrOrgId + 
                '&peopleId=' + UserContext.peopleId + 
                '&userId=' + UserContext.userId + 
                '&appName=' + SimpplrContext.applicationName +
                '&multiDomain=' + GoogleDriveService.googleMultiDomainUpgraded();

        String finalRedirectUrl = EmailUtility.format(
                                            '{0}' + 
                                            '?response_type=code' + 
                                            '&client_id={1}' + 
                                            '&redirect_uri={2}' + 
                                            '&scope={3}' + 
                                            '&prompt=consent' + 
                                            '&access_type=offline' + 
                                            '&include_granted_scopes=true' + 
                                            '&state={4}',
            new List<String>{
                googleAuthEndpoint, //0
                EncodingUtil.urlEncode(googleClientId, 'UTF-8'), //1
                EncodingUtil.urlEncode(googleRedirectURlStr, 'UTF-8'), //2
                EncodingUtil.urlEncode(googleDriveScopeStr, 'UTF-8'), //3
                EncodingUtil.urlEncode(googleStateString, 'UTF-8') //4
            }
        );

        return finalRedirectUrl;  
    }

    public Boolean upsertAppIntegrationRecord (String gUserId, String gUserName, String gUserEmail, 
            String gUserDomain, String allCompanyGrpId) {
        App_Integration__c gDAppIntObj = new  App_Integration__c();
        Boolean isRecordExist = false; 

        if (SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING) != null) {
            gDAppIntObj = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
            isRecordExist = true; 
        }

        gDAppIntObj.Name = IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE;
        gDAppIntObj.All_Company_Group_Id__c = allCompanyGrpId;
        gDAppIntObj.Connected__c = true;
        gDAppIntObj.External_Id__c = gUserId;
        gDAppIntObj.User_Email__c = gUserEmail;
        gDAppIntObj.User_Name__c = gUserName;
        gDAppIntObj.Enterprise_Id__c = gUserDomain; 
        gDAppIntObj.Client_Id__c = EFSConstants.GOOGLEDRIVE_CLIENT_ID;
        gDAppIntObj.Client_Secret__c = EFSConstants.GOOGLEDRIVE_CLIENT_SECRET;
        gDAppIntObj.Integration_Enabled__c = true; 
        gDAppIntObj.Connected__c = true; 
        gDAppIntObj.Org_Id__c = SimpplrContext.simpplrOrgId;
        gDAppIntObj.Connected_DateTime__c = DateTime.Now();
        gDAppIntObj.Refresh_Token_Expiration_Datetime__c = null;

        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
                                                    App_Integration__c.Name, 
                                                    App_Integration__c.All_Company_Group_Id__c,
                                                    App_Integration__c.Connected__c,
                                                    App_Integration__c.External_Id__c,
                                                    App_Integration__c.User_Email__c,
                                                    App_Integration__c.User_Name__c,
                                                    App_Integration__c.Enterprise_Id__c,
                                                    App_Integration__c.Client_Id__c,
                                                    App_Integration__c.Client_Secret__c,
                                                    App_Integration__c.Integration_Enabled__c,
                                                    App_Integration__c.Connected__c,
                                                    App_Integration__c.Org_Id__c,
                                                    App_Integration__c.Connected_DateTime__c,
                                                    App_Integration__c.Refresh_Token_Expiration_Datetime__c
                                                };

        // Update the appIntegration record  
        if (isRecordExist) {

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().updateAsUser(gDAppIntObj, fieldList);
                    
        // Insert the appIntegration record 
        } else {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(gDAppIntObj, fieldList); 
        }
        
        return true; 
    }
    
    public String getPeopleAuthUrl () {
        String googleClientId = EFSConstants.GOOGLEDRIVE_CLIENT_ID;
        String googleAuthEndpoint = AUTH_INTEGRATION_GOOGLE_DRIVE_ENDPOINT;
        String googleRedirectURlStr = SimpplrContext.simpplrAPIEndpoint + 
                '/oauth/google-oauth-manager';
        String googleDriveScopeStr ='https://www.googleapis.com/auth/drive ' + 
                                    'https://www.googleapis.com/auth/userinfo.profile '  + 
                                    'https://www.googleapis.com/auth/userinfo.email';

        String googleStateString = PageContext.getPageURL(Pages.StorageSettings).toLowerCase() + 
                '?state=' + IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE + 
                '&orgId=' + SimpplrContext.simpplrOrgId + 
                '&appName=' + SimpplrContext.applicationName + 
                '&userId=' + UserContext.userId + 
                '&peopleId=' + UserContext.peopleId +
                '&multiDomain=' + GoogleDriveService.googleMultiDomainUpgraded();

        String finalRedirectUrl = EmailUtility.format(
                                                '{0}' + 
                                                '?response_type=code' + 
                                                '&client_id={1}' + 
                                                '&redirect_uri={2}' + 
                                                '&scope={3}' + 
                                                '&prompt=consent' + 
                                                '&access_type=offline' + 
                                                '&include_granted_scopes=true' +
                                                '&state={4}',
            new List<String>{
                googleAuthEndpoint, //0
                EncodingUtil.urlEncode(googleClientId, 'UTF-8'), //1
                EncodingUtil.urlEncode(googleRedirectURlStr, 'UTF-8'), //2
                EncodingUtil.urlEncode(googleDriveScopeStr, 'UTF-8'), //3
                EncodingUtil.urlEncode(googleStateString, 'UTF-8') //4
            }
        );

        return finalRedirectUrl; 
    }

    public Boolean createPeopleIntegrationRecord (String gUserId, String gUserName, String gUserEmail, String myDriveId, String domain) {
        List<People_Integration__c> listOfPeopleIntegration = new List<People_Integration__c>();
        List<Schema.SObjectField> listOfModifiedFields = new List<Schema.SObjectField>();
        People_Integration__c gDPeopleIntObj = new  People_Integration__c();
        gDPeopleIntObj.Name = IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE;
        gDPeopleIntObj.People__c = UserContext.peopleId;
		gDPeopleIntObj.Connected__c = true;
        gDPeopleIntObj.User_Email__c = gUserEmail;
        gDPeopleIntObj.User_Name__c = gUserName;
		gDPeopleIntObj.App_Integration__c = SimpplrContext.Integrations.get(IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE).id;
        gDPeopleIntObj.User__c = userInfo.getUserID();
        gDPeopleIntObj.External_Id__c = gUserId;
        gDPeopleIntObj.My_Drive_Id__c = myDriveId;
        gDPeopleIntObj.Batch_Flag__c = true;
        gDPeopleIntObj.Domain__c = domain;
        listOfModifiedFields.add(People_Integration__c.Name);
        listOfModifiedFields.add(People_Integration__c.People__c);
        listOfModifiedFields.add(People_Integration__c.Connected__c);
        listOfModifiedFields.add(People_Integration__c.User_Email__c);
        listOfModifiedFields.add(People_Integration__c.User_Name__c);
        listOfModifiedFields.add(People_Integration__c.App_Integration__c);
        listOfModifiedFields.add(People_Integration__c.User__c);
        listOfModifiedFields.add(People_Integration__c.External_Id__c);
        listOfModifiedFields.add(People_Integration__c.My_Drive_Id__c);
        listOfModifiedFields.add(People_Integration__c.Batch_Flag__c);
        listOfModifiedFields.add(People_Integration__c.Domain__c);

        if(UserContext.getCurrentUserInfo != null){
			gDPeopleIntObj.OwnerId = UserContext.getCurrentUserInfo.User__c;
            listOfModifiedFields.add(People_Integration__c.OwnerId);
		}	

        if(!SimpplrContext.googleManagedPermission) {
            String successfulGroupIdStr = addMemberToGoogleGroups(gUserEmail);
            gDPeopleIntObj.Group_Id_Set__c = successfulGroupIdStr;
            listOfModifiedFields.add(People_Integration__c.Group_Id_Set__c);
        }

        listOfPeopleIntegration.add(gDPeopleIntObj);
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().insertAsUser(listOfPeopleIntegration, listOfModifiedFields);
											
        return true; 
    }

    public void createSiteRootFolder (String siteId) { 
        Folder__c fObj= new Folder__c();
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();

        fObj.Name__c = 'Google Drive Files';
        fObj.Type__c = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
        fObj.Site__c =  siteId;
        fObj.External_Folder_Id__c = 'virtual'; 
        fObj.Is_System_Folder__c = true;

        fieldList.add(Folder__c.Name__c);
        fieldList.add(Folder__c.Type__c);
        fieldList.add(Folder__c.Site__c);
        fieldList.add(Folder__c.External_Folder_Id__c);
        fieldList.add(Folder__c.Is_System_Folder__c);
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
		SIMPESAPI.accessController().insertAsUser(fObj, fieldList);
    }

    public String addMemberToGoogleGroups(String userEmail) { 
        logger.logDebug('GoogleDriveHelper.addMemberToGoogleGroups()----userEmail----' + userEmail);
        String successfulGroupIdStr = null; 
        //Getting site membership of loggedIn user 
        List<CollaborationGroupMember> listOfGroupMember = [SELECT memberId, CollaborationGroupId 
                FROM CollaborationGroupMember 
                WHERE memberId=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
        
        if (!listOfGroupMember.isEmpty()) {
            Set<Id> setOfChatterGrpId = new Set<Id>(); 
            successfulGroupIdStr = '';

            for (CollaborationGroupMember grpMembObj: listOfGroupMember) {
                setOfChatterGrpId.add(grpMembObj.CollaborationGroupId);
            } 
 
            //Getting sites for which google drive is active and loggedIn user is a member
            List<Simpplr_Site__c> listOfSite = [SELECT Id,Site_Type__c, File_Storage_Source__c,
                    Chatter_Group_Id__c 
                    FROM Simpplr_Site__c  
                    WHERE File_Storage_Source__c='googledrive' 
                    AND Chatter_Group_Id__c IN :setOfChatterGrpId 
                    AND Show_In_Simpplr__c=true AND Is_Active__c=true WITH SECURITY_ENFORCED];
            List<GoogleDriveModel.GroupMemberRequest> listOfGrpMemReq = new List<GoogleDriveModel.GroupMemberRequest>();
            String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
            
            if (!listOfSite.isEmpty()) { 
                
                for (Simpplr_Site__c siteObj: listOfSite) {
                    String chatterGrpId = siteObj.Chatter_Group_Id__c;
                    successfulGroupIdStr = successfulGroupIdStr + chatterGrpId + ',';

                    // RGroup Member will be added only when permissions are simp managed
                    if (!SimpplrContext.googleManagedPermission) {
                        GoogleDriveModel.GroupMemberRequest addRGroupMemberReq = new GoogleDriveModel.GroupMemberRequest();
                        String rGroupEmail = chatterGrpId + GoogleDriveService.READ_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                        addRGroupMemberReq.groupEmail = rGroupEmail;
                        addRGroupMemberReq.memberEmail = userEmail;
                        listOfGrpMemReq.add(addRGroupMemberReq);

                        if (UserContext.sitesIManageMap.keyset().contains(siteObj.id)) {
                            GoogleDriveModel.GroupMemberRequest addRWGroupMemberReq = new GoogleDriveModel.GroupMemberRequest();
                            String rWGroupEmail = chatterGrpId + GoogleDriveService.READ_WRITE_SIMPPLR_MANAGED_GROUP_SUFFIX + domainStr;
                            addRWGroupMemberReq.groupEmail = rWGroupEmail;
                            addRWGroupMemberReq.memberEmail = userEmail;
                            listOfGrpMemReq.add(addRWGroupMemberReq);
                        }
                        
                    }

                }

            }

            //Member will be added in all company group only when permission is Simp managed 
            if (!SimpplrContext.googleManagedPermission) {
                String allCompanyGroupEmail = SimpplrContext.simpplrOrgId;
                allCompanyGroupEmail += '_sfsm@' + domainStr;

                GoogleDriveModel.GroupMemberRequest addAllCompGroupMemberReq = new GoogleDriveModel.GroupMemberRequest();
                addAllCompGroupMemberReq.groupEmail = allCompanyGroupEmail;
                addAllCompGroupMemberReq.memberEmail = userEmail;
                listOfGrpMemReq.add(addAllCompGroupMemberReq);
            }

            String resultBody = new GoogleDriveService().addMembersToGroupBulk(listOfGrpMemReq);
            successfulGroupIdStr = successfulGroupIdStr + SimpplrContext.simpplrOrgId;
            return successfulGroupIdStr;

        } else {
            successfulGroupIdStr = '';
        }

        return successfulGroupIdStr;
    }
}