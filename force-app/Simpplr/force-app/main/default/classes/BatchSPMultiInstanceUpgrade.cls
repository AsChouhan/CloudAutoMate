/**
 * @description This batch is used to migrate sharepoint integration to multi instance
 * There are different batch types which are excuted one after the other to achieve migration
 */
public class BatchSPMultiInstanceUpgrade implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    
    private static final String BATCH_UNLINK_FOLDERS = 'unlinkFolders';
    private static final String BATCH_INSTANCE_ID_UPDATE = 'populateInstanceId';
    private static final String BATCH_FOLDER_INSTANCE_ID_UPDATE = 'folderPopulateInstanceId';
    private static final String BATCH_FILE_INSTANCE_ID_UPDATE = 'filePopulateInstanceId';
    
    private String batchType;
    private Exception exceptionDetailsObj;
    private List<List<String>> folderUnlikedCsvList = new List<List<String>>();
    private Boolean runNextBatchInSequence;

    /**
     * @description Parameterized consutructor which takes the type of batch as we have used same batch class to run multiple batch types
     * related to the sharepoint migration to multi instance
     * @param batchType 
     * @param runNextBatchInSequence 
     */
    public BatchSPMultiInstanceUpgrade(String batchType, Boolean runNextBatchInSequence) {
        this.batchType = batchType;
        this.runNextBatchInSequence = runNextBatchInSequence;
    }

    /**
     * @description This is the batch class entry method which returns dynamic record set based on batch type
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if(this.batchType == BATCH_UNLINK_FOLDERS) {
            query = 'SELECT Id, Name__c, Path__c, Site__c, Site__r.Name FROM Folder__c WHERE Is_Deleted__c = false AND External_Folder_Id__c != null AND Type__c = \'' + ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING + '\'';
        } else if(this.batchType == BATCH_INSTANCE_ID_UPDATE) {
            query = 'SELECT Id, User__c, People__c, SP_Instance_Id__c, Is_SP_Admin__c, SP_Instance_Name__c, Access_Token_Requested_Datetime__c, Access_Token_Expiry__c, Token_Type__c, Access_Token__c, Refresh_Token__c,  User_Email__c, Domain__c FROM People_Integration__c WHERE Is_Deleted__c = false AND SP_Instance_Id__c = null AND Name = \'' + ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING + '\'';
        } else if(this.batchType == BATCH_FOLDER_INSTANCE_ID_UPDATE) {
            query = 'SELECT Id, OwnerId FROM Folder__c WHERE Is_Deleted__c = false AND External_Folder_Id__c != null AND Type__c = \'' + ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING + '\' AND SP_Instance_Id__c = null';
        } else if(this.batchType == BATCH_FILE_INSTANCE_ID_UPDATE) {
            query = 'SELECT Id, OwnerId FROM File__c WHERE Is_Deleted__c = false AND External_Id__c != null AND Repository__c = \'' + ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING + '\' AND SP_Instance_Id__c = null';
        }
        return Database.getQueryLocator(query);
    }

    /**
     * @description Actual batch execution based on type
     * @param bc 
     * @param listOfSObjects 
     */
    public void execute(Database.BatchableContext bc, List<SObject> listOfSObjects) {
        try{
            if(this.batchType == BATCH_UNLINK_FOLDERS) {
                unlinkFolders((List<Folder__c>) listOfSObjects);
            } else if(this.batchType == BATCH_INSTANCE_ID_UPDATE) {
                populatePeopleIntInstanceId((List<People_Integration__c>) listOfSObjects);
            } else if(this.batchType == BATCH_FOLDER_INSTANCE_ID_UPDATE) {
                updateInstanceIdOnFolder((List<Folder__c>) listOfSObjects);
            } else if(this.batchType == BATCH_FILE_INSTANCE_ID_UPDATE) {
                updateInstanceIdOnFile((List<File__c>) listOfSObjects);
            }
        } catch(Exception ex) {
            exceptionDetailsObj =  ex;
    		throw ex;
        }
    }

    /**
     * @description Batch finish method for running batch in sequence base on batch type
     * @param bc 
     */
    public void finish(Database.BatchableContext bc) {
        initLangKeyValueMap();
        if(this.batchType == BATCH_UNLINK_FOLDERS) {
            if(!Test.isRunningTest()) {
                unlinkFoldersAws();
            }
            runNextBatch(BATCH_INSTANCE_ID_UPDATE, 20);
        } else if(this.batchType == BATCH_INSTANCE_ID_UPDATE) {
            updateAppIntegrationRecord();
            runNextBatch(BATCH_FOLDER_INSTANCE_ID_UPDATE, 1000);
        } else if(this.batchType == BATCH_FOLDER_INSTANCE_ID_UPDATE) {
            runNextBatch(BATCH_FILE_INSTANCE_ID_UPDATE, 1000);
        } else {
            if(SimpplrContext.enableEmail) {
                NotificationDispatcher.sendSPUpgradeDoneEmailNotification();
            }
            updateAppConfigUpgradeStatus(ServiceConstants.SP_UPGRADE_STATUS_COMPLETED);
            sendInAppNotification();
        }
    }

    /**
     * @description this method is used to run batch in sequence
     * @param batchType 
     * @param batchSize 
     */
    private void runNextBatch(String batchType, Integer batchSize) {
        if(!sendErrorEmailIfAny() && this.runNextBatchInSequence) {
            Database.executeBatch(new BatchSPMultiInstanceUpgrade(batchType, true), batchSize);
        }
    }

    /**
     * @description This method sends error email if any error ocurred while executing a batch
     * @return  `Boolean` to show if error email was sent or not
     */
    private Boolean sendErrorEmailIfAny() {
        Boolean errorSent = false;
        if(exceptionDetailsObj != null) {
            updateAppConfigUpgradeStatus(ServiceConstants.SP_UPGRADE_STATUS_FAILED);
            Utility.sendBatchFailedExceptionEmail('BatchSPMultiInstanceUpgrade.' + batchType, exceptionDetailsObj);
            errorSent = true;
        }
        return errorSent;
    }

    /**
     * @description Update people integration records for sharepoint instance id, name and admin flag
     * @param peopleIntegrationsToUpdate 
     */
    private void  populatePeopleIntInstanceId(List<People_Integration__c> peopleIntegrationsToUpdate) {
        EFSAccessService efsAccess;
        List<String> errorList = new List<String>();
        List<String> peopleList = new List<String>();
        Boolean isRefreshTokenValid;
        for(People_Integration__c integration:peopleIntegrationsToUpdate) {
            efsAccess = new EFSAccessService(integration, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, false);
            if(efsAccess.isAccessExpired()) {
                isRefreshTokenValid = efsAccess.isRefreshTokenValid();
            }
            if(isRefreshTokenValid == true) {
                try {
                    MSAPIModelUser.Organization orgInfo = efsAccess.getSPInstanceInfo();
                    integration.SP_Instance_Id__c = orgInfo?.id;
                    integration.Is_SP_Admin__c = efsAccess.isSPAdmin();
                    integration.SP_Instance_Name__c = orgInfo?.displayName;
                    if(String.isNotBlank(integration.User_Email__c) && integration.User_Email__c.contains('@')){
                        integration.Domain__c = integration.User_Email__c.split('@')[1];
                    }
                } catch(Exception ex) { 
                    errorList.add(JSON.serialize(new Map<String, String>{
                        'message' => ex.getMessage(),
                        'lineNumber' => String.valueOf(ex.getLineNumber()),
                        'stackTrace' => ex.getStackTraceString()
                    }));
                } 
            } else {
                peopleList.add(integration.People__c);
                errorList.add(JSON.serialize(new Map<String, String>{
                    'message' => 'invalid_refresh_token'
                }));  
            }      
        }
        if(errorList.size() > 0) {
            insertLogError(errorList);
        }
        if(peopleList.size() > 0) {
            updatePeopleIntegrationRecord(peopleList);
        }

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(peopleIntegrationsToUpdate), new List<Schema.SObjectField>{
                                                    People_Integration__c.SP_Instance_Id__c, People_Integration__c.Is_SP_Admin__c, People_Integration__c.SP_Instance_Name__c, People_Integration__c.Domain__c });

    }


     /**
     * @description update app Integration record for shrepoint
     * @param sharepointWhitelistDomainSet list of sharepoint admin domain
     */
    private static void updateAppIntegrationRecord() {
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
        soqlParamMap.put('soqlParam2', SimpplrContext.simpplrOrgId);  
		
        String query = 'SELECT Id, User_Email__c,  Whitelist_Domain__c, App_Refresh_Token__c FROM App_Integration__c ' + 
                    ' WHERE Is_Deleted__c = false  AND Connected__c = true AND Name =: soqlParam1 AND Org_Id__c =: soqlParam2 LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<App_Integration__c> listOfAppInt = (List<App_Integration__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        for(App_Integration__c appIng : listOfAppInt) {
            if(String.isNotBlank(appIng.User_Email__c) && appIng.User_Email__c.contains('@')){
                appIng.Whitelist_Domain__c = appIng.User_Email__c.split('@')[1];  
            }
            else{
                if(String.isNotBlank(appIng.App_Refresh_Token__c)){
                    String accessToken = getMSAccessToken(appIng);
                    if(String.isNotBlank(accessToken)){
                        SCoreClient.Credentials cred = new SCoreClient.Credentials('Bearer', accessToken);
                        MSAPIClient client = new MSAPIClient(cred, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
                        MSAPIUser usr = new MSAPIUser(client);
                        MSAPIUser.CurrentUserDetail usrReq = new MSAPIUser.CurrentUserDetail(usr);
                        MSAPIModelUser ownerInfo = (MSAPIModelUser)usrReq.execute();
                        if(ownerInfo !=null && ownerInfo.mail.contains('@')){
                            appIng.Whitelist_Domain__c = ownerInfo.mail.split('@')[1];
                        }
                        else if(ownerInfo !=null && ownerInfo.userPrincipalName.contains('@')){
                            appIng.Whitelist_Domain__c = ownerInfo.userPrincipalName.split('@')[1];
                        }
                    }
                }
            }
        }  
        update listOfAppInt;
    }
     /**
     * @description update people Integration record for shrepoint
     * @param peopleIds list of peopleId for whom we disable sharepoint
     */
    private static void updatePeopleIntegrationRecord(List<String> peopleIds){
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', peopleIds);
        soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
        String query = 'Select Id, Name, People__c FROM People_Integration__c WHERE People__c IN : soqlParam1 AND name=:soqlParam2';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<People_Integration__c> listOfPeopleInt = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        for(People_Integration__c pIng : listOfPeopleInt) {
            pIng.Is_Deleted__c = true;
        }
        if(!listOfPeopleInt.isEmpty()) {
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(listOfPeopleInt), new List<Schema.SObjectField>{									
                                                                People_Integration__c.Is_Deleted__c
                                                            });
        }  
    }

    /**
     * @description insert error logs 
     * @param errorList list of error to insert in Logs__c obj
     */
    private static void insertLogError(List<String> errorList){
        List<Logs__c> logList = new List<Logs__c>();
        for(String er : errorList) {
            Logs__c logsObj = new Logs__c();
            logsObj.Log_Data__c = er;
            logsObj.Log_Type__c = 'INFO';
            logsObj.Source_Info__c = 'Sharepoint_Upgrade';
            logsObj.Data_Counter__c = 0;
            logsObj.Is_Deleted__c = false;
            logsObj.Unique_Token__c = null;
            logList.add(logsObj);
        }
        if(logList.size() > 0) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITH);
            SIMPESAPI.accessController().insertAsUser(logList, new List<Schema.SObjectField>{
                                                                                Logs__c.Log_Data__c,
                                                                                Logs__c.Log_Type__c,
                                                                                Logs__c.Source_Info__c,
                                                                                Logs__c.Data_Counter__c,
                                                                                Logs__c.Is_Deleted__c,
                                                                                Logs__c.Unique_Token__c});
        }
    }

    /**
     * @description This method creates a set of site ids for 
     * which we need to unlink the folders and soft delete folders
     * @param folderList list of folder records to b processed
     */
    private void unlinkFolders(List<Folder__c> folderList) {
        for(Folder__c folderObj : folderList) {
            folderObj.Is_Deleted__c = true;
            folderUnlikedCsvList.add(new List<String> {folderObj.Name__c,folderObj.Path__c,folderObj.Site__r.Name});
        }
        if(!folderList.isEmpty()) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c> (folderList),
                                                      new List<Schema.SObjectField>{Folder__c.Is_Deleted__c});
        }
    }

    /**
     * @description load locatization labels
     */
    public static void initLangKeyValueMap() {
        Set<String> localeSet = new Set<String>();
        localeSet.add('en_US');
        localeSet.add(UserContext.languageLocaleKey);
        LocaleContext.getAllLabelMap('EmailNotifications', new List<String>(localeSet));
    }

    /**
     * @description This methid is used to delete folder from AWS database
     */
    private void unlinkFoldersAws() {
        try{
			String simpDri = Utility.externalRequestAuthToken() + ' '
                    			+ SimpplrContext.simpplrOrgId.substring(0, 15) + ' '
								+ UserContext.userId.substring(0, 15);
			
			HttpRequest reqObj = new HttpRequest();
            reqObj.setEndpoint(SimpplrContext.simpplrAPIEndpoint + '/spodbc/search-sp?action=removelinkeditem&isSPUpgrade=true'); 
			reqObj.setTimeout(60000);
			reqObj.setHeader('content-type','application/json');
			reqObj.setHeader('accept', 'application/json');
			reqObj.setHeader('simpplr-dri', simpDri);
			reqObj.setMethod('POST');

			Map<String, Object> requestMap = new Map<String, Object>();
			requestMap.put('orgId', UserInfo.getOrganizationId());
			requestMap.put('simpplrSiteId', null);
			requestMap.put('driveId', null);
			requestMap.put('folderId', null);
			requestMap.put('provider', ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
			requestMap.put('removeAllForSite', 'false');
			requestMap.put('sender', ServiceConstants.EMAIL_SIMPPLR_USER_SERVICES);
			requestMap.put('to', new List<String>{UserInfo.getUserEmail()});
			requestMap.put('emailSubject', LocaleContext.getLabel(UserContext.languageLocaleKey, NotificationDispatcher.KEY_EMAIL_SP_UPGRADE_IN_PROGRESS));
			requestMap.put('emailHtmlBody', NotificationDispatcher.getSharepointUpgradeInProgressEmailBody());
			requestMap.put('attachmentName', 'SharePoint document library list.csv');
			requestMap.put('attachmentBody', folderUnlikedCsvList);
			reqObj.setBody(Json.serialize(requestMap));

			Http httpObj = new Http();
			HTTPResponse resObj = httpObj.send(reqObj);

			if (resObj.getStatusCode() != 200) {
				throw new EFSException('Folder Linking Error AWS');	
			}

		} catch(Exception ex){
			throw new EFSException('Folder Linking Error AWS', ex.getMessage());	
		}
    }

    /**
     * @description This method updates the sharepoint upgrade status after bath execution
     * @param status 
     */
    private void updateAppConfigUpgradeStatus(String status) {
        String appConfigQuery = 'SELECT Id, SP_Upgrade_Status__c FROM App_Config__c LIMIT 1';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<App_Config__c> listOfAppConfig = ((List<App_config__c>) SIMPESAPI.accessController().queryAsUser(appConfigQuery, null));
        if(listOfAppConfig.size() > 0) {
            App_Config__c appConfig = listOfAppConfig.get(0);
            appConfig.SP_Upgrade_Status__c = status;
            SIMPESAPI.accessController().updateAsUser(appConfig, new List<Schema.SObjectField>{
                App_Config__c.SP_Upgrade_Status__c});
        }
    }

    /**
     * @description this method is used to update the instance id on folder
     * @param folderList 
     */
    private void updateInstanceIdOnFolder(List<Folder__c> folderList) {
        Set<Id> ownerIdSet = new Set<Id>();
        for(Folder__c folder:folderList) {
            ownerIdSet.add(folder.OwnerId);
        }
        Map<String, String> ownerInstanceMap = getUserInstanceMap(ownerIdSet);
        for(Folder__c folder:folderList) {
            folder.SP_Instance_Id__c = ownerInstanceMap.get(folder.OwnerId);
        }
        SIMPESAPI.accessController().updateAsUser(new Map<Id, Folder__c>(folderList), new List<Schema.SObjectField>{Folder__c.SP_Instance_Id__c});
    }

    /**
     * @description this method is used to update the instance id on files
     * @param fileList 
     */
    private void updateInstanceIdOnFile(List<File__c> fileList) {
        Set<Id> ownerIdSet = new Set<Id>();
        for(File__c file:fileList) {
            ownerIdSet.add(file.OwnerId);
        }
        Map<String, String> ownerInstanceMap = getUserInstanceMap(ownerIdSet);
        for(File__c file:fileList) {
            file.SP_Instance_Id__c = ownerInstanceMap.get(file.OwnerId);
        }
        SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{File__c.SP_Instance_Id__c});
    }

    /**
     * * @description this method is used to get instance ids corresponding to users
     * @param ownerIdSet 
     * @return  `Map<String, String>`
     */
    private Map<String, String> getUserInstanceMap(Set<Id> ownerIdSet) {
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
        soqlParamMap.put('soqlParam2', ownerIdSet);
        String pplIntQuery = 'SELECT Id, SP_Instance_Id__c, User__c FROM People_Integration__c WHERE Name =: soqlParam1 AND OwnerId IN :soqlParam2 AND IS_Deleted__c=false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> pplIntegrations = ((List<People_Integration__c>) SIMPESAPI.accessController().queryAsUser(pplIntQuery, soqlParamMap));
        Map<String, String> ownerInstanceMap = new Map<String, String>();
        for(People_Integration__c pplInt:pplIntegrations) {
            ownerInstanceMap.put(pplInt.User__c, pplInt.SP_Instance_Id__c);
        }
        return ownerInstanceMap;
    }

    /**
     * @description This will send an in app notification when sharepoint upgrade is done
     */
    private void sendInAppNotification() {
        String guid = UserContext.id + '-' + System.currentTimeMillis(); 
        App_Notification__c notificationObject = new App_Notification__c();
        notificationObject.GUID__c = guid;
        notificationObject.Status__c = 'Pending';
        notificationObject.Type__c = 'Information';
        notificationObject.Is_Read__c = false;
        notificationObject.Is_New__c = true;
        notificationObject.Category__c = 'Sharepoint_Upgraded';
        notificationObject.Sent_to__c = UserContext.getCurrentUserInfo.id;
        notificationObject.Simpplr_Site__c = null;
        notificationObject.Created_DateTime__c = DateTime.now();
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().insertAsUser(notificationObject, new List<Schema.SObjectField>{
            App_Notification__c.GUID__c, 
            App_Notification__c.Status__c, 
            App_Notification__c.Type__c, 
            App_Notification__c.Is_Read__c, 
            App_Notification__c.Is_New__c, 
            App_Notification__c.Category__c, 
            App_Notification__c.Sent_to__c, 
            App_Notification__c.Created_DateTime__c});
    }

    //Get access token for admin
    private static String getMSAccessToken(App_Integration__c appInt){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String accesToken = '';
        String endPoint = IntegrationConstants.TOKEN_ENDPOINT_MAP.get(IntegrationConstants.INTEGRATION_TYPE_SHAREPOINT);
        req.setEndpoint(endPoint);
        req.setHeader(IntegrationConstants.CONTENT_TYPE, IntegrationConstants.URL_ENCODED_FORM);
        req.setBody(IntegrationConstants.GRANT_TYPE+ '='+IntegrationConstants.REFRESH_TOKEN
        +'&'+IntegrationConstants.REFRESH_TOKEN+'='
        +EncodingUtil.urlEncode(appInt.App_Refresh_Token__c, IntegrationConstants.CHARSET_UTF8)
        +'&'+IntegrationConstants.CLIENT_ID+'='
        +EncodingUtil.urlEncode(EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_ID, IntegrationConstants.CHARSET_UTF8)
        +'&'+IntegrationConstants.CLIENT_SECRET+'='
        +EncodingUtil.urlEncode(EFSConstants.SHAREPOINT_ONEDRIVE_CLIENT_SECRET, IntegrationConstants.CHARSET_UTF8));
        req.setMethod(IntegrationConstants.POST_REQUEST_TYPE);
        req.setTimeout(120000);
        HttpResponse resObj = http.send(req);
        if (resObj.getStatusCode()== 200) { 
            String resBodyJSON = resObj.getBody();
            Map<String,Object> resBody = (Map<String,Object>)JSON.deserializeUntyped(resBodyJSON);
            accesToken = String.valueOf(resBody.get(IntegrationConstants.ACCESS_TOKEN));
        }
        return accesToken;
    }

}