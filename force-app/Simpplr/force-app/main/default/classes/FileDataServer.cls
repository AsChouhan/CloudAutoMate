/**
* Class [Class Name] 
* Purpose:  [A description of why this class exists.  For what reason was it written?  Which jobs does it perform?]
*
*/
public with sharing class FileDataServer extends DataServer{
	@TestVisible private final String ACTION_VALUE_SEARCH = 'search';
	@TestVisible private final String ACTION_VALUE_GET_MEDIA = 'getMedia';
	@TestVisible private final String ACTION_VALUE_GET = 'get';
	@TestVisible private final String ACTION_VALUE_LINK_SHAREPOINT_FOLDER = 'linkSharepointFolder';
	@TestVisible private final String ACTION_VALUE_UNLINK_SHAREPOINT_FOLDER = 'unlinkSharepointFolder';
	@TestVisible private final String ACTION_VALUE_LINK_ONEDRIVE_FOLDER = 'linkOnedriveFolder';
	@TestVisible private final String ACTION_VALUE_UNLINK_ONEDRIVE_FOLDER = 'unlinkOnedriveFolder';
	@TestVisible private final String ACTION_VALUE_GET_SHAREPOINT_SITE_ITEM_LIST = 'getSharePointLinkableItems';
	@TestVisible private final String ACTION_VALUE_GET_ONEDRIVE_SITE_ITEM_LIST = 'getOnedriveLinkableItems';
	@TestVisible private final String ACTION_VALUE_CREATE_CHATTER_FOLDER = 'createFolder';
	@TestVisible private final String ACTION_VALUE_CREATE_BOX_FOLDER = 'createBoxFolder';
    @TestVisible private final String ACTION_VALUE_CREATE_EFS_FOLDER = 'createEFSFolder';
    @TestVisible private final String ACTION_VALUE_CREATE_GOOGLE_FOLDER = 'createGoogleFolder';
	@TestVisible private final String ACTION_VALUE_LINK_BOX_FOLDER = 'linkFolder';
	@TestVisible private final String ACTION_VALUE_UNLINK_BOX_FOLDER = 'unlinkFolder';
	@TestVisible private final String ACTION_VALUE_LINK_GOOGLE_DRIVE_FOLDER = 'linkGoogleDriveFolder';
	@TestVisible private final String ACTION_VALUE_UNLINK_GOOGLE_DRIVE_FOLDER = 'unlinkGoogleDriveFolder';
	@TestVisible private final String ACTION_VALUE_GET_SITE_GOOGLE_SHARED_DRIVE = 'getSiteSharedDriveDetails';
	@TestVisible private final String ACTION_VALUE_GET_BOX_LINKABLE_FOLDERS = 'getBoxLinkableFolders';
    @TestVisible private final String ACTION_VALUE_GET_EFS_FOLDERS = 'getEFSLinkFolders';
    @TestVisible private final String ACTION_VALUE_GET_GOOGLE_DRIVE_FOLDERS = 'getGoogleDriveLinkFolders';
	@TestVisible private final String ACTION_VALUE_GET_VERSION_HISTORY = 'getVersionHistory';
	@TestVisible private final String ACTION_VALUE_GET_BOX_DOWNLOAD_URL = 'getDownloadUrl';
	@TestVisible private final String ACTION_VALUE_GET_SHAREPOINT_VERSION_DOWNLOAD_URL = 'getSharePointVersionDownloadUrl';
	@TestVisible private final String ACTION_VALUE_GET_BOX_ACCESS_TOKEN = 'getAccessToken';
    @TestVisible private final String ACTION_VALUE_GET_EFS_ACCESS_TOKEN = 'getEFSAccessToken';
    @TestVisible private final String ACTION_VALUE_GET_GOOGLE_DRIVE_ACCESS_TOKEN = 'getGoogleDriveAccessToken';
	@TestVisible private final String ACTION_VALUE_GET_DROPBOX_ACCESS_TOKEN = 'getDropboxAccessToken';
	@TestVisible private final String ACTION_VALUE_GET_PUBLIC_URL = 'getPublicUrl';
	@TestVisible private final String ACTION_VALUE_GET_AUDIENCE_CSV_DOWNLOAD_URL = 'getAudienceCSVDownloadURL';
	@TestVisible private final String ACTION_VALUE_SET_DESCRIPTION = 'setDescription';
	@TestVisible private final String ACTION_VALUE_SET_FOLDER_NAME = 'setFolderName';
	@TestVisible private final String ACTION_VALUE_SET_FOLDER_PERMISSIONS = 'setFolderPermissions';
	@TestVisible private final String ACTION_VALUE_RESET_BOX_ACCESS_TOKEN = 'resetCurrentUserBoxAccessToken';
    @TestVisible private final String ACTION_VALUE_RESET_EFS_ACCESS_TOKEN = 'resetEFSAccessToken';
    @TestVisible private final String ACTION_VALUE_RESET_GOOGLE_DRIVE_ACCESS_TOKEN = 'resetGoogleDriveAccessToken';
	@TestVisible private final String ACTION_VALUE_DELETE_FILE = 'deleteFile';
	@TestVisible private final String ACTION_VALUE_REMOVE_FILE = 'removeFile';
	@TestVisible private final String ACTION_VALUE_DELETE_FOLDER = 'deleteFolder';
	@TestVisible private final String ACTION_VALUE_MOVE_FILES = 'moveFiles';
	@TestVisible private final String ACTION_VALUE_UPLOAD_IMAGE_TO_AWS = 'uploadImageToAWS';
	@TestVisible private final String REQUEST_PARAM_DATA = 'data';
	@TestVisible private final String PROVIDER_BOX = 'Box';
	@TestVisible private final String PROVIDER_NATIVE_VIDEO = 'native_video';
	@TestVisible private final String PROVIDER_INTRANET = 'Intranet';
	@TestVisible private final String PROVIDER_CRM = 'CRM';
	
	@TestVisible private final String ACTION_VALUE_GET_CRM_FOLDER = 'getCrmFolders';
	@TestVisible private final String ACTION_VALUE_LINK_CRM_FOLDER = 'linkCrmFolder';
	@TestVisible private final String ACTION_VALUE_UNLINK_CRM_FOLDER = 'unlinkCrmFolder';    

	@TestVisible private final String FILTER_PHOTO = 'photo';
	@TestVisible private final String FILTER_VIDEO = 'video';
	@TestVisible private final String FILTER_ALL = 'all';
	@TestVisible private final String FILTER_BOOKMARKED = 'bookmarked';
	@TestVisible private final String FILTER_FAVORITES = 'favorites';
	@TestVisible private final String ERROR_BOX_NOT_CONNECTED = 'Your Box account is not connected. Please login via desktop to connect account';
	@TestVisible private final String ERROR_GDRIVE_NOT_CONNECTED = 'Your Google Drive account is not connected. Please login via desktop to connect account';
	@TestVisible private final String ERROR_DROPBOX_NOT_CONNECTED = 'Your Dropbox account is not connected. Please login via desktop to connect account';
	public transient final String STR_KEY_ERROR_BOX_NOT_CONNECTED  { get { return labelMap.get('file.view.box_connect_error_flash');}}
	public transient final String STR_KEY_ERROR_GDRIVE_NOT_CONNECTED  { get { return labelMap.get( 'file.view.gdrive_connect_error_flash');}}
	public transient final String STR_KEY_ERROR_DROPBOX_NOT_CONNECTED { get { return labelMap.get('file.view.dropbox_connect_error_flash');}}
	public transient final String STR_KEY_ERROR_SHAREPOINT_NOT_CONNECTED { get { return labelMap.get('file.view.sharepoint_connect_error_flash');}}
	public transient final String STR_KEY_ERROR_ONEDRIVE_NOT_CONNECTED { get { return labelMap.get('file.view.onedrive_connect_error_flash');}}
	public transient final String STR_KEY_NATIVE_VIDEO_NOT_CONNECTED  { get { return labelMap.get( 'file.view.native_video_connect_error_flash');}}
    @TestVisible private final String ACTION_VALUE_GET_FILE_TYPES = 'getFileTypes';
    @TestVisible private final String ACTION_VALUE_SYNC_ALL_COMPANY_GOOGLE_DRIVE_GROUP = 'syncAllCompanyGoogleDriveGroup';
    @TestVisible private final String ACTION_VALUE_FILE_FOLDER_PERMISSION = 'getFileFolderPermission';
	
	/*
	private final String STR_KEY_SYS_FOLDER_CONTENT_FILES = 'files.system_folder.content_files';
	private final String STR_KEY_SYS_FOLDER_QUESTION_FILES = 'files.system_folder.question_files';
	private final String STR_KEY_SYS_FOLDER_SITE_VIDEOS = 'files.system_folder.site_videos';
	private final String STR_KEY_SYS_FOLDER_IMAGES = 'files.system_folder.images';
	private final String STR_KEY_SYS_FOLDER_VIDEOS = 'files.system_folder.videos';
	private final String STR_KEY_SYS_FOLDER_FILES = 'files.system_folder.files';
	private final String STR_KEY_SYS_FOLDER_ALBUMS = 'files.system_folder.albums';
	private final String STR_KEY_SYS_FOLDER_CRM_FILES = 'files.system_folder.crm_files';
	
	private final String STR_KEY_SYS_FOLDER_FEED_FILES = 'files.system_folder.feed_files';
	private final String STR_KEY_SYS_FOLDER_SITE_FILES = 'files.system_folder.site_files';
	private final String STR_KEY_SYS_FOLDER_BOX_FILES = 'files.system_folder.box_files';
	private final String STR_KEY_SYS_FOLDER_GOOGLE_DRIVE_FILES = 'files.system_folder.googledrive_files';
	private final String STR_KEY_SYS_FOLDER_DROPBOX_FILES = 'files.system_folder.dropbox_files';
	private final String STR_KEY_SYS_FOLDER_SHAREPOINT_FILES = 'files.system_folder.sharepoint_files';
	private final String STR_KEY_SYS_FOLDER_ONEDRIVE_FILES = 'files.system_folder.onedrive_files';
	private final String STR_KEY_LOC_NOT_AVAILABLE = 'file.location.not_available';
	private final String STR_KEY_SHAREPOINT_LIMIT = 'file.link_folder.sharepoint.limit_reach_error_flash';
	private final String STR_KEY_ONEDRIVE_LIMIT = 'file.link_folder.onedrive.limit_reach_error_flash';
	private final String STR_KEY_GOOGLEDRIVE_LIMIT = 'file.link_folder.googledrive.limit_reach_error_flash';

	public transient final String STR_KEY_1 = 'date.month.short.01';
	public transient final String STR_KEY_2 = 'date.month.short.02';
	public transient final String STR_KEY_3 = 'date.month.short.03';
	public transient final String STR_KEY_4 = 'date.month.short.04';
	public transient final String STR_KEY_5 = 'date.month.short.05';
	public transient final String STR_KEY_6 = 'date.month.short.06';
	public transient final String STR_KEY_7 = 'date.month.short.07';
	public transient final String STR_KEY_8 = 'date.month.short.08';
	public transient final String STR_KEY_9 = 'date.month.short.09';
	public transient final String STR_KEY_10 = 'date.month.short.10';
	public transient final String STR_KEY_11 = 'date.month.short.11';
	public transient final String STR_KEY_12 = 'date.month.short.12';
	public transient final String STR_KEY_DATE_PM = 'common.date_pm';
	public transient final String STR_KEY_DATE_AM = 'common.date_am';

	*/
    public transient final String STR_KEY_FILE_TYPE_PDF = 'file.type.pdf';
    public transient final String STR_KEY_FILE_TYPE_MICROSOFT_OFFICE_EXCEL = 'file.type.microsoft_office_excel';
    public transient final String STR_KEY_FILE_TYPE_MICROSOFT_OFFICE_DOCUMENT = 'file.type.microsoft_office_document';
	public transient final String STR_KEY_FILE_TYPE_MICROSOFT_POWERPOINT = 'file.type.microsoft_powerpoint';
	public transient final String STR_KEY_FILE_TYPE_CSV = 'file.type.csv';
    public transient final String STR_KEY_FILE_TYPE_TXT = 'file.type.txt';
    public transient final String STR_KEY_FILE_TYPE_PNG = 'file.type.png';
	public transient final String STR_KEY_FILE_TYPE_JPG = 'file.type.jpg';
    public transient final String STR_KEY_FILE_TYPE_JPEG = 'file.type.jpeg';
	public transient final String STR_KEY_FILE_TYPE_GIF = 'file.type.gif';
    public transient final String STR_KEY_FILE_TYPE_RTF = 'file.type.rtf';
    public transient final String STR_KEY_FILE_TYPE_ZIP = 'file.type.zip';
    
	public String getPageFeature() {
    	return AccessManager.FEATURE_SIMPPLR;
    }
    
	 /**
     * 
     * Purpose:  [Explain what this method does to support the correct operation of its class, and how it does it.]
     * Parameters:
     * parameter_name -- [Explanation of the purpose of this parameter to the method.
     *      
     * Returns:  [If this method sends back a value via the return mechanism, describe the purpose of that value here, otherwise state 'None.']
    */
    public override void handleRequest () {
        String redirectUrl = '';
        try {
        	logger.logDebug('FileDataServer.handleRequest()----entered handleRequest----');
            
        	String action = readParam(REQUEST_PARAM_ACTION);
           	String  requestData = readParam(REQUEST_PARAM_DATA);

            if (String.isBlank(action)) {
                throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
            }
            
            if (SiteContext.chatterGroupId != null && !SiteContext.showInSimpplr) {
				redirectUrl = SimpplrContext.salesforceBaseUrl + '/'+SiteContext.chatterGroupId;
			    throw new SimpplrException(ServiceConstants.ERROR_404);
			}
			
/**
 * @api {get} /apex/DataServerRW?target=FileDataServer&action=search search
 * @apiVersion 1.0.0
 * @apiGroup FileDataServer
 * @apiName Files
 *
 * @apiParam {String} action=search search is the default action for the file data server class
 * @apiDescription 
 * 1. Called from Simpplr.Salesforce.File.search
 * 2. Used in SiteFileList, MyFileList and MediaManager
 * 3. This is used for search and for file listing with various filter conditions
 * 
 * @apiSuccess {List[FileListingWrapper]} Response.listOfItems Some Description
 * @apiUse FileListingWrapper
 *
 * @apiError SimpplrException Simpplr Exception
 * @apiError (Error 404) SimpplrException File not found
 */         
 			// action = ACTION_VALUE_GET Used by Native Mobile App only
             if(ACTION_VALUE_GET.equalsIgnoreCase(action)) {
            	Criteria.File fileCriteriaObj = (Criteria.File)JSON.deserialize(requestData, Criteria.File.class);
            	response = getFileDetail(fileCriteriaObj);
            	
            } else if (ACTION_VALUE_SEARCH.equalsIgnoreCase(action)) {      	
				Criteria.File fileCriteriaObj = (Criteria.File)JSON.deserialize(requestData, Criteria.File.class);
				logger.logDebug('FileDataServer.handleRequest()----fileCriteriaObj----' + fileCriteriaObj);
				
				if(FILTER_FAVORITES.equalsIgnoreCase(fileCriteriaObj.filter)) {
			        if('mobile'.equalsIgnoreCase(readParam('origin'))){
                        response = getFavoriteFiles(fileCriteriaObj);
                        
			        } else {
                        
                        if (PROVIDER_CRM.containsIgnoreCase(fileCriteriaObj.provider)) {
				            response = getFavoriteCRMFiles(fileCriteriaObj);
                        
                        } else if (PROVIDER_BOX.containsIgnoreCase(fileCriteriaObj.provider)) {
				            response = getFavoriteBoxFiles(fileCriteriaObj);
                        
                        } else if(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.containsIgnoreCase(fileCriteriaObj.provider)) {
			        		response = getFavoriteGoogleDriveFiles(fileCriteriaObj);
                        
				        } else if(PROVIDER_NATIVE_VIDEO.containsIgnoreCase(fileCriteriaObj.provider)) {
			        		response = getNativeVideoFiles(requestData);
				        } else {
			        		response = getFavoriteSFDCFiles(requestData);	
				        }
			        }
				} else if (String.isNotBlanK(fileCriteriaObj.siteId)) {
					
					if(PROVIDER_INTRANET.equalsIgnoreCase(fileCriteriaObj.provider)) {
						if(String.isNotBlank(fileCriteriaObj.directory) && fileCriteriaObj.directory.startsWith('058')) {
							response = getSiteCRMFiles(fileCriteriaObj);
							
						} else {
							response = getSiteChatterFoldersAndFiles(fileCriteriaObj);
							
						}
				
					} else if(PROVIDER_CRM.equalsIgnoreCase(fileCriteriaObj.provider)) {
						response = getSiteCRMFiles(fileCriteriaObj);
							
					} else if(PROVIDER_BOX.equalsIgnoreCase(fileCriteriaObj.provider)) {
						response = getSiteBoxFiles(fileCriteriaObj);
						
					} else if(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
						if(String.isNotBlank(fileCriteriaObj.term)) {
							response = searchGoogleDriveFiles(fileCriteriaObj);

						} else if('virtual'.equalsIgnoreCase(fileCriteriaObj.directory) || 
								String.isBlank(fileCriteriaObj.directory)) {
							response = getLinkedGoogleDriveFolders(fileCriteriaObj);
						} else { 
							response = getGoogleDriveFolderContents(fileCriteriaObj);
						}

                    } else if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
						response = getSiteDropboxFiles(fileCriteriaObj);
					} else if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileCriteriaObj.provider) ||
							  ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
						response = getSiteMSDriveFiles(fileCriteriaObj);

					} else if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(fileCriteriaObj.provider)) {
						response = getSiteVideoFolderAndFiles(fileCriteriaObj);

					} else {
	    				response = getSiteChatterFoldersAndFiles(fileCriteriaObj);
					}
				} else if(PROVIDER_INTRANET.equalsIgnoreCase(fileCriteriaObj.provider)) {
					logger.logDebug('FileDataServer.handleRequest()----213 INTRANET ----' + fileCriteriaObj);
			           response = getMyFilesIntranetFiles(fileCriteriaObj);
		        } else if (PROVIDER_BOX.equalsIgnoreCase(fileCriteriaObj.provider)) {
		            response = getMyBoxFiles(fileCriteriaObj);
		        } else if (PROVIDER_CRM.equalsIgnoreCase(fileCriteriaObj.provider)) {
					response = getMyFilesCRMLibFiles(fileCriteriaObj);
                
                } else if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {	
					if(String.isNotBlank(fileCriteriaObj.term)){
						response = searchGoogleDriveFiles(fileCriteriaObj);

					} else {
						response = getSitesWithGoogleDriveFileStortage(fileCriteriaObj);

					}
                    
    			} else if (ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
					response = getMyDropboxFiles(fileCriteriaObj);
				
				} else if (String.isNotBlank(fileCriteriaObj.term) &&
							ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileCriteriaObj.provider) &&
						EFSConstants.SHAREPOINT_FULL_SEARCH_CLIENT_ID.equalsIgnoreCase(SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).Client_Id__c)) {
						response = searchAllFilesSharePoint(fileCriteriaObj);
						
    			} else if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileCriteriaObj.provider) || 
    					   ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
					response = getSiteMSDriveFiles(fileCriteriaObj);
    			} else {
	            	response = autoComplete(fileCriteriaObj);
    			}
            } else if (ACTION_VALUE_CREATE_EFS_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
                response = createEFSFolder(folderCriteriaObj);
                
            } else if (ACTION_VALUE_CREATE_GOOGLE_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = createGoogleFolder(folderCriteriaObj);
                
            } else if(ACTION_VALUE_GET_MEDIA.equalsIgnoreCase(action)) {
				Criteria.File fileCriteriaObj = (Criteria.File)JSON.deserialize(requestData, Criteria.File.class);
	        	response = getMedia(fileCriteriaObj);
	        	
            } else if(ACTION_VALUE_CREATE_CHATTER_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = createChatterFolder(folderCriteriaObj);
            	
            } else if(ACTION_VALUE_CREATE_BOX_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
				response = createBoxFolder(folderCriteriaObj);
				
            } else if(ACTION_VALUE_GET_BOX_LINKABLE_FOLDERS.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = getBoxLinkableFolders(folderCriteriaObj);

            } else if(ACTION_VALUE_LINK_BOX_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = linkFolder(folderCriteriaObj);
            
            } else if(ACTION_VALUE_LINK_SHAREPOINT_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = linkSharepointFolder(folderCriteriaObj);
            
            } else if(ACTION_VALUE_LINK_ONEDRIVE_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = linkOnedriveFolder(folderCriteriaObj);
            
            } else if(ACTION_VALUE_UNLINK_BOX_FOLDER.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = unlinkFolder(requestMap);
            			
            } else if(ACTION_VALUE_UNLINK_SHAREPOINT_FOLDER.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = unlinkSharepointFolder(requestMap);

            } else if(ACTION_VALUE_FILE_FOLDER_PERMISSION.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = getFileFolderPermission(requestMap);
				
            } else if(ACTION_VALUE_UNLINK_ONEDRIVE_FOLDER.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = unlinkOnedriveFolder(requestMap);
            			
            } else if(ACTION_VALUE_GET_EFS_FOLDERS.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = getEFSLinkFolders(folderCriteriaObj);

            } else if (ACTION_VALUE_LINK_GOOGLE_DRIVE_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
                response = linkGoogleDriveFolder(folderCriteriaObj);
                
            } else if (ACTION_VALUE_UNLINK_GOOGLE_DRIVE_FOLDER.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
                response = unlinkGoogleDriveFolder(requestMap);
                
            } else if(ACTION_VALUE_SET_DESCRIPTION.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = setFileDescription(requestMap);
            
            } else if(ACTION_VALUE_SET_FOLDER_NAME.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = setFolderName(requestMap);
            	
            } else if(ACTION_VALUE_SET_FOLDER_PERMISSIONS.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = setFolderPermissions(requestMap);
            		
        	} else if(ACTION_VALUE_DELETE_FILE.equalsIgnoreCase(action)) {
				Criteria.FileDeleteParams deleteFileCriteriaObj = (Criteria.FileDeleteParams)JSON.deserialize(requestData,Criteria.FileDeleteParams.class);
				List<File__c> fileObj ;
				Map<String, Object> soqlParamMap = new Map<String, Object>();
				soqlParamMap.put('soqlParam1', deleteFileCriteriaObj.fileId[0]);
				if(SimpplrContext.isNativeVideo && deleteFileCriteriaObj.provider.equalsIgnoreCase(ServiceConstants.VIDEO_PROVIDER_NATIVE)){	
							
					String filesQuery = 'Select Id, External_Id__c,Simpplr_Content__r.Site__c,Simpplr_Content__r.Type__c From File__c where External_Id__c =: soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					fileObj = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
					VideoDao daoObj = new VideoDao();
					FileDao fileDaoObj = new FileDao();
					Boolean result ;
					File__c fileRecordObj ;
					
					result= daoObj.deleteVideo(new Set<String>{fileObj[0].External_Id__c});	
					fileRecordObj = FileDao.getFileRecordDetails(fileObj[0].External_Id__c);	
						  
					fileDaoObj.unbookmarkFileForAllUsers(fileObj[0].External_Id__c, deleteFileCriteriaObj.provider);
					FileDao.SoftDeleteVideoFileRecord(fileRecordObj);

					response = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);

				} else {
					response = deleteFile(deleteFileCriteriaObj);	
				}
            } else if(ACTION_VALUE_REMOVE_FILE.equalsIgnoreCase(action)) {
				List<File__c> fileList;
				
				Criteria.FileDeleteParams removeFileCriteriaObj = (Criteria.FileDeleteParams)JSON.deserialize(requestData,Criteria.FileDeleteParams.class);
				if(SimpplrContext.isNativeVideo && removeFileCriteriaObj.provider.equalsIgnoreCase(ServiceConstants.VIDEO_PROVIDER_NATIVE)){				
					
					Map<String, Object> soqlParamMap = new Map<String, Object>();
					soqlParamMap.put('soqlParam1', removeFileCriteriaObj.fileId);

					String filesQuery = 'SELECT Id, External_Id__c, Site__c, Simpplr_Content__r.Site__c, Is_Deleted__c FROM File__c WHERE Is_Deleted__c = false AND Id =:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					List<File__c> fileToDeleteList = (List<File__c>) SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);

					Set<String> externalIdSet = new Set<String>();
					for(File__c fileObj : fileToDeleteList){
						externalIdSet.add(fileObj.External_Id__c);

						fileObj.Is_Deleted__c = true;
					}	

					Map<String, Object> fileByExtIdSoqlParamMap = new Map<String, Object>();
					fileByExtIdSoqlParamMap.put('soqlParam1', externalIdSet);

					filesQuery = 'SELECT Id, External_Id__c, Site__c, Simpplr_Content__r.Site__c, Is_Deleted__c FROM File__c WHERE Is_Deleted__c = false AND External_Id__c =:soqlParam1';
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					fileList = (List<File__c>) SIMPESAPI.accessController().queryAsUser(filesQuery, fileByExtIdSoqlParamMap);

					Map<String, Set<String>> externalIdVsFileIdSetMap = new Map<String, Set<String>>();
					Map<String, Integer> externalIdVsCurrentSiteRefMap = new Map<String, Integer>();
					for(File__c fileObj : fileList){
						if(externalIdVsFileIdSetMap.containsKey(fileObj.External_Id__c)){

							externalIdVsFileIdSetMap.get(fileObj.External_Id__c).add(fileObj.Id);
						} else {

							Set<String> fileIdSet = new Set<String>{fileObj.Id};
							externalIdVsFileIdSetMap.put(fileObj.External_Id__c, fileIdSet);
						}

						if(String.isNotBlank(fileObj.Site__c) &&
							removeFileCriteriaObj.fileSiteId.equalsIgnoreCase(fileObj.Site__c)){
							
							if(externalIdVsCurrentSiteRefMap.containsKey(fileObj.External_Id__c)){

								Integer numberOfRef = externalIdVsCurrentSiteRefMap.get(fileObj.External_Id__c) + 1;
								externalIdVsCurrentSiteRefMap.put(fileObj.External_Id__c, numberOfRef);
							} else {
	
								externalIdVsCurrentSiteRefMap.put(fileObj.External_Id__c, 1);
							}
						}
					}

					Set<String> entryIdToDeleteSet = new Set<String>();
					Set<String> entryIdToRemoveFromCategorySet = new Set<String>();
					for(String externalId : externalIdVsFileIdSetMap.keySet()){
						Set<String> fileIdSet = externalIdVsFileIdSetMap.get(externalId);
						if(fileIdSet.size() == 1){

							entryIdToDeleteSet.add(externalId);
						} else {

							if(externalIdVsCurrentSiteRefMap.get(externalId) == 1){
								entryIdToRemoveFromCategorySet.add(externalId);
							}
						}					
					}
					VideoDao daoObj = new VideoDao();
					if(!entryIdToDeleteSet.isEmpty()){
						
						
						daoObj.deleteVideo(entryIdToDeleteSet);
					}
					if(!entryIdToRemoveFromCategorySet.isEmpty()){
						// remove these external ids from current site
						daoObj.removeVideoFromCategory(entryIdToRemoveFromCategorySet, removeFileCriteriaObj.fileSiteId);
					}
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id, File__c>(fileToDeleteList), new List<Schema.SObjectField>{
																File__c.is_Deleted__c
															});
				
				} else {

					response = removeFile(removeFileCriteriaObj);
				}
            } else if(ACTION_VALUE_DELETE_FOLDER.equalsIgnoreCase(action)) {
            	Criteria.FolderDeleteParams requestMap = (Criteria.FolderDeleteParams)JSON.deserialize(requestData, Criteria.FolderDeleteParams.class);
            	response = deleteFolder(requestMap);
            	
            } else if(ACTION_VALUE_GET_VERSION_HISTORY.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = getVersionHistory(requestMap);
            
            } else if(ACTION_VALUE_GET_BOX_DOWNLOAD_URL.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = getDownloadUrl(requestMap);
			
			} else if(ACTION_VALUE_GET_SHAREPOINT_VERSION_DOWNLOAD_URL.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
				response = getSharePointVersionDownloadUrl(requestMap);
				
            } else if (ACTION_VALUE_GET_BOX_ACCESS_TOKEN.equalsIgnoreCase(action)) {
            	response = getAccessToken();
            
            } else if (ACTION_VALUE_RESET_BOX_ACCESS_TOKEN.equalsIgnoreCase(action)) {
            	response = resetCurrentUserBoxAccessToken();            	
            	
            } else if (ACTION_VALUE_GET_EFS_ACCESS_TOKEN.equalsIgnoreCase(action)) {

            	if (ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(readparam('provider'))){
            		response = getEFSAccessToken(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
                
                } else if (ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(readparam('provider'))){
            		response = getEFSAccessToken(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);
                }
                
            } else if (ACTION_VALUE_GET_GOOGLE_DRIVE_ACCESS_TOKEN.equalsIgnoreCase(action)){
                response = getGoogleDriveAccessToken();

            } else if (ACTION_VALUE_GET_DROPBOX_ACCESS_TOKEN.equalsIgnoreCase(action)) {
                response = getDropboxAccessToken();
                
            } else if (ACTION_VALUE_RESET_EFS_ACCESS_TOKEN.equalsIgnoreCase(action)) {

            	if (ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(readparam('provider'))){
            		response = resetEFSAccessToken(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
                
                } else if (ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(readparam('provider'))){
            		response = resetEFSAccessToken(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);
                }
                
            } else if (ACTION_VALUE_RESET_GOOGLE_DRIVE_ACCESS_TOKEN.equalsIgnoreCase(action)) {
                response = resetGoogleDriveAccessToken();

            } else if(ACTION_VALUE_GET_PUBLIC_URL.equalsIgnoreCase(action)) {
            	Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
        		response = getPublicUrl(requestMap);
        		
        	} else if(ACTION_VALUE_GET_AUDIENCE_CSV_DOWNLOAD_URL.equalsIgnoreCase(action)) {
        		Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
        		response = getAudienceCSVDownloadURL(requestMap);
        		
        	} else if(ACTION_VALUE_MOVE_FILES.equalsIgnoreCase(action)) {
        		Criteria.FileMove fileMoveCriteriaObj = (Criteria.FileMove)JSON.deserialize(requestData, Criteria.FileMove.class);
				response = moveFiles(fileMoveCriteriaObj);

			} else if(ACTION_VALUE_UPLOAD_IMAGE_TO_AWS.equalsIgnoreCase(action)) {
				response = uploadImageToAWS(readParam('contentVersionId'));

            } else if(ACTION_VALUE_LINK_CRM_FOLDER.equalsIgnoreCase(action)) {
        		Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = linkCrmFolder(folderCriteriaObj);
            } else if(ACTION_VALUE_UNLINK_CRM_FOLDER.equalsIgnoreCase(action)) {
        		Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
            	response = unlinkCRMFolder(requestMap);
            } else if(ACTION_VALUE_GET_CRM_FOLDER.equalsIgnoreCase(action)) {
        		Map<String, String> requestMap = new Map<String, String>();
        		String siteId = readParam('siteId');
            	response = getCrmFolders(requestMap, siteId);
            } else if(ACTION_VALUE_GET_SHAREPOINT_SITE_ITEM_LIST.equalsIgnoreCase(action)) {
				Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
	        	response = getSharePointLinkableItems(requestMap);
	        	
            } else if (ACTION_VALUE_GET_ONEDRIVE_SITE_ITEM_LIST.equalsIgnoreCase(action)) {
				Map<String, String> requestMap = (Map<String, String>)JSON.deserialize(requestData, Map<String, String>.class);
	        	response = getOnedriveLinkableItems(requestMap);
            
            } else if (ACTION_VALUE_GET_FILE_TYPES.equalsIgnoreCase(action)) {
                response = getFileTypes();
 
            } else if (ACTION_VALUE_GET_GOOGLE_DRIVE_FOLDERS.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
                response = getGoogleDriveLinkFolders(folderCriteriaObj);
            
            } else if (ACTION_VALUE_SYNC_ALL_COMPANY_GOOGLE_DRIVE_GROUP.equalsIgnoreCase(action)) {
                response = syncAllCompanyGoogleDriveGroup();

            } else if (ACTION_VALUE_GET_SITE_GOOGLE_SHARED_DRIVE.equalsIgnoreCase(action)) {
            	Criteria.Folder folderCriteriaObj = (Criteria.Folder)JSON.deserialize(requestData, Criteria.Folder.class);
            	response = getSiteSharedDriveDetails(folderCriteriaObj);
            } else {
            	 throw new SimpplrException(ExceptionCode.UNKNOWN_ACTION_PARAM.name());
            }
             
        } catch (Exception ex) {
        	logger.logError('Either no page access or action parameter returning wrong data',ex);
            response = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(ex), null);
        	
        	if (String.isNotBlank(redirectUrl)) {
        		response.redirectUrl = redirectUrl;
        	}
        }
        
    }
    
    @testVisible
    private ResponseWrapper getFileDetail(Criteria.File fileCriteriaObj){
    	logger.logDebug('FileDataServer.getFileDetail()----fileCriteriaObj----'+fileCriteriaObj);
	    ResponseWrapper responseToReturn = null;
		try{
			String provider = fileCriteriaObj.provider;
			String rootDirectory = fileCriteriaObj.rootDirectory;
   			String directory = fileCriteriaObj.directory;
   			String fileId = fileCriteriaObj.fileId;
			if (String.isblank(fileId)) {
				throw new SimpplrException(ExceptionCode.MISSING_REQUIRED_PARAM.name());
			}
			if('intranet'.equalsIgnoreCase(provider)) {
			}else if('native_video'.equalsIgnoreCase(provider)) {
				if(!SimpplrContext.isNativeVideo) {
					throw new SimpplrException(STR_KEY_NATIVE_VIDEO_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
				}

			} else if (!AccessManager.hasPageAccess(AccessManager.FEATURE_FILE) || (SimpplrContext.Integrations.get(provider) != null && (SimpplrContext.Integrations.get(provider).Connected__c==false || SimpplrContext.Integrations.get(provider).Integration_Enabled__c==false))) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			FileDetailWrapper fileDetails = new FileDetailWrapper();
		    FileDao fileDaoObj = new FileDao();
	    	
	    	if((ServiceConstants.STORAGE_TYPE_BOX_STRING).equalsIgnoreCase(provider)) {
				provider = provider.toLowerCase();
	    		if(UserContext.isBoxConnected == false){
	    			throw new SimpplrException(STR_KEY_ERROR_BOX_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
	    		}
	    	
	    		fileDetails = BoxContentProvider.getBoxFileDetails(fileId, rootDirectory);
	   			directory = String.isBlank(directory) ? '0' :  directory;
	   			fileDetails.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileId,'rootDirectory' =>rootDirectory, 'directory'=> directory});
	   			fileDetails.url = fileDetails.publicUrl;
	   			fileDetails.isBookmarked = fileDaoObj.isFileBookmarked(fileId, provider);
				fileDetails.canDelete = UserContext.peopleId.equalsIgnoreCase(fileDetails.Owner.id);
				fileDetails.viewInExternalSystem = 'https://app.box.com/files/0/f/' + directory + '/1/f_' + fileId ;
				
	    	} else if ((ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).equalsIgnoreCase(provider)) {
				provider = provider.toLowerCase();
				if((UserContext.Integrations.get(provider) == null) || (UserContext.Integrations.get(provider).Connected__c == false)) {
	   				throw new SimpplrException(STR_KEY_ERROR_GDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));

				   }
				   
				GoogleDriveService fileServiceObj = new GoogleDriveService();
            	fileDetails = fileServiceObj.getFileDetail(fileId);
	   			fileDetails.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileId,'provider' => ServiceConstants.STORAGE_TYPE_GDRIVE_STRING,'directory'=> directory});
	   			fileDetails.url = fileDetails.publicUrl;
	   			fileDetails.pdfViewUrl = PageContext.getPageURL(Pages.PdfPreview, new Map<String, String>{'fileId' => fileId,
	   						'provider' => ServiceConstants.STORAGE_TYPE_GDRIVE_STRING, 'filetype'=> fileDetails.fileType});
				fileDetails.viewInExternalSystem = fileDetails.viewInGoogleDrive;
				
	   		} else if ((ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).equalsIgnoreCase(provider)) {
				if((UserContext.Integrations.get(provider) == null) || (UserContext.Integrations.get(provider).Connected__c == false)) {
	   				throw new SimpplrException(STR_KEY_ERROR_DROPBOX_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));

	   			}
	   		
	   			EFSFileService fileServiceObj = new EFSFileService(provider);
	   			fileDetails = fileServiceObj.getFileDetail(fileId,'','', null);
	   			fileDetails.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileId,'provider' => ServiceConstants.STORAGE_TYPE_DROPBOX_STRING,'directory'=> directory});
	   			fileDetails.url = fileDetails.publicUrl;
	   			fileDetails.pdfViewUrl = PageContext.getPageURL(Pages.PdfPreview, new Map<String, String>{'fileId' => fileId,
	   						'provider' => ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, 'filetype'=> fileDetails.fileType});
				fileDetails.viewInExternalSystem = 'https://www.dropbox.com/home'+ Utility.encodeUrlString(fileDetails.fileUrl);
				fileServiceObj.close();
	   		
	   		} else if ((ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).equalsIgnoreCase(provider)) {
	   			if((UserContext.Integrations.get(provider) == null) || (UserContext.Integrations.get(provider).Connected__c == false)) {
	   				throw new SimpplrException(STR_KEY_ERROR_SHAREPOINT_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
	   			}
	   		
	   			EFSFileService fileServiceObj = new EFSFileService(provider);
	   			fileDetails = fileServiceObj.getFileDetail(fileId,rootDirectory,'', 'read');
	   			fileDetails.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileId,'provider' => ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING,'directory'=> directory});
	   			fileDetails.url = fileDetails.publicUrl;
	   			fileDetails.pdfViewUrl = PageContext.getPageURL(Pages.PdfPreview, new Map<String, String>{'fileId' => fileId,
	   						'provider' => ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, 'filetype'=> fileDetails.fileType});
				fileServiceObj.close();
	   		
	   		} else if ((ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING).equalsIgnoreCase(provider)) {	
	   			if((UserContext.Integrations.get(provider) == null) || (UserContext.Integrations.get(provider).Connected__c == false)) {
	   				throw new SimpplrException(STR_KEY_ERROR_ONEDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
	   			}
	   		
	   			EFSFileService fileServiceObj = new EFSFileService(provider);
	   			fileDetails = fileServiceObj.getFileDetail(fileId,rootDirectory,'', 'read');
	   			fileDetails.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileId,'provider' => ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING,'directory'=> directory});
	   			fileDetails.url = fileDetails.publicUrl;
	   			fileDetails.pdfViewUrl = PageContext.getPageURL(Pages.PdfPreview, new Map<String, String>{'fileId' => fileId,
	   						'provider' => ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, 'filetype'=> fileDetails.fileType});
				fileServiceObj.close();
				
			} else if ((ServiceConstants.Video_Provider_Native.equalsIgnoreCase(provider)))	{				
				File__c fileObj = FileDao.getFileRecordDetails(fileId);
				fileDetails = new VideoDao().toFileDetailWrapper(fileObj) ;   
				fileDetails.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileId,'provider' => ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING,'directory'=> directory});
				fileDetails.url = fileDetails.publicUrl;
				fileDetails.isBookmarked = fileDaoObj.isFileBookmarked(fileId, provider);
				fileDetails.rootDirectory = rootdirectory;

			} else {
				ContentDocument contentDocumentObj = fileDaoObj.getFileDetails(fileId);
				Set<String> userIds = new Set<String>();
				userIds.add(contentDocumentObj.Owner.Id);
				PeopleDao.setPeopleNameMapByUserId(userIds);
				fileDetails = ObjectToWrapperAdapter.convertContentDocumentToFileDetailWrapper(contentDocumentObj);
		    	fileDetails.listOfSite = new FileDao().getCVRelatedSites(new Set<Id>{contentDocumentObj.latestPublishedVersionId}, provider).get(contentDocumentObj.id);
				fileDetails.isBookmarked = fileDaoObj.isFileBookmarked(fileId, provider);
	    	}
			fileDetails.isLiked = fileDetails.isLiked == null ? fileDaoObj.isFileLiked(fileId):false;
			fileDetails.likedCount = fileDetails.likedCount ==  null? fileDaoObj.getFileLikes(fileId).size():0;
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileDetails);
			if('mobile'.equalsIgnoreCase(readParam('origin'))){
        		Utility.insertMobileAnalyticsRecord('FileDetail',new Map<String,String>{'fileId'=>fileCriteriaObj.fileId, 'siteId'=>fileCriteriaObj.siteId, 'userAgent'=>readHeader('User-Agent')});
        	}
		    
		} catch (Exception e) {
			logger.logDebug('FileDataServer.getFileDetail()----exception----'+e);
			logger.logError('Could not retrieve file detail',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			e.getMessage(), null);
		}
		return responseToReturn;
    }
        
    @TestVisible 
    private ResponseWrapper getMyFilesIntranetFiles (Criteria.File fileCriteriaObjArg) {
    	logger.logDebug('FileDataServer.getMyFilesIntranetFiles()----fileCriteriaObjArg----'+fileCriteriaObjArg);
	    ResponseWrapper responseToReturn = null;
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	    
	    try {
	    	if(fileCriteriaObjArg.size == null) {
	    		fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
	    	if (fileCriteriaObjArg.nextPageToken == null) {
    			fileCriteriaObjArg.offset = 0;
    			
    		} else {
    			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
    		}
    		
    		FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
    		
    		if( (fileCriteriaObjArg.nextPageToken == null && (fileCriteriaObjArg.isMediaManager == null || fileCriteriaObjArg.isMediaManager == false)) && String.isBlank(fileCriteriaObjArg.term) ) {
	    		if(fileCriteriaObjArg.hideProviderSystemDirs == null || fileCriteriaObjArg.hideProviderSystemDirs == false) {
		    		FileListingWrapper fLWObj4Box = getEFSVirtualFolder();
		    		if(fLWObj4Box != null) {
		    			filePaginatorObj.listOfItems.add(fLWObj4Box);
		    		}
		    		
					FileListingWrapper fLWObj4CRM = getCRMVirtualFolder();
		    		if(fLWObj4CRM != null) {
		    			filePaginatorObj.listOfItems.add(fLWObj4CRM);
		    		}
	    		}
    		}
    		Integer recordLimit = fileCriteriaObjArg.nextPageToken == null ? fileCriteriaObjArg.size - filePaginatorObj.listOfItems.size() + 1 : fileCriteriaObjArg.size + 1;
    		listOfFileWrapper = FileContentProvider.getMyFilesIntranetFiles(fileCriteriaObjArg, recordLimit);
    		
	    	filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
	    	filePaginatorObj.canUpload = true;
	    	
	    	if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
		        		fileCriteriaObjArg.offset < 2000) {
		        filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
		        filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + listOfFileWrapper.size() - 1);
		    } else {
		        filePaginatorObj.nextPageToken = null;
		    }
	    	
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
		    
		} catch (Exception e) {
			logger.logError('Could not retrieve SFDC files',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			null, null);
		}
		logger.logDebug('FileDataServer.getMyFilesIntranetFiles()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
    }
    
    @TestVisible 
    private ResponseWrapper getMyFilesCRMLibFiles(Criteria.File fileCriteriaObjArg) {
    	logger.logDebug('FileDataServer.getMyFilesCRMLibFiles()----fileCriteriaObjArg----'+fileCriteriaObjArg);
	    ResponseWrapper responseToReturn = null;
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	    
	    try {
	    	if(fileCriteriaObjArg.size == null) {
	    		fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
	    	if (fileCriteriaObjArg.nextPageToken == null) {
    			fileCriteriaObjArg.offset = 0;
    			
    		} else {
    			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
    		}
    		
    		listOfFileWrapper = FileContentProvider.getMyFilesCRMLibFiles(fileCriteriaObjArg);
    		
    		FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
    		
    		filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
	    	filePaginatorObj.canUpload = false;
	    	
	    	if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
		        		fileCriteriaObjArg.offset < 2000) {
		        filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
		        filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
		    
		    } else {
		        filePaginatorObj.nextPageToken = null;
		    }
		    
		    FileListingWrapper.DirectoryWrapper currentDirectory = new FileListingWrapper.DirectoryWrapper();
		    currentDirectory.id = 'CRM Files';
		    currentDirectory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.crm_files');
		    currentDirectory.permissions = 'read';
		    currentDirectory.isSystemDir = true;
		    currentDirectory.provider = ServiceConstants.STORAGE_TYPE_INTRANET_STRING;
		    
		    filePaginatorObj.directory = currentDirectory;
    		
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
		    
		} catch (Exception e) {
			logger.logError('Could not retrieve CRM Library files',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		
		logger.logDebug('FileDataServer.getMyFilesCRMLibFiles()----responseToReturn----'+responseToReturn);
    	return responseToReturn;
    }
    
    @TestVisible
    private FileListingWrapper getEFSVirtualFolder() {
    	FileListingWrapper fLWObj = new FileListingWrapper();

    	fLWObj.id = '';
     	fLWObj.permissions = 'read';
     	fLWObj.isSystemDir = true;
	    fLWObj.type = 'System Folder';
	    fLWObj.isDir = true;
	    fLWObj.canDelete = false;
   		fLWObj.canMove = false;
   		fLWObj.owner.id = UserInfo.getUserId();
		fLWObj.owner.name = UserContext.peopleName;
		fLWObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + UserInfo.getUserId(); 
		fLWObj.modifiedAt = System.Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
		fLWObj.modifiedAtDateTime = System.Datetime.now();
   		fLWObj.url = PageContext.getPageURL(Pages.MyFiles) + '';
   		fLWObj.canChangeName = false;
		fLWObj.canSetPermissions = false;
		
    	if (UserContext.isBoxConnected) {
			fLWObj.id = '0';
     		fLWObj.title = 'Box Files';
     		fLWObj.provider = 'box';
    	} else {
			fLWObj = null;
    	}

    	return fLWObj;
    }
    
    @TestVisible
    private FileListingWrapper getCRMVirtualFolder () {
    	FileListingWrapper fLWObj = null;
    	FolderDao folderDaoObj = new FolderDao();
    	
    	if (folderDaoObj.isCRMAvailable()) {
    		fLWObj = new FileListingWrapper();
    		fLWObj.id = 'crm_root_dir';
     		fLWObj.title = 'CRM Files';
     		fLWObj.provider = 'crm';
     		fLWObj.permissions = 'read';
     		fLWObj.isSystemDir = true;
	     	fLWObj.type = 'System Folder';
	     	fLWObj.isDir = true;
	     	fLWObj.canDelete = false;
   			fLWObj.canMove = false;
   			fLWObj.owner.id = UserInfo.getUserId();
			fLWObj.owner.name = UserContext.peopleName;
			fLWObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/people/' + UserInfo.getUserId(); 
			fLWObj.modifiedAt = System.Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
			fLWObj.modifiedAtDateTime = System.Datetime.now();
   			fLWObj.url = PageContext.getPageURL(Pages.MyFiles) + '?#directory=' + fLWObj.id;
   			fLWObj.canChangeName = false;
			fLWObj.canSetPermissions = false;
    	}
    	
    	return fLWObj;
	}
	
	@TestVisible 
    private ResponseWrapper getNativeVideoFiles(String requestData) {
	    ResponseWrapper responseToReturn = null;
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	    FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
	    try {
			Criteria.File fileCriteriaObjArg = (Criteria.File)JSON.deserialize(requestData, Criteria.File.class);
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotEmpty(fileCriteriaObjArg.term)) {
				logger.logDebug('--------enter in external search');
				Criteria.ExternalSearchReq fileSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				String SearchForType = 'File';
				List<String> externalFileIds = new List<String>();
				ExternalSearchService externalSearchService = new ExternalSearchService();
				List<String> bookmarkVideoIds = new List<String>();
				List<Bookmark__c> bookmarkList = [Select id, External_File_Id__c From Bookmark__c where Type__c = 'native_video' 									
													AND people__c =: UserContext.peopleId AND Is_Deleted__c = false WITH SECURITY_ENFORCED Order by LastModifiedDate Desc];
				for(Bookmark__c bookmarkObj : bookmarkList) {
					bookmarkVideoIds.add(bookmarkObj.External_File_Id__c);
				}
				fileSearchCriteria.favouriteIds = bookmarkVideoIds;
				
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchFiles(fileSearchCriteria, SearchForType);
				if(returnWrapper.listOfItems != null && returnWrapper.listOfItems.size() > 0) {
					for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : returnWrapper.listOfItems) {
						Object item = itemWrapperObj.item;
						FileListingWrapper flWrapper = (FileListingWrapper)item;
						externalFileIds.add(flWrapper.id);	
					}					
					listOfFileWrapper = FileContentProvider.getBookmarkedNativeVideoFiles(externalFileIds);
					filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
					filePaginatorObj.nextPageToken = returnWrapper.nextPageToken;
				}
			}
			else {
				if(fileCriteriaObjArg.size == null) {
					fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
				}
				if (fileCriteriaObjArg.nextPageToken == null) {
					fileCriteriaObjArg.offset = 0;
					
				} else {
					fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
				}
				
				listOfFileWrapper = FileContentProvider.getBookmarkedNativeVideoFiles(fileCriteriaObjArg);
				filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
				filePaginatorObj.canUpload = true;
				
				if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
							fileCriteriaObjArg.offset < 2000) {
					filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
					filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
				
				} else {
					filePaginatorObj.nextPageToken = null;
				}
			}
	    	
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
			if('mobile'.equalsIgnoreCase(readParam('origin'))){
        		Utility.insertMobileAnalyticsRecord('FavoriteFile', new Map<String, String>{'term' => fileCriteriaObjArg.term, 'siteId' => fileCriteriaObjArg.siteId, 'userAgent' => readHeader('User-Agent')});
        	}
		    
		} catch (Exception e) {
			logger.logError('Could not retrieve Favorite Video files', e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		
    	return responseToReturn;
    }

    @TestVisible 
    private ResponseWrapper getFavoriteSFDCFiles(String requestData) {
	    ResponseWrapper responseToReturn = null;
		Criteria.File fileCriteriaObjArg = (Criteria.File)JSON.deserialize(requestData, Criteria.File.class);
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	    
	    try {
			FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
	    	if(fileCriteriaObjArg.size == null) {
	    		fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
	    	if (fileCriteriaObjArg.nextPageToken == null) {
    			fileCriteriaObjArg.offset = 0;
    			
    		} else {
    			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
    		}
			if(SimpplrContext.isFeatureEnabled('Full_External_Search') && String.isNotEmpty(fileCriteriaObjArg.term)) {
				logger.logDebug('--------enter in external search');
				Criteria.ExternalSearchReq fileSearchCriteria = (Criteria.ExternalSearchReq)JSON.deserialize(requestData, Criteria.ExternalSearchReq.class);
				String SearchForType = 'File';
				List<String> fileIds = new List<String>();
				ExternalSearchService externalSearchService = new ExternalSearchService();
				
					List<String> bookmarkContentDocumentIds = new List<String>();
					List<Bookmark__c> bookmarkList = [Select id, External_File_Id__c From Bookmark__c where Type__c = 'Intranet' 
													AND Is_Deleted__c = false
													AND people__c =: UserContext.peopleId WITH SECURITY_ENFORCED
													Order by LastModifiedDate Desc];
					for(Bookmark__c bookmarkObj : bookmarkList) {
						bookmarkContentDocumentIds.add(bookmarkObj.External_File_Id__c);
					}
					fileSearchCriteria.favouriteIds = bookmarkContentDocumentIds;
				
				ExternalSearchWrapper.TopContentsWrapper returnWrapper = externalSearchService.searchFiles(fileSearchCriteria, SearchForType);
				if(returnWrapper.listOfItems != null && returnWrapper.listOfItems.size() > 0) {
					for(ExternalSearchWrapper.ItemWrapper itemWrapperObj : returnWrapper.listOfItems) {
						Object item = itemWrapperObj.item;
						FileListingWrapper flWrapper = (FileListingWrapper)item;
						fileIds.add(flWrapper.id);

					}							
					listOfFileWrapper = FileContentProvider.getMyFilesBookmarkedFiles(fileIds);	
					filePaginatorObj.nextPageToken = returnWrapper.nextPageToken;	
				}
			}
    		else {
				listOfFileWrapper = FileContentProvider.getMyFilesBookmarkedFiles(fileCriteriaObjArg);
				if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
		        		fileCriteriaObjArg.offset < 2000) {
		        filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
		        filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
		    
				} else {
					filePaginatorObj.nextPageToken = null;
				}
			}
		    
	    	filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
	    	filePaginatorObj.canUpload = true;
	    	
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
			if('mobile'.equalsIgnoreCase(readParam('origin'))){
        		Utility.insertMobileAnalyticsRecord('FavoriteFile',new Map<String,String>{'term'=>fileCriteriaObjArg.term, 'siteId'=>fileCriteriaObjArg.siteId, 'userAgent'=>readHeader('User-Agent')});
        	}
		    
		} catch (Exception e) {
			logger.logError('Could not retrieve Favorite SFDC files',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		
    	return responseToReturn;
    }
    
    @TestVisible 
    private ResponseWrapper getFavoriteFiles(Criteria.File fileCriteriaObjArg) {
	    ResponseWrapper responseToReturn = null;
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	    
	    try {
	    	if(fileCriteriaObjArg.size == null) {
	    		fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
	    	if (fileCriteriaObjArg.nextPageToken == null) {
    			fileCriteriaObjArg.offset = 0;
    			
    		} else {
    			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
    		}
    		
		listOfFileWrapper = FileContentProvider.getFavoriteFiles(fileCriteriaObjArg);
	    Map<String,Object> result = New Map<String,Object>();
	    	if (listOfFileWrapper.size() == (fileCriteriaObjArg.size + 1) && fileCriteriaObjArg.offset < 2000) {
	        	listOfFileWrapper.remove(listOfFileWrapper.size() - 1);
	        	result.put('nextPageToken',fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
        } else {
        	result.put('nextPageToken',null);
	    }
	    	result.put('listOfItems',listOfFileWrapper);
	    	result.put('canUpload',true);
    		
    		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
						
			if('mobile'.equalsIgnoreCase(readParam('origin'))){
        		Utility.insertMobileAnalyticsRecord('FavoriteFile',new Map<String,String>{'term'=>fileCriteriaObjArg.term, 'siteId'=>fileCriteriaObjArg.siteId, 'userAgent'=>readHeader('User-Agent')});
        	}
		    
		} catch (Exception e) {
			logger.logError('Could not retrieve Favorite files',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		
    	return responseToReturn;
    }
    
    @TestVisible 
    private ResponseWrapper getFavoriteCRMFiles(Criteria.File fileCriteriaObjArg) {
	    ResponseWrapper responseToReturn = null;
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	    
	    try {
	    	if(fileCriteriaObjArg.size == null) {
	    		fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
	    	if (fileCriteriaObjArg.nextPageToken == null) {
    			fileCriteriaObjArg.offset = 0;
    			
    		} else {
    			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
    		}
    		
		listOfFileWrapper = FileContentProvider.getMyFilesFavoriteCRMFiles(fileCriteriaObjArg);
	    	
	    	Map<String,Object> result = New Map<String,Object>();
	    	if (listOfFileWrapper.size() == (fileCriteriaObjArg.size + 1) && fileCriteriaObjArg.offset < 2000) {
	        	listOfFileWrapper.remove(listOfFileWrapper.size() - 1);
	        	result.put('nextPageToken',fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
        } else {
        	result.put('nextPageToken',null);
	    }
	    	result.put('listOfItems',listOfFileWrapper);
	    	result.put('canUpload',true);
	    	
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		    
		} catch (Exception e) {
			logger.logError('Could not retrieve Favorite SFDC files',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
    	return responseToReturn;
    }
    
    @TestVisible 
    private ResponseWrapper getSiteCRMFiles(Criteria.File fileCriteriaObjArg) {
	    ResponseWrapper responseToReturn = null;
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	    
	    try {
	    	if(fileCriteriaObjArg.size == null) {
	    		fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
		    FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
	    	
	    	if (fileCriteriaObjArg.nextPageToken == null) {
    			fileCriteriaObjArg.offset = 0;
    			
    		} else {
    			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
    		}
    		
			FolderDao daoObj = new FolderDao(); 
    		if (FILTER_BOOKMARKED.equalsIgnoreCase(fileCriteriaObjArg.filter)) {
    			listOfFileWrapper = FileContentProvider.getSiteCRMBookmarkedFiles(fileCriteriaObjArg);
    			
    		} else if (String.isNotBlank(fileCriteriaObjArg.term)) {
    			listOfFileWrapper = FileContentProvider.searchSiteCRMFilesInAllLibraries(fileCriteriaObjArg);
		
			} else if (fileCriteriaObjArg.isMediaManager == true && String.isBlank(fileCriteriaObjArg.directory)) {
				listOfFileWrapper = FileContentProvider.getSiteCRMLibraries(fileCriteriaObjArg);
				
			} else if (String.isNotBlank(fileCriteriaObjArg.directory) &&
	    				  daoObj.isSystemFolder(fileCriteriaObjArg.siteId, fileCriteriaObjArg.directory)) {
				listOfFileWrapper = FileContentProvider.getSiteCRMLibraries(fileCriteriaObjArg);
				filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
				filePaginatorObj.directory.id =  fileCriteriaObjArg.directory;
				filePaginatorObj.directory.rootDirectory =  fileCriteriaObjArg.directory;
				filePaginatorObj.directory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.crm_files');
				filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_CRM_STRING;
				filePaginatorObj.directory.isSystemDir = true;
				filePaginatorObj.directory.permissions = 'read';
				filePaginatorObj.directory.canLinkFolder = (SiteContext.isCurrentUserSiteManager || (SiteContext.isPublicSite && UserContext.isUserAppModerator));
				filePaginatorObj.canCreateFolder = false;
				
			} else {
    			listOfFileWrapper = FileContentProvider.getSiteCRMFilesInLibrary(fileCriteriaObjArg);
    			filePaginatorObj.directory = FileContentProvider.getCRMFolderDetails(fileCriteriaObjArg.directory, fileCriteriaObjArg.siteId);
				filePaginatorObj.canCreateFolder = false;
				FileListingWrapper.ParentWrapper parentWrapperObj = new FileListingWrapper.ParentWrapper(); 
				Folder__c folderObj = daoObj.getSystemFoldersForSite(fileCriteriaObjArg.siteId, ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.get('CRM_FILES'))[0];
				parentWrapperObj.id =  folderObj.Id;		
				parentWrapperObj.name =  LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.crm_files');
		        filePaginatorObj.listOfParents.add(parentWrapperObj);
			}
			
	    	filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
	    	filePaginatorObj.canUpload = false;
	    	
	    	if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
		        		fileCriteriaObjArg.offset < 2000) {
		        filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
		        filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
		    
		    } else {
		        filePaginatorObj.nextPageToken = null;
		    }
	    	
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
		    
		} catch (Exception e) {
			logger.logError('Could not retrieve SITE CRM files',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
    	return responseToReturn;
    }
    
    /**
	 * @api {get} /apex/DataServerRW?target=FileDataServer&action=getMedia getMedia
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName Files
	 *
	 * @apiParam {String} id - id of an album
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Album.getMedia
	 * 2. Used in AlbumDetail
	 * 
	 * @apiSuccess {List[FileListingWrapper]} Response.listOfItems List of all the photos/media in an album
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	 * @apiError (Error 404) SimpplrException Album not found
	*/
    @TestVisible 
    private ResponseWrapper getMedia (Criteria.File fileCriteriaObjArg) {
	    String redirectUrl = ''; 
	    
	    ResponseWrapper responseToReturn = null;
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	   
	    try {
	    		
	    		if(!SimpplrContext.AllowedFeatures.containsIgnoreCase('album')){
	    			throw new SimpplrException(ServiceConstants.ERROR_404);
	    		}
		    	if (fileCriteriaObjArg.nextPageToken == null) {
	    			fileCriteriaObjArg.offset = 0;
	    			
	    		} else {
	    			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
	    		}
			
		    FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
			if (String.isNotBlank(fileCriteriaObjArg.versionHistoryId)) {
				FileDao fileDaoObj = new FileDao();
				listOfFileWrapper = fileDaoObj.getAlbumMediaByVersionId(fileCriteriaObjArg.id, fileCriteriaObjArg.versionHistoryId);
				filePaginatorObj.totalRecords = listOfFileWrapper.isEmpty() ? 0 : listOfFileWrapper.size();
				filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
			} else {
				listOfFileWrapper = FileContentProvider.getSiteAlbumDetailAllFiles(fileCriteriaObjArg);
				filePaginatorObj.totalRecords = listOfFileWrapper.isEmpty()?0:(listOfFileWrapper[0].photoCount + listOfFileWrapper[0].videoCount);
	    		filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
			}
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
	    
		} catch (Exception e) {
			logger.logError('Could not retrieve ALBUM files',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        	if(String.isNotBlank(redirectUrl)) {
        		responseToReturn.redirectUrl = redirectUrl;
        	}		
		}
    	return responseToReturn;
    }
    
    @TestVisible 
    private ResponseWrapper getSiteChatterFoldersAndFiles(Criteria.File fileCriteriaObjArg) {
	    ResponseWrapper responseToReturn = null;
    	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
	   
	    try {
	    	Boolean includeFolders;
	    	Integer pulledfolderCount = 0;
	    	if(fileCriteriaObjArg.size == null) {
	    		fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
	    	if (fileCriteriaObjArg.nextPageToken == null) {
    			fileCriteriaObjArg.offset = 0;
		    	
		    	if(FILTER_BOOKMARKED.equalsIgnoreCase(fileCriteriaObjArg.filter)) {
		    		includeFolders = false;
		    	
		    	} else {
		    		includeFolders = true;
		    	}
		    	
    		} else {
    			List<String> parts = fileCriteriaObjArg.nextPageToken.split(':');
    			fileCriteriaObjArg.offset = Integer.valueOf(parts[0]);
    			includeFolders = Boolean.valueOf(parts[1]);
    		}
    		
    		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter);
    		Integer filesRecordLimit = fileCriteriaObjArg.size + 1;
		    FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
    		logger.logDebug('FileDataServer.getSiteChatterFoldersAndFiles()--974--isWriteFolderFilter----'+isWriteFolderFilter +'--filesRecordLimit-'+filesRecordLimit+'--includeFolders--'+includeFolders);
    		if(isWriteFolderFilter) {
    			listOfFileWrapper = FileContentProvider.getSiteChatterWriteFolders(fileCriteriaObjArg);
    			filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
	    	} else if(includeFolders) {
    			if(String.isBlank(fileCriteriaObjArg.term)) {
					logger.logDebug('FileDataServer.getSiteChatterFoldersAndFiles()--980--fileCriteriaObjArg----'+fileCriteriaObjArg);
    				listOfFileWrapper = FileContentProvider.getSiteChatterFolders(fileCriteriaObjArg);
    			}
    			
    			if (listOfFileWrapper.size() == (fileCriteriaObjArg.size + 1) &&
		        		fileCriteriaObjArg.offset < 2000) {
	        		filesRecordLimit = 0;	
        		} else {
        			filesRecordLimit = fileCriteriaObjArg.size + 1 - listOfFileWrapper.size();
        			fileCriteriaObjArg.offset = 0;
        			includeFolders = false;
        		}
        		
        		pulledfolderCount = listOfFileWrapper.size();
	    	}
    		
    		// If 'write_folders' filter is there then no need to include files.
    		if (!isWriteFolderFilter){
    			if (filesRecordLimit > 0) {
		    		listOfFileWrapper.addAll(FileContentProvider.getSiteFilesAllFiles(fileCriteriaObjArg, filesRecordLimit));
	    		}
	    		
		    	if (String.isNotBlank(fileCriteriaObjArg.directory)) {
		    		Boolean isAlbumSubFolder = false;
		    		
		    		if (String.isBlank(fileCriteriaObjArg.term)) {
		    			filePaginatorObj.directory = FileContentProvider.getIntranetFolderDetails(fileCriteriaObjArg.directory);
		    		
			    		if (String.isNotBlank(filePaginatorObj.directory.path)) {
			    			List<String> listOfParentFolderIds = filePaginatorObj.directory.path.split(',');
			    			filePaginatorObj.listOfParents = FileContentProvider.getListOfParentsForChatterFolder(listOfParentFolderIds);
			    		}
			    		
			    		for (FileListingWrapper.ParentWrapper parent : filePaginatorObj.listOfParents) {
			    			if (ServiceConstants.DEFAULT_SITE_SYSTEM_SUB_FOLDERS_MAP.get('ALBUMS').equalsIgnoreCase(parent.name)
			    				&& parent.isSystemFolder) {
			    				isAlbumSubFolder = true;
			    				break;
			    			}
			    		}
						if (filePaginatorObj.directory.isSystemDir) {
							filePaginatorObj.canUpload = false;
							filePaginatorObj.canCreateFolder = false;	
							if (EFSConstants.EFS_SYSTEM_FOLDERS_MAP.get('box').equalsIgnoreCase(filePaginatorObj.directory.name)) {
								filePaginatorObj.canCreateFolder = SiteContext.canManage();
							} 

						} else if (isAlbumSubFolder) {
							filePaginatorObj.canCreateFolder = false;
							filePaginatorObj.canUpload = false;
							
						} else if ('read'.equalsIgnoreCase(filePaginatorObj.directory.permissions)) {				    		
								filePaginatorObj.canUpload = SiteContext.canManage();
								filePaginatorObj.canCreateFolder = filePaginatorObj.canUpload;
															
						} else if ('readwrite'.equalsIgnoreCase(filePaginatorObj.directory.permissions)) {
							filePaginatorObj.canUpload = true;
							filePaginatorObj.canCreateFolder = true;
							
						} else {				    		
							filePaginatorObj.canCreateFolder = SiteContext.canManage();
														
						}
		    		}
				} else {
					// Site Root
					filePaginatorObj.canUpload = true;
					filePaginatorObj.canCreateFolder = SiteContext.canManage();
				}				
    		
		    	filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
		    	
		    	if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
			        		fileCriteriaObjArg.offset < 2000) {
			        filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
			        if(pulledfolderCount == 0 || pulledfolderCount == (fileCriteriaObjArg.size + 1)) {
			        	filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
			        } else {
			        	filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset - pulledfolderCount + fileCriteriaObjArg.size);
			        }
			        filePaginatorObj.nextPageToken += (':' + String.valueOf(includeFolders));
			    } else {
			        filePaginatorObj.nextPageToken = null;
			    }
            }
            
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
		} catch (Exception e) {
			logger.logError('could not retrieve file data',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, 
        			MessageHelper.translateSFMessageToErrorCode(e), null);
		}
		
    	return responseToReturn;
	}
	
	private ResponseWrapper getSiteVideoFolderAndFiles(Criteria.File fileCriteriaObjArg) {
	    ResponseWrapper responseToReturn = null;	   
	    try {
			FileContentProvider provider = new FileContentProvider(); 
			FolderDao daoObj = new FolderDao();
	    	Boolean includeFolders;
	    	Integer pulledfolderCount = 0;
	    	if(fileCriteriaObjArg.size == null) {
	    		fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
	    	}
	    	if (fileCriteriaObjArg.nextPageToken == null) {
    			fileCriteriaObjArg.offset = 0;
		    	includeFolders = FILTER_BOOKMARKED.equalsIgnoreCase(fileCriteriaObjArg.filter) ? false : true;
		    	
    		} else {
    			List<String> parts = fileCriteriaObjArg.nextPageToken.split(':');
    			fileCriteriaObjArg.offset = Integer.valueOf(parts[0]);
    			includeFolders = Boolean.valueOf(parts[1]);
    		}
    		
    		Integer filesRecordLimit = fileCriteriaObjArg.size + 1;
			FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper();
			if(String.isNotBlank(fileCriteriaObjArg.directory)) {
				filePaginatorObj.directory = provider.getVideoFolderDetails(fileCriteriaObjArg.directory);		
				if (String.isNotBlank(filePaginatorObj.directory.path)) {
					List<String> listOfParentFolderIds = filePaginatorObj.directory.path.split(',');
					filePaginatorObj.listOfParents = FileContentProvider.getListOfParentsForVideoFolder(listOfParentFolderIds);
				}	
			}		    	
			Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter);
			List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
			if(includeFolders) {
				listOfFileWrapper.addAll(provider.getSiteVideoFolders(fileCriteriaObjArg));
				if (listOfFileWrapper.size() == (fileCriteriaObjArg.size + 1) &&
						fileCriteriaObjArg.offset < 2000) {
					filesRecordLimit = 0;	
				} else {
					filesRecordLimit = fileCriteriaObjArg.size + 1 - listOfFileWrapper.size();
					fileCriteriaObjArg.offset = 0;
					includeFolders = false;
				}	
			}		
			pulledfolderCount = listOfFileWrapper.size();

			if (!isWriteFolderFilter && filesRecordLimit > 0) {
				listOfFileWrapper.addAll(provider.getSiteVideoFiles(fileCriteriaObjArg, filesRecordLimit));
			}					
			
			if (String.isNotBlank(fileCriteriaObjArg.directory)) {
				if (filePaginatorObj.directory.isSystemDir) {
					filePaginatorObj.canUpload = filePaginatorObj.directory.canCreateFolder;
					filePaginatorObj.canCreateFolder = filePaginatorObj.canUpload;

				} else if ('read'.equalsIgnoreCase(filePaginatorObj.directory.permissions)) {				    		
						filePaginatorObj.canUpload = SiteContext.canManage();
						filePaginatorObj.canCreateFolder = filePaginatorObj.canUpload;
													
				} else if ('readwrite'.equalsIgnoreCase(filePaginatorObj.directory.permissions)) {
					filePaginatorObj.canUpload = true;
					filePaginatorObj.canCreateFolder = true;
					
				}
			}				
		
			filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
			
			if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
						fileCriteriaObjArg.offset < 2000) {
				filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
				if(pulledfolderCount == 0 || pulledfolderCount == (fileCriteriaObjArg.size + 1)) {
					filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
				} else {
					filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset - pulledfolderCount + fileCriteriaObjArg.size);
				}
				filePaginatorObj.nextPageToken += (':' + String.valueOf(includeFolders));
			} else {
				filePaginatorObj.nextPageToken = null;
			}
            
	    	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
		} catch (Exception e) {
			logger.logError('FileDataServer.getSiteVideoFolderAndFiles()----Exception Occcured----',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		
    	return responseToReturn;
    }
    
    @TestVisible 
    private ResponseWrapper getSiteBoxFiles (Criteria.File fileCriteriaObjArg) {
    	logger.logDebug('FileDataServer.getSiteBoxFiles()----fileCriteriaObjArg----'+fileCriteriaObjArg);
    	fileCriteriaObjArg.size = 16;
    	ResponseWrapper responseWrapperObj = null;
    	
    	if (fileCriteriaObjArg.nextPageToken == null) {
			fileCriteriaObjArg.offset = 0;
			
		} else {
			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
		}
		
		FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
     	List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
     	
     	if (String.isNotBlank(fileCriteriaObjArg.term)) {
     		listOfFileWrapper = BoxContentProvider.searchFiles(fileCriteriaObjArg);		
     	
     	} else if (UserContext.isBoxConnected) {
     		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter);
     		FolderDao daoObj = new FolderDao();
     		/**
     			In this case of 'isWriteFolderFilter' for the first call we need to fetch
     			all the linked folders so the directory would be null for this case.
     			
     			And after the second call there will always be a directory and then it will move to the 'Not Blank Directory' case
     		**/
     		if(daoObj.isSystemFolder(fileCriteriaObjArg.siteId, fileCriteriaObjArg.directory) || 
		     			(String.isBlank(fileCriteriaObjArg.directory) && isWriteFolderFilter) || 
		     			(String.isNotBlank(fileCriteriaObjArg.siteId) && (fileCriteriaObjArg.isMediaManager != null && fileCriteriaObjArg.isMediaManager) && String.isBlank(fileCriteriaObjArg.directory))) {
	     		filePaginatorObj.canUpload = false;
	 			listOfFileWrapper = BoxContentProvider.getSiteLinkedBoxFolders(fileCriteriaObjArg);
	 			filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
	 			filePaginatorObj.directory.id = fileCriteriaObjArg.directory;
				filePaginatorObj.directory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.box_files');
	 			filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_BOX_STRING;
				filePaginatorObj.directory.canCreateBoxFolder = String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : UserContext.sitesIManageIdSet.contains(fileCriteriaObjArg.siteId);
				filePaginatorObj.directory.canLinkBoxFolder = UserContext.sitesIManageIdSet.contains(fileCriteriaObjArg.siteId);
				filePaginatorObj.directory.isSystemDir = true;
	
	     	} else if (String.isNotBlank(fileCriteriaObjArg.directory)) {
				String folderPermission = daoObj.getExternalFolderPermissions(fileCriteriaObjArg.rootDirectory, fileCriteriaObjArg.siteId);		
				FileListingWrapper.BoxFolderContentsWrapper boxFolderContents = BoxContentProvider.getContentsAssociatedToFolder(fileCriteriaObjArg, folderPermission); 
				if(boxFolderContents.isAccessDenied == true) {
					filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
					filePaginatorObj.directory.id = fileCriteriaObjArg.directory;
					filePaginatorObj.directory.name = fileCriteriaObjArg.name;
					filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_BOX_STRING;
					filePaginatorObj.directory.isAccessDenied = true; 
					filePaginatorObj.listOfParents = boxFolderContents.listOfParents;
					listOfFileWrapper = boxFolderContents.listOfFile;
				} else {

					listOfFileWrapper = boxFolderContents.listOfFile;
					filePaginatorObj.canUpload = boxFolderContents.canUpload;
					filePaginatorObj.listOfParents = boxFolderContents.listOfParents;
					
					filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
					filePaginatorObj.directory.id = fileCriteriaObjArg.directory;
					filePaginatorObj.directory.name = boxFolderContents.folderName;
					filePaginatorObj.directory.permissions = folderPermission;
					filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_BOX_STRING;
					filePaginatorObj.directory.canCreateBoxFolder = String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : UserContext.sitesIManageIdSet.contains(fileCriteriaObjArg.siteId);
	     		}	
    		}			
		}
		filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
			
		if (filePaginatorObj.listOfItems != null && filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
							fileCriteriaObjArg.offset < 2000) {
			filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
			filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
			
		} else {
			filePaginatorObj.nextPageToken = null;
		}
			
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
        return responseWrapperObj;
    }
    
    @TestVisible 
    private ResponseWrapper getMyBoxFiles(Criteria.File fileCriteriaObjArg) {
    	
    	if (!UserContext.isBoxConnected) {
    		throw new SimpplrException(ExceptionCode.USER_NOT_CONNECTED_TO_BOX.name());
    	}
    	
    	if (fileCriteriaObjArg.nextPageToken == null) {
			fileCriteriaObjArg.offset = 0;
			
		} else {
			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
		}

     	ResponseWrapper responseWrapperObj = null;
		FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
     	
     	List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
     	
     	Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter);
     	
     	if (FILTER_BOOKMARKED.equalsIgnoreCase(fileCriteriaObjArg.filter)) {
     		listOfFileWrapper = BoxContentProvider.getBookmarkedFiles(fileCriteriaObjArg);
     		
     	} else if (String.isNotBlank(fileCriteriaObjArg.term)) {
     		listOfFileWrapper = BoxContentProvider.searchFiles(fileCriteriaObjArg);
     		
     	} else {
     		if('box_root_dir'.equalsIgnoreCase(fileCriteriaObjArg.directory)) {
	 			fileCriteriaObjArg.directory = '';
	 		}
     		
     		if(isWriteFolderFilter) {
     			fileCriteriaObjArg.size = ServiceConstants.BOX_API_FOLDER_ITEMS_LIMIT;
     		}
     		
     		FileListingWrapper.BoxFolderContentsWrapper boxFolderContents = BoxContentProvider.getContentsAssociatedToFolder(fileCriteriaObjArg, null); 
     		listOfFileWrapper = boxFolderContents.listOfFile;
   			filePaginatorObj.canUpload = boxFolderContents.canUpload;
     		filePaginatorObj.listOfParents = boxFolderContents.listOfParents;
     		filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
     		filePaginatorObj.directory.provider = 'box';
     		
     		if (String.isNotBlank(fileCriteriaObjArg.directory)) {
	     		filePaginatorObj.directory.id = fileCriteriaObjArg.directory;
	     		filePaginatorObj.directory.name = boxFolderContents.folderName;
	     		filePaginatorObj.directory.canCreateBoxFolder = String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : boxFolderContents.canUpload;
     		} else {
     			filePaginatorObj.directory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.box_files');
	 			filePaginatorObj.directory.canCreateBoxFolder = String.isNotBlank(SimpplrContext.boxManagedPermission) && 'box'.equalsIgnoreCase(SimpplrContext.boxManagedPermission) ? false : true;
	 			filePaginatorObj.directory.canLinkBoxFolder = false;
	 			filePaginatorObj.directory.isSystemDir = true;
     		}
     		
     	}
    	
		filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
		if ( isWriteFolderFilter == false && filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) && fileCriteriaObjArg.offset < 2000) {
	        filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
	        filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
	   
	    } else {
	        filePaginatorObj.nextPageToken = null;
	    }
	    
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
        return responseWrapperObj;
	}
	
    @TestVisible 
    private ResponseWrapper getGoogleDriveFolderContents(Criteria.File fileCriteriaObjArg) {
		if (!UserContext.isGoogleDriveConnected) {
    		throw new SimpplrException(STR_KEY_ERROR_GDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
        }
		ResponseWrapper responseWrapperObj;    	
     	FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper();        

		Map<String, Object> folderContents = new GoogleDriveService().getFolderContents(fileCriteriaObjArg);
		filePaginatorObj.listOfItems = (List<FileListingWrapper>) folderContents.get('listOfItems');
		List<String> externalFileIDs = new List<String>();
		FileDao fileDaoObj = new FileDao();
		for(FileListingWrapper fw: filePaginatorObj.listOfItems) {
			fw.canDelete = false;
			externalFileIDs.add(fw.id);
		}
		Set<String> setOfBookmarks = fileDaoObj.getSetOfBookmarkedFiles(externalFileIDs, ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
		Set<String> setOfLikes = fileDaoObj.getSetOfLikedFiles(externalFileIDs);
		for(FileListingWrapper fw: filePaginatorObj.listOfItems) {
			if (setOfLikes.contains(fw.id)) {
				fw.isLiked = true;
			}
			if (setOfBookmarks.contains(fw.id)){
				fw.isFavorited = true;
            }
            
            fw.permissions = null;
		} 

		filePaginatorObj.nextPageToken = (String) folderContents.get('nextPageToken');
		filePaginatorObj.directory = (FileListingWrapper.DirectoryWrapper) folderContents.get('directory');
        filePaginatorObj.directory.permissions = null;
        FileListingWrapper.ParentWrapper parentWrap = new FileListingWrapper.ParentWrapper();
		parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.googledrive_files');
		filePaginatorObj.listOfParents.add(parentWrap);
		filePaginatorObj.canUpload = filePaginatorObj.directory.canCreateFolder;
        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);		
        return responseWrapperObj;
	}

    @TestVisible 
    private ResponseWrapper getMyDropboxFiles(Criteria.File fileCriteriaObjArg) {
    	
    	if(!UserContext.isDropboxConnected) {
    		throw new SimpplrException(STR_KEY_ERROR_DROPBOX_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
    	}
    	
     	ResponseWrapper responseWrapperObj = null;
		FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
     	
     	List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
     	EFSFileService fs = new EFSFileService('dropbox');
     	Boolean writeToFolder = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter);
     	try {
	     	if (String.isNotBlank(fileCriteriaObjArg.term) || FILTER_BOOKMARKED.equalsIgnoreCase(fileCriteriaObjArg.filter)) {
				Map<String, Object> searchResponse = fs.searchFilesDropbox('MyFiles', fileCriteriaObjArg);
				listOfFileWrapper = (List<FileListingWrapper>) searchResponse.get('listOfFiles');
	     	} else {
	     		String directoryId = '';
	     		if(String.isNotBlank(fileCriteriaObjArg.directory)){
	     			directoryId = (fileCriteriaObjArg.directory.equalsIgnoreCase('root') ? '' : fileCriteriaObjArg.directory);	
	     		}     		
	     		
				Integer recordLimit = fileCriteriaObjArg.size = writeToFolder == true ?  1000 : fileCriteriaObjArg.size;
	     		String nextPageToken = fileCriteriaObjArg.nextPageToken = String.isBlank(fileCriteriaObjArg.nextPageToken) ? null : fileCriteriaObjArg.nextPageToken;
	     		String sortBy = fileCriteriaObjArg.sortBy = String.isBlank(fileCriteriaObjArg.sortBy) ? 'alphabetical' : fileCriteriaObjArg.sortBy;
	     		listOfFileWrapper = fs.listFiles(directoryId, fileCriteriaObjArg);
	     		
	     		if (String.isBlank(directoryId)) {
		     		filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
		     		filePaginatorObj.directory.id = 'root';
		     		filePaginatorObj.directory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.dropbox_files');
	                filePaginatorObj.directory.canCreateFolder = true;
	                filePaginatorObj.directory.canLinkFolder = false;
	                filePaginatorObj.directory.isSystemDir = true;
	     			filePaginatorObj.canUpload = true;
	     			filePaginatorObj.directory.permissions = 'readwrite';
	     			filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;
	     					    		
		    		for(FileListingWrapper fw: listOfFileWrapper) {
		    			if(fw.id.equalsIgnoreCase(SimpplrContext.integrations.get(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).Root_Folder_Id__c)) {
		    				fw.canDelete = false;
		    				fw.canRemove = false;
		    				fw.canUnlink = false;
		    				fw.canChangeName = false;
		    			}
		    		}
	     		} else {
	     			Set<String> siteFolderExternalIds = new Set<String>();
	     			String parentPerm = 'read';
		        	// Fetch the System Site files to hide on MyFiles 
					FolderDao daoObj = new FolderDao();
		    		
		    		for(Folder__c siteFold: daoObj.getEFSSiteFolderForMyFilesPage('dropbox')) {
		    			siteFolderExternalIds.add(siteFold.External_Folder_Id__c.toLowerCase());
		    			if(directoryId.startsWith(siteFold.External_Folder_Id__c)) {
		    				parentPerm = siteFold.Permissions__c.toLowerCase();
		    			}
		    		}
		    		
		    		for(FileListingWrapper fw: listOfFileWrapper) {
		    			if(siteFolderExternalIds.contains(fw.id.toLowerCase())) {
		    				fw.canDelete = false;
		    				fw.canRemove = false;
		    				fw.canUnlink = false;
		    				fw.canChangeName = false;
		    			}
		    		}
		    		
	     			filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
	 				filePaginatorObj.directory.id = directoryId;
	 				filePaginatorObj.directory.name = directoryId.substringAfterLast('/');
		 			filePaginatorObj.directory.isSystemDir = false;
	     			filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;
		     		
		     		if(!writeToFolder) {
		     			FileDetailWrapper foldDetail = fs.getFileDetail('', fileCriteriaObjArg.directory, '', '');
		     			filePaginatorObj.directory.permissions = foldDetail.directory.permissions;
	                    if(foldDetail.isDir && foldDetail.directory.permissions.equalsIgnoreCase('READWRITE')) {
	                    	filePaginatorObj.canUpload = true;
	                    	filePaginatorObj.directory.canCreateFolder = true;
	                    }
		     		}
		     		
		     		String parentPath = directoryId.substringBeforeLast('/');
					FileListingWrapper.ParentWrapper parentWrap = new FileListingWrapper.ParentWrapper();
					parentWrap.id = 'root';
					parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.dropbox_files');
					filePaginatorObj.listOfParents.add(parentWrap);
						
		     		String consolidatedPath = '';
		     		
					for(String foldName: parentPath.split('/')) {
						if(String.isNotBlank(foldName)) {
							consolidatedPath += '/' + foldName;
							FileListingWrapper.ParentWrapper rParentWrap = new FileListingWrapper.ParentWrapper();
							rParentWrap.id = consolidatedPath;
							rParentWrap.name = foldName;
							filePaginatorObj.listOfParents.add(rParentWrap);
						}
					}
	     		}
     		}
     	} catch (EFSException se) {
     		logger.logDebug(se.getMessage());
     	}
     	fs.close();
		filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
		
		if (!writeToFolder && String.isNotBlank(fs.nextPageToken) && filePaginatorObj.listOfItems.size() == fileCriteriaObjArg.size) {
	        filePaginatorObj.nextPageToken = fs.nextPageToken;
	    } else {
	        filePaginatorObj.nextPageToken = null;
	    }
	    
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
        return responseWrapperObj;
    }
        
    @TestVisible 
    private ResponseWrapper getFavoriteGoogleDriveFiles(Criteria.File fileCriteriaObjArg){
    	 
    	if (!UserContext.isGoogleDriveConnected) {
    		throw new SimpplrException(STR_KEY_ERROR_GDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
    	}
    	
     	ResponseWrapper responseWrapperObj = null;
		FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
     	
        List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
        GoogleDriveService gdServiceObj = new GoogleDriveService();
        GoogleDriveModel.FileListResponse fileListResp = new GoogleDriveModel.FileListResponse();
        try {
          
            fileListResp = gdServiceObj.getFavoriteFiles(fileCriteriaObjArg.size, 
                    fileCriteriaObjArg.nextPageToken, fileCriteriaObjArg.term);

            GoogleDriveDataAdapter converterObj = new GoogleDriveDataAdapter();			
            listOfFileWrapper = converterObj.convertListOfFilesToWrapper(fileListResp.files);        			
     	} catch (EFSException se) {
     		logger.logDebug(se.getMessage());
         }
         
		filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
		
		if (String.isNotBlank(fileListResp.nextPageToken) && filePaginatorObj.listOfItems.size() == fileCriteriaObjArg.size) {
	        filePaginatorObj.nextPageToken = fileListResp.nextPageToken;
	   
	    } else {
	        filePaginatorObj.nextPageToken = null;
	    }
	    
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
        return responseWrapperObj;
    }
     
    @TestVisible 
    private ResponseWrapper getFavoriteBoxFiles(Criteria.File fileCriteriaObjArg) {
    	
    	if (!UserContext.isBoxConnected) {
    		throw new SimpplrException(ExceptionCode.USER_NOT_CONNECTED_TO_BOX.name());
    	}
    	
    	if (fileCriteriaObjArg.nextPageToken == null) {
			fileCriteriaObjArg.offset = 0;
			
		} else {
			fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
		}
		
     	ResponseWrapper responseWrapperObj = null;
		FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
     	List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
 		listOfFileWrapper = BoxContentProvider.getBookmarkedFiles(fileCriteriaObjArg);
		filePaginatorObj.listOfItems.addAll(listOfFileWrapper);

		if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) &&
	        		fileCriteriaObjArg.offset < 2000) {
	        filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
	        filePaginatorObj.listOfItems.addAll(filePaginatorObj.listOfItems);
	        filePaginatorObj.nextPageToken = String.valueOf(fileCriteriaObjArg.offset + fileCriteriaObjArg.size);
	   
	    } else {
	        filePaginatorObj.nextPageToken = null;
	    }
	    
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
        return responseWrapperObj;
    }
     
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=createFolder createChatterFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName Folder
	 *
	 * @apiParam (Post Parameter) {Object} data  CriteriaFolder
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.createFolder
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {Object} FileListingWrapper Chatter Folder record just created
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper createChatterFolder (Criteria.Folder folderObjArg) {
     	
     	ResponseWrapper responseWrapperObj = null;
     	FileListingWrapper wrapperObj = FileContentProvider.createChatterFolder(folderObjArg.name, folderObjArg.directory, readParam('siteId'), folderObjArg.permissions);
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
     	return responseWrapperObj;
    }
     
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=createBoxFolder createBoxFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName createBoxFolder
	 *
	 * @apiParam (Query Parameter) {String} action createBoxFolder
	 * @apiParam (Post Parameter) {Object} data  {directory, rootDirectory, name, permissions, siteId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.createBoxFolder
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result Box Folder record just created
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper createBoxFolder(Criteria.Folder folderObjArg) {
     	ResponseWrapper responseWrapperObj = null;
     	if('box_root_dir'.equalsIgnoreCase(folderObjArg.directory)) {
 			folderObjArg.directory = null;
 			folderObjArg.rootDirectory = '0';
 		}
     	FileListingWrapper wrapperObj = BoxContentProvider.createFolder(folderObjArg);
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
     	return responseWrapperObj;
    }
     
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=createEFSFolder createEFSFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName createEFSFolder
	 *
	 * @apiParam (Query Parameter) {String} action createEFSFolder
	 * @apiParam (Post Parameter) {Object} data  {directory, rootDirectory, name, permissions, siteId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.createEFSFolder
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result gDrive Folder record just created
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper createEFSFolder(Criteria.Folder folderObjArg) {
     	logger.logDebug('FileDataServer.createEFSFolder()----folderObjArg----'+folderObjArg + '--' + SiteContext.siteId);
     	logger.logDebug(readParam('provider'));
     	ResponseWrapper responseWrapperObj = null;
     	EFSFileService fs = new EFSFileService(SiteContext.fileStorageSource);
     	String storage = fs.getFileStorage();
     	try {
			FolderDao foldObj = new FolderDao();
			Folder__c siteFold = String.isBlank(folderObjArg.siteId) ? null : 
					foldObj.getEFSSiteFolder(folderObjArg.siteId, storage);
			
			if(siteFold != null) {
				if(storage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) && folderObjArg.directory.equalsIgnoreCase(siteFold.id)) {
					folderObjArg.directory = siteFold.Path__c;
				} 
			} else {
				if(storage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING) && folderObjArg.directory.equalsIgnoreCase('root')) {
					folderObjArg.directory = '';
				}
			}

     		FileListingWrapper wrapperObj = fs.createFolder(folderObjArg);
     		wrapperObj.permissions = folderObjArg.permissions.toLowerCase();
     		
     		if (storage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
     			wrapperObj.canDelete = true;
				wrapperObj.canRemove = true;
				//wrapperObj.canUnlink = true;
				wrapperObj.canChangeName = true;
     		}
     		 
     		if(siteFold != null) {
     			if(storage.equalsIgnoreCase(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING)) {
     				wrapperObj.canSetPermissions = false;
     				
     				// This below code can be uncommented when the dropbox supports shared folder inside another shared folder
     				/*
     				if(folderObjArg.siteId != null && folderObjArg.permissions != null && folderObjArg.permissions.equalsIgnoreCase('READWRITE')) {
     					fs.shareFolder(wrapperObj.fileUrl, '', '', siteFold.EFS_Read_Collaboration_Id__c);
     				} 
     				*/
     			}
     		}
     		
			fs.close();
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);     		
     	} catch (EFSException se) {
     		fs.close();
     		logger.logDebug(se.getError() + 'Message ' + se.getMessage());
     		
     		throw new SimpplrException('EFS Folder creation error!');
     	}

     	return responseWrapperObj;
    }
     
    @TestVisible 
    private ResponseWrapper getBoxLinkableFolders (Criteria.Folder folderObjArg) {
     	ResponseWrapper responseWrapperObj = null;
     	String folderId = String.isNotBlank(folderObjArg.directory) ? folderObjArg.directory : '0';
		List<BoxWrapper.MiniFolderFile> listOfBoxFolders = BoxContentProvider.getFolders(folderId);
		Map<String, Object> result = new Map<String, Object>();
		result.put('listOfItems', listOfBoxFolders);
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
     	return responseWrapperObj;
    }
     
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=getEFSLinkFolders getEFSLinkFolders
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getEFSLinkFolders
	 *
	 * @apiParam (Query Parameter) {String} action getEFSLinkFolders
	 * @apiParam (Post Parameter) {Object} data  {parentDirectory, currentDirectory, storage}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.GoogleDrive.getEFSLinkFolders
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FilterAttributeWrapper} Response.result All box folders within a box directory
	 * @apiUse FilterAttributeWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper getEFSLinkFolders (Criteria.Folder folderObjArg) {
     	ResponseWrapper responseWrapperObj = null;
     	EFSFileService fs = new EFSFileService(folderObjArg.storage);
     	String directory = String.isBlank(folderObjArg.directory) ? 'root' :folderObjArg.directory;
     	Criteria.File inputFile = new Criteria.File();
     	inputFile.size = 1000;
     	
     	List<FilterAttributeWrapper> listOfEFSLinkFolders = new List<FilterAttributeWrapper>();
     	for(FileListingWrapper fold: fs.listFiles(directory, inputFile)) {
     		if(fold.isDir && !fold.id.equalsIgnoreCase(folderObjArg.currentDirectory)) {
	     		FilterAttributeWrapper filterObj = new FilterAttributeWrapper();
	     		filterObj.id = fold.id;
	     		filterObj.name = fold.title;
	     		listOfEFSLinkFolders.add(filterObj);
     		}
     	}
     	
     	fs.close();
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfEFSLinkFolders);
     	return responseWrapperObj;
    }
     
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=linkFolder linkFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName linkFolder
	 *
	 * @apiParam (Query Parameter) {String} action linkFolder
	 * @apiParam (Post Parameter) {Object} data  {directory, name, permissions, siteId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Box.linkFolder
	 * 2. Used in SiteFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result Box Folder record just linked with a site
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper linkFolder (Criteria.Folder folderObjArg) {
     	ResponseWrapper responseWrapperObj = null;
     	FileListingWrapper wrapperObj = BoxContentProvider.linkFolder(folderObjArg);
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
     	return responseWrapperObj;
    }
    
    /**
	 * @apiDefine MySuccess
	 * @apiSuccess {String} status success
	*/
	
	/**
	 * @apiDefine RedirectSuccess
	 * @apiSuccess {String} status success
	 * @apiSuccess {String} url redirectUrl
	*/
	
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=unlinkFolder unlinkFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName unlinkFolder
	 *
	 * @apiParam (Query Parameter) {String} action unlinkFolder
	 * @apiParam (Post Parameter) {Object} data  {folderId, provider}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Box.unlinkFolder
	 * 2. Used in SiteFiles
	 * 
	 * @apiUse MySuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper unlinkFolder (Map<String, String> requestDataMap) {
     	ResponseWrapper responseWrapperObj = null;
     	String externalFolderId = requestDataMap.get('folderId');
     	String siteId = readParam('siteId');
     	new BoxService().unlinkAndDeleteFolderInDB(siteId, externalFolderId);
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
     	return responseWrapperObj;
    }
    
    @TestVisible 
    private ResponseWrapper setFileDescription (Map<String, String> requestDataMap) {
     	ResponseWrapper responseWrapperObj = null;
     	String provider = requestDataMap.get('provider');
     	String description = String.isNotBlank(requestDataMap.get('description')) ? requestDataMap.get('description') :'';
     	String languageId = String.isNotBlank(requestDataMap.get('languageId')) ? requestDataMap.get('languageId') :'';
     	String title = String.isNotBlank(requestDataMap.get('title')) ? requestDataMap.get('title') :'';
     	String fileId = String.isNotBlank(requestDataMap.get('fileId')) ? requestDataMap.get('fileId') :'';
		 if (PROVIDER_BOX.equalsIgnoreCase(provider)) {
     		BoxDao boxDaoObj = new BoxDao();
     		boxDaoObj.setFileDescription(requestDataMap.get('fileId'), description);  
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, description.replace('\n','<br>'));   	
     	} else if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(provider)) {
			return buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		
		} else if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)){
			File__c fileObj = fileDao.getFileRecordDetails(fileId);
			String entryId = fileObj.External_Id__c; 
			fileObj.description__c = description ;
			fileObj.title__c = title ; 
			String captionLanguageId = languageId;
			if(languageId.equalsIgnoreCase(fileObj.Video_Caption_Language__c)){
				//captions language not changed
				languageId = '';
			}else{
				fileObj.Video_Caption_Language__c = languageId;
			}
			Map<String, String> vedioAndCaptionUpdateState = null;
			if(String.isNotBlank(entryId)){		
				VideoDao.updateVideo(title ,entryId, description, languageId);

				if(String.isNotBlank(languageId)){
					fileObj.Video_Caption_Status__c = 1;
				}
			}
			update fileObj;
			Map<String, String> resultMap = new Map<String, String>();
			resultMap.put('description', description.replace('\n','<br>'));
			resultMap.put('title', title);
			resultMap.put('languageId', captionLanguageId);	
			resultMap.put('videoCaptionStatus', String.valueOf(fileObj.Video_Caption_Status__c));
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultMap);
			
		} else {
			FileDao fileDaoObj = new FileDao();
			fileDaoObj.setDescription(requestDataMap.get('fileId'), description);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, description.replace('\n','<br>'));
		}
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=setFolderName setFolderName
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName setFolderName
	 *
	 * @apiParam (Query Parameter) {String} action setFolderName
	 * @apiParam (Post Parameter) {Object} data  {folderId, provider, name}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.setFolderName
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiUse MySuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper setFolderName (Map<String, String> requestDataMap) {
     	logger.logDebug('FileDataServer.setFolderName()----requestDataMap----'+requestDataMap);
     	ResponseWrapper responseWrapperObj = null;
     	String folderId = requestDataMap.get('folderId');
     	String provider = requestDataMap.get('provider');
     	String name = requestDataMap.get('name');
     	FolderDao folderDaoObj = new FolderDao();
     	
     	if( ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(provider) ){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', folderId);
			soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
			
			String folderQuery = 'SELECT Id, Parent_Folder__c, Type__c, Parent_Folder__r.Name__c, Drive_Type__c, External_Folder_Id__c, Site__c FROM Folder__c WHERE External_Folder_Id__c=:soqlParam1 AND Type__c =:soqlParam2 AND Is_Deleted__c = false';

			String siteId = requestDataMap.containsKey('siteId') ? (String)requestDataMap.get('siteId') : null;
			if(String.isNotBlank(siteId)){
				soqlParamMap.put('soqlParam3', siteId);
				folderQuery += ' AND Site__c=:soqlParam3';
			}

			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
			
			if (listOfFolders != null && !listOfFolders.isEmpty()) {
				for (Folder__c folderObj : listOfFolders){
					folderObj.name__c = name;
				}
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
				SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(listOfFolders), new List<Schema.SObjectField>{
					Folder__c.Name__c
				});
			} else {
				//If no folder found in Simpplr, throw error 
				throw new  SimpplrException('Not able to rename');
			}
		}else if( ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(provider) ){
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			String siteId = requestDataMap.containsKey('siteId') ? (String)requestDataMap.get('siteId') : null;
			soqlParamMap.put('soqlParam1', folderId);
			soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
			soqlParamMap.put('soqlParam3', siteId);
			String folderQuery = 'select id, Parent_Folder__c, type__c,name__c, Parent_Folder__r.name__c, Drive_Type__c, External_Folder_Id__c, Site__c, SP_Instance_Id__c from Folder__c where External_Folder_Id__c=:soqlParam1 and Site__c=:soqlParam3 and Is_Deleted__c = false and type__c =:soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
			if (!listOfFolders.isEmpty()) {

				for (Folder__c folderObj : listOfFolders){
					folderObj.name__c = name;
				}
				if(!SimpplrContext.isSharepointUpgraded || ( listOfFolders[0].SP_Instance_Id__c!= null && UserContext.spInstanceId != null && listOfFolders[0].SP_Instance_Id__c.equalsIgnoreCase(UserContext.spInstanceId))){
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
					SIMPESAPI.accessController().updateAsUser(new Map<Id,Folder__c>(listOfFolders), new List<Schema.SObjectField>{
						Folder__c.Name__c
					});
				}else{
					throw new  SimpplrException('Not able to rename');
				}	
			} else {
				//If no folder found in Simpplr, throw error 
				throw new  SimpplrException('Not able to rename');
			}
		} else if (PROVIDER_BOX.equalsIgnoreCase(provider)) {
     		new BoxDao().setFolderName(folderId, name);
     		folderDaoObj.setExternalFolderName(folderId, name, PROVIDER_BOX);     	
     	} else if(EFSConstants.storageTypes.contains(provider)) {
     		EFSFileService EFS = new EFSFileService(provider);
     		if( ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(provider)) {
     			EFS.updateItemName(requestDataMap.get('rootDirectory'), folderId, name);
     		} else {
     			EFS.updateFileName(folderId, name);
     		}
     		EFS.updateFileName(folderId, name);
     		EFS.close();
     		
     		// Since we have no RW folder in Dropbox
     		if(!ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(provider)) {
     			folderDaoObj.setExternalFolderName(folderId, name, provider);
     		}
     	} else {
	     	folderDaoObj.setFolderName(folderId, name);
     	}
     	
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, requestDataMap);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=setFolderPermissions setFolderPermissions
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName setFolderPermissions
	 *
	 * @apiParam (Query Parameter) {String} action setFolderPermissions
	 * @apiParam (Post Parameter) {Object} data  {folderId, provider, permissions, siteId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.setFolderPermissions
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result The folder object for whic permissions have been updated
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper setFolderPermissions (Map<String, String> requestDataMap) {
     	ResponseWrapper responseWrapperObj = null;
     	FileListingWrapper wrapperObj = null;
     	
     	String folderId = requestDataMap.get('folderId');
     	String provider = requestDataMap.get('provider');
     	String permissions = requestDataMap.get('permissions');
     	String name = requestDataMap.get('name');
     	FolderDao folderDaoObj = new FolderDao();
     	
     	if (PROVIDER_BOX.equalsIgnoreCase(provider)) {
     		Boolean success = BoxContentProvider.setFolderPermissions(folderId, permissions);
     		
     		if (success == true) {
     			folderDaoObj.setExternalFolderPermissions(SiteContext.siteId, folderId, permissions, PROVIDER_BOX);
     		}
     		
     	} else if (ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(provider) || 'Dropbox Files'.equalsIgnoreCase(name)) {
     		////////////////////////////////////////////////////////////////////////////////////////////////////
     		// The below code can be uncommented when Dropbox supports sharing folder inside a shared folder. //
     		////////////////////////////////////////////////////////////////////////////////////////////////////

/*     		try {
     			EFSFileService fs = new EFSFileService();
     			Folder__c siteFold = folderDaoObj.getEFSSiteFolder(SiteContext.siteId, provider);
     			
     			if('read'.equalsIgnoreCase(permissions)) {
     				fs.unshareFolder(folderId, siteFold.EFS_Read_Collaboration_Id__c);
     			} else {
     				fs.shareFolder(folderId, '', '', siteFold.EFS_Read_Collaboration_Id__c);
     			}
     		} catch(EFSException reqEx) {
		     	logger.logDebug(reqEx.getMessage());
     		} */
     		
     		////////////////////////////////////////////////////////////////////////////////////////////////////
     		// For Dropbox we are setting the storage at site root folder level.                              //
     		////////////////////////////////////////////////////////////////////////////////////////////////////

     		try {
     			EFSFileService fs = new EFSFileService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
     			Folder__c siteFold = folderDaoObj.getEFSSiteFolder(SiteContext.siteId, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
     			Boolean success = fs.changeFolderSharing(siteFold.EFS_Shared_Folder_Id__c, siteFold.EFS_Read_Collaboration_Id__c, permissions);
     			
		 		if (success == true) {
		 			folderDaoObj.setExternalFolderPermissions(SiteContext.siteId, siteFold.External_Folder_Id__c, permissions, ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
		 		}
     		} catch(EFSException reqEx) {
		     	logger.logDebug(reqEx.getMessage());
     		}
     	} else {
	     	wrapperObj = folderDaoObj.setFolderPermissions(folderId, permissions);
     	}
     	
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=delete deleteFile
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName deleteFile
	 *
	 * @apiParam (Query Parameter) {String} action delete
	 * @apiParam (Post Parameter) {Object} data  {fileId, provider, siteId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.delete
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiUse RedirectSuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper deleteFile (Criteria.FileDeleteParams deleteFileCriteriaObj) {
		ResponseWrapper responseWrapperObj = null;
     	List<String> fileId = deleteFileCriteriaObj.fileId;
     	String provider = deleteFileCriteriaObj.provider;
     	String driveId = deleteFileCriteriaObj.rootDirectory;
     	if(String.isBlank(driveId)){
     		driveId = readParam('rootDirectory'); 
     	}
     	String siteId = '';
     	
     	if('Box'.equalsIgnoreCase(provider)) {
     		BoxContentProvider.deleteFile(fileId[0], null);
     	} else if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(provider)) {
			ResponseWrapper gResponseObj = new GoogleDriveService().deleteFile(fileId[0]);
			logger.logDebug('gResponseObj'+ gResponseObj.result);
		
			if (gResponseObj == null) {
				throw new  SimpplrException('Not able to delete file');
			}

		} else if(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(provider) || ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(provider)) {
     		EFSFileService fs = new EFSFileService(provider);
     		fs.deleteFile(fileId[0]);
     		fs.close();
     	} else if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(provider) || ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(provider)) {
     		EFSFileService fs = new EFSFileService(provider);
     		fs.deleteItem(driveId,fileId[0]);
     		fs.close();
     	} else {
     		FileDao fileDaoObj = new FileDao();
     		fileDaoObj.deleteFile(fileId);
			fileDaoObj.markAlbumContentAsDeleted(null, fileId, true);
     	}
     	if(ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(provider) || ServiceConstants.STORAGE_TYPE_BOX_STRING.equalsIgnoreCase(provider)) {
     		FileDao fileDaoObj = new FileDao();
     		fileDaoObj.deleteExternalFile(fileId[0]);
     	}
     	
     	Map<Object,Object> result = New Map<Object,Object>();
        String redirectURL = '';
       
        if (String.isBlank(siteId)) {
        	redirectURL = PageContext.getPageURL(Pages.MyFiles);
        } else {
        	redirectURL = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files';
        }
        
        result.put('url', redirectURL);
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=remove removeFile
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName removeFile
	 *
	 * @apiParam (Query Parameter) {String} action remove
	 * @apiParam (Post Parameter) {Object} data  {fileId, provider, siteId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.remove
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiUse RedirectSuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper removeFile (Criteria.FileDeleteParams removeFileCriteriaObj) {
     	ResponseWrapper responseWrapperObj = null;
     	List<String> fileId = removeFileCriteriaObj.fileId;
     	String provider = removeFileCriteriaObj.provider;
     	String siteId = '';
     	
     	if (String.isNotBlank(removeFileCriteriaObj.fileSiteId)) {
    		siteId = removeFileCriteriaObj.fileSiteId;
      	} else {
      		throw new SimpplrException(ExceptionCode.INVALID_SITE_ID.name());
      	}
      	
     	FileDao fileDaoObj = new FileDao();
	    fileDaoObj.removeFileFromSite(siteId, fileId);
     	
     	if((SiteContext.isCurrentUserSiteManager && SiteContext.isPrivateSite) ||
			 		(SiteContext.isPublicSite && (SiteContext.isCurrentUserSiteManager || UserContext.isUserAppModerator))){
			fileDaoObj.markAlbumContentAsDeleted(siteId, fileId, false);
		}
     	
     	Map<Object,Object> result = New Map<Object,Object>();
        String redirectURL = PageContext.getPageURL(Pages.app) +'?u=/site/' + siteId + '/files';
        
        result.put('url', redirectURL);
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=deleteFolder deleteFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName deleteFolder
	 *
	 * @apiParam (Query Parameter) {String} action deleteFolder
	 * @apiParam (Post Parameter) {Object} data  {folderId, provider}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.deleteFolder
	 * 2. Used in SiteFiles and MyFiles
	 * 3. Updated for Box, Google Drive and DropBox
	 *
	 * @apiUse MySuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper deleteFolder (Criteria.FolderDeleteParams deleteFolderParamsObj) {
     	logger.logDebug('FileDataServer.deleteFolder()----deleteFolderParamsObj----'+deleteFolderParamsObj);
     	ResponseWrapper responseWrapperObj = null;
   		String folderId = deleteFolderParamsObj.folderId[0];
     	String provider = deleteFolderParamsObj.provider;
     	String rootDirectory = deleteFolderParamsObj.rootDirectory;
     	FolderDao fileDaoObj = new FolderDao();
     	
     	if ('Box'.equalsIgnoreCase(provider)) {
     		BoxContentProvider.deleteFolder(folderId);
     	} else if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(provider)) {
			ResponseWrapper gResponseObj = new GoogleDriveService().deleteFile(folderId);
			logger.logDebug('gResponseObj'+ gResponseObj.result);
		
			if (gResponseObj == null) {
				throw new  SimpplrException('Not able to delete folder');
			}

		} else if(EFSConstants.storageTypes.contains(provider)) {
     		EFSFileService fs = new EFSFileService(provider);
     		if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(provider) || ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(provider)) {
     			fs.deleteItem(deleteFolderParamsObj.rootDirectory, folderId);
     		} else {
	     		fs.deleteFile(folderId);
     		}
     		fs.close();
     		
     		for(Folder__c fold: fileDaoObj.getEFSFolders(deleteFolderParamsObj.siteId, folderId, provider, null)) {
     			fileDaoObj.deleteEFSFolderRecord(fold.Id);    			
     		}    
     	} else {
	     	fileDaoObj.deleteFolder(folderId);
     	}
     	
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=getVersionHistory getVersionHistory
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getVersionHistory
	 *
	 * @apiParam (Query Parameter) {String} action getVersionHistory
	 * @apiParam (Post Parameter) {Object} data  {fileId, provider}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.getVersionHistory
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FileVersionHistoryWrapper} Response.result The version history of the specified file
	 * @apiUse FileVersionHistoryWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper getVersionHistory (Map<String, String> requestDataMap) {
     	ResponseWrapper responseWrapperObj = null;
     	String provider = requestDataMap.get('provider');
     	List<FileVersionHistoryWrapper> listOfFileVersions;
     	
     	if ('Box'.equalsIgnoreCase(provider)) { 
     		listOfFileVersions = BoxContentProvider.getVersionHistory(requestDataMap.get('fileId'));
     	
     	} else if (ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(provider)) {
			listOfFileVersions = new GoogleDriveService().getversionhistory(requestDataMap.get('fileId'));

		} else if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(provider)) { 
     		EFSFileService fs = new EFSFileService(provider);
     		listOfFileVersions = fs.getFileVersions(requestDataMap.get('fileId'));
     	
     	} else if ((ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).equalsIgnoreCase(provider) || 
     			(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING).equalsIgnoreCase(provider)) {
     		EFSFileService fileServiceObj = new EFSFileService(provider);
     		listOfFileVersions = fileServiceObj.getFileVersions(requestDataMap.get('driveId'),
     				requestDataMap.get('fileId'));
     		
     	} else {
	     	FileDao fileDaoObj = new FileDao();
     		listOfFileVersions = FileContentProvider.getVersionHistory(requestDataMap.get('fileId'));
     	}
     	
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, listOfFileVersions);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=getDownloadUrl getDownloadUrl
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getDownloadUrl
	 *
	 * @apiParam (Query Parameter) {String} action getDownloadUrl
	 * @apiParam (Post Parameter) {Object} data  {fileObj, versionId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Box.getDownloadUrl
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FileVersionHistoryWrapper} Response.result The downloadUrl of the specified file
	 * @apiUse FileVersionHistoryWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper getDownloadUrl (Map<String, String> requestDataMap) {
     	ResponseWrapper responseWrapperObj = null;
     	String fileDownloadUrl;
     	if (UserContext.isBoxConnected) {
	     	fileDownloadUrl = new BoxDao().getFileDownloadURL(requestDataMap.get('fileId'), requestDataMap.get('versionId'));
     	} else {
     		throw new SimpplrException(BoxConstants.BOX_NOT_CONNECTED_DOWNLOAD_ERROR);
     	}
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, new Map<String, String>{'url'=> fileDownloadUrl});
     	return responseWrapperObj;
	}
	
	@TestVisible 
    private ResponseWrapper getSharePointVersionDownloadUrl (Map<String, String> requestDataMap) {
     	ResponseWrapper responseWrapperObj = null;	
		EFSFileService fs = new EFSFileService(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
		String fileDownloadUrl = fs.getDownloadURL(requestDataMap.get('driveId'), requestDataMap.get('fileId'), requestDataMap.get('versionId'));
     	
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null,
     						 new Map<String, String>{'url'=> fileDownloadUrl});
     	return responseWrapperObj;
    }
     
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=getAccessToken getAccessToken
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getAccessToken
	 *
	 * @apiParam (Query Parameter) {String} action getAccessToken
	 * @apiParam (Post Parameter) {Object} data  {fileObj, versionId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Box.getAccessToken and from Simpplr.Salesforce.File.uploadNewVersion
	 * 2. Used in SiteFiles and MyFiles
	 * 3. Only Specific to Box Integration
	 * @apiUse MySuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper getAccessToken () {
     	BoxWrapper.UserTokens currentUserTokens= new BoxDao().getUserTokens(true, UserContext.peopleId);
     	ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, currentUserTokens.accessToken);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=resetAccessToken resetCurrentUserBoxAccessToken
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName resetCurrentUserBoxAccessToken
	 *
	 * @apiParam (Query Parameter) {String} action resetAccessToken
	 * @apiParam (Post Parameter) {Object} data  {}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Box.resetAccessToken and from Simpplr.Salesforce.File.resetCurrentUserBoxAccessToken
	 * 2. Used on MySettingsExternalApps and ManageApplicationIntegrations page
	 * 
	 * @apiUse MySuccess 
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper resetCurrentUserBoxAccessToken () {
     	BoxContentProvider.resetCurrentUserBoxAccessToken();
     	ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=getEFSAccessToken getEFSAccessToken
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getEFSAccessToken
	 *
	 * @apiParam (Query Parameter) {String} action getEFSAccessToken
	 * @apiParam (Post Parameter) {Object} data  {fileObj, versionId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.GoogleDrive.getEFSAccessToken and from Simpplr.Salesforce.File.uploadNewVersion
	 * 2. Used in SiteFiles and MyFiles
	 * 3. Specific to Google and Dropbox
	 * @apiUse MySuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper getEFSAccessToken(String fileStorage) {
     	logger.logDebug('FileDataServer.getEFSAccessToken()');
     	EFSAccessService access = new EFSAccessService(fileStorage, false);
     	if(access.isAccessExpired()) {
     		access.refreshToken();
     	}
     	access.close();
     	ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, access.getAccessToken());
     	return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper getGoogleDriveAccessToken() {
     	logger.logDebug('FileDataServer.getGoogleDriveAccessToken()');
        GoogleDriveService serviceObj = new GoogleDriveService();
        String accessToken = serviceObj.getAccessToken();
     	ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, accessToken);
     	return responseWrapperObj;
    }
    
    @TestVisible 
    private ResponseWrapper getDropboxAccessToken() {
    	EFSFileService fs = new EFSFileService(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING);
     	String encryptedAccessToken = Utility.droboxFileMgmtAuthToken();
     	ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, encryptedAccessToken);
     	fs.close();
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=resetEFSAccessToken resetEFSAccessToken
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName resetEFSAccessToken
	 *
	 * @apiParam (Query Parameter) {String} action resetEFSAccessToken
	 * @apiParam (Post Parameter) {Object} data  {}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.GoogleDrive.resetAccessToken and from Simpplr.Salesforce.File.uploadNewVersion
	 * 2. Used on MySettingsExternalApps and ManageApplicationIntegrations page
	 * 3. Specific to Google and Dropbox
	 * @apiUse MySuccess 
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper resetEFSAccessToken(String fileStorage) {
     	logger.logDebug('FileDataServer.resetEFSAccessToken()');
     	EFSAccessService access = new EFSAccessService(fileStorage, false);
     	access.refreshToken();
     	access.close();
     	ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=getPublicUrl getPublicUrl
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getPublicUrl
	 *
	 * @apiParam (Query Parameter) {String} action getPublicUrl
	 * @apiParam (Post Parameter) {Object} data  {fileId, provider}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.getPublicUrl
	 * 2. Used in SiteFiles and MyFiles
	 *
	 * @apiUse MySuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper getPublicUrl (Map<String, String> requestDataMap) {
     	String publicURL = FileContentProvider.getPublicUrl(requestDataMap.get('fileId'));
     	ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, publicURL);
     	return responseWrapperObj;
    }
     
    @TestVisible 
    private ResponseWrapper autoComplete (Criteria.File fileCriteriaObj) {
     	ResponseWrapper responseWrapperObj = null;
     	List<FileListingWrapper> listOfFileWrapper = new List<FileListingWrapper>();
     	
     	if (PROVIDER_INTRANET.equalsIgnoreCase(fileCriteriaObj.provider)) {
     		listOfFileWrapper = FileContentProvider.autoComplete(fileCriteriaObj);
     		
     	} else if (PROVIDER_BOX.equalsIgnoreCase(fileCriteriaObj.provider)) {
     		listOfFileWrapper = BoxContentProvider.autoComplete(fileCriteriaObj);
     	
     	} else if (ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider)
     			|| ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(fileCriteriaObj.provider)
     			|| ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(fileCriteriaObj.provider)
     			|| ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileCriteriaObj.provider)) {
     		EFSFileService fs = new EFSFileService(fileCriteriaObj.provider);
     		listOfFileWrapper = fs.searchFiles(String.isBlank(fileCriteriaObj.siteId)?'AppFiles':'SiteFiles' , fileCriteriaObj);
     	} 
     	
     	responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, new Map<String, object>{'listOfFile'=> listOfFileWrapper});
     	return responseWrapperObj;
    }
     
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=moveFiles moveFiles
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName moveFiles
	 *
	 * @apiParam (Query Parameter) {String} action moveFiles
	 * @apiParam (Post Parameter) {Object} data  {siteId, fileobjArray, sourceFolderId, destinationFolderId, fileProvider}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.moveFiles
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiUse MySuccess
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
	@TestVisible
    private ResponseWrapper moveFiles (Criteria.FileMove fileMoveArg) {
     	logger.logDebug('FileDataServer.moveFiles()----fileMoveArg----'+fileMoveArg);
     	ResponseWrapper responseWrapperObj = null;
     	String siteId = fileMoveArg.siteId;
     	List<Criteria.File> fileList = fileMoveArg.fileArray;
     	String source = fileMoveArg.source;
     	String destination = fileMoveArg.destination;
     	String provider = fileMoveArg.provider;
     	List<String> fileIdList = new List<String>();
     	
     	for (Criteria.File fileObj : fileList) {
     		fileIdList.add(fileObj.fileId);
     	}
     	
     	if((!EFSConstants.storageTypes.contains(provider) && String.isBlank(siteId)) 
     				|| fileList.size() == 0 || String.isBlank(destination)){
     		throw new SimpplrException(ExceptionCode.MISSING_ACTION_PARAM.name());
     	}
     	
     	if ('Box'.equalsIgnoreCase(provider)) {
     		BoxWrapper.MiniFolderFile folderFileObj = moveBoxFile(fileList[0].fileId, source, destination);     		
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, folderFileObj);
			 
     	} else if(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(provider)) {
			if(!source.equalsIgnoreCase(destination)) {
	     		new GoogleDriveService().moveFile(fileList[0].fileId, destination, new List<String>{source});
			 }
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);			 
     		
     	} else if(ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(provider)) {
     		if(!source.equalsIgnoreCase(destination)){
	     		EFSFileService fs = new EFSFileService(provider);
				fs.updateFileName(fileList[0].fileId, destination + '/' + fileList[0].name);
	     		fs.close();
     		}
     		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
     	} else if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(provider) ||
     			  ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(provider)) {
     		if(!source.equalsIgnoreCase(destination)){
	     		EFSFileService fs = new EFSFileService(provider);
				fs.moveItem(fileMoveArg.sourceRoot, fileList[0].fileId, fileList[0].name, fileMoveArg.destinationRoot, fileMoveArg.destination);
	     		fs.close();
     		}
     		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} else if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)) {
			new FileDao().moveVideoFiles(siteId, fileIdList, destination, source); 
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
		} else {
     		List<File__c> movedFilesList = moveOtherFiles(siteId, fileIdList, destination, source);
     		
     		if(!movedFilesList.isEmpty()){
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, ('Moved ' + movedFilesList.size() + ' file(s) successfully'), movedFilesList);
	     	} else {
	     		throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
	     	}
     	}      	
     	
     	return responseWrapperObj;
    }
    
	@TestVisible
    private BoxWrapper.MiniFolderFile moveBoxFile (String fileId, String sourceFolderId, 
     		String destinationFolderId) {
     	BoxWrapper.MiniFolderFile folderFileObj = (new BoxDao()).moveBoxFiles(fileId, 
     			sourceFolderId, destinationFolderId);
     	
     	return folderFileObj;
    }
     
    private List<File__c> moveOtherFiles (String siteId, List<String> fileList, 
    	String destination, String source) {
     	Boolean isMoveAllowed = false;
     	List<File__c> movedFilesList = null;
     	String loggedInUserId = UserContext.userId;
     	Map<String, Object> soqlParamMap = new Map<String, Object>();
     	soqlParamMap.put('soqlParam1', siteId);
     	soqlParamMap.put('soqlParam2', destination);
     	soqlParamMap.put('soqlParam3', source);
     	String folderQuery = 'SELECT Id, permissions__c, Is_System_Folder__c, Name__c FROM Folder__c WHERE Site__c =:soqlParam1 AND Id IN (:soqlParam2, :soqlParam3)';
     	SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
     	Map<Id, Folder__c> folderMap = new Map<Id, Folder__c>(
			(List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap));
    	List<String> filteredCdIdList = new List<String>();
    	String queryStr = 'SELECT id FROM ContentDocument WHERE Id IN :fileList AND OwnerId = :loggedInUserId';

    	if(SimpplrContext.isCommunitiesEnabled){
    		queryStr += ' AND LatestPublishedVersion.networkid = null';
    	}
    	Map<Id, ContentDocument> loggedInUserOwnedCdMap = new Map<Id, ContentDocument>((List<ContentDocument>) Database.query(queryStr));
    	Set<String> loggedInUserOwnedCdIdSet = (Set<String>)JSON.deserialize(JSON.serialize(
    			loggedInUserOwnedCdMap.keySet()), Set<String>.class);

    	if (folderMap.IsEmpty()) {
    		throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
    	
    	} else {
    		Folder__c sourceFolderObj = folderMap.get(source);
    		Folder__c destinationFolderObj = folderMap.get(destination);
    		
    		if(sourceFolderObj != null && sourceFolderObj.Is_System_Folder__c){
    			// can not move files from a System Folder
    			throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
    		}
    		
    		if (destinationFolderObj != null &&
					destinationFolderObj.Is_System_Folder__c && 
					(ServiceConstants.DEFAULT_SITE_SYSTEM_FOLDERS_MAP.get('CONTENT_IMAGES')).equalsIgnoreCase(destinationFolderObj.Name__c)){
				
				if (SiteContext.isCurrentUserSiteManager || UserContext.isUserAppModerator) {
					filteredCdIdList.addAll(fileList);			
				
				} else {
					// can not move files to a System Folder except a Content Images Folder and this move is allowed to only managers.
    				throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
				}
    		}
    		
    		if (String.isBlank(destination) && String.isNotBlank(source)) {
    			// Moving from a folder to Root is not allowed.
    			throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
    		
    		} else if (String.isNotBlank(destination) && String.isBlank(source)) {
    			// Moving from Root to a folder.
    			
    			if (destinationFolderObj != null) {
    				// Destination folder either shouldn't be the system folder here
    				
    				if (!destinationFolderObj.Is_System_Folder__c) {
    					
    					if (SiteContext.isCurrentUserSiteManager || UserContext.isUserAppModerator) {
    						filteredCdIdList.addAll(fileList);
    					
    					} else if ('ReadWrite'.equalsIgnoreCase(destinationFolderObj.permissions__c)) {
    						// Check if the logged in user is not a manager then the folder should have 'readwrite' permisions and
    						// the logged in user should be the owner of the files to be moved.
    						
    						if (!loggedInUserOwnedCdMap.isEmpty()) {
    							filteredCdIdList.addAll(new List<String>(loggedInUserOwnedCdIdSet));
    						}
    						
    					}
    					
    				}
    				
    			}
    			
    		} else if (String.isNotBlank(destination) && String.isNotBlank(source)) {
    			// Moving between Folders.
    			
    			if (!destinationFolderObj.Is_System_Folder__c && !sourceFolderObj.Is_System_Folder__c) {
    				
    				if (SiteContext.isCurrentUserSiteManager || UserContext.isUserAppModerator) {
    						filteredCdIdList.addAll(fileList);
					
					} else if ('ReadWrite'.equalsIgnoreCase(destinationFolderObj.permissions__c) &&
    						  	'ReadWrite'.equalsIgnoreCase(sourceFolderObj.permissions__c)) {
							
						if (!loggedInUserOwnedCdMap.isEmpty()) {
							filteredCdIdList.addAll(new List<String>(loggedInUserOwnedCdIdSet));
						}
						
					}
					
    			}
    			
    		}
    		
    	}
    
    	if (!filteredCdIdList.isEmpty()) {
			FileDao fileDaoObj = new FileDao();
	     	movedFilesList = fileDaoObj.moveFiles(siteId, filteredCdIdList, destination, source);
	    
	    } else {
     		throw new SimpplrException(ExceptionCode.INVALID_REQUEST_DATA.name());
     	}
     	
     	return movedFilesList;
    }
    
    @TestVisible 
    private ResponseWrapper getSiteDropboxFiles(Criteria.File fileCriteriaObjArg) {
    	ResponseWrapper responseWrapperObj = null;
    	
    	if(!UserContext.isDropboxConnected) {
    		throw new SimpplrException(STR_KEY_ERROR_DROPBOX_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
    	}
    	
    	List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
     	FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper();
     	EFSFileService fs = new EFSFileService(fileCriteriaObjArg.provider);
     	try {
	     	// Access for File Storage
     		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter);
		 	Boolean isUserSiteOwnerOrManager = (UserContext.sitesIManageMap.get(SiteContext.siteId) != null) ;

	     	if (String.isNotBlank(fileCriteriaObjArg.term)) {
				Map<String, Object> searchResponse = fs.searchFilesDropbox('SiteFiles', fileCriteriaObjArg);
				listOfFileWrapper = (List<FileListingWrapper>) searchResponse.get('listOfFiles');

	     	} else {
	     		FolderDao daoObj = new FolderDao();
				Folder__c siteFold = daoObj.getEFSSiteFolder(SiteContext.siteId, fileCriteriaObjArg.provider);
				if(siteFold == null){
					filePaginatorObj.canCreateFolder = false;
			    	return buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
				} else if(String.isNotBlank(fileCriteriaObjArg.directory) && fileCriteriaObjArg.directory.equalsIgnoreCase(siteFold.id)) {
					fileCriteriaObjArg.directory = siteFold.Path__c;
				} else if((String.isNotBlank(fileCriteriaObjArg.currentDirectory) || String.isNotBlank(fileCriteriaObjArg.siteId)) && String.isBlank(fileCriteriaObjArg.directory)) {
					// this condition check is for move files 
					fileCriteriaObjArg.directory = siteFold.Path__c;
				}
				
	 			filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
		     	// For Dropbox no file link/unlink
		     	filePaginatorObj.directory.canLinkFolder = false;
	 			filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_DROPBOX_STRING;

				Boolean rwFolderFlag = 'readwrite'.equalsIgnoreCase(siteFold.Permissions__c) 
						&& UserContext.sitesIFollowIdSet.contains(fileCriteriaObjArg.siteId);
				
				if(isUserSiteOwnerOrManager || (UserContext.sitesIFollowIdSet.contains(fileCriteriaObjArg.siteId) 
						&& rwFolderFlag)) {
		 			filePaginatorObj.canUpload = true;
					filePaginatorObj.directory.canCreateFolder = true;
				}
				
	     		if (String.isNotBlank(fileCriteriaObjArg.directory) || isWriteFolderFilter) { 
 					fileCriteriaObjArg.parentDirectory = siteFold.Path__c;
		 			listOfFileWrapper = fs.listFiles(fileCriteriaObjArg.directory, fileCriteriaObjArg);	

		 			for(FileListingWrapper filWrapper: listOfFileWrapper) {
		 				if(filWrapper.isDir) {
				    		if(rwFolderFlag || UserContext.peopleId.equalsIgnoreCase(filWrapper.owner.Id) || isUserSiteOwnerOrManager) {
				    			filWrapper.canChangeName = true;
				    		} else {
				    			filWrapper.canChangeName = false;
				    		}
				    		
				    		if(UserContext.Id.equalsIgnoreCase(filWrapper.owner.Id)){
				    			filePaginatorObj.canUpload = true;
				    			filWrapper.canDelete = true;
				    		}
				    		
		 					filWrapper.canSetPermissions = false;
		 					
		 					if (String.isNotBlank(siteFold.permissions__c)) {
		 						filWrapper.permissions = siteFold.permissions__c.toLowerCase();
		 					}
		 				}
		 			}
		     	}
		     	
				// Handling of the Parent
				
				// Handling for the Site Root Folder
				if(String.isNotBlank(fileCriteriaObjArg.directory) && fileCriteriaObjArg.directory.equalsIgnoreCase(siteFold.Path__c)) {
					fileCriteriaObjArg.directory = siteFold.Path__c;

	 				filePaginatorObj.directory.id = siteFold.id;
	 				filePaginatorObj.directory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.dropbox_files');
		 			filePaginatorObj.directory.isSystemDir = true;
		 			filePaginatorObj.directory.permissions = siteFold.permissions__c.toLowerCase();
				} else {
	 				String parentPath = String.isNotBlank(fileCriteriaObjArg.directory)?fileCriteriaObjArg.directory.substringBeforeLast('/').toLowerCase():'';
	 				
	 				// Dropbox Files is kind of Mandatory
 					FileListingWrapper.ParentWrapper parentWrap = new FileListingWrapper.ParentWrapper();
					parentWrap.id = siteFold.Path__c;
					parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.dropbox_files');
					filePaginatorObj.listOfParents.add(parentWrap);
		
					String remainingParents = parentPath.substringAfter(siteFold.Path__c.toLowerCase());
					if(String.isNotBlank(remainingParents)) {
						String consolidatedPath = siteFold.Path__c;
						for(String foldName: remainingParents.split('/')) {
							if(String.isNotBlank(foldName)) {
								consolidatedPath += '/' + foldName;
								FileListingWrapper.ParentWrapper rParentWrap = new FileListingWrapper.ParentWrapper();
								rParentWrap.id = consolidatedPath;
								rParentWrap.name = foldName;
								filePaginatorObj.listOfParents.add(rParentWrap);
							}
						}
					}

					// Directory info
					filePaginatorObj.directory.id = fileCriteriaObjArg.directory;
	 				
					if(String.isNotBlank(fileCriteriaObjArg.directory)){
						filePaginatorObj.directory.name = fileCriteriaObjArg.directory.substringAfterLast('/');
					}
					filePaginatorObj.directory.permissions = siteFold.permissions__c.toLowerCase();
					filePaginatorObj.directory.isSystemDir = false;
			   }
		   }
	    	fs.close();
     	} catch (EFSException se) {
     		logger.logDebug(se.getMessage());
     	}
     	
     	filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
     	
     	if (String.isNotBlank(fs.nextPageToken) && filePaginatorObj.listOfItems.size() == fileCriteriaObjArg.size) {
	        filePaginatorObj.nextPageToken = fs.nextPageToken;
	    } else {
	        filePaginatorObj.nextPageToken = null;
	    }
	    
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
        return responseWrapperObj;
	}
	
	private ResponseWrapper searchAllFilesSharePoint(Criteria.File fileCriteriaObjArg) {
		logger.logDebug('FileDataServer.searchAllFilesSharePoint()----fileCriteriaObjArg----'+fileCriteriaObjArg);
		ResponseWrapper responseWrapperObj = null;
		if (UserContext.Integrations == null ||
    	    !UserContext.Integrations.containsKey(fileCriteriaObjArg.provider) || 
    		!UserContext.Integrations.get(fileCriteriaObjArg.provider).Connected__c) {
			throw new SimpplrException(STR_KEY_ERROR_ONEDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
		}
		try {
			FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper();
			EFSFileService gfs = new EFSFileService(fileCriteriaObjArg.provider);
			Map<String, Object> fullSearchResponse = gfs.searchAllFilesSharePoint(fileCriteriaObjArg);
			
			filePaginatorObj.listOfItems = (List<FileListingWrapper>) fullSearchResponse.get('listOfFiles');
			filePaginatorObj.nextPageToken = (String) fullSearchResponse.get('nextPageToken'); 
			filePaginatorObj.totalRecords = (Integer) fullSearchResponse.get('totalRecords');
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
			
		} catch (EFSException ex) {
			logger.logError('FileDataServer.searchAllFilesSharePoint()----Exception Occured----' + ex);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 
		}
		return responseWrapperObj;
	}
    
    @TestVisible 
    private ResponseWrapper getSiteMSDriveFiles(Criteria.File fileCriteriaObjArg) {
    	logger.logDebug('FileDataServer.getSiteMSDriveFiles()----fileCriteriaObjArg----'+fileCriteriaObjArg);
    	ResponseWrapper responseWrapperObj = null;
    	Map<String,String> driveIdtoDriveNameMap = new Map<String,String>();
    	Boolean odFlag = ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileCriteriaObjArg.provider);
    	Boolean myFilesFlag = String.isBlank(fileCriteriaObjArg.siteId);
    	
    	if (UserContext.Integrations == null ||
    	    !UserContext.Integrations.containsKey(fileCriteriaObjArg.provider) || 
    		!UserContext.Integrations.get(fileCriteriaObjArg.provider).Connected__c) {
    		if(!odFlag) {
    			throw new SimpplrException(STR_KEY_ERROR_SHAREPOINT_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));		
    		}
    		throw new SimpplrException(STR_KEY_ERROR_ONEDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
    	}
    	
    	List<FileListingWrapper> listOfFileWrapper  = new List<FileListingWrapper>();
		FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper();
		
		EFSAccessService efsAccess = new EFSAccessService(fileCriteriaObjArg.provider, false);
		EFSFileService fs = new EFSFileService(efsAccess);
		 
		try {
	     	// Access for File Storage
     		Boolean isWriteFolderFilter = ServiceConstants.FILTER_WRITE_FOLDERS.equalsIgnoreCase(fileCriteriaObjArg.filter);
			String driveId;
			String driveName;
			String parentPath;

			if (String.isNotBlank(fileCriteriaObjArg.term)) {
				String scope = (String.isBlank(fileCriteriaObjArg.siteId) ? 'MyFiles' : 'SiteFiles');
				Map<String, Object> responseMap = fs.getMSDriveFilesCuratedSearch(scope, fileCriteriaObjArg, null);
				return buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseMap);
	     	} else {
	     		FolderDao daoObj = new FolderDao();
	     		Folder__c siteFold = daoObj.getEFSSiteFolder(fileCriteriaObjArg.siteId, fileCriteriaObjArg.provider);
	     		List<Folder__c> folList = daoObj.getEFSFolders(fileCriteriaObjArg.siteId, 
																(!myFilesFlag ? 'all' : ''), 
																fileCriteriaObjArg.provider, 
															    fileCriteriaObjArg.sortBy);
				Set<String> userIds = new Set<String>();
				if(siteFold != null && siteFold.owner.id != null) {
					userIds.add(siteFold.owner.id);
				}
				for (Folder__c folderObj : folList) {
					userIds.add(folderObj.Owner.Id);
				}
				for(Folder__c linkedFolder:	folList) {
					if(String.isNotBlank(linkedFolder.External_Folder_Id__c)) {
						driveIdtoDriveNameMap.put(linkedFolder.External_Folder_Id__c, linkedFolder.Name__c);
					}
				}

	     		filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
	     		filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING;
	     		if(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(fileCriteriaObjArg.provider)){
     				filePaginatorObj.directory.provider = ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING;
	     		}
				filePaginatorObj.directory.canLinkFolder = false;
	 			filePaginatorObj.canUpload = false;
				filePaginatorObj.directory.canCreateFolder = false;
			
				if(String.isNotBlank(fileCriteriaObjArg.siteId) && siteFold == null){
					filePaginatorObj.directory = null;
					filePaginatorObj.canCreateFolder = false;
			    	return buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
				} else if(String.isNotBlank(fileCriteriaObjArg.directory)) {
					if(siteFold != null && fileCriteriaObjArg.directory.equalsIgnoreCase(siteFold.id)) {
						filePaginatorObj.directory.canLinkSharepointFolder = SiteContext.isCurrentUserSiteOwner || SiteContext.isCurrentUserSiteManager;
					} else if(!odFlag && myFilesFlag && (fileCriteriaObjArg.isMediaManager == true)) {
			    	   // Handling of MyFiles for Sharepoint
						siteFold = daoObj.getSystemFolder(fileCriteriaObjArg.directory);
						if(siteFold != null) {
							userIds.add(siteFold.Owner.Id);
							fileCriteriaObjArg.siteId = siteFold.site__c;
							myFilesFlag = false;
						}
			    	}
				} else if((String.isNotBlank(fileCriteriaObjArg.currentDirectory) || String.isNotBlank(fileCriteriaObjArg.siteId)) && String.isBlank(fileCriteriaObjArg.directory)) {
					// this condition check is for move files 
					if(siteFold != null){
						fileCriteriaObjArg.directory = siteFold.id;
					}
				}
				PeopleDao.setPeopleNameMapByUserId(userIds);
				
				if(String.isNotBlank(fileCriteriaObjArg.directory) && siteFold != null && fileCriteriaObjArg.directory.equalsIgnoreCase(siteFold.id)) {
	 				filePaginatorObj.canUpload = false;
	 				filePaginatorObj.directory.canCreateFolder = false;
					if(odFlag == true) {
						filePaginatorObj.directory.canLinkFolder = SiteContext.isCurrentUserSiteOwner ;
					} else {
						filePaginatorObj.directory.canLinkFolder = SiteContext.isCurrentUserSiteOwner || SiteContext.isCurrentUserSiteManager;
					}
	 				
					// Read the local folder records
					for(Folder__c linkedFolder: folList) {
						FileListingWrapper wrapObj = new FileListingWrapper();
						wrapObj.id = linkedFolder.External_Folder_Id__c;
						wrapObj.externalFileId = linkedFolder.External_Folder_Id__c;
						wrapObj.modifiedAt = linkedFolder.lastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
						wrapObj.modifiedAtDateTime = linkedFolder.lastModifiedDate;
						
						if(odFlag) {
							wrapObj.rootDirectory = linkedFolder.EFS_Drive_Id__c;	
							wrapObj.canDelete = SiteContext.isCurrentUserSiteOwner;
							wrapObj.canChangeName = SiteContext.isCurrentUserSiteOwner;
							wrapObj.canUnlink = SiteContext.isCurrentUserSiteOwner;
						} else {
							wrapObj.rootDirectory = linkedFolder.External_Folder_Id__c;
							if(!SimpplrContext.isSharepointUpgraded || ( linkedFolder.SP_Instance_Id__c != null && UserContext.spInstanceId != null && linkedFolder.SP_Instance_Id__c.equalsIgnoreCase(UserContext.spInstanceId))){
								wrapObj.canChangeName = true;
								wrapObj.canUnlink = SiteContext.isCurrentUserSiteOwner || SiteContext.isCurrentUserSiteManager;
							}
						}
						wrapObj.title = linkedFolder.Name__c;
				    	wrapObj.context = fileCriteriaObjArg.provider;
				    	wrapObj.provider = fileCriteriaObjArg.provider;
						wrapObj.canCreateNewVersion = false;	
						wrapObj.permissions = 'read';
						wrapObj.canMove = false;
			    		wrapObj.type = 'Folder';	
			    		wrapObj.isDir = true;
			    		wrapObj.isFolder = 1;
			    		wrapObj.owner = new FileListingWrapper.OwnerWrapper();
			    		if(linkedFolder.People__c != null) {
			   				wrapObj.owner.Id = linkedFolder.People__c;
							wrapObj.owner.Name = linkedFolder.People__r.Full_Name__c;
							wrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + linkedFolder.People__c;
			    		} else {
			    			wrapObj.owner.Name = linkedFolder.Linked_Folder_Owner__c;
			    		}
				
						if(!isWriteFolderFilter || 
						   (isWriteFolderFilter && (fileCriteriaObjArg.rootDirectory == wrapObj.rootDirectory || String.isBlank(wrapObj.rootDirectory)))
						  ) {
							listOfFileWrapper.add(wrapObj);
						}
					}
				} else if(String.isNotBlank(fileCriteriaObjArg.directory) || isWriteFolderFilter) {	
					if(String.isBlank(fileCriteriaObjArg.rootDirectory)) {
						if(!odFlag) {
							fileCriteriaObjArg.rootDirectory = fileCriteriaObjArg.directory;
							fileCriteriaObjArg.directory = '';
						} else {
							for(Folder__c linkedFolder: folList) {
								if(fileCriteriaObjArg.directory.endsWith(linkedFolder.Name__c)) {
									fileCriteriaObjArg.rootDirectory = linkedFolder.EFS_Drive_Id__c;
									fileCriteriaObjArg.directory = linkedFolder.External_Folder_Id__c;
									break;
								}
							}
						}
					} else if (fileCriteriaObjArg.rootDirectory == fileCriteriaObjArg.directory) {
							for(Folder__c linkedFolder: folList) {
								if(fileCriteriaObjArg.directory.equalsIgnoreCase(linkedFolder.External_Folder_Id__c)) {
									if(String.isNotBlank(linkedFolder.Path__c)){
										fileCriteriaObjArg.externalUrl = linkedFolder.Path__c;
									}
									fileCriteriaObjArg.spInstanceId = String.isNotBlank(linkedFolder.SP_Instance_Id__c) ? linkedFolder.SP_Instance_Id__c : '';
									break;
								}
							}
							fileCriteriaObjArg.directory = '';
							filePaginatorObj.directory.spInstanceId = String.isNotBlank(fileCriteriaObjArg.spInstanceId) ? fileCriteriaObjArg.spInstanceId : null;
							if(SimpplrContext.isSharepointUpgraded && ( fileCriteriaObjArg.spInstanceId  != null && UserContext.spInstanceId != null && !fileCriteriaObjArg.spInstanceId .equalsIgnoreCase(UserContext.spInstanceId))){
								//folder is from different Instance
								filePaginatorObj.directory.isDifferentSpInstance = true;
							}else{
								filePaginatorObj.directory.isDifferentSpInstance = false;
							}
					} else if(!odFlag && isWriteFolderFilter) {
						fileCriteriaObjArg.rootDirectory = fileCriteriaObjArg.directory;
						fileCriteriaObjArg.directory = '';						
					}
					
					listOfFileWrapper = fs.listFiles('', fileCriteriaObjArg);	
					filePaginatorObj.canUpload = (fs.msParentPermission == 'readwrite' ? true : false);
					filePaginatorObj.directory.canCreateFolder = (fs.msParentPermission == 'readwrite' ? true : false);
		     	} else if(myFilesFlag) {
					FileListingWrapper.OwnerWrapper usrAsOwner = new FileListingWrapper.OwnerWrapper(); 
		   			usrAsOwner.Id = UserContext.peopleId;
					usrAsOwner.Name = UserContext.Integrations.get(fileCriteriaObjArg.provider).User_Name__c;
					usrAsOwner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ UserContext.peopleId;
		     		if(odFlag) {
			     		// My Files for onedrive						
			 			FileListingWrapper filesObj = new FileListingWrapper();
			 			filesObj.id = 'me';
			 			filesObj.externalFileId = 'me';
			 			filesObj.title = 'My Files';
			 			filesObj.type = 'Folder';
			    		filesObj.isDir = true;
			    		filesObj.isFolder = 1;
			    		filesObj.isSystemDir = true;
						filesObj.owner = usrAsOwner;
						filesObj.pathOnClient = '';
				    	listOfFileWrapper.add(filesObj);
				    	
			 			FileListingWrapper sharedObj = new FileListingWrapper();
			 			sharedObj.id = 'sharedwithme';
			 			sharedObj.externalFileId = 'sharedwithme';
			 			sharedObj.title = 'Shared with me';
			 			sharedObj.type = 'Folder';
			    		sharedObj.isDir = true;
			    		sharedObj.isFolder = 1;
			    		sharedObj.isSystemDir = true;
			    		sharedObj.owner = usrAsOwner;
			    		sharedObj.pathOnClient = '';
				    	listOfFileWrapper.add(sharedObj);
		     		} else {	
						// My Files for SharePoint
						for(Folder__c spSiteFolders: folList) {
							if(UserContext.chatterGroupsIFollowIdSet.contains(spSiteFolders.Site__r.chatter_Group_id__c)) {
								FileListingWrapper wrapObj = new FileListingWrapper();
								wrapObj.id = spSiteFolders.site__c;
								wrapObj.title = spSiteFolders.Site__r.Name;
						    	wrapObj.context = fileCriteriaObjArg.provider;
						    	wrapObj.provider = fileCriteriaObjArg.provider;
								wrapObj.canCreateNewVersion = false;	
								wrapObj.permissions = 'read';
								wrapObj.pathOnClient = '';
								wrapObj.canDelete = false;
								wrapObj.canChangeName = false;
								wrapObj.canUnlink = false;
								wrapObj.canMove = false;
					    		wrapObj.type = 'Site';	
					    		wrapObj.isDir = true;
					    		wrapObj.isFolder = 1;
					    		wrapObj.owner = new FileListingWrapper.OwnerWrapper();
					    		if(spSiteFolders.People__c != null) {
					   				wrapObj.owner.Id = spSiteFolders.People__c;
									wrapObj.owner.Name = PeopleDao.mapUserIdToPeopleName.containsKey(spSiteFolders.Owner.id) ? PeopleDao.mapUserIdToPeopleName.get(spSiteFolders.Owner.id) : spSiteFolders.Owner.name;
									wrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + spSiteFolders.Owner.id;
					    		} else {
					    			wrapObj.owner.Name = spSiteFolders.Linked_Folder_Owner__c;
					    		}
								
								listOfFileWrapper.add(wrapObj);
							}
						}
		     		}
				 }
				 
				// Handling for the Site Root Folder
				if(String.isNotBlank(fileCriteriaObjArg.directory) && siteFold != null && fileCriteriaObjArg.directory.equalsIgnoreCase(siteFold.id)) {
					fileCriteriaObjArg.directory = siteFold.Path__c;
				    filePaginatorObj.directory.id = siteFold.id;
					if(odFlag) {
						filePaginatorObj.directory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.onedrive_files');
					} else {
						filePaginatorObj.directory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.sharepoint_files');
					}
		 			filePaginatorObj.directory.isSystemDir = true;
		 			filePaginatorObj.directory.permissions = 'read';
				} else {
					parentPath = listOfFileWrapper.size() > 0 ? EncodingUtil.urlDecode(listOfFileWrapper[0].pathOnClient.replaceAll('\\+','%2B'), 'UTF-8') : '';					
					driveId =  String.isNotBlank(parentPath) && parentPath.startsWith('/drives') ? parentPath.substringAfter('/drives/').substringBefore('/') : fileCriteriaObjArg.rootDirectory;
		 			driveName = driveIdtoDriveNameMap != NULL ? driveIdtoDriveNameMap.get(driveId) : '';
 					FileListingWrapper.ParentWrapper parentWrap = new FileListingWrapper.ParentWrapper();
					if(String.isNotBlank(fileCriteriaObjArg.directory)){
						if(siteFold != null) {
							parentWrap.id = siteFold.id;
							if(odFlag) {
								parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.onedrive_files');
							} else {
								parentWrap.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.sharepoint_files');
							}
							filePaginatorObj.listOfParents.add(parentWrap);
						}
					}
					
					// drive information of parent
					FileListingWrapper.ParentWrapper parentWrapDrive = new FileListingWrapper.ParentWrapper();
					if (!odFlag &&
					    (!(String.isNotBlank(fileCriteriaObjArg.rootDirectory) && String.isBlank(fileCriteriaObjArg.directory)) || 
						(String.isNotBlank(fileCriteriaObjArg.rootDirectory) && siteFold != null && fileCriteriaObjArg.directory.equalsIgnoreCase(siteFold.id)))
					   ) {
						parentWrapDrive.id = driveId;
						parentWrapDrive.name = driveName;
						if(String.isNotBlank(driveName)) {
							filePaginatorObj.listOfParents.add(parentWrapDrive);
						}
					} else if(odFlag && myFilesFlag && String.isNotBlank(fileCriteriaObjArg.rootDirectory)) {
						if(fileCriteriaObjArg.rootDirectory == UserContext.Integrations.get(fileCriteriaObjArg.provider).My_Drive_Id__c) {
							parentWrapDrive.id = 'me';
							parentWrapDrive.name = 'My Files';							
						} else {
							parentWrapDrive.id = 'sharedwithme';
							parentWrapDrive.name = 'Shared with me';	
						}
						filePaginatorObj.listOfParents.add(parentWrapDrive);
					}
					
					String remainingParents ;
					String consolidatedPath = '';

					if (parentPath.startsWith('/drives/') || parentPath.startsWith('/drive/')) {
						remainingParents = parentPath.substringAfter('/root:');
					} else if (parentPath.contains('sharepoint.com/sites/')) {// using webUrl
						//parentPath = EncodingUtil.urlDecode(parentPath.replaceAll('\\+','%2B'), 'UTF-8');
						if(String.isNotBlank(driveName)){
							remainingParents = parentPath.substringAfter('/sites/').substringAfter('/').substringAfter(driveName).subStringBeforeLast('/');
						}
					} else if(String.isNotBlank(fileCriteriaObjArg.directory) && !'sharedwithme'.equalsIgnoreCase(fileCriteriaObjArg.directory)) {
						//parentPath = EncodingUtil.urlDecode(parentPath.replaceAll('\\+','%2B'), 'UTF-8');
						remainingParents = ('/' + parentPath.substringAfter('/Documents/')).subStringBeforeLast('/');
					}
					
					if(String.isNotBlank(remainingParents)) {
						Boolean odLFParsed = false;
						consolidatedPath = '/root:';
						for(String foldName: remainingParents.split('/')) {
							if(String.isNotBlank(foldName)) {
								consolidatedPath += '/' + foldName;
								
								FileListingWrapper.ParentWrapper rParentWrap = new FileListingWrapper.ParentWrapper();
								rParentWrap.id = consolidatedPath;
								rParentWrap.name = foldName;
								rParentWrap.rootDirectory = fileCriteriaObjArg.rootDirectory;
								 
								if(odFlag && 
								   !odLFParsed && 
								   (myFilesFlag || driveIdtoDriveNameMap.values().contains(foldName))
								   ) {
									odLFParsed = true;		
								}
								
								if(!odFlag || odLFParsed) {
									filePaginatorObj.listOfParents.add(rParentWrap);	
								}
							}
						}
					}

					// Directory info
	 				filePaginatorObj.directory.id = fileCriteriaObjArg.directory; 
	 				filePaginatorObj.directory.rootDirectory = fileCriteriaObjArg.rootDirectory;
	 				
	 				if(String.isBlank(fileCriteriaObjArg.directory) || fileCriteriaObjArg.directory == driveId){
	 					filePaginatorObj.directory.name = driveName;
	 					filePaginatorObj.directory.id = driveId;
						filePaginatorObj.directory.externalUrl = fileCriteriaObjArg.externalUrl;
	 				} else if (String.isNotBlank(fileCriteriaObjArg.directory)) {
						if (parentPath.endsWith('/root:')) { // in root folder
	 						if(odFlag && myFilesFlag) {
	 							filePaginatorObj.directory.id = 'me';
	 							filePaginatorObj.directory.name = 'My Files';
	 						} else {
								filePaginatorObj.directory.name = driveIdtoDriveNameMap.get(fileCriteriaObjArg.directory);
	 						}
	 					} else {
	 						if(odFlag && myFilesFlag && fileCriteriaObjArg.directory == 'sharedwithme') {
	 							filePaginatorObj.directory.id = 'sharedwithme';
	 							filePaginatorObj.directory.name = 'Shared with me';
	 						} else {
	 							filePaginatorObj.directory.name = parentPath.substringAfterLast('/');
	 						}
	 					}
	 				} 
	 				filePaginatorObj.directory.permissions = fs.msParentPermission;
					filePaginatorObj.directory.isSystemDir = false;
				}
	    	}

	    	fs.close();
     	} catch (EFSException se) {
     		logger.logDebug(se.getMessage() + fileCriteriaObjArg);
     		logger.logDebug(se.getError());
     		if('Not Found'.equalsIgnoreCase(se.getMessage())) {
     			FolderDao fdObj = new Folderdao();
				fdObj.deletLinkedFoldersForSite(fileCriteriaObjArg.provider, fileCriteriaObjArg.directory, fileCriteriaObjArg.rootDirectory);
	     		throw new SimpplrException(ServiceConstants.FILES_NOT_FOUND);
     		} else {
     			throw new SimpplrException(se.getMessage());
     		} 
     	}
     	
     	// Add to list only if there is files(this will exclude file which was only send to get parent info)
     	if (listOfFileWrapper.size() > 0 && String.isNotBlank(listOfFileWrapper[0].id) ) {
     		filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
     	} 
     	
		filePaginatorObj.nextPageUrl = fs.nextPageUrl;
     	if (String.isNotBlank(fs.nextPageToken) && filePaginatorObj.listOfItems.size() == fileCriteriaObjArg.size) {
	        filePaginatorObj.nextPageToken = fs.nextPageToken;
	    } else if(String.isNotBlank(fs.nextPageUrl) && String.isNotBlank(fs.nextPageToken)) {
	        filePaginatorObj.nextPageToken = fs.nextPageToken;
		} else {
	        filePaginatorObj.nextPageToken = null;
	    }
	    
		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
        return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=linkCrmFolder linkCrmFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName linkCrmFolder
	 *
	 * @apiParam (Query Parameter) {String} action linkCrmFolder
	 * @apiParam (Post Parameter) {Object} data  {directory, rootDirectory, name, permissions, siteId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.linkCrmFolder
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result crm Folder record just linked to site
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper linkCrmFolder(Criteria.Folder folderObjArg) {
     	ResponseWrapper responseWrapperObj = null;
     	
     	try {
			SiteService service = new SiteService();
			Folder__c folderObj = service.linkCRMFolderToSite(folderObjArg.directory, folderObjArg.name, folderObjArg.siteId);
			
			
			FileListingWrapper  fileWrapObj = new FileListingWrapper();
			fileWrapObj = ObjectToWrapperAdapter.folderToWrapper(folderObj, null);
			fileWrapObj.canChangeName = false;
	     	fileWrapObj.canSetPermissions = false;
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, fileWrapObj);     		
     	} catch (Exception ex) {
     		logger.logDebug('FileDataServer.linkCrmFolder()----Error Message----' + ex.getMessage());
     		throw new SimpplrException('Error while linking CRM Folder!');
     	}
     	
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=unlinkCRMFolder unlinkCRMFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName unlinkCRMFolder
	 *
	 * @apiParam (Query Parameter) {String} action unlinkCRMFolder
	 * @apiParam (Post Parameter) {Object} data  {folderId, siteId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.unlinkCRMFolder
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result crm Folder record just linked to site
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper unlinkCRMFolder(Map<String, String> requestDataMap) {
     	String crmFolderId = requestDataMap.get('folderId');
     	String siteId = readParam('siteId');
     	ResponseWrapper responseWrapperObj = null;
     	
     	try {
			SiteService service = new SiteService();
			service.unlinkCRMFolderFromSite(crmFolderId, siteId);
			
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);     		
     	} catch (Exception ex) {
     		logger.logDebug('FileDataServer.unlinkCRMFolder()----Error Message----' + ex.getMessage());
     		throw new SimpplrException('Error while unlinking CRM Folder!');
     	}
     	
     	return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=getCrmFolders getCrmFolders
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getCrmFolders
	 *
	 * @apiParam (Query Parameter) {String} action getCrmFolders
	 * @apiParam (Post Parameter) {Object} data  {directory, rootDirectory}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.File.getCrmFolders
	 * 2. Used in SiteFiles and MyFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result crm Folders record
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper getCrmFolders(Map<String, String> requestMap, String siteId) {
     	logger.logDebug('FileDataServer.getCrmFolders()----requestMap----'+requestMap + '----siteId----' + siteId);
     	ResponseWrapper responseWrapperObj = null;
     	
     	try {
			SiteService service = new SiteService();
			List<ContentWorkspace> allCRMLibList = service.fetchAllCRMLibList();
			
			Set<Id> linkedCRMLibIds = new Set<Id>();
			if(String.isNotBlank(siteId)) {
				linkedCRMLibIds = FileContentProvider.getLinkedLibraryIds4Site(siteId);
			}
			
			List<FilterAttributeWrapper> foldersWrapperList = new List<FilterAttributeWrapper>();
			
			for(ContentWorkspace cwObj : allCRMLibList) {
				if(linkedCRMLibIds.contains(cwObj.Id) == false) {
					FilterAttributeWrapper fAWObj = new FilterAttributeWrapper();
					
					fAWObj.id = cwObj.Id;
					fAWObj.name = cwObj.Name;
					
					foldersWrapperList.add(fAWObj);
				}
			}
			Map<String, Object> result = new Map<String, Object>();
			result.put('listOfItems', foldersWrapperList);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);     		
     	} catch (Exception ex) {
     		logger.logDebug('FileDataServer.getCrmFolders()----Error Message----' + ex.getMessage());
     		throw new SimpplrException('Error while linking CRM Folder!');
     	}
     	
     	logger.logDebug('FileDataServer.getCrmFolders()----responseWrapperObj----'+responseWrapperObj);
     	return responseWrapperObj;
    }
    
    
    /**
	 * @api {get} /apex/DataServerRW?target=FileDataServer&action=getSharePointLinkableItems getSharePointLinkableItems
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getSharePointLinkableItems
	 *
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Sharepoint.getSharePointLinkableItems
	 * 
	 * @apiSuccess {List[FileListingWrapper]} Response.listOfItems List of all the sites in Sharepoint
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	 * @apiError (Error 404) SimpplrException Album not found
	*/
    @TestVisible 
    private ResponseWrapper getSharePointLinkableItems (Map<String,String> requestDataMap) {
    	logger.logDebug('FileDataServer.getSharePointLinkableItems()----fileCriteriaObj----'+requestDataMap);
	    String redirectUrl = ''; 
	    
	    ResponseWrapper responseToReturn = null;
    	List<MSAPIModelSite.UIResponse> listOfMSSiteWrapper = new List<MSAPIModelSite.UIResponse>();
	    try {
	    	EFSFileService efs = new EFSFileService(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
			String weburl = requestDataMap.get('webUrl');
			String term = String.isNotBlank(requestDataMap.get('term'))  ?requestDataMap.get('term')+'*':'';
			String sharepointSiteId = requestDataMap.get('sharepointSiteId');
			if(String.isBlank(term)){
				if(String.isNotBlank(sharepointSiteId)){
					MSAPIModelSite msChildItemList = efs.getMSChildrenItemListing(sharepointSiteId);
					if(msChildItemList != null){
						if(msChildItemList.drives != null){
							for(MSAPIModelSite.ChildItem childObj: msChildItemList.drives){
								MSAPIModelSite.UIResponse respObj = new MSAPIModelSite.UIResponse();
								respObj.id = childObj.id;
								respObj.name = childObj.name;
								respObj.type = 'documentLibrary';
								respObj.webUrl = childObj.webUrl;
								respObj.owner = new Criteria.OwnerWrapper();
								String pplKey;
								
								if(childObj.owner != null && childObj.owner.user != null) {
									pplKey = childObj.owner.user.id;
									respObj.owner.Name = childObj.owner.user.displayName;	
								} else if(childObj.createdBy != null && childObj.createdBy.user != null) {
									pplKey = childObj.createdBy.user.id;
									respObj.owner.Name = childObj.createdBy.user.displayName;
								} else {
									respObj.owner.Id = UserContext.peopleId;
									respObj.owner.Name = UserContext.getCurrentUserInfo.Full_Name__c;
									respObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + UserContext.peopleId;
								}
								
								if(String.isNotBlank(pplKey)) {
									Map<String, People_Integration__c> EFSIdWithPeoplePrefMap = EFSFileService.getEFSIdWithPeoplePref();
									
									People_Integration__c ppl = EFSIdWithPeoplePrefMap.get(pplKey);
									if(ppl != null) {
										respObj.owner.Id = ppl.People__c;
										respObj.owner.Name = ppl.People__r.Full_Name__c;
										respObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ ppl.People__c;
									}
								}
								
								listOfMSSiteWrapper.add(respObj);
							}
						} 
						if(msChildItemList.sites != null){
							for(MSAPIModelSite.ChildItem subsiteObj: msChildItemList.sites){
								MSAPIModelSite.UIResponse respObj = new MSAPIModelSite.UIResponse();
								respObj.id = subsiteObj.id;
								respObj.name = subsiteObj.name;
								respObj.type = 'site';
								respObj.webUrl = subsiteObj.webUrl;
								listOfMSSiteWrapper.add(respObj);
							}
						}
					}
				} else {
					MSAPIModelSite.MSSiteListing msSiteList = efs.getMSSiteListing();
					if(msSiteList != null){
						if(msSiteList.value != null){
							for(MSAPIModelSite siteModel : msSiteList.value){
								if(siteModel.listItem == null){
									MSAPIModelSite.UIResponse respObj = new MSAPIModelSite.UIResponse();
									respObj.id = siteModel.id;
									respObj.name = siteModel.displayName;
									respObj.type = 'site';
									respObj.webUrl = siteModel.webUrl;
									listOfMSSiteWrapper.add(respObj);
								}
							}
						}
					}
				}
				
			} else {
				MSAPIModelSite.SearchResult searchResult = efs.searchSharepointLinkableItems(webUrl, term);
				logger.logdebug('searchResult===========>'+searchResult);
				if(searchResult != null && searchResult.value != null && !searchResult.value.isEmpty() 
				&& searchResult.value[0].hitsContainers!= null && !searchResult.value[0].hitsContainers.isEmpty() 
				&& searchResult.value[0].hitsContainers[0].hits != null && !searchResult.value[0].hitsContainers[0].hits.isEmpty()){
					for(MSAPIModelSite.Hits  hit : searchResult.value[0].hitsContainers[0].hits){
						MSAPIModelSite.UIResponse respObj = new MSAPIModelSite.UIResponse();
						if(hit.resource != null){
							if(hit.resource.type.equalsIgnoreCase('#microsoft.graph.site')){
								respObj.id = hit.resource.id;
								respObj.name = hit.resource.displayName;
								respObj.webUrl = hit.resource.webUrl;
								respObj.type = 'site';
							} else if(hit.resource.type.equalsIgnoreCase('#microsoft.graph.drive')){
								respObj.id = hit.resource.id;
								respObj.name = hit.resource.name;
								respObj.webUrl = hit.resource.webUrl;
								respObj.type = 'documentLibrary';
							}
						}
						listOfMSSiteWrapper.add(respObj);
						
					}
				}
			}
			Map<String, Object> result = new Map<String, Object>();
			listOfMSSiteWrapper.sort();
			result.put('listOfItems', listOfMSSiteWrapper);
			
			String siteId = requestDataMap.get('siteId');
			Boolean isMaxLimitReached = getTotalLinkedFoldersCount(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, siteId) >= 15 ? true : false;
			result.put('isMaxLimitReached', isMaxLimitReached);
    		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
	    
		} catch (Exception e) {
			logger.logError('Could not retrieve MS sites item list',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        	if(String.isNotBlank(redirectUrl)) {
        		responseToReturn.redirectUrl = redirectUrl;
        	}		
		}
    	return responseToReturn;
	}
    
    /**
	 * @api {get} /apex/DataServerRW?target=FileDataServer&action=getOnedriveLinkableItems getOnedriveLinkableItems
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName getOnedriveLinkableItems
	 *
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Sharepoint.getOnedriveLinkableItems
	 * 
	 * @apiSuccess {List[FileListingWrapper]} Response.listOfItems List of all the sites in Sharepoint
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	 * @apiError (Error 404) SimpplrException Album not found
	*/
    @TestVisible 
    private ResponseWrapper getOnedriveLinkableItems (Map<String,String> requestDataMap) {
//    	logger.logDebug('FileDataServer.getOnedriveLinkableItems()----fileCriteriaObj----'+requestDataMap);
	    String redirectUrl = ''; 
	    
	    ResponseWrapper responseToReturn = null;
	    try {
	    	List<MSAPIModelDriveItem.UIOnedriveLinkingResponse> listOfMSDriveItemWrapper = new List<MSAPIModelDriveItem.UIOnedriveLinkingResponse>();
	    	String folderId = String.valueOf(requestDataMap.get('folderId'));
	    	String folderType = String.valueOf(requestDataMap.get('folderType'));
	    	String driveId = String.valueOf(requestDataMap.get('rootDirectory'));
	    	EFSFileService efs = new EFSFileService(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);
			List<MSAPIModelDriveItem.UIOnedriveLinkingResponse> msDriveItemList = efs.getOnedriveLinkableItemListing(folderType, folderId, driveId);
			
			Map<String, Object> result = new Map<String, Object>();
			result.put('listOfItems', msDriveItemList);
    		responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
		} catch (Exception e) {
			logger.logError('Could not retrieve MS sites item list',e);
        	responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
        	if(String.isNotBlank(redirectUrl)) {
        		responseToReturn.redirectUrl = redirectUrl;
        	}		
		}
    	return responseToReturn;
    }
    
    @TestVisible 
    private ResponseWrapper linkSharepointFolder (Criteria.Folder foldObj) {
		ResponseWrapper responseWrapperObj = null;
		try{
			String driveId = foldObj.directory;
			String simpplrSiteId = foldObj.siteId;
			if(getTotalLinkedFoldersCount(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, foldObj.siteId) >= 15) {
				throw new SimpplrException(ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_SITE.name());
			}
			if(getTotalLinkedFoldersCount(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, null) >= 300) {
				throw new SimpplrException(ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_ORG.name());
			}

			FolderDao daoObj = new FolderDao();
			Boolean isAlreadyLinked = daoObj.isFolderAlreadyLinkedForSite(driveId, simpplrSiteId, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
			if(isAlreadyLinked) {
				throw new SimpplrException(ExceptionCode.FOLDER_ALREADY_LINKED_FOR_SITE.name());
			} else {
				String name = foldObj.name;
				Criteria.OwnerWrapper ownerInfo = new Criteria.OwnerWrapper();
				ownerInfo.Id = UserContext.peopleId;
				ownerInfo.name = UserContext.peopleName;
				ownerInfo.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ UserContext.peopleId;

				// store data in AWS
				EFSAccessService efsAccess = new EFSAccessService(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, false);
				EFSFileService efs = new EFSFileService(efsAccess);
				String username = getConnectedUserName(UserContext.userId, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
				String sharepointInstanceId = UserContext.spInstanceId;
				efs.insertAWSRecordForFolder(foldObj.siteId, foldObj.sharepointSiteId, sharepointInstanceId, SiteContext.chatterGroupId, driveId, '', foldObj.webUrl, userName, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);

				FolderDao fdObj = new Folderdao();
				fdObj.createMSStorageFoldersForSite(foldObj.siteId, sharepointInstanceId, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, false, null, driveId, name, ownerInfo, foldObj.webUrl);
				
				FileListingWrapper wrapperObj = new FileListingWrapper();
				wrapperObj.title = name;
				wrapperObj.name = name;
				wrapperObj.id = driveId;
				wrapperObj.fileId = driveId;
				wrapperObj.rootDirectory = driveId;
				wrapperObj.type = 'Folder';	
				wrapperObj.isDir = true;
				wrapperObj.isFolder = 1;
				wrapperObj.isImage = false;
				wrapperObj.canChangeName = true;
				wrapperObj.spInstanceId = sharepointInstanceId;

				if(ownerInfo != null) {
					try {
						wrapperObj.owner.id = ownerInfo.id;
						wrapperObj.owner.name = ownerInfo.name;
						wrapperObj.owner.URL = ownerInfo.URL;
					} catch(Exception oe) {
						wrapperObj.owner.name = ownerInfo.name;
					}
				} else {
					wrapperObj.owner.Id = UserContext.peopleId;
					wrapperObj.owner.Name = UserContext.peopleName;
					wrapperObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ UserContext.peopleId;
				}
				
				// Unlink permission after the folder linking
				wrapperObj.canUnlink = true;
				wrapperObj.provider = ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING;
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
			}
		} catch(exception ex){
			logger.logError('FileDataServer.linkSharepointFolder()-----could not retrieve data----',ex);
			
			String errorMessage;
			if((ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_SITE.name()).equalsIgnorecase(ex.getMessage()) ) {
				errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.link_folder.sharepoint.limit_reach_error_flash');

			} else if((ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_ORG.name()).equalsIgnorecase(ex.getMessage()) ) {
				errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.link_folder.sharepoint.limit_reach_error_flash');

			} else if((ExceptionCode.FOLDER_ALREADY_LINKED_FOR_SITE.name()).equalsIgnorecase(ex.getMessage()) ) {
				errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.link_folder.folder_already_linked_error_flash');

			}

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errorMessage, null);
		}
		 return responseWrapperObj;
    } 
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=linkOnedriveFolder linkOnedriveFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName linkOnedriveFolder
	 *
	 * @apiParam (Query Parameter) {String} action linkOnedriveFolder
	 * @apiParam (Post Parameter) {Object} data  {driveId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Onedrive.linkOnedriveFolder
	 * 2. Used in SiteFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result 
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper linkOnedriveFolder (Criteria.Folder foldObj) {
		ResponseWrapper responseWrapperObj = null;
		try{
			if(getTotalLinkedFoldersCount(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, foldObj.siteId) > 15) {
				throw new SimpplrException(ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_SITE.name());
			}
			if(getTotalLinkedFoldersCount(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, null) > 300) {
				throw new SimpplrException(ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_ORG.name());
			}
			
			String driveId = foldObj.rootDirectory;
			String name = foldObj.name;
			String driveItemId = foldObj.directory;
			Criteria.OwnerWrapper ownerInfo = foldObj.owner;
			
			// store data in AWS
			EFSAccessService efsAccess = new EFSAccessService(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, false);
			EFSFileService efs = new EFSFileService(efsAccess);
			String username = getConnectedUserName(UserContext.userId, ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);
			efs.insertAWSRecordForFolder(foldObj.siteId, '', '', SiteContext.chatterGroupId, driveId, driveItemId, foldObj.webUrl, userName, ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);

			FolderDao fdObj = new Folderdao();
			fdObj.createMSStorageFoldersForSite(foldObj.siteId, '', ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, false, driveItemId, driveId, name, ownerInfo, foldObj.webUrl);
			
			FileListingWrapper wrapperObj = new FileListingWrapper();
			wrapperObj.title = name;
			wrapperObj.name = name;
			wrapperObj.id = driveItemId;
			wrapperObj.fileId = driveItemId;
			wrapperObj.rootDirectory = driveId;
			wrapperObj.type = 'Folder';	
			wrapperObj.isDir = true;
			wrapperObj.isFolder = 1;
			wrapperObj.isImage = false;

			if(ownerInfo != null) {
				try {
					wrapperObj.owner.id = ownerInfo.id;
					wrapperObj.owner.name = ownerInfo.name;
					wrapperObj.owner.URL = ownerInfo.URL;
				} catch(Exception oe) {
					wrapperObj.owner.name = ownerInfo.name;
				}
			} else {
				wrapperObj.owner.Id = UserContext.peopleId;
				wrapperObj.owner.Name = UserContext.peopleName;
				wrapperObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/'+ UserContext.peopleId;
			}
			
			// Unlink permission after the folder linking
			wrapperObj.canUnlink = true;
			wrapperObj.canChangeName = false;
			wrapperObj.canDelete = false;
			wrapperObj.provider = ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING;
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
     	
		} catch(exception ex){
			logger.logError('FileDataServer.linkOnedriveFolder()-----could not retrieve data----',ex);
			
			String errorMessage; 
			if( (ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_SITE.name()).equalsIgnorecase(ex.getMessage()) ) {
				errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.link_folder.onedrive.limit_reach_error_flash');

			} else if( (ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_ORG.name()).equalsIgnorecase(ex.getMessage()) ) {
				errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.link_folder.onedrive.limit_reach_error_flash');

			}

  			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errorMessage, null);
		}

		return responseWrapperObj;
    }
    
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=unLinkOnedriveFolder unLinkOnedriveFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName unLinkOnedriveFolder
	 *
	 * @apiParam (Query Parameter) {String} action unLinkOnedriveFolder
	 * @apiParam (Post Parameter) {Object} data  {driveId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Onedrive.unLinkOnedriveFolder
	 * 2. Used in SiteFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result 
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper unLinkOnedriveFolder (Map<String,String> requestData) {
		ResponseWrapper responseWrapperObj = null;
		try {
			String driveItemId = requestData.get('folderId');
			String siteId = requestData.get('siteId');
			
			// store data in AWS
			EFSAccessService efsAccess = new EFSAccessService(ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, false);
			EFSFileService efs = new EFSFileService(efsAccess);
			String username = getConnectedUserName(UserContext.userId, ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);
			efs.deleteAWSRecordForFolder(siteId, false, '', driveItemId, userName, ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING);

			FolderDao fdObj = new Folderdao();
			fdObj.deleteMSStorageFoldersForSite(siteId, ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING, false, driveItemId, null);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
     	
		} catch(exception e){
			logger.logError('FileDataServer.unLinkOnedriveFolder()-----could not retrieve data----',e);
  			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
    }
    
    /**
	 * @api {post} /apex/DataServerRW?target=FileDataServer&action=unLinkSharepointFolder unLinkSharepointFolder
	 * @apiVersion 1.0.0
	 * @apiGroup FileDataServer
	 * @apiName unLinkSharepointFolder
	 *
	 * @apiParam (Query Parameter) {String} action unLinkSharepointFolder
	 * @apiParam (Post Parameter) {Object} data  {driveId}
	 * @apiDescription 
	 * 1. Called from Simpplr.Salesforce.Sharepoint.unLinkSharepointFolder
	 * 2. Used in SiteFiles
	 * 
	 * @apiSuccess {FileListingWrapper} Response.result 
	 * @apiUse FileListingWrapper
	 *
	 * @apiError SimpplrException Simpplr Exception
	*/
    @TestVisible 
    private ResponseWrapper unLinkSharepointFolder (Map<String,String> requestData) {
		ResponseWrapper responseWrapperObj = null;
		try{
			String driveId = requestData.get('folderId');
			String siteId = requestData.get('siteId');

			// store data in AWS
			EFSAccessService efsAccess = new EFSAccessService(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, false);
			EFSFileService efs = new EFSFileService(efsAccess);
			People_Integration__c ppl = UserContext.integrations.get(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);

			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', driveId);
			soqlParamMap.put('soqlParam2', ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);
			String folderQuery = 'select id, type__c,name__c, SP_Instance_Id__c from Folder__c where External_Folder_Id__c=:soqlParam1 and Is_Deleted__c = false and type__c =:soqlParam2';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);

			if (!SimpplrContext.isSharepointUpgraded || (listOfFolders.size() > 0 && listOfFolders[0].SP_Instance_Id__c == UserContext.spInstanceId)) {
				efs.deleteAWSRecordForFolder(siteId, false, driveId, '', ppl.User_Name__c, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING);

				FolderDao fdObj = new Folderdao();
				fdObj.deleteMSStorageFoldersForSite(siteId, ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, false, null, driveId);
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
			} else {
				logger.logError('FileDataServer.unLinkSharepointFolder()-----folder data not retrieved or user sp instance is mismatched----');
				responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
			}
     	
		} catch(exception e){
			logger.logError('FileDataServer.unLinkSharepointFolder()-----could not retrieve data----',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
    } 
    
    /**
     * This method is used to check file folder permissions
     * @param requestData 
     * @return  `ResponseWrapper`
     */
    @TestVisible 
    public ResponseWrapper getFileFolderPermission (Map<String,String> requestData) {
        ResponseWrapper responseWrapperObj = null;
        try{
            String itemId = requestData.get('itemId');
            String siteId = requestData.get('siteId');
            String storageType = requestData.get('provider');
			Boolean isDir = requestData.containsKey('isDir') ? Boolean.valueOf(requestData.get('isDir')) : true;
            Boolean isAccessible = true;
            if(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(storageType)) {
                Map<String, Object> soqlParamMap = new Map<String, Object>();
                soqlParamMap.put('soqlParam1', itemId);
                soqlParamMap.put('soqlParam2', storageType);
                String folderQuery = 'SELECT Id, External_Folder_Id__c, Site__c FROM Folder__c WHERE External_Folder_Id__c=:soqlParam1 and Is_Deleted__c = false AND Type__c =:soqlParam2';
                SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
                List<Folder__c> listOfFolders = (List<Folder__c>)SIMPESAPI.accessController().queryAsUser(folderQuery, soqlParamMap);
                if(listOfFolders.size() > 0) {
                    EFSAccessService efsAccess = new EFSAccessService(ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING, false);
                    isAccessible = efsAccess.isSPFolderAccessible(itemId);  
                    responseWrapperObj = isAccessible ? buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, new Map<String, Object>{ 'isAccessible' => true }) : buildResponseWrapper(RESPONSE_STATUS_ERROR, null, new Map<String, Object>{ 'isAccessible' => false }); 
                } else {
                    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
                }
            } else if(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(storageType)) {
                isAccessible = new GoogleDriveService().checkFolderPermission(itemId); 
                responseWrapperObj = isAccessible ? buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, new Map<String, Object>{ 'isAccessible' => true }) : buildResponseWrapper(RESPONSE_STATUS_ERROR, null, new Map<String, Object>{ 'isAccessible' => false });      	
            
            } else if(ServiceConstants.STORAGE_TYPE_BOX_STRING.equalsIgnoreCase(storageType)) {
				String filter = requestData.get('userAction');
                BoxDao boxDaoObj = new BoxDao();
				BoxWrapper.FolderFile folderFileObj;
				Boolean isAccessDenied = false;
				try {
					if(isDir){
						folderFileObj = boxDaoObj.getContentsAssociatedToFolder(itemId, 0, 1);
						isAccessDenied = folderFileObj.isAccessDenied;
					} else {
						folderFileObj = boxDaoObj.getBoxFileDetails(itemId);
					}
				} catch(exception e) {
					isAccessDenied = true;
				}
				if(isAccessDenied == false) {
					BoxWrapper.BoxPermissions permissions = folderFileObj.permissions;
					if(String.isNotBlank(filter) && 'delete'.equalsIgnoreCase(filter)) {
						isAccessDenied = permissions.can_delete == false ? true : false;
					} else if(String.isNotBlank(filter) && 'rename'.equalsIgnoreCase(filter)) {	
						isAccessDenied = permissions.can_rename == false ? true : false;
					}
				}
                responseWrapperObj = isAccessDenied == true ? buildResponseWrapper(RESPONSE_STATUS_ERROR, null, new Map<String, Object>{ 'isAccessible' => false }) : buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, new Map<String, Object>{ 'isAccessible' => true });      	
            } else {
                responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
            }
        } catch(exception e) {
            logger.logError('FileDataServer.getFileFolderPermission()-----could not retrieve data----',e);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
        }
        return responseWrapperObj;
    } 

	@TestVisible 
    private ResponseWrapper getFileTypes() {
        LocaleContext.getAllLabelMap('File', new List<String>{UserContext.languageLocaleKey});
        ResponseWrapper responseWrapperObj = null;
        try {
            Set<Pair> setOfAllFileTypes = new Set<Pair>();
            setOfAllFileTypes.add(new Pair('pdf', LocaleContext.getLabel(UserContext.languageLocaleKey, STR_KEY_FILE_TYPE_PDF)));
            setOfAllFileTypes.add(new Pair('microsoft_office_excel', LocaleContext.getLabel(UserContext.languageLocaleKey, STR_KEY_FILE_TYPE_MICROSOFT_OFFICE_EXCEL)));
            setOfAllFileTypes.add(new Pair('microsoft_office_document', LocaleContext.getLabel(UserContext.languageLocaleKey, STR_KEY_FILE_TYPE_MICROSOFT_OFFICE_DOCUMENT)));
            setOfAllFileTypes.add(new Pair('microsoft_powerpoint', LocaleContext.getLabel(UserContext.languageLocaleKey, STR_KEY_FILE_TYPE_MICROSOFT_POWERPOINT)));
			setOfAllFileTypes.add(new Pair('text', LocaleContext.getLabel(UserContext.languageLocaleKey, STR_KEY_FILE_TYPE_TXT)));
			setOfAllFileTypes.add(new Pair('csv', LocaleContext.getLabel(UserContext.languageLocaleKey, STR_KEY_FILE_TYPE_CSV)));
            setOfAllFileTypes.add(new Pair('rtf', LocaleContext.getLabel(UserContext.languageLocaleKey, STR_KEY_FILE_TYPE_RTF)));
			setOfAllFileTypes.add(new Pair('zip', LocaleContext.getLabel(UserContext.languageLocaleKey, STR_KEY_FILE_TYPE_ZIP)));
			
			Map<String, Object> responseMap = new Map<String, Object>();
			responseMap.put('listOfItems', setOfAllFileTypes);
            responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, responseMap);
        } catch(exception e){
			logger.logError('FileDataServer.getFileTypes()-----could not retrieve data----',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
 
        return responseWrapperObj;
    }
	
	private Integer getTotalLinkedFoldersCount(String storageProvider, String siteId) {
		return getTotalLinkedFoldersCount(storageProvider, siteId, null);
	}

	private Integer getTotalLinkedFoldersCount(String storageProvider, String siteId, String driveType) {
		Integer linkedFolderCount = 0;

		FolderDao folderDaoObj = new FolderDao();
		linkedFolderCount = folderDaoObj.getTotalLinkedFoldersCount(storageProvider, siteId, driveType);

		return linkedFolderCount;
	}

	private String getConnectedUserName(String peopleId, String storageProvider) {
		String userName;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', peopleId);
		soqlParamMap.put('soqlParam2', storageProvider);
		String queryStr = 'SELECT Id, People__c, User_Name__c FROM People_Integration__c '+
														' WHERE People__c = :soqlParam1 AND name = :soqlParam2 '+
														' AND Connected__c = true AND Active__c = true AND Is_Deleted__c = false'+
														' LIMIT 1';
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> peopleIntegrationList = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
		if(!peopleIntegrationList.isEmpty()) {
			userName = peopleIntegrationList[0].User_Name__c;
		}
		
		return userName;
    }
    
    @TestVisible 
    private ResponseWrapper getGoogleDriveLinkFolders (Criteria.Folder folderObjArg) {
        logger.logDebug('FileDataServer.getGoogleDriveLinkFolders()----folderObjArg----' + folderObjArg);
        ResponseWrapper responseWrapperObj = null;
        Map<String, Object> result = new Map<String, Object>();
        GoogleDriveService gService = new GoogleDriveService();
        
        if (folderObjArg.type == 'mydrive') { 
            result = gService.getMyDriveFolderListingForLinking(folderObjArg);

        } else if (folderObjArg.type == 'shareddrive') {
            result = gService.getSharedDrivesForLinking(folderObjArg);
            
		}
        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
     	return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper getSiteSharedDriveDetails(Criteria.Folder folderObjArg) {
        logger.logDebug('FileDataServer.getSiteSharedDriveDetails()----folderObjArg----' + folderObjArg);
        ResponseWrapper responseWrapperObj = null;
        try{
	        Map<String, Object> result = new Map<String, Object>();

	        result.put('isSharedDriveLinkedWithSite', false);
	        result.put('sharedDrive', null);

	        if(String.isNotBlank(folderObjArg.siteId) && String.isNotBlank(folderObjArg.storage)){
	        	FolderDao daoObj = new FolderDao();
	        	List<Folder__c> listOfFolder = daoObj.getSiteGoogleSharedDriveDetails(folderObjArg.siteId,  folderObjArg.storage);

	        	logger.logDebug('FileDataServer.getSiteSharedDriveDetails()----listOfFolder----' + listOfFolder);
	        	
	        	if(listOfFolder != null && !listOfFolder.isEmpty()){
	        		GoogleDriveModel.Drive drive = new GoogleDriveModel.Drive();
	        		drive.id = listOfFolder[0].External_Folder_Id__c;
	        		drive.name = listOfFolder[0].Name__c;

	        		result.put('sharedDrive', drive);
	        		result.put('isSharedDriveLinkedWithSite', true);
	        	}
	        }
	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, result);
     	} catch(Exception e){
			logger.logError('FileDataServer.getSiteSharedDriveDetails()-----could not retrieve data----', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseWrapperObj;
    }
 
    @TestVisible 
	private ResponseWrapper linkGoogleDriveFolder (Criteria.Folder folderObjArg) {
	    logger.logDebug('FileDataServer.linkGoogleDriveFolder()----folderObjArg----'+ folderObjArg);
	    ResponseWrapper responseWrapperObj = null;
	    FileListingWrapper wrapperObj = new FileListingWrapper();
	    try {
	        if(folderObjArg.type == IntegrationConstants.GOOGLE_DRIVE_TYPE_MYDRIVE){
	        	wrapperObj = linkGoogleMyDriveFolder(folderObjArg);
	        }else if (folderObjArg.type == IntegrationConstants.GOOGLE_DRIVE_TYPE_SHARED_DRIVE){
	        	wrapperObj = linkGoogleSharedDrive(folderObjArg);
	        }
	        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);
	    } catch(exception ex){
			logger.logError('FileDataServer.linkGoogleDriveFolder()-----could not retrieve data----',ex);
			
			String errorMessage;
			if((ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_SITE.name()).equalsIgnorecase(ex.getMessage())) {
				errorMessage = LocaleContext.getLabel(UserContext.languageLocaleKey, 'file.link_folder.googledrive.limit_reach_error_flash');
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, errorMessage, null);
		}
		return responseWrapperObj;
	}

    @TestVisible 
    private FileListingWrapper linkGoogleMyDriveFolder(Criteria.Folder folderObjArg) {
		FileListingWrapper wrapperObj = new FileListingWrapper();

		Integer maxLinkFolderLimit = 15; //my drive limit

		if (getTotalLinkedFoldersCount(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING, folderObjArg.siteId, folderObjArg.type) >= maxLinkFolderLimit) {
			throw new SimpplrException(ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_SITE.name());
		}

		List<Simpplr_Site__c> listOfSimpplrSite = [SELECT id, Chatter_Group_Id__c,
				Site_Type__c 
				FROM Simpplr_Site__c 
				WHERE id=:folderObjArg.siteId WITH SECURITY_ENFORCED];        
		
		if (!listOfSimpplrSite.isEmpty()) {
			GoogleDriveService serviceObj = new GoogleDriveService();
            String directory = folderObjArg.directory;
            
			if (String.isBlank(directory) && String.isNotBlank(folderObjArg.name)) {
				GoogleDriveModel.File folderDetails = serviceObj.getFolderDetails(folderObjArg.type, null, folderObjArg.name);
				directory = folderDetails.id;
            } 

            SIMPSFDCAccessControlResults.InsertResults insertObjResult;

			if (!SimpplrContext.googleManagedPermission) {
				GoogleDriveModel.GroupPermission grpPermissionObj = serviceObj.addPermissionsToLinkedFolder(
						listOfSimpplrSite[0].Chatter_Group_Id__c, directory,
						listOfSimpplrSite[0].Site_Type__c, folderObjArg.type);  
				// Check for 15 shared drive limit 
				// create folder_c object with parent dir, and externalFolderId
				Folder__c newFoldObj = new Folder__c();
				Folder__c siteFold = new FolderDao().getEFSSiteFolder(folderObjArg.siteId, ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
				newFoldObj.Name__c = folderObjArg.Name;
				newFoldObj.Site__c = folderObjArg.siteId;
				newFoldObj.Type__c = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
				newFoldObj.Is_System_Folder__c = false;
				newFoldObj.External_Folder_Id__c = directory;
				newFoldObj.Drive_Type__c = folderObjArg.type; 
				newFoldObj.Domain__c = PeopleDao.getPeopleIntDomainByPeopleId(UserContext.peopleId, IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE);
				newFoldObj.EFS_Read_Collaboration_Id__c = grpPermissionObj.rPermissionId;
				newFoldObj.EFS_Read_Write_Collaboration_Id__c = grpPermissionObj.rWPermissionId;
				newFoldObj.EFS_Search_Collaboration_Id__c = grpPermissionObj.searchPermissionId;
				newFoldObj.EFS_All_Company_Collaboration_Id__c = grpPermissionObj.pubPermissionId;
				
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);				
				insertObjResult = SIMPESAPI.accessController().insertAsUser(
					new List<Folder__c>{newFoldObj}, 
					new List<Schema.SObjectField> {
						Folder__c.Name__c,
						Folder__c.Site__c,
						Folder__c.Type__c,
						Folder__c.Is_System_Folder__c,
						Folder__c.External_Folder_Id__c,
						Folder__c.Drive_Type__c, 
						Folder__c.EFS_Read_Collaboration_Id__c,
						Folder__c.EFS_Read_Write_Collaboration_Id__c,
						Folder__c.EFS_Search_Collaboration_Id__c,
						Folder__c.EFS_All_Company_Collaboration_Id__c,
						Folder__C.Domain__c
					}
				);

			} else  {
				Folder__c newFoldObj = new Folder__c();
				Folder__c siteFold = new FolderDao().getEFSSiteFolder(folderObjArg.siteId, ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
				newFoldObj.Name__c = folderObjArg.Name;
				newFoldObj.Site__c = folderObjArg.siteId;
				newFoldObj.Type__c = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
				newFoldObj.Is_System_Folder__c = false;
				newFoldObj.External_Folder_Id__c = directory;
				newFoldObj.Drive_Type__c = folderObjArg.type; 
				newFoldObj.Domain__c = PeopleDao.getPeopleIntDomainByPeopleId(UserContext.peopleId, IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE);
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);				
				insertObjResult = SIMPESAPI.accessController().insertAsUser(
					new List<Folder__c>{newFoldObj}, 
					new List<Schema.SObjectField> {
						Folder__c.Name__c,
						Folder__c.Site__c,
						Folder__c.Type__c,
						Folder__c.Is_System_Folder__c,
						Folder__c.External_Folder_Id__c,
						Folder__c.Drive_Type__c,
						Folder__c.Domain__c
					}
				);
			}         

			
			
			List<Folder__c> listOfFolder = new List<Folder__C>();
            listOfFolder = insertObjResult.getInsertedObjects();	
            listOfFolder = new FolderDao().getGoogleDriveLinkedFolder(listOfFolder[0].id);  
			wrapperObj.name = listOfFolder[0].name__c; 
			wrapperObj.title = listOfFolder[0].name__c;
			wrapperObj.isDir = true;
			wrapperObj.type = 'Folder';
			wrapperObj.driveType = listOfFolder[0].Drive_Type__c;
			wrapperObj.provider = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
			wrapperObj.externalFileId = listOfFolder[0].External_Folder_Id__c;
            wrapperObj.id = listOfFolder[0].External_Folder_Id__c; 
            wrapperObj.owner.id = listOfFolder[0].Owner.id;
		    wrapperObj.owner.name = UserContext.peopleName;
		    wrapperObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + listOfFolder[0].Owner.id; 
            Boolean isUserOwnerOrManager = (UserContext.sitesIManageMap.get(folderObjArg.siteId) != null) ||
		 			UserContext.Id.equalsIgnoreCase(listOfFolder[0].Owner.id);
            wrapperObj.canSetPermissions = false;
            wrapperObj.canUnlink = SiteContext.canManage();				
            wrapperObj.canChangeName = isUserOwnerOrManager;
            wrapperObj.canDelete = false;
		}
     	return wrapperObj;
	}
	
	@TestVisible 
    private FileListingWrapper linkGoogleSharedDrive(Criteria.Folder folderObjArg) {
		FileListingWrapper wrapperObj = new FileListingWrapper();

		Integer maxLinkFolderLimit = 1; //For shared drive limit
		if(getTotalLinkedFoldersCount(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING, folderObjArg.siteId, folderObjArg.type) >= maxLinkFolderLimit) {
			throw new SimpplrException(ExceptionCode.LINKED_FOLDER_LIMIT_EXCEEDED_FOR_SITE.name());
		}     
		
		GoogleDriveService serviceObj = new GoogleDriveService();
        String directory = folderObjArg.directory;
        
		if (String.isBlank(directory) && String.isNotBlank(folderObjArg.name)) {
			GoogleDriveModel.File folderDetails = serviceObj.getFolderDetails(folderObjArg.type, null, folderObjArg.name);
			directory = folderDetails.id;
        } 

		// create folder_c object with parent dir, and externalFolderId
		Folder__c newFoldObj = new Folder__c();
		Folder__c siteFold = new FolderDao().getEFSSiteFolder(folderObjArg.siteId, ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
		newFoldObj.Name__c = folderObjArg.Name;
		newFoldObj.Site__c = folderObjArg.siteId;
		newFoldObj.Type__c = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
		newFoldObj.Is_System_Folder__c = false;
		newFoldObj.External_Folder_Id__c = directory;
		newFoldObj.Drive_Type__c = folderObjArg.type; 
		newFoldObj.Domain__c = PeopleDao.getPeopleIntDomainByPeopleId(UserContext.peopleId, IntegrationConstants.INTEGRATION_TYPE_GOOGLE_DRIVE);
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);				
		SIMPSFDCAccessControlResults.InsertResults result = SIMPESAPI.accessController().insertAsUser(
			new List<Folder__c>{newFoldObj}, 
			new List<Schema.SObjectField> {
				Folder__c.Name__c,
				Folder__c.Site__c,
				Folder__c.Type__c,
				Folder__c.Is_System_Folder__c,
				Folder__c.External_Folder_Id__c,
				Folder__c.Drive_Type__c,
				Folder__c.Domain__c
			}
		);
		
		List<Folder__c> listOfFolder = new List<Folder__C>();
        listOfFolder = result.getInsertedObjects();	
        listOfFolder = new FolderDao().getGoogleDriveLinkedFolder(listOfFolder[0].id);		
		wrapperObj.name = listOfFolder[0].name__c; 
		wrapperObj.title = listOfFolder[0].name__c;
		wrapperObj.isDir = true;
		wrapperObj.type = 'Folder';
		wrapperObj.driveType = listOfFolder[0].Drive_Type__c;
		wrapperObj.provider = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
		wrapperObj.externalFileId = listOfFolder[0].External_Folder_Id__c;
        wrapperObj.id = listOfFolder[0].External_Folder_Id__c; 
        wrapperObj.owner.id = listOfFolder[0].Owner.id;
	    wrapperObj.owner.name = UserContext.peopleName;
	    wrapperObj.owner.url = PageContext.getPageURL(Pages.app) + '?u=/redirect-to-profile/' + listOfFolder[0].Owner.id; 
        Boolean isUserOwnerOrManager = (UserContext.sitesIManageMap.get(folderObjArg.siteId) != null) ||
	 			UserContext.Id.equalsIgnoreCase(listOfFolder[0].Owner.id);
        wrapperObj.canSetPermissions = false;
        wrapperObj.canUnlink = SiteContext.canManage();				
    
        wrapperObj.canChangeName = isUserOwnerOrManager;
        wrapperObj.canDelete = false;
        
     	return wrapperObj;
	}

	@TestVisible 
    private ResponseWrapper unlinkGoogleDriveFolder (Map<String, String> requestMap) {
        logger.logDebug('FileDataServer.unlinkGoogleDriveFolder-----'+ requestMap);
        ResponseWrapper responseWrapperObj = null;
		try{
			String folderId = requestMap.get('folderId');
			String siteId = requestMap.get('siteId');
			FolderDao daoObj = new Folderdao();
			List<Folder__c> folderList = daoObj.getExternalFolderDetails('googledrive', folderId, siteId);
			// Simpplr managed permissions 
			if (!folderList.isEmpty() && !SimpplrContext.googleManagedPermission) {
				List<String> permissionIdList = new List<String>();
				permissionIdList.add(folderList[0].EFS_Read_Collaboration_Id__c);
				permissionIdList.add(folderList[0].EFS_Read_Write_Collaboration_Id__c);
				permissionIdList.add(folderList[0].EFS_Search_Collaboration_Id__c);

				if (String.isNotBlank(folderList[0].EFS_All_Company_Collaboration_Id__c)) {
					permissionIdList.add(folderList[0].EFS_All_Company_Collaboration_Id__c);
				}

				GoogleDriveService gfs = new GoogleDriveService();
				gfs.unlinkFolder(folderId, permissionIdList);
				daoObj.deleteEFSFolderRecord(folderList[0].id);
			
			// Google managed permissions just delete folder
			} else  {
				daoObj.deleteEFSFolderRecord(folderList[0].id);
			}

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
     	
		} catch(exception e){
			logger.logError('FileDataServer.unlinkGoogleDriveFolder()-----could not unlink google drive folder----',e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}

		return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper createGoogleFolder(Criteria.Folder folderObjArg) {
     	logger.logDebug('FileDataServer.createGoogleFolder()----folderObjArg----'+folderObjArg + '--' + SiteContext.siteId);
        ResponseWrapper responseWrapperObj = null;
        FileListingWrapper wrapperObj = new FileListingWrapper();

        try {
            wrapperObj = new GoogleDriveService().createNewFolder(folderObjArg);
		    responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, wrapperObj);     		
         
        } catch (Exception ex) {
     		logger.logError('FileDataServer.createGoogleFolder----Exception occured----', ex);     		
     		responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null); 
     	}

     	return responseWrapperObj;
    }

    @TestVisible 
    private ResponseWrapper resetGoogleDriveAccessToken() {
     	logger.logDebug('FileDataServer.resetGoogleDriveAccessToken()');
     	GoogleDriveService serviceObj = new GoogleDriveService();
     	Boolean isSuccess = serviceObj.expireAccessToken();
     	ResponseWrapper responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, null);
     	return responseWrapperObj;
	}
	
	@TestVisible 
    private ResponseWrapper getSitesWithGoogleDriveFileStortage(Criteria.File criteriaObj) {
    	
		if(!UserContext.isGoogledriveConnected) {
			throw new SimpplrException(STR_KEY_ERROR_GDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
		}
		ResponseWrapper responseToReturn;
		try{			
			Integer nextPageToken = criteriaObj.nextPageToken != null ? Integer.valueOf(criteriaObj.nextPageToken) : 0;
			List<FileListingWrapper> listOfFileWrapper = new FileContentProvider().getSitesWithFileStortage(criteriaObj);
    	
			FileListingWrapper.PaginationWrapper paginationObj = new FileListingWrapper.PaginationWrapper();
			paginationObj.listOfItems.addAll(listOfFileWrapper);
			
			if (paginationObj.listOfItems.size() == (criteriaObj.size + 1) && nextPageToken < 2000) {
				paginationObj.listOfItems.remove((paginationObj.listOfItems.size()-1));
				paginationObj.nextPageToken = String.valueOf(nextPageToken + criteriaObj.size);
			} else {
				paginationObj.nextPageToken = null;
			}
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, paginationObj);
		} catch(Exception e) {
			logger.logError(e);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}
	 	return responseToReturn;
	}

	private ResponseWrapper searchGoogleDriveFiles(Criteria.File criteriaObj) {
    	
		if(!UserContext.isGoogledriveConnected) {
			throw new SimpplrException(STR_KEY_ERROR_GDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
		}
		ResponseWrapper responseToReturn;
		try{
			
			ResponseWrapper responseWrapperObj;   	
			FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper();
			filePaginatorObj.shareddriveName = null;
			if(String.isNotBlank(criteriaObj.siteId) && String.isNotBlank(criteriaObj.driveType) && 'shareddrive'.equalsIgnoreCase(criteriaObj.driveType)) {
				String siteId = criteriaObj.siteId;
				Map<String, Object> soqlParamMap = new  Map<String, Object>();
				soqlParamMap.put('soqlParam1', siteId);
				String query = 'SELECT Id, Name__c, Site__c, Type__c, Drive_Type__c, External_Folder_Id__c, Is_Deleted__c '+
								' FROM Folder__c where Type__c = \'googledrive\' and Drive_Type__c = \'shareddrive\' '+
								' and Is_Deleted__c = false and Site__c =: soqlParam1';
				SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
				List<Folder__c> folderList = (List<Folder__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
				if(folderList.size() > 0) {
					criteriaObj.directory = folderList[0].External_Folder_Id__c;
					filePaginatorObj.shareddriveName = folderList[0].Name__c;
				}
			} else if(String.isNotBlank(criteriaObj.siteId) && String.isNotBlank(criteriaObj.driveType) && IntegrationConstants.GOOGLE_DRIVE_TYPE_MYDRIVE.equalsIgnoreCase(criteriaObj.driveType)) {
				String siteId = criteriaObj.siteId;
				FolderDao folderDaoObj = new FolderDao();
				filePaginatorObj.isMyDriveFolderLinked = folderDaoObj.isMyDriveFolderLinkedForSite(siteId);
			}			
			if(String.isBlank(criteriaObj.siteId) || filePaginatorObj.shareddriveName != null || filePaginatorObj.isMyDriveFolderLinked == true) {
				Map<String, Object> folderContents = new GoogleDriveService().searchFiles(criteriaObj);
				filePaginatorObj.listOfItems = (List<FileListingWrapper>) folderContents.get('listOfFiles');
				filePaginatorObj.totalRecordsStr = (String)folderContents.get('totalRecords');
				filePaginatorObj.nextPageToken = (String) folderContents.get('nextPageToken'); 
			} else {
				filePaginatorObj.totalRecordsStr = String.valueOf(0);
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);			
        	return responseWrapperObj;
			
		} catch(Exception e) {
			logger.logError(e);
			responseToReturn = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}
	 	return responseToReturn;
	}
	
	public ResponseWrapper getLinkedGoogleDriveFolders( Criteria.File fileCriteriaObjArg ){
		ResponseWrapper responseWrapperObj;
		try{
            
            if (!UserContext.isGoogledriveConnected) {
                throw new SimpplrException(STR_KEY_ERROR_GDRIVE_NOT_CONNECTED.replace('{{appName}}', SimpplrContext.applicationName));
            }
            
			Integer nextPageToken = 0;
			if(fileCriteriaObjArg.size == null) {
				fileCriteriaObjArg.size = SimpplrContext.simpplrDefaultPageSize;
			}
			if (fileCriteriaObjArg.nextPageToken == null) {
				fileCriteriaObjArg.offset = 0;
				
			} else {
				fileCriteriaObjArg.offset = Integer.valueOf(fileCriteriaObjArg.nextPageToken);
				nextPageToken = fileCriteriaObjArg.offset;
			}
			FileListingWrapper.PaginationWrapper filePaginatorObj = new FileListingWrapper.PaginationWrapper ();
			List<FileListingWrapper> listOfFileWrapper = new FileContentProvider().getGoogleDriveLinkedFolderForASite(fileCriteriaObjArg );
			filePaginatorObj.listOfItems.addAll(listOfFileWrapper);
			FileListingWrapper fileWrapObj = new FileListingWrapper();
			
			if (filePaginatorObj.listOfItems.size() == (fileCriteriaObjArg.size + 1) && nextPageToken < 2000) {
				filePaginatorObj.listOfItems.remove((filePaginatorObj.listOfItems.size()-1));
				filePaginatorObj.nextPageToken = String.valueOf(nextPageToken + fileCriteriaObjArg.size);
			} else {
				filePaginatorObj.nextPageToken = null;
			}
			filePaginatorObj.directory = new FileListingWrapper.DirectoryWrapper();
			
			filePaginatorObj.directory.id = 'virtual';
			filePaginatorObj.directory.name = LocaleContext.getLabel(UserContext.languageLocaleKey, 'files.system_folder.googledrive_files');
			filePaginatorObj.directory.isSystemDir = true;
			filePaginatorObj.directory.canLinkFolder = SiteContext.canManage();

			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, filePaginatorObj);
		} catch(Exception e) {
			logger.logError(e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, MessageHelper.translateSFMessageToErrorCode(e), null);
		}
	 	return responseWrapperObj;
	}

	@TestVisible
    private ResponseWrapper uploadImageToAWS (String contentVersionId) {
		logger.logDebug('FileDataServer.uploadImageToAWS()----contentVersionId----' + contentVersionId);
		ResponseWrapper responseWrapperObj = null;
		String publicURL;
		try{
			Map<String, Object> soqlParamMap = new Map<String, Object>();
			soqlParamMap.put('soqlParam1', contentVersionId);
			String filesQuery = 'select id, content_version__c, thumbnail_url__c, title__c from file__c '+
									' where simpplr_content__c!= null AND content_version__c=:soqlParam1';
			SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
			List<File__c> fileList = (List<File__c>)SIMPESAPI.accessController().queryAsUser(filesQuery, soqlParamMap);
			if(!fileList.isEmpty()) {
				if(String.isNotBlank(fileList[0].thumbnail_url__c) && fileList[0].thumbnail_url__c.startsWith('https://static.simpplr.com')) {
					publicURL = fileList[0].thumbnail_url__c;
				} else {
					FileContentProvider provider = new FileContentProvider();
					publicURL = provider.uploadImageToAWS(fileList[0].title__c, contentVersionId);
					Map<String, String> urlMap = new Map<String, String>();
					urlMap.put(contentVersionId, publicURL);
					provider.updateThumbnailUrl(fileList, urlMap);
				}
			}
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, publicURL);
		} catch(Exception e) {
			logger.logError('FileDataServer.uploadImageToAWS()----Exception occured----', e);
			responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
	 	return responseWrapperObj;
    }
    
    @TestVisible 
    private ResponseWrapper syncAllCompanyGoogleDriveGroup () {
        logger.logDebug('FileDataServer.syncAllCompanyGoogleDriveGroup()----');
        ResponseWrapper responseWrapperObj;   
        String domainStr = SimpplrContext.Integrations.get(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).Enterprise_Id__c;
		Map<String, Object> soqlParamMap = new Map<String, Object>();
		soqlParamMap.put('soqlParam1', ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING);
        String queryStr = 'SELECT id, User_Email__c,name'+
                ' FROM People_Integration__c WHERE name=:soqlParam1'; 
		SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.WITHOUT);
		List<People_Integration__c> listOfPeopleIntg = (List<People_Integration__c>)SIMPESAPI.accessController().queryAsUser(queryStr, soqlParamMap);
        String resultBody ;

        if (!SimpplrContext.googleManagedPermission) {
            String allCompanyGroupEmail = SimpplrContext.simpplrOrgId;
            allCompanyGroupEmail += '_sfsm@' + domainStr;
            List<GoogleDriveModel.GroupMemberRequest> listOfGrpMemReq = new List<GoogleDriveModel.GroupMemberRequest>();
            
            for (People_Integration__c peopleIntgObj : listOfPeopleIntg) {
                GoogleDriveModel.GroupMemberRequest addAllCompGroupMemberReq = new GoogleDriveModel.GroupMemberRequest();
                addAllCompGroupMemberReq.groupEmail = allCompanyGroupEmail;
                addAllCompGroupMemberReq.memberEmail = peopleIntgObj.User_Email__c;
                listOfGrpMemReq.add(addAllCompGroupMemberReq);
            }

            resultBody = new GoogleDriveService().addMembersToGroupBulk(listOfGrpMemReq);
        }

        responseWrapperObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, resultBody);
     	return responseWrapperObj;
    }

	/**
	 * @description this method is used to get download URL to download audience csv 
	 * @param requestDataMap
	 * @return ResponseWrapper - with presigned url from AWS
	 */
	private ResponseWrapper getAudienceCSVDownloadURL(Map<String, String> requestDataMap) {
		logger.logDebug('FileDataServer.getAudienceCSVDownloadURL()----requestDataMap'+ requestDataMap);
		ResponseWrapper responseObj = new ResponseWrapper();	
		try{
			String endpoint = SimpplrContext.simpplrAPIEndpoint + '/audience/manage-audience';
			Map<String, Object> requestBody = new Map<String, Object>();
			requestBody.put('orgId', SimpplrContext.simpplrOrgId);
			requestBody.put('fileId', requestDataMap.get('fileId'));
			requestBody.put('peopleId', UserContext.peopleId);
			requestBody.put('action', 'getDownloadURL');

			HttpResponse response =	Utility.getResponseFromAWS(endpoint, requestBody);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_SUCCESS, null, JSON.deserializeUntyped(response.getBody()));
		} catch (Exception e){
			logger.logDebug('FileDataServer.getAudienceCSVDownloadURL()-----Exception-- '+ e);
			responseObj = buildResponseWrapper(RESPONSE_STATUS_ERROR, null, null);
		}
		return responseObj;
	}
}