public with sharing class VideoDao {
    public VideoDao() {

    }


    /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */

	public Map<String, Object> addVideoToCategory (String entryId, String siteId, Boolean isCaptionLanguageIdRequired) {      
        Map<String, Object> requestBody = new Map<String, Object>();
        Map<String, Object> response = null;
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('entryId', entryId);
        requestBody.put('siteId', siteId);
        requestBody.put('action', 'addVideoToCategory');

        if(String.isNotBlank(UserContext.languageLocaleKey) && isCaptionLanguageIdRequired){
            Integer captionLanguageId = ServiceConstants.SIMPPLR_LANG_VS_KALTURA_LANG_ID_MAP.get(UserContext.languageLocaleKey);

            if(captionLanguageId != null){
                
                requestBody.put('captionLanguageId', captionLanguageId);
            }
        }
        
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/video-manager';
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        return response;
    }

    @future(callout=true)
	public static void addVideoToCategoryInFuture (String entryIdVsSiteIdJsonStr) {
        Boolean isCaptionLanguageIdRequired = false;
        VideoDao videoDaoObj = new VideoDao();

        Map<String, Object> entryIdVsSiteIdMap = (Map<String, Object>) JSON.deserializeUntyped(entryIdVsSiteIdJsonStr);
        for(String entryId : entryIdVsSiteIdMap.keySet()){
            List<Object> objectList = (List<Object>) entryIdVsSiteIdMap.get(entryId);
            for(Object objectTemp : objectList){
                String siteId = (String) objectTemp;
                videoDaoObj.addVideoToCategory(entryId, siteId, isCaptionLanguageIdRequired);
            }
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

	public Boolean removeVideoFromCategory (Set<String> entryIdSet, String siteId) {

        logger.logDebug('VideoDao.removeVideoFromCategory()----');
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('entryIds', entryIdSet);
        requestBody.put('siteId', siteId);
        requestBody.put('action', 'removeVideoFromCategory');        
        
        String REMOVE_VIDEO_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/video-manager';
        String response = null;
        Boolean result = false;
        Map<String, Object> requestDataMap ;

        HttpResponse res = Utility.getResponseFromAWS(REMOVE_VIDEO_ENDPOINT, requestBody);
        logger.logError('VideoDao.removeVideoFromCategory()--------response----' + response);
        if(res.getStatusCode() == 200){
            requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());

        }
        if (requestDataMap != null && requestDataMap.containsKey('status')) {
            if ('error'.equalsIgnoreCase((String)requestDataMap.get('status'))) {
                logger.logError('VideoDao.removeVideoFromCategory()-------' + 'error'); 
                        
            } else {
                logger.logError('VideoDao.removeVideoFromCategory()-------' + 'success');
                result = true;
            }
        } else {
            logger.logError('VideoDao.removeVideoFromCategory()-------' + 'error');
        }
                
        return result;
}

/**
 * 
 * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
 * Parameters:
 * parameter_name -- [Explanation of the purpose of this parameter to the method.
 *      
 * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
*/

public Boolean deleteVideo (Set<String> entryIdToDeleteSet) {
        logger.logDebug('VideoDao.deleteVideo()----');
        String DELETE_VIDEO_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/video-manager';
        String response = null;
        Boolean result = false;       
                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('entryId', null);
        requestBody.put('entryIds', entryIdToDeleteSet);
        requestBody.put('action', 'deleteVideo');
        Map<String, Object> requestDataMap ;

        HttpResponse res = Utility.getResponseFromAWS(DELETE_VIDEO_ENDPOINT, requestBody);
       
        logger.logError('VideoDao.deleteVideo()--------response----' + response);
        if(res.getStatusCode() == 200){
            requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        }    
        if (requestDataMap != null && requestDataMap.containsKey('status')) {
            if ('error'.equalsIgnoreCase((String)requestDataMap.get('status'))) {
                logger.logError('VideoDao.deleteVideo()-------' + 'error'); 
                        
            } else {
                logger.logError('VideoDao.deleteVideo()-------' + 'success');
                result = true;
            }
        } else {
            logger.logError('VideoDao.deleteVideo()-------' + 'error');
        }
                
        return result;
}

@future(callout=true)
/**
 * @description to delete videos in future
 * @param entryId of video - String
 */
public static void deleteVideoInFuture (String entryId) {
    logger.logDebug('VideoDao.deleteVideoInFuture()----');

    Set<String> entryIdToDeleteSet = new Set<String>();
    entryIdToDeleteSet.add(entryId);
    VideoDao daoObj = new VideoDao();
    daoObj.deleteVideo(entryIdToDeleteSet);
}

/**
 * 
 * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
 * Parameters:
 * parameter_name -- [Explanation of the purpose of this parameter to the method.
 *      
 * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
*/

@future(callout=true)
public static void updateVideo (String name, String entryId, String description, String languageId) {
    logger.logDebug('VideoDao.updateVideo()----');
    String UPDATE_VIDEO_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/video-manager';
    Boolean result = false;
                
    Map<String, Object> requestBody = new Map<String, Object>();
    requestBody.put('org_id', SimpplrContext.simpplrOrgId);
    requestBody.put('peopleId', UserContext.peopleId);
    requestBody.put('entryId', entryId);
    requestBody.put('describe', description);
    requestBody.put('name', name);
    if(String.isNotBlank(languageId)){
        requestBody.put('captionLanguageId', languageId);
    }
    requestBody.put('action', 'updateVideo');
    HttpResponse res = Utility.getResponseFromAWS(UPDATE_VIDEO_ENDPOINT, requestBody);
    Map<String, Object> requestDataMap = null;
    if(res.getStatusCode() == 200){   
        requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        if (requestDataMap != null) {
            if(requestDataMap.get('videoCaptionUpdateStatus') != null){
                result = true;
            }else{
                logger.logError('VideoDao.updateVideo()-------videoCaptionUpdateStatus' + 'error');
            }
        } else {
            logger.logError('VideoDao.updateVideo()-------' + 'error');
        }
    }
}

public Integer getVideoCaptionStatus (String entryId) {
    logger.logDebug('VideoDao.getVideoCaptionStatus()----');
    final String VIDEO_MANAGER_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/video-manager';      
            
    Map<String, Object> requestBody = new Map<String, Object>();
    requestBody.put('orgId', SimpplrContext.simpplrOrgId);
    requestBody.put('peopleId', UserContext.peopleId);
    requestBody.put('entryId', entryId);
    requestBody.put('action', 'getVideoCaptionStatus');
    Integer captionStatus = null;

    HttpResponse res = Utility.getResponseFromAWS(VIDEO_MANAGER_ENDPOINT, requestBody);
    logger.logDebug('VideoDao.getVideoCaptionStatus()--------response----' + res);
    
    if(res.getStatusCode() == 200){
        Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        if(requestDataMap.containsKey('captionStatus')){

            captionStatus = (Integer) requestDataMap.get('captionStatus');
        } else {

            logger.logError('VideoDao.getVideoCaptionStatus()-------' + 'error'); 
        }
    } else {

        logger.logError('VideoDao.getVideoCaptionStatus()-------' + 'error'); 
    }
            
    return captionStatus;
}

public Map<String, Object> getAccessToken () {
    String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/session-manager';                
    Map<String, Object> requestBody = new Map<String, Object>();
    requestBody.put('org_id', SimpplrContext.simpplrOrgId);
    requestBody.put('peopleId', UserContext.peopleId);
    requestBody.put('action', 'getVideoAccessToken');
    requestBody.put('langauge', UserContext.languageLocaleKey);
    requestBody.put('isAdminSessionRequired', UserContext.isUserAppModerator || UserContext.hasModifyAllDataPermission);
    HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
    Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                         
    return requestDataMap;
}

public Map<String, Object> revokeSession(String session) {
    String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/session-manager';                
    Map<String, Object> requestBody = new Map<String, Object>();
    requestBody.put('org_id', SimpplrContext.simpplrOrgId);
    requestBody.put('peopleId', UserContext.peopleId);
    requestBody.put('session', session);
    requestBody.put('action', 'revokeSession');
    HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
    Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                           
    return requestDataMap;
}


public Map<String, Object> createVideoCategoryForSite (Simpplr_Site__c siteObj) {
    String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/video-manager';                
    Map<String, Object> requestBody = new Map<String, Object>();
    requestBody.put('org_id', SimpplrContext.simpplrOrgId);
    requestBody.put('siteId', siteObj.id);
    requestBody.put('peopleId', UserContext.peopleId);
    requestBody.put('siteName', siteObj.name);
    requestBody.put('siteType', siteObj.Site_Type__c);
    requestBody.put('action', 'createCategoryForSite');
    HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
    Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                
    return requestDataMap;
}

public Map<String,String> getThumbnail (String entryId) {
    String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/video-manager';                
    Map<String, Object> requestBody = new Map<String, Object>();
    requestBody.put('org_id', SimpplrContext.simpplrOrgId);
    requestBody.put('peopleId', UserContext.peopleId);
    requestBody.put('entryId', entryId);
    requestBody.put('action', 'getThumbnail');
    Map<String,String> resultMap = new Map<String,String>();

    Map<String, Object> soqlParamMap = new Map<String, Object>();
    soqlParamMap.put('soqlParam1', ServiceConstants.VIDEO_PROVIDER_NATIVE);
    soqlParamMap.put('soqlParam2', entryId);
    String fileQuery = 'Select id, Thumbnail_URL__c,External_Id__c From File__c'+
                           ' where Video_Provider__c =: soqlParam1'+
                           ' AND External_Id__c =: soqlParam2';
    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    File__c fileObj = ((List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap)).get(0);
    String thumbnailURL ='';
    String assetId = '';
                            
    if(!string.isBlank(fileObj.Thumbnail_URL__c)){
        assetId = thumbnailURL.substringBetween('thumbAssetId/','/');
        thumbnailURL= fileObj.Thumbnail_URL__c ;
    }
    else{
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());  
        if(res.getStatusCode() == 200 ){    
            thumbnailURL = (String)requestDataMap.get('thumbnail');
            assetId = thumbnailURL.substringBetween('thumbAssetId/','/');
            thumbnailURL = thumbnailURL.substringBeforeLast('/');
            thumbnailURL = thumbnailURL + '/';
            fileObj.Thumbnail_Url__c = thumbnailURL ;
            
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().updateAsUser(fileObj, new List<Schema.SObjectField>{
                                                        File__c.Thumbnail_Url__c
                                                    });
        } 
    }
    resultMap.put('thumbnail',thumbnailURL);
    resultMap.put('assetId',assetId);
    return resultMap;
}

public NativeVideoWrapper.VideoReferencesWrapper getVideoReferences (String entryId, Integer size, Integer offsetVal) {
    NativeVideoWrapper.VideoReferencesWrapper videoReferencesWrapper = new NativeVideoWrapper.VideoReferencesWrapper();
    Map<String,String> resultMap = new Map<String,String>();
    Set<Id> siteIdSet = UserContext.sitesIFollowIdSet;
    String loggedInPeopleId = UserContext.peopleId;
    Map<String, Object> soqlParamMap1 = new Map<String, Object>();
    soqlParamMap1.put('soqlParam1', ServiceConstants.VIDEO_PROVIDER_NATIVE);
    soqlParamMap1.put('soqlParam2', entryId);
    String fileQuery1 = 'Select Id, Feed_Item__c, Tile_Id__c, Is_Deleted__c From File__c where Is_Deleted__c = false and (Video_Provider__c =: soqlParam1 OR Repository__c =: soqlParam1) and External_Id__c =: soqlParam2';
    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    List<File__c> fileObjList1 = (List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery1, soqlParamMap1);
    List<String> feedIdsSet1 = new List<String>();
    Set<String> tileIdsSet = new Set<String>();
    for(File__c fileObj : fileObjList1){
        if(String.isNotBlank(fileObj.Feed_Item__c)){
            feedIdsSet1.add(fileObj.Feed_Item__c);
        }
        
        if(String.isNotBlank(fileObj.Tile_Id__c)){
            tileIdsSet.add(fileObj.Tile_Id__c);
        }
    }

    List<String> feedIdsSet = new List<String>();
    if(feedIdsSet1.size() > 0){
        Map<String, Object> soqlParamMap2 = new Map<String, Object>();
        soqlParamMap2.put('soqlParam1', feedIdsSet1);
        String feedQuery = 'Select Id, isDeleted , status From FeedItem where id IN:soqlParam1 And isDeleted = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<FeedItem> feedItemList = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedQuery, soqlParamMap2);
        for(FeedItem feedItemObj:feedItemList){
            feedIdsSet.add(feedItemObj.id);
        }
    }

    Map<String, Tiles_Config__c> tileMap = new Map<String, Tiles_Config__c>();
    if(tileIdsSet.size() > 0){
        Map<String, Object> soqlParamMap3 = new Map<String, Object>();
        soqlParamMap3.put('soqlParam1', tileIdsSet);
        String tileQuery = 'SELECT Id, Site__c, Site__r.name, Site__r.Landing_Page__c, Site__r.Title_Content_Version__c, Site__r.Site_Type__c, site__r.Is_Active__c, Site__r.Chatter_Group_Id__c  FROM Tiles_Config__c WHERE Type__c = \'media\' AND Variant__c = \'video\' AND Id IN:soqlParam1 And Is_Deleted__c = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Tiles_Config__c> tilesList = (List<Tiles_Config__c>)SIMPESAPI.accessController().queryAsUser(tileQuery, soqlParamMap3);
        tileMap = new Map<String, Tiles_Config__c>(tilesList);
    }

    String unlistedCondition ='';
    String systemAdminCondition ='';
    if(UserContext.hasManageUnlistedSitePermission ){ 
        unlistedCondition = ' OR site__r.site_type__c =\'Unlisted\''	;	
    }
    if(UserContext.hasModifyAllDataPermission ){
        systemAdminCondition = ' OR site__r.site_type__c =\'private\''	;	
    }
    Map<String, Object> soqlParamMap = new Map<String, Object>();
    soqlParamMap.put('soqlParam1', ServiceConstants.VIDEO_PROVIDER_NATIVE);
    soqlParamMap.put('soqlParam2', entryId);
    soqlParamMap.put('soqlParam3', size);
    soqlParamMap.put('soqlParam4', offsetVal);
    soqlParamMap.put('soqlParam5', siteIdSet);
    soqlParamMap.put('soqlParam6', feedIdsSet);
    String fileQuery = 'Select Id, Simpplr_Content__c, video_provider__c, external_id__c, Tile_Id__c, ' +
            ' Site__c, Site__r.Name ,Site__r.Landing_Page__c,Simpplr_Content__r.Is_Published__c,' +
            ' Simpplr_Content__r.Status__c, Simpplr_Content__r.Primary_Author__r.User__c,Question__c, OwnerId,' +
            ' Order__c, Name,title__c, LastModifiedDate, Is_Deleted__c,site__r.Is_Active__c,Site__r.Chatter_Group_Id__c,' +
            ' LastModifiedById, Folder__c, Feed_Item__c,createdDate, Feed_Comment__c, CreatedById ,Site__r.Site_Type__c,' +
            ' Thumbnail_URL__c,Location__c,Is_Title_Image__c,MIME_Type__c,Content_Version__c,' +
            ' Simpplr_Content__r.id,Simpplr_Content__r.Title__c,Simpplr_Content__r.Type__c,Simpplr_Content__r.Cover_Image_Layout__c,' +
            ' Simpplr_Content__r.Title_Image_Caption__c,Simpplr_Content__r.Site__r.name,Simpplr_Content__r.Site__r.Title_Content_Version__c,' +
            ' Simpplr_Content__r.Site__r.Landing_Page__c,Simpplr_Content__r.Site__r.Site_Type__c,Simpplr_Content__r.site__r.Is_Active__c,' +
            ' Simpplr_Content__r.Site__r.Chatter_Group_Id__c,Simpplr_Content__r.Primary_Author__c,Simpplr_Content__r.Primary_Author__r.User__r.Id,' +
            ' Simpplr_Content__r.Primary_Author__r.Full_Name__c,Simpplr_Content__r.Primary_Author__r.User__r.TimezoneSidKey,' +
            ' Simpplr_Content__r.Primary_Author__r.User__r.FullPhotoURL,Simpplr_Content__r.Primary_Author__r.title__c,Simpplr_Content__r.Primary_Author__r.city__c,' +
            ' Simpplr_Content__r.Primary_Author__r.state__c,Simpplr_Content__r.Primary_Author__r.country__c,' +
            ' Simpplr_Content__r.Primary_Author__r.Department__c,Simpplr_Content__r.Primary_Author__r.User__r.isActive,' +
            ' Simpplr_Content__r.Primary_Author__r.User__r.MediumPhotoURL,Simpplr_Content__r.Publish_Start_DateTime__c,Simpplr_Content__r.Is_Deleted__c, Author__c' +
            ' From File__c where Is_Deleted__c = false and (Video_Provider__c =: soqlParam1 OR Repository__c =: soqlParam1)' +
            ' and (feed_Item__c =null OR feed_Item__c IN :soqlParam6)' +
            ' and (Site__c = null OR ( site__r.is_Active__c=true And (site__c IN:soqlParam5 or site__r.site_type__c =\'Public\''+unlistedCondition + systemAdminCondition+')))' +
            ' and (Simpplr_Content__c = null OR ( ( Simpplr_Content__r.Site__c = null and  Simpplr_Content__r.Is_Published__c = true and Simpplr_Content__r.Is_Deleted__c = false) or (Simpplr_Content__r.Site__c != null and  Simpplr_Content__r.Is_Published__c = true and Simpplr_Content__r.Is_Deleted__c = false and Simpplr_Content__r.Site__r.Is_Active__c = true)))' +
            ' and External_Id__c =: soqlParam2  LIMIT :soqlParam3  OFFSET :soqlParam4';
    SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
    List<File__c> fileObjList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap);
    List<NativeVideoWrapper.ReferenceItemWrapper> result=new List<NativeVideoWrapper.ReferenceItemWrapper>();

    for(File__c fileObj : fileObjList){
        NativeVideoWrapper.ReferenceItemWrapper itemWrapperObj = new NativeVideoWrapper.ReferenceItemWrapper();
        if(String.isNotBlank(fileObj.Site__c) && String.isNotBlank(fileObj.Feed_Item__c) && String.isBlank(fileObj.Simpplr_Content__c)){
            //site feed post
            NativeVideoWrapper.ReferenceFeedWrapper feedWrapperObj=convertToFeedWrapper(fileObj);
            itemWrapperObj.id=fileObj.id;
            itemWrapperObj.feedPost=feedWrapperObj;
            itemWrapperObj.peopleId=fileObj.Author__c;
            itemWrapperObj.isSiteFeedPost=true;
            itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            result.add(itemWrapperObj);
        }else if(String.isNotBlank(fileObj.Site__c) && String.isNotBlank(fileObj.Simpplr_Content__c) && String.isBlank(fileObj.Feed_Item__c)){
            //site content
            NativeVideoWrapper.ReferenceContentWrapper contentWrapperObj=convertToContentWrapper(fileObj);
            itemWrapperObj.id=fileObj.id;
            itemWrapperObj.content=contentWrapperObj;
            itemWrapperObj.peopleId=fileObj.Author__c;
            itemWrapperObj.isContent=true;
            itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            result.add(itemWrapperObj);
        }else if(String.isNotBlank(fileObj.Simpplr_Content__c) && String.isBlank(fileObj.Site__c) && String.isBlank(fileObj.Feed_Item__c)){
            //Blog Post
            NativeVideoWrapper.ReferenceContentWrapper contentWrapperObj=convertToContentWrapper(fileObj);
            itemWrapperObj.id=fileObj.id;
            itemWrapperObj.content=contentWrapperObj;
            itemWrapperObj.peopleId=fileObj.Author__c;
            itemWrapperObj.isBlog=true;
            itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            result.add(itemWrapperObj);
        }else if(String.isBlank(fileObj.Site__c) && String.isNotBlank(fileObj.Feed_Item__c) && String.isBlank(fileObj.Simpplr_Content__c)){
            //home feed
            NativeVideoWrapper.ReferenceFeedWrapper feedWrapperObj=convertToFeedWrapper(fileObj);
            itemWrapperObj.id=fileObj.id;
            itemWrapperObj.feedPost=feedWrapperObj;
            itemWrapperObj.peopleId=fileObj.Author__c;
            itemWrapperObj.isHomeFeedPost=true;
            itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            result.add(itemWrapperObj);
        }else if(String.isNotBlank(fileObj.Tile_Id__c) && tileMap.containsKey(fileObj.Tile_Id__c)){
            //Tile
            NativeVideoWrapper.ReferenceTileWrapper tileWrapperObj=convertToTileWrapper(tileMap.get(fileObj.Tile_Id__c));
            itemWrapperObj.id=fileObj.id;
            itemWrapperObj.tile=tileWrapperObj;
            itemWrapperObj.peopleId=fileObj.Author__c;
            itemWrapperObj.isSiteTile=tileWrapperObj.site != null ? true : false;
            itemWrapperObj.isHomeTile=!itemWrapperObj.isSiteTile;
            itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            result.add(itemWrapperObj);
        }
    }
    if(fileObjList.size() == size && result.size() > 1){
        result.remove((result.size()-1));
        videoReferencesWrapper.results= result;
        videoReferencesWrapper.nextPageToken = String.valueOf(offsetVal + size - 1);
    }else{
        videoReferencesWrapper.nextPageToken=null;
        videoReferencesWrapper.results= result;
    }
    return videoReferencesWrapper;
}

private NativeVideoWrapper.ReferenceFeedWrapper convertToFeedWrapper(File__c fileObj){
    NativeVideoWrapper.ReferenceFeedWrapper wrapperObj=new NativeVideoWrapper.ReferenceFeedWrapper();
    
    People__c authorByObj = [ Select id,user__c,User__r.Id,Full_Name__c,User__r.TimezoneSidKey,User__r.FullPhotoURL,title__c,city__c,
                            state__c,country__c,Department__c,User__r.isActive from people__c 
                            where user__c =: fileObj.OwnerId WITH SECURITY_ENFORCED];
    
    wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/feed/' + fileObj.Feed_Item__c;
    wrapperObj.id = fileObj.Feed_Item__c;
    wrapperObj.authoredBy = new PeopleLiteWrapper();
    wrapperObj.authoredBy.Id = authorByObj.id;
    wrapperObj.authoredBy.sfUserId = authorByObj.User__r.Id;
    wrapperObj.authoredBy.peopleId = authorByObj.id;
    wrapperObj.authoredBy.name = authorByObj.Full_Name__c;
    wrapperObj.authoredBy.img = authorByObj.User__r.FullPhotoURL.endsWith('005/F') ? null : authorByObj.User__r.FullPhotoURL;
    wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + authorByObj.id;
    wrapperObj.authoredBy.title = SimpplrContext.isPPTitleDisplay ? authorByObj.title__c : null;
    wrapperObj.authoredBy.location = Utility.buildLocation(authorByObj.city__c,authorByObj.state__c,authorByObj.country__c);
    wrapperObj.authoredBy.isFollowing = UserContext.usersIFollowIdSet.contains(wrapperObj.authoredBy.sfUserId);
    wrapperObj.authoredBy.department = SimpplrContext.isPPDepartmentDisplay ? authorByObj.Department__c : null;
    wrapperObj.authoredBy.canFollow	= UserContext.peopleId.equalsIgnoreCase(wrapperObj.authoredBy.peopleId) ?  false : authorByObj.User__r.isActive;
    wrapperObj.authoredBy.city = authorByObj.City__c;
    wrapperObj.authoredBy.state = authorByObj.State__c;
    wrapperObj.authoredBy.country = authorByObj.Country__c;
    wrapperObj.authoredBy.isActive = authorByObj.User__r.IsActive;
    if(String.isNotBlank(fileObj.Site__c)){
        wrapperObj.isSiteFeed = true;
        wrapperObj.site = New SiteLiteWrapper();
        wrapperObj.site.siteid = fileObj.Site__c;
        wrapperObj.site.name = fileObj.Site__r.name;
        wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + fileObj.Site__c + '/' + fileObj.Site__r.Landing_Page__c;
        wrapperObj.site.access = fileObj.Site__r.Site_Type__c;
        wrapperObj.site.isActive = fileObj.site__r.Is_Active__c;
        wrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(fileObj.Site__r.Site_Type__c);
        wrapperObj.site.isPublic = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(fileObj.Site__r.Site_Type__c);
        wrapperObj.site.isMember = false;
        wrapperObj.site.isFollower = false;
        wrapperObj.site.isManager = UserContext.sitesIManageIdSet.contains(fileObj.Site__c);
        wrapperObj.site.isContentManager = UserContext.sitesIManageContentsIdSet.contains(fileObj.Site__c);
        wrapperObj.site.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(fileObj.Site__r.Site_Type__c);
        wrapperObj.site.chatterGroupId = fileObj.Site__r.Chatter_Group_Id__c;
    }else{
        wrapperObj.isHomeFeed = true;
    }
    return wrapperObj;
}

private NativeVideoWrapper.ReferenceContentWrapper convertToContentWrapper(File__c fileObj){
    NativeVideoWrapper.ReferenceContentWrapper wrapperObj=new NativeVideoWrapper.ReferenceContentWrapper();
    
    wrapperObj.id = fileObj.Simpplr_Content__r.id;
    wrapperObj.contentId = fileObj.Simpplr_Content__r.id;
    if(ServiceConstants.TYPE_PAGE.equalsIgnoreCase(fileObj.Simpplr_Content__r.Type__c)){
        wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+fileObj.site__c+'/page/'+fileObj.Simpplr_Content__r.Id;                                          

    } else if(ServiceConstants.TYPE_BLOGPOST.equalsIgnoreCase(fileObj.Simpplr_Content__r.Type__c)){
        wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/people/'+fileObj.Simpplr_Content__r.Primary_Author__c+'/blog/'+fileObj.Simpplr_Content__r.id;                                          

    } else if(ServiceConstants.TYPE_EVENT.equalsIgnoreCase(fileObj.Simpplr_Content__r.Type__c)){
        wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+fileObj.site__c+'/event/'+fileObj.Simpplr_Content__r.Id;                                           

    } else if(ServiceConstants.TYPE_ALBUM.equalsIgnoreCase(fileObj.Simpplr_Content__r.Type__c)){
        wrapperObj.url = PageContext.getPageURL(Pages.app)+'?u=/site/'+fileObj.site__c+'/album/'+fileObj.Simpplr_Content__r.Id;                                           
    }
    wrapperObj.type = fileObj.Simpplr_Content__r.Type__c.toLowerCase();
    wrapperObj.title = String.isBlank(fileObj.Simpplr_Content__r.Title__c)?'' : Utility.getAllValidWords(fileObj.Simpplr_Content__r.Title__c, fileObj.Simpplr_Content__r.Title__c.length(), false);
    wrapperObj.imgLayout= fileObj.Simpplr_Content__r.Cover_Image_Layout__c;
    wrapperObj.imgCaption = fileObj.Simpplr_Content__r.Title_Image_Caption__c;
    String timezoneSidKey = fileObj.Simpplr_Content__r.Primary_Author__r.User__r.TimezoneSidKey;
    TimeZone tz = Timezone.getTimeZone(timezoneSidKey);
    wrapperObj.timezoneName = Utility.timezoneIdToDisplayLabel(timezoneSidKey);
    wrapperObj.timezoneIso = tz.getID();
    wrapperObj.timezoneOffset = tz.getOffset(system.today());
    wrapperObj.startsAt = Utility.dateTimeToMomentJSDateTime(fileObj.Simpplr_Content__r.Publish_Start_DateTime__c);
	wrapperObj.img = fileObj.Thumbnail_URL__c;
    wrapperObj.imgLandscape = fileObj.Thumbnail_URL__c;
    wrapperObj.authoredBy = new PeopleLiteWrapper();
    wrapperObj.authoredBy.Id = fileObj.Simpplr_Content__r.Primary_Author__c;
    wrapperObj.authoredBy.sfUserId = fileObj.Simpplr_Content__r.Primary_Author__r.User__r.Id;
    wrapperObj.authoredBy.peopleId = fileObj.Simpplr_Content__r.Primary_Author__c;
    wrapperObj.authoredBy.name = fileObj.Simpplr_Content__r.Primary_Author__r.Full_Name__c;
    wrapperObj.authoredBy.img = fileObj.Simpplr_Content__r.Primary_Author__r.User__r.FullPhotoURL.endsWith('005/F') ? null : fileObj.Simpplr_Content__r.Primary_Author__r.User__r.FullPhotoURL;
    wrapperObj.authoredBy.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + fileObj.Simpplr_Content__r.Primary_Author__c;
    wrapperObj.authoredBy.title = SimpplrContext.isPPTitleDisplay ? fileObj.Simpplr_Content__r.Primary_Author__r.title__c : null;
    wrapperObj.authoredBy.location = Utility.buildLocation(fileObj.Simpplr_Content__r.Primary_Author__r.city__c,fileObj.Simpplr_Content__r.Primary_Author__r.state__c,fileObj.Simpplr_Content__r.Primary_Author__r.country__c);
    wrapperObj.authoredBy.isFollowing = UserContext.usersIFollowIdSet.contains(wrapperObj.authoredBy.sfUserId);
    wrapperObj.authoredBy.department = SimpplrContext.isPPDepartmentDisplay ? fileObj.Simpplr_Content__r.Primary_Author__r.Department__c : null;
    wrapperObj.authoredBy.canFollow	= UserContext.peopleId.equalsIgnoreCase(wrapperObj.authoredBy.peopleId) ?  false : fileObj.Simpplr_Content__r.Primary_Author__r.User__r.isActive;
    wrapperObj.authoredBy.city = fileObj.Simpplr_Content__r.Primary_Author__r.City__c;
    wrapperObj.authoredBy.state = fileObj.Simpplr_Content__r.Primary_Author__r.State__c;
    wrapperObj.authoredBy.country = fileObj.Simpplr_Content__r.Primary_Author__r.Country__c;
    wrapperObj.authoredBy.isActive = fileObj.Simpplr_Content__r.Primary_Author__r.User__r.IsActive;
    if(String.isNotBlank(fileObj.Site__c)){
        wrapperObj.site = New SiteLiteWrapper();
        wrapperObj.site.siteid = fileObj.Simpplr_Content__r.Site__c;
        wrapperObj.site.name = fileObj.Simpplr_Content__r.Site__r.name;
        wrapperObj.site.img = String.isBlank(fileObj.Simpplr_Content__r.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(fileObj.Simpplr_Content__r.Site__r.Title_Content_Version__c);
        wrapperObj.site.imgThumbnail= String.isBlank(fileObj.Simpplr_Content__r.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(fileObj.Simpplr_Content__r.Site__r.Title_Content_Version__c);
        wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + fileObj.Simpplr_Content__r.Site__c + '/' + fileObj.Simpplr_Content__r.Site__r.Landing_Page__c;
        wrapperObj.site.access = fileObj.Simpplr_Content__r.Site__r.Site_Type__c;
        wrapperObj.site.isActive = fileObj.Simpplr_Content__r.site__r.Is_Active__c;
        wrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(fileObj.Simpplr_Content__r.Site__r.Site_Type__c);
        wrapperObj.site.isPublic = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(fileObj.Simpplr_Content__r.Site__r.Site_Type__c);
        wrapperObj.site.isMember = false;
        wrapperObj.site.isFollower = false;
        wrapperObj.site.isManager = UserContext.sitesIManageIdSet.contains(fileObj.Simpplr_Content__r.Site__c);
        wrapperObj.site.isContentManager = UserContext.sitesIManageContentsIdSet.contains(fileObj.Simpplr_Content__r.Site__c);
        wrapperObj.site.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(fileObj.Simpplr_Content__r.Site__r.Site_Type__c);
        wrapperObj.site.chatterGroupId = fileObj.Simpplr_Content__r.Site__r.Chatter_Group_Id__c;
    }
    return wrapperObj;
}

/**
 * @description ReferenceTileWrapper converter
 * @return type of NativeVideoWrapper.ReferenceTileWrapper
 * @param tile-Config object - Tiles_Config__c
 */
private NativeVideoWrapper.ReferenceTileWrapper convertToTileWrapper(Tiles_Config__c tileObj){
    NativeVideoWrapper.ReferenceTileWrapper wrapperObj=new NativeVideoWrapper.ReferenceTileWrapper();
    
    wrapperObj.id = tileObj.Id;
    wrapperObj.url = PageContext.getPageURL(Pages.app) +'?u=/';
    if(String.isNotBlank(tileObj.Site__c)){
        wrapperObj.site = New SiteLiteWrapper();
        wrapperObj.site.siteid = tileObj.Site__c;
        wrapperObj.site.name = tileObj.Site__r.name;
        wrapperObj.site.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + tileObj.Site__c + '/' + tileObj.Site__r.Landing_Page__c;
        wrapperObj.url += 'site/'+tileObj.site__c+'/dashboard';
        wrapperObj.site.img = String.isBlank(tileObj.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor720By480(tileObj.Site__r.Title_Content_Version__c);
        wrapperObj.site.imgThumbnail= String.isBlank(tileObj.Site__r.Title_Content_Version__c)? null :Utility.getFileDownloadURLFor120BY90(tileObj.Site__r.Title_Content_Version__c);
        wrapperObj.site.access = tileObj.Site__r.Site_Type__c;
        wrapperObj.site.isActive = tileObj.site__r.Is_Active__c;
        wrapperObj.site.isPrivate = ServiceConstants.PRIVATE_SITE.equalsIgnoreCase(tileObj.Site__r.Site_Type__c);
        wrapperObj.site.isPublic = ServiceConstants.PUBLIC_SITE.equalsIgnoreCase(tileObj.Site__r.Site_Type__c);
        wrapperObj.site.isManager = UserContext.sitesIManageIdSet.contains(tileObj.Site__c);
        wrapperObj.site.isContentManager = UserContext.sitesIManageContentsIdSet.contains(tileObj.Site__c);
        wrapperObj.site.isListed = !ServiceConstants.UNLISTED_SITE.equalsIgnoreCase(tileObj.Site__r.Site_Type__c);
        wrapperObj.site.chatterGroupId = tileObj.Site__r.Chatter_Group_Id__c;
    }
    return wrapperObj;
}

@future (callout = true)
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
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    } catch(Exception ex) {
            markSiteSyncForNativeVideo(siteId);
            logger.logError(ex);
    }                           
}

    @future(callout = true)
    public static void createCategoryForCgToSite(String siteId, String siteName, String siteType, String siteOwnerId) {
        final String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';               
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', siteOwnerId);
        requestBody.put('siteId', siteId);
        requestBody.put('siteName', siteName);
        requestBody.put('siteType', siteType);
        requestBody.put('action', 'createCategoryForCgToSite');
        try {
            HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
            if(res.getStatusCode() == 200) {
                System.enqueueJob(new SyncNVSiteMemberQueuealbe());
            } 
        } catch(Exception ex) {
                markSiteSyncForNativeVideo(siteId);
                logger.logError(ex);
        }      
           
    }

    public class SyncNVSiteMemberQueuealbe implements System.Queueable {

        public void execute(System.QueueableContext ctx) { 
            BatchManageVideo job = new BatchManageVideo('syncSiteMembersToNativeVideoAws');
            Database.executeBatch(job, 100);
        }
    }


    @future (callout = true)
    public static void  addUserToGroup(String siteId, List<String> sfUserIdList) {
        List<People__c> peopleList = [SELECT Id FROM People__c WHERE User__c =: sfUserIdList WITH SECURITY_ENFORCED];
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('action', 'addUserToGroup');

        for(People__c peopleObj : peopleList){
            requestBody.put('userTobeAdded', peopleObj.Id);
            try {
                HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
                Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());              
            } catch(Exception ex) {
                logger.logError(ex);
            }  
        }               
    }

    @future (callout = true)
    public static void  addManagerToGroup(String siteId, String sfUserId) {
        List<people__c> peopleObj = [SELECT Id FROM people__c WHERE user__c =: sfUserId WITH SECURITY_ENFORCED];
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('userTobeAdded', peopleObj[0].Id);
        requestBody.put('action', 'addManagerToGroup');
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                  
    }

    @future (callout = true)
    public static void removeManagerFromGroup(String siteId, String sfUserId) {
        List<people__c> peopleObj = [SELECT Id FROM people__c WHERE user__c =: sfUserId WITH SECURITY_ENFORCED];
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('userTobeAdded', peopleObj[0].Id);
        requestBody.put('action', 'removeManagerFromGroup');
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                  
    }

    @future (callout = true)
    public static void removeUserFromGroup(String siteId, String sfUserId) {
        List<people__c> peopleObj = [SELECT Id FROM people__c WHERE user__c =: sfUserId WITH SECURITY_ENFORCED];
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('userTobeAdded', peopleObj[0].Id);
        requestBody.put('action', 'removeUserFromGroup');
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                  
    } 
    
    @future (callout = true)
    public static void publicToPrivate(String siteId, String siteType) {
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('siteType', siteType);
        requestBody.put('action', 'publicToPrivate');
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                  
    }

    @future (callout = true)
    public static void privateToPublic(String siteId, String siteType) {
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('siteType', siteType);
        requestBody.put('action', 'privateToPublic');
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                  
    }

    @future (callout = true)
    public static void makeOwner(String siteId, String sfUserId, Boolean isManager, String prevOwnerId) {
        List<people__c> peopleObj = [SELECT Id FROM people__c WHERE user__c =: sfUserId WITH SECURITY_ENFORCED];
        List<people__c> prevPeopleId = [SELECT Id FROM people__c WHERE user__c =: prevOwnerId WITH SECURITY_ENFORCED];
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('userTobeAdded', peopleObj[0].Id);
        requestBody.put('userTobeDeleted', prevPeopleId[0].Id);
        requestBody.put('isManager', isManager);
        requestBody.put('action', 'makeOwner');
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
        Map<String, Object> requestDataMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());                  
    }

    @future (callout = true)
    public static void updateCategoryName(String siteId, String name) {
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('siteId', siteId);
        requestBody.put('categoryName', name);
        requestBody.put('action', 'updatecategoryname');
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);                  
    }

     /* Utility method to move videos */
 	public Static Void  moveVideo(String toSiteId,List<String> listOfContentIdToMove){
        
        List<NativeVideoWrapper.videoMoveWrapper> videoObjList = new List <NativeVideoWrapper.videoMoveWrapper>();
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', listOfContentIdToMove);
        soqlParamMap.put('soqlParam2', ServiceConstants.VIDEO_PROVIDER_NATIVE);
        String filesQuery = 'SELECT id, Name,External_id__c,Simpplr_Content__c, Site__c, Simpplr_Content__r.site__c,'+
                ' Is_Deleted__c,Size__c  '+
                ' FROM File__C '+
                ' WHERE Is_Deleted__c = false AND'+
                ' Simpplr_Content__c IN :soqlParam1 AND repository__c=:soqlParam2';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<File__c> listOfFile = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
          if(listOfFile.size()>0){      
           For(File__c fileObj :listOfFile){
            NativeVideoWrapper.videoMoveWrapper videoObj = new NativeVideoWrapper.videoMoveWrapper() ;
            videoObj.oldSiteId = fileObj.Simpplr_Content__r.site__c ;
            videoObj.newSiteId = toSiteId ;
            videoObj.entryId = fileObj.External_id__c ;
            videoObj.size = Integer.valueOf(fileObj.size__c) ;
            videoObjList.add(videoObj);
           } 
        } 
        if(videoObjList.size()>0){
            VideoDao.sendVideoMoveDatatoAWS(videoObjList);
        }   
    }
    
    public static void sendVideoMoveDatatoAWS(List<NativeVideoWrapper.videoMoveWrapper> videoObjList) {
        String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint +'/video/site-manager';                
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('org_id', SimpplrContext.simpplrOrgId);
        requestBody.put('peopleId', UserContext.peopleId);
        requestBody.put('action', 'movevideo');
        requestBody.put('context', 'first');
        requestBody.put('videoList', videoObjList);
        HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
    }   
    
    /**
    * @description gets list of videos from Kaltura
    * @param requestParams request params
    * @return list of entries from kaltura
    **/
    public static VideoDataService.EntryListWrapper getVideoList(Map<String, Object> requestParams) {
        VideoDataService.EntryListWrapper entryList = new VideoDataService.EntryListWrapper();
        try {
            String ACCESS_TOKEN_ENDPOINT = SimpplrContext.simpplrAPIEndpoint +'/video/video-manager';                
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('org_id', SimpplrContext.simpplrOrgId);
            requestBody.put('peopleId', UserContext.peopleId);
            requestBody.put('action', 'getVideoList');
            requestBody.put('chunkSize', requestParams.get('chunkSize'));
            requestBody.put('pageIndex', requestParams.get('pageIndex'));
            if(requestParams.containsKey('createdAtLessThanOrEqual')){
                requestBody.put('createdAtLessThanOrEqual', requestParams.get('createdAtLessThanOrEqual'));
            }
            if(requestParams.containsKey('createdAtGreaterThanOrEqual')){
                requestBody.put('createdAtGreaterThanOrEqual', requestParams.get('createdAtGreaterThanOrEqual'));
            }
            logger.logDebug('requestBody ' + requestBody);
            HttpResponse res = Utility.getResponseFromAWS(ACCESS_TOKEN_ENDPOINT, requestBody);
            entryList = (VideoDataService.EntryListWrapper)JSON.deserialize(res.getBody(), VideoDataService.EntryListWrapper.class);
        } catch (Exception exp) {
            logger.logError(exp);
        }
        return entryList;
    }   

    public FileDetailWrapper toFileDetailWrapper(File__c FileObj) {
        FileDetailWrapper fileDetailWrapObj = new FileDetailWrapper();
        String siteId ;
        
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
        soqlParamMap.put('soqlParam1', fileObj.OwnerId);
        String query = 'select id,People__c,People__r.Full_Name__c,user__c from People_Preference__c where People__r.user__c =:soqlParam1';
       
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
        List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
        People_Preference__c peoplePreferenceObj = peoplePreferenceList[0];
        if(!string.isBlank(fileObj.site__c)){
            siteId =fileObj.site__c ;
        }else if(!string.isBlank(fileObj.simpplr_content__c)){
            siteId =fileObj.simpplr_content__r.site__c ;
        }
        fileDetailWrapObj.id = FileObj.External_Id__c;
        fileDetailWrapObj.context = ServiceConstants.VIDEO_PROVIDER_NATIVE;
        fileDetailWrapObj.provider = ServiceConstants.VIDEO_PROVIDER_NATIVE;
        fileDetailWrapObj.name = FileObj.title__c;
        Map<String, String> fileDetailParams = new Map<String, String>{'provider' => ServiceConstants.VIDEO_PROVIDER_NATIVE, 'fileId' => FileObj.External_Id__c};
        fileDetailWrapObj.title = FileObj.title__c;
        fileDetailWrapObj.fileType = fileDetailWrapObj.title.substring(FileObj.title__c.lastIndexOf('.')+1).toUpperCase();
        fileDetailWrapObj.type = fileDetailWrapObj.fileType;
        fileDetailWrapObj.fileExtension = fileDetailWrapObj.title.substring(fileDetailWrapObj.title.lastIndexOf('.')+1);
        fileDetailWrapObj.fileSize = fileObj.Size__c != null ? Utility.byteToHumanReadableFormate(fileObj.Size__c) : null;
        fileDetailWrapObj.size = fileObj.Size__c != null ? Integer.valueof(fileObj.Size__c):null ;
        fileDetailWrapObj.thumbnailImg = fileObj.Thumbnail_url__c;
        fileDetailWrapObj.lastModifiedDate = String.valueOf(fileObj.lastModifiedDate);
        fileDetailWrapObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(fileObj.lastModifiedDate);
        fileDetailWrapObj.description = fileObj.description__c;
        fileDetailWrapObj.videoStatus = fileObj.Video_Status__c !=null ? Integer.valueOf(fileObj.Video_Status__c):1 ;
        if(String.isNotBlank(fileDetailWrapObj.description)) {
            fileDetailWrapObj.htmlDescription = fileDetailWrapObj.description.replace('\n','<br>');
        }
            
        fileDetailWrapObj.owner.Id = peoplePreferenceObj.People__c;
        fileDetailWrapObj.owner.Name = peoplePreferenceObj.People__r.Full_Name__c;
        fileDetailWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + peoplePreferenceObj.People__c;
        fileDetailWrapObj.canDelete = UserContext.peopleId.equalsIgnoreCase(fileDetailWrapObj.Owner.id);
        
        if(!string.isBlank(fileObj.folder__c)){
            fileDetailWrapObj.directory = new FileDetailWrapper.DirectoryWrapper();
            fileDetailWrapObj.directory.id = fileDetailWrapObj.id;
            fileDetailWrapObj.directory.name = FileObj.folder__r.name__c; 
            
        }
        if(!String.isBlank(siteId)){
            fileDetailWrapObj.listOfSite = fetchSiteInfo(siteId) ;
        }    	
    	return fileDetailWrapObj; 
    }

    public List<SiteLiteWrapper> fetchSiteInfo(id siteId){
        SiteLiteWrapper siteInfo = new SiteLiteWrapper() ;
        List<SiteLiteWrapper> siteWrapList = new List<SiteLiteWrapper>();
        Simpplr_Site__c siteObj;
        string query = 'SELECT Active_Tiles__c,Active_Widgets__c,Allowed_Features__c,Allow_Public_Contribution__c,'+ 
                       'Banner_Content_Document__c,Carousel_Content__c,Chatter_Group_Id__c,Content_Version_Id__c, '+
                       'Cover_Content_Document__c,Cover_Content_Version__c,Cover_Image_Enabled__c,CreatedById, '+
                       'CreatedDate,Dashboard_Layout__c,Dashboard_Settings__c,Feed_Active__c,File_Storage_Source__c, '+
                       'Has_Albums__c,Has_Events__c,Has_Pages__c,Id,IsActive__c,IsDefault__c,IsDeleted,isFeatured__c, '+
                       'Is_Active__c,Is_Alert_Enabled__c,Is_Deleted__c,Is_Featured__c,Is_Must_Read_Enabled__c, '+
                       'Is_Newsletter_Allowed__c,Landing_Page__c,LastActivityDate,LastModifiedById,LastModifiedDate, '+
                       'Last_Edited_DateTime__c,Metadata__c,Name,Order__c,Origin__c,OwnerId,Show_In_Simpplr__c, '+
                       'Site_Category__c,Site_Config__c,Site_Links__c,Site_Type__c,SystemModstamp,Tags__c, '+
                       'Title_Content_Document__c,Title_Content_Version__c FROM Simpplr_Site__c WHERE id =:siteId LIMIT 1 ' ;
        siteObj = Database.query(query);
        siteInfo.name =  siteObj.name;
        siteInfo.access = siteObj.Site_Type__c ;
        siteInfo.siteId = siteObj.id ;
        siteInfo.isPrivate = siteObj.Site_Type__c == 'private'?true:false ;
        siteInfo.url = 	PageContext.getPageURL(Pages.app) + '?u=/site/' + siteObj.id +'/dashboard';
        siteWrapList.add(siteInfo);
        return siteWrapList;
        
    }

    public void updateVideoStatus(String entryId, Integer status) {
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1',entryId);

        String filesQuery = 'SELECT id, Video_Status__c FROM File__c'+ 
                                ' WHERE External_Id__c =: soqlParam1'+
                                ' AND (Repository__c = \'native_video\' OR Video_Provider__c = \'native_video\')';

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
        for(File__c fileObj : fileList) {
            fileObj.Video_Status__c = status;
        }
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{
                                                    File__c.Video_Status__c
                                                });
    }

    public Map<String, List<NativeVideoWrapper.ReferenceItemWrapper>> getReferencesForVideos (Set<String> entryIds, Set<String> feedIdsSetAll) {
        Map<String, List<NativeVideoWrapper.ReferenceItemWrapper>> refrencesMap = new Map<String, List<NativeVideoWrapper.ReferenceItemWrapper>>();
        Map<String,String> resultMap = new Map<String,String>();
        Set<Id> siteIdSet = UserContext.sitesIFollowIdSet;
        String loggedInPeopleId = UserContext.peopleId;

        Map<String, Object> soqlParamMap2 = new Map<String, Object>();
        soqlParamMap2.put('soqlParam1', feedIdsSetAll);
        String feedQuery = 'Select Id, isDeleted , status From FeedItem where id IN:soqlParam1 And isDeleted = false';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<FeedItem> feedItemList = (List<FeedItem>)SIMPESAPI.accessController().queryAsUser(feedQuery, soqlParamMap2);
        List<String> feedIdsSet = new List<String>();
        for(FeedItem feedItemObj:feedItemList){
            feedIdsSet.add(feedItemObj.id);
        }

        String unlistedCondition ='';
        String systemAdminCondition ='';
        if(UserContext.hasManageUnlistedSitePermission ){ 
            unlistedCondition = ' OR site__r.site_type__c =\'Unlisted\''	;	
        }
        if(UserContext.hasModifyAllDataPermission ){
            systemAdminCondition = ' OR site__r.site_type__c =\'private\''	;	
        }
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', ServiceConstants.VIDEO_PROVIDER_NATIVE);
        soqlParamMap.put('soqlParam2', entryIds);
        soqlParamMap.put('soqlParam5', siteIdSet);
        soqlParamMap.put('soqlParam6', feedIdsSet);
        String fileQuery = 'Select Id, Simpplr_Content__c, video_provider__c, external_id__c, ' +
                ' Site__c, Site__r.Name ,Site__r.Landing_Page__c,Simpplr_Content__r.Is_Published__c,' +
                ' Simpplr_Content__r.Status__c, Simpplr_Content__r.Primary_Author__r.User__c,Question__c, OwnerId,' +
                ' Order__c, Name,title__c, LastModifiedDate, Is_Deleted__c,site__r.Is_Active__c,Site__r.Chatter_Group_Id__c,' +
                ' LastModifiedById, Folder__c, Feed_Item__c,createdDate, Feed_Comment__c, CreatedById ,Site__r.Site_Type__c,' +
                ' Thumbnail_URL__c,Location__c,Is_Title_Image__c,MIME_Type__c,Content_Version__c,' +
                ' Simpplr_Content__r.id,Simpplr_Content__r.Title__c,Simpplr_Content__r.Type__c,Simpplr_Content__r.Cover_Image_Layout__c,' +
                ' Simpplr_Content__r.Title_Image_Caption__c,Simpplr_Content__r.Site__r.name,Simpplr_Content__r.Site__r.Title_Content_Version__c,' +
                ' Simpplr_Content__r.Site__r.Landing_Page__c,Simpplr_Content__r.Site__r.Site_Type__c,Simpplr_Content__r.site__r.Is_Active__c,' +
                ' Simpplr_Content__r.Site__r.Chatter_Group_Id__c,Simpplr_Content__r.Primary_Author__c,Simpplr_Content__r.Primary_Author__r.User__r.Id,' +
                ' Simpplr_Content__r.Primary_Author__r.Full_Name__c,Simpplr_Content__r.Primary_Author__r.User__r.TimezoneSidKey,' +
                ' Simpplr_Content__r.Primary_Author__r.User__r.FullPhotoURL,Simpplr_Content__r.Primary_Author__r.title__c,Simpplr_Content__r.Primary_Author__r.city__c,' +
                ' Simpplr_Content__r.Primary_Author__r.state__c,Simpplr_Content__r.Primary_Author__r.country__c,' +
                ' Simpplr_Content__r.Primary_Author__r.Department__c,Simpplr_Content__r.Primary_Author__r.User__r.isActive,' +
                ' Simpplr_Content__r.Primary_Author__r.User__r.MediumPhotoURL,Simpplr_Content__r.Publish_Start_DateTime__c,Simpplr_Content__r.Is_Deleted__c, Author__c' +
                ' From File__c where Is_Deleted__c = false and (Video_Provider__c =: soqlParam1 OR Repository__c =: soqlParam1)' +
                ' and (feed_Item__c =null OR feed_Item__c IN :soqlParam6)' +
                ' and (Site__c = null OR ( site__r.is_Active__c=true And (site__c IN:soqlParam5 or site__r.site_type__c =\'Public\''+unlistedCondition + systemAdminCondition+')))' +
                ' and (Simpplr_Content__c = null OR (( Simpplr_Content__r.Site__c = null and  Simpplr_Content__r.Is_Published__c = true and Simpplr_Content__r.Is_Deleted__c = false) or (Simpplr_Content__r.Site__c != null and  Simpplr_Content__r.Is_Published__c = true and Simpplr_Content__r.Is_Deleted__c = false and Simpplr_Content__r.Site__r.Is_Active__c = true)))' +
                ' and External_Id__c IN: soqlParam2';

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<File__c> fileObjList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(fileQuery, soqlParamMap);

        for(File__c fileObj : fileObjList){
            List<NativeVideoWrapper.ReferenceItemWrapper> result = new List<NativeVideoWrapper.ReferenceItemWrapper>();
            if(refrencesMap.containsKey(fileObj.External_Id__c)){
                result.addAll(refrencesMap.get(fileObj.External_Id__c));
            }
            NativeVideoWrapper.ReferenceItemWrapper itemWrapperObj = new NativeVideoWrapper.ReferenceItemWrapper();
            if(String.isNotBlank(fileObj.Site__c) && String.isNotBlank(fileObj.Feed_Item__c) && String.isBlank(fileObj.Simpplr_Content__c)){
                //site feed post
                NativeVideoWrapper.ReferenceFeedWrapper feedWrapperObj=convertToFeedWrapper(fileObj);
                itemWrapperObj.id=fileObj.id;
                itemWrapperObj.feedPost=feedWrapperObj;
                itemWrapperObj.peopleId=fileObj.Author__c;
                itemWrapperObj.isSiteFeedPost=true;
                itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

                result.add(itemWrapperObj);

            }else if(String.isNotBlank(fileObj.Site__c) && String.isNotBlank(fileObj.Simpplr_Content__c) && String.isBlank(fileObj.Feed_Item__c)){
                //site content
                NativeVideoWrapper.ReferenceContentWrapper contentWrapperObj=convertToContentWrapper(fileObj);
                itemWrapperObj.id=fileObj.id;
                itemWrapperObj.content=contentWrapperObj;
                itemWrapperObj.peopleId=fileObj.Author__c;
                itemWrapperObj.isContent=true;
                itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

                result.add(itemWrapperObj);

            }else if(String.isNotBlank(fileObj.Simpplr_Content__c) && String.isBlank(fileObj.Site__c) && String.isBlank(fileObj.Feed_Item__c)){
                //Blog Post
                NativeVideoWrapper.ReferenceContentWrapper contentWrapperObj=convertToContentWrapper(fileObj);
                itemWrapperObj.id=fileObj.id;
                itemWrapperObj.content=contentWrapperObj;
                itemWrapperObj.peopleId=fileObj.Author__c;
                itemWrapperObj.isBlog=true;
                itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

                result.add(itemWrapperObj);

            }else if(String.isBlank(fileObj.Site__c) && String.isNotBlank(fileObj.Feed_Item__c) && String.isBlank(fileObj.Simpplr_Content__c)){
                //home feed
                NativeVideoWrapper.ReferenceFeedWrapper feedWrapperObj=convertToFeedWrapper(fileObj);
                itemWrapperObj.id=fileObj.id;
                itemWrapperObj.feedPost=feedWrapperObj;
                itemWrapperObj.peopleId=fileObj.Author__c;
                itemWrapperObj.isHomeFeedPost=true;
                itemWrapperObj.videoUploadDate=fileObj.createdDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');

                result.add(itemWrapperObj);

            }
            refrencesMap.put(fileObj.External_Id__c,result);
        }
        return refrencesMap;

    }
    
    /**
    * @description get files list for given entry Id
    * @param entryIdSet entry Id set
    * @return list of native video file records 
    **/
    public static List<File__c> getNativeVideoFileRecords(Set<String> entryIdSet){
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('soqlParam1', 'native_video');
        soqlParamMap.put('soqlParam2', entryIdSet);
        String queryStr = 'SELECT Id, Is_Deleted__c, External_Id__c FROM FILE__c WHERE External_Id__c IN :soqlParam2 AND (Repository__c = :soqlParam1 OR Video_Provider__c = :soqlParam1)';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<File__c> fileObjList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
        return fileObjList;
    }

    /**
    * @description delete orphan native videos and ensure records not exists in File__c
    * @param orphanEntryIdSet kaltura video entry id
    **/
    public static void deleteOrphanNativeVideos(Set<String> orphanEntryIdSet){
        if(orphanEntryIdSet != null && !orphanEntryIdSet.isEmpty()){
            //double ensure references not exists in File__c
            //delete only if records is empty
            List<File__c> fileObjList = VideoDao.getNativeVideoFileRecords(orphanEntryIdSet);
            logger.logDebug('deleteOrphanNativeVideos.fileObjList => ' + fileObjList);
            if(fileObjList.isEmpty()){
                logger.logDebug('deleting orphan native videos..');
                VideoDao videoObj = new VideoDao();
                videoObj.deleteVideo(orphanEntryIdSet);
            }
        }
    }
    
    /**
    * @description cleanup Orphan Native Videos from Kaltura
    * @param requestParams request params
    * @return VideoDataService.EntryListWrapper entry list wrapper
    **/
    public VideoDataService.EntryListWrapper orphanNativeVideoList(Map<String, Object> requestParams){
        VideoDataService.EntryListWrapper entryListWrapper = new VideoDataService.EntryListWrapper(); 
        try{
            Integer chunkSize = (Integer)requestParams.get('chunkSize');
            Integer pageIndex = (Integer)requestParams.get('pageIndex');
            entryListWrapper = VideoDao.getVideoList(requestParams);
            if(entryListWrapper.objects != null && !entryListWrapper.objects.isEmpty()){
                
                Set<String> kalturaEntryIdSet = new Set<String>();
                for(VideoDataService.EntryWrapper entryWrapper: entryListWrapper.objects){
                    logger.logDebug('entryWrapper => ' + entryWrapper);
                    kalturaEntryIdSet.add(entryWrapper.id);
                }

                logger.logDebug('kalturaEntryIdSet => ' + kalturaEntryIdSet);

                Set<String> entryIdSet = new Set<String>();
                List<File__c> fileObjList = VideoDao.getNativeVideoFileRecords(kalturaEntryIdSet);
                if(fileObjList != null && !fileObjList.isEmpty()){
                    for(File__c fileObj: fileObjList){
                        entryIdSet.add(fileObj.External_Id__c);
                    }
                }

                logger.logDebug('entryIdSet => ' + entryIdSet);

                kalturaEntryIdSet.removeAll(entryIdSet);
                entryListWrapper.orphanEntryIdSet = kalturaEntryIdSet;

                logger.logDebug('delete kalturaEntryIdSet => ' + kalturaEntryIdSet);

            } //END-entryListWrapper.objects

            entryListWrapper.nextPageIndex = (entryListWrapper.totalCount > chunkSize * pageIndex) ? pageIndex + 1 : null;

            logger.logDebug('entryListWrapper => ' + entryListWrapper);

        } catch (Exception exp) {
            logger.logError(exp);
        }
        return entryListWrapper;
    }

    /**
    * @description cleanup orphan videos from kaltura
    * @param createdAtGreaterThanOrEqual timesatmp in ms
    **/
    public void cleanupOrphanNativeVideos(Long createdAtGreaterThanOrEqual){
        Map<String, Object> requestParams = new Map<String, Object>();
        requestParams.put('chunkSize', 500);
        //atleast 1 day old orphan videos collect for cleanup
        Long createdAtLessThanOrEqual = DateTime.now().addDays(-1).getTime();
        requestParams.put('createdAtLessThanOrEqual', createdAtLessThanOrEqual/1000);
        //all orphan videos created in last 7 days
        if(createdAtGreaterThanOrEqual == null){
            createdAtGreaterThanOrEqual = DateTime.now().addDays(-7).getTime();
        }
        requestParams.put('createdAtGreaterThanOrEqual', createdAtGreaterThanOrEqual/1000);

        Integer pageIndex = 1;
        Set<String> orphanEntryIdSet = new Set<String>();
        while(pageIndex != null && Limits.getCallouts() < Limits.getLimitCallouts()){
            requestParams.put('pageIndex', pageIndex);
            VideoDataService.EntryListWrapper entryListWrapper = orphanNativeVideoList(requestParams);   
            pageIndex = entryListWrapper.nextPageIndex;
            if(entryListWrapper.orphanEntryIdSet != null){
                orphanEntryIdSet.addAll(entryListWrapper.orphanEntryIdSet);
            }
        }
        logger.logDebug('orphanEntryIdSet => ' + orphanEntryIdSet);
        VideoDao.deleteOrphanNativeVideos(orphanEntryIdSet);
    }


    /**
     * @description It is update Video_Provider_Sync_Status__c = 0 when res is not 200
     * @param siteId
    */
    private static void markSiteSyncForNativeVideo(String siteId){
        Map<String, Object> soqlParamMap = new  Map<String, Object>();
		soqlParamMap.put('soqlParam1', siteId);
        String simpplrSiteQuery = 'SELECT Id, Video_Provider_Sync_Status__c FROM Simpplr_Site__c WHERE id =: soqlParam1 ';
        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        List<Simpplr_Site__c> siteList = (List<Simpplr_Site__c>)SIMPESAPI.accessController().queryAsUser(simpplrSiteQuery, soqlParamMap);

        for(Simpplr_Site__c siteObj : siteList){
            siteObj.Video_Provider_Sync_Status__c = 0;
        }

        SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
        SIMPESAPI.accessController().updateAsUser(new Map<Id, Simpplr_Site__c>(siteList), new List<Schema.SObjectField>{
                                                        Simpplr_Site__c.Video_Provider_Sync_Status__c
                                              });
    }

    public void syncPeopleData() {
        logger.logDebug('VideoDao.syncPeopleData()----');
        String ENDPOINT = SimpplrContext.simpplrAPIEndpoint + '/video/site-manager';
        Map<String, Object> requestBody = new Map<String, Object>();     
        try {
            
            requestBody.put('action', 'syncpeopledata');
            requestBody.put('org_id', SimpplrContext.simpplrOrgId);
            requestBody.put('peopleId', UserContext.peopleId);
            requestBody.put('userTobeAdded', UserContext.peopleId);  
            HttpResponse res = Utility.getResponseFromAWS(ENDPOINT, requestBody);
        
        } catch(Exception ex) {
            logger.logError(ex);
        } 
    }
}