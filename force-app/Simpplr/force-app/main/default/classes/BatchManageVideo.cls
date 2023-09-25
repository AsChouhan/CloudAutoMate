public without sharing class BatchManageVideo implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    private String query;
	private Boolean runNextBatchInSequence;
    private string recordType;
    Date startDate ;
    private Set<String> processedSiteRoleIdSet = new Set<String>(); 
    private Set<CollaborationGroupMember> collaborationGroupMemberSet;
    
    public BatchManageVideo() {

    }

    public BatchManageVideo(String recordType,date StartDate) {
        this.startDate = startDate;
        this.recordType = recordType;
    }

    public BatchManageVideo(String recordType, Set<CollaborationGroupMember> collaborationGroupMemberSet) {
        this.recordType = recordType;
        this.collaborationGroupMemberSet = collaborationGroupMemberSet;
    }

    public BatchManageVideo(String recordType) {
        this.recordType = recordType;
    }

    public database.querylocator start(Database.BatchableContext bc){
        Set<String> collabGroupId = new Set<String>();
        Set<String> cGMemberIdSet = new Set<String>();
    	query = '';
        DateTime currentDate = DateTime.now();
    	if('sendNativeVideoDataToAws'.equalsIgnoreCase(recordType)){
            query = 'SELECT Id,user__r.languagelocalekey, user__r.timeZonesidkey, user__r.username, Segment__c, ' + 
                    ' Segment__r.Branding_JSON__c, Segment__r.Branding_Logo__c ' + 
                    ' FROM People__c WHERE (App_Moderation_Permission__c = \'Yes\' OR Can_Access_Analytics__c = True) ' + 
                    ' AND User__r.isActive=true AND User__r.UserType=\'Standard\' LIMIT 1';      
      
        } else if('createVideoFolders'.equalsIgnoreCase(recordType)){ 
            query = 'SELECT id, Chatter_Group_Id__c, Name FROM Simpplr_Site__c WHERE Is_Deleted__c = false';

        } else if('markPeopleIntDeleted'.equalsIgnoreCase(recordType)){
            query = 'SELECT Id, Is_Deleted__c FROM People_Integration__c WHERE Is_Deleted__c = false AND App_Integration__r.Name =\'native_video\' ';

        } else if('markSiteVideoFolderDeleted'.equalsIgnoreCase(recordType)){
            query = 'SELECT Id, Is_Deleted__c FROM Folder__c '
                    + ' WHERE Is_Deleted__c = false AND Type__c = \'native_video\'';

        } else if('markVideoFileDeleted'.equalsIgnoreCase(recordType)){
            query = 'SELECT Id, Is_Deleted__c FROM File__c '
                    + ' WHERE Is_Deleted__c = false AND (Repository__c = \'native_video\' OR Video_Provider__c = \'native_video\')';

        } else if('syncSiteMembersToNativeVideoAws'.equalsIgnoreCase(recordType)){
            query = 'SELECT Id, Name, is_Manager__c, Site__c, Site__r.Chatter_Group_Id__c,  Is_Content_Manager__c,'
                    + ' Is_Member__c, People__r.User__c, People__c, Is_Deleted__c, Sync_Status__c, Video_Provider_Sync_Status__c FROM Site_Role__c '
                    + ' WHERE Is_Deleted__c = false AND Video_Provider_Sync_Status__c = null AND People__c != null AND Site__c != null ' 
                    + ' AND Site__r.Show_In_Simpplr__c = true' 
                    + ' AND People__c in (SELECT People__c from People_Integration__c where name = \'native_video\' and Is_Deleted__c = False)'
                    + ' ORDER BY createddate DESC ';

        } else if ('removeGroupMembers'.equalsIgnoreCase(recordType)){
            
            for(CollaborationGroupMember cgm : collaborationGroupMemberSet) {
                collabGroupId.add(cgm.CollaborationGroupId);
                cGMemberIdSet.add(cgm.MemberID);
            }
            query = 'SELECT Id, Name, is_Manager__c, Site__c, Site__r.Chatter_Group_Id__c, ' 
                            + ' People__r.User__c, People__c FROM Site_Role__c '
                            + ' WHERE Site__r.Chatter_Group_Id__c IN :collabGroupId AND ' 
                            + ' People__r.User__c IN :cGMemberIdSet ';

        } else if ('cleanupOrphanNativeVideos'.equalsIgnoreCase(recordType)){
            query = 'SELECT id FROM App_Config__c LIMIT 1';
        
        } else if ('syncFailedSite'.equalsIgnoreCase(recordType)){
            query = ' SELECT Id, Name, Site_Type__c, Video_Provider_Sync_Status__c From Simpplr_Site__c Where video_provider_sync_status__c = 0 '
                            + ' And Is_Active__c = true ' 
                            + ' And Show_In_Simpplr__c = true';
        }

    	return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> listOfsObject){
    	try {
            if('sendNativeVideoDataToAws'.equalsIgnoreCase(recordType)){
                sendVideoDataToAws();

            } else if('createVideoFolders'.equalsIgnoreCase(recordType)){
                List<Simpplr_Site__c> simpplrSiteList = (List<Simpplr_Site__c>)listOfsObject;
                createVideoFolders(simpplrSiteList);

            } else if('markPeopleIntDeleted'.equalsIgnoreCase(recordType)){
                List<People_Integration__c> peopleIntegrationList = (List<People_Integration__c>) listOfsObject;
                markPeopleIntegrationRecordsDeleted(peopleIntegrationList);

            } else if('markSiteVideoFolderDeleted'.equalsIgnoreCase(recordType)){
                List<Folder__c> folderList = (List<Folder__c>) listOfsObject;
                markSiteVideoFolderRecordsDeleted(folderList);

            } else if('markVideoFileDeleted'.equalsIgnoreCase(recordType)){
                List<File__c> fileList = (List<File__c>) listOfsObject;
                markVideoFileRecordsDeleted(fileList);

            } else if('syncSiteMembersToNativeVideoAws'.equalsIgnoreCase(recordType)){
                List<Site_Role__c> siteRoleList = (List<Site_Role__c>) listOfsObject;
                syncSiteMembersToNativeVideoAws(siteRoleList);

            } else if ('removeGroupMembers'.equalsIgnoreCase(recordType)){
                List<Site_Role__c>  siteRoleList = (List<Site_Role__c>) listOfsObject;
                removeGroupMembers(siteRoleList);

            } else if ('cleanupOrphanNativeVideos'.equalsIgnoreCase(recordType)){
                VideoDao videoObj = new VideoDao();
                videoObj.cleanupOrphanNativeVideos(null);
            
            } else if ('syncFailedSite'.equalsIgnoreCase(recordType)){
                List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>) listOfsObject;
                syncFailedSite(siteList);
            }  
        }catch(Exception ex) {
    		
            Utility.sendBatchFailedExceptionEmail('BatchManageVideo - ' + recordType, ex);
    	}
    }

    /**
     * @description It is used to update siteObj record when createCategoryForSite endpoint failed
     * @param siteList 
    */
    public void syncFailedSite(List<Simpplr_site__c> siteList) {
        List<Simpplr_site__c> siteObjList = new List<Simpplr_site__c>();
        for(Simpplr_site__c siteObj : siteList) {
            try {
                createCategoryForSite(siteObj.id, siteObj.Name, siteObj.Site_Type__c);     
            } catch(Exception ex) {
                siteObjList.add(siteObj);
            }          
        }
        if(!siteObjList.isEmpty()) {
            markSiteSyncForNativeVideo(siteObjList);
        }
    }

    /**
     * @description It is used to send req to lambda fro cration of category corresponding to a site
     * @param siteId 
     * @param siteName 
     * @param siteType 
    */
    public static void createCategoryForSite(String siteId, String siteName, String siteType) {
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';               
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('siteName', siteName);
        requestBody.put('siteType', siteType);
        requestBody.put('action', 'createCategoryForSite');
        try {
            Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody); 
        } catch(Exception ex) {
            throw ex;
        }                       
    }
    
    /**
     * @description It is update Video_Provider_Sync_Status__c = 0 when res is not 200
     * @param siteList 
    */
    private void markSiteSyncForNativeVideo(List<Simpplr_Site__c> siteList){
        for(Simpplr_Site__c siteObj : siteList){
            siteObj.Video_Provider_Sync_Status__c = 0;
        }

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
                                                        Simpplr_Site__c.Video_Provider_Sync_Status__c
                                              });
    }
    
    public void finish(Database.BatchableContext bc){

        if('sendNativeVideoDataToAws'.equalsIgnoreCase(recordType)){
            if(SimpplrContext.isEmployeeAdvocacyEnabled && SimpplrContext.appIntegrationEnabledSet.size() > 0) {
                BatchSocialCampaignAnalytics campaignBatchJob = new BatchSocialCampaignAnalytics('initAnalyticsData', startDate);
                DataBase.executeBatch(campaignBatchJob, 10);
             } else {
                BatchPullNewsletterTrackerData job = new BatchPullNewsletterTrackerData();
                DataBase.executeBatch(job, 1);            
             }

        } else if('markPeopleIntDeleted'.equalsIgnoreCase(recordType)){
            BatchManageVideo job = new BatchManageVideo('markVideoFileDeleted');
            Database.executeBatch(job, 100);

        } else if('markVideoFileDeleted'.equalsIgnoreCase(recordType)){
            BatchManageVideo job = new BatchManageVideo('markSiteVideoFolderDeleted');
            Database.executeBatch(job, 100);

        } else if('markSiteVideoFolderDeleted'.equalsIgnoreCase(recordType)){
            // Mark app int record for video deleted

            String appIntQuery = 'SELECT Id FROM App_Integration__c WHERE Name = \'native_video\' '
                                                     + ' AND Is_Deleted__c = false LIMIT 1';
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            List<App_integration__c> appIntRecord = (List<App_integration__c>)SIMPESAPI.accessController().queryAsUser(appIntQuery, null);

            if(appIntRecord.isEmpty() == false){
                appIntRecord[0].Is_Deleted__c = true;

                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                SIMPESAPI.accessController().updateAsUser(new Map<Id, App_integration__c>(appIntRecord), new List<Schema.SObjectField>{
                                                                        App_integration__c.Is_Deleted__c
                                                                    });
            }
        } else if('syncSiteMembersToNativeVideoAws'.equalsIgnoreCase(recordType)){
            // Do Nothing
        } else if('cleanupOrphanNativeVideos'.equalsIgnoreCase(recordType)) {

            // Added to execute nigthly jobs sequentially
            SchedulerSimpplrServices.executeNextJob('videoCleanupJob');             
        } else if('createVideoFolders'.equalsIgnoreCase(recordType) && !Test.isRunningTest()) {
            // initiate action sendEmail and SaveMediaConfig on AWS
            finishNVSetup();
        }
    }

    private void removeGroupMembers(List<Site_Role__c> siteRoleList){

        Map<String, Map<String, Boolean>> siteIdVsUserIdAndIsManagerSetMap = new Map<String, Map<String, Boolean>>();
        Map<String, Site_Role__c> siteRoleMap = new Map<String, Site_Role__c>();
        for(Site_Role__c sr : siteRoleList){

            siteRoleMap.put(sr.Site__r.Chatter_Group_Id__c + '_' + sr.People__r.User__c, sr);
        }
        Set<CollaborationGroupMember> cgmToBeRemovedSet = new Set<CollaborationGroupMember>();
        for(CollaborationGroupMember cgm : collaborationGroupMemberSet){

            String chatterGroupIdVsUserUniqueKey = cgm.CollaborationGroupId + '_' + cgm.MemberID;
            Site_Role__c sr = siteRoleMap.get(chatterGroupIdVsUserUniqueKey);

            if(sr != null){
                
                if(siteIdVsUserIdAndIsManagerSetMap.containsKey(sr.Site__c)){

                    siteIdVsUserIdAndIsManagerSetMap.get(sr.Site__c).put(sr.People__c, sr.Is_Manager__c);
                } else {

                    Map<String, Boolean> userIdVsIsManagerMap = new Map<String, Boolean>{
                        sr.People__c => sr.Is_Manager__c
                    };                     
                    siteIdVsUserIdAndIsManagerSetMap.put(sr.Site__c, userIdVsIsManagerMap);
                }

                cgmToBeRemovedSet.add(cgm);
            }
        }
        // remove already processed records.
        collaborationGroupMemberSet.removeAll(cgmToBeRemovedSet);
        if(siteIdVsUserIdAndIsManagerSetMap.isEmpty() == false){

            deleteGroupMembersFromNVProvider(JSON.serialize(siteIdVsUserIdAndIsManagerSetMap)); 
        }
    }

    public void finishNVSetup() {

		String endpoint = SimpplrContext.simpplrAPIEndpoint + '/video/license-manager';                
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('action', 'saveMediaConfigSendEmail');

		HttpResponse res = Utility.getResponseFromAWS(endpoint, requestBody);        
    }

    public void syncSiteMembersToNativeVideoAws(List<Site_Role__c> siteRoleList) {
        Map<String, Map<String, Boolean>> peopleIdVsSiteIdAndIsManagerSetMap = new Map<String, Map<String, Boolean>>();

        String sitePeopleIdConcatStr = null;
        for(Site_Role__c sr : siteRoleList){

            sitePeopleIdConcatStr = sr.Site__c + '_' + sr.People__c;
            if(processedSiteRoleIdSet.contains(sitePeopleIdConcatStr) == false){
                Map<String, Boolean> siteIdVsIsManagerMap = null;
                if(peopleIdVsSiteIdAndIsManagerSetMap.containsKey(sr.People__c)){

                    peopleIdVsSiteIdAndIsManagerSetMap.get(sr.People__c).put(sr.Site__c, sr.Is_Manager__c);
                } else {
                    
                    siteIdVsIsManagerMap = new Map<String, Boolean>(); 
                    siteIdVsIsManagerMap.put(sr.Site__c, sr.Is_Manager__c);                    
                    peopleIdVsSiteIdAndIsManagerSetMap.put(sr.People__c, siteIdVsIsManagerMap);
                }
                processedSiteRoleIdSet.add(sitePeopleIdConcatStr);
            }

            sr.Video_Provider_Sync_Status__c = 1;
        }

        if(peopleIdVsSiteIdAndIsManagerSetMap.isEmpty() == false){

            sendDataToAws(JSON.serialize(peopleIdVsSiteIdAndIsManagerSetMap)); 
        }
        RecursionCheck.stopRecursion();
        
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id, Site_Role__c>(siteRoleList), new List<Schema.SObjectField>{
                                                                Site_Role__c.Video_Provider_Sync_Status__c
                                                            });

    }
    
    private void sendDataToAws (String dataStr) {
		String syncSiteMembersEndpoint = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('data', dataStr);
		requestBody.put('action', 'syncSiteMembers');

		HttpResponse res = Utility.getResponseFromAWS(syncSiteMembersEndpoint, requestBody);
    }

    private void deleteGroupMembersFromNVProvider(String dataStr) {
		String syncSiteMembersEndpoint = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('orgId', SimpplrContext.simpplrOrgId);
		requestBody.put('data', dataStr);
		requestBody.put('action', 'removeGroupMembers');

		HttpResponse res = Utility.getResponseFromAWS(syncSiteMembersEndpoint, requestBody);
    }

    private void sendVideoDataToAws () {
        Date dateToday = Date.today().addDays(-1);
        Date yesterDay = Date.today().addDays(-2);
        String sMonth = String.valueof(dateToday.month());
        String sDay = String.valueof(dateToday.day());
        String previousDay = String.valueof(yesterDay.day());
        if(sMonth.length()== 1){
            sMonth = '0' + sMonth;
        }
          if(sDay.length() == 1){
            sDay = '0' + sDay;
        }
          if(previousDay.length() == 1){
            previousDay = '0' + previousDay;
        }
        String sToday = String.valueof(dateToday.year()) + sMonth + sDay;
        String ANALYTICS_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/analytics-manager';                
        DateTime now = DateTime.now();
	    Long offsetms = DateTime.newInstance(now.date(), now.time()).getTime() - 
        DateTime.newInstance(now.dateGmt(), now.timeGmt()).getTime();
        Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('fromDate', sToday);
        requestBody.put('toDate', sToday);
        requestBody.put('action', 'topcontent');
        requestBody.put('context', 'first');
        requestBody.put('offset', offsetms);
        requestBody.put('peopleId', UserContext.peopleId);
		HttpResponse res = Utility.getResponseFromAWS(ANALYTICS_ENDPOINT, requestBody);
    }
    
    public static void createVideoFolders (List<Simpplr_Site__c> simpplrSiteList) {
        List<String> collaborationIdList = new  List<String>();
        Map<String,Id> collaborationOwnerIdMap = new Map<String,Id>();
        List<String> collabIdList = new  List<String>();
        Map<String,Id> collabOwnerIdMap = new Map<String,Id>();
        for(Simpplr_Site__c site : simpplrSiteList) {
            collaborationIdList.add(site.Chatter_Group_Id__c);
        }
        List<CollaborationGroup> collabGroupList = [SELECT id, ownerId FROM CollaborationGroup WHERE id In: collaborationIdList And owner.isActive = true];
        for(CollaborationGroup collab : collabGroupList) {
            collaborationOwnerIdMap.put(collab.id,collab.ownerId);
        }
        List<Folder__c> newFolderList = new List<Folder__c>();
        for(Simpplr_Site__c site : simpplrSiteList) {
            Folder__c folderObj = new Folder__c();
            folderObj.Name__c = ServiceConstants.SITE_VIDEOS_SYSTEM_FOLDER;
            folderObj.Parent_folder__c = null;
            folderObj.Path__c = null;
            folderObj.Is_System_folder__c = true;
            folderObj.Is_Deleted__c = false;
            folderObj.site__c = site.id;
            folderObj.Type__c = 'native_video';
            folderObj.ownerId = collaborationOwnerIdMap.get(site.Chatter_Group_Id__c) != null ? collaborationOwnerIdMap.get(site.Chatter_Group_Id__c) : UserContext.userId;
            newFolderList.add(folderObj);
        }

        if(newFolderList.isEmpty() == false){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(newFolderList, new List<Schema.SObjectField> { 
                Folder__c.Name__c,
                Folder__c.Parent_folder__c,
                Folder__c.Path__c,
                Folder__c.Is_System_folder__c,
                Folder__c.Is_Deleted__c,
                Folder__c.site__c,
                Folder__c.Type__c,
                Folder__c.ownerId
            });
        }

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', simpplrSiteList);
        String folderQuery = 'SELECT id, Site__c, site__r.Chatter_Group_Id__c FROM Folder__c ' +
            ' WHERE Is_System_Folder__c=true And Is_Deleted__c = false And Site__c =:soqlParam1 And Name__c In (\'Content Files\', \'Feed Files\')';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
        List<Folder__c> newSubFolderList = new List<Folder__c>();
        for(Folder__c fold: folderList) {
            Folder__c folderObj = new Folder__c();
            folderObj.Name__c = 'Videos';
            folderObj.Parent_folder__c = fold.id;
            folderObj.Path__c = fold.id;
            folderObj.Is_System_folder__c = true;
            folderObj.Is_Deleted__c = false;
            folderObj.site__c = fold.site__c;
            folderObj.Type__c = 'native_video';
            folderObj.ownerId = collaborationOwnerIdMap.get(fold.site__r.Chatter_Group_Id__c) != null ? collaborationOwnerIdMap.get(fold.site__r.Chatter_Group_Id__c) : UserContext.userId;
            newSubFolderList.add(folderObj);
        }

        if(newSubFolderList.isEmpty() == false){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(newSubFolderList, new List<Schema.SObjectField> { 
                Folder__c.Name__c,
                Folder__c.Parent_folder__c,
                Folder__c.Path__c,
                Folder__c.Is_System_folder__c,
                Folder__c.Is_Deleted__c,
                Folder__c.site__c,
                Folder__c.Type__c,
                Folder__c.ownerId
            });
        }
    }

    public void markPeopleIntegrationRecordsDeleted(List<People_Integration__c> peopleIntegrationList){
        // Mark people int records aas deleted when native video is disabled.
        for(People_Integration__c pplIntObj : peopleIntegrationList){
            pplIntObj.Is_Deleted__c = true;
        }

        if(peopleIntegrationList.isEmpty() == false){

            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id, People_Integration__c>(peopleIntegrationList), new List<Schema.SObjectField>{
                                                People_Integration__c.Is_Deleted__c
                                            });        
        }
    }

    public void markSiteVideoFolderRecordsDeleted(List<Folder__c> folderList){
        // Mark folders for site video records aas deleted when native video is disabled.
        for(Folder__c folderObj : folderList){
            folderObj.Is_Deleted__c = true;
        }

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(folderList), new List<Schema.SObjectField>{
            Folder__c.Is_Deleted__c
        });
    }

    public void markVideoFileRecordsDeleted(List<File__c> fileList){
        // Mark file records as deleted when native video is disabled.
        for(File__c fileObj : fileList){
            fileObj.Is_Deleted__c = true;
        }

        if(fileList.isEmpty() == false) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(new Map<Id,File__c>(fileList), new List<Schema.SObjectField>{
                File__c.Is_Deleted__c
            });
        }
    }

}