public with sharing class VideoDataServer extends DataServer {
    private final String ACTION_VALUE_ADD_VIDEO = 'addVideoToCategory';
    private final String ACTION_VALUE_GET_VIDEO_ACCESS_TOKEN = 'getAccessToken';
    private final String ACTION_VALUE_REVOKE_VIDEO_ACCESS_TOKEN = 'revokeSession';
    private final String ACTION_VALUE_GET_THUMBNAIL = 'getThumbnail';
    private final String ACTION_VALUE_GET_VIDEO_REFERENCES = 'getVideoReferences';
    private final String ACTION_VALUE_ADD_TO_FOLDER = 'addToFolder';
    private final String ACTION_VALUE_UPDATE_VIDEO_STATUS = 'updateVideoStatus';
    private final String ACTION_VALUE_CREATE_VIDEO_FOLDERS = 'createVideoFolders';
    private final String ACTION_VALUE_PROCESS_NATIVE_VIDEO_DISABLE = 'processVideoDisable';
    private final String ACTION_VALUE_GET_CAPTIONS_LANGUAGES = 'getCaptionsLanguages';
    private final String ACTION_VALUE_UPDATE_CAPTION_STATUS = 'updateVideoCaptionStatusInfo';
    private final String ACTION_VALUE_UPDATE_VIDEO_FILES = 'updateVideoFiles';
    private final String ACTION_VALUE_SYNC_PEOPLE_DATA = 'syncPeopleData';
    private final String REQUEST_PARAM_DATA = 'data';
    private final String ACTION_VALUE_GET = 'get';
    private final String ACTION_VALUE_SEARCH = 'search';
    private final String ACTION_VALUE_GET_BY_IDS = 'getByIds';
    /*
	public transient final String STR_KEY_1 = 'files.system_folder.crm_files';
	public transient final String STR_KEY_2 = 'files.system_folder.box_files';
	public transient final String STR_KEY_3 = 'files.system_folder.site_files';
	public transient final String STR_KEY_4 = 'files.system_folder.content_files';
	public transient final String STR_KEY_5 = 'files.system_folder.site_videos';
	public transient final String STR_KEY_6 = 'files.system_folder.feed_files';
	public transient final String STR_KEY_7 = 'files.system_folder.images';
	public transient final String STR_KEY_8 = 'files.system_folder.videos';
	public transient final String STR_KEY_9 = 'files.system_folder.files';
	public transient final String STR_KEY_10 = 'files.system_folder.albums';
	public transient final String STR_KEY_11 = 'files.system_folder.question_files';

	*/
    public VideoDataServer() {     
    }
    
    public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
    public override void handleRequest() {

        try {
            logger.logDebug('VideoDataServer----entered handleRequest----');
            String action = readParam(REQUEST_PARAM_ACTION);
        	String dataParam = readParam(REQUEST_PARAM_DATA);	

            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());

            } else {
                if (ACTION_VALUE_ADD_VIDEO.equalsIgnoreCase(action)) {
                    response = addVideoToCategory(dataParam);
                    
                } else if (ACTION_VALUE_GET_VIDEO_ACCESS_TOKEN.equalsIgnoreCase(action)) {
                    response = getAccessToken();

                } else if (ACTION_VALUE_REVOKE_VIDEO_ACCESS_TOKEN.equalsIgnoreCase(action)) {
                    response = revokeSession(readParam('session'));

                }else if (ACTION_VALUE_GET_THUMBNAIL.equalsIgnoreCase(action)) {
                    response = getThumbnail(readParam('entryId'));

                }else if (ACTION_VALUE_GET_VIDEO_REFERENCES.equalsIgnoreCase(action)) {
                    response = getVideoReferences(dataParam);

                }else if (ACTION_VALUE_GET_CAPTIONS_LANGUAGES.equalsIgnoreCase(action)) {
                    response = getCaptionsLanguages();

                }else if (ACTION_VALUE_ADD_TO_FOLDER.equalsIgnoreCase(action)) {
                    response = addToFolder(dataParam);

                }else if (ACTION_VALUE_UPDATE_VIDEO_STATUS.equalsIgnoreCase(action)) {
                    response = updateVideoStatus(dataParam);

                } else if (ACTION_VALUE_CREATE_VIDEO_FOLDERS.equalsIgnoreCase(action)) {
                    response = createVideoFolders();

                } else if (ACTION_VALUE_PROCESS_NATIVE_VIDEO_DISABLE.equalsIgnoreCase(action)) {
                    response = processNativeVideoDisable();

                } else if (ACTION_VALUE_GET.equalsIgnoreCase(action)) {
                    response = getVideoDetails(dataParam); 

                } else if (ACTION_VALUE_UPDATE_CAPTION_STATUS.equalsIgnoreCase(action)) {
                    response = updateVideoCaptionStatusInfo(dataParam);

                } else if (ACTION_VALUE_UPDATE_VIDEO_FILES.equalsIgnoreCase(action)) {
                    response = updateVideoFileRecords(dataParam);

                } else if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {
                    response = search(dataParam);

                } else if (ACTION_VALUE_GET_BY_IDS.equalsIgnoreCase(action)) {
                    response = getByIds(readParam('ids'));

                } else if (ACTION_VALUE_SYNC_PEOPLE_DATA.equalsIgnoreCase(action)) {
                    response = syncPeopleData();

                } else {
                	throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            	}

            }
            
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        }
        
    }

	@TestVisible
	private ResponseWrapper addVideoToCategory(String requestData){
        logger.logDebug('VideoDataServer.addVideo()--------');
        ResponseWrapper responseWrapperObj = null;

		try {
            NativeVideoWrapper.VideoCategoryWrapper wrapperObj = (NativeVideoWrapper.VideoCategoryWrapper)JSON.deserialize(requestData, NativeVideoWrapper.VideoCategoryWrapper.class);
            if( wrapperObj.mediaParams == null || String.isBlank(wrapperObj.mediaParams.id)){
                throw new SimpplrException('Required params missing.');
            }

            String entryId = wrapperObj.mediaParams.id;
            Boolean isCaptionLanguageIdRequired = true;
            VideoDao videoDaoObj = new VideoDao();
            videoDaoObj.addVideoToCategory(entryId, wrapperObj.siteId, isCaptionLanguageIdRequired);
            
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            	    
		} catch (Exception e) {
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());				
        }
		
		return responseWrapperObj;
    }

    @TestVisible
	private ResponseWrapper getAccessToken() {
        logger.logDebug('VideoDataServer.getAccessToken()--------');
        ResponseWrapper responseWrapperObj = null;
		try {
            if(SimpplrContext.isNativeVideo) {
                VideoDao videoDaoObj = new VideoDao();
                Map<String, Object> res = videoDaoObj.getAccessToken();
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, res);                   	    
            } else {
                logger.logDebug('Native video license not enabled');
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
            }

		} catch (Exception e) {
            logger.logError('VideoDataServer.getAccessToken()----Exception occured----', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());	

        }		
		return responseWrapperObj;
    }

    @TestVisible
	private ResponseWrapper revokeSession(String session) {
        logger.logDebug('VideoDataServer.revokeSession()--------');
        ResponseWrapper responseWrapperObj = null;
		try {
            VideoDao videoDaoObj = new VideoDao();
            Map<String, Object> res = videoDaoObj.revokeSession(session);

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, res);                   	    
		} catch (Exception e) {
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());	

        }		
		return responseWrapperObj;
    }
    @TestVisible
    private ResponseWrapper getVideoReferences(string requestData) {
        ResponseWrapper responseWrapperObj = null;
		try {
            Map<String, Object> requestDataMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
            String entryId = (String) requestDataMap.get('entryId');
            Integer recordLimit = requestDataMap.containsKey('size') ? Integer.valueOf(requestDataMap.get('size')) : SimpplrContext.simpplrDefaultPageSize;
        	Integer offset = requestDataMap.containsKey('nextPageToken') ? Integer.valueOf(requestDataMap.get('nextPageToken')) : 0;
            Integer size = recordLimit + 1;
            VideoDao videoDaoObj = new VideoDao();
            NativeVideoWrapper.VideoReferencesWrapper videoReferencesWrapper = videoDaoObj.getVideoReferences(entryId, size, offset);
			List<NativeVideoWrapper.ReferenceItemWrapper> referenceItemWrapperList = videoReferencesWrapper.results;
            PaginationWrapper paginationWrapperObj=new PaginationWrapper();
			if(ReferenceItemWrapperList != null){
				paginationWrapperObj.listOfItems.addAll(referenceItemWrapperList);
	   		}

			paginationWrapperObj.entryId = entryId;   
	        paginationWrapperObj.nextPageToken = videoReferencesWrapper.nextPageToken != null ? videoReferencesWrapper.nextPageToken : null;
    		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, paginationWrapperObj);      	    
		} catch (Exception e) {
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());	
        }		
		return responseWrapperObj;
    }

    @TestVisible
	private ResponseWrapper getThumbnail(string entryId) {
        ResponseWrapper responseWrapperObj = null;
		try {
            VideoDao videoDaoObj = new VideoDao();
            Map<String,String> resultMap = videoDaoObj.getThumbnail(entryId);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);                   	    
		} catch (Exception e) {
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());	

        }		
		return responseWrapperObj;
    }

    @TestVisible
	private ResponseWrapper addToFolder(String requestData) {
        logger.logDebug('VideoDataServer.addToFolder()--------');
        ResponseWrapper responseWrapperObj = null;

		try {
            NativeVideoWrapper.VideoCategoryWrapper wrapperObj = (NativeVideoWrapper.VideoCategoryWrapper)JSON.deserialize(requestData, NativeVideoWrapper.VideoCategoryWrapper.class);
            if( wrapperObj.mediaParams == null || String.isBlank(wrapperObj.mediaParams.id)){
                throw new SimpplrException('Required params missing.');
            }
            String directory = String.isNotBlank(wrapperObj.directory) ? wrapperObj.directory : new FolderDao().getSiteVideosSystemFolderId(wrapperObj.siteId);
            FileContentProvider provider  = new FileContentProvider();
            FileListingWrapper  fileWrapObj = provider.addToFolder(wrapperObj.siteId, directory, wrapperObj.mediaParams, wrapperObj.uploadVideoResponse); 
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileWrapObj);
            	    
		} catch (Exception e) {
            logger.logError('VideoDataServer.addToFolder()----Exception occured', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

    @TestVisible
	private ResponseWrapper updateVideoStatus(String requestData) {
        logger.logDebug('VideoDataServer.updateVideoStatus()--------');
        ResponseWrapper responseWrapperObj = null;

		try {
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestData);
            String entryId = (String) requestMap.get('entryId');
            Integer status = (Integer) requestMap.get('status');
            new VideoDao().updateVideoStatus(entryId, status);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
        } catch (Exception e) {
            logger.logError('VideoDataServer.updateVideoStatus()----Exception occured', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);				
        }
		
		return responseWrapperObj;
    }

    @TestVisible
	private ResponseWrapper createVideoFolders(){
        logger.logDebug('VideoDataServer.createVideoFolders()--------');
        ResponseWrapper responseWrapperObj = null;

		try {
            BatchManageVideo job = new BatchManageVideo('createVideoFolders');
            Database.executeBatch(job,100);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            	    
		} catch (Exception e) {
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());				
        }
		
		return responseWrapperObj;
    }

    @TestVisible
	private ResponseWrapper processNativeVideoDisable(){
        logger.logDebug('VideoDataServer.processNativeVideoDisable()--------');
        ResponseWrapper responseWrapperObj = null;

		try {
            BatchManageVideo job = new BatchManageVideo('markPeopleIntDeleted');
            Database.executeBatch(job, 100);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            	    
		} catch (Exception e) {
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());				
        }
		
		return responseWrapperObj;
    }
    public class PaginationWrapper{
		public String entryId;
		public String nextPageToken;
    	public List<Object> listOfItems = new List<Object>();
	}

    @TestVisible
	private ResponseWrapper getVideoDetails(String requestData){
        logger.logDebug('VideoDataServer.getVideoDetails()--------');
        ResponseWrapper responseWrapperObj = null;

		try {
            FileDetailWrapper fileDetailWrapObj = new FileDetailWrapper();
            VideoDataService videoDataServiceObj = new VideoDataService();
            fileDetailWrapObj = VideoDataServiceObj.getVideoDetails(requestData);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileDetailWrapObj);
            
		} catch (Exception e) {
            String message = e.getMessage() == ServiceConstants.ERROR_404 ? ServiceConstants.ERROR_404 : null;
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, message, null);	
            logger.logError('VideoDataServer.getVideoDetails()',e);			
        }

		return responseWrapperObj;
    }

    private ResponseWrapper getCaptionsLanguages() {
        ResponseWrapper responseWrapperObj = null;
		try {
            FilterService serviceObj = new FilterService();
            Map<String, Object> result = serviceObj.getCaptionsLanguages();
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
        } catch (Exception e) {
            logger.logError('VideoDataServer.getCaptionsLanguages()----Exception occured----', e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());
        }
        return responseWrapperObj;

    }

    private ResponseWrapper updateVideoCaptionStatusInfo(String requestData) {
		logger.logDebug('updateVideoCaptionStatusInfo()');
        ResponseWrapper responseWrapperObj = null;

        try{
            VideoDataService videoDataServiceObj = new VideoDataService();
            VideoDataServiceObj.updateVideoCaptionStatusInfo(requestData);

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            
        } catch (Exception ex) {
            logger.logError('VideoDataServer.updateIntegrationInfo()---Exception occured----', ex);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
    }

    private ResponseWrapper updateVideoFileRecords(String requestData) {
		logger.logDebug('updateVideoFileRecords()');
        ResponseWrapper responseWrapperObj = null;

        try{
            VideoDataService videoDataServiceObj = new VideoDataService();
            VideoDataServiceObj.updateVideoFileRecords(requestData);

            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            
        } catch (Exception ex) {
            logger.logError('VideoDataServer.updateVideoFileRecords()---Exception occured----', ex);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
    }

    /**
     * @description this method search for videos within Salesforce without API callout - NEWSLETTER
     * @return ResponseWrapper object
     * @param requestData string value
     */
    private ResponseWrapper search(String requestData) {
		logger.logDebug('VideodataServer.search()');
        ResponseWrapper responseWrapperObj = null;

        try{
            if (!SimpplrContext.Integrations.containsKey(ServiceConstants.VIDEO_PROVIDER_NATIVE)) {
                throw new SimpplrException(ServiceConstants.ERROR_404);
            }else {
                VideoDataService videoDataServiceObj = new VideoDataService();
                NativeVideoWrapper.VideoResultWrapper result = VideoDataServiceObj.search(requestData);

                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
            }
            
        } catch (Exception ex) {
            logger.logError('VideoDataServer.search()---Exception occured----', ex);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
    }

    /**
     * @description this method send videos from Salesforce without API callout - NEWSLETTER
     * @return ResponseWrapper object
     * @param ids string value
     */
    private ResponseWrapper getByIds(String ids) {
		logger.logDebug('VideodataServer.getByIds()');
        ResponseWrapper responseWrapperObj = null;

        try{
            if (!SimpplrContext.Integrations.containsKey(ServiceConstants.VIDEO_PROVIDER_NATIVE)) {
                throw new SimpplrException(ServiceConstants.ERROR_404);
            }else {
                VideoDataService videoDataServiceObj = new VideoDataService();
                NativeVideoWrapper.VideoResultWrapper result = VideoDataServiceObj.getByIds(ids);
    
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
            }
            
        } catch (Exception ex) {
            logger.logError('VideoDataServer.getByIds()---Exception occured----', ex);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
    }

    @TestVisible
    private ResponseWrapper syncPeopleData(){
        logger.logDebug('VideoDataServer.syncPeopleData()-----------');
        ResponseWrapper responseWrapperObj = null;

        try {
            if (!SimpplrContext.Integrations.containsKey(ServiceConstants.VIDEO_PROVIDER_NATIVE)) {
                throw new SimpplrException(ServiceConstants.ERROR_404);
            } else {
                VideoDao videoDaoObj = new VideoDao();
                videoDaoObj.syncPeopleData(); 
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
            }  
        } catch (Exception e) {
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, e.getMessage(), e.getMessage());				
        }

        return responseWrapperObj;
    }
}