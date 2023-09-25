public with sharing class VideoDataService {



	public FileDetailWrapper getVideoDetails (String requestData){
		FileDetailWrapper fileDetailWrapObj = new FileDetailWrapper();
		FileDetailWrapper.SiteWrapper siteWrpObj = new FileDetailWrapper.SiteWrapper();
        
		Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
		String fileId = (String) requestMap.get('id');

		if (!SimpplrContext.Integrations.containsKey(ServiceConstants.VIDEO_PROVIDER_NATIVE)) {
			throw new SimpplrException(ServiceConstants.ERROR_404);
		}else {
			file__c fileObj = FileDao.getFileRecordDetails(fileId);
			if(fileObj == null) {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}

			return convertFileToFileDetailedWrapper(fileObj);
		}
	}

	public void updateVideoCaptionStatusInfo(String requestData) {
		logger.logDebug('VideoDataServiceupdateVideoCaptionStatusInfo() '+ requestData);
       
        CaptionStatusWrapper data = (CaptionStatusWrapper)JSON.deserialize(requestData, CaptionStatusWrapper.class);

		String entityId = data.entityId;
		Integer captionStatus = data.captionStatus;
		List<File__c> fileList = [SELECT Id, External_id__c, Video_Caption_Status__c FROM File__c WHERE External_id__c = :entityId WITH SECURITY_ENFORCED];
	
		for(File__c file: fileList){
			file.Video_Caption_Status__c = captionStatus;
		}

		if(fileList.isEmpty() == false){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{
                File__c.Video_Caption_Status__c
			});
		}
    }

	public void updateVideoFileRecords(String requestData) {
		logger.logDebug('VideoDataService.updateVideoFileRecords() '+ requestData);
       
        EntryIdsWrapper data = (EntryIdsWrapper)JSON.deserialize(requestData, EntryIdsWrapper.class);

		Set<String> entryIdsSet = data.entryIdsSet;
		List<File__c> fileList = [SELECT Id, External_id__c, is_deleted__c FROM File__c WHERE External_id__c IN :entryIdsSet WITH SECURITY_ENFORCED];
	
		for(File__c file: fileList){
			file.is_deleted__c = false;
		}

		if(fileList.isEmpty() == false){
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileList), new List<Schema.SObjectField>{
                File__c.is_deleted__c
			});
		}
    }

	/**
     * @description this method search for videos within Salesforce without API callout - NEWSLETTER
     * @return NativeVideoWrapper.VideoResultWrapper 
     * @param requestData string value
     */
	public NativeVideoWrapper.VideoResultWrapper search(String requestData) {
		logger.logDebug('VideoDataService.search() '+ requestData);
		NativeVideoWrapper.videoSearchFilter fileCriteriaObj = (NativeVideoWrapper.videoSearchFilter) JSON.deserialize(requestData, NativeVideoWrapper.videoSearchFilter.class);
		String term = String.isBlank(fileCriteriaObj.term) ? '' : EncodingUtil.urlEncode(fileCriteriaObj.term, 'UTF-8').replaceAll('\\+','%20');
		Integer offset = 0;
        if (fileCriteriaObj.nextPageToken != null && Integer.valueOf(fileCriteriaObj.nextPageToken) > 0) {
			offset =  Integer.valueOf(fileCriteriaObj.nextPageToken);
		}
		
		String endpoint = SimpplrContext.simpplrAPIEndpoint + '/video/search-manager?';
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('orgId', UserInfo.getOrganizationId());
		requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('action', 'search');
		requestBody.put('offset', offset);
		requestBody.put('searchTerm', term);
		requestBody.put('pageSize', fileCriteriaObj.size);
		
		if(fileCriteriaObj.site != null){
			requestBody.put('site', fileCriteriaObj.site);
		}
		if(fileCriteriaObj.owner != null){
			requestBody.put('owner', fileCriteriaObj.owner);
		}
		HttpResponse reponseString = Utility.getResponseFromAWS(endpoint, requestBody);
		NativeVideoWrapper.VideoResultWrapper resultWrapper = convertNativeVideoResponseToWrapper(reponseString.getBody());
		resultWrapper.nextPageToken = (offset + fileCriteriaObj.size) >= (Integer) resultWrapper.totalRecords ? null : offset + fileCriteriaObj.size ;
		return resultWrapper;
    }

	/**
     * @description this method send videos from Salesforce without API callout - NEWSLETTER
     * @return List<FileDetailWrapper> list all files wrapper
     * @param ids string value
     */
	public NativeVideoWrapper.VideoResultWrapper getByIds(String ids) {
		List<String> idsList = (List<String>)JSON.deserialize(ids, List<String>.class);
		ids = string.join(idsList,',');
		logger.logDebug('VideoDataService.getByIds() '+ ids);

		String endpoint = SimpplrContext.simpplrAPIEndpoint + '/video/search-manager?';
		Map<String, Object> requestBody = new Map<String, Object>();
		requestBody.put('orgId', UserInfo.getOrganizationId());
		requestBody.put('peopleId', UserContext.peopleId);
		requestBody.put('action', 'getbyids');
		requestBody.put('videoIds', ids);

		HttpResponse reponseString = Utility.getResponseFromAWS(endpoint, requestBody);
		return convertNativeVideoResponseToWrapper(reponseString.getBody());
    }

	/**
     * @description this method converts File__c record to fileWrapper with all keys
     * @return FileDetailWrapper convertedWrapper
     * @param fileObj File__c object value
     */
	public FileDetailWrapper convertFileToFileDetailedWrapper(File__c fileObj) {
		FileDetailWrapper fileDetailWrapObj = new FileDetailWrapper();
		FileDetailWrapper.SiteWrapper siteWrpObj = new FileDetailWrapper.SiteWrapper();
		String provider = 'native_video';
		FileDao fileDaoObj = new FileDao();
		String collaborationGroupId ;   
		String directoryArg ;
		String fileId = fileObj.External_Id__c;

		if (fileObj.Repository__c == 'native_video' && !SimpplrContext.isNativeVideo) {
			fileDetailWrapObj.isAccessible = false;
		} else {
			fileDetailWrapObj.isAccessible = !fileObj.is_Deleted__c;
		}
		fileDetailWrapObj.videoStatus = 1; 
		if (fileObj.Video_Status__c != null) {
			fileDetailWrapObj.videoStatus = Integer.valueOf(fileObj.Video_Status__c);
		}
		collaborationGroupId = fileObj.Simpplr_Content__r.Site__r.Chatter_Group_Id__c ;
		if(String.isNotBlank(collaborationGroupId)
			&& (SiteContext.isPrivateSite || SiteContext.isUnlistedSite)
			&& !UserContext.isUserAppModerator
			&& !UserContext.hasModifyAllDataPermission 
			&& !UserContext.chatterGroupsIFollowIdSet.contains(collaborationGroupId)){

			throw new SimpplrException(ServiceConstants.ERROR_404);
		}else{
			Boolean isSiteManager = false; 
			Boolean isContentManager = false;
			if(String.isNotBlank(fileObj.Site__c)) {
				isSiteManager = (UserContext.sitesIManageIdSet).contains(fileObj.Site__c);
				isContentManager = (UserContext.sitesIManageContentsIdSet).contains(fileObj.Site__c);
			}
			Boolean isAuthor = UserContext.peopleId.equalsIgnoreCase(fileObj.Author__c);
			
			String siteVideosFolderId = fileDaoObj.getSiteVideosFolderId(fileObj.Site__c);
			if(String.isNotBlank(siteVideosFolderId) && 
			(siteVideosFolderId.equalsIgnoreCase(fileObj.Folder__c) || 
				(String.isNotBlank(fileObj.Folder__r.Path__c) && 
				fileObj.Folder__r.Path__c.startsWith(siteVideosFolderId))) &&
			(SiteContext.isCurrentUserSiteManager ||
			(UserContext.isUserAppModerator && SiteContext.isPublicSite))){
				fileDetailWrapObj.canMove = true;	
			}else{
				fileDetailWrapObj.canMove = false;		
			}
			fileDetailWrapObj.title = fileObj.Title__c ;
			fileDetailWrapObj.type = fileObj.MIME_Type__c.toUppercase() ;	
			fileDetailWrapObj.fileExtension = fileDetailWrapObj.title!=null ?fileDetailWrapObj.title.substring(fileDetailWrapObj.title.lastIndexOf('.')+1):null;
			fileDetailWrapObj.fileSize = fileObj.Size__c != null ? Utility.byteToHumanReadableFormate(fileObj.Size__c).toUppercase() : null;
			fileDetailWrapObj.size = fileObj.Size__c != null ? Integer.valueof(fileObj.Size__c):null ;
			fileDetailWrapObj.thumbnailImg = fileObj.Thumbnail_url__c;
			fileDetailWrapObj.lastModifiedDate =  Utility.dateTimeToMomentJSDateTime(fileObj.lastModifiedDate);
			fileDetailWrapObj.owner.Id = fileObj.Author__c;
			fileDetailWrapObj.owner.Name = fileObj.Author__r.Full_Name__c;
			fileDetailWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + fileObj.Author__c;
			fileDetailWrapObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(fileObj.lastModifiedDate);
			fileDetailWrapObj.uploadedAt = Utility.dateTimeToMomentJSDateTime(fileObj.CreatedDate);
			if (UserContext.isUserAppModerator || (fileObj.site__c == null && UserContext.peopleId.equalsIgnoreCase(fileObj.Author__c))) {
				fileDetailWrapObj.canDelete = true;
			}
			if(UserContext.isUserAppModerator || isSiteManager || isContentManager || isAuthor) {
				fileDetailWrapObj.canEdit = true;
			}
			fileDetailWrapObj.listOfSite = FileDao.getListOfSites(fileId);
			fileDetailWrapObj.canDownload = false;
			fileDetailWrapObj.id = fileObj.External_Id__c;
			fileDetailWrapObj.isFavorited = fileDaoObj.isFileBookmarked(fileObj.External_Id__c, ServiceConstants.VIDEO_PROVIDER_NATIVE);
			fileDetailWrapObj.isLiked = fileDaoObj.isFileLiked(fileObj.External_Id__c);
			fileDetailWrapObj.likedCount = fileDaoObj.getFileLikes(fileObj.External_Id__c).size();
			fileDetailWrapObj.canCreateNewVersion = false ;
			fileDetailWrapObj.description = fileObj.description__c;
			fileDetailWrapObj.context = ServiceConstants.VIDEO_PROVIDER_NATIVE; 
			fileDetailWrapObj.provider = provider; 
			if(String.isNotBlank(fileObj.Video_Caption_Language__c)){
				fileDetailWrapObj.language = Integer.valueof(fileObj.Video_Caption_Language__c);
			} else {
				fileDetailWrapObj.language = 0; //Incase video caption language id is null
			}
			//added additional flags for add campaign
			if(!string.isBlank(fileObj.site__c)){
				siteWrpObj.id = fileObj.site__c ;
				siteWrpObj.name = fileObj.site__r.Name ;
				siteWrpObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + fileObj.site__c + '/' + fileObj.site__r.Landing_Page__c ;
				siteWrpObj.isManager = isSiteManager;
				siteWrpObj.isOwner = UserContext.siteIOwnMap.containsKey(fileObj.Site__c) ? true : false;
				siteWrpObj.hasCampaigns = fileObj.Site__r.Has_Campaigns__c;
			}else if(!string.isBlank(fileObj.simpplr_content__c)){
				siteWrpObj.id =fileObj.simpplr_content__r.site__c ;
				siteWrpObj.name = fileObj.simpplr_content__r.site__r.Name ;
				siteWrpObj.url = PageContext.getPageURL(Pages.app) +'?u=/site/' + fileObj.simpplr_content__r.site__c + '/' + fileObj.site__r.Landing_Page__c ;
				siteWrpObj.isManager = isSiteManager;
				siteWrpObj.isOwner = UserContext.siteIOwnMap.containsKey(fileObj.Simpplr_Content__r.Site__c) ? true : false;
				siteWrpObj.hasCampaigns = fileObj.Simpplr_Content__r.Site__r.Has_Campaigns__c;
			}
			fileDetailWrapObj.site = siteWrpObj;
			fileDetailWrapObj.publicUrl = PageContext.getPageURL(Pages.app) +'?u=/video/' + fileObj.External_Id__c + '&fileId=' + fileObj.External_Id__c + '&provider=' +ServiceConstants.VIDEO_PROVIDER_NATIVE ;
			fileDetailWrapObj.url = fileDetailWrapObj.publicUrl;
			fileDetailWrapObj.fileId = fileObj.id;
			if(!string.isBlank(siteWrpObj.id) && !Test.isRunningTest()){
				directoryArg = fileObj.folder__c != null ? fileObj.folder__c:'';
				fileDetailWrapObj.listOfParents = FileContentProvider.getListOfParents(siteWrpObj.id, ServiceConstants.VIDEO_PROVIDER_NATIVE, directoryArg, fileId);
			}

			fileDetailWrapObj.videoCaptionStatus = Integer.valueOf(fileObj.Video_Caption_Status__c);
			if(fileObj.Video_Caption_Status__c == null){
				fileDetailWrapObj.videoCaptionStatus = ServiceConstants.CAPTION_STATUS_MAP.get('inProgress');

			} else if(fileObj.Video_Caption_Status__c == ServiceConstants.CAPTION_STATUS_MAP.get('inProgress')){
				VideoDao videoDaoObj = new VideoDao();

				Integer videoCaptionStatus = videoDaoObj.getVideoCaptionStatus(fileObj.External_Id__c);
				fileDetailWrapObj.videoCaptionStatus = videoCaptionStatus;
			}

		}
		
		if (fileDetailWrapObj.listOfParents != null && fileDetailWrapObj.listOfParents.size() > 0) {
			Integer parentIndex = fileDetailWrapObj.listOfParents.size() - 1;
			fileDetailWrapObj.directoryName = fileDetailWrapObj.listOfParents[parentIndex].name;
		
		} else {
			fileDetailWrapObj.directoryName = ServiceConstants.VIDEO_PROVIDER_NATIVE.capitalize() + ' Files';
		}

		return fileDetailWrapObj;
    }

	/**
     * @description this method converts responseStr from AWS to NativeVideoWrapper.VideoResultWrapper
     * @return NativeVideoWrapper.VideoResultWrapper convertedWrapper
     * @param responseStr String respomse body value
     */
	private NativeVideoWrapper.VideoResultWrapper convertNativeVideoResponseToWrapper(String responseStr) {
		NativeVideoWrapper.VideoResultWrapper resultWrapper = new NativeVideoWrapper.VideoResultWrapper();
		resultWrapper.listOfItems = new List<FileListingWrapper>();
		
		Map<String, Object> respObj = (Map<String, Object>) JSON.deserializeUntyped(responseStr);
		if('KalturaAPIException'.equalsIgnoreCase((String) respObj.get('objectType')) == true) { 
			throw new SimpplrException((String) respObj.get('message'));
		}

		if(respObj.get('objects') != null){

			List<Object> objectList = (List<Object>) respObj.get('objects');
			Set<String> entryIdSet = new Set<String>();
			Map<String, Integer> mapOfVideoDuration = new Map<String, Integer>();
			for(Object objElem : objectList){
				Map<String, Object> videoObj = (Map<String, Object>) objElem;
				if(videoObj.containsKey('object')){
					videoObj = (Map<String, Object>) videoObj.get('object');
				}
				String fileExternalId = (String) videoObj.get('id');
				mapOfVideoDuration.put(fileExternalId, (Integer) videoObj.get('duration'));
				entryIdSet.add(fileExternalId);
			}

			List<File__c> fileList = new List<File__c>();
			Map<String, File__c> fileMap = new Map<String, File__c> ();
			Map<String, List<SiteLiteWrapper>> fileToSiteWrapperListMap = new Map<String, List<SiteLiteWrapper>> ();
			Map<String, Set<String>> fileToSiteIdsMap = new Map<String, Set<String>> ();
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', entryIdSet);
			Map<String, Boolean> extIdVSisHomefeedMap = new Map<String, Boolean>();
			if(entryIdSet.isEmpty() == false){
				String filesQuery = 'SELECT Id, Title__c, External_Id__c, MIME_Type__c, Author__c, Author__r.Full_Name__c,'+
											' Author__r.User__c, LastModifiedDate, Size__c, Site__r.Name, Site__r.Site_Type__c,'+
											' Site__r.Landing_Page__c ,Simpplr_Content__c, Feed_Item__c, Video_Provider__c, Repository__c, video_status__c '+
											' FROM File__c WHERE External_Id__c IN :soqlParam1 and is_Deleted__c = false ORDER BY createdDate';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
				Set<String> feedIdsSet = new Set<String>();
				for(File__c fileObj : fileList) {
					if(!fileMap.containsKey(fileObj.External_Id__c)){
						fileMap.put(fileObj.External_Id__c, fileObj);
					}
					if(String.isNotBlank(fileObj.Site__c)){
						Set<String> siteIds = new Set<String>();
						List<SiteLiteWrapper> listOfSite = new List<SiteLiteWrapper>();
						if(fileToSiteIdsMap.containsKey(fileObj.External_Id__c)){
							siteIds.addAll(fileToSiteIdsMap.get(fileObj.External_Id__c));
							listOfSite.addAll(fileToSiteWrapperListMap.get(fileObj.External_Id__c));
						}
						if(!siteIds.contains(fileObj.Site__c)){
							SiteLiteWrapper siteWrapObj= new SiteLiteWrapper();
							siteWrapObj.siteId = fileObj.Site__c;
							siteWrapObj.name = fileObj.Site__r.Name;
							siteWrapObj.access = fileObj.Site__r.Site_Type__c;
							siteWrapObj.url= PageContext.getPageURL(Pages.app) +'?u=/site/' + fileObj.Site__c + '/' + fileObj.Site__r.Landing_Page__c;
							siteIds.add(fileObj.Site__c);
							listOfSite.add(siteWrapObj);
							fileToSiteIdsMap.put(fileObj.External_Id__c, siteIds);
							fileToSiteWrapperListMap.put(fileObj.External_Id__c, listOfSite);
						}
					}
					if(String.isBlank(fileObj.Site__c) && String.isBlank(fileObj.Simpplr_Content__c) && String.isNotBlank(fileObj.Feed_Item__c)) {
						extIdVSisHomefeedMap.put(fileObj.External_Id__c, true);
					}
					if(String.isNotBlank(fileObj.Feed_Item__c) && (fileObj.Video_Provider__c == ServiceConstants.VIDEO_PROVIDER_NATIVE || fileObj.Repository__c == ServiceConstants.VIDEO_PROVIDER_NATIVE)) {
						feedIdsSet.add(fileObj.Feed_Item__c);
					}
				}
				
				for(String externalId : fileMap.keySet()){
					FileListingWrapper fileWrapperObj = new FileListingWrapper();
					fileWrapperObj.title = fileMap.get(externalId).Title__c;
					fileWrapperObj.name = fileMap.get(externalId).Title__c;
					fileWrapperObj.size = fileMap.get(externalId).Size__c != null ? fileMap.get(externalId).Size__c.longValue() : 0;
					fileWrapperObj.id = externalId;
					fileWrapperObj.fileId = externalId;
					fileWrapperObj.type = 'Video';
					fileWrapperObj.isVideo = true;
					fileWrapperObj.videoStatus = 1;
					if(fileMap.get(externalId).video_status__c != null){
						fileWrapperObj.videoStatus = Integer.valueOf(fileMap.get(externalId).video_status__c);
					}
					fileWrapperObj.owner.id = fileMap.get(externalId).Author__c;
					fileWrapperObj.owner.name = fileMap.get(externalId).Author__r.Full_Name__c;
					fileWrapperObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + fileWrapperObj.owner.id; 
					fileWrapperObj.context = ServiceConstants.VIDEO_PROVIDER_NATIVE;
					fileWrapperObj.provider = ServiceConstants.VIDEO_PROVIDER_NATIVE;
					DateTime dateTimeValue = fileMap.get(externalId).LastModifiedDate;
					fileWrapperObj.modifiedAt = dateTimeValue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
					fileWrapperObj.url = PageContext.getPageURL(Pages.app) + '?u=/video/' + externalId;
					fileWrapperObj.thumbnailImg = ServiceConstants.NATIVE_VIDEO_BASE_URL + SimpplrContext.Integrations.get(ServiceConstants.VIDEO_PROVIDER_NATIVE).External_Id__c +'/thumbnail/entry_id/' + fileMap.get(externalId).External_Id__c +'/width/550/height/480';

					fileWrapperObj.listOfSite = fileToSiteWrapperListMap.containsKey(externalId) ? fileToSiteWrapperListMap.get(externalId) : new List<SiteLiteWrapper>();
					fileWrapperObj.runTime = mapOfVideoDuration.get(externalId);
					fileWrapperObj.isInHomeFeed = extIdVSisHomefeedMap.keyset().contains(externalId) ? true : false;
					resultWrapper.listOfItems.add(fileWrapperObj);
				}
			}

		}
		resultWrapper.totalRecords = respObj.get('totalCount') != null ? (Integer) respObj.get('totalCount') : 0;
		return resultWrapper;
	}

	/**
	 * @description getVideoCaptions from response data
	 * @return FileListingWrapper.VideoCaptionWrapper caption wrapper
	 * @param fileExternalId String type video Id
	 * @param itemsData List<Object> type
	 */
	private FileListingWrapper.VideoCaptionWrapper getVideoCaptions(String fileExternalId, List<Object> itemsData) {
		FileListingWrapper.VideoCaptionWrapper vCWObj = new FileListingWrapper.VideoCaptionWrapper();
		vCWObj.totalRecords = 0;
		vCWObj.listOfItems = new List<FileListingWrapper.VideoCaptionItem>();

		for(Object itemObj : itemsData) {
			Map<String, Object> tempMap = (Map<String, Object>) itemObj;

			String itemType = (String)tempMap.get('itemsType');
			if('caption'.equalsIgnoreCase(itemType)) {
				vCWObj.totalRecords = (Integer)tempMap.get('totalCount');
				List<Object> captionMap = (List<Object>)tempMap.get('items');
				
				for(Object captionObj : captionMap) {
					Map<String, Object> captionObjMap = (Map<String, Object>)captionObj;

					FileListingWrapper.VideoCaptionItem vCItem = new FileListingWrapper.VideoCaptionItem();
					vCItem.id = (String)captionObjMap.get('captionAssetId');
					vCItem.text = (String)captionObjMap.get('line');
					vCItem.timeStamp = (Integer)((Integer)captionObjMap.get('startsAt'))/1000;

					vCWObj.listOfItems.add(vCItem);
				}
			}
		}
		
		return vCWObj;
	}

    public Boolean getVideoStorage() {
        Boolean videoStorageMoreThanEighty = true;
        try {
            Decimal consumedBandwidth;
            Decimal totalBandwidth;
            String analyticEndpoint = SimpplrContext.simpplrAPIEndpoint + '/video-analytics/analytics'; 
            HttpResponse res = getResponseFromKalturaMS(analyticEndpoint);
            string body = res.getBody();
            AnalyticResponse analyticResponse = (AnalyticResponse) System.JSON.deserialize(body, AnalyticResponse.class);
            consumedBandwidth = analyticResponse?.result?.consumedBandwidth != null ? analyticResponse?.result?.consumedBandwidth : 0.0;
            totalBandwidth = analyticResponse?.result?.totalBandwidth != null ? analyticResponse?.result?.totalBandwidth : 0.0;

            logger.logDebug('consumedBandwidth----' + consumedBandwidth);
            logger.logDebug('totalBandwidth----' + totalBandwidth);

            videoStorageMoreThanEighty = calculateVideoStorage(consumedBandwidth, totalBandwidth);
            logger.logDebug('videoStorageMoreThanEighty----' + videoStorageMoreThanEighty);

        } catch(Exception ex) {
            List<String> errorList = new List<String>();
            errorList.add(JSON.serialize(new Map<String, String>{
                'message' => 'analytic_microservice_error'
            })); 
            insertLogError(errorList);
            return false; 
        }
        return videoStorageMoreThanEighty;
    }

    private HttpResponse getResponseFromKalturaMS(String endpoint) {
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(endpoint);     
        req.setHeader('jwttoken', Utility.getJwtToken());
        req.setMethod('GET');
        req.setTimeout(60000);
        
        Http http = new Http();
        HttpResponse response = http.send(req);

        logger.logDebug('VideoDataService.getResponseFromKalturaMS()----endpoint----' + endpoint);
        logger.logDebug('VideoDataService.getResponseFromKalturaMS()----response body----' + response.getBody());
        
        if (response.getStatusCode() != 200) {
            throw new SimpplrException(ExceptionCode.UNEXPECTED_ERROR.name());
        }

        return response;                
    }


    private Boolean calculateVideoStorage(Decimal consumedBandwidth, Decimal totalBandwidth) {
        Decimal videoStoragePercentage = ((consumedBandwidth * 100.0) / totalBandwidth).setScale(2);
        Integer currentPercentLimit = Math.round(videoStoragePercentage);
        return currentPercentLimit > 80 ? true : false;
    } 

    private static void insertLogError(List<String> errorList){
        List<Logs__c> logList = new List<Logs__c>();
        for(String er : errorList) {
            Logs__c logsObj = new Logs__c();
            logsObj.Log_Data__c = er;
            logsObj.Log_Type__c = 'INFO';
            logsObj.Source_Info__c = 'Native_Video_Notification';
            logsObj.Is_Deleted__c = false;
            logList.add(logsObj);
        }
        if(logList.size() > 0) {
            SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
            SIMPESAPI.accessController().insertAsUser(logList, new List<Schema.SObjectField>{
                                                                                Logs__c.Log_Data__c,
                                                                                Logs__c.Log_Type__c,
                                                                                Logs__c.Source_Info__c,
                                                                                Logs__c.Is_Deleted__c});
        }
    }

    public class AnalyticResponse {
        public String message;
        public Result result;
    }

    public class Result {
        public Decimal consumedBandwidth;
        public Decimal totalBandwidth;
    }

    private class CaptionStatusWrapper{
        String entityId;
        Integer captionStatus;
    }

	private class EntryIdsWrapper{
        Set<String> entryIdsSet;
    }
	
    /**
     * @description kaltura videos entry list wrapper class
     */
    public class EntryListWrapper{
    	public String objectType;
    	public Integer totalCount;
		public Integer nextPageIndex;
		public Set<String> orphanEntryIdSet;
		public List<EntryWrapper> objects;
    }
    /**
     * @description kaltura videos entry wrapper class
     */
    public class EntryWrapper{
        public String id;
        public String name;
        public String status;
        public Long createdAt;
    }
	
}