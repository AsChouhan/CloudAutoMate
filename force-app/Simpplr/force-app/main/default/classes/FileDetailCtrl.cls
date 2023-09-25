/*
* Purpose: Controller class to handle file detail page 
* 
* Functions defined in the Class
* 1. PageReference init() 
* 2. Boolean updateFileName(String, String)
* 3. FileDetailWrapper createFile(Criteria.File)
* 4. FileDetailWrapper addFile(Criteria.File, Blob)
* 5. List<FileListingWrapper> listFiles(String)
* 6. List<FileListingWrapper> myFiles(Boolean)
* 7. boolean deleteFile(String) 
* 9. Boolean starFile(String, Boolean)
* 10. FileDetailWrapper getFileDetail(String)
*/
public with sharing class FileDetailCtrl extends BaseCtrl {

	public transient final String STR_LOADING { get { return labelMap.get('common.loading');}}
	public transient final String STR_UNLIKE { get { return labelMap.get('common.unlike');}}
	public transient final String STR_LIKE { get { return labelMap.get('common.like');}}
	public transient final String STR_FAVORITE { get { return labelMap.get('common.favorite');}}
	public transient final String STR_UNFAVORITE { get { return labelMap.get('common.unfavorite');}}
	public transient final String STR_BTN_SHARE_LBL { get { return labelMap.get('button_label.share');}}
	public transient final String STR_LIKE_PLURAL { get { return labelMap.get('like_plural');}}
	public transient final String STR_OWNER { get { return labelMap.get('common.owner');}}
	public transient final String STR_TYPE { get { return labelMap.get('common.type');}}
	public transient final String STR_SIZE { get { return labelMap.get('common.size');}}
	public transient final String STR_FILE { get { return labelMap.get('common.file');}}
	public transient final String STR_DOWNLOAD { get { return labelMap.get('common.download');}}
	public transient final String STR_SITE_PLURAL { get { return labelMap.get('common.site_plural');}}
	public transient final String STR_EDITED { get { return labelMap.get('common.edited');}}
	public transient final String STR_VERSION { get { return labelMap.get('common.version');}}
	public transient final String STR_VESRION_HISTORY { get { return labelMap.get('file_detail.version_history');}}
	public transient final String STR_ADD_NEW_VERSION { get { return labelMap.get('file_detail.add_new_version');}}
	public transient final String STR_DELETE_FILE { get { return labelMap.get('button_label.delete_file');}}
	public transient final String STR_BTN_EDIT_LBL { get { return labelMap.get('button_label.edit');}}
	public transient final String STR_DESCRIPTION { get { return labelMap.get('common.description');}}
	public transient final String STR_MODIFIED_BY { get { return labelMap.get('common.modified_by');}}
	public transient final String STR_LOCATION { get { return labelMap.get('location');}}
	public transient final String STR_REFRESH_LBL { get { return labelMap.get('button_label.refresh');}}
	public transient final String STR_NO_PREVIEW { get { return labelMap.get('file.no_preview');}}
	public transient final String STR_CANNOT_SHOW { get { return labelMap.get('file.cannot_show');}}
	public transient final String STR_CONNECT_PROVIDER_WARNING_MOBILE { get { return labelMap.get('file.connect_provider.warning_mobile');}}
	public transient final String STR_CONNECT_PROVIDER_WARNING_DESKTOP { get { return labelMap.get('file.connect_provider.warning_desktop');}}
	public transient final String STR_DOWNLOAD_AS_PDF { get { return labelMap.get('file.download_as_pdf');}}
	public transient final String STR_PROVIDER_BOX { get { return labelMap.get('file.provider.box');}}
	public transient final String STR_PROVIDER_GOOGLE_DRIVE { get { return labelMap.get('file.provider.googledrive');}}
	public transient final String STR_PROVIDER_ONEDRIVE { get { return labelMap.get('file.provider.onedrive');}}
	public transient final String STR_PROVIDER_SHAREPOINT { get { return labelMap.get('file.provider.sharepoint');}}
	public transient final String STR_PROVIDER_DROPBOX { get { return labelMap.get('file.provider.dropbox');}}
	public transient final String STR_VIEW_ON_PROVIDER { get { return labelMap.get('file.location.view_storage_provider');}}
	public transient final String STR_FAVORITE_FILE { get { return labelMap.get('file.favorite_file');}}
	public transient final String STR_SHARE_THIS_FILE { get { return labelMap.get('file.options.share');}}
	public transient final String STR_LIKE_THIS_FILE { get { return labelMap.get('common.like_this_noun').replace('{{noun}}', STR_FILE);}}
	public transient final String STR_UNLIKE_THIS_FILE { get { return labelMap.get('common.unlike_this_noun').replace('{{noun}}', STR_FILE);}}
	public transient final String STR_FAVORITE_THIS_FILE { get { return labelMap.get('common.favorite_this_noun').replace('{{noun}}', STR_FILE);}}
	public transient final String STR_UNFAVORITE_THIS_FILE { get { return labelMap.get('common.unfavorite_this_noun').replace('{{noun}}', STR_FILE);}}
	/**
	 * @description localized String for Button open in sharepoint
	*/
	public transient final String STR_BTN_OPEN_IN_SHAREPOINT { get { return labelMap.get('file.sharepoint.open_in_sharepoint_button');}}
	/**
	 * @description localized String for msg dont have access
	*/
	public transient final String STR_DONT_HAVE_FILE_ACCESS_MSG { get { return labelMap.get('file.sharepoint.no_file_access_message');}}
	/**
	 * @description localized String for msg file dont exist
	*/
	public transient final String STR_FILE_DONT_EXIST_MSG { get { return labelMap.get('file.sharepoint.no_file_access_or_not_exists_message');}}
	/**
	 * @description localized String for msg unable to display file
	*/
	public transient final String STR_UNABLE_TO_DISPLAY_FILE_MSG { get { return labelMap.get('file.sharepoint.no_file_access_header');}}
	public  string native_video_url{get;set;}
	/**
	 * @description localized String for msg block download
	*/
	public transient final String STR_SHAREPOINT_BLOCK_DOWNLOAD_MESSAGE { get { return labelMap.get('file.sharepoint.file_download_blocked');}}
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
	private final String STR_KEY_SYS_FOLDER_GDRIVE_FILES = 'files.system_folder.gdrive_files';
	private final String STR_KEY_SYS_FOLDER_DROPBOX_FILES = 'files.system_folder.dropbox_files';
	private final String STR_KEY_SYS_FOLDER_SHAREPOINT_FILES = 'files.system_folder.sharepoint_files';
	private final String STR_KEY_SYS_FOLDER_ONEDRIVE_FILES = 'files.system_folder.onedrive_files';
	private final String STR_KEY_LOC_NOT_AVAILABLE = 'file.location.not_available';


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
	
	public String fileId {get; set;}
	public String directory {get; set;}
	public String directoryName {get; set;}
	public FileDetailWrapper fileDetailWrapObj {get; set;}
	public Boolean showSocialOptions{get; set;}
	public Boolean showVersionHistory{get; set;}
	public String fileDetailJson {
		get {
			FileDetailWrapper detailWrapper = fileDetailWrapObj;
			
			if('googledrive'.equalsIgnoreCase(detailWrapper.provider)) {
				detailWrapper.isImage = false;
			}
			
			return Json.serialize(detailWrapper);
		}
		set;
	}
	
	public String userNotConnectedMessage{get;set;}

	public String provider {get; set;}
	public String externalAppsURL {get; set;}
	public Boolean showBoxNotConnectedMessage {get; set;}
	public Boolean showGdriveNotConnectedMessage {get; set;}
	public Boolean showDropboxNotConnectedMessage {get; set;}
	public Boolean showSharepointNotConnectedMessage {get; set;}
	public Boolean showOnedriveNotConnectedMessage {get; set;}
	/**
	 * @description Check to Show Sharepoint File Access Denied Error Page
	*/
	public Boolean showSpFileAccessDeniedMessage {get; set;}
	public String viewInHTML {get; set;}
	public String usingFlashCSS {get; set;}
	public String iosHiddenCSS {get; set;}
	public Boolean previewResponseAsPdfBool {get; set;}
	public Boolean previewResponseAsHtmlBool {get; set;}
	public static final Set<String> DB_FILES_PDF_PREVIEW_SET = new Set<String>{'AI', 'DOC', 'PDF',
			 'DOCM', 'DOCX', 'EPS', 'ODP', 'ODT', 'PPS', 'PPSM', 'PPSX', 'PPT', 'PPTM', 'PPTX', 'RTF'};
	public static final Set<String> DB_FILES_HTML_PREVIEW_SET = new Set<String>{'CSV', 'ODS','XLS', 
			'XLSM', 'XLSX'};		 
	public static final Set<String> INTRANET_FILES_NON_PDF_PREVIEW_SET = new Set<String>{'DOC', 
			'DOCX', 'PPT', 'POWERPOINT', 'PPTX', 'EXCEL', 'WORD', 'RTF', 'WORD_T', 'POWER_POINT_T', 'POTX', 'DOTX', 
			'PPSX'};
	public Boolean isNonPDFIntranetFilePreviewAvailable {get;set;}
	public Boolean isFileNameHasInvalidChar {get;set;}
	public Boolean isFileNotFoundOrNoAccess {get;set;}
	/**
	 * @description Check for Show Open In Sharepoint Button
	*/
	public Boolean isShowOpenInSharePoint {get;set;}
	/**
	 * @description Sp File External Url
	*/
	public String fileExternalUrl {get;set;}
	public FileDetailCtrl() {
		isNonPDFIntranetFilePreviewAvailable = false;
	   	fileDetailWrapObj = new FileDetailWrapper(); 
	   	previewResponseAsPdfBool = false;
	   	previewResponseAsHtmlBool = false;
	   	isFileNotFoundOrNoAccess = false;
		isShowOpenInSharePoint = SimpplrContext.showOpenInSharePoint;
   	}
   
   	public static String pageName {get{
   	
		if (String.isEmpty(pageName)) {
			pageName = PageContext.namespacePrefix + 'FileDetail';
		}
		
		return pageName;
	}set;}
   
   	public override String getPageFeature () {
		return AccessManager.FEATURE_FILE;
   	}
   
   	public Boolean isMobileMode { get {
   		return Utility.isMobileMode; 
   	}set;}
   	
   	public Boolean isFeedEnabled { get {
   		return SimpplrContext.isFeedEnabled;
   	}set;}
   
	public String getPageTitle() {
		return (fileDetailWrapObj != null && String.isNotBlank(fileDetailWrapObj.title) ?
				fileDetailWrapObj.title :  'Files Detail') + AppPageTitle;
	}
	
   	public PageReference init() {
   		logger.logDebug('init()---start--request params-- ' + ApexPages.currentPage().getParameters());
		PageReference returnPage = null;
		
		try {
			logger.logDebug('init()---checking page access--when page-- ' + pageName +' and page feature is- ' + getPageFeature());
			showSocialOptions = true;
			showVersionHistory = true;
			provider = readParam('provider');
			//For older gdrive urls
			if('gdrive'.equalsIgnoreCase(provider)) {
				provider = ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING;
			}
			
			if (!AccessManager.hasPageAccess(getPageFeature())) {
					logger.logDebug('init()---page access denied--when page-- ' + pageName + 
						' and page feature is- ' + getPageFeature());
				throw new SimpplrException(ServiceConstants.ERROR_404);
	   	 	} else if(ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(provider) || 
	   	 			  ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(provider) ||
					  ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING.equalsIgnoreCase(provider) || 
					  ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING.equalsIgnoreCase(provider) ||
					  ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)) {
				if (!SimpplrContext.Integrations.containsKey(provider)) {
	   	 			throw new SimpplrException(ServiceConstants.ERROR_404);
	   	 		}
			}
			
			logger.logDebug('init()---start loading page metadata--');
			String selectedUserId = readParam('profileId');
			
			if (String.isNotBlank(selectedUserId) && 
					UserContext.userId.equalsIgnoreCase(selectedUserId) == false && 
					UserContext.peopleId.equalsIgnoreCase(selectedUserId) == false) {
				throw new SimpplrException(ServiceConstants.ERROR_403);
			}
			
			fileId = readParam('fileId');
			
		   	if (String.isblank(fileId)) {
				MessageHelper.addErrorMessage(ExceptionCode.MISSING_REQUIRED_PARAM.name(),false);
			}
			
			logger.logDebug('FileDetailCtrl.init()--- start initializeFileDetail()');
			externalAppsURL = PageContext.getPageURL(Pages.app) + '?u=/my-settings/external-apps';
			if(String.isNotBlank(provider)) {
				userNotConnectedMessage = STR_CONNECT_PROVIDER_WARNING_DESKTOP.replace('{{provider}}', provider);
				userNotConnectedMessage = userNotConnectedMessage.replace('{{externalAppsURL}}',externalAppsURL);

			}

			initializeFileDetail(fileId);
			logger.logDebug('FileDetailCtrl.init()---end initializeFileDetail()');

			if(isFileNotFoundOrNoAccess 
				&& ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING.equalsIgnoreCase(provider)){
				Map<String, String> params = new Map<String, String>{'u' => '/error/404', 'provider' => ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING};
				// send externalURL only if showfile and request access enabled
				if(SimpplrContext.showOpenInGoogleDrive == true){
					params.put('externalUrl', 'https://drive.google.com/file/d/'+fileId+'/view?usp=drivesdk');
				}
				returnPage = new PageReference(PageContext.getPageURL(Pages.app, params));
				returnPage.setRedirect(true);
			}

			if(isFileNotFoundOrNoAccess && ServiceConstants.STORAGE_TYPE_BOX_STRING.equalsIgnoreCase(provider)){
				String paramsStr = 'u=/error/404&provider=' + ServiceConstants.STORAGE_TYPE_BOX_STRING;

				// send externalURL only if showfile and request access enabled
				if(SimpplrContext.showOpenInBox == true){
					paramsStr += '&externalUrl=https://app.box.com/files/0/f/' + directory + '/1/f_' + fileId;
				}

				returnPage = new Pagereference('/apex/app?' + paramsStr);
				returnPage.setRedirect(true);
			} else {
				if ('box'.equalsIgnoreCase(provider)){
					viewInHTML = '<a href="https://app.box.com/files/0/f/' + directory + '/1/f_' + fileId + '">' + STR_VIEW_ON_PROVIDER.replace('{{storageProvider}}', STR_PROVIDER_BOX) + '</a>' ; 
				}
				
				iosHiddenCSS = 'ios-hidden';
				
				if ('box'.equalsIgnoreCase(provider) == false 
						&& ServiceConstants.STORAGE_TYPE_GDRIVE_STRING.equalsIgnoreCase(provider) == false 
						&& ServiceConstants.STORAGE_TYPE_DROPBOX_STRING.equalsIgnoreCase(provider) == false) {
					iosHiddenCSS = fileDetailWrapObj.isDownloadableOniOS ? '' : 'ios-hidden';
				}
			}
				
			logger.logDebug('FileDetailCtrl.init()---end loading page metadata--');
			
		} catch (Exception e) {
			returnPage = handleAndTranslateException(returnPage, e);
		}
		
		logger.logDebug('init()---page successfully loaded--');
	   	return returnPage;
   }
   
   @TestVisible 
   private void initializeFileDetail(String fileId) {
				
		FileDao fileDaoObj = new FileDao();
   		showBoxNotConnectedMessage = false;
   		showGdriveNotConnectedMessage = false;
   		showDropboxNotConnectedMessage = false;
		showSpFileAccessDeniedMessage = false;
		String rootDirectory = readParam('rootdirectory');
		String siteId = readParam('siteId');
		String collaborationGroupId ;   
   		String directoryArg = readParam('directory');
   		String permArg = readParam('permission');   
   		if(ServiceConstants.VIDEO_PROVIDER_NATIVE.equalsIgnoreCase(provider)){
			
			if (!SimpplrContext.Integrations.containsKey(ServiceConstants.VIDEO_PROVIDER_NATIVE)) {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}else {
				file__c fileObj = FileDao.getFileRecordDetails(fileId);
				if(fileObj == null) {
					throw new SimpplrException(ServiceConstants.ERROR_404);
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
					
					Map<String, Object> soqlParamMap = new  Map<String, Object>();
					soqlParamMap.put('soqlParam1', fileObj.OwnerId);
					String query = 'select id,People__c,People__r.Full_Name__c,user__c from People_Preference__c where People__r.user__c =:soqlParam1';	
					SIMPESAPI.accessController().setSharingMode(SIMPSFDCAccessController.SharingMode.Without);
					List<People_Preference__c> peoplePreferenceList = (List<People_Preference__c>)SIMPESAPI.accessController().queryAsUSer(query, soqlParamMap);
					People_Preference__c peoplePreferenceObj = peoplePreferenceList[0];
					VideoDao daoObj = new VideoDao() ;
					Map<String,Object> requestDataMap = daoObj.getAccessToken() ;
					Map<String,Object> accessTokenMap  =(Map<String, Object>)requestDataMap.get('accessToken');  
					fileDetailWrapObj.title = fileObj.Title__c ;
					fileDetailWrapObj.fileType = fileObj.MIME_Type__c ;	
					fileDetailWrapObj.fileExtension = fileDetailWrapObj.title!=null ?fileDetailWrapObj.title.substring(fileDetailWrapObj.title.lastIndexOf('.')+1):null;
					fileDetailWrapObj.fileSize = fileObj.Size__c != null ? Utility.byteToHumanReadableFormate(fileObj.Size__c) : null;
					fileDetailWrapObj.size = fileObj.Size__c != null ? Integer.valueof(fileObj.Size__c):null ;
					fileDetailWrapObj.thumbnailImg = fileObj.Thumbnail_url__c;
					fileDetailWrapObj.lastModifiedDate =  LocaleContext.getLocalisedDateAsMMMDDYYYYhhmmss(fileObj.lastModifiedDate, UserContext.languageLocaleKey);
					fileDetailWrapObj.owner.Id = peoplePreferenceObj.people__c;
					fileDetailWrapObj.owner.Name = peoplePreferenceObj.People__r.Full_Name__c;
					fileDetailWrapObj.owner.URL = PageContext.getPageURL(Pages.app) + '?u=/people/' + peoplePreferenceObj.People__c;
					fileDetailWrapObj.modifiedAt = Utility.dateTimeToMomentJSDateTime(fileObj.lastModifiedDate);
					if (UserContext.isUserAppModerator || (fileObj.site__c == null && UserContext.peopleId.equalsIgnoreCase(fileObj.Author__c))) {
						fileDetailWrapObj.canDelete = true;
					}
					if(UserContext.isUserAppModerator || isSiteManager || isContentManager || isAuthor) {
						fileDetailWrapObj.canEdit = true;
					}
					fileDetailWrapObj.listOfSite = null;
					fileDetailWrapObj.canDownload = false;
					fileDetailWrapObj.id = fileId;
					fileDetailWrapObj.fileId = fileObj.id;
					showSocialOptions = true ;
					fileDetailWrapObj.isFavorited = fileDaoObj.isFileBookmarked(fileId, provider);
					fileDetailWrapObj.canCreateNewVersion = false ;
					showVersionHistory=false;
					fileDetailWrapObj.description = fileObj.description__c;
					fileDetailWrapObj.context = ServiceConstants.VIDEO_PROVIDER_NATIVE; 
					if(!string.isBlank(fileObj.site__c)){
						siteId =fileObj.site__c ;
					}else if(!string.isBlank(fileObj.simpplr_content__c)){
						siteId =fileObj.simpplr_content__r.site__c ;
					}
					fileDetailWrapObj.publicUrl =  PageContext.getPageURL(Pages.app) + '?u=/video/' + fileObj.external_id__c;
					fileDetailWrapObj.url = fileDetailWrapObj.publicUrl;
					if(!string.isBlank(siteId)){
						directoryArg = fileObj.folder__c != null ? fileObj.folder__c:'';
						fileDetailWrapObj.listOfParents = FileContentProvider.getListOfParents(siteId, provider, directoryArg, fileId);
					}
					native_video_url = (string)requestDataMap.get('playerUrl') + '&entry_id='+fileObj.external_id__c;
  
				}			
			}
		}else if ('box'.equalsIgnoreCase(provider)) {
			if (SimpplrContext.IsBoxIntegrationEnabled && UserContext.isBoxConnected == false) {
				showBoxNotConnectedMessage = true;
				return;
			}
			try {
				fileDetailWrapObj = BoxContentProvider.getBoxFileDetails(fileId, rootDirectory);
				directory = String.isBlank(readParam('directory')) ? '0' :  readParam('directory');
				fileDetailWrapObj.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileDetailWrapObj.id,'rootDirectory' =>rootDirectory, 'directory'=> directory});
				fileDetailWrapObj.url = fileDetailWrapObj.publicUrl;
				fileDetailWrapObj.isFavorited = fileDaoObj.isFileBookmarked(fileId, provider);
			} catch (Exception ex) {
				isFileNotFoundOrNoAccess = true;
				return;
			}
			
   		} else if ((ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING).equalsIgnoreCase(provider)) {
               
   			if (!userConnectedToEfs(provider)) { 
   				showGdriveNotConnectedMessage = true; 
				return;
   			}
   			
   			GoogleDriveService fileServiceObj = new GoogleDriveService();
			try {
			   fileDetailWrapObj = fileServiceObj.getFileDetail(fileId);
			} catch (Exception ex) {
				isFileNotFoundOrNoAccess = true;
				return;
			}
            
            if (fileDetailWrapObj != null ) { 
                fileDetailWrapObj.publicUrl = PageContext.getPageURL(Pages.FileDetail, 
                    new Map<String, String>{'fileId' => fileDetailWrapObj.id, 
                    'provider' => ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING, 
                    'directory'=> directoryArg});
                fileDetailWrapObj.url = fileDetailWrapObj.publicUrl;
                fileDetailWrapObj.pdfViewUrl = PageContext.getPageURL(Pages.PdfPreview, 
                        new Map<String, String>{'fileId' => fileDetailWrapObj.id,
                        'provider' => ServiceConstants.STORAGE_TYPE_GOOGLE_DRIVE_STRING, 
                        'type' => fileDetailWrapObj.fileType});
				fileDetailWrapObj.isFavorited = fileDetailWrapObj.isBookmarked;
                viewInHTML = '<a href=' + fileDetailWrapObj.viewInGoogleDrive + 
                        '>' + STR_VIEW_ON_PROVIDER.replace('{{storageProvider}}', 
                        STR_PROVIDER_GOOGLE_DRIVE) + '</a>' ;

            } else  {
                throw new SimpplrException(ServiceConstants.ERROR_404);
            }
			
   		} else if ((ServiceConstants.STORAGE_TYPE_DROPBOX_STRING).equalsIgnoreCase(provider)) {

   			if (!userConnectedToEfs(provider)) {
   				showDropboxNotConnectedMessage = true;
				return;
   			}
			
			EFSFileService fileServiceObj = new EFSFileService(provider);
   			fileDetailWrapObj = fileServiceObj.getFileDetail(fileId, '', siteId, permArg);
   			fileDetailWrapObj.pdfViewUrl = PageContext.getPageURL(Pages.PdfPreview, new Map<String, String>{'fileId' => fileDetailWrapObj.id,
   						'provider' => ServiceConstants.STORAGE_TYPE_DROPBOX_STRING, 'type' => fileDetailWrapObj.fileType,
   						'folderPath' => Utility.encodeUrlString(fileDetailWrapObj.fileUrl)});
   			
   			if (DB_FILES_PDF_PREVIEW_SET.contains(fileDetailWrapObj.fileType)) {
   				previewResponseAsPdfBool = true;
   			
   			} else if (DB_FILES_HTML_PREVIEW_SET.contains(fileDetailWrapObj.fileType)) {
   				previewResponseAsHtmlBool = true;
   			}
   			
			fileDetailWrapObj.isFavorited = fileDetailWrapObj.isBookmarked;
   			viewInHTML = '<a href="https://www.dropbox.com/home'+ Utility.encodeUrlString(fileDetailWrapObj.fileUrl) 
   					+'">' + STR_VIEW_ON_PROVIDER.replace('{{storageProvider}}', STR_PROVIDER_DROPBOX) + '</a>' ;
   			fileServiceObj.close();
   			
   		} else if ((ServiceConstants.STORAGE_TYPE_SHAREPOINT_STRING).equalsIgnoreCase(provider)) { 
			fileExternalUrl = readParam('externalUrl');
   			if (!userConnectedToEfs(provider)) {
   				showSharepointNotConnectedMessage = true;
   				return;
   			}
			
			EFSFileService fileServiceObj = new EFSFileService(provider);
			fileDetailWrapObj = fileServiceObj.getFileDetail(fileId, rootDirectory, siteId, permArg);
			directory = directoryArg;
			if(fileDetailWrapObj.isDifferentSpInstance != null && fileDetailWrapObj.isDifferentSpInstance){
				isShowOpenInSharePoint = false;
			}
			if('none'.equalsIgnoreCase(fileDetailWrapObj.permissions)) {  //Access denied
				showSpFileAccessDeniedMessage = true;
				return;
			}
			fileDetailWrapObj.iframeViewUrl = fileServiceObj.getPreviewUrl(fileId, rootDirectory ,siteId);
			fileDetailWrapObj.rootDirectory = rootDirectory;
			fileDetailWrapObj.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileDetailWrapObj.id,'rootDirectory' =>rootDirectory, 'provider' => 'sharepoint' , 'siteId'=> siteId});
			fileDetailWrapObj.url = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileDetailWrapObj.id,'rootDirectory' =>rootDirectory, 'provider' => 'sharepoint'});
			
			if(String.isNotBlank(fileDetailWrapObj.viewInExternalSystem)) {
				if(fileDetailWrapObj.viewInExternalSystem.containsIgnoreCase('my.sharepoint.com/')){
					viewInHTML = '<a href="'+fileDetailWrapObj.viewInExternalSystem
							+'">' + STR_VIEW_ON_PROVIDER.replace('{{storageProvider}}', STR_PROVIDER_ONEDRIVE) + '</a>' ;
				} else {
					viewInHTML = '<a href="'+fileDetailWrapObj.viewInExternalSystem
							+'">' + STR_VIEW_ON_PROVIDER.replace('{{storageProvider}}', STR_PROVIDER_SHAREPOINT) + '</a>' ;
				}

			}

   		} else if ((ServiceConstants.STORAGE_TYPE_ONEDRIVE_STRING).equalsIgnoreCase(provider)) { 
   			
   			if (!userConnectedToEfs(provider)) {
   				showOnedriveNotConnectedMessage = true;
   				return;
   			}
   			
   			EFSFileService fileServiceObj = new EFSFileService(provider);
   			fileDetailWrapObj = fileServiceObj.getFileDetail(fileId, rootDirectory, siteId, permArg);
   			fileDetailWrapObj.iframeViewUrl = fileServiceObj.getPreviewUrl(fileId, rootDirectory ,siteId);
   			fileDetailWrapObj.rootDirectory = rootDirectory;
   			fileDetailWrapObj.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileDetailWrapObj.id,'rootDirectory' =>rootDirectory, 'provider' => 'onedrive'});
			fileDetailWrapObj.url = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileDetailWrapObj.id,'rootDirectory' =>rootDirectory, 'provider' => 'onedrive' });
			if(String.isNotBlank(fileDetailWrapObj.viewInExternalSystem)) {
				viewInHTML = '<a href="'+fileDetailWrapObj.viewInExternalSystem
							+'">' + STR_VIEW_ON_PROVIDER.replace('{{storageProvider}}', STR_PROVIDER_ONEDRIVE) + '</a>' ;
			}
   			
   		} else {
   			//Both CRM files and Intranet Files 
			ContentDocument fileObj = new ContentDocument();
			fileObj = fileDaoObj.getFileDetails(fileId);

			if (fileObj == null) {
				throw new SimpplrException(ServiceConstants.ERROR_404);
			}
			Set<String> userIds = new Set<String>();
			userIds.add(fileObj.Owner.Id);
			PeopleDao.setPeopleNameMapByUserId(userIds);
			fileDetailWrapObj = ObjectToWrapperAdapter.convertContentDocumentToFileDetailWrapper(fileObj);
			fileDetailWrapObj.publicUrl = PageContext.getPageURL(Pages.FileDetail, new Map<String, String>{'fileId' => fileDetailWrapObj.id, 'provider' => fileDetailWrapObj.provider});
    		if(String.isBlank(provider)) {
    			provider = fileDetailWrapObj.provider;
    		}
    		
			fileDetailWrapObj.url = fileDetailWrapObj.publicUrl;
			
			if(fileDetailWrapObj.title.contains('#')){
				isFileNameHasInvalidChar = true;
			} else {
				isFileNameHasInvalidChar = false;
			}
			
			if ('pdf'.equalsIgnoreCase(fileDetailWrapObj.fileType)) {
				
				if (fileDetailWrapObj.size < 3000000) {
					fileDetailWrapObj.iframeViewUrl = PageContext.getPageURL(Pages.PDFPreview, 
							new Map<String, String>{'fileId' => fileDetailWrapObj.latestPublishedVersionId, 
							'provider' => fileDetailWrapObj.provider, 
							'fileSize' => String.valueOf(fileDetailWrapObj.size), 
							'fileName' => fileDetailWrapObj.name, 
							'type' =>fileDetailWrapObj.fileType});
				} else {
					String bigPdfFileURL = System.URL.getSalesforceBaseUrl().toExternalForm();
					bigPdfFileURL = bigPdfFileURL + '/services/data/v42.0/sobjects/ContentVersion/' + 
						fileDetailWrapObj.latestPublishedVersionId +'/VersionData';
					bigPdfFileURL = EncodingUtil.URLENCODE(bigPdfFileURL, 'UTF-8');
					fileDetailWrapObj.iframeViewUrl = PageContext.getPageURL(Pages.PDFPreview, 
						new Map<String, String>{'file' => bigPdfFileURL,
						'fileId' => fileDetailWrapObj.latestPublishedVersionId, 
						'provider' => fileDetailWrapObj.provider, 
						'fileSize' => String.valueOf(fileDetailWrapObj.size), 
						'fileName' => fileDetailWrapObj.name, 
						'type' =>fileDetailWrapObj.fileType});
				}
				
						
			} else if (INTRANET_FILES_NON_PDF_PREVIEW_SET.contains(fileDetailWrapObj.fileType)) {
				String nonPdfFileURL = System.URL.getSalesforceBaseUrl().toExternalForm();
				nonPdfFileURL = nonPdfFileURL + '/services/data/v42.0/connect/files/' + 
						fileDetailWrapObj.id +'/rendition?versionNumber=' + fileDetailWrapObj.latestPublishedVersionId + '&type=PDF';
				nonPdfFileURL = EncodingUtil.URLENCODE(nonPdfFileURL, 'UTF-8');
				isNonPDFIntranetFilePreviewAvailable = true;
				fileDetailWrapObj.iframeViewUrl = PageContext.getPageURL(Pages.PDFPreview, 
						new Map<String, String>{'file' => nonPdfFileURL,
						'fileId' => fileDetailWrapObj.latestPublishedVersionId, 
						'provider' => fileDetailWrapObj.provider, 
						'fileSize' => String.valueOf(fileDetailWrapObj.size), 
						'fileName' => fileDetailWrapObj.name, 
						'type' =>fileDetailWrapObj.fileType});
			}
			
			if ('Intranet'.equalsIgnoreCase(provider)) {				
				
				if (UserContext.hasModifyAllDataPermission || 
						UserContext.id.equalsIgnoreCase(fileDetailWrapObj.Owner.id)) {
					fileDetailWrapObj.canDelete = true;
					fileDetailWrapObj.canCreateNewVersion = true;
					
				} else {
					fileDetailWrapObj.canDelete = false;
					fileDetailWrapObj.canCreateNewVersion = FileContentProvider.canUserUploadNewVersion(fileId);
				}
				
			} 			
			
			else {
				fileDetailWrapObj.canDelete = UserContext.hasModifyAllDataPermission || UserContext.id.equalsIgnoreCase(fileDetailWrapObj.Owner.id);
				fileDetailWrapObj.canCreateNewVersion = false;
			}
			
			fileDetailWrapObj.canCreatePublicShareLink = fileDetailWrapObj.canCreateNewVersion;
			// Reusing the Code from Global Search Service
			fileDetailWrapObj.listOfSite = null;

			if (String.isBlank(SiteContext.siteId)) {
				
				try {
					fileDetailWrapObj.listOfSite = fileDaoObj.getCVRelatedSites(new Set<Id>{fileDetailWrapObj.latestPublishedVersionId}, provider).get(fileDetailWrapObj.id);
				} catch (Exception e) {
					// Exception in getting the site details
				}
				
			} else {
				fileDetailWrapObj.listOfParents = FileContentProvider.getListOfParents(SiteContext.siteId, provider, directoryArg, fileId);
				directory = directoryArg;
			}
			
			fileDetailWrapObj.isFavorited = fileDaoObj.isFileBookmarked(fileId, provider);
   		}
   		
   		if (fileDetailWrapObj.listOfParents != null && fileDetailWrapObj.listOfParents.size() > 0) {
			Integer parentIndex = fileDetailWrapObj.listOfParents.size() - 1;
			directoryName = fileDetailWrapObj.listOfParents[parentIndex].name;
		
		} else {
			directoryName = provider.capitalize() + ' Files';
		}
		
		fileDetailWrapObj.isLiked = fileDaoObj.isFileLiked(fileId);
		fileDetailWrapObj.likedCount = fileDaoObj.getFileLikes(fileId).size();
		
	}
   	
   	private Boolean userConnectedToEfs(String provider) {

   		if (UserContext.integrations!=null 
   				&& UserContext.integrations.containsKey(provider) 
   				&& !(UserContext.integrations.get(provider).connected__c)
   					|| 
   				UserContext.integrations == null
   					||
   				!UserContext.integrations.containsKey(provider)	) {
   			return false ;		
   		} else {
   			return true;
   		}
   	}
   
}